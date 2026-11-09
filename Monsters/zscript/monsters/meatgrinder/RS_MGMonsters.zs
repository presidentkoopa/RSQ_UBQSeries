// ============================================================================
// RS_MGMonsters.zs -- the MEATGRINDER monster set in RSQ Monsters.
//
// Sergeant Mark IV's Meatgrinder monsters (their states, sprites, gory
// dismember deaths and sounds), as the owner recoloured and re-tiered them,
// carried over from his old HF tree onto RS_MonsterMaster. Only the monsters
// and what they need to run came across; the HF keywords (MonIdentity) and the HF
// colour dial were not brought (owner, 2026-11-09: no keywords). HF's retier flash is kept (RS_Retier.zs, for all sets).
//
// RENAMES (none of these may clash with Brutal Doom or the rest of RSQ
// Monsters): classes HF_MG* -> RS_MG*, base HF_MG_Monsters -> RS_MGMonster;
// every gore / effect actor gets an MG_ prefix (decorate/meatgrinder/);
// every sprite prefix this set ships is renamed MGxx (sprites/meatgrinder/);
// the sounds it defines are mg/* (SNDINFO, sounds/meatgrinder/).
//
// THE CORPSE-FALLING FIX that HF_MG_Monsters.Tick carried is NOT repeated
// here: RS_MonsterMaster.Tick already does exactly the same nudge for every
// monster, and a second copy would apply it twice.
//
// TIERS. RSQ Monsters' CH families are one class per colour and change tier by
// swapping class (RS_Retier.zs). The MG set is one class per creature and keeps
// HF's per-colour buff curve, so it fills RS_MonsterMaster's own in-place tier
// seam (TierData / ApplyTier / RS_ApplyTint / RS_ShowBody) instead. Tier
// numbers are the RSQ ladder (RS_MonsterMaster.RS_TierForColour), matched to
// HF's colours by name:
//   1 Common (HF Neutral)  2 Green  3 Blue  4 Purple  5 Yellow  6 Red
//   7 FireBlu  8 Gray  9 Abyss  10 Black  11 White  12 Cyan  13 Brown
// A map spawn is tier 1 (Common). `netevent rs_retier N` on an aimed MG
// monster goes through RS_Retier.Request: HF's tier-change flash, shared with
// the CH families (a random 5..25-tic wait blinking the flash colour every 3
// tics -- white; black when the target is White -- then the new tier and tint).
//
// What a tier changes: health (hpMul, or MGHP absolute when > 0), speed
// (spdMul), PainChance, OUTGOING DAMAGE (dmgMul, as the engine's DamageMultiply,
// also kept in TierDamageMul), AGGRESSION (HF's `behave` column: 2 = +MISSILEMORE,
// 3 = +MISSILEEVENMORE; owner 2026-11-09 -- HF stored it but nothing applied it),
// and the tint (TRNSLATE rs_mg_<family>_tNN, CH's own recipes as HF reused them).
// ============================================================================

class RS_MGMonster : RS_MonsterMaster abstract
{
	// The vanilla class this creature stands in for, read by RS_RosterHandler
	// when the Monster Set is MeatGrinder. Declared in each monster's Default.
	meta Name MG_Family;
	Property Family : MG_Family;

	// per-monster tint family ("zombie","imp","demon",...) -> rs_mg_<fam>_tNN
	string tintFam;

	Default
	{
		RS_MGMonster.Family "none";
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		Tier = 1;   // HF Neutral = RSQ ladder 1, Common
		mgSampleOffset = random(0, 11);
	}

	// ---- Retier. RS_MonsterMaster.SetTier (its gold-flash tell) is not
	// virtual, so the MG set enters here. A live retier goes through
	// RS_Retier.Request: HF's tier-change flash (HF_Monster.zs SetTier :302 /
	// Tick :632-648), shared with the CH families -- one flash for both sets.
	void MG_SetTier(int t, bool instant = false)
	{
		RS_Retier.Request(self, t, instant);
	}

	// The commit at the end of the flash (or an instant tier): stats,
	// aggression, damage, and the new tier's own tint.
	void MG_ApplyTierNow(int t, bool instant = false)
	{
		if (TierLocked() || health <= 0) return;
		Tier = clamp(t, 1, MaxTier());
		ApplyTier(instant);
	}

	override int MaxTier() { return 13; }

	// concrete monsters may override to give real per-colour HP (absolute).
	// 0 = derive from the multiplier. (HF: no monster overrode it.)
	virtual int MGHP(int t) { return 0; }

	// HF_MG_Monsters.TierData, verbatim numbers, keyed by RSQ ladder tier.
	override bool TierData(int t, out RS_MonsterTierRow r)
	{
		r = new("RS_MonsterTierRow");
		r.hpMul = 1.0; r.hp = MGHP(t); r.spdMul = 1.0; r.painChance = 200; r.dmgMul = 1.0;
		switch (t)
		{
			case 2:  r.hpMul=1.6;  r.spdMul=1.1; r.painChance=180; r.dmgMul=1.2; break;   // Green
			case 3:  r.hpMul=2.0;  r.spdMul=1.2; r.painChance=160; r.dmgMul=1.3; break;   // Blue
			case 12: r.hpMul=1.8;  r.spdMul=1.6; r.painChance=120; r.dmgMul=1.3; break;   // Cyan
			case 4:  r.hpMul=3.5;  r.spdMul=1.4; r.painChance=100; r.dmgMul=1.6; break;   // Purple
			case 5:  r.hpMul=3.0;  r.spdMul=1.7; r.painChance=90;  r.dmgMul=1.8; break;   // Yellow
			case 9:  r.hpMul=4.0;  r.spdMul=1.3; r.painChance=100; r.dmgMul=1.5; break;   // Abyss
			case 7:  r.hpMul=2.5;  r.spdMul=1.5; r.painChance=110; r.dmgMul=1.7; break;   // FireBlu
			case 13: r.hpMul=3.0;  r.spdMul=1.1; r.painChance=140; r.dmgMul=1.4; break;   // Brown
			case 8:  r.hpMul=3.8;  r.spdMul=1.0; r.painChance=90;  r.dmgMul=1.5; break;   // Gray
			case 6:  r.hpMul=5.0;  r.spdMul=1.5; r.painChance=70;  r.dmgMul=2.0; break;   // Red
			case 10: r.hpMul=12.0; r.spdMul=1.6; r.painChance=40;  r.dmgMul=2.5; break;   // Black
			case 11: r.hpMul=20.0; r.spdMul=1.8; r.painChance=24;  r.dmgMul=3.0; break;   // White
			default: break;   // 0/1: HF Neutral, the monster's own Default stats
		}
		return true;
	}

	// HF's per-colour `behave` column (HF_MG_Monsters.TierData r.behave, the
	// same numbers as HF_Monster.zs:110-122), verbatim, by RSQ ladder tier.
	// 0..1 = no change, 2 = +MISSILEMORE, 3 = +MISSILEEVENMORE (owner, 2026-11-09).
	virtual int MGBehave(int t)
	{
		switch (t)
		{
			case 2:  return 1;   // Green
			case 3:  return 1;   // Blue
			case 12: return 2;   // Cyan
			case 4:  return 2;   // Purple
			case 5:  return 3;   // Yellow
			case 9:  return 2;   // Abyss
			case 7:  return 2;   // FireBlu
			case 13: return 1;   // Brown
			case 8:  return 2;   // Gray
			case 6:  return 3;   // Red
			case 10: return 3;   // Black
			case 11: return 3;   // White
		}
		return 0;                // Neutral / Common
	}

	// Commits a tier: stats from the Defaults (never compounding), then the tint.
	override void ApplyTier(bool instant)
	{
		RS_MonsterTierRow r;
		if (!TierData(Tier, r) || !r) return;

		let def = GetDefaultByType(GetClass());
		int newMax = r.hp > 0 ? r.hp : max(1, int(def.Health * r.hpMul));
		int oldMax = TierMaxHealth > 0 ? TierMaxHealth : def.Health;
		// Full health or the fraction already lost: RSQ Monsters > "On tier
		// change" (RS_Retier.FullHealth; default HF's rule, full on an instant
		// tier, the fraction on a live one).
		if (health > 0)
		{
			if (RS_Retier.FullHealth(instant) || oldMax <= 0)
				health = newMax;
			else
				health = clamp(int(newMax * double(health) / oldMax), 1, newMax);
		}
		TierMaxHealth = newMax;
		Speed         = def.Speed * r.spdMul;
		PainChance    = r.painChance;
		TierDamageMul  = r.dmgMul;
		// Outgoing damage. DamageMultiply is the stock Actor field the engine
		// applies to every hit whose SOURCE is this monster: its hitscans, its
		// projectiles (source = shooter) and its melee. (Owner 2026-11-08: "the
		// whole point of tiering MG was to give the challenge". HF filled dmgMul
		// but never applied it; this is the new line that does.)
		DamageMultiply = r.dmgMul;

		// Aggression: both flags stated every time, so retiering down clears
		// what a tier added. "No change" means the class's own Default (three
		// MG classes ship +MISSILEMORE: lost soul, mastermind, cyberdemon), so
		// tier 0/1 leaves the creature as Sergeant Mark IV made it.
		// (On 4.13+ the two flags are script-side views of MissileChanceMult;
		// it is reset to the class Default first, then the tier's flag is set.)
		int behave = MGBehave(Tier);
		MissileChanceMult = def.MissileChanceMult;
		if (behave == 2) bMISSILEMORE = true;
		if (behave >= 3) bMISSILEEVENMORE = true;
		RS_ApplyTint();
	}

	override void RS_ApplyTint() { MG_Tint(Tier); }
	override void RS_ShowBody(int t) { MG_Tint(t); }

	// =================================================================
	// FROM HF_Monster (owner 2026-11-09, "TAKE THAT CODE"): what the MG
	// monsters inherited and used in HF. Ported with HF's logic; names MG_/mg,
	// cvars rsq_mg_*. RS_MGReactions.zs holds the event handler, the context
	// struct and the FX actors.
	// =================================================================

	// ---- SENSORS (HF_Monster fields + DamageMobj): how the player last hit me.
	int  mgLastHitBy;        // MGHIT_* (RS_MGReactions.zs)
	bool mgLastWasHeadshot;
	bool mgHeadExplode;      // next head-pop bursts (set by the death router)
	string mgPendingDeathSeq; // reactive-death label, jumped in Tick

