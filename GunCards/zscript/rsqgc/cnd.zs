// cnd.zs -- RSQ Gun Cards: WEAPON CONDITION (design/WEAPON_CONDITION.md, owner 2026-11-16 04:55-05:08). OFF by default
// (Weapon Condition, rsqgc_cnd). One Series layer for every gun of every pack (BD22 VR Reloaded, GNRC, WoS, any mod's
// guns), with or without LegenDoom: it knows a gun by its class, and asks nothing of the gun.
//
//   CONDITION     0-100 a gun (by its class: BD22 VR's off-hand copy RSQ_Off_<gun> is a gun of its own), kept on the player
//                 (RSQGC_CndBook, saved, carried across maps). A gun first seen starts at 100.
//   WEAR          ONLY A BIG HIT: one blow of more than Big Hit Over (20) damage to the player takes Wear per Big Hit (3)
//                 off the gun in each hand. Shooting never wears a gun.
//   REPAIR        RSQ VisualRewards' steel bits (Kill Rewards) +1 a bit to each held gun, and the Boss kiosk (RSQ Miniboss)
//                 repairs every gun he carries fully for gold. Both ask this file by name (RSQGC_Service, below).
//   THE CURVE     the owner's earlier weapon base (its HF_CndGetModifiers / HF_CndApplyModifiers): five profiles chosen by
//                 the gun's kind (Profile), the Workhorse band table as the anchor. Under 30 THE WILD FLIP: more damage,
//                 pellets, rate; accuracy collapses; backfire and misfire hurt the player.
//   DAMAGE        ON HIT: the player's damage is scaled by the gun that fired it (RSQGC_CndBook.ModifyDamage), so bullets,
//                 pellets, rockets, plasma and their blasts all count. Which gun: a hitscan or rail by its hand (the
//                 engine's LAF_ISOFFHAND / RGF_ISOFFHAND on WorldHitscanPreFired / WorldRailgunPreFired); a missile by
//                 the hand it was born at (BD22 VR's muzzle.zs Born test) with that hand's trigger down, recorded at its
//                 spawn; a missile a recorded missile makes as it bursts (a rocket's fragments) inherits its gun. Melee
//                 damage types and anything unrecorded are left alone (it fails closed).
//   RATE          where possible: while a hand's trigger is held and its gun is not in its Ready state, the gun's layer
//                 tics are stretched or shortened (an accumulator: a fire sequence of T tics takes T / rate). A frame of
//                 1 tic cannot be shortened, so the fastest guns gain less. Fire Rate Follows Condition, on.
//   ACCURACY      needs the gun's own spread: a weapon set asks by name (GetDouble "cnd.spread", below) and widens its
//                 own spread by the answer. BD22 VR Reloaded does (its muzzle.zs). A gun without it gets damage, rate,
//                 backfire and misfire. Pellets: GetInt "cnd.pellets" / GetDouble "cnd.pelletmul" (the hook for later).
//   BACKFIRE /    rolled once a tic a hand fired (a shot); a small chip (1-5, armour ignored) or a bigger self-hit
//   MISFIRE       (4-12; an Overheat gun's overload 8-20), neither lethal by itself (my reading for the misfire), with a
//                 sound and a toast (RSQ VisualRewards' "toast", by name), never a centre print. At most one a second a hand.
//   AT 0          Lose the Gun at 0 (off): a gun worn to 0 breaks and is taken; off, it stays at its worst band.
//   SHOWN         a CND row with a bar on the gun's watch card (side.zs) and the world card (worldcard.zs).
//   THE LOG       Condition Log (rsqgc_cnd_log): every big hit and what it wore, every scaled hit, every shot's band,
//                 backfire, misfire, repair. Test (sv_cheats): netevent rsqgc_cnd_set <0..100> [0 both, 1 main, 2 off];
//                 netevent rsqgc_cnd_hit <damage> (a blow from nobody, through the big-hit rule).
// Rig only, not headset-confirmed.

class RSQGC_Cnd play
{
	enum EProfile { P_WORKHORSE, P_BRUISER, P_PRECISION, P_OVERHEAT, P_VOLATILE }

	static clearscope int CI(Name n, int f) { let c = CVar.FindCVar(n); return c ? c.GetInt() : f; }
	static clearscope bool On() { return CI('rsqgc_cnd', 0) != 0; }
	static clearscope bool LogOn() { return CI('rsqgc_cnd_log', 0) != 0; }

	static clearscope String ProfileName(int p)
	{
		static const String N[] = { "Workhorse", "Bruiser", "Precision", "Overheat", "Volatile" };
		return N[clamp(p, 0, 4)];
	}

