// RSQ_TacticalRig -- BRUTAL DOOM'S DUAL KEY WITH A GUN IN THE OFF HAND ONLY (owner 2026-11-09 17:24: "if I have an off-hand
// weapon and an empty main hand and I press BD Dual, I want the main-hand equivalent"; rig only, not headset-confirmed).
//
// Brutal Doom 22's Dual key (+user3) is read by its own ACS (Inputs.acs: while the button is held it gives the token
// StartDualWield, one a tic), and BD22 VR Reloaded's RSQ_Dual takes the token at the start of the next tic and toggles
// (rsq/dual.zs Toggle): a gun in the main hand -> its off-hand version into the off hand; an off-hand version in the off
// hand -> the off hand back to its empty hand. So with a gun in the OFF hand and the MAIN hand empty, the key used to take
// the off hand's gun away. Now, in exactly that case, the MAIN hand gets the same gun (its main-hand version) and the off
// hand keeps its own: a gun in each hand, as the key does the other way round.
//
// HOW (by name, nothing linked): every player carries RSQTR_DualCatch while BD22 VR Reloaded is loaded (its
// RSQ_BD22OffhandService). An item the player is given passes every item he carries first (Inventory.HandlePickup), so the
// catch sees each StartDualWield as BD's ACS gives it, the same tic, before RSQ_Dual can. In the case above it swallows the
// token, and keeps swallowing them while the same press is held (BD's ACS gives one every tic), so a held key does not then
// toggle the off hand back; every other case passes the token on untouched: BD's own Dual stays as it ships.
// THE MAIN HAND TAKES THE GUN AT ONCE, the next WorldTick (Apply, from RSQTR_Rig.WorldTick), as BD22 VR itself turns a gun
// into its other version in place (rsq/dual.zs Become): the main version becomes the ready weapon and rises from its Select
// state. NOT through a pending switch: the first rig run (11-09) asked BD22 VR's "equip" (a pending switch) and it was
// cancelled before any handler saw it (no switch ran in 150 tics, cause not found: rig checks were stopped there).
//   - The off hand must hold a BD22 VR off-hand version (RSQ_Off_<gun>: a gun with one) and the main hand its empty hand
//     (the Rig's EmptyHand: Brutal Doom's fists) or nothing, with no switch already under way, and the player must own the
//     gun's main version (owning a gun owns both: BD22 VR's off-hand rule). Otherwise BD's Dual runs as before.
//   - Holster assignment does not change: the gun is the same gun (filed under its main name, MainOf) in either hand.
//   - With the gun's Dual Options row off (one hand at a time), BD22 VR's own rule then moves the gun to the main hand and
//     the off hand goes empty -- its rule, not changed here.
// NETPLAY: the button is in the usercmd and BD's ACS gives the token on every machine on the same tic; the catch runs in
// play on every machine from the same inventory, so the worlds agree.
class RSQTR_DualCatch : Inventory
{
	bool latched;     // this press already gave the main hand its gun: swallow the rest of it
	String want;      // the main version to raise on the next WorldTick ("" none)
	int wantTic, doneTic;

	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.UNCLEARABLE
	}

	override bool HandlePickup(Inventory item)
	{
		if (item && item.GetClassName() == 'StartDualWield' && Owner && Owner.player)
		{
			let pmo = PlayerPawn(Owner);
			if (latched || (pmo && Main(pmo)))
			{
				latched = true;
				item.bPickupGood = true;     // taken (and gone): RSQ_Dual never sees it
				return true;
			}
		}
		return false;
	}

	override void DoEffect()
	{
		Super.DoEffect();
		if (latched && (!Owner || !Owner.player || !(Owner.player.cmd.buttons & BT_USER3))) latched = false;
	}

	// The case above: the off hand holds a BD22 VR off-hand version, the main hand is empty, the main version is his.
	// Answers that main version's class name ("" not the case).
	static String Wanted(PlayerPawn pmo)
	{
		let p = pmo.player;
		if (!p || p.playerstate != PST_LIVE || pmo.health <= 0) return "";
		if (!ServiceIterator.Find("RSQ_BD22OffhandService").Next()) return "";
		let off = p.OffhandWeapon;
		if (!off) return "";
		String offCn = off.GetClassName();
		String mainCn = RSQTR_Rig.MainOf(offCn);
		if (mainCn ~== offCn) return "";                                     // not a BD22 VR off-hand version
		if (p.PendingWeapon && p.PendingWeapon != WP_NOCHANGE) return "";    // a switch under way: BD's own
		let r = p.ReadyWeapon;
		if (r && r != RSQTR_Rig.EmptyHand(pmo)) return "";                   // the main hand holds something
		class<Inventory> mc = mainCn;
		if (!mc || !pmo.FindInventory(mc)) return "";                        // the main version is not his
		return mainCn;
	}

	bool Main(PlayerPawn pmo)
	{
		String m = Wanted(pmo);
		if (m == "") return false;
		want = m;
		wantTic = pmo.Level.maptime;
		if (RSQTR_Rig.Flag("rsqtr_messages", pmo.player, false))
			Console.Printf("T_DUALMAIN t%d: Dual with %s in the off hand and the main hand empty (%s): the main hand takes %s (Brutal Doom's own Dual skipped)",
				wantTic, pmo.player.OffhandWeapon.GetClassName(), pmo.player.ReadyWeapon ? pmo.player.ReadyWeapon.GetClassName() : 'none', m);
		return true;
	}

	// every tic, every player (RSQTR_Rig.WorldTick): raise what a press asked for, and log the hands 10 tics later
	static void Apply()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			let pmo = players[n].mo;
			let c = RSQTR_DualCatch(pmo.FindInventory("RSQTR_DualCatch"));
			if (!c) continue;
			let p = pmo.player;
			bool msg = RSQTR_Rig.Flag("rsqtr_messages", p, false);
			if (c.doneTic > 0 && pmo.Level.maptime == c.doneTic + 10)
			{
				if (msg) Console.Printf("T_DUALMAIN t%d: 10 tics on: main %s, off %s", pmo.Level.maptime,
					p.ReadyWeapon ? p.ReadyWeapon.GetClassName() : 'none', p.OffhandWeapon ? p.OffhandWeapon.GetClassName() : 'none');
				c.doneTic = 0;
			}
			if (c.want == "") continue;
			String m = c.want;
			c.want = "";
			if (Wanted(pmo) != m) { if (msg) Console.Printf("T_DUALMAIN t%d: the hands changed since the press: nothing done", pmo.Level.maptime); continue; }
			class<Inventory> mc = m;
			let w = mc ? Weapon(pmo.FindInventory(mc)) : null;
			if (!w) continue;
			let was = p.ReadyWeapon;
			w.bOffhandWeapon = false;
			p.ReadyWeapon = w;
			p.SetPsprite(PSP_WEAPON, w.GetUpState(), false, w);
			p.PendingWeapon = WP_NOCHANGE;
			c.doneTic = pmo.Level.maptime;
			if (msg) Console.Printf("T_DUALMAIN t%d: main hand %s -> %s (rising), off hand keeps %s", pmo.Level.maptime,
				was ? was.GetClassName() : 'none', w.GetClassName(), p.OffhandWeapon ? p.OffhandWeapon.GetClassName() : 'none');
		}
	}

	// every player carries one while BD22 VR Reloaded is loaded (RSQTR_Rig.WorldTick)
	static void Ensure()
	{
		if (!ServiceIterator.Find("RSQ_BD22OffhandService").Next()) return;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			let mo = players[n].mo;
			if (!mo.FindInventory("RSQTR_DualCatch")) mo.GiveInventory("RSQTR_DualCatch", 1);
		}
	}
}
