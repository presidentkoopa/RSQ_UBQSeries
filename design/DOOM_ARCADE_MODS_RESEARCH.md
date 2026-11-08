# Doom arcade mods: research for contextual triggered challenges (2026-11-08)

For the owner's idea: short challenges that fire during play (a streak of shot-quality bonuses or an RS Score
condition starts them): a timed hunt where monsters teleport in and you must find and kill one target, and
miniboss events. Doom-flavoured, not generic. He said these mods "may offer us little". Some do offer little; I say so.

## How to read this
- Every fact about a mod comes from a page I opened. The URL is next to it.
- **[inference]** marks my reading or an idea for us, not a fact about the mod.
- Paraphrase only; at most one short quote per source.
- **Pages I could not open:** the ZDoom forum (robots block and proxy refusal), the Doomworld Reelism 2 thread,
  ModDB's LegenDoom page, Namu wiki. Two later fetches (Lithium, ScoreDoom on the Doom Wiki) were held for a
  permission no one answered, so they are not covered. The GZChaos forum thread was read by the owner in his browser.
- Nothing here was tested in QuestZDoom 17.3. Every "compatibility" line is inference unless the mod's page says it.

---

## 1. Reelism / Reelism 2 (The Kins and others)

**What it is.** A horde mode on Doom II. Each map is a run of timed rounds; monsters teleport in; a slot machine
changes the rules each round.
- Reelism (1): three reels spin each round, one for rule modifiers (low gravity, flight, infinite ammo), one for
  the weapon/item theme, one for the enemy theme (e.g. hitscan zombies, imp variants, Wolfenstein SS). Weapon spawns
  show as brown sparkles, items as blue. Five rounds, then a boss drawn from a pool of 13; killing it ends the stage.
  Score comes from kills and score items. Modes: Endurance (ten rounds), Shuffle (no repeat until all rules played),
  Boss Practice, Boss Rush, Infinite. https://doomwiki.org/wiki/Reelism
- Reelism 2: waves last 60 seconds; each wave gives the player a random status effect while new weapons and enemy
  types appear; the last wave is one boss. Points are kept whether you live or die and are spent in a hub town
  (vendors such as "Cheap Shot!" for shotguns). Single player only for now. https://doomwiki.org/wiki/Reelism_2
  The modifiers range from shrinking the player to turning them into a tank. https://nichegamer.com/reelism-2-makes-doom-rando-shooter
  The hub page says points "must be spent immediately"; cheating is punished. https://modstalgia.com/doom-ii-hell-on-earth/mods/reelism-2
- **How the player is told** (TV Tropes summary, Reelism series): each reel's name and description are shown when a
  round starts, and a boss's name and description when it appears; a boss's entrance voice clip is heard anywhere on
  the map; three matching reels give a "jackpot" effect (a mid-round break, or instant death); a results screen shows
  score, round, kills and survival time; cheating replaces the score with "CHEATER!".
  https://www.tvtropes.org/pmwiki/pmwiki.php/VideoGame/Reelism
- Fan reels show the reel format can carry objectives: an "Allied Soldiers" reel asks you to keep friendly soldiers
  alive; a "Survival Challenge" reel is never picked in round 1. https://forum.zdoom.org/viewtopic.php?p=1225619
  (search snippet and fetch summary; the forum blocked a direct read later)

**Triggers.** A clock. Every round is the same length; nothing the player does starts an event.

**Doom-flavoured vs generic.** The teleport-in waves, the boss announced by name, and Doom monster themes per reel
are Doom. The slot machine, the hub town and the cross-game weapon pool are a game-show frame laid over Doom
[inference].

**For us [inference].**
- The useful bit is small: **name + one line, shown at the start of the event**, and a boss whose arrival sound
  carries across the map. That is how Reelism makes a random event readable in one glance.
- "Never in round 1" is a good rule shape: some challenges only unlock after the player has proved something.
- The jackpot (three matching reels) is the nearest thing to "triggered by how you play", and it is still luck.
  Ours is the opposite: skill starts the event.
- Reelism replaces maps and the game loop. It is not something to load with Brutal Doom; its weapons and monsters
  would fight BD22 and ours.

---

## 2. "DOOM Roguelike": DoomRL (the original) and DoomRL Arsenal

Two different things share the name.

