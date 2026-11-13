// RSR-ASSIST: the capture zones of the real VR reload. QuestZDoom 17.3, no engine changes.
//
// Why this file exists. The reload asked the player to put a part exactly where the mesh
// says it goes: a magazine's top within 3.5 cm of the well's axis, a round's tip within
// 1.4 cm of a chamber's bore, and then pushed all the way home. That is right for a short
// part held in the middle of the fist, and impossible for a long one: a BD22 rocket is
// 22 cm and is held near its tail, so its nose is 18.9 cm from the hand, and a 3.5 cm
// target at a 18.9 cm lever arm asks the wrist to be right to within 10 degrees. The
// grenade launcher's 11 cm grenade on a 1.4 cm target is the same sum.
//
// So every insertion point now has a CAPTURE ZONE round it: a cylinder of CAPTURE cm about
// the insertion axis, running from home to CAPTURE cm beyond the mouth. A held part whose
// leading end is inside it, and whose own axis is within TILT of the insertion axis, is
// CAUGHT. Caught, it snaps to the axis -- the part is from then on drawn on the axis at
// the depth the hand has reached, so the hand only has to push ALONG it (the magnetic
// lead-in). SEATFRAC of the way in counts as home.
//
// Nothing here loosens what has to be true: you must be HOLDING the part (the grab rule in
// vreload.zs is untouched), the part must point roughly the right way, and it still has to
// be pushed in. A hand merely near the gun catches nothing.
//
// rsr_assist (0.5 .. 3.0, default 1.0) scales every radius and tolerance at once, and
// scales how little of the push counts as home. Per gun, change the numbers in the tables
// below. rsr_assist and rsr_assist_debug BOTH have menu rows (MENUDEF.rsq, "Reload: tuning
// and debug") -- deliberately, because a console command is no use with a headset on.
//
// INDEX SPACES -- the three modules number their guns separately, and each set has its own
// table, so an index means nothing without its module:
//   Mag*   : RSR_Guns  (vreload.zs).      BD22 1..9 Rifle, BrutalPistol, BrutalSMG, MP40,
//                                         AssaultShotgun, RailGun, Plasma_Gun, Sniper,
//                                         Rocket_Launcher.  Vanilla VR Plus: 1 VR_Rifle.
//   Break* : RSB_Guns  (rsr_break.zs).    1 SSG, 2 GrenadeLauncher, 3 Revolver (BD22);
//                                         4 VR_SuperShotgun, 5 VR_Revolver, 6 VR_Revolver2 (V+).
//   Pump*  : RSP_Guns  (rsr_pump.zs).     1 Shot_Gun (BD22), 2 VR_Shotgun (V+). One shared table.
// The Mag table is the only one both sets share indexes in: BD22's index 1 is Rifle and
// V+'s is VR_Rifle. Leave index 1 at the default, or the two sets drag each other.

class RSR_Assist abstract
{
	// ---- the defaults, before rsr_assist scales them

	const CAPTURE  = 8.0;		// cm: the capture zone's radius about the insertion axis
	const TILT     = 60.0;		// deg: how far off the axis the held part may point
	const SEATFRAC = 0.60;		// of the way in from the mouth: home
	const GRABR    = 10.0;		// cm: the hand this close to a charging handle / slide / pump takes it
	const PULLFRAC = 0.70;		// of the handle's travel: far enough back to have worked it
	const FWDFRAC  = 0.30;		// of the travel: far enough forward again to be ready

	const LEAVE_MUL = 1.5;		// the part is back in the hand this much further out than CAPTURE
	const MAXTILT   = 85.0;		// never past this, or a part pointing backwards would be caught
	const DBG_TICS  = 7;		// rsr_assist_debug prints at most this often

	// ---- the master scale

	clearscope static double Scale(PlayerInfo p)
	{
		let cv = p ? CVar.GetCVar('rsr_assist', p) : CVar.FindCVar('rsr_assist');
		return cv ? clamp(cv.GetFloat(), 0.5, 3.0) : 1.0;
	}

	clearscope static bool Dbg(PlayerInfo p)
	{
		let cv = p ? CVar.GetCVar('rsr_assist_debug', p) : CVar.FindCVar('rsr_assist_debug');
		return cv && cv.GetBool();
	}

	// a radius grows with the assist
	clearscope static double R(PlayerInfo p, double base)
	{
		return base * Scale(p);
	}

	// so does an angle, up to MAXTILT
	clearscope static double A(PlayerInfo p, double base)
	{
		return min(base * Scale(p), MAXTILT);
	}

	// a fraction of a push or a stroke that has to be done: more assist, less of it
	clearscope static double Frac(PlayerInfo p, double base)
	{
		return clamp(1.0 - (1.0 - base) * Scale(p), 0.15, 1.0);
	}

	// a fraction a part has to come back to: more assist, more of it allowed
	clearscope static double Back(PlayerInfo p, double base)
	{
		return clamp(base * Scale(p), 0.05, 0.60);
	}

	// how far out a caught part is let go of again
	clearscope static double Leave(PlayerInfo p, double cap)
	{
		return cap * LEAVE_MUL;
	}

	// ---- per gun: magazines, drums, cells (RSR_Guns, vreload.zs)

