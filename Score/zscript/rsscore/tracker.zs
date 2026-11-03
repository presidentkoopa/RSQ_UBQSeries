// ============================================================================
// RS_ScoreTracker -- one player's score, and every counter a bonus needs.
//
// WHY AN INVENTORY TOKEN AND NOT ARRAYS ON THE HANDLER. The engine already saves
// a player's inventory into savegames and carries it across a map change, hub
// travel included. The ACS original faked both by hand -- a `global` array indexed
// by player number, plus a counter item it copied the score into every tic just so
// the value survived. Put the state on the player and all of that disappears.
//
// PLAY SCOPE, ALWAYS. Everything here is game state: it must come out the same on
// every machine in a net game. Nothing in this file may read consoleplayer, a
// user cvar, or anything else that is one machine's opinion. The HUD reads these
// fields; it never writes them.
// ============================================================================

class RS_ScoreTracker : Inventory
{
	// The original's shape, kept: nine weapon slots, three fire modes. A caller
	// passing anything outside those bounds is ignored, as it was there.
	const SCOREWEPS      = 9;
	const SCOREFIREMODES = 3;
	const S_SCRAPPER     = 1;   // the signature slot, as in the original

	// ---- the two scores ----------------------------------------------------
	// SCORE is progress toward the map's reward threshold.
	// DISPLAYSCORE is the running total the player reads.
	int score;
	int displayScore;

	// Score_CalcScorePercent's value: the fractional part of the progress,
	// recomputed every tic, and read at map start to rescale SCORE against the new
	// map's threshold.
	double scorePercent;

	// ---- rewards ----------------------------------------------------------
	int  rewardCount;
	int  regenTimer;
	int  regenSpent;
	int  extraLives;
	bool hasLives;

	// ---- the melee family (melee.zs) --------------------------------------
	Actor hurlBy;            // the throw that last scored: further kills by it pay Hurled more
	int   hurlKills;
	Array<int> comboKind;    // recent melee kills, for Combo
	Array<int> comboTic;
	int  lastResetTic;
	int   rallyCount;        // Rally: shots sent back that killed, one after another
	int   rallyTic;

	// ---- the arcade layer (hook.zs) ----------------------------------------
	int   reelCount;         // Reeled In: one after another
	int   reelTic;
	int   varMask;           // Variety: the tools used in this fight
	int   varTic;
	int   bigComboTic;       // a big combo landed (combo.zs): the HUD's word breathes brighter

	// ---- slow motion for big moments (handler.zs BigMomentPulse) -------------
	int slowmoReady;         // no pulse before this tic (rs_score_slowmo_cooldown)
	int slowmoUntil;         // our own last pulse is still slowing the world until about here

	// ---- Spree ------------------------------------------------------------
	int spreeCount;
	int spreeExpire;

	// ---- Untouchable ------------------------------------------------------
	int utKills;
	int utHP;
	int utStacks;

	// ---- Air --------------------------------------------------------------
	// The floor we left, the best apex this jump reaches, and the previous vertical
	// speed, which is how the gravity is MEASURED rather than assumed.
	double airFloorZ;
	double airHeight;
	double airPrevVelZ;
	bool   airTracking;

	// ---- Switcharoo -------------------------------------------------------
	// PlayerWeapons_LastFired, flattened: slot * SCOREFIREMODES + mode holds the tic
	// that slot/mode last fired on.
	//
	// WRITTEN ONLY BY AN EXPLICIT CALL, exactly as the original was: its weapons each
	// called Dakka_Switcharoo(slot, firemode) from their own fire states, and
	// SMult_WeaponSwitch returned 0 for any player class that did not update it.
	// Watching the attack buttons instead looks equivalent and is not -- it fires on
	// a trigger press rather than on a shot, and it cannot tell a burst from a tap.
	// So this stays inert until a weapon calls RS_ScoreHandler.Switcharoo().
	private int lastFired[27];   // SCOREWEPS * SCOREFIREMODES

	// SWITCHAROO'S EARS (11-03, sheet D3): no weapon in BD22 VR Reloaded calls the old door, so the fire is read off
	// the blow the ledger hears (combo.zs WorldThingDamaged): the gun that fired (the class in the hand that fired, or
	// the missile's own) and which trigger (0 main, 1 the off hand's, 2 alt fire). The last sixteen, newest last; a
	// burst of the same gun and trigger is one entry, its tic moved on.
	Array<String> fireWep;
	Array<int> fireMode, fireTic;

	static void NoteFire(Actor src, Actor inf)
	{
		let tr = RS_ScoreHandler.GetTracker(src);
		let p = src ? src.player : null;
		if (!tr || !p) return;
		int b = p.cmd.buttons;
		bool off = (b & BT_OFFHANDATTACK) && !(b & BT_ATTACK);
		Weapon w = off ? p.OffhandWeapon : p.ReadyWeapon;
		if (!w) w = p.ReadyWeapon;
		String gun = "";   // not "name": identifiers are case-insensitive and Name is a type
		if (w) gun = w.GetClassName();
		else if (inf) gun = inf.GetClassName();
		if (gun.Left(8) ~== "RSQ_Off_") gun = gun.Mid(8);
		if (gun == "") return;
		int mode = off ? 1 : ((b & BT_ALTATTACK) ? 2 : 0);
		int n = tr.fireWep.Size();
		if (n > 0 && tr.fireWep[n - 1] == gun && tr.fireMode[n - 1] == mode) { tr.fireTic[n - 1] = level.maptime + 1; return; }
		if (n >= 16) { tr.fireWep.Delete(0); tr.fireMode.Delete(0); tr.fireTic.Delete(0); }
		tr.fireWep.Push(gun); tr.fireMode.Push(mode); tr.fireTic.Push(level.maptime + 1);
	}

