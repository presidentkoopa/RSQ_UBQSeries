# Miniboss rework (owner + Claude, 2026-11-09 06:05-06:34). Design only; nothing built.

Owner's words, then where we landed.

- **Who arrives boosted:** "the miniboss and its thralls are the only monsters to arrive boosted legendary champions."
  (SlowMo's DOWN already spawns Boosted Legendary Champion copies via Champions itself: SlowMo/zscript/rsqsm/down.zs.)
- **Scale:** "the miniboss should be scaled up some." **1.25x** (owner 07:28). BD22 decides head shots by a FIXED height above the floor per type
  (brutal22test6 actors/Gore/BloodTypesMonsters.dec, e.g. `A_JumpIf((z - floorz) > 46, "HeadShot")`), so a scaled monster
  gets chest shots counted as head shots. Owner: **"we will need a real headshot fix"**: our own hit-height check against
  the monster's real (scaled) size, like MG's head band.
- **Thralls make it immune** (owner): "any shots on it cause grey Xs to bounce off like our damage numbers, and text says
  Immune! or something." "Target!" appears over the thralls' bars.
- **Kill a thrall:** "a sphere pops and all movement slows (we need to figure out how fast we are allowed to move in certain
  kinds of slowmo)." "The shield icon goes away for a large, pulsing Target! above the MB while the Target over the
  thralls shrinks." The shield drops "for either a period of time, or a set amount of damage is done": Claude suggested
  whichever comes first, the damage cap being one segment. **Owner 06:42: whichever comes first.** Window length (06:43): "three seconds if 3, four if 4, five if 5":
  one second per thrall the miniboss came with (3 thralls = 3 s).
  Window closes with the segment unfinished (06:46): "the MB and its thralls tier-up (let's say the thralls are CH, and
  the MB is MG) by a factor of 1 - 3." (A retier with the tier flash: CH thralls swap class, the MG miniboss changes in place.)
  **The window bar (07:12-07:13):** DOWN's reward bar repurposed for the HUD, right under the thrall segments: one step per
  thrall, one second each, draining tallest first; the step you break the segment in sets Score's pay (first = most).
  Drained to zero with the segment unbroken = tier-up by how much segment was left: a sliver +1, about half +2,
  untouched +3 (owner: "I think so"). DOWN's bar is drawn on its world plate today: it needs a HUD-style redraw.
  **Option: the tier-up hits every monster on the map** (ON by default, owner 07:15) (owner: "successive miniboss fights could cause a player to
  leave a map with tier 9 enemies, lol"). **Miniboss-induced tiers reset on a map change**; tiering from RSQ Score or
  Gun Bonsai VR (their own, later) is unaffected.
- **HUD bar stack** (owner: "i love the idea of an on-HUD hp bar, i will look for something"):
  - top: the THRALL bar, "if 3 thralls, then three segments", grey with a large shield icon while immune;
  - then its own bar: "thralls = number of segments you have to whittle down before it's one-on-one with the miniboss
    itself, who has 1 full hp bar remaining";
  - thinner bars under it = its LIVES (Claude's suggestion, owner: "I think so, the spheres get lost in the tether art"):
    they replace the orbs circling its head. **Option (owner 07:28): it tiers up (with the flash) each time a life bar
    empties.** Empty the main bar, the next life refills it, the flames come up, the
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
  colours; its thralls do.) Menu (Claude's proposal, owner 07:45: "your rules are good"): RSQ Monsters > Bossfight: Miniboss From (Same as
  Monster Set / CH / MG / Mixed), Thralls From (Same as Miniboss / CH / MG / Mixed / Map's Own Monsters).
- **GITD** (owner): "take another crack at integrating GITD, I like your ideas but want a few more. GITD has a lot of
  abilities." First list (06:37): arrival wave in its ladder colour; shielded = its room steady cold grey; thrall kill =
  a wave in the colour of the power it carried; shield down = gold pulsing with Target!; life lost = red, then the new
  ladder colour; death = a map-wide wave then a reroll; optional flares for any RSQ tier-up, waves for Black/White/EX.

## Words (07:40)
Owner: "we already use Target!, I guess we could say Defend! in some animated life. Like the numbers here [Castlevania
GIF: the damage number pops over the head, flickers between colours, drifts up, holds about a second], but our font, and
the word Guard! in silver like the shield, with this kind of flashing and life to it." Claude recommends **Guard!**:
shots on the shielded miniboss pop "Guard!" over it in RS Score's font, silver flickering to white like that GIF's
number, drifting up and fading, with the grey Xs bouncing off. "Target!" stays for thralls and for the miniboss with its
shield down. (Drops "Immune!" and "Defend!".)

## Head shots
Agent researching a real head-shot solution from the engine survey (RSQ_QuestEngineSurvey): design/HEADSHOT_SOLUTION.md.

## The fight, as decided (summary for the owner, 08:12-08:14)
1. Arrives 1.25x with its thralls, all Boosted Legendary Champions.
2. Shield up: shots bounce off (grey Xs, "Guard!"); thralls show "Target!".
3. Kill a thrall: slow-mo, the miniboss loses that thrall's power, the shield drops for 1 s per thrall.
4. Break one segment in time, or everything tiers up 1-3 by how much segment was left (map-wide option, on).
5. All segments gone: one-on-one with its main bar.
6. Main bar empties: it uses a life (thin bars) and tiers up (option). **No thralls rise: it fights its last lives alone**
   (owner 08:14: "I think B?", tentative). This drops the original Minibosses! rule that dead thralls rise again.
- GITD "thrall rooms glow their colour": DROPPED (owner 08:43: thralls spawn in the same room as the miniboss, so it tells
  you nothing).
- GITD in the fight (owner 08:44, yes and yes): the fight room glows steady cold grey while the shield is up and turns
  gold, pulsing with "Target!", when it drops; on the miniboss's death a map-wide wave in its colour, then a colour
  reroll. Not built.
- GITD "Randomize Colours" key (owner 08:44): BUILT (code only, loads clean, not run): RSQ Glow In The Dark menu,
  Randomize Colours Key (unbound; also under Controls > RSQ Glow In The Dark). New colours now, same look; it stands down
  while a miniboss tint, DOWN's red map or another mod's timed tint runs.
