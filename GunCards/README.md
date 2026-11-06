# RSQ Gun Cards

Holographic ammo cards that live on your guns, and a status card on your wrist when you check your watch.

**Status: 0.99 — played and confirmed working in the headset; refinement and bug fixing ongoing.**

New on 11-06 (rig only, not headset-confirmed): a card on every weapon; No Background; Card Glow; wider small-card
sliders; the looser watch check (RSQ Accessibility's Watch Check Twist, 35 degrees). Per-gun card spots: boots clean, not
rig-tested.

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
- Each gun can have its own spot (2026-11-06; boots clean, not rig-tested): Advanced on the Gun Cards page moves the
  card of the gun in your main hand (Up, Side, In) and saves that spot for that gun only, by its class, so every mod's
  guns get their own. Guns without one use the Placement sliders. Saved on this machine (setting `rsqgc_spots`), kept
  between maps, saves and sessions; in netplay your spots only move your own cards. Grab-and-drag by hand: not built yet
  (no free button; waiting on the owner's choice).
- The card can turn up / down and left / right (it swings round the wrist as it turns: that is how it is drawn), and
  slide in or out 6 cm along the forearm. It cannot roll, and cannot move further in or out, without new voxels.

**The watch card**
- Weapon card: magazine and reserve, grenades, kills with this gun this level.
- Status card: health (red at 25 or less), armour, the keys you hold, grenades.
- Both on one card, if you prefer.
- Gun Bonsai's level, XP and upgrades under the weapon card (optional, off by default).
- Reads right way up whichever way your arm is turned.

**Every weapon (2026-11-06; rig only, not headset-confirmed)**
- A weapon with no ammo to count (RSQ Saber, Whip, ShieldSaw, Melee's gloves, fists) shows the status card on the wrist on
  a watch check, and always with Watch Card: Always On.

**Look**
- Ermac's Force Unleashed holo panels, each gun its own colour by weapon slot.
- Or one colour for every card, or colour by ammo type: bullets gold, shells red, rockets orange, cells cyan, fuel
  green.
- Glass, glow, solid, or no background (only the text). Card Glow keeps the cards lit in the dark (off by default).
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
6. Prefer a cleaner view? Options → Radiant Silvergun Options → RSQ Gun Cards → Show Cards → When I Look.

## Controls

There are no buttons. The cards answer to where your hands are.

| Action | How (VR) | Notes |
|---|---|---|
| Read the small card | Look at your wrist | Shows all the time by default. |
| Show the card by looking (Show Cards: When I Look) | Bring the gun within 0.7 m of your eyes, within 30 degrees of where you look | Both numbers are sliders on Test and Debug. |
| Show the card on reload (Show Cards: On Reload) | Hold that hand's reload, or the shared reload | Stays 35 tics after you let go. |
| Check your watch | Forearm across your chest, wrist 15 to 50 cm from your eyes and within 35 degrees of your view, hand pointing across your body, back of the wrist turned at least 45 degrees toward your face | The gesture reader's watch-check pose is used instead (RSQ Accessibility's, or Gun Cards' own copy without it; back of the wrist turned 35 degrees since 11-06, was 45: Accessibility's Watch Check Twist); this looser pose only when that reader's watch check is switched off. |
| Status card | Check your watch with an empty hand or fists | With Draw in the World on, it is built in the world on the back of the wrist (keys as words, not icons). |
| Hide the small card when aiming (Hide at Your Eye) | Raise the gun within 0.30 m of your eye, pointing where you look | Off by default. |

Left-handed play is handled: the cards follow QuestZDoom's handedness setting and the mirrored left hand, and the R
and L labels follow the hands as you hold them.

## Menu

Options → Radiant Silvergun Options → RSQ Gun Cards (one page, then Test and Debug and Reset All at its foot)

| Row | Default | What it does |
|---|---|---|
| Show Cards | Always | Off, Always, When I Look, Inspect Gesture, On Reload. Inspect Gesture uses RSQ Accessibility's gesture reader when it is loaded, and Gun Cards' own copy of that reader without it. |
| Watch Card | When I Check My Watch | Off, When I Check My Watch, or Always On (the wrist card always drawn; an empty or melee hand shows the status card always). |
| Watch Card Shows | Weapon Card | Weapon Card, Status Card, or Both on One Card. An empty hand always shows the Status Card. |
| Gun Bonsai on Card | Off | Gun Bonsai's level, XP and upgrades under the weapon card (with Gun Bonsai). |
| *Look* | | |
| Card Colour | Each Gun Its Own | Or By Ammo Type, or one of ten colours for every card. |
| Small Card Colours | Ermac's | Or the Wheel's palette. |
| Small Card Font | JFO | JFO, or Ermac's own lettering and digits. |
| Text Quality | Quest | Quest or PCVR. |
| Material | Glass | Solid, Glass, Glow or No Background (the panel left out, only the text). |
| Card Glow | Off | Quest: the cards are fullbright (they keep their colours in the dark). PCVR: the same plus a small dynamic light at the hand (needs dynamic lights on). |
| Card Opacity | 0.85 | How solid glass or glow is. |
| AMMO Word | On | The AMMO / MAGAZINE word. |
| Low Ammo Colour | On | The green, yellow, red magazine count. |
| Key Icons | On | On the status card. |
| Only This Map's Keys | On | Off shows all six keys. |
| Both Guns on One Card | Off | The off hand's rounds in the main card's small row. |
| *Behaviour* | | |
| Draw in the World | Off | Cards built in the world at the hand. |
| Tilt to Your Eyes | Off | The small card turns toward your face. |
| Hide at Your Eye | Off | The small card hides while the gun is at your eye. |
| *Placement* | | |
| Small Card Up | 0 | Degrees about the hand, -60 to 60. |
| Small Card Side | 0 | Degrees, -60 to 60. |
| Small Card In | 0 | Along the forearm (cm), in 1.5 cm steps. |
| Watch Card Up | 0 | Degrees. |
| Watch Card Side | 0 | Only with Draw in the World. |
| World Card Size | 1.40 | Only with Draw in the World. |
| *Advanced: This Gun's Small Card* | | The gun in your main hand (named on the row under the header). |
| Up (pitch) | Placement's | Saves this gun's own spot. -60 to 60 degrees. |
| Side (yaw) | Placement's | -60 to 60 degrees. |
| In (cm) | Placement's | -6 to 6 cm in 1.5 cm steps (the card is built at those places; further is clamped). |
| Reset This Gun's Card | | This gun back to the Placement spot. |
| Reset All Saved Spots | | Every gun back to the Placement spot. |
| Reset All | | Every setting back to its default (the saved per-gun spots are kept: Reset All Saved Spots clears them). |

**Test and Debug**

| Row | Default | What it does |
|---|---|---|
| Panel (0 = per gun) | 0 | One of Ermac's 18 panels for every gun. |
| Low Below (share) | 0.25 | Red at or below this share of a magazine. |
| Fade (tics) | 4 | |
| Look: Reach (m) | 0.70 | When I Look: the gun within this many metres of the eyes. |
| Look: Cone (deg) | 30 | And within this many degrees of where you look. |
| Watch Check Shows | Once It Is Held | Or As the Twist Starts. |
| Stays After (tics) | 35 | How long a card stays after the pose ends or reload is let go. |
| Tilt: Most (deg) | 20 | |
| Eye Reach (m) | 0.30 | Hide at Your Eye: the hand within this distance of the eye. |
| Pickup +N (tics) | 52 | How long a pickup's "+N" shows. |
| Hand Numbers on Screen | Off | The engine's hand data on screen, for a bug report screenshot. |
| Debug Log | Off | One console line per kill the cards count. |
| Reset All | | Every setting back to its default. |

## Works with

Runs on its own with any weapon mod.

- **RSQ Accessibility (its gesture reader):** checking your watch, and Show Cards: Inspect Gesture, use its inspect pose (without it, Gun Cards' own copy of the same pose).
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
