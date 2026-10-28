// ERMAC'S CIGARETTE (optional tribute, off by default: rsqtr_cig).
//
// The idea is Ermac's: the cigarette, its butt and its smoke come from his Virtual
// Tactical Vest for Doom VR (its credits name him as their modeller; the cigarette's
// texture is an atlas shared with a Sketchfab cigarette-pack model, its pack art blanked
// here), and the Zippo is the voxel lighter from his ZBlood-VR, credited to him there.
// This is a new implementation for the rig.
//
// Reach to the pocket on your left chest (right chest left-handed) and grip (or press Use): a cigarette comes
// to that hand. Bring it to your mouth and hold it there a moment and it lights --
// or, with the Zippo on (rsqtr_cig_zippo), reach to the same pocket with your OTHER
// hand and keep the grip held: the Zippo comes out and flicks open, and holding its
// flame to the cigarette's tip at your mouth lights it. Let go of the grip and the
// Zippo snaps shut and goes away.
//
// While it burns (rsqtr_cig_secs), RSQ_SlowMo slows the world, if it is loaded:
// the cigarette asks for it through RS_SlowMo's own rsm_pulse, so it needs no link
// to the other mod and does nothing if nothing answers. Ermac's originals are kept:
// smoking at your mouth heals you slowly under 35 health, and a butt flicked away
// (press the grip again while swinging the hand) smoulders where it lands and
// draws monsters to it, and into each other. Burnt down, it drops from your hand.
// A pocket holds a few (rsqtr_cig_count), refilled on a new level (rsqtr_cig_refill).
//
// NETPLAY: the hands are the console player's alone, so that machine decides and
// sends one event per action (take, put back, light, at the mouth or not, flick,
// Zippo out, Zippo away); every machine spawns and moves the same things.

class RSQTR_Cig : EventHandler
{
	const POCKET_F = 0.12;
	const POCKET_L = 0.16;
	const POCKET_U = -0.25;
	const POCKET_R = 0.09;
	const MOUTH_R = 0.12;        // metres: the cigarette is "at your mouth"
	const FLAME_R = 0.07;        // metres: the Zippo's flame is "on the tip"
	const FLICK_SPEED = 1.5;     // metres a second: a press while the hand moves this fast is a flick

	// ---- synced --------------------------------------------------------------------
	int  cigHand[MAXPLAYERS];    // -1 none
	bool lit[MAXPLAYERS];
	int  burnEnd[MAXPLAYERS];
	bool atMouth[MAXPLAYERS];
	Vector3 flickAt[MAXPLAYERS]; // where the hand was when it flicked (sent, so every machine agrees)
	int  zipHand[MAXPLAYERS];    // -1 none
	Actor cigProp[MAXPLAYERS];
	Actor zipProp[MAXPLAYERS];

	// ---- local (console player) ----------------------------------------------------
	private transient bool pressWas[2];
	private transient Vector3 lastHand[2];
	private transient int mouthT, flameT, pulseNext;
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
			cigHand[i] = -1; zipHand[i] = -1; lit[i] = false; atMouth[i] = false;
			cigProp[i] = null; zipProp[i] = null;
			if (!playeringame[i] || !players[i].mo) continue;
			let pmo = players[i].mo;
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

