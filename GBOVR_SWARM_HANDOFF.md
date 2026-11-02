# Gun Bonsai VR: handoff for the local coding swarm

Written 2026-11-02 by the cloud lane, at the owner's request ("handoff for local coding swarm"). It is for coding
agents running on the owner's PC (`E:\DOOMWork\RSQ_UBQSeries`), with a shell, the real QuestZDoom 17.3 and his
headset.

**Read first, in this order:** `LOCAL_AGENT_HANDOFF.md` (the rules, the build, the load order),
`WHO_OWNS_WHAT.md`, then this file. Before anything else, run `git pull`.

The series is at 0.9; this pass (Gun Bonsai VR, then Score) is the last one before 1.0. Repo state at handoff:
`main` @ bae904e9f. BD22 VR Reloaded is at **2.0.3l** in the BD22 Weapons repo; its `pk3/` folder is gitignored, so
build it with `python build.py`.

---

## 1. What the owner wants (his words, 2026-11-02)

> "We start the game, we can punch. Once we level up the fist, we can unlock things to send us down paths. Does this
> make sense? Treat gunbonsai like a branching level up system for a comprehensive melee attack system."

> "Like, we unlock uppercut, or we unlock reflect imp fireballs, or we unlock punching bullets in slow mo (if we can
> work it more)... real game design shit... existing GunBonsai upgrades are of no value to this vr native melee
> path... maybe this could piggyback on distancegrab to allow for further throwing or headlocking larger enemies..."

> "Maybe grenade gets a dozen unique upgrades? The Saber upgrades and can unlock Force powers, and then specific
> force powers, or a second blade, or damage up or more lock ons (assume we change the default to 1 when GBOVR is
> loaded w sabers), the shieldsaw, the whip..."

> "since GunBonsai offers player levels, we could work those into grapple, allow it to be unlockable and
> upgradeable, same for some other things?"

> On art: "we own those gifs, we can recolor or spin them or scale them up and down" and "they could even be parts
> of the animation, as the attack levels up it gets more of the animation frames to seem more powerful."

> Melee is meant "to completely replace the need for weapons in a lot of instances."

**His decision on stock upgrades:** Gun Bonsai's own (stock) upgrades on our weapons are **an option**. Default:
hidden on all of our weapons, namely gloves/hands, both sabers, ShieldSaw, whip, grenade and grapple. BD22's guns
keep stock Gun Bonsai.

**Ownership (WHO_OWNS_WHAT.md):**
- **Gun Bonsai VR:** upgrades only, and only for the mods it detects. It unlocks and levels moves.
- **The mods:** each move's code lives in its own mod (Melee owns fighting with the body, Distance Grab owns
  objects, and so on). Gun Bonsai VR turns those moves on and scales them, asked by name or through a service.
- **Score:** scores only. Its pass comes after this one, and the owner gives the orders for it. Known item:
  rename Score's "Bullet Time" bonus.

---

## 2. Gun Bonsai facts (read from Gun Bonsai 0.10.6's own source, not from memory)

Source: `GunBonsai-0.10.6.pk3`, the `ca.ancilla.bonsai/` folder, plus `BONSAIRC`, `MODDING.md` and `UPGRADES.md`.
Never edit Gun Bonsai. All our work goes in `GunBonsaiOffhandVR/`.

- **How choices are offered** (`upgrades/Registry.zsc`, GenerateUpgradesForWeapon / ForPlayer):
  - On a level-up, GB collects every registered upgrade whose `IsSuitableForWeapon(info)` (or
    `IsSuitableForPlayer(stats)`) returns true and that `info.CanAcceptUpgrade(name)` allows.
  - It then shows a random `bonsai_upgrade_choices_per_gun_level` (default 4) of them. `-1` shows all of them.
- **Branching is possible.** `IsSuitableFor*` is ours to write, so an upgrade can require a parent upgrade
  (or a level of it) on the same weapon info, or a player level, or anything else. That is how paths are built.
- **Levels:** picking an upgrade you already own levels it up (`UpgradeBag.zsc`, `level` / `max_level`). This
  fits "more animation frames per level".
