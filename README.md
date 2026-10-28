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
  | Boomerang | 0.5 | a throw that already killed on its way out kills again on its way home |
  | Ground Down | 0.3 | the thrown disc stuck in a monster too tough to cut through and ground it to death |
  | Shield Work | 0.3 bash, 0.2 grind | the shield itself in the hand |
  | Riposte | 0.4 | killed within 3 s of the shield blocking that monster's attack |
  | Perfect Riposte | 0.7 (replaces Riposte) | the same after a PERFECT block (the plate met the attack) |
  | Return to Sender | 0.4 | killed by a shot sent back: turned by the shield, the saber or the Force, or a returned bullet |
  | Poetic Justice | 0.3 (on top) | ...and the shot killed the very monster that fired it |
  | Heavy Swing | 0.15 blow 2, 0.3 blow 3 | BD22Q's VR swing stacks BD's attacks by swing power (2nd at 1.6, 3rd at 2.4); the 2nd or 3rd blow made the kill |
  | Choked | 0.3 | the Force grip choked it to death |
  | Slammed | 0.5 | a body flung from the Force grip died hitting something |
  | Juggle | 0.3 | a melee or Force kill of a non-flyer in the air that your Force, a kick, a punch or a bash put there (top of a push, held in the grip) |
  | Boot | 0.2 | Brutal Doom's boots: a kick, head kick or stomp |
  | Combo | 0.1 per different melee move inside 4 s (to 0.4) | a jab, a saber cut, a Force kill, a kick, a saw throw... |

  Tested on the rig: a disc throw through two imps paid Cleaved + Hurled 0.30, then 0.45; a
  turned imp fireball paid Return to Sender; a kill after a shield block paid Riposte + Shield Work.
  Second round (probe `mlprobe`, the owner's load order): Perfect Riposte 0.7 after a perfect block;
  a fireball turned back into its shooter paid Return to Sender + Poetic Justice; the disc killed out,
  then home (Boomerang 0.5, Hurled 0.45), and ground a BD imp (Ground Down); the saber thrown killed out,
  then home (Boomerang, measured from its motion); BD22Q's axe stack killed on blow 2 (0.15) and 3
  (0.3), not on blow 1; the Force choke, slam and a saber cut after (Combo 0.1); the saber's real Force
  push lifted an imp 8 units and a cut at the top paid Juggle; a kick paid Boot.
  Not measurable yet: a PULL does no damage and (on the rig) did not lift an imp, so "pulled, then cut on
  arrival" needs the saber to report pulls; a saber block/parry riposte needs it to report blocks.
  The melee family's big moments are listed in one place: `RS_Melee.BigMoment` (see *Slow motion*).
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
  | Air Catch | Daring | 1.0, +0.5 per extra catch (to 2.0) | the thrown thing was caught back out of the air and thrown again before it landed |
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
  thrown up, caught mid-air and thrown again paid Air Catch 1.0 + Thrown; an imp falling from
  120 units paid Skeet, a standing one did not; a shot 90 degrees off the head paid No-Look, a
  straight one did not, a missile fired sideways paid it even after the head turned to follow;
  behind the pillar a hitscan from 25 units beside the eye and a missile from there paid
  Blind-fire, a visible imp did not, a missile from a gun pushed through the pillar did not;
  BD22Q's off-hand rifle fired with `+oh_attack` paid Off-hand, the main rifle did not; a
  shotgun drawn with the rig's own `rsqtr_draw` event (up 4 tics later) paid Quick Draw on the
  kill 8 tics after the draw, not 160 tics later; a shot with a clip held paid Full Hands, with
  the hand empty it did not.

  **Big moments** (see *Slow motion*): Air Catch and Blind-fire always, Powder Keg from the third
  kill of one blast.

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
- **Options -> Score**: a menu (the original had none; a headset has no console), in BD22 VR
  Weapons' style: one short page (Show Score, Size, Across, Down, Target Reward, New Map Keeps,
  Slow Motion Moments) and a Tuning page (flashes, bonus time, raised-monster pay, the caps, the
  slow-motion cooldown, Reset All).
- **The revival**: Dakka's fire-and-explosion revival was never carried; a life spent is now a
  sound and one short warm flash, no actors. *Flash the whole view on a reward or revival*
  (`rs_score_screenflash`) turns every whole-view tint off.
