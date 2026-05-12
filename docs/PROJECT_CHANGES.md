# Project change log

Use **`git log`**, **`CHANGELOG.md`**, and this file’s history for past releases. After a large local session, you can paste a short “delta vs `main`” here; trim it once merged.

## Working tree vs `main` (local)

| Area | Change |
|------|--------|
| **Level 2 — post-interaction celebration** | Full write-up: **[`CHANGELOG.md` — Level 2 post-interaction celebration (2026-05-11)](../CHANGELOG.md#level-2-post-interaction-celebration-2026-05-11)**. Summary: **`PostInteractionDirector`** + **`post_interaction_celebration.gd`**, **`bstreet_roof_reveal.gd`** **`are_all_roofs_complete()`**, **`ac_old_unit.gd`** group **`ac_old_unit`**. |
| **Level 2 clouds** | **`level 2/level_2.tscn`**: small **`Sprite2D`** **`position`** edits under **`Clouds/CloudGroup1`** (**`Sprite2`**, **`Sprite5`**, **`Sprite6`**) and **`Clouds/CloudGroup3`** (**`Sprite2`**, **`Sprite8`**) — parallax cloud placement only. |
| **Untracked** | **`level 2/BStreet copy.png`** (+ **`.import`**) — duplicate of **`BStreet.png`**; do **not** commit. |
| **Level 2 — Paulo / AC / décor** | See **`CHANGELOG.md`** section *Level 2 Beale: Paulo finish, AC façade upgrade, foreground decor, bag prop (2026-05-11)*: **`paulo_goal`**, **`FinishLine`**, **`ac_old_unit`**, **`tree_depth_vs_player`** on **`T9`**, selected **tree/bush** **`z_index`**, **`BagProp`**. |

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

## Latest session (Level 2 — Paulo, AC interact, depth, bag) — 2026-05-11

Cross-reference: **`CHANGELOG.md`** → *Level 2 Beale: Paulo finish, AC façade upgrade, foreground decor, bag prop (2026-05-11)*.

| Topic | Detail |
|------|--------|
| **Paulo** | **`level 2/paulo_goal.gd`** on **`FinishLine`**: **Talk to Paulo**, **`drop_seed*`** to **`present_level_complete()`**, wipe/idle loop, height from measured Lawrence sprite AABB + multiplier, slower transitions, editor-visible first frame. |
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