- **Player levels:** these work the same way through `IsSuitableForPlayer`. This is the route for "Grapple
  unlocks at a player level".
- **The hurdle: stock upgrades get into our pool.**
  - Each stock upgrade decides its own suitability, and many accept melee.
  - Today `GunBonsaiOffhandVR/bonsairc.rsq` only `disable`s the elemental and RapidFire upgrades on
    RSQ_Glove/GloveOff, UBQS_Saber/SaberOff and SSQ_ShieldSaw.
  - So stock upgrades like LifeLeech, Bandoliers, Juggler, Cleave, Sweep and Shield still roll on fists.
- **Way through, and it allows a menu option:**
  - `disabled_upgrades` is a public `array<string>` on `TFLV_WeaponInfo` (`WeaponInfo.zsc:83-89`).
    `CanAcceptUpgrade` just checks it.
  - BONSAIRC's `disable` fills it when the info is created (`RC.zsc:252`, `DisableUpgrades` = copy).
  - Our handler can **add or remove the stock names at run time** to follow a cvar.
  - Rules for that: keep BONSAIRC's own entries (append, never overwrite), re-sync when the cvar changes and
    when a new WeaponInfo is made, and only touch our weapons' infos.
  - BONSAIRC itself has no wildcard, so the stock list must be explicit. Our patch is pinned to GB 0.10.6;
    re-check the list if GB is ever updated.
- **The stock upgrade classes in 0.10.6**, from `ca.ancilla.bonsai/`: AcidSpray, AggressiveDefence, AmmoLeech,
  ArmourLeech, Bandoliers, Beam, BlastShaping, BouncyShots, BurningTerror, ChainLightning, Cleave,
  ConcentratedAcid, Conflagration, CorrosiveShots, DarkHarvest, DecoyFlares, ECM, ElementalBeam, ElementalBlast,
  ElementalSynthesis, ElementalWave, Embrittlement, ExplosiveDeath, ExplosiveShots, FastShots,
  FragmentationShots, Hallucinogens, HazardSuit, HomingShots, IncendiaryShots, Indestructable (only with that mod),
  InfernalKiln, Intuition, Juggler, LifeLeech, PiercingShots, PlayerDamage, PoisonShots, Putrefaction, RapidFire,
  Revivification, Shield, ShockingInscription, Submunitions, Sweep, Swiftness, Thorns, Thunderbolt, ToughAsNails,
  Weakness, WeaponDamage.
  - All carry the `TFLV_Upgrade_` prefix.
  - Helper classes are not upgrades: Dot*, *Util, Registry, UpgradeBag, BaseUpgrade, ElementalUpgrade.
  - Confirm this list against `BONSAIRC`'s `register` blocks before using it.
  - Player upgrades (Swiftness, ToughAsNails, etc.) are per-player, not per-weapon. Decide with the owner
    whether the option also hides them; the weapon-info array won't.
- **Netevents:**
  - `bonsai-level-up`: arg0 is 0 for a player level, 1 for a weapon level; arg1 is the level.
  - `bonsai-choose-level-up-option`.
  - Debug: `netevent bonsai-debug,w-up,<class> <levels>`, `w-xp <xp>`, `p-xp`, `info`, `reset`. Use these on
    the rig and in the headset to jump to levels.
- **Service:** `TFLV_GunBonsaiService` (`Service.zsc`). Find it by name, as always in this series.

---

## 3. What already exists in our patch (`GunBonsaiOffhandVR/rsq/zscript/`)

About 60 of our upgrades, registered in `bonsairc.rsq`, mostly in **one flat random pool**:

- **up_gloves.zs (gloves):** Haymaker, OneTwo, StarPunch, Counterpunch, BodyBlow, Knockdown, HeavyHands,
  ReturnFire (the Hadouken; class name kept for saves), WallSplat.
- **up_melee.zs:** Lunge, Executioner, Adrenaline.
- **up_saber.zs:** Momentum, RiposteEdge, PiercingReturn, SaberThrow, ChainChoke, DualHarmony, ForcePush,
  ForcePull, ForceChoke, ForceJump.
