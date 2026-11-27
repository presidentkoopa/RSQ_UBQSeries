// ============================================================================
// RSQ Gore PHASE 3 runtime: meat, guts, limbs, heads, halves and casings (design/GORE_SYSTEM_DESIGN.md section 2.3,
// section 5, section 7 phase 3). The classes themselves are GENERATED (zscript/rsqgo/chunk_cards.zs, by
// Gore/tools/chunk_gen.py): one RSQGO_G_<BD class> per Brutal Doom / XMVE class, BD's own properties and states run
// by the engine. This file is what those states call, and the three things that make them cheap:
//
//   1. PARKING. A chunk resting in a -1 frame (on the floor, stuck to a ceiling) is moved to statnum 26
//      (RSQGO_Manager.STAT_PARKED_ACTOR): never ticked again, still saved, still moved by lifts, still shootable.
//      (A gravity piece without MOVEWITHSECTOR joins the ring but stays awake, so a fast-lowering floor drops it as BD's.)
//      statnum is not readable from ZScript (Phase 0), so the actor keeps its own `parked` flag. A parked limb un-parks
//      the moment it is damaged (DamageMobj) or crushed (Grind), so BD's Pain, Death, Death.Kick (the re-launch),
//      Death.Trample, GibRemoving and TeleportRemover all play exactly as BD wrote them.
//   2. THE RING (RSQGO_GibRing). Parked meat and limbs are kept up to the owner's budget (rsqgo_meat_*: 160 on PC,
//      Q3), oldest recycled, never timed out; casings in a ring of their own with the same budget. Flying chunks are
//      capped by rsqgo_fly_* (server cvars: every machine admits the same chunks). This replaces BD's A_QueueCorpse.
//   3. ONE ACTOR FLIES, THEN BECOMES THE LANDED LIMB (RSQGO_Become, RSQGO_DeathEntry): a flier is generated as a
//      subclass of the gib it lands as, so it already carries that gib's damage factors, pain chances and Death.* /
//      Pain states; landing copies the gib's fields and flags (RSQGO_ToGib, generated) and enters its Spawn.
//
// TIERS (design 2.1). Everything here decides actors, so it reads server cvars only and uses no RNG but
// random[RSQGO_Play] (and BD's own state RNG, run by the engine). The particles a trail call emits are phase 1's
// cosmetic tier (RSQGO_Manager.Process).
// ============================================================================

class RSQGO_Chunk : Actor
{
	const KIND_CHUNK = 0;
	const KIND_CASING = 1;

	int gKind;                  // KIND_CHUNK (meat and limbs: the meat ring, the fly cap) or KIND_CASING
	property GibKind: gKind;
	Class<Actor> gibCls;        // a flier: the gib class it becomes (its parent class); null otherwise
	property GibOf: gibCls;

	bool parked;                // in the ring as a rest (statnum 26 unless it must stay awake: see RSQGO_GibRing.Park)
	bool inFly;                 // counted in RSQGO_GibRing.flying
	bool flyExempt;             // a limb spawned it (a kick's re-launch, a limb bursting): never refused by the fly cap.
	                            // Set by the spawn helpers below, at spawn time: the launcher is often gone (Stop in the
	                            // same tic) by the time PostBeginPlay runs, so `target` cannot tell.
	bool landed;                // a flier that has become its gib (always true for a class that is not a flier)
	bool restSeen;              // RSQGO_LongRest: the long rest has played once
	bool lowGfx;                // BD's LowGraphicsMode token, held as a field (BDCheckJanitor / BDCheckJanitor2)
	int liquidBits;             // BD's IsOverWater / IsOverSlime / ... tokens (BD_CheckIfOverLiquid), one bit each
	int parkSerial;             // which ring entry is this actor's current park
	Name deathMod;              // the damage type of the death in progress (RSQGO_DeathEntry)

