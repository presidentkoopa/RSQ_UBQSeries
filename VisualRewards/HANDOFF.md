# RSQ VisualRewards (until 2026-11-03: RSQ_TopHPBars / RSQ HP Bars) -- handoff

## 2026-11-05: the owner's approved HP bar icons (11-05) -- rig only, not headset-confirmed

Done (code: bar.zs, handler.zs; art: tools/gen_art.py -> TEXTURES.rsqthp + RQK5 / RQS4 / RQS5 / RQB3 / RQB4; all under
Status Markers, no new menu row):
- **Whipped** (coiled lash, left, nearest the bar): 5th marker bit 16, sprite RSYW A..P (= the other four bits; RSYZ
  A..O unchanged). RSQ Whip's RSQTHP_MarkerWhip answers "whipped"; VisualRewards asks "hooked" of marker services with
  stringArg "whipped", which the new Whip answers 0. Old Whip + new VisualRewards: hook (as before). New Whip + old
  VisualRewards: hook (it asks hooked with ""). 16 more composed textures, drawn only when shown.
- **Ally** (blue heart) and **burning** (flame), right row: RSYF frame = s + 3 * (raised + 2 * (burning + 2 * ally)) - 1,
  A..W (A..E unchanged), laid out ally, raised, frozen/held, burning from the bar outward. Ally = friendly and not a
  player, with or without Ally Colour. Burning = fire damage (Fire / Flames / Flame / Burn / HumanBBQ) landed within
  24 tics, stamped in WorldThingDamaged, read every 4th tic. Measured from the parent code: brutal22test6 puts no lasting
  burn mark on a living monster (a fire death swaps in a Burning* body, which never gets a bar); BD22's flamethrower,
  its FlamethrowerBurningStuff and the RSQ Grenade / Gun Bonsai VR burns all deal "Fire"; RSQ FnF's flare hurts nothing,
  so it never lights the flame.
- **Legendary** (pink gem, above) and **Bossfight tier pips** (0-4 gold, right of the crown): sprite RSYI A..M, one
  43 px canvas round the crown (gem left, pips right, never overlapping). Gem = LDLegendaryMonsterTransformed (LegenDoom
  3.0 LEGENDMON.acs / MonsterStats.dec, Lite 4.2 DECORATE; never on a candidate). Tier = RSQMB_Service "tier" (new read
  key, 0..4, -1 not a Bossfight's): one pip per tier (owner 11-05, later the same day: "use 4 pips"; tier 0 the bare
  crown, tier 4 four pips); an older RSQ_Miniboss gives -1: crown only. LegenDoom is read by class name only and never
  changed (owner 11-05: "don't make any changes to legendoom, it isn't ours, and we won't always use it"); without it the
  class lookup is null and no gem is drawn.
- 4-pip update (11-05): RSYI F..I crown + 1..4 pips, J..M + gem. Proof: a TEXTURES render of every RSYI frame
  (scratchpad hpicons/rsyi_layout.png) and the BD-order no-error run (hpicons/logs/bdpips.log).

Shown (probe test only, scratchpad hpicons/probe; contact sheet hpicons/hpicons_contact_sheet.png):
- doom2 + LegenDoom 3.0 + Miniboss + Whip + VisualRewards: hook (old-Whip answer), lash, flame, heart, heart + flame,
  gems on turned legendaries, a real called-in Bossfight miniboss with gem + crown + 3 pips (RSYI K). Logged frames
  RSYW A, RSYZ A, RSYF F / L / R, RSYI C / K. New Whip: whipped 1, hooked("") 1, hooked("whipped") 0.
- BD order (doom2, lo2 01-07 with 03 = 2.0.3x, Gun Bonsai 0.10.6, every RSQ pk3): no script error but BD_VoxelPack's 4
  voxeldef lines.
