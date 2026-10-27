# RS_Score -- the Quest series version (RSQ_Score)

This copy is the owner's RS_Score brought to **stock QuestZDoom 17.3** for the Ultra Badass Quest
series: Brutal Doom compatible, a fourth bonus family for melee, a menu, and a light revival cue.
What changed is listed under *Quest version* at the end; everything above it is the original.

A scoring system for GZDoom: points for a kill, bonuses for how you got it, and a
per-map target that pays out when you cross it.

Written for **UZDXREMA**, a private GZDoom fork with a full OpenXR VR layer. It has
no dependency on the fork's VR features and should load on stock GZDoom 4.10+, but
that is untested.

## What it does

Every kill is worth the victim's spawn health. On top of that, thirteen bonuses each
add a multiplier for *how* the kill happened, grouped into three families that the
HUD colours differently:

**Efficiency** — Spree (kills in quick succession), Untouchable (kills since you
last took damage), Infighter (a monster killed another monster).

**Style** — Switcharoo (you varied weapon or trigger), Air (killed while airborne,
scaled by how high the jump reaches), Curveball (the victim never had line of sight
to you), Scrapping (a signature weapon), Darwin (the monster killed itself),
Telefrag.

**Daring** — Brawler (melee), Redline (*your* health at 25 or below), Swan Song (the
kill landed after you were already dead), Point-Blank (within 64 map units,
measured box edge to box edge).

The multipliers are summed and applied to the base once, so they stack additively
rather than compounding.

Each map gets a target score computed from a census of every monster on it. Crossing
a multiple of that target pays a reward — by default an extra life, which holds you
in buddha and catches you at 1 HP.

## Adding your own bonus

A bonus ships from the mod that owns the fact it measures. RS_Score never needs to
know your mod exists:

```
class MyMod_Parried : RS_ScoreBonus
{
    override int Family() const { return FAM_EFFICIENCY; }
    override String DisplayName() const { return "Parried"; }

    override double Evaluate(RS_ScoreEvent ev)
    {
        // ev carries the victim, the killer, the inflictor, the damage type,
        // the killer's health at the kill, box-edge distance, line of sight,
        // and the tracker holding that player's counters.
        return MyCondition(ev) ? 0.25 : 0.0;
    }

    // Anything worth remembering for next time. Called for every scored kill,
    // not only the ones this bonus paid on.
    override void Commit(RS_ScoreEvent ev) { }
}

class MyMod_Handler : StaticEventHandler
{
    override void OnRegister()
    {
        RS_ScoreRegistry.RegisterBonus("MyMod_Parried");
    }
}
```

Bonuses are sorted by class name before use, so every machine in a network game sums
them in the same order.

## Switcharoo

Inert until a weapon says it fired. Call it from the weapon's own fire state, with a
slot from 0–8 and a fire mode from 0–2:

```
RS_ScoreHandler.Switcharoo(self, 2, 0);   // slot 2, primary
```

## Settings

`rs_score_*`. The ones worth knowing:

| cvar | default | what it does |
| --- | --- | --- |
| `rs_score_rewardtypes` | 3 | 0 regen then life, alternating · 1 life first · 2 regen only · 3 a life every time · 4 no rewards |
| `rs_score_startmode` | 0 | what survives a map change: 0 nothing · 1 the running total · 2 total and rewards · 3 everything |
| `rs_score_interval` | 5000 | rewards land on multiples of this |
| `rs_score_farmpercent` | 100 | base paid by a monster that was not on the map at load. 100 is inert |
| `rs_score_cap_*` | 0 | per-family and total multiplier ceilings. 0 is off |
| `rs_score_scale` / `_x` / `_y` | 100 / 85 / 10 | HUD size and position, per player |

## Building

```
powershell -File build.ps1
```

Regenerates `RS_Score.pk3` from the sources, verifies every expected lump made it in,
then compile-checks the result. `-NoCompileCheck` skips the last step.

## Credit

The scoring design, the bonus taxonomy, the reward loop, the HUD layout and its
graphics are **ijon's**, from *Dakka* (<https://github.com/0dot0repeating/dakka>),
released under the WTFPL. This is a rebuild of those rules in ZScript, not a copy of
the code. See [CREDITS.md](CREDITS.md) for the full breakdown, including which
assets are **not** ours to redistribute.

## Quest version

Built and run on stock QuestZDoom 17.3 (`build.sh`), with brutal22test6 + BD_VoxelPack + BD22Q.

- **Only real kills score.** A kill is a monster the level counts (+COUNTKILL), plus Lost Souls.
  Brutal Doom spawns helper actors flagged as monsters that "die" as effects play out: one
  Brutal Doom imp (80 health) scored **1305** because a blood smear (BootSmearerRed, 1000 health)
  died too. Now **80**, the same as the engine's own kill count. The census uses the same rule.
