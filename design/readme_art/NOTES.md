# README art

The front page's title banner, section headers, imp divider and the mod web. All drawn from the series' own files:
the Score fonts (`Score/RSSCFON.fon2`, `RSSCFN2.fon2`) and the painted monster art (`MonsterRecolour/rsrecolour/`).

Run from anywhere, with the repo root and an output folder:

    python design/readme_art/make_readme_art.py   <repo> design/readme_art    # title banner, divider, first headers
    python design/readme_art/make_readme_art_2.py <repo> design/readme_art    # the other headers
    python design/readme_art/mod_web_edges.py     <repo>                      # counts the strings, writes mod_web_edges.json
    python design/readme_art/make_mod_web.py      <repo> design/readme_art    # the corkboard (uses mods/*_icon.png)
    python design/readme_art/make_keys_art.py     <repo> design/readme_art/screens   # the two keys pictures
    python -I design/readme_art/make_readme_screens.py <uploads> <BD22 renders> design/readme_art/screens  # game pictures
    python design/readme_art/make_mod_art.py      <repo> design/readme_art/mods   # each mod README's title and divider

A string in the mod web from A to B means A's ZScript names (in quotes, so it can find it) a service B declares. Network
events and names read off other mods are not counted. The monster on each photo is decoration only.

The mod web, 2026-11-27: 117 strings between 20 mods. RSQ Accessibility is gone from it (being removed). The shared
options-menu code (rsmenu.zs) and the How To Play code being added (howto*.zs) are not counted. The folders Monsters and
MonsterRecolour are not read (owner's order): RSQ Monsters is a node with the strings other mods' code names to it
(RSQMN_ services), and make_mod_web.py draws each photo from `mods/<key>_icon.png`, not from MonsterRecolour.
`make_mod_art.py` still reads MonsterRecolour's sprites; it was not run for this.

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

## The front page (2026-11-16)

Intro, the contents grid (each mod's monster, `mods/<key>_icon.png`, linking to its section), In short, then one
section per mod: the mod's own animated title (a link to its page), a short introduction that hands off to the next
section, a few pictures, and a link to the mod's full page. The mod sections are not `## ` headings, so
`apply_readme_art.py` leaves them alone.

## The front page (2026-11-27)

Rewritten from the mods' new READMEs (each written from its code that day). Kept: the title banner and the contents
grid (7 across; RSQ Accessibility's cell gone, so the last row has 6). RSQ Monsters' section text is kept as it was.
New pictures in `screens/`: the owner's game screenshots (grenade types, the mega blast, the Wheel's ring and holster
screen, the watch card and the small card, two sabers, the lasers, the top of the view) cropped and framed by
`make_readme_screens.py`, BD22 VR Reloaded's reload renders, and the two keys pictures (`make_keys_art.py`: the buttons
of each hand, and where on your body). The keys pictures and the front page's Keys table carry the same lines: change
them together.
