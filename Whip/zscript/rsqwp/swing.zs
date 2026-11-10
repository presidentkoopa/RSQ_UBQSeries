// swing.zs -- THE AIMED SWING ANCHOR (owner, approved 2026-11-03).
//
// While the whip weapon is in hand, the OTHER hand's alt-fire (the off hand's, with the whip in the main hand) casts
// an aim ray from that hand: a thin dotted line and the series' diamond where the whip would anchor -- gold when it
// may (a wall or a ceiling within Whip Reach, rsqwp_target_reach), red when it may not (out of reach, sky, a floor, a portal, a
// 3D middle texture, a polyobject). With the ray on a valid spot, the whip hand's own deliberate crack (wind-up and
// swing, unchanged) sends the whip there: it stretches out to the spot as a marked crack flies (Reach), latches,
// waits for its start if you are standing (grip or jump, below; both off: the old small hop), and from then it is the rope every snag becomes (core.zs: pendulum, reel,
// pump, climb, let go, momentum kept).
//
// Anchor (surveys/05_GRAPPLE_ROPES.md 3.1): the trace gives no normal, so it is rebuilt -- a ceiling's from its
// plane, a wall's from its line (right-hand normal of the front side, negated on the back) -- and then pointed
// toward the hand (the survey asks for the sign to be checked: both are logged). The anchor sits SWING_OFF map units
// off the surface along it, so the rope never pulls into the geometry. Ceilings follow their plane (a lift, a
// crusher: core.UpdateAnchor); walls are re-checked every 4 tics, traced along the normal into the face.
// Refused (survey 5.5, 5.7): sky (a ceiling of the sky flat, or a two-sided line's upper part between two sky
// ceilings), any portal on the way (FLineTraceData.NumPortals, a line portal hit), floors, 3D middle textures and
// polyobjects (their line's normal may not be the drawn face).
//
// AIM WITH OFF-HAND FIRE (owner 2026-11-03: "when offhand is empty / fist, holding offhand fire casts out a beam"):
// with the whip in the MAIN hand and the off hand empty or a fist (OffFree: no weapon, Doom's Fist, Brutal Doom VR's
// off hand RSQ_Hands, RSQ Saber's bare Force hand UBQS_ForceHand (what fills an empty off hand on the full set, rig
// 11-03), Brutal Doom's fists Melee_Attacks, RSQ Melee's gloves, anything named a fist -- the series' own tests:
// Saber's FistOff and IsBareHand, GunCards' EmptyHand, TacticalRig's OffEmptyName), HOLDING the off hand's FIRE casts the
// same ray. Its key (+oh_attack: QuestZDoom posts the off trigger as KEY_LSHIFT, Quest and SteamVR alike) is eaten
// with its release (whip.zs AimKey), so the off fist does not punch as well. A gun in the off hand fires as normal;
// the other hand's alt-fire aims in every case, as before. Switch: rsqwp_swing_ohfire ("Aim With Off-Hand Fire").
// With RSQ Saber's Force hand there, that press no longer holds the Force while the whip is out (its other button, the
// off alt-fire, was already the whip's); Aim With Off-Hand Fire off gives it back.
//
// THE RAY THAT VANISHED (owner 11-03: "it disappears instantly instead of staying drawn"): the eaten key's state,
// aimBtn, is one per PLAYER, but AimTick runs per HAND and cleared it whenever "this hand's weapon is gone" -- and the
// hand that is not the whip's never has a weapon tending it, so every tic the off hand's slot cleared the whip hand's
// key: the ray lived for the one tic of the press (the rig's console +oh_altatk sets the button, never the key, so
// the old proof never took the key's road; its one key run logged the ray held 1 tic of 165). Now cleared only when
// neither hand has the whip weapon.
//
// THE BEAM WINS (owner 2026-11-03: "the entire point of the offhand beam is that it takes precedence over any
// actor-lock-on ... we use the offhand beam to mark where we snag the whip, and the whip crack snags that spot").
// Switch rsqwp_swing_beamwins ("Beam Wins Over Lock-On", on). While the beam is ON -- held (gold or red), or let go
// within BEAM_MEMORY (35 tics, 1 s) of a GOLD spot (a beam that ended red forgets its spot) -- the crack's every
// other way to pick a target stands down (BeamWins): the trigger's MARK on a monster / pickup / switch (Mark), the
// LOCKED crack that flies to it (Crack), the edge snag at the tip (Crack's WrapNear and Collide's Snag), the crack's
// own target and fetch round the tip (Crack: no actor at all; owner 12:06 "traversal / offhand target first, then
// actors"), a thrown lasso (it flies into the air), and a monster the whip is still WRAPPED round lets go (Lash: a
// wrap blocks every crack). The thong flying to the spot strikes nothing on the way (Collide, casting). So the crack
// goes to the gold spot, or, red, is a plain crack (a switch it lands on still throws). No beam: every path as before. Off: the old 6-tic grace, no stand-down.
//
// NOT A TARGET (owner 11:35: "whip needs to not target bits, just enemies, weapons, items, and our offhand traversal
// marker"): RSQ Gun Bonsai VR's Kill Rewards bits (RSQ_KRHealthBit / ArmorBit / AmmoBit, any class named "RSQ_KR...")
// by NAME (NotATarget), so the whip still loads alone: never marked, locked, fetched, lassoed or cracked onto.
//
// SNAGGED: THE ROPE HOLDS, THE OFF HAND IS FREE (rsqwp_swing_offfree, on). The engine's off-hand switch (slot keys,
// `use`, RSQ TacticalRig's holster draw: PendingWeapon with the off-hand flag) and RSQ Wheel's instant equip touch the
// off hand only; nothing of the whip lets go on them, and an off-hand gun's fire is never eaten (AimKey: only a free
// off hand's). Off: a gun coming into the off hand of an aimed swing lets the rope go (core.SwingWatch).
//
// STARTING THE SWING (core.SwingStart, below). A latch FROM THE GROUND no longer hops or takes the rope up by itself
// while either start is on: you stand on the rope until you start (or step off). Started once per rope:
//   GRIP (rsqwp_swing_grip, on): an empty off hand closes (its grip key, or a grab bind) within GRIP_REACH (0.5 m) of
//     the whip hand or the rope -- two hands on the whip. The rope is taken up GRIP_LIFT (24 units, 0.7 m: one hand-
//     over-hand pull) more than the arc needs, at GRIP_PULL 6 a tic, with the old hop: you rise and swing from where
//     you stood. That press never becomes a climbing hold (the next one does). With SWING ASSIST: GRAB SNAG on
//     (rsqwp_swing_assist, the default) the hop is a lift and a forward speed instead (core.GrabAssist, below).
//   JUMP (rsqwp_swing_jump, on; any off hand): +jump's press (BT_JUMP, its edge). Up: vel.z = max(vel.z, Jump Lift),
//     so the engine's own floor jump that tic (JumpZ 8) is never stacked on (no double jump). Forward: Jump Push
//     along where you FACE, the part pointing away from the anchor taken out (the rope would only eat it) and the push
//     kept at full size along what is left -- added to the speed you had, all of it kept. Plus the arc's take-up.
// Netplay: like the mark (Mark), the aim reads the local hand pose in play; single player is exact.
extend class RSQWP_Whip
{
	const SWING_OFF = 4.0;       // the anchor this far off the surface, along its normal (map units)
	const SWING_HOP = 6.0;       // a standing player is lifted this much on the latch (map units a tic; a jump is 8)
	const AIM_GRACE = 6;         // the aim let go this many tics before the crack still casts (~0.17 s) -- Beam Wins off
	const BEAM_MEMORY = 35;      // Beam Wins on: a gold spot is remembered this long after the beam is let go (1 s)
	const AIM_STEP = 10.0;       // the dotted ray: a dot every this many map units ...
	const AIM_FROM = 6.0;        // ... from this far out of the hand
	const AIM_RED = 0xFF4030;    // the refused ray (the colour-blind palette's IDLE role takes it over)

	bool    aimHeld[NW];         // the other hand's alt-fire is held (weapon.zs Tend: the button, or the eaten key)
	int     aimTic[NW];          // the tic Tend last said so
	bool    aimBtn[MAXPLAYERS];  // that key, eaten in InputProcess so the gun in that hand does not alt-fire too
	bool    aimFire[MAXPLAYERS]; // the off hand's FIRE key, eaten while the off hand is empty or a fist (Aim With Off-Hand Fire)
	int     aimBy[NW];           // which button holds the ray: 1 the other hand's alt-fire, 2 the off hand's fire
	bool    aimShown[NW];
	int     aimBeamWas[NW];      // the beam's state last tic, for the log: 0 off, 1 held, 2 remembered
	bool    aimOk[NW];           // this tic's ray ends on an anchor
	Name    aimWhy[NW];          // what it hit: 'ceiling', 'wall', or why not
	Vector3 aimEnd[NW];          // where the ray ends (map)
	double  aimM[NW];            // how far, metres
	// the last valid anchor (cast within AIM_GRACE of letting the button go)
	int     okTic[NW];
	Vector3 okAt[NW], okHit[NW], okN[NW];
	Sector  okSec[NW];
	int     okPlane[NW];         // 2 a ceiling that follows its plane, 0 a wall (or a 3D floor's underside)
	// the cast under way (Reach) and the anchor it flies to
	bool    casting[NW];
	Vector3 castAt[NW], castHit[NW], castN[NW];
	Sector  castSec[NW];
	int     castPlane[NW];
	bool    outNow[NW];          // the next Start leaves the thong out (a chain: it comes straight off the rope)
	bool    indy[NW];            // Whip and Gun (IndyOn) this tic: weapon.zs Tend says so
	bool    aimFrozen[NW];       // Whip and Gun: the cursor is held where it was while a crack is under way (AimTick)
	// ... the cursor's last INDY_BACK + 1 tics (a ring by maptime): the hand's aim, and what the trace found then
	const INDY_BACK = 3;         // the sweep test looks this many tics back, and a hold starts from the cursor that far back
	const INDY_SWEEP = 9.0;      // ... a hand that turned more than this in those tics sweeps (3 degrees a tic, ~105 deg/s)
	Vector3 rgDir[NW * 4], rgEnd[NW * 4], rgAt[NW * 4], rgHit[NW * 4], rgN[NW * 4];
	int     rgTic[NW * 4], rgPlane[NW * 4];
	bool    rgOk[NW * 4], rgTraced[NW * 4];
	Name    rgWhy[NW * 4];
	double  rgM[NW * 4];
	Sector  rgSec[NW * 4];
	void AimKeep(int i, Vector3 d, bool traced)
	{
		int k = i * 4 + level.maptime % 4;
		rgTic[k] = level.maptime; rgDir[k] = d; rgTraced[k] = traced;
		rgOk[k] = aimOk[i]; rgWhy[k] = aimWhy[i]; rgEnd[k] = aimEnd[i]; rgM[k] = aimM[i];
		rgAt[k] = okAt[i]; rgHit[k] = okHit[i]; rgN[k] = okN[i]; rgSec[k] = okSec[i]; rgPlane[k] = okPlane[i];
	}
	// the slot of `back` tics ago, or -1
	int AimSlot(int i, int back)
	{
		int t = level.maptime - back;
		int k = i * 4 + ((t % 4) + 4) % 4;
		return rgTic[k] == t ? k : -1;
	}
	RSQWP_LockRing aimRing[NW];
	RSQWP_LockCentre aimCen[NW];

	// WHIP REACH (rsqwp_target_reach, 20 m; slider 3..MAX_REACH; owner 11-06, BUGS_1.0 item 30: one reach for everything):
	// the rangefinder's and the aimed swing's reach AND every mark's and lock's (whip.zs LockRange), in metres. The cap
	// (owner 11-03 20:14: "a range slider so it can be extended ... max generous"): measured on SWINGTST (11-03, on the
	// reach row of then) at 60, the rangefinder gold on B's east wall 56.3 m off, the crack cast there (8 tics) and
	// latched, a 1907-unit rope (the hook's range follows the reach where the cast builds it, SwingLatch, so nothing else
	// caps it). So 60 m, the longest sightline measured.
	const MAX_REACH = 60.0;
	static double SwingReachM() { return clamp(RSQWP_Util.Num("rsqwp_target_reach", 20), 3.0, MAX_REACH); }

	// An EMPTY OFF HAND, as the series tests it (see the top): nothing in it, or a fist of any of the parents'.
	static clearscope bool OffFree(PlayerInfo p)
	{
		if (!p) return false;
		return FreeHand(p.OffhandWeapon);
	}
	// a hand's weapon that is no weapon: nothing, or a fist (OffFree's test, for either hand)
	static clearscope bool FreeHand(Weapon off)
	{
		if (!off) return true;
		if (off is "Fist") return true;
		String n = off.GetClassName();
		n = n.MakeLower();
		return n == "rsq_hands" || n == "ubqs_forcehand" || n == "melee_attacks" || n == "rsq_glove" || n == "rsq_gloveoff" || n.IndexOf("fist") >= 0;
	}

	// WHIP AND GUN, "INDIANA JONES" (owner 11-10 12:27 / 12:30, "aim with the whip hand, we still target actors while holding
	// in primary fire. so with whip in hand we are free aiming the snag cursor, but holding the trigger makes it behave like
	// normal"; rsqwp_indy, on). The slot-1 whip weapon is in this hand and the OTHER hand holds a weapon (anything that is
	// not empty or a fist, FreeHand): the whip hand's own ray is the snag cursor while its trigger is up, the other hand's
	// buttons stay its own, no lasso, a one-handed swing. With the other hand empty or a fist, nothing changes.
	static clearscope bool IndyOn(PlayerInfo p, int hand)
	{
		if (!p || !RSQWP_Util.Flag("rsqwp_indy", true) || !RSQWP_Util.Flag("rsqwp_on", true) || !RSQWP_Util.Flag("rsqwp_swing", true)) return false;
		Weapon wh = hand ? p.OffhandWeapon : p.ReadyWeapon;
		Weapon other = hand ? p.ReadyWeapon : p.OffhandWeapon;
		return wh is "RSQWP_WhipWeapon" && other && !(other is "RSQWP_WhipWeapon") && !FreeHand(other);
	}

	// The off hand's FIRE aims the ray: the whip weapon in the main hand, the off hand free, the switches on.
	static clearscope bool OffFireAims(PlayerInfo p)
	{
		return p && p.ReadyWeapon is "RSQWP_WhipWeapon" && OffFree(p) && RSQWP_Util.Flag("rsqwp_swing_ohfire", true)
			&& RSQWP_Util.Flag("rsqwp_swing", true) && RSQWP_Util.Flag("rsqwp_on", true);
	}

	// ---- the beam wins -----------------------------------------------------------------------------------------

	static bool BeamWinsOn() { return RSQWP_Util.Flag("rsqwp_swing_beamwins", true); }
	int BeamMem() { return BeamWinsOn() ? BEAM_MEMORY : AIM_GRACE; }
	bool BeamHeld(int i) { return aimHeld[i] && level.maptime - aimTic[i] <= 1; }
	bool BeamMemory(int i) { return okTic[i] > 0 && level.maptime - okTic[i] <= BeamMem(); }

	// The beam is on for this whip (held, or a gold spot let go of within BEAM_MEMORY) and Beam Wins Over Lock-On is on:
	// no other target may be picked for the crack (see the top).
	bool BeamWins(int i)
	{
		if (!BeamWinsOn() || !byWeapon[i] || !RSQWP_Util.Flag("rsqwp_swing", true) || !RSQWP_Util.Flag("rsqwp_on", true)) return false;
		// WHIP AND GUN: the cursor is on whenever the trigger is up, so only a GOLD cursor wins (a red one is a plain crack
		// with every target path as before: the crack's own target, an edge snag, a fetch)
		if (indy[i]) return (BeamHeld(i) && aimOk[i]) || BeamMemory(i);
		return BeamHeld(i) || BeamMemory(i);
	}

	// RSQ Gun Bonsai VR's Kill Rewards bits, by name (the whip loads without it): never a whip target.
	static clearscope bool NotATarget(Actor a)
	{
		if (!a) return true;
		String n = a.GetClassName();
		n = n.MakeLower();
		return n.IndexOf("rsq_kr") == 0;
	}

	// ---- the aim, every tic -----------------------------------------------------------------------------------

	void AimTick(int i)
	{
		int pn = i / 2;
		int hand = i & 1;
		let pmo = playeringame[pn] ? players[pn].mo : null;
		bool on = pmo && pmo.Health > 0 && aimHeld[i] && level.maptime - aimTic[i] <= 1
			&& RSQWP_Util.Flag("rsqwp_swing", true) && RSQWP_Util.Flag("rsqwp_on", true);
		if (!on)
		{
			if (aimShown[i]) ClearAim(i);
			aimOk[i] = false;
			// the beam's memory (Beam Wins): logged as it starts and as it ends
			int bw = BeamWins(i) ? 2 : 0;
			if (bw != aimBeamWas[i] && aimBeamWas[i] != 0 && RSQWP_Util.Flag("rsqwp_debug", false))
				Console.Printf("T_WPW %d BEAM t%d %s", i, level.maptime, bw == 2 ? String.Format("let go: the gold spot is remembered %d tics", BeamMem()) : "off: every target path as before");
			aimBeamWas[i] = bw;
			// the whip weapon is gone from BOTH hands: no key stays held. (Not this hand's own tic: the hand without
			// the whip is never tended, and clearing on it took the key away the tic after the press.)
			if (pmo && level.maptime - aimTic[pn * 2] > 1 && level.maptime - aimTic[pn * 2 + 1] > 1) { aimBtn[pn] = false; aimFire[pn] = false; }
			return;
		}
		// WHIP AND GUN: the whip hand's own ray. Held still on a spot while a crack is under way (the wind-up points the hand
		// up and back, the swing sweeps it down: owner's "aim, then crack"): the cursor stays where it was when the wind-up
		// began (or the flick's stiffening), drawn there, its gold spot kept fresh until the gesture is over.
		int ah = indy[i] ? hand : 1 - hand;
		// ... and while the hand SWEEPS (it turned over INDY_SWEEP in the last INDY_BACK tics: the rise into the wind-up comes
		// before the wind-up is read, rig 11-10: a 43-degree aim at a ceiling 14.5 m off had become the ceiling 1.9 m overhead
		// by the tic the wind-up began). The hold starts from the cursor of INDY_BACK tics ago, before the sweep. A hand at
		// rest on its aim moves the cursor at once.
		bool sweep = false;
		Vector3 dnow = (1, 0, 0);
		if (indy[i])
		{
			dnow = RSQWP_Util.MapDir(RSQWP_Util.AimYaw(pmo, hand), RSQWP_Util.AimPitch(pmo, hand));
			int kb = AimSlot(i, INDY_BACK);
			sweep = kb >= 0 && acos(clamp(dnow dot rgDir[kb], -1.0, 1.0)) > INDY_SWEEP;
		}
		if (indy[i] && aimShown[i] && (sweep || (wstate[i] == ST_OUT && (windTics[i] > 0 || swinging[i] || stiff[i] > 0.01))))
		{
			Vector3 o0 = RSQWP_Util.AimPos(pmo, ah);
			int kb = AimSlot(i, INDY_BACK);
			if (!aimFrozen[i] && kb >= 0 && rgTraced[kb])
			{
				aimOk[i] = rgOk[kb]; aimWhy[i] = rgWhy[kb]; aimEnd[i] = rgEnd[kb]; aimM[i] = rgM[kb];
				if (aimOk[i]) { okAt[i] = rgAt[kb]; okHit[i] = rgHit[kb]; okN[i] = rgN[kb]; okSec[i] = rgSec[kb]; okPlane[i] = rgPlane[kb]; }
			}
			Vector3 sp = aimEnd[i] - o0;
			if (aimOk[i] && !casting[i]) okTic[i] = level.maptime;
			if (!aimFrozen[i] && RSQWP_Util.Flag("rsqwp_debug", false))
				Console.Printf("T_WPW %d CURSOR t%d held (%s %s, %.1f m): %s", i, level.maptime, aimOk[i] ? "GOLD" : "RED", aimWhy[i], aimM[i], sweep ? "the hand sweeps" : "a crack under way");
			aimFrozen[i] = true;
			aimBeamWas[i] = 1;
			DrawAim(i, o0, aimOk[i], aimEnd[i], sp.Length() > 0.01 ? sp.Unit() : (1, 0, 0));
			AimKeep(i, dnow, false);
			return;
		}
		aimFrozen[i] = false;
		Vector3 org = RSQWP_Util.AimPos(pmo, ah);
		Vector3 dir = RSQWP_Util.MapDir(RSQWP_Util.AimYaw(pmo, ah), RSQWP_Util.AimPitch(pmo, ah));
		double ps = RSQWP_Util.PS();
		double roomPerMap = sqrt(dir.x * dir.x + dir.y * dir.y + dir.z * ps * dir.z * ps);   // room units per map unit along dir
		double maxL = SwingReachM() * 34.0 / max(0.01, roomPerMap);
		FLineTraceData d;
		pmo.LineTrace(atan2(dir.y, dir.x), maxL, -asin(clamp(dir.z, -1.0, 1.0)), TRF_ABSPOSITION | TRF_THRUACTORS, org.z, org.x, org.y, d);
		Name why = 'none';
		Vector3 n = (0, 0, 0);
		int plane = 0;
		Vector3 hit = d.HitLocation;
		double nSurvey = 0;
		if (d.NumPortals > 0) why = 'portal';
		else if (d.HitType == TRACE_HitNone) { why = 'out of reach'; hit = org + dir * maxL; }
		else if (d.HitType == TRACE_HitFloor) why = 'floor';
		else if (d.HitType == TRACE_HitCeiling)
		{
			if (!d.Hit3DFloor && d.HitSector && d.HitSector.GetTexture(Sector.ceiling) == skyflatnum) why = 'sky';
			else
			{
				why = 'ceiling';
				n = d.Hit3DFloor ? (0, 0, -1) : (d.HitSector ? d.HitSector.ceilingplane.Normal : (0, 0, -1));
				plane = (!d.Hit3DFloor && d.HitSector) ? 2 : 0;
			}
		}
		else if (d.HitType == TRACE_HitWall && d.HitLine)
		{
			Line l = d.HitLine;
			bool skyWall = l.frontsector && l.backsector && d.LinePart == 0
				&& l.frontsector.GetTexture(Sector.ceiling) == skyflatnum && l.backsector.GetTexture(Sector.ceiling) == skyflatnum;
			if (l.isLinePortal()) why = 'portal';
			else if (skyWall) why = 'sky';
			else if ((l.sidedef[0] && (l.sidedef[0].Flags & Side.WALLF_POLYOBJ)) || (l.sidedef[1] && (l.sidedef[1].Flags & Side.WALLF_POLYOBJ))) why = 'polyobject';
			else if ((l.flags & Line.ML_3DMIDTEX) && d.LinePart == 1 && !d.Hit3DFloor) why = '3D midtex';
			else
			{
				why = 'wall';
				Vector2 dl = l.delta.Unit();
				n = (dl.y, -dl.x, 0);              // the front side's normal (survey 3.1) ...
				if (d.LineSide == Line.back) n = -n;   // ... negated on the back
			}
		}
		else why = 'no surface';
		bool ok = why == 'ceiling' || why == 'wall';
		Vector3 at = hit;
		if (ok)
		{
			// THE SIGN, checked (survey 3.1: "verify the sign empirically once"): the normal must face the hand
			Vector3 back = org - hit;
			nSurvey = n dot back;
			if (nSurvey < 0) n = -n;
			if (n.Length() < 0.5) { ok = false; why = 'no surface'; }
			else
			{
				n = n.Unit();
				at = hit + n * SWING_OFF;
				// the anchor must be in the open (a corner may leave the 4-unit step inside another face)
				Sector s = level.PointInSector(at.xy);
				if (!s || at.z <= s.floorplane.ZatPoint(at.xy) + 1 || at.z >= s.ceilingplane.ZatPoint(at.xy) - 1) { ok = false; why = 'no room'; }
			}
		}
		bool changed = ok != aimOk[i] || why != aimWhy[i];
		aimOk[i] = ok; aimWhy[i] = why; aimEnd[i] = ok ? at : hit;
		aimM[i] = RSQWP_Util.Metres(hit - org);
		if (ok)
		{
			okTic[i] = level.maptime; okAt[i] = at; okHit[i] = hit; okN[i] = n; okPlane[i] = plane;
			okSec[i] = d.HitSector;
		}
		else if (BeamWinsOn()) okTic[i] = -100;   // the beam's last word is red: no gold spot is remembered
		if (BeamWinsOn() && aimBeamWas[i] != 1 && RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d BEAM t%d on (held): %s", i, level.maptime, indy[i] ? "Whip and Gun's cursor (only a gold cursor stands the other targets down)" : "lock-on, marks, edge snag and Assist's reach stand down");
		aimBeamWas[i] = 1;
		if (changed && RSQWP_Util.Flag("rsqwp_debug", false))
		{
			if (ok) Console.Printf("T_WPW %d AIM t%d VALID %s at (%.0f %.0f %.0f) %.1f m, normal (%.2f %.2f %.2f) (survey's sign %s), anchor (%.0f %.0f %.0f)", i, level.maptime, why, hit.x, hit.y, hit.z, aimM[i], n.x, n.y, n.z, nSurvey >= 0 ? "faces the hand" : "flipped", at.x, at.y, at.z);
			else Console.Printf("T_WPW %d AIM t%d INVALID: %s (%.1f m, portals %d)", i, level.maptime, why, aimM[i], d.NumPortals);
		}
		DrawAim(i, org, ok, ok ? at : hit, dir);
		if (indy[i]) AimKeep(i, dnow, true);
		if (RSQWP_Util.Opt("rsqwp_debug", 0) == 5)
			Console.Printf("T_WPW %d RAY t%d drawn by %s: %s %s, %.1f m, %d dots, diamond %s", i, level.maptime, aimBy[i] == 2 ? "off-hand fire" : "alt-fire",
				ok ? "GOLD" : "RED", why, aimM[i], aimDots, aimRing[i] ? "on" : "none");
	}

	// The ray: a thin dotted line of full-bright particles from the hand to where it ends (gold: the whip would
	// anchor there; red: it would not), and the series' diamond on the spot (gold ring and white centre) or a red
	// ring where a refused ray ends. Colour-blind palette: COULD / IDLE.
	int aimDots;
	void DrawAim(int i, Vector3 org, bool ok, Vector3 end, Vector3 dir)
	{
		aimShown[i] = true;
		aimDots = 0;
		// WHIP AND GUN (owner 11-10): its cursor is drawn only when it can snag (gold); a red one is not drawn (the state
		// and the freeze behave the same, only the dots are left out). The slot-1 aimed swing's red ray is unchanged.
		if (indy[i] && !ok) return;
		int col = ok ? RSQWP_CB.Pick(RSQWP_CB.CB_COULD, RSQWP_LockRing.GOLD) : RSQWP_CB.Pick(RSQWP_CB.CB_IDLE, AIM_RED);
		Vector3 span = end - org;
		double len = span.Length();
		if (len > AIM_FROM)
		{
			Vector3 u = span / len;
			FSpawnParticleParams p;
			p.color1 = col;
			p.style = STYLE_Add;
			p.flags = SPF_FULLBRIGHT;
			p.lifetime = 1;
			p.size = 2.0;
			p.sizestep = 0;
			p.startalpha = ok ? 0.9 : 0.6;
			p.fadestep = 0;
			for (double t = AIM_FROM; t < len - 2; t += AIM_STEP)
			{
				p.pos = org + u * t;
				level.SpawnParticle(p);
				aimDots++;
			}
		}
		double sc = 0.35 * RSQWP_A11y.Cue() * clamp(RSQWP_Util.Metres(span) / 5.0, 1.0, 3.0) * (ok ? 1.0 : 0.6);
		if (!aimRing[i]) { aimRing[i] = RSQWP_LockRing(Actor.Spawn("RSQWP_LockRing", end, NO_REPLACE)); if (aimRing[i]) aimRing[i].ClearInterpolation(); }
		if (aimRing[i])
		{
			aimRing[i].SetOrigin(end, true);
			aimRing[i].scale = (sc, sc);
			aimRing[i].SetShade(col);
		}
		if (ok)
		{
			if (!aimCen[i]) { aimCen[i] = RSQWP_LockCentre(Actor.Spawn("RSQWP_LockCentre", end, NO_REPLACE)); if (aimCen[i]) aimCen[i].ClearInterpolation(); }
			if (aimCen[i]) { aimCen[i].SetOrigin(end, true); aimCen[i].scale = (sc, sc); }
		}
		else if (aimCen[i]) { aimCen[i].Destroy(); aimCen[i] = null; }
	}

	void ClearAim(int i)
	{
		aimShown[i] = false;
		if (aimRing[i]) aimRing[i].Destroy();
		if (aimCen[i]) aimCen[i].Destroy();
		aimRing[i] = null; aimCen[i] = null;
	}

	// ---- the cast ---------------------------------------------------------------------------------------------

	// Called first thing by a crack of the whip weapon. The ray held on a valid spot (or let go of within AIM_GRACE
	// with a valid spot): the thong flies there (Reach) and latches (SwingLatch). The ray held on a refused spot:
	// an ordinary crack, and the log says why.
	bool SwingCast(int i, PlayerPawn pmo, int hand, Vector3 at)
	{
		if (!byWeapon[i] || !RSQWP_Util.Flag("rsqwp_swing", true)) return false;
		bool held = BeamHeld(i);
		bool use = held ? aimOk[i] : BeamMemory(i);
		if (!use)
		{
			if (held && RSQWP_Util.Flag("rsqwp_debug", false))
				Console.Printf("T_WPW %d CAST t%d refused: %s (%.1f m) -- an ordinary crack%s", i, level.maptime, aimWhy[i], aimM[i], BeamWins(i) ? " (the beam still wins: no lock-on, no mark, no snag)" : "");
			return false;
		}
		int memAge = level.maptime - okTic[i];
		castAt[i] = okAt[i]; castHit[i] = okHit[i]; castN[i] = okN[i]; castSec[i] = okSec[i]; castPlane[i] = okPlane[i];
		casting[i] = true;
		okTic[i] = -100;                // one cast per aim
		reachFor[i] = null;
		reachPt[i] = castAt[i];
		Vector3 h0 = RSQWP_Util.HandPos(pmo, hand);
		double dist = (castAt[i] - h0).Length();
		reachTic[i] = clamp(int(dist / 64.0 + 0.5), REACH_TICS, 8);
		lockLeft[i] = 0; lockOn[i] = null; lockLine[i] = false; lock2[i] = null; reach2[i] = null;
		Noise(pmo, 'crack', at, i);
		Buzz(pmo, hand, 1.0, 5);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d CAST #%d t%d -> %s anchor (%.0f %.0f %.0f), %.1f m, flies %d tics (%s)", i, cracks[i], level.maptime,
				castPlane[i] == 2 ? "ceiling" : "wall", castAt[i].x, castAt[i].y, castAt[i].z, RSQWP_Util.Metres(castAt[i] - h0), reachTic[i],
				held ? "beam held" : String.Format("beam let go %d tics ago, remembered", memAge));
		return true;
	}

	// The thong reached the aimed spot: core's hook, built as Snag builds it, at the anchor off the surface. A
	// ceiling follows its plane; a wall (or a 3D floor's underside) is re-checked along the normal into the face.
	void SwingLatch(int i, PlayerPawn pmo, int hand)
	{
		let core = RSQWP_Core.Get();
		if (!core) return;
		let old = core.hooks[i];
		if (old)
		{
			if (old.phase != RSQWP_Hook.PH_RETRACT) return;
			old.Destroy(); core.hooks[i] = null;
		}
		Vector3 at = castAt[i];
		let h = RSQWP_Hook(Actor.Spawn("RSQWP_Hook", at, NO_REPLACE));
		if (!h) return;
		Vector3 hand0 = RSQWP_Util.HandPos(pmo, hand);
		Vector3 ldir = (at - hand0).Unit();
		h.owner = pmo;
		h.hand = hand;
		h.dir = ldir;
		h.speed = 40;                // read by core.zs Fly only (a claw in flight; none in this mod). rsqwp_speed was never defined (11-10)
		h.range = max(1024.0, SwingReachM() * 34.0);   // 1024 the default the never-defined rsqwp_range fell back to (11-10); a longer Whip Reach wins
		h.angle = atan2(ldir.y, ldir.x);
		h.traveled = (at - hand0).Length();
		h.anchor = at;
		h.hitDir = -castN[i];           // into the face: core's wall check traces from struck along it
		h.SetOrigin(at, true);
		// A WALL: the arc's bottom is straight under the anchor, so an anchor 4 units off the face would hang the body
		// inside the wall's reach (rig: the swing ran into the wall at the bottom and died there). The rope's point is
		// put the body's radius further out; the rope is still drawn to the face (the hook's place).
		if (castPlane[i] != 2 && abs(castN[i].z) < 0.5)
		{
			h.anchor = castHit[i] + castN[i] * (pmo.radius + SWING_OFF);
			h.SetOrigin(castHit[i] + castN[i] * 1.0, true);
		}
		h.anchorSec = castSec[i];
		h.anchorPlane = 0;
		if (castPlane[i] == 2 && castSec[i])
		{
			h.anchorPlane = 2;
			h.planeOfs = at.z - castSec[i].ceilingplane.ZatPoint(at.xy);
		}
		h.whipped = true;
		h.aimed = true;
		h.launch = true;
		h.struck = castHit[i];          // on the face itself (core: struck - hitDir x 6 = 6 out, traced 16 in)
		core.hooks[i] = h;
		core.Latch(h, i);
		// A SWITCH OR A DOOR where the aimed swing latched on a wall: worked as the crack works one (owner, BUGS_1.0 item 13;
		// whip.zs UseLine), the wall right at the hit
		if (castPlane[i] != 2 && abs(castN[i].z) < 0.5 && RSQWP_Util.Flag("rsqwp_whip_lines", true)) Switches(pmo, castHit[i], 4);
		bool grounded = pmo.pos.z <= pmo.floorz + 0.5 || pmo.bOnMobj;
		double hop = 0;
		if (h.phase == RSQWP_Hook.PH_LATCH)
		{
			// A SWING FROM THE GROUND: the arc's bottom must clear the floor under the anchor (feet and 8 units), or a
			// standing player only drags along it. Longer than that, the rope is taken up to it (core.Swing, at
			// TAKEUP a tic, as a reel), lifting him into the arc. Too low an anchor for any swing: no take-up.
			double attachH = pmo.Height * RSQWP_Util.Num("rsqwp_attach", 0.6);
			Vector3 an = h.anchor;
			Sector us = level.PointInSector(an.xy);
			double fz = us ? us.floorplane.ZatPoint(an.xy) : pmo.floorz;
			double want = an.z - fz - attachH - 8;
			double minLen = RSQWP_Util.Num("rsqwp_min_len", 32);
			h.autoLen = (want >= minLen && want < h.ropeLen - 1) ? want : 0;
			h.fullLen = h.autoLen > 0 ? 0 : h.ropeLen;
			// THE START WAITS (owner 11-03: snag, then grip or jump to begin): from the ground, with a start on, no hop
			// and no take-up yet -- the take-up is kept for the start (core.SwingStart). In the air it swings at once.
			// (Whip and Gun: one hand on the whip, so only a jump can start it; Jump Starts Swing off: the old hop)
			if (grounded && (indy[i] ? RSQWP_Util.Flag("rsqwp_swing_jump", true) : RSQWP_Core.StartsOn()))
			{
				h.startLen = h.autoLen;
				h.autoLen = 0;
				h.fullLen = h.ropeLen;
				h.waiting = true;
			}
			else if (grounded) { hop = SWING_HOP; pmo.vel.z = max(pmo.vel.z, hop); }
		}
		Noise(pmo, 'crack', at, i);
		Buzz(pmo, hand, 0.7, 6);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW %d SWING LATCH t%d %s at (%.0f %.0f %.0f), rope %.0f, take-up to %.0f, hop %.0f, player (%.0f %.0f %.0f) vel (%.1f %.1f %.1f)%s", i, level.maptime,
				h.anchorPlane == 2 ? "ceiling" : "wall", h.anchor.x, h.anchor.y, h.anchor.z, h.ropeLen, h.autoLen, hop, pmo.pos.x, pmo.pos.y, pmo.pos.z, pmo.vel.x, pmo.vel.y, pmo.vel.z,
				h.waiting ? String.Format(" -- waiting for a start (grip / jump), its take-up %.0f", h.startLen) : "");
		Halt(i);
	}
}

