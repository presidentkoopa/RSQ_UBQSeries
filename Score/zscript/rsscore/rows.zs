// ============================================================================
// THE 11-03 ROWS: the sheet's kept bonuses (Score/ideas/NAMING_SHEET.csv), one row per distinct feel, built where the
// fact is readable today or its answer now exists. Names are proposals (the owner renames after 1.0); every pay is
// the sheet's starting number. Each row says which sheet id it is.
//
// The facts come from what the rest of Score already keeps: the kill's tool and tags (the ledger, tools.zs), the
// melee kind (melee.zs), the thrown things in flight and the blow's health-before (RS_ScoreShots), the boosted-monster
// tokens (boost.zs), the mods' services (svc.zs), and the tracker's counters (tracker.zs, the 11-03 block).
// ============================================================================

class RS_RowSeed play
{
	static void Names(out Array<String> into)
	{
		static const String rows[] =
		{
			// the fists (RSQ Melee)
			"RS_Row_Shoryuken", "RS_Row_LiverShot", "RS_Row_GlassJaw", "RS_Row_Textbook", "RS_Row_TripleThreat",
			"RS_Row_DempseyRoll", "RS_Row_AirCombo", "RS_Row_Bouncer", "RS_Row_Release", "RS_Row_Toss",
			"RS_Row_Piledriver", "RS_Row_CutLoose", "RS_Row_ButtStroke", "RS_Row_KO", "RS_Row_Shatter",
			"RS_Row_LiveWire", "RS_Row_BlastRadius",
			// shared melee (sheet X)
			"RS_Row_WeaponMaster", "RS_Row_GiantSlayer", "RS_Row_DeathFromAbove", "RS_Row_Juggler",
			"RS_Row_Misdirection", "RS_Row_MultiKill",
			// the saber
			"RS_Row_Lunge", "RS_Row_Impaled", "RS_Row_BackOff", "RS_Row_DoubleThrow",
			// the ShieldSaw
			"RS_Row_ShieldDash", "RS_Row_BitOffMore", "RS_Row_Homecoming", "RS_Row_EyesInTheBack",
			"RS_Row_HoldTheLine", "RS_Row_Cleaver",
			// the whip
			"RS_Row_WreckingBall", "RS_Row_Tarzan", "RS_Row_StunLock", "RS_Row_HeavyHaul", "RS_Row_SnapKill",
			// the hook
			"RS_Row_HookedKeg", "RS_Row_BoardingParty", "RS_Row_ZipKick", "RS_Row_Scorpion",
			// Distance Grab, the rig
			"RS_Row_HeavyThrow", "RS_Row_Throwaway", "RS_Row_Iaido", "RS_Row_PinPulled", "RS_Row_Armory",
			// the grenade
			"RS_Row_Cooked", "RS_Row_Airburst", "RS_Row_Tagged", "RS_Row_HoldMyBeer", "RS_Row_ClusterBomb",
			"RS_Row_IceBreaker", "RS_Row_CivilWar", "RS_Row_Blindside", "RS_Row_Barbecue",
			// the guns (BD22 VR's classes)
			"RS_Row_HoldStreak", "RS_Row_DoubleTap", "RS_Row_HandCannon", "RS_Row_Headshot", "RS_Row_SightsUp",
			"RS_Row_DirectHit", "RS_Row_DangerClose", "RS_Row_Unmade", "RS_Row_RipAndTear", "RS_Row_Tomahawk",
			// Champions, LegenDoom, Miniboss, slow motion
			"RS_Row_ImmovableObject", "RS_Row_Pop", "RS_Row_Pinata", "RS_Row_ChampionStreak", "RS_Row_TooClose",
			"RS_Row_GlassCannon", "RS_Row_FoolsGold", "RS_Row_Heartbreaker", "RS_Row_ChampionFatality", "RS_Row_Rainbow",
			"RS_Row_OneTapLegend", "RS_Row_StrikeWhileItRises", "RS_Row_LegendSlayer",
			"RS_Row_ChainGang", "RS_Row_RageQuit", "RS_Row_RiotControl", "RS_Row_Severed",
			"RS_Row_LastGrain",
			// the second round (the facts the mods answer since 11-03 evening)
			"RS_Row_RunThrough", "RS_Row_Saberstaff", "RS_Row_UnlimitedPower", "RS_Row_ClashBreak",
			"RS_Row_Buzzsaw", "RS_Row_WallSplat", "RS_Row_Clubbed", "RS_Row_TrapShot", "RS_Row_Teeth", "RS_Row_Contact",
			"RS_Row_ChainSwing"
		};
		for (int i = 0; i < rows.Size(); i++) into.Push(rows[i]);
	}
}

// ---- the shared readers --------------------------------------------------------------------------------------
class RS_Rows play
{
	// a melee kind that is a blow of the hands or a hand weapon (not a shot, a throw's landing, a grenade)
	static bool MeleeKind(RS_ScoreEvent ev)
	{
		int k = RS_Melee.Kind(ev);
		return k != RS_Melee.MK_NONE && k != RS_Melee.MK_GRENADE && k != RS_Melee.MK_THROW;
	}
	// the glove's blow (RSQ Melee's RSQ_Glove is the inflictor)
	static bool GloveKill(RS_ScoreEvent ev) { return RS_Melee.Kind(ev) == RS_Melee.MK_FIST && RS_Melee.IsGlove(ev.inflictor); }
	// RSQ Melee's answers about the glove that struck
	static int Punch(RS_ScoreEvent ev, String what) { return ev.inflictor ? RS_Svc.Int(RS_Svc.MELEE, what, 0, ev.inflictor) : -1; }
	// a tag on any step of the kill's chain
	static bool ChainTag(RS_ScoreEvent ev, String tag)
	{
		RS_Combo.ChainOf(ev);
		let led = RS_ComboLedger.Get();
		if (!led) return false;
		for (int k = 0; k < ev.chainIdx.Size(); k++) if (led.TagAt(ev.chainIdx[k], tag)) return true;
		return false;
	}
	// a tool (or group) on any step of the kill's chain but the last
	static bool ChainHas(RS_ScoreEvent ev, String step)
	{
		RS_Combo.ChainOf(ev);
		for (int k = 0; k < ev.chain.Size() - 1; k++) if (RS_Tool.InGroup(ev.chain[k], step)) return true;
		return false;
	}
	static String Tool(RS_ScoreEvent ev) { return RS_Melee.KillTool(ev); }
	static String Infl(RS_ScoreEvent ev) { String s = ""; if (ev.inflictor) s = ev.inflictor.GetClassName(); return s; }
	// the gun that made this shot kill (physical.zs), or ""
	static String Gun(RS_ScoreEvent ev)
	{
		int kind = RS_Physical.ShotKind(ev);
		if (kind == RS_Physical.SHOT_NONE) return "";
		Weapon w; int hand;
		[w, hand] = RS_Physical.KillingGun(ev, kind);
		String s = "";
		if (w) s = w.GetClassName();
		if (s.Left(8) ~== "RSQ_Off_") s = s.Mid(8);
		return s;
	}
	// one blow from full: the victim's health before the killing blow was its spawn health or more
	static bool OneBlow(RS_ScoreEvent ev) { return ev.healthBefore >= ev.victimSpawnHealth && ev.victimSpawnHealth > 0; }
	static int Miniboss(String what, Actor about) { return RS_Svc.Int(RS_Svc.MINIBOSS, what, 0, about); }
	// the shot's line against the head's facing, degrees (No-Look's math)
	static double OffHead(RS_ScoreEvent ev, int kind)
	{
		int age = RS_Physical.ShotAge(ev, kind);
		return RS_Physical.Between(RS_Physical.ShotDir(ev, kind), RS_Physical.HeadAt(ev.killer, age));
	}
}

