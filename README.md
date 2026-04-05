# 2D Platformer (simplified)

This project is a pixel art **Godot 4** 2D platformer based on the [official demo](https://godotengine.org/asset-library/asset/120), trimmed to **platforming only**: no shooting, no enemies, and no collectible coins.

It demonstrates a side-scrolling player with physics, moving platforms, camera limits, pause UI, and optional split-screen. The level also includes **seed pickups**, **soil patches**, single-carry planting (**E** / **`drop_seed`**), on-soil prompts, and short **pickup notifications** — documented in [**CHANGELOG.md**](CHANGELOG.md) under *Seeds, soils, planting, and pickup notifications*.

**Main scene:** `game_singleplayer.tscn` (see `project.godot` → Application → Run).

**Level content:** `level/level.tscn` (tilemap, props, moving platforms).

Language: **GDScript**  
Renderer: **Compatibility** (`gl_compatibility`)

## Features

- **Player** (`CharacterBody2D`): walk, jump, double-jump, slope snapping, camera with level limits.
- **Moving platforms** and static collision from the tilemap.
- **Input:** keyboard, gamepad, and on-screen touch buttons (move / jump).
- **Pause** menu (single-player and split-screen variants).
- **Seeds & soils:** pick up one seed at a time, plant on matching soil (either willow seed on either willow soil; cypress on cypress).
- Pixel art, sound effects, and background music (`music.tscn` autoload).

## What was removed

A full file-by-file list is in [**CHANGELOG.md**](CHANGELOG.md). In short:

- Gun, bullets, and all `shoot` / `shoot_p1` / `shoot_p2` input actions.
- Enemy scenes, scripts, and level placements.
- Coins, coin pickup scene/script, HUD counter, and `coin_collected` wiring.

## Screenshots

![2D Platformer](screenshots/platformer.webp)

## Music

[*Pompy*](https://soundcloud.com/madbr/pompy) by Hubert Lamontagne (madbr)
