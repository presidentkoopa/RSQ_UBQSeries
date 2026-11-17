// ============================================================================
// CRITICAL HITS: ONE HYBRID SYSTEM, CREDITED TO BOTH (owner 2026-11-17).
//
// "our critical chance should be, eventually, a stat that we track in our arcade design. for now, let's have randomcrits
// colored random critical shot, and have it give us MKs sounds and visuals and damage and stun"; "we can build a hybrid
// critical system and credit both"; "Random only"; "monsters cannot crit player, this game is dangerous enough with our
// monster tiers".
//
// HOW A CRIT HAPPENS: cyber_c001's RANDOMCRITS. Each player shot rolls the player's crit chance when it is fired
// (RandomCrits' player default, 0.15) and a shot that rolls a crit flies in RandomCrits' crit colour (its translations, its
// colour list, its default colour). RandomCrits' TF2 sounds, its enemy crits and its chance boosts are NOT ported.
//   - A real projectile (bMISSILE, spawned with a player as its target) rolls in WorldThingSpawned, as RandomCrits does,
//     and carries RS_ScoreCritShot. Its blows are crits: its hit, and its explosion on anything it did not just hit.
//   - BD22 VR Reloaded's player rounds (its "Bullet" ballistics: RSQ_PlayerRound, and RSQ_PiercingRound for the Ruger's
//     rail) are not missiles: +NOINTERACTION, they fly by traces and deliver the shot's ORIGINAL hitscan on arrival
//     (LineAttack, LAF_TARGETISSOURCE: the player is the source, the puff the inflictor). Found by class name at run
//     time (Score loads without BD22 VR). A round rolls when it spawns, like a projectile, is coloured and carries
//     RS_ScoreCritShot, and is kept on a short list. The hitscan it delivers is known as its own by where it lands: a
//     round fires it from 2 units short of what it hit, so the blow's puff is next to it (ROUND_NEAR); a piercing round
//     fires each hit from along this tic's step. That blow is the crit, and no second roll is made for it.
//   - A plain hitscan (no projectile: BD22 VR's Hitscan mode, any other player hitscan) rolls when the hit lands. Nothing
//     flies to colour; the crit still shows mk's impact FX. A melee hitscan (LAF_ISMELEEATTACK: fists, saws, kicks) is
//     not a shot and never rolls.
//   - MONSTERS NEVER CRIT THE PLAYER: only a player's blow is ever looked at, and only monsters carry the items.
//
// WHAT A CRIT DOES WHEN IT LANDS: Mikk-'s CRITICAL SHOTS (mk-crits), its critical hit, ported (one path, Land, below).
// His damage factor (rs_score_crit_factor), his 50-tic stun (Pain state, held), his FX at the blow, his sound from the
// player (channel 99), and while stunned every other blow does x rs_score_crit_factor_r. His cvars are renamed
// rs_score_crit_* (same meanings, same defaults). His timing trigger (a blow in the first 10 tics of a monster's attack)
// was REMOVED on the owner's word ("Random only"), and with it Prevent Fast Crits (it only guarded that window) and
// Prevent Damage Stacking (it only read a mark his head shots and backstabs gave, which Score never ported).
//   - A crit shot on a monster that is already stunned still lands (sound, FX, x factor) but does not restart the stun,
//     and it is not ALSO multiplied by the stunned factor: one blow, one crit, counted once.
//   - One blow is judged once: the rest of it in the same tic through the same inflictor (Score's head-shot damage, a
//     rocket's explosion after its hit) neither rolls again nor crits again.
//
// THE CRASH FIX (owner hit it in game, 11-17). His initStun does owner.setState(owner.findState("Pain")). A monster with
// no plain Pain state (Brutal Doom's last-stand SergeantLastStand2: DyingSergeant has only Pain.Stealth) gets
// setState(null), which DESTROYS it inside the damage call. Here a null state is never set: with no Pain state the
// monster is held in the frame it is in for the stun, and every use of the monster after a state change is guarded.
//
// THE CRIT CHANCE IS A TRACKED STAT, in ONE place: RS_ScoreTracker.CritChance() on the player (tracker.zs), read and
// raised through RS_ScoreCritHandler.ChanceOf / SetChanceOf below, or by any mod by name: RS_ScoreService "crit.chance"
// (objectArg the pawn -> permille) and "crit.chance.set" (intArg permille, objectArg the pawn -> permille now). It starts
// from rs_score_crit_random_chance (0.15). No boost system is built yet.
//
// STAND-DOWN, by class name, once (OnRegister): with mk-crits loaded, Score's crits give nothing (as before); with
// RandomCrits loaded, Score's random roll stands down, and since the roll is the only way to crit, Score's crits do
// nothing. One console line each. So no crit ever fires twice.
//
// SCORE: a crit is told to the combo ledger as the tag "crit" (combo.zs Touch), as Gun Bonsai VR's crits are. No row pays
// for it on its own.
// ============================================================================

