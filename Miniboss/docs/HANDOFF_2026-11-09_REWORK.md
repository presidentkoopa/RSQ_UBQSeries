# RSQ Miniboss: the fight rework (2026-11-09) -- handoff

Built from design/MINIBOSS_REWORK.md (all of it, Summoning excepted: parked) and design/mockups/miniboss/ p1-p7.
**Code only: not compiled (no engine here), not rig-tested, not headset-confirmed.** Checked statically with
`python3 -I Miniboss/tools/check_zs.py` (0 errors) and `python3 tools/series_check.py static`.
`Miniboss/RSQ_Miniboss.pk3` (10-27) is STALE: rebuild with `Miniboss/build.sh` before any run.

## Where it lives

| File | What |
|---|---|
| zscript/rsqmb/fight.zs (new) | the rules: windows, segment breaks, tier-ups (and following a CH body swap), words, room glow, death wave + re-roll, the grey Xs |
| zscript/rsqmb/bossfight.zs | the staggered arrival: beams, hold until reveal, arrows, boost, 1.25x miniboss, the bind |
| zscript/rsqmb/boss.zs | the set piece's state: segments, shield, window, lives (no revive), powers lost, Rebody |
| zscript/rsqmb/items.zs | RSQMB_Ward (immune / segment / own bar), RSQMB_XFx (the grey X) |
| zscript/rsqmb/hud.zs | DrawStack: thrall bar + shield icon, window bar, its bar + skull, life bars |
| zscript/rsqmb/fx.zs | no life orbs, no BFG ball over thralls |
| Monsters/zscript/monsters/RS_ScoreReadout.zs | RSQMN_RosterService "retier" (new request) |
| graphics/RSQMBWH.png, RSQMBSH.png | white box, placeholder shield (tools/gen_hudart.py) |

Calls by name, per /tmp/contract.md: RSQVR_Service "beam" (nameArg role 'miniboss' / 'thrall') / "word" / "word.hold" / "word.clear" / "pop";
RSQSM_Service "arrow.add" / "arrow.clear" / "start.bossfight"; RSQGD_Service "event.tint" / "event.wave" /
"event.reroll"; RSQMN_RosterService "tier" / "tier.next" / "tier.ago" / "retier". Each absent: skipped quietly.

## Numbers that are mine (not the owner's), easy to change

- Segment size: the miniboss's health at the bind / thralls (the mockup: "its share of the miniboss's health").
- Score's window pay: "Thrall Slow Kill" row, 100 x the steps left (first step = most).
- Tier-up by segment left: >= 99% +3, >= 1/3 +2, else +1.
- Arrival: thralls 10 tics apart, the miniboss from 46 tics; arrows held 18 tics after a reveal; a beam may hide a monster 6 s at most.
- Room glow: shield 8A93A6 (the mockup's), gold FFC830 / 7A5A10 alternating every 9 tics, life lost FF2020 for 20 tics.
- Thralls drawn x1.15 (DOWN's boost); the light, full-bright, +50% health without LegenDoom (DOWN's).

## Rig-test list

1. Call a Bossfight (netevent rsqmb_fill 1000, watch check + Use) with VisualRewards' beams: thralls land ~0.3 s apart
   on V1 (or V2), the miniboss on V3 (or V4); none moves or shoots before its reveal; arrows show only for landings out
   of view and go ~0.5 s after the reveal; SlowMo's BOSSFIGHT bar runs 4 s; GITD wave from the miniboss.
2. The same without VisualRewards: the old fog per landing, revealed at once.
3. The miniboss is 1.25x and its hitbox too (shoot just over its old head height); faster; shoots more.
4. HUD stack: segments slot in as thralls land, the skull and bars rise with the miniboss; grey segments + shield icon
   after the bind; RSQ SlowMo's countdown and Score's combo rows sit under the stack.
5. Shield: shots do no damage, grey Xs fly off, "GUARD!" at most every ~0.5 s, "TARGET!" over each thrall, room grey.
6. Kill a thrall: pop in its power's colour, that power gone (rsqmb_state lists powers), window bar 1 s per thrall,
   big "TARGET!" over the miniboss, thralls' shrink, room gold pulsing (steady with rsqa_photosafe 1).
7. Break the segment in the window: Score's Thrall Slow Kill row pays more in the first step than the last.
8. Miss the window: tier flash on the miniboss and thralls (+1/+2/+3 by segment left) and, with the map-wide row on, every
   RSQ Monsters monster; CH bodies are swapped and still belong to the fight (debug: "tier swap followed").
9. One-on-one: thrall bar gone, "TARGET!" over it, its bar drains; a life lost: refill animation, a thin bar fewer,
   flames 5 s, tier +1 with the flash, room red then its new colour; no thralls rise.
10. Death: map-wide wave, GITD colours re-roll ~2 s later, loot, Score's Miniboss and Bossfight rows.
11. Hub: tier things up, leave and re-enter: they are back to their old tiers.
12. Save and load mid-fight (segments, window, the followed bodies are saved fields).
13. Cost: rsqmb_debug 1, netevent rsqmb_state (ms per tic) with the map-wide tier-up on a big map.

## Not built

- Summoning (parked by the owner).
- (Built later on 11-09: RSQ Monsters > Bossfight: Miniboss From / Thralls From, fight.zs ApplyFrom / FromTier and
  Monsters RS_BossfightPick. Head shots were already RSQ Score's head check, judged on the grown 1.25x body.)
- DOWN's full "real Champion" (hidden candidates until Champions picks one): a monster Champions did not pick gets a
  colour token by name (DOWN's own fallback).
