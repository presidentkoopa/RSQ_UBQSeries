// RSQ PLAYLOG -- the series' plan, step 4 (owner 2026-11-24): real play from the headset, written down, so tuning comes
// from how you actually play and not from guesses on a test rig that has no hands. It changes nothing in the game.
//
// With Record Play Log on (rsqpl_on), every line it writes starts "RSQLOG" and goes to the console; the engine's own
// logfile command (the menu's Start Log File rows) copies the console into a text file you can send back.
//
//   MAP     a map started: its lump, title, monsters, the skill
//   END     a map ended: seconds, kills of total, deaths in it
//   SWING   a hand's swing: its peak m/s (hand against the body, the same reading every throw in the series uses),
//           how much of it went ahead / up, what that hand held, and whether a throw would read it (ONE THROW 1.5 m/s)
//   KILL    you killed: the monster, its health, with what (weapon or the thing that hit it), how far, the means
//   HURT    you were hurt: by what, how much, the health left
//   DIED    you died: by what
//   WRIST   (2026-11-24, the Start Fight Card's pulse check) while the off hand is up near your face, every 7 tics and on
//           every change: RSQ Accessibility's watch check and pulse check for that hand (0 not, 1 entering, 2 held), and
//           for each, why its pose is not met (too far, too high, tilted, not twisted enough, moving), with the numbers
//   FPS     each second: the draws (in VR the engine may draw once per eye, so read it as a count, not frames per
//           second) and the longest wait between two draws in ms (the renderer's real clock)
//   HITCH   one wait between draws of 50 ms or more: how long, and the map time
// Code only, not run in the headset.

class RSQPL_Log : EventHandler
{
	const SWING_START = 1.0;     // m/s: a hand faster than this has begun a swing
	const SWING_END = 0.6;       // m/s: and the swing is over once it drops below this
	const THROW_MPS = 1.5;       // ONE THROW's MIN_MPS (tools/core/fling_template.zs): would a throw read this swing
	const HITCH_MS = 50;

	// the swing being watched, per hand (0 main, 1 off)
	Vector3 lastOff[2];
	bool haveLast[2];
	bool inSwing[2];
	double peak[2];
	Vector3 peakDir[2];
	int swingFrom[2];
	int slowTics[2];   // tics in a row under SWING_END: a swing ends after two (one still tic between two frames is not the end)

	int mapStart, deaths;
	int wristLast, wristAt;   // the last WRIST states (watch * 10 + pulse) and when it was written

	// frame rate (ui: the renderer's own clock)
	ui int fFrames, fSecondAt, fLastMs, fWorst, fSum, fHitches;

	static clearscope bool On() { let c = CVar.FindCVar("rsqpl_on"); return c && c.GetBool(); }

	static double Vu()
	{
		let c = CVar.FindCVar("vr_vunits_per_meter");
		double v = c ? c.GetFloat() : 34;
		return v > 0 ? v : 34;
	}

	override void WorldLoaded(WorldEvent e)
	{
		mapStart = level.maptime;
		deaths = 0;
		for (int h = 0; h < 2; h++) { haveLast[h] = false; inSwing[h] = false; }
		if (!On() || e.IsSaveGame) return;
		Console.Printf("RSQLOG t%d MAP %s \"%s\" monsters %d skill %d", level.maptime, level.MapName, level.LevelName, level.total_monsters, CVar.FindCVar("skill") ? CVar.FindCVar("skill").GetInt() : -1);
	}

	override void WorldUnloaded(WorldEvent e)
	{
		if (!On()) return;
		Console.Printf("RSQLOG t%d END %s %.1f s, kills %d of %d, deaths %d", level.maptime, level.MapName,
			(level.maptime - mapStart) / double(TICRATE), level.killed_monsters, level.total_monsters, deaths);
	}

