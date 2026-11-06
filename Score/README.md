# RSQ Score

An arcade scorer for VR Doom. Every kill pays for how you pulled it off, and every tool in the series chains
into combos.

**Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.**

New on 11-06 (rig only, not headset-confirmed): Letters (Uniform / Wave / Chaos), replacing Letter Wave.

RSQ Score is ijon's *Dakka* point system rebuilt in ZScript for stock QuestZDoom 17.3, then grown to fit what
your hands can do in VR. It watches the whole RSQ series: the saber, the ShieldSaw, the whip, the grappling
hook, Distance Grab, the gloves, the grenades, the holsters and slow motion. Nothing links to anything. Score
asks each mod by name, and if a mod isn't loaded its bonuses simply never fire.

## Standout feature: combos across your whole arsenal

Every monster remembers, in order, the tools that touched it. When it dies, the chain pays.

Crack the whip on an imp, then slam it with the shield. That's **Lion Tamer**. Uppercut a zombie, then finish
it with the shotgun. That's **Trap Shooter**. Hit a demon with a hadouken, shove it with your gun butt and
finish it with the shotgun. That's **Return Fire**. Shove a demon with your gun butt,
then finish it with a shotgun blast in the slow motion the shove gives you. That's **F.E.A.R. Effect**.

There are more than 240 named combos. Any mix without a name still pays as a generic **N-Tool Combo**. Order
matters: whip-then-bash isn't bash-then-whip. A single kill can show a named combo, a family of bonuses and
a slow-motion moment, all in the breakdown under your score.

## Features

**How a kill is scored**
- **Base:** a kill pays the monster's starting health. A vanilla imp pays 60, a Cyberdemon 4000.
- **Bonuses:** each bonus that fires adds a share of that base. They add up. They don't multiply each other.
- **The kill cap:** all the bonuses on one kill add at most three times its base (300%). This stops a pile-up
  without trimming any single bonus.
- **Who gets it:** the killing blow's source, traced back through projectiles. A monster you shoved or punched
  into a pit or crusher is still yours (**Ring Out**). A monster you turned with a grenade that kills
  another pays you (**Civil War**). Monsters killing each other pay every player (**Infighter**). A monster
  that kills itself pays everyone three times its base (**Darwin**).
- **Fair counting:** only real monsters count. Brutal Doom's helper actors (blood smears, dying bodies)
  never pay. Its renamed monsters still do. A monster that wasn't on the map at the start (raised by an
  Arch-vile, spat by a Pain Elemental) can be set to pay less, and each body only ever pays once.

**Five bonus families, five colours**
- **Efficiency** (red): fighting fast and clean. Spree, Untouchable, Infighter.
- **Style** (green): how it looked. Air, Curveball, Switcharoo, Skeet, Off-hand, Two Guns, Multi-Kill, the Combo Chain.
- **Daring** (orange): risk. Point-Blank, Redline, Swan Song, No-Look, Blind-fire, Quick Draw, Headshot, champions and legendaries.
- **Melee** (steel blue): the hands' craft. Fatality, Cleaved, Hurled, Shoryuken, Giant Slayer, Wall Splat, Death from Above.
- **Counterplay** (violet): defence turned into a kill. Riposte, Perfect Riposte, Return to Sender, Poetic Justice, Rally.

There are nearly 190 bonuses in all. Many belong to one mod and fire only when it's loaded.

**A taste of the bonuses**
- **Swan Song:** the kill landed after you were already dead. Adds three times the base, the biggest single bonus.
- **Redline:** a kill while your own health is nearly gone. The closer to 1 HP, the more it pays.
- **No-Look:** the killing shot left your hand more than 60° away from where your head was facing.
- **Blind-fire:** you shot around a corner with your hand while your eyes stayed behind cover.
- **Point-Blank:** measured from the edge of your body to the edge of its body, so a Cyberdemon on your toes counts.
- **Air Catch:** you threw something with Distance Grab, caught it back out of the air and threw it again for the kill.
- **Powder Keg:** a thrown barrel's blast. Each kill from the same chain of blasts pays more.
- **Quick Draw / Hot Swap:** a kill with a gun you just pulled from a Tactical Rig holster.
- **Poetic Justice:** a shot you sent back kills the very monster that fired it.
- **Tarzan:** you swing in on the grappling rope and your arrival kills it.
- **Stretched Second:** a kill in slow motion pays an extra share of its style.
- **Last Grain:** a kill in the last moment of slow motion, as the world speeds back up.
- **Rainbow:** kill champions of 5, 10 and all 14 colours in one map.

