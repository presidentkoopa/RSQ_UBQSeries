// RS VR fists (2026-10-16, owner): one fist per hand, and they never change hands.
//   main hand   BD22's fists weapon (Melee_Attacks). Ermac's fist is drawn on it (hands.zs).
//   off hand    our off-hand weapon (RSQ_Hands, "Hands"): a fist whenever it is free. It is
//               also what does the immersive reloads, so the main gun keeps reloading by hand.
// A real punch with either controller lands BD22's own punch (MeleeStrikeNormal, or the
// berserk one), from the hand, the way the punch went. Only a fast, mostly forward blow counts,
// once per blow; the hand has to slow down before it can punch again.
// Neither fist can be moved to the other hand (WEAPON.NOHANDSWITCH).
// rsq_punch 0 turns the real punches off. Out of VR nothing here does anything.
class RSQ_Fists : EventHandler
{
	RSQ_FistHand mainH[MAXPLAYERS];
	RSQ_FistHand offH[MAXPLAYERS];
	// 2.0.4a (LD mode, owner round 4: "fist legendaries on both fists", "damage scaled by swing speed"): every punch
	// thrown with an arm is recorded here for a few tics: the strike, the hand (0 main, 1 off) and the swing's speed in
	// m/s. Read by zscript/rsld (handler.zs StrikeHand, ld_g7_fx.zs Swing); nothing else changes.
	Array<Actor> recA;
	Array<int> recHand, recTic;
	Array<double> recMps;

	static RSQ_Fists Get() { return RSQ_Fists(EventHandler.Find("RSQ_Fists")); }
	static void Record(Actor strike, int hand, double mps)
	{
		let f = Get();
		if (!f || !strike) return;
		for (int i = f.recA.Size() - 1; i >= 0; i--)
			if (!f.recA[i] || level.maptime - f.recTic[i] > 35) { f.recA.Delete(i); f.recHand.Delete(i); f.recTic.Delete(i); f.recMps.Delete(i); }
		f.recA.Push(strike); f.recHand.Push(hand); f.recTic.Push(level.maptime); f.recMps.Push(mps);
	}
	// the recorded punch of a strike: its hand (-1 not an arm's punch) and swing speed (m/s)
	static int, double Lookup(Actor strike)
	{
		let f = Get();
		if (!f || !strike) return -1, 0;
		int i = f.recA.Find(strike);
		if (i >= f.recA.Size()) return -1, 0;
		return f.recHand[i], f.recMps[i];
	}

	static Class<Actor> Cls(Name n) { class<Actor> c = n; return c; }

	// 2026-10-23 (owner: "that way we can punch open switches n shit"): a blow that lands on a
	// switch or any usable line works it, at the fist's own reach instead of the engine's 64-unit
	// use range -- you hit the thing where your arm actually is.
	//
	// The LINE'S SPECIAL decides, not its texture. There is no script query for the SWITCHES list,
	// and a line with no special is not usable however it is painted; a line WITH one is usable
	// whatever texture it wears. TRF_ABSPOSITION so the three "offsets" are the coordinates: with
	// OverrideAttackPosDir on (always, in VR) a non-zero offset otherwise reads uninitialised stack
	// (p_map.cpp:5181, DVector3 startpos declared and never set).
	const USE_REACH = 30.0;		// map units from the fist

	static void PunchUse(PlayerPawn mo, Vector3 from, Vector3 dir)
	{
		if (!mo || RSQ.PlayerInt(mo, 'rsq_punch_use', 1) == 0)
			return;
		FLineTraceData d;
		double ang = VectorAngle(dir.x, dir.y);
		double pit = -asin(clamp(dir.z, -1, 1));
		if (!mo.LineTrace(ang, USE_REACH, pit, TRF_ABSPOSITION, from.z, from.x, from.y, d))
			return;
		if (d.HitType != TRACE_HitWall || !d.HitLine || d.HitLine.special == 0)
			return;
		if (!d.HitLine.Activate(mo, d.LineSide, SPAC_Use))
			d.HitLine.Activate(mo, d.LineSide, SPAC_Push);	// some lines are push, not use
	}

