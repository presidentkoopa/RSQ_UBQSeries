version "4.14"
// TEST ONLY (rig): the dying-body census (rcf_census.py writes zscript.txt from this and the class table).
// For each tierable BD22 / XMVE class: one monster a cell on the arena (rcf_arena.py), one cell per death its
// DECORATE has (Death.<type>), plus two plain deaths and one gib; each cell its own colour through RSQ Monsters' own
// tier change (the colours cycle, a pass moves them on by 5). All killed in the same tic with that damage type
// (DMG_FORCED), then every actor on the arena is looked at five times (4 to 140 tics after): what it shows.
//   ART      holds the colour, drawn from the painted art
//   TINT-L   holds the colour, shows the tint: its sprite has art in this colour, this lump has none
//   TINT-S   holds the colour, shows the tint: its sprite has no art in this colour at all
//   OTHER    holds the colour, wears another translation (a flash, a Champions tint, its own)
//   MISS     a body or a piece (not blood, fire, smoke, effects or pickups by RSQ Monsters' own name rule) holding NO colour
//   LIVE-*   a live monster (an Abyss rise, a summon): with or without colour
//   OWNART   keeps its own look by the name rule, but its sprite has painted art (a body taken for an effect?)
//   +WRONG   holds a colour other than the cell it lies in (within 120 units of its centre; ~far: further, not judged)
class RCC_Census : EventHandler
{
	static const String TAB[] = {
$TABLE$
	};
	// Legion of Bones' classes (another mod in his order: it raises its own undead out of corpses), taken away
	static const String LOB[] = { "Abhorrent", "AbhorrentShot", "AbhorrentShotTrail", "AbhorrentSpawn", "AbhorrentSpawner", "Arachnobone", "ArachnoboneShot", "ArachnoboneSpawn", "ArachnoboneSpawner", "Balrog", "BalrogBall", "BalrogBuffEffectSpawner", "BalrogFire", "BalrogFireBuffEffect", "BalrogFireGiver", "BalrogFireSpawner", "BalrogSpawn", "BalrogSpawner", "BloodSpitTrail", "Bone", "Bone1", "Bone2", "BoneGib", "CacoLich", "CacoLichBall", "CacoLichFlame", "CacoLichSpawn", "CacoLichSpawner", "ChaingunnerSkull", "ConqCountdown", "ConqCube", "ConqCubeShot", "ConqMiniNuke", "ConqNuke", "ConqRailPow", "ConqRailShot", "ConqRailTrail", "ConqSpawnCube", "Conqueror", "ConquerorSpawn", "ConquerorSpawner", "DragonSoul", "DragonSoulFlame", "DragonSoulSpawner", "FakeGhostSpectre", "GhostBlood", "GhostSpectre", "GhostSpectreSpawn", "GhostSpectreSpawner", "GhostSpectreTrail1", "GhostSpectreTrail2", "GhostSpectreTrail3", "GhostSpectreTrail4", "HotHead", "InfightController", "LOBArachnotron", "LOBArchvile", "LOBBaronOfHell", "LOBCacodemon", "LOBChaingunGuy", "LOBDeadDoomImp", "LOBDeadShotgunGuy", "LOBDeadZombieMan", "LOBDemon", "LOBDoomImp", "LOBHellKnight", "LOBLostSoul", "LOBMancubus", "LOBRevenant", "LOBShotgunGuy", "LOBSpectre", "LOBSpiderMastermind", "LOBZombieMan", "MonsterTracer", "Painbringer", "PainbringerSpawner", "PhantomRevenant", "PhantomRevenant2", "PhantomRevenantSpawn", "PhantomRevenantSpawner", "PhantomRevenantTrail1", "PhantomRevenantTrail2", "PhantomRevenantTrail3", "PhantomRevenantTrail4", "PhantomRevenantTrail5", "PhantomRevenantTrail6", "PowerBalrogFireBuff", "PowerBalrogFireBuffGiver", "Reaper", "ReaperBloodSkull", "ReaperBloodSkullGiver", "ReaperBloodSkullSpawner", "ReaperBloodSpit", "ReaperFire", "ReaperFireStart", "ReaperFireTrail", "ReaperSpawn", "ReaperSpawner", "ReaperStealthFire", "RetroSkeleton", "RetroSkeletonFlame", "RetroSkeletonSpawner", "SKFlameTrail", "SkeletonDemon", "SkeletonDemonSpawn", "SkeletonDemonSpawner", "SkeletonImp", "SkeletonImpArm", "SkeletonImpBall", "SkeletonImpLeg", "SkeletonImpSpawn", "SkeletonImpSpawner", "SkullBloodDrip", "SkullChaingunner", "SkullChaingunnerSpawn", "SkullChaingunnerSpawner", "SkullChaingunnerTracer", "SkullShotgunner", "SkullShotgunnerSpawn", "SkullShotgunnerSpawner", "SkullShotgunnerTracer", "SkullZombie", "SkullZombieSpawn", "SkullZombieSpawner", "SkullZombieTracer", "SlayerKnight", "SlayerKnightFlame", "SlayerKnightFlame2", "SlayerKnightSpawn", "SlayerKnightSpawner", "SoulBallHoming", "SoulBallNormal", "SoulTrail", "Tracer", "UndeadSpawnFire", "ZombieTracer" };
	Map<Name, int> lobSet; bool lobBuilt;
	bool IsLob(Name n)
	{
		if (!lobBuilt) { lobBuilt = true; for (int i = 0; i < LOB.Size(); i++) lobSet.Insert(Name(LOB[i]), 1); }
		return lobSet.CheckKey(n);
	}
	static const String CN[] = { "", "shipped", "green", "blue", "purple", "cyan", "brown", "yellow", "fireblu", "gray", "red", "abyss", "black", "white" };
	const SP = 288;
	const PER = 12;
	const BLEN = 148;
	Array<Actor> cell;
	Array<double> cx, cy;
	Array<int> ccol;
	Array<String> cdt;
	int first, last, pass, cur, t0, batch;
	bool running;
	Array<String> keys; Array<int> cnt;

