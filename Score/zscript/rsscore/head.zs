// ============================================================================
// THE HEAD-SHOT CHECK (owner 2026-11-09: "there is no headshot pk3, it needs to be part of RS Score").
// Design and the owner's rulings: design/HEADSHOT_SOLUTION.md (the rulings block at its top wins).
//
// ONE VERDICT PER BLOW, decided here, at the moment of damage (WorldThingDamaged), for EVERY monster: Brutal Doom's,
// ColorfulHell's, MeatGrinder's and any pack's.
//
//   head  when the hit point is at or above  feet + f x Height,  where `feet` is the monster's own pos.z (never the
//         floor under the blood) and Height its CURRENT collision box (a 1.25x monster grown with A_SetSize is
//         judged on its grown box). f is the monster's FAMILY's own head fraction: Brutal Doom's fixed heights turned
//         into fractions of that BD type's height (the imp's 46 of 56 = 0.82, the chaingunner's 50 of 60 = 0.83...),
//         0.80 (rs_score_hs_unknown) for a family nobody gave numbers.
//   leg   below BD's 25 units, as the same fraction, for the families whose BD blood has a leg check.
//   body  anything else, and always: no positioned inflictor (an explosion, a punch's weapon, a body), knocked down
//         or crouching (BD's IsDown / IsCrouching tokens), a blow from inside the monster.
//
// The hit point is game state only: the bullet's puff (where the engine's trace met the box), or a missile's centre,
// clamped into the box. Never AttackPos / HmdPosition (renderer-written), never random. Cvars are server cvars.
// So every machine in a network game gets the same verdict.
//
// WHAT THE VERDICT DOES (always on since 11-09; Brutal Doom's own check as an option was removed):
//   - BRUTAL DOOM'S OWN OUTCOME, applied from it: the HitHead / HitLeg tokens BD's death states read (taken and given
//     as BD's bloods do), and BD's head damage: +30 of type Head on its blood-checked families (ACS Head_Shot's own
//     number; the monster's DamageFactor "Head" applies), the blow again (double) on its hitbox families.
//     Dealt with the PLAYER as the source (BD's own was the monster itself or its hitbox), so Score credits the kill.
//   - BD'S SMALL-MONSTER BLOODS (Blood_Imp, Blood_Zombies, Blood_Comando, SitZ_Blood, Blood_BWSS and the Vanilla
//     set's Blood_Noble / Fatso / Archie / Cybie) are swapped, by name, for copies (CheckReplacement; BD untouched,
//     nothing here inherits from BD). A copy draws BD's gore and, when this blow was judged, does nothing else: the
//     verdict already acted. A copy whose blow was not judged (a punch whose blood lands before its blow, a script's
//     blood) runs BD's own fixed check, copied number for number.
//   - BD'S HEAD HITBOX ACTORS on its big monsters (baron, knight, boss baron, arch-vile, revenant, mancubus,
//     cyberdemon) are swapped, by name, for sensors (RS_ScoreHeadSensor): the same place and size as BD's, scaled
//     with the monster's current Height (a 1.25x baron's head box is 1.25x), the same damage factors. A shot that
//     meets a sensor is a head shot; BD's outcome (the damage x2, typed as BD types it) is applied to the monster
//     from the player, here.
//   - HEAD-SHOT DAMAGE FOR ALL (owner 11-09 08:57, rs_score_hs_bonus): ColorfulHell, MeatGrinder and pack monsters
//     get the bonus of their family (a zombie-, imp-, sergeant-, chaingunner- or SS-type: +30 Head; a baron-, knight-,
//     vile-, revenant-, mancubus- or cyberdemon-type: the blow again); a monster of no known family: whichever of
//     the two is more.
//   - SCORE: the blow is marked +head in the combo ledger (combo.zs CondOf), so the Headshot row and +head combos
//     see BD, CH, MG and pack head shots alike. RS_ScoreService "headshot" answers any mod (RSQ Monsters' MeatGrinder
//     death router, its RSQMN_RosterService).
//
// Saws and axes (a weapon with AXEBLOOD) keep BD's own saw bloods and their fixed numbers: no tokens and no bonus
// from here (BD's saw bloods give no Head damage either); Score still reads the verdict. Blood_Bones (the Vanilla
// set's revenant) likewise.
// ============================================================================

class RS_ScoreHead : EventHandler
{
	enum EVerdict { HV_NONE = -1, HV_BODY = 0, HV_HEAD = 1, HV_LEG = 2 }
	// the families (Brutal Doom's numbers per family: BdHeight, BdHeadZ, BdLegZ below)
	enum EFam
	{
		HF_UNKNOWN, HF_ZOMBIE, HF_SHOTGUN, HF_CHAINGUN, HF_IMP, HF_SS,
		HF_BARON, HF_KNIGHT, HF_VILE, HF_REVENANT, HF_FATSO, HF_CYBER,
		HF_DEMON, HF_CACO, HF_PAIN, HF_SOUL, HF_ARACH, HF_MIND
	}

