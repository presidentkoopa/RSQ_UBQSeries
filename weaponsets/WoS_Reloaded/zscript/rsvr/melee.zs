// RS VR melee for Brutal Doom v22 on QuestZDoom 17.3 (stock engine).
//
// Axe (BrutalAxe) and Dragonslayer (DSweap): swing the controller and the blade
// hits whatever it passes through. The hit is BD22's own attack actor (AxeAttack,
// AxeAttackNoDecal, DSAttack, DSAttack2) started at the point and height where
// the blade met the body, so BD22's gore rules decide the result: its blood
// actors mark a head or leg hit from the impact height, and the Saw / Cut deaths
// take heads, legs, arms or cut the body in half from there.
//
// Axe throw (VR throwing on): hold the TRIGGER, swing, let go -- like the grenade. Alt-fire
// does the same. Either way: BD22's thrown axe (ThrowedAxe, or
// ThrowedAxeStrong with berserk) leaves the hand with the hand's speed.
//
// 2.0.2 (owner r3 item 37: "I want two dual-wield axes and not have to two-hand them ever"): the axe is
// NEVER two-handed -- no AXE2 placement, no two-handed bite, no rule against throwing it. It dual-wields
// instead: RSQ_Off_BrutalAxe (Axe.dec, dual.zs / dualtable.zs index 11) in the off hand swings, cuts and
// throws from that hand exactly as the main axe does from its own (offHands[] below: the same RSVR_Hand,
// reading the OFF controller's pose history and the off-hand weapon layer).
//
// The trigger keeps BD22's own chop. Outside VR nothing here does anything and
// the axe's alt-fire is BD22's sideways swing.

class RSVR_MeleeHandler : EventHandler
{
	RSVR_Hand hands[MAXPLAYERS];
	RSVR_Hand offHands[MAXPLAYERS];	// 2.0.2: the off-hand axe (RSQ_Off_BrutalAxe)

	// rsvr_axe_keys: the weapon hand's grip arrives as a KEY, not a usercmd button, so its codes
	// become a synchronised event the same way rsr_grip_keys does in vreload.zs. Every machine
	// sees the same down and up, so readying a throw is never a local-only decision.
	bool keyDown[MAXPLAYERS];
	ui Array<int> axeKeys;
	ui String axeKeysFrom;
	ui bool keyIsDown;

	static bool KeyHeld(PlayerPawn mo)
	{
		let h = RSVR_MeleeHandler(EventHandler.Find('RSVR_MeleeHandler'));
		if (!h || !mo || !mo.player)
			return false;
		int n = mo.PlayerNumber();
		return n >= 0 && n < MAXPLAYERS && h.keyDown[n];
	}

	bool offGrip[MAXPLAYERS];	// F11: the off grip (rsr_grip events, sent by vreload.zs InputProcess)
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "rsr_grip" && e.Player >= 0 && e.Player < MAXPLAYERS)
			offGrip[e.Player] = e.Args[0] != 0;
		if (e.Name != "rsvr_axe_grip")
			return;
		int n = e.Player;
		if (n >= 0 && n < MAXPLAYERS && playeringame[n])
			keyDown[n] = e.Args[0] != 0;
	}

	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown && e.Type != InputEvent.Type_KeyUp)
			return false;
		let me = players[consoleplayer];
		let cv = CVar.GetCVar('rsvr_axe_keys', me);
		String keys = cv ? cv.GetString() : "";
		if (keys != axeKeysFrom)
		{
			axeKeysFrom = keys;
			axeKeys.Clear();
			Array<String> w;
			keys.Split(w, " ", TOK_SKIPEMPTY);
			for (int j = 0; j < w.Size(); j++)
				axeKeys.Push(w[j].ToInt());
		}
		if (axeKeys.Size() == 0 || axeKeys.Find(e.KeyScan) == axeKeys.Size())
			return false;
		bool down = e.Type == InputEvent.Type_KeyDown;
		if (down == keyIsDown)
			return false;			// key repeat: only the edges are worth a net event
		keyIsDown = down;
		EventHandler.SendNetworkEvent("rsvr_axe_grip", down ? 1 : 0, e.KeyScan);
		return false;				// never eaten: the grip keeps whatever else it does
	}

	// 2026-10-23 (owner): a new map starts clean, as the reload handlers now do. The hand
	// keeps the blade's last position in the BODY's frame, and the first tic of a new map
	// would otherwise difference it against where the blade was in the old one -- a large
	// bogus velocity, which is a phantom swing on spawn. The teleport guard in Tick catches
	// most of that (a jump over 64 units, or a yaw change over 12 degrees) but neither is
	// guaranteed across an exit. The lock-on goes too: its target and ring were actors of
	// the old level.
	override void WorldLoaded(WorldEvent e)
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			keyDown[n] = false;	// a grip held through the exit is not a throw readied here
			if (!hands[n])
				continue;
			hands[n].Reset();
			hands[n].Unlock();
			hands[n].kind = 0;	// so the next Tick re-reads the weapon rather than trusting it
		}
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!offHands[n])
				continue;
			offHands[n].Reset();
			offHands[n].Unlock();
			offHands[n].kind = 0;
		}
		axePickups.Clear();
	}

	override void WorldTick()
	{
		AxePickupTick();
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo)
				continue;
			if (!hands[i])
				hands[i] = new('RSVR_Hand');
			let mo = players[i].mo;
			hands[i].Tick(mo);
			if (!offHands[i])
			{
				offHands[i] = new('RSVR_Hand');
				offHands[i].off = true;
			}
			offHands[i].Tick(mo);
			// 2.0.2: the off-hand axe's trigger throws it, the grenade's way, with VR throwing on (Axe.dec RSQ_Off_BrutalAxe)
			mo.SetInventory('RSVR_OffAxeVRThrow', RSVR_VRHand.InVR(mo) && RSR.PlayerInt(mo.player, 'rsg_vr', 1) != 0
				&& RSVR_Hand.KindOfOff(mo) == RSVR_Hand.AXE ? 1 : 0);
			// 2.0.2: the off axe was thrown: the off hand goes back to the fist and the copy is put away
			// until a thrown axe is picked up again (AxePickupTick)
			if (mo.CountInv('RSVR_OffAxeGone') > 0)
			{
				let ow = mo.player.OffhandWeapon;
				if (ow && ow is 'RSQ_Off_BrutalAxe')
				{
					if (mo.player.PendingWeapon == WP_NOCHANGE)
					{
						let fist = Weapon(mo.FindInventory('RSQ_Hands'));
						if (!fist)
						{
							mo.GiveInventory('RSQ_Hands', 1);
							fist = Weapon(mo.FindInventory('RSQ_Hands'));
						}
						if (fist)
							mo.player.PendingWeapon = fist;
					}
				}
				else
				{
					mo.TakeInventory(RSVR_MeleeHandler.Inv('RSQ_Off_BrutalAxe'), 1);
					mo.TakeInventory('RSVR_OffAxeGone', 1);
				}
			}
			// RSVR_AxeHold lets the axe's Ready state enter its hold loop from the grip. The
			// hold used to be reachable only from alt-fire, so no other button could ever ready
			// a throw however the cvars were set (owner, 2026-10-13: throwing should be hold and
			// release the grip). Only in VR: out of VR the axe keeps BD22's own sideways swing.
			bool want = RSVR_VRHand.InVR(mo) && RSVR_Hand.HoldDown(mo)
				&& mo.player.ReadyWeapon && RSVR_Hand.KindOf(mo) == RSVR_Hand.AXE;
			mo.SetInventory('RSVR_AxeHold', want ? 1 : 0);
			// VR throwing on (rsg_vr): the axe's trigger throws it the grenade's way (Axe.dec Fire)
			bool trigThrow = RSVR_VRHand.InVR(mo) && RSR.PlayerInt(mo.player, 'rsg_vr', 1) != 0
				&& mo.player.ReadyWeapon && RSVR_Hand.KindOf(mo) == RSVR_Hand.AXE;
			mo.SetInventory('RSVR_AxeVRThrow', trigThrow ? 1 : 0);
			// F11: the sword goes two-handed on the off grip held near it. 2.0.2 (owner r3 item 37): the AXE
			// never does -- no RSVR_AxeTwo, no AXE2 placement (Axe.dec), no two-handed bite, and it always throws.
			int mk = mo.player.ReadyWeapon ? RSVR_Hand.KindOf(mo) : 0;
			bool meleeTwo = RSVR_VRHand.InVR(mo) && mk == RSVR_Hand.SWORD
				&& offGrip[i] && RSVR_VRHand.SteadyGap(mo) < 50.0;
			mo.SetInventory('RSVR_MeleeTwo', meleeTwo ? 1 : 0);
			// r6b (owner item 10): the sword under the engine's steadying (WF_TWOHANDSTABILIZED)
			mo.SetInventory('RSVR_SwordTwo', RSVR_VRHand.InVR(mo) && mk == RSVR_Hand.SWORD && RSVR_VRHand.Steadied(mo) ? 1 : 0);
			// r6 (item 7): in VR the chainsaw's trigger runs the chain without BD22's swing animation
			// (Saw.dec RSVR_SawRun); the cutting is RSVR_Hand.Tick's, by contact
			mo.SetInventory('RSVR_SawVR', RSVR_VRHand.InVR(mo) && mk == RSVR_Hand.SAW ? 1 : 0);
			// 2.0.2 (owner 2026-10-28): in VR the sword's trigger runs no BD22 combo (Dragonslayer.dec Fire); swings attack
			mo.SetInventory('RSVR_SwordVR', RSVR_VRHand.InVR(mo) && mk == RSVR_Hand.SWORD ? 1 : 0);
		}
	}

	// r6 (owner item 17): THE HIT FLASH ON EVERY MELEE HIT. The gun bash already drew the owner's
	// RS_CombatFX impact (bash.zs RSQ_BashFX; 2.0.2: the gun bash itself is gone). The punch, the
	// pistol whip and the butt strike land BD22's own strike actors -- MeleeStrike1's family
	// (MeleeStrikeNormal, MeleeStrike1Berserked) and KickAttack's (KickAttack, SuperKickAttack) --
	// so the flash goes where one of those, fired by a player, actually damaged something. One
	// effect and one colour for all of them: the menu's Melee Hit Flash rows. BD22's downed-enemy probe
	// (KickAttackDetectDowned, 2 damage) is a probe, not a blow.
	static bool Descends(Actor a, Name n)
	{
		for (class<Object> c = a.GetClass(); c; c = c.GetParentClass())
			if (c.GetClassName() == n)
				return true;
		return false;
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		let inf = e.Inflictor;
		if (!inf || !e.DamageSource || !e.DamageSource.player || !e.Thing || e.Damage <= 0)
			return;
		if (!Descends(inf, 'MeleeStrike1') && !Descends(inf, 'KickAttack'))
			return;
		if (Descends(inf, 'KickAttackDetectDowned'))
			return;
		let fx = Actor.Spawn('RSQ_BashFX', inf.pos, ALLOW_REPLACE);
		if (fx)
			fx.target = e.DamageSource;
	}

	static RSVR_Hand HandOf(PlayerPawn mo, bool off = false)
	{
		let h = RSVR_MeleeHandler(EventHandler.Find('RSVR_MeleeHandler'));
		if (!h || !mo || !mo.player)
			return null;
		int n = mo.PlayerNumber();
		if (n < 0 || n >= MAXPLAYERS)
			return null;
		if (off)
		{
			if (!h.offHands[n])
			{
				h.offHands[n] = new('RSVR_Hand');
				h.offHands[n].off = true;
			}
			return h.offHands[n];
		}
		if (!h.hands[n])
			h.hands[n] = new('RSVR_Hand');
		return h.hands[n];
	}

	// 2.0.2 DUAL AXES. A second axe: the first time a player has the axe (BD22's pickup, a cheat, a drop) the
	// off-hand copy comes with it (Dual Options "Axe", rsq_dual_axe) -- the owner wants two, and BD22 maps
	// seldom hold a second. A thrown off-hand axe is gone until an axe on the floor is picked up again: a
	// BD22 BrutalAxe pickup is never taken by a player who already has the axe (the engine leaves a weapon
	// that gives no ammo on the floor), so these few pickups are watched here and give the copy back.
	Array<Actor> axePickups;
	bool hadAxe[MAXPLAYERS];
	Weapon mainPrev[MAXPLAYERS];	// 2.0.3i: the main hand's weapon last tic

	// DECORATE classes are not known when ZScript compiles: look them up by name at run time
	static class<Inventory> Inv(Name n)
	{
		class<Inventory> c = n;
		return c;
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (a && a.GetClassName() == 'BrutalAxe' && Inventory(a) && !Inventory(a).Owner)
			axePickups.Push(a);
	}

	void AxePickupTick()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo)
				continue;
			let mo = players[n].mo;
			bool has = mo.FindInventory(Inv('BrutalAxe'), false) != null;	// the axe itself, not its off-hand copy
			bool want = RSQ.PlayerInt(mo, 'rsq_dual_axe', 1) != 0;
			// 2.0.3i (owner 2026-10-29 07:00, "player gets max one axe in each hand at a time"): no free second
			// axe with the first. 2.0.3y (owner, BUGS_1.0 item 5): superseded -- "picking up one axe grants both
			// axes": RSQ_Dual.GrantBoth (dual.zs) gives the off-hand axe with a picked-up axe. A thrown axe is still
			// gone until an axe is picked up (here, below, and Axe.dec's wall axe).
			hadAxe[n] = has;
			// 2.0.3j: an axe taken off a wall (BrutalAxeOnWall) while the main hand had one: the off hand's
			if (mo.CountInv('RSVR_GiveOffAxe') > 0)
			{
				mo.TakeInventory('RSVR_GiveOffAxe', 999);
				RSVR_AxeGrab.GiveOff(mo);
			}
			// a thrown MAIN axe is gone until an axe is picked up: once the throw has put the fists up
			// (Axe.dec AxeThrown, FistSelect), the axe leaves the inventory, so the axe on the floor can be
			// taken again by BD22's own pickup
			if (mo.CountInv('RSVR_MainAxeGone') > 0 && !(mo.player.ReadyWeapon && RSQ_Alias.Exact(mo.player.ReadyWeapon) == 'BrutalAxe'))
			{
				mo.TakeInventory(Inv('BrutalAxe'), 1);
				mo.TakeInventory('RSVR_MainAxeGone', 999);
			}
			// the off-hand axe is put away (off hand to the fist) when the main hand switches to a GUN (owner:
			// "when you switch to a gun in mainhand"); fists or the axe leave it; it can be cycled back (slot 1, KEYCONF.rsq) or put there with the Dual key
			let rw = mo.player.ReadyWeapon;
			let ow = mo.player.OffhandWeapon;
			if (rw != mainPrev[n] && RSQ_Flick.IsGun(rw) && ow && ow is 'RSQ_Off_BrutalAxe'
				&& mo.player.PendingWeapon == WP_NOCHANGE)
			{
				let fist = Weapon(mo.FindInventory('RSQ_Hands'));
				if (!fist)
				{
					mo.GiveInventory('RSQ_Hands', 1);
					fist = Weapon(mo.FindInventory('RSQ_Hands'));
				}
				if (fist)
					mo.player.PendingWeapon = fist;
			}
			mainPrev[n] = rw;
		}
		for (int i = axePickups.Size() - 1; i >= 0; i--)
		{
			let a = axePickups[i];
			if (!a || Inventory(a).Owner)
			{
				axePickups.Delete(i);
				continue;
			}
			for (int n = 0; n < MAXPLAYERS; n++)
			{
				if (!playeringame[n] || !players[n].mo)
					continue;
				let mo = players[n].mo;
				if (mo.health <= 0 || mo.FindInventory(Inv('RSQ_Off_BrutalAxe')) || !mo.FindInventory(Inv('BrutalAxe'), false)
					|| RSQ.PlayerInt(mo, 'rsq_dual_axe', 1) == 0)
					continue;
				if (mo.Distance3D(a) > mo.radius + a.radius + 16)
					continue;
				RSQ_Dual.GiveCopy(mo, RSQ_DualTable.AXE);
				mo.A_StartSound("Axe/Draw", CHAN_ITEM);
				a.Destroy();
				axePickups.Delete(i);
				break;
			}
		}
	}
}

