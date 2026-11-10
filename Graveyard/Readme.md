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

- commands to remove gravestones on this map or all gravestones (in this
  edition, buttons on its options page; see Controls).
- doesn't affect gameplay.
- netgame compatible (players see other player's gravestones). In this
  edition (2026-11-10, code only, not shown; no netgame run yet) every
  machine sends its own stored stones at map load, so each player's solo
  deaths on the map come too; the dying player's machine sends a new
  death's stone; each stone carries a key made from game data (player,
  game tics, map tics, spot, kind), and a copy whose key is already on the
  map is skipped, so no stone comes twice. Stones stored before the key are
  matched by their exact spot and kind.

## Controls

No keys. **Remove Gravestones on This Map** and **Remove All Gravestones**
are menu buttons on its page (Options > Radiant Silvergun Options > RSQ
Graveyards, Controls). The console aliases still work: `gy_remove_map` and
`gy_remove_all`.

### Local additions

Options > Radiant Silvergun Options > RSQ Graveyards, or the cvars directly:

- gravestones pop in when they spawn and keep a slow idle squash & stretch
  (`gy_anim_enabled`, `gy_popin_enabled`, `gy_bounce_amount`,
  `gy_bounce_speed` - speed is degrees per tic, so 1.5 is about a 7 second
  breath).
- a warm candle light on each grave, faded in and out by distance and culled
  entirely past `gy_light_cull` (`gy_light_enabled`, `gy_light_flicker`,
  `gy_light_radius`, `gy_light_bright`).

Both are cosmetic. In a netgame every machine draws them with the host's
(arbitrator's) settings and lights a candle for the nearest player, so they
come out the same on every machine.

### How To Play (RSQ Edition)

1. Load `RSQ_Graveyard.pk3` with the other RSQ pk3s.
2. Play. Where you die, a gravestone stands the next time you play that map (new game or a loaded save). With RSQ Score,
   a life you spend leaves a gold stone instead.
3. Options > Radiant Silvergun Options > RSQ Graveyards: the settings, Living Stones, and the two remove buttons (Remove
   Gravestones on This Map, Remove All Gravestones; menu buttons, not keys).
4. With RSQ Miniboss and Legion of Bones: Graves Rise raises undead from the stones when a miniboss fight lands (RSQ Miniboss's
   option, off by default).

### RSQ Edition changes (presidentkoopa)

- the animated gravestones and the grave light above.
- the options page lives under Options > Radiant Silvergun Options >
  RSQ Graveyards (the RSQ series' shared menu), with the same settings as
  before plus the two remove commands as buttons (Remove Gravestones on
  This Map, Remove All Gravestones; no keys, owner 2026-11-10) and a Reset
  All. Graveyard's own "Graveyards" row in the Options menu is gone.
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
  - RSQ Miniboss can wake the tombstones in a miniboss fight (its Graves Rise row):
    every tombstone in range raises undead, with no cap (2026-11-07; the old
    cap of 24 is gone). A riser whose spot is taken looks for a free spot
    near it, 5 tries a second apart, then is given up (2026-11-10, code
    only, not shown), and while a miniboss fight waits every stone's candle and stone beat with the
    map's red heartbeat (held steady in RSQ Accessibility's Photosensitive
    Mode).
- source: the `Graveyard/` folder of RSQ_UBQSeries, built to
  `RSQ_Graveyard.pk3`.

## Status (RSQ Edition)

- rig only, not headset-confirmed: the Bones Bridge, the heartbeat, Graves
  Rise (2026-11-06/07 builds), the gold stone and Living Stones' colour
  steps (logs), and the pack loading on the owner's order with no script
  error (2026-11-10).
- code only, not shown: m8f's stones and store in this edition, the
  pop-in, breathing and candle fade, Reset All, and the 2026-11-10 fixes
  (risers looking for a free spot, the remove buttons, the look read the
  same on every machine, the stone keys).
- not yet run: netgames, including the everyone's-stones rule above.

## Acknowledgments

- Thanks to Captain J for gravestone sprites.
- Thanks to Dr_Cosmobyte for feature suggestions.
- Thanks to mamaluigisbagel and Colerx for bug reports.
- Thanks to 3saster for implementing real time access in GZDoom.
- PresidentKoopa for RSQ changes: animated tombstone, fading lights.
- m8f's soulsphere add-on (`add-ons/soulsphere` in the source) is not part
  of RSQ_Graveyard.pk3.
## Other Info

Author: m8f
License: GPLv3

This mod is a part of [m8f's toolbox](https://mmaulwurff.github.io/pages/toolbox).
