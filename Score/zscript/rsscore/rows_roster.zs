// ============================================================================
// THE ROSTER ROWS (owner 2026-11-09, design/SCORE_EXPANSION.md B and C): what was killed, from RSQ Monsters' roster --
// the 13-colour RSQ ladder (CH colour tiers and MeatGrinder in-place tiers), the EX boss forms, the CH spawn dial, the
// tier-change flash, and MeatGrinder's reactive deaths and Abyss split. "I want a big tree to prune": every row is
// built, and every row has its own on/off switch (server cvar rs_score_rr_*, on by default; Score's page, "Monster
// Roster Rows"), so pruning is a menu choice before it is a deletion.
//
// NOTHING HERE LINKS TO RSQ MONSTERS. Every fact is one question to its service, by name (RS_Svc.MONSTERS,
// "RSQMN_RosterService", Monsters/zscript/monsters/RS_ScoreReadout.zs). Without RSQ Monsters nobody answers (-1) and
// every row here pays 0.
//
// THE HOOK (boost.zs, "THE HOOK FOR A LATER MONSTER SET"): the tier rows ARE RS_ScoreTierRow subclasses -- one group
// per kill, the higher Mult wins. One difference, and why: the hook expects one inventory token per tier; the roster
// carries ONE token whose amount is the tier (CH, RS_ZomTierToken) or a field (MG, Tier). So each tier row answers its
// tier number and asks the service, instead of answering Token(). EX is its own group, so a Black Boss EX pays both.
// The rows are seeded through boost.zs's seed list (one line), like the champion rows.
//
// WHAT THE BASE ALREADY PAYS. A CH colour is its own class with its own Health, so a CH tier's health is in the base;
// these rows pay for its powers and rarity, the way the champion colour rows do (0.25 each, Bronze/Silver 0.5,
// Gold 0.75, a risen Legendary 1.5). A MeatGrinder tier sets health on the live body, so today its base is the
// Common's (SCORE_EXPANSION.md A1, the other lane's fix); the rows do not try to make that up.
//
// THE LADDER'S ORDER IS NOT ITS STRENGTH. Tier 12 Cyan and 13 Brown are not stronger than 6 Red (CH weights: Cyan 120,
// Brown 65, Red 55 of the imp's 1843; MG health x1.8, x3.0, x5.0). So the rows rank a colour by the CH dial's rarity and
// MG's health curve together: Common 1, Green 2, Blue 3, Cyan 4, Purple 5, Yellow 6, FireBlu 7, Abyss 7, Brown 8,
// Gray 8, Red 9, Black 10, White 11. "Top" is rank 10+ (the Black and White bosses) or an EX form; "low" is rank 3 or less.
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
			"RS_RR_Upset", "RS_RR_TierSlayer", "RS_RR_GangWar", "RS_RR_MixedBag",
			"RS_RR_Headhunter", "RS_RR_MGBarbecue", "RS_RR_MGIceBreaker", "RS_RR_MGLiveWire", "RS_RR_MGPop",
			"RS_RR_MGCleaved", "RS_RR_MGPinata", "RS_RR_Meltdown", "RS_RR_Splitter", "RS_RR_CutShort"
		};
		for (int i = 0; i < rows.Size(); i++) into.Push(rows[i]);
	}
}

// ---- the readers --------------------------------------------------------------------------------------------
class RS_Roster play
{
	// MG reactive deaths (RSQMN_RosterService "mg.death")
	enum EMGDeath { MGD_NONE, MGD_HEAD, MGD_HEADBURST, MGD_GIB, MGD_BURN, MGD_FREEZE, MGD_SHOCK, MGD_MELT }

	static int Ask(String req, Actor v, int arg = 0) { return v ? RS_Svc.Int(RS_Svc.MONSTERS, req, arg, v) : -1; }
	static int SetOf(Actor v) { return Ask("set", v); }    // 1 CH, 2 MG, -1 not the roster
	static int Tier(Actor v) { return Ask("tier", v); }   // 1..13, -1
	static bool EX(Actor v)  { return Ask("ex", v) == 1; }

