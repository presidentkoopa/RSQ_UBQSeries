// spots.zs -- RSQ Gun Cards: THE SMALL CARD'S SPOT PER GUN (owner 2026-11-06: "save this card's position for this
// weapon ... we allow people to make their own best solution").
//
// One saved spot per weapon class (every mod's guns get their own), relative to the hand: the same three numbers the
// Placement sliders give every gun (Small Card Up / Side in degrees, In in cm). A gun with no saved spot uses those.
//
// WHAT A SPOT CAN BE (how the card is drawn, card.zs). Every piece of the small card is a voxel baked with its place on
// the hand. Per tic the engine lets a layer turn its model about the model origin on two axes only, psp.x (yaw about
// the hand's up) and psp.y (pitch about the hand's right) (hw_weapon.cpp:108: the third, roll, is a fixed 0); the origin
// is 30 cm behind and 5 cm above the controller (models.cpp:227), so a turn also carries the card round it (about
// 0.37 cm a degree). In is a choice between baked copies, 1.5 cm apart, -6 to +6 cm (tools/gen_cards.py DEPTHS).
// So a spot is: Up (pitch, -60..60), Side (yaw, -60..60), In (-6..6, clamped: further needs a re-bake). No roll, and no
// turn of the card about its own centre separate from where it sits: neither has a way to draw without a re-bake.
//
// STORE: rsqgc_spots, a nosave string (this machine only; never in the userinfo, which overflowed for the Tactical
// Rig's profiles, d_netinfo.cpp "User info descriptor too big"; archived in the ini like any client setting, so it
// survives saves, maps and sessions). Format ";class=side,up,in;class=..." with lower-case class names. Our own cap is
// MAXLEN characters (~120 guns at ~32 each); over it the oldest spot is dropped. Netplay: each player's spots live on
// his own machine and only move his own cards (the cards are drawn for the console player only).
//
// THE OFF HAND (2026-11-10). The Advanced rows edit the gun in the hand Edit Spot For picks (rsqgc_spot_hand). BD22 VR's
// off-hand copy of a gun is another class (RSQ_Off_<gun>); with no spot of its own it uses its gun's, so a spot set
// once serves the gun in either hand: the copy is the same mesh drawn mirrored on the other hand, and the off-hand card
// is mirrored with it, so the same turns should land in the mirrored place on that wrist (from the code, not shown).
// Set on the copy, its own spot wins.
// Any other pack's gun is the same class in either hand, so it has one spot for both.
class RSQGC_Spots
{
	const MAXLEN = 4000;
	const SIDE_MAX = 60.0;
	const UP_MAX = 60.0;
	const IN_MAX = 6.0;

	static clearscope String Store()
	{
		let c = CVar.FindCVar("rsqgc_spots");
		return c ? c.GetString() : "";
	}

	static clearscope String Key(String cls) { return cls.MakeLower(); }

	// the spot saved for this class: found, side, up, in
	static clearscope bool, double, double, double Get(String cls)
	{
		if (cls == "") return false, 0, 0, 0;
		String s = Store();
		String k = ";" .. Key(cls) .. "=";
		int at = s.IndexOf(k);
		if (at < 0) return false, 0, 0, 0;
		int from = at + k.Length();
		int end = s.IndexOf(";", from);
		if (end < 0) end = s.Length();
		String v = s.Mid(from, end - from);
		Array<String> f;
		v.Split(f, ",");
		if (f.Size() < 3) return false, 0, 0, 0;
		return true, clamp(f[0].ToDouble(), -SIDE_MAX, SIDE_MAX), clamp(f[1].ToDouble(), -UP_MAX, UP_MAX), clamp(f[2].ToDouble(), -IN_MAX, IN_MAX);
	}

	// BD22 VR's off-hand copy (RSQ_Off_<gun>): the gun it copies, "" for any other class
	static clearscope String CopyOf(String cls)
	{
		if (!(cls.Left(8) ~== "RSQ_Off_")) return "";
		return cls.Mid(8);
	}

