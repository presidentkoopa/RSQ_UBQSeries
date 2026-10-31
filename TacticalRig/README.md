# RSQ_TacticalRig — the Radiant Silvergun Quest Ermac Rig

Guns holstered on your body, spots for the saber, a torso and helmet, a mirror, and Ermac's
cigarette. For **stock QuestZDoom 17.3**: ZScript and lumps only, no engine changes. Part of the
Radiant Silvergun Quest series ([RSQ_UBQSeries](https://github.com/presidentkoopa/RSQ_UBQSeries)).

Built on **Ermac's** idea: his Virtual Tactical Vest for Doom VR. This is a new implementation
that reads the real hand poses and keeps the rig on your body rather than your head.

## Holsters

Six gun holsters, **both hips**, **both sides of the chest** (cross-draw) and **both shoulders**, and two **saber spots** just below the
hips (with RSQ_Saber loaded).

- **A holster holds exactly the gun you put there**, one gun, never chosen for you.
- **Holster:** reach to a holster with a gun in your hand and grip (or press Use). The gun goes
  in and your hand is left empty (the fists; Brutal Doom's own fists with Brutal Doom). If the
  holster already held a gun, the two **swap**: that one comes to your hand.
- **Draw:** reach to a full holster with an empty hand and grip (or Use).
- **Each hand holsters and draws its own gun.** The engine's own *switchhand* moves a gun
  between your hands; the off hand then holsters it and draws into itself the same way.
- **Dual is left to its own key** (Brutal Doom Quest's Dual): the rig does not move the off-hand
  copy. *Draw Pairs* (Never by default) can bring it along again.
- **Saber spots:** the main saber's spot is on your main-hand side's opposite hip (the left for
  a right-hander), the second saber's on the other.
- **Left-handed:** QuestZDoom's Control Scheme decides which controller is your main hand, and
  everything a hand owns follows it (saber spots, the shield's shoulder, rumble, the mirror). With
  RSQ_Accessibility, its Handedness sets that scheme and also mirrors what no hand owns: the
  cigarette pocket and the way stored guns hang. Each saber shows in its spot whenever it is
  not in its hand. A saber put on an empty holster goes to its own spot.
- **Doors** are no longer the rig's: they moved to RSQ_DistanceGrab.

**Grenade spot** (the belt buckle): grip it with either hand and your pack's hand grenade comes to your main hand --
with Brutal Doom VR, its VR grenade (the off hand pulls the pin, you throw it by hand). Grip it again to put it back
and get your gun. Its light is your grenade count: green 2+, yellow 1, red none.

**Throw a gun away:** grip with the hand swinging fast, outside every holster: the gun flies from that hand and lands
as a pickup you can take again (*Throw Swing Speed*).

**Keyring:** the keys you carry hang on a steel ring on the front of your belt, off-hand side, as the keys themselves.

**Quick swap, kept holsters, ammo light, new guns to a holster:** see *Rig Options*.

**Feedback:** a wireframe sphere shows each holster when a hand is near (or always; *Holster
Rings*), green with your hand inside; its idle colour is the holster profile in use. The gun
stored there shows as its pickup model, at a pistol's length on the hips and longer over the
shoulders, hanging as worn (hips muzzle down; shoulders on the back, butt up). Only guns measured
into the `RSQTRFIT` table (by `tools/measure_pickups.py`, for brutal22test6 -> BD_VoxelPack ->
BD22Q) are shown. A sound and a rumble mark each holster and draw.

**Details:**
- A hand acts only after it has been in a holster a moment (*Press Delay*, 3 tics), so a hand
  passing through does nothing. A hand steadying the gun (the engine's two-handed grip) never
  fires a holster.
- The holsters stay on your **body**: looking around does not swing them, snap and smooth turns
  carry them, and a head held turned past 35 degrees for 1 s counts as your body turning.
- With RS_ShieldSawQ loaded, the off shoulder is left to the shield while it hangs there, unless
  the ShieldSaw draws by its key only.

## Fit it to you

- **Seated:** for playing sitting down. Standing, the rig hangs from the game's view height,
  which stays put when you sit; seated, it hangs from your seated eyes (the highest your
  headset has been lately, so leaning to reach does not pull the holsters down), and the torso
  and helmet come down with it.
- **Measure My Height** (stand straight, look ahead) scales the whole rig to your eye height.
- **Move Holsters by Hand:** turn it on, grip in a sphere, carry it where your hand naturally
  goes, let go; it's saved. Turn it off to play. *Holster Positions* has sliders for each.
- **Holster Profiles:** four (Standing A blue, Standing B orange, Seated A purple, Seated B
  yellow), each keeping every holster's position and size, on this machine only.
- **Mirror:** a copy of you about a metre out (while moving holsters, or always), showing your
  front, your back or both: the torso, the helmet, every holster, what it holds and your hands.
  Only you see it.

## Torso and helmet (optional)

- **Torso:** the Doom marine's (default) or Quake's Grunt, worn on the rig's body. Green or blue
  with your armour, breathing red at low health, fading as you look down (*Torso Fades Looking
  Down*). *Torso Fit* moves and sizes it.
- **Helmet:** with the marine torso. It sits on your head and turns with it, and only mirrors
  draw it (the rig's mirror, or a real mirror in a map): your own view never does.
- **In a map's mirror,** with the torso on: the guns and hands you hold are shown too (a copy
  of each, seen only in mirrors, posed as the game draws it in your hands), and the sprite
  marine steps out of the mirror so you see one body. Guns and hands drawn as flat sprites are
  not copied; Brutal Doom Quest's hands sit where your controller is (its per-gun hand moves
  happen at draw time, where a mod cannot read them).

## Ermac's cigarette (optional, off by default)

Turn on **Cigarettes**. A pocket on your left chest (the right, left-handed) holds a few (3, refilled each level).

- **Take one:** reach to the pocket and grip (or Use). Put it back the same way.
- **Light it:** hold it at your mouth a moment. Or turn on *Zippo Lights It*: reach to the pocket
  with your other hand and keep the grip held; the Zippo flicks open, and its flame on the tip at
  your mouth lights it. Let go and it snaps shut.
- **While it burns** (6 s) the world slows, if RSQ_SlowMo is loaded.
- Ermac's originals: smoking heals you slowly under 35 health, and a butt flicked away (grip
  again while swinging your hand) smoulders where it lands and draws monsters to it, and into
  each other.

## Install

Load after your weapon pack. Tested order:
`doom2.wad -> brutal22test6 -> BD_VoxelPack -> the series, any order`.
Settings: **Options → Radiant Silvergun Options → RSQ Tactical Rig** (reset under *Tuning and Debug*).

## For other mods

`RSQTR_RigService` (a `Service`, found by name):
- `GetInt("rig.region", "", hand)`: the holster a hand is in, or -1 (console player only).
- `GetInt("rig.busy", "", hand, 0, pawn)`: 1 while a hand is in a holster, holds a Distance Grab
  door, the cigarette or the Zippo (console player only). RSQ_DistanceGrab asks it.
- `GetInt("rig.drawtic", "", 0, 0, pawn)` / `GetString("rig.drawn", "", 0, 0, pawn)`: when that
  player last drew from a holster this map (or -1) and what came out. Synced, for any player.

## Credits

See [CREDITS.txt](CREDITS.txt) (shipped in the pk3).

- **Ermac**: the vest and the cigarette are his ideas (Virtual Tactical Vest). The cigarette,
  butt and smoke come from that mod, whose credits name him as their modeller; the cigarette's
  texture is an atlas it shares with a Sketchfab cigarette-pack model (a real brand's pack art,
  blanked out here). The Zippo is the voxel lighter from his ZBlood-VR, credited to him there.
- **The marine torso** is the Doom Eternal Classic Slayer (id Software): a rip shared on
  Sketchfab, cut to torso and shoulder pads and recoloured green / blue / red in the project
  owner's RS_VRBody (provenance in its `models/marine/PROVENANCE.md`); skins halved to 1024
  here for the Quest.
- **The helmet** is the Doom Eternal Classic Slayer's helmet (id Software), a rip, prepared
  (shell, visor, interior; green / blue / red skins) in the project owner's RS_VRBody
  (provenance in its `models/helmet/PROVENANCE.md`).
- **The Quake torso** is Quake's Grunt (id Software, *Quake*, 1996): Vittorio Romeo's original
  Quake VR mod cut it into a torso, and the project owner's RS_VRBody recoloured its skin.
  Converted here from Quake's .mdl to MD3.
- The holster spheres are the project owner's, from his RS_Holsters.
- Holster, draw and foley sounds: RS_CombatFX (the project owner's effects library).
- The Zippo and cigarette sounds are generated (`tools/gen_sounds.py`).
- QuestZDoom: Emawind and Team Beef.
- Sharing other people's work in this pack is the project owner's decision.
