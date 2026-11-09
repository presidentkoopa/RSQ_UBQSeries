// =====================================================================
// RS_MonsterMaster -- the monster-side parallel of RS_Weapon.
// ---------------------------------------------------------------------
// Owns three things and nothing else:
//
//   TIER     numeric 00..12 (+ EX via TierLocked). Runtime-safe,
//            idempotent, re-callable mid-fight.
//   BODY     which sprite (and which TRNSLATE colour) this monster
//            wears at this tier, as DATA -- two space-delimited
//            strings in ladder order.
//   ATTACKS  an RS_AttackSlot per tier (RS_AttackProfile.zs, same
//            structure the guns use).
//
// Content-free. No monster behaviour lives here.
//
// WHY THE BODY STRING: the previous port wrote Spawn/See/Pain/Death out
// once per tier -- thirteen near-identical blocks whose only difference
// was a four-letter sprite name. Measured across all 19 family files
// that was about three quarters of every file. Here the base owns one
// set of states and the family supplies thirteen sprite names on one
// line. A family that genuinely needs a bespoke tier still overrides
// the state outright; the table is the default, not a cage.
//
// The sprite and colour are applied on TIER CHANGE, not on state entry.
// A monster's body doesn't change because it took a step.
//
// It used to also declare three empty per-family base classes
// (RS_HumanMonster, RS_DemonBase, RS_KnightBase). They were removed on
// 2026-08-04 -- see the note at the bottom of this file for why, and for
// what to do instead if family grouping is ever actually wanted.
// =====================================================================

class RS_MonsterTierRow
{
	// ABSOLUTE, HAND-ASSIGNED STATS -- the preferred way to state a tier.
	//
	// A tier is not a point on a curve. Colourful Hell and CHP hand-tuned
	// every colour's health and speed individually, and every tier we add
	// from here (TEX and whatever packs follow) is authored the same way:
	// somebody decides this creature has 5000 HP because that is what it
	// should have, not because 5000 is what the formula produced.
	//
	// Set hp/speed > 0 and they are used verbatim. Leave them 0 and the
	// multipliers below apply instead, recomputed from the actor's
	// Defaults. Writing the real number is clearer and cannot drift, so
	// prefer it -- the multiplier path exists for the generic base ladder
	// and for anything that genuinely wants to scale off a default.
	int    hp;
	int    speed;

	double hpMul;
	double spdMul;
	int    painChance;

	// Stored, NOT auto-applied. hp/speed/painChance are plain Actor
	// properties we can safely rescale here. Outgoing damage is not --
	// scaling it would mean reaching into every vanilla attack action on
	// every monster. It is data the monster's own attack code reads and
	// applies. Do not read this as "damage scaling is wired." It isn't.
	double dmgMul;

	// =================================================================
	// THE CH PARENT PROPERTIES.  Added 2026-08-05, and this is the half
	// of the port that was missing for three attempts.
	//
	// CHP's actors are `ACTOR CommonRedZombie : RedZombie` -- the STATES
	// are CHP's, but every combat PROPERTY lives on the CH parent in
	// CH/decorate/<Family>.txt. The port transcribed the states
	// faithfully and took none of the parents, so all fourteen tiers ran
	// with one identical flag set and only hp/speed/painChance varying.
	// That is why every tier played like a plain zombieman no matter
	// which creature was on screen: +MISSILEMORE was missing from the
	// ten tiers that have it, +AVOIDMELEE from the eleven that have it.
	//
	// EVERY FIELD HERE IS "LEAVE ALONE" AT ITS ZERO VALUE, because
	// ApplyTier runs on every retier and must be able to state a tier
	// absolutely -- a flag T03 sets has to be CLEARED when the monster
	// becomes T04. Flags are therefore assigned, never OR'd.
	int    flags;         // RS_TF_* bitmask
	string species;       // "" = leave alone
	double radius;        // 0 = leave alone
	double height;        // 0 = leave alone
	double mass;          // 0 = leave alone
	double scale;         // 0 = leave alone
	int    gibHealth;     // 0 = leave alone
	// RECORDED, NOT APPLIED -- deliberately, and this is not an omission.
	// BloodColor is a `color` field, and setting it at runtime does
	// nothing on its own: the engine bakes BloodTranslation at class-init
	// from the DECORATE property, and that is what actually tints blood.
	// The CH values are transcribed here because they are ground truth
	// and finding them again costs a read of CH/decorate; applying them
	// needs a BloodTranslation rebuild, which is its own job.
	string bloodColor;
	// 1.0 = normal, 0.5 = +MISSILEMORE, 0.125 = +MISSILEEVENMORE,
	// 0.0625 = BOTH (CH stacks them on Benellus and the Arachnotron set).
	// LOWER FIRES MORE -- it scales the "don't fire" distance roll.
	// 0 = leave alone.
	double missileChance;
	// Splash taken, as a multiplier. Added for family 02: CH's shotgunner
	// bosses span 0.33 (the Crew Commander shrugs it off) to 2.0 (Green
	// Benellus is a balloon), which is a wider spread than any stat in the
	// hp table. 0 = leave alone.
	double radiusDamageFactor;

	// --- Added for families 05/07/09 (LostSoul, Spectre, Cacodemon) ---
	//
	// RS_TF_* ran out of bits at 23, so the ghost/floater flags live in a
	// second word. Both are assigned absolutely, same rule as flags.
	int    flags2;        // RS_TF2_* bitmask

	// TRANSPARENCY IS IDENTITY IN THESE FAMILIES, not decoration. CH's
	// gray spectre sits at Alpha 0.05 and the black at 0.45 -- one is
	// nearly invisible and the other is merely dim, and they are the same
	// creature otherwise. 0 = leave alone.
	double alpha;
	// -1 = leave alone. Use the STYLE_* constants.
	int    renderStyle;

	// CH varies these per tier and they change the fight: the red spectre
	// reaches 78 where the common reaches 54. 0 = leave alone.
	double meleeRange;
	double meleeThreshold;
	double maxTargetRange;
	double floatSpeed;

	// DamageFactor None -- the untyped-damage multiplier, i.e. most
	// weapons. CH's black cacodemon carries None,1.5 and CHP neutralises
	// it to 1.0; missing that override makes the boss half again as
	// fragile as intended. 0 = leave alone.
	double noneDamageFactor;
}

// Tier flag bits. Plain file-scope consts, NOT a static const array --
// array literals do not reliably resolve on this build (CLAUDE.md).
// Named for what CH writes, so a reader can diff this against
// CH/decorate/<Family>.txt without a translation step.
const RS_TF_AVOIDMELEE       = 1;
const RS_TF_DONTHARMSPECIES  = 2;
const RS_TF_THRUSPECIES      = 4;
const RS_TF_NOINFIGHTING     = 8;
const RS_TF_NOTARGETSWITCH   = 16;
const RS_TF_ROLLSPRITE       = 32;
const RS_TF_NOICEDEATH       = 64;
const RS_TF_EXTREMEDEATH     = 128;
const RS_TF_BOSS             = 256;
const RS_TF_QUICKTORETALIATE = 512;
const RS_TF_LOOKALLAROUND    = 1024;
const RS_TF_NOFEAR           = 2048;
const RS_TF_DONTMORPH        = 4096;
// CH writes `-NORADIUSDMG` on all three bosses -- they DO take splash.
// Spelled positively here so the zero value stays "leave alone".
const RS_TF_TAKESRADIUSDMG   = 8192;
const RS_TF_NOTARGET         = 16384;
const RS_TF_LAXTELEFRAGDMG   = 32768;
const RS_TF_DONTHARMCLASS    = 65536;
const RS_TF_NOBLOOD          = 131072;
// The hover set. CH gives Benellus (family 02 T12/TEX) +FLOAT +NOGRAVITY
// +FLOATBOB -- the God of Shotguns does not walk. A previous pass noted
// these as "Default-only properties with no per-tier setter"; this is
// the setter.
const RS_TF_NOGRAVITY        = 262144;
const RS_TF_FLOAT            = 524288;
const RS_TF_FLOATBOB         = 1048576;
const RS_TF_BOSSDEATH        = 2097152;
const RS_TF_SEEINVISIBLE     = 4194304;
const RS_TF_NOTIMEFREEZE     = 8388608;
// Seeker missiles cannot lock onto it. Unique to the abyss imp in
// family 03. Bit 24 -- the first word still has bits 24-30 free before
// the sign bit, which is why RS_TF2_* starts over rather than
// continuing here.
const RS_TF_CANTSEEK         = 16777216;

// SECOND FLAG WORD. RS_TF_* stops at bit 23 and int is signed 32-bit, so
// the ghost/floater set added for families 05/07/09 lives here rather
// than risking the sign bit. Assigned absolutely, same as RS_TF_*.
const RS_TF2_STEALTH            = 1;
const RS_TF2_SHADOW             = 2;
const RS_TF2_VISIBILITYPULSE    = 4;
const RS_TF2_SHORTMISSILERANGE  = 8;
const RS_TF2_SPAWNCEILING       = 16;
const RS_TF2_SPAWNFLOAT         = 32;
const RS_TF2_DONTFALL           = 64;
const RS_TF2_NOPAIN             = 128;
const RS_TF2_DONTOVERLAP        = 256;
const RS_TF2_NOBLOODDECALS      = 512;
const RS_TF2_NOTARGETSWITCH     = 1024;

