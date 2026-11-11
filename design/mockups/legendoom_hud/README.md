# LegenDoom HUD: redesign mockups (owner 11-11 15:05)

"the legendoom hud is a nightmare, we need to redesign it in our style." These are mockups to choose from, not a
build. No mod code is changed.

**Made from code only, no rig run** (owner 11-11 15:07). The "today" picture is rebuilt from LegenDoom 3.0's ACS,
TEXTURES, fonts and art. It is not a capture. Every image is drawn over one existing rig frame: 2026-11-10 batch,
launch P3A, frame f00144 (480 px per eye, shown 2x). In that frame the Rifle is in the right hand and a zombie is in
view. The overlays are drawn at 960 px. That is still well under a Quest eye, so if it reads here it reads in the
headset. Regenerate with:

```
python3 -I design/mockups/legendoom_hud/src/make_mockups.py <LegenDoom_3.0 unzipped> <frame> <BD22 MGUNA0.png>
```

| Image | What it is |
|---|---|
| `00_today_from_code.png` | LegenDoom's pickup screen and buff row as its code draws them, on the HUD plane we share |
| `A_gunbonsai_gauge_and_card.png` | **A**: put it into Gun Bonsai VR: a row under the gun hand's gauge, and one card when you pick it up |
| `B_world_words_sotn.png` | **B**: words in the world (SOTN style A): over the legendary monster, over its drop and over the gun |
| `C_wrist_panel.png` | **C**: one small panel on the off-hand wrist, for both guns, which you look at when you want |
| `D_overview.png` | **D** (owner 11-11 15:22): B's monster words and A's pickup card together. Two options for after the card: A's gauge row, or B's X3 over the gun |
| `D_card_variants.png` | the D pickup card: one frame per rarity, plus four versions V1-V4 |
| `D_card_V3_shimmer.gif` | V3's title moving between its two SOTN looks |
| `D_sequence.png` | D's moments in order: LEGENDARY, RISEN!, the glowing drop, the card for 3 s, then the card folding into the gauge row (5a) or into X3 over the gun (5b) |

## Direction D: B's monster words with A's card (owner 11-11 15:22)

The owner: "i love the enemy legendary and risen and red shit but i adore the gbovr-inspired card".

- **Monster (from B):**
  - LEGENDARY appears over a legendary in view;
  - at half health, RISEN! appears in red;
  - LegenDoom's own pentagram and red after-images stay as they are.
- **Drop (from B):** our gun glows, with EPIC and the power's name over it.
- **Pickup (from A):** one Gun Bonsai VR-style card in the rarity colour, for 3 s, with no key to close it.
- **Afterwards, two options for the owner to pick from:**
  - **Option 1:** the card folds into a row under the gun hand's gauge, on the HUD (A);
  - **Option 2:** the card becomes X3 and its seconds over the gun, moving with the hand, in the world (B).

**The card's variants** (`D_card_variants.png`):

- **Rarity frames:** one card per LegenDoom rarity, each with a chaingun-slot power of that rarity:
  - Common is green (Determined);
  - Uncommon is blue (Berserker);
  - Rare is purple (Vampiric);
  - Epic is orange (Murderous).

  LegenDoom 3.0 has only these four rarities. Epic is its top one; there is no separate "legendary" rarity.
- **V1, LegenDoom's name:** the sub line reads "EPIC CHAINGUN", LegenDoom's slot name. The card has the icon box.
- **V2, no icon box:** the text is centred across the card, with a rarity bar at the foot.
- **V3, SOTN A title shimmer:** the title is the two-tone SOTN word and flashes between two looks, like GUARD! and TARGET!. The GIF shows it moving.
- **V4, our gun's name:** the sub line reads "EPIC RIFLE". "Rifle" is BD22's own tag for the gun in hand (`Tag "$TAGBD_RIFLE"`, language.enu `TAGBD_RIFLE = "Rifle"`). The card has the icon box.

