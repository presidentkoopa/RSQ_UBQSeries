# RSQoopaControls

The series' one controller profile, **RSQoopaControls** (the owner's name for it, 11:23: "call this RSQoopaControls"):
**the owner's own layout** (2026-11-27; his revised list of 10:31, built at 10:34, then his decisions of 10:49 to
11:17), in QuestZDoom 17.3's key names. The binds and the one setting are `design/controls/rsq_standard_controls.ini`
(the one source; the file keeps that path; the tables below are that file, line for line). **RSQ_Controls.pk3**
(`Controls/`, RSQ Controls, owner 2026-11-27 11:3x) is what sets the buttons; three ways in:

- **First launch:** the first time RSQ_Controls.pk3 loads, a yes / no screen offers the layout (`RSQCT_FirstRun`,
  `Controls/MENUDEF.txt`; the code in `tools/howtoplay/howto_template.zs`). Yes writes every ini line: the binds, the
  double-press binds and the `[CVars]` line, `vr_crouch_use_button=false`, natural crouch on. No, or Back, changes
  nothing. It asks once per layout: the CVar `rsqct_layout_asked` takes the layout's id (a CRC-32 of the ini's lines,
  not its comments, written by the generator as `LAYOUT_ID`) as the screen opens, so a change to any bind asks once more.
- **Any time: Options > Radiant Silvergun Options > Use RSQoopaControls**, right under How To Play: one press, a yes /
  no prompt, the same lines (how: `design/HOWTOPLAY_BUILD.md`). Only the buttons and the setting listed below change.
- **A console script: `Controls/RSQoopaControls.cfg`**, generated from the ini by `tools/howtoplay/gen_howtoplay.py`
  (`--check` fails while it is stale) and copied beside the pk3 into `pk3/` by the build: one line per ini line,
  `bind <Key> "<cmd>"` (`unbind <Key>` for an empty line), `doublebind` / `undoublebind`, `set <cvar> <value>`. It is
  not in the pk3: the console's `exec` opens a file on disk (`src/common/console/c_dispatch.cpp:1019-1029`,
  `FileReader::OpenFile` on the path), never a lump. In the QuestZDoom folder, `exec RSQoopaControls.cfg` in the console
  runs it once and the engine keeps the binds (saved at exit). On a command line, see "Active profile" below.

The layout is also in the game: How To Play's first tab, CONTROLS, draws it as the front README's table picture does,
its rows generated from the ini in the picture's own words (`design/readme_art/make_controls_table.py` WORD).

Nothing here has been run in a headset; RSQ Controls, the .cfg and the CONTROLS tab are not compiled or run.

## The owner's words

### 2026-11-27, first list (verbatim; corrected later, see below)

> left controller: leftgrip, trigger, x, y, stick, stick in. these can be double pressed, or MODIFIER+press via
> holding RIGHTGrip. leftgrip IS a button, but also snaps to gun for Two Handing. leftgrip cannot be MODIFIER+pressed
> via rightgrip.
> right controller: trigger, a, b, stick, stick in. these can be double pressed, or alt+press via holding RIGHTGrip.
> RIGHTGrip is not a button.
> left trigger: offhand fire / modifier+left trigger: mainhand fire / left grip: (empty) / left grip 2x: toggle map /
> left stick: up down strafe leftright / left stick click in: Slowmo / MODIFIER: left stick click in: Crisis Dive /
> pad x: offhand next weapon / pad y: offhand prev weapon / pad y 2x: move mainhand weapon to offhand / MODIFIER + pad
> x: shieldsaw toggle / MODIFIER + pad y: GBOVR menu toggle /
> right trigger: mainhand fire / modifier+right trigger: offhand altfire / right grip: MODIFIER / right stick up: jump
> / MODIFIER+right stick up: quick grenade (BD or RSQ) / right stick down: duck (hold, not toggle) / MODIFIER+right
> stick down: reload both guns / drop mag (one gun) / pad a: use / MODIFIER+pad a: BD Dual / pad a 2x: slot 3 / pad b:
> (empty) / modifier + pad b: Main Menu / pad b 2x: move offhand weapon to mainhand / right stick click in: fire
> grapple / MODIFIER+right stick click in: Open Wheel / MODIFIER+R stick left: mainhand prev weapon / MODIFIER+R stick
> right: mainhand next weapon
>
> 10:08: "mainhand alt fire is modifier + rtrigger"

### What came after (design/README_PASS_STATUS.md, "Controls: owner decisions 2026-11-27 10:17-10:21", 10:17 to 11:10)

