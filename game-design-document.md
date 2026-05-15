# Patch Me
## Game Design Document (GDD)

---

# 1. High Concept

## Premise
Patch Me is a 2D action-adventure game where the player experiences the evolution of an indie game developer learning how to make games.

The game intentionally begins as a badly made indie project:
- broken hitboxes
- ugly UI
- inconsistent sprites
- buggy systems
- poor sound mixing
- awkward animations

As the player defeats bosses and progresses through the story, the game itself evolves:
- systems improve
- mechanics become polished
- visuals become cleaner
- performance improves
- UX becomes professional

The player's progression mirrors the developer's growth.

---

# 2. Vision Statement

The goal is to create a game that:
- feels funny and self-aware
- emotionally connects with developers and players
- transforms frustration into progression
- makes the player literally experience game development evolution

The game should start intentionally amateurish and end polished and beautiful.

---

# 3. Genre

- 2D Action Adventure
- Metroidvania-lite
- Meta Narrative
- Comedy / Psychological Indie

Inspirations:
- Evoland
- There Is No Game
- Pony Island
- Undertale
- The Stanley Parable
- The Magic Circle

---

# 4. Core Pillars

## Pillar 1 — The Game Evolves
The game visually and mechanically improves over time.

## Pillar 2 — Bugs Are Gameplay
Technical flaws are intentionally designed mechanics.

## Pillar 3 — Developer Journey
The story reflects real struggles of indie development.

## Pillar 4 — Small Scope, Strong Identity
Short game with memorable creativity.

Estimated playtime:
4–8 hours.

---

# 5. Gameplay Loop

1. Explore an area
2. Deal with a “development problem”
3. Learn how to overcome broken mechanics
4. Reach area boss
5. Boss represents a development concept/problem
6. Defeat boss
7. Unlock a new “development skill”
8. Entire game improves permanently

---

# 6. Player Progression

## Starting State
Player begins with:
- simple sword
- weak dash
- terrible UI
- poor feedback
- broken hit detection

## Progression Philosophy
The player does not simply gain stats.

Instead, the game itself improves:
- hitboxes become accurate
- camera smoothing improves
- animations become fluid
- input delay disappears
- menus become polished
- sound becomes responsive

The reward is psychological and mechanical.

---

# 7. World Structure

## Central Hub — “The Project Folder”

Represents the game project itself.

Connected regions:
- Assets
- Scripts
- Audio
- UI
- Build
- Legacy Code
- Prototype Graveyard

Each region symbolizes a different development challenge.

---

# 8. Areas & Bosses

---

# AREA 1 — Collision Plains

## Theme
First platformer prototype.

## Problems
- broken hitboxes
- inconsistent collision
- attacks miss visually
- enemies hit from impossible distances

## Boss
### The Placeholder

Visual:
Large red cube with temporary textures. Its actual hitbox is displayed as a visible red outline — clearly misaligned with the sprite.

Dialogue:
> “You thought collision systems were easy?”

### Boss Mechanics
- The boss's sprite and its actual hitbox are visually offset — the player must learn to attack the hitbox, not the image.
- The boss's attacks have no visual telegraph. Damage comes from where the attack “should” be, not where it appears.
- At 50% HP, the boss freezes entirely — simulating a crash. It stands motionless for 5 seconds. The player must hit it during this window.
- At 25% HP, the boss's hitbox becomes briefly visible on every attack, teaching the player the underlying system.
- Victory moment: the boss's sprite and hitbox snap into alignment for the first time. The cube lets out a single, broken sound byte and disappears.

## Reward
### Collision System v1.0

Unlocks:
- accurate hitboxes
- hit feedback
- impact particles
- responsive combat

---

# AREA 2 — Optimization Mines

## Theme
Terrible performance.

## Problems
- fake FPS drops
- excessive particles
- slow loading
- sound stacking bugs

## Boss
### Memory Leak

Visual:
A mass of corrupted particles and floating error windows. Every second it exists, it spawns more visual debris. An FPS counter is visible in the corner of the screen throughout the fight.

