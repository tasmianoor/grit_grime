# Grit & Rewind

**Level 1 — Memphis Riverfront** · **Genre:** 2D platformer / light puzzle-exploration  
**Engine:** Godot 4.6 · GDScript · GL compatibility renderer

**Grit & Rewind** stars **Lawrence** on **Memphis Riverfront** (Level 1): run and double-jump across moving platforms, **plant willow and cypress seeds** on matching soil, **fill trash cans** for points, **climb vines**, and **talk to Feena** at the finish to wrap the level. Time you spend moving **right** grows your saplings; moving **left** rewinds growth until trees **lock in** at maturity—so platforming rhythm shapes the garden.

---

## Key features

- **Precision platforming** — Double-jump, slope snap, camera bounds, moving platforms, hidden collision toggles for secret routes  
- **Seeds & soils** — Pick up seeds with **E**, plant on the right patch, gated **second willow seed**, wrong-family feedback  
- **Time-directed growth** — Hold **right** to grow, **left** to rewind (until mature); idle pauses growth  
- **Trash loop** — Seven pickups, two cans with per-can quotas, score toasts  
- **Vine climb** — Land on vines, use **Up / Down** (with jump rules so **Arrow Up** can climb or jump)  
- **Score HUD & parallax sun** — Points top-of-screen on most levels; **Memphis** and **Beale (Level 2)** use the **collapsible mission panel** instead of points (see [CHANGELOG — Level 2 Beale mission HUD…](CHANGELOG.md#level-2-beale-mission-hud-strike-logic-and-christie-2026-05-11)); sun tracks behind clouds  
- **Level flow** — Splash → map hub → levels; **Feena** interact opens **level complete** (retry / continue / back to map); **Level 2 (Beale)** adds **Bruno** as the finish interact, façade **AC** hold-to-upgrade (**old → new** art), and map-hub **Beale Street** entry; **Memphis Aquifer** on the hub opens a **Level 3** teaser screen (**`Lswim.png`**, [CHANGELOG — Theme hub…](CHANGELOG.md#theme-hub-aligned-buttons-level-3-aquifer-placeholder-and-level-2-completion-captions-2026-05-12))  
- **Retro pixel art** — Custom Lawrence / Feena / props; Kenney UI font; Memphis skyline vibe  

---

## Visuals

| | |
|--|--|
| ![Gameplay — Grit & Rewind, Level 1 Memphis Riverfront](screenshots/platformer.webp) | *Gameplay still — add short GIFs here for jump–plant–trash loop and level-complete flow when you have them.* |

*Tip for portfolios:* Record 2–3 short GIFs (movement + planting + finish) and drop them under `screenshots/` for stronger first impressions.

---

## Player controls

Defaults from **Project → Project Settings → Input Map**. Current build is single-player (gamepad device **0**).

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| **Move left / right** | **Left / Right arrows** or **A / D** | D-pad left/right or left stick X-axis |
| **Jump** | **Space**, **W**, or **Up arrow** | **A** (button index **0**) |
| **Climb vines** | **Up / Down arrows** | Left stick Y-axis up/down |
| **Interact** (pick up / plant / deposit / talk) | **E** | **X** (button index **2**) |
| **Pause** | **Esc** | Menu/Start button (index **11**) |
| **Toggle fullscreen** | **F11** or **Alt + Enter** | — |

**Vine note:** **Jump** and **move_up** overlap on **Up/W/Space**; while attached to vines, upward input is used for climbing.

---

## Technical details

| | |
|--|--|
| **Language** | GDScript |
| **Renderer** | `gl_compatibility` |
| **Viewport** | 960×540 (16:9); **`window/stretch/aspect=keep`** — uniform scale, letterbox/pillarbox if the window is not 16:9 |

### Requirements (approximate)

| | Minimum |
|--|--------|
| **OS** | Windows 10+, macOS 11+, or 64-bit Linux |
| **CPU** | Dual-core, ~2 GHz |
| **RAM** | 4 GB |
| **GPU** | OpenGL 3.3 / GLES3–class integrated graphics |

Godot 4 is lightweight for a 2D project; integrated graphics are usually enough.

### Installation & running

1. Install **[Godot 4.6](https://godotengine.org/download)** (or matching **4.x**).  
2. **Project → Import** and select this folder (`project.godot`).  
3. Press **F5** or click **Run** — main entry is **`splash/splash.tscn`** (splash → map).  
4. To run a specific scene directly: open **`game_level_1.tscn`** or **`game_singleplayer.tscn`** and run the current scene.

**Exporting a build:** **Project → Export…** → add **Windows / macOS / Linux** preset → **Export Project**. There is no checked-in `.exe`; builds are produced locally from your machine.

---

## Credits & assets

| Role | Credit |
|------|--------|
| **Development** | **Tasmia Noor** — gameplay, level design fork, GDScript |
| **Base template** | Derived from the [Godot official 2D platformer demo](https://godotengine.org/asset-library/asset/120) (combat/coins/enemies removed; systems extended). |
| **UI font** | **Kenney** — *Kenney Mini Square* (`gui/theme.tres`). |
| **Music** | In-game loop: **Memphis** (`memphis.ogg`, **`Music`** autoload). See [CHANGELOG — Lawrence hero, Memphis pass, and music](CHANGELOG.md#lawrence-hero-memphis-pass-and-music-2026-04-18). |
| **Art** | Lawrence / Feena / level props and tiles as included in the repository (mix of fork-specific assets and demo lineage; see **CHANGELOG** for file-level notes). |

---

## Roadmap & status

| Status | **Alpha / playable vertical slice** — core loop (platform → plant → trash → score → Feena) is shippable; content and polish can grow. |
|--------|----------------------------------------------------------------|

**Ideas / planned directions** (not committed):

- Additional levels and tighter **Level 2** integration from the hub  
- More environmental storytelling and SFX pass  
- Optional combat or hazards *if* design goals change  
- Published **desktop + web** exports with CI builds  

---

## Further reading

| Topic | Document |
|-------|----------|
| Deep design notes, file roles, verification steps | **[CHANGELOG.md](CHANGELOG.md)** |
| Input actions & autoloads | **`project.godot`** |

