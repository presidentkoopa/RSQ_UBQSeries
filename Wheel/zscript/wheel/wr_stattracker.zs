// WEAPON STAT TRACKER.
//
// Everything else this wheel reads for the sheet -- RS Weapon's fields, the
// eight other mods' compat files -- is a READ: some other mod already
// computed the number, this wheel just asks for it by name. Nothing,
// anywhere, computes "kills with this gun" or "shots fired" or "was that a
// headshot" as a queryable field, including for RS Weapon's own arsenal.
// So this file is a TRACKER, not a compat reader: it watches the game as it
// happens and keeps its own running counters, per weapon INSTANCE, entirely
// independent of which mod (if any) that weapon came from.
//
// IDENTITY, WITHOUT A FIELD ON A CLASS WE DON'T OWN. The soft-dependency
// rule this whole mod follows means never subclassing another mod's weapon
// -- so there is nowhere to stamp an ID on the gun itself. Instead, the
// PLAYER carries a hidden ledger item (wr_StatLedger, below), and each
// entry in it holds a real Weapon object reference. Actor references are
// ordinary savegame-serialized fields -- the same mechanism that already
// keeps target/tracer/every inventory chain alive across a save/load -- so
// the exact gun you are holding when you save is still the exact gun with
// the exact same stats when you load. No new engine capability needed.
//
// ATTRIBUTION IS A GUESS, AND IT FAILS CLOSED. A WorldThingDamaged/
// WorldThingDied event does not say which of your two hands (this rig is
// genuinely dual-wielded -- player.ReadyWeapon AND player.OffhandWeapon are
// both real) caused it. attributedWeapon() below picks whichever hand's
// weapon fired most recently, inside a short window, and if both fired the
// same tic -- or neither fired recently enough to plausibly be the cause --
// it attributes to NEITHER rather than guess wrong. Same reasoning as a
// reload-sized ammo drop not being counted as one giant shot: an
// undercounted stat is honest; a misattributed one is a lie wearing a
// number.
//
// HEADSHOTS ONLY IF RS_HEADSHOTS IS ACTUALLY LOADED. That mod keeps no
// count of its own -- HS_Handler.WorldThingDamaged detects a headshot and
// calls HS_Marker.Confirm(), which spawns a cosmetic marker actor, plays a
// positional sound, and fades out. Nothing persists. So this counts
// HS_Marker spawns itself, via WorldThingSpawned -- zero duplicated
// hit-detection geometry, and the class simply not existing is what gates
// the row off when the mod is absent (HeadshotsOf's Object.FindClass check),
// exactly the same soft-dependency rule every compat file here follows.
//
// Its damage bonus needs one specific guard on the damage path -- see
// WorldThingDamaged below.
class wr_WeaponStats
{
	Weapon wpn;

	int kills;
	int shotsFired;
	int hits;
	int headshots;

	// NO TIME-HELD COUNTER. There was one, and it was removed on the owner's
	// call: a running total of how much of your life you have spent holding a
	// particular gun is not a statistic anybody asked to be shown.
	//
	// Removed rather than hidden. A counter that still accrues costs a write
	// per weapon per tic and a field in every ledger entry, saved and loaded
	// forever, to feed a row that no longer exists.

	// DAMAGE AS A RANGE, NOT AN AVERAGE. Most Doom weapons roll their
	// damage -- a pistol lands 5, 10 or 15, never "10" -- so averaging the
	// hits into one figure invents a number the weapon cannot actually
	// deal, and makes the reading depend on how many times you happened to
	// fire it. The lowest and highest that have actually landed ARE what
	// the gun does, are honest after eight shots and after eight hundred,
	// and simply tighten toward the true bounds as the extremes get found.
	//
	// damageSamples is kept even though nothing averages any more: it is
	// what says whether the range has anything in it at all.
	int damageLow;
	int damageHigh;
	int damageSamples;

