# Changelog

This document records simplifications applied to the original Godot 2D platformer demo: removal of combat, enemies, and collectibles.

## Summary

| Area | Removed |
|------|---------|
| Combat | Shooting, bullets, gun node, shoot input actions |
| Enemies | All enemy instances in the level, enemy scene and script |
| Collectibles | All coin pickups, coin counter UI, coin collection flow |

The game remains a playable platformer: movement, jump/double-jump, moving platforms, pause menu, single-player and split-screen entry scenes, camera limits, and audio/visuals for the player and level.

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
| `project.godot` | Description + removed shoot inputs |
| `gui/pause_menu.tscn` | No coins counter |
| `gui/pause_menu.gd` | No coin handler |
| `game_singleplayer.tscn` | No `coin_collected` connection |
| `game_splitscreen.tscn` | No `coin_collected` connections |
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