### Boss Mechanics
- The boss continuously spawns particle emitters. As the fight progresses, the FPS counter visibly drops (simulated, not real).
- At low FPS stages, the player character moves in slow motion — the lag mechanic becomes a gameplay obstacle.
- The boss duplicates itself into 2, then 3 copies. More copies = more memory usage displayed on screen.
- To deal meaningful damage, the player must destroy the particle emitters around the arena first — "freeing memory" — before targeting the boss core.
- At critical HP, the screen glitches hard: audio distorts, the game appears to almost crash. Then the boss is defeated and everything stabilizes.
- Victory moment: the FPS counter climbs back to 60 and locks there.

## Reward
### Optimization Knowledge

Unlocks:
- stable framerate
- cleaner effects
- reduced loading times
- smoother gameplay

---

# AREA 3 — Scope Creep Forest

## Theme
Adding too many mechanics.

## Problems
- useless crafting
- abandoned systems
- unnecessary fishing
- confusing UI
- unfinished skill trees

## Boss
### The Dream Game

Visual:
An enormous, bloated creature that grows visibly larger as the fight progresses. New limbs, features, and attachments keep appearing mid-battle.

Dialogue:
> “You wanted to make everything.”

### Boss Mechanics
- The boss starts manageable. Every 20 seconds, it gains a new attack type — the fight literally scope-creeps in real time.
- Mid-fight interruptions: a fishing minigame prompt appears on screen. A crafting UI pops up. An unfinished skill tree flickers open. All are dismissible but cost time.
- The boss's HP bar has multiple segments labeled with feature names: “FISHING”, “CRAFTING”, “SKILL TREE”, “DIALOGUE SYSTEM”. Each segment must be cleared.
- At 50% health, the boss announces: “NEW FEATURE UNLOCKED” and adds a mechanic that actively interferes with the player (e.g., the attack button now also opens inventory).
- Defeating each segment removes it visually from the boss — it shrinks. Victory leaves only the original, manageable core.
- Victory moment: the boss deflates to a tiny, simple cube. Clean. Just the essentials.

## Reward
### Focus System

Unlocks:
- simplified systems
- cleaner UI
- streamlined mechanics
- better gameplay pacing

---

# AREA 4 — Tutorial Dungeon

## Theme
Over-explaining everything.

## Problems
- nonstop tutorials
- giant control popups
- gameplay interruptions
- excessive dialogue

## Boss
### UX Director

Visual:
A floating figure in a business suit holding a massive clipboard. Every attack is preceded by a lengthy explanation tooltip. It cannot stop explaining itself.

Dialogue:
> "Welcome to Phase One of the Boss Encounter Tutorial. Please read the following before proceeding."

### Boss Mechanics
- Before every single attack, the boss pauses and a tutorial popup appears explaining what it is about to do ("THE BOSS WILL NOW PERFORM A SWEEP ATTACK. DODGE TO THE LEFT.").
- Giant "PRESS X TO ATTACK" prompts periodically cover portions of the screen, blocking visibility.
- The player can dismiss popups quickly — but the boss has so many that managing them becomes the core challenge.
- At 50% HP, a full-screen tutorial appears: "YOU ARE NOW IN PHASE 2. HERE IS A 12-STEP GUIDE TO DEFEATING THIS BOSS." The player must mash through all 12 pages while the boss slowly walks toward them.
- At 25% HP, the popups start appearing faster than the player can dismiss them — the screen fills with overlapping tooltips.
- Victory condition: the last popup appears and reads simply: "You already knew how to play."
- Victory moment: all tooltips disappear simultaneously. The arena is clean and silent for the first time.

## Reward
### Clean UX

Unlocks:
- minimal UI
- better readability
- smoother onboarding
- modern presentation

---

# AREA 5 — Burnout Core

## Theme
Creative exhaustion.

## Problems
- reused assets
- unfinished music
- empty areas
- abandoned devlogs
- emotionally heavy atmosphere

Tone becomes more serious and introspective.

## Boss
### The Abandoned Build

Visual:
A hollow, half-rendered version of the player character — same sprite, missing animations, looping in place like a stuck coroutine. The arena has silhouettes instead of tiles. No music plays.

Dialogue:
> "There is no point. Nobody is watching anyway."

