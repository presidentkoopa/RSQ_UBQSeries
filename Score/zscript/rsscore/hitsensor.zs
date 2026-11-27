// ============================================================================
// XMVE'S HEAD AND LEG HELPERS BECOME DECLARATIONS AND SENSORS (design/GORE_SYSTEM_DESIGN.md section 3, option C, and
// section 9; owner Q1 2026-11-27: "the XMVE helper takeover lives in RSQ Score").
//
// WHAT XMVE DOES TODAY. On about 2,800 animation frames its monsters A_SpawnItem a HeadshotTarget* (r7 h18, alive 4-201
// tics) or a LegTarget* (r24 h12) at the pose's head or legs: about 20 shootable blockmap actors a second in a fight, each
// one checked by every hitscan and missile. The helper's `target` is its monster (A_SpawnItem: attacks.zs InitSpawnedItem).
//   - HeadshotTarget (Head_Sys.dec:2-140): Health 999999, so its health ladder is dead code. Any pain: A_Stop, one tic,
//     A_Explode(20, 15, 0, 0, 15) of its DamageType "head", gone. Pain.Saw / Pain.Cut drop SHOOTABLE first;
//     Pain.Explosive / Pain.ExplosiveImpact wait 3 tics first.
//   - LegTarget (Leg.dec:1-168): Health 300. Any pain: one tic, then a ladder on the health it has lost picks an
//     A_Explode(N, 20, 0) of type "leg" (2 to 400), and one more tic. A kill: Death's A_Explode(200, 20, 0).
//   - Neither passes XF_HURTSOURCE, so the explosion hurts its monster only once the engine has made the attacker the
//     helper's target (ReactToDamage, p_interaction.cpp; Die sets it too). Phase 0 measured it: a HeadshotTarget10 hit
//     for 10 by the player gave its SniperZombie 26 "head" damage, source the player, inflictor the helper.
//
// WHAT HAPPENS HERE (only with XMVE loaded and rs_score_hs_sensors on; otherwise nothing is replaced and XMVE runs as
// it does today):
//   1. Every helper class on the generated list (hitsensor_cards.zs, tools/hitsensor_gen.py: the 28 classes NAMED as
//      helpers; `is HeadshotTargetBase` alone would also take MeatShield, TankEngineWeakSpot and six more non-helpers)
//      is replaced by its DECLARATION: +NOBLOCKMAP +NOSECTOR +NOINTERACTION, one tick long.
//   2. On that tick it moves its monster's single HEAD or LEG SENSOR to its own position, sized as its helper class,
//      shootable for exactly as long as the helper would have stood (its card's life), and destroys itself.
//   3. The sensor IS the helper, made persistent: the same flags, damage factors, health, PainChance and pain states,
//      reached through the engine's own damage path (so the pain roll, the retarget and the kill are the engine's, not
//      a copy). Where the helper's chain ended in Stop the sensor goes Spent: not shootable, off the blockmap, until
//      the next declaration. Its blood, blood colour and DONTRIP are its current helper class's.
//   4. Score's outcome rides on the helper's own explosion, onto its monster:
//        head: HitHead given (HitLeg taken), the blast marked a head shot (RS_ScoreHead.sensorBlow: the Headshot row and
//              +head combos see it), and Score's family bonus (+30 Head; 20 on a hitbox family; none from a saw) dealt
//              after every handler has heard the blast (RS_ScoreHeadLate). On IsDown / IsCrouching the bonus is refused
//              and the token is still given, as BD does (Inputs.acs:1114). The helper's own 20 is never refused: XMVE
//              never refused it.
//        leg:  the ladder's damage as XMVE deals it; then HitLeg given (HitHead taken) and the blow stamped a leg shot.
//      Nothing is added when the explosion cannot reach the monster (the attacker is the monster itself).
//
// NETPLAY: gameplay only. Server cvars, no random numbers of our own (the pain roll is the engine's pr_damagemobj, as it
// was the helper's), everything keyed by the monster; nothing reads consoleplayer.
// ============================================================================

