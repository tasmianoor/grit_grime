# Changelog

This document records simplifications applied to the original Godot 2D platformer demo: removal of combat, enemies, and collectibles.

## Summary

| Area | Removed |
|------|---------|
| Combat | Shooting, bullets, gun node, shoot input actions |
| Enemies | All enemy instances in the level, enemy scene and script |
| Collectibles | All coin pickups, coin counter UI, coin collection flow |
| Display | Viewport **800×480** → **960×540** (16:9); window override **1600×960** → **1920×1080**; stretch **`mode=canvas_items`**, **`aspect=keep`** (uniform scale; letterbox/pillarbox on non–16:9; logical viewport stays 16:9). Earlier fork step used **`aspect=expand`** (fill window, no black bars). |

The game remains a playable platformer: movement, jump/double-jump, moving platforms, pause menu, single-player entry scenes, camera limits, and audio/visuals for the player and level.

**Later additions** (see sections below): soil **growth placeholder** + tree labels; **willow seed 2** gated drop; **trash / trash can** (sprite-based trash, seven pickups, carry sizing, can completion without global trash wipe); **manual** seed & trash pickup (**E** / **`drop_seed*`**); shared **theme** font + **text outline**; **`level.gd`** orchestration for seed 2; **2D `z_index`** so the player draws in front of the trash can; **level / tilemap editor pass** (wider map, décor visibility, **`FinishLine`** marker, **`level_2.tscn`**) under [Level and tileset revisions](#level-and-tileset-revisions-editor); **single-player spawn** and **wider horizontal camera limits** under [Single-player spawn and camera scroll limits](#single-player-spawn-and-camera-scroll-limits); **Lawrence** hero, **Memphis** music and skyline, and **single-player scene cleanup** under [Lawrence hero, Memphis pass, and music (2026-04-18)](#lawrence-hero-memphis-pass-and-music-2026-04-18); follow-up **Lawrence animation timing/jump sources**, **single-player transform fix**, and **hidden platform collision gating** under [Lawrence animation follow-up and hidden platform collisions (2026-04-19)](#lawrence-animation-follow-up-and-hidden-platform-collisions-2026-04-19); **trash art, carry scale, Memphis loop, decor vines, and climb placeholders** under [Trash art, carry scale, Memphis loop, and decor vines (2026-04-19)](#trash-art-carry-scale-memphis-loop-and-decor-vines-2026-04-19); **Grass/Vine climb**, **`move_up` / `move_down`**, **trash can sprite**, and related **level** tweaks under [Grass/Vine climb, trash can art, and inputs (2026-04-19)](#grassvine-climb-trash-can-art-and-inputs-2026-04-19); **per-player score**, **world `+N points` / hint toasts**, **soil UX** (no standing “plant here” label; wrong-family seed message), and **parallax sun (behind clouds)** under [Score HUD, world points popups, soil feedback, and sun overlay (2026-04-19)](#score-hud-world-points-popups-soil-feedback-and-sun-overlay-2026-04-19); **level time-direction plant growth** (right grows / left rewinds until maturity lock) under [Level time-direction plant growth and maturity lock (2026-04-20)](#level-time-direction-plant-growth-and-maturity-lock-2026-04-20); **`FinishLine` visual swap** to animated **Feena idle** frames with Lawrence-matched idle cadence under [Finish marker Feena idle swap (2026-04-20)](#finish-marker-feena-idle-swap-2026-04-20); **level complete UI**, **world map hub**, **`GameLevel`** scoring exports, and **Feena talk-to-finish** under [Level complete screen, world map, and Feena goal (2026-04-27)](#level-complete-screen-world-map-and-feena-goal-2026-04-27); **pickup proximity glow** (seeds/trash) and **soil “patch of soil” hint** (carrying a seed) under [Pickup glow and soil proximity hint (2026-04-27)](#pickup-glow-and-soil-proximity-hint-2026-04-27); **riverfront wildlife sprite library** (Cardinal, Heron, Kingfisher, Sparrow, Woodpecker — idle / fly / hop / pickup frames) and the **per-animation subfolder reorg** under [Riverfront wildlife bird sprites (2026-05-09)](#riverfront-wildlife-bird-sprites-2026-05-09); a **smog-cluster placeholder set** (`smog_1/` with `_a / _b / _c` variants) seeded from cloud art under [Smog backdrop placeholders (2026-05-09)](#smog-backdrop-placeholders-2026-05-09); **foreground smog**, **tree-count smog fade**, **Feena sad / idle + cough line**, and related wiring under [Memphis foreground smog, tree-driven fade, and Feena mood (2026-05-09)](#memphis-foreground-smog-tree-driven-fade-and-feena-mood-2026-05-09); **root-level cloud WebP copies** under [Root-level cloud WebP placeholders (2026-05-09)](#root-level-cloud-webp-placeholders-2026-05-09); **river atlas (`rivertile`)** on **`sources/21`** and **Level 2 river tile paint** under [River tile atlas and Level 2 Memphis river paint (2026-05-09)](#river-tile-atlas-and-level-2-memphis-river-paint-2026-05-09); **Cypress roots** (visual growth strip), **TileMap runtime river-floor polygons** under those roots, **river fall + splash UI**, **trash-on-water bob**, and **draw-order / script hygiene** under [Cypress roots, river bridge, river splash, and z-order (2026-05-09)](#cypress-roots-river-bridge-river-splash-and-z-order-2026-05-09); **ambient sparrow + kingfisher** (runtime spawn, river landing helpers, draw order vs. roots) and **returning blue heron** (full smog fade + no litter left on river tiles) under [Riverfront sparrow and kingfisher ambient (2026-05-10)](#riverfront-sparrow-and-kingfisher-ambient-2026-05-10); **trash cans / Feena / scoring cap** under [Trash cans, Feena interact, and scoring cap (2026-05-10)](#trash-cans-feena-interact-and-scoring-cap-2026-05-10); **Memphis Riverfront mission checklist HUD**, **no floating score toasts** on that level, **level-complete points line hidden** (superseded by the **no-score** overlay in [Level complete UX, Memphis completion stars, and hub map (2026-05-10)](#level-complete-ux-memphis-completion-stars-and-hub-map-2026-05-10)), **Feena hint stacking vs cough**, **Feena-adjacent mature willow trunk climb + canopy jump**, and **Level 2 / legacy scene tweaks** under [Memphis mission HUD, Feena-adjacent willow climb, and UI polish (2026-05-10)](#memphis-mission-hud-feena-adjacent-willow-climb-and-ui-polish-2026-05-10); **level-complete star ratings, Memphis captions, Continue gating, and `map/map.tscn` hub** under [Level complete UX, Memphis completion stars, and hub map (2026-05-10)](#level-complete-ux-memphis-completion-stars-and-hub-map-2026-05-10); **Level 2 lift cab, static cable, full `tiles.webp` collision, and backdrop `z_index`** under [Level 2 lift cab, cable, tiles collision, and backdrop depth (2026-05-12)](#level-2-lift-cab-cable-tiles-collision-and-backdrop-depth-2026-05-12); **Level 2 Beale** **Bruno** finish interact, **AC** façade hold-to-upgrade (**old→new**), foreground **tree/bush** **`z_index`**, **`T9`** depth sort vs player, **`BagProp`** under [Level 2 Beale: Bruno finish, AC façade upgrade, foreground decor, bag prop (2026-05-11)](#level-2-beale-bruno-finish-ac-façade-upgrade-foreground-decor-bag-prop-2026-05-11); **Level 2 post-interaction celebration** (all **AC** upgrades + all **Pink/Yellow/Green** roof stamps → floating **mnotes**, then **van**; **`z_index`** matches **Lawrence** vs **`tree_depth_vs_player`**) under [Level 2 post-interaction celebration (2026-05-11)](#level-2-post-interaction-celebration-2026-05-11); **Level 2 Beale mission HUD** (**`gui/level2_mission_goals.gd`**, **`score_hud`**, **`points_popup`**, **`use_memphis_mission_hud`**, **Christie** performance gold line) under [Level 2 Beale mission HUD, strike logic, and Christie (2026-05-11)](#level-2-beale-mission-hud-strike-logic-and-christie-2026-05-11).

---

## Level 2 post-interaction celebration (2026-05-11)

**Goal:** After **Level 2** roof work and **AC** interact goals are complete, run a short scripted beat: **money-note** billboards drift across the **full level scroll bounds**, then (once **Lawrence** is on the floor and an extra pause) a **van** crosses the street.

**Gates (both required, once):**

1. **AC:** Every node in group **`ac_old_unit`** must report **`is_ac_upgrade_complete()`** `true` (three instances on **`Buildings`** in **`level 2/level_2.tscn`**).
2. **Roofs:** **`BStreet`** sprite script **`bstreet_roof_reveal.gd`** tracks **`BuildingPink`**, **`BuildingYellow`**, and **`BuildingGreen`**: each must have received **at least one** valid mask stamp while the player’s feet were on that roof (same physics layer **16** strip as before). **`are_all_roofs_complete()`** is `true` only when all three keys are set.

**AC gate implementation:** **`_all_ac_upgrades_done`** delegates to **`gui/level2_mission_goals.gd`** **`ac_upgrades_all_complete`** (same helper as the **Level 2** mission HUD checklist row **2**; see **[Level 2 Beale mission HUD, strike logic, and Christie (2026-05-11)](#level-2-beale-mission-hud-strike-logic-and-christie-2026-05-11)**).

**Orchestrator:** **`level 2/post_interaction_celebration.gd`** on **`PostInteractionDirector`** (**`Node`**, child of **`Level 2`** in **`level 2/level_2.tscn`**). **`_physics_process`** polls gates, then runs **`_run_sequence`** deferred (runs once).

**Floating notes:**

- **Four** **`Sprite2D`** wrappers under a **`Node2D`** on the level root; textures **`1@2x` … `4@2x`** from **`level 2/props/mnotes/`**.
- **Height:** uniform scale from **`note_height_px`** (default **32** world px tall per texture).
- **Area:** motion uses **`level 2/level.gd`** scroll limits **`LIMIT_LEFT` / `TOP` / `RIGHT` / `BOTTOM`** (duplicated as floats in the script) minus **`_NOTE_BOUNDS_PAD`**; Lissajous-style paths so notes wander the **whole** bounds (not camera-centered).
- **Persistence:** notes are **not** removed after the initial **3 s** gate timer; they keep animating for the rest of the run.
- **Layering:** note holder **`z_index = 24`**.

**Timing after gates:**

1. **`_NOTE_FLOAT_SEC`** (**3 s**): notes already spawned; sequence waits, then continues.
2. **`_wait_lawrence_grounded_then_van_delay`:** loop until **`Player`** **`is_on_floor()`**, then **`_GROUND_THEN_VAN_DELAY_SEC`** (**3 s**). The **3 s before the van** starts **after** Lawrence lands (if already grounded, the wait is just the **3 s**).
3. **`_van_phase`:** **`Sprite2D`** on level root; frames **`level 2/props/van/van 1.png`**, **`van2`–`van5`**; **`Timer`** advances frames; **`Tween`** on **`global_position`**.

**Van path (world space, not viewport center):**

- Hold / midpoint **X** = **`(_LEVEL_LIMIT_LEFT + _LEVEL_LIMIT_RIGHT) * 0.5`** (**500** with current limits **−1200 … 2200**), i.e. middle of the **authored scroll span**, not **`Camera2D`** center.
- **Y** from **`van_lane_y`** (export, default **558**).
- Start **`mid_x - van_enter_offset_x`**, exit **`mid_x + van_exit_extra_x`** (exports **1050** / **1300**).

**Van size:** **`van_height_px`** (default **170**) sets uniform scale from each frame’s texture height (re-applied on frame change).

**Van vs trees / Lawrence:** **`z_as_relative = true`**, **`z_index = _VAN_SORT_Z_MATCH_PLAYER`** (**5**), matching **`player/player.tscn`** **`Player`** root so **`tree_depth_vs_player.gd`** trees (**absolute** **4** / **10**) sort the van like Lawrence.

**`ac_old_unit.gd`:** **`add_to_group("ac_old_unit")`** in **`_ready`**; public **`is_ac_upgrade_complete() -> bool`**.

### Files touched

| Path | Change |
|------|--------|
| **`level 2/post_interaction_celebration.gd`** | New orchestrator: gates, notes, delays, van tweens + frame cycle, level mid-**X**, exports. |
| **`level 2/post_interaction_celebration.gd.uid`** | Godot script UID (generated when the editor imports the script). |
| **`level 2/bstreet_roof_reveal.gd`** | **`_roof_stamp_done`**, **`are_all_roofs_complete()`**, **`_feet_on_target_roof_building()`**; stamp path records which colored roof was active. |
| **`level 2/props/ACs/ac_old_unit.gd`** | Group **`ac_old_unit`**; **`is_ac_upgrade_complete()`**. |
| **`level 2/level_2.tscn`** | **`PostInteractionDirector`** node + **`ext_resource`** to **`post_interaction_celebration.gd`**. |
| **`CHANGELOG.md`**, **`docs/PROJECT_CHANGES.md`** | This documentation. |

---

## Level 2 Beale mission HUD, strike logic, and Christie (2026-05-11)

**Goal:** On **Level 2 (Beale)**, replace the top-right **Points** strip with the same **collapsible mission panel** shell as **Memphis Level 1**, but with **Beale** copy, **Level-2-specific** checklist completion rules, and a **gold congrats line** tied to **Christie’s** performance instead of “all three strikes.”

### HUD wiring

| Piece | Detail |
|--------|--------|
| **Opt-in** | **`level 2/level.gd`** — **`@export var use_memphis_mission_hud`** (default **`false`**). **`level 2/level_2.tscn`** sets it **`true`** so **`level_display_name`** can stay **Level 2** for the level-complete heading. |
| **Detection** | **`gui/score_hud.gd`** — **`_uses_memphis_mission_hud`**: Memphis when **`level_display_name`** matches **`memphis_mission_goals.display_name()`**, or when **`use_memphis_mission_hud`** is true. **`_level2_mission_hud_variant`**: Beale copy when the export is on **and** the level is **not** Memphis by name (so L1 still uses **`memphis_mission_goals.gd`** only). |
| **World toasts** | **`gui/points_popup.gd`** — **`_hide_point_popups_for_player`** also returns true when **`use_memphis_mission_hud`** is set (in addition to **Mississippi Riverbank**), suppressing **`+points`** floats on Beale. |

### Beale copy (same panel chrome as L1)

| UI string | Value |
|-----------|--------|
| **Header** | **Beale back to life** |
| **Lines** | **1.** Weatherize rooftops to beat the heat · **2.** Change to energy efficient ACs · **3.** Bring back monarch butterflies |
| **Gold line** | **You brought Christie back to life! Now go to Bruno** (BBCode gold **`#FDBA21`**) |

### Strike-through: **`gui/level2_mission_goals.gd`**

**`score_hud`** loads this script as **`_level2_goals_script`** and, when **`_level2_mission_hud_variant`** is true, refreshes the three rows from:

| Row | **`level2_mission_goals`** | Done when |
|-----|---------------------------|-----------|
| 1 | **`roofs_weatherized_complete(gl)`** | **`gl`** has child **`BStreet`** with **`are_all_roofs_complete()`** from **`bstreet_roof_reveal.gd`** (≥1 valid mask stamp on **BuildingPink**, **BuildingGreen**, **BuildingYellow** while feet on roof layer **16**). |
| 2 | **`ac_upgrades_all_complete(tree)`** | Every node in **`ac_old_unit`** implements **`is_ac_upgrade_complete()`** and returns **`true`**. |
| 3 | **`monarch_butterflies_present(tree)`** | **`SceneTree`** has ≥1 node in group **`level2_monarch_butterfly`**. **`level 2/props/butterfly/level2_butterfly.gd`** joins that group in **`_ready`** (runtime) so spawned butterflies count. |

### Gold line vs checklist (Level 2 only)

- **Checklist strikes** still use the three rules above.
- **Gold line visibility** uses **`christie_performance_complete(tree)`** — true if any node is in group **`christie_performance_complete`**.
- **`level 2/props/Christie/level2_christie_npc.gd`**: after **`_PLAY_HOLDS_BEFORE_PERFORMANCE_COMPLETE`** (**8**) **`PLAY`**-phase holds at **`_PLAY_FRAME_SEC`**, sets **`_christie_performance_reported`** and **`add_to_group(&"christie_performance_complete")`** once. **`begin_walk_sequence`** resets the flag.

### Christie walk / idle timing

- **`_CHRISTIE_ANIM_TIMING_MULT`** (**1.5**) multiplies **`_WALK_FRAME_SEC`** and **`_PLAY_FRAME_SEC`** (slower walk and play idle).

### Post-interaction celebration (shared AC helper)

- **`level 2/post_interaction_celebration.gd`** — **`const _LEVEL2_MISSION_GOALS: GDScript = preload("res://gui/level2_mission_goals.gd")`**; **`_all_ac_upgrades_done`** calls **`ac_upgrades_all_complete`** so the **AC** gate matches the HUD and **`level2_mission_goals`** stays single-source. (Use a typed **`preload`** assignment for **`const`**; **`as GDScript`** on the right-hand side is **not** a constant expression in GDScript.)

### Files touched (this feature)

| Path | Change |
|------|--------|
| **`gui/level2_mission_goals.gd`** | New: L2 roof / AC / butterfly / Christie-complete queries. |
| **`gui/level2_mission_goals.gd.uid`** | Editor UID (after import). |
| **`gui/score_hud.gd`** | Beale strings; **`_level2_mission_hud_variant`**; **`show_congrats`** branch for L2 vs Memphis; load **`level2_mission_goals`**. |
| **`gui/points_popup.gd`** | Hide floats when **`use_memphis_mission_hud`**. |
| **`level 2/level.gd`** | **`use_memphis_mission_hud`** export + doc comment. |
| **`level 2/level_2.tscn`** | **`use_memphis_mission_hud = true`**. |
| **`level 2/props/Christie/level2_christie_npc.gd`** | Timing mult; PLAY completion → **`christie_performance_complete`** group. |
| **`level 2/props/butterfly/level2_butterfly.gd`** | **`level2_monarch_butterfly`** group. |
| **`level 2/post_interaction_celebration.gd`** | Delegates AC gate to **`level2_mission_goals`**. |

### Related working-tree items (same branch; see `git status`)

**Finish NPC rename:** **`paulo_goal.gd`** removed; **`level 2/bruno_goal.gd`** drives **`FinishLine`**; **Paulo** art removed under **`level 2/props/Paulo/`**; **Bruno** sprites under **`level 2/props/Bruno/`**. **Planters / bag / van handoff / pickup strip:** **`level 2/props/planters/`**, **`planter_butterfly_coordinator.gd`**, **`bag_prop`**, **`player/player.gd`** bag outfit and **`Lawrence/bag_*`** frames, **`pickup_notifications.gd`**, **`ac_old_unit.gd`** / **`bstreet_roof_reveal.gd`** blocked hints — cross-reference **[Level 2 planters, bag-gated interactions, pickup strip](#level-2-planters-bag-gated-interactions-pickup-strip-2026-05-11)** and **[Level 2 Beale: Bruno finish…](#level-2-beale-bruno-finish-ac-façade-upgrade-foreground-decor-bag-prop-2026-05-11)**. **Assets:** **`roadtile.png`**, **`van*.png`**, optional **`BStreet copy.png`** (duplicate; do not commit per **`docs/PROJECT_CHANGES.md`**).

---

## Display stretch keep and map hub Level 2 button (2026-05-11)

**Display:** In **`project.godot`**, **`window/stretch/aspect`** is **`keep`** (was **`expand`**). The logical viewport remains **960×540 (16:9)** with **`window/stretch/mode="canvas_items"`**; the game **scales uniformly** to fit the window and uses **letterboxing or pillarboxing** when the physical window is not 16:9, instead of **expanding** the root viewport to fill the window.

**Map hub:** **`BealeStreetButton`** was removed from **`map/map.tscn`** (it had no **`pressed`** scene connection). **`Level2Button`** now uses the same **`StyleBoxFlat`** card theme and **Beale Street** label as that control; **`map/map.gd`** auto-places **`Level2Button`** at **`BEALE_MAP_UV`**, applies the same **glyph spacing** and **hover outline** behavior as **Memphis Riverfront** and **Memphis Aquifer**, and **`Level2Button`** still opens **`res://game_level_2.tscn`** via **`_on_level_2_pressed`**. The unused transparent **`StyleBoxEmpty`** subresource was removed from **`map/map.tscn`**.

### Files touched

| Path | Change |
|------|--------|
| **`project.godot`** | **`window/stretch/aspect="keep"`**. |
| **`map/map.tscn`** | **`Level2Button`** card styling + **Beale Street** text; **`BealeStreetButton`** node removed; empty style subresource removed. |
| **`map/map.gd`** | **`_layout_map_buttons()`** includes **`Level2Button`** at **`BEALE_MAP_UV`**; letter-spacing and hover-outline **`map_buttons`** lists use **`Level2Button`** instead of **`BealeStreetButton`**; **`_beale_street_button`** **`@onready`** removed. |

---

## Level 2 Beale layout: B Street layer, buildings, road physics, vertical platform (2026-05-11)

**Scene composition:** **`BStreet.png`** is no longer a child of the Level 2 parallax scene; it is a **`Sprite2D`** on the **`level 2/level_2.tscn`** root (with authored **`z_index`** so it sits behind gameplay but in front of the parallax rig). **`Buildings`** adds colored façades plus **`Artboard 2.png`**; each walkable building uses **`StaticBody2D`** + **`building_static_body.gd`**, which sizes a **`RectangleShape2D`** to the **top quarter** of the visible sprite (roof ledge), **`collision_layer = 16`**, and clears collision when the body is hidden.

**Climb:** **`BuildingBrown`** exposes **`BuildingBrownClimbCap`** (invisible **`Sprite2D`** strip aligned to the brown texture’s top quarter). **`level 2/level.gd`** adds that node to **`vine_climb`** so the player can climb it like vines.

**TileMap / props:** **`level 2/tileset.tres`** gives **`roadtile.png`** atlas tile alternatives **0–7** floor polygons on **`physics_layer_0`** (walkable road paint). Foliage props use higher **`z_index`** for depth while **pickups, trash, trash cans, and soils** use **`z_index = 5`** so they stay above grass; positions were moved with the expanded street layout.

**Moving platform:** **`level/platforms/moving_platform.gd`** adds **`@export var drive_animation_with_player_velocity`** (default **true**; Level 2 instances set **false** so vertical motion does not scrub from walk speed) and **`@export var one_way_collision`** (Level 2 sets **false** for reliable floor contact on a vertical mover). **`AnimationPlayer`** on Level 2 platforms uses **`callback_mode_process = 1`** (physics). The **`move`** clip keys **only** `t = 0, 2, 4` with **matching first and last `position`** so the loop has **no Y seam** (avoids bottom “snap”); the old **`t = 0.001`** spike key was removed.

**Prefab:** **`level 2/platforms/platform.tscn`** uses **`res://level/platforms/moving_platform.gd`**, **`z_index = -1`** on the body, and optional decorative child sprites (grass / bush / vine) for the Beale platform look.

### Files touched

| Path | Change |
|------|--------|
| **`level 2/background/parallax_background_level2.tscn`** | Removed **`BStreet`** sprite and its texture **`ext_resource`**. |
| **`level 2/level_2.tscn`** | **`BStreet`** + **`Buildings`** subtree, tile paint, **`z_index`** / positions for gameplay props, **`Platform`** / **`Platform2`** exports and **`AnimationPlayer`** process mode, seamless **`move`** animation. |
| **`level 2/level.gd`** | Registers **`Buildings/BuildingBrown/BuildingBrownClimbCap`** with **`vine_climb`**. |
| **`level 2/tileset.tres`** | **`roadtile`** physics polygons per alternative. |
| **`level 2/platforms/platform.tscn`** | Level 2 art stack + shared **`moving_platform.gd`**. |
| **`level/platforms/moving_platform.gd`** | Player-driven vs autoplay animation; **`one_way_collision`** applied in **`_ready`**. |
| **`level 2/props/buildings/`** (untracked until committed) | **`building_static_body.gd`**, building PNGs, **`Artboard 2.png`**. |

---

## Level 2 lift cab, cable, tiles collision, and backdrop depth (2026-05-12)

**Backdrop:** The large root **`Sprite2D`** sky uses **`z_index = -2`** so it sits **behind** **`BStreet`** (**`-1`**) and the rest of the level.

**`tiles.webp` tileset:** **`level 2/tileset.tres`** — all **`tiles.webp`** atlas tiles that previously had **no** collision now use **`physics_layer_0`** **full 64×64** quads (including flipped/transposed alternatives). Previously **thin-strip** collision on two atlases was expanded to **full tile** coverage; **one-way** collision was removed from the **slope** atlas (**`pxbka`**) so those tiles are **solid** from every direction.

**Beale moving lift:** **`level 2/platforms/platform.tscn`** — deck art is **`res://level 2/props/lift/top.png`**, with **`z_as_relative = false`** and **`z_index = 6`** so the deck draws **above** the player. **`body.png`** is **not** parented to the **`AnimatableBody2D`**. **`level 2/level_2.tscn`** adds **`Platforms/PlatformLiftBody`** (**`Sprite2D`**) at a **fixed** world position with **`z_index = 4`** (**behind** the player). **`Platforms/PlatformLiftCable`** is a **`Node2D`** running **`lift_cable_line.gd`**, which drives two **`Line2D`** nodes: **outline** **`#291b0a`**, **width 14**; **fill** **`#E59424`**, **width 12** (1 px outline ring around a 12 px stroke). The polyline updates each frame from the **underside of the animated top** to the **top of the static cab**. The **`move`** **`AnimationPlayer`** **position** keys must use the **same `x`** as **`Platform.position.x`** and **`PlatformLiftBody.position.x`** (e.g. **`300.2617`**); otherwise the platform snaps horizontally off the cab.

### Files touched (this batch)

| Path | Change |
|------|--------|
| **`level 2/tileset.tres`** | **`tiles.webp`** collision completeness; full-tile quads; slope **one-way** removed; strip atlases widened to full cell. |
| **`level 2/platforms/platform.tscn`** | **`top.png`** deck; **`z_index`** layering; **`body`** removed from prefab. |
| **`level 2/level_2.tscn`** | Backdrop **`z_index`**; **`PlatformLiftBody`**, **`PlatformLiftCable`** + children; **`ext_resource`** for **`body.png`** and **`lift_cable_line.gd`**; **`move`** keys aligned with platform/cab **X**. |
| **`level 2/props/lift/lift_cable_line.gd`** (+ **`.uid`**) | **`Node2D`** script updating **`Outline`** / **`Fill`** **`Line2D`** segments. |
| **`level 2/props/lift/top.png`**, **`body.png`**, **`arm.png`** (+ **`.import`**) | Lift textures (deck, cab, spare arm art). |
| **`CHANGELOG.md`**, **`docs/PROJECT_CHANGES.md`** | Session documentation. |

---

## Level 2 Beale: Bruno finish, AC façade upgrade, foreground decor, bag prop (2026-05-11)

**Bruno (Level 2 exit):** **`level 2/level_2.tscn`** adds **`FinishLine`** (**`Node2D`**) with **`level 2/bruno_goal.gd`** and child **`Square`** (**`Sprite2D`**, `centered = false`). Same interaction contract as Feena: proximity + **`drop_seed` + `action_suffix`**, skip while **`Player.is_holding_trash()`**, calls **`game_controller.present_level_complete()`**. Hint **“Talk to Bruno”** uses **`top_level`** and fixed theme font overrides so it does not scale with Bruno. Sprite height targets **Lawrence’s on-screen `Sprite2D` AABB height** (so **`game_level_2.tscn`** Player root scale is included), then **`_BRUNO_HEIGHT_VS_LAWRENCE`** (default **1.25**) so Bruno reads taller; **`call_deferred`** reapplies after the player exists. Animation: **wipe** frames **`wipe1`–`wipe6`** loop **4×**, then **idle** **`idle1`–`idle4`** once, repeat; timings multiplied by **`_SPRITE_TRANSITION_SLOWDOWN`** (**1.6** = **60% slower** transitions). **`_apply_bruno_sprite_visual()`** runs before the editor early-return so Bruno is visible in the **2D editor**.

**Old / new AC façades:** **`level 2/props/ACs/ac_old_unit.tscn`** instances (**`PackedScene` `uid://cvmh7acoldu2`**) replace standalone old-AC sprites under **`Buildings`** (**Pink / Green / Yellow`** placements preserved; Green sets **`flip_old_sprite`**). Each unit: **`OldSprite`** / **`NewSprite`** (**`AnimatedTexture`** over **`props/ACs/old/old_ac*.png`** and **`props/ACs/new/new_ac*.png`**), **`InteractArea`** (**`Area2D`**, **`collision_mask = 1`**) + **`RectangleShape2D`** (**`250×175`**, center **`(30, 18)`** vs the **61×37** art), **`LoadWheel`** (**`Control`**, **`ac_old_load_wheel.gd`**, **`class_name AcOldLoadWheel`**) draws a **circular hold-progress** ring. While a **player** overlaps and **holds** **`drop_seed*`**, progress fills over **`hold_duration_sec`** (default **2.25** s); **release** or **leave range** clears progress and **hides** the wheel; **re-hold** restarts from **0%**; at **100%** the old sprite hides, **new** loop shows, area stops monitoring. Scripts: **`ac_old_unit.gd`**, **`ac_old_load_wheel.gd`** (+ **`.uid`** sidecars).

**Foreground décor:** **`level 2/level_2.tscn`** — **`Trees/T8`**, **`T9`**, **`Bushes/B17`**, **`B31`**, **`B32`**: **`z_as_relative = false`**, **`z_index = 10`** so they draw in front of the player (**`5`**). **`T9`** uses **`level 2/props/tree_depth_vs_player.gd`**: compares nearest player’s **`y`** to the sprite’s **world bottom**; **north** of that line → tree **`z_index = 10`** (walk **behind** canopy); **south** → **`z_index = 4`** (in front).

**Bag:** **`BagProp`** **`Sprite2D`** on **`level 2/level_2.tscn`** root uses **`level 2/props/bag/bag.png`** (decoration).

### Files touched (this batch)

| Path | Role |
|------|------|
| **`level 2/bruno_goal.gd`**, **`level 2/bruno_goal.gd.uid`** | Bruno goal: hint, interact, wipe/idle animation, Lawrence-relative height, editor sprite setup. |
| **`level 2/props/tree_depth_vs_player.gd`**, **`.uid`** | **`T9`** Y-sort vs player for behind/in-front. |
| **`level 2/props/ACs/ac_old_unit.tscn`**, **`.uid`** | Packed AC unit: old/new **`AnimatedTexture`**, **`Area2D`**, load wheel. |
| **`level 2/props/ACs/ac_old_unit.gd`**, **`.uid`** | Hold **`drop_seed*`** logic, completion swap. |
| **`level 2/props/ACs/ac_old_load_wheel.gd`**, **`.uid`** | Circular progress **`Control`** drawing. |
| **`level 2/level_2.tscn`** | **`FinishLine` / Bruno**; **`BagProp`**; **AC** instances (**`ExtResource` `ac_old_unit.tscn`**); **T8/T9/B17/B31/B32** **`z_index`**; **`T9`** script ref; removed inlined **Old AC** textures / subresource in favor of the AC scene. |
| **`level 2/props/ACs/old/*.png`**, **`new/*.png`** (+ **`.import`**) | AC animation sources (authored assets). |

---

## Level 2 planters, bag-gated interactions, pickup strip (2026-05-11)

**Finish line draw order:** **`level 2/level_2.tscn`** — **`FinishLine`** **`z_index = 4`** so the goal square draws **behind** the player (**`z_index = 5`**).

**Bag outfit (PNG):** **`player/player.gd`** preloads **`Lawrence/bag_idle/bag_idle.png`**, **`Lawrence/bag_walk/bag_walk.png`**, **`Lawrence/bag_jump/bag_jump.png`** (replacing prior JPEG paths). **`has_lawrence_bag_outfit_active()`** returns true when the current idle texture is the bag idle art.

**AC / roof before bag:** **`level 2/props/ACs/ac_old_unit.gd`** — old-AC hold and wheel only when **`has_lawrence_bag_outfit_active()`**; otherwise a **`CanvasLayer`** (**`layer = 58`**) **`Label`** shows **“Special tools needed to replace old unit”** using **`gui/theme.tres`** (**`font_size = 13`**, **`outline_size = 3`**) to match the Level 1 soil-patch hint style. **`level 2/bstreet_roof_reveal.gd`** — roof stamping only with bag outfit; otherwise the same typography for **“Special tools needed to weatherize building”**; skips players carrying trash (e.g. AC upgrade path).

**Pickup strip (bag + planter):** **`gui/pickup_notifications.gd`** — **`show_pickup_line(line: String)`** reuses the same bottom strip + timer as **`show_pickup()`**; bag pickup calls it for **“You picked up Bruno’s bag of tools”**. **`level 2/props/planters/planter_carry_pickup.gd`** calls **`show_pickup("planter.")`** → **“You picked up a planter.”** (same strip as seeds).

**Van → planters:** **`level 2/post_interaction_celebration.gd`** — while the van is stopped, two **`planter1.png`** **`Sprite2D`** nodes sit **behind** the van (**lower `z_index`**); when the van leaves, they are removed and **`planter_carry_pickup.tscn`** instances spawn at the saved world positions for Lawrence to pick up.

**Planter pickups / drop zones:** **`level 2/props/planters/planter_carry_pickup.gd`** (+ **`.tscn`**, **`.uid`**) — interact like trash carry but **not** in the **`trash_pickup`** group. **`level 2/props/planters/planter_drop_zone.gd`** (+ **`.tscn`**, **`.uid`**) — **`Area2D`** with **`PolygonFill`** (**`Polygon2D`**) and convex **`CollisionShape2D`**; proximity label **“Missing plant”** until a carried **`planter1`** texture is **`deposit_trash()`**’d. **`level 2/level_2.tscn`** — **`PlanterDropZone1`** and **`PlanterDropZone2`** instances (placement / skew per zone).

**Carry art offset:** **`player/player.gd`** — **`get_carried_trash_texture()`** / **`_apply_trash_carry_local_position()`**: when the carried texture path contains **`planter1`**, **`CarryTrashVisual`** is shifted **up** (more negative local **`Y`**) so the planter does not cover the face.

**Bruno naming / scene wiring:** **`README.md`**, **`docs/PROJECT_CHANGES.md`**, this file — **Paulo → Bruno** where the Level 2 exit NPC is named. **`level 2/level_2.tscn`** **`FinishLine`** **`ext_resource`** targets **`res://level 2/bruno_goal.gd`** (with script **`.uid`**). **`level 2/props/planters/planter_drop_zone.tscn`** **`ext_resource`** UID matches **`planter_drop_zone.gd.uid`**.

### Files touched (this batch)

| Path | Change |
|------|--------|
| **`player/player.gd`** | Bag **`.png`** preloads; **`has_lawrence_bag_outfit_active()`**; **`get_carried_trash_texture()`**; planter carry **Y** offset; bag **`show_pickup_line`** toast. |
| **`gui/pickup_notifications.gd`** | **`show_pickup_line()`**; shared strip/timer helper. |
| **`level 2/props/ACs/ac_old_unit.gd`** | Bag gate + blocked hint (**CanvasLayer** 58, theme label). |
| **`level 2/bstreet_roof_reveal.gd`** | Bag gate for stamp + roof blocked hint; overlap helpers. |
| **`level 2/post_interaction_celebration.gd`** | Van-stop planter decor; spawn **`planter_carry_pickup`** on van exit. |
| **`level 2/props/planters/planter_carry_pickup.gd`**, **`.tscn`**, **`.uid`** | Planter pickup (no **`trash_pickup`**); planter toast. |
| **`level 2/props/planters/planter_drop_zone.gd`**, **`.tscn`**, **`.uid`** | Polygon fill + deposit + **“Missing plant”** hint. |
| **`level 2/level_2.tscn`** | **`FinishLine`** **`z_index`** + **`bruno_goal.gd`** ref; **`PlanterDropZone1`**, **`PlanterDropZone2`**. |
| **`README.md`**, **`docs/PROJECT_CHANGES.md`**, **`CHANGELOG.md`** | Bruno naming + this session. |

---

## Level complete UX, Memphis completion stars, and hub map (2026-05-10)

End-of-level overlay rework: **no points** row; **heading** **`Level {n}: {display name}`** (from **`level_index`** + **`level_display_name`**); gold **“Level complete!”** (**`#FDBA21`**, matching mission congrats gold); **three-star** row (filled **gold** vs **dark gray** empty); **caption** under stars on **Memphis Riverfront**; **Next Level** (formerly **Continue**) visible only when **star count ≥ 2**; **Go to Map** and **Next Level** (when **`next_level_scene`** is empty) load **`res://map/map.tscn`** — the same interactive level picker as splash / pause quit — instead of **`gui/world_map.tscn`**. Follow-up for **all levels**, Take Action always on, and CTA row layout: [Session update: level complete for all levels, willow seed drops (2026-05-10)](#session-update-level-complete-for-all-levels-willow-seed-drops-2026-05-10).

**`gui/memphis_mission_goals.gd`** (new): shared predicates with the Feena checklist (**trees / all trash / heron**, plus **river-only** vs **ground-only** trash via **`trash_pickup.is_river_tile_trash()`**); **`level1_completion_stars_and_message(tree, gl)`** returns **`{ "stars": 0..3, "message": String }`**. **`game.gd`** reads **`game_level`** with **`.get()`** / **`Variant`** (compatible with **`level 2/level.gd`** roots), **`load()`**-caches the goals **`GDScript`** once (**`class_name Game`** cannot rely on **`const preload`** of sibling globals in strict mode), and calls **`LevelCompleteScreen.present(..., stars_filled, star_feedback)`**.

### Files touched

| Path | Change |
|------|--------|
| **`game.gd`** | **`present_level_complete()`** → Memphis **`level1_completion_stars_and_message`** when title matches goals **`display_name()`**; else **`get_completion_stars_and_message(get_tree())`** on **`game_level`** when implemented; **`_memphis_mission_goals_script_cached()`**; no **`_total_player_score()`** / score args to complete UI. |
| **`gui/level_complete_screen.gd`** | **`present(..., star_feedback)`**; star row + **`StarFeedbackLabel`**; **`NextLevelButton.visible`** from stars (stars **≥ 2**); focus **Next Level** or **Retry**; **`_LEVEL_SELECT_MAP`**. Take Action + resource columns always shown in **`present()`** (see [session update](#session-update-level-complete-for-all-levels-willow-seed-drops-2026-05-10)). |
| **`gui/level_complete_screen.tscn`** | Nodes for heading, complete line, stars, feedback, **Take Action** block, **`PrimaryActionsRow`** (**Retry Level** / **Go to Map** / **Next Level**), spacers; removed legacy title / points row and separate continue row. |
| **`gui/memphis_mission_goals.gd`** | New module (no **`class_name`**): constants + table logic below. |
| **`gui/memphis_mission_goals.gd.uid`** | New UID sidecar. |
| **`gui/score_hud.gd`** | **`load`** goals script in **`_ready`**; **`call("trees_goal_met"`, …)** etc.; Memphis name via **`call("display_name")`**. |
| **`level/level.gd`**, **`level 2/level.gd`** | **`@export var level_index`** after **`level_display_name`**. |
| **`level/level.tscn`**, **`level 2/level.tscn`** | **`level_index = 1`**. |
| **`level/level_2.tscn`**, **`level 2/level_2.tscn`** | **`level_index = 2`**. |
| **`game_level_1.tscn`** | **`level_complete_screen.tscn`** ext_resource **`uid://b4tfglr8tnly7`** (editor consistency). |

### Memphis Level 1 — `level1_completion_stars_and_message` (first match wins)

| Order | Stars | Condition (short) | Caption |
|------:|------:|---------------------|---------|
| 1 | **3** | Trees + all trash + heron | *Our ecosystem is thriving and the beautiful blue heron soars over a fully restored riverfront—all thanks to you!* |
| 2 | **2** | Trees + heron + river clear + ground trash left | *The beautiful blue heron has returned! Clear skies and clean water brought her home.* |
| 3 | **2** | Trees + ground clear + river trash left | *Great job at restoring the park and clearing our air! Our polluted river will need some cleanup.* |
| 4 | **1** | All trash cleared, no trees, no heron | *The park and river are clean, but smog keeps the wildlife away.* |
| 5 | **1** | No trees/heron, river clear, ground trash left | *The river is cleaner, but smog still hangs in the air.* |
| 6 | **1** | No trees/heron, ground clear, river trash left | *The park looks better, but the river and air need attention.* |
| 7 | **1** | Trees + all trash, no heron | Same caption as row **4**. |
| 8 | **1** | Trees, trash not fully cleared (after rows 2–3) | *The air is clearer, but the river still suffers.* |
| 9 | **0** | No trees, no full trash clear, no heron | *The riverfront remains untouched. Memphis needs your grit.* |
| — | **0** | Any other partial state | Same as row **9**. |

Copy uses **`.`** sentence endings where lines had none; **`!`** retained inside sentences.

### `gui/world_map.tscn`

Still in the repo; **level complete** no longer routes here. Hub routing matches **`map/map.tscn`** / **`map/map.gd`** (Level 1 → **`game_singleplayer.tscn`**, Level 2 → **`game_level_2.tscn`**).

---

## Single-player–only build (2026-05-10)

Split-screen multiplayer entry paths were removed as out of scope. **`gui/world_map.tscn`** no longer offers split-screen; **`game_splitscreen.tscn`**, **`game_splitscreen.gd`**, and **`gui/pause_menu_splitscreen.tscn`** are deleted; **`project.godot`** drops **`jump`/`move`/`drop_seed`** mappings suffixed **`_p1`** / **`_p2`** and the **`splitscreen`** action. **`gui/score_hud.gd`** always binds one **`player`** group member for the points strip.

---

## Editor landmarks and Memphis congratulations line (2026-05-10)

| Item | Detail |
|------|--------|
| **`HeronLandingSpot`** / **`KingfisherLandingSpot`** | **`Marker2D`** children of **`Level`** in **`level 2/level.tscn`** (what **`game_level_1`** runs), **`level/level.tscn`**, and **`level/level_2.tscn`**. Adjust in the editor for authored perch positions; script wiring is summarized under [Riverfront sparrow and kingfisher ambient](#riverfront-sparrow-and-kingfisher-ambient-2026-05-10). |
| **Mission checklist** | When all three Memphis goals are complete, the gold line reads **`Nice work! Now find Feena`** (**`#FDBA21`**); see [Memphis mission HUD](#memphis-mission-hud-feena-adjacent-willow-climb-and-ui-polish-2026-05-10). |
| **Cursor rule** | **`.cursor/rules/heron_landing.mdc`** summarizes heron + kingfisher landing marker conventions for agents. |

---

## Trash cans, Feena interact, and scoring cap (2026-05-10)

Trash **deposits** are easier to land near the bin, **Feena** no longer competes for **`drop_seed*`** while you are carrying litter, **per-can quotas are removed**, and the **level-complete max score** counts **trash pickups** instead of summing can **`pieces_required`**.

### Trash cans (`pickups/trash_can.gd`, `pickups/trash_can.tscn`)

| Change | Detail |
|--------|--------|
| **No per-can quota** | Removed **`pieces_required`**, per-can deposit counting, **`_cleared`**, and **`_finish_trash_collection()`**. Cans **do not** disable **`DropZone`** after a fill count; any can accepts a deposit whenever **`Player.deposit_trash()`** succeeds. |
| **Reach** | Proximity fallback uses **`DropZone/CollisionShape2D.global_position`** and **`_DEPOSIT_PROXIMITY_PX` (120)** in addition to **`Area2D`** overlap (`_inside`). |
| **Hitbox** | **`CollisionShape2D`** under **`DropZone`** uses **`position = Vector2(0, 30)`** so overlap sits lower toward the player’s feet. |

### Feena (`level/feena_goal.gd`, `level 2/feena_goal.gd`)

| Change | Detail |
|--------|--------|
| **While holding trash** | **`Player.is_holding_trash()`** → skip **“Talk to Feena”** proximity and **do not** handle **`drop_seed*`** on **`FinishLine`**, so **E** is unambiguous for **deposit** until hands are empty. |

### Scoring (`level/level.gd`, `level 2/level.gd`)

| Change | Detail |
|--------|--------|
| **`get_max_achievable_points()`** | Counts nodes whose script is **`trash_pickup.gd`** (**one** **`Player.POINTS_TRASH_DEPOSIT`** per world litter piece), plus soil patches as before. **`_TRASH_CAN_SCRIPT` / `pieces_required`** summing was removed. |

### Level scenes

| File | Change |
|------|--------|
| **`level/level.tscn`**, **`level/level_2.tscn`**, **`level 2/level.tscn`**, **`level 2/level_2.tscn`** | Removed **`pieces_required`** overrides from **`TrashCan`** / **`TrashCan2`** instances. |

---

## Memphis mission HUD, Feena-adjacent willow climb, and UI polish (2026-05-10)

Memphis Riverfront (**`GameLevel.level_display_name == "Memphis Riverfront"`**) swaps the usual score HUD for a **collapsible “A favor for Feena” checklist**, suppresses **world `+N points`** floats there, and (historically) hid **points** on **level complete** — superseded by the **star + caption** overlay documented in [Level complete UX, Memphis completion stars, and hub map (2026-05-10)](#level-complete-ux-memphis-completion-stars-and-hub-map-2026-05-10). Also separates **Feena’s interact hint** from the **cough** caption when both show, and adds optional **climb geometry + auto-jump** off a designated mature **willow** beside Feena. **`level 2/level.tscn`** picks up editor tile/prop nudges alongside these gameplay/UI scripts.

### Score HUD — Memphis mission box (`gui/score_hud.gd`)

| Piece | Detail |
|------|--------|
| **Detection** | **`get_first_node_in_group("game_level")`** → compare **`level_display_name`** to **`Memphis Riverfront`**; early-outs before score labels. |
| **Widget** | Top-right **`PanelContainer`** with **`StyleBoxFlat`**: fill **`Color("#00235E").darkened(0.68)`** at alpha **0.94**, border **`#00235E`** toned with **`.darkened(0.38)`**, rounded corners, theme margins. |
| **Interaction** | Flat **`Button`** header (**`A favor for Feena` ▼ / ▶**); **`alignment`** uses **`HORIZONTAL_ALIGNMENT_LEFT`**. |
| **Copy** | Three **`RichTextLabel`** checklist rows (**strike** when done); bottom **`Nice work! Now find Feena`** in **`#FDBA21`** visible only when **all three** goals are complete. |
| **Completion** | **`_process`**: (1) **Trees** — **`has_mature_locked_tree()`** count ≥ **`get_soil_drop_zone_count()`**. (2) **Trash** — no **`trash_pickup`** nodes. (3) **Heron** — **`heron_spawned`** group. **`_memphis_apply_outer_rect`** when strikes or congrats line toggles. |
| **Layout** | Anchors **top-right**, **`anchor_bottom = 0`**: height/width set from **`get_combined_minimum_size()`** via **`_memphis_apply_outer_rect`** (immediate + **`call_deferred`** next frame) so the panel is never zero-height after **`offset_top`** alone; width hugs content with **12 px** right screen margin. |

### Points popups (`gui/points_popup.gd`)

| Change | Detail |
|--------|--------|
| **`spawn`** | If the player’s **`game_level`** display name is **Memphis Riverfront**, **return** before instantiating **`PointsPopup`** (no **`+N points`** world floats on that level). **`spawn_message`** unchanged. |

### Level complete (`gui/level_complete_screen.gd`)

| Change | Detail |
|--------|--------|
| **Superseded (2026-05-10)** | Earlier Memphis-only **points** hide on complete; see **[Level complete UX, Memphis completion stars, and hub map (2026-05-10)](#level-complete-ux-memphis-completion-stars-and-hub-map-2026-05-10)** for the current overlay (no score row, stars, captions, **Continue** gating, **`map/map.tscn`** hub). |

### Feena hint vs cough bubble (`level/feena_goal.gd`, `level 2/feena_goal.gd`)

| Piece | Detail |
|------|--------|
| **`_GAP_HINT_ABOVE_COUGH_PX`** | **10** px gap above the cough label when it is visible. |
| **`_position_hint_label`** | **`_hint.reset_size()`**; if **`_cough_label.visible`**, place **Talk to Feena** using **`_cough_label.global_position.y`** so it stacks **above** the cough line; else keep prior offset above Feena’s head (**4 px**). |

### Feena-adjacent willow trunk navigation (`pickups/soil_drop_zone.gd`, `player/player.gd`, `level/level.tscn`)

| Piece | Detail |
|------|--------|
| **`feena_adjacent_willow_climb`** | **`@export`** on **`soil_drop_zone.gd`** (default **`false`**). When **`true`**, **willow** soil, on **maturity lock**, spawns **`FeenaWillowNav`** under **`_growth_anchor`** once (guarded by child **`FeenaWillowNav`**). |
| **`FeenaWillowNav`** | Group **`feena_willow_nav`**; stores **`trunk_x0` / `trunk_x1` / `roof_y`** meta from sprite bounds in global space. |
| **`TrunkClimbVolume`** | **`Sprite2D`** with procedural **`ImageTexture`**, **fully transparent**, **`vine_climb`** group — full trunk **`move_up`/`move_down`** ladder like **`Grass/Vine2`**. |
| **`TrunkTopWalk`** | **`StaticBody2D`**, layer **8**, **`RectangleShape2D`** **50%** of trunk width × **10 px** thick, centered on canopy **roof** line — walk-off ledge. |
| **`Player`** | **`_feena_willow_climb_roof_y(mid_x)`** scans **`feena_willow_nav`** for **`mid_x`** in trunk band; when cresting that roof (vs **`Grass/Vine2`** top Y fallback), applies **`JUMP_VELOCITY * 0.7`** (**`FEENA_WILLOW_TOP_AUTO_JUMP_MULT`**) instead of **`_vine_crest_idle`** zero velocity. |
| **`level/level.tscn`** | **`WillowSoil2`** **`DropZone`** soil patch sets **`feena_adjacent_willow_climb = true`** (east patch near Feena). |

### Level 2 scene (`level 2/level.tscn`)

| Change | Detail |
|------|--------|
| **Tilemap / props** | **`layer_0/tile_data`** edits plus assorted décor **`Sprite2D`** position nudges (layout polish with Memphis/HUD work). |

---

## Riverfront sparrow and kingfisher ambient (2026-05-10)

Runtime **wildlife** on Level 1 (Memphis): **sparrows** after the **first** mature persisted tree, **kingfisher** after **two** mature trees **and** picking up **one** piece of trash that counts as **on river** (`float_on_water` or atlas **source 21** under the feet), **blue heron** once **foreground smog** has fully faded (**`get_fade_progress() == 1`**) and **every remaining trash pickup on river tiles** has been collected. **CHANGELOG** and wiring ship together on **`main`**.

### Sparrow (`level/props/birds/Sparrow/`)

| Piece | Detail |
|------|--------|
| **`sparrow_ambient.tscn` + `sparrow_ambient.gd`** | Group **`sparrows_ambient`**, spawns **two** deferred **`sparrow_actor`** nodes (staggered start). |
| **`sparrow_actor.gd`** | Fly in from a random **viewport** edge (camera world rect), **fly** strip then **`Sparrow_fly4`** for landing; **ray** to ground (**mask 24**); **idle** (2 full rounds) → **hop** (1 round) → repeat. **Visual scale** `1/3` of texture; timings slowed **2×** vs. an initial pass. |
| **`pickups/soil_drop_zone.gd`** | On first **locked maturity**, after smog: **`_ensure_sparrow_ambient_node()`** instantiates **`sparrow_ambient.tscn`** under **`game_level`**, then **`notify_one_tree_matured()`**. |

### Kingfisher (`level/props/birds/Kfisher/`)

| Piece | Detail |
|------|--------|
| **`kingfisher_ambient.tscn` + `kingfisher_ambient.gd`** | Group **`kingfisher_ambient`**, **`notify_tree_matured`** / **`notify_river_trash_removed`** counters, spawns **one** **`kingfisher_actor`** when thresholds met. If **`KingfisherLandingSpot`** exists under **`game_level`**, sets meta **`kingfisher_land_anchor`** to **`global_position`**. On spawn: **`z_index = max(cypress_roots_prop)+1`** (floor **4**) and **`move_child`** to **last** sibling under **`Level`** so art draws **in front of** runtime **`CypressRoots`** (`level/props/Roots/*.png`). |
| **`kingfisher_actor.gd`** | Same fly pattern using **`Kfisher_fly*`** / land on **`Kfisher_fly6`**; **idle** (2 rounds) → **pickup** (2 rounds) → repeat; **neutral** `z_index` on the actor (ordering on ambient parent). Landing: **`kingfisher_land_anchor`** when set (**authored X/Y**); else **`random_river_tile_top_center_world`**, then **`y -= _RIVER_CROSSSECTION_PERCH_Y_LIFT_PX`** (**104**) for rivertile cross-section art. |
| **`pickups/kingfisher_ambient_ensure.gd`** | **`static func ensure_under_game_level(SceneTree) -> Node`** preloads **`kingfisher_ambient.tscn`**; **`load()`** avoids circular **`PackedScene`** preload with the ambient script. **`soil_drop_zone.gd`** / **`trash_pickup.gd`** call it via **`preload("…kingfisher_ambient_ensure.gd")`**. |
| **`pickups/soil_drop_zone.gd`** | **`CypressRoots`** joins group **`cypress_roots_prop`**. Calls **`ensure_under_game_level`** then **`notify_tree_matured`** on maturity. |
| **`pickups/trash_pickup.gd`** | On successful pickup, if **river** (`float_on_water` or **`RiverTileQueries.global_point_on_river_tile`**): ensure ambient, **`notify_river_trash_removed()`**. **`is_river_tile_trash()`** exposes that test for **heron** spawn counting; **`heron_ambient_ensure.notify_maybe_spawn_deferred`** runs **after** **`queue_free()`** flushes so tallies exclude the piece just picked. |

### Heron (`level/props/birds/Heron/`)

| Piece | Detail |
|------|--------|
| **`heron_ambient.tscn` + `heron_ambient.gd`** | Group **`heron_ambient`**. Passes meta **`heron_land_anchor`**: **`HeronLandingSpot.global_position`** (**full X/Y**) when present; else **`Vector2(land_world_x, NaN)`** (**`@export`** default **-88**) so **`heron_actor`** raycasts **Y** only in that fallback. Marker must exist on the **played** level (**`level 2/level.tscn`** for **`game_level_1`**). **`notify_maybe_spawn()`**: smog **fully faded** + **no** river **`trash_pickup`** left → spawn **one** **`heron_actor`**. |
| **`heron_actor.gd`** | **`begin_flight`**: vertical drop; **`_fly_end`** from **`heron_land_anchor`** (**fixed point**) or legacy **`heron_land_world_x`** + **ground ray** (**mask 24**) when anchor absent / **NaN** **Y**. Faces toward the river (**`flip_h`**). Idle / pickup loop unchanged. |
| **`pickups/heron_ambient_ensure.gd`** | **`ensure_under_game_level`**, **`notify_maybe_spawn`**, **`notify_maybe_spawn_deferred`** (trash pickup path). |
| **`pickups/soil_drop_zone.gd`** | After **`notify_tree_matured`** on kingfisher line: **`_HERON_AMBIENT_ENSURE.notify_maybe_spawn(get_tree())`** so clearing **last smog** while litter already gone still triggers. |

### River helpers (`level/river_tile_queries.gd`)

| Piece | Detail |
|------|--------|
| **`global_point_on_river_tile`** | **`get_cell_source_id(0, …) == RIVER_SOURCE_ID` (21)** at a world point. |
| **`random_river_tile_top_center_world`** | Picks a **random** river cell (prefer **camera rect**), landing **X/Y** from the cell’s **world quad** (four **`to_global(map_to_local(…))`** corners) so **Y** matches the **drawn** tile top. |
| **`river_layer_world_x_max`** | Rightmost world **X** across **all** river cells (full-level east edge). |
| **`river_layer_world_x_max_intersecting_world_rect`** | Rightmost **X** among river cells whose tile bounds intersect a **world rect** (heron fallback / wide horizontal pad). |
| **`river_layer_world_x_max_overlapping_y_interval`** | Rightmost **X** among river cells whose **vertical** span overlaps an interval at **ground height** — fixes skewed tile quads where **`intersects(camera_rect)`** missed water and **`river_right`** was too small (**heron west of river**). |
| **`_river_cell_top_center_world`** | Shared helper for that quad top / horizontal mid. |

### Level 2 scene

| File | Change |
|------|--------|
| **`level 2/level.tscn`** | Small **`layer_0/tile_data`** edits; **`TrashCan`**, **`Trash`**, **`Trash2`** position nudges (editor / layout). |

---

## Memphis foreground smog, tree-driven fade, and Feena mood (2026-05-09)

Level 1 (Memphis Riverfront) gains **playfield smog** that clears as **adult trees persist**, **`FinishLine` / Feena** react to smog state with **sad vs idle** animation, and **optional cough copy** on a specific sad frame. **`game_level_1.tscn`** now instances **`level 2/level.tscn`** (Memphis layout) instead of **`level/level.tscn`**.

### Smog visuals and fade logic

| Piece | Role |
|------|------|
| **`level/background/smog_parallax_layer.gd`** (+ **`.uid`**) | **`ForegroundSmog`** `Node2D` script: `add_to_group("smog_parallax_fade")`, **`get_fade_progress()`** returns **0 → 1** fade progress, **`maturity_slots_override`** optional cap. |
| **`ForegroundSmog`** in **`level 2/level.tscn`** and **`level/level.tscn`** | World-space **`z_index = 8`** smog stack (above tilemap / player draw order used for props). Editor may add many child **`Sprite2D`** layers; fade drives **parent `modulate`**. |
| **`pickups/soil_drop_zone.gd`** | On first **fully grown + maturity lock** transition, **`call_group("smog_parallax_fade", "register_tree_matured")`** so each persisted tree advances fade. |
| **`level/level.gd`** and **`level 2/level.gd`** | **`get_soil_drop_zone_count()`** counts **`soil_drop_zone.gd`** nodes; **`get_max_achievable_points()`** reuses it for soil count. Smog uses **`max(1, count)`** as the number of steps to **100%** clear. |
| **`level 2/background/parallax_background.tscn`** | Prior experimental **Smog** `ParallaxLayer` removed so haze is not duplicated in the sky stack. |

Fade progress **only increases** with mature trees (no rewind with level time direction). Smog is **fully transparent** when the **last** counted soil patch reaches locked maturity.

### Feena (`feena_goal.gd`)

| Behavior | Detail |
|----------|--------|
| **Sad vs idle** | While **`get_fade_progress() < 1`**, **`Square`** uses a runtime **`AnimatedTexture`** over **`res://level/props/Feena/sad/F_sad1.png`–`F_sad7.png`** (**1.4 s** per frame). At **100%** smog fade, switches to **`idle/`** `F_idle1`–`F_idle3` (**1.0 s** per frame). |
| **Cough line** | When the sad strip is on **frame index 5** (**`F_sad6.png`**), a **`Label`** shows **`"*cough cough*"`** centered above the sprite AABB (outline + theme font). |
| **Scripts** | **`level 2/feena_goal.gd`** (referenced by both level scenes) and **`level/feena_goal.gd`** stay in sync. |

### Art

| Path | Note |
|------|------|
| **`level/props/Feena/sad/`** | **`F_sad1`–`F_sad7`** PNGs + **`.import`** (seven-frame sad cycle for Feena). |
| **`level/background/smog_1/*.webp`** | Smog plates **re-toned** toward mid-gray (50% contrast reduction on RGB) for a softer haze read. |

### Entry scene

| File | Change |
|------|--------|
| **`game_level_1.tscn`** | Level instance path **`level 2/level.tscn`**; **`level_complete_screen`** ext_resource no longer carries a redundant **`uid`**. |

---

## Root-level cloud WebP placeholders (2026-05-09)

Commit **`442004f`** adds **`cloud_1.webp`**, **`cloud_2.webp`**, and **`cloud_3.webp`** at the **repository root**, each with a matching **`.import`** sidecar so Godot records stable **`CompressedTexture2D`** import metadata. The commit message describes them as previously untracked placeholders staged for consistent import settings and UIDs.

These files are **in addition to** the parallax clouds under **`level/background/`** and **`level 2/background/`** (see [Smog backdrop placeholders](#smog-backdrop-placeholders-2026-05-09) for how `smog_1*` relates to those paths). No scene or script change in **`442004f`** retargets parallax textures to the root copies—confirm any intended wiring before relying on **`res://cloud_*.webp`**.

---

## River tile atlas and Level 2 Memphis river paint (2026-05-09)

**`level/rivertile.png`** (plus **`.import`**, texture **`uid://ddwq574os3116`**) is authored as a **64×64** tile grid. The on-disk image is **321×193** px, which yields **5×3 = 15** atlas cells under Godot’s integer grid (one spare pixel on the **right** and **bottom** unless cropped to **320×192**).

### TileSet wiring

| File | Change |
|------|--------|
| **`level/tileset.tres`** | New **`ExtResource("2")`** → **`res://level/rivertile.png`**. New **`TileSetAtlasSource_river`**: **`texture_region_size = Vector2i(64, 64)`**, explicit atlas coordinates **`(0,0)` through `(4,2)`**. Registered as **`sources/21`**. |
| **`level 2/tileset.tres`** | Same **`TileSetAtlasSource_river`** and **`sources/21`**; texture path **`res://level/rivertile.png`** so Level 2 reuses the Level 1 asset without duplicating the PNG. |

The river atlas still has **no baked-in** `physics_layer` polygons in **`tileset.tres`**; walkable water under a mature Cypress uses **runtime** collision added by **`tilemap_cypress_river_floor.gd`** (see [Cypress roots, river bridge, river splash, and z-order (2026-05-09)](#cypress-roots-river-bridge-river-splash-and-z-order-2026-05-09)).

### Level 2 scene (`level 2/level.tscn`)

| Area | Change |
|------|--------|
| **TileMapLayer `layer_0`** | **`tile_data`** (`PackedInt32Array`) rewritten: river terrain uses **atlas source index `21`** (the river sub-atlas) with new placements along the playfield; array order differs from the prior commit (normal after a large repaint). |
| **Trash / cans** | **`TrashCan`**, **`TrashCan2`**, and **`Trash`**–**`Trash7`** **position** updates; several trash nodes gained or adjusted **`rotation`**. |
| **`Trash8` / `Trash9`** | **`Trash8`** was brought back into the playfield (**`position ≈ (949, 665)`**, slight **`rotation`**) after it had briefly sat far below the camera’s **`limit_bottom`** (~1290), which hid it in the 2D editor. **`Trash9`** is an additional **`Trash`** instance (**`position ≈ (633, 658)`**). |
| **Soils** | **`WillowSoil1`** moved near the west trash cluster; **`CypressSoil`** repositioned. |
| **River décor** | **`RiverVine*`** and smog wash **`Sprite2D`** instances repositioned (exact vectors in the scene file). |

This pass is **one `git` commit on `main`** (message: *Add rivertile atlas, paint Memphis river on Level 2, fix trash placement*) bundling **`level/rivertile.png`** + **`.import`**, **`level/tileset.tres`**, **`level 2/tileset.tres`**, and **`level 2/level.tscn`**, plus **CHANGELOG** updates ([Root-level cloud…](#root-level-cloud-webp-placeholders-2026-05-09), this river section, and the **2026-05-09 commit index** table).

### Git commits on 2026-05-09 (`main`, newest first)

| SHA | Summary | Detailed section |
|-----|---------|------------------|
| **`442004f`** | Root **`cloud_1`–`3.webp`** + `.import` | [Root-level cloud WebP placeholders](#root-level-cloud-webp-placeholders-2026-05-09) (above) |
| **`4897aba`** | Foreground smog, tree-driven fade, Feena sad/idle | [Memphis foreground smog…](#memphis-foreground-smog-tree-driven-fade-and-feena-mood-2026-05-09) |
| **`dfd4cd8`** | **`smog_1/`** layered placeholder WebPs | [Smog backdrop placeholders](#smog-backdrop-placeholders-2026-05-09) |
| **`e4bc803`** | Bird sprites → **`idle/`** / **`fly/`** / **`hop/`** / **`pickup/`** | [Riverfront wildlife bird sprites](#riverfront-wildlife-bird-sprites-2026-05-09) |
| **`4e75ef0`** | **`game_level_1.tscn`** resave (scene **`uid`**, node **`unique_id`**, `PackedScene` **`uid`** on level-complete UI) | *(No separate section—editor metadata hygiene only.)* |
| **`6a96ebe`** | Initial riverfront bird PNG drop (52 frames) | [Riverfront wildlife bird sprites](#riverfront-wildlife-bird-sprites-2026-05-09) |

---

## Cypress roots, river bridge, river splash, and z-order (2026-05-09)

End-to-end pass so **mature Cypress** shows a **roots growth strip** over the bank, **river tiles under that strip gain floor collision** (without colliders on the roots node itself), **falling into open river** can trigger a **pause + splash / retry** flow, and **2D draw order** keeps **litter art** in front of roots while the **player** stays on top. (Shipped on **`main`** as commit **`52f3f66`**.)

### Cypress roots (`pickups/soil_drop_zone.gd`)

| Piece | Detail |
|------|--------|
| **Frames** | **`_CYPRESS_ROOT_FRAMES`**: `level/props/Roots/Roots1.png`–`Roots4.png`, stepped every **`_CYPRESS_ROOT_STEP_SEC`** (`0.42` s) while maturity is locked. |
| **Spawn** | **`_start_cypress_roots()`** after the first **fully grown** transition on **`accepts == CYPRESS`**: **`CypressRoots`** is a **`Node2D`** with one **`Sprite2D`** (nearest filter, centered, scale tied to tree placeholder height × `0.75`). |
| **Placement** | Roots anchor from **trunk right** and **soil base** of **`_growth_sprite`**; parent is **`Level`** when possible, with **`z_index = 3`** and **`move_child`** to the index of the first **`trash_pickup.tscn`** instance so **trash** stays visually forward. |
| **River floor handoff** | **`_update_cypress_roots_river_tile_floor()`** finds **`^"TileMap"`** on the level (`get_node_or_null(^"TileMap")`) and calls **`add_cypress_river_floor_cells`** with every **layer 0** cell in the roots sprite world rect whose **`get_cell_source_id` == `RiverTileQueries.RIVER_SOURCE_ID` (21)**. Re-runs when the root texture advances so the covered **cell set** tracks the wider frames. |

### TileMap bridge script (`level/tilemap_cypress_river_floor.gd` + **`.uid`**)

| Piece | Detail |
|------|--------|
| **Attachment** | Script on **`TileMap`** in **`level/level.tscn`**, **`level/level_2.tscn`**, **`level 2/level.tscn`**, **`level 2/level_2.tscn`**. |
| **`add_cypress_river_floor_cells(Array[Vector2i])`** | Merges into **`_cypress_river_floor_cells`**, mirrors **`Dictionary`** to TileMap **`meta`** **`cypress_river_floor_cell_dict`** for **`RiverTileQueries`**, then **`notify_runtime_tile_data_update(0)`**. |
| **Runtime tile data** | **`_use_tile_data_runtime_update`** / **`_tile_data_runtime_update`**: for tracked coords that are still **river source 21**, **`add_collision_polygon(0)`** + **`set_collision_polygon_points`** using the same **quad** as typical ground tiles on this tileset (`(-32,-22)` … `(32,32)` in tile space), **`set_collision_polygon_one_way(..., false)`**. |
| **GDScript note** | Floor polygon is a script **`var _river_floor_poly`** (not **`const`**) because **`PackedVector2Array([Vector2…])`** is not a constant expression in this project’s analyzer. |

### River detection (`level/river_tile_queries.gd` + **`.uid`**)

| API | Role |
|-----|------|
| **`RIVER_SOURCE_ID`** | **`21`** (must match **`sources/21`** on **`level/tileset.tres`** / **`level 2/tileset.tres`**). |
| **`player_started_river_plummet(tm, player)`** | Requires **`can_trigger_river_submersion()`**, feet cell **river**, and feet cell **not** in **`cypress_river_floor_cell_dict`** on **`tm`**. |
| **`player_feet_below_viewport(player)`** | Used by the level when a tracked fall should open the splash. |

### Level loop (`level/level.gd`, **`level 2/level.gd`**)

| Piece | Detail |
|------|--------|
| **`_river_fall_tracking`** | **`Array[WeakRef]`** of players who matched **`player_started_river_plummet`**. |
| **`_check_river_fall()`** | Each **`_physics_process`**: drop entries when **`is_on_floor()`**; if tracked player’s feet pass **below the camera viewport** (with margin), call **`Game.present_river_fall()`** and clear the list. |

### Game + splash UI (`game.gd`, **`gui/river_splash_menu.gd`**, **`gui/river_splash_menu.tscn`**, **`.uid`**)

| Piece | Detail |
|------|--------|
| **`Game`** | **`@onready _river_splash`**, **`present_river_fall()`** pauses the tree and opens the menu; **`present_level_complete`** and **`_unhandled_input`** respect **`RiverSplashMenu.is_blocking()`**. |
| **`RiverSplashMenu`** | **`class_name RiverSplashMenu`**: blocking overlay, **Retry** returns to **`map/map.tscn`**, tweened fade. |
| **Scenes** | **`RiverSplashMenu`** instanced under **`InterfaceLayer`** in **`game_singleplayer.tscn`**, **`game_level_1.tscn`**, **`game_level_2.tscn`**. |

### Player (`player/player.gd`, **`player/player.tscn`**)

| Piece | Detail |
|------|--------|
| **`can_trigger_river_submersion()`** | **Not** on floor, **not** vine-latched / crest-idle, **`velocity.y > 55`** so river tracking matches an actual downward fall. |
| **`_sprite_global_bounds_rect(spr: Sprite2D)`** | Parameter renamed from **`sprite`** to avoid **SHADOWED_VARIABLE** against **`@onready var sprite`**. |
| **`z_index`** | **`Player`** raised (**`5`**) so the character draws above **roots (`3`)** and **trash pickup root (`4`)**. |

### Trash pickups (`pickups/trash_pickup.tscn`, **`pickups/trash_pickup.gd`**)

| Piece | Detail |
|------|--------|
| **Layering** | **`Area2D`** **`z_index = 4`**; child **`Sprite2D`** **`z_index = 0`** so nested relative Z does not stack above the player. |
| **Water bob** | Optional **`float_on_water`** (+ period / amplitude exports): gentle **`sin`** bob on **`position.y`** in **`_physics_process`**. |

### Art

| Path | Note |
|------|------|
| **`level/props/Roots/*.png`** + **`.import`** | Four root growth frames consumed by **`soil_drop_zone.gd`**. |

### Fixes called out during integration

| Issue | Fix |
|-------|-----|
| **`get_node_or_null(&"TileMap")`** | **`&`** builds a **`StringName`**; **`get_node_or_null`** expects a **`NodePath`** — use **`^"TileMap"`**. |

---

## Smog backdrop placeholders (2026-05-09)

Seeds a new `level/background/smog_1/` asset bucket so a future polluted-skyline pass on **Memphis Riverfront** has a place to drop its art without further folder shuffling. Pure-asset commit: no scene, script, or `ParallaxLayer` references the smog bucket yet.

### New files

| File | Godot `uid` | Bytes |
|------|-------------|-------|
| **`level/background/smog_1/smog_1a.webp`** + `.import` | `uid://dwpy7eta5cbxs` | 830 |
| **`level/background/smog_1/smog_1b.webp`** + `.import` | `uid://cvf3b154isoib` | 7 808 |
| **`level/background/smog_1/smog_1c.webp`** + `.import` | `uid://gag778ikdjyy` | 1 064 |

### Naming pattern

| Element | Meaning |
|---------|---------|
| **`smog_1/`** | First **smog cluster**. Mirrors the `bird/<species>/` and `pickups/<seed>/` folder grain — leaves room for `smog_2/`, `smog_3/` clusters later (e.g. distinct stacks of haze layered at different parallax depths or tied to different riverfront zones). |
| **`smog_1a` / `smog_1b` / `smog_1c`** | Variants **inside** the cluster, intended to be combined to build up one smog effect (rather than alternates of the same sprite). The trailing `_a / _b / _c` suffix is reserved for additional layered variants without renumbering the import UIDs. |

### Notes

| Aspect | State |
|--------|-------|
| **Pixel content** | Currently **byte-identical** to `level/background/cloud_1.webp` / `cloud_2.webp` / `cloud_3.webp` (verified by SHA-1: `85d7b6b…`, `fea3e0b…`, `061672b…`). The smog files are **placeholders**, seeded from the cloud art so import settings, scaling, and parallax scoping can be validated end-to-end before final pollution-themed art lands. Final art will overwrite these files in place; the Godot `uid` references in the `.import` sidecars stay stable across that swap, so any future scene wiring will not break. |
| **Sidecars** | `.import` sidecars correctly reference `res://level/background/smog_1/smog_1{a,b,c}.webp` after Godot re-imported the moved files — no orphan `source_file` paths. |
| **Scene wiring** | **Update:** smog is **not** in `parallax_background.tscn`; it is wired as **`ForegroundSmog`** on the level scenes (see [Memphis foreground smog…](#memphis-foreground-smog-tree-driven-fade-and-feena-mood-2026-05-09)). This row originally described placeholder-only state. |
| **Sibling layout** | `level/background/smog_1/` sits beside the existing `cloud_*.webp`, `sky.webp`, `lvl1_memphis_skyline.jpg`, `distant_platforms_*.webp`, and `parallax_background.tscn`, keeping all sky-stack inputs in one folder. |

### Known follow-ups (not yet done)

1. Replace the placeholder bytes with actual smog art (overwrite the three `.webp` files in place; Godot will re-import on next open while preserving the `.import` UIDs).
2. Add a `Smog` `ParallaxLayer` to `level/background/parallax_background.tscn`, layering `smog_1a` / `smog_1b` / `smog_1c` together for a single stacked haze effect; mirror into `level 2/background/parallax_background.tscn` if Level 2 needs the same treatment.
3. Decide whether haze needs its own `motion_scale` (slower than `Clouds`’ `(0.1, 1)`) and a `modulate` alpha to suggest depth.
4. If additional clusters are needed (e.g. `smog_2/` for downtown vs `smog_3/` for the river), drop them in beside `smog_1/` using the same `<cluster>/<cluster><variant>.webp` shape.

---

## Riverfront wildlife bird sprites (2026-05-09)

This update introduces a sprite library for ambient riverfront wildlife on Level 1 (Memphis Riverfront). It is a **pure-asset drop**: 52 PNG frames (plus matching Godot `.import` sidecars) for five species, with no scene, script, or `SpriteFrames` resource wiring yet — the library is staged so a future pass can author per-species `AnimatedSprite2D` props and place them in `level/level.tscn`.

### Asset layout

Sprites live under **`level/props/birds/<Species>/<animation>/<Species>_<state><n>.png`**, with one `.import` sidecar per PNG. Animation buckets vary per species based on supplied frames (no `hop` for Heron / Kingfisher / Woodpecker; no `pickup` for Cardinal / Sparrow / Woodpecker). All `<Species>_<state>_1.png` siblings (e.g. `Cardinal_idle1_1.png`) are **alternate first-frame variants**, useful as `SpriteFrames` randomization or breathing-cycle pairs.

| Species (folder) | Idle | Fly | Hop | Pickup | Total PNGs |
|------------------|------|-----|-----|--------|-----------|
| **`Cardinal/`**  | 3 (`idle1`, `idle1_1`, `idle2`) | 6 (`fly1`, `fly2`, `fly2_1`, `fly3`, `fly3_1`, `fly4`) | 2 (`hop`, `hop2`) | — | **11** |
| **`Heron/`**     | 3 (`idle1`–`idle3`) | 6 (`fly1`–`fly6`) | — | 2 (`pickup2`, `pickup3`) | **11** |
| **`Kfisher/`** *(Kingfisher)* | 3 (`idle1`–`idle3`) | 6 (`fly1`, `fly2`, `fly2_1`, `fly3`, `fly5`, `fly6`) | — | 3 (`pickup1`–`pickup3`) | **12** |
| **`Sparrow/`**   | 4 (`idle1`, `idle1_1`, `idle2`, `idle3`) | 5 (`fly1`–`fly4`, `fly3_1`) | 2 (`hop1`, `hop2`) | — | **11** |
| **`Woodpecker/`** *(prefix `WP_`)* | 3 (`idle1`–`idle3`) | 4 (`fly1`–`fly4`) | — | — | **7** |
| **Total** | 16 | 27 | 4 | 5 | **52** |

### Two-step rollout

| Step | Form on disk | Status |
|------|--------------|--------|
| **1. Initial drop** (commit **`6a96ebe`**) | Flat: `level/props/birds/<Species>/<Species>_<state><n>.png` (52 PNGs + 52 `.import`) | **Pushed to `origin/main`**. |
| **2. Per-animation reorg** | Nested: `level/props/birds/<Species>/<animation>/<Species>_<state><n>.png` | **Committed to `main`** — 52 PNGs + `.import` sidecars under `idle/`, `fly/`, `hop/`, and `pickup/`. `Heron/Heron_6.png` was renamed to `Heron/fly/Heron_fly6.png` (byte-identical to the prior flat asset). |

### Integration status

| Aspect | State |
|--------|-------|
| **Scene references** | None. No `level/level.tscn`, `game_level_1.tscn`, or `level 2/level.tscn` reference `props/birds/` yet (verified by repo search). |
| **`SpriteFrames` / `AnimatedSprite2D`** | Not yet authored. The four animation buckets (`idle` / `fly` / `hop` / `pickup`) are pre-bucketed for direct drag-into-SpriteFrames. |
| **Naming convention** | Per-frame numeric suffix (`*_idle1`, `*_idle2`); `*_n_1` siblings are alternate first frames intended as variant idles or randomized starting frames. Woodpecker uses the `WP_` short prefix; all others use the full species name. |
| **Sidecars** | Every PNG has a matching `<file>.png.import`, so the sprites import cleanly on the next Godot project open. |

### Known follow-ups (not yet done)

1. Author one `bird.tscn` (`AnimatedSprite2D` + `SpriteFrames`) per species, mapping each subfolder to a same-named animation track.
2. Place ambient bird props into **`level/level.tscn`** (so both `game_singleplayer.tscn` and `game_level_1.tscn` inherit them) rather than into the level wrappers.

---

## Map level routing and Level 1/Level 2 entry fixes (2026-04-27)

This update stabilizes map-driven scene launches so the two map touch targets route to separate level entries, and resolves parser/type issues that blocked launch attempts during the Level 1/Level 2 split.

### New files

| File | Role |
|------|------|
| **`game_level_1.tscn`** | Dedicated single-player entry wrapper for **Level 1**, instancing **`level/level.tscn`**, **`player/player.tscn`**, pause menu, and level-complete UI. |

### Map launch flow

| File | Change |
|------|--------|
| **`map/map.tscn`** | Existing touch target wiring retained: **`LevelButton -> _on_level_pressed`**, **`Level2Button -> _on_level_2_pressed`**. |
| **`map/map.gd`** | Level routing constants maintained for explicit map targets (**Level 1** and **Level 2**). Added defensive `_ready()` signal binding for both buttons so launch handlers stay connected even if scene signal metadata drifts. |
| **`map/map.gd`** | `_open_scene()` now uses explicit typed error capture (`var err: Error = ...`) before checking `OK`, avoiding parser/type issues on strict inference. |

### Scene target corrections

| File | Change |
|------|--------|
| **`game_singleplayer.tscn`** | Level ext-resource path corrected back to **`res://level/level.tscn`** for the Level 1 route. |
| **`gui/world_map.gd`** | Level 1 world-map button now targets **`res://game_singleplayer.tscn`**. |
| **`gui/pause_menu.gd`** | Single-player button now targets **`res://game_singleplayer.tscn`**. |

### Parser conflict fix (Level 2 script)

| File | Change |
|------|--------|
| **`level 2/level.gd`** | Removed duplicate global class declaration by changing **`class_name GameLevel extends Node2D`** to **`extends Node2D`**. This resolves: **`Class "GameLevel" hides a global script class`**. |

### Resulting behavior

1. Map touch target 1 launches the Level 1 gameplay entry.
2. Map touch target 2 launches the Level 2 gameplay entry.
3. Launch path no longer fails on duplicate `GameLevel` global class registration.
4. Map scene change error handling parses cleanly under strict typing.

### Full file manifest (commit `4496c25`)

The following project paths were changed in this update.

| Scope | Paths |
|------|------|
| **Top-level scene entries** | **`game_level_1.tscn`** (new), **`game_level_2.tscn`** (new), **`game_singleplayer.tscn`** (updated) |
| **Map / splash flow** | **`map/map.tscn`**, **`map/map.gd`**, **`map/map.gd.uid`**, **`map/InteractiveMap.png`** (+`.import`), **`map/MenuCTA.png`** (+`.import`), **`splash/splash.tscn`**, **`splash/splash.gd`**, **`splash/splash.gd.uid`**, **`splash/splash.png`** (+`.import`), **`splash/StartCTA.png`** (+`.import`) |
| **UI scripts touched** | **`gui/pause_menu.gd`** |
| **Project settings** | **`project.godot`** |
| **Level 1 assets touched** | **`level/level.tscn`**, **`level/props/Trashcan.png`** (+`.import`) |
| **New Level 2 scene/scripts** | **`level 2/level.tscn`**, **`level 2/level_2.tscn`**, **`level 2/level.gd`**, **`level 2/level.gd.uid`**, **`level 2/feena_goal.gd`**, **`level 2/feena_goal.gd.uid`**, **`level 2/tileset.tres`**, **`level 2/tiles.webp`** (+`.import`), **`level 2/coin.webp`** (+`.import`) |
| **New Level 2 background** | **`level 2/background/parallax_background.tscn`**, **`level 2/background/sun_parallax_layer.gd`** (+`.uid`), **`level 2/background/sky.webp`** (+`.import`), **`level 2/background/cloud_1.webp`** (+`.import`), **`level 2/background/cloud_2.webp`** (+`.import`), **`level 2/background/cloud_3.webp`** (+`.import`), **`level 2/background/distant_platforms_1.webp`** (+`.import`), **`level 2/background/distant_platforms_2.webp`** (+`.import`), **`level 2/background/lvl1_memphis_skyline.jpg`** (+`.import`) |
| **New Level 2 platforms** | **`level 2/platforms/platform.tscn`**, **`level 2/platforms/moving_platform.gd`** (+`.uid`), **`level 2/platforms/moving_platform.webp`** (+`.import`), **`level 2/platforms/one_way_platform.webp`** (+`.import`) |
| **New Level 2 props** | **`level 2/props/wind_sway.tres`**, **`level 2/props/tiles-01.svg`** (+`.import`), **`level 2/props/Sun.png`** (+`.import`), **`level 2/props/Trashcan.png`** (+`.import`), **`level 2/props/Vine1.png`** (+`.import`), **`level 2/props/Willow_seed.png`** (+`.import`), **`level 2/props/Cypress_seed.png`** (+`.import`), **`level 2/props/Willow_soil.png`** (+`.import`), **`level 2/props/Cypress_soil.png`** (+`.import`), **`level 2/props/Feena/idle/F_idle1.png`** (+`.import`), **`level 2/props/Feena/idle/F_idle2.png`** (+`.import`), **`level 2/props/Feena/idle/F_idle3.png`** (+`.import`), **`level 2/props/Trash/trash_bbag1.png`** (+`.import`), **`level 2/props/Trash/trash_bbag2.png`** (+`.import`), **`level 2/props/Trash/trash_blkbag.png`** (+`.import`), **`level 2/props/Trash/trash_cup.png`** (+`.import`), **`level 2/props/Trash/trash_food.png`** (+`.import`), **`level 2/props/Trash/trash_soda1.png`** (+`.import`), **`level 2/props/Trash/trash_soda2.png`** (+`.import`), **`level 2/props/Tree_Cypress/Cypress1.png`** (+`.import`), **`level 2/props/Tree_Cypress/Cypress2.png`** (+`.import`), **`level 2/props/Tree_Cypress/Cypress3.png`** (+`.import`), **`level 2/props/Tree_Cypress/Cypress4.png`** (+`.import`), **`level 2/props/Tree_Willow/Willow1.png`** (+`.import`), **`level 2/props/Tree_Willow/Willow2.png`** (+`.import`), **`level 2/props/Tree_Willow/Willow3.png`** (+`.import`), **`level 2/props/Tree_Willow/Willow4.png`** (+`.import`), **`level 2/props/tree_1.webp`** (+`.import`), **`level 2/props/tree_2.webp`** (+`.import`), **`level 2/props/bush_1.webp`** (+`.import`), **`level 2/props/rock_1.webp`** (+`.import`), **`level 2/props/grass_1.webp`** (+`.import`), **`level 2/props/grass_2.webp`** (+`.import`), **`level 2/props/grass_3.webp`** (+`.import`), **`level 2/props/flower_1.webp`** (+`.import`), **`level 2/props/fern_1.webp`** (+`.import`), **`level 2/props/ground_flowers_1.webp`** (+`.import`), **`level 2/props/vine_1.webp`** (+`.import`), **`level 2/props/vine_2.webp`** (+`.import`) |
| **This documentation** | **`CHANGELOG.md`** |

---

## Level complete screen, world map, and Feena goal (2026-04-27)

This update adds an end-of-level flow: **talk to Feena** (proximity hint + **`drop_seed*`** interact) opens a **level complete** overlay (level name, score earned vs maximum achievable, **Retry** / **Continue** / **Back to Map**), pauses the scene tree, and introduces a minimal **world map** scene for navigation when **Continue** has no next level or when returning from the overlay.

### New files

| File | Role |
|------|------|
| **`gui/level_complete_screen.tscn`** | Full-screen **`Control`** with **`process_mode = PROCESS_MODE_ALWAYS`** (same idea as **`PauseMenu`**: UI keeps running while **`SceneTree.paused`**). Themed like the pause menu: dim **`ColorRect`**, **`CenterContainer`**, title **“Level Complete”**, **`LevelNameLabel`**, **`PointsLabel`**, **Retry** / **Continue** / **Back to Map** buttons. |
| **`gui/level_complete_screen.gd`** | **`class_name LevelCompleteScreen`**: **`present(title, earned, possible)`** (fade + anchor tween, focus **Retry**), **`is_blocking()`**, **`_dismiss_immediate()`** (unpause + hide). **Continue** asks **`game_controller`** for **`get_continue_scene_path()`**; if empty, loads **`res://gui/world_map.tscn`**. **Back to Map** always loads the world map. **Memphis Riverfront:** hides **`PointsLabel`** ([Memphis mission HUD…](#memphis-mission-hud-feena-adjacent-willow-climb-and-ui-polish-2026-05-10)). |
| **`gui/world_map.tscn`** | Hub **`Control`**: title **“World Map”**, **Level 1** → **`game_singleplayer.tscn`**, **Quit**. |
| **`gui/world_map.gd`** | Button handlers for the above scene changes / quit. |
| **`level/feena_goal.gd`** | Script on **`FinishLine`**: each physics frame, distance from each **`player`** **`global_position`** to the **world axis-aligned bounds** of **`FinishLine/Square`** (Feena **`Sprite2D`**). If **≤ 40px**, shows themed **`Label`** **“Talk to Feena”** above the sprite’s top-center; if in range and **`drop_seed` + `action_suffix`** fires, calls **`present_level_complete()`** once and stops processing. |

### Removed

| File / node | Reason |
|-------------|--------|
| **`level/finish_zone.gd`** (and **`.uid`**) | Replaced by proximity + interact on **`FinishLine`**; earlier design used a **`FinishTrigger`** **`Area2D`** on **`body_entered`**. |
| **`level/level.tscn`** → **`FinishLine/FinishTrigger`** | **`Area2D`** + **`RectangleShape2D`** win volume removed; completion is interact-only. |

### `level/level.gd` (`class_name GameLevel`)

| Change | Detail |
|--------|--------|
| **`class_name GameLevel`** | Root **`level/*.tscn`** scripts extend **`Node2D`** with this name so **`game.gd`** can cast the **`game_level`** group node. |
| **`@export var level_display_name`** | Shown as the level title on the complete screen (main level set to **“Memphis Riverfront”** in **`level.tscn`**; **`level_2.tscn`** sets **“Level 2”**). |
| **`@export_file("*.tscn") var next_level_scene`** | If non-empty, **Continue** on **`LevelCompleteScreen`** loads this path after unpause; if empty, **Continue** falls back to **`world_map.tscn`**. |
| **`get_max_achievable_points()`** | Walks the level subtree: counts nodes whose script is **`soil_drop_zone.gd`** (**× `Player.POINTS_SOIL_PLANT`**) and **`trash_pickup.gd`** (**× `Player.POINTS_TRASH_DEPOSIT`**). See [Trash cans, Feena interact, and scoring cap (2026-05-10)](#trash-cans-feena-interact-and-scoring-cap-2026-05-10). |

### `level/level.tscn`

| Change | Detail |
|--------|--------|
| **`FinishLine`** | **`script = feena_goal.gd`** (was unscripted; win **`Area2D`** removed). |
| **Root exports** | **`level_display_name = "Memphis Riverfront"`** on the **`Level`** node. |

### `game.gd` (`class_name Game`)

| Change | Detail |
|--------|--------|
| **`game_controller` group** | **`add_to_group("game_controller")`** in **`_ready`** so **`LevelCompleteScreen`** and **`feena_goal`** can find the active **`Game`**. |
| **`@onready var _level_complete`** | **`$InterfaceLayer/LevelCompleteScreen`**. |
| **`present_level_complete()`** | Guards with **`_level_complete.is_blocking()`**; sets **`get_tree().paused = true`**; resolves **`game_level`** as **`GameLevel`** for **`level_display_name`** and **`get_max_achievable_points()`**; **`earned`** = sum of **`Player.score`** over group **`player`**; calls **`_level_complete.present(...)`**. |
| **`get_continue_scene_path()`** | Returns **`GameLevel.next_level_scene`** from the **`game_level`** node, or **`""`**. |
| **`_total_player_score()`** | Sums scores for all **`Player`** in **`player`**. |
| **`_unhandled_input`** | If **`_level_complete.is_blocking()`**, skips **toggle_pause** and **toggle_fullscreen** handling (same frame ordering as pause overlay). |

### Game scenes

| File | Change |
|------|--------|
| **`game_singleplayer.tscn`** | **`InterfaceLayer`** child **`LevelCompleteScreen`** instancing **`gui/level_complete_screen.tscn`**. |
| **`game_splitscreen.tscn`** | Same **`LevelCompleteScreen`** instance under **`InterfaceLayer`**. |

### Files touched (paths)

| Path | Role |
|------|------|
| **`gui/level_complete_screen.tscn`** | Level complete overlay scene. |
| **`gui/level_complete_screen.gd`** | **`LevelCompleteScreen`** logic (present / dismiss / buttons). |
| **`gui/world_map.tscn`** | Hub scene. |
| **`gui/world_map.gd`** | Hub button handlers. |
| **`game.gd`** | **`game_controller`** group, **`_level_complete`**, **`present_level_complete()`**, **`get_continue_scene_path()`**, **`_total_player_score()`**, input guard when **`is_blocking()`**. |
| **`game_singleplayer.tscn`** | Instantiates **`LevelCompleteScreen`**. |
| **`game_splitscreen.tscn`** | Instantiates **`LevelCompleteScreen`**. |
| **`level/level.gd`** | **`class_name GameLevel`**, exports, **`get_max_achievable_points()`**. |
| **`level/level.tscn`** | **`FinishLine.script`**, **`level_display_name`**, removed **`FinishTrigger`** / **`FinishWinRect`**. |
| **`level/level_2.tscn`** | **`level_display_name = "Level 2"`** on root (optional; no **`feena_goal`** / finish until added). |
| **`level/feena_goal.gd`** | Proximity hint + interact → **`present_level_complete()`**. |
| **`level/finish_zone.gd`** (removed) | Superseded by **`feena_goal.gd`**. |

### Buttons (`LevelCompleteScreen`)

| Button | Behavior |
|--------|----------|
| **Retry** | **`_dismiss_immediate()`** (unpause, clear **`_blocking`**, reset **`modulate.a`** and **`CenterContainer.anchor_bottom`**, **`hide()`**), then **`get_tree().reload_current_scene()`**. |
| **Continue** | Reads **`get_continue_scene_path()`** from **`game_controller`** (**`GameLevel.next_level_scene`**). If empty, uses **`res://gui/world_map.tscn`**. **`_dismiss_immediate()`**, then **`change_scene_to_file(next_path)`**. |
| **Back to Map** | **`_dismiss_immediate()`**, then **`change_scene_to_file("res://gui/world_map.tscn")`** (always the hub, regardless of **`next_level_scene`**). |

### Design notes

- **Pause:** While the level complete UI is up, **`SceneTree.paused`** is **true**; **`LevelCompleteScreen`** root uses **`process_mode = always`** so tweens and buttons still run (same idea as **`PauseMenu`**).
- **Feena distance:** Uses closest-point distance from the player to the **world AABB** of the Feena sprite rect (handles **`centered = false`** and scale). **40px** is a constant in **`feena_goal.gd`** (**`INTERACT_DISTANCE_PX`**).
- **Interact:** Same action as seeds / trash / cans: **`drop_seed`** (keyboard **E** in default maps) plus **`_p1` / `_p2`** suffix in split-screen.
- **Split-screen:** Both players contribute to **earned** total; either player can press interact in range to finish (first press wins; **`feena_goal`** sets **`_done`**).

### How to verify

1. Run **`game_singleplayer.tscn`**, walk to **Feena** at **`FinishLine`**: within **40px**, confirm **“Talk to Feena”** appears above the sprite; step back and confirm it hides.
2. In range, press **E** (**`drop_seed`**): confirm **level complete** overlay (**Memphis Riverfront**, **points earned / max**, three buttons), game **paused**, **Retry** refocuses after open.
3. **Retry**: reloads the current run; **Back to Map** / **Continue** (with empty **`next_level_scene`**): **`world_map.tscn`**; from map, **Level 1** returns to single-player.
4. **`game_splitscreen.tscn`**: confirm Feena hint and **P1/P2** interact both work; scores sum on the overlay.

---

## Pickup glow and soil proximity hint (2026-04-27)

This update adds a shared **80px** proximity halo for **seed** and **trash** pickups (light yellow radial gradient, drawn **behind** the pickup sprite), centralizes distance and texture helpers in **`PickupNearPlayer`**, and replaces any soil **glow** experiment with a short **on-screen label** when a player is near a patch **while holding a seed**.

### New file

| File | Role |
|------|------|
| **`pickups/pickup_near_player.gd`** | `class_name PickupNearPlayer`: **`GLOW_DISTANCE_PX` (80)**, **`any_player_within_glow_distance(tree, world_pos)`** (any player in group **`player`** within range), **`any_seed_carrier_within_glow_distance(tree, world_pos)`** (same radius, requires **`get_held_seed_kind() != NONE`**), **`radial_glow_texture()`** (cached **`GradientTexture2D`**, radial fill, faint light yellow center → transparent edge). |

### Pickups (`pickups/seed_pickup.gd`, `pickups/trash_pickup.gd`)

| Change | Detail |
|--------|--------|
| **Proximity glow** | Runtime **`ProximityGlow`** `Sprite2D` child on the pickup **`Area2D`**, **`z_index = 1`**, moved to child index **0**; pickup **`Sprite2D`** stays at scene **`z_index = 2`** so the halo draws **under** the art. |
| **Texture / scale** | Uses **`PickupNearPlayer.radial_glow_texture()`**; scale **`0.65`** (world ~83px diameter for the 128px texture). |
| **Visibility** | Each physics frame: **`any_player_within_glow_distance`** from sprite **`global_position`**; **`global_position`** synced to the pickup sprite. |
| **Removed** | Dependency on a missing **`pickup_proximity_outline.gdshader`** / outline material (replaced entirely by the glow path). |
| **Editor** | **`seed_pickup.gd`** (`@tool`): glow setup runs only when **`not Engine.is_editor_hint()`** (same as signal wiring). |

### Soil drop zones (`pickups/soil_drop_zone.gd`)

| Change | Detail |
|--------|--------|
| **No sprite glow** | Earlier soil-specific glow approaches (sibling under **`Soils`**, scaled to patch, same radial texture as pickups) were **removed** in favor of text. |
| **Label** | **`CanvasLayer`** (layer **58**) + **`Label`** text **`a patch of soil`**, themed like **`pickups/planted_tree_prompt.gd`** (`**gui/theme.tres**` default font, size **13**, white text, black outline). |
| **When shown** | **`any_seed_carrier_within_glow_distance`** from **soil sprite center** (80px, **must be carrying a seed**). |
| **Position** | Screen position from **`viewport.get_canvas_transform() * _hint_world_position()`** (label above patch, consistent with other soil hint Y offset). |
| **Lifecycle** | Built in **`_ready`**; **`_free_soil_proximity_hint()`** on **`_retire_drop_zone_for_plant()`** (after planting). |

### Design notes (soil vs pickup)

- **Pickups:** glow is a **child** of the **`Area2D`** with fixed **`z_index`** vs the sprite.
- **Soils:** UI is **screen-space** **`Control`** text (not a world **`Sprite2D`** behind the dirt), so **cypress `modulate`** and **soil scale** do not affect readability; proximity for the string is **seed-carrier-only**, unlike pickups’ glow (any player in range).

### How to verify

1. **Seeds / trash:** Stand within ~80px of a pickup without interacting; confirm a soft **yellow radial halo** appears **behind** the sprite; move away and confirm it hides.
2. **Soil:** With **no** seed, approach within 80px; confirm **no** “a patch of soil” label. Pick up a seed, approach the same patch; confirm the label appears above the soil and tracks on screen. Plant and confirm the label **does not** return for that zone.

---

## Level time-direction plant growth and maturity lock (2026-04-20)

This update ties soil growth playback to level-wide time direction derived from player horizontal movement. Growth now advances while moving right, rewinds while moving left, and pauses while idle. Once a tree reaches full maturity, it is locked as an adult and no longer rewinds.

### Changes

| File | Change |
|------|--------|
| **`level/level.gd`** | Added **`time_direction_changed(direction: int)`** signal, **`_time_direction`** state, **`get_time_direction()`**, and per-physics direction sampling from players in group **`player`** using **`velocity.x`** (`1`, `0`, `-1`). |
| **`pickups/soil_drop_zone.gd`** | Replaced one-way async timer growth with frame-by-frame progress state (**`_growth_progress`**), driven by level time direction. |
| **`pickups/soil_drop_zone.gd`** | Added maturity lock (**`_growth_maturity_locked`**): once progress reaches full (`1.0`), tree remains adult even if time direction flips left. |
| **`pickups/soil_drop_zone.gd`** | Growth speed tuned to **75% faster** than the original baseline (`GROWTH_STEP_DURATION_MULT = 1.7142857`, equivalent to baseline `3.0 / 1.75`). |
| **`pickups/soil_drop_zone.gd`** | Tree name prompt lifecycle now follows maturity state via completion checks. (**Willow seed 2** drop revised: per patch at **~90%** growth — see [Session update: level complete…](#session-update-level-complete-for-all-levels-willow-seed-drops-2026-05-10).) |

### Behavioral rules

- **Right movement:** growth progresses forward.
- **Left movement:** growth rewinds only before maturity lock.
- **Idle movement:** growth stays at current progress.
- **Mature tree:** persists as adult (`Black Willow Tree` / `Blue Cypress Tree`) and does not regress.

### How to verify

1. Plant willow or cypress and hold right movement: confirm growth advances faster than previous baseline.
2. Before full maturity, hold left movement: confirm growth rewinds.
3. Grow the same plant to full adult state, then hold left movement: confirm no visual regression.
4. For each **willow** soil with a planted willow seed, confirm a **willow seed 2** pickup **falls** when growth first crosses **~90%** (each patch once per tree).

---

## Finish marker Feena idle swap (2026-04-20)

This update replaces the old brown `FinishLine` square with animated `Feena` idle art and matches the marker animation speed to the Lawrence idle cadence used by `player/player.gd`.

### Changes (`level/level.tscn`)

| Path / node | Change |
|-------------|--------|
| `FinishLine/Square` | Node type changed from **`Polygon2D`** to **`Sprite2D`**. |
| `FinishLine/Square` texture | Uses scene-local **`AnimatedTexture_feena_idle`** instead of a solid-color polygon. |
| `AnimatedTexture_feena_idle` frames | `F_idle1.png`, `F_idle2.png`, `F_idle3.png` from **`level/props/Feena/idle/`**. |
| `AnimatedTexture_feena_idle` speed | `fps = 0.14285715` ( `1 / 7` ), matching Lawrence idle’s base **`IDLE_FRAME_DURATION = 7.0`** from `player/player.gd`. |

### Notes

- **Update (2026-04-27):** Completion is no longer “visual only”; **`FinishLine`** runs **`feena_goal.gd`** (proximity label + **`drop_seed*`** to open the level complete flow). See [Level complete screen, world map, and Feena goal (2026-04-27)](#level-complete-screen-world-map-and-feena-goal-2026-04-27).
- The table above still describes **`FinishLine/Square`** art and **`AnimatedTexture_feena_idle`** timing only.
- Parent/child placement and marker draw layer are unchanged (`FinishLine` still uses `z_index = 3`).

### How to verify

1. Run `game_singleplayer.tscn` and go to the finish marker area.
2. Confirm the marker renders Feena idle art (not a brown square) and animates slowly at Lawrence-like idle pacing.

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
| Count | Main **`level.tscn`** and **`level_2.tscn`** each place **seven** trash instances; two **`TrashCan`** scenes accept deposits (**no per-can quota** since [Trash cans, Feena interact, and scoring cap (2026-05-10)](#trash-cans-feena-interact-and-scoring-cap-2026-05-10); historically **`pieces_required` 4+3** split the seven across cans). |
| Completion | Earlier revisions disabled each can’s **`DropZone`** after its quota; **`trash_can.gd`** **no longer** **`queue_free()`**s every **`trash_pickup`** in the tree (unpicked trash stays). |

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
2. Deposit trash at **either** can while carrying litter (**`drop_seed*`**); remaining trash on the ground **stays** until picked up.
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
| **`level/props/Sun.png`** (+ **`.import`**) | Texture drawn by **`SunBehindClouds`** / **`sun_parallax_layer.gd`** in **`parallax_background.tscn`** (between **Sky** and **Clouds**); see [Score HUD, world points popups, soil feedback, and sun overlay (2026-04-19)](#score-hud-world-points-popups-soil-feedback-and-sun-overlay-2026-04-19). |

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
| Level time-direction growth + mature lock | [Level time-direction plant growth and maturity lock (2026-04-20)](#level-time-direction-plant-growth-and-maturity-lock-2026-04-20) |
| Finish marker art/speed update (`Feena/idle`) | [Finish marker Feena idle swap (2026-04-20)](#finish-marker-feena-idle-swap-2026-04-20) |
| Level complete UI, world map, **`GameLevel`** exports, Feena talk-to-finish | [Level complete screen, world map, and Feena goal (2026-04-27)](#level-complete-screen-world-map-and-feena-goal-2026-04-27) |
| Pickup proximity glow (**`PickupNearPlayer`**), soil **“patch of soil”** hint | [Pickup glow and soil proximity hint (2026-04-27)](#pickup-glow-and-soil-proximity-hint-2026-04-27) |
| Score, floating `+points` / hints, parallax sun (behind clouds), [file list](#files-touched-score-popups-soil-sun) | [Score HUD, world points popups, soil feedback, and sun overlay (2026-04-19)](#score-hud-world-points-popups-soil-feedback-and-sun-overlay-2026-04-19) |
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
| **Score HUD, world points popups, soil feedback, and sun overlay (2026-04-19)** | **`Player.score`**, trash/soil **points**, **`gui/score_hud.*`**, **`gui/points_popup.gd`**, **`pickups/soil_drop_zone.gd`** wrong-seed hint, **`level/background/sun_parallax_layer.gd`** + **`parallax_background.tscn`**, **`game.gd`** / **`game_splitscreen.gd`**; [Files touched…](#files-touched-score-popups-soil-sun) |
| **Level time-direction plant growth and maturity lock (2026-04-20)** | **`level.gd`** time-direction signal/state and **`soil_drop_zone.gd`** reversible growth progress, maturity lock, and faster growth tuning. |
| **Finish marker Feena idle swap (2026-04-20)** | `FinishLine/Square` in `level/level.tscn` switched to animated `Feena/idle` (`AnimatedTexture`), cadence matched to Lawrence idle (`1/7` fps). |
| **Level complete screen, world map, and Feena goal (2026-04-27)** | **`gui/level_complete_screen.*`**, **`gui/world_map.*`**, **`game.gd`** **`present_level_complete` / `game_controller`**, **`GameLevel`** **`level_display_name` / `next_level_scene` / `get_max_achievable_points`**, **`feena_goal.gd`** on **`FinishLine`**; removed **`finish_zone.gd`** and **`FinishTrigger`**; [Files touched (paths)](#files-touched-paths) and [Buttons](#buttons-levelcompletescreen) in that section. |
| **Pickup glow and soil proximity hint (2026-04-27)** | **`pickups/pickup_near_player.gd`**, seed/trash glow, soil **“a patch of soil”** label when carrying a seed near a patch. |
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

**Policy change (2026-05-11):** Prefer **`aspect=keep`** so the logical viewport stays **16:9** with **letterboxing/pillarboxing** instead of **`expand`**; see the update note under the settings table below.

### Project settings (`project.godot`)

| Setting | Before | After |
|---------|--------|--------|
| `display/window/size/viewport_width` | 800 | **960** |
| `display/window/size/viewport_height` | 480 | **540** |
| `display/window/size/window_width_override` | 1600 | **1920** |
| `display/window/size/window_height_override` | 960 | **1080** |
| `display/window/stretch/aspect` | `keep_height` | **`expand`** |
| `display/window/stretch/scale_mode` | `integer` | **`fractional`** |

**Update (2026-05-11):** The table above records the demo-wide **16:9 + expand + fractional** pass. The project now uses **`window/stretch/aspect="keep"`** (uniform scale; letterbox/pillarbox on non–16:9 windows; no viewport expand). See [Display stretch keep and map hub Level 2 button (2026-05-11)](#display-stretch-keep-and-map-hub-level-2-button-2026-05-11). **`scale_mode`** may still appear in older notes; check **`project.godot`** for the current value.

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
| `project.godot` | Description + removed shoot inputs; **16:9** viewport + window override; stretch was **`expand`** + **`fractional`** in that pass ([Display and viewport (16:9)](#display-and-viewport-169)); **2026-05-11** sets **`aspect=keep`** ([Display stretch keep and map hub Level 2 button (2026-05-11)](#display-stretch-keep-and-map-hub-level-2-button-2026-05-11)) |
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

This section documents features added after the original demo trim: placeholder seed and soil art, **single-carry** pickup/planting, **wrong-family soil hint** (no standing “plant here” label), **plant-time score** / **`+points`** toasts, and on-screen pickup messages. Cross-file table: [Files touched (score, popups, soil, sun)](#files-touched-score-popups-soil-sun).

### Design

- **Single carry:** The player holds at most one seed at a time. Picking up a second seed while already holding one does nothing (the pickup stays in the world until the slot is free).
- **Willow soils (shared rule):** Patches configured as **willow** (`SeedDefs.Type.WILLOW_1` or `WILLOW_2` on the drop zone) accept **either** **willow tree seed** (willow 1 or willow 2). The player does not need to match a specific willow seed to a specific willow soil.
- **Cypress soil:** Only **cypress** seed can be planted there.
- **Pickup feedback:** While overlapping a seed, pressing **`drop_seed`** (see Input) plays **`player/coin_pickup.wav`** (reused), removes the pickup, and shows a timed notification banner.
- **Planting feedback:** Successful drop applies a light green **modulate** on the soil sprite and disables further drops on that patch. **Points** for planting are granted **at successful drop** (not when growth finishes); see [Score HUD, world points popups…](#score-hud-world-points-popups-soil-feedback-and-sun-overlay-2026-04-19).
- **Wrong-family seed at soil:** There is **no** standing “plant here” label. If the player presses **`drop_seed*`** on a patch while holding **cypress on willow soil** or **willow on cypress soil**, a short toast **`try a different seed`** appears above the patch (same typography as transient score text).

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
| `pickups/soil_drop_zone.gd` | On **`Soils/*`** sprites: child **`DropZone`** `Area2D` with **`@export accepts`** (`SeedDefs.Type`). Tracks overlapping **`Player`**s. On **`drop_seed` + `player.action_suffix`**, if held seed is **compatible**, plants and tints parent **`Sprite2D`**, awards **soil plant points** and a **`+N points`** toast (see [Score HUD…](#score-hud-world-points-popups-soil-feedback-and-sun-overlay-2026-04-19)), then drives growth as a continuous progress state on a **`PlantedGrowth`** child. Progress follows **`level.gd`** time direction: **right = forward**, **left = reverse**, **idle = pause**; reversal applies only until full maturity, then growth is locked as adult. Current tuning is **75% faster** than baseline (`GROWTH_STEP_DURATION_MULT = 1.7142857`). If the player holds the **wrong family** (cypress on willow patch or willow on cypress) and presses **`drop_seed*`**, shows **`try a different seed`** via **`PointsPopup.spawn_message`** at the same world anchor used for score toasts. After maturity, **`planted_tree_prompt.gd`** shows **“Black Willow Tree”** or **“Blue Cypress Tree”** when overlapping the placeholder. Each **willow** patch (planted with **willow #1** or **willow #2**) calls **`level.gd` → `drop_willow_seed_2_from`** once when growth first reaches **~90%** toward full size (per-zone **`_willow_seed_2_dropped`**). **`drop_willow_seed_2_from`** instantiates **`willow_seed_2_pickup.tscn`** and tweens **`global_position`** from the tree top to a landing point (`willow_seed_2_pickup.gd`, **`Tween.tween_property`** on **`^"global_position"`**). See [Session update: level complete…](#session-update-level-complete-for-all-levels-willow-seed-drops-2026-05-10). **`RectangleShape2D`** size **100×72** in local space inherits each soil’s **`scale`**. |

### Player carry (`player/player.gd`, `player/player.tscn`)

- **Score:** integer **`score`**, signal **`score_changed(new_score)`**, **`add_score(amount)`**; trash/soil awards use **`POINTS_TRASH_DEPOSIT`** (**5**) and **`POINTS_SOIL_PLANT`** (**10**) — see [Score HUD, world points popups…](#score-hud-world-points-popups-soil-feedback-and-sun-overlay-2026-04-19).
- **`_held_seed`**, **`get_held_seed_kind()`**, **`try_pickup_seed(kind, ground_sprite_global_scale)`**, **`consume_held_for_soil(soil_kind)`** (willow-or-willow matching for any willow soil; cypress-only for cypress soil). **`try_pickup_seed`** refuses if the player is already holding **trash** (see [Trash and trash can](#trash-and-trash-can)).
- **`_holding_trash`**, **`try_pickup_trash(tex, ground_sprite_global_scale)`**, **`deposit_trash()`**, **`is_holding_trash()`** — mutually exclusive with carrying a seed.
- **`CarryVisual`** **`Sprite2D`**: shows the correct seed texture; overhead **world** size matches the pickup **`Sprite2D.global_scale`** at grab (via **`_carry_local_scale_from_ground_pickup`**); **`scale.x`** follows run direction.
- **`CarryTrashVisual`** **`Sprite2D`**: shows the carried trash texture with the same world-size rule; **`scale.x`** follows run direction like seeds.

### Level layout (`level/level.tscn`)

- **Root `Level`** **`Node2D`** uses **`level/level.gd`**: adds **`game_level`** group; sets camera limits for **`Player`** children; emits level time direction (**`time_direction_changed`**) from player horizontal movement; implements **`drop_willow_seed_2_from(world_top, world_land)`** for the delayed willow 2 pickup.
- **Pickups:** **`WillowSeed1Pickup`** (reference for **world scale / modulate** of runtime **willow #2** drops), **`CypressSeedPickup`** instanced under **`Level`**. Authored **`WillowSeed2Pickup`** instances were **removed** from **`level*.tscn`**; drops are **spawned** in **`drop_willow_seed_2_from`**.
- **`TrashCan`**, **`TrashCan2`**, **`Trash`–`Trash7`** (seven instances) — see [Trash and trash can](#trash-and-trash-can) and [Trash art, carry scale, Memphis loop, and decor vines (2026-04-19)](#trash-art-carry-scale-memphis-loop-and-decor-vines-2026-04-19).
- **`FinishLine`** (**`Node2D`**, **`z_index`** **3**) with child **`Square`** (**`Sprite2D`**) using scene-local **`AnimatedTexture_feena_idle`** from **`level/props/Feena/idle/F_idle1.png`**–**`F_idle3.png`** at **`fps = 0.14285715`** (Lawrence idle cadence: **`1 / IDLE_FRAME_DURATION`**). The **`FinishLine`** node runs **`feena_goal.gd`**: within **40px** of the sprite bounds, shows **“Talk to Feena”**; **`drop_seed*`** in range opens the **level complete** flow (see [Level complete screen, world map, and Feena goal (2026-04-27)](#level-complete-screen-world-map-and-feena-goal-2026-04-27)). Editor positions: parent **`(900, 576)`**, child offset **`(460, -249)`** (tune in **`level/level.tscn`**).
- **`level/level_2.tscn`**: duplicate of the level scene for a second layout (**different root scene `uid://`** from **`level.tscn`**; root node name **`Level 2`**). **Not** referenced by **`game_singleplayer.tscn`** / **`game_splitscreen.tscn`** until you instance it there or change the main level path.
- **`Soils`** **`Node2D`**: **`WillowSoil1`**, **`WillowSoil2`**, **`CypressSoil`** **`Sprite2D`** nodes (manual **`position`** / **`scale`**).
- Each soil has a **`DropZone`** child with **`soil_drop_zone.gd`**; **`accepts`** is **1**, **2**, or **3** in the scene file — **both 1 and 2 are treated as willow family** for compatibility checks.

### Project hygiene (historical)

- Empty default scenes **`control.tscn`** and **`node_2d.tscn`** were removed from the repository root when they were identified as unused saves.

### How to verify (planting loop)

1. Run **`game_singleplayer.tscn`** (main scene).
2. Stand on each seed and press **E**: hear pickup sound, see **5 s** bottom banner and carry icon.
3. Stand on a **willow** soil with **either** willow seed; press **E**: seed clears, soil tints, **`+10 points`** (default) toast above the patch, growth starts. Move **right** to advance growth; move **left** to reverse until full maturity; once mature, the adult tree persists and no longer rewinds. Repeat willow **#1** on **either** willow soil first to get **willow seed 2** dropped near that patch; pick it up with **E** on the fallen pickup.
4. Stand on **cypress** soil with **cypress** seed only; press **E** — same success behavior. With **willow** seed on **cypress** soil (or **cypress** on **willow**), press **E**: **`try a different seed`** toast; no plant.
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
- **`Trash`–`Trash7`**: seven trash pickups with per-instance **`trash_texture`** from **`level/props/Trash/*.png`**. **`TrashCan`** / **`TrashCan2`** are two deposit targets (**no per-can quota**; see [Trash cans, Feena interact, and scoring cap (2026-05-10)](#trash-cans-feena-interact-and-scoring-cap-2026-05-10)). See [Trash art, carry scale, Memphis loop, and decor vines (2026-04-19)](#trash-art-carry-scale-memphis-loop-and-decor-vines-2026-04-19).

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
- Deposit: overlap **`DropZone`** (or proximity fallback) + **`drop_seed*`** calls **`Player.deposit_trash()`**; **no per-can quota** — any can accepts every carried piece ([Trash cans, Feena interact, and scoring cap (2026-05-10)](#trash-cans-feena-interact-and-scoring-cap-2026-05-10)).
- **`DropZone`** stays **monitored** for the whole session; remaining **`trash_pickup`** nodes are **not** bulk-removed (**`trash_can.gd`** does not **`queue_free()`** the whole group).

### Files

| Path | Role |
|------|------|
| `pickups/trash_pickup.gd` | Overlap list + **`_physics_process`**; **`drop_seed` + suffix** → **`try_pickup_trash(tex, scale)`** → **`queue_free()`** on success. Registers **`trash_pickup`** group in **`_ready`**. |
| `pickups/trash_pickup.tscn` | Root node name **`Trash`**; **`Sprite2D`** + **`RectangleShape2D`**. |
| `pickups/trash_can.gd` | On successful **`deposit_trash()`**, adds **`Player.POINTS_TRASH_DEPOSIT`** (**5**) and spawns **`PointsPopup`** above the can. **No** per-can cap or **`DropZone`** shutdown ([Trash cans, Feena interact, and scoring cap (2026-05-10)](#trash-cans-feena-interact-and-scoring-cap-2026-05-10)). |
| `pickups/trash_can.tscn` | Root node name **`TrashCan`**. |

---

## Theme and UI text (`gui/theme.tres`, notifications, pause)

### `gui/theme.tres`

- **`Label`**: **`font_color`** white, **`font_outline_color`** black, **`outline_size`** **3** (readable text without panel backgrounds).
- **`Button`**: same outline settings so pause menu button labels match.

### `gui/pickup_notifications.gd`

- Root **`Control`** uses **`theme = preload("res://gui/theme.tres")`** so the banner label uses **Kenney Mini Square** (same family as pause **`Resume`**).
- Bottom strip is a **`ColorRect`** (**semi-opaque black**), **`layer`** **110**.

### `gui/points_popup.gd` (`PointsPopup`)

- Floating **`+%d points`** and arbitrary hint strings; full behavior under [Score HUD, world points popups, soil feedback, and sun overlay (2026-04-19)](#score-hud-world-points-popups-soil-feedback-and-sun-overlay-2026-04-19).

### `pickups/planted_tree_prompt.gd`

- **`Node2D`** added under **`PlantedGrowth`**: **`Area2D`** hitbox aligned to the grown-tree footprint; **`CanvasLayer`** + **`Label`** with theme font, white text, black outline; updates screen position in **`_physics_process`**.

### Pause menu (`gui/pause_menu.tscn`)

- **“Game Paused”** is a plain **`Label`** under **`VBoxContainer`** (no panel wrapper); outline comes from the shared theme on the root **`Control`**.

---

## Score HUD, world points popups, soil feedback, and sun overlay (2026-04-19)

This batch adds **per-player score**, **screen-space toasts** tied to trash cans and soils, **soil UX** without standing “plant here” prompts, and a **parallax sun** (**`SunBehindClouds`** in **`parallax_background.tscn`**) drawn **behind** cloud layers while following the active camera’s player (including split-screen).

### Scoring (`player/player.gd`, `pickups/trash_can.gd`, `pickups/soil_drop_zone.gd`)

| Constant / event | Value / when |
|------------------|--------------|
| **`Player.POINTS_TRASH_DEPOSIT`** | **5** — awarded on each successful trash deposit at a **`TrashCan`** (`trash_can.gd` after **`deposit_trash()`**). |
| **`Player.POINTS_SOIL_PLANT`** | **10** — awarded when a compatible seed is **planted** at a soil **`DropZone`** (`soil_drop_zone.gd` **`_try_plant`**, not when growth animation ends). |
| **`Player.score`**, **`score_changed(new_score)`**, **`add_score(amount)`** | Per-**`Player`** state; HUD listens for updates. |

### Score HUD (`gui/score_hud.gd`, `gui/score_hud.tscn`)

- **`CanvasLayer`** **`layer`** **95**, child of **`InterfaceLayer`** (same as pause’s parent).
- **`Game._ready()`** (`game.gd`) instantiates **`score_hud.tscn`** after the pause menu tree is ready.
- **Single player:** one label, top-right: **`Points: N`**.
- **Split-screen:** **`game_splitscreen.gd`** calls **`super._ready()`** so the HUD is created; two labels (**`P1:`** / **`P2:`** from **`action_suffix`**) at top-left and top-right, sorted by node **`name`**.
- **Memphis Riverfront:** no points strip — collapsible **A favor for Feena** checklist top-right; see [Memphis mission HUD, Feena-adjacent willow climb, and UI polish (2026-05-10)](#memphis-mission-hud-feena-adjacent-willow-climb-and-ui-polish-2026-05-10).

### World toasts (`gui/points_popup.gd`, `class_name` **`PointsPopup`**)

| API | Role |
|-----|------|
| **`spawn(player, world_position, amount)`** | **`+%d points`** toast at **`world_position`**, reprojected each frame; **~2.4 s** lifetime, upward drift + fade-out. **No-op** on **Memphis Riverfront** ([Memphis mission HUD…](#memphis-mission-hud-feena-adjacent-willow-climb-and-ui-polish-2026-05-10)). |
| **`spawn_message(player, world_position, message)`** | Same motion/styling for arbitrary text ( **`try a different seed`** on wrong-family soil press). |

**Viewport choice:** **`player.camera.custom_viewport`** when non-null (P2 in **`game_splitscreen.tscn`**), else **`player.get_viewport()`**. The toast node is parented to that **`Viewport`** so coordinates match the correct half of the window. **`SubViewportContainer.get_global_rect().position`** offsets into window space when needed.

**Trash can anchor:** **`trash_can.gd`** uses root **`global_position + Vector2(0, -72)`** for the toast.

**Soil anchors:** **`soil_drop_zone.gd`** uses **`_hint_world_position()`** = parent soil **`global_position + Vector2(0, -50)`** (or drop zone **`global_position`** if no soil parent).

### Soil prompts removed; wrong-family hint (`pickups/soil_drop_zone.gd`)

- **Removed:** persistent **`CanvasLayer`** / **`Label`** “Plant Willow / Cypress Seed Here” while overlapping soil.
- **Added:** on **`drop_seed*`** with **cypress** held on **willow** patch, or **willow** held on **cypress** patch, **`PointsPopup.spawn_message(..., "try a different seed")`** at **`_hint_world_position()`**.

### Sun behind clouds (`level/background/sun_parallax_layer.gd`, `level/background/parallax_background.tscn`)

- **`SunBehindClouds`** is a **`ParallaxLayer`** inserted **after `Sky`** and **before `Clouds`** in **`parallax_background.tscn`** so draw order is **sky → sun → clouds** (then other parallax layers).
- **`motion_scale = Vector2(0, 0)`** on that layer so it tracks the camera; placement maps **canvas** coordinates to **world** with **`Viewport.get_canvas_transform().affine_inverse()`**.
- **Player selection:** **`_player_for_active_camera()`** returns the **`Player`** whose **`camera`** reference equals **`get_viewport().get_camera_2d()`** (works in split-screen: **P1**’s camera in **`Viewport1`**, **P2**’s in **`Viewport2`** when each parallax instance renders).
- **Placement pipeline:** **`_update_sun_from_player()`** holds all logic. **`_ready`** ends with **`call_deferred("_update_sun_from_player")`** so the sun is aligned **before the first visible frame** once the active camera and player exist; **`_process`** calls the same function every frame so the sun follows the player.
- **Horizontal (code):** **`_RIGHT_OF_PLAYER_AXIS_PX = 40`** — **40 px** to the **right** of the player’s screen **x** (vertical line through the player) to the sun’s **left** edge; sun **`Sprite2D`** is **`centered`**, so the world position uses **half** the scaled texture width after that offset.
- **Vertical (code):** **`_TOP_THIRD_CENTER_FRAC = 1/6`** — vertical **center** of the sun at **`visible_rect.position.y + visible_rect.size.y * (1/6)`**, i.e. the **midline of the top third** of the visible viewport.
- **Parallax Y correction:** **`ParallaxBackground`** applies an extra transform to **`ParallaxLayer`** children, so canvas **`affine_inverse`** alone did not match final screen Y. **`_update_sun_from_player`** runs up to **6** iterations: set **`_sun.global_position`**, read **`_sun.get_global_transform_with_canvas().origin.y`**, adjust target canvas **y** by the error until the error is **under 0.75 px** or iterations end.
- **Size:** **`@export_range(8 … 1024) sun_max_dimension_px`** on the **`SunBehindClouds`** node (default **80**): uniform scale so the texture’s **longer** side is that many pixels.
- **Removed:** **`gui/sun_overlay.gd`** and **`gui/sun_overlay.tscn`** (screen **`CanvasLayer`** sun). **`game.gd`** only instantiates the score HUD under **`InterfaceLayer`** — it does **not** add a sun node.

### Files touched (score, popups, soil, sun)

| Path | Role |
|------|------|
| **`player/player.gd`** | **`POINTS_TRASH_DEPOSIT`**, **`POINTS_SOIL_PLANT`**, **`score`**, **`score_changed`**, **`add_score()`**. |
| **`pickups/trash_can.gd`** | **`Player.add_score`** + **`PointsPopup.spawn`** on successful **`deposit_trash()`**. |
| **`pickups/soil_drop_zone.gd`** | No standing “plant here” UI; wrong-family seed → **`PointsPopup.spawn_message`** **`try a different seed`**; compatible plant → **`add_score`** + **`PointsPopup.spawn`** in **`_try_plant`** (not at growth end). |
| **`gui/score_hud.gd`**, **`gui/score_hud.tscn`** | Top-of-screen **points** labels; one vs two players; **Memphis** mission checklist instead of points ([Memphis mission HUD…](#memphis-mission-hud-feena-adjacent-willow-climb-and-ui-polish-2026-05-10)). |
| **`gui/points_popup.gd`** | **`PointsPopup.spawn`** / **`spawn_message`**; viewport from **`camera.custom_viewport`** or **`get_viewport()`**. |
| **`game.gd`** | **`_ready`**: instantiate **`score_hud.tscn`** on **`InterfaceLayer`**. |
| **`game_splitscreen.gd`** | **`super._ready()`** so **`Game`** HUD setup runs. |
| **`level/background/sun_parallax_layer.gd`** | **`SunBehindClouds`** script: **`Sprite2D`**, **`_update_sun_from_player`**, deferred first placement, parallax Y loop, **`_player_for_active_camera`**. |
| **`level/background/parallax_background.tscn`** | **`ext_resource`** script **`id="8"`**; **`SunBehindClouds`** **`ParallaxLayer`** between **Sky** and **Clouds**. |
| **`CHANGELOG.md`**, **`README.md`**, **`project.godot`** | **`config/description`** and prose updated for score, toasts, soil hint, parallax sun. |

### How to verify

1. Run **`game_singleplayer.tscn`**: confirm **sun** is correct **on the first frame** (no jump from a wrong starting Y), in the **upper third**, **behind** cloud art, **in front of** sky; **40 px** past the player’s screen column (rule above). Deposit trash / plant seeds — **`+5`** / **`+10`** toasts and **Points** label update.
2. Stand on wrong-family soil with wrong seed; press **E**: **`try a different seed`**; no plant / no growth.
3. Run **`game_splitscreen.tscn`**: confirm score HUD; each pane’s sun follows **that** viewport’s camera/player.

---

## Willow seed 2 delayed pickup (`pickups/willow_seed_2_pickup.gd`)

- Extends **`seed_pickup.gd`** but overrides **`_ready`**: starts **`monitoring = false`**, **`visible = false`** until **`begin_fall_from`** runs.
- **`begin_fall_from(world_top, world_land)`**: tween **`global_position`** with **`Tween.tween_property(self, ^"global_position", …)`** (Godot **4.6** expects a **`NodePath`**, not **`StringName`**).
- **`fall_duration_sec`** export (default **~0.55**).
- **Spawn path:** the level no longer relies on a placed **`WillowSeed2Pickup`** node; **`level/level.gd`** and **`level 2/level.gd`** **`instantiate()`** this scene from **`drop_willow_seed_2_from`** (see [Session update: level complete for all levels, willow seed drops](#session-update-level-complete-for-all-levels-willow-seed-drops-2026-05-10)).

---

## Session update: level complete for all levels, willow seed drops (2026-05-10)

Single reference for cross-cutting changes that touch **`gui/`**, **`game.gd`**, **`level/`**, **`level 2/`**, and **`pickups/`**. Supersedes older prose in [Level complete UX, Memphis completion stars, and hub map](#level-complete-ux-memphis-completion-stars-and-hub-map-2026-05-10), the [Soil drop zones](#soil-drop-zones) table row on **`soil_drop_zone.gd`**, step **4** under [Level time-direction plant growth…](#level-time-direction-plant-growth-and-maturity-lock-2026-04-20), and the **Willow seed 2 delayed pickup** subsection (later in this file).

### Level-complete overlay (every level)

| Path | Change |
|------|--------|
| **`gui/level_complete_screen.gd`** | **`TakeActionSection`** always **`visible = true`** in **`present()`**; always runs **`_apply_take_action_icon_min_sizes()`** and sets the four Take Action **`RichTextLabel`** BBCode strings (no **`level_index == 1`** gate). **`continue_button`** targets **`PrimaryActionsRow/NextLevelButton`**. |
| **`gui/level_complete_screen.tscn`** | **`SpacerBeforeTakeAction`** and **`SpacerBeforeButtons`** **`custom_minimum_size.y`** = **32** for extra vertical space. |
| **`game.gd`** | **`present_level_complete()`**: after Memphis **`level1_completion_stars_and_message`** when **`level_display_name`** matches **`memphis_mission_goals.display_name()`**, else if **`game_level`** has **`get_completion_stars_and_message`**, uses returned **`Dictionary`** for **`stars_filled`** and **`star_feedback`**. |
| **`level/level.gd`** | **`get_completion_stars_and_message(_tree)`** — **`level_index == 2`**: placeholder three stars + short caption; otherwise **`{ stars: 0, message: "" }`**. |
| **`level 2/level.gd`** | Same **`get_completion_stars_and_message`** returning **`{ stars: 0, message: "" }`** as fallback when Memphis branch does not apply. |
| **`game_level_1.tscn`** | **`level_display_name`** = **`Mississippi Riverbank`** to match Memphis goals **`display_name()`**. |

### Level-complete primary actions (one row)

| Path | Change |
|------|--------|
| **`gui/level_complete_screen.tscn`** | **`PrimaryActionsRow`**: **`← Retry Level`**, **`Go to Map`**, **`Next Level →`** (Unicode arrows). **`NextLevelButton`** is last; row **`custom_minimum_size.x`** **640**. No separate **`ContinueButton`** row. |
| **`gui/level_complete_screen.gd`** | **`present()`**: **`NextLevelButton`** visible when **`stars_filled >= 2`**; focus **Next Level** or **Retry**; handler **`_on_continue_button_pressed`** unchanged (loads **`get_continue_scene_path()`** or **`_LEVEL_SELECT_MAP`**). |

### Take Action block (shared template)

- Title, intro copy, four resource columns (**52px**-tall icons, blue BBCode links, **`OS.shell_open`** on **`meta_clicked`**) unchanged in intent; shown on **all** completion screens per **`level_complete_screen.gd`** above.
- Overlay chrome (**`ColorRect`** **`#002962`** alpha **0.9**, **`gui/theme.tres`**, outlines) remains scene-driven.

### Willow seed 2 — two drops, 90% trigger, runtime spawn, size match

| Path | Change |
|------|--------|
| **`pickups/soil_drop_zone.gd`** | Removed **static** once-global flag. Per **`DropZone`**: **`_willow_seed_2_dropped`**, reset in **`_start_growth_sequence`**. **`_WILLOW_SEED_DROP_PROGRESS := 0.9`**. **`_maybe_drop_willow_seed_2_at_threshold()`** after growth progress update (unlocked growth path); requires willow soil and planted **WILLOW_1** or **WILLOW_2**. **Removed** **`_maybe_release_willow_seed_2`** from **`_update_growth_completion_state()`** (maturity at 100% no longer required for the drop). |
| **`level/level.gd`**, **`level 2/level.gd`** | **`const _WILLOW_SEED_2_PICKUP_SCENE`** **`preload("res://pickups/willow_seed_2_pickup.tscn")`**; **`const _WILLOW_SEED_2_FALLBACK_SCALE`**. **`drop_willow_seed_2_from`**: **`instantiate()`**, copy **`scale`** / **`modulate`** from **`WillowSeed1Pickup`** **before** **`add_child`**, then **`p.global_scale = ref.global_scale`** when ref valid; else fallback scale; **`z_index = 2`**; **`begin_fall_from`**. |
| **`level/level.tscn`**, **`level 2/level.tscn`**, **`level/level_2.tscn`**, **`level 2/level_2.tscn`** | Removed **`WillowSeed2Pickup`** instanced node and the **`ext_resource`** for **`willow_seed_2_pickup.tscn`** where it was only used for that placed pickup. |

### How to verify

1. **Level complete:** Finish any level with the overlay — **Take Action** block appears; with **2+** stars, **Next Level →** is visible on the same row as **← Retry Level** and **Go to Map**.
2. **Memphis:** **`game_level_1`** — mission stars still apply when **`level_display_name`** matches goals **`display_name()`**.
3. **Willows:** Plant both willow soils; advance growth past **90%** each — **two** **willow #2** pickups fall; on-screen size matches the placed **`WillowSeed1Pickup`** on that map.

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
| **`level/level.tscn`** → **`FinishLine`** (**`Node2D`**) | **3** | Animated **`Sprite2D`** finish marker (`Feena/idle`) draws above **TileMap** / trash can band. |
| Seed / cypress pickups under **`Level`** | **2** | Set on each instance in **`level.tscn`**. |
| **`player/player.tscn`** → **`CarryVisual`**, **`CarryTrashVisual`** | **5** (relative) | Carried icon stays above the robot body. |

---
