// =====================================================================
// RS_AttackProfile / RS_AttackSlot -- the attack-assembly bricks.
// ---------------------------------------------------------------------
// One AttackProfile describes ONE way a weapon attacks: what leaves the
// barrel, what it costs, its own shot shape, its own sound. Nothing in
// it is hardcoded to a specific weapon -- it's a reference bundle, so
// the same profile can sit on several weapons, and a weapon can carry
// several different ones.
//
// An AttackSlot is an ORDERED LIST of profiles plus a cursor. Firing the
// slot fires the profile at the cursor, then advances one step, wrapping
// at the end. That single mechanism covers everything:
//
//   list of 1                -> a normal weapon. Cursor never visibly
//                               moves; looks like no cycling at all.
//   list of [A, A, B]        -> "every third shot is B"
//   list of [A, B]           -> "alternates A and B"
//
// A weapon has two slots -- Primary (main trigger) and Secondary
// (alt-fire). They are fully independent: different profiles, different
// ammo, different everything. Nothing is shared between them.
//
// WHY IT'S SHAPED THIS WAY: GunBonsai upgrades write into this at two
// altitudes, and both are one-line operations on the structures below:
//   * grow the list   -> AppendProfile() / InsertProfile()  ("your
//                        revolver now fires a plasma bolt every 3rd shot")
//   * swap an entry   -> ReplaceProfile()                   ("your
//                        alt-fire is now something else entirely")
// The upgrade-card sentence and the data structure are the same thing
// described two ways.
//
// The weapon's OWN rolled stats (Tier, Condition, DamagePerShot,
// Accuracy, CritChance, Velocity) are NOT duplicated per profile. They
// stay on RS_Weapon and modulate whatever profile just fired -- a
// Prototype-tier gun's plasma entry hits harder than a Basic-tier gun's
// plasma entry, and the profile never needs to know that happened.
// =====================================================================

// Which firing path a profile uses. Lives on the individual profile, not
// on the weapon, so one weapon can rotate through wildly different attack
// types without any of them being a special case.
const RS_ATK_BULLET  = 0;   // volley of travelling rounds (RS_BallisticFired)
const RS_ATK_HEAVY   = 1;   // one explosive/energy round (Rocket/Plasma/BFG)
const RS_ATK_MELEE   = 2;   // short-range hit, no projectile
const RS_ATK_HITSCAN = 3;   // instant A_FireBullets trace (chaingun)

// --- Monster-side modes ---------------------------------------------
// Monsters need verbs weapons don't have. Added to the SAME enum rather
// than forked into a parallel type because RS_AttackProfile.Clone()
// hardcodes new("RS_AttackProfile") and PadTo() calls it -- a subclass
// would silently slice every time an upgrade padded a rotation. The
// weapon dispatch ignores modes it doesn't handle, so weapons are
// unaffected by these existing.
// WHICH BEAT AN ATTACK BELONGS TO. Most attacks fire from Missile; CHP
// fires plenty from elsewhere and those were previously undescribable.
// Comparison-chain friendly ints, never a static const array -- that form
// does not resolve reliably on this engine build (CLAUDE.md).
const RS_FIRE_MISSILE = 0;  // the normal case: a Missile state
const RS_FIRE_MELEE   = 1;  // a Melee state
const RS_FIRE_PAIN    = 2;  // retaliation, fired on being hurt
const RS_FIRE_DEATH   = 3;  // a death burst
const RS_FIRE_XDEATH  = 4;  // a gib burst, distinct from Death
const RS_FIRE_WALK    = 5;  // thrown mid-chase, out of See
const RS_FIRE_SPAWN   = 6;  // fired once on arrival (auras, marks)

const RS_ATK_SUMMON   = 4;  // spawn minions, capped by live pack size
const RS_ATK_RADIAL   = 5;  // radius effect -- damage enemies or buff allies
const RS_ATK_SELFBUFF = 6;  // temporary self stat spike

class RS_AttackProfile : Object
{
	// --- What this attack is ---
	int Mode;                       // RS_ATK_*
	Class<Actor> ProjectileClass;   // bullet class or heavy class, by Mode.
	                                // null on a bullet profile = fall back to
	                                // the weapon's own ProjectileClass.