class RSVR_Hand play
{
	const HIST = 6;
	const AXE = 1;
	const SWORD = 2;
	const PISTOL = 3;		// 1.97: the pistol whip
	const REVOLVER = 4;
	const RIFLEBUTT = 5;
	const SGBUTT = 6;
	const SSGBUTT = 7;
	const ASGBUTT = 8;
	const MP40BUTT = 9;
	const SMGBUTT = 10;
	const MGBUTT = 11;
	const MG42BUTT = 12;
	const SAW = 13;			// r6 (owner item 7): the chainsaw cuts whatever its running bar touches

	// swing speed (m/s at the blade's outer point, relative to the player's own
	// movement) that counts as a blow, and the slowest release that throws
	const AXE_SWING = 3.0;
	const SWORD_SWING = 3.5;
	// 2.0.2 (owner r3 item 38: "it goes bananas executing several attacks all the time, can it be more responsive
	// to a deliberate swing?"). The speed is taken at the sword's
	// POINT, 90 map units forward and 159 up of the hand in the model (BladeOut), about 1.8 m from the grip, so a
	// turn of the wrist alone moves it fast -- the old gate (3.5 m/s x 1.5 at the point) is about a 170 deg/s turn of the wrist,
	// and the strike list emptied after 3 slow tics, so a wobbling blade struck the same body again and again.
	// A sword blow now needs all three: the speed (SWORD_SWING x 1.5, as before), SWORD_ARC map units of the
	// point's travel ABOVE that speed in this one swing before it may cut (a deliberate arc, not a flick or a
	// wobble), and SWORD_COOL tics after a swing ends before the next may start, so one swing is one attack.
	const SWORD_ARC = 34.0;		// 1 m of the point's travel (34 units a metre)
	const SWORD_COOL = 12;		// about a third of a second
	const SWORD_CALM = 4;		// tics below the speed that end a swing
	const WHIP_SWING = 3.2;		// 1.97: a pistol is lighter than the axe
	const BUTT_SWING = 3.6;		// 1.97: a long gun is heavy and swung short
	// r4 (owner: "enemies back away as you close in, so the range is too short"). The butt strike
	// used to land only where the gun physically was: the stock-to-forward segment, padded 5 map
	// units (15 cm at vr_vunits_per_meter 34). It now also sweeps BUTT_REACH ahead of the stock,
	// along the way the stock is moving, padded BUTT_PAD -- the same envelope as Brutal Doom's
	// own kick, which this blow stands in for. BD22 Melee.dec KickAttack: a FastProjectile of
	// Speed 30 that lives 2 tics (Spawn: TNT1 AA 1) with Radius 12, fired from the weapon
	// controller in VR (p_mobj.cpp: AttackPos). 30 x 2 = 60 units of travel, 12 of radius:
	// 72 map units, 2.1 m. A hit still needs the blow itself (speed, butt leading, two hands)
	// and a clear line from the hand (Clear), so nothing is struck through a wall.
	// 2.0.3y (owner, BUGS_1.0 item 33: "needs a larger range, i feel like im in these peoples faces and im still not
	// connecting consistently"): half as far again ahead of the stock (60 -> 90 map units, 2.6 m at 34 a metre) and
	// a fatter envelope (12 -> 16). The speed it needs is now its own row (rsq_butt_speed, below), and a straight shove
	// counts as well as the pivot (Tick, isButt).
	const BUTT_REACH = 90.0;
	const BUTT_PAD = 16.0;
	const BUTT_LEAD = 1.25;		// 2.0.3y: the muzzle may not outrun the butt by more than this (it is leading, not the butt)
	const WHIP_USE = 30.0;		// 2.0.3y: a whip's reach for a switch past the gun (RSQ_Fists.USE_REACH, a fist's)
	const THROW_MIN = 2.5;
	const SAW_EVERY = 2;		// r6: tics between cuts on one body (BD22's held saw: A_CustomPunch(7) a tic)
	const SAW_PAD = 4.0;		// r6: the bar's half-height, Chain_saw.md3 surface Cube.002_Cube z -11.3..1.0,
							// x 1.5 (Scale) x 0.34 (34 units per metre / 100) = 3.1 map units, padded to 4
	const RISE = 0.15;			// of the blade's speed that may be upward before it is a backswing (about 9 degrees)

	// rsvr_melee_swing scales how hard you have to swing; rsvr_melee_up is how much of the
	// motion may point UP before it counts as raising the axe rather than striking with it.
	// Both are user cvars (CVARINFO.rsvr), read per player so a netgame cannot disagree.
	clearscope static double Cv(PlayerPawn mo, Name n, double def)
	{
		let cv = mo && mo.player ? CVar.GetCVar(n, mo.player) : CVar.FindCVar(n);
		return cv ? cv.GetFloat() : def;
	}

	clearscope static int CvI(PlayerPawn mo, Name n, int def)
	{
		let cv = mo && mo.player ? CVar.GetCVar(n, mo.player) : CVar.FindCVar(n);
		return cv ? cv.GetInt() : def;
	}

	// Is the throw's hold input down? QuestZDoom has no usercmd bit for the WEAPON hand's grip,
	// so this takes either a button mask (rsvr_axe_hold, default BT_ALTATTACK, how it has always
	// worked) or raw key codes (rsvr_axe_keys), read the way vreload.zs reads rsr_grip_keys.
	static bool HoldDown(PlayerPawn mo)
	{
		if (!mo || !mo.player)
			return false;
		int mask = CvI(mo, 'rsvr_axe_hold', BT_ALTATTACK);
		if (mask == BT_TURN180)	// F11: the old default, still archived in players' inis -- it meant alt fire
			mask = BT_ALTATTACK;
		if (mask != 0 && (mo.player.cmd.buttons & mask) != 0)
			return true;
		return RSVR_MeleeHandler.KeyHeld(mo);
	}

	// recent samples: blade outer point and player position, newest at [head]
	double tx[HIST];
	double ty[HIST];
	double tz[HIST];
	double px[HIST];
	double py[HIST];
	double pz[HIST];
	int count;
	int head;

