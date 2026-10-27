// RSQ_Accessibility -- round two: the parts this pk3 runs itself (README.md "Round two").
//
//   RSQA_Set       the settings, read in one place (every series mod carries the same few lines
//                  under its own prefix, tools/a11y_template.zs; this class is for this pk3 only)
//   RSQA_Handler   the One-Handed binds (the Off-Hand Modifier and the gesture buttons, Hold to
//                  Toggle), the comfort vignette, and the sound cues: hits and shots from off-view,
//                  slow motion starting and stopping, lock / grab ready on request
//   RSQA_Service   how series mods reach it, by name (nothing links):
//                    GetInt("swap", "", playerNumber)        1 while that player's main hand plays
//                                                            the off hand's part (One-Handed on);
//                                                            GetIntData too (any scope)
//                    GetInt("vignette", source, playerNumber, strength 0..1)
//                                                            a comfort moment this tic (Comfort
//                                                            Vignette on); the strongest wins
//                    GetInt("ready", "", playerNumber, hand) a lock / grab-ready cue on that hand:
//                                                            a short rumble when Sound Cues has it
//   RSQA_MenuMode  Simple / Full: the series' front option pages without / with their sub-pages

class RSQA_Set
{
	static clearscope int I(Name n, int d = 0)
	{
		let cv = CVar.FindCVar(n);
		return cv ? cv.GetInt() : d;
	}
	static clearscope double F(Name n, double d = 0)
	{
		let cv = CVar.FindCVar(n);
		return cv ? cv.GetFloat() : d;
	}
	static clearscope bool OneHand()    { return I('rsqa_onehand') != 0; }
	static clearscope bool HoldToggle() { return I('rsqa_hold_toggle') != 0; }
	static clearscope bool Photo()      { return I('rsqa_photosafe') != 0; }
	static clearscope int  Vignette()   { return clamp(I('rsqa_vignette'), 0, 3); }
	static clearscope bool CueVisual()  { return (I('rsqa_sound_cues') & 1) != 0; }
	static clearscope bool CueRumble()  { return (I('rsqa_sound_cues') & 2) != 0; }
	static clearscope double Cue()      { return clamp(F('rsqa_cue_scale', 1.0), 0.5, 3.0); }
	static clearscope double Text()     { return clamp(F('rsqa_text_scale', 1.0), 1.0, 3.0); }
	static clearscope int  ColorBlind() { return clamp(I('rsqa_colorblind'), 0, 4); }
}

class RSQA_Handler : EventHandler
{
	// THE OFF-HAND MODIFIER, per player. Not saved: a key held across a save is not held after the
	// load, and every machine resets it on the same load, so it stays in step.
	transient bool swap[MAXPLAYERS];
	// Hold to Toggle, this machine's side: which held binds are latched on now (ui writes only).
	ui bool latch[10];

	// THE VIGNETTE: the strongest comfort request this tic (play), eased per tic for the local view.
	transient double vigReq[MAXPLAYERS];
	transient int    vigTic[MAXPLAYERS];
	transient double vig, vigLast;
	ui bool vigShown;

	// THE OFF-VIEW CUES: where a hit or a shot came from, kept 1.2 s (the local player's only).
	const THREATS = 8;
	const THREAT_TICS = 42;
	transient Vector3 thPos[THREATS];
	transient int     thTic[THREATS];
	transient int     thKind[THREATS];    // 1 a hit on you, 2 a shot coming at you
	transient Actor   thFrom[THREATS];

	// SLOW MOTION starting and stopping (RSQ_SlowMo's service, asked by name).
	transient bool smWas;
	transient int  smEdge;                // maptime of the last change, + = started, - = stopped

	static RSQA_Handler Get() { return RSQA_Handler(EventHandler.Find("RSQA_Handler")); }

	override void WorldLoaded(WorldEvent e)
	{
		for (int i = 0; i < MAXPLAYERS; i++) { swap[i] = false; vigReq[i] = 0; vigTic[i] = -100; }
		vig = 0; vigLast = 0;
		for (int i = 0; i < THREATS; i++) thTic[i] = -1000;
		smWas = false; smEdge = 0;
	}

