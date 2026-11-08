# Arcade assets inventory: fonts and in-world text (2026-11-08)

What the series and its load order (doom2 -> brutal22test6 -> BD_VoxelPack -> RSQ pk3s) already have for text and
numbers, so mockups of in-world arcade feedback use our real assets. Nothing in the mods was changed. Every claim has
a file and line; **(inference)** marks what was read off pixels or reasoned, not stated in code or docs. Status words
("headset-confirmed", "rig only") are the mods' own READMEs, not new checks.

Glyph sheets, rendered from the actual files by `design/mockups/fonts/make_font_sheets.py` (FON2 and Doom patches
decoded there; nothing copied by hand): `design/mockups/fonts/font_*.png` and `contact_sheet.png`.

## 0. The VR rule every text path works around

- A canvas texture is black in VR on 17.3: Draw2D skips its viewport whenever a VR mode is on, measured on the rig
  (`Wheel/zscript/wheel/wr_q_shim.zs:13-19`; again for the Rig's holster digits, `TacticalRig/zscript/rsqtr/rig.zs:2992-2993`;
  `design/NEAR_DEATH.md:164-165`).
- So the series uses four ways to show text, and a mockup should say which one it means:
  1. **HUD layer** (`RenderOverlay` + `Screen.DrawText` / `DrawTexture`): drawn on QuestZDoom's HUD quad, 1 m ahead,
     half-width `vr_hud_scale` m, tilted down `vr_hud_rotate` (`SlowMo/zscript/rsqsm/downhud.zs:11-15`, read from
     QZD's `getHUDProjection`). No clip rectangles: their scissor misses the projected HUD (`Score/zscript/rsscore/hud.zs:33-38`,
     `SlowMo/zscript/rsqsm/countdown.zs:24-25`). Used by Score, DOWN's panel, SlowMo / Miniboss bars, GBOVR, Melee.
  2. **World billboards / model quads**: one actor per glyph (Score wrist, Rig ammo count) or unit-quad models skinned
     per letter, "letter strips" (Wheel, DOWN crosshair and trail): `wr_q_shim.zs:17-19`, `SlowMo/zscript/rsqsm/plate.zs:12-14`.
  3. **VisualThinker glyphs** from textures, no sprite frames, one 200-glyph pool (VisualRewards damage numbers and
     banners): `VisualRewards/pk3/zscript/rsqthp/damnums/glyphs.zs:3-14`, `events.zs:63`.
  4. **Voxels baked on the hand** (Gun Cards: every digit and letter a voxel drawn as a HUD model at the hand):
     `GunCards/zscript/rsqgc/card.zs:10-17`; 16,442 `.kvx` files in `GunCards/voxels/` (counted).
- The one canvas still in the series: RSQ LaserSight's range readout writes canvas `RSLRANGE` in SmallFont
  (`LaserSight/zscript/rsqls/sight.zs:49-50, 1059-1071`). By the rule above it should be black in VR **(inference;
  not checked here)**.

## 1. Fonts (files, glyphs, look, users, VR path)