Not shown: 1 and 2 tier pips in a frame (the miniboss's bar only rose after it turned legendary), any icon on a Brutal
Doom monster (XMVE's ImpSpawner swallowed the probe's row; the BD miniboss stayed invulnerable to the probe), the flame
from BD22's flamethrower itself (fire damage was dealt by the probe).

## 2026-11-03 (night): the merge -- RSQ VisualRewards = HP bars + damage numbers + level-ups + Kill Rewards -- read first

Rig only, not headset-confirmed. NEXT_PLAN_2026-11-03.md section 1, the owner's name (11-03 18:38-18:43).

Done (measured on the QZD 17.3 rig, doom2.wad; probe `tools/rigprobe/zscript_vr.txt` + `run_vr.sh`, test only; key lines
in `test/evidence/merge_*.txt`):
- Folder `TopHPBars/` -> `VisualRewards/` (git mv, history kept); pk3 `pk3/RSQ_VisualRewards.pk3` (build target
  `VisualRewards` in tools/build_all.py and build_all.sh); `pk3/RSQ_HPBars.pk3` removed.
- Kill Rewards moved in from GunBonsaiOffhandVR: `zscript/rsqvr/killrewards.zs` (RSQ_KRHandler, RSQ_KRHealthBit /
  ArmorBit / AmmoBit, unchanged names), `sprites/rsqkr` (KRBH / KRBA / KRBM), every `rsqgb_kr_*` cvar (same names),
  its menu page `RSQ_KillRewards` and LANGUAGE strings (same ids), SoM in CREDITS. Gun Bonsai VR keeps the four path
  node classes (`rsq/zscript/up_killrewards.zs`).
- Links, all by name: Kill Rewards reads the nodes (`RSQ_MeleeUpgradeService` "plevel"), asks Gun Bonsai VR "kr.lucky"
  (GetString) / "kr.luckyfx" for Lucky Kill and "level" "Scavenger" for the grenade bit; Gun Bonsai VR offers the nodes
  only while `RSQVR_Service` "kr.loaded" == 1 (`zscript/rsqvr/service.zs`: loaded, kr.loaded, kr.on, kr.perk, helper,
  GetDouble kr.magnet). Miniboss's "bossfor rewards" hook and Whip's "RSQ_KR*" skip work unchanged (same names).
- One Brutal Doom helper list (`zscript/rsqvr/helpers.zs`: HeadHitbox family, boot smearers, NewCybersHitBox, the
  1000+ hp -COUNTKILL rider rule) used by the bars (new: they skipped none before), the numbers and the bits.
- Menu: Radiant Silvergun Options -> RSQ VisualRewards (page still named RSQTHP_Options so every pk3's menu order
  knows it) -> HP Bars / Damage Numbers / Level-Up Displays / Kill Rewards / Tuning and Debug, one Reset All
  (`rsqthp_reset`, now also every `rsqgb_kr_*`: 71 cvars, checked against CVARINFO). menutool.py check: OK.
- **Bug found and fixed** (in the old Gun Bonsai VR pk3 too, `old_gbnodes`): a bit already picked up (no longer SPECIAL)
  inside Magnet's reach was touched again -> VM abort "tried to write to address zero" in AddInventory. BitTick now
  skips a bit that is owned or not SPECIAL.
- Proof: VisualRewards alone: imp 6 rolled / 3 dropped, Cyberdemon 1200 / 1200, on the floor (z - floorz 0), all drawn,
  gone 7 s after (`vr_alone_kr`); bars 2, a hit, a total, banner and tag (`vr_alone_dn`). Full order (03 = 2.0.3q, GB,
  all RSQ): first run a TheCyberdemon (5000) burst 1500 / 1500, its NewCybersHitBox died with no bits (helper 1), an
  imp (80) 8 / 6; the evidence run (XMVE picked Thamuz, 3800: 1140) also shows Dying_Headshot and BootSmearerGreen
  with no bits; HEADSHOT 1, totals, kills, banner 1, tag 1, bits vanish at 7 s (`vr_full`). Miniboss "Boss Kill
  Rewards": imp 18 / 18 (x3, all drop), off 6 rolled -- with and without Gun Bonsai (`vr_mb_rewards*`). Gun Bonsai VR
  nodes (fistsprobe, a scratch copy minus 4 stale TacticalRig lines): Bit Scavenger 1 -> 8 rolled for an imp, Rich Bits
  1 -> health +50 / armour +20, Magnet 1 -> 2.0 m, Lucky Kill 1 + a crit -> "5 more bits, x2", grenade Scavenger 3 ->
  20 ammo bits gave 8 grenades (`vr_gbnodes`). Gun Bonsai VR alone: RSQVR_Service absent, Add All added 154 node
  levels and none of the four, an imp kill made no bits (`vr_gb_alone`). Old ini + old save: values set under the old
  pk3s (rsqgb_kr_chance 77, _boss 5, _life 30, rsqthp_scheme 6, rsqthp_dn_size 1.5) read back under the new ones; the
  old save loaded with its 5 bits still on the floor and Kill Rewards working after (`vr_old_save`, `vr_new_load`).
- Script errors from our packs: 0 in every run above (doom2 + VisualRewards alone; doom2 + GB + Gun Bonsai VR alone;
  doom2 + GB + all RSQ; the full order: only BD_VoxelPack's 4 voxeldef lines).

Not done / open:
- Headset: all of it. Frames of the bits were not captured this round (the census reads position, SPECIAL and sprite).
- Brutal Doom's dying bodies (e.g. DyingShotgunguyHitInEye, -COUNTKILL, 40 hp) still roll Kill Rewards when finished
  off (as before the merge); the plan leaves adding them to the helper list to the owner.
- The menus wait for the owner's redesign.


## 2026-11-03 (evening): the owner's approved design (mockups 18:05-18:12) + his headset reports (18:28-18:36) -- read first

Rig only, not headset-confirmed. Probe `tools/rigprobe/zscript_dn3.txt` + `run_dn3.sh` (test only; adds `dn3_lvl
"tic:kind:level"`, which sends Gun Bonsai's own `bonsai-level-up` event, and logs each number's first glyph: Pos, Prev,
world height and degrees). Evidence: `test/evidence/dn3_*`.

Done (measured):
- **THE SEIZURE, found and fixed** (owner 18:28 "why are all of my damnums having a seizure?"). glyphs.zs `Put(Vector3 p,
  Vector3 prev) { Prev = prev; ...}`: ZScript names are case-insensitive, the parameter hid the field and Prev was never
  written. The renderer draws a VisualThinker at Prev + ticFrac * (Pos - Prev); Prev stayed at the spawn point, so every
  frame (72-90 Hz) each number was drawn somewhere between where it was born and where it is. Rig log before: Prev stuck
  at the spawn spot for the number's life, a total's Prev 4.4 units off its Pos every tic; after: Prev = last tic's Pos,
  monotonic (`dn3_seizure_before.txt`, `dn3_motion_one_number_log.txt`). Also: colour steps at least 4 tics (8 with
  Photosensitive Mode), close shades, no flash in any cycle; the aim-line slide eased 0.12 with a 0.75-unit dead band
  (hand tremor no longer moves numbers); each glyph a hair behind the one before (no translucent sort flips); JFO advance
  0.92 (no overlap); Most Numbers cut has 24 units of give (no blinking at the edge); the combo shake is a smooth wobble.
- **Sizes** (18:28-18:29 "fuckin huge", "super tiny stuff", "the text is also really, really damn big"): hit digits 2.5
  map units at Number Size 1 (7 cm; 1.4 deg at 3 m, 0.53 at 8 m, 0.21 at 20 m), never more than 1.8 deg however near; no
  growth with range (Grow with Distance now off); words 0.42 of a digit at Word Size 1; total 1.2x a hit; the combo a word.
  New sliders Number Size, Word Size. Gains at the wrist: never more than 2.5 deg (the rig measured 2.50 deg on landing,
  `dn3_gain_log.txt`), smaller than RSQ Gun Cards' card digits beside it (`dn3_gain_vs_guncards_sheet.png`, world cards,
  hands posed out with qz_rhand / qz_lhand). The weapon tag uses Gun Cards' sizes (name 0.78, LV 1.56 units).
- **Normal hit = a little fountain jet** (18:36): appears at the inflictor (a bullet's puff, a missile's spot; real
  LineAttack bullets on the rig spawned it at the puff), launched up and out (random +-80 deg around your side, varied
  speed), gravity over the top, spins at its own random speed (70 % 0.5-3.5 deg/tic, 30 % 7-18, either way; the whole
  number turns: glyphs rolled and their columns turned, placed in the world so they interpolate), gone at 0.63 s
  (`dn3_jets_spin_sheet.png`, `dn3_motion_one_number_log.txt`). Calm: one colour, no flash.
- **Headshot**: the only number with the Castlevania life (white flash 2-3 tics, slow gold/white shimmer, letters bobbing,
  a jolt, 1.35x) (`dn3_headshot_sheet.png`: HEADSHOT 28 on a shotgun guy; HEADSHOT OVERKILL 60 on an imp). A killing head
  hit stands at the monster's standing height (death frames are short).
- **Total and combo**: total centred above the bar (rolls up, small bounce), xN beside the bar, colour steps
  white/yellow/orange/red (x1-2, x3-4, x5, x6+), grow to x5, wobble from x5, drain then fade over Score's 105-tic window;
  the kill punches once with OVERKILL above and fades (`dn3_spray_total_combo_kill.png`: 1000 x24 OVERKILL). Under a low
  ceiling the total goes beside the bar (mode 1), a wall on the combo's side (or a wall between your eyes and that spot)
  moves the combo to the other side (`dn3_room_log.txt`: mode 1 in MAP01 sector 28, mode 2 / side -1 in sector 52).
- **Clear of Walls** for jets: the spot pulled out of walls, lowered under the ceiling, the launch shortened so the top stays
  under the ceiling and both legs of the path miss walls (`clamped` counter). Frames of a jet meeting a ceiling were NOT
  captured (the rig's teleports into MAP01's low sectors faced walls); `dn3_corridor_wall_sheet.png` is the corridor case.
- **Player level-up**: band + scroll, measured x of LEVEL UP per frame 538 -> 304 (readable middle, about 7 frames) -> 8,
  monotonic (`dn3_levelup_scroll_sheet.png`, `dn3_banner_log.txt`). World-anchored 64 units along your gaze (nearer if a
  wall is), lazily following; real tics (a slow-mo pulse never drags it out).
- **Weapon level-up**: tag at the gun, name typed with flashes, LV n one punch, NEW UPGRADE green flicker, border one
  colour (`dn3_weapon_tag_and_gain_sheet.png`). Never nearer the eyes than 22 units.
- **HP bars**: Colours 6 Cyan Lavender Orange, 7 Random, by translation of coldcite's Classic frames (0 new sprite frames)
  (`dn3_bars_cyan_lavender_orange.png`: 90 % cyan, 55 % lavender, 25 % orange). Random everywhere: `dn3_random_colours_sheet.png`.
- Rows added: Hit Colours (replaces Colour by Hit Strength), Combo Counter, Number Size, Word Size, Headshot Flash, Headshot
  Cycling, Combo Shake, Clear of Walls, Total Colours, Combo Colours, Headshot Colour, Player Level-Up, Level-Up Slow-Mo,
  Level-Up Band Colour, Level-Up Text Colour, Weapon Level-Up, Weapon Tag Border; all in Reset All.
- Script errors: see the commit message (doom2 + HP Bars, doom2 + Gun Bonsai + all RSQ, full order with 03 = 2.0.3q; save,
  two loads, map change, both bonsai-level-up events sent with `netevent`).

Not done / open:
- Headset: everything above. Gun Bonsai's real level-ups were not played to on the rig (the event was sent by the probe and
  by `netevent`, exactly as Gun Bonsai's Fanfare sends it).
- Level-Up Slow-Mo (rsm_pulse 500 30) not run with RSQ SlowMo on the rig.
- CRIT: hook only.

## 2026-11-03 (afternoon): the owner's damage-number round -- read first

Rig only, not headset-confirmed. Owner: "I love all of this, let's get on it"; "I like the numbers but not the
sprites behind them"; "we don't use backstab at all, but I love the headshot and crit idea" (crits after 2.0).
Rig: tools/rig17/run17.sh (real QZD 17.3), doom2.wad; probe `tools/rigprobe/zscript_dn2.txt` + `run_dn2.sh` (test
only: scripted spawns, hits, real bullets, hit-stops, pickups, RSQ SlowMo's netevent; logs every number every tic).
Evidence: `test/evidence/dn2_*` (frames as contact sheets, logs). Most runs teleport to MAP01's outdoor yard
(-860, 250) so nothing is cut by walls.

Done (measured):
- **Drawing rewritten:** no digit actors and no sprites. Each glyph is a VisualThinker (glyphs.zs) holding a texture
  from graphics/rsqthpdn (tools/gen_dn_art.py: 132 PNGs), on a non-ticking statnum, placed by one post-actor driver
  thinker (statnum 125). One pool, 160 glyphs at most. **Sprite frames added: 0** (the pk3 has 655, all bars; the
  morning's fold had 1,215: damnums' 560 are gone). Numbers survive a save and two loads (totals kept counting after
  each load, e_* logs) and a map change (numbers on MAP01 and MAP02, m_* logs).
- Bug found on the rig and fixed: a number at the monster's head stood in its sprite's plane and was hidden by the
  sprite (first font run: the 123 inside the Baron). A hit's number now stands at the top of the head, radius + 6 in
  front of the monster toward your eyes.
- Bug found and fixed: gen_art.py clears graphics/rsqthp, so the glyphs live in their own folder (graphics/rsqthpdn);
  build.sh runs gen_dn_art.py too.
- **Fonts:** JFO Metal (default), Ermac, Classic Doom, Classic Doom (small); Text Quality Quest (32 px digits) / PCVR
  (64 px). Frame `dn2_fonts_quest_vs_pcvr.png` (600 px eye, a 123 held by a hit-stop): all four fonts draw; at the
  rig's resolution Quest and PCVR differ only slightly (judge in the headset).
- **Ramp + size:** Barons hit for 30 / 100 / 250 / 500 (3 / 10 / 25 / 50 %): white 30 (scale 0.78), yellow 100
  (0.88), orange 250 (1.09), red 500 (1.28) (`dn2_ramp_white_yellow_orange_red.png`, `dn2_p_ramp.txt`).
- **Pop:** an imp hit for 14: scale 0.37 (t21) -> 1.55 (t22) -> 1.20 -> 1.07 (t24, settled), drifts up, fades from
  0.5 s, gone at 0.9 s (`dn2_p_pop.txt`, `dn2_pop_sheet.png`). Single-tic frames of the pop could not be had: the
  rig renders ~1 frame per 2 tics and stalls at very low i_timescale; the log carries the curve.
- **Running total:** a Baron chaingunned 9 every 3 tics: from the 2nd hit one total beside its bar, hits fly in,
  "151 x17" counting up, orange by share (`dn2_total_xN_kill_overkill_sheet.png`, `dn2_total_xN_and_slam_zoom.png`).
- **Kill + OVERKILL:** the kill 600 past zero: the total slams to "1000 x16" (180 hits + 820 it had left; the real
  health taken), OVERKILL over it, holds 12 tics, breaks apart and fades (same sheet). An imp killed 80 past zero (no
  total): "60 OVERKILL". No sprite behind any number.
- **HEADSHOT:** the exact signal, read from brutal22test6: a bullet's blood (Blood_*, BloodTypesMonsters.dec) landing
  more than 46 above the floor runs ACS "Head_Shot" -> Thing_Damage2(0, 30, "Head") on the monster the same tic; head
  hitboxes pass theirs with A_DamageMaster(.., "head"). Full order, real LineAttack bullets at a RifleZombie and a
  ShotgunGuy1's heads: 6 + 30 Head + ..., killed: "HEADSHOT 40" crimson, bigger, slams and breaks
  (`dn2_headshot_fullorder_sheet.png`, `dn2_p_head.txt`). Two kills 60 units apart overlap their slams.
- **Out of your face:** the main hand aimed through a number: slid 4.7 -> 13.6 units off the aim line (comfort on),
  0.0 (off) (`dn2_p_aim1.txt` / `dn2_p_aim0.txt`). MIN_EYE (36) never had to act in these tests (an imp 30 units
  away put its number 50 from the eyes).
- **Most Numbers / busy room:** 40 Barons, each hit every 4 tics: 130 numbers alive, 12 shown (default), 33 glyphs in
  the pool, 0 stolen; at 48: 48 shown, 109 glyphs. Actors 129 with numbers on, 129 with them off (no actor is added);
  monsters 59 alive, 40 HP bars (`dn2_p_busy*.txt`). A number beyond the cut gives its glyphs back to the pool.
- **Gains:** health 50, stimpack +10 green, clip +10 gold, armour bonus +1 blue: rise from the pickup, fly to the
  wrist (ammo to the main hand, the rest to the off hand) and shrink to ~7 cm (`dn2_gains_to_wrist_sheet.png`,
  `dn2_p_gain.txt`; plain doom2 draws no hands on the rig, so the wrist is where AttackPos / OffhandPos are). With
  RSQ_GunCards loaded the ammo gain fades into the wrist in 4 tics instead of holding 20 (`dn2_gain_guncards_sheet.png`).
- **Hit-stop:** two imps hit at t20, the left one held 25 tics: it stands at 0.96 to t44, pops 1.55 at t45, settles
  1.07; the other popped at once (`dn2_p_stop.txt`, `dn2_hitstop_sheet.png`).
- **SlowMo:** RSQ_SlowMo on (netevent rsm_on): World Time clock 0.25 a tic (2.25 at 9 tics), Your Time 1 a tic
  (`dn2_p_slow_w.txt`, `dn2_p_slow_y.txt`, `dn2_slowmo_world_sheet.png`).
- **Rows** (14 new, all in Reset All): Text Quality, Colour by Hit Strength, Pop and Settle, Size by Hit, Grow with
  Distance, Running Total, Kill Slam, Overkill Word, Headshot Word, Out of Your Face, Most Numbers, Gains on You,
  Freeze in Hit-Stop, Numbers in Slow-Mo; Number Font now JFO Metal / Ermac / Classic Doom / Classic Doom (small).
- **Script errors** (save, two loads; separate map-change runs): doom2 + HP Bars 0; doom2 + Gun Bonsai 0.10.6 + all 18
  RSQ pk3s 0; full order (lo2 01, 02, 03 = 2.0.3p, 04-07, Gun Bonsai, all RSQ) 4, all BD_VoxelPack's voxeldef.

Not done / open:
- Headset: readability and size of the metal digits, Quest vs PCVR, the pop's feel, the wrist landing.
- Gun Cards landing exactly on its +N needs a Gun Cards Service (card world position per hand, +N showing); not
  asked of Gun Cards, not edited. README "Next".
- Next (README): CRIT word / magenta (hook in: RSQTHP_DnService "crit"), Score payout names and move colours (need
  Score answers by name), 3D voxel numbers. No backstab.
- Totals beside a bar near a wall can be hidden by the wall (seen in the MAP01 corridor).
- The owner restored every README at 12:07 (b11da6d86); the Damage Numbers rows and steps were added to that
  restored README, nothing else in it changed.


Rig: rig A (`/home/claude/scratch/run17A.sh`, the real QZD 17.3 binary, zscript 4.14.2), doom2.wad MAP01.
Every number below was measured there; the logs and frames are under `test/evidence/` (copies) and
the scratchpad (`frames/<run>/`, `logsA/<run>.log`). Test runner: `test/run.sh <name> <secs> "<console>" <order>`.

## 2026-11-03: Damage Numbers (damnums folded in, the 9999 fixed) -- read first

Rig only, not headset-confirmed. Owner: fold Xaser Acheron's damnums (MIT, github.com/XaserAcheron/damnums v1.0.2,
953673c) into HP Bars; "with brutal doom, when we kill a monster its corpse falls to the ground and i see a 9999 every
single time". Rig: tools/rig17/run17.sh (real QZD 17.3), doom2.wad MAP01, probe `tools/rigprobe/zscript_dn.txt` +
`run_dn.sh` (test only): spawns monsters one at a time, kills them with traced 20-damage hits (head hitboxes get hit
too), logs every number with what it stood on, every ISMONSTER death. Evidence: `test/evidence/dmgnum_*`.

The 9999, measured (full order: lo2 01, 02, 03 = BD22_VR-Reloaded 2.0.3p, 04-07, Gun Bonsai 0.10.6, every RSQ pk3, the
old HP Bars, damnums; 32 BD monsters killed): damnums put its tracker on every ISMONSTER actor. Brutal Doom's
HeadHitbox family (Head_Sys.dec: Health 9999, +ISMONSTER -COUNTKILL, A_Warp onto its master) calls A_Die when the body
under it stops being shootable -- the kill, a dying/slumped body (DyingImp, ZombiemanLastStand2 ...) dropping. damnums
then showed its whole 9999. 15 numbers of 9999 in 30 kills, each the same tic as a helper's death "by None":
Dying_Headshot, SlumpedZMan_Headshot, Baron_/Knight_NobleHeadshot, MancuHeadshot, BonesHeadshot, NewCybersHitBox.
Also 14 numbers of 1000 from BootSmearerRed (blood smear, ISMONSTER, 1000 hp) dying, and overkills showed the whole
hit (imp on 10 hit for 25: 25). After (same run, new HP Bars, no damnums): 195 numbers, 0 of 9999, 0 on any helper or
smearer (`dmgnum_dn_before_full.txt` / `dmgnum_dn_after_full.txt`, DNP_SUM / DNP_BIG lines). Overkill, doom2: imp on 10
hit for 25 shows 10 (damnums 25); zombieman 20 hp one-shot for 25 shows 20 (`dmgnum_dn_over_*.txt`).

Done (measured):
- zscript/rsqthp/damnums/: damnums' DamNum (digits, physics, fade, statnum 88) and fonts kept as shipped, renamed
  RSQTHP_DamNum*, driven by WorldThingDamaged (RSQTHP_DamNumHandler; no item on every monster, font read from defaults,
  no font actor per number). Sum per target per tic like damnums' tracker, spawned next tic; Shotgun Spray per hit.
  Skipped: HeadHitbox descendants + BootSmearer* + NewCybersHitBox by name, ISMONSTER -COUNTKILL 1000+ hp with a master
  or NEVERTARGET, player bodies, hits on things already dead, Massacre / KillMe, a -COUNTKILL body ending itself with no
  source and no inflictor. Number = min(damage, health it had left).
- Only damnums' Doom Classic (default) and Doom Small fonts: 560 sprite frames (QC / QD; all 13 fonts would be 3,640).
  Sprites, TEXTURES.rsqthpdn, TRNSLATE.rsqthp (RSQTHP_Dam*), LANGUAGE.rsqthp (RSQTHP_DMG_TYPECOLOR_*, damnums'
  DAMNUM_TYPECOLOR_* also read). Names checked against every pk3 in the full order + doom2.wad: no clash.
- Menu rows (frame `dmgnum_menu_rows.png`): Damage Numbers, Numbers For, Shotgun Spray, Number Font, Number Colour,
  Number Motion, Damage Type Colours; all in Reset All (log `dmgnum_dn_reset.txt`: every row back to default).
- Frames: doom2 (`dmgnum_doom2_numbers.png`), full order (`dmgnum_fullorder_numbers.png`), damnums also loaded =
  two numbers per hit (`dmgnum_with_damnums_double.png`: ours cyan, damnums red 25 on the kill where ours says 10).
- Damage Numbers Off: 0 numbers for 2 kills.
- Script errors: doom2 + HP Bars 0; doom2 + Gun Bonsai + all RSQ pk3s 0; full order 4 (BD_VoxelPack voxeldef only).

Not done / open: headset check (size and readability of the digits in VR, toss toward the console player's body).
VisualThinker could draw digits with no sprite frames; not tried (unproven on the rig). On the rig the HP bars
themselves did not show in these frames with the old pk3 either (same view), so no bar change is claimed either way.

## 2026-11-02: LegenDoom candidates no longer give themselves away -- read first

Owner: "they show on legendary boosted champions before they turn, so they give themselves away." Cause (rig,
real LegenDoom Lite 4.2): LegenDoom gives a picked monster LDLegendaryMonsterToken and sets 300 % health at once,
no damage; the 16-tic poll took that for an overheal, so an unhurt candidate got a full bar with the overheal
strip (180/60 at t20; a plain imp: none). Fix (handler.zs FullOf / LDCandidate, bar.zs): token and not yet
LDLegendaryMonsterTransformed (both by name) -> drawn against its most health since picked; length by spawn
health. Rig after, LDL 4.2, LD 3.0 and Champions dormant + booster + LDL: candidates no bar until hit, then
160/180 plain (no strip, length x1.00 like the plain imp); on the turn at half health: 180/60 full strip
(LDL) or Champions' own 225/225 (dormant mode). Without LegenDoom: unchanged. `test/ld.sh` (+ `test/ldprobe/`).
Not headset-confirmed. The "Overheal, LegenDoom Lite" lines below are the old behaviour (bars on untouched
legendaries), kept as history.

## QoL round 2026-10-31 (owner's picks HP1-HP4 options, HP6-HP9 on) -- read first

Rig only, not headset-confirmed. QZD 17.3 rig, doom2 -> brutal22test6 -> BD_VoxelPack -> BD22_VR-Reloaded 2.0.3h ->
hotfix -> RSQ_HPBars -> probe (`tools/rigprobe/zscript_qol.txt`, `PROBE=qol tools/rigprobe/run.sh`, test only).
With every series pk3 loaded: no script error but BD_VoxelPack's voxeldef lines.

Done (measured):
- **HP6 length by toughness** (on): stretch 1 + 0.15 x log2(spawn health / 60), 0.7..2.0. BD's spawn health, logged:
  RifleZombie 40 -> 0.91, imp 80 -> 1.06, BaronofHell2 1200 -> 1.65, TheSpiderMastermind 4000 -> 1.91,
  TheCyberdemon 5000 -> 1.96 (widest). The icons beside the bar move out with its ends.
- **HP7 hit flash** (on): one tic as a white stencil after a player's hit (log: flash 1 at t40, t45, t50 for hits at
  those tics, never the tic after). Photosensitive Mode (RSQ_Accessibility, rsqa_photosafe 1): hits at t40..t60
  every 5 tics flash only at t40 and t55 (14-tic gap), alpha 0.36 (40 %). Frame: the flash tic is a grey-white bar.
- **HP8 raised** (on, with Markers): an Arch-Vile (BD's TehArchvile, its own A_VileChase) raised a stock imp at t37
  (WorldThingRevived, the vile in its Heal state); the imp got its bar at once with the arrow (status frame C).
  Frame: purple up arrow right of the bar. Brutal Doom's own imp leaves a separate DeadImp corpse actor on the
  spot; on the rig the vile did not raise that one (not ours to change).
- **HP9 fade in** (on): alpha 0.17 -> 1.0 over 6 tics on a new bar (and on one shown again).
- **HP1 Damage Chunk** (option): what the hit took off stays white 17 tics, drains over 10 (log: last hit t50, full
  to t67, gone by t77; hits while lit add up). Frame: white block right of the remaining fill, on its pixels.
- **HP2 Ally Colour** (option): a FRIENDLY imp's bar uses the blue set RSYG (coldcite's Red, R and B swapped). Frame.
- **HP3 Nearest 24** (option): 30 hurt imps -> 24 visible (culled every 4th tic); off -> 30.
- **HP4 Distance Limit** (option, Limit Distance slider in Tuning, 1536 default): at 600, 12 of 30 visible.
- All four options have a menu row and are in Reset All (KEYCONF rsqthp_reset).

Not done / open: "your own shot" is any player's shot (single-player VR: yours). The flash, the chunk and the
culling read the console player's camera like the rest of the bars (render-side visibility).

## Sweep 2026-10-31 (owner's picks 35, 36, 37)

Rig only, not headset-confirmed. QZD 17.3 rig, doom2 -> brutal22test6 -> BD_VoxelPack -> BD22_VR-Reloaded 2.0.3h
-> hotfix -> (RSQ_DistanceGrab) -> RSQ_HPBars -> probe (`tools/rigprobe/run.sh`, test only). No script error
but BD_VoxelPack's voxeldef lines.

Done (measured):
- **Frozen** (pick 36, on with Markers; teardown 01_MELEE 3.6, 10_TIME): a snowflake right of the bar while the
  monster's freezetics counts down. Log: a 5-tic hit-stop at t60 -> icon A at t61-63, gone at t64.
- **Held** (pick 37; apply/04 1): a padlock while RSQ DistanceGrab's Headlock holds it (the real mod, its own
  `rsqdg_ngrip` netevent): freezetics stands at 1 and NOGRAVITY/FORCEINFIGHTING are borrowed -> icon B from
  t94 to t160 (grip released at t160), and no wrong icon on the first tic. Frame: padlock right of the bar
  (`icons` run). Read from the monster only; nothing links to DistanceGrab.