	override void WorldTick()
	{
		// Legion of Bones' skeletons (raised out of the corpses) and a Pain Elemental's spat souls are other monsters
		let it = ThinkerIterator.Create("Actor"); Actor a;
		while (a = Actor(it.Next()))
		{
			String cn = a.GetClassName(); cn = cn.MakeLower();
			if (cn.IndexOf("skel") >= 0 || cn.IndexOf("undead") >= 0 || cn.IndexOf("skullzombie") >= 0 || IsLob(a.GetClassName())) a.Destroy();
		}
		if (!running) return;
		int dt = level.maptime - t0;
		if (dt == 0) Lay();
		else if (dt == 3) Colour();
		else if (dt == 6) Kill();
		else if (dt == 10) Snap(0);
		else if (dt == 20) Snap(1);
		else if (dt == 41) Snap(2);
		else if (dt == 76) Snap(3);
		else if (dt == 146) Snap(4);
		else if (dt >= BLEN)
		{
			cur++;
			if (cur > last) { running = false; Wipe(); Console.Printf("RCC end t%d", level.maptime); return; }
			t0 = level.maptime;
			Lay();
		}
	}

	void Wipe()
	{
		let p = players[consoleplayer].mo;
		cell.Clear(); cx.Clear(); cy.Clear(); ccol.Clear(); cdt.Clear();
		let it = ThinkerIterator.Create("Actor"); Actor a;
		while (a = Actor(it.Next()))
			if (a != p && !a.player && !(a is "Inventory" && Inventory(a).owner) && abs(a.pos.x) < 2300 && abs(a.pos.y) < 2300) a.Destroy();
	}

