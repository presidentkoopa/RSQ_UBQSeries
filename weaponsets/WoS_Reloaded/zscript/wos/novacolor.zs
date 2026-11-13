// The Titan's rounds in the Nuker's colour (owner: "nuker is orange weapon firing green rounds, recolor round"): the
// Nova, the Hyper Nova, their residue and the BFG spray they set off are drawn through RSQWS_NovaOrange (TRNSLATE:
// Doom's green ramp 112-127 onto its orange ramp 208-223), and lit by orange copies of the stock BFGBALL lights
// (GLDEFS.wos, tools/build.py). The model and the weapon are untouched.
class RSQWS_NovaColor : EventHandler
{
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a)
			return;
		if (a is 'RSQWS_Nova' || a is 'RSQWS_HyperNova' || a is 'RSQWS_Residue')
		{
			a.A_SetTranslation('RSQWS_NovaOrange');
			return;
		}
		// a BFG spray hit set off by the Titan (its target is the player who fired it)
		if (a.GetClass() == 'BFGExtra' && a.target && a.target.player && a.target.player.ReadyWeapon is 'RSQWS_TITAN')
			a.A_SetTranslation('RSQWS_NovaOrange');
	}
}
