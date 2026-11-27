<p align="center"><img src="../design/readme_art/mods/graveyard_title.gif" alt="RSQ Graveyards"></p>

# RSQ Graveyards

Where a player died, a gravestone stands the next time that map comes up, with a small candle light. The stones are
kept between games. Press Use on a stone to read who died there and what killed them. With Legion of Bones loaded,
a dead monster can get up again as its undead.

<a name="how-to-play"></a>
## How to play

| Do this | What happens | Needs |
|---|---|---|
| Die (playing alone) | Your death is stored: the map, the spot, "Here lies <name>, killed by <killer>.", the date and the map time. No stone yet: it stands there from the next time the map is loaded (a saved game, a restart, coming back) | |
| Die in a netgame | The same, and the stone stands at once on every machine | |
| Enter a map where players died | A gravestone at each spot, one of four tomb pictures picked by the spot. Stones already standing in a loaded save stay as they stood | |
| Watch the stones as a map starts | Each one pops up from tiny over 24 tics, swells to 1.35 times its size and settles; the whole graveyard pops over about one second. A stone made later pops at once | Animate Gravestones: On (default); Pop In on Spawn: On (default) |
| Look at a stone | It breathes: a slow squash and stretch, about one breath every 7 seconds | Animate Gravestones: On (default) |
| Walk within 640 map units of a stone | Its candle light fades up over 20 tics (radius 72) and flickers; walk away and it fades out | Grave Light: On (default); Candle Flicker: On (default) |
| Look at the stones' colour | The light and the stone's tint breathe from cool blue to warm yellow, one breath every 2 seconds, all stones together | Living Stones: On (default) |
| Press Use on a stone | Its words float over it for about 4 seconds: the name, KILLED BY and the killer, the date, MAP TIME. Use again and they start again | RSQ VisualRewards, its Monster Words on |
| Press Use on a stone, without those words | The obituary is printed in the console, on your machine only | |
| Press Remove Map Gravestones (Options > Radiant Silvergun Options > RSQ Graveyards, Controls) | Every stone on this map is taken away and forgotten; the console says "Gravestones on this map are removed." | |
| Press Remove All Gravestones (same page) | Every stone on this map goes and every stored stone on every map is forgotten; the console says "All gravestones are removed." | |
| Type `gy_remove_map` or `gy_remove_all` in the console | The same as the two buttons | |
| Die more than 200 times on one map | The oldest stones of that map are forgotten and taken off the map, so 200 stand at most | |
| Lose an extra life in RSQ Score (it catches the killing blow) | A gold stone stands where you were, at once: "Here <name> lost a life, killed by <killer>." It has a stronger, steadier gold candle with a second light in it | RSQ Score |
| Kill a Brutal Doom, XMVE or plain Doom monster | Now and then (15 times in 100, rolled at the death, with no sign which), after Legion of Bones' death animation and a delay of 0, 5, 10, 15 or 20 seconds picked at the death, its Legion of Bones undead rises from the corpse with fire and the teleport sound, and comes for whoever killed it. The corpse goes. A loser stays dead for good | Legion of Bones; Bones Bridge: On (default); Rise Chance (default 15); Random Delay: On (default) |
| Stand on a corpse (or anything solid does) when its rise is due | The wait starts again (at least 1 second). After 4 such holds it rises at the nearest free spot beside the corpse, or stays dead if there is none | Legion of Bones; What Stops a Rise: Something On It (default) |
| Kill one of Legion of Bones' own monsters that rise again | The same roll: a loser's corpse stays for good; a winner rises Legion of Bones' own way after its own picked delay. This happens with Bones Bridge off too | Legion of Bones; Rise Chance (default 15); Random Delay: On (default) |
| Look at a stone | It stands still at full size | Animate Gravestones: Off (default On) |
| Watch a map start | Stones appear at full size, no pop | Pop In on Spawn: Off (default On) |
| Walk up to a stone | No candle light | Grave Light: Off (default On) |
| Watch a candle | It burns steady | Candle Flicker: Off (default On) |
| Look at the stones' colour | Stones keep their own colour and a warm candle; a gold stone is tinted gold with an amber candle | Living Stones: Off (default On) |
| Look at the stones' colour | The breath runs across the stones as a wave by their distance from you, one breath per 512 map units | Living Stones Mode: Wave (default Uniform) |
| Look at the stones' colour | Each stone breathes at its own pace (0.55 to 1.6 times) from its own start | Living Stones Mode: Chaos (default Uniform) |
| Stand on a corpse when its rise is due | It rises anyway, on time | Legion of Bones; What Stops a Rise: Nothing (default Something On It) |
| Kill a monster that rises | It waits Legion of Bones' own Respawn Delay (its menu) | Legion of Bones; Random Delay: Off (default On) |
| Kill a Brutal Doom, XMVE or plain Doom monster | It stays dead. Legion of Bones' own monster swaps run as Legion of Bones ships them | Legion of Bones; Bones Bridge: Off (default On) |

