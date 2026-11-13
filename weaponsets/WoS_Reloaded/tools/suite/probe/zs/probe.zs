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
	int doorLine;
	override void OnRegister() { doorLine = -1; }
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
		String cs = cn;
		if (cs.Left(5) == "RSQB_" || cs.Left(6) == "RSQGN_")
			Console.Printf("PROBE t%d basic %s", level.maptime, cn);
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
				// (GNRC_Reloaded has no rocket lock-on: the AIM line is not logged)
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
		if (e.Name ~== "probe_hand")	// both hands in the body frame (forward, left, up), map units
		{
			for (int h = 0; h < 2; h++)
			{
				Vector3 d = (h == 0 ? mo.AttackPos : mo.OffhandPos) - mo.pos;
				double c = cos(mo.angle), s = sin(mo.angle);
				Console.Printf("HAND t%d %d fwd %.1f left %.1f up %.1f", level.maptime, h, d.x * c + d.y * s, -d.x * s + d.y * c, d.z);
			}
			return;
		}
		if (e.Name ~== "probe_door")	// the nearest manual door: the player put Args[0] units in front of its face, facing it
		{
			Line best = null; double bd = 1e9;
			for (int i = 0; i < Level.Lines.Size(); i++)
			{
				Line l = Level.Lines[i];
				if (!l.backsector || !RSQB_DG_Door.IsDoorSpecial(l.special) || l.args[0] != 0) continue;
				double d = (mo.pos.xy - (l.v1.p + l.delta * 0.5)).Length();
				if (d < bd) { bd = d; best = l; }
			}
			if (!best) { Console.Printf("DOOR none"); return; }
			doorLine = best.Index();
			Vector2 mid = best.v1.p + best.delta * 0.5;
			Vector2 nrm = (best.delta.y, -best.delta.x).Unit();	// the front side
			Vector2 at = mid + nrm * e.Args[0];
			mo.SetOrigin((at.x, at.y, best.frontsector.floorplane.ZAtPoint(at)), false);
			mo.angle = VectorAngle(-nrm.x, -nrm.y);
			mo.vel = (0, 0, 0);
			Console.Printf("DOOR line %d special %d ceiling %.1f floor %.1f at %.0f %.0f", doorLine, best.special, best.backsector.ceilingplane.ZAtPoint(mid), best.backsector.floorplane.ZAtPoint(mid), at.x, at.y);
			return;
		}
		if (e.Name ~== "probe_blasttest")	// the basic grenade's blast (part 0) 64 units ahead, a barrel Args[0] units past it
		{
			Vector3 at = mo.Vec3Angle(64, mo.angle, 0);
			let g = Actor.Spawn('RSQB_GN_Thrown', at + (0, 0, 8), NO_REPLACE);
			let b = Actor.Spawn('ExplosiveBarrel', mo.Vec3Angle(64 + e.Args[0], mo.angle, 0), NO_REPLACE);
			if (!g || !b) { Console.Printf("BLASTTEST no spawn"); return; }
			g.target = mo;
			Console.Printf("BLASTTEST barrel at %.0f from the blast, health %d", g.Distance3D(b), b.health);
			RSQB_GN_Thrown.Blast(g, mo, 0, 1.0);
			Console.Printf("BLASTTEST after: barrel health %d", b.health);
			g.Destroy();
			return;
		}
		if (e.Name ~== "probe_ceil" && doorLine >= 0)
		{
			Line l = Level.Lines[doorLine];
			Vector2 mid = l.v1.p + l.delta * 0.5;
			Vector3 hp = mo.AttackPos;
			double c2 = l.delta dot l.delta;
			double tt = clamp(((hp.xy - l.v1.p) dot l.delta) / c2, 0.0, 1.0);
			Console.Printf("CEIL t%d %.1f hand-to-door %.1f", level.maptime, l.backsector.ceilingplane.ZAtPoint(mid), (hp.xy - (l.v1.p + l.delta * tt)).Length());
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