	// ---- the breakdown the HUD draws ---------------------------------------
	// One row per bonus plus a Base row at index 0, sized by the handler. The value
	// and the tic it was set on are play scope, because they are earned; how long a
	// row stays on screen is the viewer's own setting and lives in the HUD.
	Array<int> rowValue;
	Array<int> rowTic;

	// Moments the HUD reacts to, set here so both screens in a co-op game react off
	// the same tic rather than each guessing from its own view.
	int flashTic;
	int rewardTic;
	int rewardLifeTic;   // the tic the delayed extra-life cue is due on
	int pendingLives;    // how many lives that cue is announcing
	int reviveTic;

	Default
	{
		Inventory.MaxAmount 1;
		Inventory.InterHubAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.QUIET
		+INVENTORY.KEEPDEPLETED
		-COUNTITEM
	}

	States
	{
	Spawn:
		TNT1 A -1;
		stop;
	}

	// ------------------------------------------------------------------ score

	void AddScore(int points)
	{
		score        += points;
		displayScore += points;
	}

	// Score_CalcScorePercent: FixedDiv(score, threshold) % 1.0.
	void CalcScorePercent(int threshold)
	{
		if (threshold <= 0) { scorePercent = 0.0; return; }

		double p = double(score) / double(threshold);
		scorePercent = p - floor(p);
	}

	clearscope double ProgressFraction(int threshold) const
	{
		if (threshold <= 0) { return 0.0; }
		return double(score % threshold) / double(threshold);
	}

	// --------------------------------------------------------------- per tic

	override void Tick()
	{
		Super.Tick();

		if (!owner || !owner.player) { return; }

		UpdateAir();
	}

	// MEASURE THE GRAVITY, DO NOT ASSUME IT. Predicting the apex with HeightFromJumpZ
	// needs the gravity constant -- and gets it wrong on a low-gravity map, under a
	// jump modifier, or in water. The acceleration is simply the change in vertical
	// speed from one tic to the next, so read it off the actor: apex = v^2 / 2a.
	private void UpdateAir()
	{
		let mo = owner;

		bool grounded = (mo.pos.z <= mo.floorz) || mo.waterlevel > 0;

		if (grounded)
		{
			airFloorZ   = mo.pos.z;
			airHeight   = 0.0;
			airPrevVelZ = 0.0;
			airTracking = false;
			return;
		}

		double apex = mo.pos.z;

		if (airTracking && mo.vel.z > 0.0)
		{
			double accel = airPrevVelZ - mo.vel.z;
			if (accel > 0.0)
			{
				apex += (mo.vel.z * mo.vel.z) / (2.0 * accel);
			}
		}

		apex = min(apex, mo.ceilingz);

		airHeight   = max(airHeight, apex - airFloorZ);
		airPrevVelZ = mo.vel.z;
		airTracking = true;
	}

	// ---------------------------------------------------------- Switcharoo

	// Dakka_Switcharoo: lastFired[slot][mode] = Timer() + 1, with the same bounds
	// check and the same silent ignore outside them.
	void RecordFire(int slot, int firemode)
	{
		if (slot < 0 || slot >= SCOREWEPS) { return; }
		if (firemode < 0 || firemode >= SCOREFIREMODES) { return; }

		lastFired[slot * SCOREFIREMODES + firemode] = level.maptime + 1;
	}

	// SMult_WeaponSwitch's counting half: how many slots, and how many fire modes,
	// fired at or after `cutoff`. A slot counts once however many of its modes fired.
	void CountRecentFire(int cutoff, out int weapons, out int modes)
	{
		weapons = 0;
		modes   = 0;

		Array<int> modeUsed;
		modeUsed.Resize(SCOREFIREMODES);

		for (int s = 0; s < SCOREWEPS; s++)
		{
			bool used = false;

			for (int f = 0; f < SCOREFIREMODES; f++)
			{
				int t = lastFired[s * SCOREFIREMODES + f];
				if (t == 0) { continue; }

				if (cutoff <= t)
				{
					used = true;
					modeUsed[f] = 1;
				}
			}

			if (used) { weapons += 1; }
		}

		// the guns heard off the blows (NoteFire): distinct guns, distinct triggers, at or after the cutoff
		Array<String> guns;
		for (int k = 0; k < fireWep.Size(); k++)
		{
			if (fireTic[k] < cutoff) continue;
			bool had = false;
			for (int j = 0; j < guns.Size(); j++) if (guns[j] == fireWep[k]) { had = true; break; }
			if (!had) guns.Push(fireWep[k]);
			if (fireMode[k] >= 0 && fireMode[k] < SCOREFIREMODES) modeUsed[fireMode[k]] = 1;
		}
		weapons += guns.Size();

		for (int f = 0; f < SCOREFIREMODES; f++)
		{
			if (modeUsed[f] != 0) { modes += 1; }
		}
	}

	// SMult_Scrapping's fallback half: the slot that fired most recently, or -1.
	int LatestFiredSlot() const
	{
		int best = -1;
		int bestSlot = -1;

		for (int s = 0; s < SCOREWEPS; s++)
		{
			for (int f = 0; f < SCOREFIREMODES; f++)
			{
				int t = lastFired[s * SCOREFIREMODES + f];
				if (t > best)
				{
					best     = t;
					bestSlot = s;
				}
			}
		}

		return bestSlot;
	}

	// -------------------------------------------------------- untouchable

	void AddUntouchable(int victimSpawnHealth)
	{
		utKills += 1;
		utHP    += victimSpawnHealth;
	}

	// Taking damage ends the run. A NODAMAGE player keeps it, which is how a streak
	// survives a cutscene or a scripted hit.
	void ResetUntouchable()
	{
		utKills  = 0;
		utHP     = 0;
		utStacks = 0;
	}
}