	// a row's switch (server cvar, on when missing)
	static bool On(Name cv)
	{
		if (cv == 'None') return true;
		let c = CVar.FindCVar(cv);
		return !c || c.GetBool();
	}

	static int Rank(int tier)
	{
		switch (tier)
		{
			case 1:  return 1;   // Common
			case 2:  return 2;   // Green
			case 3:  return 3;   // Blue
			case 12: return 4;   // Cyan
			case 4:  return 5;   // Purple
			case 5:  return 6;   // Yellow
			case 7:  return 7;   // FireBlu
			case 9:  return 7;   // Abyss
			case 13: return 8;   // Brown
			case 8:  return 8;   // Gray
			case 6:  return 9;   // Red
			case 10: return 10;  // Black
			case 11: return 11;  // White
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
		int dot = t.IndexOf(".");
		String pre = dot >= 0 ? t.Left(dot) : t;
		return t == "gun.pistol" || t == "punch" || t == "kick" || t == "shove" || pre == "glove";
	}

	// the MG reactive death this kill brings (the killing blow's damage: health before it, less health after)
	static int MGDeath(RS_ScoreEvent ev)
	{
		if (!ev.victim) return -1;
		int dmg = ev.healthBefore >= 0 ? ev.healthBefore - ev.victim.health : -1;
		return Ask("mg.death", ev.victim, dmg);
	}
	static bool MGKill(RS_ScoreEvent ev) { return ev.killer && SetOf(ev.victim) == 2; }
}

// The rows' memory for this map (one per level, saved with it; gone at the next map, as "in one map" asks).
class RS_RosterBook : Thinker
{
	const STATNUM = Thinker.STAT_USER + 39;   // GunCards uses +38, the Wheel +37 and +8

	int chainTier[MAXPLAYERS];     // Colour Chain: the colour and how many in a row
	int chainCount[MAXPLAYERS];
	int specMask[MAXPLAYERS];      // Full Spectrum: bit (tier - 1)
	bool specPaid[MAXPLAYERS];
	int headRun[MAXPLAYERS];       // Headhunter: head-pops in a row, and the last one's tic
	int headTic[MAXPLAYERS];
	int lastSet[MAXPLAYERS];       // Mixed Bag: the set of your last roster kill, and when
	int lastSetTic[MAXPLAYERS];
	Array<int> spGroup, spKiller, spSouls;                // Splitter: an Abyss split's group, who killed the parent, souls since

	static RS_RosterBook Get()
	{
		let it = ThinkerIterator.Create("RS_RosterBook", STATNUM);
		let b = RS_RosterBook(it.Next());
		if (b) return b;
		b = new("RS_RosterBook");
		b.ChangeStatNum(STATNUM);
		return b;
	}

	int SplitAt(int g)
	{
		for (int i = 0; i < spGroup.Size(); i++) if (spGroup[i] == g) return i;
		return -1;
	}
}

// A roster row with its own switch. Subclasses answer Ask; the switch is checked here.
class RS_RosterRow : RS_ScoreBonus
{
	virtual Name Switch() const { return 'None'; }
	virtual double Ask(RS_ScoreEvent ev) { return 0.0; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Roster.On(Switch()) ? Ask(ev) : 0.0; }
}

// ================================================================================ the tier rows (the hook)

// One colour of the ladder, on a player's kill (CH or MG). Common has no row: it is the ordinary spawn (630 of the
// imp's 1843, every MG map spawn), and a row on it would pay most kills for nothing.
class RS_RosterTierRow : RS_ScoreTierRow
{
	virtual int TierNo() const { return 0; }
	virtual Name Switch() const { return 'None'; }
	override Name Group() const { return 'rsqtier'; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !ev.victim || !RS_Roster.On(Switch())) return 0.0;
		return RS_Roster.Tier(ev.victim) == TierNo() ? Mult() : 0.0;
	}
}

