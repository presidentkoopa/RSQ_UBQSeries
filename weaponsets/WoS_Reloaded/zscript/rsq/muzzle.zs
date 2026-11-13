// muzzle.zs (r4, owner 2026-10-27: "Ruger 14 / sniper: the bullets leave from below the barrel,
// as if from the magazine").
//
// WHERE A VR SHOT STARTS. On QuestZDoom 17.3 every player hitscan and rail starts at AttackPos,
// the weapon CONTROLLER (hw_openxrdevice.cpp writes it each frame; p_map.cpp P_LineAttack and
// P_RailAttack read it). The controller is the grip. On the Ruger that is 62 cm behind the muzzle
// and 5 cm under the bore, so BD22's gray trail -- the one thing you see of the shot -- came out
// of the magazine. AttackPos is `native readonly`, and A_RailAttack has no forward offset (its
// side/up offsets are zeroed in VR unless use_action_spawn_yzoffset is set), so the shot is
// moved here, without touching the engine, by two stock routes:
//
//   HITSCANS  WorldHitscanPreFired cancels the engine's trace and fires the SAME one again with
//             LineAttack(LAF_ABSPOSITION): the start is an absolute point, the muzzle; the
//             direction is still the engine's own AttackDir (p_map.cpp: the VR branch sets it
//             whatever the position flags). Same angle, pitch, damage, puff, range, flags.
//   THE TRAIL BD22's "Trail effect only" rail (damage 0) is cancelled and drawn again by
//             Actor.RailAttack from a mount at the muzzle, aimed down the same AttackDir, with
//             the same FRailParams: colour, duration, sparsity, puff, everything.
//
// What is NOT moved: the Ruger's damaging rail (30, "Heavy penetration", colour None, so it draws
// nothing). Fired from a mount, its damage would be credited to the mount, not to you. It starts
// at the controller, parallel to the bore and 5 cm under it, as it always has.
//
// THE WALL GUARD. A muzzle can be through a wall the hand is not. Before anything moves, the
// line from the controller to the muzzle is traced; if it hits a wall, floor or ceiling the shot
// is left exactly as the engine fired it. You never shoot from the far side of a wall.
//
// THE DIRECTION (fix-accuracy, 2026-10-28). Moving the start was not enough: the hand ports had also TURNED every gun
// in the hand, and the shot still went down the controller's forward, 3.85 deg right and 3.36 deg low of the drawn
// barrel. Every shot of a gun with a bore (Bore below) is now turned onto the drawn barrel -- hitscans and pellets (their
// angles), rails (their angle / pitch offsets), the player's missiles (their velocity, WorldThingSpawned) -- and the
// two scoped guns are zeroed on the scope camera's centre line, which looks down the bore (scope.zs Axis).
//
// Per gun: the muzzle, cm in the weapon controller's frame (F forward, L left, U up), measured
// off the held mesh through its MODELDEF chain (Depot tools/kit/rgeo.py to_flu).

class RSQ_MuzzleRail : Actor
{
	Default
	{
		+NOINTERACTION; +NOBLOCKMAP; +NOGRAVITY; +DONTSPLASH;
		Height 0; Radius 0; FloatSpeed 0;
		RenderStyle "None";
	}
	States { Spawn: TNT1 A 1; Stop; }
}

class RSQ_Muzzle : EventHandler
{
	bool busy;

