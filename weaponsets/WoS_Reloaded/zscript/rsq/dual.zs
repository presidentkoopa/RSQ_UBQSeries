// RS dual wield (1.20, owner). Two of the same gun, one in each hand, each its own gun.
//   - Each dual-able gun has an off-hand COPY (DECORATE.rsqdual, generated): the gun itself,
//     with its own magazine, that lives in the off hand only (it never changes hands).
//   - You get a copy by picking up a second one of the gun (BD22's own rule for dual),
//     or the pistol's from the start ("Pistol Start: Start with Dual Pistols").
//   - BD22's Dual key (+user3) toggles the off hand: the copy of the gun in your main hand,
//     or back to the fist (so VR reloading of the main gun is always one press away).
//     A gun whose Dual Options entry is off does not go dual.
// Reserve ammo is shared with the gun; each copy keeps its own magazine. Firing is per hand
// (1.16) and so is reloading (1.17 flick).
class RSQ_Dual : EventHandler
{
	const MAXGUNS = 12;		// RSQ_DualTable.COUNT
	bool had[MAXPLAYERS][MAXGUNS];	// owned the gun last tic (a pickup now is a second one)
	bool forcedNoAuto[MAXPLAYERS];	// 1.21: NoAutoReload is ours while two guns are out

	static int GunIndex(Weapon w)
	{
		if (!w)
			return -1;
		for (int i = 0; i < RSQ_DualTable.COUNT; i++)
		{
			class<Actor> c = RSQ_DualTable.Gun(i);
			class<Actor> cc = RSQ_DualTable.Copy(i);
			if (c && w is c && !(cc && w is cc))
				return i;
		}
		return -1;
	}

	static bool Owns(PlayerPawn mo, int i)
	{
		class<Actor> c = RSQ_DualTable.Gun(i);
		class<Actor> cc = RSQ_DualTable.Copy(i);
		for (let it = mo.Inv; it; it = it.Inv)
			if (c && it is c && !(cc && it is cc))
				return true;
		return false;
	}

	// which gun this is the off-hand copy OF, or -1. IsCopy only says "some copy";
	// rsq/hands.zs has to know WHICH, to tell a real dual wield from one left behind.
	static int CopyIndex(Weapon w)
	{
		for (int i = 0; w && i < RSQ_DualTable.COUNT; i++)
		{
			class<Actor> cc = RSQ_DualTable.Copy(i);
			if (cc && w is cc)
				return i;
		}
		return -1;
	}

	static bool IsCopy(Weapon w)
	{
		for (int i = 0; w && i < RSQ_DualTable.COUNT; i++)
		{
			class<Actor> cc = RSQ_DualTable.Copy(i);
			if (cc && w is cc)
				return true;
		}
		return false;
	}

	static void GiveCopy(PlayerPawn mo, int i)
	{
		class<Inventory> cc = (class<Inventory>)(RSQ_DualTable.Copy(i));
		if (!cc || mo.FindInventory(cc))
			return;
		let p = mo.player;
		let pend = p.PendingWeapon;
		mo.GiveInventory(cc, 1);
		if (p.PendingWeapon != pend)
			p.PendingWeapon = pend;		// getting it never switches to it; the Dual key does
		class<Inventory> mc = (class<Inventory>)(RSQ_DualTable.Mag(i));
		if (mc)
			mo.SetInventory(mc, RSQ_DualTable.MagMax(i));
	}