	// ---------------------------------------------------------------- the family table
	// Heights from brutal22test6 actors/Enemies/*.dec; head heights from actors/Gore/BloodTypesMonsters.dec (the blood
	// route) and actors/MISC/Head_Sys.dec (the hitbox route: its A_Warp z, the head box's bottom). design/HEADSHOT_SOLUTION.md 1a, 1b.
	static double BdHeight(int f)
	{
		switch (f)
		{
		case HF_CHAINGUN: return 60;   // Comando.dec:5
		case HF_BARON:    return 60;   // Baron.dec (Height 60//64)
		case HF_FATSO:    return 60;   // Mancubus.dec:23
		case HF_CYBER:    return 96;   // Cyberdemon.dec:20
		}
		return 56;
	}
	static double BdHeadZ(int f)
	{
		switch (f)
		{
		case HF_ZOMBIE: case HF_SHOTGUN: case HF_IMP: return 46;   // Blood_Imp / Blood_Zombies: (z - floorz) > 46
		case HF_CHAINGUN: return 50;   // Blood_Comando
		case HF_SS:       return 43;   // Blood_BWSS
		case HF_BARON:    return 60;   // Baron_NobleHeadshot A_Warp z 60
		case HF_KNIGHT:   return 56;   // Knight_NobleHeadshot 56
		case HF_VILE:     return 58;   // Vile_HeadHitbox 58
		case HF_REVENANT: return 56;   // BonesHeadshot 56
		case HF_FATSO:    return 56;   // MancuHeadshot 56
		case HF_CYBER:    return 98;   // NewCybersHitBox 98
		}
		return -1;
	}
	static double BdLegZ(int f)
	{
		switch (f)
		{
		case HF_ZOMBIE: case HF_SHOTGUN: case HF_IMP: case HF_SS: return 25;   // (z - floorz) < 25 (Blood_Comando has none)
		}
		return -1;
	}
	// 1 BD checks it by its blood (+30 Head), 2 by a head hitbox (the blow x2), 3 BD gives it no head, 0 unknown
	static int Route(int f)
	{
		if (f >= HF_ZOMBIE && f <= HF_SS) return 1;
		if (f >= HF_BARON && f <= HF_CYBER) return 2;
		if (f >= HF_DEMON) return 3;
		return 0;
	}
	static String FamName(int f)
	{
		static const String N[] = { "unknown", "zombie", "sergeant", "chaingunner", "imp", "ss", "baron", "knight", "vile",
			"revenant", "mancubus", "cyberdemon", "demon", "caco", "pain", "lostsoul", "arachnotron", "mastermind" };
		return (f >= 0 && f < N.Size()) ? N[f] : "?";
	}
	static int ByName(Name n)
	{
		switch (n)
		{
		case 'ZombieMan':        return HF_ZOMBIE;
		case 'ShotgunGuy':       return HF_SHOTGUN;
		case 'ChaingunGuy':      return HF_CHAINGUN;
		case 'DoomImp':          return HF_IMP;
		case 'WolfensteinSS':    return HF_SS;
		case 'BaronOfHell':      return HF_BARON;
		case 'HellKnight':       return HF_KNIGHT;
		case 'Archvile':         return HF_VILE;
		case 'Revenant':         return HF_REVENANT;
		case 'Fatso':            return HF_FATSO;
		case 'Cyberdemon':       return HF_CYBER;
		case 'Demon':            return HF_DEMON;
		case 'Spectre':          return HF_DEMON;
		case 'Cacodemon':        return HF_CACO;
		case 'PainElemental':    return HF_PAIN;
		case 'LostSoul':         return HF_SOUL;
		case 'Arachnotron':      return HF_ARACH;
		case 'SpiderMastermind': return HF_MIND;
		}
		return -1;
	}

	// ---------------------------------------------------------------- cvars (server: the same on every machine)
	// ALWAYS ON (owner 2026-11-09 22:27: "remove it"): "Brutal Doom's Own" (rs_score_hs 0) is gone; on the rig its BD head
	// kills did not pay Headshot. rs_score_hs is kept only so a saved 0 cannot switch the check off.
	static bool On()        { return true; }
	static bool BonusOn()   { let c = CVar.FindCVar("rs_score_hs_bonus"); return !c || c.GetBool(); }
	static bool HeadlessOn(){ let c = CVar.FindCVar("rs_score_hs_headless"); return !c || c.GetBool(); }
	static double Unknown() { let c = CVar.FindCVar("rs_score_hs_unknown"); return c ? clamp(c.GetInt(), 50, 98) / 100.0 : 0.80; }
	static bool LogOn()     { let c = CVar.FindCVar("rs_score_hs_log"); return c && c.GetBool(); }