	// A GUN: a weapon that uses ammo and is not a melee weapon, a tool or a thrown grenade (those keep no condition).
	// BY WHOLE WORDS OF ITS CLASS NAME (GC5, 2026-11-16; was any part of the name, so "saw" took a "SawedOff" and "flare" a
	// "Flaregun"): the name is cut at underscores, digits and lower-to-upper case changes (Chain_saw: chain saw; BrutalAxe:
	// brutal axe; RSQGN_Frag: rsqgn frag), and a word must be one of these, or that word plus "s" / "es".
	static clearscope void NameWords(String n, out Array<String> words)
	{
		words.Clear();
		String cur = "";
		int prev = 0;
		for (int i = 0; i < int(n.Length()); i++)
		{
			int ch = n.ByteAt(i);
			bool up = ch >= 65 && ch <= 90, lo = ch >= 97 && ch <= 122;
			bool cut = !(up || lo) || (up && prev >= 97 && prev <= 122);
			if (cut && cur != "") { words.Push(cur.MakeLower()); cur = ""; }
			if (up || lo) cur.AppendCharacter(ch);
			prev = ch;
		}
		if (cur != "") words.Push(cur.MakeLower());
	}
	static clearscope bool HasWord(Array<String> words, String t)
	{
		for (int i = 0; i < words.Size(); i++) { String w = words[i]; if (w == t || w == t .. "s" || w == t .. "es") return true; }
		return false;
	}
	static clearscope bool IsGun(Weapon w)
	{
		if (!w || w.bMeleeWeapon) return false;
		if (!w.AmmoType1 && !w.AmmoType2) return false;
		static const String NOTGUN[] = { "axe", "saw", "chainsaw", "saber", "sabre", "lightsaber", "fist", "knife", "knive", "melee",
			"whip", "punch", "glove", "flare", "torch", "cigar", "cigarette", "rsqgn", "grapple", "hook", "shield", "shieldsaw" };
		Array<String> words;
		NameWords(w.GetClassName(), words);
		for (int i = 0; i < NOTGUN.Size(); i++) if (HasWord(words, NOTGUN[i])) return false;
		if (HasWord(words, "grenade") && !HasWord(words, "launcher")) return false;
		return true;
	}

	// THE PROFILE, by the gun's kind (design/WEAPON_CONDITION.md "The curve"): its name first, then its ammo
	static clearscope int Profile(Weapon w)
	{
		if (!w) return P_WORKHORSE;
		String n = w.GetClassName();
		n = n.MakeLower();
		static const String PREC[] = { "rail", "sniper", "revolver", "ruger", "magnum", "marksman", "deagle" };
		static const String BRUI[] = { "shot", "ssg", "minigun", "chaingun", "mg42", "machinegun", "gatling", "vulcan", "auto5" };
		static const String VOLA[] = { "rocket", "grenade", "missile", "nuke", "launcher", "m202", "bazooka", "incendiary", "devastator" };
		static const String OVER[] = { "plasma", "bfg", "big_fucking", "unmaker", "flame", "laser", "lightning", "tesla", "cell" };
		for (int i = 0; i < PREC.Size(); i++) if (n.IndexOf(PREC[i]) >= 0) return P_PRECISION;
		for (int i = 0; i < BRUI.Size(); i++) if (n.IndexOf(BRUI[i]) >= 0) return P_BRUISER;
		for (int i = 0; i < VOLA.Size(); i++) if (n.IndexOf(VOLA[i]) >= 0) return P_VOLATILE;
		for (int i = 0; i < OVER.Size(); i++) if (n.IndexOf(OVER[i]) >= 0) return P_OVERHEAT;
		String a = "";
		if (w.AmmoType1) a = w.AmmoType1.GetClassName();
		else if (w.AmmoType2) a = w.AmmoType2.GetClassName();
		a = a.MakeLower();
		if (a.IndexOf("shell") >= 0) return P_BRUISER;
		if (a.IndexOf("rocket") >= 0) return P_VOLATILE;
		if (a.IndexOf("cell") >= 0) return P_OVERHEAT;
		return P_WORKHORSE;
	}

