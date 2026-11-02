// RSQ Melee -- the shared core: settings reads, the hands, the other mods asked by name.
//
// RSQ Melee owns fighting with your body: the punch and the boxing gloves (SuperPunchOut's), Slappers Only,
// Guard, Hadouken, Wall Splat, Heavy Hands, the gun-butt shove (BD22 VR Reloaded's) with its slow-mo and the
// F.E.A.R. Effect, and the Headlock. It moved here on 2026-11-01 from RSQ Gun Bonsai VR (the punch, the gloves,
// Slappers Only, the four moves), RSQ Gestures (the shove) and RSQ Distance Grab (the Headlock).
//
// NO MOD IS REQUIRED. Everything here works on plain Doom 2 alone. Each other mod adds something when it is
// loaded, found by NAME at run time (ServiceIterator, Object.FindClass through a String), never linked:
//   RSQ Gun Bonsai VR   RSQ_MeleeUpgradeService: the upgrade levels and their numbers (Guard, Hadouken, Wall
//                       Splat, Heavy Hands are its upgrades when it is loaded), paying a glove's helpers to the glove
//   RSQ Distance Grab   RSQDG_ThrowService: a monster thrown out of the Headlock flies through its throw code;
//                       which mod takes the off-hand grip press ("near.dist")
//   RSQ SlowMo          rsm_pulse after a shove, "slowmo.active" for the F.E.A.R. window
//   RSQ Score           RS_ScoreService: "touch" grab.hold (the Headlock combo), "award" F.E.A.R. Effect
//   RSQ Accessibility   RSQML_A11y (a11y.zs): Rumble Strength, Seated Play, the Off-Hand Modifier
//   BD22 VR Reloaded    the shove stands down for its own butt strike
//   RSQ Grapple, Wheel  the shove is quiet on the rope or with the ring open
//
// SAVES. The classes a save can hold keep the names they had in Gun Bonsai VR (RSQ_Glove, RSQ_GloveOff,
// RSQ_Splat, RSQ_SplatHit, RSQ_SlapperStash, RSQ_NoPickup, RSQ_Buzz, and the two old handlers as empty shells:
// legacy.zs), so a game saved before the move loads. Melee's own handlers are STATIC (never saved), so they are
// there on a save made before Melee existed too.
class RSQML play
{
	// ---- settings ------------------------------------------------------------------------------------------
	static clearscope double SV(String n, double fb) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : fb; }
	static clearscope int SVI(String n, int fb) { let c = CVar.FindCVar(n); return c ? c.GetInt() : fb; }
	static int Debug() { return SVI("rsqml_debug", 0); }

	static clearscope double UnitsPerMetre()
	{
		if (multiplayer) return 34.0;
		let c = CVar.FindCVar("vr_vunits_per_meter");
		double u = c ? c.GetFloat() : 34.0;
		return u < 1.0 ? 34.0 : u;
	}
	static clearscope double Stretch() { double ps = level.pixelstretch; return ps > 0.1 ? ps : 1.2; }

	// a map-space vector's real length in metres (the vertical x pixelstretch)
	static clearscope double Metres(Vector3 v)
	{
		double z = v.z * Stretch();
		return sqrt(v.x * v.x + v.y * v.y + z * z) / UnitsPerMetre();
	}

	// ---- the other mods, by name --------------------------------------------------------------------------
	static clearscope Service Svc(String name) { let it = ServiceIterator.Find(name); return it.Next(); }
	static bool Has(String cls) { return Object.FindClass(cls) != null; }

	// RSQ Gun Bonsai VR (needs ToxicFrog's Gun Bonsai): its upgrade service, or null
	static Service GB() { return Svc("RSQ_MeleeUpgradeService"); }

	// A MOVE THAT IS A GUN BONSAI UPGRADE (Guard, Hadouken, Wall Splat, Heavy Hands). With Gun Bonsai VR loaded:
	// the level learned (on that glove's record; Guard on the player's), 0 until it is learned. Without it: the
	// Melee menu row, which plays it at level 1. short = the upgrade's class name after RSQ_Upgrade_.
	static int MoveLevel(Actor pawn, Weapon glove, String short, String cvarName)
	{
		let gb = GB();
		if (gb)
		{
			if (glove) return gb.GetInt("level", short, 0, 0, glove);
			return gb.GetInt("plevel", short, 0, 0, pawn);
		}
		return SVI(cvarName, 0) != 0 ? 1 : 0;
	}

	// THE MOVE'S NUMBERS stay with the upgrade (Gun Bonsai VR's RSQ_Upgrade_* classes, "upgrade.num"). Without
	// Gun Bonsai VR, fb: that upgrade's level 1, copied from its formula.
	static double Num(String what, int lv, double param, double fb)
	{
		let gb = GB();
		return gb ? gb.GetDouble("upgrade.num", what, lv, param) : fb;
	}

	// a helper actor (master = the glove) paid to that glove by Gun Bonsai; nothing without it
	static void Claim(Actor a, Weapon w)
	{
		let gb = GB();
		if (!gb || !a || !w) return;
		a.master = w;
		gb.GetInt("claim", "", 2, 0, a);   // 2 = Gun Bonsai VR's HINT_MELEE
	}

	// STAGGER: held in its pain frame. Gun Bonsai VR's own (RSQ_Dazed, which its Executioner reads) when it is
	// loaded, else the same thing done here.
	static void Stagger(Actor mo, int tics)
	{
		if (!mo || mo.health <= 0 || tics <= 0) return;
		let gb = GB();
		if (gb && gb.GetInt("stagger", "", tics, 0, mo) == 1) return;
		if (!mo.bIsMonster) return;
		State p = mo.FindState("Pain");
		if (p) mo.SetState(p);
		if (mo.tics >= 0 && mo.tics < tics) mo.tics = tics;
	}

	// ---- which weapon is which, by class name ---------------------------------------------------------------
	static clearscope bool IsGloveName(String n) { return n.Left(9) ~== "SPO_Glove" || n.Left(9) ~== "RSQ_Glove"; }
	static clearscope bool IsSaberName(String n) { return n ~== "UBQS_Saber" || n ~== "UBQS_SaberOff"; }
	static clearscope bool IsShieldName(String n) { return n ~== "SSQ_ShieldSaw"; }

	// WHAT SLAPPERS ONLY LETS YOU KEEP (and what counts as an empty hand for Guard), in any base game: the series'
	// own melee (the gloves, the sabers, the ShieldSaw, the Force hand), anything flagged a melee weapon, anything
	// using no ammo at all, and -- with Gun Bonsai VR -- a weapon Gun Bonsai's own type inference calls melee
	// ("is.melee", which also honours a BONSAIRC `type ... : MELEE` line).
	static bool IsSlapperClass(Class<Actor> c, Actor pawn = null)
	{
		if (!c) return false;
		String n = c.GetClassName();
		if (IsGloveName(n) || IsSaberName(n) || IsShieldName(n) || n ~== "UBQS_ForceHand") return true;
		let w = (Class<Weapon>)(c);
		if (!w) return false;
		let d = GetDefaultByType(w);
		if (!d) return false;
		if (d.bMeleeWeapon) return true;
		if (!d.AmmoType1 && !d.AmmoType2) return true;
		if (pawn)
		{
			let gb = GB();
			if (gb && gb.GetInt("is.melee", n, 0, 0, pawn) == 1) return true;
		}
		return false;
	}

	static bool IsFoe(Actor pawn, Actor mo)
	{
		if (!mo || mo == pawn || !mo.bShootable || mo.health <= 0) return false;
		if (mo.player) return deathmatch;
		return mo.bIsMonster && !mo.bFriendly;
	}

	// in its attack wind-up (its Missile or Melee sequence)
	static bool InAttack(Actor mo)
	{
		if (!mo || !mo.CurState) return false;
		State s = mo.FindState("Missile");
		if (s && mo.InStateSequence(mo.CurState, s)) return true;
		s = mo.FindState("Melee");
		if (s && mo.InStateSequence(mo.CurState, s)) return true;
		return false;
	}

	static bool HasSound(String n) { Sound s = n; return int(s) > 0; }

	static bool Descends(Actor a, Name n)
	{
		for (class<Object> c = a.GetClass(); c; c = c.GetParentClass())
			if (c.GetClassName() == n) return true;
		return false;
	}
}

