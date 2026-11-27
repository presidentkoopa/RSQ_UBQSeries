# RSQ Glow In The Dark

Every room's walls glow in colour, from the floor up and the ceiling down; liquids glow and breathe in their own
colours; switches, exits and locked doors are lit so you can find them. The map is darker (DarkDoomZ is built in), and
the glow answers what happens: a boss, slow motion, a kill chain, a level up.

<a name="how-to-play"></a>
## How to play

| Do this | What happens | Needs |
|---|---|---|
| Start a map | Every room's walls glow: a band up from the floor and a band down from the ceiling, 64 units, each channel of each colour picked at random. One pair of colours for each tag group; all untagged rooms share one pair. New colours every map | Glow In The Dark: On (default); Profile: Classic (1.1) (default); Reroll Colours: Every Map (default); Floors and Ceilings: On (default) |
| Look round any room | It is darker than the map made it: each room's light times 0.625, sky rooms too | Darkness Mode: Compress (default); Darkness Level: Dismal (default) |
| Look at a liquid (water, nukage, slime, lava, blood, screens, exit signs and the rest of the Glow list) | The walls round it glow in the liquid's own colour, 128 units up, and breathe at its own pace (lava slow, water quick) | Liquids Glow: On (default); Living Liquids: On (default); Liquid Colour: By Profile (default) |
| Look at a liquid from another map pack, not in the list | If its name says NUK, ACID, TOXIC, OOZE, LAVA, MAGMA, BLOOD, WATER, SLIM, SLUDG or POIS, or the map calls it liquid, it glows the same way | Guess Liquids by Name: On (default) |
| Look at a floor that hurts and is not a known liquid | The walls round it throb red, 40 times a minute | Hurt Floors Throb Red: On (default) |
| Look at a teleporter pad (a floor named GATE...) | A cyan shimmer up the walls round it | Switches and Exits: On (default) |
| Look at a switch (any wall you use or shoot that does something) | That wall is lit amber | Switches and Exits: On (default) |
| Look at an exit switch | Lit green, breathing | Switches and Exits: On (default) |
| Look at a locked door | Lit in its key's colour (red, blue, yellow; lavender for any other lock), breathing 18 times a minute | Switches and Exits: On (default) |
| Pick up that door's key (any player holding it counts) | The door glows brighter and breathes faster, 50 times a minute | Switches and Exits: On (default) |
| Look at an ordinary door | A faint cool edge | Switches and Exits: On (default); Ordinary Doors Too: On (default) |
| Look at keys and powerups lying in the map | Drawn at full brightness. Picked up, they are normal again | Keys and Pickups: Keys (default) |
| Walk into a dark room | Its glow is stronger and taller: up to 1.6 times as strong and 1.4 times as tall, by how dark it is | Stronger in the Dark: On (default) |
| Kill something (or die) standing in a liquid | The pool flares in its colour for 18 tics | Splash Flares: On (default) |
| Press Shuffle Profile (Options > Radiant Silvergun Options > RSQ Glow In The Dark) | Another named profile at random, with new colours 2 tics later. With Profile at Custom or Random Profile it only gives new colours | |
| Press Randomize Look (same page) | A new look made up at random (colours, pulse, strength, liquids), Profile set to Custom, new colours | |
| Press Randomize Colours (same page) | New colours now, the same profile and look | |
| Press any of those three during a boss fight, a boss's tint, a Score life flash or while any player is DOWN | Nothing. Your console says "Glow In The Dark: colours held during a Boss fight or sequence" | |
| Step Profile left or right (or click it) | The next or previous of 37 rows: Custom, Random Profile, Classic (1.1) and 34 named looks | |
| Press Pair Darkness to Profile (Test and Debug page) | Darkness Mode and Darkness Level are set to that profile's pairing. Greyed for Custom and Random Profile | |
| Change any glow setting | The map is written again within a second | |
| Play a whole map with Reroll Colours at Never | The same colours every map, from Colour Seed (default 1337). Randomize Colours writes a new seed | Reroll Colours: Never |
| Die | New colours. Alone: when the map or a save is loaded again. In a netgame: at once | Reroll Colours: On Death |
| Level up a gun in Gun Bonsai | New colours | Reroll Colours: Level Up; Gun Bonsai or RSQ Gun Bonsai VR |
| Play on | New colours every Reroll Every (min) minutes (default 5), counted from the map's start | Reroll Colours: Timed |
| Look at a secret room you have not found | Its walls shimmer gold until you find it | Secret Rooms Shimmer: On (default Off) |
| Look at a liquid | It wears the room's colour (as 1.1 did) | Liquid Colour: Room Colour (default By Profile) |
| Look at a liquid | Always its own colour, whatever the profile says | Liquid Colour: Own Colour (default By Profile) |
| Walk room to room | A colour for each room, or for each tag group, whatever the profile says | One Colour Per: Each Room or Tag Group (default By Profile) |
| Walk room to room | Each room's floor colour is pulled half way to its neighbours' | Blend Rooms: On (default Off) |
| Look at health and armour (and ammo and weapons) lying in the map | Drawn at full brightness too | Keys and Pickups: Plus Health or Plus Ammo (default Keys) |
| Look at the largest pools, or the most important items | A real light over each (as many as the row says), coloured like it | Lights Over Pools above 0 (default 0); Lights on Items above 0 (default 0) |
| Turn Glow In The Dark off | The map's own glow and light come back: no darkness, no lit walls, items normal | Glow In The Dark: Off |

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
This mod has no options page.
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| RSQ Miniboss | While a miniboss lives (`RSQMB_Service` "miniboss"), the map's glow turns its own colour (else blood red) and throbs like a heart, and the map loses 48 light (Boss Tint, Darken the Map). It also asks this mod: "event.tint" (the glow beats red while a fight waits; a steady grey in the fight room), "event.dark" (DarkDoom Black for its landing, alone only), "event.wave" when it dies, "event.reroll" 2 seconds later (refused with Reroll Colours at Never) |
| RSQ SlowMo | While time is slowed (`RSQSM_Service` "active", "scale") the glow drains toward cold grey (SlowMo Drain). While you are DOWN with its red map ("down.redmap") every room goes deep blood red and beats. Any player DOWN ("down.any") holds the three colour buttons. SlowMo asks "ddz.original" so its own darkness keeps your Darkness Mode |
| RSQ Score | Each scored kill within 4 seconds of the last (`RS_ScoreService` "kill.serial") makes the glow 8% stronger, up to 10 kills (Combo Glow); it fades after 4 seconds. When a Score life is spent Score asks "event.lifeflash": 3 seconds of grey and white, then the map's own colours strongly to 5 seconds, then 1 second back |
| RSQ Gun Bonsai VR | When a gun's XP bar fills (`RSQGB_Service` "name", "level", "xp.permille", each hand) a gold wave rolls across the map's glow from you (Level Up Wave), once a level |
| Gun Bonsai | Without RSQ Gun Bonsai VR, its own "bonsai-level-up" event for a weapon makes the same wave |
| RSQ Grenade | Asks "enabled" and reads the room's glow colour for its Room Complement explosion colour and the Neon Crescent |
| RSQ Flashlight & Flare | Nothing read either way. DarkDoomZ's flashlight (and its spill light) was taken out of this copy; that mod draws DarkDoomZ's beam types itself |
| RSQ Accessibility | Nothing read or asked |
| DarkDoomZ | Built in, with its own settings names (`ddz_*`), so mods that read or write them keep working. The separate darkdoomz.pk3 must not be loaded with this mod |
| RSQ Gun Bonsai VR (menu) | The shared menu code looks for `RSQ_MeleeUpgradeService`; no row of this page is gated |
| Every series mod | One "Radiant Silvergun Options" entry; this mod adds the RSQ Glow In The Dark page to it |
| (its own service) | `RSQGD_Service` answers "version" (2), "enabled", "planes", "liquids", "liquid" (a sector, or how many), "darkdoomz" (always 1), "profile" (its row, or its name as a string), "ddz.original"; and takes "event.wave", "event.flare", "event.tint", "event.reroll", "event.dark", "event.lifeflash" |