	// ---- the binds ---------------------------------------------------------------------
	// KEYCONF: `event rsqa_key <code> <down>`. Checked here, on the machine that pressed; the
	// result goes out as one network event (rsqa_mod / rsqa_alt, or SlowMo's rsm_toggle).
	override void ConsoleProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "rsqa_key")) return;
		if (!RSQA_Set.OneHand()) return;
		int code = e.Args[0];
		bool down = e.Args[1] != 0;
		if (code < 0 || code > 8) return;
		if (code == 8) { if (down) EventHandler.SendNetworkEvent("rsm_toggle"); return; }
		bool held = code == 0 || code == 2 || code == 5;
		if (held && RSQA_Set.HoldToggle())
		{
			// a press flips it, a release does nothing
			if (!down) return;
			latch[code] = !latch[code];
			down = latch[code];
		}
		else if (held) latch[code] = down;
		if (code == 0) EventHandler.SendNetworkEvent("rsqa_mod", down ? 1 : 0);
		else EventHandler.SendNetworkEvent("rsqa_alt", code, down ? 1 : 0);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Player < 0 || e.Player >= MAXPLAYERS) return;
		if (e.Name ~== "rsqa_mod")
		{
			swap[e.Player] = e.Args[0] != 0 && RSQA_Set.OneHand();
			let mo = playeringame[e.Player] ? players[e.Player].mo : null;
			// a tick on the main hand: the hand changed parts (only felt, never heard)
			if (mo) RSQA_Buzz.Start(mo, 0, swap[e.Player] ? 0.45 : 0.25, 3);
		}
	}

	clearscope bool Swapped(int pn)
	{
		return pn >= 0 && pn < MAXPLAYERS && swap[pn] && RSQA_Set.OneHand();
	}

	// ---- every tic ---------------------------------------------------------------------
	override void WorldTick()
	{
		// the One-Handed setting switched off while the modifier was held lets it go
		if (!RSQA_Set.OneHand()) for (int i = 0; i < MAXPLAYERS; i++) swap[i] = false;
		VignetteTick();
		SlowMoTick();
	}

	// THE COMFORT VIGNETTE (rsqa_vignette). Series mods report a comfort moment every tic it lasts
	// (a grapple swing, yank or climb, a Force jump), with how strong; it eases in over 0.2 s and
	// out over 0.4 s, so it never snaps (a snap at the edge of view is its own discomfort).
	private void VignetteTick()
	{
		vigLast = vig;
		int pn = consoleplayer;
		double want = (RSQA_Set.Vignette() > 0 && level.maptime - vigTic[pn] <= 1) ? clamp(vigReq[pn], 0.0, 1.0) : 0.0;
		if (want > vig) vig = min(want, vig + 1.0 / 7.0);
		else if (want < vig) vig = max(want, vig - 1.0 / 14.0);
		if (level.maptime - vigTic[pn] > 1) vigReq[pn] = 0;
	}

	void Comfort(int pn, double strength)
	{
		if (pn < 0 || pn >= MAXPLAYERS || RSQA_Set.Vignette() <= 0) return;
		if (vigTic[pn] != level.maptime) { vigReq[pn] = 0; vigTic[pn] = level.maptime; }
		vigReq[pn] = max(vigReq[pn], clamp(strength, 0.0, 1.0));
	}

	// SLOW MOTION STARTING AND STOPPING: SlowMo's own sounds say it; with Sound Cues on, both
	// controllers give a long soft rumble starting and a short one stopping, and a steady label
	// says it is on (RenderOverlay). A pulse (a reload's, the cigarette's) counts too.
	private void SlowMoTick()
	{
		if (!RSQA_Set.CueVisual() && !RSQA_Set.CueRumble()) { smWas = false; return; }
		let it = ServiceIterator.Find("RSQSM_Service");
		let s = it.Next();
		bool now = s && s.GetInt("slowmo.active") == 1;
		if (now == smWas) return;
		smWas = now;
		smEdge = now ? level.maptime : -level.maptime;
		let mo = players[consoleplayer].mo;
		if (mo && RSQA_Set.CueRumble())
		{
			RSQA_Buzz.Start(mo, 0, now ? 0.5 : 0.3, now ? 10 : 5);
			RSQA_Buzz.Start(mo, 1, now ? 0.5 : 0.3, now ? 10 : 5);
		}
	}

	// ---- the off-view cues ---------------------------------------------------------------
	// A HIT ON YOU from a source you can see is not news; one from beside or behind is. So is a
	// shot on its way to you from out of view (a monster's missile, Brutal Doom's tracers, a
	// hitscan). Remembered with where it came from; drawn as an arrow round the middle of the
	// view, and felt on the controller on that side.
	override void WorldThingDamaged(WorldEvent e)
	{
		if (!e.Thing || !e.Thing.player || e.Thing.player != players[consoleplayer] || e.Damage <= 0) return;
		Actor src = e.DamageSource ? e.DamageSource : e.Inflictor;
		if (!src || src == e.Thing) return;
		Note(src, src.pos, 1);
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let m = e.Thing;
		if (!m || !m.bMISSILE || !m.target || m.target.player || !m.target.bISMONSTER) return;
		if (!RSQA_Set.CueVisual() && !RSQA_Set.CueRumble()) return;
		let pmo = players[consoleplayer].mo;
		if (!pmo || pmo.health <= 0) return;
		Vector3 to = level.Vec3Diff(m.pos, pmo.pos + (0, 0, pmo.height * 0.5));
		double d = to.Length();
		if (d < 1 || d > 2048 || m.vel.Length() < 0.1) return;
		if ((m.vel.Unit() dot (to / d)) < 0.94) return;    // within 20 degrees of coming at you
		Note(m.target, m.target.pos, 2);
	}

	override void WorldHitscanFired(WorldEvent e)
	{
		let src = e.Thing;
		if (!src || src.player || !src.bISMONSTER || !src.target || src.target != players[consoleplayer].mo) return;
		if (!RSQA_Set.CueVisual() && !RSQA_Set.CueRumble()) return;
		Note(src, src.pos, 2);
	}

	private void Note(Actor from, Vector3 at, int kind)
	{
		if (!RSQA_Set.CueVisual() && !RSQA_Set.CueRumble()) return;
		let pmo = players[consoleplayer].mo;
		if (!pmo) return;
		// one arrow per source: a burst of tracers is one cue, renewed
		int slot = -1, oldest = 0;
		for (int i = 0; i < THREATS; i++)
		{
			if (thFrom[i] == from && level.maptime - thTic[i] < THREAT_TICS) { slot = i; break; }
			if (thTic[i] < thTic[oldest]) oldest = i;
		}
		bool fresh = slot < 0 || level.maptime - thTic[slot] > 12;
		bool same = slot >= 0;
		if (slot < 0) slot = oldest;
		thPos[slot] = at;
		thTic[slot] = level.maptime;
		thKind[slot] = same ? max(kind, thKind[slot]) : kind;   // a hit outranks a shot coming
		thFrom[slot] = from;
		// the rumble only when it is out of view (40 degrees off where the body faces) and new
		double rel = Actor.DeltaAngle(pmo.angle, pmo.AngleTo(from));
		if (fresh && abs(rel) > 40 && RSQA_Set.CueRumble())
			RSQA_Buzz.Start(pmo, (rel > 0) != RSQA_Hand.EngineLeft() ? 1 : 0, kind == 1 ? 0.6 : 0.4, kind == 1 ? 5 : 3);
	}

	// ---- drawing ----------------------------------------------------------------------------
	override void RenderOverlay(RenderEvent e)
	{
		DrawVignette(e);
		if (!RSQA_Set.CueVisual()) return;
		DrawThreats(e);
		DrawSlowMo(e);
	}

	ui void DrawVignette(RenderEvent e)
	{
		int lv = RSQA_Set.Vignette();
		double v = lv > 0 ? vigLast + (vig - vigLast) * e.FracTic : 0.0;
		if (v <= 0.005)
		{
			if (vigShown) { PPShader.SetEnabled("RSQA_Vignette", false); vigShown = false; }
			return;
		}
		// Light / Medium / Strong: how dark the edge gets, and how far in the dark reaches
		static const double DARK[] = { 0.0, 0.55, 0.75, 0.92 };
		static const double INNER[] = { 1.0, 0.62, 0.48, 0.34 };
		PPShader.SetUniform1f("RSQA_Vignette", "rsqaStrength", DARK[lv] * v);
		PPShader.SetUniform1f("RSQA_Vignette", "rsqaInner", INNER[lv] + (1.0 - INNER[lv]) * (1.0 - v) * 0.5);
		if (!vigShown) { PPShader.SetEnabled("RSQA_Vignette", true); vigShown = true; }
	}

	ui void DrawThreats(RenderEvent e)
	{
		let pmo = players[consoleplayer].mo;
		if (!pmo) return;
		double w = Screen.GetWidth(), h = Screen.GetHeight();
		double cx = w * 0.5, cy = h * 0.5;
		double sc = RSQA_Set.Cue();
		double r = min(w, h) * 0.30;
		double sz = min(w, h) * 0.035 * sc;
		int cb = RSQA_Set.ColorBlind();
		for (int i = 0; i < THREATS; i++)
		{
			int age = level.maptime - thTic[i];
			if (age < 0 || age >= THREAT_TICS) continue;
			Vector3 d = level.Vec3Diff(e.ViewPos, thPos[i]);
			double rel = Actor.DeltaAngle(e.ViewAngle, atan2(d.y, d.x));
			if (abs(rel) <= 35) continue;          // in view: you can see it
			double fade = 1.0 - (age + e.FracTic) / THREAT_TICS;
			int a = int(255 * clamp(fade * 1.4, 0.0, 1.0));
			// a hit: the HAVE colour, big and filled; a shot coming: the COULD colour, an open chevron
			Color c = thKind[i] == 1 ? Color(255, 255, 48, 48) : Color(255, 255, 176, 0);
			if (cb > 0)
			{
				static const int HAVE[] = { 0, 0x3090FF, 0x3090FF, 0x00E0E0, 0xFF40FF };
				static const int COULD[] = { 0, 0xFFB000, 0xFFB000, 0xFF4040, 0xFFFF00 };
				int rgb = thKind[i] == 1 ? HAVE[cb] : COULD[cb];
				c = Color(255, (rgb >> 16) & 255, (rgb >> 8) & 255, rgb & 255);
			}
			double s = sin(rel), co = cos(rel);
			// screen: up is ahead, left is +angle
			Vector2 dir = (-s, -co);
			Vector2 side = (co, -s);
			Vector2 tip = (cx, cy) + dir * (r + sz);
			Vector2 b1 = (cx, cy) + dir * r + side * sz * 0.8;
			Vector2 b2 = (cx, cy) + dir * r - side * sz * 0.8;
			double th = max(2.0, sz * (thKind[i] == 1 ? 0.35 : 0.2));
			Screen.DrawThickLine(tip.x, tip.y, b1.x, b1.y, th, c, a);
			Screen.DrawThickLine(tip.x, tip.y, b2.x, b2.y, th, c, a);
			if (thKind[i] == 1)
			{
				Vector2 m = (cx, cy) + dir * (r + sz * 0.45);
				Screen.DrawThickLine(m.x + side.x * sz * 0.4, m.y + side.y * sz * 0.4, m.x - side.x * sz * 0.4, m.y - side.y * sz * 0.4, th, c, a);
			}
		}
	}

	ui void DrawSlowMo(RenderEvent e)
	{
		bool on = smEdge > 0;
		int since = level.maptime - abs(smEdge);
		if (!on && (smEdge == 0 || since > 35)) return;
		String t = on ? "Slow Motion" : "Normal Speed";
		double sc = RSQA_Set.Text();
		double vw = 640 / sc, vh = 400 / sc;
		let f = NewSmallFont;
		double x = (vw - f.StringWidth(t)) * 0.5;
		double alpha = on ? 1.0 : clamp(1.0 - since / 35.0, 0.0, 1.0);
		Screen.DrawText(f, on ? Font.CR_LIGHTBLUE : Font.CR_GRAY, x, vh * 0.16, t,
			DTA_VirtualWidthF, vw, DTA_VirtualHeightF, vh, DTA_KeepRatio, true, DTA_Alpha, alpha);
	}
}

