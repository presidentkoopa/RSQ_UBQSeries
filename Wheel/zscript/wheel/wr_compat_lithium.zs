// LITHIUM COMPATIBILITY.
//
// Lithium (1.7.0 "Nevermind", by Marrub/Alison, CC0) is a total conversion
// built as SEVEN separate player characters -- Lane the Marine, Jem the
// CyberMage, Fulk the Informant, Luke the Wanderer, Omi the Assassin, Ari
// the Dark Lord, Kiri of Thoth -- each with its own weapon set, plus an RPG
// layer (level, seven attributes, a 76-entry upgrade tree, a shop) written
// in C and compiled to ACS.
//
// That split decides this whole file. The ZScript half is the actors, and
// the moment-to-moment state a card actually wants -- magazines, mana, heat,
// charge, spin-up, status effects -- is on them and fully readable. The
// progression half is ACS module memory and is invisible to reflection; the
// one sanctioned door into it is guarded at the bottom of this file.
//
// NO RARITY OR TIER LADDER, established from both sides: nothing on
// Lith_Weapon orders weapons by quality, and the ACS upgrade record carries
// four binary flags with no ordering. So like wr_compat_combinedarms.zs and
// wr_compat_finaldoomer.zs this NEVER touches tierColorOf()/cardColorFor()
// or the sheet's title row -- purely supplementary rows.
//
// TWO STRUCTURAL FACTS THAT SHAPE EVERYTHING BELOW:
//
//  1. A LITHIUM WEAPON NEVER LIES ON THE FLOOR AS ITSELF. Lith_Weapon's
//     postBeginPlay spawns a slot-generic pickup stand-in and then destroys
//     any instance with no Owner (Weapons/Base.zsc:128-143 -- the destroy()
//     is outside the if). So the "readable even for an unowned weapon on the
//     floor" case that DOOM Infinite made possible does not exist here at
//     all. Every row in this file requires an OWNED weapon.
//
//  2. NO LITHIUM WEAPON SETS VANILLA Weapon.AmmoType1. A grep of the whole
//     mod finds no AmmoType1/AmmoUse1 anywhere; Lithium uses its own
//     Lith_Weapon.AmmoType, backed by a `meta` field, and meta fields are
//     rejected by reflection by design. So the sheet's generic ammo row
//     shows nothing mod-wide, and the weapon->ammo mapping here has to be a
//     hardcoded table read against the owner's inventory instead.
class wr_CompatLithium
{
	// Lithium's own caps, from its DECORATE/ZScript defaults. Read from the
	// LIVE instance wherever one exists -- these are the fallbacks for when
	// it does not, never a substitute for the real MaxAmount.
	const MANA_MAX     = 1000;
	const SMG_HEAT_MAX = 500;   // 4_SMG.zsc:88
	const SMG_HEAT_HOT = 450;   // fire aborts at or above this
	const SMG_VENT_MIN = 200;   // manual vent refuses below this
	const AUTORELOAD_TICS = 175; // OutcastsWeapon.zsc -- 5s, counts UP
	const REMS_VENT_MAX = 175;  // 7_Rems.zsc:243
	const ION_VENT_AT   = 1.3;  // 5_IonRifle.zsc:278, >= not >

	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	private static bool active(Weapon w)
	{
		return w && w.Owner && cv("wr_lith_compat", 1.0) > 0.0;
	}

	private static string clsOf(Object o)
	{
		return o ? ("" .. o.GetClassName()) : "";
	}

	//==========================================================================
	// PRIMITIVES.
	//
	// Two different inventory walks, and using the wrong one silently finds
	// nothing. The plain walk finds the six ammo pools and the IDOL itself.
	// ARMOR AND EVERY OTHER LITHIUM ITEM lives one level deeper, attached
	// under a Lith_IDOL container rather than the player
	// (Items/Inventory.zsc:176-182), so it needs idolItemOf().