	// ---- 2.0.3y THE OFF-HAND RULE (owner, BUGS_1.0 items 5 and 16, 2026-11-06) --------------------------------------
	// "anytime an axe goes into my offhand it becomes the offhand axe. picking up one axe grants both axes (but i only
	// need to see one in wheel since the code knows what hand is choosing) -- this should be the rule for all weapons
	// in bd22." So, for every gun in RSQ_DualTable (the ones with an off-hand version):
	//   - owning the gun means owning both versions: the off-hand version is given with it, loaded (owner 11-06:
	//     "Give it loaded");
	//   - whatever puts the gun in the OFF hand (a holster draw, the Wheel, a Distance Grab catch, QuestZDoom's switch
	//     hand, a pickup), it is the off-hand version there; whatever puts it in the MAIN hand, the main version. The
	//     rounds in the magazine go with it (the two magazines swap), so moving a gun never loads or empties it;
	//   - with its Dual Options row off, the gun is in one hand at a time: taking it into one hand takes it out of the
	//     other (that hand gets its empty hand), as before this rule.
	// Done here once a tic for every player, so every mod that moves weapons gets it without asking: they flip
	// bOffhandWeapon on the gun and raise it, as QuestZDoom does, and this swaps in the right version (Hands). Other
	// mods may also ask RSQ_BD22OffhandService (below). Weapons with no off-hand version (the chainsaw, the sword...)
	// are left to the engine: they go into the off hand as themselves.
	Weapon prevMain[MAXPLAYERS];
	Weapon prevOff[MAXPLAYERS];
	bool primed[MAXPLAYERS];	// had[] read once this level before any gift (a level start is no pickup)

	static bool Logs(PlayerPawn mo) { return RSQ.PlayerInt(mo, 'rsq_switch_log', 0) > 0; }

	// index of the MAIN version, by exact class (BD22's Purist guns are subclasses and are left alone)
	static int MainIndex(Weapon w)
	{
		if (!w)
			return -1;
		Name n = w.GetClassName();
		for (int i = 0; i < RSQ_DualTable.COUNT; i++)
			if (n == RSQ_DualTable.Gun(i))
				return i;
		return -1;
	}

	static int OffIndex(Weapon w)
	{
		if (!w)
			return -1;
		Name n = w.GetClassName();
		for (int i = 0; i < RSQ_DualTable.COUNT; i++)
			if (n == RSQ_DualTable.Copy(i))
				return i;
		return -1;
	}

	static Weapon Have(PlayerPawn mo, Name n)
	{
		class<Inventory> c = n;
		return c ? Weapon(mo.FindInventory(c)) : null;
	}

	// a weapon given with no ammo of its own and no switch to it (as the Rig gives BD22's single gun)
	static Weapon GiveBare(PlayerPawn mo, Name n)
	{
		let w = Have(mo, n);
		if (w)
			return w;
		class<Actor> c = n;
		if (!c)
			return null;
		let p = mo.player;
		let pend = p.PendingWeapon;
		let g = Weapon(Actor.Spawn(c, mo.pos, NO_REPLACE));
		if (!g)
			return null;
		g.AmmoGive1 = 0;
		g.AmmoGive2 = 0;
		if (!g.CallTryPickup(mo))
		{
			g.Destroy();
			return null;
		}
		if (p.PendingWeapon != pend)
			p.PendingWeapon = pend;		// getting it never switches to it
		return Have(mo, n);
	}

	// the rounds in one gun's magazine go into the other's (the moved gun keeps its own rounds)
	static void SwapMags(Weapon a, Weapon b)
	{
		if (!a || !b || !a.Ammo2 || !b.Ammo2 || a.Ammo2 == b.Ammo2)
			return;
		int x = a.Ammo2.Amount, y = b.Ammo2.Amount;
		a.Ammo2.Amount = min(y, a.Ammo2.MaxAmount);
		b.Ammo2.Amount = min(x, b.Ammo2.MaxAmount);
	}

	static Weapon EmptyHandOf(PlayerPawn mo, bool off)
	{
		let w = Have(mo, off ? 'RSQ_Hands' : 'RSQWS_Knuckles');
		if (!w && off)
		{
			mo.GiveInventory('RSQ_Hands', 1);
			w = Have(mo, 'RSQ_Hands');
		}
		return w;
	}

	// The version of gun i for that hand, owned (given bare if missing). When the other version must be given, the
	// one gun is moving: the version it leaves is taken, so a thrown gun stays thrown.
	static Weapon VersionFor(PlayerPawn mo, int i, bool off, Weapon from)
	{
		Name want = off ? RSQ_DualTable.Copy(i) : RSQ_DualTable.Gun(i);
		let w = Have(mo, want);
		if (w)
			return w;
		w = GiveBare(mo, want);
		if (w && from && from != w)
		{
			SwapMags(from, w);
			from.bOffhandWeapon = !off;
			mo.TakeInventory(from.GetClass(), 1);
		}
		return w;
	}