	static RS_ScoreHead Get() { return RS_ScoreHead(EventHandler.Find("RS_ScoreHead")); }

	override void OnRegister() { SetOrder(-100); }   // before the combo ledger reads the verdict for the same blow

	// ---------------------------------------------------------------- classes by name (BD is never linked)
	transient bool clsReady;
	transient Array<Name> repFrom;
	transient Array< class<Actor> > repFromC, repTo;
	transient class<Actor> cHitbox;
	transient class<Inventory> cHitHead, cHitLeg, cIsDown, cIsCrouching;
	transient class<Actor> cKeptBlood;
	void Classes()
	{
		if (clsReady) return;
		clsReady = true;
		String n;
		n = "HeadHitbox";  cHitbox = n;
		n = "HitHead";     cHitHead = n;
		n = "HitLeg";      cHitLeg = n;
		n = "IsDown";      cIsDown = n;
		n = "IsCrouching"; cIsCrouching = n;
		n = "Blood_Bones"; cKeptBlood = n;
		static const String FROM[] = {
			"Blood_Imp", "Blood_Zombies", "Blood_Comando", "SitZ_Blood", "Blood_BWSS", "Blood_Noble", "Blood_Fatso", "Blood_Archie", "Blood_Cybie",
			"Baron_NobleHeadshot", "Knight_NobleHeadshot", "Boss_NobleHeadshot", "Vile_HeadHitbox", "MancuHeadshot", "BonesHeadshot", "NewCybersHitBox" };
		static const String TO[] = {
			"RS_ScoreHB_Imp", "RS_ScoreHB_Zombies", "RS_ScoreHB_Comando", "RS_ScoreHB_SitZ", "RS_ScoreHB_BWSS", "RS_ScoreHB_Noble", "RS_ScoreHB_Fatso", "RS_ScoreHB_Archie", "RS_ScoreHB_Cybie",
			"RS_ScoreHS_Baron", "RS_ScoreHS_Knight", "RS_ScoreHS_Boss", "RS_ScoreHS_Vile", "RS_ScoreHS_Mancu", "RS_ScoreHS_Bones", "RS_ScoreHS_Cyber" };
		repFromC.Clear(); repTo.Clear();
		for (int i = 0; i < FROM.Size(); i++)
		{
			n = FROM[i]; class<Actor> a = n;
			n = TO[i];   class<Actor> b = n;
			if (a && b) { repFromC.Push(a); repTo.Push(b); }
		}
	}

	// BD's head bloods and head hitboxes become ours (by name; nothing happens without BD)
	override void CheckReplacement(ReplaceEvent e)
	{
		if (!e.Replacee || !On()) return;
		Classes();
		for (int i = 0; i < repFromC.Size(); i++)
		{
			if (e.Replacee != repFromC[i]) continue;
			e.Replacement = repTo[i];
			return;
		}
	}

	// ---------------------------------------------------------------- the family of a monster (cached per class)
	Array< class<Actor> > famCls;
	Array<int> famVal;
	int FamilyOf(Actor v)
	{
		class<Actor> c = v.GetClass();
		for (int i = 0; i < famCls.Size(); i++) if (famCls[i] == c) return famVal[i];
		int f = Resolve(v);
		famCls.Push(c); famVal.Push(f);
		return f;
	}
	private int Resolve(Actor v)
	{
		// RSQ Monsters names the Doom family of its own bodies (its MeatGrinder set derives from no Doom class), by name
		String fn = RS_Svc.Str(RS_Svc.MONSTERS, "family", v);
		if (fn != "") { int f = ByName(fn); if (f >= 0) return f; }
		// the class and its parents, and what each one replaces (BD's Imp replaces DoomImp; CH's RS_CommonImp is a DoomImp)
		for (class<Actor> c = v.GetClass(); c; c = (class<Actor>)(c.GetParentClass()))
		{
			int f = ByName(c.GetClassName());
			if (f >= 0) return f;
			class<Actor> r = Actor.GetReplacee(c);
			for (int g = 0; r && r != c && g < 8; g++)
			{
				f = ByName(r.GetClassName());
				if (f >= 0) return f;
				r = (class<Actor>)(r.GetParentClass());
			}
			if (c.GetClassName() == 'Actor') break;
		}
		return HF_UNKNOWN;
	}

