// ============================================================================
// RSQ_Miniboss -- BOSSES FROM THE WHOLE ROSTER, MIXED ESCORTS (owner 2026-11-25: "variety in types on monsters spawning
// in ... the entire CH roster is full of fun higher tier monsters"; thralls: "Mixed families: 2-3 families with different
// jobs, e.g. a Revenant Boss with imps and a Pain Elemental").
//
// Only with RSQ Monsters loaded (RSQMN_RosterService, by name: its "set.class" gives a family's ColorfulHell class at a
// colour). Without it, or for a Big Boss, the old pick (the map's own roster, the Boss's family as thralls) as before.
//
//   THE BOSS     a pool of the map's own types (each its own entry, weight x3) and every other Doom family that is not on the
//                map (weight x1; the map's x3 is a family's, shared by its types), as RSQ Monsters' ColorfulHell class at the Boss's colour (world tier + 2). Left out, as
//                before: anything +BOSS (Cyberdemon, Spider Mastermind: the scan never took them), and, from outside the map,
//                the three zombie families (their attacks are hitscan: none are added where the map has none).
//                RANK LEANS: the pool in strength order (each family's own Doom health), each entry weighted by a bell round
//                the centre Rank gives (0.30 at Rank 0 .. 0.95 at 100, as before; without Rank the fight's tier 0..4 gives
//                0.5 .. 1.0), with a floor so any type can still come. The Archvile from outside x0.5. NO REPEAT: the family
//                (or the type) of the last Boss you fought weighs 0 (unless nothing else is left); remembered on the player
//                (RSQMB_BossMemo), so it holds across maps. Up to three picks are drawn; a pick with no room to land (a
//                flyer under a low ceiling) gives way to the next.
//   THE ESCORT   the same number of thralls as before (Thralls, ThrallWant), from 2 families (3 with four thralls or more),
//                each with a different job: RUSH (Demon, Spectre, Lost Soul), SHOOT (Imp, Revenant, Arachnotron; the
//                zombie families only when the map has them), FLY (Cacodemon, Pain Elemental), BRUTE (Hell Knight, Baron,
//                Mancubus). Never the Boss's own family (while others are left), never an Archvile, Cyberdemon or Spider
//                Mastermind. A family stronger than max(400, the Boss's health x 1.5) stays out. The map's own families
//                weigh x2. Pain Elemental, Mancubus and Baron at most one each in an escort. Each thrall is its family's
//                ColorfulHell class at the thralls' colour (world tier + 1; fight.zs ApplyFrom then sets it as before).
// Everything after the pick (thrall health, Champions / LegenDoom dressing, the ring, the beams, the bind) is unchanged.
// ============================================================================

// the last Boss you fought (its family, or its type when it has none): travels with the player from map to map
class RSQMB_BossMemo : Inventory
{
	String lastKey;
	Default
	{
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		Inventory.MaxAmount 1;
	}
}

// the tables: each family by its RSQ Monsters number
class RSQMB_MixTab
{
	// RS_RosterHandler.FamilyId's order (RSQ Monsters), its vanilla classes, their Doom health, their jobs
	static String Fam(int f)
	{
		static const String T_FAM[] = { "ZombieMan", "ShotgunGuy", "ChaingunGuy", "DoomImp", "Demon", "Spectre", "Cacodemon",
			"LostSoul", "PainElemental", "HellKnight", "BaronOfHell", "Revenant", "Fatso", "Arachnotron", "Archvile", "CyberDemon",
			"SpiderMastermind" };
		return f >= 0 && f < 17 ? T_FAM[f] : "no family";
	}
	static int Hp(int f)
	{
		static const int T_HP[] = { 20, 30, 70, 60, 150, 150, 400, 100, 400, 500, 1000, 300, 600, 500, 700, 4000, 3000 };
		return f >= 0 && f < 17 ? T_HP[f] : 100;
	}
	static int Role(int f)
	{
		static const int T_ROLE[] = { 1, 1, 1, 1, 0, 0, 2, 0, 2, 3, 3, 1, 3, 1, -1, -1, -1 };
		return f >= 0 && f < 17 ? T_ROLE[f] : -1;
	}
	static String Job(int r)
	{
		static const String T_JOBS[] = { "rush", "shoot", "fly", "brute" };
		return r >= 0 && r < 4 ? T_JOBS[r] : "-";
	}
}

