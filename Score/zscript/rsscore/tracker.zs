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

	// ---- gold (gold.zs; design/KIOSK.md): the Boss kiosk's bank ------------
	int  gold;               // banked: kept across maps, never lost on death
	int  goldEarned;         // every gold ever banked (never goes down; the kiosk's per-Boss log reads it)
	int  goldSpent;          // every gold ever spent
	int  goldMap;            // banked on this map
	int  goldTic;            // the tic gold last came in (the HUD's pop)
	int  goldSpendTic;       // the tic gold was last spent
	// SKILL GOLD's clean Boss kill (gold.zs RS_ScoreSkillGold, owner 2026-11-22)
	int  goldLivesLost;      // Score lives spent and deaths, ever (only compared: a Boss fight's start against its win)
	int  goldFightMark;      // goldLivesLost when the Boss fight now on began
	bool goldFightOn;        // a Boss fight began and has not been won yet (this map)
	bool goldFightBig;       // ...and it is a Big Boss's

	// ---- Critical Hits (crit.zs, owner 11-17): THE CRIT CHANCE, a tracked stat -----------------------------------
	// "our critical chance should be, eventually, a stat that we track in our arcade design". The ONE place it is kept:
	// read it with CritChance(), raise or set it with SetCritChance() (or RS_ScoreCritHandler.ChanceOf / SetChanceOf, or
	// RS_ScoreService "crit.chance" / "crit.chance.set" by name). It starts from rs_score_crit_random_chance (0.15). A
	// value set here is kept as its distance from that cvar, so the menu's Random Crit Chance still moves it.
	double critSetTo;        // the chance set (0..1), when critChanceSet (not "critChance": names are case-blind, CritChance() below)
	double critSeed;         // rs_score_crit_random_chance when it was set
	bool   critChanceSet;

	clearscope double CritChance() const
	{
		double start = rs_score_crit_random_chance;
		double c = critChanceSet ? critSetTo + (start - critSeed) : start;
		return clamp(c, 0.0, 1.0);
	}

	void SetCritChance(double chance)
	{
		critSetTo     = clamp(chance, 0.0, 1.0);
		critSeed      = rs_score_crit_random_chance;
		critChanceSet = true;
	}

	// ---- the melee family (melee.zs) --------------------------------------
	Actor hurlBy;            // the throw that last scored: further kills by it pay Hurled more
	int   hurlKills;
	Array<int> comboKind;    // recent melee kills, for Combo
	Array<int> comboTic;
	int   rallyCount;        // Rally: shots sent back that killed, one after another
	int   rallyTic;

	// ---- the arcade layer (hook.zs) ----------------------------------------
	int   varMask;           // Variety: the tools used in this fight
	int   varTic;
	int   bigComboTic;       // a big combo landed (combo.zs): the HUD's word breathes brighter

	// ---- the 11-03 rows (rows.zs) ------------------------------------------
	String wmMod;            // Weapon Master: the melee mod of the last run of kills, and the run
	int    wmCount, wmTic;
	Actor  mkInf;            // Multi-Kill: the last kill's inflictor, its tool, the tic, kills so far
	String mkTool;
	int    mkTic, mkCount;
	int    holdStart[2];     // Hold Streak: the tic each hand's trigger went down (0 up), kills in the hold
	int    holdKills[2];
	int    champTic, champCount;   // Champion Streak
	int    legendTic;        // Legend Slayer: the last legendary kill
	int    cgTic, cgCount;   // Chain Gang: thrall kills one after another, each within 12 s
	Actor  thrownKillInf;    // Double Throw: the last thrown-saber kill's inflictor
	int    thrownKillTic;
	int    colourMask;       // Rainbow: the champion colours killed this map (bit per token)
	int    rainbowPaid;      // ...and which of its three awards have paid (bits)
	Array<String> armWep;    // Armory: the guns drawn and killing lately
	Array<int> armTic;

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
	// So the slot path stays unused (no weapon calls RS_ScoreHandler.Switcharoo()); since 11-08 the guns are heard off
	// the blows instead (NoteFire, below), which is what feeds Switcharoo now.
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
	int rewardKind;      // what the last reward paid: 1 a life, 0 ammo regen (the bar's glow colour)
	int lifeCueTic;      // the tic the extra-life cue ran (the life pips' pop)
	int rewardLifeTic;   // the tic the delayed extra-life cue is due on
	int pendingLives;    // how many lives that cue is announcing
	int reviveTic;
	bool downNoted;          // the debug line "at 1 HP while RSQ SlowMo's DOWN holds him" printed (handler.zs RunExtraLives)
	bool lifeCueSlow;        // the life cue due is a life earned by Score's target: +1UP pays world slow motion (handler.zs RunRewardCue)
	Vector3 lifeFrom;        // where the life due came from (the life crate's middle), for RSQ VisualRewards' 1UP world word
	int lifeFromTic;         // the tic it was taken (0: none; the 1UP then rises in front of him)

	// ---- the life hold's test (handler.zs RunExtraLives; bugfix SC4, 2026-11-16) --------------------------------------
	// Only a hit that WOULD HAVE KILLED spends a life: its damage at least the health before it, as RSQ SlowMo's DOWN
	// judges (down.zs PlayerHit, hpSeen). 1 HP alone is not enough: a 13 hit at 14 HP left 1 HP and spent a life on the
	// rig, and a life earned while at 1 HP was spent at once.
	int  hpSeen;             // the health at the start of this tic (the last tic's, after its hits)
	int  preHp;              // the health just before the hit being dealt (ModifyDamage, below), when it ran
	bool preFresh;
	bool lethalHit;          // a hit since the health was last above 1 would have killed him
	bool diedSpent;          // he died through the hold and its one life is spent (cleared when he is alive again)

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

	// ---------------------------------------------------------- the life hold
	// The health just before a hit (only for hits the engine runs ModifyDamage for: not DMG_NO_FACTOR, which the
	// tic's hpSeen covers). The damage is not changed.
	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		newdamage = damage;
		if (!passive || !owner || !owner.player) return;
		preHp = owner.health;
		preFresh = true;
	}

	// a hit has landed (handler.zs WorldThingDamaged): was it a killing one?
	void NoteHit(int damage)
	{
		int pre = preFresh ? preHp : hpSeen;
		preFresh = false;
		if (pre <= 0 || damage >= pre) lethalHit = true;   // not known: as before the fix (1 HP is a caught killing hit)
		if (owner) hpSeen = owner.health;
	}

	// ----------------------------------------------------------------- a new map
	// EVERY TIC KEPT HERE IS A MAP TIC, and level.maptime starts again at 0 on a new map, while this token travels with
	// the player. A tic from the last map then reads as "in the future" or "just now" (bugfix 2026-11-16, check E: SC1
	// slow motion and hit-stop blocked, SC2 breakdown gaps, SC7 Spree carried on, NEW-SC-B chains carried on, NEW-SC-C
	// the +1UP cue held back), and Rainbow is "in one map" (SC3). Called by ScoreReset at every
	// map start, whatever New Map Keeps says: what is kept (score, total, lives, regen) is not here.
	void NewMap(bool keepLives)
	{
		// big moments (handler.zs BigMomentPulse)
		slowmoReady = 0;
		slowmoUntil = 0;
		// Spree
		spreeCount  = 0;
		spreeExpire = 0;
		// the breakdown
		for (int r = 0; r < rowTic.Size(); r++) rowTic[r] = 0;
		for (int r = 0; r < rowValue.Size(); r++) rowValue[r] = 0;
		// the chains (melee.zs, hook.zs, rows.zs)
		comboKind.Clear(); comboTic.Clear();
		rallyCount = 0; rallyTic = 0;
		varMask = 0; varTic = 0;
		bigComboTic = 0;
		wmMod = ""; wmCount = 0; wmTic = 0;
		mkInf = null; mkTool = ""; mkTic = 0; mkCount = 0;
		for (int h = 0; h < 2; h++) { holdStart[h] = 0; holdKills[h] = 0; }
		champTic = 0; champCount = 0;
		legendTic = 0;
		goldFightOn = false;   // SKILL GOLD: a Boss fight is one map's
		cgTic = 0; cgCount = 0;
		thrownKillInf = null; thrownKillTic = 0;
		colourMask = 0; rainbowPaid = 0;   // Rainbow: in one map
		armWep.Clear(); armTic.Clear();
		// Switcharoo's fire record
		for (int i = 0; i < SCOREWEPS * SCOREFIREMODES; i++) lastFired[i] = 0;
		fireWep.Clear(); fireMode.Clear(); fireTic.Clear();
		// the HUD's moments
		flashTic = 0;
		rewardTic = 0;
		lifeCueTic = 0;
		reviveTic = 0;
		downNoted = false;
		// a +1UP cue still due from the last map: now, if the life was kept; dropped with it otherwise
		if (rewardLifeTic > 0 && keepLives) rewardLifeTic = level.maptime + 1;
		else { rewardLifeTic = 0; pendingLives = 0; lifeCueSlow = false; }
		// the life hold's test
		hpSeen = owner ? owner.health : 0;
		preFresh = false;
		lethalHit = false;
		diedSpent = false;
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
		// Hold Streak (rows.zs): a trigger held from one tic to the next is one hold
		int b = owner.player.cmd.buttons;
		for (int h = 0; h < 2; h++)
		{
			bool down = h == 0 ? (b & BT_ATTACK) != 0 : (b & BT_OFFHANDATTACK) != 0;
			if (down && holdStart[h] == 0) { holdStart[h] = level.maptime; holdKills[h] = 0; }
			if (!down) holdStart[h] = 0;
		}
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