class RS_ScoreHitSensors : EventHandler
{
	// the switch (server: the same on every machine). With no CVARINFO row it counts as on, like rs_score_hs_bonus.
	static bool SwitchOn() { let c = CVar.FindCVar("rs_score_hs_sensors"); return !c || c.GetBool(); }

	static RS_ScoreHitSensors Get() { return RS_ScoreHitSensors(EventHandler.Find("RS_ScoreHitSensors")); }

	// ---------------------------------------------------------------- classes by name (XMVE is never linked)
	transient bool clsReady, xmve;
	transient class<Actor> cHeadRoot, cLegRoot;
	transient Array< class<Actor> > cardCls, declCls;
	void Classes()
	{
		if (clsReady) return;
		clsReady = true;
		String n;
		// XMVE's own leg helper (MELeg.txt): Brutal Doom alone defines the other helper classes too, and is left alone
		n = "LegTarget4b";        class<Actor> mark = n;  xmve = mark != null;
		n = "HeadshotTargetBase"; cHeadRoot = n;
		n = "LegTargetBase";      cLegRoot = n;
		cardCls.Clear(); declCls.Clear();
		for (int i = 0; i < RS_ScoreHitCards.Count(); i++)
		{
			n = RS_ScoreHitCards.NameAt(i);          class<Actor> a = n;
			n = "RS_ScoreHitDecl_" .. RS_ScoreHitCards.NameAt(i); class<Actor> b = n;
			cardCls.Push(a); declCls.Push(b);
		}
	}
	int CardOf(class<Actor> c)
	{
		for (int i = 0; i < cardCls.Size(); i++) if (cardCls[i] == c) return i;
		return -1;
	}

	override void CheckReplacement(ReplaceEvent e)
	{
		let r = e.Replacee;
		if (!r) return;
		Classes();
		if (!xmve) return;
		// every spawn of every class passes here: two `is` tests turn away all but the helpers before anything else
		if (!(cHeadRoot && r is cHeadRoot) && !(cLegRoot && r is cLegRoot)) return;
		if (!SwitchOn()) return;
		int i = CardOf(r);
		if (i < 0 || !declCls[i]) return;
		e.Replacement = declCls[i];
	}

	// ---------------------------------------------------------------- one head and one leg sensor per monster
	Array<Actor> mons;
	Array<RS_ScoreHitSensor> heads, legs;
	int lastIdx;

	RS_ScoreHitSensor SensorOf(Actor m, int kind)
	{
		int idx = -1;
		if (lastIdx >= 0 && lastIdx < mons.Size() && mons[lastIdx] == m) idx = lastIdx;
		else for (int i = mons.Size() - 1; i >= 0; i--) if (mons[i] == m) { idx = i; break; }
		if (idx < 0)
		{
			mons.Push(m); heads.Push(null); legs.Push(null);
			idx = mons.Size() - 1;
		}
		lastIdx = idx;
		RS_ScoreHitSensor s = kind == 1 ? heads[idx] : legs[idx];
		if (!s)
		{
			if (kind == 1) s = RS_ScoreHitSensor(Actor.Spawn("RS_ScoreHitSensorHead", m.pos));
			else s = RS_ScoreHitSensor(Actor.Spawn("RS_ScoreHitSensorLeg", m.pos));
			if (!s) return null;
			s.mon = m;
			if (kind == 1) heads[idx] = s; else legs[idx] = s;
		}
		return s;
	}

	// a declaration's tick: XMVE would have stood helper `card` at `p` for its monster `m`
	void Declare(Actor m, int card, Vector3 p)
	{
		int kind = RS_ScoreHitCards.KindAt(card);
		if (!m || kind <= 0) return;
		let s = SensorOf(m, kind);
		if (s) s.Declare(card, p);
	}

	override void WorldTick()
	{
		if ((level.maptime % 35) != 0) return;
		for (int i = mons.Size() - 1; i >= 0; i--)
		{
			if (mons[i] && (heads[i] || legs[i])) continue;
			mons.Delete(i); heads.Delete(i); legs.Delete(i);   // a gone monster's sensors destroy themselves (Tick)
		}
		lastIdx = -1;
	}
}

