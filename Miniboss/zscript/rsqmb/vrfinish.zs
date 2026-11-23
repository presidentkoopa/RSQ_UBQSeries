// ============================================================================
// RSQ_Miniboss -- THE VR FINISHER: BD22's fatalities without the cut-scene (owner 2026-11-23 07:4x, picked "VR finisher":
// "Any melee strike on a staggered monster finishes it: BD22's gore death and fatality armour kept, no camera, no
// freeze"). Code only, not run.
//
//   WHY             Brutal Doom 22's fatalities, stealth kills, curbstomps and downed-enemy executions are flat-screen
//                   scenes: the monster vanishes (its Death.Fatality / Death.Stealthy / Death.Vanish: A_NoBlocking, Stop),
//                   hands its killer a token (GoFatality, SKImp, ExecuteDownedImp...), and the player's class plays the
//                   scene (Player.dec FatalityChecker: BDStartCamera's third-person camera, invulnerable, held still;
//                   ExecutionsWeap.dec: SetPlayerProperty frozen, the pitch forced to 65-90). In a headset that yanks the
//                   view or freezes you watching nothing.
//   THE SCENE GUARD RSQMB_SceneGuard, an item every player carries: its HandlePickup takes BD22's scene tokens as they are
//                   given (bd_Token family, by name: GoFatality, Execute*, IsCurbstomping*, SK<monster>, any *Fatality*
//                   token) and drops them, so no scene starts. The monster BD22 made vanish is put back as a body and
//                   gibbed at once (a copy of its class, its spot, its facing and colours, no kill count, no source:
//                   BD22's own extreme death, its gore), with the finisher's pop, a short slow motion and Score's Finisher row. A
//                   fatality's own health and armour bonus (HealthPlusFatalityBonus, ArmorShardFatalityBonus: Death.
//                   Fatality spawns them before it vanishes) are left as BD22 gives them; a stealth kill or an execution
//                   (no bonus of its own in BD22) throws the same two.
//   THE FINISHER    any melee strike (finisher.zs MeleeGroup: fists and kicks, saber, ShieldSaw, whip, BD22's blades) by a
//                   player on a STAGGERED monster outside a Boss fight finishes it: an extreme death by that player (his
//                   kill, BD22's gore), BD22's two fatality bonus items thrown from the body, the pop, a short slow
//                   motion and Score's Finisher row (rsqmb_vrfin_score). Staggered: knocked down by BD22 (its IsDown token, Pain.Kick)
//                   or dazed (RSQ_Dazed: Gun Bonsai VR's stagger, which RSQ Melee's uses). Not a boss (+BOSS), not over
//                   rsqmb_vrfin_maxhp (1000) spawn health, not a Boss fight's (Miniboss's own finishers, finisher.zs).
//                   Paid the next tic, never inside the blow.
//   Rows (Boss page, "VR Finisher"): VR Finisher (rsqmb_vrfin), BD22 Scenes Off (rsqmb_vrfin_guard), Most Health, Score.
// ============================================================================

class RSQMB_VRFin : EventHandler
{
	// a monster's death, kept two tics (the scene guard puts the vanished one back)
	Array<Actor> dA;
	Array<String> dCls;
	Array<double> dX, dY, dZ, dAng, dSx, dSy;
	Array<TranslationID> dTr;
	Array<int> dTic;
	// tokens taken (the next tic: the body back)
	Array<Actor> swP;
	Array<bool> swFat;
	Array<String> swWhy;
	Array<int> swTic;
	// finishers due
	Array<Actor> fnV, fnP;
	Array<String> fnWhy;
	bool debug;

	static RSQMB_VRFin Get() { return RSQMB_VRFin(EventHandler.Find("RSQMB_VRFin")); }
	static clearscope int CI(Name n, int d) { return RSQMB_Handler.CI(n, d); }
	static bool On() { return CI('rsqmb_vrfin', 1) != 0; }
	static bool GuardOn() { return On() && CI('rsqmb_vrfin_guard', 1) != 0; }

	// ---- BD22's scene tokens ----------------------------------------------------------------------------------------
	static bool SceneToken(Inventory item)
	{
		if (!item || !RSQMB_Handler.Descends(item, 'bd_Token')) return false;
		String n = item.GetClassName();
		if (n ~== "GoFatality") return true;
		if (n.Left(7) ~== "Execute" || n.Left(14) ~== "IsCurbstomping") return true;
		if (n.IndexOf("Fatality") >= 0 || n.IndexOf("fatality") >= 0) return true;
		static const String SK[] = { "SKImp", "SKZombieMan", "SKShotgunGuy", "SKLabguy", "SKNazi", "SKChaingunGuy", "SKUbersoldat" };
		for (int i = 0; i < SK.Size(); i++) if (n ~== SK[i]) return true;
		return false;
	}

