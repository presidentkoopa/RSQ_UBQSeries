#!/bin/bash
# TEST ONLY (never ships): the gesture probe into build/, beside pk3/RSQ_Accessibility.pk3 (the gesture reader lives in
# RSQ Accessibility since 2026-11-05, when RSQ Gestures was folded in; build it with tools/build_all.py Accessibility).
T="$(cd "$(dirname "$0")" && pwd)"; HUB="$(cd "$T/../../.." && pwd)"; B="$T/build"; mkdir -p "$B"
rm -f "$B/RSQ_Accessibility.pk3" "$B/gprobe.pk3"
cp "$HUB/pk3/RSQ_Accessibility.pk3" "$B/"
(cd "$T/gprobe" && zip -q -r -X "$B/gprobe.pk3" .)
echo "built $B/RSQ_Accessibility.pk3 $B/gprobe.pk3"
