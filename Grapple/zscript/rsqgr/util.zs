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
	const OFF = 1;               // the off hand's controller field (OffhandPos); 0 is the main hand's (AttackPos)

	// HOOK HAND (C7, owner 2026-11-16: "Let me pick the hand"): rsqgr_hand, a USER cvar read for the pawn's own player.
	// 0 Off Hand (the hook as it always was), 1 Main Hand. Answers the controller field the hook reads: 1 OffhandPos,
	// 0 AttackPos. The air spike reads both hands either way.
	static clearscope int HookCtrl(PlayerPawn pmo)
	{
		let c = (pmo && pmo.player) ? CVar.GetCVar("rsqgr_hand", pmo.player) : null;
		return (c && c.GetInt() == 1) ? 0 : OFF;
	}
	static clearscope Vector3 HookRaw(PlayerPawn pmo) { return HookCtrl(pmo) == 0 ? pmo.AttackPos : pmo.OffhandPos; }

	static clearscope double Num(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static clearscope int Opt(String n, int d) { let c = CVar.FindCVar(n); return c ? c.GetInt() : d; }
	static clearscope bool Flag(String n, bool d) { let c = CVar.FindCVar(n); return c ? c.GetBool() : d; }
	static clearscope bool Debug() { return Opt("rsqgr_debug", 0) >= 1; }
	static clearscope double Range() { return clamp(Num("rsqgr_range", 780), 64, 8192); }
	// AIM TRIM (owner 2026-11-23, "it fires slightly off to the right"): degrees the claw's line is turned from the hook hand's,
	// your own (user cvars): yaw + left / - right, pitch + up / - down; none while two-handing (the claw goes where you look)
	static clearscope double AimTrimYaw(PlayerPawn pmo) { if (TwoHanding(pmo)) return 0; let c = (pmo && pmo.player) ? CVar.GetCVar("rsqgr_aim_yaw", pmo.player) : null; return c ? clamp(c.GetFloat(), -15, 15) : 0; }
	static clearscope double AimTrimPitch(PlayerPawn pmo) { if (TwoHanding(pmo)) return 0; let c = (pmo && pmo.player) ? CVar.GetCVar("rsqgr_aim_pitch", pmo.player) : null; return c ? clamp(c.GetFloat(), -15, 15) : 0; }

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

	// a real pose of the hook hand: VR on, the hands not collapsed to one point (a menu just closed, a level just began),
	// and the hook hand within reach of the body
	static clearscope bool PoseGood(PlayerPawn pmo)
	{
		if (!pmo || !pmo.player || !pmo.OverrideAttackPosDir) return false;
		if (pmo.AttackPos == pmo.OffhandPos) return false;
		Vector3 d = HookRaw(pmo) - pmo.Pos;
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

	// where the hook hand is this tic (play code)
	static play Vector3 HandPos(PlayerPawn pmo)
	{
		if (!PoseGood(pmo)) return ChestPos(pmo);
		return RSQGR_HandSync.Fix(pmo, HookRaw(pmo), HookCtrl(pmo));
	}
	// TWO-HANDING (owner 2026-11-23: "sometimes i two-hand and fire the grapple expecting it to come forward but it fires in
	// the direction of the gun when i 'grabbed' it to two hand it"): while the engine's two-hand grip holds the gun
	// (WF_TWOHANDSTABILIZED), the hand on the gun reads the gun's line, so the claw flies straight where you look instead
	static clearscope bool TwoHanding(PlayerPawn pmo) { return pmo && pmo.player && (pmo.player.WeaponState & WF_TWOHANDSTABILIZED) != 0; }
	static clearscope double HandYaw(PlayerPawn pmo)
	{
		if (!PoseGood(pmo) || TwoHanding(pmo)) return pmo.Angle;
		return (HookCtrl(pmo) == 0 ? pmo.AttackAngle : pmo.OffhandAngle) + 90;
	}
	static clearscope double HandPitch(PlayerPawn pmo)
	{
		if (!PoseGood(pmo) || TwoHanding(pmo)) return -pmo.Pitch;
		return HookCtrl(pmo) == 0 ? pmo.AttackPitch : pmo.OffhandPitch;
	}

	// THE FIRING LINE (owner 2026-11-23 07:46: "fix the grapple hook so it rides the firing line and doesn't fire off to the
	// right"). The engine aims a gun in a hand by AttackDir / OffhandDir (gzdoom.pk3 attacks.zs A_FireProjectile,
	// A_SpawnItemEx: dir = OffhandDir(self, Angle, Pitch) -> (angle, pitch) in map space, pitch + down), built from the
	// controller's whole rotation, its roll and vr_weaponRotate included. HandYaw / HandPitch above are only the hand's yaw
	// and pitch: with the wrist rolled the two part by degrees, sideways. So the claw and the Aim Dot now take the gun's
	// own line from that hand, in map space as a shot flies (no pixelstretch), with Aim Trim on top. Two-handing and no VR
	// pose: as before (where you look). Play scope: the engine's call is play.
	// BD22 VR 2.0's muzzle handler is running (its bore applies to its guns): by name at run time
	static clearscope bool BoreActive()
	{
		if (Opt("rsqgr_bore", 1) == 0) return false;
		Name rn = 'RSQ_Muzzle';
		class<StaticEventHandler> k = rn;
		return k && EventHandler.Find(k) != null;   // as RSQ LaserSight asks (bdbore.zs Active)
	}
	static play Vector3 FireDir(PlayerPawn pmo)
	{
		// TWO-HANDING RIDES THE GUN (owner 2026-11-23 14:56: "Does grapple ride firing line when two handing as well?" It did
		// not: two-handing took where you look). The off hand is on the gun then, so the claw takes the steadied gun's own
		// line (AttackDir: the engine's two-hand aim), with the bore, as its shots and its laser fly. No Aim Trim (as before).
		if (PoseGood(pmo) && TwoHanding(pmo) && Opt("rsqgr_fireline", 1) != 0)
		{
			double ty = 0, tp = 0;
			if (BoreActive()) { ty = 3.8541; tp = 3.3629; }
			Vector3 g = pmo.AttackDir(pmo, pmo.Angle + ty, pmo.Pitch + tp);
			return (cos(g.y) * cos(g.x), cos(g.y) * sin(g.x), -sin(g.y)).Unit();
		}
		if (!PoseGood(pmo) || TwoHanding(pmo) || Opt("rsqgr_fireline", 1) == 0)
			return MapDir(HandYaw(pmo) + AimTrimYaw(pmo), HandPitch(pmo) + AimTrimPitch(pmo));
		// THE BORE (owner 2026-11-23 08:32: "our lasers and truebullets ride the firing line, why does the grapple not?"):
		// Brutal Doom VR 2.0 fires every gun with a bore 3.8541 deg left and 3.3629 deg up of the controller (its
		// fix-accuracy, muzzle.zs), and RSQ LaserSight traces that same line (bdbore.zs RSQLS_BDBore.Line: Angles(mo, h,
		// BORE_YAW, BORE_PITCH) = OffhandDir(mo, angle + 3.8541, pitch + 3.3629)). The hook flew down the bare controller
		// line, so beside the guns and their lasers it went ~4 deg right. It takes the same bore now, whenever BD22 VR's
		// muzzle handler (RSQ_Muzzle, by name) runs; without it, the controller line as before.
		double by = 0, bp = 0;
		if (BoreActive()) { by = 3.8541; bp = 3.3629; }
		Vector3 fd = HookCtrl(pmo) == 0 ? pmo.AttackDir(pmo, pmo.Angle + by, pmo.Pitch + bp) : pmo.OffhandDir(pmo, pmo.Angle + by, pmo.Pitch + bp);
		double yaw = fd.x + AimTrimYaw(pmo);
		double pit = fd.y - AimTrimPitch(pmo);      // the engine's pitch is + down; Aim Trim's + up
		Vector3 d = (cos(pit) * cos(yaw), cos(pit) * sin(yaw), -sin(pit));
		return d.Unit();
	}

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

	// RSQ MELEE (RSQML_Service): e.g. "dizzy", tics, a monster -- its chicks and stars. 0 = no RSQ Melee (or refused).
	static play int Melee(String req, int arg, Actor who)
	{
		let s = Svc("RSQML_Service");
		if (!s) return 0;
		return s.GetInt(req, "", arg, 0, who);
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

	// AC2 (11-16): the vignette's strength follows how fast the hook moves you: 0.35 at a crawl, full at 30 units a tic
	// (about 31 m a second) and over -- RSQ Accessibility's page promises "stronger the faster you move"
	static play double ComfortBySpeed(PlayerPawn pmo) { return pmo ? clamp(pmo.vel.Length() / 30.0, 0.35, 1.0) : 1.0; }

	// RSQ ACCESSIBILITY's Comfort Vignette: a comfort moment this tic (its own row decides whether anything shows)
	static play void Comfort(PlayerPawn pmo, double strength)
	{
		if (!pmo || !pmo.player) return;
		let s = Svc("RSQA_Service");
		if (s) s.GetInt("vignette", "", pmo.PlayerNumber(), strength, null);
	}

	// HEAVY (the OG rule, owner 2026-11-13): a boss, a dormant monster, or a miniboss with RSQ Miniboss's Can't Be Yanked
	// -- and (owner 2026-11-13 01:xx) "BARONS ARE ALWAYS HEAVY". Heavy: you go to it. Light: it comes to you.
	// ONLY HUMANS AND IMPS COME TO YOU (owner 2026-11-24 14:35: "i want to kick everyone unless i pull towards me and we can
	// only pull humanoids and imps"). Heavy now means "not one of those": every other monster is a kick, whatever its
	// mass (Kick Mass, 11-23, is gone with this). A boss, a dormant one, a Baron and a miniboss with Can't Be Yanked stay
	// heavy as before, even a human-shaped one.
	static play bool Heavy(Actor v)
	{
		return v.bBOSS || v.bDORMANT || Baron(v) || MinibossAs(v, "yank") || !Pullable(v);
	}

	// A HUMAN OR AN IMP: the class is, is built on, or stands in for (its replacee: Brutal Doom's and the packs' own
	// zombies and imps replace Doom's) a zombieman, shotgun guy, chaingunner, SS or imp; or, for a pack's own new monster
	// that replaces nothing (XMVE's Labgal ...), a small walker: no taller than a marine-and-a-bit (64), no heavier than
	// 150, not a flyer (a lost soul is small but no human).
	static clearscope bool ClassIs(class<Object> c, class<Object> k)
	{
		for (; c; c = c.GetParentClass()) if (c == k) return true;
		return false;
	}
	static play bool Pullable(Actor v)
	{
		if (!v) return false;
		static const Name KIN[] = { 'ZombieMan', 'ShotgunGuy', 'ChaingunGuy', 'WolfensteinSS', 'DoomImp' };
		class<Actor> rep = Actor.GetReplacee(v.GetClass());
		for (int i = 0; i < KIN.Size(); i++)
		{
			class<Actor> k = KIN[i];
			if (!k) continue;
			if (ClassIs(v.GetClass(), k) || ClassIs(rep, k)) return true;
		}
		if (v.bFLOAT || v.bNOGRAVITY) return false;
		return v.Height <= 64 && v.Mass <= 150;
	}

	// A BARON OF HELL, any of them: the class is a BaronOfHell (Doom's, Brutal Doom's BaronofHell2 and what is built on
	// it, XMVE's Cyberbaron / Bruiser / Pyro / Belphegor, RSQ Monsters' RS_CommonBaron ...), or its species is
	// BaronOfHell (RSQ Monsters' Actor-based RS_ barons: RS_BrownBaron2, RS_RedBaron1 ... all say Species "BaronOfHell").
	// HELL KNIGHTS STAY BY MASS (owner): Doom's HellKnight is itself built on BaronOfHell and shares its species (an
	// unset species is the class under Actor), and RSQ Monsters' RS_*HK* knights say Species "BaronOfHell" too, so a
	// knight -- anything built on HellKnight, or with "Knight" or an RS_ "HK" in its class name -- is never a Baron here.
	static play bool Baron(Actor v)
	{
		if (!v || !v.bIsMonster) return false;
		if (v is "HellKnight") return false;
		String n = v.GetClassName();
		String low = n.MakeLower();
		if (low.IndexOf("knight") >= 0) return false;
		if (low.Left(3) == "rs_" && n.IndexOf("HK") >= 0) return false;
		if (v is "BaronOfHell") return true;
		return v.Species == 'BaronOfHell' || v.GetSpecies() == 'BaronOfHell';
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