- **Aimed Only** (pick 35, option off, menu row, in Reset All): a bar only on what either hand's gun points
  at, plus 18 tics. Log: unhurt imp aimed -> bar; aim moved away -> bar gone within 30 tics; three hurt imps,
  one aimed -> one bar shown, two hidden; option off -> all three shown.
- Bug found and fixed on the rig while building it: the first status-icon art used a negative x offset
  (`Offset -29, 7`) and drew nothing (frame `heldpic`); now a 38-wide sprite from the bar's centre (frame `icons`).

Not done / open: the frozen/held icons need a bar, so an unhurt monster shows neither. No existing bug was
found in the old code on the rig (a raise-while-polled duplicate was suspected and could not happen: a corpse
cannot be raised before the 1/16 poll drops it).

## Branch `agent-polish` (2026-10-27, independent review items) -- read first

Not yet run on the owner's headset. Rig B (QZD 17.3 Linux), probe in the session scratchpad
`pol/thpprobe` (a two-map hub cluster over doom2 MAP01/MAP02, a voodoo doll made by giving a second
DoomPlayer body `player = players[0]`).
- **No bar on voodoo dolls**: `Eligible()` takes a player-class actor only when it is its player's own
  `mo`. Measured: a doll damaged for 5 had 1 bar before, 0 now; the player it passes the hit to still
  gets its bar (1).
