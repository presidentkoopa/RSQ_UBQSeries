// ============================================================================
// RS_Carry -- A MONSTER THAT CHANGES COLOUR STAYS WHAT IT WAS, AND ITS TIER COLOUR STAYS ON TOP (2026-11-13).
// design/BD_XMVE_TIERING.md section 8, fix 2 (a swap carries what the other mods gave the old body) and fix 6
// (Champions' and Universal Entropy's tints no longer hide the tier colour).
//
// FIX 2. A ColorfulHell colour is its own class, so a tier change (RS_Retier.Swap) spawns a NEW body and destroys the
// old one. Before this, the new body was a stranger to every other mod: Champions rolled it again, LegenDoom's legendary
// was gone, Universal Entropy gave it a new size. Now Swap hands the old body to RS_Carry.Take, and the new body gets:
//   - its CHAMPION (Champions 2021-03-09): the old body's champion_PersistentInfo (its colour, mutation and hybrid) is
//     moved onto it, and Champions' own WorldThingRevived builds its controllers from that record (the same colour, the
//     same mutation; Champions' code, nothing copied). It holds champion_NullToken for its spawn, so Champions does not roll
//     it a second, random champion. A champion still held DORMANT (Champions' "Dormant until LegenDoom transforms it",
//     champion_dormant 1) keeps its record and its colour token but no controller: Champions' own revive does the same
//     (handler.txt WorldThingRevived leaves a dormant champion asleep). One case is woken: a LegenDoom legendary that has
//     not risen yet (its champion would wake when it rises, and nothing can wake it later from here: Champions builds
//     controllers only inside its own events). It is the case RSQ Miniboss's carry wakes too (Miniboss/zscript/rsqmb/carry.zs).
//   - its LEGENDARY (LegenDoom 3.0): LDLegendaryMonsterPickupGuaranteed, LegenDoom's own "make this legendary" item, so
//     its own script (LEGENDMON.acs LDMonsterInit) runs on the new body: legendary health, the drop on death. One that had
//     RISEN (LDLegendaryMonsterTransformed: healed, boosted, glowing) rises again: it is taken just under half its legendary
//     health for one tic, unhurtable, and LegenDoom raises it by its own rule (Miniboss's trick, boss.zs RiseOne).
//     Then its health is set to the share the old body had (of its legendary health).
//   - RSQ's own marks: RS_CHAbyssMark and RS_GrowRaisin (ColorfulHell's Abyss and Grow); the tier stamp is put by the job.
//   - UNIVERSAL ENTROPY's look: its size (radius, height and scale against its class, the health, damage and pain that
//     came with it, its Shifter for the voice). Not its colour: that is fix 6.
//   A Miniboss set piece (RSQMB_Ward, RSQMB_Thrall) gets the same, but Miniboss raises it and gives its health back itself
//   (boss.zs Reborn), so the legendary health steps here are left to it.
//   Brutal Doom, XMVE and plain Doom monsters change colour IN PLACE (RS_BDKit, RS_BDTier.zs): the same actor, so they keep
//   everything without this. (One thing was lost in place too and is fixed there: a legendary's extra health.)
//
// FIX 6. THE TIER COLOUR STAYS ON TOP (owner 11-13 09:49 approved the body-recolour tier tints).
//   - Universal Entropy recolours a monster once, in its spawn event (randomise.zs; ue_recolour 5 = always). RS_CarryFirst
//     runs before every other handler and notes the colour each new thing has; RS_CarryLast runs after every other
//     handler and, on a monster that wears a tier colour, puts that colour back: a Brutal Doom monster's tier tint, a
//     ColorfulHell monster's own colour.
//   - Champions tints a champion when its controller starts (at spawn, or when LegenDoom transforms it, and again on a
//     revive). The tier kit (BD) or RS_LookKeep (ColorfulHell) sees a Champions tint on its monster and puts the tier
//     colour back on the next tic. Only Champions' tints are undone, never a colour a monster's own states set
//     (ColorfulHell's Cyberdemon and Fatso EX change theirs). Champions keeps its particles, its icons and its powers.
//   - A monster in its PLAIN look (a Brutal Doom monster at its entry colour, a ColorfulHell Common) wears no tier colour,
//     so Universal Entropy's and Champions' colours are left on it.
//   - The tier change's own flash is never fought (the job marks the monster while it flashes).
//
// Everything by class NAME: without Champions, LegenDoom, Universal Entropy or RSQ Miniboss this does nothing for them.
// Cost: two small handlers' spawn events (a pointer and an int noted, a few tests); a kit or keeper compares one int a tic.
// Debug: rsq_mon_bdtier_debug 1 prints every carry; `netevent rs_carry_dump` lists every living monster's colour, champion
// and legendary state.
// ============================================================================