	int kind;
	bool off;			// 2.0.2: this is the OFF hand (the off-hand axe): its pose, its layer, its weapon
	bool havePrev;
	Vector3 prevIn;
	Vector3 prevH;		// 2.0.3i
	Vector3 prevOut;
	Vector3 prevPos;
	Vector3 prevRel;		// 1.11: the blade tip in the BODY's frame last tic (forward, left, up)
	Vector3 prevRelIn;		// 1.97: and the inner end, so a butt strike can be asked to lead
	int prevStamp;		// 1.97 F7: the stamp of the sample prevRel was taken from
	Actor lockTarget;	// the monster painted while a throw is readied
	int lockSeen;		// 2.0.3e: the last tic the tagged monster was in sight
	Actor lockRing;
	int lockKeep;		// F11: a release that was not a throw keeps the paint until this tic
	int poseFrame;
	int placeK;		// r12 port: which weapon Place() is placing (RSVR_MeleeMove)		// 0 = one hand, 1 = the two-handed placement
	int lastPoseFrame;
	int swingTics;
	int calmTics;
	int whooshWait;
	int sawWait;		// r6: tics until the bar may cut the same body again
	// 2.0.4b (LD mode, owner 2026-11-07: "Extended and Imaginary = LONGER BLADE REACH"): set every tic by zscript/rsld
	// (ld_g7_fx.zs RSLD_G7.SawReach) while the saw carries one of them; never set without LegenDoom.
	double ldSawMul;	// Extended: the cut reaches this many times the saw's own reach (the hand to the bar's tip)
	double ldSawPoint;	// Imaginary: the cut hits what the bar points at, up to this many units from the hand
	int ldSawTic;		// the tic they were set (a value not renewed for a tic is off)
	double ldSawBar;	// for the LD log: the saw's own reach (hand to bar tip) and how far the last cut was from the hand
	double ldSawCut;
	bool usedLine;		// 2.0.3y: this swing has worked a switch / door already (one Use per swing)
	// 2.0.2 (owner r3 item 38) THE SWORD'S DELIBERATE SWING: see SWORD_* below and Tick
	double arc;			// map units the point has travelled in this swing, above the speed threshold
	bool armed;			// the swing has covered SWORD_ARC: it may cut
	int coolUntil;		// no new sword swing before this tic (one swing, one attack)
	int swings;			// sword swings that armed (the rig log reads it)
	double lastEdge;	// r6: the axe's last edge-vs-motion cosine (logged by the rig driver)
	int scrapeWait;
	bool inWall;
	Array<Actor> struck;

	// this tic's hand frame and view settings
	transient Vector3 fH;
	transient Vector3 pBod;		// 1.97 F7: the body pose recorded WITH this hand sample
	transient double pByaw;
	transient int pStamp;
	transient Vector3 fF;
	transient Vector3 fR;
	transient Vector3 fU;
	transient double vu;
	transient double ws;
	transient double ox;
	transient double oy;
	transient double oz;
	transient double ps;

	transient bool spritesSet;
	transient SpriteID sAXEG;
	transient SpriteID sRIFG;
	transient SpriteID s2IFG;
	transient SpriteID sRI2G;
	transient SpriteID sSHTN;
	transient SpriteID s2HTN;
	transient SpriteID sSHTA;
	transient SpriteID sVSSG;
	transient SpriteID sSHT2;
	transient SpriteID sVSHZ;
	transient SpriteID sUSAS;
	transient SpriteID s2SAS;
	transient SpriteID sA12P;
	transient SpriteID sMP40;
	transient SpriteID sMP42;
	transient SpriteID sPP40;
	transient SpriteID sSMGF;
	transient SpriteID sSMGR;
	transient SpriteID sVSMG;
	transient SpriteID sMGN1;
	transient SpriteID sHBUS;
	transient SpriteID sPBUS;
	transient SpriteID sPIST;
	transient SpriteID s2IST;
	transient SpriteID sREVO;
	transient SpriteID s2EVO;
	transient SpriteID sRVMA;		// 2.0.2: the Moonlight (BrutalRevolver) held, RVMA A
	transient SpriteID sAXE2;
	transient SpriteID s1XEG;
	transient SpriteID s2XEG;
	transient SpriteID s3XEG;
	transient SpriteID s4XEG;
	transient SpriteID s5XEG;
	transient SpriteID sDSLA, sDSL2;
	transient SpriteID sSAWG;
	transient SpriteID s1AWG;
	transient SpriteID s2AWG;
	transient SpriteID s3AWG;

	//------------------------------------------------------------------
	// the blade, in the held model's own units (BrutalAxe.md3 frame 5 = AXEG A,
	// DSweap.md3 frame 0 = DSLA A; posefix/melee measurements)
	static Vector3 BladeIn(int k)
	{
		if (k == AXE)
			return (44, 0, 26);		// top of the axe head
		if (k == RIFLEBUTT)
			return (25.1, 0.1, 6.3);	// 1.97: Rifle.md3 frame 3, toward the muzzle
		if (k == SGBUTT)
			return (23.7, 0.0, -5.4);	// 1.97: ShotGun.md3 frame 4, toward the muzzle
		if (k == SSGBUTT)
			return (27.9, 0.1, -2.8);	// 1.97: SSG.md3 frame 1, toward the muzzle
		if (k == ASGBUTT)
			return (20.0, 0.0, -2.6);	// 1.97: AssaultShotgun.md3 frame 4, toward the muzzle
		if (k == MP40BUTT)
			return (24.8, 0.2, -3.1);	// 1.97: MP40.md3 frame 2, toward the muzzle
		if (k == SMGBUTT)
			return (18.6, -0.3, -1.2);	// 1.97: BrutalSMG.md3 frame 3, toward the muzzle
		if (k == MGBUTT)
			return (20.1, 0.0, 4.3);	// 1.97: Machinegun.md3 frame 4, surface M249_lowpoly, toward the muzzle
		if (k == MG42BUTT)
			return (21.6, -1.0, 1.2);	// 1.97: HitlersBuzzsaw.md3 frame 0, toward the muzzle
		if (k == PISTOL)
			return (26.2, 0.0, -7.0);	// 1.97: BrutalPistol.md3 frame 3, just forward of the hand
		if (k == REVOLVER)
			return (29.4, 0.1, -1.5);	// 1.97: Revolver.md3 frame 0, just forward of the hand
		if (k == SAW)
			return (84.0, -3.15, -7.7);	// r6: Chain_saw.md3 frame 11, surface Cube.002_Cube (the bar), root x 56.0 -- x MODELDEF Scale 1.5
		return (38, 0, 16);			// Dragonslayer: guard
	}

	static Vector3 BladeOut(int k)
	{
		if (k == AXE)
			return (55, 0, 16);		// the axe's cutting edge
		if (k == RIFLEBUTT)
			return (2.5, 0.5, -1.0);	// 1.97: Rifle.md3 frame 3, the butt
		if (k == SGBUTT)
			return (0.9, 0.0, -10.7);	// 1.97: ShotGun.md3 frame 4, the butt
		if (k == SSGBUTT)
			return (15.3, 0.1, -7.0);	// 1.97: SSG.md3 frame 1, the butt
		if (k == ASGBUTT)
			return (-1.7, 0.0, -6.0);	// 1.97: AssaultShotgun.md3 frame 4, the butt
		if (k == MP40BUTT)
			return (-1.2, 0.0, -3.5);	// 1.97: MP40.md3 frame 2, the butt
		if (k == SMGBUTT)
			return (0.6, 0.0, -10.4);	// 1.97: BrutalSMG.md3 frame 3, the butt
		if (k == MGBUTT)
			return (-1.4, 0.0, 2.0);	// 1.97: Machinegun.md3 frame 4, surface M249_lowpoly, the butt
		if (k == MG42BUTT)
			return (-10.8, -0.1, 1.6);	// 1.97: HitlersBuzzsaw.md3 frame 0, the butt
		if (k == PISTOL)
			return (44.2, 0.0, -0.2);	// 1.97: BrutalPistol.md3 frame 3, the muzzle
		if (k == REVOLVER)
			return (50.2, 0.0, 2.4);	// 1.97: Revolver.md3 frame 0, the muzzle
		if (k == SAW)
			return (155.7, -3.15, -7.7);	// r6: the bar's tip, x 103.8 (z centre -5.15 of -11.3..1.0) -- x 1.5
		return (90, 0, 159);		// Dragonslayer: point
	}

	static Vector3 AxeHead()
	{
		return (50, 0, 20);
	}

	//------------------------------------------------------------------
	void InitSprites()
	{
		sAXEG = Actor.GetSpriteIndex('AXEG');
		sRIFG = Actor.GetSpriteIndex('RIFG');
		s2IFG = Actor.GetSpriteIndex('2IFG');
		sRI2G = Actor.GetSpriteIndex('RI2G');
		sSHTN = Actor.GetSpriteIndex('SHTN');
		s2HTN = Actor.GetSpriteIndex('2HTN');
		sSHTA = Actor.GetSpriteIndex('SHTA');
		sVSSG = Actor.GetSpriteIndex('VSSG');
		sSHT2 = Actor.GetSpriteIndex('SHT2');
		sVSHZ = Actor.GetSpriteIndex('VSHZ');
		sUSAS = Actor.GetSpriteIndex('USAS');
		s2SAS = Actor.GetSpriteIndex('2SAS');
		sA12P = Actor.GetSpriteIndex('A12P');
		sMP40 = Actor.GetSpriteIndex('MP40');
		sMP42 = Actor.GetSpriteIndex('MP42');
		sPP40 = Actor.GetSpriteIndex('PP40');
		sSMGF = Actor.GetSpriteIndex('SMGF');
		sSMGR = Actor.GetSpriteIndex('SMGR');
		sVSMG = Actor.GetSpriteIndex('VSMG');
		sMGN1 = Actor.GetSpriteIndex('MGN1');
		sHBUS = Actor.GetSpriteIndex('HBUS');
		sPBUS = Actor.GetSpriteIndex('PBUS');
		sPIST = Actor.GetSpriteIndex('PIST');
		s2IST = Actor.GetSpriteIndex('2IST');
		sREVO = Actor.GetSpriteIndex('REVO');
		s2EVO = Actor.GetSpriteIndex('2EVO');
		sRVMA = Actor.GetSpriteIndex('RVMA');
		sAXE2 = Actor.GetSpriteIndex('AXE2');	// the two-handed placement
		s1XEG = Actor.GetSpriteIndex('1XEG');
		s2XEG = Actor.GetSpriteIndex('2XEG');
		s3XEG = Actor.GetSpriteIndex('3XEG');
		s4XEG = Actor.GetSpriteIndex('4XEG');
		s5XEG = Actor.GetSpriteIndex('5XEG');
		sDSLA = Actor.GetSpriteIndex('DSLA');
		sDSL2 = Actor.GetSpriteIndex('DSL2');
		sSAWG = Actor.GetSpriteIndex('SAWG');	// r6: the chainsaw's idle (and, in VR, its running) frames
		s1AWG = Actor.GetSpriteIndex('1AWG');
		s2AWG = Actor.GetSpriteIndex('2AWG');
		s3AWG = Actor.GetSpriteIndex('3AWG');
		spritesSet = true;
	}

	static int KindOf(PlayerPawn mo)
	{
		let p = mo.player;
		if (!p || !p.ReadyWeapon || p.PendingWeapon != WP_NOCHANGE || mo.health <= 0)
			return 0;
		// this pack: the saw (the contact saw) and the basics' pistol whip (owner 2026-11-13; BD22 VR's own, the BrutalPistol rows)
		if (p.ReadyWeapon is 'RSQWS_Motorsaw') return SAW;
		if (RSQ.PlayerInt(mo, 'rsq_pistol_whip', 1) != 0 && RSQ_Alias.BD(p.ReadyWeapon) == 'BrutalPistol') return PISTOL;
		return 0;
	}