	// a hand's weapon turned into its other version, in place (no lowering): it rises from where it is
	void Become(PlayerPawn mo, Weapon was, Weapon now, bool off)
	{
		let p = mo.player;
		was.bOffhandWeapon = !off;
		now.bOffhandWeapon = off;
		if (off)
		{
			p.OffhandWeapon = now;
			if (p.ReadyWeapon == now)
				p.ReadyWeapon = null;
		}
		else
		{
			p.ReadyWeapon = now;
			if (p.OffhandWeapon == now)
				p.OffhandWeapon = null;
		}
		p.SetPsprite(off ? PSP_OFFHANDWEAPON : PSP_WEAPON, now.GetUpState(), false, now);
		if (p.PendingWeapon == now)
			p.PendingWeapon = WP_NOCHANGE;
		if (Logs(mo))
			Console.Printf("RSQ offhand rule t%d: %s in the %s hand -> %s", mo.Level.maptime, was.GetClassName(), off ? "off" : "main", now.GetClassName());
	}

	void Hands(PlayerPawn mo)
	{
		let p = mo.player;
		// 1. on its way into a hand (PendingWeapon): the right version is raised instead
		let pend = p.PendingWeapon;
		if (pend && pend != WP_NOCHANGE)
		{
			bool off = pend.bOffhandWeapon;
			int i = off ? MainIndex(pend) : OffIndex(pend);
			if (i >= 0)
			{
				let w = VersionFor(mo, i, off, pend);
				if (w && w != pend)
				{
					if (pend.Owner == mo)	// (not taken by VersionFor: both versions owned)
					{
						SwapMags(pend, w);
						pend.bOffhandWeapon = !off;
					}
					w.bOffhandWeapon = off;
					p.PendingWeapon = (off ? p.OffhandWeapon : p.ReadyWeapon) == w ? WP_NOCHANGE : w;
					if (Logs(mo))
						Console.Printf("RSQ offhand rule t%d: %s on its way to the %s hand -> %s", mo.Level.maptime, pend.GetClassName(), off ? "off" : "main", w.GetClassName());
				}
			}
		}
		// 2. already raised in the wrong version (QuestZDoom's switch hand and the Wheel raise at once)
		let o = p.OffhandWeapon;
		let r = p.ReadyWeapon;
		int oi = MainIndex(o);
		int ri = OffIndex(r);
		if (oi >= 0 && oi == ri)
		{
			// the two versions of one gun swapped hands: each is the right one now, the rounds stay put
			o.bOffhandWeapon = false;
			r.bOffhandWeapon = true;
			p.ReadyWeapon = o;
			p.OffhandWeapon = r;
			p.SetPsprite(PSP_WEAPON, o.GetUpState(), false, o);
			p.SetPsprite(PSP_OFFHANDWEAPON, r.GetUpState(), false, r);
			return;
		}
		if (oi >= 0)
		{
			let w = VersionFor(mo, oi, true, o);
			if (w && w != o)
			{
				if (o.Owner == mo)
					SwapMags(o, w);
				Become(mo, o, w, true);
			}
		}
		if (ri >= 0)
		{
			let w = VersionFor(mo, ri, false, r);
			if (w && w != r)
			{
				if (r.Owner == mo)
					SwapMags(r, w);
				Become(mo, r, w, false);
			}
		}
	}

	// Dual Options off for a gun: one hand at a time. The hand that just took it keeps it; the other gets its
	// empty hand, and the rounds come with the gun.
	void OneAtATime(PlayerPawn mo, int n)
	{
		let p = mo.player;
		let r = p.ReadyWeapon;
		let o = p.OffhandWeapon;
		int i = MainIndex(r);
		if (i < 0 || i != OffIndex(o) || p.PendingWeapon != WP_NOCHANGE)
			return;
		if (RSQ.PlayerInt(mo, RSQ_DualTable.CVarName(i), 0) != 0)
			return;		// dual wield allowed: a gun in each hand
		bool mainNew = prevMain[n] != r;
		bool offNew = prevOff[n] != o;
		if (mainNew == offNew)
			return;		// both at once (a level start, a load): leave it
		let e = EmptyHandOf(mo, mainNew);
		if (!e)
			return;
		SwapMags(mainNew ? o : r, mainNew ? r : o);
		p.PendingWeapon = e;
		if (Logs(mo))
			Console.Printf("RSQ offhand rule t%d: %s is one gun (Dual Options off): it moved to the %s hand", mo.Level.maptime, RSQ_DualTable.Nice(i), mainNew ? "main" : "off");
	}

