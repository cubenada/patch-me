# CLAUDE.md — Patch Me

Project instruction bible. Read this entire file before writing any code.

---

## 1. The Project

**Patch Me** is a 2D action-adventure game in Godot 4.6 where the game starts intentionally broken and improves as the player defeats bosses. The premise is meta: the game mirrors the journey of an indie developer learning how to make games.

The full design document is at `game-design-document.md`. Read it when you need creative or gameplay design context.

**Current MVP:** Area 1 (Collision Plains) with boss The Placeholder and the post-boss Patch Notes system. Everything else (Areas 2–5, hub world, The Console, final boss) is out of scope until the MVP is complete and validated.

**MVP success criteria:** a first-time player is confused by the broken hitboxes but laughs instead of quitting, defeats the boss, reads the patch notes, and clearly notices the difference within 30 seconds of post-patch gameplay.

---

## 2. Engine and Version

- **Godot 4.6** with static GDScript
- Renderer: **GL Compatibility** (broad hardware support)
- Base resolution: **640×360**, integer-scaled to 1920×1080 (`stretch/mode = viewport`, `scale_mode = integer`)
- Texture filter: **Nearest** (pixel art)

Never suggest migrating the engine, Godot version, or renderer without explicit user request.

---

## 3. Directory Structure

```
patch-me/
├── assets/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   └── sprites/
│       ├── enemies/
│       ├── player/
│       ├── ui/
│       └── world/
├── scenes/
│   ├── bosses/
│   ├── enemies/
│   ├── player/
│   ├── ui/
│   └── world/
└── scripts/
    ├── autoloads/
    ├── bosses/
    ├── enemies/
    ├── player/
    ├── ui/
    └── world/
```

Every `.tscn` scene has its `.gd` script at the mirrored path under `scripts/`. Never put scripts inside `scenes/` or scenes inside `scripts/`.

---

## 4. Autoloads

Two autoloads registered in `project.godot`. Do not create new autoloads without a clear architectural need.

### `GameState` (`scripts/autoloads/game_state.gd`)
Game state singleton. Holds:
- `patch_version: String` — current patch version ("v0.1.0", "v0.2.0", etc.)
- `hitbox_accurate: bool` — false = broken hitboxes, true = corrected
- `has_impact_particles: bool` — impact particles unlocked
- `has_hitstop: bool` — 2-frame hit stop unlocked
- `has_clean_audio: bool` — clean audio vs. intentionally broken
- `current_weapon: int` — equipped weapon slot
- `weapons_unlocked: Array[bool]` — which weapons are available

All "broken vs. fixed" conditional behavior **must go through GameState**, never through local scene variables.

### `AudioManager` (`scripts/autoloads/audio_manager.gd`)
Centralizes all sounds. When `GameState.has_clean_audio = false`, sounds play with random pitch, delays, and intentional failures — this is a designed mechanic, not a bug.

Play sounds: `AudioManager.play("sound_name")`
Play music: `AudioManager.play_music("res://assets/audio/music/file.mp3")`

---

## 5. GDScript Conventions

### Static typing is mandatory
All new code must use static types. No `var x = something` without a type when the type is determinable.

```gdscript
# CORRECT
var health: int = 4
var direction: Vector2 = Vector2.ZERO
@onready var sprite: Sprite2D = $Sprite2D

# WRONG
var health = 4
var direction = Vector2.ZERO
@onready var sprite = $Sprite2D
```

### Constants in SCREAMING_SNAKE_CASE
```gdscript
const MAX_HP := 5
const MOVE_SPEED := 80.0
const FREEZE_DURATION := 5.0
```

### Private functions with `_` prefix
```gdscript
func _handle_movement() -> void:
func _get_player() -> Node2D:
func _check_phase_transition() -> void:
```

### Signals with descriptive snake_case names
```gdscript
signal boss_defeated
signal patch_applied(version: String)
```

### Enums for state machines
Any system with multiple states must use `enum`, not loose integer constants.
```gdscript
enum Phase { IDLE, ONE, FREEZE, THREE, RETURN, DEAD }
var phase: Phase = Phase.IDLE
```

### Comments: only the "why", never the "what"
Code should be self-explanatory. Comment only when there is a non-obvious reason: an engine-specific bug, a subtle invariant, behavior that looks wrong but is intentional.

```gdscript
# CORRECT — explains why
# process_physics = true ensures the timer ignores time_scale = 0 during hitstop
await get_tree().create_timer(0.033, true, false, true).timeout

# WRONG — describes the obvious
# Reduces player HP
health -= amount
```

---

## 6. Scene Patterns

### Preload vs. load
- `preload()` for resources known at compile time (scenes that get instantiated repeatedly)
- `load()` only when the path is dynamic

```gdscript
const PROJECTILE := preload("res://scenes/player/projectile.tscn")
```

### @onready for child node references
Always use `@onready` for child node references. Never call `get_node()` inside `_process` or `_physics_process`.

```gdscript
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer
```

