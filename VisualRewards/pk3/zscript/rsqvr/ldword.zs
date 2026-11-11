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

	override void WorldUnloaded(WorldEvent e) { watch.Clear(); }
}
