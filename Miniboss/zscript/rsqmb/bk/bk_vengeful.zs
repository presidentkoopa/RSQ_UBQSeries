// THE VENGEFUL SOUL (RS_WhiteLSoulEX, lostsoul/RS_LostSoul.zs:1893; design/BIG_BOSS_REMAINING_A.md 20). From its own code only.
//   opener    Transformers: its stretch (ETHS F 6 bright); a MISS lets Transformers run (HK / REV / CACO, from act 2
//             RollOut's Baron / Vile / Mancu)
//   points    ETHS F1: skull (0, 0.36), left flame (-0.78, 0.6), right flame (+0.67, 0.6)
//   summons   its own two skulls (RS_SkullWSoulEX1 / 2) breaking off: on every opener its Missile's A1 / A2 / A3 (one of
//             them, A_RadiusGive RS_WhiteSoulAdsOff2 / 3 / 4 within 700), so its orbiting skulls do their A2 / A3 / A4
//             as written (shootable, they hatch if left). GUARD: its skulls are the wave; fewer than two orbiting, its
//             AddOns spawns (both skulls, 32,32,12 and -32,-32,12, SXF_NOCHECKPOSITION | SXF_SETMASTER), then released
//   acts      its RollOut line (< 6000) from life 2 (RS_Act.zs hook in Transformers); acts 2 and 3
class RSQMB_BK_RS_WhiteLSoulEX : RSQMB_BigKit
{
	override String Card() { return "THE VENGEFUL SOUL"; }
	override String Kind() { return "WHITE LOST SOUL"; }
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, 0, 0.36, -0.78, 0.6, 0.67, 0.6); }
	override String Opener(RSQMB_Tele t, int act) { return "Transformers"; }

	// its skulls still orbiting it (no AdsOff token yet)
	static void Orbiting(Actor mb, Array<Actor> res)
	{
		res.Clear();
		String sn = "RS_SkullWSoulEX1";        // EX2 is its subclass; strings: resolved at run time
		Class<Actor> c = sn;
		if (!c || !mb) return;
		static const String TOK[] = { "RS_WhiteSoulAdsOff", "RS_WhiteSoulAdsOff2", "RS_WhiteSoulAdsOff3", "RS_WhiteSoulAdsOff4" };
		let it = ThinkerIterator.Create(c);
		Actor a;
		while (a = Actor(it.Next()))
		{
			if (a.master != mb || a.health <= 0) continue;
			bool off = false;
			for (int i = 0; i < TOK.Size() && !off; i++) { Class<Inventory> tc = TOK[i]; if (tc && a.CountInv(tc) > 0) off = true; }
			if (!off) res.Push(a);
		}
	}

	override int Summon(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p, bool guard, int n)
	{
		let mb = t.b ? t.b.mb : null;
		if (!mb) return 0;
		Array<Actor> sk;
		Orbiting(mb, sk);
		// GUARD: its AddOns, when two are not orbiting
		if (guard && sk.Size() < 2)
		{
			String n1 = "RS_SkullWSoulEX1", n2 = "RS_SkullWSoulEX2";
			Class<Actor> c1 = n1, c2 = n2;
			if (c1) mb.A_SpawnItemEx(c1, 32, 32, 12, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_SETMASTER);
			if (c2) mb.A_SpawnItemEx(c2, -32, -32, 12, 0, 0, 0, 0, SXF_NOCHECKPOSITION | SXF_SETMASTER);
			Orbiting(mb, sk);
		}
		if (sk.Size() == 0) return 0;
		// its Missile's A1 / A2 / A3: one of the three, within 700
		static const String GIVE[] = { "RS_WhiteSoulAdsOff2", "RS_WhiteSoulAdsOff3", "RS_WhiteSoulAdsOff4" };
		Class<Inventory> gc = GIVE[random[rsqmbsum](0, 2)];
		if (!gc) return 0;
		mb.A_RadiusGive(gc, 700, RGF_MONSTERS);
		int got = 0;
		for (int i = 0; i < sk.Size(); i++)
		{
			let a = sk[i];
			if (!a || a.CountInv(gc) == 0) continue;     // out of its 700
			if (p) a.target = p;
			t.AddSum(a);
			got++;
		}
		return got;
	}

	// A HATCHED MONSTER JOINS THE WAVE (design 20): a released skull ends in its hatch (Stop) and spawns its monster
	// where it stood. Each tic: its skulls' places kept; a skull gone, a monster no older than 2 tics within 96 of it
	// joins the wave.
	Array<Actor> skA;
	Array<double> skX, skY, skZ;
	override void Watch(RSQMB_Tele t, RSQMB_Handler h, int now)
	{
		for (int i = skA.Size() - 1; i >= 0; i--)
		{
			if (skA[i] && skA[i].health > 0) { skX[i] = skA[i].pos.x; skY[i] = skA[i].pos.y; skZ[i] = skA[i].pos.z; continue; }
			Vector3 at = (skX[i], skY[i], skZ[i]);
			let it = ThinkerIterator.Create("Actor");
			Actor a;
			while (a = Actor(it.Next()))
			{
				if (!a.bISMONSTER || a.health <= 0 || a.GetAge() > 2 || a == t.b.mb) continue;
				if ((a.pos - at).Length() > 96) continue;
				let p = t.Victim();
				if (p) a.target = p;
				t.AddSum(a);
				if (h && h.debug) Console.Printf("RSQMB GUARD t%d: a skull hatched %s: it joins the wave", now, a.GetClassName());
			}
			skA.Delete(i); skX.Delete(i); skY.Delete(i); skZ.Delete(i);
		}
		for (int i = 0; i < t.sums.Size(); i++)
		{
			let a = t.sums[i];
			if (!a || a.health <= 0 || skA.Find(a) < skA.Size()) continue;
			String n = a.GetClassName();
			if (n.IndexOf("RS_SkullWSoulEX") != 0) continue;
			skA.Push(a); skX.Push(a.pos.x); skY.Push(a.pos.y); skZ.Push(a.pos.z);
		}
	}
}
