# Death, bones and graves: ideas, set A (systems, progression, rewards)

Brainstorm for a talk with the owner (2026-11-06). Nothing here is built, nothing is decided. Set B (another agent)
covers moment-to-moment combat and horror; this set covers what the systems earn, cost and feed each other.

Every fact below is read from code (LOB_v1.05.pk3, brutal22test6.pk3, Graveyard/zscript), not run on the rig.

## 1. Facts that matter

**Legion of Bones (LOB v1.05, SpacemanStrife; DECORATE, one tiny ZScript class)**
- Two modes:
  - **Plain load:** `RandomSpawner ... replaces ZombieMan` (and Imp, Demon, and the rest). Every monster is a
    skeleton FROM THE START. Nothing rises.
  - **"Double Death" skills (Easy / Normal / Hard)** in MAPINFO: `ReplaceActor` swaps 13 monsters for LOB copies
    of the VANILLA monsters. Those copies rise as skeletons after death. This is the mode the owner describes.
- **On Brutal Doom it does not do what we want.** BD's `RifleZombie Replaces ZombieMan` (not a subclass). LOB loaded
  after BD wins the replacement, so BD's monsters are swapped out. Plain load gives skeletons from the start.
  Double Death gives LOB's vanilla-based copies. Either way you lose BD's monsters (their gore, fatalities and headshots).
  To get "BD monster dies, then its skeleton rises", one of our mods has to do the rising (idea 1).
- **How it rises:** the rising is written into the corpse's own Death/XDeath states, not an event hook.
  - The corpse waits for the delay, then does `A_CheckBlock`. If anything stands on it, the whole delay starts over.
    **Standing on a corpse keeps it down.**
  - Then it spawns `UndeadSpawnFire` (a burst of fire) and an `<Name>Spawn` actor (the rising animation).
  - Last it spawns the skeleton, with `SXF_TRANSFERPOINTERS` (it keeps its target, so it comes for whoever was fighting it).
- **Timing:** server cvar `LOB_Respawn`: Instant / 5 / 10 (default) / 15 / 20 s. Counted from the end of the death animation. Then
  a rise animation of about 0.6 to 1.3 s (Conqueror about 2.9 s). The rising actor is solid but NOT shootable.
- **Who rises (Double Death):** Zombieman, Shotgunner, Chaingunner, Imp, Demon, Spectre, Cacodemon, Hell Knight,
  Baron, Revenant, Mancubus, Arachnotron, Arch-vile. **No rise:** Lost Soul, Pain Elemental, Cyberdemon, Spider
  Mastermind. (LOB has `LOBSpiderMastermind` -> Conqueror, but the skills never use it.)
- **The undead and their health:**

  | Undead | Health | Undead | Health |
  |---|---|---|---|
  | Skull Zombie | 20 | Caco Lich | 350 |
  | Skull Shotgunner | 30 | Phantom Revenant | 250 |
  | Skull Chaingunner | 70 | Abhorrent (Mancubus) | 580 |
  | Skeleton Imp | 50 | Arachnobone | 500 |
  | Skeleton Demon | 150 | Reaper (Arch-vile) | 700 |
  | Ghost Spectre | 150 | Conqueror | 2500 |
  | Slayer Knight | 400 | Balrog | 1000 |

  A second death is final: bones burst out, and the body stays. Every undead has a Raise state, so an Arch-vile (or the
  Reaper, which uses `A_VileChase`) can bring it back.
- **Low-tier undead are fodder.** At 20 to 70 health, a risen zombie dies to one hit. Useful for idea 8.
- **Holy damage is already wired in.** Many undead take `DamageFactor "Purifying" 2.0` (Final Doomer),
  "Exorcist"/"Blessed" 3.0 (LegenDoom) and `UndeadGoHome 2.0` (Guncaster):
  - Have it: zombie, shotgunner, chaingunner, imp, demon, caco, knight, revenant, retro.
  - Don't: Balrog, Abhorrent, Painbringer, Ghost Spectre, Arachnobone, Reaper, Conqueror, Dragon Soul.

  If one of our mods deals damage of type "Purifying", it hurts most undead double with no edit to LOB.
