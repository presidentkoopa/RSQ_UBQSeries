// WHAT THE GRAB FEELS LIKE.
//
// Every other file decides; this one only reports. It is told what happened --
// a lock, a launch, a catch, a drop -- and turns it into a buzz in the right
// hand.
//
// NO SOUNDS OF ITS OWN (2026-10-27). The five procedural sounds this used to
// play (tools/gen_sounds.py: a lock tick, a launch, a hum that rose through the
// flight, a catch thump, a drop) are gone. The owner called them goofy, and his
// RS_WorldHands -- the grab he wants this to feel like -- plays none at all: its
// pk3 has no SNDINFO and no A_StartSound anywhere in its hand code. What you
// hear is the world itself: a barrel's own sounds, a monster's pain when a
// thrown thing lands on it, a door's own motor as you lift it. Nothing here can change what the grab
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
// THAT WAS THE PULSE ROUTE, and it is still here (rsqdg_rumble off). The
// default is now the RUMBLE ROUTE, below, which has what the pulse lacks:
// amplitude, and a continuous level.
//
// =========================================================================
// THE RUMBLE ROUTE -- A_QuakeEx, and the four things that make it usable
// =========================================================================
//
// The renderer turns quake jiggers into controller rumble every rendered
// frame (r_utility.cpp:1084-1094): Vibrate(10 ms, left, level * X-jigger) and
// Vibrate(10 ms, right, level * Y-jigger), level = vr_quake_haptic_level, 0.8
// by default. So a quake ISSUED BY US is a per-hand amplitude dial. Four
// things had to be got right, each from the stock source:
//
//  1 NO RANDOMNESS, NO NEGATIVES. Without QF_WAVE the jigger is a random draw
//    in +/-intensity (QuakePower), so half the frames are negative -- nothing
//    -- and the rest are noise. With QF_WAVE the jigger is
//    intensity * sin(mult * (countdown - ticFrac) * 2pi/35) and the random
//    term is zero (a_quake.cpp GetModWave; StaticGetQuakeIntensities). Issued
//    with duration 2 every tic, the quake is always at countdown 1 when the
//    frame is drawn (spawned in WorldTick, ticked once by RunThinkers in the
//    same tic -- fresh thinkers are ticked the tic they are made,
//    dthinker.cpp:153-160), so time is (1 - ticFrac) in (0, 1], and with
//    mult 17.5 the phase is pi*time: the sine is NEVER negative. Every frame
//    of a tic gets a positive amplitude that swells and falls across the tic,
//    a 35 Hz grain under a level we control.
//
//  2 THE NUMBERS. GetModIntensity doubles the intensity, and in wave mode the
//    result is multiplied again by GetModIntensity(1.0) -- 2 -- so the
//    jigger peak is 4 x what we pass, and the haptic peak is 0.8 x that at the
//    default level. We pass amplitude / 3.2, so `amp` below IS the controller
//    amplitude at its peak, on a default install.
//
//  3 NO SOUND, NO DAMAGE, NO NEIGHBOUR. A dedicated silent spot actor at the
//    player (DEarthquake claims CHAN_BODY on its spot for its whole life),
//    sfx "", damrad 0, tremrad 64 -- so a co-op partner would have to be
//    standing on top of you to feel it. Roll and Z at 0: they make no haptic.
//
//  4 IT AND THE PULSE CANNOT SHARE A CONTROLLER. The Quest runtime refuses a
//    vibrate request while that channel still has time left (OpenXrInput.cpp
//    TBXR_Vibrate). The quake writes BOTH channels every frame -- a hand at
//    zero amplitude still gets a 10 ms request -- AFTER that frame's haptics
//    update and BEFORE the next tic runs. So while any rumble is running,
//    every 150 ms missile buzz on either hand arrives at a busy channel and
//    is dropped. That is why this is a ROUTE, not a layer: with rumble on,
//    every event here -- lock, launch, ramp, catch -- is a spike in the
//    rumble's own amplitude, and the missile buzz is never fired.
//
// THE PRICE, stated: the same lockout applies to everyone else's buzz. While
// our rumble runs, a weapon's own fire buzz is dropped too. So the rumble runs
// only while it means something -- a lock, a flight, a spike, a strained
// carry -- and is silent the rest of the time, including while you merely
// carry something that is following your hand without a fight.
//
// View shake: r_quakeintensity defaults to 0 in VR (r_utility.cpp:116). A user
// who raised it sees a sub-unit offset at full amplitude (4 x amp/3.2 units).
// And a user who zeroed vr_quake_haptic_level feels nothing, which script
// cannot detect -- the menu offers the pulse route for that player.
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

