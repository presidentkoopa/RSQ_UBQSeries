// ============================================================================
// THE TOOL VOCABULARY: one set of ids for every move in the series (Score/ideas/COMBOS_MASTER.md section 1,
// built 2026-11-03). A tool id is `mod.move`, lower case. The ledger (combo.zs) records tools; a pattern step
// names a tool, a group, or a prefix; the melee family (melee.zs) reads the kill's tool back out of the ledger,
// so there is ONE classification of a blow and two readers.
//
//   Canon     the ids the mods send today (their touch calls) mapped onto the vocabulary, so no mod has to
//             change its strings for Score to understand them; an unknown id passes through unchanged
//   IsTag     facts ABOUT a blow (an upgrade hook, how it landed): stored on the blow's run, never a tool
//   ActionOf  what a tool counts as when the tools of a chain are counted (every gun.* is the one action gun)
//   ModOf     which mod delivered it (the generic chain's breadth: +0.1 a mod past two)
//   Guess     a classification from the damage type alone, which a mod's own name for the move replaces when
//             it arrives on the same tic (Melee's pound, clearout and shove; the Whip's tarzan; the hook's zip)
//   InGroup   does tool t answer pattern step g (exact, prefix, or a group: melee, hands, fists, headlock,
//             block, parry, return, throw, dodge, any, or one a mod registered with RegisterTool)
//   Classify  what struck, for a blow a player dealt
// ============================================================================

class RS_Tool play
{
	// ---- the ids the mods send today, onto the vocabulary ------------------------------------------------
	static String Canon(String id)
	{
		// RSQ Grenade's kinds (kinds.zs Effect, thrown.zs): one throw is one tool, grenade.<kind>
		if (id == "stun.nade")   return "grenade.stun";
		if (id == "freeze.nade") return "grenade.freeze";
		if (id == "flash")       return "grenade.flash";
		if (id == "smoke")       return "grenade.smoke";
		if (id == "fire.nade")   return "grenade.fire";
		if (id == "sticky")      return "grenade.sticky";
		if (id == "charm")       return "grenade.charm";
		if (id == "infight")     return "grenade.infight";
		// RSQ Whip (whip.zs Touch)
		if (id == "lasso")        return "whip.lasso";
		if (id == "bola")         return "whip.bola";
		if (id == "tarzan")       return "whip.tarzan";
		if (id == "crack.shot")   return "whip.shot";
		if (id == "crack.return") return "whip.return";
		if (id == "whip")         return "whip.crack";
		// RSQ Melee
		if (id == "swat.back")   return "swat";
		if (id == "parry")       return "guard.parry";
		if (id == "slam")        return "headlock.slam";
		if (id == "choke")       return "headlock.choke";
		if (id == "whip.pistol") return "shove";          // the Pistol Whip: one move with the gun-butt shove and BD22's butt strike
		// the rig and Distance Grab
		if (id == "gun.toss")    return "throw.gun";      // a gun.* id would join the group gun (C's gun.throw)
		if (id == "body.shield") return "grab.shield";
		// RSQ Grapple: the Zip Kick is a hook move, not a second tool on the bite
		if (id == "zip.kick")    return "hook.zip";
		// Gun Bonsai VR's Finisher node is a tag; Score's fatality tool is the Brutal Doom execution
		if (id == "finisher")    return "fist.finisher";
		return id;
	}

	// ---- tags: facts about a blow, never a tool (COMBOS_MASTER 1.4) ------------------------------------
	static bool IsTag(String id)
	{
		static const String tags[] =
		{
			// RSQ Melee
			"hit.heavy", "hit.body", "juggle", "punch.uppercut", "launch", "meteor", "wall", "shield.human",
			"bullet.punch", "butt.knockdown", "catch", "guard",
			// Gun Bonsai VR (every tree)
			"crit", "headshot", "backstab", "combo.3", "combo.dempsey", "fist.finisher", "fist.explosive", "shatter",
			"arc", "burn", "bloodrush", "berserk.earned", "lucky", "knockdown", "ram", "sever", "staff.spin",
			"boomerang", "slow.burn",
			// QuestSaber
			"stab.lunge", "impale", "crossguard", "barrage", "return.sender", "force.speed",
			// RSQ ShieldSaw
			"cleave.saw", "spartan", "buzz.return", "rev.block", "charge", "dash.bash", "slam.saw", "reflect.saw",
			"backplate",
			// RSQ Whip
			"crack", "crack.stun", "crack.marked", "pull.punch", "yank.heavy",
			// RSQ Grapple
			"scorpion", "torn",
			// RSQ Grenade
			"cooked", "skeet", "teeth", "airburst", "hand", "impact",
			// Distance Grab, the rig
			"heavy", "thrown", "empty", "boomerang.gun"
		};
		for (int i = 0; i < tags.Size(); i++) if (tags[i] == id) return true;
		return RS_ScoreRegistry.ToolInGroup(id, "tag");
	}

