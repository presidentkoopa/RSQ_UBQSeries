// RSQTR_A11y -- RSQ_Accessibility's round-two settings, read the series' way (RSQ_Accessibility,
// tools/a11y_template.zs, one copy per mod under its own prefix). Every setting reads as OFF unless
// RSQ_Accessibility is loaded (the class-name guard below): a value left in the ini does nothing
// on its own, and every mod still loads and plays alone.
//
//   rsqa_photosafe     strong flashes dimmed to 40%, flicker / pulse rates at most 2.5 a second
//   rsqa_onehand       the Off-Hand Modifier (RSQA_Service "swap") and the gesture buttons (rsqa_alt)
//   rsqa_gesture_ease  0..1: tolerances x1..x2, speed thresholds and hold times x1..x0.5
//   rsqa_vignette      comfort moments reported through RSQA_Service "vignette"
//   rsqa_slowmo_ramp   the shortest a slow-motion ease may be, seconds
//   rsqa_cue_scale     dots, rings, glows, markers x0.5..x3
//   rsqa_text_scale    HUD text x1..x3
//   rsqa_sound_cues    1 visual, 2 rumble, 3 both
//   rsqa_hold_toggle   held binds toggle
class RSQTR_A11y
{
	// PHOTOSENSITIVE MODE's numbers (WCAG 2.3.1 asks for no more than 3 flashes in any second):
	// a pulse or flicker at most 2.5 cycles a second, so a new strong flash at least 14 tics after
	// the last; a strong flash at 40% of its brightness.
	const MAX_HZ = 2.5;
	const MIN_GAP = 14;
	const DIM_K = 0.4;
	const MAX_DEG = 25.7;       // degrees of phase per tic at MAX_HZ (2.5 * 360 / 35)

	static clearscope CVar Cv(Name n)
	{
		CVar cv = null; { Name rsqaN = "RSQA_Menu"; class<Object> rsqaC = rsqaN; if (rsqaC) cv = CVar.FindCVar(n); }  // only while RSQ_Accessibility is loaded: a value left in the ini must not act on its own
		return cv;
	}
	static clearscope int I(Name n) { let cv = Cv(n); return cv ? cv.GetInt() : 0; }
	static clearscope double F(Name n, double d) { let cv = Cv(n); return cv ? cv.GetFloat() : d; }

	// ---- photosensitivity ----
	static clearscope bool Photo() { return I('rsqa_photosafe') != 0; }
	static clearscope double Dim(double v) { return Photo() ? v * DIM_K : v; }
	// a pulse's rate in cycles a second, capped
	static clearscope double Hz(double hz) { return Photo() ? min(hz, MAX_HZ) : hz; }
	// a pulse's phase step, degrees per tic (sin(t * step)), capped
	static clearscope double Deg(double step) { return Photo() ? min(step, MAX_DEG) : step; }
	// a cycle's length in tics, at least MIN_GAP
	static clearscope int Period(int tics) { return Photo() ? max(tics, MIN_GAP) : tics; }
	// may a new strong flash start now, the last one having started at `last`?
	static clearscope bool Gate(int last, int now) { return !Photo() || now - last >= MIN_GAP; }

	// ---- gestures ----
	static clearscope double Ease() { return clamp(F('rsqa_gesture_ease', 0), 0.0, 1.0); }
	static clearscope double Wide(double tol) { return tol * (1.0 + Ease()); }
	static clearscope double Low(double thr) { return thr * (1.0 - 0.5 * Ease()); }
	static clearscope bool OneHand() { return I('rsqa_onehand') != 0; }
	static clearscope bool HoldToggle() { return I('rsqa_hold_toggle') != 0; }

	// ---- comfort ----
	static clearscope int Vignette() { return clamp(I('rsqa_vignette'), 0, 3); }
	static clearscope double SlowRamp() { return max(0.0, F('rsqa_slowmo_ramp', 0)); }

	// ---- size ----
	static clearscope double Cue() { return clamp(F('rsqa_cue_scale', 1.0), 0.5, 3.0); }
	static clearscope double Text() { return clamp(F('rsqa_text_scale', 1.0), 1.0, 3.0); }
	// the font for a centre-screen print (A_Print / Console.MidPrint): the engine's own below Text
	// Size 1.5, the big font at and above it (about twice the height)
	static clearscope Name PrintFont() { return Text() >= 1.5 ? 'BigFont' : 'none'; }

	// ---- hearing ----
	static clearscope bool CueVisual() { return (I('rsqa_sound_cues') & 1) != 0; }
	static clearscope bool CueRumble() { return (I('rsqa_sound_cues') & 2) != 0; }

	// ---- RSQ_Accessibility's service, by name ----
	static clearscope Service Svc()
	{
		let it = ServiceIterator.Find("RSQA_Service");
		return it.Next();
	}
	// the Off-Hand Modifier: this player's main hand plays the off hand's part now
	static clearscope bool Swapped(Actor who)
	{
		if (!who || !who.player || !OneHand()) return false;
		let s = Svc();
		return s && s.GetIntData("swap", "", who.PlayerNumber()) == 1;
	}
	// the controller a hand's part is played by now: 0 the main controller, 1 the off one
	static clearscope int Ctrl(Actor who, int hand)
	{
		return (hand == 1 && Swapped(who)) ? 0 : hand;
	}
	// a comfort moment this tic, strength 0..1 (the vignette eases it in and out)
	static play void Comfort(Actor who, double strength)
	{
		if (!who || !who.player || Vignette() <= 0) return;
		let s = Svc();
		if (s) s.GetInt("vignette", "RSQTR", who.PlayerNumber(), strength);
	}
	// a lock / grab-ready cue on a hand (0 main, 1 off): a short rumble when Sound Cues has it
	static play void Ready(Actor who, int hand)
	{
		if (!who || !who.player || !CueRumble()) return;
		let s = Svc();
		if (s) s.GetInt("ready", "", who.PlayerNumber(), hand);
	}
}