	// BeginPlay runs inside Spawn, before A_SpawnProjectile's P_CheckMissileSpawn: a flier that spawns blocked explodes
	// there and becomes its gib (RSQGO_Become sets landed) before its first tick, so landed must be set here, not in
	// PostBeginPlay (which would undo that landing).
	override void BeginPlay()
	{
		Super.BeginPlay();
		landed = (gibCls == null);
		if (gibCls) RSQGO_ToFlier();
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		// the fly cap applies to a chunk really in flight: not to a flier that already landed inside Spawn
		if (gibCls && landed) return;
		let r = RSQGO_GibRing.Find(true);
		if (r && !r.Admit(self)) Destroy();
	}

	override void Tick()
	{
		if (bDestroyed) return;
		Super.Tick();
		if (bDestroyed || parked) return;
		bool rest = AtRest();
		bool park = tics == -1 && rest;
		// the ring is looked up only when something changes (a lookup every tic per chunk is the cost to avoid)
		if (!park && (gKind != KIND_CHUNK || inFly != rest)) return;
		let r = RSQGO_GibRing.Find(true);
		if (!r) return;
		// a rest: a -1 frame, not flying, not moving
		if (park) r.Park(self);
		// "flying" counts motion, not frames: a piece lying still in a timed state (a long rest's first pass) stops
		// counting against the fly cap, and one that moves again (a kick never parked) counts again. Never refused here.
		else if (gKind == KIND_CHUNK)
		{
			if (inFly && rest) r.Rest(self);
			else if (!inFly && !rest) r.Fly(self);
		}
	}

	bool AtRest()
	{
		if (bMissile) return false;
		if (vel.x * vel.x + vel.y * vel.y > 0.0001 || abs(vel.z) > 0.01) return false;
		return bNoGravity || pos.z <= floorz + 0.5;
	}

	void Unpark()
	{
		let r = RSQGO_GibRing.Find(true);
		if (r) r.Unpark(self);
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double dmgang)
	{
		if (parked) Unpark();
		if (gibCls && !landed)
		{
			// a flier is a subclass of its gib: in flight it takes damage as BD's flier did (its own factors, no pain)
			damage = int(damage * RSQGO_FlyFactor(mod));
			flags |= DMG_NO_FACTOR | DMG_NO_PAIN;
		}
		return Super.DamageMobj(inflictor, source, damage, mod, flags, dmgang);
	}

