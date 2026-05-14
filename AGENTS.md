# Agent Directives & Workflow Mandates

## Core Philosophy
We have moved away from "vibe coding." Every architectural decision and code implementation must be research-backed, documented with evidence, and fully understood by the user before execution.

## The Workflow

### Phase 1 — Story Definition (skip if starting from an existing Trello card)

1. Write the feature as stories in `design/stories/*.md` (temporary — never committed).
2. Present stories to the user. Wait for explicit approval before touching Trello.
3. Push approved stories to **BACKLOG** via the Trello API.
4. Delete the local story files. They live in Trello now.
5. Ask the user which story to start first.

### Phase 2 — Starting a Story

1. Move the Trello card from its current column to **DOING**.
2. Create a feature branch: `feat/<short-story-name>`.
3. Write `design/TECHNICAL_RATIONALE_<name>.md` (temporary — never committed) covering:
    - The "Why" behind each architectural choice.
    - Evidence/links to docs, articles, or standards.
    - Real-world examples of the pattern in use.
4. Walk the user through the rationale. Wait for explicit sign-off.
5. Delete the rationale file.

### Phase 3 — Implementation

1. Write the code.
2. Write GUT unit tests alongside the code (see Testing Standards below).
3. If the feature includes a utility or library, write a `<filename>.md` companion doc next to the code.
4. Present all changes with explanation. **Do NOT commit.**
5. Ask the user to run the tests and report results back.
6. Iterate until tests pass and the user is satisfied.

### Phase 4 — Completion

1. The user says "commit" or commits themselves.
2. Move the Trello card to **DONE**.

### What is never committed
- `design/stories/` — deleted after Trello sync
- `design/TECHNICAL_RATIONALE_*.md` — deleted after user sign-off

---

## Testing Standards (GUT)

All logic must have unit tests written with [GUT (Godot Unit Test)](https://github.com/bitwes/Gut).

**Setup:** Install GUT via Godot's Asset Library (Project > Asset Library > search "GUT"), then enable it in Project > Project Settings > Plugins.

**File layout:**
```
tests/
  unit/
    test_<system_name>.gd   # mirrors the source file name
```

**Rules:**
- Test files are named `test_<source_file>.gd` and extend `GutTest`.
- One `describe_*` block per public function.
- Cover: happy path, edge cases, and any values that feel like "what if someone passes 0 here."
- Do NOT mock the Godot scene tree in unit tests — if a function needs a node, it belongs in an integration test, not here.
- Agent never runs tests. Always ask the user to run them and report results.

## Goal
The User must be able to explain the codebase as if they wrote it themselves. Transparency and education are as important as the code itself.

## 🏗 Architectural Blueprint: "Entity-System"
We prioritize **Composition over Inheritance**.

### 1. Feature-Based Folders
*   Keep `script.gd` and `scene.tscn` in the same directory.
*   Group local assets (sprites, sfx) inside the feature folder if they are unique to that feature.
*   **Rule:** If you find yourself hopping between 3+ top-level folders to edit one object, the structure is wrong.

### 2. Component Pattern
*   Encapsulate logic into small, reusable nodes (e.g., `HealthComponent`, `MovementComponent`).
*   Entities (Characters, Cards) are formed by composing these components.

### 3. Signal-Based Communication
*   **Downwards:** Call methods on children.
*   **Upwards:** Emit signals to parents.
*   **Cross-System:** Use a "Signal Bus" or Global Managers (Autoloads) sparingly for system-wide events.

## 💻 Coding Standards (GDScript 2.0)
*   **Naming:** `snake_case` for files and variables. `PascalCase` for ClassNames.
*   **Static Typing:** ALWAYS use static types where possible.
    *   `var speed: float = 10.0`
    *   `func take_damage(amount: int) -> void:`
*   **Internal Variables:** Prefix private variables/methods with an underscore `_private_var`.
*   **Export Variables:** Use `@export` for inspector-visible variables, grouped logically.

## 🛠 Specific System Requirements (from Design)
*   **Grid System:** Must handle Hexagonal coordinates.
*   **Turn Economy:** Implementation of the "Tug-of-War" marker as a global system state.
*   **Card Logic:** Cards are Data Resources (`.tres`) that instantiate scenes when played.

## 🚫 The "No" List
*   No deep inheritance hierarchies (limit to 1-2 levels).
*   No hard-coded strings for paths; use exported variables or resource references.
*   No large "God Scripts" that handle multiple unrelated systems.
