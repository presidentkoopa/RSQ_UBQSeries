# RSQ Gun Cards

Holographic ammo cards that live on your guns, and a status card on your wrist when you check your watch.

**Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.**

Part of the Radiant Silvergun Quest series for stock QuestZDoom 17.3. Everything here is ZScript and data. No engine
changes.

## Standout feature: check your watch

Turn the back of your wrist to your face, the way you would check the time. A holo card lies flat on the back of that
hand: the rounds in the magazine and in reserve in big numbers, your grenades, and how many kills that gun has made
this level.

Do it with an empty hand and the card becomes your status: health, armour, and the keys you hold. It only shows the
key kinds this map actually uses, so you know at a glance whether you are hunting keycards or skulls.

The cards are drawn as part of the hand itself, in the same frame as the gun. They never lag, never float, never
swim behind a fast swing. Bending a stock engine to do that took every piece of every card, each digit and letter,
built as a voxel with its place on the wrist baked in.

## Features

**The small card**
- Rides beside each wrist: right of the main hand, left of the off hand.
- The rounds in the gun big, the reserve small and in gold.
- The magazine count turns green, yellow, then red as it runs down.
- An empty magazine with rounds to load flips between RELOAD and a red 0.
- Pick up ammo and a "+N" shows in the reserve's place for a moment.
- A cooking grenade (RSQ Grenade) shows its fuse seconds, amber then red.
- Shows always, when you look at the gun, on the inspect gesture, or while you hold reload. Your choice.

**The watch card**
- Weapon card: magazine and reserve, grenades, kills with this gun this level.
- Status card: health (red at 25 or less), armour, the keys you hold, grenades.
- Both on one card, if you prefer.
- Gun Bonsai's level, XP and upgrades under the weapon card (optional, off by default).
- Reads right way up whichever way your arm is turned.

**Look**
- Ermac's Force Unleashed holo panels, each gun its own colour by weapon slot.
- Or one colour for every card, or colour by ammo type: bullets gold, shells red, rockets orange, cells cyan, fuel
  green.
- Glass, glow or solid.
- Key icons from BD_VoxelPack's own key models when it is loaded.
- Text Quality: Quest (lighter) or PCVR (full resolution).

**Optional extras** (off by default)
- Draw in the World: the cards built in the world at your hand, so no gun model can ever cover them. They may trail a
  fast hand slightly.
- Tilt to Your Eyes: the small card turns toward your face.
- Hide at Your Eye: the small card steps aside while you aim down the sights or a scope.
- Both guns on the main hand's card.

## How To Play

1. Load the pk3. Nothing else is needed.
2. Pick up a gun. A small card appears beside your wrist with the rounds in the gun and the reserve.
3. Fire until the count turns yellow, then red. Empty it and watch it flip to RELOAD.
4. Bring your forearm up across your chest and turn the back of your wrist to your face. The watch card appears on the
   back of your hand.
5. Holster to your fists and check your watch again: health, armour and keys.
6. Prefer a cleaner view? Options → Radiant Silvergun Options → RSQ Gun Cards → Show Cards → When You Look at the Gun.

## Controls

There are no buttons. The cards answer to where your hands are.

| Action | How (VR) | Notes |
|---|---|---|
| Read the small card | Look at your wrist | Shows all the time by default. |
| Show the card by looking (Show Cards: When You Look at the Gun) | Bring the gun within 0.7 m of your eyes, within 30 degrees of where you look | Both numbers are sliders. |
| Show the card on reload (Show Cards: On Reload) | Hold that hand's reload, or the shared reload | Stays 35 tics after you let go. |
| Check your watch | Forearm across your chest, wrist 15 to 50 cm from your eyes and within 35 degrees of your view, hand pointing across your body, back of the wrist turned at least 45 degrees toward your face | With RSQ Gestures loaded, its inspect pose is used instead. |
| Status card | Check your watch with an empty hand or fists | With Draw in the World on, it is built in the world on the back of the wrist (keys as words, not icons). |
| Hide the small card when aiming (Hide at Your Eye) | Raise the gun within 0.30 m of your eye, pointing where you look | Off by default. |

Left-handed play is handled: the cards follow QuestZDoom's handedness setting and the mirrored left hand, and the R
and L labels follow the hands as you hold them.

## Menu

Options → Radiant Silvergun Options → RSQ Gun Cards

**Front page**