	// --- Shot shape ---
	// Everything here MODIFIES the weapon's rolled stats rather than
	// replacing them. That's the whole reason tier and Condition keep
	// meaning something no matter which profile in a rotation fired.
	//
	// Final spread reproduces what each weapon computed inline before:
	//   (100 - Accuracy) * SpreadScale * chokeFactor
	//     + (UsesCadence ? overshoot * 0.15 : 0)
	//     + SpreadBonus
	// SpreadScale 0.05 = tight (pistol/revolver/smg/rifle/chaingun),
	// 0.1 = shotgun family. chokeFactor = (1 - Choke*0.5) when UsesChoke.
	int    PelletOverride;   // 0 = use the weapon's own rolled PelletCount
	double SpreadScale;
	bool   UsesChoke;
	double SpreadBonus;      // flat extra degrees on top
	bool   UsesCadence;      // semi-auto: firing early widens the cone.
	                         // full-auto leaves this false -- RateOfFire IS
	                         // the cadence there, so there's nothing to
	                         // outpace.
	double DamageMult;       // x weapon's rolled DamagePerShot
	double VelocityMult;     // x weapon's rolled Velocity
	double CritBonus;        // added to weapon's rolled CritChance (0-1)

	// --- Cost ---
	// AmmoClass null + AmmoCost > 0 means "the weapon's own AmmoType2"
	// (its magazine), resolved at fire time. That one rule covers all 66
	// ballistic identities without any of them naming their own chamber
	// class here -- VR_RevLoaded vs VR_RevLoaded4 sorts itself out.
	// AmmoCost 0 = this profile is free at the profile layer (melee, or a
	// weapon metering ammo in its own states).
	Class<Ammo> AmmoClass;
	int AmmoCost;

	// --- Presentation ---
	sound FireSound;

	// LAYERED ON TOP OF FireSound, added 2026-08-08. Not axis 5, and not
	// a ninth axis in the PACK sense either -- axis 5 keeps its existing
	// override semantics (an affix or a profile that wants to fully
	// REPLACE the gun's report, e.g. a suppressor, still can). This is
	// additive only: if set, it plays as a SECOND, independent sound
	// alongside whatever axis 5 resolved to, never instead of it.
	//
	// Built for exactly one case, named here so the next reader knows
	// it is not speculative: RS_PACKAssembly's own comment already
	// promised a themed beat would "still sound like it is being fired
	// by [the gun] underneath the new noise", but axis 5 there was
	// pulling the theme's sound through the ordinary override chain --
	// a shotgun firing a caco-themed beat sounded like ONLY the caco,
	// the shotgun blast silenced underneath it rather than under it.
	// ExtraFireSound is where that theme voice goes now; axis 5 stays
	// the gun's own.
	sound ExtraFireSound;
	// String, not Class<Actor> -- RS_HiFiFX.CasingEject's own signature
	// takes a string. "" = no casing ejected.
	string CasingClass;
	bool   BigMuzzle;           // RS_HiFiFX.MuzzleEffects(self, <this>)
	double SpawnHeight;         // muzzle offset, heavy profiles

	// --- Player Feedback layer ---
	// null = use the Sequence's own built-in default (RS_Catalog's
	// PUFF_Bullet/SPARK_Hit/SMOKE_Wisp/TRAIL_Ballistic entries -- see
	// RS_BallisticFired's Death: state and Tick()) -- every existing
	// weapon that doesn't set these keeps firing exactly as it does
	// today. Set one to actually override it.
	//
	// WHICH MODES READ WHICH -- read off RS_Weapon's dispatch, not assumed.
	// The split is per SLOT, not per mode, and it falls exactly where gun
	// identity ends and the shot's own arrival begins:
	//   MuzzleSmoke    EVERY mode. RS_Weapon:645 sits OUTSIDE the mode
	//                  branch, alongside FireSound and CasingEject, so a
	//                  gun keeps its own voice/brass/flash whatever it is
	//                  firing -- including a monster volley in HEAVY mode.
	//   ImpactPuff     bullet + hitscan (RS_Weapon:606, :725).
	//   ImpactSparks   bullet only (:726).
	//   Trail          bullet only (:727) -- hitscan has no flight.
	// Heavy skips the three impact slots BY DESIGN: a heavy projectile
	// owns its own arrival (that is what lets a weapon wear a monster's
	// attack and keep the monster's impact FX). ExplosionVisual below is
	// heavy's own cosmetic hook.
	//
	// This header previously said "bullet/hitscan only" and that heavy
	// used none of the four. That was wrong about MuzzleSmoke, and reading
	// it instead of the dispatch produced a confident wrong conclusion.
	Class<Actor> ImpactPuff;
	Class<Actor> ImpactSparks;
	Class<Actor> MuzzleSmoke;
	// In-flight trail piece (bullet-mode only, not hitscan -- hitscan has
	// no flight to trail). null = RS_Catalog.TRAIL_Ballistic().
	Class<Actor> Trail;
	// Heavy-mode only. Cosmetic blast visual spawned alongside a heavy
	// projectile's own A_Explode -- swaps the LOOK of the detonation,
	// never its damage/splash radius. null = the projectile class's own
	// default (see RS_EnhancedRocket.ExplosionVisual). Not every heavy
	// projectile class reads this yet -- see RS_FX_HeavyProjectiles.zs.
	Class<Actor> ExplosionVisual;