	clearscope static double MagCapture(PlayerInfo p, int i)
	{
		double b = CAPTURE;
		switch (i)
		{
		// BD22 Rocket_Launcher: a 22 cm rocket held near its tail, its nose 18.9 cm from
		// the hand (RSR_Guns.TopInHand 9). The lever arm turns a radius into a wrist angle,
		// so this one needs more of it than a magazine held in the middle of the fist.
		case 9:	b = 12.0; break;
		}
		return R(p, b);
	}

	clearscope static double MagTilt(PlayerInfo p, int i)
	{
		double b = TILT;
		switch (i)
		{
		case 9:	b = 70.0; break;		// BD22 Rocket_Launcher: it goes in across the gun, an awkward wrist
		}
		return A(p, b);
	}

	clearscope static double MagSeatFrac(PlayerInfo p, int i)
	{
		// no gun needs its own number yet. To tune one, add:
		//   switch (i) { case <index>: return Frac(p, <value>); }
		return Frac(p, SEATFRAC);
	}

	clearscope static double MagGrab(PlayerInfo p, int i)
	{
		// no gun needs its own number yet. To tune one, add:
		//   switch (i) { case <index>: return R(p, <value>); }
		return R(p, GRABR);
	}

	clearscope static double MagPullFrac(PlayerInfo p, int i)
	{
		// no gun needs its own number yet. To tune one, add:
		//   switch (i) { case <index>: return Frac(p, <value>); }
		return Frac(p, PULLFRAC);
	}

	// ---- per gun: break-open guns and revolvers (RSB_Guns, rsr_break.zs)

	clearscope static double BreakCapture(PlayerInfo p, int i)
	{
		double b = CAPTURE;
		switch (i)
		{
		// BD22 GrenadeLauncher: an 11 cm grenade whose tip is 11 cm from the hand
		// (RSB_Guns.HandTip 2) going into one chamber -- nothing else to confuse it with.
		case 2:	b = 10.0; break;
		}
		return R(p, b);
	}

	clearscope static double BreakTilt(PlayerInfo p, int i)
	{
		double b = TILT;
		switch (i)
		{
		case 2:	b = 70.0; break;		// BD22 GrenadeLauncher: one chamber, so be generous
		// BD22 Revolver: the cylinder swings 90 deg out to the left, so the chamber mouths
		// face back towards the chest and the hand has to come round to push forward.
		case 3:	b = 70.0; break;
		}
		return A(p, b);
	}

	clearscope static double BreakSeatFrac(PlayerInfo p, int i)
	{
		// no gun needs its own number yet. To tune one, add:
		//   switch (i) { case <index>: return Frac(p, <value>); }
		return Frac(p, SEATFRAC);
	}

	// ---- per gun: pump shotguns (RSP_Guns, rsr_pump.zs). One table, both sets.

	clearscope static double PumpCapture(PlayerInfo p, int i)
	{
		// no gun needs its own number yet. To tune one, add:
		//   switch (i) { case <index>: return R(p, <value>); }
		return R(p, CAPTURE);
	}

	clearscope static double PumpTilt(PlayerInfo p, int i)
	{
		// no gun needs its own number yet. To tune one, add:
		//   switch (i) { case <index>: return A(p, <value>); }
		return A(p, TILT);
	}

	clearscope static double PumpSeatFrac(PlayerInfo p, int i)
	{
		// no gun needs its own number yet. To tune one, add:
		//   switch (i) { case <index>: return Frac(p, <value>); }
		return Frac(p, SEATFRAC);
	}

	clearscope static double PumpGrab(PlayerInfo p, int i)
	{
		// no gun needs its own number yet. To tune one, add:
		//   switch (i) { case <index>: return R(p, <value>); }
		return R(p, GRABR);
	}

	clearscope static double PumpPullFrac(PlayerInfo p, int i)
	{
		// no gun needs its own number yet. To tune one, add:
		//   switch (i) { case <index>: return Frac(p, <value>); }
		return Frac(p, PULLFRAC);
	}

	clearscope static double PumpFwdFrac(PlayerInfo p, int i)
	{
		// no gun needs its own number yet. To tune one, add:
		//   switch (i) { case <index>: return Back(p, <value>); }
		return Back(p, FWDFRAC);
	}

	// ---- seating: how far short of home still counts as home
	//
	// frac of the way in from the mouth, but never looser than the module's own SEAT cm,
	// so a well only a centimetre deep is not seated the moment the part is caught.

	clearscope static double SeatAt(double depth, double frac, double hard)
	{
		return max(hard, depth * (1.0 - frac));
	}

	// ---- rsr_assist_debug: draw a capture zone
	//
	// A tuning aid, off by default, switched from the menu because the console cannot be
	// reached in a headset. It never becomes a marker a player has to look at: with the cvar
	// off not one particle is spawned. Particles, not actors, so there is nothing in the
	// world to collide with or pick up either way.
	//
	// off is the ring's centre as a world offset from mo; su and sv span its plane, already
	// scaled to the radius (A_SpawnParticle's offsets are world, not turned by the actor's
	// angle, with SPF_RELPOS clear).

	play static void Ring(Actor mo, Vector3 off, Vector3 su, Vector3 sv, Color col)
	{
		if (!mo)
			return;
		for (int k = 0; k < 16; k++)
		{
			double a = k * 22.5;
			Vector3 q = off + su * cos(a) + sv * sin(a);
			mo.A_SpawnParticle(col, SPF_FULLBRIGHT, 2, 3.0, 0, q.x, q.y, q.z);
		}
	}
}