class RS_Carry play
{
	static bool Debug() { let c = CVar.FindCVar('rsq_mon_bdtier_debug'); return c && c.GetBool(); }
	static clearscope class<Inventory> Inv(String n) { class<Inventory> c = n; return c; }
	static clearscope bool Has(Actor a, String n) { let c = Inv(n); return a && c && a.FindInventory(c); }
	static int CVI(Name n, int def) { let c = CVar.FindCVar(n); return c ? c.GetInt() : def; }

	// LegenDoom's LD_legendarymonsters: 0 a legendary is only marked, 1 it rises at half health (healed, boosted), 2 it is
	// transformed at once
	static int LDMode() { return CVI('LD_legendarymonsters', 1); }
	// LegenDoom's legendary health factor (LDMonsterInit: x LD_legendaryhealth / 100, bosses LD_legendaryhealthboss, in
	// whole numbers as its ACS does)
	static int LDMult(Actor a) { return max(1, CVI(a.bBOSS ? 'LD_legendaryhealthboss' : 'LD_legendaryhealth', 300) / 100); }
	// Champions holds a champion asleep until LegenDoom transforms it (handler.txt: champion_dormant with champion_legendoom,
	// and LegenDoom loaded)
	static bool ChampDormantRule()
	{
		return CVI('champion_dormant', 0) != 0 && CVI('champion_legendoom', 0) != 0 && Inv("LDLegendaryMonsterToken") != null;
	}

	// THE MOST HEALTH THIS BODY HAS A RIGHT TO (the wound share is of this). Its spawn health (skill, ladder health,
	// Champions' StartHealth); a LegenDoom legendary's is LegenDoom's: x3 (LegenDoom raises its health, never its
	// StartHealth). Except when Champions woke it AFTER it rose (the dormant rule): Champions then set its StartHealth from
	// the risen health, so the spawn health already is the legendary number.
	static int PeakOf(Actor mo)
	{
		int full = mo.GetSpawnHealth();
		if (Has(mo, "LDLegendaryMonsterToken") && LDMode() != 0)
		{
			bool risen = Has(mo, "LDLegendaryMonsterTransformed");
			bool champAfter = risen && ChampDormantRule() && Has(mo, "champion_PersistentInfo");
			if (!champAfter) full *= LDMult(mo);
		}
		return max(1, full);
	}

