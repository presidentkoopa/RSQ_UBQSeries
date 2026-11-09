# Graveyards [RSQ Edition]

<a href="https://github.com/mmaulwurff/graveyard/releases" alt="Downloads">
  <img src="https://img.shields.io/github/downloads/mmaulwurff/graveyard/total" />
</a>

Graveyards is a minimod for GZDoom that places gravestones where you die.
Gravestones are carried over play sessions, so:

1. You die.
2. You start a new game, or load the savegame.
3. You see a gravestone where you died.

[Demonstration](https://youtu.be/t3X0r8QXwRA)

## Features

- keys to remove gravestones on this map or all gravestones.
- doesn't affect gameplay.
- netgame compatible (players see other player's gravestones).

### Local additions

Options > Radiant Silvergun Options > RSQ Graveyards, or the cvars directly:

- gravestones pop in when they spawn and keep a slow idle squash & stretch
  (`gy_anim_enabled`, `gy_popin_enabled`, `gy_bounce_amount`,
  `gy_bounce_speed` - speed is degrees per tic, so 1.5 is about a 7 second
  breath).
- a warm candle light on each grave, faded in and out by distance and culled
  entirely past `gy_light_cull` (`gy_light_enabled`, `gy_light_flicker`,
  `gy_light_radius`, `gy_light_bright`).

Both are cosmetic and read only from the local player's cvars.

- boss markers: an animated terminal, `gy_BossSmall` (45x40 map units) and
  `gy_BossBig` (161x143, taller than a standard 128 ceiling so it only fits
  outdoors). Summon either to look at one.

Boss marker frames are imported from a GIF with
`E:\Tools\msdfgen\Import-GifSprite.ps1`, which extracts every frame, writes the
patches, and emits the TEXTURES and a ready-made state line.

### How To Play (RSQ Edition)

1. Load `RSQ_Graveyard.pk3` with the other RSQ pk3s.
2. Play. Where you die, a gravestone stands the next time you play that map (new game or a loaded save). With RSQ Score,
   a life you spend leaves a gold stone instead.
3. Options > Radiant Silvergun Options > RSQ Graveyards: the settings, Living Stones, and the two keys (Remove Gravestones
   on This Map, Remove All Gravestones; also in Customize Controls).
4. With RSQ Miniboss and Legion of Bones: Graves Rise raises undead from the stones when a Bossfight lands (RSQ Miniboss's
   option, off by default).

### RSQ Edition changes (presidentkoopa)

- the animated gravestones and the grave light above.
- the options page lives under Options > Radiant Silvergun Options >
  RSQ Graveyards (the RSQ series' shared menu), with the same settings as
  before plus the two keys (Remove Gravestones on This Map, Remove All
  Gravestones) and a Reset All. Graveyard's own "Graveyards" row in the
  Options menu is gone. The keys are still in Customize Controls too.
- two kinds of stone (2026-11-06, rig only, not headset-confirmed): a real
  death is the stone as always (grey, warm flickering candle); an RSQ Score
  life spent (RSQ Score asks by name, service `gy_RSQService`) is the same
  stone tinted gold, with a steadier gold light and a slightly larger light
  radius. The kind is kept in the stored stones (a 4th field in
  `gy_locations`; stones stored before load as a death). Without RSQ Score
  every stone is a death stone. SlowMo's DOWN places no stone.
- Living Stones (off, `gy_living`; Living Stones Mode `gy_living_mode`:
  Uniform / Wave / Chaos): each stone's light colour and tint breathe like
  RSQ Score's "Score:" label (calm blue to warm yellow every 2 s; gold
  stones within a gold range). Uniform: all together; Wave: a sequence by
  distance from you; Chaos: each stone its own pace. Held still in RSQ
  Accessibility's Photosensitive Mode. The same one light per stone.
- the Bones (2026-11-06, rig only, not headset-confirmed), with Legion of Bones
  (SpacemanStrife, LOB_v1.05) loaded; nothing without it:
  - **Bones Bridge** (off, `gy_bones`): Brutal Doom's monsters stay. A few
    seconds after a Brutal Doom / XMVE monster dies, its Legion of Bones undead
    rises from the corpse, LoB's way: LoB's Respawn Delay (its own menu), its
    fire burst, its rising animation, and it comes for whoever killed it. The
    13 kinds LoB raises (zombieman, shotgunner, chaingunner, imp, demon,
    spectre, cacodemon, hell knight, baron, revenant, mancubus, arachnotron,
    arch-vile) follow what each BD / XMVE monster replaces
    (`tools/gen_bones_table.py`); lost souls, pain elementals, the Cyberdemon
    and the Mastermind stay dead. **What Stops a Rise** (`gy_bones_block`):
    Something On It (LoB's rule: if something stands on the corpse when the
    wait ends, the wait starts again) or Nothing.
  - **Load order**: Legion of Bones goes AFTER Brutal Doom and XMVE, before
    the RSQ pk3s. (Loaded before Brutal Doom, its own Tracer / MonsterTracer
    replace Brutal Doom's and BD's monsters shoot LoB's weaker bullet.) Loaded
    after, LoB would turn every monster into a skeleton from the start; with
    the Bones Bridge on, Graveyard hands those spawns back to Brutal Doom /
    XMVE. Bridge off: LoB as it ships. (LoB's skeletons then fire Brutal
    Doom's tracer.)
  - RSQ Miniboss can wake the tombstones in a Bossfight (its Graves Rise row):
    every tombstone in range raises undead, with no cap (2026-11-07; the old
    cap of 24 is gone; rig only, not headset-confirmed: 31 stones raised 31
    Legion of Bones undead on the rig), and while a Bossfight waits every stone's candle and stone beat with the
    map's red heartbeat (held steady in RSQ Accessibility's Photosensitive
    Mode).
- source: the `Graveyard/` folder of RSQ_UBQSeries, built to
  `RSQ_Graveyard.pk3`.

## Acknowledgments

- Thanks to Captain J for gravestone sprites.
- Thanks to Dr_Cosmobyte for feature suggestions.
- Thanks to mamaluigisbagel and Colerx for bug reports.
- Thanks to 3saster for implementing real time access in GZDoom.
- PresidentKoopa for RSQ changes: animated tombstone, fading lights.
## Other Info

Author: m8f
License: GPLv3

This mod is a part of [m8f's toolbox](https://mmaulwurff.github.io/pages/toolbox).
