#!/bin/sh
# TEST ONLY, never ships (2026-11-03): gbp.pk3 (GBP_Probe: which RSQ hook perks Gun Bonsai would offer now).
# Runs beside ../og_1103/grv.pk3 (the GRV room and the velocity probe). See seq.py.
cd "$(dirname "$0")" && (cd probe && rm -f ../gbp.pk3 && zip -q -r ../gbp.pk3 .) && echo built gbp.pk3