	// Swap: `mo` is the old body, `a` the new one (spawned, its spawn event not yet run), `frac` the share of PeakOf(mo) the
	// old body had. Called before the old body is destroyed.
	static void Take(Actor mo, Actor a, double frac)
	{
		if (!mo || !a) return;
		let first = RS_CarryFirst(EventHandler.Find("RS_CarryFirst"));
		if (!first) return;
		// swapped inside its own spawn event (the world tier at map load, RS_RetierHandler): Champions and Universal Entropy
		// rolled it this very moment, so the new body is simply rolled by them in its turn, as any new monster is
		if (first.inSpawn == mo)
		{
			if (Debug()) Console.Printf("CARRY t%d: %s -> %s in its own spawn event: the other mods roll the new body", level.maptime, mo.GetClassName(), a.GetClassName());
			return;
		}
		let r = RS_CarryRec(new("RS_CarryRec"));
		r.nu = a;
		r.from = mo.GetClassName();
		r.born = level.maptime;
		r.frac = frac;
		bool risen = Has(mo, "LDLegendaryMonsterTransformed");
		r.legend = Has(mo, "LDLegendaryMonsterToken") ? (risen ? 2 : 1) : 0;
		r.setPiece = Has(mo, "RSQMB_Ward") || Has(mo, "RSQMB_Thrall");
		r.hadNull = Has(mo, "champion_NullToken");

		// Champions: the record off the old body (its WorldThingDestroyed must not find it: Miniboss's carry would take it)
		let ic = Inv("champion_PersistentInfo");
		let info = ic ? mo.FindInventory(ic) : null;
		if (info)
		{
			mo.RemoveInventory(info);
			r.info = info;
			// awake by Champions' own rule (not held for LegenDoom, or LegenDoom has transformed it), or a legendary waiting to rise
			r.wake = !ChampDormantRule() || risen || r.legend == 1;
		}
		bool titan = r.wake && Has(mo, "champion_TitanToken");   // its controller makes it a Titan again (x1.33 scale)

		// Universal Entropy's size, against the class (its Shifter held for the new body, which UE may give one of its own)
		let od = GetDefaultByType(mo.GetClass());
		r.rr = od.radius > 0 ? mo.radius / od.radius : 1.0;
		r.hr = od.height > 0 ? mo.height / od.height : 1.0;
		double tf = titan ? 1.33 : 1.0;
		r.sx = od.Scale.x != 0 ? mo.Scale.x / od.Scale.x / tf : 1.0;
		r.sy = od.Scale.y != 0 ? mo.Scale.y / od.Scale.y / tf : 1.0;

		// the items that are not built again: RSQ's marks, UE's Shifter, and a sleeping champion's tokens (an awake one's
		// controllers give theirs again)
		class<Inventory> tokCls = Inv("champion_Token");
		for (Inventory it = mo.Inv; it; )
		{
			let nx = it.Inv;
			String n = it.GetClassName();
			bool move = false;
			if (n ~== "RS_CHAbyssMark" || n ~== "RS_GrowRaisin") move = true;
			else if (n ~== "Shifter") { mo.RemoveInventory(it); r.shifter = it; it = nx; continue; }
			else if (!r.wake && n.Left(9) ~== "champion_" && !(n ~== "champion_NullToken") && !(n ~== "champion_PersistentInfo")) move = true;
			if (move && a.FindInventory(it.GetClass())) move = false;
			if (move) { mo.RemoveInventory(it); it.AttachToOwner(a); r.moved++; }
			it = nx;
		}
		first.pend.Push(r);
	}
}

// One swapped body: what it carries, until its spawn event, then LegenDoom's health steps.
class RS_CarryRec : Thinker
{
	Actor nu;              // the new body
	String from;           // the old body's class (debug)
	int born;
	double frac;           // the share of its most health the old body had
	Inventory info;        // Champions' record, between the swap and the new body's spawn event
	bool wake, woke;       // its champion is awake / Champions built its controllers on the new body
	bool hadNull, tempNull;
	int legend;            // 0 not legendary, 1 legendary, 2 legendary and risen
	bool setPiece;         // a Miniboss set piece (Miniboss raises it and gives its health back)
	double rr, hr, sx, sy; // UE's size against the class
	Inventory shifter;     // UE's Shifter (its voice pitch), held for the new body
	int moved;
	bool spawned;
	int stage, ldFull;     // LegenDoom's steps: 0 waiting for its legendary health, 1 waiting for it to rise, 9 done
	bool ownInv;
	Actor tgt;
	const LD_WAIT = 105;

	void Done(String why)
	{
		if (stage == 1 && nu) nu.bINVULNERABLE = ownInv;
		stage = 9;
		if (RS_Carry.Debug() && why != "") Console.Printf("CARRY t%d: %s %s", level.maptime, nu ? nu.GetClassName() : 'its new body', why);
		Destroy();
	}

	override void OnDestroy()
	{
		if (stage == 1 && nu) nu.bINVULNERABLE = ownInv;
		if (info && !info.Owner) info.Destroy();
		if (shifter && !shifter.Owner) shifter.Destroy();
		Super.OnDestroy();
	}

