// RS VR hands: the per-player upkeep (v9). This is all that is left of v8's
// zscript/rsq/reload.zs: the event handler that hands the player the off-hand
// weapon every tic, and the per-player state rsq/hands.zs reads.
//
// v8's reload pauses are gone: no gates, no markers, no carried ammo, no reload
// cvars. Nothing here draws, pauses or changes a weapon. kind and carry are kept
// only because hands.zs reads them; they are always 0. The real VR reload is
// zscript/rsr (rsr_reload).

class RSQ abstract play
{
	static int PlayerInt(PlayerPawn mo, Name n, int def)
	{
		let cv = CVar.GetCVar(n, mo.player);
		return cv ? cv.GetInt() : def;
	}

	static double Float(Name n, double def)
	{
		let cv = CVar.FindCVar(n);
		return cv ? cv.GetFloat() : def;
	}

	// the off hand in the gun hand's frame, metres (forward, left, up)
	static Vector3 OffLocal(PlayerPawn mo)
	{
		double ps = mo.Level.pixelstretch;
		if (ps <= 0)
			ps = 1.2;
		double vu = Float('vr_vunits_per_meter', 34);
		if (vu <= 0)
			vu = 34;
		Vector3 f = RSVR_VRHand.HandDir(mo, 0, 0, ps);
		Vector3 l = RSVR_VRHand.HandDir(mo, 90, 0, ps);
		Vector3 u = RSVR_VRHand.HandDir(mo, 0, 90, ps);
		Vector3 d = RSVR_VRHand.OffPos(mo) - RSVR_VRHand.HandPos(mo);
		d.z *= ps;
		d /= vu;
		return (d dot f, d dot l, d dot u);
	}
}

// one player's hands
class RSQ_State play
{
	int kind;			// always 0 (was v8's reload step)
	int carry;			// always 0 (was v8's ammo in the off hand)
	bool holding;		// the off hand is holding the front of the gun (rsq/hands.zs)
}

class RSQ_Handler : EventHandler
{
	RSQ_State st[MAXPLAYERS];

	static RSQ_State StateOf(PlayerPawn mo)
	{
		let h = RSQ_Handler(EventHandler.Find('RSQ_Handler'));
		if (!h || !mo || !mo.player)
			return null;
		int n = mo.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS)
			return null;
		if (!h.st[n])
			h.st[n] = new('RSQ_State');
		return h.st[n];
	}

	override void WorldTick()
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo)
				continue;
			if (!st[i])
				st[i] = new('RSQ_State');
			RSQ_Hands.Upkeep(players[i].mo);
		}
	}
}
