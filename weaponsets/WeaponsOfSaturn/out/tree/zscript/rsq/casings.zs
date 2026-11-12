// 1.38 (owner): in VR the spent brass of the pistol, rifle, SMG and assault shotgun comes out of
// the gun's own ejection port (just above the firing hand), flicked out to the gun's right and up.
// BD22's own casings (PistolCasing, EmptyBrass, ShotgunCasing) are kept; only where they start and
// how they fly changes. Ports: cm in the weapon controller's frame (F L U), measured on each gun's
// ready frame (kitbash/ports.png).
// 1.97: and of the pump gun, the SSG, the Revolver and the Shotvolver. Those four are
// measured off the held mesh -- the surface the model-maker named, or the hole itself --
// NOT from WMCARD.bd22, whose ejectport every one of the 25 cards annotates "the point
// and the direction are estimates", and which misses all four of the ports above by
// between 0.8 and 10.8 cm. See tools/bd22_plus.py casings for the measurement and the
// four guns whose mesh has no port in it at all.
class RSA_Casings : EventHandler
{
	// (0, 0, 0): not one of ours. (This engine's VM cannot pass a Vector3 out by reference.)
	static Vector3 Port(Weapon w)
	{
		if (RSQ_Alias.BD(w) == 'BrutalPistol')		return (7.2, -0.1, 6.4);	// BD 2.0 b1: moved with the gun to the FBX hand (was -1.0, -1.0, 1.3)
		if (RSQ_Alias.BD(w) == 'Rifle')				return (15.7, 1.2, 8.0);	// batch 4: moved with the gun to the FBX hand (was 10.0, -0.6, 2.6)
		if (RSQ_Alias.BD(w) == 'BrutalSMG')			return (18.7, -0.8, 2.6);	// batch 2: moved with the gun to the FBX hand (was 14.0, -3.1, -1.0)
		if (RSQ_Alias.BD(w) == 'AssaultShotgun')		return (20.8, 6.5, -5.2);	// shotguns: moved with the gun to the FBX hand (was 16.0, -1.4, -0.6)
		if (RSQ_Alias.BD(w) == 'Shot_Gun')			return (17.0, 4.9, -1.7);	// shotguns: moved with the gun to the FBX hand (was 12.8, -1.5, 0.0)	// 1.97: the port the model-maker named `eject`
		if (RSQ_Alias.BD(w) == 'SSG')					return (8.1, 5.8, -3.9);	// r11 port: moved with the gun to the FBX hand (was 4.4, 0.0, 1.9)	// 1.97: the break-open breech, surface `Open`
		if (RSQ_Alias.BD(w) == 'Revolver')			return (13.2, 2.0, 4.6);	// batch 4: moved with the gun to the FBX hand (was 7.9, 0.0, 0.2)	// 1.97: the cylinder: the mean of its five `shells`
		if (RSQ_Alias.BD(w) == 'MG42')				return (18.0, 3.9, 6.6);	// r10 port: moved with the gun to the FBX hand (was 15.3, 0.0, -0.6)	// 1.97: the chute in the receiver floor, the hole itself
		if (RSQ_Alias.BD(w) == 'Machinegun')			return (18.3, 4.1, 1.3);	// r10 port: moved with the gun to the FBX hand (was 14.3, -0.3, -4.3)	// 1.97: the chute under the breech, the hole itself
		if (RSQ_Alias.BD(w) == 'MP40')				return (38.9, 2.5, 9.4);	// batch 3: moved with the gun to the FBX hand (was 34.7, -2.2, 3.3)	// 1.97: CONSTRUCTED: the bolt face at the right wall, on the bore line -- no port is modelled
		return (0, 0, 0);
	}