### Boss Mechanics
- The boss barely fights. It attacks by copy-pasting moves from previous bosses — no creativity, pure repetition.
- The arena is visually incomplete: missing tiles, placeholder decorations, grey boxes where content should be.
- Periodically, the boss stops entirely and stands still with an idle loop. The player must keep attacking even when the boss refuses to engage.
- A devlog counter is visible in the corner: **"Days since last update: 847."**
- The only way to lose is to also stop attacking — the lose condition is inaction, not damage.
- As the boss loses HP, the arena slowly fills in: tiles appear, decorations load, a faint melody starts.

## Reward
### Renewed Purpose

Unlocks:
- empty areas fill with previously missing content
- music tracks become complete
- reused assets get replaced with originals
- a personal entry appears in the in-game devlog for the first time in months

---

# 9. Narrative

## Initial Assumption
The player believes they are simply playing a bad indie game.

## Gradual Discovery
The player realizes:
- the game reflects a developer’s mental state
- NPCs know they are unfinished
- the world is literally a struggling project

NPC dialogue begins discussing:
- perfectionism
- abandoned projects
- crunch
- imposter syndrome
- fear of failure

---

# 10. Final Boss
### The Inner Critic

Visual:
A perfect, fully-polished version of the player character. Smooth animations, clean sprite, professional VFX. Everything the player has been working toward — but standing against them.

Dialogue:
> “You never finish anything.”
> “This game will never be good enough.”
> “You should have quit a long time ago.”
> “I am everything you wanted to make. And you will never reach me.”

### Boss Mechanics

**Phase 1 — Doubt**
Each hit the boss lands applies a debuff styled as a dev criticism:
- “Weak design” → reduced attack damage
- “Slow iteration” → reduced movement speed
- “Poor scope” → player's reach shrinks

The player can cleanse debuffs by landing hits — action overcomes paralysis.

**Phase 2 — The Ideal Game**
The arena transforms into a perfect, impossibly polished environment — shining tiles, dynamic lighting, orchestral music. The boss taunts that this is what the game “should have been.”

The player must fight in this space without being intimidated by the contrast. The mechanics don't change — only the pressure does.

**Phase 3 — The List**
The boss reads out a list of the developer's abandoned projects, unfinished prototypes, failed ideas. Each name spoken spawns a ghost enemy (weak, easily defeated — they are just memories).

The player defeats each ghost and the list grows shorter until only this game remains.

**Defeat Condition**
The Inner Critic does not die dramatically. It slowly fades, its polished sprite deteriorating back into a rough sketch. Final line:

> “...maybe it's enough.”

After victory:
The game becomes fully polished in a single, satisfying transition.

Then the screen displays:

> PATCH ME — Version 1.0
> Released.

The game immediately ends.

Final message:
No game is ever truly perfect. Ship it anyway.

---

# 11. Art Direction

## Early Game
- ugly pixel art
- inconsistent proportions
- poor animation timing
- ugly fonts
- placeholder assets

## Mid Game
- cleaner sprites
- basic lighting
- improved particles
- stronger visual identity

## End Game
- cohesive art direction
- smooth animations
- polished VFX
- professional presentation

The visual evolution must be obvious and satisfying.

---

# 12. Audio Direction

## Early Game
- distorted sounds
- poor volume balancing
- awkward looping music
- delayed effects

## End Game
- polished mixing
- dynamic soundtrack
- responsive combat audio
- emotional ambience

---

# 13. Technical Scope

## DO NOT INCLUDE
- multiplayer
- procedural generation
- giant open world
- deep RPG systems
- complex crafting
- massive skill trees

## FOCUS ON
- strong gimmick
- memorable bosses
- high polish
- short experience
- clever progression

Ideal scope:
- 5 main areas
- 5 bosses
- 4–8 hours

---

# 14. Recommended Engine

## Godot Engine

Reasons:
- excellent for 2D
- lightweight
- fast iteration
- open source
- AI-friendly scripting workflows
- ideal for indie scope

---

# 15. Monetization

## Price Range
US$9.99–14.99

Reasoning:
- short premium indie experience
- strong creative identity
- high replayability through discovery

