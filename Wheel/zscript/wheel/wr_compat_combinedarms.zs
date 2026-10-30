// COMBINED ARMS COMPATIBILITY.
//
// Combined Arms (V2.3, 2021) is a FOUR-CLASS weapon replacer -- Artificer,
// BlastMaster Mk.2, Tech Monk, Past Linked -- and it is DECORATE + ACS with
// no ZScript anywhere. That normally means the field reflection every other
// compat file in this mod leans on is useless here: a DECORATE actor
// compiles to an Inventory/Weapon/Powerup subclass with ZERO declared
// fields of its own, so there is nothing to read BY NAME.
//
// IT DOES NOT MATTER, because of how this mod stores state. Every meter,
// cooldown, charge and upgrade in Combined Arms is the Amount of an
// inventory item the player is carrying -- its own ACS does
// checkinventory("GauntletHP") rather than keeping a variable. So the whole
// dataset is reachable through the plain owned-item walk
// wr_compat_metadoom.zs already uses for Demon Keys, reading Amount and
// MaxAmount, both of which are ordinary Inventory base-class fields needing
// no reflection and no compile-time dependency on this mod at all.
//
// NOT ONE ACS CALL, AND THAT IS DELIBERATE. Every script in CBarms.acs was
// read before this file was written. They are not lookups -- they are the
// mod's own running machinery, and calling them is destructive rather than
// merely useless: poweruptaker takes 17 different items away, then clamps
// GauntletHP; Pistolstarter runs clearinventory() and resets the player's
// health to 100; StrikerMeter grants StrikerReset 600, a fifty-second
// lockout. The two scripts that ARE clean reads (CratePicker, BerserkValue)
// only hand back a cvar this file could read directly. There is no
// BorderDoom-style temptation here (wr_compat_borderdoom.zs) -- no ACS
// route to anything, so nothing to be tempted by.
//
// NO RARITY LADDER, so like most of the mods here this never touches
// tierColorOf()/cardColorFor() or the sheet's title row -- purely
// supplementary rows. Past Linked's three UPGRADE ladders are real, but
// they are per-subweapon progression, not a quality roll on a found weapon.
class wr_CompatCombinedArms
{
	const CA_NONE   = 0;
	const CA_ARTI   = 1;
	const CA_BLAST  = 2;
	const CA_MONK   = 3;
	const CA_LINKED = 4;

	// BlastMaster heat tiers, from MeterManager in CBarms.acs -- the exact
	// values its own escalation fires at, not thresholds invented here, so
	// the word on the sheet changes on the same shot the mod's own audio
	// tier does.
	const HEAT_MAX   = 200;
	const HEAT_TIER2 = 91;
	const HEAT_TIER3 = 156;
	const HEAT_WARN  = 180;

	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	private static bool active(Weapon w)
	{
		return w && w.Owner && cv("wr_ca_compat", 1.0) > 0.0;
	}

	// THE ONE PRIMITIVE THIS WHOLE FILE IS BUILT ON. Walks the owner's
	// inventory for a class by NAME -- CountInv() would need a compile-time
	// class<Inventory>, and every class named in this file is Combined Arms'
	// own, which this mod must not reference at compile time.
	//
	// MaxAmount comes off the LIVE INSTANCE, never a table written here, and
	// that is load-bearing rather than tidiness: IceCharge declares
	// MaxAmount 100 but BackpackMaxAmount 10, so a BlastMaster who picks up
	// a backpack has his ice cap DROP to 10. A hardcoded 100 would print
	// "8/100" at what is actually a nearly-full meter. Reading the instance
	// is self-correcting for that and for anything else this mod does to a
	// cap at runtime.
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

	// Just the count, for the many places that only need "is this held".
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
	// WHICH CLASS. Every row below is class-specific, so this is read first
	// and everything else early-outs on it. The four IAm* tokens are granted
	// as Player.startitem and never removed (playertokens.dec), so this is
	// as reliable as the class itself.
	static int ClassOf(Weapon w)
	{
		if (!active(w)) return CA_NONE;
		Actor o = w.Owner;
		if (hasItem(o, "IAmArtificer"))   return CA_ARTI;
		if (hasItem(o, "IAmBlastMaster")) return CA_BLAST;
		if (hasItem(o, "IAmTechMonk"))    return CA_MONK;
		if (hasItem(o, "IAmPastLinked"))  return CA_LINKED;
		return CA_NONE;
	}