	// 2.0.3y (owner, BUGS_1.0 item 13): the same for a gun swung as a club (melee.zs: the pistol whip, the butt
	// strike). "what do we do about wads with custom switch textures, isn't the logic the same?" -- yes: as above, the
	// LINE'S SPECIAL decides (Line.Activate runs it, as the Use key does), never the texture, so a WAD's own switch
	// art works the same. Two traces: along the gun (hand -> its striking end), then the striking end's own path this
	// tic (where it was -> where it is) and on along the blow for `reach` -- the hand can pass through a wall in VR, so
	// the path is traced from where the end was, on the near side. The first usable line met is worked. True when one was.
	static bool LineUse(PlayerPawn mo, Vector3 hand, Vector3 prevTip, Vector3 tip, double reach, String what)
	{
		if (!mo || RSQ.PlayerInt(mo, 'rsq_punch_use', 1) == 0)
			return false;
		Vector3 g = tip - hand;
		double gl = g.Length();
		if (gl > 1 && UseAlong(mo, hand, g / gl, gl, what))
			return true;
		Vector3 m = tip - prevTip;
		double ml = m.Length();
		if (ml <= 0)
			return false;
		return UseAlong(mo, prevTip, m / ml, ml + reach, what);
	}

	static bool UseAlong(PlayerPawn mo, Vector3 from, Vector3 dir, double reach, String what)
	{
		FLineTraceData d;
		double ang = VectorAngle(dir.x, dir.y);
		double pit = -asin(clamp(dir.z, -1, 1));
		if (!mo.LineTrace(ang, reach, pit, TRF_ABSPOSITION | TRF_THRUACTORS, from.z, from.x, from.y, d))
			return false;
		if (d.HitType != TRACE_HitWall || !d.HitLine || d.HitLine.special == 0)
			return false;
		bool done = d.HitLine.Activate(mo, d.LineSide, SPAC_Use) || d.HitLine.Activate(mo, d.LineSide, SPAC_Push);
		if (RSQ.PlayerInt(mo, 'rsq_switch_log', 0) > 0)
			Console.Printf("RSQ melee use t%d: %s hit line %d (special %d) at %.0f units: %s", mo.Level.maptime, what,
				d.HitLine.Index(), d.HitLine.special, d.Distance, done ? "worked" : "not usable from here");
		return done;
	}

	override void WorldTick()
	{
		if (Object.FindClass("RSQML_Gloves") != null)	return;	// the weapon sets: RSQ Melee is loaded, its punches are the ones
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo)
				continue;
			let mo = players[n].mo;
			let p = mo.player;

			// the fists weapon stays in the main hand
			class<Inventory> mc = (class<Inventory>)(Cls('RSQGW_Knuckle'));
			let fw = mc ? Weapon(mo.FindInventory(mc)) : null;
			if (fw)
				fw.bNoHandSwitch = true;

			if (!mainH[n])
				mainH[n] = new('RSQ_FistHand');
			if (!offH[n])
				offH[n] = new('RSQ_FistHand');
			// 2.0.3y "No Trigger Punch" (owner 11-06): the button swallower rides on the player (RSQ_NoTrigPunch below)
			if (!mo.FindInventory('RSQ_NoTrigPunch'))
				mo.GiveInventory('RSQ_NoTrigPunch', 1);
			bool vr = RSVR_VRHand.InVR(mo) && p.playerstate == PST_LIVE && mo.health > 0
				&& RSQ.PlayerInt(mo, 'rsqb_punch', 1) != 0;
			bool mainFist = vr && p.ReadyWeapon && fw && p.ReadyWeapon == fw;
			bool offFist = vr && p.OffhandWeapon is 'RSQ_Hands' && RSQ_Hands.OffFist(mo);
			mainH[n].handIdx = 0;
			offH[n].handIdx = 1;
			mainH[n].Tick(mo, RSVR_VRHand.HandPos(mo), mainFist);
			offH[n].Tick(mo, RSVR_VRHand.OffPos(mo), offFist);
		}
	}
}

