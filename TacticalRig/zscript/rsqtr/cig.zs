// ERMAC'S CIGARETTE (optional tribute, off by default: rsqtr_cig), the owner's way (2026-10-31):
//
//   1. Grip at the pocket on your left chest (right chest left-handed) with the MAIN hand: the cigarette is in that hand,
//      drawn WITH Brutal Doom VR's hand on the hand's own layer (RSQTR_CigWeapon), and the Zippo is in the off hand
//      (RSQTR_ZippoWeapon). Grip at the pocket again to put it back.
//   2. Bring it to the headset and press FIRE: it stays at your mouth, and the hand has its gun again.
//   3. OFF-HAND FIRE flicks the Zippo open (again: shut). Hold its flame to the tip: it lights.
//   4. OFF-HAND FIRE again: you draw on it, it flares, then you spit it out -- it flies away from your face end over
//      end in an arc, you exhale, and RSQ_SlowMo starts (if loaded; RS_SlowMo's own rsm_pulse, no link needed).
//      The Zippo goes away. The butt still smoulders where it lands and draws monsters, as Ermac's did.
//
// The idea is Ermac's: the cigarette, its butt and its smoke come from his Virtual Tactical Vest for Doom VR (its credits
// name him as their modeller; the cigarette's texture is an atlas shared with a Sketchfab cigarette-pack model, its pack
// art blanked here), and the Zippo is the voxel lighter from his ZBlood-VR, credited to him there. tools/gen_handprops.py
// bakes both into Brutal Doom VR's hand. A pocket holds a few (rsqtr_cig_count), refilled on a new level.
//
// NETPLAY: the hands are the console player's alone, so that machine decides and sends one event per action (take, put
// back, lock at the mouth, flick the Zippo, light, smoke); every machine runs the same steps from them.

class RSQTR_Cig : EventHandler
{
	const POCKET_F = 0.12;
	const POCKET_L = 0.16;
	const POCKET_U = -0.25;
	const POCKET_R = 0.09;
	const MOUTH_R = 0.18;        // metres: the cigarette hand is "at the headset"
	const FLAME_R = 0.14;        // metres: the Zippo hand is "at the tip"
	const DRAW_TICS = 14;        // the draw before the flare
	const FLARE_TICS = 8;        // the flare before you spit it

	const PH_NONE = 0;
	const PH_HAND = 1;           // in the hand
	const PH_MOUTH = 2;          // at the mouth, not lit
	const PH_LIT = 3;            // lit
	const PH_DRAW = 4;           // drawing on it, then the flare, then the spit

	// ---- synced --------------------------------------------------------------------
	int  phase[MAXPLAYERS];
	int  phaseTic[MAXPLAYERS];
	bool zipOpen[MAXPLAYERS];
	int  zipTic[MAXPLAYERS];
	String prevMain[MAXPLAYERS], prevOff[MAXPLAYERS];
	Actor mouthProp[MAXPLAYERS];
	int  spitTic[MAXPLAYERS];    // when the last spit was (the console player's SlowMo starts on it)

	// ---- local (console player) ----------------------------------------------------
	private transient bool pressWas[2], fireWas, offFireWas;
	private transient int flameT, spitSeen;
	private transient Actor pocketMark;

	static RSQTR_Cig Get() { return RSQTR_Cig(EventHandler.Find("RSQTR_Cig")); }

	// The pocket's count lives on the player (RSQTR_CigPack), because an EventHandler is
	// rebuilt on every map and its fields would not carry the count to the next level.
	static int Packs(PlayerPawn pmo) { return pmo ? pmo.CountInv("RSQTR_CigPack") : 0; }

