// WHAT A HAND IS ALLOWED TO PULL, AS DATA.
//
// Ported from RS_WorldHands rs_grabpolicy.zs. The table, its order, its weights
// and its reasons are the desktop's, and so is the argument for it:
//
//   The distinction is not derivable. Nothing on an actor says "this is a thing
//   with a shape you could close a hand around" as opposed to "this is a number
//   that happens to be on the floor". Doom gives a medikit and a health bonus
//   the same flags and very nearly the same collision cylinder.
//
// So it is an ordered table, FIRST MATCH WINS, specific above general: a rule
// for HealthBonus has to be able to overrule the rule for Inventory.
//
// WHAT THIS REPLACED, and why it was the first thing to fix. cone.zs used to
// allow anything with bSPECIAL, and anything bSOLID that was in the blockmap.
// The second half meant every tech column, lamp, tree and pillar in a map could
// be pulled across the room. The first half meant a +1 health bonus argued as
// hard as a medikit.
//
// WHAT DID NOT COME ACROSS, and why. The desktop rule carried a GRIPSUBJ_*
// subject and a POSE_* hand shape. GRIPSUBJ_* is a FORK ENGINE CONSTANT -- zero
// hits in stock qzd17.3's wadsrc and zero declarations in the desktop's own
// zscript -- so the file did NOT "port as-is" the way the lane-1 survey said; a
// verbatim copy fails to compile. Both fields exist for the fork's grip arbiter
// and the hand models, neither of which exists here, so they are dropped rather
// than stubbed. Also dropped: the walk-over suppression (a near-grab feature
// that would make every pickup in the level unwalkable) and OnTake's
// ammo-pouch branch (no pouch on Quest). The catch's own consume rule lives in
// flight.zs.
//
// A StaticEventHandler, NOT a level one. The table is derived data, rebuilt
// from code every session. Serialising it is the exact trap the desktop header
// warns about -- a restored "built" flag sitting over an array that did not
// come back -- and the fix is to never save it at all.

class RSQDG_Rule : Object
{
	Class<Actor> cls;
	bool   allow;
	Name   category;   // which menu switch governs it, 'None' for always
	String why;        // named, so the trace says WHICH rule decided
	double weight;     // how hard it competes for the hand. 1.0 = neutral

	// WEIGHT IS A PREFERENCE, NOT A GATE -- the desktop's rule, kept exactly.
	//
	// The cone admits on raw geometry (inside the cone and in reach, or not) and
	// only the RANKING among things already admitted is weighted. So nothing
	// becomes ungrabbable: point at a medikit with nothing else in the cone and
	// you get the medikit. Weight decides ties and near-ties and can never veto,
	// which is what makes it safe to be blunt with the numbers.
	//
	// Same scale as the desktop: weight 4 "counts as half as far off", weight
	// 0.25 "counts as twice as far". cone.zs divides its cost by sqrt(weight).
}

class RSQDG_Policy : StaticEventHandler
{
	// No weight may exceed this. cone.zs prunes with its square root, so the cap
	// is what keeps that shortcut exact. 16 = "counts as a quarter as far off",
	// which is already more preference than any sane rule wants.
	const MAX_WEIGHT = 16.0;

	private Array<RSQDG_Rule> rules;

	// THE CORPSE ANSWER, ONE OBJECT, REFILLED. The corpse rule turns on STATE,
	// not class -- the same imp is a monster and then a prop a second apart -- so
	// it is built when asked. Asked means per corpse per candidate per hand per
	// tic, on a floor after a firefight, on a Quest. One instance, every field
	// rewritten every time, so nothing stale survives from the last corpse.
	private RSQDG_Rule corpseRule;

	// THE RULE SERVICE, FOUND ONCE. Services are engine singletons made at
	// startup (service.zs AllServices), so the lookup -- a new iterator and a
	// MakeLower of every service name -- belongs in a cache, not in Decide(),
	// which runs per in-cone candidate per hand per tic and again per lock.
	// This handler is static, so the cache lives exactly as long as they do.
	private RSQDG_GrabRuleService ruleSvc;
	private bool ruleSvcLooked;

	// The TNT1 sprite's index, looked up once (OnRegister).
	private SpriteID tnt1;

	RSQDG_GrabRuleService RuleService()
	{
		if (!ruleSvcLooked) { ruleSvc = RSQDG_GrabRuleService.Find(); ruleSvcLooked = true; }
		return ruleSvc;
	}

	static RSQDG_Policy Get()
	{
		return RSQDG_Policy(StaticEventHandler.Find("RSQDG_Policy"));
	}