class RS_MonsterMaster : Actor abstract
{
	// --- Tier ---
	int    Tier;
	double TierDamageMul;   // see RS_MonsterTierRow.dmgMul -- data only
	// This tier's CH GibHealth, 0 = unstated. Held rather than assigned
	// because the engine's GibHealth is readonly; GetGibHealth() serves it.
	int    rsTierGibHealth;
	// DamageFactor None -- the untyped multiplier. 0 = unstated.
	double rsTierNoneFactor;

	// The health ceiling for our CURRENT tier. Tracked ourselves rather
	// than read back from the engine: we rescale health per tier, so the
	// actor's spawn health is the T00 default and would give the wrong
	// answer everywhere a fraction or a threshold is computed. Set in
	// ApplyTier, read by the retier fraction, CheckThreshold, and the
	// support-aura heal.
	int TierMaxHealth;

	// Cached Defaults, captured once. ALL scaling recomputes from these,
	// never from current values, so tier-up-then-down cannot drift or
	// compound however many times the dial moves.
	private int    rsBaseHealth;
	private double rsBaseSpeed;
	private int    rsBasePainChance;
	private bool   rsBaseCaptured;

	// --- Body / tint ---
	// BodyTable() is now DOCUMENTATION + AUDIT data only: the actual
	// bodies are real per-tier state clusters (See.T03, Missile.T03...)
	// with literal sprites, dispatched by TierState(). The sprite field
	// is never assigned at runtime -- that was the skin-system bug that
	// made monsters flash zombieman frames. TintTable() is still LIVE
	// data: translations apply on tier change in RS_ApplyTint().
	private Array<string> rsBodies;   // parsed BodyTable(), cached
	private Array<string> rsTints;    // parsed TintTable(), cached
	private bool rsTablesParsed;

	// Deferred state jump, applied in Tick where SetState is legal.
	// Set by ApplyTier after a tier change ("See.T05" if fighting,
	// "Spawn.T05" if idle); consumed exactly once. Jumping states from
	// a handler/inventory context silently fails -- this is the
	// HF-proven safe route.
	private string pendingStateJump;

	// --- Staggered transform ---
	private bool   rsTransforming;
	private int    rsPendingTier;
	private int    rsPendingTic;
	private int    rsTransformStart;   // when the tell began (for the accelerating flash)
	private int    rsXfOldTier;        // body we're transforming FROM (display only)
	private int    rsFlashPhase;       // beat counter: even=gold, odd=a real body
	private int    rsNextBeat;         // next flicker beat, shrinks as the snap nears

	// --- Enrage tell ---
	// The enrage roar (vile/sight) is the only signal an enraged monster
	// gives, and the owner cannot hear it mid-firefight. These drive a
	// SILVER pulse that also doubles as a health readout: the closer to
	// death, the faster it blinks. Silver, never gold -- gold is already
	// the transform tell above and one colour must not mean two things.
	// NAMED FOR THE TELL, NOT THE STATE, and not merely to dodge a
	// collision. The plain name was already taken TWICE by subclasses
	// meaning two different things: RS_Imp.zs:48 marks the T10 Primal's
	// real speed-up (which never calls Enrage()), and RS_Revenant.zs:97
	// is CH's User_Enrage carried over as a two-stage MISSILE gate, not
	// an enrage at all. Three meanings on one name is how a codebase
	// stops being readable, so these three own the narrowest one: the
	// visual. ZScript has no shadowing -- a subclass field silently
	// colliding with a base field is a hard redefinition error.
	private bool rsEnrageTellOn;
	private int  rsEnrageTellBeat;     // next pulse beat
	private int  rsEnrageTellPhase;    // even = silver, odd = the tier's own tint

	// --- Attacks ---
	RS_AttackSlot CurrentAttacks;
	private int   rsAttacksBuiltFor;

	// --- Behaviour primitives (see the PRIMITIVES section below) ---
	// One-shot threshold guards, as a bitmask rather than an array of
	// bools: 32 independent slots, and no array-in-class-body risk.
	private int rsThresholdFlags;

	// Timed stat pulse.
	private bool   rsPulseActive;
	private int    rsPulseEndTic;
	private double rsPulseBaseSpeed;
	private double rsPulseBaseDamageMul;
	private bool   rsPulseSetNoPain;

	// Phase dodge / blink.
	private bool   rsDodgeActive;
	private int    rsDodgeEndTic;
	private double rsDodgeBaseSpeed;
	private double rsDodgeBaseAlpha;
	private int    rsDodgeBaseStyle;
	private bool   rsDodgeSetNoPain;

	// Generic escalation counter. CHP builds half its boss behaviour on
	// one of these (Archvile's charge portal, courage meters, live-pack
	// limits, combo stacks). One int plus helpers covers all of them.
	int ChargeCounter;

	Default
	{
		Monster;
	}

	// =================================================================
	// THE DIAL -- WHICH CREATURE A MAP SPAWN ACTUALLY BECOMES.
	//
	// THE BUG THIS EXISTS TO FIX, and it is the largest one in the
	// project: NOTHING HAS EVER ASSIGNED A SPAWN TIER. `Tier` is not a
	// ZScript Property, so no Default block can set it, and every
	// SetTier() call site is a REACTION to something -- self-enrage,
	// abyss conversion, summon inheritance, a portal, the debug menu.
	// A monster placed in a map therefore spawns Tier 0 and stays there
	// forever. Eight sessions built tiers 1..12 across 238 monsters and
	// the ONLY way anyone has ever seen any of it is the debug menu.
	// That is also why four families could ship ported off the wrong
	// actor without anyone noticing in play: nobody could reach them.
	//
	// Under the CH rebuild each creature is its own class, so the dial
	// picks a CLASS, not a ladder position. One roll, at spawn, once.
	//
	// A family opts in by overriding SpawnRoster(). Families that have
	// not been rebuilt yet return false and are completely unaffected.
	// =================================================================
	private bool rsRolled;

	// A family's spawn table, declared the way RS_MonsterCatalog already
	// declares its rosters (ROSTER_VileConjure / ROSTER_VileConjureCount)
	// -- three plain virtuals over simple types. Deliberately NOT an
	// `out Array<>` parameter and NOT a `static const [] literal`:
	// CLAUDE.md records that array literals do not reliably resolve on
	// this engine build, and it has been rediscovered three times.
	// Weights are CH's own -- do not invent them.
	virtual int    SpawnRosterCount()          { return 0;  }
	virtual string SpawnRosterPick(int i)      { return ""; }
	virtual int    SpawnRosterWeight(int i)    { return 0;  }

	// Weighted pick, then become it. Returns true if we handed off.
	private bool RS_RollSpawnClass()
	{
		int n = SpawnRosterCount();
		if (n <= 0) return false;

		int total = 0;
		for (int i = 0; i < n; i++)
			total += max(0, SpawnRosterWeight(i));
		if (total <= 0) return false;

		int roll = random(0, total - 1), acc = 0, hit = -1;
		for (int i = 0; i < n; i++)
		{
			acc += max(0, SpawnRosterWeight(i));
			if (roll < acc) { hit = i; break; }
		}
		if (hit < 0) return false;

		Class<Actor> nc = SpawnRosterPick(hit);
		// Rolling ourselves is the common case and must NOT respawn --
		// that would be an actor churn every time the dial lands home.
		if (!nc || nc == GetClass()) return false;

		let a = RS_MonsterMaster(Actor.Spawn(nc, pos, ALLOW_REPLACE));
		if (!a) return false;

		// The replacement is the map's monster: carry placement, not
		// combat state. There is no fight yet -- this runs at spawn.
		a.angle     = angle;
		a.bAMBUSH   = bAMBUSH;
		a.bFRIENDLY = bFRIENDLY;
		a.special   = special;
		a.args[0] = args[0]; a.args[1] = args[1]; a.args[2] = args[2];
		a.args[3] = args[3]; a.args[4] = args[4];
		if (tid != 0) a.ChangeTid(tid);

		// Belt and braces. Actor.Spawn has ALREADY run the replacement's
		// PostBeginPlay by the time we get here, so this assignment does
		// not gate that call -- what actually prevents a re-roll is that
		// only the family's ENTRY class overrides the roster, and the
		// `nc == GetClass()` guard above means the entry class is never
		// what we spawn. This flag is the second lock, for the day
		// someone writes a roster that can name its own owner.
		a.rsRolled = true;

		Destroy();
		return true;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		// Before anything else -- if this spawn is going to become a
		// different creature, do it now and let the replacement run its
		// own PostBeginPlay.
		if (!rsRolled)
		{
			rsRolled = true;
			if (RS_RollSpawnClass())
				return;
		}

		if (!rsBaseCaptured)
		{
			let def = GetDefaultByType(GetClass());
			rsBaseHealth     = def.Health;
			rsBaseSpeed      = def.Speed;
			rsBasePainChance = def.PainChance;
			rsBaseCaptured   = true;
		}

		rsAttacksBuiltFor = -1;
		ApplyTier(true);
	}

	// EX / SetPiece monsters ignore the ambient dial and keep their
	// hand-authored Default stats. Override to true.
	virtual bool TierLocked()
	{
		return false;
	}

