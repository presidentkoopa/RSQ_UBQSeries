// ============================================================================
// RS_PlusEX.zs -- Colourful Hell Plus R3.0.1's NEW boss bodies, shared helpers.
// (Owner 2026-11-16 09:21, "get people on the EX bosses".)
//
// Source (read-only): Enemies_ColourfulHell_Plus_R3.0.1.pk3 (CHP), its decorate/<family>/<family>_<colour> files and
// source/*.acs. Every class in plus/*.zs cites its CHP file and line. Only the COMMON subtier of each body is
// ported (CHP layers a second "subtier" colour on every body: its other 14 copies, the 15x15 grid, CHP's spawn
// system and presets, and its player-side options are NOT ported; the owner is deciding how a second colour works).
//
// THE BODIES (class -- CHP class -- tag -- health -- ladder tier):
//   RS_BlackSpectreEX    CommonBlackSpectreEX2  THE BACKSTABBER UNSILENCED  7,250   12 Black  (EX of RS_BlackSpectre)
//   RS_WhiteSPEX         CommonWhiteSpiderEX2   WHITE HOT SPIDER            9,500   13 White  (EX of RS_WhiteSP1)
//     RS_WhiteSPEXSplit    CommonWhiteSpiderEX3   (its first split, x2)     2,200
//     RS_WhiteSPEXSplit2   CommonWhiteSpiderEX4   (its second split)          500
//   RS_BlackArchEX       CommonBlackArchEX2     AHH HELP!!!                 2,700   12 Black  (EX of RS_BlackArch)
//     RS_BlackArchEXVoid   CommonBlackArchEX3     Void Strikes back         4,166   (three rise from its death)
//   RS_WhiteArchEX       CommonWhiteArchEX2     Time to die                20,800   13 White  (EX of RS_WhiteArch)
//     RS_WhiteArchEXClone  CommonWhiteArchEX3     (its clones)                500
//   RS_BlackCybieEX      CommonBlackCybieEX2    Obsidian Tyrant            24,000   12 Black  (EX of RS_BlackCybie)
//   RS_WhiteCybieEX      CommonWhiteCybieEX2    It crashes doom II         32,767   13 White  (EX of RS_WhiteCybie)
//     RS_WhiteCybieEXCore  CommonWhiteCybieEX3    The one behind it all     3,000
//   RS_WhiteMindES       CommonWhiteMind2       Everlasting White Spidey   20,000   13 White  (CHP's White Mastermind)
//   RS_WhiteSPPlus       CommonWhiteSpider2     White Spider (CHP "New")   (RS_WhiteSP11 + CHP's changes)
//   RS_WhiteSPFusion     CommonWhiteSpider3     (CHP "Fusion")              4,000   13 White, splits into
//     RS_WhiteSPFusion2 / RS_WhiteSPFusion3  CommonWhiteSpider4 / 5         1,250 / 500
//   1.04's dormant RS_WhiteSP11Old and RS_BlackLSoulOld3 were already ported (spider/, lostsoul/); CHP's
//   "Old" choices for the White Arachnotron and the Black Lost Soul spawn them (RS_PlusEX.WhiteSpider / BlackSoul).
//   ON THE LADDER (11-17, owner-approved): the bodies named "EX" by their gate (RS_TierLadder.FamilyOfAny); the
//   Everlasting White Spidey, the Fusion, New and Old White Arachnotrons and the Old Black Lost Soul by the 1.04 body whose
//   slot they hold (RS_TierLadder.PlusSlotOf). A tier change or the World Tier landing on one of those slots gives the
//   body the Plus row picks (LadderBody below). The splits, clones and cores stay off the ladder.
//
// NAMING: an EX body is its gate's name + "EX" (RS_BlackCybie -> RS_BlackCybieEX; the spider's RS_WhiteSP1 ->
// RS_WhiteSPEX), the rule RS_TierLadder.IsEXName / FamilyOfAny and RS_BossfightPick.SetClassEX already read, so
// Score's "ex" row, the tier change and RSQ Miniboss's "set.class.ex" pick find these with no new table.
//
// HOW THEY SPAWN: the six gates' Black/White branch asks RS_PlusEX for the class (one line in each family file):
// the EX share is 1.04's own rs_ch_exboss roll (1 = 24 in 256, 2 = half, 3 = always, anything else never).
// The three type choices (CVARINFO.plusex: rs_chp_whitespider, rs_chp_blacksoul, rs_chp_whitemind) are rows on Test and
// Debug > ColorfulHell Switches (11-16 bugfix MO5); Test and Debug's A0001-A0003 rows spawn the bodies they pick.
//
// CONVERSION: Monsters/tools/plus_ex/conv.py (DECORATE -> ZScript, this file's rules) then hand edits, each marked "CHP:".
// The same rules as the 1.04 port (cyberdemon/RS_CyberdemonFX.zs header): Damage (roll) -> DamageFunction,
// A_ChangeFlag -> { bFLAG = x; }, A_SetUserVar -> member assignment, ThrustThing angles int(), RenderStyle quoted.
// CHP's icon actors (NewIconCHP*) are replaced by this series' tier gem (RS_ColorTierIconCH10 Black / CH11 White,
// RS_PlusEX.Icon from each body's Tick). ACS: announcers dropped (standing order); "EXBOSS" -> the same A_Log the
// 1.04 EX bosses use; the White Arch-vile EX's timers -> RS_PlusWVileTimer below.
//
// STUBBED (owner: no Abyss-style effects that reverse the player's movement or darken the screen):
//   RS_DarknessTokenBlackSpectreEX, RS_BVileEXDarknessToken, RS_BlackMindDarknessToken -- CHP Powerups that blacken
//   the player's screen (Powerup.Color "00 00 00",0.5 + A_Light). Each is an item no one can hold.
// ============================================================================