	// No OnRegister on purpose: it also runs when a save is loaded, after the synced
	// fields are read back (p_saveg.cpp), and would wipe them. A level's handlers get
	// no WorldLoaded on a load (events.cpp), so this runs for new levels only.
	override void WorldLoaded(WorldEvent e)
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			phase[i] = PH_NONE; zipOpen[i] = false; mouthProp[i] = null; spitTic[i] = -100;
			if (!playeringame[i] || !players[i].mo) continue;
			let pmo = players[i].mo;
			pmo.TakeInventory("RSQTR_CigWeapon", 999);
			pmo.TakeInventory("RSQTR_ZippoWeapon", 999);
			int count = RSQTR_Rig.Opt("rsqtr_cig_count", players[i], 3);
			let tok = pmo.FindInventory("RSQTR_CigPack");
			if (!tok) pmo.SetInventory("RSQTR_CigPack", count);
			else if (RSQTR_Rig.Flag("rsqtr_cig_refill", players[i], true)) tok.Amount = count;
		}
	}

	// On the left chest for a right-hander and the right chest for a left-hander
	// (RSQTR_Body.LayoutLeft: rsqa_handed, else the engine's), so the main hand reaches across.
	Vector3 Pocket(PlayerPawn pmo)
	{
		double l = RSQTR_Body.LayoutLeft() ? -POCKET_L : POCKET_L;
		let rig = RSQTR_Rig.Get();
		if (rig) return rig.BodyPoint(pmo, POCKET_F, l, POCKET_U);
		RSQTR_Body tmp = new("RSQTR_Body");
		tmp.yaw = pmo.angle; tmp.primed = true;
		return tmp.At(pmo, POCKET_F, l, POCKET_U);
	}

	// Just below the eyes and a little in front, turned with the head.
	static Vector3 Mouth(PlayerPawn pmo)
	{
		Vector3 h = RSQTR_Body.Head(pmo);
		return h + (cos(pmo.angle) * 0.07 * 34, sin(pmo.angle) * 0.07 * 34, -0.08 * 34 / 1.2);
	}
	// The cigarette's burning end at the mouth: 7 cm out along where you look, a little down.
	static Vector3 MouthTip(PlayerPawn pmo)
	{
		return Mouth(pmo) + (cos(pmo.angle) * 0.07 * 34, sin(pmo.angle) * 0.07 * 34, -0.02 * 34 / 1.2);
	}

	// ---- the local loop ----------------------------------------------------------------
	override void WorldTick()
	{
		Steps();

		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.health <= 0) { HideMark(); return; }
		let pmo = p.mo;
		int n = consoleplayer;
		if (!RSQTR_Rig.Flag("rsqtr_cig", p, false)) { HideMark(); return; }
		let rig = RSQTR_Rig.Get();
		Vector3 pocket = Pocket(pmo);
		bool useDown = (p.cmd.buttons & BT_USE) != 0;
		double nearest = 1e9;

		// the pocket: the main hand takes one, or puts it back
		for (int h = 0; h < 2; h++)
		{
			Vector3 hp = RSQTR_Body.Hand(pmo, h);
			bool grip = rig && rig.gripDown[n * 2 + h];
			bool holding = grip || useDown;
			bool press = holding && !pressWas[h];
			pressWas[h] = holding;
			double dp = RSQTR_Body.RoomMetres(hp, pocket);
			nearest = min(nearest, dp);
			if (!press || dp >= POCKET_R || h != 0) continue;
			if (phase[n] == PH_NONE)
			{
				if (Packs(pmo) > 0) EventHandler.SendNetworkEvent("rsqtr_cigtake");
				else RSQTR_Buzzer.Start(pmo, h, 0.2, 3);
			}
			else if (phase[n] == PH_HAND) EventHandler.SendNetworkEvent("rsqtr_cigback");
		}

		// fire: the cigarette at the headset stays at your mouth
		bool fire = (p.cmd.buttons & BT_ATTACK) != 0;
		bool fireEdge = fire && !fireWas;
		fireWas = fire;
		if (fireEdge && phase[n] == PH_HAND && p.ReadyWeapon is "RSQTR_CigWeapon"
			&& RSQTR_Body.RoomMetres(RSQTR_Body.Hand(pmo, 0), Mouth(pmo)) < MOUTH_R)
			EventHandler.SendNetworkEvent("rsqtr_ciglock");

		// off-hand fire: the Zippo open / shut, or (lit) the draw
		bool off = (p.cmd.buttons & BT_OFFHANDATTACK) != 0;
		bool offEdge = off && !offFireWas;
		offFireWas = off;
		if (offEdge && p.OffhandWeapon is "RSQTR_ZippoWeapon")
		{
			if (phase[n] == PH_LIT) EventHandler.SendNetworkEvent("rsqtr_cigsmoke");
			else if (phase[n] != PH_DRAW) EventHandler.SendNetworkEvent("rsqtr_zipflick");
		}

		// the flame on the tip lights it
		if (phase[n] == PH_MOUTH && zipOpen[n] && level.maptime - zipTic[n] > 7 && p.OffhandWeapon is "RSQTR_ZippoWeapon")
		{
			flameT = RSQTR_Body.RoomMetres(RSQTR_Body.Hand(pmo, 1), MouthTip(pmo)) < FLAME_R ? flameT + 1 : 0;
			if (flameT >= 4) { flameT = 0; EventHandler.SendNetworkEvent("rsqtr_ciglight"); }
		}
		else flameT = 0;

		// the spit: RSQ_SlowMo starts with the exhale
		if (spitTic[n] != spitSeen && spitTic[n] == level.maptime)
		{
			spitSeen = spitTic[n];
			if (RSQTR_Rig.Flag("rsqtr_cig_slowmo", p, true))
				EventHandler.SendNetworkEvent("rsm_pulse", int(RSQTR_Rig.Num("rsqtr_cig_secs", p, 6) * 1000), RSQTR_Rig.Opt("rsqtr_cig_depth", p, 25));
		}

		ShowMark(pocket, nearest);
	}

	private void ShowMark(Vector3 at, double nearest)
	{
		let p = players[consoleplayer];
		int mode = RSQTR_Rig.Opt("rsqtr_markers", p, 1);
		bool show = mode == 2 || (mode == 1 && nearest < 0.30);
		if (!show) { HideMark(); return; }
		if (!pocketMark) pocketMark = Actor.Spawn("RSQTR_Marker", at);
		if (!pocketMark) return;
		pocketMark.SetOrigin(at, true);
		pocketMark.bINVISIBLE = false;
		pocketMark.Alpha = nearest < POCKET_R ? 0.9 : 0.35;
		pocketMark.Scale = (POCKET_R * RSQTR_Body.UPM, POCKET_R * RSQTR_Body.UPM);   // the wireframe sphere: radius 1.0
		pocketMark.frame = nearest < POCKET_R ? 1 : 0;
	}
	private void HideMark() { if (pocketMark) pocketMark.bINVISIBLE = true; }

	// ---- every machine ----------------------------------------------------------------
	private void SetPhase(int n, int ph) { phase[n] = ph; phaseTic[n] = level.maptime; }

	// The hands back as they were: the main hand's gun, the off hand's (or Brutal Doom Quest's empty hand).
	private void MainBack(PlayerPawn pmo, int n)
	{
		class<Weapon> wc = prevMain[n];
		let w = wc ? Weapon(pmo.FindInventory(wc)) : null;
		if (!w) w = RSQTR_Rig.EmptyHand(pmo);
		if (w && !(w is "RSQTR_CigWeapon")) pmo.player.PendingWeapon = w;
	}
	private void OffBack(PlayerPawn pmo, int n)
	{
		let rig = RSQTR_Rig.Get();
		String o = prevOff[n];
		class<Weapon> oc = o;
		if (!oc || !pmo.FindInventory(oc)) o = RSQTR_Rig.OffEmptyName(pmo);
		if (rig && o != "") rig.QueueOff(n, o);
		else { pmo.player.SetPsprite(PSP_OFFHANDWEAPON, null); pmo.player.OffhandWeapon = null; }
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (!pmo) return;
		let p = players[n];
		if (e.Name.Left(9) == "rsqtr_cig" || e.Name.Left(9) == "rsqtr_zip")
			if (RSQTR_Rig.Flag("rsqtr_messages", p, false)) Console.Printf("T_CIG %s t%d phase %d", e.Name, level.maptime, phase[n]);

		if (e.Name == "rsqtr_cigtake")
		{
			if (phase[n] != PH_NONE || Packs(pmo) <= 0) return;
			pmo.TakeInventory("RSQTR_CigPack", 1);
			prevMain[n] = p.ReadyWeapon && !(p.ReadyWeapon is "RSQTR_CigWeapon") ? p.ReadyWeapon.GetClassName() : 'None';
			if (prevMain[n] == "None") prevMain[n] = "";
			prevOff[n] = p.OffhandWeapon && !(p.OffhandWeapon is "RSQTR_ZippoWeapon") ? p.OffhandWeapon.GetClassName() : 'None';
			if (prevOff[n] == "None") prevOff[n] = "";
			if (!pmo.FindInventory("RSQTR_CigWeapon")) pmo.GiveInventory("RSQTR_CigWeapon", 1);
			if (!pmo.FindInventory("RSQTR_ZippoWeapon")) pmo.GiveInventory("RSQTR_ZippoWeapon", 1);
			p.PendingWeapon = Weapon(pmo.FindInventory("RSQTR_CigWeapon"));
			let rig = RSQTR_Rig.Get();
			if (rig) rig.QueueOff(n, "RSQTR_ZippoWeapon");
			zipOpen[n] = false;
			SetPhase(n, PH_HAND);
			pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.6);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, 0, 0.3, 3);
		}
		else if (e.Name == "rsqtr_cigback")
		{
			if (phase[n] != PH_HAND) return;
			pmo.GiveInventory("RSQTR_CigPack", 1);
			MainBack(pmo, n); OffBack(pmo, n);
			SetPhase(n, PH_NONE);
			pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.5);
		}
		else if (e.Name == "rsqtr_ciglock")
		{
			if (phase[n] != PH_HAND) return;
			let c = RSQTR_CigProp(Actor.Spawn("RSQTR_CigProp", Mouth(pmo)));
			if (c) { c.holder = pmo; c.atMouth = true; }
			mouthProp[n] = c;
			MainBack(pmo, n);
			SetPhase(n, PH_MOUTH);
			pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.4);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, 0, 0.3, 3);
		}
		else if (e.Name == "rsqtr_zipflick")
		{
			if (!(p.OffhandWeapon is "RSQTR_ZippoWeapon")) return;
			zipOpen[n] = !zipOpen[n];
			zipTic[n] = level.maptime;
			pmo.A_StartSound(zipOpen[n] ? "rsqtr/zipopen" : "rsqtr/zipclose", CHAN_AUTO, 0, 0.8);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, 1, 0.4, 4);
		}
		else if (e.Name == "rsqtr_ciglight")
		{
			if (phase[n] != PH_MOUTH) return;
			let c = RSQTR_CigProp(mouthProp[n]);
			if (c) c.SetLit();
			SetPhase(n, PH_LIT);
			pmo.A_StartSound("rsqtr/ziplight", CHAN_AUTO, 0, 0.6);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, 1, 0.5, 6);
		}
		else if (e.Name == "rsqtr_cigsmoke")
		{
			if (phase[n] != PH_LIT) return;
			SetPhase(n, PH_DRAW);
			pmo.A_StartSound("rsqtr/inhale", CHAN_AUTO, 0, 0.9);
		}
	}

	// The draw, the flare, the spit; and tidying the two hand weapons away once they are out of the hands.
	private void Steps()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) continue;
			let pmo = players[n].mo;
			let p = players[n];
			if (pmo.health <= 0 && phase[n] != PH_NONE)
			{
				if (mouthProp[n]) mouthProp[n].Destroy();
				SetPhase(n, PH_NONE);
			}
			if (phase[n] == PH_DRAW)
			{
				int t = level.maptime - phaseTic[n];
				let c = RSQTR_CigProp(mouthProp[n]);
				if (t == DRAW_TICS && c)
				{
					c.Flare();
					pmo.A_StartSound("rsqtr/ciglight", CHAN_AUTO, 0, 1.0);
				}
				if (t >= DRAW_TICS + FLARE_TICS) Spit(pmo, n);
			}
			// out of the hands: away (never left in a weapon slot)
			if (phase[n] != PH_HAND && p.ReadyWeapon != pmo.FindInventory("RSQTR_CigWeapon") && p.PendingWeapon != pmo.FindInventory("RSQTR_CigWeapon"))
				pmo.TakeInventory("RSQTR_CigWeapon", 999);
			bool zipNeeded = phase[n] == PH_HAND || phase[n] == PH_MOUTH || phase[n] == PH_LIT || phase[n] == PH_DRAW;
			if (!zipNeeded && p.OffhandWeapon != pmo.FindInventory("RSQTR_ZippoWeapon"))
				pmo.TakeInventory("RSQTR_ZippoWeapon", 999);
		}
	}

	// SPIT IT OUT: the butt flies from the mouth away from your face, end over end, on an arc; you exhale and the
	// Zippo goes away. RSQ_SlowMo starts on this tic (WorldTick, the console player).
	private void Spit(PlayerPawn pmo, int n)
	{
		Vector3 from = MouthTip(pmo);
		let b = RSQTR_Butt(Actor.Spawn("RSQTR_Butt", from));
		if (b)
		{
			b.vel = (cos(pmo.angle) * 7, sin(pmo.angle) * 7, 4.5) + pmo.vel;
			b.target = pmo;
			b.smoulder = true;
			b.spin = 24;
		}
		if (mouthProp[n]) mouthProp[n].Destroy();
		mouthProp[n] = null;
		Exhale(pmo);
		pmo.A_StartSound("rsqtr/exhale", CHAN_AUTO, 0, 0.9);
		zipOpen[n] = false;
		pmo.A_StartSound("rsqtr/zipclose", CHAN_AUTO, 0, 0.6);
		OffBack(pmo, n);
		spitTic[n] = level.maptime;
		SetPhase(n, PH_NONE);
		if (RSQTR_Rig.Flag("rsqtr_messages", players[n], false)) Console.Printf("T_CIG spit t%d", level.maptime);
	}

	private void Exhale(PlayerPawn pmo)
	{
		Vector3 m = Mouth(pmo);
		for (int i = 0; i < 8; i++)
		{
			let s = Actor.Spawn("RSQTR_Smoke", m);
			if (s)
			{
				s.vel = (cos(pmo.angle) * (0.5 + i * 0.12), sin(pmo.angle) * (0.5 + i * 0.12), 0.12 + i * 0.02);
				s.Scale *= 2.0;
			}
		}
	}
}