	private static bool, int, int itemOf(Actor owner, string cls)
	{
		if (!owner) return false, 0, 0;
		for (Inventory it = owner.Inv; it; it = it.Inv)
		{
			if (clsOf(it) == cls) return true, it.Amount, it.MaxAmount;
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

	// The IDOL container itself, or null. Everything Lithium considers a real
	// inventory item hangs off this rather than off the player.
	private static Inventory idolOf(Actor owner)
	{
		if (!owner) return null;
		for (Inventory it = owner.Inv; it; it = it.Inv)
		{
			if (clsOf(it) == "Lith_IDOL") return it;
		}
		return null;
	}

	// Walks the IDOL's contents for the first item whose class name STARTS
	// WITH the given prefix -- armor classes are Lith_Armor<Kind>, and the
	// kind is part of the name rather than a field.
	private static Inventory idolFind(Actor owner, string prefix)
	{
		let idol = idolOf(owner);
		if (!idol) return null;
		int n = prefix.Length();
		for (Inventory it = idol.Inv; it; it = it.Inv)
		{
			string c = clsOf(it);
			if (int(c.Length()) >= n && c.Mid(0, n) == prefix) return it;
		}
		return null;
	}

	//==========================================================================
	// IS THIS EVEN LITHIUM.
	//
	// By CLASS ANCESTRY, never by referencing a Lithium symbol -- the same
	// string-walk wr_compat_drla.zs uses, and the reason this mod has no
	// compile-time dependency on any of the mods it reads.
	static bool IsLithium(Weapon w)
	{
		if (!w) return false;
		for (Class<Object> c = w.GetClass(); c; c = c.GetParentClass())
		{
			if (("" .. c.GetClassName()) == "Lith_Weapon") return true;
		}
		return false;
	}

	private static bool ready(Weapon w)
	{
		return active(w) && IsLithium(w);
	}

	//==========================================================================
	// WHO THE PLAYER IS.
	//
	// FOUND, PCLASS (0..6), DISCRIM ("Lane"/"Jem"/...). Both are plain fields
	// on Lith_Player (Player/Base.zsc:23-24) -- m_discrim is the character's
	// actual name, which is nicer on a card than the class word.
	static bool, int, string CharacterOf(Weapon w)
	{
		if (!ready(w)) return false, -1, "";
		int pc;
		if (!level.GetFieldInt(w.Owner, "m_pclass", pc)) return false, -1, "";
		string dis;
		level.GetFieldString(w.Owner, "m_discrim", dis);
		return true, pc, dis;
	}

	static string ClassWord(int pclass)
	{
		switch (pclass)
		{
			case 0: return "MARINE";
			case 1: return "CYBERMAGE";
			case 2: return "INFORMANT";
			case 3: return "WANDERER";
			case 4: return "ASSASSIN";
			case 5: return "DARK LORD";
			case 6: return "THOTH";
		}
		return "";
	}

	// THE WEAPON'S DISPLAY NAME, and the reason this is not just GetTag():
	// six weapons have no LITH_INFO_SHORT_* entry in the mod's language.txt,
	// and GZDoom's string table returns the KEY on a miss. So GetTag() on
	// those six literally hands back "LITH_INFO_SHORT_Flintlock". Detect the
	// raw key and substitute a real name.
	//
	// FOUND, NAME.
	static bool, string NameOf(Weapon w)
	{
		if (!ready(w)) return false, "";
		string tag = w.GetTag();
		if (tag.Length() == 0) return false, "";
		if (tag.Length() >= 5 && tag.Mid(0, 5) == "LITH_")
		{
			string c = clsOf(w);
			if (c == "Lith_Flintlock")   return true, "FLINTLOCK";
			if (c == "Lith_Magnum")      return true, "MAGNUM";
			if (c == "Lith_DualPistols") return true, "DUAL PISTOLS";
			if (c == "Lith_BurstRifle")  return true, "BURST RIFLE";
			if (c == "Lith_RiotShotgun") return true, "RIOT SHOTGUN";
			if (c == "Lith_RedRifle")    return true, "RED RIFLE";
			return false, "";   // an unknown raw key is worse than no row
		}
		return true, tag;
	}

	//==========================================================================
	// WHAT A PICKUP ON THE FLOOR WOULD ACTUALLY GIVE YOU.
	//
	// This is the answer to the structural problem in the file header: a
	// Lithium weapon deletes itself when unowned, so what is lying on the
	// ground is one of exactly NINE slot-generic Lith_*Pickup actors. The
	// pickup itself does not know what it will become -- it calls into ACS,
	// which switches on the player's class and hands back a weapon.
	//
	// So resolving "what is that on the floor" needs the pickup AND the
	// character, and the mapping is a 9x7 table transcribed from Lithium's
	// own Wep_FromName (lsource/p_weaponinfo.c:67-156).
	//
	// ONLY 30 OF THE 63 PAIRS GIVE ANYTHING. Lithium fills the rest with a
	// Marine-restricted fist as a "nothing for you" sentinel, so the
	// Informant and Wanderer get exactly one weapon from the floor, the
	// Assassin two, and THOTH GETS NOTHING FROM ANY PICKUP AT ALL. Reporting
	// that honestly is the point of this reader -- an empty answer here is
	// real information, not a failed lookup.
	//
	// FOUND (is a Lithium pickup), NAME ("" when this character gets nothing).
	static bool, string PickupOf(Actor a, PlayerPawn who)
	{
		if (!a || !who || cv("wr_lith_compat", 1.0) <= 0.0) return false, "";

		bool isPickup = false;
		for (Class<Object> c = a.GetClass(); c; c = c.GetParentClass())
		{
			if (("" .. c.GetClassName()) == "Lith_WeaponPickup") { isPickup = true; break; }
		}
		if (!isPickup) return false, "";

		int pc;
		if (!level.GetFieldInt(who, "m_pclass", pc)) return true, "";

		// Thoth is unfinished content -- its two weapons exist as classes but
		// nothing in the mod can ever grant them.
		if (pc == 6) return true, "";

		string p = "" .. a.GetClassName();

		if (p == "Lith_FistPickup")
			return true, (pc == 0) ? "FIST" : (pc == 1) ? "CHARGE FIST"
			           : (pc == 5) ? "KHANDA" : "";

		if (p == "Lith_ChainsawPickup")
			return true, (pc == 0 || pc == 1) ? "CHARGE FIST"
			           : (pc == 5) ? "KAMPILAN" : "";

		// The only pickup every character but Thoth can use.
		if (p == "Lith_PistolPickup")
			return true, (pc == 0) ? "PISTOL" : (pc == 1) ? "MATEBA"
			           : (pc == 2) ? "FLINTLOCK" : (pc == 3) ? "MAGNUM"
			           : (pc == 4) ? "DUAL PISTOLS" : "700 EXPRESS";

		if (p == "Lith_ShotgunPickup")
			return true, (pc == 0) ? "SHOTGUN" : (pc == 1) ? "SHOCK RIFLE"
			           : (pc == 5) ? "SHRAPNEL GUN" : "";

		if (p == "Lith_SuperShotgunPickup")
			return true, (pc == 0) ? "SUPER SHOTGUN" : (pc == 1) ? "SPAS"
			           : (pc == 5) ? "4 BORE" : "";

		if (p == "Lith_ChaingunPickup")
			return true, (pc == 0) ? "COMBAT RIFLE" : (pc == 1) ? "SMG"
			           : (pc == 4) ? "BURST RIFLE" : (pc == 5) ? "MINIGUN" : "";

		if (p == "Lith_RocketLauncherPickup")
			return true, (pc == 0) ? "GRENADE LAUNCHER" : (pc == 1) ? "ION RIFLE"
			           : (pc == 5) ? "DUAL ROCKET" : "";

		if (p == "Lith_PlasmaRiflePickup")
			return true, (pc == 0) ? "PLASMA RIFLE" : (pc == 1) ? "PLASMA RIFLE"
			           : (pc == 5) ? "FORTUNE GUN" : "";

		if (p == "Lith_BFG9000Pickup")
			return true, (pc == 0) ? "BFG9000" : (pc == 1) ? "STAR DESTROYER"
			           : (pc == 5) ? "REMS" : "";

		return true, "";
	}

	//==========================================================================
	// THE UNIVERSAL LAYER -- one reader, all 48 weapons.

	// MAGAZINE. m_fired counts UP (shots SPENT), m_max is capacity, so what
	// the player wants is m_max - m_fired. Lithium's own emptiness test is
	// `m_fired >= m_max` (Weapons/Base.zsc:164), which is what proves the
	// direction rather than assuming it.
	//
	// THREE WEAPONS ARE EXCLUDED BY NAME, each for its own real reason:
	//   Kampilan  -- its m_fired is a 0..5 BONK COMBO, not a magazine, and
	//                its MagSize 5 matching the combo cap is a coincidence.
	//                Higher is BETTER there, the opposite polarity. See
	//                ComboOf() below, which is where it actually belongs.
	//   Flintlock -- has no Reload state and no WRF_ALLOWRELOAD, so once
	//                m_fired reaches 2 it stays there forever. The counter is
	//                a lie rather than a low magazine.
	//   SPAS      -- with one upgrade it skips the increment entirely and
	//                reads a permanently full 8/8. The upgrade bit is not
	//                readable, so the row cannot be made honest.
	//
	// m_max == 0 means NO MAGAZINE (27 of 48 weapons), not an empty gun.
	//
	// FOUND, REMAINING, CAPACITY.
	static bool, int, int MagazineOf(Weapon w)
	{
		if (!ready(w)) return false, 0, 0;

		string c = clsOf(w);
		if (c == "Lith_Kampilan" || c == "Lith_Flintlock" || c == "Lith_SPAS")
			return false, 0, 0;

		int mx;
		if (!level.GetFieldInt(w, "m_max", mx) || mx <= 0) return false, 0, 0;

		int fired;
		level.GetFieldInt(w, "m_fired", fired);
		return true, clamp(mx - fired, 0, mx), mx;
	}

	// AIM STATE. An ENUM (0 hip / 1 scope / 2 irons), never a magnitude --
	// see Weapons/Base.zsc:73-77. Live only on the weapon actually in hand.
	//
	// FOUND, WORD.
	static bool, string AdsOf(Weapon w)
	{
		if (!ready(w)) return false, "";
		int a;
		if (!level.GetFieldInt(w, "m_ads", a) || a <= 0) return false, "";
		return true, (a == 1) ? "SCOPED" : "IRON SIGHTS";
	}

	// HITSCAN OR PROJECTILE, and it is LIVE rather than a static property --
	// six weapons rewrite this bit as they change fire mode, so it answers
	// "what is this gun doing right now", which is the useful question.
	//
	// bHitScan is a flagdef over m_flags bit 0 (Weapons/Base.zsc:104); this
	// fork's GetFieldBool reads flagdef bits directly.
	//
	// FOUND, HITSCAN.
	static bool, bool HitscanOf(Weapon w)
	{
		if (!ready(w)) return false, false;
		int hs;
		if (level.GetFieldBool(w, "bHitScan", hs)) return true, hs != 0;

		int fl;   // fallback for a build where the flagdef does not resolve
		if (level.GetFieldInt(w, "m_flags", fl)) return true, (fl & 1) != 0;
		return false, false;
	}

	// BACKGROUND AUTO-RELOAD, and the one row here built specifically for a
	// WHEEL rather than for a HUD: this counter ticks on weapons the player
	// is NOT holding. A stowed gun with a part-spent magazine quietly
	// refills after five seconds, and browsing the ring is exactly when you
	// would want to know a gun is nearly ready again.
	//
	// Counts UP toward 175, so it is time ELAPSED -- the remaining seconds
	// are (175 - tics)/35, not tics/35.
	//
	// FOUND, SECONDS REMAINING.
	static bool, int AutoReloadOf(Weapon w)
	{
		if (!ready(w)) return false, 0;

		// Only meaningful for a stowed weapon -- on the held gun the counter
		// is inert and the ordinary magazine row already says everything.
		let pp = PlayerPawn(w.Owner);
		if (pp && pp.player && pp.player.ReadyWeapon == w) return false, 0;

		int t;
		if (!level.GetFieldInt(w, "m_autoReloadTics", t) || t <= 0) return false, 0;
		int left = AUTORELOAD_TICS - t;
		if (left <= 0) return false, 0;
		return true, left / 35 + 1;
	}

	//==========================================================================
	// AMMO -- hardcoded table plus a plain inventory walk.
	//
	// Necessary because Lithium never sets vanilla AmmoType1 and its own
	// AmmoType is a `meta` field, which reflection rejects by design. The
	// pools themselves are ordinary Inventory items GIVEN TO EVERY PLAYER AT
	// AMOUNT 0 ON SPAWN (Player/Base.zsc:191-198), so they always exist and
	// Amount/MaxAmount always resolve.
	//
	// READ MaxAmount OFF THE LIVE INSTANCE. Lith_Backpack assigns
	// `inv.maxAmount = def.maxAmount * 2` for the five non-mana pools
	// (Items/Artifacts.zsc:422-436), so a hardcoded cap would misreport a
	// backpacked player by half. Mana is deliberately not in that list.
	//
	// This table is taken from the shipped ZScript, NOT from the mod's own
	// lsource/p_weaponinfo.c, which is stale on at least two entries (it
	// lists Blade as mana and the Flintlock as shells; neither is true of
	// the actual weapon classes).
	private static string ammoClassFor(string wep)
	{
		if (wep == "Lith_Revolver" || wep == "Lith_CombatRifle"
		 || wep == "Lith_SniperRifle" || wep == "Lith_ShockRifle"
		 || wep == "Lith_Minigun")          return "Lith_BulletAmmo";

		if (wep == "Lith_Shotgun" || wep == "Lith_SuperShotgun"
		 || wep == "Lith_SPAS" || wep == "Lith_4Bore"
		 || wep == "Lith_ShrapnelGun")      return "Lith_ShellAmmo";

		if (wep == "Lith_GrenadeLauncher" || wep == "Lith_IonRifle"
		 || wep == "Lith_DualRocket" || wep == "Lith_MissileLauncher")
			return "Lith_RocketAmmo";

		if (wep == "Lith_PlasmaRifle" || wep == "Lith_CPlasmaRifle"
		 || wep == "Lith_FortuneGun" || wep == "Lith_PlasmaDiffuser")
			return "Lith_PlasmaAmmo";

		if (wep == "Lith_BFG9000" || wep == "Lith_StarDestroyer"
		 || wep == "Lith_Rems")             return "Lith_CannonAmmo";

		if (wep == "Lith_Delear" || wep == "Lith_Feuer" || wep == "Lith_Rend"
		 || wep == "Lith_Hulgyon" || wep == "Lith_StarShot"
		 || wep == "Lith_Cercle")           return "Lith_ManaAmmo";

		// Blade is genuinely free -- it declares no AmmoType at all, unlike
		// the other six spells. Everything else here simply has no pool.
		return "";
	}

	private static string ammoWordFor(string cls)
	{
		if (cls == "Lith_BulletAmmo") return "BULLETS";
		if (cls == "Lith_ShellAmmo")  return "SHELLS";
		if (cls == "Lith_RocketAmmo") return "ROCKETS";
		if (cls == "Lith_PlasmaAmmo") return "PLASMA";
		if (cls == "Lith_CannonAmmo") return "CANNON";
		if (cls == "Lith_ManaAmmo")   return "MANA";
		return "AMMO";
	}

	// FOUND, WORD, AMOUNT, MAX.
	static bool, string, int, int AmmoOf(Weapon w)
	{
		if (!ready(w)) return false, "", 0, 0;
		string pool = ammoClassFor(clsOf(w));
		if (pool.Length() == 0) return false, "", 0, 0;

		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, pool);
		if (!got) return false, "", 0, 0;
		return true, ammoWordFor(pool), n, mx;
	}

	//==========================================================================
	// PLAYER-SIDE ROWS.

	// INCOMING DAMAGE REDUCTION, as a percentage. The ONLY window onto
	// Lithium's attribute system that needs no ACS call at all: the ACS side
	// mirrors it onto the pawn every tick via SetUserVariable
	// (lsource/p_player.c:644), and this fork lets reflection read any
	// declared field regardless of who wrote it.
	//
	// Range 0..100, and at 100 all damage becomes exactly 1, not 0.
	//
	// FOUND, PERCENT.
	static bool, int DamageFacOf(Weapon w)
	{
		if (!ready(w)) return false, 0;
		int f;
		if (!level.GetFieldInt(w.Owner, "m_DmgFac", f) || f <= 0) return false, 0;
		return true, clamp(f, 0, 100);
	}

	// MOVEMENT SPEED PERCENT -- also ACS-mirrored, every tick.
	//
	// THE BASELINE IS NOT 100 AND IT DIFFERS PER CHARACTER (Marine 70,
	// CyberMage 70, Dark Lord 45, the other four 100), so this must never be
	// coloured as a debuff for being under 100 and must never be compared
	// across characters. Reported raw, with that judgement left to the row.
	//
	// FOUND, PERCENT.
	static bool, int SpeedOf(Weapon w)
	{
		if (!ready(w)) return false, 0;
		int s;
		if (!level.GetFieldInt(w.Owner, "m_speed", s) || s <= 0) return false, 0;
		return true, s;
	}

	// THE ABSORBING SHIELD POOL. Live (Player/Damage.zsc:32-36), written
	// from ACS, regenerating +1 every 3 tics -- but ONLY the Dark Lord's CBI
	// shield upgrade ever grants any, so it reads 0 for everyone else, which
	// is what the > 0 gate is for rather than a character check.
	//
	// Its maximum lives in ACS and is not readable, so this is a bare value
	// and never a fraction.
	//
	// FOUND, AMOUNT.
	static bool, int ShieldOf(Weapon w)
	{
		if (!ready(w)) return false, 0;
		int s;
		if (!level.GetFieldInt(w.Owner, "m_shield", s) || s <= 0) return false, 0;
		return true, s;
	}

	// ARMOUR. Reachable, but only through the IDOL container -- a plain
	// owner walk finds the ammo pools and nothing else.
	//
	// m_curSave is the live save value (1..6, applied as up to 12 against a
	// matching damage type). m_save1 is DELIBERATELY NOT READ: it is never
	// consulted at runtime, so printing it would be inventing a stat.
	//
	// FOUND, NAME, SAVE.
	static bool, string, int ArmorOf(Weapon w)
	{
		if (!ready(w)) return false, "", 0;
		let arm = idolFind(w.Owner, "Lith_Armor");
		if (!arm) return false, "", 0;

		int save;
		level.GetFieldInt(arm, "m_curSave", save);
		if (save <= 0) return false, "", 0;

		string nm;
		if (!level.GetFieldString(arm, "m_invName", nm) || nm.Length() == 0)
			nm = "ARMOR";
		return true, nm, save;
	}

	//==========================================================================
	// STATUS EFFECTS.
	//
	// Lith_StatFx is a THINKER -- not an Actor, not an Inventory item -- so
	// none of the walks above find it. It is reached with a ThinkerIterator
	// over Lithium's own statnum, and read through the same field accessors,
	// which take a plain Object rather than an Actor.
	//
	// `snam` is already the three-letter badge Lithium's own HUD draws (MKM,
	// ACC, SWR, SWD, SKP...), so no class-name-to-badge table is needed.
	// tics == -1 means PERMANENT, not expired.
	//
	// This single reader is what makes the Wanderer and the Khanda legible
	// at all, since both of those mechanics live entirely in this pool.
	//
	// FOUND, TEXT.
	static bool, string StatusOf(Weapon w)
	{
		if (!ready(w)) return false, "";

		let fxc = (class<Thinker>)(Object.FindClass("Lith_StatFx"));
		if (!fxc) return false, "";

		string s = "";
		let it = ThinkerIterator.Create(fxc, Thinker.STAT_USER + 8);
		Thinker t;
		while (t = it.Next())
		{
			// The pool is global, with no per-player filter on Lithium's own
			// side either -- so the owner check has to happen here.
			Object who;
			if (level.GetFieldObject(t, "plyr", who) && who && who != w.Owner)
				continue;

			string nm;
			if (!level.GetFieldString(t, "snam", nm) || nm.Length() == 0) continue;

			int tics, cnt;
			level.GetFieldInt(t, "tics", tics);
			level.GetFieldInt(t, "cnt0", cnt);

			string e = nm;
			if (cnt > 1) e = e .. String.Format(" x%d", cnt);
			if (tics > 0) e = e .. String.Format(" %ds", tics / 35 + 1);
			else if (tics < 0) e = e .. " *";   // permanent

			s = s.Length() ? (s .. "  " .. e) : e;
		}
		return s.Length() > 0, s;
	}

	//==========================================================================
	// MARINE.

	// CHARGE FIST. A player-owned Inventory counter with MaxAmount int.max
	// (Weapons/1_ChargeFist.zsc:10) -- so this is an ABSOLUTE number and
	// must never be drawn as a percentage of anything.
	//
	// FOUND, CHARGE.
	static bool, int ChargeFistOf(Weapon w)
	{
		// Same shape, same fix: Lith_FistCharge is player-owned, so the Marine's
		// CHARGE row printed on every Lithium weapon card. Audit finding #39.
		// PREFIX, not an exact name: the only reference in this file is
		// "Lith_FistPickup", so the weapon class itself is inferred rather than
		// confirmed. A prefix still catches a variant and still refuses every
		// other Lithium weapon, which is the whole point -- an exact name that
		// turned out wrong would trade a visible leak for a silent absence.
		// Mid(0,n), not Left(): this file has no Left helper -- that one is private
		// to wr_compat_finaldoomer.
		string fc = clsOf(w);
		if (!ready(w) || fc.Length() < 9 || fc.Mid(0, 9) != "Lith_Fist") return false, 0;
		int n = amountOf(w.Owner, "Lith_FistCharge");
		if (n <= 0) return false, 0;
		return true, n;
	}

	// REACTIVE ARMOUR. Exactly one Lith_RA_<Type><1|2> Powerup is held at a
	// time, and THE CLASS NAME ITSELF carries both the damage type and the
	// tier -- tier 1 cuts 30%, tier 2 cuts 50%. So this is a walk-and-report
	// rather than a lookup table.
	//
	// FOUND, TEXT.
	static bool, string ReactiveArmorOf(Weapon w)
	{
		if (!ready(w) || !w.Owner) return false, "";
		for (Inventory it = w.Owner.Inv; it; it = it.Inv)
		{
			string c = clsOf(it);
			if (c.Length() > 8 && c.Mid(0, 8) == "Lith_RA_")
			{
				string body = c.Mid(8);
				int n = body.Length();
				string tier = (n > 0) ? body.Mid(n - 1) : "";
				string kind = (n > 0) ? body.Mid(0, n - 1) : body;
				return true, String.Format("%s %s", kind, tier == "2" ? "50%" : "30%");
			}
		}
		return false, "";
	}

	// GRENADE LAUNCHER: rockets chambered, and which of three firing shapes
	// the next volley uses. Both plain fields (5_RocketLauncher.zsc:102,104).
	//
	// FOUND, LOADED, MODE WORD.
	static bool, int, string GrenadeOf(Weapon w)
	{
		if (!ready(w) || clsOf(w) != "Lith_GrenadeLauncher") return false, 0, "";
		int loaded, mode;
		if (!level.GetFieldInt(w, "m_Loaded", loaded)) return false, 0, "";
		level.GetFieldInt(w, "m_Mode", mode);
		string word = (mode == 2) ? "BOUNCING" : (mode == 1) ? "SPIRAL" : "SPREAD";
		return true, loaded, word;
	}

	// COMBAT RIFLE grenade tube -- a persistent "spent, waiting on reload"
	// state independent of the magazine, so it survives long enough to be
	// worth a row (unlike m_Burst, which lives about fifteen tics).
	//
	// FOUND, READY.
	static bool, bool GrenadeTubeOf(Weapon w)
	{
		if (!ready(w) || clsOf(w) != "Lith_CombatRifle") return false, false;
		int spent;
		if (!level.GetFieldBool(w, "m_GrenFire", spent)) return false, false;
		return true, spent == 0;
	}

	// MISSILE LAUNCHER barrel spin, 0..6 (clamped to 5 in use).
	//
	// FOUND, SPIN, MAX.
	static bool, int, int MissileSpinOf(Weapon w)
	{
		if (!ready(w) || clsOf(w) != "Lith_MissileLauncher") return false, 0, 0;
		int n;
		if (!level.GetFieldInt(w, "m_Reset", n) || n <= 0) return false, 0, 0;
		return true, min(n, 5), 5;
	}

	//==========================================================================
	// CYBERMAGE.

	// MANA. A plain Inventory pool -- exactly how Lithium's own HUD reads it.
	// Never backpack-doubled, unlike the five ballistic pools.
	//
	// FOUND, MANA, MAX.
	static bool, int, int ManaOf(Weapon w)
	{
		if (!ready(w)) return false, 0, 0;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "Lith_ManaAmmo");
		if (!got) return false, 0, 0;
		return true, n, mx > 0 ? mx : MANA_MAX;
	}