	// Public entry. Safe to call repeatedly, safe mid-swing.
	//
	// STAGGERED TRANSFORM. A retier is NOT applied on the spot unless
	// asked for. Each monster picks a short random delay first, for two
	// reasons that both matter:
	//   (a) retiering a room full of monsters spreads the recompute over
	//       many tics instead of spiking one frame. This is a load
	//       balancer, not decoration.
	//   (b) it reads as an event. A monster that flashes for a moment
	//       and THEN changes looks deliberate; one that snaps looks
	//       like a bug.
	//
	// The tell is a plain additive RenderStyle flash -- a built-in
	// engine feature, no lump or external data required. Deliberately
	// NOT a named palette flash: the previous template flashed via
	// A_SetTranslation with names defined in no TRNSLATE lump anywhere,
	// which silently no-opped.
	void SetTier(int t, bool instant = false)
	{
		if (TierLocked())
			return;

		int want = clamp(t, 0, MaxTier());
		if (want == Tier && rsAttacksBuiltFor == Tier)
			return;

		if (instant || !RS_MonOpt("rs_mon_transform_tell", true))
		{
			int old = Tier;
			Tier = want;
			ApplyTier(instant);
			if (old != Tier)
				OnRetier(old, Tier);
			return;
		}

		// Re-targetable: a second call mid-stagger just changes the
		// destination, it doesn't queue a second transform.
		rsPendingTier = want;
		if (!rsTransforming)
		{
			rsTransforming   = true;
			rsXfOldTier      = Tier;
			rsTransformStart = level.time;
			// Random length, never longer than 3 seconds (105 tics).
			rsPendingTic     = level.time + random(45, 105);
			rsFlashPhase     = -1;
			rsNextBeat       = level.time;
		}
	}

	// Runs the staggered transform. Called from Tick.
	//
	// THE TELL, owner-specified: the monster alternates between the body
	// it IS and the body it is BECOMING, with a gold flash on every
	// beat between --
	//
	//     old -> GOLD -> new -> GOLD -> old -> GOLD -> new -> ...
	//
	// slow at first and accelerating into the snap. Total length is
	// random per monster and never exceeds 3 seconds (105 tics), so a
	// retiered room ripples instead of snapping, and each monster reads
	// as a 90s beat-em-up boss winding up.
	//
	// Beat length shrinks from ~10 tics to 1 as the deadline nears; the
	// acceleration IS the signal that something is about to change.
	// --- LEAD FIRE -----------------------------------------------------
	//
	// Fire a projectile at where the target WILL BE, not where it is.
	//
	// This is CH's ProjInt_Brute, and it is the reason RS_MonsterAim.zs
	// exists -- that file's header says so and then notes it is "not
	// wired into any monster yet". It has had ZERO callers since it was
	// written. This is the caller.
	//
	// CH routes four scripts through ProjInt_Brute -- BaronMissile,
	// CybMissile, ImpMissile, FatMissile -- and gates every one behind
	// CallACS("CH_Intercept"), a plain cvar read, with a Miss2 state as
	// the fallback when it is off. THE IMPORT KEPT Miss2 AND DROPPED THE
	// GATED BRANCH, so every monster in this tree has been permanently
	// behaving as though intercept were switched off. RS_Baron's
	// Missile.T00 still ends in a bare `Goto Missile.T00.Miss2` -- a jump
	// with nothing left to choose between.
	//
	// Returns false when it did not fire, so a state can fall through to
	// its own Miss2 exactly the way CH's does.
	bool FireLeadShot(class<Actor> proj, double zoff = 32.0, double xoff = 0.0)
	{
		if (!proj || !target)
			return false;

		// The cvar is CH_Intercept's equivalent, kept as a real option
		// because CH shipped it as one.
		let cv = CVar.GetCVar("rs_monster_intercept", null);
		if (cv && !cv.GetBool())
			return false;

		// Speed comes off the projectile's own defaults rather than a
		// hand-passed number: CH passes speed explicitly and then has to
		// keep it in sync with the actor, which is how those four scripts
		// ended up with 10.0 / 15.0 / 20.0 hardcoded three different ways.
		let pd = GetDefaultByType(proj);
		double spd = pd ? pd.Speed : 0.0;
		if (spd <= 0.0)
			return false;

		double ang, pit;
		RS_MonsterAim.GetLeadAngle(self, target, spd, ang, pit);

		// Absolute angle AND pitch -- GetLeadAngle returns a world-space
		// solution, not an offset from where we happen to be facing.
		A_SpawnProjectile(proj, zoff, xoff, ang,
			CMF_ABSOLUTEANGLE | CMF_ABSOLUTEPITCH | CMF_AIMDIRECTION, pit);
		return true;
	}

	// Turn on the silver pulse WITHOUT touching stats.
	//
	// Enrage() is the packaged version -- speed, bNOPAIN and a halved
	// MissileChanceMult together. Plenty of monsters escalate through
	// their own one-shot flag instead and never call it: the T10 Primal
	// imp just does A_SetSpeed(14), and CH's User_Rage / User_RageUP /
	// User_rage gates unlock a harder attack rather than changing stats.
	// Those are still the thing the player needs to see coming, so the
	// tell gets its own door. Calling this NEVER changes behaviour --
	// it only makes an escalation that already happened legible.
	//
	// ONE-SHOT ESCALATIONS ONLY. Do not hang this on a fill-and-drain
	// meter (RS_Mancubus.rsRage drains by 50, RS_Mastermind.rsRageMind by
	// 8): a pulse that switches off again is noise, not a signal.
	void MarkEnrageTell()
	{
		if (rsEnrageTellOn)
			return;
		rsEnrageTellOn   = true;
		rsEnrageTellBeat = level.time;
	}

	// --- ENRAGE TELL ---------------------------------------------------
	//
	// A silver pulse whose RATE IS THE HEALTH BAR: slow while the monster
	// is still healthy, frantic as it dies. Owner's spec, 2026-08-04 --
	// "if it is enraged and hasn't taken damage, there is a slow flash,
	// and as it takes damage it flashes more and more."
	//
	// Reuses the accelerating-beat shape already proven by the transform
	// tell above, but drives the beat from HEALTH rather than from a
	// countdown, so it reads continuously instead of announcing once.
	//
	// It yields to the transform tell rather than competing with it: two
	// systems writing A_SetTranslation on the same actor would fight, and
	// a tier change is the more important thing to be able to see.
	private void RS_TickEnrageTell()
	{
		if (!rsEnrageTellOn)
			return;

		// Dead: hand the body back its own colour so a corpse is never
		// left frozen mid-flash, and stop.
		if (health <= 0)
		{
			rsEnrageTellOn = false;
			RS_ApplyTint();
			return;
		}

		// The transform tell owns the translation while it runs.
		if (rsTransforming || level.time < rsEnrageTellBeat)
			return;

		// Opt-out. Restore the tier colour on the way out so switching it
		// off mid-fight cannot strand a monster wearing silver.
		let cv = CVar.GetCVar("rs_monster_enragetell", null);
		if (cv && !cv.GetBool())
		{
			if ((rsEnrageTellPhase & 1) == 0)
				RS_ApplyTint();
			rsEnrageTellBeat = level.time + 35;
			return;
		}

		// SAME denominator CheckThreshold uses. A tiered monster's
		// TierMaxHealth is not its SpawnHealth, so measuring against the
		// wrong one would make the pulse disagree with the very threshold
		// that started it -- fast at full health on a high tier, or barely
		// moving at death on a low one.
		int maxhp = TierMaxHealth > 0 ? TierMaxHealth : SpawnHealth();
		double frac = (maxhp > 0) ? clamp(double(health) / double(maxhp), 0.0, 1.0) : 1.0;

		// 35 tics per beat at full health down to 3 at death. Enrage fires
		// at the half-health threshold, so in practice this opens around
		// 19 and tightens from there -- a visibly quickening pulse.
		rsEnrageTellBeat = level.time + clamp(int(3 + frac * 32), 3, 35);

		rsEnrageTellPhase++;
		if ((rsEnrageTellPhase & 1) == 0)
			A_SetTranslation("rs_enrage_flash");
		else
			RS_ApplyTint();   // back to whatever this tier actually wears
	}

	// =================================================================
	// PROMOTION BY ACTOR SWAP -- the CH-native retier.
	//
	// SetTier() moves a monster along a ladder inside ONE class. That is
	// not how CH promotes and it is not how this tree is built any more:
	// under the CH rebuild each creature is its OWN class, so becoming
	// the next creature means becoming a different actor.
	//
	// CH does exactly this itself. Its `Grow` state spawns the next
	// colour and calls A_Die; its Abyss conversion plays an animation and
	// spawns the abyss body. Every previous import copied that as a raw
	// A_SpawnItemEx + A_Die, which loses EVERYTHING -- the promoted
	// monster forgets who it was fighting and comes back at full health,
	// which reads as "a fresh monster appeared", not "that one changed".
	//
	// This routes the swap through the SAME gold-flash tell as SetTier,
	// so a promotion looks like a promotion. It is also what the floor-
	// glow / hotspot promotions need: one helper, one visual language.
	// =================================================================
	private Class<Actor> rsSwapTo;

	void RS_PromoteTo(Class<Actor> nc, bool instant = false)
	{
		if (!nc || health <= 0 || TierLocked())
			return;

		if (instant || !RS_MonOpt("rs_mon_transform_tell", true))
		{
			RS_DoActorSwap(nc);
			return;
		}

		// Re-targetable exactly like SetTier's tell: a second call mid-
		// stagger changes the destination rather than queueing a second
		// transform.
		rsSwapTo = nc;
		if (!rsTransforming)
		{
			rsTransforming   = true;
			rsXfOldTier      = Tier;
			rsPendingTier    = Tier;      // no ladder move; the CLASS changes
			rsTransformStart = level.time;
			rsPendingTic     = level.time + random(45, 105);
			rsFlashPhase     = -1;
			rsNextBeat       = level.time;
		}
	}

