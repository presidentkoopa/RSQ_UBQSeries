# Damage numbers for the arcade game (ideas lane A)

Proposals only. Nothing here is built, measured on the rig or approved. Every name is a placeholder for the owner
to rename. Written 2026-11-03 by a read-only ideas pass. It reads damnums (Xaser Acheron, MIT, cloned to
`/home/claude/ext/damnums-ideasA`) and the series repo: Score, Gun Bonsai VR, Melee, Saber, ShieldSaw, Whip,
Grapple, Grenade, SlowMo, Miniboss, GunCards, Accessibility and HP Bars.

## For the owner: the best ideas, one line each

1. **The number says which move did it.** Every hit's number takes the colour of the move that made it (whip, saber,
   shotgun, punch, grenade...), using the same move names Score uses. You learn your moves by their colours.
2. **The kill pays out in the air.** When something dies, the points Score paid for it rise in gold from the body,
   with the best bonus or combo name under it ("LION TAMER  +840"). Then they fly to your score.
3. **One growing number per monster.** Hits on the same monster add into one number that counts up, with a small
   "x3" for how many moves are in the chain. It fades as the 3-second chain window runs out, so you can see the
   chain rule.
4. **Headshots, crits and backstabs look different.** They are bigger and in their own shape, with one word: HEAD,
   CRIT, BACK. You learn where to aim and when to flank.
5. **PARRY, BLOCK and RETURN pop up.** When the saber, the shield or the Guard stops a shot, the word appears at the
   monster that fired it. A shot you send back shows its damage as a RETURN number.
6. **The miniboss shows "BLOCKED" while its thralls live.** You see how little gets through and how much the shield
   ate, so you learn to kill the thralls first. "IMMUNE" shows while it is invulnerable.
7. **Overkill shows.** Damage past the monster's last hit point shows as a red "+120 OVERKILL", so you can tell when
   the rocket was wasted on an imp, or when you gibbed something on purpose.
8. **Numbers lean toward the hand that hit.** A main-hand shot's number drifts toward your main hand, an off-hand
   shot's toward the off hand. The numbers sit in the world, never stuck to your face.
9. **Your upgrades show up.** Gun Bonsai procs like Shatter, Arc, Burn, Sting, Strike True and Lucky each get their
   own tint and word, so you can see your build working.
10. **Built for Quest, with comfort settings.** One shared pool of numbers with a hard cap, nearest first. No new
    art (it uses Doom's own small font, like Score's wrist digits). Every part has its own switch, and it follows
    Accessibility's size, colour-blind and photosensitive settings.

Every idea below has its own on/off switch. The numbers never pay points. Score pays only for fighting and killing,
and the numbers only show what Score already paid. A move has one name and one colour across every mod, taken from
Score's tool list (`Score/ideas/COMBOS_MASTER.md` 1.3).

---

## 0. Ground rules this file keeps

- **Who owns what** (`WHO_OWNS_WHAT.md`): HP Bars owns markers on monsters, so it gets numbers on monsters as well.
  Score owns points; the numbers only *show* what Score already paid, through its own reads. GunCards owns the
  wrist cards and already shows "+N" on an ammo pickup (`GunCards/README.md`, "+N"). Health and armour gained
  belong on GunCards' status card (idea H1), not in a second display.
- **Score pays only for fighting and killing.** No idea here makes a number worth points. If the owner wants
  Overkill to pay, that is a new row in `Score/ideas/NAMING_SHEET.csv`, owned by Score. It is not part of this
  feature.
