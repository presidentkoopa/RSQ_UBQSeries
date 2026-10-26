// WHAT THE GRAB FEELS AND SOUNDS LIKE.
//
// Every other file decides; this one only reports. It is told what happened --
// a lock, a launch, a catch, a drop -- and turns it into a buzz in the right
// hand and a sound in the right place. Nothing here can change what the grab
// does, so nothing here can break it: switch every option on this page off and
// the mechanic behaves identically, silently.
//
// =========================================================================
// HAPTICS ON A STOCK ENGINE, AND THE ONE TRICK THAT REACHES THEM
// =========================================================================
//
// Stock qzd17.3 gives ZScript NO vibrate call. The fork's level.VRHaptic is
// zero hits here. What the engine does have is a handful of places that buzz
// the controllers on its own account, and exactly one of them is per-hand and
// can be triggered on purpose without side effects:
//
//   P_SpawnPlayerMissile (p_mobj.cpp:7547-7562). When a player spawns a
//   projectile that has a DamageType, a damage function or a SeeSound, and
//   P_CheckMissileSpawn passes, the engine calls Vibrate(150 ms, hand, 0.8) on
//   the hand that fired -- ALF_ISOFFHAND picks the off hand, and the engine
//   itself maps main/off to right/left by vr_control_scheme, so a left-handed
//   player is right without any code here knowing it.
//
// That is the RSVR_Buzz trick the owner's Brutal22 and Aliens Quest ports
// already ship. It is used here with ONE CHANGE, and the change is a
// compatibility fix:
//
//   RSQDG_Buzz IS NOT A MISSILE. RSVR_Buzz is `Projectile;`, so every mod that
//   watches WorldThingSpawned for "the player fired a missile" sees a shot.
//   Brutal22Q's recoil and muzzle flash do exactly that and except RSVR_Buzz BY
//   NAME (rsq/ballistics.zs:61) -- so a buzz under any other name would kick
//   the gun and flash the muzzle every time the grab buzzed. Without +MISSILE
//   the engine treats it as an MBF grenade in P_CheckMissileSpawn (p_mobj.cpp
//   :6971), +NOCLIP lets the move succeed, the haptic still fires, and
//   WorldThingSpawned -- which runs from CallPostBeginPlay, so it sees the
//   class defaults -- reports bMissile false to every mod listening.
//
// THE SHAPE IT IMPOSES. Strength is fixed at 0.8 and length at 150 ms, and the
// Quest runtime IGNORES a vibrate request while the channel is still busy
// (OpenXrInput.cpp TBXR_Vibrate returns early). So there is no amplitude to
// play with -- the vocabulary is RHYTHM:
//
//   lock       one tick                  "got it"
//   launch     one tick                  "it's coming"
//   approach   ticks speeding up         a sonar ping closing in, and the
//                                        one cue you can use without looking
//   (silence)  the last stretch          so the catch lands clean, never
//                                        swallowed by a ramp tick still busy
//   catch      one tick, two if heavy    "in your hand" -- and a barrel
//                                        should feel like more than a clip
//   release    one tick
//
// A_QuakeEx WAS CONSIDERED AND REJECTED. It does give per-side AMPLITUDE (X
// buzzes the left controller, Y the right, r_utility.cpp:1084-1094) -- but the
// same intensity shakes the view by the same number of map units, and in a
// headset a centimetre of camera jitter per buzz is a comfort problem, not
// feedback. Its amplitude is also a random value in +/-intensity, so half its
// samples are nothing.
//
// CAVEAT, stated where it is true: while a weapon is two-hand stabilised the
// engine also buzzes the OTHER hand at 0.6 (p_mobj.cpp:7557). Nothing in
// script can see or stop that.
// =========================================================================

class RSQDG_Buzz : Actor
{
	Default
	{
		// NOT `Projectile` -- see above. These are the flags that make it a
		// harmless, invisible, non-interacting point that lives for one tic.
		+NOCLIP
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		Radius 1;
		Height 1;
		Speed 0;
		// Any DamageType other than None is what the engine checks. Our own name,
		// so nothing ever matches it by accident.
		DamageType "RSQDGHaptic";
		RenderStyle "None";
	}
	States
	{
	Spawn:
		TNT1 A 1;
		Stop;
	}
}