	// THE CURVE (the owner's HF_CndGetModifiers, its numbers as they are). acc: spread x (higher is worse); dmg: damage x;
	// rate: x (> 1 faster); pMul / pAdd: pellets (spread guns only); bk / mf: backfire / misfire chance a shot.
	static clearscope double, double, double, double, int, double, double Curve(int prof, int c)
	{
		double acc = 1, dmg = 1, rate = 1, pMul = 1, bk = 0, mf = 0;
		int pAdd = 0;
		c = clamp(c, 0, 100);
		if (prof == P_BRUISER)
		{
			if      (c >= 90) { }
			else if (c >= 80) { acc = 1.025; }
			else if (c >= 70) { acc = 1.06;  dmg = 0.95; }
			else if (c >= 60) { acc = 1.075; dmg = 0.90; rate = 0.85; }
			else if (c >= 50) { acc = 1.10;  dmg = 0.90; rate = 0.67; bk = 0.005; }
			else if (c >= 40) { acc = 1.15;  dmg = 1.10; rate = 0.70; pMul = 1.0; pAdd = 1; bk = 0.01; }
			else if (c >= 30) { acc = 1.225; dmg = 1.20; rate = 1.05; pMul = 1.2; pAdd = 1; bk = 0.015; }
			else if (c >= 20) { acc = 1.25;  dmg = 1.40; rate = 1.20; pMul = 1.4; pAdd = 2; bk = 0.02;  mf = 0.005; }
			else if (c >= 10) { acc = 1.40;  dmg = 1.60; rate = 1.20; pMul = 1.8; pAdd = 3; bk = 0.025; mf = 0.01; }
			else              { acc = 1.45;  dmg = 1.90; rate = 1.25; pMul = 2.2; pAdd = 4; bk = 0.035; mf = 0.02; }
		}
		else if (prof == P_PRECISION)
		{
			if      (c >= 90) { }
			else if (c >= 80) { acc = 1.10; }
			else if (c >= 70) { acc = 1.24; dmg = 0.95; }
			else if (c >= 60) { acc = 1.30; dmg = 0.90; rate = 0.85; }
			else if (c >= 50) { acc = 1.40; dmg = 0.90; rate = 0.67; bk = 0.005; }
			else if (c >= 40) { acc = 1.60; dmg = 0.95; rate = 0.70; bk = 0.01; }
			else if (c >= 30) { acc = 1.90; dmg = 1.00; rate = 1.05; bk = 0.015; }
			else if (c >= 20) { acc = 2.00; dmg = 1.05; rate = 1.20; bk = 0.02;  mf = 0.005; }
			else if (c >= 10) { acc = 2.60; dmg = 1.08; rate = 1.20; bk = 0.025; mf = 0.01; }
			else              { acc = 2.80; dmg = 1.10; rate = 1.25; bk = 0.035; mf = 0.02; }
		}
		else
		{
			// WORKHORSE (the anchor), OVERHEAT (the same ramp, no backfire, no pellets: its misfire is an overload) and
			// VOLATILE (as Workhorse; blast radius to scale with condition later)
			if      (c >= 90) { }
			else if (c >= 80) { acc = 1.05; }
			else if (c >= 70) { acc = 1.12; dmg = 0.90; }
			else if (c >= 60) { acc = 1.15; dmg = 0.85; rate = 0.85; }
			else if (c >= 50) { acc = 1.20; dmg = 0.80; rate = 0.67; bk = 0.01; }
			else if (c >= 40) { acc = 1.30; dmg = 0.70; rate = 0.70; bk = 0.02; }
			else if (c >= 30) { acc = 1.45; dmg = 0.60; rate = 1.05; bk = 0.03; }
			else if (c >= 20) { acc = 1.50; dmg = 1.20; rate = 1.20; pMul = 1.4; pAdd = 1; bk = 0.04; mf = 0.005; }
			else if (c >= 10) { acc = 1.80; dmg = 1.50; rate = 1.20; pMul = 1.8; pAdd = 2; bk = 0.05; mf = 0.01; }
			else              { acc = 1.90; dmg = 1.80; rate = 1.25; pMul = 2.2; pAdd = 3; bk = 0.07; mf = 0.02; }
			if (prof == P_OVERHEAT) { bk = 0; pMul = 1; pAdd = 0; }
		}
		return acc, dmg, rate, pMul, pAdd, bk, mf;
	}

	// the band's lower edge (90, 80 ... 10, 0), for the log and the card's colour
	static clearscope int Band(int c) { c = clamp(c, 0, 100); return c >= 90 ? 90 : (c >= 10 ? c / 10 * 10 : 0); }
	// the card's colour: green, lime, yellow, orange, red (the flip)
	static clearscope int Colour(int c)
	{
		if (c >= 90) return 0x80E040;
		if (c >= 70) return 0xC8E040;
		if (c >= 50) return 0xF0D040;
		if (c >= 30) return 0xF08030;
		return 0xFF5040;
	}

	// the condition of the gun w (held or carried by its owner): -1 when the system is off or w is not a gun
	static clearscope int Of(Weapon w)
	{
		if (!On() || !IsGun(w) || !w.owner) return -1;
		let b = RSQGC_CndBook(w.owner.FindInventory("RSQGC_CndBook"));
		return b ? b.Get(w.GetClassName()) : 100;
	}

	// what the gun's card shows: its condition, -1 for no row (off, Condition on Card off, not a gun)
	static clearscope int CardValue(Weapon w) { return CI('rsqgc_cnd_bar', 1) ? Of(w) : -1; }
	// the card's bar: n units of '=' worn down to '-' (the Gun Bonsai row's look)
	static clearscope String Bar(int c, int units)
	{
		int on = int(ceil(clamp(c, 0, 100) * units / 100.0));
		String b = "";
		for (int i = 0; i < units; i++) b = b .. (i < on ? "=" : "-");
		return b;
	}

	static Service Svc(String n)
	{
		let it = ServiceIterator.Find(n);
		Service s;
		while (s = it.Next()) if (s.GetClassName() == n) return s;
		return null;
	}
	// a toast (RSQ VisualRewards' "toast", by name): never a centre print (no VisualRewards: the sound alone)
	static void Toast(Actor pmo, String kindText)
	{
		let vr = Svc("RSQVR_Service");
		if (vr && pmo) vr.GetInt("toast", kindText, 0, 0, pmo);
	}
}

// THE BOOK: every gun's condition, on the player (saved with him, carried across maps)
class RSQGC_CndBook : Inventory
{
	Array<String> cls;
	Array<int> cnd;

	Default
	{
		Inventory.MaxAmount 1;
		Inventory.InterHubAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.QUIET
		+INVENTORY.KEEPDEPLETED
		-COUNTITEM
	}
	States { Spawn: TNT1 A -1; Stop; }

	static RSQGC_CndBook Of(Actor a, bool make = false)
	{
		if (!a || !a.player) return null;
		let b = RSQGC_CndBook(a.FindInventory("RSQGC_CndBook"));
		if (!b && make) { a.GiveInventory("RSQGC_CndBook", 1); b = RSQGC_CndBook(a.FindInventory("RSQGC_CndBook")); }
		return b;
	}

	clearscope int Get(String c)
	{
		int i = cls.Find(c);
		return i < cls.Size() ? cnd[i] : 100;
	}
	void Set(String c, int v)
	{
		v = clamp(v, 0, 100);
		int i = cls.Find(c);
		if (i < cls.Size()) cnd[i] = v;
		else { cls.Push(c); cnd.Push(v); }
	}
	void Forget(String c)
	{
		int i = cls.Find(c);
		if (i < cls.Size()) { cls.Delete(i); cnd.Delete(i); }
	}

