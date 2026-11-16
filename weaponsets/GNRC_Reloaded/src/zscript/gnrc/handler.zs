// GNRC_Reloaded's own handler (owner's list 2026-11-16 03:44, "all of it"):
//   - the start kit for ANY player class (item 7): GNRC's player class starts with the Beretta, the knuckle and 50 rounds
//     of 9 mm. Another mod's player class (some gameplay mods set their own) starts with Doom's guns: each of those that
//     this pack replaces becomes this pack's gun (Doom's Pistol -> the Beretta, Doom's Fist -> the knuckle...), Doom's
//     bullets become 9 mm, and the kit is made whole. Its own guns and items are left alone. Once a life (a token that
//     travels with the inventory and goes with it on a pistol start), so "Start With Two Pistols" (RSQ_Dual) sees the
//     Beretta as it does with GNRC's own class;
//   - BD22 VR's held-trigger fix on every player (RSQGW_TriggerHeld, gun.zs, item 4);
//   - Start With Two Pistols (rsq_dual_start, on; owner 2026-11-16 03:51 B): at the start of a life the off hand takes the
//     second Beretta, with this pack's player class or any other; off, the start is one pistol (build.py's dual.zs patch);
//   - the rifle's underbarrel launcher (item 12): hidden while "Rifle Underbarrel Launcher" is off, the off trigger with
//     the off hand on the handguard launches a grenade while it is on.
// Logs (rsq_switch_log 1, the pack's debug log): "RSQGW kit", "RSQGW launcher", "RSQGW twin".

class RSQGW_GLGo : Inventory { Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE; +INVENTORY.UNTOSSABLE; +INVENTORY.QUIET } }
class RSQGW_KitGiven : Inventory { Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE; +INVENTORY.UNTOSSABLE; +INVENTORY.QUIET } }

class RSQGW_Handler : EventHandler
{
	const GL_EVERY = 35;		// tics between two launches (one a second)
	int glNext[MAXPLAYERS];
	int dualBy[MAXPLAYERS];		// Start With Two Pistols: the off hand takes the second Beretta by this tic (0: not wanted)
	bool offPrev[MAXPLAYERS];
	Array<int> twFrom, twTo;	// the rifle's sprites -> their no-launcher twins (MODELDEF.rsqgl, tools/build.py)

	static bool LauncherOn()
	{
		let c = CVar.FindCVar('rsqgw_rifle_gl');
		return c && c.GetBool();
	}
	static bool Logs(PlayerPawn mo)
	{
		let c = mo && mo.player ? CVar.GetCVar('rsq_switch_log', mo.player) : null;
		return c && c.GetInt() > 0;
	}

	// ---------------------------------------------------------------- the start kit (item 7)
	override void PlayerEntered(PlayerEvent e) { Kit(e.PlayerNumber); }
	override void PlayerRespawned(PlayerEvent e) { Kit(e.PlayerNumber); }