// How series mods reach this pk3, by name (no hard link; an absent pk3 is a Find that finds nothing).
class RSQA_Service : Service
{
	// "swap" from any scope (a hand pose is read in ui code too: a grapple's local aim)
	override int GetIntData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQA_Handler(EventHandler.Find("RSQA_Handler"));
		if (!h) return -1;
		if (request ~== "swap") return h.Swapped(intArg) ? 1 : 0;
		return -1;
	}

	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQA_Handler.Get();
		if (!h) return -1;
		if (request ~== "swap") return h.Swapped(intArg) ? 1 : 0;
		if (request ~== "vignette") { h.Comfort(intArg, doubleArg); return RSQA_Set.Vignette(); }
		if (request ~== "ready")
		{
			if (!RSQA_Set.CueRumble() || intArg < 0 || intArg >= MAXPLAYERS || !playeringame[intArg]) return 0;
			RSQA_Buzz.Start(players[intArg].mo, int(doubleArg) ? 1 : 0, 0.5, 3);
			return 1;
		}
		return -1;
	}
}

// A RUMBLE WITH A LENGTH AND A STRENGTH on one controller (0 main, 1 off), the series' route:
// A_QuakeEx QF_WAVE re-issued every tic (X = the left controller, Y = the right; which is the main
// hand is the engine's vr_control_scheme). The local player only.
class RSQA_Buzz : Actor
{
	Actor feels;
	bool left;
	double amp;
	int total, tleft;

