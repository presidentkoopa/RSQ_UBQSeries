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
class RSQTR_MirrorView play
{
	Actor mBody, mBreath, mHelmet;
	Actor mMark[RSQTR_Region.N];
	Actor mIcon[RSQTR_Region.N];
	Actor mHand[2];

	// The plane: a point on it, its normal (the body's forward), the body's yaw; `back`
	// shows the rig turned to face away instead of reflected; `side` shifts it to the left.
	Vector2 plane, n;
	double yaw, side;
	Vector3 head;
	bool back;

	Vector3 Map(Vector3 v)
	{
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
		m.SetOrigin(Map(src.pos), true);
		m.angle = MapAngle(src.angle);
		m.pitch = src.pitch;
		m.roll = MapRoll(src.roll);
		// A model drawn off its own origin (a held model's grip offset) cannot be reflected by its
		// origin alone: the mesh is not turned inside out, so its side offset would land on the
		// wrong side. Its middle is reflected instead, and the offset applied in the copy's turn.
		if (si && si.hasOff)
		{
			Vector3 F, L, U;
			[F, L, U] = RSQTR_Fit.Basis(m.angle, m.pitch, m.roll);
			m.SetOrigin(Map(si.placed) - (F * si.cOff.x + L * si.cOff.y + U * si.cOff.z), true);
		}
		m.sprite = src.sprite;
		m.frame = src.frame;
		m.Scale = src.Scale;
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
		for (int h = 0; h < 2; h++)
		{
			if (!mHand[h]) mHand[h] = Actor.Spawn("RSQTR_Marker", head);
			if (!mHand[h]) continue;
			mHand[h].SetOrigin(Map(RSQTR_Body.Hand(pmo, h)), true);
			double s = 0.035 * RSQTR_Body.Upm();
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

	override void WorldTick()
	{
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
