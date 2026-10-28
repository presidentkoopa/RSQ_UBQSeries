#!/bin/sh
# repack the pk3 (the loose folder is not what a launcher loads). README.md ships: it carries the credits.
rm -f ../RSQ_ShieldSaw.pk3 && zip -q -r ../RSQ_ShieldSaw.pk3 . -x '.git/*' 'docs/*' 'tools/*' '*.sh' '.gitignore' 'HANDOFF.md'
