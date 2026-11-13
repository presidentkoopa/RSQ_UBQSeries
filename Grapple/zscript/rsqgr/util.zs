// RSQGR_Util -- reads only: settings, the off hand, the world's numbers, and every other series mod, asked BY NAME
// (ServiceIterator), so this pack loads and plays alone and a missing mod is simply no answer.
//
// THE HAND. Stock QuestZDoom 17.3 writes the controllers into AttackPos / OffhandPos and their angles (yaw stored minus
// 90 degrees, pitch positive UP) once per rendered frame, for the camera player only. Map space is the room squashed by
// pixelstretch (1.2) vertically, so a room direction is (x, y, z / 1.2) in map units. In play code a hand is read
// through RSQGR_HandSync.Fix (tools/handsync): the frame's hand carried to where the body is this tic -- at 30 units a
// tic of flight, the raw field trails the body by a whole step.
class RSQGR_Util
{
	const ARM_MAX = 96.0;
	const PIXELSTRETCH = 1.2;
	const OFF = 1;               // the hook is the off hand's (OffhandPos); the main hand's is never read here

	static clearscope double Num(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static clearscope int Opt(String n, int d) { let c = CVar.FindCVar(n); return c ? c.GetInt() : d; }
	static clearscope bool Flag(String n, bool d) { let c = CVar.FindCVar(n); return c ? c.GetBool() : d; }
	static clearscope bool Debug() { return Opt("rsqgr_debug", 0) >= 1; }
	static clearscope double Range() { return clamp(Num("rsqgr_range", 780), 64, 8192); }

	// map units in a metre (the engine's VR scale; the series' gesture readers use the same)
	static clearscope double UPM() { let c = CVar.FindCVar("vr_vunits_per_meter"); double u = c ? c.GetFloat() : 34.0; return u > 1.0 ? u : 34.0; }
	// a height in metres, in map units (the room is squashed by pixelstretch vertically)
	static clearscope double MetresUp(double m) { return m * UPM() / PIXELSTRETCH; }
	// a map-space vector in room metres
	static clearscope Vector3 Metric(Vector3 v) { return (v.x, v.y, v.z * PIXELSTRETCH) / UPM(); }

	// Map-space unit direction from a room yaw (engine degrees) and a room pitch (positive up).
	static clearscope Vector3 MapDir(double yaw, double pitchUp)
	{
		Vector3 d = (cos(pitchUp) * cos(yaw), cos(pitchUp) * sin(yaw), sin(pitchUp) / PIXELSTRETCH);
		return d.Unit();
	}

	// a real off-hand pose: VR on, the hands not collapsed to one point (a menu just closed, a level just began), and the
	// hand within reach of the body
	static clearscope bool PoseGood(PlayerPawn pmo)
	{
		if (!pmo || !pmo.player || !pmo.OverrideAttackPosDir) return false;
		if (pmo.AttackPos == pmo.OffhandPos) return false;
		Vector3 d = pmo.OffhandPos - pmo.Pos;
		if (d.xy.Length() > ARM_MAX) return false;
		if (d.z < -ARM_MAX || d.z > pmo.Height + ARM_MAX) return false;
		return true;
	}

	// the body's fallback point (no VR pose): just under the eyes
	static clearscope Vector3 ChestPos(PlayerPawn pmo)
	{
		double z = pmo.player ? pmo.player.viewz - pmo.Pos.z - 8 : pmo.Height * 0.5 + 8;
		return pmo.Pos + (0, 0, z);
	}

	// where the off hand is this tic (play code)
	static play Vector3 HandPos(PlayerPawn pmo)
	{
		if (!PoseGood(pmo)) return ChestPos(pmo);
		return RSQGR_HandSync.Fix(pmo, pmo.OffhandPos, OFF);
	}
	static clearscope double HandYaw(PlayerPawn pmo) { return PoseGood(pmo) ? pmo.OffhandAngle + 90 : pmo.Angle; }
	static clearscope double HandPitch(PlayerPawn pmo) { return PoseGood(pmo) ? pmo.OffhandPitch : -pmo.Pitch; }

	// both hands against the body this tic, in map units (the gesture readers': the air spike, the Scorpion yank)
	static play Vector3 HandOff(PlayerPawn pmo, int ctrl)
	{
		Vector3 raw = ctrl == 0 ? pmo.AttackPos : pmo.OffhandPos;
		return RSQGR_HandSync.Fix(pmo, raw, ctrl) - RSQGR_HandSync.Body(pmo);
	}

	static play bool OnGround(PlayerPawn pmo)
	{
		return pmo.player && (pmo.player.onground || pmo.bOnMobj || pmo.Pos.z <= pmo.floorz + 0.5);
	}

	// one tic of the player's gravity, map units a tic per tic (Doom: 1)
	static play double Grav(Actor a) { return a.GetGravity(); }

	// ---- the other mods, by name ------------------------------------------------------------------------------
	static clearscope Service Svc(String n) { let it = ServiceIterator.Find(n); return it.Next(); }

	// RSQ SLOWMO (SlowMo/zscript/rsqsm/clock.zs, RSQSM_Service "g2.*", the contract of 2026-11-13). -2 = no SlowMo.
	static play int SlowMo(String req, String reason, int tics, PlayerPawn pmo)
	{
		let s = Svc("RSQSM_Service");
		if (!s) return -2;
		return s.GetInt(req, reason, tics, 0, pmo);
	}

	// RSQ VISUALREWARDS' words (RSQVR_Service "word", "word.hold", "word.clear"). 0 = no VisualRewards (or no actor).
	static play int Word(String req, String text, int rgb, double arg, Actor who)
	{
		let s = Svc("RSQVR_Service");
		if (!s || !who) return 0;
		return s.GetInt(req, text, rgb, arg, who);
	}

	// RSQ MINIBOSS: wants this monster treated as a boss for "yank" (Can't Be Yanked). Cheap first: its ward, by name.
	static play bool MinibossAs(Actor v, String sys)
	{
		String wn = "RSQMB_Ward";
		class<Inventory> wc = wn;
		if (!v || !wc || !v.FindInventory(wc)) return false;
		let sv = Svc("RSQMB_Service");
		return sv && sv.GetInt("bossfor", sys, 0, 0, v) == 1;
	}
	// a GUARDED miniboss: its shield is up (a thrall stands) or it is invulnerable after a lost life
	static play bool MinibossGuarded(Actor v)
	{
		String wn = "RSQMB_Ward";
		class<Inventory> wc = wn;
		if (!v || !wc || !v.FindInventory(wc)) return false;
		let sv = Svc("RSQMB_Service");
		return sv && (sv.GetInt("shielded", "", 0, 0, v) == 1 || sv.GetInt("invulnerable", "", 0, 0, v) == 1);
	}

	// RSQ ACCESSIBILITY's Comfort Vignette: a comfort moment this tic (its own row decides whether anything shows)
	static play void Comfort(PlayerPawn pmo, double strength)
	{
		if (!pmo || !pmo.player) return;
		let s = Svc("RSQA_Service");
		if (s) s.GetInt("vignette", "", pmo.PlayerNumber(), strength, null);
	}

	// HEAVY (the OG rule, owner 2026-11-13): a boss, mass over 1000, a dormant monster, or a miniboss with RSQ Miniboss's
	// Can't Be Yanked. Heavy: you go to it. Light: it comes to you.
	const MASS_MAX = 1000;
	static play bool Heavy(Actor v)
	{
		return v.bBOSS || v.Mass > MASS_MAX || v.bDORMANT || MinibossAs(v, "yank");
	}

	// a thing the claw may bite, and the aim assist may snap to
	static clearscope bool Biteable(Actor a, Actor shooter)
	{
		if (!a || a == shooter || a.player || a.bDestroyed) return false;
		if (!a.bSHOOTABLE || a.bNONSHOOTABLE || a.Health <= 0 || a.bMISSILE) return false;
		String n = a.GetClassName();
		if (n.Left(6) ~== "RSQGR_") return false;
		return true;
	}

	static play Vector3 Mid(Actor a) { return a.Pos + (0, 0, a.Height * 0.5); }
}
