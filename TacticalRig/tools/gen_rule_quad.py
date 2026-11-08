#!/usr/bin/env python3
"""Writes models/rsqtr/rtquad.obj: the flat card the RULE PICTURE is drawn on (owner 2026-11-08, "rules shown as they
happen"; rig.zs DrawRulePic, MODELDEF RSQTR_RulePic / RSQTR_RulePicGlow). One square, 1.0 across, centred on the model's
origin, standing in the model's side-up plane with its face toward the model's forward, so an actor's angle and pitch turn
it to the eyes (a sprite or visual thinker is turned by the engine, to the view's yaw, not the head). UVs 0..1 so a skin is
drawn once across it: the gun's own pickup sprite (A_ChangeModel by texture name) on the picture and on its glow copies.
Both windings, so it is never culled.

    python3 tools/gen_rule_quad.py           # from TacticalRig/
"""
import os

here = os.path.dirname(os.path.abspath(__file__))
path = os.path.normpath(os.path.join(here, '..', 'models', 'rsqtr', 'rtquad.obj'))
# OBJ as GZDoom draws it (models_obj.cpp, hw_models): x forward (the face), y up, z sideways (negated)
V = [(0, -0.5, -0.5), (0, 0.5, -0.5), (0, 0.5, 0.5), (0, -0.5, 0.5)]
T = [(1, 0), (1, 1), (0, 1), (0, 0)]      # (u along -z, v along y): v up, u to the right seen from the front (rig frames 11-08: u along +z came out mirrored)
lines = ['# the rule picture card: a 1.0 square facing +x, UVs 0..1 (tools/gen_rule_quad.py)']
lines += ['v %g %g %g' % v for v in V]
lines += ['vt %g %g' % t for t in T]
lines += ['g card', 'f 1/1 2/2 3/3', 'f 1/1 3/3 4/4', 'f 3/3 2/2 1/1', 'f 4/4 3/3 1/1']
open(path, 'w').write('\n'.join(lines) + '\n')
print(path)
