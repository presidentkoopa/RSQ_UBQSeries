# RSQ Training Room: architecture and modularity (design only)

Read-only study of `/home/claude/wt_fix2`, 2026-11-27. Nothing was changed, built or run. Citations are
`file:line` in that tree. **[idea]** marks a proposal with no code behind it yet. **[engine]** marks a QuestZDoom 17.3 /
GZDoom 4.14.3 behaviour (the engine version is from `tools/rig17/README.md:3-6`). That behaviour is not in this repo and
has to be shown on the rig before anything relies on it.

---

## 1. The core idea: one fixed hub pad facing one "pin-screen" arena

- **The hub (never moves).** A round pad about 384u across, with the player start in the middle. This is the one place
  where the player stands while the room changes. The mirror spot for Show On My Body is here. Along its back and side
  walls runs a **ring of alcoves**, one per lesson plus EXIT and RESET. Each alcove holds a palm switch.
- **The arena (morphs).** North of the hub is a 1024 x 512u floor cut into a **16 x 8 grid of 64u cells (about 2 m
  each)**. Every cell is its own sector with its own tag. A lesson is mostly a **heightmap** over that grid: pillars and
  ledges for the grapple, a row of pedestals for the saw's five rings, an open floor for the saber's remote, and so on.
  A 24u lip separates the hub from the arena, so the player watches the arena rise from the hub and then walks in.
- **Why a hybrid rather than "a hub with N rooms" or "one arena only".** Separate rooms need N hand-built rooms that each
  drift from the code. A pure morphing arena moves floors under the player. With a fixed pad and a grid, the map is
  built once and never changes, and each lesson is a few lines of data.

```
 +--------------------------------------------------+
 |  ARENA: 16 x 8 cells, 64u, floors 0..256          |  <- tags 1001..1128, spawn MapSpots on cell centres
 |  ceiling 512 (room for ledges and hook arcs)      |
 +----------------------[24u lip]-------------------+
 |  [alc][alc][alc]   ( HUB PAD, start )   [alc][alc]|  <- alcoves: closed (ceiling = floor) when the mod is absent
 |  [alc][alc][alc]     mirror spot        [alc][EXIT]|
 +--------------------------------------------------+
```

## 2. How the room reconfigures on QuestZDoom 17.3 (solid vs not)

| Tool | Use it? | Why |
|---|---|---|
| **Real sector floors moved by the engine's mover** (`Level.ExecuteSpecial(Floor_MoveToValue, ...)` by cell tag) **[engine]** | **Yes, the backbone** | The engine's own thinker carries actors, plays the sector sound, is saved in savegames, and gives real two-sided step faces. Grapple's mantle was proven on exactly that kind of face (`TestRig/README.md:112-114`, `TestRig/maps/make_rig01.py:5-7`). Grapple calls a wall bite within 40u of a step top a ledge (`Grapple/zscript/rsqgr/core.zs:77`). |
| Ceilings | Only to open and close alcoves and monster closets | Never lower a ceiling onto an occupied cell. Use crush -1 **[engine]**. |
| Line specials, intercepted | **Yes, for every switch** | A palm on a switch runs `Line.Activate`. WorldLinePreActivated and WorldLineActivated fire exactly as for a Use press (`DistanceGrab/zscript/rsqdg/door.zs:288-295`). The room's handler takes the event and runs its own code. Glow In The Dark lights any line with a special and Use/Push activation as a switch (`GlowInTheDark/zscript/rsqgd/things.zs:89-100`), so alcove switches glow for free. |
| Manual doors (special 10-14 etc., tag 0) | Yes, for the Distance Grab lesson's gate | Distance Grab lifts these by hand (`door.zs:13`, `DistanceGrab/README.md:46`). Glow In The Dark lights them as doors (`things.zs:99`). |
| 3D floors | **No** for anything a mod must read | No ffloor handling turns up in Grapple, Distance Grab, Tactical Rig, ShieldSaw, Saber, Melee or Glow In The Dark (grep). Only the Whip reads `ffloor` (`Whip/zscript/rsqwp/whip.zs:1322`). Ledges and lips on 3D floors are unproven. |
| Polyobjects | No | No series mod reads them (grep). They would be one more unproven surface for hooks, palms and the saw. |