	void Lay()
	{
		Wipe();
		let p = players[consoleplayer].mo;
		p.angle = 225; p.pitch = 0;          // facing the corner: the rig draws next to nothing (the census needs no frames)
		Array<String> f; TAB[cur].Split(f, "|");
		Array<String> d; f[2].Split(d, ",");
		Class<Actor> cls = f[1];
		batch++;
		if (!cls) { Console.Printf("RCC b%d %s|%s no class", batch, f[0], f[1]); return; }
		int n = d.Size();
		for (int i = 0; i < n; i++)
		{
			double x = -1584 + SP * (i % PER), y = -1584 + SP * (i / PER);
			let a = Actor.Spawn(cls, (x, y, 0));
			if (!a) continue;
			a.angle = a.AngleTo(p);
			a.bDORMANT = true;
			cell.Push(a); cx.Push(x); cy.Push(y); ccol.Push(2 + (i + pass * 5) % 12); cdt.Push(d[i]);
		}
		Console.Printf("RCC b%d %s|%s cells %d t%d", batch, f[0], f[1], cell.Size(), level.maptime);
	}

	void Colour()
	{
		// a class that replaces itself at spawn (the cell's actor is gone): the live monster now standing in the cell
		for (int i = 0; i < cell.Size(); i++)
		{
			if (cell[i] && cell[i].health > 0) continue;
			Actor best = null; double bd = 64;
			let it = ThinkerIterator.Create("Actor"); Actor a;
			while (a = Actor(it.Next()))
				if (a.bISMONSTER && a.health > 0 && !a.player && cell.Find(a) == cell.Size() && (a.pos.xy - (cx[i], cy[i])).Length() < bd) { bd = (a.pos.xy - (cx[i], cy[i])).Length(); best = a; }
			if (best) { Console.Printf("RCC b%d cell %d is now %s", batch, i, best.GetClassName()); cell[i] = best; best.bDORMANT = true; }
		}
		for (int i = 0; i < cell.Size(); i++) { let k = cell[i] ? RS_BDKit.Of(cell[i]) : null; if (k && k.entry > 1) { k.entry = 1; k.rung = 1; } }
		for (int i = 0; i < cell.Size(); i++) if (cell[i]) RS_Retier.RequestKit(cell[i], ccol[i], true);
		int ok = 0;
		for (int i = 0; i < cell.Size(); i++) if (cell[i] && RS_BDHue.ColourOf(cell[i]) == ccol[i]) ok++;
		Console.Printf("RCC b%d coloured %d of %d", batch, ok, cell.Size());
	}

	void Kill()
	{
		let p = players[consoleplayer].mo;
		int dead = 0;
		for (int i = 0; i < cell.Size(); i++)
		{
			let a = cell[i];
			if (!a || a.health <= 0) continue;
			a.bDORMANT = false;
			a.angle = a.AngleTo(p);
			if (cdt[i] ~== "XDeath") a.DamageMobj(p, p, a.health + max(1000, a.GetSpawnHealth() * 3), 'None', DMG_FORCED | DMG_NO_ARMOR);
			else a.DamageMobj(p, p, a.health + 1, cdt[i], DMG_FORCED | DMG_NO_ARMOR);
			if (!a || a.health <= 0) dead++;
		}
		Console.Printf("RCC b%d killed %d of %d t%d", batch, dead, cell.Size(), level.maptime);
	}

	static bool BloodKin(Actor a)
	{
		for (class<Actor> k = a.GetClass(); k; k = (class<Actor>)(k.GetParentClass()))
		{
			String kn = k.GetClassName();
			if (kn ~== "Actor") break;
			if (kn ~== "Blood" || kn ~== "SuperGore" || kn ~== "BloodMist") return true;
		}
		return false;
	}

	void Add(String k) { int j = keys.Find(k); if (j == keys.Size()) { keys.Push(k); cnt.Push(1); } else cnt[j]++; }

