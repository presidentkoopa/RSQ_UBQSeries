// RSQ Score -- THE LIFE CRATE (owner 2026-11-07, design/NEAR_DEATH.md "v3 getting up, and the life crate"; the Boss's 1UP,
// owner 2026-11-16, design/BANNERS_AND_HUD.md 6). Score owns it; other mods spawn it BY NAME only when Score is loaded
// (RSQ Miniboss: a Boss win drops it where the miniboss died). Touching it is +1 Score life, with an earned life's cue and
// the +1UP banner (handler.zs RunRewardCue).
//   LOOK      the Berserk pack (PSTR; Brutal Doom's voxel when BD_VoxelPack is loaded) in Score's gold (TRNSLATE
//             RSQSC_LifeGold), full-bright, a gold light, and a beam of light into the sky (a column of rising particles).
//   STAYS     until it is picked up (2026-11-16: no 10 s timer, no red fade). Gold all its life. RSQ Distance Grab can pull
//             it (its rule service, "grab.rule", by name, as RSQ SlowMo's v2 crate was).
//   FLOATS    BACK UP if it falls where the player cannot reach it (2026-11-16). The test (my choice, kept simple): HOME is
//             where it was spawned (the miniboss's death spot) and the floor there; once its own z is more than FALL_MAX
//             (64) units below that floor -- a pit, the foot of a ledge, a lift that went down -- or it is outside the
//             level, it floats straight back up to HOME at FLOAT_SPEED a tic (through anything: a pickup has no business
//             colliding on the way) and hovers there, gravity off, until it is taken. A boss that dies in the air over a
//             pit gives a HOME floor that is the pit's own: then nothing floats (said, not solved).
class RSQ_ScoreLifeCrate : Inventory
{
	int born;
	Vector3 home;              // where it was spawned (the miniboss's death spot)
	double homeFloor;          // the floor there
	bool floating, hovering;
	const FALL_MAX = 64.0;     // this far below HOME's floor counts as out of reach
	const FLOAT_SPEED = 6.0;   // units a tic on the way back up
	Default
	{
		Inventory.PickupMessage "";
		Inventory.PickupSound "misc/p_pkup";
		Tag "Score Life";
		Radius 16;
		Height 24;
		+DONTGIB
		+BRIGHT
		+INVENTORY.NEVERRESPAWN
		+INVENTORY.ALWAYSPICKUP
		+NOTIMEFREEZE
	}
	States
	{
	Spawn:
		PSTR A -1;
		Stop;
	}
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		born = level.maptime;
		home = pos;
		homeFloor = floorz;
		A_SetTranslation('RSQSC_LifeGold');
		A_AttachLight('RSQSC_Life', DynamicLight.PointLight, Color(255, 255, 200, 48), 96, 0, 0, (0, 0, 20));
		GrabRule();
		if (RS_ScoreHandler.DebugOn()) Console.Printf("RS_Score: the life crate at %.0f %.0f %.0f (floor %.0f): stays until taken, floats back up from more than %.0f below", pos.x, pos.y, pos.z, homeFloor, FALL_MAX);
	}
	static void GrabRule()
	{
		let it = ServiceIterator.Find("RSQDG_GrabRuleService");
		Service s;
		while (s = it.Next())
		{
			if (s.GetInt("grab.hello", "", 0, 0, null, '') != 1) continue;
			s.GetInt("grab.rule", "RSQ_ScoreLifeCrate", 0, 0, null, 'RSQ_Score');
			s.GetInt("grab.weight", "RSQ_ScoreLifeCrate", 0, 2.0, null, '');
			return;
		}
	}
	override void Tick()
	{
		Super.Tick();
		if (Owner || bDestroyed) return;
		// OUT OF REACH: back up to where the miniboss died
		if (!floating && !hovering && (pos.z < homeFloor - FALL_MAX || !level.IsPointInLevel(pos)))
		{
			floating = true;
			bNOGRAVITY = true;
			vel = (0, 0, 0);
			if (RS_ScoreHandler.DebugOn()) Console.Printf("RS_Score: the life crate fell out of reach (z %.0f, its home's floor %.0f): floating back up", pos.z, homeFloor);
		}
		if (floating)
		{
			Vector3 to = (home.xy, max(home.z, homeFloor));
			Vector3 d = level.Vec3Diff(pos, to);
			double l = d.Length();
			vel = (0, 0, 0);
			if (l <= FLOAT_SPEED) { SetOrigin(to, true); floating = false; hovering = true;
				if (RS_ScoreHandler.DebugOn()) Console.Printf("RS_Score: the life crate is back where the miniboss died (%.0f %.0f %.0f), hovering", pos.x, pos.y, pos.z); }
			else SetOrigin(pos + d / l * FLOAT_SPEED, true);
		}
		else if (hovering) vel = (0, 0, 0);
		// THE BEAM: a column of gold motes rising fast from it into the sky
		Color pc = Color(255, 255, 200, 48);
		for (int i = 0; i < 2; i++)
			A_SpawnParticle(pc, SPF_FULLBRIGHT, 40, 5, 0, frandom[RSSCLc](-2, 2), frandom[RSSCLc](-2, 2), 20 + i * 12, 0, 0, 14, 0, 0, 0, 0.9);
	}
	override bool TryPickup(in out Actor toucher)
	{
		if (!toucher || !toucher.player) return false;
		let tr = RS_ScoreTracker(toucher.FindInventory("RS_ScoreTracker"));
		if (!tr) return false;
		// +1 life, given as an earned life is (RS_ScoreService "givelife": the cue, the pips' pop, the +1UP banner; no slow
		// motion: that is for a life Score's own target pays)
		tr.extraLives    += 1;
		RS_ScoreHandler.RankLife(true);   // lives feed Rank (handler.zs)
		tr.rewardTic      = level.maptime;
		tr.rewardKind     = 1;
		tr.pendingLives  += 1;
		tr.rewardLifeTic  = max(1, level.maptime);
		tr.lifeFrom       = Pos + (0, 0, Height * 0.5);    // the 1UP world word rises from here (handler.zs RunRewardCue)
		tr.lifeFromTic    = max(1, level.maptime);
		if (RS_ScoreHandler.DebugOn()) Console.Printf("RS_Score: the life crate taken by player %d after %d tics: +1 life -> %d", toucher.PlayerNumber(), level.maptime - born, tr.extraLives);
		GoAwayAndDie();
		return true;
	}
}
