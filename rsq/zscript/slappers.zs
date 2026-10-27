// SLAPPERS ONLY (rsq_slappers, a server setting, off by default).
//
// Your guns are taken at the start of each level and no gun can be picked up. You keep, or are
// given: the boxing gloves, both sabers and the ShieldSaw when those mods are loaded (found by
// name), the Force hand, and Brutal Doom's fists, axe and sword. Ammo stays where it lies.
//
// Outside it, rsq_gloves 1 hands you the gloves at the start of each level (default 0: never).
class RSQ_NoPickup : Actor
{
	// what a gun pickup becomes: nothing, gone on its first tic
	Default { +NOINTERACTION +NOBLOCKMAP +NOSECTOR RenderStyle "None"; }
	States { Spawn: TNT1 A 1; Stop; }
}

class RSQ_SlappersHandler : EventHandler
{
	static bool On() { return RSQM.SVI("rsq_slappers", 0) != 0; }

	override void CheckReplacement(ReplaceEvent e)
	{
		if (!On() || e.IsFinal) return;
		// the class that will really spawn, after every replacement so far
		Class<Actor> c = e.Replacement ? e.Replacement : e.Replacee;
		if (!IsGun(c)) return;
		e.Replacement = "RSQ_NoPickup";
		e.IsFinal = true;
	}

	static bool IsGun(Class<Actor> c)
	{
		let w = (Class<Weapon>)(c);
		return w && !RSQM.IsSlapperClass(c);
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

	int dueTic[MAXPLAYERS];

	override void WorldTick()
	{
		bool slap = On();
		bool gloves = slap || RSQM.SVI("rsq_gloves", 0) != 0;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			let pmo = players[pn].mo;
			if (dueTic[pn] > 0 && level.maptime >= dueTic[pn])
			{
				dueTic[pn] = 0;
				if (gloves) GiveGloves(pmo);
				if (slap) { Strip(pmo); GiveKit(pmo); }
			}
			// AND IT STAYS THAT WAY: whatever hands you a gun later (a script, a mod's own
			// give, a cheat) loses it within a quarter of a second
			else if (slap && (level.maptime % 8) == pn % 8) Strip(pmo);
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
		// by name: each one only if its mod is loaded
		Give(pmo, "UBQS_Saber");
		Give(pmo, "UBQS_SaberOff");
		Give(pmo, "Melee_Attacks");
		Give(pmo, "BrutalAxe");
		Give(pmo, "DSweap");
		// the ShieldSaw is handed out by its own mod (it hangs on your shoulder); nothing to do
		let p = pmo.player;
		// an empty main hand takes the gloves
		if (!p.ReadyWeapon || IsGun(p.ReadyWeapon.GetClass()))
		{
			let g = Weapon(pmo.FindInventory("RSQ_Glove"));
			if (g) { p.PendingWeapon = g; pmo.BringUpWeapon(); }
		}
	}

	static void Strip(PlayerPawn pmo)
	{
		let p = pmo.player;
		bool tookReady = false;
		Array<Inventory> gone;
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			if (!w || !IsGun(w.GetClass())) continue;
			// a gun's sister (powered-up twin) goes with it
			gone.Push(w);
		}
		for (int i = 0; i < gone.Size(); i++)
		{
			let w = Weapon(gone[i]);
			if (!w) continue;
			if (p.ReadyWeapon == w) { p.ReadyWeapon = null; tookReady = true; }
			if (p.OffhandWeapon == w) p.OffhandWeapon = null;
			if (p.PendingWeapon == w) p.PendingWeapon = WP_NOCHANGE;
			w.Destroy();
		}
		if (tookReady)
		{
			let g = Weapon(pmo.FindInventory("RSQ_Glove"));
			if (!g) g = Weapon(RSQM.FindByName(pmo, "Melee_Attacks"));
			if (g) { p.PendingWeapon = g; pmo.BringUpWeapon(); }
		}
	}
}