- **Hellfire (Balrog):** a 500-unit aura gives nearby monsters NOPAIN + NOTARGET. Cvar `LOB_Hellfire`: both / NOPAIN
  only / off. It finds monsters by vanilla class names, so BD's monsters are mostly not buffed.
- **Other side effects:**
  - LOB `replaces DoomImpBall` everywhere.
  - Its decoration corpses (`DeadZombieMan`, etc.) never rise.
  - It has its own sounds (bone rattles, Balrog). Those exist only while LOB is loaded, so our mods can't use them.
- Undead come from `A_SpawnItemEx`, so they were not on the map at the start. RSQ Score's "Raised Monster Pay (%)"
  already applies to them.

**Graveyards (m8f, RSQ edition)**
- A stone is the player's death spot plus an obituary. The obituary includes the killer's tag ("killed by Imp").
- Stones are stored in three archived cvars, keyed by the map's checksum. They outlive saves and sessions. Saves
  don't hold them.
- In single player, a stone appears the next time that map loads (first WorldTick), not at the moment of death.
  In netplay it spawns at once through a network event. Spawning is always the `gy_spawn` network event, so it is netplay-safe.
- Each stone has a candle light (culled by distance). A pile of deaths is a pile of lights.

**Clashes to settle before Second Wind**
- RSQ Score's extra life already catches a lethal hit at 1 HP and revives you with Revival Fire. Its Swan Song bonus
  pays for a kill after you are dead.
- Gun Bonsai VR already has a SlowMo node called **"Second Wind"** (kills charge the meter). The owner said "rename together".
- Distance Grab's "Corpse Grab" was struck on 11-02. None of the ideas below brings it back.

## 2. Ideas

Cost: S = days, M = a week-ish lane, L = more. "Home" follows WHO_OWNS_WHAT. Every LOB part checks for LOB by class
name and stands down without it. Every mod still loads alone.

**1. Bones Bridge** (the foundation)
- Pitch: BD's monsters die as BD monsters, then rise as LOB's undead.
- In VR: you see the body you just made, a timer you can't see, and fire. You learn to watch corpses.
- Touches:
  - A WorldThingDied hook in ONE existing mod (owner picks: Graveyard as "the death mod", or Miniboss as the
    monster director). It spawns LOB's own `<Name>Spawn` actors by name.
  - Maps BD monsters to LOB forms by health/size (the way Miniboss reads monsters).
  - Reads `LOB_Respawn` for the delay. Keeps LOB's "stand on it to hold it" rule.
  - The player loads LOB without picking a Double Death skill. We need LOB's undead, not its replacements, so LOB's
    plain-load replacers must be beaten (load order, or our own replaces). **Blocker to check on the rig.**
- Rewards / risks: every fight has a second wave. Ammo matters more.
- Cost: M.
- Worry: BD's dead body is sometimes a helper actor, not the monster. Fading Corpses / gibs remove the body.
  Thinker count (one timer per corpse).

**2. Put Them Down**
- Pitch: kill the body before it gets up.
- In VR: a stomp (foot is not tracked, so a downward punch or gun-butt into the corpse), a shotgun blast into it, or a
  saber cut that gibs it. A gibbed or "put down" corpse never rises.
- Touches:
  - Bridge (1) checks the corpse is still whole.
  - Score: "Double Tap" award, and "Clean Room" (a fight where nothing rose).
  - Melee: a ground punch counts as a hit on a corpse.
- Rewards / risks: spend ammo or time now, or fight a skeleton later. Melee and Sword and Shield builds win here.
- Cost: S on top of 1.
- Worry: hitting corpses with hitscan needs a shootable "ghost" or a line check from the hand. Keep it play-scope.

**3. Hold Them Down (the flashlight)**
- Pitch: light on a corpse stops its clock. Light on an undead burns it.
- In VR: you sweep the beam over the bodies while you reload with the other hand.
  - A corpse in the beam keeps resetting its rise timer.
  - An undead in the beam takes small "Purifying" damage. LOB's own x2 already applies to most of them.
  - The Ghost Spectre shows clearly in the beam.
- Touches:
  - FnF: the beam's end point already exists (it stops at walls and monsters).
  - Bridge (1).
  - Gun Bonsai VR: a node for beam strength, maybe in a new Rig/FnF player branch.
- Rewards / risks: this is the answer to "what makes the battery worth managing" (BUGS item 12). Holding the dead
  drains it faster. A dead battery in a room of corpses is the horror.
