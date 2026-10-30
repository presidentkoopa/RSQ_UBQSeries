// FINAL DOOMER COMPATIBILITY.
//
// Final Doomer is NINE separate weapon sets (Plutonia, TNT, Doom2, Aliens
// TC, JPCP, BTSX, Hellbound, Alien Vendetta, Whitemare) picked as a player
// CLASS at game start (MAPINFO PlayerClasses, NoRandomPlayerClass) -- one
// set is active for the whole game, never mixed with another.
//
// Pure DECORATE + tiny ACS, no ZScript anywhere, and NO rarity/tier/quality
// ladder anywhere across all nine sets -- exhaustively grepped for this
// file, confirmed absent. So exactly like wr_compat_combinedarms.zs this
// never touches tierColorOf()/cardColorFor() or the sheet's title row.
//
// Every mechanic built here lives on a player-OWNED Inventory item, not a
// weapon field -- an FDCounter/FDLevelLimit/FDBoolean/Powerup/Ammo the
// weapon's own DECORATE state chain checks with A_JumpIfInventory rather
// than keeping a variable, exactly Combined Arms' pattern. So this file
// reuses that file's owned-item-walk primitives rather than field
// reflection, and every class name below was checked against the mod's
// actual DECORATE declarations before being used, not assumed from a
// weapon's in-game name.
//
// COVERAGE IS DELIBERATELY UNEVEN, because the mod itself is: Doom2 and
// Aliens TC are almost entirely fixed A_FireBullets math with nothing live
// to read, so they get identification only, while Whitemare, Hellbound,
// JPCP, Alien Vendetta and BTSX each have real per-weapon state worth a
// row. Two mechanics found in the survey are deliberately left OUT even
// though they are real: Aliens TC's plasma-rifle escalation and rocket
// growth are pure state-machine/in-flight math with no backing counter to
// read, and Alien Vendetta's Grav-Staff ranged combo has its actual
// projectile-spawn calls confirmed commented out (dead code) in this build.
class wr_CompatFinalDoomer
{
	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	private static bool active(Weapon w)
	{
		return w && cv("wr_fd_compat", 1.0) > 0.0;
	}

	// Same primitive as wr_compat_combinedarms.zs -- every value in this
	// file is the Amount of an inventory item, never a declared field.
	private static bool, int, int itemOf(Actor owner, string cls)
	{
		if (!owner) return false, 0, 0;
		for (Inventory it = owner.Inv; it; it = it.Inv)
		{
			if (("" .. it.GetClassName()) == cls)
				return true, it.Amount, it.MaxAmount;
		}
		return false, 0, 0;
	}

	private static int amountOf(Actor owner, string cls)
	{
		bool got; int n, mx;
		[got, n, mx] = itemOf(owner, cls);
		return got ? n : 0;
	}

	private static bool hasItem(Actor owner, string cls)
	{
		bool got; int n, mx;
		[got, n, mx] = itemOf(owner, cls);
		return got && n > 0;
	}

	//==========================================================================
	// WHICH SET, read off the WEAPON's own class-name prefix rather than a
	// player token -- this works for a weapon still sitting on the floor,
	// unowned, matching every other set-identification reader in this mod.
	// The nine prefixes are the mod's own (verified against actual class
	// declarations, not the ACS lookup table's slightly different spelling).
	//
	// FOUND, SET NAME.
	static bool, string SetOf(Weapon w)
	{
		if (!w || cv("wr_fd_compat", 1.0) <= 0.0) return false, "";
		string wc = "" .. w.GetClassName();

		// FDAlienVendetta must be checked before FDAliens -- they share a
		// seven-letter prefix, but "FDAliens" is not itself a prefix of
		// "FDAlienVendetta" (the eighth character differs, 's' vs 'V'), so
		// this is a safety margin rather than a fix for a real collision.
		if (Left(wc, 15) == "FDAlienVendetta") return true, "ALIEN VENDETTA";
		if (Left(wc, 8)  == "FDAliens")        return true, "ALIENS TC";
		if (Left(wc, 6)  == "FDPlut")          return true, "PLUTONIA";
		if (Left(wc, 5)  == "FDTNT")           return true, "TNT";
		// 7, NOT 8 -- "FDDoom2" is seven characters. Left(wc,8) on a real class
		// returned the eight-char "FDDoom2S", which can never equal the seven-char
		// literal, so the DOOM II set was the one set that never identified. Every
		// other prefix here is counted correctly. Audit finding #35.
		if (Left(wc, 7)  == "FDDoom2")         return true, "DOOM II";
		if (Left(wc, 6)  == "FDJPCP")          return true, "JPCP";
		if (Left(wc, 6)  == "FDBTSX")          return true, "BTSX";
		if (Left(wc, 11) == "FDHellbound")     return true, "HELLBOUND";
		if (Left(wc, 11) == "FDWhitemare")     return true, "WHITEMARE";
		return false, "";
	}

