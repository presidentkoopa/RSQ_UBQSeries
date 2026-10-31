#!/bin/sh
# gen_rsmenu.sh -- writes every series mod's copy of rsmenu_template.zs under its own prefix.
# Run from anywhere; edit the template, never a copy. menutool.py check verifies the MENUDEF side.
H="$(cd "$(dirname "$0")/../.." && pwd)"
T="$H/tools/rsmenu/rsmenu_template.zs"
gen() {   # <prefix> <path in the hub>
	mkdir -p "$(dirname "$H/$2")"
	sed "s/@P@/$1/g" "$T" > "$H/$2" && echo "wrote $2 ($1)"
}
gen UBQS   QuestSaber/zscript/ubqs_rsmenu.zs
gen SSQ    ShieldSaw/zscript/ssq/rsmenu.zs
gen RSQDG  DistanceGrab/zscript/rsqdg/rsmenu.zs
gen RSQTR  TacticalRig/zscript/rsqtr/rsmenu.zs
gen RSQSM  SlowMo/zscript/rsqsm/rsmenu.zs
gen RSQLS  LaserSight/zscript/rsqls/rsmenu.zs
gen RSQGR  Grapple/zscript/rsqgr/rsmenu.zs
gen RSQTHP TopHPBars/pk3/zscript/rsqthp/rsmenu.zs
gen RSQSC  Score/zscript/rsscore/rsmenu.zs
gen RSQMB  Miniboss/zscript/rsqmb/rsmenu.zs
gen RSQGBV GunBonsaiOffhandVR/rsq/zscript/rsmenu.zs
gen RSQWH  Wheel/zscript/wheel/rsmenu.zs
gen RSQWP  Whip/zscript/rsqwp/rsmenu.zs
gen RSQGC  GunCards/zscript/rsqgc/rsmenu.zs
gen RSQG   Gestures/zscript/rsqg/rsmenu.zs
gen RSQA   Accessibility/zscript/rsqa_rsmenu.zs
