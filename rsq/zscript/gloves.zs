// THE GLOVES -- SuperPunchOut's boxing gloves, as weapons for any Doom map.
//
// From SuperPunchOut (presidentkoopa): the glove weapons (spo_present.zs SPO_Glove /
// SPO_GloveOff), their model and skins (models/spo, the mesh of Ermac's PunchOutVR glove and
// Ermac's fit, Scale -1.2 1.2 1.2, Offset 0 -10 -10) and the punch reader (spo_corner.zs, the
// Arcade reader: a punch arms only after the glove has travelled ARM_M toward its target on
// consecutive tics, must average spo_min_speed over that travel, and its power is the average).
// The boxer, the ring and the bout are not here.
//
// RENAMED RSQ_Glove / RSQ_GloveOff, so this patch and SuperPunchOut can both be loaded without
// two classes of one name. The Gun Bonsai upgrades match either spelling (RSQM.IsGloveName).
//
// A glove draws nothing (TNT1) and fires nothing: a punch is the hand. Stock QuestZDoom draws
// the READY weapon's model on the main controller and the OFFHAND weapon's on the other, so the
// MODELDEF on these two classes is the whole of what you see.

class RSQ_Glove : Weapon
{
	// THE LAST PUNCH, as the reader saw it -- the upgrades read these in ModifyDamageDealt, where
	// the only thing they are handed is this weapon as the inflictor.
	double lastPower;     // 0..1 between spo_min_speed and spo_full_speed (SuperPunchOut's own scale)
	double lastSpeed;     // m/s, the swing's average
	int    lastKind;      // RSQ_GloveHandler.PK_JAB / PK_HOOK / PK_UPPER
	bool   lastBody;      // landed below the chest
	bool   lastCounter;   // the target was in its attack wind-up
	bool   lastStar;      // a star punch
	int    lastChain;     // One-Two: how many alternating hits in a row, this one included
	int    lastHand;

	Default
	{
		Weapon.SelectionOrder 5500;
		Weapon.Kickback 100;
		Weapon.SlotNumber 1;
		Tag "$RSQ_GLOVE_TAG";
		Inventory.PickupMessage "$RSQ_GLOVE_PICKUP";
		Obituary "$RSQ_GLOVE_OB";
		+WEAPON.WIMPY_WEAPON
		+WEAPON.MELEEWEAPON
		+WEAPON.NOALERT
		+WEAPON.NOHANDSWITCH
		+WEAPON.NOAUTOSWITCHTO
		+WEAPON.NO_AUTO_SWITCH
		+WEAPON.AMMO_OPTIONAL
		+INVENTORY.UNDROPPABLE
	}

	States
	{
	Ready:
		TNT1 A 1 A_WeaponReady(WRF_NOFIRE);
		Loop;
	Deselect:
		TNT1 A 1 A_Lower(120);
		Wait;
	Select:
		TNT1 A 1 A_Raise(120);
		Wait;
	Fire:
		TNT1 A 1;
		Goto Ready;
	Spawn:
		TNT1 A -1;
		Stop;
	}
}

class RSQ_GloveOff : RSQ_Glove
{
	Default
	{
		+WEAPON.OFFHANDWEAPON
	}
}

// ---- THE READER ------------------------------------------------------------------------------
// Per player, per hand. Pure arithmetic over the hand's positions, so the same code reads a
// real controller and a probe's synthetic swing (Feed).
class RSQ_PunchHand play
{
	bool armed, swinging;
	double approach;
	int approachTics;
	int lastHit;
	// the hand, relative to the pawn at the top of the tic, and its velocity (map units / s)
	Vector3 loc, prevLoc, vel, hand, prevHand;
	bool prevValid;
	int prevTic;
	double prevYaw;
}

class RSQ_GloveHandler : EventHandler
{
	enum EKind { PK_JAB, PK_HOOK, PK_UPPER }

	// SuperPunchOut's Arcade reader constants (spo_corner.zs), unchanged
	const ARM_M = 0.15;       // metres toward the target before a swing is a punch
	const IN_MPS = 0.25;      // m/s that still counts as coming in
	const MAX_TICS = 14;      // longer than this is two motions, not one
	// SuperPunchOut's QZD velocity rules (spo_qzd.zs LocalHandVel), unchanged
	const JUMP_UNITS = 48.0;
	const MAX_GAP = 3;
	const SNAP_DEG = 15.0;