### 2a. DoomRL / DRL (Kornel Kisielewicz, a standalone turn-based roguelike)
The more useful one for us, because it has real triggered events and an announcer.
- **Level events**, rolled when you arrive on a level, each with one line of text
  (https://drl.chaosforge.org/wiki/Level_event):
  - Deadly Air: health drains, monsters too; leave fast.
  - Armed Nuke: a countdown of (10 minus difficulty) minutes starts.
  - Flood: acid or lava advances column by column from the start side toward the stairs; the line is
    "You feel the sudden need to run!!!"
  - Alarm: every enemy hunts the player precisely.
  - Frozen / Sturdy: walls all destructible / all indestructible.
- **Hell's Arena** (a fixed special level at depth 2) (https://drl.chaosforge.org/wiki/Hell%27s_Arena):
  an announcer greets you ("Welcome to Hell's Arena mortal!"), says the crowd is watching, and asks you to kill
  all enemies. Three waves spawn at random spots: lost souls/demons/cacodemons, then more cacodemons, then barons or
  hell knights by difficulty. After waves 1 and 2 he asks whether you want to continue (y/n); quitting gives a
  smaller reward. Rewards climb: a chaingun, then shells and 10mm, then a rocket launcher, blue armor, a large
  medkit and a supercharge. He taunts you if you flee and names you Hell's Arena Champion if you finish.
- Clearing all three Arena waves is what makes the next special level's boss, the Arena Master (a tougher Arch-vile),
  appear. https://drl.chaosforge.org/wiki/Strategy:Arena_Master
- Special levels each have one gimmick, some optional behind red stairs, and give rewards you rarely get otherwise.
  https://drl.chaosforge.org/wiki/Levels
- **Challenge modes** ("Angel of ..."): whole-run rules such as melee only (Berserk), pistol and fist only
  (Marksmanship), shotguns only, a five-minute nuke on every level (Red Alert), darkness with doubled XP.
  https://drl.chaosforge.org/wiki/Challenges

**Doom-flavoured vs generic.** Very Doom: the events use Doom's own items (envirosuit, invulnerability stop Deadly
Air), Doom monsters in a Doom-tier ladder, and the announcer speaks to the player as "mortal", from Hell's side.
The arena with an announcer is a familiar trope, but the voice and rewards make it Doom [inference].

**For us [inference].**
- **Push your luck** is the best idea in this whole survey: after each wave, keep going for more or take the
  smaller prize now. In VR it could be a gesture, not a menu (step into a marker, or holster the gun).
- **One line on arrival, then the player works it out** (Flood, Deadly Air): no tutorial, just pressure.
- **A challenge that unlocks a boss later** (Arena -> Arena Master) maps onto our Miniboss: a cleared hunt could
  earn the next Bossfight instead of a timer earning it.
- **Rewards in Doom items** (chaingun, blue armor, supercharge) instead of abstract points. The Angel modes are
  Doom's demo categories (Tyson, Pacifist) turned into rules; good names for short challenges ("fists only for 20
  seconds").
- DoomRL is not a GZDoom mod; nothing to load or collide with.

### 2b. DoomRL Arsenal (DRLA, Yholl and Ryan Cordell, GZDoom)
https://doomwiki.org/wiki/DoomRL_Arsenal
- A weapon/class mod inspired by DoomRL: 200+ weapons in rarity tiers, modpacks, and **assemblies** (modpack +
  weapon combinations that become a new weapon, remembered by an in-game PDA). A Monster Pack adds enemies.
- The page covers no events, challenges or special levels. **DRLA offers us nothing for triggered challenges**.
- It replaces weapons and monsters, so it does not go with BD22 [inference].

---

## 3. Vandomizer (MFG38)
https://github.com/MFG38/vandomizer
- A "vanilla randomizer": shuffles existing things at map load, adds no new monsters or weapons, never touches keys.
  Modes: same-tier enemy and ammo swaps; all enemies and ammo; total chaos (may be unbeatable). "Irregulator" mode
  randomises enemy projectiles. Changes apply only on a new or reloaded level.
- Compatibility with other gameplay mods is "not guaranteed"; large monsters landing in tight spots can softlock.

**Triggers / how told.** None: it runs once at map load and says nothing during play.

**For us [inference].** Almost nothing. Two small things: its **tier groups** (swap only within monsters of similar
health and threat) are the same idea as Miniboss's tiers, a fair way to choose who teleports in. Its softlock
warning applies to our spawns too (we already fit-test). Vandomizer on top of BD22 would swap BD's replacement
monsters unpredictably; not a pairing to support.

---

## 4. Corruption Cards (Mike Hill / Cutmanmike) — assume always loaded