// a shot (projectile or BD22 VR round) that rolled a crit carries this (RandomCrits' RandomCrits_CritMissileToken)
class RS_ScoreCritShot : Inventory
{
	Default
	{
		+INVENTORY.IGNORESKILL;
		+INVENTORY.UNTOSSABLE;
		Inventory.Amount 1;
		Inventory.MaxAmount 1;
	}
}

class RS_ScoreCritBrain : Inventory
{
	// his csh_sounds / csh_visualFX, in his order (the menu's RSQSC_CritSounds / RSQSC_CritFX numbers)
	static const String CRIT_SOUNDS[] =
	{
		"",
		"rs_score_crit/mmz/clash",
		"rs_score_crit/cod/hitmark",
		"rs_score_crit/dks/dink",
		"rs_score_crit/dks/kill1",
		"rs_score_crit/dks/kill2",
		"rs_score_crit/dks/meat",
		"rs_score_crit/tf2/crit",
		"rs_score_crit/tf2/rec",
		"rs_score_crit/tf2/mini",
		"rs_score_crit/csz/headshot",
		"rs_score_crit/csg/helmet",
		"rs_score_crit/csg/headshot",
		"rs_score_crit/re1/slash",
		"rs_score_crit/re1/pop",
		"rs_score_crit/nmc/cutbody",
		"rs_score_crit/htd/splat"
	};

	static const String CRIT_FX[] =
	{
		"",
		"RS_ScoreCritFX_SmallBloodSplatter",
		"RS_ScoreCritFX_LargeBloodSplatter",
		"RS_ScoreCritFX_SharpBlueFlash",
		"RS_ScoreCritFX_RoundRedFlash",
		"RS_ScoreCritFX_RoundBlueRedFlash",
		"RS_ScoreCritFX_BloodSplat",
		"RS_ScoreCritFX_TF2Crit"
	};

	// Every blow on this monster passes here first (the handler gives the controller, then this: this is ahead of it in
	// the monster's inventory, so the controller sees what this decided).
	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		if (!passive) return;

		Actor monster = owner;
		if (!monster || !source || !source.player) return;   // a player's blow only: monsters never crit
		if (!rs_score_crit_enabled || damageType == 'critical') return;

		let h = RS_ScoreCritHandler.Get();
		if (!h) return;

		// ONE BLOW, ONE CRIT. A blow can reach this monster more than once in a tic through the same inflictor: Score's
		// head-shot damage (head.zs DealPending: the same puff or missile, type 'Head', sized from the blow already
		// multiplied), a crit rocket's hit and then its explosion. The first is judged; the rest pass as they are: no
		// second roll, sound, FX, stun or multiplier.
		if (h.Judged(monster, inflictor) >= 0) return;

		String how = h.CritBlow(inflictor, source, flags);
		h.Judge(monster, inflictor, how != "");
		if (how == "") return;