	// P_DoCrunch calls Grind every movement tic for a thing that does not fit; for a non-solid gib it changes nothing.
	// Un-park only when it did something (a crush state, a removal), so a crusher resting on a gib does not cycle it.
	override bool Grind(bool items)
	{
		if (!parked) return Super.Grind(items);
		State before = CurState;
		bool res = Super.Grind(items);
		if (!bDestroyed && (res || CurState != before)) Unpark();
		return res;
	}

	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		deathMod = MeansOfDeath;
		// a flier in flight must not find its gib's Death.<type>: the dispatcher picks its own F_Death.<type>
		if (gibCls && !landed) MeansOfDeath = 'RSQGO_Flight';
		Super.Die(source, inflictor, dmgflags, MeansOfDeath);
	}

	override void OnDestroy()
	{
		if (parked || inFly)
		{
			let r = RSQGO_GibRing.Find(false);
			if (r) r.Gone(self);
		}
		Super.OnDestroy();
	}

	// ---- generated overrides (chunk_cards.zs)
	virtual void RSQGO_ToGib() {}                           // the gib's flags (a landing, or a limb landing again)
	virtual double RSQGO_FlyFactor(Name dmgtype) { return 1.0; }    // a flier's own damage factor in flight
	virtual void RSQGO_ToFlier() {}                         // a flier at spawn: its own blood colour where it differs
	virtual Name RSQGO_FlyBlood(int type) { return 'None'; }       // a flier's own BloodType slot where it differs

	// A flier inherits its gib's BloodType (it needs it once landed); in flight BD's flier bled its own.
	override Class<Actor> GetBloodType(int type)
	{
		if (gibCls && !landed)
		{
			Name n = RSQGO_FlyBlood(type);
			if (n != 'None')
			{
				Class<Actor> c = n;
				return c ? GetReplacement(c) : null;
			}
		}
		return Super.GetBloodType(type);
	}

	// ================================================================ what the generated states call
	// The flier's (or the limb's own) landing: "spawn <gib> here, then stop" in BD. The same actor takes the gib's
	// fields and flags and enters the gib's Spawn. mode: 0 its first state, 1 the state after it (BD never runs a first
	// spawn state's action without NoDelay), 2 its first state without the action. keepScale / keepTrans: BD's
	// SXF_TRANSFERSCALE / transfer_translation.
	action state RSQGO_Become(int mode, bool keepScale, bool keepTrans)
	{
		Class<Actor> g = invoker.gibCls;
		if (!g) g = (Class<Actor>)(invoker.GetClass());
		let d = GetDefaultByType(g);
		A_SetSize(d.radius, d.height, false);
		invoker.health = d.health;
		invoker.PainChance = d.PainChance;
		invoker.Mass = d.Mass;
		invoker.Gravity = d.Gravity;
		invoker.Speed = d.Speed;
		if (!keepScale) invoker.Scale = d.Scale;
		if (!keepTrans) invoker.Translation = d.Translation;
		A_SetRenderStyle(d.Alpha, d.GetRenderStyle());
		invoker.bouncefactor = d.bouncefactor;
		invoker.wallbouncefactor = d.wallbouncefactor;
		invoker.bouncecount = d.bouncecount;
		invoker.DamageType = d.DamageType;
		invoker.Species = d.Species;
		invoker.SeeSound = d.SeeSound;
		invoker.DeathSound = d.DeathSound;
		invoker.PainSound = d.PainSound;
		invoker.ActiveSound = d.ActiveSound;
		invoker.BounceSound = d.BounceSound;
		invoker.DamageFactor = d.DamageFactor;
		invoker.projectilepassheight = d.projectilepassheight;
		invoker.vel = (0, 0, 0);
		invoker.CopyBloodColor(d);          // a flier with its own blood colour in flight gets the gib's back
		invoker.RSQGO_ToGib();
		invoker.landed = true;
		invoker.restSeen = false;
		State st = d.FindState("Spawn");      // the gib's own Spawn (the flier's shadows it in this class)
		if (mode == 1 && st) return st.NextState;
		if (mode == 2 && st)
		{
			invoker.SetState(st, true);
			return null;
		}
		return st;
	}

	// A flier's Death. The engine enters it when the flier explodes, and when a landed flier dies with a damage type its
	// gib has no Death.<type> for; a gib's own states reach it with a jump to "Death" (an unqualified label resolves at
	// run time in the actor's class, and the flier's Death shadows the gib's). In flight: its own F_Death.<type>, else
	// F_Death. Landed: the gib's plain Death, which is what BD's real gib would run in both cases (the engine already
	// found no Death.<type>). Never the gib's Death.<type> here: ZombiemanHead's Death.Trample ends in
	// A_Jump(255, "Death"), and returning Death.Trample again looped about 256 boot gives instead of BD's one.
	action state RSQGO_DeathEntry()
	{
		if (!invoker.landed || !invoker.gibCls)
		{
			State s = null;
			if (invoker.deathMod != 'None' && invoker.deathMod != 'RSQGO_Flight')
				s = FindStateByString("F_Death." .. invoker.deathMod, true);
			if (!s) s = FindStateByString("F_Death", true);
			return s;
		}
		let d = GetDefaultByType(invoker.gibCls);
		return d.FindState("Death");
	}

	// A 200+ tic state inside a loop (LimbBase's 1900-tic spot spawner, a casing's rest): it plays once; the next
	// time round it holds (-1) without running its action again, and the rest parks it. Q3: residue never times out.
	bool RSQGO_LongRest()
	{
		if (restSeen)
		{
			tics = -1;
			return true;
		}
		restSeen = true;
		return false;
	}

	// A 1000+ tic state that carries an action (LimbBase's "TNT1 A 1900 A_SpawnItem(Brutal_BloodSpot) Loop"): the action
	// runs when BD first runs it (not on a natural spawn or a mode 2 landing: at tic 1900; at once when a goto enters
	// it), then the state holds (-1) and the rest parks. BD repeats it every 1900 tics; the repeats are dropped (Q3).
	void RSQGO_Hold()
	{
		tics = -1;
	}

	// ---- spawns. A phase 1 liquid class with a drop card (a trail drop, a spray) becomes particles through phase 1's
	// emitter, exactly as phase 1's KidAt places it; anything else is spawned by name, so the takeover still applies.
	action void RSQGO_Missile(Name cls, double h, double ofs, double ang, int flg, double pit, bool badpitch)
	{
		if (badpitch && ofs == 0 && (flg & 3) == CMF_AIMDIRECTION)
		{
			let m = RSQGO_Manager.Get();
			int c = RSQGO_Gibs.DropCard(m, cls);
			if (c >= 0)
			{
				// A_CustomMissile's pitch is up-positive (CMF_BADPITCH); the speed is the spawned class's
				double spd = m.data.cSpeed[c];
				double a = invoker.angle + ang;
				// the engine: missilespeed = fabs(Pitch.Cos() * Speed), then VelFromAngle along the angle
				double cp = abs(cos(pit));
				Vector3 v = (cos(a) * cp * spd, sin(a) * cp * spd, sin(pit) * spd);
				// under water the drop takes phase 1's water branch (BD's trail: waterlevel > 1 -> Splash, Underblood2)
				m.Process(c, invoker, invoker.pos + (0, 0, h), v, a, 0, 0, invoker.waterlevel >= 1);
				return;
			}
		}
		Class<Actor> ci = cls;
		if (!ci) return;
		let mo = RSQGO_Chunk(A_SpawnProjectile(ci, h, ofs, ang, badpitch ? (flg | CMF_BADPITCH) : flg, pit));
		if (mo && invoker is 'RSQGO_Limb') mo.flyExempt = true;
	}

	action void RSQGO_Item(Name cls, double dist, double zh, bool transfer)
	{
		let m = RSQGO_Manager.Get();
		int c = RSQGO_Gibs.DropCard(m, cls);
		if (c >= 0)
		{
			double a = invoker.angle;
			// A_SpawnItem's z: -Floorclip + GetBobOffset() + zheight (attacks.zs)
			double z = zh - invoker.Floorclip + invoker.GetBobOffset();
			m.Process(c, invoker, invoker.pos + (cos(a) * dist, sin(a) * dist, z), (0, 0, 0), a, 0, 0, invoker.waterlevel >= 1);
			return;
		}
		Class<Actor> ci = cls;
		if (!ci) return;
		bool ok;
		Actor mo;
		[ok, mo] = A_SpawnItem(ci, dist, zh, false, transfer);
		let ch = RSQGO_Chunk(mo);
		if (ch && invoker is 'RSQGO_Limb') ch.flyExempt = true;
	}

	action void RSQGO_ItemEx(Name cls, double ox, double oy, double oz, double vx, double vy, double vz, double ang, int flg, int chance)
	{
		let m = RSQGO_Manager.Get();
		int c = RSQGO_Gibs.DropCard(m, cls);
		if (c >= 0)
		{
			if (chance > 0 && random[RSQGO_Play](0, 255) < chance) return;
			// A_SpawnItemEx's offsets and velocity turn with the final angle (p_actionfunctions.cpp)
			double da = (flg & SXF_ABSOLUTEANGLE) ? ang : invoker.angle + ang;
			double sn = sin(da);
			double co = cos(da);
			// A_SpawnItemEx's z: pos.Z - Floorclip + GetBobOffset() + zofs, relative or absolute (attacks.zs)
			double z = oz - invoker.Floorclip + invoker.GetBobOffset();
			Vector3 p = invoker.pos + (ox * co + oy * sn, ox * sn - oy * co, z);
			if (flg & SXF_ABSOLUTEPOSITION) p = invoker.pos + (ox, oy, z);
			Vector3 v = (vx * co + vy * sn, vx * sn - vy * co, vz);
			if (flg & SXF_ABSOLUTEVELOCITY) v = (vx, vy, vz);
			m.Process(c, invoker, p, v, da, 0, 0, invoker.waterlevel >= 1);
			return;
		}
		Class<Actor> ci = cls;
		if (!ci) return;
		bool ok;
		Actor mo;
		[ok, mo] = A_SpawnItemEx(ci, ox, oy, oz, vx, vy, vz, ang, flg, chance);
		let ch = RSQGO_Chunk(mo);
		if (ch && invoker is 'RSQGO_Limb') ch.flyExempt = true;
	}

	// ---- inventory by name (a BD class: never a class constant, ZScript compiles before DECORATE)
	action void RSQGO_GiveTarget(Name cls, int amount)
	{
		Class<Inventory> ci = cls;
		if (ci) A_GiveToTarget(ci, amount);
	}

	action void RSQGO_GiveSelf(Name cls, int amount)
	{
		Class<Inventory> ci = cls;
		if (ci) A_GiveInventory(ci, amount);
	}

	action state RSQGO_JumpIfInv(Name item, int amount, statelabel lbl)
	{
		Class<Inventory> ci = item;
		if (!ci) return null;
		let it = invoker.FindInventory(ci);
		if (!it) return null;
		// A_JumpIfInventory: amount 0 means "has the maximum"
		if (amount <= 0 ? it.Amount >= it.MaxAmount : it.Amount >= amount) return ResolveState(lbl);
		return null;
	}

	// ---- BD's ACS checks, natively
	// BD_CheckIfOverLiquid (SPLASH.acs): the floor under the chunk against BD's list; one token, as the script gives.
	action void RSQGO_LiquidCheck()
	{
		let m = RSQGO_Manager.Get();
		if (m) invoker.liquidBits |= RSQGO_Gibs.Of(m).LiquidAt(invoker.floorpic);
	}

	action state RSQGO_JumpIfLiquid(int bit, statelabel lbl)
	{
		if (invoker.liquidBits & (1 << bit)) return ResolveState(lbl);
		return null;
	}

	// BDCHeckJanitor: LowGraphicsMode when zdoombrutaljanitor is 1 or in deathmatch. (Its bd_lowgraphicsmode test reads
	// BDCVarInfo[PlayerNumber()] with a chunk as activator, index -1, which is never 1: Phase 0's finding.)
	action void RSQGO_Janitor()
	{
		let cv = CVar.FindCVar('zdoombrutaljanitor');
		if ((cv && cv.GetInt() == 1) || deathmatch) invoker.lowGfx = true;
	}

	// BDCHeckJanitor2: LowGraphicsMode unless bd_infinitecasings is on (a casing rests 210 tics, then goes).
	action void RSQGO_Janitor2()
	{
		let cv = CVar.FindCVar('bd_infinitecasings');
		if (!cv || cv.GetInt() == 0) invoker.lowGfx = true;
	}

	// BDCHeckJanitor3: limbs that do not bounce with explosives when the janitor is on (BD: SetActorState "NoColision"
	// one tic later; here at once).
	action state RSQGO_Janitor3(statelabel lbl)
	{
		let cv = CVar.FindCVar('zdoombrutaljanitor');
		if (cv && cv.GetInt() == 1) return ResolveState(lbl);
		return null;
	}

	action state RSQGO_JumpIfLowGfx(int amount, statelabel lbl)
	{
		if (invoker.lowGfx) return ResolveState(lbl);      // a one-count token: amount 0 and 1 read the same
		return null;
	}
}

