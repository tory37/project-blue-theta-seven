# Input Ownership & Networking Readiness
**Domain:** Godot 4 Multiplayer Architecture — Input Gating for Interactive Game Objects  
**Project:** project-n1b (card game, turn-based, 2-player, local prototype with networking seam)  
**Date:** 2026-05-18

---

## The Core Problem

You have two decks and (possibly) two avatars in the scene. Both exist as nodes that can receive mouse events. The question is: **who should be allowed to act on a click, and how should that knowledge live in the code?**

There are two distinct click scenarios, and they have different correct answers:

| Scenario | Click Target | Expected Behavior |
|---|---|---|
| A | Your own deck | Attempt to draw a card |
| A | Opponent's deck | Nothing |
| B | Your own avatar | Open your player menu / self-target |
| B | Opponent's avatar | View opponent info / target them |

Scenario A is an **exclusive ownership** interaction — only the owner may act.  
Scenario B is a **dual-meaning** interaction — both clicks are valid, but do different things.

These are different problems. They call for different solutions.

---

## Section I: The "Local Player" Concept — The Foundation

Before any input gating works, there must be a single source of truth that answers: **"Which player is sitting at this machine right now?"**

In your current prototype, `GameState` tracks `active_player` (whose turn it is), but there is no persistent concept of "which physical seat this machine represents." Those are different things:

- `active_player` = whose turn it is (changes during the game)
- `local_player_id` = which player this machine IS (never changes for the lifetime of the session)

**You need to add `local_player_id` to `GameState`.** This is the single variable that every input gate in the game will check. It is also the exact variable that gets replaced by Godot's `multiplayer.get_unique_id()` when networking arrives.

```gdscript
# game_state.gd — add this
var local_player_id: int = PLAYER_ONE  # In hot-seat: set at game start. In network: set from peer_id.
```

For hot-seat play, you set this once at game start (or toggle it per-turn if hot-seat). For networked play, you set it once when the peer connects and never change it.

---

## Section II: Two Approaches — Evaluated

### Approach A: Distributed Ownership Gate (Recommended for Scenario A)

Each interactive node knows which player owns it. On click, it checks ownership before doing anything.

```gdscript
# deck_view.gd
@export var owner_player_id: int = GameState.PLAYER_ONE

func _on_input_event(_camera, event, _pos, _normal, _idx) -> void:
    if not event is InputEventMouseButton:
        return
    if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
        return
    # Ownership gate — the entire action is silently skipped for the wrong player.
    if owner_player_id != GameState.local_player_id:
        return
    SignalBus.deck_clicked.emit(owner_player_id)
```

**When networking arrives**, this one line changes:
```gdscript
# Before (local):
if owner_player_id != GameState.local_player_id:
    return

# After (networked):
if not is_multiplayer_authority():
    return
```

This works because `set_multiplayer_authority(peer_id)` will have been called on each deck node when it spawned, assigning it to the correct peer. `is_multiplayer_authority()` then returns `true` only on the machine that owns that deck.

**Why this is the right choice for Scenario A:** The opponent's deck should be *inert* to the local player. There is no valid action a player can take by clicking the opponent's deck. Silently ignoring it at the node level means the game logic never sees a spurious event — clean and no edge cases.

**Source:** [Godot 4 High-Level Multiplayer Docs](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html) — "you can use `set_process(get_multiplayer_authority() == multiplayer.get_unique_id())` to disable processing entirely on non-authority peers."

---

### Approach B: Centralized Input Router (Recommended for Scenario B — Avatars)

For objects where clicking *any* instance is meaningful, but the *identity of the clicked object* matters, the node should report what was clicked and let game logic decide.

```gdscript
# avatar_view.gd — does NOT gate by ownership
@export var represented_player_id: int

func _on_input_event(_camera, event, _pos, _normal, _idx) -> void:
    if not event is InputEventMouseButton:
        return
    if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
        return
    # No ownership gate — any player's avatar can be clicked by anyone.
    # Emit who WAS clicked, not who clicked.
    SignalBus.avatar_clicked.emit(represented_player_id)
```

The listener (a UI manager or game scene) then decides:

```gdscript
func _on_avatar_clicked(clicked_player_id: int) -> void:
    if clicked_player_id == GameState.local_player_id:
        _open_self_menu()
    else:
        _open_opponent_info(clicked_player_id)
```

**Why this is the right choice for Scenario B:** The avatar interaction has two valid code paths. The node can't know which path to take without knowing both "who clicked" AND "who was clicked." The signal carries the "who was clicked" identity. The listener resolves the "who clicked" from `GameState.local_player_id`. Both pieces of information are present at the listener, not at the node.

---

## Section III: The Full Networking Path

Your project already has the `request_*` / `_apply_*` seam. Here is how input ownership completes that chain.

### Today (Local Prototype)

```
[Click event] 
  → Ownership gate (owner_player_id == GameState.local_player_id)
  → SignalBus.deck_clicked.emit(player_id)
  → GameState.request_draw_card(player_id)
  → GameState._apply_draw_card(player_id)   ← state mutation
```