		newdamage = Land(monster, damage, inflictor, source, how);
	}

	// MK'S CRIT, the one path every crit takes: the stun, the FX, the sound, the damage, the ledger's "crit". Returns the
	// blow's new damage.
	int Land(Actor monster, int damage, Actor inflictor, Actor src, String how)
	{
		let info = RS_ScoreCritController(monster.FindInventory("RS_ScoreCritController"));

		// what the FX, the sound and the log need, read BEFORE the stun's state change
		Vector3 at = monster.pos + (0, 0, monster.height * 0.5);
		if (inflictor) at = inflictor.pos;
		TranslationID btrans = monster.BloodTranslation;   // a TranslationID under version 4.14 (his 4.3 read an int)
		String mname = monster.GetClassName();
		String iname = inflictor ? inflictor.GetClassName() : "nothing";

		bool wasStunned = info && info.isStunned;
		bool toPain = false;
		if (info && !wasStunned)
		{
			toPain = info.InitStun();

			// [crash fix] the state change may have ended the monster (and this item with it): touch nothing of it then
			if (!monster || monster.bDestroyed || !info || info.bDestroyed)
			{
				if (RS_ScoreCritHandler.DebugOn())
					Console.Printf("RS_Score crit: %s ended by its Pain state on the crit; nothing more done", mname);
				return damage;
			}
		}

		// the critical blow itself is never also multiplied by the stunned factor (the controller reads this)
		monster.GiveInventory("RS_ScoreCritJustStunned", 1);

		int eff = rs_score_crit_effect;
		String fxName = "none";
		if (eff > 0 && eff < CRIT_FX.Size())
		{
			class<Actor> fxc = (class<Actor>)(CRIT_FX[eff]);
			let hitfx = fxc ? Actor.Spawn(fxc, at) : null;
			if (hitfx)
			{
				fxName = hitfx.GetClassName();
				if (eff <= 2 || eff == 6) hitfx.translation = btrans;
			}
		}

		int snd = rs_score_crit_sound;
		String sndName = "none";
		if (src && snd > 0 && snd < CRIT_SOUNDS.Size())
		{
			src.A_StartSound(CRIT_SOUNDS[snd], 99, 0, rs_score_crit_vol);
			sndName = CRIT_SOUNDS[snd];
		}

		int newdamage = int(damage * rs_score_crit_factor);

		// Score: the ledger's "crit" tag on this blow (taken by the blow's own entry, this tic)
		if (src && src.player)
		{
			let led = RS_ComboLedger.Get();
			int pn = src.PlayerNumber();
			if (led && monster && pn >= 0 && pn < MAXPLAYERS)
			{
				led.Poll(monster, pn);
				led.Touch(monster, pn, "crit", level.maptime);
			}
		}

		if (RS_ScoreCritHandler.DebugOn())
			Console.Printf("RS_Score crit: CRITICAL HIT (%s) on %s by %s: %d -> %d, stun %s, fx %s, sound %s",
				how, mname, iname, damage, newdamage,
				wasStunned ? "already running (not restarted)" : (!info ? "none (no controller)" : (toPain ? "Pain state" : "held in its frame (no Pain state)")),
				fxName, sndName);
		return newdamage;
	}
}

// His csh_critController, its stun only (the timing window that started crits is gone: "Random only").
class RS_ScoreCritController : Inventory
{
	int stunTime;
	bool isStunned;

	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		if (passive && isStunned && owner)
		{
			double a = max(1, ApplyDamageFactors(GetClass(), damageType, damage, int(damage * rs_score_crit_factor_r)));

			if (owner.CountInv("RS_ScoreCritJustStunned"))
				a = damage;

			newdamage = int(a);
		}
	}

	// His initStun, with the crash fix. True: the monster went to its Pain state. False: it has none, and is held in the
	// frame it is in (the tics -1 below; DoEffect keeps it held for the stun, as it holds a Pain frame).
	bool InitStun()
	{
		isStunned = true;
		stunTime = 50;
		owner.tics = -1;
		owner.bNOPAIN = true;

		State pain = owner.FindState("Pain");
		if (!pain) return false;   // never SetState(null): that destroys the monster mid-damage
		owner.SetState(pain);
		return true;
	}

	void EndStun()
	{
		isStunned = false;
		stunTime = 0;
		if (!owner) return;
		owner.tics = 1;
		owner.bNOPAIN = owner.default.bNOPAIN;
	}

	override void DoEffect()
	{
		Super.DoEffect();

		if (!owner) return;

		if (owner.health < 1)
		{
			if (stunTime) EndStun();
			return;
		}

		if (stunTime)
		{
			owner.tics = -1;
			stunTime--;
			return;
		}

		if (isStunned) EndStun();
	}
}

