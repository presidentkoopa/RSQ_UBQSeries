// TEST ONLY (never ships): logs for the RSQ Grenade rig probes. Lines start GRP.
class GRP_Probe : EventHandler
{
	int lastFrame;
	override void WorldLoaded(WorldEvent e)
	{
		int s = 0, k = 0, items = 0;
		let it = ThinkerIterator.Create("Inventory");
		Inventory i;
		while (i = Inventory(it.Next()))
		{
			if (i.Owner) continue;
			if (!i.bSpecial) Console.Printf("GRP unowned non-pickup %s at (%.0f %.0f %.0f) destroyed %d", i.GetClassName(), i.pos.x, i.pos.y, i.pos.z, i.bDestroyed);
			if (!i.bSpecial) continue;
			if (i.GetClassName() == 'RSQGN_Pack') k++;
			else if (i.GetClassName() == 'RSQGN_Ammo') s++;
			else items++;
		}
		Console.Printf("GRP map %s: %d other items lying, our singles %d, our packs %d", level.MapName, items, s, k);
	}
	override void WorldThingDamaged(WorldEvent e)
	{
		Console.Printf("GRP t%d damaged %s by %s via %s: %d %s (health now %d)", level.maptime,
			e.Thing ? e.Thing.GetClassName() : 'none', e.DamageSource ? e.DamageSource.GetClassName() : 'none',
			e.Inflictor ? e.Inflictor.GetClassName() : 'none', e.Damage, e.DamageType, e.Thing ? e.Thing.health : 0);
	}
	override void WorldThingDied(WorldEvent e)
	{
		Console.Printf("GRP t%d died %s, killer %s via %s", level.maptime, e.Thing ? e.Thing.GetClassName() : 'none',
			e.Thing && e.Thing.target ? e.Thing.target.GetClassName() : 'none', e.Inflictor ? e.Inflictor.GetClassName() : 'none');
	}
	override void NetworkProcess(ConsoleEvent e)
	{
		let pmo = players[e.Player].mo;
		if (!pmo) return;
		if (e.Name == "grp_mon")
		{
			double d = e.Args[0] > 0 ? e.Args[0] : 256;
			String cn = e.Args[1] == 1 ? "ZombieMan" : "DoomImp";
			let m = Actor.Spawn(cn, pmo.Vec3Angle(d, pmo.angle + e.Args[2], 0), ALLOW_REPLACE);
			if (m) { m.angle = m.AngleTo(pmo); Console.Printf("GRP t%d spawned %s at (%.0f %.0f %.0f), %.0f ahead", level.maptime, m.GetClassName(), m.pos.x, m.pos.y, m.pos.z, d); }
		}
		else if (e.Name == "grp_put")
		{
			String cn = e.Args[1] == 1 ? "RSQGN_Pack" : "RSQGN_Ammo";
			let m = Actor.Spawn(cn, pmo.Vec3Angle(e.Args[0], pmo.angle + e.Args[2], 0), ALLOW_REPLACE);
			if (m) Console.Printf("GRP t%d put %s at (%.0f %.0f %.0f)", level.maptime, m.GetClassName(), m.pos.x, m.pos.y, m.pos.z);
		}
		else if (e.Name == "grp_push") pmo.Thrust(e.Args[0], pmo.angle + e.Args[1]);
		else if (e.Name == "grp_inv")
		{
			String n1 = "RSQGN_Ammo"; class<Inventory> c1 = n1;
			String n2 = "RSQGN_Grenade"; class<Inventory> c2 = n2;
			String n3 = "HandGrenades"; class<Inventory> c3 = n3;
			String n4 = "GrenadeAmmo"; class<Inventory> c4 = n4;
			int ours = 0;
			let it = ThinkerIterator.Create("Actor");
			Actor a;
			while (a = Actor(it.Next())) { String cn = a.GetClassName(); if (cn.Left(6) == "RSQGN_" && !(a is "Inventory" && Inventory(a).Owner)) ours++; }
			Console.Printf("GRP t%d inv: RSQGN_Grenade %d, RSQGN_Ammo %d, HandGrenades %d, GrenadeAmmo %d; RSQGN_ actors in the world %d; ready %s off %s",
				level.maptime, c2 ? pmo.CountInv(c2) : -1, c1 ? pmo.CountInv(c1) : -1, c3 ? pmo.CountInv(c3) : -1, c4 ? pmo.CountInv(c4) : -1, ours,
				pmo.player.ReadyWeapon ? pmo.player.ReadyWeapon.GetClassName() : 'none', pmo.player.OffhandWeapon ? pmo.player.OffhandWeapon.GetClassName() : 'none');
		}
	}
	override void WorldTick()
	{
		let p = players[consoleplayer];
		let pmo = p.mo;
		if (!pmo) return;
		let cv = CVar.GetCVar("grp_trace", p);
		int tr = cv ? cv.GetInt() : 0;
		if (tr <= 0) return;
		if (level.maptime % tr == 0)
		{
			let si = ServiceIterator.Find("RSQTR_RigService");
			let sv = si ? si.Next() : null;
			if (sv) Console.Printf("GRP t%d rig region main %d off %d", level.maptime, sv.GetInt("rig.region", "", 0, 0, pmo), sv.GetInt("rig.region", "", 1, 0, pmo));
			String n = "RSQGN_Geo"; class<Object> gc = n;
			int fr = -1;
			let psp = p.FindPSprite(PSP_WEAPON);
			if (psp) fr = psp.Frame;
			Vector3 h0 = pmo.AttackPos, h1 = pmo.OffhandPos;
			String ring = "";
			if (gc)
			{
				Vector3 r = h0 + RSQGN_Geo.FromHand(pmo, 0, (3.45, 5.12, 5.06));
				Vector3 nd = h0 + RSQGN_Geo.FromHand(pmo, 0, (2.77, 4.23, -1.97));
				ring = String.Format(" ring (%.1f %.1f %.1f) off->ring %.1f cm nade->eyes %.2f m", r.x, r.y, r.z, RSQGN_Geo.Metres(pmo, h1 - r) * 100,
					RSQGN_Geo.Metres(pmo, nd - (pmo.pos.x, pmo.pos.y, p.viewz)));
			}
			Console.Printf("GRP t%d psp frame %d btn %d main (%.1f %.1f %.1f) off (%.1f %.1f %.1f) pawn (%.1f %.1f %.1f) view %.1f%s", level.maptime, fr, p.cmd.buttons,
				h0.x, h0.y, h0.z, h1.x, h1.y, h1.z, pmo.pos.x, pmo.pos.y, pmo.pos.z, p.viewz, ring);
		}
		let it = ThinkerIterator.Create("RSQGN_Thrown");
		Actor g;
		while (g = Actor(it.Next()))
			Console.Printf("GRP t%d thrown at (%.1f %.1f %.1f) vel (%.2f %.2f %.2f) missile %d floorz %.1f frame %d pitch %.0f roll %.0f", level.maptime, g.pos.x, g.pos.y, g.pos.z, g.vel.x, g.vel.y, g.vel.z, g.bMissile, g.floorz, g.frame, g.pitch, g.roll);
	}
}
