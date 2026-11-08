# Challenge building blocks: what we already have (2026-11-08)

A code study for the owner's contextual triggered challenges (a streak or Score condition starts a short timed event:
monsters teleport in, find and kill the target, minibosses, bits tied to challenges). See `design/BIG_FOURTH_ARCADE.md`
and `design/mockups/arcade_language/index.html`. No code was changed. Every claim has a file and line; **[inference]**
marks my reading, not something the code or a README states. Status words come from the mods' own READMEs.

## 1. Teleport-in: two working spawners, both private

The series has two: Miniboss's Bossfight arrival and SlowMo DOWN's target spawns. Neither offers a service, so another
mod cannot ask either one to spawn monsters.

| | **Miniboss Bossfight** (rig only, `Miniboss/README.md:6`) | **SlowMo DOWN targets** (rig only) |
|---|---|---|
| Where | `Miniboss/zscript/rsqmb/bossfight.zs` | `SlowMo/zscript/rsqsm/down.zs` |
| Candidates | Up to 400 of the map's own monster start spots, saved at the scan (`:123-147`). Plus 7 rays along the view (0, ±18, ±36, ±50°), 3 points each, inside a wall trace (`:530-548`). Each spot must be 384-1024 units away and within 55° of facing (`:521-529`, cvars `rsqmb_bf_near/far`). | A grid along the view: 5 distances (640 down to 192) × 11 angles (0 to ±60°), 7 probes a tic (`SpawnInView :815-843`) |
| Fit test | A hidden probe sized to the monster (`RSQMB_Probe :68-84`). The ceiling must leave room, then `TestMobjLocation` (`Fits :662-672`). | Spawns the real monster, then `TestMobjLocation`, `IsPointInLevel` and a height difference of 256 or less, and destroys it with `ClearCounters` on a miss (`:827-838`) |
| In view? | **Required**: the boss spot must pass `CheckSight` from the player (`:556`). Nothing avoids being seen: the arrival is meant to be watched. | **Required** (`m.CheckSight(pmo)` `:832`). After 70 tics with no spot, it falls back to `SpawnNearby`: all round, out of sight allowed (`:845-870`, `SPAWN_TRIES :72`) |
| Group | The boss, then thralls on two rings round it (8 + 8 slots, with a clash test, z within 48) (`:566-597`). At least half the thralls must fit (`:599`). | One monster per queued spawn. The queue retries every tic (`QueueSpawn :616`, `Spawns :628-669`) |
| How many | 1 boss + `rsqmb_thralls`, clamped 1-8 (+1 from tier 3) (`:514`). At most 24 candidates tried (`:553`). 2 a map, 90 s cooldown (`Guard :415-444`, `Miniboss/CVARINFO.txt:7-8`) | 1 + the number of DOWNs since the last Score life (`:551, 585`). No cap |
| Effect and timing | Fog first: `misc/teleport` at the spot, SlowMo's landing slow (`StartArrival :716-735`). After 24 tics the monsters spawn (`FOG_TICS :87`). Bound 6 tics later, once Champions has dressed them (`BIND_TICS :88`, `ArrivalStep :782-842`). The fog art is BFG / plasma bursts in the set's colour from a pooled VisualThinker FX set (`FxArrive :846-866`). | `TeleportFog` on reveal (`Reveal :755-763`) |
| Guard rails | Waits during the first 60 s, near an exit (768), under 40 HP, with more than 3 awake monsters on you, with no room, during the cooldown and past the map cap. The HUD shows the reason (`:395-444`). "Ignore Spawn Restrictions" loosens it in 3 steps, the last one untested (`:600-657`) | None beyond the fit and sight tests |
| Failed landing | No boss or no thrall standing: whoever came stays a plain monster and it tries again (`:802-808`) | A target removed without dying gets a fresh one queued (`WatchTargets :960-1013`) |
| Who comes | The map's roster, sorted by spawn health (`BfScan`), with a tier 0-4 picked from Gun Bonsai level / Score lives (`Tier :473-506`, `PlanArrival :508-519`) | A copy of the killer's class |

Rig evidence: `Miniboss/tools/rigtest/evidence_1105_bossfight.txt`. Graveyard can also raise undead on tombstones when Miniboss asks (`Graveyard/zscript/rsqgy/bones.zs:20-26`).

