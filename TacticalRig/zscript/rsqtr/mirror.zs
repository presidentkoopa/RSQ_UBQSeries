// THE MIRROR (rsqtr_mirror): see yourself wearing the rig.
//
// You can look down at your hips, but never at your own shoulders or back. So a copy of you stands in front of you: the torso, every region's sphere, what
// each region holds, and your two hands (small green spheres), moving as you move.
//   rsqtr_mirror       0 off, 1 while moving the regions (the default), 2 always
//   rsqtr_mirror_view  0 your front, as a mirror shows it (reach for your right shoulder
//                        and the mirrored hand goes to the mirrored shoulder)
//                      1 your back, as someone behind you sees it (left is on the left)
//                      2 both, side by side (front on the left, back on the right)
//   rsqtr_mirror_m     metres from your eyes to it
//
// Copies only (this machine's own actors, like the rings): no camera texture, nothing
// rendered twice. The front view reflects positions and headings; a mesh is not turned
// inside out, so a gun's left side shows where its right side would.
//
// THE WEB'S MIRROR (RSQ Wheel's "Web View: Mirror", owner 2026-11-07 10:32): the same front view, drawn small on the
// Wheel's holster web panel, asked by name (RSQTR_RigService "mirror.web", hooks.zs). A third view, `web`: every copy is
// carried from your body (its yaw, from your eyes) onto the panel, reflected as the front view is (you see your left on
// your left), shrunk so the highest and lowest gun holsters land where the Wheel asks, its front at the panel's middle.
class RSQTR_MirrorView play
{
	Actor mBody, mBreath, mHelmet;
	Actor mMark[RSQTR_Region.N];
	Actor mIcon[RSQTR_Region.N];
	Actor mHand[2];
	// THE REST OF WHAT YOU WEAR (11-03, the owner: "the torso rig will need to always show cigarette, whip, grenade, sabers,
	// shieldsaw"): the grenade at the buckle (rig.nadeShow), the cigarettes in the pocket (RSQTR_Cig.packShow) and RSQ
	// ShieldSaw's shield on your back (its SSQ_Prop, found by name within EXTRA_NEAR of you). The stowed guns, sabers,
	// whip and flare are icon[] above.
	const NEXTRA = 8;
	const EXTRA_NEAR = 1.5;    // metres
	const MIRROR_MARK = 0x52534D52;
	Actor mExtra[NEXTRA];

	// The plane: a point on it, its normal (the body's forward), the body's yaw; `back`
	// shows the rig turned to face away instead of reflected; `side` shifts it to the left.
	Vector2 plane, n;
	double yaw, side;
	Vector3 head;
	bool back;

	// the web's view (RSQ Wheel's panel): body frame (bF forward, bL left, up) from `anchor`, onto the panel's frame (wN
	// toward your eyes, wRt right, wUp up) at wO, shrunk by wk
	bool web;
	double wk;
	Vector3 anchor, bF, bL, wO, wN, wRt, wUp;

	Vector3 WebMap(Vector3 v)
	{
		Vector3 d = v - anchor;
		return wO + (wN * (d dot bF) - wRt * (d dot bL) + wUp * d.z) * wk;
	}
	Vector3 WebDir(Vector3 v) { return wN * (v dot bF) - wRt * (v dot bL) + wUp * v.z; }

	Vector3 Map(Vector3 v)
	{
		if (web) return WebMap(v);
		Vector2 lft = (-n.y, n.x);
		Vector2 xy;
		if (back) xy = v.xy + n * (2 * ((plane - head.xy) dot n));   // carried out to where the mirror image stands
		else xy = v.xy - n * (2 * ((v.xy - plane) dot n));          // reflected in the plane
		return (xy + lft * side, v.z);
	}
	double MapAngle(double a) { return back ? a : 2 * yaw + 180 - a; }
	double MapRoll(double r) { return back ? r : -r; }