- Cost: M.
- Worry: per-tic beam traces for each player. The beam is from the hand position, so netplay is as safe as every other hand mod.

**4. Bone Charge** (the battery economy)
- Pitch: the battery bar recharges slowly by itself. Undead second deaths drop a small blue "charge" bit.
- In VR: the bits fly to your off-hand wrist like Kill Rewards' armour bits, and the bar on the flashlight card ticks up.
- Touches:
  - VisualRewards (bits).
  - FnF (battery).
  - Gun Cards (the bar, item 29).
  - Gun Bonsai VR (Magnet / Rich Bits already apply).
- Rewards / risks: the undead you fear pay for the light that fights them. Without LOB, any kill can drop charge (an option).
- Cost: S.
- Worry: none beyond Kill Rewards' existing ones.

**5. Burn the Bodies** (flares; the Indiana Jones build)
- Pitch: a flare lying on or near a corpse cremates it. It won't rise.
- In VR: you throw a flare into the pile you just made and walk on. The flare lights the room and guards it.
- Touches:
  - FnF (flare already does BD fire to the living).
  - Bridge (1).
  - Score: "Funeral Pyre" award, with a bonus per body burnt by one flare.
- Rewards / risks: flares become a tactical resource, not only light. You trade a flare's light for a quiet room.
- Cost: S.
- Worry: the light cap (3 Quest / 6 PCVR) already limits flares. The burn check is a small radius search per lying flare.

