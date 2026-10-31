# RSQ Gun Cards

The cards on your guns, for Doom VR on stock QuestZDoom 17.3. Ermac's Force Unleashed art (CREDITS.txt).

- **The small card** sits beside the wrist stub of each gun: right of it on the main hand, left of it on the off
  hand. Ermac's panel, the AMMO / MAGAZINE word, the rounds in the gun big and the reserve small. The count turns
  red when the magazine runs low.
- **The watch card**: check your watch with a gun in your hand (knuckles up, the twist RSQ Gestures calls
  inspect; without RSQ Gestures, the forearm across the chest with the wrist in front of your face) and the full
  card lies flat on both sides of that wrist: the gun's name and hand, MAGAZINE / RESERVE and the counts, and with
  Gun Bonsai + RSQ Gun Bonsai VR loaded its level, XP bar and upgrades.
- **Colour**: each gun its own (by its weapon slot), or one simple colour for every card.
- Left-handed (`vr_control_scheme` 10 and up) works: the cards follow the hands.

Needs no other mod. Load it after your weapon pack, like the rest of the series. With RSQ Wheel loaded, the
Wheel's own wrist card stands down while the watch card is on, and the cards drawn in the world follow the
Wheel's palette and font set.

## Options

Options -> Radiant Silvergun Options -> **RSQ Gun Cards**

| Row | What it does |
|---|---|
| Show Cards | the small card: Off / Always / When You Look at the Gun / Inspect Gesture |
| Card Colour | Each Gun Its Own, or one colour for all |
| Watch Card | the full card on the watch check, on or off |
| Draw in the World | On: the cards are drawn in the world at the hand, so no gun can cover them (they can trail a fast hand a little). Off (default): drawn with the hand itself, no lag |
| Placement | nudge each card up / down and left / right; the world cards' size |
| Tuning and Debug | both guns on the main card, Ermac's 18 panels, solid / glass / glow, colours, the word, low-ammo colour and level, fade, the look and watch-check timings, hand numbers on screen, Reset All |

## How it draws

Every piece of a card (panel, word, each digit or letter) is a weapon layer drawn as a voxel at the hand, so
the card is part of the hand's own draw and never lags the gun. The voxels have their place on the hand baked
in: `tools/gen_cards.py` (the small card) and `tools/gen_side.py --iwad <freedoom2.wad>` (the watch card, every
row and column baked). Both are deterministic: run them after changing the art or the layout, then
`tools/gen_reset.py` if CVARINFO changed. See `zscript/rsqgc/card.zs` for the details.
