// ============================================================================
// THE ROSTER ROWS (owner 2026-11-09, design/SCORE_EXPANSION.md B and C): what was killed, from RSQ Monsters' roster --
// the 13-colour RSQ ladder (ColorfulHell's colour tiers), the EX boss forms, the CH spawn dial and the tier-change
// flash (MeatGrinder's rows, Gang War and Mixed Bag went with MeatGrinder, 11-10). "I want a big tree to prune": every row is
// built, and every row has its own on/off switch (server cvar rs_score_rr_*, on by default; Score's page, "Monster
// Roster Rows"), so pruning is a menu choice before it is a deletion.
//
// NOTHING HERE LINKS TO RSQ MONSTERS. Every fact is one question to its service, by name (RS_Svc.MONSTERS,
// "RSQMN_RosterService", Monsters/zscript/monsters/RS_ScoreReadout.zs). Without RSQ Monsters nobody answers (-1) and
// every row here pays 0.
//
// THE HOOK (boost.zs, "THE HOOK FOR A LATER MONSTER SET"): the tier rows ARE RS_ScoreTierRow subclasses -- one group
// per kill, the higher Mult wins. One difference, and why: the hook expects one inventory token per tier; the roster
// carries ONE token whose amount is the tier (RS_ZomTierToken). So each tier row answers its
// tier number and asks the service, instead of answering Token(). EX is its own group, so a Black Boss EX pays both.
// The rows are seeded through boost.zs's seed list (one line), like the champion rows.
//
// WHAT THE BASE ALREADY PAYS. A CH colour is its own class with its own Health, so a CH tier's health is in the base;
// these rows pay for its powers and rarity, the way the champion colour rows do (0.25 each, Bronze/Silver 0.5,
// Gold 0.75, a risen Legendary 1.5).
//
// THE LADDER IS NUMBERED BY STRENGTH since 11-11 (owner; RSQ Monsters RS_Retier.zs): 1 Common 2 Green 3 Blue 4 Purple
// 5 Cyan 6 Brown 7 Yellow 8 FireBlu 9 Gray 10 Red 11 Abyss 12 Black 13 White. These rows still rank a colour by the CH
// dial's RARITY, not its strength (CH weights: Cyan 120, Brown 65, Red 55 of the imp's 1843): Common 1, Green 2, Blue 3,
// Cyan 4, Purple 5, Yellow 6, FireBlu 7, Abyss 7, Brown 8, Gray 8, Red 9, Black 10, White 11 -- unchanged by the
// renumber, only keyed by the new tier numbers (Rank). "Top" is rank 10+ (the Black and White bosses) or an EX form;
// "low" is rank 3 or less.
//
// Pay, per row, is a share of the kill's base like every bonus, charged against the family caps and the kill cap.
// ============================================================================

class RS_RosterSeed play
{
	static void Names(out Array<String> into)
	{
		static const String rows[] =
		{
			"RS_RR_TierGreen", "RS_RR_TierBlue", "RS_RR_TierCyan", "RS_RR_TierPurple", "RS_RR_TierYellow",
			"RS_RR_TierFireBlu", "RS_RR_TierAbyss", "RS_RR_TierBrown", "RS_RR_TierGray", "RS_RR_TierRed",
			"RS_RR_TierBlack", "RS_RR_TierWhite", "RS_RR_EXBoss",
			"RS_RR_Rarity", "RS_RR_FullSpectrum", "RS_RR_ColourChain", "RS_RR_KeepTheChange", "RS_RR_FreshPaint",
			"RS_RR_Upset", "RS_RR_TierSlayer"
		};
		for (int i = 0; i < rows.Size(); i++) into.Push(rows[i]);
	}
}

// ---- the readers --------------------------------------------------------------------------------------------
class RS_Roster play
{
	static int Ask(String req, Actor v, int arg = 0) { return v ? RS_Svc.Int(RS_Svc.MONSTERS, req, arg, v) : -1; }
	static int SetOf(Actor v) { return Ask("set", v); }    // 1 CH, -1 not the roster
	static int Tier(Actor v) { return Ask("tier", v); }   // 1..13 (RSQ Monsters' ladder, strength order since 11-11), -1
	static bool EX(Actor v)  { return Ask("ex", v) == 1; }

	// a row's switch (server cvar, on when missing)
	static bool On(Name cv)
	{
		if (cv == 'None') return true;
		let c = CVar.FindCVar(cv);
		return !c || c.GetBool();
	}