	double MG_HeadZoneFrac() { CVar c = CVar.FindCVar("rsq_mg_head_zone"); return c ? c.GetFloat() : 0.22; }
	virtual double MG_HeadLo() { return (bNoGravity || bFloat) ? 0.0 : 1.0 - MG_HeadZoneFrac(); }
	virtual double MG_HeadHi() { return 2.0; }

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		bool fromPlayer = (source && source.player) ||
		                  (inflictor && inflictor.target && inflictor.target.player);
		if (fromPlayer)
		{
			// HF: the inflictor (puff / missile) sits at the impact point; compare its Z
			// with the head band. Melee carries no inflictor, so it is never a headshot.
			mgLastWasHeadshot = (inflictor &&
			                     inflictor.pos.z >= pos.z + height * MG_HeadLo() &&
			                     inflictor.pos.z <= pos.z + height * MG_HeadHi());
			if (inflictor && inflictor.bMissile)
				mgLastHitBy = MGHIT_PROJECTILE;
			else if (source && source.player && source.Distance3D(self) <= (radius + 80))
				mgLastHitBy = MGHIT_MELEE;
			else
				mgLastHitBy = MGHIT_HITSCAN;
		}
		return Super.DamageMobj(inflictor, source, damage, mod, flags, angle);
	}

	// ---- REACTIVE DEATH ROUTER (HF_Monster.AssignDeathReaction), called by
	// RS_MGReactionHandler.WorldThingDied. HF also read the firing HF_Weapon's
	// keywords (dmg:explosive/energy/fire/ice/shock/melt, class:chainsaw/fist,
	// class:revolver); no HF_Weapon exists in this load, so those inputs are
	// absent and the damage-type half of each test is what decides.
	void MG_AssignDeathReaction(RS_MGEventContext ctx)
	{
		CVar rd = CVar.FindCVar("rsq_mg_reactdeath");
		if (rd && !rd.GetBool()) return;

		bool explosive = (ctx.dmgType == 'Explosive');
		bool fire      = (ctx.dmgType == 'Fire');
		bool frost     = (ctx.dmgType == 'Ice');
		bool shock     = (ctx.dmgType == 'Lightning') || (ctx.dmgType == 'Electric');
		bool meltdmg   = (ctx.dmgType == 'Melt') || (ctx.dmgType == 'Acid');
		bool tieredOK  = (Tier <= 1 || MG_DismemberTieredOn());

		if (shock)   { mgPendingDeathSeq = "DeathSeq_Shock";    return; }
		if (meltdmg) { mgPendingDeathSeq = "DeathSeq_Melt";     return; }
		if (fire)    { mgPendingDeathSeq = "DeathSeq_Burn";     return; }
		if (frost)   { mgPendingDeathSeq = "DeathSeq_Freeze";   return; }

		if (ctx.overkill || explosive) { mgPendingDeathSeq = "DeathSeq_Gib"; return; }

		if (ctx.isHeadshot && tieredOK)
		{
			CVar eh = CVar.FindCVar("rsq_mg_explodeheads");
			bool ehOn = (!eh || eh.GetBool());
			mgHeadExplode = ehOn && (ctx.damage >= 60);
			mgPendingDeathSeq = "DeathSeq_Head";
			return;
		}
		// else: the monster's own Meatgrinder death.
	}

	static bool MG_DismemberTieredOn()
	{
		CVar c = CVar.FindCVar("rsq_mg_dismember_tiered");
		return c ? c.GetBool() : true;
	}

	// ---- HEAD-POP (HF_Monster.HF_HeadPop). MG monsters never overrode HF's
	// HeadVariant() (-1 = no fitting head), so in HF they never threw a severed
	// head: only the geyser / burst. That branch is therefore not carried.
	void MG_HeadPop()
	{
		if (mgHeadExplode)
		{
			mgHeadExplode = false;
			vector3 ep = pos; ep.z += height * 0.9;
			int g = MG_GoreBudget.PartsFor(8);
			for (int i = 0; i < g; i++)
			{
				Actor j = Spawn("MG_HeadGibSpurt", ep, ALLOW_REPLACE);
				if (j) { j.vel = (frandom(-1.2, 1.2), frandom(-1.2, 1.2), frandom(9.0, 15.0)); j.Translation = Translation; }
			}
			int eg = MG_GoreBudget.PartsFor(5);
			for (int i = 0; i < eg; i++)
			{
				Actor j = Spawn("MG_HeadGibSpurt", ep, ALLOW_REPLACE);
				if (j) { double a = frandom(0, 360); j.vel = (cos(a) * frandom(2.5, 5.5), sin(a) * frandom(2.5, 5.5), frandom(3.0, 7.0)); j.Translation = Translation; }
				else SpawnBlood(ep, random(0, 359), 24);
			}
			int sp = MG_GoreBudget.PartsFor(4);
			for (int i = 0; i < sp; i++)
				Spawn("MG_BulletSpark", ep, ALLOW_REPLACE);
			for (int i = 0; i < 5; i++)
				SpawnBlood(ep, random(0, 359), 18);
			return;
		}

		// HF rolls the outcome; with no head to throw, "vaporized" (20%) is the
		// heavier geyser and the other 80% the normal one.
		int spurts = (random(0, 99) < 80) ? 6 : 11;
		spurts = MG_GoreBudget.PartsFor(spurts);
		vector3 hp = pos; hp.z += height * 0.9;
		for (int i = 0; i < spurts; i++)
		{
			Actor j = Spawn("MG_HeadGibSpurt", hp, ALLOW_REPLACE);
			if (j) j.vel = (frandom(-2.5, 2.5), frandom(-2.5, 2.5), frandom(5.0, 9.0));
			else   SpawnBlood(hp, random(0, 359), 20);
		}
		for (int i = 0; i < 4; i++)
			SpawnBlood(hp, random(0, 359), 14);
	}

	// ---- ABYSS DEATH-SPLIT (HF_Monster.Die / DeathSplit / AbyssSplitRoster).
	// HF: an Abyss-tier monster splits into two "HF_LostSoul" at Green. The
	// in-place-tiered lost soul here is RS_MGLostSoul, so that is the roster.
	virtual string MG_AbyssSplitRoster() { return "RS_MGLostSoul"; }

	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		if (Tier == 9)   // Abyss
		{
			string roster = MG_AbyssSplitRoster();
			if (roster.Length() > 0)
				MG_DeathSplit(roster, 2, 2);   // two, at Green
		}
		Super.Die(source, inflictor, dmgflags, MeansOfDeath);
	}

	void MG_DeathSplit(string roster, int count = 2, int splitTier = 2)
	{
		let cv = CVar.GetCVar("rsq_mg_deathsplit");
		if (cv && !cv.GetBool()) return;
		// (HF's potato/lite trim read its fx dial, hfmon_fx_level; at its
		// default, 3 ultra, the trim does nothing, and no dial exists here.)
		Array<string> picks;
		roster.Split(picks, " ");
		if (picks.Size() == 0) return;
		int splitGroup = RS_SplitStamp.Mark(self, 0);   // RSQ Score read-out (RS_ScoreReadout.zs): the parent's group
		for (int i = 0; i < count; i++)
		{
			string pick = picks[random(0, picks.Size() - 1)];
			double ang = frandom(0, 360);
			vector3 spot = Vec3Angle(frandom(16, 40), ang, 8);
			Actor a = Actor.Spawn(pick, spot, ALLOW_REPLACE);
			if (!a) continue;
			RS_SplitStamp.Mark(a, splitGroup);   // RSQ Score read-out: a child of that split
			let mon = RS_MGMonster(a);
			if (mon)
			{
				mon.MG_ApplyTierNow(splitTier, true);
				if (target) { mon.target = target; mon.bAmbush = false; }
			}
			a.A_StartSound("misc/spawn");
			Spawn("MG_RiftFlash", spot, ALLOW_REPLACE);
		}
	}

	// HF_Monster.Tick: jump a freshly-killed monster into its reactive death
	// (set by the handler; SetState is valid in the actor's own Tick).
	int mgSampleOffset;   // HF sampleOffset: staggers the icon across a crowd

	override void Tick()
	{
		Super.Tick();

		// HF_Monster.Tick's floating tier marker: coloured tiers only, every 20
		// tics, off by default (HF hfmon_tier_icon -> rsq_mg_tier_icon).
		if (health > 0 && Tier > 1 && (level.maptime % 20) == (mgSampleOffset % 20))
		{
			let cv = CVar.GetCVar("rsq_mg_tier_icon");
			if (cv && cv.GetBool())
			{
				let ic = MG_TierIcon(Spawn("MG_TierIcon", pos + (0, 0, Height + 8)));
				if (ic) { ic.SetTierFrame(Tier); ic.master = self; }
			}
		}

		if (mgPendingDeathSeq.Length() > 0)
		{
			string d = mgPendingDeathSeq;
			mgPendingDeathSeq = "";
			let st = FindStateByString(d, true);
			if (st) SetState(st);
		}
	}

	// RS_MonsterMaster's entry dispatchers send each label to "this class's own
	// label of that name". For a label an MG creature does not define, that is
	// the dispatcher itself: an infinite state loop (seen on the rig, 2026-11-09:
	// "Infinite state loop in Actor 'RS_MGZombieman' state 'RS_MonsterMaster.5'",
	// the Melee dispatcher). HF's base was a plain Actor with none of these
	// labels, so the MG monsters get none either: a label followed by Stop is
	// no state, and a class that defines the label still overrides this.
	States
	{
	Missile:
		Stop;
	Melee:
		Stop;
	XDeath:
		Stop;
	Raise:
		Stop;

	// HF_Monster's reactive deaths (sounds mg/hb/*, FX MG_*, cvars rsq_mg_*).
	DeathSeq_Head:
		TNT1 A 0
		{
			A_StartSound(mgHeadExplode ? "mg/hb/headpop" : "mg/hb/bone", CHAN_BODY, CHANF_OVERLAP);
			MG_HeadPop();
			let st = FindStateByString("Death", true);
			return st ? st : FindStateByString("Spawn", true);
		}
		Stop;
	DeathSeq_Gib:
		TNT1 A 0 { A_StartSound("mg/hb/gib", CHAN_BODY, CHANF_OVERLAP); let st = FindStateByString("XDeath", true); return st ? st : FindStateByString("Death", true); }
		Stop;
	DeathSeq_Burn:
		TNT1 A 0
		{
			A_StartSound("mg/hb/burn", CHAN_BODY, CHANF_OVERLAP);
			A_SetRenderStyle(1.0, STYLE_Shaded);
			SetShade("18 12 0C");
			CVar hp = CVar.FindCVar("rsq_mg_optimized_fx");
			bool lowperf = (hp && hp.GetBool());
			if (!lowperf)
			{
				int n = MG_GoreBudget.PartsFor(10);
				for (int i = 0; i < n; i++)
				{
					Actor e = Spawn("MG_EmberTrail", (pos.x + frandom(-8, 8), pos.y + frandom(-8, 8), pos.z + frandom(0, height * 0.7)), ALLOW_REPLACE);
					if (e) e.vel = (frandom(-0.6, 0.6), frandom(-0.6, 0.6), frandom(0.8, 2.0));
				}
				int sm = MG_GoreBudget.PartsFor(2);
				for (int i = 0; i < sm; i++)
					Spawn("MG_SmokeWake", (pos.x + frandom(-5, 5), pos.y + frandom(-5, 5), pos.z + height * 0.55), ALLOW_REPLACE);
				Spawn("MG_BurnLight", (pos.x, pos.y, pos.z + height * 0.5), ALLOW_REPLACE);
			}
			else
			{
				int n = MG_GoreBudget.PartsFor(6);
				for (int i = 0; i < n; i++)
					A_SpawnParticle(Color(255, random(200, 255), random(90, 170), random(20, 60)), SPF_FULLBRIGHT, 20, frandom(1.5, 2.5), 0, frandom(-7, 7), frandom(-7, 7), frandom(0, height * 0.5), 0, 0, frandom(0.6, 1.2));
			}
			let st = FindStateByString("Death", true);
			return st ? st : FindStateByString("Spawn", true);
		}
		Stop;
	DeathSeq_Freeze:
		TNT1 A 0
		{
			A_StartSound("mg/hb/ice", CHAN_BODY, CHANF_OVERLAP);
			A_SetRenderStyle(1.0, STYLE_Shaded);
			SetShade("88 C8 FF");
			CVar hp = CVar.FindCVar("rsq_mg_optimized_fx");
			bool lowperf = (hp && hp.GetBool());
			int n = MG_GoreBudget.PartsFor(lowperf ? 6 : 14);
			for (int i = 0; i < n; i++)
				A_SpawnParticle(Color(255, random(180, 220), random(225, 255), 255), SPF_FULLBRIGHT, lowperf ? 16 : 24, frandom(2.0, 4.0), 0, frandom(-10, 10), frandom(-10, 10), frandom(0, height), frandom(-1.5, 1.5), frandom(-1.5, 1.5), frandom(-0.5, 1.5));
			if (!lowperf) Spawn("MG_FrostLight", (pos.x, pos.y, pos.z + height * 0.5), ALLOW_REPLACE);
			let st = FindStateByString("Death", true);
			return st ? st : FindStateByString("Spawn", true);
		}
		Stop;
	DeathSeq_Shock:
		TNT1 A 0
		{
			A_StartSound("mg/hb/spark", CHAN_BODY, CHANF_OVERLAP);
			CVar hp = CVar.FindCVar("rsq_mg_optimized_fx");
			bool lowperf = (hp && hp.GetBool());
			int n = MG_GoreBudget.PartsFor(lowperf ? 8 : 16);
			for (int i = 0; i < n; i++)
				A_SpawnParticle(Color(255, random(170, 220), random(210, 250), 255), SPF_FULLBRIGHT, lowperf ? 12 : 18, frandom(1.5, 3.0), 0, frandom(-8, 8), frandom(-8, 8), frandom(0, height), frandom(-2.5, 2.5), frandom(-2.5, 2.5), frandom(0.5, 3.0));
			if (!lowperf)
			{
				int sk = MG_GoreBudget.PartsFor(8);
				for (int i = 0; i < sk; i++)
					Spawn("MG_BulletSpark", (pos.x + frandom(-9, 9), pos.y + frandom(-9, 9), pos.z + frandom(0, height)), ALLOW_REPLACE);
				Spawn("MG_ZapLight", (pos.x, pos.y, pos.z + height * 0.5), ALLOW_REPLACE);
			}
			let st = FindStateByString("Death", true);
			return st ? st : FindStateByString("Spawn", true);
		}
		Stop;
	DeathSeq_Melt:
		TNT1 A 0
		{
			A_StartSound("mg/hb/burn1", CHAN_BODY, CHANF_OVERLAP);   // ACIDMELT (HF hb/brn1)
			A_SetRenderStyle(1.0, STYLE_Shaded);
			SetShade("3A 8C 30");
			CVar hp = CVar.FindCVar("rsq_mg_optimized_fx");
			bool lowperf = (hp && hp.GetBool());
			int n = MG_GoreBudget.PartsFor(lowperf ? 6 : 12);
			for (int i = 0; i < n; i++)
				A_SpawnParticle(Color(255, random(60, 120), random(160, 210), random(40, 90)), SPF_FULLBRIGHT, 26, frandom(2.0, 4.0), 0, frandom(-9, 9), frandom(-9, 9), frandom(0, height), frandom(-0.5, 0.5), frandom(-0.5, 0.5), frandom(-1.0, 0.5));
			let st = FindStateByString("Death", true);
			return st ? st : FindStateByString("Spawn", true);
		}
		Stop;
	}

	// rs_mg_<fam>_tNN. Common (and any tier this family has no recipe for)
	// wears no translation.
	void MG_Tint(int t)
	{
		A_SetTranslation("");
		if (t <= 1 || tintFam.Length() == 0) return;
		A_SetTranslation(String.Format("rs_mg_%s_t%02d", tintFam, t));
	}
}


