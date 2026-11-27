# Controls map (owner 2026-11-27): DRAFT, two of three layers

Owner: "my current ini needs to be dissected to establish controls for doom itself, brutal doom vr weapons, and RSQ
mods loaded." Then a default control profile for the series is drafted from this map (opt-in; see
design/KEYBINDS_PLAN.md: keys are precious in VR, and default binds were removed 11-10).

STILL MISSING: the owner's ini (layer 1, and which physical button each command below is on).

## Layer 2: Brutal Doom (brutal22test6.pk3, KEYCONF.txt)

BD22 VR Reloaded (src/KEYCONF.rsq, KEYCONF.rsqmoon) adds NO keys: only weapon slots (RSQ_Hands and RSQ_Off_BrutalAxe
on 1, Machinegun on 4, BrutalRevolver on 2). Every Brutal Doom key is the base pk3's.

| Section | Action | Command | Default bind (keyboard) |
|---|---|---|---|
| Advanced Options | Kick | `+zoom` | Q |
| | Reload | `+reload` | R |
| | Flashlight | `flashlightswitch` | F |
| | Underbarrel | `AssaultRifleGrenade` | none |
| | Toss Grenade | `+user1` | G |
| | Unload | `+user2` | none |
| | Dual Wield | `+user3` | X |
| | Ammo Dropper | `+user4` | none |
| | Roll | `DodgeRoll` | none |
| | Roll Left | `roleft` | none |
| | Roll Right | `roright` | none |
| Interactions | Offend | `brutaltaunt` | H |
| | Taunt (GZDoom) | `gztaunt` | none |
| | Wave 1 | `wave1` | V |
| | Wave 2 | `wave2` | N |
| | Advanced Taunts | `advtaunt` | J |
| | One-Liners | `oneliner` | K |
| | Slow Motion | `slowmo` (rebinds itself to `slowmostop`) | none |

All defaults are keyboard letters: on a headset none of them is on a controller button unless the ini puts it there.
To do with the ini: which of these the owner has on a button; which BD22 VR Reloaded still reads (its code), and which
are dead in VR.

## Layer 3: the RSQ mods

### Keys (KEYCONF; rebindable)

| Mod | Key | Command | Default bind |
|---|---|---|---|
| Wheel | Open Wheel (hold, point, release) | `+wr_wheel` | LThumb (only if LThumb is unbound) |
| Grapple | Fire Hook | `+rsqgr_hook` | none |
| Grenade | Quick Grenade | `rsqgn_quickthrow` | none |
| ShieldSaw | Draw / Put Back | `ssq_draw` | none |
| SlowMo | Slow motion on/off | `rsqsm_toggle` | none |
| SlowMo | Crisis Dive | `rsqsm_dodge` | none |
| Tactical Rig | Recenter Torso | `rsqtr_recenter` | none |
| Distance Grab | Grab / pull (main hand), optional | `+rsqdg_main` | none |
| Distance Grab | Grab / pull (off hand), optional | `+rsqdg_off` | none |
| Accessibility | nine gesture buttons | `+rsqa_mod`, `rsqa_pull`, `+rsqa_reach`, `rsqa_fpush`, `rsqa_fpull`, `+rsqa_fgrip`, `rsqa_throw`, `rsqa_reload`, `rsqa_slowmo` | none |

### Raw key codes (NOT binds: read straight from the controller, set as text in each mod's options)

| Mod | Setting | Default | Meaning |
|---|---|---|---|
| Tactical Rig | `rsqtr_keys_main` / `rsqtr_keys_off` | 446 / 443 436 | main grip / off grip |
| Distance Grab | `rsqdg_keys_main` / `rsqdg_keys_off` | 446 / 443 436 | the same |
| Whip | `rsqwp_keys_main` / `rsqwp_keys_off` | 446 / 443 436 | the same |
| Melee | `rsqml_keys_off` | 443 436 | off grip |
| Flashlight & Flare | `rsqff_keys_off` | 443 436 | off grip |

446 KEY_PAD_LTRIGGER, 443 KEY_PAD_RTHUMB, 436 KEY_PAD_DPAD_UP (the off grip while the main grip is held), per
TacticalRig/CVARINFO.txt, which also says 446 holds "only with vr_secondary_button_mappings 0". To do with the ini:
that setting's value, and whether the owner's saved values of these five mods still agree with each other.

### Engine binds the mods watch for (by the text of the bind on the pressed key)

To do: list per mod from the code (`Bindings.GetBinding(e.KeyScan)` in ShieldSaw, Tactical Rig, Wheel, Whip,
Flashlight & Flare, Melee, Miniboss, Distance Grab): e.g. `+oh_attack`, `weapnext`, `weapprev`, `+use`.

## Layer 1: the engine and Doom itself

Waiting for the ini.
