// RSQWP_Looks / RSQWP_Perks / RSQWP_Events -- what the tether code (forked from RSQ_Grapple's core)
// asks of the hook's look sets, the Gun Bonsai patch and the service. RSQ_Whip has none of those:
// its own sounds and a spark of particles; no upgrades (factor 1); nothing to report.
class RSQWP_Looks
{
	static String Sound(Name what)
	{
		if (what == 'hitflesh') return "rsqwp/hit";
		if (what == 'crack') return "rsqwp/crack";
		return "";
	}
	static Name Sprite(Name what) { return 'TNT1'; }

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
}

class RSQWP_Perks
{
	static clearscope double Factor(Actor who, Name what) { return 1.0; }
	static double SteadyDrag(PlayerPawn pmo, double k, bool still) { return 0; }
	static play void OnLetGo(RSQWP_Hook h, bool byPlayer) {}
	static play void OnBite(RSQWP_Hook h, Actor v) {}
	static play void OnArrive(Actor v, PlayerPawn pmo) {}
	static play void Bowl(Actor v, PlayerPawn pmo, Vector3 at, double step) {}
	// Every point the whip deals goes through here. GUN BONSAI VR (2026-11-02, GBOVR_TREES.md section 1): the whip
	// weapon earns it. Gun Bonsai credits a hit by its inflictor, and the whip's inflictors are the player (a crack),
	// nothing (the swung monster's own hurt) or the swung monster (a flail smash), never RSQWP_WhipWeapon, so before
	// the patch the XP went to whichever hand Gun Bonsai guessed. Now the hit is dealt inside the patch's claim
	// bracket (RSQ_MeleeUpgradeService "credit.push" / "credit.pop", asked by name: no Gun Bonsai needed to compile,
	// nothing happens without the patch), which pays damage by the player's own body to the weapon that opened it.
	// The bracket covers an inflictor that is the player or nothing; a smash's inflictor is the swung monster, so
	// inside the bracket that hit is dealt as the player's with no thrust (Smash does its own knock).
	// flags: DMG_THRUSTLESS from a crack or sting with Crack Knocks Enemies Back off (whip.zs Hit)
	static play void Hurt(Actor v, Actor inflictor, Actor source, int dmg, Name kind, int flags = 0)
	{
		if (!v || v.Health <= 0) return;
		Weapon wh = null;
		Service gb = null;
		let pmo = PlayerPawn(source);
		if (pmo)
		{
			wh = Weapon(pmo.FindInventory("RSQWP_WhipWeapon"));
			if (wh) { let it = ServiceIterator.Find("RSQ_MeleeUpgradeService"); gb = it.Next(); }
		}
		bool bracket = gb && wh && gb.GetInt("credit.push", "", 0, 0, wh) == 1;
		if (bracket && inflictor && inflictor != source) v.DamageMobj(source, source, dmg, kind, DMG_THRUSTLESS);
		else v.DamageMobj(inflictor, source, dmg, kind, flags);
		if (bracket) gb.GetInt("credit.pop", "", 0, 0, wh);
	}
}