// ============================================================================
// MG ZOMBIEMAN  (Meatgrinder Zombieman1 -> RS_MGZombieman)
// Hitscan-ish grunt: fires MG_EnemyBullet (fast projectile). Gory 5-way
// dismember deaths + saw/plasma/crush. Tint family "zombie" (reuses CH zombie).
// ============================================================================
class RS_MGZombieman : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "ZombieMan";
		Health 20;
		Radius 20;
		Height 56;
		Speed 8;
		PainChance 200;
		Monster;
		+FLOORCLIP;
		SeeSound "grunt/sight";
		AttackSound "grunt/attack";
		PainSound "grunt/pain";
		DeathSound "grunt/death";
		ActiveSound "grunt/active";
		Obituary "$OB_ZOMBIE";
		DropItem "Clip";
		BloodColor "darkred";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "zombie"; }

	States
	{
	Spawn:
		POSS AB 10 A_Look;
		Loop;
	See:
		POSS AABBCCDD 4 A_Chase;
		Loop;
	Missile:
		POSS E 10 A_FaceTarget;
		TNT1 A 0 A_StartSound("mg/enemygun", CHAN_WEAPON);
		TNT1 A 0 A_StartSound("mg/mgun2", 4);
		TNT1 A 0 A_CustomMissile("MG_EnemyBullet", 38, 0, random(-6,6), 1, random(-1,1));
		POSS F 8;
		POSS E 8;
		Goto See;
	Pain:
		POSS G 3;
		POSS G 3 A_Pain;
		Goto See;
	Death.Melee:
		MGA5 A 0;
		MGA5 A 0 A_FaceTarget;
		MGA5 A 0 A_Recoil(10);
	Death:
		POSS H 0;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50, 0, random(0, 360), 2, random(60, 90));
		POSS H 0 A_Jump(192, "Death1", "Death2", "Death3", "Death4", "Death5");
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 40, 0, random(0, 360), 2, random(0, 90));
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(45, 50));
		POSS H 5;
		POSS I 5 A_Scream;
		POSS J 5 A_NoBlocking;
		POSS K 5;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20, 0, random(0, 360), 2, random(10, 45));
		POSS L -1;
		Stop;
	Death1: // Leg
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 20, 0, random(0, 360), 2, random(0, 90));
		TNT1 A 0 A_CustomMissile("MG_XZombieManLeg", 10, 0, random(0, 360), 2, random(40, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(45, 50));
		MGA8 A 6 A_Scream;
		MGA8 B 6 A_NoBlocking;
		MGA8 C 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20, 0, random(0, 360), 2, random(10, 45));
		MGA8 D -1;
		Stop;
	Death2: // Arm
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 20, 0, random(0, 360), 2, random(0, 90));
		TNT1 A 0 A_CustomMissile("MG_XDeathArm", 50, 0, random(0, 360), 2, random(40, 60));
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(45, 50));
		MGB8 A 6 A_Scream;
		MGB8 B 6 A_NoBlocking;
		MGB8 CD 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20, 0, random(0, 360), 2, random(10, 45));
		MGB8 E -1;
		Stop;
	Death3: // Head
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50, 0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(45, 50));
		MGB9 B 6 A_Scream;
		MGB9 C 6 A_NoBlocking;
		MGB9 DEF 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20, 0, random(0, 360), 2, random(10, 45));
		MGB9 G -1;
		Stop;
	Death4: // Guts
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 30, 0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 30, 0, random(0, 360), 2, random(10, 45));
		MGB5 A 6 A_Scream;
		MGB5 B 6 A_NoBlocking;
		MGB5 BCD 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20, 0, random(0, 360), 2, random(10, 45));
		MGB5 E -1;
		Stop;
	Death5: // Heavy
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 30, 0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 30, 0, random(0, 360), 2, random(10, 45));
		MGB5 A 6 A_Scream;
		MGB5 B 6 A_NoBlocking;
		MGB5 BCD 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20, 0, random(0, 360), 2, random(10, 45));
		MGB5 E -1;
		Stop;
	XDeath:
		POSS M 4;
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60, 0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50, 0, random(0, 360), 2, random(30, 90));
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeathArm", 50, 0, random(0, 360), 2, random(40, 60));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath2", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath3", 50, 0, random(0, 360), 2, random(10, 45));
		POSS N 5 A_XScream;
		POSS O 5 A_NoBlocking;
		POSS PQRST 5;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40, 0, random(0, 360), 2, random(10, 45));
		POSS U -1;
		Stop;
	Death.Saw:
		POSS M 4;
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60, 0, random(0, 360), 2, random(0, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50, 0, random(0, 360), 2, random(30, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40, 0, random(0, 360), 2, random(10, 45));
		POSS N 5 A_XScream;
		POSS O 5 A_NoBlocking;
		POSS PQRST 5;
		POSS U -1;
		Stop;
	Raise:
		POSS K 5;
		POSS JIH 5;
		Goto See;
	Death.Plasma:
		MGAR A 0 A_Stop;
		MGAR A 0 A_XScream;
		MGAR A 0 A_NoBlocking;
		TNT1 A 0 A_SpawnItem("MG_SmokePillar");
		TNT1 A 0 A_CustomMissile("MG_XDeath2", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath3", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60, 0, random(0, 360), 2, random(0, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40, 0, random(0, 360), 2, random(10, 45));
		MGAR ABCDEFG 4;
		MGAR H -1;
		Stop;
	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushed", 0, 0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 50, 0, random(0, 360), 2, random(10, 45));
		MGAN A 1;
		MGAN A -1;
		Stop;
	}
}