	// THE DAMAGE ON HIT (active: the owner dealt it; `source` is then the one hit). The gun that fired it scales it.
	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		if (passive || damage <= 0 || !owner || !owner.player || source == owner || !RSQGC_Cnd.On()) return;
		let h = RSQGC_CndHandler.Get();
		if (!h) return;
		String gun = h.GunFor(owner, inflictor, damageType);
		if (gun == "") return;
		class<Weapon> wc = gun;
		let w = wc ? Weapon(owner.FindInventory(wc)) : null;
		int c = Get(gun);
		int prof = w ? RSQGC_Cnd.Profile(w) : RSQGC_Cnd.P_WORKHORSE;
		double acc, dmg, rate, pMul, bk, mf; int pAdd;
		[acc, dmg, rate, pMul, pAdd, bk, mf] = RSQGC_Cnd.Curve(prof, c);
		if (dmg == 1.0) return;
		int nd = max(1, int(round(damage * dmg)));
		if (RSQGC_Cnd.LogOn())
			Console.Printf("RSQGC cnd t%d: hit %s with %s (cnd %d, %s, band %d): x%.2f %d -> %d (%s)", level.maptime,
				source ? source.GetClassName() : 'nothing', gun, c, RSQGC_Cnd.ProfileName(prof), RSQGC_Cnd.Band(c), dmg, damage, nd,
				inflictor ? inflictor.GetClassName() : 'none');
		newdamage = nd;
	}
}

class RSQGC_CndHandler : EventHandler
{
	// the last hitscan / rail each player fired, and with which hand
	int scanTic[MAXPLAYERS], scanHand[MAXPLAYERS];
	// the missiles each gun fired (and the guns they belong to)
	Array<Actor> shotA;
	Array<String> shotGun;
	Array<int> shotTic;
	// per player and hand (pn * 2 + hand): the last tic a shot was counted, the last backfire / misfire, the rate's
	// accumulator, the last tic the trigger was down
	int firedTic[MAXPLAYERS * 2], hurtTic[MAXPLAYERS * 2], trigTic[MAXPLAYERS * 2];
	double rateAcc[MAXPLAYERS * 2];

	static RSQGC_CndHandler Get() { return RSQGC_CndHandler(EventHandler.Find("RSQGC_CndHandler")); }

	static bool MeleeType(Name dt)
	{
		return dt == 'Melee' || dt == 'Kick' || dt == 'HeadKick' || dt == 'Stomp' || dt == 'ExtremePunches' || dt == 'Saw'
			|| dt == 'Cut' || dt == 'Saber' || dt == 'Fatality' || dt == 'RSQBackfire';
	}

	static Weapon HandGun(PlayerInfo p, int hand)
	{
		Weapon w = hand ? p.OffhandWeapon : p.ReadyWeapon;
		return RSQGC_Cnd.IsGun(w) ? w : null;
	}

	// which gun dealt this: its class name, "" for none (melee, a blast nobody fired, a thrown thing)
	String GunFor(Actor pmo, Actor inf, Name dt)
	{
		if (MeleeType(dt) || !pmo.player) return "";
		if (inf && inf != pmo && inf.bMissile)
		{
			int i = shotA.Find(inf);
			return i < shotA.Size() ? shotGun[i] : "";
		}
		if (inf && inf != pmo && !inf.bIsPuff)
		{
			// a recorded missile may have turned into something else (its death state): still that missile
			int i = shotA.Find(inf);
			return i < shotA.Size() ? shotGun[i] : "";
		}
		// a hitscan, a pellet or a rail: the hand whose shot is being traced now
		int pn = pmo.PlayerNumber();
		if (pn < 0 || scanTic[pn] != level.maptime) return "";
		let w = HandGun(pmo.player, scanHand[pn]);
		if (!w) return ""; String g = w.GetClassName(); return g;
	}

