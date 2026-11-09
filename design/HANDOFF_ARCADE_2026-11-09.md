# Handoff: Doom Arcade VR, encounters and set pieces (2026-11-09)

This replaces `design/HANDOFF_ARCADE_DESIGNER.md` (2026-11-08) as the starting point for the arcade lane. Read it top
to bottom before touching anything. It is long on purpose: the owner asked for a comprehensive handoff ("it can be
wordy, this is a big deal").

---

## 0. Read this first: the honest state

- **Nothing in the arcade layer is built.** No encounter, no set piece, no challenge, no DoorCard exists in code.
- **No encounter is fully designed.** We have a short list of encounter ideas (section 6), each with what the owner
  said and what is still open. None has been worked through to the end.
- **What is new since 2026-11-08:** a real monster roster (RSQ Monsters with four selectable sets, 13 colour tiers,
  a live tier-change flash, any monster spawnable by name), a deck of arcade mechanics pulled from the games the
  owner loves (`design/ARCADE_MECHANICS_DECK.md`), and the owner's own encounter ideas on top of it.
- **The last handoff failed.** In the owner's words: "your handoff got me nothing but [someone] who wasted my time and
  money", and "you're acting like we have concrete ideas and arenas and gameplay and all we have are disconnected
  ideas and a framework". Do not repeat that. The framework (arenas, DoorCards, sheets, families) is a place to put
  designs; it is not the design. Do not fill in templates and call it design. Bring the owner one real gameplay idea
  at a time, in plain words, and let him react.
- **The owner's own restart rule (2026-11-08 23:18):** "Let's start by assuming we have no ideas and no gamemodes; we
  have these conceptual images and a robust miniboss program." Since then the roster was added. Work from there.

---

## 1. Who, and how to work with him

- **Owner:** presidentkoopa. VR Doom mods for **stock QuestZDoom 17.3** (Quest standalone; gzdoom 4.14 base). No
  engine changes, ever: ZScript, DECORATE, MODELDEF and data only.
- **Guiding statement** (repo CLAUDE.md): **"Doom Arcade VR."** His words only. Don't expand it into rules, palettes
  or features of your own. He also said: Doom-flavoured, not generic.
- **His first VR Doom project was Hackfraud (HF)**, at `E:\oldshit\outdatedHFmaster` on his PC. All of its code is
  his. Take from it whatever we need. Never treat it as someone else's code (this caused real anger on 11-08/09). And don't get distracted in it
  (owner 11-09: "I told you not to get distracted in HF, so DROP IT"): what MG needed is taken; leave the rest.
- **Working style, learned the hard way:**
  - **One question at a time.** "STOP ... TOO MUCH HAPPENING." Finish the thread in hand.
  - **Plain words.** Say what the player sees. Explain any term the first time. ("What the fuck is a time trial
    card?" happened because a term was never explained.)
  - **If something is open, ask him** (2026-11-09 00:17: "if something is open ask me questions"). Don't decide it
    silently, and don't leave it out silently.
  - **Don't ask him to tune what he already designed.** He designed MeatGrinder's tiers in full; asking "do you want
    them to hit harder?" made him rightly angry. Read his material first.
  - **Remember what exists.** Forgetting RSQ SlowMo while proposing slow motion got: "are you fuckin insane? did you
    forget RSQ SlowMo?" Check section 3 before saying "we'd need to build X".
  - **His ideas are his; yours are yours.** Write his words down as his. Mark your suggestions as yours.
  - **Show, don't describe.** He decides from mockups. An approved mockup is a spec.
  - **No rig tests unless he allows them.** On 11-09 00:12 he said "No rig tests". When code is built but not run,
    say so plainly: "built, not run".
  - **Don't be sanctimonious about ripped art** (he knows the scene), but if a licence forbids shipping something,
    say so once, plainly.

---

## 2. The big picture he has agreed to

### 2.1 Doom as one arcade cabinet (the mosaic, 2026-11-08 18:13, owner: "I think it's coming together, yeah")
- **The map** is the playfield. Rooms come from sound-blocking lines and the mapper's own fights.
- **Corruption Cards** is the run's rule card. **RS Monsters** is the targets; **Brutal Doom** gives them bodies and gore.
- **Champions and LegenDoom** are the rare targets. **Score** is the scoreboard. The **arcade language** (the eight
  mockups) is the machine talking.
- **Challenges / encounters** are the modes and the multiball. **Miniboss** is boss mode. **DOWN** is the continue
  screen. **Gun Bonsai VR (GBOVR)** is what carries over between credits. The rest of the series is the controls.
- **Missing piece: the conductor.** One piece that decides who tiers or buffs which monster and who gets to speak, so
  five systems don't stack on one monster or shout at once. A challenge director grown from Miniboss's Bossfight
  shape could become it. Not designed.

### 2.2 The arcade loop (design/ARCADE_LOOP.md; owner approved the look of all eight mockups)
Eight mockup panels, `design/mockups/arcade_language/contact_sheet.png`:
1. **Lock-on ring** (Virtual Cop): a ring on one monster closes green -> yellow -> red before it attacks.
2. **Danger flash** (Time Crisis): only the shot that will hit you flashes.
3. **Shot words**: GOOD / GREAT / AMAZING / PERFECT on the head you hit.
4. **Hit number and combo name**: +20 rolling to +45, TRAP SHOOTER stamped above.
5. **The level lights the next target** (pinball): a barrel outlined, "+500".
6. **Room timer and time bonus**: clock over the door, ROOM CLEAR, TIME BONUS.
7. **Level end tally and grade**: KILLS / ITEMS / SECRET count up, an "S" slams in.
8. **Jackpot and frenzy**: FRENZY over a clock, JACKPOT +6100, bits burst.

The loop: **shot** (3, 4) -> **fight** (5, 6) -> **level** (7), with the **peak** (8) earned across them. Panels 1-2
were set aside for set pieces only, because in VR you move and aim freely. **New on 11-09:** with the roster, a ring on
one monster now has a real job: in a crowd of very different monsters, it says "this one is the problem" (the
strongest tier, a monster that just flashed up, a boss). Which monsters get the ring was asked and not answered.

### 2.3 The challenge framework (design/ARCADE_CHALLENGES.md; a container, not a design)
- The **arena** (a combat zone in a map) is the unit. Each map lists its arenas, drawn by the owner in `tools/mapview/`.
- A **DoorCard** on an arena's door is the menu (like a Gun Card). States: offered / in progress / cleared. Pick a
  row by **shooting, punching or touching** it. **Each row prints its own stake** (lose a life / a weapon level / the
  next challenge gets harder): push your luck at the door. **No return visits** for now.
- Written designs use one **challenge sheet** with fixed fields (Name, Family, Goal, Clock, Spawns, Win, Fail, Pays,
  Stake, Shows, Doom flavour); families Speed / Hunt / Collect / Skill; the owner sorts KEEP / LATER / NO.
- Mockup: `design/mockups/doorcard_concept.png` (predates the stake rule).
- **Target WAD: Maps of Chaos OVERKILL** (`WADs/MapsOfChaos_OVERKILL.wad`, 59 maps; he plays it on Doom and Doom II).

---

## 3. What we have to build with (check here before saying "we'd need to build X")

Status words: **headset** = played and confirmed by the owner; **rig** = shown on the test rig, not headset-confirmed;
**built, not run** = compiled or written but never run; **idea** = not built. Each mod's README has its own status line.

### 3.1 RSQ Monsters (`Monsters/`, `pk3/RSQ_Monsters.pk3`, ~85 MB; owner's RS Monsters, Quest edition)
- **Monster sets**, picked in RS Options -> RSQ Monsters -> Select Monster Set, applied on a map restart:
  **Vanilla**, **BD22** (only when Brutal Doom is loaded, else Vanilla), **MeatGrinder**, **ColorfulHell** (default).
  Cvar `rsq_monster_set` (0-3). Status: the switch was shown on the rig (spawns changed set by set).
- **The set only swaps the 17 stock Doom monster types the map places.** Anything spawned by its own class name
  (`RS_RedImp`, `RS_MGImp`...) comes out exactly as named, whatever set is picked. So **an encounter can spawn CH, MG,
  or a mix inside any level, including a BD22 level.** Needs RSQ Monsters loaded. One catch: with ColorfulHell picked,
  CH also swaps the stock projectiles (imp fireballs etc.), so an MG imp in a CH level throws a CH fireball. A small fix
  if it matters.
- **The 13-colour ladder:** 1 Common, 2 Green, 3 Blue, 4 Purple, 5 Yellow, 6 Red, 7 FireBlu, 8 Gray, 9 Abyss, 10 Black,
  11 White, 12 Cyan, 13 Brown.
- **ColorfulHell (CH):** every colour is its own complete monster class (own health, attacks, sounds, blood, flags).
  A map spawn rolls a weighted colour (imp: Common ~34%, Green ~20%, Blue ~10%, Black 2 in 1843, White 1 in 1843).
  Rare colours have on / 50% / off switches (`rs_ch_brown` etc.). Changing tier swaps the class. 17 families. EX and
  boss variants exist (`rs_ch_exboss`, `rs_ch_blackboss`). "The EX monsters alone are gold for encounter design" (owner).
- **MeatGrinder (MG):** 17 monsters (Sergeant Mark IV's Meatgrinder, recoloured and re-tiered by the owner in
  Hackfraud). Stock attacks; each tier multiplies the same monster by **the owner's own table** (HF_Monster.zs:110-122):
  health, speed, flinch, **damage**, **aggression** and colour. Owner's plan: "keep their stock attacks, and just
  increase their health, damage, and aggression [and speed]. Room to expand their attacks later." Measured on the rig
  for an MG imp: Common 60 hp / speed 8 / x1 / normal; Purple 210 / 11.2 / x1.6 / attacks more; White 1200 / 14.4 / x3 /
  attacks most. Damage and aggression were never applied in Hackfraud; they are now (built, not run). Also from
  Hackfraud: **reactive deaths** (shock, melt, burn, freeze by damage type; gib on explosion or overkill; head shot ->
  head death, head pops at 60+ damage; else MG's own death), the **Abyss split** (an Abyss MG monster splits into two
  Green lost souls), the tier icon (off by default), HF's blood decals, the owner's tracer model.
- **The tier-change flash (the owner's, from Hackfraud):** told to change tier, a monster waits a random 5-25 tics,
  blinks white every 3 tics (black when becoming White), then becomes its new colour and stats. Shared by CH and MG.
  "It's how monsters change tier in real time." Built, not run. Commands: `netevent rs_retier N` (what you look at),
  `rs_retier_all N`, `rs_tierof`. Health on a tier change is a menu option (default: instant change = full health,
  live change = same fraction).
- **Missing:** `blooddrop2` without BD.

### 3.2 Set-piece and feedback tools already in the series
- **Miniboss** (headset for the set piece): the **Bossfight**: fill a meter with stylish kills, check your watch, call
  it in; a miniboss and its thralls **teleport in where you can see them**. Shape: meter -> arrival -> payoff ->
  cooldown. A win drops Score's life crate (rig). Graves Rise (31 undead from 31 tombstones, rig).
- **SlowMo** (headset): the world slows, you don't; enemy bullets become dodgeable. Any system can start it by name
  (`rsqsm_start:<who> <ms> <speed%> <flags>`). Triggers today: heavy hits, grenade blasts, barrel chains, reload.
  **DOWN** (rig, off by default): a killing hit holds you at 1 HP; kill marked targets before a clock runs out to get
  up. DOWN already has: per-target crosshairs (ten, never repeated), **edge arrows** to off-screen targets, a
  **chevron trail** in the world to near ones, target lines on a HUD panel (e.g. LEGENDARY ORANGE CHAMPION ZOMBIE),
  **real Champion copies** spawned via Champions itself, bits that bank and pay on revive. **DOWN is already a small
  Where's Waldo.** Most encounter HUD needs (point at a thing, mark a thing) can reuse it.
- **Score** (headset): the scoreboard, extra lives, shot tags (headshots, airborne, point-blank, Quick Draw, Direct
  Hit...). It pays 25% for spawned monsters today (matters for encounters). No streak counter yet.
- **VisualRewards**: per-hit words and numbers, kill-reward bits.
- **Gun Bonsai VR (GBOVR)**: weapon/player levels; the player screen has **item slots** (the owner's inventory idea).
- **QuestSaber**: lightsaber, Force powers (push, pull, jump), and a **training drone** that circles and shoots bolts
  for you to deflect, keeping score. The owner wants to expand the drone.
- **Melee**: throws, an axe. **Grapple**, **Whip**: movement. **Grenade**. **DistanceGrab** (headset). **GlowInTheDark**.
  **Tactical Rig** (holsters, keyring). **Graveyard** (tombstones). **GunCards**, **LaserSight** (headset).
- **mapview** (`tools/mapview/`): top-down map pages with layers and a computed areas layer; the owner draws named
  rooms and exports JSON.

### 3.3 Other mods in his load (not ours)
Brutal Doom 22 (+ VoxelPack, BD22 VR weapons), **LegenDoom** (legendary monsters), **Champions** (champion monsters;
**no licence: we cannot ship its art**, e.g. its food sprites), **Corruption Cards** (often; its card pick keeps the
clock running, so our timers must wait), plus his environment mods. Full list: `design/IDEAS_TRUE_LOAD_ORDER.md`.

### 3.4 Assets
- Fonts and in-world text methods: `design/ARCADE_ASSETS_INVENTORY.md`, `design/mockups/fonts/`. **Canvas textures
  render black in VR on 17.3**: world text must be model quads, letter strips, sprites or VisualThinkers.
- FX sheets for explosions (grenades, barrels; Metal Slug / Neo Geo feel): `design/assets/fx_sheets/`. The three
  sheets are kept (two of unknown source: ask before shipping). The Reactorcore pack's only licence word is a "CC0"
  comment by the author: get it in writing before shipping. The Vecteezy sheet is excluded (licence forbids it).
- Condition bits (weapon repair = weapon wear) and Gold bits (a currency) belong to the arcade (owner 11-09).

---

## 4. Rules that bind any design
- Works on stock QuestZDoom 17.3; no engine changes.
- Each mod loads alone; cross-mod links are by name lookups.
- Netplay matters: four-player co-op is a goal. Who owns an encounter in co-op is undecided.
- "Working" means shown working (frames or logs), never "the code exists". VR behaviour stays "rig only, not
  headset-confirmed" until he confirms it.
- VR comfort: anything that moves or slows the world while your head moves normally needs care.
- Commits: author presidentkoopa, explicit paths, never `git add -A`; pk3 under GitHub's 100 MB.

---

## 5. The games and what they gave us (full detail: design/ARCADE_MECHANICS_DECK.md)

The owner listed his seminal arcade and board games. For each, the deck has Claude's read (the takeaway mechanic plus
what's unique), the owner's take in his words, and where we landed. In one line each:

| Game | What we took | Status |
|---|---|---|
| Virtual Cop | the lock-on ring that warns who fires first; arrows + slow-mo; we can scale monsters | panel 1 |
| Time Crisis | no cover in Doom maps; its red danger flash and section timer become rules (panels 2, 6) | rule, not encounter |
| House of the Dead 2 | **giant weak-point boss** (owner's towering imp) | short list |
| Jurassic Park | **Jurassic Run**: run to a marked spot with an unkillable threat behind you | short list |
| Alien 3 / Gunblade NY / Beast Busters | owner: "skip this" | skipped |
| Star Wars Trilogy Arcade | saber + Force + **expand the training drone** | short list |
| Metal Slug | **massive pixel explosions**; **rescues** with "Rescued X/Y" on the tally | short list |
| Smash TV | melee waves + floor prizes -> **collect tokens to summon an EX bossfight** | short list |
| Double Dragon | **monsters carry 3D melee weapons** (bat, pipe), drop them when knocked down | short list |
| Gauntlet Legends | generators, food (not Champions' art) | idea |
| D&D: Shadow over Mystara | gold bits, an inventory on GBOVR's slots | idea |
| DoDonPachi | a chain that breaks when you pause | idea |
| Radiant Silvergun | colour chains on our 13 colours: "pattern building and execution would be super fun" | idea, feeds Bust-a-Move |
| Neo Geo | "impressive frame count for explosions" | art direction |
| Bust-a-Move | **the colour-crowd encounter** (owner's design) | short list, strongest |
| DDR | movement is style: dashes, wall runs, hookshot, whip, constant slow-mo to stay airborne | short list |
| Where's Waldo / Guess Who | **find the target in a growing crowd**; each kill reveals a trait | short list |
| Clue / Risk | Risk dropped; Clue's deduction folds into Guess Who | dropped |

The owner also added his own: **Tower of Power** (stacked enemies only killable from the bottom).

---

## 6. The short list: encounter ideas, as far as they've got

Each entry: what it is, who said what, what we'd use from section 3, and what's open. None is final.

### 6.1 Bust-a-Move: the colour crowd (owner's design; Claude: "the best idea on the list")
**Owner:** "Clearing a room of monsters means turning them a certain color by shooting them; they do not take damage.
Some monsters are keyed. Assume 30 monsters, all infighting different ones with each hit for maximum chaos (constant
retargeting and rechasing) but taking no damage. Three coloured monsters are key, and when you kill that one you kill
all monsters currently that colour. But the infighting makes it hard for you to get control over the colour crowd."
**Uses:** the colour tables (MG translations can paint any family), the tier flash, infighting, RSQ Monsters spawning.
**Claude's notes:** painting is cosmetic only (a painted imp keeps its stats). Monsters take no damage from each other
either, so the chaos never settles, which is the point.
**Open:** what a hit paints: one step along the ladder per hit, or each weapon paints its own colour (switching guns
sets up the colour crowd: Radiant Silvergun inside Bust-a-Move). How the three key monsters are told apart. Win/fail.

### 6.2 Giant weak-point boss (House of the Dead 2)
**Owner:** "a large Imp, towering, with active crosshairs appearing on parts of its body being the only way to damage
it. A large health bar on our HUD to show its depletion. 'Weak Point' text underlined, and that line extending at an
angle to the weak point."
**Uses:** monster scaling; hit-height measurement (MG's head band already does it); DOWN's HUD lines and icons that
track a world spot; Miniboss's arrival/payoff shape.
**Open:** does the weak point stay put, or move to another body part after each hit? How many parts per monster.

### 6.3 Jurassic Run
**Owner:** "pick a point in the map and have the player run to it; we spawn in a massive threat like a Champion EX tier
and have it motivate the player to run to the marked spot. Workshop this some."
**Claude's workshop (not approved):** DOWN's chevron trail marks the goal; the threat arrives behind you, slightly
slower than your sprint, unkillable but stunnable (an explosion buys ~2 s); chumps spawn on the route as blockers;
SlowMo on its lunges; reaching the spot slams a door or teleports you out; pays for time and for how close it got
(Crazy Taxi near-miss tips). Variant: carry a rescued scientist, which slows you.
**Open:** all of it; the owner hasn't reacted to the workshop yet.

### 6.4 Where's Waldo / Guess Who
**Owner (00:39):** "We spawn in a ton of monsters and keep doing so every X tics. Some are genuine threats, which
might get our Virtual Cop crosshair when they attack and maybe some contextual slomo and some arrows to point us to
them; many others are chumps. One is our target: it could be a Boosted Legendary Champion or an EX monster or a
high-tier something."
**Uses:** RSQ Monsters (chumps = Common/Green, threats = mid/high tiers, target = EX/Black/White or a Champion copy),
DOWN's crosshairs, arrows, trail and target lines, SlowMo, the lock-on ring (panel 1), the danger flash (panel 2),
the jackpot (panel 8). Guess Who: each kill reveals one trait of the target.
**Open (asked, not answered):** is the target hidden among the chumps until it gives itself away (e.g. by the tier
flash), or marked from the start and protected by the crowd?

### 6.5 Smash TV tokens -> summon an EX bossfight
**Owner:** "melee monsters coming at you in waves while you mow them down and collect prizes... maybe puzzle
pieces?... collecting required trinkets to summon an EX tier bossfight."
**Uses:** waves via RSQ Monsters; Miniboss's Bossfight as the summon; panel 8.
**Open:** what the tokens are and look like; how many; where they drop; tie-in to LegenDoom.

### 6.6 Rescues (Metal Slug + HotD2)
**Owner:** "source some civilian or scientist sprites; walk up to them and Use to free them... help them teleport out
or something. Add it to our tally at the end: Rescued X/Y."
**Uses:** panel 7's tally; BD's rescuable marines prove the idea.
**Open:** civilian sprites we're allowed to ship; what rescuing pays.

### 6.7 Monster melee weapons (Double Dragon)
**Owner:** "we will try to find a baseball bat and a pipe... get them on our enemy sprites as attached 3D weapons";
then: "SuperPunchOut proved 3D gloves can be done. We would only need to draw our weapon actor near the monster
holding it, and intercept monster attacks as an animated swing of the whatever."
**How SuperPunchOut does it** (read 11-09, `superpunchout/src/zscript/spo/spo_liveglove.zs`): each sprite frame has
an authored hand **anchor** pixel; that pixel becomes a point on the sprite, pushed toward your eye by a depth; a damped
spring (3 Hz) carries the 3D glove there every tic, so frames without an anchor hold and frame jumps glide. A punch
hands off to a separate flying glove, then the live one springs back. **For us:** mark the hand on a few frames per
monster (idle, walk, attack), the spring covers the rest, the melee swing is the hand-off; knocked down, the monster
drops the weapon as a pickup (Double Dragon's "take his weapon").
**Open:** models (bat, pipe; we have an axe); which monsters carry them.

### 6.8 Tower of Power (owner's own)
**Owner:** "stacked enemies who can only be taken out from the bottom."
**Claude's first thoughts:** real monsters standing on each other; only the bottom takes damage; when it dies the
tower drops a level; the tower walks toward you and the top ones still shoot; with colour, matching colours landing at
the bottom clear together (a chain).
**Open:** all of it.

### 6.9 Movement and air time (DDR)
**Owner:** "movement = style. We design expanded movesets to keep us in the air: dashes, wall runs; the hookshot and
whip help here too. Certain events / set pieces need constant slowmo so we can stay in the air while targeting what
we need."
**Uses:** Grapple, Whip, Force Jump, SlowMo (constant slow-mo is something it can do).
**Open:** dashes and wall runs don't exist; which set pieces want air time.

### 6.10 Saber and drone (Star Wars Trilogy Arcade)
**Owner:** "Our lightsaber and Force powers can play on this for sure. We have a training drone we could expand into
something." **Open:** what the drone becomes.

### Ideas without an encounter yet
Radiant Silvergun colour chains (kill the same colour in a row), DoDonPachi's chain that breaks on a pause, Gauntlet
generators and food, D&D gold and an inventory on GBOVR's slots, Metal Slug / Neo Geo explosions on grenades and
barrels.

---

## 7. Pieces several encounters need (none built)
- **The conductor / encounter director:** starts an encounter in an arena, spawns, keeps the clock, decides win/fail,
  pays out, and stops Champions, LegenDoom, Corruption Cards, RS Monsters and Score from stacking on one monster.
- **Arena spawning:** spawn RSQ Monsters by class inside a drawn arena (Miniboss's teleport-in is the model).
- **Paint:** recolour a monster without changing its stats (Bust-a-Move).
- **No-damage monsters** that still infight (Bust-a-Move).
- **Weak points:** hit location on a body part (HotD2 boss).
- **Tokens / pickups** on the floor mid-fight (Smash TV).
- **Rescuable people** (Metal Slug).
- **The tally line** "Rescued X/Y" and the grade (panel 7).
- **HUD pointers** reused from DOWN (crosshairs, edge arrows, trail, target lines).
- **Score paying full for encounter monsters** (it pays 25% for spawned monsters today).

---

## 8. Open questions, in a sensible order (ask ONE at a time)
1. Which encounter to workshop fully first: **Bust-a-Move** or the **weak-point boss**? (asked 01:23, not answered)
2. Where's Waldo: target **hidden** until it gives itself away, or **marked and protected**? (asked, not answered)
3. Bust-a-Move: does a hit paint one ladder step, or does each weapon paint its own colour?
4. Weak-point boss: does the weak point move after each hit?
5. Lock-on ring: which monsters get it (top tiers and bosses only, any monster about to land a big hit)?
6. Jurassic Run: does the workshop in 6.3 match what he meant?
7. What starts an encounter: a DoorCard at an arena door, a run of good shots (Score), or both?
8. Which Maps of Chaos maps get arenas drawn first.
9. Co-op: who owns an encounter.

---

## 9. Suggested next step
Workshop **one** encounter with the owner, question by question, until every line of it is his. Then write it as one
challenge sheet. Then, only when he says build, build it as a test in **one** Maps of Chaos arena, and show it working
(frames or logs) before calling it working.

---

## 10. File index
| File | What |
|---|---|
| `design/ARCADE_IDEAS_2026-11-09.md` | nine ideas kept 11-09 for the stew (four owner's/Claude's, the circle and its modes) and the shelf of outside mods supplied that day |
| `design/ARCADE_MECHANICS_DECK.md` | every game: Claude's read, the owner's take, where we landed; SuperPunchOut's gloves |
| `design/ARCADE_LOOP.md` | the eight panels as gameplay; the loop |
| `design/mockups/arcade_language/` | contact sheet + panels p1-p8 + index.html |
| `design/ARCADE_CHALLENGES.md` | arena, DoorCard, stakes, sheets, families |
| `design/BIG_FOURTH_ARCADE.md` | the owner's notes; rooms from map data; the mosaic; the conductor |
| `design/MONSTER_SETS.md` | the sets, Hackfraud, the MG tiering plan |
| `Monsters/README.md` | RSQ Monsters as built |
| `SlowMo/README.md`, `design/NEAR_DEATH.md` | SlowMo and DOWN |
| `Miniboss/README.md` | the Bossfight |
| `design/CHALLENGE_BUILDING_BLOCKS.md` | what exists for challenges and the gaps |
| `design/DOOM_ARCADE_MODS_RESEARCH.md`, `design/CORRUPTION_CARDS_STUDY.md`, `design/ARCADE_LANGUAGE_RESEARCH.md` | research done; don't redo it |
| `design/ARCADE_ASSETS_INVENTORY.md`, `design/mockups/fonts/`, `design/assets/fx_sheets/` | fonts, text methods, FX art |
| `tools/mapview/` | map viewer and room drawing |
| `design/PARKED.md` | parked ideas (Wheel support, Condition/Gold bits) |
| `design/HANDOFF_ARCADE_DESIGNER.md` | the 11-08 handoff (superseded by this one) |