	// MAGAZINE CAPACITY, OBSERVED. The obvious source, Ammo2.MaxAmount, is
	// the ammo CLASS's default rather than this weapon's own capacity, and
	// mods routinely give that headroom -- so a full magazine prints as a
	// fraction of a number it never reaches. The highest load this weapon
	// has ever actually been seen holding IS its capacity, needs no field
	// from any mod, and self-corrects if a mod changes the cap mid-run.
	int magHigh;

	// PELLETS, AND THIS ONE IS A FLOOR RATHER THAN A COUNT. Nothing reports
	// "that shot was eight pellets" -- there is no field and no event for
	// it -- so this counts how many separate hits landed inside a single
	// shot's window, which only ever finds the pellets that CONNECTED. A
	// shotgun fired at a wall reads low forever. Shown as "at least N", not
	// as the spread, because that is all it can honestly claim.
	int pelletMax;
	int pelletRun;

	// Ammo-drain shot detection needs a baseline to compare against, per
	// weapon, updated every tic that weapon is in a hand -- see
	// wr_StatEvents.trackFire().
	int lastAmmo1;
	int lastAmmo2;
	bool seenAmmo;
	int  lastPollTic;   // the tic this weapon's ammo was last polled -- see trackFire

	// Rate of fire, as an exponential moving average of tics between shots
	// rather than a straight average -- so a weapon's ROF reading tracks
	// its CURRENT firing pattern (burst vs. sustained) instead of being
	// dragged down by a slow first shot from ten minutes ago.
	int lastFireTic;
	double rofEma;

	// The window a shot leaves open for WorldThingDamaged to credit it as a
	// hit. Consumed by the first damage event that lands inside it, so a
	// ten-pellet shotgun blast counts as one hit against one shot fired,
	// not ten.
	int pendingHitUntilTic;
}

// PER-CLASS HISTORY, kept alongside the per-instance records above.
//
// The instance records answer "how has THIS gun gone", which is the right
// question for a weapon in your hands and useless for one on the floor --
// you have never held that one, so it has no history at all. This answers
// the next best question, and arguably the more useful one when deciding
// whether to pick something up: how have guns OF THIS KIND gone for you.
// "Your plasma rifles: 44% accuracy over two hours" is something no mod and
// no HUD in this game can tell you, and it survives the weapon itself being
// dropped, destroyed or left behind.
class wr_ClassStats
{
	Name cls;

	int kills;
	int shotsFired;
	int hits;
	int headshots;
	int damageLow;
	int damageHigh;
	int damageSamples;
}

// The hidden per-player carrier. Auto-granted lazily (wr_StatLedger.StatsFor
// grants it itself the first time anything asks, rather than depending
// solely on PlayerSpawned/PlayerEntered firing) so an existing save from
// before this file existed still picks it up the moment it matters.
class wr_StatLedger : Inventory
{
	Array<wr_WeaponStats> mStats;
	Array<wr_ClassStats>  mClassStats;

	default
	{
		Inventory.Amount 1;
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.UNCLEARABLE
	}

	// Finds (or, with create=true, makes) the record for one specific
	// weapon INSTANCE on one specific player. Prunes dead references on the
	// way past -- a weapon reference nulls itself out when the actor it
	// pointed to is destroyed, same as target/tracer anywhere else in the
	// engine, so a gun that got dropped and never picked back up just
	// quietly falls out of the ledger the next time anything looks.
	static play wr_WeaponStats StatsFor(PlayerPawn pawn, Weapon w, bool create)
	{
		if (!pawn || !w) return null;

		let ledger = wr_StatLedger(pawn.FindInventory("wr_StatLedger"));
		if (!ledger)
		{
			if (!create) return null;
			ledger = wr_StatLedger(pawn.GiveInventoryType("wr_StatLedger"));
			if (!ledger) return null;
		}

		for (int i = ledger.mStats.Size() - 1; i >= 0; --i)
		{
			if (ledger.mStats[i].wpn == null) ledger.mStats.Delete(i);
		}

		for (int i = 0; i < ledger.mStats.Size(); ++i)
		{
			if (ledger.mStats[i].wpn == w) return ledger.mStats[i];
		}

		if (!create) return null;

		let s = new("wr_WeaponStats");
		s.wpn = w;
		ledger.mStats.Push(s);
		return s;
	}

