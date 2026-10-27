// TEST ONLY -- never shipped (test/build_test.sh adds it to the test pk3).
// Spawns a thing in front of the player at a set time and logs it; the firing itself goes
// through core's real input (netevent rsqgr_fire from the console script).
class RSQGRH_Harness : EventHandler
{
	Actor v;
	int spawned;
	override void WorldTick()
	{
		let pmo = players[consoleplayer].mo;
		if (!pmo) return;
		int at = CVar.FindCVar("rsgrh_at").GetInt();
		if (level.maptime == 5 && CVar.FindCVar("rsgrh_scan").GetInt())
		{
			for (int k = 0; k < 12; k++)
			{
				FLineTraceData d;
				pmo.LineTrace(k * 30, 4000, 0, TRF_THRUACTORS, 40, data: d);
				Console.Printf("H_SCAN map %s at (%.0f %.0f %.0f) angle %d -> %.0f", level.MapName, pmo.pos.x, pmo.pos.y, pmo.pos.z, k * 30, d.Distance);
			}
		}
		if (level.maptime == at && !spawned)
		{
			spawned = 1;
			String cls = CVar.FindCVar("rsgrh_cls").GetString();
			double d = CVar.FindCVar("rsgrh_dist").GetFloat();
			double side = CVar.FindCVar("rsgrh_side").GetFloat();
			double up = CVar.FindCVar("rsgrh_up").GetFloat();
			Vector3 sp = pmo.Vec3Angle(d, pmo.angle) + (cos(pmo.angle - 90), sin(pmo.angle - 90), 0) * side + (0, 0, up);
			v = Actor.Spawn(cls, sp, ALLOW_REPLACE);
			if (v)
			{
				v.angle = pmo.angle + 180;
				int hp = CVar.FindCVar("rsgrh_hp").GetInt();
				if (hp > 0) { v.health = hp; v.StartHealth = hp; }
			}
			Vector3 hp0 = RSQGR_Util.HandPos(pmo, 0);
			Console.Printf("H_SPAWN %s at (%.0f %.0f %.0f) dist %.0f player (%.0f %.0f %.0f) ang %.0f hand (%.1f %.1f %.1f) poseGood %d",
				v ? v.GetClassName() : 'null', sp.x, sp.y, sp.z, d, pmo.pos.x, pmo.pos.y, pmo.pos.z, pmo.angle,
				hp0.x, hp0.y, hp0.z, RSQGR_Util.PoseGood(pmo, 0));
		}
		if (v && CVar.FindCVar("rsgrh_log").GetInt() && level.maptime % 1 == 0 && level.maptime > at)
			Console.Printf("H_POS %d %s pos (%.1f %.1f %.1f) hp %d tics %d grav %.4f nograv %d", level.maptime, v.GetClassName(), v.pos.x, v.pos.y, v.pos.z, v.health, v.tics, v.Gravity, v.bNOGRAVITY);
	}
	override void NetworkProcess(ConsoleEvent e)
	{
		Console.Printf("H_NET %d %s %d %d %d", level.maptime, e.Name, e.Args[0], e.Args[1], e.Args[2]);
	}
}
