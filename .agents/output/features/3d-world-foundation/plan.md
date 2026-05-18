# Plan: 3D World Foundation

## Feature Summary

Convert the project from 2D hex math to a 3D world. This is a pure foundation story:
build the 3D board scene, hex tiles, camera, and table. Card drag and entities are
out of scope — those are their own subsequent stories.

---

## Scope

### In scope

- Update `HexUtils` to output 3D world positions; remove 2D pixel math
- Update unit tests to cover 3D functions
- `HexTile` scene: 3D placeholder hexagonal prism with collision and hover signals
- `HexBoard` scene: spawns `HexTile` nodes from axial coords in 3D space
- `Table` scene: flat plane beneath the board ("the table")
- `Main` scene: root Node3D with Camera3D at ~70° angle, HexBoard, Table
- Set `Main` as the project's main scene in `project.godot`

### Out of scope

- Card drag from 2D hand to 3D tiles (subsequent story)
- Entity spawning on tiles (subsequent story)
- Tile state tracking in `GameState` (subsequent story)
- Merchant UI, AP Tracker UI, combat (subsequent stories)

---

## Architectural Rationale

### HexUtils: XZ-plane convention with dual orientation

Godot 3D uses Y-up. The board lives in the XZ plane (Y=0). The math mirrors the
existing 2D axial system exactly — the q/r basis vectors map to X and Z instead
of X and Y. This lets us keep `axial_round`, `get_neighbors`, and `get_distance`
completely unchanged.

Both orientations are supported for playtesting. A `HexOrientation` enum lives in
`HexUtils`; `HexBoard` exposes it as an `@export var` so it can be toggled in the
Godot inspector without touching code.

**Pointy-top** (hex points at top/bottom, "diamond grid"):
```
axial_to_world_pointy_top:
  world.x = size * (sqrt(3) * q + sqrt(3)/2 * r)
  world.y = 0
  world.z = size * (3/2 * r)

world_to_axial_pointy_top (inverse):
  q_float = (sqrt(3)/3 * world.x  -  1/3 * world.z) / size
  r_float = (2/3 * world.z) / size
  → axial_round(q_float, r_float)
```

**Flat-top** (hex points at left/right, "column grid"):
```
axial_to_world_flat_top:
  world.x = size * (3/2 * q)
  world.y = 0
  world.z = size * (sqrt(3)/2 * q + sqrt(3) * r)

world_to_axial_flat_top (inverse):
  q_float = (2/3 * world.x) / size
  r_float = (-1/3 * world.x + sqrt(3)/3 * world.z) / size
  → axial_round(q_float, r_float)
```

Generic dispatchers delegate to the named variants:
```
axial_to_world(q, r, size, orientation) -> Vector3
world_to_axial(point, size, orientation) -> Vector2i
```

### HexTile: StaticBody3D with 6-segment CylinderMesh

`CylinderMesh` with `radial_segments = 6` is a hexagonal prism — no custom mesh
needed for placeholder art. The `StaticBody3D` root means it can receive mouse
input via `InputEventMouseButton` from the viewport once we add a `CollisionShape3D`.

Two visual states driven by material swaps:

- `default`: grey/muted
- `hovered`: subtle highlight

### HexBoard: Procedural generation

`HexBoard` stores a `Dictionary` mapping `Vector2i` (axial) → `HexTile` node.
The `generate(radius)` method fills a ring of that radius using HexUtils neighbor
logic. The size constant (`HEX_SIZE`) lives here as an `@export var` so it can be
tuned in the inspector.

### Camera: Fixed angled perspective

`Camera3D` parented directly to `Main`. Position: above the back edge of the board,
rotation_degrees.x ≈ −65 to −70 so the player sees the faces of their pieces and a
bit of the top of the board. No camera controller for MVP — fixed is fine.

---

## Files Changed

| File | Action |
|---|---|
| `common/hex_utils.gd` | Edit — replace 2D pixel functions with 3D world functions |
| `tests/unit/test_hex_utils.gd` | Edit — remove old 2D tests, add 3D tests |
| `project.godot` | Edit — set main scene |

## Files Created

| File | Purpose |
|---|---|
| `world/hex_tile/hex_tile.gd` | HexTile logic + signals |
| `world/hex_tile/hex_tile.tscn` | HexTile scene (StaticBody3D → Mesh + Collision) |
| `world/hex_board/hex_board.gd` | Generates and tracks tiles |
| `world/hex_board/hex_board.tscn` | HexBoard scene (Node3D) |
| `world/table/table.tscn` | Flat table plane |
| `world/main/main.gd` | Main scene script (camera, board setup) |
| `world/main/main.tscn` | Root scene |

---

## Implementation Steps

### 1. Tests first — update `test_hex_utils.gd`

Remove all `test_axial_to_pixel_*` and `test_pixel_to_axial_*` tests.

Add:

- `test_axial_to_world_origin_is_zero` — `axial_to_world(0, 0, SIZE)` == `Vector3.ZERO`
- `test_axial_to_world_q_axis_moves_along_x` — q=1,r=0 produces correct x, y=0, z=0
- `test_axial_to_world_r_axis_moves_along_xz` — q=0,r=1 produces correct x and z
- `test_axial_to_world_scales_with_size`
- `test_world_to_axial_origin_is_zero`
- `test_world_to_axial_round_trips` — for coords `[(2,-1), (-3,2), (0,4), (1,1)]`
- `test_world_to_axial_snaps_nearby_point_to_nearest_hex`

