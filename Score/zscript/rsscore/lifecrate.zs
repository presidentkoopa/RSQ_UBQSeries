// RSQ Score -- THE LIFE CRATE (owner 2026-11-07, design/NEAR_DEATH.md "v3 getting up, and the life crate"). Score owns it;
// other mods spawn it BY NAME only when Score is loaded (RSQ Miniboss: a Bossfight win drops it where the miniboss died,
// instead of adding the life outright). Touching it is +1 Score life, with an earned life's cue.
//   LOOK      the Berserk pack (PSTR; Brutal Doom's voxel when BD_VoxelPack is loaded) in Score's gold (TRNSLATE
//             RSQSC_LifeGold), full-bright, a gold light, and a beam of light into the sky (a column of rising particles).
//   10 S      it lasts 10 s of real time (its class name starts RSQ: RSQ SlowMo's clock leaves it on real time). In the
//             last 5 s it breathes and fades red, faster and faster (gold -> ember -> red); in RSQ Accessibility's
//             Photosensitive Mode it does not breathe: a steady fade and colour change.
//   STAYS     where it fell (it drops to the floor and never moves toward anyone); RSQ Distance Grab can pull it (its rule
//             service, "grab.rule", by name, as RSQ SlowMo's v2 crate was). Owner-noted risk: over a pit it is lost.
class RSQ_ScoreLifeCrate : Inventory
{
	int born;
	double phase;
	const LIFE = 350;          // 10 s
	const WARN = 175;          // the last 5 s
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
		A_SetTranslation('RSQSC_LifeGold');
		A_AttachLight('RSQSC_Life', DynamicLight.PointLight, Color(255, 255, 200, 48), 96, 0, 0, (0, 0, 20));
		GrabRule();
		if (RS_ScoreHandler.DebugOn()) Console.Printf("RS_Score: the life crate at %.0f %.0f %.0f, %d s", pos.x, pos.y, pos.z, LIFE / TICRATE);
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
		int age = level.maptime - born;
		if (age >= LIFE)
		{
			if (RS_ScoreHandler.DebugOn()) Console.Printf("RS_Score: the life crate ran out (10 s), nobody took it");
			Destroy();
			return;
		}
		// THE BEAM: a column of gold motes rising fast from it into the sky
		bool late = age >= LIFE - WARN;
		double k = late ? (age - (LIFE - WARN)) / double(WARN) : 0.0;     // 0..1 through the last 5 s
		bool photo = RSSC_A11y.Photo();
		int r = 255, g = int(200 * (1 - k) + 40 * k), b = int(48 * (1 - k) + 24 * k);
		double ca = 1.0;
		if (late)
		{
			if (photo) ca = 1.0 - 0.7 * k;
			else
			{
				// faster and faster: 1 breath a second at the start of the warning, 6 at the end
				phase += 360.0 / TICRATE * (1.0 + 5.0 * k * k);
				ca = (0.55 + 0.45 * cos(phase)) * (1.0 - 0.5 * k);
			}
			Name tn = k < 0.34 ? 'RSQSC_LifeGold' : (k < 0.67 ? 'RSQSC_LifeEmber' : 'RSQSC_LifeRed');
			A_SetTranslation(tn);
			A_SetRenderStyle(ca, STYLE_Translucent);
			A_AttachLight('RSQSC_Life', DynamicLight.PointLight, Color(255, r, g, b), int(96 * (0.5 + 0.5 * ca)), 0, 0, (0, 0, 20));
		}
		Color pc = Color(255, r, g, b);
		for (int i = 0; i < 2; i++)
			A_SpawnParticle(pc, SPF_FULLBRIGHT, 40, 5, 0, frandom[RSSCLc](-2, 2), frandom[RSSCLc](-2, 2), 20 + i * 12, 0, 0, 14, 0, 0, 0, ca * 0.9);
	}
	override bool TryPickup(in out Actor toucher)
	{
		if (!toucher || !toucher.player) return false;
		let tr = RS_ScoreTracker(toucher.FindInventory("RS_ScoreTracker"));
		if (!tr) return false;
		// +1 life, given as an earned life is (RS_ScoreService "givelife": the cue, the pips' pop)
		tr.extraLives    += 1;
		tr.rewardTic      = level.maptime;
		tr.rewardKind     = 1;
		tr.pendingLives  += 1;
		tr.rewardLifeTic  = max(1, level.maptime);
		if (RS_ScoreHandler.DebugOn()) Console.Printf("RS_Score: the life crate taken by player %d: +1 life -> %d", toucher.PlayerNumber(), tr.extraLives);
		GoAwayAndDie();
		return true;
	}
}
