# mapview: Doom maps from the top, with rooms you draw

`mapview.py` reads a WAD and writes one HTML page per map. Each page shows the map from above,
and you can draw rectangles ("rooms") on it, name them, and export them as JSON.
It needs Python 3 only (no extra packages). The pages work offline in any browser and need no server.

Files: `mapview.py` (the converter) and `template.html` (the page it fills in). Keep them together.

## Run it

Windows (Command Prompt or PowerShell, in this folder):

    py mapview.py "C:\Games\Doom\DOOM2.WAD" -o C:\mapview_out
    py mapview.py "C:\Games\Doom\DOOM.WAD" "C:\Games\Doom\DOOM2.WAD" "C:\WADs\MapsOfChaos.wad" -o C:\mapview_out
    start C:\mapview_out\index.html

(If `py` is missing, use `python` instead.)

Linux:

    python3 mapview.py ~/wads/DOOM2.WAD -o ~/mapview_out
    python3 mapview.py ~/wads/DOOM2.WAD --maps MAP01,MAP07 -o ~/mapview_out
    xdg-open ~/mapview_out/index.html

- You can give several WADs in one run. Each WAD gets its own folder (`mapview_out/DOOM2/MAP01.html`, ...)
  with its own `index.html`, and `mapview_out/index.html` lists every WAD folder.
- `--maps MAP01,E1M1` makes only those maps.
- A PWAD with maps only (such as a map pack) works on its own: textures are not needed.
- A PK3/ZIP works too: it reads the map WADs inside it (`maps/NAME.wad` becomes the map `NAME`).
- A run over a whole IWAD takes a few seconds.

## On the page

- **Draw a room:** left-drag on the map. It snaps to the grid in the "Snap" box (16 map units by default).
  The new room's name box gets the focus: type its name and press Enter.
- **Move a room:** drag it. **Select:** click it. **Delete:** the Delete key, or the x next to it in the list.
- **Zoom:** mouse wheel. **Pan:** right-drag or middle-drag, or hold Space and drag, or use the Pan tool (P).
  **Fit** (F) shows the whole map.
- **Hover** a sector for its number, floor and ceiling height, light, special, tag and area number (bottom bar).
  Hover a door, trigger, exit or teleport line, a monster or a key for its details.
- **Export JSON** saves the rooms to a file named `<wad>_<map>_rooms.json`. **Import JSON** loads one back
  (it asks before adding to rooms already there, and warns if the file is for another map).
- The rooms are also kept in the browser by themselves (per WAD and map), so closing the page loses nothing.
  That copy lives only in that browser on that computer: Export to keep or share them.

The exported file is in map units, with y going up, as in Doom Builder / UDB, so the numbers can be read
against the map in an editor:

    {"format": "mapview-rooms-1", "wad": "DOOM2.WAD", "map": "MAP01",
     "rects": [{"name": "Arena A", "x1": 512, "y1": 192, "x2": 912, "y2": 512}]}

## The layers (tick boxes on the left)

| Layer | What it shows |
|---|---|
| Floor height shade | each sector in grey: darker is lower, lighter is higher (within this map) |
| Walls | one-sided lines thick black (always on); two-sided lines thin grey (can be turned off) |
| Areas | sectors joined across two-sided lines, cut at door and lift sectors and at sound-blocking lines. Each area has its own tint and a number (0 = the biggest). Numbers of areas too small to read hide until you zoom in |
| Sound-blocking lines | lines with the "block sound" flag (Doom flag 0x40), bright pink |
| Doors / lifts | door sectors orange, lift sectors blue, and the door lines you open by hand (DR, D1) |
| Trigger lines | lines that move a door, lift, floor, ceiling, stairs or crusher somewhere else: dashed = walk over (W1/WR), solid = switch (S1/SR), dotted = shoot (G1/GR) |
| Secret sectors | purple |
| Exits / teleports | exit lines yellow, teleport lines teal |
| Monsters | dots: red = small (zombies, imps, demons), magenta = medium (cacos, knights, revenants, arachnotrons, chaingunners), purple = big (barons, mancubi, arch-viles, pain elementals), black = boss |
| Keys and player starts | keys in their colour; starts as green arrows |

The **Skill** box shows the monsters and keys of that skill. Multiplayer-only things are hidden
unless you tick "show multiplayer-only things". The layer ticks are remembered by the browser.

## Limits

- **Map formats:** Doom (vanilla and Boom), Hexen (ZDoom-in-Hexen) and UDMF. Doom and Boom specials are named
  from a table (vanilla, Boom's extra numbered specials, and Boom's generalised doors, lifts, floors, ceilings,
  stairs and crushers). For Hexen and UDMF maps, doors, platforms, floors and so on are recognised by their action
  special number; anything done by an ACS script (a door a script opens, a secret a script gives) is not seen.
- **Areas** are a guide, not the engine's sound. In Doom, sound stops only after crossing **two** sound-blocking
  lines; this tool cuts at every one, so the thin strip between a pair of them becomes its own small area.
  Doors and lifts cut areas whether they are open or closed. Only door and lift sectors cut: a floor that rises to
  make a wall does not.
- **Monsters** are the Doom and Doom II ones by number. Monsters added by a mod (DECORATE / ZScript) do not show
  as monsters.
- Map names are the lump names (MAP01, E1M1); the level titles from MAPINFO are not read.
- Polyobjects and 3D floors are drawn as their plain sectors and lines.
- Tested in Google Chrome (headless). Edge uses the same engine. Firefox should work but was not tested.
