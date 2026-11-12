// RSQ VisualRewards -- LEGENDARY over a LegenDoom legendary once it rises (the LegenDoom HUD, direction D: owner 11-11 15:30,
// design/mockups/legendoom_hud/README.md "Owner's decision").
//
//   "No words over a legendary monster until it rises. When it rises (half health), the word is LEGENDARY, with LegenDoom's
//   red pentagram and after-images as they are." Minibosses and thralls: no change (their GUARD! and TARGET! stay as they
//   work now), so a monster RSQ Miniboss names its miniboss or a thrall gets no LEGENDARY.
//
// WHEN: LegenDoom 3.0 (LEGENDMON.acs LDMonsterInit, MonsterStats.dec, read from the pk3) picks a monster by giving it
// LDLegendaryMonsterToken and it RISES at half health, when LDLegendaryMonsterStatBoost gives it
// LDLegendaryMonsterTransformed (the same turn VisualRewards' legendary gem shows from: rsqthp/handler.zs). A monster can
// only rise from being hurt, so a hurt monster carrying the token and not yet transformed is watched every tic until it
// rises (the word goes up that tic) or dies. Both classes are looked up BY NAME: without LegenDoom nothing happens.
// (LegenDoom's "Legendary Monsters: Transformed" setting turns them at once, unhurt: those get the word on their first hit.)
//
// LOOK: the SOTN style A word (two tones, the dark box) in LegenDoom's Epic gold, top 240,150,20 / bottom 255,236,120, as
// make_mockups.py draws it; held over the monster until it dies (rsqvr/words.zs "word.hold", its sotn look). Colour-blind
// modes: the series' COULD colour (words.zs). Photosensitive Mode: nothing to change (the word holds still).
// OFF: the LegenDoom: LEGENDARY Word row (rsqvr_ldword, user): nothing is drawn, as LegenDoom itself draws nothing there.
// The word is made in play on every machine whatever the row says; the row only hides it on that player's screen.
class RSQVR_LDWord : EventHandler
{
	const TOP = 0xF09614;     // 240, 150, 20
	const BOT = 0xFFEC78;     // 255, 236, 120

	Array<Actor> watch;
	transient bool checked;
	transient class<Inventory> tok, risen;
	transient bool mbFound;
	transient Service mbSvc;

	private void Check()
	{
		checked = true;
		String t1 = "LDLegendaryMonsterToken", t2 = "LDLegendaryMonsterTransformed";
		tok = t1; risen = t2;
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		if (!checked) Check();
		if (!tok || !risen) return;
		let m = e.Thing;
		if (!m || !m.bISMONSTER || !m.FindInventory(tok)) return;
		if (watch.Find(m) != watch.Size()) return;
		watch.Push(m);
	}

	override void WorldTick()
	{
		if (fresh.Size() || drops.Size()) DropTick();
		if (!watch.Size()) return;
		if (!checked) Check();
		for (int i = watch.Size() - 1; i >= 0; i--)
		{
			let m = watch[i];
			if (!m || m.bDestroyed || m.health <= 0) { watch.Delete(i); continue; }
			if (!risen || !m.FindInventory(risen)) continue;
			watch.Delete(i);
			if (MinibossOrThrall(m)) continue;
			let h = RSQVR_FxHandler.Get();
			if (h) h.WordHoldSotn("LEGENDARY", TOP, BOT, 1.0, m, 'legendary');
		}
	}

	// RSQ Miniboss's own answer, by name (RSQMB_Service "miniboss" / "thrall"); false without RSQ Miniboss
	private bool MinibossOrThrall(Actor m)
	{
		if (!mbFound) { mbFound = true; let it = ServiceIterator.Find("RSQMB_Service"); mbSvc = it.Next(); }
		if (!mbSvc) return false;
		return mbSvc.GetInt("miniboss", "", 0, 0, m) == 1 || mbSvc.GetInt("thrall", "", 0, 0, m) == 1;
	}

	// ---- THE WORDS OVER A LEGENDOOM DROP (owner 11-11 22:00: "the words over a LegenDoom drop (EPIC plus the power's
	// name)"; direction D, design/mockups/legendoom_hud/README.md "Drop (from B): our gun glows, with EPIC and the power's
	// name over it"). Two held words over the drop until it is picked up or gone: the power's name (LegenDoom's own
	// LD_FX_TITLE_<Power>) and the rarity (LD_RARITY_NAME_<Rarity>, else the rarity's English name), both in the SOTN look
	// in the rarity's two colours (the same table as the Gun Bonsai VR card: Common green, Uncommon blue, Rare purple,
	// Epic orange). A drop is told by the tokens it carries, by name: LD<Slot>Legendary<Rarity> and LD<Slot>Effect_<Power>
	// (BD22 VR's LD mode gives them to its RSLD_LegendaryPickup in Setup, "as LegenDoom's do"). A new pickup is looked at
	// for its first 8 tics, since the tokens can arrive after it spawns. Without LegenDoom nothing carries them.
	// OFF: the LegenDoom: Drop Words row (rsqvr_lddrop, user).
	// (QZD 17.3 keeps constant arrays inside functions)
	private static String SlotN(int i)
	{
		static const String T[] = { "Fists", "Chainsaw", "Pistol", "Shotgun", "SuperShotgun", "Chaingun", "RocketLauncher", "PlasmaRifle", "BFG9000" };
		return T[clamp(i, 0, 8)];
	}
	private static String RarN(int i)
	{
		static const String T[] = { "Common", "Uncommon", "Rare", "Epic" };
		return T[clamp(i, 0, 3)];
	}
	private static int RTop(int i)
	{
		static const int T[] = { 0x5AE65A, 0x6496FF, 0xDC6EFF, 0xF09614 };
		return T[clamp(i, 0, 3)];
	}
	private static int RBot(int i)
	{
		static const int T[] = { 0x96FF78, 0xAAD2FF, 0xF0B4FF, 0xFFEC78 };
		return T[clamp(i, 0, 3)];
	}

