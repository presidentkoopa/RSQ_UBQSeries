// WHAT A THING WEIGHS, in kilograms.
//
// Ported from RS_WorldHands rs_mass.zs, near-verbatim. It is the dependency the
// impulse-and-steer flight was chosen for (DECISIONS D9): a written path cannot
// carry mass, an impulse can -- but only if it has a mass to carry. Until this
// file, flight.zs steered on Actor.Mass, and the desktop header says exactly
// why that is worthless:
//
//   It defaults to 100 on every actor, and the engine reads it for exactly one
//   thing -- ApplyKickback's thrust divisor. So a Clip and a Cyberdemon both
//   report 100, and an INHERITED 100 cannot be told apart from a deliberate 100.
//
// So every non-monster flew identically, which was the very failing the flight
// design existed to fix.
//
// THE ORDER, each step there because the one after it is wrong for that case:
//
//   1  MASSDEF, a per-class lump ANY pk3 may ship. The authored answer.
//   2  The class's ANCESTORS in MASSDEF. A mod's clip that inherits Clip gets
//      Clip's mass with nobody writing a line for it.
//   3  A weapon weight service, if a weapons pack that measures guns is loaded.
//   4  Monsters: Doom Mass, which for monsters WAS authored (50 Lost Soul, 400
//      Cacodemon, 1000 Cyberdemon -- close enough to kilograms).
//   5  Bounding volume x a density, CLAMPED HARD. A guess, and it says so.
//
// THE LUMP KEEPS THE DESKTOP NAME AND FORMAT, MASSDEF, on purpose. It is a
// shared data format across the family: a weapons pack that ships a MASSDEF
// for its own pickups is read by this, and by the desktop hands, without
// either knowing the other exists. All MASSDEF lumps are read, in load order,
// and a later line for the same class wins.
//
// FIXED WORLD SCALE, NEVER vr_vunits_per_meter. That is the player's room-scale
// comfort setting; running mass through it would make a barrel weigh one thing
// on one machine and another on the next. 32 units to the metre is Doom's own
// scale for the volume guess -- and it is deliberately NOT the 34/28.3 of
// reach.zs, which converts the ROOM, not the object.

class RSQDG_Mass play
{
	const UNITS_PER_METRE = 32.0;

	// 300 kg/m^3: between softwood and a hollow steel drum. Right for "a Doom
	// object" and wrong for everything specific, which is why MASSDEF exists.
	const DEFAULT_DENSITY = 300.0;

	// THE CLAMPS ARE NOT TIDINESS. A default 20-radius, 16-high collision box
	// through any sensible density is ~190 kg for a pistol clip, because the
	// box is a pickup trigger and has nothing to do with the object. Inside
	// these bounds a wrong answer is a mildly odd pull. Outside them it is a
	// medikit that cannot be lifted.
	const INV_MIN  = 0.1;
	const INV_MAX  = 5.0;
	const PROP_MIN = 1.0;
	const PROP_MAX = 200.0;

	// MASSDEF's trailing words, kept for format compatibility with the desktop
	// lump. Nothing in the pull reads them yet; they are parsed so a shared
	// MASSDEF line is never rejected for having them.
	const FLIGHT_FLUTTER = 1;
	const FLIGHT_EXPLODE = 2;

	static double Kg(Actor a)
	{
		if (!a) return 0;

		let t = RSQDG_MassTable.Get();

		// A LINE NAMING THIS EXACT CLASS beats everything: somebody stated it.
		if (t)
		{
			int e = t.FindExact(a.GetClass());
			if (e >= 0 && t.dMass[e] > 0) return t.dMass[e];
		}

		// THEN A MEASURED GUN, BEFORE ANY INHERITED LINE. A mod's rifle that
		// derives from Shotgun would otherwise take the vanilla Shotgun row off
		// its parent and never ask the weapons pack that actually weighed it.
		// (Found in review, 2026-10-26: the ancestor walk ran first.)
		double lb = GunPounds(a);
		if (lb > 0) return lb * 0.45359237;

		// Then the ancestors' lines: a mod's clip deriving from Clip.
		if (t)
		{
			int i = t.FindFor(a.GetClass());
			if (i >= 0 && t.dMass[i] > 0) return t.dMass[i];
		}

		if (a.bIsMonster) return max(1.0, double(a.Mass));

		return Guess(a);
	}

	static double Drag(Actor a)
	{
		if (!a) return 0;
		let t = RSQDG_MassTable.Get();
		if (!t) return 0;
		int i = t.FindFor(a.GetClass());
		return (i >= 0) ? t.dDrag[i] : 0.0;
	}

	static int Flags(Actor a)
	{
		if (!a) return 0;
		let t = RSQDG_MassTable.Get();
		if (!t) return 0;
		int i = t.FindFor(a.GetClass());
		return (i >= 0) ? t.dFlags[i] : 0;
	}

