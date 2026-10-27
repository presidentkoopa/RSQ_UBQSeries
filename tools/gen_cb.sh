#!/bin/sh
# gen_cb.sh <PREFIX> <out.zs> -- writes a series mod's copy of the colour-blind palette class.
sed "s/@P@/$1/g" "$(dirname "$0")/cb_template.zs" > "$2" && echo "wrote $2 ($1_CB)"
