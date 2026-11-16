// 2.0.2a (owner 2026-10-28 19:47): "allow instant switching for all weapons, this raise / lower thing is
// rough on some". Option "Instant Weapon Switch" (rsq_instant_switch, default On).
//
// How: no weapon's code is skipped. When the engine starts putting a weapon away (DropWeapon), its
// Deselect frames, then the next weapon's Select frames, are run through in the SAME tic, each frame's
// action in order, exactly as if every frame's time had run out. It stops the moment the new weapon calls
// A_WeaponReady (WF_WEAPONREADY): it is ready to fire. The engine's own instant-switch flag
// (CF_INSTANTWEAPSWITCH) keeps the gun at the top, so A_Lower / A_Raise finish at once and the drawn gun
// never dips (in VR a lowered gun tilts down: hw_weapon.cpp pitch (y - WEAPONTOP) / -4).
// Main hand only (PSP_WEAPON). Off: BD22's own switch, as before.
class RSQ_Switch : EventHandler
{
	bool okPrev[MAXPLAYERS];
	Weapon wPrev[MAXPLAYERS];

	override void WorldTick()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n])
				continue;
			let p = players[n];
			let mo = p.mo;
			if (!mo)
				continue;
			bool on = CVar.GetCVar('rsq_instant_switch', p).GetBool();
			if (on)
				p.cheats |= CF_INSTANTWEAPSWITCH;
			else
				p.cheats &= ~CF_INSTANTWEAPSWITCH;

			if (on && p.playerstate == PST_LIVE && mo.health > 0)
			{
				// the drop happened in this tic's player think: the weapon allowed switching last tic
				// (A_WeaponReady set WF_WEAPONSWITCHOK), a weapon is pending, and the flag is gone now
				bool dropped = okPrev[n] && p.ReadyWeapon && p.ReadyWeapon == wPrev[n]
					&& p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon && !p.PendingWeapon.bOffhandWeapon && !(p.WeaponState & WF_WEAPONSWITCHOK);	// this pack: the main hand's switch only
				bool raised = p.ReadyWeapon && wPrev[n] && p.ReadyWeapon != wPrev[n];
				// or the weapon is at a frame that allows switching and one is pending: drop it now
				// (rig sw1: without this, half the switches ran the old weapon's lowering at full length)
				bool canDrop = !dropped && !raised && p.ReadyWeapon && p.PendingWeapon != WP_NOCHANGE && p.PendingWeapon && !p.PendingWeapon.bOffhandWeapon
					&& (p.WeaponState & WF_WEAPONSWITCHOK) && !(p.WeaponState & WF_DISABLESWITCH);
				if (canDrop)
				{
					mo.DropWeapon();
					dropped = true;
				}
				if (dropped || raised)
					Run(p, dropped);
			}
			if (p.PendingWeapon != WP_NOCHANGE && CVar.GetCVar('rsq_switch_log', p).GetInt() > 1)
			{
				let ps = p.GetPSprite(PSP_WEAPON);
				Console.Printf("RSQ switch t%d pending %s ready %s state %s+%d tics %d ws %x", level.maptime,
					p.PendingWeapon.GetClassName(), p.ReadyWeapon ? p.ReadyWeapon.GetClassName() : 'none',
					ps && ps.CurState ? ps.CurState.DistanceTo(p.ReadyWeapon.FindState('Ready')) .. "" : "-", 0, ps ? ps.tics : -1, p.WeaponState);
			}
			okPrev[n] = (p.WeaponState & WF_WEAPONSWITCHOK) != 0;
			wPrev[n] = p.ReadyWeapon;
		}
	}

	static void Run(PlayerInfo p, bool dropped)
	{
		Weapon from = p.ReadyWeapon;
		int steps = 0;
		p.WeaponState &= ~WF_WEAPONREADY;
		// the old weapon's Deselect frames, down to its A_Lower (which brings the new weapon up)
		if (dropped)
		{
			for (; steps < 96 && p.ReadyWeapon == from; steps++)
			{
				let psp = p.GetPSprite(PSP_WEAPON);
				if (!psp || !psp.CurState)
					break;
				psp.y = WEAPONBOTTOM;	// any A_Lower here finishes now
				psp.SetState(psp.CurState.NextState);
			}
			if (p.ReadyWeapon == from)
			{
				Log(p, from, null, steps, "the old weapon never lowered; left to the engine");
				return;
			}
		}
		// the new weapon's Select frames, up to its first A_WeaponReady
		Weapon to = p.ReadyWeapon;
		int up = 0;
		for (; up < 96 && p.ReadyWeapon == to && !(p.WeaponState & WF_WEAPONREADY); up++)
		{
			let psp = p.GetPSprite(PSP_WEAPON);
			if (!psp || !psp.CurState)
				break;
			psp.y = WEAPONTOP;
			psp.SetState(psp.CurState.NextState);
		}
		let psp = p.GetPSprite(PSP_WEAPON);
		if (psp)
		{
			psp.y = WEAPONTOP;
			psp.oldy = WEAPONTOP;
		}
		Log(p, from, to, steps, String.Format("ready after %d select frames%s", up,
			(p.WeaponState & WF_WEAPONREADY) ? "" : " (not ready yet: left to the engine)"));
	}

	static void Log(PlayerInfo p, Weapon from, Weapon to, int steps, String what)
	{
		if (CVar.FindCVar('rsq_switch_log') && CVar.FindCVar('rsq_switch_log').GetInt())
			Console.Printf("RSQ switch t%d: %s -> %s: %d deselect frames, %s", level.maptime,
				from ? from.GetClassName() : 'none', to ? to.GetClassName() : 'none', steps, what);
	}
}