	// ---- shots -----------------------------------------------------------------------------------------------------
	override bool WorldHitscanPreFired(WorldEvent e)
	{
		let mo = e.Thing;
		if (!mo || !mo.player || (e.AttackLineFlags & LAF_ISMELEEATTACK) || !RSQGC_Cnd.On()) return false;
		int hand = (e.AttackLineFlags & LAF_ISOFFHAND) ? 1 : 0;
		Shot(mo.player, hand, "hitscan");
		return false;
	}
	override bool WorldRailgunPreFired(WorldEvent e)
	{
		let mo = e.Thing;
		if (!mo || !mo.player || !RSQGC_Cnd.On()) return false;
		int hand = (e.RailParams.flags & RGF_ISOFFHAND) ? 1 : 0;
		Shot(mo.player, hand, "rail");
		return false;
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let c = e.Thing;
		if (!c || !c.bMissile || !RSQGC_Cnd.On()) return;
		let mo = PlayerPawn(c.target);
		if (!mo || !mo.player) return;
		Prune();
		// fired: born at a hand (BD22 VR Reloaded's muzzle.zs Born test) whose trigger is down
		int pn = mo.PlayerNumber();
		bool m = level.maptime - trigTic[pn * 2] <= 2, o = level.maptime - trigTic[pn * 2 + 1] <= 2;
		int hand = -1;
		double vl = c.vel.Length();
		if (mo.OverrideAttackPosDir)
		{
			if (m && Born(c.pos - mo.AttackPos, c.vel, vl)) hand = 0;
			else if (o && Born(c.pos - mo.OffhandPos, c.vel, vl)) hand = 1;
		}
		else if (m) hand = 0;
		let w = hand >= 0 ? HandGun(mo.player, hand) : null;
		if (w)
		{
			Record(c, w.GetClassName());
			Shot(mo.player, hand, "missile " .. c.GetClassName());
			return;
		}
		// not fired from a hand: a missile a recorded one makes as it bursts (a rocket's fragments, a BFG's tracers) is
		// that gun's; anything else (a thrown grenade, a kick) is nobody's. ITS OWN, NOT A NEIGHBOUR'S (GC11, 2026-11-16: any
		// player missile within 64 units of a recorded one in flight took its gun): spawned by it (its target, master or
		// tracer is the recorded missile: SXF_ORIGINATOR, A_SpawnProjectile from it), or born within 64 units of it while it
		// is bursting (it has hit: no longer a MISSILE, in its death frames). A_SpawnItemEx gives a fragment the shooter as
		// its target, so the burst is how most fragments are known.
		for (int i = 0; i < shotA.Size(); i++)
		{
			let s = shotA[i];
			if (!s || s == c || level.maptime <= shotTic[i]) continue;
			bool spawnedBy = c.target == s || c.master == s || c.tracer == s;
			bool burst = !s.bMissile && (s.pos - c.pos).Length() < 64;
			if (spawnedBy || burst)
			{
				Record(c, shotGun[i]);
				return;
			}
		}
	}
	static bool Born(Vector3 d, Vector3 v, double vl)
	{
		double dl = d.Length();
		if (dl < 1) return true;
		return vl > 0 && dl <= vl + 1 && (d dot v) / (dl * vl) > cos(15);
	}
	void Record(Actor c, String gun)
	{
		shotA.Push(c); shotGun.Push(gun); shotTic.Push(level.maptime);
	}
	void Prune()
	{
		for (int i = shotA.Size() - 1; i >= 0; i--)
			if (!shotA[i] || level.maptime - shotTic[i] > 35 * 20) { shotA.Delete(i); shotGun.Delete(i); shotTic.Delete(i); }
	}

	// A SHOT from this hand: the hitscan's hand for its damage, and once a tic the backfire / misfire roll
	void Shot(PlayerInfo p, int hand, String what)
	{
		let mo = p.mo;
		if (!mo) return;
		int pn = mo.PlayerNumber();
		scanTic[pn] = level.maptime; scanHand[pn] = hand;
		int k = pn * 2 + hand;
		if (firedTic[k] == level.maptime) return;
		firedTic[k] = level.maptime;
		let w = HandGun(p, hand);
		if (!w) return;
		let b = RSQGC_CndBook.Of(mo, true);
		if (!b) return;
		String gun = w.GetClassName();
		int c = b.Get(gun);
		int prof = RSQGC_Cnd.Profile(w);
		double acc, dmg, rate, pMul, bk, mf; int pAdd;
		[acc, dmg, rate, pMul, pAdd, bk, mf] = RSQGC_Cnd.Curve(prof, c);
		if (RSQGC_Cnd.LogOn() && RSQGC_Cnd.CI('rsqgc_cnd_log', 0) >= 2)
			Console.Printf("RSQGC cnd t%d: shot %s hand %s (%s) cnd %d %s: acc x%.2f dmg x%.2f rate x%.2f pellets x%.1f+%d bk %.3f mf %.3f",
				level.maptime, hand ? "off" : "main", gun, what, c, RSQGC_Cnd.ProfileName(prof), acc, dmg, rate, pMul, pAdd, bk, mf);
		if (level.maptime - hurtTic[k] < 35 && hurtTic[k] > 0) return;
		// test: rsqgc_cnd_force 1 forces a backfire, 2 a misfire on the next shot that can have one (sv_cheats)
		int force = RSQGC_Cnd.CI('rsqgc_cnd_force', 0);
		bool doMf = mf > 0 && (force == 2 || frandom[RSQGCCnd](0, 1) < mf);
		bool doBk = !doMf && bk > 0 && (force == 1 || frandom[RSQGCCnd](0, 1) < bk);
		if (!doMf && !doBk) return;
		if (force) CVar.FindCVar('rsqgc_cnd_force').SetInt(0);
		hurtTic[k] = level.maptime;
		bool over = prof == RSQGC_Cnd.P_OVERHEAT;
		int hp = doMf ? (over ? random[RSQGCCnd](8, 20) : random[RSQGCCnd](4, 12)) : random[RSQGCCnd](1, 5);
		// NEVER LETHAL BY ITSELF, AFTER THE SKILL'S FACTOR (NEW-GC-A, 2026-11-16): the engine multiplies a player's damage by
		// the skill's DamageFactor (BD22's Black Metal 1.5), sv_damagefactorplayer and his own factors after this, so the cap
		// is taken on what will land (at 3 health a 2 became 3 and killed: a Score life, a Boss fight lost). And the blow is
		// dealt under BUDDHA, so no factor or ModifyDamage of another mod can push it over: it leaves at least 1 health.
		int rolled = hp;
		double f = PlayerFactor(mo);
		hp = min(hp, int((mo.health - 1) / max(0.01, f)));
		int before = mo.health;
		if (hp > 0)
		{
			bool ownBuddha = mo.bBUDDHA;
			mo.bBUDDHA = true;
			mo.DamageMobj(null, null, hp, 'RSQBackfire', DMG_NO_ARMOR | DMG_THRUSTLESS);
			mo.bBUDDHA = ownBuddha;
		}
		int dealt = max(0, before - mo.health);
		String word = doMf ? (over ? "OVERLOAD" : "MISFIRE") : "BACKFIRE";
		if (doMf) mo.A_StartSound(over ? "weapons/plasmax" : "world/barrelx", CHAN_AUTO, CHANF_OVERLAP, over ? 0.9 : 0.6, ATTN_NORM, over ? 0.8 : 1.3);
		else mo.A_StartSound("weapons/rocklx", CHAN_AUTO, CHANF_OVERLAP, 0.35, ATTN_NORM, 1.7);
		// the toast says what it took (GC6: no "-0" when nothing could be taken; the word alone)
		RSQGC_Cnd.Toast(mo, dealt > 0 ? String.Format("down|%s -%d", word, dealt) : String.Format("down|%s", word));
		if (RSQGC_Cnd.LogOn())
			Console.Printf("RSQGC cnd t%d: %s! %s hand %s (cnd %d, %s): rolled %d, x%.2f after factors, dealt %d: health %d -> %d, toast shown", level.maptime, word,
				hand ? "off" : "main", gun, c, RSQGC_Cnd.ProfileName(prof), rolled, f, dealt, before, mo.health);
	}