	//==========================================================================
	// BLASTMASTER HEAT -- the one meter in this mod big enough to earn a
	// gauge rather than a row, and the only reading here that carries a
	// WORD as well as a number, because its thresholds change what the
	// weapons actually do.
	//
	// FOUND, HEAT, MAX, OVERHEAT TICS. Overheat is reported separately
	// rather than folded in: at that point heat itself has been zeroed by
	// the mod (MeterManager takes all of it on the overheat frame), so a
	// caller reading only heat would show a cool, healthy 0/200 during the
	// exact twenty seconds the player cannot fire at all.
	static bool, int, int, int HeatOf(Weapon w)
	{
		if (ClassOf(w) != CA_BLAST) return false, 0, 0, 0;

		bool got; int heat, mx;
		[got, heat, mx] = itemOf(w.Owner, "BMheat");
		int over = amountOf(w.Owner, "BMoverheat");

		// Not "got" alone: BMheat is taken away entirely at zero rather
		// than left sitting at 0, so a cool BlastMaster genuinely has no
		// such item. Found is therefore "this is a BlastMaster", and a
		// missing item reads as the zero it actually means.
		return true, got ? heat : 0, (got && mx > 0) ? mx : HEAT_MAX, over;
	}

	static string HeatWord(int heat)
	{
		if (heat >= HEAT_WARN)  return "CRITICAL";
		if (heat >= HEAT_TIER3) return "HIGH";
		if (heat >= HEAT_TIER2) return "WARM";
		return "";
	}

	//==========================================================================
	// THE PRIMARY RESOURCE ROW, one per class -- the number that class
	// actually plays around. Returned pre-formatted because what belongs
	// here differs per class in shape, not just in value: a fraction for
	// some, a bare count for others, nothing at all for a class whose
	// resource is the vanilla ammo the sheet already shows.
	static bool, string ResourceRow(Weapon w)
	{
		int c = ClassOf(w);
		if (c == CA_NONE) return false, "";
		Actor o = w.Owner;

		bool got; int n, mx;

		if (c == CA_ARTI)
		{
			// Skill is Lilk's Axe mana; GauntletHP is the Cobalt Mace's
			// durability, which is the more urgent of the two because the
			// mace is DESTROYED at zero rather than merely unusable. Both
			// shown when both are held, since a player can carry both.
			string s = "";
			[got, n, mx] = itemOf(o, "Skill");
			if (got) s = String.Format("SKILL %d/%d", n, mx > 0 ? mx : 50);

			[got, n, mx] = itemOf(o, "GauntletHP");
			if (got && n > 0)
			{
				string m = String.Format("MACE %d", n);
				s = s.Length() ? (s .. "  " .. m) : m;
			}
			return s.Length() > 0, s;
		}

		if (c == CA_BLAST)
		{
			// Ice charge only -- heat has its own row and its own gauge.
			[got, n, mx] = itemOf(o, "IceCharge");
			if (!got) return false, "";
			return true, String.Format("ICE %d/%d", n, mx > 0 ? mx : 100);
		}

		if (c == CA_MONK)
		{
			// The Tech Monk's weapons run on vanilla ammo the sheet already
			// prints. What is genuinely his is the Striker, which is three
			// mutually exclusive states sharing one row: locked out after
			// use, currently transformed, or charging toward it.
			//
			// StrikerTimer and StrikerReset both drain 1 per 3 tics -- so the
			// counter is not in tics, and each unit is worth THREE of them.
			// Remaining tics = counter * 3, seconds = counter * 3 / 35.
			//
			// It used to divide by 105, which is counter/(3*35) -- the formula for
			// a counter measured in tics that drains 3 per tic, the exact opposite
			// mechanism. Nine times too small. This file's own header carries the
			// check value: StrikerMeter grants StrikerReset 600, "a fifty-second
			// lockout". 600*3/35 = 51s, which matches; 600/105+1 = 6s, which is
			// what was printed, and then crawled at one displayed second per nine
			// real ones. Audit finding #37.
			int reset = amountOf(o, "StrikerReset");
			if (reset > 0) return true, String.Format("STRIKER LOCKED %ds", reset * 3 / 35 + 1);

			int timer = amountOf(o, "StrikerTimer");
			if (timer > 0) return true, String.Format("STRIKER ACTIVE %ds", timer * 3 / 35 + 1);

			if (!hasItem(o, "StrikerModule")) return false, "";
			int chg = amountOf(o, "StrikerCharge");
			return true, chg >= 300 ? "STRIKER READY"
			                        : String.Format("STRIKER %d/300", chg);
		}

		// Past Linked: which subweapon is actually selected, and how long
		// until it can be used again. The carousel is cycled with Reload
		// and Zoom and the game shows the choice only on the weapon
		// sprite, so this is the one row that answers "what does my Reload
		// key do right now".
		string which = "";
		string cool  = "";
		if (hasItem(o, "BoomerangActive"))
		{
			which = "BOOMERANG";
			int cd = amountOf(o, "BoomerangCooldown");
			if (cd > 0) cool = String.Format("%ds CD", cd / 35 + 1);
		}
		else if (hasItem(o, "CandleActive"))
		{
			which = "CANDLE";
			int cd = amountOf(o, "CandleCooldown");
			if (cd > 0) cool = String.Format("%ds CD", cd / 35 + 1);
		}
		else if (hasItem(o, "BombBagActive"))
		{
			// Bombs spend RocketAmmo rather than running a cooldown, and
			// the sheet's own ammo row already carries that number.
			which = "BOMBS";
		}
		if (which.Length() == 0) return false, "";
		return true, cool.Length() ? ("SUB " .. which .. "  " .. cool)
		                           : ("SUB " .. which .. "  READY");
	}

