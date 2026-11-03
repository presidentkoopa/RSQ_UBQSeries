# Damage numbers: giving them life (ideas lane B, presentation)

Ideas only, 2026-11-03. Nothing here is built, and nothing is promised as working. Each idea is a
proposal for the owner to pick from; every one gets its own on/off switch in the menu and a line in Reset All.
Mockups (made from the series' real art, not in-engine frames): `mock1_pop.png`, `mock2_ramp_specials.png`,
`mock3_running_total.png`, `mock4_fonts_quality.png`, next to this file.

## The short list (plain language)

Foundation first: draw the numbers with the engine's "visual thinker" (a lightweight floating picture)
instead of one full monster-style actor per digit. It costs **no sprite frames**, which matters because the
load order is near the engine's sprite-frame ceiling. All ten ideas below sit on top of it.

**Top 10**
1. **Our metal font, coloured by how hard you hit.** JFO's metal digits (Gun Cards' font): white for chip
   damage, then yellow, orange, red, and glowing magenta for a crit. Quest/PCVR quality switch like Gun Cards; Ermac's
   pixel digits as the other font.
2. **Pop and settle.** A number pops out small, overshoots to about 1.5x, snaps back, drifts up and fades:
   a punchy "hit" feel instead of a number that just appears.
3. **Bigger hits, bigger numbers.** Size grows with the share of the monster's health the hit took, and
   the number grows with distance the same way HP Bars do, so it stays readable across a room.
4. **Running total on the target.** Chaingun and shotgun hits don't flood the air: they fly into one total
   beside the monster's HP bar that counts up, with a "x5" hit counter. It bumps on every hit.
5. **The kill moment.** On the kill, the total slams to a big final number; if you hit far past zero it
   says OVERKILL, a burst goes off behind it, and then the digits shatter.
6. **Headshot / Crit / Backstab words.** A short word over the number in its colour, with the Melee burst
   that already means that thing (the red burst for a headshot).
7. **Hit-stop and slow motion change them.** Numbers freeze with a hit-stop, then pop when it releases; in
   slow motion they hang in the air, bigger and slower ("bullet-time numbers").
8. **Never in your face.** Numbers stay at the monster's distance (never closer than about a metre), turn
   to face you, slide out of your line of aim, and only the nearest few show.
9. **Gains on you.** +25 health (green), +armour (blue), +ammo (gold) float off the pickup and fly to your
   wrist, landing on Gun Cards' card, which already shows "+N" for ammo.
10. **Big moments in 3D.** For a miniboss losing a life, a champion or a legendary falling: one large
    voxel number that tumbles in 3D. Rare, so it's cheap.

Everything else (damage-type colours, combo-coloured numbers, a wrist damage tally, damage-per-second
readouts, sounds) is in the details below.

---

## 0. What damnums does today (parsed from its source)

Read from `/home/claude/ext/damnums-ideasB/src` (MIT, Xaser Acheron). Parsed, not run.

- **One Actor per digit.** `DamNum : Actor`, `+NOINTERACTION +CLIENTSIDEONLY +BRIGHT`. "123" is three actors.
- **Placement by baked sprites.** Each digit's sprite name is `<prefix><length><place>` (e.g. `_C32` = 2nd digit
  of 3), and `textures.txt` bakes a canvas per (length, place) with the digit patched at its offset, so a
  billboarded sprite lands in the right column. 7 lengths give 28 sprite names x 10 frames (A-J = 0-9) =
  **280 sprite frames per font**. All 13 fonts: 130 PNGs + 3,510 `Sprite` entries in TEXTURES = **3,640 frames**
  (counted with grep).
- **Motion:** "toss" (gravity 0.4, a random sideways kick of 1, up 3-4) or "float" (up 1, no gravity). Angle
  toward the console player +/- 20 degrees.
- **Life:** 10 tics full, then alpha -0.05 a tic (`A_FadeOut`) = about 30 tics, 0.86 s.
- **Colour:** a TRNSLATE ramp per font (`"0:255=%[0,0,0]:[r,g,b]"`), the user's colour, or per damage type
  through LANGUAGE `DAMNUM_TYPECOLOR_<type>`.