class RS_PlusEX play
{
	// the tier gem over the body, the way the 1.04 EX bosses show it (RS_BlackImpEX spawns RS_ColorTierIconCH10 in
	// its Idle and See loops; here from Tick so CHP's state offsets -- Goto See+1 and the like -- stay exact). The gem
	// only draws with "Tier Icons Above Monsters" on, so nothing is spawned when it is off.
	static void Icon(Actor mo, int tier)
	{
		if (!mo || mo.health <= 0 || mo.bDORMANT || (level.maptime + mo.tid) % 12) return;
		if (RS_Zom.CV('rs_ch_colorblind', 0) != 1) return;
		mo.A_SpawnItemEx(tier >= 13 ? "RS_ColorTierIconCH11" : "RS_ColorTierIconCH10", 0, 0, 32,
			random(1, 4), 0, random(0, 2), random(0, 359), SXF_NOCHECKPOSITION);
	}

	// 1.04's EX roll, as the gate stubs make it (RS_BlackImp: rs_ch_exboss 1 -> A_Jump(232) off = 24 in 256 EX,
	// 2 -> half, 3 -> always, anything else never)
	static bool RollEX()
	{
		int g = RS_Zom.CV('rs_ch_exboss', 1);
		if (g == 3) return true;
		if (g == 2) return random[rsplusex](0, 255) >= 128;
		if (g == 1) return random[rsplusex](0, 255) >= 232;
		return false;
	}

	// a gate's boss branch: the plain body, or its CHP EX form on the EX roll
	static class<Actor> Boss(class<Actor> plain, class<Actor> ex)
	{
		return RollEX() ? ex : plain;
	}

	// The White Arachnotron gate (RS_WhiteSP1): EX on the roll, else the type the menu picks (CHP's CH_OldWSpid,
	// rs_chp_whitespider): 1 = 1.04's body (RS_WhiteSP11, this series' default and unchanged), 2 = Old
	// (RS_WhiteSP11Old, dormant in 1.04), 3 = Fusion (RS_WhiteSPFusion), 4 = CHP's New (RS_WhiteSPPlus).
	static class<Actor> WhiteSpider()
	{
		if (RollEX()) return "RS_WhiteSPEX";
		return WhiteSpiderType();
	}
	static class<Actor> WhiteSpiderType()
	{
		int t = RS_Zom.CV('rs_chp_whitespider', 1);
		if (t == 2) return "RS_WhiteSP11Old";
		if (t == 3) return "RS_WhiteSPFusion";
		if (t == 4) return "RS_WhiteSPPlus";
		return "RS_WhiteSP11";
	}

