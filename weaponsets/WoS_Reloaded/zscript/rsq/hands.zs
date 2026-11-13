// RS VR hands for BD22 and Vanilla VR Plus on QuestZDoom 17.x. rsq_hands 0 hides them.
//
// The hands and their poses are Ermac's (Force Unleashed / Rusted Legacy, MIT):
// a gun hand posed on each gun's grip, a support hand posed on its front, and
// an off hand that is open, or holds the right magazine / shell / cell while
// reloading. rsq_hands_gen.py fitted his poses onto each set's guns
// (handtable.zs, one per set).
//
//   gun hand      always on the gun (none for melee weapons, two-gun weapons and the flame
//                 cannon your arm goes into). Fists and punches: the FBX fist (2026-10-28,
//                 was Ermac's), in both hands; the VR grenade: the FBX nade hand round it (OwnHand)
//   off hand      free on the off controller. When the engine steadies the gun
//                 with both hands (the off hand brought to the gun and grip
//                 pressed: vr_two_handed_weapons), it takes hold of the front
//                 of the gun (the support hand), the way Ermac's two-hand
//                 models swap in, and lets go when the engine does. It never
//                 holds on while a reload needs it.
//
// The gun and support hands stay on the gun when it moves under them: when its
// layer is offset (raised, lowered, kicked by Offset) and when its model frames
// kick (BD22's and Vanilla VR Plus's recoil is in the meshes: gunmoves.zs, one
// per set, made by rsq_gunmoves_gen.py).
//
// How they reach the controllers (no engine changes): models.cpp puts a layer
// on the OFF controller only when its caller is the off-hand weapon, so the
// free hand belongs to RSQ_Hands (an off-hand weapon that never fires) and the
// gun and support hands to RSQ_GunSide (a plain item: main controller).
// hw_weapon.cpp asks the off-hand weapon's ModifyBobLayer3D where to put every
// layer that is not the ready weapon's; that places them per gun.

class RSQ_Layers abstract
{
	const GUNHAND = 2100;	// RSQ_GunSide, main controller
	const SUPPORT = 2101;	// RSQ_GunSide, main controller
	const FREEHAND = 2200;	// RSQ_Hands, off controller

	// 2026-10-23: ONE PSPRITE ID HOLDS ONE CALLER. Several lanes hand out layer ids in this
	// range -- the hands here, the real reload (rsr/vreload.zs), break-open (rsr_break.zs),
	// the pump (rsr_pump.zs), the M203 (rsr_m203.zs) -- and a clash between them is silent:
	// both owners SetPsprite the same id every tic and whichever ran last wins, so one of the
	// two features simply stops working with nothing in the log. Anything claiming a NEW id
	// asks here first. Free as of today: 2112-2119, 2124-2129, and 2132 upward.
	clearscope static bool Taken(int id)
	{
		return id == GUNHAND || id == SUPPORT || id == FREEHAND
			|| id >= RSR.LAYER_FIRST && id <= RSR.LAYER_LAST || id == RSR.HANDMAG
			|| id >= RSB.LAYER_FIRST && id <= RSB.LAYER_LAST
			|| id == RSB.HANDROUND || id == RSB.HANDROUND2
			|| id >= RSP.LAYER_FIRST && id <= RSP.LAYER_LAST || id == RSP.HANDSHELL
			|| id >= RSM.LAYER_FIRST && id <= RSM.LAYER_LAST;
	}
}

class RSQ_GunSide : Inventory
{
	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.QUIET
	}

	States
	{
	GunA: RQGS A -1; Stop;
	GunB: RQGS B -1; Stop;
	GunC: RQGS C -1; Stop;
	GunD: RQGS D -1; Stop;
	GunE: RQGS E -1; Stop;
	GunF: RQGS F -1; Stop;
	GunG: RQGS G -1; Stop;
	GunH: RQGS H -1; Stop;	// BD22 v9: axe, chainsaw. V+: BFG
	// the gun hand with its index finger on the trigger, and squeezing it (fire held)
	TrgA: RQGT A -1; Stop;
	SqzA: RQGU A -1; Stop;
	TrgB: RQGT B -1; Stop;
	SqzB: RQGU B -1; Stop;
	TrgC: RQGT C -1; Stop;
	SqzC: RQGU C -1; Stop;
	TrgD: RQGT D -1; Stop;
	SqzD: RQGU D -1; Stop;
	TrgE: RQGT E -1; Stop;
	SqzE: RQGU E -1; Stop;
	TrgF: RQGT F -1; Stop;
	SqzF: RQGU F -1; Stop;
	TrgG: RQGT G -1; Stop;
	SqzG: RQGU G -1; Stop;
	TrgH: RQGT H -1; Stop;
	SqzH: RQGU H -1; Stop;
	TrgI: RQGT I -1; Stop;
	SqzI: RQGU I -1; Stop;
	TrgJ: RQGT J -1; Stop;
	SqzJ: RQGU J -1; Stop;
	TrgK: RQGT K -1; Stop;
	SqzK: RQGU K -1; Stop;
	TrgL: RQGT L -1; Stop;
	SqzL: RQGU L -1; Stop;
	TrgM: RQGT M -1; Stop;
	SqzM: RQGU M -1; Stop;
	TrgN: RQGT N -1; Stop;
	SqzN: RQGU N -1; Stop;
	TrgO: RQGT O -1; Stop;
	SqzO: RQGU O -1; Stop;
	TrgP: RQGT P -1; Stop;
	SqzP: RQGU P -1; Stop;
	TrgQ: RQGT Q -1; Stop;
	SqzQ: RQGU Q -1; Stop;
	TrgR: RQGT R -1; Stop;
	SqzR: RQGU R -1; Stop;
	SupA: RQSP A -1; Stop;
	SupM1: RQ2S A -1; Stop;	// 1.31 RSR-M203: the off hand on the launcher, finger on its trigger
	SupM2: RQ2S B -1; Stop;	// ...squeezed
	SupB: RQSP B -1; Stop;
	SupC: RQSP C -1; Stop;
	SupD: RQSP D -1; Stop;
	SupE: RQSP E -1; Stop;
	SupF: RQSP F -1; Stop;
	// BD 2.0 b1: the FBX hands (rows 4 BrutalPistol, 7 Flamethrower2; lane_c r5)
	FbxTrgP: RQFG A -1; Stop;
	FbxSqzP: RQFG B -1; Stop;
	FbxTrgF: RQFG C -1; Stop;
	FbxSqzF: RQFG D -1; Stop;
	FbxSupP: RQFS A -1; Stop;
	FbxSupF: RQFS B -1; Stop;
	FbxSupDS: RQXD A -1; Stop;	// r12 port: DSweap (row 26) support
	FbxSupSaw: RQXC A -1; Stop;	// r12 port: Chain_saw (row 25) support
	FbxSupFC: RQXB A -1; Stop;	// r12 port: FlameCannon (row 28) support
	FbxSupMini: RQXA A -1; Stop;	// r12 port: Minigun (row 13) support
	// support192 BEGIN: the FBX support hands fitted from the 1.92 holds (tools/handfit/support192)
	FbxWrapSSG: RQWS A -1; Stop;	// SSG (row 20)
	FbxWrapShotGun: RQWS B -1; Stop;	// Shot_Gun (row 21)
	FbxWrapAS: RQWS C -1; Stop;	// AssaultShotgun (row 1)
	FbxWrapRifle: RQWS D -1; Stop;	// Rifle (row 18)
	FbxWrapDevastator: RQWS E -1; Stop;	// Devastator (row 6)
	FbxWrapInc: RQWS F -1; Stop;	// IncendiaryLauncher (row 10)
	FbxWrapGL: RQWS G -1; Stop;	// GrenadeLauncher (row 8)
	FbxWrapRL: RQWS H -1; Stop;	// Rocket_Launcher (row 19)
	FbxWrapPlasmaGun: RQWS I -1; Stop;	// Plasma_Gun (row 15)
	FbxWrapRailGun: RQWS J -1; Stop;	// RailGun (row 16)
	FbxWrapSniper: RQWS K -1; Stop;	// Sniper (row 22)
	FbxWrapMG42: RQWS L -1; Stop;	// MG42 (row 11)
	FbxWrapMachinegun: RQWS M -1; Stop;	// Machinegun (row 27)
	FbxWrapNukeLauncher: RQWS N -1; Stop;	// NukeLauncher (row 14)
	FbxWrapBFG10k: RQWS O -1; Stop;	// BFG10k (row 2)
	FbxWrapBFG9: RQWS P -1; Stop;	// BIG_FUCKING_GUN (row 3)
	FbxWrapUnmaker: RQWS Q -1; Stop;	// Unmaker (row 23)
	FbxWrapHML: RQWS R -1; Stop;	// HellishMissileLauncher (row 9)
	FbxWrapBrutalAxe: RQWS S -1; Stop;	// BrutalAxe (row 24)
	// support192 END
	// batch 2: BrutalSMG (row 5), the pistol's FBX hand with the index on the SMG trigger
	FbxTrgS: RQFH A -1; Stop;
	FbxSqzS: RQFH B -1; Stop;
	// batch 3: MP40 (row 12)
	FbxTrgM: RQFI A -1; Stop;
	FbxSqzM: RQFI B -1; Stop;
	// batch 4: Rifle (row 18)
	FbxTrgRif: RQFJ A -1; Stop;
	FbxSqzRif: RQFJ B -1; Stop;
	// shotguns: AssaultShotgun (row 1)
	FbxTrgAS: RQFQ A -1; Stop;
	FbxSqzAS: RQFQ B -1; Stop;
	// batch 4: Revolver (row 17)
	FbxTrgRev: RQFK A -1; Stop;
	FbxSqzRev: RQFK B -1; Stop;
	// batch 4: BrutalRevolver (row 17)
	FbxTrgBru: RQFL A -1; Stop;
	FbxSqzBru: RQFL B -1; Stop;
	// shotguns: Shot_Gun (row 21)
	FbxTrgSG: RQFP A -1; Stop;
	FbxSqzSG: RQFP B -1; Stop;
	// r9 port: GrenadeLauncher (row 8)
	FbxTrgGL: RQV7 A -1; Stop;
	FbxSqzGL: RQV7 B -1; Stop;
	// r9 port: Rocket_Launcher (row 19)
	FbxTrgRL: RQV6 A -1; Stop;
	FbxSqzRL: RQV6 B -1; Stop;
	// r9 port: RailGun (row 16)
	FbxTrgRail: RQV5 A -1; Stop;
	FbxSqzRail: RQV5 B -1; Stop;
	// r9 port: Plasma_Gun (row 15)
	FbxTrgPlas: RQV4 A -1; Stop;
	FbxSqzPlas: RQV4 B -1; Stop;
	// r9 port: Minigun (row 13)
	FbxTrgMini: RQV3 A -1; Stop;
	FbxSqzMini: RQV3 B -1; Stop;
	// r9 port: Sniper (row 22)
	FbxTrgSni: RQFN A -1; Stop;
	FbxSqzSni: RQFN B -1; Stop;
	// r10 port: MG42 (row 11)
	FbxTrgMG42: RQV1 A -1; Stop;
	FbxSqzMG42: RQV1 B -1; Stop;
	// r10 port: Machinegun (row 27)
	FbxTrgMGun: RQV2 A -1; Stop;
	FbxSqzMGun: RQV2 B -1; Stop;
	// r10 port: NukeLauncher (row 14)
	FbxTrgNuke: RQV9 A -1; Stop;
	FbxSqzNuke: RQV9 B -1; Stop;
	// r10 port: BFG10k (row 2)
	FbxTrgBFGk: RQVA A -1; Stop;
	FbxSqzBFGk: RQVA B -1; Stop;
	// r11 port: BIG_FUCKING_GUN (row 3)
	FbxTrgBFG9: RQVB A -1; Stop;
	FbxSqzBFG9: RQVB B -1; Stop;
	// r11 port: IncendiaryLauncher (row 10)
	FbxTrgInc: RQV8 A -1; Stop;
	FbxSqzInc: RQV8 B -1; Stop;
	// r11 port: Devastator (row 6)
	FbxTrgDeva: RQVC A -1; Stop;
	FbxSqzDeva: RQVC B -1; Stop;
	// r11 port: SSG (row 20)
	FbxTrgSSG: RQVD A -1; Stop;
	FbxSqzSSG: RQVD B -1; Stop;
	// r12 port: Unmaker (row 23)
	FbxTrgUnm: RQVE A -1; Stop;
	FbxSqzUnm: RQVE B -1; Stop;
	// r12 port: HellishMissileLauncher (row 9)
	FbxTrgHML: RQVF A -1; Stop;
	FbxSqzHML: RQVF B -1; Stop;
	// r12 port: Chain_saw (row 25)
	FbxTrgSaw: RQVG A -1; Stop;
	FbxSqzSaw: RQVG B -1; Stop;
	// r12 port: DSweap (row 26)
	FbxTrgDS: RQVH A -1; Stop;
	FbxSqzDS: RQVH B -1; Stop;
	// r12 port: BrutalAxe (row 24)
	FbxTrgAxe: RQVI A -1; Stop;
	FbxSqzAxe: RQVI B -1; Stop;
	Fist: RQGF A -1; Stop;	// the FBX fist (the free hand's fist too, fbx_oh_free_R.md3 frame 1): fists, punches
	Nade: RQGN A -1; Stop;	// the FBX hand round the VR grenade (fbx_nade_R.md3, fit_nade.py)
	// 2026-10-23: the VR scope's collimated reticle (rsq/scope.zs, layer RSQ_ScopeLayers.RETICLE).
	// Its own sprite, so it carries its own flat quad in MODELDEF and nothing about it is tied
	// to the hand meshes; ModifyBobLayer3D puts it on the glass every rendered frame. Bright,
	// because a reflex dot is light on glass and not paint on it.
	ScopeDot: RQRT A -1 Bright; Stop;
	ScopeRing: RQRT B -1 Bright; Stop;	// the same dot inside a ring; no option selects it yet
	Hidden: TNT1 A -1; Stop;
	}
}