	// The per-CLASS counterpart. Keyed by the weapon's class name rather
	// than by an object reference, so unlike the instance records these are
	// never pruned -- the whole point is that they outlive the gun.
	static play wr_ClassStats ClassStatsFor(PlayerPawn pawn, Name cls, bool create)
	{
		if (!pawn || cls == 'None') return null;

		let ledger = wr_StatLedger(pawn.FindInventory("wr_StatLedger"));
		if (!ledger)
		{
			if (!create) return null;
			ledger = wr_StatLedger(pawn.GiveInventoryType("wr_StatLedger"));
			if (!ledger) return null;
		}

		for (int i = 0; i < ledger.mClassStats.Size(); ++i)
		{
			if (ledger.mClassStats[i].cls == cls) return ledger.mClassStats[i];
		}

		if (!create) return null;

		let c = new("wr_ClassStats");
		c.cls = cls;
		ledger.mClassStats.Push(c);
		return c;
	}
}

// The EventHandler doing the actual watching. Its own file and its own
// class because it shares no state with wr_Rig, and folding an unrelated
// concern into an already-large class would only cost readability.
class wr_StatEvents : EventHandler
{
	// How many tics an ammo-drain-detected shot's hit-credit window stays
	// open. Generous enough for a slow projectile's travel time, short
	// enough that an unrelated later hit on the same target doesn't get
	// mistaken for this shot's result.
	const HIT_WINDOW    = 12;

	// Beyond this many tics since the last shot, a fresh one is treated as
	// the start of a new firing pattern rather than a continuation of the
	// old one -- so a rate-of-fire reading does not average in the pause
	// between one engagement and the next.
	const ROF_WINDOW    = 105;

	// How long a hand's last-fire timestamp stays eligible to explain a
	// kill or a hit. Past this, neither hand gets credit -- see the file
	// header on why undercounting beats guessing.
	// 70, not 35: with shot stamping now synchronous for hitscan (see
	// syncFire) this only has to cover a projectile's flight, and 35 tics
	// is a rocket landing within 700 units -- two rooms. Kills further out
	// were being dropped.
	const ATTRIB_WINDOW = 70;

	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	private static bool active()
	{
		return cv("wr_stats_track", 1.0) > 0.0;
	}

	// SHOT DETECTION. Not hooked off any weapon's own fire state -- there
	// is no such hook that works identically across nine mods with nothing
	// in common -- so this watches the one thing every ammo-using weapon
	// shares: its ammo pool getting smaller. A decrease big enough to be a
	// reload rather than a shot is folded into the new baseline and NOT
	// counted -- the same undercount-over-misattribute rule as everywhere
	// else in this file.
	override void WorldTick()
	{
		if (!active()) return;
		if (!playeringame[consoleplayer] || !players[consoleplayer].mo) return;

		let pawn = players[consoleplayer].mo;
		if (!pawn.player) return;

		// WHICH HAND, passed in, because the ammo pool cannot say.
		//
		// Weapon.Ammo1 points at the player's single Inventory item of that ammo
		// class, so two weapons sharing a pool -- pistol and chaingun, shotgun and
		// SSG, plasma and BFG, or any two copies of the same gun, which is the
		// flagship case of a dual-wield rig -- read the identical drain and BOTH
		// conclude they fired. Both then stamp the same lastFireTic, attribution
		// sees tA == tB and fails closed on every damage, death and marker event
		// after it, so kills, hits and headshots sat at zero forever while SHOTS
		// counted double. Audit finding #32.
		trackFire(pawn, pawn.player.ReadyWeapon,  false);
		trackFire(pawn, pawn.player.OffhandWeapon, true);
	}