// ---- the cigarette and the Zippo in the hands: weapons on the hand's own layer -------------------------------------
// (MODELDEF: Brutal Doom VR's hand with the prop baked in; tools/gen_handprops.py.) Fire does nothing here: the rig's
// handler reads the buttons and acts (cig.zs RSQTR_Cig), so a press never punches or shoots.
class RSQTR_CigWeapon : Weapon
{
	Default
	{
		Weapon.SelectionOrder 99999;
		Weapon.AmmoUse 0;
		Tag "Cigarette";
		+WEAPON.NOAUTOFIRE +WEAPON.NOALERT +WEAPON.NOAUTOSWITCHTO +WEAPON.CHEATNOTWEAPON +WEAPON.WIMPY_WEAPON
		+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE
	}
	States
	{
	Spawn:
		RTCW A -1;
		Stop;
	Select:
		RTCW A 1 A_Raise(24);
		Loop;
	Deselect:
		RTCW A 1 A_Lower(24);
		Loop;
	Ready:
		RTCW A 1 A_WeaponReady(WRF_NOFIRE);
		Loop;
	Fire:
		Goto Ready;
	}
}

class RSQTR_ZippoWeapon : Weapon
{
	Default
	{
		Weapon.SelectionOrder 99999;
		Weapon.AmmoUse 0;
		Tag "Zippo";
		+WEAPON.OFFHANDWEAPON
		+WEAPON.NOAUTOFIRE +WEAPON.NOALERT +WEAPON.NOAUTOSWITCHTO +WEAPON.CHEATNOTWEAPON +WEAPON.WIMPY_WEAPON
		+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE
	}
	// the lid follows RSQTR_Cig.zipOpen: shut, opening over 6 tics, then the flame
	action state A_ZipReady(int lit)
	{
		A_WeaponReady(WRF_NOFIRE);
		let c = RSQTR_Cig.Get();
		int n = player ? PlayerPawn(self).PlayerNumber() : -1;
		bool open = c && n >= 0 && c.zipOpen[n];
		if (open && !lit) return ResolveState("Open");
		if (!open && lit) return ResolveState("Shut");
		return ResolveState(null);
	}
	States
	{
	Spawn:
		RTZW A -1;
		Stop;
	Select:
		RTZW A 1 A_Raise(24);
		Loop;
	Deselect:
		RTZW A 1 A_Lower(24);
		Loop;
	Ready:
		RTZW A 1 A_ZipReady(0);
		Loop;
	Open:
		RTZW EEFFGG 1;
	Burn:
		RTZW BB 1 Bright A_ZipReady(1);
		RTZW CC 1 Bright A_ZipReady(1);
		RTZW DD 1 Bright A_ZipReady(1);
		Loop;
	Shut:
		RTZW GGFFEE 1;
		Goto Ready;
	Fire:
		Goto Ready;
	}
}

