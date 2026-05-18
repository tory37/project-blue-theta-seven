# 3D World Foundation

**Last Updated:** 2026-05-17
**Status:** Awaiting Approval — Plan written, no code written yet
**Branch:** none yet (to be created: `feat/3d-world-foundation`)
**PR:** none

## Summary

Converting the project from a 2D hex coordinate system to a full 3D world using Godot 4.6 Forward Plus. The board lives in the XZ plane (Y-up world). This is a pure foundation story — board, tiles, camera, and table only. Card drag, entities, and game state wiring are subsequent stories.

## Implementation Complete

- MVP plan reviewed (`design/MVP_PLAN.md`)
- Codebase explored: `common/hex_utils.gd`, `systems/game_state.gd`, `autoload/signal_bus.gd`, `tests/unit/test_hex_utils.gd`, design docs
- Implementation plan written: `.agents/output/features/3d-world-foundation/plan.md`
- Doer test plan written: `.agents/output/features/3d-world-foundation/doer-test-plan.md`

## Pending

- User approval of the plan
- Create branch `feat/3d-world-foundation`
- Write failing GUT tests (Step 1 of plan)
- Update `common/hex_utils.gd` to 3D (Step 2)
- Create `world/hex_tile/` scene + script (Step 3)
- Create `world/hex_board/` scene + script (Step 4)
- Create `world/table/table.tscn` (Step 5)
- Create `world/main/` scene + script (Step 6)
- Update `project.godot` with main scene (Step 7)
- User runs GUT tests and Doer Test Plan; reports results

## Technical Notes

### HexUtils 3D math
Board is in XZ plane. Axial → world:
```
world.x = size * (sqrt(3) * q  +  sqrt(3)/2 * r)
world.y = 0
world.z = size * (3/2 * r)
```
Inverse (world → axial):
```
q_float = (sqrt(3)/3 * world.x  -  1/3 * world.z) / size
r_float = (2/3 * world.z) / size
→ axial_round(q_float, r_float)
```
`axial_round`, `get_neighbors`, `get_distance` are coordinate-space only — unchanged.

### HexTile placeholder mesh
`CylinderMesh` with `radial_segments = 6` naturally forms a hexagonal prism. No custom mesh needed.

### Camera starting values
`position = Vector3(0, 9, 7)`, `rotation_degrees = Vector3(-52, 0, 0)`.
User noted "~70 degree angle" from horizontal. -52° on X is actually ~52° below horizontal.
If it feels too steep, tune up toward -40°; if too flat, go toward -65°. Easy inspector tweak after first run.

### 2D elements (future stories)
- Card hand = `CanvasLayer` with 2D `Control` nodes
- Drag to board = `Viewport.get_mouse_position()` + raycast to `HexBoard` collision
- Grid outline (empty slots) = thin flat mesh on table surface

### Board radius
Default `board_radius = 3` as `@export var` on HexBoard — 37 tiles, easily changed in inspector.

### Testing
GUT is set up in the project. Tests live in `tests/unit/`. Agent does NOT run tests — always ask the user to run them and report back.

### Approved design choices from user
- 3D hex tiles (placeholder cylinder geometry)
- Characters and objects on tiles = 3D
- UI (AP tracker, cards, merchant) = 2D CanvasLayer overlay
- Grid/placement zone = 2D, flat-projected on table
- Table = 2D texture under the grid so there's no abyss visible
- HexUtils goes fully 3D — remove all 2D pixel math

## Next Steps

1. Read `.agents/output/features/3d-world-foundation/plan.md` to reload context.
2. Ask the user to confirm the plan (if not already confirmed in this session).
3. Create branch: `git checkout -b feat/3d-world-foundation`
4. Write failing tests in `tests/unit/test_hex_utils.gd` (replace 2D tests with 3D equivalents).
5. Ask user to run GUT and confirm the new 3D tests fail (expected at this point).
6. Implement `common/hex_utils.gd` changes.
7. Ask user to run GUT again — 3D tests should pass now.
8. Continue through Steps 3–7 of the plan.
