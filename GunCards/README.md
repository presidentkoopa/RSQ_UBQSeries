# Gun Cards (RSQ GunCards)

**The one thing:** a holo ammo card riding the gun itself, and a glance at your watch brings up the whole card on
the back of your wrist.

Small ammo cards on your guns, on Ermac's Force Unleashed holo panels. A small card sits beside the wrist of each
gun: rounds in the gun big, reserve small. Check your watch with a gun in hand and a full card lies flat on the back
of that wrist: the weapon card, the status card (health, armour, keys, grenades) or both on one card. For stock
QuestZDoom 17.3, VR. Needs no other mod; Brutal Doom, RSQ Gestures, RSQ Grenade, RSQ Wheel and Gun Bonsai (with RSQ
Gun Bonsai VR) each add something when loaded.

## Features

**The small card.**
- A card beside the wrist of each gun, right of it on the main hand, left of it on the off hand: Ermac's panel, the
  AMMO or MAGAZINE word, the rounds in the gun big and the reserve small in gold. Each gun has its own panel colour
  by weapon slot, or By Ammo Type (bullets gold, shells red, rockets and grenades orange, cells cyan, fuel green), or
  one colour for every gun.
- Show Cards picks when it shows: always, when you look at the gun, on RSQ Gestures' inspect gesture, or while that
  hand's reload is held.
- **Low Ammo Colour:** the magazine's count is green above half a magazine, yellow from half down to Low Below (a
  quarter), red at or below it. A gun without a magazine goes red only when empty.
- **RELOAD:** an empty magazine with rounds to load shows RELOAD in red, then a red "0", taking turns every 1.5 s.
  Empty with nothing to load shows the count.
- **+N:** picking up ammo shows "+N" in green in the reserve's place for a moment.
- **The fuse count:** with RSQ Grenade and Gun Bonsai VR's Cook Sense 3, a grenade cooking in your hand shows the
  seconds left big on its card, amber for the first half of the fuse and red after, whatever Show Cards says (unless
  Off).
