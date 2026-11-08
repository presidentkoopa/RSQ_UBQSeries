#!/usr/bin/env python3
"""Writes models/rsqtr/rtwirewh.png: the WHITE ring flash of a holster freed by hand (owner 2026-11-08, "rules shown as they
happen"; rig.zs FRAME_WHITE, MODELDEF RSQTR_Marker / RSQTR_ItemMarker frame Z). 8x8 flat RGB, like the stock rtwire
skins. (The red refusal flash, frame Y, is the ammo light's own rtwirerd.png.)

    python3 tools/gen_rule_skins.py          # from TacticalRig/
"""
import os
from PIL import Image

here = os.path.dirname(os.path.abspath(__file__))
path = os.path.normpath(os.path.join(here, '..', 'models', 'rsqtr', 'rtwirewh.png'))
Image.new('RGB', (8, 8), (255, 255, 255)).save(path)
print(path)
