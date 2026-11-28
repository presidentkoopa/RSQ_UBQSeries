// RS_EXAnnounce -- "A chill runs down your spine" as any of the 16 EX bosses arrives (README "Meet an EX boss").
// Colourful Hell printed it from each EX boss's Scripted state, which its Spawn state jumps to on its first tic. A boss
// that RSQ Miniboss lands is sent to its See state before that first tic (bossfight.zs, bigacts.zs: SetState(SeeState)),
// so the line never came (rig check, owner's load order, 2026-11-27: RS_BlackImpEX arrived, no line). Printed here when
// the boss spawns instead, once, whatever state it is sent to; the Scripted states no longer print it.
class RS_EXAnnounce : EventHandler
{
	static const Name EX[] = { 'RS_BlackArchEX', 'RS_BlackCGuyEX', 'RS_BlackCacoEX', 'RS_BlackCybieEX', 'RS_BlackFatsoEX',
		'RS_BlackHKEX', 'RS_BlackImpEX', 'RS_BlackRevenantEX', 'RS_BlackSPEX', 'RS_BlackSpectreEX', 'RS_BlackZombieEX',
		'RS_WhiteArchEX', 'RS_WhiteCybieEX', 'RS_WhiteLSoulEX', 'RS_WhiteSGEX', 'RS_WhiteSPEX' };
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || !a.bIsMonster) return;
		Name n = a.GetClassName();
		for (int i = 0; i < RS_EXAnnounce.EX.Size(); i++)
		{
			if (n != RS_EXAnnounce.EX[i]) continue;
			a.A_Log("A chill runs down your spine");
			return;
		}
	}
}