	// the RARITY rank of a ladder tier (tier numbers since the 11-11 renumber; the ranks themselves unchanged)
	static int Rank(int tier)
	{
		switch (tier)
		{
			case 1:  return 1;   // Common
			case 2:  return 2;   // Green
			case 3:  return 3;   // Blue
			case 5:  return 4;   // Cyan
			case 4:  return 5;   // Purple
			case 7:  return 6;   // Yellow
			case 8:  return 7;   // FireBlu
			case 11: return 7;   // Abyss
			case 6:  return 8;   // Brown
			case 9:  return 8;   // Gray
			case 10: return 9;   // Red
			case 12: return 10;  // Black
			case 13: return 11;  // White
		}
		return 0;
	}

	static bool Top(Actor v) { return Rank(Tier(v)) >= 10 || EX(v); }
	static bool Low(Actor v) { int r = Rank(Tier(v)); return r >= 1 && r <= 3 && !EX(v); }

	// the monster whose blow killed it (an infight, or a monster your grenade turned): the blow's source walked up out of
	// any projectile, else the target Die() left (the handler's own rule)
	static Actor MonsterKiller(RS_ScoreEvent ev)
	{
		if (!ev.victim) return null;
		Actor src; bool known;
		[src, known] = RS_ScoreShots.KillSource(ev.victim);
		Actor k = known ? src : ev.victim.target;
		int guard = 0;
		while (k && k.bMissile && k.target && guard < 8) { k = k.target; guard++; }
		if (!k || k == ev.victim || k.player || !k.bIsMonster) return null;
		return k;
	}

	// a weak tool: the pistols, the fists and gloves, a kick, the gun-butt shove (tools.zs ids)
	static bool WeakTool(RS_ScoreEvent ev)
	{
		String t = RS_Rows.Tool(ev);
		if (t == "") return false;
		int dotAt = t.IndexOf(".");
		String pre = dotAt >= 0 ? t.Left(dotAt) : t;
		return t == "gun.pistol" || t == "punch" || t == "kick" || t == "shove" || pre == "glove";
	}

}

// The rows' memory for this map (one per level, saved with it; gone at the next map, as "in one map" asks).
class RS_RosterBook : Thinker
{
	const STATNUM = Thinker.STAT_USER + 39;   // GunCards uses +38, the Wheel +37 and +8

	int chainTier[MAXPLAYERS];     // Colour Chain: the colour and how many in a row
	int chainCount[MAXPLAYERS];
	int specMask[MAXPLAYERS];      // Full Spectrum: bit (tier - 1)
	bool specPaid[MAXPLAYERS];

	static RS_RosterBook Get()
	{
		let it = ThinkerIterator.Create("RS_RosterBook", STATNUM);
		let b = RS_RosterBook(it.Next());
		if (b) return b;
		b = new("RS_RosterBook");
		b.ChangeStatNum(STATNUM);
		return b;
	}
}

// A roster row with its own switch. Subclasses answer Ask; the switch is checked here.
class RS_RosterRow : RS_ScoreBonus
{
	virtual Name RowCvar() const { return 'None'; }
	virtual double Ask(RS_ScoreEvent ev) { return 0.0; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Roster.On(RowCvar()) ? Ask(ev) : 0.0; }
}

// ================================================================================ the tier rows (the hook)

// One colour of the ladder, on a player's kill. Common has no row: it is the ordinary spawn (630 of the
// imp's 1843), and a row on it would pay most kills for nothing.
class RS_RosterTierRow : RS_ScoreTierRow
{
	virtual int TierNo() const { return 0; }
	virtual Name RowCvar() const { return 'None'; }
	override Name Group() const { return 'rsqtier'; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !ev.victim || !RS_Roster.On(RowCvar())) return 0.0;
		return RS_Roster.Tier(ev.victim) == TierNo() ? Mult() : 0.0;
	}
}

