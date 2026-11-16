# Player banners and the top HUD: Arcade Gold (design, not built)

Owner, 2026-11-16 01:50-02:25. Companion to `DOWN_LIVES_MINIBOSS_TIERS.md` (the rule these banners announce).
**Nothing here is built.** Pictures and animations: `mockups/banners/` (made outside the game, in the Series' real
fonts and HUD art, over a rig frame).

His words, in order:
- "we need snappier, poppier ways to display this information. and more., like, for REVIVE, we need to tell the player
  the kind of bonus they got, like +X health +Y Armor +invuln or whatever"
- "let's try to have some fun here with styles, we have a core set of fonts we use"
- "I like the Arcade Gold series"; "I very much like the revive screen"
- "your bonus awards too how they pop in in sequence and animate, are particularly lovely"
- "player-facing it should be called Boss to avoid a system rewrite"
- On the 1UP: "less like the example image. usually in arcades the up is superscript ... smaller and higher next to the
  number"; "the 1up could have a lot of life to it, a lot of freedom for that one specifically provided it falls into our style"
- "the invuln bar can be modelled like our other three bars, and laid out at the top. the invulnerable text that we flash
  to the player can be the same vivid color as the bar so the player knows where to look"
- "we award slomo on a lot of this too so ensure our contextslomobar is always showing the reason"
- On the Doomguy faces as Score's life pips: "an excellent idea ... yes, i like this"

## 1. Player-facing words

- **Boss**, never "miniboss", in anything the player reads: **BOSS DEFEATED!**, **BOSS WINS!**, slow motion's
  **BOSS** / **BOSS INCOMING**. Code, cvars, class names and these design docs keep "miniboss" (no system rewrite).
- An extra life is **1UP**; spending one is **−1UP**. Not "1DOWN": DOWN already names the downed state.

## 2. The style: Arcade Gold

- **Headline:** RSSCFON, a gold ramp, a dark outline and a drop shadow. Red ramp for a loss (BOSS WINS!).
- **Bonus chips:** a dark rounded pill each, an icon, the number in RSSCFN2 at the larger size, the word at the smaller,
  in its family's colour:

