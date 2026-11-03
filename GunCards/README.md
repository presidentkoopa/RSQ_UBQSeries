# RSQ Gun Cards

Small ammo cards on your guns, on Ermac's Force Unleashed holo panels. A small card sits beside the wrist
of each gun: rounds in the gun big, reserve small. Check your watch with a gun in hand (the back of the wrist
turned to your face) and a full card lies flat on the back of that wrist, the way up you read it. What it shows is
your pick (Watch Card Shows): the Weapon card (MAG / RESERVE, grenades, this gun's kills this level), the Status
card (health, armour, the map's keys, grenades) or both on one card. Check your watch with an empty hand and you
always get the Status card. All text is JFO ("our font", 2026-11-03), at Quest or PCVR quality.

Pk3: `pk3/RSQ_GunCards.pk3` (about 14 MB since 2026-11-03: JFO at two qualities; it was 3.3 MB).

## Load order

doom2.wad -> 01 brutal22test6 -> 02 BD22_VoxelPack -> 03 BD22_VR-Reloaded_2.0.3j -> 04-07 XMVE ->
**RSQ_GunCards.pk3**

- Load it after your weapon pack. Needs no other RSQ pk3 to work alone.
- Plain Doom 2 without Brutal Doom: should work (nothing in the code needs Brutal Doom), but no note says
  it was run there. The grenade count reads Brutal Doom's hand grenades; without them RSQ Grenade's (when that pk3
  is loaded); absent with neither.
- With **RSQ_Gestures** loaded, the watch check is its watch pose: the back of the wrist turned to your face.
  Without it, the watch check is the forearm across your chest, wrist in front of your face, the back of the
  wrist up.

## Setup

- No buttons. The cards show by themselves; the watch card on the watch check; "On Reload" uses your reload
  buttons.
- Menu: Options -> Radiant Silvergun Options -> **RSQ Gun Cards**. Pages: **Placement**, **Tuning and
  Debug** (Reset All is there).

## What to do in VR

- **Look at the gun**: bring it within about 0.7 m of your eyes and look at it (for "When You Look at the
  Gun").
- **Watch check, with RSQ_Gestures**: hold the gun up in front of you and turn the back of your wrist to your
  face (the side a watch sits on, not the pulse side), hold a moment. It reads best with the forearm across
  your chest, as you would check a watch.
- **Watch check, without RSQ_Gestures**: bring the forearm up across your chest, wrist in front of your
  face, hand pointing across your body, the back of the wrist up (since 2026-11-02 the pulse side up no
  longer counts).
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
| Watch Card Shows | Weapon Card | Weapon Card (MAG / RESERVE, the counts, GRENADES, KILLS) / Status Card (H / A, health and armour, the key icons, G:n) / Both on One Card (MAG / RESERVE, the counts, H and A, the key icons, G:n). An empty hand always shows the Status Card. (2026-11-03) |
| Show Gun Bonsai on Card | Option (off) | With Gun Bonsai: the gun's level, XP bar and upgrades below the Weapon card. |
| Text Quality | Quest | Quest: JFO's glyphs at half resolution (a quarter of the voxels). PCVR: full resolution. Same size on the card. |
| Small Card Font | JFO | JFO, or Ermac's own words and digits (Option). The colours work the same with both. |
| Draw in the World | Option (off) | Cards drawn in the world at the hand, so no gun covers them (they can trail a fast hand). Off: drawn with the hand, no lag. |
| Tilt to Your Eyes | Option (off) | The small card turns toward your eyes (up to 20 degrees); it also swings a few cm round the wrist as it turns. |
| Hide at Your Eye | Option (off) | The small card hides while the gun is up at your eye. |

Always on (no row):

- **+N on pickup**: picking up ammo shows "+N" (green on the watch card) in the reserve's place for a moment.
- **RELOAD**: an empty magazine with rounds to load shows RELOAD in red instead of the count (on the watch card it
  replaces the MAG word).
- **The magazine's colour** (Low Ammo Colour, on): the magazine's count is green above half a magazine, yellow from
  half down to Low Below (a quarter), red at or below it; three clear steps, on the small card (both fonts) and the
  watch card. A gun without a magazine: red only when empty.
- **The key icons** (Status and Both cards): BD22_VoxelPack's own keys (keycards by Ghostpilot, skulls by Voxelbro)
  when it is loaded, Freedoom's status-bar keys otherwise; lit when held, dark grey when not. **Only the kinds this
  map has**: a keycard map shows the three keycards and no skulls, a skull map the skulls, a map with both all six,
  a map with no keys no icons (G:n alone). The map is scanned when it starts: keys lying in the level (Brutal Doom's
  GLRedCard etc. spawners count), keys a monster or spawner drops, line locks that name a keycard or a skull; a key
  that appears later (dropped, spawned by a script, picked up) adds its kind. Doom-format doors accept either kind,
  so with only those the keycards show. Other keys (no red / yellow / blue in the name) count as "+N" if there is
  room.
- **Grenades** on the watch card: Brutal Doom's hand grenades (not mines), or RSQ Grenade's without Brutal Doom.
- **The fuse count** (with RSQ Grenade and Gun Bonsai VR's Cook Sense 3): while RSQ Grenade's grenade cooks in your
  hand, its small card shows the seconds left big, amber for the first half of the fuse and red after, and shows
  while it cooks whatever Show Cards says (unless Off). Asked of RSQ Grenade by name; nothing without it.
- **Kills this level** on the watch card: this gun's kills on this level (a kill goes to the hand that fired
  last within a second).
- **Status card**: watch check with an empty hand shows H / A, health (red at 25 or less) and armour (blue) big,
  the key icons and G:n. Only when Draw in the World is off. (Before 2026-11-03 it had a STATUS title, letter keys
  and the level's kills; the owner's design has no title row.)
- **Which way up**: the watch and status cards read upright from where you look: the text turns half round
  when the gun's top points up instead of down where you see the card (2026-11-02).
- **Room light**: cards are lit like the gun, dim in a dark room.
- Left-handed (QuestZDoom's left-handed schemes) works: the cards follow the hands.

Placement page: Up / Down, Left / Right, In / Out for the small card; Up / Down, Left / Right (in the world)
for the watch card; Size in the World.

Tuning and Debug page: Both Guns on the Main Card (off), Panel (0 = each gun its own; 1-18 one of Ermac's panels for all), Material (Glass),
Strength, Small Card Colours (Ermac's / Wheel Palette), AMMO / MAGAZINE Word (on), Low Ammo Colour (on), Key Icons
(on), Only This Map's Keys (on; off shows all six key slots),
Low Below, Fade, the look and watch-check distances and timings (Watch Check Shows: Once It Is Held),
Tilt: At Most, Hide at Eye: Within, Pickup +N Stays, Show Hand Numbers on Screen (off; it also prints which way
up the watch card is turned, once a second), Reset All.

## Test it

Load the order above plus RSQ_GunCards.pk3. Start MAP01 with a gun in each hand if you can. Gun Cards was
split out of the Wheel on 2026-10-31. The owner placed the cards himself, so their look and place have
been seen; the rest is marked.

1. Look at your main gun: a small card sits right of the wrist, left of it on the off hand. Rounds big,
   reserve small.
2. Fire until the magazine is low: the count turns the empty colour.
3. Empty the magazine with ammo in reserve: RELOAD shows in place of the count. (not yet headset-confirmed)
4. Pick up ammo: "+N" shows in the reserve's place for about 1.5 s. (not yet headset-confirmed)
5. Watch check with a gun (see "What to do in VR"). The full card lies on the back of the wrist: name,
   MAGAZINE / RESERVE, grenades and this gun's kills this level. (one card on the back of the wrist, and
   grenades and kills: not yet headset-confirmed)
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

The 2026-11-02 fixes (owner's headset report: card upside down, text blurry, three "voxel lasers" from the gun
on the watch check). Rig only, **none of these is headset-confirmed yet**:

20. Forearm across your chest, the back of the wrist up to your face: the full card on the back of the wrist
    reads upright (the gun's name at the top), on either hand; the status card too with an empty hand.
    (rig: right and left hand, BD22 VR rifle and empty hand, upright; before, both read upside down)
21. Turn the wrist the other way (pulse side up): no watch card. (rig, both hands)
22. Only one card: nothing is drawn on the palm side of the wrist any more. (rig)
23. The small letters (MAGAZINE, RESERVE, GRENADES, KILLS) are whole and sharper than before. (rig frames;
    the headset is the real test)
24. With LaserSight and every series pk3 loaded on the Brutal Doom order: the watch check shows the card and
    the one laser beam, and no other lines out of the gun. (rig: none with every series pk3)
25. Placement -> watch card Up / Down: the card moves about as far per step as before (it now leans less).
26. RSQ Gestures' Watch Check Off: the forearm across the chest with the back of the wrist up shows the card;
    the pulse side up does not. (rig)

The 2026-11-03 design (owner, from the mockups): rig only, **not headset-confirmed**. Frames in
`test/evidence/20261103_*.png` (BD22 VR order with 03 = BD22_VR-Reloaded 2.0.3p, right hand across the chest, back of
the wrist up):

27. Watch Card Shows -> Weapon Card: MAG / RESERVE small, the counts big, GRENADES n orange, KILLS n red, no title.
    (rig, Quest and PCVR: `20261103_watch_weapon_status.png`)
28. Watch Card Shows -> Status Card with a gun: H / A, health and armour (blue) big, the key icons, G:n. (rig)
29. Watch Card Shows -> Both on One Card: MAG / RESERVE, the counts, H 100 / A n (blue), the key icons, G:n. (rig,
    `20261103_watch_both_empty.png`)
30. Watch check with an empty hand: always the Status card, whatever Watch Card Shows says. (rig, both qualities,
    and the left hand: `20261103_watch_left_hand_status.png`)
31. The key row by map (`20261103_watch_keys_by_map.png`): MAP01 no keys: no icons, G:n alone; MAP01 after picking
    up a red keycard: three keycard slots, red lit; MAP02 (keycards only): three keycards, no skulls; MAP08 (skulls
    only): three skulls in the keycards' place; MAP17 (both): all six. Rig log: "keys on MAP02: keycards 1 skulls 0
    (things 2)", MAP08 "keycards 0 skulls 1 (things 2)", MAP17 "keycards 1 skulls 1 (things 3)".
32. Without the voxel pack (plain Doom 2): Freedoom's key icons. (rig, `20261103_watch_freedoom_keys_plain_doom2.png`)
33. Text Quality Quest / PCVR: the same card, PCVR's glyphs at twice the resolution. (rig; the headset is the real
    test of whether Quest's half resolution reads well)
34. Magazine colour on the small card, JFO Quest, JFO PCVR and Ermac's font: 16/16 green, 8/16 yellow, 4/16 red,
    0/16 RELOAD red. (rig, `20261103_small_*_full_half_quarter_empty.png`); on the watch card 31/31 green, 13/31 yellow.
36. Small card, centred numbers (owner 08:20): the magazine count and the reserve (and "+N") stand in the middle of
    the card for 1, 2 and 3 digits, in both fonts; RELOAD where it was. (rig, `20261103_small_centred_jq.png`,
    `20261103_small_centred_er.png`: 16 / 120, 8 / 45, 4 / 8, RELOAD / 120)
35. Show Gun Bonsai on Card on, with Gun Bonsai: LV bar and upgrades below KILLS. (rig, full order,
    `20261103_watch_gunbonsai_rows_full_order.png`)

With other mods:

16. RSQ_Gestures: Show Cards -> Inspect Gesture. Turn the back of the wrist to your face: the small card shows.
    In Gestures, turn on Watch Check Off: Gun Cards falls back to its own forearm-across-chest pose. (not yet
    headset-confirmed)
17. Gun Bonsai 0.10.6 + RSQ_GunBonsaiVR: the watch card shows the gun's level, XP bar and upgrades.
18. RSQ_Wheel: with Watch Card on, the Wheel's own Wrist Card stands down. Draw in the World cards follow
    the Wheel's palette and font.
19. RSQ_Grenade on plain Doom 2 (no Brutal Doom): the watch card's GRENADES is RSQ Grenade's count and goes up
    when you pick up a pack. (not yet headset-confirmed)

## Works with

- **RSQ_Gestures** (read): the watch check ("inspect"). Watch Check Off there makes Gun Cards use its own pose.
- **RSQ_LaserSight**: no direct link. Until 2026-11-02 the cards' 33,600 sprite frames pushed the whole load
  order past the engine's 65,535 (see Known limits / open), and on the watch check card pieces drew as LaserSight's
  beam rods in the card's colour.
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
- THE SPRITE-FRAME LIMIT. The engine numbers a sprite's first frame with 16 bits (`r_data/sprites.h`,
  `spritedef_t.spriteframes` is `uint16_t`), so a load order with more than 65,535 sprite frames in all wraps
  later sprites onto other sprites' frames (pieces drawn as the wrong voxel or model). With every series pk3
  on the owner's order the total was ~71,150, Gun Cards' watch card alone 31,580 (each glyph baked per row and
  column). Since 2026-11-02 the watch card bakes columns only and turns each row into place: Gun Cards
  ~7,400 frames, the whole order ~45,000 (counted by `pk3` sprite lumps and VOXELDEF; a few more come from
  Gun Bonsai when it is loaded). Keep new voxel art small.
- THE WEAPON SCALE. The watch card's pieces turn about a point 1.5 m back along the forearm, placed for
  QuestZDoom's default `vr_weaponScale` 1.02. Another weapon scale slides the whole watch card along the
  forearm by (1.02 - scale) x 167 cm (3.3 cm at 1.00); text and panel stay together. Not seen on a headset.
- Forearm pointing away from you (gun forward, back of the hand up): the card's text runs along the forearm,
  so it reads sideways, as a watch would. Across the chest it reads upright.
- The pk3 went from 13.2 MB to about 3.3 MB (2026-11-02).
- Kills this level is the cards' own count, using the Wheel's rule; to use the Wheel's numbers instead, the
  Wheel needs a new request.
- Tilt to Your Eyes swings the card a few cm round the wrist (the engine turns it about a point behind the
  hand).

## Credits

See `CREDITS.txt`. In short: Ermac's Force Unleashed panels (and his words and digits for Small Card Font: Ermac);
**JFO**, the JDUI font by **Zedas** in **Blackmore1014**'s edit "JDUI Brutal Doom Ultimate Edition"
(https://www.moddb.com/addons/jdui-brutal-doom-ultimate-edition) for all card text (**no reuse licence is stated:
ask permission before a public release**); BD22_VoxelPack's key voxels (keycards by Ghostpilot, skulls by Voxelbro)
and Freedoom's status-bar keys (BSD) for the key icons; Gun Bonsai is ToxicFrog's (read only).

## Appendix: how it draws (for builders)

Every piece of a card (panel, word, each digit or letter) is a weapon layer drawn as a voxel at the hand, so
the card is part of the hand's own draw and never lags the gun. The voxels have their place on the hand baked
in: `tools/gen_cards.py` (the small card) and `tools/gen_side.py --iwad <freedoom2.wad>` (the watch card). Both
are deterministic: run them after changing the art or the layout, then `tools/gen_reset.py` if CVARINFO
changed. See `zscript/rsqgc/card.zs` for the details.

The watch card since 2026-11-02 (`gen_side.py` HOW v3): each glyph is baked once per font, family and column at
one reference height, with its VOXELDEF YOffset / ZOffset putting its turning point 150 cm back along the
forearm; the layer's y turns it up to its row (`side_states.zs` ROW_Y), the Up / Down slider adds to that turn
(NUDGE_K). Families: rot 0 / rot 1 (turned half round) x mirrored (the left hand); `card.zs SideRot` picks the
rot from the pose. Each piece has at most 16 colours, each filling an aligned 4 x 4 block of the voxel's 16 x 16
palette texture, so texture filtering does not mix a glyph's colour with its neighbours; glyphs keep all their
pixels (the voxel is scaled, not the picture).

The watch card since 2026-11-03 (`gen_side.py` v4, the owner's design): JFO glyphs from `tools/card_art/jfo/`
(`tools/jfo.py`), each baked at every unit of a grid (small font 25 units of 3.6 card px, a glyph two units and a
narrow one one; big digits 13 units of 6.9 px), per set (small / big x Quest / PCVR) and family; the rows are the
same far turns as v3, now named row ids (`side_states.zs` R_*). The key icons are baked front views at their slots
(a VOXELDEF voxel can only be turned about the vertical, so the real key voxels cannot lie on the card). No IWAD is
needed to build any more. The small card (`gen_cards.py`): JFO words and digits at both qualities in the frames
after Ermac's panels, Ermac's own words, RELOAD and digits kept for Small Card Font: Ermac.
The small card's numbers have five slots half a digit apart (centred, owner 08:20). Counts (2026-11-03): Gun Cards
16,065 sprite frames (was ~7,400); the owner's whole order with every series pk3 and Gun Bonsai 54,387 of the
engine's 65,535.