// ================================================================================ the fists (RSQ Melee)

// M1 Shoryuken: an uppercut kills it (the glove's own kind, answered by RSQ Melee).
class RS_Row_Shoryuken : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Shoryuken"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Tool(ev) == "glove.upper" ? MULT : 0.0; }
}

// M3 Liver Shot: a punch landed below the chest kills it (Melee's hit.body tag).
class RS_Row_LiverShot : RS_ScoreBonus
{
	const MULT = 0.2;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Liver Shot"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Rows.GloveKill(ev) && RS_Melee.Tagged(ev, "hit.body")) ? MULT : 0.0; }
}

// M4 Glass Jaw: a punch to the head (the top fifth of the body) kills it (RSQML_Service "punch.height", permille).
class RS_Row_GlassJaw : RS_ScoreBonus
{
	const MULT = 0.25;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Glass Jaw"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Rows.GloveKill(ev) && RS_Rows.Punch(ev, "punch.height") >= 800) ? MULT : 0.0; }
}

// M5 Textbook: the kill is the hook of jab, jab, hook inside one second ("punch.kinds" 112).
class RS_Row_Textbook : RS_ScoreBonus
{
	const MULT = 0.35;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Textbook"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Rows.GloveKill(ev) && RS_Rows.Punch(ev, "punch.kinds") == 112) ? MULT : 0.0; }
}

// M6 Triple Threat: the kill is the uppercut of jab, hook, uppercut inside one second (123). Replaces Shoryuken and Textbook.
class RS_Row_TripleThreat : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Triple Threat"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Rows.GloveKill(ev) && RS_Rows.Punch(ev, "punch.kinds") == 123) ? MULT : 0.0; }
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Row_Shoryuken" || other is "RS_Row_Textbook"; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// M7 Dempsey Roll: the kill ends a run of alternating hooks ("punch.run", this one included).
class RS_Row_DempseyRoll : RS_ScoreBonus
{
	const PER = 0.15;
	const MAXMULT = 0.6;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Dempsey Roll"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Rows.GloveKill(ev)) return 0.0;
		int run = RS_Rows.Punch(ev, "punch.run");
		return run >= 3 ? min(MAXMULT, PER * (run - 2)) : 0.0;
	}
}

// M8 Air Combo: a punch kills a monster your uppercut launched, while it is still in the air ("launch.age"). Replaces Juggle.
class RS_Row_AirCombo : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Air Combo"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Rows.GloveKill(ev) || !RS_Melee.Airborne(ev.victim)) return 0.0;
		return RS_Svc.Int(RS_Svc.MELEE, "launch.age", ev.killerNum, ev.victim) >= 0 ? MULT : 0.0;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_Juggle" || other is "RS_Bonus_Skeet"; }
}

// M12 Bouncer: the Clear Out palm thrust kills it.
class RS_Row_Bouncer : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Bouncer"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Tool(ev) == "clearout" ? MULT : 0.0; }
}

// M15 Release: the Guard's stored charge, let out, kills it.
class RS_Row_Release : RS_ScoreBonus
{
	const MULT = 0.4;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Release"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Tool(ev) == "guard.release" ? MULT : 0.0; }
}

// M23 Toss: a monster you threw out of the Headlock dies of its own landing (what it struck is Bowling's).
class RS_Row_Toss : RS_ScoreBonus
{
	const MULT = 0.35;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Toss"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Rows.Tool(ev) != "headlock.throw") return 0.0;
		return (!ev.inflictor || ev.inflictor == ev.victim) ? MULT : 0.0;
	}
}

// M24 Piledriver: the Headlock Slam kills it.
class RS_Row_Piledriver : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Piledriver"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Tool(ev) == "headlock.slam" ? MULT : 0.0; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// M26 Cut Loose: the Headlock Uppercut (launched out of the hold) kills it.
class RS_Row_CutLoose : RS_ScoreBonus
{
	const MULT = 0.4;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Cut Loose"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Tool(ev) == "headlock.launch" ? MULT : 0.0; }
}

// M27 Butt Stroke: the gun-butt shove itself kills it (Melee's shove, BD22 VR's butt strike, the pistol whip).
class RS_Row_ButtStroke : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Butt Stroke"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Melee.Kind(ev) == RS_Melee.MK_SHOVE ? MULT : 0.0; }
}

// M31 K.O.: Gun Bonsai VR's Finisher (the last hit of a chain on a staggered, low monster) kills (tag fist.finisher).
class RS_Row_KO : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "K.O."; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Kind(ev) == RS_Melee.MK_FIST && RS_Melee.Tagged(ev, "fist.finisher")) ? MULT : 0.0; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// M32 Shatter: a frozen monster is shattered to death (Gun Bonsai VR's tag).
class RS_Row_Shatter : RS_ScoreBonus
{
	const MULT = 0.4;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Shatter"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Melee.Tagged(ev, "shatter") ? MULT : 0.0; }
}

// M33 Live Wire: Shock Fist's arc kills (tag arc).
class RS_Row_LiveWire : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Live Wire"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Melee.Tagged(ev, "arc") ? MULT : 0.0; }
}

// M34 Blast Radius: Explosive Fist's blast kills (tag fist.explosive).
class RS_Row_BlastRadius : RS_ScoreBonus
{
	const MULT = 0.25;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Blast Radius"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Melee.Tagged(ev, "fist.explosive") ? MULT : 0.0; }
}

// ================================================================================ shared melee (sheet X)

// X10 Weapon Master: a run of kills with the same melee mod (fists, saber, ShieldSaw, whip), nothing else killing
// between, each within 10 s. M30 Rip and Tear is the fists' case.
class RS_Row_WeaponMaster : RS_ScoreBonus
{
	const PER = 0.1;
	const MAXMULT = 0.5;
	const WINDOW = 350;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Weapon Master"; }
	static String MeleeMod(RS_ScoreEvent ev)
	{
		if (!RS_Rows.MeleeKind(ev)) return "";
		String m = RS_Tool.ModOf(RS_Rows.Tool(ev));
		return (m == "melee" || m == "saber" || m == "shield" || m == "whip") ? m : "";
	}
	override double Evaluate(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		String m = MeleeMod(ev);
		if (!tr || m == "" || tr.wmMod != m || level.maptime - tr.wmTic > WINDOW) return 0.0;
		int n = tr.wmCount + 1;
		return n >= 3 ? min(MAXMULT, PER * (n - 2)) : 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr) return;
		String m = MeleeMod(ev);
		if (m == "" || m != tr.wmMod || level.maptime - tr.wmTic > WINDOW) { tr.wmMod = m; tr.wmCount = m == "" ? 0 : 1; }
		else tr.wmCount++;
		tr.wmTic = level.maptime;
	}
}