// ---- the things in your hands -------------------------------------------------------------

// Shared: follows one hand of its holder, turned with that hand.
class RSQTR_HandProp : Actor
{
	PlayerPawn holder;
	int hand;

	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		Radius 1; Height 1;
	}

	void Follow(bool upright)
	{
		if (!holder) { Destroy(); return; }
		double yaw = hand == 0 ? holder.AttackAngle : holder.OffhandAngle;
		double pit = hand == 0 ? holder.AttackPitch : holder.OffhandPitch;
		double rol = hand == 0 ? holder.AttackRoll : holder.OffhandRoll;
		Vector3 at = RSQTR_Body.Hand(holder, hand);
		angle = yaw;
		pitch = upright ? 0 : -pit;      // AttackPitch is positive up; an actor's pitch is positive down
		roll = upright ? 0 : rol;
		SetOrigin(at, true);
	}

	// Along the hand: metres forward in the hand's own frame.
	Vector3 AlongHand(double metres)
	{
		double pit = hand == 0 ? holder.AttackPitch : holder.OffhandPitch;
		double c = cos(pit);
		return pos + (cos(angle) * c * metres * 34, sin(angle) * c * metres * 34, sin(pit) * metres * 34 / 1.2);
	}
}

class RSQTR_CigProp : RSQTR_HandProp
{
	bool burning;
	bool atMouth;        // held in the mouth: it follows the head (cig.zs RSQTR_Cig.Mouth), pointing out
	int age;