	// ---- what a tool counts as (the generic chain counts ACTIONS) ----------------------------------------
	static String Prefix(String t)
	{
		int dp = t.IndexOf(".");
		return dp > 0 ? t.Left(dp) : t;
	}

	static String ActionOf(String t)
	{
		String pre = Prefix(t);
		if (pre == "gun" || pre == "glove" || pre == "grenade" || pre == "hook") return pre;
		if (pre == "whip") return t == "whip.yank" ? t : "whip";
		if (pre == "rig") return "rig.draw";
		if (t == "saber.stab" || t == "saber.spin") return "saber.cut";
		if (t == "shield.grind" || t == "shield.dash" || t == "shield.slam") return "shield.bash";
		return t;
	}

	// ---- which mod delivered it (the chain's breadth) ---------------------------------------------------
	static String ModOf(String t)
	{
		String pre = Prefix(t);
		if (pre == "glove" || pre == "shove" || pre == "guard" || pre == "hadouken" || pre == "swat" || pre == "taunt"
			|| pre == "pound" || pre == "clearout" || pre == "headlock" || t == "grab.hold") return "melee";
		if (pre == "saber" || pre == "force") return "saber";
		if (pre == "shield") return "shield";
		if (pre == "whip") return "whip";
		if (pre == "hook") return "hook";
		if (pre == "grab") return "grab";
		if (pre == "grenade") return "grenade";
		if (pre == "gun") return "gun";
		if (pre == "rig" || pre == "throw") return "rig";
		if (pre == "punch" || pre == "kick" || pre == "blade" || pre == "fatality") return "bd";
		if (pre == "lean") return "slowmo";
		return pre;
	}

	// ---- a guess from the damage type, which the mod's own name for the move replaces --------------------
	static bool Guess(String t)
	{
		String pre = Prefix(t);
		return t == "punch" || t == "kick" || t == "glove" || pre == "gun" || pre == "blade"
			|| t == "whip.crack" || t == "hook.bite" || t == "shield.bash" || t == "grenade.frag"
			|| t == "force.push" || t == "grab.throw" || t == "saber.cut";
	}

	static bool IsMelee(String t)
	{
		String pre = Prefix(t);
		return pre == "saber" && t != "saber.return" && t != "saber.block" && t != "saber.parry"
			|| pre == "force" && t != "force.pull"
			|| pre == "shield" && t != "shield.block" && t != "shield.perfect" && t != "shield.return"
			|| pre == "whip" && (t == "whip.crack" || t == "whip.flail" || t == "whip.tarzan")
			|| t == "hook.zip" || t == "hook.slam"
			|| pre == "glove" || t == "shove" || t == "guard.release" || t == "pound" || t == "clearout"
			|| t == "headlock.throw" || t == "headlock.slam" || t == "headlock.choke" || t == "headlock.launch"
			|| t == "grab.swing" || pre == "blade" || t == "punch" || t == "kick" || t == "fatality";
	}

	// does tool t answer to pattern step g (the id part of a step: the conditions are the ledger's)
	static bool InGroup(String t, String g)
	{
		if (g == "any" || t == g) return true;
		String pre = Prefix(t);
		if (pre == g) return true;
		if (g == "melee") return IsMelee(t);
		if (g == "hands") return t == "kick" || t == "punch" || pre == "glove";
		if (g == "fists") return pre == "glove" || t == "shove" || pre == "guard" || t == "hadouken" || t == "swat"
			|| t == "taunt" || t == "pound" || t == "clearout" || t == "grab.hold" || pre == "headlock";
		if (g == "headlock") return t == "grab.hold" || pre == "headlock";
		if (g == "block") return t == "shield.block" || t == "shield.perfect" || t == "saber.block" || t == "saber.parry";
		if (g == "parry") return t == "saber.parry" || t == "shield.perfect";
		if (g == "return") return t == "saber.return" || t == "shield.return" || t == "hadouken" || t == "swat"
			|| t == "guard.reflect" || t == "whip.return" || t == "grab.shield";
		if (g == "throw") return t == "saber.throw" || t == "shield.disc" || t == "whip.lasso" || t == "whip.bola"
			|| t == "headlock.throw" || t == "grab.throw" || t == "throw.gun";
		if (g == "dodge") return t == "lean";
		if (g == "rig.draw") return pre == "rig";
		return RS_ScoreRegistry.ToolInGroup(t, g);
	}