	Actor Copy(Actor m, Actor src)
	{
		if (!src || src.bINVISIBLE)
		{
			if (m) m.bINVISIBLE = true;
			return m;
		}
		if (m && m.GetClass() != src.GetClass()) { m.Destroy(); m = null; }
		if (!m) m = Actor.Spawn(src.GetClass(), src.pos);
		if (!m) return null;
		let si = RSQTR_Icon(src), mi = RSQTR_Icon(m);
		if (si && mi && si.wearing != "") mi.Wear(si.wearing, si.Scale.X, si.Alpha);
		let sn = RSQTR_NadeShow(src), mn = RSQTR_NadeShow(m);
		if (sn && mn) mn.Mimic(sn);
		m.SetOrigin(Map(src.pos), true);
		if (web)
		{
			// reflected as the front view is: forward and up carried over, left made from them (the mesh is not turned
			// inside out)
			Vector3 sF, sL, sU;
			[sF, sL, sU] = RSQTR_Fit.Basis(src.angle, src.pitch, src.roll);
			Vector3 F = WebDir(sF), U = WebDir(sU);
			Vector3 L = U cross F;
			m.angle = atan2(F.y, F.x);
			m.pitch = -asin(clamp(F.z, -1.0, 1.0));
			Vector3 F0, L0, U0;
			[F0, L0, U0] = RSQTR_Fit.Basis(m.angle, m.pitch, 0);
			m.roll = atan2(L dot U0, L dot L0);
		}
		else
		{
			m.angle = MapAngle(src.angle);
			m.pitch = src.pitch;
			m.roll = MapRoll(src.roll);
		}
		// A model drawn off its own origin (a held model's grip offset) cannot be reflected by its
		// origin alone: the mesh is not turned inside out, so its side offset would land on the
		// wrong side. Its middle is reflected instead, and the offset applied in the copy's turn.
		if (si && si.hasOff)
		{
			Vector3 F, L, U;
			[F, L, U] = RSQTR_Fit.Basis(m.angle, m.pitch, m.roll);
			m.SetOrigin(Map(si.placed) - (F * si.cOff.x + L * si.cOff.y + U * si.cOff.z) * (web ? wk : 1.0), true);
		}
		m.sprite = src.sprite;
		m.frame = src.frame;
		m.Scale = src.Scale * (web ? wk : 1.0);
		m.A_SetRenderStyle(src.Alpha, src.GetRenderStyle());
		m.Translation = src.Translation;   // colour-blind play recolours by translation and shade
		m.SetShade(src.fillcolor);
		m.bINVISIBLE = false;
		return m;
	}