	override void WorldTick()
	{
		if (!On()) return;
		let pmo = players[consoleplayer].mo;
		if (!pmo || !pmo.player || pmo.health <= 0) return;
		if (!pmo.OverrideAttackPosDir || pmo.AttackPos == pmo.OffhandPos) return;   // no VR hands
		Wrist(pmo);
		double vu = Vu();
		Vector3 body = RSQPL_HandSync.Body(pmo);
		for (int h = 0; h < 2; h++)
		{
			Vector3 hp = RSQPL_HandSync.Fix(pmo, h == 0 ? pmo.AttackPos : pmo.OffhandPos, h);
			Vector3 off = hp - body;
			if (!haveLast[h]) { lastOff[h] = off; haveLast[h] = true; continue; }
			Vector3 d = off - lastOff[h];
			lastOff[h] = off;
			double mps = d.Length() * TICRATE / vu;
			if (mps > 30) continue;   // a teleport or a frame gap, not a hand
			if (!inSwing[h])
			{
				if (mps >= SWING_START) { inSwing[h] = true; peak[h] = mps; peakDir[h] = d; swingFrom[h] = level.maptime; slowTics[h] = 0; }
				continue;
			}
			if (mps > peak[h]) { peak[h] = mps; peakDir[h] = d; }
			slowTics[h] = mps < SWING_END ? slowTics[h] + 1 : 0;
			if (slowTics[h] >= 2)
			{
				inSwing[h] = false;
				Vector3 u = peakDir[h].Length() > 0 ? peakDir[h].Unit() : (0, 0, 0);
				double fwd = u.xy dot (cos(pmo.Angle), sin(pmo.Angle));
				Weapon w = h == 0 ? pmo.player.ReadyWeapon : pmo.player.OffhandWeapon;
				Console.Printf("RSQLOG t%d SWING %s %.2f m/s over %d tics, ahead %.2f up %.2f, holding %s%s", level.maptime,
					h == 0 ? "main" : "off", peak[h], level.maptime - swingFrom[h], fwd, u.z, w ? w.GetClassName() : 'nothing',
					peak[h] >= THROW_MPS ? ", throw-fast" : "");
			}
		}
	}

	void Wrist(PlayerPawn pmo)
	{
		Vector3 eye = (pmo.pos.xy, pmo.player.viewz);
		Vector3 hp = RSQPL_HandSync.Fix(pmo, pmo.OffhandPos, 1) - eye;
		hp.z *= level.pixelstretch;
		if (hp.Length() > 0.8 * Vu()) { wristLast = -1; return; }
		let it = ServiceIterator.Find("RSQG_Service");
		Service sv;
		while (sv = it.Next())
		{
			if (sv.GetClassName() != 'RSQG_Service') continue;
			int w = sv.GetInt("inspect", "", 1, 0, pmo), p = sv.GetInt("pulse", "", 1, 0, pmo);
			int st = w * 10 + p;
			if (st == wristLast && level.maptime - wristAt < 7) return;
			wristLast = st; wristAt = level.maptime;
			Console.Printf("RSQLOG t%d WRIST watch %d pulse %d | pulse: %s | watch: %s", level.maptime, w, p,
				sv.GetString("pose.why", "pulse", 1, 0, pmo), sv.GetString("pose.why", "watch", 1, 0, pmo));
			return;
		}
	}

	override void WorldThingDied(WorldEvent e)
	{
		if (!On() || !e.Thing) return;
		let t = e.Thing;
		if (t.player && t.player == players[consoleplayer])
		{
			deaths++;
			Console.Printf("RSQLOG t%d DIED by %s (%s)", level.maptime, e.Inflictor ? e.Inflictor.GetClassName() : 'nothing',
				t.target ? t.target.GetClassName() : 'nothing');
			return;
		}
		if (!t.bISMONSTER) return;
		let pmo = players[consoleplayer].mo;
		if (!pmo || t.target != pmo) return;   // a monster's killer is its target when the kill was yours
		string with = e.Inflictor && e.Inflictor != pmo ? e.Inflictor.GetClassName() : (pmo.player.ReadyWeapon ? pmo.player.ReadyWeapon.GetClassName() : 'nothing');
		string means = t.DamageTypeReceived;
		if (means == "" || means ~== "None") means = "normal";
		Console.Printf("RSQLOG t%d KILL %s (%d health) with %s at %.1f m, %s", level.maptime, t.GetClassName(), t.SpawnHealth(),
			with, pmo.Distance3D(t) / Vu(), means);
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		if (!On() || !e.Thing || !e.Thing.player || e.Thing.player != players[consoleplayer]) return;
		if (e.Damage <= 0) return;
		Console.Printf("RSQLOG t%d HURT %d by %s (%s), health %d", level.maptime, e.Damage,
			e.DamageSource ? e.DamageSource.GetClassName() : 'nothing', e.DamageType, e.Thing.health);
	}

	override void RenderOverlay(RenderEvent e)
	{
		if (!On()) return;
		int now = MSTime();
		if (fSecondAt == 0) { fSecondAt = now; fLastMs = now; return; }
		int ms = now - fLastMs;
		fLastMs = now;
		fFrames++;
		fSum += ms;
		if (ms > fWorst) fWorst = ms;
		if (ms >= HITCH_MS && ++fHitches <= 3) Console.Printf("RSQLOG t%d HITCH %d ms", level.maptime, ms);   // at most 3 a second; FPS says the worst
		if (now - fSecondAt >= 1000)
		{
			Console.Printf("RSQLOG t%d FPS %d draws, longest wait %d ms", level.maptime, fFrames, fWorst);
			fFrames = 0; fSum = 0; fWorst = 0; fHitches = 0; fSecondAt = now;
		}
	}
}