	// Carry the fight across the swap. Without this the promotion reads as
	// a teleport-in: new monster, full health, no idea who shot it.
	private void RS_DoActorSwap(Class<Actor> nc)
	{
		let a = RS_MonsterMaster(Actor.Spawn(nc, pos, ALLOW_REPLACE));
		if (!a)
		{
			// No room. Better to stay what we are than vanish.
			rsSwapTo = null;
			rsTransforming = false;
			A_SetTranslation("");
			return;
		}

		a.angle    = angle;
		a.pitch    = pitch;
		a.vel      = vel;
		a.target   = target;
		a.master   = master;
		a.tracer   = tracer;
		a.threshold = threshold;
		a.bAMBUSH  = bAMBUSH;
		a.bFRIENDLY = bFRIENDLY;
		a.special  = special;
		// tid is READ-ONLY in ZScript -- assigning it is a compile error
		// ("Expression must be a modifiable value"). ChangeTid is the
		// only legal way to move it, and it keeps the tid hash correct,
		// which a raw assignment would not have done anyway.
		if (tid != 0)
			a.ChangeTid(tid);

		// Health as a FRACTION, not an absolute -- the creatures either
		// side of a promotion have wildly different maxima (CH's common
		// captain is 70, its General is 4500), so copying the number
		// either one-shots the new body or heals it to nothing.
		if (RS_MonOpt("rs_mon_retier_preserve_fraction", true))
		{
			let def = GetDefaultByType(nc);
			int mx = def ? def.Health : a.health;
			double frac = (SpawnHealth() > 0)
			            ? double(health) / double(SpawnHealth()) : 1.0;
			a.health = max(1, int(mx * clamp(frac, 0.0, 1.0)));
		}

		rsSwapTo = null;
		A_SetTranslation("");
		Destroy();
	}

	private void RS_TickTransform()
	{
		if (!rsTransforming)
			return;

		if (level.time < rsPendingTic)
		{
			if (level.time < rsNextBeat)
				return;

			int remain = rsPendingTic - level.time;
			// 10 tics per beat at the start, tightening to 1 at the end.
			int beat = clamp(remain / 8, 1, 10);
			rsNextBeat = level.time + beat;

			rsFlashPhase++;
			// Even phases flash; odd phases show a real body.
			//
			// COLOUR CARRIES THE MEANING, and the three do not overlap:
			//   GOLD   = tier transform (same creature, moved along its
			//            own ladder)
			//   COPPER = PROMOTION (this creature is about to become a
			//            DIFFERENT creature -- an actor swap)
			//   SILVER = enrage, handled separately in RS_TickEnrageTell
			// See TRNSLATE.txt. One signal, one meaning.
			if ((rsFlashPhase & 1) == 0)
			{
				A_SetTranslation(rsSwapTo ? "rs_copper_flash"
				                          : "rs_gold_flash");
			}
			else
			{
				A_SetTranslation("");
				// A class swap has no "new body" on THIS actor to flick
				// to -- the new creature is a different class entirely --
				// so a promotion pulses copper against its own body
				// instead of alternating. The acceleration still carries
				// the "something is about to happen" signal.
				if (!rsSwapTo)
					RS_ShowBody(((rsFlashPhase >> 1) & 1) == 0 ? rsXfOldTier : rsPendingTier);
			}
			return;
		}

		// A pending class swap ends the tell by BECOMING the other
		// creature, not by moving along this one's ladder.
		if (rsSwapTo)
		{
			rsTransforming = false;
			rsFlashPhase   = -1;
			RS_DoActorSwap(rsSwapTo);
			return;
		}

		int old = Tier;
		Tier = rsPendingTier;
		rsTransforming = false;
		rsFlashPhase   = -1;
		ApplyTier(false);   // commits stats, tint, attacks and the real body

		if (old != Tier)
			OnRetier(old, Tier);
	}

	virtual void OnTierApplied(int t) {}
	virtual void OnRetier(int oldTier, int newTier) {}

	// ------------------------------------------------------------------
	// A SWEEP FRONT REACHED THIS MONSTER.
	//
	// Actor.OnSweepCrossed is an engine hook that is empty on Actor, so
	// this override is the ONLY thing that connects a sweep to the tier
	// ladder. Neither mod references the other: the sweep calls a method
	// every actor has, and this decides what it means for a monster.
	// Either one loads alone.
	//
	// THE COLOUR IS THE INSTRUCTION. The tier ladder is a colour ladder --
	// CH's own icon index -- so a blue sweep asking for blue monsters is
	// not a metaphor, it resolves to the blue rung. Nearest wins, so any
	// sweep colour lands on a real tier.
	//
	// NOT instant. The staggered neutral/gold/neutral tell is the whole
	// point of driving this from a wave, and SetTier already handles
	// being called again mid-transform by re-targeting rather than
	// queueing a second one.
	// ------------------------------------------------------------------
	void OnSweepCrossed(Vector3 origin, double front, Color tint)   // RSQ (Quest): was "override"; the engine hook exists only on UZDXREMA, so on stock QZD 17.3 nothing calls it
	{
		if (health <= 0 || TierLocked()) return;

		let cv = CVar.FindCVar("rss_fx_tier");
		if (!cv || !cv.GetBool()) return;

		let byCol = CVar.FindCVar("rss_fx_tier_bycolour");
		if (!byCol || byCol.GetBool())
		{
			SetTier(RS_TierForColour(tint, MaxTier()));
			return;
		}

		let st = CVar.FindCVar("rss_fx_tier_step");
		int step = st ? st.GetInt() : 1;
		if (step != 0) SetTier(Tier + step);
	}

	// The ladder as colours, for matching a sweep's colour to a rung.
	// Representative values only -- they exist to be told apart, not to
	// tint anything, and the real tinting is still TintTable's job.
	static int RS_TierForColour(Color c, int maxTier)
	{
		int best = 1;
		double bestD = 1e30;
		for (int t = 1; t <= maxTier; t++)
		{
			int r = 160, g = 160, b = 160;
			if      (t == 1)  { r = 200; g = 200; b = 200; }   // Common
			else if (t == 2)  { r =  60; g = 220; b =  70; }   // Green
			else if (t == 3)  { r =  60; g = 120; b = 255; }   // Blue
			else if (t == 4)  { r = 170; g =  70; b = 230; }   // Purple
			else if (t == 5)  { r = 255; g = 200; b =  40; }   // Yellow
			else if (t == 6)  { r = 230; g =  40; b =  40; }   // Red
			else if (t == 7)  { r =  40; g = 160; b = 220; }   // FireBlu
			else if (t == 8)  { r = 130; g = 130; b = 130; }   // Gray
			else if (t == 9)  { r =  70; g =  20; b = 110; }   // Abyss
			else if (t == 10) { r =  25; g =  25; b =  25; }   // Black
			else if (t == 11) { r = 255; g = 255; b = 255; }   // White
			else if (t == 12) { r =  60; g = 240; b = 240; }   // Cyan
			else if (t == 13) { r = 140; g =  90; b =  40; }   // Brown / TEX
			double dr = c.r - r, dg = c.g - g, db = c.b - b;
			double d = dr * dr + dg * dg + db * db;
			if (d < bestD) { bestD = d; best = t; }
		}
		return best;
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage,
	                        Name mod, int flags, double angle)
	{
		double fac = TierDamageFactor(Tier, mod);
		// CH writes `DamageFactor None,x` -- the multiplier for UNTYPED
		// damage, i.e. most weapons. The black cacodemon carries None,1.5
		// and CHP neutralises it to 1.0; the gray mancubus carries a bare
		// global 0.65 that CHP likewise cancels. Missing either override
		// misprices the monster by a third or more.
		if (fac == 1.0 && rsTierNoneFactor > 0 && mod == 'None')
			fac = rsTierNoneFactor;
		if (fac != 1.0)
		{
			damage = int(damage * fac);
			// A factor of 0 means immune, and that has to survive the
			// int truncation above -- otherwise a 1-damage hit rounds
			// back up to nothing-in-particular rather than nothing.
			if (fac <= 0.0)
				return 0;
			if (damage < 1)
				damage = 1;
		}
		return Super.DamageMobj(inflictor, source, damage, mod, flags, angle);
	}

	// Where this monster is HEADING, for diagnostics. A staggered
	// transform means Tier hasn't moved yet, so a readout taken right
	// after SetTier would report the old tier and look like the command
	// did nothing. Returns the destination while transforming, the
	// current tier otherwise.
	int RS_DbgTargetTier()
	{
		return rsTransforming ? rsPendingTier : Tier;
	}

	// =================================================================
	// TIER STATE DISPATCH -- the rebuilt body system.
	// A tier's body is a real state cluster: See.T03, Missile.T03...
	// with literal sprite tokens, exactly the architecture Colourful
	// Hell and the proven HF port use. These helpers route into it.
	// =================================================================

	// THE LADDER IS OPEN-ENDED. T00..T12 are Colourful Hell's thirteen
	// colours and TEX (13) is CHP's EX variant, but nothing here caps at
	// thirteen: a higher tier is simply ANOTHER KIND OF MONSTER. Import a
	// new monster pack and it becomes T14, T15, ... with no base-class
	// change -- author the cluster, add the TierData row, raise the
	// family's MaxTier(). The main game mode runs T00 -> TEX; the rest of
	// the ladder is headroom that costs nothing until it is used.
	//
	// Labels are generated, not enumerated, so a new tier can never be
	// "missing" from a switch someone forgot to extend.
	static string TierLabel(int t)
	{
		if (t <= 0)  return "T00";
		if (t == RS_TIER_EX) return "TEX";
		return String.Format("T%02d", t);
	}

	// TEX sits directly above T12. Named so nothing has to hardcode 13.
	const RS_TIER_EX = 13;

