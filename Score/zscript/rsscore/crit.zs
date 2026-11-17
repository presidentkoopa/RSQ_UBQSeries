// ============================================================================
// CRITICAL HITS (owner 2026-11-17: "i just want a god damn critical hit with the art style sounds and rules of mk",
// inside RSQ Score).
//
// A PORT OF "CRITICAL SHOTS" (mk-crits) BY MIKK-, its critical hit only: his rules, his cvars (renamed rs_score_crit_*,
// same meanings, same defaults), his visual FX art and his sounds. The author's permission is public (ZDoom forum:
// "You're welcome to use this in your own projects"); the credits are in CREDITS.md and README.md. mk-crits' head shots
// and backstabs are NOT ported: Score judges head shots its own way (head.zs).
//
// HIS RULES, as his csh_Brain / csh_critController run them (csh_classes/core.txt, delayer.txt):
//   - Every monster gets two items when it spawns: the controller, then the brain (his handler's order).
//   - A monster can be critted for the first 10 tics after it starts an attack (enters its Missile or Melee sequence).
//   - A player's blow in that window, on a monster not already stunned, is a CRITICAL HIT: the blow does
//     x rs_score_crit_factor damage, the monster is stunned for 50 tics (sent to its Pain state and held there, no
//     pain reactions meanwhile), the FX spawns where the blow landed and the sound plays from the player (channel 99).
//   - While it is stunned every other blow does x rs_score_crit_factor_r (its damage factors applied), except the
//     critical blow itself and, with Prevent Damage Stacking, a blow marked as a head shot or backstab.
//   - Prevent Fast Crits (rs_score_crit_anticheese): each player blow adds to a counter that lasts 15 tics from the
//     newest blow (at most 3); at 3 the monster cannot be critted. Rapid fire into an attack does not crit.
//   - Damage of type 'critical' never crits.
//
// THE CRASH FIX (owner hit it in game, 11-17). His initStun does owner.setState(owner.findState("Pain")). A monster with
// no plain Pain state (Brutal Doom's last-stand SergeantLastStand2: DyingSergeant has only Pain.Stealth) gets
// setState(null), which DESTROYS it inside the damage call; his next line, monster.GiveInventory("csh_JustStunned"),
// then aborts the VM ("read from address zero"). Here: a null state is never set. With no Pain state the monster is
// held in the frame it is in for the stun (tics -1, as his stun already holds it), with no state jump. And every use of
// the monster after a state change is guarded (a Pain state can still end the actor).
// Also guarded: his FX translation line (`hitfx && effect <= 2 || effect == 6`) read a null hitfx for effect 6, and a
// sound or FX number out of the list's range read past the array. Neither changes what a valid setting does.
//
// BOTH LOADED: mk-crits' classes are looked for by name once (RS_ScoreCritHandler.OnRegister). While mk-crits is
// loaded this port stands down (gives nothing, so nothing fires twice) and says so once in the console.
//
// SCORE: a crit is told to the combo ledger as the tag "crit" (combo.zs Touch), the same "how it landed" fact Gun Bonsai
// VR's crits already send. No row pays for it on its own; a pattern that asks +crit can see it. Nothing else changes.
// ============================================================================

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

	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		if (!passive) return;

		Actor monster = owner;
		if (!inflictor || !monster || !source) return;

		if (!rs_score_crit_enabled || !(source is "PlayerPawn") || damageType == 'critical') return;

		let info = RS_ScoreCritController(monster.FindInventory("RS_ScoreCritController"));

		if (rs_score_crit_anticheese) monster.GiveInventory("RS_ScoreCritDelayerCritical", 1);

		if (!info || info.isStunned) return;
		if (!info.canStun || monster.CountInv("RS_ScoreCritDelayerCritical") > 2) return;

		// what the FX, the sound and the log need, read BEFORE the stun's state change
		Vector3 at = inflictor.pos;
		TranslationID btrans = monster.BloodTranslation;   // a TranslationID under version 4.14 (his 4.3 read an int)
		String mname = monster.GetClassName();
		String iname = inflictor.GetClassName();
		Actor src = source;

		bool toPain = info.InitStun();

		// [crash fix] the state change may have ended the monster (and this item with it): touch nothing of it then
		if (!monster || monster.bDestroyed || !info || info.bDestroyed)
		{
			if (RS_ScoreCritHandler.DebugOn())
				Console.Printf("RS_Score crit: %s ended by its Pain state on the crit; nothing more done", mname);
			return;
		}

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

		newdamage = int(damage * rs_score_crit_factor);

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
			Console.Printf("RS_Score crit: CRITICAL HIT on %s by %s: %d -> %d, stun %s, fx %s, sound %s",
				mname, iname, damage, newdamage, toPain ? "Pain state" : "held in its frame (no Pain state)", fxName, sndName);
	}
}