	// THE DRAIN IS POLLED BEFORE ANY CREDIT IS GIVEN. P_PlayerThink runs
	// before WorldTick in this engine, and a hitscan weapon depletes its
	// ammo and lands its damage inside that same call -- so every damage,
	// death and headshot-marker event of a hitscan shot used to arrive
	// while lastFireTic still described the PREVIOUS shot. The first shot
	// after a pause credited nothing, the pistol never landed inside its
	// own 12-tic window (ACC 0% forever), and the shotgun and SSG, whose
	// refire is longer than the attribution window, were never credited a
	// hit, a kill or a pellet at all. trackFire rebases the ammo baseline
	// on every call, so the WorldTick poll that follows sees no second
	// drain and nothing is counted twice.
	private void syncFire(PlayerPawn pawn)
	{
		if (!pawn || !pawn.player) return;
		trackFire(pawn, pawn.player.ReadyWeapon,  false);
		trackFire(pawn, pawn.player.OffhandWeapon, true);
	}

	// Barrels and other shootable props the player set off report the
	// player as the damage source. Their blasts are not the gun's damage.
	private static bool viaProp(WorldEvent e, PlayerPawn pawn)
	{
		return e.Inflictor && e.Inflictor != pawn && !e.Inflictor.bMissile && e.Inflictor.bShootable;
	}

	private void trackFire(PlayerPawn pawn, Weapon w, bool offhand)
	{
		if (!w) return;

		let s = wr_StatLedger.StatsFor(pawn, w, true);
		if (!s) return;

		int a1 = w.Ammo1 ? w.Ammo1.Amount : 0;
		int a2 = w.Ammo2 ? w.Ammo2.Amount : 0;

		// MAGAZINE CAPACITY, observed as a high-water mark -- see the field's
		// own note. Ammo2 is the magazine where a weapon has one; the check
		// against Ammo1 being a DIFFERENT item is what distinguishes a real
		// magazine from a weapon whose Ammo1 and Ammo2 are the same pool.
		// THE ALT-FIRE EXCLUSION, which this third copy never got.
		//
		// Ammo2 is overloaded: a magazine on one weapon, a separate alt-fire pool
		// on another. wr_Rig.hasMagazine is the authoritative test and adds
		// `if (hasAltFire(w)) return false;` for exactly that reason; wr_gunhud's
		// copy was fixed to match and says so in its own comment. This one stayed
		// in the pre-fix two-part form.
		//
		// The result is a MAG row whose two halves come from DIFFERENT pools --
		// the numerator through the three-part test (Ammo1) and the denominator
		// through this one (Ammo2) -- printing nonsense like "MAG 187 / 12":
		// 187 rounds over a capacity of 12 grenades. Audit finding #33.
		if (w.Ammo2 != null && w.Ammo1 != w.Ammo2 && !wr_Rig.hasAltFire(w)
		    && a2 > s.magHigh) s.magHigh = a2;

		if (!s.seenAmmo)
		{
			s.lastAmmo1 = a1;
			s.lastAmmo2 = a2;
			s.seenAmmo  = true;
			return;
		}

		// A weapon that was NOT polled last tic (holstered, on the wheel's
		// shelf, in nobody's hand) has a stale baseline: whatever another gun
		// spent from the shared pool since then would read as this one's
		// shot the moment it came back. Rebase, uncounted.
		bool continuous = (s.lastPollTic == level.totaltime) || (s.lastPollTic == level.totaltime - 1);
		s.lastPollTic = level.totaltime;
		if (!continuous)
		{
			s.lastAmmo1 = a1;
			s.lastAmmo2 = a2;
			return;
		}

		int down1 = s.lastAmmo1 - a1;
		int down2 = s.lastAmmo2 - a2;
		int use1  = w.default.AmmoUse1 > 0 ? w.default.AmmoUse1 : 1;
		int use2  = w.default.AmmoUse2 > 0 ? w.default.AmmoUse2 : use1;   // the alt pool's own cost

		// A drop roughly the size of what ONE shot should cost -- not a
		// refill (down <= 0), and not a reload-sized jump either (more
		// than double what one shot costs). Anything outside that band is
		// ambiguous and simply becomes the new baseline, uncounted.
		bool fired = (down1 > 0 && down1 <= use1 * 2) || (down2 > 0 && down2 <= use2 * 2);

		// AND THIS HAND'S TRIGGER HAS TO BE DOWN.
		//
		// The drain alone cannot say which weapon spent it when both draw from
		// the same pool -- the band test passes for both, so both count a shot
		// and both stamp the same tic, which is what poisons attribution for
		// everything downstream.
		//
		// The buttons CAN say. A hand whose trigger is not held did not fire the
		// round that just left the pool, whatever the ammo count did.
		//
		// The alt-fire twin counts too: a weapon firing on alt still spends ammo
		// and is still that hand pulling a trigger.
		//
		// FAILS OPEN when neither hand shows a button, rather than dropping the
		// shot: a mod that fires from a state function without the engine seeing
		// a press would otherwise lose every stat it has. The ambiguity this
		// exists to break is BOTH hands claiming one shot, and that is still
		// broken -- one of them is holding a trigger and the other is not.
		if (fired)
		{
			int btn = pawn.player.cmd.buttons;
			bool mainDown = (btn & (BT_ATTACK | BT_ALTATTACK)) != 0;
			bool offDown  = (btn & (BT_OFFHANDATTACK | BT_OFFHANDALTATTACK)) != 0;

			if (mainDown || offDown)
				fired = offhand ? offDown : mainDown;
		}

		s.lastAmmo1 = a1;
		s.lastAmmo2 = a2;

		if (!fired) return;

		s.shotsFired++;

		// Fetched HERE rather than near the top of the function. It used to be
		// looked up alongside the time-held counter that was removed, and this
		// was the other user of that one lookup -- so deleting the counter took
		// the declaration with it and left this orphaned. It belongs next to the
		// increment that needs it anyway: the function returns before here on
		// every tic that is not a shot, so fetching it early asked the ledger
		// for a class entry thirty-five times a second to use it once.
		let cs = wr_StatLedger.ClassStatsFor(pawn, w.GetClassName(), true);
		if (cs) cs.shotsFired++;

		// A new shot closes the last one's pellet run and starts a fresh
		// count -- see pelletMax's note on why this is a floor.
		if (s.pelletRun > s.pelletMax) s.pelletMax = s.pelletRun;
		s.pelletRun = 0;

		s.pendingHitUntilTic = level.totaltime + HIT_WINDOW;

		if (s.lastFireTic > 0)
		{
			int dt = level.totaltime - s.lastFireTic;
			if (dt > 0 && dt <= ROF_WINDOW)
				s.rofEma = (s.rofEma <= 0.0) ? double(dt) : (s.rofEma * 0.75 + double(dt) * 0.25);
		}
		s.lastFireTic = level.totaltime;
	}

