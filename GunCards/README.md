# RSQ Gun Cards

Small ammo cards on your guns, in Ermac's Force Unleashed holo style. A small card sits beside the wrist
of each gun: rounds in the gun big, reserve small. Check your watch with a gun in hand and a full card
lies flat on both sides of that wrist: the gun's name, magazine and reserve, grenades, kills this level,
and (with Gun Bonsai) its level and upgrades. Check your watch with an empty hand and you get a status
card: health, armour, keys.

Pk3: `pk3/RSQ_GunCards.pk3` (about 13 MB).

## Load order

doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE ->
**RSQ_GunCards.pk3**

- Load it after your weapon pack. Needs no other RSQ pk3 to work alone.
- Plain Doom 2 without Brutal Doom: should work (nothing in the code needs Brutal Doom), but no note says
  it was run there. The grenade count reads Brutal Doom's hand grenades; without them RSQ Grenade's (when that pk3
  is loaded); absent with neither.
- With **RSQ_Gestures** loaded, the watch check is its knuckles-up wrist twist. Without it, the watch check is
  the forearm across your chest, wrist in front of your face.

## Setup

- No buttons. The cards show by themselves; the watch card on the watch check; "On Reload" uses your reload
  buttons.
- Menu: Options -> Radiant Silvergun Options -> **RSQ Gun Cards**. Pages: **Placement**, **Tuning and
  Debug** (Reset All is there).

## What to do in VR