	// A version not in a hand and not on its way there carries its own hand's flag again: a main version left flagged
	// for the off hand (a draw that was queued and dropped) would otherwise rise in the off hand from a slot key
	// (QuestZDoom raises by the flag). Every mod that moves a gun sets the flag again when it raises it.
	static void Tidy(PlayerPawn mo)
	{
		let p = mo.player;
		for (int i = 0; i < RSQ_DualTable.COUNT; i++)
		{
			let m = Have(mo, RSQ_DualTable.Gun(i));
			if (m && m.bOffhandWeapon && m != p.ReadyWeapon && m != p.OffhandWeapon && m != p.PendingWeapon)
				m.bOffhandWeapon = false;
			let c = Have(mo, RSQ_DualTable.Copy(i));
			if (c && !c.bOffhandWeapon && c != p.ReadyWeapon && c != p.OffhandWeapon && c != p.PendingWeapon)
				c.bOffhandWeapon = true;
		}
	}

	// 2.0.3y (owner 11-06: "we need to start with some revolver ammo, whatever it is. each time i get a silvergun i have
	// to reload it"). The Silvergun (BrutalRevolver) fires BD22's pistol rounds (Clip1, 3 a shot) from its own cylinder
	// (BrutalRevolverCylinder, 0-6 shots), and a picked-up one arrived with the cylinder EMPTY (Inventory.Amount 0,
	// AmmoGive2 0: only the 18 reserve rounds, so a reload first). Now:
	//   - a Silvergun you did not have arrives loaded (a full cylinder, as the off-hand version does);
	//   - every player starts with one Silvergun pickup's rounds (18 Clip1, BrutalRevolver.dec AmmoGive1) on top of
	//     BD22's own start, once a life, at the start of a map (RSQ_StartRounds remembers it).
	void Silvergun(PlayerPawn mo, int n)
	{
		int MOON = 10;	// RSQ_DualTable index of BrutalRevolver
		if (primed[n] && !had[n][MOON] && Have(mo, RSQ_DualTable.Gun(MOON)))
		{
			Name cn = 'BrutalRevolverCylinder';
			class<Inventory> cc = cn;
			if (cc && mo.CountInv(cc) < 6)
				mo.SetInventory(cc, 6);
			if (Logs(mo))
				Console.Printf("RSQ silvergun t%d: picked up, cylinder loaded (6)", mo.Level.maptime);
		}
		if (mo.CountInv('RSQ_StartRounds') == 0 && mo.Level.maptime < 35)
		{
			mo.GiveInventory('RSQ_StartRounds', 1);
			Name an = 'Clip1';
			class<Inventory> ac = an;
			if (ac)
				mo.GiveInventory(ac, 18);
			if (Logs(mo))
				Console.Printf("RSQ silvergun t%d: start rounds, Clip1 +18 -> %d", mo.Level.maptime, ac ? mo.CountInv(ac) : -1);
		}
	}

	// owning a gun means owning its off-hand version (loaded); the axe's only on a pickup (a thrown axe stays thrown)
	void GrantBoth(PlayerPawn mo, int n)
	{
		for (int i = 0; i < RSQ_DualTable.COUNT; i++)
		{
			bool own = Have(mo, RSQ_DualTable.Gun(i)) != null;	// the gun itself (not BD22's Purist subclass)
			if (own && (i != RSQ_DualTable.AXE || primed[n] && !had[n][i]))
				GiveCopyLoaded(mo, i);
		}
	}