	// the head fraction for this body: its family's, measured on its current Height
	double HeadLo(Actor v, int f)
	{
		int rt = Route(f);
		if (rt == 0) return Unknown();
		if (rt == 3) return HeadlessOn() ? Unknown() : 99.0;
		double r = BdHeadZ(f) / BdHeight(f);
		// a hitbox family's head is BD's box ABOVE the body box (the baron's starts at its top, 60 of 60): on a body that
		// carries our sensor it stays there; on a body with no sensor (a ColorfulHell or MeatGrinder baron) the top tenth
		if (rt == 2 && r > 0.9 && !HasSensor(v)) r = 0.9;
		return r;
	}
	double LegHi(int f)
	{
		double l = BdLegZ(f);
		return l > 0 ? l / BdHeight(f) : -1;
	}

	// ---------------------------------------------------------------- who is judged
	Array<Actor> sensors;     // our head sensors alive
	Array<Actor> keptHb;      // BD hitboxes we leave alone (slumped / dying bodies): their masters keep BD's own check
	bool HasSensor(Actor v)
	{
		for (int i = 0; i < sensors.Size(); i++) if (sensors[i] && sensors[i].master == v) return true;
		return false;
	}
	bool Kept(Actor v)
	{
		for (int i = 0; i < keptHb.Size(); i++) if (keptHb[i] && keptHb[i].master == v) return true;
		return false;
	}
	bool InScope(Actor v)
	{
		if (!v || !v.bIsMonster || v.player) return false;
		if (v is "RS_ScoreHeadSensor") return false;
		Classes();
		if (cHitbox && v is cHitbox) return false;
		return !Kept(v);
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a) return;
		Classes();
		if (cHitbox && a is cHitbox) keptHb.Push(a);
		else if (a is "RS_ScoreHeadSensor") sensors.Push(a);
	}

	// ---------------------------------------------------------------- the verdict (pure: no side effects)
	// hitZ, frac, fam, lo: what it was judged on (for the log); the verdict: HV_HEAD / HV_BODY / HV_LEG
	int Judge(Actor v, Actor inf, int flags, out double hitZ, out double frac, out int fam, out double lo)
	{
		hitZ = 0; frac = -1; lo = 0;
		fam = FamilyOf(v);
		// no hit point: an explosion, the monster's own blow, a body, a weapon item (a punch's glove): never a head
		if (!inf || inf == v || inf.player || (flags & DMG_EXPLOSION) || !(inf.bIsPuff || inf.bMissile)) return HV_BODY;
		Classes();
		if ((cIsDown && v.FindInventory(cIsDown)) || (cIsCrouching && v.FindInventory(cIsCrouching))) return HV_BODY;
		double h = v.height;
		if (h <= 0) return HV_BODY;
		hitZ = inf.bMissile ? inf.pos.z + inf.height * 0.5 : inf.pos.z;
		hitZ = clamp(hitZ, v.pos.z, v.pos.z + h);
		frac = (hitZ - v.pos.z) / h;
		lo = HeadLo(v, fam);
		if (frac >= lo) return HV_HEAD;
		double leg = LegHi(fam);
		if (leg > 0 && frac < leg) return HV_LEG;
		return HV_BODY;
	}

	// ---------------------------------------------------------------- stamps: this tic's verdicts, per blow
	Array<Actor> stV, stInf, stSrc;
	Array<int> stTic, stVerdict;
	Array<double> stFrac;
	void Stamp(Actor v, Actor inf, Actor src, int verdict, double frac)
	{
		if (stV.Size() >= 256) { stV.Delete(0); stInf.Delete(0); stSrc.Delete(0); stTic.Delete(0); stVerdict.Delete(0); stFrac.Delete(0); }
		stV.Push(v); stInf.Push(inf); stSrc.Push(src); stTic.Push(level.maptime); stVerdict.Push(verdict); stFrac.Push(frac);
	}
	// the verdict of THIS blow (the ledger asks while the blow's own event runs): -2 not judged
	int VerdictOf(Actor v, Actor inf)
	{
		for (int k = stV.Size() - 1; k >= 0; k--)
		{
			if (stTic[k] != level.maptime) break;
			if (stV[k] == v && stInf[k] == inf) return stVerdict[k];
		}
		return -2;
	}
	// the newest verdict on this monster, this tic or the last (bloods, services): -2 none
	int Latest(Actor v)
	{
		for (int k = stV.Size() - 1; k >= 0; k--)
		{
			if (stTic[k] < level.maptime - 1) break;
			if (stV[k] == v) return stVerdict[k];
		}
		return -2;
	}

	override void WorldTick()
	{
		int keep = 0;
		while (keep < stTic.Size() && stTic[keep] < level.maptime - 2) keep++;
		if (keep > 0) { stV.Delete(0, keep); stInf.Delete(0, keep); stSrc.Delete(0, keep); stTic.Delete(0, keep); stVerdict.Delete(0, keep); stFrac.Delete(0, keep); }
		if ((level.maptime % 35) == 0)
		{
			for (int i = sensors.Size() - 1; i >= 0; i--) if (!sensors[i]) sensors.Delete(i);
			for (int i = keptHb.Size() - 1; i >= 0; i--) if (!keptHb[i]) keptHb.Delete(i);
		}
	}

	// ---------------------------------------------------------------- at the blow
	int busy;            // > 0 while our own bonus blow is being dealt (its events are not blows of their own)
	bool sensorBlow;     // the blow now landing came through a head sensor (already a head, its outcome applied)
	bool IsOwnBlow() { return busy > 0; }

	override void WorldThingDamaged(WorldEvent e)
	{
		if (busy > 0) return;
		let v = e.Thing;
		if (!InScope(v) || !On()) return;
		let inf = e.Inflictor, src = e.DamageSource;
		double hz, fr, lo; int fam;
		int verdict;
		String route;
		if (sensorBlow)
		{
			fam = FamilyOf(v); lo = HeadLo(v, fam);
			hz = inf ? inf.pos.z : v.pos.z + v.height; fr = v.height > 0 ? (hz - v.pos.z) / v.height : 1;
			verdict = HV_HEAD;
			route = "sensor";
		}
		else
		{
			verdict = Judge(v, inf, e.DamageFlags, hz, fr, fam, lo);
			route = Route(fam) == 1 ? "blood" : (HasSensor(v) ? "body+sensor" : "body");
		}
		Stamp(v, inf, src, verdict, fr);
		bool log = LogOn();
		String line;
		if (log)
		{
			let d = GetDefaultByType(v.GetClass());
			String sn = "none";
			if (src && src.player) sn = "player"; else if (src) sn = src.GetClassName();
			line = String.Format("HS t%d %s fam %s H %.1f (def %.1f) R %.1f scale %.2f feet %.1f floor %.1f hit %.1f up %.1f frac %.3f lo %.3f verdict %s dt %s src %s route %s",
				level.maptime, v.GetClassName(), FamName(fam), v.height, d.height, v.radius, d.scale.y != 0 ? v.scale.y / d.scale.y : 1.0,
				v.pos.z, v.floorz, hz, hz - v.pos.z, fr, lo, VName(verdict), e.DamageType, sn, route);
			if (v.health > 0 && d.height > 0 && d.scale.y != 0 && abs((v.scale.y / d.scale.y) - (v.height / d.height)) > 0.1)
				Console.Printf("HS warning: %s is drawn %.2fx but its box is %.2fx (bullets meet the box, not the picture)", v.GetClassName(), v.scale.y / d.scale.y, v.height / d.height);
		}
		int bonus = 0;
		bool tokens = false;
		if (!sensorBlow)
		{
			[bonus, tokens] = Outcome(v, inf, src, verdict, fam, e.Damage, e.DamageFlags);
		}
		if (log) Console.Printf("%s bonus %d (after the blow) tokens %d hp %d", line, bonus, tokens, v.health);
	}
	static String VName(int v) { return v == HV_HEAD ? "HEAD" : (v == HV_LEG ? "leg" : (v == HV_BODY ? "body" : "none")); }

	// BD's outcome, from our verdict: its tokens, its head damage. Returns the bonus dealt and whether tokens were set.
	int, bool Outcome(Actor v, Actor inf, Actor src, int verdict, int fam, int dealt, int flags)
	{
		Classes();
		// a saw / axe: BD's own saw bloods keep their check (and deal no Head damage); likewise a body on Blood_Bones
		bool axe = src && src.player && src.player.ReadyWeapon && src.player.ReadyWeapon.bAxeBlood && !(inf && inf.bMissile);
		if (axe) return 0, false;
		if (cKeptBlood && v.GetBloodType(0) == cKeptBlood) return 0, false;
		// BD's tokens, as its bloods set them (BloodTypesMonsters.dec: HeadShot / LegShot / neither)
		if (verdict == HV_HEAD)
		{
			if (cHitLeg) v.TakeInventory(cHitLeg, 0x7FFFFFFF);
			if (cHitHead) v.GiveInventory(cHitHead, 1);
		}
		else if (verdict == HV_LEG)
		{
			if (cHitHead) v.TakeInventory(cHitHead, 0x7FFFFFFF);
			if (cHitLeg) v.GiveInventory(cHitLeg, 1);
		}
		else
		{
			if (cHitHead) v.TakeInventory(cHitHead, 0x7FFFFFFF);
			if (cHitLeg) v.TakeInventory(cHitLeg, 0x7FFFFFFF);
		}
		if (verdict != HV_HEAD || !BonusOn() || v.health <= 0) return 0, true;
		// BD's head damage: ACS Head_Shot's +30 Head on its blood families; its hitbox's "health lost x2" on the big ones
		// (the blow again); a family BD gives no numbers: whichever is more
		int rt = Route(fam);
		int amt = rt == 1 ? 30 : (rt == 2 ? dealt : max(30, dealt));
		if (amt <= 0) return 0, true;
		// dealt by RS_ScoreHeadLate, AFTER every other handler has heard this blow (the combo ledger above all): a head
		// bonus that kills scores the kill, and the kill must find this blow's +head already in the ledger
		pV = v; pInf = inf; pSrc = src; pAmt = amt; pFlags = DMG_THRUSTLESS | (flags & DMG_INFLICTOR_IS_PUFF); pTic = level.maptime; pOn = true;
		return amt, true;
	}

	// the head bonus waiting for the end of its blow's event (RS_ScoreHeadLate)
	Actor pV, pInf, pSrc;
	int pAmt, pFlags, pTic;
	bool pOn;
	void DealPending(Actor v, Actor inf)
	{
		if (!pOn || pV != v || pInf != inf || pTic != level.maptime) return;
		pOn = false;
		if (!v || v.health <= 0) return;
		busy++;
		v.DamageMobj(pInf, pSrc, pAmt, 'Head', pFlags);
		busy--;
	}

	// A blow that met one of our head sensors: BD's hitbox outcome (HeadshotHandler: health lost x2, typed as its pain
	// states type it), from the player, through the monster's own DamageMobj.
	void SensorHit(Actor sensor, Actor m, Actor inf, Actor src, int amount, Name mod, int flags)
	{
		Classes();
		if (cHitLeg) m.TakeInventory(cHitLeg, 0x7FFFFFFF);
		if (cHitHead) m.GiveInventory(cHitHead, 1);
		if (LogOn())
			Console.Printf("HS t%d sensor %s on %s (H %.1f) box r %.1f h %.1f at up %.1f: %d x2 = %d as %s", level.maptime, sensor.GetClassName(),
				m.GetClassName(), m.height, sensor.radius, sensor.height, sensor.pos.z - m.pos.z, amount / 2, amount, mod);
		sensorBlow = true;
		m.DamageMobj(inf, src, amount, mod, flags | DMG_THRUSTLESS);
		sensorBlow = false;
	}

	// ---------------------------------------------------------------- for the bloods and the service
	// 1 head, 0 not, -1 the check is off or this monster is not judged
	int Answer(Actor v)
	{
		if (!On() || !InScope(v)) return -1;
		int r = Latest(v);
		return r == HV_HEAD ? 1 : 0;
	}
}

