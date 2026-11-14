Frames painted by hand go here: hand/<colour>/<LUMP>.png (colour folder names as in rsrecolour/: green, blue, purple,
cyan, brown, yellow, fireblu, gray, red, abyss, black, white; LUMP = the sprite lump name, e.g. TROOA1.png).

Start from the baked frame in rsrecolour/<colour>/ (it already has the lump's offsets in its grAb chunk; keep them).
Monsters/tools/recolour/bake.py never writes into this folder. After it bakes, it copies every PNG found here over its
own output in rsrecolour/<colour>/, so a hand-painted frame always wins and survives every re-bake.

This folder is not in the pk3 (the build zips rsrecolour/, where the bake has already put the hand frames).
