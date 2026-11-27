// ============================================================================
// The two actor bases every generated card class (cards.zs, RSQGO_K_<BD class>) derives from.
//
// WHY AN ACTOR AT ALL. ZScript cannot cancel a spawn: when BD's code spawns "Brutal_FlyingBlood", CheckReplacement can
// only choose WHAT spawns. So one actor still spawns, our card class, and it does all its work in PostBeginPlay, which
// runs on its first tic AFTER the spawner has set its velocity, angle, pitch and target (dthinker.cpp: PostBeginPlay is
// called from the tick loop, not from Spawn). Then it destroys itself before it ever ticks: no movement, no blockmap,
// no sprite, no state machine. Everything BD's actor and its children would have shown becomes particles.
//
// THE TWO TIERS (design 2.1). The actor exists on every machine, so whatever it decides about actors (the floor spot
// it leaves, a BD actor it spawns, screen blood it gives) uses random[RSQGO_Play] and server cvars only. The particles
// it emits are per machine (the manager's xorshift, local camera distance, user cvars).
// ============================================================================

class RSQGO_Card : Actor
{
	int cardNo;                 // index into RSQGO_Data (set by each generated class)
	property CardNo: cardNo;

	Default
	{
		+NOBLOCKMAP
		+NOINTERACTION
		+NOGRAVITY
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		+NOBLOODDECALS
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

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		let m = RSQGO_Manager.Get();
		if (m) m.RunActor(self);
		Destroy();
	}
}

// A hit blood (BD's Brutal_Blood, its colour and saw versions). P_SpawnBlood starts a blood one state in for 9-12
// damage and two states in for under 9 (p_mobj.cpp P_SpawnBlood, "advance"), which in BD skips the states that come
// first (Brutal_Blood's SuperGoreMistTiny, SawBlood's saw check). Our Spawn sequence has three states, so the engine
// still moves us 1 or 2 in, and PostBeginPlay reads where we stand and skips what BD would have skipped.
class RSQGO_HitBlood : RSQGO_Card
{
	States
	{
	Spawn:
		TNT1 A 1;
	Adv1:
		TNT1 A 1;
	Adv2:
		TNT1 A 1;
		Stop;
	}

	int Advance()
	{
		if (CurState == FindState("Adv2")) return 2;
		if (CurState == FindState("Adv1")) return 1;
		return 0;
	}
}

// A playsim moment BD's blood had a few tics after it spawned, when our card is long gone: the playsim queue spawns one
// of these where BD's blood stood on that tic (QueueActor: saved, the same on every machine). Its angle carries which
// one (a give index, a card number). It acts in PostBeginPlay and is gone on its first tic.
class RSQGO_Deferred : Actor
{
	Default
	{
		+NOBLOCKMAP
		+NOINTERACTION
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

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		let m = RSQGO_Manager.Get();
		if (m && m.Ready()) Act(m, int(angle));
		Destroy();
	}

	virtual void Act(RSQGO_Manager m, int which) {}
}

// The saw's ChainsawHit* / Power*OnVisor: BD's A_RadiusGive after HitSaw's TNT1 A 1, from the blood's place then.
class RSQGO_Giver : RSQGO_Deferred
{
	override void Act(RSQGO_Manager m, int which) { m.DeferredGive(self, which); }
}

// The saw's Chainsaw/Flesh sound and Radius_Quake, on the tic BD's HitSaw makes them.
class RSQGO_SawFx : RSQGO_Deferred
{
	override void Act(RSQGO_Manager m, int which) { m.SawFx(self, which); }
}

// A flying blood's DeathFloor spot, on the tic BD's drop lands: placed through the residue from the drop's box floor
// (RSQGO_Manager.PlaceSpot). Its velocity's x carries the spot's angle (it never moves: gone in PostBeginPlay).
class RSQGO_SpotFrom : RSQGO_Deferred
{
	override void Act(RSQGO_Manager m, int which) { m.PlaceSpot(pos, which, vel.x); }
}
