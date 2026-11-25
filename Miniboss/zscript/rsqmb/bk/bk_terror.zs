// WHITE SPIDER OF TERROR (RS_WhiteSPFusion, Monsters/zscript/monsters/plus/RS_PlusWhiteSpiderFusion.zs;
// design/BIG_BOSS_REMAINING_C.md 29). From its own code only.
//   opener    Atk1 (:53; its half's Atk1 :477 in act 3). The hold is its first frame, TRIT A 2 (the hover's E-F charge
//             comes after it). A MISS lets Atk1 run as written: it rises, charges on E-F, then two volleys of
//             RS_WhiteSpiderPBolt.
//   points    TRIT E1 (93 x 44, offsets 46,40): image-left eye, image-right eye, brain cap. Acts 1-2 on the Fusion (Scale
//             1.5, Radius 56, Height 64): (+0.13, 0.70), (-0.16, 0.70), (-0.03, 0.87). Act 3 on its half (Scale 1,
//             Radius 38, Height 43): (+0.13, 0.70), (-0.16, 0.70), (-0.03, 0.86).
//   summons   act 1 none, no GUARD. Act 2 its Atk3 eggs, RS_WhiteSpidegg. Act 3 its twin half (below); no new monster.
//   acts      its 2500 line (Missile :36, Set2) from life 2 (RS_Act.zs). Act 3 its own split (Death :205-206: two
//             RS_WhiteSPFusion2): the body becomes one RS_WhiteSPFusion2 where it stands (the Black Knight's body swap,
//             bigacts.zs KnightBody, done here) and its twin lands beside it. With rsqmb_big_bodies 0, no swap.
//   splits    owner's call: its splits die with the fight. The twin and every split that comes out of a split's death
//             (RS_WhiteSPFusion3, and the RS_MiniSP1 a quarter bursts into) fight beside it (t.Keep, owner 2026-11-25:
//             not the GUARD wave) and KeepEnd kills them. Killing a split makes it split again (its own Death), so after the
//             fight a short sweep (RSQMB_BK_TerrorSweep) removes what those deaths, and the last body's, still spawn.
class RSQMB_BK_RS_WhiteSPFusion : RSQMB_BigKit
{
	override String Card() { return "WHITE SPIDER OF TERROR"; }
	override String Kind() { return "FUSION WHITE ARACHNOTRON"; }
	override String OpenerFrame(RSQMB_Tele t, int act) { return "E"; }   // design 29: the hover charge (E-F)
	override void Points(int act, Array<double> sx, Array<double> sy)
	{
		if (act >= 3) Pts(sx, sy, 0.13, 0.70, -0.16, 0.70, -0.03, 0.86);
		else Pts(sx, sy, 0.13, 0.70, -0.16, 0.70, -0.03, 0.87);
	}
	override String Opener(RSQMB_Tele t, int act) { return "Atk1"; }

	// a split of its family (by name: RSQ Monsters need not be loaded)
	static bool IsSplit(Actor a)
	{
		if (!a) return false;
		Name n = a.GetClassName();
		return n == 'RS_WhiteSPFusion2' || n == 'RS_WhiteSPFusion3' || n == 'RS_MiniSP1';
	}

	// a split whose death splits again (a half, a quarter): the ones watched
	static bool Splits(Actor a)
	{
		if (!a) return false;
		Name n = a.GetClassName();
		return n == 'RS_WhiteSPFusion' || n == 'RS_WhiteSPFusion2' || n == 'RS_WhiteSPFusion3';
	}

	override int Summon(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p, bool guard, int n)
	{
		if (t.act < 2 || !t.b.mb) return 0;
		if (t.act == 2)
		{
			String en = "RS_WhiteSpidegg";
			Class<Actor> c = en;
			if (!c) return 0;
			int got = 0;
			for (int i = 0; i < n; i++) if (t.SummonAt(h, c, p, (0, 0), 96, 256)) got++;
			return got;
		}
		// act 3: its twin and its splits fight beside it (t.Keep), not as the GUARD wave; nothing new
		return 0;
	}

	// ---- act 3: its split ------------------------------------------------------------------------------------------------
	override void OnAct(RSQMB_Tele t, RSQMB_Handler h, int act)
	{
		if (act < 3 || RSQMB_Tele.CI('rsqmb_big_bodies', 1) == 0) return;
		let old = t.b.mb;
		if (!old || old.GetClassName() != 'RS_WhiteSPFusion') return;
		String cn = "RS_WhiteSPFusion2";
		Class<Actor> c = cn;
		if (!c) return;
		// the body: one half where it stands (KnightBody's swap)
		if (h) h.swapNoRoll = c;
		let nb = Actor.Spawn(c, old.pos, NO_REPLACE);
		if (h) h.swapNoRoll = null;
		if (!nb) return;
		nb.angle = old.angle;
		nb.target = old.target;
		int hp = old.health, mx = t.b.maxHP;
		t.ClearWeakPoints(true);
		t.Unpin(old);
		t.b.Rebody(-1, nb, h);
		nb.health = max(1, hp);
		t.b.maxHP = mx;
		if (nb.SeeState) nb.SetState(nb.SeeState);
		Vector3 at = old.pos;
		double ang = old.angle;
		Actor.Spawn("TeleportFog", at, ALLOW_REPLACE);
		old.ClearCounters();
		old.Destroy();
		t.ActMark();                 // the new body carries its act
		// its twin beside it (its Death spawns two), in the wave
		let p = t.Victim();
		Vector2 rt = (sin(ang), -cos(ang));
		double d = nb.radius * 2.5;
		Actor tw = t.SummonAt(h, c, p, rt * d, 0, 0);
		if (!tw) tw = t.SummonAt(h, c, p, rt * -d, 0, 0);
		if (!tw) tw = t.SummonAt(h, c, p, (0, 0), 64, 192);
		if (tw) { t.Keep(tw); Track(tw); }     // beside it, not the GUARD wave (owner 2026-11-25)
		if (h && h.debug) Console.Printf("RSQMB act t%d: the Fusion splits: its body is %s (%d health kept), its twin %s", level.maptime, c.GetClassName(), hp,
			tw ? "landed" : "found no spot");
	}