// X11 Giant Slayer: a melee kill on a monster of 400+ base (a Baron and up); 1.0 at 2000+ (a Cyberdemon).
class RS_Row_GiantSlayer : RS_ScoreBonus
{
	const MULT = 0.5;
	const BIG = 1.0;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Giant Slayer"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Rows.MeleeKind(ev)) return 0.0;
		if (ev.victimSpawnHealth >= 2000) return BIG;
		return ev.victimSpawnHealth >= 400 ? MULT : 0.0;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid >= BIG; }
}

// X13 Death from Above: a melee kill dropping onto it: you are at least a metre above its head and falling.
class RS_Row_DeathFromAbove : RS_ScoreBonus
{
	const MULT = 0.4;
	const OVER = 34.0;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Death from Above"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let k = ev.killer; let v = ev.victim;
		if (!k || !v || !RS_Rows.MeleeKind(ev)) return 0.0;
		return (k.vel.z < -1.0 && k.pos.z >= v.pos.z + v.height + OVER) ? MULT : 0.0;
	}
}

// X14 Juggler: a kill with one hand while your other weapon is still in flight (the saber or the disc thrown).
class RS_Row_Juggler : RS_ScoreBonus
{
	const MULT = 0.25;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Juggler"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut) return 0.0;
		let h = RS_ScoreShots.Get();
		if (!h) return 0.0;
		for (int k = 0; k < h.thrown.Size(); k++)
		{
			let t = h.thrown[k];
			if (t && t != ev.inflictor && t.target == ev.killer) return MULT;
		}
		return 0.0;
	}
}

// X15 Misdirection: a shot you sent back kills a monster that did NOT fire it. On Return to Sender.
class RS_Row_Misdirection : RS_ScoreBonus
{
	const MULT = 0.25;
	override int Family() const { return FAM_COUNTER; }
	override String DisplayName() const { return "Misdirection"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Melee.Returned(ev) || !ev.inflictor) return 0.0;
		Actor from = RS_ScoreShots.BornOf(ev.inflictor);
		if (!from) from = RS_Melee.AskShieldActor("returned.from", ev.inflictor);
		return (from && from != ev.victim) ? MULT : 0.0;
	}
}

// X12 Multi-Kill (and lane D's Pump Double, Two Barrels, Collateral, Skewer, Fan Fire, Tracer Count, lane B's Frag Out,
// Two Birds, lane A's Shockwave): one blow, blast or swing kills more than one. The same inflictor actor (a blast, a
// bolt, a push, a thrown thing) inside a second, or the same tool on the same tic. Each kill past the first pays by
// what did it; the grenade's crowd is a big moment from the fourth.
class RS_Row_MultiKill : RS_ScoreBonus
{
	const WINDOW = 35;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Multi-Kill"; }
	static double Per(RS_ScoreEvent ev, String tool)
	{
		String pre = RS_Tool.Prefix(tool);
		String g = RS_Rows.Gun(ev);
		if (pre == "grenade") return 0.2;
		if (tool == "gun.shotgun") return g ~== "SSG" ? 0.35 : 0.3;
		if (tool == "gun.rifle") return g ~== "Sniper" ? 0.5 : 0.15;
		if (tool == "gun.energy") return (g ~== "RailGun") ? 0.4 : (g.Left(3) ~== "BFG" || g ~== "BIG_FUCKING_GUN" || g ~== "BFG9000") ? 0.1 : 0.2;
		if (pre == "gun") return 0.15;
		if (tool == "force.push") return 0.2;
		if (tool == "grab.throw") return 0.3;
		if (tool == "gun.explosive") return 0.15;
		return RS_Tool.IsMelee(tool) ? 0.25 : 0.0;
	}
	static int Earlier(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr || tr.mkCount <= 0) return 0;
		String tool = RS_Rows.Tool(ev);
		if (tool == "" || tool != tr.mkTool) return 0;
		// the same THING (a blast, a bolt, a thrown body) inside a second; the pawn itself is every punch's inflictor, so
		// a blow dealt by the pawn counts only on the same tic
		bool sameInf = ev.inflictor && ev.inflictor != ev.killer && tr.mkInf == ev.inflictor && level.maptime - tr.mkTic <= WINDOW;
		bool sameTic = tr.mkTic == level.maptime;
		return (sameInf || sameTic) ? tr.mkCount : 0;
	}
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut) return 0.0;
		int n = Earlier(ev);
		if (n <= 0) return 0.0;
		String tool = RS_Rows.Tool(ev);
		double per = Per(ev, tool);
		double cap = RS_Tool.Prefix(tool) == "grenade" ? 1.0 : (tool == "gun.energy" && RS_Rows.Gun(ev) ~== "RailGun") ? 1.2 : 0.75;
		return min(cap, per * n);
	}
	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr || !ev.killer) return;
		int n = Earlier(ev);
		tr.mkCount = n + 1;
		tr.mkTool = RS_Rows.Tool(ev);
		tr.mkInf = ev.inflictor;
		tr.mkTic = level.maptime;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid >= 0.6 - 0.001; }
}

// ================================================================================ the saber

// S-2 Lunge: a stab driven by your whole body kills it (the saber's stab.lunge tag).
class RS_Row_Lunge : RS_ScoreBonus
{
	const MULT = 0.4;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Lunge"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Kind(ev) == RS_Melee.MK_SABER && RS_Melee.Tagged(ev, "stab.lunge")) ? MULT : 0.0; }
}

// S-3 Impaled: you draw the blade out of an impaled monster and it dies of it (the saber's impale tag).
class RS_Row_Impaled : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Impaled"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Kind(ev) == RS_Melee.MK_SABER && RS_Melee.Tagged(ev, "impale")) ? MULT : 0.0; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// S-13 Back Off: the X of your two blades (Cross Guard) turned a shot that kills. Replaces Return to Sender.
class RS_Row_BackOff : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_COUNTER; }
	override String DisplayName() const { return "Back Off"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Returned(ev) && RS_Melee.Tagged(ev, "crossguard")) ? MULT : 0.0; }
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_ReturnToSender"; }
}

// S-7 Double Throw: both sabers are thrown and each kills, within a second of each other.
class RS_Row_DoubleThrow : RS_ScoreBonus
{
	const MULT = 0.4;
	const WINDOW = 35;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Double Throw"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr || RS_Melee.Kind(ev) != RS_Melee.MK_THROWN || !ev.inflictor) return 0.0;
		return (tr.thrownKillInf && tr.thrownKillInf != ev.inflictor && level.maptime - tr.thrownKillTic <= WINDOW) ? MULT : 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr || RS_Melee.Kind(ev) != RS_Melee.MK_THROWN) return;
		tr.thrownKillInf = ev.inflictor;
		tr.thrownKillTic = level.maptime;
	}
}

// ================================================================================ the ShieldSaw

// D2 Shield Dash: the bash at the end of a Shield Dash kills it (tag dash.bash).
class RS_Row_ShieldDash : RS_ScoreBonus
{
	const MULT = 0.4;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Shield Dash"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Kind(ev) == RS_Melee.MK_BASH && RS_Melee.Tagged(ev, "dash.bash")) ? MULT : 0.0; }
}

// D4 Bit Off More: a monster clawing your revving shield is ground to death on it (tag rev.block).
class RS_Row_BitOffMore : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Bit Off More"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Kind(ev) == RS_Melee.MK_GRIND && RS_Rows.ChainTag(ev, "rev.block")) ? MULT : 0.0; }
}

