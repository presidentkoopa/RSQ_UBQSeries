#!/bin/sh
# build.sh -- pack RSQ_Controls.pk3 (explicit include list, as tools/build_all.py and build_all.sh). RSQoopaControls.cfg
# stays out of it and ships beside it: the console's exec reads a file on disk, never a pk3 lump (design/controls/CONTROLS.md).
# Run tools/howtoplay/gen_howtoplay.py first: zscript/rsqct/howto*.zs and RSQoopaControls.cfg are generated.
cd "$(dirname "$0")" && rm -f RSQ_Controls.pk3 && \
zip -q -r -X RSQ_Controls.pk3 zscript.txt MAPINFO.txt CVARINFO.txt MENUDEF.txt README.md zscript && echo "built RSQ_Controls.pk3"
