# Controls map (owner 2026-11-27): the three layers

Owner: "my current ini needs to be dissected to establish controls for doom itself, brutal doom vr weapons, and RSQ
mods loaded." The series' control profile is now his own layout (his revised list of 10:31, built 10:34, then his
decisions of 10:49 to 11:17), named **RSQoopaControls** (owner 11:23): `design/controls/rsq_standard_controls.ini`
(the file keeps its path), explained line by line in `design/controls/CONTROLS.md`. Opt-in, from RSQ_Controls.pk3
(Controls/): its first-launch screen (once per layout), or Options > Radiant Silvergun Options > Use RSQoopaControls,
writes it, its binds and its one setting, `vr_crouch_use_button=false` (natural crouch on); `Controls/RSQoopaControls.cfg`
does the same from the console (design/KEYBINDS_PLAN.md: keys are precious in VR, and default binds were removed
11-10). The "RSQoopaControls" columns below are that ini; "not in the layout" = no line.
"RG +" = hold the right grip (the modifier) and press; "2x" = double press.

## Layer 2: Brutal Doom (brutal22test6.pk3, KEYCONF.txt)

BD22 VR Reloaded (src/KEYCONF.rsq, KEYCONF.rsqmoon) adds NO keys: only weapon slots (RSQ_Hands and RSQ_Off_BrutalAxe
on 1, Machinegun on 4, BrutalRevolver on 2). Every Brutal Doom key is the base pk3's.

| Section | Action | Command | Default bind (keyboard) | RSQoopaControls |
|---|---|---|---|---|
| Advanced Options | Kick | `+zoom` | Q | right stick down (MWheelDown) |
| | Reload | `+reload` | R | RG + right stick down (Axis8Minus) |
| | Flashlight | `flashlightswitch` | F | not in the layout |
| | Underbarrel | `AssaultRifleGrenade` | none | not in the layout |
| | Toss Grenade | `+user1` | G | RG + right stick up (Axis8Plus) |
| | Unload | `+user2` | none | not in the layout |
| | Dual Wield | `+user3` | X | RG + pad a (LThumb) |
| | Ammo Dropper | `+user4` | none | not in the layout |
| | Roll | `DodgeRoll` | none | not in the layout |
| | Roll Left | `roleft` | none | not in the layout |
| | Roll Right | `roright` | none | not in the layout |
| Interactions | Offend | `brutaltaunt` | H | left stick click 2x (Space), right stick click 2x (Enter) (owner 11:15-11:17): the middle finger, a voice taunt, monsters alerted (BD `KEYCONF.txt:57-59`; BD22 VR `actors/Weapons/DEFAULTWEAPON.dec:601-610`); plays in the main hand |
| | Taunt (GZDoom) | `gztaunt` | none | not in the layout |
| | Wave 1 | `wave1` | V | not in the layout |
| | Wave 2 | `wave2` | N | not in the layout |
| | Advanced Taunts | `advtaunt` | J | not in the layout |
| | One-Liners | `oneliner` | K | not in the layout |
| | Slow Motion | `slowmo` (rebinds itself to `slowmostop`) | none | not in the layout |

All defaults are keyboard letters: on a headset none of them is on a controller button unless a bind puts it there.
The rest of Brutal Doom's keys (Unload, Ammo Dropper, Underbarrel, Flashlight, the rolls, the other taunts, its slow
motion) are not used by the owner (11:09); Offend (`brutaltaunt`) came in at 11:15-11:17.
Still to do: which BD22 VR Reloaded still reads (its code), and which are dead in VR.

## Layer 3: the RSQ mods

### Keys (KEYCONF; rebindable)

RSQ Distance Grab has no keys any more (its KEYCONF.txt is gone, 2026-11-27).