// KEPT ONLY SO AN OLD SAVEGAME LOADS. The grab's sounds were played from this
// actor (two-second life); a save taken in that window names the class, and a
// class missing from a save is a load failure. Nothing spawns it any more.
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
		TNT1 A 1;
		Stop;
	}
}

// The rumble's quake spot. Silent, inert, kept for the level and moved onto the
// player each tic it is used. One actor, so one quake source, so the two hands'
// amplitudes always come from one place and never fight.
class RSQDG_RumbleSpot : Actor
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
		TNT1 A -1;
		Stop;
	}
}

class RSQDG_Feel : EventHandler
{
	// ---- the rumble ----------------------------------------------------------
	//
	// Spikes are written into a short per-hand timeline of future tics; each tic
	// the head of the line is maxed with the continuous level and the line
	// shifts. So two events that overlap make the stronger shape, never a sum
	// that clips, and a heavy catch can be two hits with a gap between.
	const LINE = 10;
	private double tline[20];      // [hand * LINE + tic]
	private Actor rumbleSpot;
	private double lastAmp[2];    // what was sent last tic, for the probe

	// One quake per tic carries both hands. 17.5 makes the wave's phase pi
	// across a tic: never negative (see the header).
	const WAVE_MULT   = 17.5;
	const AMP_TO_QUAKE = 1.0 / 3.2;
	// Generous on purpose: the spot is placed before the player moves this
	// tic and tested in 2D, and with falloff 0 a wider radius costs nothing
	// -- at 24 a fast mover or a teleport tic dropped out of it (review).
	const TREMOR_RADIUS = 64;
	// ---- the rhythm scheduler ----------------------------------------------
	//
	// Priorities, so an important tick is QUEUED rather than lost to a busy
	// channel, and a ramp tick never delays a catch.
	const PRI_RAMP    = 1;
	const PRI_LOCK    = 2;
	const PRI_LAUNCH  = 3;
	const PRI_RELEASE = 3;
	const PRI_CATCH   = 4;

	// THE CHANNEL IS BUSY FOR 150 ms OF REAL TIME, not for a number of tics:
	// the runtime counts the buzz down per rendered frame, and a Quest that
	// runs two tics in one frame to catch up gets six tics through in well
	// under 150 ms -- a tic-counted window would send the queued tick into a
	// channel that is still busy, and the runtime would drop it. So the window
	// is wall-clock (MSTime, present in every 17.x engine pk3), with a small
	// margin. Haptics are local, so wall time cannot desync anything.
	const BUSY_MS = 165;

	private uint busyUntil[2];
	private int pendPri[2];
	private int pendCount[2];
	private int lastRamp[2];

	static RSQDG_Feel Get()
	{
		return RSQDG_Feel(EventHandler.Find("RSQDG_Feel"));
	}

	// ---- haptics -----------------------------------------------------------

	private bool HapticsOn(PlayerInfo p)
	{
		return RSQDG_Reach.Flag("rsqdg_haptics", p, true);
	}

	// With cl_capfps on the renderer's tic fraction is pinned at 1.0
	// (r_utility.cpp), so the wave's phase is sin(0) every frame and the rumble
	// is silent. Fall back to the pulse rather than say nothing (review).
	private bool RumbleOn(PlayerInfo p)
	{
		if (!RSQDG_Reach.Flag("rsqdg_rumble", p, true)) return false;
		let cap = CVar.FindCVar("cl_capfps");
		return !(cap && cap.GetBool());
	}

	// A shape on one hand's timeline: `amp` for `tics`, starting `at` tics from
	// now. Maxed in, never added.
	void Spike(int hand, double amp, int tics, int at = 0)
	{
		if (hand != 0 && hand != 1) return;
		for (int i = at; i < at + tics && i < LINE; i++)
		{
			int k = hand * LINE + i;
			if (amp > tline[k]) tline[k] = amp;
		}
	}

	// What was sent to each hand this tic (0..1 at default level) -- for the
	// rig probe and for anything that wants to show it.
	double Amp(int hand) const { return (hand == 0 || hand == 1) ? lastAmp[hand] : 0; }

