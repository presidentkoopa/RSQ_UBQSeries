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

## 8. The DOWN screen in Arcade Gold (owner, 2026-11-16 02:37-02:49)

His words: "i like your idea. i want to change the bar ... the icon to be the animated doomguy low health face, with his
head bloodied up ... looking to the left and right. and the bar should be pulsing blood red, not the same icon and color as
the boss/miniboss bar". On the bars' look: "pick either set" (today's or the old DOWN ripple): **today's look is kept for
every bar** (8 tinted steps, the sweeping band, the breathing edge).

Same place and timing as today's DOWN (SlowMo `downhud.zs`: middle, then it sinks to the panel under the gaze); the look
changes. Mockups: `mockups/banners/DOWN_now_vs_proposed.jpg`, `DOWN_proposed_settled_v2.jpg`, `anim_DOWN_blood_bar.gif`.
- **Going down (middle):** the OUCH face greyed + a big red **DOWN!** (RSSCFON, red bands), **BE QUICK OR BE DEAD** under
  it; then chips pop in sequence as the banners' do: **1 KILL TO GET UP** (the kills owed), **100% HEALTH** (the health
  you will get up with: 100 / 66 / 33 % by DOWN count), **DEATH IN** with the seven-segment clock inside the chip.
- **Settled (the panel):** BE QUICK OR BE DEAD small on top; one **TARGET** chip per target in its colour (dead: dimmed,
  struck through); the bar; the DEATH IN chip beside it.
- **The DOWN bar:** the series' bar art (`RSQSMHE` / `RSQSMHW`), **pulsing blood red** (dark crimson to bright blood red,
  about one beat every 0.8 s), draining with the clock. **Its icon: the bloodied low-health Doomguy** (IWAD `STFST40`,
  `STFST41`, `STFST42`), looking one way, ahead, the other way, about 0.2 s a frame. No skull, no gold: never mistaken
  for the Boss bar.
- Photosensitive Mode: the pulse at most once a second and dimmed, as the other bars.

## 9. The Boss arrival (owner, 2026-11-16 02:52-03:06)

- **The Boss health bar stays exactly as it is** (Miniboss `bossbar.zs`: the slant, the crowned skull, GUARD, the ×count,
  the clock, each thrall with its own crosshair and Champion icon). Owner 02:52: "let's not ditch our awesome miniboss
  healthbar". Do not restyle it.
- **New: a BOSS INCOMING! banner** at the arrival, before the bar's own arrival (`mockups/banners/BOSS_proposed_arrival_v3.png`):
  the crowned skull (`RSQMBHD`) and **BOSS INCOMING!** (RSSCFON, gold bands) punch in; then the chips pop in sequence:
  the Boss's name; **TIER n** with its colour swatch (the Boss's tier: world +2); **n THRALLS** shown with each thrall's
  own crosshair (`RSQMBX*`, in its colour) — the series has many crosshairs: use the ones the thralls actually carry;
  **FIGHT IN 03.00** with the seven-segment digits. Then it leaves. Moment name for the banner service: BOSSINCOMING
  (chips: name, tier, thralls, clock).
- **Clean species names** (owner 03:06): the bar's name today is the internal Species + " WARLORD", which shows code names
  to the player (DEMON1, PE, CYBIE, SPIDER1, VILE1, MMIND, BARONOFHELL, DAIKATANA). Fix: the player-facing monster name
  comes from the vanilla Doom monster the Colorful Hell class descends from or replaces (IMP, DEMON, SPECTRE, CACODEMON,
  PAIN ELEMENTAL, LOST SOUL, BARON, HELL KNIGHT, REVENANT, MANCUBUS, ARACHNOTRON, ARCH-VILE, CYBERDEMON, SPIDER
  MASTERMIND, ZOMBIEMAN, SHOTGUN GUY, CHAINGUNNER); a class with no vanilla ancestor uses its Tag, else its class name
  split into words without the RS_ prefix and colour. Then + " WARLORD". The same name on the bar and the banner.
## 10. LEVEL UP (owner, 2026-11-16 03:08: "good. let's move on")

Mockup `mockups/banners/LEVELUP_now_vs_proposed.png`. Today: VisualRewards' gold band sweeping across with LEVEL UP /
PLAYER LV n / +1 UPGRADE (`damnums/events.zs` Banner), and the gun's framed tag (PISTOL / LV n / NEW UPGRADE).
- **Player level up:** the grinning face (`STFEVL0`) + **LEVEL UP!** (gold bands) punch in; chips **★ PLAYER LV n**,
  **↑ +1 UPGRADE** (green) pop in sequence. No sweeping band.