	// 2.0.2: what the OFF hand swings. Only the off-hand axe: the off hand's other weapons are guns, whose
	// melee is the main hand's (and the fists' own punch, fists.zs).
	static int KindOfOff(PlayerPawn mo)
	{
		let pw = mo.player;	// this pack: the off hand's only melee is the basics' pistol whip (owner 2026-11-13)
		if (pw && pw.OffhandWeapon && mo.health > 0 && RSQ.PlayerInt(mo, 'rsq_pistol_whip', 1) != 0 && RSQ_Alias.BD(pw.OffhandWeapon) == 'BrutalPistol') return PISTOL;
		return 0;
		let p = mo.player;
		if (!p || !p.OffhandWeapon || mo.health <= 0)
			return 0;
		if (p.OffhandWeapon is 'RSQ_Off_BrutalAxe')
			return AXE;
		// 2.0.3y (owner, BUGS_1.0 item 34: "i sometimes move weapons between hands, but i cannot pistol whip in
		// offhand?"): a pistol or revolver in the off hand whips like the main hand's (same points, same swing,
		// "Pistol Whip" and its Swing Needed row). With the off-hand rule (dual.zs) the off hand holds the off-hand
		// version; the main versions are listed too, for a moment before it is swapped in.
		if (RSQ.PlayerInt(mo, 'rsq_pistol_whip', 1) == 0)
			return 0;
		Name n = p.OffhandWeapon.GetClassName();
		if (n == 'RSQ_Off_BrutalPistol' || n == 'BrutalPistol')
			return PISTOL;
		if (n == 'RSQ_Off_Revolver' || n == 'Revolver' || n == 'RSQ_Off_BrutalRevolver' || n == 'BrutalRevolver')
			return REVOLVER;
		return 0;
	}

	int KindFor(PlayerPawn mo)
	{
		return off ? KindOfOff(mo) : KindOf(mo);
	}

	// the weapon is in its held pose (AXEG A or a blood-colour copy, DSLA A):
	// the blade is where the model shows it
	bool ReadyPose(PlayerPawn mo, int k)
	{
		if (!spritesSet)
			InitSprites();
		let psp = mo.player.FindPSprite(off ? PSP_OFFHANDWEAPON : PSP_WEAPON);
		if (!psp)
			return false;
		SpriteID s = psp.Sprite;
		poseFrame = 0;
		placeK = k;	// r12 port
		// r6 (owner item 16: "the pistol whip only works with the off hand"). The main hand's pistol
		// never whipped: BrutalPistol's Ready holds PIST E (loaded), PIST I (empty) or 2IST E, never
		// frame A, so the `Frame != 0` test below turned the whip off whenever the pistol was ready.
		// The off hand's downstroke was its free FIST (fists.zs), not a whip. MODELDEF.bd.txt binds
		// PIST E and 2IST E to model frame 7 and PIST I to frame 3; a rigid fit of BrutalPistol.md3
		// frame 3 onto frame 7 (all 6828 vertices) moves the whip points by 0.1 unit, so BladeIn /
		// BladeOut (measured at frame 3) stand for all three.
		if (k == PISTOL)
			return (s == sPIST && (psp.Frame == 0 || psp.Frame == 4 || psp.Frame == 8)) || (s == s2IST && (psp.Frame == 0 || psp.Frame == 4));
		// r6 (item 7): the chainsaw's idle loop is SAWG A..G (and its blood-visor copies), model
		// frames 11 and 12, which hold the bar in the same place (the vibration)
		if (k == SAW)
		{
			poseFrame = 2;
			return (s == sSAWG || s == s1AWG || s == s2AWG || s == s3AWG) && psp.Frame <= 6;
		}
		if (psp.Frame != 0)
			return false;
		if (k == SWORD)
		{
			poseFrame = s == sDSL2 ? 3 : 0;	// r6b: 3 = the two-handed block (MODELDEF.bd.txt DSL2)
			return s == sDSLA || s == sDSL2;
		}
		if (k == RIFLEBUTT)
			return s == sRIFG || s == s2IFG || s == sRI2G;
		if (k == SGBUTT)
			return s == sSHTN || s == s2HTN || s == sSHTA;
		if (k == SSGBUTT)
			return s == sVSSG || s == sSHT2 || s == sVSHZ;
		if (k == ASGBUTT)
			return s == sUSAS || s == s2SAS || s == sA12P;
		if (k == MP40BUTT)
			return s == sMP40 || s == sMP42 || s == sPP40;
		if (k == SMGBUTT)
			return s == sSMGF || s == sSMGR || s == sVSMG;
		if (k == MGBUTT)
			return s == sMGN1;
		if (k == MG42BUTT)
			return s == sHBUS || s == sPBUS;
		if (k == PISTOL)
			return s == sPIST || s == s2IST;
		if (k == REVOLVER)
			return s == sREVO || s == s2EVO || s == sRVMA;	// RVMA: the Moonlight (2.0.2)
		// 2.0.2: AXE2 (the two-handed placement) is gone (owner r3 item 37); the axe is always one-handed
		return s == sAXEG || s == s1XEG || s == s2XEG || s == s3XEG || s == s4XEG || s == s5XEG;
	}

	static double CVarF(Name n, double def)
	{
		let cv = CVar.FindCVar(n);
		return cv ? cv.GetFloat() : def;
	}

	// 1.97 F7: THE HAND COMES OUT OF THE POSE HISTORY, not out of the engine fields.
	// RSVR_VRHand.HandPos reads AttackPos, which stock QuestZDoom writes on the CONSOLE
	// PLAYER'S PAWN ONLY and never sends: for every other player it is zero, so a second
	// player's melee resolved from nothing. RSQ_PoseHandler fills a stamped history on every
	// machine from one netevent a tic, and this reads that -- on the sender's machine too, so
	// there is one code path and no special case for the player holding the controller.
	//
	// `bod` and `byaw` are the body pose recorded WITH this hand sample. That is the whole
	// reason the snap-turn patch could be deleted: the controller pose is written by the
	// renderer at the end of a frame and the pawn's angle changes in the tic after, so
	// converting an old hand reading with a new body angle invented a swing out of a turn.
	// Matching each sample to its own body pose removes that at the source.
	bool Frame(PlayerPawn mo)
	{
		let ph = RSQ_PoseHandler.Of(mo, off ? RSQ_Pose.OFF : RSQ_Pose.MAIN);
		if (!ph || !ph.Fresh(mo.Level.maptime))
			return false;
		ps = mo.Level.pixelstretch;
		if (ps <= 0)
			ps = 1.2;
		fH = ph.pos[0];
		fF = ph.F;
		fR = -ph.L;
		fU = off ? -ph.U : ph.U;	// 2.0.3q: the off frame arrives mirrored (engine mirrors the left weapon, hw_vrmodes.cpp:469; OffDir yaw 90 is the hand's right), so pose.zs U = F x L points down. fR = -ph.L is already mirrored like the drawn off model.
		pBod = ph.bod[0];
		pByaw = ph.byaw[0];
		pStamp = ph.stamp[0];
		vu = CVarF('vr_vunits_per_meter', 34);
		ws = CVarF('vr_weaponScale', 1.02);
		ox = CVarF('vr_3dweaponOffsetX', 0);
		oy = CVarF('vr_3dweaponOffsetY', 0);
		oz = CVarF('vr_3dweaponOffsetZ', 0);
		return true;
	}

	// a point of the held model -> world. Same chain as RenderHUDModel: hand,
	// scale .01, translate (0, 5, 30), model Scale -1 1 1 with ZOffset -5,
	// the jDoom 90 degree turn, vr_weaponScale; local x right, y up, -z forward.
	Vector3 Place(Vector3 m)
	{
		// The two-handed block moves the model, so the blade must move with it or the
		// hits stay where the one-handed axe was. Offset.y comes off forward, and
		// ZOffset off up measured against the shipped block's -5.
		double sf = poseFrame == 1 ? 8.9584 : poseFrame == 2 ? 10.0 : 0.0;	// 2: Chain_saw's Offset y 10
		double su = poseFrame == 1 ? -17.2631 : 0.0;
		if (poseFrame == 3)
		{
			// r6b: the two-handed sword block -- PitchOffset 110 (forward toward up), then its
			// Offset y -40.26 and ZOffset -33.19 (MODELDEF.bd.txt DSL2)
			m = (m.x * cos(110) - m.z * sin(110), m.y, m.x * sin(110) + m.z * cos(110));
			sf = -40.26;
			su = -28.19;
		}
		double f = 0.01 * (ws * m.x - 30 - oz - sf);
		double r = 0.01 * (-ws * m.y + ox);
		double u = 0.01 * (ws * m.z + oy + su);
		// r12 port: the weapon is drawn moved to the FBX hand: its points move the same way (RSVR_MeleeMove, F / L / U cm)
		Vector3 mv = RSVR_MeleeMove.Apply(placeK, poseFrame, (100 * f, -100 * r, 100 * u));
		f = 0.01 * mv.x;
		r = -0.01 * mv.y;
		u = 0.01 * mv.z;
		Vector3 w = fF * f + fR * r + fU * u;
		w.z /= ps;
		return fH + w * vu;
	}

	// ONE THROW (RSQ series, owner 11-10: "one throw for everything"): WHETHER the axe is thrown is read off the HAND, the
	// series' one sampler (RSQ Grenade hand.zs Sample / Peak, RSQ Saber, RSQ ShieldSaw, this pack's grenade): the hand
	// relative to the pawn, turned by the pawn's yaw, the fastest 2-tic window over the last 7 tics in real m/s (the
	// vertical squash taken out), a collapsed pose and over a metre in two tics no motion, against THROW_MIN (2.5 m/s). It
	// was the axe's EDGE, single tics, the pawn's travel taken out but not its turn. How hard it flies still comes from
	// the edge (Throw below), so a thrown axe flies as before.
	const TWIN = 7;
	Vector3 tHist[TWIN];
	bool tOk[TWIN];
	int tAt;
	bool tSame;
	void ThrowSample(PlayerPawn mo)
	{
		bool same = mo.AttackPos == mo.OffhandPos;
		bool collapsed = same && !tSame;
		tSame = same;
		Vector3 off = fH - mo.pos;
		double c = cos(mo.angle), sn = sin(mo.angle);
		tHist[tAt] = (off.x * c + off.y * sn, off.y * c - off.x * sn, off.z);
		tOk[tAt] = !same && !collapsed;
		tAt = (tAt + 1) % TWIN;
	}
	double ThrowMs()
	{
		double ps = level.pixelstretch > 0.1 ? level.pixelstretch : 1.2;
		double u = vu > 0 ? vu : 34;
		double bestM = 0;
		for (int i = 0; i + 2 < TWIN; i++)
		{
			int ka = (tAt - 1 - i + 2 * TWIN) % TWIN, kb = (tAt - 3 - i + 2 * TWIN) % TWIN;
			if (!tOk[ka] || !tOk[kb]) continue;
			Vector3 v = (tHist[ka] - tHist[kb]) * 0.5;
			double mm = (v.x, v.y, v.z * ps).Length() / u;
			if (mm >= 0.5) continue;
			bestM = max(bestM, mm);
		}
		return bestM * TICRATE;
	}

