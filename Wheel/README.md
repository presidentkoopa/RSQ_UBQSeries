# RSQ Wheel

REMA's weapon wheel on stock **QuestZDoom 17.3**: a ring of weapon cards around your hand. Point
at one and pull the trigger, or reach into it, and that gun is in your hand. Rest the beam on a
card and a data sheet in the middle of the ring tells you about it (ammo, kills, shots, accuracy).
A slot holding several guns fans them out.

The ring only. REMA's honeycomb and star chart stay in REMA.

## Use

- **One button: hold, point, release.** Hold the left thumbstick click (*Wheel: hold, point,
  release* under Customize Controls → RSQ Wheel), point **either hand** at a card, let go: that gun
  is in that hand. Let go over nothing and the ring just closes.
- **Tap** the button and the ring stays up; **tap twice** and the hand you last picked with goes
  back to the gun it had before.
- **Either hand picks.** The hand on a card owns the beam; the other shows a dimmer beam and takes
  over the moment it is on a card. The gun goes into the hand that picked it.
- **Two hands compare.** A different gun's card under each hand turns the sheet into a side-by-side
  comparison.
- **Pull a card out.** Put a hand into a card and snap it back toward you: the gun comes with it.
- **Throw a gun back.** Snap the hand holding a gun toward the ring (not at a card): it files
  itself away and that hand takes its empty-hand weapon (slot 1, or BD22 VR's off-hand fist).
- **Fan:** rest on a card that holds several guns, or press Use on it.
- **Sheet:** with ModelSwapper's shelf, the trigger on the sheet swaps to the Models page.
- **The wrist card.** Bring a forearm up across your chest as if checking a watch: that hand's gun
  shows its card over the wrist -- rounds, reserve, kills and hit rate, Gun Bonsai level.
- The ring holds you still while it is up and, with **RSQ SlowMo** loaded, slows the world. Without SlowMo
  time runs on, unless **Stop Time Without SlowMo** (`wr_own_freeze`, off) is on: then the ring freezes the world itself.
- It swings round to stay in front of you if you turn away (*Ring follows past*).
- Each card's tick in the controller is shaped by the gun's weight: light pistol, heavy BFG.
- Settings: Options → Radiant Silvergun Options → RSQ Wheel.

## How it looks

Everything is drawn in the game's own art: the cards and the sheet are the status bar's stone
health box, the words are DoomFont, the numbers are the status bar's numerals, coloured by palette
remaps the way Doom colours its own text.

- **Pickup voxels on cards**: a gun with a pickup voxel (BD_VoxelPack) shows it on its card, turning
  slowly, sized from the voxel's own VOXELDEF scale and KVX size to sit inside the card. A gun with
  no voxel keeps its flat icon; nothing is drawn at a guessed size.
- **Palettes** (*Palette*): Standard (REMA's), Doom, Hell, Tech. A palette is a few lines in a
  `WRPALS` lump -- any pk3 can add one -- naming the ring's colour roles (`hover`, `slot2`,
  `sheet_text`, `laser`, ...). See `WRPALS.txt`.
- **Font sets** (*Font*): DoomFont words with the big red numerals, the small gold or grey ones, or
  DoomFont throughout. A `WRFONTS` lump names the glyph cells; `tools/gen_assets.py` makes cells
  from any WAD font lumps.

## The series

Each by name, each only when loaded: **RSQ SlowMo** slows the world while the ring is up;
**RSQ TacticalRig** adds a HOLSTER row to a holstered gun's sheet (its new `rig.holster` request);
**RSQ Gun Bonsai VR** adds the gun's Gun Bonsai level and each of its upgrades by name and level
to the sheet and the inspect card, and a BONSAI row to the comparison card (`RSQGB_Service`, read by
`zscript/wheel/wr_q_bonsai.zs`, whose `WR_Bonsai` calls any part of the Wheel can use; *Gun Bonsai
level and upgrades* on the Data sheet page turns it off), and a BONSAI level row to the wrist card; **ModelSwapper** names the model a gun wears.

## What is different from REMA

- **Drawn with model quads, not engine billboards.** `zscript/wheel/wr_q_shim.zs` does REMA's
  billboard calls in ZScript. Layout follows the tic (35 Hz) rather than the frame.
- **No painted canvas faces.** ZScript canvases come out black in VR on QuestZDoom 17.3
  (`Draw2D` skips its viewport in VR mode), so `wr_canvas` does nothing.
- **No room effects.** The volumetric laser, fog slab, light sweep, glow ripple and floor marks
  are REMA engine shaders; their settings remain, marked REMA only.
- **No mod-specific data rows.** REMA's field reflection does not exist on stock QuestZDoom, so
  the compat readers (Lithium, DOOM Infinite, Pandemonia, ...) find nothing and the sheet shows
  the universal rows only. LegenDoom, DRLA, Combined Arms and Final Doomer read inventory and
  may still show theirs.
- **No inventory page.** Removed, as REMA's work queue asked.
- **Haptics** go through the quake-wave route (`vr_quake_haptic_level` above 0). At 0 they fall back to the
  LineAttack pulse (a flat 150 ms tick on the same hand, gated only on `vr_enable_haptics`; teardown apply/07 7.3).

## Status

Tested on the QuestZDoom 17.3 rig, on freedoom2 and on the owner's order (brutal22test6 →
BD_VoxelPack → BD22_VR-Reloaded 2.0.3h → its 2.0.3ha hotfix → the wheel), alone and with every
series pk3: hold-point-release, tap and double tap, either hand picking (off hand → BrutalPistol),
two-hand compare (Chainsaw against Pistol), pull a card out (Chainsaw), throw a gun back (Rifle →
DSweap), pickup voxels fitted inside their cards, palettes and font sets, the wrist card (RIFLE,
rounds and reserve), the ring following a 90° head turn, SlowMo on and off with the ring. The only
script errors are BD_VoxelPack's own four voxeldef lines. Not run: the holster row with a gun
really holstered, the Gun Bonsai rows (Gun Bonsai 0.10.6 is not on the rig). **Not yet on a
headset** -- gesture speeds and the wrist pose are first guesses.

## Files

- `zscript/wheel/zscript.zs` -- REMA's ring (changes marked `RSQ:`)
- `zscript/wheel/wr_q_shim.zs` -- billboards, reflection stubs, VR hooks for stock QZD
- `zscript/wheel/wr_q_look.zs` -- palettes and font sets; `WRPALS.txt`, `WRFONTS.txt`
- `zscript/wheel/wr_q_watch.zs` -- the wrist card
- `tools/gen_assets.py` -- writes the quad models, TEXTURES and the palette table
- `tools/rig/` -- the rig runner and probe (test only)

## The cards on the gun

Moved to their own mod, **RSQ Gun Cards** (`GunCards/`, `RSQ_GunCards.pk3`), 2026-10-31. The Wheel loads and works
without it, and it without the Wheel. With it loaded and its watch card on, the Wheel's wrist card stands down.