	// CERCLE, the class's ultimate: it fires only when mana is EXACTLY full
	// and then spends the entire pool. So "ready" is a real binary state the
	// player otherwise has to eyeball off a bar, and it needs no reflection
	// at all.
	//
	// FOUND, READY.
	static bool, bool CercleOf(Weapon w)
	{
		if (!ready(w) || clsOf(w) != "Lith_Cercle") return false, false;
		bool got; int n, mx;
		[got, n, mx] = ManaOf(w);
		if (!got) return false, false;
		return true, (n >= mx && mx > 0);
	}

	// THE SPELL'S MANA COST. Call arguments rather than fields, so this is a
	// hardcoded table -- but the cost is the single thing that decides
	// whether a spell is castable, and it is the reason the mana row exists.
	//
	// FOUND, COST, PER-RELOAD (rather than per-cast).
	static bool, int, bool SpellCostOf(Weapon w)
	{
		if (!ready(w)) return false, 0, false;
		string c = clsOf(w);
		if (c == "Lith_Blade")    return true, 0,    false;  // genuinely free
		if (c == "Lith_Delear")   return true, 25,   true;
		if (c == "Lith_Feuer")    return true, 30,   false;
		if (c == "Lith_Rend")     return true, 10,   false;
		if (c == "Lith_Hulgyon")  return true, 50,   false;
		if (c == "Lith_StarShot") return true, 100,  true;
		if (c == "Lith_Cercle")   return true, MANA_MAX, false;
		return false, 0, false;
	}

