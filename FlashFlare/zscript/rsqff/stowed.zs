// RSQ FnF -- THE FLARE AND THE FLASHLIGHT SHOWN ON THE BODY (owner 11-04 19:0x: "Always show flare, flashlight ... Toggle
// show ___ on/off in each mod's options"). Rig only, not headset-confirmed.
//   SHOW FLARE (rsqff_show_flare, each player's own, on): while you carry a flare, one hangs at the chest pocket, upright,
//     cap up, leaning a little forward (as the Tactical Rig hangs it). With RSQ Tactical Rig's flare holster on, the rig
//     draws it there instead (it reads this same row by name) and the pocket shows nothing.
//   SHOW FLASHLIGHT (rsqff_show_torch, on): while the flashlight is on its clip (not in the hand), it hangs there, lens up.
// Both are drawn for every player on every machine (positions from the synced pawn); the body's yaw is the pocket's and
// the clip's own (handler.zs / torch.zs ShownYaw). One actor each per player, never in play.
class RSQFF_Shown : EventHandler
{
	const FLARE_LEAN = 15;     // degrees the flare leans forward from upright (the rig's STOW_FLARE_LEAN)
	const TORCH_LEAN = 10;
	Actor flare[MAXPLAYERS];
	Actor torch[MAXPLAYERS];

	static bool UFlag(PlayerInfo p, String n, bool d) { let c = CVar.GetCVar(n, p); return c ? c.GetBool() : d; }
	static bool SFlag(String n, bool d) { let c = CVar.FindCVar(n); return c ? c.GetBool() : d; }

	// RSQ Tactical Rig's flare holster holds (and draws) the flares for this player
	static bool RigHolster(PlayerInfo p)
	{
		if (ServiceIterator.Find("RSQTR_RigService").Next() == null) return false;
		return UFlag(p, "rsqtr_flare_holster", true);
	}

	override void WorldTick()
	{
		let hd = RSQFF_Handler(EventHandler.Find("RSQFF_Handler"));
		let th = RSQFF_Torches.Get();
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			PlayerPawn pmo = (playeringame[n] && players[n].mo) ? PlayerPawn(players[n].mo) : null;
			bool alive = pmo && pmo.health > 0 && pmo.player.playerstate == PST_LIVE;
			// the flare at the pocket
			bool wantF = alive && hd && SFlag("rsqff_on", true) && UFlag(players[n], "rsqff_show_flare", true)
				&& pmo.CountInv("RSQFF_Ammo") > 0 && !RigHolster(players[n]);
			if (wantF)
			{
				double by = hd.ShownYaw(pmo);
				flare[n] = Place(flare[n], "RSQFF_Stowed", RSQFF_Geo.Pocket(pmo, by), by, -(90 - FLARE_LEAN));
			}
			else if (flare[n]) flare[n].bINVISIBLE = true;
			// the flashlight on its clip
			bool wantT = alive && th && RSQFF_Torches.FlOn() && UFlag(players[n], "rsqff_show_torch", true)
				&& th.phase[n] == RSQFF_Torches.T_NONE;
			if (wantT)
			{
				double by = th.ShownYaw(pmo);
				torch[n] = Place(torch[n], "RSQFF_TorchStowed", RSQFF_Torches.Clip(pmo, by), by, -(90 - TORCH_LEAN));
			}
			else if (torch[n]) torch[n].bINVISIBLE = true;
		}
	}

	static Actor Place(Actor a, Class<Actor> c, Vector3 at, double yaw, double pitch)
	{
		if (!a) a = Actor.Spawn(c, at, NO_REPLACE);
		if (!a) return null;
		a.SetOrigin(at, true);
		a.angle = yaw;
		a.pitch = pitch;
		a.bINVISIBLE = false;
		return a;
	}
}

// THE FLASHLIGHT ON ITS CLIP: torch.md3 (tools/gen_torch.py --stowed), the flashlight alone, lens +x, centred, at the
// held light's scale (MODELDEF.torch). Never in play.
class RSQFF_TorchStowed : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		Radius 1; Height 1;
	}
	States
	{
	Spawn:
		QFFT E -1;
		Stop;
	}
}