| Family | Colour | Icon |
|---|---|---|
| Health | green | cross |
| Armor | blue | shield shape |
| Invulnerable | **hot magenta** (the bar's colour, section 5) | the orb |
| Ammo / mags | white | three rounds |
| Lives | the Doomguy face | the face |
| Tier up | gold | up arrow, plus the tier colour's swatch |
| Tier down | red | down arrow, plus the swatch |

- **The motion** (the part he called "particularly lovely"; keep it exact):
  - the headline punches in: scale 0.2 → 1.35 → 1.0 over 4 frames (about 2 tics a frame), capped at 1.12 on screen;
  - the chips pop the same way, **each starting 2 frames after the one before**, in reading order, two to a row;
  - a short hold, then everything shrinks to about 0.4 and fades over about 6 frames.
  - In ZScript this is a scale and a start time per chip; nothing else.

## 3. The moments

| Moment | Headline | Chips | Mockup |
|---|---|---|---|
| Getting up from DOWN | **REVIVE** | what it actually gave: +health, +armor, INVULNERABLE n S, MAGS FULL (only the ones that happened, real numbers) | `A_REVIVE.jpg`, `anim_REVIVE.gif`, `anim_REVIVE_INV.gif` |
| A Score life spent (failed DOWN) | **−1UP** (section 4) | lives left (as faces), +100 HEALTH, INVULNERABLE 5S, MAGS FULL | `A3_MINUS1UP.jpg`, `anim_MINUS1UP_INV.gif` |
| The Boss killed | **BOSS DEFEATED!** | TIER UP + the new tier's colour. **No legendary line:** the drop is in the world, the player sees it | `A2_BOSS_DEFEATED.jpg` |
| The Boss fight lost | **BOSS WINS!** (red) | TIER DOWN + the colour, NO LEGENDARY | `A2_BOSS_WINS.jpg` |
| A life gained (the pickup, or Score's target) | **+1UP** (section 4) | the lives, the new face popping in | `A3_1UP.jpg`, `anim_1UP.gif` |

## 4. 1UP and −1UP

- **The look:** a big **1** with a small **UP** raised beside it (superscript, top-aligned), in RSSCFON, filled with
  hard horizontal bands (yellow, amber, orange, red from the top) and a thick black pixel outline, the Doomguy face at
  its left. A white band sweeps down through the colours. Optional: **EXTEND!** above it (the shmup word for an extra
  life), `A3_EXTEND.jpg`: **dropped** (owner 02:29).
- **+1UP has freedom** ("a lot of life to it"): a gold flash and spinning rays on the pickup; the face pops in with
  Doom's evil grin (`STFEVL0`) and wobbles; the 1UP squashes as it lands and bobs; sparkles burst; then the whole badge
  shrinks and **floats up into the lives at the top** (the Super Mario Bros. float), where the new face pops in with a
  second burst.
- **−1UP:** the hot 1UP shows for a beat, then the minus slams in with a red flash and a shake; the face turns to the
  OUCH face (`STFOUCH0`), greyed; the bands drain to cold steel and droop; one face falls grey off the lives at the top.
  Then the chips pop as in section 2.
- **The pickup:** the Boss's 1UP is a pickup, not an instant life. It is Score's existing life crate
  (`RSQ_ScoreLifeCrate`: the Berserk pack, Brutal Doom's voxel with BD_VoxelPack, in Score's gold). The Boss drop of it
  was removed earlier; bringing it back is a later decision. Open with it: its tint (he remembers it white; the code
  tints it gold), its 10 s life, and a safety net (it can be lost over a pit). **Decided: section 6.**

## 5. The top HUD

```
        Score: 12450                     (Score's line, as today)
  [ ======== Score's bar ======== ]  ☺☺☺   Doomguy faces in place of Score's life pips
     ♛ [ ===== Boss meter ===== ]          (Miniboss: red, gold when full)
     ⧗ [= adrenaline =]  ⧗ [= world slow =] (SlowMo: cyan / the chosen colour)
                REASON WORD                 (SlowMo's reason line, as today)
     ● [ ===== INVULNERABLE ===== ]        NEW: the fourth bar, magenta
```

- **Life faces:** Score's life pips (`HUD_LIF1`–`4`) become small Doomguy faces (`STFST01`, from the IWAD the player
  already loads): grinning when one is gained, OUCH and grey as one falls away.
- **The invulnerability bar** (`A3_TOP_STACK.jpg`):
  - the same family as the other three: coldcite's Top HP Bars well and fill (`RSQSMHE` / `RSQSMHW`), tinted in 8 steps,
    the light band sweeping along the fill, the breathing edge, the same Photosensitive Mode rules;
  - **hot magenta** (dark plum empty, magenta, pale pink at the top), because red/gold, cyan and green are taken;
  - a new 16×16 pixel-art icon: a magenta orb with a glint (to be drawn properly; the mockup's is a stand-in);
  - its own row under the slow motion row, the Boss meter's width and thickness; it shows only while invulnerable, full
    at the start, draining to zero over the real seconds left, then fading;
  - **the hand-off:** the banner's INVULNERABLE chip is the same magenta. It blinks a few times, then flies up into the
    stack; the bar flashes in full where it lands, then drains. The player's eye follows it to the bar.
- **The slow motion reason** (built: SlowMo `countdown.zs` DrawCause, clock `CauseWord`): every slow motion that shows
  the world bar prints its reason under it in the SOTN style; a source with no word of its own shows its name in
  capitals, so it is never blank. With Adrenaline on, the bar (and so its reason) shows only for slow motion the game
  starts by itself (his rule of 11-06). To add with the banners: **REVIVE**, **1UP**, **−1UP** words for the slow
  motion those moments pay; **MINIBOSS** → **BOSS** and **MINIBOSS INCOMING** → **BOSS INCOMING**.

## 6. Decided (owner, 2026-11-16 02:29-02:38)

- **No EXTEND!** The 1UP is plain: the big 1, the raised UP, the face.
- **Magenta for invulnerable.** The four bar colours: Boss red, adrenaline cyan, world slow motion green, invulnerable
  magenta.
- **A life earned by Score's target shows +1UP**, with world slow motion for as long as the +1UP is on screen (its
  reason word: 1UP).
- **The Boss's 1UP is the life crate** (`RSQ_ScoreLifeCrate`, Score; today nothing in play spawns it, only rig probes):
  - the Boss drops it where it died (Miniboss asks Score for it by name, as before);
  - **gold**, as now (Score's gold, the beam of light into the sky);
  - **it stays until picked up** (no 10 s timer, no red fade);
  - **it floats back up** to where the Boss died if it falls where the player cannot reach it (a pit, below a ledge);
  - touching it: **+1UP** (section 4).
- The legendary weapon still drops as it does; the banner does not name it.
- **Fonts:** RSSCFON is the Series' font for these. Its letters are drawn light on their own darker tiles; the banded
  look keeps the tiles and bands the colour by rows (the first mockups filled the whole tile and read as blocks: a mockup
  error, not the font). In game the bands need pre-made graphics (the engine colours a font by brightness, not by row);
  the 1UP is a few characters, so that is small.

Still open: whether a second life at once reads **2UP**.

## 7. Built / not built (2026-11-16)

| Part | State |
|---|---|
| Arcade Gold banners and the chip pop | Not built (mockups only) |
| 1UP / −1UP | Not built |
| Doomguy faces as life pips | Not built (Score's own pips today) |
| The invulnerability bar | Not built (and the 5 s invulnerability itself is not built: rule doc, section 3) |
| The slow motion reason line | Built; the new words and BOSS wording not built |
| "Boss" in player-facing words | Not built (banners and reason words still say MINIBOSS) |
| The life crate as the Boss's 1UP (gold, stays, floats back) | Not built (the crate exists in Score; nothing spawns it) |
| +1UP with slow motion for a Score life | Not built |
