// RSQ Monsters -- RSQ ACCESSIBILITY'S RUMBLE BACKUP FOR ITS EARTHQUAKES (owner 2026-11-12: rumble backup for ALL mods).
// QuestZDoom sends an earthquake's shake to both controllers (r_utility.cpp, scaled by its Quake Haptics level); at Quake
// Haptics 0 that is silent. Every earthquake this pack's monsters start (Brutal Doom's and ColorfulHell's Radius_Quake /
// A_Quake, 37 state lines, each now { the quake; RSQMN_QuakeFeel.Felt(self, its tremor radius); }) asks RSQ
// Accessibility by name as it starts, for both controllers, when the console player stands inside the tremor radius
// (the engine's own test: 2D distance; Radius_Quake's radius is in 64-unit blocks, A_Quake's in map units). RSQ
// Accessibility decides: with its Rumble Backup on and Quake Haptics at 0 it sends the engine's 150 ms buzz on each
// controller (at most one a controller every 5 tics) and logs it with its Debug Log; otherwise nothing. The quake
// itself is unchanged. Without RSQ Accessibility, or with Rumble Backup off, nothing happens: this pack loads and plays
// alone. A quake centred on other things (a tid) is not asked for. Rig only (log lines), not headset-confirmed.
class RSQMN_QuakeFeel play
{
	static void Felt(Actor src, double radius)
	{
		if (!src || consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer]) return;
		let pmo = players[consoleplayer].mo;
		if (!pmo || src.Distance2D(pmo) >= radius) return;
		let cv = CVar.FindCVar('rsqa_rumble_backup');
		if (!cv || cv.GetInt() == 0) return;
		let s = ServiceIterator.Find("RSQA_Service").Next();
		if (!s) return;
		s.GetInt("buzz", "RSQMN", pmo.PlayerNumber(), 1);   // the left controller
		s.GetInt("buzz", "RSQMN", pmo.PlayerNumber(), 0);   // the right
	}
}