	// --- Melee only ---
	double MeleeRange;
	Class<Actor> MeleePuff;

	// --- Volley shape (monster-side, but deliberately generic) --------
	// Colourful Hell's signature move is the ring burst: 12, 24, 36
	// projectiles fired at once in a fan or a full circle. Expressing
	// that as data rather than as thirty hand-written A_CustomMissile
	// lines is the whole reason this layer exists.
	//   VolleyCount 1            -> a single shot (the default)
	//   VolleyCount 8, Arc 0     -> 8 shots straight ahead (a burst)
	//   VolleyCount 8, Arc 90    -> 8 shots spread across a 90-degree fan
	//   VolleyCount 36, Arc 360  -> a full ring
	// Nothing weapon-side sets these, so weapons keep firing exactly as
	// they do today.
	int    VolleyCount;
	double VolleyArc;
	double VolleyPitchJitter;   // degrees of vertical scatter, 0 = flat

	// --- Burst: THE SAME COUNT, SPREAD OVER TIME -----------------------
	// rs_17 s4 named this gap and four independent cases hit it: CHP's
	// walking bursts, double-taps and A_Monsterrefire loops could not be
	// described at all, because VolleyCount fires its WHOLE count on one
	// tic. That is a shotgun. A burst is the same rounds arriving apart.
	//
	//   BurstDelayTics 0   -> all VolleyCount rounds on one tic (a fan,
	//                         a ring, a shotgun). The default, so every
	//                         profile written before this field is
	//                         unchanged.
	//   BurstDelayTics 2   -> VolleyCount rounds, 2 tics between each.
	//
	// VolleyArc still applies, so a burst can also fan -- CHP's T05
	// walking burst is exactly that: three rounds, a few tics apart,
	// each with its own spread.
	//
	// DELIBERATELY NOT a separate BurstCount field. rs_17 s4(a) warned
	// that VolleyCount and BurstCount "will be confused, and someone will
	// build the wrong one or build the second one twice". One count, one
	// spacing: if the spacing is zero they arrive together, if it is not
	// they arrive apart. There is no third thing to name.
	int    BurstDelayTics;

	// --- WHEN it fires --------------------------------------------------
	// A profile that describes a monster attack has to say which state it
	// belongs to, because CHP fires plenty of attacks from somewhere
	// other than Missile: death bursts, pain retaliation, and rounds
	// thrown mid-walk. Family 01 alone has four, and until this field
	// existed the catalog could describe them and the slot could not hold
	// them.
	//
	// This is DESCRIPTIVE, not a dispatcher -- the state still fires the
	// attack. It exists so an attack in a slot can be matched to the beat
	// it belongs to, which is what PACK needs in order to ever move one.
	int    FireTrigger;

	// --- Projectile size -----------------------------------------------
	// 0 = DERIVE from the firer (RS_Catalog.ScaleForArchetype for weapons,
	// ScaleForMonsterRole for monsters). That is the normal case and the
	// reason the shared projectile library works at all -- a rifle firing
	// a Cacodemon ball gets a bullet-sized one without anyone authoring
	// the pairing.
	//
	// Set non-zero only to force a specific size regardless of who fires
	// it (a deliberately oversized boss shot, say). Affix multipliers
	// still apply on top either way.
	double ProjScale;

	// --- Range band -----------------------------------------------------
	// The dispatch skips a profile whose window doesn't contain the
	// current distance to target, so close/mid/long attacks are data
	// rather than hand-written state branches.
	// MaxRange 0 = no upper limit (the default: always eligible).
	double MinRange;
	double MaxRange;

	// --- Summon mode --------------------------------------------------
	// Class comes from RS_MonsterCatalog, never named inline.
	Class<Actor> SummonClass;
	int SummonCount;        // how many per cast
	int SummonCap;          // refuse to cast if this many are already live
	int SummonTierOffset;   // relative to the summoner's own tier

	// --- Radial mode --------------------------------------------------
	// One shape, two uses: damage enemies, or buff/heal allies. CHP does
	// both off the same A_RadiusGive idiom, so they share a mode.
	double RadialRadius;
	int    RadialDamage;      // 0 with RadialHeal set = pure support
	int    RadialHeal;        // healed to allies rather than damage
	bool   RadialHitsAllies;  // false = enemies only (the usual case)

	// --- Self-buff mode -----------------------------------------------
	double BuffSpeedMult;
	double BuffDamageMult;
	int    BuffDuration;      // tics
	bool   BuffNoPain;

	// Display name for menus/upgrade cards. Optional.
	string ProfileName;

