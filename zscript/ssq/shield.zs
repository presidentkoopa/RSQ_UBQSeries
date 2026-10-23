// RS_ShieldSawQ -- the shield in the hand: an off-hand Weapon.
//
// It is a Weapon only so the engine draws its model at the off controller every frame (a
// layer goes to the off controller only when its caller is the player's off-hand weapon,
// models.cpp). It never fires; the off trigger revs the saw, and the grip edges are read by
// SSQ_Handler. Nothing but SSQ_Handler.Draw() selects it.
//
// The rev: BT_OFFHANDALTATTACK (the off alt-fire) is a synced usercmd bit, so the rev level is
// the same on every machine with no traffic. It drives the blade frames, the loop's pitch,
// the grind, and the damage of the throw it ends in.
//
// Placement: ModifyBobLayer3D, called by the renderer per frame, adds the ssq_held_* cvars
// (cm, degrees) to the layer, so the shield can be dialled in with the headset on.

class SSQ_ShieldSaw : Weapon
{
	int rev;			// 0 .. ssq_rev_tics
	int grindTic;
	bool loopOn;

	Default
	{
		+WEAPON.OFFHANDWEAPON
		+WEAPON.NOHANDSWITCH
		+WEAPON.NO_AUTO_SWITCH
		+WEAPON.NOAUTOSWITCHTO
		+WEAPON.NOALERT
		+WEAPON.CHEATNOTWEAPON
		+WEAPON.NODEATHINPUT
		+WEAPON.NOAUTOFIRE
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.QUIET
		Weapon.SelectionOrder 31000;
		Weapon.SlotNumber 1;
		Weapon.Kickback 0;
		Weapon.UpSound "";
		Weapon.ReadySound "";
		Inventory.PickupMessage "$SSQ_PICKUP";
		Tag "$SSQ_TAG";
	}

	// the held frame for the rev: A closed, B-D opening, E-H blades deploying then spinning
	clearscope int Frame()
	{
		int n = SSQ_Handler.SVI('ssq_rev_tics', 21);
		if (n <= 0) n = 1;
		int f = int(floor(rev * 7.0 / n + 0.5));
		if (rev >= n) f = 5 + (Level.maptime / 2) % 3;	// spinning: E F G H cycle the blade frames 5-7
		return clamp(f, 0, 7);
	}

	clearscope bool Revved() { return rev >= SSQ_Handler.SVI('ssq_rev_tics', 21); }
	clearscope double RevFrac() { int n = SSQ_Handler.SVI('ssq_rev_tics', 21); return n > 0 ? clamp(rev / double(n), 0, 1) : 1; }

	void StopRev()
	{
		rev = 0;
		if (loopOn && Owner) { Owner.A_StopSound(CHAN_7); loopOn = false; }
	}

	// which sprite the held layer wants: hand or not, mirrored or not
	// WHICH BAKED SIZE IS IN YOUR HAND. MODELDEF fixes a model's size at load; the only thing
	// a mod can change per frame is the SPRITE on the layer. So the five sizes are five baked
	// blocks and this picks between them -- SSH1..SSH5 right-handed, SSJ1..SSJ5 left. Same
	// number the guard plate scales by, so the shield you see and the shield that blocks are
	// one object at every setting.
	int HeldSprite()
	{
		let p = Owner ? Owner.player : null;
		bool left = p ? SSQ_Handler.LeftHanded(p) : false;
		double k = clamp(SSQ_Handler.SV('ssq_shield_scale', 1.0), 1.0, 1.5);
		int step = clamp(int(floor((k - 1.0) / 0.125 + 0.5)), 0, 4);	// 1.0 1.125 1.25 1.375 1.5
		static const Name rh[] = { 'SSH1', 'SSH2', 'SSH3', 'SSH4', 'SSH5' };
		static const Name lh[] = { 'SSJ1', 'SSJ2', 'SSJ3', 'SSJ4', 'SSJ5' };
		return GetSpriteIndex(left ? lh[step] : rh[step]);
	}

	States
	{
	Spawn:
		SSQH A -1;
		Stop;
	// MODELDEF only knows a sprite that some state names, and these three are set at run time
	// by writing the layer's sprite (A_SSQ_Held), so they are named here once
	SpriteNames:
		SSQJ A 0;
		SSH1 A 0; SSH2 A 0; SSH3 A 0; SSH4 A 0; SSH5 A 0;
		SSJ1 A 0; SSJ2 A 0; SSJ3 A 0; SSJ4 A 0; SSJ5 A 0;
		Stop;
	Ready:
		SSQH A 1 A_SSQ_Held;
		Loop;
	Select:
		SSQH A 0 A_SSQ_Select;
		SSQH A 1 A_Raise(100);
		Loop;
	Deselect:
		SSQH A 0 A_SSQ_Deselect;
		SSQH A 1 A_Lower(100);
		Loop;
	Fire:
		SSQH A 1 A_SSQ_Held;
		Goto Ready;
	AltFire:
		SSQH A 1 A_SSQ_Held;
		Goto Ready;
	}

	action void A_SSQ_Select()
	{
		invoker.rev = 0;
	}

	action void A_SSQ_Deselect()
	{
		invoker.StopRev();
	}