	void Push(Vector3 tip, Vector3 pos)
	{
		head = (head + 1) % HIST;
		tx[head] = tip.x;
		ty[head] = tip.y;
		tz[head] = tip.z;
		px[head] = pos.x;
		py[head] = pos.y;
		pz[head] = pos.z;
		if (count < HIST)
			count++;
	}

	void Reset()
	{
		count = 0;
		havePrev = false;
		prevStamp = 0;
		swingTics = 0;
		calmTics = 0;
		arc = 0;
		armed = false;
		inWall = false;
		usedLine = false;
		struck.Clear();
	}

	//------------------------------------------------------------------
	void Tick(PlayerPawn mo)
	{
		if (whooshWait > 0)
			whooshWait--;
		if (scrapeWait > 0)
			scrapeWait--;
		// F11: a paint kept after a release that was not a throw -- gone after its second, or with its monster
		if (lockKeep > 0 && (mo.Level.maptime > lockKeep || !lockTarget || lockTarget.health <= 0))
			Unlock();
		if (lockKeep > 0 && lockRing && lockTarget)
			lockRing.SetOrigin(RSVR_AxeLock.Above(lockTarget), true);

		int k = KindFor(mo);
		if (k != kind)
		{
			Reset();
			Unlock();	// the axe went away: so does the paint
			kind = k;
		}
		if (k == 0 || !ReadyPose(mo, k) || !Frame(mo))
		{
			Reset();
			return;
		}
		// r6b: a change of placement (one hand <-> two) moves the blade in one tic without
		// the hand moving: that jump is not a swing (rig: the sword's steadying started one)
		if (poseFrame != lastPoseFrame)
		{
			lastPoseFrame = poseFrame;
			Reset();
			return;
		}

		// 1.97 F7: THE SNAP-TURN AND TELEPORT PATCH IS GONE, not retuned. It threw away two
		// tics whenever the pawn turned more than 12 degrees or moved more than 64 units, which
		// is the shape of fix the melee document records failing in the saber: above about
		// 280 deg/s a smooth-turn player trips it EVERY tic and loses every swing, and below the
		// threshold the turn is not subtracted at all. BodyFrame now converts each sample with
		// the body pose recorded beside it, so a turn cancels arithmetically and there is
		// nothing left to throw away.

		Vector3 bin = Place(BladeIn(k));
		Vector3 bout = Place(BladeOut(k));
		Push(bout, mo.pos);
		ThrowSample(mo);
		if (!havePrev)
		{
			prevIn = bin; prevH = fH;
			prevOut = bout;
			prevPos = mo.pos;
			prevRel = BodyFrame(mo, bout);
			prevRelIn = BodyFrame(mo, bin);
			prevStamp = pStamp;
			havePrev = true;
			return;
		}

		// r6 (owner item 7): THE CHAINSAW IS NOT SWUNG BY SPEED. While its trigger is held the
		// chain runs (Saw.dec RSVR_SawRun: no swing animation, the player moves it) and the bar
		// cuts whatever it touches, moving or still -- BD22's own SawDamageHorizontal (5-6 Cut)
		// every SAW_EVERY tics into each body the bar is in.
		if (k == SAW)
		{
			if (mo.player.cmd.buttons & BT_ATTACK)
			{
				if (--sawWait <= 0)
				{
					struck.Clear();		// each body may be cut again: contact, not one hit per swing
					sawWait = SAW_EVERY;
				}
				Sweep(mo, k, prevIn, prevOut, bin, bout, 1.0, SAW_PAD);
				if (mo.Level.maptime - ldSawTic <= 1)
					LDSawReach(mo, k, bin, bout);
			}
			else
			{
				struck.Clear();
				sawWait = 0;
			}
			prevIn = bin; prevH = fH;
			prevOut = bout;
			prevPos = mo.pos;
			prevRel = BodyFrame(mo, bout);
			prevRelIn = BodyFrame(mo, bin);
			prevStamp = pStamp;
			return;
		}

		bool isButt = k == RIFLEBUTT || k == SGBUTT || k == SSGBUTT || k == ASGBUTT || k == MP40BUTT || k == SMGBUTT || k == MGBUTT || k == MG42BUTT;
		double thr = (k == AXE ? AXE_SWING : k == SWORD ? SWORD_SWING
			: isButt ? clamp(Cv(mo, 'rsq_butt_speed', 2.4), 1.0, 8.0)	// 2.0.3y (owner item 33: "i need to do the motion extremely fast"): was BUTT_SWING 3.6
			: clamp(Cv(mo, 'rsq_whip_speed', 5.0), 1.0, 12.0)) * vu / 35.	// 2.0.3g (owner 00:42, "pistol whip is too sensitive, make me whip harder"): was WHIP_SWING 3.2
			* max(0.2, Cv(mo, 'rsvr_melee_swing', 1.0))
			* ((k == AXE || k == SWORD) ? 1.5 : 1.0);	// F11 (owner): "swing sensitivity seems too high"
		// 1.11 (owner: "goes insane with attacks just when I move around"). The blade is measured
		// in the BODY's own frame (from the pawn, turned by the pawn's angle), so walking,
		// strafing and turning move nothing; only the arm swinging the blade counts. (World
		// motion minus the pawn's motion was fooled by turns and by the controller and the pawn
		// landing a tic apart.)
		// 1.97 F7: per TIC, over the gap the stamps actually record. This used to be a bare
		// difference, which is a velocity only while no tic is ever missed; a dropped tic read as
		// a swing twice as fast as it was. A gap of 0 would divide by zero, so it is floored at 1.
		int gap = max(1, pStamp - prevStamp);
		Vector3 rel = BodyFrame(mo, bout);
		Vector3 vel = (rel - prevRel) / gap;
		prevRel = rel;
		Vector3 relIn = BodyFrame(mo, bin);
		Vector3 velIn = (relIn - prevRelIn) / gap;
		prevRelIn = relIn;
		prevStamp = pStamp;
		double speed = vel.Length();
		double power = speed / thr;

		// THE BACKSWING IS NOT A STRIKE. The test used to be speed alone, so raising the axe to
		// strike was itself a hit -- it landed before the player had swung, and read as the axe
		// being wildly oversensitive (owner, 2026-10-13). Motion that is mostly upward is the
		// player winding up, so it does not cut, and it falls through to the calm branch below
		// so the downswing that follows is a fresh swing with a cleared strike list.
		double rise = speed > 0 ? vel.z / speed : 0;
		// 2026-10-16 (owner): NO hits on the upswing. Only a level or downward blade cuts
		// (rsvr_melee_up, default 0.15: about 9 degrees up at most; it was 0.55, about 33).
		// 1.11 (owner): "swinging an axe DOWNWARD meaningfully". A blow must now point down by at
		// least rsvr_melee_down of its speed (default 0.25, about 15 degrees below level); a
		// level or rising blade never cuts.
		bool backswing = rise > -clamp(Cv(mo, 'rsvr_melee_down', 0.25), 0.0, 0.9);
		// F11 (owner): the axe and the sword cut on a DOWN or a SIDE swing, never an upswing --
		// anything that rises more than about 9 degrees is a wind-up
		if (k == AXE || k == SWORD)
			backswing = rise > 0.15;
		// r6 (owner item 9): THE AXE CUTS ONLY WITH ITS EDGE LEADING. BladeIn is the top of the head
		// and BladeOut the cutting edge, so rel - relIn is the way the edge faces, in the same body
		// frame as the motion. Held like a gun the edge faces forward and down (BrutalAxe.md3 frame 5:
		// (11, 0, -10)), so a downswing leads with it and raising the arm leads with the poll -- no cut;
		// a sideways swing leads with the flat unless the wrist is turned so the edge faces the way it
		// moves. The motion must be within acos(rsvr_axe_edge) of the edge: 0.5 = 60 degrees, the
		// same cosine the two-handed bite has always been scored against.
		if (k == AXE)
		{
			Vector3 edge = rel - relIn;
			double el = edge.Length();
			lastEdge = (el > 0 && speed > 0) ? (vel dot edge) / (el * speed) : -1;
			if (lastEdge < clamp(Cv(mo, 'rsvr_axe_edge', 0.5), -1.0, 1.0))
				backswing = true;
		}
		if (isButt)
		{
			// 1.97 the butt strike. Not the axe's must-point-DOWN test: this blow drives
			// forward and up. And two hands is NOT the gate -- two hands on a rifle is how
			// you hold a rifle. What separates it is the butt LEADING: the gun pivots about
			// the front hand, so the stock outruns the muzzle. Walking moves both ends alike
			// (and the body frame has already cancelled it) and raising the gun moves both;
			// only the pivot does this.
			// 2.0.3y (owner item 33): A SHOVE COUNTS TOO. The butt had to outrun the muzzle by 1.3x (rsvr_butt_lead,
			// no menu row), so only a pivot struck and a straight shove -- both ends moving alike -- missed about half
			// the time, by a hair either way. Now the blow only must not be MUZZLE-led (the muzzle more than BUTT_LEAD
			// times the butt's speed): a pivot and a straight shove both strike; swinging the barrel round does not.
			// Walking still moves nothing (the body frame), and raising the gun still fails the forward test.
			double fwd = speed > 0 ? vel.x / speed : 0;
			backswing = !RSVR_VRHand.Steadied(mo)
				|| fwd < clamp(Cv(mo, 'rsvr_butt_fwd', 0.5), 0.0, 1.0)
				|| velIn.Length() > speed * BUTT_LEAD;
		}

		// 2.0.2 (owner r3 item 38): the sword cuts only on a deliberate swing (SWORD_ARC, SWORD_COOL above)
		bool fast = power >= 1 && !backswing;
		if (k == SWORD)
		{
			int now = mo.Level.maptime;
			if (fast && !armed && now < coolUntil)
				fast = false;			// still cooling down from the last swing: this is not a new one
			if (fast)
			{
				arc += speed * gap;
				if (!armed && arc >= SWORD_ARC)
				{
					armed = true;
					swings++;
				}
			}
			if (!armed)
			{
				if (!fast && ++calmTics > SWORD_CALM)
					arc = 0;
				if (fast)
					calmTics = 0;
				WallCheck(mo, bout, 0);
				prevIn = bin; prevH = fH;
				prevOut = bout;
				prevPos = mo.pos;
				return;
			}
			if (!fast)
			{
				if (++calmTics > SWORD_CALM)
				{
					// the swing is over: one swing, one attack, then a short rest
					armed = false;
					arc = 0;
					swingTics = 0;
					struck.Clear();
					coolUntil = now + SWORD_COOL;
				}
				WallCheck(mo, bout, power);
				prevIn = bin; prevH = fH;
				prevOut = bout;
				prevPos = mo.pos;
				return;
			}
		}
		if (fast)
		{
			calmTics = 0;
			swingTics++;
			if (swingTics == 1 && whooshWait == 0)
			{
				if (k == AXE)
					mo.A_StartSound("Axe/Swing", CHAN_WEAPON, CHANF_OVERLAP);
				else
					mo.A_StartSound("Melee/SwingStrong", CHAN_WEAPON, CHANF_OVERLAP);
				whooshWait = 12;
			}
			if (k == AXE)
			{
				// 2.0.3i (owner 2026-10-29 07:04, "increase axe slashing range by 33%"): the blade's swept points
				// are pushed out from the hand by a third (each tic's points from that tic's hand)
				double AXE_RANGE = 1.33;
				Sweep(mo, k, prevH + (prevIn - prevH) * AXE_RANGE, prevH + (prevOut - prevH) * AXE_RANGE,
					fH + (bin - fH) * AXE_RANGE, fH + (bout - fH) * AXE_RANGE, power);
			}
			else
				Sweep(mo, k, prevIn, prevOut, bin, bout, power);
			Vector3 sd = bout - prevOut;
			double sl = sd.Length();
			if (sl > 0)
				sd /= sl;
			if (isButt && sl > 0)
			{
				// r4: the reach ahead of the stock (BUTT_REACH above)
				Sweep(mo, k, prevOut, prevOut + sd * BUTT_REACH, bout, bout + sd * BUTT_REACH, power, BUTT_PAD);
			}
			// 2.0.3y (owner, BUGS_1.0 item 13: "punch, jab, hook, uppercut, whip, pistol whip, gun butt-shove all
			// activate switches"): the pistol whip and the butt strike work a switch or door they hit, once a swing,
			// as a Use press on that line (RSQ_Fists.LineUse: the line's special decides, never its texture). The gun
			// itself (hand to striking end), then on along the blow: a fist's reach for the whip, the butt's reach
			// for the butt. "Punch Switches Open" (rsq_punch_use) switches it off with the punches.
			if ((isButt || k == PISTOL || k == REVOLVER) && !usedLine && sl > 0)
				usedLine = RSQ_Fists.LineUse(mo, fH, prevOut, bout, isButt ? BUTT_REACH : WHIP_USE, isButt ? "butt strike" : off ? "off-hand pistol whip" : "pistol whip");
		}
		else if (++calmTics > 2)
		{
			swingTics = 0;
			struck.Clear();
			usedLine = false;
		}
		WallCheck(mo, bout, power);

		prevIn = bin; prevH = fH;
		prevOut = bout;
		prevPos = mo.pos;
	}

