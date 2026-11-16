// 2.0.4u RSQ MELEE IS THE MELEE MOD (owner 2026-11-13 01:32: "GET THE MELEE INTO RSQ MELEE ... IT IS CALLED RSQ MELEE NOT
// RSQ SOMEMELEE"). The gun as a club and the empty-hand VR punch moved to RSQ Melee (RSQ_UBQSeries Melee/zscript/rsqml/
// club.zs), ported line for line, the same numbers:
//   the butt strike   melee.zs RSVR_Hand kinds RIFLEBUTT..MG42BUTT (rsq_butt, rsq_butt_speed, rsvr_butt_fwd)
//   the pistol whip   melee.zs RSVR_Hand kinds PISTOL, REVOLVER, either hand (rsq_pistol_whip, rsq_whip_speed, rsvr_melee_down)
//   the VR punch      rsq/fists.zs RSQ_FistHand (rsq_punch, rsq_punch_use)
// WITH RSQ MELEE LOADED this pack's own stand down: it is asked by NAME at run time (RSQML_Service "owns" "club" / "punch"),
// never linked, so this pack still loads and plays alone, and WITHOUT RSQ Melee it keeps its own, exactly as in 2.0.4t.
// RSQ Melee knows this pack hands them over by this class's name (RSVR_MeleeYield); an older BD22 VR Reloaded keeps its
// own strike and RSQ Melee leaves it alone.
// Stays here, as each weapon's own attack: the axe (swing and throw), the Dragonslayer, the chainsaw. Also stays: the
// Melee Hit Flash (melee.zs WorldThingDamaged: it draws on any player's MeleeStrike / KickAttack hit, RSQ Melee's too),
// No Trigger Punch (fists.zs RSQ_NoTrigPunch: it stops BD22's canned button punch, a weapon's own animation).
// rsvr_melee_log 1 logs who does each blow and when this pack's stand down.
class RSVR_MeleeYield play
{
	// RSQ Melee's answer, asked once a second (and on each map) by RSVR_MeleeHandler: the service lookup is not per swing
	static bool Club(PlayerPawn mo) { let h = RSVR_MeleeHandler(EventHandler.Find('RSVR_MeleeHandler')); return h ? h.mlClub : Ask("club"); }
	static bool Punch(PlayerPawn mo) { let h = RSVR_MeleeHandler(EventHandler.Find('RSVR_MeleeHandler')); return h ? h.mlPunch : Ask("punch"); }

	static bool Ask(String what)
	{
		let s = ServiceIterator.Find("RSQML_Service").Next();
		return s && s.GetInt("owns", what) == 1;
	}

	static bool Logs(PlayerPawn mo) { return mo && RSQ.PlayerInt(mo, 'rsvr_melee_log', 0) > 0; }
}

// What RSQ Melee asks of this pack by name (none of it linked):
//   GetInt("punch.record", "", hand, mps, strike)   RSQ Melee's port of the VR punch records its strike as rsq/fists.zs
//                                                   does (hand 0 main / 1 off, the swing in m/s), so the LegenDoom mode's
//                                                   fist effects read it as before (rsld handler.zs StrikeHand, ld_g7_fx.zs
//                                                   Swing). 1 recorded, 0 not.
class RSVR_MeleeService : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request ~== "punch.record")
		{
			let a = Actor(objectArg);
			if (!a) return 0;
			RSQ_Fists.Record(a, intArg, doubleArg);
			return 1;
		}
		return 0;
	}
}
