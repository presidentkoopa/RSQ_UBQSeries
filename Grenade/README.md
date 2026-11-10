# RSQ Grenade

A hand grenade you work like a real one: pull the pin with your other hand or your teeth, squeeze the spoon, cook it,
and throw it with your own arm.

Status: 0.99. The grenade was played and confirmed working in the headset; refinement and bug fixing ongoing. The
barrels and the explosions (11-09) were run on the rig the same day (QuestZDoom 17.3 Linux rig on Freedoom 2, no Brutal
Doom; **rig only, not headset-confirmed**): 11 compile errors fixed (two names were ZScript keywords); barrels go off and
chain at the stock pace; both Barrel Sound choices play. The look of the six explosions in the engine is not yet seen. The pk3 is `pk3/RSQ_Grenade.pk3`
(rebuilt 11-09).

**What's new**
- **11-09 evening** (rig, with brutal22test6 + BD22 VR Reloaded 2.0.4e + XMVE): **Brutal Doom's Launchers** (Explosions,
  on): BD's rocket launcher (Rocket2, Rocket2Fast, RocketDM) and grenade launcher (GrenadeMissile, ShortGrenade2) shots
  go off with our blast; BD's drawing-only explosion actors there are removed, its damage, sounds, quake and craters
  stay. Rockets play **the rocket blast** (renders/rocket, approved without the flashback): the floor version within 24
  units of the floor, the air version otherwise (a wall hit too); grenades play the grenade's.
- **11-09 evening, built from the approved mockups** (not yet loaded in the engine): **the rocket blast** and **the mega
  blast** (MEGA2, the non-mushroom design), exported frame by frame (tools/flip_export.py) and played as one full-bright
  pixel billboard with a light that follows the mockup's glow. A **chain's finale** (the fifth barrel down a chain, with
  Chain Escalation) is now the mega blast.
- **11-09, evening** (code only: loads clean, not yet run on the rig, not headset-confirmed): the throw. Owner on PC VR:
  "there is no way to throw grenades". Three fixes. Grip and trigger together (which the engine sends as alt fire) now
  count as squeezing the spoon, so letting go of them cooks or throws. The swing speed is measured the way BD22 VR's
  grenade and the ShieldSaw measure theirs; the old way went blind whenever your head turned during the throw. And a
  grenade in your hand always works, even with Brutal Doom VR loaded and Replace Brutal Doom's Grenade off.
- **11-09, later** (rig only, not headset-confirmed): the wall scorch fades away instead of cutting out. It used to
  share the engine's small decal limit with every bullet hole and blood splat (20 on QuestZDoom), so a few shots later
  it vanished at once. Now it is outside that limit: the soot stays 8 seconds, then fades out smoothly over 6.
- **11-09** (rig only):
  - **Barrels**: six new barrel explosions, picked at random (below).
  - **Explosions**: a new grenade blast and options for both: colour, lights, debris and seven room contexts (below).
  - **Barrel Sound**: Combat FX, or the owner's Test Candidate (below).
- **11-06** (rig only, not headset-confirmed; not yet tried with BD22 VR): Replace Brutal Doom's Grenade (off).
- **Since the headset pass** (rig-tested, headset check pending): shooting thrown grenades and the Shot Grenade Reach
  slider, the teeth pin pull measured from your real eyes, grenade types without Gun Bonsai.

Part of the Radiant Silvergun Quest series for stock QuestZDoom 17.3. ZScript only, no engine changes. On plain Doom 2
it adds its own grenade. With Brutal Doom 22 VR Reloaded loaded it stands down completely and BD22 VR's own grenade
takes over, unless Replace Brutal Doom's Grenade is on.

## Standout feature: the pin, the spoon and your teeth

Hold the grenade and squeeze its trigger: that is your grip on the spoon. Reach your other hand to the ring at the
top, pull its trigger, and draw it away. The pin is out, with the clink of the pin and a buzz in that hand. Or skip
the other hand entirely: bring the grenade to your mouth, keep squeezing, and hold it there for a moment. You pull
the pin with your teeth.

Now let go. If your arm is swinging, the grenade leaves at the speed and direction of your swing, measured against
your body, so walking and turning never count as a throw. If your hand is still, the spoon flies off and the fuse
lights in your hand. The grenade flashes red with a tick on every flash, faster and faster as the fuse runs down.
Squeeze and let go again to throw it. Hold it too long and it goes off in your hand.