## Keys

<!-- GEN:keys -->
This mod has no keys.
<!-- /GEN:keys -->

## Options

<!-- GEN:options -->
Options > Radiant Silvergun Options > RSQ Graveyards

| Option | Default | What it does |
|---|---|---|
| **Animation** | | |
| Animate Gravestones | On | Gravestones breathe with a slow squash and bounce. |
| Pop In on Spawn | On | A new gravestone pops in instead of just appearing. |
| **Grave Light** | | |
| Grave Light | On | Each gravestone gives off a small light. |
| Candle Flicker | On | The grave light flickers like a candle. |
| Living Stones | On | Each stone's light and tint breathe slowly. |
| **Bones** | | |
| Bones Bridge | On | A Brutal Doom or XMVE monster's Legion of Bones undead rises from its corpse. |
| Rise Chance | 15 (0 to 100) | The share of corpses that rise, rolled once at the death; a corpse that loses stays dead. |
| **Controls** | | |
| Remove Map Gravestones | (button) | Removes every gravestone on this map. |
| Remove All Gravestones | (button) | Removes every stored gravestone on every map. |
| Test and Debug | (page) | Every other setting: animation and light tuning, the Living Stones mode and the Bones rules. |
| Reset All | (button) | Puts every RSQ Graveyards setting back to its default; the stored stones are kept. |

<details><summary>RSQ Graveyards: Test And Debug (8 rows)</summary>

