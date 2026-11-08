# Handoff: the arcade designer lane (2026-11-08)

For a designer starting fresh on the series' **arcade layer** (the "Big Fourth"). This is design only: **no building**
until the owner says so ("building now would be disastrous", 18:39). Read this first, then the files it points to.

## 1. Who and what
- **Owner:** presidentkoopa. Makes VR Doom mods: **RSQ UBQ Series** (this repo) and BD22 VR weapons, on stock
  **QuestZDoom 17.3** (Quest standalone; gzdoom 4.14 base; no engine changes; ZScript/DECORATE/MODELDEF/data only).
- **Guiding statement** (CLAUDE.md): **"Doom Arcade VR."** Take it as his words only. Do not expand it into rules,
  palettes or features of your own. He also said: keep it **Doom-flavoured, not generic**.
- **His load** (18:13): Brutal Doom 22, BD_VoxelPack, BD22 VR weapons, Champions, LegenDoom or LegenDoom Lite,
  Corruption Cards (often), RS Monsters with three sets (later), and the UBQ Series.
- **Target WAD: Maps of Chaos OVERKILL** (`WADs/MapsOfChaos_OVERKILL.wad`; owner 18:49). It holds 59 maps:
  E1M1-E3M9 (27 Doom-style) and MAP01-MAP32 (32 Doom II-style). He plays it on both IWADs (Doom and Doom II).

## 2. How to work with him (learned the hard way)
- **One question at a time.** He has said "STOP ... TOO MUCH HAPPENING" and "we're doing too much right now". Don't
  open new threads; finish the one in hand.
- **Plain words.** Jargon confuses him ("lots of this terminology is confusing to me"). Say what the player sees.
- **Show, don't describe.** He decides from mockups. An approved mockup is the spec; a builder must match it.
- **Ideas are his; you organise them.** Write his words down as his, mark your own suggestions as yours. Never turn
  your own leading question into "his decision".
- **Use our real assets.** Our own fonts and art, Doom's look. No invented logos. He dislikes hard-edged boxes and
  cards (prefers glow/outline).
- **Every claim checked.** Facts come from a source you opened or the repo (file:line). Label inference. No
  "mountain of hallucination trash".

## 3. Where the design stands
Read in this order:
1. `design/ARCADE_LOOP.md` — what each of the eight mockup panels stands for as gameplay, and the loop:
   **shot → fight → level**, with the **peak** earned across them. Panels 1-2 (lock-on ring, danger flash) are for set
   pieces only (Bossfight, marked target, a triggered challenge), because in VR you move and aim freely.
2. `design/mockups/arcade_language/` — `contact_sheet.png` (all eight) and `index.html`. Mockups only; nothing built.
3. `design/ARCADE_CHALLENGES.md` — the concept and the decisions so far:
   - the **arena** is the unit (each map lists its arenas);
   - the **DoorCard** (like a Gun Card) on an arena's door is the menu; three states: offered / in progress / cleared;
   - **choose by shooting, punching or touching a row** on the card;
   - **each row prints its own stake** (lose a life / a weapon level / next challenge harder): push-your-luck;
   - **no return visits** for now;
   - the **keyring** (Tactical Rig) might be repurposed (open);
   - every challenge is written as **one card with fixed fields** (Name, Family, Goal, Clock, Spawns, Win, Fail,
     Pays, Stake, Shows, Doom flavour), in four **families** (Speed, Hunt, Collect, Skill);
   - the owner sorts cards **KEEP / LATER / NO**; only KEEP gets built, one at a time.
   - First cards (names only): Time Trial, Clear the Room, Find the Marked One (his "Where's Waldo" concept, not that
     exact idea), Miniboss, Barrels In, Bit Rush.
4. `design/BIG_FOURTH_ARCADE.md` — his notes in order, the "mosaic" (Doom as one arcade cabinet), and the missing
   **conductor**: one piece deciding who tiers/buffs which monster and who speaks, so Champions, LegenDoom,
   Corruption Cards, RS Monsters and Score don't stack on one monster or shout at once.

