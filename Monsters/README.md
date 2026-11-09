# RSQ Monsters (RS Monsters, Quest edition)

Copied into the RSQ UBQ Series from presidentkoopa/RS_Monsters on 2026-11-08 (owner). One change for stock
QuestZDoom 17.3: `zscript/monsters/RS_MonsterMaster.zs` line 796, `OnSweepCrossed` is no longer an `override` (that
engine hook exists only on UZDXREMA; on 17.3 nothing calls it). Loads with 0 script errors on 17.3, alone and after
brutal22test6; imp, shotgunner, demon and cacodemon shown spawning, moving and dying on the rig (rig only, not
headset-confirmed). Built as `pk3/RSQ_Monsters.pk3` by `python3 tools/build_all.py Monsters`.

## Monster Set option

Radiant Silvergun Options > RSQ Monsters > **Select Monster Set** (server cvar `rsq_monster_set`) decides what the stock
monster spawns become. It takes effect on map restart.

| Set | What spawns |
|---|---|
| Vanilla | the id monsters themselves, even with Brutal Doom loaded |
| BD22 | no RSQ replacement: Brutal Doom's own. Without Brutal Doom (found by class name at run time) it is Vanilla |
| MeatGrinder | the MeatGrinder set below |
| ColorfulHell (default) | the CH colour tiers as before, with the Starting Roster caps |

It is one EventHandler (`RS_RosterHandler.CheckReplacement`, `zscript/monsters/RS_Roster.zs`). The CH classes no longer
use `replaces`: the 17 dials and CH's six projectile swaps (imp, cacodemon, baron, mancubus, arachnotron balls and the
cyberdemon rocket) apply only when the set is ColorfulHell. It replaced the old `rs_roster_pack` string and its
"Monster Pack" row.

## MeatGrinder set

The monsters, gore and sounds of **Sergeant Mark IV's Meatgrinder**, as the owner recoloured and re-tiered them in his
earlier HF project. Seventeen monsters, `RS_MGZombieman` through `RS_MGChaingunner`
(`zscript/monsters/meatgrinder/RS_MGMonsters.zs`, base `RS_MGMonster : RS_MonsterMaster`). Each keeps its own Meatgrinder
states, dismember deaths and sounds. Gore and effect actors are DECORATE (`decorate/meatgrinder/`, every name `MG_`),
the sprites are `sprites/meatgrinder/` (prefixes renamed `MGxx`), and the sounds are `mg/*` (`sounds/meatgrinder/`). None
of these names can clash with Brutal Doom or the rest of this pack.

Tiers use the RSQ ladder (1 Common ... 13 Brown). Map spawns are Common. `netevent rs_retier N` / `rs_retier_all N`
retiers them in place with the owner's per-colour table: health, speed, pain chance, outgoing damage (as
`DamageMultiply`), aggression (+MISSILEMORE / +MISSILEEVENMORE) and the tint (`rs_mg_<family>_tNN`; the lost soul and
archvile tints are CH's own recipes for those two families plus three taken from HF's TRNSLATE). A tier change on any RSQ
monster, CH or MG, first blinks white for 5..25 tics (black when the target tier is White). This is the owner's HF
tier-change flash, in `RS_Retier.zs`. RSQ Monsters > "On tier change" picks the health rule for CH and MG.

Also carried from the owner's HF monster template, because the MG monsters used them there (`RS_MGReactions.zs`,
RSQ Monsters menu > MeatGrinder):

- Reactive deaths: head-pop on a headshot (an exploding head on a heavy hit), and gib on an overkill or explosive kill.
  Fire, ice, lightning and acid kills burn, freeze, shock or melt the body. HF's weapon-keyword inputs need HF's
  weapons, so the damage type decides here.
- Abyss-tier MG monsters split into two lost souls when they die.
- Keywords (`class:`, `species:`, `role:`, `trait:`, `set:meatgrinder`, plus `color:` and `tier:`) on RS_MonsterMaster's
  own keyword hook.
- The optional floating tier marker.
- The gore governor.

MG blood leaves the owner's HF wall and floor decals (`DECALDEF.txt`, every name `MG_`, pictures
`graphics/meatgrinder/decals/`). The enemy tracer is the owner's streak model (`MODELDEF.txt`,
`models/meatgrinder/tracer/`).
