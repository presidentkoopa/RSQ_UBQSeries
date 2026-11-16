# The kiosk (2026-11-13, design mockups)

- `kiosk_lucky_anim.gif` (still: `kiosk_lucky_still.png`): the owner's pick, "now we're talking. save this fuckin image. i want this."
  A tier-2 miniboss's kiosk: every offer the same rarity (Uncommon), SOTN gold prices, the compare card popping in, one
  Score life spent for +1 rarity on one offer ("LUCKY", a name option), drawn over a real MAP01 frame from the rig.
  Made by `kiosk_anim.py` (with `sotnfont.py`, `ext.py` and `mk.py`; the SOTN letters come from the owner's word sheet).
- `kiosk_in_game_rig.png`: the same kiosk stood up in the engine from sprites (rig only, a throwaway test pack).
- `kiosk_TARGET.png`: the owner's capture of that in-game render, 2026-11-13: "i want that kiosk to look like this". This is the look to build.
- `kiosk_counter.png`: the first flat mockup ("i don't hate this").
- `hf_weapon_screen_rig.png`: the owner's earlier weapon screen, drawn in the rig by its own code ("theres my baby").
- `rig/` (2026-11-16): **the built kiosk and gold, on the rig** (rig only, not headset-confirmed): `rig_KIOSK_open.png` (open
  after standing still, the card for the offer pointed at), `rig_KIOSK_sequence_vr_trigger.png` (closed, opened, bought with
  the faked controller's trigger, LUCKY, too dear, bought, folded), `rig_GOLD_BITS_fly_in.png` and `rig_HUD_gold_counter.png`
  (gold bits flying in, the bank by the score going 350 -> 380), `evidence_2026-11-16.txt` (the logs: a real Boss win, the
  VR input, the economy measure, the death keep). Made by Miniboss/tools/rigtest/kioskprobe.