// D5 Homecoming: the disc (or the saber) kills on its way home without having killed on the way out. Boomerang
// replaces it when there was an out kill.
class RS_Row_Homecoming : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Homecoming"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		int k = RS_Melee.Kind(ev);
		if (k != RS_Melee.MK_DISC && k != RS_Melee.MK_THROWN) return 0.0;
		if (RS_Melee.ThrownLeg(ev.inflictor, ev.killer) != RS_Melee.LEG_BACK) return 0.0;
		return RS_ScoreShots.ThrowKilledOut(ev.inflictor) ? 0.0 : MULT;
	}
}

// D8 Eyes in the Back: the shield on your back blocked that monster's attack, then you killed it within 3 s (tag backplate).
class RS_Row_EyesInTheBack : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_COUNTER; }
	override String DisplayName() const { return "Eyes in the Back"; }
	override double Evaluate(RS_ScoreEvent ev) { return (ev.killer && RS_Rows.ChainTag(ev, "backplate")) ? MULT : 0.0; }
}

// D9 Hold the Line: Shield Wall, but the shield turned away blows from 2 or more different monsters in the last 2 s.
class RS_Row_HoldTheLine : RS_ScoreBonus
{
	const MULT = 0.25;
	const PER = 0.1;
	const MAXMULT = 0.55;
	const WINDOW = 70;
	const REACH = 2048;
	override int Family() const { return FAM_COUNTER; }
	override String DisplayName() const { return "Hold the Line"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let k = ev.killer;
		if (!k || ev.ringOut || !RS_Melee.ShieldInHand(k)) return 0.0;
		int n = 0;
		let it = BlockThingsIterator.Create(k, REACH);
		while (it.Next())
		{
			let m = it.thing;
			if (!m || m == ev.victim || !m.bIsMonster || m.player) continue;
			int since = RS_Melee.AskShield("blocked", m);
			if (since >= 0 && since <= WINDOW) n++;
		}
		return n >= 2 ? min(MAXMULT, MULT + PER * (n - 2)) : 0.0;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_ShieldWall"; }
}

// D12 Cleaver: the disc cut it in two only because of the Cleaver node (tag cleave.saw). Stacks on Cleaved.
class RS_Row_Cleaver : RS_ScoreBonus
{
	const MULT = 0.2;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Cleaver"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Kind(ev) == RS_Melee.MK_DISC && RS_Melee.Gibbed(ev.victim) && RS_Melee.Tagged(ev, "cleave.saw")) ? MULT : 0.0; }
}

// ================================================================================ the whip

// W2 Wrecking Ball: the monster you swing on the whip smashes into another and kills it.
class RS_Row_WreckingBall : RS_ScoreBonus
{
	const MULT = 0.4;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Wrecking Ball"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Rows.Tool(ev) != "whip.flail") return 0.0;
		return (ev.inflictor && ev.inflictor != ev.victim && ev.inflictor.bIsMonster) ? MULT : 0.0;
	}
}

// W10 Tarzan: you swing in on the rope and your arrival kills it. Replaces Swinging.
class RS_Row_Tarzan : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Tarzan"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Tool(ev) == "whip.tarzan" ? MULT : 0.0; }
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_Swinging"; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// W12 Stun Lock: a crack held the monster in pain (the Stun node's crack.stun tag) and a different tool killed it.
class RS_Row_StunLock : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Stun Lock"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Tool.Prefix(RS_Rows.Tool(ev)) == "whip") return 0.0;
		return (RS_Rows.ChainHas(ev, "whip") && RS_Rows.ChainTag(ev, "crack.stun")) ? MULT : 0.0;
	}
}

// W14 Heavy Haul: you yanked a heavy monster off its feet (the Heavy Yank's tag) and it died within 2 s.
class RS_Row_HeavyHaul : RS_ScoreBonus
{
	const MULT = 0.35;
	const WINDOW = 70;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Heavy Haul"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut) return 0.0;
		int t = RS_Whip.Ask("yanked", ev.victim);
		return (t >= 0 && t <= WINDOW && RS_Rows.ChainTag(ev, "yank.heavy")) ? MULT : 0.0;
	}
}

// W15 Snap Kill: a crack finishes a monster you marked from across the room (the marked crack), from 6 m or more.
class RS_Row_SnapKill : RS_ScoreBonus
{
	const MULT = 0.3;
	const FAR = 204.0;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Snap Kill"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Kind(ev) == RS_Melee.MK_WHIP && RS_Melee.Tagged(ev, "crack.marked") && ev.edgeDistance >= FAR) ? MULT : 0.0; }
}

// ================================================================================ the hook

// G1 Hooked Keg: killed by the blast of a barrel your hook bit. Each further kill by hooked barrels within 3 s pays more.
class RS_Row_HookedKeg : RS_ScoreBonus
{
	const MULT = 0.4;
	const PER = 0.2;
	const MAXMULT = 1.2;
	const WINDOW = 105;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Hooked Keg"; }
	private int Earlier(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		return (tr && tr.hkCount > 0 && level.maptime - tr.hkTic <= WINDOW) ? tr.hkCount : 0;
	}
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Tool(ev) == "hook.keg" ? min(MAXMULT, MULT + PER * Earlier(ev)) : 0.0; }
	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr || RS_Rows.Tool(ev) != "hook.keg") return;
		tr.hkCount = Earlier(ev) + 1;
		tr.hkTic = level.maptime;
	}
}

// G3 Boarding Party: you reeled yourself to a monster too heavy to come (the hook latched as an anchor) and killed it
// in melee within 2 s of arriving.
class RS_Row_BoardingParty : RS_ScoreBonus
{
	const MULT = 0.6;
	const WINDOW = 70;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Boarding Party"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Rows.MeleeKind(ev)) return 0.0;
		int t = RS_Grapple.Ask("hooked", ev.victim);
		if (t < 0 || t > WINDOW || RS_Grapple.Ask("hooked.by", ev.victim) != ev.killerNum) return 0.0;
		return RS_Grapple.Ask("hooked.heavy", ev.victim) == 1 ? MULT : 0.0;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_ReeledIn"; }
}

// G4 Zip Kick: arriving on a monster by rope at speed killed it.
class RS_Row_ZipKick : RS_ScoreBonus
{
	const MULT = 0.35;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Zip Kick"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Tool(ev) == "hook.zip" ? MULT : 0.0; }
}

// G7 Scorpion: Gun Bonsai VR's automatic counterpunch killed what the hook brought (tag scorpion). Replaces Counter.
class RS_Row_Scorpion : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Scorpion"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Kind(ev) == RS_Melee.MK_FIST && RS_Melee.Tagged(ev, "scorpion")) ? MULT : 0.0; }
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_Counter"; }
}

// ================================================================================ Distance Grab, the rig

// D7 Heavy Throw: a thrown thing of 100 kg or more killed (Distance Grab's "throw.kg"). On Thrown.
class RS_Row_HeavyThrow : RS_ScoreBonus
{
	const MULT = 0.15;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Heavy Throw"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Physical.ThrownBy(ev)) return 0.0;
		return RS_Physical.AskGrab("throw.kg", ev.inflictor) >= 100 ? MULT : 0.0;
	}
}

