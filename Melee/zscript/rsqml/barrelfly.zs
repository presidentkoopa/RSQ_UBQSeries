// barrelfly.zs -- THE LAUNCHED BARREL (owner 2026-11-12 05:11: "gun butt shove needs to send barrels flyin like our
// uppercut does. also our uppercut is bullshit it is supposed to send barrels flying. and we may as well have it trigger
// contextual slo mo ... (say 3 seconds or explosion, whichever happens first) and we want them to move at a good bit of
// speed in the air with a nice tumble, even in slowmo ... just have it be sent to the closest enemy").
//
// An uppercut into a barrel, or a gun-butt shove into one (Barrel Launch, rsqml_barrel_launch, on): the barrel is taken
// out of the map and this flies in its place -- the barrel's own sprite, tumbling -- to the monster that hand has painted
// (until 2026-11-27: the nearest living monster the barrel could see), on a low fast arc that leans after it as it moves.
// With none painted it goes where you hit it. It goes off on the first monster, wall, floor or ceiling it meets, or after LIFE: the barrel's own class is
// put back there and blown up with you as the one who did it, so the blast, its damage, its look and your kills are the
// barrel's own (Brutal Doom's, RSQ Grenade's dressing, RSQ Score's Field Goal).
// IN SLOW MOTION IT IS NOT SLOWED: RSQ SlowMo leaves every actor whose class starts "rsq" in real time (its clock.zs
// RealTime), and this is one. The launch asks RSQ SlowMo for a game slow of up to SLOW_MS ("start.barrel", its own
// switch: Barrel Launch Slow-Mo, rsqml_barrel_slowmo, on) and ends it when the barrel goes off ("stop").
// RSQ Distance Grab's Barrel Lock-On, when it holds a lock, still takes an uppercut's barrel to the lock as before.
// Code and one rig run (design/HANDOFF_SESSION_2026-11-12.md); not headset-confirmed.
// 2026-11-27 (owner: "throwing barrels is still all wrong ... can triggers do targeting for barrel throwing or barrel
// punching"): THE TARGET IS THE ONE THE TRIGGER PAINTED, no longer the nearest monster. While the hand that launches it
// is held as a fist (or holds the gun) with its fire held, the monster nearest that hand's aim line is painted
// (gloves.zs PaintTick, the ring is RSQML_PaintMark below) and the barrel flies to it. With nothing painted it flies the
// way it was hit. The speed, the tumble, when it goes off, whose blast it is and the slow motion are as they were.
// 2026-11-27 (owner: "i feel like melee should have throwing barrels, they have punching barrels and gun-butt-shove
// barrels and pistol-whip-to-launch-barrels??"): SENDING A BARREL AT A MONSTER IS ONE THING, THIS ONE. Launch is now
// also called for a barrel thrown from the hand (RSQ Distance Grab carries it and asks RSQML_Service "barrel.throw",
// service.zs; how "throw") and for a pistol whip or a butt strike that meets one (club.zs Strike; how "pistol whip" /
// "butt strike"). All fly the same. Only the launch's own sound differs (below).
class RSQML_FlyingBarrel : Actor
{
	const SPEED = 28.0;        // map units a tic along the floor (about 29 m/s)
	const GRAV = 0.5;          // its own fall, a tic
	const REACH = 1536.0;      // how far a monster may be to be sent to (since 2026-11-27: to be painted, from the hand)
	const LIFE = 105;          // 3 s
	const SPIN = 24.0;         // the tumble, degrees a tic
	const SLOW_MS = 3000;

	class<Actor> cls;
	PlayerPawn by;
	Actor aim;
	int born;

	Default
	{
		Radius 10;
		Height 32;
		+NOINTERACTION
		+NOGRAVITY
		+NOBLOCKMAP
		+DONTSPLASH
		+NOTELEPORT
		+ROLLSPRITE
		+ROLLCENTER
		+INTERPOLATEANGLES
	}
	States { Spawn: TNT1 A -1; Stop; }

