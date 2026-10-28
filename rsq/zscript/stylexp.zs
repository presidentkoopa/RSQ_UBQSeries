// XP SOURCE: STYLE -- the owner's arcade room, 10-27: RSQ Score turns how you fight into points, and
// here those points grow the tools that earned them.
//
//   rsq_xp_source  0 Damage (Gun Bonsai's own, the default: nothing here runs)
//                  1 Style: a kill's style points become XP, and damage pays none
//                  2 Both: Gun Bonsai's damage XP, and the style on top
// Style needs RSQ Score (asked by name, RS_ScoreService); without it Style reads as Damage
// (TFLV_PerPlayerStats.RSQ_XPSource).
//
// WHAT A KILL PAYS. RSQ Score publishes each kill a player earns: its style (every bonus row -- the
// total less the base; Champions' and LegenDoom Lite's rows count as style) and its combo chain, the
// tools in order, the finishing blow last ("kill.style", "kill.chain", "kill.victim"). Here:
//   xp = style x rsq_xp_style_scale
//   the FINISHER's tool takes 50%, the SETUP tools share the other 50% equally (a chain of one tool:
//   the finisher takes it all), and on top rsq_xp_style_player percent goes to the player pool
//   (Gun Bonsai's player bar, where a throw's and the hook's XP already go).
// WHERE EACH TOOL'S SHARE GOES, through the patch's existing paths:
//   gun, rig.draw          the gun(s) that hit this monster (Gun Bonsai's own credit, noted per blow:
//                          PerPlayerStats.NoteStyleHit); none noted -> the gun that got the kill
//   saber.*, force.*       the saber (up_saber's path: UBQS_Saber / UBQS_SaberOff)
//   shield.*               the ShieldSaw (up_shield)
//   glove                  the boxing gloves (up_gloves)
//   punch, kick, blade, finisher   the melee weapon that hit it (up_melee), else the pool
//   hook.*, whip, grab.throw, anything else   the player pool (the hook's perks, up_hook, and the
//                          grab's are player upgrades)
// Gun Bonsai's bars are untouched: this only decides how much XP lands where.
class RSQ_StyleXP : EventHandler
{
	int seen[MAXPLAYERS];
	double paidTotal[MAXPLAYERS];

