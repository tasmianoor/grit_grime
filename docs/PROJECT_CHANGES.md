# Project change log (working tree)

This document summarizes edits **currently** in the working tree relative to **`origin/main`** (2026-05-11). Regenerate or trim after you commit.

## Summary

| Area | What changed |
|------|----------------|
| **B Street art** | **`BStreet.png`** removed from **`parallax_background_level2.tscn`**; added as a level-root **`Sprite2D`** in **`level 2/level_2.tscn`** with draw order between parallax and gameplay. |
| **Buildings** | New **`Buildings`** branch: façades (**Blue, Pink, Green, Yellow, brown, Artboard 2**). Each building is **`StaticBody2D`** + **`Sprite2D`** + **`CollisionShape2D`** with **`level 2/props/buildings/building_static_body.gd`** — collision is the **top 25%** of the sprite (roof), **`collision_layer = 16`**. |
| **BuildingBrown climb** | Child **`BuildingBrownClimbCap`** (invisible top-strip sprite). **`level 2/level.gd`** adds it to **`vine_climb`** in **`_ready`**. |
| **Road walkability** | **`level 2/tileset.tres`**: **`roadtile.png`** atlas alternatives **0–7** define **`physics_layer_0`** floor polygons so painted road behaves like other ground tiles. |
| **Draw order / gameplay props** | Foliage (grass, bushes, vines, trees, flowers) biased forward with **`z_index`**; **seeds, trash, cans, soils** set to **`z_index = 5`** and repositioned for the wider / lower Beale layout so they stay readable above grass. |
| **Moving platform** | Shared **`level/platforms/moving_platform.gd`**: **`drive_animation_with_player_velocity`** (off on Level 2 = autoplay), **`one_way_collision`** (off on Level 2 = solid floor while descending). **`level 2/level_2.tscn`**: **`move`** animation uses **three** keys at **0, 2, 4** s, **same X**, **bottom → top → bottom** with **identical first/last Y** (no loop seam); **`AnimationPlayer.callback_mode_process = 1`** (physics). |
| **Level 2 platform prefab** | **`level 2/platforms/platform.tscn`**: uses shared script, **`z_index = -1`**, decorative grass/bush/vine children (mostly hidden by default in scene). |

---

## Modified files (tracked)

### `level 2/background/parallax_background_level2.tscn`

- Deletes the **`BStreet`** **`Sprite2D`** under **`Sky`** and its **`ext_resource`** for **`BStreet.png`**, so B Street is no longer scrolled as parallax sky content.

### `level 2/level_2.tscn`

- **External resources** for **`BStreet.png`**, building textures, and **`building_static_body.gd`**.
- **TileMap** `layer_0/tile_data` — large repaint for Memphis street / road / grass layout (includes road alternatives with collision from tileset).
- **`Buildings`** node with **`StaticBody2D`** instances per building; **`BuildingBrown`** includes **`BuildingBrownClimbCap`** for climb detection.
- **`BStreet`** sprite node (placement, scale, **`z_index`**).
- **`Grass`**, **`Bushes`**, **`Trees`**, **`Flowers`**, **`Vines`** — **`z_index`** and visibility tweaks for layering vs player (**player** remains in front of mid-ground foliage).
- **Pickups / trash / cans / soils** — higher **`z_index`** and new **positions** aligned with the layout.
- **`Platforms/Platform`** and **`Platform2`**: **`drive_animation_with_player_velocity = false`**, **`one_way_collision = false`**; **`AnimationPlayer`** **`callback_mode_process = 1`**; **`move`** subresource: vertical path, **no** extra key at **0.001** s, **closed loop** on **`position`**.
- **`PlatformStatic`**, parallax instance ordering / **`z_index`** as authored for depth.

### `level 2/level.gd`

- After vine registration: **`get_node_or_null(^"Buildings/BuildingBrown/BuildingBrownClimbCap")`** → **`add_to_group(&"vine_climb")`** when present.

### `level 2/tileset.tres`

- **`roadtile.png`** source: per-tile-alternative **`physics_layer_0`** polygons (trapezoid-style shapes matching road orientation), same collision layer usage as other floor tiles in this tileset.

### `level 2/platforms/platform.tscn`

- **`AnimatableBody2D`** uses **`res://level/platforms/moving_platform.gd`** (shared with Level 1 prefab path).
- Body **`z_index = -1`**; **`CollisionShape2D`** default **`one_way_collision = true`** (overridden per level instance via script export).
- Optional decorative **`Sprite2D`** children with **`wind_sway.tres`** material reference.

### `level/platforms/moving_platform.gd`

- **`@export var drive_animation_with_player_velocity`** — when **false**, **`speed_scale = 1.0`** each physics frame (animation plays on its own).
- **`@export var one_way_collision`** — applied to child **`CollisionShape2D`** in **`_ready`**.

---

## Untracked paths (add when committing)

| Path | Role |
|------|------|
| **`level 2/props/buildings/`** | **`building_static_body.gd`** (+ **`.uid`**), building PNGs (**`1 Blue.png`** … **`5 brown.png`**), **`Artboard 2.png`**, and **`.import`** sidecars. |
| **`level 2/BStreet copy.png`** (+ **`.import`**) | Appears to be a duplicate asset; **remove or rename** before commit if unintended. |

---

## Technical notes (platform loop)

For a looping **`position`** track on an **`AnimatableBody2D`**:

1. **First and last keyframe values must match** or the frame after `length` will **teleport** (felt as jitter at the “bottom” of the path).
2. Avoid **very short** intermediate keys (e.g. **0.001** s) — they create huge **effective velocity** spikes.
3. Prefer **`AnimationPlayer.callback_mode_process = 1`** (**physics**) so body motion stays in step with **`CharacterBody2D`** floor snaps.

---

## How to refresh this document

```bash
git status
git diff --stat
git diff
```

Merge or replace sections after commits so this file stays a faithful “uncommitted delta” snapshot.