- **One move is one move.** The colour or shape of a number comes from Score's tool id: `whip.crack`, `saber.cut`,
  `gun.shotgun` and so on, with the prefix as the family. Nothing here invents a second name for a move. Without
  Score loaded, a damage-type fallback applies (damnums' own LANGUAGE table, A1).
- **Every feature gets a switch.** Each idea lists a placeholder menu row. All of them go under one HP Bars page,
  "Damage Numbers", with a master "Show Numbers" switch and Reset All.
- **Stock QZD 17.3, ZScript only.** Nothing here needs the engine. One constraint is measured and important: **a
  canvas texture draws black in VR on QZD 17.3** (`Score/zscript/rsscore/wrist.zs` header, measured again by
  TacticalRig's holster count). So every number and word is billboard actors, one per glyph, as in damnums and as
  in Score's wrist.

---

## 1. What damnums actually does (read from its code), and what that means here

These are facts about the code, for the agent doing the fold. Each line says where it was read.

| Fact | Where | What it means for RSQ |
|---|---|---|
| One `DamNumTracker` (an Inventory) is given to every `bIsMonster` actor on spawn or revive, and it ticks every tic, comparing health. | `events.txt` WorldThingSpawned / `DamNumTracker.Tick` | On Brutal Doom that includes the gore helpers that carry ISMONSTER and big health: BootSmearer* (1000 hp, measured by Score, `handler.zs:85-115`) and HeadHitbox and its descendants (9999 hp, `GunBonsaiOffhandVR/rsq/zscript/killrewards.zs:45-51`). HP Bars already polls monsters itself, so its poll list should drive the numbers instead of an inventory on every monster. Then there is one tick cost instead of hundreds. |
| A number is the health lost since last tic, so all damage in one tic is merged. | `DamNumTracker.SpawnNumbers` | A shotgun's pellets come out as one number, which is good. But the tracker never knows **who** or **what** dealt the damage. `WorldThingDamaged` gives the source, inflictor, damage type and flags, so it should be used to find the cause (idea A1). |
| Only the `Massacre` damage type is filtered out. | `events.txt`, `SpawnNumbers` | brutal22test6 also uses `KillMe` (3 uses: helpers killing themselves) and `Extreme` (14). Filter `KillMe`. Measure what `Extreme` lands on before deciding. Counts are from a grep of `/home/claude/scratch/lsids/brutal22test6`. |
| Each digit is its own actor: 11 one-tic states, then a fade of 0.05 a tic, so it lives about 31 tics (0.9 s). | `damnum.txt` States, FADE_AMT | A 3-digit number is 3 actors. A minigun on 10 monsters is about 35 numbers a second, so about 100 actors a second, with around 95 alive at once. That needs a cap on Quest (idea K1). |
| Every number spawns a `DamNumFont` actor just to read its fields, then destroys it. | `spawnDamageNumbers` | `GetDefaultByType` reads the same fields with no actor. This is a free saving. |
| Colours come from LANGUAGE: `DAMNUM_TYPECOLOR_<damagetype>` gives a translation name. | `language.txt`, `spawnDamageNumbers` | Any mod can add colours without linking. This is the fallback when Score is absent (A1). BD's damage types include Head, Leg, Kick, Fire, Saw, Cut, Plasma, Fatality, Blood and ExplosiveImpact. |
| It reads `players[consoleplayer]` in play scope. | `spawnDamageNumbers` | This is fine in single-player VR. Kill Rewards fixed the same pattern for netgames (`killrewards.zs` header). |
| Numbers spawn at `height - 16`, under the HP bar. | `SpawnNumbers` | Already measured in the HP Bars full order (`TopHPBars/HANDOFF.md:133`, frame `fullorder_damnums_g2.png`). |
| Words: damnums has none (digits only, in pre-offset sprites `FC<count><place>`). | `damnum.txt` PostBeginPlay | Words like CRIT, PARRY and LION TAMER need glyphs. Doom's own small font STCFN033-095 has A-Z, 0-9, `+`, `!`, `%` and `x`. Score's wrist already shows STCFN glyphs as billboards through `picnum`, with no art and no TEXTURES (`wrist.zs` header). The same trick gives words. |

---

## 2. The foundation: three small pieces that unlock most ideas

**F1. One answer from Score: "what was this blow?"** (needs a small answer from Score)
Score's ledger (`Score/zscript/rsscore/combo.zs`, `RS_ComboLedger`) already stores the tool id and tags for every
blow a player lands on a monster (`eTool`, `eTags`, `eFirst`/`eLast`, `eHits`, `eCond`). Every tag the series
sends goes there: Gun Bonsai's crit, headshot, backstab, shatter, arc, burn and lucky (through `RSQM.Touch`,
`GunBonsaiOffhandVR/rsq/zscript/core.zs:83-95`), Melee's, the Whip's `crack`, Grenade's `cooked` and so on.
Following the series rule that nothing links, HP Bars must ask by name:

- `RS_ScoreService GetString("blow.last", "", playerNumber, 0, monster)` returns
  `"<tool>|<tags,...>|<conds>|<hits in run>|<tics since run began>"`, for example
  `"glove.upper|crit,hit.heavy|air|1|0"`, or `""` if there is none.
- `GetString("chain.of", "", playerNumber, 0, monster)` returns the live chain, oldest first, with the tics left
  before the 3 s gap breaks it: `"whip.crack>shield.bash|62"`.
- `GetString("kill.rows", "", playerNumber, serial)` returns the rows a kill paid, best first, as
  `"Lion Tamer:0.6:melee|Air:0.3:style"`. Score already keeps `kBase`/`kStyle`/`kChain` per kill
  (`handler.zs:1104-1115`); the row names are known when it adds rows (`AddRow`). This is the one new field.

Score answers these reads only. They do not change what it pays.

**F2. Spawn the number one tic after the hit.** The handler that sees `WorldThingDamaged` notes the hit:
victim, source, inflictor, damage, damage type, and the health left (below 0 means overkill). It spawns the
number on the next `WorldTick`. By then every handler's `WorldThingDamaged` has run, including Score's ledger,
so it does not matter which handler runs first. damnums' tracker is already a tic late, so nobody sees a
difference.

**F3. A glyph pool.** A fixed ring of billboard actors (`picnum` set to an STCFN glyph or a damnums digit) that
are hidden and shown again, never spawned per hit. `wrist.zs` keeps such a fixed array (`dig[]`, hidden with
`bINVISIBLE`). See K1 for the numbers.

---

## 3. The ideas

Status: **readable today** means the fact is already sent or answered and only HP Bars' own code is needed.
**Needs** names the small answer the owning mod must add. Each idea also lists its placeholder switch.

### A. Which move did it

**A1. Move colours** (TOP 10 #1). The number is tinted by the move's family, which is the prefix of Score's tool
id: `glove`/`punch` warm white, `saber` the blade's colour, `shield` steel, `whip` tan, `hook` green, `grenade`
orange, `force` violet, `gun.*` by class (pistol, shotgun, rifle, explosive, energy, fire: the six in
COMBOS_MASTER 1.2). Teaches: you see your moves by colour, and a chain of three colours on one monster is a chain.
- Reads: F1 `blow.last` (the tool). Without Score: the damage type through damnums' LANGUAGE table, plus a small
  HP Bars LANGUAGE file for BD's types (Head, Kick, Saw, Cut, Fire, Plasma...).
- Status: fallback readable today. Per-move colour needs F1 from Score.
- Colour-blind: colour is never the only cue. Each family also has a small glyph before the number, taken from
  STCFN (`!` fists, `/` blade, `#` shield, `~` whip, `*` grenade, `>` gun), and the palette follows
  `rsqa_colorblind` (J1).
- Switch: "Colour by Move: On / Damage Type / Off".

**A2. Punch kinds.** A jab, hook and uppercut each throw their number differently: a jab's goes straight up, a
hook's to the side the hook came from, an uppercut's high with a short hang. It teaches the three punches that
Textbook, Triple Threat and Dempsey Roll ask for (`NAMING_SHEET.csv` lane A M5-M7).
- Reads: `RSQML_Service GetInt("punch.kind")` returns 0/1/2 (`Melee/zscript/rsqml/service.zs:7`), or
  `glove.jab/hook/upper` from F1. Readable today.
- Switch: "Punch Styles".

**A3. One name, one colour, everywhere.** BD22 VR's butt strike and Melee's shove are one tool, `shove`
(COMBOS_MASTER 1.2). Their numbers look the same whichever mod delivered the blow. This is not a separate
feature; it is what A1 guarantees when it reads Score's id rather than the inflictor.

**A4. Off-hand numbers are mirrored.** A number from the off hand's gun is drawn in an outline style, or as the
mirror of the main hand's tint. A two-gun player can then read Two Guns and Off-hand at a glance.
- Reads: the same test Score uses (`BT_OFFHANDATTACK` alone, `Score/zscript/rsscore/tools.zs:248-251`); for melee,
  whether the inflictor is the off-hand weapon. Readable today.
- Switch: part of A1.

### B. Hits that should read differently

**B1. HEAD / CRIT / BACK stamps** (TOP 10 #4). The number is 1.5x bigger and shown with a short word, and it gets a
one-tic pop in scale (no flash, so it is photosafe).
- HEAD reads BD22's damage type `Head`/`MinorHead`, the same test as Score's `+head`
  (`Score/zscript/rsscore/combo.zs:150`). Readable today, with no Score needed. **Do not** draw the number on
  BD's HeadHitbox (9999 hp, ISMONSTER); draw it on the monster it rides.
- CRIT and BACK read Gun Bonsai's `crit`/`backstab`/`headshot` tags (`up_fists.zs:776/833/854`) through F1.
  This needs F1.
- Teaches: aim high, flank. It also teaches Gun Bonsai's Critical Hits and Backstab nodes without opening a menu.
- Switch: "Crit Stamps".

**B2. PARRY / BLOCK / RETURN** (TOP 10 #5). A block deals no damage, so damnums never shows it. The word appears
at the monster whose shot was stopped:
- Saber: `UBQS_SaberService GetInt("perfect"/"blocked", monster)` returns tics since
  (`QuestSaber/zscript.txt:6793-6794`).
- ShieldSaw: `SSQ_ScoreService "perfect"/"blocked"` (`ShieldSaw/zscript/ssq/score.zs:129-131`).
- Melee's Guard parry: tool `guard.parry` in F1.
- All of these are readable today. HP Bars already asks services about each tracked monster (its markers), so
  this costs one more question on the same 4-tic cadence.
- A returned shot that hits shows its damage in the RETURN style, read from tool group `return` (`saber.return`,
  `shield.return`, `hadouken`, `swat`, `guard.reflect`, `whip.return`, `grab.shield`; COMBOS_MASTER 1.5) through
  F1.
- Teaches: what Riposte, Perfect Riposte and Return to Sender (the Counterplay family) need, before the kill pays
  it.
- Switch: "Defence Words".

**B3. Overkill** (TOP 10 #7). On a killing blow, the health below 0 shows as a second, smaller red number:
"+120 OVERKILL". On Brutal Doom a gib (health past the gib line, or `Extreme`) says GIBBED instead.
- Reads: `WorldThingDamaged` with `e.Thing.health < 0`. Readable today, needs nothing.
- Teaches: spend the right ammo. No pay is attached.
- Switch: "Overkill".

**B4. Melee finishers.** Glass Jaw, Liver Shot and Shoryuken are rows Score already pays on the kill. The finishing
punch's number takes the row's word (see D1). Before the kill, Melee's `hit.heavy` and `hit.body` tags tint
heavy hits and body hits. Reads F1 tags. Needs F1.

### C. Chains and combos

**C1. The rolling number** (TOP 10 #3). Hits on one monster by one player add into **one** number that counts up
in place: 12, 31, 58... It does not make a new number per hit. A row of small tool glyphs grows under it (A1's
glyphs), with "x3" for the actions in the chain. The whole stack dims over Score's chain gap (105 tics,
`combo.zs` CHAIN_GAP) and drops when the chain breaks.
- Reads: F1 `chain.of` gives the chain and the tics left. Without Score: a plain 105-tic merge window, with no
  chain glyphs.
- Status: the merge is readable today. The chain glyphs need F1.
- Teaches: the owner's 3-second rule and Score's "order matters" without a word of text. It is also the biggest
  Quest saving, since one 3-digit number per monster replaces a new one each hit (K1).
- Switch: "Rolling Numbers: On / Off (one per hit)".

**C2. Named combo stamp.** When a kill completes a named combo (Lion Tamer, Clay Pigeon, F.E.A.R. Effect: the 823
named chains in COMBOS_MASTER), the name stamps over the body in big STCFN letters for about a second, in the
colour of the row's family. Reads F1 `kill.rows`. Needs F1. This is part of D1.

**C3. One step away (later, needs more of Score).** While a live chain matches the first steps of a named combo,
a faint hint of the next tool's glyph shows on the monster: "~ >" for "a gun finishes Lion Tamer's whip". Score
would need to answer `chain.next` (the best pattern the live chain is a prefix of). That is real work in Score's
matcher (`RS_Combo.Match`), not a field read. Mark it later. It teaches combos better than any list, but it could
feel like a tutorial, so it is off by default.

**C4. Multi-kill counter.** One blow that kills several (Shockwave, Stampede, Blast Radius, a grenade) puts a
"x2", "x3" stamp over the last body. It reads Score's same-tic kills (`kill.serial` stepping more than once in a
tic), which is readable today. Switch: part of "Kill Payout".

### D. Kills and Score

**D1. The kill payout** (TOP 10 #2). On a kill, the total Score paid (base + bonuses) rises in Score's gold from
the body, with the best row's name under it in that row's family colour (Efficiency, Style, Daring, Melee,
Counterplay: `Score/zscript/rsscore/bonus.zs:39-46`, colours `RSScore_*` in `Score/TEXTCOLO.txt`). After half a
second it flies to where the score lives: the top-right HUD direction, or the off-hand wrist when Score on the
Wrist is on (`rs_score_wrist`, `wrist.zs`).
- Reads: `RS_ScoreService GetInt("kill.serial"/"kill.base"/"kill.style")` and `GetString("kill.chain")`, all
  answered today (`awards.zs:61-140`). The row name needs F1 `kill.rows`.
- Status: points readable today; the name needs F1.
- Teaches: what a kill was worth and why, at the spot where you earned it. The HUD list stays the record, and this
  becomes the moment.
- Switch: "Kill Payout: Points and Name / Points / Off".

**D2. Big moment.** If `kill.big` is 1 (`awards.zs`), the payout is double size and holds still for the slow
motion Score asks for. Readable today. Part of D1.

**D3. Stretched Second in cyan.** A kill in slow motion shows the extra share Score paid for it (Slow Motion Style)
as a cyan "+n" beside the gold. Reads `RSQSM_Service "slowmo.active"` and `"trigger.auto"`
(`SlowMo/zscript/rsqsm/clock.zs:1381-1401`), and the payout's rows from F1. It needs F1 to split the share out.
Teaches: your own slow motion pays more than an automatic one.

**D4. Target crossing.** When a kill crosses the map's target (a reward: a life or ammo), that kill's payout turns
into the reward's word (LIFE, AMMO) and flies to the life pips. Reads `progress`/`rewards` (`awards.zs`, also
`GetIntUI`). Readable today. Switch: part of D1.

**D5. Raised monsters pay less, and show it.** A monster that was not on the map at the start pays
`rs_score_farmpercent` (Raised Monster Pay). If the owner sets it under 100, that kill's payout shows grey with a
small down arrow, the same arrow HP Bars already uses for "raised" (HP8). It teaches why farming an Arch-Vile does
not pay. HP Bars already knows a raised monster (WorldThingRevived), so this is readable today.

### E. Gun Bonsai upgrades showing themselves

**E1. Proc tints** (TOP 10 #9). Each glove element and upgrade proc has its own small word and tint under the
number. Reads: the inflictor class `RSQ_GloveHit` (`core.zs`: an element's blast, arc or burn is dealt through
it), readable today by class name. The exact proc comes from F1 tags:

| Proc | Word | Tag (source) |
|---|---|---|
| Frost Fist shatter | SHATTER (ice blue) | `shatter` (`up_fists.zs:203`) |
| Shock Fist arc | ARC (yellow) | `arc` (`up_fists.zs:263`) |
| Burn | BURN (orange, small repeating numbers) | `burn` (`up_fists.zs:299`) |
| Whip Sting | STING | `crack` (Whip, COMBOS_MASTER 1.4) |
| Strike True (saber, shield hit-stop) | a freeze glyph; the number hangs for the 3-6 frozen tics | the monster's `freezetics`, which HP Bars already reads for its snowflake (HANDOFF "Frozen") |
| Lucky | LUCKY (gold) | `lucky` (`killrewards.zs:232`) |
| Explosive Fist | BLAST, on each body hit | `fist.explosive` |
| Knockdown | DOWN | needs Gun Bonsai to tag `knockdown` (NAMING_SHEET M28: "not sent today") |

- Teaches: whether the node you bought is doing anything, the question Gun Bonsai players always ask.
- Switch: "Upgrade Procs".

**E2. Damage over time as small ticks.** Burn, Incendiary grenade and BD's flamethrower afterburn tick in small,
dim numbers that roll into one (C1), so a burning room does not fill with digits. Readable today: the damage types
`Fire`/`Burn`/`Flames` and the `burn` tag.

### F. Miniboss, Champions, LegenDoom

**F1m. BLOCKED while thralls live** (TOP 10 #6). `RSQMB_Service GetInt("shield", monster)` gives the share of
damage the miniboss takes now, in permille (`Miniboss/zscript/rsqmb/service.zs` header). The number shows what got
through, small, plus the share the shield ate as a grey "BLOCKED n". That is the real damage times
(1000 - shield) / shield. While `invulnerable` is 1 it shows IMMUNE. While `greed` is armed, a small coin glyph
shows on each hit (the greed rule comes due).
- Readable today. Cheap first test: the monster carries `RSQMB_Ward` (by name).
- Teaches: kill the thralls first, without a tutorial. The grey number shrinks as each thrall dies.
- Switch: "Miniboss Feedback".

**F2m. Thrall hits show their link.** A hit on a thrall shows a small chain-link glyph (HP Bars' chain-link marker
already exists, README "crown / chain link"). The thrall's kill shows the living count left: "3 LEFT". Reads
`thrall` and `living`. Readable today.

**F3m. Lives.** A miniboss losing a life shows "LIFE -1" in place of a damage number. Reads `lives`. Readable
today.

**F4m. Champions and legendaries.** Hits on a champion take the champion's tier colour on the number's outline;
hits on a dormant LegenDoom candidate show plain numbers. This keeps HP Bars' 11-02 rule that candidates do not
give themselves away (HANDOFF). Reads what HP Bars already reads (Champions' icon, LegenDoom tokens). Readable
today.

### G. Slow motion

**G1. Numbers hang in slow motion.** SlowMo slows "everything near you... every slowed thing still moves every
tic, by the slowed amount" (`SlowMo/README.md`). Whether its slowing reaches a NOINTERACTION number actor must be
measured on the rig. If it does not, HP Bars scales the number's rise and fade by `RSQSM_Service "scale"`
(permille), which is readable today. Numbers floating slowly in bullet time is the arcade picture.
- Switch: "Slow Numbers in Slow Motion".

**G2. Your own slow motion vs automatic.** In slow motion you started yourself (`trigger.auto` 0), numbers get a
thin cyan edge. In an automatic one (`trigger.auto` 1) they do not. Score pays the two differently (Score README,
"Stretched Second"); this shows it. Readable today.

### H. Rewards on you

**H1. Health and armour as +N on GunCards' status card.** It does not go in the world. Kill Rewards bits are 25
health / 10 armour / 5 ammo (`killrewards.zs` header). GunCards already shows "+N" for ammo
(`GunCards/README.md`). Proposed as a **GunCards** row, "+N for Health and Armour", reading the pawn's health and
armour change per tic. Readable today. It is listed here so nobody builds it twice.

**H2. The fountain counter.** A boss's Kill Rewards fountain (By Health: a Cyberdemon about 1000 bits; the owner
loves it, GBOVR_TREES 3.14) shows one rolling "+health / +armour / +ammo" total over the body as you collect,
instead of one number per bit. It reads the bits picked up near the body. It needs the counting done in Gun
Bonsai VR's Kill Rewards (`RSQ_KRHandler`), so it is a GBOVR row: "needs `kr.collected` from RSQGB_Service".
Switch there.

### I. VR placement

**I1. Toward the hand that hit** (TOP 10 #8). The number's toss heading leans 20-30 degrees toward the hand that
dealt the blow (main or off: A4's test). For melee, it comes back along the line from the hand to the monster,
so a punch's number appears between you and the target. Reads `pmo.AttackPos` / `pmo.OffhandPos` (used by
`wrist.zs:53-54`, QZD 17.3). Readable today.

**I2. In the world, never head-locked.** Numbers are billboards at the monster, sized like HP Bars: they grow with
range (`rsqthp_far`, 256 to 1024 units) so a far hit is still readable. Nothing is drawn on the flat HUD. The
exception is D1's last flight to the HUD score.

**I3. On the weapon.** An option for cramped fights: the last hit's number sits on a small plate by the firing
hand's gun for half a second, as GunCards' small card does. It reads the same hand poses. Readable today. It is
**off** by default, and it must not overlap GunCards' card. If both are on, GunCards wins and I3 sits above it.

**I4. Behind you.** A hit you land on something you cannot see (Blind-fire, No-Look, a thrown saber or disc) puts
its number at the monster plus a small edge arrow in view. This reuses Accessibility's off-view cue idea
(`rsqa_sound_cues` 1 Visual, which marks hits from off-view). Proposed as an Accessibility-shared cue. It needs an
answer from Accessibility if its arrow is reused. Otherwise HP Bars draws its own.

### J. Accessibility and comfort

**J1. Follows RSQ Accessibility.** `rsqa_text_scale` sets number size (x1-x3). `rsqa_cue_scale` sets the glyphs.
`rsqa_colorblind` 1-4 sets the move palette: the same Machado-simulated check HP Bars already runs
(`TopHPBars/tools/cvd_check.py`), worst dE reported. `rsqa_photosafe` 1 removes every pop and pulse and keeps the
spacing to 14 tics (HP Bars HP7's rule). All of these are readable today (`Accessibility/CVARINFO.txt`).

**J2. Modes for comfort.** "Show Numbers: All / Kills and Big Hits / Kills Only / Off". Kills Only keeps D1 and
drops the rest, for players who want the score moment without the digits.

**J3. Distance and count.** HP Bars' own Distance Limit and Nearest 24 (HP3/HP4) apply to numbers too, with their
own sliders.

### K. Quest budget

**K1. Pool and caps** (TOP 10 #10, with J). One pool of 64 glyph actors, all numbers and words together, at
`STAT_USER` like damnums' statnum 88. Proposed caps, to be measured on the rig:
- At most 12 live numbers. A new one takes the oldest slot, but never a payout's.
- C1's merge means one number per monster per chain.
- Burn ticks always merge (E2).
- Nearest first when over the cap.
- No `DamNumFont` actor per number (section 1).
- The per-monster tracker is replaced by HP Bars' poll (section 1).
- PC: the cap doubles when the pool sees no frame-time pressure. That is a cvar, not detection.

**K2. Measure before claiming.** Run the HP Bars rig probe (`tools/rigprobe/run.sh`) with a 30-imp room under BFG
and minigun fire. Log the live glyph actors per tic and the frame time with numbers on and off. This file claims
no number for it.

---

## 4. Top 10 summary

| # | Idea | Reads from | Status |
|---|---|---|---|
| 1 | A1 Move colours | Score tool id (F1); damage-type fallback | fallback today; needs Score `blow.last` |
| 2 | D1 Kill payout + name, flies to score/wrist | `kill.serial/base/style/big`, `rs_score_wrist` | points today; name needs Score `kill.rows` |
| 3 | C1 Rolling number + chain glyphs, fades over the 3 s gap | `chain.of` (F1) | merge today; chain needs Score |
| 4 | B1 HEAD / CRIT / BACK stamps | BD `Head`/`MinorHead`; GBOVR tags via F1 | HEAD today; CRIT/BACK need F1 |
| 5 | B2 PARRY / BLOCK / RETURN words | saber/shield `perfect`/`blocked`; `return` group | today (RETURN needs F1) |
| 6 | F1m Miniboss BLOCKED / IMMUNE | RSQMB `shield`/`invulnerable`/`greed` | today |
| 7 | B3 Overkill / GIBBED | health below 0 at the killing blow | today |
| 8 | I1 Numbers lean toward the hand that hit | AttackPos/OffhandPos, BT_OFFHANDATTACK | today |
| 9 | E1 Upgrade proc tints | `RSQ_GloveHit` inflictor; GBOVR tags via F1 | partly today |
| 10 | K1 + J1 Pool, caps, Accessibility | pool code; `rsqa_*` | today |

Honourable mentions: G1 slow numbers in slow motion (measure first), F2m thrall links, A2 punch kinds,
D3 Stretched Second in cyan, C3 one step away (later).

## 5. What to ask each mod (all small, all by name)

| Mod | Answer | For |
|---|---|---|
| RSQ Score | `blow.last`, `chain.of`, `kill.rows` (GetString on RS_ScoreService) | A1, B1, B2, B4, C1, C2, D1, D3, E1 |
| Gun Bonsai VR | send the `knockdown` tag (already listed, NAMING_SHEET M28); `kr.collected` | E1 DOWN, H2 |
| GunCards | a "+N for Health and Armour" row | H1 |
| RSQ Accessibility | share its off-view arrow (optional) | I4 |

Nothing else is needed. Everything in section 4 marked "today" works on what the mods already answer.

## 6. Open questions for the owner

- Should numbers show at all without Score loaded, as damage-type colours only?
- Is the payout's flight to the HUD wanted, or should it fade where it rose?
- Overkill: show only, or should Score also get an "Overkill" row (a Score decision, through the naming sheet)?
- Default: All numbers, or Kills and Big Hits? On Quest, the second is cheaper and less busy.