**VR comfort rules [idea; speeds to be measured in the headset]:**
1. Never move a sector that any player overlaps. Before each move, test the four corners of every player's radius with
   `Level.PointInSector`. If a cell is occupied, it waits and the sign says "STEP OFF". The hub pad has no tag, so it
   cannot move.
2. Floors move only while the player stands on the hub or on a cell that is not changing. Move them at a speed that
   reads as "set dressing", about 2u/tic. A lesson never carries the player on a lift. Height is reached by Grapple
   ledges or by steps of 24u or less.
3. A morph takes at most 2 s. The room shows a cue during it (§5) and plays no camera effect.

## 3. The station contract

**Who knows what.** The room asks; the mods answer by name, as the whole series already does: 117 strings between 20 mods
(`README.md:429-437`), plus the cached lookup pattern (`TacticalRig/zscript/rsqtr/lookup.zs:1-40`). **No mod has to
change to be taught. The only exception is the "quiet" hook in §8.** A station is data, plus at most one small override
in the room's code.

```
class RSQTRN_Station play            // [idea] one per lesson, filled from generated trn_data.zs
  String id, title;                  // "grapple", "GRAPPLE"
  Array<String> needs, wants;        // PROBE class names: all of needs, or the alcove stays shut;
                                     // a missing want drops its steps (e.g. Wheel for holster assignment)
  String heights;                    // 16x8 digits, x 30u (0..8 -> 0..240)
  Array<String> spawns;              // "Imp|DoomImp @S12 passive", see section 4
  Array<String> steps;               // "SERVICE|request|stringArg|obj|op|value|SIGN TEXT"
  Array<String> show;                // "ghost:holster", "mirror:RHIP", "remote", "callin"
  virtual int Check(int k);          // default: the generic step evaluator; override for one-offs
```