	// fix-accuracy: the player's PROJECTILES (plasma, the RailGun's beam missiles, BD22's DecorativeTracers, rockets...).
	// P_SpawnPlayerMissile starts them AT the controller down its forward (p_mobj.cpp, OverrideAttackPosDir; the side and
	// height offsets are zeroed unless use_action_spawn_yzoffset) and P_CheckMissileSpawn steps them along their velocity.
	// WorldThingSpawned comes on the missile's first think (CallPostBeginPlay), the same tic, with target and velocity set:
	// a missile of ours still on that first step is turned from the controller's forward onto the drawn barrel and
	// started at the muzzle, the step kept. Speed, spread, damage: BD22's. A muzzle inside a wall leaves it as it was.
	override void WorldThingSpawned(WorldEvent e)
	{
		let c = e.Thing;
		if (!c || !c.bMISSILE)
			return;
		let mo = PlayerPawn(c.target);
		if (!mo || !mo.player || !RSVR_VRHand.InVR(mo))
			return;
		// 2.0.4i (owner 11-11: "while DOWN the shots seem to come from far to my right"; rig R3): BD22's muzzle glow
		// (PlayerMuzzle1-3: a bright sprite with a dynamic light, A_SpawnItemEx 30 forward, 5 right, 30-45 up) is placed
		// from the PAWN, not the gun: it stays at standing chest height to the front right wherever the gun is, about
		// 0.8 m above a gun held while DOWN. It is put on the drawn muzzle (the hand when the wall guard says no).
		if (c.Speed == 0 && c.vel == (0, 0, 0))
		{
			String cn = c.GetClassName();
			if (cn.Left(12) ~== "PlayerMuzzle")
			{
				Vector3 at; bool ok;
				[at, ok] = Where(mo);	// the main hand's gun (BD22's own states spawn it; an off-hand copy's glow lands there too)
				c.SetOrigin(at, false);
				c.ClearInterpolation();
				return;
			}
		}
		if (RSQ_Ballistics.IsMelee(c) || RSQ_Ballistics.MeleeHeld(mo))
			return;
		Name n = c.GetClassName();
		if (n == 'FlamethrowerProjectileNew' || n == 'FlamethrowerProjectileNew2' || n == 'FlamethrowerProjectileNew3'
			|| n == 'BigFireBallWithGravity' || n == 'Shotgunparticles2')
			return;	// flamespout.zs
		if (NotAShot(n))
			return;
		// born at which controller: the spawn step from it runs (within the spread) along the velocity, no longer than it
		double vl = c.vel.Length();
		bool off;
		if (Born(c.pos - mo.AttackPos, c.vel, vl))
			off = false;
		else if (Born(c.pos - mo.OffhandPos, c.vel, vl))
			off = true;
		else
			return;
		let w = off ? mo.player.OffhandWeapon : mo.player.ReadyWeapon;
		if (!HasBore(w))
			return;
		Vector3 at; bool ok;
		if (off)
			[at, ok] = OffWhere(mo);
		else
			[at, ok] = Where(mo);
		double da, dp;
		[da, dp] = AimOffset(w, FromFLU(w, ok));
		Vector3 fw = Dir(off ? mo.OffhandDir(mo, mo.angle, mo.pitch) : mo.AttackDir(mo, mo.angle, mo.pitch));
		Vector3 bw = Dir(off ? mo.OffhandDir(mo, mo.angle + da, mo.pitch + dp) : mo.AttackDir(mo, mo.angle + da, mo.pitch + dp));
		Vector3 hp = off ? mo.OffhandPos : mo.AttackPos;
		Vector3 was = c.pos, wasVel = c.vel;
		// 2.0.5: two hands on it, the projectile's spread (its velocity off the controller's forward) is shrunk first
		double k = off ? 1.0 : Steady(mo, w);
		if (k < 1.0 && vl > 0)
			c.vel = Tighten(c.vel / vl, fw, k) * vl;
		Vector3 step = Turn(c.pos - hp, fw, bw);
		c.vel = Turn(c.vel, fw, bw);
		if (vl > 0)
		{
			c.angle = VectorAngle(c.vel.x, c.vel.y);
			c.pitch = -atan2(c.vel.z, c.vel.xy.Length());
		}
		c.SetOrigin(at + step, false);
		if (!c.TestMobjLocation())
		{
			c.SetOrigin(was, false);
			c.vel = wasVel;
		}
	}

	// BD22 fires its helpers as player missiles too (Actors/Weapons/*.dec A_FireCustomMissile): casing and magazine
	// spawners (casings.zs puts their brass at the port), flashlight and noise probes, and melee strikes (kick, bash,
	// slide, execution, use). They are not shots and keep BD22's start and line.
	static bool NotAShot(Name n)
	{
		String s = n;
		s = s.MakeLower();
		static const String words[] = { "case", "casing", "clip", "ammospawn", "flashlight", "alerter", "taunter", "shakeyourass", "distantfiresound", "attack", "links" };
		for (int i = 0; i < words.Size(); i++)
			if (s.IndexOf(words[i]) >= 0)
				return true;
		return false;
	}

	static bool Born(Vector3 d, Vector3 v, double vl)
	{
		double dl = d.Length();
		if (dl < 1)
			return true;
		// A_FireProjectile turns a spread shot's velocity AFTER the spawn step (its angle / pitch arguments), so the step
		// and the velocity differ by the spread: BD22's widest is the shotgun tracers' random(-5, 5) in angle and pitch
		return vl > 0 && dl <= vl + 1 && (d dot v) / (dl * vl) > cos(15);
	}

