# HANDOFF -- RSQ_Whip (PROJECT WHIP), 2026-10-30

Not run on the owner's headset. Rig: QZD 17.3 (RSQ_WeaponDepot tools/rig/bin), freedoom2 MAP01 and WHIPTEST
(tools/rigtest/mkwhipmap.py: a ledge, a pit, a beam over it, a 96-unit block, a switch pillar). Hands driven per tic by
tools/rigtest/whipprobe (the rig's qzt_rhand), runner tools/rigtest/whip.sh (BD=1 the owner's BD order, GRAPPLE=1 also
loads pk3/RSQ_Grapple.pk3).

History: built inside RSQ_Grapple first (commit cc32dbc), then split out on the owner's word (10-30: "Grapple should stay
intact"): RSQ_Grapple is back to exactly what it was before; this mod carries its own copy of the line.

## What it is
- Thong: 20 links, Verlet, 8 sub-steps x 6 constraint passes a tic (3 sub-steps at rest), room units (map z x 1.2), mass
  falling to ~1/30 at the popper. A 24 cm rigid handle. Constants searched in tools/whipsim.py on rig-recorded hand paths.
- CRACK = the tip's speed passing rsqwp_whip_crack (20 room units/tic) with the hand having driven it lately; at the speed's
  peak. Fast outer links sting; the crack and its 8-tic lash land rsqwp_whip_damage and the Pain stun.
- Snag only on EDGES (lintel/beam underside, ledge lip, 3D floor top): a fast link striking one, or a crack within 12 units
  of one. The anchor goes on the corner; the existence check traces the struck face (hook.struck).
- Lock: the whip hand's +altattack (swallowed in InputProcess while a whip is out) holds a lock from the other hand
  (512 units, 7 deg); the crack flies there in 5 tics; bind held on a monster = leash (the line bites; slide to you).
- Line (forked core): swing, reel, stick pump, arm pump, climb, tap to let go with keepmomentum, mantle over a lip.

## Measured (standalone RSQ_Whip.pk3)
| what | result |
|---|---|
| slow motions | sweep +-40 deg over 4 s: 0 cracks; slow lift: 0 |
| thrown motions | overhead (4 throws): 6 cracks, crack hit imp 60 -> 48 + Pain; side-arm: 10 cracks, 1 hit |
| snag + mantle | WHIPTEST block from 30 units: snag on the lip, MANTLE from z 34 onto 96 |
| lock + leash | imp at 300: LOCKED crack 283 units, hit 60 -> 48 + Pain, LEASH, pulled in (13 pull logs) |
| with RSQ_Grapple + BD order | both load; whip cracks and hits; Grapple's off-hand hook fires, bites, pulls; only BD_VoxelPack's 4 voxeldef script errors |
| cost | 0.13-0.16 ms/tic out and still, 0.23-0.26 lashing (sim 0.12, sweeps 0.03, draw 0.03), desktop, BD order |
| measured before the split (same code, in Grapple) | beam swing kept on the corner anchor; arm pump +0.27 u/tic a haul; Assist hit/air crack; switch thrown by Assist and by Lock; save/load twice replays the same cracks |

## Open
- Feel, headset: crack speed 20, handle 24 cm, length 3.8 m, lock cone 7 deg, arm pump 0.12, mantle.
- Snag reach: scripted throws are chaotic (the same throw caught the block's lip from 30 units, not from 50+).
- Quest cost (Debug Log = Cost).
- No Gun Bonsai / RSQ_Score / TopHPBars hooks (RSQ_Grapple's service and perks were not forked): add a service if wanted.
- Left-handed mirror and the SteamVR two-hand latch not run.