- 10:17, the triggers: "THERE IS ONE FUCKING MODIFIER! TWO FUCKING TRIGGERS!" Left trigger = off-hand fire, right grip
  + left trigger = off-hand alt fire; right trigger = main-hand fire, right grip + right trigger = main-hand alt fire.
  The right grip as the modifier is how QuestZDoom is built, not a choice.
- 10:21: "no fucking moving weapons between hands then. we'll use the fucking wheel every fuckign time we want to do
  this." (Pad y 2x and pad b 2x came back in his 10:31 list.)
- 10:22: "moving offhand saber into main hand with keypresses crashes the game anway, it's not supposed to move." So RSQ
  Saber must refuse `switchhand`; done at 11:0x (`+WEAPON.NOHANDSWITCH` on `UBQS_SaberBase`, not compiled). No button
  has `switchhand` now (10:59).
- 10:28: plain right stick left / right = snap turn (the engine does it; not rebound).
- 10:31, **his revised list** (the ini's source), as the coordinator's log records it (his own text of 10:31 is not
  in the repo): pad x = ShieldSaw toggle; pad y = use item ("we only need one"); modifier + pad x = map toggle;
  modifier + pad y = GBOVR menu toggle; left grip 2x = toggle map; pad y 2x = move mainhand weapon to offhand
  (`switchhand 1`); pad b 2x = move offhand weapon to mainhand (`switchhand 0`); pad a 2x = slot 3; right stick down =
  duck, held; snap turn by the engine; pad b and the left grip, pressed once: empty. Everything else as his first list with the triggers as at
  10:08 and 10:17.
- 10:32: "FIX THE TRIGGERS": modifier + left trigger = off-hand alt fire (as at 10:17).
- 10:34: "Build it". 10:40: "YOU ARE NOT ALLOWED TO INVENT CONTROLS STOP CHOPOSING FOR ME".
- 10:49: Recenter Torso on pad b (`rsqtr_recenter`); not on the left grip (every left-hand grab would recenter).
- 10:57 / 10:58: right stick up 2x = double jump; "double jump is already in code" (RSQ Grapple). No double-press line:
  the second press runs `+jump` again and Grapple reads it as a jump in the air.
- 10:59: "no more move gun to mainhand or offhand. wheel only." Pad y 2x and pad b 2x lose `switchhand`.
- 11:0x: the Glow In The Dark key is Randomize Look (`netevent rsqgd_randomize`).
- 11:06: pad y = next item (`invnext`), pad y 2x = map, right grip + pad y = use item (`invuse`), pad b 2x = Randomize
  Look.
- 11:08: map on pad y 2x only; left grip 2x and right grip + pad x emptied.
- 11:09: Gun Bonsai menu on right grip + pad x (`netevent bonsai-show-info`). Brutal Doom's extras not used; no
  previous item (cycle with next item).
- 11:10: "stick down 1x is kick, we have natural crouch in QZD"; "make sure it is on": right stick down = `+zoom`
  (Brutal Doom's kick); the ini's `[CVars]` line `vr_crouch_use_button=false`.
- 11:15 to 11:17: Brutal Doom's taunt on left stick click 2x and right stick click 2x (`brutaltaunt`): taunt during
  SlowMo, or on the way in on the grapple.
- 11:23: "stick click 2x, let's go. let's get these menus and how to play and default keybinds in. ... call this
  RSQoopaControls".
- 11:3x (the coordinator's relay): a new mod, RSQ Controls (`Controls/`, RSQ_Controls.pk3), holds How To Play (moved
  out of the 20 mods) and RSQoopaControls: the Options row and a first-launch yes / no screen.
- 11:33: "players never see the word FREE": an empty slot is a dash. The layout table goes in the game, as How To Play's
  first tab.

## The layout

Exactly the ini. Each cell: his words, the command, the key QuestZDoom sends. A dash: nothing there, the ini has no
line for it (owner 11:33: players see a dash for an empty slot, never "FREE"). "Right grip + press": hold the right grip (the modifier) and press. A double press is two presses within 571 ms
(`gzdoom src/common/console/c_bind.cpp:863-889`).

### Left hand (off hand)

<!-- TABLE LEFT -->
| Button | Press | Double press | Right grip + press |
|---|---|---|---|
| trigger | offhand fire: `+oh_attack` (Shift) | - | offhand alt fire: `+oh_altatk` (Alt) |
| grip | - (RThumb). It still steadies a gun with both hands; the mods still read it as the off grip | - (RThumb) | - |
| stick up / down | `+forward` (Axis2Plus) / `+back` (Axis2Minus) | - | - |
| stick left / right | strafe: `+moveleft` (Axis1Minus) / `+moveright` (Axis1Plus) | - | - |
| stick click | Slowmo: `rsqsm_toggle` (Space) | taunt (Brutal Doom's Offend): `brutaltaunt` (Space) | Crisis Dive: `rsqsm_dodge` (Home) |
| pad x | ShieldSaw toggle: `ssq_draw` (Pad_X) | - | Gun Bonsai menu: `netevent bonsai-show-info` (PgDn) |
| pad y | next item: `invnext` (Pad_Y) | map: `togglemap` (Pad_Y) | use item: `invuse` (PgUp) |
<!-- /TABLE LEFT -->

### Right hand (main hand)

<!-- TABLE RIGHT -->
| Button | Press | Double press | Right grip + press |
|---|---|---|---|
| trigger | mainhand fire: `+attack` (RTrigger) | - | mainhand alt fire: `+altattack` (LTrigger) |
| grip | THE MODIFIER: sends no key of its own | - | - |
| stick up | jump: `+jump` (MWheelUp) | double jump: no line; the second press is `+jump` again, RSQ Grapple's double jump | quick grenade (BD or RSQ): `+user1` (Axis8Plus) |
| stick down | kick: `+zoom` (MWheelDown). Crouch by crouching: natural crouch is on (`[CVars]`) | - | reload both guns / drop mag (one gun): `+reload` (Axis8Minus) |
| stick left / right | snap turn: QuestZDoom does it from the stick, not a bind | - | mainhand prev weapon: `weapprev` (Axis7Minus) / mainhand next weapon: `weapnext` (Axis7Plus) |
| pad a | use: `+use` (Pad_A) | slot 3: `slot 3` (Pad_A) | BD Dual: `+user3` (LThumb) |
| pad b | Recenter Torso: `rsqtr_recenter` (Pad_B) | Randomize Look (RSQ Glow In The Dark): `netevent rsqgd_randomize` (Pad_B) | Main Menu: `menu_main` (Backspace) |
| stick click | fire grapple: `+rsqgr_hook` (Enter) | taunt (Brutal Doom's Offend): `brutaltaunt` (Enter) | Open Wheel: `+wr_wheel` (Tab) |
<!-- /TABLE RIGHT -->

### The setting

<!-- TABLE CVARS -->
| CVar | Value | What it does |
|---|---|---|
| `vr_crouch_use_button` | `false` | Natural crouch on: the view height follows the headset and you crouch by crouching. The engine's default is `true`, crouch by button (gzdoom `src/common/rendering/hwrenderer/data/hw_vrmodes.cpp:122`; read at `hw_openxrdevice.cpp:160-171`, `:574-583`; QuestZDoom `VrCommon.h:18`). Saved in the config's `[GlobalSettings]` (`CVAR_ARCHIVE` with `CVAR_GLOBALCONFIG`, `src/gameconfigfile.cpp:987-989`) |
<!-- /TABLE CVARS -->

Facts that come with it (engine code, not questions):

- **A double press runs the single press first.** The engine's doublebind runs the normal bind on the first press and
  the double line only on the second (`c_bind.cpp:863-889`): pad y 2x runs next item, then the map; pad a 2x runs Use,
  then slot 3; pad b 2x runs Recenter Torso, then Randomize Look; left stick click 2x turns SlowMo on, then taunts
  (SlowMo stays on: the second click runs only the taunt); right stick click 2x fires the hook, then taunts (the hook
  stays out).
- **An empty or missing double line falls back to the normal bind** (`c_bind.cpp:892-896`). So right stick up 2x is
  two `+jump` presses (the double jump is RSQ Grapple's: a fresh jump press in the air, `Grapple/zscript/rsqgr/core.zs:1145-1161`,
  Double Jump Always on by default), and left grip 2x, empty both ways, does nothing.
- **The left grip** sends no command, single or double, but every press is still read by the mods as the off grip (key
  443): the Rig's holsters, Melee's Headlock, FlashFlare, Distance Grab, BD22 VR's reload grab. It has no right grip + press while
  `vr_two_handed_weapons` is on (its default; `VrInputDefault.cpp:480-483`).
- **Right grip + left stick** sends Axis5 / Axis6 and the thumb rests (Quest only) send Joy5 to Joy8: no ini line, so
  the profile leaves them as they are.
- **The menu button** (left hand) is Escape, the engine's menu, not a bind (`VrInputDefault.cpp:48-49`).
- **The profile sets one setting**, `vr_crouch_use_button`. It assumes `vr_secondary_button_mappings` and
  `vr_two_handed_weapons` at their defaults (on, `hw_vrmodes.cpp:118-119`) and does not write them.
- **Gun Bonsai's menu**: the bind is `netevent bonsai-show-info`, the event Gun Bonsai's own key sends (shown working
  on the rig, `design/rigtest_2026-11-10/RESULTS_GBOVR.md:12`). GBOVR's info screen looks for a key bound to exactly
  `bonsai-show-info` (`GunBonsaiOffhandVR/rsq/ui/menus.zs:271-280`) and does not see this bind.
- **RSQ Wheel's own default** is `defaultbind LThumb +wr_wheel` (`Wheel/KEYCONF:35`); on QuestZDoom LThumb is right grip
  + pad a, here BD Dual. In RSQoopaControls Open Wheel is right grip + right stick click (Tab). `Wheel/README.md` says
  both (its How to play row and a line under its Keys table).
- **The taunt** (`brutaltaunt`, both stick clicks 2x) is Brutal Doom's Offend key: `alias brutaltaunt "pukename
  BDweaponActions always 1"` (BD `KEYCONF.txt:57-59`); the weapon's Taunt state (BD22 VR `actors/Weapons/DEFAULTWEAPON.dec:601-610`):
  the middle-finger sprite (`FUCK`, `VUCK` when playing as Purist), the `VoiceTaunt` voice line and `A_AlertMonsters`.
  It plays in the main hand.

## How QuestZDoom 17.3 makes the keys (from source)

Sources: QuestZDoom's Android wrapper `emawind84/questzdoom` at `a85c819`
(`Projects/Android/jni/QzDoom/VrInputDefault.cpp`, called from `QzDoom_OpenXR.cpp:397-416`) and the engine
`emawind84/gzdoom` tag `qzd17.3` (`9afc750`). Right-handed (`vr_control_scheme` 0): main = right, off = left, A / B on
the main hand, X / Y on the off hand (`QzDoom_OpenXR.cpp:404-407`). Left-handed (10) swaps the hands; the key names stay
with the hand's role (`QzDoom_OpenXR.cpp:409-414`). The PC VR build sends the same names for these buttons
(`gzdoom src/rendering/gl/stereo3d/gl_openvr.cpp:1618-2260`, no thumb rests).

- **The modifier** is the main (right) grip while `vr_secondary_button_mappings` is on (default on,
  `hw_vrmodes.cpp:118`): held, it sends no key itself and each other button sends a second key name
  (`VrInputDefault.cpp:51-55`, `:367-372`). With it off there is no modifier and the main grip is key 446 (LTrigger).
- **The left grip with the modifier** sends DPadUp (436) only while `vr_two_handed_weapons` is off (default on,
  `hw_vrmodes.cpp:119`; `VrInputDefault.cpp:480-483`). The left grip also starts the two-hand steadying within 50 cm
  (`VrInputDefault.cpp:131-142`).
- **A double press** is GZDoom's doublebind: the second press of a key within 571 ms runs its `DoubleBindings` line;
  **the first press runs the normal bind** (`gzdoom src/common/console/c_bind.cpp:863-889`; called for the game at
  `g_game.cpp:1130-1158`). An empty double line falls back to the normal one (`c_bind.cpp:892-896`). Saved in the ini
  as `[Doom.DoubleBindings]` (`gameconfigfile.cpp:811`, `:972`).
- **The menu button** (left hand) is Escape, the engine's menu, not a bind (`VrInputDefault.cpp:48-49`).
- **Turning** is the main stick left / right without the modifier, done by the wrapper (`VrInputDefault.cpp:263-303`),
  not a bind. **Walking** is the off stick, done by the wrapper (`:239-260`); the stick also sends Axis1 / Axis2 keys.
- **Crouching**: with `vr_crouch_use_button` false the engine sets the player's crouch from the headset's height every
  frame (`hw_openxrdevice.cpp:574-579`) and the view height follows the headset (`:160-163`); with it true (the
  default) crouch is a button (`hw_vrmodes.cpp:122`).

| Hand | Button | Key name (code) | Without the modifier | With the modifier | Engine default (Layout "QZD Dual Wield") |
|---|---|---|---|---|---|
| main | trigger | RTrigger (447) / LTrigger (446) | `:338-341` | `:378-381` | `+attack` / `+altattack` (commonbinds.txt:22-23) |
| main | A | Pad_A (448) / LThumb (442) | `:344-347` | `:384-387` | `+use` / `crouch` (:18, :32) |
| main | B | Pad_B (449) / Backspace (14) | `:350-353` | `:390-393` | `+jump` / `menu_main` (:19, :15) |
| main | stick click | Enter (28) / Tab (15) | `:356-359` | `:396-399` | `invuse` / `togglemap` (:5, :7) |
| main | thumb rest (Quest only) | Joy5 / Joy6 | `:362-365` | `:402-405` | none |
| main | grip | LTrigger (446) only with the modifier setting off | `:369-372` | is the modifier | `+altattack` |
| main | stick up / down | MWheelUp / MWheelDown (and Axis4Plus / Axis4Minus) | `:311-320`, `:516-524` | Axis8Plus / Axis8Minus `:556-564` | `weapprev` / `weapnext` (:10, :9); `weapprev 1` / `weapnext 1` (defbind1.txt:4-5) |
| main | stick right / left | turning (MWheelLeft / MWheelRight only with snap turn 0; Axis3 always) | `:263-331`, `:496-504` | Axis7Plus / Axis7Minus `:536-544` | `switchhand 0` / `switchhand 1` (defbind1.txt:6-7) |
| off | trigger | Shift (42) / Alt (56) | `:413-416` | `:451-454` | `+oh_attack` / `+oh_altatk` (defbind1.txt:9, :8) |
| off | X | Pad_X (450) / PgDn (209) | `:419-422` | `:457-460` | `invuse` / `invprev` (commonbinds.txt:21, :13) |
| off | Y | Pad_Y (451) / PgUp (201) | `:425-428` | `:463-466` | `togglemap` / `invnext` (:20, :12) |
| off | stick click | Space (57) / Home (199) | `:431-434` | `:469-472` | `+use` / `land` (:7, :14) |
| off | thumb rest (Quest only) | Joy7 / Joy8 | `:437-440` | `:475-478` | none |
| off | grip | RThumb (443) / DPadUp (436, two-handed off only) | `:442-445` | `:480-483` | `+speed` (defbind1.txt:10) / `togglemap` (commonbinds.txt:29) |
| off | stick | Axis1 / Axis2 Plus, Minus | `:486-514` | Axis5 / Axis6 `:526-554` | `+moveright` `+moveleft` `+forward` `+back` (:34-37) / none |

Line numbers in the two "modifier" columns are `VrInputDefault.cpp`. The defaults: new players get Layout 1 ("QZD
Dual Wield", `cl_defaultconfiguration` 1, `c_bind.cpp:783`): `wadsrc/static/engine/vr/commonbinds.txt` then
`engine/vr/defbind1.txt` (`c_bind.cpp:738-815`). The same menu offers Layout 3 "QZD Koopa" (`menudef.txt:524-533`),
`engine/vr/defbind3.txt`: "thanks to President_Koopa for providing the layout". Key codes: `keydef.h:18-136`.

The mods' raw grip codes agree: 446 is LTrigger (`keydef.h:131`), 443 RThumb (`:128`), 436 DPadUp (`:121`)
(`TacticalRig/CVARINFO.txt:8-9`, `DistanceGrab/CVARINFO.txt:45-46`, `Melee/CVARINFO.txt:89`, `FlashFlare/CVARINFO.txt:31`,
BD22 VR `rsr_grip_keys`). What that means with the modifier on: open question 1.

## Options > "Active profile" is not a keybind profile (QuestZDoom 17.3, from source)

Read in gzdoom `qzd17.3` (`9afc750`) and questzdoom `a85c819`; not run.

- **What it is:** the row `LabeledSubmenu "Active profile", "cmdlineprofile", "CommandLineProfileMenu"` in Options
  (`wadsrc/static/menudef.txt:393`; the empty page `:356-360`). Its entries are made when the menus are built
  (`src/menu/doommenu.cpp:1047-1063` `InitCommandLineProfileMenu`, called at `:1077`): one `cmdlineprofile "<name>"`
  command per profile, plus "No profile".
- **A profile is a command line file:** `commandline_<name>.txt` in the engine's folder, its `profiles/` folder or a
  `[FileSearch.Directories]` path (`src/menu/profiledef.cpp:32-64` `ProcessOneProfileFile`, `:66-121`
  `CollectProfiles`). If its first bytes are `#TITLE `, the rest of that line is the name shown (up to 50 characters,
  `:47-56`); otherwise the file's name after `commandline_`. QuestZDoom ships six (`assets/profiles/commandline_Doom.txt`
  and the others, copied by `java/com/drbeef/questzdoom/GLES3JNIActivity.java:288-293`).
- **Choosing one restarts the game with that command line:** setting `cmdlineprofile` (a saved global setting,
  `profiledef.cpp:13`; read back by `M_GetActiveProfile`, `src/m_misc.cpp:332-348`) drops `-iwad`, `-file`, `-deh` and
  the other file switches from the current command line and asks for a restart (`profiledef.cpp:13-28`). On the Quest
  the restart is a full app restart (`src/d_main.cpp:3930-3935`, `QzDoom_Restart`): the Java side copies
  `commandline_<name>.txt` over `commandline.txt` (`GLES3JNIActivity.java:111-115`) and starts again, reading
  `commandline.txt` with every line that starts with `#` skipped (`:303-318`). On PC the engine reads the profile's file
  itself (`src/d_main.cpp:1883-1913` `ParseCommandLineFile`; at start `:3780-3782`, which Android skips, and on restart
  `:3846`).
- **So it holds no binds.** A profile only changes which IWAD, files and command-line switches the game starts with.
  Binds live in the engine's ini (`[Doom.Bindings]`, `[Doom.DoubleBindings]`), which every profile shares.

**How a profile could run RSQoopaControls.cfg on start.** The command line does take console scripts and commands:
`-exec <file>.cfg` (`src/d_main.cpp:2103` `CollectFiles("-exec", ".cfg")`, `:3259` `GatherFiles("-exec")`) and any `+`
command (`src/common/console/c_dispatch.cpp:867-895` `C_ParseCmdLineParams`; `+exec <file>` is parsed there and then,
`:989-996`). But both run at `src/d_main.cpp:3349-3354`, and two lines later `DoKeySetup` (`:3356`;
`src/gameconfigfile.cpp:806-836`) calls `C_SetDefaultBindings`, which unbinds every key (`c_bind.cpp:818-822`), then reads
the saved binds: **every bind line of the .cfg is lost** (its `set` line runs before that and is not a bind). A `wait`
holds the rest of a command back (`c_dispatch.cpp:355-385`; `FWaitingCommand :70-85`) until the delayed commands run,
after `DoKeySetup` (`d_main.cpp:3594`, then every game tic, `src/g_game.cpp:1430`). So the line to add to a profile's
`commandline_<name>.txt` (with `RSQoopaControls.cfg` in `/sdcard/QuestZDoom`, the folder QuestZDoom starts in,
`QzDoom_OpenXR.cpp:249`) is:

    +wait 1;exec RSQoopaControls.cfg

(`wait` in lower case, `c_dispatch.cpp:355`; the arguments after `+wait` up to the next `-` or `+` make one command,
`c_dispatch.cpp:867-895`.) The file's first lines say the same. Not needed for the binds to stay: one `exec` from the
console, or the Options row, is saved in the ini at exit (`gameconfigfile.cpp:968-978`).

## Every ini line: where its command is defined

<!-- TABLE -->
| Section | Key | Command | What it does | From | Defined at |
|---|---|---|---|---|---|
| Bindings | Shift | `+oh_attack` | Off hand fire | QuestZDoom | gzdoom `src/d_main.cpp:2730` |
| Bindings | Alt | `+oh_altatk` | Off hand alt fire. RSQ Tactical Rig's keyring watches for it (`TacticalRig/zscript/rsqtr/keyring.zs:56`) | QuestZDoom | `src/d_main.cpp:2750` |
| Bindings | RThumb | (empty) | Nothing (owner: left grip empty; it still steadies a gun with both hands) | owner | `VrInputDefault.cpp:131-142`, `:442-445` |
| Bindings | Axis1Plus | `+moveright` | Strafe right (the stick itself walks you) | QuestZDoom | `src/d_main.cpp:2744` |
| Bindings | Axis1Minus | `+moveleft` | Strafe left | QuestZDoom | `src/d_main.cpp:2742` |
| Bindings | Axis2Plus | `+forward` | Walk forward | QuestZDoom | `src/d_main.cpp:2739` |
| Bindings | Axis2Minus | `+back` | Walk back | QuestZDoom | `src/d_main.cpp:2729` |
| Bindings | Space | `rsqsm_toggle` | Slow motion on / off | RSQ SlowMo | `SlowMo/KEYCONF.txt:1` |
| Bindings | Home | `rsqsm_dodge` | Crisis Dive | RSQ SlowMo | `SlowMo/KEYCONF.txt:4` |
| Bindings | Pad_X | `ssq_draw` | ShieldSaw: into the off hand, or back to the previous weapon; in flight, call it home (owner 10:31) | RSQ ShieldSaw | `ShieldSaw/KEYCONF.txt:8` |
| Bindings | Pad_Y | `invnext` | Next item: selects the next item in the inventory (owner 11:06) | QuestZDoom | `src/g_game.cpp:496` |
| Bindings | PgDn | `netevent bonsai-show-info` | Gun Bonsai's info screen: status and level-ups (owner 11:09) | Gun Bonsai (GBOVR) | `src/events.cpp:2433` (netevent); the event: `design/rigtest_2026-11-10/RESULTS_GBOVR.md:12` |
| Bindings | PgUp | `invuse` | Use item: uses the selected item (owner 11:06) | QuestZDoom | `src/g_game.cpp:525` |
| Bindings | RTrigger | `+attack` | Main hand fire | QuestZDoom | `src/d_main.cpp:2736` |
| Bindings | LTrigger | `+altattack` | Main hand alt fire (owner 10:08) | QuestZDoom | `src/d_main.cpp:2741` |
| Bindings | MWheelUp | `+jump` | Jump; pressed again in the air, RSQ Grapple's double jump (owner 10:57-10:58) | QuestZDoom; RSQ Grapple | `src/d_main.cpp:2726`; `Grapple/zscript/rsqgr/core.zs:1145-1161` |
| Bindings | Axis8Plus | `+user1` | Quick grenade: Brutal Doom's Toss Grenade, or RSQ Grenade's Quick Grenade when it is loaded | Brutal Doom, RSQ Grenade | `src/d_main.cpp:2737`; BD `KEYCONF.txt:36`, `src/Inputs.acs:347-353`; `Grenade/zscript/rsqgn/hand.zs:750` |
| Bindings | MWheelDown | `+zoom` | Kick (owner 11:10) | Brutal Doom, BD22 VR Reloaded | `src/d_main.cpp:2728`; BD `KEYCONF.txt:23`, `src/Inputs.acs:333-339`; BD22 `actors/Weapons/DEFAULTWEAPON.dec:390-391` (DoKick on the Zoom label) |
| Bindings | Axis8Minus | `+reload` | Reload both guns; with one gun, drop the magazine (the hand reload) | Brutal Doom, BD22 VR Reloaded | `src/d_main.cpp:2732`; BD `KEYCONF.txt:26`, `src/Inputs.acs:340-346`; BD22 VR `zscript/rsq/flick.zs:53`, `zscript/rsr/vreload.zs:3-9` |
| Bindings | Axis7Minus | `weapprev` | Main hand: previous weapon | QuestZDoom | `src/g_game.cpp:447` |
| Bindings | Axis7Plus | `weapnext` | Main hand: next weapon | QuestZDoom | `src/g_game.cpp:414` |
| Bindings | Pad_A | `+use` | Use | QuestZDoom | `src/d_main.cpp:2757` |
| Bindings | LThumb | `+user3` | Dual Wield: a copy of the main gun in the off hand, or the fist back (RSQ Saber: second saber away / out) | Brutal Doom, BD22 VR Reloaded | `src/d_main.cpp:2752`; BD `KEYCONF.txt:41`, `src/Inputs.acs:361-367`; BD22 VR `zscript/rsq/dual.zs:447-451` |
| Bindings | Pad_B | `rsqtr_recenter` | Recenter Torso: turns the torso and its holsters to where the head faces (owner 10:49) | RSQ Tactical Rig | `TacticalRig/KEYCONF.txt:3-5`; `rig.zs:800-805` |
| Bindings | Backspace | `menu_main` | The main menu | QuestZDoom | `src/menu/doommenu.cpp:1476` |
| Bindings | Enter | `+rsqgr_hook` | Fire the grapple hook | RSQ Grapple | `Grapple/KEYCONF.txt:7-8` |
| Bindings | Tab | `+wr_wheel` | Open Wheel: tap to open, tap to close; twice quickly, the last gun back | RSQ Wheel | `Wheel/KEYCONF:28-29` |
| DoubleBindings | Space | `brutaltaunt` | Brutal Doom's Offend taunt: the middle finger, a voice taunt, monsters alerted (owner 11:15-11:17) | Brutal Doom, BD22 VR Reloaded | BD `KEYCONF.txt:57-59`; BD22 VR `actors/Weapons/DEFAULTWEAPON.dec:601-610` |
| DoubleBindings | Enter | `brutaltaunt` | The same taunt, on the right stick click (owner 11:15-11:17) | Brutal Doom, BD22 VR Reloaded | BD `KEYCONF.txt:57-59`; BD22 VR `actors/Weapons/DEFAULTWEAPON.dec:601-610` |
| DoubleBindings | RThumb | (empty) | Nothing: falls back to the single press, also empty (owner 11:08) | owner | `c_bind.cpp:892-896` |
| DoubleBindings | Pad_Y | `togglemap` | The automap (owner 11:06, 11:08) | QuestZDoom | `src/am_map.cpp:261` |
| DoubleBindings | Pad_A | `slot 3` | Weapon slot 3 (the shotguns) | QuestZDoom | `src/g_game.cpp:352` |
| DoubleBindings | Pad_B | `netevent rsqgd_randomize` | RSQ Glow In The Dark's Randomize Look: a whole new look now, Profile set to Custom (owner 11:0x, 11:06) | RSQ Glow In The Dark | `src/events.cpp:2433` (netevent); `GlowInTheDark/MENUDEF.txt:126`, `GlowInTheDark/zscript/rsqgd/handler.zs:828` |
| CVars | vr_crouch_use_button | `false` | Natural crouch on (owner 11:10) | QuestZDoom | `src/common/rendering/hwrenderer/data/hw_vrmodes.cpp:122` |
<!-- /TABLE -->

Paths: `src/...` without a mod name and `player.zs` (`wadsrc/static/zscript/actors/player/player.zs`) are gzdoom
`qzd17.3`; the engine's button names are the list at `src/d_main.cpp:2722-2760`, registered at `:3736`. "BD" is
`brutal22test6.pk3` (`src/Inputs.acs` is the source of its `BD_Main` script, `src/BD_Main.acs:25`). "BD22 VR" is
`presidentkoopa/rsq_bd_vr_reloaded` `src/` at `edfaf63`. The grenade line serves both because RSQ Grenade reads this
button for its Quick Grenade and, with RSQ Grenade in play, BD22 VR stands its own grenade down
(`Grenade/zscript/rsqgn/hand.zs:708-709`, `:750`).

## Not in the layout

Not in the owner's layout, so the profile writes nothing for them; whatever the player has bound stays.

| Command | What it is |
|---|---|
| `+user2`, `+user4`, `AssaultRifleGrenade`, `flashlightswitch`, `DodgeRoll`, `roleft`, `roright`, `gztaunt`, `wave1`, `wave2`, `advtaunt`, `oneliner`, `slowmo` | Brutal Doom's Unload, Ammo Dropper, Underbarrel, Flashlight, rolls, its other taunts and its own slow motion (BD `KEYCONF.txt:29-80`). Not used by the owner (11:09; `brutaltaunt` came in at 11:15-11:17, above) |
| `invprev` | Previous item (`src/g_game.cpp:508`). Not needed: cycle with next item (owner 11:09) |
| `+speed` | Run; Brutal Doom's sprint (`src/d_main.cpp:2756`; BD `src/Inputs.acs:198`). Not bound. The engine had it on the left grip, which the owner leaves empty |
| `+crouch`, `crouch` | Crouch by button (`src/d_main.cpp:2748`). Natural crouch is on instead (`[CVars]` above; owner 11:10) |
| `switchhand`, `weapnext 1`, `weapprev 1` | Moving a weapon to the other hand and the off hand's next / previous weapon (`src/g_game.cpp:335`, `:414-420`, `:447-453`). Off-hand weapons are switched with RSQ Wheel only (owner 10:21, 10:59); no button has `switchhand` |
| `rsqgn_quickthrow` | RSQ Grenade's Quick Grenade key (`Grenade/KEYCONF.txt:3`); `+user1` above does the same (`Grenade/zscript/rsqgn/hand.zs:750`) |
| `land` | The engine's landing key (its default on right grip + left stick click, which is Crisis Dive here) |

## Open questions for the owner

1. **The right grip and the mods.** Your modifier needs `vr_secondary_button_mappings` on. Then the right grip alone
   sends no key (`VrInputDefault.cpp:51-55`, `:369-372`). The mods that read the main grip as key 446 (Tactical Rig's
   holsters, keyring, cigarette and saber spot; Distance Grab's main hand; `TacticalRig/CVARINFO.txt:8`) only get 446
   from **right grip + right trigger**, which is also main-hand alt fire. So holding the modifier at a holster does
   not holster, and alt fire at a holster does. How should the main grip reach those mods?