	// once a tic while held: the rev, the frame, the grind, the bash
	action void A_SSQ_Held()
	{
		let p = player;
		if (!p) return;
		// no WRF flags that fire: the off trigger is ours
		A_WeaponReady(WRF_NOFIRE | WRF_NOBOB | WRF_NOSWITCH);
		int n = SSQ_Handler.SVI('ssq_rev_tics', 21);
		bool trig = (p.cmd.buttons & BT_OFFHANDATTACK) != 0;	// off primary held revs (main primary stays the gun's)
		if (trig) { if (invoker.rev < n) invoker.rev++; }
		else if (invoker.rev > 0) invoker.rev = max(0, invoker.rev - 2);

		// the loop: pitch climbs with the rev
		if (invoker.rev > 0)
		{
			if (!invoker.loopOn) { A_StartSound("ssq/revstart", CHAN_6); A_StartSound("ssq/loop", CHAN_7, CHANF_LOOPING, 0.7); invoker.loopOn = true; }
			A_SoundPitch(CHAN_7, 0.7 + 0.8 * invoker.RevFrac());
		}
		else if (invoker.loopOn) { A_StopSound(CHAN_7); A_StartSound("ssq/revstop", CHAN_6); invoker.loopOn = false; }

		// the frame: both hand variants share one state table, the sprite is written here
		let psp = p.FindPSprite(PSP_OFFHANDWEAPON);
		if (psp)
		{
			psp.sprite = invoker.HeldSprite();
			psp.frame = invoker.Frame();
		}

		let h = SSQ_Handler.Get();
		if (h) SSQ_Guard.HeldTick(PlayerPawn(self), invoker, h.PoseOf(p.mo.PlayerNumber()));
	}

	// the renderer asks where the layer goes, every frame: add the live sliders. Translation
	// is in model units (cm) in the controller frame X right, Y up, Z back; rotation X yaw,
	// Y pitch, Z roll.
	override Vector3, Vector3 ModifyBobLayer3D(Vector3 translation, Vector3 rotation, int layer, double ticfrac)
	{
		if (layer != PSP_OFFHANDWEAPON)
		{
			// NOT OURS: the pack's gun-side hand layers are placed by the hook of ITS hands weapon,
			// which the shield displaces from the off hand. Forward to it (found by name: no link).
			if (Owner)
			{
				Name hn = "RSQ_Hands";	// a variable, so an absent class is a run-time null, not a compile error
				let w = Weapon(Owner.FindInventory(hn));
				if (w && w != self)
				{
					Vector3 t, r;
					[t, r] = w.ModifyBobLayer3D(translation, rotation, layer, ticfrac);
					return t, r;
				}
			}
			return translation, rotation;
		}
		if (consoleplayer < 0) return translation, rotation;
		let p = players[consoleplayer];
		translation += (SSQ_Handler.UV(p, 'ssq_held_x', 0), SSQ_Handler.UV(p, 'ssq_held_z', 0), -SSQ_Handler.UV(p, 'ssq_held_y', 0));
		rotation += (SSQ_Handler.UV(p, 'ssq_held_yaw', 0), SSQ_Handler.UV(p, 'ssq_held_pitch', 0), SSQ_Handler.UV(p, 'ssq_held_roll', 0));
		return translation, rotation;
	}
}

// sounds and haptics that are "for you": the haptic is a tiny quake at the player's own
// feet with no tremor radius to speak of, so only the player it belongs to feels it, on
// every machine alike (deterministic), and the view does not shake. X buzzes the left
// controller, Y the right (r_utility.cpp), so the off hand is picked by handedness.
// Needs vr_quake_haptic_level > 0 on the headset.
class SSQ_FX abstract play
{
	static void Buzz(PlayerPawn mo, double strength, int tics)
	{
		if (!mo || !mo.player) return;
		if (SSQ_Handler.UVI(mo.player, 'ssq_feedback', 1) == 0) return;
		bool left = !SSQ_Handler.LeftHanded(mo.player);
		let q = Actor.Spawn('SSQ_Buzzer', mo.pos);
		if (!q) return;
		q.A_QuakeEx(left ? strength : 0, left ? 0 : strength, 0, max(1, tics), 0, 4, "", QF_SCALEDOWN);
	}

	static void Particle(Actor at, Vector3 p, Vector3 v, Color c, int life, double size)
	{
		FSpawnParticleParams pp;
		pp.color1 = c; pp.style = STYLE_None; pp.flags = SPF_FULLBRIGHT; pp.lifetime = life;
		pp.size = size; pp.sizestep = 0; pp.pos = p; pp.vel = v; pp.accel = (0, 0, -0.3);
		pp.startalpha = 1.0; pp.fadestep = -1; pp.startroll = 0; pp.rollvel = 0; pp.rollacc = 0;
		at.Level.SpawnParticle(pp);
	}

	static void Sparks(Actor at, Vector3 p, Vector3 n, int count)
	{
		if (!at) return;
		let f = Actor.Spawn('SSQ_BlockFlash', p);
		if (f) f.A_SetScale(0.25 + count * 0.015);
		let sp = Actor.Spawn('SSQ_SparkPuff', p + n * 2);
		if (count >= 12) Actor.Spawn('SSQ_BlastBloom', p + n * 4);
		for (int k = 0; k < count; k++)
		{
			Vector3 v = n * frandom(2, 6) + (frandom(-2, 2), frandom(-2, 2), frandom(0, 3));
			Particle(at, p, v, "ffd27a", 10 + random(0, 8), 2.5);
		}
	}
}

class SSQ_Buzzer : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOSECTOR
		+DONTSPLASH
	}
	States
	{
	Spawn:
		TNT1 A 12;
		Stop;
	}
}