// ---- his delayer (delayer.txt): an item that removes itself lifeSpan tics after it was last given ----
class RS_ScoreCritDelayer : Inventory
{
	property LifeSpan: lifeSpan;
	int lifeSpan;
	int age;

	Default
	{
		RS_ScoreCritDelayer.LifeSpan 0;
		Inventory.MaxAmount 1;
	}

	override void DoEffect()
	{
		Super.DoEffect();
		age--;
		if (age <= 0) DepleteOrDestroy();
	}

	override void AttachToOwner(Actor other)
	{
		Super.AttachToOwner(other);
		age = lifeSpan;
	}

	override bool HandlePickup(Inventory item)
	{
		age = lifeSpan;
		return Super.HandlePickup(item);
	}
}

// his csh_JustStunned: the critical blow itself (2 tics), so the stunned factor never stacks on a crit
class RS_ScoreCritJustStunned : RS_ScoreCritDelayer
{
	Default
	{
		RS_ScoreCritDelayer.LifeSpan 2;
	}
}

// ---- the handler: the stand-downs, the items, the rolls ----
class RS_ScoreCritHandler : StaticEventHandler
{
	const ROUND_NEAR = 16.0;   // a round's delivered hitscan lands within this of the round (2 short, puff z +-4, compat 10)
	const ROUND_SPEED = 80.0;  // BD22 VR's round speed default (its sv_rsq_round_speed), for a piercing round's step

	// RandomCrits' player-shot colours (trnslate.txt, Score's TRNSLATE.txt RSQSC_Crit*), its numbers (the menu's
	// RSQSC_CritColours); 0 is its "none"
	static const String CRIT_COLOURS[] =
	{
		"",
		"RSQSC_CritBlack",
		"RSQSC_CritBlue",
		"RSQSC_CritGreen",
		"RSQSC_CritCyan",
		"RSQSC_CritRed",
		"RSQSC_CritViolet",
		"RSQSC_CritOrange",
		"RSQSC_CritGray",
		"RSQSC_CritWhite",
		"RSQSC_CritAlloyOrange",
		"RSQSC_CritAntiqueBronze",
		"RSQSC_CritAmaranth",
		"RSQSC_CritElectric"
	};

	bool mkLoaded;              // mk-crits is loaded: Score's crits stand down
	bool rcLoaded;              // RandomCrits is loaded: Score's random roll stands down
	class<Actor> roundCls;      // BD22 VR Reloaded's RSQ_PlayerRound, by name (null without BD22 VR)
	class<Actor> pierceCls;     // ...and its RSQ_PiercingRound
	Array<Actor> rounds;        // the player rounds in flight, crit or not (a destroyed one reads null; pruned each tic)
	bool meleeOn[MAXPLAYERS];   // a melee hitscan of this player's is running (WorldHitscanPreFired .. Fired)
	int  meleeAt[MAXPLAYERS];

	static RS_ScoreCritHandler Get() { return RS_ScoreCritHandler(StaticEventHandler.Find("RS_ScoreCritHandler")); }

	static bool DebugOn()
	{
		let cv = CVar.FindCVar("rs_score_debug");
		return cv ? cv.GetBool() : false;
	}

	// ---- THE CRIT CHANCE, a tracked stat (the one place: the player's RS_ScoreTracker) ----
	static clearscope double ChanceOf(Actor pawn)
	{
		let tr = pawn ? RS_ScoreTracker(pawn.FindInventory("RS_ScoreTracker")) : null;
		return tr ? tr.CritChance() : clamp(rs_score_crit_random_chance, 0.0, 1.0);
	}

	// false: no Score tracker on that pawn (nothing kept)
	static bool SetChanceOf(Actor pawn, double chance)
	{
		let tr = pawn ? RS_ScoreTracker(pawn.FindInventory("RS_ScoreTracker")) : null;
		if (!tr) return false;
		tr.SetCritChance(chance);
		return true;
	}