	// The Black Lost Soul gate (RS_BlackLSoul, no EX on black in this family): CHP's CH_OldBSoul, rs_chp_blacksoul:
	// 1 = 1.04's body (RS_BlackLSoul3, default, unchanged), 2 = Old (RS_BlackLSoulOld3, dormant in 1.04).
	static class<Actor> BlackSoul()
	{
		return RS_Zom.CV('rs_chp_blacksoul', 1) == 2 ? "RS_BlackLSoulOld3" : "RS_BlackLSoul3";
	}

	// The White Mastermind gate (RS_WhiteMind): CHP replaced 1.04's White Mastermind (Heavily Armed Spidey) with
	// the Everlasting White Spidey. rs_chp_whitemind: 1 = 1.04's only (default, owner 11-16 11:3x), 2 = CHP's only,
	// 3 = either, half and half. The Everlasting White Spidey is in RSQ Miniboss's Big Boss pool either way (RSQBIGBS.txt).
	static class<Actor> WhiteMind()
	{
		int t = RS_Zom.CV('rs_chp_whitemind', 1);
		if (t == 2 || (t == 3 && random[rsplusex](0, 1))) return "RS_WhiteMindES";
		return "RS_WhiteMind2";
	}

	// [11-17] THE LADDER'S BODY FOR A PLUS SLOT (owner-approved 11-17): a tier change or the World Tier that lands on the
	// White Arachnotron, the Black Lost Soul or the White Mastermind (RS_Retier.Swap, the World Tier's raised spawn in
	// RS_RosterHandler) gives the body that slot's Plus row picks, as the gate does, without the gate's EX roll (the ladder
	// never gives an EX body). At the rows' defaults (1 each) that is 1.04's body, the ladder's own: nothing changes.
	// Any other class comes back as it went in.
	static Name LadderBody(Name cls)
	{
		class<Actor> c = null;
		if (cls == 'RS_WhiteSP11') c = WhiteSpiderType();
		else if (cls == 'RS_BlackLSoul3') c = BlackSoul();
		else if (cls == 'RS_WhiteMind2') c = WhiteMind();
		return c ? c.GetClassName() : cls;
	}

	// ---- the White Arch-vile EX ("Time to die"), CHP source/WVileEX.acs rewritten --------------------------------
	// WVileEXArmorSteal_C (WVileEX.acs:5): on the vile's target: a white flash, "rsplus/wvextake" at full volume, the speed
	// nerf (WVileEXSpeedNerf, PowerSpeed 0.25 for 10 s), every point of armour taken, 20 damage.
	// CHP: FadeTo(255,255,255,1.0,0.0) then back over 1 s -- here a softer 60% white blend over the same second.
	static void WVileArmorSteal(Actor vile)
	{
		if (!vile) return;
		let t = vile.target;
		if (!t || t.health <= 0) return;
		t.A_SetBlend("White", 0.6, 35);
		t.A_StartSound("rsplus/wvextake", CHAN_AUTO, CHANF_DEFAULT, 1.0, ATTN_NONE);
		t.GiveInventory("RS_WVileEXSpeedNerf", 1);
		t.TakeInventory("BasicArmor", 0x7fffffff);
		t.DamageMobj(vile, vile, 20, 'None');
		if (PlusLog()) Console.Printf("RSPLUSEX WVILE armorsteal on %s", t.GetClassName());
	}

	// [11-16 bugfix MO10] the RSPLUSEX lines are Test and Debug > Logs > Plus Boss Log's (rsq_mon_plus_debug): a Console.Printf
	// also reaches the notify lines on screen. The countdown itself is the centre print to the target, always.
	static bool PlusLog() { return RS_Zom.CV('rsq_mon_plus_debug', 0) != 0; }

	// WVileEXTimer_C + WVileEXTimer2_C (WVileEX.acs:199, 2130): the 300-second count.
	static void WVileTimer(Actor vile)
	{
		if (!vile) return;
		let j = new("RS_PlusWVileTimer");
		j.vile = vile;
		j.victim = vile.target;
		j.t0 = level.maptime;
		j.Start();
	}
	static void WVileTimer2(Actor vile) {}   // the timer thinker does both scripts' work (see RS_PlusWVileTimer)