	// 2.0.5 (owner 2026-11-09: "two handing a gun needs to cut down on spread"). The spread multiplier for a main-hand
	// shot: sv_rsq_twohand_spread while the off hand steadies the gun (the engine's Two-Hand Grip, RSVR_VRHand.Steadied),
	// 1 otherwise. A shotgun's pellet pattern is left alone unless sv_rsq_twohand_shotguns. An off-hand (dual) gun is
	// never steadied: the other hand is holding a gun.
	static double Steady(PlayerPawn mo, Weapon w)
	{
		if (!mo || !mo.player || !w || !RSVR_VRHand.InVR(mo) || !RSVR_VRHand.Steadied(mo))
			return 1.0;
		if (RSQ_Alias.BD(w) == 'Shot_Gun' || RSQ_Alias.BD(w) == 'SSG' || RSQ_Alias.BD(w) == 'AssaultShotgun' || RSQ_Alias.BD(w) == 'Revolver')
		{
			let sg = CVar.FindCVar('sv_rsq_twohand_shotguns');
			if (!sg || !sg.GetBool())
				return 1.0;
		}
		let cv = CVar.FindCVar('sv_rsq_twohand_spread');
		return cv ? clamp(cv.GetFloat(), 0.0, 1.0) : 1.0;
	}

	// a unit direction u pulled toward the aim line fw: its angle off fw shrunk by k (tan of it, exactly: close enough
	// for spreads of a few degrees)
	static Vector3 Tighten(Vector3 u, Vector3 fw, double k)
	{
		double along = u dot fw;
		Vector3 nu = fw * along + (u - fw * along) * k;
		double l = nu.Length();
		return l > 0 ? nu / l : u;
	}

	static Vector3 Dir(Vector3 ap)
	{
		double cp = cos(ap.y);
		return (cp * cos(ap.x), cp * sin(ap.x), -sin(ap.y));
	}

	// v turned by the rotation that takes unit a onto unit b (Rodrigues)
	static Vector3 Turn(Vector3 v, Vector3 a, Vector3 b)
	{
		Vector3 k = a cross b;
		double s = k.Length(), c = a dot b;
		if (s < 1e-9)
			return v;
		k /= s;
		return v * c + (k cross v) * s + k * ((k dot v) * (1 - c));
	}