	// Highest tier THIS family actually authors clusters for. The base
	// ships the CH ladder plus TEX; a family that imports further packs
	// overrides this and the dial reaches them automatically. SetTier
	// clamps to it, and ApplyTier still bails if TierData has no row --
	// two independent guards, so an unauthored tier can never half-apply.
	virtual int MaxTier()
	{
		return RS_TIER_EX;
	}

	// Convenience for families doing hitscan attacks off the tier data,
	// so thirteen tiers don't need thirteen hand-tuned magic numbers.
	void RS_TierBullets(int shots, double spread, int dmgLo, int dmgHi, string puff = "BulletPuff")
	{
		A_FaceTarget();
		int dmg = int(random(dmgLo, dmgHi) * TierDamageMul);
		A_CustomBulletAttack(spread, 0, shots, dmg, puff);
	}

	// -----------------------------------------------------------------
	// THE DISPATCH -- the single place every monster attack mode meets,
	// the same role A_RS_FireSlot plays on the weapon side.
	//
	// A monster's Missile state calls this and the DATA decides what
	// happens: a fireball, a 36-shot ring, a summon, an aura, a self
	// buff. Adding an attack to a tier is editing a table, not writing
	// a state.
	//
	// Advances the slot cursor, so a rotation like [shot, shot, summon]
	// naturally makes every third attack the summon.
	// -----------------------------------------------------------------
	void A_RS_MonsterFire()
	{
		if (!CurrentAttacks || CurrentAttacks.IsEmpty())
			return;

		let p = PickProfile();
		if (!p)
			return;

		FireProfile(p);
	}

	// Advance the rotation, skipping any profile whose range band does
	// not contain the current distance to target. That is what turns a
	// rotation into close/mid/long attacks with no hand-written state
	// branching.
	//
	// Walks at most one full lap: if nothing in the slot fits the current
	// distance we fire the next entry anyway rather than standing there
	// doing nothing, which reads as a broken monster.
	RS_AttackProfile PickProfile()
	{
		if (!CurrentAttacks || CurrentAttacks.IsEmpty())
			return null;

		double dist = target ? Distance3D(target) : 0;
		int n = CurrentAttacks.Count();

		for (int i = 0; i < n; i++)
		{
			let p = CurrentAttacks.Advance();
			if (!p) continue;
			if (!p.HasRangeBand() || p.InRange(dist))
				return p;
		}

		return CurrentAttacks.Advance();
	}

	// Fire one profile directly, without touching the rotation cursor.
	// Used by monsters that pick an attack by condition (range band,
	// health gate) rather than by rotation.
	void FireProfile(RS_AttackProfile p)
	{
		if (!p)
			return;

		if (p.FireSound)
			A_StartSound(p.FireSound, CHAN_WEAPON);

		switch (p.Mode)
		{
			case RS_ATK_SUMMON:
			{
				if (p.SummonClass)
					SummonPack(p.SummonClass, p.SummonCount,
					           p.SummonCap, p.SummonTierOffset);
				break;
			}

			case RS_ATK_RADIAL:
			{
				if (p.RadialHeal > 0)
				{
					// Support aura -- heal/buff nearby monsters. Uses the
					// same idiom CHP does, just typed.
					ThinkerIterator it = ThinkerIterator.Create("RS_MonsterMaster");
					RS_MonsterMaster mo;
					while (mo = RS_MonsterMaster(it.Next()))
					{
						if (mo == self || mo.health <= 0) continue;
						if (Distance3D(mo) > p.RadialRadius) continue;
						int cap = mo.TierMaxHealth > 0 ? mo.TierMaxHealth : mo.SpawnHealth();
						mo.health = min(cap, mo.health + p.RadialHeal);
					}
				}
				if (p.RadialDamage > 0)
				{
					// Plain A_Explode. Note this DOES splash other
					// monsters -- that's engine behaviour and it's what
					// CHP relied on (it starts infighting, which is
					// usually a feature in a crowd). RadialHitsAllies is
					// honoured on the heal path above, where we control
					// the iteration ourselves; it is NOT wired to the
					// damage path, because A_Explode has no
					// friendly-fire switch. Flagged rather than faked.
					int dmg = int(p.RadialDamage * TierDamageMul);
					A_Explode(dmg, int(p.RadialRadius), 0, false);
				}
				break;
			}

			case RS_ATK_SELFBUFF:
			{
				PulseStats(p.BuffSpeedMult, p.BuffDamageMult,
				           p.BuffDuration, p.BuffNoPain);
				break;
			}

			case RS_ATK_MELEE:
			{
				if (target && Distance3D(target) <= p.MeleeRange)
				{
					int dmg = int(random(8, 24) * p.DamageMult * TierDamageMul);
					int newdam = target.DamageMobj(self, self, dmg, "Melee");
					target.TraceBleed(newdam > 0 ? newdam : dmg, self);
				}
				break;
			}

			case RS_ATK_HITSCAN:
			{
				A_FaceTarget();
				int dmg = int(random(3, 15) * p.DamageMult * TierDamageMul);
				if (p.ImpactPuff)
					A_CustomBulletAttack(p.SpreadScale * 100.0, 0,
					                     max(1, p.VolleyCount), dmg, p.ImpactPuff);
				else
					A_CustomBulletAttack(p.SpreadScale * 100.0, 0,
					                     max(1, p.VolleyCount), dmg);
				break;
			}

			default:   // RS_ATK_HEAVY / RS_ATK_BULLET -- a projectile volley
			{
				FireVolley(p);
				break;
			}
		}
	}

	// The ring/fan burst. Colourful Hell's signature shape, as one
	// function instead of thirty hand-written A_CustomMissile lines.
	private void FireVolley(RS_AttackProfile p)
	{
		if (!p.ProjectileClass)
			return;

		A_FaceTarget();

		int n = max(1, p.VolleyCount);
		double arc = p.VolleyArc;

		// BurstDelayTics IS NOT HONOURED HERE, AND CANNOT BE. This is a
		// function, and functions do not wait -- state machines do
		// (rs_17 s4 reached the same conclusion for the weapon side).
		// Firing n rounds `delay` tics apart needs the caller's STATE to
		// loop, not this loop to sleep.
		//
		// That is not a hole today, because for monsters the slot is
		// DESCRIPTIVE: the tier states still fire their own attacks and
		// already carry the real spacing in their tic counts. The field
		// records the shape so the catalog is accurate and so PACK can
		// tell a burst from a fan -- which it previously could not, since
		// both looked like VolleyCount > 1.
		//
		// WHEN the states are converted to fire THROUGH the slot, this is
		// where the burst has to become a state loop. Do not "fix" it by
		// sleeping in this function; it will look right in a test and
		// stall the actor's thinker in play.

		// Size derived from what THIS monster is, unless the profile
		// forces it. A chaingunner throwing a Cacodemon ball is a
		// bullet-delivery skirmisher, so it throws a bullet-sized one.
		double projScale = (p.ProjScale > 0) ? p.ProjScale
			: RS_Catalog.ScaleForMonsterRole(GetKeywordValue("role"),
			                                 GetKeywordValue("delivery"));

		// A full ring divides evenly all the way round; a fan is
		// centred on where we're already facing.
		double step  = (n > 1) ? (arc / (arc >= 359.0 ? n : (n - 1))) : 0.0;
		double start = (arc >= 359.0) ? 0.0 : -arc * 0.5;

		for (int i = 0; i < n; i++)
		{
			double yaw = start + step * i;
			double pitchOff = (p.VolleyPitchJitter != 0)
			                ? frandom(-p.VolleyPitchJitter, p.VolleyPitchJitter)
			                : 0.0;

			// CMF_AIMDIRECTION so our computed yaw wins instead of the
			// engine re-aiming every shot at the target -- without it a
			// "ring" collapses into 36 shots all pointing the same way.
			let mo = A_SpawnProjectile(p.ProjectileClass, 32.0, 0, yaw,
			                           CMF_AIMDIRECTION | CMF_TRACKOWNER, pitchOff);
			// Size it to whoever fired it. No-ops at scale 1.0.
			RS_Catalog.ApplyProjectileScale(mo, projScale);
		}
	}

	// =================================================================
	// BEHAVIOUR PRIMITIVES
	// -----------------------------------------------------------------
	// Every one of these was found independently in five or more CHP
	// families during the behaviour survey -- summoning is in all 17,
	// per-actor state counters in 15, threshold triggers and timed
	// buffs nearly as often. They are shared machinery, not per-monster
	// content: a family file should be able to say "summon two of these,
	// cap four" in one line rather than reimplement pack tracking.
	//
	// Everything here is opt-in. A monster that calls none of it behaves
	// exactly like a vanilla Doom monster with a tier.
	// =================================================================

	// --- SUMMONING ---------------------------------------------------
	//
	// Live-pack counting walks the RS monster list rather than keeping a
	// stored array: an Array<Actor> of minions would need pruning every
	// time one died, and a stale pointer in it is a crash. Counting is
	// O(live monsters) but only runs when something actually tries to
	// summon, which is seconds apart at worst.

	int CountLiveMinions(Class<Actor> ofType = null)
	{
		int n = 0;
		ThinkerIterator it = ThinkerIterator.Create("RS_MonsterMaster");
		RS_MonsterMaster mo;
		while (mo = RS_MonsterMaster(it.Next()))
		{
			if (mo == self) continue;
			if (mo.master != self) continue;
			if (mo.health <= 0) continue;
			if (ofType && !(mo is ofType)) continue;
			n++;
		}
		return n;
	}

