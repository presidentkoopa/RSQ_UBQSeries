
// FLICK TO RELOAD THE MAIN GUN WHILE THIS MOD HOLDS THE OFF HAND (the owner, 10-27: "when the
// ShieldSaw or saber is in the off hand, flick down does not work on the main-hand weapon with
// BD22 -- this fix belongs here"). Brutal Doom Quest reloads by hand only while its own hands hold
// the off hand, and by flick only with a gun in each hand, so with our item there the main gun
// could not reload at all. Its flick, measured from its flick.zs and copied here: the barrel drops
// 45 degrees within 4 tics, ends 40 below level, re-arms above 15 below. Any gun with a Reload
// state; its own Reload state is entered, as Brutal Doom Quest's flick does. Its rsq_flick switch
// is honoured when it exists. Read from AttackPitch (no AttackDir: that is unsafe on the first
// tic after a load).
class SSQ_OffFlick : EventHandler
{
	const FLICK_DEG = 45.0;
	const FLICK_TICS = 4;
	const DOWN_DEG = -40.0;
	const REARM_DEG = -15.0;
	const HIST = 8;

	double el[MAXPLAYERS][HIST];
	int head[MAXPLAYERS], count[MAXPLAYERS];
	bool armed[MAXPLAYERS];

	static bool IsGun(Weapon w)
	{
		if (!w || w.bMELEEWEAPON) return false;
		String n = w.GetClassName();
		n = n.MakeLower();
		if (n.IndexOf("ubqs_") == 0 || n.IndexOf("ssq_") == 0 || n == "rsq_hands") return false;
		return w.FindState("Reload") != null;
	}

	override void WorldTick()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			let mo = players[n].mo;
			let p = mo.player;
			let fc = CVar.GetCVar("rsq_flick", p);
			bool on = p.playerstate == PST_LIVE && mo.health > 0 && mo.OverrideAttackPosDir
				&& (p.OffhandWeapon && p.OffhandWeapon.GetClassName() == 'SSQ_ShieldSaw') && IsGun(p.ReadyWeapon) && (!fc || fc.GetInt() != 0);
			if (!on) { count[n] = 0; armed[n] = false; continue; }
			double e = -mo.AttackPitch;
			head[n] = (head[n] + 1) % HIST;
			el[n][head[n]] = e;
			if (count[n] < HIST) count[n]++;
			if (e > REARM_DEG) armed[n] = true;
			if (!armed[n] || count[n] <= FLICK_TICS || e > DOWN_DEG) continue;
			double before = el[n][(head[n] - FLICK_TICS + HIST) % HIST];
			if (before - e < FLICK_DEG) continue;
			armed[n] = false;
			let w = p.ReadyWeapon;
			if (!(p.WeaponState & WF_WEAPONREADY)) continue;
			State st = w.FindState("Reload");
			if (st) p.SetPsprite(PSP_WEAPON, st, false, w);
		}
	}
}
