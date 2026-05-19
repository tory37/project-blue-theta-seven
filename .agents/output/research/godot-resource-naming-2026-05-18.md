# Godot 4: Resource Script Naming Conventions

**Question:** Do people suffix Resource class scripts with `_resource`?

---

## Verdict: No. Use `_data` as the disambiguating suffix.

The `_resource` suffix is not idiomatic in the Godot community. It describes the *base type* (Resource), not *what the data is*. The widely-used pattern is a descriptive suffix — most commonly `_data`.

---

## Evidence

### Official Style Guide
[Godot GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) specifies:
- **File names:** `snake_case` (e.g., `card_data.gd`)
- **`class_name`:** `PascalCase` (e.g., `class_name CardData`)
- No mention of `_resource` as a convention.

### GDQuest Guidelines
[GDQuest's GDScript Guidelines](https://gdquest.gitbook.io/gdquests-guidelines/godot-gdscript-guidelines) — one of the most-cited community style guides — uses `CardData`, `EnemyData`, etc. for Resource subclasses.

### Real-World Card Game Codebases

| Project | Pattern Used | Example |
|---|---|---|
| [db0/godot-card-game-framework](https://github.com/db0/godot-card-game-framework) | Simple descriptive names | `Card`, `Pile`, `Hand` |
| [chun92/card-framework](https://github.com/chun92/card-framework) | Role-based names | `CardFactory`, `CardContainer` |
| [Slashskill Deckbuilder Tutorial](https://www.slashskill.com/how-to-build-a-card-game-in-godot-4-deckbuilder-systems-from-scratch/) | `_data` / descriptive suffix | `class_name CardEffect extends Resource` |

The pattern `class_name DeckData extends Resource` with file `deck_data.gd` matches what real projects do.

---

## Applied to This Project

| File | class_name | Role |
|---|---|---|
| `src/deck/deck_data.gd` | `DeckData` | Resource subclass — holds array of CardData |
| `src/deck/deck_view.gd` | *(none needed)* | Scene script — visual prop, emits `clicked` |

**Why no `class_name` on `deck_view.gd`?** It's never instantiated by name from another script — the scene handles it. Skipping `class_name` avoids the naming collision entirely.

---

## Sources
- [GDScript Style Guide — Godot Engine (stable)](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [GDQuest GDScript Guidelines](https://gdquest.gitbook.io/gdquests-guidelines/godot-gdscript-guidelines)
- [db0/godot-card-game-framework](https://github.com/db0/godot-card-game-framework)
- [chun92/card-framework](https://github.com/chun92/card-framework)
- [How to Build a Card Game in Godot 4 — Slashskill](https://www.slashskill.com/how-to-build-a-card-game-in-godot-4-deckbuilder-systems-from-scratch/)