- ZScript header 4.14 (the engine's version), so no version warning.

## The suite (10-27)

The suite is loaded over **any** base game, so Score has to make sense over all of them.

**What a kill is, and who made it** (tested on freedoom2 and the real doom2.wad with the suite, on
brutal22test6 + BD_VoxelPack + BD22Q, and on a synthetic monster pack, `scratch/mpack`, that has
the shapes gameplay mods use: a replacement without COUNTKILL, a monster that splits on death, a
50,000-health gore helper flagged as a monster, a morph, a raise):

- A replacement of a counted monster is a kill even if it dropped COUNTKILL. Brutal Doom's
  WolfensteinSS is `EvilMarine` with no COUNTKILL: five killed paid nothing before, now they pay.
  Helpers that replace nothing (BD's smears, `Dying_Headshot`, `DyingSergeant`; the mpack gore
  helper) still pay nothing.
- A monster killed in the tic it was born, by a monster, pays nothing: a Pain Elemental's Lost Soul
  with no room is killed by the Elemental at once, and those paid every player Infighter (8 of 13
  Lost Soul deaths in the vanilla sweep, 14 everyone-payments under BD). Now 0.
- The killer is the killing blow's own damage source, not the victim's last target. A monster
  chasing you that died in a crusher still had you as its target and was paid to you as your kill.
- A morphed monster's death kills its original too; the pair pays once (was 63 + 11).
- Sweep result, every kill scored exactly once: vanilla 110 counted kills -> 110 paid; BD 110
  counted + 5 EvilMarine -> 115 paid; mpack 7 bodies -> 7 paid, the gore helper 0.

**Suite bonuses**, each read from a fact the game already has, each silent when its mod is absent:

| Bonus | Family | Pays | For |
|---|---|---|---|
| Pulled In | Melee | 0.3 | a melee kill within 2 s of the saber's Force pull (`UBQS_SaberService` "pulled") |
| Twin Blades | Melee | 0.2 | a saber kill with a lit saber in each hand ("saber.lit") |
| Rally | Melee | 0.2 per earlier, to 0.6 | sent-back shots killing one after another, each within 3 s |
| Ring Out | Melee | 0.5 | a crusher, a pit or another monster killed it within 2 s of your Force, kick, punch or bash (you get the kill) |
| Ground Pound | Melee | 0.3 (replaces Slammed) | the Force jump's landing (LandSlam) killed it |
| Clean Sweep | Melee | 0.5 | the ShieldSaw thrown at 2+ locks killed the last of them, all dead |
| Bank Shot | Melee | 0.4 | the ShieldSaw's Ricochet (a Gun Bonsai upgrade) rang a new lock at a wall and killed it |
| Shield Wall | Melee | 0.25 | a kill while the shield in your hand blocked another monster inside the last second |
| Counter | Melee | 0.3 | a punch killed it mid-attack (its Missile/Melee states, or it fired within half a second) |
| Knockdown | Melee | 0.2 | a punch finished it while it reeled (its Pain state) |
| Flurry | Melee | 0.15 per punch past 2, to 0.45 | a glove kill ending left-right-left punches, each within half a second |
| Body Blow | Style | 0.3 | a corpse you threw with Distance Grab killed it |
| Hand-Me-Down | Style | 0.3 | a weapon that fell out of a monster, thrown, killed it |
| Hot Swap | Daring | 0.25 | a holster swap mid-fight: last kill with another gun at most 3 s before the draw, this kill at most 3 s after |
| Bullet Time | Style | 50% of the kill's style/daring/melee bonuses | a kill while RSQ_SlowMo has the world slowed (not inside Score's own pulse); was a flat 0.15, see The arcade layer |
| Two Guns | Style | 0.25 | a shot kill from one hand's trigger within a second of one from the other's |

Also: **Brawler** now pays the boxing gloves as fists (0.5) and follows replacements, so Brutal
Doom's fists (`Melee_Attacks`, which replaces Fist) pay it; it reads the striking weapon first, so
an off-hand glove's kill counts. **Juggle replaces Skeet** (one fact, the body in the air). A shot
**sent back** (Return to Sender) is no longer also judged as your own shot by No-Look, Blind-fire,
Off-hand, Full Hands or Two Guns.