// ---- the snagged state and the starts (core's side: it runs the rope, after the player's think) ---------------
extend class RSQWP_Core
{
	const GRIP_LIFT = 24.0;      // a grip start takes the rope up this much more than the arc needs (map units, ~0.7 m): one pull
	const GRIP_PULL = 6.0;       // ... at this pace a tic (a hand-over-hand pull, ~6 m/s for a few tics; the floor's take-up too)
	const GRIP_REACH_M = 0.5;    // the off hand closes within this of the whip hand or the rope (metres)

	bool jumpWas[MAXPLAYERS], gripWas[MAXPLAYERS], offFreeWas[MAXPLAYERS];
	bool jumpEdge[MAXPLAYERS], gripEdge[MAXPLAYERS];

	static bool StartsOn() { return RSQWP_Util.Flag("rsqwp_swing_grip", true) || RSQWP_Util.Flag("rsqwp_swing_jump", true); }

	// once a tic per player (Swing): the jump press (BT_JUMP's edge) and the off hand's grip press (its key, or a grab bind)
	void SwingInput(PlayerPawn pmo, int pn)
	{
		bool j = pmo.player && (pmo.player.cmd.buttons & BT_JUMP);
		let w = RSQWP_Whip.Get();
		bool g = grabHeld[pn * 2 + 1] || (w && w.offGripKey[pn]);
		jumpEdge[pn] = j && !jumpWas[pn];
		gripEdge[pn] = g && !gripWas[pn];
		jumpWas[pn] = j; gripWas[pn] = g;
	}

	// OFF HAND FREE WHILE SNAGGED. On (the default): nothing here -- the off hand may take any gun. Off: an aimed swing's
	// rope is let go the tic a gun (anything not an empty hand, swing.zs OffFree) comes into the off hand.
	bool SwingWatch(RSQWP_Hook h, PlayerPawn pmo, int pn)
	{
		bool free = RSQWP_Whip.OffFree(pmo.player);
		bool was = offFreeWas[pn];
		offFreeWas[pn] = free;
		if (h.phaseAge <= 1 || !h.whipped || free == was) return false;
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW SNAGGED t%d off hand now %s: %s", level.maptime, pmo.player.OffhandWeapon ? pmo.player.OffhandWeapon.GetClassName() : 'none',
				free ? "empty again" : (RSQWP_Util.Flag("rsqwp_swing_offfree", true) || !h.aimed ? "the rope holds (Off Hand Free While Snagged)" : "lets go (Off Hand Free While Snagged is off)"));
		if (!free && h.aimed && !RSQWP_Util.Flag("rsqwp_swing_offfree", true)) { held[pn * 2 + h.hand] = false; LetGo(h, true); return true; }
		return false;
	}

	// Is the off hand within GRIP_REACH_M of the whip hand or of the rope (the whip in both hands)?
	bool GripNear(RSQWP_Hook h, PlayerPawn pmo, int pn, out double m)
	{
		m = 99;
		bool ok; Vector3 off;
		[ok, off] = RSQWP_Climb.HandOffset(pmo, pn, 1);
		if (!ok) return false;
		Vector3 hp = pmo.Pos + off;
		Vector3 wh = RSQWP_Util.HandPos(pmo, h.hand);
		double dh = RSQWP_Util.Metres(hp - wh);
		double dr = RSQWP_Util.Metres(hp - (AttachPoint(pmo) + (h.anchor - AttachPoint(pmo)) * clamp(((hp - AttachPoint(pmo)) dot (h.anchor - AttachPoint(pmo))) / max(0.0001, (h.anchor - AttachPoint(pmo)) dot (h.anchor - AttachPoint(pmo))), 0.0, 1.0)));
		m = min(dh, dr);
		return m <= GRIP_REACH_M;
	}

	// SWING ASSIST: GRAB SNAG (owner 11-04 19:49: "grab the damn thing and be lifted up a little and moved forward at a
	// reasonable speed, as a toggle"; rsqwp_swing_assist, on). The grip start, once per rope (h.started), gives a
	// one-shot lift and a forward speed instead of the grip's small hop; from the next tic the rope runs as ever
	// (pendulum, reel, climb, mantle, let go with the speed kept). Up: vel.z = max(vel.z, Assist Lift) -- never stacked
	// on a jump already rising. Forward: level, toward the point under the anchor (where you face if you stand under
	// it); the speed along it is raised to Assist Speed, never cut (a run you already had is kept), and the rest of your
	// speed kept. Then the swing's cap (CapSpeed: Gun Bonsai VR's Momentum raises it). The player runs on real time under
	// RSQ SlowMo (util.zs WorldScale: only the world slows), so -- like the jump start -- nothing is scaled.
	static double AssistLift() { return clamp(RSQWP_Util.Num("rsqwp_swing_assistlift", 8), 0.0, 20.0); }
	static double AssistSpeed() { return clamp(RSQWP_Util.Num("rsqwp_swing_assistspeed", 10), 0.0, 30.0); }
	Vector3 GrabAssist(RSQWP_Hook h, PlayerPawn pmo)
	{
		pmo.vel.z = max(pmo.vel.z, AssistLift());
		Vector2 d = h.anchor.xy - pmo.Pos.xy;
		Vector2 f = d.Length() > 16 ? d.Unit() : Actor.AngleToVector(pmo.Angle, 1);
		double along = pmo.vel.xy dot f;
		double want = AssistSpeed();
		if (along < want) pmo.vel += (f * (want - along), 0);
		return (f, 0);
	}

	// THE START (see swing.zs's top): once per rope, by the off hand's grip (an aimed swing, the off hand empty) or by a
	// jump (any whip rope, any off hand). True when it started this tic.
	bool SwingStart(RSQWP_Hook h, PlayerPawn pmo, int pn, bool grounded, double minLen)
	{
		if (h.started || !h.whipped || h.heavy || h.victim || !pmo.player) return false;
		bool jump = jumpEdge[pn] && RSQWP_Util.Flag("rsqwp_swing_jump", true);
		double gm = 99;
		bool grip = !jump && h.aimed && gripEdge[pn] && RSQWP_Util.Flag("rsqwp_swing_grip", true) && RSQWP_Whip.OffFree(pmo.player) && GripNear(h, pmo, pn, gm);
		if (!jump && !grip)
		{
			if (gripEdge[pn] && h.aimed && RSQWP_Util.Flag("rsqwp_debug", false))
				Console.Printf("T_WPW START t%d grip not taken: off hand %s, %.2f m from the whip", level.maptime, RSQWP_Whip.OffFree(pmo.player) ? "empty" : "holds a gun", gm);
			return false;
		}
		h.started = true;
		h.waiting = false;
		Vector3 v0 = pmo.vel;
		double len0 = h.ropeLen;
		// the take-up: what the arc needs to clear the floor (kept from the latch), and a grip's GRIP_LIFT on top
		double want = h.startLen;
		if (grip)
		{
			double g = max(minLen, min(h.ropeLen, (h.anchor - AttachPoint(pmo)).Length()) - GRIP_LIFT);
			want = want > 0 ? min(want, g) : g;
		}
		if (want >= minLen && want < h.ropeLen - 1) { h.autoLen = want; h.fullLen = 0; }
		h.takeRate = grip ? GRIP_PULL : 0;
		Vector3 fd = (0, 0, 0);
		bool assist = grip && RSQWP_Util.Flag("rsqwp_swing_assist", true);
		if (grip)
		{
			if (assist)
			{
				fd = GrabAssist(h, pmo);
				// the take-up (a reel) holds the speed in toward the anchor to 1.5 x its pace (core.Swing): at GRIP_PULL it
				// ate the assist (rig: 12 forward -> 7.3 the next tic). Its pace follows the assist instead.
				h.takeRate = max(GRIP_PULL, pmo.vel.Length() / 1.5);
			}
			else if (grounded) pmo.vel.z = max(pmo.vel.z, RSQWP_Whip.SWING_HOP);
			// this press is the start, not a climbing hold (the next press climbs)
			wantGrip[pn * 2 + 1] = false;
			if (h.gripHand == 1) h.gripHand = -1;
		}
		else
		{
			double lift = clamp(RSQWP_Util.Num("rsqwp_swing_jumplift", 10), 0.0, 30.0);
			double push = clamp(RSQWP_Util.Num("rsqwp_swing_jumppush", 8), 0.0, 30.0);
			// up: never stacked on the engine's own floor jump of this tic (it has already set vel.z = JumpZ)
			pmo.vel.z = max(pmo.vel.z, lift);
			// forward: where you face, its part away from the anchor taken out, the push kept whole along the rest
			Vector3 f = (Actor.AngleToVector(pmo.Angle, 1), 0);
			Vector3 r = AttachPoint(pmo) - h.anchor;
			double rl = r.Length();
			if (rl > 1)
			{
				Vector3 n = r / rl;
				double outw = f dot n;
				if (outw > 0)
				{
					Vector3 t = f - n * outw;
					if (t.Length() > 0.2) f = t.Unit();
				}
			}
			fd = f;
			pmo.vel += f * push;
		}
		CapSpeed(pmo);
		Carry(pmo);
		if (RSQWP_Util.Flag("rsqwp_debug", false))
			Console.Printf("T_WPW START t%d by %s%s%s: rope %.0f, take-up to %.0f; vel (%.1f %.1f %.1f) %.1f flat %.1f -> (%.1f %.1f %.1f) %.1f flat %.1f; push dir (%.2f %.2f %.2f); off hand %s",
				level.maptime, jump ? "JUMP" : "GRIP", grip ? String.Format(" (%.2f m from the whip)", gm) : (grounded ? " from the ground" : " in the air"),
				grip ? (assist ? String.Format(" ASSIST lift %.1f speed %.1f", AssistLift(), AssistSpeed()) : " no assist (Swing Assist: Grab Snag off)") : "", len0, h.autoLen,
				v0.x, v0.y, v0.z, v0.Length(), v0.xy.Length(), pmo.vel.x, pmo.vel.y, pmo.vel.z, pmo.vel.Length(), pmo.vel.xy.Length(), fd.x, fd.y, fd.z,
				pmo.player.OffhandWeapon ? pmo.player.OffhandWeapon.GetClassName() : 'none');
		return true;
	}
}
