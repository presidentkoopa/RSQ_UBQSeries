# RSQ UBQ Series: the presentation guide

One look for everything the Series shows the player. Every mod follows this page; when a mod's own README disagrees,
this page wins. The detail and the mockups behind it: `design/BANNERS_AND_HUD.md`.

## 1. Fonts: which one, where

| Font | Use it for | Never for |
|---|---|---|
| **RSSCFON** (Score) | Headlines: every banner's big word, Score's line, words over monsters | Small labels |
| **RSSCFN2** (Score) | Chip words and numbers, labels, Score's combo rows, the reason line's fallback | Headlines |
| **SOTN look** (VisualRewards, two-toned halves) | Words over monsters (TARGET!, GUARD!, LEGENDARY…), the slow motion reason line | Chips |
| **Seven-segment digits** (SlowMo) | Every countdown clock: DEATH IN, FIGHT IN | Anything that is not a clock |
| **JFO, Ermac, Doom digits** | On guns, cards, the Wheel, damage numbers | The HUD |
| **Engine font** | Options menus only | Anything shown during play |

Player-facing text never shows a code name (DEMON1, PE…), never says "miniboss" or "bossfight" (it says **Boss**).

## 2. Banners (anything that announces a moment)

- **Shape:** a headline, then chips. Headline: RSSCFON in the moment's bands (gold for good news, red for bad, cold steel
  for a loss of a life, the 1UP's hot bands for a life). Chip: a dark rounded pill, an icon, the number, the word, all
  in the chip's family colour.
- **Say what happened, with real numbers:** +66 HEALTH, not "healed". Only the chips that actually happened.
- **Motion:** the headline's letters smear in, snap upright and flash between two looks (the SOTN letters), inside a pop
  of 0.2 → 1.35 → 1.0 over 4 frames; each chip pops the same way, **2 frames after the one before**, two to a row; a
  short hold; everything shrinks to about 0.4 and fades over about 6 frames.
- **Faces:** the Doomguy face from the IWAD says how it feels: grin (`STFEVL0`) for a gain, OUCH (`STFOUCH0`, greyed) for
  a loss, the bloodied low-health face (`STFST40`–`42`) while DOWN, the plain face (`STFST01`) for a life pip.
- **One banner service:** RSQ VisualRewards draws every banner; other mods ask it by name (`RSQVR_Service "banner"`,
  the contract in `BANNERS_AND_HUD.md`). No mod draws its own announcement.

## 3. Chip family colours

| Family | Colour | Icon |
|---|---|---|
| Health | green | cross |
| Armor | blue | shield shape |
| Invulnerable | magenta | the orb |
| Ammo, mags | white | three rounds |
| Lives | pink / the face | the face |
| Tier up, upgrade, level | gold / green arrow | up arrow, star |
| Tier down, a loss | red | down arrow |
| Legendary | purple | — |

## 4. Bars (anything that fills or drains)

- **One family:** coldcite's Top HP Bars well and fill (`RSQSMHE` / `RSQSMHW`), tinted in 8 steps from dark to bright,
  a band of light sweeping along the fill, a breathing edge where it ends. An icon at its left, 1.6 × the bar's thickness.
- **One colour each, never shared:**

| Bar | Colour | Icon |
|---|---|---|
| Score | Score's orange | (Score's own) |
| Boss meter | red, gold when full | the crowned skull |
| Big Boss bar (beside the Boss meter, design/BIG_BOSS.md) | gold (provisional, 2026-11-16) | the gold skull with a ruby |
| Adrenaline | cyan | Adrenaline's hourglass |
| World slow motion | green (or the player's choice) | the hourglass |
| Invulnerable | magenta | the orb |
| DOWN | blood red, pulsing | the bloodied low-health face |

- **The top stack:** Score, then the Boss meter (with the Big Boss bar beside it, the pair centred), then adrenaline and world slow motion side by side, then the reason line,
  then invulnerable; each bar asks the one above it where to sit, by name, and the stack closes up when one is hidden.
- **Exceptions kept on purpose:** the Boss health bar (`bossbar.zs`) and the DOWN panel keep their own place and shape.
- **A bar that slows time shows why:** the world slow motion bar always carries its reason word under it.

## 4b. Words over monsters (owner, 2026-11-16 03:15)

- RSQ VisualRewards' words (`words.zs`), in the world over the monster: the Word Font / the SOTN look, the entrance, the drift.
- **The SOTN entrance** (owner 11-16 07:59, "sotn style"; mockup `design/mockups/word_motion/`, its right column): every
  word (THREAT!, the LegenDoom drop words, TARGET!, GUARD!, KICK! and every service word) comes in as the banners' SOTN
  letters do. Counted from its first drawn tic: tics 0-3 stretched wide and slanted forward (k = 1 - tic/4: width
  x (1 + 0.3k), the top 0.45k of its height ahead), tic 4 upright at its normal size; tics 4-27 it flashes between its own
  look and a light look (each colour, both bands of a two-tone word, halfway to white) every 4 tics, light first; from tic
  28 its own look. Then as before: drift up, hold, fade over 10 tics. A held word does it once and keeps its pulse; the same
  word asked again while it is up pops in place (0.45 -> 1.35 -> 1.15 -> 1.0) and flashes again, never smears again.
  In the world a letter is a flat quad and cannot be sheared: in the smear tics each letter is four horizontal slices (on
  whole font rows; slices 1-2 the top half, 3-4 the bottom, so the two-tone look keeps its colours), each moved sideways by
  the slant at its middle. **Photosensitive Mode:** no flash between looks; the smear and the snap stay (shape only, no
  change of brightness, as the banners). Rig only, not headset-confirmed (`VisualRewards/test/evidence/wordmotion_*`).
- **Word Font** (owner 11-16, VisualRewards menu, `rsqvr_wordfont`): Score Small (RSSCFN2) the default, then SOTN (the
  owner's word sheet), JFO, Score Big (RSSCFON) and Doom Small. Only the letters change (motion, colours, two-tone look and
  sizes are the same in each); every font is VisualRewards' own and works without RS Score.
- **No doubling with a banner:** a moment that has a banner (BOSS DEFEATED!, BOSS WINS!, ENEMIES TIER UP / DOWN) is not
  also written over the monster. THREAT! stays a world word. Without VisualRewards' banners, the old world words come back.
- **Never on top of each other:** words that arrive together on one monster stand one above another; **never on the
  monster's health bar** (they stand above it and its markers).
- **TARGET! / GUARD!** one size up from today, readable at fighting distance.

## 5. Small messages

Short in-play messages ("No flares left", "No grenades", a tool's confirmation) are **toasts**: one chip in the family
colour that pops (section 2's chip motion) and leaves after about 1.5 s, low in the view. Not the engine's centre print.

## 6. Pixels and VR

- Pixel art and pixel fonts scale by whole numbers wherever possible and are never smoothed.
- The HUD layer only (RenderOverlay, quads): no clip rectangles and no Screen.Dim (they do not show on the projected HUD in VR).
- Kept inside the series' safe area (`rsq_ui_inset`); follows RSQ Accessibility's Text Size.
- **Photosensitive Mode:** no white flashes, no shakes, no flashing between looks, pulses at most once a second and dimmed.
- Everything is "rig only, not headset-confirmed" until the owner confirms it in his headset.