// T6 Throwaway: a gun you threw (the rig's flight, or a floor gun thrown with Distance Grab) kills; +0.2 thrown empty.
class RS_Row_Throwaway : RS_ScoreBonus
{
	const MULT = 0.3;
	const EMPTY = 0.2;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Throwaway"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Rows.Tool(ev) != "throw.gun") return 0.0;
		return MULT + (RS_Melee.Tagged(ev, "empty") ? EMPTY : 0.0);
	}
}

// T4 Iaido: draw the saber from its spot and kill with it inside the draw window.
class RS_Row_Iaido : RS_ScoreBonus
{
	const MULT = 0.45;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Iaido"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let k = ev.killer;
		if (!k || !k.player || RS_Melee.Kind(ev) != RS_Melee.MK_SABER) return 0.0;
		for (int h = 0; h < 2; h++)
		{
			int t = RS_Physical.AskRig("rig.drawtic", k, h);
			if (t < 0 || level.maptime - t > RS_Bonus_QuickDraw.WINDOW) continue;
			Weapon w = h ? k.player.OffhandWeapon : k.player.ReadyWeapon;
			if (w && w.GetClassName() == RS_Physical.AskRigString("rig.drawn", k, h)) return MULT;
		}
		return 0.0;
	}
}

// T8 Pin Pulled: the grenade drawn from the belt buckle kills within 3 s of the draw.
class RS_Row_PinPulled : RS_ScoreBonus
{
	const MULT = 0.3;
	const WINDOW = 105;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Pin Pulled"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let k = ev.killer;
		if (!k || RS_Melee.Kind(ev) != RS_Melee.MK_GRENADE) return 0.0;
		for (int h = 0; h < 2; h++)
		{
			int t = RS_Physical.AskRig("rig.drawtic", k, h);
			if (t < 0 || level.maptime - t > WINDOW) continue;
			String d = RS_Physical.AskRigString("rig.drawn", k, h);
			if (d.IndexOf("Grenade") >= 0 || d.IndexOf("grenade") >= 0) return MULT;
		}
		return 0.0;
	}
}

// T5 Armory: three different guns, each drawn from a holster and each killing, inside 6 s.
class RS_Row_Armory : RS_ScoreBonus
{
	const MULT = 0.5;
	const WINDOW = 210;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Armory"; }
	// the gun this kill was a draw's (Quick Draw's own test), or ""
	static String DrawnGun(RS_ScoreEvent ev)
	{
		let k = ev.killer;
		int kind = RS_Physical.ShotKind(ev);
		if (!k || !k.player || kind == RS_Physical.SHOT_NONE) return "";
		Weapon w; int hand;
		[w, hand] = RS_Physical.KillingGun(ev, kind);
		if (!w) return "";
		int t = RS_Physical.AskRig("rig.drawtic", k, hand);
		if (t < 0 || level.maptime - t > RS_Bonus_QuickDraw.WINDOW) return "";
		String s = "";
		if (w.GetClassName() == RS_Physical.AskRigString("rig.drawn", k, hand)) s = w.GetClassName();
		return s;
	}
	override double Evaluate(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		String g = DrawnGun(ev);
		if (!tr || g == "") return 0.0;
		int n = 1;
		for (int k = 0; k < tr.armWep.Size(); k++) if (level.maptime - tr.armTic[k] <= WINDOW && tr.armWep[k] != g) n++;
		return n >= 3 ? MULT : 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		String g = DrawnGun(ev);
		if (!tr || g == "") return;
		for (int k = tr.armWep.Size() - 1; k >= 0; k--) if (level.maptime - tr.armTic[k] > WINDOW || tr.armWep[k] == g) { tr.armWep.Delete(k); tr.armTic.Delete(k); }
		tr.armWep.Push(g); tr.armTic.Push(level.maptime);
	}
}

// ================================================================================ the grenade

// N2 Cooked: killed by a grenade cooked in the hand (RSQ Grenade's "cooked", tics). More the longer it cooked.
class RS_Row_Cooked : RS_ScoreBonus
{
	const MULT = 0.2;
	const PER_HALF = 0.1;
	const MAXMULT = 0.6;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Cooked"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Melee.Kind(ev) != RS_Melee.MK_GRENADE || !ev.inflictor) return 0.0;
		int c = RS_Svc.Int(RS_Svc.GRENADE, "cooked", 0, ev.inflictor);
		if (c < 35) return 0.0;
		return min(MAXMULT, MULT + PER_HALF * ((c - 35) / 17));
	}
}

// N3 Airburst: the grenade went off in the air, not on the floor.
class RS_Row_Airburst : RS_ScoreBonus
{
	const MULT = 0.35;
	const UP = 24.0;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Airburst"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let inf = ev.inflictor;
		if (RS_Melee.Kind(ev) != RS_Melee.MK_GRENADE || !inf || RS_Rows.Infl(ev) ~== "RSQGN_HandBlast") return 0.0;
		return inf.pos.z - inf.floorz >= UP ? MULT : 0.0;
	}
}

// N5 Tagged: a Sticky grenade riding a monster killed THAT monster (the sticky's touch, then its own blast, on one body).
class RS_Row_Tagged : RS_ScoreBonus
{
	const MULT = 0.35;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Tagged"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Rows.Tool(ev) == "grenade.frag" && RS_Rows.ChainHas(ev, "grenade.sticky")) ? MULT : 0.0; }
}

// N10 Hold My Beer: a grenade that went off IN YOUR HAND killed a monster. More if you live through it.
class RS_Row_HoldMyBeer : RS_ScoreBonus
{
	const MULT = 0.5;
	const ALIVE = 0.8;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Hold My Beer"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!(RS_Rows.Infl(ev) ~== "RSQGN_HandBlast")) return 0.0;
		return ev.killerHealth > 0 ? ALIVE : MULT;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// N11 Cluster Bomb: a Cluster bomblet killed it.
class RS_Row_ClusterBomb : RS_ScoreBonus
{
	const MULT = 0.25;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Cluster Bomb"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Tool(ev) == "grenade.cluster" ? MULT : 0.0; }
}

// N12 Ice Breaker: a monster frozen by your Freeze grenade shattered and died, by any tool. Replaces Shatter.
class RS_Row_IceBreaker : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Ice Breaker"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Tagged(ev, "shatter") && RS_Rows.ChainHas(ev, "grenade.freeze")) ? MULT : 0.0; }
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Row_Shatter"; }
}

// N13 / N14 Civil War: a monster your Infight or Charm grenade turned killed another: paid to you (handler.zs).
class RS_Row_CivilWar : RS_ScoreBonus
{
	const MULT = 0.4;
	override int Family() const { return FAM_EFFICIENCY; }
	override String DisplayName() const { return "Civil War"; }
	override double Evaluate(RS_ScoreEvent ev) { return ev.turncoat ? MULT : 0.0; }
}

// N15 Blindside: killed while blinded by your Flash or Smoke grenade (it lost you).
class RS_Row_Blindside : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Blindside"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut) return 0.0;
		return (RS_Rows.ChainHas(ev, "grenade.flash") || RS_Rows.ChainHas(ev, "grenade.smoke")) ? MULT : 0.0;
	}
}

// N16 Barbecue: your Incendiary's fire finished it.
class RS_Row_Barbecue : RS_ScoreBonus
{
	const MULT = 0.25;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Barbecue"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Tool(ev) == "grenade.fire" ? MULT : 0.0; }
}