| Option | Default | What it does |
|---|---|---|
| **Animation** | | |
| Bounce Amount | 0.05 (0 to 0.25) | How deep the gravestones' squash goes; 0 is perfectly still. |
| Bounce Speed | 1.5 (0.2 to 8) | How fast the gravestones breathe (1.5 is about a seven second breath). |
| **Grave Light** | | |
| Light Radius | 72 (16 to 256) | How far the grave light reaches. |
| Light Brightness | 210 (32 to 255) | How bright the grave light is. |
| Light Cull Distance | 640 (128 to 2048) | No grave light exists past this distance, in map units. |
| Living Stones Mode | Uniform | How the stones breathe: all together, in a wave by distance, or each at its own pace. |
| **Bones** | | |
| What Stops a Rise | Something On It | What stops a corpse rising: something standing on it (Legion of Bones' rule, the wait starts again), or nothing. |
| Random Delay | On | Each corpse rolls its own respawn delay at the death. |

</details>
<!-- /GEN:options -->

## Works with

| Mod | What changes |
|---|---|
| RSQ Score | When an extra life catches a killing blow, Score asks this mod's service `gy_RSQService` for "stone.life" and a gold stone is stored and stands at once |
| RSQ Miniboss | Asks `gy_RSQService` "bones.graves" when a fight lands with its Graves Rise row on and its Graves Rise Chance roll (default 30%) wins: each stone in range, nearest first, raises one Legion of Bones undead (or one for each thrall) in a ring round it, each looking for a free spot up to 8 times a second apart (needs Legion of Bones). Asks "stones.pulse" on each heartbeat while a fight waits: every candle swells up to 1.6 times, leans to the beat's colour and the stone lights up full bright |
| RSQ VisualRewards | Use on a stone asks `RSQVR_Service` ("loaded", then "word.hold" for each line) for the obituary words over the stone. With its Monster Words (`rsqvr_words`) off, the console line is printed as well |
| Legion of Bones | Found by its class names (`SkullZombieSpawn` and the rest). Its Respawn Delay (`LOB_Respawn`) is read. With Bones Bridge on, its monster swaps at map load are handed back to the monsters loaded before it (Brutal Doom's, XMVE's, or Doom's own), which then rise as its undead when they die. The four Bones rows are greyed without it |
| Brutal Doom, XMVE | Their monster classes are looked up in a table (from brutal22test6 and XMVE 1.3.1) to pick which of Legion of Bones' 13 undead each one rises as; their dying-part actors never rise |
| RSQ Gun Bonsai VR | Nothing on this page. The shared menu code looks for it (`RSQ_MeleeUpgradeService`) but no Graveyard row is gated |
| Every series mod | One "Radiant Silvergun Options" entry; this mod adds the RSQ Graveyards page to it |
| (its own service) | `gy_RSQService` answers "stone.life" (Score), "bones.graves" and "stones.pulse" (Miniboss); any other request gets 0 |

## Limits

- Playing alone, your own death's stone is not there when you die: it stands from the next time the map is loaded. A Score life's gold stone is the one that stands at once.
- The stones are kept in three settings (`gy_hashes`, `gy_locations`, `gy_obituaries`) on each machine, never in a saved game: they last across saves, new games and sessions, and loading an earlier save does not take a later death's stone away.
- At most 200 stones a map. There is no limit on how many maps have stones, and all three settings are read whole at every map start, every death and every Score life.
- A map is known by its checksum: if the map file changes, its stones are not shown on it.
- A stone is not solid: you walk through it. Use is the only thing that does anything at one.
- A candle exists only within Light Cull Distance (default 640) of the nearest player.
- In a netgame every stone looks as the host's settings say, and the candle and Wave follow the nearest player.
- In a netgame either Remove button, pressed by any player, empties every player's stored stones.
- A corpse brought back to life (an Arch-vile, RSQ Miniboss) before its rise is left alone.
- Lost souls, pain elementals, the Cyberdemon and the Spider Mastermind (and what replaces them) never rise through the Bones Bridge.
- Without Legion of Bones nothing of the Bones happens.
- A Rise Chance saved at 50 (the old default) is moved to 15 once: in the config at the first start, and in a game saved before 2026-11-27 when it loads. Any other saved value is kept, and 50 chosen again afterwards stays.
- There is no key: the two remove commands are menu buttons (and console commands).

## Credits

- **m8f** (Alexander Kromm, github.com/mmaulwurff/graveyard): **Graveyards**, the mod this edition is built on: the
  stones, the store across sessions, the obituaries, the remove commands, netgame support, and the Zabor VM abort handler.
  Copyright 2020 to 2021, GPLv3. Part of m8f's toolbox (mmaulwurff.github.io/pages/toolbox).
- **Captain J:** the tombstone sprites (gy_tomb1 and gy_tomb3 with minor edits by m8f, gy_tomb2 mirrored from gy_tomb1
  by m8f, gy_tomb4), per `credits.txt`.
- m8f's own thanks, carried over from his README: Dr_Cosmobyte for feature suggestions; mamaluigisbagel and Colerx for
  bug reports; 3saster for real time access in GZDoom.
- **presidentkoopa:** the RSQ Edition: the pop-in, the breathing, the candle light, gold stones, Living Stones, the
  Bones Bridge, Graves Rise, the heartbeat, the options page, the netgame fixes. Each of m8f's files it changed says
  so in its header (GPLv3 section 5a).
- **SpacemanStrife:** **Legion of Bones** (LOB_v1.05), used by name only: its rising actors, fire and Respawn Delay.
  None of it ships here.
- **Legion of Bones respawn-delay randomizer (som_lobrnd):** the idea behind Random Delay (a random Respawn Delay,
  Instant to 20 seconds). Its pk3 names no author. None of it ships here; Random Delay is written anew.
- **Sergeant Mark IV** (Brutal Doom, brutal22test6) and **XV117** (XMVE Monster Expansion): the DECORATE the Bones table
  was read from. None of it ships here.
- **QuestZDoom** (Emawind and Team Beef): the engine.

**Licence:** GPLv3 (`copying.txt`). The RSQ Edition's changes are GPLv3 too. You may share and change this pack under
that licence; keep m8f's copyright and the licence with it.

---
Written from the code at commit a283738bb, 2026-11-27; updated the same day for the owner's rising made rare (Rise Chance 50 to 15).