## 2. RS Score: what another mod can hear

Score is play-scope and deterministic: "nothing in this file may read consoleplayer" (`Score/zscript/rsscore/handler.zs:11-14`).
Mods ask it by name through `RS_ScoreService` (`awards.zs:86-215`):

| Ask | Gives |
|---|---|
| `kill.serial` (player) | The newest kill number. Poll it and walk back, as Miniboss does every tic (`bossfight.zs:271-287`) |
| `kill.style` / `kill.base` (player, serial) | The style points (total minus base) and the base of that kill |
| `kill.victim` / `kill.chain` | The body; the tool chain ("gun>whip>shield.bash") |
| `kill.big` (body) | 1 if a bonus called it a big moment (`handler.zs:599-611`) |
| `score`, `progress`, `lives`, `rewards` | The running total, the way to the next reward (permille), extra lives, rewards this map |
| `monster.name` | The name with Score's tier words ("Red Champion Imp") |
| `award` (label, points, pawn) | Pays a labelled row. **An unknown label pays onto the Base row** (`PayLabel`, after `:812`). A new row name needs an `RS_Award_*` class in Score (`awards.zs:6-84`) |
| `givelife`, `revivefire`, `touch`, `combo`, `tool` | Gives a life; runs the revival fire; feeds and registers combos |

The ring of kills keeps the last **16** (`handler.zs:1232`). Fields: serial, player, base, style, chain, victim, big, tic.

What Score computes but does **not** send out:
- **Which rows paid on a kill** (Headshot, Sights Up, Spree...): only local `mults` in `AwardKiller` (`handler.zs:472-575`).
- **Families**: Efficiency, Style, Daring, Melee, Counter (`bonus.zs:41-46`), plus Base as row 0. There are about 165
  `Family()` rows (grep count), 18 Champion tier rows (`boost.zs:216-233`) and 228 named combos such as Trap Shooter
  ("glove.upper > gun.shotgun", `combos.zs:25`).
- **Streaks**, kept on `RS_ScoreTracker` (`tracker.zs:27-88`): Spree (window 72-360 tics, set by victim health,
  `bonuses.zs:22-55`), Untouchable (kills since you were last hurt), Multi-Kill, Champion Streak, Chain Gang, Rainbow,
  Hold Streak, Hooked Keg. None of them is readable from outside.
- **The cap**: bonuses are shares of the base, summed, capped at 300% (`rs_score_cap_kill`, `handler.zs:538-544`).
- **Anti-farming**: a monster that was not on the map at load pays **25%** of its base (`rs_score_farmpercent`,
  `handler.zs:341-363`). Challenge monsters would count as spawned.

## 3. Shot quality: what already grades a shot

| Grade | Where | When it is known |
|---|---|---|
| Headshot (BD22 damage types `Head`, `MinorHead`, `Headshot`) | Score's combo ledger tags each blow with `C_HEAD` (`combo.zs:102, 150`). The Headshot row pays 0.25, or 0.4 with the Ruger / revolver (`rows.zs:997-1012`). VisualRewards shows a HEADSHOT word per hit (`damnums/events.zs:127`, `numbers.zs:169`) | Per hit (ledger, damnums); per kill (row) |
| Airborne victim, point-blank (64), own slow motion | Ledger conditions `C_AIR`, `C_PB`, `C_SLOW` (`combo.zs:145-151`; `Airborne` `melee.zs:245`; `DIST` `bonuses.zs:442`) | Per hit |
| Distance and aim | Sights Up: 768 or more, within 2° of the head's facing. Glass: Ruger / Railgun at 1024+, more at 2048 (`rows.zs:1016-1046`) | Per kill |
| Air (your jump), Quick Draw, No-Look, Blind-fire, Skeet, Direct Hit, Double Tap, Hand Cannon | `bonuses.zs`, `physical.zs:440-540`, `rows.zs` | Per kill |
| Crit / headshot / backstab / finisher | Gun Bonsai VR's touches (`GunBonsaiOffhandVR/rsq/zscript/core.zs:87`). The damnums crit mark (`RSQTHP_DnService "crit"`, nothing drawn yet, `events.zs:1552-1577`) | Per hit |
| Punch height; laser dot on a head | Melee `punch.height` (`Melee/zscript/rsqml/service.zs:11`); LaserSight, local state (`sight.zs:151`) | Per hit; local only |