Not built, and why: an uppercut finisher (the glove's punch kind is on the glove object, and the
patch exposes no service for it); a catch thrown back at the thrower (Distance Grab catches no
missiles); a push off a ledge (Doom monsters take no falling damage).

**Slow motion for big moments.** A kill that a bonus calls a big moment sends RSQ_SlowMo
`netevent rsm_pulse 600 35` (600 ms at 35% speed), from the earning player's machine only.
Big moments: Fatality, Perfect Riposte, Poetic Justice, Boomerang, Slammed, Heavy Swing at full,
Ring Out, Clean Sweep, Bank Shot, Rally from the fourth, Flurry at its top; Air Catch, Blind-fire,
Powder Keg from the third; of the original thirteen, Swan Song, Telefragged, Air from 0.5 (a
164-unit jump) and Redline at 5 HP or less. `rs_score_slowmo` (on) turns it off;
`rs_score_slowmo_cooldown` (6 s) spaces them. Measured: a pulse slowed the world for about 38
tics; a second big moment 40 tics later sent nothing; one 240 tics later did. Without SlowMo the
event goes nowhere. Bullet Time needs SlowMo's `slowmo.active` answer (RSQ_SlowMo branch
`agent-suite`); an older SlowMo still gets the pulses.

**The cap on one kill** (`rs_score_cap_kill`, 300 = bonuses at most 3x base, on by default, the
original's `rs_score_cap_total` renamed so an archived 0 cannot hide the new default). Measured
with Gun Bonsai's score-to-XP at 1: Swan Song + Telefragged + Point-Blank on a 60-health imp paid
306 points and 306 XP uncapped, 240 and 240 capped. The cap also holds on kills paid to every
player (Infighter, Darwin).

**Gun Bonsai, damage XP and score XP.** With both factors at 1 the same kill paid 300 XP: 240 from
score plus 60 from damage, which is the monster's health a second time (the base points ARE its
health). Keep `bonsai_damage_to_xp_factor` at 0 when score-to-XP is on.

**Slappers Only.** A plain glove kill pays Brawler 0.5 (a plain gun kill pays nothing), and the
gloves have Counter, Knockdown, Flurry, Juggle, Ring Out and Combo on top; the gun-only rows
(No-Look, Blind-fire, Off-hand, Two Guns, Full Hands, Quick Draw, Hot Swap) are worth about the
same in all. Measured with `rsq_slappers 1` on BD: jab 80 + 40, mid-attack 80 + 75.

**The lives effect on Quest.** What is left of it costs nothing measurable: a life spent is one
sound and one 20-tic tint, no actors. Measured in a Brutal Doom fight (30 imps, ~600 actors, rig
B): all of Score's per-tic work 0.004 ms a tic, the HUD 0.011-0.015 ms a frame with lives held,
the spawn hook 0.0005 ms an actor (it now compares class pointers, not names, because Brutal Doom
spawns hundreds of actors a second), 0.2-0.5 ms per scored kill (noisy rig).

## The arcade layer (10-27): the hook and the combos across mods

The suite's mods are tools for your hands; Score is the arcade room that pays for mixing them. No
monster class is named: it works over vanilla, Brutal Doom, Champions, LegenDoom or any set.
Brutal Doom-specific scoring is later. RSQ_Grapple's facts come from its own `RSQGR_Service`
(found by name; RSQ_Grapple branch `agent-svc`, its HANDOFF has the API); absent, every row here is
silent and nothing else changes.