	// INHERITANCE-AWARE, which is the whole reason this is not a name compare. A
	// rule for Ammo covers every shell box in every mod that derived from it, and
	// `is` cannot help because it needs the class at compile time. Class<Object>
	// for the walk because GetParentClass returns one, and narrowing it back into
	// a Class<Actor> is a conversion the compiler refuses.
	static bool Inherits(Actor a, Class<Actor> want)
	{
		if (!a || !want) return false;
		Class<Object> c = a.GetClass();
		Class<Object> w = want;
		while (c)
		{
			if (c == w) return true;
			c = c.GetParentClass();
		}
		return false;
	}

	// The same walk for a class rather than an actor, for rules registered by
	// class name. A missing want (not loaded) is simply false.
	static bool InheritsClass(Class<Actor> c, Name wantName)
	{
		Class<Actor> want = wantName;
		return IsA(c, want);
	}

	static bool IsA(Class<Actor> c, Class<Actor> want)
	{
		if (!c || !want) return false;
		Class<Object> k = c;
		Class<Object> w = want;
		while (k)
		{
			if (k == w) return true;
			k = k.GetParentClass();
		}
		return false;
	}

	// ---- WHAT A THING STANDS IN FOR -------------------------------------
	//
	// A REPLACEMENT IS NOT A SUBCLASS, and Brutal Doom is the proof. BD v22
	// declares `ACTOR ExplosiveBarrel1 Replaces ExplosiveBarrel` with NO parent,
	// and `HealthPlus : Health Replaces HealthBonus`. Matching on inheritance
	// alone made every BD barrel unpullable and let every BD +1 bonus through
	// the Health rule. (Found against brutal22test6, 2026-10-26.)
	//
	// So a class also answers to whatever it REPLACES, walked up the chain
	// (a mod replacing a mod's replacement), and the table's order still
	// decides: HealthPlus reaches the HealthBonus DENY before the Health allow,
	// because the deny is higher in the table. This makes the table hold for
	// every replacement mod at once, with no line naming any of them.
	const MAX_REPLACE_DEPTH = 4;

	static bool StandsFor(Class<Actor> c, Class<Actor> want)
	{
		for (int d = 0; c && d <= MAX_REPLACE_DEPTH; d++)
		{
			if (IsA(c, want)) return true;
			Class<Actor> r = Actor.GetReplacee(c);
			if (!r || r == c) break;
			c = r;
		}
		return false;
	}

	// THE TABLE'S ANSWER PER CLASS, CACHED. The answer depends only on the
	// class (the menu switches and ownership are checked after), and walking
	// 25 rules x an inheritance chain x a replacement chain per candidate per
	// tic is exactly the cost a Quest cannot spare. -1 = no rule matches.
	private Array<Class<Actor> > memoCls;
	private Array<int>           memoIdx;

	private int RuleIndexFor(Class<Actor> c)
	{
		for (int m = 0; m < memoCls.Size(); m++)
			if (memoCls[m] == c) return memoIdx[m];
		int found = -1;
		for (int i = 0; i < rules.Size(); i++)
		{
			if (StandsFor(c, rules[i].cls)) { found = i; break; }
		}
		memoCls.Push(c);
		memoIdx.Push(found);
		return found;
	}

	private void Rule(Name clsName, bool allow, Name category, String why, double weight = 1.0)
	{
		// A CLASS THAT DOES NOT EXIST IS NOT AN ERROR. The table names Doom
		// classes and loads under Heretic and Hexen too. A missing class is a
		// rule that can never match, which is the correct outcome.
		// A Name assigned to a class type is resolved AT RUNTIME by the
		// compiler's class cast -- the same form the desktop table used. Not
		// Object.FindClass: that helper is in 9afc750's base.zs but NOT in the
		// earlier 17.x engine pk3 (ZScript 4.12), and this has to load on both.
		Class<Actor> c = clsName;
		if (!c) return;

		let r = RSQDG_Rule(new("RSQDG_Rule"));
		r.cls      = c;
		r.allow    = allow;
		r.category = category;
		r.why      = why;
		// Zero or negative is a typo in a table line, not a request to divide by
		// zero inside a per-tic blockmap scan.
		r.weight   = (weight > 0) ? min(weight, MAX_WEIGHT) : 1.0;
		rules.Push(r);
	}

	private void Deny(Name clsName, String why)
	{
		Rule(clsName, false, 'None', why);
	}