- **Hub maps come back tracked**: on `WorldLoaded` with `IsReopen` the level's live monsters (and the
  players) are walked once into the poll list (WorldUnloaded cleared it, and hub monsters come back from
  the snapshot without WorldThingSpawned). Measured: MAP01 -> MAP02 -> MAP01 in a hub, an imp then set to
  3 x spawn health without damage (a legendary's way): overheal bar after 40 tics 0 before, 1 now.
  A saved game was already fine (the list is saved with the handler).
- RSQ_Accessibility's shared menu now has the HP Bars section (its branch `agent-polish`): the open
  item below is done there.
- Full order (doom2 -> brutal22test6 -> BD_VoxelPack -> BD22Q r7 -> Champions -> LegenDoom Lite -> suite
  -> Gun Bonsai + patch), save, load twice, map change: see the polish lane's smoke run in
  RSQ_Accessibility's README / the report (no script error but BD_VoxelPack's voxeldef lines).

## Branch `agent-compat` (2026-10-27): Champions + LegenDoom Lite -- read first

Not yet run on the owner's headset. Rig C = QZD 17.3 Linux, doom2 MAP01, the owner's order (brutal22test6 ->
BD_VoxelPack -> BD22_VR-Reloaded r7 -> Champions -> LegenDoom Lite 4.2 -> suite -> Gun Bonsai 0.10.6 + VR patch)
and vanilla doom2 + Champions + LegenDoom Lite + suite; Champions' setting champion_Legendoom 1,
champion_Dormant 1, champion_Booster 1. Probe: the session scratchpad cp/probe (forces tiers through
champion_debug_forced / champion_OverrideChance 256, legendaries through LDLegendaryMonsterPickupGuaranteed).
Save, load twice, MAP02: no script error but BD_VoxelPack's voxeldef lines.

