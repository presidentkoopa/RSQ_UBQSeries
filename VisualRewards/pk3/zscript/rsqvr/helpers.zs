// RSQ VisualRewards -- THE ONE LIST OF BRUTAL DOOM'S HELPERS (2026-11-03 merge, NEXT_PLAN_2026-11-03.md 1.4).
//
// Brutal Doom builds parts of its monsters out of other monsters: invisible +ISMONSTER actors that ride the real one and die
// with it. None of them is a monster the player sees, so none gets an HP bar, a damage number or Kill Rewards bits. Until
// the merge the bars had no list, the numbers had one copy (damnums/events.zs) and Kill Rewards another (killrewards.zs);
// now all three ask this class.
//   - the HeadHitbox family, by its base class: HeadHitbox is +ISMONSTER -COUNTKILL, 9999 hp and dies with the monster it
//     rides (in brutal22test6: NewCybersHitBox, the Noble / Baron / Knight / Boss / Dying_Noble headshots, Dying_Headshot,
//     Slumped*_Headshot, Vile_HeadHitbox, the Mancubus / Revenant headshots, the SaciLol ones). A BD Cyberdemon's
//     NewCybersHitBox once burst into 1000 Kill Rewards bits and showed 9999 over every corpse;
//   - by name: BootSmearerRed / Blue / Green ("Because Brutal Doom...", SoM) and NewCybersHitBox;
//   - by build: any +ISMONSTER -COUNTKILL thing with 1000+ spawn health that rides a master or can never be targeted
//     (that is how those helpers are made), so a renamed one in a newer Brutal Doom is caught too.
// Everything by name (Name -> class at run time): no Brutal Doom, nothing matches, nothing links.
// (No static const String arrays here: QZD 17.3 rejected class-level ones in an event handler, events.zs note.)
class RSQVR_Helpers
{
	static clearscope bool IsHeadHitbox(Actor a)
	{
		if (!a) return false;
		Name hn = "HeadHitbox";
		class<Actor> bc = hn;
		return bc && a is bc;
	}

	static clearscope bool IsHelper(Actor a)
	{
		if (!a) return true;
		if (IsHeadHitbox(a)) return true;
		Name cn = a.GetClassName();
		if (cn == 'BootSmearerRed' || cn == 'BootSmearerBlue' || cn == 'BootSmearerGreen' || cn == 'NewCybersHitBox') return true;
		if (a.bIsMonster && !a.bCountKill && a.SpawnHealth() >= 1000 && ((a.master && a.master != a) || a.bNeverTarget)) return true;
		return false;
	}
}