	// ---- THE TABLE -------------------------------------------------------
	//
	// Guarded on the table being empty, not on a flag: a flag and the thing it
	// describes are two pieces of state that can disagree.
	private void Build()
	{
		if (rules.Size() > 0) return;

		// -- denied, and specific, so these sit above the general allows ------

		// The "+1" pickups. A health bonus is not a small medikit, it is a
		// number with a sprite. Walk over them.
		Deny('HealthBonus', "a +1 is a number, not an object");
		Deny('ArmorBonus',  "a +1 is a number, not an object");

		// -- the powerups: their own switch, OFF by default --------------------
		//
		// The desktop denied these outright -- "a hand closing on one raises the
		// question of what happens when you let go of a soulsphere, which has no
		// good answer". That holds for a hand. For a pull it has an answer --
		// catch it and it is used, exactly as walking into it would -- and pulling
		// the megasphere off the ledge you cannot reach is the most Force-like
		// thing this mechanic can do. So: off by default, which is the desktop's
		// behaviour, and one switch away for anyone who wants it.
		Rule('Soulsphere',            true, 'Powerups', "a powerup");
		Rule('Megasphere',            true, 'Powerups', "a powerup");
		Rule('InvulnerabilitySphere', true, 'Powerups', "a powerup");
		Rule('Blursphere',            true, 'Powerups', "a powerup");
		Rule('Infrared',              true, 'Powerups', "a powerup");
		Rule('RadSuit',               true, 'Powerups', "a powerup");
		Rule('Allmap',                true, 'Powerups', "a powerup");
		Rule('Berserk',               true, 'Powerups', "a powerup");

		// -- allowed, specific ---------------------------------------------

		// The barrel. The single most satisfying thing in Doom to pull across a
		// room. The heaviest weight in the table, 4.0 -- it competes as though
		// at half the distance -- so the shell box beside it does not quietly
		// win the barrel you were plainly pointing at.
		Rule('ExplosiveBarrel', true, 'Barrels', "a barrel", 4.0);

		// THE OTHER BARREL, unrelated to the first in any way the engine can
		// see: `class BurningBarrel : Actor`, a +SOLID decoration. Nothing
		// inherits from anything, so the rule above never covered it -- and the
		// prop that most reads as "a barrel you could pick up" was the one you
		// could not. Added on desktop 2026-08-28 on exactly that report.
		Rule('BurningBarrel', true, 'Barrels', "a burning barrel", 4.0);

		// -- allowed, general ------------------------------------------------

		// Ammunition. Below neutral: the most numerous thing on a cleared floor
		// and the least interesting to have chosen for you.
		Rule('Ammo', true, 'None', "ammunition", 0.6);

		// Weapons. ON by default here, against the desktop, and for a reason
		// that only exists at range: the desktop's objection was that taking a
		// shotgun off the floor by hand is a whole interaction. Pulling it to
		// you is not -- it is the pickup, from further away -- and this package
		// has always done it. Weighted UP so the gun does not lose to the clip
		// lying next to it.
		Rule('Weapon', true, 'Weapons', "a weapon", 2.0);

		// BRUTAL DOOM'S GUNS ARE NOT WEAPONS. BD v22's floor guns are
		// `BDWeaponSpawner : CustomInventory` -- a pickup whose Pickup state
		// GIVES the weapon -- and they neither inherit nor replace a Doom
		// weapon (the replacer that does is an invisible spawner, refused
		// above). Without this line they still pull, through the catch-all,
		// but at pickup weight and ignoring the Weapons switch. A class that is
		// not loaded is skipped, so this line costs nothing without BD.
		Rule('BDWeaponSpawner', true, 'Weapons', "a weapon (Brutal Doom)", 2.0);

		// Health and armour, the real ones -- the bonuses were denied above.
		Rule('Health', true, 'None', "a health item", 0.6);
		Rule('Armor',  true, 'None', "armour", 0.6);

		// Keys. There are never many, reaching for one is always deliberate,
		// and a keycard is small enough that something duller is easily nearer.
		Rule('Key', true, 'None', "a key", 2.0);

		// The catch-all for anything else a mod leaves in the world. LAST, so
		// every rule above overrules it. Neutral, and here neutral is the
		// considered answer: we do not know what this is, and pure geometry is
		// the honest ranking for that.
		Rule('Inventory', true, 'None', "a pickup in the world", 1.0);
	}

	override void OnRegister()
	{
		tnt1 = Actor.GetSpriteIndex('TNT1');
		Build();
	}

