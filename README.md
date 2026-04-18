# 2D Platformer (simplified)

This project is a pixel art **Godot 4** 2D platformer based on the [official demo](https://godotengine.org/asset-library/asset/120), trimmed to **platforming only**: no shooting, no enemies, and no collectible coins.

It demonstrates a side-scrolling player with physics, moving platforms, camera limits, pause UI, and optional split-screen. The level adds **seeds**, **soils**, **growth placeholders**, **trash** pickups and a **trash can**, and HUD text styled with the pause menu font — all summarized below and **fully documented in [CHANGELOG.md](CHANGELOG.md)** (including a [documentation map](CHANGELOG.md#documentation-map) and section index).

**Main scene:** `game_singleplayer.tscn` (see `project.godot` → Application → Run).

**Single-player start:** player spawn **`(-170, 546)`** under **`Level`**; horizontal camera bounds are set in **`level/level.gd`** (**`LIMIT_LEFT` −1200**, **`LIMIT_RIGHT` 2200**) so the **`Camera2D`** can follow the full width of the map. See [CHANGELOG — Single-player spawn and camera scroll limits](CHANGELOG.md#single-player-spawn-and-camera-scroll-limits).

**Level content:** `level/level.tscn` (tilemap, props, moving platforms, pickups, soils, trash, two **`TrashCan`** instances, three **`Trash`** pickups, brown **`FinishLine`** marker for the goal). **Optional second scene:** `level/level_2.tscn` (duplicate layout; not loaded by default — see [CHANGELOG — Level and tileset revisions](CHANGELOG.md#level-and-tileset-revisions-editor)). **Level script:** `level/level.gd` (camera limits, **`game_level`** group, willow-seed-2 drop helper).

Language: **GDScript**  
Renderer: **Compatibility** (`gl_compatibility`)

## Features

- **Player** (`CharacterBody2D`): walk, jump, double-jump, slope snapping, camera with level limits; **`z_index`** tuned so the character draws above the trash can and tilemap (see **Technical notes → 2D draw order** in [CHANGELOG.md](CHANGELOG.md)).
- **Moving platforms** and static collision from the tilemap.
- **Input:** keyboard, gamepad, and on-screen touch buttons (move / jump). **Interact / plant / pick up / drop trash:** **`drop_seed`** (and **`drop_seed_p1`** / **`drop_seed_p2`** in split-screen) — table under *Seeds, soils… → Input* in [CHANGELOG.md](CHANGELOG.md).
- **Pause** menu (single-player and split-screen variants); **Label** / **Button** text uses **`gui/theme.tres`** (Kenney font + black outline).
- **Seeds & soils:** **manual** pickup (overlap + **`drop_seed*`**), single carry, plant on matching soil (either willow seed on either willow soil; cypress on cypress). After planting, a short **growth** animation ends in a pink placeholder; **tree name** labels when standing on the placeholder. **Willow seed 2** is hidden until the first **willow #1** plant finishes growing on **either** willow soil, then it **falls** near that patch.
- **Trash:** three red **triangle** pickups in the main level; **two trash cans** (`pickups/trash_can.tscn`) accept deposits with the same **`drop_seed*`** action; when a can reaches its **`pieces_required`** count, leftover pickups are cleared and the **can stays visible** — [CHANGELOG — Trash and trash can](CHANGELOG.md#trash-and-trash-can) and [Level and tileset revisions](CHANGELOG.md#level-and-tileset-revisions-editor).
- **Pickup notifications** bottom banner (`PickupNotifications` autoload + `gui/pickup_notifications.gd`).
- Pixel art, sound effects, and background music (`music.tscn` autoload).

## Documentation

| Need | Read |
|------|------|
| Overview + this list | **README.md** (this file) |
| Every design choice, file roles, verify steps, **`z_index`**, tween gotchas | **[CHANGELOG.md](CHANGELOG.md)** |
| Key bindings, autoload list | **`project.godot`** |

## What was removed

A full file-by-file list is in [**CHANGELOG.md**](CHANGELOG.md). In short:

- Gun, bullets, and all `shoot` / `shoot_p1` / `shoot_p2` input actions.
- Enemy scenes, scripts, and level placements.
- Coins, coin pickup scene/script, HUD counter, and `coin_collected` wiring.

## Screenshots

![2D Platformer](screenshots/platformer.webp)

## Music

[*Pompy*](https://soundcloud.com/madbr/pompy) by Hubert Lamontagne (madbr)