| Mod | Key | Command | Default bind | RSQoopaControls |
|---|---|---|---|---|
| Wheel | Open Wheel | `+wr_wheel` | LThumb (only if LThumb is unbound; on QuestZDoom LThumb is RG + pad a) | RG + right stick click (Tab) |
| Grapple | Fire Hook | `+rsqgr_hook` | none | right stick click (Enter) |
| Grenade | Quick Grenade | `rsqgn_quickthrow` | none | not in the layout; `+user1` (RG + right stick up) does the same (`Grenade/zscript/rsqgn/hand.zs:750`) |
| ShieldSaw | Draw / Put Back | `ssq_draw` | none | pad x (Pad_X) |
| SlowMo | Slow motion on/off | `rsqsm_toggle` | none | left stick click (Space) |
| SlowMo | Crisis Dive | `rsqsm_dodge` | none | RG + left stick click (Home) |
| Tactical Rig | Recenter Torso | `rsqtr_recenter` | none | pad b (Pad_B) |
| Glow In The Dark | Randomize Look (a menu Command row, `GlowInTheDark/MENUDEF.txt:126`) | `netevent rsqgd_randomize` | none | pad b 2x (the first press runs Recenter Torso) |
| Grapple | Double jump (no key: a jump press in the air, `Grapple/zscript/rsqgr/core.zs:1145-1161`) | `+jump` | | right stick up 2x (no double-press line: the second press is `+jump` again) |
| Gun Bonsai VR | Display Info (Gun Bonsai's event) | `netevent bonsai-show-info` | none in this repo | RG + pad x (PgDn) |

### Raw key codes (NOT binds: read straight from the controller, set as text in each mod's options)

| Mod | Setting | Default | Meaning |
|---|---|---|---|
| Tactical Rig | `rsqtr_keys_main` / `rsqtr_keys_off` | 446 / 443 436 | main grip / off grip |
| Distance Grab | `rsqdg_keys_main` / `rsqdg_keys_off` | 446 / 443 436 | the same |
| Whip | `rsqwp_keys_main` / `rsqwp_keys_off` | 446 / 443 436 | the same |
| Melee | `rsqml_keys_off` | 443 436 | off grip |
| Flashlight & Flare | `rsqff_keys_off` | 443 436 | off grip |

446 KEY_PAD_LTRIGGER, 443 KEY_PAD_RTHUMB, 436 KEY_PAD_DPAD_UP (the off grip while the main grip is held), per
TacticalRig/CVARINFO.txt, which also says 446 holds "only with vr_secondary_button_mappings 0". The owner's layout
uses the right grip as the modifier, which needs that setting on (its default): then 446 comes only from RG + right
trigger (main-hand alt fire), and 436 not at all while `vr_two_handed_weapons` is on (CONTROLS.md, open question 1).
Still unknown: the owner's saved values of these five settings.

### Engine binds the mods watch for (by the text of the bind on the pressed key)

To do: list per mod from the code (`Bindings.GetBinding(e.KeyScan)` in ShieldSaw, Tactical Rig, Wheel, Whip,
Flashlight & Flare, Melee, Miniboss, Distance Grab): e.g. `+oh_attack`, `weapnext`, `weapprev`, `+use`.

## Layer 1: the engine and Doom itself

The owner's layout (the ini; CONTROLS.md has the key names and the source of every command):

| Command | What | RSQoopaControls |
|---|---|---|
| `+attack` / `+altattack` | main hand fire / alt fire | right trigger / RG + right trigger |
| `+oh_attack` / `+oh_altatk` | off hand fire / alt fire | left trigger / RG + left trigger |
| `+forward` `+back` `+moveleft` `+moveright` | walk, strafe | left stick (the stick itself moves you too) |
| `+jump` | jump; again in the air, RSQ Grapple's double jump | right stick up; right stick up 2x (no double-press line) |
| `brutaltaunt` (Brutal Doom) | taunt | left stick click 2x, right stick click 2x (the first click runs SlowMo / Fire Hook; the second only the taunt) |
| `+use` | use | pad a |
| `slot 3` | weapon slot 3 | pad a 2x (the first press runs Use) |
| `invnext` | next item | pad y |
| `togglemap` | the automap | pad y 2x (the first press runs next item) |
| `invuse` | use item | RG + pad y |
| `weapprev` / `weapnext` | main hand previous / next weapon | RG + right stick left / right |
| `menu_main` | the main menu | RG + pad b |
| turning | snap turn | right stick left / right (QuestZDoom, not a bind) |
| crouching | natural crouch: `vr_crouch_use_button` = false (the ini's `[CVars]`) | crouch for real |
| - (empty) | nothing | left grip (it still steadies a gun with both hands), left grip 2x |

Not in the layout (the player's own binds stay): `invprev` (not needed: cycle with next item, owner 11:09), `+speed`
(run / sprint, not bound), `+crouch` / `crouch` (natural crouch instead), `switchhand`, `weapnext 1` / `weapprev 1`
(off-hand weapons are switched with RSQ Wheel only, owner 10:59), `land`.