**The combo chain**
- A chain is the ordered list of tools that touched a monster. It breaks after **3 seconds** with no new move.
- Every gun counts as one tool, "gun". (Swapping guns is Switcharoo's bonus.) A combo can still name a
  specific gun, such as the shotgun.
- How a blow landed (a heavy hit, a headshot, airborne, point-blank) rides on the move. It never counts as an extra tool.
- **Generic pay:** 2 tools +20% of base, 3 tools +45%, 4 tools +75%, 5 tools +100%, 6 or more +120%.
  Each mod beyond the second in the chain adds 10% (up to 30%). A whole chain inside 2 seconds pays 25% more.
- **Named combos:** one per kill, the best-paying match. It replaces the generic pay for the tools it
  names, and any tools beyond those still pay as generic. Nothing scores twice.
- The breakdown shows the named combo and the N-Tool part on their own rows.

**Rewards**
- Each map sets a target score from its monster count and their average health. Every time your score crosses
  it, you earn a reward.
- By default every reward is an **extra life**. While you hold one, a hit that would kill you leaves you at
  1 HP, then you're revived to full health, as in *Dakka*: the revive sound, a blast that hurts everything within
  256 units but you (*Dakka*'s 384 damage), no damage to you for about 2.7 seconds, and a turning ring and rising column
  of fire round you, 80 units out (Revival Fire). The fire is 32 pooled flames and one light, spawned once, instead of
  *Dakka*'s ~1,150 flames. Damage that ignores the hold (a telefrag, for example) still kills you, and you lose every
  life you held. Code only, not rig-tested, not headset-confirmed (owner 11-05: "i wanted an optimized version of that").
- Other reward modes alternate lives with an **ammo burst**: 40% of every ammo type you carry, given back over 20 seconds, for any weapon set.

**Slow-motion moments** (with RSQ SlowMo)
- A big moment, such as a Fatality, Perfect Riposte, Swan Song, a Telefrag, a three-step named combo or a five-tool chain,
  slows the world for a beat. A 6-second cooldown stops a killing spree from becoming one long slow motion.
- **Hit-Stop on Big Kills** (optional, off by default): a big moment, or a kill on a monster with 400+ health,
  briefly drops the world to 5% speed. At most once a second, and never while time is already slowed.

**The HUD**
- **Score: N** in gold, top right by default. The word "Score:" breathes every 2 seconds, from calm blue to warm
  yellow, and flares hot white-gold when points land or on a big combo (Living Label; the owner's own label colours).
  It warms toward gold as you near a reward. Letters picks how the word's letters breathe: Uniform (all together), Wave (a smooth sequence across the word) or Chaos (each letter on its own pace).
  Photosensitive Mode holds it at one steady colour; a colour-blind setting keeps the breath as brightness only.
- **The reward bar** under it fills toward the next reward. It's blue when the next reward is a life and orange when it's ammo.
  When it fills, you hear the reward sound and the whole bar lights up in what you got (orange for ammo, blue for a life) while the score
  flashes. A life also makes the life pips swell and light up. Only the HUD flashes, not the whole view, because a whole-view flash costs extra full-screen passes in each eye in VR.
- **Life pips** above the score: one animated pip for each extra life you hold, up to ten.
- **The breakdown** under the bar: "+N  Name" for the base and every bonus that paid, each in its family's colour.
  Quick kills add into the same row while it's on screen, so three fast point-blank kills read as one growing number.
  Rows fade after the display time.
- **Score on the Wrist** (optional, off by default): your running total in small gold digits floating above
  your off-hand controller, like a watch. VR only.

## How To Play

1. **Load it and play.** There's nothing to bind. The score sits top right and the breakdown appears under it as you kill.
2. **Read the breakdown.** Every row names what you did. Colour tells you the family: red for speed, green
   for style, orange for risk, blue for melee, violet for counters.
3. **Fill the bar.** Each time it fills you bank an extra life (a pip above the score). Lives catch you at 1 HP.
4. **Start chaining.** Hit one monster with two different tools inside 3 seconds, then kill it. Watch for
   "2-Tool Combo". Then try three. Bring the whip, the hook, the gloves and the shield into one fight.
5. **Play like it's VR.** Shoot with your off hand. Dual-wield. Shoot one way while looking another. Fire
   around corners. Jump and shoot. Draw from a holster and fire at once. The code reads all of it.
6. **Master it.** Hunt the named combos. Go for risk: Point-Blank, Redline, Swan Song. Load RSQ SlowMo and earn
   your big moments in bullet time.

## Controls

RSQ Score has no keys of its own. It reads what you already do. These are the VR moves that the bonuses look for.

| Action | How (VR) | Notes |
|---|---|---|
| Off-hand kill | Off-hand trigger (off-hand fire, as the engine maps it) | **Off-hand:** only the off-hand trigger was held when the killing shot fired. |
| Dual-wield | A gun in each hand, both killing | **Two Guns:** this kill from one hand's trigger and your last kill, inside a second, from the other's. |
| Shoot without looking | Aim your hand more than 60° away from where your head faces | **No-Look.** |
| Blind-fire | Hold the gun around a corner while your head stays behind cover | **Blind-fire.** A gun pushed through the wall doesn't count. |
| Airborne kill | Jump and kill before you land | **Air.** Paid on how high the jump reaches. |
| Holster draw | Draw from a Tactical Rig holster and kill straight away | **Quick Draw** (within about a second), **Hot Swap** (a swap mid-fight). |
| Thrown kill | Throw an object, barrel, corpse or dropped gun with Distance Grab | **Thrown, Powder Keg, Body Blow, Hand-Me-Down, Air Catch.** |
| Chain a combo | Different tools on the same monster, each within 3 s of the last | See *The combo chain*. |

**Left-handed play:** Score follows the engine's own main-hand and off-hand mapping, so Off-hand and Two
Guns work either way round. Score on the Wrist floats above whichever controller is your off hand.

## Menu

Options → Radiant Silvergun Options → **RSQ Score**. One page; the raw numbers (position, caps, the reward target) and
the debug log are on **Test and Debug**; **Reset All** at the foot resets both. Score has no Gun Bonsai VR gating.

| Row | Default | What it does |
|---|---|---|
| Show Score | Yes | Shows or hides the whole display, including the wrist digits. |
| Size | 150 | The display's size, 50-200. |
| Living Label | On | The word "Score:" breathes, blue to warm, and flares when points land. |
| Letters | Uniform | Uniform: the word breathes as one. Wave: the breath runs across the word letter by letter. Chaos: each letter breathes on its own pace and timing. |
| Score on the Wrist | Off | Your total above the off-hand controller (VR only). |
| **Rewards** | | |
| Show Reward Bar | Yes | The bar that fills toward the next reward. |
| Target Reward | Life Every Time | What crossing the target pays: Ammo Then Life, Life Then Ammo, Ammo Only, Life Every Time or Nothing. |
| New Map Keeps | Nothing | What carries to the next map: Nothing, Total, Total and Rewards, or Everything. |
| **Big Moments** | | |
| Slow Motion Moments | On | Big moments ask RSQ SlowMo for a short slow. |
| Hit-Stop on Big Kills | Off | Big kills stop the world for a beat (needs RSQ SlowMo). |
| Revival Fire | On | The ring and column of fire round you when a life is used. The blast and protection happen either way. |
| Bar Flash | On | The score and bar flash when points land. |
| Screen Flash | On | The switch for the two whole-view flashes below. Off stops both. |
| Reward Screen Flash | Off | The old whole-view colour flash on a reward, on top of the bar's glow. It needs Screen Flash on. |
| Revival Screen Flash | Off | A warm whole-view flash when a life is used. It needs Screen Flash on; never in Photosensitive Mode. |
| Test and Debug | | The page below. |
| Reset All | | Every setting on both pages back to its default. |

**Test and Debug**

| Row | Default | What it does |
|---|---|---|
| Across | 85 | Horizontal position, 0-100. |
| Down | 10 | Vertical position, 0-100. |
| Bonus Time (0 Hides) | 35 | How long breakdown rows stay, in tics (35 = 1 second, up to 193); 0 hides the breakdown. |
| Kill Bonus Cap | 300 | The most all bonuses on one kill can add, as a percent of base (0 = no cap). |
| Efficiency / Style / Daring / Melee / Counterplay Cap | 0 | Each bonus family's cap per kill, percent of base (0 = no cap). |
| Target Size (%) | 50 | The reward target: this share of (average monster worth x monsters counted). |
| Fewest Monsters | 140 | The monster count used is at least this. |
| Most Monsters | 800 | And at most this. |
| Round To | 5000 | The target is rounded to this many points (and never below it). |
| Ammo Refill (%) | 40 | An ammo reward refills this share of each ammo type's maximum. |
| Raised Monster Pay (%) | 100 | Percent of base paid for monsters that weren't on the map at the start (raised, spawned). |
| Slow Motion: Cooldown (s) | 6 | Seconds between slow-motion moments. |
| Slow Motion: Style Share (%) | 50 | Percent of a kill's style, daring and melee bonuses that Stretched Second adds in slow motion. |
| Debug Log | Off | Logs the scoring to the console. |

## Works with

RSQ Score runs on its own: on plain Doom, every classic bonus works. Every other mod adds bonuses when it's loaded.

- **The RSQ series:** RSQ Saber, ShieldSaw, Whip, Grapple, Distance Grab, Melee, Grenade, Tactical Rig and
  SlowMo each become tools in the combo chain and bring their own bonuses. Grapple pays **Indiana Jones** for a
  gap crossed on the rope. The saber's training remote pays **Deflect** and **Remote Down**. RSQ Miniboss's kills pay as
  shares of the kill's base (Thrall Slow Kill, Miniboss, Greedy, and **Bossfight**, 2 x, for a called-in miniboss). RSQ
  Miniboss's Bossfight meter reads each kill's style points and sits under the bar; the bonus list goes below it.
- **RSQ SlowMo:** big moments and the optional hit-stop use its slow motion. Slow motion you started pays the
  full Stretched Second share. Automatic slow motion pays half, and Score's own pays none. SlowMo's two bars
  (stored slow-mo and countdown) sit under Score's bar, and the breakdown moves down to make room.
  New on 11-06 (rig only, not headset-confirmed): SlowMo's **DOWN** comes before a Score life. While DOWN holds you
  at 1 HP no life is spent; a life is spent only if DOWN fails. Each kill inside DOWN pays a **Down** row (half the
  kill's base) and getting up pays a **Revive** row (twice the reviving kill's base).
- **RSQ Accessibility:** Text Size scales the whole display and the wrist digits. Colour-blind play swaps each
  family to colours made for that vision and adds the family's letter (E, S, D, M, C) beside each row. The
  reward bar also shows a life pip when a life is next. Photosensitive Mode dims flashes to 40%, limits them to 2.5 a second and holds the label still.
- **Gun Bonsai:** Score adds what you earn to the engine's standard score field. Gun Bonsai can turn rises in that field into weapon XP.
- **RSQ Gun Bonsai VR:** its "XP Source: Style" reads what each kill earned in style, and Lucky Kill reads Score's big moments.
  While its ShieldSaw gauge is on, the score display moves down to clear it.
- **Champions and LegenDoom Lite:** a champion kill names its colour and mutation. Legendaries, denied legendaries and
  legendary champions get their own rows.
- **Brutal Doom / BD22 VR Reloaded:** Brutal Doom's executions pay **Fatality**, its cuts and boots feed the melee family, and
  BD22 VR's Super Shotgun fired point-blank pays **Coach Gun**.
- **For modders:** pay a labelled award with `RS_ScoreService` `GetInt("award", "<row>", points, 0, pawn)`. Add a
  tool to a monster's chain with `GetInt("touch", "<tool>", playerNumber, 0, monster)`. Give a player extra lives with
  `GetInt("givelife", "", n, 0, pawn)` (n 0 or less gives 1; returns the lives now held, -1 without a score): added like
  an earned life, with an earned life's cue (owner 11-05: "can we have killing a miniboss give a Score life?"). Add your own bonus by
  subclassing `RS_ScoreBonus` and registering it with `RS_ScoreRegistry.RegisterBonus`.

## Credits and licence

- **ijon** (*Dakka* / *Vanilla VR Dakka Points*, <https://github.com/0dot0repeating/dakka>, released under the WTFPL):
  the scoring design. That covers the thirteen original bonuses and their three families with every number attached,
  the reward loop of a per-map target paying out lives and ammo, the HUD layout, and the score HUD graphics
  (SCOREBG1-4, SCOREBR1-4, SCOREBKT, HUD_LIF1-4). This is a ZScript rebuild of those rules, not a copy of the code.
- **Blue Shadow** (the score-line font, carried as RSSCFON) and **Jimmy** (the breakdown font, RSSCFN2), as credited
  in *Dakka*, and carried here with that credit.
- The `TEXTCOLO` colour definitions come from *Dakka*, renamed so that both mods can load together.
- **presidentkoopa** (project owner): RS_Score, the registry, the anti-farming rule, the caps, the generalised
  ammo regeneration and the gravity-aware Air bonus. The Quest series version adds the Brutal Doom kill rule, the Melee
  and Counterplay families, the physical, suite and combo bonuses, the slow-motion moments, the menu and the pooled revival fire.
- The six score sounds in `sounds/score/` are *Dakka*'s files (byte for byte), which *Dakka* credits to People Can
  Fly, *Painkiller*. *Dakka*'s revival (the blast, the protection, the ring and column of fire) is rebuilt from its
  code with a fixed pool of flames; the flame sprite is doom2.wad's Arch-vile fire, not *Dakka*'s (see CREDITS.md).

The fonts ship with credit to Blue Shadow and Jimmy (owner's decision). See [CREDITS.md](CREDITS.md).
