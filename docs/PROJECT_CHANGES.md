# Project change log

Use **`git log`**, **`CHANGELOG.md`**, and this file’s history for past releases. After a large local session, you can paste a short “delta vs `main`” here; trim it once merged.

## Working tree vs `main` (local)

| Area | Change |
|------|--------|
| **Pause menu, sound, map hub (2026-05-13)** | Canonical: **[`CHANGELOG.md` — Pause menu refresh, global sound toggle, and map hub copy (2026-05-13)](../CHANGELOG.md#pause-menu-refresh-global-sound-toggle-and-map-hub-copy-2026-05-13)** — **`gui/pause_menu.*`**: dimmer **α = 0.7**, **InputMap**-driven keyboard help under buttons (**1/3** viewport width), **Esc** label, **splash** **Resume** / instance **Restart**; **`gui/sound_toggle.gd`** + **`project.godot`** **`SoundToggle`** autoload (**Master** bus mute, **CanvasLayer** **125**, dock left of **`mission_hud_panel`** when present); **`gui/score_hud.gd`** adds **`mission_hud_panel`** group; **`map/map.tscn`** **Memphis Aquifer** two-line **(Coming Soon)** label. |
| **Level 1 & 2 pre-level intros** | **[`CHANGELOG.md` — Level 1 intro screen… (2026-05-12)](../CHANGELOG.md#level-1-intro-screen-splash-style-buttons-and-map-hub-entry-2026-05-12)** — **`gui/level_1_intro.*`** (**`level/intro/`**), **`gui/level_2_intro.*`** (**`level 2/intro/`**); **`Content`** + **36** px bottom inset + clip; two-step **Continue** → **Start level**; **`map/map.gd`**: L1 → **`level_1_intro`**, L2 → **`level_2_intro`** (then gameplay scenes). |
| **Splash-style button script** | **`gui/splash_screen_button.gd`** on **`level_1_intro`**, **`level_2_intro`**, **`river_splash_menu`**, **`memphis_aquifer_placeholder`**, **`world_map`** (not **`map`** hub pins); **`refresh_after_content_change()`** after text swaps. |
| **Theme + completion UI** | **[`CHANGELOG.md` — Theme hub-aligned buttons… (2026-05-12)](../CHANGELOG.md#theme-hub-aligned-buttons-level-3-aquifer-placeholder-and-level-2-completion-captions-2026-05-12)** — **`gui/theme.tres`** **`Button`** = map hub card look; **`level_complete_screen`** buttons use theme; **pause / river splash / world map** inherit the same **`Button`** defaults. |
| **Level 3 hub teaser** | **`map/memphis_aquifer_placeholder.*`**, **`level 3/Lswim.png`**, **`map/map.gd`** / **`map.tscn`** **Memphis Aquifer** → placeholder scene (title, body, **Back to map**). |
| **Level 2 level-complete captions** | **`gui/level2_mission_goals.gd`** **`level2_completion_stars_and_message`**; **`level 2/level.gd`** **`get_completion_stars_and_message`** when **`use_memphis_mission_hud`**. |
| **Mission HUD (Level 2)** | Canonical: **[`CHANGELOG.md` — Level 2 Beale mission HUD, strike logic, and Christie (2026-05-11)](../CHANGELOG.md#level-2-beale-mission-hud-strike-logic-and-christie-2026-05-11)** — **`gui/level2_mission_goals.gd`**, **`gui/score_hud.gd`**, **`gui/points_popup.gd`**, **`level 2/level.gd`** **`use_memphis_mission_hud`**, **`level_2.tscn`**; **Christie** PLAY-end → **`christie_performance_complete`**; butterflies → **`level2_monarch_butterfly`**. |
| **Post-interaction AC gate** | **`post_interaction_celebration.gd`** uses **`level2_mission_goals.ac_upgrades_all_complete`** (same as HUD row 2). |
| **Level 2 — post-interaction celebration** | Full write-up: **[`CHANGELOG.md` — Level 2 post-interaction celebration (2026-05-11)](../CHANGELOG.md#level-2-post-interaction-celebration-2026-05-11)**. Summary: **`PostInteractionDirector`** + **`post_interaction_celebration.gd`**, **`bstreet_roof_reveal.gd`** **`are_all_roofs_complete()`**, **`ac_old_unit.gd`** group **`ac_old_unit`**. |
| **Level 2 clouds** | **`level 2/level_2.tscn`**: small **`Sprite2D`** **`position`** edits under **`Clouds/CloudGroup1`** (**`Sprite2`**, **`Sprite5`**, **`Sprite6`**) and **`Clouds/CloudGroup3`** (**`Sprite2`**, **`Sprite8`**) — parallax cloud placement only. |
| **Untracked** | **`level 2/BStreet copy.png`** (+ **`.import`**) — duplicate of **`BStreet.png`**; do **not** commit. |
| **Level 2 — Bruno / AC / décor** | See **`CHANGELOG.md`** section *Level 2 Beale: Bruno finish, AC façade upgrade, foreground decor, bag prop (2026-05-11)*: **`bruno_goal`**, **`FinishLine`**, **`ac_old_unit`**, **`tree_depth_vs_player`** on **`T9`**, selected **tree/bush** **`z_index`**, **`BagProp`**. |
| **Level 2 — planters, bag tools, pickup strip** | **`CHANGELOG.md`** → *Level 2 planters, bag-gated interactions, pickup strip (2026-05-11)*: bag **`Lawrence/bag_*/*.png`**; AC + roof **blocked hints** until bag outfit; **`show_pickup_line`** (Bruno’s bag); **`planter_carry_pickup`** / **`planter_drop_zone`** (×2); van planter handoff in **`post_interaction_celebration.gd`**; **`FinishLine`** behind player; **`level_2`** **`FinishLine`** script → **`bruno_goal.gd`**. |
| **Paulo → Bruno** | **`paulo_goal`** removed; **`level 2/props/Paulo/`** deleted; **`bruno_goal.gd`** + **`level 2/props/Bruno/`** added (see **`git status`**). |
| **Other assets** | **`roadtile.png`**, **`van*.png`**, **`pickup_notifications.gd`**, **`player/player.gd`**, **`map`**, **`project`**, **`gui/theme`** / **`level_complete_screen`** per branch diff — use **`git diff --stat`**. |
| **UI polish + controls docs (2026-05-13)** | **[`CHANGELOG.md` — Level-complete copy/assets… (2026-05-13)](../CHANGELOG.md#level-complete-copyassets-non-white-button-states-pause-spacing-and-readme-controls-2026-05-13)** — Level 2 completion heading/copy/icon swap; intro/splash/map-style button non-white runtime enforcement; glow removal; README controls refresh. (Pause spacing **8** and later pause/sound work: **[Pause menu refresh…](../CHANGELOG.md#pause-menu-refresh-global-sound-toggle-and-map-hub-copy-2026-05-13)**.) |

---

## Latest session (pause keyboard help, global sound toggle, map aquifer copy) — 2026-05-13

Canonical detail: **[`CHANGELOG.md` — Pause menu refresh, global sound toggle, and map hub copy (2026-05-13)](../CHANGELOG.md#pause-menu-refresh-global-sound-toggle-and-map-hub-copy-2026-05-13)**.

| Topic | Detail |
|------|--------|
| **Pause** | **`pause_menu.gd`**: builds keyboard lines from **`InputMap`**; **Esc** string; help label width = viewport **/ 3**; **`Viewport.size_changed`**. **`pause_menu.tscn`**: **ColorRect** **α = 0.7**; **Resume** uses **`splash_screen_button.gd`**; **ControlsSpacer** + **PlayerControlsLabel** after **Quit**; **VBox** **separation** **8**. **`pause_menu_singleplayer.tscn`**: **Restart** — **splash** script, shrink center, index **3**. |
| **Sound** | **`SoundToggle`** autoload **`gui/sound_toggle.gd`**: **Sound OFF** / **Sound ON** toggles **`AudioServer`** **Master** bus mute; **layer** **125**, **`PROCESS_MODE_ALWAYS`**; default top-right; beside **`mission_hud_panel`** in gameplay. |
| **Mission HUD** | **`score_hud.gd`**: mission **`PanelContainer`** joins group **`mission_hud_panel`**. |
| **Map** | **`map.tscn`**: **Memphis Aquifer** button — two-line **(Coming Soon)**; taller **`offset_bottom`**. |
| **Docs** | **`CHANGELOG.md`**, **`docs/PROJECT_CHANGES.md`**, **`README.md`** (sound toggle line under **Player controls**). |

---

## Latest session (UI polish, completion copy/assets, controls docs) — 2026-05-13

Canonical detail: **[`CHANGELOG.md` — Level-complete copy/assets, non-white button states, pause spacing, and README controls (2026-05-13)](../CHANGELOG.md#level-complete-copyassets-non-white-button-states-pause-spacing-and-readme-controls-2026-05-13)**.

| Topic | Detail |
|------|--------|
| **Level 2 completion** | `level_complete_screen.gd` now forces heading **Level 2: Beale Street** for `level_index == 2`, uses Beale-specific intro/first-column copy, and guards cleanup icon as static texture to avoid AC-loop animation bleed. |
| **Take Action icon art** | `level_complete_screen.tscn` icon resources changed to **`level 2/props/paint.png`**, **`level 2/props/ACs/new/new_ac1.png`**, **`level 2/props/butterfly/bfly2.png`**, **`level/props/Tree_Cypress/Cypress3.png`**. |
| **Buttons (no white text)** | `splash_screen_button.gd` hot/idle colors are non-white; glow removed. `level_1_intro.gd` / `level_2_intro.gd` now apply explicit non-white font overrides across all button states for Continue/Start text in runtime. |
| **Related UI tweaks** | `theme.tres` button icon hover/pressed tint moved off white; `score_hud.gd` mission header button uses non-white states without glow. Pause menu spacing **8** was part of this batch; the larger pause/sound/map pass is **[Pause menu refresh…](../CHANGELOG.md#pause-menu-refresh-global-sound-toggle-and-map-hub-copy-2026-05-13)**. |
| **README controls** | Controls section rewritten as **Player controls** from current `project.godot` single-player mappings; stale split-screen/P2 notes removed. |

---

## Latest session (Level 2 intro + intro layout refresh) — 2026-05-13

Canonical detail: **[`CHANGELOG.md` — Level 1 intro screen, splash-style buttons, and map hub entry (2026-05-12)](../CHANGELOG.md#level-1-intro-screen-splash-style-buttons-and-map-hub-entry-2026-05-12)** (section now covers **L1** and **L2**).

| Topic | Detail |
|------|--------|
| **Level 2 intro** | **`gui/level_2_intro.tscn`** / **`level_2_intro.gd`**: same two-step pattern as Level 1; art **`level 2/intro/`**; title **Level 2: Beale Street**; next **`game_level_2.tscn`**. |
| **Map** | **`map/map.gd`** **`LEVEL_2_ENTRY_SCENE`** → **`res://gui/level_2_intro.tscn`**. |
| **Level 1 layout** | **`Content`** layer (**`clip_contents`**, runtime **`offset_bottom = -36`**); **Continue** / **Start level** positioned with **`get_rect()`** under **`DialoguePlate`** inside **`Content`**; **`splash_screen_button.refresh_after_content_change()`** after label changes. |

---

## Latest session (Level 1 intro + splash buttons + map entry) — 2026-05-12

Canonical detail: **[`CHANGELOG.md` — Level 1 intro screen, splash-style buttons, and map hub entry (2026-05-12)](../CHANGELOG.md#level-1-intro-screen-splash-style-buttons-and-map-hub-entry-2026-05-12)**.

| Topic | Detail |
|------|--------|
| **Template removed** | **`gui/level_intro.*`**, **`level_intro_level_*.tscn`** deleted; per-level **`level_*_intro`** scenes. |
| **Art** | **L1:** **`level/intro/`** backgrounds + **`dialogue1`/`dialogue2`**; tree **Background** → **Content** (title, dialogue, **Continue**). |
| **Map** | **Memphis Riverfront** → **`level_1_intro.tscn`** → **`game_singleplayer.tscn`**; **Beale Street** → **`level_2_intro.tscn`** → **`game_level_2.tscn`**. |

---

## Latest session (documentation — theme, Level 3 teaser, Level 2 stars) — 2026-05-12

Canonical detail: **[`CHANGELOG.md` — Theme hub-aligned buttons, Level 3 aquifer placeholder, and Level 2 completion captions (2026-05-12)](../CHANGELOG.md#theme-hub-aligned-buttons-level-3-aquifer-placeholder-and-level-2-completion-captions-2026-05-12)**.

| Topic | Detail |
|------|--------|
| **Buttons** | **`theme.tres`** matches **`map`** hub **`StyleBoxFlat`** + font/outline. |
| **Aquifer** | Full-screen **`Lswim`**, overlay copy, **Back**; **Memphis Aquifer** hub button. |
| **L2 complete** | Stars and caption strings from **`level2_completion_stars_and_message`**. |

---

## Latest session (documentation — Level 2 mission HUD + working tree) — 2026-05-11

Canonical detail: **[`CHANGELOG.md` — Level 2 Beale mission HUD, strike logic, and Christie (2026-05-11)](../CHANGELOG.md#level-2-beale-mission-hud-strike-logic-and-christie-2026-05-11)**.

| Topic | Detail |
|------|--------|
| **Checklist** | Row **1** roofs (**`BStreet.are_all_roofs_complete()`**), row **2** all **`ac_old_unit`** upgraded, row **3** **`level2_monarch_butterfly`** present. |
| **Gold line** | **`christie_performance_complete`** group after Christie **PLAY** phase holds (**`level2_christie_npc.gd`**). |
| **Broader tree** | **`CHANGELOG`** “Related working-tree items” + table above; **`git status`** for the full list. |

---

## Latest session (Level 2 — planters, bag-gated tools, carry) — 2026-05-11

Canonical detail: **[`CHANGELOG.md` — Level 2 planters, bag-gated interactions, pickup strip (2026-05-11)](../CHANGELOG.md#level-2-planters-bag-gated-interactions-pickup-strip-2026-05-11)**.

| Topic | Detail |
|------|--------|
| **Layering** | **`FinishLine`** **`z_index`** below player so the goal square does not cover Lawrence. |
| **Bag** | **`player/player.gd`** uses **`Lawrence/bag_*/*.png`**; **`has_lawrence_bag_outfit_active()`** gates AC hold and roof stamp. |
| **Blocked hints** | **`ac_old_unit.gd`**, **`bstreet_roof_reveal.gd`** — **`CanvasLayer` 58** + **`theme.tres`** label (**13px**, **outline 3**): replace AC / weatherize roof copy until bag is worn. |
| **Toasts** | **`PickupNotifications.show_pickup_line`** for Bruno’s bag; **`show_pickup("planter.")`** for planters (same strip as seeds). |
| **Van** | **`post_interaction_celebration.gd`** — planter sprites behind van while stopped; **`planter_carry_pickup`** spawns when van leaves (**not** **`trash_pickup`**). |
| **Drop zones** | **`PlanterDropZone1`**, **`PlanterDropZone2`** — **“Missing plant”** until **`planter1`** deposited; **`planter_drop_zone.gd`** + **`PolygonFill`**. |
| **Carry** | Planter-only carry raises **`CarryTrashVisual`** local **Y** so the face stays visible. |
| **Docs / wiring** | **Paulo → Bruno** in **`README`** and docs; **`level_2.tscn`** **`FinishLine`** → **`bruno_goal.gd`**; **`planter_drop_zone.tscn`** script UID ↔ **`.gd.uid`**. |

---

## Latest session (Level 2 — post-interaction celebration) — 2026-05-11

Canonical detail: **[`CHANGELOG.md` — Level 2 post-interaction celebration (2026-05-11)](../CHANGELOG.md#level-2-post-interaction-celebration-2026-05-11)**.

| Topic | Detail |
|------|--------|
| **Gates** | All **`ac_old_unit`** instances complete (**`is_ac_upgrade_complete()`**); **`BStreet`** **`are_all_roofs_complete()`** (≥1 stamp each on **Pink / Yellow / Green** roofs while feet on that façade). |
| **Notes** | Four **`mnotes`** **`@2x`** billboards; **`note_height_px`** (default **32**); drift inside **`level.gd`** scroll bounds; **persist** after spawn; holder **`z_index = 24`**. |
| **Timing** | **3 s** after gates with notes visible → wait **`is_on_floor()`** → **3 s** → **van** tweens. |
| **Van** | **`van_height_px`** (default **170**); path midpoint **X** = scroll limits midpoint (**500** at **−1200…2200**); **`z_index` 5** + **`z_as_relative`** to match **`Player`** vs **`tree_depth_vs_player.gd`**. |
| **Scene** | **`level 2/level_2.tscn`**: **`PostInteractionDirector`** (**`Node`**) + script **`ext_resource`**. |

---

## Latest session (Level 2 — Bruno, AC interact, depth, bag) — 2026-05-11

Cross-reference: **`CHANGELOG.md`** → *Level 2 Beale: Bruno finish, AC façade upgrade, foreground decor, bag prop (2026-05-11)*.

| Topic | Detail |
|------|--------|
| **Bruno** | **`level 2/bruno_goal.gd`** on **`FinishLine`**: **Talk to Bruno**, **`drop_seed*`** to **`present_level_complete()`**, wipe/idle loop, height from measured Lawrence sprite AABB + multiplier, slower transitions, editor-visible first frame. |
| **AC units** | **`ac_old_unit.tscn`** + **`ac_old_unit.gd`** + **`AcOldLoadWheel`**: hold interact fills ring; release/out of range resets; 100% swaps **`old_ac*`** animation to **`new_ac*`**. **`InteractArea`** rect **250×175**. |
| **Trees / bushes** | **T8, T9, B17, B31, B32** forced foreground (**`z_index = 10`**, **`z_as_relative = false`**). **T9** dynamic depth via **`tree_depth_vs_player.gd`**. |
| **Bag** | **`BagProp`** on **`level_2.tscn`** uses **`props/bag/bag.png`**. |

---

## Latest session (Level 2 — lift, tiles, docs) — 2026-05-12

See **`../CHANGELOG.md`**, section *Level 2 lift cab, cable, tiles collision, and backdrop depth (2026-05-12)*, and `git log` on **`main`** through **`405ac77`** (feature work in **`08bdf11`**).

| Topic | Detail |
|------|--------|
| **Tileset** | **`level 2/tileset.tres`**: full **`physics_layer_0`** coverage for **`tiles.webp`** where missing; full-tile quads on previously thin strips; slope atlas **`one_way`** removed so tiles are solid from all sides. |
| **Backdrop / B Street** | Root sky **`Sprite2D`** **`z_index = -2`** so it draws behind **`BStreet`** (**`-1`**). |
| **Lift prefab** | **`level 2/platforms/platform.tscn`**: deck **`top.png`**, **`z_index = 6`**, **`z_as_relative = false`**; no cab on prefab. |
| **Level scene** | **`level 2/level_2.tscn`**: **`PlatformLiftBody`** (static **`body.png`**), **`PlatformLiftCable`** + **`Outline`** / **`Fill`** **`Line2D`**; **`move`** animation **`position`** keys share **`x`** with **`Platform`** / cab (avoid horizontal snap). |
| **Cable script** | **`level 2/props/lift/lift_cable_line.gd`**: dual **`Line2D`**, fill **`#E59424`** width **12**, outline **`#291b0a`** width **14**, endpoints from animated top underside to cab top (global coords each frame). |
| **Assets** | **`level 2/props/lift/`** — **`top.png`**, **`body.png`**, **`arm.png`**, imports, **`lift_cable_line.gd`** (+ **`.uid`**). |

### Lift alignment (editor checklist)

1. **`PlatformLiftBody.position.x`** = **`Platform.position.x`** = every **`move`** keyframe **`position.x`**.
2. Lowest keyframe **`position.y`**: **`body_center_y − (texture_height_body × scale_y / 2) − (texture_height_top × top_scale_y / 2)`** with top half-height from **`platform.tscn`** (**`26 × 1.038 / 2`**).
3. Upper keyframe **Y**: keep desired travel (e.g. **−390** from bottom for the current Beale loop).
4. **`PlatformLiftCable`** **`Node2D`** position **`(0, 0)`** under **`Platforms`** — cable uses globals; offset parent only if you intend a rig pivot.

### Not in the repo

**`level 2/BStreet copy.png`** (and **`.import`**) — duplicate; do not commit.

---

## How to refresh a working-tree snapshot

```bash
git status
git diff --stat
git diff
```
