// THE WHIP (rsqgr_whip 1; off by default). The same two binds crack a whip instead of
// firing the claw: a short lash from the hand along where it points that, at the
// moment it cracks, hits the first thing within reach -- damage, and it is knocked
// into its Pain state whatever its pain chance, which breaks off an attack it was
// winding up (the closest thing to a disarm a Doom monster has: there is nothing to
// knock out of its hands, a monster's attack is a state, not an item) -- or, if the
// tip meets something ABOVE the hand within reach (a ledge, a beam, a ceiling edge),
// it wraps round it and becomes core's rope: swing, reel and release are core's own.
//
// NO EDIT TO CORE. Core's input has no whip in it, so this handler runs after core's
// on the same network event (rsqgr_fire, registered after RSQGR_Input in MAPINFO):
// when the whip is on, the claw core just fired (phase FLY, age 0) is taken back
// before it moves a unit, and the crack starts from the same hand along the same
// line. A snag builds core's hook in core's own LATCH phase through core's own
// Latch(), exactly as a claw that hit that spot would have, so everything after it --
// the swing, the reel, the tap to let go -- is core's code, unchanged.
//
// THE CRACK, in tics (world time is irrelevant: the whip is the player's, real time):
//   0..3   the lash goes out, the rope bowed up and rolling a wave down to the tip
//   4      CRACK: full reach, the hit or the snag, the sound and the spark at the tip
//   5..8   it falls back to the hand
// The whip is drawn with core's rope pieces (RSQGR_Rope), 12 of them, thinner.
class RSQGR_Whip : EventHandler
{
	const NW = MAXPLAYERS * 2;
	const OUT_TICS = 4;
	const BACK_TICS = 4;
	const NLINK = 12;

	PlayerPawn wby[NW];
	int     wage[NW];          // -1 idle
	Vector3 wdir[NW];
	double  wreach[NW];
	bool    wdone[NW];         // the crack has happened
	Vector3 wtip[NW];          // where the tip got to (the hit or full reach)
	RSQGR_Rope wl[NW * NLINK]; // the drawn whip, NLINK pieces per hand slot
	transient RSQGR_Tracer tracer;

	static RSQGR_Whip Get() { return RSQGR_Whip(EventHandler.Find("RSQGR_Whip")); }