	// THE EMITTER. One call per tic, both hands, or none. Which controller is
	// "main" is the engine's own rule (vr_control_scheme 10+ is left-handed), so
	// a left-handed player's lock buzzes the hand that locked.
	private void Emit(PlayerPawn pmo, double amp0, double amp1)
	{
		lastAmp[0] = amp0;
		lastAmp[1] = amp1;
		if (amp0 <= 0.001 && amp1 <= 0.001) return;   // the last quake dies next tic

		if (!rumbleSpot)
		{
			rumbleSpot = Actor.Spawn("RSQDG_RumbleSpot", pmo.Pos);
			if (!rumbleSpot) return;
		}
		rumbleSpot.SetOrigin(pmo.Pos, false);

		let cs = CVar.FindCVar("vr_control_scheme");
		bool leftHanded = cs && cs.GetInt() >= 10;
		double right = leftHanded ? amp1 : amp0;
		double left  = leftHanded ? amp0 : amp1;

		rumbleSpot.A_QuakeEx(
			clamp(left, 0.0, 1.0) * AMP_TO_QUAKE,     // X -> left controller
			clamp(right, 0.0, 1.0) * AMP_TO_QUAKE,    // Y -> right controller
			0,                                        // Z: no haptic, only shake
			2,                                        // see header: always countdown 1 at draw
			0, TREMOR_RADIUS, "", QF_WAVE,
			WAVE_MULT, WAVE_MULT, 1);
	}

	private void Fire(int hand, PlayerPawn pmo)
	{
		if (!pmo) return;
		pmo.SpawnPlayerMissile("RSQDG_Buzz", pmo.angle, noautoaim: true,
			aimflags: (hand == 1) ? ALF_ISOFFHAND : 0);
		busyUntil[hand] = MSTime() + BUSY_MS;
	}