	// Which hand's weapon most plausibly caused a hit/kill/headshot landing
	// right now. See the file header -- this fails closed on ambiguity
	// rather than guessing.
	private static Weapon attributedWeapon(PlayerPawn pawn)
	{
		if (!pawn || !pawn.player) return null;

		Weapon a = pawn.player.ReadyWeapon;
		Weapon b = pawn.player.OffhandWeapon;

		wr_WeaponStats sa = a ? wr_StatLedger.StatsFor(pawn, a, false) : null;
		wr_WeaponStats sb = b ? wr_StatLedger.StatsFor(pawn, b, false) : null;

		int tA = sa ? sa.lastFireTic : 0;
		int tB = sb ? sb.lastFireTic : 0;

		if (tA <= 0 && tB <= 0) return null;
		if (level.totaltime - max(tA, tB) > ATTRIB_WINDOW) return null;
		if (tA == tB) return null;

		return (tA > tB) ? a : b;
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		if (!active()) return;
		if (!e.DamageSource || !e.DamageSource.player) return;
		if (e.DamageSource.player != players[consoleplayer]) return;

		let pawn = PlayerPawn(e.DamageSource);
		if (!pawn) return;
		if (e.Thing == pawn) return;          // self-splash is not a landed shot
		if (viaProp(e, pawn)) return;         // a barrel's blast is not the gun's damage
		bool viaMissile = e.Inflictor && e.Inflictor.bMissile;

		syncFire(pawn);
		Weapon w = attributedWeapon(pawn);
		if (!w) return;

		let s = wr_StatLedger.StatsFor(pawn, w, true);
		if (!s) return;

		// RS_HEADSHOTS' BONUS IS NOT A SECOND HIT, AND MUST NOT COUNT AS ONE.
		//
		// That mod cannot raise a headshot's damage in place -- WorldThing
		// Damaged fires AFTER DamageMobj has already applied the number -- so
		// it deals a separate immediate follow-up hit for the difference,
		// tagged 'HS_HeadshotBonus' (hs_detect.zs). That arrives here as its
		// own damage event, and counting it as its own sample would average
		// one headshot's total damage across two samples: a 30-damage hit
		// plus its 15-damage bonus reading as 22 per hit rather than the 45
		// it actually was -- the bonus would make the weapon look WEAKER.
		//
		// So the damage is added (it was really dealt) but the sample is not
		// (it was not a separate hit). Hits themselves need no such guard:
		// pendingHitUntilTic is consumed by the first event and cannot be
		// claimed twice.
		//
		// The range is recorded from the ORIGINAL hit only, for the same
		// reason: a bonus is part of one landed shot, not a second landing,
		// and folding it in as its own sample would put a 15-damage bonus
		// into the low end of a weapon whose real floor is 30.
		if (e.DamageType != 'HS_HeadshotBonus')
		{
			int d = e.Damage;
			if (d > 0)
			{
				if (s.damageSamples <= 0) { s.damageLow = d; s.damageHigh = d; }
				else
				{
					if (d < s.damageLow)  s.damageLow  = d;
					if (d > s.damageHigh) s.damageHigh = d;
				}
				s.damageSamples++;

				let cs = wr_StatLedger.ClassStatsFor(pawn, w.GetClassName(), true);
				if (cs)
				{
					if (cs.damageSamples <= 0) { cs.damageLow = d; cs.damageHigh = d; }
					else
					{
						if (d < cs.damageLow)  cs.damageLow  = d;
						if (d > cs.damageHigh) cs.damageHigh = d;
					}
					cs.damageSamples++;
				}
			}

			// PELLETS, counted as separate landings inside one shot's window
			// -- a floor on the true count, never the spread itself. Only
			// the original hits count; a headshot bonus would inflate a
			// single-pellet weapon to two.
			// THE SHOT'S OWN WINDOW, not the hit-credit token.
			//
			// pendingHitUntilTic is deliberately SINGLE USE -- the first damage
			// event that lands inside it takes the hit credit and closes it four
			// lines below. Sharing it here meant pellet one raised the count to 1
			// and shut the window, and pellets two through eight of the same blast
			// all failed this test. pelletRun could only ever hold 0 or 1, so the
			// PELLETS row never drew and DPS multiplied by one: a vanilla shotgun
			// read a seventh of its real damage, an SSG a twentieth.
			//
			// Measured against lastFireTic instead, which is the shot's own span
			// and is not consumed by anything. Audit finding #31.
			// Not for a missile: its impact and its splash on the same monster
			// are two events for one shot, and every other monster in the
			// blast is another -- a rocket read PELLETS 2+ and its DPS
			// multiplied by the crowd.
			if (!viaMissile && level.totaltime <= s.lastFireTic + HIT_WINDOW)
				s.pelletRun++;
		}

		// A projectile's credit lasts its flight (ATTRIB_WINDOW); hitscan's
		// stays short so an unrelated later hit on the same target is not
		// mistaken for this shot's.
		int hitWin = viaMissile ? ATTRIB_WINDOW : HIT_WINDOW;
		if (s.pendingHitUntilTic > 0 && level.totaltime <= s.lastFireTic + hitWin)
		{
			s.hits++;
			s.pendingHitUntilTic = 0;

			let cs = wr_StatLedger.ClassStatsFor(pawn, w.GetClassName(), true);
			if (cs) cs.hits++;
		}
	}