	//------------------------------------------------------------------
	// 2.0.4b (LD mode, owner 2026-11-07): LegenDoom's Extended / Imaginary on the running bar: a longer blade reach.
	// Extended: the cut reaches ldSawMul times the saw's own reach, along the bar: the bar's tip line is swept on out to
	// that distance from the hand (same pad, same once-per-SAW_EVERY rule, nothing through a wall). Imaginary: whatever
	// the bar points at (a trace from the hand along the bar) is cut, up to ldSawPoint units from the hand.
	void LDSawReach(PlayerPawn mo, int k, Vector3 bin, Vector3 bout)
	{
		ldSawBar = (bout - fH).Length();
		if (ldSawMul > 1)
		{
			Vector3 x0 = prevH + (prevOut - prevH) * ldSawMul;
			Vector3 x1 = fH + (bout - fH) * ldSawMul;
			Sweep(mo, k, prevOut, x0, bout, x1, 1.0, SAW_PAD);
		}
		if (ldSawPoint > 0)
		{
			Vector3 d = bout - bin;
			double l = d.Length();
			if (l <= 0)
				return;
			d /= l;
			FLineTraceData tr;
			mo.LineTrace(VectorAngle(d.x, d.y), ldSawPoint, -asin(clamp(d.z, -1, 1)), TRF_ABSPOSITION, fH.z, fH.x, fH.y, tr);
			Actor t = tr.HitActor;
			if (tr.HitType != TRACE_HitActor || !t || t == mo || t.player || !t.bSHOOTABLE || t.bFRIENDLY || t.bDORMANT || t.health <= 0)
				return;
			if (struck.Find(t) != struck.Size())
				return;
			struck.Push(t);
			Strike(mo, k, t, tr.HitLocation, d, 1.0, d);
		}
	}

	//------------------------------------------------------------------
	// the blade's path this tic (a0-b0 -> a1-b1) against every body near it;
	// each body is hit once per swing, at the first point the blade reaches it
	void Sweep(PlayerPawn mo, int k, Vector3 a0, Vector3 b0, Vector3 a1, Vector3 b1, double power, double padAt = 0)
	{
		double pad = padAt > 0 ? padAt : (k == AXE) ? 3 : 5;
		Vector3 c = (a0 + b0 + a1 + b1) / 4;
		double r = max(max((a0 - c).Length(), (b0 - c).Length()), max((a1 - c).Length(), (b1 - c).Length())) + pad;
		double travel = max((b1 - b0).Length(), (a1 - a0).Length());
		int steps = clamp(int(travel / 4) + 1, 1, 16);
		int segs = (k == AXE) ? 2 : 8;

		Array<Actor> victims;
		Array<double> hx;
		Array<double> hy;
		Array<double> hz;
		Array<double> dx;
		Array<double> dy;
		Array<double> dz;
		let it = BlockThingsIterator.CreateFromPos(c.x, c.y, c.z - r, 2 * r, r, false);
		while (it.Next())
		{
			Actor t = it.thing;
			if (!t || t == mo || t.player || !t.bSHOOTABLE || t.bFRIENDLY || t.bDORMANT || t.health <= 0)
				continue;
			if (struck.Find(t) != struck.Size() || victims.Find(t) != victims.Size())
				continue;
			bool hit = false;
			Vector3 at = (0, 0, 0);
			Vector3 dir = (0, 0, 0);
			for (int i = 1; i <= steps && !hit; i++)
			{
				double f = double(i) / steps;
				for (int j = segs; j >= 0 && !hit; j--)
				{
					double s = double(j) / segs;
					Vector3 p0 = a0 + (b0 - a0) * s;
					Vector3 p1 = a1 + (b1 - a1) * s;
					Vector3 q = p0 + (p1 - p0) * f;
					if (Touches(t, q, pad))
					{
						hit = true;
						at = q;
						dir = p1 - p0;
					}
				}
			}
			if (!hit || !Clear(mo, fH, at))
				continue;
			victims.Push(t);
			hx.Push(at.x);
			hy.Push(at.y);
			hz.Push(at.z);
			dx.Push(dir.x);
			dy.Push(dir.y);
			dz.Push(dir.z);
		}

		// The axe is bladed on ONE side. BladeIn is the top of the head and BladeOut the
		// cutting edge, so this is where the edge points this tic -- what the two-handed
		// bite is scored against.
		Vector3 edge = b1 - a1;

		// strike after the search: the hits spawn gore and kill things
		for (int i = 0; i < victims.Size(); i++)
		{
			Actor t = victims[i];
			if (!t || t.health <= 0)
				continue;
			struck.Push(t);
			Strike(mo, k, t, (hx[i], hy[i], hz[i]), (dx[i], dy[i], dz[i]), power, edge);
		}
	}

	static bool Touches(Actor t, Vector3 q, double pad)
	{
		if (q.z < t.pos.z - pad || q.z > t.pos.z + t.height + pad)
			return false;
		double ddx = q.x - t.pos.x;
		double ddy = q.y - t.pos.y;
		double rr = t.radius + pad;
		return ddx * ddx + ddy * ddy <= rr * rr;
	}

	// nothing solid between the hand and that point
	static bool Clear(Actor mo, Vector3 from, Vector3 to)
	{
		Vector3 d = to - from;
		double len = d.Length();
		if (len < 1)
			return true;
		FLineTraceData tr;
		mo.LineTrace(VectorAngle(d.x, d.y), len, -asin(clamp(d.z / len, -1, 1)),
			TRF_ABSPOSITION | TRF_THRUACTORS, from.z, from.x, from.y, tr);
		return tr.HitType == TRACE_HitNone || tr.HitType == TRACE_HitActor;
	}

	void Strike(PlayerPawn mo, int k, Actor t, Vector3 at, Vector3 dir, double power, Vector3 edge)
	{
		// start BD22's attack just inside the body, at the height the blade met it
		double rx = at.x - t.pos.x;
		double ry = at.y - t.pos.y;
		double rl = sqrt(rx * rx + ry * ry);
		double lim = max(t.radius - 2, 1);
		if (rl > lim)
		{
			rx *= lim / rl;
			ry *= lim / rl;
		}
		Vector3 p = (t.pos.x + rx, t.pos.y + ry, clamp(at.z, t.pos.z + 1, t.pos.z + max(t.height - 1, 1)));
		double dl = dir.Length();
		if (dl > 0)
			dir = dir / dl;
		else
			dir = (cos(mo.angle), sin(mo.angle), 0);

		if (k == AXE)
		{
			Launch(mo, 'AxeAttack', p, dir);
			if (power >= 1.6)
				Launch(mo, 'AxeAttackNoDecal', p, dir);
			if (power >= 2.4)
				Launch(mo, 'AxeAttack', p, dir);
			// 2.0.2: no two-handed bite (RSVR_AxeHalf): the axe is never two-handed (owner r3 item 37)
		}
		else if (k == SWORD)
		{
			Launch(mo, 'DSAttack', p, dir);
			Launch(mo, 'DSAttack2', p, dir);
			// r6b (owner item 10): two hands on the sword, 2.0x -- the same pair again
			// (DSAttack and DSAttack2 deal a fixed 200 each: Damage (random(200,200)))
			if (mo.CountInv('RSVR_SwordTwo') > 0)
			{
				Launch(mo, 'DSAttack', p, dir);
				Launch(mo, 'DSAttack2', p, dir);
			}
		}
		else if (k == SAW)
		{
			// into the body from the hand: the bar may be still, so its motion is no direction
			Vector3 into = (t.pos.x, t.pos.y, p.z) - fH;
			double il = into.Length();
			ldSawCut = (p - fH).Length();
			Launch(mo, 'RSQWS_SawCut', p, il > 0 ? into / il : dir, off ? 1 : 0);
		}
		else
		{
			// 1.97 the pistol whip: BD22's own punch, which is what this pack's fists
			// already land (zscript/rsq/fists.zs), so its gore decides the result.
			if (k == PISTOL || k == REVOLVER)
			{
				Launch(mo, mo.CountInv('PowerStrength') > 0 ? 'RSQB_PunchBerserk' : 'RSQB_Punch', p, dir);	// this pack: the basics' strike
				if (power >= 2.0)
					Launch(mo, 'RSQB_Punch', p, dir);
			}
			else
			{
				// 1.97 the butt strike: BD22's own kick, which is what a stock to the face is
				// and what the gun bash already lands.
				Launch(mo, mo.CountInv('PowerStrength') > 0 ? 'SuperKickAttack' : 'KickAttack', p, dir);
			}
		}
		if (!off)
			Buzz(mo);	// the engine buzzes the WEAPON hand only; the off axe goes without
	}

	// BD22's attack actor, fired by the player from that point. rec >= 0 (the saw's cut: 0 main hand, 1 off hand):
	// 2.0.4b (LD mode, owner 2026-11-07) it is recorded the way rsq/fists.zs records a punch, before it can hit, so the
	// LD mode counts it as a melee attack of the hand that holds the saw (zscript/rsld handler.zs IsStrike / StrikeHand)
	static void Launch(PlayerPawn mo, Name cname, Vector3 p, Vector3 dir, int rec = -1)
	{
		class<Actor> cls = cname;
		if (!cls)
			return;
		let a = Actor.Spawn(cls, p, ALLOW_REPLACE);
		if (!a)
			return;
		a.target = mo;
		a.angle = VectorAngle(dir.x, dir.y);
		a.pitch = -asin(clamp(dir.z, -1, 1));
		a.vel = dir * a.speed;
		if (rec >= 0)
			RSQ_Fists.Record(a, rec, 0);
		a.CheckMissileSpawn(0);
	}