	RSQ_PunchHand hands[MAXPLAYERS * 2];
	// One-Two
	int chainLastHand[MAXPLAYERS], chainLastTic[MAXPLAYERS], chainCount[MAXPLAYERS];
	// Star Punch: SuperPunchOut's bank (rules.txt `maxstars 3`) and its landed-punch count
	int stars[MAXPLAYERS], starLanded[MAXPLAYERS];
	// a probe may hand the reader positions instead of the controllers (headless testing)
	bool simOn[MAXPLAYERS * 2];
	Vector3 simHand[MAXPLAYERS * 2];

	static RSQ_GloveHandler Get() { return RSQ_GloveHandler(EventHandler.Find("RSQ_GloveHandler")); }

	RSQ_PunchHand HandOf(int pn, int h)
	{
		int i = pn * 2 + h;
		if (!hands[i]) hands[i] = new("RSQ_PunchHand");
		return hands[i];
	}

	static RSQ_Glove GloveIn(PlayerPawn pmo, int h)
	{
		if (!pmo || !pmo.player) return null;
		return RSQ_Glove(h == 0 ? pmo.player.ReadyWeapon : pmo.player.OffhandWeapon);
	}

	// The controller, or nothing: out of VR the engine writes both hands to the pawn's chest
	// (hw_vrmodes.cpp SetUp), and two hands at one point is that fallback's signature.
	Vector3, bool HandPos(PlayerPawn pmo, int h)
	{
		int i = pmo.PlayerNumber() * 2 + h;
		if (simOn[i]) return simHand[i], true;
		if (!pmo.OverrideAttackPosDir || !pmo.player.PlayInVR) return (0, 0, 0), false;
		if (pmo.AttackPos == pmo.OffhandPos) return (0, 0, 0), false;
		return (h == 0 ? pmo.AttackPos : pmo.OffhandPos), true;
	}

	// SuperPunchOut's ClassifyPunch (PunchOutVR core.zs), unchanged: from how the glove travelled
	// against the line to the target -- not from where you look or how the controller is held.
	static int Classify(Vector3 dir, Vector2 toFoe, double rise)
	{
		double fwd = dir.xy dot toFoe;
		double lat = abs(dir.x * toFoe.y - dir.y * toFoe.x);
		if (dir.z > rise) return PK_UPPER;
		if (lat > 0.6 && lat > fwd) return PK_HOOK;
		return PK_JAB;
	}