// ============================================================================
// MG IMP  (Meatgrinder Imp1 -> RS_MGImp)
// Stock A_TroopAttack (fireball/claw). Gory dismember deaths. Tint family "imp".
// ============================================================================
class RS_MGImp : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "DoomImp";
		Health 60;
		Radius 20;
		Height 56;
		Mass 100;
		Speed 8;
		PainChance 200;
		Monster;
		+FLOORCLIP;
		SeeSound "imp/sight";
		PainSound "imp/pain";
		DeathSound "imp/death";
		ActiveSound "imp/active";
		HitObituary "$OB_IMPHIT";
		Obituary "$OB_IMP";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "imp"; }

	States
	{
	Spawn:
		TROO AB 10 A_Look;
		Loop;
	See:
		TROO AABBCCDD 3 A_Chase;
		Loop;
	Melee:
	Missile:
		TROO EF 8 A_FaceTarget;
		TROO G 6 A_TroopAttack;
		Goto See;
	Pain:
		TROO H 2;
		TROO H 2 A_Pain;
		Goto See;
	Death:
		TROO I 1;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50, 0, random(0, 360), 2, random(60, 90));
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(45, 50));
		TROO I 0 A_Jump(192, "Death1", "Death2", "Death3", "Death4", "Death5");
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 40, 0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(10, 45));
		TROO I 5;
		TROO J 5 A_Scream;
		TROO K 5 A_NoBlocking;
		TROO L 5;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20, 0, random(0, 360), 2, random(10, 45));
		TROO M -1;
		Stop;
	Death1: // Leg
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 20, 0, random(0, 360), 2, random(0, 90));
		TNT1 A 0 A_CustomMissile("MG_XDeathImpLeg", 10, 0, random(0, 360), 2, random(40, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(10, 45));
		MGBP A 6 A_Scream;
		MGBP B 6 A_NoBlocking;
		MGBP C 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20, 0, random(0, 360), 2, random(10, 45));
		MGBP D -1;
		Stop;
	Death2: // Arm
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 20, 0, random(0, 360), 2, random(0, 90));
		TNT1 A 0 A_CustomMissile("MG_XDeathImpArm", 50, 0, random(0, 360), 2, random(40, 60));
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(10, 45));
		MGBO A 6 A_Scream;
		MGBO B 6 A_NoBlocking;
		MGBO CD 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20, 0, random(0, 360), 2, random(10, 45));
		MGBO E -1;
		Stop;
	Death3: // Head
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50, 0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_GibHeadPiece", 55, 0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_GibTeeth", 55, 0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_GibEyeball", 55, 0, random(0, 360), 2, random(45, 50));
		MGBR B 6 A_Scream;
		MGBR C 6 A_NoBlocking;
		MGBR D 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20, 0, random(0, 360), 2, random(10, 45));
		MGBR E -1;
		Stop;
	Death4: // Guts
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 30, 0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 30, 0, random(0, 360), 2, random(10, 45));
		MGBO A 6 A_Scream;
		MGBO B 6 A_NoBlocking;
		MGBO CD 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20, 0, random(0, 360), 2, random(10, 45));
		MGBO E -1;
		Stop;
	Death5: // Heavy
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 30, 0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 30, 0, random(0, 360), 2, random(10, 45));
		MGBO A 6 A_Scream;
		MGBO B 6 A_NoBlocking;
		MGBO CD 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20, 0, random(0, 360), 2, random(10, 45));
		MGBO E -1;
		Stop;
	XDeath:
		TROO I 1;
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60, 0, random(0, 360), 2, random(0, 90));
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50, 0, random(0, 360), 2, random(30, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeathImpArm", 50, 0, random(0, 360), 2, random(40, 60));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath2", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath3", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(10, 45));
		TROO J 5 A_XScream;
		TROO K 5 A_NoBlocking;
		TROO LM 5;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40, 0, random(0, 360), 2, random(10, 45));
		TROO N -1;
		Stop;
	Raise:
		TROO MLKJI 8;
		Goto See;
	Death.Plasma:
		MGAR A 0 A_Stop;
		MGAR A 0 A_XScream;
		MGAR A 0 A_NoBlocking;
		TNT1 A 0 A_CustomMissile("MG_XDeath2", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath3", 50, 0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60, 0, random(0, 360), 2, random(0, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40, 0, random(0, 360), 2, random(10, 45));
		MGAR ABCDEFG 4;
		TNT1 A 0 A_SpawnItem("MG_SmokePillar");
		MGAR H -1;
		Stop;
	Death.Saw:
		TROO I 4;
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60, 0, random(0, 360), 2, random(0, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50, 0, random(0, 360), 2, random(30, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30, 0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath1b", 40, 0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40, 0, random(0, 360), 2, random(10, 45));
		TROO J 5 A_XScream;
		TROO K 5 A_NoBlocking;
		TROO LM 5;
		TROO N -1;
		Stop;
	}
}


// ============================================================================
// MEATGRINDER SET -- remaining 14 monsters (Stage 2b)
// ============================================================================

// ============================================================================
// RS_MGDemon  (Meatgrinder Pinky)  tint "demon"
// ============================================================================
class RS_MGDemon : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "Demon";
		Health 150;
		PainChance 180;
		Speed 10;
		Radius 30;
		Height 56;
		Mass 400;
		Monster;
		+FLOORCLIP;
		SeeSound "demon/sight";
		AttackSound "demon/melee";
		PainSound "demon/pain";
		DeathSound "demon/death";
		ActiveSound "demon/active";
		Obituary "$OB_DEMONHIT";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "demon"; }

	States
	{

	Spawn:
		SARG AB 10 A_Look;
		Loop;
	See:
		SARG AABBCCDD 2 Fast A_Chase;
		Loop;
	Melee:
		SARG EF 8 Fast A_FaceTarget;
		SARG G 8 Fast A_SargAttack;
		Goto See;
	Pain:
		SARG H 2 Fast;
		SARG H 2 Fast A_Pain;
		Goto See;
	Death:
		SARG I 1;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		SARG I 0 A_Jump(220, "Death1", "Death2", "Death3");
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 40,  0, random(0, 360), 2, random(0, 90));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		SARG I 8;
		SARG J 8 A_Scream;
		SARG K 4;
		SARG L 4 A_NoBlocking;
		SARG M 4;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		SARG N -1;
		Stop;

	Death1:
		TNT1 A 0;
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 20,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath2", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath3", 40,  0, random(0, 360), 2, random(10, 45));
		MGBF A 6 A_Scream;
		MGBF B 6 A_NoBlocking;
		MGBF C 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGBF D -1;
		Stop;
	XDeath:
	Death2:
		TNT1 A 0;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 20,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeathDemonArm", 50,  0, random(0, 360), 2, random(10, 45));
		MGBE A 6 A_Scream;
		MGBE B 6 A_NoBlocking;
		MGBE C 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGBE D -1;
		Stop;

	Death3:
		TNT1 A 0;
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 20,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeathDemonArm", 50,  0, random(0, 360), 2, random(10, 45));
		MGBC A 6 A_Scream;
		MGBC B 6 A_NoBlocking;
		MGBC CDE 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGBC F -1;
		Stop;

	Death.Plasma:
		TNT1 A 0;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 20,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 40,  0, random(0, 360), 2, random(10, 45));
		MGBD A 6 A_Scream;
		TNT1 A 0 A_SpawnItem("MG_SmokePillar");
		MGBD B 6 A_NoBlocking;
		MGBD C 6;
		MGBD D -1;
		Stop;

	Raise:
		SARG N 5;
		SARG MLKJI 5;
		Goto See;

	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushed", 0,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		MGAN B 1;
		MGAN B -1;
		Stop;

	}
}

// ============================================================================
// RS_MGSpectre  (Meatgrinder Pinky)  tint "spectre"
// ============================================================================
class RS_MGSpectre : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "Spectre";
		Health 150;
		PainChance 180;
		Speed 10;
		Radius 30;
		Height 56;
		Mass 400;
		RenderStyle "OptFuzzy";
		Alpha 0.5;
		Monster;
		+FLOORCLIP;
		+SHADOW
		SeeSound "spectre/sight";
		AttackSound "spectre/melee";
		PainSound "spectre/pain";
		DeathSound "spectre/death";
		ActiveSound "spectre/active";
		HitObituary "$OB_SPECTREHIT";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "spectre"; }

	States
	{

	Spawn:
		SARG AB 10 A_Look;
		Loop;
	See:
		SARG AABBCCDD 2 Fast A_Chase;
		Loop;
	Melee:
		SARG EF 8 Fast A_FaceTarget;
		SARG G 8 Fast A_SargAttack;
		Goto See;
	Pain:
		SARG H 2 Fast;
		SARG H 2 Fast A_Pain;
		Goto See;
	Death:
		SARG I 1;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		SARG I 0 A_Jump(220, "Death1", "Death2", "Death3");
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 40,  0, random(0, 360), 2, random(0, 90));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		SARG I 8;
		SARG J 8 A_Scream;
		SARG K 4;
		SARG L 4 A_NoBlocking;
		SARG M 4;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		SARG N -1;
		Stop;

	Death1:
		TNT1 A 0;
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 20,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath2", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath3", 40,  0, random(0, 360), 2, random(10, 45));
		MGBF A 6 A_Scream;
		MGBF B 6 A_NoBlocking;
		MGBF C 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGBF D -1;
		Stop;
	XDeath:
	Death2:
		TNT1 A 0;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 20,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeathDemonArm", 50,  0, random(0, 360), 2, random(10, 45));
		MGBE A 6 A_Scream;
		MGBE B 6 A_NoBlocking;
		MGBE C 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGBE D -1;
		Stop;

	Death3:
		TNT1 A 0;
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 20,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeathDemonArm", 50,  0, random(0, 360), 2, random(10, 45));
		MGBC A 6 A_Scream;
		MGBC B 6 A_NoBlocking;
		MGBC CDE 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGBC F -1;
		Stop;

	Death.Plasma:
		TNT1 A 0;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 20,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 40,  0, random(0, 360), 2, random(10, 45));
		MGBD A 6 A_Scream;
		TNT1 A 0 A_SpawnItem("MG_SmokePillar");
		MGBD B 6 A_NoBlocking;
		MGBD C 6;
		MGBD D -1;
		Stop;

	Raise:
		SARG N 5;
		SARG MLKJI 5;
		Goto See;

	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushed", 0,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		MGAN B 1;
		MGAN B -1;
		Stop;

	}
}

