// RIG ONLY (tools/suite.py): logs what the player holds, its ammo, which state it is in, what it fires and what it
// damages. Never shipped.
class RSPROBE_H : EventHandler
{
	Name last;
	String lastLab;
	static const String WL[] = { "Ready", "Fire", "Hold", "AltFire", "AltHold", "Reload", "StockReload", "RSR_Out", "RSR_Wait",
		"RSP_LoadWait", "RSP_LoadWaitE", "RSP_P1Wait", "RSP_P2Wait", "RSB_Wait", "RSM_Dry", "RSM_FireGrenade", "RSA_RLLock",
		"DoKick", "AirKick", "RSVR_SawRun", "SemiHold", "PumpStock", "Select", "Deselect" };
	int shots;
	Actor spawnedLast;
	override void WorldTick()
	{
		let p = players[consoleplayer];
		if (!p.mo) return;
		let w = p.ReadyWeapon;
		Name n = w ? w.GetClassName() : 'None';
		if (n != last)
		{
			last = n;
			Console.Printf("PROBE t%d ready %s off %s", level.maptime, n, p.OffhandWeapon ? "" .. p.OffhandWeapon.GetClassName() : "none");
		}
		let ec = CVar.FindCVar('rsprobe_elev');
		if (ec && ec.GetInt() > 0)
		{
			double pst = level.pixelstretch > 0 ? level.pixelstretch : 1.2;
			Vector3 hd = RSVR_VRHand.HandDir(p.mo, 0, 0, pst);
			Console.Printf("ELEV t%d %.1f ready %d steady %d", level.maptime, asin(clamp(hd.z, -1, 1)), (p.WeaponState & WF_WEAPONREADY) != 0, RSVR_VRHand.Steadied(p.mo));
		}
		if (w)
		{
			let ps = p.FindPSprite(PSP_WEAPON);
			String lab = "?";
			if (ps && ps.CurState)
				for (int q = 0; q < WL.Size(); q++) { let st = w.FindStateByString(WL[q], true); if (st && ps.CurState.InStateSequence(st)) { lab = WL[q]; break; } }
			if (lab != lastLab)
			{
				lastLab = lab;
				Console.Printf("STATE t%d %s %s%s", level.maptime, n, lab, lab == "?" && ps && ps.CurState ? String.Format(" (sprite %d frame %c tics %d)", int(ps.Sprite), 65 + ps.Frame, ps.Tics) : "");
			}
		}
	}
	override void WorldHitscanFired(WorldEvent e) { if (e.Thing && e.Thing.player) { shots++; Console.Printf("PROBE t%d hitscan", level.maptime); } }
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a) return;
		Name cn = a.GetClassName();
		if (cn == 'RSQ_PlayerRound' || cn == 'RSQ_PiercingRound' || cn == 'RSQ_Bullet')
			Console.Printf("PROBE t%d round %s", level.maptime, cn);
		else if (a.bMissile && a.target && a.target.player)
			Console.Printf("PROBE t%d missile %s", level.maptime, cn);
		if (cn == 'RSQ_Debris' || cn == 'RSQ_ImpactLight' || cn == 'RSQ_Flash')
			Console.Printf("PROBE t%d bfx %s", level.maptime, cn);
		if (cn == 'RSQGN_HandBlast' || cn == 'RSQ_M203Fallback')
			Console.Printf("PROBE t%d blast %s", level.maptime, cn);
	}
	override void WorldThingDamaged(WorldEvent e)
	{
		if (e.Thing && !e.Thing.player)
			Console.Printf("DMG t%d %s by %s %d", level.maptime, e.Thing.GetClassName(), e.Inflictor ? "" .. e.Inflictor.GetClassName() : "none", e.Damage);
	}
	override void NetworkProcess(ConsoleEvent e)
	{
		let mo = players[consoleplayer].mo;
		if (!mo) return;
		if (e.Name ~== "probe_ammo")
		{
			if (spawnedLast)
			{
				Vector3 af, ad;
				[af, ad] = RSQ_RocketLock.Aim(mo);
				Vector3 to = spawnedLast.pos + (0, 0, spawnedLast.height * 0.5) - af;
				Console.Printf("AIM t%d from %.0f %.0f %.0f dir %.2f %.2f %.2f to target %.0f %.0f %.0f angle %.1f", level.maptime, af.x, af.y, af.z, ad.x, ad.y, ad.z, to.x, to.y, to.z, acos(clamp(to.Unit() dot ad, -1, 1)));
			}
			if (spawnedLast) Console.Printf("SPAWNED t%d %s health %d pos %.0f %.0f %.0f friendly %d dormant %d", level.maptime, spawnedLast.GetClassName(), spawnedLast.health, spawnedLast.pos.x, spawnedLast.pos.y, spawnedLast.pos.z, spawnedLast.bFriendly, spawnedLast.bDormant);
			else Console.Printf("SPAWNED t%d gone", level.maptime);
			for (int h = 0; h < 2; h++)
			{
				let w = h ? players[consoleplayer].OffhandWeapon : players[consoleplayer].ReadyWeapon;
				if (!w) continue;
				Console.Printf("AMMO t%d %s %s %s=%d %s=%d", level.maptime, h ? "off" : "main", w.GetClassName(),
					w.Ammo1 ? "" .. w.Ammo1.GetClassName() : "-", w.Ammo1 ? w.Ammo1.Amount : -1,
					w.Ammo2 ? "" .. w.Ammo2.GetClassName() : "-", w.Ammo2 ? w.Ammo2.Amount : -1);
			}
			return;
		}
		if (e.Name ~== "probe_empty")	// the main gun's loaded rounds to Args[0] (0: empty)
		{
			let w = players[consoleplayer].ReadyWeapon;
			if (w && w.Ammo2) w.Ammo2.Amount = e.Args[0];
			return;
		}
		if (e.Name.Left(12) ~== "probe_spawn:")	// probe_spawn:<class> with Args[0] = map units straight ahead
		{
			Name n = e.Name.Mid(12);
			class<Actor> c = n;
			if (!c) { Console.Printf("PROBE spawn %s: no such class", n); return; }
			let a = Actor.Spawn(c, mo.Vec3Angle(e.Args[0], mo.angle, 0) + (cos(mo.angle + 90) * e.Args[1], sin(mo.angle + 90) * e.Args[1], 0), NO_REPLACE);
			spawnedLast = a;
			if (a) { a.angle = mo.angle + 180; a.bNeverTarget = false; Console.Printf("PROBE spawned %s at %d sight %d pos %.0f %.0f %.0f player %.0f %.0f %.0f angle %.0f monster %d shootable %d health %d", n, e.Args[0], mo.CheckSight(a, SF_IGNOREVISIBILITY), a.pos.x, a.pos.y, a.pos.z, mo.pos.x, mo.pos.y, mo.pos.z, mo.angle, a.bIsMonster, a.bShootable, a.health); }
			return;
		}
		if (e.Name.Left(6) ~== "probe:")	// pick-up check: a fresh one of the class, picked up
		{
			Name n = e.Name.Mid(6);
			class<Actor> c = n;
			if (!c) { Console.Printf("PROBE pickup %s: no such class", n); return; }
			let i2 = Inventory(Actor.Spawn(c, mo.pos + (64, 0, 0), NO_REPLACE));
			bool ok = i2 && i2.CallTryPickup(mo);
			Console.Printf("PICKUP %s %d owned %d", n, ok, mo.FindInventory((class<Inventory>)(c)) != null);
		}
	}
	override void WorldUnloaded(WorldEvent e) { Console.Printf("PROBE hitscans %d", shots); }
}
