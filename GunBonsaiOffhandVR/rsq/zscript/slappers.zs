// SLAPPERS ONLY (rsq_slappers, a server setting, off by default; Options -> Gun Bonsai -> RSQ
// Suite Upgrades, and Options -> RSQ Suite Upgrades).
//
// WHAT THE TOGGLE DOES:
//   ON   at once (no need to wait for the next level): you are handed the boxing gloves and they
//        are put on both hands; every gun you carry is put away in a stash; gun pickups become
//        nothing while it lasts, and a gun handed to you later is stashed within a quarter second.
//        You keep the suite's melee (gloves, sabers, ShieldSaw, Force hand) and whatever the loaded
//        game itself calls melee (RSQM.IsSlapperClass: no list of one mod's names). Ammo stays.
//        At each level start the same is done again.
//   OFF  at once: the stashed guns come back -- with no free ammo (what you had is what you have)
//        -- and the gun that was in your main hand goes back into it. The gloves stay in your
//        inventory. Gun pickups the toggle removed from the current level do not come back.
//
// Outside it, rsq_gloves 1 hands you the gloves at the start of each level (default 0: never).
class RSQ_NoPickup : Actor
{
	// what a gun pickup becomes: nothing, gone on its first tic
	Default { +NOINTERACTION +NOBLOCKMAP +NOSECTOR RenderStyle "None"; }
	States { Spawn: TNT1 A 1; Stop; }
}

// The guns Slappers Only put away, carried with the player across levels.
class RSQ_SlapperStash : Inventory
{
	Array<String> guns;
	String mainGun, offGun;
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE +INVENTORY.QUIET }
}

class RSQ_SlappersHandler : EventHandler
{
	static bool On() { return RSQM.SVI("rsq_slappers", 0) != 0; }

	int dueTic[MAXPLAYERS];
	int equipStage[MAXPLAYERS], equipTic[MAXPLAYERS];     // putting the gloves on both hands
	int restoreStage[MAXPLAYERS], restoreTic[MAXPLAYERS]; // giving the main gun back its hand
	String restoreOff[MAXPLAYERS];
	bool wasOn, seen;

	override void CheckReplacement(ReplaceEvent e)
	{
		if (!On() || e.IsFinal) return;
		// the class that will really spawn, after every replacement so far
		Class<Actor> c = e.Replacement ? e.Replacement : e.Replacee;
		if (!IsGun(c)) return;
		e.Replacement = "RSQ_NoPickup";
		e.IsFinal = true;
	}

	static bool IsGun(Class<Actor> c, Actor pawn = null)
	{
		let w = (Class<Weapon>)(c);
		return w && !RSQM.IsSlapperClass(c, pawn);
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		// anything that reached the world as a gun anyway (spawned with NO_REPLACE): a gun
		// lying on the floor with no owner goes
		if (!On() || !e.thing) return;
		let w = Weapon(e.thing);
		if (w && !w.owner && IsGun(w.GetClass())) w.Destroy();
	}

	override void PlayerEntered(PlayerEvent e)
	{
		if (e.PlayerNumber < 0 || e.PlayerNumber >= MAXPLAYERS) return;
		// the kit goes on a few tics in, after the mods that hand out their own weapons at spawn
		dueTic[e.PlayerNumber] = level.maptime + 3;
	}
	override void PlayerRespawned(PlayerEvent e)
	{
		if (e.PlayerNumber >= 0 && e.PlayerNumber < MAXPLAYERS) dueTic[e.PlayerNumber] = level.maptime + 3;
	}