	// THE CHARGE FIST'S REAL JOB. It cannot attack at all -- it is a battery,
	// regenerating +4 mana every 7 tics. Worth saying on its card precisely
	// because the weapon looks broken otherwise.
	static bool IsManaBattery(Weapon w)
	{
		return ready(w) && clsOf(w) == "Lith_CFist";
	}

	// SMG HEAT. A player-owned pool, 0..500. Heat accrues on EVERY shot --
	// the upgrade that looks like it gates this actually only gates the
	// fire-abort, confirmed against the jump target rather than assumed.
	//
	// FOUND, HEAT, MAX, LOCKED OUT.
	static bool, int, int, bool SmgHeatOf(Weapon w)
	{
		// CLASS-GATED, like every sibling reader here -- SmgSpreadOf, IonChargeOf,
		// WindUpOf, RemsOf, ShrapnelOf and ComboOf all carry one and this did not.
		//
		// Lith_SMGHeat is a PLAYER-owned pool, so reading it off w.Owner succeeds
		// for any Lithium weapon that reaches it: every card in the ring showed
		// the SMG's heat, and once past 450 showed LOCKED in dry-ammo red on
		// weapons that were not locked out at all. It also claimed the sheet's
		// single gauge, so the bar read another gun's heat. Audit finding #39.
		if (!ready(w) || clsOf(w) != "Lith_SMG") return false, 0, 0, false;
		bool got; int n, mx;
		[got, n, mx] = itemOf(w.Owner, "Lith_SMGHeat");
		if (!got) return false, 0, 0, false;
		int cap = mx > 0 ? mx : SMG_HEAT_MAX;
		return true, n, cap, (n >= SMG_HEAT_HOT);
	}