	//==========================================================================
	// COOLDOWNS AND LOCKOUTS, packed into one row. Every one of these is a
	// count draining to zero, and every one means "you cannot do the thing
	// yet", so they read better together than scattered.
	//
	// Combined Arms' own status bar draws these bars ONLY while non-zero --
	// the meter appears the instant you are penalised and vanishes when you
	// recover. This row follows the same rule (nothing listed while ready),
	// but sits on a card the player opens deliberately rather than flashing
	// past mid-fight.
	static bool, string CooldownRow(Weapon w)
	{
		int c = ClassOf(w);
		if (c == CA_NONE) return false, "";
		Actor o = w.Owner;
		string s = "";

		if (c == CA_ARTI)
		{
			// SecondWindHeat and BootTimer both drain 1 per tic, so both
			// are plain tics and divide by the tic rate for seconds.
			int sw = amountOf(o, "SecondWindHeat");
			if (sw > 0) s = String.Format("PISTOL %ds", sw / 35 + 1);

			int kick = amountOf(o, "BootTimer");
			if (kick > 0)
			{
				string k = String.Format("KICK %ds", kick / 35 + 1);
				s = s.Length() ? (s .. "  " .. k) : k;
			}
		}
		else if (c == CA_MONK)
		{
			// KameCoolDown counts UP to 300 rather than down, so this is
			// progress toward ready, not time remaining -- shown as a
			// fraction rather than as seconds so it cannot be misread as a
			// countdown that is somehow getting longer.
			if (hasItem(o, "KameBombModule"))
			{
				int kame = amountOf(o, "KameCoolDown");
				s = (kame > 0) ? String.Format("KAME %d/300", kame) : "KAME READY";
			}
		}
		else if (c == CA_LINKED)
		{
			// The subweapon NOT currently selected still cools down, and
			// the player cannot see it at all -- the carousel shows one at
			// a time. This is the row that says whether swapping is even
			// worth it.
			int bcd = amountOf(o, "BoomerangCooldown");
			int ccd = amountOf(o, "CandleCooldown");
			if (bcd > 0) s = String.Format("BOOM %ds", bcd / 35 + 1);
			if (ccd > 0)
			{
				string cc = String.Format("CANDLE %ds", ccd / 35 + 1);
				s = s.Length() ? (s .. "  " .. cc) : cc;
			}
		}

		return s.Length() > 0, s;
	}

	//==========================================================================
	// UPGRADES. Past Linked has three real ladders; the other three classes
	// have flat unlock flags. Both go here.
	//
	// The ladders are climbed by picking the SAME crystal up again rather
	// than by finding a better one, so a tier is genuinely earned progress
	// and worth a row -- it is just not a RARITY, which is why this file
	// still never touches the sheet's title row or its colour.
	static bool, string UpgradeRow(Weapon w)
	{
		int c = ClassOf(w);
		if (c == CA_NONE) return false, "";
		Actor o = w.Owner;

		if (c == CA_LINKED)
		{
			string s = "";

			// Sword: base -> White -> Magical -> Peril. Read top-down so
			// the highest owned tier wins.
			int sw = 1;
			if (hasItem(o, "PerilBeamToken"))         sw = 4;
			else if (hasItem(o, "MagicalSwordToken")) sw = 3;
			else if (hasItem(o, "WhiteSwordToken"))   sw = 2;
			s = String.Format("SWORD %d/4", sw);

			if (hasItem(o, "BoomerangToken"))
			{
				int bm = 1;
				if (hasItem(o, "FireBoomerangToken"))         bm = 3;
				else if (hasItem(o, "MagicalBoomerangToken")) bm = 2;
				s = s .. String.Format("  BOOM %d/3", bm);
			}

			if (hasItem(o, "MagicCandle"))
				s = s .. String.Format("  CANDLE %d/2", hasItem(o, "RedCandle") ? 2 : 1);

			return true, s;
		}

		// The other three classes: flat unlocks, listed only once earned.
		string s = "";
		if (c == CA_ARTI)
		{
			if (hasItem(o, "GauntletHP")) s = "MACE";
		}
		else if (c == CA_BLAST)
		{
			if (hasItem(o, "Superventer")) s = "SUPERVENT";
		}
		else if (c == CA_MONK)
		{
			if (hasItem(o, "StrikerModule"))  s = "STRIKER";
			if (hasItem(o, "KameBombModule")) s = s.Length() ? (s .. "  KAME") : "KAME";
			if (hasItem(o, "HandBeamAug"))    s = s.Length() ? (s .. "  AUG") : "AUG";
		}

		if (s.Length() == 0) return false, "";
		return true, "UNLOCKED " .. s;
	}

