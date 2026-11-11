// items.zs -- RSQ Gun Cards: THE CARDS OF WEAPONS THAT ARE NOT GUNS (owner 2026-11-10 12:53: "the claim that there is a
// card for every weapon in the RSQ series... im not sure is true. i'd like it to be.")
//
// A gun's card counts its rounds (card.zs Loaded). A weapon with no ammo pile (no Ammo1) is an ITEM: a melee weapon or a
// tool held in the hand. Checking your watch with one shows its item card (side.zs BuildItem): its name and what it holds,
// asked of the mod that made it by name, with the status rows (health, armour, keys) under them, as the status card gave
// these weapons before (owner 11-06, BUGS_1.0 #24). Two items have a count that also goes on the small card in a gun's
// place: the road flares left and the cigarettes left.
//
//   class                        top row                  big count            asked of (by name)
//   UBQS_Saber, UBQS_SaberOff    SABER, LIT / OFF         -                    UBQS_SaberService "saber.lit" (intArg the hand)
//   RSQFF_Held                   FLARE, LIT / UNLIT       flares left          RSQFF_Service "flare.phase", "flare.count"
//   RSQFF_Torch                  LIGHT, ON / OFF          battery, percent     RSQFF_TorchService "torch.phase", "battery"
//   RSQTR_CigWeapon              CIGARETTES               cigarettes left      the pocket's RSQTR_CigPack (no service answers it)
//   any other item               its name (its tag)       -                    -
// "Any other" is RSQ Melee's gloves, RSQ Saber's Force hand, the ShieldSaw, the whip, the Zippo, Brutal Doom's axe,
// chainsaw and Dragonslayer, and any pack's melee weapon. The empty hands (card.zs EmptyHand) keep the status card.
// The item card: the saber, flare and flashlight cards shown on the rig 11-10 night (design/rigtest_2026-11-10/RESULTS_FIX.md 5),
// rig only, not headset-confirmed; the other items code only.

class RSQGC_Items play
{
	// an item: a weapon with no ammo pile to count
	static clearscope bool IsItem(Weapon w) { return w && !w.Ammo1; }

	// an item whose count also goes on the small card, as a gun's rounds (the Advanced spot rows edit its card too)
	static clearscope bool SmallCount(Weapon w)
	{
		if (!IsItem(w)) return false;
		Name n = w.GetClassName();
		return n == 'RSQFF_Held' || n == 'RSQTR_CigWeapon';
	}

	private static int Pn(Weapon w) { return (w && w.Owner && w.Owner.player) ? w.Owner.PlayerNumber() : -1; }
	private static int Hand(Weapon w) { return (w.Owner && w.Owner.player && w.Owner.player.OffhandWeapon == w) ? 1 : 0; }
	private static int Ask(String svc, String req, int intArg, Object obj = null)
	{
		let s = ServiceIterator.Find(svc).Next();
		return s ? s.GetInt(req, "", intArg, 0, obj) : -1;
	}

	// the count, -1 none
	static int Count(Weapon w)
	{
		if (!IsItem(w) || Pn(w) < 0) return -1;
		Name n = w.GetClassName();
		if (n == 'RSQFF_Held') return Ask("RSQFF_Service", "flare.count", Pn(w));
		if (n == 'RSQFF_Torch')
		{
			int pm = Ask("RSQFF_TorchService", "battery", Pn(w));
			return pm >= 0 ? (pm + 5) / 10 : -1;
		}
		if (n == 'RSQTR_CigWeapon')
		{
			// a String first: a quoted class name is resolved when the script compiles (card.zs Grenades)
			String cn = "RSQTR_CigPack";
			class<Inventory> c = cn;
			return c ? w.Owner.CountInv(c) : -1;
		}
		return -1;
	}

	// the top row's name: short where the state must fit beside it (25 small units), else the weapon's own name
	static String Label(Weapon w)
	{
		Name n = w.GetClassName();
		if (n == 'UBQS_Saber' || n == 'UBQS_SaberOff') return "SABER";
		if (n == 'RSQFF_Held') return "FLARE";
		if (n == 'RSQFF_Torch') return "LIGHT";
		if (n == 'RSQTR_CigWeapon') return "CIGARETTES";
		return RSQGC_GunCard.NameOf(w);
	}

	// what it is doing, right of the name, and its colour; "" none
	static String, int State(Weapon w)
	{
		Name n = w.GetClassName();
		if (n == 'UBQS_Saber' || n == 'UBQS_SaberOff')
		{
			int lit = Ask("UBQS_SaberService", "saber.lit", Hand(w), w.Owner);
			if (lit == 1) return "LIT", RSQGC_SideCard.C_GREEN;
			if (lit == 0) return "OFF", RSQGC_SideCard.C_DARK;
		}
		else if (n == 'RSQFF_Held')
		{
			int ph = Ask("RSQFF_Service", "flare.phase", Pn(w));
			if (ph == 2) return "LIT", RSQGC_SideCard.C_ORANGE;
			if (ph == 1) return "UNLIT", RSQGC_SideCard.C_GREY;
		}
		else if (n == 'RSQFF_Torch')
		{
			int ph = Ask("RSQFF_TorchService", "torch.phase", Pn(w));
			if (ph == 2) return "ON", RSQGC_SideCard.C_WHITE;
			if (ph == 1) return "OFF", RSQGC_SideCard.C_DARK;
		}
		return "", -1;
	}

	// what the item card says, for its signature
	static String Sig(Weapon w)
	{
		String st; int col;
		[st, col] = State(w);
		return String.Format(" i%s %d", st, Count(w));
	}
}