class RSQ_Hands : Weapon
{
	// 2026-10-23: where the scope reticle's quad is parked when there is no sight picture.
	// Centimetres back along the model's own z (see ModifyBobLayer3D), so it clips away.
	const DOT_FARAWAY = 1000000.0;

	// How the ready weapon's model frame has moved the gun (RSQ_GunMoves), for
	// ModifyBobLayer3D: looked up in play by A_RSQ_Layers when the gun layer
	// changes frame, read by the renderer.
	State gunState;				// the gun layer's state, sprite and frame they are for
	int gunSprite, gunFrame;
	Vector3 gunTurn, gunMove;	// that frame
	Vector3 nextTurn, nextMove;	// the next state's frame, which the engine blends toward
	bool showOwn;				// the gun hand shows its own fist or grenade hold (OwnHand), at Ermac's placement
	bool freeFist;				// the free hand is a fist this tic (rsq/fists.zs punches with it)
	Array<int> fistSprites;		// BD22's punch / fist sprites (MODELDEF.bd.txt hides its glove on them)
	int nadeSprite;
	Array<int> bdHandSprites;
	Array<int> ongSprites, ungSprites;	// 1.5: the jab / cross and uppercut families (RSQ_FistMoves)
	int unsSprite;
	int fistMesh, fistMeshPrev;			// the main fist's BD punch frame, this tic and the last
	int offMesh, offMeshPrev;			// the off fist's punch frame
	int offPunchTic;					// -1 idle; the off-hand trigger punch's tic
	bool offTrigPrev;	// sprites where BD22's own hand model shows (taunts, grabs, carries)
	Weapon readyWas;	// 2.0.4i: the main hand's weapon last tic (Upkeep: a switch TO a gun takes the off glove back)
	bool dotClash;		// the scope reticle's layer id clashes with another lane's: said once

	override void BeginPlay()
	{
		Super.BeginPlay();
		offPunchTic = -1;
	}

	Default
	{
		+WEAPON.OFFHANDWEAPON
		+WEAPON.NOHANDSWITCH
		+WEAPON.NO_AUTO_SWITCH
		+WEAPON.NOAUTOSWITCHTO
		+WEAPON.NOALERT
		+WEAPON.CHEATNOTWEAPON
		+WEAPON.NODEATHINPUT
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.QUIET
		Weapon.SelectionOrder 32000;
		Weapon.Kickback 0;
		Weapon.UpSound "";
		Weapon.ReadySound "";
		Weapon.UseRange 48;
		Tag "Fist";
		Weapon.SlotNumber 1;	// 1.5: selectable in the OFF hand (slot 1), so a gun moved there can be swapped back for the fist
	}

	static bool OffFist(PlayerPawn mo)
	{
		let h = RSQ_Hands(mo.FindInventory('RSQ_Hands'));
		return h && h.freeFist && mo.player && mo.player.OffhandWeapon == h;
	}

	static bool Shown(PlayerPawn mo)
	{
		return mo && RSQ.PlayerInt(mo, 'rsq_hands', 1) != 0 && RSVR_VRHand.InVR(mo);
	}

	// every tic, from RSQ_Handler.WorldTick: hand the player the off-hand
	// weapon when hands are on and they are playing in VR
	static void Upkeep(PlayerPawn mo)
	{
		let p = mo.player;
		if (!p || p.playerstate != PST_LIVE || mo.health <= 0 || !Shown(mo) && !RSR_ReloadHandler.WantsHands(mo))
			return;
		let h = Weapon(mo.FindInventory('RSQ_Hands'));
		if (!h)
		{
			mo.GiveInventory('RSQ_Hands', 1);
			h = Weapon(mo.FindInventory('RSQ_Hands'));
		}
		// 2026-10-23 (owner: empty gun -> dual -> back to one gun -> no reload ever again).
		// The real reload only runs while the off hand IS these hands (vreload.zs Wanted),
		// and this used to re-arm them only when the slot was EMPTY. A stale dual copy --
		// one whose gun is not the gun in the main hand -- sits in the slot forever, so the
		// slot is neither empty nor RSQ_Hands and reloading dies silently for EVERY gun.
		// A copy that matches the ready weapon is a real dual wield and is left alone.
		let off = p.OffhandWeapon;
		// 2026-10-27: only OUR leftover Dual copy is stale. Any other off-hand weapon (QZD's
		// switchhand, the QuestSaber, the ShieldSaw, a holstered gun) is left alone.
		// 2.0.3i (owner 07:00): the off-hand AXE is an off-hand weapon of its own, never stale: it may be
		// cycled into the off hand whatever the main hand holds (melee.zs puts it away once on a switch)
		// 2.0.3y (owner, BUGS_1.0 item 5: the off-hand rule, dual.zs): every gun in the off hand is its off-hand version
		// now, put there on purpose (a holster, the Wheel, a catch, switch hand), so no copy is stale any more: it stays
		// until the player moves it. (A copy whose gun left the main hand used to be swapped for the fist here.)
		bool stale = false;
		// 2.0.4i (owner 11-11: no hands on the guns, no pump, no rifle grenade load): RSQ Melee's off glove
		// (RSQ_GloveOff: Start With Melee Hands, a Wheel pick of the gloves) stayed in the off hand after the main
		// hand went back to a gun, so these hands never came back. When the main hand SWITCHES to a gun of the hand
		// table and the off hand holds a glove, the glove goes back to the inventory and the hands return. Only on
		// the switch: a glove picked into the off hand while a gun is already held stays.
		let rh = RSQ_Hands(h);
		if (rh && off && !stale && p.ReadyWeapon && p.ReadyWeapon != rh.readyWas && RSQ_HandTable.Index(p.ReadyWeapon) > 0)
		{
			String on = off.GetClassName();
			if (on ~== "RSQ_GloveOff")
				stale = true;
		}
		bool can = p.PendingWeapon == WP_NOCHANGE;
		if (rh && (!stale || can))	// a switch still pending: try again next tic
			rh.readyWas = p.ReadyWeapon;
		if (h && (!off || stale) && can)
			p.PendingWeapon = h;
	}