	//==========================================================================
	// THE EXPIRY WARNING, and the reason this file is worth building at all.
	//
	// Three upgrades in this mod are stripped on every map load -- CBarms.acs's
	// poweruptaker takes PerilBeamToken, FireBoomerangToken and HandBeamAug
	// in its ENTER script. The mod says so ONCE, in a pickup message
	// ("Fire Boomerang Upgrade for this level!") that scrolls away in
	// seconds, and then never mentions it again. Nothing in the game's own
	// HUD distinguishes a permanent tier from one about to vanish.
	//
	// So this is not a prettier version of something the player can already
	// see. It is the one row here that tells them something the game has no
	// other way of telling them.
	static bool, string ExpiryRow(Weapon w)
	{
		int c = ClassOf(w);
		if (c == CA_NONE) return false, "";
		Actor o = w.Owner;

		string s = "";
		if (c == CA_LINKED)
		{
			if (hasItem(o, "PerilBeamToken"))    s = "SWORD 4";
			if (hasItem(o, "FireBoomerangToken"))
				s = s.Length() ? (s .. " BOOM 3") : "BOOM 3";
		}
		else if (c == CA_MONK)
		{
			if (hasItem(o, "HandBeamAug")) s = "AUG";
		}

		if (s.Length() == 0) return false, "";
		return true, s .. " LOST ON EXIT";
	}

	//==========================================================================
	// WHAT THE MOD'S OWN HUD NEVER SHOWS.
	//
	// All three of these are live, meaningful state that Combined Arms
	// tracks and then simply does not draw anywhere -- checked against its
	// own SBARINFO, which references neither TechCombo nor speedupcount nor
	// the Revenant queue. The combo stage is invisible, the SMG's spin-up is
	// audible only, and which summon is loaded is legible only from the
	// weapon sprite.
	//
	// Gated on the relevant weapon actually being in hand, since none of
	// these mean anything otherwise.
	static bool, string HiddenRow(Weapon w)
	{
		if (!active(w)) return false, "";
		Actor o = w.Owner;
		string wc = "" .. w.GetClassName();

		// Hand Beam melee combo, 1 -> 2 -> 3, third being the finisher.
		if (wc == "HandBeam")
		{
			int stage = 0;
			if (hasItem(o, "TechCombo3"))      stage = 3;
			else if (hasItem(o, "TechCombo2")) stage = 2;
			else if (hasItem(o, "TechCombo1")) stage = 1;
			if (stage <= 0) return false, "";
			return true, stage >= 3 ? "COMBO 3/3  FINISHER"
			                        : String.Format("COMBO %d/3", stage);
		}

		// Vulture SMG barrel spin-up. The thresholds are the mod's own
		// (8/9/17/18 in its DECORATE), collapsed here into the three barrel
		// states they actually produce.
		if (wc == "VultureSMG")
		{
			int spin = amountOf(o, "speedupcount");
			int barrels = (spin >= 18) ? 3 : (spin >= 9) ? 2 : 1;

			bool got; int scav, smax;
			[got, scav, smax] = itemOf(o, "ScavCharge");
			string sc = "";
			if (got)
				sc = (scav >= (smax > 0 ? smax : 100))
				       ? "  SCAV READY"
				       : String.Format("  SCAV %d/%d", scav, smax > 0 ? smax : 100);

			return true, String.Format("BARRELS %d/3", barrels) .. sc;
		}

		// Pocket Revenants: exactly one of six summons is queued at a time,
		// and the only tell in-game is the sprite.
		if (wc == "RevenantBox")
		{
			string which = "";
			if (hasItem(o, "DoomBonerReady"))        which = "REVENANT";
			else if (hasItem(o, "GoldenBonerReady")) which = "GOLDEN";
			else if (hasItem(o, "PocketMummyReady")) which = "MUMMY";
			else if (hasItem(o, "BlazMimicReady"))   which = "MIMIC";
			else if (hasItem(o, "MiniPfhorReady"))   which = "PFHOR";
			else if (hasItem(o, "MiniCultistReady")) which = "CULTIST";
			if (which.Length() == 0) return false, "";
			return true, "LOADED " .. which;
		}

		return false, "";
	}
}
