# README art

The front page's title banner, section headers, imp divider and the mod web. All drawn from the series' own files:
the Score fonts (`Score/RSSCFON.fon2`, `RSSCFN2.fon2`) and the painted monster art (`MonsterRecolour/rsrecolour/`).

Run from anywhere, with the repo root and an output folder:

    python design/readme_art/make_readme_art.py   <repo> design/readme_art    # title banner, divider, first headers
    python design/readme_art/make_readme_art_2.py <repo> design/readme_art    # the other headers
    python design/readme_art/mod_web_edges.py     <repo>                      # counts the strings, writes mod_web_edges.json
    python design/readme_art/make_mod_web.py      <repo> design/readme_art    # the corkboard
    python design/readme_art/make_mod_art.py      <repo> design/readme_art/mods   # each mod README's title and divider

A string in the mod web from A to B means A's ZScript calls `ServiceIterator.Find` on a service B declares. Network
events and names read off other mods are not counted. The monster on each photo is decoration only.

Each mod README opens with its animated title (`mods/<folder>_title.gif`) and uses its still divider
(`mods/<folder>_divider.png`, the mod's monster in the twelve ladder colours) where it had a `---` rule. The headings
stay plain text, so links to a section and the README inside each pk3 still read as before.