	// controller rumble: the engine buzzes the weapon hand when the player
	// fires a projectile (p_mobj.cpp P_SpawnPlayerMissile)
	static void Buzz(PlayerPawn mo)
	{
		mo.SpawnPlayerMissile('RSVR_Buzz', mo.angle, noautoaim: true);
	}

	// the blade going into a wall, floor or ceiling at speed: BD22's axe impact
	// (sparks and clang, or the floor's splash / dirt)
	void WallCheck(PlayerPawn mo, Vector3 bout, double power)
	{
		Vector3 d = bout - fH;
		double len = d.Length();
		bool blocked = false;
		Vector3 hitAt = (0, 0, 0);
		if (len > 1)
		{
			FLineTraceData tr;
			mo.LineTrace(VectorAngle(d.x, d.y), len, -asin(clamp(d.z / len, -1, 1)),
				TRF_ABSPOSITION | TRF_THRUACTORS, fH.z, fH.x, fH.y, tr);
			if (tr.HitType == TRACE_HitWall || tr.HitType == TRACE_HitFloor || tr.HitType == TRACE_HitCeiling)
			{
				blocked = true;
				hitAt = tr.HitLocation;
			}
		}
		if (blocked && !inWall && power >= 1 && scrapeWait == 0)
		{
			Vector3 dir = d / len;
			Launch(mo, 'AxeAttack', hitAt - dir * 6, dir);
			Buzz(mo);
			scrapeWait = 8;
		}
		inWall = blocked;
	}

	//------------------------------------------------------------------
	// axe alt-fire, called every tic of the hold by RSVR_AxeGrip
	static void Grip(PlayerPawn mo)
	{
		// rsg_vr 0 (menu: VR throwing off) -> BD22's own canned axe throw
		bool vr = RSVR_VRHand.InVR(mo) && RSR.PlayerInt(mo.player, 'rsg_vr', 1) != 0;
		mo.SetInventory('RSVR_NotVR', vr ? 0 : 1);
		mo.SetInventory('RSVR_AxeThrown', 0);
		if (!vr)
			return;
		// the trigger path (Axe.dec TrigGrip, VR throwing on) holds with the trigger, like the grenade
		bool held = mo.CountInv('RSVR_AxeTrig') > 0 ? (mo.player.cmd.buttons & BT_ATTACK) != 0 : HoldDown(mo);
		mo.SetInventory('RSVR_AxeHolding', held ? 1 : 0);
		if (!held)	// F11: WorldTick sets this AFTER the weapon ticks, so it is still 1 on the release tic,
			mo.SetInventory('RSVR_AxeHold', 0);	// and Ready would send the axe straight back here: a zero-tic loop
		HoldOrThrow(mo, RSVR_MeleeHandler.HandOf(mo), held, 'RSVR_AxeThrown');
	}

	// 2.0.2: the OFF-hand axe (Axe.dec RSQ_Off_BrutalAxe OffTrigGrip): held on the off trigger, thrown on its release
	static void GripOff(PlayerPawn mo)
	{
		mo.SetInventory('RSVR_OffAxeThrown', 0);
		bool held = (mo.player.cmd.buttons & BT_OFFHANDATTACK) != 0;
		mo.SetInventory('RSVR_OffAxeHolding', held ? 1 : 0);
		HoldOrThrow(mo, RSVR_MeleeHandler.HandOf(mo, true), held, 'RSVR_OffAxeThrown');
	}

	static void HoldOrThrow(PlayerPawn mo, RSVR_Hand h, bool held, class<Inventory> thrown)
	{
		if (held)
		{
			// winding up: paint what the hand is pointing at
			if (h)
			{
				h.lockKeep = 0;	// F11: a kept paint is picked back up
				h.LockTick(mo);
			}
			return;
		}
		if (h && h.Throw(mo))
		{
			mo.SetInventory(thrown, 1);
			if (thrown == 'RSVR_AxeThrown')
				mo.SetInventory('RSVR_MainAxeGone', 1);	// 2.0.3i: gone until picked up (AxePickupTick)
			h.Unlock();
		}
		// F11 (owner): let go without a throw and the paint stays a second, as on the ShieldSaw and the
		// saber -- pick the hold back up and it is still there; otherwise Tick takes it down
		else if (h && h.lockTarget && h.lockKeep == 0)
			h.lockKeep = mo.Level.maptime + 105;	// 2.0.3e: a tag kept 3 s after a let-go that was not a throw (was 1 s)
	}

	// a world point in the body's own frame: forward, left, up (map units)
	// 1.97 F7: against the body pose that came WITH the sample (pBod / pByaw), not against
	// the pawn's live position and angle. Those two are a tic apart -- the hand is written by
	// the renderer at the end of a frame, the pawn turns in the tic after -- and that gap is
	// what used to turn a snap turn into a swing.
	Vector3 BodyFrame(PlayerPawn mo, Vector3 p)
	{
		Vector3 d = p - pBod;
		double c = cos(pByaw), s = sin(pByaw);
		return (d.x * c + d.y * s, -d.x * s + d.y * c, d.z);
	}

	// Drop the paint and take the ring down.
	void Unlock()
	{
		if (lockRing)
			lockRing.Destroy();
		lockRing = null;
		lockTarget = null;
		lockKeep = 0;
	}

	// While the throw is held: paint the monster the hand points at. A lock STAYS locked
	// until it dies, is lost from sight, or leaves a much wider cone than the one that
	// took it -- otherwise it flickers off every time the arm moves to wind up. Same
	// shape as the Quest ShieldSaw's disc locks (ssq/disc.zs).
	void LockTick(PlayerPawn mo)
	{
		if (!Frame(mo) || KindFor(mo) != AXE)
		{
			Unlock();
			return;
		}
		// 2.0.2a (owner 19:51, "lock on was sloppy, tighten and refine"): picked inside 8 degrees of the hand's
		// line (was 16), kept to 1.5x that (was 2.2x: 35 degrees, so the ring hung on whatever it first touched)
		double cone = clamp(Cv(mo, 'rsvr_axe_pick_cone', 8.0), 1.0, 90.0);
		double range = clamp(Cv(mo, 'rsvr_axe_lock_range', 1200.0), 64.0, 8192.0);
		Vector3 from = fH;
		Vector3 aim = fF;
		if (lockTarget)
		{
			Vector3 to = lockTarget.pos + (0, 0, lockTarget.height * 0.5) - from;
			double dist = to.Length();
			// 2.0.3e (owner 22:23, "the axe needs to TAG an enemy ... our lock is lost when I raise my arm to
			// throw, so I always miss"): a tag is NOT a lock. Once tagged it stays, wherever the hand points
			// (winding up swings the hand far off the line). It goes only when the monster dies, gets out of
			// range, or is out of sight for 2 seconds.
			if (mo.CheckSight(lockTarget))
				lockSeen = mo.Level.maptime;
			bool keep = lockTarget.health > 0 && dist > 1 && dist <= range * 1.5
				&& mo.Level.maptime - lockSeen <= 70;
			if (!keep)
				Unlock();
		}
		if (!lockTarget)
		{
			Actor best = null;
			double bestAng = cone;
			let it = BlockThingsIterator.CreateFromPos(from.x, from.y, from.z - range, range * 2.0, range, false);
			while (it.Next())
			{
				Actor t = it.thing;
				if (!t || t == mo || t.player || !t.bISMONSTER || !t.bSHOOTABLE
					|| t.bFRIENDLY || t.bDORMANT || t.health <= 0)
					continue;
				Vector3 to = t.pos + (0, 0, t.height * 0.5) - from;
				double dist = to.Length();
				if (dist < 1 || dist > range)
					continue;
				double ang = acos(clamp((to / dist) dot aim, -1, 1));
				if (ang >= bestAng || !mo.CheckSight(t))
					continue;
				bestAng = ang;
				best = t;
			}
			if (best)
			{
				lockTarget = best;
				lockSeen = mo.Level.maptime;
				lockRing = Actor.Spawn('RSVR_AxeLock', RSVR_AxeLock.Above(best), ALLOW_REPLACE);
				Buzz(mo);	// the hand says the paint landed
			}
		}
		if (lockRing && lockTarget)
			lockRing.SetOrigin(RSVR_AxeLock.Above(lockTarget), true);
	}

	bool Throw(PlayerPawn mo)
	{
		if (KindFor(mo) != AXE || !Frame(mo))
			return false;
		// 2.0.2: the axe is never two-handed, so it always throws (the 2026-10-23 two-handed rule is gone)

		// fastest step of the axe's edge over the last few tics: people slow
		// down as they let go
		placeK = AXE;	// r12 port: the axe's own move (RSVR_MeleeMove)
		Vector3 t1 = Place(BladeOut(AXE));
		Vector3 p1 = mo.pos;
		double best = 0;
		Vector3 vel = (0, 0, 0);
		int n = min(count, 4);
		for (int i = 0; i < n; i++)
		{
			int j = (head - i + HIST) % HIST;
			Vector3 t0 = (tx[j], ty[j], tz[j]);
			Vector3 p0 = (px[j], py[j], pz[j]);
			Vector3 v = t1 - t0;
			double rel = (v - (p1 - p0)).Length();
			if (rel > best)
			{
				best = rel;
				vel = v;
			}
			t1 = t0;
			p1 = p0;
		}
		if (ThrowMs() < THROW_MIN || vel.Length() <= 0)     // ONE THROW: the hand decides (ThrowSample)
			return false;

		double spd = clamp(vel.Length() * 3, 14, 42);
		Vector3 dir = vel.Unit();
		// F11 (owner): the arm's own motion blended with where the hand points, as the ShieldSaw
		// (ssq_throw_blend 0.7) and the saber (0.6) do. 1 = all arm (as it was), 0 = all aim.
		double bl = clamp(Cv(mo, 'rsvr_axe_throw_blend', 0.7), 0.0, 1.0);
		if (fF.Length() > 0)
			dir = (dir * bl + fF.Unit() * (1.0 - bl)).Unit();
		Vector3 from = Place(AxeHead());
		if (!Clear(mo, fH, from))
			from = fH;
		// a painted target takes the throw; with nothing painted, the old 8-degree assist
		Actor seek = null;
		if (lockTarget && lockTarget.health > 0)
		{
			// 2.0.2a: a locked throw flies straight and is steered onto the monster (RSVR_AxeSeek):
			// no drop to guess, and a monster that moves is still hit
			Vector3 to = lockTarget.pos + (0, 0, lockTarget.height * 0.5) - from;
			if (to.Length() > 0)
				dir = to.Unit();
			spd = max(spd, 30);
			seek = lockTarget;
		}
		else
			dir = AimAssist(mo, from, dir, spd);

		Name cname = mo.CountInv('PowerStrength') > 0 ? 'ThrowedAxeStrong' : 'ThrowedAxe';
		class<Actor> cls = cname;
		if (!cls)
			return false;
		let axe = Actor.Spawn(cls, from, ALLOW_REPLACE);
		if (!axe)
			return false;
		axe.target = mo;
		axe.angle = VectorAngle(dir.x, dir.y);
		axe.pitch = -asin(clamp(dir.z, -1, 1));
		axe.vel = dir * spd;
		mo.A_StartSound("Axe/Throw", CHAN_WEAPON, CHANF_OVERLAP);
		Buzz(mo);
		if (seek)
			RSVR_AxeSeek.Start(axe, seek);
		axe.CheckMissileSpawn(mo.radius);
		Reset();
		return true;
	}