// The head bonus of a blow, dealt after every other handler has heard that blow (Order 1000; RS_ScoreHead.Outcome).
class RS_ScoreHeadLate : EventHandler
{
	override void OnRegister() { SetOrder(1000); }
	override void WorldThingDamaged(WorldEvent e)
	{
		let h = RS_ScoreHead.Get();
		if (h && h.pOn) h.DealPending(e.Thing, e.Inflictor);
	}
}

// ============================================================================
// BD's head-checking bloods, copied by name (brutal22test6 actors/Gore/BloodTypesMonsters.dec). The same flags and the
// same first three states (the engine starts a blood 1 or 2 states in for small damage: p_mobj.cpp P_SpawnBlood), so a
// copy behaves as BD's own. A copy whose blow was judged does nothing more: the verdict already set BD's tokens and
// dealt BD's head damage. A copy with no judged blow runs BD's fixed check.
// ============================================================================
class RS_ScoreHeadBlood : Actor
{
	Default
	{
		RenderStyle "Translucent";
		+FORCEXYBILLBOARD
		+NOBLOCKMAP
		+NOGRAVITY
		+NOCLIP
		+PUFFONACTORS
		+PUFFGETSOWNER
		+NODAMAGETHRUST
		Speed 0;
		Scale 0.3;
		Mass 999999;
		Species "Blood";
		DamageType "Head";
	}
	virtual String GoreName() { return "Brutal_Blood"; }
	virtual double HeadUp()   { return 46; }
	virtual double LegUp()    { return 25; }    // -1: no leg check
	virtual bool AcsAlways()  { return false; } // BD's Noble / Fatso line uses ACS_NamedExecuteAlways