// ---- THE HANDS ---------------------------------------------------------------------------------------------
// QuestZDoom writes the controllers into AttackPos / OffhandPos (absolute map positions) for the camera player
// only, once per rendered frame. The controller playing a hand's part follows RSQ Accessibility's Off-Hand
// Modifier (RSQML_A11y.Ctrl). A probe may stand in for a controller (RSQML_Sim, headless testing only).
class RSQML_Hands play
{
	const ARM_MAX = 96.0;

	static Vector3, bool Pos(PlayerPawn pmo, int h)
	{
		if (!pmo || !pmo.player) return (0, 0, 0), false;
		let sim = RSQML_Sim.Get();
		int i = pmo.PlayerNumber() * 2 + h;
		if (sim && sim.simOn[i]) return sim.simHand[i], true;
		// out of VR the engine writes both hands to the pawn's chest (hw_vrmodes.cpp SetUp): never a real pose
		if (!pmo.OverrideAttackPosDir || !pmo.player.PlayInVR) return (0, 0, 0), false;
		if (pmo.AttackPos == pmo.OffhandPos) return (0, 0, 0), false;
		Vector3 p = RSQML_A11y.Ctrl(pmo, h) == 0 ? pmo.AttackPos : pmo.OffhandPos;
		if (p == (0, 0, 0)) return p, false;
		Vector3 d = p - pmo.Pos;
		if (d.xy.Length() > ARM_MAX || d.z < -ARM_MAX || d.z > pmo.Height + ARM_MAX) return p, false;
		return p, true;
	}

