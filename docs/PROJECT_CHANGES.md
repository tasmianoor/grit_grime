# Project change log

Use **`git log`**, **`CHANGELOG.md`**, and this file’s history for past releases. After a large local session, you can paste a short “delta vs `main`” here; trim it once merged.

## Latest session (Level 2 — lift, tiles, docs) — 2026-05-12

Committed as one bundle (see **`../CHANGELOG.md`**, section *Level 2 lift cab, cable, tiles collision, and backdrop depth (2026-05-12)*, and `git log`).

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