	// SMG SPREAD BLOOM. A MULTIPLIER where LOWER IS BETTER -- 0.1 is
	// pinpoint, 1.0 is worst. Never fed to a higher-is-better bar; the row
	// that prints it labels it SPREAD for exactly that reason.
	//
	// FOUND, SPREAD, WORST.
	static bool, double, double SmgSpreadOf(Weapon w)
	{
		if (!ready(w) || clsOf(w) != "Lith_SMG") return false, 0.0, 0.0;
		double r;
		if (!level.GetFieldFloat(w, "m_Recoil", r)) return false, 0.0, 0.0;
		return true, r, 1.0;
	}

	// ION RIFLE CHARGE, and it is DUAL-POLARITY: more charge is more damage
	// and more bolts, but 1.3 or above forces a vent. So the number is good
	// and bad at once and the row has to say which side of 1.3 it is on.
	//
	// Real range is 1.0..2.05 (a ten-step ladder), damage is charge * 300,
	// a second bolt at 1.5 and a third at 2.
	//
	// FOUND, CHARGE, WILL VENT.
	static bool, double, bool IonChargeOf(Weapon w)
	{
		if (!ready(w) || clsOf(w) != "Lith_IonRifle") return false, 0.0, false;
		double c;
		if (!level.GetFieldFloat(w, "m_Charge", c) || c <= 1.0) return false, 0.0, false;
		return true, c, (c >= ION_VENT_AT);
	}

