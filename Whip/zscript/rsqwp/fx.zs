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
	static play void Hurt(Actor v, Actor inflictor, Actor source, int dmg, Name kind)
	{
		if (v && v.Health > 0) v.DamageMobj(inflictor, source, dmg, kind);
	}
}

class RSQWP_Events
{
	static play void Bitten(PlayerPawn by, Actor v, int hand, bool heavy) {}
	static play void Whipped(Actor v, PlayerPawn by) {}
}
