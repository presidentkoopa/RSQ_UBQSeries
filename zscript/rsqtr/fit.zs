// HOW BIG A STORED GUN IS AND WHICH WAY IT POINTS (lump RSQTRFIT).
//
// A pickup is made to lie on a floor, so every pack picks its own size and facing (measured
// with BD22Q: the Devastator's model points backward, the Machinegun's sideways; lengths run
// from 20 to 210 map units). The game cannot measure a model while it runs, so
// tools/measure_pickups.py measures the load order's pickups ahead of time and writes
//     <Class> <length in map units> <yaw> <pitch> <shown by> <centre x y z> <squat>
// (the turn that brings the muzzle onto the actor's forward axis; the class whose MODELDEF
// draws it -- BD22Q lends its pickups VOXELS through holder classes, so the rig borrows the
// same one, not the gun's first-person model; the middle of its bounds, model axes). Every lump named RSQTRFIT
// is read, so a weapon pack can ship its own; a later one wins for the same class. A weapon
// not in any table is shown at its pickup size and facing, as before.
class RSQTR_Fit
{
	Array<String> cls, holder;
	Array<double> len, yaw, pitch, cx, cy, cz, squat;

	static RSQTR_Fit Load()
	{
		let f = new("RSQTR_Fit");
		int l = -1;
		while ((l = Wads.FindLump("RSQTRFIT", l + 1, Wads.AnyNamespace)) >= 0)
		{
			Array<String> lines;
			Wads.ReadLump(l).Split(lines, "\n");
			for (int i = 0; i < lines.Size(); i++)
			{
				String s = lines[i];
				s.StripRight();
				if (s.Length() == 0 || s.Left(2) == "//") continue;
				Array<String> t;
				s.Split(t, " ", TOK_SKIPEMPTY);
				if (t.Size() < 4) continue;
				String c = t[0];
				c = c.MakeLower();
				int at = f.cls.Find(c);
				if (at == f.cls.Size()) { f.cls.Push(c); f.len.Push(0); f.yaw.Push(0); f.pitch.Push(0); f.holder.Push(t[0]); f.cx.Push(0); f.cy.Push(0); f.cz.Push(0); f.squat.Push(0); }
				f.len[at] = t[1].ToDouble();
				f.yaw[at] = t[2].ToDouble();
				f.pitch[at] = t[3].ToDouble();
				f.holder[at] = t.Size() > 4 ? t[4] : t[0];
				if (t.Size() > 8) f.squat[at] = t[8].ToDouble();
				if (t.Size() > 7) { f.cx[at] = t[5].ToDouble(); f.cy[at] = t[6].ToDouble(); f.cz[at] = t[7].ToDouble(); }
			}
		}
		return f;
	}

	// A class named in rsqtr_icon_flip (space-separated, any case) is shown turned round.
	static bool Listed(String c, PlayerInfo p)
	{
		let cv = CVar.GetCVar("rsqtr_icon_flip", p);
		if (!cv) return false;
		String l = " " .. cv.GetString().MakeLower() .. " ";
		String n = " " .. c.MakeLower() .. " ";
		return l.IndexOf(n) >= 0;
	}

	Vector3 Centre(int at) { return (cx[at], cy[at], cz[at]); }

	int Find(String c)
	{
		c = c.MakeLower();
		int at = cls.Find(c);
		return at < cls.Size() && len[at] > 0 ? at : -1;
	}

	// The actor angles that hang a measured gun as (a, p, r) hangs one pointing forward:
	// R = R(a, p, r) * Ry(pitch) * Rz(yaw), read back as angle, pitch, roll (the engine
	// turns a model by roll about its forward axis, then pitch, then yaw).
	static void Compose(double a, double p, double r, double cy, double cp,
		out double oa, out double op, out double orl)
	{
		// columns of R(a,p,r): forward, left, up
		Vector3 F, L, U;
		[F, L, U] = Basis(a, p, r);
		// the correction's columns in that frame: Ry(cp) * Rz(cy)
		Vector3 f2 = (cos(cy) * cos(cp), sin(cy), -cos(cy) * sin(cp));
		Vector3 l2 = (-sin(cy) * cos(cp), cos(cy), sin(cy) * sin(cp));
		Vector3 nF = F * f2.x + L * f2.y + U * f2.z;
		Vector3 nL = F * l2.x + L * l2.y + U * l2.z;
		oa = atan2(nF.y, nF.x);
		op = -asin(clamp(nF.z, -1.0, 1.0));
		// roll: the new left measured against the left of (oa, op) with no roll
		Vector3 F0, L0, U0;
		[F0, L0, U0] = Basis(oa, op, 0);
		orl = atan2(nL dot U0, nL dot L0);
	}

	// Forward, left and up of a body turned by yaw a (left +), pitch p (nose down +), roll r.
	static Vector3, Vector3, Vector3 Basis(double a, double p, double r)
	{
		double ca = cos(a), sa = sin(a), cp = cos(p), sp = sin(p), cr = cos(r), sr = sin(r);
		Vector3 F = (ca * cp, sa * cp, -sp);
		Vector3 L0 = (-sa, ca, 0);
		Vector3 U0 = (ca * sp, sa * sp, cp);
		Vector3 L = L0 * cr + U0 * sr;
		Vector3 U = U0 * cr - L0 * sr;
		return F, L, U;
	}
}