class RS_ScoreCritController : Inventory
{
	int stunTime;
	int maxTime;
	bool inAction;
	bool canStun;
	bool isStunned;

	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		if (passive && isStunned && owner)
		{
			double a = max(1, ApplyDamageFactors(GetClass(), damageType, damage, int(damage * rs_score_crit_factor_r)));

			if (owner.CountInv("RS_ScoreCritJustStunned") || (rs_score_crit_dontmultiply && owner.CountInv("RS_ScoreCritJustAttacked")))
				a = damage;

			newdamage = int(a);
		}
	}

	bool IsAttacking()
	{
		return owner.InStateSequence(owner.curState, owner.FindState("Missile")) || owner.InStateSequence(owner.curState, owner.FindState("Melee"));
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

		if (!stunTime && isStunned) EndStun();

		if (inAction && canStun)
		{
			if (owner.GetAge() > maxTime) canStun = false;
		}

		if (IsAttacking() && !inAction)
		{
			inAction = true;
			canStun = true;
			maxTime = owner.GetAge() + 10;
		}

		if (!IsAttacking() && inAction) inAction = false;
	}
}

// ---- his delayers (delayer.txt) ----
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

class RS_ScoreCritDelayerCritical : RS_ScoreCritDelayer
{
	Default
	{
		RS_ScoreCritDelayer.LifeSpan 15;
		Inventory.MaxAmount 3;
	}
}

class RS_ScoreCritDelayerHeadshot : RS_ScoreCritDelayer
{
	Default
	{
		RS_ScoreCritDelayer.LifeSpan 2;
	}
}

// his csh_JustAttacked (given by his head shots and backstabs, not ported: Prevent Damage Stacking reads it) and
// csh_JustStunned (the critical blow itself)
class RS_ScoreCritJustAttacked : RS_ScoreCritDelayerHeadshot {}
class RS_ScoreCritJustStunned : RS_ScoreCritJustAttacked {}

// ---- his handler, with the stand-down ----
class RS_ScoreCritHandler : StaticEventHandler
{
	bool mkLoaded;

	static bool DebugOn()
	{
		let cv = CVar.FindCVar("rs_score_debug");
		return cv ? cv.GetBool() : false;
	}

	override void OnRegister()
	{
		// mk-crits' own classes, by name (never linked): either one there means mk-crits is loaded
		class<Actor> b = (class<Actor>)(String.Format("%s", "csh_Brain"));
		class<Actor> c = (class<Actor>)(String.Format("%s", "csh_critController"));
		mkLoaded = (b != null || c != null);
		if (mkLoaded)
			Console.Printf("RSQ Score: Critical Shots (mk-crits) is loaded, so Score's Critical Hits stand down (no double crits). Remove mk-crits to use Score's.");
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if (mkLoaded) return;
		if (e.Thing && e.Thing.bISMONSTER)
		{
			e.Thing.GiveInventory("RS_ScoreCritController", 1);
			e.Thing.GiveInventory("RS_ScoreCritBrain", 1);
		}
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