	override void OnRegister()
	{
		// mk-crits' own classes, by name (never linked): either one there means mk-crits is loaded
		class<Actor> b = (class<Actor>)(String.Format("%s", "csh_Brain"));
		class<Actor> c = (class<Actor>)(String.Format("%s", "csh_critController"));
		mkLoaded = (b != null || c != null);
		if (mkLoaded)
			Console.Printf("RSQ Score: Critical Shots (mk-crits) is loaded, so Score's Critical Hits stand down (no double crits). Remove mk-crits to use Score's.");

		// RandomCrits' handler, by name
		class<Object> rc = (class<Object>)(String.Format("%s", "RandomCrits_EventHandler"));
		rcLoaded = (rc != null);
		if (rcLoaded)
			Console.Printf("RSQ Score: RandomCrits is loaded, so Score's random critical shots stand down (no double crits). Remove RandomCrits to use Score's.");

		// BD22 VR Reloaded's player rounds, by name
		roundCls = (class<Actor>)(String.Format("%s", "RSQ_PlayerRound"));
		pierceCls = (class<Actor>)(String.Format("%s", "RSQ_PiercingRound"));
	}

	bool Active() { return !mkLoaded && !rcLoaded; }

	override void WorldUnloaded(WorldEvent e)
	{
		rounds.Clear();
		judgedV.Clear();
		judgedInf.Clear();
		judgedCrit.Clear();
		judgedTic = -1;
		for (int i = 0; i < MAXPLAYERS; i++) meleeOn[i] = false;
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let t = e.Thing;
		if (!t || !Active()) return;

		if (t.bISMONSTER)
		{
			// his handler's order: the controller, then the brain (the brain ends up ahead of it in the inventory)
			t.GiveInventory("RS_ScoreCritController", 1);
			t.GiveInventory("RS_ScoreCritBrain", 1);
			return;
		}

		Actor shooter = t.target;
		if (!shooter || !shooter.player) return;   // a player's shot only (monsters never crit)

		if (roundCls && t is roundCls)
		{
			rounds.Push(t);
			if (rs_score_crit_enabled) RollShot(t, shooter);
			return;
		}

		if (t.bMISSILE && rs_score_crit_enabled) RollShot(t, shooter);
	}

	// RandomCrits' roll on a shot as it is fired: the token and the crit colour
	void RollShot(Actor shot, Actor shooter)
	{
		if (!Roll(shooter)) return;
		shot.GiveInventory("RS_ScoreCritShot", 1);
		int c = rs_score_crit_colour;
		if (c > 0 && c < CRIT_COLOURS.Size()) shot.A_SetTranslation(CRIT_COLOURS[c]);
		if (DebugOn())
			Console.Printf("RS_Score crit: %s rolled a crit shot (chance %.3f, colour %d)", shot.GetClassName(), ChanceOf(shooter), c);
	}

	bool Roll(Actor shooter)
	{
		double chance = ChanceOf(shooter);
		return chance > 0 && frandom[RS_ScoreCrit](0.0, 1.0) < chance;
	}

	// Is this player's blow a crit? "" no; otherwise how it was rolled (for the log).
	String CritBlow(Actor inflictor, Actor src, int flags)
	{
		if (!Active() || !inflictor) return "";

		// a projectile that rolled a crit (its hit or its explosion), or a crit round that is its own inflictor
		if (inflictor.FindInventory("RS_ScoreCritShot"))
			return (roundCls && inflictor is roundCls) ? "round" : "projectile";

		if (!(flags & DMG_INFLICTOR_IS_PUFF)) return "";   // not a hitscan: a projectile that did not roll, melee mods...

		int r = RoundOf(inflictor, src);
		if (r == 1) return "round";   // the hitscan a crit round delivered
		if (r == 0) return "";        // a round that rolled no crit when it was fired

		if (MeleeNow(src)) return "";
		return Roll(src) ? "hitscan" : "";   // a plain hitscan: rolled as it lands
	}