	// WVileEXTimeStop (WVileEX.acs:2242): the clock sound stops on the target; ACS_NamedTerminate(WVileEXTimer_C)
	static void WVileTimeStop(Actor vile)
	{
		if (!vile) return;
		if (vile.target) vile.target.A_StopSound(RS_PlusWVileTimer.CLOCKCHAN);
	}
	static void WVileTimerStop(Actor vile)
	{
		let it = ThinkerIterator.Create("RS_PlusWVileTimer", Thinker.STAT_DEFAULT);
		RS_PlusWVileTimer j;
		while (j = RS_PlusWVileTimer(it.Next())) if (j.vile == vile) j.Halt();
	}
}

// The White Arch-vile EX's 300-second count (CHP WVileEX.acs "WVileEXTimer_C" + "WVileEXTimer2_C").
// CHP's script runs on the vile's target: "rsplus/time03" looped on CHAN_7, a HUD line at 300/200/100/50/20 s and every
// second from 10, a quake every 10 s (stronger as the end nears). Timer2: at 10,500 tics (300 s) the vile turns
// invulnerable and gets TIMESUPMOT, which sends it to TIMESUP (it stops the target and fires until the target dies).
// Here: one thinker. The lines are a centre print on the target player (and the log); the quakes are A_Quake on
// the target, the same numbers; the clock loops on its own channel (CLOCKCHAN) so a mod's CHAN_7 cannot cut it.
class RS_PlusWVileTimer : Thinker
{
	const CLOCKCHAN = 41;
	Actor vile, victim;
	int t0;
	bool done;

	void Start()
	{
		if (victim) victim.A_StartSound("rsplus/time03", CLOCKCHAN, CHANF_LOOPING, 1.0, ATTN_NORM);
		Say("300 seconds left...");
		Quake(1, 35);
	}

	void Halt()
	{
		if (victim) victim.A_StopSound(CLOCKCHAN);
		Destroy();
	}

	void Say(String s)
	{
		if (RS_PlusEX.PlusLog()) Console.Printf("RSPLUSEX WVILE timer t+%d: %s", level.maptime - t0, s);
		if (victim && victim.player) victim.A_Print("\cf" .. s, 3);
	}

	void Quake(int i, int d)
	{
		if (victim) victim.A_Quake(i, d, 0, 1200);
	}

	override void Tick()
	{
		if (!vile || vile.health <= 0) { Halt(); return; }
		int e = level.maptime - t0;
		// WVileEXTimer2_C: Delay(10500); invulnerable; TIMESUPMOT
		if (e >= 10500)
		{
			vile.bINVULNERABLE = true;
			vile.GiveInventory("RS_TIMESUPMOT", 1);
			if (RS_PlusEX.PlusLog()) Console.Printf("RSPLUSEX WVILE time is up: %s invulnerable, TIMESUPMOT given", vile.GetClassName());
			if (victim) victim.A_StopSound(CLOCKCHAN);
			Destroy();
			return;
		}
		if (e > 0 && e % 350 == 0)
		{
			int k = e / 350;   // 1..29: ten 10 s steps (1,35), ten (1,35), five (2,60), three (3,100), one (5,200)
			if (k == 10) Say("200 seconds left...");
			else if (k == 20) Say("100 seconds left...");
			else if (k == 25) Say("50 seconds left...");
			else if (k == 28) Say("20 seconds left...");
			else if (k == 29) Say("10...");
			if (k < 20)      Quake(1, 35);
			else if (k < 25) Quake(2, 60);
			else if (k < 28) Quake(3, 100);
			else if (k < 29) Quake(5, 200);
			else             Quake(9, 350);
		}
		if (e > 10150 && (e - 10150) % 35 == 0)
		{
			int n = 10 - (e - 10150) / 35;
			if (n >= 1 && n <= 9) Say(String.Format("%d...", n));
		}
	}
}

// CHP 14/14_WX:611 (WVileEXSpeedNerf): given by WVileEXArmorSteal_C only (so no state names it; the converter's
// reference walk could not find it).
class RS_WVileEXSpeedNerf : PowerSpeed
{
	Default
	{
		Speed 0.25;
		Powerup.Duration -10;
	}
}
