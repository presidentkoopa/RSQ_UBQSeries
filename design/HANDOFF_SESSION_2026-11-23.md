# Handoff, 2026-11-23 (owner: "prepare handoff for new lane")

Everything below is on main in both repos:
- RSQ_UBQSeries at `69e80e43b1`.
- RSQ_BD_VR_Reloaded at `c5ee2e2`.

The owner's PK3TEST folder (`C:\Users\Command\Desktop\PK3TEST`) matches main for every pk3 changed this session.

Labels used below:
- **rig only**: shown on the development rig, not yet in his headset.
- **code only**: loads with no script error, behaviour never run.

## 1. What the owner should load
- **BD22 VR Reloaded 2.0.5g** (in PK3TEST beside 2.0.5d/e/f; he should keep only 2.0.5g).
  - The RSQ_BD_VR_Reloaded repo keeps releases source only: `python build.py` from a checkout that has `tools/`.
  - The repo's `pk3/` still holds 2.0.4x, as its README says.
- **Every RSQ pk3 in `pk3/`.** Changed this session:
  - Grapple, Tactical Rig, Distance Grab, Melee;
  - Grenade, Visual Rewards, Miniboss.

## 2. Built this session

| Mod | What | Status |
|---|---|---|
| Visual Rewards | A map boss (not an RSQ Boss) throws twice an RSQ Boss's gold fountain | rig only |
| Grenade | Explosions fit under the ceiling: ours and every mod's (`rsqgn_ceilfit` 2) | rig only |
| Grapple | Aim Dot and Aim Trim | trim rig only; dot never seen in a frame |
| Grapple | Slow motion at the top of the kick-off and the double jump | rig only |
| Grapple | While two-handing, the claw flies where you look | rig only; flag set by a probe, not a real grip |
| Tactical Rig | Chest radius 0.13 (settings version 10) | rig only |
| Tactical Rig | Full gun holsters outrank tools nearby | **not driven on the rig** |
| Tactical Rig | Stored guns drawn with the engine's roll sign (the left chest gun sat out) | rig only |
| Distance Grab | Door lift eased; a flick past ~30% opens fully; seated reach 0.22 m | rig only, by events; **a hand grab was never shown** |
| Melee | Arcade impacts (POW!/WHAM!/COUNTER!, bursts, hit-stop) | rig only. The owner wants to redo these *with* him: "we will come back to it" |
| Melee | Headlock three-hit combo (third bowls the monster) | rig only |
| BD22 VR 2.0.5g | The plasma rifle's low-magazine beep no longer repeats while moving (dual too) | rig only |
| Miniboss | The Boss rework | rig only, by test events; see section 3 |
| Visual Rewards | Fight Kill Rewards (+2 health, +2 armour bits for close or quick kills in a fight, thralls too) | rig only |

## 3. The Boss rework (design/BOSS_REWORK.md)

### Built
Rig runs bt1–bt6, MAP01, driven by test events (`/home/claude/rig/work/t70/bkp`, `bbp`).
- **Section 2: the arrival, "Around You"**
  - 3 s stage turn.
  - Thralls land around the player at 400–700 units, 0.5–1 s apart, each marked 0.75 s before.
  - Thralls fight at once; the Boss lands last.
  - Classic arrival is still an option.
- **Section 3: the telegraphed attack**
  - Wind-up every 20 s at World Tier 1, down to 10 s.
  - 2 weak points on a Boss, 3 on a Big Boss.
  - BREAK! gives ×2 for 3 s on a Boss, ×3 for 4 s on a Big Boss.
  - A missed wind-up fires a visible attack. Per-Big-Boss attacks follow BIG_BOSS.md sections 11–15.
- **Section 4 (part)**
  - Melee finishers: every melee counts. Thralls stagger under 25% health and during BREAK!.
  - Camping pressure.
  - Fight Kill Rewards.
- **Section 9: the Big Boss fix**
  - No thralls.
  - Each life = the player's damage per second × 60 s.
  - 2 s act changes.
  - Weak points and BREAK! drop health and armour.

### Owner's answers (section 7)
- Ring 400–700.
- All melee counts.
- 60 s per life.
- BREAK! ×3 for 4 s.
- "You're free to handle bits however you feel": bits are ours to tune; tell him what changed.

### Not seen in a frame
On the rig, frames stopped rendering before the fights started, so the following are shown by logs only:
- landing markers;
- the red room;
- crosshairs on the weak points;
- the big attacks.

Before calling them working, get frames: shorter runs, or `EVERY=1` around the wind-up.

### Not built
- Section 1 and Phase C: Rank and the director. The owner's own build order puts this last, after he plays A/B. It touches Monsters, Score and Visual Rewards. Ask him first:
  - Should Rank choose the Boss's monster type?
  - Keep the meter-and-call, or let the director call fights too?
- The Big Bosses' summons during EXPOSED!.
- Supersmith's pentagrams.
- Benellus's four act-3 ghost guns (they became extra shots).
- RSQ Score has no "Finisher" row: finishers pay on Base.

