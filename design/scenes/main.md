# Scene Setup Guide: main.tscn

**Location:** `world/main/main.tscn`
**Script:** `world/main/main.gd` (already written — attach it in step 1)

This guide walks you through assembling the root scene in the Godot Editor.

---

## Step 1 — Create the Root Node

1. In the **Scene** panel, click **Other Node**.
2. Search for and select **Node3D**.
3. Rename it to `Main`.
4. In the **Inspector**, click the **Script** icon (scroll icon, top-right area).
5. Click **Load** and navigate to `res://world/main/main.gd`. Select it.

---

## Step 2 — Add Camera3D

1. With `Main` selected, press **Ctrl+A** (or click the **+** icon) to add a child node.
2. Search for **Camera3D** and add it.
3. In the **Inspector**, set:
   - **Transform > Position:** `(0, 9, 7)`
   - **Transform > Rotation (degrees):** `(-52, 0, 0)`

The camera will look down at an angle — angled enough to show the fronts of future pieces, while still showing the board clearly.

---

## Step 3 — Add DirectionalLight3D

1. With `Main` selected, add another child: **DirectionalLight3D**.
2. In the **Inspector**, set:
   - **Transform > Rotation (degrees):** `(-45, -45, 0)` — this casts shadows diagonally away from the camera direction, keeping them readable.
   - **Light > Energy:** `1.0` (default is fine)
   - **Shadow > Enabled:** `true` (checkbox in the DirectionalLight3D section)

---

## Step 4 — Instance HexBoard

1. In the **FileSystem** panel, navigate to `res://world/hex_board/hex_board.tscn`.
2. **Drag** it into the **Scene** panel onto the `Main` node (drop it as a child).
   - Or: Select `Main`, then **Scene > Instantiate Child Scene** and pick `hex_board.tscn`.
3. Select the `HexBoard` node in the scene tree.
4. In the **Inspector**, find the **Hex Tile Scene** export variable.
5. Click the slot next to it and navigate to `res://world/hex_tile/hex_tile.tscn`. Assign it.

---

## Step 5 — Instance Table

1. In the **FileSystem** panel, navigate to `res://world/table/table.tscn`.
2. Drag it onto the `Main` node as a child (same method as above).
3. No additional configuration needed — the table is a flat plane mesh.

---

## Step 6 — Set as Main Scene

1. Go to **Project > Project Settings**.
2. Navigate to **Application > Run**.
3. Next to **Main Scene**, click the folder icon and select `res://world/main/main.tscn`.
4. Close the settings.

---

## Step 7 — Verify

1. Press **F5** (or the Play button) to run the project.
2. Expected result:
   - The HexBoard renders as a grid of hex tiles from an angled overhead perspective.
   - The Table (green plane) is visible beneath the board.
   - No errors in the Godot Output panel.
   - The Output panel shows: `Main scene loaded - 3D world ready`

---

## Final Scene Hierarchy

```
Node3D [Main] (main.gd)
  ├─ Camera3D          — pos (0,9,7), rot (-52°,0,0)
  ├─ DirectionalLight3D — rot (-45°,-45°,0), shadows on
  ├─ HexBoard          — hex_tile_scene assigned
  └─ Table
```