	// MUZZLE AXIS, the light half. BigMuzzle above is a bool and only
	// ever meant "heavy fire" for the smoke gate; it cannot say WHICH
	// flash, so a fire beat and a plasma beat flashed identically.
	//
	// Null is the normal case and means "say nothing" -- RS_Main does
	// not emit a muzzle light of its own any more, it defers to
	// GlowInTheDark's. A beat that names one is the exception, and it
	// LAYERS with GITD rather than replacing it: A_AttachLight is keyed
	// by name, GITD attaches "gitd_muzzle", this attaches
	// "rs_beat_muzzle", so both sit on the same pawn and add.
	Class<Actor> MuzzleFlash;

	// WHO PUT THIS BEAT HERE. Empty for a weapon's own authored
	// profiles; an affix sets it to its own class name when it installs.
	// Without it the only safe cleanup was "delete every PACK beat on the
	// gun", which meant Salvage and the eight Attune cards silently wiped
	// each other -- nine cards that could never coexist, with no message
	// saying so. An owned beat can be removed by its owner alone.
	string OwnerTag;

	// Per-BEAT granted keywords -- same shape and format as
	// RS_Weapon.GrantedKeywords, but scoped to this one profile instead
	// of the whole weapon. This is what lets rotation entry 2 behave
	// differently from entry 4 (e.g. "beat 2 is homing, beat 4 is a
	// delayed explosive") instead of a grant applying to every shot
	// regardless of which beat is up. RS_KeywordEffects reads the union
	// of the weapon's own grants and whichever profile is actually
	// firing.
	Array<string> LocalKeywords;

	// Idempotent, same reasoning as RS_Weapon.GrantKeyword -- an affix's
	// OnActivate can be called more than once without an intervening
	// OnDeactivate.
	void GrantLocal(string key, string value)
	{
		string entry = key .. ":" .. value;
		for (int i = 0; i < LocalKeywords.Size(); i++)
			if (LocalKeywords[i] == entry)
				return;
		LocalKeywords.Push(entry);
	}

	void UngrantLocal(string key, string value)
	{
		string entry = key .. ":" .. value;
		for (int i = 0; i < LocalKeywords.Size(); i++)
		{
			if (LocalKeywords[i] == entry)
			{
				LocalKeywords.Delete(i);
				return;
			}
		}
	}

	void GetLocalValues(string key, out Array<string> results)
	{
		string prefix = key .. ":";
		for (int i = 0; i < LocalKeywords.Size(); i++)
			if (LocalKeywords[i].Left(prefix.Length()) == prefix)
				results.Push(LocalKeywords[i].Mid(prefix.Length()));
	}

	// -----------------------------------------------------------------
	// Factories. Authoring a profile is one call, not eight assignments
	// at every call site -- and defaults mean a half-specified profile
	// still fires something safe rather than nothing.
	// -----------------------------------------------------------------

	// Shared neutral defaults, so a factory only has to name what it
	// actually differs on.
	private void InitDefaults()
	{
		Mode          = RS_ATK_BULLET;
		OwnerTag      = "";
		ExtraFireSound = "";
		MuzzleFlash   = null;
		PelletOverride = 0;
		SpreadScale   = 0.05;
		UsesChoke     = false;
		SpreadBonus   = 0.0;
		UsesCadence   = false;
		DamageMult    = 1.0;
		VelocityMult  = 1.0;
		CritBonus     = 0.0;
		AmmoCost      = 0;
		BigMuzzle     = false;
		MeleeRange    = 64.0;
		// Monster-side neutral defaults. VolleyCount 1 means every
		// existing weapon profile keeps firing exactly one shot's worth
		// of whatever its mode already did -- these fields are inert
		// unless a monster factory sets them.
		VolleyCount       = 1;
		VolleyArc         = 0.0;
		VolleyPitchJitter = 0.0;
		BurstDelayTics    = 0;              // 0 = all on one tic, as before
		FireTrigger       = RS_FIRE_MISSILE; // the overwhelming default
		ProjScale         = 0.0;   // 0 = derive from firer
		MinRange          = 0.0;
		MaxRange          = 0.0;   // 0 = unlimited
		SummonCount       = 0;
		SummonCap         = 0;
		SummonTierOffset  = -2;
		RadialRadius      = 0.0;
		RadialDamage      = 0;
		RadialHeal        = 0;
		RadialHitsAllies  = false;
		BuffSpeedMult     = 1.0;
		BuffDamageMult    = 1.0;
		BuffDuration      = 0;
		BuffNoPain        = false;
	}