| Row | Default | What it does |
|---|---|---|
| Show Cards | Always | Off, Always, When You Look at the Gun, Inspect Gesture (RSQ Gestures; without it, as looking), On Reload. |
| Card Colour | Each Gun Its Own | Or By Ammo Type, or one of ten colours for every card. |
| Watch Card | When I Check My Watch | Off, When I Check My Watch, or Always On. |
| Watch Card Shows | Weapon Card | Weapon Card, Status Card, or Both on One Card. An empty hand always shows the Status Card. |
| Show Gun Bonsai on Card | Off | Gun Bonsai's level, XP and upgrades under the weapon card. |
| Text Quality | Quest | Quest or PCVR. |
| Small Card Font | JFO | JFO, or Ermac's own lettering and digits. |
| Draw in the World | Off | Cards built in the world at the hand. |
| Tilt to Your Eyes | Off | The small card turns toward your face. |
| Hide at Your Eye | Off | The small card hides while the gun is at your eye. |

**Placement**

| Row | Default | What it does |
|---|---|---|
| Small card: Up / Down | 0 | Degrees about the hand. |
| Small card: Left / Right | 0 | Degrees. |
| Small card: In / Out (cm) | 0 | Along the forearm, in 1.5 cm steps. |
| Watch card: Up / Down | 0 | Degrees. |
| Watch card: Left / Right (in the world) | 0 | Only with Draw in the World. |
| Size in the World | 1.40 | Only with Draw in the World. |

**Tuning and Debug**

| Row | Default | What it does |
|---|---|---|
| Both Guns on the Main Card | Off | The off hand's rounds in the main card's small row. |
| Panel (0 = each gun its own) | 0 | One of Ermac's 18 panels for every gun. |
| Material | Glass | Solid, Glass or Glow. |
| Strength | 0.85 | How solid glass or glow is. |
| Small Card Colours | Ermac's | Or the Wheel's palette. |
| AMMO / MAGAZINE Word | On | |
| Low Ammo Colour | On | The green, yellow, red magazine count. |
| Key Icons | On | On the status card. |
| Only This Map's Keys | On | Off shows all six keys. |
| Low Below (share of a magazine) | 0.25 | Red at or below this. |
| Fade (tics) | 4 | |
| Look: Gun Within (metres) | 0.70 | |
| Look: Within (degrees) | 30 | |
| Watch Check Shows | Once It Is Held | Or As the Twist Starts (RSQ Gestures). |
| Stays After (tics) | 35 | How long a card stays after the pose ends or reload is let go. |
| Tilt: At Most (degrees) | 20 | |
| Hide at Eye: Within (metres) | 0.30 | |
| Pickup +N Stays (tics) | 52 | |
| Show Hand Numbers on Screen | Off | The engine's hand data on screen, for a bug report screenshot. |
| Reset All | | Every setting back to its default. |

## Works with

Runs on its own with any weapon mod.

- **RSQ Gestures:** checking your watch, and Show Cards: Inspect Gesture, use its inspect pose.
- **Gun Bonsai with RSQ Gun Bonsai VR:** the watch card can show each gun's level, XP and upgrades.
- **RSQ Grenade:** its grenade count on the cards, and a cooking grenade's fuse countdown.
- **RSQ Wheel:** its palette, font and plates can colour the cards. Gun Cards' watch card replaces the Wheel's wrist
  card. The ring's card colours match Gun Cards'.
- **Brutal Doom / BD22 VR Reloaded:** Brutal Doom's grenade count, its magazines and reserves, its off-hand copies
  named as the gun they copy, and its off-hand fist counted as an empty hand. BD_VoxelPack's key models for the key
  icons.

## Credits and licence

- The cards are Ermac's Force Unleashed holo HUD, used with the owner's blessing: the ammo panels, the AMMO / MAGAZINE
  / CHAMBER words and the digits are his art, from his doom-force-unleashed devbuild. We turn them into voxels; the
  design is his. The cards drawn in the world are made from the same art.
- The text font is JFO, the JDUI font by Zedas, in the edit "JDUI Brutal Doom Ultimate Edition" by Blackmore1014
  (https://www.moddb.com/addons/jdui-brutal-doom-ultimate-edition). The glyphs are copied unchanged and turned into
  voxels. It ships with credit to Zedas and Blackmore1014 (owner's decision).
- Key icons: BD22_VoxelPack's key voxels seen from the front (keycards by Ghostpilot, skull keys by Voxelbro, per the
  voxel pack's credits) when the voxel pack is loaded; otherwise Freedoom's status-bar keys (freedoom2.wad, BSD
  licence).
- The cards in the world use the loaded IWAD's DoomFont and status bar by lump name.
- Code: ZScript written for the Radiant Silvergun Quest series (presidentkoopa), moved out of RSQ Wheel.
- Gun Bonsai is ToxicFrog's; the watch card only reads it, through RSQ Gun Bonsai VR, when loaded.
- QuestZDoom by Emawind and Team Beef.