One catch for V4: BD22 tags the Minigun "Chaingun" too (`TAGBD_CHAINGUN = "Chaingun"`). So if the card names the gun the drop hands you (the Minigun), it still says Chaingun. It reads "Rifle" only when it names the gun in your hand.

## What LegenDoom shows today (from its code)

The example is an Epic **Murderous** drop for the chaingun slot. In BD22 VR's LD mode that slot covers the Rifle /
Minigun family.

1. **The pickup screen** (`LEGNDLIB.acs` script `EffectScreen`, on a 320x240 HUD). It runs on every legendary pickup, also
   in LD mode (`rs_brutal22weaponsq/src/zscript/rsld/pickup.zs:167-170`). It shows:
   - the title "<Power> <LegenDoom weapon name>" in ZD2012, in the rarity colour (green, blue, purple or orange), at
     the top. It says "Chaingun" even when the power goes on our Rifle.
   - LegenDoom's own Doom sprite of the gun (`LCHGEPIC` = ECHGZ0 at scale 0.3: 240 units wide) in the middle;
   - the 42-unit power icon below it;
   - the description and a joke quote in MINIPLIC.

   It stays 7.5 s and fades for 2.5 s. **Use, Fire or Alt-fire closes it**, so closing it also fires the gun in your
   hand. It plays a pickup sound. The title and the description also go to the console log (HUDMSG_LOG).
   On our HUD plane it lands right on Gun Bonsai VR's gauges, Score's line and the middle of the view.
2. **The buff row** (`LEGENDPLY.acs` `LDPlayerLoop`). For each timed buff that is running (Determined, Battlerage,
   Killstreaker, Entrenched, Intimidating x2, Ghostly, Murderous, Unstoppable, Artifact cooldown, Augmented x2) it draws a
   box (HUDBOX5/6) at the top centre. Each box holds a 7-unit icon and the seconds left in INDEXFONT_DOOM, coloured by
   rarity. A new box is added every 20 units to the right.
3. **The info screen**: the L key, or "Legendary Info Screen" in the LD mode menu (`LEGENDMEN.acs`). It is a 640x480
   grid of the nine weapon slots, with pulsing icons and the chosen slot's name and description.
4. **Upgrading**: a centre print "<Weapon> upgraded!" (`LANGUAGE.misc`, `LD_UpgradingUpgrader`).
5. **Pickups**: the legendary drop glows in its rarity colour (`LD_glowingpickups`). Optional, off by default: power
   icons that hover over a pickup you look at (`LD_effectnames`), and pickup messages (`LD_verbosepickups`). In LD mode
   the drop looks like our gun (`RSLD_LegendaryPickup`).
6. **Monsters: nothing on the HUD.** There is no name, level, bar or XP, because LegenDoom has no XP.
   - A legendary has 3x health and looks normal until half health (`LEGENDMON.acs` `LDMonsterInit`).
   - At half health it rises: it heals to full and deals 2x damage, with a pentagram of particles.
   - From then on it has red/black after-images and particles, or its Champions colour.
   - Automap markers are off by default.
7. LegenDoom's fullscreen SBARINFO does not show: with LegenDoom loaded first, BD22's status bar wins.
8. **LD mode's own extras** (BD22 VR 2.0.4f):
   - the held gun's legendary name at the top of the view (`rsld_screen_name`), off since the owner turned it off on 11-05;
   - the print "This gun has no legendary power.";
   - a pickup-fail print in CONFONT.

Already in the series:
- the Wheel's card shows the rarity, the name and the power;
- Score has its Legendary rows;
- VisualRewards puts a gem on a legendary;
- Gun Bonsai's status screen has a LegenDoom effects line. That code reads LegenDoom's own weapon classes; not
  checked against LD mode.

## The style these use

- **Gun Bonsai VR:** the gauges and the level-up card. The colours are taken from
  `GunBonsaiOffhandVR/rsq/ui/skin_a_menus.zs`: card fill #170D26 with a double outline, the title in SmallFont in the
  card's colour, and a dark icon box.