	// (0, 0, 0): not moved.
	//   Sniper  XM21.md3 frame 0 (the only frame; X21G/X21F/P21F all show it), surface 9
	//           (trigger_safety_low.001_Cylinder.013, the body and barrel), MODELDEF.rsr Scale
	//           -10.485 10.485 10.485, Offset -0.2816 -44.5467, ZOffset -6.3157: the barrel's tip
	//           F 62.34, and the bore's centre L 0.28 U 5.03, the same from F 45 to the tip.
	static Vector3 Muzzle(Weapon w)
	{
		if (!w)
			return (0, 0, 0);
		Name n = RSQ_Alias.Exact(w);
		if (n == 'Sniper')	return (68.38, 6.31, 9.77);	// r9 port: moved with the gun to the FBX hand (was 62.3, 0.3, 5.0)
		if (w is 'RSQWS_1911')	return (23.79, 2.95, 5.50);	// this pack: the 1911's own muzzle at its seat (tools/row_1911.py)
		if (RSQ_Alias.BD(w) == 'BrutalPistol')	return (23.3, 2.2, 6.3);	// BD 2.0 b1: BrutalPistol.md3 frame 3 slide face (F 15.18, bore U 0.10 at the 1.99 placement), moved with the gun to the FBX hand
		// hands b3: BrutalSMG.md3 frame 3, the front-most face (surface 1, F 35.07, L -1.02..1.02, U -5.74..-3.71 at the
		// 1.99 placement: the barrel end under the rail), its centre moved with the gun by batch 2's move (shift + pistol r5 move)
		if (RSQ_Alias.BD(w) == 'BrutalSMG')	return (39.6, 4.4, 0.8);
		// moon-reload: rev.md3 frame 0, surface 3 (barrel and top strap), MODELDEF.rsqmoon placement. CONSTRUCTED:
		// no bore is modelled; the barrel is a box at the muzzle (face F 27.02-27.38, L -1.40..1.35, U 4.04..5.18):
		// its face's centre (reference/moonlight/bake_reload.txt "muzzle")
		if (n == 'BrutalRevolver')	return (35.03, 3.24, 8.51);	// batch 4: moved with the gun to the FBX hand (was 27.2, -0.03, 4.61)
		// batch 4: Rifle's drawn muzzle (front-most face centre of the ready frame, 65.80 0.49 2.57 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'Rifle')	return (71.18, 6.06, 11.42);
		// shotguns: AssaultShotgun's drawn muzzle (front-most face centre of the ready frame, 62.87 -0.13 -1.08 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'AssaultShotgun')	return (67.36, 11.02, -2.66);
		// batch 4: Revolver's drawn muzzle (front-most face centre of the ready frame, 21.54 -0.02 1.86 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'Revolver')	return (26.67, 2.61, 7.04);
		// shotguns: Shot_Gun's drawn muzzle (front-most face centre of the ready frame, 65.34 0.02 0.22 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'Shot_Gun')	return (69.20, 9.87, 1.83);
		// r9 port: GrenadeLauncher's drawn muzzle (front-most face centre of the ready frame, 46.39 0.00 1.16 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'GrenadeLauncher')	return (50.66, 9.86, -3.40);
		// r9 port: Rocket_Launcher's drawn muzzle (front-most face centre of the ready frame, 51.65 0.00 7.65 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'Rocket_Launcher')	return (55.59, 3.74, 17.94);
		// r9 port: RailGun's drawn muzzle (front-most face centre of the ready frame, 111.51 0.03 0.59 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'RailGun')	return (116.02, 10.31, 12.14);
		// r9 port: Plasma_Gun's drawn muzzle (front-most face centre of the ready frame, 72.10 0.07 -1.15 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'Plasma_Gun')	return (76.10, 8.12, 9.61);
		// r9 port: Minigun's drawn muzzle (front-most face centre of the ready frame, 95.92 0.35 -7.94 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'Minigun')	return (100.86, 11.49, 2.74);
		// r10 port: MG42's drawn muzzle (front-most face centre of the ready frame, 100.51 -0.15 1.86 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'MG42')	return (102.78, 8.98, 14.00);
		// r10 port: Machinegun's drawn muzzle (front-most face centre of the ready frame, 68.76 -0.04 4.77 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'Machinegun')	return (72.13, 6.28, 13.43);
		// r10 port: NukeLauncher's drawn muzzle (front-most face centre of the ready frame, 53.57 0.00 -2.87 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'NukeLauncher')	return (55.76, 6.04, 11.54);	// r12 port: moved with the re-fitted gun (was 55.74, 5.70, 11.67)
		// r10 port: BFG10k's drawn muzzle (front-most face centre of the ready frame, 88.00 0.01 -4.00 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'BFG10k')	return (90.36, 9.53, 7.73);	// r12 port: moved with the re-fitted gun (was 90.20, 9.05, 7.27)
		// r11 port: BIG_FUCKING_GUN's drawn muzzle (front-most face centre of the ready frame, 84.70 0.00 11.24 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'BIG_FUCKING_GUN')	return (86.71, 5.85, 21.97);
		// r11 port: IncendiaryLauncher's drawn muzzle (front-most face centre of the ready frame, 55.69 0.03 3.09 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'IncendiaryLauncher')	return (61.12, 11.16, 1.79);
		// r11 port: Devastator's drawn muzzle (front-most face centre of the ready frame, 64.79 0.02 13.59 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'Devastator')	return (66.55, 4.36, 21.68);
		// r11 port: SSG's drawn muzzle (front-most face centre of the ready frame, 36.84 0.04 1.12 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'SSG')	return (40.48, 8.12, -2.75);
		// r12 port: Unmaker's drawn muzzle (front-most face centre of the ready frame, 66.71 0.00 6.40 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'Unmaker')	return (72.53, 3.94, 17.03);
		// r12 port: HellishMissileLauncher's drawn muzzle (front-most face centre of the ready frame, 70.39 0.24 8.67 before the move), moved with the gun
		if (RSQ_Alias.BD(w) == 'HellishMissileLauncher')	return (77.12, 1.68, 22.32);
		// r12 port: FlameCannon's drawn NOZZLE TIP (bore axis at the nozzle ring's front lip, 49.90 -0.31 -2.67 before the move; bore-face centre +8.06 cm along the housing axis), moved with the gun (fc_place)
		if (RSQ_Alias.BD(w) == 'FlameCannon')	return (61.92, -5.02, -14.53);
		// fix-accuracy: MP40's drawn muzzle (front-most face centre of the ready frame, 62.41 -0.01 3.25 at 1.92), moved with the
		// gun by batch 3's place (MP40_b3.json; tools/accuracy/bore.py muzzle_row, which gives the Rifle's row to 0.01 cm). It had none.
		if (RSQ_Alias.BD(w) == 'MP40')	return (66.36, 6.54, 11.39);
		return (0, 0, 0);
	}

