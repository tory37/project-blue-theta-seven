# Agent Directives & Workflow Mandates

## Core Philosophy
We have moved away from "vibe coding." Every architectural decision and code implementation must be research-backed, documented with evidence, and fully understood by the user before execution.

## The Workflow
1. **Research & Proposal:** Before any implementation, the agent provides a technical design write-up (e.g., in `design/TECHNICAL_RATIONALE_*.md`). This must include:
    - The "Why" behind the choice.
    - Evidence/links to articles, documentation, or industry standards.
    - Real-world examples of the pattern in use.
2. **Story Mapping:** Once a proposal is approved, it is broken down into **Stories** (e.g., in `design/stories/*.md`).
3. **Ticket Management:** Stories are written to the `BACKLOG` using the `djt-trello` skill.
4. **Collaborative Review:** Code is presented with a detailed explanation. Implementation only proceeds once both Agent and User feel confident and educated on the logic.

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