- **Gun level up:** smaller, by the gun as today: a **PISTOL** chip (the gun's name), a big gold **LV n**, a green
  **↑ NEW UPGRADE** chip; the same pop.
- Gun Bonsai's upgrade picker (the cards) is a menu, not a banner: unchanged.

## 11. The SOTN letter animation on every banner (owner 03:08: "our usual SOTN style of character animations for these
and the other designs I approved")

The series' SOTN words (`design/mockups/sotn_words/mock.py`, owner 11-10; VisualRewards `words.zs`' sotn look): the
letters **smear in, snap upright, then flash between two looks**, each look two-toned (top half / bottom half). Every
banner headline in this doc (REVIVE, −1UP, +1UP, BOSS DEFEATED!, BOSS WINS!, BOSS INCOMING!, DOWN!, LEVEL UP!, the gun's
LV n) comes in that way, letter by letter, inside the banner's pop; its two looks are the headline's own bands and a
white-hot version of them. Photosensitive Mode: no flash between looks (the smear and snap stay). The chips keep the pop
of section 2. The mockup stills and GIFs do not show this; it is part of the design all the same.

- **Also important: sharp pixels.** Every in-game draw of these fonts and icons scales by whole numbers where it can and
  never smooths: the soft look of some mockup stills was the mockups' downscaling, not the font.