	// Ask for `count` ticks at this priority. Sent now if the channel is free;
	// otherwise queued -- and a queued request only ever goes UP in priority, so
	// a catch waiting behind a ramp tick is never downgraded by the next ramp.
	void Pulse(int hand, int pri, int count = 1)
	{
		if (hand != 0 && hand != 1) return;
		let p = players[consoleplayer];
		if (!p || !p.mo || !HapticsOn(p)) return;

		// THE RUMBLE ROUTE: the same vocabulary, as amplitude. The pulse's
		// rhythm survives -- a heavy catch is still two hits -- and gains what
		// the pulse never had: a lock is lighter than a catch.
		if (RumbleOn(p))
		{
			switch (pri)
			{
			case PRI_RAMP:    Spike(hand, 0.60, 1); break;   // over the flight's top level
			case PRI_LOCK:    Spike(hand, 0.55, 2); break;
			case PRI_LAUNCH:  Spike(hand, 0.75, 3); break;   // PRI_RELEASE shares 3
			case PRI_CATCH:   Spike(hand, 1.00, 3); break;
			}
			// More hits: same strength, a two-tic gap between them.
			int len = (pri == PRI_RAMP) ? 1 : ((pri == PRI_LOCK) ? 2 : 3);
			for (int i = 1; i < count; i++)
				Spike(hand, (pri == PRI_CATCH) ? 1.0 : 0.75, len, i * (len + 2));
			return;
		}

		if (MSTime() >= busyUntil[hand] && pendCount[hand] == 0)
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

	// ---- THE EVENTS ----------------------------------------------------------
	//
	// Each is also forwarded to RSQDG_Events, so a mod that wants to dress a
	// pull -- ModelSwapper turning a sprite into a model in flight, say -- hears
	// about it without this package naming that mod.

	void OnLock(int hand, Actor a, PlayerInfo p)
	{
		if (!a || !p || !p.mo) return;
		Pulse(hand, PRI_LOCK);
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

		RSQDG_Events.Tell("pull.start", hand, a, true);
	}

	// `a` may be null when catching it used it up and the item is gone.
	void OnCatch(int hand, Actor a, PlayerInfo p, bool used, double heft)
	{
		if (!p || !p.mo) return;

		// TWO TICKS FOR A HEAVY THING. Rhythm is the only dial there is, and
		// a barrel landing in your palm should not feel like a clip landing.
		Pulse(hand, PRI_CATCH, heft >= 0.55 ? 2 : 1);

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
		RSQDG_Events.Tell(what, hand, a, true);
	}

	void OnRelease(int hand, Actor a, bool thrown)
	{
		Pulse(hand, PRI_RELEASE);
		RSQDG_Events.Tell(thrown ? "hold.throw" : "hold.drop", hand, a);
	}

	// A thrown thing landed. Felt in no hand, because it has left the hand, and
	// heard only as whatever it hit (WorldHands plays nothing of its own here).
	void OnImpact(Actor a, PlayerInfo p, double mps, double heft)
	{
	}

	// ---- the continuous level, per hand ------------------------------------
	//
	// Report §8.4's mapping, extended: nothing while merely POINTING (that is
	// constant, and would also lock out every weapon buzz); a low steady
	// rumble while LOCKED, so "I have it" is felt and not only seen; a rumble
	// that BUILDS through the flight, heavier for heavier things; silence in
	// the last stretch so the catch lands on a quiet hand; and while carrying,
	// only STRAIN -- the object held back by a wall or a floor from where the
	// hand wants it. A carry that follows freely is silent.
	private double Level0(int h, PlayerInfo p, RSQDG_Flight fl)
	{
		Actor a = fl ? fl.FlyingActor(h) : null;
		if (a)
		{
			if (fl.Near(h)) return 0;
			double heft = RSQDG_Mass.Heft(a);
			return (0.10 + 0.30 * fl.Progress(h)) * (0.7 + 0.6 * heft);
		}

		let grab = RSQDG_Grab.Get();
		Actor lk = grab ? grab.Locked(h) : null;
		if (lk)
			return clamp(RSQDG_Reach.Num("rsqdg_rumble_lock", p, 0.15), 0.0, 1.0)
				* (0.8 + 0.6 * RSQDG_Mass.Heft(lk));

		let hold = RSQDG_Hold.Get();
		if (hold && hold.HeldBy(h) && RSQDG_Reach.Flag("rsqdg_rumble_carry", p, true))
		{
			// WORLDHANDS' STRAIN HAPTIC (rs_held.zs ShouldBreak): the gap between
			// where the hand wants the object and where it is, as a fraction of
			// the break distance -- nothing under 15%, full strength just as the
			// hold gives -- times 0.6, times a LOGARITHMIC bulk from the mass,
			// clamp(0.5 + 0.9 log10(kg + 1), 0.5, 2): a controller has one motor,
			// and what reads is the ORDER of weights (clip, medikit, barrel).
			double brk = RSQDG_Reach.Num("rsqdg_hold_break", p, 1.5);
			if (brk <= 0) return 0;
			double strain = hold.Strain(h) / brk;
			if (strain <= 0.15) return 0;
			double kg = RSQDG_Mass.Kg(hold.HeldBy(h));
			double bulk = clamp(0.5 + log10(max(kg, 0.0) + 1.0) * 0.9, 0.5, 2.0);
			return clamp(strain * 0.6 * bulk, 0.0, 1.0);
		}
		return 0;
	}

	// ---- per tic: the rumble, the queue, the approach ramp --
	override void WorldTick()
	{
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		let pmo = p.mo;

		let fl = RSQDG_Flight.Get();
		bool rumble = HapticsOn(p) && RumbleOn(p);
		double amp0 = 0, amp1 = 0;
		if (rumble)
		{
			// THE TIMELINE. Head maxed with the continuous level, then shifted
			// on, every tic -- a spike that outlives its event is still owed.
			amp0 = max(Level0(0, p, fl), tline[0]);
			amp1 = max(Level0(1, p, fl), tline[LINE]);
		}
		for (int k = 0; k < 2 * LINE; k++)
			tline[k] = ((k % LINE) == LINE - 1) ? 0.0 : tline[k + 1];
		double gain = clamp(RSQDG_Reach.Num("rsqdg_rumble_gain", p, 1.0), 0.0, 2.0);
		Emit(pmo, amp0 * gain, amp1 * gain);

		for (int h = 0; h < 2; h++)
		{
			// The queue first, so an owed catch tick goes out the first tic
			// the channel is free. Pulse route only: the rumble route never
			// queues, it has amplitude instead.
			if (!rumble && pendCount[h] > 0 && MSTime() >= busyUntil[h] && HapticsOn(p))
			{
				Fire(h, pmo);
				if (--pendCount[h] <= 0) { pendCount[h] = 0; pendPri[h] = 0; }
			}

			Actor a = fl ? fl.FlyingActor(h) : null;
			if (!a) continue;

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
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int h = 0; h < 2; h++)
		{
			busyUntil[h] = 0; pendPri[h] = 0; pendCount[h] = 0; lastRamp[h] = 0;
			lastAmp[h] = 0;
		}
		for (int k = 0; k < 2 * LINE; k++) tline[k] = 0;
		// DESTROYED, not just forgotten: in a hub the level is kept, and a
		// forgotten spot would wait there for a second one to join it.
		if (rumbleSpot) rumbleSpot.Destroy();
		rumbleSpot = null;
	}

	override void WorldLoaded(WorldEvent e)
	{
		// Nothing owed carries across a map.
		for (int h = 0; h < 2; h++)
		{
			busyUntil[h] = 0; pendPri[h] = 0; pendCount[h] = 0; lastRamp[h] = 0;
			lastAmp[h] = 0;
		}
		for (int k = 0; k < 2 * LINE; k++) tline[k] = 0;
		// A savegame brings our spot back with this handler's pointer to it;
		// forgetting it there would leak one spot per load (review). On a
		// fresh map, sweep up any a hub snapshot kept.
		if (!e.IsSaveGame)
		{
			rumbleSpot = null;
			let it = ThinkerIterator.Create("RSQDG_RumbleSpot");
			Actor old;
			while (old = Actor(it.Next())) old.Destroy();
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