	action void A_RSQ_Layers()
	{
		let p = player;
		let mo = PlayerPawn(self);
		if (!p || !mo)
			return;
		bool on = Shown(mo);
		let s = RSQ_Handler.StateOf(mo);
		int carry = s ? s.carry : 0;
		// a real reload (rsr/vreload.zs) has the off hand: it says what the free hand shows
		String rsr = RSR_ReloadHandler.FreeHand(mo);
		if (rsr == "")
			rsr = RSP_Handler.FreeHand(mo);	// RSR-PUMP: the pump shotguns' loading and pump (rsr/rsr_pump.zs)
		if (rsr == "")
			rsr = RSB_Handler.FreeHand(mo);	// RSR-BREAK
		if (rsr == "")
			rsr = RSK_M203Handler.FreeHand(mo);	// 1.30 RSR-M203: the rifle's launcher (rsr/rsr_m203.zs)
		if (rsr == "" && mo.CountInv('RSG_RingHand') > 0)
			rsr = "RsgRing";				// the VR grenade's ring, pinched (rsg/grenade.zs)
		// 2.0.3n: while the engine's Two-Hand Grip holds the gun (WF_TWOHANDSTABILIZED) it draws nothing the off-hand weapon
		// owns (hw_weapon.cpp:832, :917), so an EMPTY free hand during a magazine or break-open reload was not drawn at all,
		// and the support hand was hidden for it too: no off hand anywhere. Empty and steadied, the support hand holds the gun,
		// as the pump and the M203 already do (their FreeHand returns "" while steadied). A hand holding a part is unchanged.
		if (rsr == "FreeHand" && RSVR_VRHand.Steadied(mo))
			rsr = "";
		int i = on ? RSQ_HandTable.Index(p.ReadyWeapon) : 0;
		// 2026-10-28 (owner, overrides his 2026-10-16 "fists are Ermac's, both hands"): the fists are the FBX hand, both hands
		// (MODELDEF RQGF / RQHN H: one FBX fist frame fitted in place of Ermac's, tools/handfit/offhand); the VR grenade sits in the FBX nade hand
		String own = on ? invoker.OwnHand(p) : "";
		invoker.showOwn = own != "";
		if (own != "")
			i = 0;
		// 1.5: the main fist follows BD22's punch frames (jab, cross, uppercut)
		invoker.fistMeshPrev = invoker.fistMesh;
		invoker.fistMesh = own == "Fist" ? invoker.FistFrame(p) : 0;

		// The off hand holds the front of the gun exactly while the engine
		// steadies the gun with both hands (WF_TWOHANDSTABILIZED: the player
		// brought the off hand to the gun and pressed grip), unless a reload
		// needs it. Going by the engine's own grab keeps the hands and the
		// steadying together: a distance snap of our own fought it, and lost
		// the minigun's handlebar grip.
		// 1.12: never while a reload or the shell feed has the hand (rsr): grabbing a shell with grip
		// near the gun also two-hands it, and that hid the hand and the shell it was holding
		bool hold = i > 0 && RSVR_VRHand.TwoHands(PlayerPawn(p.mo)) && s && s.kind == 0 && carry == 0 && rsr == "";
		// 2026-10-16 (owner): pistols and revolvers. The engine's steadying aims the gun along
		// the line from the gun hand to the off hand, which is right for a forend and wrong for
		// a two-hand pistol grip, where the hands are together. So on a cup-support gun the
		// support hand shows by CLOSENESS instead: bring the off hand to the grip, no grip press,
		// and both hands are on the gun while it aims from the gun hand alone. Pressing grip
		// still steadies as stock. (Support "A" = Ermac's pistol cup.)
		if (!hold && i > 0 && s && s.kind == 0 && carry == 0 && RSQ_HandTable.Support(i) == "A" && rsr == "")
		{
			double gap = RSVR_VRHand.SteadyGap(mo);
			hold = gap < (s.holding ? 18.0 : 13.0);		// in at 13 cm, out at 18 (no flicker)
		}
		if (s)
			s.holding = hold;
		// r6b (owner item 10): the sword steadied in two hands. The engine aims it at the off
		// hand, so the off controller is ON the handle line: the off hand shows there, closed
		// (the free fist), instead of the support hand posed for the one-handed sword
		bool swordTwo = i == 26 && mo.CountInv('RSVR_SwordTwo') > 0;
		invoker.FollowGun(p, i);

		static const String ammo[] = { "FreeHand", "AmmoB", "AmmoC", "AmmoD", "AmmoE", "AmmoF", "AmmoG", "AmmoH" };
		// 2026-10-16 (owner): the free off hand is a FIST (it punches: rsq/fists.zs), open only
		// while the grenade is out, to take its ring
		bool nade = p.ReadyWeapon && p.ReadyWeapon.GetClassName() == 'HandGrenades';
		// r12 port (owner item 28: "two hands on the hilt"): the two-handed sword now draws the FBX support hand ON the hilt
		// (FbxSupDS, turned with the sword below), so the free fist is hidden then too
		String fh = !on || hold || swordTwo ? "Hidden" : rsr != "" ? rsr : carry == 0 && !nade ? "AmmoH" : ammo[clamp(carry, 0, 7)];
		invoker.freeFist = fh == "AmmoH";
		invoker.OffPunch(mo);
		invoker.SetLayer(p, RSQ_Layers.FREEHAND, invoker, fh);

		let gs = RSQ_GunSide(FindInventory('RSQ_GunSide'));
		if (!gs)
		{
			A_GiveInventory('RSQ_GunSide', 1);
			gs = RSQ_GunSide(FindInventory('RSQ_GunSide'));
		}
		if (!gs)
			return;
		String g = hold ? RSQ_HandTable.GunTwo(i) : RSQ_HandTable.GunOne(i);
		// the index finger rests on the trigger, and squeezes it while fire is held
		String tf = RSQ_HandTable.Trigger(i);
		String gl = tf != "" ? ((p.cmd.buttons & BT_ATTACK) ? "Sqz" .. tf : "Trg" .. tf) : "Gun" .. g;
		if (i == 4 || i == 7)	// BD 2.0 b1 (lane_c r5): the FBX hands squeeze on the gun's FIRE tics (the frames its Fire / Hold states show), trigger otherwise
		{
			bool fsq = false;
			let fgp = p.FindPSprite(PSP_WEAPON);
			if (fgp && fgp.CurState)
			{
				int ff = fgp.Frame;
				if (i == 4)	// BD22 Pistol.dec ResumeFireFrame / Fire2: "####" A 1 BRIGHT (the shot), then B, C, D 1
					fsq = (fgp.Sprite == Actor.GetSpriteIndex('PIST') || fgp.Sprite == Actor.GetSpriteIndex('2IST')) && (fgp.CurState.bFullbright || ff == 1 || ff == 2 || ff == 3);
				else	// BD22 Flamethrower.dec Fire / Hold: D E G H 1 BRIGHT
					fsq = (fgp.Sprite == Actor.GetSpriteIndex('FLMT') || fgp.Sprite == Actor.GetSpriteIndex('2LMT')) && (fgp.CurState.bFullbright || ff == 3 || ff == 4 || ff == 6 || ff == 7);
			}
			gl = (fsq ? "FbxSqz" : "FbxTrg") .. (i == 4 ? "P" : "F");
		}
		if (i == 1)	// shotguns: AssaultShotgun squeezes on its FIRE frames (gunmoves rows 0-5: 2SAS B-E, 3SAR I, USAS J N O) or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('2SAS') && mf >= 1 && mf <= 4) || (mgp.Sprite == Actor.GetSpriteIndex('3SAR') && mf == 8) || (mgp.Sprite == Actor.GetSpriteIndex('USAS') && (mf == 9 || mf == 13 || mf == 14));
			}
			gl = msq ? "FbxSqzAS" : "FbxTrgAS";
		}
		if (i == 17 && !(RSQ_Alias.BD(p.ReadyWeapon) == 'BrutalRevolver'))	// batch 4: Revolver squeezes on its FIRE frames (Revolver.dec Fire: REVO / 2EVO B C bright, D-G the kick; Revolver2 draws REVO on the same mesh) or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mf >= 1 && mf <= 6 && (mgp.Sprite == Actor.GetSpriteIndex('REVO') || mgp.Sprite == Actor.GetSpriteIndex('2EVO')));
			}
			gl = msq ? "FbxSqzRev" : "FbxTrgRev";
		}
		if (i == 17 && RSQ_Alias.BD(p.ReadyWeapon) == 'BrutalRevolver')	// batch 4: BrutalRevolver squeezes on its FIRE frames (BrutalRevolver.dec Fire: RVMA B D bright, F H) or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mf >= 1 && mf <= 7 && mgp.Sprite == Actor.GetSpriteIndex('RVMA'));
			}
			gl = msq ? "FbxSqzBru" : "FbxTrgBru";
		}
		if (i == 21)	// shotguns: Shot_Gun squeezes on its fire frames (SHTN / 2HTN B-H) or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || ((mgp.Sprite == Actor.GetSpriteIndex('SHTN') || mgp.Sprite == Actor.GetSpriteIndex('2HTN')) && mf >= 1 && mf <= 7);
			}
			gl = msq ? "FbxSqzSG" : "FbxTrgSG";
		}
		if (i == 8)	// r9 port: GrenadeLauncher squeezes on its fire frames: 2RLN BCDE, GRLN BCDE or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('2RLN') && (mf == 1 || mf == 2 || mf == 3 || mf == 4)) || (mgp.Sprite == Actor.GetSpriteIndex('GRLN') && (mf == 1 || mf == 2 || mf == 3 || mf == 4));
			}
			gl = msq ? "FbxSqzGL" : "FbxTrgGL";
		}
		if (i == 19)	// r9 port: Rocket_Launcher squeezes on its fire frames: 2ISF ABCDEFGHIJKLMNOPQRSTU, MISF ABCDEFGHIJKLMNOPQRSTU, MISG BCDEGHJ or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('2ISF') && (mf == 0 || mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 13 || mf == 14 || mf == 15 || mf == 16 || mf == 17 || mf == 18 || mf == 19 || mf == 20)) || (mgp.Sprite == Actor.GetSpriteIndex('MISF') && (mf == 0 || mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 13 || mf == 14 || mf == 15 || mf == 16 || mf == 17 || mf == 18 || mf == 19 || mf == 20)) || (mgp.Sprite == Actor.GetSpriteIndex('MISG') && (mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 6 || mf == 7 || mf == 9));
			}
			gl = msq ? "FbxSqzRL" : "FbxTrgRL";
		}
		if (i == 16)	// r9 port: RailGun squeezes on its fire frames: 2AIF BCDEFG, RAIF BCDEFG or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('2AIF') && (mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6)) || (mgp.Sprite == Actor.GetSpriteIndex('RAIF') && (mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6));
			}
			gl = msq ? "FbxSqzRail" : "FbxTrgRail";
		}
		if (i == 15)	// r9 port: Plasma_Gun squeezes on its fire frames: 2RSG DE, PRSA ABCDEFGHI, PRSG DE or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('2RSG') && (mf == 3 || mf == 4)) || (mgp.Sprite == Actor.GetSpriteIndex('PRSA') && (mf == 0 || mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7 || mf == 8)) || (mgp.Sprite == Actor.GetSpriteIndex('PRSG') && (mf == 3 || mf == 4));
			}
			gl = msq ? "FbxSqzPlas" : "FbxTrgPlas";
		}
		if (i == 13)	// r9 port: Minigun squeezes on its fire frames: CHAE BCDEF, CHAF ABCDEFGHIJKLMNOPQST, CHAG BCDEF, CHAV GHIJKLMNO or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('CHAE') && (mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5)) || (mgp.Sprite == Actor.GetSpriteIndex('CHAF') && (mf == 0 || mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 13 || mf == 14 || mf == 15 || mf == 16 || mf == 18 || mf == 19)) || (mgp.Sprite == Actor.GetSpriteIndex('CHAG') && (mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5)) || (mgp.Sprite == Actor.GetSpriteIndex('CHAV') && (mf == 6 || mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 13 || mf == 14));
			}
			gl = msq ? "FbxSqzMini" : "FbxTrgMini";
		}
		if (i == 22)	// r9 port: Sniper squeezes on its FIRE frames (X21F / P21F A-C, the gunmoves rows of row 22) or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mf <= 2 && (mgp.Sprite == Actor.GetSpriteIndex('X21F') || mgp.Sprite == Actor.GetSpriteIndex('P21F')));
			}
			gl = msq ? "FbxSqzSni" : "FbxTrgSni";
		}
		if (i == 11)	// r10 port: MG42 squeezes on its fire frames: HBUS BCF, PBUS BCF or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('HBUS') && (mf == 1 || mf == 2 || mf == 5)) || (mgp.Sprite == Actor.GetSpriteIndex('PBUS') && (mf == 1 || mf == 2 || mf == 5));
			}
			gl = msq ? "FbxSqzMG42" : "FbxTrgMG42";
		}
		if (i == 27)	// r10 port: Machinegun squeezes on its fire frames: MGN1 BCDEFK or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('MGN1') && (mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 10));
			}
			gl = msq ? "FbxSqzMGun" : "FbxTrgMGun";
		}
		if (i == 14)	// r10 port: NukeLauncher squeezes on its fire frames: NKLF ABCDEFGHIJ or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('NKLF') && (mf == 0 || mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7 || mf == 8 || mf == 9));
			}
			gl = msq ? "FbxSqzNuke" : "FbxTrgNuke";
		}
		if (i == 2)	// r10 port: BFG10k squeezes on its fire frames: BG2G MNOPQR or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('BG2G') && (mf == 12 || mf == 13 || mf == 14 || mf == 15 || mf == 16 || mf == 17));
			}
			gl = msq ? "FbxSqzBFGk" : "FbxTrgBFGk";
		}
		if (i == 3)	// r11 port: BIG_FUCKING_GUN squeezes on its fire frames: BFGA ABCDEF or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('BFGA') && (mf == 0 || mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5));
			}
			gl = msq ? "FbxSqzBFG9" : "FbxTrgBFG9";
		}
		if (i == 10)	// r11 port: IncendiaryLauncher squeezes on its fire frames: M202 B or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('M202') && (mf == 1));
			}
			gl = msq ? "FbxSqzInc" : "FbxTrgInc";
		}
		if (i == 6)	// r11 port: Devastator squeezes on its fire frames: DEVA BCDEFGHJKLMNOP or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('DEVA') && (mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 13 || mf == 14 || mf == 15));
			}
			gl = msq ? "FbxSqzDeva" : "FbxTrgDeva";
		}
		if (i == 20)	// r11 port: SSG squeezes on its fire frames: SHT2 BCDEFGHIJ, VSSG BCDEFGHIJ or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('SHT2') && (mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7 || mf == 8 || mf == 9)) || (mgp.Sprite == Actor.GetSpriteIndex('VSSG') && (mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7 || mf == 8 || mf == 9));
			}
			gl = msq ? "FbxSqzSSG" : "FbxTrgSSG";
		}
		if (i == 23)	// r12 port: Unmaker squeezes on its fire frames: 2NHF BCDEFGH, UNHF BCDEFGH or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('2NHF') && (mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7)) || (mgp.Sprite == Actor.GetSpriteIndex('UNHF') && (mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7));
			}
			gl = msq ? "FbxSqzUnm" : "FbxTrgUnm";
		}
		if (i == 9)	// r12 port: HellishMissileLauncher squeezes on its fire frames: PVCG BCDEFHIJKL, RVCG BCDEFHIJKL or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('PVCG') && (mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11)) || (mgp.Sprite == Actor.GetSpriteIndex('RVCG') && (mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11));
			}
			gl = msq ? "FbxSqzHML" : "FbxTrgHML";
		}
		if (i == 25)	// r12 port: Chain_saw squeezes on its fire frames: 1AWF ABCDEFGHIJKLMNOPQRSTUVWXYZ, 1AWG HIJKLMOPQRSTUWXYZ[, 2AWF ABCDEFGHIJKLMNOPQRSTUVWXYZ, 2AWG HIJKLMOPQRSTUWXYZ[, 3AWF ABCDEFGHIJKLMNOPQRSTUVWXYZ, 3AWG HIJKLMOPQRSTUWXYZ[, PAWF ABCDEFGHIJKLMNOPQRSTUVWXYZ, PAWG HIJKLMOPQRSTUW, SAWF ABCDEFGHIJKLMNOPQRSTUVWXYZ, SAWG HIJKLMOPQRSTUWXYZ[ or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('1AWF') && (mf == 0 || mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 13 || mf == 14 || mf == 15 || mf == 16 || mf == 17 || mf == 18 || mf == 19 || mf == 20 || mf == 21 || mf == 22 || mf == 23 || mf == 24 || mf == 25)) || (mgp.Sprite == Actor.GetSpriteIndex('1AWG') && (mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 14 || mf == 15 || mf == 16 || mf == 17 || mf == 18 || mf == 19 || mf == 20 || mf == 22 || mf == 23 || mf == 24 || mf == 25 || mf == 26)) || (mgp.Sprite == Actor.GetSpriteIndex('2AWF') && (mf == 0 || mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 13 || mf == 14 || mf == 15 || mf == 16 || mf == 17 || mf == 18 || mf == 19 || mf == 20 || mf == 21 || mf == 22 || mf == 23 || mf == 24 || mf == 25)) || (mgp.Sprite == Actor.GetSpriteIndex('2AWG') && (mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 14 || mf == 15 || mf == 16 || mf == 17 || mf == 18 || mf == 19 || mf == 20 || mf == 22 || mf == 23 || mf == 24 || mf == 25 || mf == 26)) || (mgp.Sprite == Actor.GetSpriteIndex('3AWF') && (mf == 0 || mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 13 || mf == 14 || mf == 15 || mf == 16 || mf == 17 || mf == 18 || mf == 19 || mf == 20 || mf == 21 || mf == 22 || mf == 23 || mf == 24 || mf == 25)) || (mgp.Sprite == Actor.GetSpriteIndex('3AWG') && (mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 14 || mf == 15 || mf == 16 || mf == 17 || mf == 18 || mf == 19 || mf == 20 || mf == 22 || mf == 23 || mf == 24 || mf == 25 || mf == 26)) || (mgp.Sprite == Actor.GetSpriteIndex('PAWF') && (mf == 0 || mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 13 || mf == 14 || mf == 15 || mf == 16 || mf == 17 || mf == 18 || mf == 19 || mf == 20 || mf == 21 || mf == 22 || mf == 23 || mf == 24 || mf == 25)) || (mgp.Sprite == Actor.GetSpriteIndex('PAWG') && (mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 14 || mf == 15 || mf == 16 || mf == 17 || mf == 18 || mf == 19 || mf == 20 || mf == 22)) || (mgp.Sprite == Actor.GetSpriteIndex('SAWF') && (mf == 0 || mf == 1 || mf == 2 || mf == 3 || mf == 4 || mf == 5 || mf == 6 || mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 13 || mf == 14 || mf == 15 || mf == 16 || mf == 17 || mf == 18 || mf == 19 || mf == 20 || mf == 21 || mf == 22 || mf == 23 || mf == 24 || mf == 25)) || (mgp.Sprite == Actor.GetSpriteIndex('SAWG') && (mf == 7 || mf == 8 || mf == 9 || mf == 10 || mf == 11 || mf == 12 || mf == 14 || mf == 15 || mf == 16 || mf == 17 || mf == 18 || mf == 19 || mf == 20 || mf == 22 || mf == 23 || mf == 24 || mf == 25 || mf == 26));
			}
			gl = msq ? "FbxSqzSaw" : "FbxTrgSaw";
		}
		if (i == 26)	// r12 port: DSweap squeezes on its never (melee: frame 1 is the saw trigger only); fullbright frames only or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || false && false;
			}
			gl = msq ? "FbxSqzDS" : "FbxTrgDS";
		}
		if (i == 24)	// r12 port: BrutalAxe squeezes on its never (melee: frame 1 is the saw trigger only); fullbright frames only or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || false && false;
			}
			gl = msq ? "FbxSqzAxe" : "FbxTrgAxe";
		}
		if (i == 18)	// batch 4: Rifle squeezes on its FIRE frames (gunmoves rows 93-95: RIFF / RI2F / 2IFF A-D and the no-tube twins QT09 / QT0A / QT08) or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mf <= 3 && (mgp.Sprite == Actor.GetSpriteIndex('RIFF') || mgp.Sprite == Actor.GetSpriteIndex('RI2F') || mgp.Sprite == Actor.GetSpriteIndex('2IFF') || mgp.Sprite == Actor.GetSpriteIndex('QT09') || mgp.Sprite == Actor.GetSpriteIndex('QT0A') || mgp.Sprite == Actor.GetSpriteIndex('QT08')));
			}
			gl = msq ? "FbxSqzRif" : "FbxTrgRif";
		}
		if (i == 12)	// batch 3: MP40 squeezes on its FIRE frames (gunmoves rows 42-45: MP40 B D E Q R S, PP40 B D E) or fullbright, trigger otherwise
		{
			bool msq = false;
			let mgp = p.FindPSprite(PSP_WEAPON);
			if (mgp && mgp.CurState)
			{
				int mf = mgp.Frame;
				msq = mgp.CurState.bFullbright || (mgp.Sprite == Actor.GetSpriteIndex('MP40') && (mf == 1 || mf == 3 || mf == 4 || (mf >= 16 && mf <= 18))) || (mgp.Sprite == Actor.GetSpriteIndex('PP40') && (mf == 1 || mf == 3 || mf == 4));
			}
			gl = msq ? "FbxSqzM" : "FbxTrgM";
		}
		if (i == 5)	// batch 2: BrutalSMG squeezes on its FIRE frames (BD22 SMG.dec Fire: SMGF / 2MGF A-C, zoomed SMGZ G-I), trigger otherwise
		{
			bool ssq = false;
			let sgp = p.FindPSprite(PSP_WEAPON);
			if (sgp && sgp.CurState)
			{
				int sf = sgp.Frame;
				ssq = sgp.CurState.bFullbright || ((sgp.Sprite == Actor.GetSpriteIndex('SMGF') || sgp.Sprite == Actor.GetSpriteIndex('2MGF')) && sf <= 2) || (sgp.Sprite == Actor.GetSpriteIndex('SMGZ') && sf >= 6 && sf <= 8);
			}
			gl = ssq ? "FbxSqzS" : "FbxTrgS";
		}
		invoker.SetLayer(p, RSQ_Layers.GUNHAND, gs, own != "" ? own : i > 0 && g != "" ? gl : "Hidden");
		String sp = RSQ_HandTable.Support(i);
		if (i == 18 && RSK_M203Handler.TriggerGrip(mo))
			sp = (p.cmd.buttons & BT_OFFHANDATTACK) ? "M2" : "M1";	// 1.31: finger on the M203's trigger (squeezed)
		String spl = (i == 4 || i == 7) ? (i == 4 ? "FbxSupP" : "FbxSupF") : "Sup" .. sp;	// BD 2.0 b1: the FBX support hands
		if (i == 20)
			spl = "FbxWrapSSG";	// support192 batch 1: SSG, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 20 = 0: baked in place)
		if (i == 6)
			spl = "FbxWrapDevastator";	// support192 batch 2: Devastator, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 6 = 0: baked in place)
		if (i == 10)
			spl = "FbxWrapInc";	// support192 batch 2: IncendiaryLauncher, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 10 = 0: baked in place)
		if (i == 3)
			spl = "FbxWrapBFG9";	// support192 batch 5: BIG_FUCKING_GUN, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 3 = 0: baked in place)
		if (i == 2)
			spl = "FbxWrapBFG10k";	// support192 batch 5: BFG10k, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 2 = 0: baked in place)
		if (i == 14)
			spl = "FbxWrapNukeLauncher";	// support192 batch 5: NukeLauncher, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 14 = 0: baked in place)
		if (i == 27)
			spl = "FbxWrapMachinegun";	// support192 batch 3: Machinegun, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 27 = 0: baked in place)
		if (i == 11)
			spl = "FbxWrapMG42";	// support192 batch 4: MG42, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 11 = 0: baked in place)
		if (i == 22)
			spl = "FbxWrapSniper";	// support192 batch 4: Sniper, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 22 = 0: baked in place)
		if (i == 15)
			spl = "FbxWrapPlasmaGun";	// support192 batch 3: Plasma_Gun, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 15 = 0: baked in place)
		if (i == 16)
			spl = "FbxWrapRailGun";	// support192 batch 3: RailGun, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 16 = 0: baked in place)
		if (i == 19)
			spl = "FbxWrapRL";	// support192 batch 3: Rocket_Launcher, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 19 = 0: baked in place)
		if (i == 8)
			spl = "FbxWrapGL";	// support192 batch 2: GrenadeLauncher, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 8 = 0: baked in place)
		if (i == 21)
			spl = "FbxWrapShotGun";	// support192 batch 1: Shot_Gun, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 21 = 0: baked in place)
		if (i == 17)
			spl = "FbxSupP";	// batch 5: Revolver, Revolver2 and BrutalRevolver (shared row), the FBX cup under the gun hand (handtable SupportHook / SupportRot row 17)
		if (i == 18)
			spl = "FbxWrapRifle";	// support192 batch 1: Rifle, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 18 = 0: baked in place)
		if (i == 1)
			spl = "FbxWrapAS";	// support192 batch 1: AssaultShotgun, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 1 = 0: baked in place)
		if (i == 12)
			spl = "FbxSupF";	// batch 3: MP40, the FBX open palm under its barrel (handtable SupportHook / SupportRot row 12)
		if (i == 5)
			spl = "FbxSupF";	// batch 2: BrutalSMG, the FBX open palm under its forend (handtable SupportHook / SupportRot row 5)
		if (i == 13)
			spl = "FbxSupMini";	// r12 port: Minigun, the FBX fist round the side handle (hands r4 support_r4_bar_ref: pen 0.09, wrap I/M/R/P 188/202/198/183 deg; replaces Ermac's pose E; owner-approved 2026-10-28) (handtable SupportHook / SupportRot row 13)
		if (i == 28)
			spl = "FbxSupFC";	// r12 port: FlameCannon, the FBX open palm cupped under the barrel 38 cm from the slit (hands r4 FlameCannon_under40: pen 0.33, palm gap 0.30; owner-approved 2026-10-28) (handtable SupportHook / SupportRot row 28)
		if (i == 25)
			spl = "FbxSupSaw";	// r12 port: Chain_saw, the FBX L hand on the top handle (melee lane support_top: R fit on the mirrored saw, mirrored back; pen 0.39; owner-approved 2026-10-27) (handtable SupportHook / SupportRot row 25)
		if (i == 26)
			spl = "FbxSupDS";	// r12 port: DSweap, the FBX L hand on the hilt below the gun hand (melee lane: the gun hand mirrored, slid 12.5 cm down the handle; pen 0.44; owner-approved 2026-10-27) (handtable SupportHook / SupportRot row 26)
		if (i == 23)
			spl = "FbxWrapUnmaker";	// support192 batch 5: Unmaker, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 23 = 0: baked in place)
		if (i == 9)
			spl = "FbxWrapHML";	// support192 batch 6: HellishMissileLauncher, the FBX support hand fitted from the 1.92 hold (handtable SupportHook / SupportRot row 9 = 0: baked in place)
		if (i == 24)
			spl = "FbxWrapBrutalAxe";	// support192 batch 6: BrutalAxe, the FBX L fist on the haft 1 cm below the two-handed gun hand (seed: the FBX gun hand mirrored, axe192.py; the axe has no 1.92 support hold) (handtable SupportHook / SupportRot row 24 = 0: baked in place)
		invoker.SetLayer(p, RSQ_Layers.SUPPORT, gs, (hold || swordTwo) && sp != "" ? spl : "Hidden");	// r12 port: the two-handed sword shows its FBX support on the hilt

		// 2026-10-23: the VR scope's reticle (rsq/scope.zs). WHETHER the layer is there is this
		// tic's business; WHERE it sits is ModifyBobLayer3D's, per rendered frame. It exists
		// only while the ready weapon has a row in RSQ_ScopeTable, that gun's own mode cvar says
		// DOT, and we are in VR -- out of VR there is nothing to collimate against and no layer.
		// A gun with a scope needs a table row and a cvar and nothing here.
		int sci = RSVR_VRHand.InVR(mo) ? RSQ_ScopeTable.Index(p.ReadyWeapon) : 0;
		if (sci > 0)	// this pack: the real scope always, never the dot
			sci = 0;		// REAL mode: the glass is rendered into (rsq/scope_real.zs), no reticle
		// The reticle originally took 2102, which is RSR.WELLMAG (rsr/vreload.zs) -- the
		// magazine at the well, on exactly the two guns that have scopes (RSR_Guns.Index:
		// RailGun 6, Sniper 8). One psprite id holds one caller, so that would have killed
		// reloading on both guns with nothing in the log. DOT is 2112 now and this guard is
		// quiet; it stays as the general safeguard for the next lane that claims an id.
		if (RSQ_Layers.Taken(RSQ_ScopeLayers.RETICLE))
		{
			if (!invoker.dotClash)
			{
				invoker.dotClash = true;
				Console.Printf("RSQ scope: reticle layer %d is already a reload layer; the dot is off until RSQ_ScopeLayers.RETICLE (rsq/scope.zs) moves to a free id (2112-2119, 2124-2129).", RSQ_ScopeLayers.RETICLE);
			}
		}
		else
			invoker.SetLayer(p, RSQ_ScopeLayers.RETICLE, gs, sci > 0 ? "ScopeDot" : "Hidden");
	}

	// "Fist" while the gun layer shows one of BD22's punch / fist sprites (the fists, and a quick
	// punch on any gun); "Nade" while it shows the VR grenade (RQNP: Grenades.dec RSG_ states)
	String OwnHand(PlayerInfo p)
	{
		let g = p.FindPSprite(PSP_WEAPON);
		if (!g || !g.CurState)
			return "";
		if (fistSprites.Size() == 0)
		{
			static const Name fs[] = { '1ONG', '2ONG', '3ONG', '4ONG', '5ONG', 'PONG', '1UNG', '2UNG', '3UNG', '4UNG', '5UNG', 'PUNG',
				'1IST', '3IST', '5IST', 'FIST', '22ST', 'PUNS' };
			for (int k = 0; k < fs.Size(); k++)
				fistSprites.Push(GetSpriteIndex(fs[k]));
			nadeSprite = GetSpriteIndex('RQNP');
			static const Name hs[] = { '1HRG', '2HRG', '3HRG', 'THRG', '1HRW', '2HRW', '3HRW', '5HRW', 'THRW', '1KUP', '2KUP', '3KUP', 'PKUP',
				'1UCK', '2UCK', '3UCK', '4UCK', 'FUCK', 'VUCK', 'SALU', 'GRZ1', 'GRZ2', 'GRZ3', 'GRZ4', 'GRZ5', 'GRZ6', 'GRZ7',
				'PTG1', 'PTG2', 'PTG3', 'THEA', 'IEHW' };
			for (int k = 0; k < hs.Size(); k++)
				bdHandSprites.Push(GetSpriteIndex(hs[k]));
			static const Name on[] = { '1ONG', '2ONG', '3ONG', '4ONG', '5ONG', 'PONG' };
			for (int k = 0; k < on.Size(); k++)
				ongSprites.Push(GetSpriteIndex(on[k]));
			static const Name un[] = { '1UNG', '2UNG', '3UNG', '4UNG', '5UNG', 'PUNG' };
			for (int k = 0; k < un.Size(); k++)
				ungSprites.Push(GetSpriteIndex(un[k]));
			unsSprite = GetSpriteIndex('PUNS');
		}
		int s = g.Sprite;
		if (s == nadeSprite)
			return "Nade";
		if (fistSprites.Find(s) < fistSprites.Size())
			return "Fist";
		// the fists themselves: fists whenever BD22's own hand isn't showing something else
		// (a taunt, a grab, a carried barrel, a pickup, a throw, a fatality)
		let w = p.ReadyWeapon;
		if (w && RSQ_Alias.Exact(w) == 'Melee_Attacks' && bdHandSprites.Find(s) >= bdHandSprites.Size())
			return "Fist";
		return "";
	}

	// the BD22 punch frame the main gun layer shows, as a fistclosed.md3 frame (RSQ_FistMoves)
	int FistFrame(PlayerInfo p)
	{
		let g = p.FindPSprite(PSP_WEAPON);
		if (!g || !g.CurState)
			return 0;
		int s = g.Sprite;
		int fam = ongSprites.Find(s) < ongSprites.Size() ? 1 : ungSprites.Find(s) < ungSprites.Size() ? 2 : s == unsSprite ? 3 : 0;
		return RSQ_FistMoves.MeshFrame(fam, g.Frame);
	}

	// 1.5 (owner): the OFF-hand trigger throws BD22's jab from the off fist, with BD's jab motion:
	// PONG B C D, E E E, F, G H (BD22 Melee.dec Jab + FinishJab), the blow landing on D. Only when
	// the off hand is a free fist and the main hand holds no gun (fists, axe, chainsaw, sword):
	// with a gun out, the off trigger is the reload grab and must not punch.
	void OffPunch(PlayerPawn mo)
	{
		static const int seq[] = { 1, 2, 3, 4, 4, 4, 5, 7, 8 };
		let p = mo.player;
		bool trig = (p.cmd.buttons & BT_OFFHANDATTACK) != 0;
		bool press = trig && !offTrigPrev;
		offTrigPrev = trig;
		offMeshPrev = offMesh;
		if (offPunchTic < 0 || offPunchTic >= seq.Size())
		{
			offPunchTic = -1;
			offMesh = 0;
			// 2026-10-23 (owner: "yes -- that way we can punch open switches n shit"): the off
			// trigger now punches with a GUN in the main hand too. It is also the reload's grab,
			// so POSITION decides instead of the weapon: a hand up at the gun is reaching for
			// ammo, a hand out away from it is a punch. freeFist already rules out the support
			// grip and any reload that has the hand.
			// 1.99x: behind rsq_punch, as the owner decided (2026-10-25: "off-hand punch stays behind
			// rsq_punch, off by default"). It was not: with the option off, an off-trigger press away
			// from the gun still swung (Melee/Swing) and punched -- 1.92 never did that with a gun out.
			// 2.0.3y (owner 11-06: "in bd my hands animate a punch, which isn't good... i just don't need the
			// swinging fist automatically, when i swing it myself"): the off TRIGGER no longer throws the animated
			// jab. The off fist still punches when you swing it (rsq_punch, fists.zs RSQ_FistHand, and RSQ Melee).
			if (true)
				return;
			if (!press || !freeFist || RSQ.PlayerInt(mo, 'rsq_punch', 0) == 0)
				return;
			if (RSVR_VRHand.SteadyGap(mo) < 30.0)	// cm: at the gun, so that press is the reload's
				return;
			offPunchTic = 0;
			mo.A_StartSound("Melee/Swing", CHAN_AUTO, CHANF_OVERLAP);
		}
		offMesh = seq[offPunchTic];
		if (offPunchTic == 2)
		{
			double ps = mo.Level.pixelstretch;
			if (ps <= 0)
				ps = 1.2;
			Vector3 dir = RSVR_VRHand.OffDir(mo, 0, 0, ps);
			Name sn = mo.CountInv('PowerStrength') > 0 ? 'MeleeStrike1Berserked' : 'MeleeStrikeNormal';
			class<Actor> sc = RSQ_Fists.Cls(sn);
			let a = sc ? Actor.Spawn(sc, RSVR_VRHand.OffPos(mo), ALLOW_REPLACE) : null;
			if (a)
			{
				a.target = mo;
				a.angle = VectorAngle(dir.x, dir.y);
				a.pitch = -asin(clamp(dir.z, -1, 1));
				a.vel = dir * 16;
			}
			RSQ_Fists.PunchUse(mo, RSVR_VRHand.OffPos(mo), dir);
		}
		offPunchTic++;
	}

	// a fist's punch move between last tic's frame and this one (BD22's meshes do not blend, but
	// our hands are drawn every display frame, so they glide between tics)
	ui static Vector3, Vector3 FistMove(int prev, int cur, double ticfrac)
	{
		Vector3 t0, m0, t1, m1;
		[t0, m0] = RSQ_FistMoves.Move(prev);
		[t1, m1] = RSQ_FistMoves.Move(cur);
		return t0 + (t1 - t0) * ticfrac, m0 + (m1 - m0) * ticfrac;
	}

	// put a layer on a state only when it changes, so a pose is not
	// restarted every tic
	void SetLayer(PlayerInfo p, int id, Actor caller, String label)
	{
		State want = caller.FindStateByString(label);
		let psp = p.FindPSprite(id);
		if (psp && psp.Caller == caller && psp.CurState == want)
			return;
		p.SetPsprite(id, want, false, caller);
		psp = p.FindPSprite(id);
		if (psp)
		{
			psp.bAddWeapon = false;
			psp.bAddBob = true;
			// a fresh layer has y 0, which tilts a HUD model 8 degrees (hw_weapon.cpp:
			// pitch (y - WEAPONTOP) / -4): every hand layer, the free hand too, sits at WEAPONTOP
			psp.y = WEAPONTOP;
			psp.oldy = WEAPONTOP;
		}
	}

	// Look up how the gun's model frame moves it when the gun layer shows
	// another frame. The gun layer has ticked by now (layers tick in ID order,
	// the off-hand weapon's last), so this is the frame drawn this tic.
	void FollowGun(PlayerInfo p, int i)
	{
		let g = i > 0 ? p.FindPSprite(PSP_WEAPON) : null;
		if (!g || !g.CurState)
		{
			gunState = null;
			gunTurn = gunMove = nextTurn = nextMove = (0, 0, 0);
			return;
		}
		int spr = g.Sprite;
		if (g.CurState == gunState && spr == gunSprite && g.Frame == gunFrame)
			return;
		gunState = g.CurState;
		gunSprite = spr;
		gunFrame = g.Frame;
		Vector3 t, m;
		[t, m] = RSQ_GunMoves.Frame(i, spr, g.Frame);
		gunTurn = nextTurn = t;
		gunMove = nextMove = m;
		// The engine blends a model toward the next state's frame, unless that
		// state keeps the layer's sprite ("####": sprite index 1 or 2), which it
		// cannot look up.
		let n = gunState.NextState;
		if (RSQ_GunMoves.Blends(i) && n && n != gunState && n.sprite > 2)
		{
			[t, m] = RSQ_GunMoves.Frame(i, n.sprite, n.Frame);
			nextTurn = t;
			nextMove = m;
		}
	}

	// a layer's offset as the renderer draws it this frame (hw_weapon.cpp BobWeapon3D)
	ui static Vector2 LayerOffset(PSprite s, double ticfrac)
	{
		if (s.firstTic)
			return (s.x, s.y);
		return (s.oldx + (s.x - s.oldx) * ticfrac, s.oldy + (s.y - s.oldy) * ticfrac);
	}

	// Where the gun-side hands sit for the gun in hand (ui scope, inherited).
	// The incoming translation is the weapon bob every layer gets; the hook is
	// added to it. The free hand keeps Ermac's own placement on its controller.
	override Vector3, Vector3 ModifyBobLayer3D(Vector3 translation, Vector3 rotation, int layer, double ticfrac)
	{
		// 2026-10-23: THE VR SCOPE'S COLLIMATED DOT (rsq/scope.zs). It is placed here, per
		// rendered FRAME, and not from a tic hook, because holding still against the world while
		// the head moves is the entire point of it: a dot sampled at tic rate visibly lags.
		// This case is FIRST because the RSR reload branch below claims a range of layer ids.
		//
		// UNITS. DotAt() answers in the weapon controller's frame, centimetres, (forward, left,
		// up). A ModifyBobLayer3D translation is applied by r_data/models.cpp RenderHUDModel
		// AFTER objectToWorldMatrix.scale(xscale, zscale, yscale) and after the renderer's own
		// 0.01 shrink of the controller frame -- so one unit is one centimetre divided by that
		// layer's own MODELDEF scale, on the model axes (x left, y up, z back):
		//     (x, y, z) = (L / xscale, U / zscale, -F / yscale)
		// The reticle's quad is Scale -1.0 1.0 1.0, the same as the hand meshes, so every
		// divisor is 1 and the conversion is just (L, U, -F). Corroborated by the pack's own
		// rsr/vreload.zs DeskShift, which turns F,L,U cm into exactly
		// (-c.y / scale.x, c.z / scale.z, -c.x / scale.y) -- same mapping, same divisors, and
		// RSR_Guns.WellHook reproduces (L, U, -F) of each gun's magazine axis to three decimals.
		// (the Taken() test is the same stand-down as in A_RSQ_Layers: while the id belongs to
		// another lane this case must not shadow that lane's branch below)
		if (layer == RSQ_ScopeLayers.RETICLE && !RSQ_Layers.Taken(RSQ_ScopeLayers.RETICLE))
		{
			let mo = PlayerPawn(Owner);
			let so = mo ? mo.player : null;
			int si = so ? RSQ_ScopeTable.Index(so.ReadyWeapon) : 0;
			if (si <= 0)
				return translation, rotation;
			Vector3 d;
			bool ok;
			[d, ok] = RSQ_Scope.DotAt(mo, si);
			// No sight picture (the eye is off the glass, or behind the objective end). The
			// layer's STATE is the honest way to hide it, but a state is play data and this hook
			// is ui and returns a translation and nothing else, so the quad is thrown far enough
			// away to clip instead -- ten kilometres behind the controller, which in practice is
			// behind the near plane. A_RSQ_Layers above does the tic-rate hiding it can.
			if (!ok)
				return translation + (0, 0, DOT_FARAWAY), rotation;
			return translation + (d.y, d.z, -d.x), rotation;
		}
		// RSR-BREAK: the break-open / revolver reload's layers (rsr/rsr_break.zs)
		if (RSB_Handler.Owns(Owner, layer))
		{
			Vector3 bt, br;
			[bt, br] = RSB_Handler.Place(Owner, translation, rotation, layer, ticfrac);
			return bt, br;
		}
		// 1.30 RSR-M203: the rifle launcher's tube and round (rsr/rsr_m203.zs)
		if (RSK_M203Handler.Places(Owner, layer))
		{
			Vector3 mt, mr;
			[mt, mr] = RSK_M203Handler.Place(Owner, translation, rotation, layer, ticfrac);
			return mt, mr;
		}
		// RSR-PUMP: the pump shotguns' layers (rsr/rsr_pump.zs)
		if (RSP_Handler.Places(Owner, layer))
		{
			Vector3 pt, pr;
			[pt, pr] = RSP_Handler.Place(Owner, translation, rotation, layer, ticfrac);
			return pt, pr;
		}
		// the real reload's layers (rsr/vreload.zs)
		if (layer >= RSR.LAYER_FIRST && layer <= RSR.LAYER_LAST || layer == RSR.HANDMAG || layer == RSQ_Layers.FREEHAND)
		{
			Vector3 t, r;
			[t, r] = RSR_ReloadHandler.Place(Owner, translation, rotation, layer, ticfrac);
			if (layer != RSQ_Layers.FREEHAND)
				return t, r;
			translation = t;
			rotation = r;
			if (offMesh > 0 || offMeshPrev > 0)	// 1.5: the off-hand trigger punch
			{
				Vector3 ft, fm;
				[ft, fm] = FistMove(offMeshPrev, offMesh, ticfrac);
				return translation + fm, rotation + ft;
			}
		}
		if (layer == RSQ_Layers.GUNHAND && showOwn && (fistMesh > 0 || fistMeshPrev > 0))
		{
			Vector3 ft, fm;
			[ft, fm] = FistMove(fistMeshPrev, fistMesh, ticfrac);
			return translation + fm, rotation + ft;
		}
		if (layer != RSQ_Layers.GUNHAND && layer != RSQ_Layers.SUPPORT || showOwn)
			return translation, rotation;
		let o = Owner ? Owner.player : null;
		int i = o ? RSQ_HandTable.Index(o.ReadyWeapon) : 0;
		if (i <= 0)
			return translation, rotation;
		bool gunHand = layer == RSQ_Layers.GUNHAND;
		// 2026-10-23: a weapon may be gripped somewhere else in two hands. GunHookTwo
		// defaults to GunHook for every gun, so only the axe moves.
		bool two = Owner && Owner.CountInv('RSVR_AxeTwo') > 0;
		Vector3 hook = gunHand ? (two ? RSQ_HandTable.GunHookTwo(i) : RSQ_HandTable.GunHook(i))
			: RSQ_HandTable.SupportHook(i);
		Vector3 hookTurn = gunHand ? (two ? RSQ_HandTable.GunRotTwo(i) : RSQ_HandTable.GunRot(i))
			: RSQ_HandTable.SupportRot(i);
		if (!gunHand && i == 18 && RSK_M203Handler.TriggerGrip(Owner))
		{
			hook = (0, 0, 0);		// 1.31: the trigger grip is baked in place (MODELDEF.rsm RQ2S)
			hookTurn = (0, 0, 0);
		}

		// The renderer turns every HUD model by its own layer's offset: yaw x / 4,
		// pitch (y - WEAPONTOP) / -4 (hw_weapon.cpp, RenderHUDModel's call). The gun
		// layer is at y = 32 when ready and moves when it is raised, lowered or
		// kicked by Offset; ours stay at 0, which on its own tipped the hands 8
		// degrees up off the gun (the support hand into the shotguns' barrels). So
		// the hands take the gun layer's turn instead of their own, about the point
		// the gun model turns on. A gun model mirrored against the hands turns the
		// other way sideways.
		PSprite gp, hp;
		for (let s = o.psprites; s; s = s.Next)
		{
			if (s.ID == PSP_WEAPON)
				gp = s;
			else if (s.ID == layer)
				hp = s;
		}
		Vector2 g = gp ? LayerOffset(gp, ticfrac) : (0, WEAPONTOP);
		Vector2 h = hp ? LayerOffset(hp, ticfrac) : (0, 0);
		Vector3 gunTurnNow = (g.x / 4, (g.y - WEAPONTOP) / -4, 0);
		if (RSQ_GunMoves.Mirrored(i))
			gunTurnNow.x = -gunTurnNow.x;

		// The gun's model frame (the recoil is in the meshes), blended toward the
		// next state's frame the way the engine blends the model
		// (models.cpp CalcModelFrame).
		Vector3 frameTurn = gunTurn;
		Vector3 frameMove = gunMove;
		if (gp && gunState && gp.CurState == gunState && gunState.Tics > 0 && gp.Tics <= gunState.Tics)
		{
			double inter = (gunState.Tics - gp.Tics + ticfrac) / gunState.Tics;
			frameTurn += (nextTurn - gunTurn) * inter;
			frameMove += (nextMove - gunMove) * inter;
		}

		if (!gunHand)
		{
			frameMove += RSP_Handler.SupportShift(Owner, ticfrac);	// RSR-PUMP: the support hand rides the pump
			frameMove += RSK_M203Handler.SupportShift(Owner, ticfrac);	// 1.30 RSR-M203: ...and the launcher's tube
		}
		Vector3 t, r;
		[t, r] = RSQ_Turn.Place(hook, hookTurn, gunTurnNow, frameTurn, frameMove, RSQ_GunMoves.Pivot(i));
		if (i == 26 && Owner.CountInv('RSVR_SwordTwo') > 0)	// r12 port: the support hand (FBX L on the hilt) takes the same turn as the gun hand and the sword
		{
			// r6b: the two-handed sword block (MODELDEF.bd.txt DSL2) turns the mesh 110 deg
			// (forward toward up) about the grip, (0, 5, -6) in this layer's space: the sword's
			// grip md3 (30/ws, 0, 0) -> (0, -5, -30) after its ZOffset and the jDoom turn, less
			// the hands' Offset (0, -10, -24). The gun hand takes the same turn about that point.
			Vector3 k0, k1, k2, r0, r1, r2, n0, n1, n2;
			[k0, k1, k2] = RSQ_Turn.Rows((0, 110, 0));
			[r0, r1, r2] = RSQ_Turn.Rows(r);
			[n0, n1, n2] = RSQ_Turn.Mul(k0, k1, k2, r0, r1, r2);
			Vector3 piv = (0, 5, -6);
			Vector3 kp = (k0 dot piv, k1 dot piv, k2 dot piv);
			t += RSQ_Turn.Back(n0, n1, n2, piv - kp);
			r = RSQ_Turn.Angles(n0, n1, n2);
		}
		// the renderer still adds this layer's own turn on top: take it back out
		return translation + t, rotation + r - (h.x / 4, (h.y - WEAPONTOP) / -4, 0);
	}

	States
	{
	Ready:
		TNT1 A 1
		{
			A_RSQ_Layers();
			A_WeaponReady(WRF_NOFIRE | WRF_NOBOB);
		}
		Loop;
	Deselect:
		TNT1 A 1 A_Lower(64);
		Loop;
	Select:
		TNT1 A 1 A_Raise(64);
		Loop;
	Fire:
		TNT1 A 1;
		Goto Ready;

	// the free hand (MODELDEF.rsq): open, or a fist
	FreeHand: RQHN A -1; Stop;
	AmmoH: RQHN H -1; Stop;		// a closed hand
	RspShell: RQUN A -1; Stop;	// RSR-PUMP: the FBX hand round the gun's own shell (RQUN A = RQHF X; was Ermac's ammo_hand 1)
	RsrHold: RQHN I -1; Stop;	// real reload: was Ermac's hold (ammo_hand 3); now RQHF A, no shipped gun uses it (vreload HoldState: OhHold<letter>)
	RsrHoldPod: RQHN M -1; Stop;	// was Ermac's BFG pod hold (ammo_hand 6); now RQHF O, unused (OhHold<letter>)
	RsbShell: RQHN J -1; Stop;	// RSR-BREAK: was Ermac's one-shell hold; now RQHF S, unused (rsb HoldState: OhHold<letter>)
	RsbCell: RQHN L -1; Stop;	// RSR-BREAK: was Ermac's cell hold; now RQHF V, unused (OhHold<letter>)
	RsgRing: RQHR A -1; Stop;
	// off-hand FBX lane (2026-10-28): each reload hold's own FBX frame (MODELDEF.rsq RQHF; vreload / rsb HoldState)
	OhHoldA: RQHF A -1; Stop;	// rsr01_Rifle
	OhHoldB: RQHF B -1; Stop;	// rsr02_BrutalPistol
	OhHoldC: RQHF C -1; Stop;	// rsr03_BrutalSMG
	OhHoldD: RQHF D -1; Stop;	// rsr04_MP40
	OhHoldE: RQHF E -1; Stop;	// rsr05_AssaultShotgun
	OhHoldF: RQHF F -1; Stop;	// rsr06_RailGun
	OhHoldG: RQHF G -1; Stop;	// rsr07_Plasma_Gun
	OhHoldH: RQHF H -1; Stop;	// rsr08_Sniper
	OhHoldI: RQHF I -1; Stop;	// rsr09_Rocket_Launcher
	OhHoldJ: RQHF J -1; Stop;	// rsr10_MG42
	OhHoldK: RQHF K -1; Stop;	// rsr11_Flamethrower2
	OhHoldL: RQHF L -1; Stop;	// rsr12_IncendiaryLauncher
	OhHoldM: RQHF M -1; Stop;	// rsr13_Unmaker
	OhHoldN: RQHF N -1; Stop;	// rsr14_Devastator
	OhHoldO: RQHF O -1; Stop;	// rsr15_NukeLauncher
	OhHoldP: RQHF P -1; Stop;	// rsr16_HellishMissileLauncher
	OhHoldQ: RQHF Q -1; Stop;	// rsr17_Minigun
	OhHoldR: RQHF R -1; Stop;	// rsr18_Machinegun
	OhHoldS: RQHF S -1; Stop;	// rsb01_SSG
	OhHoldT: RQHF T -1; Stop;	// rsb02_GrenadeLauncher
	OhHoldU: RQHF U -1; Stop;	// rsb03_Revolver
	OhHoldV: RQHF V -1; Stop;	// rsb10_BrutalRevolver
	OhHoldW: RQHF W -1; Stop;	// rsb11_BrutalRevolver_round
	OhHoldX: RQHF X -1; Stop;	// rsp01_Shot_Gun
	OhHoldY: RQHF Y -1; Stop;	// rsm_M203_round
	RsmRound: RQ2H A -1; Stop;	// 1.30 RSR-M203: the FBX hand round a 40 mm round (RQ2H A = RQHF Y + the round; was Ermac's ammo_hand 5)
	RsmGrip: RQ2H B -1; Stop;	// ...the same grip, the round on the gun
	// dual wield (rsq/dualhands.zs): the gun hand as a layer CALLED BY A GUN must use weapon
	// states (an inventory item's states are refused for a weapon caller), so they live here
	DTrgA: RQGT A -1; Stop;
	DSqzA: RQGU A -1; Stop;
	DTrgB: RQGT B -1; Stop;
	DSqzB: RQGU B -1; Stop;
	DTrgC: RQGT C -1; Stop;
	DSqzC: RQGU C -1; Stop;
	DTrgD: RQGT D -1; Stop;
	DSqzD: RQGU D -1; Stop;
	DTrgE: RQGT E -1; Stop;
	DSqzE: RQGU E -1; Stop;
	DTrgF: RQGT F -1; Stop;
	DSqzF: RQGU F -1; Stop;
	DTrgG: RQGT G -1; Stop;
	DSqzG: RQGU G -1; Stop;
	DTrgH: RQGT H -1; Stop;
	DSqzH: RQGU H -1; Stop;
	DTrgI: RQGT I -1; Stop;
	DSqzI: RQGU I -1; Stop;
	DTrgJ: RQGT J -1; Stop;
	DSqzJ: RQGU J -1; Stop;
	DTrgK: RQGT K -1; Stop;
	DSqzK: RQGU K -1; Stop;
	DTrgL: RQGT L -1; Stop;
	DSqzL: RQGU L -1; Stop;
	DTrgM: RQGT M -1; Stop;
	DSqzM: RQGU M -1; Stop;
	DTrgN: RQGT N -1; Stop;
	DSqzN: RQGU N -1; Stop;
	DTrgO: RQGT O -1; Stop;
	DSqzO: RQGU O -1; Stop;
	DTrgP: RQGT P -1; Stop;
	DSqzP: RQGU P -1; Stop;
	DTrgQ: RQGT Q -1; Stop;
	DSqzQ: RQGU Q -1; Stop;
	DFist: RQGF A -1; Stop;	// dual wield: the fists in the main hand
	DNade: RQGN A -1; Stop;	// dual wield: the VR grenade in the main hand
	DGunA: RQGS A -1; Stop;
	DGunB: RQGS B -1; Stop;
	DGunC: RQGS C -1; Stop;
	DGunD: RQGS D -1; Stop;
	DGunE: RQGS E -1; Stop;
	DGunF: RQGS F -1; Stop;
	DGunG: RQGS G -1; Stop;
	DGunH: RQGS H -1; Stop;	// VR grenade: Ermac's one-shell pinch (ammo_hand 1) holding the ring
	DFbxTrgP: RQFG A -1; Stop;	// BD 2.0 b1: dual wield, the FBX hands
	DFbxSqzP: RQFG B -1; Stop;
	DFbxTrgF: RQFG C -1; Stop;
	DFbxSqzF: RQFG D -1; Stop;
	DFbxTrgS: RQFH A -1; Stop;	// batch 2: dual wield, BrutalSMG
	DFbxSqzS: RQFH B -1; Stop;
	DFbxTrgM: RQFI A -1; Stop;	// batch 3: dual wield, MP40
	DFbxSqzM: RQFI B -1; Stop;
	DFbxTrgRif: RQFJ A -1; Stop;	// batch 4: dual wield, Rifle
	DFbxSqzRif: RQFJ B -1; Stop;
	DFbxTrgAS: RQFQ A -1; Stop;	// shotguns: dual wield, AssaultShotgun
	DFbxSqzAS: RQFQ B -1; Stop;
	DFbxTrgRev: RQFK A -1; Stop;	// batch 4: dual wield, Revolver
	DFbxSqzRev: RQFK B -1; Stop;
	DFbxTrgBru: RQFL A -1; Stop;	// batch 4: dual wield, BrutalRevolver
	DFbxSqzBru: RQFL B -1; Stop;
	DFbxTrgSG: RQFP A -1; Stop;	// shotguns: dual wield, Shot_Gun
	DFbxSqzSG: RQFP B -1; Stop;
	DFbxTrgGL: RQV7 A -1; Stop;	// r9 port: dual wield, GrenadeLauncher
	DFbxSqzGL: RQV7 B -1; Stop;
	DFbxTrgRL: RQV6 A -1; Stop;	// r9 port: dual wield, Rocket_Launcher
	DFbxSqzRL: RQV6 B -1; Stop;
	DFbxTrgRail: RQV5 A -1; Stop;	// r9 port: dual wield, RailGun
	DFbxSqzRail: RQV5 B -1; Stop;
	DFbxTrgPlas: RQV4 A -1; Stop;	// r9 port: dual wield, Plasma_Gun
	DFbxSqzPlas: RQV4 B -1; Stop;
	DFbxTrgMini: RQV3 A -1; Stop;	// r9 port: dual wield, Minigun
	DFbxSqzMini: RQV3 B -1; Stop;
	DFbxTrgSni: RQFN A -1; Stop;	// r9 port: dual wield, Sniper
	DFbxSqzSni: RQFN B -1; Stop;
	DFbxTrgMG42: RQV1 A -1; Stop;	// r10 port: dual wield, MG42
	DFbxSqzMG42: RQV1 B -1; Stop;
	DFbxTrgMGun: RQV2 A -1; Stop;	// r10 port: dual wield, Machinegun
	DFbxSqzMGun: RQV2 B -1; Stop;
	DFbxTrgNuke: RQV9 A -1; Stop;	// r10 port: dual wield, NukeLauncher
	DFbxSqzNuke: RQV9 B -1; Stop;
	DFbxTrgBFGk: RQVA A -1; Stop;	// r10 port: dual wield, BFG10k
	DFbxSqzBFGk: RQVA B -1; Stop;
	DFbxTrgBFG9: RQVB A -1; Stop;	// r11 port: dual wield, BIG_FUCKING_GUN
	DFbxSqzBFG9: RQVB B -1; Stop;
	DFbxTrgInc: RQV8 A -1; Stop;	// r11 port: dual wield, IncendiaryLauncher
	DFbxSqzInc: RQV8 B -1; Stop;
	DFbxTrgDeva: RQVC A -1; Stop;	// r11 port: dual wield, Devastator
	DFbxSqzDeva: RQVC B -1; Stop;
	DFbxTrgSSG: RQVD A -1; Stop;	// r11 port: dual wield, SSG
	DFbxSqzSSG: RQVD B -1; Stop;
	DFbxTrgUnm: RQVE A -1; Stop;	// r12 port: dual wield, Unmaker
	DFbxSqzUnm: RQVE B -1; Stop;
	DFbxTrgHML: RQVF A -1; Stop;	// r12 port: dual wield, HellishMissileLauncher
	DFbxSqzHML: RQVF B -1; Stop;
	DFbxTrgSaw: RQVG A -1; Stop;	// r12 port: dual wield, Chain_saw
	DFbxSqzSaw: RQVG B -1; Stop;
	DFbxTrgDS: RQVH A -1; Stop;	// r12 port: dual wield, DSweap
	DFbxSqzDS: RQVH B -1; Stop;
	DFbxTrgAxe: RQVI A -1; Stop;	// r12 port: dual wield, BrutalAxe
	DFbxSqzAxe: RQVI B -1; Stop;
	Hidden: TNT1 A -1; Stop;
	}
}