	// ---- the switches ----------------------------------------------------
	//
	// Fallbacks match CVARINFO exactly. A fallback that disagrees with the
	// shipped default is a system that behaves differently depending on whether
	// a lookup succeeded -- the worst kind of intermittent.
	static bool CategoryOn(Name cat, PlayerInfo p)
	{
		if (cat == 'Barrels')  return RSQDG_Reach.Flag("rsqdg_barrels",  p, true);
		if (cat == 'Weapons')  return RSQDG_Reach.Flag("rsqdg_weapons",  p, true);
		if (cat == 'Powerups') return RSQDG_Reach.Flag("rsqdg_powerups", p, false);
		if (cat == 'Corpses')  return RSQDG_Reach.Flag("rsqdg_corpses",  p, false);
		return true;
	}

	// ---- the question ----------------------------------------------------
	//
	// Null means no. The RULE comes back rather than a bool, so the caller gets
	// the weight and the reason out of the same decision.
	RSQDG_Rule Decide(Actor a, PlayerPawn pmo, PlayerInfo p)
	{
		if (!a || a == pmo || !p) return null;

		// Never, whatever the table says. These are the difference between an
		// object and a thing that is not there.
		if (a.bNOINTERACTION) return null;
		if (a.bMISSILE)       return null;      // in flight, not on the floor
		if (a.player)         return null;      // another player
		if (a.Radius <= 0 || a.Height <= 0) return null;

		// DELIBERATELY HIDDEN IS NOT THERE. An invisible or unrendered actor is
		// not a pickup, and locking one draws a beam at empty air. GetRenderStyle
		// rather than RenderStyle: the field is private (actor.zs), the method
		// is the public clearscope read.
		//
		if (a.bINVISIBLE || a.GetRenderStyle() == STYLE_None) return null;

		// AND A TNT1 FRAME IS NOTHING TO SEE. Brutal Doom v22 leaves its
		// weapon spawner REPLACERS lying where the map's guns were -- a
		// Health-derived item parked on `TNT1 A -1` forever, next to the real
		// pickup it spawned (WeaponSpawners.dec ShotgunSpawnerReplacer). It
		// stands for a Shotgun, so the table would happily lock it at weapon
		// weight: a beam at empty air that outranks the gun beside it. Found
		// against brutal22test6, 2026-10-26.
		//
		// The cost, stated: a mod that renders a MODEL on a TNT1 frame would
		// lose those things to this test. ModelSwapper does not -- its BD22
		// MODELDEF states "TNT1 keys removed (TNT1 means draw nothing in
		// BD22)" -- and pickups drawn that way are rare.
		if (a.sprite == tnt1) return null;

		// A DYING PROP IS NOT A PROP. A barrel that has been shot is in its
		// death sequence for a moment before it explodes; pulling it then
		// delivers the explosion to your palm. Something that can be killed,
		// is not a monster, and is out of health is on its way out.
		if (!a.bISMONSTER && a.default.bSHOOTABLE && a.Health <= 0) return null;

		// LIVING THINGS ARE NOT PROPS. "It is a way of deleting monsters. A
		// corpse is a prop, and one worth having." State, not class -- so not in
		// the table.
		if (a.bISMONSTER)
		{
			if (a.Health > 0) return null;
			if (!CategoryOn('Corpses', p)) return null;

			if (!corpseRule) corpseRule = RSQDG_Rule(new("RSQDG_Rule"));
			corpseRule.cls      = a.GetClass();
			corpseRule.allow    = true;
			corpseRule.category = 'Corpses';
			corpseRule.why      = "a corpse";
			// THE LOWEST WEIGHT IN THE SYSTEM. A corpse is a large cylinder
			// lying exactly where the fighting was -- where you are standing --
			// so on pure geometry a body beats almost anything worth having.
			// 0.25: it competes as though twice as far off.
			corpseRule.weight   = 0.25;
			return corpseRule;
		}

		// WHAT A MOD SAID ABOUT ITS OWN THING BEATS THE TABLE. A rule naming a
		// class was written by whoever made it. Ownership is still checked: a
		// registered rule says what a thing IS, not that it is on the floor.
		let svc = RuleService();
		if (svc)
		{
			bool known;
			let r = svc.Match(a, known);
			if (known)
			{
				if (!r) return null;           // the mod said no
				if (!CategoryOn(r.category, p)) return null;
				let rinv = Inventory(a);
				if (rinv && rinv.Owner) return null;
				return r;
			}
		}

		Build();
		int ri = RuleIndexFor(a.GetClass());
		if (ri >= 0)
		{
			let r = rules[ri];
			if (!r.allow) return null;
			if (!CategoryOn(r.category, p)) return null;

			// OWNERSHIP, not SPECIAL, decides whether an Inventory is on the
			// floor. One with an Owner is in somebody's pockets and is not a
			// thing in the room at all. (Flight clears SPECIAL deliberately;
			// asking SPECIAL here would make a dropped pull ungrabbable.)
			let inv = Inventory(a);
			if (inv && inv.Owner) return null;
			return r;
		}
		return null;
	}
}

