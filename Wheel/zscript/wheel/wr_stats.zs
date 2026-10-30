// THE UNIVERSAL STAT RESOLVER.
//
// Before this file, RS Weapon's stats were a privileged special case:
// rsRows() had seven dedicated rows of its own while every other mod got a
// generic handful, and a weapon from no mod at all got almost nothing. That
// was backwards. Damage, rate of fire, accuracy, magazine size and pellet
// count are not RS Weapon's concepts -- they are things EVERY weapon in
// every mod has, and the only thing that differs is whether anyone can tell
// you the number.
//
// So this asks one question per stat, of any weapon, from any mod, and
// takes the best answer available:
//
//   DECLARED -- the mod stores it as a real field and this read it. The
//               strongest answer: authored, exact, and true before the
//               weapon has ever been fired. Only RS Weapon and BorderDoom
//               do this.
//   OBSERVED -- nobody declares it, so the tracker watched the weapon work
//               and recorded what actually happened. Available for any
//               weapon from any mod, including mods that did not exist when
//               this was written -- but only once you have carried it.
//   MASKED   -- the value exists and is deliberately hidden (RS Weapon's
//               curses). Distinct from UNKNOWN on purpose: "we are not
//               allowed to tell you" and "nobody knows" are different
//               statements, and only one of them is the game being played
//               correctly.
//   UNKNOWN  -- nothing can answer. The row does not draw.
//
// WHY GZDOOM FORCES THE OBSERVED PATH AT ALL: damage, rate of fire and
// pellet count are not stored anywhere readable for an ordinary weapon.
// They are arguments passed to action functions inside fire states --
// A_FireBullets(spread, spread, pellets, damage) -- which is code, not
// data. No amount of reflection reaches them. A mod that wants them
// readable has to declare its own fields, and almost none do. That is why
// the tracker exists and why it is the foundation here rather than the
// fallback.
class wr_Stats
{
	// Where an answer came from. Ordered by strength -- a caller comparing
	// two sources can just take the larger.
	const SRC_UNKNOWN  = 0;
	const SRC_MASKED   = 1;
	const SRC_OBSERVED = 2;
	const SRC_DECLARED = 3;

	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	// Whether this weapon is one RS Weapon rolled, and therefore whether the
	// curse rules below apply to it at all.
	private static bool isRS(Weapon w)
	{
		int tier;
		return w && level.GetFieldInt(w, "Tier", tier);
	}

	// FAIL CLOSED, and this is the one rule in this file that is not about
	// accuracy but about not spoiling the game.
	//
	// RS Weapon's curses hide a rolled stat until the player pays to lift
	// them (RS_Screens.zs:272-281). Every test here is POSITIVE -- a read
	// that fails leaves its flag false, which would mean "not cursed" and
	// print the number. So an unreadable flag is treated AS cursed: showing
	// ??? when nothing is hidden is a cosmetic error, and showing a number
	// that should be hidden is the one that cannot be taken back.
	private static bool lockedBy(Weapon w, string flag)
	{
		int li;
		return !level.GetFieldBool(w, flag, li) || li != 0;
	}

	//==========================================================================
	// DAMAGE PER SHOT, as a RANGE.
	//
	// Most Doom weapons roll their damage, so a single figure is a number
	// the gun cannot actually deal. Returns low and high; low == high means
	// either a fixed-damage weapon or one that has not yet been fired enough
	// to find its spread, and the caller prints one number for that.
	//
	// DECLARED beats observed here even though observation is live, because
	// RS Weapon's DamagePerShot is the authored value the mod itself uses in
	// its own arithmetic -- disagreeing with it would put two different
	// numbers for the same gun on two different screens.
	static play int, int, int Damage(Weapon w)
	{
		if (!w) return SRC_UNKNOWN, 0, 0;

		if (isRS(w))
		{
			if (lockedBy(w, "LockedDamage")) return SRC_MASKED, 0, 0;
			int dmg;
			if (level.GetFieldInt(w, "DamagePerShot", dmg) && dmg > 0)
				return SRC_DECLARED, dmg, dmg;
		}

		// DOOM Infinite stores its rolled damage as a plain field, and --
		// uniquely among every mod read here -- it is already populated on
		// a weapon lying on the floor, before anyone has picked it up. That
		// is what makes a genuine before-you-take-it comparison possible.
		bool di; int diDmg;
		[di, diDmg] = wr_CompatDoomInfinite.DamageOf(w);
		if (di) return SRC_DECLARED, diDmg, diDmg;

		// BorderDoom caches a real per-weapon damage figure, but only for
		// weapons actually carried -- see wr_compat_borderdoom.zs.
		bool bd; int bdDmg, bdAcc, bdRof, bdRcl, bdClip, bdLvl;
		[bd, bdDmg, bdAcc, bdRof, bdRcl, bdClip, bdLvl] = wr_CompatBorderDoom.StatsOf(w);
		if (bd && bdDmg > 0) return SRC_DECLARED, bdDmg, bdDmg;

		bool got; int lo, hi;
		[got, lo, hi] = wr_StatTracker.DamageOf(w);
		if (got) return SRC_OBSERVED, lo, hi;

		return SRC_UNKNOWN, 0, 0;
	}