	// the way the hand points (engine yaw stored minus 90, pitch positive up)
	static Vector3 Dir(PlayerPawn pmo, int h)
	{
		let sim = RSQML_Sim.Get();
		int i = pmo.PlayerNumber() * 2 + h;
		if (sim && sim.simOn[i]) return (cos(pmo.angle), sin(pmo.angle), 0);
		bool m = RSQML_A11y.Ctrl(pmo, h) == 0;
		double y = (m ? pmo.AttackAngle : pmo.OffhandAngle) + 90, p = m ? pmo.AttackPitch : pmo.OffhandPitch;
		return (cos(y) * cos(p), sin(y) * cos(p), sin(p));
	}

	// the eyes in the map (RSQ Gestures' RSQG_Pose.EyePos): viewz + the headset's height - the height the engine
	// built the view from
	static Vector3 EyePos(PlayerPawn pmo)
	{
		double u = RSQML.UnitsPerMetre(), ps = RSQML.Stretch();
		let adj = CVar.FindCVar("vr_height_adjust");
		double hmdH = (pmo.HmdPosition.y + (adj ? adj.GetFloat() : 0)) * u / ps;
		let cb = CVar.FindCVar("vr_crouch_use_button");
		double h = (cb && cb.GetBool()) ? pmo.ViewHeight : hmdH;
		return (pmo.Pos.x, pmo.Pos.y, pmo.player.viewz + hmdH - h);
	}

	static Weapon InHand(PlayerPawn pmo, int h)
	{
		let p = pmo ? pmo.player : null;
		if (!p) return null;
		return h == 0 ? p.ReadyWeapon : p.OffhandWeapon;
	}
}

// A probe's stand-in for the controllers (headless testing; nothing sets it in play).
class RSQML_Sim : StaticEventHandler
{
	bool simOn[MAXPLAYERS * 2];
	Vector3 simHand[MAXPLAYERS * 2];
	static RSQML_Sim Get() { return RSQML_Sim(StaticEventHandler.Find("RSQML_Sim")); }
}

// ---- A RUMBLE on one controller (moved from Gun Bonsai VR with its name: a save may hold one) ---------------
// The series' haptic route, as RSQ_Saber's UBQS_Buzzer does it: A_QuakeEx QF_WAVE, re-issued each tic, X the left
// controller and Y the right. Local to its owner (tremor 8). RSQ Accessibility's Rumble Strength scales it.
class RSQ_Buzz : Actor
{
	Actor feels;
	bool left;
	double amp;
	int total, leftTics;
	Default { +NOINTERACTION +NOBLOCKMAP +NOSECTOR +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP RenderStyle "None"; }

	static void Start(Actor who, int hand, double k, int tics)
	{
		if (!who || !who.player) return;
		double rs = RSQML_A11y.Rumble();
		if (rs <= 0) return;
		k *= rs;
		bool lefty = false;
		if (!multiplayer) { let cs = CVar.FindCVar("vr_control_scheme"); lefty = cs && cs.GetInt() >= 10; }
		let q = RSQ_Buzz(Actor.Spawn("RSQ_Buzz", who.pos));
		if (!q) return;
		q.feels = who;
		q.left = (hand == 1) != lefty;
		q.amp = clamp(k, 0.12, 1.0);
		q.total = clamp(tics, 1, 16);
		q.leftTics = q.total;
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels || leftTics <= 0) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		double a = amp * leftTics / double(total) / 3.2;
		leftTics--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}
	States { Spawn: TNT1 A 20; Stop; }
}