- **up_shield.zs (ShieldSaw):** Ricochet, MeatGrinder, HuntersReturn, Bulwark, Rebound, BatteringRam.
- **up_hook.zs (Grapple):** LongLine, FastReel, HeavyHaul, GetOverHere, Bowling, BarbedClaw, Slingshot, SteadyLine,
  DoubleHook.
- **up_suite.zs:** Broadening, Lockstep, Deflector, LongArm, IronGrip, HeavyHitter, AirCatch, PowderKeg, QuickDraw,
  PairDraw, Showdown, Marksman, Dodger, SecondWind, TimeDilation, Akimbo, Crossfire, Alternator, Evasion, Southpaw,
  SteadyAim, Guard.
- Also: stylexp.zs (style XP), shieldgauge.zs, service.zs, a11y.zs.
- **Missing entirely:** no whip upgrades and no grenade upgrades yet.
- **Melee's base-vs-upgrade split** (Melee/README.md):
  - The punch, the gloves/hands, the fist/palm toggle, the swat, the shove and the Headlock are base moves.
  - Guard, Hadouken, Wall Splat and Heavy Hands are Gun Bonsai VR upgrades when it is loaded; Melee's rows for
    them do nothing then.
  - The owner's new vision moves more onto paths. The uppercut, for example, becomes unlockable.
    **Proposed in the design doc, not decided.**

---

## 4. The work, as lanes