// A SOUND AT A POINT, with nothing else about it. Invisible, touches nothing,
// takes no part in the playsim, and removes itself after two seconds -- longer
// than any sound it carries. Its sound stays where it was spawned.
class RSQDG_SoundPoint : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		RenderStyle "None";
		Radius 1;
		Height 1;
	}
	States
	{
	Spawn:
		TNT1 A 70;
		Stop;
	}
}

class RSQDG_Feel : EventHandler
{
	// ---- the rhythm scheduler ----------------------------------------------
	//
	// Priorities, so an important tick is QUEUED rather than lost to a busy
	// channel, and a ramp tick never delays a catch.
	const PRI_RAMP    = 1;
	const PRI_LOCK    = 2;
	const PRI_LAUNCH  = 3;
	const PRI_RELEASE = 3;
	const PRI_CATCH   = 4;

	// 150 ms is 5.25 tics. Six tics busy, so a queued tick is sent after the
	// channel is actually free and is not silently dropped by the runtime.
	const BUSY_TICS = 6;

	private int busyUntil[2];
	private int pendPri[2];
	private int pendCount[2];
	private int lastRamp[2];

	// The slot the flight hum loops on, on the FLYING OBJECT. A number nothing
	// else uses, so the object's own sounds -- a barrel's, a mod pickup's --
	// are never cut off by the hum, and stopping the hum never cuts them.
	const HUM_SLOT = 20819;
	private Actor humOn[2];

	static RSQDG_Feel Get()
	{
		return RSQDG_Feel(EventHandler.Find("RSQDG_Feel"));
	}

	// ---- haptics -----------------------------------------------------------

	private bool HapticsOn(PlayerInfo p)
	{
		return RSQDG_Reach.Flag("rsqdg_haptics", p, true);
	}

	private void Fire(int hand, PlayerPawn pmo)
	{
		if (!pmo) return;
		pmo.SpawnPlayerMissile("RSQDG_Buzz", pmo.angle, noautoaim: true,
			aimflags: (hand == 1) ? ALF_ISOFFHAND : 0);
		busyUntil[hand] = level.maptime + BUSY_TICS;
	}

	// Ask for `count` ticks at this priority. Sent now if the channel is free;
	// otherwise queued -- and a queued request only ever goes UP in priority, so
	// a catch waiting behind a ramp tick is never downgraded by the next ramp.
	void Pulse(int hand, int pri, int count = 1)
	{
		if (hand != 0 && hand != 1) return;
		let p = players[consoleplayer];
		if (!p || !p.mo || !HapticsOn(p)) return;

		if (level.maptime >= busyUntil[hand] && pendCount[hand] == 0)
		{
			Fire(hand, p.mo);
			count--;
		}
		if (count <= 0) return;

		// A ramp tick is the one thing that is allowed to be lost: by the time
		// the channel is free there is a newer, closer one to send instead.
		if (pri == PRI_RAMP) return;

		if (pri >= pendPri[hand])
		{
			pendPri[hand] = pri;
			pendCount[hand] = max(pendCount[hand], count);
		}
	}

	// ---- sound -------------------------------------------------------------

	private bool SoundOn(PlayerInfo p)
	{
		return RSQDG_Reach.Flag("rsqdg_sound", p, true);
	}

	private double Vol(PlayerInfo p)
	{
		return clamp(RSQDG_Reach.Num("rsqdg_sound_vol", p, 0.8), 0.0, 1.0);
	}

	// Light things sound high and heavy things low. A clip ticks; a barrel
	// clonks. One curve, from the same heft the rhythm uses.
	private static double PitchFor(Actor a)
	{
		return 1.30 - 0.55 * RSQDG_Mass.Heft(a);
	}

	// Placed in the WORLD at a point, so a tick at your palm is heard at your
	// palm and not from the floor under the pawn, which is where a sound on the
	// player actor plays from.
	//
	// THROUGH A ONE-SHOT POINT ACTOR, not S_StartSoundAt. That native is in the
	// 17.3 release (9afc750) but NOT in earlier 17.x builds, and a call to a
	// function the engine lacks is a fatal compile error for the whole package.
	// The point actor is ShieldSawQ's SSQ_Ping shape, already shipping on Quest:
	// spawned, given the sound, gone in two seconds.
	private void At(PlayerInfo p, Vector3 pos, Sound s, double vol, double pitch)
	{
		if (!SoundOn(p)) return;
		let e = Actor.Spawn("RSQDG_SoundPoint", pos);
		if (e) e.A_StartSound(s, CHAN_BODY, 0, Vol(p) * vol, ATTN_NORM, pitch);
	}