	//==========================================================================
	// RATE OF FIRE, in shots per second. One number, no range.
	static play int, double Rof(Weapon w)
	{
		if (!w) return SRC_UNKNOWN, 0.0;

		if (isRS(w))
		{
			// Never cursed -- RS_Screens.zs:299 says so outright -- so this
			// needs no mask branch of its own.
			int rof;
			if (level.GetFieldInt(w, "RateOfFire", rof) && rof > 0)
				return SRC_DECLARED, double(rof);
		}

		// Converted from tics-between-shots inside the compat file -- see
		// its header on why handing the raw field over would invert the
		// meaning of every rate comparison on the card.
		bool di; double diRps;
		[di, diRps] = wr_CompatDoomInfinite.RofOf(w);
		if (di) return SRC_DECLARED, diRps;

		bool bd; int bdDmg, bdAcc, bdRof, bdRcl, bdClip, bdLvl;
		[bd, bdDmg, bdAcc, bdRof, bdRcl, bdClip, bdLvl] = wr_CompatBorderDoom.StatsOf(w);
		if (bd && bdRof > 0) return SRC_DECLARED, double(bdRof);

		bool got; double rps;
		[got, rps] = wr_StatTracker.RofOf(w);
		if (got) return SRC_OBSERVED, rps;

		return SRC_UNKNOWN, 0.0;
	}

	//==========================================================================
	// ACCURACY.
	//
	// The two sources mean genuinely different things and this is worth
	// knowing when reading the card: RS Weapon's Accuracy is a SPREAD stat,
	// a property of the gun. The tracker's is a HIT RATE, a property of you
	// using it. Both are honestly called accuracy and neither is wrong, but
	// they are not interchangeable -- which is why the caller labels the
	// observed one differently rather than printing them into the same row.
	static play int, double Accuracy(Weapon w)
	{
		if (!w) return SRC_UNKNOWN, 0.0;

		if (isRS(w))
		{
			if (lockedBy(w, "LockedAccuracy")) return SRC_MASKED, 0.0;
			double acc;
			if (level.GetFieldFloat(w, "Accuracy", acc))
				return SRC_DECLARED, acc;
		}

		bool bd; int bdDmg, bdAcc, bdRof, bdRcl, bdClip, bdLvl;
		[bd, bdDmg, bdAcc, bdRof, bdRcl, bdClip, bdLvl] = wr_CompatBorderDoom.StatsOf(w);
		if (bd && bdAcc > 0) return SRC_DECLARED, double(bdAcc);

		bool got; int kills, shots, hits;
		[got, kills, shots, hits] = wr_StatTracker.BasicsOf(w);
		if (got && shots > 0) return SRC_OBSERVED, double(hits) * 100.0 / double(shots);

		return SRC_UNKNOWN, 0.0;
	}

	//==========================================================================
	// PELLET COUNT. Declared is exact; observed is a FLOOR and nothing more
	// -- see wr_StatTracker.PelletsOf. The caller words the two differently
	// because "8 pellets" and "at least 8 pellets" are different claims.
	static play int, int Pellets(Weapon w)
	{
		if (!w) return SRC_UNKNOWN, 0;

		if (isRS(w))
		{
			// Promotion's reward rather than a rolled stat (RS_Screens.zs:
			// 325-326), so never cursed and needing no mask branch.
			int pel;
			if (level.GetFieldInt(w, "PelletCount", pel) && pel > 0)
				return SRC_DECLARED, pel;
		}

		bool di; int diPel;
		[di, diPel] = wr_CompatDoomInfinite.PelletsOf(w);
		if (di) return SRC_DECLARED, diPel;

		bool got; int n;
		[got, n] = wr_StatTracker.PelletsOf(w);
		if (got) return SRC_OBSERVED, n;

		return SRC_UNKNOWN, 0;
	}

	//==========================================================================
	// MAGAZINE CAPACITY.
	//
	// Ammo2.MaxAmount is deliberately NOT consulted anywhere here. It is the
	// ammo CLASS's default rather than this weapon's capacity, and mods
	// routinely give it headroom, so a full magazine would print as a
	// fraction of a number it never reaches. Declared (RS Weapon's rolled
	// Capacity, BorderDoom's cached clip) or observed high-water, nothing
	// else.
		// Returns source, LOADED, capacity. loaded is -1 when the caller should
	// use its own ammoLoaded(); a mod that keeps the magazine in a plain
	// field (Pandemonia's magCount) answers it here, because for those the
	// ammo pool is the RESERVE and printing it over the capacity gave
	// "MAG 187 / 30".
static play int, int, int Magazine(Weapon w)
	{
		if (!w) return SRC_UNKNOWN, -1, 0;

		if (isRS(w))
		{
			if (lockedBy(w, "LockedCapacity")) return SRC_MASKED, -1, 0;
			int cap;
			if (level.GetFieldInt(w, "Capacity", cap) && cap > 0)
				return SRC_DECLARED, -1, cap;
		}

		bool bd; int bdDmg, bdAcc, bdRof, bdRcl, bdClip, bdLvl;
		[bd, bdDmg, bdAcc, bdRof, bdRcl, bdClip, bdLvl] = wr_CompatBorderDoom.StatsOf(w);
		if (bd && bdClip > 0) return SRC_DECLARED, -1, bdClip;

		// Pandemonia's magCount/magSize is a real declared magazine.
		bool pm; int pmCur, pmMax;
		[pm, pmCur, pmMax] = wr_CompatPandemonia.MagazineOf(w);
		if (pm && pmMax > 0) return SRC_DECLARED, pmCur, pmMax;

		bool got; int cap2;
		[got, cap2] = wr_StatTracker.MagazineOf(w);
		if (got) return SRC_OBSERVED, -1, cap2;

		return SRC_UNKNOWN, -1, 0;
	}

