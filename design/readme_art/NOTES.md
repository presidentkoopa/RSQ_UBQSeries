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

## One presentation for every README

    python design/readme_art/make_mod_art.py     <repo> design/readme_art/mods   # every page's title and divider
    python design/readme_art/apply_readme_art.py <repo>                          # titles, word headers, dividers

`apply_readme_art.py` is the one to run after adding a section or a README (add a new README to its PAGES table and to
`make_mod_art.py`). On each page it puts the animated title above the first heading, turns every `## Heading` into an
animated word header in the page's colour (`heads/<page>/<slug>.gif`), and puts the page's still divider before each
header and in place of a `---` rule. Each header keeps an `<a name="slug">` in front of it, the same slug GitHub gave
the heading, so links to a section still work. `###` headings stay text. Run again, it only converts new `## ` lines.

The front page's own banner, its chain headers (`h_*.gif`) and the imp divider are made by `make_readme_art.py` and
`make_readme_art_2.py`.