### Node communication: downward by reference, upward by signal
- Parent nodes call methods on children directly
- Children communicate upward to parents via signals
- Cross-branch communication: use autoloads or groups

```gdscript
# Child emits, parent connects
signal boss_defeated
boss_defeated.emit()

# Group access (when no direct reference is available)
get_tree().get_first_node_in_group("player")
```

### Groups
Existing groups:
- `"player"` — the player node

When creating new enemies or entities that need to be found globally, add them to the appropriate group in `_ready()`.

---

## 7. Physics and Collision

### Collision layers
Defined in `project.godot`. Always respect:
- Layer 1 (value 1): Walls / Environment (TileMap)
- Layer 2 (value 2): Player
- Layer 3 (value 4): Enemies / Boss bodies
- Layer 4 (value 8): Enemy projectiles + Enemy hurtboxes
- Layer 5 (value 16): High ground objects / Enemy damage zones
- Layer 6 (value 32): Player projectiles / Player hurtbox Area2D

Collision masks:
- Enemy/boss projectiles: `mask = 3` (walls + player)
- Player projectiles: `mask = 9` (walls + enemy hurtboxes)
- Enemy damage zones: `mask = 2` (player only)
- Area2D interaction triggers: `mask = 2` (player only)

The high ground system (`on_high_ground`) exists so projectiles do not collide with objects on different elevation planes — this is intentional mechanic.

### Z-index stack (Area 1)
`Ground(0)` → `WallShadow(1)` → `Walls / HighGroundWalls(2)` → `YSortRoot(3)` → `WallTop(4)`

- `YSortRoot`: `Node2D` with `y_sort_enabled = true` — contains Player, Enemies, Boss, Chests
- `WallShadow`: empty `TileMapLayer` with `modulate = Color(0, 0, 0, 0.5)` — painted tiles become visual shadows
- `WallTop`: empty `TileMapLayer` at z=4 — painted tiles occlude the player (appear on top)
- `ShadowSystem.gd`: detects if the player stands on a WallShadow tile and tweens `player.modulate`

### Broken hitboxes (pre-patch)
When `GameState.hitbox_accurate = false`, hitboxes are intentionally offset. **This offset is gameplay, not a bug.** The Placeholder boss uses `HURTBOX_BROKEN_OFFSET = Vector2(36.0, -28.0)`. The player uses an offset of `Vector2(10.0, 5.0)` on its `collision_shape`.

Never "fix" these offsets without checking `GameState.hitbox_accurate`.

### CharacterBody2D
Always use `CharacterBody2D` + `move_and_slide()` for moving entities. Never use `RigidBody2D` for controllable characters.

---

## 8. Boss System

Each boss is a standalone scene in `scenes/bosses/` with a state machine via `enum Phase`. Required pattern:

```gdscript
enum Phase { IDLE, ..phases.., DEAD }
signal boss_defeated

func _die() -> void:
    phase = Phase.DEAD
    velocity = Vector2.ZERO
    # death animation
    await get_tree().create_timer(X).timeout
    boss_defeated.emit()
    queue_free()
```

The parent scene (area) connects to the `boss_defeated` signal and triggers the Patch Notes transition.

Boss state machines use `match` inside `_physics_process`, never chained `if/elif` for phases.

Boss and Player nodes should have `unique_name_in_owner = true`; area scripts access them via `%Boss` / `%Player` (unique name syntax).

---

## 9. Patch Notes and Progression

The core system of the game. When creating a new patch version:

1. Add an `apply_patch_vXYZ()` method to `GameState`
2. The method sets all relevant boolean flags and updates `patch_version`
3. The `patch_notes.tscn` scene displays the text and calls the apply method when done
4. After apply, the current scene reloads or transitions — the player must notice the difference immediately

Each patch must have **perceptible, clear changes**. If the difference is not obvious within 30 seconds of gameplay, the patch needs more impact.

---

## 10. Audio

### Existing sounds (AudioManager)
`attack`, `hit`, `player_hurt`, `enemy_die`, `boss_hit`, `boss_die`, `dash`, `chest_open`, `menu_hover`, `menu_click`, `attack_w0`, `attack_w1`, `attack_w2`

### Adding a new sound
1. Place the file in `assets/audio/sfx/`
2. Add `_load("name", "file.wav")` in AudioManager's `_ready()`
3. Call `AudioManager.play("name")` where needed

### Broken audio (pre-patch)
`AudioManager` checks `GameState.has_clean_audio` automatically. Pre-patch sounds have random pitch (0.72–1.38), random delays, and a 15% chance of not playing at all. **This is intentional.** Do not fix it without a patch.

---

## 11. UI and HUD

### Resolution and scaling
All UI uses `CanvasLayer` to avoid being affected by the camera. Base resolution is 640×360 — UI elements must be designed for this resolution.

### HUD (`scenes/ui/hud.tscn`)
The player health bar is drawn via `_draw()` directly on the player's `CharacterBody2D` node (above the sprite). This is intentional for the "badly made indie game" phase — the UI has no clean fixed position.