- WearsChampIcon: in Champions' dormant LegenDoom mode EVERY champion is dormant until transformed, not only
  the legendary ones (handler.txt passes ld_dormant to the plain roll too). Measured: two dormant Gold imps
  that LegenDoom never picked reported icon 1 (bar lifted over nothing); now 0; the transformed one 1.

## Done (measured)
- **Compiles and runs clean**: shipped pk3 alone (g0), vanilla + probe (g1), Champions + LegenDoom Lite
  (g3), the owner's full order doom2 -> brutal22test6 -> BD_VoxelPack -> BD22_VR-Reloaded r7 -> Champions ->
  LegenDoom Lite 4.2 -> the 8 suite pk3s -> ours -> damnums (g2). Each: save, load, load again, map
  change. Only script errors in any log: BD_VoxelPack's own `voxeldef.txt` lines 66/72/77/892. (Warnings
  that are not ours: BD's ForceDamageEventScripts / Deh_Actor_153, LegenDoom Lite's guncaster/DRLA compat.)
  Bars survive both loads (g2: 7 bars before, 7 after each load), MAP02 starts clean and gets its own.
- **Default look = coldcite's**: Classic/Red are his PNGs byte for byte; same 112x11 art, 5 % steps, ghost
  half-steps, offset 56,11, scale 0.3, 10 % height offset (log: imp bar 62.70 above feet = 57 x 1.1).