	// 1.97: BD22 throws one EmptyBrass for the Rifle (5.56), the Minigun (5.56),
	// the Machinegun (7.62) and the MG42 (7.92), and its 9mm brass is 2.25 map
	// units -- about three and a half times a real case. Each casing is scaled to
	// the round the gun actually fires, anchored on BD22's OWN 12-gauge (23 px at
	// Scale 0.25 for a 70.06 mm hull), so the shotgun is unchanged and everything
	// else is measured against it. 0 = leave BD22's own size alone.
	//
	// The Revolver is deliberately NOT here. REMA's sheet calls it brass_357, but
	// BD22's Revolver takes AmmoType1 "AmmoShell", carries shotpellets = 9 and
	// fires SSGCaseSpawner: it is a BUCKSHOT revolver and its red hull is right.
	static double Size(Name gun, Name casing)
	{
		if (gun == 'BrutalPistol' && casing == 'PistolCasing')
			return 0.1051;	// 1.97: 9x19, casing_9mm.md3
		if (gun == 'BrutalSMG' && casing == 'PistolCasing')
			return 0.1051;	// 1.97: 9x19, casing_9mm.md3
		if (gun == 'MP40' && casing == 'PistolCasing')
			return 0.1051;	// 1.97: 9x19, casing_9mm.md3
		if (gun == 'Rifle' && casing == 'EmptyBrass')
			return 0.1529;	// 1.97: 5.56x45, casing_rifle.md3
		if (gun == 'Minigun' && casing == 'EmptyBrass')
			return 0.1529;	// 1.97: 5.56x45, casing_rifle.md3
		if (gun == 'Machinegun' && casing == 'EmptyBrass')
			return 0.1744;	// 1.97: 7.62x51, the same mesh at its 7.62 MODELDEF scale
		if (gun == 'MG42' && casing == 'EmptyBrass')
			return 0.1949;	// 1.97: 7.92x57 Mauser, the real round: RS has no mesh for it
		if (gun == 'SSG' && casing == 'ShotgunCasing')
			return 0.2719;	// 1.97: 12ga 3in magnum, the real round: RS cannot tell it from 2.75in
		return 0;
	}

	// 1.97: not every gun throws its case the same way, and it is three things.
	// SIDE is flicked out of a port in the receiver wall, which is the default and
	// what 1.38 wrote. DOWN is thrown out of a chute in the receiver FLOOR under the
	// gun's own gas -- the MG42, whose port is exactly that and nothing in either
	// wall. TIP is not thrown at all: RSBDEFS calls brass_357 "dumped from a
	// cylinder, not thrown by a port: slow, no glow" and hull_12ga_magnum "dumped
	// from an open breech", so the shooter tips those out. A belt gun at 1200 rpm is
	// NOT that, which is why DOWN is its own: the same direction, nothing like the speed.
	const SIDE = 0;
	const DOWN = 1;
	const TIP = 2;

	static int Throw(Weapon w)
	{
		if (RSQ_Alias.BD(w) == 'SSG')
			return TIP;
		if (RSQ_Alias.BD(w) == 'Revolver')
			return TIP;
		if (RSQ_Alias.BD(w) == 'MG42')
			return DOWN;
		if (RSQ_Alias.BD(w) == 'Machinegun')
			return DOWN;
		return SIDE;
	}