// ================================================================================ the guns (BD22 VR's classes)

// Lane D's hold streaks (Street Sweeper, Beltfed, Bullet Hose, Green Rain, Firestarter: one mechanism): kills while
// one trigger stays down. The third kill of a hold pays, more each after.
class RS_Row_HoldStreak : RS_ScoreBonus
{
	const PER = 0.15;
	const MAXMULT = 0.6;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Hold Streak"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		int kind = RS_Physical.ShotKind(ev);
		if (!tr || kind == RS_Physical.SHOT_NONE) return 0.0;
		int h = RS_Physical.ShotHand(ev, kind) == 2 ? 1 : 0;
		if (tr.holdStart[h] <= 0) return 0.0;
		int n = tr.holdKills[h] + 1;
		return n >= 3 ? min(MAXMULT, PER * (n - 2)) : 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		int kind = RS_Physical.ShotKind(ev);
		if (!tr || kind == RS_Physical.SHOT_NONE) return;
		int h = RS_Physical.ShotHand(ev, kind) == 2 ? 1 : 0;
		if (tr.holdStart[h] > 0) tr.holdKills[h]++;
	}
}

// D Double Tap: two pistol hits on one monster within 10 tics, the second kills (the ledger's run of gun.pistol).
class RS_Row_DoubleTap : RS_ScoreBonus
{
	const MULT = 0.2;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Double Tap"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Rows.Tool(ev) != "gun.pistol") return 0.0;
		RS_Combo.ChainOf(ev);
		let led = RS_ComboLedger.Get();
		int n = ev.chainIdx.Size();
		if (!led || n < 1) return 0.0;
		int k = ev.chainIdx[n - 1];
		return (led.HitsAt(k) >= 2 && led.SpanAt(k) <= 10) ? MULT : 0.0;
	}
}

// D Hand Cannon / Magnum Slug: one revolver round takes a monster from full to dead (BD22's BrutalRevolver, the Moonlight;
// the Shotvolver's slug pays more).
class RS_Row_HandCannon : RS_ScoreBonus
{
	const MULT = 0.25;
	const SLUG = 0.3;
	override int Family() const { return FAM_EFFICIENCY; }
	override String DisplayName() const { return "Hand Cannon"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Rows.Tool(ev) != "gun.pistol" || !RS_Rows.OneBlow(ev)) return 0.0;
		String g = RS_Rows.Gun(ev);
		if (g ~== "BrutalRevolver") return MULT;
		if (g ~== "Revolver") return SLUG;
		return 0.0;
	}
}

// D Headshot: the killing blow was a headshot (its damage type, BD22's Head / MinorHead: the ledger's +head). The
// Ruger and the Moonlight pay more. UNMEASURED: the damage type names are lane D's reading of the pack.
class RS_Row_Headshot : RS_ScoreBonus
{
	const MULT = 0.25;
	const SHARP = 0.4;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Headshot"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		RS_Combo.ChainOf(ev);
		let led = RS_ComboLedger.Get();
		int n = ev.chainIdx.Size();
		if (!led || n < 1 || !(led.CondAt(ev.chainIdx[n - 1]) & RS_ComboLedger.C_HEAD)) return 0.0;
		String g = RS_Rows.Gun(ev);
		return (g ~== "Sniper" || g ~== "BrutalRevolver") ? SHARP : MULT;
	}
}

// D Sights Up / Glass: a gun kill from far with the shot's line within 2 degrees of the head's facing (aimed down the
// gun, not from the hip): 768 units pays Sights Up; the Ruger or the Railgun at 1024 pays Glass (0.6 at 2048).
class RS_Row_SightsUp : RS_ScoreBonus
{
	const MULT = 0.2;
	const GLASS = 0.4;
	const GLASS_FAR = 0.6;
	const ANGLE = 2.0;
	override int Family() const { return FAM_DARING; }
	override int RowCount() const { return 2; }
	override String RowName(int i) const { return i == 0 ? "Sights Up" : "Glass"; }
	bool lastGlass;
	override double RowShare(int i) const { return (i == 1) == lastGlass ? 1.0 : 0.0; }
	override String DisplayName() const { return "Sights Up"; }
	override String DebugName() const { return lastGlass ? "Glass" : "Sights Up"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		lastGlass = false;
		int kind = RS_Physical.ShotKind(ev);
		if (kind == RS_Physical.SHOT_NONE || ev.edgeDistance < 768) return 0.0;
		if (RS_Rows.OffHead(ev, kind) > ANGLE) return 0.0;
		String g = RS_Rows.Gun(ev);
		if ((g ~== "Sniper" || g ~== "RailGun") && ev.edgeDistance >= 1024)
		{
			lastGlass = true;
			return ev.edgeDistance >= 2048 ? GLASS_FAR : GLASS;
		}
		return MULT;
	}
}

// D Direct Hit: a rocket's impact killed it, not the splash.
class RS_Row_DirectHit : RS_ScoreBonus
{
	const MULT = 0.2;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Direct Hit"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!(RS_Rows.Infl(ev).Left(6) ~== "Rocket")) return 0.0;
		return RS_Physical.Splash(ev) == 0 ? MULT : 0.0;
	}
}

// D Danger Close: a nuke kill while you stood within 768 units of it and lived.
class RS_Row_DangerClose : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Danger Close"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		String icn = RS_Rows.Infl(ev);
		if (!(icn.Left(7) ~== "Nuclear" || icn ~== "SpawnedExplosionNuke" || ev.damageType == 'Nuke')) return 0.0;
		return (ev.killerHealth > 0 && ev.edgeDistance <= 768) ? MULT : 0.0;
	}
}

// D Unmade: an Unmaker kill of a monster of 1000 spawn health or more.
class RS_Row_Unmade : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Unmade"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Rows.Infl(ev).Left(7) ~== "Unmaker" && ev.victimSpawnHealth >= 1000) ? MULT : 0.0; }
}

// D Rip and Tear: a chainsaw kill of a monster of 400 spawn health or more; a big moment at 1000.
class RS_Row_RipAndTear : RS_ScoreBonus
{
	const MULT = 0.5;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Rip and Tear"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Rows.Tool(ev) == "blade.saw" && ev.victimSpawnHealth >= 400) ? MULT : 0.0; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0 && ev.victimSpawnHealth >= 1000; }
}

// D Tomahawk: a thrown axe kills.
class RS_Row_Tomahawk : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Tomahawk"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Infl(ev).Left(10) ~== "ThrowedAxe" ? MULT : 0.0; }
}

// ================================================================================ Champions, LegenDoom, Miniboss

// C17 Immovable Object: melee-kill a Bronze champion.
class RS_Row_ImmovableObject : RS_ScoreBonus
{
	const MULT = 0.4;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Immovable Object"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Rows.MeleeKind(ev) && RS_Boost.ChampActive(ev.victim) && RS_Boost.Has(ev.victim, "champion_BronzeToken")) ? MULT : 0.0; }
}

// C20 Pop!: kill a Balloon champion with anything but a gun.
class RS_Row_Pop : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Pop!"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut || !RS_Boost.ChampActive(ev.victim) || !RS_Boost.Has(ev.victim, "champion_BalloonToken")) return 0.0;
		return RS_Physical.ShotKind(ev) == RS_Physical.SHOT_NONE ? MULT : 0.0;
	}
}