// A landed limb, head or half, or a gib a flier becomes (shootable). The behaviour is all in RSQGO_Chunk; the class
// exists so the cap's re-launch exemption (a kicked limb's new flier) can tell them apart.
class RSQGO_Limb : RSQGO_Chunk
{
}

// EmptyBrass and family: they fly, rest (210 tics, or forever with bd_infinitecasings), park; a ring of their own, no
// fly cap (they are not gore).
class RSQGO_Casing : RSQGO_Chunk
{
	Default
	{
		RSQGO_Chunk.GibKind 1;
	}
}

// ============================================================================
// The ring and the counters: one per level, a Thinker in statnum 25 (never ticked, saved with the level). 25 is shared
// with phase 2's RSQGO_Residue holder (residue.zs STAT_RESIDUE); both find theirs with a class-filtered iterator, so
// finding one walks two thinkers, not the parked actors of 26.
// ============================================================================
class RSQGO_GibRing : Thinker
{
	const STAT_HOLDER = 25;

	int flying;                 // chunks (not casings) alive and not parked
	int serial;
	int parkedMeat;
	int parkedCas;
	int headMeat;
	int headCas;
	int statDropped;            // spawns refused by the fly cap
	int statRecycled;           // parked pieces recycled by the ring
	Array<RSQGO_Chunk> meat;
	Array<int> meatS;
	Array<RSQGO_Chunk> cas;
	Array<int> casS;

