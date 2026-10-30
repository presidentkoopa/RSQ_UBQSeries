# RSQ Wheel

REMA's weapon wheel on stock **QuestZDoom 17.3**: a ring of weapon cards around your hand. Point
at one and pull the trigger, or reach into it, and that gun is in your hand. Rest the beam on a
card and a data sheet in the middle of the ring tells you about it (ammo, kills, shots, accuracy).
A slot holding several guns fans them out.

The ring only. REMA's honeycomb and star chart stay in REMA.

## Use

- **Open / close:** bind *Wheel: main hand* or *Wheel: off hand* under Customize Controls →
  RSQ Wheel. (The keyboard defaults are `[` and `]`.) The ring opens around that hand.
- **Pick:** point and pull the trigger, or touch a card with the hand.
- **Fan:** rest on a card that holds several guns, or press Use on it.
- **Sheet:** pull the trigger on the sheet for the next page, alt-fire for the previous one.
- While the ring is open you are held still (you cannot walk or shoot), as in REMA.
- Settings: Options → Radiant Silvergun Options → RSQ Wheel.

## How it looks

Everything is drawn in the game's own art: the cards and the sheet are the status bar's stone
health box, the words are DoomFont, the numbers are the status bar's big numerals, all coloured
by palette remaps the way Doom colours its own text.

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
- **Single player.** The cards are real actors built from the local player, as REMA builds its
  billboards; in a net game every machine would build its own.
- **Haptics** go through the quake-wave route (`vr_quake_haptic_level` above 0).

## Status

Tested on the QuestZDoom 17.3 rig (freedoom2): the ring opens, the beam hovers a card, the
trigger equips it (Pistol to Chainsaw, measured), the ring folds away and the player is released.
Zero script errors alone and with the whole series. **Not yet on a headset, not yet with Brutal
Doom.**

## Files

- `zscript/wheel/zscript.zs` -- REMA's ring (changes marked `RSQ:`)
- `zscript/wheel/wr_q_shim.zs` -- billboards, reflection stubs, VR hooks for stock QZD
- `tools/gen_assets.py` -- writes the quad models, TEXTURES and the palette table
- `tools/rig/` -- the rig runner and probe (test only)
