// ============================================================================
// AWARD ROWS: bonuses that never pay on a kill (Evaluate is always 0) and exist so that another
// mod's RS_ScoreService "award" call has a labelled row in the breakdown, in a family colour.
// ============================================================================

class RS_AwardSeed play
{
	static void Names(out Array<String> into)
	{
		into.Push("RS_Award_Deflect");
		into.Push("RS_Award_RemoteDown");
		into.Push("RS_Award_IndianaJones");
		into.Push("RS_Award_ThrallSlowKill");
		into.Push("RS_Award_Miniboss");
		into.Push("RS_Award_Bossfight");
		into.Push("RS_Award_Revenge");
		into.Push("RS_Award_Revive");
		// RS_Award_FEAR went 11-03: F.E.A.R. Effect is the combo "shove > gun.shotgun@slow" (combo.zs), paid on the kill
	}
}

// RSQ_Grapple: a gap crossed on the rope (its service.zs measures and pays it, once per gap per map).
class RS_Award_IndianaJones : RS_ScoreBonus
{
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Indiana Jones"; }
}

// The saber's training remote: a bolt knocked back into it, and the remote knocked out of the air.
class RS_Award_Deflect : RS_ScoreBonus
{
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Deflect"; }
}

class RS_Award_RemoteDown : RS_ScoreBonus
{
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Remote Down"; }
}

// RSQ_Miniboss (its handler.zs Award): a thrall killed in the slow window and the miniboss itself (Greedy retired 11-10:
// the reworked fight can't be won with a thrall standing). The labels are Miniboss's own strings, exactly.
class RS_Award_ThrallSlowKill : RS_ScoreBonus
{
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Thrall Slow Kill"; }
}

class RS_Award_Miniboss : RS_ScoreBonus
{
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Miniboss"; }
}

// RSQ_Miniboss's Bossfight (owner 11-05): the called-in miniboss killed (its bossfight.zs BfPayoff), on top of "Miniboss".
class RS_Award_Bossfight : RS_ScoreBonus
{
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Bossfight"; }
}

// RSQ SlowMo's DOWN v2 (owner-approved 11-06 19:51, design/NEAR_DEATH.md 11): "Revenge" for killing the monster that downed
// you (1x that kill's base: SlowMo sends it from the killing blow, before this mod records the kill, so it waits for it,
// AwardExternal) and "Revive" for taking the crate it dropped (3x the base of that marked kill, remembered per player).
class RS_Award_Revenge : RS_ScoreBonus
{
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Revenge"; }
}

class RS_Award_Revive : RS_ScoreBonus
{
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Revive"; }
}

