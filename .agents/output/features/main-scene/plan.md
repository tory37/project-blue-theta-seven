# Plan: Main Scene (Ticket 06)

**Goal:** Create the root 3D scene (`world/main/`) that wires together the Camera, DirectionalLight, HexBoard, and Table into a runnable game entry point.

## Phases

### Phase 1 — Write main.gd (agent writes)

- Create `world/main/main.gd`
- Extends `Node3D`
- Minimal `_ready()` that logs "Main scene loaded"

**Tests:** No unit-testable logic; verification is the scene running without errors.

### Phase 2 — Assemble main.tscn (user does in Godot Editor)

Per project mandate, scene assembly is done by the user in the Godot Editor, guided by `design/scenes/main.md`.

Steps (user follows guide):
1. Create `Node3D` root, attach `main.gd`
2. Add `Camera3D` child — position `(0, 9, 7)`, rotation `(-52°, 0, 0)`
3. Add `DirectionalLight3D` child — rotate to cast shadows away from camera
4. Instance `hex_board.tscn` as child — assign `hex_tile_scene` export in Inspector
5. Instance `table.tscn` as child
6. Set scene as Project > Project Settings > Application > Run > Main Scene
7. Run and verify: board renders, no errors

## Files

| File | Who creates |
|------|-------------|
| `world/main/main.gd` | Agent |
| `world/main/main.tscn` | User (Godot Editor) |
| `design/scenes/main.md` | Agent (scene setup guide) |

## Commit Message (after both phases complete)

```
feat: create main scene with camera, lights, and world assembly
```