	Array<Inventory> fresh;      // new pickups, looked at for 8 tics
	Array<int> freshT;
	Array<Inventory> drops;      // drops wearing words
	Array<String> dropW1, dropW2;

	override void WorldThingSpawned(WorldEvent e)
	{
		let it = Inventory(e.Thing);
		if (!it || it.Owner) return;
		fresh.Push(it); freshT.Push(0);
	}

	private static String LocOr(String key, String fallback)
	{
		String v = StringTable.Localize("$" .. key);
		return (v == key || v == "$" .. key || v == "") ? fallback : v;
	}

	// "" when the pickup carries no legendary power; else the power name and the rarity word, and the rarity index
	private static String, String, int ReadDrop(Inventory d)
	{
		String pow = ""; int rar = -1;
		for (let i = d.Inv; i; i = i.Inv)
		{
			String cn = i.GetClassName();
			if (cn.Left(2) != "LD") continue;
			for (int s = 0; s < 9; s++)
			{
				String pe = "LD" .. SlotN(s) .. "Effect_";
				if (cn.Length() > pe.Length() && cn.Left(pe.Length()) == pe) pow = cn.Mid(pe.Length());
				String pl = "LD" .. SlotN(s) .. "Legendary";
				if (cn.Length() > pl.Length() && cn.Left(pl.Length()) == pl)
					for (int r = 0; r < 4; r++) if (cn.Mid(pl.Length()) ~== RarN(r)) rar = r;
			}
		}
		if (pow == "" || rar < 0) return "", "", -1;
		return LocOr("LD_FX_TITLE_" .. pow, pow), LocOr("LD_RARITY_NAME_" .. RarN(rar), RarN(rar)), rar;
	}

	// A LEGENDARY FIST DROP HAS A MODEL (owner 11-11 23:56): BD22 VR's legendary pickup wears its weapon's own pickup frame,
	// and the fists have none, so a fist drop was the glow and the words round nothing. A drop that carries a fists token
	// (LDFists...) and draws nothing (no sprite, or TNT1) is lent the fist mesh (MODELDEF.rsqvr, RSQVR_LDFist) on a frame
	// of its own. Any drop that already draws something is left alone. Rig: the log line below; the look is the headset's.
	private void FistLook(Inventory d)
	{
		bool fist = false;
		for (let i = d.Inv; i; i = i.Inv) { String cn = i.GetClassName(); if (cn.Left(7) == "LDFists") { fist = true; break; } }
		if (!fist) return;
		if (d.sprite != Actor.GetSpriteIndex("TNT1")) return;   // it draws something already (BD22 VR sets sprite / frame itself)
		d.sprite = Actor.GetSpriteIndex("RVFI");
		d.frame = 0;
		d.Scale = (1.0, 1.0);
		d.A_ChangeModel("RSQVR_LDFist");
		lentFists++;
	}
	int lentFists;     // how many fist drops were lent the model (a test reads it)

	private void DropTick()
	{
		for (int i = fresh.Size() - 1; i >= 0; i--)
		{
			let d = fresh[i];
			if (!d || d.bDestroyed || d.Owner || ++freshT[i] > 8) { fresh.Delete(i); freshT.Delete(i); continue; }
			String w1, w2; int rar;
			[w1, w2, rar] = ReadDrop(d);
			if (rar < 0) continue;
			fresh.Delete(i); freshT.Delete(i);
			FistLook(d);
			let h = RSQVR_FxHandler.Get();
			if (!h) continue;
			// the power's name first (lower), the rarity above it
			h.WordHoldSotn(w1, RTop(rar), RBot(rar), 1.0, d, 'lddrop');
			h.WordHoldSotn(w2, RTop(rar), RBot(rar), 1.0, d, 'lddrop');
			drops.Push(d); dropW1.Push(w1); dropW2.Push(w2);
		}
		for (int i = drops.Size() - 1; i >= 0; i--)
		{
			let d = drops[i];
			if (d && !d.bDestroyed && !d.Owner) continue;
			// picked up (it went into someone's inventory) or gone: the words fade
			let h = RSQVR_FxHandler.Get();
			if (h && d) { h.ClearWord(dropW1[i], d); h.ClearWord(dropW2[i], d); }
			drops.Delete(i); dropW1.Delete(i); dropW2.Delete(i);
		}
	}

	override void WorldUnloaded(WorldEvent e) { watch.Clear(); fresh.Clear(); freshT.Clear(); drops.Clear(); dropW1.Clear(); dropW2.Clear(); }
}