	//==========================================================================
	// DARK LORD.

	// MINIGUN SPIN-UP. The cleanest gauge in the mod -- a genuine normalised
	// 0..1 that maps straight onto rate of fire. It is hard-zeroed the
	// instant the weapon stops being ready, so it reads 0 for a gun you are
	// merely browsing, which is honest rather than broken.
	//
	// FOUND, FRACTION, TICS PER SHOT.
	static bool, double, int WindUpOf(Weapon w)
	{
		if (!ready(w) || clsOf(w) != "Lith_Minigun") return false, 0.0, 0;
		double u;
		if (!level.GetFieldFloat(w, "m_windUp", u) || u <= 0.0) return false, 0.0, 0;
		return true, u, 1 + int((1.0 - u) * 10.0);
	}

	// KHANDA SKILL POWER -- while true the damage multiplier is FIFTY times.
	// The remaining duration is not on the weapon; it is the "SKP" entry in
	// the status pool, which StatusOf() already surfaces.
	//
	// FOUND, ACTIVE.
	static bool, bool KhandaOf(Weapon w)
	{
		if (!ready(w) || clsOf(w) != "Lith_Khanda") return false, false;
		int p;
		if (!level.GetFieldBool(w, "m_power", p)) return false, false;
		return true, p != 0;
	}

	// KAMPILAN BONK COMBO. This is the base m_fired REPURPOSED as a 0..5
	// stack, +10% swing damage each, which is why the magazine reader
	// excludes this weapon by name -- there, higher is worse; here, higher
	// is better.
	//
	// m_cooldownTics IS CLAMPED HERE BECAUSE IT GOES NEGATIVE AND STAYS
	// THERE: if a stack is gained against an invulnerable or dormant target
	// the timer is never set, and the decrement then walks it past zero
	// forever. That is Lithium's bug, not ours, but an unclamped read would
	// print it.
	//
	// FOUND, STACKS, MAX, COOLDOWN TICS.
	static bool, int, int, int ComboOf(Weapon w)
	{
		if (!ready(w) || clsOf(w) != "Lith_Kampilan") return false, 0, 0, 0;
		int n;
		if (!level.GetFieldInt(w, "m_fired", n)) return false, 0, 0, 0;
		int cd;
		level.GetFieldInt(w, "m_cooldownTics", cd);
		return true, clamp(n, 0, 5), 5, max(cd, 0);
	}

	// REMS VENTING, 0..175 -- slammed to full when a shot starts charging
	// and drained while venting, so it persists for seconds after firing and
	// is the closest thing this class has to a heat gauge.
	//
	// FOUND, VENT, MAX.
	static bool, int, int RemsOf(Weapon w)
	{
		if (!ready(w) || clsOf(w) != "Lith_Rems") return false, 0, 0;
		int s;
		if (!level.GetFieldInt(w, "m_steamy", s) || s <= 0) return false, 0, 0;
		return true, min(s, REMS_VENT_MAX), REMS_VENT_MAX;
	}

	// SHRAPNEL GUN CHARGE -- widens the pellet count as 7 + level*3/4.
	//
	// NOT CLEARED AFTER FIRING, so the honest label is "last charge" rather
	// than a live meter, and the caller words it that way.
	//
	// FOUND, LEVEL, PELLETS.
	static bool, int, int ShrapnelOf(Weapon w)
	{
		if (!ready(w) || clsOf(w) != "Lith_ShrapnelGun") return false, 0, 0;
		int c;
		if (!level.GetFieldInt(w, "m_chargeLevel", c) || c <= 0) return false, 0, 0;
		return true, c, 7 + c * 3 / 4;
	}

