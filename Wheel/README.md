<p align="center"><img src="../design/readme_art/mods/wheel_title.gif" alt="RSQ Wheel"></p>

# RSQ Wheel
### Changes 2026-11-23 (owner 08:08)
- **Off-hand alt-fire picks and the wheel stays open** (Off-Hand Alt-Fire Picks, on): the card under your off hand goes to
  your off hand and the wheel stays up, so you can change both hands in one go; either hand's fire picks and closes. This
  replaces the off-hand alt-fire's rotation toggle (into / out of next-prev). Code only, not run.
- **Hold Still While Open** (on): no moving in the game while the wheel is up (room-scale walking still works). Rig only, not
  headset-confirmed (wh2: frozen on while open, off when it closed).
- RSQ Grapple's hook cannot be fired while the wheel is open (rig wh1: "press ignored: RSQ Wheel is open").

## Doom Arcade VR · every gun you carry on a ring of cards, and the place where you decide which holster each lives in

<p align="right"><a href="../README.md#wheel">&larr; RSQ UBQ Series</a></p>

Press and hold, and your weapon slots stand in front of you as a ring of cards. Point at one and let go.

**What it does:**

- **One key does everything:** hold, point, release to pick; tap to leave the ring up; tap twice for your last gun ([How to play](#how-to-play))
- **Either hand picks** from the same ring, and with a card under each hand, each hand takes its own
- **Three ways to point:** a ray from your hand, the thumbstick, or reach in and touch the card
- **Pull a card out** by hand, or **throw a gun back** at the ring to go to your fists
- **Three ways round the wheel:** every weapon its own card, group only when crowded, or always group (the default: one card for each weapon slot; take a slot with several weapons and its weapons take the ring) ([The ring](#the-ring))
- **Guns turn on their cards:** a gun with a voxel or a model shows it, turning slowly; the rest show their pickup picture
- **A data sheet** in the middle for the gun you point at: ammo, reserve, kills, accuracy, damage, rate of fire, and what the gun shares ammo with ([The data sheet](#the-data-sheet))
- **Reads your upgrades:** Gun Bonsai level and upgrades, and a LegenDoom weapon's rarity, name and effects
- **Stops time while it is open** (Freeze Time While Open, on); turn that off and it slows the world through RSQ SlowMo instead
- **Keeps out of walls:** it slides, steps toward you and shrinks to fit
- **Kit yourself out:** with RSQ Tactical Rig, alt fire on a card and point at a holster, and that gun lives there ([The holster screen](#kit-yourself-out-the-holster-screen-with-rsq-tactical-rig))
- **Owns next and previous weapon,** so the list is the guns you chose ([Next and previous weapon](#next-and-previous-weapon))
- **Cards for the rest of the Series:** fists and gloves, sabers, the whip, the ShieldSaw, grenades
- **A wrist card** (off until you turn it on) and **Point at a Gun:** look at a weapon on the floor to read its sheet
- **Four fonts, two card looks** ([Fonts](#fonts), [Looks](#looks))

Three things make it more than a list of guns:

- **One key.** Hold, point and let go is the whole of it. A tap keeps the ring up, a double tap is your last gun, and
  either hand can do the picking.
- **The cards are things.** Reach into the ring and take one. Snap your hand back and the card comes out with it.
  Throw the gun in your hand at the ring and you are on your fists.
- **It tells you about your guns.** The sheet shows what the Wheel has watched each gun do: its damage, its hit
  rate, its kills. And with RSQ Tactical Rig, the same ring is where you give each gun its holster.

![The ring and its sheet, with a pistol that shares its ammo with the minigun](docs/readme/ring_and_sheet.png)

*[picture to come: the ring opening in the headset (GIF)]*

**Works on plain Doom II with nothing else loaded:** the slot cards, the sheet with ammo and the Wheel's own stats.
**While the ring is open the world is stopped and you stand still:** no walking, turning or firing until it closes.
Left alone it folds by itself after four seconds.

<p align="center"><img src="../design/readme_art/mods/wheel_divider.png" alt=""></p>

<a name="how-to-play"></a><img src="../design/readme_art/heads/wheel/how-to-play.gif" alt="How to play" height="44">

| Do this | What happens |
|---|---|
| Hold the wheel button (left thumbstick click), point a hand at a card, let go | That hand takes the gun. Let go over nothing and the ring just closes |
| The same on a slot's card ("3 WEAPONS"; Always Group) | The slot opens: its weapons take the ring, with BACK top left. The ring stays up; pick as after a tap |
| Push the stick all the way toward a slot's card and hold it there a moment | The slot opens. Pushed the same way into BACK: back to the slots |
| With a slot open, tap the wheel button | Back to the slots (the ring stays up; another tap closes it) |
| Tap the wheel button | The ring opens and stays up. Pull the trigger (either hand) on a card to take it |
| Tap it twice, quickly | The ring closes and the hand you last picked with goes back to the gun it had before |
| Reach a hand into a card and press Use | That hand takes the gun |
| Hand in a card, snap it back toward you | The gun comes out with your hand |
| Snap a hand holding a gun toward the ring, pointing at no card | The gun goes back on the ring; the hand takes its fist |
| Point at a card that hides more weapons, and wait (or press Use) | Its slot fans out, one card per weapon (Group When Crowded only) |
| Hold the trigger on a card in a fan, move it, let go | That gun takes the new place in its slot, and keeps it (fans: Group When Crowded only) |
| Main-hand alt fire on a card (with RSQ Tactical Rig) | The holster screen opens for that gun: your body with its six holsters |
| On the holster screen, pull the trigger on a holster | The gun flies into it: that holster is its home from now on |
| Off-hand alt fire on a card | That gun goes in or out of your next / previous weapon list |
| Turn more than 45° away from the ring | It swings round to sit in front of you again |
| Leave it alone | After 4 seconds with nothing pointed at, it fades, ticks once, and folds away |

### Controls

**One key: Open Wheel** (hold, point, release). It is bound to the **left thumbstick click** by default (a key already
bound to something else is left alone). It is on this mod's page under Controls and in Customize Controls, section
**RSQ Wheel**, as "Open Wheel (hold, point, release)".

- **The key:** hold, point, let go to take a gun (or open the slot you let go on); tap to leave the ring up; tap twice
  to go back to the last gun; with a slot open, one tap goes back to the slots.
- **The stick** points at a card; pushed all the way into a slot's card (or BACK) and held a sixth of a second, it opens
  that slot (or goes back). It must come back toward the middle before it can push again.
- **Either hand, trigger** on a card: take it; on a slot's card, open the slot; on BACK, the slots (hold it on a card in a
  fan to move that card).
- **Main hand, alt fire** on a card: the holster screen (with RSQ Tactical Rig). **Off hand, alt fire** on a card: that
  gun in or out of your next / previous weapon list.
- **Use** with a hand in a card: that hand takes the gun.
- **Gestures:** snap a hand in a card back toward you (the gun comes out with it); snap a hand holding a gun toward the
  ring (it goes back on the ring).
- Your own **next / previous weapon** keys step through the Wheel's list.

Gone on 2026-11-10 (owner: keys are precious in VR): **Wheel: open**, **Wheel: off hand** and **Wheel: main hand**, and
the `]` and `[` default binds. Their console commands stay, with no key and no menu row. The two ModelSwapper keys have
been off the controls list since 11-09, while ModelSwapper support is parked.

<p align="center"><img src="../design/readme_art/mods/wheel_divider.png" alt=""></p>

<a name="the-ring"></a><img src="../design/readme_art/heads/wheel/the-ring.gif" alt="The ring" height="44">

**The card you are on is the big one.** It grows to 2.2 times its size, and the three cards either side of it step
down, to 1.75, 1.45 and 1.2, before the ring is back to normal, so you can read what is next to your pick. No card leaves its place on the ring.

**Weapons Around the Wheel** has three choices (one row on the menu; Reset All sets it back to Always Group):

- **Always Group** (the default, as shipped since 2026-11-15). The ring opens on the slots: one card for each weapon slot
  (1 to 9, then 0) that holds a weapon you have, plus the fist's card. A slot with two or more weapons has one card, which
  shows **the gun you last had in a hand from that slot** (its picture or model, and its sheet when you point at it), the
  slot number in its corner as on every card, and **how many weapons it holds** as its name ("3 WEAPONS"). Take it
  (trigger, Use, let go of the wheel button on it, pull it out, or push the stick into it) and the ring becomes that
  slot's weapons in the slot's own order, with a **BACK** card first (top left). Inside a slot everything works as on the
  full ring: either hand picks, the off hand gets BD22 VR's off-hand version, the picked card is big with three steps
  down each side. A slot with one weapon is that weapon's own card, taken directly. Every opening starts on the slots.
  There are no fans, so no dragging; a slot keeps an order you dragged before.
- **Group When Crowded** (the ring before 2026-11-15). With up to **Group When Crowded: Own Cards Up To** weapons (10
  by default) every weapon has its own card and the ring grows to fit them. Past that, each weapon slot gets one card,
  so slot 4 is always in the same direction; a card that hides others shows a small "+N" in its corner. Point at it for
  a moment, or press Use while pointing, and the slot opens as a **fan** of cards stacked outward. The last gun you used
  comes first in its fan, and you can drag the rest into any order you like.
- **Every Weapon Its Own Card.** No grouping: one ring of every weapon you carry, each its own card, however many there
  are. With a big arsenal the ring is large (Keep Out of Walls still shrinks it to fit a narrow space).

A config from before 2026-11-17 with the old Group by Slot turned off moves once to what that ring did: Every Weapon Its
Own Card if its limit was 99, otherwise Group When Crowded at its own limit. A saved limit of 99 goes back to 10.

**Keep Out of Walls** (on by default). When the ring opens (and when it changes between the slots and a slot), rays
from its middle along its own plane find the walls, floor and ceiling round it, at its biggest (its radius plus the
picked card at full size); monsters and pickups do not count. A wall on one side: the ring slides away from it. Walls on
both sides closer than the ring is wide: it steps toward your eyes, never past halfway to you, and if the gap is still
too narrow there it shrinks to fit it (never below about a third of its size, 0.35) and stands in the middle. The same against the
floor and the ceiling. When the ring swings round to follow you it is fitted again where it lands (moved only). The
approach is RSQ VisualRewards' (its words do the same), copied into the Wheel.

**The cards.** Each card shows the gun's picture, its name, its slot number, its ammo and a bar for it. Where the
gun's pickup has a voxel or a model in your load order (BD_VoxelPack gives Brutal Doom's guns theirs), it turns slowly
on its card instead of a flat picture. A gun you are already
holding gets a corner mark. A card that is out of ammo rests in a colour that says so, and one running low pulses. The
card you point at steps toward you, grows a little, lights the room round it, and the others fade back. When you take a
gun, its card bursts into sparks and spins away as the ring folds.

**The fist is always there.** The fist's card sits on the ring whether or not you own a fist, and it gives the hand that
picked it that hand's own fist.

**Some things always go to one hand.** Either hand can pick them, but RSQ ShieldSaw's shield always ends up in your off
hand, and RSQ Saber's saber, RSQ Whip's whip and RSQ Grenade's grenade always in your main hand.

**Brutal Doom 22 VR's off-hand guns share one card.** Pick it with your main hand and you get the gun; pick it with your
off hand and you get its off-hand version.

**A gun with nothing to fire is not taken.** No rounds loaded, none in reserve, nothing for its alt fire: you hear Doom's
dry click and your hand keeps what it had. A gun with an empty magazine but rounds in reserve is still taken.

**Picking the gun your other hand holds.** If there is a second copy of it, that hand takes the copy and you hold one in
each hand. If not, the two hands swap.

**RSQ Grenade's kinds.** Rest on the grenade's own card (or press Use on it) and it opens a fan of every other
grenade kind you own, each in its own colour: pick one and you hold that kind. *Code only, not shown (2026-11-16):
until then the fan could not open on the default ring. The grenade's alt fire changes the kind too.*

**The Wheel's own icons.** A few cards would say little with their own pictures, so the Wheel draws its own: the fist,
the lightsaber, the whip, the ShieldSaw, the road flare and flashlight (RSQ FnF) and the Force hand (RSQ Saber). The
gloves wear RSQ Melee's own icons (the main glove's and the off glove's), and the Wheel's glove only when those are not
there.

<p align="center"><img src="../design/readme_art/mods/wheel_divider.png" alt=""></p>

<a name="the-data-sheet"></a><img src="../design/readme_art/heads/wheel/the-data-sheet.gif" alt="The data sheet" height="44">

A panel stands in the middle of the ring and describes the card you are pointing at, or the gun in your hand when you
point at nothing ("EMPTY" for an empty hand). Point at a gun lying on the floor and, after a moment, the same sheet
appears for it.

**It grows with the ring.** The more cards the ring holds, the wider the ring and the bigger the hole in its middle;
the sheet, text and all, grows to fill that hole and stops a gap short of the cards.

![The ring and its sheet, with a pistol that shares its ammo with the minigun](docs/readme/ring_and_sheet.png)

*Rig frame, 2026-11-06, in the JFO font. The default font is now RSQ Score's (see Fonts).*

What it can show, each only when there is something to say:

- the gun's name, in a band of its colour
- what is loaded and what is in reserve, and how many shots that is
- **SHARES:** the other guns you carry that eat the same ammo
- **HOLSTER:** where it lives on RSQ Tactical Rig
- **GUN BONSAI LV:** its level, progress and up to four upgrades by name (with Gun Bonsai and RSQ Gun Bonsai VR)
- **KILLS, SHOTS, ACCURACY:** counted by the Wheel itself for every gun you use, so it works with any weapon set; turn
  on **This Level's Kills** for a second row with this level's counts
- **LegenDoom:** the gun's rarity in LegenDoom's own colours, its legendary name, and its power in LegenDoom's own words

**Two Hands Compare** (off by default): point your other hand at a different card and the sheet turns into the two guns
side by side, the better numbers marked.

<p align="center"><img src="../design/readme_art/mods/wheel_divider.png" alt=""></p>

<a name="the-wrist-card"></a><img src="../design/readme_art/heads/wheel/the-wrist-card.gif" alt="The wrist card" height="44">

Off by default. Bring a forearm up across your chest as if checking a watch and hold it there a moment: a small card
stands over that wrist with the gun's name, its rounds, its kills and hit rate, and its Gun Bonsai level. Lower your arm
and it folds away. With RSQ Gun Cards loaded and its own watch card on, Gun Cards' card shows instead.

*[picture to come: the wrist card over the main-hand wrist]*

<p align="center"><img src="../design/readme_art/mods/wheel_divider.png" alt=""></p>

<a name="kit-yourself-out-the-holster-screen-with-rsq-tactical-rig"></a><img src="../design/readme_art/heads/wheel/kit-yourself-out-the-holster-screen-with-rsq-tactical-rig.gif" alt="Kit yourself out: the holster screen (with RSQ Tactical Rig)" height="44">

This is how you decide where every gun lives on your body, without ever leaving the fight for a menu.

**Main-hand alt fire on a card** opens a panel beside the ring: your marine with Tactical Rig's six gun holsters on him
as numbered rings (1 left shoulder, 2 right shoulder, 3 left chest, 4 right chest, 5 left hip, 6 right hip), in your
holster profile's colour. A ring that belongs to another gun shows that gun's name. Lines draw out from the card to the
rings.

- **Pull the trigger on a ring** and the gun flies into it: it is assigned to that holster and goes straight in. A gun
  that held that holster before loses it. A gun you are holding stays in your hand: only the holster is set, and the gun
  goes there the next time you holster it.
- **Clear** takes the gun's holster away, and takes the gun off the next and previous weapon list.
- **Alt fire on the same card again** closes the panel; on another card, it opens that card's.

Set **Web View** to **Mirror** and the panel shows Tactical Rig's own mirror of you instead, with the rings on your real
holster spots (your left on your left). With RSQ ShieldSaw worn over the shoulder, that shoulder shows the ShieldSaw and
takes no gun. Without RSQ Tactical Rig, main-hand alt fire on a card gives a dull tick and nothing else.

**How a card looks tells you where its gun lives:** a plain card is on the Wheel only; a card with a short gold light
running round its edge is in your next / previous list; a card sitting back on the ring, smaller and faded, outlined in
your profile's colour, has a holster.

*[picture to come: the holster screen, Marine view]*
*[picture to come: the holster screen, Mirror view]*
*[picture to come: a gun flying from its card into a holster ring (GIF)]*

<p align="center"><img src="../design/readme_art/mods/wheel_divider.png" alt=""></p>

<a name="next-and-previous-weapon"></a><img src="../design/readme_art/heads/wheel/next-and-previous-weapon.gif" alt="Next and previous weapon">

Your next / previous weapon keys (each hand's) step through one shared list, in slot order. A new game starts with
every gun on it. **Off-hand alt fire on a card** takes that gun off the list or puts it back; a gun with a holster is
never on it. With nothing on the list, the keys step through every gun, as Doom does.

<p align="center"><img src="../design/readme_art/mods/wheel_divider.png" alt=""></p>

<a name="fonts"></a><img src="../design/readme_art/heads/wheel/fonts.gif" alt="Fonts" height="44">

The ring's text now uses **RSQ Score's fonts**: **Score** (the default, its "SCORE:" lettering) or **Combo** (its smaller
combo font). The Wheel carries its own copies, so they work without RSQ Score loaded. The older sets are still there:
JFO, the status bar numerals, small gold or grey numerals, DoomFont only, and Ermac's digits.

![Four font sets on the same ring: JFO, Score, Combo, DoomFont](docs/readme/fonts_compared.png)

*Rig frames, 2026-11-09: JFO (top left), Score (top right), Combo (bottom left), DoomFont (bottom right).*

The holster screen's ring numbers are in RSQ Score's combo digits when RSQ Score is loaded, and JFO's big digits without
it.

<p align="center"><img src="../design/readme_art/mods/wheel_divider.png" alt=""></p>

<a name="looks"></a><img src="../design/readme_art/heads/wheel/looks.gif" alt="Looks" height="44">

- **Card Look.** **Colour by Gun** (the default) washes each card in its gun's colour, the same colour RSQ Gun Cards
  gives it, lit warm from the top, with a halo behind the card you point at and the series' lock-on mark at your
  pointer's tip. **Classic** is the plain ring.
- **Palette.** Standard, Doom (the status bar's reds and golds), Hell (embers and bone) or Tech (Doom 2's computer greens).
- **Ring Plates.** The Wheel's own plates (Ermac style) or the status bar's stone.
- **Extras, off by default:** a breathing halo, a spark running round each card's edge, and a starfield behind the ring.

<p align="center"><img src="../design/readme_art/mods/wheel_divider.png" alt=""></p>

<a name="plays-well-with"></a><img src="../design/readme_art/heads/wheel/plays-well-with.gif" alt="Plays well with" height="44">

- **RSQ Tactical Rig:** the holster screen, its Mirror view, and the HOLSTER row on the sheet.
- **RSQ SlowMo:** the ring slows the world while it is open. Slow motion you started yourself keeps running when the ring
  closes, unless you turn on **Closing Ends SlowMo**.
- **RSQ Gun Bonsai VR** (with Gun Bonsai): a gun's level and upgrades on the sheet and the wrist card.
- **RSQ Grenade:** a fan of your grenade kinds, and the grenade always goes to your main hand.
- **RSQ ShieldSaw, RSQ Saber, RSQ Whip:** each goes to its own hand, with its own icon; ShieldSaw's shoulder on the holster
  screen.
- **RSQ Gun Cards:** the cards take Gun Cards' gun colours, and its watch card replaces the Wheel's.
- **RSQ Laser Sight:** a hand whose gun draws a laser points at the ring along that laser, so you never see two beams.
- **RSQ Score:** the holster screen's ring numbers in its combo digits.
- **RSQ Accessibility:** Colour Blind Mode (every card neutral, only the one you point at coloured), Photosensitive Mode
  (the breathing and the edge sweep softer and slower), Slower Taps (more time for a hold or a double tap) and Steady
  Hands (a smoothed pointer). Seated Play puts the wrist card's pose at your seated eyes.
- **Brutal Doom 22 VR Reloaded:** one card for each gun and its off-hand version; Brutal Doom's own dry-fire click.
- **BD_VoxelPack:** the turning gun models on the cards.
- **RSQ Saber, RSQ ShieldSaw, RSQ Whip, RSQ Melee (with Gun Models on Cards):** their cards turn their own pack's model
  instead of the icon: the saber's hilt (the one at your hip), the shield, the coiled whip, and for the fist and the
  gloves RSQ Melee's FBX fist in your Hand Skin Tone (BD22 VR's), or the boxing glove while the gloves are worn. A pack
  that is not loaded leaves its card the icon. Code only, not shown on the rig yet.
- **LegenDoom:** rarity colours, legendary names and powers on the sheet.

**Other weapon mods are parked.** The Wheel has readers for DoomRL Arsenal, Doomablo, the Pandemonia family, Guncaster,
MetaDoom, BorderDoom, DOOM Infinite, Combined Arms, Final Doomer, ModelSwapper and Lithium. They are switched off for
now (the owner, 2026-11-09) and their options are hidden. Only Gun Bonsai and LegenDoom are read.

<p align="center"><img src="../design/readme_art/mods/wheel_divider.png" alt=""></p>

<a name="options"></a><img src="../design/readme_art/heads/wheel/options.gif" alt="Options" height="44">

*Radiant Silvergun Options → RSQ Wheel.* Everything is on one page; the fine-tuning numbers are under Test and Debug.
**Reset All** resets both pages.

| Section | Rows |
|---|---|
| (top) | Weapon Wheel (On) · Either Hand Picks (On) · Weapons Around the Wheel (Every Weapon Its Own Card / Group When Crowded / Always Group; Always Group) · Group When Crowded: Own Cards Up To (10 weapons) · Keep Out of Walls (On) · Opens On (Main hand / Off hand) · Sound (On) · Controller Rumble (1.0) · Size (1.0) |
| Controls | Open Wheel (hold, point, release; left thumbstick click) |
| Picking | Two Hands Compare (Off) · Open on Your Gun (Off) · Wrist Card (Off) · Open at Level Start (Off) · Slow Time While Open (On) · Closing Ends SlowMo (Off) · Freeze Without SlowMo (Off) · Freeze Time While Open (On) · Pull a Card Out (1.5) · Throw a Gun Back (2.6) · Reach In (7) · Feel Each Gun's Weight (1.0) |
| Look | Palette (Standard, Doom, Hell, Tech) · Ring Plates (Its own (Ermac style) / Status bar stone) · Card Look (Colour by Gun / Classic) · Web View (Marine / Mirror) · Gun Models on Cards (On) · Ammo Counts (On) · Ammo Readout (LED segments / Lozenge badge) · Rarity Colours (On) · Mark Guns You Hold (On) · Slot Numbers (On) · Cards Face You (On) · Hover Halo Breathes (Off) · Edge Sweep (Off) · Flash on Pick (On) · Spark Colour (Slot colour / White hot / Rainbow) · Hover Lights the Room (On) · Background Stars (0) |
| Data Sheet | Show Data Sheet (On) · Weapon Stats (On) · Track Kills and Accuracy (On) · This Level's Kills (Off) · Gun Bonsai Rows (On) · Point at a Gun (On) · Compare With Yours (Off) |
| Other Mods | LegenDoom Rarity (On) · LegenDoom Effects (On) |
| Test and Debug | Picking: Hold to Pick (9 tics), Double Tap (10 tics), Ring Follows Past (45°), Folds After (140 tics), Fold Warning (25 tics) · Ring: Ring Distance Ahead (34), Ring Radius (5), Height Above Hand (2), Lean Toward You (12), Wrist Roll Spins the Ring (0), Stick Deadzone (0.2), Card Width (4.2), Card Height (3.0), Hovered Card Steps Out (1.5), Hovered Card Grows (0.06), Other Cards Fade To (0.55), Cards Grow In (6 tics), Card Shadow (0.32), Shadow Offset (0.35), Idle Breathing (0.35), Breathing Speed (1.7), Low Ammo Below (0.25), Low Ammo Pulse (0.35), Model Turn Speed (1.5), Model Size (0.16), Model Stand-Off (3) · Cards: Fan Close Forgiveness (6 tics), Star Brightness (0.5), Light Size (44), Light Holds Across Gaps (3 tics), Sparks (18), Spark Speed (1.4), Volume (0.65), Idle Shimmer (0), Taken Card Spins (360°) · Data Sheet: Data Sheet Size (1.0), Pointing at a Gun: Rest For (18 tics), Wrist Card: Hold the Pose (8 tics), Wrist Card Size (0.6), Palette by Name · Debug Log (Off) |

**Weapon Wheel Off** stops the ring from opening and hands next / previous weapon back to the engine. **Freeze Without
SlowMo** only acts when RSQ SlowMo is not loaded; **Freeze Time While Open** stops
time whether SlowMo is loaded or not. Distances are in map units (34 to a metre; Inspect Within is in metres).

**Keys:** one, *Options → Customize Controls → RSQ Wheel → Open Wheel*. A default key that is already bound to
something else is left alone; bind it there instead. **Opens On** picks the hand the ring opens in front of (with
Either Hand Picks on, both hands still pick from it).

![Opens On: the ring in front of the main hand, then in front of the off hand](docs/readme/wheel_opens_main_then_off_hand.jpg)

*Opens On set to Main hand: the ring opens in front of the right hand, the PISTOL card in front (left); set to Off hand: in front of the left hand, the FIST card in front (right) (rig capture, not headset).*

<p align="center"><img src="../design/readme_art/mods/wheel_divider.png" alt=""></p>

<a name="status"></a><img src="../design/readme_art/heads/wheel/status.gif" alt="Status" height="44">

| | |
|---|---|
| **code only, not run (owner's call)** (2026-11-17) | **Weapons Around the Wheel:** the three choices (Every Weapon Its Own Card, Group When Crowded, Always Group), the Group When Crowded limit back at 10, config generation 32, and a slot's card named "N WEAPONS" ("1 WEAPON" for one). Not loaded, not on the rig, not in the headset |
| **rig only, not headset-confirmed** (2026-11-15, runs wsS2, wwall4A / wwall4B, wfinal; frames and logs in `docs/slots/`) | **Group by Slot:** with every gun given (31 guns on his settings), the ring opened on 10 cards (fist + slots 1-9; `docs/slots/ring_size_before_after.jpg`). The stick (rig controller, `qz_lstick`) pushed into slot 1: its 5 guns and BACK; the stick on the chainsaw and the take event (`wr_grab`, what the trigger sends; the rig's trigger makes no key event) gave the main hand the chainsaw; reopened, slot 1's card wore the chainsaw; a tap of the wheel key and the stick held on BACK each went back to the slots; the off hand pointed at the axe card (main hand pointed away) and took BD22 VR's RSQ_Off_BrutalAxe (`docs/slots/slot_flow.jpg`, `slot_flow_log.txt`). Holding the wheel key and letting go on the slot-4 card opened slot 4; Group by Slot off opened the old 31-card ring (wfinal). **Keep Out of Walls** (a test map loaded on the full order, not committed: a room and a 48-unit corridor): 15 units from a wall the slot ring slid 5.3, the 31-card ring 28.2; in the corridor the slot ring fitted as it was, the 31-card ring stepped 23.3 toward the eye and shrank to 0.76. The same spots with the old Wheel: the ring's half in the wall (`docs/slots/walls_before_after.jpg`, `walls_log.txt`). No script errors from our packs on his full order (wfinal). Not shown: a real trigger press on the rig, the ring in a gap narrower than the slot ring, the follow swing's refit |
| **rig only, not headset-confirmed** (2026-11-12, runs axp1 and axp2 with BD22 VR Reloaded 2.0.4r; `../TacticalRig/tools/rigtest/axepool/evidence/`) | **One axe card for both hands:** the card list (built as the ring builds it) holds BrutalAxe once, never RSQ_Off_BrutalAxe; the off hand picking that card got the off-hand axe, then the main hand picking it got the axe -- one in each hand at once. The picks went through the ring's own commit (resolvePick, commitAs) from a test event (`wr_test_cards`, `wr_test_pick:<class>`, `wr_debug 1` only, added 11-12); no hand pointed at a card |
| **rig only, not headset-confirmed** (2026-11-12; runs voxsize, wheelvox4) | The SMG, flamethrower, grenade launcher, rocket launcher and BFG10k show their models on their cards. Their voxels carry the same short names as Brutal Doom's pickup sprites and the size was being read from the sprite |
| **rig only, not headset-confirmed** (2026-11-12; run sheetgrow, every weapon given) | The data sheet grows with the ring |
| **rig only at 1.5 / 1.22 / 1.08 with one card forced, not headset-confirmed** (2026-11-12; run pickbig5). Shipped at 1.8 / 1.35 / 1.12, loads clean, not shown at those sizes; picking a card by hand was not managed on the rig | The picked card is the big one and its neighbours step down |
| **code only, not shown** (2026-11-11 22:10; loads clean on the full order, not run) | The data sheet is back in the middle of the ring (3616ed19's "closer" sheet reverted: pulled toward the eye it left the centre and shrank) and a third bigger at every Data Sheet Size (owner: "put it back where it was and make it bigger") |
| **code only, not shown** (2026-11-11 evening; loads clean on the full order, not run) | A card shows the pickup frame a gun really shows: the first Spawn state that lasts and draws something. BD22's pistol starts on a zero-tic frame of vanilla Doom's pistol (PIST A 0) before its own pickup (P3ST K), so its card drew the vanilla pistol; now it is BD's pistol pickup, like every other gun (owner: "use BD pistol pickup model in wheel for pistol") |
| **rig only, not headset-confirmed** (2026-11-11, rig batch R1, `design/rigtest_2026-11-10/RESULTS_R1.md`) | Start With Melee Hands on: ONE fist card in slot 1; a pick with the main hand gives RSQ_Glove, with the off hand RSQ_GloveOff (log; the hover was set by a probe, so aiming is not tested). 3D cards: the FBX fist in skin tone, the shield turning in place, the coiled whip, the saber as a thin rod turning in place in two frames (whether it reads as a hilt: judge in the headset) |
| **rig only, not headset-confirmed** (2026-11-11, the last checks, `design/rigtest_2026-11-10/RESULTS_LAST.md`) | **The glove cards, the gloves in slot 1 by RSQ Melee:** Start With Melee Hands on and a map load, no console addslot; slot 1 holds RSQ_Glove and RSQ_GloveOff; Open Wheel (`+wr_wheel`): two MELEE HANDS cards with Melee's RMICA0 / RMICB0 (`design/rigtest_2026-11-10/evidence/LAST_WHEEL_glove_cards_slot1.jpg`, `_log.txt`) |
| **rig only, not headset-confirmed** (2026-11-10 night, `design/rigtest_2026-11-10/RESULTS_FIX.md`) | **The glove cards wear RSQ Melee's icons:** both rings with the two MELEE HANDS cards showing Melee's RMICA0 / RMICB0, not the Wheel's WRIGLOVE (`design/rigtest_2026-11-10/evidence/FIX_3_wheel_glove_cards_RMIC.jpg`). **But** on the owner's order the gloves are not in any weapon slot, so the ring has no glove card at all: for that frame they were put in slot 1 from the console (`addslot 1 RSQ_Glove`; slot readout in `FIX_E_log.txt`). The owner decided: RSQ Melee now puts them in slot 1 (commit 18043e65; slot readout `FIX_3b_gloves_in_slot1_log.txt`) |
| **rig only, not headset-confirmed** (2026-11-10, the batched rig test, `design/rigtest_2026-11-10/RESULTS.md`) | Every launch on the owner's order (with BD22 VR Reloaded 2.0.4f) had no script error from our packs. The ring was not opened in them (the packed batch, next row, opened it) |
| **rig only, not headset-confirmed** (2026-11-10 night, the packed batch, N4: `design/rigtest_2026-11-10/RESULTS_P4.md`) | **Opens On:** hands 0.64 m apart, the Open Wheel key's command tapped: on Main hand the ring opened in front of the right hand, on Off hand in front of the left; a second tap closed it each time (`design/rigtest_2026-11-10/evidence/P4_N4_wheel_opens_on_main_then_off.jpg`, `P4_A_log.txt`). The key was sent as its command, not pressed |
| **rig only, not headset-confirmed** (2026-11-09, full series load order) | The Wheel loads with the rest of the series and its RSQ Wheel page appears under Radiant Silvergun Options, with no error from the Wheel in the log. Nothing of the ring itself was exercised in that run |
| **Headset-confirmed** | Nothing yet |
| **code only, not shown** (2026-11-11, owner's order "no rig test, code only until i say") | **3D models on the saber, shield, whip and fist cards** (Gun Models on Cards on): each card stands its own pack's world mesh, spawned by its class name so the pack's own MODELDEF draws it: RSQ Saber's UBQS_HipSaber (UBSP N), RSQ ShieldSaw's SSQ_Prop (SSQP A), RSQ Whip's RSQWP_Stowed (RSWP A), RSQ Melee's RSQ_Glove at its FBX fist (RMHF A) wearing BD22 VR's Hand Skin Tone, or its boxing glove (RMHG A) while Slappers Only or Boxing Gloves is on; the gloves' cards show the same. Without the pack, the icon. Sizes and centres measured from the meshes by `tools/measure_card_props.py` (`wr_CardProp`, `wr_q_vox.zs`). Not run: not built into a load-checked launch, no frame. Before: these cards kept their icon in 3D mode, because a card with the Wheel's own icon skipped the model (`spawnCardModels`), and their packs have no pickup voxel for the card to measure |
| **code only, not shown** | The 11-10 key change (one Open Wheel key; on the rig only its command was sent, above); the 11-09 evening fixes (Reset All covers Freeze Time and Web View, the ModelSwapper keys off the controls list, Freeze Without SlowMo on its own); everything else on this page |
| **not yet run** | Nothing from the rig test: N4 and the glove cards with the gloves in slot 1 by Melee have run (above) |

<p align="center"><img src="../design/readme_art/mods/wheel_divider.png" alt=""></p>

<a name="under-the-hood"></a><img src="../design/readme_art/heads/wheel/under-the-hood.gif" alt="Under the hood" height="44">

- **REMA's wheel on stock QuestZDoom 17.3.** The ring is presidentkoopa's RS_WeaponSelectionSystem from his UZDXREMA
  engine. Everything it asked of REMA's engine is redone in ZScript (`wr_q_shim.zs`): each card, label and bar is a
  model quad placed every tic, text is a strip of one-quad-per-character cells, and colour is a palette translation built
  at run time. Canvas textures were not used: on QuestZDoom 17.3 they draw black in VR.
- **The WAD's own art.** Card plates come from STBAR, words from DoomFont, numbers from the status bar numerals, all by
  lump name through TEXTURES (`tools/gen_assets.py`). Palettes (`WRPALS`) and font sets (`WRFONTS`) are lumps read by
  name, so any pk3 can add a palette and pick it with Palette by Name. The text is always the Wheel's own font
  (RSQ Score's, from the Wheel's own PNGs; owner 2026-11-18: "force the wheel to use it's own fucking font all the god
  damn time"): the Font row and Font Set by Name are gone and wr_fontset is not read.
- **Event handlers, in order:** `wr_Rig` (the ring), `wr_StatEvents` (the kill / shot / accuracy ledger),
  `wr_Watch` (the wrist card), `wr_BB` (lays out every quad after the ring moves them), `wr_VRState` (the pointer and
  the freeze).
- **Fire never shoots through the ring.** Trigger, alt fire and Use are caught in `InputProcess` only while a card or
  the holster panel is under a hand, and turned into `wr_*` network events.
- **Weapons Around the Wheel** (`wr_ring_layout`: 0 Every Weapon Its Own Card, 1 Group When Crowded, 2 Always Group,
  the default; `ringLayout()`). `gatherWeaponCards()` reads it on every build: 2 is Group by Slot below, 1 sets
  `mFansEnabled` when the weapons outnumber `wr_subcards_max`, 0 never collapses. The retired `wr_group_slots` is read
  once, by config generation 32, and nothing else.
- **Always Group / Group by Slot**: `mCardRole` says what each card is (a gun, a slot, BACK), `mSlotOpen` which
  slot is on the ring; `navigate()` rebuilds the ring for the other level through the same `rebuildPage()` a page flip
  uses, and every way of taking a card goes through `commit()`, so all of them open a slot. The stick's push is
  `tickStickPush()`; the stick's full reach is learned (the engine scales it by walk / run and the player class). The
  stick's two axes were swapped before (forward chose the card on the right); fixed. A fingertip resting in the data
  sheet no longer outvotes the stick.
- **Keep Out of Walls** (`wr_walls`): `solveAnchor()` places the ring once per opening, before its cards are made, and
  `fitToWalls()` slides it, steps it toward the eye or sets `mWallK`; everything sized by Size reads `ringSc()` (Size
  times `mWallK`), so a shrunk ring is the same ring, smaller. Rays: `wr_WallTracer`, a copy of VisualRewards'
  `RSQVR_WallTracer`.
- **Pointing:** each hand's ray, one-to-one with the controller; a hand holding an RSQ Laser Sight gun points along the
  line Laser Sight publishes (`RSQLS_SightService`). Hand speeds and the wrist pose are measured in true proportions
  (the engine's pixel stretch put back), at 34 units a metre.
- **Rumble** goes through the series' quake-wave route (RSQ ShieldSaw's buzzer), felt with `vr_quake_haptic_level`
  above 0; at 0 every card gets the engine's same flat pulse, so Feel Each Gun's Weight needs it.
- **Stats are counted, not read.** Damage, rate of fire and pellets live inside fire states, out of a script's reach,
  so `wr_stattracker.zs` watches the game: per gun instance, on a hidden ledger item the player carries, so a save keeps
  them. A kill goes to the hand that fired most recently, and to neither if it can't tell.
- **The series, by name.** Every other mod is reached through its service or class name at run time
  (`RSQTR_RigService`, `RSQSM_Service`, `RSQGB_Service`, `RSQGN_Service`, `RSQ_BD22OffhandService`,
  `RSQLS_SightService`, `rsqgc_*` and `rsqa_*` settings), so the Wheel loads and plays alone. The holster screen assigns
  and clears with Tactical Rig's `rsqtr_assign:<gun>` and `rsqtr_unassign:<gun>` events. Other mods can ask the Wheel
  through `wr_RigService` (is it open, which hand, where, which gun is pointed at).
- **What is kept:** the next / previous list rides on the player (`wr_RotTok`), so it lasts through levels and saves; your
  fan order is a setting (`wr_slot_order`) that Reset All leaves alone. Old configs are moved to new defaults once
  (`wr_cfgver`, generation 30).
- **Other-mod support is parked** in `wr_modsupport.zs`: every compat reader but LegenDoom's answers "off". The hidden
  setting `wr_unpark_mods 1` brings them back, for testing only. Most of those readers read another mod's fields by name,
  which needs REMA's engine; on QuestZDoom that read always answers "not there".
- **Not in the menu, on purpose:** REMA settings that do nothing on QuestZDoom 17.3 (the engine's own wheel, the room
  effects, painted card faces, the distance-field plate and its glow). Their settings stay so a config can still hold
  them.
- **Stock QuestZDoom 17.3:** ZScript and data only. No engine changes. Built for single player: the ring follows the
  console player only.

<p align="center"><img src="../design/readme_art/mods/wheel_divider.png" alt=""></p>

<a name="credits"></a><img src="../design/readme_art/heads/wheel/credits.gif" alt="Credits" height="44">

The full list, with every file and its source, is in **CREDITS.txt**.

- **presidentkoopa:** the wheel, RS_WeaponSelectionSystem, from his UZDXREMA engine and RS_VR_Unified; its sounds came
  across with it.
- **Ermac:** his Force Unleashed holo HUD art, which the ring's own plates and digits are drawn from (with the owner's
  blessing).
- **id Software:** the IWAD art the ring draws by name: STBAR, DoomFont, the status bar numerals.
- **RSQ Score's fonts**, carried from ijon's **Dakka**: the score-line font by **Blue Shadow** and the breakdown (combo)
  font by **Jimmy**.
- **JFO**, the JDUI font by **Zedas**, in the "JDUI Brutal Doom Ultimate Edition" edit by **Blackmore1014**.
- **LegenDoom** (Yholl and its contributors): the brass knuckles on the fist card.
- **danger_doughnut52** (dinopixel.com): the lightsaber card's pixel art.
- The whip, ShieldSaw, flare, flashlight, Force hand, gloves and padlock icons, the lock-on mark and the glow art are the
  series' own.
- **QuestZDoom** (Emawind and Team Beef): the engine, and the off-hand weapon and hand-pose API the ring reads.