	// the draw's flare: the ember blazes and throws sparks
	void Flare()
	{
		A_RemoveLight("rsqtr_ember");
		A_AttachLight("rsqtr_ember", DynamicLight.PointLight, "FF7A20", 10, 0, DYNAMICLIGHT.LF_ATTENUATE);
		for (int i = 0; i < 6; i++)
		{
			let s = Actor.Spawn("RSQTR_Smoke", Tip());
			if (s) s.vel = (frandom(-0.2, 0.2), frandom(-0.2, 0.2), frandom(0.2, 0.5));
		}
	}

	// (RSQ_Accessibility's Photosensitive Mode: the ember glows steady, not pulsing)
	void SetLit()
	{
		burning = true; SetStateLabel("Lit");
		if (RSQTR_A11y.Photo()) A_AttachLight("rsqtr_ember", DynamicLight.PointLight, "FF6020", 3, 0, DYNAMICLIGHT.LF_ATTENUATE);
		else A_AttachLight("rsqtr_ember", DynamicLight.PulseLight, "FF6020", 2, 4, DYNAMICLIGHT.LF_ATTENUATE, (0, 0, 0), 0.4);
	}

	// The burning end: Ermac's mesh runs 9.5 units along X; at scale 0.3, ~1.7 forward.
	Vector3 Tip() { return !holder ? pos : (atMouth ? RSQTR_Cig.MouthTip(holder) : AlongHand(0.05)); }

