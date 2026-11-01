// RSQ Grenade -- GRENADES SCATTERED THROUGH EACH MAP, the UAC Survival Pack's way (randomuac.acs
// UAC_RandomItemSpawner, parsed): once per map, beside every item lying in the level, one roll of random(0, 125):
// 6-10 drops a single grenade (5 in 126), 18-20 a pack of three (3 in 126), 15 units to the item's south (the pack's
// y - 15), up to a cap a map (the pack's uac_grenamt 4 and uac_grenpkamt 2: rsqgn_singles, rsqgn_packs).
// The pack's other rolls (its flares, pipe bombs, satchels) are not ours and roll nothing here.
//
// Differences from the ACS, on purpose: it runs when the map is loaded (the pack waited 5 tics after a player
// entered, then gave every item a token that ran the script); it does not skip an item standing at x, y or z = 0
// (the ACS's "no position" test also skipped every item on a floor at height 0); a drop that would land in a wall is
// put on the item instead.
//
// Deterministic in netplay: every machine loads the same map, walks the same items in the same order and draws from
// the same synced random table (random[RSQGN_Scatter]). Not on a saved game or a hub map revisited.
class RSQGN_Scatter : EventHandler
{
	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame || e.IsReopen) return;
		if (!RSQGN_Handler.Active()) return;
		let on = CVar.FindCVar("rsqgn_scatter");
		if (on && !on.GetBool()) return;
		int capS = clamp(int(RSQGN_Handler.SNum("rsqgn_singles", 4)), 0, 16);
		int capP = clamp(int(RSQGN_Handler.SNum("rsqgn_packs", 2)), 0, 16);

		Array<Inventory> items;
		let it = ThinkerIterator.Create("Inventory");
		Inventory i;
		while (i = Inventory(it.Next()))
			// a pickup lying in the level (bSpecial: it can be touched); not what a player carries, nor the unowned
			// armour and ammo objects the engine keeps at the map's origin (seen on the rig: HexenArmor, BasicArmor)
			if (!i.Owner && i.bSpecial && !(i is "RSQGN_Ammo")) items.Push(i);

		int s = 0, k = 0;
		for (int j = 0; j < items.Size(); j++)
		{
			int r = random[RSQGN_Scatter](0, 125);
			if (r > 5 && r <= 10 && s < capS) { if (Drop("RSQGN_Ammo", items[j])) s++; }
			else if (r > 17 && r <= 20 && k < capP) { if (Drop("RSQGN_Pack", items[j])) k++; }
		}
		if (players[consoleplayer].mo && RSQGN_Handler.Debug(players[consoleplayer]))
			Console.Printf("RSQGN scatter %s: %d items rolled, %d single grenades (cap %d), %d packs (cap %d)", level.MapName, items.Size(), s, capS, k, capP);
	}

	static bool Drop(class<Actor> c, Actor by)
	{
		let a = Actor.Spawn(c, by.pos + (0, -15, 0), ALLOW_REPLACE);
		if (!a) return false;
		if (!a.TestMobjLocation()) a.SetOrigin(by.pos, false);
		return true;
	}
}