	override void OnRegister()
	{
		for (int i = 0; i < NW; i++) if (!wby[i]) wage[i] = -1;
	}

	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame) return;
		for (int i = 0; i < NW; i++) { wage[i] = -1; wby[i] = null; }
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "rsqgr_fire")) return;
		if (!RSQGR_Util.Flag("rsqgr_whip", false)) return;
		if (e.Player < 0 || e.Player >= MAXPLAYERS || !playeringame[e.Player]) return;
		int hand = e.Args[0] & 1;
		let core = RSQGR_Core.Get();
		let pmo = players[e.Player].mo;
		if (!core || !pmo) return;
		int i = e.Player * 2 + hand;
		let h = core.hooks[i];
		// only a claw core fired on THIS press (it has not moved yet)
		if (!h || h.phase != RSQGR_Hook.PH_FLY || h.phaseAge != 0 || h.traveled != 0) return;
		Vector3 org = h.Pos, dir = h.dir;
		h.A_StopSound(CHAN_BODY);
		h.A_StopSound(CHAN_WEAPON);
		h.Destroy();
		core.hooks[i] = null;
		Start(i, pmo, org, dir);
	}

	void Start(int i, PlayerPawn pmo, Vector3 org, Vector3 dir)
	{
		wby[i] = pmo;
		wage[i] = 0;
		wdir[i] = dir;
		wreach[i] = max(32.0, RSQGR_Util.Num("rsqgr_whip_reach", 192));
		wdone[i] = false;
		wtip[i] = org + dir * wreach[i];
		String s = RSQGR_Looks.Sound('lash');
		if (s != "") pmo.A_StartSound(s, CHAN_AUTO, 0, 0.8);
		if (RSQGR_Util.Flag("rsqgr_debug", false))
			Console.Printf("T_GRW %d start reach %.0f dir (%.2f %.2f %.2f)", i, wreach[i], dir.x, dir.y, dir.z);
	}

	override void WorldTick()
	{
		for (int i = 0; i < NW; i++)
		{
			if (wage[i] < 0) continue;
			let pmo = wby[i];
			if (!pmo || pmo.Health <= 0) { Halt(i); continue; }
			int hand = i & 1;
			Vector3 org = RSQGR_Util.HandPos(pmo, hand);
			// the lash follows the hand: a whip goes where your wrist sends it
			if (RSQGR_Util.PoseGood(pmo, hand))
				wdir[i] = RSQGR_Util.MapDir(RSQGR_Util.HandYaw(pmo, hand), RSQGR_Util.HandPitch(pmo, hand));
			if (wage[i] == OUT_TICS && !wdone[i]) Crack(i, pmo, hand, org);
			if (wage[i] < 0) continue;     // the crack snagged: core has it now
			Draw(i, org);
			if (++wage[i] > OUT_TICS + BACK_TICS) Halt(i);
		}
	}

	RSQGR_Tracer GetTracer()
	{
		if (!tracer) tracer = new("RSQGR_Tracer");
		return tracer;
	}

	private void Crack(int i, PlayerPawn pmo, int hand, Vector3 org)
	{
		wdone[i] = true;
		let tr = GetTracer();
		tr.shooter = pmo;
		Vector3 dir = wdir[i];
		bool hitAny = tr.Trace(org, level.PointInSector(org.xy), dir, wreach[i], TRACE_HitSky, RSQGR_Tracer.WALLMASK, false, pmo);
		int ht = hitAny ? tr.Results.HitType : TRACE_HitNone;
		Vector3 at = hitAny ? tr.Results.HitPos : org + dir * wreach[i];
		wtip[i] = at;
		bool dbg = RSQGR_Util.Flag("rsqgr_debug", false);

		if (ht == TRACE_HitActor && tr.Results.HitActor)
		{
			let v = tr.Results.HitActor;
			int dmg = RSQGR_Util.Opt("rsqgr_whip_damage", 12);
			int hp0 = v.Health;
			if (dmg > 0) RSQGR_Perks.Hurt(v, pmo, pmo, dmg, 'Melee');   // the hook's own damage (perks.zs)
			bool stunned = false;
			if (v && v.Health > 0 && v.bISMONSTER && RSQGR_Util.Flag("rsqgr_whip_stun", true))
			{
				State pain = v.FindState("Pain");
				if (pain && !v.InStateSequence(v.CurState, pain)) { v.SetState(pain); stunned = true; }
				else stunned = pain != null;
			}
			Sound2(pmo, at, 'hitflesh');
			RSQGR_Looks.Spark(at, 'flesh');
			if (dbg) Console.Printf("T_GRW %d CRACK hit %s at %.0f units: hp %d -> %d, pain %d",
				i, v ? v.GetClassName() : 'gone', tr.Results.Distance, hp0, v ? v.Health : 0, stunned);
			return;
		}
		Sound2(pmo, at, 'crack');
		RSQGR_Looks.Spark(at, 'crack');
		if (ht != TRACE_HitNone && ht != TRACE_HitActor && at.z > org.z + RSQGR_Util.Num("rsqgr_whip_above", 16)
			&& RSQGR_Util.Flag("rsqgr_whip_snag", true))
		{
			if (Snag(i, pmo, hand, at, dir, tr))
			{
				if (dbg) Console.Printf("T_GRW %d CRACK snagged at %.0f units, %.0f above the hand -> core's rope", i, tr.Results.Distance, at.z - org.z);
				return;
			}
		}
		if (dbg) Console.Printf("T_GRW %d CRACK %s at %.0f units", i, ht == TRACE_HitNone ? "in the air" : "on geometry (not above: no snag)", hitAny ? tr.Results.Distance : wreach[i]);
	}

	// One sound at the tip: a tiny actor carries it there for its length.
	private void Sound2(PlayerPawn pmo, Vector3 at, Name what)
	{
		String s = RSQGR_Looks.Sound(what);
		if (s == "") return;
		let c = Actor.Spawn("RSQGR_WhipTip", at, NO_REPLACE);
		if (c) c.A_StartSound(s, CHAN_VOICE);
	}

	// Core's hook, built as a claw that hit this spot would have been (core.zs Fly's
	// geometry branch), then handed to core's own Latch().
	private bool Snag(int i, PlayerPawn pmo, int hand, Vector3 at, Vector3 dir, RSQGR_Tracer tr)
	{
		let core = RSQGR_Core.Get();
		if (!core || core.hooks[i]) return false;
		let h = RSQGR_Hook(Actor.Spawn("RSQGR_Hook", at, NO_REPLACE));
		if (!h) return false;
		h.owner = pmo;
		h.hand = hand;
		h.dir = dir;
		h.speed = max(4.0, RSQGR_Util.Num("rsqgr_speed", 40));
		h.range = max(64.0, RSQGR_Util.Num("rsqgr_range", 1024));
		h.angle = atan2(dir.y, dir.x);
		h.traveled = tr.Results.Distance;
		h.anchor = at - dir * 1.0;
		h.hitDir = dir;
		h.SetOrigin(h.anchor, true);
		h.anchorSec = tr.Results.HitSector;
		h.anchorPlane = 0;
		int ht = tr.Results.HitType;
		if (!tr.Results.ffloor && h.anchorSec)
		{
			if (ht == TRACE_HitCeiling) { h.anchorPlane = 2; h.planeOfs = h.anchor.z - h.anchorSec.ceilingplane.ZatPoint(h.anchor.xy); }
			else if (ht == TRACE_HitFloor) { h.anchorPlane = 1; h.planeOfs = h.anchor.z - h.anchorSec.floorplane.ZatPoint(h.anchor.xy); }
		}
		core.hooks[i] = h;
		core.Latch(h, i);
		Halt(i);
		return true;
	}

	// The rope: hand to tip, bowed up and rolling a wave toward the tip while it goes
	// out, straightening at the crack, sagging on the way back.
	private void Draw(int i, Vector3 org)
	{
		int age = wage[i];
		double ext;
		if (age <= OUT_TICS) ext = double(age) / OUT_TICS;
		else ext = 1.0 - double(age - OUT_TICS) / BACK_TICS;
		ext = clamp(ext, 0.05, 1.0);
		Vector3 tip = wdone[i] ? org + (wtip[i] - org) * ext : org + wdir[i] * wreach[i] * ext;
		Vector3 span = tip - org;
		double len = span.Length();
		Vector3 side = (-wdir[i].y, wdir[i].x, 0);
		if (side.Length() < 0.01) side = (1, 0, 0);
		side = side.Unit();
		double bow = (age <= OUT_TICS) ? len * 0.25 * (1.0 - double(age) / OUT_TICS) : len * 0.08;
		double phase = double(age) / OUT_TICS;
		// core's rope pieces (RSQGR_Rope, a tube along +Z): placed and aimed as core's DrawRope does
		double w = RSQGR_Util.Num("rsqgr_rope_width", 0.6) * 0.7;   // a whip is thinner than the hook's rope
		Vector3 pa = org;
		for (int k = 0; k < NLINK; k++)
		{
			double u = (k + 1.0) / NLINK;
			Vector3 pb = org + span * u;
			pb.z += bow * sin(180.0 * u) * (age <= OUT_TICS ? 1.0 : -1.0);
			pb += side * (len * 0.06 * u * sin(360.0 * (1.5 * u - phase)));
			RSQGR_Rope r = wl[i * NLINK + k];
			bool fresh = false;
			if (!r)
			{
				r = RSQGR_Rope(Actor.Spawn("RSQGR_Rope", pa, NO_REPLACE));
				wl[i * NLINK + k] = r;
				fresh = true;
			}
			if (!r) continue;
			if (!fresh) r.SetOrigin(pa, true);
			Vector3 m = pb - pa;
			Vector3 room = (m.x, m.y, m.z * RSQGR_Util.PIXELSTRETCH);
			double l = room.Length();
			r.angle = atan2(room.y, room.x);
			r.pitch = -atan2(room.z, room.xy.Length()) + 90;
			r.scale = (w, l / RSQGR_Rope.ROPE_L);
			if (fresh) r.ClearInterpolation();
			pa = pb;
		}
	}

	void Halt(int i)
	{
		wage[i] = -1;
		wby[i] = null;
		for (int k = 0; k < NLINK; k++)
		{
			if (wl[i * NLINK + k]) wl[i * NLINK + k].Destroy();
			wl[i * NLINK + k] = null;
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int i = 0; i < NW; i++) if (wage[i] >= 0) Halt(i);
	}
}

// Carries the crack's sound at the whip's tip, then goes.
class RSQGR_WhipTip : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+NOTONAUTOMAP
	}
	States
	{
	Spawn:
		TNT1 A 90;
		Stop;
	}
}
