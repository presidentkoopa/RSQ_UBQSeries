#!/bin/sh
# build_all.sh -- pack every mod into pk3/ from the folders beside it.
# Needs `zip`. Each folder keeps its own original build script too (DistanceGrab: build.ps1;
# ShieldSaw, TacticalRig, SlowMo: build.sh); this does the same packing
# in one go on any machine with a shell. Include lists match those scripts exactly.
set -e
HUB="$(cd "$(dirname "$0")" && pwd)"
OUT="$HUB/pk3"
mkdir -p "$OUT"

# DistanceGrab: an EXPLICIT include list (see their build.ps1 for why:
# a stray file in a pk3 root can shadow a real lump).
pack_list() {   # <folder> <pk3 name> <model dir>
	cd "$HUB/$1"
	rm -f "$OUT/$2"
	F=""
	for f in zscript.txt MAPINFO.txt CVARINFO.txt TRNSLATE.txt KEYCONF.txt MENUDEF.txt MODELDEF.txt SNDINFO.txt MASSDEF.txt ANIMDEFS.txt TEXTURES.txt GLDEFS.txt RSQTRFIT.txt RSQTRLAY.txt CREDITS.txt; do
		[ -e "$f" ] && F="$F $f"
	done
	for d in zscript graphics sprites sounds "$3"; do
		[ -d "$d" ] && F="$F $d"
	done
	zip -q -r -X "$OUT/$2" $F
	echo "built pk3/$2"
}
pack_list DistanceGrab RSQ_DistanceGrab.pk3 models/rsqdg
pack_list TacticalRig  RSQ_TacticalRig.pk3  models/rsqtr
pack_list SlowMo       RSQ_SlowMo.pk3       models/rsqsm

# ShieldSaw: everything but docs, tools, scripts, the handoff and git files (its build.sh).
# README.md ships: it carries the credits.
cd "$HUB/ShieldSaw"
rm -f "$OUT/UltraBadassShieldSaw.pk3"
zip -q -r -X "$OUT/UltraBadassShieldSaw.pk3" . -x 'docs/*' 'tools/*' '*.sh' '.gitignore' 'HANDOFF.md'
echo "built pk3/UltraBadassShieldSaw.pk3"

# QuestSaber: everything but docs.
cd "$HUB/QuestSaber"
rm -f "$OUT/UltraBadassQuestSaber.pk3"
zip -q -r -X "$OUT/UltraBadassQuestSaber.pk3" . -x 'docs/*' '.gitignore'
echo "built pk3/UltraBadassQuestSaber.pk3"

# LaserSight: its explicit include list (its build.sh); tools/ and docs/ stay out.
cd "$HUB/LaserSight"
rm -f "$OUT/RSQ_LaserSight.pk3"
zip -q -r -X "$OUT/RSQ_LaserSight.pk3" zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt MODELDEF.txt \
	VOXELDEF.txt ANIMDEFS.txt zscript sprites models/rsqls
echo "built pk3/RSQ_LaserSight.pk3"

# Grapple: its explicit include list (jp_original/ is source material and does not ship).
cd "$HUB/Grapple"
rm -f "$OUT/RSQ_Grapple.pk3"
zip -q -r -X "$OUT/RSQ_Grapple.pk3" zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt SNDINFO.txt CREDITS.txt MODELDEF.txt zscript sprites sounds models
echo "built pk3/RSQ_Grapple.pk3"

# TopHPBars: the mod lives in pk3/ (its art is generated from coldcite's originals by tools/gen_art.py).
cd "$HUB/TopHPBars"
rm -f "$OUT/RSQ_TopHPBars.pk3"
(cd pk3 && zip -q -r -X "$OUT/RSQ_TopHPBars.pk3" .)
echo "built pk3/RSQ_TopHPBars.pk3"

# Accessibility: the shared menu and settings.
cd "$HUB/Accessibility"
rm -f "$OUT/RSQ_Accessibility.pk3"
zip -q -r -X "$OUT/RSQ_Accessibility.pk3" zscript.txt CVARINFO.txt MENUDEF.txt CREDITS.txt zscript
echo "built pk3/RSQ_Accessibility.pk3"