	static RSQGO_GibRing Find(bool create)
	{
		let m = RSQGO_Manager.Get();
		if (!m) return null;
		return RSQGO_Gibs.Of(m).Ring(create);
	}

	// The owner's budget column (design section 6, CVARINFO): All / Some / None by rsqgo_amount, PC / Quest by
	// rsqgo_platform; Quest at Some is Quest x Some / All (CVARINFO's note).
	static int Budget(int all, int some, int quest)
	{
		int amt = rsqgo_amount;
		bool q = rsqgo_platform == 1;
		if (amt >= 2) return q ? quest : all;
		if (amt == 1) return q ? quest * some / max(1, all) : some;
		return 0;
	}

	int FlyCap() { return Budget(rsqgo_fly_all, rsqgo_fly_some, rsqgo_fly_quest); }
	int MeatCap() { return Budget(rsqgo_meat_all, rsqgo_meat_some, rsqgo_meat_quest); }
	int CasingCap() { return rsqgo_platform == 1 ? rsqgo_meat_quest : rsqgo_meat_all; }

	// A new chunk: refused past the fly cap, unless a limb launched it (a kick's re-launch, a limb bursting)
	bool Admit(RSQGO_Chunk a)
	{
		if (a.gKind == RSQGO_Chunk.KIND_CASING) return true;
		int cap = FlyCap();
		bool exempt = a.flyExempt;
		if (!exempt && (cap <= 0 || flying >= cap))
		{
			statDropped++;
			return false;
		}
		flying++;
		a.inFly = true;
		return true;
	}