	// Spawn one minion bound to us. tierOffset is RELATIVE to our own
	// tier -- CHP's rule is that a summon inherits the summoner's
	// identity but is usually weaker, so -2 or -3 is the normal call and
	// 0 means "as strong as me".
	//
	// Minions are real RS_MonsterMaster monsters, deliberately: they get
	// the tier ladder, the body table, and can themselves be retiered by
	// the ambient dial. They do NOT count toward the level kill total --
	// a boss that spawns forever would make 100% kills impossible.
	Actor SummonMinion(Class<Actor> cls, int tierOffset = -2,
	                   double dist = 72.0, double zoff = 0.0, bool countKill = false)
	{
		if (!cls)
			return null;

		double ang = random(0, 359);
		Vector3 p = (pos.xy + (cos(ang), sin(ang)) * dist, pos.z + zoff);

		let mo = Spawn(cls, p, ALLOW_REPLACE);
		if (!mo)
			return null;

		mo.master = self;
		mo.target = target;          // inherit our current quarry
		mo.angle  = ang;
		if (!countKill)
			mo.bCOUNTKILL = false;

		let rm = RS_MonsterMaster(mo);
		if (rm)
			rm.SetTier(clamp(Tier + tierOffset, 0, 12), true);

		return mo;
	}

	// Capped pack summon. Returns how many actually spawned -- 0 means
	// the cap blocked it, which the caller usually wants to know so it
	// can fall back to a normal attack instead of standing there.
	int SummonPack(Class<Actor> cls, int count, int liveCap, int tierOffset = -2, double dist = 72.0)
	{
		if (!cls || count <= 0)
			return 0;

		int live = CountLiveMinions();
		int room = liveCap - live;
		if (room <= 0)
			return 0;

		int n = min(count, room);
		for (int i = 0; i < n; i++)
			SummonMinion(cls, tierOffset, dist);
		return n;
	}

	// Kill everything we summoned. CHP calls A_GivetoChildren("GoAway")
	// for this; we can do it directly since our minions are typed.
	// Prevents a dead boss leaving an unkillable pet swarm behind.
	void ReleaseMinions(bool killThem = true)
	{
		ThinkerIterator it = ThinkerIterator.Create("RS_MonsterMaster");
		RS_MonsterMaster mo;
		while (mo = RS_MonsterMaster(it.Next()))
		{
			if (mo == self || mo.master != self) continue;
			if (killThem && mo.health > 0)
				mo.DamageMobj(self, self, mo.health + 1000, "Massacre");
			else
				mo.master = null;
		}
	}

	// --- THRESHOLDS --------------------------------------------------
	//
	// One-shot health gate. Returns true EXACTLY once, the first time
	// health drops below the given fraction of max. Every CHP boss
	// enrage is this pattern guarded by a user_ variable; here the guard
	// is a bit in rsThresholdFlags, so a monster can have up to 32
	// independent gates without inventing a field per gate.
	//
	// slot is the caller's own index -- use 0, 1, 2... per monster.
	bool CheckThreshold(int slot, double fraction)
	{
		if (slot < 0 || slot > 31)
			return false;

		int bit = 1 << slot;
		if (rsThresholdFlags & bit)
			return false;

		int maxHP = TierMaxHealth > 0 ? TierMaxHealth : SpawnHealth();
		if (maxHP <= 0 || health > int(maxHP * fraction))
			return false;

		rsThresholdFlags |= bit;
		return true;
	}

	// Has a gate already fired? For attack pools that stay unlocked
	// after the enrage that opened them.
	bool ThresholdFired(int slot)
	{
		if (slot < 0 || slot > 31) return false;
		return (rsThresholdFlags & (1 << slot)) != 0;
	}

	// The permanent enrage itself, as CHP shapes it nearly every time:
	// faster, harder to stagger, more willing to shoot.
	//
	// MissileChanceMult SCALES THE "DON'T FIRE" DISTANCE ROLL, SO LOWER
	// FIRES MORE. It is the modern spelling of the old flags, and the
	// engine's own deprecation mapping fixes the direction:
	// +MISSILEMORE == 0.5, +MISSILEEVENMORE == 0.125. Multiplying UP
	// makes an enraged monster shoot LESS -- the exact opposite of the
	// line above this one. Do not "fix" 0.5 back to 2.0.
	void Enrage(double speedMult = 1.35, bool noPain = true, bool missileMore = true)
	{
		Speed *= speedMult;
		if (noPain)      bNOPAIN = true;
		if (missileMore) MissileChanceMult *= 0.5;   // == +MISSILEMORE

		// Turn on the silver pulse. Every caller already plays
		// SND_Enrage() on the next line; this is the half you can see.
		rsEnrageTellOn    = true;
		rsEnrageTellBeat = level.time;   // first flash immediately, with the roar
	}

	// --- TIMED PULSE -------------------------------------------------
	//
	// Temporary stat spike that reverts itself. CHP does this with ACS
	// delay() coroutines; a stored revert-tic checked in Tick is the
	// ZScript-native version. Guarded: calling it again while active is
	// ignored rather than stacking, so a monster spammed with pain
	// can't multiply its own speed.
	void PulseStats(double speedMult, double damageMult = 1.0,
	                int durationTics = 105, bool noPain = false)
	{
		if (rsPulseActive)
			return;

		rsPulseActive        = true;
		rsPulseBaseSpeed     = Speed;
		rsPulseBaseDamageMul = TierDamageMul;
		rsPulseSetNoPain     = noPain && !bNOPAIN;

		Speed         *= speedMult;
		TierDamageMul *= damageMult;
		if (rsPulseSetNoPain)
			bNOPAIN = true;

		rsPulseEndTic = level.time + durationTics;
	}

	private void RS_TickPulse()
	{
		if (!rsPulseActive || level.time < rsPulseEndTic)
			return;

		Speed         = rsPulseBaseSpeed;
		TierDamageMul = rsPulseBaseDamageMul;
		if (rsPulseSetNoPain)
			bNOPAIN = false;

		rsPulseActive = false;
	}

	// --- PHASE DODGE / BLINK -----------------------------------------
	//
	// Interrupt combat, become briefly hard to hit, resume. Found on
	// every high-tier CHP Archvile and on the Spectre/Revenant bosses,
	// always triggered off taking pain rather than off a timer.
	//
	// Won't start during a tier transform -- both want the render style,
	// and the transform is the more important read.
	void PhaseDodge(int tics = 54, double speedMult = 4.0, double toAlpha = 0.25)
	{
		if (rsDodgeActive || rsTransforming)
			return;

		rsDodgeActive    = true;
		rsDodgeBaseSpeed = Speed;
		rsDodgeBaseAlpha = alpha;
		rsDodgeBaseStyle = 0;
		rsDodgeSetNoPain = !bNOPAIN;

		Speed *= speedMult;
		A_SetRenderStyle(toAlpha, STYLE_Translucent);
		if (rsDodgeSetNoPain)
			bNOPAIN = true;

		rsDodgeEndTic = level.time + tics;
	}

	private void RS_TickDodge()
	{
		if (!rsDodgeActive || level.time < rsDodgeEndTic)
			return;

		Speed = rsDodgeBaseSpeed;
		A_SetRenderStyle(rsDodgeBaseAlpha, STYLE_Normal);
		if (rsDodgeSetNoPain)
			bNOPAIN = false;

		rsDodgeActive = false;
	}

	bool IsDodging() { return rsDodgeActive; }

	// --- ORBIT / ATTACH ----------------------------------------------
	//
	// Attach a satellite that follows us. The satellite class owns its
	// own warp loop and its own death condition (see
	// RS_MonsterSatellite in RS_MonsterCatalog.zs) -- all we do here is
	// spawn it and point it at ourselves.
	Actor AttachSatellite(Class<Actor> cls, double angleOffset = 0, double radius = 40, double height = 40)
	{
		if (!cls)
			return null;

		let mo = Spawn(cls, pos, ALLOW_REPLACE);
		if (!mo)
			return null;

		mo.master = self;
		mo.target = self;
		mo.angle  = angle + angleOffset;
		mo.bCOUNTKILL = false;

		let sat = RS_MonsterSatellite(mo);
		if (sat)
		{
			sat.OrbitRadius = radius;
			sat.OrbitHeight = height;
			sat.OrbitAngle  = angleOffset;
		}
		return mo;
	}

	// --- MORPH -------------------------------------------------------
	//
	// Replace ourselves with a different class, carrying our fight
	// forward. This is how CHP does multi-phase bosses: the "death" of
	// stage one spawns stage two rather than ending the encounter.
	//
	// Deliberately does NOT preserve health -- the new stage brings its
	// own pool, which is the whole point of a phase change.
	Actor MorphInto(Class<Actor> cls, bool inheritTier = true, bool inheritTarget = true)
	{
		if (!cls)
			return null;

		let mo = Spawn(cls, pos, ALLOW_REPLACE);
		if (!mo)
			return null;

		mo.angle = angle;
		mo.vel   = vel;
		if (inheritTarget && target)
			mo.target = target;

		let rm = RS_MonsterMaster(mo);
		if (rm && inheritTier)
			rm.SetTier(Tier, true);

		// Don't leave the corpse counting toward the kill total twice.
		bCOUNTKILL = false;
		return mo;
	}

	// --- CHARGE COUNTER ----------------------------------------------
	//
	// CHP's escalation engine, generalised. The Abyss Archvile's summon
	// portal ramps Revenant -> Imp -> Cacodemon off one of these; the
	// White Archvile spends it like a resource; the Black one uses it as
	// a live-pack budget paid down by dodging.
	void AddCharge(int n = 1)
	{
		ChargeCounter += n;
	}