	// ---- its splits join the wave ----------------------------------------------------------------------------------------
	// Each tic: every split in the wave is watched; one gone (its Death ends in Stop or A_Burst the tic it spawns its own
	// splits), every split no older than 2 tics within 128 of where it last stood joins the wave too.
	Array<Actor> wA;
	Array<double> wX, wY, wZ;

	void Track(Actor a)
	{
		if (!a || wA.Find(a) < wA.Size()) return;
		wA.Push(a); wX.Push(a.pos.x); wY.Push(a.pos.y); wZ.Push(a.pos.z);
	}

	override void Watch(RSQMB_Tele t, RSQMB_Handler h, int now)
	{
		for (int i = wA.Size() - 1; i >= 0; i--)
		{
			let a = wA[i];
			if (a) { wX[i] = a.pos.x; wY[i] = a.pos.y; wZ[i] = a.pos.z; continue; }
			Array<Actor> fresh;
			RSQMB_BK_TerrorSweep.Fresh((wX[i], wY[i], wZ[i]), fresh);
			let p = t.Victim();
			for (int k = 0; k < fresh.Size(); k++)
			{
				let s = fresh[k];
				if (s == t.b.mb) continue;
				if (p) s.target = p;
				t.Keep(s);
				if (h && h.debug) Console.Printf("RSQMB t%d: its split %s fights beside it", now, s.GetClassName());
			}
			wA.Delete(i); wX.Delete(i); wY.Delete(i); wZ.Delete(i);
		}
		for (int i = 0; i < t.keepers.Size(); i++) if (Splits(t.keepers[i])) Track(t.keepers[i]);
	}

	// the fight over: SummonsEnd has killed the wave; what their deaths and the last body's still spawn is swept
	override void OnEnd(RSQMB_Tele t, RSQMB_Handler h)
	{
		let sw = RSQMB_BK_TerrorSweep(new("RSQMB_BK_TerrorSweep"));
		if (!sw) return;
		sw.endAt = level.maptime + 6 * TICRATE;
		for (int i = 0; i < wA.Size(); i++) sw.Add(wA[i]);
		let mb = t.b ? t.b.mb : null;
		if (Splits(mb)) sw.Add(mb);
		wA.Clear(); wX.Clear(); wY.Clear(); wZ.Clear();
		if (h && h.debug) Console.Printf("RSQMB t%d: the Fusion's fight over: %d split bodies watched for their own splits", level.maptime, sw.wA.Size());
	}
}

// After its fight: each watched body gone, the splits its death has just spawned (no older than 2 tics, within 128) are
// removed before they act. Ends when every watched body is gone, or after 6 s.
class RSQMB_BK_TerrorSweep : Thinker
{
	Array<Actor> wA;
	Array<double> wX, wY, wZ;
	int endAt;

	void Add(Actor a)
	{
		if (!a || wA.Find(a) < wA.Size()) return;
		wA.Push(a); wX.Push(a.pos.x); wY.Push(a.pos.y); wZ.Push(a.pos.z);
	}

	// its splits fresh near a spot (no older than 2 tics, within 128)
	static void Fresh(Vector3 at, Array<Actor> res)
	{
		res.Clear();
		let it = BlockThingsIterator.CreateFromPos(at.x, at.y, at.z, 128, 128, false);
		while (it.Next())
		{
			let s = it.thing;
			if (!s || s.health <= 0 || s.GetAge() > 2 || !RSQMB_BK_RS_WhiteSPFusion.IsSplit(s)) continue;
			if ((s.pos.xy - at.xy).Length() > 128) continue;
			res.Push(s);
		}
	}

	override void Tick()
	{
		if (level.isFrozen()) return;
		for (int i = wA.Size() - 1; i >= 0; i--)
		{
			let a = wA[i];
			if (a) { wX[i] = a.pos.x; wY[i] = a.pos.y; wZ[i] = a.pos.z; continue; }
			Array<Actor> fresh;
			Fresh((wX[i], wY[i], wZ[i]), fresh);
			for (int k = 0; k < fresh.Size(); k++) { fresh[k].ClearCounters(); fresh[k].Destroy(); }
			wA.Delete(i); wX.Delete(i); wY.Delete(i); wZ.Delete(i);
		}
		if (wA.Size() == 0 || level.maptime >= endAt) Destroy();
	}
}

// its halves and quarters after the act-3 swap: the Boss bar keeps its name
class RSQMB_BK_RS_WhiteSPFusion2 : RSQMB_BigKit
{
	override String Card() { return "WHITE SPIDER OF TERROR"; }
	override String Kind() { return "FUSION WHITE ARACHNOTRON"; }
}
class RSQMB_BK_RS_WhiteSPFusion3 : RSQMB_BK_RS_WhiteSPFusion2 {}