Changed your mind before cooking it? Take the ring again with your other hand and the pin goes back in.

## Features

**Handling**
- Ring pull with the other hand, or the pin pulled with your teeth from your real mouth position (read from the
  headset, lips to just under the chin).
- Squeeze-and-release throwing at your arm's own speed, with a natural arc and your running speed carried into it.
- Cooking: the spoon flies, the fuse burns in your hand, and the red flash and tick speed up to the end.
- Either hand can hold it. The grenade model mirrors correctly in a left hand, ring to the thumb.
- Switch away with the spoon still on and the pin goes back in. Switch away while it cooks and it goes off.

**In the air and on the floor**
- Bounces off floors, walls and monsters, tumbles, then settles on its side and slides to a stop. Only the fuse sets
  it off.
- Shoot thrown grenades: your bullets or projectiles passing within 0.35 m (Shot Grenade Reach: tighten it down to 0.10 m) of a thrown grenade set it off on the spot,
  in the air if you are quick. Punches never do, and a grenade is safe for its first 6 tics out of the hand. Only the
  ray of the hand that fired counts. In co-op anyone can shoot anyone's thrown grenade, and the shooter gets the kill.
- Optional: only while the world is slowed by RSQ SlowMo (off by default).
- Thrown grenades slow down with RSQ SlowMo like everything else. Optional: let them run faster than the slowed world
  (off by default).

**Eight grenade types**
- The holding hand's alt fire cycles the types until the spoon flies. The grenade's colour shows
  which one you hold.
- **Frag**: the full blast. **Impact**: bursts on the first thing it touches. **Incendiary**: a blast, then burning
  ground for a few seconds. **Freeze**: freezes monsters in the blast (bosses are immune). **Stun**: half damage, and
  monsters reel in pain. **Smoke**: a cloud that blinds any monster inside it or looking through it. **Flash**: a
  bright burst that staggers monsters and makes them lose you. **Charm**: monsters in the blast fight for you for a
  while. **Infight**: they turn on each other. Charm and Infight never work on bosses.
- Without Gun Bonsai every type is available from the start (or set Frag Only). With RSQ Gun Bonsai VR you unlock
  them on the grenade's own upgrade tree.

**Supply**
- You start with the grenade and 3 grenades. Carry 8, or 16 with a backpack.
- Single grenades and packs of three are scattered beside each map's items, up to 4 singles and 2 packs a map.

## Barrels

Every barrel in the map is still Doom's barrel: same health, same blast damage and radius, and it goes off on the same
tic after it is hit, so chain reactions run at the stock pace. Only the look and the sound change.

**What you see.** Hit a barrel: it stands for a moment, then blinks white-hot five times (lit, dark, lit, dark, lit)
and is gone in one of six explosions, each centred on the barrel: a big flash about 24 units up (a solid white frame,
then the fireball, rolled at random), three flat light pops at its foot, three smaller bursts climbing the barrel one
tic apart, pixel embers thrown up, debris that bounces, skids, settles and cools before it blinks out, a ring
spreading flat across the floor, a floor light that steps down in bands, and blocky smoke. All pixel art, drawn
nearest-neighbour. A clatter plays when the first debris lands.

| # | Name | Its look |
|---|---|---|
| 5 | Snap | A quick ring flash, three yellow-brown fireballs, a light spray of hot bits that cool to charcoal |
| 6 | Heavy | A huge circular fireball, a pastel cap ring, a red fireball choking to dark smoke; fat glowing chunks and dark barrel shrapnel that thud down |
| 7 | Pillar | A yellow flash, then a column of blasts climbing above the barrel to a fire-ring crown and smoke; bits flung high that rain back |
| 8 | Groundbreaker | A shock sphere and a shockwave running out flat with a dust ring and an ember scorch; grit skittering along the floor and rock chunks |
| 9 | Slag Column | A dirty white blob choking to smoke, brown fireballs, heavy soot billowing up into a thin rising column; dust bits |
| 10 | Neon Crescent | Arcade neon: a pink star pop, two crescents (pink and gold) flying apart with after-images, star pops, purple soot; pink and gold bits that twinkle |

**Sounds** (RS Combat FX): its three barrel explosions, layered with a low, pitched-down second copy, plus a distant
explosion on its own channel and a small metal clatter. **Barrel Sound: Test Candidate** swaps the three near blasts for
the owner's test sound (ST0E_U0_00001, its last 0.35 s faded out), layered the same way; the distant blast and the
clatter stay.