- **Tracking:** every monster gets an Inventory `DamNumTracker` on spawn that ticks every tic and compares
  health (so one tic's hits sum into one number). "Spray" mode spawns per hit from `WorldThingDamaged` instead.
- **Per hit it Spawns and Destroys a `DamNumFont` actor** just to read its defaults, and reads 4 CVars.

What that means for us:
- **Sprite budget:** the brief says the order uses about 54,700 of 65,535 sprite frames (the 16-bit index
  Gun Cards documents in `tools/gen_side.py`). One damnums font is 280; all 13 would take a third of the
  headroom left. Ship at most one font as sprites, or better, none (section 1).
- **Per-monster ticking inventory** is the wrong shape for slaughter maps on Quest: 1,000 monsters = 1,000
  extra thinkers ticking every tic. HP Bars already polls monsters (every 16 tics) and its bar actor already
  knows `lastHp`; it is the natural place to notice damage, or `WorldThingDamaged` gives it for free per hit.
- The font actor per hit and the CVar reads per hit are small but avoidable (cache once a tic).

## 1. Foundation: what to draw the numbers WITH (checked in the QZD 17.3 source)

Checked in `/home/claude/g9/src/qzd/wadsrc/static/zscript` (the rig's QZD 17.3 source, `version "4.14.2"`).
Every option below exists there. "Rig-proved in the series" means some RSQ mod already uses it.

| Way to draw | Sprite frames | Cost per digit | Can it move after spawn? | Notes |
|---|---|---|---|---|
| **VisualThinker** (`visualthinker.zs`) | **0** (takes a TextureID) | one light thinker, no states, no blockmap | yes: Pos, Vel, Scale (x,y), **Offset (pixels)**, Roll, Alpha, Translation, per tic | Offset does damnums' column trick with no baked sprites. **Not yet used anywhere in the series: rig-prove it first, in stereo, on Quest GLES.** |
| Textured particle (`A_SpawnParticleEx` / `FSpawnParticleParams`) | 0 | cheapest: engine pool, no thinker | no: velocity, accel, size step, fade step, roll speed are set once at spawn | Fire-and-forget only (sparks, shards, trails). `r_maxparticles` default 4000 is a shared, user-set pool; `SPF_NOTIMEFREEZE`, `SPF_ROLL`, `SPF_FACECAMERA` exist. No Translation field: a tint needs a tinted texture (or `color1`, behaviour with a texture to check on the rig). |
| Actor with sprite (damnums) | 280 per font (baked) or 10-12 if offsets are done by moving the actor | full actor + states | yes | Rig-proved everywhere (Melee's sparks and bursts are actors). |
| Voxel actor (VOXELDEF) | 1 per glyph (a voxel binds to a sprite frame) | a model draw per digit | yes; VOXELDEF has `UseActorPitch`, `UseActorRoll`, `PitchFromMomentum` (voxeldef.cpp) so a digit can tumble | Gun Cards bakes JFO glyph voxels (16,388 lines of VOXELDEF). Heavier to draw: keep for rare moments. |
| Canvas texture (ANIMDEFS `canvastexture` + `TexMan.GetCanvas` + `DrawText` in `UiTick`) | 0 (+1 frame for the quad it is worn on) | one texture redraw when the text changes | the texture is redrawn; the quad moves | **Rig-proved in the series:** LaserSight's range readout (`RSLRANGE`, worn by a quad model, `sight.zs` UiTick). Any font (JFO as a ZDoom font, Score's `RSSCFON.fon2`) and any string. One canvas per live total, so a few at most. |
| HUD / RenderOverlay text | 0 | cheapest to draw | n/a | In VR this is a flat sheet near your face, not at the monster: no good for world numbers. Fine for a corner "total damage" readout if ever wanted. |

**Recommendation:** VisualThinker digits for every ordinary number (with a pool, section 9), textured particles
for the shatter shards and trails, one canvas-texture plate per running total (idea 4) if the per-digit total
looks busy, and voxels only for idea 10. Zero sprite frames for everything but idea 10 (about 12 frames).

The glyph art goes in `graphics/` (or a TEXTURES `Graphic`) so it is a texture, not a sprite. JFO's big digits are
64x64 grey metal (`GunCards/tools/card_art/jfo/big/fontb048-057.png`, plus `+` 043), so one greyscale set takes
any colour through a translation ramp, exactly like damnums' `%[0,0,0]:[r,g,b]` ramps (mockups 2 and 4 use that
maths). JFO small (32 px) has 0-9, A-Z, `+ - = / :` (41 glyphs copied, no `.` or `!`): enough for the words.

---

## 2. Fonts and quality

- **JFO metal (default).** The series font (Gun Cards made it "our font", owner 2026-11-03). Its beveled grey
  metal reads as a number with weight; tinted, it keeps the bevel (mockup 4). Needs: the 11 big glyphs as
  textures, done by a tool from `card_art/jfo` (no new art).
- **Quality: Quest / PCVR**, the same switch Gun Cards has (`rsqgc_text_q`): Quest = glyphs at half resolution
  (32x32 for the big ones), PCVR = full 64x64. Same size on screen. Mockup 4 shows the two side by side; at number
  size the difference is small, so Quest default costs little.
- **Ermac's digits** (`card_art/digit_0-9, plus`, 12x12 pixel art with a black edge). Crisp and arcade, reads well
  small; the second font, like Gun Cards' `rsqgc_small_font`. Tinted, the black edge stays (mockup 4).
- **Outline / glow.** Baked into the textures, not computed: a 2-3 px dark edge (the colour's own darkest shade, as in the
  mockups) helps against bright skies and fire; a soft glow only on the crit tier (two extra textures:
  glow-backed digits, or one additive "halo" texture behind the number). Needs: a tool pass, no hand art.
- **Voxel 3D digits.** See idea 10. Gun Cards' voxel tooling (`tools/gen_side.py`, `jfo.py`) already turns JFO
  glyphs into KVX at two qualities; a standing 3D digit is a simpler case (a front-facing extrusion).
- **Not recommended:** shipping damnums' 13 fonts. Its game-matching fonts (Doom, Heretic, Strife...) don't
  fit a Brutal Doom VR series that already has a look, and they cost frames if kept as sprites.

## 3. Motion

All motion is per tic on the pooled thinkers, eased in script (no engine help needed). Numbers below are
starting values to tune on the rig, not measurements.

- **Pop and settle (top 10 #2, mockup 1).** Scale 0.35 at tic 0, 1.45 at tic 1, 1.15 at tic 2, 1.0 at tic 3; hold
  rising slowly; fade over the last 8 tics. The overshoot is what makes it feel struck. Big hits overshoot more,
  chip hits barely.
- **Arc away from the shot.** `WorldThingDamaged` gives `DamageAngle` (the direction the hit came from):
  numbers kick away from you along the shot, with a small up-arc, so a shotgun blast sprays numbers out of the
  target. Gentler than damnums' random toss and it tells you where the hit came from.
- **Bounce.** For heavy hits only: falls back to its spawn height once with a 30 % bounce, then fades. Cheap
  (one if in the tick).
- **Shake.** A crit number jitters 1-2 px (Offset) for 4 tics. Offset moves the picture, not the thinker.
- **Stack and merge (top 10 #4, mockup 3).** Hits on the same monster within about 12 tics don't spawn new
  floaters past the first: each new hit's number flies (6 tics, ease-in) into a total beside the HP bar, and the
  total bumps (x1.25 for 2 tics) and counts up. A hit counter "x5" in JFO small sits after it. The total
  fades 20 tics after the last hit. This is the single biggest readability gain for chainguns, BD's
  pellet shotguns and the minigun.
- **Count-up ticker.** The total doesn't jump 52 to 64; it rolls through the digits over 4-6 tics. Each step
  is only a texture swap on a digit.
- **Shatter (top 10 #5).** On the kill, each digit of the final number breaks into 4-6 textured particles
  (quarter-digit shards, from the same metal texture cut by the tool) with an outward velocity, gravity and
  roll. Particles: no thinkers.
- **Fly to the hand / wrist (top 10 #9).** Gains on you fly from the pickup to the controller's wrist (the
  same hand position Gun Cards uses) over about 10 tics, shrinking, then land as Gun Cards' "+N".
- **Fly to a score tally.** With RSQ Score loaded, the kill's points could fly from the corpse to the Score
  readout. That belongs to Score; listed here only so the two don't fight over the same moment.

## 4. Size with damage

- **By share of the monster, not raw damage (top 10 #3).** BD's numbers range from 3 (a pistol on a zombie) to
  hundreds (a BFG), and the same 40 is a kill on a zombie (BD spawn health 40, measured in HP Bars' HANDOFF) and a
  scratch on a Cyberdemon (5000). Size = 0.55 to 1.5 by `damage / spawn health`, log-scaled, with a small
  raw-damage floor so a 300-hit on a boss is still big. HP Bars already reads spawn health for its length (HP6).
- **Distance compensation:** reuse HP Bars' Far Size curve (x1 up to 256 units, to `rsqthp_far` at 1024) so a
  number across a room is as readable as one at arm's length. Same CVar, so the bar and its number grow together.
- **Cap:** never more than about 1.5 x the bar's height, so a BFG hit doesn't wall off the view.

## 5. Colour

- **Tier ramp (top 10 #1, mockup 2):** chip white, solid yellow, heavy orange, huge red, crit magenta with
  glow. Tiers by share of spawn health (e.g. < 5 %, < 15 %, < 35 %, < 100 %, crit/kill flag). Five
  translations, no art.
- **Damage type (option):** fire orange, plasma cyan, BFG green, poison sickly green, frost pale blue, using
  damnums' LANGUAGE table idea. Off by default, because it fights the tier ramp; the owner picks which wins.
- **Match the series:** the crit/headshot reds and frost/shock colours can be the same as Melee's burst
  variants (`RSQML_BurstH` red, `BurstF` frost, `BurstS` shock yellow, `BurstR` fire) so one colour means one
  thing across the series.
- **Colour-blind / high contrast:** follow HP Bars' rule (`tools/gen_art.py` sets): a cue that is not colour.
  Here: size and the tier word already carry it; the crit tier also gets the shake. RSQ_Accessibility's
  Photosensitive Mode dims the crit glow and stops shake, as it does HP7's flash.
- **Ally hits** (you hit a friendly / BD marine): RSYG blue like HP2, or none.

## 6. Special treatments

Only where the series already knows the fact (by name, through its services) or the engine says it:

| Moment | How we know | Treatment |
|---|---|---|
| Headshot | BD22's headshot damage type / Melee's headshot (`BurstH`) | HEADSHOT in JFO small above, red, `RSQML_BurstH` behind (mockup 2) |
| Crit | Melee's / Gun Bonsai VR's crit (they spawn `RSQML_Burst2`) | CRIT, magenta glow, shake |
| Backstab, Parry, Riposte | Melee (`Burst4` white perfects) | the word in white |
| Overkill | damage past the monster's health at death (`damage - health before`) | OVERKILL gold, the overkill amount small under the final number |
| Finisher | Melee's Finisher (`Burst5`) | FINISHER, the big burst, a longer hold |
| Miniboss life lost | `RSQMB_Service` (HP Bars asks it already, #16) | idea 10, with HP Bars' crown |
| Champion / LegenDoom turn | HP Bars already reads their tokens by name | the gold number, the champion's own colour |
| Infight hits (monster on monster) | DamageSource is not a player | smaller, grey, or off (option) |

The words need JFO small glyphs we have (A-Z). Each word is about 6-9 thinkers; one per hit at most.

## 7. Death and overkill

- **Final number slam:** on death the running total (or the killing hit) scales to 1.6 in 2 tics, holds 10,
  then shatters (particles). With a big overkill, the OVERKILL word drops in from above.
- **Gibs:** BD gibbing is the overkill moment players already see; the number should sit above the gib cloud,
  not in it (spawn at the monster's top, as HP Bars places the bar).
- **No number for "Massacre" / kill-all cheats** (damnums already skips `'Massacre'`): keep that.

## 8. Hit-stop and SlowMo

- **Hit-stop:** Melee's hit-stop freezes the monster (`freezetics`, which HP Bars reads for its snowflake). The
  number of that blow can spawn frozen at 1.45 scale (the pop's peak) and hold while the monster is frozen,
  then release into the settle. It makes the hit-stop read as a single beat.
- **SlowMo:** `RSQSM_Service` answers `"active"` and `"scale"` (x1000; clock.zs line ~1385). Two choices
  (option, owner picks the default):
  - **World time:** numbers slow with the world (velocity and fade scaled by the scale): they hang in the air.
  - **Your time:** numbers run at real speed like your hands, so they stay readable while the world crawls.
  Either way, in slow motion numbers can be 1.2x bigger and live longer: "bullet-time numbers".
- Textured particles can ignore a level freeze (`SPF_NOTIMEFREEZE`) or not; choose per effect.

## 9. Depth, readability and comfort in a headset

- **Placement:** at the monster's top (HP Bars' measured sprite top, voxel tops included, `voxels.zs`), just
  above or beside the bar so numbers and bar read as one unit. That puts them at the monster's depth: correct
  stereo, no eye strain.
- **Never in your face:** no number closer than about 1 m (34 map units a metre, Melee's figure): a monster
  in melee range gets its number pushed back and to the side. Numbers never spawn between your eyes and your
  gun's line of aim; slide them 15-20 cm to the side of it.
- **Facing:** VisualThinkers and sprites face the camera (billboard). Keep upright (no camera roll) so they read
  when you tilt your head.
- **Limit:** at most N floaters on screen (Quest 24, PCVR 64; starting values), nearest first, reusing HP Bars'
  Nearest 24 / Distance Limit culling, so a swarm doesn't fill the view. The running total makes this mostly moot.
- **Contrast:** `+BRIGHT` and the baked dark outline. Additive style washes out on bright skies; Translucent with
  the outline (like the Melee bursts) reads better (mockups use it).
- **Your own damage taken:** no floating numbers on you by default (in VR they'd be at your face). If wanted: a
  small red "-12" on the off-hand wrist (idea 9's place) instead.

## 10. Gains on you, and the wrist (Gun Cards tie-in)

- **Pickups (top 10 #9):** +HP green, +armour blue, +ammo gold (Gun Cards' reserve colour), each spawned at the
  pickup and flying to the wrist of the hand that matters (ammo: the hand holding that gun). On arrival Gun Cards
  shows its own "+N" (already built, green); this only adds the flight. Health/armour land on the Status Card's
  wrist when it's up.
- **The tie-in contract:** don't link the mods; do it by name, as the series does (a Service). Gun Cards could
  expose "where is the wrist" (it already computes the hand pose) and HP Bars sends nothing back.
- **Watch readout (option):** check your watch and the Status Card could add DMG (this level's damage dealt) and
  BEST HIT. Gun Cards' card layout is the owner-approved v4; adding a row is Gun Cards' change, needing the
  owner's yes there. Listed, not proposed for this pack.

## 11. Top 10 #10: big moments in voxels

- One JFO voxel digit set (10 digits; Gun Cards' tool path; about 12 sprite frames for VOXELDEF), used only
  for: miniboss life lost, a champion/legendary kill, a Finisher. A large number (40-60 cm tall at 3-4 m)
  pops, tumbles once (`UseActorPitch` / `UseActorRoll`), then shatters into particles.
- At most one on screen. Rare, so its draw cost doesn't matter on Quest.
- Needs: a front-facing extrusion of the 11 JFO big glyphs (a tool, from art we own), two qualities like Gun
  Cards.

## 12. Other ideas (not in the top 10)

- **Combo-coloured numbers:** when RSQ Score's chain is running on a monster, its numbers take the Score
  family's colour (Melee, Style...). Needs Score to answer "chain on this monster" by name.
- **DPS readout:** a small "312/s" under the total while you hold the trigger on one target. Nice for Gun
  Bonsai players; noisy for others. Off by default.
- **Sound:** a soft tick per count-up step, a heavier clink for the crit tier. Needs sounds (licence check).
- **Accumulate on the hand:** damage your gun dealt since you raised it, floating by the muzzle. Probably noise.
- **Weakpoint-style criticals by aim** (hit near the sprite's top = "head"): a gameplay change, not
  presentation. Not proposed.

## 13. Quest performance (what's cheap)

- **Pool, don't spawn:** a ring of, say, 96 VisualThinkers made once (on WorldLoaded), hidden at alpha 0 on a
  non-ticking stat when free (`UpdateSector()` is required then, per `visualthinker.zs`). A hit takes the oldest
  free slots. No Spawn / Destroy churn, no GC.
- **One tick for all:** the pooled digits are moved by one handler loop, not by 96 Tick() overrides (or let them
  tick natively with Vel and only touch the ones animating).
- **Merge per monster per tic** (as damnums' tracker does), but from `WorldThingDamaged` or HP Bars' existing
  bar, not a ticking Inventory on every monster.
- **Running totals cut the count:** a chaingun burst becomes 1 total of 2-3 digits instead of 20 floaters.
- **Particles for debris only**, and not many (a shatter = 3 digits x 5 shards = 15). The particle pool
  (`r_maxparticles`, default 4000, user setting) is shared with anything else that uses particles.
- **Caps:** Quest 24 live numbers / PCVR 64 (option "Max Numbers"), and HP Bars' culling.
- **Sprite frames:** 0 for the recommended path (textures, not sprites); about 12 for the voxel big moment.
  Compare damnums as shipped: 280 for one font, 3,640 for all 13.
- **CVars:** read once a tic in the handler (HP Bars already does this for its settings), never per digit.
- **To measure on the rig before choosing:** per-tic time with 24 / 64 / 128 live VisualThinker digits vs the
  same count of damnums actors, and the frame cost of the canvas plate redraw. None of these are measured yet.

## 14. Switches (every feature has one)

Proposed menu rows (names promise only what they do):

| Row | Default (proposed) |
|---|---|
| Damage Numbers | On |
| Font | JFO / Ermac |
| Text Quality | Quest / PCVR |
| Colour By | Hit Strength / Damage Type / One Colour |
| Pop Animation | On |
| Size By Damage | On |
| Running Total | On |
| Kill Finale (slam, overkill, shatter) | On |
| Special Words (Headshot, Crit...) | On |
| Burst Behind Big Hits | On (needs RSQ Melee's art loaded, or ship our own copy, see below) |
| Slow Motion Numbers | World Time / Your Time |
| Hit-Stop Hold | On |
| Gains On You (fly to wrist) | Off |
| Big Moment 3D Numbers | On |
| Infight Numbers | Off |
| Max Numbers | 24 (Quest) |
| Number Size | 1.0 |

**Art licence note for the bursts:** kiddolink's "VFX Hit Impact" is a paid pack bought for the series and
used under its purchase licence (Melee/CREDITS.txt); reusing it from HP Bars is the same owner, but a second copy
in another pk3 should be checked against that licence (or the number asks Melee's burst classes by name when
Melee is loaded, as Gun Bonsai VR does with `RSQM.Burst`). The CvS2 sparks are a rip: same rule as Melee's.

## 15. New art each idea needs

| Idea | New art |
|---|---|
| 1 JFO tinted | none (tool: textures + translations from `card_art/jfo/big`) |
| 1 Quest/PCVR | none (half-res pass, as Gun Cards) |
| 1 Ermac font | none (`card_art/digit_*`) |
| Outline / glow | none (baked by the tool) |
| 2-4, 7, 8 | none (code) |
| 5 shatter | none (shards cut from the glyphs by the tool) |
| 6 words | none (JFO small A-Z) |
| 9 gains | none |
| 10 voxels | a tool pass: JFO big glyphs to KVX (Gun Cards' path) |
| Sounds | new sounds (not in the series yet) |

## Mockups

Rendered with PIL from the real art (`/tmp/claude-0/-home-claude/01ebc270-3953-5301-831b-c73a8b1320ca/scratchpad/dn/mock.py`):
JFO big/small glyphs, Ermac digits, kiddolink burst MLK2 / MLKH / MLK5 / MLKE, CvS2 spark MLSN, HP Bars' RQMA60 bar.
They show a look, not engine output.

- `mock1_pop.png`: the pop at tics 0-22 with burst and spark (idea 2).
- `mock2_ramp_specials.png`: the five tiers, and HEADSHOT / OVERKILL / FINISHER (ideas 1, 3, 5, 6).
- `mock3_running_total.png`: hits flying into the total beside the bar (idea 4).
- `mock4_fonts_quality.png`: JFO PCVR vs Quest, raw, Ermac, Ermac tinted, a +25 pickup (ideas 1, 9).
