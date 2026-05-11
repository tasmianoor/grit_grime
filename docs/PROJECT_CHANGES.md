# Project change log (working tree)

This document summarizes edits present in the repository working tree relative to `origin/main` (uncommitted changes and new files). Regenerate or trim it after you commit.

## Summary

| Area | What changed |
|------|----------------|
| **Display** | **`window/stretch/aspect="keep"`** in **`project.godot`**: uniform scale, fixed **16:9** logical viewport (**960×540**), letterbox/pillarbox on non–16:9 windows (replaces **`expand`**). |
| **Map UI** | New illustrated map art, UV-based button placement, styled labels, removed title bar and top shade, global GUI theme hook; **`Level2Button`** is the visible **Beale Street** card (same style as other hubs); **`BealeStreetButton`** removed |
| **Level 2 routing** | `game_level_2.tscn` loads `level 2/level_2.tscn`; that scene uses `level 2/` assets, Memphis road tiles, B Street parallax, hidden duplicate foliage where tiles carry the look |
| **Level 1 / shared level scripts** | Higher camera bottom limit, null-safe camera lookup |
| **Player** | Camera follow smoothing, lower framing offset, animation clips no longer drive invalid `Sprite2D:frame` keys |

---

## Modified files

### `project.godot`

- Sets `[gui] theme/custom` to `res://gui/theme.tres` so map buttons and other UI pick up the shared theme (e.g. Jersey25 where configured in the theme).
- **`[display]`** **`window/stretch/aspect`**: **`keep`** — preserves **16:9** content aspect with uniform scaling (letterboxing/pillarboxing when the window aspect differs). Not **`expand`**.

### `map/map.tscn` and `map/map.gd`

- **Removed:** `TopShade` overlay and **Map** title `Label`.
- **Hub buttons:** **Memphis Riverfront** (`LevelButton`), **Beale Street** (**`Level2Button`** → **`game_level_2.tscn`**), and **Memphis Aquifer** (`MemphisAquiferButton`) share the same card **`StyleBoxFlat`** (fill, border, rounded corners, shadow). The separate **`BealeStreetButton`** node was removed to avoid a duplicate landmark control.
- **`map.gd`:** Constants `RIVERFRONT_MAP_UV`, `BEALE_MAP_UV`, `AQUIFER_MAP_UV` (normalized 0–1 on the texture). Export `auto_position_buttons` (default true). On resize and after first frame, `_layout_map_buttons()` places **Riverfront**, **Level 2 (Beale)**, and **Aquifer** using math that matches `TextureRect` **KEEP_ASPECT_COVERED** cropping. `FontVariation` adds ~5% glyph spacing on those three; hover raises font outline from 1px to 2px.
- **Assets:** `InteractiveMap.png` replaced (larger file; new `uid` in `.import`).

### `game_level_2.tscn`

- Level scene path: `res://level/level_2.tscn` → `res://level 2/level_2.tscn`.
- Player spawn: `y` **544** → **546** (aligned with Level 1 spawn height).

### `level 2/level_2.tscn`

- All primary resources point under `res://level 2/` (tileset, platforms, parallax, props, trash art). Script: `level 2/level.gd`. Cypress river floor script remains `res://level/tilemap_cypress_river_floor.gd` (shared).
- **Parallax:** `parallax_background_level2.tscn` (B Street art) instead of the Level 1 parallax scene.
- **TileMap:** Uses `level 2/tileset.tres`; node position offset `(-3, -74)`; layer data extended with road (`source`/atlas index **22**) and grass (`0` with alternative flags) where the Memphis street layout was painted; `tilemap_cypress_river_floor.gd` attached after tile data (same behavior, editor order).
- **Decor:** Many grass, tree, bush, and rock sprites set **`visible = false`** where the tile layer now carries the environment read.

### `level 2/level.gd`

- `LIMIT_BOTTOM`: **690** → **1050** so the camera can scroll lower with the layout.
- Camera limits applied via `get_node_or_null(^"Camera") as Camera2D` with a null guard (avoids errors if the node is missing).

### `level/level_2.tscn`

- Scene **uid** changed (Godot re-save).
- External resources repointed from `res://level/...` to `res://level 2/...` for duplicated Level 2 content (tileset, platforms, background, props, trash), matching the split so this scene file stays a sibling variant that uses the same Level 2 asset folder.
- Soil textures still reference `res://level/props/Willow_soil.png` and `Cypress_soil.png`.
- **TileMap:** `script = ExtResource("40")` moved after `layer_0/tile_data` (editor ordering only).
- **Trash nodes:** `position` before `trash_texture` (ordering).
- **Markers:** `HeronLandingSpot` and `KingfisherLandingSpot` gained `unique_id` metadata.

### `level/level.gd`

- Same `LIMIT_BOTTOM` raise and null-safe `Camera2D` application as `level 2/level.gd`.

### `player/player.gd`

- In `_ready()`, if `camera` is non-null: `enabled = true`, `process_callback = CAMERA2D_PROCESS_PHYSICS`, `position_smoothing_enabled = true`, `position_smoothing_speed = 7.0`.

### `player/player.tscn`

- **Camera2D** `position.y`: **-28** → **-120** (character sits lower in the frame).
- **Animations** `falling`, `falling_weapon`, `jumping`, `jumping_weapon`: removed **value** tracks targeting `Sprite2D:frame` (they forced frame 4 while the sprite uses a single-column HD strip, which caused out-of-bounds errors). Added `loop_mode = 1` and explicit `resource_name` where applicable on those clips.

---

## Untracked files (add when committing)

| Path | Role |
|------|------|
| `level 2/roadtile.png` (+ `.import`) | Road surface atlas texture for the Level 2 tileset |
| `level 2/roadtile.webp.import` | Import sidecar if a WebP variant was probed |
| `level 2/BStreet.png` (+ `.import`) | B Street skyline / street art for parallax |
| `level 2/background/parallax_background_level2.tscn` | Parallax rig referencing B Street (used by `level 2/level_2.tscn`) |

---

## Already on `main` (no local diff) — Level 2 tileset

`level 2/tileset.tres` matches HEAD. It includes atlases for `tiles.webp`, `rivertile.png`, and **`roadtile.png`**. The road atlas tile **0:0** defines **`physics_layer_0`** floor polygons for alternatives **0–7** (same trapezoid pattern as other walkable 64×64 ground tiles), so road tiles collide as floor.

---

## How to refresh this document

```bash
git status
git diff --stat
git diff
```

Then merge the above sections with any new files or revert entries that were committed.
