# Agent Directives & Workflow Mandates

## Core Philosophy
We have moved away from "vibe coding." Every architectural decision and code implementation must be research-backed, documented with evidence, and fully understood by the user before execution.

## The Workflow

### When a task does NOT come from an existing plan or ticket:
1. **Story Mapping:** Write the feature as stories in `design/stories/*.md` (these are **temporary, never committed**).
2. **User Approval:** Present the stories to the user. Wait for explicit approval.
3. **Push to Trello:** Once approved, write the stories to the backlog via the `djt-trello` skill.
4. **Delete local story files.** They live in Trello now — not in the repo.
5. **Ask the user** if they want to move on to the first story before proceeding.

### For every feature/story (with or without an incoming ticket):
1. **Technical Plan:** Write a `design/TECHNICAL_RATIONALE_*.md` (also **temporary, never committed**) covering:
    - The "Why" behind each architectural choice.
    - Evidence/links to docs, articles, or industry standards.
    - Real-world examples of the pattern in use.
2. **User Verification:** Walk the user through the plan. Implementation does NOT start until the user explicitly approves and says they understand.
3. **Write the code.** Present changes with explanation. **Do NOT commit.** The user must either say "commit" explicitly or commit themselves.

### What is never committed
- `design/stories/` — deleted after Trello sync
- `design/TECHNICAL_RATIONALE_*.md` — deleted after user review and approval

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