	// A piece lying still in a timed state: no longer flying (RSQGO_Chunk.Tick); Fly() counts it again when it moves.
	void Rest(RSQGO_Chunk a)
	{
		if (a.inFly)
		{
			flying--;
			a.inFly = false;
		}
	}

	void Fly(RSQGO_Chunk a)
	{
		if (!a.inFly && a.gKind != RSQGO_Chunk.KIND_CASING)
		{
			flying++;
			a.inFly = true;
		}
	}

	void Park(RSQGO_Chunk a)
	{
		if (a.inFly)
		{
			flying--;
			a.inFly = false;
		}
		a.parked = true;
		// A gravity piece without MOVEWITHSECTOR must keep ticking: a floor that lowers 9+ units a tic (or instantly)
		// leaves it to gravity in Tick (PIT_FloorDrop), and BD's gib falls. It still joins the ring (budget, recycling);
		// its Tick returns at once while parked. Ceiling-stuck pieces are NOGRAVITY and sleep.
		if (a.bNoGravity || a.bMoveWithSector) a.ChangeStatNum(RSQGO_Manager.STAT_PARKED_ACTOR);
		serial++;
		a.parkSerial = serial;
		if (a.gKind == RSQGO_Chunk.KIND_CASING)
		{
			cas.Push(a);
			casS.Push(serial);
			parkedCas++;
			TrimCasings();
		}
		else
		{
			meat.Push(a);
			meatS.Push(serial);
			parkedMeat++;
			TrimMeat();
		}
	}