// ============================================================================
// RS_MGLostSoul  (Meatgrinder LostSoul1)  tint "lostsoul"
// ============================================================================
class RS_MGLostSoul : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "LostSoul";
		Health 100;
		Radius 16;
		Height 56;
		Mass 50;
		Speed 8;
		PainChance 256;
		Damage 3;
		RenderStyle "Add";
		Alpha 1;
		Monster;
		+FLOORCLIP;
		+FLOAT
		+NOGRAVITY
		+MISSILEMORE
		+DONTFALL
		SeeSound "skull/active";
		AttackSound "skull/melee";
		PainSound "skull/pain";
		DeathSound "skull/death";
		ActiveSound "skull/active";
		Obituary "$OB_SKULL";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "lostsoul"; }

	States
	{

	Spawn:
		SKUL AB 10 BRIGHT A_Look;
		Loop;
	See:
		SKUL AB 6 BRIGHT A_Chase;
		Loop;
	Missile:
		SKUL C 10 BRIGHT A_FaceTarget;
		SKUL D 4 BRIGHT A_SkullAttack;
		SKUL CD 4 BRIGHT;
		Goto Missile+2;
	Pain:
		SKUL E 3 BRIGHT;
		SKUL E 3 BRIGHT A_Pain;
		Goto See;
	Death:
		SKUL F 3 BRIGHT;
		SKUL G 3 BRIGHT A_Scream;
		TNT1 AAA 0 A_CustomMissile("MG_ExplosionFire", 10,  0, random(0, 360), 2, random(-90, 90));
		TNT1 A 0 A_CustomMissile("MG_ExplSmokeParticle", 10,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAA 0 A_CustomMissile("MG_LostSoulGib1", 20,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_LostSoulGib2", 20,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAA 0 A_CustomMissile("MG_LostSoulGib3", 20,  0, random(0, 360), 2, random(0, 90));
		SKUL H 3 BRIGHT;
		SKUL I 3 BRIGHT A_NoBlocking;
		SKUL J 3;
		SKUL K 3;
		Stop;

	}
}

// ============================================================================
// RS_MGRevenant  (Meatgrinder skelly)  tint "rev"
// ============================================================================
class RS_MGRevenant : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "Revenant";
		Health 300;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 10;
		PainChance 100;
		Monster;
		+FLOORCLIP;
		SeeSound "skeleton/sight";
		AttackSound "skeleton/attack";
		PainSound "skeleton/pain";
		DeathSound "skeleton/death";
		ActiveSound "skeleton/active";
		MeleeSound "skeleton/melee";
		Obituary "$OB_UNDEAD";
		HitObituary "$OB_UNDEADHIT";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "rev"; }

	States
	{

	Spawn:
		SKEL AB 10 A_Look;
		Loop;
	See:
		SKEL AABBCCDDEEFF 2 A_Chase;
		Loop;
	Melee:
		SKEL G 1 A_FaceTarget;
		SKEL G 6 A_SkelWhoosh;
		SKEL H 6 A_FaceTarget;
		SKEL I 6 A_SkelFist;
		Goto See;
	Missile:
		SKEL J 1 BRIGHT A_FaceTarget;
		SKEL J 9 BRIGHT A_FaceTarget;
		SKEL K 10 A_SkelMissile;
		SKEL KK 10 A_FaceTarget;
		Goto See;
	Pain:
		SKEL L 5;
		SKEL L 5 A_Pain;
		Goto See;
	Death:
		TNT1 A 0;
		TNT1 A 0 A_Jump(128, "Death2");
		SKEL LM 5;
		SKEL N 5 A_Scream;
		SKEL O 5 A_NoBlocking;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 30,  0, random(0, 360), 2, random(10, 45));
		SKEL P 5;
		SKEL Q -1;
		Stop;
	Death2:
		MGBA E 4;
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 30,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath2b", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath3b", 40,  0, random(0, 360), 2, random(10, 45));
		MGBA F 5 A_Scream;
		MGBA G 5 A_NoBlocking;
		TNT1 H 0 A_CustomMissile("MG_XDeath1", 30,  0, random(0, 360), 2, random(10, 45));
		MGBA IJK 5;
		MGBA L -1;
		Stop;

	Death.Plasma:
		MGBB E 4;
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 30,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath2b", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath3b", 40,  0, random(0, 360), 2, random(10, 45));
		MGBB F 5 A_Scream;
		MGBB G 5 A_NoBlocking;
		TNT1 A 0 A_SpawnItem("MG_SmokePillar");
		TNT1 H 0 A_CustomMissile("MG_XDeath1", 30,  0, random(0, 360), 2, random(10, 45));
		MGBB IJK 5;
		MGBB L -1;
		Stop;

	XDeath:
		MGBA AB 2;
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 30,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_RevenantGib1", 40,  0, random(0, 360), 2, random(30, 45));
		TNT1 A 0 A_CustomMissile("MG_RevenantGib2", 40,  0, random(0, 360), 2, random(30, 45));
		TNT1 A 0 A_CustomMissile("MG_RevenantGib3", 40,  0, random(0, 360), 2, random(30, 45));
		MGA9 C 3 A_Scream;
		MGA9 D 3 A_NoBlocking;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 30,  0, random(0, 360), 2, random(10, 45));
		MGA9 EFGHIJ 3;
		MGA9 K -1;
		Stop;


	Raise:
		SKEL Q 5;
		SKEL PONML 5;
		Goto See;

	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushed", 0,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		MGAN A 1;
		MGAN A -1;
		Stop;

	}
}

// ============================================================================
// RS_MGCaco  (Meatgrinder Cacodemon1)  tint "caco"
// ============================================================================
class RS_MGCaco : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "Cacodemon";
		Health 400;
		Radius 31;
		Height 56;
		Mass 400;
		Speed 8;
		PainChance 128;
		RenderStyle "Add";
		Alpha 1;
		Monster;
		+FLOORCLIP;
		+FLOAT
		+NOGRAVITY
		SeeSound "caco/sight";
		PainSound "caco/pain";
		DeathSound "caco/death";
		ActiveSound "caco/active";
		Obituary "$OB_CACO";
		HitObituary "$OB_CACOHIT";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "caco"; }

	States
	{

	Spawn:
		HEAD A 10 A_Look;
		Loop;
	See:
		HEAD A 3 A_Chase;
		Loop;
	Missile:
		HEAD B 5 A_FaceTarget;
		HEAD C 5 A_FaceTarget;
		HEAD D 5 BRIGHT A_HeadAttack;
		Goto See;
	Pain:
		HEAD E 3;
		HEAD E 3 A_Pain;
		HEAD F 6;
		Goto See;
	Death2:
		TNT1 A 0;
		TNT1 A 0 A_Jump(160, "XDeath");
		HEAD G 8 A_NoBlocking;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodCheckerblue", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 A 0 A_CustomMissile("MG_XDeath1bblue", 30,  0, random(0, 360), 2, random(10, 45));
		HEAD H 6 A_Scream;
		HEAD I 6;
		HEAD J 6;
		HEAD K 6;
		HEAD LLL 6 A_SetScale(scalex+0.03, scaley-0.1);
		TNT1 A 0 A_CustomMissile("MG_XDeath1blue", 20,  0, random(0, 360), 2, random(10, 45));
		HEAD L -1 A_SetFloorClip;
		Stop;

	Death:
		MGAJ A  0;
		TNT1 AA 0 A_CustomMissile("MG_XDeath1bblue", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2blue", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3blue", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath2bblue", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath3bblue", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 AAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBigblue", 50,  0, random(0, 360), 2, random(10, 45));
		MGAJ A  0 A_Scream;
		MGAJ A  0;
		MGAJ A  0 A_NoBlocking;
		MGAJ ABCDEFG 4;
		TNT1 A 0 A_CustomMissile("MG_XDeath1blue", 20,  0, random(0, 360), 2, random(10, 45));
		MGAJ H -1 A_SetFloorClip;
		Stop;

	Death.Plasma:
		MGAJ A  0;
		TNT1 AA 0 A_CustomMissile("MG_XDeath1bblue", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2blue", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3blue", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath2bblue", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath3bblue", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 AAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBigblue", 50,  0, random(0, 360), 2, random(10, 45));
		MGAK A  0 A_Scream;
		MGAK A  0;
		MGAK A  0 A_NoBlocking;
		MGAK ABCDEFG 4;
		TNT1 A 0 A_SpawnItem("MG_SmokePillar");
		TNT1 A 0 A_CustomMissile("MG_XDeath1blue", 20,  0, random(0, 360), 2, random(10, 45));
		MGAK H -1 A_SetFloorClip;
		Stop;

	Raise:
		HEAD L 8 A_UnSetFloorClip;
		HEAD KJIHG 8;
		Goto See;
	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushedBlue", 0,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2blue", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3blue", 50,  0, random(0, 360), 2, random(10, 45));
		MGAN E 1;
		MGAN E -1;
		Stop;

	}
}

// ============================================================================
// RS_MGPainElemental  (Meatgrinder PainElemental1)  tint "pe"
// ============================================================================
class RS_MGPainElemental : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "PainElemental";
		Health 400;
		Radius 31;
		Height 56;
		Mass 400;
		Speed 8;
		PainChance 128;
		Monster;
		+FLOORCLIP;
		+FLOAT
		+NOGRAVITY
		SeeSound "pain/sight";
		PainSound "pain/pain";
		DeathSound "pain/death";
		ActiveSound "pain/active";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "pe"; }

	States
	{

	Spawn:
		PAIN A 10 A_Look;
		Loop;
	See:
		PAIN AABBCC 3 A_Chase;
		Loop;
	Missile:
		PAIN D 5 A_FaceTarget;
		PAIN E 5 A_FaceTarget;
		PAIN F 4 BRIGHT A_FaceTarget;
		PAIN F 1 BRIGHT A_PainAttack;
		Goto See;
	Pain:
		PAIN G 6;
		PAIN G 6 A_Pain;
		Goto See;
	Death:
		PAIN H 8 BRIGHT;
		PAIN I 8 BRIGHT A_Scream;
		PAIN JK 8 BRIGHT;
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 20,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath2", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath3", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_ExplosionFire", 0,  0, random(0, 360), 2, random(-90, 90));
		TNT1 AAA 0 A_CustomMissile("MG_ExplSmokeParticle", 0,  0, random(0, 360), 2, random(0, 90));
		PAIN L 8 BRIGHT A_PainDie;
		PAIN M 8;
		MGA6 X 1;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGA6 X -1;
		Stop;
	Raise:
		PAIN MLKJIH 8;
		Goto See;

	}
}