	override void WorldTick()
	{
		bool slap = On();
		bool gloves = slap || RSQM.SVI("rsq_gloves", 0) != 0;
		// THE TOGGLE FLIPPED (a server cvar, read once a tic): act now, not at the next level
		bool flipOn = seen && slap && !wasOn;
		bool flipOff = seen && !slap && wasOn;
		wasOn = slap; seen = true;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			let pmo = players[pn].mo;
			if (flipOn)
			{
				// what the off hand held, to give it back when the toggle goes off (a kept melee weapon
				// such as the second saber is never stashed, so it is remembered here)
				let off = pmo.player.OffhandWeapon;
				let stash = StashOf(pmo);
				if (stash && off && !RSQM.IsGloveName(off.GetClassName())) stash.offGun = off.GetClassName();
				GiveGloves(pmo); Strip(pmo); GiveKit(pmo); StartEquip(pn);
			}
			if (flipOff) Restore(pn, pmo);
			if (dueTic[pn] > 0 && level.maptime >= dueTic[pn])
			{
				dueTic[pn] = 0;
				if (gloves) GiveGloves(pmo);
				if (slap) { Strip(pmo); GiveKit(pmo); StartEquip(pn); }
			}
			// AND IT STAYS THAT WAY: whatever hands you a gun later (a script, a mod's own
			// give, a cheat) loses it within a quarter of a second
			else if (slap && (level.maptime % 8) == pn % 8) Strip(pmo);
			EquipTick(pn, pmo);
			RestoreTick(pn, pmo);
		}
	}

	static void Give(PlayerPawn pmo, String cls)
	{
		Class<Inventory> c = cls;
		if (c && !pmo.FindInventory(c)) pmo.GiveInventory(c, 1);
	}

	static void GiveGloves(PlayerPawn pmo)
	{
		Give(pmo, "RSQ_Glove");
		Give(pmo, "RSQ_GloveOff");
	}

	static void GiveKit(PlayerPawn pmo)
	{
		GiveGloves(pmo);
		// the suite's sabers, by name: each only if its mod is loaded. The base game's own melee
		// stays as it was (it is never taken); the ShieldSaw is handed out by its own mod.
		Give(pmo, "UBQS_Saber");
		Give(pmo, "UBQS_SaberOff");
	}

	// PUT THE GLOVES ON: the main hand first, then the off hand once the main has switched (an
	// off-hand weapon raised while the main is still changing is lost to the switch).
	void StartEquip(int pn) { equipStage[pn] = 1; equipTic[pn] = level.maptime; }

	void EquipTick(int pn, PlayerPawn pmo)
	{
		if (equipStage[pn] == 0) return;
		let p = pmo.player;
		if (level.maptime - equipTic[pn] > 105) { equipStage[pn] = 0; return; }
		let g = Weapon(pmo.FindInventory("RSQ_Glove"));
		let o = Weapon(pmo.FindInventory("RSQ_GloveOff"));
		if (!g) { equipStage[pn] = 0; return; }
		if (equipStage[pn] == 1)
		{
			if (p.ReadyWeapon == g) { equipStage[pn] = 2; return; }
			if (p.PendingWeapon != g) { p.PendingWeapon = g; if (!p.ReadyWeapon) pmo.BringUpWeapon(); }
			return;
		}
		if (!o || p.OffhandWeapon == o) { equipStage[pn] = 0; return; }
		if (p.PendingWeapon == WP_NOCHANGE || p.PendingWeapon == null) p.PendingWeapon = o;
	}

	static RSQ_SlapperStash StashOf(PlayerPawn pmo)
	{
		let s = RSQ_SlapperStash(pmo.FindInventory("RSQ_SlapperStash"));
		if (!s) s = RSQ_SlapperStash(pmo.GiveInventoryType("RSQ_SlapperStash"));
		return s;
	}

	static void Strip(PlayerPawn pmo)
	{
		let p = pmo.player;
		bool tookReady = false;
		Array<Inventory> gone;
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			if (!w || !IsGun(w.GetClass(), pmo)) continue;
			gone.Push(w);
		}
		if (gone.Size() == 0) return;
		let stash = StashOf(pmo);
		for (int i = 0; i < gone.Size(); i++)
		{
			let w = Weapon(gone[i]);
			if (!w) continue;
			String n = w.GetClassName();
			if (stash && stash.guns.Find(n) == stash.guns.Size()) stash.guns.Push(n);
			if (p.ReadyWeapon == w) { p.ReadyWeapon = null; tookReady = true; if (stash) stash.mainGun = n; }
			if (p.OffhandWeapon == w) { p.OffhandWeapon = null; if (stash) stash.offGun = n; }
			if (p.PendingWeapon == w) p.PendingWeapon = WP_NOCHANGE;
			w.Destroy();
		}
		if (tookReady)
		{
			Weapon g = Weapon(pmo.FindInventory("RSQ_Glove"));
			// no gloves: whatever melee the game left you
			for (let it = pmo.Inv; it && !g; it = it.Inv)
			{
				let w = Weapon(it);
				if (w && !w.bOffhandWeapon && RSQM.IsSlapperClass(w.GetClass(), pmo)) g = w;
			}
			if (g) { p.PendingWeapon = g; pmo.BringUpWeapon(); }
		}
	}

	// THE GUNS COME BACK, with the ammo you have now: the gun's own pickup ammo is taken back off.
	void Restore(int pn, PlayerPawn pmo)
	{
		equipStage[pn] = 0;
		let stash = RSQ_SlapperStash(pmo.FindInventory("RSQ_SlapperStash"));
		if (!stash || (stash.guns.Size() == 0 && stash.offGun == "")) return;
		Array<Inventory> ammo; Array<int> had;
		for (let it = pmo.Inv; it; it = it.Inv) if (Ammo(it)) { ammo.Push(it); had.Push(it.Amount); }
		for (int i = 0; i < stash.guns.Size(); i++)
		{
			Class<Weapon> wc = stash.guns[i];
			if (wc && !pmo.FindInventory(wc)) pmo.GiveInventory(wc, 1);
		}
		// what the give added, taken back; ammo the player did not have before goes again
		for (int i = 0; i < ammo.Size(); i++) if (ammo[i]) ammo[i].Amount = had[i];
		for (let it = pmo.Inv; it; it = it.Inv) if (Ammo(it) && ammo.Find(it) == ammo.Size()) it.Amount = 0;
		Class<Weapon> mc = stash.mainGun;
		let mw = mc ? Weapon(pmo.FindInventory(mc)) : null;
		if (!mw)
			for (int i = 0; i < stash.guns.Size() && !mw; i++)
			{
				Class<Weapon> wc = stash.guns[i];
				let w = wc ? Weapon(pmo.FindInventory(wc)) : null;
				if (w && !w.bOffhandWeapon) mw = w;
			}
		restoreOff[pn] = stash.offGun;
		stash.guns.Clear(); stash.mainGun = ""; stash.offGun = "";
		if (mw) pmo.player.PendingWeapon = mw;
		restoreStage[pn] = 1; restoreTic[pn] = level.maptime;
	}

	// and the off-hand gun (BD22Q's off-hand copy of it) back into the off hand once the main is up
	void RestoreTick(int pn, PlayerPawn pmo)
	{
		if (restoreStage[pn] == 0) return;
		let p = pmo.player;
		if (level.maptime - restoreTic[pn] > 105) { restoreStage[pn] = 0; return; }
		if (p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon != null) return;
		restoreStage[pn] = 0;
		Class<Weapon> oc = restoreOff[pn];
		let ow = oc ? Weapon(pmo.FindInventory(oc)) : null;
		if (ow && p.OffhandWeapon != ow) p.PendingWeapon = ow;
	}
}
