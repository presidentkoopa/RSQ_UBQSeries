// THE SEAM, looks side (replaces core's stub). The contract core calls:
//
//   Sound(what)      a SNDINFO name, "" for silence   fire loop swish hitwall hitflesh retract
//                                                     (the whip adds: lash crack)
//   Sprite(what)     a 4-letter sprite name           open closed
//   Spark(at, what)  an impact effect, or nothing     wall flesh crack
//
// THREE SETS (rsqgr_looks), every one built only from art and sound that already
// exists -- nothing here is new art:
//
//   0 JP (default)   jpalomo's hook (jp_original/, shipped by core under RSG* names):
//                    OCLW/CCLW claw (core's rope is a tube in tenda0's grey), dschain / dsswish / dspulchn /
//                    dsmtalht / dsmeatht. JP's hook makes no spark.
//   1 Combat FX      the owner's RS_CombatFX well, what of it is in the upload: its
//                    shared draw (the hook leaves the hand), holster x3 (it comes back)
//                    and the three unsorted foley takes (the rope through the air,
//                    picked at random). The well holds no impact sound or art in the
//                    upload, so the hits and the claw stay JP's.
//   2 Ballistics     the owner's RS_Ballistics: the near-miss whiz x4 (the claw going
//                    out, the rope's swish), the near crack x2 (a wall hit, the whip's
//                    crack), and its tracer mesh (btracer.obj): the claw flies as a
//                    tracer streak, and a wall hit throws four small ones off as sparks.
//
// A set that has no sound for something answers JP's for it, never silence by
// accident; "" only where JP itself is silent.
class RSQGR_Looks
{
	const SET_JP = 0;
	const SET_CFX = 1;
	const SET_BAL = 2;

	static clearscope int Set()
	{
		return clamp(RSQGR_Util.Opt("rsqgr_looks", 0), 0, 2);
	}

	static String Sound(Name what)
	{
		int set = Set();
		if (set == SET_CFX)
		{
			if (what == 'fire') return "rsqgr/cfx/draw";
			if (what == 'loop') return "";
			if (what == 'swish' || what == 'lash') return "rsqgr/cfx/foley";
			if (what == 'retract') return "rsqgr/cfx/holster";
		}
		else if (set == SET_BAL)
		{
			if (what == 'fire' || what == 'swish' || what == 'lash' || what == 'retract') return "rsqgr/bal/whiz";
			if (what == 'loop') return "";
			if (what == 'hitwall' || what == 'crack') return "rsqgr/bal/crack";
		}
		// JP, and whatever a set does not have
		if (what == 'fire') return "rsqgr/fire";
		if (what == 'loop') return "rsqgr/loop";
		if (what == 'swish' || what == 'lash') return "rsqgr/swish";
		if (what == 'hitwall') return "rsqgr/hit/terrain";
		if (what == 'hitflesh') return "rsqgr/hit/flesh";
		if (what == 'retract') return "rsqgr/loop";
		if (what == 'crack') return "rsqgr/hit/terrain";
		return "";
	}

	static Name Sprite(Name what)
	{
		if (Set() == SET_BAL && (what == 'open' || what == 'closed')) return 'RSGB';   // the tracer mesh (MODELDEF)
		if (what == 'open') return 'RSGH';
		if (what == 'closed') return 'RSGK';
		return 'TNT1';
	}

	static play void Spark(Vector3 at, Name what)
	{
		if (Set() != SET_BAL) return;
		if (what != 'wall' && what != 'crack') return;
		for (int k = 0; k < 4; k++)
		{
			let s = Actor.Spawn("RSQGR_Streak", at, NO_REPLACE);
			if (!s) continue;
			double an = FRandom[RSQGRLooks](0, 360);
			double pt = FRandom[RSQGRLooks](-60, 30);
			double sp = FRandom[RSQGRLooks](4, 9);
			s.Angle = an;
			s.Pitch = pt;
			s.Vel = (cos(pt) * cos(an), cos(pt) * sin(an), -sin(pt)) * sp;
		}
	}
}

// RS_Ballistics' tracer mesh as a spark: a short streak along its own flight, gone in
// eight tics. NOINTERACTION: it moves by its velocity and touches nothing. Runs in
// real time under RSQ_SlowMo (an "rsq..." class), like the rest of the hook's look.
class RSQGR_Streak : Actor
{
	Default
	{
		Radius 1;
		Height 1;
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
		+NOTELEPORT
		+BRIGHT
		RenderStyle "Add";
		Alpha 1.0;
	}
	States
	{
	Spawn:
		RSGB A 1 { A_FadeOut(0.12); Vel *= 0.8; }
		Loop;
	}
}