// ============================================================================
// RS_MGBaron  (Meatgrinder BaronOfHell1)  tint "baron"
// ============================================================================
class RS_MGBaron : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "BaronOfHell";
		Health 1000;
		Radius 24;
		Height 64;
		Mass 1000;
		Speed 8;
		PainChance 50;
		Monster;
		+FLOORCLIP;
		+BOSSDEATH;    // crush/ice deaths still fire the boss special
		+E1M8BOSS;     // last Baron on Doom1 E1M8 lowers floor tag 666
		SeeSound "baron/sight";
		PainSound "baron/pain";
		DeathSound "baron/death";
		ActiveSound "baron/active";
		Obituary "$OB_BARON";
		HitObituary "$OB_BARONHIT";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "baron"; }

	States
	{

	Spawn:
		BOSS AB 10 A_Look;
		Loop;
	See:
		BOSS AABBCCDD 3 A_Chase;
		Loop;
	Melee:
	Missile:
		BOSS EF 8 A_FaceTarget;
		BOSS G 8 A_BruisAttack;
		Goto See;
	Pain:
		BOSS H  2;
		BOSS H  2 A_Pain;
		Goto See;
	Death:
		BOSS I  0;
		TNT1 A 0 A_JumP(64, "XDeath");
		BOSS I  8;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodCheckerGreen", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1bGreen", 40,  0, random(0, 360), 2, random(45, 50));
		BOSS J  8 A_Scream;
		BOSS K  8;
		BOSS L  8 A_NoBlocking;
		BOSS MN 8;
		TNT1 A 0 A_CustomMissile("MG_XDeath1Green", 20,  0, random(0, 360), 2, random(10, 45));
		BOSS O -1 A_BossDeath;
		Stop;


	XDeath:
		MGBT A  5;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodCheckerGreen", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1bGreen", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2Green", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3Green", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath2bGreen", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath3bGreen", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 AAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBigGreen", 50,  0, random(0, 360), 2, random(10, 45));
		MGBT B  5 A_Scream;
		MGBT C  5;
		MGBT D  5 A_NoBlocking;
		MGBT EFGH 5;
		TNT1 A 0 A_CustomMissile("MG_XDeath1Green", 20,  0, random(0, 360), 2, random(10, 45));
		MGBT h -1 A_BossDeath;
		Stop;


	Death.Plasma:
		MGBT A  5;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodCheckerGreen", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1bGreen", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath2bGreen", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath3bGreen", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 AAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBigGreen", 50,  0, random(0, 360), 2, random(10, 45));
		MGAA B  5 A_Scream;
		MGAA C  5;
		MGAA D  5 A_NoBlocking;
		MGAA EFGH 5;
		TNT1 A 0 A_CustomMissile("MG_XDeath1Green", 20,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_SpawnItem("MG_SmokePillar");
		MGAA h -1 A_BossDeath;
		Stop;

	Raise:
		BOSS O 8;
		BOSS NMLKJI  8;
		Goto See;
	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushedGreen", 0,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2Green", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3Green", 50,  0, random(0, 360), 2, random(10, 45));
		MGAN C 1;
		MGAN C -1;
		Stop;

	}
}

// ============================================================================
// RS_MGHellKnight  (Meatgrinder BaronOfHell1)  tint "hk"
// ============================================================================
class RS_MGHellKnight : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "HellKnight";
		Health 500;
		Radius 24;
		Height 64;
		Mass 1000;
		Speed 8;
		PainChance 50;
		Monster;
		+FLOORCLIP;
		SeeSound "knight/sight";
		PainSound "knight/pain";
		DeathSound "knight/death";
		ActiveSound "knight/active";
		Obituary "$OB_KNIGHT";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "hk"; }

	States
	{

	Spawn:
		BOSS AB 10 A_Look;
		Loop;
	See:
		BOSS AABBCCDD 3 A_Chase;
		Loop;
	Melee:
	Missile:
		BOSS EF 8 A_FaceTarget;
		BOSS G 8 A_BruisAttack;
		Goto See;
	Pain:
		BOSS H  2;
		BOSS H  2 A_Pain;
		Goto See;
	Death:
		BOSS I  0;
		TNT1 A 0 A_JumP(64, "XDeath");
		BOSS I  8;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodCheckerGreen", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1bGreen", 40,  0, random(0, 360), 2, random(45, 50));
		BOSS J  8 A_Scream;
		BOSS K  8;
		BOSS L  8 A_NoBlocking;
		BOSS MN 8;
		TNT1 A 0 A_CustomMissile("MG_XDeath1Green", 20,  0, random(0, 360), 2, random(10, 45));
		BOSS O -1 A_BossDeath;
		Stop;


	XDeath:
		MGBT A  5;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodCheckerGreen", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1bGreen", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2Green", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3Green", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath2bGreen", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath3bGreen", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 AAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBigGreen", 50,  0, random(0, 360), 2, random(10, 45));
		MGBT B  5 A_Scream;
		MGBT C  5;
		MGBT D  5 A_NoBlocking;
		MGBT EFGH 5;
		TNT1 A 0 A_CustomMissile("MG_XDeath1Green", 20,  0, random(0, 360), 2, random(10, 45));
		MGBT h -1 A_BossDeath;
		Stop;


	Death.Plasma:
		MGBT A  5;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodCheckerGreen", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1bGreen", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath2bGreen", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath3bGreen", 30,  0, random(0, 360), 2, random(45, 50));
		TNT1 AAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBigGreen", 50,  0, random(0, 360), 2, random(10, 45));
		MGAA B  5 A_Scream;
		MGAA C  5;
		MGAA D  5 A_NoBlocking;
		MGAA EFGH 5;
		TNT1 A 0 A_CustomMissile("MG_XDeath1Green", 20,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_SpawnItem("MG_SmokePillar");
		MGAA h -1 A_BossDeath;
		Stop;

	Raise:
		BOSS O 8;
		BOSS NMLKJI  8;
		Goto See;
	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushedGreen", 0,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2Green", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3Green", 50,  0, random(0, 360), 2, random(10, 45));
		MGAN C 1;
		MGAN C -1;
		Stop;

	}
}

// ============================================================================
// RS_MGMancubus  (Meatgrinder Mancubus)  tint "manc"
// ============================================================================
class RS_MGMancubus : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "Fatso";
		Health 600;
		Radius 48;
		Height 64;
		Mass 1000;
		Speed 8;
		PainChance 80;
		Monster;
		+FLOORCLIP;
		+BOSSDEATH;    // crush/ice deaths still fire the boss special
		+MAP07BOSS1;   // last Fatso on Doom2 MAP07 lowers floor tag 666
		SeeSound "fatso/sight";
		PainSound "fatso/pain";
		DeathSound "fatso/death";
		ActiveSound "fatso/active";
		Obituary "$OB_FATSO";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "manc"; }

	States
	{

	Spawn:
		FATT AB 15 A_Look;
		Loop;
	See:
		FATT AABBCCDDEEFF 4 A_Chase;
		Loop;
	Missile:
		FATT G 20 A_FatRaise;
		FATT H 10 BRIGHT A_FatAttack1;
		FATT IG 5;
		FATT H 10 BRIGHT A_FatAttack2;
		FATT IG 5;
		FATT H 10 BRIGHT A_FatAttack3;
		FATT IG 5;
		Goto See;
	Pain:
		FATT J 3;
		FATT J 3 A_Pain;
		Goto See;
	Death:
		FATT K 0;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_Jump(192, "Death2", "Death3", "Death4");
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath2b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath3b", 50,  0, random(0, 360), 2, random(10, 45));
		FATT K 6;
		FATT L 6 A_Scream;
		FATT M 6 A_NoBlocking;
		FATT NOPQ 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		FATT RS 6;
		FATT T -1 A_BossDeath;
		Stop;

	Death2:
		FATT K 0;
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_NoBlocking;
		MGBY ABCD 6;
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath3b", 50,  0, random(0, 360), 2, random(10, 45));
		MGBY EFGHI 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGBY I -1 A_BossDeath;
		Stop;

	Death3:
		FATT K 0;
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_NoBlocking;
		MGAT KL 6;
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath3b", 50,  0, random(0, 360), 2, random(10, 45));
		MGAT MNOP 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGAT P -1 A_BossDeath;
		Stop;

	Death4:
		FATT K 0;
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_NoBlocking;
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath3b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_FatsoArm", 50,  0, random(0, 360), 2, random(10, 45));
		MGB0 ABCD 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGB0 D -1 A_BossDeath;
		Stop;


	XDeath:
		FATT K 0;
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_NoBlocking;
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_FatsoArm", 50,  0, random(0, 360), 2, random(10, 45));
		MGBZ ABCDEF 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGBZ F -1 A_BossDeath;
		Stop;

	Death.Plasma:
		FATT K 0;
		TNT1 A 0 A_Scream;
		TNT1 A 0 A_NoBlocking;
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_FatsoArm", 50,  0, random(0, 360), 2, random(10, 45));
		MGBU ABCDEF 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGBU F -1 A_BossDeath;
		Stop;

	Raise:
		FATT R 5;
		FATT QPONMLK 5;
		Goto See;

	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushed", 0,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		MGAN F 1;
		MGAN F -1;
		Stop;

	}
}