	// 2.0.3y (owner 11-06, "Give it loaded"): the off-hand version comes with a full magazine (GiveCopy's own fill)
	static void GiveCopyLoaded(PlayerPawn mo, int i)
	{
		class<Inventory> cc = (class<Inventory>)(RSQ_DualTable.Copy(i));
		if (!cc || mo.FindInventory(cc))
			return;
		GiveCopy(mo, i);
		if (Logs(mo))
			Console.Printf("RSQ offhand rule t%d: %s picked up: its off-hand version comes with it", mo.Level.maptime, RSQ_DualTable.Nice(i));
	}

	override void WorldTick()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo)
				continue;
			let mo = players[n].mo;
			let p = mo.player;
			if (p.playerstate != PST_LIVE)
				continue;

			// Pistol Start
			if (RSQ.PlayerInt(mo, 'rsq_dual_start', 1) != 0 && Owns(mo, 0))
				GiveCopy(mo, 0);
			// BD22's own "second one picked up" tokens count too
			static const Name hasDual[] = { 'HasDualPistol', 'None', 'HasDualSMG', 'HasDualMP40', 'HasDualRifle', 'HasDualPlasma' };
			for (int i = 0; i < hasDual.Size() && i < RSQ_DualTable.COUNT; i++)
			{
				if (hasDual[i] == 'None')
					continue;
				class<Inventory> tc = hasDual[i];
				if (tc && mo.CountInv(tc) > 0 && Owns(mo, i))
					GiveCopy(mo, i);
			}

			// 2.0.3y the off-hand rule (above)
			if (!primed[n])
			{
				for (int i = 0; i < RSQ_DualTable.COUNT; i++)
					had[n][i] = Owns(mo, i);
				primed[n] = true;
			}
			GrantBoth(mo, n);
			// (this pack has no Silvergun: BD22 VR's Silvergun(mo, n) is not called)
			Hands(mo);
			OneAtATime(mo, n);
			Tidy(mo);
			prevMain[n] = p.ReadyWeapon;
			prevOff[n] = p.OffhandWeapon;

			// 1.21 (owner): with a gun in each hand only the flick reloads. BD22's own "no auto
			// reload" token is forced on while both hands hold guns, and set back to the player's
			// BD22 option (bd_noautoreload) when they don't.
			bool two = RSQ_Flick.IsGun(p.OffhandWeapon);	// a gun in the off hand: it reloads only by flick
			if (two)
			{
				if (mo.CountInv('NoAutoReload') < 1)
					mo.SetInventory('NoAutoReload', 1);
				forcedNoAuto[n] = true;
			}
			else if (forcedNoAuto[n])
			{
				forcedNoAuto[n] = false;
				mo.SetInventory('NoAutoReload', RSQ.PlayerInt(mo, 'bd_noautoreload', 0) != 0 ? 1 : 0);
			}

			// the Dual key (BD22: +user3 gives StartDualWield; the guns no longer take it)
			if (mo.CountInv('StartDualWield') > 0)
			{
				mo.TakeInventory('StartDualWield', 0x7fffffff);
				Toggle(mo);
			}

			for (int i = 0; i < RSQ_DualTable.COUNT; i++)
				had[n][i] = Owns(mo, i);
		}
	}

	static void Toggle(PlayerPawn mo)
	{
		let p = mo.player;
		if (IsCopy(p.OffhandWeapon))
		{
			let fist = Weapon(mo.FindInventory('RSQ_Hands'));
			if (!fist)
			{
				mo.GiveInventory('RSQ_Hands', 1);
				fist = Weapon(mo.FindInventory('RSQ_Hands'));
			}
			if (fist)
				p.PendingWeapon = fist;
			return;
		}
		int i = GunIndex(p.ReadyWeapon);
		if (i < 0)
			return;
		if (RSQ.PlayerInt(mo, RSQ_DualTable.CVarName(i), 0) == 0)
		{
			mo.A_Print(String.Format("Dual %s is off in Dual Options", RSQ_DualTable.Nice(i)));
			return;
		}
		class<Inventory> cc = (class<Inventory>)(RSQ_DualTable.Copy(i));
		let w = cc ? Weapon(mo.FindInventory(cc)) : null;
		if (!w)
		{
			mo.A_Print(String.Format("Find a second %s to dual wield it", RSQ_DualTable.Nice(i)));
			return;
		}
		p.PendingWeapon = w;
	}

	// a BD22 weapon pickup taken by a player who already had that gun: a second one
	override void WorldThingDestroyed(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || !(a is 'Inventory') || Inventory(a).Owner)
			return;
		int i = RSQ_DualTable.PickupGun(a.GetClassName());
		if (i < 0)
			return;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo || !had[n][i])
				continue;
			let mo = players[n].mo;
			if (mo.Distance3D(a) <= mo.radius + a.radius + 16)
				GiveCopy(mo, i);
		}
	}
}

