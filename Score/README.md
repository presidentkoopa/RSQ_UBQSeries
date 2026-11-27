# RSQ Score

RSQ Score counts what you do to monsters. Every kill gives its base points, how you made the kill adds bonus rows under the score line, and a full reward bar gives a Score life that catches a killing hit. It also judges head shots, rolls critical shots, keeps the gold bank other mods fill, and replaces the help screen with its Glossary.

<a name="how-to-play"></a>
## How to play

Score has no keys. It watches your kills and names them. "Base" is the killed monster's spawn health, in points. A bonus written "+0.3 x base" adds three tenths of that. The word in brackets is the row's family: its colour and its column on the HUD. "A big moment" means the kill also asks for the short slow motion of its own row below. 1 s is 35 tics.

| Do this | What happens | Needs |
|---|---|---|
| Press the engine's help key (the menu's own note: F1 / Read This!) | The RSQ Score Glossary opens in place of the engine's help pages |  |
| Open Options, Radiant Silvergun Options, RSQ Score, Glossary | The same Glossary |  |
| In the Glossary, press Up or Down | The row above or below is picked, with the menu's cursor sound; past either end it wraps; the list shows 9 rows and scrolls to keep the pick in view |  |
| In the Glossary, press Page Up or Page Down | The pick moves 9 rows and stops at the ends |  |
| In the Glossary, press Left or Right | The tab before or after, wrapping: Efficiency, Style, Daring, Melee, Counterplay, Combos. It opens on Style and each tab keeps its own place |  |
| In the Glossary, press Enter | Nothing |  |
| In the Glossary, press Back | The Glossary closes |  |
| Point at a tab and click (it acts when the button is let go) | That tab opens | A mouse, or a pointer that sends mouse events |
| Point at one of the 9 rows shown and click | That row is picked and its detail shows on the right | A mouse, or a pointer that sends mouse events |
| Read the Glossary's page | A solid dark page: the title RSQ SCORE GLOSSARY in gold, six tabs each in its family's colour, the list on the left (name in the family colour, its first +N in white), the detail on the right (name, what it is for, Bonus, Needs), a line of keys at the foot |  |
| On the rig, with the Glossary open, set rs_score_glosstest to 1, 2, 3, 4, 5 or 6 in the console | Up, Down, Left, Right, Page Down or Page Up is pressed once, and the setting goes back to 0 | No menu row; not saved |
| Kill a monster the level counts, a Lost Soul, or a monster that replaces a counted one | Base: its spawn health in points, to the player whose blow killed it. The points go on the total (Score: n) and on the reward bar |  |
| Kill in a way a row below names | That row's bonus is added: a share of the base. All the bonuses of one kill together add at most 3 x base. Each shows on its own row under the bar for 35 tics, growing while it is still shown | Kill Bonus Cap (default 300); Bonus Time (default 35) |
| Kill a monster that was not on the map by its first tic (raised, or spawned later) | Raised Monster Pay percent of its base: 100 by default, so the same as any kill | Raised Monster Pay (%) (default 100) |
| Let the level kill a monster with no blow of yours (a crusher, a floor) | Nothing |  |
| Fill the reward bar | A Score life. The reward sound plays and the bar lights; 24 tics later the life sound plays and the faces pop. The bar's length is the map's average monster health x half its monster count (counted as 140 to 800), rounded to 5000 | Reward: Life Only (default); Reward Bar: On (default) |
| Start a new game | You hold 1 Score life | Starting Lives (default 1) |
| Take a hit that would have killed you while you hold a Score life | You are held at 1 health, then set to full health, and one life is spent: the revive sound, a blast round you (384 damage over 256 units, not to you), a ring of fire, no damage at all for 95 tics, invulnerable for 5 s, and both held guns' magazines filled | Revival Fire: On (default) for the fire |
| Die anyway while holding lives (a telefrag, forced damage) | One life is lost; the others are kept |  |
| Finish a map and start the next | The total, the reward bar and your Score lives all start again from nothing | New Map Keeps: Nothing (default) |
| Walk over the gold life crate | 1 Score life, with the life sound and the faces' pop | Another mod must spawn it by name (RSQ Miniboss, when its Boss is beaten) |
| Shoot a monster in the head: the bullet's puff or the missile lands at or above its kind's head height (a kind with no numbers: the top fifth) | More damage on that blow, from you: 30 more on zombie, sergeant, chaingunner, imp and SS kinds; the blow's damage again on baron, knight, arch-vile, revenant, mancubus and cyberdemon kinds; the larger of the two on any other | Head Shots: On (default); Heads on Demons: On (default); Unknown Head (%) (default 80) |
| Fire a gun | Each shot has a 15 in 100 chance to be a critical shot. A critical projectile flies in Cyan. Where it lands: damage x2, the monster is held stunned for 50 tics and takes x2 from every other blow meanwhile, with the ZX Clash sound and a Blue Flash | Critical Hits: On (default); Crit Chance (default 0.15); Crit Colour (default Cyan); not while mk-crits or RandomCrits is loaded |
| Punch, saw or kick (a melee hitscan) | No critical roll |  |
| Make a kill that its row calls a big moment | Score asks RSQ SlowMo for a short slow motion: 600 ms at 35 in 100 of full speed, no sooner than 6 s after the last one | Slow Motion: On (default); Cooldown (s) (default 6); RSQ SlowMo |
| Look up at the top middle of your view | Score: and the total (Across 50, Down 13), the reward bar under it, one Doomguy face for each Score life (10 at most are drawn), and under the bar the bonus rows in three columns: Efficiency on the left, Style and Melee in the middle, Daring and Counterplay on the right | Show Score: On (default); Size (default 150) |
| Open any menu, or the automap | The score line is not drawn while it is open |  |
| Kill again before the last kill's time runs out (2 to 10 s, by that monster's health: 24 tics per 100) | **Spree** (Efficiency): +0.025 x base for each kill in the run so far, at most +0.25 |  |
| Kill without taking damage, once a tenth of the map's monsters (20 to 100 kills) or of their health (2000 to 10000) is down unhurt | **Untouchable** (Efficiency): Each kill adds a stack (one more per 400 health killed): +0.025 x base a stack, at most +0.5 at 20. Any damage you take ends it |  |
| Let one monster kill another | **Infighter** (Efficiency): Every player gets the base and +0.2 x base |  |
| Kill after hitting with two different guns inside the last 72 to 144 tics (by the monster's health) | **Switcharoo** (Style): +0.15 x base; two triggers of one gun (main hand fire, off hand fire, alt fire) +0.075 |  |
| Kill while off the ground on a jump that reaches more than 64 units above the floor you left | **Air** (Style): +0.005 x base a unit past 64, at most +2.0. A big moment from 164 units |  |
| Kill a monster that has no clear line to you from its feet, middle or head | **Curveball** (Style): +0.2 x base |  |
| Kill with a blow of damage type SSG | **Coach Gun** (Daring): +0.25 x base (type Scrap: +0.125) | A gun that deals type SSG (the code's note: BD22 VR's Super Shotgun) |
| Let a monster kill itself | **Darwin** (Style): Every player gets the base and +2.0 x base |  |
| Kill by telefrag | **Telefragged** (Style): +1.0 x base. A big moment |  |
| Kill with a fist, saw or axe: the weapon that struck or the one in the main hand is Fist, Chainsaw, a glove, Chain_saw or BrutalAxe | **Brawler** (Daring): +0.5 x base (Heretic's and Hexen's hand weapons +0.1 to +0.5). Nothing for a shot, a shove, a throw, a choke, a whip or hook blow, or a grenade |  |
| Kill while your own health is 25 or less | **Redline** (Daring): +0.02 x base at 25, +0.02 more for each point lower, +0.5 at 1. A big moment at 5 or less |  |
| Land a kill after you have died | **Swan Song** (Daring): +3.0 x base. Replaces Redline. A big moment |  |
| Kill within 64 units, measured edge to edge | **Point-Blank** (Daring): +0.1 x base |  |
| Make a melee kill that gibs the monster | **Cleaved** (Melee): +0.3 x base |  |
| Make melee kills of different kinds within 4 s (saber, disc, bash, grind, blade, fist, boot, whip and so on) | **Combo** (Melee): +0.1 x base for each kind past the first, at most +0.4. Not on a kill whose own chain mixed two tools |  |
| Make a melee kill on a monster at least 2 units off the floor (not a flyer) that your punch, kick, Force or whip touched in the last 2 s | **Juggle** (Melee): +0.3 x base. Replaces Skeet |  |
| Punch, kick, push or whip a monster, then let the level or another monster kill it within 2 s | **Ring Out** (Melee): The kill is yours: base and +0.5 x base. A big moment |  |
| Kill with a melee blow while the monster is in its Missile or Melee states, or within 18 tics of its shot | **Counter** (Melee): +0.3 x base |  |
| Kill with a fist while the monster is in its Pain states | **Knockdown** (Melee): +0.2 x base |  |
| Kill a monster that is 24 units or more above its floor (not a flyer, not standing on another) | **Skeet** (Style): +0.25 x base |  |
| Kill with a shot that leaves more than 60 degrees away from where your head faces | **No-Look** (Daring): +0.3 x base. Not for a rocket's splash |  |
| Kill with a shot while your eyes have no line to the monster and a point within 40 units of your eyes has | **Blind-fire** (Daring): +0.4 x base. Replaces No-Look. A big moment |  |
| Kill with a shot fired by the off hand's trigger alone | **Off-hand** (Style): +0.2 x base |  |
| Kill with a shot from one hand's trigger within 1 s of a shot kill from the other hand's | **Two Guns** (Style): +0.25 x base |  |
| Hit one monster with two or more different tools, no more than 3 s between moves, and kill it | **Combo Chain** (Style): 2-Tool Combo +0.2 x base, 3-Tool +0.45, 4-Tool +0.75, 5-Tool +1.0, 6-Tool +1.2; +0.1 for each mod past two (at most +0.3); x1.25 if the whole chain took 2 s or less. A named combo (the list below) takes the place of the tools it names |  |
| Bring a new tool into a fight (kills no more than 10 s apart) once three or more are in it | **Variety** (Style): +0.15 x base for each tool past two, at most +0.6. Not on a kill whose own chain mixed two tools. A big moment at five |  |
| Make three or more kills in a row with one melee mod (fists, saber, ShieldSaw or whip), each within 10 s | **Weapon Master** (Melee): +0.1 x base for each kill past two, at most +0.5 |  |
| Make a melee kill on a monster of 400 spawn health or more | **Giant Slayer** (Melee): +0.5 x base; +1.0 from 2000 (a big moment) |  |
| Make a melee kill while falling, your feet 34 units or more above the monster's head | **Death from Above** (Melee): +0.4 x base |  |
| Kill more than one monster with one blast, bolt or thrown thing inside 1 s, or with one tool on one tic | **Multi-Kill** (Style): For each kill before this one: grenade +0.2 x base, shotgun +0.3 (SSG +0.35), Sniper +0.5, RailGun +0.4, BFG +0.1, other guns +0.15, a Force push +0.2, a thrown thing +0.3, melee +0.25; at most +0.75 (grenade +1.0, RailGun +1.2). A big moment from +0.6 |  |
| Make three or more shot kills while one trigger stays held | **Hold Streak** (Style): +0.15 x base for each kill past two, at most +0.6 |  |
| Hit a monster twice with a pistol within 10 tics; the second hit kills | **Double Tap** (Style): +0.2 x base |  |
| Kill a monster from full health with one round of BrutalRevolver or Revolver | **Hand Cannon** (Efficiency): BrutalRevolver +0.25 x base, Revolver +0.3 | A weapon of that class name |
| Kill with a head shot (the killing blow itself) | **Headshot** (Daring): +0.25 x base; +0.4 with Sniper or BrutalRevolver |  |
| Kill with a gun from 768 units or more, the shot within 2 degrees of where your head faces | **Sights Up / Glass** (Daring): Sights Up +0.2 x base. With Sniper or RailGun from 1024 units the row is Glass: +0.4, +0.6 from 2048 |  |
| Kill with a rocket's direct hit (the inflictor's class starts Rocket), not its splash | **Direct Hit** (Style): +0.2 x base |  |
| Kill a monster of 400 spawn health or more with a chainsaw | **Rip and Tear** (Melee): +0.5 x base. A big moment from 1000 |  |
| Shoot a monster dead while it is in its attack and before its shot has left (none in the last 1 s) | **Justice Shot** (Counterplay): +0.4 x base. A big moment on a monster of 700 health or more |  |
| Let a monster's shot pass within 48 units of you without hurting you, then kill that monster within 3 s | **Read It** (Counterplay): +0.5 x base |  |
| Kill with a blow of damage type Fatality | **Fatality** (Melee): +0.5 x base. A big moment | Brutal Doom |
| Kill with a blow of damage type Kick, HeadKick or Stomp | **Boot** (Melee): +0.2 x base | Brutal Doom |
| Swing hard enough that the second or third stacked blow of one swing kills | **Heavy Swing** (Melee): Second +0.15 x base, third +0.3 (a big moment) | BD22 VR Reloaded (its AxeAttack and MeleeStrike attacks) |
| Kill with a nuke while you stand within 768 units and live | **Danger Close** (Daring): +0.5 x base | A gun whose blast is named Nuclear... or deals type Nuke (Brutal Doom) |
| Kill a monster of 1000 spawn health or more with the Unmaker | **Unmade** (Daring): +0.3 x base | A gun whose shot's class starts Unmaker |
| Kill with a thrown axe (class ThrowedAxe...) | **Tomahawk** (Melee): +0.3 x base | BD22 VR Reloaded's axe |
| Kill with a glove at the end of a run of punches, left and right in turn, each within 17 tics | **Flurry** (Melee): Third punch +0.15 x base, fourth +0.3, fifth and later +0.45 (a big moment) | RSQ Melee |
| Kill with an uppercut | **Shoryuken** (Melee): +0.3 x base | RSQ Melee |
| Kill with a punch below the chest | **Liver Shot** (Melee): +0.2 x base | RSQ Melee |
| Kill with a punch in the top fifth of the body | **Glass Jaw** (Melee): +0.25 x base | RSQ Melee |
| Jab, jab, hook inside 1 s; the hook kills | **Textbook** (Melee): +0.35 x base | RSQ Melee |
| Jab, hook, uppercut inside 1 s; the uppercut kills | **Triple Threat** (Melee): +0.5 x base. Replaces Shoryuken and Textbook. A big moment | RSQ Melee |
| Kill with the third or later of alternating hooks | **Dempsey Roll** (Melee): +0.15 x base for each hook past two, at most +0.6 | RSQ Melee |
| Punch dead a monster your uppercut launched, while it is in the air | **Air Combo** (Melee): +0.3 x base. Replaces Juggle and Skeet | RSQ Melee |
| Kill with the Clear Out | **Bouncer** (Melee): +0.3 x base | RSQ Melee |
| Kill with the Guard's release | **Release** (Melee): +0.4 x base | RSQ Melee |
| Throw a monster out of the Headlock; its own landing kills it | **Toss** (Melee): +0.35 x base | RSQ Melee |
| Kill with the Headlock Slam | **Piledriver** (Melee): +0.5 x base. A big moment | RSQ Melee |
| Kill with the Headlock Uppercut | **Cut Loose** (Melee): +0.4 x base | RSQ Melee |
| Kill with the gun-butt shove | **Butt Stroke** (Melee): +0.3 x base | RSQ Melee |
| Knock a monster's missile aside by hand (RSQ Melee answers `returned.by` 3); it kills something | **Swatted** (Counterplay): +0.5 x base. Replaces Return to Sender | RSQ Melee |
| Soak a monster's blow on your Guard, then kill it within 3 s | **Rope-a-Dope** (Counterplay): +0.4 x base; +0.6 when the kill is a melee blow | RSQ Melee |
| Kill two or more with one Ground Pound | **Seismic** (Melee): +0.3 x base for each kill before this one, at most +0.9. Replaces Multi-Kill. A big moment from the third | RSQ Melee |
| Kill two or more with one Clear Out | **Out of My Way** (Melee): +0.3 x base for each kill before this one, at most +0.9. Replaces Multi-Kill. A big moment from the third | RSQ Melee |
| Kill two or more with one Guard release | **Full Release** (Counterplay): +0.3 x base for each kill before this one, at most +0.9. Replaces Multi-Kill. A big moment from the third | RSQ Melee |
| Hold a monster in the Headlock while something else kills it | **Meat Shield** (Counterplay): The kill is yours: +0.6 x base. Replaces Ring Out | RSQ Melee |
| Kill another monster while your off hand holds one as a Human Shield | **Human Shield** (Daring): +0.3 x base | RSQ Melee |
| Kick a barrel with an uppercut; its blast kills | **Field Goal** (Melee): +0.5 x base | RSQ Melee |
| Land a Heavy Hands punch, then kill that monster within 1 s | **Seeing Stars** (Melee): +0.3 x base | RSQ Melee |
| Launch a monster with an uppercut so that it comes down on another and kills it | **Meteor** (Melee): +0.4 x base | RSQ Melee |
| Kill with a Star Punch | **Star Punch** (Melee): +0.5 x base. A big moment | RSQ Melee |
| Knock a monster down with the Rifle Butt shove, then kill it inside the chain's 3 s | **Down for the Count** (Melee): +0.35 x base | RSQ Melee |
| Kill with a glove while Slappers Only is on | **Bare Knuckle** (Daring): +0.15 x base | RSQ Melee, its Slappers Only on |
| Kill with a shotgun in your F.E.A.R. window a monster you did not shove | **Red Mist** (Style): +0.35 x base | RSQ Melee |
| Knock a monster into a wall so that the wall kills it (a punch, or the shield's slam) | **Wall Splat** (Melee): +0.4 x base. A big moment on a monster of 400 health or more | RSQ Melee or RSQ ShieldSaw |
| Throw a monster out of the Headlock so that it strikes and kills another | **Bowling** (Style): +0.5 x base. A big moment. (A body thrown by a hook that answers `struck` gives +0.25 more for each body past the first, at most +1.25.) | RSQ Melee |
| Choke a monster to death with the Force grip, or with the Headlock's Chokehold | **Choked** (Melee): +0.3 x base. Replaces Juggle | RSQ Saber or RSQ Melee |
| Fling a body out of the Force grip so that it dies hitting something | **Slammed** (Melee): +0.5 x base. Replaces Juggle. A big moment | RSQ Saber |
| Force pull a monster, then kill it with a melee blow within 2 s | **Pulled In** (Melee): +0.3 x base | RSQ Saber |
| Kill with a saber cut or throw while a saber is lit in each hand | **Twin Blades** (Melee): +0.2 x base | RSQ Saber |
| Kill with the Force jump's landing, or with RSQ Melee's two-fist pound | **Ground Pound** (Melee): +0.3 x base. Replaces Slammed | RSQ Saber or RSQ Melee |
| Kill with a lunging stab | **Lunge** (Melee): +0.4 x base | RSQ Saber |
| Kill by drawing the blade out of an impaled monster | **Impaled** (Melee): +0.5 x base. A big moment | RSQ Saber |
| Turn a shot with crossed blades; it kills | **Back Off** (Counterplay): +0.5 x base. Replaces Return to Sender | RSQ Saber |
| Throw both sabers; each kills within 1 s of the other | **Double Throw** (Melee): +0.4 x base on the second | RSQ Saber |
| Kill with a stab | **Run Through** (Melee): +0.25 x base | RSQ Saber |
| Kill with a blow the ledger knows as saber.spin | **Saberstaff** (Melee): +0.3 x base | A mod that sends "saber.spin" (none in this repo does) |
| Kill with Force Lightning | **Unlimited Power** (Melee): +0.35 x base | RSQ Saber |
| Kill a monster whose chain carries the tag "clash" | **Clash Break** (Melee): +0.35 x base | A tag "clash" (RSQ Saber sends "clash", which Score files as a tool, not a tag) |
| Knock a bolt back into RSQ Saber's training remote | **Deflect** (Melee): The points RSQ Saber sends, on the Deflect row | RSQ Saber |
| Knock RSQ Saber's training remote out of the air | **Remote Down** (Melee): The points RSQ Saber sends, on the Remote Down row | RSQ Saber |
| Kill with the thrown ShieldSaw disc or a thrown saber | **Hurled** (Melee): +0.3 x base, +0.15 for each kill the same throw already made, at most +0.75 | RSQ ShieldSaw or RSQ Saber |
| Kill with the shield in the off hand: its bash, or its grind | **Shield Work** (Melee): Bash +0.3 x base, grind +0.2 | RSQ ShieldSaw |
| Block a monster's attack with the shield or the saber, then kill it within 3 s | **Riposte** (Counterplay): +0.4 x base | RSQ ShieldSaw or RSQ Saber |
| Make a perfect block, then kill that monster within 3 s | **Perfect Riposte** (Counterplay): +0.7 x base. Replaces Riposte. A big moment | RSQ ShieldSaw or RSQ Saber |
| Kill with a shot you sent back | **Return to Sender** (Counterplay): +0.4 x base; a Hadouken or Swat Back +0.6, the Guard's reflect +0.5, the whip's return +0.55 | RSQ ShieldSaw, RSQ Saber or RSQ Melee |
| Kill a monster with its own shot, sent back | **Poetic Justice** (Counterplay): +0.3 x base on top of Return to Sender. A big moment | RSQ ShieldSaw, RSQ Saber or RSQ Melee |
| Kill with shots sent back one after another, each within 3 s | **Rally** (Counterplay): Second +0.2 x base, third +0.4, then +0.6 (a big moment) | RSQ ShieldSaw, RSQ Saber or RSQ Melee |
| Kill with a shot sent back a monster that did not fire it | **Misdirection** (Counterplay): +0.25 x base | RSQ ShieldSaw, RSQ Saber or RSQ Melee |
| Kill on a throw's way home after the same throw killed on its way out | **Boomerang** (Melee): +0.5 x base. A big moment | RSQ ShieldSaw or RSQ Saber |
| Kill on a throw's way home when it did not kill on its way out | **Homecoming** (Melee): +0.3 x base | RSQ ShieldSaw or RSQ Saber |
| Kill while your thrown saber or disc is still in flight (and is not what killed) | **Juggler** (Style): +0.25 x base | RSQ Saber or RSQ ShieldSaw |
| Stick the disc in a monster and let it grind it dead | **Ground Down** (Melee): +0.3 x base | RSQ ShieldSaw |
| Throw the disc at two or more locks; it kills the last one standing | **Clean Sweep** (Melee): +0.5 x base. A big moment | RSQ ShieldSaw |
| Kill a monster the disc locked after the throw (at a wall) | **Bank Shot** (Melee): +0.4 x base. A big moment | RSQ ShieldSaw |
| Kill while the shield in your off hand blocked another monster within 2048 units in the last 1 s | **Shield Wall** (Counterplay): +0.25 x base | RSQ ShieldSaw |
| Kill while the shield blocked two or more other monsters in the last 2 s | **Hold the Line** (Counterplay): +0.25 x base, +0.1 for each monster past two, at most +0.55. Replaces Shield Wall | RSQ ShieldSaw |
| Kill with the bash that ends a Shield Dash | **Shield Dash** (Melee): +0.4 x base | RSQ ShieldSaw |
| Grind dead a monster that was clawing your revving shield | **Bit Off More** (Melee): +0.5 x base | RSQ ShieldSaw |
| Let the shield on your back block a monster, then kill it inside the chain's 3 s | **Eyes in the Back** (Counterplay): +0.5 x base | RSQ ShieldSaw |
| Gib a monster with the disc on a kill tagged cleave.saw | **Cleaver** (Melee): +0.2 x base on top of Cleaved | RSQ ShieldSaw |
| Grind a monster dead after 52 tics (1.5 s) or more of grinding | **Buzzsaw** (Melee): +0.3 x base. Replaces Shield Work | RSQ ShieldSaw |
| Kill with the whip (a blow of damage type Whip from you) | **Lashed** (Melee): +0.25 x base. With a whip that answers `crack.k` it is +0.2 for a light crack and +0.35 for a heavy one (50 or more) instead | RSQ Whip (it answers no `crack.k` at this commit) |
| Kill with a thing you threw with Distance Grab | **Thrown** (Style): +0.2 x base, +0.03 for each m/s over 3, at most +0.5 | RSQ Distance Grab |
| Kill with the blast of a barrel your throw set off | **Powder Keg** (Style): +0.3 x base, +0.2 for each more within 1 s, at most +1.1. A big moment from the third | RSQ Distance Grab |
| Catch a thrown thing back out of the air, throw it again, and kill with it | **Air Catch** (Daring): +1.0 x base, +0.5 for each more catch, at most +2.0. A big moment | RSQ Distance Grab |
| Kill with a shot while a hand carries something with Distance Grab | **Full Hands** (Style): +0.25 x base | RSQ Distance Grab |
| Kill with a corpse you threw | **Body Blow** (Style): +0.3 x base on top of Thrown | RSQ Distance Grab |
| Kill with a thrown weapon that a dying monster dropped | **Hand-Me-Down** (Style): +0.3 x base on top of Thrown | RSQ Distance Grab |
| Kill with a thrown thing of 100 kg or more | **Heavy Throw** (Style): +0.15 x base on top of Thrown | RSQ Distance Grab |
| Swing a thing you hold into a monster and kill it | **Clubbed** (Melee): +0.3 x base; +0.4 with a corpse | RSQ Distance Grab |
| Kill with a gun you threw | **Throwaway** (Style): +0.3 x base; +0.5 on a throw tagged empty | RSQ Tactical Rig or RSQ Distance Grab |
| Draw a gun from a holster and kill with a shot of it within 42 tics | **Quick Draw** (Daring): +0.35 x base | RSQ Tactical Rig |
| Kill, draw a different gun from a holster within 3 s, and kill with it within 3 s of the draw | **Hot Swap** (Daring): +0.25 x base | RSQ Tactical Rig |
| Draw the saber from a holster and kill with a saber blow within 42 tics | **Iaido** (Daring): +0.45 x base | RSQ Tactical Rig and RSQ Saber |
| Draw a grenade from the rig and kill with a grenade within 3 s | **Pin Pulled** (Daring): +0.3 x base | RSQ Tactical Rig and a grenade |
| Kill with three different guns, each just drawn from a holster, inside 6 s | **Armory** (Daring): +0.5 x base on the third | RSQ Tactical Rig |
| Kill with a grenade cooked 1 s or more in the hand | **Cooked** (Daring): +0.2 x base, +0.1 for each further 17 tics, at most +0.6 | RSQ Grenade |
| Kill with a grenade that goes off 24 units or more above the floor (not in your hand) | **Airburst** (Style): +0.35 x base | RSQ Grenade or BD22 VR's hand grenade |
| Stick a Sticky grenade on a monster; its blast kills that monster | **Tagged** (Style): +0.35 x base | RSQ Grenade |
| Kill with a grenade that goes off in your hand | **Hold My Beer** (Daring): +0.5 x base; +0.8 if you are alive. A big moment | RSQ Grenade |
| Kill with a Cluster bomblet | **Cluster Bomb** (Style): +0.25 x base | RSQ Grenade |
| Turn a monster with an Infight or Charm grenade; it kills another | **Civil War** (Efficiency): The kill is yours: +0.4 x base | RSQ Grenade |
| Kill a monster your Flash or Smoke grenade touched inside the chain's 3 s | **Blindside** (Style): +0.3 x base | RSQ Grenade |
| Kill with your Incendiary's fire | **Barbecue** (Style): +0.25 x base | RSQ Grenade |
| Kill with your own grenade, shot in the air | **Trap Shot** (Style): +0.6 x base. A big moment | RSQ Grenade |
| Kill with a grenade whose pin you pulled with your teeth | **Teeth** (Style): +0.15 x base | RSQ Grenade |
| Kill with an Impact grenade's burst | **Contact** (Style): +0.4 x base | RSQ Grenade |
| Kill while RSQ SlowMo has the world slowed | **Stretched Second** (Style): Half (Style Share, 50%) of what the kill's Style, Daring, Melee and Counterplay bonuses gave, again; x1.5 at 10% speed or slower; half of that for an automatic slow motion; nothing during Score's own pulse | RSQ SlowMo |
| Kill while the world speeds back up at the end of a slow motion | **Last Grain** (Style): +0.2 x base | RSQ SlowMo |
| (RSQ SlowMo's award "Revenge") | **Revenge** (Daring): 1 x the base of your kill on that tic, on the Revenge row (100 points if no kill comes by the next tic) | RSQ SlowMo |
| (another mod's award "Revive") | **Revive** (Daring): 3 x the base of your last Revenge kill, on the Revive row (300 points with none) | A mod that sends it (RSQ SlowMo does not at this commit) |
| Kill the Boss you called in | **Boss** (Daring): RSQ Miniboss's award "Miniboss Called": 3 x the Boss kill's base on the Boss row (its 1500 points if no kill comes by the next tic) | RSQ Miniboss |
| (RSQ Miniboss's award "Finisher") | **Finisher** (Melee): The points RSQ Miniboss sends, on the Finisher row | RSQ Miniboss |
| (another mod's award "Thrall Slow Kill") | **Thrall Slow Kill** (Daring): 0.3 x the base of your kill on that tic, on that row | A mod that sends it (RSQ Miniboss does not at this commit) |
| Score anything while RSQ Miniboss's Rank is above 0 | **Rank** (Daring): Every payment gets more, in a straight line up to x2 at Rank 100 (Top Rank Multiplier); the extra is on the Rank row | RSQ Miniboss |
| Kill thralls one after another while RSQ Miniboss answers "window" above 0 | **Chain Gang** (Daring): Second +0.4 x base, third +0.8, then +1.0 (a big moment) | RSQ Miniboss (its "window" answers 0 at this commit) |
| Kill the Boss while RSQ Miniboss answers "enraged" 1 | **Rage Quit** (Daring): +0.75 x base. A big moment | RSQ Miniboss (its "enraged" answers 0 at this commit) |
| Kill a monster that carries RSQ Miniboss's RSQMB_Rage | **Riot Control** (Daring): +0.15 x base | RSQ Miniboss |
| Kill a Dark Red champion | **Dark Red Champion** (Daring): +0.25 x base | Champions |
| Kill a Red champion | **Red Champion** (Daring): +0.25 x base | Champions |
| Kill an Orange champion | **Orange Champion** (Daring): +0.25 x base | Champions |
| Kill a Yellow champion | **Yellow Champion** (Daring): +0.25 x base | Champions |
| Kill a Dark Green champion | **Dark Green Champion** (Daring): +0.25 x base | Champions |
| Kill a Green champion | **Green Champion** (Daring): +0.25 x base | Champions |
| Kill a Cyan champion | **Cyan Champion** (Daring): +0.25 x base | Champions |
| Kill a Blue champion | **Blue Champion** (Daring): +0.25 x base | Champions |
| Kill an Indigo champion | **Indigo Champion** (Daring): +0.25 x base. Its clones give nothing | Champions |
| Kill a Violet champion | **Violet Champion** (Daring): +0.25 x base | Champions |
| Kill a Pink champion | **Pink Champion** (Daring): +0.25 x base | Champions |
| Kill a Black champion | **Black Champion** (Daring): +0.25 x base | Champions |
| Kill a Grey champion | **Grey Champion** (Daring): +0.25 x base | Champions |
| Kill a White champion | **White Champion** (Daring): +0.25 x base | Champions |
| Kill a Bronze champion | **Bronze Champion** (Daring): +0.5 x base | Champions |
| Kill a Silver champion | **Silver Champion** (Daring): +0.5 x base | Champions |
| Kill a Gold champion | **Gold Champion** (Daring): +0.75 x base | Champions |
| Kill a Titan champion | **Titan** (Daring): +0.5 x base. A big moment | Champions |
| Kill an Undying champion after its heart | **Undying** (Daring): +0.5 x base | Champions |
| Kill a Ghost champion | **Ghost** (Daring): +0.25 x base | Champions |
| Kill a Balloon champion | **Balloon** (Daring): +0.25 x base | Champions |
| Kill a champion with two colours | **Hybrid** (Daring): Hybrid +0.25 x base; of its two colour rows only the higher is given | Champions |
| Kill a Bronze champion with a melee blow | **Immovable Object** (Daring): +0.4 x base | Champions |
| Kill a Balloon champion with anything but a shot | **Pop!** (Daring): +0.3 x base | Champions |
| Gib a champion | **Pinata** (Daring): +0.25 x base | Champions |
| Kill champions one after another, each within 5 s | **Champion Streak** (Daring): +0.1 x base for each one before, at most +0.5 | Champions |
| Kill an Orange champion with a melee blow or within 64 units | **Too Close for Comfort** (Daring): +0.35 x base | Champions |
| Kill a Black champion in one blow from full health | **Glass Cannon** (Daring): +0.35 x base | Champions |
| Kill a monster that carries a Gold champion's token and is no champion itself | **Fool's Gold** (Daring): +0.2 x base | Champions |
| Kill an Undying champion within 2 s of its heart | **Heartbreaker** (Daring): +0.35 x base | Champions |
| Kill a champion with a blow of type Fatality | **Champion Fatality** (Melee): +0.25 x base on top of Fatality | Champions and Brutal Doom |
| Kill champions of 5, 10 and all 14 colours in one map | **Rainbow** (Daring): +0.5 x base at 5 colours, +1.0 at 10, +2.0 at 14, once each. A big moment from 10 | Champions |
| Kill a LegenDoom legendary after it has risen | **Legendary** (Daring): +1.5 x base. A big moment | LegenDoom |
| Kill a legendary before it rises | **Legend Denied** (Daring): +0.75 x base | LegenDoom |
| Kill a risen legendary whose champion powers are on | **Legendary Champion** (Daring): +0.5 x base in place of Legendary. A big moment | LegenDoom and Champions |
| Kill a legendary in one blow from 3 x its spawn health | **One-Tap Legend** (Daring): +1.0 x base. Replaces Legend Denied. A big moment | LegenDoom |
| Kill a risen legendary within 2 s of the first blow Score sees on it after it rose | **Strike While It Rises** (Daring): +0.5 x base | LegenDoom |
| Kill two legendaries within 10 s | **Legend Slayer** (Daring): +0.5 x base on the second | LegenDoom |
| Kill a Green tier monster | **Green Tier** (Daring): +0.1 x base | RSQ Monsters; Green Tier: On (default) |
| Kill a Blue tier monster | **Blue Tier** (Daring): +0.15 x base | RSQ Monsters; Blue Tier: On (default) |
| Kill a Cyan tier monster | **Cyan Tier** (Daring): +0.2 x base | RSQ Monsters; Cyan Tier: On (default) |
| Kill a Purple tier monster | **Purple Tier** (Daring): +0.25 x base | RSQ Monsters; Purple Tier: On (default) |
| Kill a Yellow tier monster | **Yellow Tier** (Daring): +0.25 x base | RSQ Monsters; Yellow Tier: On (default) |
| Kill a FireBlu tier monster | **FireBlu Tier** (Daring): +0.3 x base | RSQ Monsters; FireBlu Tier: On (default) |
| Kill an Abyss tier monster | **Abyss Tier** (Daring): +0.3 x base | RSQ Monsters; Abyss Tier: On (default) |
| Kill a Brown tier monster | **Brown Tier** (Daring): +0.35 x base | RSQ Monsters; Brown Tier: On (default) |
| Kill a Gray tier monster | **Gray Tier** (Daring): +0.35 x base | RSQ Monsters; Gray Tier: On (default) |
| Kill a Red tier monster | **Red Tier** (Daring): +0.4 x base | RSQ Monsters; Red Tier: On (default) |
| Kill a Black Boss | **Black Boss** (Daring): +0.75 x base. A big moment | RSQ Monsters; Black Boss: On (default) |
| Kill a White Boss | **White Boss** (Daring): +1.0 x base. A big moment | RSQ Monsters; White Boss: On (default) |
| Kill an EX boss | **EX Boss** (Daring): +0.5 x base on top of its tier's row. A big moment | RSQ Monsters; EX Boss: On (default) |
| Kill a monster whose spawn roll was 1 in 20 or rarer | **Rarity** (Daring): +0.1 x base for each doubling past 1 in 10, at most +1.0. A big moment from +0.5 | RSQ Monsters; Rarity: On (default) |
| Kill all 13 tiers yourself in one map | **Full Spectrum** (Daring): +2.0 x base on the kill that completes it, once. A big moment | RSQ Monsters; Full Spectrum: On (default) |
| Kill the same tier (not Common) three or more times in a row | **Colour Chain** (Style): +0.15 x base for each kill past two, at most +0.75 | RSQ Monsters; Colour Chain: On (default) |
| Kill a monster while it flashes, about to move up a tier | **Keep the Change** (Efficiency): +0.3 x base; +0.5 if it was becoming a Black or White Boss | RSQ Monsters; Keep the Change: On (default) |
| Kill a monster within 3 s of it moving up a tier | **Fresh Paint** (Style): +0.25 x base | RSQ Monsters; Fresh Paint: On (default) |
| Let a Common, Green or Blue monster kill a Black Boss, a White Boss or an EX | **Upset** (Efficiency): Every player (or you, if your grenade turned the killer) gets +0.75 x base. A big moment | RSQ Monsters; Upset: On (default) |
| Kill a Black Boss, a White Boss or an EX with a pistol, a punch, a glove, a kick or the shove | **Tier Slayer** (Daring): +0.5 x base. A big moment | RSQ Monsters; Tier Slayer: On (default) |
| Kill while a latched rope holds you off the ground | **Swinging / Hanging Shot** (Daring): Swinging +0.35 x base; under 2 units a tic the row is Hanging Shot, +0.15. Replaces Air | A rope that answers `swinging` 1 (RSQ Whip and RSQ Grapple are both asked; neither does at this commit) |
| Let go of a swing at 6 units a tic or more, then kill within 3 s in the air or 1 s after landing | **Dismount** (Daring): +0.4 x base. Replaces Air | A rope that answers `released` (RSQ Whip and RSQ Grapple are both asked; neither does at this commit) |
| Kill on the second or later of whip swings latched one after another | **Chain Swing** (Daring): +0.2 x base for each swing past the first, at most +0.8 | RSQ Whip's `swinging` and `swings` (both answer 0 at this commit) |
| Swing a monster on the whip into another; the smash kills it | **Wrecking Ball** (Melee): +0.4 x base | A whip blow whose inflictor is a monster (RSQ Whip has no such move at this commit) |
| Swing in on the rope; your arrival kills | **Tarzan** (Melee): +0.5 x base. Replaces Swinging. A big moment | A mod that sends "tarzan" (none in this repo does at this commit) |
| Stun a monster with a whip crack (tag crack.stun), then kill it with another tool | **Stun Lock** (Melee): +0.3 x base | A mod that sends "crack.stun" (none in this repo does at this commit) |
| Yank a heavy monster with the whip (tag yank.heavy); it dies within 2 s | **Heavy Haul** (Melee): +0.35 x base | RSQ Whip's `yanked` and a tag "yank.heavy" (neither at this commit) |
| Kill with a marked whip crack (tag crack.marked) from 204 units (6 m) or more | **Snap Kill** (Melee): +0.3 x base | A mod that sends "crack.marked" (none in this repo does at this commit) |
| Hook a monster, then kill it with a melee blow within 2 s | **Reeled In** (Melee): +0.3 x base, +0.15 for each one inside 4 s of the last, at most +0.75. Replaces Pulled In | RSQ Grapple's "hooked" and "hooked.by" |
| Hook a monster, send it flying, hook it again, then kill it | **Ping-Pong** (Style): +0.4 x base, +0.2 a volley, at most +1.0 | RSQ Grapple's "hooked", "hooked.by" and "volleys" |
| Let the hook's throw itself kill the monster | **Hard Landing** (Style): +0.3 x base | RSQ Grapple's "landing" |
| Kill a monster while your hook is throwing it | **Fly Ball** (Style): +0.35 x base. Replaces Skeet and Juggle | RSQ Grapple's "yanked" and "hooked.by" |
| Kill with the blast of a barrel your hook bit | **Hooked Keg** (Style): +0.4 x base, +0.2 for each more within 3 s, at most +1.2 | RSQ Grapple's "hooked" and "hooked.by" |
| Reel yourself to a monster too heavy to pull, then kill it in melee within 2 s | **Boarding Party** (Daring): +0.6 x base. Replaces Reeled In | RSQ Grapple's "hooked", "hooked.by" and "hooked.heavy" |
| Kill with a blow the ledger knows as hook.zip | **Zip Kick** (Melee): +0.35 x base | A mod that sends "zip.kick" or "hook.zip" (none in this repo does) |
| Kill with a fist on a blow tagged scorpion | **Scorpion** (Melee): +0.3 x base. Replaces Counter | A mod that sends "scorpion" (none in this repo does) |
| (another mod's award) | **Indiana Jones** (Daring): The points sent with the label "Indiana Jones", on that row | A mod that sends it (none in this repo does) |
| Kill with a fist on a blow tagged fist.finisher | **K.O.** (Melee): +0.5 x base. A big moment | A mod that sends "finisher" or "fist.finisher" (none in this repo does) |
| Kill on a blow tagged shatter | **Shatter** (Melee): +0.4 x base | A mod that sends "shatter" (none in this repo does) |
| Kill on a blow tagged arc | **Live Wire** (Melee): +0.3 x base | A mod that sends "arc" (none in this repo does) |
| Kill on a blow tagged fist.explosive | **Blast Radius** (Melee): +0.25 x base | A mod that sends "fist.explosive" (none in this repo does) |
| Kill on a blow tagged shatter a monster your Freeze grenade touched | **Ice Breaker** (Style): +0.5 x base. Replaces Shatter | RSQ Grenade and a mod that sends "shatter" (none in this repo does) |
| Kill a monster of 400 spawn health or more, or make a big-moment kill | The world stops for a beat first: a pulse of 115 ms plus RSQ SlowMo's own ramp, at 5 in 100 of full speed, no more than once a second and not while the world is already slowed | Hit Stop: On (default Off); RSQ SlowMo |
| In VR, look at your off hand | The total in small gold digits 5 cm above the off hand controller; hidden while a menu is open, and while RSQ Saber's training remote is out | Wrist Score: On (default Off); Show Score: On |
| Fill the reward bar | 20 s of ammo coming back: in all, 40 in 100 of each ammo type's maximum. With Ammo First or Life First the two rewards take turns | Reward: Ammo Only, Ammo First or Life First (default Life Only); Ammo Refill (%) (default 40) |
| Fill the reward bar | Nothing, and no bar is drawn | Reward: None (default Life Only) |
| Finish a map and start the next | Total: the total is kept. Plus Rewards: the total and your lives are kept. Everything: the bar's fill is kept too, as the same share of the new map's bar | New Map Keeps: Total, Plus Rewards or Everything (default Nothing) |
| Take a killing hit while you hold a life | The same revival without the ring of fire | Revival Fire: Off (default On) |
| Fill the reward bar, or take a killing hit while you hold a life | The whole view is tinted for a moment as well | Reward Tint: On or Revival Tint: On (default Off); Screen Flash: On (default) |
| Shoot a monster in the head | No extra damage. The Headshot row is still given | Head Shots: Off (default On) |
| Fire a gun | No critical shots | Critical Hits: Off (default On) |
| Kill anything | Points still count, but no score line, bar, faces or rows are drawn (the same with the engine's HUD size at 12) | Show Score: Off (default On) |
| Kill anything | No bonus rows are drawn under the bar | Bonus Time: 0 (default 35) |
| Kill a roster monster | The row whose switch is Off gives nothing | Any row under Roster Tiers or Roster Bonuses: Off (default On) |
| Kill with many bonuses of one family | That family's bonuses are scaled down to its cap | Efficiency, Style, Daring, Melee or Counterplay Cap above 0 (default 0: no cap) |

<details><summary>The 242 named combos (one row each)</summary>

A named combo is a row of the Combo Chain. Hit one monster with the steps in order, no more than 3 s apart; the last step must be the killing blow, and other moves may come between the steps. Only the best match is given on a kill. The steps are the code's own words: a tool (`saber.cut`, `gun.shotgun`), the start of one (`whip`, `grenade`, `hook`, `gun`), or a group (`hands`: a punch, kick or glove; `melee`: any melee blow; `block`, `parry`, `return`, `throw`, `any`). `@slow` means the step landed in slow motion you started yourself; `+air` the monster was off the floor; `+pb` within 64 units; `+head` a head shot. A word after `|` names what the monster must be (`champ`, `armoured`, `legend.dormant`, `miniboss`, `Ghost`).

| Combo | Steps, in order | Bonus |
|---|---|---|
| Lion Tamer | `whip > shield.bash` | +0.5 x base |
| Clay Pigeon | `force.push > gun` | +0.5 x base |
| Sitting Duck | `force.grip > gun` | +0.5 x base |
| Pull! | `force.pull > gun` | +0.5 x base |
| Disc Jockey | `force.push > shield.disc` | +0.5 x base |
| Gun Kata | `hands > gun` | +0.4 x base |
| Fast Hands | `melee > rig.draw` | +0.5 x base |
| Lasso | `whip > hook.yank` | +0.5 x base |
| Pitch and Slice | `grab.throw > saber.cut` | +0.5 x base |
| Circus Act | `whip > hook.yank > gun` | +0.9 x base |
| Yo-Yo | `force.pull > force.push > gun` | +0.9 x base |
| Discus | `shield.bash > force.push > shield.disc` | +0.9 x base |
| Headlock | `grab.hold > hands` | +0.5 x base |
| F.E.A.R. Effect | `shove > gun.shotgun@slow` | +0.6 x base |
| Trap Shooter | `glove.upper > gun.shotgun` | +0.5 x base |
| Rising Dragon | `glove.upper > saber.cut` | +0.5 x base |
| Spike | `glove.upper > shield.disc` | +0.5 x base |
| Catch of the Day | `glove.upper > hook.yank` | +0.6 x base |
| Air Lash | `glove.upper > whip.crack` | +0.5 x base |
| Alley-Oop | `glove.upper > grab.throw` | +0.5 x base |
| Air Mail | `glove.upper > grenade` | +0.5 x base |
| Fireworks | `glove.upper > gun.explosive` | +0.5 x base |
| One-Two-Skeet | `glove > glove.upper > gun.shotgun` | +0.9 x base |
| Cross Cut | `glove.hook > saber.cut` | +0.4 x base |
| Fist and Shield | `glove > shield.bash` | +0.4 x base |
| Knuckle Crack | `glove > whip.crack` | +0.4 x base |
| Jedi Jab | `glove > force.push` | +0.4 x base |
| Punch and Pitch | `glove > shield.disc` | +0.4 x base |
| Slow Trap Shooter | `glove.upper@slow > gun.shotgun` | +0.55 x base |
| Feint | `glove.jab > saber.stab` | +0.45 x base |
| Skyskewer | `glove.upper > saber.stab` | +0.55 x base |
| Pistol Whip | `shove > gun.pistol` | +0.5 x base |
| Executioner | `shove > gun+head` | +0.6 x base |
| Riot Shield | `shove > shield.bash` | +0.5 x base |
| Make Room | `shove > saber.cut` | +0.4 x base |
| Fire in the Hole | `shove > grenade` | +0.45 x base |
| Backlash | `shove > whip.crack` | +0.4 x base |
| Street Fighter | `hadouken > glove.upper` | +0.6 x base |
| Shoto | `hadouken > saber.cut` | +0.5 x base |
| Return Fire | `hadouken > shove > gun.shotgun` | +1 x base |
| Neo | `hadouken@slow > glove` | +0.6 x base |
| Backhand Spring | `swat > glove.upper > gun.pistol` | +1 x base |
| Parry Punish | `guard.parry > any` | +0.5 x base |
| Counter Cut | `guard.parry > saber` | +0.6 x base |
| Knuckle Sandwich | `guard.parry > glove` | +0.55 x base |
| Dragon Fist | `guard.parry > glove.upper > glove` | +0.9 x base |
| Pressure Valve | `guard.release > glove` | +0.5 x base |
| Hostage | `grab.hold > gun.pistol` | +0.5 x base |
| Close Quarters | `grab.hold > gun.shotgun` | +0.5 x base |
| Hold This | `grab.hold > grenade` | +0.6 x base |
| Execution | `grab.hold > saber` | +0.5 x base |
| Suplex | `grab.hold > headlock.throw` | +0.5 x base |
| Flog | `grab.hold > whip.crack` | +0.5 x base |
| Title Belt | `grab.hold > hands \| champ` | +0.6 x base |
| Bouncer | `grab.hold > hands > gun.shotgun` | +0.9 x base |
| Choke and Cut | `grab.hold > headlock.choke > saber.cut` | +0.9 x base |
| Slam and Blam | `grab.hold > headlock.slam > gun.shotgun` | +0.9 x base |
| Clay Toss | `headlock.throw > gun.shotgun` | +0.5 x base |
| Ground and Pound | `headlock.slam > glove` | +0.5 x base |
| Pin Down | `headlock.slam > saber.stab` | +0.55 x base |
| Come Get Some | `taunt > hands` | +0.4 x base |
| Come Closer | `taunt > gun.shotgun` | +0.5 x base |
| Tremor | `pound > gun.shotgun` | +0.45 x base |
| Quake | `pound > shield.bash` | +0.4 x base |
| Get Back! | `clearout > grenade` | +0.5 x base |
| Spread Out | `clearout > gun.explosive` | +0.45 x base |
| Laser Sword | `saber.cut > gun.energy` | +0.5 x base |
| Blade and Buckshot | `saber.cut > gun.shotgun` | +0.45 x base |
| Edge and Board | `saber.cut > shield.bash` | +0.4 x base |
| Pommel | `saber.cut > glove` | +0.4 x base |
| Slash and Blast | `saber.cut > force.push > gun.shotgun` | +0.9 x base |
| Distraction | `saber.throw > glove` | +0.5 x base |
| Covering Fire | `saber.throw > gun.rifle` | +0.45 x base |
| Air Traffic | `saber.throw > shield.disc` | +0.5 x base |
| Throw and Go | `saber.throw > saber.cut` | +0.4 x base |
| Return Flight | `saber.throw > force.pull > saber.cut` | +0.9 x base |
| Helpless | `force.grip > saber.cut` | +0.5 x base |
| Hung Out to Dry | `force.grip > glove` | +0.5 x base |
| Special Delivery | `force.grip > grenade` | +0.5 x base |
| Pinned | `force.grip > shield.disc` | +0.5 x base |
| Strung Up | `force.grip > whip.crack` | +0.5 x base |
| Exorcism | `force.grip > saber.cut \| Ghost` | +0.6 x base |
| Jedi Brawler | `force.grip > glove > saber.cut` | +0.9 x base |
| Superhero Landing | `force.jump > glove` | +0.5 x base |
| Leap Strike | `force.jump > saber.cut` | +0.5 x base |
| Come Here, Go Up | `force.pull > glove.upper > gun.shotgun` | +0.9 x base |
| Force Arrest | `force.pull > grab.hold > glove` | +0.9 x base |
| Jedi Hoplite | `force.pull > shield.bash > saber.cut` | +0.9 x base |
| Clay Saber | `force.push > saber.throw` | +0.5 x base |
| Slingshot | `force.push > hook.yank` | +0.5 x base |
| Hot Seat | `force.push > grab.keg` | +0.5 x base |
| Scoundrel | `force.push > saber.throw > gun.pistol` | +0.9 x base |
| Push-Pull | `force.push > force.pull > saber.cut` | +0.9 x base |
| Time Slash | `force.push@slow > saber.cut` | +0.55 x base |
| Off the Blade | `saber.stab > force.push` | +0.5 x base |
| Stab and Jab | `saber.stab > glove` | +0.4 x base |
| Shock and Awe | `force.lightning > glove` | +0.5 x base |
| Sith Ambush | `force.lightning > saber.cut` | +0.5 x base |
| Overcharge | `force.lightning > gun.energy` | +0.5 x base |
| Riot Control | `shield.bash > gun.shotgun` | +0.5 x base |
| Bash and Slash | `shield.bash > saber.cut` | +0.5 x base |
| Spring Back | `shield.bash > hook.yank` | +0.45 x base |
| Bash and Lash | `shield.bash > whip.crack` | +0.4 x base |
| Shield and Fist | `shield.bash > glove` | +0.4 x base |
| Crack the Shell | `shield.bash > blade \| armoured` | +0.55 x base |
| Bash and Launch | `shield.bash > glove.upper > gun.shotgun` | +0.9 x base |
| Shield Up | `shield.block > grenade` | +0.5 x base |
| This Is Sparta | `shield.block > shield.bash > saber` | +0.9 x base |
| Riot Squad | `shield.block > shield.bash > gun.shotgun` | +0.9 x base |
| Shield Uppercut | `shield.block > shield.bash > glove.upper` | +1 x base |
| Slow Sparta | `shield.block@slow > shield.bash > saber.cut` | +1 x base |
| Blitz | `shield.dash > glove.upper` | +0.5 x base |
| Door Kicker | `shield.dash > gun.shotgun` | +0.5 x base |
| Spartan Charge | `shield.dash > saber` | +0.5 x base |
| Saw and Saber | `shield.disc > saber.cut` | +0.5 x base |
| Crossfire | `shield.disc > saber.throw` | +0.5 x base |
| Follow-Through | `shield.disc > glove` | +0.4 x base |
| Throw and Follow | `shield.disc > shield.bash` | +0.4 x base |
| Cleanup Crack | `shield.disc > whip.crack` | +0.4 x base |
| Vibranium | `shield.disc > shield.dash > glove` | +0.9 x base |
| Sawblade Send-Off | `shield.grind > force.push > shield.disc` | +0.9 x base |
| Turnabout | `block > hook` | +0.5 x base |
| Hoplite | `shield.bash > saber.stab` | +0.55 x base |
| Nailed | `shield.slam > saber.stab` | +0.55 x base |
| Up Against the Wall | `shield.slam > glove` | +0.5 x base |
| Ringmaster | `whip > hook > shield.bash` | +1 x base |
| Frontier | `whip.crack > gun.pistol` | +0.5 x base |
| High Noon | `whip.crack > rig.draw` | +0.6 x base |
| Zorro | `whip.crack > saber` | +0.5 x base |
| Big Top | `whip.crack > shield.disc` | +0.55 x base |
| Crack and Smack | `whip.crack > glove` | +0.4 x base |
| Crack of Doom | `whip.crack > any \| legend.dormant` | +0.6 x base |
| Bullet Ballet | `whip.crack@slow > gun` | +0.9 x base |
| Tetherball | `whip.flail > glove` | +0.5 x base |
| Tetherball Disc | `whip.flail > shield.disc` | +0.5 x base |
| Rope-a-Dope | `whip.lasso > glove` | +0.5 x base |
| Rodeo | `whip.lasso > gun` | +0.45 x base |
| Hogtie | `whip.lasso > saber.cut` | +0.5 x base |
| Roped and Diced | `whip.lasso > shield.disc` | +0.5 x base |
| Bound | `whip.lasso > force.grip` | +0.5 x base |
| Hog-Tied | `whip.bola > grenade` | +0.55 x base |
| Saloon Brawl | `whip.lasso > glove > gun.pistol` | +0.9 x base |
| Bounty Hunter | `whip.lasso > force.pull > saber.cut` | +0.9 x base |
| Jungle Law | `whip.tarzan > glove` | +0.5 x base |
| Swing Shot | `whip.tarzan > gun.shotgun` | +0.5 x base |
| Swashbuckler | `whip.tarzan > saber.cut` | +0.6 x base |
| Cannonball | `whip.tarzan > shield.bash` | +0.55 x base |
| On a Leash | `whip.wrap > glove` | +0.5 x base |
| Tied Up | `whip.wrap > saber.cut` | +0.5 x base |
| Tethered | `whip.wrap > shield.disc` | +0.5 x base |
| Gift Wrapped | `whip.wrap > gun.explosive` | +0.5 x base |
| Package Deal | `whip.wrap > grenade` | +0.5 x base |
| Strangler | `whip.wrap > force.grip` | +0.5 x base |
| Puppeteer | `whip.wrap > force.grip > saber.cut` | +0.9 x base |
| Get Over Here! | `whip.yank > glove` | +0.6 x base |
| Closer | `whip.yank > gun.shotgun` | +0.5 x base |
| Reel and Deal | `whip.yank > saber.cut` | +0.5 x base |
| Yank and Bank | `whip.yank > shield.bash` | +0.55 x base |
| Into the Blades | `whip.yank > shield.grind` | +0.55 x base |
| Yank and Launch | `whip.yank > glove.upper > gun.shotgun` | +0.9 x base |
| Ringside | `whip.yank > grab.hold > glove` | +0.9 x base |
| Reel and Run Through | `whip.yank > saber.stab` | +0.55 x base |
| Fish Out of Water | `hook > glove.upper` | +0.6 x base |
| Harpoon | `hook > saber.cut` | +0.5 x base |
| Doorstop | `hook > shield.bash` | +0.5 x base |
| Come Here! | `hook > hands` | +0.5 x base |
| Hook Shot | `hook > gun.shotgun` | +0.45 x base |
| Care Package | `hook > grenade` | +0.6 x base |
| Collar | `hook > grab.hold` | +0.45 x base |
| Crack the Line | `hook > whip.crack` | +0.5 x base |
| Sawmill | `hook > shield.grind` | +0.55 x base |
| Meat Hook | `hook > blade` | +0.55 x base |
| Strung Out | `hook > force.grip > gun` | +0.9 x base |
| Kite | `hook > glove.upper > hook.yank` | +1.1 x base |
| Finish Him! | `hook > hands > fatality` | +1.1 x base |
| Reel and Hurl | `hook > shield.bash > shield.disc` | +1 x base |
| Wrestlemania | `hook.yank > grab.hold > glove` | +0.9 x base |
| Suplex City | `hook.yank > grab.hold > headlock.throw` | +0.9 x base |
| Hook, Line and Sinker | `hook.yank > shield.bash > saber.cut` | +0.9 x base |
| Hooked Keg | `hook.keg > any` | +0.4 x base |
| Fetch! | `hook.keg > grab.throw > gun` | +1 x base |
| Drop In | `hook.zip > gun` | +0.45 x base |
| Swoop | `hook.zip > melee` | +0.6 x base |
| Catch This | `grab.throw > glove` | +0.45 x base |
| Batter Up | `grab.throw > gun` | +0.35 x base |
| Bait and Hook | `grab.throw > hook` | +0.45 x base |
| Serve and Volley | `grab.throw > shield.bash` | +0.45 x base |
| Two Throws | `grab.throw > shield.disc` | +0.45 x base |
| Toss and Crack | `grab.throw > whip.crack` | +0.45 x base |
| Kitchen Sink | `grab.throw > grenade > gun` | +1 x base |
| Bait and Switch | `grab.throw > hook > melee` | +1 x base |
| Aftershock | `grab.keg > melee` | +0.5 x base |
| Sandbag Riposte | `grab.shield > gun` | +0.4 x base |
| Into the Breach | `grenade > melee` | +0.45 x base |
| Mop Up | `grenade > gun` | +0.3 x base |
| Flush Out | `grenade > hook` | +0.5 x base |
| Shell Shock | `grenade > glove` | +0.5 x base |
| Frag and Slash | `grenade > saber.cut` | +0.5 x base |
| Demolition | `grenade > grab.keg > gun` | +1 x base |
| Ice Breaker | `grenade.freeze > glove` | +0.55 x base |
| Cold Cut | `grenade.freeze > saber.cut` | +0.55 x base |
| Cold Shoulder | `grenade.freeze > shield.bash` | +0.55 x base |
| Ice Fishing | `grenade.freeze > hook.yank` | +0.7 x base |
| Ice Pop | `grenade.freeze > glove.upper > gun.shotgun` | +1 x base |
| Dazed and Confused | `grenade.stun > glove` | +0.55 x base |
| Stun and Gun | `grenade.stun > gun` | +0.45 x base |
| Snatch | `grenade.stun > hook` | +0.55 x base |
| Dizzy Finish | `grenade.stun > glove > fatality` | +1 x base |
| Butcher Shop | `grenade.stun > hook > blade` | +1.1 x base |
| Lights Out | `grenade.flash > melee` | +0.5 x base |
| Blind Side | `grenade.flash > saber` | +0.55 x base |
| Swat Team | `grenade.flash > hook > gun.shotgun` | +1 x base |
| Breach and Clear | `grenade.flash > shield.dash > gun.shotgun` | +0.9 x base |
| Out of the Smoke | `grenade.smoke > melee` | +0.5 x base |
| Ninja | `grenade.smoke > saber.stab` | +0.55 x base |
| Batting Practice | `grab.swing > gun` | +0.4 x base |
| Ghost Hold | `grenade.smoke > grab.hold > blade` | +1 x base |
| Pin Cushion | `grenade.sticky > gun` | +0.45 x base |
| Hot Potato | `grenade.sticky > hook > grenade` | +1.2 x base |
| Return to the Pack | `grenade.sticky > force.push > grenade` | +0.9 x base |
| Hot Lash | `grenade.fire > whip.crack` | +0.5 x base |
| Fan the Flames | `grenade.fire > force.push > gun.fire` | +0.9 x base |
| Rocket Punch | `gun.explosive > glove` | +0.5 x base |
| Over-Under | `gun.explosive > gun.rifle` | +0.4 x base |
| Mop-Up Saw | `gun.explosive > blade.saw` | +0.5 x base |
| Hot Hands | `gun.fire > glove` | +0.5 x base |
| Fire Whip | `gun.fire > whip.crack` | +0.45 x base |
| Plasma Blade | `gun.energy > saber.cut` | +0.45 x base |
| Shoot and Snap | `gun.pistol > whip.crack` | +0.4 x base |
| Buckshot Brawl | `gun.shotgun > glove` | +0.4 x base |
| Clean Up | `gun.shotgun > saber.cut` | +0.4 x base |
| Suppress and Storm | `gun.rifle > shield.bash` | +0.45 x base |
| Rip and Pump | `blade.saw > gun.shotgun` | +0.4 x base |
| Door Kick | `kick > gun.shotgun+pb` | +0.5 x base |
| Showdown | `rig.draw@slow > gun` | +0.9 x base |
| Draw and Shove Off | `rig.draw > force.push > gun.pistol` | +0.9 x base |
| Tuco | `throw.gun > rig.draw` | +0.5 x base |
| Slip and Shoot | `lean > gun` | +0.4 x base |
| Bob and Weave | `lean > hands` | +0.5 x base |
| Tennis | `return > return` | +0.5 x base |
| Volley | `return > return > return` | +1 x base |
| Kingslayer | `any@slow > any \| miniboss` | +0.5 x base |

</details>

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ Score

| Option | Default | What it does |
|---|---|---|
| Show Score | false | Shows the score line on your view. |
| Size | 150 (50 to 200) | How big the score line is. |
| Wrist Score | Off | The running total in small gold digits above the off-hand controller (VR only). |
| **Rewards** | | |
| Reward Bar | false | Shows the bar that fills toward the next reward. |
| Reward | Life Only | What filling the reward bar pays: ammo, a life, both in turn, or nothing. |
| **Big Moments** | | |
| Slow Motion | On | A big moment (a Fatality, a Perfect Riposte, Swan Song) gives a short pulse of slow motion. |
| Hit Stop | Off | A big kill stops the world for a beat. |
| Revival Fire | On | A column of fire when a life is spent. |
| Screen Flash | On | The master switch for every whole-view tint Score makes. |
| **Combat** | | |
| Head Shots | On | Head shots do extra damage, judged by our own head check on every monster. |
| Critical Hits | On | Random coloured critical shots that land a critical hit. |
| Glossary | (page) | What each bonus and combo is, what it is worth and what it needs. |
| Test and Debug | (page) | The score's position and look, the reward numbers, bonus caps, gold amounts, crit tuning, the roster bonuses and the logs. |
| Reset All | (button) | Puts every RSQ Score setting back to its default. |

<details><summary>RSQ Score: Test And Debug (57 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **Display** | | |
| Across | 50 (0 to 100) | How far across your view the score line sits (percent). |
| Down | 13 (0 to 100) | How far down your view the score line sits (percent). |
| Bonus Time | 35 (0 to 196) | How long a bonus stays on screen, in tics; 0 hides bonuses. |
| Living Label | On | The word "Score:" breathes from calm blue to warm. |
| Letters | Uniform | How the label's letters breathe: as one, in a wave, or each on its own. |
| Bar Flash | On | A reward lights the score bar and life pips. |
| Reward Tint | Off | A reward also tints the whole view (only with Screen Flash on). |
| Revival Tint | Off | A spent life also tints the whole view (only with Screen Flash on). |
| **Bonus Caps** | | |
| Kill Bonus Cap | 300 (0 to 1000) | The bonuses on one kill add at most this percent of its base; 0 is no cap. |
| Efficiency Cap | 0 (0 to 300) | The Efficiency family's ceiling, in percent; 0 is no cap. |
| Style Cap | 0 (0 to 300) | The Style family's ceiling, in percent; 0 is no cap. |
| Daring Cap | 0 (0 to 300) | The Daring family's ceiling, in percent; 0 is no cap. |
| Melee Cap | 0 (0 to 300) | The Melee family's ceiling, in percent; 0 is no cap. |
| Counterplay Cap | 0 (0 to 300) | The Counterplay family's ceiling, in percent; 0 is no cap. |
| **Reward Target** | | |
| New Map Keeps | Nothing | What a new map keeps of the score: nothing, the total, the total and rewards, or everything. |
| Target Size (%) | 50 (10 to 200) | The reward target's size against the map's monsters, in percent. |
| Fewest Monsters | 140 (0 to 500) | The target counts at least this many monsters. |
| Most Monsters | 800 (100 to 2000) | The target counts at most this many monsters. |
| Round To | 5000 (1000 to 20000) | The target is rounded to this many points. |
| Ammo Refill (%) | 40 (0 to 400) | The percent of each ammo's maximum an ammo reward hands back. |
| Raised Monster Pay (%) | 100 (0 to 100) | What a monster not on the map at its start (raised, spawned) pays, in percent. |
| Top Rank Multiplier | 2 (1 to 5) | The Rank multiplier at Rank 100 (1 is off). |
| Starting Lives | 1 (0 to 9) | How many Score lives a new game starts with. |
| **Slow Motion** | | |
| Cooldown (s) | 6 (1 to 30) | The fewest seconds between two big-moment slow motions. |
| Style Share (%) | 50 (0 to 200) | A kill in slow motion pays this percent of its bonuses again. |
| **Head Shots** | | |
| Heads on Demons | On | Demons, cacos, pain elementals, lost souls and spiders get a head too (the top of the body). |
| Unknown Head (%) | 80 (50 to 98) | Where an unknown monster's head starts, in percent of its height from the feet. |
| **Critical Hits** | | |
| Crit Chance | 0.15 (0.01 to 1) | The chance each player's crit shot starts with. |
| Crit Colour | Cyan | The colour of a crit shot. |
| Damage Multiplier | 2 (1 to 10) | The critical blow's damage multiplier. |
| Stunned Multiplier | 2 (1 to 10) | Every other blow's damage multiplier while the monster is stunned. |
| Crit Sound | ZX Clash | The sound a critical hit plays. |
| Crit Volume | 1 (0 to 1) | The critical hit sound's volume. |
| Crit Effect | Blue Flash | The flash or splatter a critical hit shows. |
| **Roster Tiers** | | |
| Green Tier | On | The Green tier's roster bonus pays. |
| Blue Tier | On | The Blue tier's roster bonus pays. |
| Cyan Tier | On | The Cyan tier's roster bonus pays. |
| Purple Tier | On | The Purple tier's roster bonus pays. |
| Yellow Tier | On | The Yellow tier's roster bonus pays. |
| FireBlu Tier | On | The FireBlu tier's roster bonus pays. |
| Abyss Tier | On | The Abyss tier's roster bonus pays. |
| Brown Tier | On | The Brown tier's roster bonus pays. |
| Gray Tier | On | The Gray tier's roster bonus pays. |
| Red Tier | On | The Red tier's roster bonus pays. |
| Black Boss | On | The Black Boss's roster bonus pays. |
| White Boss | On | The White Boss's roster bonus pays. |
| EX Boss | On | The EX Boss's roster bonus pays. |
| **Roster Bonuses** | | |
| Rarity | On | The Rarity roster bonus pays. |
| Full Spectrum | On | The Full Spectrum roster bonus pays. |
| Colour Chain | On | The Colour Chain roster bonus pays. |
| Keep the Change | On | The Keep the Change roster bonus pays. |
| Fresh Paint | On | The Fresh Paint roster bonus pays. |
| Upset | On | The Upset roster bonus pays. |
| Tier Slayer | On | The Tier Slayer roster bonus pays. |
| **Logs** | | |
| Head Shot Log | Off | One console line per judged head-shot blow. |
| Gold Log | Off | One console line per gold deposit and spend, and each map's gold as it ends. |
| Debug Log | Off | Score's debug lines in the console. |

</details>
<!-- /GEN:options -->

## Works with

Score links to no other mod. It finds each one by a service, class or setting name, and every row that needs a mod gives nothing without it.

| Mod | What changes |
|---|---|
| RSQ Score's own service, `RS_ScoreService` | What any mod may ask by name. GetInt: `award` (label, points, pawn), `touch` (tool id, player number, monster), `combo`, `tool`, `givelife`, `revivefire`, `census.take`, `census.add`, `gold.add`, `gold.spend`, `life.spend`, `headshot`, `head.at`, `kill.serial`, `kill.style`, `kill.base`, `kill.big`, `crit.chance.set`, and the reads `score`, `progress`, `lives`, `rewards`, `gold`, `gold.earned`, `gold.map`, `crit.chance`. GetString: `kill.chain`, `monster.name`. GetObject: `kill.victim`. GetIntUI: the reads, and `hud.cx`, `hud.bar.bottom`, `hud.bar.w` |
| Any mod that links Score | `RS_ScoreRegistry.RegisterBonus`, `RegisterCombo` and `RegisterTool` add a bonus class, a named combo or a tool, from that mod's OnRegister. Every gain is also added to the player's engine `score` field, which other mods read |
| RSQ Grapple | Score asks `RSQGR_Service`: `hooked`, `hooked.by`, `hooked.heavy`, `yanked`, `struck`, `struck.by`, `pin`, `volleys`, `landing`, `whipped`, `hook.dealing`, `swinging`, `airborne`, `rope.speed`, `released`, `released.speed`, `landed`. The Grapple at this commit answers only names that start `g2.`, so every one of these gets no answer |
| RSQ ShieldSaw | Score asks `SSQ_ScoreService`: `blocked`, `perfect`, `returned`, `returned.from`, `thrown.leg`, `disc.grinding`, `grind.held`. It knows the classes `SSQ_Disc`, `SSQ_LockMark` and `SSQ_ShieldSaw` by name. It reads the ShieldSaw's touches `shield.slam`, `rev.block`, `backplate`, `cleave.saw` (and keeps `dash.bash`, `spartan`, `slam.saw`, `reflect.saw`, `buzz.return` as tags) |
| RSQ Saber | Score asks `UBQS_SaberService`: `blocked`, `perfect`, `pulled`, `gripped`, `saber.lit`, `thrown.leg`. It knows `UBQS_Thrown`, `UBQS_Force`, `UBQS_Bolt`, `UBQS_RemoteBolt` and the damage type Saber by name, and hides the wrist digits while the player carries `UBQS_RemoteOut`. It reads the Saber's touches `saber.stab`, `force.lightning`, `force.slam`, `stab.lunge`, `impale`, `crossguard`, and its awards `Deflect` and `Remote Down` |
| RSQ Distance Grab | Score asks `RSQDG_ThrowService`: `throw.by`, `throw.blast`, `throw.cms`, `throw.juggle`, `throw.kg`, `hold.full`. It reads Distance Grab's touch `grab.swing`. The life crate tells `RSQDG_GrabRuleService` (`grab.hello`, `grab.rule`, `grab.weight`) that it may be pulled |
| RSQ Tactical Rig | Score asks `RSQTR_RigService`: `rig.drawtic` and `rig.drawn`, for each hand. It reads the Rig's touches `gun.toss` (as the tool throw.gun) and `boomerang.gun` |
| RSQ SlowMo | Score asks `RSQSM_Service`: `slowmo.active`, `trigger.auto`, `trigger.score`, `scale`, `active`, `running`, `down.hold`, `countdown.bottom`, and `start.reward` with `life.up` (2500 ms, on a life from the bar) or `life.used` (5000 ms, on a life spent). It sends the network event `rsm_pulse` and reads SlowMo's setting `rsm_ramp_in`. While SlowMo's DOWN holds you, no Score life is spent. It reads SlowMo's touch `lean` and its award `Revenge`; a monster's shot of class `RSQSM_Round` counts as fired |
| RSQ Whip | Score asks `RSQWP_Service`: `wrapped`, `wrapped.by`, `yanked`, `returned`, `crack.k`, `swings`, `swinging`, `airborne`, `rope.speed`, `released`, `released.speed`, `landed`, and knows the damage type Whip. The Whip at this commit has no rope: it answers 0 to `swinging`, `airborne` and `swings` and "not happened" to the rest, and sends Score no touch. So of the whip's rows only Lashed is given, and of the named combos only those whose whip step is `whip` or `whip.crack` can match |
| RSQ Melee | Score asks `RSQML_Service`: `punch.kind`, `punch.counter`, `punch.body`, `punch.height`, `punch.kinds`, `punch.run`, `punch.star`, `launch.age`, `returned.by`, `headlock.by`, `headlock.shield`, `guarded`, `barrel.kicked`, `fear`. It knows the classes `RSQ_Glove...`, `SPO_Glove...`, `RSQ_GloveFist` and `RSQML_Round`, and reads Melee's setting `rsqml_slappers`. It reads Melee's touches `grab.hold`, `shove`, `whip.pistol`, `pound`, `clearout`, `guard.release`, `guard.reflect`, `hadouken`, `swat.back`, `parry`, `slam`, `choke`, `headlock.launch`, `taunt` (as tools) and `hit.heavy`, `hit.body`, `juggle`, `punch.uppercut`, `launch`, `meteor`, `wall`, `shield.human`, `bullet.punch`, `butt.knockdown`, `catch`, `guard` (as tags). Melee's award `F.E.A.R. Effect` is taken and gives no points: the combo of that name gives them on the kill |
| RSQ Grenade | Score asks `RSQGN_Service`: `turned.by`, `teeth`, `skeet`, `impact`, `cooked`. It knows `RSQGN_Thrown`, `RSQGN_HandBlast`, `RSQGN_Bomblet` and `RSQGN_FireField` by name. It reads the Grenade's touches `sticky`, `freeze.nade`, `stun.nade`, `flash`, `smoke`, `fire.nade`, `charm`, `infight` |
| RSQ Miniboss | Score asks `RSQMB_Service`: `rank`, `window`, `enraged`, `bossfight`, `bigboss`, `meter.bottom`, and tells it `rank.life` (1 a life gained, 0 one lost). It knows the tokens `RSQMB_Thrall`, `RSQMB_Ward` and `RSQMB_Rage`. It takes the award labels `Miniboss Called`, `Boss Called`, `Miniboss`, `Boss`, `Thrall Slow Kill` and `Finisher`. Miniboss spawns the life crate by name |
| RSQ Monsters | Score asks `RSQMN_RosterService`: `tier`, `ex`, `spawn.odds`, `tier.next`, `tier.ago`, `tier.from` (and `set`, which nothing in Score then uses) |
| RSQ VisualRewards | Score asks `RSQVR_Service`: `banner` (LIFEUP and LIFEUSED), `toast` (MAGS REFILLED), `worldword` (1UP), `banner.lives`, `invbar.bottom`. Without it none of those words show |
| RSQ Glow In The Dark | On a life spent Score asks `RSQGD_Service` for `event.lifeflash`, 5 s |
| RSQ Graveyard | On a life spent Score asks `gy_RSQService` for `stone.life` where you stood |
| RSQ Gun Bonsai VR | Score asks `RSQ_HudService` for `gauges.top` and `gauges.bottom` and sets the score line in the middle of the hand gauges' band. It keeps Gun Bonsai VR's touch `lucky` as a tag |
| RSQ Accessibility | Read only while its class `RSQA_Menu` is loaded: `rsqa_colorblind` changes the families' colours and adds a letter (E, S, D, M, C) to each row; `rsqa_photosafe` dims flashes to 40 in 100, spaces score flashes 14 tics apart and holds the word Score: still; `rsqa_text_scale` scales the score line and the wrist digits |
| Brutal Doom and BD22 VR Reloaded | Score swaps Brutal Doom's head-checking bloods and head hitboxes for its own, by class name, and sets Brutal Doom's `HitHead` and `HitLeg` tokens from its own head check. BD22 VR's `RSQ_PlayerRound` and `RSQ_PiercingRound` roll critical shots (its setting `sv_rsq_round_speed` is read). Guns are told apart by BD22 VR's class names; plain Doom's read as the same kinds |
| Champions | Champions' tokens are read by class name (`champion_PersistentInfo`, the colour tokens, `champion_TitanToken`, `champion_BalloonToken`, `champion_CloneToken`, the actor `champion_Heart`) and its settings `champion_Legendoom` and `champion_Dormant`. The champion rows show Champions' icons |
| LegenDoom | Found by its lump `LEGNDLIB`; its tokens `LDLegendaryMonsterToken` and `LDLegendaryMonsterTransformed` are read by name |
| Critical Shots (mk-crits) or RandomCrits | With either loaded (found by `csh_Brain`, `csh_critController` or `RandomCrits_EventHandler`) Score's own critical shots do nothing, and say so once in the console |

## Limits

- Score has no keys of its own: it ships no KEYCONF and reads no bind. The only buttons it looks at are each hand's fire and alt fire, to tell which hand shot.
- With New Map Keeps at Nothing (the default) every new map starts with 0 Score lives, the starting life of a new game included, and an empty bar.
- A life is spent only by a hit that would have killed. A life is not spent while RSQ SlowMo's DOWN holds you.
- At most 10 life faces are drawn; lives past 10 are held but not shown.
- A monster that does not count for the level's kills and replaces no counted monster is no kill (Lost Souls are). A Lost Soul killed in the tic it was born gives nothing. A morphed monster counts once.
- A body counts in full once. Raised again it gives Raised Monster Pay percent of its base, which is 100 until you lower it.
- Of two rows that mean the same thing only one is given: the row that says Replaces wins.
- A combo's moves must come no more than 3 s apart and the last one must be the killing blow. Moves older than 10 s are forgotten.
- Only one named combo is given on a kill: the one worth most.
- RSQ Grapple at this commit answers none of the names Score asks it, so Reeled In, Ping-Pong, Hard Landing, Fly Ball, Hooked Keg, Boarding Party and Zip Kick are never given and no named combo with a hook step can match. Bowling is still given for a Headlock toss.
- RSQ Whip at this commit has no rope, wrap or yank and sends Score no touch, so Swinging, Hanging Shot, Dismount, Chain Swing, Tarzan, Wrecking Ball, Stun Lock, Heavy Haul and Snap Kill are never given.
- RSQ Miniboss at this commit answers 0 to `window` and `enraged`, so Chain Gang and Rage Quit are never given.
- Monsters never land a critical hit on you: only a player's blow is looked at.
- A head shot needs a bullet's puff or a missile: an explosion, a punch, a thrown body, and a monster that is knocked down or crouching (Brutal Doom's tokens) are never a head shot.
- Score gives no gold of its own: its Skill Gold is switched off in code. Gold comes in only when another mod asks `gold.add`, and is shown by other mods.
- The Glossary reads no mouse wheel and no drag: a pointer can pick only the 9 rows shown and the six tabs. Its words come from a generated file, not from the bonuses as they run.
- Wrist Score shows only in VR.
- Five names are used twice, by a bonus row and by a named combo: Bouncer, Riot Control, Rope-a-Dope, Hooked Keg, Ice Breaker.

## Credits

The full list, with every file and its origin, is in **CREDITS.md**.

- **ijon** (*Dakka*, *Vanilla VR Dakka Points*, WTFPL): the scoring design, the thirteen classic bonuses and their
  families and numbers, the reward loop, the HUD layout and its graphics, the colour set, and the revival that Score's
  fire is rebuilt from.
- **Blue Shadow** (the score line's font) and **Jimmy** (the breakdown's font), carried from *Dakka*.
- **People Can Fly** (*Painkiller*): the reward, life and revival sounds, carried from *Dakka*.
- **Critical hits, a hybrid of two mods, credited side by side:**
  - **Mikk-** (*Critical Shots*, mk-crits; "You're welcome to use this in your own projects", ZDoom forum): what a
    crit does when it lands: its damage, its stun, its hit flashes and its sound choices. His credits for those flashes
    and sounds are in CREDITS.md: Neoworm's Touhou rips, SNK's Metal Slug (ripped by Kevin Huff), Major Cooke, Bandai
    Namco and From Software, Capcom and Inti Creates (ripped by Team Kiira), Call of Duty, and Valve.
  - **cyber_c001** (*RandomCrits*): which shots crit: the random roll on each shot as it is fired, its 15% player
    chance and its crit-shot colours. RandomCrits' TF2 crit sounds are **not** used: mk's sound plays for every crit.
- **presidentkoopa:** RS_Score, the design of the Quest series' version, and the breathing word's colours from his
  own earlier Score HUD.
- **id Software:** the Arch-Vile fire the revival draws, the Berserk pack the life crate wears, and the small-font
  digits on the wrist, all read from the IWAD (not shipped).
- **QuestZDoom** (Emawind and Team Beef): the engine and its VR hand API.

---
Written from the code at commit d66896944, 2026-11-27.