	private static string Left(string s, int n)
	{
		return (int(s.Length()) <= n) ? s : s.Mid(0, n);
	}

	// The weapon's own display name plus which set it belongs to -- Final
	// Doomer's Tags are genuinely flavourful ("Quantum Accelerator",
	// "Totenheim", "Onmyou Devastator") and nothing else on the sheet shows
	// them; the generic fallback title row only ever prints "SLOT N".
	//
	// FOUND, TEXT.
	static bool, string NameOf(Weapon w)
	{
		bool got; string set;
		[got, set] = SetOf(w);
		if (!got) return false, "";
		string tag = w.GetTag();
		if (tag.Length() == 0) return false, "";
		return true, tag .. " -- " .. set;
	}

	//==========================================================================
	// PLUTONIA. Heavy Machine Gun (plasma-rifle slot) runs a live 0-50
	// inaccuracy gauge that climbs while firing and decays while idle -- the
	// mod's own name for it, not a term invented here. BFG "Quantum
	// Accelerator" charges in +27 bursts toward a 140 cap and discharges
	// through four lightning tiers at 60/45/30/15 remaining.
	//
	// FOUND, SPREAD, MAX. Inverted like DOOM Infinite's statSpread -- LOWER
	// is more accurate -- so this is never fed into the universal Accuracy
	// resolver, only ever its own row.
	static bool, int, int InaccuracyOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0;
		if (("" .. w.GetClassName()) != "FDPlutPlasmaRifle") return false, 0, 0;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "FDPlutMachinegunInaccuracy");
		if (!got) return false, 0, 0;
		return true, n, mx > 0 ? mx : 50;
	}

	// FOUND, CHARGE, MAX.
	static bool, int, int BfgChargeOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0;
		if (("" .. w.GetClassName()) != "FDPlutBFG9000") return false, 0, 0;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "FDPlutBFGChargeup");
		if (!got || n <= 0) return false, 0, 0;
		return true, n, mx > 0 ? mx : 140;
	}

	//==========================================================================
	// TNT. Fist runs a two-hit jab combo into an uppercut finisher; SuperShotgun
	// "Burst Shotgun" fires four rapid sub-shells per pull; chainsaw
	// "Halderman Device" is a genuine 3-mode toggle cycled on altfire --
	// Defence (damage resist), Hazard (radsuit immunity), Vision (light
	// pulse) -- each with a real, different effect, not a cosmetic skin.
	//
	// FOUND, COMBO STAGE (0-2, 2 = finisher window).
	static bool, int FistComboOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0;
		if (("" .. w.GetClassName()) != "FDTNTFist") return false, 0;
		int stage = 0;
		if (hasItem(w.Owner, "FDTNTFistComboTwo"))      stage = 2;
		else if (hasItem(w.Owner, "FDTNTFistComboOne"))  stage = 1;
		if (stage <= 0) return false, 0;
		return true, stage;
	}

	// FOUND, SHELLS INTO BURST, MAX.
	static bool, int, int BurstOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0;
		if (("" .. w.GetClassName()) != "FDTNTSuperShotgun") return false, 0, 0;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "FDTNTSuperShotgunBurst");
		if (!got || n <= 0) return false, 0, 0;
		return true, n, mx > 0 ? mx : 4;
	}

	// FOUND, MODE WORD.
	static bool, string HaldermanOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, "";
		if (("" .. w.GetClassName()) != "FDTNTChainsaw") return false, "";
		int t = amountOf(w.Owner, "FDTNTHaldermanType");
		return true, (t == 2) ? "VISION" : (t == 1) ? "HAZARD" : "DEFENCE";
	}

	//==========================================================================
	// HELLBOUND. Dual Magnums track each cylinder separately (six rounds a
	// side); Borstal Shotgun tracks shots into its 3-shot pump cycle; the
	// rocket-launcher slot is a full C4 charge system -- up to ten placed
	// charges tracked live, detonation mode set globally by the player
	// (cvar, not per-charge, so read once and shown alongside the count).
	//
	// FOUND, LEFT, RIGHT, MAX EACH.
	static bool, int, int, int MagnumsOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0, 0;
		if (("" .. w.GetClassName()) != "FDHellboundPistol") return false, 0, 0, 0;
		bool got; int l, mx, r, mx2;
		[got, l, mx] = itemOf(w.Owner, "FDHellboundPistolLeftShots");
		bool got2;
		[got2, r, mx2] = itemOf(w.Owner, "FDHellboundPistolRightShots");
		if (!got && !got2) return false, 0, 0, 0;
		return true, l, r, mx > 0 ? mx : 6;
	}

	// FOUND, SHOTS INTO PUMP, MAX.
	static bool, int, int PumpOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0;
		if (("" .. w.GetClassName()) != "FDHellboundShotgun") return false, 0, 0;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "FDHellboundShotgunShots");
		if (!got || n <= 0) return false, 0, 0;
		return true, n, mx > 0 ? mx : 3;
	}

	// FOUND, ACTIVE CHARGES, MAX.
	static bool, int, int C4Of(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0;
		if (("" .. w.GetClassName()) != "FDHellboundRocketLauncher") return false, 0, 0;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "FDHellboundC4Active");
		if (!got) return false, 0, 0;
		return true, n, mx > 0 ? mx : 10;
	}

	//==========================================================================
	// ALIEN VENDETTA. Fist runs a 3-hit jab-jab-hook combo; SuperShotgun
	// "Shattergun" fires ten rapid sub-bursts per trigger pull; BFG "The
	// Vendetta Machine" is the single most complex mechanic in the whole
	// mod -- it does not fire a bolt itself, a tracking puff rides the
	// locked target and homing bolts spawn from IT while the trigger is
	// held, per the mod's own dev comment. Only the lock state is a stable
	// enough signal to show here.
	//
	// FOUND, COMBO STAGE (0-2, 2 = hook).
	static bool, int VendettaComboOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0;
		if (("" .. w.GetClassName()) != "FDAlienVendettaFist") return false, 0;
		int n = amountOf(w.Owner, "FDAlienVendettaFistComboCounter");
		if (n <= 0) return false, 0;
		return true, n;
	}

	// FOUND, SUB-BURST, MAX.
	static bool, int, int ShattergunOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0;
		if (("" .. w.GetClassName()) != "FDAlienVendettaSuperShotgun") return false, 0, 0;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "FDAlienVendettaSuperShotgunShotCounter");
		if (!got || n <= 0) return false, 0, 0;
		return true, n, mx > 0 ? mx : 10;
	}

	// FOUND, LOCKED.
	static bool, bool BfgLockOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, false;
		if (("" .. w.GetClassName()) != "FDAlienVendettaBFG9000") return false, false;
		return true, hasItem(w.Owner, "FDAlienVendettaBFGTargetActive");
	}

	//==========================================================================
	// JPCP. The Fist slot secretly is the chainsaw too -- picking up "the
	// chainsaw" just grants FDGotChainsaw, and the Fist's own state machine
	// reads it throughout to swap its whole moveset into an NRG Katana.
	// FDJPCPSwordUnsheathed tracks whether the blade is currently drawn in
	// EITHER mode. Chaingun "Burst Needler" tracks shots within its current
	// burst before transitioning to full auto.
	//
	// FOUND, DRAWN, NRG MODE.
	static bool, bool, bool KatanaOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, false, false;
		if (("" .. w.GetClassName()) != "FDJPCPFist") return false, false, false;
		bool nrg = hasItem(w.Owner, "FDGotChainsaw");
		if (!nrg) return false, false, false;
		return true, hasItem(w.Owner, "FDJPCPSwordUnsheathed"), true;
	}

	// FOUND, SHOTS IN BURST, MAX.
	static bool, int, int NeedlerOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0;
		if (("" .. w.GetClassName()) != "FDJPCPChaingun") return false, 0, 0;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "FDJPCPNeedleHolder");
		if (!got || n <= 0) return false, 0, 0;
		return true, n, mx > 0 ? mx : 6;
	}

	//==========================================================================
	// BTSX. NanoCore is a chainsaw-slot buff-ACTIVATION item -- it never
	// attacks, it just arms a mod-wide overdrive flag every other BTSX
	// weapon checks for a confirmed, exact bonus (double damage, extra
	// pellets, faster charge, and so on). One use per life. Fist and Pistol
	// separately track their own charge-up meters toward a power hit.
	//
	// FOUND, ACTIVE.
	static bool, bool NanoCoreOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, false;
		bool got; string set;
		[got, set] = SetOf(w);
		if (!got || set != "BTSX") return false, false;
		bool on = hasItem(w.Owner, "FDBTSXOverdrivePower") || hasItem(w.Owner, "FDBTSXOverdrivePowerAlt");
		return true, on;
	}

	// FOUND, CHARGE, MAX.
	static bool, int, int FistChargeOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0;
		if (("" .. w.GetClassName()) != "FDBTSXFist") return false, 0, 0;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "FDBTSXFistCharge");
		if (!got || n <= 0) return false, 0, 0;
		return true, n, mx > 0 ? mx : 100;
	}

	// FOUND, CHARGE, MAX.
	static bool, int, int PistolChargeOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0;
		if (("" .. w.GetClassName()) != "FDBTSXPistol") return false, 0, 0;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "FDBTSXPistolCharge");
		if (!got || n <= 0) return false, 0, 0;
		return true, n, mx > 0 ? mx : 100;
	}

	//==========================================================================
	// WHITEMARE, the richest set in the mod. ThermoCoat chainsaw heat takes
	// its own gauge (mirrors DOOM Infinite/Combined Arms' heat rows).
	// Chaingun "overdrive" is a separate 0-500 speed counter with its own
	// overload flag. BFG "Totenheim" reports its own continuous-incineration
	// firing timer only while actually firing. Rocket launcher charges a
	// grenade up to 25 -- damage, blast radius and visual size all scale
	// with the charge directly.
	//
	// FOUND, HEAT, MAX, ACTIVE.
	static bool, int, int, bool ThermoCoatOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0, false;
		if (("" .. w.GetClassName()) != "FDWhitemareChainsaw") return false, 0, 0, false;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "FDWhitemareHeatLevel");
		if (!got) return false, 0, 0, false;
		return true, n, mx > 0 ? mx : 999, hasItem(w.Owner, "FDWhitemareHeatActive");
	}

	// FOUND, SPEED, MAX, OVERLOADED.
	static bool, int, int, bool WmChaingunOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0, false;
		if (("" .. w.GetClassName()) != "FDWhitemareChaingun") return false, 0, 0, false;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "FDWhitemareChaingunSpeedCounter");
		if (!got) return false, 0, 0, false;
		return true, n, mx > 0 ? mx : 500, hasItem(w.Owner, "FDWhitemareChaingunOverload");
	}

	// FOUND, TICS.
	static bool, int WmBfgOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0;
		if (("" .. w.GetClassName()) != "FDWhitemareBFG9000") return false, 0;
		int n = amountOf(w.Owner, "FDWhitemareBFGFiringTimer");
		if (n <= 0) return false, 0;
		return true, n;
	}

	// FOUND, CHARGE, MAX.
	static bool, int, int WmRocketOf(Weapon w)
	{
		if (!active(w) || !w.Owner) return false, 0, 0;
		if (("" .. w.GetClassName()) != "FDWhitemareRocketLauncher") return false, 0, 0;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "FDWhitemareFireballCharge");
		if (!got || n <= 0) return false, 0, 0;
		return true, n, mx > 0 ? mx : 25;
	}
}