// ============================================================================
// The declaration: stands where XMVE's helper would have, for one tick, then moves its monster's sensor there.
// Its subclasses (one per helper class, hitsensor_cards.zs) only name their card row.
// ============================================================================
class RS_ScoreHitDecl : Actor
{
	virtual int Card() { return -1; }
	Default
	{
		Radius 1;
		Height 1;
		RenderStyle "None";
		+NOBLOCKMAP
		+NOSECTOR
		+NOINTERACTION
		+NOGRAVITY
		+DONTSPLASH
		+NOTELEPORT
		+NOTONAUTOMAP
	}
	// Tick, not a state action: a spawned actor's first state runs no action without NoDelay. Its first tick is the tick
	// on which XMVE's helper would have taken its first tick (both are spawned by the same A_SpawnItem).
	override void Tick()
	{
		if (bDestroyed) return;
		Actor m = target ? target : master;   // A_SpawnItem makes the monster the target (and the master unless useammo 0)
		let h = RS_ScoreHitSensors.Get();
		if (h && m) h.Declare(m, Card(), pos);
		Destroy();
	}
	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}
}

// ============================================================================
// The sensor: a persistent copy of the helper (see the top of this file). Head and leg subclasses carry the helper's
// own Default block and pain states; this base carries the arming, the expiry and the parts both share.
// ============================================================================
class RS_ScoreHitSensor : Actor
{
	Actor mon;                 // the monster it serves (not `master`: a monster's A_RemoveChildren must not take it)
	class<Actor> helper;       // the XMVE class it currently stands in for (its blood, blood colour, DONTRIP)
	int card;                  // that class's row (hitsensor_cards.zs)
	Vector3 declPos;           // where the newest declaration stood
	int expireTic;             // the tic on which that helper would have gone
	bool inPain;               // a pain or death chain is running: the helper it was is still finishing
	bool rearm;                // a declaration came during that chain: arm for it when the chain ends

	Default
	{
		Mass 999999;
		PainChance 255;
		-COUNTKILL
		-SOLID
		+NOTARGET
		+NOGRAVITY
		+SHOOTABLE
		+NOTELEPORT
		+FORCERADIUSDMG
		+NODAMAGETHRUST
		+THRUGHOST
		+NORADIUSDMG
		+GHOST
		+NOTAUTOAIMED
		// (the helpers' +SERVERSIDEONLY is a dummy flag in this engine: thingdef_data.cpp DEFINE_DUMMY_FLAG)
	}

	virtual int Kind() { return 0; }

	// a declaration: XMVE would have spawned helper row `c` at `p` now
	void Declare(int c, Vector3 p)
	{
		card = c;
		declPos = p;
		expireTic = level.maptime + max(1, RS_ScoreHitCards.LifeAt(c)) - 1;
		if (inPain) { rearm = true; return; }   // the old helper is still exploding: finish it first (Spend)
		Arm();
		SetStateLabel("Spawn");
	}

	// become a fresh helper of row `card` at declPos: its box, its health, its monster as target, shootable
	void Arm()
	{
		rearm = false;
		String n = RS_ScoreHitCards.NameAt(card);
		helper = n;
		double r = RS_ScoreHitCards.RadiusAt(card), hh = RS_ScoreHitCards.HeightAt(card);
		int hp = RS_ScoreHitCards.HealthAt(card);
		if (helper)
		{
			let d = GetDefaultByType(helper);
			r = d.radius; hh = d.height; hp = d.SpawnHealth();
			CopyBloodColor(d);
			bDontRip = d.bDontRip;
		}
		health = hp;
		target = mon;
		bShootable = true;
		bThruActors = false;
		vel = (0, 0, 0);
		A_ChangeLinkFlags(0);          // back in the blockmap
		A_SetSize(r, hh);
		SetOrigin(declPos, false);
		// where the helper's own first move would have put it: under the ceiling, on or over the floor
		double z = pos.z;
		if (z + hh > ceilingz) z = ceilingz - hh;
		if (z < floorz) z = floorz;
		if (z != pos.z) SetZ(z);
	}