	// THE BORE (fix-accuracy, owner 2026-10-28 18:24, report item 31: "all the guns pull to the right").
	// A shot in VR goes down the engine's AttackDir, the CONTROLLER's forward (hw_vrmodes.cpp MapWeaponDir). The 2.0
	// hand ports turned every gun in the hand to the approved pistol's aim (MODELDEF AngleOffset 3.854 / PitchOffset
	// 3.363 / RollOffset 10.974) and moved every table that hangs off the gun -- muzzle, scope, casings, reloads -- but
	// not the shot. So the drawn barrel points 3.85 deg LEFT and 3.36 deg UP of where every shot went: the shots
	// landed right and low of the barrel (69 units right at 1024), and right and low of the scope's centre.
	// The bore, unit, F L U in the controller's frame: the port record's rotation R (Depot sets/bd22q/handfit/fits
	// ported_<gun>.json, the pistol's r5 move for the pistol, SMG and MP40) applied to the 1.92 bore. The 1.92 bores
	// run along the controller's forward (measured off the meshes, tools/accuracy/bore.py: Rifle, RailGun, Plasma,
	// Machinegun, MG42, Ruger within 0.35 deg). Every ported gun shares the one R, so the one bore:
	//   R @ (1, 0, 0) = (0.99602, 0.06710, 0.05866): yaw 3.854 deg left, pitch 3.363 deg up.
	// The FlameCannon (its own place, fc_place.json) is the one exception; its flames are aimed in flamespout.zs.
	static bool HasBore(Weapon w)
	{
		return w && !(RSQ_Alias.BD(w) == 'FlameCannon') && Muzzle(w) != (0, 0, 0);
	}

	static Vector3 Bore(Weapon w)
	{
		if (!HasBore(w))
			return (1, 0, 0);
		return (0.99602, 0.06710, 0.05866);
	}

	// The scoped guns are ZEROED: their shot is aimed from where it starts to the point on the scope camera's
	// centre line ZERO_M metres out, so it crosses the reticle's centre there and stays within the scope's height
	// over the bore (4-6 cm) of it everywhere else. The camera looks down the bore (RSQ_ScopeTable.Axis), so the
	// zeroed shot is within 0.1 deg of the drawn barrel.
	const ZERO_M = 30.0;

	// The direction a main- or off-hand shot leaving `from` (cm, F L U, the controller's frame) takes, F L U, unit.
	static Vector3 AimFLU(Weapon w, Vector3 from)
	{
		Vector3 b = Bore(w);
		int i = RSQ_ScopeTable.Index(w);
		if (i > 0)
		{
			Vector3 t = RSQ_ScopeTable.Lens(i) + RSQ_ScopeTable.Axis(i) * (ZERO_M * 100.0) - from;
			if (t.Length() > 0)
				b = t.Unit();
		}
		return b;
	}

	// The same as the yaw and pitch to add to an attack's own angles: the engine maps an attack's angle and pitch
	// through the controller (AttackDir / OffhandDir: relative yaw + is left, relative pitch + is up), so adding
	// these turns the shot, spread and all, onto the drawn barrel.
	static double, double AimOffset(Weapon w, Vector3 from)
	{
		if (!HasBore(w))
			return 0, 0;
		Vector3 b = AimFLU(w, from);
		return atan2(b.y, b.x), asin(clamp(b.z, -1, 1));
	}

	// the muzzle in the controller's frame, or the controller itself when the guard said no
	static Vector3 FromFLU(Weapon w, bool atMuzzle)
	{
		return atMuzzle ? Muzzle(w) : (0, 0, 0);
	}