// ============================================================================
// RS_MGArachnotron  (Meatgrinder Arachnotron2)  tint "spider"
// ============================================================================
class RS_MGArachnotron : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "Arachnotron";
		Health 500;
		GibHealth 50;
		Radius 64;
		Height 64;
		Mass 600;
		Speed 12;
		PainChance 128;
		Monster;
		+FLOORCLIP;
		+BOSSDEATH;    // crush/ice deaths still fire the boss special
		+MAP07BOSS2;   // last Arachnotron on Doom2 MAP07 raises floor tag 667
		SeeSound "baby/sight";
		PainSound "baby/pain";
		DeathSound "baby/death";
		ActiveSound "baby/active";
		Obituary "$OB_BABY";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "spider"; }

	States
	{

	Spawn:
		BSPI AB 10 A_Look;
		Loop;
	See:
		BSPI A 20;
		BSPI A 3 A_BabyMetal;
		BSPI ABBCC 3 A_Chase;
		BSPI D 3 A_BabyMetal;
		BSPI DEEFF 3 A_Chase;
		Goto See+1;
	Missile:
		BSPI A 20 BRIGHT A_FaceTarget;
		BSPI G 4 BRIGHT A_BspiAttack;
		BSPI H 4 BRIGHT;
		BSPI H 1 BRIGHT A_SpidRefire;
		Goto Missile+1;
	Pain:
		BSPI I 3;
		BSPI I 3 A_Pain;
		Goto See+1;
	Death:
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50,  0, random(0, 360), 2, random(60, 90));
		BSPI J 7 A_Scream;
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(30, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		BSPI K 7 A_NoBlocking;
		BSPI LMNO 7;
		BSPI P -1 A_BossDeath;
		Stop;

	XDeath:

		TNT1 AAA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(30, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeathSpiderLeg", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAAA 0 A_CustomMissile("MG_XDeath1b", 50,  0, random(0, 360), 2, random(10, 45));
		MGBV A 7 A_Scream;
		MGBV B 7 A_NoBlocking;
		MGBV C 7;
		MGBV D -1 A_BossDeath;
		Stop;
	Raise:
		BSPI P 5;
		BSPI ONMLKJ 5;
		Goto See+1;

	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushed", 0,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		MGAN F 1;
		MGAN F -1;
		Stop;

	}
}

// ============================================================================
// RS_MGArchvile  (Meatgrinder Archvile1)  tint "archvile"
// ============================================================================
class RS_MGArchvile : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "Archvile";
		Health 700;
		Radius 20;
		Height 56;
		Mass 500;
		Speed 15;
		PainChance 10;
		Monster;
		+FLOORCLIP;
		SeeSound "vile/sight";
		PainSound "vile/pain";
		DeathSound "vile/death";
		ActiveSound "vile/active";
		Obituary "$OB_VILE";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "archvile"; }

	States
	{

	Spawn:
		VILE AB 10 A_Look;
		Loop;
	See:
		VILE AABBCCDDEEFF 2 A_VileChase;
		Loop;
	Missile:
		VILE G 0 BRIGHT A_VileStart;
		VILE G 10 BRIGHT A_FaceTarget;
		VILE H 8 BRIGHT A_VileTarget;
		VILE IJKLMN 8 BRIGHT A_FaceTarget;
		VILE O 8 BRIGHT A_VileAttack;
		VILE P 20 BRIGHT;
		Goto See;
	Heal:
		VILE "[\]" 10 BRIGHT;
		Goto See;
	Pain:
		VILE Q 5;
		VILE Q 5 A_Pain;
		Goto See;
	Death:
		TNT1 A 0;
		TNT1 A 0 A_Jump(128, "Death2");
		VILE Q 7;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAAA 0 A_CustomMissile("MG_XDeath2", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAAA 0 A_CustomMissile("MG_XDeath3", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(10, 45));
		VILE R 7 A_Scream;
		VILE S 7 A_NoBlocking;
		VILE TUVWXY 7;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40,  0, random(0, 360), 2, random(10, 45));
		VILE Z -1;
		Stop;

	Death2:
		MGB4 A 5;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath2", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath3", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(10, 45));
		MGB4 B 5 A_Scream;
		MGB4 C 5 A_NoBlocking;
		MGB4 DFGH 5;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40,  0, random(0, 360), 2, random(10, 45));
		MGB4 I -1;
		Stop;

	Death.PLasma:
		MGAI A 5;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(10, 45));
		MGAI B 5 A_Scream;
		MGAI C 5 A_NoBlocking;
		MGAI DFGH 5;
		TNT1 A 0 A_SpawnItem("MG_SmokePillar");
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40,  0, random(0, 360), 2, random(10, 45));
		MGAI I -1;
		Stop;

	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushed", 0,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		MGAN A 1;
		MGAN A -1;
		Stop;

	}
}

// ============================================================================
// RS_MGMastermind  (Meatgrinder Mastermind)  tint "spider"
// ============================================================================
class RS_MGMastermind : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "SpiderMastermind";
		Health 3000;
		Radius 90;
		Height 100;
		Mass 1000;
		Speed 12;
		PainChance 40;
		Monster;
		+FLOORCLIP;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		+NORADIUSDMG
		+DONTMORPH
		+NOTARGET
		+BOSSDEATH
		+E3M8BOSS     // last Spider Mastermind on E3M8/E4M8 fires the boss special
		+E4M8BOSS
		SeeSound "spider/sight";
		PainSound "spider/pain";
		DeathSound "spider/death";
		ActiveSound "spider/active";
		Obituary "$OB_SPIDER";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "spider"; }

	States
	{

	Spawn:
		SPID AB 10 A_Look;
		Loop;
	See:
		SPID A 3 A_Metal;
		SPID ABB 3 A_Chase;
		SPID C 3 A_Metal;
		SPID CDD 3 A_Chase;
		SPID E 3 A_Metal;
		SPID EFF 3 A_Chase;
		Loop;
	Missile:
		SPID A 20 BRIGHT A_FaceTarget;
		TNT1 A 0 A_StartSound("mg/enemygun", 1);
		TNT1 A 0 A_StartSound("mg/enemysg", 4);
		TNT1 A 0 A_CustomMissile("MG_EnemyBullet", 45, 0, random(-8,8), 1, random(-1,1));
		SPID H 2 BRIGHT;
		SPID G 2;
		SPID H 0 BRIGHT A_SpidRefire;
		Goto Missile+1;
	Pain:
		SPID I 3;
		SPID I 3 A_Pain;
		Goto See;
	Death:
		SPID I 1 A_Scream;
		SPID I 1 A_NoBlocking;
		SPID IIIII 13 A_SpawnItemEx("MG_Explosion", random(-64,64), random(-64,64), random(32,120));
		SPID JK 6;
		TNT1 A 0 A_SpawnItemEx("MG_Explosion", random(-64,64), random(-64,64), random(32,120));
		SPID LMN 6;
		TNT1 AAAAA 0 A_SpawnItemEx("MG_Explosion", random(-64,64), random(-64,64), random(32,120));
		TNT1 AAAAAAAAAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleHuge", 50,  0, random(0, 360), 2, random(30, 65));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath1b", 80,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAAA 0 A_CustomMissile("MG_XDeath2", 80,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath3", 80,  0, random(0, 360), 2, random(10, 45));
		SPID OPQR 10;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 10,  0, random(0, 360), 2, random(10, 45));
		SPID S 30;
		SPID S -1 A_BossDeath;
		Stop;
	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushed", 0,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		MGAN F 1;
		MGAN F -1;
		Stop;

	}
}

// ============================================================================
// RS_MGCyberdemon  (Meatgrinder Cyberdemon1)  tint "cyber"
// ============================================================================
class RS_MGCyberdemon : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "Cyberdemon";
		Health 4000;
		Radius 40;
		Height 110;
		Mass 1000;
		Speed 16;
		PainChance 20;
		Monster;
		+FLOORCLIP;
		+BOSS
		+MISSILEMORE
		+FLOORCLIP
		+NORADIUSDMG
		+DONTMORPH
		+BOSSDEATH
		+E2M8BOSS     // last Cyberdemon on E2M8/E4M6 fires the boss special
		+E4M6BOSS
		SeeSound "cyber/sight";
		PainSound "cyber/pain";
		DeathSound "cyber/death";
		ActiveSound "cyber/active";
		Obituary "$OB_CYBORG";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "cyber"; }

	States
	{

	Spawn:
		CYBR AB 10 A_Look;
		Loop;
	See:
		CYBR A 3 A_Hoof;
		CYBR ABBCC 3 A_Chase;
		CYBR D 3 A_Metal;
		CYBR D 3 A_Chase;
		Loop;
	Missile:
		CYBR E 6 A_FaceTarget;
		CYBR F 12 A_CustomMissile("MG_Rocket", 58, -10, 0);
		CYBR E 12 A_FaceTarget;
		CYBR F 12 A_CustomMissile("MG_Rocket", 58, -10, 0);
		CYBR E 12 A_FaceTarget;
		CYBR F 12 A_CustomMissile("MG_Rocket", 58, -10, 0);
		Goto See;
	Pain:
		CYBR G 10 A_Pain;
		Goto See;
	Death:
		CYBR H 0;
		CYBR H 0 A_Scream;
		CYBR H 10;
		CYBR I 6;
		CYBR JKL 6;
		TNT1 AAAAA 0 A_SpawnItemEx("MG_Explosion", random(-64,64), random(-64,64), random(32,120));
		TNT1 AAAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleHuge", 40,  0, random(0, 360), 2, random(30, 65));
		TNT1 AAAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleHuge", 80,  0, random(0, 360), 2, random(30, 65));
		TNT1 A 0 A_CustomMissile("MG_CyberGib1", random(80, 90),  0, random(0, 360), 2, random(30, 65));
		TNT1 A 0 A_CustomMissile("MG_CyberGib2", random(60, 90),  0, random(0, 360), 2, random(30, 65));
		TNT1 A 0 A_CustomMissile("MG_CyberGib3", random(60, 90),  0, random(0, 360), 2, random(30, 65));
		TNT1 A 0 A_CustomMissile("MG_CyberGib4", random(50, 90),  0, random(0, 360), 2, random(30, 65));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath1b", 80,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAAA 0 A_CustomMissile("MG_XDeath2", 80,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath3", 80,  0, random(0, 360), 2, random(10, 45));
		CYBR M 6 A_NoBlocking;
		CYBR NO 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 10,  0, random(0, 360), 2, random(10, 45));
		CYBR P 30;
		CYBR P -1 A_BossDeath;
		Stop;
	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushed", 0,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		MGAN F 1;
		MGAN F -1;
		Stop;

	}
}