`axial_round`, `get_neighbors`, `get_distance` tests are unchanged — keep them.

### 2. Update `common/hex_utils.gd`

Remove:

- `Q_BASIS_POINTY_TOP`, `R_BASIS_POINTY_TOP`
- `Q_INV_BASIS_POINTY_TOP`, `R_INV_BASIS_POINTY_TOP`
- `axial_to_pixel_pointy_top`
- `pixel_to_axial_pointy_top`

Add:

```gdscript
enum HexOrientation { POINTY_TOP, FLAT_TOP }

# Named pointy-top variants
static func axial_to_world_pointy_top(q: int, r: int, size: float) -> Vector3
static func world_to_axial_pointy_top(point: Vector3, size: float) -> Vector2i

# Named flat-top variants
static func axial_to_world_flat_top(q: int, r: int, size: float) -> Vector3
static func world_to_axial_flat_top(point: Vector3, size: float) -> Vector2i

# Generic dispatchers
static func axial_to_world(q: int, r: int, size: float, orientation: HexOrientation) -> Vector3
static func world_to_axial(point: Vector3, size: float, orientation: HexOrientation) -> Vector2i
```

### 3. Create `world/hex_tile/hex_tile.gd` + `hex_tile.tscn`

Scene structure:

```
StaticBody3D (hex_tile.gd)
  └─ MeshInstance3D       ← CylinderMesh, radial_segments=6, height=0.2
  └─ CollisionShape3D     ← CylinderShape3D matching mesh
```

Script:

- `@export var axial_coord: Vector2i`
- `signal tile_clicked(axial: Vector2i)`
- `signal tile_hovered(axial: Vector2i)`
- `func set_highlighted(on: bool)` — swaps between default and hover material
- `_input_event(...)` handler emits `tile_clicked`
- `_mouse_enter()` / `_mouse_exit()` emit `tile_hovered`, drive highlight

### 4. Create `world/hex_board/hex_board.gd` + `hex_board.tscn`

Scene structure:

```
Node3D (hex_board.gd)
```

Script:

- `@export var hex_size: float = 1.0`
- `@export var board_radius: int = 3`
- `@export var orientation: HexUtils.HexOrientation = HexUtils.HexOrientation.POINTY_TOP`
- `@export var hex_tile_scene: PackedScene`
- `var _tiles: Dictionary = {}` — maps `Vector2i` → `HexTile`
- `func generate() -> void` — called in `_ready`, spawns tiles
- `func get_tile(axial: Vector2i) -> HexTile` — returns node or null
- Generation loop: use `axial_ring` pattern via `HexUtils.get_neighbors` traversal
  for all cells within `board_radius`

Hex ring fill algorithm (all cells within radius):

```gdscript
for q in range(-board_radius, board_radius + 1):
    for r in range(max(-board_radius, -q - board_radius), min(board_radius, -q + board_radius) + 1):
        _spawn_tile(q, r)
```

### 5. Create `world/table/table.tscn`

Scene structure:

```
StaticBody3D
  └─ MeshInstance3D  ← PlaneMesh, size=24x24, simple flat StandardMaterial3D (dark green/brown)
  └─ CollisionShape3D ← BoxShape3D (thin, large)
```

No script needed for MVP.

### 6. Create `world/main/main.gd` + `world/main/main.tscn`

Scene structure:

```
Node3D (main.gd)
  └─ Camera3D
  └─ DirectionalLight3D
  └─ HexBoard (instance of hex_board.tscn)
  └─ Table (instance of table.tscn)
```

Camera3D setup:

- `position = Vector3(0, 9, 7)`
- `rotation_degrees = Vector3(-52, 0, 0)`
  (angled view, seeing fronts of future pieces and a good portion of the board)

Light:

- `DirectionalLight3D`, rotation to cast shadows at a readable angle

Script:

- Minimal — just `_ready` to verify scene loads.

### 7. Update `project.godot`

Set `config/main_scene` to `"res://world/main/main.tscn"`.

---

## GUT Tests Summary

### Modified: `tests/unit/test_hex_utils.gd`

Removed tests (2D):

- `test_axial_to_pixel_*` (4 tests)
- `test_pixel_to_axial_*` (3 tests)

New tests (3D, pointy-top):

- `test_axial_to_world_pointy_top_origin_is_zero`
- `test_axial_to_world_pointy_top_q_axis`
- `test_axial_to_world_pointy_top_r_axis`
- `test_axial_to_world_pointy_top_round_trip`

New tests (3D, flat-top):

- `test_axial_to_world_flat_top_origin_is_zero`
- `test_axial_to_world_flat_top_q_axis`
- `test_axial_to_world_flat_top_r_axis`
- `test_axial_to_world_flat_top_round_trip`

New tests (dispatcher):

- `test_axial_to_world_dispatcher_pointy_top` — matches named variant output
- `test_axial_to_world_dispatcher_flat_top` — matches named variant output

Unchanged:

- `test_axial_round_*` (3 tests)
- `test_get_neighbors_*` (3 tests)
- `test_get_distance_*` (4 tests)

---

## Doer Test Plan

See `doer-test-plan.md` alongside this file.

---

## What's Next (not in this story)

1. **Card Hand UI + Drag to Board** — 2D Control nodes in a `CanvasLayer`, drag with
   `Viewport.get_mouse_position()` + raycast to `HexBoard` collision
2. **Entity Scene** — Capsule placeholder on tiles, driven by `GameState`
3. **Tile State in GameState** — `placed_tiles: Dictionary` tracking which axial
   coords have tiles and which have entities