class RS_RR_TierGreen   : RS_RosterTierRow { override int TierNo() const { return 2; }  override Name RowCvar() const { return 'rs_score_rr_green'; }   override String DisplayName() const { return "Green Tier"; }   override double Mult() const { return 0.1; } }
class RS_RR_TierBlue    : RS_RosterTierRow { override int TierNo() const { return 3; }  override Name RowCvar() const { return 'rs_score_rr_blue'; }    override String DisplayName() const { return "Blue Tier"; }    override double Mult() const { return 0.15; } }
class RS_RR_TierCyan    : RS_RosterTierRow { override int TierNo() const { return 5; } override Name RowCvar() const { return 'rs_score_rr_cyan'; }    override String DisplayName() const { return "Cyan Tier"; }    override double Mult() const { return 0.2; } }
class RS_RR_TierPurple  : RS_RosterTierRow { override int TierNo() const { return 4; }  override Name RowCvar() const { return 'rs_score_rr_purple'; }  override String DisplayName() const { return "Purple Tier"; }  override double Mult() const { return 0.25; } }
class RS_RR_TierYellow  : RS_RosterTierRow { override int TierNo() const { return 7; }  override Name RowCvar() const { return 'rs_score_rr_yellow'; }  override String DisplayName() const { return "Yellow Tier"; }  override double Mult() const { return 0.25; } }
class RS_RR_TierFireBlu : RS_RosterTierRow { override int TierNo() const { return 8; }  override Name RowCvar() const { return 'rs_score_rr_fireblu'; } override String DisplayName() const { return "FireBlu Tier"; } override double Mult() const { return 0.3; } }
class RS_RR_TierAbyss   : RS_RosterTierRow { override int TierNo() const { return 11; }  override Name RowCvar() const { return 'rs_score_rr_abyss'; }   override String DisplayName() const { return "Abyss Tier"; }   override double Mult() const { return 0.3; } }
class RS_RR_TierBrown   : RS_RosterTierRow { override int TierNo() const { return 6; } override Name RowCvar() const { return 'rs_score_rr_brown'; }   override String DisplayName() const { return "Brown Tier"; }   override double Mult() const { return 0.35; } }
class RS_RR_TierGray    : RS_RosterTierRow { override int TierNo() const { return 9; }  override Name RowCvar() const { return 'rs_score_rr_gray'; }    override String DisplayName() const { return "Gray Tier"; }    override double Mult() const { return 0.35; } }
class RS_RR_TierRed     : RS_RosterTierRow { override int TierNo() const { return 10; }  override Name RowCvar() const { return 'rs_score_rr_red'; }     override String DisplayName() const { return "Red Tier"; }     override double Mult() const { return 0.4; } }
// the boss tiers (Monsters' "Boss & Special Forms": about one spawn in eight hundred)
class RS_RR_TierBlack   : RS_RosterTierRow
{
	override int TierNo() const { return 12; }   // Black (10 before the 11-11 renumber)
	override Name RowCvar() const { return 'rs_score_rr_black'; }
	override String DisplayName() const { return "Black Boss"; }
	override double Mult() const { return 0.75; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}
class RS_RR_TierWhite   : RS_RosterTierRow
{
	override int TierNo() const { return 13; }   // White (11 before the 11-11 renumber)
	override Name RowCvar() const { return 'rs_score_rr_white'; }
	override String DisplayName() const { return "White Boss"; }
	override double Mult() const { return 1.0; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// EX: CH's "rarer, nastier build" of a boss (RS_BlackImpEX ...). Its own group: it pays on top of its Black or White row.
class RS_RR_EXBoss : RS_RosterTierRow
{
	override Name Group() const { return 'rsqex'; }
	override Name RowCvar() const { return 'rs_score_rr_ex'; }
	override String DisplayName() const { return "EX Boss"; }
	override double Mult() const { return 0.5; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !ev.victim || !RS_Roster.On(RowCvar())) return 0.0;
		return RS_Roster.EX(ev.victim) ? Mult() : 0.0;
	}
}

// ================================================================================ the roster

// Rarity: how rare the CH spawn roll was ("spawn.odds", 1 in N, the family's dial with the menu's gates). Pays from
// 1 in 20: 0.1 per doubling past 1 in 10, at most 1.0 (1 in 34 Red imp 0.18, 1 in 721 Black 0.62, 1 in 1443 White
// 0.72, an EX Black 0.94; the imp's dial with the default gates). Never for a body that changed tier.
class RS_RR_Rarity : RS_RosterRow
{
	const FROM = 20;
	const MAXMULT = 1.0;
	override Name RowCvar() const { return 'rs_score_rr_rarity'; }
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Rarity"; }
	override double Ask(RS_ScoreEvent ev)
	{
		if (!ev.killer) return 0.0;
		int n = RS_Roster.Ask("spawn.odds", ev.victim);
		if (n < FROM) return 0.0;
		return min(MAXMULT, 0.1 * (log(n / 10.0) / log(2.0)));
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid >= 0.5; }
}

// Full Spectrum: all 13 ladder colours (Common included) killed by you in one map. Paid once, on the kill that
// completes it (Rainbow's top pay for our ladder).
class RS_RR_FullSpectrum : RS_RosterRow
{
	const ALL = 0x1FFF;
	const MULT = 2.0;
	override Name RowCvar() const { return 'rs_score_rr_spectrum'; }
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Full Spectrum"; }
	static int Bit(RS_ScoreEvent ev) { int t = RS_Roster.Tier(ev.victim); return (t >= 1 && t <= 13) ? 1 << (t - 1) : 0; }
	override double Ask(RS_ScoreEvent ev)
	{
		int p = ev.killerNum;
		if (!ev.killer || p < 0) return 0.0;
		int bit = Bit(ev);
		let b = RS_RosterBook.Get();
		if (bit == 0 || b.specPaid[p] || (b.specMask[p] & bit)) return 0.0;
		return ((b.specMask[p] | bit) == ALL) ? MULT : 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		int p = ev.killerNum;
		if (!ev.killer || p < 0) return;
		int bit = Bit(ev);
		if (bit == 0) return;
		let b = RS_RosterBook.Get();
		b.specMask[p] |= bit;
		if (b.specMask[p] == ALL) b.specPaid[p] = true;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// Colour Chain (Radiant Silvergun): the same colour killed N times in a row. Any other kill breaks it; Common does not
// chain. Pays from the third: 0.15 each step, at most 0.75.
class RS_RR_ColourChain : RS_RosterRow
{
	const PER = 0.15;
	const MAXMULT = 0.75;
	override Name RowCvar() const { return 'rs_score_rr_chain'; }
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Colour Chain"; }
	override double Ask(RS_ScoreEvent ev)
	{
		int p = ev.killerNum;
		if (!ev.killer || p < 0) return 0.0;
		int t = RS_Roster.Tier(ev.victim);
		if (t < 2) return 0.0;
		let b = RS_RosterBook.Get();
		int n = (b.chainTier[p] == t) ? b.chainCount[p] + 1 : 1;
		return n >= 3 ? min(MAXMULT, PER * (n - 2)) : 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		int p = ev.killerNum;
		if (!ev.killer || p < 0) return;
		let b = RS_RosterBook.Get();
		int t = RS_Roster.Tier(ev.victim);
		if (t < 2) { b.chainTier[p] = 0; b.chainCount[p] = 0; return; }
		if (b.chainTier[p] == t) b.chainCount[p]++;
		else { b.chainTier[p] = t; b.chainCount[p] = 1; }
	}
}

// Keep the Change (owner's name): killed while it flashes, before the tier change lands (RS_Retier's job).
// Only a change UP (by rank); 0.5 when it was becoming a boss.
class RS_RR_KeepTheChange : RS_RosterRow
{
	const MULT = 0.3;
	const BOSS = 0.5;
	override Name RowCvar() const { return 'rs_score_rr_keepchange'; }
	override int Family() const { return FAM_EFFICIENCY; }
	override String DisplayName() const { return "Keep the Change"; }
	override double Ask(RS_ScoreEvent ev)
	{
		if (!ev.killer) return 0.0;
		int next = RS_Roster.Ask("tier.next", ev.victim);
		if (next < 1) return 0.0;
		int rn = RS_Roster.Rank(next);
		if (rn <= RS_Roster.Rank(RS_Roster.Tier(ev.victim))) return 0.0;
		return rn >= 10 ? BOSS : MULT;
	}
}

// Fresh Paint: killed within 3 s of a tier change up (the flash path; a body born at its tier does not count).
class RS_RR_FreshPaint : RS_RosterRow
{
	const MULT = 0.25;
	const WINDOW = 105;
	override Name RowCvar() const { return 'rs_score_rr_freshpaint'; }
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Fresh Paint"; }
	override double Ask(RS_ScoreEvent ev)
	{
		if (!ev.killer) return 0.0;
		int ago = RS_Roster.Ask("tier.ago", ev.victim);
		if (ago < 0 || ago > WINDOW) return 0.0;
		int from = RS_Roster.Ask("tier.from", ev.victim);
		return RS_Roster.Rank(RS_Roster.Tier(ev.victim)) > RS_Roster.Rank(from) ? MULT : 0.0;
	}
}

// Upset: infighting -- a low tier (Common, Green, Blue) kills a top tier (a Black or White boss, an EX). Paid like
// Infighter, to every player (or to you, when your grenade turned the killer).
class RS_RR_Upset : RS_RosterRow
{
	const MULT = 0.75;
	override Name RowCvar() const { return 'rs_score_rr_upset'; }
	override int Family() const { return FAM_EFFICIENCY; }
	override String DisplayName() const { return "Upset"; }
	override double Ask(RS_ScoreEvent ev)
	{
		if (!ev.monsterOnMonster && !ev.turncoat) return 0.0;
		let k = RS_Roster.MonsterKiller(ev);
		return (k && RS_Roster.Low(k) && RS_Roster.Top(ev.victim)) ? MULT : 0.0;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// Tier Slayer (the owner's "tier Giant Slayer"): you kill a top tier with a weak tool -- a pistol, your fists or
// gloves, a kick, the gun-butt shove. Giant Slayer itself stays the melee kill of a big monster.
class RS_RR_TierSlayer : RS_RosterRow
{
	const MULT = 0.5;
	override Name RowCvar() const { return 'rs_score_rr_tierslayer'; }
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Tier Slayer"; }
	override double Ask(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut) return 0.0;
		return (RS_Roster.Top(ev.victim) && RS_Roster.WeakTool(ev)) ? MULT : 0.0;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}