	void Update(PlayerPawn pmo, RSQTR_Rig rig, RSQTR_Torso tor)
	{
		mBody = Copy(mBody, tor ? tor.body : null);
		mBreath = Copy(mBreath, tor ? tor.breath : null);
		mHelmet = Copy(mHelmet, tor ? tor.helmet : null);
		if (mHelmet) mHelmet.bONLYVISIBLEINMIRRORS = false;     // the copy IS the mirror
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			mMark[r] = Copy(mMark[r], rig.marker[r]);
			mIcon[r] = Copy(mIcon[r], rig.icon[r]);
		}
		Actor src[NEXTRA];
		int ns = 0;
		src[ns++] = rig.nadeShow;
		let cig = RSQTR_Cig.Get();
		for (int k = 0; k < RSQTR_Cig.PACK_SHOWN; k++) src[ns++] = cig ? cig.packShow[k] : null;
		String sn = "SSQ_Prop";
		class<Actor> sc = sn;
		Actor shield = null;
		if (sc)
		{
			let it = ThinkerIterator.Create(sc);
			Actor a;
			while (a = Actor(it.Next())) if (!a.bINVISIBLE && RSQTR_Body.RoomMetres(a.pos, pmo.pos + (0, 0, pmo.height * 0.5)) < EXTRA_NEAR) { shield = a; break; }
		}
		src[ns++] = shield;
		for (int k = 0; k < 2; k++) src[ns++] = rig.fnfMark[k];    // RSQ FlashFlare's pocket and clip spheres (rig.zs DrawFnFMarkers)
		for (int k = 0; k < NEXTRA; k++)
		{
			mExtra[k] = Copy(mExtra[k], k < ns ? src[k] : null);
			if (mExtra[k]) mExtra[k].special2 = MIRROR_MARK;    // a copy of another mod's class: ClearLocalMarks knows it by this
		}
		for (int h = 0; h < 2; h++)
		{
			if (!mHand[h]) mHand[h] = Actor.Spawn("RSQTR_Marker", head);
			if (!mHand[h]) continue;
			mHand[h].SetOrigin(Map(RSQTR_Body.Hand(pmo, h)), true);
			double s = 0.035 * RSQTR_Body.Upm() * (web ? wk : 1.0);
			mHand[h].Scale = (s, s);
			mHand[h].frame = RSQTR_Rig.MarkerFrame(true, 1);
			mHand[h].Alpha = 0.9;
			mHand[h].bINVISIBLE = false;
		}
	}

	void Hide()
	{
		if (mBody) mBody.bINVISIBLE = true;
		if (mBreath) mBreath.bINVISIBLE = true;
		if (mHelmet) mHelmet.bINVISIBLE = true;
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			if (mMark[r]) mMark[r].bINVISIBLE = true;
			if (mIcon[r]) mIcon[r].bINVISIBLE = true;
		}
		for (int h = 0; h < 2; h++) if (mHand[h]) mHand[h].bINVISIBLE = true;
		for (int k = 0; k < NEXTRA; k++) if (mExtra[k]) mExtra[k].bINVISIBLE = true;
	}
}

class RSQTR_Mirror : EventHandler
{
	private transient RSQTR_MirrorView views[2];
	// THE MIRROR STANDS STILL. Placed in front of you when it appears and left there, like
	// a real one: it does not follow your head or body round (it did: "it keeps spinning all
	// around me"). It is put back in front of you when you walk 3 m from it or turn more than
	// 100 degrees away from it.
	private transient bool anchored;
	private transient Vector2 aPlane, aN;
	private transient double aYaw;

	// THE WEB'S MIRROR (hooks.zs "mirror.web"): shown while RSQ Wheel asks for it, every tic; hidden the tic it stops
	private transient RSQTR_MirrorView webView;
	private transient int webTic;
	const WEB_FRONT_M = 0.30;   // the copy's front: this far in front of the most forward gun holster (metres; the torso reaches past
	                            // it: at 0.05 it hid the chest and hip rings, rig frames 2026-11-07)
	const WEB_BACK_M = 0.30;    // its back: this far behind the rearmost one (the ShieldSaw over the shoulder, the torso)
	static const int GUNS[] = { 0, 1, 4, 5, 6, 7 };

