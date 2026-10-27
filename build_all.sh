#!/bin/sh
# build_all.sh -- pack every mod into pk3/ from the folders beside it.
# Needs `zip`. Each folder keeps its own original build script too (DistanceGrab and
# LaserSight: build.ps1 on Windows; ShieldSaw: build.sh); this does the same packing
# in one go on any machine with a shell. Include lists match those scripts exactly.
set -e
HUB="$(cd "$(dirname "$0")" && pwd)"
OUT="$HUB/pk3"
mkdir -p "$OUT"

# DistanceGrab and LaserSight: an EXPLICIT include list (see their build.ps1 for why:
# a stray file in a pk3 root can shadow a real lump).
pack_list() {   # <folder> <pk3 name> <model dir>
	cd "$HUB/$1"
	rm -f "$OUT/$2"
	F=""
	for f in zscript.txt MAPINFO.txt CVARINFO.txt TRNSLATE.txt KEYCONF.txt MENUDEF.txt MODELDEF.txt SNDINFO.txt MASSDEF.txt ANIMDEFS.txt TEXTURES.txt GLDEFS.txt RSQTRFIT.txt; do
		[ -e "$f" ] && F="$F $f"
	done
	for d in zscript graphics sprites sounds "$3"; do
		[ -d "$d" ] && F="$F $d"
	done
	zip -q -r -X "$OUT/$2" $F
	echo "built pk3/$2"
}
pack_list DistanceGrab RSQ_DistanceGrab.pk3 models/rsqdg
pack_list LaserSight   RSQ_LaserSight.pk3   models/rsqls
pack_list TacticalRig  RSQ_TacticalRig.pk3  models/rsqtr
pack_list SlowMo       RSQ_SlowMo.pk3       models/rsqsm

# ShieldSaw: everything but docs, scripts and git files (its build.sh).
cd "$HUB/ShieldSaw"
rm -f "$OUT/UltraBadassShieldSaw.pk3"
zip -q -r -X "$OUT/UltraBadassShieldSaw.pk3" . -x 'docs/*' '*.sh' '.gitignore'
echo "built pk3/UltraBadassShieldSaw.pk3"

# QuestSaber: everything but docs.
cd "$HUB/QuestSaber"
rm -f "$OUT/UltraBadassQuestSaber.pk3"
zip -q -r -X "$OUT/UltraBadassQuestSaber.pk3" . -x 'docs/*' '.gitignore'
echo "built pk3/UltraBadassQuestSaber.pk3"