	// Spend if affordable. Returns false (and spends nothing) if short,
	// so an attack can cleanly fall through to a cheaper option.
	bool SpendCharge(int cost)
	{
		if (ChargeCounter < cost)
			return false;
		ChargeCounter -= cost;
		return true;
	}

	void ResetCharge() { ChargeCounter = 0; }

	// =================================================================
	// KEYWORDS -- same BASE/GRANTED shape as RS_Weapon, same shared
	// RS_Keywords parser. Not forked.
	// =================================================================

	Array<string> GrantedKeywords;

	virtual string GetBaseKeywords()
	{
		return "";
	}

	bool HasKeyword(string key, string value)
	{
		if (RS_Keywords.StringHas(GetBaseKeywords(), key, value))
			return true;
		string needle = key .. ":" .. value;
		for (int i = 0; i < GrantedKeywords.Size(); i++)
			if (GrantedKeywords[i] == needle)
				return true;
		return false;
	}

	string GetKeywordValue(string key)
	{
		string v = RS_Keywords.GetValue(GetBaseKeywords(), key);
		string prefix = key .. ":";
		for (int i = 0; i < GrantedKeywords.Size(); i++)
			if (GrantedKeywords[i].Left(prefix.Length()) == prefix)
				v = GrantedKeywords[i].Mid(prefix.Length());
		return v;
	}

	void GetKeywordValues(string key, out Array<string> results)
	{
		RS_Keywords.GetValues(GetBaseKeywords(), key, results);
		string prefix = key .. ":";
		for (int i = 0; i < GrantedKeywords.Size(); i++)
			if (GrantedKeywords[i].Left(prefix.Length()) == prefix)
				results.Push(GrantedKeywords[i].Mid(prefix.Length()));
	}

	void GrantKeyword(string key, string value)
	{
		GrantedKeywords.Push(key .. ":" .. value);
	}

	// =================================================================
	// DEATH
	// =================================================================

	// Override true on a summoner whose pack should not outlive it.
	// CHP goes both ways on this deliberately -- the Deep One's
	// tentacles die with it, the Imp Master's imps don't -- so it's a
	// per-monster decision rather than a blanket rule.
	virtual bool MinionsDieWithMe()
	{
		return false;
	}

	// A morph-on-death monster names its next stage here. Returning a
	// class means "this death is a phase change, not the end of the
	// fight" -- the successor spawns where we fell.
	virtual Class<Actor> DeathMorphClass()
	{
		return null;
	}

	// --- FACTS ABOUT THIS MONSTER ------------------------------------
	//
	// These report what a monster IS. They deliberately do NOT decide
	// what any other system should do about it -- a monster shouldn't
	// know the loot system exists. RS_Bits reads these and applies its
	// own policy; if that policy later becomes "minions drop reduced
	// bits" instead of "minions drop nothing", that's an edit to Bits
	// and this file doesn't change.

	// Spawned by another monster rather than placed by the map or the
	// spawner. The thing that makes an infinite-summon loop farmable.
	bool IsSummonedMinion()
	{
		return master && (master is "RS_MonsterMaster");
	}

	// This body is one stage of a multi-stage fight and its death hands
	// off to another stage rather than ending the encounter.
	bool IsTransientStage()
	{
		return DeathMorphClass() != null;
	}

	// THE UNDERTAKER'S PLAN -- CHP 01_W.txt:18.
	//
	// The T12 White Zombieman opens by radius-giving CHWhitePlan to every
	// monster on the map, at radius 16383 and RGF_NOSIGHT: through walls,
	// no line of sight, effectively the whole level. Every marked corpse
	// then hatches a skeleton on death.
	//
	// CH implements the second half by editing the Death state of every
	// monster in the game -- 128 CHP files carry a `Tickles` jump. We do
	// it once, here, because every RS monster already funnels through this
	// one override. Same behaviour, one site instead of 128, and it
	// cannot rot out of sync the way 128 hand-edited Death states can.
	//
	// Deliberately NOT gated on the Undertaker still being alive: CH does
	// not clear the mark either, so a level the Undertaker passed through
	// keeps hatching. That is the mechanic, not an oversight -- the boss
	// is seeding the whole map, and it is why ignoring the skeletons is
	// as bad as killing them.
	// The Abyss Zombie's half of the same idea -- CHP 01_A.txt:18. A
	// marked zombie does not drop a skeleton, it comes BACK as an Abyss
	// Zombie. Ours retiers in place rather than spawning a replacement,
	// for the same reasons Pain.AbyssPE does.
	//
	// Runs before the Undertaker's hatch and returns true to claim the
	// corpse: a monster carrying both marks converts rather than
	// hatching, because a body that stands back up has no corpse left to
	// seed a skeleton from.
	private bool RS_HatchAbyss()
	{
		// DISABLED 2026-08-05. This is family 01's mechanic and its
		// inventory token (RS_AbyssMark) lives in the quarantined CHP
		// build, which is no longer loaded. Restore the token check the
		// day the zombieman is rebuilt from CH.
		return false;
		/*
		if (!CountInv(""))
			return false;

		TakeInventory("", 1);

		// CH's filter is species "Zombie" excluding CommonAbyssZombie.
		// Ours is one class with a tier, so the equivalent test is "is a
		// Zombieman below the Abyss tier".
		if (!(self is "ZombieMan") || Tier >= 6)
			return false;

		// SPAWN A FRESH ONE rather than retiering this corpse. Die() is
		// already committed -- Super.Die() runs after us and would kill
		// anything we revived here. Pain.AbyssPE can retier in place
		// because it fires on a LIVING monster; this cannot. CH spawns
		// too (AbyssGrow), so this is the faithful shape as well as the
		// only workable one.
		class<Actor> cls = GetClass();
		let a = Actor.Spawn(cls, pos + (0, 0, 1), ALLOW_REPLACE);
		let m = RS_MonsterMaster(a);
		if (m)
		{
			m.SetTier(6, true);
			if (target)
				m.target = target;
		}
		return true;
		*/
	}

	private void RS_HatchPlan()
	{
		// DISABLED 2026-08-05, same reason: RS_UndertakerPlan and
		// RS_MrBones are family 01's, and family 01 is not loaded.
		return;
		/*
		if (!CountInv("RS_UndertakerPlan"))
			return;

		// One skeleton per corpse. Take the mark first so a monster that
		// somehow dies twice (raised, then killed again) cannot double up.
		TakeInventory("RS_UndertakerPlan", 1);

		class<Actor> bones = "RS_MrBones";
		if (bones)
			Actor.Spawn(bones, pos + (0, 0, 4), ALLOW_REPLACE);
		*/
	}

	override void Die(Actor source, Actor inflictor, int dmgflags, Name MeansOfDeath)
	{
		// Abyss first: a body that stands back up as an Abyss Zombie has
		// no corpse left to seed a skeleton from, so the conversion
		// claims the death and the Undertaker's hatch is skipped. CH
		// reaches the same outcome structurally -- a Death state can only
		// jump to ONE branch.
		if (!RS_HatchAbyss())
			RS_HatchPlan();

		if (MinionsDieWithMe())
			ReleaseMinions(true);

		let next = DeathMorphClass();
		if (next)
		{
			let mo = MorphInto(next, true, true);
			// Hand the killer over so the next stage immediately knows
			// who it's fighting rather than standing idle.
			if (mo && source)
				mo.target = source;
		}

		Super.Die(source, inflictor, dmgflags, MeansOfDeath);
	}

	// =================================================================
	// TICK
	// =================================================================

	// How often a live monster emits its tier icon, in tics. CH re-spawns
	// the icon from inside Spawn/See/Missile/Pain, so the rate is however
	// often those states cycle; 35 is a steady once-a-second that reads the
	// same without depending on which state the monster happens to be in.
	const RS_TIERICON_PERIOD = 35;

	// CH's tier icon, emitted here rather than from each monster's states.
	//
	// CH spawns it with an A_SpawnItemEx line pasted into Spawn, See,
	// Missile and Pain of EVERY actor -- roughly 3,500 copies of one line.
	// Doing it that way here would be actively dangerous: those lines are
	// 0-tic, and `Goto X+N` offsets COUNT FRAMES, so inserting or removing
	// one silently retargets every jump after it in that state. That
	// exact hazard already forced two placeholder frames in this family.
	//
	// One emitter in the base class is identical on screen, cannot shift a
	// single offset, and gives all seventeen families the icon for free.
	private int rsIconTic;
	private void RS_EmitTierIcon()
	{
		if (health <= 0) return;

		let cv = CVar.FindCVar("rs_mon_tiericons");
		if (!cv || !cv.GetBool()) return;

		if (level.time < rsIconTic) return;
		rsIconTic = level.time + RS_TIERICON_PERIOD;

		// One icon class per tier. Tier 0 is the base class; 1..12 are the
		// numbered subclasses. Clamped rather than trusted -- a family
		// whose ladder runs past 12 must not resolve to a null class.
		int t = clamp(Tier, 0, 12);
		string cls = (t == 0) ? "RS_ColorTierIcon"
		                      : ("RS_ColorTierIcon" .. t);
		Class<Actor> ic = cls;
		if (!ic) return;

		// CH's own spawn parameters, verbatim: z+32, a small upward drift
		// and a random facing so repeated icons scatter instead of
		// stacking into one blob over the monster's head.
		A_SpawnItemEx(ic, 0, 0, 32,
		              random(1, 4), 0, random(0, 2),
		              random(0, 359), SXF_NOCHECKPOSITION);
	}