	// where the helper's chain ended (Stop): nothing to shoot until the next declaration
	void Disarm()
	{
		bShootable = false;
		A_ChangeLinkFlags(1);          // off the blockmap: no hitscan or mover checks it
	}

	// the end of a pain or death chain; returns the state to go to (the Spawn wait, if a declaration came meanwhile)
	state Spend()
	{
		inPain = false;
		Disarm();
		if (rearm && level.maptime < expireTic)
		{
			Arm();
			return FindState("Spawn");   // (FindState: ResolveState is an action function)
		}
		rearm = false;
		return null;
	}

	override void Tick()
	{
		if (!mon && !inPain) { Destroy(); return; }
		if (inPain) { Super.Tick(); return; }          // the helper's own chain: tics, A_Stop, its move
		if (bShootable && level.maptime >= expireTic) Disarm();
		// armed and waiting (TNT1 A -1, no velocity) or spent: nothing else to run
	}

	// the helper's blood is its class's (Brutal_Blood, or Green_Blood on the b variants), replaced as the engine does
	override class<Actor> GetBloodType(int type)
	{
		if (!helper) return Super.GetBloodType(type);
		let d = GetDefaultByType(helper);
		class<Actor> c;
		if (type == 0) c = d.BloodType;
		else if (type == 1) c = d.BloodType2;
		else if (type == 2) c = d.BloodType3;
		else return null;
		return c ? GetReplacement(c) : null;
	}

	// Never the engine's death: the sensor outlives every helper. What Die did to the helper that matters here: its
	// killer becomes its target (p_interaction.cpp AActor::Die), it is no longer shootable, and its Death state plays
	// (XDeath below its gib health).
	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		if (source) target = source;
		bShootable = false;
		inPain = true;
		// a ternary of two labels is a String, which does not convert to a StateLabel: branch instead
		if (health < GetGibHealth()) SetStateLabel("XDeath"); else SetStateLabel("Death");
	}

	// ---------------------------------------------------------------- Score's outcome
	// the attacker the engine left as target, if the helper's explosion can reach the monster (no XF_HURTSOURCE)
	Actor Striker()
	{
		let src = target;
		return (src && mon && src != mon) ? src : null;
	}

	static void Tokens(RS_ScoreHead h, Actor m, bool head)
	{
		// a blast that killed the monster may have removed it already (its death state can Stop at once): giving it a token
		// then reads a dead actor's inventory and aborts the VM (rig 2026-11-27, leg blast). A dead monster has picked its
		// death; XMVE's own helpers never gave it tokens either.
		if (!m || m.health <= 0) return;
		h.Classes();
		if (head)
		{
			if (h.cHitLeg) m.TakeInventory(h.cHitLeg, 0x7FFFFFFF);
			if (h.cHitHead) m.GiveInventory(h.cHitHead, 1);
		}
		else
		{
			if (h.cHitHead) m.TakeInventory(h.cHitHead, 0x7FFFFFFF);
			if (h.cHitLeg) m.GiveInventory(h.cHitLeg, 1);
		}
	}

	void HSLog(String what, Actor src, int dmg, int hpBefore)
	{
		if (!RS_ScoreHead.LogOn()) return;
		String sn = "none";
		if (src && src.player) sn = "player"; else if (src) sn = src.GetClassName();
		Console.Printf("HS t%d xmve %s %s on %s (H %.1f) box r %.1f h %.1f at up %.1f: blast %d src %s hp %d -> %d",
			level.maptime, what, helper ? helper.GetClassName() : 'none', mon ? mon.GetClassName() : 'none', mon ? mon.height : 0.0,
			radius, height, mon ? pos.z - mon.pos.z : 0.0, dmg, sn, hpBefore, mon ? mon.health : 0);
	}
}