	// what the engine will multiply a blow to this player by: the skill's DamageFactor, sv_damagefactorplayer, his own
	// DamageFactor for the backfire's damage type (p_interaction: DamageMobj, the player branch)
	static double PlayerFactor(Actor mo)
	{
		let dfp = CVar.FindCVar('sv_damagefactorplayer');
		double f = G_SkillPropertyFloat(SKILLP_DamageFactor) * (dfp ? dfp.GetFloat() : 1.0);
		f *= mo.ApplyDamageFactor('RSQBackfire', 1000) / 1000.0;
		return max(f, 0.01);
	}

	// ---- wear ------------------------------------------------------------------------------------------------------
	override void WorldThingDamaged(WorldEvent e)
	{
		let mo = e.Thing;
		if (!mo || !mo.player || !RSQGC_Cnd.On() || e.DamageType == 'RSQBackfire') return;
		int over = RSQGC_Cnd.CI('rsqgc_cnd_bighit', 20);
		if (e.Damage <= over) return;
		BigHit(mo.player, e.Damage, e.DamageSource ? e.DamageSource.GetClassName() : (e.Inflictor ? e.Inflictor.GetClassName() : 'nothing'));
	}
	void BigHit(PlayerInfo p, int dmg, String from)
	{
		let mo = p.mo;
		let b = RSQGC_CndBook.Of(mo, true);
		if (!b) return;
		int wear = clamp(RSQGC_Cnd.CI('rsqgc_cnd_wear', 3), 0, 100);
		String l = "";
		Weapon w0 = HandGun(p, 0), w1 = HandGun(p, 1);
		if (w1 && w0 && w1.GetClass() == w0.GetClass()) w1 = null;
		for (int h = 0; h < 2; h++)
		{
			let w = h ? w1 : w0;
			if (!w) continue;
			String gun = w.GetClassName();
			int was = b.Get(gun);
			int now = max(0, was - wear);
			b.Set(gun, now);
			l = l .. String.Format(" %s %s %d -> %d;", h ? "off" : "main", gun, was, now);
			// (GC9, 2026-11-16: a gun already at 0 when Lose the Gun at 0 was turned on breaks at its next big hit too)
			if (now == 0 && RSQGC_Cnd.CI('rsqgc_cnd_losegun', 0)) BreakGun(p, w);
		}
		if (RSQGC_Cnd.LogOn())
			Console.Printf("RSQGC cnd t%d: big hit %d (over %d) from %s on player %d:%s", level.maptime, dmg,
				RSQGC_Cnd.CI('rsqgc_cnd_bighit', 20), from, mo.PlayerNumber(), l == "" ? " no gun in hand" : l);
	}
	// LOSE THE GUN AT 0 (option, off): it breaks and is taken; its book entry goes, so the next one is new
	void BreakGun(PlayerInfo p, Weapon w)
	{
		let mo = p.mo;
		String gun = w.GetClassName();
		String tag = w.GetTag();
		mo.A_StartSound("world/barrelx", CHAN_AUTO, CHANF_OVERLAP, 0.5, ATTN_NORM, 1.5);
		RSQGC_Cnd.Toast(mo, String.Format("down|%s BROKE", tag.MakeUpper()));
		mo.TakeInventory(w.GetClass(), 0x7FFFFFFF);
		let b = RSQGC_CndBook.Of(mo);
		if (b) b.Forget(gun);
		if (RSQGC_Cnd.LogOn()) Console.Printf("RSQGC cnd t%d: %s broke at 0 and was taken (Lose the Gun at 0)", level.maptime, gun);
	}