	override void Tick()
	{
		Super.Tick();

		RS_EmitTierIcon();

		// Deferred tier-body jump (set by ApplyTier). Only while alive --
		// a corpse must never be yanked back into See.
		if (health > 0 && pendingStateJump.Length() > 0)
		{
			string j = pendingStateJump;
			pendingStateJump = "";
			State st = FindStateByString(j, true);
			if (st)
				SetState(st);
		}

		RS_TickTransform();
		RS_TickEnrageTell();
		RS_TickPulse();
		RS_TickDodge();

		// Corpse-nudge: a monster gibbed in mid-air can stick on its
		// infinite (-1) corpse frame before gravity grounds it. General
		// to every monster set, not tier-related.
		if (health <= 0 && !bNoGravity)
		{
			double fz = floorz;
			if (pos.z > fz + 0.5)
			{
				if (vel.z > -0.5) vel.z -= 0.8;
			}
			else if (pos.z < fz)
			{
				SetZ(fz);
				if (vel.z < 0) vel.z = 0;
			}
		}
	}

	// Every dynamic behaviour in here is meant to be switchable --
	// default settings keep combat Doom-honest, and a player who wants
	// full chaos turns them up.
	static bool RS_MonOpt(string name, bool def)
	{
		let cv = CVar.FindCVar(name);
		return cv ? cv.GetBool() : def;
	}

	// Float form. Same contract: missing cvar falls back to the default,
	// so the tree still runs if CVARINFO and the code get out of step.
	static double RS_MonOptF(string name, double def)
	{
		let cv = CVar.FindCVar(name);
		return cv ? cv.GetFloat() : def;
	}

	// =================================================================
	// ENTRY-POINT DISPATCHERS. The engine enters monsters through these
	// fixed label names (A_Chase looks up "Missile"/"Melee", pain
	// routing looks up "Pain"...). Each one immediately routes to the
	// current tier's real cluster. The plain-frame fallbacks after each
	// dispatcher only run if a family shipped NO cluster at all for a
	// label -- the audit treats that as a defect; the fallback just
	// keeps it from being a freeze.
	// =================================================================

	States
	{
	Spawn:
		TNT1 A 0 NoDelay { return TierState("Spawn"); }
		TNT1 A 10 A_Look();
		Loop;
	See:
		TNT1 A 0 { return TierState("See"); }
		TNT1 A 4 A_Chase();
		Loop;
	Missile:
		TNT1 A 0 { return TierState("Missile"); }
		Goto See;
	Melee:
		TNT1 A 0 { return TierState("Melee"); }
		Goto See;
	Pain:
		TNT1 A 0 { return TierState("Pain"); }
		TNT1 A 3 A_Pain();
		Goto See;
	Death:
		TNT1 A 0 { return TierState("Death"); }
		TNT1 A 5 { A_Scream(); A_NoBlocking(); }
		Stop;
	XDeath:
		TNT1 A 0 { return TierState("XDeath"); }
		Goto Death;
	Raise:
		TNT1 A 0 { return TierState("Raise"); }
		Goto See;

	// =================================================================
	// THE ABYSS CONVERSION -- family-agnostic, added 2026-08-05.
	//
	// CH defines Pain.AbyssPE on nearly every low-tier parent in nearly
	// every family and CHP overrides it nowhere, so it is live and
	// inherited across the whole bestiary. It was ported to family 01
	// only. A sweep of family 04 found it on SIX of seven parents there
	// (Chaingunners.txt:1041, 1125, 1247, 374, 1414, 1627) and absent
	// from our tree entirely.
	//
	// IT LIVES HERE RATHER THAN IN SEVENTEEN FAMILY FILES because CH's
	// bodies are byte-identical and, more importantly, OUR conversion is
	// the same everywhere. CH must spawn a different class per family
	// (AbyssCGuy2, AbyssZombie2, ...) and A_die the original, because
	// its tiers ARE separate classes. Ours are one class with a tier, so
	// every family's conversion is the same two words: SetTier(6).
	//
	// TRIGGER: DamageType "AbyssPE", dealt only by the Abyss Pain
	// Elemental's pulse (RS_AbyssPEPulse, RS_PainElemental.zs). That
	// pulse was typed "Plasma" until 2026-08-04, which made this
	// unreachable from BOTH ends at once -- the state was missing and so
	// was its trigger, and each hid the other.
	//
	// A family that needs a different conversion overrides this label;
	// RS_Zombieman does exactly that, because its version also has to
	// handle the sprite scale its own tier table sets.
	Pain.AbyssPE:
		TNT1 A 0
		{
			// Already Abyss or beyond -- nothing to convert to. CH needs
			// no such guard because a T06 there is simply a different
			// class that never carries this state.
			if (Tier >= 6)
				return ResolveState("Pain");
			bNOPAIN = true;
			A_SetScale(0.8);
			return ResolveState(null);
		}
		"AYPB" AAB 5 Bright;
		"AYPB" B 5 Bright { A_StartSound("AbyssForm", CHAN_VOICE); }
		"AYPB" BBACDE 5 Bright;
		TNT1 A 0
		{
			// CH throws 45 + 45 SplashAbyss at two velocities. One loop
			// rather than two 45-character frame runs; same count.
			for (int i = 0; i < 45; i++)
			{
				A_SpawnItemEx("RS_SplashAbyss", random(-16, 16), random(-16, 16), random(4, 32),
				              16, 0, 3, random(-359, 359), SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
				A_SpawnItemEx("RS_SplashAbyss", random(-16, 16), random(-16, 16), random(4, 32),
				              12, 0, 8, random(-359, 359), SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
			}
		}
		"AYPB" FGH 3 Bright;
		"AYPB" I 5 Bright;
		"AYPB" H 5 Bright;
		TNT1 A 0
		{
			bNOPAIN = false;
			A_SetScale(1.0);
			SetTier(6, true);
		}
		Goto See;
	}

	// =================================================================
	// THE TIER-LADDER SEAM.  Split out 2026-08-05.
	//
	// Everything below is a NO-OP here and is overridden by
	// RS_MonsterLadder (zscript/monsters/_chp_legacy/). That subclass
	// holds the machinery that makes ONE class behave as FOURTEEN --
	// per-tier stat rows, per-tier sprite and tint tables, per-tier
	// state clusters and the .T00 dispatch.
	//
	// It exists because the CHP-era families still need it and cannot be
	// deleted without leaving sixteen families with no monsters. It is
	// NOT in the path for anything rebuilt from CH: under the CH rebuild
	// each creature is its own class with its own Default block, its own
	// sprites, its own Translation and plain state labels, so there is
	// no ladder to walk.
	//
	// A family stops inheriting RS_MonsterLadder the day it is rebuilt.
	// When the last one leaves, the subclass and this seam both go.
	// =================================================================

	// Recompute everything a tier owns. Nothing to recompute when the
	// class IS the creature.
	virtual void ApplyTier(bool instant) { }

	// The per-tier palette remap. A CH rebuild states its own
	// Translation in its own Default block.
	virtual void RS_ApplyTint() { }

	// Show another tier's body without committing to it -- the transform
	// tell's flicker. A class swap has no other body to show; the
	// promotion tell pulses copper against its own instead.
	virtual void RS_ShowBody(int t) { }

	// Per-tier damage-type multiplier. A CH rebuild states its own
	// DamageFactor lines.
	virtual double TierDamageFactor(int t, Name damageType) { return 1.0; }

	// Per-tier stat row. No row means "this class already is its stats".
	virtual bool TierData(int t, out RS_MonsterTierRow r) { return false; }

	// STATE DISPATCH. The plain label, which is what an ordinary actor
	// writes and what every CH rebuild writes.
	//
	// RS_MonsterLadder overrides this to try "prefix.<tier>" and
	// "prefix.T00" first. That suffix requirement is why five files in
	// family 04 could not fire a shot: FindStateByString(..., exact)
	// does not match a plain `Missile:`, so MissileState came back null
	// and the monster stood there. Every one of them looked correct on
	// the page.
	virtual State TierState(string prefix)
	{
		return FindStateByString(prefix, true);
	}

}

// =====================================================================
// Shared per-family base classes. Kept here rather than in a fourth
// kind of file -- this IS the template file, and a base class that
// exists purely to remove duplication across a family's concrete
// monster files belongs with the rest of the template machinery.
// =====================================================================

// Thin family-group shells. Their old shared "POSS"-literal state
// blocks were the skin-system bug -- every state advance re-baked a
// zombieman frame over whatever body the monster was supposed to wear.
// REMOVED 2026-08-04: RS_HumanMonster, RS_DemonBase, RS_KnightBase.
//
// Three empty abstract classes -- literally `: RS_MonsterMaster abstract
// {}` -- that six families inherited from. The comment here claimed they
// were kept "as grouping points for shared mechanics and `is`-checks".
// There were no shared mechanics and no `is`-checks: a search for all
// three names across the whole tree returned only the six `class X : Y`
// lines and this comment. They did nothing.
//
// They are gone rather than left harmless because of what they invited.
// Demon and Spectre share an IDENTICAL body list from T00 to T07, and
// Baron and HellKnight are close. The moment somebody notices that and
// "helpfully" hoists shared states up into RS_DemonBase, a Demon and a
// Spectre are running the same state code -- change one, change both --
// which is the cross-family sprite bleed this project has been chasing.
// An empty base class is a standing invitation to exactly that.
//
// If shared family behaviour is ever genuinely wanted, add it when there
// is something to share, and add it as a MIXIN or a helper the families
// call, not as a parent that silently owns their states.
