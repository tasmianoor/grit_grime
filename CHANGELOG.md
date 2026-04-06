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

**Later additions** (see sections below): soil **growth placeholder** + tree labels; **willow seed 2** gated drop; **trash / trash can**; **manual** seed & trash pickup (**E** / **`drop_seed*`**); shared **theme** font + **text outline**; **`level.gd`** orchestration for seed 2; **2D `z_index`** so the player draws in front of the trash can.

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
| **Trash and trash can** | Red triangles, green can, deposit, **`trash_pickup`** group |
| **Theme and UI text (`gui/theme.tres`, notifications, pause)** | **`gui/theme.tres`**, font + outline, notifications, labels |
| **Willow seed 2 delayed pickup (`pickups/willow_seed_2_pickup.gd`)** | Hidden pickup, fall tween, **`NodePath`** for tween |
| **Technical notes** | Stale UIDs, collision shapes; subsection **2D draw order (`z_index`)** |

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

- **`_held_seed`**, **`get_held_seed_kind()`**, **`try_pickup_seed(kind)`**, **`consume_held_for_soil(soil_kind)`** (willow-or-willow matching for any willow soil; cypress-only for cypress soil). **`try_pickup_seed`** refuses if the player is already holding **trash** (see [Trash and trash can](#trash-and-trash-can)).
- **`_holding_trash`**, **`try_pickup_trash()`**, **`deposit_trash()`**, **`is_holding_trash()`** — mutually exclusive with carrying a seed.
- **`CarryVisual`** **`Sprite2D`**: shows the correct seed texture at the carry scale; **`scale.x`** follows run direction (**`signf(sprite.scale.x)`**).
- **`CarryTrashVisual`** **`Polygon2D`**: small red triangle when holding trash; **`scale.x`** follows run direction like seeds.

### Level layout (`level/level.tscn`)

- **Root `Level`** **`Node2D`** uses **`level/level.gd`**: adds **`game_level`** group; sets camera limits for **`Player`** children; implements **`drop_willow_seed_2_from(world_top, world_land)`** for the delayed willow 2 pickup.
- **Pickups:** **`WillowSeed1Pickup`**, **`WillowSeed2Pickup`** (starts hidden until the first willow-1 maturity drop), **`CypressSeedPickup`** instanced under **`Level`**.
- **`TrashCan`**, **`Trash`**, **`Trash2`** — see [Trash and trash can](#trash-and-trash-can).
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

## Trash and trash can

### Design

- **Trash** pieces are **red** **`Polygon2D`** triangles (**40×40** bounding box) as **`Area2D`** pickups (`pickups/trash_pickup.tscn`), **`collision_layer = 4`**, **`collision_mask = 1`** (same pattern as seeds).
- **Trash can** is a **dark green** **64×64** square (`pickups/trash_can.tscn`: **`CanVisual`** `Polygon2D` + **`DropZone`** `Area2D` with **64×64** `RectangleShape2D`).
- Pickup is **manual**: overlap + **`drop_seed` + `action_suffix`** (same as seeds and soil).
- Deposit: overlap **`DropZone`** + **`drop_seed*`** calls **`Player.deposit_trash()`**; **`pieces_required`** (default **2**) successful deposits complete the task.
- On completion: **`DropZone`** monitoring turns off; any nodes in group **`trash_pickup`** still in the level are **`queue_free()`**; the **can stays visible** (no longer hidden).

### Files

| Path | Role |
|------|------|
| `pickups/trash_pickup.gd` | Overlap list + **`_physics_process`**; **`drop_seed` + suffix** → **`try_pickup_trash()`** → **`queue_free()`** on success. Registers **`trash_pickup`** group in **`_ready`**. |
| `pickups/trash_pickup.tscn` | Root node name **`Trash`**. |
| `pickups/trash_can.gd` | Counts deposits; **`_finish_trash_collection()`** disables zone and clears leftover **`trash_pickup`** nodes. |
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

- **`level.tscn`** references some **`PackedScene`** entries **without** **`uid://`** on **`ext_resource`** lines where UIDs were stale (Godot falls back to path; avoids invalid UID warnings).
- **`ConvexPolygonShape2D`** on **`trash_pickup.tscn`** uses **`points`** for the triangle hitbox.

### 2D draw order (`z_index`)

So the **player walks in front of** the trash can (and stays consistent with seed pickups), these values are set:

| Node / scene | `z_index` | Role |
|--------------|-----------|------|
| **`player/player.tscn`** → **`Player`** (root **`CharacterBody2D`**) | **2** | Character + default child sprites sit above **TileMap** (**1**) and **`TrashCan`** (**1**). Matches seed pickup instances (**2**); among ties, tree order (player often added last under **`Level`**) helps draw order vs pickups. |
| **`pickups/trash_can.tscn`** → **`TrashCan`** (root **`Node2D`**) | **1** | Same band as ground décor / **TileMap**. |
| **`pickups/trash_can.tscn`** → **`CanVisual`** (**`Polygon2D`**) | **0** (relative to parent) | Keeps the square on the parent layer (no extra stacking bump). |
| **`level/level.tscn`** → **TileMap** | **1** | |
| Seed / cypress pickups under **`Level`** | **2** | Set on each instance in **`level.tscn`**. |
| **`player/player.tscn`** → **`CarryVisual`**, **`CarryTrashVisual`** | **5** (relative) | Carried icon stays above the robot body. |

---