	void Unpark(RSQGO_Chunk a)
	{
		a.parked = false;
		a.ChangeStatNum(STAT_DEFAULT);
		if (a.gKind == RSQGO_Chunk.KIND_CASING)
		{
			parkedCas--;
			return;
		}
		parkedMeat--;
		flying++;
		a.inFly = true;
	}

	// an actor going away (recycled, removed by BD's own states, or the level ending)
	void Gone(RSQGO_Chunk a)
	{
		if (a.parked)
		{
			if (a.gKind == RSQGO_Chunk.KIND_CASING) parkedCas--;
			else parkedMeat--;
			a.parked = false;
		}
		if (a.inFly)
		{
			flying--;
			a.inFly = false;
		}
	}

	// oldest first; an entry whose actor is gone, flying again or parked again later (a newer entry) is skipped
	void TrimMeat()
	{
		int cap = MeatCap();
		while (parkedMeat > cap && headMeat < meat.Size())
		{
			let a = meat[headMeat];
			int s = meatS[headMeat];
			headMeat++;
			if (a && a.parked && a.parkSerial == s)
			{
				statRecycled++;
				a.Destroy();
			}
		}
		if (headMeat > 512 && headMeat * 2 > meat.Size())
		{
			meat.Delete(0, headMeat);
			meatS.Delete(0, headMeat);
			headMeat = 0;
		}
		// un-park / re-park cycles (a hit, a Pain back to the rest) leave stale entries behind the head: keep the arrays
		// O(cap) by rebuilding them from the live entries, oldest first (the recycle order is unchanged)
		if (meat.Size() - headMeat > 2 * max(parkedMeat, cap) + 64)
		{
			Array<RSQGO_Chunk> na;
			Array<int> ns;
			for (int i = headMeat; i < meat.Size(); i++)
			{
				let a = meat[i];
				if (a && a.parked && a.parkSerial == meatS[i])
				{
					na.Push(a);
					ns.Push(meatS[i]);
				}
			}
			meat.Move(na);
			meatS.Move(ns);
			headMeat = 0;
		}
	}

	void TrimCasings()
	{
		int cap = CasingCap();
		while (parkedCas > cap && headCas < cas.Size())
		{
			let a = cas[headCas];
			int s = casS[headCas];
			headCas++;
			if (a && a.parked && a.parkSerial == s)
			{
				statRecycled++;
				a.Destroy();
			}
		}
		if (headCas > 512 && headCas * 2 > cas.Size())
		{
			cas.Delete(0, headCas);
			casS.Delete(0, headCas);
			headCas = 0;
		}
		// un-park / re-park cycles (a hit, a Pain back to the rest) leave stale entries behind the head: keep the arrays
		// O(cap) by rebuilding them from the live entries, oldest first (the recycle order is unchanged)
		if (cas.Size() - headCas > 2 * max(parkedCas, cap) + 64)
		{
			Array<RSQGO_Chunk> na;
			Array<int> ns;
			for (int i = headCas; i < cas.Size(); i++)
			{
				let a = cas[i];
				if (a && a.parked && a.parkSerial == casS[i])
				{
					na.Push(a);
					ns.Push(casS[i]);
				}
			}
			cas.Move(na);
			casS.Move(ns);
			headCas = 0;
		}
	}
}