	override void Tick()
	{
		if (!nu || nu.bDestroyed) { Done(""); return; }
		if (!spawned) { if (level.maptime - born > 35) Done("never had its spawn event"); return; }
		if (level.isFrozen()) return;
		if (legend == 0 || setPiece || RS_Carry.LDMode() == 0) { Done(""); return; }
		if (nu.health <= 0) { Done("died before LegenDoom finished"); return; }
		int age = level.maptime - born;
		if (stage == 0)
		{
			// LegenDoom's script has run on it: it holds the token and its legendary health
			if (!RS_Carry.Has(nu, "LDLegendaryMonsterToken")) { if (age > LD_WAIT) Done("not made legendary by LegenDoom in 3 s"); return; }
			ldFull = nu.health;
			if (legend == 2 && RS_Carry.LDMode() == 1)
			{
				// it had risen: under half for one tic, unhurtable, and LegenDoom raises it (heals it, boosts it)
				ownInv = nu.bINVULNERABLE;
				tgt = nu.target;
				nu.bINVULNERABLE = true;
				nu.health = 2;
				stage = 1;
				if (RS_Carry.Debug()) Console.Printf("CARRY t%d: %s legendary again (health %d), taken to 2 for LegenDoom to raise it", level.maptime, nu.GetClassName(), ldFull);
				return;
			}
			// not risen: its share of its legendary health, never at or under half (LegenDoom would raise it for that)
			int hp = int(round(ldFull * frac));
			if (legend == 1 && RS_Carry.LDMode() == 1) hp = max(hp, ldFull / 2 + 1);
			nu.health = max(1, min(ldFull, hp));
			Done(String.Format("legendary again: health %d of %d (share %.2f)", nu.health, ldFull, frac));
			return;
		}
		if (stage == 1)
		{
			if (!RS_Carry.Has(nu, "LDLegendaryMonsterTransformed"))
			{
				if (age > LD_WAIT) { nu.health = max(1, int(round(ldFull * frac))); Done(String.Format("did NOT rise in 3 s; health %d", nu.health)); }
				return;
			}
			int full = max(nu.health, nu.GetSpawnHealth());
			nu.bINVULNERABLE = ownInv;
			stage = 2;
			nu.health = max(1, int(round(full * frac)));
			if (tgt && tgt.health > 0 && !nu.target) { nu.target = tgt; nu.LastHeard = tgt; }
			Done(String.Format("risen again by LegenDoom: health %d of %d (share %.2f)", nu.health, full, frac));
		}
	}
}

// FIRST of every handler: the colour each new thing came with (fix 6), and a swapped body's champion (fix 2), built
// before Champions' own handler could roll it and before RSQ Miniboss's carry (order -1000) looks at it.
class RS_CarryFirst : EventHandler
{
	Array<RS_CarryRec> pend;      // swapped bodies whose spawn event has not come yet
	Actor inSpawn;                // the thing whose spawn event is running (cleared by RS_CarryLast)
	Actor preThing;
	TranslationID preTrans;

	override void OnRegister() { SetOrder(-1100); }

	RS_CarryRec PendFor(Actor a)
	{
		for (int i = pend.Size() - 1; i >= 0; i--)
		{
			let r = pend[i];
			if (!r || !r.nu || r.nu.bDestroyed) { pend.Delete(i); continue; }
			if (r.nu == a) return r;
		}
		return null;
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a) return;
		inSpawn = a;
		preThing = a;
		preTrans = a.Translation;
		if (!a.bISMONSTER || pend.Size() == 0) return;
		let r = PendFor(a);
		if (!r) return;
		if (r.info)
		{
			r.info.AttachToOwner(a);
			r.info = null;
			if (r.wake)
			{
				String hn = "champion_Handler";
				class<StaticEventHandler> hc = hn;
				let ch = hc ? EventHandler.Find(hc) : null;
				if (ch)
				{
					// Champions' revive builds the controllers from the record; it skips a champion held dormant for LegenDoom,
					// so the Transformed token is held for that one call (LegenDoom gives the real one when it rises)
					let tc = RS_Carry.Inv("LDLegendaryMonsterTransformed");
					bool tmp = tc && !a.FindInventory(tc);
					if (tmp) a.GiveInventory(tc, 1);
					ch.WorldThingRevived(e);
					if (tmp) a.TakeInventory(tc, 999);
					r.woke = true;
				}
			}
		}
		// Champions must not roll it again (taken off again at the end of this spawn event, RS_CarryLast). After the revive:
		// Champions' revive removes a body that holds this token (its Indigo clones).
		let nc = RS_Carry.Inv("champion_NullToken");
		if (nc && !a.FindInventory(nc)) { a.GiveInventory(nc, 1); r.tempNull = true; }
	}
}

// LAST of every handler: the rest of the carry, and the tier colour back on top of Universal Entropy's (fix 6).
class RS_CarryLast : EventHandler
{
	override void OnRegister() { SetOrder(1100); }

	static RS_CarryLast Get() { return RS_CarryLast(EventHandler.Find("RS_CarryLast")); }

	// ---- Champions' tints, by name (champions/trnslate.txt); a translation id is the same int for the whole game ----------
	static const Name CHAMP_TINTS[] = { 'champion_darkred', 'champion_red', 'champion_orange', 'champion_yellow',
		'champion_darkgreen', 'champion_green', 'champion_blue', 'champion_indigo', 'champion_violet', 'champion_pink',
		'champion_magenta', 'champion_cyan', 'champion_brown', 'champion_black', 'champion_grey', 'champion_white',
		'champion_bronze', 'champion_silver', 'champion_golden' };
	private Array<int> champIds;
	private bool champBuilt;
	private RS_CarryFirst firstH;
	private int fixes;

