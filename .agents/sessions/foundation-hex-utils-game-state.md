# Foundation: HexUtils, GameState, ResourceDisplay

**Last Updated:** 2026-05-13
**Status:** In Progress
**Branch:** `feat/foundation-hex-utils-game-state`
**PR:** None yet

## Summary

Three foundational systems were stubbed out by a previous agent without going through the proper workflow. We did damage control (rewrote git history to remove plan files from master, set up gitignore correctly), created Trello cards for all three stories in DOING, and have been working through the HexUtils story properly — technical rationale written and reviewed, GUT test suite written, companion doc (`common/hex_utils.md`) written. GUT is installed but not yet successfully running tests due to a directory config issue.

## Implementation Complete

- `common/hex_utils.gd` — HexUtils static utility (axial coords, pointy-top, pixel conversion, neighbors, distance)
- `common/hex_utils.md` — contributor-facing doc explaining coordinate system choice and full API
- `tests/unit/test_hex_utils.gd` — 16 GUT unit tests covering all four public functions
- `systems/game_state.gd` — GameState autoload stub (tug-of-war marker, AP/Coins, turn switching)
- `ui/resource_display.gd` — ResourceDisplay UI stub (signal-driven AP/Coins display)
- `.gitignore` — now excludes `.godot/`, `addons/gut/`, `design/stories/`, `design/TECHNICAL_RATIONALE_*.md`
- `AGENTS.md` — updated with full 4-phase workflow (Story → DOING → Technical Plan → Code+Tests → Commit → DONE) and GUT testing standards
- `.gutconfig.json` — GUT config pointing at `res://tests` (not yet confirmed working)
- Trello cards created in DOING for all three stories (HexUtils, GameState, ResourceDisplay)

## Pending

- [ ] Fix GUT test runner — it's not picking up the test directory (`.gutconfig.json` may not be the right mechanism; need to verify via GUT panel UI or runner scene)
- [ ] Run HexUtils tests and confirm all 16 pass
- [ ] Move HexUtils Trello card to DONE once tests pass and user signs off
- [ ] Technical rationale + tests for GameState (`systems/game_state.gd`)
- [ ] Technical rationale + tests for ResourceDisplay (`ui/resource_display.gd`)
- [ ] Scene file for ResourceDisplay (`resource_display.tscn`) — the GDScript references nodes that don't exist yet
- [ ] Merge `feat/foundation-hex-utils-game-state` to master once all three stories are complete

## Technical Notes

- **Coordinate system:** Axial (q, r) with pointy-top orientation. `s = -q - r` always — never stored, reconstructed inline when needed. All HexUtils methods are `static`.
- **axial_round:** Must round in cube space (all three axes) and recompute the axis with the largest error. Naive rounding of q and r independently breaks the `q+r+s=0` constraint.
- **GUT version:** Installed via Godot Asset Library. 248 files in `addons/gut/` — gitignored. Any new dev must reinstall via Asset Library before running tests.
- **`.gutconfig.json`** was added to project root but GUT panel still showed "no directories set" — unclear if the config file format is correct for this version of GUT or if it needs to be wired differently. Worth checking GUT docs or trying the panel UI settings directly.
- **`.godot/` was previously committed** — untracked this session via `git rm --cached`.
- **Workflow rule:** Never auto-commit. User must say "commit" explicitly. Planning artifacts (`design/stories/`, `design/TECHNICAL_RATIONALE_*.md`) are always deleted after use, never committed.

## Next Steps

1. Open Godot, go to the GUT bottom panel.
2. Find the directory/settings input and manually add `res://tests` — confirm tests are found.
3. Run all tests, report results back to agent.
4. Once 16 tests pass, agent moves HexUtils Trello card to DONE.
5. Start GameState technical rationale review (agent writes `design/TECHNICAL_RATIONALE_game_state.md`, walks through it).
6. Write GUT tests for GameState.
7. Repeat for ResourceDisplay.
8. Merge branch to master.