	action void RSH_Gore()
	{
		String n = invoker.GoreName();
		class<Actor> c = n;
		if (c) A_SpawnItem(c);
	}
	action state RSH_Decide()
	{
		let h = RS_ScoreHead.Get();
		if (h && target && h.Answer(target) >= 0 && h.Latest(target) > -2)
		{
			if (h.LogOn()) Console.Printf("HS t%d blood %s on %s: verdict already applied (BD's own check skipped)", level.maptime, invoker.GetClassName(), target.GetClassName());
			return null;
		}
		double up = pos.z - floorz;
		if (h && h.LogOn() && target) Console.Printf("HS t%d blood %s on %s: no judged blow, BD's own check (z - floorz %.1f)", level.maptime, invoker.GetClassName(), target.GetClassName(), up);
		if (up > invoker.HeadUp()) return ResolveState("BDHead");
		if (invoker.LegUp() >= 0 && up < invoker.LegUp()) return ResolveState("BDLeg");
		invoker.Tok("HitHead", false);
		if (invoker.LegUp() >= 0) invoker.Tok("HitLeg", false);
		return null;
	}
	void Tok(String n, bool give)
	{
		class<Inventory> c = n;
		if (!c || !target) return;
		if (give) target.GiveInventory(c, 1); else target.TakeInventory(c, 0x7FFFFFFF);
	}
	action void RSH_BDHead()
	{
		invoker.Tok("HitLeg", false);
		invoker.Tok("HitHead", true);
		if (invoker.AcsAlways()) ACS_NamedExecuteAlways("Head_Shot");
		else ACS_NamedExecuteWithResult("Head_Shot");
	}
	action void RSH_BDLeg()
	{
		invoker.Tok("HitHead", false);
		invoker.Tok("HitLeg", true);
	}
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_FaceTarget;
		TNT1 A 0 RSH_Gore;
		TNT1 A 0 RSH_Decide;
		Stop;
	BDHead:
		TNT1 A 0 A_FaceTarget;
		TNT1 A 0 RSH_BDHead;
		TNT1 A 2;
		Stop;
	BDLeg:
		TNT1 A 0 A_FaceTarget;
		TNT1 A 0 RSH_BDLeg;
		TNT1 A 2;
		Stop;
	}
}
class RS_ScoreHB_Imp : RS_ScoreHeadBlood {}
class RS_ScoreHB_Zombies : RS_ScoreHeadBlood {}
class RS_ScoreHB_Comando : RS_ScoreHeadBlood { override double HeadUp() { return 50; } override double LegUp() { return -1; } }
class RS_ScoreHB_SitZ : RS_ScoreHeadBlood { override double HeadUp() { return 21; } }
class RS_ScoreHB_BWSS : RS_ScoreHeadBlood { override double HeadUp() { return 43; } }
class RS_ScoreHB_Noble : RS_ScoreHeadBlood
{
	override String GoreName() { return "Green_Blood"; }
	override double HeadUp() { return 54; }
	override bool AcsAlways() { return true; }
}
class RS_ScoreHB_Fatso : RS_ScoreHeadBlood { override double HeadUp() { return 54; } override bool AcsAlways() { return true; } }
class RS_ScoreHB_Archie : RS_ScoreHeadBlood { override double HeadUp() { return 56; } override bool AcsAlways() { return true; } }
class RS_ScoreHB_Cybie : RS_ScoreHeadBlood { override double HeadUp() { return 96; } override bool AcsAlways() { return true; } }