- **Score:** the RSSCFN2 combo font for short words, and the IWAD SmallFont in gold for wrist digits.
- **VisualRewards:** the SOTN style A words (QVW glyphs, two tones, dark box), from `design/mockups/sotn_words/`.
- **LegenDoom:** its rarity colours and its power icons are kept, because they are what makes it LegenDoom.

## The three directions

| | A: Gun Bonsai VR gauge and card | B: words in the world (SOTN A) | C: wrist panel |
|---|---|---|---|
| **Keeps** | rarity colours, the power's name, LD's icon, the buff timer | rarity colours, the power's name, LD's monster effects (pentagram, after-images) | rarity colours, the power names, LD's icon, the buff timer, both hands |
| **Moves** | name, icon, X3 and its drain into a row under the gauge of the hand holding the gun. A rarity tick on that gauge. The pickup becomes one GBOVR-style card on the HUD plane for 3 s, with no key, then it folds into the row | the pickup screen becomes EPIC and MURDEROUS over the drop, so you see it before you take it. The buff becomes X3 and its seconds over the gun | everything goes to one panel on the off-hand wrist. On pickup the panel flashes and EPIC! pops |
| **Adds** | nothing new | LEGENDARY over a legendary in view, and RISEN! when it rises. LegenDoom shows nothing for these today | the other hand's power, on the same panel |
| **Drops** | the 240-unit Doom sprite, the quote, Fire-to-close, the buff row at the top of the view, LD's weapon names | everything LegenDoom draws on the HUD plane | the pickup screen and the buff row at the top |
| **Trade-off** | it lives in HUD space shared with GBOVR and Score. The row sits outside the gun hand's gauge, clear of Score's line | world words must be billboard glyphs or VisualThinker words (canvases draw black in QZD VR) | you must look at your wrist to read it, and it shares the wrist with a saber or shield |

In all three, the description and the quote go to places you open on purpose: the Wheel card, the status screen,
and the info screen (L).

## Open for the owner

- Pick a direction, or a mix. For example, B's LEGENDARY and RISEN! over the monster could go with A's gauge row.
- Should the info screen (L) stay as LegenDoom's grid, or become a Gun Bonsai VR status page?
- RISEN! and LEGENDARY are new words. Is it the owner's call to add them (B)?

## Notes

- The HUD plane on the frame is estimated, not read from the engine. The status bar is 320 units wide over
  x 310..695 px, so 1 unit is 1.203 px. A 320x240 HudMessage screen is then x 310..695, y 447..736, and Gun Bonsai VR's
  gauges sit at its top (y 448), which agrees.
- The uploaded `LegenDoom_3.0.pk3` is plain LegenDoom 3.0. It has no BD22 VR patch in it.
  - The patch lives inside BD22 VR 2.0.4f as its "LD mode" (`rs_brutal22weaponsq/src/zscript/rsld/`).
  - The separate `LegenDoom_BD22VR_Patch.pk3` is the old version and must not be loaded with it
    (`rs_brutal22weaponsq/ldl_patch/README.md`).
  - The owner's order puts LegenDoom right after doom2.

## Owner's decision (2026-11-11 15:30): direction D approved, with changes
- No words over a legendary monster until it rises. When it rises (half health), the word is **LEGENDARY** (it replaces
  RISEN!), with LegenDoom's red pentagram and after-images as they are.
- Minibosses and thralls: no change (GUARD! and TARGET! stay as they work now).
- Champions: words for Champions (Champions mod) are PARKED. Maybe none are needed, since they have icons and visuals;
  the owner wants to come back to it, not drop it.
- Picked (owner 11-11 15:3x): the pickup card is **V3, the SOTN shimmer title**; after the card folds away the power lives
  in **option 1, the row under the gun hand's Gun Bonsai VR gauge** (icon, name, X3 with its drain line, a rarity tick).
- The design is settled; building it is the next step (not started).