// The door for other mods: GetInt("award", label, points, 0, playerPawn). See RS_ScoreHandler.AwardExternal.
class RS_ScoreService : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "award")
		{
			let h = RS_ScoreHandler(EventHandler.Find("RS_ScoreHandler"));
			return h ? h.AwardExternal(Actor(objectArg), stringArg, intArg) : -1;
		}
		// [11-09 score-fix] THE MAP'S CENSUS (handler.zs TakeFromCensus / AddToCensus; design/SCORE_EXPANSION.md A2).
		// A monster on it pays its full base once; one that is not pays rs_score_farmpercent (anti-farming).
		//   "census.take"  objectArg a monster -> 1 it was on the census and is now off it, 0 it was not, -1 no score
		//   "census.add"   objectArg a monster -> 1 it will pay its full base once, 0 it already would, -1 refused
		//                  (dead, already paid in full once, or not a monster Score pays for)
		// A body swap (RSQ Monsters' retier): "census.take" the old body, and only if that answered 1, "census.add"
		// the new one -- the slot moves, nothing is made. An encounter's own monsters: "census.add" each as it spawns.
		if (request == "census.take" || request == "census.add")
		{
			let h = RS_ScoreHandler(EventHandler.Find("RS_ScoreHandler"));
			if (!h) return -1;
			return request == "census.take" ? h.TakeFromCensus(Actor(objectArg)) : h.AddToCensus(Actor(objectArg));
		}
		// RSQ SLOWMO'S DOWN v3 (owner 11-07, design/NEAR_DEATH.md): the TOP tier's getting up fires Score's Revival Fire --
		//   "revivefire"  objectArg the player's pawn -> 1: the revival's sound, its blast and (Revival Fire row on) its
		//   column of fire (revive.zs), no life spent, no other change
		if (request == "revivefire")
		{
			let pawn = Actor(objectArg);
			if (!pawn || !pawn.player) return -1;
			pawn.A_StartSound("rsscore/revive", CHAN_VOICE, CHANF_LOCAL, 1.0, ATTN_NONE);
			RS_ScoreReviveFire.Begin(pawn, RS_ScoreHandler.ReviveFire(pawn));
			if (RS_ScoreHandler.DebugOn()) Console.Printf("RS_Score: Revival Fire for RSQ SlowMo's DOWN (top tier), player %d", pawn.PlayerNumber());
			return 1;
		}
		// A LIFE GIVEN BY ANOTHER MOD (owner 11-05: "can we have killing a miniboss give a Score life?"):
		//   "givelife"  intArg how many (0 or less: 1), objectArg the player's pawn -> the lives now held, -1 no score
		// Added the way an earned life is (CheckRewards: extraLives += 1, no cap; LIVES_MAX only caps the pips drawn), with
		// an earned life's cue: the bar lit blue, then the life sound and the pips' pop (RunRewardCue, next tic). No
		// whole-view tint unless "Reward Screen Flash" is on. Play scope only.
		if (request == "givelife")
		{
			let pawn = Actor(objectArg);
			let tr = (pawn && pawn.player) ? RS_ScoreTracker(pawn.FindInventory("RS_ScoreTracker")) : null;
			if (!tr) return -1;
			int n = max(1, intArg);
			tr.extraLives    += n;
			tr.rewardTic      = level.maptime;
			tr.rewardKind     = 1;
			tr.pendingLives  += n;
			tr.rewardLifeTic  = max(1, level.maptime);
			return tr.extraLives;
		}
		// THE HEAD-SHOT CHECK (head.zs, owner 11-09), for any mod that asks by name (RSQ Monsters' RSQMN_RosterService
		// "headshot" passes it on):
		//   "headshot"  objectArg a monster -> 1 its newest blow (this tic or the last) was a head shot, 0 it was not or it
		//               took none, -1 the check is off (Brutal Doom's own) or the monster is not judged (then use your own)
		if (request == "headshot")
		{
			let hc = RS_ScoreHead.Get();
			return hc ? hc.Answer(Actor(objectArg)) : -1;
		}
		// THE COMBO SYSTEM (combo.zs), for mods that do not link:
		//   "touch"  stringArg tool id, intArg player number, objectArg the monster -> 1 recorded
		//   "combo"  stringArg "<name>|<pattern>", intArg pay in permille (from OnRegister) -> 1
		//   "tool"   stringArg "<id>|<groups,...>" (from OnRegister) -> 1
		if (request == "touch")
		{
			let led = RS_ComboLedger.Get();
			let v = Actor(objectArg);
			if (!led || !v || intArg < 0 || intArg >= MAXPLAYERS || stringArg == "") return -1;
			led.Poll(v, intArg);
			led.Touch(v, intArg, stringArg, level.maptime);
			return 1;
		}
		if (request == "combo" || request == "tool")
		{
			Array<String> p;
			stringArg.Split(p, "|");
			if (p.Size() < 2) return -1;
			if (request == "combo") RS_ScoreRegistry.RegisterCombo(p[0], p[1], intArg / 1000.0);
			else RS_ScoreRegistry.RegisterTool(p[0], p[1]);
			return 1;
		}
		// WHAT A KILL EARNED IN STYLE (handler.zs RecordKill), for the Gun Bonsai VR patch:
		//   "kill.serial" intArg player -> the newest kill serial (0 none this map)
		//   "kill.style" / "kill.base"  intArg player, doubleArg serial -> points (-1: not kept)
		//   "kill.big"   objectArg the body -> 1 its kill was a big moment (the slow-motion moment's call), 0 not, -1 not kept
		if (request.Left(5) == "kill.")
		{
			let h = RS_ScoreHandler(EventHandler.Find("RS_ScoreHandler"));
			if (!h) return -1;
			if (request == "kill.big")
			{
				for (int b = h.kVictim.Size() - 1; b >= 0; b--) if (h.kVictim[b] == Actor(objectArg)) return h.kBig[b];
				return -1;
			}
			if (request == "kill.serial") return h.LastKill(intArg);
			int k = h.KillIndex(int(doubleArg));
			if (k < 0 || h.kPn[k] != intArg) return -1;
			if (request == "kill.style") return h.kStyle[k];
			if (request == "kill.base") return h.kBase[k];
			return -1;
		}
		// READS FOR A HUD THAT DRAWS THE SCORE ITSELF (the Gun Bonsai VR patch's screens, 10-27),
		// here and through GetIntUI. objectArg = the pawn (null: the console player's); -1 when
		// there is no score. "score" the running total the player reads; "progress" permille of
		// the way to the next reward (0..1000); "lives" extra lives held; "rewards" this map's.
		return Read(request, Actor(objectArg));
	}

	// "kill.chain": intArg player, doubleArg serial -> "gun>whip>shield.bash" (finishing blow last), "" not kept
	// "monster.name": objectArg a monster -> its name with Score's tier words in front when it has them ("Dark Red
	//   Champion Imp", "Legendary Imp"; RS_Boost.NameOf). RSQ SlowMo's DOWN plate asks it (owner 11-07). "" no monster.
	override String GetString(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "monster.name") return RS_Boost.NameOf(Actor(objectArg));
		if (request != "kill.chain") return "";
		let h = RS_ScoreHandler(EventHandler.Find("RS_ScoreHandler"));
		if (!h) return "";
		int k = h.KillIndex(int(doubleArg));
		return (k >= 0 && h.kPn[k] == intArg) ? h.kChain[k] : "";
	}

	// "kill.victim": intArg player, doubleArg serial -> the body (so a reader can match its own records)
	override Object GetObject(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request != "kill.victim") return null;
		let h = RS_ScoreHandler(EventHandler.Find("RS_ScoreHandler"));
		if (!h) return null;
		int k = h.KillIndex(int(doubleArg));
		return (k >= 0 && h.kPn[k] == intArg) ? h.kVictim[k] : null;
	}

	// the same reads from a HUD or menu (ui scope)
	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		// where the display is on screen, for another HUD (RSQ SlowMo's countdown bar sits under the bar): hud.zs LayoutPx
		if (request == "hud.cx" || request == "hud.bar.bottom" || request == "hud.bar.w") return RS_ScoreHUD.LayoutPx(request);
		return Read(request, Actor(objectArg));
	}

	static clearscope int Read(String request, Actor pawn)
	{
		if (!pawn && players[consoleplayer].mo) pawn = players[consoleplayer].mo;
		let tr = pawn ? RS_ScoreTracker(pawn.FindInventory("RS_ScoreTracker")) : null;
		if (!tr) return -1;
		if (request == "score") return tr.displayScore;
		if (request == "progress") return int(clamp(tr.scorePercent, 0.0, 1.0) * 1000);
		if (request == "lives") return tr.extraLives;
		if (request == "rewards") return tr.rewardCount;
		return -1;
	}
}