	override void WorldThingDied(WorldEvent e)
	{
		if (!active()) return;

		// THE ENGINE FILLS e.Thing AND e.Inflictor ONLY for a death (events.cpp
		// WorldThingDied; DamageSource is a thingdamaged-only field), so the
		// old `!e.DamageSource` bail returned on every death and KILLS read 0
		// for every weapon, forever. AActor::Die sets the victim's target to
		// the source just before firing the hook, and a missile's target is
		// its shooter, so the killer is recoverable from what does arrive.
		Actor src = e.DamageSource;
		if (!src && e.Thing) src = e.Thing.target;
		if ((!src || !src.player) && e.Inflictor)
			src = e.Inflictor.player ? e.Inflictor : e.Inflictor.target;
		if (!src || !src.player) return;
		if (src.player != players[consoleplayer]) return;

		let pawn = PlayerPawn(src);
		if (!pawn || e.Thing == pawn) return;
		if (viaProp(e, pawn)) return;         // a barrel the player set off is not a gun kill

		syncFire(pawn);
		Weapon w = attributedWeapon(pawn);
		if (!w) return;

		let s = wr_StatLedger.StatsFor(pawn, w, true);
		if (s) s.kills++;

		let cs = wr_StatLedger.ClassStatsFor(pawn, w.GetClassName(), true);
		if (cs) cs.kills++;
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if (!active()) return;
		if (!e.Thing || (("" .. e.Thing.GetClassName()) != "HS_Marker")) return;
		if (!playeringame[consoleplayer] || !players[consoleplayer].mo) return;

		let pawn = players[consoleplayer].mo;
		syncFire(pawn);
		Weapon w = attributedWeapon(pawn);
		if (!w) return;

		let s = wr_StatLedger.StatsFor(pawn, w, true);
		if (s) s.headshots++;

		let cs = wr_StatLedger.ClassStatsFor(pawn, w.GetClassName(), true);
		if (cs) cs.headshots++;
	}

