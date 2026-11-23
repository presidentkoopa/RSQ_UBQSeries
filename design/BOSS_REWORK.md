# The Boss fight rework (design, not built)

Owner, 2026-11-22: "i love the thrall boss idea but they get fucking ganked as soon as they spawn in. something about it
isn't a challenge." He picked all four references to shape it: House of the Dead, Time Crisis / Robotron, Battle
Garegga's rank with an L4D2-style director, and DOOM 2016. This document puts them together into one fight. It is a
proposal for him to mark up, and nothing in it is built.

## 0. Why the fight isn't a challenge today

The fight as it runs now (as built, after 826a51543d):

1. **The player sets up the fight.** The meter fills and he calls the fight. Then comes a 5 s arrival. Every monster
   lands on a beam in front of him (384–1024 units out), frozen and invulnerable until the arrival ends. By the time
   they're live he's aimed, loaded and waiting, so the thralls die where they land.
2. **The rules make the Boss hard to kill, not the player hard-pressed.** Thralls cut the Boss's damage (20% with all
   up), and it has lives, each with 5 s of invulnerability. None of that makes the player move, choose or react.
3. **Thralls are ordinary monsters standing together where he's already looking.** Brutal Doom's guns kill ordinary
   monsters in a group, Champion power or not.
4. **Difficulty is World Tier,** which only moves on a Boss win (+1) or loss (−1). Gun Bonsai levels climb on their own
   path, and levels per gun can't measure "the player" anyway (shotgun 6, pistol 1).

What all four references share: **the pressure is on the player.** The threat comes from where he isn't looking, and
the enemy telegraphs an attack he must answer. Playing well makes the game push back harder. Being aggressive is how he
stays alive.

## 1. Rank and the director (Battle Garegga, Gradius, Left 4 Dead)

**Rank** replaces World Tier as the game's difficulty. It is one number per game, 0–100, shown as the existing tier
colour. Rank 0 is Common, and every ~8 points is the next colour (Green ... White), so players read it the way they
read World Tier today.

- **It rises with play, not with gear:**
  - kills in quick succession;
  - Score's chains and combos;
  - time without being hit;
  - Boss wins (a big step);
  - clean Boss kills.
- **It falls when the player struggles:**
  - heavy damage in a short time;
  - going DOWN;
  - spending a Score life (a big step);
  - dying.
- **It drifts slowly toward where the player is playing,** so a long quiet stretch neither punishes nor rewards.
- **What it drives:**
  - the colour range monsters spawn in, which today follows World Tier;
  - Boss toughness: health and lives;
  - the thrall count and how aggressive they are (Champion powers);
  - how often the Boss attacks (§3);
  - Score's multiplier, so playing at high rank pays.

The **director** decides *when*, the way L4D2's does. It tracks intensity: recent damage taken, monsters near the
player, his health. It runs a build-up → peak → relax cycle:

- **Boss timing:** a full meter starts the Boss call as now. The director can hold the fight for a few seconds while
  intensity is already high, and it brings the fight in faster when the player has been coasting.
- **Relax:** after a fight, the director gives a short relax window: fewer new spawns, and monsters less aggressive.

## 2. The arrival (Time Crisis, Robotron)

- The stage turn stays (darkness, siren, slow motion, the music) but gets much shorter: about 1.5 s, not 5 s.
- **The Boss lands in front.** The thralls land **around the player**: at his sides and behind, in a ring 400–700 units
  out. They come **staggered**, 0.5–1 s apart.
- Every landing spot is marked about 0.75 s before the thrall lands, using the SEGA crosshair fly-in from the crosshair
  work, plus a sound from that direction. The player can turn in time; he just can't pre-aim everything.
- **Each thrall fights the moment it lands.** No freeze, no invulnerable charge. Only the Boss keeps a short
  invulnerable landing.
- Rank sets the thrall count (3 at low rank, up to 6) and how tight the ring is.

## 3. The Boss: a telegraphed attack (House of the Dead)

The Big Boss design's EXPOSED! loop, brought down to every Boss:

- **Pressure:** the Boss fights normally, and the thralls flank.
- **The tell:** every N seconds (shorter at higher rank), the Boss winds up its big attack. It roars, the room's light
  goes red, and **2 weak points** (3 on a Big Boss) appear on its body, with our crosshairs assembling on them. It has
  3 s.
- **BREAK!:** break every weak point before the wind-up ends and the attack is cancelled. The Boss staggers and takes
  extra damage for about 3 s (§4 makes that stagger worth pushing in for).
- **Miss:** the attack fires. Every big attack is something visible to dodge: travelling beams, projectiles, ground
  waves. Never hitscan, per the no-hitscan rule.
- **What stays:** thralls still cut the Boss's damage (20% with all up), so killing the flanking thralls still matters.
  Lives stay as acts. Each act's tell comes faster and its attack is meaner.

## 4. Aggression keeps you alive (DOOM 2016)

- **During a fight**, kills within a short range or in quick succession drop extra health and armour bits (Kill
  Rewards, boosted while a fight runs).
- A **staggered** thrall, or the Boss during BREAK!, can be finished or hit with a melee strike (a punch, the saber, the
  ShieldSaw). That gives a health and armour burst plus a Score pop. It's our version of glory kills, and it uses the
  melee mods we already have.