**Options** (on the main page, under Barrels): **Barrels** (On; Off = the stock barrel, untouched), **Explosion**
(Random, or always one of the six), **Barrel Sound** (Combat FX / Test Candidate), **Replace Brutal Doom's Barrels** (Off). Debris, colour, lights and the room's
contexts are under Explosions (below). Test and Debug: **Effects Cap** (600 effect pieces alive at once, barrels and
grenades together; past it a blast shows only its first-tic flash, so a long chain reaction stays cheap on Quest).

**With Brutal Doom** (BD22 VR Reloaded or any Brutal Doom with its `ExplosiveBarrel1`): by default these barrels stand
down and Brutal Doom's barrels are its own. With Replace Brutal Doom's Barrels on, ours take over both Doom's barrel
and Brutal Doom's `ExplosiveBarrel1`; Brutal Doom's own barrel extras go with it (a replaced barrel is a stock barrel
with our look), and any other barrel-like thing Brutal Doom spawns under another name stays its own. Both rows act on
barrels as they spawn: change them, then start a map (Barrels Off also turns standing barrels back to the stock death).

Other series mods keep seeing these as barrels (Melee's barrel kicks, SlowMo's barrel cues, Distance Grab's barrel
grab): the barrel is a subclass of Doom's.

## Explosions