// ============================================================================
// HEAD: HeadshotTargetBase's Default block and pain states (Head_Sys.dec:2-140), with Score's head outcome on its blast.
// ============================================================================
class RS_ScoreHitSensorHead : RS_ScoreHitSensor
{
	Default
	{
		Health 999999;
		Radius 7;
		Height 18;
		DamageType "head";
		BloodType "Brutal_Blood", "SawBlood", "SawBlood";
		DamageFactor "Taunt", 0.0; DamageFactor "Blood", 0.0; DamageFactor "BlueBlood", 0.0;
		DamageFactor "Head", 0.0; DamageFactor "MinorHead", 0.0; DamageFactor "KillMe", 0.0;
		DamageFactor "Control", 0.0; DamageFactor "Trample", 0.0; DamageFactor "GibRemoving", 0.0;
		DamageFactor "Alert", 0.0; DamageFactor "SSG", 1.5; DamageFactor "ExplosiveImpact", 0.0;
		DamageFactor "use", 0.0; DamageFactor "SHOTGUN", 1.4;
		DamageFactor "TeleportRemover", 0.0; DamageFactor "Fire", 0.0; DamageFactor "Stealth", 0.0;
	}
	override int Kind() { return 1; }

	// Score's family bonus for a head blast: +30 Head on a blood family (BD's ACS Head_Shot), the blast again (20) on a
	// hitbox family, +30 on a family BD gave no numbers; refused on IsDown / IsCrouching (Inputs.acs:1114) and from a saw
	int Bonus(RS_ScoreHead h, Actor m, Actor src)
	{
		if (!RS_ScoreHead.BonusOn()) return 0;
		h.Classes();
		if ((h.cIsDown && m.FindInventory(h.cIsDown)) || (h.cIsCrouching && m.FindInventory(h.cIsCrouching))) return 0;
		if (src.player && src.player.ReadyWeapon && src.player.ReadyWeapon.bAxeBlood) return 0;
		int rt = RS_ScoreHead.Route(h.FamilyOf(m));
		if (rt == 1) return 30;
		if (rt == 2) return 20;
		if (rt == 3) return RS_ScoreHead.HeadlessOn() ? 30 : 0;
		return 30;
	}

	// the helper's A_Explode(20, 15, 0, 0, 15), of its DamageType "head", with Score's outcome on its monster
	void HeadBlast()
	{
		let m = mon;
		let src = Striker();
		let h = RS_ScoreHead.Get();
		int hp = m ? m.health : 0;
		bool scored = h && src && m.health > 0;
		if (scored)
		{
			Tokens(h, m, true);                    // before the blast: a blast that kills picks its death with them
			int amt = Bonus(h, m, src);
			if (amt > 0)
			{
				// dealt by RS_ScoreHeadLate after every handler has heard the blast, as Score's own head bonus is
				h.pV = m; h.pInf = self; h.pSrc = src; h.pAmt = amt; h.pFlags = DMG_THRUSTLESS; h.pTic = level.maptime; h.pOn = true;
			}
			h.sensorBlow = true;                   // the blast is a head shot to Score (stamp, Headshot row, +head)
		}
		A_Explode(20, 15, 0, false, 15);
		if (h)
		{
			h.sensorBlow = false;
			if (h.pOn && h.pInf == self) h.pOn = false;   // the blast did not reach it: no bonus left waiting
		}
		HSLog("head", target, 20, hp);
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	Pain.Explosive:
	Pain.ExplosiveImpact:
		TNT1 A 3 { inPain = true; }
		Goto Pain;
	Pain.Saw:
	Pain.Cut:
		TNT1 A 0 { inPain = true; bShootable = false; bThruActors = false; }
	Pain:
		TNT1 A 0 { inPain = true; A_Stop(); }
		TNT1 A 1;
		// (the health ladder that follows here in Head_Sys.dec is dead code at Health 999999: every pain falls through)
		TNT1 A 0 { HeadBlast(); }
		TNT1 A 0 { return Spend(); }
		TNT1 A -1;
		Stop;
	Death:                                       // only a telefrag reaches it: no blast
		TNT1 A 1 { inPain = true; }
		TNT1 A 0 { return Spend(); }
		TNT1 A -1;
		Stop;
	XDeath:
		Goto Death;
	}
}