Nothing counts a **streak of good shots** (panel 3: GOOD / GREAT / AMAZING / PERFECT). [inference] A challenge trigger
would have to tag headshots per hit itself (the ledger's damage-type test), or Score would have to send out its row results.

## 4. Bits

**VisualRewards Kill Rewards** (`VisualRewards/pk3/zscript/rsqvr/killrewards.zs`):
- **Every** monster that dies bursts into bits (`WorldThingDied :176-224`). The count is spawn health / 10 (Standard),
  ×3 for a boss, ×`rsqmb_bf_bits` (3) more for a Bossfight miniboss (`BossfightX :150-157`). Each bit has a 50% chance
  to drop (bosses drop all). The mix is 15 / 20 / 65 health / armour / ammo. Bits live 7 s and fly to you within 2 m.
- Gun Bonsai nodes add Bit Scavenger, Rich Bits, Magnet and Lucky Kill (`:270-307`).
- There is one switch, `rsqgb_kr_enabled`, and it is global (`:178`). There is no per-monster "no bits" and no
  "challenge only".
- Service `RSQVR_Service` (`rsqvr/service.zs`): `kr.on`, `kr.perk`, `kr.magnet`, `helper`, and `kr.battery`. Battery
  bits are the **only** on-demand burst (`batterybit.zs:28-43`).

**DOWN's bank** (`SlowMo/zscript/rsqsm/down.zs`, `design/NEAR_DEATH.md:96-125`):
- While a player is DOWN, his kills within 3× his magnet reach send their bits to him with no gravity, through walls
  (`BankBit`, `killrewards.zs:309-321`). They bank through `RSQSM_Service "down.bank"`. Ammo bits pay at once.
- `Bank()` **refuses unless the player is DOWN** (`down.zs:1037-1042`).
- On revive the bank pays health up to max, armour up to 250 (`Revive :1053-1090`). With no bank, a tier split applies.

[inference] Bits tied only to challenges would need three things that do not exist yet: a way to stop or keep bits per
monster, a bank that is not DOWN's, and an on-demand burst for health, armour and ammo.

## 5. Timers, clocks, text

Fonts and text paths are in `design/ARCADE_ASSETS_INVENTORY.md`: the VR text rule in section 0, the DOWN seven-segment
readout, Score rows, damnums words and the level-up band in section 2. For challenges:
- **Clock base**: `level.maptime` is never slowed by SlowMo (`countdown.zs:9-10`; DOWN counts real time, `down.zs:20`).
  A challenge clock on maptime stays honest in slow motion.
- **SlowMo on demand**: `RSQSM_Service "start"` / `"start.auto"` (who, ms, speed) from play code (`clock.zs:28-34, 1962`).
  Miniboss uses it for the landing (`bossfight.zs:726-728`).
- None of these can be called from another mod: the seven-segment clock (DOWN only), the countdown bar (slow motion
  only), Miniboss's meter, VisualRewards' REVENGE / REVIVE / "+0.5s" words (only through DOWN's `RSQDownJoin`,
  `rsqvr/down.zs:12-38`).

## 6. Monster tagging and "the target"

| Tag | How | Readable |
|---|---|---|
| Bossfight monster | `RSQMB_Called` token (`bossfight.zs:65`) | `RSQMB_Service "bossfight"` |
| Miniboss / thrall | `RSQMB_Ward` + `RSQMB_Boss` thinker (`items.zs:23`, `handler.zs:267`) | `"miniboss"`, `"thrall"`, `"lives"`, `"shield"`, `"tier"`, `"colour"`, GetObject `"boss"` / `"thrall"` (`service.zs:3-50, 75-131`) |
| DOWN target | `RSQSM_Down` arrays. The boost: a light in its colour, full-bright, ×1.15 size, +50% health (`Boost :889-943`, undone by `Unboost :945`) | `RSQSM_Service "down.mark"` (`clock.zs:1994`) |
| Score's combo filters | `champ`, `armoured`, `legend`, `thrall`, `miniboss`, a colour (`combo.zs:37-38`) | In patterns only |

**DOWN's Champions copy trick** (`down.zs:671-813`). Champions makes champions only as a monster spawns, so DOWN spawns
**hidden** copies at the found spot (`Hide :754`: invisible, not solid, not shootable, out of the blockmap), 6 a tic
(`CH_PER_TIC`), up to 300. The first one Champions turns into a champion is revealed in `TeleportFog`; the rest are
destroyed with `ClearCounters`. `SwapKiller` replaces the map's own killer with a copy, keeping its tid and special
(`:692-733`). LegenDoom is given its guaranteed pickup (`:896-902`). Miniboss's `Bind` handles Champions and LegenDoom
inheritance for a set piece (`handler.zs:267-370`).

**Showing "the target"**: DOWN draws the crosshair icon on the target, an eye-level trail and edge arrows
(`plate.zs`, `downhud.zs`), and VisualRewards keeps the target's HP bar up (`rsqvr/down.zs:18-24`). All of these belong
to DOWN. Nothing marks an arbitrary monster as a target for another mod.

## 7. Netplay

| Block | Sim or local | Notes |
|---|---|---|
| Score | Sim, deterministic (`handler.zs:11-14`) | Safe to poll from play code |
| Bossfight | Sim: meter, spot, spawn, `random[rsqmbbf]`. The call-in reads the local hands, then sends netevent `rsqmb_callin` (`:364-378`) | One arrival for one player (`arrPn`). **Risk**: `BfPayoff` falls back to `players[consoleplayer]` when there is no killer (`:873`), so the drop could differ per machine [inference]. FX are drawn only near the console player's view (`fx.zs:312`, local, draw-only) |
| DOWN | Sim, per player (`down.zs:46`). The panel, plate and trail are console player only | Its joins skip players other than the console player only to draw (`rsqvr/down.zs:15`) |
| Kill Rewards | Sim. The ammo bit was fixed to the toucher (`killrewards.zs:19-20, 503`) | — |
| SlowMo | Synced events; only the sound pitch and the gesture are local (`clock.zs:52-54`) | Bossfight rules are `server` cvars (`Miniboss/CVARINFO.txt:2-25`) |

## 8. Gaps: what a challenge system needs that nothing provides

1. **A director.** Nothing starts, runs, times, wins, fails or cools down a challenge. The nearest model is the
   Bossfight: a meter, guard rails, an arrival, a payoff and a cooldown. [inference] Its structure could be copied as
   it is.
2. **A spawn service.** Both spawners are private methods. Nothing lets a mod ask "spawn N of class X with fog, in view
   or out of it".
3. **Scale.** "Dozens" is beyond both spawners as they stand: the Bossfight brings at most 9 monsters, tries 24 spots and
   allows 2 a map, and DOWN probes 7 spots a tic. [inference] Waves would need spreading over tics and spots. No spawner
   prefers to place monsters out of view (DOWN's fallback merely allows it).
4. **Shot-quality events.** Score does not send out which rows paid or its streak counters. A trigger such as "5
   headshots in a row" needs Score to send them, or its own per-hit detection.
5. **Spawned monsters score 25%** and fill Miniboss's meter (only `RSQMB_Called` monsters are left out, `bossfight.zs:239, 288`).
   A challenge needs an exemption or a tag both mods honour.
6. **Bits for challenges only**: there is no per-monster bits switch, no bank outside DOWN and no on-demand health,
   armour or ammo burst (section 4).
7. **A clock and words for other mods**: no service shows a countdown, ROOM CLEAR, TIME BONUS or a band word on request.
8. **A target marker for other mods**: DOWN's boost, icon, trail, arrows and forced HP bar are not reachable.
9. **Rooms**: nothing finds them (`BIG_FOURTH_ARCADE.md` "Rooms", prototype not built).
10. **Co-op ownership**: the Bossfight is single-owner and DOWN is per player. Who owns a challenge in 4-player co-op
    has not been decided.
11. **Spawned monsters and the kill tally**: Bossfight monsters keep their kill counters (no `ClearCounters` on a
    landing, `:793-799`), so they add to the map's KILLS total. [inference] A challenge must decide whether its
    monsters count.