## Limits

- Glow is drawn on walls: a floor's or ceiling's own face never glows. Real lights are off by default (Lights Over Pools and Lights on Items at 0).
- An exit you walk over (not a switch) has no wall to light, so it is not lit.
- DarkDoomZ re-lights every room from its light at the map's start whenever a darkness setting moves (and while a boss darkens the map), so a room the map lit since (a switch, a script) goes back.
- The drop darkness ("event.dark") happens only playing alone.
- Reroll Colours: Timed counts from the start of each map.
- The three colour buttons do nothing while a boss tint, a timed tint, a life flash or any player's DOWN is on.
- Do not load the separate darkdoomz.pk3: the engine stops at start-up because both define the same settings.
- There is no key: Randomize Colours is a menu button (and the console command `rsqgd_recolour`).
- Six console test commands (`netevent rsqgd_test_mb`, `_wave`, `_combo`, `_slowmo`, `_flare`, `_reroll`) try the reactions without the other mods.

## Credits

The full list, with every file and licence, is in **CREDITS.txt**.

- **presidentkoopa:** Glow In The Dark 1.1 (October 2021): the idea, the menu, the floor and ceiling glow as he modified
  it, and the Glow list (every liquid in Doom, the HD liquids and Brutal Doom's splashes), shipped as
  GLDEFS.txt. RS Radiance (his later direction for the idea): colour policies from a seed, seamless rooms, waves, looks
  and reactive lighting, carried over as ideas where QuestZDoom 17.3 allows.
- **ColorfulMaps** (Solid_Head; NightFright's "Lite" version): the floor and ceiling glow behaviour 1.1 grew from. No ACS
  is carried; the ZScript is new.
- **GlowingLiquids** by Finder153: what 1.1's liquid glow was built off.
- **More Lights** by Jakie (GitHub: SnakieJakie, https://github.com/SnakieJakie/More-Lights): its glowing-flat list,
  merged into the Glow list by the owner. Glow In The Dark grew into what it is when More Lights went into it (1.1's
  own readme recommended playing the two together). Jakie gave full permission to use and build on More Lights;
  credited here with thanks. No More Lights dynamic lights are shipped.
- **Subdued Lights:** the idea of the Subdued light style (double reach, half brightness), applied to this pack's own
  lights; nothing of that mod is used.
- **DarkDoomZ** by Sterling Parker (Caligari87), (C) 2018, zlib licence; this copy from the 2022 release (commit
  bcaaab8). A ZScript clone of Josh771's (SidDoyle's) Dark Doom. **This is an altered version, not the original:** its
  classes and sound are renamed so nothing can clash, its Options entry is moved under this pack's page, and its
  flashlight and its key are left out. Each altered file says so in its first lines, and DarkDoomZ's licence, credits, readme and
  text ship unchanged in DarkDoomZ/ inside the pk3. DarkDoomZ's own credits: Josh771's Dark Doom (inspiration, no code
  used); Kinsie (Fancy Doom), Gutawer (per-sector iteration), FishyClockwork (lighting adjustment), phantombeta and
  Marisa Kirisame (sector light effect removal), Accensus (iterator, addon support, logo) for code; mshahen's
  "Flashlight On/Off Clicks" (freesound.org 271109, modified, CC BY 3.0) for sound; Fort of Hard Knox, a1337spy and
  Orange Bomb for testing. The pairing, the miniboss darkening, the landing darkness and the rest of this pack's use of
  DarkDoomZ are ours.
- **QuestZDoom** (Emawind and Team Beef): the engine.

---
Written from the code at commit a283738bb, 2026-11-27.