// 2.0.3y THE OFF-HAND RULE FOR OTHER MODS (owner, BUGS_1.0 items 5 and 16). Find it by name, never by class:
//   let it = ServiceIterator.Find("RSQ_BD22OffhandService"); let s = it.Next();   // null without BD22 VR Reloaded
// Nothing has to call it: RSQ_Dual swaps in the right version every tic for whatever mod moved the gun. It is here so
// a list of weapons (the Wheel) can show ONE entry per gun and so a mod can put a gun in a hand the BD22 way at once.
//   GetString/GetStringUI("main.of", class)   the gun an off-hand version stands for ("RSQ_Off_BrutalAxe" -> "BrutalAxe");
//                                             any other class name comes back as it is
//   GetString/GetStringUI("off.of", class)    the off-hand version of a gun ("BrutalAxe" -> "RSQ_Off_BrutalAxe"), "" if none
//   GetInt/GetIntUI("is.off", class)          1: an off-hand version (leave it out of a list; show its gun's entry)
//   GetInt("equip", class, hand, 0, pawn)     (play, on every machine: from a network event) the gun (either version's
//                                             name) into hand 0 main / 1 off, as its version for that hand. 1 done or
//                                             already there, 0 not a BD22 gun with an off-hand version (do your own).
class RSQ_BD22OffhandService : Service
{
	clearscope static int Find(String cls, bool off)
	{
		Name n = cls;
		for (int i = 0; i < RSQ_DualTable.COUNT; i++)
			if (n == (off ? RSQ_DualTable.Copy(i) : RSQ_DualTable.Gun(i)))
				return i;
		return -1;
	}

	static clearscope String Answer(String request, String cls)
	{
		Name n = cls;
		for (int i = 0; i < RSQ_DualTable.COUNT; i++)
		{
			if (request ~== "main.of" && n == RSQ_DualTable.Copy(i))
				return RSQ_DualTable.Gun(i);
			if (request ~== "off.of" && n == RSQ_DualTable.Gun(i))
				return RSQ_DualTable.Copy(i);
		}
		return request ~== "main.of" ? cls : "";
	}

	override String GetString(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		return Answer(request, stringArg);
	}

	override String GetStringUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		return Answer(request, stringArg);
	}

	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request ~== "is.off")
			return Answer("main.of", stringArg) != stringArg ? 1 : 0;
		return 0;
	}

	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request ~== "is.off")
			return Answer("main.of", stringArg) != stringArg ? 1 : 0;
		if (!(request ~== "equip"))
			return 0;
		let mo = PlayerPawn(objectArg);
		if (!mo || !mo.player || mo.health <= 0)
			return 0;
		bool off = intArg == 1;
		int i = Find(stringArg, false);
		if (i < 0)
			i = Find(stringArg, true);
		if (i < 0)
			return 0;
		let p = mo.player;
		let w = RSQ_Dual.VersionFor(mo, i, off, null);
		if (!w)
			return 0;
		if ((off ? p.OffhandWeapon : p.ReadyWeapon) == w)
			return 1;
		w.bOffhandWeapon = off;
		p.PendingWeapon = w;
		if (RSQ_Dual.Logs(mo))
			Console.Printf("RSQ offhand service t%d: %s into the %s hand as %s", mo.Level.maptime, stringArg, off ? "off" : "main", w.GetClassName());
		return 1;
	}
}

class RSQ_StartRounds : RSVR_Token {}	// 2.0.3y: this life's start rounds were given (RSQ_Dual.Silvergun)