// Turns the way ModifyBobLayer3D gives them: models.cpp RenderHUDModel turns
// yaw about y, then pitch about x, then roll about z (degrees), in the hand
// models' frame before the MODELDEF scale (x left, y up, z back). A turn is
// kept as the three rows of its matrix.
class RSQ_Turn abstract
{
	clearscope static Vector3, Vector3, Vector3 Rows(Vector3 a)
	{
		double cx = cos(a.x), sx = sin(a.x);
		double cy = cos(a.y), sy = sin(a.y);
		double cz = cos(a.z), sz = sin(a.z);
		return (cx * cz + sx * sy * sz, -cx * sz + sx * sy * cz, sx * cy),
			(cy * sz, cy * cz, -sy),
			(-sx * cz + cx * sy * sz, sx * sz + cx * sy * cz, cx * cy);
	}

	clearscope static Vector3 Angles(Vector3 r0, Vector3 r1, Vector3 r2)
	{
		return (atan2(r0.z, r2.z), asin(clamp(-r1.z, -1., 1.)), atan2(r1.x, r1.y));
	}

	// the rows of a * b
	clearscope static Vector3, Vector3, Vector3 Mul(Vector3 a0, Vector3 a1, Vector3 a2, Vector3 b0, Vector3 b1, Vector3 b2)
	{
		Vector3 c0 = (b0.x, b1.x, b2.x);
		Vector3 c1 = (b0.y, b1.y, b2.y);
		Vector3 c2 = (b0.z, b1.z, b2.z);
		return (a0 dot c0, a0 dot c1, a0 dot c2), (a1 dot c0, a1 dot c1, a1 dot c2), (a2 dot c0, a2 dot c1, a2 dot c2);
	}