// ---------------------------------------------------------------------------
// A MOD REGISTERS ITS OWN GRABBABLE THING, AT RUNTIME, BY STRING.
//
// The desktop protocol, so a mod written for one family speaks to the other:
// find every Service whose name contains "GrabRuleService", check
// "grab.hello", then
//
//   GetInt("grab.rule",   "<class>", subject, pose, null, '<mod>')   allow it
//   GetInt("grab.weight", "<class>", twohand, weight)                tune it
//   GetInt("grab.forget", "<class>")                                 remove it
//   GetInt("grab.deny",   "<class>", 0, 0, null, '<mod>')            refuse it   (Quest addition)
//
// subject, pose and twohand are accepted and ignored here -- see the header of
// RSQDG_Policy for why they have no meaning on stock. A string, never a class
// reference, because a ZScript reference to a pk3 that is absent is fatal and
// global: it takes down every mod after it in the load order.
//
// Registered rules sit ABOVE the built-in table and are inheritance-aware the
// same way. Services are engine singletons created at startup and never
// serialised, so a mod re-registers in its own OnRegister; re-registering a
// class REPLACES its rule rather than stacking another.
// ---------------------------------------------------------------------------
class RSQDG_GrabRuleService : Service play
{
	private Array<RSQDG_Rule> added;

	static RSQDG_GrabRuleService Find()
	{
		let it = ServiceIterator.Find("RSQDG_GrabRuleService");
		Service s;
		while (s = it.Next())
		{
			let g = RSQDG_GrabRuleService(s);
			if (g) return g;
		}
		return null;
	}

	// The first registered rule matching this actor. `known` says whether any
	// rule matched at all, because a matching DENY returns null and must not be
	// mistaken for "no opinion".
	RSQDG_Rule Match(Actor a, out bool known)
	{
		known = false;
		for (int i = 0; i < added.Size(); i++)
		{
			let r = added[i];
			if (!r.cls) continue;
			if (!RSQDG_Policy.StandsFor(a.GetClass(), r.cls)) continue;
			known = true;
			return r.allow ? r : null;
		}
		return null;
	}

	private int Put(String clsName, bool allow, Name who)
	{
		Name n = clsName;
		Class<Actor> c = n;
		if (!c) return 0;   // not loaded: a rule that can never match. Not an error.
		for (int i = 0; i < added.Size(); i++)
		{
			if (added[i].cls == c) { added.Delete(i); break; }
		}
		let r = RSQDG_Rule(new("RSQDG_Rule"));
		r.cls      = c;
		r.allow    = allow;
		// THE MENU SWITCHES STILL APPLY. A mod's own gun is a gun: if the player
		// has switched weapons off, a registered weapon must not slip through
		// on a rule that names no category. Inferred from what it IS.
		Class<Actor> wcls = 'Weapon';
		Class<Actor> eb = 'ExplosiveBarrel';
		Class<Actor> bb = 'BurningBarrel';
		r.category = RSQDG_Policy.StandsFor(c, wcls) ? 'Weapons'
		           : (RSQDG_Policy.StandsFor(c, eb) || RSQDG_Policy.StandsFor(c, bb)) ? 'Barrels'
		           : 'None';
		r.weight   = 1.0;
		r.why      = String.Format("%s by %s", allow ? "registered" : "refused", who);
		added.Push(r);
		return 1;
	}

	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		// IDENTITY, not presence -- ServiceIterator matches a case-insensitive
		// SUBSTRING, so every consumer checks a hello first.
		if (request ~== "grab.hello") return 1;
		if (request ~== "grab.rule")  return Put(stringArg, true,  nameArg);
		if (request ~== "grab.deny")  return Put(stringArg, false, nameArg);

		if (request ~== "grab.weight")
		{
			Name n = stringArg;
			Class<Actor> c = n;
			if (!c) return 0;
			for (int i = 0; i < added.Size(); i++)
			{
				if (added[i].cls != c) continue;
				if (doubleArg > 0) added[i].weight = min(doubleArg, RSQDG_Policy.MAX_WEIGHT);
				return 1;
			}
			return 0;
		}

		if (request ~== "grab.forget")
		{
			Name n = stringArg;
			Class<Actor> c = n;
			if (!c) return 0;
			for (int i = 0; i < added.Size(); i++)
			{
				if (added[i].cls != c) continue;
				added.Delete(i);
				return 1;
			}
			return 0;
		}
		return 0;
	}
}