	String WebShow(String args, bool show)
	{
		if (!show) { if (webView) webView.Hide(); webTic = 0; return ""; }
		let p = players[consoleplayer];
		let rig = RSQTR_Rig.Get();
		if (!rig || !p || !p.mo || p.mo.health <= 0 || !RSQTR_Rig.Flag("rsqtr_on", p, true)) { if (webView) webView.Hide(); return ""; }
		Array<String> t;
		args.Split(t, " ", TOK_SKIPEMPTY);
		if (t.Size() < 7) return "";
		let pmo = p.mo;
		Vector3 c = (t[0].ToDouble(), t[1].ToDouble(), t[2].ToDouble());
		double yaw = t[3].ToDouble(), tilt = t[4].ToDouble(), top = t[5].ToDouble(), bottom = t[6].ToDouble();
		if (!webView) webView = new("RSQTR_MirrorView");
		let v = webView;
		v.web = true;
		double by = rig.BodyYaw(pmo);
		v.bF = (cos(by), sin(by), 0);
		v.bL = (-sin(by), cos(by), 0);
		v.anchor = RSQTR_Body.Head(pmo);
		v.head = v.anchor;
		double cy = cos(yaw), sy = sin(yaw), ct = cos(tilt), st = sin(tilt);
		v.wRt = (-sy, cy, 0);
		v.wUp = (-cy * st, -sy * st, ct);
		v.wN = (cy * ct, sy * ct, st);
		// the gun holsters' spread, from your eyes: up (map units) and forward
		double uHi = -1e9, uLo = 1e9, fHi = -1e9, fLo = 1e9;
		for (int i = 0; i < 6; i++)
		{
			Vector3 d = rig.RegionAt(pmo, GUNS[i]) - v.anchor;
			uHi = max(uHi, d.z); uLo = min(uLo, d.z);
			double f = d dot v.bF;
			fHi = max(fHi, f); fLo = min(fLo, f);
		}
		double upm = RSQTR_Body.Upm();
		v.wk = (uHi - uLo) > 1.0 ? (top - bottom) / (uHi - uLo) : 0.4;
		double front = fHi + WEB_FRONT_M * upm;
		v.wO = c + v.wUp * (top - v.wk * uHi) - v.wN * (v.wk * front);
		v.Update(pmo, rig, RSQTR_Torso(EventHandler.Find("RSQTR_Torso")));
		webTic = gametic;
		String ans = String.Format("%.3f", v.wk * (front - (fLo - WEB_BACK_M * upm)));
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			Vector3 q = v.WebMap(rig.RegionAt(pmo, r));
			bool item = v.mIcon[r] && !v.mIcon[r].bINVISIBLE;   // the copy shows what that place holds
			ans = ans .. String.Format(" %.3f %.3f %.3f %d", q.x, q.y, q.z, item ? 1 : 0);
		}
		return ans;
	}

	override void WorldTick()
	{
		if (webView && webTic > 0 && gametic > webTic + 1) { webView.Hide(); webTic = 0; }
		let p = players[consoleplayer];
		let rig = RSQTR_Rig.Get();
		int mode = (p && p.mo) ? RSQTR_Rig.Opt("rsqtr_mirror", p, 1) : 0;
		bool want = rig && p.mo.health > 0 && RSQTR_Rig.Flag("rsqtr_on", p, true)
			&& (mode == 2 || (mode == 1 && RSQTR_Rig.Flag("rsqtr_edit", p, false)));
		int view = want ? RSQTR_Rig.Opt("rsqtr_mirror_view", p, 2) : -1;
		let pmo = want ? p.mo : null;
		if (!want) anchored = false;
		else
		{
			double by = rig.BodyYaw(pmo);
			Vector3 h3 = RSQTR_Body.Head(pmo);
			Vector2 hd = h3.xy;
			double dist = RSQTR_Rig.Num("rsqtr_mirror_m", p, 1.0) * RSQTR_Body.Upm();
			if (anchored && ((hd - aPlane).Length() > 3.0 * RSQTR_Body.Upm() + dist || abs(Actor.DeltaAngle(aYaw, by)) > 100))
				anchored = false;
			if (!anchored)
			{
				aYaw = by;
				aN = (cos(by), sin(by));
				aPlane = hd + aN * dist;
				anchored = true;
			}
		}
		let tor = RSQTR_Torso(EventHandler.Find("RSQTR_Torso"));
		for (int i = 0; i < 2; i++)
		{
			// view 0: the front only; 1: the back only; 2: both, front left, back right
			bool show = view == 2 || view == i;
			if (!views[i]) views[i] = new("RSQTR_MirrorView");
			let v = views[i];
			if (!show) { v.Hide(); continue; }
			v.yaw = aYaw;
			v.n = aN;
			v.head = RSQTR_Body.Head(pmo);
			v.plane = aPlane;
			v.back = i == 1;
			v.side = view == 2 ? (i == 0 ? 0.45 : -0.45) * RSQTR_Body.Upm() : 0;
			v.Update(pmo, rig, tor);
		}
	}
}