Future patches may move the health bar to a dedicated HUD in a `CanvasLayer`.

### Fonts
In the early game: ugly, inconsistent, wrong-sized fonts — this is intentional aesthetics. Do not improve fonts until a specific patch addresses them.

---

## 12. Camera

`scripts/player/camera.gd` — follows the player. Camera smoothing may be disabled in the initial state as part of the "broken" experience. Any camera improvement must be gate-kept by a flag in `GameState`.

---

## 13. Save / Load

The save system uses `ConfigFile` at `user://save.cfg`. `GameState` manages `save_game()` and `load_game()`. Saving is triggered on pause (Escape → PauseMenu).

When adding new fields to `GameState`, always:
1. Add the field with a safe default value
2. Serialize it in `save_game()`
3. Deserialize it in `load_game()` with a safe default
4. Reset it in `reset()`

---

## 14. Enemies

Basic enemies (`basic_enemy.gd`) are `CharacterBody2D` with a simple patrol. Pattern:
- Walk back and forth between patrol points
- Deal damage on contact with the player
- Hitboxes are offset when `GameState.hitbox_accurate = false`

New enemies follow the same conditional collision pattern. Always check `GameState.hitbox_accurate` before setting hitbox offsets in `_ready()`.

---

## 15. Input Map

Actions defined in `project.godot`:
- `move_left` / `move_right` / `move_up` / `move_down` — WASD + arrow keys
- `attack` — Z or LMB
- `dash` — Space
- `interact` — E
- `weapon_1` / `weapon_2` / `weapon_3` — 1, 2, 3
- `ui_cancel` — Escape (pause)

Never hardcode `KEY_*` constants in scripts. Always use Input Map action names.

---

## 16. Creative Rules

### The broken state must be funny, not infuriating
Wrong hitboxes, distorted audio, ugly UI — everything should trigger a knowing smile, not anger. If a broken mechanic causes the player to quit instead of laugh, it needs tuning (more telegraphed, more predictable, or less punishing).

### Every patch must carry emotional weight
The post-boss transition is not just mechanical. The Patch Notes screen is a cinematic moment. Text must be specific, self-deprecating, and funny — never generic.

### The game knows it is a game
NPCs can reference the engine, bugs, commits. The world is literally a game project. Explore this without over-explaining it.

### Less is more
Per the GDD: the game has intentionally small scope. One fully polished area is worth more than five mediocre ones. Do not add systems, mechanics, or content beyond the current MVP.

---

## 17. What Not To Do

- **Do not create multiplayer, procedural generation, crafting, or skill trees** — permanently out of scope
- **Do not add hub world or The Console** until the MVP is complete and validated
- **Do not use `get_node()` with hardcoded paths** in `_process` — always `@onready`
- **Do not use untyped variables** (`var x = 5` → `var x: int = 5`)
- **Do not "fix" broken audio or offset hitboxes** without checking `GameState`
- **Do not create a new autoload** without clear architectural justification
- **Do not use `await` inside `_physics_process`** — causes unpredictable behavior
- **Do not use `RigidBody2D` for characters** — always `CharacterBody2D`

---

## 18. Development Workflow

### Priority order
1. MVP works and feels right (Area 1 gameplay complete end-to-end)
2. Patch v0.2.0 is perceptibly better than v0.1.0
3. Patch Notes screen has the right text and the right timing
4. Everything else

### Mandatory manual testing
Before declaring any feature complete, test:
1. The broken state (default GameState, flags at initial values)
2. The fixed state (after `apply_patch_v020()`)
3. The transition between the two

If the difference is not immediately noticeable, the fix needs more impact.

### When the user requests something outside MVP scope
Flag it as out of current scope and ask if they want to re-prioritize. Do not silently implement content beyond the MVP.

---

## 19. Technical References

Godot projects used as quality benchmarks:
- **Godot Demo Projects** (official) — scene structure standards
- **Celeste** (player state architecture) — clean `CharacterBody2D` with explicit state machines
- **Undertale** / **Pony Island** (meta-narrative in games) — how a game "knows" it is a game without breaking immersion

For Godot API questions: official docs at https://docs.godotengine.org/en/stable/ (4.x branch).

---

## 20. Quick Reference

| What | How |
|---|---|
| Game state | `GameState` autoload |
| Play audio | `AudioManager.play("name")` |
| Broken hitbox | `GameState.hitbox_accurate = false` |
| New enemy | `CharacterBody2D`, check `hitbox_accurate` in `_ready` |
| New boss | `enum Phase`, `signal boss_defeated`, `_die()` emits signal |
| New patch | `apply_patch_vXYZ()` in `GameState` + `patch_notes` scene |
| New save field | `save_game()` + `load_game()` + `reset()` |
| New sound | `assets/audio/sfx/` + `_load()` in AudioManager |
| Z-index (Area 1) | Ground(0) → WallShadow(1) → Walls(2) → YSortRoot(3) → WallTop(4) |