	// Travelling-round volley -- the main-arsenal ballistic path.
	static RS_AttackProfile MakeBullet(
		sound fireSnd = "",
		double spreadScale = 0.05,
		bool usesCadence = true,
		int ammoCost = 1,
		string casing = "",
		bool bigMuzzle = false,
		bool usesChoke = false,
		double dmgMult = 1.0,
		Class<Actor> proj = null,
		string profName = "",
		Class<Actor> impactPuff = null,
		Class<Actor> impactSparks = null,
		Class<Actor> muzzleSmoke = null,
		Class<Actor> trail = null,
		sound extraFireSnd = "",
		Class<Ammo> ammo = null)
	{
		let p = RS_AttackProfile(new("RS_AttackProfile"));
		p.InitDefaults();
		p.Mode            = RS_ATK_BULLET;
		p.FireSound       = fireSnd;
		p.ExtraFireSound  = extraFireSnd;
		// Null = draw from the weapon's own magazine (AmmoType2), which is
		// what every magazine-fed family wants. A belt-fed weapon with no
		// magazine at all -- the chaingun draws straight from AmmoType1 --
		// has to name its pool, exactly as MakeHitscan already allowed.
		p.AmmoClass       = ammo;
		p.SpreadScale     = spreadScale;
		p.UsesCadence     = usesCadence;
		p.AmmoCost        = ammoCost;
		p.CasingClass     = casing;
		p.BigMuzzle       = bigMuzzle;
		p.UsesChoke       = usesChoke;
		p.DamageMult      = dmgMult;
		p.ProjectileClass = proj;
		p.ProfileName     = profName;
		p.ImpactPuff      = impactPuff;
		p.ImpactSparks    = impactSparks;
		p.MuzzleSmoke     = muzzleSmoke;
		p.Trail           = trail;
		return p;
	}

	// Instant trace. No projectile actor exists, so nothing carries the
	// GunBonsai master pointer -- see RS_Weapon's dispatch for the note.
	static RS_AttackProfile MakeHitscan(
		sound fireSnd = "",
		double spreadScale = 0.05,
		int ammoCost = 1,
		Class<Ammo> ammo = null,
		string casing = "",
		bool bigMuzzle = false,
		string profName = "",
		Class<Actor> impactPuff = null,
		Class<Actor> impactSparks = null,
		Class<Actor> muzzleSmoke = null)
	{
		let p = RS_AttackProfile(new("RS_AttackProfile"));
		p.InitDefaults();
		p.Mode        = RS_ATK_HITSCAN;
		p.FireSound   = fireSnd;
		p.SpreadScale = spreadScale;
		p.AmmoCost    = ammoCost;
		p.AmmoClass   = ammo;
		p.CasingClass = casing;
		p.BigMuzzle   = bigMuzzle;
		p.ProfileName = profName;
		p.ImpactPuff      = impactPuff;
		p.ImpactSparks    = impactSparks;
		p.MuzzleSmoke     = muzzleSmoke;
		return p;
	}

	// ammoCost DEFAULTS TO 1, not 0. Changed 2026-08-07.
	//
	// It used to default to 0, and MakeBullet/MakeHitscan beside it both
	// default to 1 -- so heavy was the one factory where forgetting the
	// field gave you a free shot instead of a paid one. That is not
	// hypothetical: it is exactly how the Rocket Launcher, Plasma Rifle
	// and BFG9000 shipped with infinite ammo for a month. A_RS_FireSlot
	// spends via the profile's AmmoCost and nothing else -- the vanilla
	// Weapon.AmmoUse machinery is dead weight in this mod -- so a 0 there
	// is a gun that fires forever, silently, with no error and no log.
	//
	// Verified safe: all 15 MakeHeavy call sites in the tree pass
	// ammoCost explicitly, so this changes no current behaviour. It only
	// makes the NEXT beat that forgets the field fail closed instead of
	// open -- and a generated one (PACK, an affix) is the likeliest place
	// for that to happen, since no human reads it.
	static RS_AttackProfile MakeHeavy(
		Class<Actor> proj = null,
		sound fireSnd = "",
		int ammoCost = 1,
		Class<Ammo> ammo = null,
		bool bigMuzzle = true,
		double spawnHeight = 0.0,
		double dmgMult = 1.0,
		string profName = "",
		Class<Actor> explosionVisual = null)
	{
		let p = RS_AttackProfile(new("RS_AttackProfile"));
		p.InitDefaults();
		p.Mode            = RS_ATK_HEAVY;
		p.ProjectileClass = proj;
		p.FireSound       = fireSnd;
		p.AmmoCost        = ammoCost;
		p.AmmoClass       = ammo;
		p.BigMuzzle       = bigMuzzle;
		p.SpawnHeight     = spawnHeight;
		p.DamageMult      = dmgMult;
		p.ProfileName     = profName;
		p.ExplosionVisual = explosionVisual;
		return p;
	}

	static RS_AttackProfile MakeMelee(
		double range = 64.0,
		sound fireSnd = "",
		Class<Actor> puff = null,
		bool bigMuzzle = true,
		double dmgMult = 1.0,
		string profName = "")
	{
		let p = RS_AttackProfile(new("RS_AttackProfile"));
		p.InitDefaults();
		p.Mode        = RS_ATK_MELEE;
		p.MeleeRange  = range;
		p.FireSound   = fireSnd;
		p.MeleePuff   = puff;
		p.BigMuzzle   = bigMuzzle;
		p.DamageMult  = dmgMult;
		p.ProfileName = profName;
		return p;
	}

