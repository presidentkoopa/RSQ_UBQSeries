# DOWN, lives, miniboss fights and the world tier: the rule

**Agreed with the owner 2026-11-16 00:51–01:38** (talk only, no code: "we need to define the system i can't keep going
back and forth on this"). This page is the rule. Code follows it; where code and this page disagree, the code is wrong.
It replaces the 2026-11-15 19:41 "DOWN only when out of Score lives" rule (SlowMo commit 895c005e00).

Packs involved: RSQ SlowMo (DOWN), RSQ Score (lives, the revival), RSQ Glow In The Dark (the world's look), RSQ Miniboss
(fights), RSQ Monsters (the world tier: `rsq_mon_worldtier`), RSQ VisualRewards (the words). Each still loads alone and
talks to the others by name.

---

## 1. A killing hit

| The hit came from | What happens |
|---|---|
| A monster (its shot, its helper, a barrel it set off) | You go **DOWN**, every time, whether or not you hold Score lives. |
| A fall, a crusher, your own shot, a barrel nobody set off, a hazard | No DOWN. A Score life catches it if you hold one (section 3); without one you die. |

## 2. DOWN

- Kill your target before the clock runs out and you are up. One kill owed, always.
- **It gets harder each time** (owner: "increasing penalties which make it harder and harder to get out of"):

| DOWN since the last life spent | Starting clock | Health you get up with |
|---|---|---|
| 1st | 9 s | 100% |
| 2nd | 6 s | 66% |
| 3rd and after | 3 s | 33% |

- **Spending a Score life resets it** to the 1st DOWN.
- **The target in a miniboss fight** (owner 01:2x): one of the miniboss's remaining thralls; only when no thrall is left,
  the miniboss itself. (While its thralls stand the miniboss cannot be hurt, so it can never be the target then.)
  Outside a fight: as today (the monster that downed you, or a boosted copy).

## 3. Failing DOWN

**With a Score life:** the life is spent, and you come back with time to find your feet (owner 00:58–01:00):

- Score's revival: the blast round you and the column of fire, full health, **magazines refilled**.
- **5 s of invulnerability**, shown by a bar that drains (in the style of SlowMo's countdown bar under the score).
- **5 s of slow motion.**
- **The world:** it flashes **grey and white for 3 s** (Glow In The Dark; the owner asks for real white), then shows the
  map's own Glow In The Dark colours strongly **for 2 s**, then settles back to its profile (or whatever colours were set).

**Without a Score life:** you die.

## 4. Miniboss fights

**Their tier** (owner 01:2x, "World tier only", "No cap"): the **miniboss arrives at world tier + 2**, its **thralls at
world tier + 1**. Miniboss's own Tier From rule (Gun Bonsai level, Score lives, map score, wins) no longer sets it. No
ceiling: at the top tiers they are ColorfulHell's full Black and White bosses.

**How a fight ends:**

| Outcome | What happens |
|---|---|
| **Win:** you kill the miniboss | **MINIBOSS DEFEATED!** and its legendary weapon, then **ENEMIES TIER UP!**: world tier +1 (at most 13). |
| **Loss:** you spend a Score life during the fight (a failed DOWN, or a non-monster killing hit caught by a life), **or** you leave the map with the fight still on | The miniboss and its thralls leave on their beams. **MINIBOSS WINS!**, then **ENEMIES TIER DOWN!**: world tier −1 (at least 1). No legendary. The level goes on; the meter can fill again. |
| You die (no life) | You reload; nothing is counted. |

## 5. The world tier

- It starts at 1. Every BD22 / XMVE / ColorfulHell monster on the map follows it (RSQ Monsters, with its tier flash).
- It moves only through section 4: +1 a win, −1 a loss. One on/off for both (today's "Miniboss Kills Tier Up Monsters",
  `rsqmb_tierup`).
- It is a saved setting today (`rsq_mon_worldtier`), so it carries into the next game until reset in RSQ Monsters' menu:
  the owner's "just for now".

---

## What is built and what is not (2026-11-16, updated after the build)

All "built" rows below are **rig only, not headset-confirmed**: the owner's full order and saved settings, Black Metal,
runs in `SlowMo/docs/rig_2026-11-16_down_lives/` and `Miniboss/docs/rig_2026-11-16_win_loss/` (logs, probes, frames).

| Part | State |
|---|---|
| 1 · a monster's killing hit puts you DOWN with lives held | Built (SlowMo `down.zs` Armed / PlayerHit; 895c005e00's arming rule undone). Shown: DOWN with 2 lives held, no life spent. |
| 1 · non-monster killing hits skip DOWN | Built (SlowMo `down.zs` PlayerHit). Shown: a fall with 1 life held, no DOWN, the life spent. |
| 2 · one kill owed; the 9 / 6 / 3 s clock | Built. |
| 2 · 100 / 66 / 33 % health by DOWN count | Built (SlowMo `down.zs` Revive, UpHealthShare). Shown: 100 %, then 66 %. Armour stays as it was (the bits bank, else the tier split); the bank's banked health is no longer paid (my reading: the rule names the health). |
| 2 · reset on a life spent | Built (SlowMo `down.zs` WatchLives: only a drop while alive). Shown: the count 3 -> 0 on a life spent; a life earned keeps it. |
| 2 · the thrall as the target in a miniboss fight | Built (RSQMB_Service GetObject "fight.target": the nearest living thrall, else the miniboss; not boosted or swapped). Shown: a thrall as the target, killed, up. Not shown: the miniboss as the target once no thrall is left. |
| 3 · Score's blast, fire column, full health | Built (Score `revive.zs`). |
| 3 · magazines refilled, 5 s invulnerability with its bar, 5 s slow motion, the white flash and the GITD settle | Built (Score `handler.zs` RunExtraLives: RefillMags, `RSQ_ScoreLifeInvul` a PowerInvulnerable of 175 tics, RSQ SlowMo "start.reward" life.used 5 s with the reason -1UP, RSQ Glow In The Dark "event.lifeflash"). Every life spent gets it, a fall's too (my reading of section 1's "(section 3)"). Shown in the log (the glow's written colours: grey and white swinging, then the room's own colour strongly, then settling); in frames the white glow is faint under the revival fire. The bar is VisualRewards' (`invbar.zs`). |
| 4 · miniboss world +2, thralls world +1 | Built (Miniboss `fight.zs` ApplyFrom; Tier From and Gun Bonsai VR's colour bonus gone; the type pick and the service's "tier" 0..4 read off the miniboss's ladder tier in steps of three: my reading). Shown: world 3 -> miniboss Cyan (5), thralls Purple (4). |
| 4 · win: +1 and the two words | Built (Miniboss `tierup.zs`; the words now BOSS DEFEATED! / ENEMIES TIER UP!), plus RSQ Score's life crate where it died and the BOSSWIN banner. Shown. |
| 4 · loss: a life spent or leaving the map ends the fight, beams out, words, −1 | Built (Miniboss `tierup.zs` LossTick / FightLost / LossOnLeave: BOSS WINS!, ENEMIES TIER DOWN!, the BOSSLOSS banner; leaving: the tier at once, the banner on the next map). Shown: a life spent -> 5 monsters on beams, removed, tier 3 -> 2; leaving for MAP02 -> tier 3 -> 2, the banner asked there. A fight counts as on from its bind (a landing in progress is not counted: my reading). |
| 5 · monsters follow the world tier | Built (RSQ Monsters; rig only). |

Nothing here is headset-confirmed.