	// v turned back (by the transpose)
	clearscope static Vector3 Back(Vector3 r0, Vector3 r1, Vector3 r2, Vector3 v)
	{
		return r0 * v.x + r1 * v.y + r2 * v.z;
	}

	// Where a gun-side hand goes, and how it turns, so that it stays where it
	// holds the gun. hook / hookTurn: its place on the gun at rest (the hand
	// table). gunTurn: the gun layer's turn, about pivot (the gun model's turning
	// point from the hands'). frameTurn / frameMove: how the gun's model frame
	// has moved it off its ready frame. rsq_gunmoves_gen.py checks this against
	// RenderHUDModel's chain.
	clearscope static Vector3, Vector3 Place(Vector3 hook, Vector3 hookTurn, Vector3 gunTurn, Vector3 frameTurn, Vector3 frameMove, Vector3 pivot)
	{
		Vector3 q0, q1, q2, k0, k1, k2, h0, h1, h2, a0, a1, a2, e0, e1, e2;
		[q0, q1, q2] = Rows(gunTurn);
		[k0, k1, k2] = Rows(frameTurn);
		[h0, h1, h2] = Rows(hookTurn);
		[a0, a1, a2] = Mul(q0, q1, q2, k0, k1, k2);
		[e0, e1, e2] = Mul(a0, a1, a2, h0, h1, h2);
		Vector3 v = frameMove + Back(k0, k1, k2, Back(q0, q1, q2, pivot) - pivot);
		return hook + Back(h0, h1, h2, v), Angles(e0, e1, e2);
	}
}