	// ---- a pattern step: id[@slow][+cond]... -------------------------------------------------------------
	// Answers whether the ledger entry (its tool, its condition bits, its tags) satisfies the step.
	static bool StepMatches(String tool, int cond, String tags, String step)
	{
		String id = step;
		bool wantSlow = false;
		Array<String> want;
		int at = step.IndexOf("@slow");
		if (at >= 0) { wantSlow = true; id = step.Left(at) .. step.Mid(at + 5); }
		Array<String> parts;
		id.Split(parts, "+", TOK_SKIPEMPTY);
		if (parts.Size() == 0) return false;
		id = RS_ScoreRegistry.Trim(parts[0]);
		for (int k = 1; k < parts.Size(); k++) want.Push(RS_ScoreRegistry.Trim(parts[k]));
		if (!InGroup(tool, id)) return false;
		if (wantSlow && !(cond & RS_ComboLedger.C_SLOW)) return false;
		for (int k = 0; k < want.Size(); k++)
		{
			String w = want[k];
			if (w == "air")  { if (!(cond & RS_ComboLedger.C_AIR)) return false; continue; }
			if (w == "pb")   { if (!(cond & RS_ComboLedger.C_PB)) return false; continue; }
			if (w == "head") { if (!(cond & RS_ComboLedger.C_HEAD)) return false; continue; }
			if (!HasTag(tags, w)) return false;
		}
		return true;
	}

	static bool StepIsSlow(String step) { return step.IndexOf("@slow") >= 0; }

	static bool HasTag(String tags, String tag)
	{
		if (tags == "") return false;
		Array<String> a;
		tags.Split(a, ",", TOK_SKIPEMPTY);
		for (int k = 0; k < a.Size(); k++) if (a[k] == tag) return true;
		return false;
	}

	// ---- the victim filter after a pattern ("... | champ"): the facts boost.zs reads, by name ----------------
	static bool VictimIs(Actor v, String filter)
	{
		if (!v) return false;
		if (filter == "") return true;
		return RS_Boost.VictimIs(v, filter);
	}

	// ---- BD22 VR Reloaded's guns, by inflictor and by the gun in the hand that fired (COMBOS_MASTER 1.2) --------
	// A gun outside the table (another weapon set) is plain gun; vanilla Doom's are in it so the rows read on doom2.
	static String GunClassOf(String weapon)
	{
		if (weapon.Left(8) ~== "RSQ_Off_") weapon = weapon.Mid(8);   // the off-hand twins are subclasses named RSQ_Off_<Gun>
		if (weapon ~== "BrutalPistol" || weapon ~== "BrutalRevolver" || weapon ~== "Revolver" || weapon ~== "Pistol") return "gun.pistol";
		if (weapon ~== "Shot_Gun" || weapon ~== "SSG" || weapon ~== "AssaultShotgun" || weapon ~== "Shotgun" || weapon ~== "SuperShotgun") return "gun.shotgun";
		if (weapon ~== "Rifle" || weapon ~== "Machinegun" || weapon ~== "BrutalSMG" || weapon ~== "MiniGun" || weapon ~== "Sniper" || weapon ~== "Chaingun") return "gun.rifle";
		if (weapon ~== "Rocket_Launcher" || weapon ~== "GrenadeLauncher" || weapon ~== "NukeLauncher" || weapon ~== "RocketLauncher") return "gun.explosive";
		if (weapon ~== "Plasma_Gun" || weapon ~== "RailGun" || weapon ~== "BIG_FUCKING_GUN" || weapon ~== "BFG10k" || weapon ~== "Unmaker"
			|| weapon ~== "PlasmaRifle" || weapon ~== "BFG9000") return "gun.energy";
		if (weapon ~== "Flamethrower2") return "gun.fire";
		return "";
	}