	override void WorldTick()
	{
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn]) continue;
			let pmo = players[pn].mo;
			if (!pmo || pmo.health <= 0) continue;
			for (int h = 0; h < 2; h++)
			{
				let g = GloveIn(pmo, h);
				if (!g) { HandOf(pn, h).prevValid = false; continue; }
				Read(pmo, g, h);
			}
		}
	}

	private void Read(PlayerPawn pmo, RSQ_Glove g, int h)
	{
		let st = HandOf(pmo.PlayerNumber(), h);
		Vector3 hp; bool ok;
		[hp, ok] = HandPos(pmo, h);
		int now = level.maptime;
		if (!ok) { st.prevValid = false; return; }
		// THE VELOCITY, SuperPunchOut's way: the hand against the pawn at the top of the tic
		// (Prev), one tic, no averaging; a snap turn or a one-tic jump no arm makes is dropped.
		Vector3 loc = hp - pmo.Prev;
		int dt = now - st.prevTic;
		bool had = st.prevValid;
		Vector3 prev = st.loc;
		double yawStep = abs(Actor.DeltaAngle(st.prevYaw, pmo.angle));
		st.prevHand = st.hand;
		st.hand = hp;
		st.loc = loc;
		st.prevYaw = pmo.angle;
		st.prevTic = now;
		st.prevValid = true;
		st.vel = (0, 0, 0);
		if (!had || dt < 1 || dt > MAX_GAP) return;
		if (yawStep > SNAP_DEG * dt) return;
		Vector3 d = loc - prev;
		if (d.Length() > JUMP_UNITS * dt) return;
		st.vel = d * (double(TICRATE) / dt);
		Swing(pmo, g, h, st);
	}

	private void Swing(PlayerPawn pmo, RSQ_Glove g, int h, RSQ_PunchHand st)
	{
		double upm = RSQM.UnitsPerMetre();
		double ps = level.pixelstretch > 0.1 ? level.pixelstretch : 1.2;
		double minSpeed = RSQM.SV("rsq_punch_min_speed", 2.0);   // spo_min_speed's default
		double fullSpeed = RSQM.SV("rsq_punch_full_speed", 7.0); // spo_full_speed's default
		int rehit = RSQM.SVI("rsq_punch_rehit", 6);               // spo_rehit_tics' default
		Vector3 v = st.vel;
		v.z *= ps;
		double mps = v.Length() / upm;
		int now = level.maptime;
		bool dbg = RSQM.SVI("rsq_punch_debug", 0) != 0;
		if (dbg) Console.Printf("RSQ punch %s t%d %.2f m/s armed %d approach %.2f m in %d", h ? "L" : "R", now, mps, st.armed, st.approach, st.approachTics);

		if (!st.armed)
		{
			if (now - st.lastHit >= rehit && mps < minSpeed * 0.6) st.armed = true;
			return;
		}
		if (mps >= IN_MPS && st.approachTics < MAX_TICS)
		{
			st.approach += mps / TICRATE;
			st.approachTics++;
		}
		else
		{
			if (st.swinging) Whiff(pmo, h);
			st.swinging = false;
			st.approach = 0;
			st.approachTics = 0;
			return;
		}
		if (st.approach < ARM_M) return;
		double avg = st.approach * TICRATE / st.approachTics;
		if (avg < minSpeed) return;
		st.swinging = true;

		// WHAT THE GLOVE WENT INTO between last tic and this one: a body's cylinder, the glove a
		// sphere of SuperPunchOut's gloveradius (0.09 m) with a little reach.
		double gr = 0.09 * upm + RSQM.SV("rsq_punch_pad", 4.0);
		Actor victim = Contact(pmo, st.prevHand, st.hand, gr);
		if (dbg) { String vn = "nothing"; if (victim) vn = victim.GetClassName(); Console.Printf("RSQ punch %s swing %.2f m/s avg -> %s", h ? "L" : "R", avg, vn); }
		if (!victim) return;
		Vector3 dir = st.vel;
		if (dir.Length() < 0.001) dir = level.Vec3Diff(st.hand, victim.pos);
		dir = dir.Unit();
		Deliver(pmo, g, h, victim, avg, dir, st.hand);
		st.armed = false;
		st.swinging = false;
		st.approach = 0;
		st.approachTics = 0;
		st.lastHit = now;
	}

	static Actor Contact(PlayerPawn pmo, Vector3 a, Vector3 b, double gr)
	{
		Actor best = null;
		double bestD = 1e9;
		let it = BlockThingsIterator.CreateFromPos(b.x, b.y, b.z - 96, 192, gr + 64, false);
		while (it.Next())
		{
			Actor mo = it.thing;
			if (!RSQM.IsFoe(pmo, mo)) continue;
			// nearest approach of the glove's path this tic to the body's axis, in the plane
			Vector2 c = mo.pos.xy;
			Vector2 ab = b.xy - a.xy;
			double l2 = ab dot ab;
			double t = l2 > 0.0001 ? clamp(((c - a.xy) dot ab) / l2, 0.0, 1.0) : 1.0;
			Vector3 p = a + (b - a) * t;
			double dxy = (p.xy - c).Length();
			if (dxy > mo.radius + gr) continue;
			if (p.z < mo.pos.z - gr || p.z > mo.pos.z + mo.height + gr) continue;
			if (dxy < bestD) { bestD = dxy; best = mo; }
		}
		return best;
	}

	// A swing that ended without touching anything breaks a One-Two.
	void Whiff(PlayerPawn pmo, int h)
	{
		int pn = pmo.PlayerNumber();
		chainCount[pn] = 0;
	}

	// ---- A PUNCH LANDS ------------------------------------------------------------------------
	// Everything a landed punch is, decided here and written onto the glove, then one
	// DamageMobj with the glove as the inflictor: Gun Bonsai credits that glove (a weapon naming
	// itself is its own claim) and the upgrades shape the number from what is written here.
	// Public so a probe can land one without a controller.
	void Deliver(PlayerPawn pmo, RSQ_Glove g, int h, Actor victim, double avgMps, Vector3 dir, Vector3 at)
	{
		if (!pmo || !g || !victim || victim.health <= 0) return;
		int pn = pmo.PlayerNumber();
		int now = level.maptime;
		double minSpeed = RSQM.SV("rsq_punch_min_speed", 2.0);
		double fullSpeed = RSQM.SV("rsq_punch_full_speed", 7.0);
		double rise = RSQM.SV("rsq_punch_uppercut_rise", 0.5);   // spo_uppercut_rise's default

		Vector2 toFoe = victim.pos.xy - pmo.pos.xy;
		double tl = toFoe.Length();
		toFoe = tl > 0.5 ? toFoe / tl : (cos(pmo.angle), sin(pmo.angle));

		g.lastHand = h;
		g.lastSpeed = avgMps;
		g.lastPower = clamp((avgMps - minSpeed) / max(fullSpeed - minSpeed, 0.1), 0.0, 1.0);
		g.lastKind = Classify(dir, toFoe, rise);
		double upFrac = clamp((at.z - victim.pos.z) / max(victim.height, 1.0), 0.0, 1.0);
		g.lastBody = g.lastKind != PK_UPPER && upFrac < 0.6;
		g.lastCounter = RSQM.InAttack(victim);

		// ONE-TWO: the other hand, inside half a second, keeps the chain; the same hand or a gap
		// starts a new one
		if (chainCount[pn] > 0 && chainLastHand[pn] != h && now - chainLastTic[pn] <= 17) chainCount[pn]++;
		else chainCount[pn] = 1;
		chainLastHand[pn] = h;
		chainLastTic[pn] = now;
		g.lastChain = chainCount[pn];

		// STAR PUNCH: an uppercut thrown with that hand's trigger squeezed, while a star is banked
		// (SuperPunchOut's StarArmed, with the trigger standing in for the grip as its QZD seam does)
		int starLv = RSQM.LevelOn(g, "RSQ_Upgrade_StarPunch");
		int btn = pmo.player.cmd.buttons;
		bool squeeze = (btn & (h == 0 ? (BT_ATTACK | BT_ALTATTACK) : (BT_OFFHANDATTACK | BT_OFFHANDALTATTACK))) != 0;
		g.lastStar = starLv > 0 && stars[pn] > 0 && g.lastKind == PK_UPPER && squeeze;
		if (g.lastStar) stars[pn]--;

		// THE PUNCH: Brutal Doom's own fist is MeleeStrikeNormal (10) and its strong punch
		// MeleeStrike2 (20) -- parsed from brutal22test6 Melee.dec -- so a glove runs 10 at the
		// slowest punch that counts to 20 at a full-speed one.
		int dmg = int(RSQM.SV("rsq_punch_damage", 10.0) * (1.0 + g.lastPower));
		victim.SpawnBlood(at, VectorAngle(dir.x, dir.y), dmg);
		victim.DamageMobj(g, pmo, dmg, 'Melee', DMG_THRUSTLESS);
		pmo.A_StartSound(g.lastStar ? "rsq/star" : "rsq/punch", CHAN_AUTO, 0, 1.0);
		RSQ_Buzz.Start(pmo, h, 0.5 + 0.5 * g.lastPower + (g.lastStar ? 0.5 : 0.0), g.lastStar ? 10 : 5);
		if (victim && victim.health > 0 && !victim.bDontThrust)
		{
			double kk = (2.0 + 6.0 * g.lastPower) * clamp(100.0 / max(victim.mass, 1.0), 0.08, 2.0);
			victim.vel += dir * kk;
		}

		// THE BANK, SuperPunchOut's rule (spo_boxer.zs TakeHit): a punch landed into an open
		// window earns a star, and so does the starFirst-th landed punch and every starEvery-th
		// after. The defaults are Soda Popinski's line, `stars 1 2` (sodapopinski.txt), capped at
		// rules.txt's `maxstars 3`. Only a glove with Star Punch banks; a star spent does not.
		if (starLv > 0 && !g.lastStar)
		{
			int first = RSQM.SVI("rsq_star_first", 1), every = RSQM.SVI("rsq_star_every", 2);
			starLanded[pn]++;
			bool earn = g.lastCounter;
			if (first > 0 && starLanded[pn] == first) earn = true;
			if (every > 0 && starLanded[pn] > first && ((starLanded[pn] - first) % every) == 0) earn = true;
			if (earn && stars[pn] < 3)
			{
				stars[pn]++;
				pmo.A_StartSound("rsq/star", CHAN_AUTO, 0, 0.5, ATTN_NORM, 1.5);
			}
		}
	}

	override void PlayerEntered(PlayerEvent e)
	{
		// a new map: the chain and the pose history are this map's, the bank is kept
		if (e.PlayerNumber < 0 || e.PlayerNumber >= MAXPLAYERS) return;
		chainCount[e.PlayerNumber] = 0;
		for (int h = 0; h < 2; h++) HandOf(e.PlayerNumber, h).prevValid = false;
	}
}
