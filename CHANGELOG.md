# Changelog

This document records simplifications applied to the original Godot 2D platformer demo: removal of combat, enemies, and collectibles.

## Summary

| Area | Removed |
|------|---------|
| Combat | Shooting, bullets, gun node, shoot input actions |
| Enemies | All enemy instances in the level, enemy scene and script |
| Collectibles | All coin pickups, coin counter UI, coin collection flow |
| Display | Viewport **800×480** → **960×540** (16:9); window override **1600×960** → **1920×1080**; stretch **`aspect=expand`** + **`scale_mode=fractional`** (fill window, no black bars; may crop on non–16:9 displays) |

The game remains a playable platformer: movement, jump/double-jump, moving platforms, pause menu, single-player and split-screen entry scenes, camera limits, and audio/visuals for the player and level.

**Later additions** (see sections below): soil **growth placeholder** + tree labels; **willow seed 2** gated drop; **trash / trash can** (sprite-based trash, seven pickups, carry sizing, can completion without global trash wipe); **manual** seed & trash pickup (**E** / **`drop_seed*`**); shared **theme** font + **text outline**; **`level.gd`** orchestration for seed 2; **2D `z_index`** so the player draws in front of the trash can; **level / tilemap editor pass** (wider map, décor visibility, **`FinishLine`** marker, **`level_2.tscn`**) under [Level and tileset revisions](#level-and-tileset-revisions-editor); **single-player spawn** and **wider horizontal camera limits** under [Single-player spawn and camera scroll limits](#single-player-spawn-and-camera-scroll-limits); **Lawrence** hero, **Memphis** music and skyline, and **single-player scene cleanup** under [Lawrence hero, Memphis pass, and music (2026-04-18)](#lawrence-hero-memphis-pass-and-music-2026-04-18); follow-up **Lawrence animation timing/jump sources**, **single-player transform fix**, and **hidden platform collision gating** under [Lawrence animation follow-up and hidden platform collisions (2026-04-19)](#lawrence-animation-follow-up-and-hidden-platform-collisions-2026-04-19); **trash art, carry scale, Memphis loop, decor vines, and climb placeholders** under [Trash art, carry scale, Memphis loop, and decor vines (2026-04-19)](#trash-art-carry-scale-memphis-loop-and-decor-vines-2026-04-19); **Grass/Vine climb**, **`move_up` / `move_down`**, **trash can sprite**, and related **level** tweaks under [Grass/Vine climb, trash can art, and inputs (2026-04-19)](#grassvine-climb-trash-can-art-and-inputs-2026-04-19).

---

## Lawrence hero, Memphis pass, and music (2026-04-18)

This batch aligns single-player with **Lawrence** as the sole on-screen hero, drives **idle** and **walk** from **`player/Lawrence/idle`** and **`player/Lawrence/walk`**, refreshes **level / parallax** toward a Memphis look, and swaps the menu autoload track to **Memphis** music.

### Player (`player/player.gd`, `player/player.tscn`)

| Topic | Detail |
|------|--------|
| Idle | Cycles **`res://player/Lawrence/idle/L_idle1.png`** through **`L_idle4.png`** on **`Sprite2D`**, same timing as before (**`IDLE_FRAME_DURATION`**). |
| Walk | Cycles **`res://player/Lawrence/walk/L_walk1.png`** through **`L_walk6.png`** with speed-scaled step rate. |
| HD scale | Source art is ~**320×321**; **`Sprite2D`** scale uses **`64 / 321`** so height matches a **64×64** atlas cell at the same root scale. |
| Facing | **`_facing`** (±**1**) updates from horizontal velocity; carry and trash visuals use **`_facing`** for flip ( **`sprite.scale.x`** is no longer only ±**1** during idle/walk). |
| Atlas | **`lawrence.webp`**, **`hframes = 11`**, for jump/fall (**`frame = 4`**), crouch (**`0`**), and **`standing_weapon_ready`** as defined on **`AnimationPlayer`**. |
| State changes | When the logical animation switches **into** anything other than idle or walk, **`_restore_lawrence_atlas()`** reapplies the strip before **`play()`** so frame tracks target the atlas. |
| Pickup | **`pickup`** clip sets **`Sprite2D:texture`** to **`Lawrence/pickup.png`** with **`hframes` / `vframes` = 1**; **`animation_finished`** restores the atlas. |

New or replaced art under **`player/`**: **`lawrence.webp`** (strip including six walk columns and atlas-only poses), **`player/Lawrence/`** (idle, walk, pickup PNGs).

### Single-player scene (`game_singleplayer.tscn`)

- Instances **`Level`** and **`Player`** (**`player.tscn`**) at **`(-170, 546)`** plus pause UI.
- Removed the child **`AnimatedSprite2D`** and embedded **`SpriteFrames`** that drew a second Lawrence on top of **`Sprite2D`**.

### Project (`project.godot`)

- **`config/description`** states that **Lawrence** is the playable character in single-player (main scene).

### Music

| File | Change |
|------|--------|
| **`music.tscn`** | **`AudioStreamPlayer`** stream → **`res://memphis.ogg`**. |
| **`memphis.ogg`** | New loop (with **`.import`**). |
| **`music.ogg`** | Removed (replaced by Memphis track). |

Looping and pause behavior are extended in [Trash art, carry scale, Memphis loop, and decor vines (2026-04-19)](#trash-art-carry-scale-memphis-loop-and-decor-vines-2026-04-19) (**`music.gd`**, **`process_mode`**, import **`loop`**).

### Level and background

| File | Change |
|------|--------|
| **`level/background/parallax_background.tscn`** | Parallax / background layer edits for the new skyline. |
| **`level/level.tscn`** | TileMap and scene-object pass (Memphis-themed layout; review in editor for exact instance edits). |
| **`level/background/lvl1_memphis_skyline.jpg`** | New skyline texture (+ **`.import`**). |
| **`level/props/tiles-01.svg`** | New prop / tile graphic (+ **`.import`**). |

### How to verify

1. Run **`game_singleplayer.tscn`**: one Lawrence; idle and walk use folder PNGs; air poses use the atlas.
2. Confirm **Memphis** music autoplays (**`Music`** autoload).
3. Scroll the level: parallax and new skyline behave as expected.

### Scratch files

- **`node_2d.tscn`** (empty **`Node2D`** root) was **not** included in the save commit; remove it locally if it was accidental.

---

## Lawrence animation follow-up and hidden platform collisions (2026-04-19)

This follow-up batch documents animation timing and source updates for Lawrence, plus gameplay-safe collision behavior for hidden platforms in the main level.

### Player animation behavior (`player/player.gd`, `player/player.tscn`)

| Topic | Detail |
|------|--------|
| Idle cadence | **`IDLE_FRAME_DURATION`** now drives a slow loop (current value **`7.0`** sec as configured). |
| Idle frame weighting | The second idle frame (**`L_idle2`**) is weighted to **one-third** of full idle frame duration; other idle frames use full duration. |
| Jump art source | Air states now pull HD frames from **`player/Lawrence/jump`**: **`L_jump1`** and **`L_jump2`**. |
| Jump selection | Upward phase uses **`L_jump1`** while **`velocity.y < JUMP_ASCENT_FRAME_0_WHILE_VY_LESS`** (currently **`-280.0`**), otherwise **`L_jump2`**; falling uses **`L_jump2`**. |
| Atlas handoff | Entering `jumping`/`falling` states no longer immediately restores atlas frames; HD jump textures remain active for those air states. |
| Scene resource updates | `player.tscn` now references the Lawrence atlas through a local **`CompressedTexture2D`** subresource, and the `idle` animation resource length is set to **`10.0`**. |

### Single-player placement (`game_singleplayer.tscn`)

- `Player` remains spawned at **`(-170, 546)`**.
- The instance keeps **`texture_filter = 1`**.
- Transform overrides were corrected from an over-scaled/tilted state; current instance uses no rotation override and a reduced scale (**`Vector2(1.4568996, 1.4568996)`**) compared with the prior oversized setup.

### Level/platform collision safety (`level/level.gd`, `level/level.tscn`)

| File | Change |
|------|--------|
| **`level/level.gd`** | Added platform visibility-collision synchronization for the `Platforms` subtree. Hidden `CollisionObject2D` nodes now have `collision_layer`/`collision_mask` set to `0`; defaults are restored when visible again. |
| **`level/level.tscn`** | Contains hidden platform instances (e.g., `Platform`, `Platform2`, `PlatformStatic`) that now respect the above runtime collision gating. |

### Editor art/layout pass (`level/level.tscn`)

- Multiple decorative nodes under `Grass`, `Flowers`, `Trees`, `Bushes`, and `Rocks` were repositioned/rescaled.
- These are visual composition updates; no new blocker bodies were introduced in this pass.

### How to verify

1. Run **`game_singleplayer.tscn`** and idle: confirm frame 2 flashes faster than frames 1/3/4.
2. Jump and fall: confirm air poses come from **`player/Lawrence/jump`** (two-frame behavior, with `L_jump2` on descent).
3. In `level.tscn`, set `Platform2.visible = false` and run: confirm player cannot stand on or collide with it.
4. Toggle a hidden platform visible at runtime/editor and re-run: collision should return when visible.

---

## Trash art, carry scale, Memphis loop, and decor vines (2026-04-19)

### Trash pickups and cans (`pickups/trash_pickup.*`, `pickups/trash_can.gd`, `level/level.tscn`, `level/level_2.tscn`)

| Topic | Detail |
|------|--------|
| Visual | **`trash_pickup.tscn`** uses a **`Sprite2D`** + **`RectangleShape2D`** (~**40×42**) instead of a red **`Polygon2D`** triangle; default texture **`level/props/Trash/trash_bbag1.png`**, scale **0.125** on the sprite (320×321 source art). |
| Variants | **`@export var trash_texture`** on **`trash_pickup.gd`**; **`level.tscn`** / **`level_2.tscn`** assign seven distinct **`level/props/Trash/*.png`** textures across **`Trash`–`Trash7`**. |
| Count | Main **`level.tscn`** and **`level_2.tscn`** each place **seven** trash instances; **`TrashCan`** / **`TrashCan2`** overrides **`pieces_required`** to **4** and **3** respectively so deposits can consume all seven pieces across two cans. |
| Completion | **`trash_can.gd` → `_finish_trash_collection()`** still disables the can **`DropZone`**; it **no longer** **`queue_free()`**s every **`trash_pickup`** in the tree (so unpicked trash is not wiped when one can finishes first). |

### Player carry sizing (`player/player.gd`, `player/player.tscn`, `pickups/seed_pickup.gd`)

| Topic | Detail |
|------|--------|
| Seed pickup | **`try_pickup_seed(seed_kind, _sprite.global_scale)`** passes the pickup’s world scale. |
| Trash pickup | **`try_pickup_trash(texture, _sprite.global_scale)`** passes texture and scale. |
| Overhead icon | **`CarryTrashVisual`** is a **`Sprite2D`** (placeholder texture **`trash_cup.png`** until a pickup sets the real texture). **`_carry_local_scale_from_ground_pickup()`** sets carry **`scale`** so **world** size matches **`abs(pickup_sprite.global_scale)`** at grab time, divided by **`abs(player.global_scale)`**; **`Vector2.ZERO`** on the optional args falls back to **`_SEED_VISUAL_SCALE`** / **`_TRASH_PICKUP_VISUAL_SCALE`**. |

### Memphis music (`music.tscn`, `music.gd`, `memphis.ogg.import`)

| Topic | Detail |
|------|--------|
| Loop | **`music.gd`** sets **`(stream as AudioStreamOggVorbis).loop = true`** and calls **`play()`** in **`_ready`** (replaces **`autoplay`** so loop is applied reliably). **`memphis.ogg.import`** sets **`loop=true`** for import. |
| Pause | **`Music`** **`AudioStreamPlayer`** uses **`process_mode = 3` (`PROCESS_MODE_ALWAYS`)** so playback continues while **`SceneTree.paused`** (pause menu). |

### Level decor (`level/level.tscn`)

| Topic | Detail |
|------|--------|
| Vines | **`Grass/Vine`**, **`Grass/Vine2`**, **`Grass/Vine3`** use **`level/props/Vine1.png`** (**`ExtResource("40")`**) with **`material = ExtResource("18")`** (**`wind_sway.tres`**) like other swaying vines. |
| Trash can texture path | **`Trashcan.png`** (and **`.import`**) moved from **`level/props/Trash/`** to **`level/props/`** (capital **T** filename at repo root of that asset). |

### Placeholder art (`player/Lawrence/climb/`)

- **`Climb1.png`–`Climb3.png`** (+ **`.import`**) remain in the repo; **runtime climb frames** use **`player/Lawrence/climb2/`** (see [Grass/Vine climb, trash can art, and inputs (2026-04-19)](#grassvine-climb-trash-can-art-and-inputs-2026-04-19)).

### How to verify

1. Run **`game_singleplayer.tscn`**: trash appears as **prop sprites**, not red triangles; carry icon matches the picked-up trash art and size.
2. Deposit trash at both cans until **`pieces_required`** is met on each; remaining trash on the ground **stays** until picked up.
3. Open pause: **Memphis** keeps playing; after unpause, music should still loop from **`music.gd`** + import.
4. In the level, confirm **`Vine` / `Vine2` / `Vine3`** sway with other **`wind_sway`** props.

---

## Grass/Vine climb, trash can art, and inputs (2026-04-19)

This batch wires **Lawrence** climb art on the décor **`Grass/Vine`**, **`Grass/Vine2`**, and **`Grass/Vine3`** sprites, adds **vertical** input actions, replaces the **trash can** placeholder graphic, and documents **`level.gd`** / **`level.tscn`** edits that support the feature.

### Level registration (`level/level.gd`)

| Topic | Detail |
|------|--------|
| **`vine_climb` group** | In **`_ready()`**, nodes at **`Grass/Vine`**, **`Grass/Vine2`**, and **`Grass/Vine3`** are added to group **`vine_climb`** using **`NodePath` literals** (`^"Grass/Vine"`, …) so **`get_node_or_null`** receives a valid **`NodePath`** (not **`StringName`**). |

### Player climb and air idle crest (`player/player.gd`, `player/player.tscn`)

| Topic | Detail |
|------|--------|
| Climb art | **`_LAWRENCE_CLIMB`** preloads **`player/Lawrence/climb2/Climb1.png`–`Climb3.png`**; **`AnimationPlayer`** includes a stub **`climbing`** clip (same pattern as idle/walk: frames driven in GDScript). |
| Latch | **`_vine_climb_latched`** starts only when the player **intersects** grown **`vine_climb`** rects, **`_vine_latch_eligible_after_jump`** is true (set on any successful **`try_jump()`** impulse, cleared on **`is_on_floor()`** after **`move_and_slide()`**), **`velocity.y > CLIMB_VINE_LATCH_MIN_DESCENT_VY`**, reattach cooldown clear, and not **`_vine_crest_idle`**. Column bounds use the **union** of all **`vine_climb`** sprite rects plus **`CLIMB_COLUMN_PAD_X`**. |
| Motion | While climbing: no gravity; **`move_up` / `move_down`** axis sets vertical speed (**`CLIMB_SPEED`**); horizontal uses **`CLIMB_SIDE_SPEED`**. **`jump`** before **`_refresh_vine_climb_latch()`** so eligibility and overlap can apply same frame. |
| Stop + idle | Climb ends when the **vertical midpoint** of the Lawrence **`Sprite2D`** frame is at or above **`Grass/Vine2`**’s sprite top (**`_grass_vine2_sprite_top_y()`** via **`game_level`** → **`Grass/Vine2`**), with **`CLIMB_VINE2_STOP_MARGIN`**. Then **`_vine_crest_idle`**: no gravity, **`velocity.y = 0`**, horizontal decay, **`get_new_animation()`** returns **`idle`** until floor, horizontal move, or jump (dedicated **`try_jump()`** branch). |
| Jump vs Up | If **`jump`** and **`move_up`** share **Arrow Up**, **`try_jump()`** is skipped when climbing and **`climb_axis_v >= 0.35`** so Up climbs; **Space / W / gamepad** still jump off the vine. |
| Auto-hop | Removed (no ceiling-ray mount impulse). |

### Project input (`project.godot`)

| Action | Role |
|--------|------|
| **`move_up`**, **`move_down`** | Arrow Up/Down + left-stick vertical (default); **`move_up_p1` / `move_down_p1`**, **`move_up_p2` / `move_down_p2`** for split-screen suffix **`_p1`** / **`_p2`**. |
| **`jump`** | **Arrow Up** re-bound alongside **W**, **Space**, gamepad **A** so ground/air jump works with Up; combined with climb rule above on vines. |

### Trash can visual (`pickups/trash_can.tscn`)

| Before | After |
|--------|--------|
| **`CanVisual`** **`Polygon2D`** (dark green **64×64** square) | **`Sprite2D`** with **`res://level/props/Trashcan.png`** (**320×321**), **`scale = Vector2(0.2, 0.2)`** (~**64×64** footprint), **`DropZone`** hitbox unchanged. |

### Level scene (`level/level.tscn`)

- **TileMap** `layer_0/tile_data` and a few **prop positions** / **TrashCan** / **Trash** instance tweaks (editor pass).
- **`TrashCan`** / **`TrashCan2`**: small **position** nudge + shared **`scale`** on the instance.
- **`Grass/Vine2`** / **`Grass/Vine3`**: **modulate** color adjustments.

### New assets

| Path | Role |
|------|------|
| **`player/Lawrence/climb2/`** | **`Climb1.png`–`Climb3.png`** (+ **`.import`**) used for the **`climbing`** animation. |
| **`level/props/Sun.png`** (+ **`.import`**) | Texture added to the repo (optional future décor; not referenced in **`level.tscn`** in this commit). |

### How to verify

1. **Jump** onto **`Grass/Vine*`** (falling onto overlap with descent speed): Lawrence switches to **`climbing`** and **`climb2`** frames; **Up/Down** move along the vine; stop near **`Vine2`** top shows **idle** crest until you move, land, or jump.
2. **Walk** into the vine without a qualifying jump: **no** climb latch.
3. **Trash cans**: instances show **`Trashcan.png`**, not a solid green square.
4. **Split-screen**: confirm **`move_up_p1`** / **`move_down_p1`** (and **`_p2`**) exist in **Project → Input Map** if you test P2.

---

## Documentation map

| What | Where |
|------|--------|
| Project overview, main scene, quick feature list | **[README.md](README.md)** |
| Detailed behavior, file tables, verification steps | **This file — `CHANGELOG.md`** |
| Input map, autoloads, display, physics layer **names** | **`project.godot`** |
| Editor **Project → Project Settings…** name/description | **`project.godot`** → `[application]` **`config/name`**, **`config/description`** |

### Section index (`CHANGELOG.md`)

Use your editor’s outline or search headings below. Common jump targets (GitHub / many Markdown viewers):

| Heading | Contents |
|---------|----------|
| **Display and viewport (16:9)** | Resolution, stretch, split viewports |
| **Combat and enemies** / **Coins and UI counter** | Removed demo features |
| **Seeds, soils, planting, and pickup notifications** | Manual pickup, plant, **`drop_seed`**, carry, growth, soil layout |
| **Trash and trash can** | Sprite trash props, **`Trashcan.png`** can visual, deposit, **`trash_pickup`** group |
| **Theme and UI text (`gui/theme.tres`, notifications, pause)** | **`gui/theme.tres`**, font + outline, notifications, labels |
| **Willow seed 2 delayed pickup (`pickups/willow_seed_2_pickup.gd`)** | Hidden pickup, fall tween, **`NodePath`** for tween |
| **Level and tileset revisions** | TileMap / **`tileset.tres`** edits, décor visibility, finish marker, **`level_2.tscn`** |
| **Single-player spawn and camera scroll limits** | Player start position; **`level.gd`** `LIMIT_LEFT` / `LIMIT_RIGHT`; related **`level.tscn`** tweaks |
| **Lawrence hero, Memphis pass, and music (2026-04-18)** | Lawrence **`Sprite2D`** idle/walk PNGs, atlas air/pickup, **`game_singleplayer`** cleanup, Memphis audio and level/parallax art |
| **Lawrence animation follow-up and hidden platform collisions (2026-04-19)** | Idle timing weighting, jump frames from **`player/Lawrence/jump`**, single-player transform correction, hidden platform collision disable/restore |
| **Trash art, carry scale, Memphis loop, and decor vines (2026-04-19)** | Trash **`Sprite2D`** pickups, seven-per-level textures, **`pieces_required`** 4+3, can completion behavior, carry world-scale match, **`music.gd`** + pause-safe loop, **`Vine1.png`** props, climb PNG placeholders |
| **Grass/Vine climb, trash can art, and inputs (2026-04-19)** | **`vine_climb`** group in **`level.gd`**, Lawrence **`climb2`** + **`climbing`** state, jump-gated latch, **`Grass/Vine2`** top stop + crest idle, **`move_up`/`move_down`**, **`Trashcan.png`** on **`trash_can.tscn`**, **`level.tscn`** tweaks |
| **Technical notes** | Stale UIDs, collision shapes; subsection **2D draw order (`z_index`)** |

---

## Single-player spawn and camera scroll limits

### Motivation

- Single-player spawn moved **left** so the level starts further into the map; the default **`Camera2D`** scroll limits from **`level/level.gd`** were still **`LIMIT_LEFT = -315`** and **`LIMIT_RIGHT = 955`**, which clamped the view too early: the camera could not follow the player to the **left** (viewport half-width **480** needs the view’s left edge near **−650** when centered on **`x ≈ −170`**) or to the **far right** (level props and décor extend past **`x ≈ 1500`**, so **`LIMIT_RIGHT = 955`** was far too small).

### Changes

| File | Change |
|------|--------|
| **`game_singleplayer.tscn`** | **`Player`** under **`Level`**: **`position`** **`(90, 546)`** → **`(-170, 546)`**. |
| **`level/level.gd`** | **`LIMIT_LEFT`**: **`-315`** → **`-1200`**. **`LIMIT_RIGHT`**: **`955`** → **`2200`**. (**`LIMIT_TOP`** / **`LIMIT_BOTTOM`** unchanged.) |
| **`level/level.tscn`** | **`Soils`** root **`Node2D`**: **`position = Vector2(1, 0)`** (fine placement in the editor). **`Flower18`**, **`Flower19`**, **`Flower20`**, **`Flower21`**: **`visible = false`** (décor thinned to match other hidden flowers). |

### Split-screen

- **`game_splitscreen.tscn`** is unchanged: **`Player1`** remains **`(90, 546)`**, **`Player2`** at **`(120, 546)`**. The new limits still apply when **`Level`** loads (both players’ cameras are updated in **`level.gd`** **`_ready`**).

### How to verify

1. Run **`game_singleplayer.tscn`**: confirm spawn at the new left start and that walking **left** and **right** keeps the character on screen (no early horizontal “hard stop” from limits).
2. Walk to the **rightmost** playable / visual extent of the map; confirm the camera continues to follow.
3. Optional: run **`game_splitscreen.tscn`** and confirm cameras still respect limits without odd clamping at the map edges.

---

## Display and viewport (16:9)

### Motivation

- **16:9** base resolution (**960×540**) with default window **1920×1080**.
- **No black bars** on arbitrary window sizes and aspect ratios: use **`expand`** so the scaled view covers the whole window (edges clip when the window is not 16:9).
- **Smooth scaling** at any size: **`fractional`** (the demo used **`integer`**, which leaves large margins when the window is not an exact multiple of the viewport, e.g. the editor’s default run size).

### Project settings (`project.godot`)

| Setting | Before | After |
|---------|--------|--------|
| `display/window/size/viewport_width` | 800 | **960** |
| `display/window/size/viewport_height` | 480 | **540** |
| `display/window/size/window_width_override` | 1600 | **1920** |
| `display/window/size/window_height_override` | 960 | **1080** |
| `display/window/stretch/aspect` | `keep_height` | **`expand`** |
| `display/window/stretch/scale_mode` | `integer` | **`fractional`** |

**Unchanged:** `window/stretch/mode="canvas_items"`.

### Stretch behavior (reference)

| Setting | Role |
|---------|------|
| **`expand`** | Scale uniformly until the window is covered; **no letterboxing/pillarboxing**. On non–16:9 displays, a strip of the world is **cropped** at top/bottom or left/right. |
| **`fractional`** | Allows non-integer scale factors so the canvas **fills** the run window (no “1× only” gaps from **`integer`**). Slight softness on pixel art at odd scales; textures already use **nearest** where imported. |
| **`keep_height`** (previous) | Preserves aspect with **bars** when the window aspect ≠ game aspect. Restore if you prefer **never cropping** the playfield. |
| **`integer`** (previous) | Crisp integer multiples only; use with a window that is an exact multiple of **960×540** if you want both sharp pixels and no margins. |

### Split-screen (`game_splitscreen.tscn`)

Each `SubViewport` (`Viewport1`, `Viewport2`) internal size:

| Before | After |
|--------|--------|
| `Vector2i(399, 480)` | **`Vector2i(480, 540)`** |

Roughly half of **960×540** per pane (same pattern as before for **800×480**).

### What was not modified

- **`game_singleplayer.tscn`**, **`player/player.tscn`** (including `Camera2D` world limits), **`level/`**, **`gui/`** — no scene edits for this change.
- **Scripts** — no viewport dimensions hardcoded; none required updates.
- Level and parallax use **world** coordinates; numbers like `800` in `level.tscn` are **level geometry**, not the old viewport width.

### Follow-ups (optional)

1. **`player/player.tscn` — `TouchScreenButton` nodes** (`Left`, `Right`, `Jump`): positions use **y = 813** and jump **x ≈ 1871**, which do not fit inside a **540**-tall or **960**-wide logical viewport. Revisit if you ship **mobile / touchscreen** builds.
2. **Split-screen**: `HSplitContainer` is draggable; fixed **480×540** sub-viewports can **stretch** oddly if the divider is moved from a 50/50 split.
3. **Composition**: Single-player shows **more horizontal world** at once; tune art or camera limits if edges feel empty.

### How to verify

1. Run **`game_singleplayer.tscn`**: window should be **1920×1080** (or editor run size); image should **fill** the window (**no black bars**). On **16:9**, behavior matches a full-frame 16:9 view; on other aspects, expect **slight cropping** at edges.
2. Run **`game_splitscreen.tscn`**: each player view should fill half the screen on a **1080p** display.

---

## Combat and enemies

### Player (`player/player.gd`, `player/player.tscn`)

- Shooting removed:
  - No `Gun` reference, no `ShootAnimation` timer, no `shoot` + `action_suffix` input handling.
  - Animations use only base names: `idle`, `run`, `jumping`, `falling` (no `_weapon` variants at runtime).
- Removed nodes: `ShootAnimation`, `Sprite2D/Gun` (and its `Shoot` audio + `Cooldown` timer).
- Removed mobile **Fire** `TouchScreenButton` from `UI`.
- Removed external resources: `shoot.wav`, `gun.gd`.

### Deleted files (combat)

- `player/gun.gd`, `player/gun.gd.uid`
- `player/bullet.gd`, `player/bullet.gd.uid`, `player/bullet.tscn`

### Enemies

- Deleted `enemy/enemy.gd`, `enemy/enemy.gd.uid`, `enemy/enemy.tscn`.
- `level/level.tscn`: removed `Enemies` node and all enemy instances; removed `enemy.tscn` `ext_resource`; adjusted `load_steps`.

**Note:** `enemy/` may still contain `enemy.webp`, `explode.wav`, `hit.wav` and their `.import` files if not deleted manually. They are unused.

### Project settings (`project.godot`)

- Removed input actions: `shoot`, `shoot_p1`, `shoot_p2`.
- Updated `config/description` to drop bullets and enemies.

### Global class cache (`.godot/global_script_class_cache.cfg`)

- Removed registered global classes: `Bullet`, `Enemy`, `Gun` (paths pointed at deleted scripts).

### Unused assets (optional cleanup)

- `player/shoot.wav` (+ `.import`)
- `player/bullet.webp` (+ `.import`)

---

## Coins and UI counter

### Level (`level/level.tscn`)

- Removed entire `Coins` subtree (all `Coin*` instances under grouped nodes like `CoinsHorizontal1`, `CoinsArc1`, etc.).
- Removed `coin.tscn` `ext_resource`; adjusted `load_steps`.

### Player (`player/player.gd`)

- Removed `signal coin_collected()` (nothing emits it after `coin.gd` is deleted).

### Pause menu (`gui/pause_menu.tscn`, `gui/pause_menu.gd`)

- Removed `CoinsCounter` child instance and `coins_counter.tscn` reference.
- Removed `@onready var coins_counter` and `_on_coin_collected()`.

### Game scenes

- `game_singleplayer.tscn`: removed signal connection `coin_collected` → `PauseMenu._on_coin_collected`.
- `game_splitscreen.tscn`: same for both `Player1` and `Player2`.

### Deleted files (coins)

- `level/coin.gd`, `level/coin.gd.uid`, `level/coin.tscn`
- `gui/coins_counter.gd`, `gui/coins_counter.gd.uid`, `gui/coins_counter.tscn`

### Project settings (`project.godot`)

- Updated `config/description` to remove “collect coins”.

### Global class cache

- Removed registered global classes: `Coin`, `CoinsCounter`.

### Unused assets (optional cleanup)

- `level/coin.webp` (+ `.import`)
- `player/coin_pickup.wav` (+ `.import`)

### Unchanged but relevant

- `project.godot` still names physics layer 3 `"coins"`; it is only a label and does not create coin objects.

---

## Files touched (reference)

| File | Change |
|------|--------|
| `player/player.gd` | No shooting; no `coin_collected` |
| `player/player.tscn` | No gun / shoot UI |
| `level/level.tscn` | No enemies, no coins; `load_steps` updates |
| `project.godot` | Description + removed shoot inputs; **16:9** viewport + window override; stretch **`expand`** + **`fractional`** ([Display and viewport (16:9)](#display-and-viewport-169)) |
| `gui/pause_menu.tscn` | No coins counter |
| `gui/pause_menu.gd` | No coin handler |
| `game_singleplayer.tscn` | No `coin_collected` connection |
| `game_splitscreen.tscn` | No `coin_collected` connections; **16:9** `SubViewport` sizes (same section) |
| `.godot/global_script_class_cache.cfg` | Dropped removed global classes |

Scenes that **instance** `pause_menu.tscn` (`pause_menu_singleplayer.tscn`, `pause_menu_splitscreen.tscn`) required no structural edits beyond inheriting the updated base pause menu.

---

## How to verify

1. Open the project in Godot 4.x and run `game_singleplayer.tscn` (main scene).
2. Confirm: no enemies, no coin HUD, no shooting; movement, jump, pause, and platforms still work.
3. Optional: run split-screen scene and repeat.

---

## Editor cache

Godot may regenerate `.godot/editor/` caches on next open. If stray references appear, use **Project → Reload Current Project** or reimport.

---

## Seeds, soils, planting, and pickup notifications

This section documents features added after the original demo trim: placeholder seed and soil art, **single-carry** pickup/planting, soil prompts, and on-screen pickup messages.

### Design

- **Single carry:** The player holds at most one seed at a time. Picking up a second seed while already holding one does nothing (the pickup stays in the world until the slot is free).
- **Willow soils (shared rule):** Patches configured as **willow** (`SeedDefs.Type.WILLOW_1` or `WILLOW_2` on the drop zone) accept **either** **willow tree seed** (willow 1 or willow 2). The player does not need to match a specific willow seed to a specific willow soil.
- **Cypress soil:** Only **cypress** seed can be planted there.
- **Pickup feedback:** While overlapping a seed, pressing **`drop_seed`** (see Input) plays **`player/coin_pickup.wav`** (reused), removes the pickup, and shows a timed notification banner.
- **Planting feedback:** Successful drop applies a light green **modulate** on the soil sprite and disables further drops on that patch.

### Input

| Action | Default binding | Notes |
|--------|-----------------|--------|
| `drop_seed` | Keyboard **E**, gamepad button **2** | Single-player (`action_suffix` empty). |
| `drop_seed_p1` / `drop_seed_p2` | **E** / **Q** (+ pads) | Split-screen players (`action_suffix` **`_p1`** / **`_p2`**). |

Planting requires standing inside the soil **`DropZone`** `Area2D` (collision **mask** includes the player layer) and pressing the correct **`drop_seed*`** action for that player.

### Autoloads (`project.godot`)

| Name | Resource | Role |
|------|----------|------|
| `SeedDefs` | `pickups/seed_defs.gd` | Defines shared enum **`SeedDefs.Type`**: `NONE`, `WILLOW_1`, `WILLOW_2`, `CYPRESS`. |
| `PickupNotifications` | `gui/pickup_notifications.gd` | **`CanvasLayer`** (high `layer`); shows **“You picked up a …”** with display names **willow tree seed** / **cypress tree seed**; **5** second duration; **black** semi-opaque bar, **horizontally centered** at the bottom, width **at most one-third** of the visible viewport; relayout on **`viewport.size_changed`**. |

### Art placeholders (`level/props/`)

| File | Description |
|------|-------------|
| `willow_seed_1.webp`, `willow_seed_2.webp` | **64×64** WebP; black circle on transparent background (plus `.import`). |
| `cypress_seed.webp` | **64×64**; blue circle. |
| `willow_soil_1.webp`, `willow_soil_2.webp` | **100×72**; brown fills. |
| `cypress_soil.webp` | **100×72**; light blue fill. |

### Pickup scenes and script

| Path | Role |
|------|------|
| `pickups/seed_pickup.gd` | **`@tool`** `Area2D`. **`@export var seed_kind`**. Scales sprite and circle hitbox to **⅙** of the player’s **64×64** frame × **0.8** root scale (matches `player/player.tscn`). Tracks overlapping **`Player`**s; in **`_physics_process`**, on **`drop_seed` + `player.action_suffix`**, calls **`try_pickup_seed`**; on success, **`PickupNotifications.show_pickup`**, detaches/plays pickup SFX, **`queue_free()`**. Editor runs sizing via **`@tool`**; gameplay connects signals only when not **`Engine.is_editor_hint()`**. |
| `pickups/willow_seed_1_pickup.tscn` | `seed_kind` = willow 1. |
| `pickups/willow_seed_2_pickup.tscn` | `seed_kind` = willow 2. |
| `pickups/cypress_seed_pickup.tscn` | `seed_kind` = cypress. |

### Soil drop zones

| Path | Role |
|------|------|
| `pickups/soil_drop_zone.gd` | On **`Soils/*`** sprites: child **`DropZone`** `Area2D` with **`@export accepts`** (`SeedDefs.Type`). Tracks overlapping **`Player`**s; each frame updates a **`CanvasLayer`** **Label** above the soil (“Plant Willow Seed Here” / “Plant Cypress Seed Here”) using **`gui/theme.tres`** font + white fill + black outline. On **`drop_seed` + `player.action_suffix`**, if held seed is **compatible**, plants and tints parent **`Sprite2D`**, then runs a **4-step async growth** on a **`PlantedGrowth`** child: **`Polygon2D`** morphs to a **pink placeholder** (exports: **`growth_step_delay_sec`**, **`final_growth_height_px`**, **`final_growth_width_px`**). After maturity, **`planted_tree_prompt.gd`** instance shows **“Black Willow Tree”** or **“Blue Cypress Tree”** when the player overlaps the placeholder. **First** willow patch (soil 1 **or** 2) to finish growth from a planted **willow #1** seed triggers **`level.gd` → `drop_willow_seed_2_from`** once (static **`_willow_seed_2_released`**); seed 2 tweens from the placeholder top to a **world point beside that rectangle** (`willow_seed_2_pickup.gd` uses **`^"global_position"`** for **`Tween.tween_property`**). **`RectangleShape2D`** size **100×72** in local space inherits each soil’s **`scale`**. |

### Player carry (`player/player.gd`, `player/player.tscn`)

- **`_held_seed`**, **`get_held_seed_kind()`**, **`try_pickup_seed(kind, ground_sprite_global_scale)`**, **`consume_held_for_soil(soil_kind)`** (willow-or-willow matching for any willow soil; cypress-only for cypress soil). **`try_pickup_seed`** refuses if the player is already holding **trash** (see [Trash and trash can](#trash-and-trash-can)).
- **`_holding_trash`**, **`try_pickup_trash(tex, ground_sprite_global_scale)`**, **`deposit_trash()`**, **`is_holding_trash()`** — mutually exclusive with carrying a seed.
- **`CarryVisual`** **`Sprite2D`**: shows the correct seed texture; overhead **world** size matches the pickup **`Sprite2D.global_scale`** at grab (via **`_carry_local_scale_from_ground_pickup`**); **`scale.x`** follows run direction.
- **`CarryTrashVisual`** **`Sprite2D`**: shows the carried trash texture with the same world-size rule; **`scale.x`** follows run direction like seeds.

### Level layout (`level/level.tscn`)

- **Root `Level`** **`Node2D`** uses **`level/level.gd`**: adds **`game_level`** group; sets camera limits for **`Player`** children; implements **`drop_willow_seed_2_from(world_top, world_land)`** for the delayed willow 2 pickup.
- **Pickups:** **`WillowSeed1Pickup`**, **`WillowSeed2Pickup`** (starts hidden until the first willow-1 maturity drop), **`CypressSeedPickup`** instanced under **`Level`**.
- **`TrashCan`**, **`TrashCan2`**, **`Trash`–`Trash7`** (seven instances) — see [Trash and trash can](#trash-and-trash-can) and [Trash art, carry scale, Memphis loop, and decor vines (2026-04-19)](#trash-art-carry-scale-memphis-loop-and-decor-vines-2026-04-19).
- **`FinishLine`** (**`Node2D`**) with child **`Square`** (**`Polygon2D`**, brown **64×64** quad): visual **finish marker** only (no `Area2D`, no win logic). **`z_index`** **3** on the parent. Editor positions: parent **`(900, 576)`**, child offset **`(460, -249)`** (tune in **`level/level.tscn`**).
- **`level/level_2.tscn`**: duplicate of the level scene for a second layout (**different root scene `uid://`** from **`level.tscn`**; root node name **`Level 2`**). **Not** referenced by **`game_singleplayer.tscn`** / **`game_splitscreen.tscn`** until you instance it there or change the main level path.
- **`Soils`** **`Node2D`**: **`WillowSoil1`**, **`WillowSoil2`**, **`CypressSoil`** **`Sprite2D`** nodes (manual **`position`** / **`scale`**).
- Each soil has a **`DropZone`** child with **`soil_drop_zone.gd`**; **`accepts`** is **1**, **2**, or **3** in the scene file — **both 1 and 2 are treated as willow family** for compatibility checks.

### Project hygiene (historical)

- Empty default scenes **`control.tscn`** and **`node_2d.tscn`** were removed from the repository root when they were identified as unused saves.

### How to verify (planting loop)

1. Run **`game_singleplayer.tscn`** (main scene).
2. Stand on each seed and press **E**: hear pickup sound, see **5 s** bottom banner and carry icon.
3. Stand on a **willow** soil with **either** willow seed; press **E**: seed clears, soil tints, growth plays, then pink placeholder and tree label on approach. Repeat willow **#1** on **either** willow soil first to get **willow seed 2** dropped near that patch; pick it up with **E** on the fallen pickup.
4. Stand on **cypress** soil with **cypress** seed only; press **E** — same success behavior; wrong seed does nothing.
5. Resize the game window: notification bar stays **centered**, **≤ ⅓** width, at the **bottom**.

---

## Level and tileset revisions (editor)

Recorded here so hand-edited **`level/level.tscn`** and **`level/tileset.tres`** changes stay documented in-repo (not only in Git history).

### `level/tileset.tres`

- The main **`TileSetAtlasSource`** now lists extra **atlas coordinates** used on the TileMap: **`5:1/0`**, **`6:1/0`**, **`7:1/0`**, **`0:1/0`**, **`3:1/0`**, **`1:1/0`** (Godot writes these when those tiles appear in the palette / map).

### `level/level.tscn` — collision and footprint

- **`TileMap`** **`layer_0/tile_data`** was **rebuilt**: large stretches of the old floor / platforms were removed or replaced; new tiles extend farther **to the right** (wider playable strip toward the camera **`limit_right`** band). **Collision and traversal changed** relative to earlier revisions — re-verify jumps and pits after pulling.

### `level/level.tscn` — trash instances

- Second **`TrashCan`** instance: **`TrashCan2`** (see [Level layout](#level-layout-levelleveltscn) bullets).
- **`Trash`–`Trash7`**: seven trash pickups with per-instance **`trash_texture`** from **`level/props/Trash/*.png`**. **`TrashCan`** / **`TrashCan2`** set **`pieces_required`** to **4** and **3** on the instances in **`level.tscn`** (mirrored in **`level_2.tscn`**). See [Trash art, carry scale, Memphis loop, and decor vines (2026-04-19)](#trash-art-carry-scale-memphis-loop-and-decor-vines-2026-04-19).

### `level/level.tscn` — décor and platforms (visibility)

- Many **`Grass`**, **`Flowers`**, **`Trees`**, **`Bushes`**, **`Rocks`** sprites (and some **vines**) have **`visible = false`** for a sparser background.
- **`Platforms/Platform`**, **`Platform2`**, and **`PlatformStatic`** have **`visible = false`**. **Collision still runs** for hidden physics bodies unless you disable shapes or remove nodes — invisible **moving** and **static** platforms may still block the player. Re-enable **`visible`** or adjust collision if playtests feel wrong.

### `level/level.tscn` — prop positions (selected)

- Several props that sat in the **sky band** were moved toward **ground** or the **extended right** side (examples in the scene: **ferns** **`f13`**, **`f4`**; **trees** **`T8`**, **`T10`**, **`T3`**, **`T9`**; **bushes** **`B11`**, **`B12`**, **`B31`–`B34`**, **`B10`**; **rocks** **`R4`**, **`R13`**; **grass** **`g79`**; **vines** **`v19`**, **`v40`–`v42`** with extra **rotation** / **`offset`** on some). Exact numbers live in **`level.tscn`**; treat this list as a map of *what kind* of edit happened.

### External resource hygiene

- **`pickups/cypress_seed_pickup.tscn`** **`ext_resource`** in **`level.tscn`** now includes a valid **`uid://b14tshfo56bnc`** (Godot re-saved the reference).

### How to verify (level revisions)

1. Run **`game_singleplayer.tscn`**: confirm **tile collision** matches what you see (no unexpected invisible walls from hidden platforms).
2. Confirm **finish marker** (**`FinishLine`**) appears where you expect relative to the **extended** layout.
3. Optional: open **`level/level_2.tscn`** only when you wire it into a game scene; it is a **separate** scene file until referenced.

---

## Trash and trash can

### Design

- **Trash** pieces are **`Area2D`** pickups (`pickups/trash_pickup.tscn`) with a **`Sprite2D`** ( **`level/props/Trash/*.png`** textures in level layouts) and **`RectangleShape2D`** hitbox, **`collision_layer = 4`**, **`collision_mask = 1`** (same pattern as seeds). Older revisions used red **`Polygon2D`** triangles; see [Trash art, carry scale, Memphis loop, and decor vines (2026-04-19)](#trash-art-carry-scale-memphis-loop-and-decor-vines-2026-04-19).
- **Trash can** (`pickups/trash_can.tscn`): **`CanVisual`** is a **`Sprite2D`** using **`level/props/Trashcan.png`** (~**64×64** world footprint at **`scale` 0.2**); **`DropZone`** `Area2D` keeps a **64×64** `RectangleShape2D`. Older revisions used a green **`Polygon2D`** square; see [Grass/Vine climb, trash can art, and inputs (2026-04-19)](#grassvine-climb-trash-can-art-and-inputs-2026-04-19).
- Pickup is **manual**: overlap + **`drop_seed` + `action_suffix`** (same as seeds and soil).
- Deposit: overlap **`DropZone`** + **`drop_seed*`** calls **`Player.deposit_trash()`**; **`pieces_required`** (default **2** on the script; **4** / **3** on the two cans in **`level.tscn`** / **`level_2.tscn`**) successful deposits complete that can’s task.
- On completion: **`DropZone`** monitoring turns off on that can; the **can stays visible**. Remaining **`trash_pickup`** nodes in the world are **not** bulk-removed ( **`trash_can.gd`** no longer **`queue_free()`**s the whole group).

### Files

| Path | Role |
|------|------|
| `pickups/trash_pickup.gd` | Overlap list + **`_physics_process`**; **`drop_seed` + suffix** → **`try_pickup_trash(tex, scale)`** → **`queue_free()`** on success. Registers **`trash_pickup`** group in **`_ready`**. |
| `pickups/trash_pickup.tscn` | Root node name **`Trash`**; **`Sprite2D`** + **`RectangleShape2D`**. |
| `pickups/trash_can.gd` | Counts deposits; **`_finish_trash_collection()`** disables **`DropZone`** monitoring only. |
| `pickups/trash_can.tscn` | Root node name **`TrashCan`**. |

---

## Theme and UI text (`gui/theme.tres`, notifications, pause)

### `gui/theme.tres`

- **`Label`**: **`font_color`** white, **`font_outline_color`** black, **`outline_size`** **3** (readable text without panel backgrounds).
- **`Button`**: same outline settings so pause menu button labels match.

### `gui/pickup_notifications.gd`

- Root **`Control`** uses **`theme = preload("res://gui/theme.tres")`** so the banner label uses **Kenney Mini Square** (same family as pause **`Resume`**).
- Bottom strip is a **`ColorRect`** (**semi-opaque black**), **`layer`** **110**.

### `pickups/soil_drop_zone.gd` (prompt label only)

- Soil “plant here” **`Label`** uses **`preload("res://gui/theme.tres").default_font`** plus explicit **`font_color`** / **`font_outline_color`** / **`outline_size`** (same look as other HUD labels).

### `pickups/planted_tree_prompt.gd`

- **`Node2D`** added under **`PlantedGrowth`**: **`Area2D`** hitbox aligned to the pink placeholder; **`CanvasLayer`** + **`Label`** with theme font, white text, black outline; updates screen position in **`_physics_process`**.

### Pause menu (`gui/pause_menu.tscn`)

- **“Game Paused”** is a plain **`Label`** under **`VBoxContainer`** (no panel wrapper); outline comes from the shared theme on the root **`Control`**.

---

## Willow seed 2 delayed pickup (`pickups/willow_seed_2_pickup.gd`)

- Extends **`seed_pickup.gd`** but overrides **`_ready`**: starts **`monitoring = false`**, **`visible = false`**, stores landing **`global_position`** from the level.
- **`begin_fall_from(world_top, world_land)`**: tween **`global_position`** with **`Tween.tween_property(self, ^"global_position", …)`** (Godot **4.6** expects a **`NodePath`**, not **`StringName`**).
- **`fall_duration_sec`** export (default **~0.55**).

---

## Technical notes

- **`level.tscn`**: **`cypress_seed_pickup.tscn`** now carries a stable **`uid://`** on its **`ext_resource`**. Other **`PackedScene`** lines may still omit **`uid://`** where the editor has not re-saved them (Godot falls back to path).
- **`trash_pickup.tscn`** uses **`RectangleShape2D`** for the pickup hitbox (replacing the old triangle **`ConvexPolygonShape2D`**).

### 2D draw order (`z_index`)

So the **player walks in front of** the trash can (and stays consistent with seed pickups), these values are set:

| Node / scene | `z_index` | Role |
|--------------|-----------|------|
| **`player/player.tscn`** → **`Player`** (root **`CharacterBody2D`**) | **2** | Character + default child sprites sit above **TileMap** (**1**) and **`TrashCan`** (**1**). Matches seed pickup instances (**2**); among ties, tree order (player often added last under **`Level`**) helps draw order vs pickups. |
| **`pickups/trash_can.tscn`** → **`TrashCan`** (root **`Node2D`**) | **1** | Same band as ground décor / **TileMap**. |
| **`pickups/trash_can.tscn`** → **`CanVisual`** (**`Sprite2D`**) | **0** (relative to parent) | Trash can texture draws on the parent layer (no extra stacking bump). |
| **`level/level.tscn`** → **TileMap** | **1** | |
| **`level/level.tscn`** → **`FinishLine`** (**`Node2D`**) | **3** | Brown **`Polygon2D`** finish marker draws above **TileMap** / trash can band. |
| Seed / cypress pickups under **`Level`** | **2** | Set on each instance in **`level.tscn`**. |
| **`player/player.tscn`** → **`CarryVisual`**, **`CarryTrashVisual`** | **5** (relative) | Carried icon stays above the robot body. |

---