	// Did anyone actually state this one, or is it the volume guess?
	static bool IsStated(Actor a)
	{
		if (!a) return false;
		let t = RSQDG_MassTable.Get();
		if (t && t.FindFor(a.GetClass()) >= 0) return true;
		if (GunPounds(a) > 0) return true;
		return a.bIsMonster;
	}

	// A gun whose real weight a weapons pack measured, in pounds, or 0.
	//
	// ASKED BY STRING THROUGH A SERVICE, never by naming a class in another
	// package: a reference to a pk3 that is absent is fatal and global.
	// `has` IS ASKED FIRST. 0.0 means "nobody measured this", never "weightless".
	private static double GunPounds(Actor a)
	{
		if (!a || !(a is 'Weapon')) return 0;
		let t = RSQDG_MassTable.Get();
		Service sv = t ? t.GunService() : null;
		if (!sv) return 0;
		if (sv.GetInt("weapon.weight.has", "", -1, 0, a) != 1) return 0;
		double lb = sv.GetDouble("weapon.weight.lbs", "", -1, 0, a);
		return lb > 0 ? lb : 0;
	}

	private static double Guess(Actor a)
	{
		double w = 2.0 * a.Radius / UNITS_PER_METRE;
		double h = a.Height / UNITS_PER_METRE;
		double m = w * w * h * DEFAULT_DENSITY;
		if (a is 'Inventory') return clamp(m, INV_MIN, INV_MAX);
		return clamp(m, PROP_MIN, PROP_MAX);
	}

	// ---- what the pull makes of it -----------------------------------------
	//
	// THE ONE PLACE kilograms become behaviour, so the flight, the haptics and
	// the sound cannot disagree about how heavy something is.
	//
	// k / (k + kg): the share of the pull's full authority this object gets. k is
	// the mass the pull moves almost effortlessly (rsqdg_pull_kg, 10 kg by
	// default). It is the desktop throw's own shape -- keep = armKg/(armKg+kg),
	// which lane 7 called the best thing in the package -- applied to the other
	// direction. A clip (0.35) gets 0.97, a medikit 0.87, a rocket box 0.40, the
	// barrel (60) 0.14, an imp corpse 0.09, a Cacodemon 0.02.
	static double PullShare(Actor a, PlayerInfo p)
	{
		double k = max(0.1, RSQDG_Reach.Num("rsqdg_pull_kg", p, 10.0));
		return k / (k + Kg(a));
	}

	// How heavy it FEELS, 0 (a feather) .. 1 (a Cacodemon), on a log scale --
	// because the difference between a clip and a medikit is as real to a hand
	// as the difference between a barrel and a body. For pitch and rhythm.
	static double Heft(Actor a)
	{
		// log10(0.1 kg) = -1  ->  0 ;  log10(1000 kg) = 3  ->  1
		double l = log10(max(0.1, Kg(a)));
		return clamp((l + 1.0) / 4.0, 0.0, 1.0);
	}
}


// ============================================================================
// THE TABLE, READ ONCE PER SESSION.
//
// A StaticEventHandler rather than the desktop's level EventHandler: the table
// is derived from lumps, so it is rebuilt each session and never saved. The
// desktop's `loaded` flag was serialised alongside arrays it described -- the
// "flag over an empty array" shape its own policy file warns about.
//
//   mass "Clip"            0.35
//   mass "ExplosiveBarrel" 60    drag 0.001   impact explode
//
// Matched EXACTLY first, then up the inheritance chain.
// ============================================================================
class RSQDG_MassTable : StaticEventHandler
{
	Array<Class<Actor> > dClass;
	Array<double>        dMass;
	Array<double>        dDrag;
	Array<int>           dFlags;

	private Array<Class<Actor> > cacheClass;
	private Array<int>           cacheIndex;
	private bool loaded;

	static RSQDG_MassTable Get()
	{
		let t = RSQDG_MassTable(StaticEventHandler.Find("RSQDG_MassTable"));
		if (t && !t.loaded) t.Load();
		return t;
	}

	// The weapon weight service, found ONCE. Services are engine singletons,
	// and the lookup (an iterator and a MakeLower per service name) used to run
	// several times per tic for a weapon in the air. EXACT name: Find matches a
	// case-insensitive substring.
	private Service gunSvc;
	private bool gunLooked;

	Service GunService()
	{
		if (!gunLooked)
		{
			gunLooked = true;
			let it = ServiceIterator.Find("RS_WeaponWeightService");
			Service s;
			while (s = it.Next())
				if (s.GetClassName() == 'RS_WeaponWeightService') { gunSvc = s; break; }
		}
		return gunSvc;
	}

	// A row naming exactly this class, or -1.
	int FindExact(Class<Actor> cls)
	{
		if (!cls) return -1;
		for (int i = 0; i < dClass.Size(); i++)
			if (dClass[i] == cls) return i;
		return -1;
	}

