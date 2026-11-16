// HEADSHOT REACTION'S RULE: WHAT COUNTS AS A HEAD (owner 2026-11-16: "Bdxmve monsters have headshot detection already.
// This mkcrit fallback would be for a diff monster set, yes?" -> yes). What counts as a head is the gameplay mod's
// business; the laser only shows it, so it asks the rule of whichever mod deals the headshot.
//
//   1. BRUTAL DOOM 22 / XMVE MONSTERS: Brutal Doom's own head detection. Read from its code (brutal22test6), it can be
//      read from outside: a monster's BloodType names a blood actor that, spawned where a shot hit, tests its height
//      over the floor ((z - floorz) > 46 for Blood_Imp, 50 Blood_Comando, 54 Blood_Noble, 66 Blood_Bones ...); other
//      monsters carry head hitbox actors (HeadHitbox: Barons, Knights, Mancubi, Revenants, the Arch-Vile; XMVE's
//      HeadshotTarget<N> boxes) that a trace hits first. NOT BUILT YET: reported to the owner first (his order). Until
//      then these monsters keep the plain top fifth, as before.
//   2. ANY OTHER MONSTER SET, with mk-crits (Critical Hits and Headshots) loaded and its headshots on (csh_headshot_enabled):
//      mk-crits' own rule, csh_classes/core.txt: the top fifth of Height measured from the monster's FLOOR
//      (floorz + Height * 0.8 .. floorz + Height), and never on a class it refuses (zscript.txt headshot_Ignore, by
//      inheritance): Demon, Spectre, LostSoul, Cacodemon, Revenant, PainElemental, Arachnotron, SpiderMastermind.
//   3. With neither: the top fifth of the body.
// Everything by name at run time: none of these mods is linked, and without them nothing here changes.
class RSQLS_Head play
{
	const TOP = 0.2;   // mk-crits' headshot_height; the plain rule's top fifth

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

	// Which rule applies to this monster (for the debug log): 0 plain top fifth, 1 Brutal Doom's monster (plain for now),
	// 2 mk-crits, 3 mk-crits refuses it.
	static int RuleOf(Actor m)
	{
		if (IsBD(m)) return 1;
		if (MkCrits()) return MkRefused(m) ? 3 : 2;
		return 0;
	}

	// Is this point of the monster its head?
	static bool IsHead(Actor m, Vector3 hit)
	{
		if (!m) return false;
		switch (RuleOf(m))
		{
			case 2: return hit.z >= m.floorz + m.Height * (1.0 - TOP) && hit.z <= m.floorz + m.Height;
			case 3: return false;
		}
		return hit.z >= m.Pos.z + m.Height * (1.0 - TOP);
	}
}
