# RSQ_TacticalRig — the Ultimate Badass Ermac Rig

Weapons carried on your body, doors you lift open by hand, and Ermac's cigarette.
For **stock QuestZDoom 17.3**: ZScript and lumps only, no engine changes. Part of the
Ultra Badass Quest series ([RSQ_UBQSeries](https://github.com/presidentkoopa/RSQ_UBQSeries)).

Built on **Ermac's** idea: his Virtual Tactical Vest for Doom VR. This is a new
implementation that reads the real hand poses, keeps the rig on your body rather
than your head, and carries a whole arsenal per region.

## Carrying weapons

Nine places on the body. Each holds the Doom weapon slots set for it (menu: *Where the
places are*, "Holds slots"); the defaults:

| Place | Where | Holds |
|---|---|---|
| Left hip, right hip | belt line, each side | slot 2 (pistols, small arms) |
| Left pectoral, right pectoral | high on the chest, each side | slot 0 (grenades, small things) |
| Chest | the sternum | slot 3 (shotguns) |
| Stomach | below the chest | slot 4 (rifles, chainguns) |
| Left shoulder | behind the shoulder | slots 5-6 (launchers, plasma, railgun) |
| Right shoulder | behind the shoulder | slots 7-9 (BFGs, nukes, flamers) |
| Lower back | the small of the back | slot 1 (melee: axe, chainsaw; never the fists) |

- **Holster:** bring the gun into its region and grip (or press Use). Your hand is left
  empty: the fists (Brutal Doom's own fists with Brutal Doom).
- **Draw:** reach into a region with an empty hand and grip or Use. One weapon there
  comes to your hand; with several, a small **radial** of their pickup sprites opens
  round your hand: move toward one and let go.
- **Feedback:** a wireframe sphere shows each region (blue, green with your hand inside;
  menu: never / near / always), every region shows what it holds as the weapon's own
  pickup (its sprite, voxel or 3D model), a holster sound and a rumble on the right
  controller.
- The regions stay on your **body**: looking around does not swing them, snap and smooth
  turns carry them. Holding your head far round for a couple of seconds counts as your
  body having turned, and they swing round under you.
- **Fit it to you:** *Measure my height* (stand straight, look ahead) scales the whole
  rig to your eye height. *Move the regions with your hands*: turn it on, grip in a ring,
  carry it to where your hand naturally goes, let go; it's saved. Turn it off to play.
  Each region also has menu sliders.
- A hand only acts on a region after it has been there a moment (3 tics), so a hand
  passing through a holster on its way somewhere else does nothing.
- A hand steadying the main gun (the engine's two-handed grip) never fires a region.
- With RS_ShieldSawQ loaded, the off shoulder is left to the shield while it hangs there.
- With UltraBadassQuestSaber loaded, the saber's hilt clips to either hip (menu).

## Lifting doors

Put a hand flat on a door and take hold (the **grip**, **Use**, or a **palm turned
out** against it — each can be switched off), then lift. The door rises with your
hand (capped, so a flick can't fling it open; wider doors are heavier). Let go past
the **commit point** (40% open by default) and the door finishes opening by its own
special: it waits and closes as that door always did. Let go before it and the door
drops shut. Locked doors need their key (you get the normal message). Pressing Use on
a door you're touching takes over the engine's own just-started opening, so Use lifts
too. Manual doors only (Doom's ordinary doors).

## Ermac's cigarette (optional, off by default)

Turn on **Cigarettes** in the menu. A pocket on your left chest holds a few
(default 3, refilled each level).

- **Take one:** reach to the pocket and grip (or Use). Put it back the same way.
- **Light it:** hold it at your mouth a moment. Or turn on **the Zippo**: reach to the
  same pocket with your other hand and keep the grip held; Ermac's Zippo flicks open,
  and holding its flame to the tip at your mouth lights it. Let go and it snaps shut.
- **While it burns** (6 s by default) the world slows, if **RSQ_SlowMo** is loaded.
- Ermac's originals: smoking at your mouth heals you slowly under 35 health, and a
  butt flicked away (grip again while swinging your hand) smoulders where it lands and
  draws monsters to it — and into each other. Burnt down, it drops from your hand.

## The torso (optional)

Options → Tactical Rig → *Wear a torso*: the Doom marine's torso (the default) or Quake's
Grunt (see Credits) on the rig's body, for your holsters to sit on. It turns green or blue with your armour and breathes red at low health. Sliders move
and size it.

## Install

Load after your weapon pack. Tested order:
`doom2.wad -> brutal22test6 -> BD_VoxelPack -> the series, any order`.
Settings: **Options → Tactical Rig** (with a reset row).

## For other mods

`RSQTR_RigService` (a `Service`, found by name): `GetInt("rig.region", "", hand)` is the
region a hand is in (or -1); `GetInt("rig.busy", "", hand, 0, pawn)` is 1 while a hand is
in a region or its radial, or holds a door, the cigarette or the Zippo. Both answer for
the console player only. RSQ_DistanceGrab already asks `rig.busy`.

## Credits

- **Ermac**: the vest and the cigarette are his ideas (Virtual Tactical Vest). The
  cigarette, butt and smoke come from that mod, whose credits name him as their modeller;
  the cigarette's texture is an atlas it shares with a Sketchfab cigarette-pack model (a real
  brand's pack art, blanked out here). The Zippo is the voxel lighter from his ZBlood-VR,
  credited to him there.
- **The marine torso** is the Doom Eternal Classic Slayer (id Software): a rip shared on
  Sketchfab, cut to torso and shoulder pads and recoloured green / blue / red in the project
  owner's RS_VRBody (provenance in its `models/marine/PROVENANCE.md`); skins halved to 1024
  here for the Quest.
- **The Quake torso** is Quake's Grunt (id Software, *Quake*, 1996): Vittorio Romeo's original
  Quake VR mod cut it into a torso, and the project owner's RS_VRBody recoloured its skin.
  It is id Software's mesh, not an authored model; converted here from Quake's .mdl to MD3.
- Sharing other people's work in this pack is the project owner's decision.
- The region spheres are the project owner's, from his RS_Holsters.
- Holster, draw and foley sounds: RS_CombatFX (the project owner's effects library).
- The Zippo and cigarette sounds and the region ring are generated (`tools/`).
- QuestZDoom: Emawind and Team Beef.