	// where a gun's spot comes from: 1 its own, 2 the gun an off-hand copy copies, 0 the Placement sliders
	static clearscope int, double, double, double Find(String cls)
	{
		bool ok; double sd, up, inCm;
		[ok, sd, up, inCm] = Get(cls);
		if (ok) return 1, sd, up, inCm;
		[ok, sd, up, inCm] = Get(CopyOf(cls));
		if (ok) return 2, sd, up, inCm;
		return 0, Num("rsqgc_side"), Num("rsqgc_up"), clamp(Num("rsqgc_in"), -IN_MAX, IN_MAX);
	}

	// the spot a gun's card uses now: its saved one, else its gun's (an off-hand copy), else the Placement sliders
	static clearscope double, double, double SpotFor(String cls)
	{
		int from; double sd, up, inCm;
		[from, sd, up, inCm] = Find(cls);
		return sd, up, inCm;
	}
	static clearscope double Num(String n) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : 0; }

	// the store without this class
	static clearscope String Without(String s, String cls)
	{
		String k = ";" .. Key(cls) .. "=";
		int at = s.IndexOf(k);
		if (at < 0) return s;
		int end = s.IndexOf(";", at + 1);
		if (end < 0) return s.Left(at);
		return s.Left(at) .. s.Mid(end);
	}

	// save a spot for this class (newest last; the oldest dropped past MAXLEN)
	static clearscope void Save(String cls, double sd, double up, double inCm)
	{
		if (cls == "") return;
		let c = CVar.FindCVar("rsqgc_spots");
		if (!c) return;
		String s = Without(c.GetString(), cls);
		if (s == "") s = ";";
		s = s .. String.Format("%s=%.1f,%.1f,%.1f;", Key(cls), clamp(sd, -SIDE_MAX, SIDE_MAX), clamp(up, -UP_MAX, UP_MAX), clamp(inCm, -IN_MAX, IN_MAX));
		while (s.Length() > MAXLEN)
		{
			int end = s.IndexOf(";", 1);
			if (end < 0) break;
			s = s.Mid(end);
		}
		c.SetString(s);
		if (Dbg()) Console.Printf("rsqgc: spot saved %s side %.1f up %.1f in %.1f (%d chars)", Key(cls), sd, up, inCm, s.Length());
	}

	static clearscope void Forget(String cls)
	{
		let c = CVar.FindCVar("rsqgc_spots");
		if (!c || cls == "") return;
		String s = Without(c.GetString(), cls);
		if (s == ";") s = "";
		c.SetString(s);
		if (Dbg()) Console.Printf("rsqgc: spot reset %s (back to the Placement sliders)", Key(cls));
	}

	static clearscope void ForgetAll()
	{
		let c = CVar.FindCVar("rsqgc_spots");
		if (c) c.SetString("");
		if (Dbg()) Console.Printf("rsqgc: every saved spot reset");
	}

	static clearscope bool Dbg() { let c = CVar.FindCVar("rsqgc_debug_log"); return c && c.GetInt() > 0; }

	// the hand the Advanced rows edit (Edit Spot For): 0 main, 1 off
	static clearscope int EditHand() { let c = CVar.FindCVar("rsqgc_spot_hand"); return (c && c.GetInt() == 1) ? 1 : 0; }

	// the gun in that hand (null: no gun with a small card)
	static clearscope Weapon EditGun()
	{
		let p = players[consoleplayer];
		if (!p.mo) return null;
		Weapon w = EditHand() == 1 ? p.OffhandWeapon : p.ReadyWeapon;
		// no small card without something to count: a gun's ammo, or an item's count (items.zs: flares, cigarettes)
		if (!w || !(w.Ammo1 || RSQGC_Items.SmallCount(w))) return null;
		return w;
	}

	// its class, the one the Advanced rows edit (empty: no gun with a small card)
	static clearscope String EditClass()
	{
		let w = EditGun();
		if (!w) return "";
		return w.GetClassName();
	}

	// RSQGC_GunCard.NameOf, readable from the menu (that one is play scope)
	static clearscope String NameOf(Weapon w)
	{
		if (!w) return "";
		string cn = w.GetClassName();
		if (cn.Left(8) ~== "RSQ_Off_")
		{
			class<Actor> real = cn.Mid(8);
			if (real) { let d = GetDefaultByType(real); if (d) return d.GetTag(); }
		}
		string n = w.GetTag();
		if (n.Length() == 0) n = w.GetClassName();
		return n;
	}
}