**6. Haunted Graves** (the owner's idea, 11-06, item 32)
- Pitch: during a Bossfight, your own tombstones on this map wake up and spit monsters.
  - With LOB they are undead. Without it, they are the map's own types.
- In VR: the candle on a stone gutters, the stone shakes (it already squashes and stretches), and something climbs out
  of where YOU died last week.
- Touches:
  - Miniboss: the Bossfight decides when.
  - Graveyard: a small service that lists stones in view.
  - Gating by Score lives / Gun Bonsai level: more lives or levels, more stones wake.
  - A cap per fight, only stones 8 m+ away, never behind you.
- Rewards / risks:
  - Each grave monster killed BREAKS its stone. Score pays "Laid to Rest".
  - Many deaths = a harder Bossfight, but also a way to clear the clutter by earning it.
- Cost: M.
- Worry: spawning must ride the existing `gy_spawn`-style network event (the stone list lives in each machine's
  cvars). Never pick stones from consoleplayer cvars inside play code.

**7. Nemesis**
- Pitch: the stone remembers what killed you. That monster type is marked for revenge on this map.
- In VR: monsters of your killer's type wear a small skull pip over their HP bar.
- Touches:
  - Graveyard (the obituary already holds the killer's tag; add the class name).
  - VisualRewards (pip).
  - Score: "Vengeance", paying more for each death that type caused you here.
  - Gun Bonsai VR: bonus XP to the hand that took it.
- Rewards / risks: dying is turned into a bounty. Cheap and very readable.
- Cost: S.
- Worry: store the class name, not the tag. BD renames monsters' tags.

**8. Last Stand** (the near-death mode; working name, since "Second Wind" is taken)
- Pitch: a lethal hit holds you at 1 HP in deep slow-mo with the map blood-red (Glow). Get X kills to stand back up.
  The dead help you.
- In VR:
  - You're on the floor of the moment, world crawling.
  - With LOB, every corpse within 15 m rises AT ONCE as its weakest undead (20 to 70 HP fodder).
  - You shoot your way back to life through your own victims.
  - Back up: the Level-Up-style band flies past, time returns, 50 HP, guns reloaded, +1 cigarette, +1 grenade.
    A repurposed BD voxel power-up drops at your feet.
- Touches:
  - Score (owns lives and the 1-HP hold: one place to decide order. Suggestion: Last Stand first, a Score life
    only if Last Stand fails).
  - SlowMo (the clock).
  - Glow (the red).
  - Gun Bonsai VR (upgrades: fewer kills needed, auto-reload, a few seconds of invulnerability).
  - Rig (cigarette), Grenade (+1).
  - Fail: your stone gets a special "fell in Last Stand" mark (Graveyard).
- Rewards / risks: the most exciting death in the series. It costs one Score life or a cooldown, so it isn't free.
- Cost: L.
- Worry: holding at 1 HP is the same trick Score already uses (Dakka style). Telefrags and crushers still kill.
  Netplay: per-player slow-mo is a SlowMo-wide question already.

**9. Pay Respects** (the Chainsmoker build)
- Pitch: light a cigarette at your own tombstone and leave it there. The grave becomes a shrine.
- In VR: you kneel, take the cigarette from your lips and set it on the stone by hand. It smoulders there (one small
  light, reusing the stone's candle).
- The payoff:
  - Your next lethal hit within 20 m of a shrine gives a free Last Stand.
  - Or, without Last Stand: one free 1-HP catch.
- Touches:
  - Tactical Rig (cigarette).
  - Graveyard (shrine flag in its storage).
  - Score (Last Stand / life).
  - Gun Bonsai VR (Chainsmoker card: shrines last longer).
- Rewards / risks: a cigarette spent now buys insurance at a place you choose. Rewards knowing a map.
- Cost: M.
- Worry: the shrine flag lives in the stone's cvars, outside saves. See idea 10's save worry.

**10. Grave Robbing** (your own stash)
- Pitch: dying leaves part of what you were carrying at the stone (a share of this map's Score progress toward the
  next reward, or banked Gun Bonsai XP). Reach your grave to take it back.
- In VR: you walk back to the candle, reach into the stone (hand + Use, the Rig's reach logic), and it pays out with the
  reward sound.
- Touches:
  - Graveyard (stash value in the obituary string).
  - Score, Gun Bonsai VR.
  - The stone breaks when robbed.
- Rewards / risks: a reason to go back into the room that killed you. Haunted Graves (6) makes that risky.
- Cost: M.
- Worry: stones live outside saves. Die, reload, rob, die again is a farm. Fix: one rob per stone, ever, and the
  stash comes only from the run total since the last level start.

**11. Grave Weight** (fewer, bigger stones)
- Pitch: dying again within 2 m of a stone grows that stone instead of adding a new one.
- In VR: a big old stone with three candles tells you "this room is a killer" from the door.
- Touches: Graveyard only (storage merge, a count per stone, three sizes; the boss marker art is already there).
- Rewards / risks:
  - Fixes "we die a lot = many tombstones" (lights, clutter).
  - A stone's weight can be its Haunted Graves tier (6) and its Nemesis bounty (7).
- Cost: S.
- Worry: merging old storage once. Netplay: the merge must happen in the network event, not per machine.

**12. Bonebreaker** (the Melee build)
- Pitch: fists shatter the undead. A punch kill leaves only bones, which an Arch-vile or Reaper can't raise.
- In VR: you uppercut a skull zombie and it comes apart.
- Touches:
  - Gun Bonsai VR: a node in the Fists tree, numbers only.
  - Melee: the hit itself.
  - Score: "Shattered".
- Rewards / risks: a reason to go hands-on with fodder undead. Guns stay as they are (identity rule).
- Cost: S.
- Worry: none; an XDeath / remove call on the second death.

**13. Double Death Chains** (Score)
- Pitch: an undead remembers the tools that killed its living form. Kill it with a different tool and the combo chain
  pays both lives.
- In VR: shotgun the imp, then whip its skeleton = a named combo ("Exhumed"?). A kill within 1 s of the rise pays
  "Welcome Back".
- Touches: Score only. The Bridge (1) copies the chain from the corpse to the undead.
- Rewards / risks: the Raised Monster Pay cut stays, but the chain makes second deaths worth style points.
- Cost: S.
- Worry: Score's chain memory must survive the corpse being swapped for a new actor.

**14. Necromancer Tier** (Miniboss)
- Pitch: with LOB loaded, a Bossfight miniboss's dead thralls rise as their undead forms, not themselves.
  At tier 3+, the miniboss itself rises once as its undead form after its last life.
- In VR: you think it's over, the fire bursts, a Balrog stands up.
- Touches: Miniboss (Revive Thralls already exists), Bridge (1).
- Rewards / risks:
  - The best fights get a third act.
  - The payoff doubles (the drop stays on the final death).
  - Score pays "Exorcism".
- Cost: S-M.
- Worry: rage restore and thrall links must follow the new actor.

**15. Ash for Light** (Gun Bonsai VR progression for the flashlight)
- Pitch: the flashlight gets a small Gun Bonsai VR branch, fed by what the beam does: undead burnt, corpses held,
  rooms lit.
- The branch:
  - Wider beam.
  - Slower drain.
  - Purifying damage up.
  - "Lantern": the beam also slows rise timers in a cone, not just the spot it hits.
- Touches: Gun Bonsai VR (numbers), FnF (does the work).
- Rewards / risks: gives the "Indiana Jones" build its own tree.
- Cost: M.
- Worry: player-pool dilution (GBOVR_TREES 3.13); shown as a group, or behind an unlock.

## 3. Top 3

1. **Hold Them Down (3) + Bone Charge (4).** This answers the open question in BUGS item 12: what makes batteries
   worth managing. Light becomes crowd control, the undead pay for the light, and it reuses the beam end point and
   LOB's own Purifying factors. It is the most VR thing on the list: the beam is in your hand.
2. **Last Stand (8), fed by the dead.** The owner already wants it. The twist (corpses rise as one-hit fodder so
   you can earn your way up) makes LOB the engine of the comeback instead of a tax. It also settles the Score life
   vs. Second Wind order and the name clash in one talk.
3. **Haunted Graves (6) + Grave Weight (11).** This is the owner's own idea, kept fair: gated, capped, in view.
   Killing a grave monster breaks its stone, so many deaths become a harder fight that also clears the clutter.
   Grave Weight is cheap and fixes the light cost first.

All three need **Bones Bridge (1)** on BD. Without it, LOB replaces BD's monsters instead of raising them. That is the
first thing to settle and to prove on the rig.

## 4. Open questions for the owner

1. **Which mod hosts the Bones Bridge** (the BD-corpse-rises-as-LOB-undead hook)?
   a) Graveyard (it becomes "the death mod": player and monster deaths)
   b) Miniboss (it already directs monsters by health)
   c) Score (it already tracks every kill)
   d) Don't bridge: play LOB's Double Death on vanilla monsters only