class RS_RR_TierGreen   : RS_RosterTierRow { override int TierNo() const { return 2; }  override Name Switch() const { return 'rs_score_rr_green'; }   override String DisplayName() const { return "Green Tier"; }   override double Mult() const { return 0.1; } }
class RS_RR_TierBlue    : RS_RosterTierRow { override int TierNo() const { return 3; }  override Name Switch() const { return 'rs_score_rr_blue'; }    override String DisplayName() const { return "Blue Tier"; }    override double Mult() const { return 0.15; } }
class RS_RR_TierCyan    : RS_RosterTierRow { override int TierNo() const { return 12; } override Name Switch() const { return 'rs_score_rr_cyan'; }    override String DisplayName() const { return "Cyan Tier"; }    override double Mult() const { return 0.2; } }
class RS_RR_TierPurple  : RS_RosterTierRow { override int TierNo() const { return 4; }  override Name Switch() const { return 'rs_score_rr_purple'; }  override String DisplayName() const { return "Purple Tier"; }  override double Mult() const { return 0.25; } }
class RS_RR_TierYellow  : RS_RosterTierRow { override int TierNo() const { return 5; }  override Name Switch() const { return 'rs_score_rr_yellow'; }  override String DisplayName() const { return "Yellow Tier"; }  override double Mult() const { return 0.25; } }
class RS_RR_TierFireBlu : RS_RosterTierRow { override int TierNo() const { return 7; }  override Name Switch() const { return 'rs_score_rr_fireblu'; } override String DisplayName() const { return "FireBlu Tier"; } override double Mult() const { return 0.3; } }
class RS_RR_TierAbyss   : RS_RosterTierRow { override int TierNo() const { return 9; }  override Name Switch() const { return 'rs_score_rr_abyss'; }   override String DisplayName() const { return "Abyss Tier"; }   override double Mult() const { return 0.3; } }
class RS_RR_TierBrown   : RS_RosterTierRow { override int TierNo() const { return 13; } override Name Switch() const { return 'rs_score_rr_brown'; }   override String DisplayName() const { return "Brown Tier"; }   override double Mult() const { return 0.35; } }
class RS_RR_TierGray    : RS_RosterTierRow { override int TierNo() const { return 8; }  override Name Switch() const { return 'rs_score_rr_gray'; }    override String DisplayName() const { return "Gray Tier"; }    override double Mult() const { return 0.35; } }
class RS_RR_TierRed     : RS_RosterTierRow { override int TierNo() const { return 6; }  override Name Switch() const { return 'rs_score_rr_red'; }     override String DisplayName() const { return "Red Tier"; }     override double Mult() const { return 0.4; } }
// the boss tiers (Monsters' "Boss & Special Forms": about one spawn in eight hundred)
class RS_RR_TierBlack   : RS_RosterTierRow
{
	override int TierNo() const { return 10; }
	override Name Switch() const { return 'rs_score_rr_black'; }
	override String DisplayName() const { return "Black Boss"; }
	override double Mult() const { return 0.75; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}
class RS_RR_TierWhite   : RS_RosterTierRow
{
	override int TierNo() const { return 11; }
	override Name Switch() const { return 'rs_score_rr_white'; }
	override String DisplayName() const { return "White Boss"; }
	override double Mult() const { return 1.0; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// EX: CH's "rarer, nastier build" of a boss (RS_BlackImpEX ...). Its own group: it pays on top of its Black or White row.
class RS_RR_EXBoss : RS_RosterTierRow
{
	override Name Group() const { return 'rsqex'; }
	override Name Switch() const { return 'rs_score_rr_ex'; }
	override String DisplayName() const { return "EX Boss"; }
	override double Mult() const { return 0.5; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !ev.victim || !RS_Roster.On(Switch())) return 0.0;
		return RS_Roster.EX(ev.victim) ? Mult() : 0.0;
	}
}

// ================================================================================ the roster

// Rarity: how rare the CH spawn roll was ("spawn.odds", 1 in N, the family's dial with the menu's gates). Pays from
// 1 in 20: 0.1 per doubling past 1 in 10, at most 1.0 (1 in 34 Red imp 0.18, 1 in 721 Black 0.62, 1 in 1443 White
// 0.72, an EX Black 0.94; the imp's dial with the default gates). Never for MG (never rolled) or a body that changed tier.
class RS_RR_Rarity : RS_RosterRow
{
	const FROM = 20;
	const MAXMULT = 1.0;
	override Name Switch() const { return 'rs_score_rr_rarity'; }
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

// Full Spectrum: all 13 ladder colours (Common included) killed by you in one map, CH or MG. Paid once, on the kill that
// completes it (Rainbow's top pay for our ladder).
class RS_RR_FullSpectrum : RS_RosterRow
{
	const ALL = 0x1FFF;
	const MULT = 2.0;
	override Name Switch() const { return 'rs_score_rr_spectrum'; }
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
// chain (every MG map spawn is Common). Pays from the third: 0.15 each step, at most 0.75.
class RS_RR_ColourChain : RS_RosterRow
{
	const PER = 0.15;
	const MAXMULT = 0.75;
	override Name Switch() const { return 'rs_score_rr_chain'; }
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

// Keep the Change (owner's name): killed while it flashes, before the tier change lands (RS_Retier's job, CH and MG).
// Only a change UP (by rank); 0.5 when it was becoming a boss.
class RS_RR_KeepTheChange : RS_RosterRow
{
	const MULT = 0.3;
	const BOSS = 0.5;
	override Name Switch() const { return 'rs_score_rr_keepchange'; }
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
	override Name Switch() const { return 'rs_score_rr_freshpaint'; }
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
	override Name Switch() const { return 'rs_score_rr_upset'; }
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
	override Name Switch() const { return 'rs_score_rr_tierslayer'; }
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Tier Slayer"; }
	override double Ask(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut) return 0.0;
		return (RS_Roster.Top(ev.victim) && RS_Roster.WeakTool(ev)) ? MULT : 0.0;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// Gang War: a CH monster kills an MG monster, or the reverse. Paid like Infighter, to every player (or to you, for a
// monster your grenade turned).
class RS_RR_GangWar : RS_RosterRow
{
	const MULT = 0.3;
	override Name Switch() const { return 'rs_score_rr_gangwar'; }
	override int Family() const { return FAM_EFFICIENCY; }
	override String DisplayName() const { return "Gang War"; }
	override double Ask(RS_ScoreEvent ev)
	{
		if (!ev.monsterOnMonster && !ev.turncoat) return 0.0;
		let k = RS_Roster.MonsterKiller(ev);
		if (!k) return 0.0;
		int a = RS_Roster.SetOf(k), b = RS_Roster.SetOf(ev.victim);
		return (a > 0 && b > 0 && a != b) ? MULT : 0.0;
	}
}

// Mixed Bag: both sets in one combo -- this kill and your kill of the other set (CH / MG) within 3 s (the combo chain's
// window).
class RS_RR_MixedBag : RS_RosterRow
{
	const MULT = 0.3;
	const WINDOW = 105;
	override Name Switch() const { return 'rs_score_rr_mixedbag'; }
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Mixed Bag"; }
	override double Ask(RS_ScoreEvent ev)
	{
		int p = ev.killerNum;
		if (!ev.killer || p < 0) return 0.0;
		int s = RS_Roster.SetOf(ev.victim);
		let b = RS_RosterBook.Get();
		if (s < 1 || b.lastSet[p] < 1 || b.lastSet[p] == s) return 0.0;
		return level.maptime - b.lastSetTic[p] <= WINDOW ? MULT : 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		int p = ev.killerNum;
		if (!ev.killer || p < 0) return;
		int s = RS_Roster.SetOf(ev.victim);
		if (s < 1) return;
		let b = RS_RosterBook.Get();
		b.lastSet[p] = s;
		b.lastSetTic[p] = level.maptime;
	}
}

// ================================================================================ MeatGrinder

// Headhunter: an MG head-pop (its reactive head death, burst or not), and a streak of them: 0.15, +0.1 for each
// head-pop before it in a row (each within 5 s, any other kill breaks it), at most 0.65.
class RS_RR_Headhunter : RS_RosterRow
{
	const MULT = 0.15;
	const PER = 0.1;
	const MAXMULT = 0.65;
	const WINDOW = 175;
	override Name Switch() const { return 'rs_score_rr_headhunter'; }
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Headhunter"; }
	static bool Popped(RS_ScoreEvent ev)
	{
		if (!RS_Roster.MGKill(ev)) return false;
		int d = RS_Roster.MGDeath(ev);
		return d == RS_Roster.MGD_HEAD || d == RS_Roster.MGD_HEADBURST;
	}
	static int Earlier(RS_ScoreEvent ev)
	{
		let b = RS_RosterBook.Get();
		int p = ev.killerNum;
		return (b.headRun[p] > 0 && level.maptime - b.headTic[p] <= WINDOW) ? b.headRun[p] : 0;
	}
	override double Ask(RS_ScoreEvent ev)
	{
		if (ev.killerNum < 0 || !Popped(ev)) return 0.0;
		return min(MAXMULT, MULT + PER * Earlier(ev));
	}
	override void Commit(RS_ScoreEvent ev)
	{
		int p = ev.killerNum;
		if (!ev.killer || p < 0) return;
		let b = RS_RosterBook.Get();
		if (Popped(ev)) { b.headRun[p] = Earlier(ev) + 1; b.headTic[p] = level.maptime; }
		else b.headRun[p] = 0;
	}
}

// THE REACTIVE DEATHS FEED THE ROWS SCORE ALREADY HAS. An MG monster's burn, freeze, shock, exploding head and gib
// are its own death states, not the facts those rows read (a tool, a tag, a champion's token, the gib threshold), so
// they went unseen. Each row below shows the SAME NAME, family and pay as the row it feeds, fires only on an MG kill
// with that death, and stands down when the original row fires on the same kill (it asks it), so a kill never shows
// the name twice. Melt has no row of its own yet: Meltdown is new.
class RS_RosterFeedRow : RS_RosterRow
{
	transient RS_ScoreBonus orig;
	virtual Name Original() const { return 'None'; }
	virtual bool Matches(RS_ScoreEvent ev, int death) { return false; }
	virtual double Pay() const { return 0.0; }
	bool OriginalFires(RS_ScoreEvent ev)
	{
		if (Original() == 'None') return false;
		if (!orig)
		{
			class<RS_ScoreBonus> c = Original();
			if (c) orig = RS_ScoreBonus(new(c));
		}
		return orig && orig.Evaluate(ev) > 0.0;
	}
	override double Ask(RS_ScoreEvent ev)
	{
		if (!RS_Roster.MGKill(ev)) return 0.0;
		int d = RS_Roster.MGDeath(ev);
		if (d <= 0 || !Matches(ev, d) || OriginalFires(ev)) return 0.0;
		return Pay();
	}
}

class RS_RR_MGBarbecue : RS_RosterFeedRow
{
	override Name Switch() const { return 'rs_score_rr_mgburn'; }
	override Name Original() const { return 'RS_Row_Barbecue'; }
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Barbecue"; }
	override double Pay() const { return RS_Row_Barbecue.MULT; }
	override bool Matches(RS_ScoreEvent ev, int death) { return death == RS_Roster.MGD_BURN; }
}

class RS_RR_MGIceBreaker : RS_RosterFeedRow
{
	override Name Switch() const { return 'rs_score_rr_mgfreeze'; }
	override Name Original() const { return 'RS_Row_IceBreaker'; }
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Ice Breaker"; }
	override double Pay() const { return RS_Row_IceBreaker.MULT; }
	override bool Matches(RS_ScoreEvent ev, int death) { return death == RS_Roster.MGD_FREEZE; }
}

class RS_RR_MGLiveWire : RS_RosterFeedRow
{
	override Name Switch() const { return 'rs_score_rr_mgshock'; }
	override Name Original() const { return 'RS_Row_LiveWire'; }
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Live Wire"; }
	override double Pay() const { return RS_Row_LiveWire.MULT; }
	override bool Matches(RS_ScoreEvent ev, int death) { return death == RS_Roster.MGD_SHOCK; }
}

// the exploding head (a head-pop from a heavy hit, Monsters' "explode heads")
class RS_RR_MGPop : RS_RosterFeedRow
{
	override Name Switch() const { return 'rs_score_rr_mgpop'; }
	override Name Original() const { return 'RS_Row_Pop'; }
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Pop!"; }
	override double Pay() const { return RS_Row_Pop.MULT; }
	override bool Matches(RS_ScoreEvent ev, int death) { return death == RS_Roster.MGD_HEADBURST; }
}

// an MG gib by a melee blow: Cleaved's kill (the same melee kinds Cleaved counts)
class RS_RR_MGCleaved : RS_RosterFeedRow
{
	override Name Switch() const { return 'rs_score_rr_mgcleaved'; }
	override Name Original() const { return 'RS_Bonus_Cleaved'; }
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Cleaved"; }
	override double Pay() const { return RS_Bonus_Cleaved.MULT; }
	override bool Matches(RS_ScoreEvent ev, int death)
	{
		if (death != RS_Roster.MGD_GIB) return false;
		int k = RS_Melee.Kind(ev);
		return !(k == RS_Melee.MK_NONE || k == RS_Melee.MK_FINISH || k == RS_Melee.MK_HOOK || k == RS_Melee.MK_GRENADE || k == RS_Melee.MK_THROW);
	}
}

// an MG gib of a coloured tier by anything else: Pinata's kill (the roster's coloured tiers are its champions)
class RS_RR_MGPinata : RS_RosterFeedRow
{
	override Name Switch() const { return 'rs_score_rr_mgpinata'; }
	override Name Original() const { return 'RS_Row_Pinata'; }
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Pinata"; }
	override double Pay() const { return RS_Row_Pinata.MULT; }
	override bool Matches(RS_ScoreEvent ev, int death)
	{
		if (death != RS_Roster.MGD_GIB || RS_Roster.Tier(ev.victim) < 2) return false;
		int k = RS_Melee.Kind(ev);
		return k == RS_Melee.MK_NONE || k == RS_Melee.MK_FINISH || k == RS_Melee.MK_HOOK || k == RS_Melee.MK_GRENADE || k == RS_Melee.MK_THROW;
	}
}

// Meltdown (new): an MG monster melted (acid / melt damage). Barbecue's pay.
class RS_RR_Meltdown : RS_RosterFeedRow
{
	const MULT = 0.25;
	override Name Switch() const { return 'rs_score_rr_meltdown'; }
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Meltdown"; }
	override double Pay() const { return MULT; }
	override bool Matches(RS_ScoreEvent ev, int death) { return death == RS_Roster.MGD_MELT; }
}

// Splitter: you kill an Abyss MG monster and both lost souls it split into (paid on the second soul).
class RS_RR_Splitter : RS_RosterRow
{
	const MULT = 0.75;
	override Name Switch() const { return 'rs_score_rr_splitter'; }
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Splitter"; }
	override double Ask(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.killerNum < 0) return 0.0;
		int g = RS_Roster.Ask("split.group", ev.victim);
		if (g <= 0 || RS_Roster.Ask("split.child", ev.victim) != 1) return 0.0;
		let b = RS_RosterBook.Get();
		int at = b.SplitAt(g);
		return (at >= 0 && b.spKiller[at] == ev.killerNum && b.spSouls[at] == 1) ? MULT : 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.killerNum < 0) return;
		int g = RS_Roster.Ask("split.group", ev.victim);
		if (g <= 0) return;
		let b = RS_RosterBook.Get();
		int at = b.SplitAt(g);
		if (RS_Roster.Ask("split.child", ev.victim) != 1)
		{
			if (at < 0) { b.spGroup.Push(g); b.spKiller.Push(ev.killerNum); b.spSouls.Push(0); }
			return;
		}
		if (at >= 0 && b.spKiller[at] == ev.killerNum) b.spSouls[at]++;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// Cut Short: you kill a top-aggression MG monster (its tier fires +MISSILEEVENMORE: Yellow, Red, Black, White) while it
// is in its own attack (its Missile or Melee sequence; RS_Melee.InAttack, the state before Die changes it).
class RS_RR_CutShort : RS_RosterRow
{
	const MULT = 0.4;
	override Name Switch() const { return 'rs_score_rr_cutshort'; }
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Cut Short"; }
	override double Ask(RS_ScoreEvent ev)
	{
		if (!RS_Roster.MGKill(ev)) return 0.0;
		return (RS_Roster.Ask("mg.behave", ev.victim) >= 3 && RS_Melee.InAttack(ev.victim)) ? MULT : 0.0;
	}
}