	// the player who fired: the casing's target (BD22's spawner hands its own on), or the spawner's
	static PlayerPawn Shooter(Actor c)
	{
		let t = c.target;
		if (PlayerPawn(t))
			return PlayerPawn(t);
		if (t && PlayerPawn(t.target))
			return PlayerPawn(t.target);
		return multiplayer ? null : players[consoleplayer].mo;	// this pack: WoS's casings do not always carry their shooter
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let c = e.Thing;
		if (!c)
			return;
		Name n = c.GetClassName();
		// this pack: WoS's casings under the names BD22 VR's tables know
		if (n == 'RSQWS_9mmCasing' || n == 'RSQWS_45Casing') n = 'PistolCasing';
		else if (n == 'RSQWS_RifleCasing' || n == 'RSQWS_ChaingunCasing') n = 'EmptyBrass';
		else if (n == 'RSQWS_ShotgunCasing') n = 'ShotgunCasing';
		if (n != 'PistolCasing' && n != 'EmptyBrass' && n != 'ShotgunCasing'
			&& n != 'MGLinks')
			return;
		let mo = Shooter(c);
		if (!mo || !mo.player)
			return;
		// 1.99 F7: the real mesh, if this gun's cartridge has one. NOT behind the
		// VR test below: a 12-gauge hull is a 12-gauge hull on a flat screen too.
		// It sets scale 1.0 itself, because a lent model's size is the MODELDEF's
		// and the actor's own scale multiplies into it.
		bool lent = RSQ_CaseModels.Lend(c, RSQ_Alias.BD(mo.player.ReadyWeapon), n);
		if (!RSVR_VRHand.InVR(mo))
			return;
		double sz = Size(RSQ_Alias.BD(mo.player.ReadyWeapon), n);
		if (sz > 0 && !lent)	// F11: a lent 3D casing is real-size at 1.0 (casemodels.zs)
			c.A_SetScale(sz, sz);
		// r4 (owner: "the over-under machine gun's casings come out of the barrel"): placed
		// NOW, not on the next WorldTick. The engine runs this from the fresh-thinker pass
		// (dthinker.cpp: CallPostBeginPlay, then the first CallTick in the same tic), with
		// target and vel already set, so everything Place() needs is here. Waiting a tic left
		// every casing drawn for one tic where BD22's spawner dropped it -- the spawner is a
		// Speed 20 projectile (Casing.dec 50CaseSpawn2 / RifleCaseSpawn), so that is about 20
		// map units out along the barrel, and its second casing (MGLinks) another 20 further.
		// Rig, Machinegun, r3: age 0 at the spawner, age 1 at the port (14.5 -0.3 -5.6).
		Place(c);
	}

	void Place(Actor c)
	{
		let mo = Shooter(c);
		if (!mo || !mo.player)
			return;
		let p = mo.player;
		Vector3 hp = RSVR_VRHand.HandPos(mo), op = RSVR_VRHand.OffPos(mo);
		bool off = (c.pos - op).Length() < (c.pos - hp).Length() && p.OffhandWeapon && !(p.OffhandWeapon is 'RSQ_Hands');
		Weapon w = off ? p.OffhandWeapon : p.ReadyWeapon;
		Vector3 port = Port(w);
		if (port == (0, 0, 0))
			return;
		double ps = mo.Level.pixelstretch;
		if (ps <= 0)
			ps = 1.2;
		let cv = CVar.FindCVar('vr_vunits_per_meter');
		double vu = cv ? cv.GetFloat() : 34;
		if (vu <= 0)
			vu = 34;
		Vector3 F = off ? RSVR_VRHand.OffDir(mo, 0, 0, ps) : RSVR_VRHand.HandDir(mo, 0, 0, ps);
		Vector3 L = off ? RSVR_VRHand.OffDir(mo, 90, 0, ps) : RSVR_VRHand.HandDir(mo, 90, 0, ps);
		Vector3 U = off ? RSVR_VRHand.OffDir(mo, 0, 90, ps) : RSVR_VRHand.HandDir(mo, 0, 90, ps);
		Vector3 w3 = (F * port.x + L * port.y + U * port.z) * (vu / 100.0);
		w3.z /= ps;
		Vector3 pos = (off ? op : hp) + w3;
		// out of the port, each gun its own way, at its own casing speed
		Vector3 d;
		double slow = 1.0;
		int mode = Throw(w);
		if (mode == TIP)
		{
			d = -U * frandom(0.8, 1.0) - F * frandom(0.1, 0.3) + L * frandom(-0.25, 0.25);
			slow = frandom(0.35, 0.5);
		}
		else if (mode == DOWN)
			d = -U * frandom(0.85, 1.0) - F * frandom(0.0, 0.2) + L * frandom(-0.3, 0.3);
		else
			d = -L * 0.75 + U * frandom(0.45, 0.7) - F * frandom(0.05, 0.25);
		d.z /= ps;
		d = d.Unit();
		double spd = c.vel.Length();
		if (spd < 1)
			spd = 4;
		c.SetOrigin(pos, false);
		c.vel = d * spd * slow + mo.vel;
		c.angle = atan2(d.y, d.x);
	}
}