**What it does** (https://doomwiki.org/wiki/Corruption_Cards unless noted)
- At the start of each map the player picks one of several cards, almost all of them penalties: you choose the least
  bad. Effects last the level (temporary) or the whole run (permanent), and stack or interact.
- Modes: **Standard** (3 cards offered, pick 1, temporary; every 3 maps one becomes permanent), **Hardcore** (all
  permanent), **Collector**, **Chaos** (1 card a map, all permanent), **Daily Challenge** (a daily seed; themed
  decks, e.g. an extra Cyberdemon every level, per https://www.moddb.com/downloads/corruption-cards-50),
  **Custom** (up to 8 cards offered), hidden **Master** (one hidden card a map; after 12 maps a wild card).
- Card sets: Regular (226 card types), Balanced, New Friends (adds monsters), Science Project (monster properties
  only), Treacherous World (map hazards only).
- Named cards and effects relevant to us:
  - **Rescue Mission**: find Daisy hidden on the level, or the next level's monsters gain a power.
  - **Mystery Eggs**: eggs that release monsters, weak variants, powerups, or a fake Daisy.
  - A random monster teleports in after you kill a set number of enemies.
  - Totems that power up nearby monsters; blood rain that powers monsters under it; acid rain, earthquakes.
  - Items that jump away when you reach for them; Fluffy Gifts (Hissy, a throwable Cacodemon plush, takes a slot).
- Other card effects listed by a mod site: faster monsters, mini-copies, wings or jetpacks, poisonous or exploding
  blood, poison gas, shuffled spawns, stolen resources. https://modstalgia.com/doom-ii-hell-on-earth/mods/corruption-cards
- UI: a **Card Compendium** menu lists every card collected with notes (e.g. whether it stacks); a bindable stats
  screen shows active effects mid-run.
- It **detects custom monsters and generates cards for them**. Its 5.0 notes say Brutal Doom and variants run
  correctly without patches (moddb 5.0 page). 100% kills and secrets make Wild Cards more likely.
- Engine: ModDB says GZDoom 4.4.0 or higher (https://www.moddb.com/mods/corruption-cards); a mod site says no newer
  than 4.11.3. **I did not check it on QuestZDoom 17.3.** The owner loads it, so his setup is the evidence.
- I found no published class or event names (the forum was blocked). Reading the pk3 he loads would give them.

**Where it collides with our challenges [inference]**
1. **Stacking buffs.** CC buffs monsters (totems, blood rain, Science Project), Champions and LegenDoom tier them,
   and our challenge would mark a target. One monster could carry four systems' effects. This is the "conductor"
   problem already named in `design/BIG_FOURTH_ARCADE.md`.
2. **Two spawners at once.** CC's "monster teleports in after N kills", Mystery Eggs and New Friends add monsters
   while our hunt teleports its own in. A hunt timer could expire because CC's extras crowd the room, or a CC spawn
   could be mistaken for the target. Our target must be marked by us, not picked from "what is nearby".
3. **Its own objective already exists.** Rescue Mission (find Daisy, or be punished next map) is a find-the-target
   challenge. Ours must not look like a second Daisy hunt on the same map; better to stay quiet while it is active,
   or to make ours the opposite (kill vs rescue).
4. **Card pick at map start.** Our triggers must not count time or kills while the card screen is up. GZChaos
   already does this: its 1.4 notes say Corruption Card detection stops its timer during card selection (section 6).
5. **Items that flee** and stolen inventory may fight our VR pickups and holsters; worth one rig test.
6. **Generated cards for our monsters.** If our challenge spawns new actor classes, CC may make cards for them. Using
   the map's own or RS Monsters' classes avoids new classes [inference].

**What it could feed [inference].** CC is the run's rule card; we could read which cards are active (once we know
its names from the pk3) and pick challenges that fit: under "monsters teleport in", run a hunt; under heavy monster
buffs, offer a bigger prize. Read only; never change its cards.

---

## 5. Other Doom mods with events, waves or score (short)

- **Invasion** (Skulltag, Zandronum, ZDaemon; Odamex has a similar "Horde"): maps start nearly empty and fill in
  waves; clearing a wave advances; slow clearing gets you swamped by hundreds. https://doomwiki.org/wiki/Invasion
  It is a multiplayer port mode, not a GZDoom mod; the page names no announcer or boss waves. For us: the oldest
  Doom precedent for "monsters teleport in over time" [inference].
- **LegenDoom**: relevant (the owner loads it; its legendary monsters are rare targets), but every page I tried
  failed. Not covered.
- **Lithium, ScoreDoom, MetaDoom, Hideous Destructor, "Doom Incarnate"**: not covered (fetches held or no page found).

---

## 6. GZChaos (kevansevans) — approach and execution, not the chaos

The owner: "I do not want this kind of chaos, but possibly its approach or some of its executions are worth
looking at." So this section is only about how it is built and presented.

Sources: the ZDoom forum thread https://forum.zdoom.org/viewtopic.php?t=76898 (read via the owner's browser);
https://kevansevans.itch.io/gzchaos; devlogs 1.1 https://kevansevans.itch.io/gzchaos/devlog/671293/gzchaos-11-update,
1.2 https://kevansevans.itch.io/gzchaos/devlog/681581/gzchaos-12-update,
1.4 https://kevansevans.itch.io/gzchaos/devlog/857836/gzchaos-14.

**What it is.** A mutator inspired by chaos mods for Super Mario 64 and GTA: one random effect every 30 seconds,
about 250 effects (list in a spreadsheet), one pk3. GZDoom 4.11+, later 4.14 (itch page, 1.4 notes).

**Execution worth looking at**
- **The bar.** A countdown bar at the top (green by default; 1.1 added colour and texture options) shows when the
  next effect comes (thread). The player always knows "something is coming" and when. One effect even hides the
  timer and effect names, which shows the bar and the names are the normal state (1.1 notes).
- **Effects come in three shapes:** timed, instant, or whole-level (thread). Timed effects can stack and multiply
  (2x with 4x gives 8x); some effects change the timer itself (pause, 1/3 timer, 3x) (1.1 notes).
- **Repeat memory.** It remembers the last 20 effects to avoid repeats, adjustable (thread).
- **Seeded runs**, and seeded runs leave out the real "player commits suicide" effect (thread). The seed system was
  rewritten in 1.1.
- **Comfort settings** and a **maximum effect duration** slider (thread); 1.1 adds a menu to switch single effects
  off and lets the frequency go to 3 minutes. Shader and texture effects got short fixed durations (1 and 2 minutes).
- **Effects check before they fire**: "Arachnotron growth spurt" first checks there are arachnotrons on the map
  (1.1 notes).
- **Debugging**: a cvar stores the last effect rolled, so a freeze can be traced (1.4 notes).
- **Plays with other mods**: it detects Corruption Cards and stops its timer during the card pick (1.4 notes). 1.4
  reworked effects to avoid unstable morph actors; a forum user asked to disable player morphs because they break
  gameplay mods (thread). 1.1 added a hidden "purity" check aimed at weapon mods.

**Timer-driven chaos vs play-triggered challenges [inference]**

| | Reelism / GZChaos / DoomRL level events | Our challenges |
|---|---|---|
| What starts it | A clock, a map load, or a die roll | The player's own play: a streak of shot-quality bonuses, an RS Score condition |
| Player's control | None; you endure it | You earn it; better play brings it sooner |
| Fairness | Luck can kill you (Reelism's jackpot, GZChaos effects) | Should never kill outright; it is a reward that is also a test |
| What it means | "The machine is messing with you" | "You are on fire; here is a bigger fight" |

Doom-flavoured lessons from all of them [inference]:
1. **Say it in one line at the start** (Reelism's reel name, DoomRL's arrival lines, GZChaos's effect name). In VR,
   one word and one sound, then let the fight explain itself.
2. **Show the clock** while a timed hunt runs (GZChaos's bar). For VR, a bar or ring in the world, not a HUD strip.
3. **Remember what fired** and do not repeat the same challenge back to back (GZChaos's last-20 memory).
4. **Check before firing** (are there rooms, monsters, space?); our Miniboss guard rails already do this.
5. **Stop the clock** during Corruption Cards' pick, and other menus (GZChaos's precedent).
6. **Never morph or replace the player**; it breaks gameplay mods, and in VR it would break hands, holsters and guns.
7. **Seeded and repeatable** for the four-player goal later: same seed, same challenges.
8. **Push your luck and Doom-item prizes** from Hell's Arena: the one idea here that is both Doom and arcade.

## Summary of what each offers
- Reelism 2: little. The name-and-line announcement and the map-wide boss arrival sound.
- DoomRL (original): the most. Hell's Arena (announcer, waves, continue-or-quit, Doom-item prizes, unlocks a boss),
  level events with one arrival line.
- DRLA: nothing for events (assemblies are loot, not events).
- Vandomizer: nearly nothing (tier-fair swaps; softlock warning).
- Corruption Cards: no ideas to borrow, but the main collision risk (stacked buffs, second spawner, its own Daisy
  hunt, map-start card pick) and a possible input (read active cards).
- GZChaos: not its chaos; its execution (countdown bar, repeat memory, seeds, duration caps, pause during CC's pick,
  no player morphs).