- **Colour sets** (frames `test/evidence/schemes_v5.png`, art `art_sets.png`): worst CIE76 dE between bands
  under the set's own simulation (Machado 2009): ProDeutan 33.6, Tritan 48.1, High Contrast 21.8 (high vs
  overheal strip, which sits apart). Classic under deuteranopia: high-low dE 5.2 (why the sets exist).
  Non-colour cues: low band hatched + pulse (alpha 1.0/0.6, 25 tics each, 1.4 Hz), mid band centre line,
  HC white rim, dark backing, always bright. `cvd_check.txt`.
- **rsqa_colorblind** (stub pk3 with the real cvar's name/type, server int): 1->Protanopia, 2->Deuteranopia,
  3->Tritanopia, 4->High Contrast, 0 -> own setting (`rsqa_override_cb1.txt`).
- **Overheal, LegenDoom Lite**: LDL alone, forced legendaries = 180/60 (StartHealth 0) -> full bar + full
  strip + 1 pip (RS11T); drained by 30 hp hits: RS11J, RS10T, RS10J, strip gone at 60/60, yellow band at
  30/60, removed at death (`ldl_overheal_ld2.png`, `ld2_bars.txt`). Owner's combo (Champions legendoom +
  dormant + booster, LD_diemode for the census): 19/19 natural legendaries at 300 % got a bar with the strip
  without being touched (`own1_census.txt`).
