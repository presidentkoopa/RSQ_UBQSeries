# Arcade: dynamic music (documentation only, nothing built)

Owner 2026-11-09: "I think this would go into the arcade system, maybe it's just for documentation right now for arcade
stuff." Our theme is early-90s pixel art (explosions after Symphony of the Night's sprites, sounds after SNES Mega Man), and
our build has to look for the UBQS series' own conditions, not generic "monsters nearby".

## The source

- **DoomDynMus** by cyber_cool: https://github.com/jankespro12/DoomDynMus (cyber_cool was banned from the ZDoom forum;
  the mod is no longer supported).
- **DoomDynamicMusic** (fork) by MadKoala: https://github.com/MadKoalaHome/DoomDynamicMusic (ZDoom forum
  viewtopic.php?p=1252257).
- Permissions: neither repo has a licence file. Both are public, and the fork's author says he added level binding so
  other modders could use it in their megawads (owner, 11-09: "two public repos stating intent to be shared and used in
  projects"). Plan: credit cyber_cool and MadKoala with both links; keep their code in its own folder under its own names;
  ship no copyrighted game soundtracks.

## How it works

- **Music chunks:** DMUSCHNK lumps (simplified JSON) group the tracks: each track group has `normal`, `action`, `death`
  and optional `high_action` tracks, plus `level` (fork). The older DMUSDESC / DMUSHIGH format still loads.
- **The state check, every tic** (`chunk.zs` SelectFile):
  - dead -> `death`;
  - monsters within 2048 units targeting a player and seeing him (or within 256) at or above
    `dmus_combat_high_min_monsters` (20), or any `bBOSS`, -> `high_action`;
  - at or above `dmus_combat_min_monsters` (2) -> `action`;
  - `dmus_combat_cooldown` (105 tics) of hold;
  - otherwise -> `normal`.
- **A change** fades the music volume out (`SetMusicVolume`), `S_ChangeMusic` to the new file, and fades it back in.

## What the fork adds over cyber_cool's last version

- **Level binding:** a track group can carry `level`, and Choose Track Mode 1 (now the default) plays that map's group.
  Without a tag it picks at random, or by map number (submode).
- **Silent tracks:** a group can play `music/dmus/silence.mp3` on purpose.
- **High-action fixed:** it returns its state (the original returned the file alone), so the switching logic works.
- **Small changes:**
  - `dmus_announcer` toggle;
  - invalid track names are logged;
  - `dmus_enabled` is on by default;
  - `dmus_combat_rumble_hotfix`.

## Where it left off

- **Chunk by level is a TODO:** `ChunkForLevel` still picks a random chunk. Also an open "ToDo Maybe Random?".
- **Out-of-range bug:** in `ChooseTrackByLevel` submode 1 the clamp is `if (foundIndex > tracks.Size())`, which should be
  `>=`. A map number past the track count indexes past the end, and map 0 gives -1.
- **The "monsters targeting monsters" commit isn't active:** the last commit message says monsters targeting other
  monsters now count. The loaded code (`zscript/dmus/chunk.zs`) still requires `a.target is "PlayerPawn"`. The change
  lives only in `zscript/mushandler.zs` / `musplayer.zs`, which `zscript.zs` no longer includes (dead files).
- **Player one only:** the first player in game drives the music for everyone (`event_handler.zs` WorldTick).
- **Switching:** fade out, then the next track from its start. No crossfade (the engine has one music stream), and
  no resuming where a track left off.
- **No stingers:** nothing plays a short hit over the music when something happens.

## What ours would look for (UBQS conditions; asked by name, as the series does everything)

How each one sounds is the owner's call; these are the hooks that exist today.

- **Miniboss Bossfight** (RSQMB_Service): meter full (the heartbeat), the arrival (inside SlowMo's landing slow), shield
  up, window open, one-on-one, a life lost, its death.
- **SlowMo** (RSQSM_Service): contextual slow-mo and the adrenaline bar running; DOWN and REVIVE. Music could duck or
  thin out while time is slowed.
- **Score** (RS_ScoreService): combo streaks and big style rows as stingers over the music.
- **Monsters** (RSQMN_RosterService "tier"): top tiers on the map (Black, White, Cyan, Brown, EX) as the high-action
  trigger, instead of Doom's boss flag alone.
- **Glow In The Dark** (RSQGD_Service): its map-wide events (wave, re-roll) as transition points.
- **Co-op:** each player's own state decides what that player hears (the music is per client).

## Engine facts that fit the 90s pixel look

- QuestZDoom's ZMusic plays SNES `.spc`, NSF/VGM/GBS (Game Music Emu) and tracker modules (MOD/XM/IT/S3M) natively.
- `S_ChangeMusic(name, order)` jumps a tracker module or a game-music file to another order position or sub-song: one
  file can hold the ambient, action and boss sections and switch between them without the fade-and-restart. The
  original can't do this.
- Stingers can be ordinary sounds played over the music (SNDINFO), the way the series already plays its cues.

## Open questions for the owner

- Which mod it lives in when it's built (the series rule: no new mods).
- The music itself: chiptune, SNES-style or tracker; who makes it or where it comes from.