2. **Which corpses rise on BD?**
   a) All that LOB covers
   b) Only during a Bossfight or Last Stand
   c) A chance per corpse (menu %)
   d) Only on Hard skills
3. **Rise delay owner:**
   a) LOB's own `LOB_Respawn` (5-20 s)
   b) Our own row, which can differ per monster tier
   c) Our row, shorter while your health is low
4. **What stops a rise?** (pick any)
   a) Standing on it (LOB's rule)
   b) Gibbing it / Put Them Down
   c) Flashlight held on it
   d) A flare burning on it
5. **Flashlight vs. undead:**
   a) Holds corpses only
   b) Holds corpses and burns undead (Purifying)
   c) Burns undead only
   d) Neither; light stays light
6. **Battery refill:**
   a) Recharging bar only
   b) Bar + Bone Charge bits
   c) Bar + battery pickups in maps
   d) Ermac's spec as written, nothing else
7. **Near-death name and order** (the Gun Bonsai VR node already uses "Second Wind"):
   a) Near-death is "Second Wind"; rename the node (e.g. "Momentum")
   b) Near-death is "Last Stand"; keep the node
   c) Near-death is something else you name
   - And: Last Stand first, Score life after? Or Score life first?
8. **Haunted Graves gate:**
   a) Only during Bossfights
   b) Bossfights + Last Stand
   c) Any time, rare, scaled by Score lives / Gun Bonsai level
   d) Off by default, a menu row
9. **Tombstone clutter:**
   a) Grave Weight (merge nearby deaths)
   b) A cap per map (oldest go)
   c) Both
   d) Leave as m8f made them
10. **Graves outside saves** (they survive a reload, so stashes and shrines can be farmed):
    a) One use per stone, ever
    b) Stash and shrine only from the current run
    c) No stashes or shrines; graves stay cosmetic plus Haunted / Nemesis only
11. **Builds:** should the death/bones mechanics give each build a clear tool? Proposed:
    - Melee: Bonebreaker
    - Chainsmoker: Pay Respects
    - Indiana Jones: Burn the Bodies + flashlight
    - Sword and Shield: Put Them Down by saber/saw

    a) Yes, as proposed
    b) Yes, but you assign them
    c) No build tags; mechanics are open to all
