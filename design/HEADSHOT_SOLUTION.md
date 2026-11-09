> **Owner rulings, 2026-11-09 08:08:** RSQ Score's Headshot must see Brutal Doom's head shots. ColorfulHell monsters need
> head shots. MeatGrinder monsters need head shots. MK Crits is not the answer ("it is actor heavy"). The agent's seven
> open questions (end of this file) wait until the Miniboss questions now in progress are done.
> Q1 (scope) is read from these rulings as **every monster** (BD, CH and MG all need it).
> Q2 (08:57): **head-shot damage for all** ("headshots for all"): CH, MG and other packs get the head bonus too.
> Q3 (08:57): a 1.25x monster's HITBOX scales with it.

# A real head-shot check for the RSQ UBQ Series (design only; nothing built)

Written 2026-11-09 for the owner (presidentkoopa), after "we will need a real headshot fix" (design/MINIBOSS_REWORK.md:7-10).
Research by reading only: no engine or rig runs were made for this paper (owner's rule for this batch). Every engine claim
cites the QuestZDoom 17.3 source (tag `qzd17.3` of github.com/emawind84/gzdoom, the tag the engine survey uses:
rsq_questenginesurvey/surveys/_BASELINE_FACTS.md:3). Brutal Doom claims cite files inside `brutal22test6.pk3`.
**Nothing here is shown working. All of it is "code read", not "rig shown", and none of it is headset-confirmed.**

## Summary (read this if nothing else)

1. **How BD decides a head shot today.** Two separate systems, both by fixed numbers:
   - *Small monsters (zombieman, shotgunner, chaingunner, imp):* the monster's **blood actor** checks its own height above
     the floor under it, `(z - floorz) > 46` (50 for the chaingunner). On "head" it gives the monster a `HitHead` token
     and runs ACS `Head_Shot`, which deals **+30 damage of type `Head`** (x1.3 on these monsters). The death states read
     `HitHead` a few tics later and play the head gore.
   - *Big monsters (baron, knight, arch-vile, revenant, mancubus, cyberdemon):* an invisible **head hitbox** monster is
     glued at a fixed height above them (e.g. +56..+62 units). Damage to it is doubled and passed to the monster as `head`.
   Neither looks at the monster's real size, its own feet, or a resize.
2. **What breaks.** A 1.25x miniboss gets chest hits counted as head hits; a shrunken Champions clone (Indigo's 0.75x
   clones) can **never** be head-shot (46 is above its whole 42-unit body); a monster on a ledge or in the air is judged
   from the wrong floor. **And two bigger findings:** (a) in the series' **default monster set (ColorfulHell)** no monster
   has any head shot at all, because CH monsters use BD's plain blood, which has no head check; (b) **RSQ Score's Headshot
   row cannot see BD's head hits**: BD deals its head damage with the *monster itself* (blood route) or the *hitbox*
   (hitbox route) as the attacker, and Score ignores blows whose attacker is not a player (Score/zscript/rsscore/combo.zs:125).
3. **Recommendation: one verdict, decided once per blow, from the monster's real collision box, then handed to BD in
   BD's own words.** It lives in **RSQ Monsters** (no new pk3). It:
   - decides "head" when the hit point is in the **top 20% of the monster's own collision box** (`pos.z + 0.80 x Height`
     up to the top), measured from the monster's own feet, never the floor; 0.80 is BD's own ratio (46/56 = 0.82);
   - decides at the moment of damage (event `WorldThingDamaged`, from the bullet's puff or the missile's position), and
     stamps the answer on the monster;
   - **swaps BD's five head-checking blood classes for exact by-name copies** (an event-handler replacement, BD untouched)
     that use the stamp instead of `z - floorz`, then do BD's own head actions by name (`HitHead`, ACS `Head_Shot`). So BD's
     gore, death states and +30 Head damage all still happen, BD's way, but on our verdict;
   - answers `headshot` for every monster through the existing `RSQMN_RosterService`, so **Score's Headshot row and
     `+head` combos work with no change to Score** (one line changes in Monsters/zscript/monsters/RS_ScoreReadout.zs:63).
