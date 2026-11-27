// RSQWP_Looks / RSQWP_Perks -- the whip's sparks and its ring, and Hurt, which every point the whip deals goes through.
// 2026-11-27 (owner: "i want to tone this thing down"): the rope's look sets and Gun Bonsai VR's rope and leash perks
// (Fast Reel, Steady Line, Slingshot, Heavy Haul, Barbed Claw, Get Over Here, Bowling) went with the rope and the leash.
class RSQWP_Looks
{
	// A burst of sparks: hot at a crack, dark red on flesh.
	static play void Spark(Vector3 at, Name what)
	{
		let c = Actor.Spawn("RSQWP_WhipTip", at, NO_REPLACE);
		if (!c) return;
		color col = what == 'flesh' ? 0xA01010 : 0xFFE8B0;
		int n = what == 'crack' ? 10 : 6;
		for (int k = 0; k < n; k++)
		{
			double a = frandom(0, 360), p = frandom(-60, 60), v = frandom(1.5, 4.0);
			c.A_SpawnParticle(col, SPF_FULLBRIGHT, 8, 2.5, 0, 0, 0, 0, cos(a) * cos(p) * v, sin(a) * cos(p) * v, sin(p) * v, 0, 0, -0.15, 1.0, -1, -0.15);
		}
	}

	// THE GROUND CRACK'S RING (owner 2026-11-27: "the impact sends out a shockwave"): the same sparks, laid in a circle on
	// the floor and sent outward so the circle reaches `radius` (map units) as they die, with dust rising off it. As RSQ
	// Grapple draws its spike's shockwave (its RSQGR_Fx.Ring), with the Whip's own spark colour; no new art.
	static play void Ring(Vector3 at, double radius)
	{
		let c = Actor.Spawn("RSQWP_WhipTip", at + (0, 0, 2), NO_REPLACE);
		if (!c) return;
		double sp = radius / 14.0;
		for (int k = 0; k < 48; k++)
		{
			double a = k * 7.5;
			c.A_SpawnParticle(0xFFE8B0, SPF_FULLBRIGHT, 14, 6, 0, 0, 0, 0, cos(a) * sp, sin(a) * sp, 0.4, 0, 0, 0, 1.0, -1, 0);
		}
		for (int k = 0; k < 16; k++)
		{
			double a = frandom(0, 360), v = frandom(0.5, 2.0);
			c.A_SpawnParticle(0x9A8A70, 0, 20, 5, 0, 0, 0, 0, cos(a) * v, sin(a) * v, frandom(0.5, 1.5), 0, 0, -0.05, 0.8, -1, 0);
		}
	}
}

class RSQWP_Perks
{
	// Every point the whip deals goes through here. GUN BONSAI VR (2026-11-02, GBOVR_TREES.md section 1): the whip
	// weapon earns it. Gun Bonsai credits a hit by its inflictor, and the whip's inflictors are the player (a crack),
	// nothing (the swung monster's own hurt) or the swung monster (a flail smash), never RSQWP_WhipWeapon, so before
	// the patch the XP went to whichever hand Gun Bonsai guessed. Now the hit is dealt inside the patch's claim
	// bracket (RSQ_MeleeUpgradeService "credit.push" / "credit.pop", asked by name: no Gun Bonsai needed to compile,
	// nothing happens without the patch), which pays damage by the player's own body to the weapon that opened it.
	// 2026-11-27 (owner: "i want to tone this thing down"): the only damage left is the Wide Swing's (lash.zs Sweep),
	// dealt by the player himself with no thrust (its knockback is the swing's own push).
	static play void Hurt(Actor v, Actor inflictor, Actor source, int dmg, Name kind, int flags = 0)
	{
		if (!v || v.Health <= 0) return;
		Weapon wh = null;
		Service gb = null;
		let pmo = PlayerPawn(source);
		if (pmo)
		{
			wh = Weapon(pmo.FindInventory("RSQWP_WhipWeapon"));
			if (wh) { let it = RSQWP_Lookup.Find("RSQ_MeleeUpgradeService"); gb = it.Next(); }
		}
		bool bracket = gb && wh && gb.GetInt("credit.push", "", 0, 0, wh) == 1;
		if (bracket && inflictor && inflictor != source) v.DamageMobj(source, source, dmg, kind, DMG_THRUSTLESS);
		else v.DamageMobj(inflictor, source, dmg, kind, flags);
		if (bracket) gb.GetInt("credit.pop", "", 0, 0, wh);
	}
}