// ============================================================================
// BD's head hitboxes, as sensors (brutal22test6 actors/MISC/Head_Sys.dec 617-1000). The same place (its A_Warp: forward
// along the monster's facing, up from its feet), the same size and damage factors, all scaled by the monster's current
// Height over its class's own (owner 11-09: a 1.25x monster's hitbox scales with it). A sensor takes no damage itself:
// what BD's HeadshotHandler would have dealt (the health it lost x2) goes to the monster, from the player
// (RS_ScoreHead.SensorHit). It goes when its monster does (BD's: when the master is no longer SHOOTABLE).
// ============================================================================
class RS_ScoreHeadSensor : Actor
{
	double sFwd, sUp, sR, sH;
	bool checked;
	Default
	{
		Health 9999;
		Mass 999999;
		Radius 7;
		Height 18;
		PainChance 0;
		BloodType "Brutal_Blood", "SawBlood", "SawBlood";
		+SHOOTABLE
		+NOGRAVITY
		+NOCLIP
		+NODAMAGETHRUST
		+NOTARGET
		+NOTAUTOAIMED
		+NOTELEPORT
		+NORADIUSDMG
		+NEVERTARGET
		+DONTTHRUST
		-SOLID
		-COUNTKILL
		// HeadHitbox's own factors (Head_Sys.dec:624-635)
		DamageFactor "Taunt", 0.0; DamageFactor "Blood", 0.0; DamageFactor "BlueBlood", 0.0; DamageFactor "KillMe", 0.0;
		DamageFactor "Control", 0.0; DamageFactor "Trample", 0.0; DamageFactor "GibRemoving", 0.0; DamageFactor "Alert", 0.0;
		DamageFactor "use", 0.0; DamageFactor "TeleportRemover", 0.0; DamageFactor "Fire", 0.0; DamageFactor "Stealth", 0.0;
		DamageFactor "Saw", 3.0; DamageFactor "Cut", 3.0; DamageFactor "Minigun", 2.0; DamageFactor "Shotgun", 1.5;
		DamageFactor "SSG", 5.0; DamageFactor "ExplosiveImpact", 5.0; DamageFactor "Sniper", 5.0; DamageFactor "Railgun", 2.0;
	}
	virtual void Dims() { sFwd = 0; sUp = 50; sR = 7; sH = 18; }