### Fixed during the rig batch
The Big Boss's damage-per-second measure:
- It read blows after the ward scaled them (the thralls' cut, BREAK!).
- It read a blow on a BUDDHA life whole: one 99,999 blow sized the next life at 444,090.

## 4. Open: bugs the owner reported (11-23 03:01)
1. **Chaingun fires odd projectiles with a different sound when it needs a reload.**
   - Not reproduced with a plain chaingun (run mg1: 4 rounds, 4 shots, then the reload).
   - Lead: LegenDoom's no-ammo effects (Illegal, Optional, Transmogrifier) on a legendary chaingun. `rsld/g6_ammo.zs` treats the MiniGun as a one-pool gun; that is out of date since it has a real magazine (`counters.zs`).
   - The owner said "just move on": parked.
2. **Dual plasma "charge beep" while moving**: fixed in 2.0.5g.
3. **Jump spam + stick turn locks into a constant jump.** Not reproduced: the rig cannot snap-turn. Our jump code (Grapple double jump, SlowMo dive) needs a kick-off or its own key. Needs his description of the moment.
4. **The held weapon ejects three spent shotgun shells.** Not started; he can't reproduce it either. Ask which gun.
5. **Grapple while two-handing**: fixed.

## 5. Open: the owner's other topics
- **Arcade melee impacts**: redo together with him.
- **Melee in BD Weapons.** He is considering cutting all melee from BD22 VR and relying on RSQ Melee; a later BD Weapons release might bundle Melee and Tactical Rig. Offered alternative: BD22's melee steps aside when RSQ Melee is loaded. **His call; nothing done.**
- **Weapon trade-in system and +1 pellet** (04:20): "if i had a better way to implement the weapon trade-in system and +1 pellet we could stay competitive with higher tier enemies but im interested in trying this system we're doing now first". Parked until he has played the Boss rework.
- From before this session, waiting on him:
  - boss rework markup (done for A/B);
  - controls standardisation (his scheme);
  - the menu pass, the GBOVR pass and the Score pass;
  - arcade design.
- Hands are dropped ("we are moving away from it").

## 6. Gold and the kiosk: what they need
The owner asked at 04:21.
- **The Boss kiosk** needs all of:
  - Boss Kiosk on;
  - BD22 VR Reloaded's kiosk service, which needs LegenDoom 3.0;
  - RSQ Score's bank.

  Without them, the Boss drops its legendary as before.
- **Gold bits** need RSQ Score (the bank) and Visual Rewards. They drop from:
  - RSQ Bosses and Big Bosses and map bosses (always);
  - mk-champions Champions;
  - LegenDoom legendaries (when loaded).

## 7. Rig and tools
- **Gate script:** `/home/claude/rig/work/gate_1123/run.sh <name> <secs> "<console script>" [extra pk3s]`.
  - Variables: `P=` the pk3 folder, `BDVR=` the BD22 VR pk3, `EVERY=` frame dump rate, `EXTRA=` extra command-line arguments.
  - Always under `flock /home/claude/rig.lock`.
  - Pass = only BD_VoxelPack's 4 voxeldef script errors, plus "MAP01 - Entryway".
- **Current full set:** `/home/claude/rig/work/t70/final` (symlinks into `gate_1123d/pk3` plus tonight's Miniboss, Visual Rewards and Grapple).
- **Probes** (test only, never ship):
  - `t70/mgp` (Minigun magazine);
  - `t70/dpl` (dual plasma states and sounds; IsRunning forced by event);
  - `t70/jmp` (jump);
  - `t70/th` (grapple two-hand);
  - `t70/bbp` (feeds player damage);
  - `t70/bkp` (breaks weak points, hits the boss, kills thralls);
  - `gate_1123/b23` (the 11-22 batch).
- **Rig quirks:**
  - Controller roll never reaches ZScript.
  - Turning comes only from the headset (`+left`/`+right` do nothing).
  - Frames render far fewer than tics.
  - Only the left eye renders.
  - The last netevent before `quit` needs a trailing wait.
- **Disk is tight** (~3 GB free). Worktrees are sparse; frames are deleted after runs. Working worktrees: `/home/claude/wt_mel1123` (UBQ, detached), `/home/claude/wt_bd70` (BD22 VR). The agents' worktrees (`wt_bossA`, `wt_bossB`, `wt_vrKR`) are all pushed and can go.
- **PK3TEST delivery:** `device_commit_files` with `expectedMtimeMs` from `device_list_dir`. Files over 25 MB (BD22 VR) go through SendUserFile first, then its `fileUuid`.

## 8. The owner's standing rules (unchanged)
- Do only what he says.
- Ask decisions with AskUserQuestion: ask the real open questions, not endless ones. He called out that I chose defaults without asking.
- Give pushback and alternatives.
- Read the code before describing behaviour.
- Never call anything working that was not shown working. Label everything "rig only, not headset-confirmed" or "code only, not run".
- Load gate before any delivery.
- QuestZDoom 17.3 is never changed.
- Commits:
  - by explicit path, from sparse worktrees off origin/main, never from a main checkout;
  - no force-push, no branch deletes;
  - end every commit message with the Co-Authored-By and Claude-Session lines.
- Wording:
  - Player-facing text says "Boss" or "Big Boss", never "bossfight".
  - No Hackfraud terms.
- Never take the 2 GB music file in `__CurrentRotationDONOTDELETE`.
- RemaSelaco never commits to RSQ_UBQSeries.
