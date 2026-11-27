# The Glossary's source lists

The in-game Glossary's words are generated from this file by `Score/tools/gen_glossary.py` (it writes
`Score/zscript/rsscore/glossary_data.zs`). The two lists below are the two regions of the old `Score/README.md` that the
script reads, saved here on 2026-11-27 from `git show 927ddbc7f~1:Score/README.md` when the README was rewritten from the
code, and edited the same day for the rows and combos taken out and put in (the Grapple's Kick and Air Spike, the
Whip's Wide Swing and Ground Crack; Lashed, Bowling and Chain Gang reworded). Change a row here, then run the script.

The script reads: the line that starts `**N bonuses**` down to the line with the `big-moments` anchor (each
`<summary><b>Section</b>`, each table row `| **Name** | Family | text | pay |`, each bullet `- **Name** (Family): text. xN`),
and the list under `All N named combos` (each `**Group**` line and each `- Name: steps (xN)` line, to `</details>`).
In the lists the multiplication sign is the real one (U+00D7), which is what the script looks for.

**206 bonuses**, in the groups below, plus the combo chain's own rows. The names are placeholders. Most rows only pay when the mod they read is
loaded; without it they stay silent. A row's pay is a share of the kill's base: ×0.5 adds half. "Big moment" marks the
rows that can slow the world for a beat (see Big moments). Where a row "replaces" another, the two never pay on the
same kill.

<details>
<summary><b>The classics</b> (13: the original score system's, every number kept)</summary>

| Row | Family | Pays for | Pay |
|---|---|---|---|
| **Spree** | Efficiency | Kills in quick succession. Each kill gives you 2 to 10 seconds (longer after a bigger monster) to make the next | +0.025 a kill in the run, at most ×0.25 |
| **Untouchable** | Efficiency | Kills since you last took damage. Starts once you have killed a tenth of the map's monsters (20 to 100) or a tenth of its health (2,000 to 10,000) untouched, then grows | up to ×0.5 |
| **Infighter** | Efficiency | A monster killed another monster. Paid to every player | ×0.2 |
| **Switcharoo** | Style | Two different guns fired in the last 2 to 4 seconds; or two different triggers (main, off hand, alt fire) | ×0.15; ×0.075 |
| **Air** | Style | You were off the ground. Paid on how high this jump reaches, from 64 units up | ×0.005 a unit, at most ×2.0; a big moment from ×0.5 |
| **Curveball** | Style | The monster had no line of sight to you | ×0.2 |
| **Darwin** | Style | The monster killed itself. Paid to every player | ×2.0 |
| **Telefragged** | Style | A telefrag | ×1.0, a big moment |
| **Coach Gun** | Daring | A Super Shotgun blast (Brutal Doom's own damage type for it); a weapon dealing "Scrap" pays ×0.125 | ×0.25 |
| **Brawler** | Daring | A kill with fists or a blade: Doom's fist and chainsaw, Brutal Doom's fists, saw and axe, RSQ Melee's and SuperPunchOut's gloves (×0.5); Heretic's, Hexen's and Strife's melee weapons at their own prices | ×0.1 to ×0.5 |
| **Redline** | Daring | Your health at 25 or less | ×0.02 at 25 up to ×0.5 at 1; a big moment at 5 or less |
| **Swan Song** | Daring | A kill that lands after you died. Replaces Redline | ×3.0, a big moment |
| **Point-Blank** | Daring | Within 64 units, edge to edge | ×0.1 |

</details>

<details>
<summary><b>Melee: blades, the Force, the shield, fists and boots</b> (27)</summary>

- **Fatality** (Melee): Brutal Doom's execution. ×0.5, a big moment.
- **Cleaved** (Melee): a melee kill that took the body apart. ×0.3.
- **Hurled** (Melee): the thrown ShieldSaw or saber; each further kill by the same throw pays more. ×0.3, +0.15 each, at most ×0.75.
- **Shield Work** (Melee): the shield's bash ×0.3, its revved grind ×0.2.
- **Riposte** (Counterplay): you blocked its attack (shield or saber), then killed it within 3 s. ×0.4.
- **Perfect Riposte** (Counterplay): the same after a perfect block. Replaces Riposte. ×0.7, a big moment.
- **Return to Sender** (Counterplay): a shot sent back killed it. ×0.4; a Hadouken or Swat Back ×0.6; the Guard's reflect ×0.5.
- **Combo** (Melee): kills by different melee moves within 4 s. ×0.1 a move past the first, at most ×0.4.
- **Poetic Justice** (Counterplay): a sent-back shot killed the monster that fired it. ×0.3, a big moment.
- **Boomerang** (Melee): a throw that killed on its way out kills again on its way home. ×0.5, a big moment.
- **Ground Down** (Melee): the thrown disc stuck in a tough monster and ground it to death. ×0.3.
- **Heavy Swing** (Melee): Brutal Doom VR's hard swing: the second blow of the swing killed ×0.15, the third ×0.3 (a big moment).
- **Choked** (Melee): the Force grip's choke, or RSQ Melee's Chokehold. ×0.3.
- **Slammed** (Melee): a body flung from the Force grip died hitting something. ×0.5, a big moment.
- **Juggle** (Melee): a melee kill of a monster in the air that you put there in the last 2 s. ×0.3.
- **Boot** (Melee): Brutal Doom's kick, head kick or stomp. ×0.2.
- **Pulled In** (Melee): the Force pull brought it, a melee blow finished it within 2 s. ×0.3.
- **Twin Blades** (Melee): a saber kill with a lit saber in each hand. ×0.2.
- **Rally** (Counterplay): sent-back shots killing one after another, each within 3 s: the second ×0.2, the third ×0.4, then ×0.6 (a big moment).
- **Ring Out** (Melee): the level or another monster finished what you sent there (see Who gets paid). ×0.5, a big moment.
- **Ground Pound** (Melee): the Force jump's landing, or RSQ Melee's two-fist pound. Replaces Slammed. ×0.3.
- **Clean Sweep** (Melee): the ShieldSaw thrown at two or more locks killed the last of them. ×0.5, a big moment.
- **Bank Shot** (Melee): the disc came off a wall onto a new lock and killed it. ×0.4, a big moment.
- **Shield Wall** (Counterplay): a kill while your shield blocked another monster's attack in the last second. ×0.25.
- **Counter** (Melee): a melee blow killed it mid-attack. ×0.3.
- **Knockdown** (Melee): a punch finished it while it reeled. ×0.2.
- **Flurry** (Melee): a run of glove punches, left and right, each within half a second: the third ×0.15, the fourth ×0.3, then ×0.45 (a big moment).

</details>

<details>
<summary><b>Shots, throws, the rig and slow motion</b> (14)</summary>

- **Thrown** (Style): something you threw with Distance Grab. ×0.2, +0.03 a m/s over 3, at most ×0.5.
- **Powder Keg** (Style): the blast of a barrel your throw set off; each kill within a second of the last pays more. ×0.3, +0.2 each, at most ×1.1; a big moment from the third.
- **Air Catch** (Daring): a thrown thing you caught back out of the air and threw again. ×1.0, +0.5 a catch, at most ×2.0, a big moment.
- **Skeet** (Style): the monster was in the air (not a flyer). ×0.25.
- **Quick Draw** (Daring): a shot from the gun you just drew from an RSQ Tactical Rig holster, within 1.2 s. ×0.35.
- **No-Look** (Daring): the shot left more than 60 degrees from where your head faced. ×0.3.
- **Blind-fire** (Daring): your eyes could not see it, but your hand's shot could. Replaces No-Look. ×0.4, a big moment.
- **Off-hand** (Style): your off hand's trigger fired the kill. ×0.2.
- **Full Hands** (Style): a shot kill while a hand carries something with Distance Grab. ×0.25.
- **Body Blow** (Style): a thrown corpse killed it. ×0.3.
- **Hand-Me-Down** (Style): a gun a dead monster dropped, thrown. ×0.3.
- **Hot Swap** (Daring): mid-fight you drew a different gun from a holster and it killed. ×0.25.
- **Stretched Second** (Style): a kill while RSQ SlowMo has the world slowed pays **Style Share** (50%) of what the kill's other bonuses paid, Efficiency's left out. Half that in a slow motion the game started for you; nothing in Score's own; 1.5 times as much at 10% speed or slower.
- **Two Guns** (Style): a shot kill from one hand within a second of one from the other. ×0.25.

</details>

<details>
<summary><b>The hook and the whip</b> (7)</summary>

- **Bowling** (Style): a live monster you threw out of the Headlock struck it. ×0.5, a big moment.
- **Kick** (Melee): RSQ Grapple's kick: you hooked it, flew to it, and the kick killed it. ×0.3.
- **Air Spike** (Melee): the monster you air-spiked died of the explosion where it landed. ×0.5, a big moment.
- **Lashed** (Melee): the whip's Wide Swing. ×0.25.
- **Wide Swing** (Melee): one Wide Swing killed two or more. Replaces Multi-Kill. ×0.3 a kill before this one, at most ×0.9; a big moment from the third.
- **Ground Crack** (Style): a monster your Ground Crack threw into the air, killed within 2 s while still in the air. Replaces Juggle and Skeet. ×0.3.
- **Variety** (Style): three or more of your tools in one fight (kills within 10 s of each other). ×0.15 a tool past two, at most ×0.6; a big moment at five.

</details>

<details>
<summary><b>Combo Chain</b> (1 bonus, many rows)</summary>

The chain described under Combos: its rows are **2-Tool Combo** to **6-Tool Combo** and one row per named combo.

</details>

<details>
<summary><b>The fists (RSQ Melee)</b> (13)</summary>

All Melee family.

- **Shoryuken**: an uppercut. ×0.3.
- **Liver Shot**: a punch below the chest. ×0.2.
- **Glass Jaw**: a punch to the top fifth. ×0.25.
- **Textbook**: jab, jab, hook inside a second. ×0.35.
- **Triple Threat**: jab, hook, uppercut inside a second. Replaces Shoryuken and Textbook. ×0.5, a big moment.
- **Dempsey Roll**: a run of alternating hooks. ×0.15 a hook past two, at most ×0.6.
- **Air Combo**: a punch on a monster your uppercut launched. Replaces Juggle and Skeet. ×0.3.
- **Bouncer**: the Clear Out palm thrust. ×0.3.
- **Release**: the Guard's stored charge let out. ×0.4.
- **Toss**: a monster thrown out of the Headlock dies of its landing. ×0.35.
- **Piledriver**: the Headlock Slam. ×0.5, a big moment.
- **Cut Loose**: the Headlock Uppercut. ×0.4.
- **Butt Stroke**: the gun-butt shove itself. ×0.3.

</details>

<details>
<summary><b>Shared melee</b> (6)</summary>

- **Weapon Master** (Melee): a run of kills with one melee mod (fists, saber, ShieldSaw, whip), each within 10 s. ×0.1 a kill past two, at most ×0.5.
- **Giant Slayer** (Melee): a melee kill of a monster of 400 health or more ×0.5; 2,000 or more ×1.0 (a big moment).
- **Death from Above** (Melee): a melee kill falling onto it from a metre above its head. ×0.4.
- **Juggler** (Style): a kill while your thrown saber or disc is still in flight. ×0.25.
- **Misdirection** (Counterplay): a sent-back shot killed a monster that did not fire it. ×0.25.
- **Multi-Kill** (Style): one blow, blast or swing killed more than one. Each kill past the first: a grenade ×0.2 (up to ×1.0), a shotgun ×0.3 (Super Shotgun ×0.35), a rifle ×0.15 (the sniper rifle ×0.5), an energy gun ×0.2 (the railgun ×0.4, up to ×1.2; the BFG ×0.1), other guns ×0.15, a Force push ×0.2, a Distance Grab throw ×0.3, a melee move ×0.25; at most ×0.75 otherwise. A big moment from ×0.6.

</details>

<details>
<summary><b>The saber and the ShieldSaw</b> (10)</summary>

- **Lunge** (Melee): a stab driven by your whole body. ×0.4.
- **Impaled** (Melee): you drew the blade out of an impaled monster. ×0.5, a big moment.
- **Back Off** (Counterplay): your crossed blades turned the shot that killed. Replaces Return to Sender. ×0.5.
- **Double Throw** (Melee): both sabers thrown, each killing within a second of the other. ×0.4.
- **Shield Dash** (Melee): the bash at the end of a Shield Dash. ×0.4.
- **Bit Off More** (Melee): ground to death on your revving shield while clawing at it. ×0.5.
- **Homecoming** (Melee): the disc or saber killed on its way home only. ×0.3.
- **Eyes in the Back** (Counterplay): the shield on your back blocked it, then you killed it. ×0.5.
- **Hold the Line** (Counterplay): Shield Wall, against two or more monsters in the last 2 s. Replaces Shield Wall. ×0.25, +0.1 a monster, at most ×0.55.
- **Cleaver** (Melee): the disc cut it in two thanks to the Cleaver upgrade. ×0.2.

</details>

<details>
<summary><b>Distance Grab, the rig, the grenade</b> (13)</summary>

- **Heavy Throw** (Style): a thrown thing of 100 kg or more. ×0.15.
- **Throwaway** (Style): a gun you threw. ×0.3, +0.2 if it was empty.
- **Iaido** (Daring): the saber drawn from its spot kills straight away. ×0.45.
- **Pin Pulled** (Daring): the grenade drawn from your belt buckle kills within 3 s. ×0.3.
- **Armory** (Daring): three different guns, each drawn from a holster and each killing, inside 6 s. ×0.5.
- **Cooked** (Daring): a grenade cooked in your hand for a second or more. ×0.2, +0.1 a half second more, at most ×0.6.
- **Airburst** (Style): the grenade went off in the air. ×0.35.
- **Tagged** (Style): a Sticky grenade killed the monster it rode. ×0.35.
- **Hold My Beer** (Daring): a grenade that went off in your hand killed it. ×0.5; ×0.8 if you lived. A big moment.
- **Cluster Bomb** (Style): a Cluster bomblet. ×0.25.
- **Civil War** (Efficiency): a monster your Infight or Charm grenade turned made the kill. ×0.4.
- **Blindside** (Style): killed while your Flash or Smoke grenade had it blind. ×0.3.
- **Barbecue** (Style): your Incendiary's fire finished it. ×0.25.

</details>

<details>
<summary><b>The guns</b> (10)</summary>

- **Hold Streak** (Style): kills while one trigger stays down. ×0.15 a kill past two, at most ×0.6.
- **Double Tap** (Style): two pistol hits within 10 tics, the second kills. ×0.2.
- **Hand Cannon** (Efficiency): one revolver round from full health to dead. ×0.25 with Brutal Doom VR's revolver; ×0.3 with the other revolver Score knows (its slug).
- **Headshot** (Daring): the killing blow was a head shot. ×0.25; ×0.4 with the sniper rifle or the revolver.
- **Sights Up** / **Glass** (Daring): a gun kill from 768 units or more, aimed down the gun (the shot within 2 degrees of your head's facing) ×0.2; the sniper rifle or railgun from 1,024 units ×0.4, from 2,048 ×0.6.
- **Direct Hit** (Style): a rocket's impact, not its splash. ×0.2.
- **Danger Close** (Daring): a nuke kill with you within 768 units, alive. ×0.5.
- **Unmade** (Daring): an Unmaker kill of a monster of 1,000 health or more. ×0.3.
- **Rip and Tear** (Melee): a chainsaw kill of a monster of 400 health or more. ×0.5; a big moment from 1,000.
- **Tomahawk** (Melee): a thrown axe. ×0.3.

</details>

<details>
<summary><b>Champions, LegenDoom and RSQ Miniboss</b> (40)</summary>

**What the monster was** (Daring; one colour row and one mutation row a kill, the bigger wins):

- **Champions' colours:** Dark Red, Red, Orange, Yellow, Dark Green, Green, Cyan, Blue, Indigo, Violet, Pink, Black, Grey and White Champion ×0.25; **Bronze** and **Silver Champion** ×0.5; **Gold Champion** ×0.75. A champion's extra health is in its base already; these pay for its powers.
- **Champions' mutations:** **Titan** ×0.5 (a big moment), **Undying** ×0.5 (its heart killed first), **Ghost**, **Balloon** and **Hybrid** ×0.25.
- Each Champion row carries its power's icon, the series' own (left of the number, or right of the name when the
  colour-blind letter is on the left). Rig only, not headset-confirmed (the picture below).
- **LegenDoom:** **Legendary** (it rose) ×1.5, a big moment; **Legend Denied** (killed before it could rise) ×0.75; **Legendary Champion** (risen, with its champion powers on) ×0.5, a big moment. With Champions' LegenDoom dormant mode a champion has no powers until it rises, and pays no colour row before then.

![A White Champion kill's breakdown: +21 White Champion with its snowflake icon, under the base row](docs/readme/champion_row.jpg)

*A White Champion's row in the breakdown, "+21 White Champion" with its snowflake icon on the left (rig capture, not headset).*

**How you killed it** (Daring unless marked):

- **Immovable Object**: a melee kill of a Bronze champion. ×0.4.
- **Pop!**: a Balloon champion, killed with anything but a gun. ×0.3.
- **Pinata**: a champion gibbed. ×0.25.
- **Champion Streak**: champion kills each within 5 s. ×0.1 each, at most ×0.5.
- **Too Close for Comfort**: an Orange champion, in melee or point-blank. ×0.35.
- **Glass Cannon**: a Black champion in one blow from full. ×0.35.
- **Fool's Gold**: a monster a Gold champion gilded. ×0.2.
- **Heartbreaker**: an Undying champion within 2 s of its heart. ×0.35.
- **Champion Fatality** (Melee): Brutal Doom's Fatality on a champion. ×0.25.
- **Rainbow**: champions of 5, 10 and all 14 colours in one map: ×0.5, ×1.0, ×2.0, each paid once (a big moment from ×1.0).
- **One-Tap Legend**: a legendary from its full health in one blow. Replaces Legend Denied. ×1.0, a big moment.
- **Strike While It Rises**: a legendary within 2 s of rising. ×0.5.
- **Legend Slayer**: two legendaries within 10 s. ×0.5.
- **Chain Gang**: thralls killed one after another, each within 12 s of the last: the second ×0.4, the third ×0.8, then ×1.0 (a big moment).
- **Riot Control**: an enraged monster. ×0.15.

</details>

<details>
<summary><b>The second round of moves, and the last grain of slow motion</b> (10)</summary>

- **Run Through** (Melee): a saber stab. ×0.25.
- **Unlimited Power** (Melee): Force Lightning. ×0.35.
- **Clash Break** (Melee): a monster staggered by your blade-lock shockwave, killed within 3 s. ×0.35.
- **Buzzsaw** (Melee): a grind kill after 1.5 s or more of grinding. Replaces Shield Work. ×0.3.
- **Wall Splat** (Melee): knocked into a wall, killed by it. ×0.4; a big moment on a monster of 400 or more.
- **Clubbed** (Melee): a thing you held, swung into it. ×0.3, +0.1 a corpse.
- **Trap Shot** (Style): your grenade, shot by you in the air. ×0.6, a big moment.
- **Teeth** (Style): a grenade you pulled the pin of with your teeth. ×0.15.
- **Contact** (Style): an Impact grenade burst on it. ×0.4.
- **Last Grain** (Style): a kill as the world speeds back up at the end of a slow motion. ×0.2.

</details>

<details>
<summary><b>RSQ Melee's moves, second round</b> (14)</summary>

- **Swatted** (Counterplay): a missile your open palm knocked aside killed something. Replaces Return to Sender. ×0.5.
- **Rope-a-Dope** (Counterplay): your Guard soaked its blow and you killed it within 3 s. ×0.4; ×0.6 with your hands or a hand weapon.
- **Seismic** (Melee): one Ground Pound kills two or more. Replaces Multi-Kill. ×0.3 a kill past the first, at most ×0.9 (a big moment from ×0.6).
- **Out of My Way** (Melee): the same for one Clear Out.
- **Full Release** (Counterplay): the same for one Guard release.
- **Meat Shield** (Counterplay): the monster in your Headlock dies of what another monster threw at you. Replaces Ring Out. ×0.6.
- **Human Shield** (Daring): a kill while your off hand holds a monster as a shield. ×0.3.
- **Field Goal** (Melee): the blast of a barrel your uppercut kicked. ×0.5.
- **Seeing Stars** (Melee): a monster a Heavy Hands punch froze, killed within a second. ×0.3.
- **Meteor** (Melee): a monster your uppercut launched came down on it. ×0.4.
- **Star Punch** (Melee): the gloves' Star Punch. ×0.5, a big moment.
- **Down for the Count** (Melee): a monster your Rifle Butt knocked down, killed within 3 s. ×0.35.
- **Bare Knuckle** (Daring): a glove kill with RSQ Melee's Slappers Only on. ×0.15.
- **Red Mist** (Style): a shotgun kill in your F.E.A.R. slow motion on a monster you did not shove. ×0.35.

</details>

<details>
<summary><b>Reading the monster's attack</b> (2)</summary>

- **Justice Shot** (Counterplay): your gun killed it while it wound up an attack, before the attack left it. ×0.4; a big moment on a monster of 700 or more.
- **Read It** (Counterplay): its shot passed within 1.5 m of you and never hurt you, and you killed it within 3 s. ×0.5.

</details>

<details>
<summary><b>RSQ Monsters' roster</b> (20, each with its own switch on the options page)</summary>

**The ladder's tiers** (Daring; one a kill; Common pays none): **Green** ×0.1, **Blue** ×0.15, **Cyan** ×0.2,
**Purple** and **Yellow** ×0.25, **FireBlu** and **Abyss** ×0.3, **Brown** and **Gray** ×0.35, **Red** ×0.4, the
**Black Boss** ×0.75 and **White Boss** ×1.0 (both big moments). **EX Boss** ×0.5 pays on top (a big moment).

RSQ Monsters numbers its ladder by strength since 11-11 (1 Common, 2 Green, 3 Blue, 4 Purple, 5 Cyan, 6 Brown,
7 Yellow, 8 FireBlu, 9 Gray, 10 Red, 11 Abyss, 12 Black, 13 White). These rows are paid by colour and ranked by how rare
a colour's spawn is, not by its number, so the renumber changed none of their pay; Keep the Change, Fresh Paint, Upset
and Tier Slayer use that rarity rank too.

**The roster:**

- **Rarity** (Daring): how rare the monster's spawn was, from 1 in 20: ×0.1 a doubling past 1 in 10, at most ×1.0 (a big moment from ×0.5).
- **Full Spectrum** (Daring): all 13 colours killed by you in one map. ×2.0 once, a big moment.
- **Colour Chain** (Style): the same colour killed again and again. ×0.15 a kill past two, at most ×0.75.
- **Keep the Change** (Efficiency): killed while it flashes, about to move up a tier. ×0.3; ×0.5 if it was becoming a boss.
- **Fresh Paint** (Style): killed within 3 s of moving up a tier. ×0.25.
- **Upset** (Efficiency): a Common, Green or Blue monster killed a boss tier or an EX. Paid to every player. ×0.75, a big moment.
- **Tier Slayer** (Daring): a boss tier or EX killed with a pistol, fists, a kick or the shove. ×0.5, a big moment.


</details>

<details>
<summary><b>Points from other mods</b> (6)</summary>

These rows pay when another mod says so, not on a kill of their own:

- **Deflect**, **Remote Down** (Melee): RSQ Saber's training remote, a bolt knocked back into it and the remote knocked out of the air.
- **Rank** (Daring): RSQ Miniboss's Rank multiplies every payment, x1 at Rank 0 up to x2 at Rank 100 (**Rank Multiplier at Top Rank**, 2.0); the extra lands on this row. Gold deposits are multiplied the same way (code only, not run, 2026-11-23).
- **Finisher** (Melee): RSQ Miniboss's melee finisher on a staggered thrall or a Boss in BREAK! (code only, not run, 2026-11-23; paid on the Base row before).
- **Boss** (Daring): RSQ Miniboss's, a share of the kill it is for: ×3.0 for the Boss you called in (RSQ Miniboss's
  "Miniboss Called" label, paid to this row; ×1.0 for the older "Miniboss" label): one row, one reward. The row was named
  "Miniboss" until 2026-11-16.
- **Revenge** ×1.0 (Daring): RSQ SlowMo's DOWN. Revenge is the kill's base (100 if no kill comes with it).

</details>

<a name="big-moments"></a>

<details>
<summary><b>All 171 named combos</b> (names are placeholders; the pay is a share of the kill's base)</summary>

The guns: **pistol** (the pistols and revolvers), **shotgun** (shotguns and the Super Shotgun), **rifle** (rifles,
machine guns, the minigun, the sniper rifle, the chaingun), **launcher** (rockets, launcher grenades, the nuke),
**energy gun** (plasma, the railgun, the BFG, the Unmaker), **flamethrower**. **Punch** is a punch RSQ Melee lands (its
gloves, or any fist with Melee loaded) or SuperPunchOut's gloves; **punch or kick** adds any other punch and Brutal
Doom's kick.

**The first twelve**

- Lion Tamer: whip → shield bash (×0.5)
- Clay Pigeon: Force push → gun (×0.5)
- Sitting Duck: Force grip → gun (×0.5)
- Pull!: Force pull → gun (×0.5)
- Disc Jockey: Force push → ShieldSaw throw (×0.5)
- Gun Kata: punch or kick → gun (×0.4)
- Fast Hands: any melee → holster draw (×0.5)
- Pitch and Slice: Distance Grab throw → saber cut (×0.5)
- Yo-Yo: Force pull → Force push → gun (×0.9)
- Discus: shield bash → Force push → ShieldSaw throw (×0.9)
- Headlock: Headlock → punch or kick (×0.5)
- F.E.A.R. Effect: gun-butt shove → shotgun (in your slow motion) (×0.6)

**The fists (RSQ Melee): punches, the uppercut, the shove, the Guard, the Headlock**

- Trap Shooter: uppercut → shotgun (×0.5)
- Rising Dragon: uppercut → saber cut (×0.5)
- Spike: uppercut → ShieldSaw throw (×0.5)
- Air Lash: uppercut → Wide Swing (×0.5)
- Alley-Oop: uppercut → Distance Grab throw (×0.5)
- Air Mail: uppercut → grenade (×0.5)
- Fireworks: uppercut → launcher (×0.5)
- One-Two-Skeet: punch → uppercut → shotgun (×0.9)
- Cross Cut: hook punch → saber cut (×0.4)
- Fist and Shield: punch → shield bash (×0.4)
- Knuckle Crack: punch → Wide Swing (×0.4)
- Jedi Jab: punch → Force push (×0.4)
- Punch and Pitch: punch → ShieldSaw throw (×0.4)
- Slow Trap Shooter: uppercut (in your slow motion) → shotgun (×0.55)
- Feint: jab → saber stab (×0.45)
- Skyskewer: uppercut → saber stab (×0.55)
- Pistol Whip: gun-butt shove → pistol (×0.5)
- Executioner: gun-butt shove → gun (head shot) (×0.6)
- Riot Shield: gun-butt shove → shield bash (×0.5)
- Make Room: gun-butt shove → saber cut (×0.4)
- Fire in the Hole: gun-butt shove → grenade (×0.45)
- Backlash: gun-butt shove → Wide Swing (×0.4)
- Street Fighter: Hadouken → uppercut (×0.6)
- Shoto: Hadouken → saber cut (×0.5)
- Return Fire: Hadouken → gun-butt shove → shotgun (×1.0)
- Neo: Hadouken (in your slow motion) → punch (×0.6)
- Backhand Spring: Swat Back → uppercut → pistol (×1.0)
- Parry Punish: Guard parry → anything (×0.5)
- Counter Cut: Guard parry → saber (×0.6)
- Knuckle Sandwich: Guard parry → punch (×0.55)
- Dragon Fist: Guard parry → uppercut → punch (×0.9)
- Pressure Valve: Guard release → punch (×0.5)
- Hostage: Headlock → pistol (×0.5)
- Close Quarters: Headlock → shotgun (×0.5)
- Hold This: Headlock → grenade (×0.6)
- Execution: Headlock → saber (×0.5)
- Suplex: Headlock → Headlock toss (×0.5)
- Flog: Headlock → Wide Swing (×0.5)
- Title Belt: Headlock → punch or kick · on a champion (×0.6)
- Bouncer: Headlock → punch or kick → shotgun (×0.9)
- Choke and Cut: Headlock → Chokehold → saber cut (×0.9)
- Slam and Blam: Headlock → Headlock Slam → shotgun (×0.9)
- Clay Toss: Headlock toss → shotgun (×0.5)
- Ground and Pound: Headlock Slam → punch (×0.5)
- Pin Down: Headlock Slam → saber stab (×0.55)
- Come Get Some: taunt → punch or kick (×0.4)
- Come Closer: taunt → shotgun (×0.5)
- Tremor: Ground Pound → shotgun (×0.45)
- Quake: Ground Pound → shield bash (×0.4)
- Get Back!: Clear Out → grenade (×0.5)
- Spread Out: Clear Out → launcher (×0.45)

**The saber and the Force (RSQ Saber)**

- Laser Sword: saber cut → energy gun (×0.5)
- Blade and Buckshot: saber cut → shotgun (×0.45)
- Edge and Board: saber cut → shield bash (×0.4)
- Pommel: saber cut → punch (×0.4)
- Slash and Blast: saber cut → Force push → shotgun (×0.9)
- Distraction: saber throw → punch (×0.5)
- Covering Fire: saber throw → rifle (×0.45)
- Air Traffic: saber throw → ShieldSaw throw (×0.5)
- Throw and Go: saber throw → saber cut (×0.4)
- Return Flight: saber throw → Force pull → saber cut (×0.9)
- Helpless: Force grip → saber cut (×0.5)
- Hung Out to Dry: Force grip → punch (×0.5)
- Special Delivery: Force grip → grenade (×0.5)
- Pinned: Force grip → ShieldSaw throw (×0.5)
- Strung Up: Force grip → Wide Swing (×0.5)
- Exorcism: Force grip → saber cut · on a Ghost champion (×0.6)
- Jedi Brawler: Force grip → punch → saber cut (×0.9)
- Superhero Landing: Force jump landing → punch (×0.5)
- Leap Strike: Force jump landing → saber cut (×0.5)
- Come Here, Go Up: Force pull → uppercut → shotgun (×0.9)
- Force Arrest: Force pull → Headlock → punch (×0.9)
- Jedi Hoplite: Force pull → shield bash → saber cut (×0.9)
- Clay Saber: Force push → saber throw (×0.5)
- Hot Seat: Force push → grabbed barrel (×0.5)
- Scoundrel: Force push → saber throw → pistol (×0.9)
- Push-Pull: Force push → Force pull → saber cut (×0.9)
- Time Slash: Force push (in your slow motion) → saber cut (×0.55)
- Off the Blade: saber stab → Force push (×0.5)
- Stab and Jab: saber stab → punch (×0.4)
- Shock and Awe: Force Lightning → punch (×0.5)
- Sith Ambush: Force Lightning → saber cut (×0.5)
- Overcharge: Force Lightning → energy gun (×0.5)

**The ShieldSaw (RSQ ShieldSaw)**

- Riot Control: shield bash → shotgun (×0.5)
- Bash and Slash: shield bash → saber cut (×0.5)
- Bash and Lash: shield bash → Wide Swing (×0.4)
- Shield and Fist: shield bash → punch (×0.4)
- Crack the Shell: shield bash → blade · on a Bronze, Gold or Titan champion (×0.55)
- Bash and Launch: shield bash → uppercut → shotgun (×0.9)
- Shield Up: shield block → grenade (×0.5)
- This Is Sparta: shield block → shield bash → saber (×0.9)
- Riot Squad: shield block → shield bash → shotgun (×0.9)
- Shield Uppercut: shield block → shield bash → uppercut (×1.0)
- Slow Sparta: shield block (in your slow motion) → shield bash → saber cut (×1.0)
- Saw and Saber: ShieldSaw throw → saber cut (×0.5)
- Crossfire: ShieldSaw throw → saber throw (×0.5)
- Follow-Through: ShieldSaw throw → punch (×0.4)
- Throw and Follow: ShieldSaw throw → shield bash (×0.4)
- Cleanup Crack: ShieldSaw throw → Wide Swing (×0.4)
- Sawblade Send-Off: shield grind → Force push → ShieldSaw throw (×0.9)
- Hoplite: shield bash → saber stab (×0.55)
- Nailed: shield slam → saber stab (×0.55)
- Up Against the Wall: shield slam → punch (×0.5)

**The whip (RSQ Whip)**

- Frontier: Wide Swing → pistol (×0.5)
- High Noon: Wide Swing → holster draw (×0.6)
- Zorro: Wide Swing → saber (×0.5)
- Big Top: Wide Swing → ShieldSaw throw (×0.55)
- Crack and Smack: Wide Swing → punch (×0.4)
- Crack of Doom: Wide Swing → anything · on a legendary not yet risen (×0.6)
- Bullet Ballet: Wide Swing (in your slow motion) → gun (×0.9)

**Distance Grab**

- Catch This: Distance Grab throw → punch (×0.45)
- Batter Up: Distance Grab throw → gun (×0.35)
- Serve and Volley: Distance Grab throw → shield bash (×0.45)
- Two Throws: Distance Grab throw → ShieldSaw throw (×0.45)
- Toss and Crack: Distance Grab throw → Wide Swing (×0.45)
- Kitchen Sink: Distance Grab throw → grenade → gun (×1.0)
- Aftershock: grabbed barrel → any melee (×0.5)

**The grenade (RSQ Grenade, or Brutal Doom VR's own)**

- Into the Breach: grenade → any melee (×0.45)
- Mop Up: grenade → gun (×0.3)
- Shell Shock: grenade → punch (×0.5)
- Frag and Slash: grenade → saber cut (×0.5)
- Demolition: grenade → grabbed barrel → gun (×1.0)
- Ice Breaker: Freeze grenade → punch (×0.55)
- Cold Cut: Freeze grenade → saber cut (×0.55)
- Cold Shoulder: Freeze grenade → shield bash (×0.55)
- Ice Pop: Freeze grenade → uppercut → shotgun (×1.0)
- Dazed and Confused: Stun grenade → punch (×0.55)
- Stun and Gun: Stun grenade → gun (×0.45)
- Dizzy Finish: Stun grenade → punch → Fatality (×1.0)
- Lights Out: Flash grenade → any melee (×0.5)
- Blind Side: Flash grenade → saber (×0.55)
- Out of the Smoke: Smoke grenade → any melee (×0.5)
- Ninja: Smoke grenade → saber stab (×0.55)
- Batting Practice: held thing swung → gun (×0.4)
- Ghost Hold: Smoke grenade → Headlock → blade (×1.0)
- Pin Cushion: Sticky grenade → gun (×0.45)
- Return to the Pack: Sticky grenade → Force push → grenade (×0.9)
- Hot Lash: Incendiary → Wide Swing (×0.5)
- Fan the Flames: Incendiary → Force push → flamethrower (×0.9)

**The guns open it**

- Rocket Punch: launcher → punch (×0.5)
- Over-Under: launcher → rifle (×0.4)
- Mop-Up Saw: launcher → chainsaw (×0.5)
- Hot Hands: flamethrower → punch (×0.5)
- Fire Whip: flamethrower → Wide Swing (×0.45)
- Plasma Blade: energy gun → saber cut (×0.45)
- Shoot and Snap: pistol → Wide Swing (×0.4)
- Buckshot Brawl: shotgun → punch (×0.4)
- Clean Up: shotgun → saber cut (×0.4)
- Suppress and Storm: rifle → shield bash (×0.45)
- Rip and Pump: chainsaw → shotgun (×0.4)
- Door Kick: kick → shotgun (point-blank) (×0.5)

**The rig, a lean, shots sent back**

- Showdown: holster draw (in your slow motion) → gun (×0.9)
- Draw and Shove Off: holster draw → Force push → pistol (×0.9)
- Tuco: thrown gun → holster draw (×0.5)
- Slip and Shoot: lean out of a round → gun (×0.4)
- Bob and Weave: lean out of a round → punch or kick (×0.5)
- Tennis: a shot sent back → a shot sent back (×0.5)
- Volley: a shot sent back → a shot sent back → a shot sent back (×1.0)
- Kingslayer: anything (in your slow motion) → anything · on the Boss (×0.5)

</details>