// 1.5 (owner: "constantly firing when I walk around"). 1.4 measured the hand in the world and took
// the body's movement out, which a turn (the hand swings round the player) and the controller's
// position landing a tic apart from the body's both defeat: walking and turning read as blows.
// Now the hand is measured IN THE BODY'S OWN FRAME (from the pawn, turned by the pawn's angle),
// so walking, strafing and turning move nothing. A blow must then be all of:
//   fast         over PUNCH m/s in the body frame;
//   forward      mostly along the body's forward axis;
//   a real jab   the hand has travelled JAB_LEN forward within the last few tics;
//   out in front the hand ends at least FRONT ahead of the body.
// After a blow the hand must come back (RECOCK towards the body) or go still before the next.
class RSQ_FistHand play
{
	const PUNCH = 2.5;		// m/s
	const CALM = 0.35;		// of PUNCH: this slow counts as still
	const FORWARD = 0.7;	// share of the blow along the body's forward axis
	const JAB_LEN = 0.15;	// m forward within the window: a jab, not a twitch
	const FRONT = 0.25;		// m ahead of the body when the blow lands
	const RECOCK = 0.08;	// m back towards the body re-arms the fist
	const HIST = 6;			// tics of history (about 0.17 s)
	const REACH = 16.0;		// map units per tic the strike travels (it lives 2 tics)
	const JUMP = 0.5;		// m in one tic (17.5 m/s): faster than any arm, so the frame moved

	double fx[HIST], fy[HIST], fz[HIST];	// the hand in the body frame: forward, left, up
	int head, count;
	bool ready;
	double peak;			// forward reach at the last blow
	int handIdx;			// 0 main, 1 off (set by RSQ_Fists)

	void Tick(PlayerPawn mo, Vector3 hand, bool on)
	{
		if (!on)
		{
			count = 0;
			ready = false;
			return;
		}
		let cv = CVar.FindCVar('vr_vunits_per_meter');
		double vu = cv ? cv.GetFloat() : 34;
		if (vu <= 0)
			vu = 34;

		Vector3 d = hand - RSVR_HandSync.Body(mo);	// 2.0.3s: off the view's height, not the feet (vrhand.zs)
		double c = cos(mo.angle), s = sin(mo.angle);
		double lf = d.x * c + d.y * s;
		double ll = -d.x * s + d.y * c;
		double lu = d.z;

		// 1.99x (owner: "a bang sound when I load into a map"): about 15 tics into every map the
		// engine re-syncs its VR yaw to the new map (gl_openvr.cpp resetDoomYaw), and the hand's
		// world position turns round the body in ONE tic -- rig: lf -10.2 -> +10.2, ll -8.5 -> +8.5,
		// 26 units, about 27 m/s. That read as a jab: Melee/Swing and a punch on every map load.
		// No hand moves JUMP in a tic (a hard jab is under 0.3 m), so a step that big is the frame
		// changing, not the arm: the history starts again from here.
		if (count > 0 && (lf - fx[head], ll - fy[head], lu - fz[head]).Length() > JUMP * vu)
		{
			count = 0;
			ready = false;
		}
		int prev = head;
		head = (head + 1) % HIST;
		fx[head] = lf; fy[head] = ll; fz[head] = lu;
		if (count < HIST)
		{
			count++;
			if (count < 2)
				return;
		}

		Vector3 v = (lf - fx[prev], ll - fy[prev], lu - fz[prev]);	// map units per tic, body frame
		double speed = v.Length();
		double thr = PUNCH * vu / 35.;

		if (!ready)
		{
			// re-arm: the hand has come back towards the body, or gone still
			if (speed < thr * CALM || lf < peak - RECOCK * vu)
				ready = true;
			return;
		}
		if (speed < thr)
			return;
		if (RSQB_Punch.HandOnDoor(mo, handIdx))
			return;	// the weapon sets: a hand on a door is lifting it, not punching
		int kind = RSQB_Punch.Kind(v / speed, FORWARD);	// the weapon sets: 1 jab, 2 hook, 3 uppercut, 0 none
		if (kind == 0 || lf < (kind == 1 ? FRONT : FRONT * 0.5) * vu)
			return;
		// 2026-10-23: fx is a RING -- the live samples are at head, head-1, ... modulo HIST,
		// which is how grenade.zs, melee.zs and flick.zs all read theirs. Indexing it
		// linearly read stale entries from the last time the fists were out (count resets
		// to 0 but fx is never cleared) and missed live ones, so `back` could be a leftover
		// 0 and this test passed on any twitch for the first few tics after drawing them.
		double back = kind == 1 ? lf : kind == 3 ? lu : ll * (v.y >= 0 ? 1 : -1);
		double now = back;
		for (int i = 0; i < count; i++)
		{
			int k = (head - i + HIST) % HIST;
			back = min(back, kind == 1 ? fx[k] : kind == 3 ? fz[k] : fy[k] * (v.y >= 0 ? 1 : -1));
		}
		if (now - back < JAB_LEN * vu)
			return;

		ready = false;
		peak = lf;
		Vector3 dir = (v.x * c - v.y * s, v.x * s + v.y * c, v.z) / speed;	// back to the world

		// the weapon sets: an uppercut into a barrel kicks it up and away (no damage), as RSQ Melee's
		if (kind == 3 && RSQB_Punch.KickBarrel(mo, hand, dir, speed * 35. / vu))
		{
			RSQ_Fists.PunchUse(mo, hand, dir);
			return;
		}
		Name sn = mo.CountInv('PowerStrength') > 0 ? 'RSQB_PunchBerserk' : 'RSQB_Punch';
		class<Actor> sc = RSQ_Fists.Cls(sn);
		if (!sc)
			return;
		let a = Actor.Spawn(sc, hand, ALLOW_REPLACE);
		if (!a)
			return;
		a.target = mo;
		a.angle = VectorAngle(dir.x, dir.y);
		a.pitch = -asin(clamp(dir.z, -1, 1));
		a.vel = dir * REACH;
		RSQ_Fists.Record(a, handIdx, speed * 35. / vu);	// the swing's speed in m/s at the blow (map units a tic, body frame)
		RSQ_Fists.PunchUse(mo, hand, dir);
		mo.A_StartSound("Melee/Swing", CHAN_AUTO, CHANF_OVERLAP);
		if (RSQ.PlayerInt(mo, 'rsq_switch_log', 0) > 0)
			Console.Printf("RSQB punch t%d: %s, hand %d", mo.Level.maptime, kind == 1 ? "jab" : kind == 2 ? "hook" : "uppercut", handIdx);
	}
}