- **Camping is pressured, not punished:** if the player stays put too long during a fight, the director sends the
  next thrall straight at him.

**Built (code only), first bullet, 2026-11-23:** RSQ VisualRewards' Fight Kill Rewards (killrewards.zs, row "Fight Kill
Rewards", on). While RSQ Miniboss says a Boss or Big Boss fight runs, a kill within 256 units or within 2 s of the
player's last kill throws +2 health and +2 armour bits on top of the usual bits (all four are settings). A thrall's
extra health stays off by default (owner 11-12, "no red bits drop"; a row turns it on). Not run on the rig.

## 5. How it fits with what exists

- **World Tier** becomes Rank. A setting keeps the old World Tier for anyone who wants it.
- **Kiosk and gold** don't change. Rank adds a gold and Score multiplier.
- **Big Bosses:** the same loop with their own personalities (sections 11–15 of BIG_BOSS.md), now built on this shared
  base.
- **Gun Bonsai VR** stays the UI and levelling. Nothing is gated behind it (its "Unlock RSQ Features" is Off).

## 6. Build order (proposed)

1. **Phase A, the biggest change for the least work:** §2 (thralls land around you, live at once, the short stage
   turn) and §3 (the telegraphed attack with 2 weak points for normal Bosses). Then a rig check and the headset.
2. **Phase B:** §4, aggression rewards and melee finishers during fights.
3. **Phase C:** §1, Rank and the director. It touches Monsters, Miniboss, Score and VisualRewards, so it goes last, once
   A and B feel right.

## 7. Owner's answers (2026-11-22 23:2x)
- Rank shown: **both**, as the tier colour and as its own number or bar.
- Stage turn: **around 3 s, slow motion kept**. This replaces the "about 1.5 s" in section 2.
- Tell timing: **20 s at low rank, down to 10 s at high rank**.
- Build order: **not yet**. The owner will mark up this document first.

## 8. Still open
(The Big Boss part is section 9.)

3. Thralls land 400–700 units out, around you: closer or further?
5. Melee finishers: which melee counts (punch, kick, saber, ShieldSaw, whip)?
6. Should Rank also choose *which* monster type the Boss is (stronger types at high rank)?
7. Keep the meter-and-call, or let the director call the fight on its own as well?

## 9. The Big Boss fix (owner 2026-11-23)

Owner, 03:41: "the big boss, i've only fought the angrier shotgun god and it was fucking impossible, lol. even on god
mode i could do basically no fkin damage to it". 03:45: "write it in yes, and consider dropping the big boss thralls, the
fight is difficult enough?"

**Why it was impossible (read from the code, 2026-11-23).** BENELLUS, GOD OF SHOTGUNS, ANGRIER (`RS_WhiteSGEX`) has
12,537 health and takes 0.75x from ordinary bullets. As a Big Boss it then takes 20% of every hit while all its thralls
stand (boss.zs ThrallFactor), and it has 3 lives or more, each refilled to full behind 5 s of invulnerability (handler.zs
Bind, boss.zs LoseLife). Champion and LegenDoom health can stack on top. With the thralls up that is about 80,000 health
of gun damage per life, about 250,000 for the fight; a chaingun round does about 20. God mode only stops the player
taking damage. The guns are not weak: the fight multiplies the boss's toughness five ways.

**The fix is on the boss's side, not the guns'.** BD22 VR's rule keeps the guns at BD22's balance ("same role, same
feel, same balance"), and a gun buff for one boss would make every other fight easier. Gun Bonsai VR's damage and
elemental upgrades stay what they are, optional.

1. **No thralls in a Big Boss fight** (the owner's suggestion; agreed). The Big Boss fights alone, so the 20% cut is gone
   (on its own a five-fold change). Boss fights keep their thralls as in sections 2 and 3. What the thralls gave the
   fight is moved onto the boss:
   - the health and armour that section 4 drops from kills come from **BREAK!** instead: every weak point broken drops
     a health and armour burst, and a full BREAK! a bigger one;
   - the pressure from behind comes from the Big Boss's own attacks (BIG_BOSS.md 11-15), not from adds.
2. **Health by time to kill, not the monster's raw health.** Each life's health is set so the player's own damage
   empties it in about **60 s** (rsqmb_big_ttk, 30-180). The player's damage per second is measured from his own hits
   in the last few minutes of fighting (any gun he uses, so a pistol player and a BFG player both get a 60 s life). Its
   floor is the monster's own spawn health x 0.5, so the bar is never trivial. The Boss bar still shows the boss's real
   numbers.
3. **BREAK! is where the damage is.** The Big Boss's wind-up shows **3 weak points**; break all three before the
   wind-up ends and the Big Boss staggers and takes **x3 damage for about 4 s** (a normal Boss: 2 weak points, x2).
   Played well, most of a life goes in those windows.
4. **Lives stay as acts** (3), but the act change is a short beat (about 2 s of invulnerability while it rages, not 5 s),
   and each act's wind-up comes sooner and hits harder.
5. **Option, for now:** Big Boss off (rsqmb_ex 0, RSQ Boss's page) keeps it out until this is built.

Open for the owner: 60 s per life or longer? Should the BREAK! window be x3 for 4 s, or longer and smaller?