| Font | File(s) | Glyphs | Look | Used by (VR path) | Sheet |
|---|---|---|---|---|---|
| **RSSCFON** (Score line; Blue Shadow, via Dakka) | `Score/RSSCFON.fon2` | FON2, cell 12 px, chars 32-96, 65 glyphs, no lower case (decoded) | chunky bevelled grey capitals, blocky square digits | Score's "Score: N" line (HUD): `Score/zscript/rsscore/hud.zs:169`; GBOVR skin A's copy of that line `GunBonsaiOffhandVR/rsq/ui/skin_a_hud.zs:114-128`. Credit `Score/CREDITS.md:16-18` | `font_RSSCFON.png` |
| **RSSCFN2** (Score breakdown / combo font; Jimmy, via Dakka) | `Score/RSSCFN2.fon2`; unpacked copies `SlowMo/graphics/rsqsmp/RSPC032-095.png`, `Wheel/graphics/WRSC048-057.png` | FON2, cell 7 px, chars 32-96, 65 glyphs, capitals only (decoded; `design/NEAR_DEATH.md:196-198`) | small rounded pixel capitals with a dark drop edge | Score breakdown rows (HUD) `hud.zs:348`; DOWN panel text when Score is loaded (HUD quads per letter) `SlowMo/zscript/rsqsm/downhud.zs:162-181`, `platefont.zs:3`; Wheel holster-web ring numbers when Score is loaded (world quads) `Wheel/zscript/wheel/wr_web.zs:80, 706`, `Wheel/tools/gen_web_digits.py:2-12` | `font_RSSCFN2.png` |
| **JFO** (JDUI by Zedas, Blackmore1014's BD Ultimate Edition edit) | source `GunCards/tools/card_art/jfo/small/stcfnNNN.png` (32 px cell) and `.../big/fontbNNN.png` (64 px cell); copies `VisualRewards/tools/dn_art/jfo_*`, `Wheel/graphics/WRJS*/WRJB*`, `SlowMo/graphics/rsqsmp/RSPJ*` | small: 41 glyphs `0-9 A-Z + - / : =` (`GunCards/tools/jfo.py:17`); big: `0-9 +` (`jfo.py:18`). Gaps filled with IWAD DoomFont letters (`Wheel/tools/gen_jfo.py:15-17`) | grey brushed-metal bevelled capitals; big digits heavy and squared | "our font" (owner 11-03, `GunCards/CREDITS.txt:11-15`): Gun Cards text (voxels); Wheel default font set (`Wheel/CVARINFO.txt:96`, `WRFONTS.txt:19`; world quads); VisualRewards default number font "JFO Metal" and all its words (VisualThinker; `VisualRewards/README.md:122`, `numbers.zs:199-221`); DOWN panel text without Score (`platefont.zs:3`) | `font_JFO.png` |
| **Ermac's digits and words** (Force Unleashed holo HUD) | `GunCards/tools/card_art/digit_0-9, plus, d, g, o.png` (12x12), `ammo/magazine/chamber/reload.png`; copies `Wheel/graphics/WREDIG0-9.png`, `VisualRewards/tools/dn_art/ermac/` | 0-9, +, d, g, o; four words | thin pixel digits, white; d / g / o gold (pixels) | Gun Cards small-card option (`GunCards/README.md:110`, `CREDITS.txt:3-9`); Wheel "Ermac" font set (`Wheel/WRFONTS.txt:14-16`); VR damage-number font "Ermac" (`gen_dn_art.py:12`) | `font_Ermac.png` |
| **damnums Classic / Small** (Xaser) | `VisualRewards/tools/dn_art/classic/QC11A0-J0.png` (14x16), `QD11A0-J0.png` (8x7) | 0-9 | grey Doom-style digits with shadow, recoloured by translation | VR damage-number fonts "Classic Doom" / "Classic Doom (small)" (`gen_dn_art.py:13-14`, `README.md:122`) | `font_damnums.png` |
| **VR damage-number glyph textures** (generated) | `VisualRewards/pk3/graphics/rsqthpdn/RQN<F><Q><HH>.png` (173 files) | F = J/S/E/C/D (the four fonts above + JFO small), Q 0 Quest half-res / 1 PCVR, HH = ASCII hex (`gen_dn_art.py:2-17`; `glyphs.zs:65-74`) | JFO metal levelled to white so translations reach full colour (`gen_dn_art.py:16-17, 36-42`) | everything VisualRewards writes in the room | (same art as JFO / Ermac / damnums sheets) |
| **DOWN seven-segment readout** | no font file: 7 `RSPWHT` quads per digit, `downhud.zs:338-372` | 0-9 and a blinking colon (SS:hh) | lit #FF2A1A, unlit segments at 12% alpha, colon blinks every 17 tics (`downhud.zs:349, 367-372`) | DOWN panel DEATH IN tab (HUD) | `font_DOWN_sevenseg.png` (redrawn from the code's segment table) |
| **IWAD SmallFont / DoomFont** | `doom2.wad` STCFN033-096, 121, 123-125 (68 lumps) | ASCII 33-96 plus a few | red Doom capitals | Score wrist digits (STCFN048-057, billboards, AddShaded gold) `Score/zscript/rsscore/wrist.zs:7-9, 18-32`; Rig holster ammo count (TEXTURES `RTNM` = STCFN048-057) `TacticalRig/zscript/rsqtr/rig.zs:2994-2997, 3139-3149`, `TacticalRig/TEXTURES.txt:43`; Wheel words `WRG` cells `Wheel/TEXTURES.txt:2-60`, DOWN's `RSPG` copies `SlowMo/TEXTURES.txt:1-3`; GBOVR labels `rsq/ui/draw.zs:24-25`; Melee F.E.A.R. label `Melee/zscript/rsqml/shove.zs:553-563`; LaserSight canvas | `font_IWAD.png` |
| **IWAD status / intermission numerals** | STTNUM0-9 + STTMINUS, STTPRCNT; STYSNUM0-9; STGNUM0-9; WINUM0-9 + WIMINUS, WIPCNT, WICOLON | digits | big red bevelled; small yellow; small grey; big red intermission | engine HUDFONT_DOOM = STTNUM, INDEXFONT_DOOM = STYSNUM (`rsq_weapondepot/tools/rig/bin/res/qzdoom.pk3` `fontdefs.txt:3-17, 46+`); Wheel number sets `WRD` / `WRY` / `WRN` (`Wheel/WRFONTS.txt:9-11`, `TEXTURES.txt:69, 82, 92`); GBOVR skin A health / armour / reserve `skin_a_hud.zs:196-233` | `font_IWAD.png` |
| **DBIGFONT** | `doom2.wad` lump DBIGFONT, FON2, cell 15, 65 glyphs (decoded) | ASCII 32-96 | red-and-white angular capitals | BigFont: GBOVR big title `draw.zs:27`; every mod's centre-print at Text Size >= 1.5 (`Score/zscript/rsscore/a11y.zs:59-61`, same in each mod's a11y.zs); BD22's boss banner. **(inference)** that 17.3 builds BigFont from this lump: the engine pk3 carries no Doom bigfont folder, only `zbigfont.lmp` (listed); not checked in engine source here. This iwad's DBIGFONT and STCFN096/121/123-125 are not in a vanilla 1.9 doom2.wad **(inference: a re-release iwad, 28.8 MB)** | `font_IWAD.png` |
| **NewSmallFont / console font** | engine `qzdoom.pk3`: `newconsolefont.hex`, `fonts/consolefont/` | Unicode | clean sans pixel | Gun Bonsai's own HUD `GunBonsaiOffhandVR/ca.ancilla.bonsai/HUD.zsc:213`; GBOVR body text `draw.zs:26`; Miniboss "No Miniboss:" line `Miniboss/zscript/rsqmb/hud.zs:261-268` | not rendered (engine file, not in load order data) |
| **BD22 DIGINUMBER** | `brutal22test6.pk3` `graphics/HUDS/Font/DIGNUM0S-9S.png`, `DIGMINUS.png` (12x13, opaque) | 0-9, - | red LED digits on dark red cells #430000, unlit segments #4F0000 visible (pixels) | BD22 fullscreen HUD ammo `Fontdefs.txt:1-14`, `SBARINFO.BD:536, 543` (19 uses) | `font_BD22.png` |
| **BD22 DIGIFONT_SMALL / _LARGE** | `graphics/HUDS/Font/DIGINUM0-9.png` (7x10), `DIGLNUM0-9.png` (11x17), RGBA | 0-9 | white-grey thin digital digits | BD22 "Doom Nukem" style HUD `Fontdefs.txt:32-59`, `SBARINFO.BD:975-989`, translation `DoomNukemStatusBarGreen` (not defined anywhere in the pk3's text lumps: searched) | `font_BD22.png` |
| **BD22 AMMOFONT** | = IWAD STYSNUM0-9 (`Fontdefs.txt:18-30`) | 0-9 | small yellow | `SBARINFO.BD:1009` | (IWAD sheet) |
| BD22 other text | engine fonts only | | | `SetFont("BIGFONT")` "-= BOSS =-" in CR_RED + SMALLFONT HP (`src/BOSSHEALTH.acs:9-16`); version tag in SMALLFNT (`src/BD_Main.acs:214`); `A_Print` weapon messages, e.g. `actors/Weapons/Rifle.dec:474` | |

BD_VoxelPack has no font or TEXTCOLO lumps (listed). Freedoom (`/home/claude/gamedata_fd`) is not in the load order and
was not rendered.

## 2. Presentation styles already in use

### RSQ Score (HUD layer; status 0.99 headset-confirmed, `Score/README.md:5`; Letters modes rig only, `:7`)
- **Score line**: "Score: " white + number gold in RSSCFON (`hud.zs:166-218`). RSSCFON has no lower case, so the
  engine shows "SCORE:" **(inference: GZDoom maps missing lower case to capitals)**. On points: the same string in
  WhiteFlash / GoldFlash over the top, 0.05 s hold, 0.15 s fade (`hud.zs:82-84, 211-218`).
- **Living label**: the word breathes once every 2 s, calm blue (110,170,230) to warm (250,240,140), pushed to hot
  white-gold (255,255,70) on an award or big combo; warms toward gold in the bar's last quarter; Letters Uniform /
  Wave (55 degrees per letter) / Chaos (`hud.zs:404-422`, `LabelColor` `:423`; `README.md:102-106`).
- **Reward bar** SCOREBG / SCOREBKT / SCOREBR art (`Score/graphics/`), blue when the next reward is a life, orange for
  ammo; on reward the bar lights in that colour and the score flashes for 26 tics, life pips swell (`hud.zs:86-90`,
  `README.md:107-110`). Life pips HUD_LIF1-4, up to 10 (`hud.zs:53`).
- **Breakdown / combos**: one row per paying bonus, "+N" left-anchored at centre-55 in the family colour, the name at
  centre-12 in white, RSSCFN2, rows 13 px apart, a row keeps its slot; hold (bonustime/35 - 0.5) s then 0.5 s fade;
  quick kills add into the same row (`hud.zs:334-401`, `README.md:111-112`). A named combo and its "N-Tool Combo" get
  their own rows (`README.md:81-83`). No "xN" multiplier is drawn by Score: bonuses are shares of the base, summed,
  capped at 300% (`README.md:39-41`).
- **Family colours** (TEXTCOLO, bright end 25-255): White #C0C0C0-#FFFFFF, Gold/Base #C0B020-#FFD030, Efficiency
  #C09090-#FF8080, Style #90C020-#B8FF30, Daring #C06020-#FF8030, Melee #7090D0-#A0C8FF, Counter #B070D0-#E0A0FF
  (`Score/TEXTCOLO.txt:10-63, 163-167`), with _PD / _T / _HC colour-blind sets and a family letter (`TEXTCOLO.txt:72-181`,
  `hud.zs:375-391`).
- **Score on the Wrist** (option, off): up to 8 gold (#FFD040) STCFN digits, 2 cm tall, 5 cm above the off-hand
  controller, two additive layers per digit, billboards (`wrist.zs:1-22, 81`; `README.md:114`).

### RSQ VisualRewards damage numbers (VisualThinkers in the world; 0.99 headset-confirmed `README.md:6`; DOWN parts rig only `:10-16`)
Design: the owner's 11-03 round from animated mockups, references Borderlands 3 and Castlevania SotN (`events.zs:14-47`).
- **Hit number**: small, pops at the hit with a 2-3 tic white flash, snaps out with overshoot, arcs up and out, gone
  in 0.75 s; successive hits alternate left / right and step outward; traced clear of walls (`events.zs:16-20`). Arc:
  out 1.9 and up 1.7 digit heights plus 0.55 / 0.35 per lane, ease-out then a small drop (`events.zs:588-596, 1141-1150`).
  Pop off: damnums' Toss or Float (`README.md:132-133`).
- **Colour**: by damage type, 4-shade Castlevania cycling every 2 tics letter by letter (`events.zs:21-22`). Mapping
  `events.zs:396-431`: bullets white, shells yellow, fire orange, explosives **red** (the README says gold,
  `README.md:56`: they disagree), BFG lime, rail blue, melee pink, saws crimson, Saber sky, Force lavender, poison purple.
- **Palette** (18, `gen_dn_art.py:119-126`): White, Silver, Yellow, Gold, Orange, Red, Crimson, Pink, Magenta, Lavender,
  Purple, Blue, Sky, Cyan, Teal, Green, Lime, Grey (cool-down); translations from black, so the metal shading stays
  (`gen_dn_art.py:132-151`).
- **Running total + "xN" combo**: total centred above the HP bar from the 2nd hit, rolls up like a counter, bounces per
  hit; "X%d" beside the bar at 0.62 height; colour steps per hit along a ramp (default White Yellow Orange Red; six
  ramps + Random `VisualRewards/pk3/MENUDEF.txt:169-177`), grows to x5 then shakes; cools down (colour drains, fades)
  over Score's 105-tic chain window (`events.zs:23-27, 65-67`; `numbers.zs:171-179`).
- **Kill**: one punch, hold 14 tics, fade 10 (`events.zs:1109-1116`). **OVERKILL** red word, **HEADSHOT** gold word
  over a x1.35 number with a sharp jolt and gold / white cycling (`events.zs:28-32, 1150-1154`; `numbers.zs:168-169`).
- **Gains**: "+N" health / armour / ammo rise from the pickup and fly to the wrist (`README.md:59-60`).
- **Level-up band**: grey band (RQNBAND, darker top and bottom, ends fading), "LEVEL UP" in JFO small sweeping in
  fast / slow / fast, "PLAYER LV n" and "+1 UPGRADE" trailing; 1.26 s; ~2 m ahead, follows gaze lazily
  (`events.zs:33-38, 71`; `numbers.zs:207-214`; `gen_dn_art.py:154-163`).
- **Weapon tag**: dark rounded box (RQNTAGF) + coloured border (RQNTAGB); name types in letter by letter with a white
  flash each, "LV n" in JFO stamps in, NEW UPGRADE flickers green; 2 s (`events.zs:39-43, 72, 1096-1098, 1398`;
  `numbers.zs:216-224`).
- **DOWN words**: "+0.5s" in crimson (the "s" set small: capitals-only fonts) pops, holds, drifts, 1.7 s; REVENGE
  magenta, REVIVE cyan on the band in JFO, REVIVE sized by tier 1.5 / 1.15 / 0.85 (`events.zs:809-813, 848, 1100-1106`;
  `numbers.zs:180-205`).

### RSQ SlowMo DOWN (design `design/NEAR_DEATH.md`, `design/mockups/README.md`; rig only, `README.md:7`)
- **Panel** on the HUD layer, laid out in the mockup's 1312 px pixels, half of the eye's view, centred under the gaze
  (`downhud.zs:1-20`). Entrance: slams up from the bottom in 8 tics with ~6% overshoot, bar fills left to right in 10
  (`downhud.zs:18-20, 56-58`).
- **Bar**: three steps 14 / 30 / 52 px, tall end drains first, #0b0b0d border round #202024 track; fill = 60 slices of
  a moving gradient hsl(H +-9, 95%, 50 +-12%) of the target's colour; refill = a bright edge running left to right
  (`downhud.zs:21-27, 249, 264-301`).
- **Target lines**: "TARGET:" + the target's crosshair icon tinted its colour (or a dark round slot + icon + name);
  text a light tint hsl(H, 80%, 75%); dead = dimmed, struck through, icon cracked (RSPCRK) (`downhud.zs:28-35, 306-334`).
- **DEATH IN tab**: #0b0b0d / #170708, "DEATH IN:" tinted #C98A8A, the seven-segment readout (`downhud.zs:338-372`).
- **Text**: RSSCFN2 letters (RSPC) when Score is loaded, else JFO (RSPJ), each letter its own quad (`downhud.zs:162-181`;
  `SlowMo/tools/plate/gen_plate_font.py:1-25`).
- **Crosshairs** (world quads, Shaded): 10 icons x 17 baked assembly frames (RSPA, 170 PNGs), ~0.45 s, only in view
  (38 degrees) and in sight (`plate.zs:1-14, 118-121, 197`). **Trail**: six chevrons at eye level, brightness wave
  toward the target, 24 frames (RSPTC / RSPTL) (`plate.zs:8-11, 122-123, 247-248`). **Edge arrows** (HUD): four
  Turn Marker styles A-D x 30 momentum frames (RSPMA-D F/C/L), grey bevel frame #d4d8e0 / #8d93a0 / #3b404b, fill in the
  target's colour (`downhud.zs:36-45, 396-405`; `NEAR_DEATH.md:154-160`; option `SlowMo/MENUDEF.txt:105`).
- The approved HTML mockup draws its text in a browser sans-serif (`design/mockups/down_v3_full_view_mockup.html:3371`);
  the build swapped that for RSSCFN2 / JFO (`NEAR_DEATH.md:196-201`).
- **Countdown bar** (HUD): coldcite's Top HP Bars rim and well (RSQSMHE / RSQSMHW), hourglass RSQSMHG, green or chosen
  colour, light band sweep, breathing end, glint on refill (`countdown.zs:1-26`).

### Others
- **Wheel**: cards and text as unit-quad models, one strip cell per character, Doom's own art by lump name, colour by a
  run-time palette translation (`wr_q_shim.zs:13-30`). Font sets StatusBar / SmallGold / SmallGrey / DoomFont / Ermac /
  JFO (`Wheel/WRFONTS.txt:9-20`); default JFO (`CVARINFO.txt:96`, rig only `Wheel/README.md:9`).
- **Tactical Rig** holster ammo count (option, off): up to 3 STCFN digits, 2.4 cm, additive stencil billboards in the
  ammo light's colour, green / amber / red (`rig.zs:2988-2997, 3139-3149`; `TacticalRig/README.md:222`).
- **Gun Cards**: Ermac panels per weapon slot colour, text JFO by default, all voxels at the hand; "Draw in the World"
  option builds them as world quads (`card.zs:3-21`; `README.md:57, 65-66, 110`).
- **GBOVR**: screens use Doom's own fonts (SmallFont labels, BigFont title in light blue, NewSmallFont body), nearest
  `Font.CR_*` colour since Doom glyphs cannot be tinted (`rsq/ui/draw.zs:6-9, 188-191, 222`). Levelling messages are Gun
  Bonsai's `A_Log` lines in the engine message font: "You gained a level of %s!", "Your %s is ready to level up!",
  "You are ready to level up!", "Level-up rejected!" (`ca.ancilla.bonsai/PerPlayerStats.zsc:1278, 1300, 1311`;
  `WeaponInfo.zsc:231`; strings in `GunBonsai-0.10.6.pk3` `LANGUAGE.en-messages:6-11`). The in-room LEVEL UP band and
  weapon tag are VisualRewards' (above).
- **Miniboss**: no words of its own on screen. HUD meter (RSQMBHE / RSQMBHW, crowned skull RSQMBSK0/1), red while filling,
  gold when full with beat and glint; one NewSmallFont line "No Miniboss: <reason>" with a black drop shadow
  (`Miniboss/zscript/rsqmb/hud.zs:1-22, 261-268`). Crown, chain, gem and tier pips over HP bars are VisualRewards sprites
  RSYI (`VisualRewards/pk3/TEXTURES.rsqthp:10-11`). Rig only (`hud.zs:21`).
- **Melee** F.E.A.R. award name: SmallFont, CR_GRAY, 55% alpha, centred at 72% height, fades (`shove.zs:553-563`).
- **Accessibility**: every mod's centre-prints switch to BigFont at Text Size >= 1.5 (`*/a11y.zs:59-61`).

## 3. Gaps a mockup should know about
- Every series font is **capitals only** (RSSCFON / RSSCFN2 32-96, JFO 41 glyphs); lower case falls back to capitals,
  and JFO's missing punctuation is IWAD DoomFont (`gen_jfo.py:15-17`; `numbers.zs:181-182` sets the "s" of "+0.5s" small
  for this reason).
- No font is set in MAPINFO/FONTDEFS by any RSQ mod: Score's FON2s are found by lump name (`hud.zs:169, 348`), the rest
  are textures (**inference** from the grep of all `*.zs` / `*.txt`).
- The NewSmallFont and the engine console font were not rendered (engine files).