- Two fonts: JFO (the series' font) or Ermac's own words and digits. Text Quality Quest or PCVR.
- Tilt to Your Eyes turns the small card toward you as you turn your wrist. Hide at Your Eye hides it while the gun
  is up at your eye.

**The watch card.**
- Check your watch with a gun in hand and the full card lies flat on the back of that wrist, the way up you read it.
  Watch Card Shows picks what it says:
  - **Weapon Card:** MAG / RESERVE, the counts big, GRENADES, KILLS (this gun's kills on this level).
  - **Status Card:** H / A, health (red at 25 or less) and armour (blue) big, the key icons, G:n.
  - **Both on One Card:** MAG / RESERVE, the counts, H and A, the key icons, G:n.
- Check your watch with an empty hand (fists) and you always get the Status Card.
- **The key icons:** BD22_VoxelPack's own keys when it is loaded, Freedoom's status-bar keys otherwise; lit when held,
  dark grey when not. Only the kinds this map has: a keycard map shows the three keycards and no skulls, a skull map
  the skulls, a map with both all six, a map with no keys no icons. The map is read when it starts (keys lying in the
  level, keys a monster drops, locked lines), and a key that appears later adds its kind.
- **Grenades:** Brutal Doom's hand grenades (not mines), or RSQ Grenade's without Brutal Doom.
- **Show Gun Bonsai on Card:** with Gun Bonsai and RSQ Gun Bonsai VR, the gun's level, XP bar and upgrades below the
  Weapon Card.
- Watch Card: Always On keeps the full card on both wrists.

**Drawn with the hand, or in the world.**
- Cards are drawn as part of the hand's own draw, so they never lag the gun.
- Draw in the World draws the same cards in the world at the hand, so no gun can cover them (they can trail a fast
  hand). Size in the World sets their size.
- Left-handed control schemes work: the cards follow the hands.

## How to play

No buttons. The cards show by themselves.

- **Look at the gun** (Show Cards: When You Look at the Gun): bring it within about 0.7 m of your eyes and look at it.
- **Check your watch, with RSQ Gestures loaded:** hold the gun up in front of you and turn the back of your wrist to
  your face (the side a watch sits on, not the pulse side). Hold it a moment. It reads best with the forearm across
  your chest, as you would check a watch.
- **Check your watch, without RSQ Gestures:** bring the forearm up across your chest, wrist in front of your face,
  hand pointing across your body, the back of the wrist up. The pulse side up does not count.
- **The Status Card:** the same watch check with an empty hand (fists).
- **On Reload** (Show Cards: On Reload): hold that hand's reload. The card stays about a second after you let go.
- **Hide at Your Eye:** raise the gun to your eye as if aiming down sights; the small card goes.
- **Which way up:** the watch card reads upright from where you look, on either hand.

## Settings

Options -> Radiant Silvergun Options -> **RSQ Gun Cards**.

| Menu row | Default | What it does |
|---|---|---|
| Show Cards | Always | The small card: Off / Always / When You Look at the Gun / Inspect Gesture (RSQ Gestures; without it, as When You Look at the Gun) / On Reload. |
| Card Colour | Each Gun Its Own | Each gun its own colour by weapon slot, By Ammo Type, or one colour (White, Grey, Red, Gold, Green, Blue, Cyan, Purple, Orange, Pink) for all. |
| Watch Card | When I Check My Watch | Off / When I Check My Watch / Always On. |
| Watch Card Shows | Weapon Card | Weapon Card / Status Card / Both on One Card. An empty hand always shows the Status Card. |
| Show Gun Bonsai on Card | Off | The gun's Gun Bonsai level, XP bar and upgrades below the Weapon Card. |
| Text Quality | Quest | Quest: JFO's glyphs at half resolution. PCVR: full resolution. Same size on the card. |
| Small Card Font | JFO | JFO, or Ermac's own words and digits. |
| Draw in the World | Off | The cards drawn in the world at the hand instead of with it. |
| Tilt to Your Eyes | Off | The small card turns toward your eyes (up to Tilt: At Most). |
| Hide at Your Eye | Off | The small card hides while the gun is up at your eye. |

**Placement**

| Menu row | Default | What it does |
|---|---|---|
| Small card: Up / Down | 0 | Moves the small card up or down. |
| Small card: Left / Right | 0 | Moves it sideways. |
| Small card: In / Out (cm) | 0 | Moves it along the forearm, toward you or away. |
| Watch card: Up / Down | 0 | Moves the watch card up or down the wrist. |
| Watch card: Left / Right (in the world) | 0 | Moves the watch card sideways when Draw in the World is on. |
| Size in the World | 1.4 | The size of cards drawn in the world. |

**Tuning and Debug**

| Menu row | Default | What it does |
|---|---|---|
| Both Guns on the Main Card | Off | Both guns' rounds on the main hand's small card, the off hand's in the small row. |
| Panel (0 = each gun its own) | 0 | Ermac's panel: 0 each gun its own by weapon slot, 1-18 one panel for all. |
| Material | Glass | Solid / Glass / Glow. |
| Strength | 0.85 | How solid Glass and Glow are. |
| Small Card Colours | Ermac's | Ermac's own colours, or the Wheel Palette (RSQ Wheel's; Standard without it). |
| AMMO / MAGAZINE Word | On | The word on the small card. Off: the card is shorter. |
| Low Ammo Colour | On | The magazine's count green / yellow / red by how full it is. |
| Key Icons | On | The key icons on the Status and Both cards. |
| Only This Map's Keys | On | Only the key kinds this map has. Off: all six key slots. |
| Low Below (share of a magazine) | 0.25 | Red at or below this share of a full magazine. |
| Fade (tics) | 4 | Tics to fade a card in or out. |
| Look: Gun Within (metres) | 0.7 | "When You Look at the Gun": the gun within this many metres of the eyes. |
| Look: Within (degrees) | 30 | And within this many degrees of where you look. |
| Watch Check Shows | Once It Is Held | As the Twist Starts / Once It Is Held (with RSQ Gestures). |
| Stays After (tics) | 35 | Tics a card stays after the pose ends, or the reload is let go. |
| Tilt: At Most (degrees) | 20 | The most Tilt to Your Eyes turns, each way. |
| Hide at Eye: Within (metres) | 0.30 | "At your eye" is the hand within this many metres of the eye, pointing where you look. |
| Pickup +N Stays (tics) | 52 | Tics the "+N" of a pickup stays. |
| Show Hand Numbers on Screen | Off | What the engine says about the hands, on screen. |
| Reset All | - | Every RSQ Gun Cards setting back to its default. |

## Works with

- **RSQ Gestures:** the watch check is its inspect gesture (the back of the wrist turned to your face). With Gestures'
  Watch Check Off, Gun Cards uses its own forearm-across-the-chest pose. Show Cards: Inspect Gesture needs it.
- **RSQ Grenade:** without Brutal Doom's grenades, GRENADES on the watch card is RSQ Grenade's count. With Gun Bonsai
  VR's Cook Sense 3, the cooking grenade's card counts its fuse down.
- **RSQ Gun Bonsai VR** (with Gun Bonsai): the watch card shows the gun's level, XP bar and upgrades (Show Gun Bonsai on
  Card).
- **RSQ Wheel:** the Wheel's own Wrist Card stands down while Gun Cards' watch card is on. Cards drawn in the world
  follow the Wheel's palette, font set and plate art; Small Card Colours can use the Wheel's palette. The Wheel's
  Colour by Gun uses the colour Gun Cards gives each gun.
- **BD22_VoxelPack:** its own key voxels are the key icons when it is loaded.
- **Brutal Doom:** the GRENADES count is its hand grenades; its placed keys count in the map's key scan.
- Gun Bonsai VR has no nodes for Gun Cards.

## Load order

After Brutal Doom, the voxel pack, BD22 VR Reloaded, the monster packs and Gun Bonsai, among the RSQ pk3s. Load it
after your weapon pack.

## Known limits

- The Status Card on an empty hand shows only with Draw in the World off.
- Draw in the World cards are placed once a tic, so they can trail a fast hand.
- Tilt to Your Eyes swings the small card a few cm round the wrist as it turns.
- KILLS is Gun Cards' own count (a kill goes to the hand that fired last within a second); it is not RSQ Wheel's
  stat tracker.
- The cards are voxel art, many frames of it; a load order with a great deal of voxel art can pass the engine's
  sprite-frame limit, which draws later sprites wrong. Keep new voxel art small.

## Credits

See `CREDITS.txt`. In short: Ermac's Force Unleashed panels (and his words and digits for Small Card Font: Ermac),
used with the owner's blessing; **JFO**, the JDUI font by **Zedas** in **Blackmore1014**'s edit "JDUI Brutal Doom
Ultimate Edition" (https://www.moddb.com/addons/jdui-brutal-doom-ultimate-edition) for all card text (**no reuse
licence is stated: ask permission before a public release**); BD22_VoxelPack's key voxels (keycards by Ghostpilot,
skulls by Voxelbro) and Freedoom's status-bar keys (BSD) for the key icons; the cards in the world use the loaded
IWAD's DoomFont and status bar. Code: ZScript for the Radiant Silvergun Quest series (presidentkoopa), for stock
QuestZDoom 17.3 by Emawind and Team Beef; moved out of RSQ Wheel. Gun Bonsai is ToxicFrog's (read only, through RSQ
Gun Bonsai VR's service).
