# Grit & Rewind

Grit & Rewind is a 2D puzzle platformer where players control time through movement to restore Memphis, Tennessee's endangered ecosystems. Moving right advances time toward a degraded present; moving left reverses toward a healthy past. Players navigate two Memphis landmarks—the Mississippi Riverbank and Beale Street—solving environmental puzzles that address real issues including riverbank erosion, water pollution, urban heat islands, and habitat loss. Each level concludes with actionable solutions connecting gameplay to local organizations like Memphis River Parks, Wolf River Conservancy, MLGW, and Memphis Botanic Garden. Built in Godot Engine with a Spiritfarer-inspired art style and Memphis blues soundtrack.

---

## Key features

- **Precision platforming.** — Double-jump, slope snap, camera bounds, moving platforms, hidden collision toggles for secret routes  
- **Seeds & soils.** Pick up seeds with **E**, plant on the right patch, gated **second willow seed**, wrong-family feedback  
- **Time-directed growth.** Hold **right** to grow, **left** to rewind (until mature); idle pauses growth  
- **Trash loop.** Seven pickups, two cans with per-can quotas, score toasts  
- **Vine climb.** Land on vines, use **Up / Down** (with jump rules so **Arrow Up** can climb or jump)  
- **Score HUD & parallax sun.** Points top-of-screen on most levels; **Memphis** and **Beale (Level 2)** use the **collapsible mission panel** instead of points (see [CHANGELOG Level 2 Beale mission HUD…](CHANGELOG.md#level-2-beale-mission-hud-strike-logic-and-christie-2026-05-11)); sun tracks behind clouds  
- **Level flow.** Splash → map hub → levels; **Feena** interact opens **level complete** (retry / continue / back to map); **Level 2 (Beale)** adds **Bruno** as the finish interact, façade **AC** hold-to-upgrade (**old → new** art), and map-hub **Beale Street** entry; **Memphis Aquifer** on the hub opens a **Level 3** teaser screen (**`Lswim.png`**, [CHANGELOG Theme hub…](CHANGELOG.md#theme-hub-aligned-buttons-level-3-aquifer-placeholder-and-level-2-completion-captions-2026-05-12))  
- **Retro pixel art.** Custom Lawrence / Feena / props; Kenney UI font; Memphis skyline vibe  

---

## Visuals

| Description | From the Game |
|--------|----------|
| Choose from multiple Memphis-themed levels | ![Map Menu](https://github.com/tasmianoor/grit_rewind/blob/main/screenshots/Map%20Menu.png?raw=true) |
| Hear what locals need help with | ![Level 1 Intro](https://github.com/tasmianoor/grit_rewind/blob/main/screenshots/Level%201%20Intro.png?raw=true) |
| Use time-bending powers to bring harmony | ![Level 2 Gameplay](https://github.com/tasmianoor/grit_rewind/blob/main/screenshots/Level%202%20Gameplay.png?raw=true) |

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

**Audio:** A **Sound OFF** / **Sound ON** button in the **top-right** (sits **just left of the mission checklist** on Level 1 and Level 2) mutes or restores all game audio on the **Master** bus.

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

---

## Roadmap & status

| Status | **Alpha / playable vertical slice.** Core loop (platform → plant → trash → score → Feena) is shippable; content and polish can grow. |
|--------|----------------------------------------------------------------|

**Future ideas / planned directions**

- Additional levels and tighter **Level 2** integration from the hub.
- Mobile-friendly gaming experience.
- Background story & lore to explain how player Lawrence gets his powers.
- Incorporate more background music options using work from actual Memphis artists.
- Guidebook and/or wiki to help players learn about plant, animal and any other environmentally-themed sprites local to TN.
- Ability to save progress.
- Leaderboards for a shared gaming community.
- Accessible hints.

---

## Credits & assets

| Role | Credit |
|------|--------|
| **Development** | **Tasmia Noor:** gameplay, level design fork, GDScript |
| **Base template** | Derived from the [Godot official 2D platformer demo](https://godotengine.org/asset-library/asset/120) (combat/coins/enemies removed; systems extended). |
| **UI font** | **Jersey25** |
| **Music** | In-game loop: **Memphis** (`memphis.ogg`, **`Music`** autoload). See [CHANGELOG — Lawrence hero, Memphis pass, and music](CHANGELOG.md#lawrence-hero-memphis-pass-and-music-2026-04-18). |
| **Art** | Lawrence, characters, level props and tiles were all generated by Nano Banana. |
