# RSQ Score: handoff for the local coding swarm (the LAST pass before 1.0)

Written 2026-11-02 by the cloud lane, at the owner's request. Read `LOCAL_AGENT_HANDOFF.md` (rules, build, load
order), `WHO_OWNS_WHAT.md` and `GBOVR_SWARM_HANDOFF.md` first. Run `git pull` before starting.

**Order:** Score is LAST, after the whole Gun Bonsai VR pass. The owner: Score "has so much to read". Don't start
Score's own code before he says so. The event lines in other mods (section 3) may be added while the GBOVR swarm is
already working in those mods, because GBOVR needs the same moments for its XP.

---

## 0. The problem, in the owner's words

> "RS Score has a LOT it needs to be looking out for and doesn't know very much about them right now."
> "'About 89 bonus checks' was based on like half the mods we have, we made a shitton more and this thing needs to
> know about them."

**The mission: Score must know every way to FIGHT and KILL in the series as it is now.** That means every RSQ
mod, BD22 VR Reloaded and Gun Bonsai VR: every combat tool and combat move, so kills and kill combos made with them
are recognised and paid.

**Scope is combat only (the owner, 2026-11-02, emphatically).** Score is an arcade score for how you kill and
fight. **Utility actions earn nothing:** holstering, drawing, lighting or smoking the cigarette, the Zippo, the
keyring, moving guns between hands, reloading as such. They count only where they are part of a kill, as the
existing Quick Draw does (a kill shot within a beat of a draw). If you are unsure whether something is combat, ask
the owner; don't add it.

---

## 1. What Score is today (keep the good bones)

`Score/` (`pk3/RSQ_Score.pk3`, about 6,600 lines in `zscript/rsscore/`; README appendix has the full design notes):
- **Kill pay:** every kill pays the victim's spawn health. About 89 bonus classes each read one frozen
  `RS_ScoreEvent` (event.zs) and add a multiplier. There are four families (Efficiency, Style, Daring, Melee).
  There is a per-kill cap (`rs_score_cap_kill` 300).
- **Combo ledger** (combo.zs): each monster keeps an ordered chain of TOOLS; 3 s breaks the chain; named combos come
  from a data table (`RS_ComboSeed.Combos`), and their names are still **proposals the owner never approved**.
  Unnamed chains pay as a generic 2-, 3- or 4-tool combo.
- **Map target and rewards, display** (top right, bonus list, wrist score), and slow-mo moments and hit-stop
  through RSQ_SlowMo.
- **An extension route exists:** a mod can subclass `RS_ScoreBonus` and call `RS_ScoreRegistry.RegisterBonus`.
  In practice almost every bonus was written inside Score.
- **How it learns facts today:**
  - it classifies blows itself in WorldThingDamaged;
  - it asks each mod's service "how long ago" for non-damage moves;
  - its tool list is hand-written (`gun`, `rig.draw`, `saber.cut`, `saber.throw`, `saber.return`, `saber.block`,
    `force.push`, `force.pull`, `force.grip`, `shield.bash`, `shield.disc`, `shield.block`, `hook.bite`,
    `hook.yank`, `whip`, `grab.throw`, `kick`, `punch`, `glove`, `blade`, `finisher`).
  
  It is a snapshot from about 2026-10-27.

## 2. The gap (checked 2026-11-02 by grepping Score's code for each mod's name and service; start here, then verify)

- **RSQ Melee** (created 2026-11-01): **zero** references to its service (`RSQML_*`). Its moves, none known as
  Melee's own: jab, hook, uppercut (lift), the open-palm swat, the fist/palm toggle, Hadouken (return a
  projectile), guard (block flash), wall splat, heavy hands, gun-butt shove + F.E.A.R. Effect, headlock (hold,
  punch, throw, human shield, breakout).
- **RSQ Grenade:** nothing. Grenade kills, cooked-throw kills (a short fuse as part of the kill), multi-kills.
- **RSQ Whip:** only a generic tool word "whip", nothing from the rebuilt Whip (`RSQWP_*`). It has a wind-up,
  heavy and light cracks, the pull, and Whip In.