// C25 Pinata: gib a champion.
class RS_Row_Pinata : RS_ScoreBonus
{
	const MULT = 0.25;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Pinata"; }
	override double Evaluate(RS_ScoreEvent ev) { return (ev.killer && RS_Boost.ChampActive(ev.victim) && RS_Melee.Gibbed(ev.victim)) ? MULT : 0.0; }
}

// C28 Champion Streak: champion kills back to back, each within 5 s of the last.
class RS_Row_ChampionStreak : RS_ScoreBonus
{
	const PER = 0.1;
	const MAXMULT = 0.5;
	const WINDOW = 175;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Champion Streak"; }
	private int Earlier(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		return (tr && tr.champCount > 0 && level.maptime - tr.champTic <= WINDOW) ? tr.champCount : 0;
	}
	override double Evaluate(RS_ScoreEvent ev) { return (ev.killer && RS_Boost.ChampActive(ev.victim)) ? min(MAXMULT, PER * Earlier(ev)) : 0.0; }
	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr || !ev.killer || !RS_Boost.ChampActive(ev.victim)) return;
		tr.champCount = Earlier(ev) + 1;
		tr.champTic = level.maptime;
	}
}

// C5 Too Close for Comfort: kill an Orange champion with a melee blow or at point-blank (its death blast is on you).
class RS_Row_TooClose : RS_ScoreBonus
{
	const MULT = 0.35;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Too Close for Comfort"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !RS_Boost.ChampActive(ev.victim) || !RS_Boost.Has(ev.victim, "champion_OrangeToken")) return 0.0;
		return (RS_Rows.MeleeKind(ev) || ev.edgeDistance < RS_Bonus_PointBlank.DIST) ? MULT : 0.0;
	}
}

// C12 Glass Cannon: kill a Black champion in one blow from full health.
class RS_Row_GlassCannon : RS_ScoreBonus
{
	const MULT = 0.35;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Glass Cannon"; }
	override double Evaluate(RS_ScoreEvent ev) { return (ev.killer && RS_Boost.ChampActive(ev.victim) && RS_Boost.Has(ev.victim, "champion_BlackToken") && RS_Rows.OneBlow(ev)) ? MULT : 0.0; }
}

// C19 Fool's Gold: kill a monster a Gold champion gilded (it wears the Gold token and is no champion itself).
class RS_Row_FoolsGold : RS_ScoreBonus
{
	const MULT = 0.2;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Fool's Gold"; }
	override double Evaluate(RS_ScoreEvent ev) { return (ev.killer && !RS_Boost.Champion(ev.victim) && RS_Boost.Has(ev.victim, "champion_GoldToken")) ? MULT : 0.0; }
}

// C22 Heartbreaker: kill an Undying champion within 2 s of killing its heart (the handler's 'undying' mark).
class RS_Row_Heartbreaker : RS_ScoreBonus
{
	const MULT = 0.35;
	const WINDOW = 70;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Heartbreaker"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let h = RS_ScoreHandler.Get();
		if (!ev.killer || !h) return 0.0;
		int t = h.MarkedSince(ev.victim, 'undying');
		return (t >= 0 && t <= WINDOW) ? MULT : 0.0;
	}
}

// C extra Champion Fatality: Brutal Doom's Fatality on an active champion. On Fatality.
class RS_Row_ChampionFatality : RS_ScoreBonus
{
	const MULT = 0.25;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Champion Fatality"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Kind(ev) == RS_Melee.MK_FINISH && RS_Boost.ChampActive(ev.victim)) ? MULT : 0.0; }
}

// C29 Rainbow: kill champions of 5, 10 and all 14 colours in one map (paid once each, on the kill that completes it).
class RS_Row_Rainbow : RS_ScoreBonus
{
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Rainbow"; }
	static int ColourBit(Actor v)
	{
		static const String colours[] = { "DarkRed", "Red", "Orange", "Yellow", "DarkGreen", "Green", "Cyan", "Blue", "Indigo", "Violet", "Pink", "Black", "Grey", "White" };
		if (!v || !RS_Boost.ChampActive(v)) return 0;
		for (int i = 0; i < colours.Size(); i++) if (RS_Boost.Has(v, "champion_" .. colours[i] .. "Token")) return 1 << i;
		return 0;
	}
	static int Count(int m) { int n = 0; for (int b = 0; b < 14; b++) if (m & (1 << b)) n++; return n; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		int bit = ColourBit(ev.victim);
		if (!tr || !ev.killer || bit == 0 || (tr.colourMask & bit)) return 0.0;
		int n = Count(tr.colourMask | bit);
		if (n >= 14 && !(tr.rainbowPaid & 4)) return 2.0;
		if (n >= 10 && !(tr.rainbowPaid & 2)) return 1.0;
		if (n >= 5 && !(tr.rainbowPaid & 1)) return 0.5;
		return 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		int bit = ColourBit(ev.victim);
		if (!tr || !ev.killer || bit == 0) return;
		tr.colourMask |= bit;
		int n = Count(tr.colourMask);
		if (n >= 5) tr.rainbowPaid |= 1;
		if (n >= 10) tr.rainbowPaid |= 2;
		if (n >= 14) tr.rainbowPaid |= 4;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid >= 1.0; }
}

// C34 One-Tap Legend: kill a legendary from its full 300 % in a single blow. Replaces Legend Denied.
class RS_Row_OneTapLegend : RS_ScoreBonus
{
	const MULT = 1.0;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "One-Tap Legend"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || !RS_Boost.Legendary(ev.victim) || ev.healthBefore < 0) return 0.0;
		return ev.healthBefore >= ev.victimSpawnHealth * 3 - 1 ? MULT : 0.0;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_LegendDenied"; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// C31 Strike While It Rises: kill a legendary within 2 s of it rising (the handler's 'risen' mark).
class RS_Row_StrikeWhileItRises : RS_ScoreBonus
{
	const MULT = 0.5;
	const WINDOW = 70;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Strike While It Rises"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let h = RS_ScoreHandler.Get();
		if (!ev.killer || !h || !RS_Boost.Transformed(ev.victim)) return 0.0;
		int t = h.MarkedSince(ev.victim, 'risen');
		return (t >= 0 && t <= WINDOW) ? MULT : 0.0;
	}
}

// C35 Legend Slayer: two legendaries killed within 10 s.
class RS_Row_LegendSlayer : RS_ScoreBonus
{
	const MULT = 0.5;
	const WINDOW = 350;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Legend Slayer"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr || !ev.killer || !RS_Boost.Legendary(ev.victim)) return 0.0;
		return (tr.legendTic > 0 && level.maptime - tr.legendTic <= WINDOW) ? MULT : 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (tr && ev.killer && RS_Boost.Legendary(ev.victim)) tr.legendTic = level.maptime;
	}
}