**Built by the banner lane (2026-11-16), its readings:** the mockups put the top stack at the top of the eye; in the
headset the HUD is a window round the gaze and Score's stack sits near its middle, so every banner is sized in eye units
(SlowMo's EyeMap) and placed at the mockup's spot or lower, clear under the stack (the invulnerability row always
counted). +1UP shows the plain 1UP (section 6: no plus). The −1UP's lives chip shows the faces greyed, "n LEFT". A
banner waits for the one before it (four at most waiting). Rig only, not headset-confirmed, all of it.

## Banner service contract (2026-11-16, shared by the two builders)

Every pack asks RSQ VisualRewards **by name**, never linked: `ServiceIterator.Find("RSQVR_Service")`, the class name
checked, then `GetInt("banner", "<MOMENT>|<chip>|<chip>...", 0, 0, playerPawn)`. No service, or an answer of 0 or -1
(the moment unknown): nothing else happens. The banners' own reading of it is in VisualRewards `service.zs`.

| MOMENT | Sent by, when | Chips (only what actually happened, real numbers) |
|---|---|---|
| `REVIVE` | SlowMo `down.zs` Revive: got up from DOWN | `health:+n`, `armor:+n`, `invuln:<secs>` (e.g. `5`, `1.5`), `mags:` (both held guns refilled) |
| `LIFEUSED` | Score `handler.zs` RunExtraLives: a Score life spent (a failed DOWN's, or a killing hit no monster dealt) | `lives:<left>`, `health:+n`, `invuln:5`, `mags:` |
| `LIFEUP` | Score `handler.zs` RunRewardCue: a life gained (Score's target, the life crate, another mod's "givelife") | `lives:<the new count>` |
| `BOSSWIN` | Miniboss `tierup.zs` TierUpOnKill: the miniboss killed by the player | `tierup:<the new world tier 1..13>` (left out when the tier cannot rise) |
| `BOSSLOSS` | Miniboss `tierup.zs` FightLost: a life spent in the fight, or the map left with it on (then on the next map, ~20 tics in) | `tierdown:<the new world tier>` (left out at tier 1), `nolegendary:` |
| `BOSSINCOMING` | Miniboss `bossfight.zs` StartArrival: once per fight, to the player who called it | `name:<the clean Boss name>` (Miniboss `bossbar.zs` BossNameOfClass, "<NAME> WARLORD", section 9), `tier:<the miniboss's tier, world + 2, at most 13>`, `thralls:<count>`, `clock:<seconds to the fight>` |

| `LEVELUP` | VisualRewards `damnums/events.zs` Banner (Gun Bonsai's `bonsai-level-up` 0) | `playerlv:<n>`, `upgrade:+1` |
| `LEVELGUN` | VisualRewards `damnums/events.zs` Tag (`bonsai-level-up` 1) | `gun:<name>`, `lv:<n>`, `hand:<0 main / 1 off>`, `upgrade:new` |

Toasts (PRESENTATION_GUIDE.md 5): `GetInt("toast", "<kind>|<text>", 0, 0, playerPawn)`, kind `health` / `armor` /
`invuln` / `ammo` / `lives` / `up` / `down` / `info`; 1 when shown, 0 (or no service): print the old way.

Chip kinds: `health`, `armor`, `invuln`, `mags`, `lives`, `tierup`, `tierdown`, `nolegendary` (and `name`, `tier`,
`thralls`, `clock` for BOSSINCOMING). A tier is sent as its number.

**Toasts** (PRESENTATION_GUIDE.md 5): `GetInt("toast", "<kind>|<text>", 0, 0, playerPawn)`, kind one of health, armor,
invuln, ammo, lives, up, down, info; 1 shown, 0 or no service: the caller prints its old centre print exactly as before.
Callers (2026-11-16): FlashFlare and Tactical Rig "No flares left" (ammo), Grenade "No grenades" (ammo), Tactical Rig
"Grenades: none" (ammo), "<region>: empty", "<region>: nothing here", "Torso recentered" (info), Distance Grab's fallback
word (info), the Saber's training remote short lines (info). Long setup and guidance text stays a centre print.

**Words over monsters** (PRESENTATION_GUIDE.md 4b): Miniboss sends BOSS DEFEATED! / ENEMIES TIER UP! (win) and BOSS WINS! /
ENEMIES TIER DOWN! (loss) over the monster only when its banner call answered 0 (no banners); TARGET! and GUARD! are one
size up (x1.5: the miniboss's TARGET! 1.2, a thrall's 0.75 / 0.5 in a window, GUARD! 0.75).

**The invulnerability bar reads** the player's PowerInvulnerable-family power and its `EffectTics` (nothing by name):
`RSQ_ScoreLifeInvul` (Score, a life spent, 175 tics) and `RSQSM_DownInvul` (SlowMo, REVIVE, the tier's seconds). Both are
given directly (no blend, no colormap) and run on real time.

**The DOWN panel's values** (SlowMo's `RSQSM_Service`, GetInt or GetIntUI, intArg the player): `down.count` (the DOWNs
since his last Score life spent, this one included while DOWN), `down.uphealth` (the health he gets up with, permille of
max: 1000 / 660 / 330), `down.owed` and `down.killed` (-1 when not DOWN), `down.left` (real tics on DEATH IN), `down` (1
while DOWN). The slow motion for a life: `start.reward` "life.used" (5 s, -1UP) / "life.up" (2.5 s, 1UP).

## 7. Built / not built (2026-11-16)

| Part | State |
|---|---|
| Arcade Gold banners and the chip pop | **Built, rig only, not headset-confirmed** (VisualRewards `rsqvr/banners.zs`, art `tools/gen_banners.py`): REVIVE, BOSS DEFEATED!, BOSS WINS! and every chip kind of the contract; the pop, the 4-tic chip steps, two to a row, the shrink and fade; the INVULNERABLE chip blinks and flies into the bar. Shown in the owner's full order with no script errors (only BD_VoxelPack's 4 voxeldef lines). rig frames `mockups/banners/rig/` `rig_REVIVE_handoff.png`, `rig_BOSS_DEFEATED_WINS.png`. Test: `netevent rsqvr_bntest 0..9` (sv_cheats) |
| 1UP / −1UP | **Built, rig only, not headset-confirmed**: the banded 1 and raised UP (pre-made from RSSCFON, `RQVBO*` / `RQVBU*`), the grin / OUCH grey faces, rays, the gold flash, wobble, squash, bob, the shine, sparkles, the float into Score's newest face (Score holds that face back until the badge lands: `banner.lives`); −1UP: hot for a beat, the minus slams in, red flash and shake, bands go cold and droop. `rig_1UP_float.png`, `rig_MINUS1UP.png` |
| Doomguy faces as life pips | **Built, rig only, not headset-confirmed** (Score `hud.zs` DrawLives): STFST01 faces in the old pips' place and step (11 units tall), the newest grins (STFEVL0) as it is gained, a spent one falls OUCH and grey. `rig_PIPS_fall_and_land.png` |
| The invulnerability bar | **The bar: built, rig only, not headset-confirmed** (VisualRewards `rsqvr/invbar.zs`): RQVBIE / RQVBIW (gen_gauges.py), 8 steps lo (70,8,60) / mid (255,40,190) / hi (255,205,245), the band, the breathing edge, the 16 x 16 orb RQVBII; its own row under SlowMo's (countdown.bottom, meter.*, hud.*), the Boss meter's width; full when it appears, draining over the real time left; held back while a chip flies to it, then flashes there; answers `invbar.bottom` (Score's rows go under it). `rig_INVBAR_drain.png`. The invulnerability it reads is built (rig only, not headset-confirmed): `RSQ_ScoreLifeInvul` (a life spent, 5 s) and `RSQSM_DownInvul` (REVIVE, 5 / 3 / 1 s), both PowerInvulnerable (contract below) |
| The slow motion reason line | Built; REVIVE, -1UP (ASCII minus), 1UP and BOSS / BOSS INCOMING built (SlowMo `clock.zs` CauseWord; rig: the reasons -1UP, 1UP, REVIVE logged) |
| "Boss" in player-facing words | Built for the reason words, the held words (BOSS DEFEATED!, BOSS WINS!) and the meter's wait line (No Boss: ...). Menus still say Miniboss (left as they are: "no system rewrite") |
| The life crate as the Boss's 1UP (gold, stays, floats back) | Built, rig only, not headset-confirmed (Score `lifecrate.zs`, Miniboss `tierup.zs` DropLifeCrate). The floating test: more than 64 units below the floor where it appeared, or outside the level, it floats back to that spot and hovers (a Boss dying in the air over a pit gives that pit's floor: not caught). Shown: dropped on the death spot, there 150 tics later, floating up 128 to a (simulated) ledge, +1 life on touch |
| +1UP with slow motion for a Score life | Built, rig only, not headset-confirmed (Score `handler.zs` RunRewardCue: LIFEUP for every life gained; 2.5 s world slow motion, reason 1UP, only for a life Score's own target pays) |
| The DOWN screen in Arcade Gold (section 8) | **Built, rig only, not headset-confirmed** (SlowMo `downhud.zs` DrawArcade; same place, size and timing): OUCH face + DOWN! (red bands, SOTN letters), BE QUICK OR BE DEAD (red letters, still breathing), the chips (n KILL(S) TO GET UP, the getting-up health read from `RSQSM_DownWatch.downs` / `RSQSM_Down.UpHealthShare`: 100 / 66 / 33 %, DEATH IN with the seven segments), TARGET chips, the blood-red pulsing bar (RSQSMHE / RSQSMHW, today's bar look) with the bloodied face STFST40-42. `rig_DOWN_entrance_settled.png` |
| BOSS INCOMING! banner (section 9) | **Built, rig only, not headset-confirmed**: RSQMBHD + BOSS INCOMING! (gold bands), name, TIER n + swatch, the thralls' RSQMBX crosshairs, FIGHT IN counting down; the banner stays until the clock is done. `rig_BOSS_INCOMING_fullorder.png` (a test name). Reading: `name:` sent empty is filled from RSQMB_Service GetObject "boss" (0) when that answers, else BOSS; `name:@<class>` gives that class's clean name; thrall colours are the mockup's unless sent as `thralls:n@RRGGBB,...` (the arrival's colours are not readable by name) |
| Clean Boss names on the bar and banner (section 9) | **Built, rig only, not headset-confirmed**: Miniboss `bossbar.zs` RSQMB_Handler.BossName / CleanName (vanilla ancestor or replacee, else the Species and class name by their words, else Tag, else the class name split without RS_ and colour) + WARLORD; the same rule in VisualRewards `bossname.zs` (keep in step). Only the name changed on the Boss bar. Not shown on a live Boss bar on the rig |
| LEVEL UP: player and gun (section 10) | **Built, rig only, not headset-confirmed** (damnums `events.zs` Banner / Tag ask the banners: LEVELUP, LEVELGUN; the old band and tag only with Banners off): the grin + LEVEL UP!, ★ PLAYER LV n, ↑ +1 UPGRADE; the gun: its name chip, a big gold LV n, ↑ NEW UPGRADE, placed at the gun's spot carried onto the HUD (my reading of "by the gun as today"), the small gun card hidden meanwhile (RSQGC "levelcard"). `rig_LEVELUP_toasts_gun.png` (Gun Bonsai's own `bonsai-level-up` event) |
| The SOTN letter animation on every banner headline (section 11) | **Built, rig only, not headset-confirmed**: every headline is RSSCFON letters as pictures (look + white-hot look: RQVBA/B, RQVBK/L, RQVBG/H; DOWN!: RSQSR/RSQSW), letter by letter 1.5 tics apart: smeared (four slices, slanted) for 7 tics, upright, then six changes of look 6 tics apart; the 1 and UP smear (their shine is the second look). Photosensitive Mode: no change of look, no white or red flash, no shake (`rig_PHOTOSENSITIVE.png`). Sharp pixels: headline letters and chip text take whole screen px a pixel at rest |
| Toasts (PRESENTATION_GUIDE.md 5) | **Built, rig only, not headset-confirmed**: RSQVR_Service GetInt "toast" "<kind>\|<text>" (health, armor, invuln, ammo, lives, up, down, info): one chip, the pop, ~1.5 s, low in the view and under a banner's chips; three at most. `rig_LEVELUP_toasts_gun.png` (test toasts) |
| Words over a monster never overlap, never on its bar (PRESENTATION_GUIDE.md 4b) | **Built, rig only, not headset-confirmed** (VisualRewards `words.zs`): every word on one monster (or one spot) gets its own line; they start above the HP bar and its markers (`RSQTHP_Bar` Pos + 14 px, + 36 x Cue with a crown / chain / skull). `rig_WORDS_stacked_over_bar.png` (THREAT! held, three one-off words on a zombieman with its bar) |