- **A fourth family, Melee** (steel blue), for the series' VR melee. From damage types and
  inflictors measured in Brutal Doom's actors, and the ShieldSaw's service, with no links:

  | Bonus | Pays | For |
  |---|---|---|
  | Fatality | 0.5 | Brutal Doom's execution landed the kill |
  | Cleaved | 0.3 | a melee kill that took the body apart (its extreme death) |
  | Hurled | 0.3, +0.15 per earlier kill by the same throw (to 0.75) | the ShieldSaw or the saber thrown |
  | Shield Work | 0.3 bash, 0.2 grind | the shield itself in the hand |
  | Riposte | 0.4 | killed within 3 s of the shield blocking that monster's attack |
  | Return to Sender | 0.4 | killed by a shot sent back: turned by the shield or the saber, or a returned bullet |
  | Combo | 0.1 per different melee move inside 4 s (to 0.4) | a jab, a saber cut, a saw throw... |

  Tested on the rig: a disc throw through two imps paid Cleaved + Hurled 0.30, then 0.45; a
  turned imp fireball paid Return to Sender; a kill after a shield block paid Riposte + Shield Work.
  `rs_score_cap_melee` caps the family (0 off). The original thirteen are unchanged.
- **Thrown things, the rig and VR feats** (`physical.zs`), in the three original families.
  No hand pose is read anywhere (the pose exists on the local machine only): the facts are the
  shot's own line, the head's facing (the pawn's angle and pitch, driven by the headset through
  the replicated tic command), the fire buttons, Distance Grab's throw ledger
  (`RSQDG_ThrowService`) and the Tactical Rig's last draw (`RSQTR_RigService`), both found by
  name -- either mod absent, its bonuses simply never fire.

  | Bonus | Family | Pays | For |
  |---|---|---|---|
  | Thrown | Style | 0.2, +0.03 per m/s of impact over 3 (to 0.5) | killed by something you threw with Distance Grab |
  | Powder Keg | Style | 0.3, +0.2 per earlier kill by thrown blasts within 1 s (to 1.1) | killed by the blast of a barrel your throw set off, or one its blast set off |
  | Juggle | Daring | 1.0, +0.5 per extra catch (to 2.0) | the thrown thing was caught back out of the air and thrown again before it landed |
  | Skeet | Style | 0.25 | the victim was 0.85 m+ off its floor (not a flyer, not on another body) |
  | Quick Draw | Daring | 0.35 | killed with the gun you drew from a holster, within 42 tics of the draw |
  | No-Look | Daring | 0.3 | the shot left 60 degrees or more from where your head faced |
  | Blind-fire | Daring | 0.4 | your eye had no line to the victim and your hand did (direct hits; replaces No-Look) |
  | Off-hand | Style | 0.2 | the off hand's trigger alone fired the killing shot |
  | Full Hands | Style | 0.25 | a shot kill while a Distance Grab hand carries something |

  Tested on rig B (QZD 17.3, the owner's load order + Gun Bonsai, `rs_score_debug 1`, a probe
  map with a pillar): a barrel at 3.8 m/s paid Thrown 0.225, a clip at 14.4 m/s 0.5; one thrown
  barrel into three imps paid Powder Keg 0.3 / 0.5 / 0.7 on one tic and 0.9 for a fourth imp
  killed by a second barrel it set off, while a barrel the player SHOT paid nothing; a barrel
  thrown up, caught mid-air and thrown again paid Juggle 1.0 + Thrown; an imp falling from
  120 units paid Skeet, a standing one did not; a shot 90 degrees off the head paid No-Look, a
  straight one did not, a missile fired sideways paid it even after the head turned to follow;
  behind the pillar a hitscan from 25 units beside the eye and a missile from there paid
  Blind-fire, a visible imp did not, a missile from a gun pushed through the pillar did not;
  BD22Q's off-hand rifle fired with `+oh_attack` paid Off-hand, the main rifle did not; a
  shotgun drawn with the rig's own `rsqtr_draw` event (up 4 tics later) paid Quick Draw on the
  kill 8 tics after the draw, not 160 tics later; a shot with a clip held paid Full Hands, with
  the hand empty it did not.

  **Big moments**, for the series' SlowMo later (not wired): each of these answers
  `BigMoment(ev, paid)` -- Juggle and Blind-fire always, Powder Keg from the third kill of one
  blast.

  **A missile's fire tic**: the head's facing and the buttons of the last 16 tics are kept on a
  token (`RS_PhysicalNotes`, with the flags of the player's last blow, which tell a splash from a
  direct hit). It is given at the player's first kill, so a missile kill before that reads "now".

- **Gun Bonsai** (0.10.6 + RS_GunBonsai-Offhand-VR), measured on the same rig with two BD22Q
  rifles: XP comes from score only when `bonsai_score_to_xp_factor` is above 0 (default **0**:
  out of the box this pack's points give no XP at all). With score 1 and damage 0, an off-hand
  kill paid 104 points and the off-hand rifle got 104 XP, the main-hand kill 90 and 90 -- the
  addition routes each kill's score to the gun that made it. With **both** at 1 the guns got
  114 / 100: damage XP and score XP together pay the kill twice (the base points ARE the
  monster's health). **Set damage to 0 when score is on.** A Distance Grab throw's points went to
  the main-hand rifle on the rig (Gun Bonsai's resolver scores the object to a hand; headless, both
  hands sit at the pawn, so which hand wins in the headset is not measured).
- **Options -> Score**: a menu (the original had none; a headset has no console).
- **The revival**: Dakka's fire-and-explosion revival was never carried; a life spent is now a
  sound and one short warm flash, no actors. *Flash the whole view on a reward or revival*
  (`rs_score_screenflash`) turns every whole-view tint off.
- ZScript header 4.14 (the engine's version), so no version warning.
