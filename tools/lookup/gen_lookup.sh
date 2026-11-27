#!/bin/sh
# gen_lookup.sh <PREFIX> <out.zs> -- writes a series mod's copy of the remembered service lookup (lookup_template.zs).
# #include it in the mod's zscript.txt; then <PREFIX>_Lookup.Find("X") replaces ServiceIterator.Find("X") at any call site.
sed "s/@P@/$1/g" "$(dirname "$0")/lookup_template.zs" > "$2" && echo "wrote $2 ($1_Lookup)"
