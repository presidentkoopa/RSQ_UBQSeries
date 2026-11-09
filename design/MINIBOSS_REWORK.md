# Miniboss rework (owner + Claude, 2026-11-09 06:05-06:34). Design only; nothing built.

Owner's words, then where we landed.

- **Who arrives boosted:** "the miniboss and its thralls are the only monsters to arrive boosted legendary champions."
  (SlowMo's DOWN already spawns Boosted Legendary Champion copies via Champions itself: SlowMo/zscript/rsqsm/down.zs.)
- **Scale:** "the miniboss should be scaled up some." BD22 decides head shots by a FIXED height above the floor per type
  (brutal22test6 actors/Gore/BloodTypesMonsters.dec, e.g. `A_JumpIf((z - floorz) > 46, "HeadShot")`), so a scaled monster
  gets chest shots counted as head shots. Owner: **"we will need a real headshot fix"**: our own hit-height check against
  the monster's real (scaled) size, like MG's head band.
- **Thralls make it immune** (owner): "any shots on it cause grey Xs to bounce off like our damage numbers, and text says
  Immune! or something." "Target!" appears over the thralls' bars.
- **Kill a thrall:** "a sphere pops and all movement slows (we need to figure out how fast we are allowed to move in certain
  kinds of slowmo)." "The shield icon goes away for a large, pulsing Target! above the MB while the Target over the
  thralls shrinks." The shield drops "for either a period of time, or a set amount of damage is done": Claude suggested
  whichever comes first, the damage cap being one segment. **Owner 06:42: whichever comes first.**
- **HUD bar stack** (owner: "i love the idea of an on-HUD hp bar, i will look for something"):
  - top: the THRALL bar, "if 3 thralls, then three segments", grey with a large shield icon while immune;
  - then its own bar: "thralls = number of segments you have to whittle down before it's one-on-one with the miniboss
    itself, who has 1 full hp bar remaining";
  - thinner bars under it = its LIVES (Claude's suggestion, owner: "I think so, the spheres get lost in the tether art"):
    they replace the orbs circling its head. Empty the main bar, the next life refills it, the flames come up, the
    thralls rise, a new segmented thrall bar appears.
  - Words near the bars in the RS Score font, one word each: "Immune!", "Target!" (owner: "damnums can be used here").
- **Powers: LOSE** (owner 06:42). Each thrall carries the Champion power it gave the miniboss; killing that thrall
  strips that power from the miniboss.
- **Names:** the mockup's "IMP OVERLORD": owner: "overlord is cool. I like miniboss but we should keep overlord for
  something."
- Mockups: shown in chat 06:31 (three states: shielded, shield down after a thrall kill, one-on-one).
- **Glow In The Dark:** "the whole thing needs more feedback from GITD." Proposals still to bring.
- **Boss bar** (PARKED.md): a second bar beside the Bossfight meter for boss fights and EX-tier monsters.

## Wiring Miniboss into RSQ Monsters (06:34-06:36)
Owner: "we need to wire miniboss into RSQ Monsters." Claude proposed: pick the miniboss and thralls from the roster by name;
the Bossfight tier picks the colour (the miniboss always a step above its thralls; the top an EX, the "Overlord");
each lost life = the tier flash and one colour higher; Score pays full (census.add); without RSQ Monsters, as now.
Owner on mixing sets: "mixing sets is a cool idea. although the BD monsters are the ones I use the most. why not? it could
make for fun mixups. maybe some options for this in RSQ Monster options." Open: what a Bossfight uses when the Monster Set
is BD22 (BD's monsters have no colour ladder).
- **With Monster Set BD22** (owner 06:39): "a miniboss is a boosted legendary champion BD monster with thralls that are
  tiered CH boosted legendaries, I guess, sure." (BD monsters have no colour ladder, so the BD miniboss doesn't climb
  colours; its thralls do.) Menu proposal (Claude, not confirmed): RSQ Monsters > Bossfight: Miniboss From (Same as
  Monster Set / CH / MG / Mixed), Thralls From (Same as Miniboss / CH / MG / Mixed / Map's Own Monsters).
- **GITD** (owner): "take another crack at integrating GITD, I like your ideas but want a few more. GITD has a lot of
  abilities." First list (06:37): arrival wave in its ladder colour; shielded = its room steady cold grey; thrall kill =
  a wave in the colour of the power it carried; shield down = gold pulsing with Target!; life lost = red, then the new
  ladder colour; death = a map-wide wave then a reroll; optional flares for any RSQ tier-up, waves for Black/White/EX.