	// ---- repair (asked by name) ------------------------------------------------------------------------------------
	// +n to each gun in his hands; returns how many guns it raised
	int RepairHeld(Actor pmo, int n, String why)
	{
		if (!pmo || !pmo.player || !RSQGC_Cnd.On()) return 0;
		let b = RSQGC_CndBook.Of(pmo, true);
		int got = 0;
		String l = "";
		Weapon w0 = HandGun(pmo.player, 0), w1 = HandGun(pmo.player, 1);
		if (w1 && w0 && w1.GetClass() == w0.GetClass()) w1 = null;
		for (int h = 0; h < 2; h++)
		{
			let w = h ? w1 : w0;
			if (!w) continue;
			String gun = w.GetClassName();
			int was = b.Get(gun);
			if (was >= 100) continue;
			b.Set(gun, was + n);
			got++;
			l = l .. String.Format(" %s %d -> %d;", gun, was, b.Get(gun));
		}
		if (RSQGC_Cnd.LogOn()) Console.Printf("RSQGC cnd t%d: repair +%d (%s):%s", level.maptime, n, why, got ? l : " nothing worn in his hands");
		return got;
	}
	// every gun he carries: the points missing (the kiosk's price), and the full repair
	static int Worn(Actor pmo)
	{
		if (!pmo || !pmo.player || !RSQGC_Cnd.On()) return 0;
		let b = RSQGC_CndBook.Of(pmo);
		if (!b) return 0;
		int n = 0;
		for (let i = pmo.Inv; i; i = i.Inv)
		{
			let w = Weapon(i);
			if (w && RSQGC_Cnd.IsGun(w)) n += 100 - b.Get(w.GetClassName());
		}
		return n;
	}
	static int WornGuns(Actor pmo)
	{
		let b = RSQGC_CndBook.Of(pmo);
		if (!b || !RSQGC_Cnd.On()) return 0;
		int n = 0;
		for (let i = pmo.Inv; i; i = i.Inv) { let w = Weapon(i); if (w && RSQGC_Cnd.IsGun(w) && b.Get(w.GetClassName()) < 100) n++; }
		return n;
	}
	static int FixAll(Actor pmo, String why)
	{
		if (!pmo || !pmo.player || !RSQGC_Cnd.On()) return 0;
		let b = RSQGC_CndBook.Of(pmo, true);
		int n = 0;
		String l = "";
		for (let i = pmo.Inv; i; i = i.Inv)
		{
			let w = Weapon(i);
			if (!w || !RSQGC_Cnd.IsGun(w)) continue;
			int was = b.Get(w.GetClassName());
			if (was >= 100) continue;
			n += 100 - was;
			b.Set(w.GetClassName(), 100);
			l = l .. String.Format(" %s %d -> 100;", w.GetClassName(), was);
		}
		if (RSQGC_Cnd.LogOn()) Console.Printf("RSQGC cnd t%d: full repair (%s): %d points:%s", level.maptime, why, n, n ? l : " nothing worn");
		return n;
	}

	// ---- every tic: the trigger, the book, the rate ----------------------------------------------------------------
	override void WorldTick()
	{
		if (!RSQGC_Cnd.On()) return;
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) continue;
			let p = players[pn];
			int bt = p.cmd.buttons;
			if (bt & (BT_ATTACK | BT_ALTATTACK)) trigTic[pn * 2] = level.maptime;
			if (bt & (BT_OFFHANDATTACK | BT_OFFHANDALTATTACK)) trigTic[pn * 2 + 1] = level.maptime;
			if (level.maptime % 35 == 0) RSQGC_CndBook.Of(p.mo, true);
			if (!RSQGC_Cnd.CI('rsqgc_cnd_rate', 1)) continue;
			for (int h = 0; h < 2; h++) RateTick(p, h);
		}
	}
	// RATE: through the FIRE SEQUENCE a trigger pull started -- from the pull until the gun is back in its Ready state, held
	// or let go (GC4, 2026-11-16: it acted only on tics with the trigger held, so a tap's sequence ran at full speed) -- its
	// layer's tics are stretched (a slower gun: a tic added when the accumulator passes -1) or shortened (a faster gun: a
	// tic taken off a frame longer than 1). A reload or a switch is not a fire sequence (it starts from Ready, untriggered).
	transient bool fireSeq[MAXPLAYERS * 2];
	void RateTick(PlayerInfo p, int h)
	{
		int k = p.mo.PlayerNumber() * 2 + h;
		let w = HandGun(p, h);
		bool trig = level.maptime == trigTic[k];
		bool ready = (p.WeaponState & (h ? WF_OFFHANDREADY : WF_WEAPONREADY)) != 0;
		if (trig) fireSeq[k] = true;
		else if (ready || !w) fireSeq[k] = false;
		let psp = p.FindPSprite(h ? PSP_OFFHANDWEAPON : PSP_WEAPON);
		if (!w || !fireSeq[k] || ready || !psp || !psp.CurState || psp.Tics <= 0 || (!h && p.PendingWeapon != WP_NOCHANGE)) { rateAcc[k] = 0; return; }
		let b = RSQGC_CndBook.Of(p.mo);
		int c = b ? b.Get(w.GetClassName()) : 100;
		double acc, dmg, rate, pMul, bk, mf; int pAdd;
		[acc, dmg, rate, pMul, pAdd, bk, mf] = RSQGC_Cnd.Curve(RSQGC_Cnd.Profile(w), c);
		if (rate == 1.0) { rateAcc[k] = 0; return; }
		rateAcc[k] += rate - 1.0;
		if (rateAcc[k] <= -1.0) { psp.Tics++; rateAcc[k] += 1.0; }
		else if (rateAcc[k] >= 1.0)
		{
			if (psp.Tics > 1) { psp.Tics--; rateAcc[k] -= 1.0; }
			else rateAcc[k] = 1.0;
		}
	}

	override void PlayerEntered(PlayerEvent e)
	{
		if (RSQGC_Cnd.On() && playeringame[e.PlayerNumber] && players[e.PlayerNumber].mo) RSQGC_CndBook.Of(players[e.PlayerNumber].mo, true);
	}

	// tests (sv_cheats): netevent rsqgc_cnd_set <0..100> [0 both hands (default), 1 main, 2 off]; netevent rsqgc_cnd_hit <damage>
	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "rsqgc_cnd_set") && !(e.Name ~== "rsqgc_cnd_hit")) return;
		let ch = CVar.FindCVar('sv_cheats');
		if (e.IsManual && (!ch || !ch.GetBool())) { Console.Printf("rsqgc: %s needs sv_cheats 1", e.Name); return; }
		if (e.Player < 0 || !playeringame[e.Player] || !players[e.Player].mo) return;
		let p = players[e.Player];
		if (e.Name ~== "rsqgc_cnd_hit")
		{
			p.mo.DamageMobj(null, null, max(1, e.Args[0]), 'None', DMG_THRUSTLESS);
			return;
		}
		let b = RSQGC_CndBook.Of(p.mo, true);
		int which = e.Args[1];
		for (int h = 0; h < 2; h++)
		{
			if (which != 0 && which != h + 1) continue;
			let w = HandGun(p, h);
			if (!w) continue;
			b.Set(w.GetClassName(), e.Args[0]);
			Console.Printf("RSQGC cnd: %s hand %s set to %d (%s, band %d)", h ? "off" : "main", w.GetClassName(), b.Get(w.GetClassName()),
				RSQGC_Cnd.ProfileName(RSQGC_Cnd.Profile(w)), RSQGC_Cnd.Band(b.Get(w.GetClassName())));
		}
	}
}

