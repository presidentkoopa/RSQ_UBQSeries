// Laser: PC VR's halo rods are GONE (owner 2026-11-12 19:4x: "we went from one laser beam to this integrated six slice
// thing ... im willing to give it up for the previous beam"). The load order was 6,037 sprite frames over the engine's
// 65,535 (spritedef_t.spriteframes is 16-bit; read from the engine on the rig, run sfcount3): sprites past it shared
// frame slots, which drew rogue voxels, dropped letters off the watch card and put wrong frames on monsters. The halo
// was 7,344 of them. The list stays empty-but-one so beam.zs compiles; no sprite here has a frame, so nothing is drawn.
class RSQLS_HaloSprites abstract
{
	static const String SPRITES[] = { "LH00" };
	const RINGS = 4;
	const DB = 63;
}
