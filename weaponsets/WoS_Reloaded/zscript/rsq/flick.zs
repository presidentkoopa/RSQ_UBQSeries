// RS VR flick reload (1.17, owner). With a GUN IN EACH HAND, snapping a gun's barrel down
// reloads THAT gun with BD22's own reload, and only that one. With one gun (off hand free or
// a fist) nothing here runs: VR reloading (rsr) has the gun as before. An RSQ series off-hand item
// (saber, Zippo, ShieldSaw...) closes the hand reload, so then the main gun flicks (2.0.3x).
//
// The flick is read from the barrel's elevation, which turning and walking do not change:
//   fast    the barrel drops FLICK_DEG within FLICK_TICS;
//   down    it ends at least DOWN_DEG below level;
//   once    it re-arms only after coming back above REARM_DEG.
// The gun must be in its ready loop (the engine's ready flag for that hand), so a flick never
// cuts into firing or a reload already running. rsq_flick 0 turns it off. Purist: off (BD22
// purist has no reloading).
class RSQ_Flick : EventHandler
{
	const FLICK_DEG = 45.0;		// degrees of drop...
	const FLICK_TICS = 4;		// ...within this many tics (about 400 degrees a second)
	const DOWN_DEG = -40.0;
	const REARM_DEG = -15.0;
	const HIST = 8;

	double el[MAXPLAYERS][2][HIST];
	int head[MAXPLAYERS][2];
	int count[MAXPLAYERS][2];
	bool armed[MAXPLAYERS][2];

	// the hand-held things that are not guns: they have no magazine to reload
	static bool IsGun(Weapon w)
	{
		if (!w || w is 'RSQ_Hands')
			return false;
		static const Name notGuns[] = { 'Melee_Attacks', 'BrutalAxe', 'Chain_saw', 'DSweap', 'HandGrenades' };
		for (int i = 0; i < notGuns.Size(); i++)
		{
			class<Actor> c = notGuns[i];
			if (c && w is c)
				return false;
		}
		return w.FindState("Reload") != null;
	}

	// 2.0.3x (owner 11-05 01:12): "When the saber or Zippo or ShieldSaw is in the off hand, we need to be
	// able to flick reload our main-hand weapon." With one of the RSQ series' off-hand items there, the hand
	// reload is closed (vreload.zs Wanted: the off hand must be RSQ_Hands to hold the magazine), so the main
	// gun flicks into BD22's own Reload, which needs no off hand. Matched by class name, no dependency.
	static bool IsSeriesOffItem(Weapon w)
	{
		if (!w)
			return false;
		static const Name items[] = {
			'UBQS_SaberBase', 'UBQS_ForceHand',			// RSQ Saber: off-hand saber, Force hand
			'SSQ_ShieldSaw',					// RSQ ShieldSaw
			'RSQTR_ZippoWeapon', 'RSQTR_CigWeapon',			// RSQ Tactical Rig
			'RSQFF_Held', 'RSQFF_Torch',				// RSQ Flash & Flare
			'RSQWP_WhipWeapon', 'RSQGN_Grenade', 'RSQ_Glove'	// Whip, Grenade, Melee gloves in the off hand
		};
		for (int i = 0; i < items.Size(); i++)
		{
			class<Actor> c = items[i];
			if (c && w is c)
				return true;
		}
		return false;
	}