---

# 16. Steam Marketing

## Main Hook
“A game that starts broken and becomes polished as you play.”

## Steam Capsule Idea
Split image:
- left side intentionally ugly and buggy
- right side polished and beautiful

## Trailer Structure
1. Show broken gameplay
2. Reveal fourth-wall break
3. Show visual evolution
4. Show emotional/dev themes
5. End with:
> “Fix the game. Fix the developer.”

---

# 17. Target Audience

Primary:
- indie gamers
- developers
- streamers
- meta-game fans

Secondary:
- players who enjoy narrative experimentation
- players who like short memorable indie experiences

---

# 18. Production Strategy

## Recommended Development Approach
Build vertically.

Do NOT create:
- all maps first
- all systems first
- all bosses first

Instead:
1. Make Area 1 fully playable
2. Make first “game improvement” satisfying
3. Prove the core gimmick works
4. Expand gradually

---

# 19. MVP (Minimum Viable Product)

## Goal
Prove that the core gimmick works: a game that feels intentionally broken, then visibly improves after a boss fight — and that improvement feels satisfying.

Everything outside this section is out of scope until the MVP is complete and feels good.

---

## Scope: What Is In MVP

### Player
- Walk and jump (basic platformer movement)
- Single attack: sword swing with a visible swing animation
- Weak dash (short range, no invincibility frames — intentionally bad)
- Health: 3 or 4 hit points, represented by an ugly placeholder UI (pixel hearts or a raw number)
- No death screen required — respawn at area start is enough

### Area 1 — Collision Plains
- One linear level: platforms, gaps, a path to the boss
- 3–5 basic enemies: they walk back and forth, deal contact damage
- All enemy hitboxes are visually offset — their actual damage zone does not match their sprite
- Player attack hitbox is also offset — visually the sword swings one place, damage lands elsewhere
- No puzzles, no secrets, no collectibles

### Boss — The Placeholder
- Large red cube sprite with a visible red outline showing the real hitbox (clearly misaligned)
- Phase 1: boss moves toward player and attacks; attacks have no visual telegraph — damage appears from an offset zone
- Phase 2 (50% HP): boss freezes entirely for 5 seconds, simulating a crash; player must hit it during this window
- Phase 3 (25% HP): boss hitbox briefly flashes visible on every attack
- Death: sprite and hitbox snap into alignment with a click/pop sound, then boss disappears

### Post-Boss: Patch Notes Screen
- Screen fades to black, then a terminal-style interface appears
- Patch notes for v0.2.0 scroll up (see Section 22 for exact format)
- Duration: 15–20 seconds, cannot be skipped
- After notes finish, the level reloads

### Post-Boss: The Fix
After the patch notes, the game visibly changes:
- Player attack hitbox now matches the sword swing animation exactly
- Enemy hitboxes align with their sprites
- A small impact particle appears when attacks connect
- 2-frame hit stop on successful hits (the world pauses briefly — this is the most important feel improvement)

---

## Scope: What Is NOT In MVP

These are explicitly excluded. Do not build them yet.

- Hub world (“The Project Folder”)
- The Console (narrative guide)
- Areas 2–5 and their bosses
- Dash with invincibility frames
- Music (use free placeholder audio)
- Sound design beyond basic SFX (hit, jump, death)
- Dialogue or story text
- Main menu (a “Press Start” screen is enough)
- Save system
- Settings menu
- Any content referencing the Inner Critic or final boss

---

## Technical Checklist

These are the systems that must work before MVP is considered done:

- [ ] Player can move, jump, attack, and dash
- [ ] Player takes damage on contact with enemies and boss
- [ ] Player has a health value that decreases and ends the run at zero
- [ ] Enemies have a patrol loop and deal damage on contact
- [ ] Player attack deals damage to enemies within the (offset) hitbox
- [ ] Boss loads as a separate scene with its own state machine (Idle, Phase1, Phase2, Phase3, Dead)
- [ ] Boss phases trigger at correct HP thresholds
- [ ] Boss freeze (Phase 2) works as a timed window
- [ ] Post-boss scene transition triggers on boss death
- [ ] Patch Notes screen displays correctly and auto-advances
- [ ] After patch notes, hitbox values are updated globally (accurate hitboxes from this point on)
- [ ] Impact particles appear on hit (post-patch only)
- [ ] Hit stop (2 frames) works on hit (post-patch only)
- [ ] The broken state and the fixed state are both clearly distinguishable