	//==========================================================================
	// ASSASSIN, INFORMANT, WANDERER.

	// BURST RIFLE SUSTAINED-FIRE FALLOFF. m_lessen is a DIVISOR -- lower is
	// better -- so what goes on the card is the derived current damage
	// (60, 51, 44, 39, 35 ...) rather than the raw number, which would read
	// backwards.
	//
	// FOUND, CURRENT DAMAGE, BASE.
	static bool, int, int FalloffOf(Weapon w)
	{
		if (!ready(w) || clsOf(w) != "Lith_BurstRifle") return false, 0, 0;
		double l;
		if (!level.GetFieldFloat(w, "m_lessen", l) || l <= 0.0) return false, 0, 0;
		return true, int(60.0 / l), 60;
	}

	// DODGE COOLDOWN. Counts DOWN and 0 MEANS READY, so this is inverted
	// against every other counter in the file.
	//
	// The field is declared SEPARATELY on the Informant (0..35) and the
	// Assassin (0..40) -- two different classes, not one inherited field --
	// which is why the max comes from the character rather than a constant.
	//
	// FOUND, TICS REMAINING, MAX.
	static bool, int, int DodgeOf(Weapon w)
	{
		if (!ready(w)) return false, 0, 0;
		bool got; int pc; string dis;
		[got, pc, dis] = CharacterOf(w);
		if (!got || (pc != 2 && pc != 4)) return false, 0, 0;

		int d;
		if (!level.GetFieldInt(w.Owner, "m_dodgeDbc", d)) return false, 0, 0;
		return true, max(d, 0), (pc == 2) ? 35 : 40;
	}

	// SPRINTING. The Assassin reads its OWN m_isSprinting rather than the
	// shared base field, and that is the one its weapons actually consult --
	// so the base field would be the wrong answer for exactly the character
	// who uses sprinting most.
	//
	// FOUND, SPRINTING.
	static bool, bool SprintOf(Weapon w)
	{
		if (!ready(w)) return false, false;
		int s;
		if (level.GetFieldBool(w.Owner, "m_isSprinting", s)) return true, s != 0;
		if (level.GetFieldBool(w.Owner, "m_sprinting", s))   return true, s != 0;
		return false, false;
	}

	// INVULNERABILITY FRAMES, set to 20 on each Informant dodge.
	//
	// FOUND, TICS.
	static bool, int IFramesOf(Weapon w)
	{
		if (!ready(w)) return false, 0;
		int f;
		if (!level.GetFieldInt(w.Owner, "m_iFrames", f) || f <= 0) return false, 0;
		return true, f;
	}

	//==========================================================================
	//==========================================================================
	// THE ACS DOOR.
	//
	// Everything above this line is field reflection and inventory walks --
	// no calls into Lithium at all. Everything below CALLS LITHIUM'S OWN ACS
	// SCRIPT 17002, and it is fenced accordingly.
	//
	// WHY THIS IS ALLOWED AT ALL, when wr_compat_borderdoom.zs refuses the
	// equivalent: BorderDoom's stat "getter" reached a line special that
	// mutated the player's ammo capacity. Script 17002 was disassembled out
	// of the shipped acs/lithmain.bin and contains NO LSPEC OPCODE ANYWHERE
	// in its 616-dword body -- the instruction that would perform that class
	// of side effect does not appear in the script, so the failure mode is
	// structurally absent rather than merely unobserved. The five info codes
	// used here each compile to push-address, index, load, return.
	//
	// WHAT IS STILL DANGEROUS IS THE BINDING, NOT THE CALLEE. We cannot name
	// the script; we send the bare integer 17002 and an index, and several
	// positional enums sit between those integers and their meaning, none of
	// them reserved or documented. Every drift outcome is SILENT -- a wrong
	// number, not an error. The guards below exist to turn every silent
	// wrong answer into a visible absence.
	//
	// SIX OF THE THIRTY-SIX INFO CODES WRITE SAVEGAME-PERSISTED STATE (a
	// fixed-point scratch global, one write per fixed-point case). None of
	// the five used here is among them, and infoAllowed() enforces that
	// rather than trusting the call sites.
	//
	// AND THE INDEX MUST BE CLAMPED BY US: Lithium does not bounds-check
	// pl.upgrades[] or pl.attr.attrs[], and GZDoom's global-array read is a
	// TMap operator[] whose GetNode INSERTS a default node on a miss
	// (tarray.h:1705-1716). So an out-of-range index does not merely return
	// garbage -- it permanently grows savegame-persisted state. Clamping is
	// load-bearing, not hygiene.

	const ACS_PDATA   = 17002;
	const LITH_TESTED = "1.7.0";   // the ONLY build audited

	// The five info codes this file is permitted to ask for.
	const PD_WEAPON    = 0;
	const PD_UPGRADE   = 1;
	const PD_RIFLEMODE = 2;
	const PD_HASSIGIL  = 3;
	const PD_ATTR      = 9;
	const PD_PTID      = 18;   // canary only

	const UPGRADE_MAX = 75;    // 76 upgrades, 0..75
	const ATTR_MAX    = 6;     // 7 attributes, 0..6

	private static bool infoAllowed(int info)
	{
		return info == PD_WEAPON || info == PD_UPGRADE || info == PD_RIFLEMODE
		    || info == PD_HASSIGIL || info == PD_ATTR || info == PD_PTID;
	}