	override void Tick()
	{
		if (atMouth)
		{
			if (!holder) { Destroy(); return; }
			angle = holder.angle;
			pitch = 8;            // a little down from level, as a cigarette hangs from the lips
			roll = 0;
			SetOrigin(RSQTR_Cig.Mouth(holder), true);
		}
		else Follow(false);
		if (bDestroyed) return;
		Super.Tick();
		if (burning && ++age % 4 == 0)
		{
			let s = Actor.Spawn("RSQTR_Smoke", Tip());
			if (s) s.vel = (frandom(-0.05, 0.05), frandom(-0.05, 0.05), frandom(0.15, 0.35));
		}
	}

	States
	{
	Spawn:
		RSCG A -1;
		Stop;
	Lit:
		RSCG B -1 Bright;
		Stop;
	}
}

class RSQTR_ZippoProp : RSQTR_HandProp
{
	int age;

	// The lid opens over 6 tics, then the flame takes.
	bool Burning() { return age > 7; }
	// The flame sits ~12 units up the mesh (measured: 10.6-14.1); MODELDEF scales it
	// by 0.17, so ~2 map units over the hand.
	const FLAME_UP = 12.0 * 0.17;
	Vector3 Flame() { return pos + (0, 0, FLAME_UP); }

	override void Tick()
	{
		Follow(true);
		if (bDestroyed) return;
		Super.Tick();
		age++;
		if (age == 7)
		{
			A_StartSound("rsqtr/ziplight", CHAN_AUTO, 0, 0.8);
			// RSQ_Accessibility's Photosensitive Mode: a steady flame, not a random flicker
			if (RSQTR_A11y.Photo()) A_AttachLight("rsqtr_zippo", DynamicLight.PointLight, "FFF4A1", 8, 0, DYNAMICLIGHT.LF_ATTENUATE, (0, 0, 2));
			else A_AttachLight("rsqtr_zippo", DynamicLight.RandomFlickerLight, "FFF4A1", 7, 10, DYNAMICLIGHT.LF_ATTENUATE, (0, 0, 2));
		}
	}