// ---- THE MENU ROWS (Advanced: this gun's small card) -------------------------------------------------------------
// A slider for one number of the spot of the gun in the hand Edit Spot For picks: it shows the spot the card uses now
// (saved, else its gun's, else the Placement sliders) and moving it saves a spot for that gun. Its action names no cvar,
// so Reset All passes it by; the two rows below reset spots. Greyed with no gun in that hand.
class OptionMenuItemRSQGCSpotSlider : OptionMenuItemSlider
{
	int mAxis;   // 0 side, 1 up, 2 in

	OptionMenuItemRSQGCSpotSlider Init(String label, int axis, double min, double max, double step, int showval = 1)
	{
		mAxis = axis;
		Super.Init(label, 'none', min, max, step, showval);
		return self;
	}

	override double GetSliderValue()
	{
		double sd, up, inCm;
		[sd, up, inCm] = RSQGC_Spots.SpotFor(RSQGC_Spots.EditClass());
		return mAxis == 0 ? sd : mAxis == 1 ? up : inCm;
	}

	override void SetSliderValue(double val)
	{
		String cls = RSQGC_Spots.EditClass();
		if (cls == "") return;
		double sd, up, inCm;
		[sd, up, inCm] = RSQGC_Spots.SpotFor(cls);
		if (mAxis == 0) sd = val; else if (mAxis == 1) up = val; else inCm = val;
		RSQGC_Spots.Save(cls, sd, up, inCm);
	}

	override bool Selectable() { return RSQGC_Spots.EditClass() != ""; }
	override bool IsGrayed() { return RSQGC_Spots.EditClass() == ""; }
}

// "This gun:" and the gun's name, so it is clear which gun the rows below edit
class OptionMenuItemRSQGCSpotGun : OptionMenuItemStaticText
{
	OptionMenuItemRSQGCSpotGun Init(String label, int cr = -1)
	{
		Super.Init(label, cr);
		return self;
	}
	override int Draw(OptionMenuDescriptor desc, int y, int indent, bool selected)
	{
		bool off = RSQGC_Spots.EditHand() == 1;
		let w = RSQGC_Spots.EditGun();
		String n = off ? "no gun in your off hand" : "no gun in your main hand";
		if (w)
		{
			n = RSQGC_Spots.NameOf(w);
			int from; double a, b, c;
			[from, a, b, c] = RSQGC_Spots.Find(w.GetClassName());
			n = n .. (from == 1 ? " (its own spot)" : from == 2 ? " (the gun's spot)" : " (the Placement spot)");
		}
		mLabel = (off ? "Off-hand gun: " : "This gun: ") .. n;
		return Super.Draw(desc, y, indent, selected);
	}
}

// Reset This Gun's Card / Reset All Saved Spots (confirmed)
class OptionMenuItemRSQGCSpotReset : OptionMenuItemSafeCommand
{
	bool mAll;
	OptionMenuItemRSQGCSpotReset Init(String label, int all, String prompt = "")
	{
		Super.Init(label, 'none', prompt);
		mAll = all != 0;
		return self;
	}
	override bool MenuEvent(int mkey, bool fromcontroller)
	{
		if (mkey == Menu.MKEY_MBYes)
		{
			if (mAll) RSQGC_Spots.ForgetAll();
			else RSQGC_Spots.Forget(RSQGC_Spots.EditClass());
			return true;
		}
		return Super.MenuEvent(mkey, fromcontroller);
	}
	override bool Selectable() { return mAll || RSQGC_Spots.EditClass() != ""; }
}
