# Bossfight rig tests (TEST ONLY, never ships)

Runs on the Linux QuestZDoom 17.3 rig in RSQ_Meshturbator `rig/` (prebuilt engine, cvar-posed headset and hands).
The rig wants `doom2.wad` in `$MT_GAMEDATA` (default /home/claude/rig/packs); the 11-09 runs used **Freedoom 2** under
that name (same monster classes, not the owner's IWAD, no Brutal Doom).

- `make_rig02.py` -> `rig02.wad`: TestRig/maps' rig01 arena plus eight deaf monsters along the west wall, facing the
  wall (the map's own roster for a Bossfight to pick from).
- `probe/` (zip it to probe.pk3): `netevent rt_auto` plays a Bossfight off its own state, no fixed waits: the shield
  hit, a thrall killed and the window missed, a thrall killed and the segment broken in the window, every thrall
  killed, the miniboss hammered through its lives to death; one `RTP t<tic>` line per step. Also `rt_beams`
  (V1-V4 on spawned monsters, logs the reveal tic), `rt_words`, `rt_wordclear`, `rt_barrels N`, `rt_shootbarrel`.
- `load.py <name> "<console script>"`: every RSQ pk3 together, prints script errors. `fight.py`: the Bossfight twice
  (the map's own monsters; Miniboss From MeatGrinder / Thralls From ColorfulHell), frames every 6 tics on the first.
  Paths inside are the cloud session's; adjust.

## 2026-11-09 results (rig only, not headset-confirmed)
- All 20 RSQ pk3s load together with zero script errors (after the fixes below).
- Beams V1-V4: hidden, revealed one tic before the returned tic; role sounds (chump, thrall, riser + hit). Words, held
  words, clears and pops answer 1. Barrels: chain reactions; Combat FX and Test Candidate sounds both play.
- Bossfight, both setups, arrival to death: shield hit does nothing; thrall kill opens the window; missed window tiers
  everything +3 map-wide and the miniboss and thralls are followed into their new bodies; a hit in the window breaks a
  segment; lives drain with the tier-up each; death drops the gun. Evidence: `evidence_2026-11-09/`.
- Fixed from these runs: Grenade's 11 compile errors (Play / Cross are keywords); VisualRewards' read-only fillcolor;
  a ColorfulHell Common monster read as no tier (pink, never tiered); a moving miniboss or thrall lost after a CH body
  swap (the follow looked within 1 unit); a failed miniboss landing left its thralls behind and overlapped the retry;
  a thrall standing in the miniboss's spot is moved aside.
- Not shown: the look of the beams, words and HUD stack (the camera did not face the landing); the watch check (a
  posed controller's roll does not reach ZScript on this rig; the call-in used `netevent rsqmb_callin`).