**Gate:** lanes L0 and L1 can start now. Every tree lane (L2+) builds only what the owner has approved in the
design doc (L0's output). Follow the rule "Discuss before new projects": propose, get his yes, then build.

### L0: audit and design doc (first)
1. Map every existing upgrade (section 3) onto the owner's vision: keep it (and which tree and parent), merge it,
   or cut it. Note what each does today in a single line, read from the code.
2. **Off-hand XP check:** GB credits XP to the current (main-hand) weapon.
   - Find out how our patch credits off-hand punches, the off saber and the off-hand whip.
   - Test with `netevent bonsai-debug,info` and real hits, on the rig and in the headset.
   - Per-hand trees depend on this answer.
3. Write **`GBOVR_TREES.md`**: one tree each for Fists, Saber, ShieldSaw, Whip, Grenade and Grapple, plus
   player-level unlocks. For every node give:
   - its name;
   - its parent(s);
   - what each level does, in numbers;
   - which mod owns the move;
   - its art (which effect, how many frames per level, recolour/rotate/scale);
   - the Score hook it would offer (just the name of the event; Score's pass is later).
4. The owner strikes or keeps each node. Ask him with pickable answers, a few nodes per question, never a
   wall of text.

**Starting proposals for L0 to refine** (these are the cloud lane's sketch, not decisions):
- **Fists:**
  - Power: uppercut lift → launcher → Wall Splat → ground pound.
  - Counter: Guard → swat upgrades → Hadouken (reflect) → punching projectiles in slow-mo (capstone).
  - Grappler: Headlock → throw → bigger enemies through Distance Grab's throw service → human shield.
- **Saber:**
  - Under Gun Bonsai VR, lock-ons start at 1 (`ubqs_locks`, which defaults to 5 today) and upgrades add more.
  - Force branch: unlock the Force, then a specific power (Push / Pull / Choke / Jump) per branch.
  - Second blade.
  - Damage.
- **ShieldSaw:** throw/return path, block path, saw path (from the existing six).
- **Whip:** new, about 6-8 nodes.
- **Grenade:** about a dozen nodes, e.g. cook control, cluster, sticky, flash, longer throw, bigger blast, faster
  fuse feedback, gore. All must fit RSQ_Grenade's BD22-VR-style handling.
- **Grapple:** unlocked at a player level, then the existing nine as its tree.

### L1: plumbing (can start now; needed for any tree)
1. **Stock-upgrade option:** a menu row in Gun Bonsai VR, e.g. "Gun Bonsai Upgrades on RSQ Weapons: Hidden / Shown",
   default Hidden. Make it a run-time sync of `info.disabled_upgrades` for our weapon classes (section 2). Show on
   the rig that a fist level-up offers no stock upgrade when it is set to Hidden, and that stock upgrades appear
   when it is set to Shown.
2. **Prerequisite helper:** one shared `RSQ_Upgrade_Base` function, `Has(info, "RSQ_Upgrade_X", minLevel)`, used by
   every tree node's `IsSuitableForWeapon`. Do the player-level equivalent too.
3. **Service for the owning mods:** a `GetInt("unlocked", "<node>")` / `GetInt("level", "<node>")` style query on
   Gun Bonsai VR's service, so Melee, Saber, Grenade and the rest ask by name and each still works alone.
4. **Weapon types:**
   - Make sure every RSQ weapon class that should earn XP has `type ... : MELEE` (or the right type) in
     `bonsairc.rsq`.
   - The Melee hands are still `RSQ_Glove` / `RSQ_GloveOff`.
   - Check the whip's, grenade's and grapple's classes.

### L2-L7: one tree per lane (after the owner approves its tree)
These are L2 Fists, L3 Saber, L4 ShieldSaw, L5 Whip, L6 Grenade and L7 Grapple, in that order unless the owner
says otherwise.
- The move itself goes in its owning mod. The unlock and the level go in Gun Bonsai VR.
- Without Gun Bonsai VR, each mod keeps its current menu-row behaviour.

### L8: art pipeline (with L2)
- **Art sources** (cloud copies: `/home/claude/scratch/art_melee/` with `NOTES.md`; the owner's Desktop has the
  originals and `Contact Sheets\`):
  - **kiddolink "VFX - HIT IMPACT":** bought by the owner, 5 impacts × 10 frames at 96×96. Recolour, rotate,
    mirror and scale freely. Credit kiddolink.
  - **CvS2 hit sparks:** non-commercial, Capcom's. Melee already ships NormalSpark/SpecialSpark/SuperSpark/Guard
    set 1 as MLSN/MLSS/MLSU/MLGD; Slash and colour sets 2-4 are unused.
  - **Random Sprite Rips:** 78 sheets of projectiles, dust, beams and rings.
- **Frames by level:** a level-1 hit plays only the first part of its impact, and each level adds frames
  (and optionally scale and colour) until it plays the full burst.
- Melee's `Melee/tools/sparks.py` already does keying, cropping and scale. Extend it rather than writing a new
  tool.
- Size rule from the owner: sparks are about a monster's head (Melee's current sizes, 2026-11-02); there is a Hit
  Spark Size slider.

---

## 5. Known limits (say these to the owner plainly; don't promise around them)

- **Punching bullets:** most Doom bullets are hitscan traces, not actors, so there is nothing in flight to punch.
  Only real projectiles can be punched; some BD22 guns fire real projectiles. Scope the capstone to what is
  catchable.
- **Off-hand XP:** unknown until L0 checks it (section 4).
- **Two-handing (BD22 VR, Two-Hand Aim)** is not part of this pass. It is BD22-only by the owner's rule: grip points
  must come from measured meshes.
- **Do not use the BD22 Weapons repo's hand-posing toolset** (tools/handfit) for new hand poses without the owner's
  explicit yes. It is very expensive to run. The FBX slap hand reuses `fbx_oh_free_R.md3` frame 0 for that reason.

---

## 6. Done means

- Zero script errors from our packs on doom2 alone and on the owner's full order. The 4 BD_VoxelPack voxeldef
  errors are the parent's own.
- Each node shown working: a frame or a log of the behaviour, and the level-up offering it only once its parent is
  owned. Label VR-only behaviour "rig only, not headset-confirmed" until the owner confirms it.
- READMEs short and correct; remove lines your change makes wrong.
- Commit only the pk3s you changed. Messages end with the two attribution lines in LOCAL_AGENT_HANDOFF.md section 2.
- Questions to the owner come with answers to pick from. Never wait silently; never tell him he stopped something.