// ASKED BY NAME (RSQGC_Service, card.zs: ServiceIterator.Find("RSQGC_Service")). Every answer is the neutral one (1.0, 0,
// -1) while Weapon Condition is off.
//   GetInt "cnd.on"         1 while Weapon Condition is on
//   GetInt "cnd.get"        objectArg a weapon (in someone's inventory): its condition 0-100, -1 off / not a gun
//   GetInt "cnd.pellets"    objectArg a weapon: pellets to ADD to a spread shot (the curve's pAdd; 0 above 30)
//   GetInt "cnd.repair"     (play) intArg n, objectArg the player's pawn, stringArg why (the log): +n to each gun in his hands;
//                           returns how many guns it raised (RSQ VisualRewards' steel bit)
//   GetInt "cnd.worn"       objectArg the pawn: the condition points missing over every gun he carries (the kiosk's price)
//   GetInt "cnd.worn.guns"  objectArg the pawn: how many of his guns are worn
//   GetInt "cnd.fix"        (play) objectArg the pawn, stringArg why: every gun he carries back to 100; returns the points
//                           restored (RSQ Miniboss's kiosk, after it took the gold)
//   GetDouble "cnd.spread"  objectArg a weapon: THE ACCURACY HOOK: multiply that gun's own spread by this (1.0 = as made).
//                           A weapon set asks it as it fires (BD22 VR Reloaded: muzzle.zs); a gun that never asks keeps its spread
//   GetDouble "cnd.pelletmul", "cnd.damage", "cnd.rate"   objectArg a weapon: the curve's pellet, damage and rate factors
//                           (the damage is applied on hit by this layer; do not apply it again)
extend class RSQGC_Cnd
{
	static double, double, double, double, int Factors(Object o)
	{
		let w = Weapon(o);
		int c = Of(w);
		if (c < 0) return 1, 1, 1, 1, 0;
		double acc, dmg, rate, pMul, bk, mf; int pAdd;
		[acc, dmg, rate, pMul, pAdd, bk, mf] = Curve(Profile(w), c);
		return acc, dmg, rate, pMul, pAdd;
	}
	static int SvcInt(String request, String stringArg, int intArg, Object objectArg)
	{
		if (request == "cnd.on") return On() ? 1 : 0;
		if (request == "cnd.get") return Of(Weapon(objectArg));
		double acc, dmg, rate, pMul; int pAdd;
		if (request == "cnd.pellets") { [acc, dmg, rate, pMul, pAdd] = Factors(objectArg); return pAdd; }
		let a = Actor(objectArg);
		if (request == "cnd.repair") { let h = RSQGC_CndHandler.Get(); return h ? h.RepairHeld(a, max(0, intArg), stringArg) : 0; }
		if (request == "cnd.worn") return RSQGC_CndHandler.Worn(a);
		if (request == "cnd.worn.guns") return RSQGC_CndHandler.WornGuns(a);
		if (request == "cnd.fix") return RSQGC_CndHandler.FixAll(a, stringArg);
		return 0;
	}
	static double SvcDouble(String request, Object objectArg)
	{
		double acc, dmg, rate, pMul; int pAdd;
		[acc, dmg, rate, pMul, pAdd] = Factors(objectArg);
		if (request == "cnd.spread") return acc;
		if (request == "cnd.pelletmul") return pMul;
		if (request == "cnd.damage") return dmg;
		if (request == "cnd.rate") return rate;
		return 1.0;
	}
}