	override void WorldTick()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo)
				continue;
			let mo = players[n].mo;
			let p = mo.player;
			bool live = RSVR_VRHand.InVR(mo) && p.playerstate == PST_LIVE && mo.health > 0
				&& RSQ.PlayerInt(mo, 'rsq_flick', 1) != 0 && mo.CountInv('IsPlayingAsPurist') == 0;
			bool on = live && IsGun(p.OffhandWeapon);	// 1.21: a gun in the off hand flicks, whatever the main hand holds
			// 2026-10-23: with ONE rifle the whole flick was off, so "flick down to reload both
			// barrels" (1.30) only ever worked while dual wielding -- and a lone rifle is the
			// common case. A single rifle now flicks for its LAUNCHER ONLY: the magazine stays
			// the hand reload's, exactly as the header says, and the flick gets the M203.
			bool loneM203 = live && !on && RSM.IsAnyRifle(p.ReadyWeapon);
			// 2.0.2a (owner 20:09): "ssg should always flick down to reload even if we allow for our vr
			// reload". A lone SSG flicks too (SSG.dec RSQ_FlickReload); the hand reload is still there.
			bool loneSSG = live && !on && RSQ_Alias.BD(p.ReadyWeapon) == 'SSG';
			// 2.0.3x: a series off-hand item (saber, Zippo, shield...) in the off hand: the main gun flicks
			bool offItem = live && !on && IsSeriesOffItem(p.OffhandWeapon) && IsGun(p.ReadyWeapon);
			double ps = mo.Level.pixelstretch;
			if (ps <= 0)
				ps = 1.2;
			for (int h = 0; h < 2; h++)
			{
				// the main gun flicks only when the off hand has a gun too (one gun alone: VR reload)
				bool run = on && (h != 0 || IsGun(p.ReadyWeapon)) || h == 0 && (loneSSG || offItem);
				bool m203Only = !run && h == 0 && loneM203;	// a lone rifle: the launcher only
				if (!run && !m203Only)
				{
					count[n][h] = 0;
					armed[n][h] = false;
					continue;
				}
				Vector3 d = h == 0 ? RSVR_VRHand.HandDir(mo, 0, 0, ps) : RSVR_VRHand.OffDir(mo, 0, 0, ps);
				double e = asin(clamp(d.z, -1, 1));
				head[n][h] = (head[n][h] + 1) % HIST;
				el[n][h][head[n][h]] = e;
				if (count[n][h] < HIST)
					count[n][h]++;
				if (e > REARM_DEG)
					armed[n][h] = true;
				if (!armed[n][h] || count[n][h] <= FLICK_TICS || e > DOWN_DEG)
					continue;
				double before = el[n][h][(head[n][h] - FLICK_TICS + HIST) % HIST];
				if (before - e < FLICK_DEG)
					continue;
				armed[n][h] = false;
				if (m203Only)
					RSM.FlickLoad(mo, false);	// the magazine stays the hand reload's
				else
					Reload(p, h);
			}
		}
	}

	static void Reload(PlayerInfo p, int h)
	{
		Weapon w = h == 0 ? p.ReadyWeapon : p.OffhandWeapon;
		int ready = h == 0 ? WF_WEAPONREADY : WF_OFFHANDREADY;
		if (!w)
			return;
		// 2.0.2a: an SSG (either hand, dual or alone) flicks into its own reload, SSG.dec RSQ_FlickReload,
		// from its ready loop OR while it waits open for the hand reload (RSB_Wait): an empty SSG sits there
		// (rig flick3: ready 0). The hand reload is closed first.
		State fl = RSQ_Alias.BD(w) == 'SSG' ? w.FindState("RSQ_FlickReload") : null;
		if (fl)
		{
			let psp = p.GetPSprite(h == 0 ? PSP_WEAPON : PSP_OFFHANDWEAPON);
			bool open = psp && psp.CurState == w.FindState("RSB_Wait");
			if (!(p.WeaponState & ready) && !open)
				return;
			let bs = p.mo ? RSB_Handler.StateOf(p.mo) : null;
			if (bs && bs.weap == w && bs.phase != RSB.IDLE)
				bs.Abort(p.mo);
			p.SetPsprite(h == 0 ? PSP_WEAPON : PSP_OFFHANDWEAPON, fl, false, w);
			if (CVar.GetCVar('rsq_switch_log', p).GetInt() > 0)
				Console.Printf("RSQ flick t%d: %s hand %d flick reload (%s)", level.maptime, w.GetClassName(), h, open ? "was open" : "was ready");
			return;
		}
		if (!(p.WeaponState & ready))
			return;
		State st = w.FindState("Reload");
		if (!st)
			return;
		// 2.0.3x: RSQ Saber / ShieldSaw carry their own copy of this flick (UBQS_OffFlick, SSQ_OffFlick); if one
		// of them already entered the Reload this tic, don't restart it, and clear the ready flag after ours so
		// theirs (later this tic) sees the gun busy: one flick, one reload.
		let rp = p.GetPSprite(h == 0 ? PSP_WEAPON : PSP_OFFHANDWEAPON);
		if (rp && rp.CurState == st)
			return;
		p.SetPsprite(h == 0 ? PSP_WEAPON : PSP_OFFHANDWEAPON, st, false, w);
		p.WeaponState &= ~ready;
		if (CVar.GetCVar('rsq_switch_log', p).GetInt() > 0)
			Console.Printf("RSQ flick t%d: %s hand %d flick reload (off hand %s)", level.maptime, w.GetClassName(), h,
				p.OffhandWeapon ? p.OffhandWeapon.GetClassName() : 'none');
		// 1.30 (owner: "flick down to reload both barrels"): a rifle's empty M203 loads with it
		if (RSM.IsAnyRifle(w) && p.mo)
			RSM.FlickLoad(p.mo, h != 0);
	}
}