	// which Champions tint this is (its index), -1 none
	int ChampTint(int tr)
	{
		if (!champBuilt)
		{
			champBuilt = true;
			for (int i = 0; i < CHAMP_TINTS.Size(); i++) champIds.Push(int(Translate.GetID(CHAMP_TINTS[i])));
		}
		if (tr == 0) return -1;
		for (int i = 0; i < champIds.Size(); i++) if (champIds[i] != 0 && champIds[i] == tr) return i;
		return -1;
	}
	static bool IsChampTint(int tr) { let h = Get(); return h && h.ChampTint(tr) >= 0; }

	void Fixed(Actor a, String what)
	{
		fixes++;
		if (RS_Carry.Debug()) Console.Printf("LOOK t%d: %s %s (%d so far)", level.maptime, a.GetClassName(), what, fixes);
	}

	// a ColorfulHell monster that wears a colour (every tier above Common)
	static bool CHColoured(Actor a)
	{
		String n = a.GetClassName();
		if (!(n.Left(3) ~== "RS_") || RS_TierLadder.FamilyOfAny(n) < 0) return false;
		return RS_TierLadder.TierOfAny(n) >= 2;
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!firstH) firstH = RS_CarryFirst(EventHandler.Find("RS_CarryFirst"));
		let first = firstH;
		if (first) first.inSpawn = null;
		if (!a || a.bDestroyed || !a.bISMONSTER || a.player) return;
		if (first && first.pend.Size()) Carried(first, a);