Every barrel and every grenade blast (owner, 11-09: "options for explosion customization like colors and reactivity
and context"). The look only: no option here changes damage, radius or timing.

**The new grenade blast** (the owner's approved design, "very pleased with all four grenade tosses"). A white 8-point
crack star, then the same star as a 2-tic solid white silhouette, opening into a white ball and ring; the star's eight
points flung out as hard lines; 44 hard pixel shrapnel streaks out to 200-255 units in about five tics (white-hot
heads, stepping to orange as they slow), each that hits the floor leaving a spark and a hot pepper mark that cools to
a dark speck, and ricocheting off any wall in its way; two shock rings at 200 and 255 units (the reach of the
grenade's two damage parts), flat on the floor when it went off on the floor, upright in the air; a second, smaller
crack at tic 6; three small fast child bursts; pixel embers; hot debris that bounces, settles and cools; blocky smoke.
**Shot out of the air** it adds the gold reward beat: a gold crosshair ring locking on, a gold fireball ring and gold
embers raining down. **Impact** and **Incendiary** grenades show it in their own colour (the other kinds keep their
own look, unless Explosion Colour is Grenade Kind).

**Explosion Colour** (barrels and grenades): **Normal** (fire; the Impact and Incendiary grenades in their colour),
**Room Complement** (the colour opposite the room's RSQ Glow In The Dark glow, read from the floor's glow at the blast;
Normal without Glow In The Dark or in a room with no glow), **Kill Colour** (the blast turns the tier colour of the
highest-tier monster it kills, the moment the kill lands; RSQ Monsters' ladder; Normal without RSQ Monsters),
**Grenade Kind** (every grenade kind shows the new blast in its colour, beside its own effect). The white flash stays
white in every mode.

**Explosion Lights**: **Full** (stepped beats: a white-yellow punch on the flash, then the fire's colour while the
blast burns, then a dim red glow while the embers fall, then off; the colour follows Explosion Colour and the room:
pale cold blue under water, the liquid's colour over nukage, lava or blood), **Simple** (the punch only), **Off**.
One light a blast, at most 8 at once, no shadow maps.

**Debris**: how much of each blast's debris is thrown (1.0 all, down to 0).

**Contexts** (a master switch, then a row each). The room bends the blast it is in; each is a change to the blast,
never a different blast.
- **Wall** (a wall within 40 units of the blast): the blast fans out along the wall, its fire pushed off the face
  with a sheet of fire pressed flat on the wall, hot runs up and down the face (barrels), smoke drifting away, and a
  scorch that glows, cools to soot, and fades away after a few seconds. Shrapnel ricochets off walls whatever this row says.
- **Low Ceiling** (floor to ceiling under 96 units, not sky): fire and smoke can't rise through it: they flatten and
  spread under it, fire rolls along it, smoke pools under it, soot is left on it.
- **Open Sky**: the column keeps climbing and a column of dark smoke stays standing.
- **Water** (the blast fully under water): a white flash and no fire; gas bubbles and a gas dome rising, a muffled
  pressure ring, silt kicked off the floor, murk; the grenade's shrapnel stopped short in pale streaks trailing bubbles.
- **Liquid Floors** (nukage, lava, blood, by the floor's flat): a crown of drops and a tall spout of the liquid, crest
  waves running out, blobs that plop and sink, a stain left on the floor; the light in the liquid's colour.
- **Chain**: a barrel set off by another barrel's blast is one link further down the chain.
- **Crowd**: a blast that kills 3 or more monsters -- each of those deaths gets a gib burst (a blood burst, chunks and
  bits, the body's one-tic white pop). Its slow motion is RSQ SlowMo's own (its Barrel Multi-Kill and Grenade Blast
  cues); this row starts none.

**Chain Escalation**: down a chain each barrel blows bigger (#5, #5 x1.25, #6, #6 x1.2, then the finale: the
owner's mega blast, MEGA2) and blinks shorter (10, 8, 6, 6, 4 tics). It stands
longer instead, so every barrel still goes off on the stock tic. **Screen Kick on Chains**: a small, short quake from
the third link on; never with RSQ Accessibility's Photosensitive Mode or a Comfort Vignette.

**Grenade Explosion: New / Original**: Original brings back the UAC Survival Pack blast the grenade had before.

**What the game draws differently from the approved mockups** (each the nearest honest equivalent):
- The shock rings, the star rays, the liquid's crest waves, its stain and the ceiling soot are drawn once per tic into
  sprites at 2 map units a pixel (the mockups' are 0.8): a 1-pixel ring 200 units out would vanish in a headset.
- Shrapnel, the floor pepper, the ricochet sparks and the bubbles are particles: square only if your Particle Style
  is Square. A floor ring is a circle lying flat on the floor, not the GIF's squashed oval.
- Debris stops at a wall instead of bouncing back off it.
- Wall: the blast is not folded pixel by pixel at the wall plane: it fans along the wall, its fire is pushed off the
  face and copies of its first fire layers lie flat on the wall (wall sprites); the scorch is two decals (a hot glow
  that fades, the soot that stays 8 seconds and then fades out over 6).
- Low Ceiling: a layer that would rise into the ceiling is held under it, flattened and widened; it is not folded.
- Water: no surface splash and no bubble pops at the surface (stock calls cannot find the surface above a blast).
- Liquid Floors: the four fat jets are not drawn (the late spout stands in for them).
- Crowd: the corpse stays (the gib is drawn over it); its bits are blood red only (the monster's own colours would
  need its sprite's pixels); no held-frame slow motion or flat flash here (RSQ SlowMo owns the time).
- The barrel overlays (ceiling, sky, wall runs, liquids) were designed on barrels; on a grenade they play smaller.

## How To Play

1. Add RSQ_Grenade.pk3 to your load order and play in VR. Skip it if you play with BD22 VR Reloaded: its grenade does
   all of this already (or turn on Replace Brutal Doom's Grenade to use this one instead).
2. Select the grenade from slot 9 (or grab it from the RSQ Tactical Rig's belt spot).
3. Hold your main trigger. Bring your off hand to the top of the grenade, pull the off-hand trigger, and draw the hand
   away. You feel the pin go.
4. Swing your arm and let go of the trigger in mid-swing. Watch it arc.
5. Next one: pull the pin, then let go with your hand still. The spoon flies and it starts to flash. Count the ticks,
   then throw it with a squeeze and a swing. Cooked right, it bursts as it lands.
6. Try the teeth: grenade to your mouth, squeeze, hold it there half a second.
7. Tap your alt fire while holding it (pin in) to try the other types.

## Controls

| Action | How (VR) | Notes |
|---|---|---|
| Squeeze the spoon | Holding hand's trigger, held (or grip and trigger together) | Let go of both to release |
| Pull the pin (ring) | Other hand's trigger within 12 cm of the ring, then draw the hand 8 cm further away | A buzz in the pulling hand |
| Pull the pin (teeth) | Squeeze (trigger, or alt fire) and hold the grenade at your mouth for 12 tics | Within 0.15 m of your mouth. After a pull, move it clear of your mouth or let go before the next |
| Put the pin back | Other hand's trigger at the ring again, before the spoon flies | |
| Throw | Let go of the trigger while swinging at 2.5 m/s or more | After cooking, any release throws |
| Cook | Let go of the trigger with the hand still | The fuse (3 s) starts in your hand |
| Change type | Holding hand's alt fire, pin in | Not at your mouth (there it is the teeth's squeeze); with the pin out alt fire is the squeeze |
| Shoot a thrown grenade | Shoot it | Your shots and projectiles; never melee |

- Holding hand means whichever hand has the grenade; the other hand pulls the ring. Fire and alt fire are read for
  each hand as the engine maps them (main trigger and off-hand trigger).
- On QuestZDoom's default button mapping, grip plus trigger sends alt fire. That counts as the squeeze everywhere: on
  the spoon as well as for the teeth.

## Menu

Options → Radiant Silvergun Options → RSQ Grenade. One page, and one sub menu, **Test and Debug**. With RSQ Gun Bonsai VR
loaded the page starts with "GunBonsaiOVR detected. Mod features unlocked via upgrades."; Skeet Slow-Mo is greyed until
the Skeet Window upgrade is learned, and Grenade Types is greyed until you learn a grenade type (then All Types gives
the types you have learned, Frag Only the frag alone).

| Row | Default | What it does |
|---|---|---|
| **Grenades** | | |
| Grenades | On | The grenade, all of it (it stands down with BD22 VR Reloaded unless the next row is on); the barrels have their own row |
| Replace Brutal Doom's Grenade | Off | With BD22 VR Reloaded loaded, this grenade stays and BD22 VR's own stands down (BD22 VR 2.0.3y reads this setting by name; its own "Use RSQ Grenade Instead" row does the same) |
| Start With | 3 | Grenades at a new game, or after dying (0-8) |
| Grenades in Levels | On | Grenades beside each map's items |
| Singles a Map | 4 | Most singles a map |
| Packs of Three a Map | 2 | Most packs a map |
| **Throwing** | | |
| Pin With Your Teeth | On | The mouth pin pull |
| Alt Fire Changes Type | On | Alt fire cycles the grenade types |
| Grenade Types | All Types | All Types or Frag Only (with Gun Bonsai VR, All Types = the types you have learned) |
| Your Fire Burns You | Auto | Incendiary ground hurts you: Auto (Brutal Doom: yes), Yes, No |
| **Barrels** | | |
| Barrels | On | Our barrel: the blink and the six explosions (Off: the stock barrel) |
| Explosion | Random | Random, or always #5 Snap, #6 Heavy, #7 Pillar, #8 Groundbreaker, #9 Slag Column, #10 Neon Crescent |
| Barrel Sound | Combat FX | Combat FX (RS Combat FX's barrel blasts) or Test Candidate (the owner's test sound, faded out) |
| Replace Brutal Doom's Barrels | Off | With Brutal Doom loaded, ours replace its barrels (off: its barrels stay its own) |
| **Explosions** | | |
| Grenade Explosion | New | New (the approved pixel-art blast) or Original (the UAC Survival Pack's) |
| Explosion Colour | Normal | Normal, Room Complement (RSQ Glow In The Dark), Kill Colour (RSQ Monsters), Grenade Kind |
| Explosion Lights | Full | Full (stepped), Simple (one flash), Off |
| Debris | 1.0 | How much of each blast's debris is thrown, barrels and grenades |
| Contexts | On | The room bends the blast (the seven rows below); Off: every blast as in the open |
| Wall | On | Fans along a near wall, a fire sheet on it, a scorch |
| Low Ceiling | On | Held and spread under a low ceiling, soot |
| Open Sky | On | A taller column, smoke that stays |
| Water | On | Under water: a white flash, bubbles, no fire |
| Liquid Floors | On | Nukage, lava, blood: drops, waves, a stain |
| Chain | On | A barrel set off by another barrel is a chain link (the next two rows) |
| Crowd | On | A blast that kills 3+: gib bursts (the slow motion is RSQ SlowMo's Barrel Multi-Kill) |
| Chain Escalation | On | Each link bigger, its blink shorter (the blast keeps stock timing) |
| Screen Kick on Chains | On | A small quake from the third link (never with Photosensitive Mode or a Comfort Vignette) |
| **Shooting** | | |
| Shoot Thrown Grenades | On | Shots set off thrown grenades |
| Only in Slow-Mo | Off | ...only while RSQ SlowMo has the world slowed |
| Faster in Slow-Mo | Off | Thrown grenades run faster than the slowed world |
| Skeet Slow-Mo (Gun Bonsai VR) | On | Gun Bonsai VR's Skeet Window slow motion (nothing without that upgrade) |
| Reset All | | Every setting on both pages back to default |

**Test and Debug**: Fuse (3.0 s), Throw Speed (2.5 m/s), Throw Strength (1.0), Arc (0.35); Gravity (0.27), Floor Bounce
(0.5), Wall Bounce (0.25), Ground Drag (0.82), Shot Reach (0.35 m: 0.10 to 0.35, it only tightens), Slow-Mo Speed (0.5);
Teeth Mouth Reach (0.15 m), Again Beyond (0.71 m), Hold (12 tics); Explosions Effects Cap (600); Debug Log (Off); Reset All.

## Works with

Runs alone on plain Doom 2. It finds the others by name:
- **Brutal Doom 22 VR Reloaded**: RSQ Grenade stands down entirely (no grenade, no scatter, no start grenades);
  BD22 VR's own grenade is the one you use. With Replace Brutal Doom's Grenade on it is the other way round.
- **RSQ Tactical Rig**: without BD22 VR, the Rig's belt-buckle grenade spot hands out this grenade, shows it hanging
  there, and glows in the colour of the type in your hand.
- **RSQ SlowMo**: thrown grenades slow with the world (unless SlowMo is set to leave your own missiles in real time);
  Only in Slow Motion and Faster Grenades in Slow Motion read it. New on 11-06 (rig only, not headset-confirmed):
  getting up from DOWN (REVIVE) gives one grenade, up to your carry; with BD22 VR's grenade in use, one of Brutal
  Doom's. Since DOWN v3 (11-07, rig only, not headset-confirmed): only when you get up on the reward bar's top step.
- **RSQ Wheel** fans out the types you own; **RSQ Gun Cards** shows the fuse count with the Cook Sense upgrade;
  **RSQ Score** scores teeth pulls, shot grenades and impact bursts.
- **Gun Bonsai + RSQ Gun Bonsai VR**: the grenade levels like a weapon, with its own tree: the types, Short Fuse, Cook
  Sense, Teeth, Strong Arm, Flat Arc, Bounce, Sticky, Skeet, Skeet Window, Big Bang, Cluster, Bandolier and Scavenger.
  Freeze, Stun and Flash then use its freeze and stagger (a frozen monster shatters on the next hard hit); without it,
  this mod freezes and staggers on its own.
- **Brutal Doom** (without BD22 VR): Incendiary's burning ground hurts you too, on Auto. Its barrels stay its own
  unless Replace Brutal Doom's Barrels is on (with or without BD22 VR).

## Credits and licence

- **UAC Survival Pack** by JohnnyDoom: its hand grenade (original by Froon, Brutal Doom version by Saegiru, sprites by
  Pa1nki113r). Its sounds (blast, distant blast, pin, throw, spoon, bounce, tick), pickup and thrown sprites, explosion
  sprites and the explosion itself, its ammo rules and its random placement beside map items, rewritten in ZScript.
  Lumps renamed so no other mod's are replaced.
- **Gomuz**: the grenade model and skin (its red fuse-flash skin and the type colours are recolours).
- **presidentkoopa** (project owner): the handling, from his BD22 VR Reloaded grenade (ring pull, spoon, swing throw,
  cook, cook-off; its held placement and measured ring point); his RS_Grenade (the teeth, the speeding red flash, the
  flight numbers, the blast damage and its port of the pack's explosion); the upgrade tree's effects and sounds from
  his RS Combat FX and RS Ballistics libraries.
- **The barrel explosions**: art from the owner's RS Combat FX (embers), Reactorcore's Explosion Spriteanim Sheet
  Minipack, Rufaswan's rips (sheet by Magma MK-II) and fx_sheet_2 (source unknown, #6 only); sounds from RS Combat FX and the owner's test candidate (ST0E_U0_00001);
  the barrel-death structure after End of Starchild (none of its art). CREDITS.txt has every source per explosion.
- Generated for this pack: transparent placeholder sprites; the barrel debris bits.
- **QuestZDoom** (Emawind and Team Beef): the engine, and its off-hand weapon and hand-pose API.

Every base sound is the UAC Survival Pack's own recording; nothing is synthesized.

Free to share as part of the Radiant Silvergun Quest series. Borrowed assets keep their authors' terms; sharing other
people's work in this pack is the project owner's decision.
