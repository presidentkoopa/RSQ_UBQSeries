
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
			// RSQ_Accessibility's Gesture Ease: the drop x1..x0.5 (45 -> 22.5 degrees), over a window of
			// 4..7 tics, ending at least 40..20 below level. 0 / absent: Brutal Doom Quest's own numbers.
			int win = FLICK_TICS + int(SSQ_A11y.Ease() * 3.0 + 0.5);
			if (!armed[n] || count[n] <= win || e > -SSQ_A11y.Low(-DOWN_DEG)) continue;
			double before = el[n][(head[n] - win + HIST) % HIST];
			if (before - e < SSQ_A11y.Low(FLICK_DEG)) continue;
			armed[n] = false;
			Reload(p);
		}
	}

	static void Reload(PlayerInfo p)
	{
		let w = p.ReadyWeapon;
		if (!w || !(p.WeaponState & WF_WEAPONREADY)) return;
		State st = w.FindState("Reload");
		if (st) p.SetPsprite(PSP_WEAPON, st, false, w);
	}

	// RSQ_Accessibility's Flick Reload gesture button (One-Handed; rsqa_alt 7): the same reload, when the
	// flick itself would have been heard (the shield in the off hand, a gun with a Reload state).
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name != "rsqa_alt" || e.Args[0] != 7 || !e.Args[1] || !SSQ_A11y.OneHand()) return;
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		let p = players[e.Player];
		let mo = p.mo;
		if (!mo || p.playerstate != PST_LIVE || mo.health <= 0) return;
		let fc = CVar.GetCVar("rsq_flick", p);
		if (p.OffhandWeapon && p.OffhandWeapon.GetClassName() == 'SSQ_ShieldSaw' && IsGun(p.ReadyWeapon) && (!fc || fc.GetInt() != 0))
			Reload(p);
	}
}