	Default { +NOINTERACTION +NOBLOCKMAP +NOSECTOR +DONTSPLASH }

	static void Start(Actor who, int hand, double strength, int tics)
	{
		if (!who || !who.player || who.player != players[consoleplayer]) return;
		let q = RSQA_Buzz(Actor.Spawn("RSQA_Buzz", who.pos));
		if (!q) return;
		q.feels = who;
		q.left = (hand == 1) != RSQA_Hand.EngineLeft();
		q.amp = clamp(strength, 0.05, 1.0);
		q.total = clamp(tics, 1, 16);
		q.tleft = q.total;
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		if (tleft <= 0) return;
		double a = amp * tleft / double(total) / 3.2;
		tleft--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}

	States { Spawn: TNT1 A 20; Stop; }
}

// ---- SIMPLE / FULL (rsqa_menus) ---------------------------------------------------------------
// The series' front option pages each end in links to their niche pages (Tuning and Debug, Rope
// and Tuning, Look, Swing and Cuts...). Simple takes those links off the front pages, so a front
// page is the everyday switches and nothing else; Full puts them back. Nothing is deleted: each
// front page's full row list is kept the first time it is touched and rebuilt from that copy.
// Only links into the same series' pages go (by menu-name prefix); a link to another mod's menu,
// a command and every setting stay. The Accessibility page itself is not touched.
class RSQA_MenuCopy ui
{
	Name menu;
	Array<OptionMenuItem> rows;
}

