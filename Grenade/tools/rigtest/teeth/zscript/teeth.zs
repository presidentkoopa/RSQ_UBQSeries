// TEST ONLY (never ships): the teeth pull on the rig, for RSQ Grenade and BD22 VR alike (names no class of either).
// Lines start GTP. Every gtp_trace tics: the buttons (A fire, a alt, O off fire, o off alt), the headset's height, the
// pawn's eye (viewz) and the real eyes (the headset), each controller's height under the real eyes and how far in
// front, and the OLD measure (controller to the pawn's x, y at viewz, metres). Each tic: the pin coming out, read from
// BD22 VR's RSG_PinOut token (RSQ Grenade logs its own with rsqgn_debug 1).
class GTP_Probe : EventHandler
{
	int lastPin;
	Actor hung, rocket;
	bool hungWas;
	Vector3 crossAt;
	int crossTic;
	static Actor Newest(Name cn)
	{
		let it = ThinkerIterator.Create("Actor");
		Actor a, best;
		while (a = Actor(it.Next())) if (a.GetClassName() == cn && a.health > -9999 && !a.bDestroyed && a.CurState && !a.InStateSequence(a.CurState, a.FindState("Boom")) && !a.InStateSequence(a.CurState, a.FindState("Explode"))) best = a;
		return best;
	}
	override void NetworkProcess(ConsoleEvent e)
	{
		let pmo = players[e.Player].mo;
		if (!pmo) return;
		// gtp_hang <units> [<class 0 RSQGN_Thrown / 1 HandGrenade>]: the newest thrown grenade held still in the air that far
		// straight ahead of the pawn at the main hand's height (a target for a level shot from a hand at the pawn's x, y)
		if (e.Name == "gtp_hang" || e.Name == "gtp_rocket")
		{
			Actor g = (e.Name == "gtp_rocket" && hung) ? hung : Newest(e.Args[1] == 1 ? "HandGrenade" : "RSQGN_Thrown");
			if (!g) { Console.Printf("GTP t%d no grenade to %s", level.maptime, e.Name); return; }
			if (e.Name == "gtp_hang")
			{
				double d = e.Args[0] > 0 ? e.Args[0] : 96;
				g.SetOrigin((pmo.pos.x + cos(pmo.angle) * d, pmo.pos.y + sin(pmo.angle) * d, pmo.AttackPos.z - 1.4), false);
				g.vel = (0, 0, 0); g.bNoGravity = true; hung = g; hungWas = true;
				if (e.Args[1] == 1) g.tics = -1;	// BD22's grenade: its fuse (state count) paused while it hangs
				Console.Printf("GTP t%d hung %s at (%.0f %.0f %.0f), %.0f ahead", level.maptime, g.GetClassName(), g.pos.x, g.pos.y, g.pos.z, d);
			}
			else
			{
				// a player-owned rocket from 40 units short of the grenade, flying at it
				Vector3 from = g.pos + (-cos(pmo.angle) * 40, -sin(pmo.angle) * 40, 0);
				let r = Actor.Spawn("Rocket", from, ALLOW_REPLACE);
				if (r) { r.target = pmo; r.angle = pmo.angle; r.vel = (cos(pmo.angle) * r.Speed, sin(pmo.angle) * r.Speed, 0); rocket = r; Console.Printf("GTP t%d rocket from 40 units short of the %s", level.maptime, g.GetClassName()); }
			}
			return;
		}
		// gtp_cross <speed> <0 RSQGN_Thrown / 1 HandGrenade> <tics>: a player-owned rocket at <speed> units a tic, aimed from
		// the eyes so that it crosses the newest thrown grenade's predicted point half-way through tic <tics> from now (so
		// its tic-end positions straddle the point by speed/2 each side: a point-sampled test can miss it)
		if (e.Name == "gtp_cross")
		{
			Actor g = Newest(e.Args[1] == 1 ? "HandGrenade" : "RSQGN_Thrown");
			if (!g) { Console.Printf("GTP t%d no grenade to cross", level.maptime); return; }
			int n = max(e.Args[2], 1);
			double gr = g.GetGravity();
			Vector3 at = g.pos + (g.vel.x * n, g.vel.y * n, g.vel.z * n - gr * n * (n - 1) / 2);
			Vector3 eye = (pmo.pos.x, pmo.pos.y, pmo.player.viewz);
			Vector3 dir = (at - eye).Unit();
			double sp = max(e.Args[0], 1);
			let r = Actor.Spawn("Rocket", at - dir * sp * (n - 0.5) - (0, 0, 4), ALLOW_REPLACE);
			if (r) { r.target = pmo; r.vel = dir * sp; r.angle = VectorAngle(dir.x, dir.y); rocket = r; crossAt = at; crossTic = level.maptime + n;
				Console.Printf("GTP t%d rocket at %.0f a tic, to cross the %s at (%.0f %.0f %.0f) in tic %d", level.maptime, sp, g.GetClassName(), at.x, at.y, at.z, crossTic); }
			return;
		}
		if (e.Name != "gtp_rail")
		{
			if (e.Name != "gtp_mon") return;
		}
		else
		{
			pmo.A_CustomRailgun(10, 0, 0, 0, RGF_SILENT | RGF_NOPIERCING, 0, 0, "BulletPuff");
			Console.Printf("GTP t%d railgun fired (A_CustomRailgun)", level.maptime);
			return;
		}
		let m = Actor.Spawn("DoomImp", pmo.Vec3Angle(e.Args[0] > 0 ? e.Args[0] : 250, pmo.angle, 0), ALLOW_REPLACE);
		if (m) { m.angle = m.AngleTo(pmo); Console.Printf("GTP t%d spawned %s %.0f ahead", level.maptime, m.GetClassName(), m.Distance2D(pmo)); }
	}
	override void WorldThingDamaged(WorldEvent e)
	{
		if (e.Thing && e.Thing.bIsMonster)
			Console.Printf("GTP t%d damaged %s by %s via %s: %d (health %d)", level.maptime, e.Thing.GetClassName(), e.DamageSource ? e.DamageSource.GetClassName() : 'none',
				e.Inflictor ? e.Inflictor.GetClassName() : 'none', e.Damage, e.Thing.health);
	}
	override void WorldTick()
	{
		let p = players[consoleplayer];
		let pmo = p.mo;
		if (!pmo) return;
		String pn = "RSG_PinOut"; class<Inventory> pc = pn;
		int pin = pc ? pmo.CountInv(pc) : -1;
		if (pin != lastPin && pc) Console.Printf("GTP t%d BD22 pin %s (RSG_PinOut %d -> %d)", level.maptime, pin > lastPin ? "OUT" : "back", lastPin, pin);
		lastPin = pin;
		if (hung || hungWas) { if (!hung || hung.bDestroyed || hung.InStateSequence(hung.CurState, hung.FindState("Boom")) || hung.InStateSequence(hung.CurState, hung.FindState("Explode"))) { hungWas = false; Console.Printf("GTP t%d the hung grenade went off", level.maptime); hung = null; } else hung.vel = (0, 0, 0); }
		if (rocket && !rocket.bDestroyed && hung) Console.Printf("GTP t%d rocket %.0f units from the hung grenade", level.maptime, (rocket.pos - hung.pos).Length());
		if (rocket && !rocket.bDestroyed && crossTic > 0 && abs(level.maptime - crossTic) <= 1) Console.Printf("GTP t%d rocket %.0f units from the crossing point", level.maptime, (rocket.pos - crossAt).Length());
		if (rocket && rocket.bDestroyed) rocket = null;
		let tg = CVar.GetCVar("gtp_thrown", p);
		if (tg && tg.GetInt() > 0)
		{
			let ti = ThinkerIterator.Create("Actor");
			Actor a;
			while (a = Actor(ti.Next())) if ((a.GetClassName() == 'RSQGN_Thrown' || a.GetClassName() == 'HandGrenade') && a.bMissile)
				Console.Printf("GTP t%d %s speed %.2f u/tic gravity %.3f", level.maptime, a.GetClassName(), a.vel.Length(), a.Gravity);
		}
		let cv = CVar.GetCVar("gtp_trace", p);
		int tr = cv ? cv.GetInt() : 0;
		if (tr <= 0 || level.maptime % tr) return;
		double vu = 34, ps = 1.2;
		let v = CVar.FindCVar("vr_vunits_per_meter"); if (v && v.GetFloat() > 0) vu = v.GetFloat();
		if (level.pixelstretch > 0) ps = level.pixelstretch;
		let ha = CVar.FindCVar("vr_height_adjust"); double adj = ha ? ha.GetFloat() : 0;
		double eyeZ = p.viewz + (pmo.HmdPosition.y + adj) * vu / ps - pmo.Default.ViewHeight;	// the engine's fixed eye height, never DOWN's scaled one
		int b = p.cmd.buttons;
		String bs = String.Format("%s%s%s%s", (b & BT_ATTACK) ? "A" : "-", (b & BT_ALTATTACK) ? "a" : "-", (b & BT_OFFHANDATTACK) ? "O" : "-", (b & BT_OFFHANDALTATTACK) ? "o" : "-");
		String hs = "";
		for (int h = 0; h < 2; h++)
		{
			Vector3 c = h == 0 ? pmo.AttackPos : pmo.OffhandPos;
			Vector2 d = c.xy - pmo.pos.xy;
			double fwd = (d.x * cos(pmo.angle) + d.y * sin(pmo.angle)) / vu;
			double under = (eyeZ - c.z) * ps / vu;
			Vector3 o = c - (pmo.pos.x, pmo.pos.y, p.viewz);
			double old = (o.x, o.y, o.z * ps).Length() / vu;
			hs = hs .. String.Format(" %s: %.2f under the eyes, %.2f ahead, old-measure %.2f m;", h == 0 ? "main" : "off", under, fwd, old);
		}
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next()))
		{
			if (!a.bIsMonster || a.health <= 0 || a.Distance2D(pmo) > 700) continue;
			let pain = a.FindState("Pain");
			Console.Printf("GTP t%d monster %s health %d freezetics %d in pain %d ice %d", level.maptime, a.GetClassName(), a.health, a.freezetics,
				pain && a.InStateSequence(a.CurState, pain), a.Translation == Translation.GetID('Ice'));
		}
		Console.Printf("GTP t%d btn %s hmd %.2f adj %.2f viewz %.2f m eyes %.2f m;%s ready %s off %s", level.maptime, bs, pmo.HmdPosition.y, adj,
			(p.viewz - pmo.floorz) * ps / vu, (eyeZ - pmo.floorz) * ps / vu, hs,
			p.ReadyWeapon ? p.ReadyWeapon.GetClassName() : 'none', p.OffhandWeapon ? p.OffhandWeapon.GetClassName() : 'none');
	}
}