	// -----------------------------------------------------------------
	// MONSTER-SIDE FACTORIES
	// -----------------------------------------------------------------
	// Same authoring style as the weapon factories above: one call, and
	// a half-specified profile still does something safe. These exist so
	// a monster's attack table reads as data -- "ring of 24 fireballs",
	// "summon two, cap four" -- instead of a wall of state code.
	// -----------------------------------------------------------------

	// A projectile volley. The workhorse: covers a single fireball, a
	// 3-shot spread, and a 36-shot ring with the same three arguments.
	static RS_AttackProfile MakeVolley(
		Class<Actor> proj,
		int count = 1,
		double arc = 0.0,
		sound fireSnd = "",
		double dmgMult = 1.0,
		double pitchJitter = 0.0,
		string profName = "")
	{
		let p = RS_AttackProfile(new("RS_AttackProfile"));
		p.InitDefaults();
		p.Mode              = RS_ATK_HEAVY;   // travels as a real projectile
		p.ProjectileClass   = proj;
		p.VolleyCount       = max(1, count);
		p.VolleyArc         = arc;
		p.VolleyPitchJitter = pitchJitter;
		p.FireSound         = fireSnd;
		p.DamageMult        = dmgMult;
		p.ProfileName       = profName;
		return p;
	}

	// A VOLLEY SPREAD OVER TIME. Same rounds, arriving apart instead of
	// together -- CHP's walking bursts, double-taps and refire loops.
	// This is MakeVolley with the two new shape axes exposed; it does not
	// add a mode, because a burst and a fan differ only in spacing.
	//
	//   MakeBurst(proj, 3, 2)            three rounds, 2 tics apart
	//   MakeBurst(proj, 3, 2, arc: 14)   the same, each with its own
	//                                    spread -- CHP's T05 walking burst
	//   trigger: RS_FIRE_PAIN            fired on being hurt, not aimed
	static RS_AttackProfile MakeBurst(
		Class<Actor> proj,
		int count = 3,
		int delayTics = 2,
		double arc = 0.0,
		sound fireSnd = "",
		double dmgMult = 1.0,
		double pitchJitter = 0.0,
		int trigger = RS_FIRE_MISSILE,
		string profName = "")
	{
		let p = MakeVolley(proj, count, arc, fireSnd, dmgMult, pitchJitter, profName);
		p.BurstDelayTics = max(0, delayTics);
		p.FireTrigger    = trigger;
		return p;
	}

	// Spawn minions. cap is a LIVE-pack cap, not a lifetime budget --
	// kill the pack and the summoner can rebuild it, which is what makes
	// a summoner fight a sustained threat rather than a burst.
	static RS_AttackProfile MakeSummon(
		Class<Actor> summonCls,
		int count = 2,
		int cap = 4,
		int tierOffset = -2,
		sound fireSnd = "",
		string profName = "")
	{
		let p = RS_AttackProfile(new("RS_AttackProfile"));
		p.InitDefaults();
		p.Mode             = RS_ATK_SUMMON;
		p.SummonClass      = summonCls;
		p.SummonCount      = max(1, count);
		p.SummonCap        = max(1, cap);
		p.SummonTierOffset = tierOffset;
		p.FireSound        = fireSnd;
		p.ProfileName      = profName;
		return p;
	}

	// Radius effect. Damage enemies, or heal/buff allies, or both.
	static RS_AttackProfile MakeRadial(
		double radius = 256.0,
		int damage = 0,
		int heal = 0,
		bool hitsAllies = false,
		sound fireSnd = "",
		string profName = "")
	{
		let p = RS_AttackProfile(new("RS_AttackProfile"));
		p.InitDefaults();
		p.Mode             = RS_ATK_RADIAL;
		p.RadialRadius     = radius;
		p.RadialDamage     = damage;
		p.RadialHeal       = heal;
		p.RadialHitsAllies = hitsAllies;
		p.FireSound        = fireSnd;
		p.ProfileName      = profName;
		return p;
	}

	// Temporary self stat spike. Reverts itself -- see
	// a monster-side pulse, when one exists.
	static RS_AttackProfile MakeSelfBuff(
		double speedMult = 1.5,
		double damageMult = 1.0,
		int duration = 105,
		bool noPain = false,
		sound fireSnd = "",
		string profName = "")
	{
		let p = RS_AttackProfile(new("RS_AttackProfile"));
		p.InitDefaults();
		p.Mode           = RS_ATK_SELFBUFF;
		p.BuffSpeedMult  = speedMult;
		p.BuffDamageMult = damageMult;
		p.BuffDuration   = duration;
		p.BuffNoPain     = noPain;
		p.FireSound      = fireSnd;
		p.ProfileName    = profName;
		return p;
	}