extend class RSQMB_Handler
{
	const MIX_NFAM = 17;
	const ROLE_NONE = -1;
	const ROLE_RUSH = 0;
	const ROLE_SHOOT = 1;
	const ROLE_FLY = 2;
	const ROLE_BRUTE = 3;
	const MIX_SIGMA = 0.22;       // the Rank lean's bell (in pool positions 0..1)
	const MIX_FLOOR = 0.08;       // so any type can still come
	const MIX_MAPW = 3.0;         // a Boss of the map's own types
	const MIX_THR_MAPW = 2.0;     // a thrall family on the map

	static String RoleName(int r) { return RSQMB_MixTab.Job(r); }
	static bool HitscanFam(int f) { return f >= 0 && f <= 2; }
	static int MaxOfFam(int f) { return (f == 8 || f == 10 || f == 12) ? 1 : 99; }   // PE, Baron, Mancubus

	transient Array<String> mixCommon;   // each family's Common ColorfulHell class (RSQ Monsters), for FamOf
	transient bool mixCommonDone;
	Array<int> mixFamT, mixRoleT;        // the escort just planned: each thrall's family and job (debug)

	bool MixOn(bool big) { return !big && MnService() != null && rosterCls.Size() > 0; }

	// a type's Doom family (0..16), -1 none: up its parents and what each replaces; else, RSQ Monsters loaded, the family
	// whose Common ColorfulHell class it shares (a Black or White body that is no Doom class's child)
	int FamOf(String cls)
	{
		class<Actor> c = cls;
		if (!c) return -1;
		for (class<Actor> k = c; k; k = (class<Actor>)(k.GetParentClass()))
		{
			String kn = k.GetClassName();
			for (int f = 0; f < MIX_NFAM; f++) if (kn ~== RSQMB_MixTab.Fam(f)) return f;
			class<Actor> r = Actor.GetReplacee(k);
			if (r && r != k)
			{
				String rn = r.GetClassName();
				for (int f = 0; f < MIX_NFAM; f++) if (rn ~== RSQMB_MixTab.Fam(f)) return f;
			}
			if (kn ~== "Actor") break;
		}
		let s = MnService();
		if (!s) return -1;
		if (!mixCommonDone)
		{
			mixCommonDone = true;
			mixCommon.Clear();
			for (int f = 0; f < MIX_NFAM; f++) mixCommon.Push(s.GetString("set.class", RSQMB_MixTab.Fam(f), 3, 1));
		}
		String mine = s.GetString("set.class", cls, 3, 1);
		if (mine == "") return -1;
		for (int f = 0; f < MIX_NFAM && f < mixCommon.Size(); f++) if (mixCommon[f] != "" && mixCommon[f] ~== mine) return f;
		return -1;
	}

	// a type's job from what it can do (a map type with no Doom family)
	static int RoleOfType(class<Actor> c)
	{
		if (!c) return ROLE_NONE;
		let d = GetDefaultByType(c);
		if (d.bFLOAT) return ROLE_FLY;
		if (d.MeleeState && !d.MissileState) return ROLE_RUSH;
		if (d.health >= 500) return ROLE_BRUTE;
		return ROLE_SHOOT;
	}

	String MixKey(String cls) { int f = FamOf(cls); return f >= 0 ? RSQMB_MixTab.Fam(f) : cls; }
	static RSQMB_BossMemo MemoOf(Actor p, bool make = false)
	{
		if (!p) return null;
		let m = RSQMB_BossMemo(p.FindInventory("RSQMB_BossMemo"));
		if (!m && make) m = RSQMB_BossMemo(p.GiveInventoryType("RSQMB_BossMemo"));
		return m;
	}
	void MixRemember(PlayerPawn p, String cls)
	{
		let m = MemoOf(p, true);
		if (m) m.lastKey = MixKey(cls);
	}

	// ---- THE BOSS: up to three picks, in the order to try them ------------------------------------------------------------
	void MixBosses(PlayerPawn p, int tier, Array<String> cand)
	{
		cand.Clear();
		let s = MnService();
		if (!s) return;
		int mbT = min(TOP_TIER, WorldTierNow() + 2);
		Array<String> pc; Array<int> pf, ph; Array<bool> pm;
		bool onMap[MIX_NFAM];
		for (int f = 0; f < MIX_NFAM; f++) onMap[f] = false;
		String mapFams = "";
		for (int i = 0; i < rosterCls.Size(); i++)
		{
			int f = FamOf(rosterCls[i]);
			if (f >= 0 && !onMap[f]) { onMap[f] = true; mapFams = mapFams .. (mapFams == "" ? "" : " ") .. RSQMB_MixTab.Fam(f); }
			if (f < 0) mapFams = mapFams .. (mapFams == "" ? "" : " ") .. rosterCls[i] .. "(no family)";
			pc.Push(rosterCls[i]); pf.Push(f); ph.Push(f >= 0 ? RSQMB_MixTab.Hp(f) : rosterHP[i]); pm.Push(true);
		}
		for (int f = 0; f < MIX_NFAM; f++)
		{
			if (onMap[f] || f >= 15 || HitscanFam(f)) continue;
			String cn = s.GetString("set.class", RSQMB_MixTab.Fam(f), 3, mbT);
			class<Actor> cc = cn;
			if (cn == "" || !cc || GetDefaultByType(cc).bBOSS) continue;
			pc.Push(cn); pf.Push(f); ph.Push(RSQMB_MixTab.Hp(f)); pm.Push(false);
		}
		int n = pc.Size();
		if (n == 0) return;
		// strength order (insertion, stable)
		Array<int> ord;
		for (int i = 0; i < n; i++)
		{
			int at = ord.Size();
			while (at > 0 && ph[ord[at - 1]] > ph[i]) at--;
			ord.Insert(at, i);
		}
		double c = RankOn() && RankNow() >= 0 ? 0.3 + 0.65 * RankFrac() : clamp(0.5 + 0.125 * tier, 0.0, 1.0);
		let memo = MemoOf(p);
		String last = memo ? memo.lastKey : "";
		Array<double> w;
		for (int i = 0; i < n; i++) w.Push(0);
		double tot = 0;
		for (int r = 0; r < n; r++)
		{
			int i = ord[r];
			double pos = n > 1 ? r / double(n - 1) : 0.5;
			double d = pos - c;
			// the map's own: x3 a FAMILY, shared by its types (XMVE puts four kinds of zombie on MAP01: not 12 to 1)
			int same = 1;
			if (pm[i]) { same = 0; for (int q = 0; q < n; q++) if (pm[q] && (pf[i] >= 0 ? pf[q] == pf[i] : q == i)) same++; }
			double wi = (pm[i] ? MIX_MAPW / max(1, same) : 1.0) * (MIX_FLOOR + exp(-(d * d) / (2 * MIX_SIGMA * MIX_SIGMA)));
			if (!pm[i] && pf[i] == 14) wi *= 0.5;
			String key = pf[i] >= 0 ? RSQMB_MixTab.Fam(pf[i]) : pc[i];
			if (last != "" && key ~== last) wi = 0;
			w[i] = wi; tot += wi;
		}
		if (tot <= 0) for (int i = 0; i < n; i++) { w[i] = 1; tot += 1; }
		if (debug)
		{
			String l = "";
			for (int r = 0; r < n; r++) { int i = ord[r]; l = l .. String.Format("%s%s%s %.2f", r ? ", " : "", pc[i], pm[i] ? "*" : "", w[i] / tot); }
			Console.Printf("RSQMB Boss pick: pool %d (%d the map's own, * below), the map's families [%s], centre %.2f (%s), last Boss %s; weights [%s]",
				n, rosterCls.Size(), mapFams, c, RankOn() && RankNow() >= 0 ? String.Format("Rank %.1f", RankNow()) : String.Format("tier %d", tier),
				last == "" ? "none" : last, l);
		}
		// draw up to three without putting back
		Array<double> ww; ww.Copy(w);
		for (int k = 0; k < 3 && k < n; k++)
		{
			double t = 0;
			for (int i = 0; i < n; i++) t += ww[i];
			if (t <= 0) break;
			double roll = frandom[rsqmbbf](0, t);
			int pick = -1;
			for (int i = 0; i < n; i++) { if (ww[i] <= 0) continue; pick = i; roll -= ww[i]; if (roll <= 0) break; }
			if (pick < 0) break;
			cand.Push(pc[pick]);
			ww[pick] = 0;
			if (debug && k == 0) Console.Printf("RSQMB Boss pick: %s (%s, %s, chance %.0f%%)", pc[pick], pf[pick] >= 0 ? RSQMB_MixTab.Fam(pf[pick]) : "no family",
				pm[pick] ? "the map's own" : "from outside the map", 100.0 * w[pick] / tot);
		}
	}

	// ---- THE ESCORT: want thralls from 2-3 families with different jobs ------------------------------------------------------
	void MixThralls(String bossCls, int want, int tier, Array<String> tc)
	{
		tc.Clear(); mixFamT.Clear(); mixRoleT.Clear();
		let s = MnService();
		if (!s || want <= 0) return;
		int thT = min(TOP_TIER, WorldTierNow() + 1);
		int bf = FamOf(bossCls);
		class<Actor> bcc = bossCls;
		int bhp = bf >= 0 ? RSQMB_MixTab.Hp(bf) : (bcc ? GetDefaultByType(bcc).health : 100);
		double cap = max(400.0, bhp * 1.5);
		// the kinds that may come: the map's own types (by family once), then the families not on the map
		Array<String> kc; Array<int> kf, kr; Array<double> kw;
		bool seen[MIX_NFAM];
		for (int f = 0; f < MIX_NFAM; f++) seen[f] = false;
		for (int i = 0; i < rosterCls.Size(); i++)
		{
			int f = FamOf(rosterCls[i]);
			class<Actor> c = rosterCls[i];
			if (!c) continue;
			if (f >= 0)
			{
				if (seen[f]) continue;
				seen[f] = true;
				if (f == bf || f >= 14 || RSQMB_MixTab.Hp(f) > cap) continue;
				kc.Push(rosterCls[i]); kf.Push(f); kr.Push(RSQMB_MixTab.Role(f)); kw.Push(MIX_THR_MAPW);
			}
			else
			{
				if (rosterCls[i] ~== bossCls || rosterHP[i] > cap) continue;
				kc.Push(rosterCls[i]); kf.Push(-1); kr.Push(RoleOfType(c)); kw.Push(MIX_THR_MAPW);
			}
		}
		for (int f = 0; f < 14; f++)
		{
			if (seen[f] || f == bf || HitscanFam(f) || RSQMB_MixTab.Hp(f) > cap) continue;
			String cn = s.GetString("set.class", RSQMB_MixTab.Fam(f), 3, thT);
			class<Actor> cc = cn;
			if (cn == "" || !cc) continue;
			kc.Push(cn); kf.Push(f); kr.Push(RSQMB_MixTab.Role(f)); kw.Push(1.0);
		}
		// the Boss's own family only when nothing else is left
		if (kc.Size() == 0 && bcc) { kc.Push(bossCls); kf.Push(bf); kr.Push(bf >= 0 ? RSQMB_MixTab.Role(bf) : RoleOfType(bcc)); kw.Push(1.0); }
		if (kc.Size() == 0) return;
		int k = want >= 4 ? 3 : (want >= 2 ? 2 : 1);
		// the jobs: k different ones, each drawn by its kinds' weight
		Array<int> picked;            // kind indices, one a family
		Array<bool> roleUsed; for (int r = 0; r < 4; r++) roleUsed.Push(false);
		for (int step = 0; step < k; step++)
		{
			double t = 0;
			for (int i = 0; i < kc.Size(); i++) if (picked.Find(i) == picked.Size() && kr[i] >= 0 && !roleUsed[kr[i]]) t += kw[i];
			bool anyRole = t <= 0;    // no job left unused: a second family of a job already in
			if (anyRole) for (int i = 0; i < kc.Size(); i++) if (picked.Find(i) == picked.Size()) t += kw[i];
			if (t <= 0) break;
			double roll = frandom[rsqmbbf](0, t);
			int pick = -1;
			for (int i = 0; i < kc.Size(); i++)
			{
				if (picked.Find(i) < picked.Size()) continue;
				if (!anyRole && (kr[i] < 0 || roleUsed[kr[i]])) continue;
				pick = i; roll -= kw[i];
				if (roll <= 0) break;
			}
			if (pick < 0) break;
			picked.Push(pick);
			if (kr[pick] >= 0) roleUsed[kr[pick]] = true;
		}
		// the count, round the families in turn (one each of the heavy ones at most)
		Array<int> cnt; for (int i = 0; i < picked.Size(); i++) cnt.Push(0);
		int placed = 0;
		for (int guard = 0; placed < want && guard < want * 4 + 4; guard++)
		{
			int j = guard % picked.Size();
			int f = kf[picked[j]];
			if (f >= 0 && cnt[j] >= MaxOfFam(f)) continue;
			cnt[j]++; placed++;
		}
		// every family at its most: the rest to the first family that has no limit, else the first
		while (placed < want)
		{
			int j = 0;
			for (int q = 0; q < picked.Size(); q++) if (kf[picked[q]] < 0 || MaxOfFam(kf[picked[q]]) > 1) { j = q; break; }
			cnt[j]++; placed++;
		}
		for (int j = 0; j < picked.Size(); j++)
			for (int q = 0; q < cnt[j]; q++) { int i = picked[j]; tc.Push(kc[i]); mixFamT.Push(kf[i]); mixRoleT.Push(kr[i]); }
		if (debug)
		{
			String l = "";
			for (int j = 0; j < picked.Size(); j++)
			{
				int i = picked[j];
				l = l .. String.Format("%s%d x %s (%s, %s%s)", j ? ", " : "", cnt[j], kf[i] >= 0 ? RSQMB_MixTab.Fam(kf[i]) : kc[i], RoleName(kr[i]),
					kw[i] >= MIX_THR_MAPW ? "the map's own" : "from outside the map", "");
			}
			Console.Printf("RSQMB escort for %s (%s, health cap %.0f): %d thralls from %d families of %d that may come: %s", bossCls, bf >= 0 ? RSQMB_MixTab.Fam(bf) : "no family",
				cap, tc.Size(), picked.Size(), kc.Size(), l);
		}
	}

	// after ApplyFrom set their colours: each thrall's family, class and job
	void MixLog(Array<String> tc)
	{
		if (!debug) return;
		for (int i = 0; i < tc.Size(); i++)
		{
			int f = i < mixFamT.Size() ? mixFamT[i] : -1, r = i < mixRoleT.Size() ? mixRoleT[i] : -1;
			Console.Printf("RSQMB escort thrall %d: %s, %s, job %s", i + 1, f >= 0 ? RSQMB_MixTab.Fam(f) : "no family", tc[i], RoleName(r));
		}
	}
}
