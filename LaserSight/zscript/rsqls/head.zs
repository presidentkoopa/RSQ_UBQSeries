// HEADSHOT REACTION'S RULE: WHAT COUNTS AS A HEAD (owner 2026-11-16: "Bdxmve monsters have headshot detection already.
// This mkcrit fallback would be for a diff monster set, yes?" -> yes). What counts as a head is the gameplay mod's
// business; the laser only shows it, so it asks the rule of whichever mod deals the headshot.
//
//   1. BRUTAL DOOM 22 / XMVE MONSTERS: Brutal Doom's own head detection (owner 2026-11-17: "Build it"), read from its
//      code (brutal22test6) and asked from outside, by name:
//      a. HEAD BOXES. Brutal Doom hangs a shootable box on a monster's head: HeadHitbox and what inherits from it
//         (NobleHeadshot on Barons and Knights, MancuHeadshot, BonesHeadshot, Vile_HeadHitbox, NewCybersHitBox ...),
//         spawned SXF_SETMASTER and warped onto its master every 2 tics; and XMVE's HeadshotTarget<N> boxes
//         (HeadshotTargetBase), spawned again and again at head height by A_SpawnItem, which makes the monster the
//         box's target (InitSpawnedItem: a spawned non-monster's target is its originator); and RSQ Score's
//         RS_ScoreHeadSensor, which takes the place of BD's HeadHitbox boxes when Score is loaded (same place and size,
//         its master the monster). A trace that stops on a box is a head hit on the box's monster. Not heads, though HeadshotTargetBase's: MeatShield (a marine held
//         up as a shield), TankEngineWeakSpot (a tank's engine), HellNobleCrotchHitbox.
//      b. BLOOD HEIGHT. A monster's blood (BloodType, after replacements: the class the engine spawns) is spawned where
//         the shot hit and tests its own height over the floor there: A_JumpIf((z - floorz) > N, "HeadShot")
//         (actors/Gore/BloodTypesMonsters.dec). N: Blood_Imp 46 (and Blood_Zombies, which inherits it), Blood_Comando
//         50, Blood_Noble 54, Blood_Fatso 54, Blood_Archie 56, Blood_Bones 66, Blood_Cybie 96, SitZ_Blood 21,
//         Blood_BWSS 43 (and the saw bloods Blood_Imp_Saw 46, Blood_Comando_Saw 50). A blood not named is looked up by
//         its parents (a blood that only inherits one keeps its test); a blood replaced by one that names none (RSQ
//         Score's copies, which keep BD's numbers) by the BloodType BD gave. The laser tests the same at its hit point
//         (Doom jitters the blood's height by a few units; the laser does not).
//      c. A monster whose blood has no height test but which has been seen carrying a head box: its body is never its
//         head (Brutal Doom gives it a headshot only through the box; a Baron's Green_Blood, an XMVE zombie's
//         Brutal_Blood). A monster seen carrying a box counts as Brutal Doom's whatever its blood (XMVE's riot and pyro
//         sergeants bleed HitPuff).
//      d. Otherwise (a Brutal Doom blood with no height test and no box seen): the top fifth of the body.
//   2. ANY OTHER MONSTER SET, with mk-crits (Critical Hits and Headshots) loaded and its headshots on (csh_headshot_enabled):
//      mk-crits' own rule, csh_classes/core.txt: the top fifth of Height measured from the monster's FLOOR
//      (floorz + Height * 0.8 .. floorz + Height), and never on a class it refuses (zscript.txt headshot_Ignore, by
//      inheritance): Demon, Spectre, LostSoul, Cacodemon, Revenant, PainElemental, Arachnotron, SpiderMastermind.
//   3. With neither: the top fifth of the body.
// Everything by name at run time: none of these mods is linked, and without them nothing here changes.
class RSQLS_Head play
{
	const TOP = 0.2;   // mk-crits' headshot_height; the plain rule's top fifth