	// the missiles that name their gun on their own
	static String GunClassOfMissile(String icn)
	{
		if (icn.Left(6) ~== "Rocket" || icn ~== "ShortGrenade" || icn ~== "GrenadeMissile" || icn.Left(7) ~== "Nuclear" || icn ~== "SpawnedExplosionNuke") return "gun.explosive";
		if (icn.Left(10) ~== "PlasmaBall" || icn.Left(3) ~== "BFG" || icn.Left(7) ~== "Railgun" || icn.Left(7) ~== "Unmaker") return "gun.energy";
		if (icn.Left(12) ~== "Flamethrower" || icn.Left(7) ~== "Burning") return "gun.fire";
		return "";
	}

	static String GunClass(Actor inf, Actor src)
	{
		String icn = "";
		if (inf) icn = inf.GetClassName();   // a Name converts to a String on assignment, never inside ?:
		if (inf && inf.bMissile)
		{
			String missileGun = GunClassOfMissile(icn);
			if (missileGun != "") return missileGun;
		}
		let p = src ? src.player : null;
		if (!p) return "gun";
		// a hitscan is this tic: the buttons say which hand (BT_OFFHANDATTACK alone: the off hand's gun)
		int b = p.cmd.buttons;
		bool off = (b & BT_OFFHANDATTACK) && !(b & BT_ATTACK);
		Weapon w = off ? p.OffhandWeapon : p.ReadyWeapon;
		if (!w) w = p.ReadyWeapon;
		String g = w ? GunClassOf(w.GetClassName()) : "";
		return g != "" ? g : "gun";
	}