- **Look at the gun**: bring it within about 0.7 m of your eyes and look at it (for "When You Look at the
  Gun").
- **Watch check, with RSQ_Gestures**: hold the gun up in front of your face, twist your wrist knuckles-up,
  hold a moment.
- **Watch check, without RSQ_Gestures**: bring the forearm up across your chest, wrist in front of your
  face, hand pointing across your body.
- **Status card**: the same watch check with an empty hand (fists).
- **On Reload**: hold that hand's reload.
- **Hide at Your Eye**: raise the gun to your eye as if aiming down sights.

## Features

Front page (RSQ Gun Cards):

| Row | Default | What it does |
|---|---|---|
| Show Cards | Always | The small card: Off / Always / When You Look at the Gun / Inspect Gesture (needs RSQ_Gestures; without it acts like When You Look at the Gun) / On Reload (while that hand's reload is held, then about a second). |
| Card Colour | Each Gun Its Own | Each gun its own colour by weapon slot, By Ammo Type (bullets gold, shells red, rockets and grenades orange, cells cyan, fuel green), or one colour for all. |
| Watch Card | When I Check My Watch | Off / When I Check My Watch / Always On. |
| Draw in the World | Option (off) | Cards drawn in the world at the hand, so no gun covers them (they can trail a fast hand). Off: drawn with the hand, no lag. |
| Tilt to Your Eyes | Option (off) | The small card turns toward your eyes (up to 20 degrees); it also swings a few cm round the wrist as it turns. |
| Hide at Your Eye | Option (off) | The small card hides while the gun is up at your eye. |

Always on (no row):

- **+N on pickup**: picking up ammo shows "+N" in the reserve's place for a moment.
- **RELOAD**: an empty magazine with rounds to load shows RELOAD instead of the count (on the watch card it
  replaces the MAGAZINE word).
- **Grenades** on the watch card: Brutal Doom's hand grenades (not mines), or RSQ Grenade's without Brutal Doom.
- **Kills this level** on the watch card: this gun's kills on this level (a kill goes to the hand that fired
  last within a second).
- **Status card**: watch check with an empty hand shows STATUS: health, armour, keys (cards on one line,
  skulls on the next), grenades, the level's kills. Only when Draw in the World is off.
- **Room light**: cards are lit like the gun, dim in a dark room.
- **Low ammo**: the count turns the empty colour when the magazine is at or below a quarter.
- Left-handed (QuestZDoom's left-handed schemes) works: the cards follow the hands.

Placement page: Up / Down, Left / Right, In / Out for the small card; Up / Down, Left / Right (in the world)
for the watch card; Size in the World.

Tuning and Debug page: Both Guns on the Main Card (off), Panel (0 = each gun its own; 1-18 one of Ermac's panels for all), Material (Glass),
Strength, Small Card Colours (Ermac's / Wheel Palette), AMMO / MAGAZINE Word (on), Low Ammo Colour (on),
Low Below, Fade, the look and watch-check distances and timings (Watch Check Shows: Once It Is Held),
Tilt: At Most, Hide at Eye: Within, Pickup +N Stays, Show Hand Numbers on Screen (off), Reset All.

## Test it

Load the order above plus RSQ_GunCards.pk3. Start MAP01 with a gun in each hand if you can. Gun Cards was
split out of the Wheel on 2026-10-31. The owner placed the cards himself, so their look and place have
been seen; the rest is marked.

1. Look at your main gun: a small card sits right of the wrist, left of it on the off hand. Rounds big,
   reserve small.
2. Fire until the magazine is low: the count turns the empty colour.
3. Empty the magazine with ammo in reserve: RELOAD shows in place of the count. (not yet headset-confirmed)
4. Pick up ammo: "+N" shows in the reserve's place for about 1.5 s. (not yet headset-confirmed)
5. Watch check with a gun (see "What to do in VR"). The full card lies on both sides of the wrist: name,
   MAGAZINE / RESERVE, grenades and this gun's kills this level. (grenades and kills: not yet
   headset-confirmed)
6. Kill something with that gun, check again: the kill count went up. (not yet headset-confirmed)
7. Watch check with an empty hand (fists): the STATUS card shows health, armour, keys. (not yet
   headset-confirmed)
8. Walk into a dark room: the cards dim with the gun. (not yet headset-confirmed)
9. Card Colour -> By Ammo Type: a shotgun's card is red, a rifle's gold. (not yet headset-confirmed)
10. Show Cards -> On Reload: no card until you hold reload; it stays about a second after. (not yet
    headset-confirmed)
11. Tilt to Your Eyes On: the small card turns to face you as you turn your wrist. (not yet
    headset-confirmed)
12. Hide at Your Eye On: raise the gun to your eye; the small card disappears. (not yet headset-confirmed)
13. Draw in the World On: cards move off the hand into the world; a fast swing makes them trail a little.
    The watch card's Left / Right slider (Placement) moves it. (not yet headset-confirmed)
14. Watch Card -> Always On: the full card stays on both wrists.
15. Reset All (Tuning and Debug): everything back to the defaults above.

With other mods:

16. RSQ_Gestures: Show Cards -> Inspect Gesture. Twist knuckles-up: the small card shows. In Gestures, turn
    on Watch Check Off: Gun Cards falls back to its own forearm-across-chest pose. (not yet headset-confirmed)
17. Gun Bonsai 0.10.6 + RSQ_GunBonsaiVR: the watch card shows the gun's level, XP bar and upgrades.
18. RSQ_Wheel: with Watch Card on, the Wheel's own Wrist Card stands down. Draw in the World cards follow
    the Wheel's palette and font.
19. RSQ_Grenade on plain Doom 2 (no Brutal Doom): the watch card's GRENADES is RSQ Grenade's count and goes up
    when you pick up a pack. (not yet headset-confirmed)

## Works with

- **RSQ_Gestures** (read): the watch check ("inspect"). Watch Check Off there makes Gun Cards use its own pose.
- **RSQ_Grenade** (read, 2026-11-01, by name): without Brutal Doom's grenades the GRENADES count is RSQ Grenade's
  (rig `gren_gc_b`: 3, then 6 after a pack of three; on the Brutal Doom order it still reads Brutal Doom's,
  `gren_gc_c`). Not yet headset-confirmed.
- **RSQ_GunBonsaiVR** with Gun Bonsai 0.10.6 (read): level, XP and upgrades on the watch card.
- **RSQ_Wheel**: the Wheel's Wrist Card stands down while Gun Cards' watch card is on; Gun Cards follows the
  Wheel's palette, font set and ring plate art; Small Card Colours can use the Wheel's palette.
- Does not read RSQ_Accessibility.
- Gun Cards counts its own kills; it cannot read the Wheel's stat tracker (the Wheel answers no such
  request).

## Known limits / open

- Everything from 2026-10-31 ran on the simulated rig only: On Reload, Tilt to Your Eyes, the watch-card
  flash and world Left/Right fixes, +N, RELOAD, grenades, status card, By Ammo Type, kills this level, room
  light, Hide at Your Eye.
- The pk3 grew from 10.6 to 13.2 MB with the two new watch-card rows. Watch Quest load time.
- Kills this level is the cards' own count, using the Wheel's rule; to use the Wheel's numbers instead, the
  Wheel needs a new request.
- Tilt to Your Eyes swings the card a few cm round the wrist (the engine turns it about a point behind the
  hand).

## Credits

`CREDITS.txt`, unchanged:

```
RSQ Gun Cards -- credits
========================

The cards are Ermac's Force Unleashed holo HUD, used with the owner's blessing: the ammo panels
(ammo_bg*.png), the AMMO / MAGAZINE / CHAMBER words and the digits (digit_*.png) in tools/card_art/ are his
art, from his doom-force-unleashed devbuild (models/common). We turn them into voxels; the design is his.
graphics/GCEDIG*.png and GCEPLATE.png (the cards drawn in the world) are made from the same art.

Code: ZScript written for the Radiant Silvergun Quest series (presidentkoopa), for stock QuestZDoom 17.3 by
Emawind and Team Beef. No engine change. Moved out of RSQ Wheel (the owner's RS_WeaponSelectionSystem port),
whose look reader, Gun Bonsai reader and billboards it carries its own copies of.

The watch card's letters are the IWAD's DoomFont (STCFN033-095), read from Freedoom (BSD) when the voxels are
built (tools/gen_side.py --iwad freedoom2.wad); the cards in the world use the loaded IWAD's DoomFont and
status bar by lump name.

Gun Bonsai is ToxicFrog's; the watch card only reads it, through RSQ Gun Bonsai VR's service, when loaded.
```

From the old README: "The cards on your guns, for Doom VR on stock QuestZDoom 17.3. Ermac's Force Unleashed
art (CREDITS.txt)."

## Appendix: how it draws (for builders)

Every piece of a card (panel, word, each digit or letter) is a weapon layer drawn as a voxel at the hand, so
the card is part of the hand's own draw and never lags the gun. The voxels have their place on the hand baked
in: `tools/gen_cards.py` (the small card) and `tools/gen_side.py --iwad <freedoom2.wad>` (the watch card, every
row and column baked). Both are deterministic: run them after changing the art or the layout, then
`tools/gen_reset.py` if CVARINFO changed. See `zscript/rsqgc/card.zs` for the details.
