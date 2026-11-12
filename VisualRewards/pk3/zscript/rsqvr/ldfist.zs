// RSQ VisualRewards -- the holder of the legendary fist drop's model (MODELDEF.rsqvr; ldword.zs FistLook lends it).
// Never spawned. Its state names the sprite RVFI so the engine knows it (sprites/rsqvr/RVFIA0.png, one clear pixel).
class RSQVR_LDFist : Actor
{
	Default { +NOINTERACTION +NOBLOCKMAP }
	States { Spawn: RVFI A -1; Stop; }
}