	// ---- what struck, for a blow a player dealt (src) to a monster (v) ----------------------------------------
	// The melee family's facts (melee.zs, measured there), read for every blow and not only the killing one;
	// the kill reads its own tool back out of the ledger (RS_Melee.KindOf).
	static String Classify(Actor v, Actor inf, Actor src, Name dt, int flags)
	{
		String icn = "";
		if (inf) icn = inf.GetClassName();
		int pn = src.PlayerNumber();
		if (icn ~== "SSQ_Disc") return "shield.disc";
		if (icn ~== "UBQS_Thrown") return "saber.throw";
		if (icn ~== "UBQS_Force")
		{
			// the Force item: its push lands as 'Saber', its choke, slam and jump landing as 'Force' (QuestSaber
			// Push / GripTick / SlamTick / LandSlam). The choke carries DMG_NO_PAIN; the landing has the shape of a
			// landing (melee.zs LandingShape); the rest is a flung body's slam.
			if (dt != 'Force') return "force.push";
			if (flags & DMG_NO_PAIN) return "force.grip";
			if (RS_Melee.LandingShape(src, v)) return "force.jump";
			return "force.slam";
		}
		if (icn ~== "UBQS_Bolt" || icn ~== "UBQS_RemoteBolt") return "saber.return";
		// RSQ Whip: its own damage type, from the pawn (a crack, a swing's arrival), nothing (the swung body's own
		// hurt) or the swung monster (a flail smash)
		if (dt == 'Whip') return (inf && inf != src && inf.bIsMonster) ? "whip.flail" : "whip.crack";
		// RSQ Grenade's blasts (and BD22 VR's hand grenade, which the Grenade stands down for): one throw, one tool
		if (icn ~== "RSQGN_Thrown" || icn ~== "RSQGN_HandBlast" || icn ~== "HandGrenade" || icn ~== "FragGrenadeExplosion") return "grenade.frag";
		if (icn ~== "RSQGN_Bomblet") return "grenade.cluster";
		if (icn ~== "RSQGN_FireField") return "grenade.fire";
		// RSQ_Grapple's own blows: noted by its service before they land (asked only for a blow that could be one:
		// every blow passes through here, a shotgun's twenty pellets a tic). A thrown body striking anything is the
		// yank's, whatever the inflictor (the Double Hook's slam, the Bowling perk).
		if (dt == 'Melee' && inf == src && RS_Grapple.Ask("whipped", v) == 0) return "whip.crack";
		if (dt == 'Melee' && !inf && RS_Grapple.Ask("landing", v) == 0) return "hook.yank";
		if (dt == 'Melee' && RS_Grapple.Ask("struck", v) == 0) return "hook.yank";
		bool shot = inf && (inf.bIsPuff || inf.bMissile);
		if (!shot && RS_Grapple.Ask("hook.dealing", src) == 1) return "hook.bite";
		// a hooked barrel's blast (sheet B S23): RSQ_Grapple keeps a record for any actor its claw bit
		if (inf && inf != src && !shot && !inf.bIsMonster && RS_Grapple.Ask("hooked", inf) >= 0 && RS_Grapple.Ask("hooked.by", inf) == pn) return "hook.keg";
		// a gun thrown by hand (sheet C7): the Tactical Rig's flight, or a floor gun thrown with Distance Grab, strikes
		// as 'Melee' with the weapon itself as the inflictor -- no punch
		if (dt == 'Melee' && inf && inf != src && inf is "Weapon") return "throw.gun";
		// a live monster thrown by hand (sheet S8, B S13): out of the Headlock (RSQ Melee's own toss, or Distance Grab
		// carrying it), striking something -- or itself, its own landing -- as 'Melee' with the body as the inflictor
		if (dt == 'Melee' && inf && inf != src && inf.bIsMonster && inf.health > 0) return "headlock.throw";
		if (dt == 'Melee' && !inf && RS_Physical.AskGrab("throw.by", v) == pn) return "headlock.throw";   // its own landing, Distance Grab carrying it
		// a thing thrown with Distance Grab (an object)
		if (inf && inf != src && !inf.bIsPuff && RS_Physical.AskGrab("throw.by", inf) == pn) return "grab.throw";
		if (RS_Melee.IsGlove(inf)) return GloveKind(inf);
		// a shot sent back: turned by the shield (a fresh puff or missile of the shield's), or a monster's missile now
		// yours (the saber, the Force; a Hadouken or Swat is narrowed by Melee's "returned.by" when it answers)
		if (shot && inf != src && (RS_Melee.AskShield("returned", inf) >= 0 || RS_Melee.AskShield("returned", v) >= 0)) return "shield.return";
		if (inf && inf.bMissile && RS_ScoreShots.BornOfMonster(inf))
		{
			int by = RS_Svc.Int(RS_Svc.MELEE, "returned.by", 0, inf);
			if (by == 0) return "hadouken";
			if (by == 1) return "swat";
			if (by == 2) return "guard.reflect";
			if (RS_Svc.Int(RS_Svc.WHIP, "returned", 0, inf) >= 0) return "whip.return";
			return "saber.return";
		}
		if (dt == 'Fatality') return "fatality";
		if (dt == 'Saber') return "saber.cut";
		if (inf == src && RS_Melee.ShieldInHand(src) && (dt == 'Melee' || dt == 'Saw')) return dt == 'Saw' ? "shield.grind" : "shield.bash";
		if (dt == 'Saw' || dt == 'Cut')
		{
			if (icn.Left(8) ~== "SSawPuff" || icn.Left(9) ~== "SawDamage") return "blade.saw";
			if (icn.Left(9) ~== "AxeAttack" || icn ~== "AxePuffs" || icn.Left(10) ~== "ThrowedAxe") return "blade.axe";
			return "blade";
		}
		// a missile is never a kick (BD22's Grenade Launcher's bouncing round carries DamageType Kick)
		if ((dt == 'Kick' || dt == 'HeadKick' || dt == 'Stomp') && !(inf && inf.bMissile)) return "kick";
		if (dt == 'Melee' || dt == 'ExtremePunches') return "punch";
		// a shot. Inside Quick Draw's window after a holster draw of the hand that fired, it is the draw's.
		int hand = RS_Physical.FiringHand(src);
		int t = RS_Physical.AskRig("rig.drawtic", src, hand);
		if (t >= 0 && level.maptime - t <= RS_Bonus_QuickDraw.WINDOW) return "rig.draw";
		return GunClass(inf, src);
	}

	// the glove's punch, by kind when RSQ Melee answers it (RSQML_Service "punch.kind": 0 jab, 1 hook, 2 uppercut)
	static String GloveKind(Actor glove)
	{
		int k = RS_Svc.Int(RS_Svc.MELEE, "punch.kind", 0, glove);
		if (k == 0) return "glove.jab";
		if (k == 1) return "glove.hook";
		if (k == 2) return "glove.upper";
		return "glove";
	}
}
