#!/bin/sh
# gen_a11y.sh <PREFIX> <out.zs> -- writes a series mod's copy of the round-two settings class.
sed "s/@P@/$1/g" "$(dirname "$0")/a11y_template.zs" > "$2" && echo "wrote $2 ($1_A11y)"