	// The rules, for the debug log (RuleName).
	enum ERule
	{
		R_TOP = 0,        // another set, no mk-crits: the top fifth
		R_BD_TOP = 1,     // Brutal Doom's: its blood has no height test and it has shown no box: the top fifth
		R_MK = 2,         // mk-crits' rule
		R_MK_REFUSED = 3, // mk-crits refuses the class
		R_BD_BLOOD = 4,   // Brutal Doom's blood height
		R_BD_BOX = 5,     // the trace stopped on a Brutal Doom / XMVE head box
		R_BD_BOXBODY = 6, // Brutal Doom's, its head is its box: the body never is
	}

	static String RuleName(int r)
	{
		static const String names[] = { "top fifth", "Brutal Doom, no blood height, no box: top fifth", "mk-crits", "mk-crits refuses",
			"Brutal Doom blood height", "Brutal Doom head box", "Brutal Doom, head is its box: body" };
		return (r >= 0 && r < names.Size()) ? names[r] : "?";
	}

	// Brutal Doom 22 is loaded: its blood family and its head boxes exist.
	static bool BDLoaded()
	{
		Name bb = 'Brutal_Blood', hb = 'HeadHitbox';
		class<Actor> b = bb, h = hb;
		return b && h;
	}

	// A Brutal Doom 22 / XMVE monster: its blood is Brutal Doom's (the Brutal_Blood family, or one of the few BD blood
	// actors that stand on the stock Blood), or it is one of BD's head boxes itself. A monster of another set keeps the
	// stock Blood (BD's Brutal_Blood only REPLACES it, the monster's BloodType still names Blood) or its own blood.
	static bool IsBD(Actor m)
	{
		if (!m || !BDLoaded()) return false;
		static const Name boxes[] = { 'HeadHitbox', 'HeadshotTargetBase' };
		for (int i = 0; i < boxes.Size(); i++) { class<Actor> c = boxes[i]; if (c && m is c) return true; }
		Name bt = m.BloodType;
		class<Actor> bc = bt;
		if (!bc) return false;
		Name bbn = 'Brutal_Blood';
		class<Actor> bb = bbn;
		if (bb && bc is bb) return true;
		static const Name own[] = { 'DeadBlood', 'LostSoulBlood', 'RevenantBlood', 'TankBlood', 'TreeBlood', 'AlphaBlood', 'GreenBloodTrails' };
		for (int i = 0; i < own.Size(); i++) if (bt == own[i]) return true;
		return false;
	}

	// A HEAD BOX's monster (1a above), or null when this is not a head box (or its monster is gone).
	static Actor BoxOwner(Actor a)
	{
		if (!a) return null;
		Name hbn = 'HeadHitbox', htn = 'HeadshotTargetBase', rsn = 'RS_ScoreHeadSensor';
		class<Actor> hb = hbn, ht = htn, rs = rsn;
		Actor own = null;
		if ((hb && a is hb) || (rs && a is rs)) own = a.master;
		else if (ht && a is ht)
		{
			static const Name notHead[] = { 'MeatShield', 'TankEngineWeakSpot', 'HellNobleCrotchHitbox' };
			for (int i = 0; i < notHead.Size(); i++) { class<Actor> c = notHead[i]; if (c && a is c) return null; }
			own = a.target;
		}
		else return null;
		if (!own || own == a || !own.bISMONSTER || own.player) return null;
		return own;
	}

	// Brutal Doom's head height for this monster's blood (1b above), or -1: the blood the engine spawns (its BloodType
	// after replacements), then the BloodType Brutal Doom gave it (RSQ Score swaps BD's head bloods for copies that keep
	// BD's numbers and inherit nothing from BD).
	static double BloodHeadOf(Actor m, out class<Actor> which)
	{
		which = m.GetBloodType(0);
		double n = BloodHead(which);
		if (n >= 0) return n;
		Name bt = m.BloodType;
		class<Actor> raw = bt;
		if (raw && raw != which)
		{
			n = BloodHead(raw);
			if (n >= 0) { which = raw; return n; }
		}
		return -1;
	}

