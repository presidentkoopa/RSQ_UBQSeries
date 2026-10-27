# RSQ_TacticalRig — the Ultimate Badass Ermac Rig

Weapons carried on your body, doors you lift open by hand, and Ermac's cigarette.
For **stock QuestZDoom 17.3**: ZScript and lumps only, no engine changes. Part of the
Ultra Badass Quest series ([RSQ_UBQSeries](https://github.com/presidentkoopa/RSQ_UBQSeries)).

Built on **Ermac's** idea: his Virtual Tactical Vest for Doom VR. This is a new
implementation that reads the real hand poses, keeps the rig on your body rather
than your head, and carries a whole arsenal per region.

## Carrying weapons

Six regions on the body, each holding one Doom weapon class:

| Region | Where | Holds |
|---|---|---|
| Left hip, right hip | belt line, each side | slot 2 (pistols, small arms) |
| Chest | across the chest | slot 3 (shotguns) |
| Chest (rifle) | chest centre, or the small of the back (menu) | slot 4 (rifles, chainguns) |
| Left shoulder, right shoulder | behind each shoulder | slot 5 and up (heavy weapons) |

- **Holster:** bring the gun into its region and grip (or press Use). Your hand is left
  empty (the fist).
- **Draw:** reach into a region with an empty hand and grip or Use. One weapon there
  comes to your hand; with several, a small **radial** of their pickup sprites opens
  round your hand: move toward one and let go.
- **Feedback:** a ring shows the region when your hand is near (menu: never / near /
  always), the last weapon you put there shows as its own pickup sprite, a holster
  sound and a rumble on the right controller.
- The regions stay on your **body**: looking around does not swing them, snap turns
  carry them. Each region's place and size is a menu slider.
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
  cigarette, butt and smoke models and textures are his, from that mod; the Zippo is his
  voxel lighter from ZBlood-VR (his own model, per its credits). The cigarette texture's
  pack artwork (from another model) is blanked out here. Sharing his work in this pack
  is the project owner's decision.
- Holster, draw and foley sounds: RS_CombatFX (the project owner's effects library).
- The Zippo and cigarette sounds and the region ring are generated (`tools/`).
- QuestZDoom: Emawind and Team Beef.
