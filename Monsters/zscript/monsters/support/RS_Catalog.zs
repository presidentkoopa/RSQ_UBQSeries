// RS_Catalog -- the MONSTER-FACING SLICE ONLY.
//
// RS_Main's zscript/systems/weapon/RS_Catalog.zs is 549 lines of weapon effect
// catalogue: it names 78 classes like RS_CasingShell, RS_LensFlare,
// RS_GH_PlasmaShot and RS_ST_FlameJet, none of which belong in a monster pack.
// Carrying it whole means 78 unknown-class errors.
//
// RS_MonsterMaster.zs touches RS_Catalog in exactly two places -- both about
// projectile scale, both with NO external references:
//     RS_MonsterMaster.zs:1103   RS_Catalog.ScaleForMonsterRole(...)
//     RS_MonsterMaster.zs:1124   RS_Catalog.ApplyProjectileScale(...)
// Those two, and the SCALE_ constants they read, are reproduced here verbatim.
// Nothing is altered; the rest of the file is simply not brought across.
//
// If the weapon side is ever added to this pack, delete this file so the real
// RS_Catalog is the only definition.
class RS_Catalog
{
	static double SCALE_Pellet() { return 0.35; }
	static double SCALE_Bullet() { return 0.50; }
	static double SCALE_Normal() { return 1.00; }
	static double SCALE_Heavy()  { return 1.40; }
	static double SCALE_Huge()   { return 2.00; }

	static double ScaleForMonsterRole(string role, string delivery)
	{
		if (delivery == "bullet")   return SCALE_Bullet();
		if (role == "fodder")       return SCALE_Bullet();
		if (role == "skirmisher")   return SCALE_Bullet();
		if (role == "artillery")    return SCALE_Normal();
		if (role == "bruiser")      return SCALE_Heavy();
		if (role == "summoner")     return SCALE_Normal();
		return SCALE_Normal();
	}

	static play void ApplyProjectileScale(Actor proj, double scale)
	{
		if (!proj || scale <= 0 || abs(scale - 1.0) < 0.01)
			return;

		proj.A_SetScale(proj.Scale.X * scale, proj.Scale.Y * scale);

		// Collision follows the visual. Floor at 1 so a heavily shrunk
		// round doesn't end up with a zero-size hitbox and pass through
		// everything it should hit.
		proj.A_SetSize(max(1.0, proj.Radius * scale),
		               max(1.0, proj.Height * scale));
	}
}