	// Which of this player's rounds delivered the hitscan whose puff is `puff`: -1 none (a plain hitscan), 0 a round that
	// rolled no crit, 1 a crit round. A round fires its hitscan from 2 units short of what it reached, so the puff is
	// beside it; a piercing round fires each of its hits from along the step it takes this tic.
	int RoundOf(Actor puff, Actor src)
	{
		if (!puff || !roundCls || rounds.Size() == 0) return -1;

		Actor best = null;
		double bestD = ROUND_NEAR;
		double step = -1;
		for (int i = 0; i < rounds.Size(); i++)
		{
			let r = rounds[i];
			if (!r || r.target != src) continue;

			double d;
			if (pierceCls && r is pierceCls)
			{
				if (step < 0)
				{
					let cv = CVar.FindCVar("sv_rsq_round_speed");
					step = cv ? clamp(cv.GetFloat(), 10.0, 1000.0) : ROUND_SPEED;
				}
				double cp = cos(r.pitch);
				Vector3 dir = (cp * cos(r.angle), cp * sin(r.angle), -sin(r.pitch));
				Vector3 v = level.Vec3Diff(r.pos, puff.pos);
				double along = v dot dir;
				if (along < -ROUND_NEAR || along > step + ROUND_NEAR) continue;
				d = (v - dir * along).Length();
			}
			else
				d = r.Distance3D(puff);

			if (d < bestD)
			{
				bestD = d;
				best = r;
			}
		}
		if (!best) return -1;
		return best.FindInventory("RS_ScoreCritShot") ? 1 : 0;
	}

	// this tic's blows already judged (Brain.ModifyDamage): -1 not yet, 0 judged no crit, 1 judged a crit
	Array<Actor> judgedV;
	Array<Actor> judgedInf;
	Array<bool>  judgedCrit;
	int judgedTic;

	int Judged(Actor v, Actor inf)
	{
		if (judgedTic != level.maptime)
		{
			judgedV.Clear();
			judgedInf.Clear();
			judgedCrit.Clear();
			judgedTic = level.maptime;
			return -1;
		}
		for (int i = 0; i < judgedV.Size(); i++)
			if (judgedV[i] == v && judgedInf[i] == inf) return judgedCrit[i] ? 1 : 0;
		return -1;
	}

	void Judge(Actor v, Actor inf, bool crit)
	{
		judgedV.Push(v);
		judgedInf.Push(inf);
		judgedCrit.Push(crit);
	}

	bool MeleeNow(Actor src)
	{
		int pn = src.PlayerNumber();
		return pn >= 0 && pn < MAXPLAYERS && meleeOn[pn] && meleeAt[pn] == level.maptime;
	}

	// a melee hitscan is not a shot: noted while it runs (its damage is dealt inside the LineAttack, between these two)
	override bool WorldHitscanPreFired(WorldEvent e)
	{
		let mo = e.Thing;
		if (mo && mo.player)
		{
			int pn = mo.PlayerNumber();
			if (pn >= 0 && pn < MAXPLAYERS)
			{
				meleeOn[pn] = (e.AttackLineFlags & LAF_ISMELEEATTACK) != 0;
				meleeAt[pn] = level.maptime;
			}
		}
		return false;   // never cancels a shot
	}

	override void WorldHitscanFired(WorldEvent e)
	{
		let mo = e.Thing;
		if (mo && mo.player)
		{
			int pn = mo.PlayerNumber();
			if (pn >= 0 && pn < MAXPLAYERS) meleeOn[pn] = false;
		}
	}

	override void WorldTick()
	{
		for (int i = rounds.Size() - 1; i >= 0; i--)
			if (!rounds[i]) rounds.Delete(i);
	}
}

// ---- his visual FX (visuals.txt), his art: sprites RCRA (his CRIT), RCRB (HSHT), RCRC (BCKS), RCRD (TF2C), RCRE / RCRF /
// RCRG (Major Cooke's X057 / X058 / X059) ----
class RS_ScoreCritFX_SmallBloodSplatter : Actor
{
	Default
	{
		+NOBLOCKMAP;
		RenderStyle "None";
	}
	States
	{
	Spawn:
		TNT1 A 1 NoDelay
		{
			for (int i = 0; i < 12; i++)
			{
				A_SpawnItemEx("Blood", xvel: frandom(1.0, 6.0), zvel: frandom(4.0, 8.0), angle: frandom(0.0, 360.0), SXF_TRANSFERTRANSLATION);
			}
		}
		Stop;
	}
}