	// Is this profile usable at the given distance? MaxRange 0 means no
	// ceiling, which is the default, so profiles that never set a band
	// are always eligible.
	bool InRange(double dist) const
	{
		if (dist < MinRange) return false;
		if (MaxRange > 0 && dist > MaxRange) return false;
		return true;
	}

	bool HasRangeBand() const
	{
		return MinRange > 0 || MaxRange > 0;
	}

	// Independent copy -- so a GunBonsai upgrade that tweaks one entry in
	// a cycle can't accidentally mutate a profile shared with another
	// weapon or another slot.
	RS_AttackProfile Clone()
	{
		let p = RS_AttackProfile(new("RS_AttackProfile"));
		p.Mode            = Mode;
		p.ProjectileClass = ProjectileClass;
		p.PelletOverride  = PelletOverride;
		p.SpreadScale     = SpreadScale;
		p.UsesChoke       = UsesChoke;
		p.SpreadBonus     = SpreadBonus;
		p.UsesCadence     = UsesCadence;
		p.DamageMult      = DamageMult;
		p.VelocityMult    = VelocityMult;
		p.CritBonus       = CritBonus;
		p.AmmoClass       = AmmoClass;
		p.AmmoCost        = AmmoCost;
		p.FireSound       = FireSound;
		// Was MISSING. PACK is its only producer (RS_PACKAssembly.Build
		// passes extraFireSnd) and it is the field the 2026-08-08 fix moved
		// the theme voice onto so a caco beat would stop silencing the
		// shotgun. A cloned beat kept every part and lost its voice --
		// exactly the regression that fix was written to prevent.
		p.ExtraFireSound  = ExtraFireSound;
		p.CasingClass     = CasingClass;
		p.BigMuzzle       = BigMuzzle;
		p.SpawnHeight     = SpawnHeight;
		p.ImpactPuff      = ImpactPuff;
		p.ImpactSparks    = ImpactSparks;
		p.MuzzleSmoke     = MuzzleSmoke;
		p.Trail           = Trail;
		p.ExplosionVisual = ExplosionVisual;
		p.MeleeRange      = MeleeRange;
		p.MeleePuff       = MeleePuff;
		p.VolleyCount     = VolleyCount;
		p.VolleyArc       = VolleyArc;
		p.VolleyPitchJitter = VolleyPitchJitter;
		// A field missing from Clone() is a silent bug: Echo rebuilds
		// itself from SavedOriginal.Clone() every activation, so anything
		// not copied here quietly reverts to its default on the copy.
		p.BurstDelayTics  = BurstDelayTics;
		p.FireTrigger     = FireTrigger;
		p.ProjScale       = ProjScale;
		p.MinRange        = MinRange;
		p.MaxRange        = MaxRange;
		p.SummonClass     = SummonClass;
		p.SummonCount     = SummonCount;
		p.SummonCap       = SummonCap;
		p.SummonTierOffset = SummonTierOffset;
		p.RadialRadius    = RadialRadius;
		p.RadialDamage    = RadialDamage;
		p.RadialHeal      = RadialHeal;
		p.RadialHitsAllies = RadialHitsAllies;
		p.BuffSpeedMult   = BuffSpeedMult;
		p.BuffDamageMult  = BuffDamageMult;
		p.BuffDuration    = BuffDuration;
		p.BuffNoPain      = BuffNoPain;
		p.ProfileName     = ProfileName;
		p.OwnerTag        = OwnerTag;
		p.MuzzleFlash     = MuzzleFlash;
		for (int i = 0; i < LocalKeywords.Size(); i++)
			p.LocalKeywords.Push(LocalKeywords[i]);
		return p;
	}
}

// =====================================================================
// RS_AttackSlot -- one trigger's worth of attacks.
// ---------------------------------------------------------------------
// The cursor is deliberately NOT a player-facing selector. Within a
// slot the player has no control over which entry comes next: pulling
// the trigger advances the rotation, always, in order. Deliberate
// choice happens BETWEEN slots (main trigger vs alt-fire), not inside
// one.
// =====================================================================
class RS_AttackSlot : Object
{
	Array<RS_AttackProfile> Profiles;
	int Cursor;

	int Count()
	{
		return Profiles.Size();
	}

	bool IsEmpty()
	{
		return Profiles.Size() == 0;
	}

	// The profile that WOULD fire next, without advancing. Used by menus
	// and upgrade cards that want to show the rotation without touching it.
	RS_AttackProfile Peek()
	{
		if (Profiles.Size() == 0)
			return null;
		return Profiles[Cursor % Profiles.Size()];
	}

	RS_AttackProfile PeekAt(int index)
	{
		if (index < 0 || index >= Profiles.Size())
			return null;
		return Profiles[index];
	}