	// THE OFF-HAND MUZZLE (playerrounds.zs round 4, moved here by fix-accuracy): the dual-wield copy's muzzle in the off
	// controller's frame (OffhandPos, OffhandDir: the mirrored left-hand frame the off layers are drawn in), same guard.
	static Vector3, bool OffWhere(PlayerPawn mo)
	{
		if (!mo || !mo.player || !RSVR_VRHand.InVR(mo))
			return mo ? mo.OffhandPos : (0, 0, 0), false;
		Vector3 hp = mo.OffhandPos;
		Vector3 m = Muzzle(mo.player.OffhandWeapon);
		if (m == (0, 0, 0))
			return hp, false;
		double ps = mo.Level.pixelstretch;
		if (ps <= 0)
			ps = 1.2;
		let cv = CVar.FindCVar('vr_vunits_per_meter');
		double vu = cv ? cv.GetFloat() : 34;
		if (vu <= 0)
			vu = 34;
		Vector3 F = RSVR_VRHand.OffDir(mo, 0, 0, ps);
		Vector3 L = RSVR_VRHand.OffDir(mo, 90, 0, ps);
		Vector3 U = RSVR_VRHand.OffDir(mo, 0, 90, ps);
		Vector3 w3 = (F * m.x + L * m.y + U * m.z) * (vu / 100.0);
		w3.z /= ps;
		double len = w3.Length();
		if (len > 0)
		{
			FLineTraceData tr;
			mo.LineTrace(VectorAngle(w3.x, w3.y), len, -asin(clamp(w3.z / len, -1, 1)),
				TRF_ABSPOSITION | TRF_THRUACTORS, hp.z, hp.x, hp.y, tr);
			if (tr.HitType != TRACE_HitNone)
				return hp, false;
		}
		return hp + w3, true;
	}

	// the muzzle in the world, or the controller itself when the guard says no
	static Vector3, bool Where(PlayerPawn mo)
	{
		Vector3 hp = RSVR_VRHand.HandPos(mo);
		if (!mo || !mo.player || !RSVR_VRHand.InVR(mo))
			return hp, false;
		Vector3 m = Muzzle(mo.player.ReadyWeapon);
		if (m == (0, 0, 0))
			return hp, false;
		double ps = mo.Level.pixelstretch;
		if (ps <= 0)
			ps = 1.2;
		let cv = CVar.FindCVar('vr_vunits_per_meter');
		double vu = cv ? cv.GetFloat() : 34;
		if (vu <= 0)
			vu = 34;
		// the same frame casings.zs places brass in
		Vector3 F = RSVR_VRHand.HandDir(mo, 0, 0, ps);
		Vector3 L = RSVR_VRHand.HandDir(mo, 90, 0, ps);
		Vector3 U = RSVR_VRHand.HandDir(mo, 0, 90, ps);
		Vector3 w3 = (F * m.x + L * m.y + U * m.z) * (vu / 100.0);
		w3.z /= ps;
		Vector3 at = hp + w3;
		// the wall guard
		double len = w3.Length();
		if (len > 0)
		{
			FLineTraceData tr;
			mo.LineTrace(VectorAngle(w3.x, w3.y), len, -asin(clamp(w3.z / len, -1, 1)),
				TRF_ABSPOSITION | TRF_THRUACTORS, hp.z, hp.x, hp.y, tr);
			if (tr.HitType != TRACE_HitNone)
				return hp, false;
		}
		return at, true;
	}

	override bool WorldHitscanPreFired(WorldEvent e)
	{
		let mo = PlayerPawn(e.Thing);
		if (busy || !mo || (e.AttackLineFlags & LAF_ISOFFHAND) || (e.AttackLineFlags & LAF_ABSPOSITION))
			return false;
		Vector3 at; bool ok;
		[at, ok] = Where(mo);
		// fix-accuracy: a gun with a bore is ALWAYS re-fired, from the muzzle or (guard said no) from the controller,
		// down the drawn barrel; melee traces are left as they are
		let w = mo.player ? mo.player.ReadyWeapon : null;
		bool bore = RSVR_VRHand.InVR(mo) && HasBore(w) && !(e.AttackLineFlags & LAF_ISMELEEATTACK);
		// 2.0.5: two hands on it, the shot's spread is shrunk. The engine maps an attack's angle and pitch through the
		// controller RELATIVE to mo.angle / mo.pitch (AttackDir), so what A_FireBullets rolled on top of them is the spread.
		double k = (e.AttackLineFlags & LAF_ISMELEEATTACK) ? 1.0 : Steady(mo, w);
		if (!ok && !bore && k >= 1.0)
			return false;
		double sa = e.AttackAngle, sp = e.AttackPitch;
		if (k < 1.0)
		{
			sa = mo.angle + Actor.DeltaAngle(mo.angle, sa) * k;
			sp = mo.pitch + (sp - mo.pitch) * k;
		}
		double da = 0, dp = 0;
		if (bore)
			[da, dp] = AimOffset(w, FromFLU(w, ok));
		busy = true;
		mo.LineAttack(sa + da, e.AttackDistance, sp + dp, e.Damage, e.DamageType, e.AttackPuffType,
			e.AttackLineFlags | LAF_ABSPOSITION, null, at.z, at.x, at.y);
		busy = false;
		return true;	// the engine's own trace, from the controller, is not run
	}

