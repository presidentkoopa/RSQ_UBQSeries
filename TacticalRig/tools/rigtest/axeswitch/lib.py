# TEST ONLY: console-script builder for the axe / holster-swap rig runs (scratch).
REST_R = 'qz_rhand "0.25 1.3 -0.3 30 0 0"'
REST_L = 'qz_lhand "-0.25 1.3 -0.3 30 0 0"'
E = 1.60
P = dict(hipM='0.18 %.2f 0.0 30 0 0' % (E - 0.70), hipO='-0.18 %.2f 0.0 30 0 0' % (E - 0.70),
         chestM='0.12 %.2f -0.10 30 0 0' % (E - 0.46), chestO='-0.12 %.2f -0.10 30 0 0' % (E - 0.46),
         shM='0.18 %.2f 0.08 30 0 0' % (E - 0.10), shO='-0.18 %.2f 0.08 30 0 0' % (E - 0.10))
PL = dict((k, v) for k, v in P.items())
class S:
    def __init__(s): s.c = []
    def add(s, *c): s.c += list(c)
    def w(s, n): s.c.append('wait %d' % n)
    def grip(s, hand, where, hold=5):
        rest = REST_R if hand == 'r' else REST_L
        s.add('qz_%shand "%s"' % (hand, P[where])); s.w(12); s.add('qz_%sgrip 1' % hand); s.w(hold); s.add('qz_%sgrip 0' % hand); s.w(6); s.add(rest); s.w(25)
    def setup(s):
        s.add('wait 40', 'vr_control_scheme 0', 'vr_secondary_button_mappings 0', 'set rsqtr_messages 1', 'set rsqdg_trace 1', 'set rsqdg_debug 1',
              'set rsq_switch_log 1', 'qz_hmd "0 1.6 0 0 0 0"', REST_R, REST_L, 'netevent ax_tp -320 0 0', 'netevent ax_clear')
    def throw_main(s, step=0.086):
        s.add('qz_rhand "0.25 1.35 -0.15 30 0 0"'); s.w(12); s.add('+attack'); s.w(10)
        for k in range(7): s.add('qz_rhand "0.25 1.35 %.3f 30 0 0"' % (-0.15 - step * k)); s.w(1)
        s.add('-attack'); s.w(4); s.add(REST_R); s.w(60)
    def throw_off(s, step=0.086):
        s.add('qz_lhand "-0.25 1.35 -0.15 30 0 0"'); s.w(12); s.add('+oh_attack'); s.w(10)
        for k in range(7): s.add('qz_lhand "-0.25 1.35 %.3f 30 0 0"' % (-0.15 - step * k)); s.w(1)
        s.add('-oh_attack'); s.w(4); s.add(REST_L); s.w(60)
    def pull(s, hand):
        if hand == 'r':
            a = 'qz_rhand "0.250 1.300 -0.300 %s -30 %s"'
        else:
            a = 'qz_lhand "-0.250 1.300 -0.300 %s 30 %s"'
        roll = '90' if hand == 'r' else '-90'
        s.add(a % ('-11', roll)); s.w(30); s.add(a % ('2', roll)); s.w(2); s.add(a % ('15', roll)); s.w(2); s.add(a % ('15', '0')); s.w(4)
        s.add('qz_hmd "0 1.6 0 -40 0 0"', a % ('-11', roll)); s.w(60); s.add('qz_hmd "0 1.6 0 0 0 0"', a % ('-11', '0')); s.w(30)
        s.add(REST_R if hand == 'r' else REST_L); s.w(20)
    def text(s): return '; '.join(s.c + ['wait 20', 'quit'])
