#!/bin/sh
# repack the pk3 (the loose folder is not what a launcher loads)
rm -f ../UltraBadassShieldSaw.pk3 && zip -q -r ../UltraBadassShieldSaw.pk3 . -x '.git/*' 'docs/*' '*.sh' '.gitignore'