class RSQA_MenuMode : StaticEventHandler
{
	ui Array<RSQA_MenuCopy> copies;
	ui int applied;
	ui bool started;

	static const Name FRONT[] = {
		'UBQS_Options', 'SSQ_Options', 'RSQTR_Options', 'RSQDG_Options', 'RSQSM_Options',
		'RSQLS_Options', 'RSQGR_Options', 'RSQ_MeleeOptions', 'RSQUI_Options', 'RSQSC_Options',
		'RSQTHP_Options'
	};

	override void UiTick()
	{
		int want = clamp(RSQA_Set.I('rsqa_menus'), 0, 1);
		if (started && want == applied) return;
		started = true;
		applied = want;
		for (int i = 0; i < FRONT.Size(); i++) Apply(FRONT[i], want == 1);
	}

	ui void Apply(Name menu, bool simple)
	{
		let desc = OptionMenuDescriptor(MenuDescriptor.GetDescriptor(menu));
		if (!desc) return;
		RSQA_MenuCopy copy = null;
		for (int i = 0; i < copies.Size(); i++) if (copies[i].menu == menu) { copy = copies[i]; break; }
		if (!copy)
		{
			if (!simple) return;       // never touched and Full: nothing to do
			copy = new("RSQA_MenuCopy");
			copy.menu = menu;
			copy.rows.Copy(desc.mItems);
			copies.Push(copy);
		}
		Array<OptionMenuItem> rows;
		for (int i = 0; i < copy.rows.Size(); i++)
		{
			let it = copy.rows[i];
			if (simple && Niche(it)) continue;
			// no two spacers in a row, none first
			if (simple && IsSpacer(it) && (rows.Size() == 0 || IsSpacer(rows[rows.Size() - 1]))) continue;
			rows.Push(it);
		}
		while (simple && rows.Size() > 0 && IsSpacer(rows[rows.Size() - 1])) rows.Pop();
		desc.mItems.Move(rows);
		desc.mSelectedItem = -1;
		desc.mScrollPos = 0;
	}

	static ui bool IsSpacer(OptionMenuItem it)
	{
		return it is "OptionMenuItemStaticText" && !it.Selectable() && (it.mLabel == " " || it.mLabel == "");
	}

	static ui bool Niche(OptionMenuItem it)
	{
		let sm = OptionMenuItemSubmenu(it);
		if (!sm || it is "OptionMenuItemCommand") return false;   // a (Safe)Command is a Submenu underneath
		static const String SERIES[] = {
			"ubqs_", "ssq_", "rsqtr_", "rsqdg_", "rsqsm_", "rsqls_", "rsqgr_", "rsq_melee", "rsqui_",
			"rsqsc_", "rsqthp_", "tophpbars_"
		};
		String to = sm.GetAction();
		to = to.MakeLower();
		for (int i = 0; i < SERIES.Size(); i++)
			if (to.IndexOf(SERIES[i]) == 0) return true;
		return false;
	}
}
