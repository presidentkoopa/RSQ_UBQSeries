# RSQ Monsters (RS Monsters, Quest edition)

Copied into the RSQ UBQ Series from presidentkoopa/RS_Monsters on 2026-11-08 (owner). One change for stock
QuestZDoom 17.3: `zscript/monsters/RS_MonsterMaster.zs` line 796, `OnSweepCrossed` is no longer an `override` (that
engine hook exists only on UZDXREMA; on 17.3 nothing calls it). Loads with 0 script errors on 17.3, alone and after
brutal22test6; imp, shotgunner, demon and cacodemon shown spawning, moving and dying on the rig (rig only, not
headset-confirmed). Built as `pk3/RSQ_Monsters.pk3` by `python3 tools/build_all.py Monsters`.

## How To Play

1. Load `RSQ_Monsters.pk3` with the other RSQ pk3s (after Brutal Doom if you use it).
2. Options > Radiant Silvergun Options > RSQ Monsters > **Select Monster Set**: ColorfulHell (the default), MeatGrinder,
   BD22 or Vanilla. Start a new map: the set applies to monsters as they spawn.
3. Play. With ColorfulHell or MeatGrinder a monster's colour is its tier, from Common (grey) up through Green, Blue,
   Purple, Yellow, Red, FireBlu, Gray, Abyss, Black, White and Cyan to Brown: the higher, the tougher, faster and keener
   to shoot. A monster that changes tier blinks white first (black when it becomes White), then is the new colour.
4. **On tier change** picks what a tier change does to its health. The MeatGrinder rows switch its reactive deaths,
   head-pops, the Abyss split, the tier icons, cheaper effects and the gore budget.
5. With RSQ Miniboss loaded: **Bossfight** > **Miniboss From** / **Thralls From** pick which set a Bossfight's monsters
   come from (below).

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
An MG tier also sets the monster's spawn health (`StartHealth`) to the tier's health, so RSQ Score pays the tier (a
White imp pays 1200, not 60) and an Arch-vile raise or a heal stops at the tier's health. When a body gibs does not
change: that still uses the creature's own health. A CH colour change makes a new actor; it now tells RSQ Score (by
name) to pass the old body's full pay to the new one. Head shots (11-09): with RSQ Score loaded, its head check decides
them for every monster, MG included, and the MG reactive deaths (head-pop, exploding head) follow Score's verdict;
MG's own head band (`rsq_mg_head_zone`) is only used without Score (or with Score's check set to Brutal Doom's Own).

RSQ Monsters > **Bossfight** (11-09, for RSQ Miniboss; code only, not compiled): **Miniboss From** (Same as Monster Set /
ColorfulHell / MeatGrinder / Mixed; `rsq_mon_bf_boss`) and **Thralls From** (Same as Miniboss / ColorfulHell / MeatGrinder /
Mixed / Map's Own Monsters; `rsq_mon_bf_thralls`). RSQ Miniboss turns each pick into the same family from that set through
`RSQMN_RosterService` `GetString("set.class", type, set, tier)` (set 3 CH at that tier, 2 MG), with `GetInt("class.set", type)`
and `GetInt("class.tier", type)` to read a type without a monster (`RS_BossfightPick` in `RS_ScoreReadout.zs`).
`RSQMN_RosterService` `GetInt("headshot", "", 0, 0, monster)` answers Score's verdict (any monster), else MG's band;
`GetString("family", ...)` names an MG body's Doom family for Score. (11-09: rig shown for an MG imp's head and chest,
RSQ Score's `tools/rigtest/evidence_headshot/`; not headset-confirmed.)

Also carried from the owner's HF monster template, because the MG monsters used them there (`RS_MGReactions.zs`,
RSQ Monsters menu > MeatGrinder):

- Reactive deaths: head-pop on a headshot (an exploding head on a heavy hit), and gib on an overkill or explosive kill.
  Fire, ice, lightning and acid kills burn, freeze, shock or melt the body. HF's weapon-keyword inputs need HF's
  weapons, so the damage type decides here.
- Abyss-tier MG monsters split into two lost souls when they die.
- The optional floating tier marker.
- The gore governor.

MG blood leaves the owner's HF wall and floor decals (`DECALDEF.txt`, every name `MG_`, pictures
`graphics/meatgrinder/decals/`). The enemy tracer is the owner's streak model (`MODELDEF.txt`,
`models/meatgrinder/tracer/`).

## What RSQ Miniboss asks (11-09; rig 11-09: QuestZDoom 17.3 Linux rig on Freedoom 2, no Brutal Doom; rig only, not headset-confirmed)

RSQ Miniboss's reworked fight (design/MINIBOSS_REWORK.md) asks the same service by name: `"tier"` for each monster's
ladder colour, and `GetInt("retier", "", tier, instant, monster)` (new) to tier a monster up after a missed window or a
lost life: `RS_Retier.Request`, the same path as `rs_retier`, with the tier flash (instant, no flash: its hub reset).
1 asked, 0 not a ladder monster. A CH swap is a new actor: Miniboss finds it by `"tier.ago"` where the old one stood.
Rig shown 11-09: a missed window tiered 11 monsters up +3 (CH bodies swapped to Purple and followed, the MG miniboss
changed in place), a lost life +1 each time. Fixed from the rig: a Common CH monster carries no tier token, so `"tier"` and
`"set"` read it as not on the ladder; both now fall back to its class's ladder tier.

## What RSQ Score reads (11-09)

RSQ Score's roster rows ask one service by name, `RSQMN_RosterService` (`zscript/monsters/RS_ScoreReadout.zs`); nothing
links either way, and each mod still loads alone. It answers, for a monster: its set (CH or MG), its ladder tier, whether
it is an EX form, how rare its CH colour roll was (the family's dial with the menu's gates applied), the tier a running
tier-change flash will give it, how long ago it last changed tier and from what, an MG monster's reactive death and its
tier's aggression, and its Abyss death-split group. Two plain inventory stamps carry the last two facts that were not on
the monster: `RS_TierStamp` (put after a flashed tier change, `RS_RetierJob.Tick`) and `RS_SplitStamp` (put on an Abyss
MG monster and the two lost souls it splits into, `MG_DeathSplit`). Code only, not run.