- **RSQ TacticalRig:** Quick Draw and Hot Swap (kills right after a draw or swap) exist. Check they still read the
  rig correctly. The rig's utility features (cigarette, Zippo, keyring, holstering) are NOT scored.
- **BD22 VR Reloaded** (the BD22 Weapons repo): its combat moves are pistol whip, gun bash, butt strikes (partly
  known), axe/chainsaw/sword kills, and dual-wield kills. Almost none are known. (Hand reloads and the pump are
  handling, not combat: not scored by themselves.)
- **Gun Bonsai VR:** its upgrades and moves (and the redesigned paths from the GBOVR pass). Nothing is known.
- **RSQ SlowMo:** Score's slow-motion kill bonus (to be renamed) must still read SlowMo correctly after its
  rework (commit bae904e9f). Triggering slow-mo is not itself scored.
- **RSQ Miniboss:** miniboss kills and awards; check them against the current Miniboss.
- **LaserSight, GunCards, Wheel, HP Bars, Gestures, Accessibility:** these are not combat tools. Expect nothing to
  score; only note one if it is truly part of a kill.
- **Mods Score does cover but whose combat changed since 10-27:** QuestSaber (Force on the off fist, the dual
  sabers), ShieldSaw, Distance Grab (throws), Grapple (the default pull vs the Swing option). Re-check every
  existing combat bonus against the current code.

## 3. The plan

1. **Inventory, read-only:** go mod by mod: every RSQ mod folder, the BD22 Weapons repo
   (`E:\DOOMWork\RS_Brutal22WeaponsQ`) and `GunBonsaiOffhandVR/`.
   - List every COMBAT tool and move (anything that hits, hurts, kills or defends in a fight). Give its name,
     where it lands in code (file and function), and what facts are available (target, damage, speed, hand).
   - Mark what Score catches today, what it catches wrongly (stale), and what it doesn't catch.
   - Output: `SCORE_EVENTS.md`.
2. **One shared combat-move announcement for the series.** Each mod DECLARES its combat moves once by name at
   startup:
   id `melee.uppercut`, family `Melee`, plain name "Uppercut". It ANNOUNCES each moment as it happens:
   target, hand, strength.
   - **Mechanism:** a named service or netevent, found by name at run time, never a compile-time class
     reference, so every mod still works alone. With Score absent, the announcement goes nowhere.
   - **Gun Bonsai VR** listens to the same announcements for its "how you move" XP: one list, two listeners.
   - **Score's tool list and combo ledger build themselves** from what is declared. A new move needs one line in
     its own mod and no Score code.
   - Design the payload with netplay in mind; Score is play-scope.
3. **Naming pass with the owner** (he insists names are deliberate):
   - every combat move and every kill combo, including cross-mod chains (e.g. headlock → throw → grapple yank;
     uppercut → whip crack kill), with points per line;
   - rename Score's "Bullet Time" bonus (the owner's decision);
   - the current combo names are proposals; put them in front of him too.
   
   Ask with pickable answers, a few lines at a time.
4. **Score listens:**
   - wire the announcements in, and retire Score's own guessing wherever a mod now announces;
   - keep the kill event, families, chains, caps, target and rewards and the display;
   - keep the per-kill cap meaningful as the move count grows.
5. **Re-verify every bonus** on the rig on the owner's full order, and show each firing (a log line per bonus per
   scenario).

## 4. Rules

As in `LOCAL_AGENT_HANDOFF.md`:
- No engine changes.
- Zero script errors from our packs on doom2 alone and on the full order.
- Working means shown working; VR-only behaviour is "rig only, not headset-confirmed" until the owner says so.
- New options: Yes defaults ON, Option defaults OFF.
- No console steps for the owner.
- Commit only the pk3s you changed.
- Questions to the owner come with answers to pick.
- Never wait silently; never tell him he stopped something.