	private void StopHum(int hand)
	{
		if (humOn[hand]) humOn[hand].A_StopSound(HUM_SLOT);
		humOn[hand] = null;
	}

	// ---- THE EVENTS ----------------------------------------------------------
	//
	// Each is also forwarded to RSQDG_Events, so a mod that wants to dress a
	// pull -- ModelSwapper turning a sprite into a model in flight, say -- hears
	// about it without this package naming that mod.

	void OnLock(int hand, Actor a, PlayerInfo p)
	{
		if (!a || !p || !p.mo) return;
		Pulse(hand, PRI_LOCK);
		At(p, RSQDG_Reach.Palm(p.mo, hand), "rsqdg/lock", 0.6, PitchFor(a));
		RSQDG_Events.Tell("pull.lock", hand, a);
	}

	void OnUnlock(int hand, Actor a)
	{
		RSQDG_Events.Tell("pull.unlock", hand, a);
	}

	void OnLaunch(int hand, Actor a, PlayerInfo p)
	{
		if (!a || !p) return;
		Pulse(hand, PRI_LAUNCH);
		lastRamp[hand] = level.maptime;

		if (SoundOn(p))
		{
			double pitch = PitchFor(a);
			// The lift-off, FROM THE OBJECT: you hear it leave the floor over
			// there, which is what tells you which thing answered.
			a.A_StartSound("rsqdg/launch", CHAN_AUTO, CHANF_OVERLAP, Vol(p) * 0.8, ATTN_NORM, pitch);

			// THE HUM, LOOPED ON THE OBJECT for the whole flight. Being on the
			// object is the point -- it is positional, so you can hear where it
			// is and that it is closing. It rises in pitch as it nears (see
			// WorldTick). A sound looping on an actor is stopped by the engine
			// if the actor is destroyed, so a pull that is consumed mid-air
			// cannot leave a hum playing at a point in space.
			StopHum(hand);
			a.A_StartSound("rsqdg/hum", HUM_SLOT, CHANF_LOOPING, Vol(p) * 0.35, ATTN_NORM, pitch * 0.85);
			humOn[hand] = a;
		}
		RSQDG_Events.Tell("pull.start", hand, a, true);
	}

	// `a` may be null when catching it used it up and the item is gone.
	void OnCatch(int hand, Actor a, PlayerInfo p, bool used, double heft)
	{
		StopHum(hand);
		if (!p || !p.mo) return;

		// TWO TICKS FOR A HEAVY THING. Rhythm is the only dial there is, and
		// a barrel landing in your palm should not feel like a clip landing.
		Pulse(hand, PRI_CATCH, heft >= 0.55 ? 2 : 1);

		Vector3 palm = RSQDG_Reach.Palm(p.mo, hand);
		At(p, palm, "rsqdg/catch", 0.55 + 0.45 * heft, 1.25 - 0.5 * heft);

		let las = RSQDG_Laser.Get();
		if (las) las.Burst(hand);

		RSQDG_Events.Tell("pull.caught", hand, used ? null : a, true);
	}

	void OnRefused(int hand, Actor a)
	{
		RSQDG_Events.Tell("pull.refused", hand, a, true);
	}

	// Arrived and was not caught, could not get there, or the pull was called
	// off. `what` is the event name, so a listener can tell them apart.
	void OnDrop(int hand, Actor a, PlayerInfo p, String what)
	{
		StopHum(hand);
		if (a && p && what != "pull.aborted")
			At(p, (a.Pos.x, a.Pos.y, a.Pos.z + a.Height * 0.5), "rsqdg/drop", 0.7, PitchFor(a));
		RSQDG_Events.Tell(what, hand, a, true);
	}

	void OnRelease(int hand, Actor a, bool thrown)
	{
		Pulse(hand, PRI_RELEASE);
		RSQDG_Events.Tell(thrown ? "hold.throw" : "hold.drop", hand, a);
	}

	// ---- per tic: the queue, the approach ramp, the rising hum --------------
	override void WorldTick()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		let pmo = p.mo;