	//==========================================================================
	// CRIT CHANCE and VELOCITY. Declared-only, and honestly so: neither is
	// observable. A crit is not signalled by any event this mod can see, and
	// projectile speed is a property of a projectile that may not exist yet.
	// No tracker fallback is possible for either, so absent means absent.
	//
	// RECOIL IS DELIBERATELY NOT HERE. BorderDoom declares one and it was
	// read for a while, but recoil in these mods models a crosshair kick --
	// it describes the game aiming for you. In VR your hand is the aim, so
	// the number describes a system this mod is not played under. Dropped
	// rather than shown as a stat that means nothing here.
	static play int, double Crit(Weapon w)
	{
		if (!w) return SRC_UNKNOWN, 0.0;

		if (isRS(w))
		{
			if (lockedBy(w, "LockedCritChance")) return SRC_MASKED, 0.0;

			double crit;
			if (level.GetFieldFloat(w, "CritChance", crit))
				return SRC_DECLARED, crit * 100.0;
			return SRC_UNKNOWN, 0.0;
		}

		// DOOM Infinite keeps crit as a whole percent rather than RS
		// Weapon's 0..1 fraction, so it is handed over unscaled.
		bool di; double diCrit;
		[di, diCrit] = wr_CompatDoomInfinite.CritOf(w);
		if (di) return SRC_DECLARED, diCrit;

		return SRC_UNKNOWN, 0.0;
	}

	static play int, double Velocity(Weapon w)
	{
		if (!w || !isRS(w)) return SRC_UNKNOWN, 0.0;
		if (lockedBy(w, "LockedVelocity")) return SRC_MASKED, 0.0;

		double vel;
		if (level.GetFieldFloat(w, "Velocity", vel))
			return SRC_DECLARED, vel;
		return SRC_UNKNOWN, 0.0;
	}

	//==========================================================================
	// CONDITION. RS Weapon only, never cursed, and the one stat here that
	// earns the sheet's gauge -- a bar IS a number, so a maskable stat could
	// never carry one without leaking exactly what the mask hides.
	static play int, double Condition(Weapon w)
	{
		if (!w || !isRS(w)) return SRC_UNKNOWN, 0.0;

		double cnd;
		if (level.GetFieldFloat(w, "Condition", cnd))
			return SRC_DECLARED, cnd;
		return SRC_UNKNOWN, 0.0;
	}

	//==========================================================================
	// DPS, derived rather than resolved.
	//
	// MASKS WITH ITS SOURCE. RS_Screens.zs:287-288 is explicit that DPS is
	// derived from damage and must hide when damage does, "otherwise it
	// leaks the exact number the curse is concealing" -- DPS is damage x
	// pellets x rate, and the other two are never cursed, so an unmasked DPS
	// is the cursed damage after two divisions.
	//
	// Returns the range, because damage is a range.
	static play int, int, int Dps(Weapon w)
	{
		int dsrc, dlo, dhi;
		[dsrc, dlo, dhi] = Damage(w);
		if (dsrc == SRC_MASKED)  return SRC_MASKED, 0, 0;
		if (dsrc == SRC_UNKNOWN) return SRC_UNKNOWN, 0, 0;

		int psrc, pel;
		[psrc, pel] = Pellets(w);
		if (pel < 1) pel = 1;

		int rsrc; double rps;
		[rsrc, rps] = Rof(w);
		if (rsrc == SRC_UNKNOWN || rps <= 0.0) return SRC_UNKNOWN, 0, 0;

		// The weakest source wins: a DPS built partly from observation is an
		// observed DPS, not a declared one.
		int src = (dsrc < rsrc) ? dsrc : rsrc;
		if (psrc != SRC_UNKNOWN && psrc < src) src = psrc;

		return src, int(double(dlo * pel) * rps), int(double(dhi * pel) * rps);
	}

	//==========================================================================
	// A number and its range as one string, so every caller words a range
	// the same way. low == high collapses to a single figure rather than
	// printing "12-12".
	static string Span(int lo, int hi)
	{
		return (lo == hi) ? String.Format("%d", lo) : String.Format("%d-%d", lo, hi);
	}

	// The suffix that says an observed number is a floor rather than a
	// count. Empty for anything declared.
	static string FloorMark(int src)
	{
		return (src == SRC_OBSERVED) ? "+" : "";
	}
}
