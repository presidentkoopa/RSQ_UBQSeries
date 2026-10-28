#!/usr/bin/env python3
"""presets.py -- writes each mod's PRESET rows' choices (OptionStrings) into its MENUDEF.

A preset row (OptionMenuItem<P>Preset, tools/rsmenu/rsmenu_template.zs) sets several cvars at once and
shows which choice they match, or Custom. "Standard" is ALWAYS the mod's CVARINFO defaults, read here
from the file (never typed), so Standard is exactly today's behaviour. The other choices are below.

  presets.py            rewrite the block between "// PRESETS" and "// END PRESETS" in every MENUDEF
  presets.py --print    print the blocks instead
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(__file__))
from menutool import cvar_defaults

H = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))

# mod folder: (MENUDEF, CVARINFO, [presets])
# a preset: (OptionString name, [choice labels in menu order], {label: {cvar: value}})
# "Standard" takes every cvar named by any choice at its default. A choice that leaves a cvar out
# also sets it to its default, so every choice is one exact, recognisable state.
MODS = {
 'QuestSaber': ('MENUDEF', 'CVARINFO', [
  ('UBQS_P_Size', ['Short', 'Standard', 'Long'], {
     'Short': {'ubqs_size': 0.85}, 'Long': {'ubqs_size': 1.15}}),
  ('UBQS_P_Look', ['Quest', 'Standard', 'PC VR', 'Film'], {
     # the old Presets page's three looks, as they were; "Default Look" is Standard
     'Quest': {'ubqs_glow_quality': 1, 'ubqs_lights': 1, 'ubqs_glow_dots': 0, 'ubqs_trail_steps': 2, 'ubqs_trail_life': 6,
               'ubqs_clash_fx': 0.5, 'ubqs_hand_glow': 0, 'ubqs_blade_glow': 0.6, 'ubqs_glow_width': 1.2, 'ubqs_flash': 1},
     'PC VR': {'ubqs_glow_quality': 4, 'ubqs_lights': 3, 'ubqs_glow_dots': 0, 'ubqs_trail_steps': 4, 'ubqs_trail_life': 12,
               'ubqs_clash_fx': 2, 'ubqs_hand_glow': 1, 'ubqs_blade_glow': 0.6, 'ubqs_glow_width': 1.2, 'ubqs_flash': 2},
     'Film':  {'ubqs_glow_quality': 3, 'ubqs_glow_width': 1.0, 'ubqs_glow_motionfade': 1, 'ubqs_glow_fade_deg0': 150,
               'ubqs_glow_fade_deg1': 450, 'ubqs_glow_fade_widen': 0.35, 'ubqs_trail_life': 10, 'ubqs_hand_glow': 0,
               'ubqs_blade_glow': 0.6, 'ubqs_flash': 1}}),
  ('UBQS_P_Swing', ['Light', 'Standard', 'Heavy'], {
     # Light: a flick cuts, a held blade keeps cutting, recuts come fast; Heavy: only a real swing cuts
     'Light': {'ubqs_swing_cut': 5, 'ubqs_cut_sustain': 0.8, 'ubqs_cut_rate': 6, 'ubqs_swing_scale': 0.5},
     'Heavy': {'ubqs_swing_cut': 12, 'ubqs_cut_sustain': 0.3, 'ubqs_cut_rate': 10, 'ubqs_swing_scale': 1.0}}),
  ('UBQS_P_Damage', ['Low', 'Standard', 'High', 'Brutal'], {
     'Low': {'ubqs_damage': 20}, 'High': {'ubqs_damage': 45}, 'Brutal': {'ubqs_damage': 70}}),
  ('UBQS_P_Block', ['Low', 'Standard', 'High'], {
     'Low':  {'ubqs_block': 40, 'ubqs_block_cone': 50, 'ubqs_deflect_assist': 6, 'ubqs_blade_guard': 3, 'ubqs_guard_width': 8},
     'High': {'ubqs_block': 90, 'ubqs_block_cone': 100, 'ubqs_deflect_assist': 24, 'ubqs_blade_guard': 12, 'ubqs_guard_width': 24}}),
  ('UBQS_P_Force', ['Gentle', 'Standard', 'Mighty'], {
     'Gentle': {'ubqs_push_power': 0.5, 'ubqs_pull_power': 0.5, 'ubqs_push_range': 320, 'ubqs_pull_range': 512, 'ubqs_grip_mass': 300},
     'Mighty': {'ubqs_push_power': 1.75, 'ubqs_pull_power': 1.75, 'ubqs_push_range': 768, 'ubqs_pull_range': 1024, 'ubqs_grip_mass': 1000}}),
 ]),
 'ShieldSaw': ('MENUDEF.txt', 'CVARINFO.txt', [
  ('SSQ_P_Size', ['Standard', 'Large', 'Largest'], {
     'Large': {'ssq_shield_scale': 1.25}, 'Largest': {'ssq_shield_scale': 1.5}}),
  ('SSQ_P_Throw', ['Easy', 'Standard', 'Deliberate'], {
     # Easy: a gentle flick throws, and fast; Deliberate: a real snap of the arm
     'Easy': {'ssq_throw_min': 30, 'ssq_speed_floor': 14},
     'Deliberate': {'ssq_throw_min': 85, 'ssq_speed_floor': 10}}),
  ('SSQ_P_Block', ['Low', 'Standard', 'High'], {
     # perfect_speed: the shield speed a perfect block needs (lower is easier)
     'Low': {'ssq_deflect_assist': 4, 'ssq_sweep_pad': 8, 'ssq_perfect_speed': 45},
     'High': {'ssq_deflect_assist': 30, 'ssq_sweep_pad': 32, 'ssq_perfect_speed': 15}}),
  ('SSQ_P_Damage', ['Low', 'Standard', 'High'], {
     'Low': {'ssq_cut_damage': 0.6, 'ssq_bash_damage': 0.6, 'ssq_grind_damage': 3},
     'High': {'ssq_cut_damage': 1.75, 'ssq_bash_damage': 1.75, 'ssq_grind_damage': 12}}),
 ]),
 'DistanceGrab': ('MENUDEF.txt', 'CVARINFO.txt', [
  ('RSQDG_P_Reach', ['Short', 'Standard', 'Long', 'Room'], {
     'Short': {'rsqdg_reach': 384}, 'Long': {'rsqdg_reach': 1024}, 'Room': {'rsqdg_reach': 2048}}),
  ('RSQDG_P_Aim', ['Precise', 'Standard', 'Generous'], {
     'Precise': {'rsqdg_spread': 6}, 'Generous': {'rsqdg_spread': 20}}),
  ('RSQDG_P_Gesture', ['Relaxed', 'Standard', 'Strict'], {
     # how easily the palm-out and flick register
     'Relaxed': {'rsqdg_palm_tol': 50, 'rsqdg_flick_deg': 3, 'rsqdg_lock_dwell': 0},
     'Strict': {'rsqdg_palm_tol': 20, 'rsqdg_flick_deg': 8, 'rsqdg_lock_dwell': 8}}),
  ('RSQDG_P_Pull', ['Gentle', 'Standard', 'Snappy'], {
     'Gentle': {'rsqdg_flight_speed': 8, 'rsqdg_path_speed': 10},
     'Snappy': {'rsqdg_flight_speed': 20, 'rsqdg_path_speed': 24}}),
  ('RSQDG_P_Throw', ['Soft', 'Standard', 'Strong'], {
     'Soft': {'rsqdg_throw_scale': 0.5}, 'Strong': {'rsqdg_throw_scale': 2.0}}),
 ]),
 'TacticalRig': ('MENUDEF.txt', 'CVARINFO.txt', [
  ('RSQTR_P_Reach', ['Tight', 'Standard', 'Easy'], {
     'Tight': {'rsqtr_reach': 0.75}, 'Easy': {'rsqtr_reach': 1.5}}),
  ('RSQTR_P_IconSize', ['Small', 'Standard', 'Large'], {
     'Small': {'rsqtr_icon_scale': 0.6}, 'Large': {'rsqtr_icon_scale': 1.5}}),
 ]),
 'SlowMo': ('MENUDEF.txt', 'CVARINFO.txt', [
  ('RSQSM_P_Depth', ['Light', 'Medium', 'Standard', 'Bullet Time'], {
     'Light': {'rsm_depth': 0.6}, 'Medium': {'rsm_depth': 0.4}, 'Bullet Time': {'rsm_depth': 0.1}}),
  ('RSQSM_P_Ease', ['Snap', 'Standard', 'Gradual'], {
     'Snap': {'rsm_ramp_in': 0.0, 'rsm_ramp_out': 0.0},
     'Gradual': {'rsm_ramp_in': 0.6, 'rsm_ramp_out': 1.2}}),
 ]),
 'LaserSight': ('MENUDEF.txt', 'CVARINFO.txt', [
  ('RSQLS_P_Beam', ['Subtle', 'Standard', 'Bold'], {
     'Subtle': {'rsqls_beam_len': 1.5, 'rsqls_beam_a': 0.4, 'rsqls_beam_daylight': 0.0},
     'Bold': {'rsqls_beam_len': 5.0, 'rsqls_beam_a': 1.0, 'rsqls_beam_daylight': 0.7}}),
  ('RSQLS_P_Dot', ['Small', 'Standard', 'Large'], {
     'Small': {'rsqls_spot_size': 0.6}, 'Large': {'rsqls_spot_size': 1.75}}),
 ]),
 'Grapple': ('MENUDEF.txt', 'CVARINFO.txt', [
  ('RSQGR_P_Range', ['Short', 'Standard', 'Long'], {
     'Short': {'rsqgr_range': 768}, 'Long': {'rsqgr_range': 3072}}),
  ('RSQGR_P_Swing', ['Floaty', 'Standard', 'Snappy'], {
     # how the rope carries you: reel, lean, top speed together
     'Floaty': {'rsqgr_reel_speed': 8, 'rsqgr_pump': 0.4, 'rsqgr_max_speed': 22, 'rsqgr_speed': 32},
     'Snappy': {'rsqgr_reel_speed': 18, 'rsqgr_pump': 0.15, 'rsqgr_max_speed': 45, 'rsqgr_speed': 64}}),
  ('RSQGR_P_Pull', ['Gentle', 'Standard', 'Strong'], {
     'Gentle': {'rsqgr_slide_speed': 6, 'rsqgr_mass_max': 400},
     'Strong': {'rsqgr_slide_speed': 18, 'rsqgr_mass_max': 2000}}),
 ]),
 'Miniboss': ('MENUDEF.txt', 'CVARINFO.txt', [
  ('RSQMB_P_Fight', ['Easier', 'Standard', 'Harder'], {
     'Easier': {'rsqmb_thralls': 2, 'rsqmb_lives': 2, 'rsqmb_shield': 50, 'rsqmb_invuln': 3},
     'Harder': {'rsqmb_thralls': 5, 'rsqmb_lives': 4, 'rsqmb_shield': 90, 'rsqmb_invuln': 8}}),
  ('RSQMB_P_Often', ['Rare', 'Some Maps', 'Every Map'], {
     'Rare': {'rsqmb_map_chance': 25}, 'Some Maps': {'rsqmb_map_chance': 50}}),
 ]),
 'Score': ('MENUDEF.txt', 'CVARINFO.txt', [
  ('RSQSC_P_Size', ['Small', 'Standard', 'Large'], {
     'Small': {'rs_score_scale': 75}, 'Large': {'rs_score_scale': 150}}),
  ('RSQSC_P_Place', ['Top Right', 'Top Left', 'Top Centre', 'Bottom Right'], {
     'Top Left': {'rs_score_x': 15, 'rs_score_y': 10}, 'Top Centre': {'rs_score_x': 50, 'rs_score_y': 10},
     'Bottom Right': {'rs_score_x': 85, 'rs_score_y': 80}}),
 ]),
 'TopHPBars/pk3': ('MENUDEF.txt', 'CVARINFO.txt', [
  ('RSQTHP_P_Size', ['Small', 'Standard', 'Large'], {
     'Small': {'rsqthp_scale': 0.15}, 'Large': {'rsqthp_scale': 0.5}}),
 ]),
}

# A label with no entry in its preset's choices is the defaults ("Standard", or Score's "Top Right",
# Miniboss's "Every Map").

def fmt(v):
    if isinstance(v, float):
        s = ('%.4f' % v).rstrip('0').rstrip('.')
        return s if s else '0'
    return str(v)

def defval(defs, c):
    t, v = defs[c]
    if t == 'bool': return '1' if v.lower() in ('true', '1') else '0'
    return v if v else '0'

def blocks(mod):
    md, cv, presets = MODS[mod]
    defs = cvar_defaults(os.path.join(H, mod, cv))
    out = []
    for name, labels, choices in presets:
        allc = []
        for d in choices.values():
            for c in d:
                if c not in allc: allc.append(c)
        out.append(f'OptionString "{name}"')
        out.append('{')
        for lab in labels:
            d = choices.get(lab, {})
            pairs = []
            for c in allc:
                if c not in defs: raise SystemExit(f'{mod}: {c} is not in {cv}')
                pairs.append(f'{c} {fmt(d[c]) if c in d else defval(defs, c)}')
            out.append(f'\t"{" ".join(pairs)}", "{lab}"')
        out.append('}')
    return '\n'.join(out)

def main():
    for mod in MODS:
        b = blocks(mod)
        if '--print' in sys.argv:
            print(f'== {mod}\n{b}'); continue
        p = os.path.join(H, mod, MODS[mod][0])
        s = open(p, encoding='utf-8').read()
        new = '// PRESETS -- written by tools/rsmenu/presets.py (Standard = CVARINFO defaults); edit the script, not here\n' + b + '\n// END PRESETS'
        s2, n = re.subn(r'// PRESETS.*?// END PRESETS', lambda m: new, s, flags=re.S)
        if n != 1: print(f'{mod}: no PRESETS block in {MODS[mod][0]}'); continue
        if s2 != s: open(p, 'w', encoding='utf-8').write(s2); print(f'wrote presets into {mod}/{MODS[mod][0]}')

if __name__ == '__main__':
    main()