		// fix 6 at spawn: Universal Entropy's colour off a monster that wears a tier colour
		if (a.health <= 0) return;
		let k = RS_BDKit.Of(a);
		if (k)
		{
			if (k.rung > k.entry && int(a.Translation) != k.tintId) { k.Look(); Fixed(a, "tier tint back over a colour from its spawn event"); }
			return;
		}
		if (!CHColoured(a) || !first || first.preThing != a) return;
		if (int(a.Translation) != int(first.preTrans))
		{
			a.Translation = first.preTrans;
			Fixed(a, "its ColorfulHell colour back over a colour from its spawn event");
		}
		a.GiveInventory("RS_LookKeep", 1);
		let lk = RS_LookKeep(a.FindInventory("RS_LookKeep"));
		if (lk) { lk.want = first.preTrans; lk.wantId = int(first.preTrans); }
	}

	private void Carried(RS_CarryFirst first, Actor a)
	{
		let r = first.PendFor(a);
		if (!r) return;
		first.pend.Delete(first.pend.Find(r));
		r.spawned = true;
		let nc = RS_Carry.Inv("champion_NullToken");
		if (r.tempNull && nc && !r.hadNull) a.TakeInventory(nc, 999);

		// Universal Entropy's size: its roll for the new body undone (health, damage, pain, reach, mass), the old one's put on
		let nd = GetDefaultByType(a.GetClass());
		double n1 = nd.radius > 0 ? a.radius / nd.radius : 1.0, n2 = nd.height > 0 ? a.height / nd.height : 1.0;
		bool sized = abs(n1 - 1) > 0.001 || abs(n2 - 1) > 0.001 || abs(r.rr - 1) > 0.001 || abs(r.hr - 1) > 0.001;
		if (sized && a.A_SetSize(nd.radius * r.rr, nd.height * r.hr, false))
		{
			double f = (r.rr * r.hr) / (n1 * n2), rt = sqrt(f);
			a.health = max(1, int(round(a.health * f)));
			a.Mass = max(1, int(round(a.Mass * f)));
			a.DamageMultiply *= rt;
			a.PainChance = int(round(a.PainChance / rt));
			a.MeleeRange *= rt;
		}
		a.A_SetScale(nd.Scale.x * r.sx, nd.Scale.y * r.sy);
		if (r.shifter)
		{
			let sc = RS_Carry.Inv("Shifter");
			let own = sc ? a.FindInventory(sc) : null;
			if (own) own.Destroy();
			r.shifter.AttachToOwner(a);
			r.shifter = null;
		}

		// LegenDoom: legendary again, by its own item (its script runs from the next tic; RS_CarryRec follows it)
		if (r.legend > 0)
		{
			let lc = RS_Carry.Inv("LDLegendaryMonsterPickupGuaranteed");
			if (lc) a.GiveInventory(lc, 1);
		}

		if (RS_Carry.Debug())
		{
			String champ = "no champion";
			if (RS_Carry.Has(a, "champion_PersistentInfo")) champ = r.woke ? "champion built again by Champions" : "champion kept, asleep (Champions' dormant rule)";
			Console.Printf("CARRY t%d: %s -> %s: %s; legendary %s; %d items moved; size %.2f x %.2f, scale %.2f x %.2f%s", level.maptime, r.from,
				a.GetClassName(), champ, r.legend == 2 ? "and risen" : (r.legend == 1 ? "yes" : "no"), r.moved, r.rr, r.hr, a.Scale.x, a.Scale.y,
				r.setPiece ? " (a Miniboss set piece)" : "");
		}
	}

	// ---- netevent rs_carry_dump: every living monster's colour, champion and legendary state --------------------------------
	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "rs_carry_dump")) return;
		int n = 0, onTop = 0, champTinted = 0;
		ThinkerIterator it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next()))
		{
			if (!a.bISMONSTER || a.player || a.health <= 0) continue;
			n++;
			int tr = int(a.Translation);
			let k = RS_BDKit.Of(a);
			String look;
			int ct = ChampTint(tr);
			if (ct >= 0) { look = String.Format("CHAMPIONS TINT %s", CHAMP_TINTS[ct]); champTinted++; }
			else if (k && k.rung > k.entry) { look = tr == k.tintId ? String.Format("tier tint %s", RS_BDKit.TintName(k.Tier())) : "NOT its tier tint"; if (tr == k.tintId) onTop++; }
			else if (k) look = tr == 0 ? "plain (entry colour)" : "plain (entry colour), recoloured by another mod";
			else if (CHColoured(a)) { let lk = RS_LookKeep(a.FindInventory("RS_LookKeep")); look = (lk && tr == lk.wantId) ? "its ColorfulHell colour" : "NOT its ColorfulHell colour"; if (lk && tr == lk.wantId) onTop++; }
			else look = tr == 0 ? "plain" : "plain, recoloured by another mod";
			String champ = "";
			for (Inventory i = a.Inv; i; i = i.Inv)
			{
				String cn = i.GetClassName();
				if (cn.Left(9) ~== "champion_" || cn.Left(2) ~== "LD" && (cn.IndexOf("Token") >= 0 || cn.IndexOf("Transformed") >= 0)) champ = champ .. " " .. cn;
			}
			Console.Printf("CARRYDUMP: %s tier %d | hp %d | %s | scale %.2f |%s", a.GetClassName(), RS_Retier.TierNowOf(a), a.health, look, a.Scale.x, champ);
		}
		Console.Printf("CARRYDUMP: %d living monsters; %d wear their tier colour; %d wear a Champions tint", n, onTop, champTinted);
	}
}

// On a ColorfulHell monster that wears a colour: a Champions tint is taken off again (fix 6). Only Champions' tints: a
// ColorfulHell monster's own states change its colour (the Cyberdemon's and Fatso's EX forms), and those are left alone.
class RS_LookKeep : Inventory
{
	TranslationID want;
	int wantId, flashTic, seenTr;
	bool seenChamp;

	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE }

	// the tier change's flash is running on this monster (RS_RetierJob): its colours are not fought
	static void Hold(Actor mo)
	{
		if (!mo) return;
		let k = RS_BDKit.Of(mo);
		if (k) k.flashTic = level.maptime;
		let lk = RS_LookKeep(mo.FindInventory("RS_LookKeep"));
		if (lk) lk.flashTic = level.maptime;
	}

	// a Champions tint (cached for the last translation seen, so a colour that is not one costs one compare a tic)
	bool ChampTinted(int tr)
	{
		if (tr != seenTr) { seenTr = tr; seenChamp = RS_CarryLast.IsChampTint(tr); }
		return seenChamp;
	}

	override void DoEffect()
	{
		let o = owner;
		if (!o || o.health <= 0 || level.isFrozen()) return;
		int tr = int(o.Translation);
		if (tr == wantId || level.maptime - flashTic <= 1 || !ChampTinted(tr)) return;
		o.Translation = want;
		let h = RS_CarryLast.Get();
		if (h) h.Fixed(o, "its ColorfulHell colour back over a Champions tint");
	}
}