// ============================================================================
// RS_MGShotgunner  (Meatgrinder ShotgunGuy1)  tint "sg"
// ============================================================================
class RS_MGShotgunner : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "ShotgunGuy";
		Health 30;
		Radius 20;
		Height 56;
		Speed 8;
		PainChance 170;
		Monster;
		+FLOORCLIP;
		SeeSound "shotguy/sight";
		AttackSound "shotguy/attack";
		PainSound "shotguy/pain";
		DeathSound "shotguy/death";
		ActiveSound "shotguy/active";
		Obituary "$OB_SHOTGUY";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "sg"; }

	States
	{

	Spawn:
		SPOS AB 10 A_Look;
		Loop;
	See:
		SPOS AABBCCDD 3 A_Chase;
		Loop;
	Missile:
		SPOS E 10 A_FaceTarget;
		TNT1 A 0 A_StartSound("mg/enemygun", 1);
		TNT1 A 0 A_StartSound("mg/enemysg", 4);
		TNT1 AAA 0 A_CustomMissile("MG_EnemyBullet", 38, 0, random(-6,6), 1, random(-1,1));
		SPOS F 10 BRIGHT;
		SPOS E 10;
		TNT1 A 0 A_StartSound("mg/stgpump", 4);
		MGBN ABA 4;
		Goto See;
	Pain:
		SPOS G 3;
		SPOS G 3 A_Pain;
		Goto See;

	Death:
		SPOS H 0;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50,  0, random(0, 360), 2, random(60, 90));
		SPOS H 0 A_Jump(192, "Death1", "Death2", "Death3", "Death4", "Death5");
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 40,  0, random(0, 360), 2, random(0, 90));
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(45, 50));
		SPOS H 5;
		SPOS I 5 A_Scream;
		SPOS J 5 A_NoBlocking;
		SPOS K 5;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		SPOS L -1;
		Stop;
	Death1:  //Leg
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 20,  0, random(0, 360), 2, random(0, 90));
		TNT1 A 0 A_CustomMissile("MG_XShotgunnerLeg", 10,  0, random(0, 360), 2, random(40, 50));
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(45, 50));
		MGBL A 6 A_Scream;
		MGBL B 6 A_NoBlocking;
		MGBL CGH 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGBL F -1;
		Stop;
	Death2:  //Arm
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 20,  0, random(0, 360), 2, random(0, 90));
		TNT1 A 0 A_CustomMissile("MG_XDeathArm", 50,  0, random(0, 360), 2, random(40, 60));
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(45, 50));
		MGBM A 6 A_Scream;
		MGBM B 6 A_NoBlocking;
		MGBM CD 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGBM E -1;
		Stop;
	Death3:  //Head
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 AAA 0 A_CustomMissile("MG_GibHeadPiece", 55,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_GibTeeth", 55,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_GibEyeball", 55,  0, random(0, 360), 2, random(45, 50));
		MGBJ B 6 A_Scream;
		MGBJ C 6 A_NoBlocking;
		MGBJ DE 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGBJ E -1;
		Stop;
	Death4:  //Guts
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 30,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 30,  0, random(0, 360), 2, random(10, 45));
		MGB7 A 6 A_Scream;
		MGB7 B 6 A_NoBlocking;
		MGB7 BCD 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGB7 E -1;
		Stop;
	Death5:  //Heavy1
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 30,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 30,  0, random(0, 360), 2, random(10, 45));
		MGB6 A 6 A_Scream;
		MGB6 B 6 A_NoBlocking;
		MGB6 BCD 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGB6 E -1;
		Stop;
	XDeath:
		POSS M 4;
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(30, 90));
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_XDeathArm", 50,  0, random(0, 360), 2, random(40, 60));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		POSS N 5 A_XScream;
		POSS O 5 A_NoBlocking;
		POSS PQRST 5;
		POSS U -1;
		Stop;
	Death.Plasma:
		MGAR A 0 A_Stop;
		MGAR A 0 A_XScream;
		MGAR A 0 A_NoBlocking;
		TNT1 A 0 A_SpawnItem("MG_SmokePillar");
		TNT1 A 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40,  0, random(0, 360), 2, random(10, 45));
		MGAR ABCDEFG 4;
		MGAR H -1;
		Stop;
	Raise:
		SPOS L 5;
		SPOS KJIH 5;
		Goto See;
	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushed", 0,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		MGAN A 1;
		MGAN A -1;
		Stop;

	Death.Saw:
		POSS M 4;
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(30, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40,  0, random(0, 360), 2, random(10, 45));
		POSS N 5 A_XScream;
		POSS O 5 A_NoBlocking;
		POSS PQRST 5;
		POSS U -1;
		Stop;

	}
}

// ============================================================================
// RS_MGChaingunner  (Meatgrinder ChaingunGuy1)  tint "cg"
// ============================================================================
class RS_MGChaingunner : RS_MGMonster
{
	Default
	{
		RS_MGMonster.Family "ChaingunGuy";
		Health 70;
		Radius 20;
		Height 56;
		Speed 8;
		PainChance 170;
		Monster;
		+FLOORCLIP;
		SeeSound "chainguy/sight";
		AttackSound "chainguy/attack";
		PainSound "chainguy/pain";
		DeathSound "chainguy/death";
		ActiveSound "chainguy/active";
		Obituary "$OB_CHAINGUY";
	}

	override void BeginPlay() { Super.BeginPlay(); tintFam = "cg"; }

	States
	{

	Spawn:
		CPOS AB 10 A_Look;
		Loop;
	See:
		CPOS AABBCCDD 3 A_Chase;
		Loop;
	Missile:
		CPOS E 10 A_FaceTarget;
		TNT1 A 0 A_StartSound("mg/enemygun", 1);
		TNT1 A 0 A_StartSound("mg/mgun2", 4);
		TNT1 A 0 A_CustomMissile("MG_EnemyBullet", 38, 0, random(-8,8), 1, random(-1,1));
		CPOS F 1 BRIGHT;
		CPOS E 2;
		CPOS E 1 A_CPosRefire;
		Goto Missile+1;
	Pain:
		CPOS G 3;
		CPOS G 3 A_Pain;
		Goto See;

	Death:
		MGAL A 1;
		TNT1 A 0 A_CustomMissile("MG_CeilingBloodChecker", 50,  0, random(0, 360), 2, random(60, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(45, 50));
		POSS H 0 A_Jump(255, "Death1", "Death2", "Death3");
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 40,  0, random(0, 360), 2, random(0, 90));
	Death1:
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 20,  0, random(0, 360), 2, random(0, 90));
		TNT1 A 0 A_CustomMissile("MG_XDeathBlackArm", 50,  0, random(0, 360), 2, random(40, 60));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_GibHeadPiece", 55,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_GibTeeth", 55,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_GibEyeball", 55,  0, random(0, 360), 2, random(45, 50));
		MGAM A 6 A_Scream;
		MGAM B 6 A_NoBlocking;
		MGAM CDEFG 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGAM H -1;
		Stop;
	Death2:
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 20,  0, random(0, 360), 2, random(0, 90));
		TNT1 A 0 A_CustomMissile("MG_XDeathBlackArm", 50,  0, random(0, 360), 2, random(40, 60));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_GibHeadPiece", 55,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_GibTeeth", 55,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_GibEyeball", 55,  0, random(0, 360), 2, random(45, 50));
		MGA4 A 6 A_Scream;
		MGA4 B 6 A_NoBlocking;
		MGA4 C 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGA4 D -1;
		Stop;
	Death3:  //Head
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 50,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_GibHeadPiece", 55,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_GibTeeth", 55,  0, random(0, 360), 2, random(45, 50));
		TNT1 A 0 A_CustomMissile("MG_GibEyeball", 55,  0, random(0, 360), 2, random(45, 50));
		MGAL B 6 A_Scream;
		MGAL C 6 A_NoBlocking;
		MGAL DE 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGAL F -1;
		Stop;
	Death4:  //Guts
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 30,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 30,  0, random(0, 360), 2, random(10, 45));
		MGB5 A 6 A_Scream;
		MGB5 B 6 A_NoBlocking;
		MGB5 BCD 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGB5 E -1;
		Stop;
	Death5:  //Heavy1
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 30,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2b", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3b", 30,  0, random(0, 360), 2, random(10, 45));
		MGB5 A 6 A_Scream;
		MGB5 B 6 A_NoBlocking;
		MGB5 BCD 6;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		MGB5 E -1;
		Stop;
	XDeath:
		POSS M 4;
		TNT1 AA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(45, 50));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(30, 90));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeathBlackArm", 50,  0, random(0, 360), 2, random(40, 60));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		POSS O 5 A_NoBlocking;
		CPOS P 5 A_XScream;
		CPOS QRST 5;
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 20,  0, random(0, 360), 2, random(10, 45));
		CPOS T -1;
		Stop;
	Death.Plasma:
		MGAR A 0 A_Stop;
		MGAR A 0 A_XScream;
		MGAR A 0 A_NoBlocking;
		TNT1 A 0 A_SpawnItem("MG_SmokePillar");
		TNT1 A 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40,  0, random(0, 360), 2, random(10, 45));
		MGAR ABCDEFG 4;
		MGAR H -1;
		Stop;
	Raise:
		CPOS N 5;
		CPOS MLKJIH 5;
		Goto See;
	Crush:
		TNT1 AAAAAAAAAA 0 A_CustomMissile("MG_FlyingBloodParticleCrushed", 0,  0, random(0, 360), 2, random(0, 90));
		TNT1 AA 0 A_CustomMissile("MG_XDeath2", 50,  0, random(0, 360), 2, random(10, 45));
		TNT1 AA 0 A_CustomMissile("MG_XDeath3", 50,  0, random(0, 360), 2, random(10, 45));
		MGAN A 1;
		MGAN A -1;
		Stop;

	Death.Saw:
		POSS M 4;
		TNT1 AA 0 A_CustomMissile("MG_FlyingBloodParticleFast", 60,  0, random(0, 360), 2, random(0, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 50,  0, random(0, 360), 2, random(30, 90));
		TNT1 AAA 0 A_CustomMissile("MG_FlyingBloodParticleBig", 30,  0, random(0, 360), 2, random(10, 45));
		TNT1 AAA 0 A_CustomMissile("MG_XDeath1b", 40,  0, random(0, 360), 2, random(10, 45));
		TNT1 A 0 A_CustomMissile("MG_XDeath1", 40,  0, random(0, 360), 2, random(10, 45));
		POSS N 5 A_XScream;
		POSS O 5 A_NoBlocking;
		POSS PQRST 5;
		POSS U -1;
		Stop;

	}
}