---

## Success Criteria

The MVP is viable if a first-time player (or yourself after a break):

1. Feels confused or frustrated by the broken hitboxes — but laughs, not quits
2. Understands (without being told) that something is wrong with the game
3. Finds and defeats the boss using the broken system
4. Reads the patch notes and understands what just changed
5. Plays 30 seconds post-patch and notices the difference in feel

If all five happen: **ship the full game.**

If step 1 causes the player to quit instead of laugh: the broken state needs tuning.
If step 5 doesn't feel different: the fix needs more impact.

---

# 20. Core Identity

Patch Me is not a story about saving the world.

It is a story about:
- learning
- failing
- iterating
- improving
- finishing something despite imperfections

The player experiences the emotional journey of becoming a developer.

---

# 21. The Console — Narrative Anchor

## Purpose
The player needs a guide from the very beginning. Without one, the meta-narrative risks feeling confusing rather than intentional. The Console fills this role.

## What It Is
A floating debug log that has become sentient — or at least, that's how it appears.

It shows up in the hub world ("The Project Folder") and speaks entirely in corrupted system messages that gradually become more personal and emotional.

## Early Game Voice
```
[ERROR] NPC_dialogue_01.gd — line 34: null reference
[WARNING] Player hitbox offset: 48px
[LOG] Area loaded. 3 missing assets. Proceeding anyway.
```

## Mid Game Voice
```
[LOG] You're still here.
[LOG] Most builds don't make it this far.
[WARNING] Developer mood: low. Committing anyway.
```

## Late Game Voice
```
[LOG] This was supposed to be a small project.
[LOG] I remember when this was just a prototype.
[LOG] I think we might actually finish this.
```

## Final Message (before final boss)
```
[LOG] Everything you fixed is still here.
[LOG] Everything broken was a choice, not a failure.
[LOG] Ship it.
```

## Design Notes
- The Console never breaks the fourth wall explicitly — it always stays within the metaphor of a debug log.
- It appears in the hub between areas, never during gameplay.
- Its tone shifts naturally as the game improves around it.
- It is the emotional throughline that connects all five areas.

---

# 22. The Patch Notes Ritual

## Purpose
Each boss defeat needs a satisfying, tangible moment that communicates "the game just improved." The Patch Notes screen is that moment.

## How It Works
After every boss, the screen fades to a terminal-style interface. Patch notes scroll upward, listing exactly what changed — in developer language, but written with personality.

## Format Example — After Area 1 (The Placeholder)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PATCH ME — PATCH NOTES v0.2.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  FIXED
  • Hitbox offset corrected (was 48px off, sorry)
  • Player attack no longer phases through enemies
  • Enemies can no longer hit from 3 screens away

  ADDED
  • Impact particles on hit
  • Hit stop (2 frames) for combat feedback
  • Enemy flinch animation (placeholder, but better)

  KNOWN ISSUES
  • Everything else

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Format Example — After Area 3 (The Dream Game)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PATCH ME — PATCH NOTES v0.4.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  REMOVED
  • Fishing system (never finished, nobody asked)
  • Crafting UI (12 hours of work, 0 gameplay value)
  • Skill tree (it was mostly empty boxes)
  • 4 planned biomes (the forest was fine)

  IMPROVED
  • Game is now 40% shorter and 200% more fun
  • Menu no longer requires a tutorial

  DEVELOPER NOTE
  "Cutting things is also development."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Design Notes
- Each patch notes screen should take about 15–20 seconds to read.
- The player cannot skip it — this is the reward, not an interruption.
- The humor should feel specific and self-aware, not generic.
- After the notes finish, the world reloads and the improvements are immediately visible.
- Each screen ends with a "KNOWN ISSUES" section that shrinks with each patch — until the final boss screen, where it reads: "None found. Ship it."