		let fl = RSQDG_Flight.Get();
		for (int h = 0; h < 2; h++)
		{
			// The queue first, so an owed catch tick goes out the first tic
			// the channel is free.
			if (pendCount[h] > 0 && level.maptime >= busyUntil[h] && HapticsOn(p))
			{
				Fire(h, pmo);
				if (--pendCount[h] <= 0) { pendCount[h] = 0; pendPri[h] = 0; }
			}

			Actor a = fl ? fl.FlyingActor(h) : null;
			if (!a)
			{
				// Belt and braces: flight reports every ending, but a hum left
				// on something that stopped flying for a reason nobody reported
				// would play for the rest of the level.
				if (humOn[h]) StopHum(h);
				continue;
			}

			double prog = fl.Progress(h);

			// THE APPROACH RAMP. 16 tics between ticks at launch, 7 by the
			// end: about two a second rising to five. Then SILENCE for the last
			// stretch -- fl.Near() -- so the catch tick lands on a free channel
			// and reads as its own event rather than as one more ping.
			if (RSQDG_Reach.Flag("rsqdg_haptic_ramp", p, true) && !fl.Near(h))
			{
				int every = int(16.0 - 9.0 * prog);
				if (level.maptime - lastRamp[h] >= every)
				{
					Pulse(h, PRI_RAMP);
					lastRamp[h] = level.maptime;
				}
			}

			// THE HUM RISES as it closes -- most of an octave across the
			// flight -- and swells. Pitch is the cue the ear reads fastest,
			// and a rising one means "arriving" in every language.
			if (humOn[h] == a && SoundOn(p))
			{
				double base = PitchFor(a) * 0.85;
				a.A_SoundPitch(HUM_SLOT, base * (1.0 + 0.7 * prog));
				a.A_SoundVolume(HUM_SLOT, Vol(p) * (0.30 + 0.45 * prog));
			}
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int h = 0; h < 2; h++)
		{
			humOn[h] = null;
			busyUntil[h] = 0; pendPri[h] = 0; pendCount[h] = 0; lastRamp[h] = 0;
		}
	}

	override void WorldLoaded(WorldEvent e)
	{
		// level.maptime restarts at zero on a new map; a busyUntil carried
		// over from the last one would mute the hands for that long.
		for (int h = 0; h < 2; h++)
		{
			humOn[h] = null;
			busyUntil[h] = 0; pendPri[h] = 0; pendCount[h] = 0; lastRamp[h] = 0;
		}
	}
}


// ---------------------------------------------------------------------------
// WHAT THE PULL DID, TOLD TO WHOEVER ASKED TO HEAR.
//
// The desktop's GrabEventService protocol, so a mod written against one family
// hears the other. Every Service whose class name contains "GrabEventService"
// is told
//
//   GetInt("grab.event", <event>, hand, fromAir ? 1 : 0, <thing>, 'RSQ_DistanceGrab')
//
//   pull.lock      a distant thing was taken hold of where it stands
//   pull.unlock    a lock ended without a launch
//   pull.start     it was flicked and is flying to the hand
//   pull.caught    the hand took it out of the air (thing is null if it was
//                  used up on the way in)
//   pull.refused   the hand could not take it; it keeps flying
//   pull.missed    it arrived and the hand was not there; it drops
//   pull.blocked   it could not get there in time; it drops where it is
//   pull.aborted   called off -- switched off, the player died, the level changed
//   hold.throw / hold.drop   a carried thing left the hand
//
// The answer is ignored: an event is news, not a question. With no listener
// loaded the lookup finds nothing and costs one string search.
//
// THIS IS THE DOOR FOR D12, the voxel/model swap through the flight: a mod
// that knows what a thing should look like listens for pull.start and dresses
// it, and listens for every ending to undress it. Whoever lends is the single
// owner of the restore -- which is exactly why it belongs to that mod and not
// to this one.
// ---------------------------------------------------------------------------
class RSQDG_Events play
{
	static void Tell(String what, int hand, Actor a, bool fromAir = false)
	{
		let it = ServiceIterator.Find("GrabEventService");
		Service s;
		while (s = it.Next())
			s.GetInt("grab.event", what, hand, fromAir ? 1.0 : 0.0, a, 'RSQ_DistanceGrab');
	}
}