**"Did the player do X": the generic step evaluator.** It calls `GetInt(request, stringArg, intArg, 0, obj)` on the
named service. `obj` is `pawn`, `dummy` (the step's spawned monster) or `none`. `op` is one of `>=T0` ("happened since
the step began": the answer is a tic, or "tics since"), `==`, `>=` or `chain~` (see Score below). Real requests it would
ask, all present today:

| Lesson | Steps (service, request), all by name |
|---|---|
| Grapple | `RSQGR_Service` `g2.last` with `bite.ledge`, then `kick`, then `airspike` (tic of the latest such event, `Grapple/zscript/rsqgr/service.zs:21,28-36`) |
| Tactical Rig | `RSQTR_RigService` `rig.holster` with the gun's class: the region it sits in, >= 0 (`TacticalRig/zscript/rsqtr/hooks.zs:180-195`). `rig.drawtic` > T0 (`:132`) |
| Wheel + holster assignment | `wr_RigService` `IsOpen` == 1 (`Wheel/zscript/wheel/zscript.zs:178`). `RSQTR_RigService` `rig.locked` with the gun >= 0 (`hooks.zs:160`) |
| Gun Cards | `RSQGC_GCopyService` `inspect.any` == 1 (`GunCards/zscript/rsqgc/gestcopy.zs:355`) |
| SlowMo | `RSQSM_Service` `slowmo.active` == 1 (`SlowMo/zscript/rsqsm/clock.zs:2591`) |
| Saber | `netevent ubqs_remote` summons the training remote (`QuestSaber/zscript.txt:6020-6025,6639`). On a dummy Imp, `UBQS_SaberService` `blocked` / `perfect` >= 0 (`QuestSaber/zscript.txt:7289-7290`) |
| Whip | On a dummy, `RSQWP_Service` `whipped` >= 0 (`Whip/zscript/rsqwp/service.zs:14`) |
| Melee | On a dummy, `RSQML_Service` `launch.age` (uppercut) >= 0 and `headlock.holding` == 1 (`Melee/zscript/rsqml/service.zs:21,24`) |
| Grenade | `RSQGN_Service` `kind` changed since T0 (alt fire changes the kind, `Grenade/zscript/rsqgn/upg.zs:203-210`). `skeet`, `teeth` and `cooked` for later steps (`:169-189`) |
| Distance Grab | `RSQDG_DoorService` `door.holding` with a hand >= 0 (`DistanceGrab/zscript/rsqdg/door.zs:545`). Palm switch: the room's own WorldLinePreActivated on the lesson's line |
| Boss | `netevent rsqmb_callin` (`Miniboss/zscript/rsqmb/handler.zs:477-483`). `RSQMB_Service` `bossfight` goes 1, then 0 (`Miniboss/zscript/rsqmb/service.zs:32-33,100`) |
| Gun Bonsai VR | `RSQGB_Service` `level` (`GunBonsaiOffhandVR/rsq/zscript/service.zs:124`) |
| **Any kill, any mod** | `RS_ScoreService` `kill.serial` with the player, then GetString `kill.chain`, read as "gun>whip>shield.bash" with the finisher last (`Score/zscript/rsscore/awards.zs:174-188,207-218`). The tool names are Score's single vocabulary (`Score/zscript/rsscore/tools.zs:1-16`), so `chain~whip.` or `chain~grenade.` covers lessons with no service of their own. |

Show-only lessons (Laser Sight, Glow In The Dark, Graveyard) have no steps: the alcove plays the cue and marks the
lesson seen. ShieldSaw's "ring five" has no count request, so it falls back to `chain~saw.` (a gap, §9).

**Teaching layer (all existing requests):**
- In-world titles and step text come from `RSQVR_Service` `worldword`, `"GRAPPLE|at:x,y,z|label|id:trn.title"`. `label`
  draws the word whatever the player's Reward Words setting is. `id:` replaces the previous word that has the same id
  (`VisualRewards/pk3/zscript/rsqvr/service.zs:44-57`).
- A word hangs over a dummy with `word.hold` and clears with `word.clear` (`:37-41`).
- Step-done chips use `toast` with `"up|<text>"` (`:84-86`).
- An edge arrow points at the target with `RSQSM_Service` `arrow.add` (`clock.zs:2551-2559`).
- A sector flash on the active cells uses `RSQGD_Service` `event.flare`, the tint uses `event.tint`, and a pass makes a
  wave with `event.wave` (`GlowInTheDark/zscript/rsqgd/service.zs:19-21`).
- A short world slow on pass uses `RSQSM_Service` `start` (`clock.zs:2544-2551`).
- Ghost hands: in ui code, `RSQTR_RigService` GetStringUI `ghost.demo` / `mirror.show` returns the network event to send
  (`hooks.zs:254-276`). The Rig plays it (`TacticalRig/zscript/rsqtr/ghost.zs:280-296`). The demo names are
  `ghost.zs:53`.
- The owner decides which words appear. The room ships no words or colours of its own beyond the families the services
  already take ('gold', 'cyan', 'magenta').

## 4. Spawning enemies safely

- **Exact classes, no replacement.** Each spawn row names Brutal Doom 22's class first and Doom's as a fallback, for
  example `Imp|DoomImp`, `RifleZombie|ZombieMan`, `ShotgunGuy1|ShotgunGuy`, `Cacodemon_|Cacodemon`,
  `BullDemon|Demon`, `HellKnight2|HellKnight`. The Brutal Doom names come from RSQ Monsters' table
  (`Monsters/zscript/monsters/RS_BDTierData.zs:107-118`). The room resolves them with `class<Actor>(name)`. The first
  one that exists is spawned with `Actor.Spawn(cls, spot, NO_REPLACE)`, so XMVE never swaps it. The same call is used in
  `Score/tools/rigtest/probe/zscript.txt:23`. Miniboss spawns with ALLOW_REPLACE on purpose
  (`Miniboss/zscript/rsqmb/bossfight.zs:1443`); the room must not.
- **Spots** are MapSpots with TIDs on the centres of the arena cells. The generator writes them (§6). The room fit-tests
  a spot before spawning: room under the ceiling plus `TestMobjLocation`. If it fails, the room destroys the monster and
  calls `ClearCounters`. That is the SlowMo DOWN pattern, summarised in `design/CHALLENGE_BUILDING_BLOCKS.md` §1.
- **Arrival.** `RSQVR_Service` `beam` `v1` on the monster once it is spawned. The beam hides the monster until the reveal
  and returns the tics until then. The caller keeps the monster from acting meanwhile (`service.zs:23-33`). Without
  Visual Rewards, a TeleportFog.
- **Score.** `RS_ScoreService` `census.add` for each spawn, so a training kill pays its full base once and Score's rows
  teach themselves (`awards.zs:80-91`). `ClearCounters` on dummies keeps the map's kill count clean **[idea]**.
- **Passive dummies** (saw rings, whip arcs, saber lock-on). Spawn them deaf and facing away, as rig02 does
  (`TestRig/bossfight_rig/README.md:7-8`). Do not use DORMANT: GZDoom makes dormant monsters take no damage **[engine]**.
- **Limits [idea].** At most 6 live monsters on Quest. The room tracks every one it spawns and removes it when the lesson
  ends or on RESET. It never spawns more than one wave until the last wave is dead.
- **Known side effect.** RSQ Monsters gives every spawned monster its kit at the current world tier
  (`Monsters/zscript/monsters/RS_BDTier.zs:1087-1130`). The room cannot pin Common tier without a new request (§8).

## 5. When a mod isn't loaded

- **Alcove shut.** For each lesson, the room checks its `needs` PROBE classes. These are the **same class names How To
  Play uses** to decide that a mod is loaded (`Controls/zscript/rsqct/howto_data.zs:8-10`). If any one is missing, the
  alcove's sector stays closed (ceiling = floor) and the switch inside cannot be seen or touched. This uses map geometry
  only. It also avoids a timing problem: Glow In The Dark scans the lines once at WorldLoaded
  (`GlowInTheDark/zscript/rsqgd/handler.zs:206-265`, `things.zs:80-104`), so clearing a special afterwards would leave
  the switch glowing.
- **Partly there.** A step whose service is missing (`Lookup.Find(...).Next()` is null) is dropped, not failed. For
  example, holster assignment needs both the Wheel and the Rig (`README.md:556`).
- **Switched off in Options.** The mod is loaded but its feature is off, for example the Rig, where `ghost.demo` answers
  0 (`hooks.zs:254-266`). The alcove opens and its sign reads "OFF IN OPTIONS". The room does not change the player's
  settings.
- **Visual Rewards absent.** Signs fall back to `A_Print`, as How To Play's first-run line does
  (`Controls/zscript/rsqct/howto.zs:1450-1458`).

## 6. Authoring and keeping it in sync: generated, never hand-built

- **[idea] `tools/training/gen_training.py`, in the same shape as `tools/howtoplay/gen_howtoplay.py`.** That tool writes
  its outputs and has `--check` to fail on stale ones (`gen_howtoplay.py:1-8`). It reads `tools/training/stations.py`, a
  readable list of lessons (heights, spawns, steps, show), and writes:
  1. `maps/RSQTRAIN.wad`: the UDMF kit (hub, alcoves, grid cells, tags, MapSpots, switch lines). It follows the series'
     existing UDMF generator, including its winding note (`TestRig/maps/make_rig01.py:1-60`). **The kit changes only
     when the number of cells or alcoves changes.** A new lesson changes data, not geometry.
  2. `zscript/rsqtrn/trn_data.zs`: static arrays, in the way `howto_data.zs` is generated. Never edit it by hand.
- **The PROBE names are not retyped.** The generator takes them from gen_howtoplay's mod table, so the room and How To
  Play always agree on what is loaded.
- **`--check` also verifies** that every `SERVICE|request` in a step appears in that mod's code as a request it answers.
  A grep against the service file catches a renamed request at build time, not in the headset.
- **No new sprites.** Signs are Visual Rewards words and floors use Doom II textures. The load order is already near the
  65,535 sprite-frame cap (`README.md:470-474`).

## 7. Entry, exit and progress

- **Home: RSQ_Controls.pk3.** It already owns How To Play and the first-run line. New players are told to take it
  (`README.md:461-463`). It has a MAPINFO (`Controls/MAPINFO.txt`). [idea]
- **Entry 1, New Game.** A MAPINFO `episode RSQTRAIN { name = "RSQ Training" }` entry. A new game wipes the pawn's
  inventory, which holds Score's tracker, Gun Bonsai XP and the Rig, so **training never leaks into a real run**
  **[engine, idea]**.
- **Entry 2, How To Play / Radiant Silvergun Options.** A `SafeCommand "Training Room", "map RSQTRAIN"` row. That is an
  engine menu item with a confirm screen. It would sit beside the How To Play row (`Controls/MENUDEF.txt:19-33`)
  **[engine, verify on 17.3]**.
- **Entry 3, first-run line.** RSQCT_HowToStart's toast (`howto.zs:1432-1460`) could name the Training Room as well.
- **Exit.** The EXIT alcove uses Exit_Normal (Glow In The Dark lights it as an exit, `things.zs:98`). In the episode,
  MAPINFO `next` sends the player to the title.
- **Progress within a visit.** A map-scoped EventHandler holds the current lesson and step, saved with savegames.
- **Progress across visits.** A `nosave` user string cvar `rsqct_trn_done` lists the lesson ids passed on this machine.
  The precedent is `nosave bool rsqtr_tip_holster` ("this machine only, kept", `TacticalRig/CVARINFO.txt:23`). A lesson
  already done shows DONE on its alcove, and RESET in Options clears the list.

## 8. What the room cannot do alone: the "quiet" hook

No series mod checks the map name to stand down (grep in Miniboss, Score, Graveyard, SlowMo and Monsters; the only
`MapName` reads are for death reloads, `Score/zscript/rsscore/gold.zs:89-131`, `Miniboss/zscript/rsqmb/bigboss.zs:276-289`).
In the room, therefore:
- a Boss can land on its own when the meter fills (`README.md:288-289`);
- RSQ Monsters tiers the dummies at the world tier;
- SlowMo's automatic triggers fire;
- a death leaves a Graveyard stone that is kept between games (`README.md:316-318`). That could be a lesson in itself.

**[idea]** One shared name, `RSQTRN_Service` `GetInt("quiet", "<system>")`. Miniboss asks `"arrival"`, Monsters asks
`"tier"` (answer: pin Common), SlowMo asks `"auto"`. Each is a few lines in each mod. **This is the only change outside the
room**, and under the depot rule it is "compiled, not re-verified" until it has run on the rig.

## 9. How the rig drives it (one engine launch)

- **[idea] `netevent trn_selftest`.** For every lesson the room prints `TRN HELLO <id> open|shut(<missing probe>)`. For
  every step row it asks its service once and prints `TRN ASK <svc>.<req> = <value>|NOSERVICE`. That is a live contract
  check of the room's strings against every loaded mod.
- **`netevent trn_go <id>`** arranges a lesson without the switch. The room prints `TRN t<tic> <id> ARRANGED`,
  `STEP <k> WAIT|PASS|DROP <svc>.<req>=<v>` and `DONE`.
- **The run.** Each lesson's data carries a `rig=` field of console lines: poses through `qz_rhand`, `qz_lhand` and the
  other cvars (`TestRig/README.md:54-77`), and existing network events such as `netevent rsqgr_fire 0`
  (`TestRig/README.md:112`), `netevent ubqs_remote` and `netevent rsqmb_callin`. **[idea]**
  `tools/training/rig_training.py` concatenates them into one `-Commands` script, with a `screenshot` after each
  ARRANGED and each PASS (the hidden window renders, `TestRig/README.md:104-106`). One launch covers every lesson. The
  log plus the frames are the evidence. Every frame gets looked at.
- **Headset.** The owner plays the same lessons by hand. The `TRN` lines go to the console, and RSQ Play Log's Start Log
  File copies them to `rsqplay.txt` (`PlayLog/README.md:15`). So a headset session also leaves a log, and "rig only" and
  "headset" can be told apart.
- **Limits.** The rig cannot judge feel or Quest tracking (`TestRig/README.md:104-106`). A posed controller's roll does
  not reach ZScript on that rig, so the watch check needs a network event there (`TestRig/bossfight_rig/README.md:28-29`).

## 10. Open gaps found while reading

- ShieldSaw answers no "how many are ringed". The Grapple sends Score no `touch`, so `kill.chain` sees no `hook.*`
  (`Score/docs/FINDINGS_2026-11-27.md:31`). The Grapple lesson must ask `RSQGR_Service`, not Score.
- The world words' limit on how many can show at once has not been measured. Show only the title of the alcove nearest
  the player's hand.
- Glow In The Dark's wall glow on cells whose floors move has not been seen.
- The room is single-player only: the ghost hand is local (`ghost.zs:31-32`).