// M1 Chain Gang: thralls killed one after another inside one slow window; each one pays more (the first is Miniboss's
// own Thrall Slow Kill, converted to a share of the base in handler.zs).
class RS_Row_ChainGang : RS_ScoreBonus
{
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Chain Gang"; }
	static bool Thrall(RS_ScoreEvent ev) { return ev.killer && RS_Boost.Has(ev.victim, "RSQMB_Thrall") && RS_Rows.Miniboss("window", null) > 0; }
	private int Earlier(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		int win = RS_Rows.Miniboss("window", null);
		return (tr && tr.cgCount > 0 && win > 0 && level.maptime - tr.cgTic <= 35 * 12) ? tr.cgCount : 0;
	}
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!Thrall(ev)) return 0.0;
		int n = Earlier(ev) + 1;
		if (n == 2) return 0.4;
		if (n == 3) return 0.8;
		return n > 3 ? 1.0 : 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr) return;
		if (ev.killer && RS_Boost.Has(ev.victim, "RSQMB_Thrall")) tr.thrallTic = level.maptime;
		if (!Thrall(ev)) return;
		tr.cgCount = Earlier(ev) + 1;
		tr.cgTic = level.maptime;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid >= 1.0; }
}

// M7 Rage Quit: kill the miniboss while its rage runs (every monster twice as fast).
class RS_Row_RageQuit : RS_ScoreBonus
{
	const MULT = 0.75;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Rage Quit"; }
	override double Evaluate(RS_ScoreEvent ev) { return (ev.killer && RS_Boost.Has(ev.victim, "RSQMB_Ward") && RS_Rows.Miniboss("enraged", null) == 1) ? MULT : 0.0; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// M8 Riot Control: kill an enraged monster.
class RS_Row_RiotControl : RS_ScoreBonus
{
	const MULT = 0.15;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Riot Control"; }
	override double Evaluate(RS_ScoreEvent ev) { return (ev.killer && RS_Boost.Has(ev.victim, "RSQMB_Rage")) ? MULT : 0.0; }
}

// M2 Severed: kill the miniboss within 1 s of its last thrall dying (its shield just dropped to nothing).
class RS_Row_Severed : RS_ScoreBonus
{
	const MULT = 0.5;
	const WINDOW = 35;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Severed"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let tr = ev.tracker;
		if (!tr || !ev.killer || !RS_Boost.Has(ev.victim, "RSQMB_Ward")) return 0.0;
		return (tr.thrallTic > 0 && level.maptime - tr.thrallTic <= WINDOW) ? MULT : 0.0;
	}
}

// ================================================================================ the second round (11-03 evening)

// S-1 Run Through: a stab kills it (the saber names every stab, saber.stab). Lunge pays the lunging one instead.
class RS_Row_RunThrough : RS_ScoreBonus
{
	const MULT = 0.25;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Run Through"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Tool(ev) == "saber.stab" ? MULT : 0.0; }
}

// S-6 Saberstaff: the staff's back blade or its spin kills it (saber.spin); more bodies in one spin are Multi-Kill's.
class RS_Row_Saberstaff : RS_ScoreBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Saberstaff"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Tool(ev) == "saber.spin" ? MULT : 0.0; }
}

// S-11 Unlimited Power: Force Lightning kills it (force.lightning, every struck monster); the chain's extra bodies are Multi-Kill's.
class RS_Row_UnlimitedPower : RS_ScoreBonus
{
	const MULT = 0.35;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Unlimited Power"; }
	override double Evaluate(RS_ScoreEvent ev) { return RS_Rows.Tool(ev) == "force.lightning" ? MULT : 0.0; }
}

// S-14 Clash Break: a monster staggered by your blade-lock shockwave (the saber's clash tag) is killed within 3 s.
class RS_Row_ClashBreak : RS_ScoreBonus
{
	const MULT = 0.35;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Clash Break"; }
	override double Evaluate(RS_ScoreEvent ev) { return (ev.killer && RS_Rows.ChainTag(ev, "clash")) ? MULT : 0.0; }
}

// D10 Buzzsaw: a grind kill on something that took at least 1.5 s of grinding in the hand (the ShieldSaw's "grind.held").
// Replaces Shield Work's grind pay.
class RS_Row_Buzzsaw : RS_ScoreBonus
{
	const MULT = 0.3;
	const HELD = 52;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Buzzsaw"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Melee.Kind(ev) != RS_Melee.MK_GRIND) return 0.0;
		return RS_Melee.AskShield("grind.held", ev.victim) >= HELD ? MULT : 0.0;
	}
	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_ShieldWork"; }
}

// X2 Wall Splat: a monster you knocked into a wall dies of the wall: a punch (Melee's wall tag) or a shield bash (the
// ShieldSaw's shield.slam blow). A big moment when the wall kills a monster of 400+ base.
class RS_Row_WallSplat : RS_ScoreBonus
{
	const MULT = 0.4;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Wall Splat"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer) return 0.0;
		return (RS_Melee.Tagged(ev, "wall") || RS_Rows.Tool(ev) == "shield.slam") ? MULT : 0.0;
	}
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0 && ev.victimSpawnHealth >= 400; }
}

// B D1 Clubbed: a thing you were HOLDING, swung into a monster, killed it (Distance Grab names it, grab.swing); a corpse more.
class RS_Row_Clubbed : RS_ScoreBonus
{
	const MULT = 0.3;
	const CORPSE = 0.1;
	override int Family() const { return FAM_MELEE; }
	override String DisplayName() const { return "Clubbed"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Rows.Tool(ev) != "grab.swing") return 0.0;
		let inf = ev.inflictor;
		return MULT + ((inf && inf.bIsMonster && inf.health <= 0) ? CORPSE : 0.0);
	}
}

// N4 Trap Shot: your grenade, shot by you in the air, killed (the grenade's skeet fact).
class RS_Row_TrapShot : RS_ScoreBonus
{
	const MULT = 0.6;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Trap Shot"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Kind(ev) == RS_Melee.MK_GRENADE && RS_Melee.Tagged(ev, "skeet")) ? MULT : 0.0; }
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// N17 Teeth: a grenade whose pin you pulled with your teeth killed.
class RS_Row_Teeth : RS_ScoreBonus
{
	const MULT = 0.15;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Teeth"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Kind(ev) == RS_Melee.MK_GRENADE && RS_Melee.Tagged(ev, "teeth")) ? MULT : 0.0; }
}

// N7 Contact: an Impact grenade burst on what it touched and killed it.
class RS_Row_Contact : RS_ScoreBonus
{
	const MULT = 0.4;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Contact"; }
	override double Evaluate(RS_ScoreEvent ev) { return (RS_Melee.Kind(ev) == RS_Melee.MK_GRENADE && RS_Melee.Tagged(ev, "impact")) ? MULT : 0.0; }
}

// Chain Swing (the Whip's aimed swing, sheet bn_w_swing3): a kill while the second or later of swings latched one
// after another carries you (the Whip's "swings"). On Swinging.
class RS_Row_ChainSwing : RS_ScoreBonus
{
	const PER = 0.2;
	const MAXMULT = 0.8;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Chain Swing"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut || RS_Whip.Ask("swinging", ev.killer) != 1) return 0.0;
		int n = RS_Whip.Ask("swings", ev.killer);
		return n >= 2 ? min(MAXMULT, PER * (n - 1)) : 0.0;
	}
}

// ================================================================================ slow motion

// S5 Last Grain: a kill in the ease-out, as the world speeds back up (SlowMo still active, nothing asking any more).
class RS_Row_LastGrain : RS_ScoreBonus
{
	const MULT = 0.2;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Last Grain"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!ev.killer || ev.ringOut) return 0.0;
		return (RS_Physical.AskSlowMo("active") == 1 && RS_Physical.AskSlowMo("running") == 0) ? MULT : 0.0;
	}
}
