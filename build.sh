#!/bin/sh
# repack the pk3 (the loose folder is not what a launcher loads)
rm -f ../RS_ShieldSawQ.pk3 && zip -q -r ../RS_ShieldSawQ.pk3 . -x '.git/*' 'docs/*' '*.sh' '.gitignore'