### Tomorrow (Networked)

The game state authority lives on the server (peer_id = 1). Decks have `set_multiplayer_authority(peer_id)` called on them at spawn time.

```
[Click event on Client A]
  → Ownership gate: is_multiplayer_authority() → true on Client A only
  → GameState.request_draw_card.rpc_id(1, player_id)   ← sends to server
  
[Server receives RPC]
  → Validates: is the requesting peer allowed to draw right now?
  → GameState._apply_draw_card.rpc(player_id)           ← broadcasts state change
  
[All clients receive _apply_draw_card]
  → Each client updates its local visual representation
```

The only code changes when networking arrives:
1. `local_player_id` assignment becomes `multiplayer.get_unique_id()`
2. The ownership gate becomes `is_multiplayer_authority()`
3. `request_*` calls gain `.rpc_id(1, ...)` annotations
4. `_apply_*` calls gain `.rpc(...)` annotations

Zero game logic rewrites. The seam holds.

**Source:** [Godot 4 RPC and Authority](https://godotengine.org/article/multiplayer-changes-godot-4-0-report-2/) — `@rpc("any_peer")` allows any client to call a function on the server, while `@rpc("authority")` restricts broadcasts to the server only.

---

## Section IV: Should Both Decks Even Have Click Listeners?

**Yes — but with the ownership gate in place, it doesn't matter that they both listen.**

The alternative — only wiring up the local player's deck — forces the game setup code to know which deck belongs to whom at connection time, duplicating the ownership logic in a second place. This creates two sources of truth and breaks when a player disconnects/reconnects or the scene is rebuilt.

The single-responsibility rule says: **the deck owns its own input gate.** The scene setup doesn't need to know anything about input routing.

The exception: if clicking the opponent's deck should have a *visual reaction* (e.g., briefly highlighting to show it's not interactive), then the handler remains, but the action logic is still gated. Visual feedback is not a state mutation.

---

## Section V: The 5 Inviolable Laws

1. **`local_player_id` is the single source of truth for "who is at this machine."** It lives in `GameState`, it is set once at session start, and it is the only variable the ownership gate reads.

2. **Exclusive ownership interactions (deck, hand, your UI) gate at the node with `is_multiplayer_authority()` (or its local equivalent).** The game logic layer never sees a spurious click from the wrong player.

3. **Dual-identity interactions (avatars, shared board) do NOT gate at the node.** They emit a signal carrying the *clicked object's identity*, and the listener resolves the correct action using `local_player_id`.

4. **The `request_*` / `_apply_*` seam is your RPC seam.** Never put state mutations in a click handler directly. The click handler calls `request_*`, which becomes `@rpc("any_peer")` on the server. The server's `_apply_*` becomes `@rpc("authority")` to broadcast the result.

5. **The ownership gate is the ONLY difference between local and networked input.** Everything else — signals, request/apply splits, state reads — is already network-ready by design.

---

## Section VI: Concrete Changes Needed Now (Pre-Networking)

To implement this pattern in the current prototype:

**1. Add `local_player_id` to `GameState`:**
```gdscript
var local_player_id: int = PLAYER_ONE
```

**2. Update `DeckView` to know its owner and gate on it:**
```gdscript
@export var owner_player_id: int = GameState.PLAYER_ONE

func _on_input_event(_camera, event, _pos, _normal, _idx) -> void:
    if not event is InputEventMouseButton: return
    if not (event.pressed and event.button_index == MOUSE_BUTTON_LEFT): return
    if owner_player_id != GameState.local_player_id: return
    SignalBus.deck_clicked.emit(owner_player_id)
```

**3. Add `deck_clicked` signal to `SignalBus`:**
```gdscript
signal deck_clicked(player_id: int)
```

**4. Wire `owner_player_id` via the Inspector** when placing the two deck instances in the scene (set to PLAYER_ONE for one, PLAYER_TWO for the other).

---

## Sources

- [High-level multiplayer — Godot Engine (stable)](https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html)
- [Multiplayer in Godot 4.0: Scene Replication](https://godotengine.org/article/multiplayer-in-godot-4-0-scene-replication/)
- [Multiplayer in Godot 4.0: RPC syntax, channels, ordering](https://godotengine.org/article/multiplayer-changes-godot-4-0-report-2/)
- [Godot 4 Multiplayer Overview (community gist)](https://gist.github.com/Meshiest/1274c6e2e68960a409698cf75326d4f6)
- [Understanding RPC in a turn-based multiplayer game — Godot Forum](https://forum.godotengine.org/t/understanding-rpc-implementation-in-a-turn-based-multiplayer-game/45563)
- [Multiplayer Networking in Godot 4: Authoritative Server — StraySpark](https://www.strayspark.studio/blog/godot-4-multiplayer-networking-authoritative-server)
- [Unity isLocalPlayer pattern (cross-engine reference)](https://docs.unity3d.com/2017.4/Documentation/ScriptReference/Networking.NetworkBehaviour-isLocalPlayer.html)