**What already scored the suite, so nothing scores twice** (the table above, plus): saber --
Pulled In (Force pull), Twin Blades, Riposte/Perfect Riposte, Return to Sender, Poetic Justice,
Rally, Choked, Slammed, Ground Pound, Juggle, Hurled/Boomerang (thrown saber); ShieldSaw -- Shield
Work, Hurled, Boomerang, Ground Down, Clean Sweep, Bank Shot, Shield Wall, Riposte; Distance Grab --
Thrown, Powder Keg, Air Catch, Body Blow, Hand-Me-Down, Full Hands; Tactical Rig -- Quick Draw, Hot
Swap; SlowMo -- Bullet Time, big-moment pulses; VR -- No-Look, Blind-fire, Off-hand, Two Guns;
any melee -- Combo (distinct melee kinds in 4 s), Ring Out, Counter, Knockdown, Flurry, Boot,
Cleaved, Fatality, Heavy Swing; awards (non-kills) -- Deflect, Remote Down (the saber's remote).
The per-kill cap (`rs_score_cap_kill` 300) holds over all of it, these rows included.

**New rows** (multipliers of the kill's base = the monster's spawn health; measured firing on rig E,
vanilla doom2 and the full order, scripted scenarios on a test map, each fired once per kill):

| Row | Family | Pays | For | Measured |
|---|---|---|---|---|
| Reeled In | Melee | 0.3, +0.15 per earlier one inside 4 s, to 0.75 (replaces Pulled In) | the hook brought it (it came, or you reeled to a heavy one) and a melee blow finished it within 2 s of the line letting go | imp 60: 0.30 (+18), next in chain 0.45; full order BD imp 80 +24 |
| Ping-Pong | Style | 0.4, +0.2 per volley past one, to 1.0 | hooked, sent flying back AWAY (its own velocity, >= 6 u/tic), hooked again, killed by you | 2 volleys 0.60 (vanilla), 1 volley 0.40 (full order) |
| Bowling | Style | 0.5, +0.25 per later pin of one throw, to 1.25 | a body your hook threw struck it and it died of that (or you finished it inside 1 s) | Baron struck by a yanked imp: 0.50 = +500 on base 1000 |
| Hard Landing | Style | 0.3 | the throw's own landing / strike killed the hooked body | imp 0.30 (was Brawler 0.5 + Knockdown 0.2 as a "punch") |
| Fly Ball | Style | 0.35 (replaces Skeet, Juggle) | killed in the air while your hook was throwing it | imp shot 6 tics into the yank: 0.35 |
| Swinging | Daring | 0.35 (replaces Air) | a kill while a latched rope holds you off the ground | 0.35 both orders |
| Dismount | Daring | 0.4 (replaces Air) | let go of a swing in the air, killed before landing (within 3 s) or within 1 s of landing | 0.40 in the air, 0.40 five tics after landing |
| Lashed | Melee | 0.25 | the whip's crack killed it (was Brawler 0.5 with fists held) | 0.25 both orders |
| Variety | Style | 0.15 per tool past two, to 0.6 | a kill that brings a NEW tool into the fight (kills each within 10 s): shot, saber, shield, hook, Distance Grab throw, holster draw, hands/blades | gun+saber+hook+hands: 0.15 at the 3rd, 0.30 at the 4th; repeats 0 |
| Indiana Jones | Daring (award) | 150 + (dist-192)/2 points, to 500; once per gap per map | RSQ_Grapple: a roped flight left a floor, passed over one >= 64 lower than both ends, landed >= 192 units away in another sector | 429 / 427 points for a 751 / 747-unit crossing; second crossing "already paid"; after save/load x2 still paid; after a map change paid again |

Big moments (SlowMo pulse): Reeled In from the 3rd of a chain, Ping-Pong at 2 volleys, Bowling
always, Variety at 5 tools.

**Fixed on the way**: RSQ_Grapple's own blows land as `'Melee'` with no inflictor (a thrown body)
or the pawn as inflictor (the whip), and were read as punches -- Brawler 0.5 with fists held,
Knockdown 0.2 (a thrown body is held in its Pain state), Counter, Cleaved. They are `MK_HOOK` /
`MK_WHIP` now (`RS_Melee.KindOf` asks the service, which notes each blow before it lands), Brawler
and Cleaved skip them. Measured before/after on the same scene: yank landing kill
Brawler 0.5 + Knockdown 0.2 + Point-Blank -> Hard Landing 0.3 + Point-Blank; whip kill Brawler 0.5 ->
Lashed 0.25. **Ring Out** now also credits the hooker for a monster the hook let go of in the last
2 s that the level or another monster then killed (measured: 0.5, paid to the player, not to
everyone).

**Slow motion multiplies style, it is not an easy mode** (the owner). Bullet Time paid a flat 0.15
for any kill in slow motion. It now pays `rs_score_slowstyle` percent (50, menu Tuning "Slow Motion
Style") of the kill's style, daring and melee bonuses, and nothing on a plain kill (measured: Reeled
In 0.3 + Point-Blank 0.1 under `rsm_on` -> Bullet Time 0.20; a plain shot under `rsm_on` -> 0). The
new `AfterOthers` hook on `RS_ScoreBonus` (bonus.zs, called in the handler after the supersede pass,
before the caps) is how a bonus reads the others' answers.

**Monster mods** (the owner's order: Champions then LegenDoom Lite 4.2 after BD22Q, Champions'
`champion_legendoom 1, champion_dormant 1, champion_booster 1`): base points are `GetSpawnHealth()`,
so a LegenDoom legendary (health x3, StartHealth untouched) pays its class's base (BD imp 80 at
240 health) and a Champions champion pays its StartHealth (a bronze imp 160); every multiplier is on
that base and the 300 cap holds (measured with the cap at 50: the bonuses scaled to sum 0.50).
No runaway. A legendary at low health transforms and refills (LegenDoom's own rule): a yank landing
that "should" kill it does not, and nothing is paid until it really dies. Champions and LegenDoom
only touch monsters placed on the map, not ones spawned later.

**Not reachable yet**: Bowling's second pin -- a thrown body that strikes something is stopped dead
(RSQ_Grapple monster.zs), so one throw strikes one thing; the pin count is there for when it can
carry on. A path throw also hops over a monster shorter than its arc (its vertical move into a head
is refused), so bowling happens against tall monsters or in the low first part of the arc.

**Needs the headset**: whether Reeled In's 2 s and Ping-Pong's 5 s windows match real hook play;
whether 6 u/tic is the right "sent flying" line for the real Force push and BD kicks (scripted here
with a 20 u/tic shove); whether Indiana Jones' 192/64 thresholds catch real gaps on real maps and
not stairs; the popup rows' text is the HUD's existing breakdown (no HUD change).

## Boosted monsters (10-27): Champions and LegenDoom Lite

The kill names what it killed (`zscript/rsscore/boost.zs`), read by inventory, cvar and lump NAME, so
nothing links and every row pays 0 without the two mods. Daring family, charged against the per-kill
cap like any other row, and only on a player's kill (an infight pays base + Infighter as always).

| row | when | mult |
|---|---|---|
| `<Colour> Champion` (14 colours) | an active champion of that colour | 0.25 |
| Bronze / Silver / Gold Champion | the rare three (weights 3 / 2 / 1 against 10) | 0.5 / 0.5 / 0.75 |
| Titan, Undying | the mutation (Undying: its heart's death is noted first) | 0.5 |
| Ghost, Balloon, Hybrid | the mutation (Hybrid: two colour tokens, or one at amount 2) | 0.25 |
| Legendary | a LegenDoom Lite legendary that rose (half health, refilled), not a champion | 1.5 |
| Legend Denied | a legendary killed before it rose (its 300 % gone inside one tic) | 0.75 |
| Legendary Champion | risen AND an active champion -- the owner's "dormant boosted legendary champion" | 0.5 |

No double pay with the base (measured, rig C): a champion's base is its StartHealth, which Champions
sets after its own health change (a Bronze Titan imp: 780); a plain legendary's base is the class's (LegenDoom
Lite's ACS raises health, not StartHealth), so Legendary is the big row; a legendary champion's
StartHealth already holds LegenDoom's 300 % (dormant mode: Champions sets up on the transform, a Gold
legendary imp's base is 1200 = 80 x 3 x 5; out of dormant mode a legendary spawned in play is boosted
by LegenDoom first, a Bronze Titan imp 1740), so its row is the small one. In dormant mode a champion
LegenDoom never transformed never had a power and pays as a plain monster.

Champions' Indigo clones (`champion_CloneToken`) are not kills: Champions clears their COUNTKILL, and
with Brutal Doom (whose classes replace counted monsters) each one paid a full base -- 80 per imp
clone, measured; vanilla never paid them.

THE HOOK for a later monster set (RS Monsters' 13 colour tiers and its EX tier): subclass
`RS_ScoreTierRow`, answer `Token()` (the inventory class name the tier carries), `DisplayName()`,
`Mult()`, `Group()` (one row per group per kill, highest Mult wins), override `Active(v)` if a tier
can be dormant, and register the class from your own `StaticEventHandler.OnRegister` with
`RS_ScoreRegistry.RegisterBonus`. Extra bodies that are not kills: add the token to
`RS_Boost.NotAKill`.

## The combo system (10-27): the chain of tools on each monster

Every monster keeps an ordered history of the **tools** that touched it (`zscript/rsscore/combo.zs`,
the `RS_ComboLedger` level handler, saved with the level). A kill pays for the chain that led to it.
The owner's rules: **order matters**; the chain **breaks after 3 seconds** between moves (105 tics, from
the end of one tool's run to the start of the next, and from the last move to the kill); **guns count**
(every gun is the one tool `gun`; varying guns is Switcharoo's); named **signature combos come from a
data table**; an unnamed chain still pays as a **generic 2-, 3- or 4-tool combo**. No monster class is
named. The chain is one bonus (Style family) charged against the per-kill cap like any other; the
breakdown shows its parts as text rows (`Lion Tamer`, `3-Tool Combo`); the display is otherwise untouched.

**Tools** (read by name from the series' services and the blows themselves; an absent mod's tools never
appear): `gun`, `rig.draw` (a shot inside Quick Draw's 42 tics after a Tactical Rig draw), `saber.cut`,
`saber.throw`, `saber.return` (a shot the saber or the Force turned), `saber.block`, `force.push`,
`force.pull`, `force.grip` (choke and slam), `shield.bash` (bash or revved grind), `shield.disc`,
`shield.block` (the ShieldSaw blocked that monster, or a shot it turned struck it), `hook.bite`,
`hook.yank` (the hook threw it, or a body it threw struck it), `whip`, `grab.throw` (Distance Grab),
`kick`, `punch`, `glove`, `blade`, `finisher`. Blows are classified as they land (WorldThingDamaged);
what deals no damage is asked of each mod as "how long ago" at the next blow or the death (the hook's
`hooked`/`yanked`/`struck`, the saber's `pulled`/`gripped`/`blocked`, the shield's `blocked`), so the
order is kept. A yank is the bite's own follow-through: bite + yank count as one tool.

**Named combos** (the data table, `RS_ComboSeed.Combos`; names are PROPOSALS for the owner to veto).
Pattern steps in order, the last is the finishing blow, steps before may have other tools between them.
Measured on rig E (doom2, the suite + Gun Bonsai + the patch, scripted on a DoomImp, base 60), each
fired once on its kill:

| Combo | Pattern | Pays | Measured |
|---|---|---|---|
| Lion Tamer | whip > shield.bash | 0.5 | 0.50 (+30) |
| Clay Pigeon | force.push > gun | 0.5 | 0.50 |
| Sitting Duck | force.grip > gun | 0.5 | 0.50 |
| Pull! | force.pull > gun | 0.5 | 0.50 |
| Disc Jockey | force.push > shield.disc | 0.5 | 0.50 |
| Gun Kata | hands (kick/punch/glove) > gun | 0.4 | 0.40 |
| Fast Hands | melee > rig.draw | 0.5 | 0.50 |
| Lasso | whip > hook.yank | 0.5 | 0.50 (with Hard Landing 0.30) |
| Pitch and Slice | grab.throw > saber.cut | 0.5 | 0.50 |
| Circus Act | whip > hook.yank > gun | 0.9 | 0.90 (Lasso not also paid) |
| Yo-Yo | force.pull > force.push > gun | 0.9 | 0.90 (Pull!, Clay Pigeon not also paid) |
| Discus | shield.bash > force.push > shield.disc | 0.9 | 0.90 |

**Generic chains**: 2 tools 0.2, 3 tools 0.4, 4 or more 0.6 (measured 0.20 / 0.40 / 0.60, five tools
0.60). The same tool three times: nothing. A 110-tic gap breaks the chain (nothing); 100 tics does not
(0.20). Order: bash > whip is a 2-Tool Combo, not Lion Tamer. A named combo replaces the generic pay
for the tools it names: gun > whip > bash paid Lion Tamer 0.50 + 3-Tool Combo 0.20 (= 0.4 - 0.2).

**Today's rows folded in, pay kept.** Reeled In (hook > melee), Ping-Pong (hook > shove > hook), Fly
Ball (yank > anything, airborne), Bowling (a thrown body's strike > anything), Pulled In (Force pull >
melee), Riposte / Perfect Riposte (block > anything) are named combos backed by their own rows: they
pay as before and the chain pays nothing more for the tools they cover; a table combo must name a tool
they do not (a kick inside a Ping-Pong rally is not also Gun Kata). Measured: Riposte 0.40 (chain 0),
Reeled In 0.30 (chain 0) and 0.45 second-in-a-row with a gun first (+ 3-Tool part 0.20), Ping-Pong 0.40
one volley (chain 0), Pulled In 0.30, Hard Landing 0.30, Bowling 0.50 by the strike and 0.50 when a gun
finished it inside 1 s (chain 0). Swinging, Dismount, Lashed and Indiana Jones are unchanged.
**Changed, and why**: Variety (tools across a fight) and the melee Combo (kinds across kills) pay for
mixing tools too, so on a kill whose own chain mixed two tools or more they stand down (they still
remember the kill). Before, a Reeled In kill also paid Combo 0.10 + Variety 0.15; now Reeled In alone.

**For other mods** (no link): `RS_ScoreRegistry.RegisterCombo(name, pattern, mult)` /
`RegisterTool(id, groups)` from `OnRegister`, or by name through `RS_ScoreService`:
`GetInt("combo", "<name>|<pattern>", permille)`, `GetInt("tool", "<id>|<groups>")`, and
`GetInt("touch", "<tool id>", playerNumber, 0, monster)` to record a use. Measured: a probe mod's
"kick > saber.cut" at 650 paid 0.65; a touch through the service entered the chain (rig.draw > cut 0.20).

**Saved and carried**: a chain begun before a save and finished after a load paid (twice); a new map
starts clean. Big moment (SlowMo pulse): a three-step named combo, or four tools.

**For Gun Bonsai** (`RS_ScoreService`): `kill.serial` (intArg player), and for a serial (doubleArg)
`kill.style` (the kill's bonus points: total less base, every family, Champions' and LegenDoom's
rows included), `kill.base`, `GetString kill.chain` ("gun>whip>shield.bash", finisher last), `GetObject
kill.victim`. The Gun Bonsai VR patch's XP Source: Style reads these.

**Cost per blow (polish, 10-27, measured).** Every series question went through `ServiceIterator.Find`,
which makes an iterator object and walks every service in the game, lower-casing and searching each name
in the VM; the combo system asks several per blow (Classify) and per monster per tic (Poll). The services
each name matches are now found once (`RS_ScoreRegistry.EnsureSvc`, `zscript/rsscore/svc.zs`) and asked
directly; same services, same order, same answers. Rig B, the owner's full order, 18 Brutal Doom rifle
zombies sprayed with Brutal Doom's own puffs (`ShotgunPuff` / `MachineGunBulletPuff`, 20 LineAttacks a tic
for 10 s, ~5000 blows): Classify 29.6 -> 3.0 us a blow, Poll 56.4 -> 6.1 us a monster-tic, the whole
damage-event chain (every handler of every mod loaded) 79.5 -> 29.0 us a blow, the worst tic 2.30 ->
1.25 ms. The old and new lookups answered alike 3762 times out of 3762 (hook, shield, saber, rig, grab
and SlowMo requests, SlowMo on). The HUD's and the accessibility helper's ui-scope lookups are unchanged
(once per frame, not per blow).

**The living word** (`rs_score_alive`, on; Options -> Score -> Living Label): only the word "Score:"
moves: a slow pastel hue cycle (24 s), a breath (88-100 % every 4 s), warming toward gold in the last
quarter before a reward (and breathing twice as fast), full white easing back over a second after a
big combo. RSQ_Accessibility's Photosensitive Mode holds it still (only the slow warming); a colour-blind
setting drops the hue and the warming and keeps the breath. The number, bar and rows are unchanged.

**The ShieldSaw gauge** (the Gun Bonsai VR patch's `rsq_hud_shield`, off by default): while it is on,
the whole display moves down by as far as that gauge reaches below the hand gauges' top
(`RSQ_HudService "shield.gauge.drop"`, asked by name); off, or without the patch, nothing moves.

**Needs the headset**: whether 3 s is the right break for real play with every tool; whether the
proposed names and pays feel right; the touch timings of the real hook, Force pull and shield block
(scripted here through the same service calls the mods make); the living word's colours in the lenses.