	// Read the current profile, THEN step the rotation forward. This is
	// the only thing that moves the cursor.
	RS_AttackProfile Advance()
	{
		int n = Profiles.Size();
		if (n == 0)
			return null;
		let p = Profiles[Cursor % n];
		Cursor = (Cursor + 1) % n;
		return p;
	}

	void ResetCursor()
	{
		Cursor = 0;
	}

	// --- Mutators. These are the GunBonsai write targets. ---

	void Append(RS_AttackProfile p)
	{
		if (p) Profiles.Push(p);
	}

	// Insert at a position so an upgrade can land on a specific beat of
	// the rotation ("every 3rd shot" wants index 2, not the tail).
	void InsertAt(int index, RS_AttackProfile p)
	{
		if (!p) return;
		if (index < 0) index = 0;
		if (index >= Profiles.Size())
		{
			Profiles.Push(p);
			return;
		}
		Profiles.Insert(index, p);
	}

	// Swap one entry out without disturbing the rest of the rotation.
	void Replace(int index, RS_AttackProfile p)
	{
		if (!p || index < 0 || index >= Profiles.Size()) return;
		Profiles[index] = p;
	}

	void RemoveAt(int index)
	{
		if (index < 0 || index >= Profiles.Size()) return;
		Profiles.Delete(index);
		if (Profiles.Size() == 0) Cursor = 0;
		else Cursor = Cursor % Profiles.Size();
	}

	void Clear()
	{
		Profiles.Clear();
		Cursor = 0;
	}

	// Pad the rotation with copies of an existing entry. This is what
	// turns "add an explosive shot" into "every THIRD shot is explosive":
	// author [normal], PadTo(3) -> [normal, normal, normal], then
	// Replace(2, explosive) -> [normal, normal, explosive].
	void PadTo(int length, RS_AttackProfile filler)
	{
		if (!filler) return;
		while (Profiles.Size() < length)
			Profiles.Push(filler.Clone());
	}

	// -----------------------------------------------------------------
	// PAD, AND BILL THE PADDING TO WHOEVER ASKED FOR IT.
	//
	// THE BUG THIS EXISTS TO FIX. PadTo above clones PeekAt(0) -- the
	// gun's OWN authored beat, whose OwnerTag is "". So padding clones
	// belonged to nobody, and nothing could ever remove them:
	// UninstallOwned matches on OwnerTag, UninstallAll matches on the
	// "PACK: " name prefix, and a pad clone has neither.
	//
	// Combined with `while (Size() < length)` -- which grows a slot and
	// can never shrink one -- a rotation could only ratchet upward.
	// Walk Salvage, whose card text promises every 4th, then 3rd, then
	// 2nd:
	//
	//   L1  [own] -> pad to 3 -> [own,own,own] + PACK = 4.  Every 4th.
	//   L2  UninstallOwned drops the PACK beat, leaving the 3 unowned
	//       clones. rot=3, so PadSlotTo(0,2) is a no-op. Append = 4.
	//       Card says every 3rd. Player still gets every 4th.
	//   L4  rot=2, pad to 1 is a no-op, append = 4. Still every 4th.
	//
	// Salvage never delivered anything past level 1, and neither did any
	// of the eight Attune cards. Worse, it outlived the card: deactivate
	// is also UninstallOwned, so a gun that once held Salvage kept a
	// 3-long slot forever and set the floor for the next card installed.
	//
	// Stamping the clones makes the whole cycle reversible -- uninstall
	// takes the slot back to the gun's authored beats, and the next
	// install re-pads to the new, possibly SHORTER, length.
	// -----------------------------------------------------------------
	// Remove every profile carrying this owner tag, leaving everyone
	// else's alone. The slot-level counterpart to
	// RS_PACKAssembly.UninstallOwned, for cards that rebuild a rotation
	// in place rather than installing a single beat.
	//
	// Written because TFLV_Upgrade_RS_Echo called Clear() -- wiping the
	// WHOLE slot, PACK beats and all. Its suitability check only guards
	// the FIRST take (it requires Count() == 1), so taking Echo, then
	// Salvage, then levelling Echo destroyed Salvage's beat with nothing
	// reporting it.
	void RemoveOwnedBy(string ownerTag)
	{
		if (ownerTag == "") return;
		for (int i = Profiles.Size() - 1; i >= 0; i--)
		{
			let p = Profiles[i];
			if (p && p.OwnerTag == ownerTag)
				Profiles.Delete(i);
		}
		if (Cursor >= Profiles.Size())
			Cursor = 0;
	}

	void PadToOwned(int length, RS_AttackProfile filler, string ownerTag)
	{
		if (!filler) return;
		while (Profiles.Size() < length)
		{
			let c = filler.Clone();
			c.OwnerTag = ownerTag;
			Profiles.Push(c);
		}
	}
}