// 2.0.3y NO TRIGGER PUNCH (owner 11-06: "in bd my hands animate a punch, which isn't good... i just don't need the
// swinging fist automatically, when i swing it myself"; he chose "Nothing (option, on)"). rsq_no_trigger_punch, on, in VR:
// BD22's fists (Melee_Attacks, brutal22test6 actors/Weapons/Melee.dec, not redefined here) throw no canned punch on the
// trigger or alt fire. Read from Melee.dec: Fire is the jab (Hold -> Jab; a long hold -> LeftCrossHold; PSeq combos to
// RedoJab / LeftCross / Upper) and AltFire is the cross (A_Recoil(-2) -> Cross). Both spend at least two tics on their
// wind-up frames before the swing sound and the MeleeStrike, so when the fists' layer has just gone into the Fire
// sequence or the Cross sequence, it is put straight back to Ready (DoEffect runs after the player's think, the same tic).
// The buttons themselves are untouched (every mod still reads them), and so is everything else they do on the fists:
// Fire and AltFire with a grabbed enemy, a barrel, a fatality trophy, a Lost Soul or a fatality pending (GoFatality)
// jump to THEIR states (throw, shield, eat...), which this never touches. Punches you throw with your arm are untouched
// (fists.zs RSQ_FistHand with VR Punching, RSQ Melee's punch).
class RSQ_NoTrigPunch : Inventory
{
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE; +INVENTORY.UNTOSSABLE; +INVENTORY.QUIET }
	override void DoEffect()
	{
		Super.DoEffect();
		let mo = PlayerPawn(Owner);
		if (!mo || !mo.player)
			return;
		let p = mo.player;
		let w = p.ReadyWeapon;
		if (!w || w.GetClassName() != 'Melee_Attacks' || !RSVR_VRHand.InVR(mo)
			|| RSQ.PlayerInt(mo, 'rsq_no_trigger_punch', 1) == 0)
			return;
		let psp = p.FindPSprite(PSP_WEAPON);
		if (!psp || !psp.CurState)
			return;
		State f = w.FindState('Fire');
		State c = w.FindState('Cross');
		if (!(f && Actor.InStateSequence(psp.CurState, f)) && !(c && Actor.InStateSequence(psp.CurState, c)))
			return;
		State r = w.FindState('Ready');
		if (!r)
			return;
		p.SetPsprite(PSP_WEAPON, r);
		psp = p.FindPSprite(PSP_WEAPON);
		if (psp)
		{
			psp.x = 0;
			psp.y = WEAPONTOP;	// Fire's wind-up moved the layer (OffSet 0, 38)
		}
		p.refire = 0;
		if (RSQ.PlayerInt(mo, 'rsq_switch_log', 0) > 0)
			Console.Printf("RSQ no trigger punch t%d: BD22's canned punch stopped", mo.Level.maptime);
	}
}