4. **Scope is the owner's call:** (A) miniboss + thralls (+ any resized monster) only, everything else exactly BD; or
   (B) every monster. Off = exactly BD (the copies reproduce BD's fixed numbers byte for byte).
5. **Open questions** are at the end (scope, damage bonus for non-BD monsters, the miniboss's box, hitbox monsters).

---

## Words used here

- **Hitscan:** an instant bullet: the engine draws a line from the gun and whatever it meets is hit at once (pistol, rifle,
  shotgun pellets, BD kicks). **Projectile / missile:** a flying actor (rocket, plasma ball) that hits when it touches.
- **Puff:** the small actor the engine spawns where a hitscan bullet lands. For a hit on a monster it is the
  **inflictor** (the thing that delivered the damage); the **source** is who fired.
- **Blood actor:** the actor the engine spawns where a monster is hit (its `BloodType`). BD hides its head check inside it.
- **Damage type:** the name a hit carries (`Bullet`, `Head`, `Melee`...). Monsters pick their pain and death animations
  by it (`Death.Head`, `Pain.Head`).
- **Token:** an invisible inventory item used as a flag (`HitHead`).
- **Collision box (Radius, Height):** the invisible upright box the engine actually shoots at. It is **not** the sprite
  or the 3D model. **Scale** only changes the picture; it does **not** change the box.
- **floorz:** the height of the floor under an actor.
- **Event handler:** a script object that hears world events (a thing damaged, spawned, died) without owning any monster.
- **Service:** a by-name question/answer object; how our mods talk without linking (`RS_Svc`, `RSQMN_RosterService`).
- **Deterministic:** every machine in a network game computes the same answer from the same game state.

---

## 1. How Brutal Doom decides a head shot today

### 1a. The blood route (zombieman, shotgunner, chaingunner, imp)

Which monsters: `Imp` (actors/Enemies/Imps.dec:36), `RifleZombie` (Zombiemen.dec:59) use `Blood_Imp`; `ShotgunGuy1`
uses `Blood_Zombies` (Sergeants.dec:44, which inherits Blood_Imp's check); `ChaingunGuy1` uses `Blood_Comando`
(Comando.dec:38). Also `SitZ_Blood` (sitting/slumped zombies), `Blood_BWSS` (WCS/BWSS.dec:52), and the WCS
EEEVILLL/Evinty monsters on `Blood_Imp`. BD's "Vanilla*" alternates (PlayerClasses/VanillaMonsters.dec:767-1719) use
`Blood_Noble/Fatso/Archie/Cybie/Bones`.

The check (actors/Gore/BloodTypesMonsters.dec):

| Blood class | Head if `z - floorz >` | Leg if `<` | Lines | Monster Height | ratio |
|---|---|---|---|---|---|
| Blood_Imp (and Blood_Zombies) | 46 | 25 | 17-18 | 56 | 0.82 |
| SitZ_Blood | 21 | 25 | 107-108 | (slumped) | - |
| Blood_BWSS | 43 | 25 | 124-125 | - | - |
| Blood_Noble | 54 | 25 | 143-144 | 60 (baron) | 0.90 |
| Blood_Fatso | 54 | 25 | 178-179 | 60 | 0.90 |
| Blood_Archie | 56 | 25 | 205-206 | 56 | 1.00 |
| Blood_Cybie | 96 | 25 | 222-223 | 96 | 1.00 |
| Blood_Comando | 50 | - | 240 | 60 | 0.83 |
| Blood_Bones | 66 (then metal >48, guts >40) | - | 324-326 | 56 | - |
| (saw bloods) Blood_Imp_Saw / Blood_Comando_Saw | 46 / 50 | 25 / - | 57-58 / 264 | | |

Heights from Enemies/*.dec: Imps.dec, Zombiemen.dec, Sergeants.dec Height 56; Comando.dec Height 60; Baron.dec Height 60;
Cyberdemon.dec Height 96.

What "HeadShot" does (BloodTypesMonsters.dec:23-31): `A_TakeFromTarget("HitLeg")`, `A_GiveToTarget("HitHead", 1)`,
`ACS_NamedExecuteWithResult("Head_Shot")`. The blood's `target` is the bleeding monster because the blood has
`+PUFFGETSOWNER` (line 3) and the engine then sets `th->target = originator` (src/playsim/p_mobj.cpp:6435). Not-head
and not-leg removes both tokens (lines 19-20).

ACS `Head_Shot` (src/Inputs.acs:1111-1119 in the pk3, compiled into acs/BD_Main.o via BD_Main.acs:25):
`SetActivatorToTarget(0)`; if the monster is not `IsDown` and not `IsCrouching`: `Thing_Damage2(0, 30, "Head")`.

- So **the head bonus is +30 damage of type `Head`**, scaled by the monster's `DamageFactor "Head"`: 1.3 on the zombieman
  (Zombiemen.dec:33), shotgunner (Sergeants.dec:32) and imp (Imps.dec:19); 1.0 on the chaingunner (none set). With
  `PainChance "Head", 256` the survivor plays `Pain.Head` (Zombiemen.dec:431).
- **Who BD says dealt it:** `Thing_Damage2` with tid 0 damages the activator with the activator as source:
  `EV_Thing_Damage` -> `P_DamageMobj(actor, NULL, whofor0, ...)` with `actor = whofor0` (src/playsim/p_things.cpp:398-412;
  the ACS call site src/playsim/p_acs.cpp:10089). **The Head blow's attacker is the monster itself, and it has no inflictor.**
- The **death animation** is chosen by the killing blow's damage type, then BD's death states read the token after a short
  wait, e.g. `Death.Shotgun`: two 1-tic frames, then `A_JumpIfInventory("HitHead", 2, "Death.HeadExplode")` /
  `("HitHead", 1, "Death.Head")` (Zombiemen.dec:680-685); `Death.SniperDamage` waits 4 tics then reads it (789-791);
  `Death.Head` picks decapitation / head explode / minor head by weapon and overkill (1110-1120). The wait matters:
  see 2a, the blood is spawned *after* the damage.
- There is **no other head damage multiplier** in BD's ZScript: zscript/DamageHandler.zc only multiplies all monster and
  player damage on skill 6+ (lines 26-85). `HeadshotHandler` (Inputs.acs:1121-1135) is the hitbox route below.

### 1b. The hitbox route (baron, knight, arch-vile, revenant, mancubus, cyberdemon)

These monsters spawn a separate invisible shootable monster and glue it above themselves every 2 tics with `A_Warp` to
the master at a fixed offset:

| Monster | Hitbox (actors/MISC/Head_Sys.dec) | Spawned at (Enemies/*.dec) | Glued at (Head_Sys.dec) | Hitbox size |
|---|---|---|---|---|
| Baron | Baron_NobleHeadshot | +62 (Baron.dec:118) | fwd 10, +60 (884) | r18 h24 (853-854) |
| Hell Knight | Knight_NobleHeadshot | +60 (Knight.dec:73) | fwd 10, +56 (900) | r18 h24 |
| Arch-vile | Vile_HeadHitbox | +58 (ArchVile.dec:63) | fwd 16, +58 (842) | r16 h20 (833-834) |
| Revenant | BonesHeadshot | +62 (Revenant.dec:767) | fwd 16, +56 (976) | r7 h18 |
| Mancubus | MancuHeadshot | +56 (Mancubus.dec:99) | fwd 2, +56 (951) | r12 h16 (941-942) |
| Cyberdemon | NewCybersHitBox | +96 (Cyberdemon.dec:105) | fwd 2, +98 (996) | r32 h24 (986-987) |

When the hitbox is hurt (`HeadHitbox` pain states, Head_Sys.dec:653-711) it runs ACS `HeadshotHandler` (health lost x2,
Inputs.acs:1121-1135) and `A_DamageMaster(user_headDamage, "head")` (also "decaptate", "fire", "plasma",
"ExplosiveImpact" by the weapon's type), then heals itself. The hitbox has its own damage factors (Sniper 5, SSG 5,
Saw 3, Shotgun 1.5; Head_Sys.dec:633-635). `A_DamageMaster` with default pointers uses **the hitbox as both inflictor and
source** (src/playsim/p_actionfunctions.cpp:4108-4123 -> `DoDamage` -> `P_DamageMobj`, 3997-4022). Death states then
read `HitHead` too (Baron.dec:584, Knight.dec:291, ArchVile.dec:216, Revenant.dec:543, Mancubus.dec:394).

### 1c. Melee and projectiles

- **BD melee (kicks, punches)** goes through the engine's hitscan code with a puff (`LAF_ISMELEEATTACK`,
  p_map.cpp:4736), so it gets the same blood check if its puff lets blood spawn. (Whether each BD kick puff carries
  `PUFFONACTORS`/`BLOODLESSIMPACT`, which skips the blood, was not checked.)
- **Saws and axes** (`+WEAPON.AXEBLOOD`, e.g. BD Axe.dec:4, our Saw.dec:6) take the engine's blood-*splatter* path, which
  spawns `BloodType2/3` (the saw bloods: p_mobj.cpp:6528, 6567), not the head-checking `BloodType`.
- **Projectiles** (rockets, plasma) spawn **no** `BloodType` actor when they hit (only wall decals, and splatter if the
  missile has `BLOODSPLATTER`): src/playsim/p_map.cpp:1352-1381. So **a BD projectile is never a head shot** on the blood
  route. It can be one on the hitbox route (the missile touches the hitbox).
- **RSQ Melee punches** spawn the blood at the glove's contact point *before* dealing damage
  (Melee/zscript/rsqml/gloves.zs:1334-1335), so a punch at a BD zombie's head already runs BD's blood check.

### 1d. Where it goes wrong (from the code above)

- **Floor, not feet.** `floorz` is the floor under the *blood*, set when it spawns (p_mobj.cpp:4879-4892). The blood
  spawns at the hit point on the box's skin. A monster at a ledge edge, on stairs, on a lift or knocked into the air is
  judged from the wrong floor: a chest hit over a lower floor becomes a head shot; a head hit on an airborne monster can
  read as anything.
- **Fixed numbers.** `46` is absolute. A 1.25x miniboss with a 70-unit box: everything above 46 (66% up, the chest) is
  "head". A Champions Indigo clone (`A_SetSize(Radius*0.75, Height*0.75)`,
  mk-champions zscript/champions/champs/champ_indigo.txt:64) is 42 tall: no hit can ever be above 46, **no head shots**.
  Hitboxes sit at a fixed offset too: on that clone the hitbox floats above its head; on a bigger monster it sits on the
  shoulders.
- **Scale is not size.** The engine shoots the collision box (src/playsim/p_trace.cpp:679-711 tests only `Top()`, `Z()`
  and `radius`). Scale draws a bigger picture but the box stays. **If our miniboss is scaled 1.25x without growing its box,
  its drawn head is above its box and bullets pass straight through it**: no head shot is possible by any method.
- **Noise.** The blood is spawned 0..4 units above or below the hit (`pos.Z += Random2()/64`, p_mobj.cpp:6422); the puff
  likewise (6321). BD's check has this noise today; ours will too (about 7% of a 56-unit body).
- **Crouch / knocked down.** BD does not shrink the box (no `A_SetSize` anywhere in BD's actors). `Head_Shot` refuses the
  +30 when the monster has `IsDown` or `IsCrouching`, but the blood still gives `HitHead`.
- **Nothing for non-BD monsters.** ColorfulHell monsters (the series' default set, Monsters/README.md) derive from
  `RS_MonsterMaster : Actor` (Monsters/zscript/monsters/RS_MonsterMaster.zs:188) and set no `BloodType`, so they bleed
  `Blood`, which BD replaces with `Brutal_Blood` (actors/Gore/Blood.dec:3), which has no head check. MeatGrinder monsters
  have their own band (1c-bis below). Monster packs: whatever they ship.

### 1-bis. What our mods do with head shots today

- **RSQ Score** marks a blow `+head` if its damage type is `Head`, `MinorHead` or `Headshot`, else if RSQ Monsters
  answers `headshot` = 1 (Score/zscript/rsscore/combo.zs:144-155); the Headshot row needs the killing blow's `+head`
  (rows.zs:999-1016). **But** the ledger drops any blow whose source is not a player (combo.zs:122-126). BD's `Head`
  blow has the monster as source (1a), the hitbox route's `head` blow has the hitbox as source (1b). **So by the code,
  Score's Headshot row never fires on a BD monster.** (Not shown on the rig; it is the first thing the test plan checks.)
- **VisualRewards damage numbers** show HEADSHOT on damage types Head/MinorHead/Headshot/decaptate or a hitbox inflictor
  (VisualRewards/pk3/zscript/rsqthp/damnums/events.zs:124-133). They do not filter by source, so BD's Head blow shows.
  Rig evidence: VisualRewards/test/evidence/dn2_e_ALONE.txt:16 ('4HEADSHOT' on a Zombieman).
- **RSQ Monsters' MeatGrinder set** decides in its own `DamageMobj`: head if the inflictor's z is in the top
  `rsq_mg_head_zone` (0.22) of the monster's height (Monsters/zscript/monsters/meatgrinder/RS_MGMonsters.zs:224-241;
  CVARINFO.txt:1197); Score reads it through `RSQMN_RosterService "headshot"` (RS_ScoreReadout.zs:63).

---

## 2. What the engine tells us at the moment of a hit (QZD 17.3)

### 2a. Hitscan (bullets, BD kicks, VR guns)

`P_LineAttack` (src/playsim/p_map.cpp:4714-5114), in this order:
1. `WorldHitscanPreFired` event (4718): angle, pitch, damage, puff class; may cancel the shot.
2. In VR the line starts at the **controller**: `fromPos = AttackPos` (or `OffhandPos`) when `OverrideAttackPosDir`
   (4784-4799). The trace hits the first collision box on the line (p_trace.cpp:679-711).
3. On a monster: `bleedpos = trace.HitPos`, the exact point where the line entered the box (5011).
4. **Damage first:** a puff (temporary if invisible) is spawned at that point and passed as the inflictor:
   `P_DamageMobj(trace.Actor, puff, src, damage, damageType, DMG_INFLICTOR_IS_PUFF | ...)` (5052-5077). The puff's z has the
   0..4 unit noise (p_mobj.cpp:6321) unless `LAF_NORANDOMPUFFZ`.
5. **Blood second:** the victim's `SpawnLineAttackBlood` (5080-5092 -> zscript actors/attacks.zs:873-896) ->
   `SpawnBlood` -> `P_SpawnBlood` (p_mobj.cpp:6417-6508).
6. `WorldHitscanFired` event (5106) with the exact start and hit point (`AttackPos`, `DamagePosition`), **after** damage
   and blood, so too late to steer BD.

`P_DamageMobj` fires `WorldThingDamaged` **after** health is taken and, on a killing blow, **before** the death starts
(`WorldThingDamaged` then `CallDie`, src/playsim/p_interaction.cpp:1611-1615; non-lethal: 1630-1633). The event carries
`Thing`, `Inflictor`, `DamageSource`, `Damage`, `DamageType`, `DamageFlags`, `DamageAngle`
(src/events.cpp:1942-1957). It **cannot change the damage** (`NewDamage` is only for line/sector damage, events.zs:91-98),
and it has **no hit position**: the position is the inflictor's (the puff).

**Rig evidence consistent with this order** (VisualRewards/test/evidence/merge_vr_full.txt:18): a shotgunner shot "aim z
52 over its floor: health 40 -> 25, HitHead 0", then "died ShotgunGuy1 health -14": the bullet's 15 landed with no
token yet; 39 more (= 30 Head x 1.3) followed from the blood.

How the blood's check is timed (p_mobj.cpp:6448-6492): for damage under 9 the engine starts the blood 2 states into its
Spawn sequence, 9-12 one state in, at once inside `P_SpawnBlood`; for 13+ the first state's `NoDelay` action runs on the
blood's first tick (p_mobj.cpp:4477, 4545-4569). BD's check is the 3rd state, so both paths reach it, and `target` is
set before either (6435).

### 2b. Projectiles

`P_DoMissileDamage` (p_map.cpp:1352-1381): `P_DamageMobj(victim, missile, missile->target, ...)`. The inflictor is the
missile, at its position **before** this tic's move (the touch is found by `P_CheckPosition` at the new spot, 1696-1710).
So the hit height is the missile's centre z, clamped into the victim's box. Good to a few units for normal speeds.

### 2c. Direct damage (RSQ Melee, scripts)

`DamageMobj` called by script: inflictor is whatever the caller passed. RSQ Melee passes a glove-blow actor spawned at
the contact point (Melee/zscript/rsqml/core.zs:118-127, gloves.zs:1335), sometimes the player pawn (no position: never a
head). Explosions pass the bomb spot with `DMG_EXPLOSION` (p_map.cpp:6677): never a head.

### 2d. Other facts we lean on

- Engine ZScript in the rig's qzdoom.pk3 matches the tag (`actor.zs` and `events.zs` compared identical).
- `GetBloodType` asks `GetReplacement` (zscript actors/actor.zs:607-633), which asks every event handler's
  `CheckReplacement` first (src/gamedata/info.cpp:618-626). **So a handler can swap a blood class by name without
  touching BD.** `ReplaceEvent` has `Replacee`, `Replacement`, `IsFinal` (events.zs:133-138).
- `WorldThingSpawned` fires inside `Spawn` (p_mobj.cpp:5148-5151), before `P_SpawnBlood` sets `target`.
- `WorldTick` runs before all thinkers each tic (src/p_tick.cpp:170-173).
- Handlers run in `Order`, lowest first (src/events.cpp:285-293); static handlers before level handlers (791-801).
- Puffs carry `damagesource` (the shooter) (p_mobj.cpp:6344), and face the shooter (`Angles.Yaw = hitdir + 180`, 6347).

### 2e. How reliable, in VR

- The hit point is where the **hand's** line met the box: real geometry, already what BD uses. No eye/hand problem for us.
- We should **not read `AttackPos`/`HmdPosition` ourselves**: they are written by the renderer once a frame for the
  camera player (_BASELINE_FACTS.md section 3; Melee/zscript/rsqml/core.zs:252-254), so they are not game state another
  machine shares. Everything the verdict needs (the monster, its box, the inflictor's position) is game state.
- Noise: 0..4 units on puff and blood z (above). Steep downward shots can enter the box through its top face
  (p_trace.cpp:681-696): the hit z is then the top, which we read as head. Reasonable: that is the head/shoulders.

---

## 3. A head region that follows the monster

**The rule:** head if `hitZ >= pos.z + f x Height` (and not above `pos.z + Height + 2`), where `pos.z` is the monster's
own feet and `Height` its **current** collision box height.

- **`f = 0.80` by default.** It is BD's own ratio (46/56 = 0.82 for zombies and imps, 50/60 = 0.83 for the chaingunner)
  and close to MG's 0.78 (1 - 0.22). One server cvar; an optional per-family table (by the class the monster replaces,
  `GetReplacee`) can hold BD's other ratios if the owner wants them (baron 0.90, cyberdemon 1.0 = only its hitbox).
- **No head at all** for families BD gives none: cacodemon, pain elemental, lost soul, demon/spectre, arachnotron,
  spider mastermind (their bloods have no head check in BD). Default list, cvar-switchable.
- **Feet, not floor:** fixes ledges, stairs, lifts, 3D floors and airborne/knocked monsters in one stroke.
- **Scaled minibosses:** the miniboss must grow its **box** with its picture: `A_SetSize(Radius*1.25, Height*1.25)` with
  `Scale*1.25` (Champions does exactly this for its clones, champ_indigo.txt:64-65). Then `f x Height` follows by itself.
  Without the box change no head-shot system can work (1d). A debug line flags any monster whose `Scale.Y / default
  Scale.Y` differs from `Height / default Height` by more than 10% ("drawn bigger than its box").
- **Champions / LegenDoom / RSQ tiers:** anything that calls `A_SetSize` is followed automatically. LegenDoom 3.0 never
  resizes a monster (no `A_SetSize`/owner `Scale` write in LegenDoom_3.0.pk3, by grep). RSQ Monsters' tier table can set
  radius/height/scale (RS_MonsterMaster.zs:82-84): followed as long as height is set with scale.
- **Crouching / knocked down:** BD does not shrink the box (no `A_SetSize` in BD). Mirror BD: `IsDown` or `IsCrouching`
  (by name) = never a head.
- **Pitch/lean:** Doom monsters' boxes never tilt; a model leaning forward still has an upright box. Not modelled (limit).
- **Hit height per kind of blow:** hitscan and BD melee: the puff's z. Projectile: the missile's centre z clamped into the
  box. RSQ Melee: the glove-blow actor's z (or RSQ Melee's own `punch.height`, which Score already reads, rows.zs:136).
  Explosion, no inflictor, inflictor = the shooter: never a head.

---

## 4. How our verdict reaches BD and Score without editing brutal22test6

| Way | Can it work? | Verdict |
|---|---|---|
| Change the damage type of the bullet to `Head` before BD sees it | **No.** No pre-damage hook for monsters we don't own; `WorldThingDamaged` is after the fact and read-only (2a). | Rejected |
| Override `DamageMobj` | Only on our own classes (MG does). BD, CH-pack and LegenDoom monsters are not ours. | Our classes only |
| Fix things up after BD's blood ran | **No.** BD's blood has already dealt +30 Head damage and given the token; damage cannot be taken back cleanly. | Rejected |
| Nudge the blood's `floorz` in `WorldThingSpawned` so `z - floorz` lands on our side of BD's number | Possible (`FloorZ` is writable, actor.zs:123) but fragile: `target` is not set yet (we must find the victim by geometry), and whether the engine refreshes `floorz` before a 13+ damage blood's first-tick check was not verified. | Fallback only |
| **Swap BD's head-blood classes for by-name copies (event-handler `CheckReplacement`)** | **Yes.** The engine asks handlers when it picks the blood class (2d). The copy keeps BD's state layout, flags and visuals, reads our verdict, then gives `HitHead` / runs ACS `Head_Shot` by name, exactly as BD's `HeadShot` state does. No BD file is touched, no class inherits from BD (so the pk3 still loads without BD). | **Recommended** |
| Give `HitHead` ourselves in `WorldThingDamaged` | Works for the death choice (event is before `CallDie`, 2a) but BD's blood, running after, would take it away again unless the blood is swapped. | Part of the hitbox plan |
| Publish our own head-shot event/answer | **Yes**, and needed anyway: CH/MG/pack monsters have no BD route; Score cannot see BD's route (1-bis). | **Recommended** |

**BD effects we can drive** (all by name, all already BD's own): the `HitHead` token (death states pick Death.Head /
HeadExplode / Decaptate, Pain.Head), ACS `Head_Shot` (+30 `Head` damage with BD's IsDown/IsCrouching rule), `HitLeg`
(leg deaths). **We cannot** change which `Death.<type>` state the engine picks for the killing blow (it is the blow's own
damage type), change BD's hitbox offsets (fixed in its `A_Warp`), or touch BD's saw/axe bloods' internals (we leave them).

---

## 5. Recommendation: "RSQ Head Check", inside RSQ Monsters

### 5a. Where and why

Inside **RSQ Monsters** (`Monsters/zscript/monsters/headcheck/`, names `RSQHC_*`):
- it owns the monsters' bodies, already answers Score's `headshot` (RS_ScoreReadout.zs:63) and already has the MG head
  band, which can read the same verdict so the series has **one** answer;
- no new pk3 (the owner's no-new-mods rule; WHO_OWNS_WHAT.md);
- limit: Miniboss loaded **without** RSQ Monsters gets BD's fixed numbers. (Alternative: a tiny separate pk3 "RSQ Head
  Check"; cleaner, but a new mod. Owner's call.)

### 5b. The pieces

1. **`RSQHC.Verdict(victim, hitZ)`**: the rule of section 3. Pure game state, no randomness, no controller reads,
   server cvars only (`rsq_hc_scope`, `rsq_hc_frac`, `rsq_hc_debug`).
2. **The stamp (`RSQHC_Handler.WorldThingDamaged`, `SetOrder(-100)` so it runs before Score's ledger).** For a blow by a
   player (source, or the inflictor's `target`/`damagesource`) with a positioned inflictor, compute the verdict and stamp
   the victim: tic, verdict (head/body/leg), hit fraction. Stored like RS_TierStamp, a plain token. Lethal blows are
   stamped before the death starts (p_interaction.cpp:1611-1615).
3. **The blood swap (`RSQHC_Handler.CheckReplacement`).** By name: `Blood_Imp`, `Blood_Zombies`, `Blood_Comando`,
   `SitZ_Blood`, `Blood_BWSS` -> `RSQHC_Blood_Imp` ... (phase 2: BD's Vanilla* bloods `Blood_Noble/Fatso/Archie/Cybie`;
   `Blood_Bones` and the saw bloods stay BD's). Each copy:
   - has BD's flags (`+PUFFGETSOWNER`, `+NODAMAGETHRUST`, `-GHOST`, `-THRUGHOST`, `Scale 0.3`, `Species "Blood"`) and the
     **same state layout**: state 0 `A_FaceTarget` (NoDelay), state 1 `A_SpawnItem("Brutal_Blood")` (or `Green_Blood`),
     state 2 the decision; so the engine's 1-2 state skip (2a) behaves exactly as with BD's blood;
   - decision: if the target is **in scope**, use this tic's stamp (or, with no stamp, e.g. an RSQ Melee punch where blood
     comes first, compute from its own z and stamp); if **not in scope**, BD's own `z - floorz` numbers copied exactly;
   - head: `A_TakeFromTarget("HitLeg")`, `A_GiveToTarget("HitHead", 1)`, `ACS_NamedExecuteWithResult("Head_Shot")` (BD's
     `ExecuteWithResult` / `ExecuteAlways` per class, as BD has it); leg and body likewise. All names are strings: no BD,
     no match, nothing happens.
4. **Hitbox monsters, only when resized** (Height differs from the class default by more than 5%, or the miniboss/thrall
   marker): turn the BD hitbox riding it (`master == victim`, class is `HeadHitbox`/`HeadshotTargetBase` by name) to
   `bSHOOTABLE = false` (BD's `HeadHitbox` family never sets its own SHOOTABLE flag after spawn; it only reads its
   master's, Head_Sys.dec:637-711), and on a head
   verdict give `HitHead` (before death, from the stamp) and deal BD's hitbox bonus ourselves: the blow's damage x 2,
   type `head`, inflictor = the blow's inflictor, **source = the player** (so Score can count it). Unresized: BD's hitbox
   untouched.
5. **The answer for everyone else.** `RSQMN_RosterService "headshot"` returns the stamp for **any** monster on the tic it
   was stamped (today only MG: RS_ScoreReadout.zs:63). Score needs **no change**: its `CondOf` already asks
   (combo.zs:154). Optional, by name: VisualRewards' `IsHead` asks the same service (events.zs:124) so CH/MG head hits
   get the HEADSHOT word; Miniboss can ask it for weak-point bonuses; MG's `mgLastWasHeadshot` reads the stamp.
6. **Scope cvar `rsq_hc_scope`:** 0 Off (copies behave exactly like BD), 1 Miniboss + thralls + resized monsters,
   2 Every monster. Miniboss/thralls are recognised by RSQ Miniboss's own marker, by name.

### 5c. The two scopes

| | (A) Miniboss + thralls (+ resized) | (B) Every monster |
|---|---|---|
| BD monsters normal size | exactly BD | our rule (feet, 0.80); ledge/air cases fixed; on flat floor nearly the same answers as BD |
| Miniboss 1.25x, Champions clones | fixed | fixed |
| CH / MG / pack monsters | head verdict only for MB/thralls | head verdict for all: Score's Headshot row and +head combos work everywhere |
| Damage bonus on non-BD monsters | none (owner's call, below) | none (owner's call) |
| Risk to BD's feel | lowest | small: some former "head" hits become body and the reverse |

### 5d. Limits

- The **box, not the mesh**: a head that sticks out of the box (models, sprites wider than the box) is not hittable at all.
- 0..4 units of engine noise on the hit height (same as BD today).
- Saw/axe bloods and `Blood_Bones` keep BD's fixed numbers.
- BD projectiles never head-shot BD's blood-route monsters (BD's own rule): the stamp still marks them for Score.
- A hitbox monster that is not resized keeps BD's hitbox exactly (fixed offsets, damage factors).
- The copies are of brutal22test6's bloods; a later BD changing those actors would need the copies re-checked.

### 5e. Risks and how each is handled

- **Double gore / double head damage:** the swapped bloods mean BD's own check never runs for those classes; resized
  hitbox monsters have their hitbox turned off before we add the bonus. MG keeps its own death router, fed by the same stamp.
- **Score double count:** none: BD's own `Head`/`head` blows are dropped by Score (source not a player, 1-bis); only the
  bullet's own event is marked. Our hitbox bonus blow (source = player) also carries the stamp: check on the rig that the
  row pays once.
- **Handler order:** the stamp must exist before Score's ledger reads it: `SetOrder(-100)`; logged in the test.
- **Another mod replacing the same bloods:** none in the load order (BD_VoxelPack and RS_Brutal22WeaponsQ do not name
  them, by grep); RSQ Monsters' roster `CheckReplacement` (RS_Roster.zs) touches other classes.
- **Netplay determinism:** inputs are game state only; scope and fraction are **server** cvars; no `random`; no
  `AttackPos`/`HmdPosition` reads. (The engine's own hitscan uses the renderer-written hand pose; that is the engine's
  issue on 17.3, not ours, and REMA routes it through `usercmd`.)
- **Cost:** one small function per damage event; `CheckReplacement` is a name compare.

### 5f. Test plan (rig; to be run when the owner allows rig runs)

Load order doom2 -> brutal22test6 -> BD_VoxelPack -> the series. First: **0 script errors from our packs**.
A TestRig scene fires scripted player hitscans (fixed origin and pitch, so repeatable) at chosen heights, and logs one
line per blow:
`HC t<tic> <class> H <Height> (def <h0>) feet <pos.z> floor <floorz> hit <z> frac <0..1> band <lo>..<top> verdict <head/body/leg> bd_would <head/body/leg> route <blood/hitbox/rsq> stamp_read_by <blood/score>`.

| # | Scene | Shown working when |
|---|---|---|
| 1 | Imp, flat floor, hits at 30/44/48/54 units, scope 0 | verdicts equal `bd_would` on every line (no regression) |
| 2 | Same, scope 2 | same answers except within ~2 units of the band edge; frames: Death.HeadExplode on the 54 kill, body death on the 44 kill |
| 3 | Imp at a 24-unit ledge edge, shot from below at chest | `bd_would head`, `verdict body`; frame: no head gore |
| 4 | 1.25x imp (box 20/70, scale x1.25), hits at 50 and 64 | 50: `bd_would head`, ours body; 64: head; frames of both deaths |
| 5 | 0.75x clone (box 12/42), hit at 38 | `bd_would body` (can never be head), ours head; frame: head gore |
| 6 | Knocked-up / flying imp | feet-based frac logged; no head when `IsDown` |
| 7 | 1.25x baron | its hitbox logged `SHOOTABLE 0`; head hit gives one `head` blow (source player) and Death.Head; body hit none |
| 8 | Score | with Score loaded: Headshot row pays on the kills of 2/4/5, never on 3; a log line from Score's ledger with `+head`. **Before the change, the same scene shows whether Score's row ever fired on BD (finding 1-bis).** |
| 9 | Damage numbers | HEADSHOT appears once per head blow, never on 3 |
| 10 | CH set (default) imp, scope 2 | stamp + Score `+head`; no BD gore (CH has none); no script errors |
| 11 | RSQ Melee punch to a zombie's head | blood computes and stamps first, damage event reads the stamp: one verdict |

Then the owner's headset, labelled "rig only, not headset-confirmed" until he says otherwise.

---

## Open questions for the owner

1. **Scope:** (A) miniboss + thralls + resized monsters, or (B) every monster?
2. **CH/MG/pack monsters have no head damage bonus** (BD's is +30 `Head`, x1.3 on zombies/imps). Head shots on them would
   score and show the word but hit no harder. Add a bonus (a new mechanic), or keep it score-only?
3. **The miniboss's box must grow with its picture** (`A_SetSize` x1.25), or its drawn head cannot be hit at all. A bigger
   box is also easier to hit everywhere. OK?
4. **Head size:** 0.80 of height for everyone (BD's own 0.82, MG's 0.78), or BD's per-family ratios?
5. **Big BD monsters (hitboxes):** take over only when resized (proposed), or always?
6. **Home:** inside RSQ Monsters (proposed; Miniboss without Monsters keeps BD's numbers), or a small separate pk3?
7. **MG's own band** (`rsq_mg_head_zone` 0.22): fold it into this one verdict?