The DoorCard concept mockup (offered / in progress / cleared; general layout, not yet in Doom's look) is
`design/mockups/doorcard_concept.png` (the owner's screenshot). It predates the "each row prints its stake" decision.

## 4. Research already done (use it; don't redo it)
| File | What it gives you |
|---|---|
| `design/ARCADE_LANGUAGE_RESEARCH.md` | Sega light-gun, pinball, modern FPS feedback patterns, sourced. Sega's *look* is mostly unsourced. |
| `design/DOOM_ARCADE_MODS_RESEARCH.md` | Reelism 2, DoomRL (Hell's Arena: the strongest find, push-your-luck with Doom-item prizes), Vandomizer, GZChaos (approach only; owner does not want that chaos), Invasion. |
| `design/CORRUPTION_CARDS_STUDY.md` | Code read of CC v6.3b: the card pick (clock keeps running: our timers must wait), cards that spawn/buff, VR clashes, what the conductor must read and avoid. |
| `design/CHALLENGE_BUILDING_BLOCKS.md` | What we already have: Miniboss Bossfight (the meter → arrival → payoff → cooldown shape), DOWN's spawner, Score's hooks, shot grading, bits, timers; and the gaps (no shared services, Score pays 25% for spawned monsters, no streaks). |
| `design/ARCADE_ASSETS_INVENTORY.md` + `design/mockups/fonts/` | Every font and in-world text method we have, with glyph sheets. |
| `design/WHEEL_MODS_PEEK.md` | 13 mods the Wheel knows; LegenDoom and Lithium (ideas only) worth a look. |
| `design/MONSTER_SETS.md`, `design/RSMONSTERS_SCORE_GBOVR_STUDY.md` | RS Monsters' three sets and re-tiering; a later Big Project. |
| `design/NEAR_DEATH.md` | DOWN, the arcade revive (approved, built): bits bank, Champions, death clock. |
| `design/UNIFY_STUDY.md` | Shipping the series as one pk3 or separate. |

## 5. Map tools
- `tools/mapview/` (README inside): `python tools/mapview/mapview.py <wad> -o <folder>` makes one page per map: a
  top-down view with toggle layers (sound-blocking lines, doors/lifts, trigger lines, secrets, exits/teleports,
  monsters by skill, keys/starts) and a computed **areas** layer (sectors joined, cut at doors, lifts and
  sound-blocking lines). The owner **draws named rooms** by dragging; Export/Import JSON in map units.
- Ideas for finding arenas (owner liked both): **sound-blocking lines** (mappers put them at room edges) and **the
  mapper's own fights** (trap triggers, monsters that wake together). Limits: sound blocks need two crossings in Doom;
  scripts on Hexen/UDMF maps are invisible to the tool.
- Pages for Doom, Doom II and Maps of Chaos are generated outside the repo (commercial IWADs); regenerate them with
  the command above. The owner's own room drawings, when he makes them, are the truth over the computed areas.
- Other sets held in `WADs/` (see its README): The Way id Did (E1-4, Doom II), No End In Sight ("might not be an easy
  set"). For later.

## 6. Rules of the house that bind design too
- Everything shipped must work on stock QuestZDoom 17.3. Canvas textures render **black in VR** on 17.3: world text is
  model quads, letter strips, sprites or VisualThinkers (see the inventory).
- Each mod stands alone; cross-mod links are by name lookups.
- Netplay matters: four-player co-op is a goal. Who owns a challenge in co-op is undecided.
- "Working" means shown working (frames or logs). Mockups are mockups.
- Commits: author presidentkoopa, explicit paths, never `git add -A`.

## 7. Open questions (ask one at a time)
1. Fill one challenge card together, field by field (Time Trial suggested), to prove the card format.
2. What triggers a challenge besides opening a door: a run of good shots (Score), or only doors?
3. The keyring: what role, if any?
4. Bits: tie them only to challenges (owner floated this), and how the jackpot pays.
5. Which Maps of Chaos maps to draw arenas on first (he plays it on both Doom and Doom II).
6. Co-op: who owns a challenge.
7. Where panels 1-2 (lock-on, danger flash) are allowed.

## 8. Not now
Building anything; the Wheel's mod support (parked in `design/PARKED.md`); rig clutter fixes (parked); Monster
Assembly, Score pruning and GBOVR pruning (the Big Three, later).
