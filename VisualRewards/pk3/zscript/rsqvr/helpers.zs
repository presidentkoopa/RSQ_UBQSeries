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
//     (that is how those helpers are made), so a renamed one in a newer Brutal Doom is caught too;
//   - the DYING BODIES (11-04, IsDyingBody below): the crawling / burning / slumped / last-stand monster a BD monster
//     leaves when it dies, which dies again later (its kill was counted already: -COUNTKILL).
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
		if (IsDyingBody(a)) return true;
		return false;
	}

	// BRUTAL DOOM'S DYING BODIES (owner, 11-04: they must not drop Kill Rewards bits; one monster pays once). A BD monster
	// that dies can leave a body that is a monster of its own -- crawling, twitching, burning, slumped against a wall, a
	// last stand -- which "dies" again later: its WorldThingDied paid a second fountain of bits. Every one of them is made
	// the same way: +ISMONSTER -COUNTKILL (the kill was already counted on the real monster), and named for what it is.
	// Parsed from brutal22test6 (actors/PlayerClasses/DyingGuys.dec, LastStandMonsters.dec, Gore/Burn.dec, Enemies/*.dec)
	// and the XMVE pk3s 04-07 (a DECORATE parse, 11-04): 82 such classes in brutal22test6, 34 in XMVE, e.g. DyingImp, DyingZombieman,
	// DyingSergeantNoLeg, ImpDyingOfBloodLoss, BrutalizedImp1, ZombiemanLastStand1, DeadImp_Slumped, BurningZombieMan,
	// BurningCacodemon, ZombiemanFallingBeheaded, CrawlingDyingSpider, ZombiemanGotHisLegBlowed, ImpSaciLol, ArmlessDemon,
	// RevenantU, DyingHellKnight1, DyingBaron1, DyingArchvileNoArm; XMVE's DyingASGGuy, ASGGuyLastStand1,
	// BrutalizedDarkImp1, ArmlessBDemon, VoidSpectreLostHisArm. So: -COUNTKILL monsters whose class, or a class it is made
	// from, carries one of those names. A real monster counts its kill and is never matched; nothing here without Brutal
	// Doom.
	static clearscope bool IsDyingBody(Actor a)
	{
		if (!a || !a.bIsMonster || a.bCountKill) return false;
		for (class<Object> c = a.GetClass(); c && c != 'Actor'; c = c.GetParentClass())
		{
			String n = c.GetClassName();
			n = n.MakeLower();
			if (n.IndexOf("dying") >= 0 || n.IndexOf("brutalized") >= 0 || n.IndexOf("laststand") >= 0 || n.IndexOf("_slumped") >= 0
				|| n.Left(7) == "burning" || n.IndexOf("falling") >= 0 || n.IndexOf("crawl") >= 0 || n.IndexOf("gothisleg") >= 0
				|| n.IndexOf("losthisarm") >= 0 || n.Left(7) == "armless" || n.IndexOf("sacilol") >= 0 || n == "revenantu")
				return true;
		}
		return false;
	}
}