	void Snap(int s)
	{
		keys.Clear(); cnt.Clear();
		let p = players[consoleplayer].mo;
		let drv = RS_BDArt.Get();
		let it = ThinkerIterator.Create("Actor"); Actor a;
		while (a = Actor(it.Next()))
		{
			if (a == p || a.player || (a is "Inventory" && Inventory(a).owner) || abs(a.pos.x) > 2300 || abs(a.pos.y) > 2300) continue;
			if (a is "RCC_Nothing") continue;
			String nm = a.GetClassName();
			// what is on screen: a sprite with a texture, not invisible, not drawn with no style
			bool vis = a.CurState && !a.bINVISIBLE && a.GetRenderStyle() != STYLE_None && a.alpha > 0.001;
			String lump = "-";
			if (vis)
			{
				TextureID t; bool m; Vector2 sc;
				[t, m, sc] = a.CurState.GetSpriteTexture(0, 0, (0, 0), a.sprite, a.frame);
				if (!t.IsValid()) vis = false; else { lump = TexMan.GetName(t); String l4 = lump.Left(4); l4 = l4.MakeUpper(); if (l4 == "TNT1" || l4 == "NULL") vis = false; }
			}
			// the cell it lies in
			int bi = -1; double bd = 1e9;
			for (int i = 0; i < cx.Size(); i++) { double d = (a.pos.xy - (cx[i], cy[i])).Length(); if (d < bd) { bd = d; bi = i; } }
			int want = bi >= 0 ? ccol[bi] : 0;
			String dt = bi >= 0 ? cdt[bi] : "?";
			int col = RS_BDHue.ColourOf(a);
			bool own = (a is "Inventory") || RS_BDTierHandler.OwnLookName(nm) || BloodKin(a);
			bool live = a.bISMONSTER && a.health > 0;
			String st;
			bool detail = true;
			if (!vis) { st = col ? "hidden-col" : "hidden"; detail = false; }
			else if (live) { st = col ? "LIVE-col" : (RS_BDHue.Known(a) ? "LIVE-entry" : "LIVE-none"); }
			else if (own)
			{
				int mk = drv.SpriteMask(a, a.sprite);
				st = (mk & 0x3FFC) ? "OWNART" : "ownlook";
				if (col) st = st .. "-col";
				detail = (mk & 0x3FFC) != 0;
			}
			else if (!col) st = "MISS";
			else
			{
				int tr = int(a.Translation);
				if (a.picnum.IsValid() && tr == 0) { st = "ART"; detail = false; }
				else if (tr == drv.TintOf(col)) st = (drv.SpriteMask(a, a.sprite) & (1 << col)) ? "TINT-L" : "TINT-S";
				else st = "OTHER";
			}
			if (col && col != want && !live) { if (bd <= 120) st = st .. "+WRONG"; else st = st .. "~far"; detail = true; }
			String why = "";
			if (st == "MISS" || st.Left(5) == "LIVE-" && st != "LIVE-col") why = String.Format(" m:%s t:%s d%d", a.master ? a.master.GetClassName() : '-', a.target ? a.target.GetClassName() : '-', int(bd));
			String k = detail ? String.Format("%s %s %s %s %s%s", st, nm, lump, dt, col ? CN[col] : CN[want], why) : String.Format("%s %s", st, nm);
			Add(k);
		}
		for (int j = 0; j < keys.Size(); j++) Console.Printf("RCCS b%d s%d x%d %s", batch, s, cnt[j], keys[j]);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name ~== "rcc_run")       // Args: first class, last class, pass
		{
			first = e.Args[0]; last = min(e.Args[1], TAB.Size() - 1); pass = e.Args[2];
			cur = first; t0 = level.maptime; running = true;
			Console.Printf("RCC run %d..%d pass %d of %d classes", first, last, pass, TAB.Size());
		}
	}
}
class RCC_Nothing : Actor {}