	// RSQMB_SceneGuard.HandlePickup: a token taken. Only the starters put a body back (one a scene).
	void Swallowed(Actor p, Inventory item)
	{
		String n = item.GetClassName();
		bool starter = n ~== "GoFatality" || n.Left(13) ~== "ExecuteDowned" || n.Left(14) ~== "IsCurbstomping" || n.Left(2) ~== "SK";
		if (debug) Console.Printf("RSQMB VR finisher t%d: BD22's %s taken from %s (no scene)", level.maptime, n, p ? p.GetClassName() : 'none');
		if (!starter) return;
		// the move, for SlowMo's cause line: BD22's own name for what you did
		String why = "FATALITY";
		if (n.Left(13) ~== "ExecuteDowned") why = "EXECUTION";
		else if (n.Left(14) ~== "IsCurbstomping") why = "CURBSTOMP";
		else if (n.Left(2) ~== "SK") why = "STEALTH KILL";
		for (int i = 0; i < swP.Size(); i++) if (swP[i] == p && swTic[i] == level.maptime) { if (n ~== "GoFatality") { swFat[i] = true; swWhy[i] = "FATALITY"; } return; }
		swP.Push(p); swFat.Push(n ~== "GoFatality"); swTic.Push(level.maptime); swWhy.Push(why);
	}

	// ---- events -----------------------------------------------------------------------------------------------------
	override void WorldLoaded(WorldEvent e) { debug = CI('rsqmb_debug', 0) != 0; }

	override void WorldThingDied(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || !a.bIsMonster || !GuardOn()) return;
		dA.Push(a); dCls.Push(a.GetClassName());
		dX.Push(a.pos.x); dY.Push(a.pos.y); dZ.Push(a.pos.z); dAng.Push(a.angle);
		dSx.Push(a.scale.x); dSy.Push(a.scale.y);
		dTr.Push(a.Translation); dTic.Push(level.maptime);
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		let v = e.Thing;
		if (!v || !On() || !v.bIsMonster || v.bBOSS) return;
		Actor p = RSQMB_Handler.PlayerOf(e.DamageSource);
		if (!p) p = RSQMB_Handler.PlayerOf(e.Inflictor);
		if (!p) return;
		if (v.GetSpawnHealth() > CI('rsqmb_vrfin_maxhp', 1000)) return;
		if (RSQMB_Service.BossOf(v)) return;                    // a Boss fight's: finisher.zs
		if (!Staggered(v)) return;
		int g = RSQMB_Handler.MeleeGroup(e, p);
		if (g < 0 || !RSQMB_Handler.GroupOn(g)) return;
		for (int i = 0; i < fnV.Size(); i++) if (fnV[i] == v) return;
		fnV.Push(v); fnP.Push(p); fnWhy.Push(RSQMB_Handler.MoveWord(e, g));
		if (debug) Console.Printf("RSQMB VR finisher t%d: %s staggered, %s by a player (%s %d)", level.maptime, v.GetClassName(),
			RSQMB_Handler.GroupName(g), e.DamageType, e.Damage);
	}

	static bool Staggered(Actor v)
	{
		if (!v || v.health <= 0) return false;
		// by name at run time: neither class need exist (BD22's IsDown, Gun Bonsai VR's RSQ_Dazed)
		Class<Inventory> down = "IsDown", dazed = "RSQ_Dazed";
		return (down && v.CountInv(down) > 0) || (dazed && v.CountInv(dazed) > 0);
	}

	override void WorldTick()
	{
		int now = level.maptime;
		// every player carries the guard
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo) continue;
			let mo = players[i].mo;
			if (!mo.FindInventory("RSQMB_SceneGuard")) mo.GiveInventory("RSQMB_SceneGuard", 1);
		}
		// the finishers due
		for (int i = 0; i < fnV.Size(); i++)
		{
			let v = fnV[i];
			let p = fnP[i];
			if (!v || !p || !p.player) continue;
			if (v.health > 0) v.DamageMobj(p, p, v.health + 1000, 'ExtremePunches', DMG_FORCED | DMG_THRUSTLESS | DMG_NO_ARMOR);
			Pay(p, v, v.pos, true, fnWhy[i]);
		}
		fnV.Clear(); fnP.Clear(); fnWhy.Clear();
		// a scene taken: the body back, gibbed
		for (int i = 0; i < swP.Size(); i++)
		{
			if (swTic[i] >= now) continue;     // the next tic: the monster's own death states have run
			let p = swP[i];
			if (p) Restore(p, !swFat[i], swWhy[i]);
			swP.Delete(i); swFat.Delete(i); swTic.Delete(i); swWhy.Delete(i); i--;
		}
		// deaths older than two tics go
		for (int i = dTic.Size() - 1; i >= 0; i--)
		{
			if (now - dTic[i] <= 2) continue;
			dA.Delete(i); dCls.Delete(i); dX.Delete(i); dY.Delete(i); dZ.Delete(i); dAng.Delete(i); dSx.Delete(i); dSy.Delete(i);
			dTr.Delete(i); dTic.Delete(i);
		}
	}

	// the monster BD22 made vanish for its scene: the nearest to the player that died in the last two tics and is gone
	void Restore(Actor p, bool bonus, String why)
	{
		int best = -1;
		double bd = 384;
		int tnt = Actor.GetSpriteIndex('TNT1');
		for (int i = 0; i < dA.Size(); i++)
		{
			let a = dA[i];
			bool gone = !a || a.bDestroyed || a.sprite == tnt;
			if (!gone) continue;
			double d = (p.pos.xy - (dX[i], dY[i])).Length();
			if (d < bd) { bd = d; best = i; }
		}
		if (best < 0) { if (debug) Console.Printf("RSQMB VR finisher t%d: no vanished body near the player", level.maptime); return; }
		Class<Actor> c = dCls[best];
		Vector3 at = (dX[best], dY[best], dZ[best]);
		dTic[best] = -100;      // used
		if (dA[best] && !dA[best].bDestroyed) dA[best] = null;
		if (c)
		{
			let body = Actor.Spawn(c, at, NO_REPLACE);
			if (body)
			{
				body.ClearCounters();
				body.angle = dAng[best];
				body.Translation = dTr[best];
				body.scale = (dSx[best], dSy[best]);
				body.bNOTARGET = true;
				body.DamageMobj(null, null, body.health + 1000, 'ExtremePunches', DMG_FORCED | DMG_THRUSTLESS | DMG_NO_ARMOR);
			}
		}
		Pay(p, null, at, bonus, why);
		if (debug) Console.Printf("RSQMB VR finisher t%d: %s put back and gibbed (BD22's scene skipped)", level.maptime, c ? c.GetClassName() : 'none');
	}

	// the finisher's show and pay: the pop, the slow, Score's Finisher row, BD22's fatality bonus (bonus). No word over it
	// (owner 2026-11-23 07:5x: "i didn't ask for FINISHER!").
	void Pay(Actor p, Actor over, Vector3 at, bool bonus, String why)
	{
		let h = RSQMB_Handler.Get();
		if (bonus)
		{
			Class<Actor> hb = "HealthPlusFatalityBonus", ab = "ArmorShardFatalityBonus";
			if (hb) Actor.Spawn(hb, at + (0, 0, 20), ALLOW_REPLACE);
			if (ab) Actor.Spawn(ab, at + (0, 0, 20), ALLOW_REPLACE);
		}
		int sc = max(0, CI('rsqmb_vrfin_score', 100));
		if (h && sc > 0) h.Award(p, "Finisher", sc);
		let vr = h ? h.VrService() : null;
		Actor anchor = over && !over.bDestroyed ? over : null;
		if (vr && anchor) vr.GetInt("pop", "", 0xFF8020, 1.5, anchor);
		FinSlow(p, false, why);
		p.A_StartSound("misc/i_pkup", CHAN_AUTO, CHANF_OVERLAP, 0.6, ATTN_NONE);
	}
}