	// for the debug log: the blood the rule was read from
	static String BloodName(Actor m)
	{
		class<Actor> bl;
		BloodHeadOf(m, bl);
		return bl ? String.Format("%s", bl.GetClassName()) : "none";
	}

	// ... for one blood class: the class itself, then its parents, the first one named.
	static double BloodHead(class<Actor> bc)
	{
		static const Name bn[] = { 'Blood_Imp', 'Blood_Imp_Saw', 'Blood_Zombies', 'Blood_Comando', 'Blood_Comando_Saw', 'Blood_Noble',
			'Blood_Fatso', 'Blood_Archie', 'Blood_Bones', 'Blood_Cybie', 'SitZ_Blood', 'Blood_BWSS' };
		static const double bz[] = { 46, 46, 46, 50, 50, 54,
			54, 56, 66, 96, 21, 43 };
		for (class<Actor> c = bc; c; c = (class<Actor>)(c.GetParentClass()))
			for (int i = 0; i < bn.Size(); i++) { class<Actor> t = bn[i]; if (t && c == t) return bz[i]; }
		return -1;
	}

	// The floor under a point (what a blood spawned there measures its height from).
	static double FloorAt(Vector3 at)
	{
		Sector s = Level.PointInSector(at.xy);
		if (!s) return at.z;
		double fz = s.NextLowestFloorAt(at.x, at.y, at.z);
		return fz;
	}

	// mk-crits is loaded (its damage brain exists) and its headshots are on.
	static bool MkCrits()
	{
		Name bn = 'csh_Brain';
		class<Actor> b = bn;
		if (!b) return false;
		let cv = CVar.FindCVar('csh_headshot_enabled');
		return cv && cv.GetBool();
	}

	// mk-crits' refused classes (its headshot_Ignore, the Doom ones), by inheritance as mk-crits tests them.
	static bool MkRefused(Actor m)
	{
		static const Name refused[] = { 'Demon', 'Spectre', 'LostSoul', 'Cacodemon', 'Revenant', 'PainElemental', 'Arachnotron', 'SpiderMastermind' };
		for (int i = 0; i < refused.Size(); i++) { class<Actor> c = refused[i]; if (c && m is c) return true; }
		return false;
	}

	// IS THIS POINT OF THE MONSTER ITS HEAD? m: the monster (a head box already turned into its monster, BoxOwner);
	// onBox: the trace stopped on m's head box; boxed: m's class has been seen carrying a head box (1c).
	// Returns the answer, the rule (ERule), the height the rule tests (Brutal Doom's blood: N; else -1) and the height
	// of the hit point over the floor the rule measures from.
	static bool, int, double, double Judge(Actor m, Vector3 hit, bool onBox, bool boxed)
	{
		if (!m) return false, R_TOP, -1, 0;
		if (onBox) return true, R_BD_BOX, -1, hit.z - FloorAt(hit);
		if (boxed || IsBD(m))   // a monster seen carrying a Brutal Doom head box is Brutal Doom's, whatever its blood
		{
			class<Actor> bl;
			double n = BloodHeadOf(m, bl);
			if (n >= 0)
			{
				double over = hit.z - FloorAt(hit);
				return over > n, R_BD_BLOOD, n, over;
			}
			if (boxed) return false, R_BD_BOXBODY, -1, hit.z - m.floorz;
			return hit.z >= m.Pos.z + m.Height * (1.0 - TOP), R_BD_TOP, -1, hit.z - m.Pos.z;
		}
		if (MkCrits())
		{
			if (MkRefused(m)) return false, R_MK_REFUSED, -1, hit.z - m.floorz;
			return hit.z >= m.floorz + m.Height * (1.0 - TOP) && hit.z <= m.floorz + m.Height, R_MK, -1, hit.z - m.floorz;
		}
		return hit.z >= m.Pos.z + m.Height * (1.0 - TOP), R_TOP, -1, hit.z - m.Pos.z;
	}
}
