// TEST ONLY -- never shipped (test/build_test.sh adds it to the test pk3).
// Spawns a thing in front of the player at a set time and logs it; the firing itself goes
// through core's real input (netevent rsqgr_fire from the console script).
class RSQGRH_Harness : EventHandler
{
	Actor v;
	int spawned;
	override void WorldTick()
	{
		CutCheck();
		let pmo = players[consoleplayer].mo;
		if (!pmo) return;
		int at = CVar.FindCVar("rsgrh_at").GetInt();
		if (level.maptime == CVar.FindCVar("rsgrh_tpat").GetInt() && CVar.FindCVar("rsgrh_tp").GetInt())
		{
			pmo.SetOrigin((CVar.FindCVar("rsgrh_px").GetFloat(), CVar.FindCVar("rsgrh_py").GetFloat(), pmo.pos.z), false);
			pmo.SetZ(pmo.floorz);
			pmo.angle = CVar.FindCVar("rsgrh_pa").GetFloat();
			Console.Printf("H_TP player to (%.0f %.0f %.0f) angle %.0f", pmo.pos.x, pmo.pos.y, pmo.pos.z, pmo.angle);
		}
		if (level.maptime == 6 && CVar.FindCVar("rsgrh_sounds").GetInt())
		{
			static const Name whats[] = { 'fire', 'loop', 'swish', 'hitwall', 'hitflesh', 'retract', 'lash', 'crack' };
			for (int set = 0; set < 3; set++)
			{
				String line = "";
				for (int w = 0; w < whats.Size(); w++)
				{
					String n = RSQGR_Looks.SoundIn(set, whats[w]);
					Sound snd = n;
					line = line .. String.Format(" %s=%s(%d,%.2fs)", whats[w], n, int(snd), n == "" ? 0 : S_GetLength(snd));
				}
				Console.Printf("H_SND set %d:%s sprites open=%s closed=%s", set, line, RSQGR_Looks.SpriteIn(set, 'open'), RSQGR_Looks.SpriteIn(set, 'closed'));
			}
		}
		if (level.maptime == 5 && CVar.FindCVar("rsgrh_scan").GetInt())
		{
			for (int k = 0; k < 12; k++)
			{
				FLineTraceData d;
				pmo.LineTrace(k * 30, 4000, 0, TRF_THRUACTORS, 40, data: d);
				String fl = "";
				for (int q = 1; q <= 12; q++)
				{
					Vector2 pt = pmo.pos.xy + (cos(k * 30), sin(k * 30)) * q * 32;
					Sector sec = level.PointInSector(pt);
					fl = fl .. String.Format(" %.0f/%.0f", sec.floorplane.ZatPoint(pt), sec.ceilingplane.ZatPoint(pt));
				}
				Console.Printf("H_FLOORS %d:%s", k * 30, fl);
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
			v = Actor.Spawn(cls, sp, CVar.FindCVar("rsgrh_norep").GetInt() ? NO_REPLACE : ALLOW_REPLACE);
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
	// rsgrh_cut_tt: let the rope go (core's own LetGo, as a tap would) once the throw's path
	// clock reaches this many world tics -- the same point in the arc at any world speed.
	void CutCheck()
	{
		double cut = CVar.FindCVar("rsgrh_cut_tt").GetFloat();
		double kill = CVar.FindCVar("rsgrh_kill_tt").GetFloat();
		let fl = RSQGR_Flight.Get();
		if (kill > 0 && fl)
			for (int s = 0; s < RSQGR_Flight.NFLY; s++)
				if (fl.fph[s] == RSQGR_Flight.FP_PATH && fl.fa[s] && fl.fa[s].health > 0 && fl.ftt[s] >= kill)
				{
					Console.Printf("H_KILL at tt %.2f", fl.ftt[s]);
					fl.fa[s].DamageMobj(null, null, 100000, 'None');
				}
		if (cut <= 0) return;
		let core = RSQGR_Core.Get();
		if (!fl || !core) return;
		for (int s = 0; s < RSQGR_Flight.NFLY; s++)
		{
			if (fl.fph[s] != RSQGR_Flight.FP_PATH || !fl.fline[s] || fl.ftt[s] < cut) continue;
			for (int i = 0; i < RSQGR_Core.NHOOK; i++)
			{
				let h = core.hooks[i];
				if (h && h.victim == fl.fa[s]) { Console.Printf("H_CUT at tt %.2f", fl.ftt[s]); core.LetGo(h, true); }
			}
		}
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		Console.Printf("H_NET %d %s %d %d %d", level.maptime, e.Name, e.Args[0], e.Args[1], e.Args[2]);
	}
}