class RS_ScoreCritFX_LargeBloodSplatter : RS_ScoreCritFX_SmallBloodSplatter
{
	States
	{
	Spawn:
		TNT1 A 1 NoDelay
		{
			for (int i = 0; i < 24; i++)
			{
				A_SpawnItemEx("Blood", xvel: frandom(1.0, 6.0), zvel: frandom(4.0, 8.0), angle: frandom(0.0, 360.0), SXF_TRANSFERTRANSLATION);
			}
		}
		Stop;
	}
}

class RS_ScoreCritFX_SharpBlueFlash : Actor
{
	Default
	{
		RenderStyle "Add";
		+NOGRAVITY;
		+NOBLOCKMAP;
		+NOINTERACTION;
		+ROLLSPRITE;
		+ROLLCENTER;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		bSPRITEFLIP = random(false, true);
		roll = frandom(-45.0, 45.0);
		scale.x = scale.y = frandom(1.1, 1.5);
	}

	States
	{
	Spawn:
		RCRA ABCDEFGHIJKLM 1 Bright;
		RCRA NOPQR 1 Bright A_FadeOut();
		Stop;
	}
}

class RS_ScoreCritFX_BloodSplat : Actor
{
	Default
	{
		+NOGRAVITY;
		+NOBLOCKMAP;
		+NOINTERACTION;
		+ROLLSPRITE;
		+ROLLCENTER;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		bSPRITEFLIP = random(false, true);
		roll = frandom(-45.0, 45.0);
		scale.x = scale.y = frandom(1.0, 1.2);
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_Jump(255, "State1", "State2", "State3");
	State1:
		RCRE ABCDEFGHIJ 1;
		RCRE KLMNOPQRS 1 A_FadeOut();
		Stop;
	State2:
		RCRF ABCDEFGHI 1;
		RCRF JKLMNOPQ 1 A_FadeOut();
		Stop;
	State3:
		RCRG ABCDEFG 1;
		RCRG HIJKL 1 A_FadeOut();
		Stop;
	}
}

class RS_ScoreCritFX_RoundRedFlash : Actor
{
	Default
	{
		RenderStyle "Add";
		+NOGRAVITY;
		+NOBLOCKMAP;
		+NOINTERACTION;
		+ROLLSPRITE;
		+ROLLCENTER;
	}

	override void PostBeginPlay()
	{
		bSPRITEFLIP = random(false, true);
		roll = frandom(-45.0, 45.0);
		scale.x = scale.y = frandom(0.30, 0.40);
		Super.PostBeginPlay();
	}

	States
	{
	Spawn:
		RCRB ABCDEFGHIJKLM 1 Bright;
		RCRB NOPQRS 1 Bright A_FadeOut();
		Stop;
	}
}

class RS_ScoreCritFX_RoundBlueRedFlash : Actor
{
	Default
	{
		RenderStyle "Add";
		+NOGRAVITY;
		+NOBLOCKMAP;
		+NOINTERACTION;
		+ROLLSPRITE;
		+ROLLCENTER;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		bSPRITEFLIP = random(false, true);
		roll = frandom(-45.0, 45.0);
		scale.x = scale.y = frandom(0.8, 1.0);
	}

	States
	{
	Spawn:
		RCRC ABCDEFGHIJKL 1 Bright;
		Stop;
	}
}

class RS_ScoreCritFX_TF2Crit : Actor
{
	Default
	{
		Scale 0.1;
		VSpeed 1;
		+NOGRAVITY;
		+NOBLOCKMAP;
		+NOINTERACTION;
	}

	States
	{
	Spawn:
		RCRD AAAAAAAAAA 1 Bright A_ScaleVelocity(0.9);
		RCRD A 1 Bright A_FadeOut();
		Wait;
	}
}
