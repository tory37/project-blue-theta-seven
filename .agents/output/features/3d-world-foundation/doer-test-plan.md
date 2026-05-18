# Doer Test Plan: 3D World Foundation

## Prerequisites
- Godot 4.6 installed
- Project opened in editor

---

## Step 1: GUT Unit Tests Pass

1. Open the Godot editor.
2. In the Godot editor toolbar, navigate to **Project > Open Scene** — open `addons/gut/GutScene.tscn`.
3. Press **F6** (Run Current Scene) or use the GUT panel to run all tests.
4. **Checkpoint:** All `test_hex_utils.gd` tests pass. Specifically:
   - `test_axial_to_world_*` tests are green.
   - `test_world_to_axial_*` tests are green (including round-trip).
   - `test_axial_round_*`, `test_get_neighbors_*`, `test_get_distance_*` are still green.
   - No `test_axial_to_pixel_*` or `test_pixel_to_axial_*` tests exist anymore.

---

## Step 2: Main Scene Runs Without Errors

1. In the Godot editor, press **F5** (Run Project) or click the Play button.
2. **Checkpoint:** The project launches without errors in the Output panel.
3. **Checkpoint:** A window appears showing a 3D scene — you should see a flat dark surface (the table) with a hexagonal grid of tile meshes on top.

---

## Step 3: Hex Board Is Visible and Correctly Laid Out

1. With the game running, observe the scene.
2. **Checkpoint:** There is a visible grid of hexagonal prism tiles arranged in a ring pattern.
3. **Checkpoint:** The tiles are arranged in a roughly circular formation (all cells within radius 3).
4. **Checkpoint:** No tile overlaps with another; gaps between tiles are visually uniform.
5. **Checkpoint:** The camera is positioned at an angle (~70° from horizontal) — you should see both the tops of tiles and a bit of the "front face" perspective. The view is NOT perfectly top-down.

---

## Step 4: Table Plane Is Visible Beneath Tiles

1. With the game running, observe the area around the hex board.
2. **Checkpoint:** There is a flat colored plane (dark green or brown) extending beyond the tile grid.
3. **Checkpoint:** No gaps or "abyss" visible — the table fills the background.
4. **Checkpoint:** Tiles sit visually on top of the table plane.

---

## Step 5: Tile Hover Highlight Works

1. With the game running, move the mouse cursor over individual hex tiles.
2. **Checkpoint:** When the cursor enters a tile, the tile changes color/brightness (hover highlight activates).
3. **Checkpoint:** When the cursor exits a tile, the tile returns to its default color.
4. **Checkpoint:** Only one tile is highlighted at a time.

---

## Step 6: No Console Errors

1. With the game running, perform all steps above.
2. **Checkpoint:** The Godot Output panel shows no red errors or script errors.
3. **Checkpoint:** No "null" or "unset variable" warnings during hover interaction.