	// ---- the local loop ----------------------------------------------------------------
	override void WorldTick()
	{
		BurnAll();

		let p = players[consoleplayer];
		if (!p || !p.mo || p.mo.health <= 0) { HideMark(); return; }
		let pmo = p.mo;
		int n = consoleplayer;
		if (!RSQTR_Rig.Flag("rsqtr_cig", p, false)) { HideMark(); return; }
		let rig = RSQTR_Rig.Get();
		Vector3 pocket = Pocket(pmo);
		bool useDown = (p.cmd.buttons & BT_USE) != 0;
		bool zippo = RSQTR_Rig.Flag("rsqtr_cig_zippo", p, false);
		double nearest = 1e9;

		for (int h = 0; h < 2; h++)
		{
			Vector3 hp = RSQTR_Body.Hand(pmo, h);
			Vector3 hv = level.Vec3Diff(lastHand[h], hp);
			double speed = RSQTR_Body.RoomMetres(lastHand[h], hp) * TICRATE;
			lastHand[h] = hp;
			bool grip = rig && rig.gripDown[n * 2 + h];
			bool holding = grip || useDown;
			bool press = holding && !pressWas[h];
			pressWas[h] = holding;
			double dp = RSQTR_Body.RoomMetres(hp, pocket);
			nearest = min(nearest, dp);
			bool inPocket = dp < POCKET_R;

			if (press && inPocket)
			{
				if (cigHand[n] < 0)
				{
					if (Packs(pmo) > 0) EventHandler.SendNetworkEvent("rsqtr_cigtake", h);
					else RSQTR_Buzzer.Start(pmo, h, 0.2, 3);
				}
				else if (cigHand[n] == h && !lit[n]) EventHandler.SendNetworkEvent("rsqtr_cigback");
				else if (cigHand[n] == 1 - h && zippo && zipHand[n] < 0 && !lit[n]) EventHandler.SendNetworkEvent("rsqtr_zipon", h);
			}
			else if (press && cigHand[n] == h && speed >= RSQTR_A11y.Low(FLICK_SPEED))   // Gesture Ease: x1..x0.5
			{
				// A flick: away it goes, with the hand's own speed.
				Vector3 at = RSQTR_CigProp(cigProp[n]) ? cigProp[n].pos : hp;
				EventHandler.SendNetworkEvent("rsqtr_cigat", int(at.x * 8), int(at.y * 8), int(at.z * 8));
				EventHandler.SendNetworkEvent("rsqtr_cigflick", int(hv.x * 100), int(hv.y * 100), int(hv.z * 100));
			}
			if (zipHand[n] == h && !holding) EventHandler.SendNetworkEvent("rsqtr_zipoff");
		}

		// At the mouth: lighting, smoking.
		if (cigHand[n] >= 0)
		{
			Vector3 hp = RSQTR_Body.Hand(pmo, cigHand[n]);
			bool mouth = RSQTR_Body.RoomMetres(hp, Mouth(pmo)) < MOUTH_R;
			if (mouth != atMouth[n]) EventHandler.SendNetworkEvent("rsqtr_cigmouth", mouth ? 1 : 0);
			mouthT = mouth ? mouthT + 1 : 0;
			if (!lit[n] && mouth)
			{
				if (!zippo)
				{
					if (mouthT >= 12) EventHandler.SendNetworkEvent("rsqtr_ciglight");
				}
				else if (zipHand[n] >= 0 && RSQTR_ZippoProp(zipProp[n]) && RSQTR_ZippoProp(zipProp[n]).Burning())
				{
					Vector3 tip = RSQTR_CigProp(cigProp[n]) ? RSQTR_CigProp(cigProp[n]).Tip() : hp;
					Vector3 flame = RSQTR_ZippoProp(zipProp[n]).Flame();
					flameT = RSQTR_Body.RoomMetres(tip, flame) < FLAME_R ? flameT + 1 : 0;
					if (flameT >= 6) EventHandler.SendNetworkEvent("rsqtr_ciglight");
				}
			}
			// While it burns, keep RSQ_SlowMo's pulse topped up (its hold caps at 5 s).
			if (lit[n] && RSQTR_Rig.Flag("rsqtr_cig_slowmo", p, true) && level.maptime >= pulseNext)
			{
				int left = burnEnd[n] - level.maptime;
				if (left > 0)
				{
					EventHandler.SendNetworkEvent("rsm_pulse", min(5000, left * 1000 / TICRATE), RSQTR_Rig.Opt("rsqtr_cig_depth", p, 25));
					pulseNext = level.maptime + TICRATE * 2;
				}
			}
		}
		else { mouthT = 0; flameT = 0; }

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
	override void NetworkProcess(ConsoleEvent e)
	{
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (!pmo) return;

		if (e.Name == "rsqtr_cigtake")
		{
			if (cigHand[n] >= 0 || Packs(pmo) <= 0) return;
			pmo.TakeInventory("RSQTR_CigPack", 1);
			cigHand[n] = clamp(e.Args[0], 0, 1);
			lit[n] = false; atMouth[n] = false;
			let c = RSQTR_CigProp(Actor.Spawn("RSQTR_CigProp", RSQTR_Body.Hand(pmo, cigHand[n])));
			if (c) { c.holder = pmo; c.hand = cigHand[n]; }
			cigProp[n] = c;
			pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.6);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, cigHand[n], 0.3, 3);
		}
		else if (e.Name == "rsqtr_cigback")
		{
			if (cigHand[n] < 0 || lit[n]) return;
			pmo.GiveInventory("RSQTR_CigPack", 1);
			if (cigProp[n]) cigProp[n].Destroy();
			cigHand[n] = -1;
			pmo.A_StartSound("rsqtr/radial", CHAN_AUTO, 0, 0.5);
		}
		else if (e.Name == "rsqtr_ciglight")
		{
			if (cigHand[n] < 0 || lit[n]) return;
			lit[n] = true;
			burnEnd[n] = level.maptime + int(RSQTR_Rig.Num("rsqtr_cig_secs", players[n], 6) * TICRATE);
			let c = RSQTR_CigProp(cigProp[n]);
			if (c) c.SetLit();
			pmo.A_StartSound("rsqtr/ciglight", CHAN_AUTO, 0, 0.8);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, cigHand[n], 0.5, 6);
		}
		else if (e.Name == "rsqtr_cigmouth")
		{
			bool was = atMouth[n];
			atMouth[n] = e.Args[0] != 0;
			// Away from the mouth after a draw: the exhale.
			if (was && !atMouth[n] && lit[n]) Exhale(pmo);
		}
		else if (e.Name == "rsqtr_cigat")
		{
			flickAt[n] = (e.Args[0], e.Args[1], e.Args[2]) / 8.0;
		}
		else if (e.Name == "rsqtr_cigflick")
		{
			if (cigHand[n] < 0) return;
			Vector3 v = (e.Args[0], e.Args[1], e.Args[2]) / 100.0;
			DropButt(n, v, flickAt[n]);
		}
		else if (e.Name == "rsqtr_zipon")
		{
			if (zipHand[n] >= 0) return;
			zipHand[n] = clamp(e.Args[0], 0, 1);
			let z = RSQTR_ZippoProp(Actor.Spawn("RSQTR_ZippoProp", RSQTR_Body.Hand(pmo, zipHand[n])));
			if (z) { z.holder = pmo; z.hand = zipHand[n]; }
			zipProp[n] = z;
			pmo.A_StartSound("rsqtr/zipopen", CHAN_AUTO, 0, 0.8);
			if (n == consoleplayer) RSQTR_Buzzer.Start(pmo, zipHand[n], 0.4, 4);
		}
		else if (e.Name == "rsqtr_zipoff")
		{
			if (zipHand[n] < 0) return;
			if (zipProp[n]) zipProp[n].Destroy();
			zipHand[n] = -1;
			pmo.A_StartSound("rsqtr/zipclose", CHAN_AUTO, 0, 0.8);
		}
	}

	private void Exhale(PlayerPawn pmo)
	{
		Vector3 m = Mouth(pmo);
		for (int i = 0; i < 6; i++)
		{
			let s = Actor.Spawn("RSQTR_Smoke", m);
			if (s)
			{
				s.vel = (cos(pmo.angle) * (0.6 + i * 0.1), sin(pmo.angle) * (0.6 + i * 0.1), 0.15);
				s.Scale *= 2.0;
			}
		}
	}

	// The butt is a real thing in the world (it bounces, and the smouldering one draws
	// monsters), so it starts from a place every machine agrees on: the flicking hand's
	// position as sent, or, burnt down, just in front of the player at chest height.
	// The hand-held prop's own position is only true on the holder's machine.
	private void DropButt(int n, Vector3 v, Vector3 from = (0, 0, 0))
	{
		let pmo = players[n].mo;
		if (from == (0, 0, 0) && pmo)
			from = pmo.pos + (cos(pmo.angle) * 12, sin(pmo.angle) * 12, pmo.height * 0.6);
		let b = RSQTR_Butt(Actor.Spawn("RSQTR_Butt", from));
		if (b)
		{
			b.vel = v;
			b.target = pmo;
			b.smoulder = lit[n];
		}
		if (cigProp[n]) cigProp[n].Destroy();
		cigHand[n] = -1;
		lit[n] = false;
		atMouth[n] = false;
	}

	// Burning down, and Ermac's slow heal while you smoke under 35 health.
	private void BurnAll()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || cigHand[n] < 0) continue;
			let pmo = players[n].mo;
			if (!pmo || pmo.health <= 0) { DropButt(n, (0, 0, 0)); continue; }
			if (!lit[n]) continue;
			if (level.maptime >= burnEnd[n]) { DropButt(n, (0, 0, -0.5)); continue; }
			if (atMouth[n] && pmo.health < 35 && (burnEnd[n] - level.maptime) % 105 == 0)
				pmo.A_SetHealth(pmo.health + 1);
		}
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
	int age;

	// (RSQ_Accessibility's Photosensitive Mode: the ember glows steady, not pulsing)
	void SetLit()
	{
		burning = true; SetStateLabel("Lit");
		if (RSQTR_A11y.Photo()) A_AttachLight("rsqtr_ember", DynamicLight.PointLight, "FF6020", 3, 0, DYNAMICLIGHT.LF_ATTENUATE);
		else A_AttachLight("rsqtr_ember", DynamicLight.PulseLight, "FF6020", 2, 4, DYNAMICLIGHT.LF_ATTENUATE, (0, 0, 0), 0.4);
	}

	// The burning end: Ermac's mesh runs 9.5 units along X; at scale 0.3, ~1.7 forward.
	Vector3 Tip() { return holder ? AlongHand(0.05) : pos; }

	override void Tick()
	{
		Follow(false);
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
