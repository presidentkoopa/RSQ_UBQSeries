# RSQ Monsters (RS Monsters, Quest edition)

Copied into the RSQ UBQ Series from presidentkoopa/RS_Monsters on 2026-11-08 (owner). One change for stock
QuestZDoom 17.3: `zscript/monsters/RS_MonsterMaster.zs` line 796, `OnSweepCrossed` is no longer an `override` (that
engine hook exists only on UZDXREMA; on 17.3 nothing calls it). Loads with 0 script errors on 17.3, alone and after
brutal22test6; imp, shotgunner, demon and cacodemon shown spawning, moving and dying on the rig (rig only, not
headset-confirmed). Built as `pk3/RSQ_Monsters.pk3` by `python3 tools/build_all.py Monsters`. The MeatGrinder tiered
set will be folded in next.

## The original README

The monster pack, pulled out of RS_Main so it can be loaded on its own. Every
Doom monster gets a reworked actor plus a matching effects file --
`RS_Imp.zs` / `RS_ImpFX.zs` and so on for the whole roster -- along with shared
behaviour in `zscript/monsters/chshared/`, an attack-profile system, and the
elite variants described in `ELITE_SYSTEMS.txt`. `EXCLUDED.txt` records what was
deliberately left behind when the weapon seam was cut.

Sprites, voxels, brightmaps, sounds and translations ship with it. It needs the
UZDXREMA engine fork.