// ============================================================================
// The phase 3 tables, held by the manager (a transient field: rebuilt after a load). The generated half
// (chunk_cards.zs) fills them: BuildTable (BD class -> our class) and BuildLiquids (BD's SPLASH.acs floors).
// ============================================================================
class RSQGO_Gibs play
{
	bool built;
	Map<Name, int> byName;
	Array< Class<Actor> > ours;
	Array<int> lqBit;
	Array<TextureID> lqTex;
	RSQGO_GibRing ringRef;

	static RSQGO_Gibs Of(RSQGO_Manager m)
	{
		if (!m.gibs) m.gibs = new('RSQGO_Gibs');
		return m.gibs;
	}

	// The takeover (RSQGO_Manager.CheckReplacement, after phase 1's own map): one map read per spawn. Our class for a
	// BD class, or null (the class stays BD's). A class name, not the event: a struct is not passed around.
	static Class<Actor> Lookup(RSQGO_Manager m, Name bd)
	{
		let g = Of(m);
		if (!g.built) g.Build();
		int i;
		bool has;
		[i, has] = g.byName.CheckValue(bd);
		if (!has) return null;
		return g.ours[i];
	}

	void Build()
	{
		built = true;
		BuildTable();
		BuildLiquids();
	}

	private void Add(Name bd, Class<Actor> cls)
	{
		if (!cls) return;
		byName.Insert(bd, ours.Size());
		ours.Push(cls);
	}

	private void AddLiquid(int bit, String flats)
	{
		Array<String> fl;
		flats.Split(fl, " ", TOK_SKIPEMPTY);
		for (int i = 0; i < fl.Size(); i++)
		{
			lqBit.Push(bit);
			lqTex.Push(TexMan.CheckForTexture(fl[i], TexMan.Type_Flat));
		}
	}

	int LiquidAt(TextureID t)
	{
		if (!built) Build();
		for (int i = 0; i < lqTex.Size(); i++) if (lqTex[i] == t) return 1 << lqBit[i];
		return 0;
	}

	RSQGO_GibRing Ring(bool create)
	{
		if (ringRef)
		{
			if (ringRef.bDestroyed) return null;        // the level is ending
			return ringRef;
		}
		let it = ThinkerIterator.Create('RSQGO_GibRing', RSQGO_GibRing.STAT_HOLDER);
		ringRef = RSQGO_GibRing(it.Next());
		if (!ringRef && create)
		{
			ringRef = new('RSQGO_GibRing');
			ringRef.ChangeStatNum(RSQGO_GibRing.STAT_HOLDER);
		}
		return ringRef;
	}

	// Phase 1's drop card for a BD class, or -1 (no card, not a drop, master switch off, BD absent)
	static int DropCard(RSQGO_Manager m, Name cls)
	{
		if (!m || !m.IsOn() || !m.Ready()) return -1;
		int c;
		bool has;
		[c, has] = m.data.byName.CheckValue(cls);
		if (!has || m.data.cKind[c] != RSQGO_Data.K_DROP) return -1;
		return c;
	}

	// one line for rsqgo_debug (RSQGO_Manager.DebugLine)
	static String DebugText(RSQGO_Manager m)
	{
		if (!m.gibs || !m.gibs.ringRef) return "";
		let r = m.gibs.ringRef;
		return String.Format("\cfRSQ Gore\c- chunks: %d flying (cap %d), %d kept (cap %d), %d casings kept (cap %d) | %d refused, %d recycled",
			r.flying, r.FlyCap(), r.parkedMeat, r.MeatCap(), r.parkedCas, r.CasingCap(), r.statDropped, r.statRecycled);
	}
}