- **Placement**: after every actor has ticked (a statnum-120 thinker), bar-to-thing offset in the plane and
  the Prev mismatch were 0.0000 on every tic, including RSQ_Grapple's real yank (RSQGR_Flight.Launch, flip
  tumble) at 21.9 units/tic and in the full order at 17.4 units/tic (`yank1_sync.txt`, `fullorder_g2.txt`,
  frames `tumble_yank2.png`). During roll/pitch the standing height is held.
- **Voxels**: a test VOXELDEF drawing the imp's frames as a 64-tall KVX (pivot 64): bar top 64.00 (sprite
  would be 57), 70.40 above the feet; held through a pitch tumble (`voxel_top_vox1.*`).
- **Champions icon**: bars over a champion wearing its icon are lifted above it (77.0 = 56 x 1.1 + 14.4 + 1);
  dormant legendary champions (no icon yet) are not lifted (`champions_ldl_own1.png`).
- **coldcite's pk3 loaded first**: 0 of his bars, 0 of his items at every log tic, ours drawn (`coldcite_takeover_cold1.txt`).
- **damnums** (built from github.com/XaserAcheron/damnums for the test only): loads with the full order, no
  errors; its numbers spawn at head height (Height-16), under the bar (`fullorder_damnums_g2.png`).
- **Cost** (rig desktop CPU, VM): 170 bars + 224 tracked monsters: 1.36 us per bar per tic steady, 1.98 us
  when the frame is rebuilt, handler 2.76 us per tic. coldcite's 1.04 on the same scene: 8.36 us per bar per
  tic + 0.115 us per monster per tic for his ticking item (224 items). About 235 us vs 1447 us a tic (`cost.txt`).
  (His bench calls Tick, ours Update: ours excludes one VM dispatch per bar.)

