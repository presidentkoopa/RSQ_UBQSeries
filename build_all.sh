#!/bin/sh
# build_all.sh -- pack every mod into pk3/ from the folders beside it.
# Needs `zip`. Each folder keeps its own original build script too (DistanceGrab: build.ps1;
# ShieldSaw, TacticalRig, SlowMo: build.sh); this does the same packing
# in one go on any machine with a shell. Include lists match those scripts exactly.
set -e
# Player-facing pk3 names (2026-10-28, the owner): RSQ_ everywhere, no "Badass". Old names to delete
# from a load order: UltraBadassQuestSaber.pk3 (now RSQ_Saber), UltraBadassShieldSaw.pk3 (RSQ_ShieldSaw),
# RSQ_TopHPBars.pk3 (RSQ_HPBars), Gameplay_GB_VR_Offhand_Patch.0.10.6.pk3 (RSQ_GunBonsaiVR).
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
rm -f "$OUT/RSQ_ShieldSaw.pk3"
zip -q -r -X "$OUT/RSQ_ShieldSaw.pk3" . -x 'docs/*' 'tools/*' '*.sh' '.gitignore' 'HANDOFF.md'
echo "built pk3/RSQ_ShieldSaw.pk3"

# QuestSaber: everything but docs.
cd "$HUB/QuestSaber"
rm -f "$OUT/RSQ_Saber.pk3"
zip -q -r -X "$OUT/RSQ_Saber.pk3" . -x 'docs/*' '.gitignore'
echo "built pk3/RSQ_Saber.pk3"

# LaserSight: its explicit include list (its build.sh); tools/ and docs/ stay out.
cd "$HUB/LaserSight"
rm -f "$OUT/RSQ_LaserSight.pk3"
zip -q -r -X "$OUT/RSQ_LaserSight.pk3" zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt MODELDEF.txt CREDITS.txt \
	VOXELDEF.txt ANIMDEFS.txt zscript sprites models/rsqls
echo "built pk3/RSQ_LaserSight.pk3"

# Grapple: its explicit include list (jp_original/ is source material and does not ship).
cd "$HUB/Grapple"
rm -f "$OUT/RSQ_Grapple.pk3"
zip -q -r -X "$OUT/RSQ_Grapple.pk3" zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt SNDINFO.txt CREDITS.txt MODELDEF.txt zscript sprites sounds models
echo "built pk3/RSQ_Grapple.pk3"

# TopHPBars: the mod lives in pk3/ (its art is generated from coldcite's originals by tools/gen_art.py).
cd "$HUB/TopHPBars"
rm -f "$OUT/RSQ_HPBars.pk3"
(cd pk3 && zip -q -r -X "$OUT/RSQ_HPBars.pk3" .)
echo "built pk3/RSQ_HPBars.pk3"

# Accessibility: the shared menu and settings.
cd "$HUB/Accessibility"
rm -f "$OUT/RSQ_Accessibility.pk3"
zip -q -r -X "$OUT/RSQ_Accessibility.pk3" zscript.txt CVARINFO.txt MENUDEF.txt KEYCONF.txt MAPINFO.txt GLDEFS.txt CREDITS.txt zscript shaders
echo "built pk3/RSQ_Accessibility.pk3"

# Score: its explicit include list (its build.sh).
cd "$HUB/Score"
rm -f "$OUT/RSQ_Score.pk3"
zip -q -r -X "$OUT/RSQ_Score.pk3" zscript.txt MAPINFO.txt CVARINFO.txt SNDINFO.txt TEXTCOLO.txt MENUDEF.txt RSSCFON.fon2 RSSCFN2.fon2 CREDITS.md zscript sounds graphics 2>/dev/null
echo "built pk3/RSQ_Score.pk3"

# Miniboss: its explicit include list (original/ is Tartlman's mod, source material only).
cd "$HUB/Miniboss"
rm -f "$OUT/RSQ_Miniboss.pk3"
zip -q -r -X "$OUT/RSQ_Miniboss.pk3" zscript.txt MAPINFO.txt CVARINFO.txt MENUDEF.txt CREDITS.txt zscript
echo "built pk3/RSQ_Miniboss.pk3"

# Whip: a simulated bullwhip; its explicit include list (tools/ stays out).
cd "$HUB/Whip"
rm -f "$OUT/RSQ_Whip.pk3"
zip -q -r -X "$OUT/RSQ_Whip.pk3" zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt SNDINFO.txt MODELDEF.txt CREDITS.txt README.md zscript sounds models sprites
echo "built pk3/RSQ_Whip.pk3"

# Wheel: REMA's weapon wheel; its explicit include list (tools/ and the work queue stay out).
cd "$HUB/Wheel"
rm -f "$OUT/RSQ_Wheel.pk3"
zip -q -r -X "$OUT/RSQ_Wheel.pk3" zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF MENUDEF.txt SNDINFO.txt MODELDEF.txt TEXTURES.txt WRPALS.txt WRFONTS.txt CREDITS.txt README.md zscript sounds models sprites graphics
echo "built pk3/RSQ_Wheel.pk3"

# GunCards: the cards on the guns (moved out of Wheel 2026-10-31); its explicit include list (tools/ stays out).
cd "$HUB/GunCards"
rm -f "$OUT/RSQ_GunCards.pk3"
zip -q -r -X "$OUT/RSQ_GunCards.pk3" zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt MODELDEF.txt TEXTURES.txt VOXELDEF.txt CREDITS.txt README.md zscript models sprites graphics voxels
echo "built pk3/RSQ_GunCards.pk3"

# Gestures: what the hands are doing (inspect, thrust, both hands) for any series mod that asks; tools/ stays out.
cd "$HUB/Gestures"
rm -f "$OUT/RSQ_Gestures.pk3"
zip -q -r -X "$OUT/RSQ_Gestures.pk3" zscript.txt MAPINFO.txt CVARINFO.txt KEYCONF.txt MENUDEF.txt CREDITS.txt README.md zscript
echo "built pk3/RSQ_Gestures.pk3"

# RSQ_GunBonsaiVR (the Gun Bonsai Offhand VR patch): everything but the build script, notes, tools and git files (its build.ps1).
# Needs Gun Bonsai 0.10.6 (ToxicFrog, not included) loaded just before it.
cd "$HUB/GunBonsaiOffhandVR"
rm -f "$OUT/RSQ_GunBonsaiVR.pk3"
zip -q -r -X "$OUT/RSQ_GunBonsaiVR.pk3" . -x '.git*' 'build.ps1' 'NOTES.md' 'tools/*' '*.pk3'
echo "built pk3/RSQ_GunBonsaiVR.pk3"