	// The row for this class: its own, else its nearest ancestor's, else -1.
	int FindFor(Class<Actor> cls)
	{
		if (!cls) return -1;

		// LOOPED, NOT Array.Find -- the desktop's reasoning, kept: guessing
		// wrong about a dynamic-array method on class pointers is a load-time
		// abort. The cache means each class pays for the walk once.
		for (int c = 0; c < cacheClass.Size(); c++)
			if (cacheClass[c] == cls) return cacheIndex[c];

		int found = -1;
		for (Class<Actor> k = cls; k; k = (Class<Actor>)(k.GetParentClass()))
		{
			for (int i = 0; i < dClass.Size(); i++)
				if (dClass[i] == k) { found = i; break; }
			if (found >= 0) break;
		}

		cacheClass.Push(cls);
		cacheIndex.Push(found);
		return found;
	}

	private void Load()
	{
		loaded = true;
		int lump = -1;
		while ((lump = Wads.FindLump("MASSDEF", lump + 1, Wads.GlobalNamespace)) >= 0)
			ParseOne(Wads.ReadLump(lump), lump);
	}

	private void ParseOne(String text, int lump)
	{
		Array<String> lines;
		text.Replace("\r", "");
		text.Split(lines, "\n");

		for (int n = 0; n < lines.Size(); n++)
		{
			String line = lines[n];

			int h = line.IndexOf("#");
			if (h >= 0) line = line.Left(h);
			int sl = line.IndexOf("//");
			if (sl >= 0) line = line.Left(sl);

			line.Replace("\"", " ");
			line.Replace("\t", " ");

			Array<String> tok;
			line.Split(tok, " ", TOK_SKIPEMPTY);
			if (tok.Size() < 3) continue;
			if (!(tok[0] ~== "mass")) continue;

			// Through a Name, which the class cast resolves at runtime. Not
			// Object.FindClass -- absent from the earlier 17.x engine pk3.
			Name cn = tok[1];
			Class<Actor> cls = cn;
			if (!cls)
			{
				// One MASSDEF may cover several sets; a line naming a class this
				// load order lacks is normal. Said only to someone looking.
				let dev = CVar.FindCVar("developer");
				if (dev && dev.GetInt() >= 1)
					Console.Printf("[RSQDG] %s:%d names no class: %s",
						Wads.GetLumpFullName(lump), n + 1, tok[1]);
				continue;
			}

			double kg = tok[2].ToDouble();
			if (kg <= 0) continue;

			double drag = 0;
			int flags = 0;
			for (int t = 3; t < tok.Size(); t++)
			{
				if (tok[t] ~== "drag" && t + 1 < tok.Size()) { drag = tok[++t].ToDouble(); }
				else if (tok[t] ~== "flutter") { flags |= RSQDG_Mass.FLIGHT_FLUTTER; }
				else if (tok[t] ~== "impact" && t + 1 < tok.Size())
				{
					if (tok[t + 1] ~== "explode") flags |= RSQDG_Mass.FLIGHT_EXPLODE;
					t++;
				}
			}

			// LATER WINS, in place, so a pk3 loaded after another can correct it.
			int i = -1;
			for (int q = 0; q < dClass.Size(); q++)
				if (dClass[q] == cls) { i = q; break; }

			if (i >= 0)
			{
				dMass[i] = kg; dDrag[i] = drag; dFlags[i] = flags;
			}
			else
			{
				dClass.Push(cls); dMass.Push(kg); dDrag.Push(drag); dFlags.Push(flags);
			}
		}

		cacheClass.Clear();
		cacheIndex.Clear();
	}
}


// ============================================================================
// THE DOOR. Other packages ask by string, so nothing compiles against this.
// Same requests as the desktop's RS_MassService.
//
//   GetDouble("mass.kg",   "", 0, 0, actor)   kilograms
//   GetDouble("mass.drag", "", 0, 0, actor)
//   GetInt   ("mass.stated","",0, 0, actor)   1 authored, 0 a volume guess
// ============================================================================
class RSQDG_MassService : Service play
{
	override double GetDouble(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let a = Actor(objectArg);
		if (!a) return 0;
		if (request ~== "mass.kg")   return RSQDG_Mass.Kg(a);
		if (request ~== "mass.drag") return RSQDG_Mass.Drag(a);
		return 0;
	}

	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request ~== "mass.hello") return 1;
		let a = Actor(objectArg);
		if (!a) return 0;
		if (request ~== "mass.flags")  return RSQDG_Mass.Flags(a);
		if (request ~== "mass.stated") return RSQDG_Mass.IsStated(a) ? 1 : 0;
		if (request ~== "mass.grams")  return int(RSQDG_Mass.Kg(a) * 1000.0);
		return 0;
	}
}