## Not done / needs the headset
- Readability in the headset: coldcite's size 0.3 is ~1 m x 0.1 m in VR; Far Size (x2 at 1024 units) is on
  by default. Thin 1 px rims alias at the rig's 400-600 px eye (HC rim breaks up); judge at Quest resolution.
- The low-band pulse (comfort / photosensitivity), marker icon legibility at 2x, billboard slant at the
  edges of the view.
- Cheello's Voxel Doom II itself is not on this machine: voxel tops were proven with a synthetic VOXELDEF.
  Models (ModelSwapper) are not measurable from ZScript: those use the sprite.

## Round 2 (2026-10-27): markers on real data
- Bar side (handler.zs MarkersOf): RSQGR_Service hooked = "hooked" 0..3 tics or "yanked" 1/2; stunned =
  "stunned" == 1; SSQ_ScoreService "locked" == 1; UBQS_SaberService "gripped" == 1 (README table).
- Added, additive, each on branch agent-thp in its own worktree (not pushed, not merged):
  - RSQ_Grapple (`/home/claude/work/RSQGR_thp`, e01ffb1 + 42de5f5): service.zs "stunned" -- the yank's
    landing hold (rsqgr_yank_stun tics from the tic its throw ended) or the whip's crack within 35 tics
    while in Pain. Existing answers unchanged.
  - RSQ_ShieldSaw (`/home/claude/work/rs_shieldsawq_thp`, bd04648): score.zs "locked".
  - RSQ_Saber (`/home/claude/work/rs_questsaber_thp`, 3e14b3c): UBQS_SaberService "gripped".
- Proven with the real mods driven by their real inputs on rig A (ssq_draw + ssq-lock, the grapple's
  own throw, `event rsqgr_press`, the dual saber's off-hand alt attack held still): see the round-2
  evidence (`test/evidence/markers_*`), vanilla and the owner's full order, save/load twice, map change.
- Stun is short by design (8 tics default) and the bar polls every 4 tics: the icon can trail by up to 4.
- Gun Bonsai patch's RSQ_Dazed (stagger / down) is not readable by name: RSQ_MeleeUpgradeService has no
  request for it. Adding e.g. "dazed" there would light the stunned icon for its staggers too.

## Open
- (done, RSQ_Accessibility `agent-polish`) the shared menu's HP Bars section, detected by `RSQTHP_Handler`.
- Lossvoise's retexture is still in this repo's own git history (e7e644e, `lossvoise_retexture/`): rewrite
  the history or never push this repo (independent review 10-27, item 7).
- Champions sets a champion's StartHealth to its boosted health, so set-up champions read 100 % there (not
  overheal). LegenDoom Lite's evolve-at-half did not fire in the hurt tests (theirs, not looked into).
- Lossvoise's retexture is not shipped (no permission).
