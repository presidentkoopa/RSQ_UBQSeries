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
- **Options -> Score**: a menu (the original had none; a headset has no console).
- **The revival**: Dakka's fire-and-explosion revival was never carried; a life spent is now a
  sound and one short warm flash, no actors. *Flash the whole view on a reward or revival*
  (`rs_score_screenflash`) turns every whole-view tint off.
- ZScript header 4.14 (the engine's version), so no version warning.
