#!/bin/sh
# gen_handsync.sh <PREFIX> <out.zs> -- writes a series mod's copy of the frame-to-tic hand correction
# (handsync_template.zs). Register <PREFIX>_HandSync FIRST in the mod's MAPINFO AddEventHandlers.
sed "s/@P@/$1/g" "$(dirname "$0")/handsync_template.zs" > "$2" && echo "wrote $2 ($1_HandSync)"