	void Kit(int n)
	{
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n])
			return;
		let mo = players[n].mo;
		if (!mo || mo.CountInv('RSQGW_KitGiven') > 0)
			return;
		mo.GiveInventory('RSQGW_KitGiven', 1);
		dualBy[n] = level.maptime + 105;	// a start: the two pistols, once the Beretta is up (WorldTick)
		if (mo is 'RSQGW_Player')
			return;		// this pack's own class: its StartItems are the kit
		let p = mo.player;
		bool swapped = false;
		// Doom's guns this pack replaces become this pack's (the exact Doom class only: a mod's own guns stay)
		Array<Inventory> doom;
		for (let i = mo.Inv; i; i = i.Inv)
		{
			if (!(i is 'Weapon'))
				continue;
			class<Weapon> rep = (class<Weapon>)(Actor.GetReplacement(i.GetClass()));
			String rn = "";
			if (rep)
				rn = rep.GetClassName();
			if (rep && rep != i.GetClass() && rn.Left(6) == "RSQGW_")
				doom.Push(i);
		}
		for (int k = 0; k < doom.Size(); k++)
		{
			let w = Weapon(doom[k]);
			if (!w)
				continue;
			class<Actor> rep = Actor.GetReplacement(w.GetClass());
			if (Logs(mo))
				Console.Printf("RSQGW kit: %s -> %s", w.GetClassName(), rep.GetClassName());
			if (p && p.ReadyWeapon == w)
				swapped = true;
			Name rname = rep.GetClassName();
			mo.TakeInventory(w.GetClass(), w.Amount);
			RSQ_Dual.GiveBare(mo, rname);	// no ammo of its own and no switch (as Doom's start items: emptied first)
		}
		// Doom's bullets are this pack's 9 mm (Clip is a spawner of 9 mm or rifle rounds here)
		int clips = mo.CountInv('Clip');
		if (clips > 0)
		{
			mo.TakeInventory('Clip', clips);
			mo.GiveInventory('RSQGW_PistolAmmo', clips);
		}
		// the kit, whole (what GNRC's own class starts with)
		RSQ_Dual.GiveBare(mo, 'RSQGW_Knuckle');
		RSQ_Dual.GiveBare(mo, 'RSQGW_Beretta');
		int have = mo.CountInv('RSQGW_PistolAmmo');
		if (have < 50)
			mo.GiveInventory('RSQGW_PistolAmmo', 50 - have);
		if (p && (swapped || !p.ReadyWeapon || p.ReadyWeapon is 'Fist'))
			mo.A_SelectWeapon('RSQGW_Beretta');
		if (Logs(mo))
			Console.Printf("RSQGW kit: player %d (%s): Beretta %d (loaded %d), knuckle %d, 9 mm %d", n, mo.GetClassName(),
				mo.CountInv('RSQGW_Beretta'), mo.CountInv('RSQGW_PistolMag'), mo.CountInv('RSQGW_Knuckle'), mo.CountInv('RSQGW_PistolAmmo'));
	}

	// ---------------------------------------------------------------- every tic
	override void WorldTick()
	{
		bool gl = LauncherOn();
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo)
				continue;
			let mo = players[n].mo;
			let p = mo.player;
			if (mo.CountInv('RSQGW_TriggerHeld') <= 0)
				mo.GiveInventory('RSQGW_TriggerHeld', 1);
			bool trig = (p.cmd.buttons & BT_OFFHANDATTACK) != 0;
			bool press = trig && !offPrev[n];
			offPrev[n] = trig;
			// the launcher: the off trigger pressed with the off hand on the rifle's handguard (the engine's two-hand
			// grip), the rifle up and ready, one a second
			if (gl && press && p.ReadyWeapon is 'RSQGW_ARifle' && !p.ReadyWeapon.bOffhandWeapon && mo.health > 0
				&& RSVR_VRHand.InVR(mo) && RSVR_VRHand.Steadied(mo) && (p.WeaponState & WF_WEAPONREADY)
				&& level.maptime >= glNext[n] && mo.CountInv('RSQGW_GLGo') <= 0)
			{
				mo.GiveInventory('RSQGW_GLGo', 1);
				glNext[n] = level.maptime + GL_EVERY;
				if (Logs(mo))
					Console.Printf("RSQGW launcher t%d: off trigger on the handguard: launch (rockets %d)", level.maptime, mo.CountInv('RocketAmmo'));
			}
			else if (press && Logs(mo) && p.ReadyWeapon is 'RSQGW_ARifle')
				Console.Printf("RSQGW launcher t%d: off trigger, no launch (option %d, steadied %d, ready %d)", level.maptime, gl,
					RSVR_VRHand.Steadied(mo), (p.WeaponState & WF_WEAPONREADY) != 0);
			// Start With Two Pistols: the second Beretta into the off hand, as the Dual key does (RSQ_Dual.Toggle)
			if (dualBy[n] > 0)
			{
				let cp = mo.FindInventory('RSQ_Off_RSQGW_Beretta');
				if (level.maptime > dualBy[n] || RSQ.PlayerInt(mo, 'rsq_dual_start', 1) == 0 || RSQ.PlayerInt(mo, 'rsq_dual_0', 1) == 0
					|| p.OffhandWeapon is 'RSQ_Off_RSQGW_Beretta')
					dualBy[n] = 0;
				else if (cp && p.ReadyWeapon is 'RSQGW_Beretta' && !p.ReadyWeapon.bOffhandWeapon && (p.WeaponState & WF_WEAPONREADY)
					&& p.PendingWeapon == WP_NOCHANGE && (!p.OffhandWeapon || p.OffhandWeapon is 'RSQ_Hands'))
				{
					RSQ_Dual.Toggle(mo);
					dualBy[n] = 0;
					if (Logs(mo))
						Console.Printf("RSQGW start t%d: Start With Two Pistols: the second Beretta into the off hand", level.maptime);
				}
			}
			// the launcher hidden while the option is off: the rifle wears its no-launcher frames, in either hand
			Wear(p, PSP_WEAPON, !gl);
			Wear(p, PSP_OFFHANDWEAPON, !gl);
		}
	}

	// after the weapons have ticked this tic (WorldTick comes after the players think, as BD22 VR's rsr_m203.zs Draw):
	// whatever rifle frame is showing, its twin without the launcher, or back
	void Wear(PlayerInfo p, int layer, bool hide)
	{
		let psp = p.FindPSprite(layer);
		if (!psp || !(psp.Caller is 'RSQGW_ARifle'))
			return;
		if (twFrom.Size() == 0)
		{
			Array<Name> f, t;
			RSQGW_GLTwin.Names(f, t);
			for (int k = 0; k < f.Size(); k++)
			{
				twFrom.Push(Actor.GetSpriteIndex(f[k]));
				twTo.Push(Actor.GetSpriteIndex(t[k]));
			}
		}
		int s = psp.Sprite;
		int k = hide ? twFrom.Find(s) : twTo.Find(s);
		if (k >= twFrom.Size())
			return;
		psp.Sprite = hide ? twTo[k] : twFrom[k];
	}
}

// AN EXPLOSION OF THIS PACK (the rocket, the rifle's grenade; item 9): GNRC's Radius_Quake shook the view. Here the
// blast is felt in the hands instead, as the basics' grenade does it (RSQB_GN_Buzzer: a controller buzz scaled by RSQ
// Accessibility's Rumble Strength, asking its Rumble Backup by name when that is on). Both controllers, for the console
// player inside the quake's tremor radius (Radius_Quake's units of 64), stronger closer. The view never moves.
class RSQGW_Blast play
{
	static void Felt(Actor src, int intensity, int tics, int tremrad)
	{
		if (!src || consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer])
			return;
		let pmo = players[consoleplayer].mo;
		if (!pmo)
			return;
		double r = tremrad * 64.0;
		double d = src.Distance2D(pmo);
		if (d >= r)
			return;
		double s = clamp(intensity / 3.0 * (1.0 - d / r), 0.15, 1.0);
		RSQB_GN_Buzzer.Start(pmo, 0, s, tics);
		RSQB_GN_Buzzer.Start(pmo, 1, s, tics);
		if (RSQGW_Handler.Logs(pmo))
			Console.Printf("RSQGW blast t%d: %s at %.0f units: both hands buzz %.2f for %d tics, no quake", src.Level.maptime, src.GetClassName(), d, s, tics);
	}
}