	// a throw within 8 degrees of a visible monster goes to it, arced for the drop
	static Vector3 AimAssist(PlayerPawn mo, Vector3 from, Vector3 dir, double spd)
	{
		Actor best = null;
		double bestCos = cos(8);
		let it = ThinkerIterator.Create('Actor');
		Actor t;
		while (t = Actor(it.Next()))
		{
			if (!t.bISMONSTER || !t.bSHOOTABLE || t.bFRIENDLY || t.bDORMANT || t.health <= 0)
				continue;
			Vector3 to = t.pos + (0, 0, t.height * 0.5) - from;
			double dist = to.Length();
			if (dist < 1 || dist > 1536)
				continue;
			double c = (to dot dir) / dist;
			if (c <= bestCos || !mo.CheckSight(t))
				continue;
			bestCos = c;
			best = t;
		}
		if (!best)
			return dir;
		Vector3 to = best.pos + (0, 0, best.height * 0.5) - from;
		double tics = to.Length() / spd;
		to.z += 0.5 * mo.GetGravity() * tics * tics;
		return to.Unit();
	}
}

// the axe's alt-fire state gives this every tic it holds; it never stays in
// the inventory, it only runs RSVR_Hand.Grip for the player
class RSVR_AxeGrip : Inventory
{
	override bool TryPickup(in out Actor toucher)
	{
		let mo = PlayerPawn(toucher);
		if (mo)
			RSVR_Hand.Grip(mo);
		return false;
	}
}

// 2.0.2: the off-hand axe's hold, every tic (Axe.dec RSQ_Off_BrutalAxe OffTrigGrip); never kept
class RSVR_OffAxeGrip : Inventory
{
	override bool TryPickup(in out Actor toucher)
	{
		let mo = PlayerPawn(toucher);
		if (mo)
			RSVR_Hand.GripOff(mo);
		return false;
	}
}

class RSVR_Token : Inventory
{
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}
}

class RSVR_AxeHolding : RSVR_Token {}
class RSVR_MainAxeGone : RSVR_Token {}
class RSVR_GiveOffAxe : RSVR_Token {}	// 2.0.3j: a wall axe was taken while the main hand had one	// 2.0.3i: the main axe was thrown; it leaves the inventory once the fists are up
class RSVR_AxeHold : RSVR_Token {}		// the hold input is down: Ready enters the hold loop
class RSVR_AxeThrown : RSVR_Token {}
class RSVR_AxeTrig : RSVR_Token {}
class RSVR_AxeVRThrow : RSVR_Token {}
class RSVR_MeleeTwo : RSVR_Token {}	// F11: the off grip held near the axe or the sword
class RSVR_AxeTwo : RSVR_Token {}		// 2.0.2: never given (the axe is never two-handed); hands.zs still asks
class RSVR_OffAxeHolding : RSVR_Token {}	// 2.0.2: the off-hand axe (RSQ_Off_BrutalAxe)
class RSVR_OffAxeThrown : RSVR_Token {}
class RSVR_OffAxeVRThrow : RSVR_Token {}
class RSVR_OffAxeGone : RSVR_Token {}		// thrown: melee.zs WorldTick puts the copy away
class RSVR_SwordTwo : RSVR_Token {}	// r6b: the engine steadies the sword: the DSL2 placement, 2.0x		// both hands on the haft: the shifted placement
class RSVR_NotVR : RSVR_Token {}
class RSVR_SwordVR : RSVR_Token {}		// 2.0.2: VR with the sword in hand: Dragonslayer.dec Fire runs no BD22 combo
class RSVR_SawVR : RSVR_Token {}		// r6: VR with the chainsaw in hand: Saw.dec Fire runs RSVR_SawRun

// a projectile the engine counts as a shot: spawning it buzzes the weapon hand
class RSVR_Buzz : Actor
{
	Default
	{
		Projectile;
		+NOCLIP
		Radius 1;
		Height 1;
		Speed 1;
		DamageType "RSVRHaptic";
		RenderStyle "None";
	}
	States
	{
	Spawn:
		TNT1 A 1;
		Stop;
	}
}

// 2.0.2a: a locked axe throw homes on its monster: weightless, turned up to 12 degrees a tic toward the
// monster's middle, at its throw speed. It lets go (gravity back) on its first bounce, when the monster
// dies, or after 3 seconds. Logs with rsvr_axe_seek_log 1.
class RSVR_AxeSeek : Thinker
{
	Actor axe, tgt;
	int bounces, endTic;
	double spd;

	static void Start(Actor axe, Actor tgt)
	{
		let s = new('RSVR_AxeSeek');
		s.axe = axe;
		s.tgt = tgt;
		s.bounces = axe.bouncecount;
		s.spd = axe.vel.Length();
		s.endTic = axe.Level.maptime + 105;
		axe.tracer = tgt;
		axe.bNoGravity = true;
	}

	override void Tick()
	{
		if (!axe)
		{
			Destroy();
			return;
		}
		if (!tgt || tgt.health <= 0 || axe.bouncecount != bounces || axe.Level.maptime > endTic || spd <= 0)
		{
			axe.bNoGravity = false;
			Destroy();
			return;
		}
		Vector3 to = tgt.pos + (0, 0, tgt.height * 0.5) - axe.pos;
		double d = to.Length();
		if (d < 1)
			return;
		Vector3 want = to / d;
		Vector3 cur = axe.vel.Length() > 0 ? axe.vel.Unit() : want;
		double ang = acos(clamp(cur dot want, -1, 1));
		Vector3 nd = want;
		if (ang > 12)
		{
			double t = 12 / ang;
			nd = (cur * (1 - t) + want * t).Unit();
		}
		axe.vel = nd * spd;
		axe.angle = VectorAngle(nd.x, nd.y);
		axe.pitch = -asin(clamp(nd.z, -1, 1));
		if (CVar.FindCVar('rsvr_axe_seek_log') && CVar.FindCVar('rsvr_axe_seek_log').GetInt())
			Console.Printf("RSVR axe seek t%d: %.0f units to %s, turned %.1f deg", axe.Level.maptime, d, tgt.GetClassName(), ang);
	}
}

// The ring painted on the monster the axe is aimed at while a throw is readied. The art is
// the Quest ShieldSaw's own lock mark (ssq/disc.zs SSQ_LockMark), carried here under our
// own sprite name so the two mods never share a lump -- which is what ShieldSaw did with
// the saber's UBLK frames. 48x48 drawn at 0.35, billboarded so it is never seen edge-on.
class RSVR_AxeLock : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTONAUTOMAP
		+FORCEXYBILLBOARD
		RenderStyle "Add";
		Alpha 0.95;
		Scale 0.35;
	}
	// 2.0.2a: above the head, where QuestSaber puts its mark (UBQS_LockMark: height + 8), not in the body
	static Vector3 Above(Actor t) { return t.pos + (0, 0, t.height + 8); }
	States
	{
	Spawn:
		RQLK ABCD 3 Bright;
		Loop;
	}
}

// r12 port (lane B): the melee weapons are drawn moved to the fitted FBX hand (MODELDEF Offset / Angle, tools/handfit/port/melee_r12.py),
// so their hit points move with them: the point Place() computed in the ORIGINAL placement (controller frame, F / L / U cm, the
// QZD chain at vr_weaponScale 1.02) -> R p + t, the weapon's own rigid move. One block per weapon and placement (poseFrame).
class RSVR_MeleeMove abstract
{
	static Vector3 Apply(int k, int pf, Vector3 p)
	{
		// 2.0 int r2: the butt strike / pistol whip guns, moved to the FBX hand by the r9..r12 ports (tools/int20_rig/butt_move.py)
		if (k == RSVR_Hand.RIFLEBUTT && pf == 0)	// Rifle (gun_move, tools/handfit/poses/Rifle.json)
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 5.7921, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + 1.6646, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + 4.9479);
		if (k == RSVR_Hand.SGBUTT && pf == 0)	// Shot_Gun (gun_move, tools/handfit/poses/Shot_Gun.json)
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 4.1373, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + 5.5150, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + -2.2130);
		if (k == RSVR_Hand.SSGBUTT && pf == 0)	// SSG (gun_move, tools/handfit/poses/SSG.json)
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 3.8398, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + 5.8258, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + -6.0133);
		if (k == RSVR_Hand.ASGBUTT && pf == 0)	// AssaultShotgun (gun_move, tools/handfit/poses/AssaultShotgun.json)
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 4.6856, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + 6.7137, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + -5.2711);
		if (k == RSVR_Hand.MP40BUTT && pf == 0)	// MP40 (gun_move, tools/handfit/poses/MP40.json)
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 4.3510, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + 2.9954, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + 4.5470);
		if (k == RSVR_Hand.SMGBUTT && pf == 0)	// BrutalSMG (gun_move, tools/handfit/poses/BrutalSMG.json)
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 4.4405, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + 1.1050, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + 3.3465);
		if (k == RSVR_Hand.MGBUTT && pf == 0)	// Machinegun (gun_move, tools/handfit/poses/Machinegun.json)
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 3.8472, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + 2.6254, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + 4.7226);
		if (k == RSVR_Hand.MG42BUTT && pf == 0)	// MG42 (gun_move, tools/handfit/poses/MG42.json)
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 2.7396, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + 2.7430, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + 6.3178);
		if (k == RSVR_Hand.PISTOL && pf == 0)	// BrutalPistol (gun_move, tools/handfit/poses/BrutalPistol.json)
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 8.2136, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + 1.1930, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + 5.3519);
		if (k == RSVR_Hand.REVOLVER && pf == 0)	// Revolver (gun_move, tools/handfit/poses/Revolver.json)
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 5.2965, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + 1.5468, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + 3.9587);
		// r12 port: BrutalAxe
		if (k == RSVR_Hand.AXE && pf == 0)	// BrutalAxe one-handed
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 12.9934, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + -0.2948, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + 4.5647);
		if (k == RSVR_Hand.AXE && pf == 1)	// BrutalAxe AXE2 (two hands)
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 12.9934, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + -0.2948, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + 4.5647);
		// r12 port: DSweap
		if (k == RSVR_Hand.SWORD && pf == 0)	// DSweap one-handed
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 1.4218, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + -0.7103, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + 2.4235);
		if (k == RSVR_Hand.SWORD && pf == 3)	// DSweap DSL2 (two hands): K M K^-1 on the old DSL2 point
			return (0.986393 * p.x + -0.152196 * p.y + -0.062166 * p.z + -2.7636, 0.159167 * p.x + 0.978743 * p.y + 0.129337 * p.z + -0.7103, 0.041160 * p.x + -0.137472 * p.y + 0.989650 * p.z + 0.5072);
		// r12 port: Chain_saw
		if (k == RSVR_Hand.SAW && pf == 2)	// Chain_saw saw
			return (0.996020 * p.x + -0.077127 * p.y + -0.044664 * p.z + 0.0242, 0.067099 * p.x + 0.978743 * p.y + -0.193804 * p.z + -0.5114, 0.058662 * p.x + 0.190036 * p.y + 0.980023 * p.z + -6.2932);
		return p;
	}
}