	// IS THE ACS DOOR OPEN. All of the presence/version conditions, in the
	// order that fails cheapest first.
	//
	// PRESENCE IS TESTED BY CLASS, NOT BY CVAR, and that is deliberate:
	// Lithium's __lith_version cvar is `nosave` but NOT `noarchive`, so it
	// is written into the user's config and still reports a PREVIOUS
	// session's version when Lithium is not even loaded.
	//
	// THE VERSION TEST IS EXACT EQUALITY, NEVER >=. Newer is precisely when
	// the indices move, so a "1.7.0 or later" test would be backwards.
	static bool AcsOpen(Weapon w)
	{
		if (!ready(w)) return false;
		if (cv("wr_lith_acs", 0.0) <= 0.0) return false;   // OFF by default

		// A canary failure earlier this session latches the door shut.
		if (hasItem(w.Owner, "wr_LithAcsBlocked")) return false;

		// Presence: the owner must actually be a Lith_Player.
		bool isLith = false;
		for (Class<Object> c = w.Owner.GetClass(); c; c = c.GetParentClass())
		{
			if (("" .. c.GetClassName()) == "Lith_Player") { isLith = true; break; }
		}
		if (!isLith) return false;

		// Version: exact match only. Read LATE and never cached -- Lithium
		// writes this during its own init, so it reads stale until the first
		// map has loaded.
		let vc = CVar.FindCVar("__lith_version");
		if (!vc) return false;
		if (vc.GetString() != LITH_TESTED) return false;

		return true;
	}

	// THE RAW CALL. Every guard that can be enforced mechanically is
	// enforced here rather than at the call sites, so a future row cannot
	// bypass them by accident.
	private static play int pdata(Weapon w, int info, int perm)
	{
		if (!infoAllowed(info)) return 0;

		// Clamp per info code. See the header: an out-of-range index writes
		// savegame state, so this is the single most important line here.
		if (info == PD_UPGRADE) perm = clamp(perm, 0, UPGRADE_MAX);
		else if (info == PD_ATTR) perm = clamp(perm, 0, ATTR_MAX);
		else if (perm < 0) perm = 0;

		// Special 84 is ACS_ExecuteWithResult. Called through
		// Level.ExecuteSpecial rather than the bare action-special form so
		// the ACTIVATOR IS EXPLICIT -- this is exactly Lithium's own
		// Lith_UTIL.exec helper (Utilities.zsc:168-170), copied rather than
		// invented. The script does not actually depend on the activator
		// (pl is a module global reached by name, no PLAYERNUMBER opcode
		// anywhere in its body), but passing the real owner keeps this
		// honest if that ever changes.
		return level.ExecuteSpecial(84, w.Owner, null, false, ACS_PDATA, info, perm);
	}

	// THE CANARY. Run once, after the presence and version gates pass, to
	// catch the case where some OTHER mod owns script 17002 in this load
	// order. Honest about its own limit: it fires AFTER a first call has
	// already happened, so it detects a hijacked script rather than
	// preventing the first execution of one.
	//
	// On failure it gives the owner a marker item, which latches the door
	// shut for the session rather than retrying on every card build.
	static play bool AcsCanary(Weapon w)
	{
		if (!AcsOpen(w)) return false;

		// The player TID case must agree with the actor we already have.
		int tid = pdata(w, PD_PTID, 0);
		bool ok = (tid != 0 && tid == w.Owner.tid);

		// Every attribute must be a small sane number.
		if (ok)
		{
			for (int i = 0; i <= ATTR_MAX; ++i)
			{
				int a = pdata(w, PD_ATTR, i);
				if (a < 0 || a > 1000) { ok = false; break; }
			}
		}

		if (!ok)
		{
			let blk = (class<Inventory>)(Object.FindClass("wr_LithAcsBlocked"));
			if (blk) w.Owner.GiveInventory(blk, 1);
			return false;
		}
		return true;
	}

	// THE SEVEN ATTRIBUTES. Returned as one preformatted row -- they are a
	// stat block and read as one thing.
	//
	// FOUND, TEXT.
	static play bool, string AttributesOf(Weapon w)
	{
		if (!AcsCanary(w)) return false, "";

		string s = "";
		for (int i = 0; i <= ATTR_MAX; ++i)
		{
			int a = pdata(w, PD_ATTR, i);
			if (a <= 0) continue;
			string e = String.Format("%s %d", attrName(i), a);
			s = s.Length() ? (s .. "  " .. e) : e;
		}
		return s.Length() > 0, s;
	}

	// A switch rather than a static const array, matching PerkName() in
	// wr_compat_doominfinite.zs -- an unknown index falls through to an
	// empty string instead of reading past the end.
	private static string attrName(int i)
	{
		switch (i)
		{
			case 0: return "ACC";
			case 1: return "DEF";
			case 2: return "STR";
			case 3: return "VIT";
			case 4: return "STM";
			case 5: return "LUK";
			case 6: return "CLS";
		}
		return "";
	}

	// HOW MANY UPGRADES ARE ACTIVE, out of 76.
	//
	// THE RETURN IS A MASK, NOT A BOOLEAN -- the script returns `flags & 2`,
	// so this tests != 0 and never == 1. That distinction is the difference
	// between a correct count and a permanent zero.
	//
	// FOUND, ACTIVE, TOTAL.
	static play bool, int, int UpgradesOf(Weapon w)
	{
		if (!AcsCanary(w)) return false, 0, 0;

		int n = 0;
		for (int i = 0; i <= UPGRADE_MAX; ++i)
		{
			if (pdata(w, PD_UPGRADE, i) != 0) ++n;
		}
		return true, n, UPGRADE_MAX + 1;
	}

	// RIFLE FIRE MODE -- single / burst / auto, which changes how the
	// Marine's rifle behaves in hand and is invisible everywhere else.
	//
	// FOUND, WORD.
	static play bool, string RifleModeOf(Weapon w)
	{
		if (!AcsCanary(w)) return false, "";
		if (clsOf(w) != "Lith_CombatRifle") return false, "";

		int m = pdata(w, PD_RIFLEMODE, 0);
		switch (m)
		{
			case 0: return true, "SINGLE";
			case 1: return true, "BURST";
			case 2: return true, "AUTO";
		}
		return false, "";
	}

	// THE SIGIL, a one-line boolean.
	//
	// FOUND, HELD.
	static play bool, bool SigilOf(Weapon w)
	{
		if (!AcsCanary(w)) return false, false;
		return true, pdata(w, PD_HASSIGIL, 0) != 0;
	}
}

// The latch. Given to the player if the canary ever fails, so a bad or
// hijacked script 17002 disables the ACS rows for the rest of the session
// instead of being retried on every card build.
class wr_LithAcsBlocked : Inventory
{
	default
	{
		Inventory.Amount 1;
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.UNCLEARABLE
	}
}