// ============================================================================
// LEG: LegTargetBase's Default block and pain ladder (Leg.dec:1-168), with Score's leg outcome after its blast.
// tools/hitsensor_lint.py checks LadderAt against Leg.dec's thresholds and blasts.
// ============================================================================
class RS_ScoreHitSensorLeg : RS_ScoreHitSensor
{
	Default
	{
		Health 300;
		GibHealth 10000;
		Radius 24;
		Height 12;
		DamageType "leg";
		BloodType "Brutal_Blood", "SawBlood", "SawBlood";
		DamageFactor "Taunt", 0.0; DamageFactor "Blood", 0.0;
		DamageFactor "BlueBlood", 0.0; DamageFactor "Head", 0.0;
		DamageFactor "Leg", 0.0; DamageFactor "MinorHead", 0.0;
		DamageFactor "KillMe", 0.0; DamageFactor "Control", 0.0;
		DamageFactor "Trample", 0.0; DamageFactor "GibRemoving", 0.0;
		DamageFactor "Fire", 0.0; DamageFactor "Alert", 0.0;
		DamageFactor "SSG", 0.0; DamageFactor "ExplosiveImpact", 0.0;
		DamageFactor "Bullet", 1.5;
		DamageFactor "TeleportRemover", 0.0; DamageFactor "Desintegrate", 0.0;
	}
	override int Kind() { return 2; }

	// Leg.dec's Pain ladder, in its order: A_JumpIfHealthLower(below, "PainN") -> A_Explode(blast, 20, 0), then one tic.
	// Health 292 or more (8 damage or less) falls through to A_Explode(20, 20, 0) with no tic after it.
	static int LadderBelow(int i) { static const int V[] = { 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 288, 292 }; return V[i]; }
	static int LadderBlast(int i) { static const int V[] = { 160, 140, 120, 400, 250, 200, 160, 120, 80, 40, 10, 5, 2 }; return V[i]; }
	static int LadderSize() { return 13; }

	// the helper's A_Explode(dmg, 20, 0), of its DamageType "leg"; then Score's leg outcome on its monster
	void LegBlast(int dmg)
	{
		let m = mon;
		let src = Striker();
		int hp = m ? m.health : 0;
		A_Explode(dmg, 20, 0);
		let h = RS_ScoreHead.Get();
		// the blast reached it (Score judged the blast "body" and cleared the tokens): BD's leg shot, as its bloods set it
		if (h && src && m && m.health < hp)
		{
			Tokens(h, m, false);
			h.Stamp(m, self, src, RS_ScoreHead.HV_LEG, m.height > 0 ? (pos.z - m.pos.z) / m.height : 0);
		}
		HSLog("leg", target, dmg, hp);
	}

	// the ladder step: blast now; the PainN states' one tic after it, or none (the fall-through)
	state LadderStep()
	{
		for (int i = 0; i < LadderSize(); i++)
		{
			if (health < LadderBelow(i))
			{
				LegBlast(LadderBlast(i));
				return FindState("Tail");
			}
		}
		LegBlast(20);
		return Spend();
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	Pain.Explosive:
	Pain.ExplosiveImpact:
		TNT1 A 3 { inPain = true; }
		Goto Pain;
	Pain:
		TNT1 A 0 { inPain = true; }
		TNT1 A 1;                                    // (Leg.dec's A_NoBlocking here: a no-op on a non-solid sensor)
		TNT1 A 0 { return LadderStep(); }
		TNT1 A -1;
		Stop;
	Pain.SSG:                                    // Leg.dec's Pain350 label; unreachable at SSG 0.0, kept as written
		TNT1 A 0 { inPain = true; LegBlast(250); }
		Goto Tail;
	Death:
		TNT1 A 0 { inPain = true; LegBlast(200); }
		Goto Tail;
	XDeath:
		TNT1 A 0 { inPain = true; LegBlast(400); }
		Goto Tail;
	Tail:
		TNT1 A 1;
		TNT1 A 0 { return Spend(); }
		TNT1 A -1;
		Stop;
	}
}
