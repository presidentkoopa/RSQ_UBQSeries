// wr_modsupport.zs -- OTHER-MOD SUPPORT PARKED (owner 2026-11-09 02:56: "disable wheel mod support for now").
// Earlier (11-08): "All the wheel needs to read right now is GBOVR and LegenDoom, and normal Doom." So every compat
// reader except LegenDoom's (wr_compat_legendoom.zs) answers "off" while this says parked: DoomRL Arsenal, Doomablo,
// Pandemonia (+ Anarchy, Insurrection), Guncaster, MetaDoom, BorderDoom, Doom Infinite, Combined Arms, Final Doomer,
// ModelSwapper, Lithium. Gun Bonsai (wr_q_bonsai.zs) and LegenDoom are untouched. Their own switches and code stay as
// they were (design/PARKED.md, design/WHEEL_MODS_PEEK.md); the hidden cvar wr_unpark_mods 1 brings them back for testing.
class wr_ModSupport
{
	static bool Parked()
	{
		let c = CVar.FindCVar("wr_unpark_mods");
		return !(c && c.GetBool());
	}
}