	override bool WorldRailgunPreFired(WorldEvent e)
	{
		let mo = PlayerPawn(e.Thing);
		if (busy || !mo || !mo.player)
			return false;
		bool off = (e.RailParams.flags & RGF_ISOFFHAND) != 0;
		let w = off ? mo.player.OffhandWeapon : mo.player.ReadyWeapon;
		bool bore = RSVR_VRHand.InVR(mo) && HasBore(w);
		Vector3 at; bool ok = false;
		if (!off)
			[at, ok] = Where(mo);
		if (e.RailParams.damage != 0 || off || !ok)
		{	// fix-accuracy: a damaging rail stays the player's own (its damage is credited to him), so it is fired
			// again by the player, turned onto the drawn barrel by its angle and pitch offsets (P_RailAttack adds them
			// before AttackDir): from the controller, zeroed like every other shot of that gun
			if (!bore)
				return false;
			double da, dp;
			[da, dp] = AimOffset(w, (0, 0, 0));
			FRailParams q;
			q.damage = e.RailParams.damage;
			q.offset_xy = e.RailParams.offset_xy;
			q.offset_z = e.RailParams.offset_z;
			q.color1 = e.RailParams.color1;
			q.color2 = e.RailParams.color2;
			q.maxdiff = e.RailParams.maxdiff;
			q.flags = e.RailParams.flags;
			q.puff = e.RailParams.puff;
			q.angleoffset = e.RailParams.angleoffset + da;
			q.pitchoffset = e.RailParams.pitchoffset + dp;
			q.distance = e.RailParams.distance;
			q.duration = e.RailParams.duration;
			q.sparsity = e.RailParams.sparsity;
			q.drift = e.RailParams.drift;
			q.spawnclass = e.RailParams.spawnclass;
			q.SpiralOffset = e.RailParams.SpiralOffset;
			q.limit = e.RailParams.limit;
			busy = true;
			mo.RailAttack(q);
			busy = false;
			return true;
		}
		// the trail-only rail: drawn again from the muzzle, down the drawn barrel
		let r = Actor.Spawn('RSQ_MuzzleRail', at);
		if (!r)
			return false;
		// the engine's own direction for this rail (p_map.cpp P_RailAttack, VR branch)
		// 2026-10-27: AttackDir only while live (see rsvr/vrhand.zs); else the event's own angles
		double ta = 0, tp = 0;
		if (bore)
			[ta, tp] = AimOffset(w, FromFLU(w, true));
		Vector3 ap = mo.OverrideAttackPosDir ? mo.AttackDir(mo, e.AttackAngle + ta, e.AttackPitch + tp)
			: (e.AttackAngle, e.AttackPitch, 0);
		r.angle = ap.x;
		r.pitch = ap.y;
		r.target = mo;
		FRailParams p;
		p.damage = e.RailParams.damage;
		p.offset_xy = 0;
		p.offset_z = 0;
		p.color1 = e.RailParams.color1;
		p.color2 = e.RailParams.color2;
		p.maxdiff = e.RailParams.maxdiff;
		p.flags = (e.RailParams.flags | RGF_CENTERZ) & ~RGF_ISOFFHAND;	// CENTERZ: start at the mount, not at an attack height
		p.puff = e.RailParams.puff;
		p.angleoffset = 0;
		p.pitchoffset = 0;
		p.distance = e.RailParams.distance;
		p.duration = e.RailParams.duration;
		p.sparsity = e.RailParams.sparsity;
		p.drift = e.RailParams.drift;
		p.spawnclass = e.RailParams.spawnclass;
		p.SpiralOffset = e.RailParams.SpiralOffset;
		p.limit = e.RailParams.limit;
		busy = true;
		r.RailAttack(p);
		busy = false;
		r.Destroy();
		return true;	// the engine's trail, from the controller, is not drawn
	}
}