	// barrel b, hit by pmo's hand (0 main, 1 off) toward dir (map units, used when that hand has painted no monster).
	// False: not launched. (2026-11-27: Nearest(), "the nearest living monster the barrel sees", is gone.)
	static bool Launch(PlayerPawn pmo, Actor b, Vector3 dir, String how, int hand)
	{
		if (!pmo || !b || b.health <= 0) return false;
		Actor t = RSQML_Gloves.Painted(pmo, hand);
		let f = RSQML_FlyingBarrel(Actor.Spawn("RSQML_FlyingBarrel", b.pos + (0, 0, 12), NO_REPLACE));
		if (!f) return false;
		f.cls = b.GetClass(); f.by = pmo; f.aim = t; f.born = level.maptime;
		f.sprite = b.sprite; f.frame = b.frame; f.scale = b.scale; f.Translation = b.Translation;
		f.A_SetSize(b.radius, b.height);
		f.angle = b.angle;
		Vector3 from = f.pos;
		if (t)
		{
			Vector3 to = t.pos + (0, 0, t.height * 0.5) - from;
			double d = max(1.0, to.xy.Length());
			double tics = max(4.0, d / SPEED);
			f.vel.xy = to.xy / tics;
			f.vel.z = (to.z + 0.5 * GRAV * tics * tics) / tics;
		}
		else
		{
			Vector2 h = dir.xy.Length() > 0.01 ? dir.xy.Unit() : (cos(pmo.angle), sin(pmo.angle));
			f.vel.xy = h * SPEED;
			f.vel.z = 5.0;
		}
		if (RSQML.Debug() > 0)
			Console.Printf("RSQML barrel launch (%s): %s -> %s, vel (%.1f %.1f %.1f)", how, b.GetClassName(), t ? String.Format("the painted %s at %.0f units", t.GetClassName(), b.Distance3D(t)) : "nothing painted: the way it was hit", f.vel.x, f.vel.y, f.vel.z);
		b.bSHOOTABLE = false; b.bSOLID = false;
		b.Destroy();
		// 2026-11-27 (owner: "melee should have throwing barrels"): a THROW hit nothing, so no dust off the floor and no
		// hit sound (rule chosen here; RSQ Distance Grab plays its own throw whoosh); a PISTOL WHIP's launch is the whip's
		// sound (rsqml/whip, club.zs), the butt strike's the shove's as before
		if (how != "throw") RSQML_Spark.Dust(from - (0, 0, 8));
		// the owner's sounds (2026-11-16): an uppercut's launch is the uppercut's, a gun-butt shove's the shove's
		if (how == "uppercut") RSQML_Gloves.HitSound(pmo, 0, RSQML_Gloves.PK_UPPER);
		else if (how == "pistol whip")
		{
			pmo.A_StartSound("rsqml/whip", CHAN_AUTO, CHANF_OVERLAP, 1.0);
			if (RSQML.Debug() > 0) Console.Printf("RSQML sound t%d: whip (a barrel)", level.maptime);
		}
		else if (how != "throw")
		{
			pmo.A_StartSound("rsqml/buttshove", CHAN_AUTO, 0, 1.0);
			if (RSQML.Debug() > 0) Console.Printf("RSQML sound t%d: buttshove (a barrel)", level.maptime);
		}
		if (RSQML.SVI("rsqml_barrel_slowmo", 1) != 0)
		{
			let sm = RSQML.Svc("RSQSM_Service");
			if (sm) sm.GetInt("start.barrel", "", SLOW_MS, 0);
		}
		return true;
	}

	override void Tick()
	{
		if (isFrozen()) return;
		if (!by || !cls) { Destroy(); return; }
		// it leans after its monster (the speed along the floor kept)
		if (aim && aim.health > 0)
		{
			Vector2 to = aim.pos.xy - pos.xy;
			double d = to.Length(), sp = vel.xy.Length();
			if (d > 1 && sp > 0.5) { Vector2 w = vel.xy * 0.7 + to / d * sp * 0.3; if (w.Length() > 0.01) vel.xy = w.Unit() * sp; }
		}
		vel.z -= GRAV;
		double len = vel.Length();
		FLineTraceData lt;
		if (len > 0.01 && LineTrace(VectorAngle(vel.x, vel.y), len + radius, -atan2(vel.z, max(0.001, vel.xy.Length())), TRF_THRUACTORS, height * 0.5, 0, 0, lt)
			&& lt.HitType != FLineTraceData.TRACE_HitNone)
		{
			Vector3 at = lt.HitLocation - vel / len * radius;
			SetOrigin((at.x, at.y, max(at.z - height * 0.5, floorz)), true);
			Boom("a wall, the floor or the ceiling");
			return;
		}
		SetOrigin(pos + vel, true);
		roll += SPIN;
		let it = BlockThingsIterator.Create(self, radius + 64);
		while (it.Next())
		{
			let a = it.thing;
			if (!a || a.health <= 0 || !RSQML.IsFoe(by, a)) continue;
			if ((a.pos.xy - pos.xy).Length() > radius + a.radius + 6) continue;
			if (pos.z > a.pos.z + a.height + 6 || pos.z + height < a.pos.z - 6) continue;
			Boom(String.Format("%s", a.GetClassName()));
			return;
		}
		if (level.maptime - born > LIFE) Boom("its time");
	}

	void Boom(String why)
	{
		let b = Actor.Spawn(cls, pos, NO_REPLACE);
		if (RSQML.Debug() > 0) Console.Printf("RSQML barrel goes off on %s after %d tics at (%.0f %.0f %.0f)", why, level.maptime - born, pos.x, pos.y, pos.z);
		if (b)
		{
			b.target = by;
			let g = RSQML_Gloves.Get();
			if (g) g.NoteKick(b, by.PlayerNumber(), born);
			b.DamageMobj(by, by, b.health * 3 + 100, 'None', DMG_THRUSTLESS);
		}
		let sm = RSQML.Svc("RSQSM_Service");
		if (sm) sm.GetInt("stop", "barrel");
		Destroy();
	}
}

// THE PAINTED TARGET'S RING (2026-11-27, owner: "can triggers do targeting for barrel throwing or barrel punching"): a
// green ring over the monster a held trigger has painted (gloves.zs PaintTick moves it and keeps it alive), the kind
// the ShieldSaw's paint draws. No new art: the Ground Pound ring's last frame (RQRG Q, sparks.zs RSQML_Ring), held.
// It goes by itself two tics after it was last kept (a loaded save holds one nobody keeps: the handler is not saved).
class RSQML_PaintMark : Actor
{
	int seen;
	Default
	{
		RenderStyle "AddShaded"; Radius 1; Height 1; Scale 0.22; Alpha 0.95;
		+NOINTERACTION +NOBLOCKMAP +BRIGHT +NOGRAVITY +NOTONAUTOMAP +DONTSPLASH +NOTELEPORT +FORCEXYBILLBOARD
	}
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		SetShade(0x20FF40);
		seen = level.maptime;
	}
	override void Tick()
	{
		if (level.maptime - seen > 1) Destroy();
	}
	States { Spawn: RQRG Q -1 Bright; Stop; }
}
