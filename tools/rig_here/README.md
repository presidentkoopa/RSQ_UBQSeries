# The rig as set up in the cloud session of 2026-11-27 (test only, never ships)

Engine: the prebuilt QuestZDoom 17.3 rig, in THIS repo at `tools/rig/bin` since 2026-11-27 (it was in RS_ModelSwapper; version guard `qz`,
PINS gzdoom 9afc750), copied to a scratch folder so that repo is not written to. IWAD: Freedoom 0.13.0 `freedoom2.wad`
from GitHub (no doom2.wad here). Packs: `build_all.sh` with OUT pointed at the scratch folder.
`run1.sh <name> <secs> "<console script>" <pk3...>`: one headless run; FAIL on any script error, VM abort, unknown
class or warning, or if MAP01 is not reached.

First run, each mod alone, boot to MAP01 and 70 tics (2026-11-27 08:25):
ok: DistanceGrab, Grapple, FnF, Accessibility, Graveyard, Grenade, LaserSight, Score, GunCards, Saber, ShieldSaw,
SlowMo, TacticalRig, VisualRewards, Wheel.
Fixed and ok: Melee (field `painted` clashed with function `Painted`: ZScript names ignore case; field renamed
`paintMo`), Whip (`LsVelAgo(i, a).z` on a call's result does not compile; taken into a Vector3 first).
Not a fault of today's work: GlowInTheDark alone (its ddz.zs needs DarkDoomZ's settings loaded), Gun Bonsai VR alone
(needs Gun Bonsai), Miniboss alone (boots; logs "Unknown class name" for 12 optional classes of other mods).
This proves COMPILE and BOOT only: no move was performed, no menu opened, Brutal Doom and BD22 VR not loaded.