	static double ScaleOf(Actor m)
	{
		let d = GetDefaultByType(m.GetClass());
		return (d && d.height > 0) ? max(0.1, m.height / d.height) : 1.0;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		Dims();
	}

	// its own monster's missiles (and the monster) pass through it
	override bool CanCollideWith(Actor other, bool passive)
	{
		if (master && (other == master || other.target == master)) return false;
		return true;
	}

	override void Tick()
	{
		let m = master;
		if (!m)
		{
			// BD sets the master just after the spawn; give it the tic it was born on
			if (GetAge() > 1) Destroy();
			return;
		}
		if (m.health <= 0 || !m.bShootable) { Destroy(); return; }
		if (!checked)
		{
			checked = true;
			// one head per monster: BD respawns its hitbox when the monster re-enters some states
			let it = ThinkerIterator.Create("RS_ScoreHeadSensor");
			RS_ScoreHeadSensor o;
			while (o = RS_ScoreHeadSensor(it.Next())) if (o != self && o.master == m && o.checked) { Destroy(); return; }
		}
		double s = ScaleOf(m);
		if (abs(radius - sR * s) > 0.01 || abs(height - sH * s) > 0.01) A_SetSize(sR * s, sH * s);
		SetOrigin(m.Vec3Angle(sFwd * s, m.angle, sUp * s), true);
	}

	// BD's HeadHitbox pain states type the master's damage by the blow (Head_Sys.dec:653-711)
	static Name HbType(Name mod)
	{
		if (mod == 'Saw' || mod == 'Cut') return 'decaptate';
		if (mod == 'Fire') return 'fire';
		if (mod == 'Plasma') return 'plasma';
		if (mod == 'Explosive' || mod == 'ExplosiveImpact') return 'ExplosiveImpact';
		return 'head';
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		let m = master;
		if (!m || m.health <= 0 || damage <= 0) return 0;
		if (source == m) return 0;
		int d = (flags & DMG_NO_FACTOR) ? damage : ApplyDamageFactor(mod, damage);
		if (d <= 0) return 0;
		let h = RS_ScoreHead.Get();
		if (h) h.SensorHit(self, m, inflictor, source, d * 2, HbType(mod), flags);
		else m.DamageMobj(inflictor, source, d * 2, HbType(mod), flags | DMG_THRUSTLESS);
		return 0;
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}
}
class RS_ScoreHS_Baron : RS_ScoreHeadSensor
{
	Default { BloodType "Green_Blood", "GreenSawBlood", "GreenSawBlood"; BloodColor "DarkGreen"; +DONTRIP }
	override void Dims() { sFwd = 10; sUp = 60; sR = 18; sH = 24; }
}
class RS_ScoreHS_Knight : RS_ScoreHS_Baron { override void Dims() { sFwd = 10; sUp = 56; sR = 18; sH = 24; } }
class RS_ScoreHS_Boss : RS_ScoreHS_Baron   { override void Dims() { sFwd = 10; sUp = 72; sR = 18; sH = 24; } }
class RS_ScoreHS_Vile : RS_ScoreHeadSensor { override void Dims() { sFwd = 16; sUp = 58; sR = 16; sH = 20; } }
class RS_ScoreHS_Mancu : RS_ScoreHeadSensor
{
	Default { +DONTRIP }
	override void Dims() { sFwd = 2; sUp = 56; sR = 12; sH = 16; }
}
class RS_ScoreHS_Bones : RS_ScoreHeadSensor
{
	Default { BloodType "Bone_Dust"; +DONTRIP DamageFactor "RVFT", 0.0; }
	override void Dims() { sFwd = 16; sUp = 56; sR = 7; sH = 18; }
}
class RS_ScoreHS_Cyber : RS_ScoreHeadSensor
{
	Default { DamageFactor "Stomp", 0.0; }
	override void Dims() { sFwd = 2; sUp = 98; sR = 32; sH = 24; }
}