	States
	{
	Spawn:
		RSZP A 1;
		RSZP EEFFGG 1;
	Burn:
		RSZP BBCCDD 1 Bright;
		Loop;
	}
}

// ---- the butt, Ermac's: it bounces, then smoulders and draws monsters ---------------------
class RSQTR_Butt : Actor
{
	bool smoulder;
	double spin;         // degrees a tic end over end while it flies (the spit)

	Default
	{
		Projectile;
		-NOGRAVITY
		+BOUNCEONFLOORS +BOUNCEONWALLS +BOUNCEONCEILINGS
		+NOTELEPORT +THRUSPECIES +DONTSPLASH
		Radius 2; Height 1;
		Speed 0; Damage 0;
		BounceFactor 0.5; WallBounceFactor 0.25; BounceType "Doom";
		Gravity 0.5;
	}

	override int SpecialMissileHit(Actor victim) { return 1; }   // it flies through creatures

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (spin != 0) pitch += spin;
		if (smoulder && level.maptime % 3 == 0)
		{
			let s = Actor.Spawn("RSQTR_Smoke", pos);
			if (s) s.vel = (0, 0, frandom(0.1, 0.3));
		}
	}

	States
	{
	Spawn:
		RSCB A -1;
		Stop;
	Death:
		TNT1 A 0 { if (smoulder) Spawn("RSQTR_ButtLying", pos); }
		Stop;
	}
}

class RSQTR_ButtLying : Actor
{
	int countdown;

	Default
	{
		+SHOOTABLE +NOBLOOD +NOTARGETSWITCH +FRIENDLY +NOTELEPORT +DONTSPLASH
		-COUNTKILL
		Radius 2; Height 1;
		Mass 999999; Health 60;
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		countdown = TICRATE * random(10, 30);
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || InStateSequence(CurState, FindState("Death"))) return;
		if (--countdown <= 0) { SetStateLabel("Death"); return; }
		if (level.maptime % 2 == 0)
		{
			let s = Actor.Spawn("RSQTR_Smoke", pos);
			if (s) s.vel = (0, 0, frandom(0.1, 0.3));
		}
		// Ermac's: monsters near it take it for a target, and in the scramble for it
		// they hit each other.
		if (level.maptime % 35 == 0) A_AlertMonsters(200, AMF_TARGETEMITTER | AMF_TARGETNONPLAYER);
	}

	States
	{
	Spawn:
		RSCB A -1;
		Stop;
	Death:
		RSCB A 0 A_NoBlocking;
		RSCB A 1 A_FadeOut(0.1);
		Wait;
	}
}

// Ermac's smoke: a soft puff that fades in, drifts and thins out.
class RSQTR_Smoke : Actor
{
	Default
	{
		+NOINTERACTION +FORCEXYBILLBOARD +NOTIMEFREEZE +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP
		Alpha 0.0;
		RenderStyle "Translucent";
	}

	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_Jump(256, "A", "B", "C", "D");
	A:	RSMK E 0; Goto FadeIn;
	B:	RSMK F 0; Goto FadeIn;
	C:	RSMK G 0; Goto FadeIn;
	D:	RSMK H 0; Goto FadeIn;
	FadeIn:
		"####" "#" 0 A_SetScale(frandom(0.015, 0.03));
	FadeInLoop:
		"####" "#" 1 A_FadeIn(frandom(0.02, 0.03));
		"####" "#" 0 A_JumpIf(Alpha >= 0.2, "FadeOut");
		Loop;
	FadeOut:
		"####" "#" 1 A_FadeOut(frandom(0.003, 0.004));
		"####" "#" 0 A_SetScale(Scale.X - 0.0002, Scale.Y - 0.00005);
		"####" "#" 0 A_JumpIf(Alpha <= 0, "Null");
		Loop;
	}
}

// The pocket's count, carried with the player from level to level.
class RSQTR_CigPack : Inventory
{
	Default
	{
		Inventory.MaxAmount 99;
		+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.KEEPDEPLETED
	}
}