	override void WorldTick()
	{
		if (TFLV_PerPlayerStats.RSQ_XPSource() == 0) return;
		let s = RSQM.Svc("RS_ScoreService");
		if (!s) return;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			int serial = s.GetInt("kill.serial", "", pn);
			if (serial < 0) continue;
			if (serial < seen[pn]) seen[pn] = 0;   // a new map's numbering
			if (serial == seen[pn]) continue;
			for (int k = max(seen[pn] + 1, serial - 15); k <= serial; k++)
			{
				int style = s.GetInt("kill.style", "", pn, k);
				if (style < 0) continue;
				Pay(players[pn].mo, style, s.GetString("kill.chain", "", pn, k), Actor(s.GetObject("kill.victim", "", pn, k)), k);
			}
			seen[pn] = serial;
		}
	}

	static String ActionOf(String t) { return t == "hook.yank" ? "hook.bite" : t; }

	void Pay(PlayerPawn pmo, int style, String chain, Actor victim, int serial)
	{
		let stats = TFLV_PerPlayerStats.GetStatsFor(pmo);
		if (!stats || style <= 0) return;
		double xp = style * max(0.0, RSQM.SV("rsq_xp_style_scale", 1.0));
		if (xp <= 0) return;
		Array<String> steps;
		chain.Split(steps, ">", TOK_SKIPEMPTY);
		if (steps.Size() == 0) steps.Push("gun");
		String fin = steps[steps.Size() - 1];
		// the setup tools: every other tool of the chain, once each
		Array<String> setups;
		for (int k = 0; k < steps.Size() - 1; k++)
		{
			String a = ActionOf(steps[k]);
			if (a == ActionOf(fin)) continue;
			bool had = false;
			for (int j = 0; j < setups.Size(); j++) if (ActionOf(setups[j]) == a) { had = true; break; }
			if (!had) setups.Push(steps[k]);
		}
		bool dbg = RSQM.SVI("rsq_xp_debug", 0) > 0;
		String log = "";
		double finShare = setups.Size() > 0 ? 0.5 : 1.0;
		log = log .. PayTool(stats, pmo, fin, victim, xp * finShare, true);
		for (int j = 0; j < setups.Size(); j++)
			log = log .. PayTool(stats, pmo, setups[j], victim, xp * 0.5 / setups.Size(), false);
		double pshare = xp * clamp(RSQM.SVI("rsq_xp_style_player", 10), 0, 100) / 100.0;
		if (pshare > 0) stats.AddPoolXP(pshare);
		paidTotal[pmo.PlayerNumber()] += xp + pshare;
		if (dbg)
			Console.Printf("T_SXP kill #%d style %d xp %.1f chain %s ->%s | player pool +%.1f (pool %.1f, player xp %d)",
				serial, style, xp, chain, log, pshare, stats.poolXP, stats.XP);
	}

	// one tool's share to its weapon (or the pool); the log text
	String PayTool(TFLV_PerPlayerStats stats, PlayerPawn pmo, String tool, Actor victim, double xp, bool fin)
	{
		if (xp <= 0) return "";
		String kind = Kind(tool);
		Array<TFLV_WeaponInfo> to;
		if (kind == "gun")
		{
			Hit(stats, victim, kind, to);
			if (to.Size() == 0 && stats.lastKillInfo && stats.lastKillInfo.wpn && stats.GetInfoFor(stats.lastKillInfo.wpn) == stats.lastKillInfo
				&& Sort(stats.lastKillInfo) == "gun") to.Push(stats.lastKillInfo);
			if (to.Size() == 0) { let cur = stats.GetInfoForCurrentWeapon(); if (cur && Sort(cur) == "gun") to.Push(cur); }
		}
		else if (kind == "saber" || kind == "shield" || kind == "glove" || kind == "melee")
		{
			Hit(stats, victim, kind, to);
			if (to.Size() == 0 && kind != "melee") { let info = Owned(stats, pmo, kind); if (info) to.Push(info); }
		}
		if (to.Size() == 0)
		{
			stats.AddPoolXP(xp);
			return String.Format(" %s%s %.1f->pool", tool, fin ? "(fin)" : "", xp);
		}
		String s = "";
		for (int i = 0; i < to.Size(); i++)
		{
			stats.AddXPTo(to[i], xp / to.Size());
			s = s .. String.Format(" %s%s %.1f->%s", tool, fin ? "(fin)" : "", xp / to.Size(), to[i].wpnClass);
		}
		return s;
	}

	// which path a tool's share takes
	static String Kind(String tool)
	{
		if (tool == "gun" || tool == "rig.draw") return "gun";
		if (tool.Left(6) == "saber." || tool.Left(6) == "force.") return "saber";
		if (tool.Left(7) == "shield.") return "shield";
		if (tool == "glove") return "glove";
		if (tool == "punch" || tool == "kick" || tool == "blade" || tool == "finisher") return "melee";
		return "pool";
	}

	// which path a weapon record belongs to
	static String Sort(TFLV_WeaponInfo info)
	{
		if (!info) return "";
		String n = info.wpnClass;
		if (RSQM.IsSaberName(n) || n ~== "UBQS_ForceHand") return "saber";
		if (RSQM.IsShieldName(n)) return "shield";
		if (RSQM.IsGloveName(n)) return "glove";
		if (info.IsMelee()) return "melee";
		return "gun";
	}

	// the records of this path that hit the victim in the last 10 s (Gun Bonsai's own credit), once each
	static void Hit(TFLV_PerPlayerStats stats, Actor victim, String kind, out Array<TFLV_WeaponInfo> to)
	{
		if (!victim) return;
		for (int i = stats.styleV.Size() - 1; i >= 0; i--)
		{
			if (stats.styleV[i] != victim || gametic - stats.styleTic[i] > 350) continue;
			let info = stats.styleInfo[i];
			if (!info || !info.wpn || stats.GetInfoFor(info.wpn) != info || Sort(info) != kind) continue;
			if (to.Find(info) < to.Size()) continue;
			to.Push(info);
		}
	}

	// the player's own saber / shield / gloves, by class name (a record is made if it has none yet)
	static TFLV_WeaponInfo Owned(TFLV_PerPlayerStats stats, PlayerPawn pmo, String kind)
	{
		Weapon best = null;
		for (let it = pmo.Inv; it; it = it.Inv)
		{
			let w = Weapon(it);
			if (!w) continue;
			String n = w.GetClassName();
			bool fits = (kind == "saber" && RSQM.IsSaberName(n)) || (kind == "shield" && RSQM.IsShieldName(n)) || (kind == "glove" && RSQM.IsGloveName(n));
			if (!fits) continue;
			// the one in a hand first, then the main-hand class (UBQS_Saber, RSQ_Glove) before its off-hand twin
			if (pmo.player.ReadyWeapon == w || pmo.player.OffhandWeapon == w) { best = w; break; }
			if (!best || n.IndexOf("Off") < 0) best = w;
		}
		return best ? stats.GetOrCreateInfoFor(best) : null;
	}
}