	// Lazy-grant covers the general case (StatsFor grants on first use),
	// but granting here too means a fresh player pawn already carries the
	// ledger before the first shot rather than creating it mid-tick.
	override void PlayerSpawned(PlayerEvent e)   { grantLedger(e.PlayerNumber); }
	override void PlayerEntered(PlayerEvent e)   { grantLedger(e.PlayerNumber); }

	private void grantLedger(int pnum)
	{
		if (!active()) return;
		if (pnum < 0 || pnum >= MAXPLAYERS || !playeringame[pnum] || !players[pnum].mo) return;
		if (players[pnum].mo.FindInventory("wr_StatLedger") != null) return;
		players[pnum].mo.GiveInventoryType("wr_StatLedger");
	}
}

// Public read API for the sheet -- zscript.zs's buildSheetRows() calls
// into this exactly the way it calls into every wr_CompatXxx file, even
// though this one reads the wheel's OWN tracked state rather than another
// mod's fields.
class wr_StatTracker
{
	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		return c ? c.GetFloat() : fallback;
	}

	// PLAY-SCOPED, and everything that calls into it has to be too --
	// wr_StatLedger.StatsFor ultimately touches FindInventory/
	// GiveInventoryType, which are live-game-state operations the compiler
	// will not let a data-scope function (this class's default, since it
	// is a plain Object, not an Actor) reach. Every other compat file in
	// this mod avoids the question entirely by only ever calling clearscope
	// reflection natives (Level.GetFieldInt and friends) -- this is the
	// first one that needs an actual inventory search, so it is the first
	// one that needs the keyword.
	private static play wr_WeaponStats lookup(Weapon w)
	{
		if (!w || !w.Owner || cv("wr_stats_track", 1.0) <= 0.0) return null;
		let pawn = PlayerPawn(w.Owner);
		if (!pawn) return null;
		return wr_StatLedger.StatsFor(pawn, w, false);
	}

	// FOUND, KILLS, SHOTS FIRED, HITS. Found only once at least one shot
	// has actually been detected -- a weapon that has never fired showing
	// "KILLS 0 SHOTS 0 ACC 0%" is noise, not information.
	static play bool, int, int, int BasicsOf(Weapon w)
	{
		let s = lookup(w);
		if (!s || s.shotsFired <= 0) return false, 0, 0, 0;
		return true, s.kills, s.shotsFired, s.hits;
	}

	// FOUND, LOW, HIGH. A range rather than an average -- see damageLow's
	// own note. low == high is a weapon that has only ever landed one value,
	// which is either a fixed-damage weapon or one that has not been fired
	// enough to find its spread; the caller prints a single number for that
	// case rather than "12-12".
	static play bool, int, int DamageOf(Weapon w)
	{
		let s = lookup(w);
		if (!s || s.damageSamples <= 0) return false, 0, 0;
		return true, s.damageLow, s.damageHigh;
	}

	// FOUND, CAPACITY. The observed high-water load -- see magHigh's note on
	// why the ammo class's own MaxAmount is the wrong number.
	static play bool, int MagazineOf(Weapon w)
	{
		let s = lookup(w);
		if (!s || s.magHigh <= 0) return false, 0;
		return true, s.magHigh;
	}

	// FOUND, AT-LEAST-N. A floor, never the real pellet count -- only
	// reported once more than one hit has ever landed from a single shot,
	// since "at least 1" is true of every weapon in the game and says
	// nothing.
	static play bool, int PelletsOf(Weapon w)
	{
		let s = lookup(w);
		if (!s) return false, 0;
		int best = s.pelletMax > s.pelletRun ? s.pelletMax : s.pelletRun;
		if (best < 2) return false, 0;
		return true, best;
	}

	// PER-CLASS HISTORY -- what guns of this KIND have done for you, as
	// opposed to what this particular one has. The answer for a weapon lying
	// on the floor, which by definition has no history of its own.
	//
	// FOUND, KILLS, SHOTS, HITS.
	//
	// NOTE: nothing calls this. It is kept because it is the only reader
	// written for a weapon NOBODY OWNS -- the case a floor pickup needs --
	// and that is worth having ready. Delete it if that never lands.
	static play bool, int, int, int ClassHistoryOf(Weapon w)
	{
		if (!w || cv("wr_stats_track", 1.0) <= 0.0) return false, 0, 0, 0;

		// Deliberately NOT w.Owner -- this is the reader that has to work for
		// a weapon nobody owns. The console player's own ledger is the one
		// being asked, about a class, so the weapon's ownership is irrelevant.
		if (!playeringame[consoleplayer] || !players[consoleplayer].mo) return false, 0, 0, 0;
		let pawn = players[consoleplayer].mo;

		let c = wr_StatLedger.ClassStatsFor(pawn, w.GetClassName(), false);
		if (!c || c.shotsFired <= 0) return false, 0, 0, 0;
		return true, c.kills, c.shotsFired, c.hits;
	}

	// FOUND, SHOTS PER SECOND. 35.0 is Doom's fixed tic rate.
	static play bool, double RofOf(Weapon w)
	{
		let s = lookup(w);
		if (!s || s.rofEma <= 0.0) return false, 0.0;
		return true, 35.0 / s.rofEma;
	}

	// FOUND(mod loaded), COUNT. Found means "Headshots is loaded", not
	// "this weapon has landed one" -- shown at zero once the mod is
	// present, same honesty rule as every other conditional row on the
	// sheet: present-but-zero is real information, absent is not.
	static play bool, int HeadshotsOf(Weapon w)
	{
		if (!w || !w.Owner || cv("wr_stats_track", 1.0) <= 0.0) return false, 0;
		if (Object.FindClass("HS_Marker") == null) return false, 0;

		let pawn = PlayerPawn(w.Owner);
		if (!pawn) return false, 0;

		let s = wr_StatLedger.StatsFor(pawn, w, false);
		return true, s ? s.headshots : 0;
	}
}