// CONTEXTUAL SLOW-MO ON A FINISHER (owner 2026-11-23 07:46: "should we have contextual slo mo for our finishers?"): RSQ
// SlowMo's "g2.slow" (its service, by name; the grapple's KICK! asks the same), rsqmb_fin_slow s (1.0) for a finisher,
// rsqmb_fin_slow_boss s (2.0) for the Boss in BREAK!; 0 = none. SlowMo's own rows still decide (Other / Unknown Mods).
// The reason is the move that did it (finisher.zs MoveWord: PUNCH, KICK, SABER, SHIELDSAW, WHIP, AXE, DRAGONSLAYER, CHAINSAW;
// a BD22 scene taken: FATALITY, EXECUTION, CURBSTOMP, STEALTH KILL), under SlowMo's contextual bar (owner 2026-11-23 07:52).
extend class RSQMB_VRFin
{
	static void FinSlow(Actor p, bool boss, String why)
	{
		let pmo = PlayerPawn(p);
		if (!pmo) return;
		double secs = boss ? RSQMB_Handler.CF('rsqmb_fin_slow_boss', 2.0) : RSQMB_Handler.CF('rsqmb_fin_slow', 1.0);
		if (secs <= 0) return;
		let s = ServiceIterator.Find("RSQSM_Service").Next();
		if (s) s.GetInt("g2.slow", why != "" ? why : "PUNCH", int(clamp(secs, 0.1, 10.0) * TICRATE), 0, pmo);
	}
}

// carried by every player: BD22's scene tokens never land (RSQMB_VRFin)
class RSQMB_SceneGuard : Inventory
{
	Default
	{
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.UNCLEARABLE
		+INVENTORY.HUBPOWER
		Inventory.MaxAmount 1;
	}

	override bool HandlePickup(Inventory item)
	{
		if (Owner && Owner.player && RSQMB_VRFin.GuardOn() && RSQMB_VRFin.SceneToken(item))
		{
			let f = RSQMB_VRFin.Get();
			if (f) f.Swallowed(Owner, item);
			item.bPickupGood = true;
			return true;
		}
		return Super.HandlePickup(item);
	}
}
