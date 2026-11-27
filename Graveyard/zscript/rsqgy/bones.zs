// RSQ Graveyards (RSQ Edition, presidentkoopa) -- THE BONES (owner 2026-11-06, design/DECISIONS_DEATH_BONES.md 1). GPLv3 like
// the rest of this folder. Everything here waits for Legion of Bones (SpacemanStrife, LOB_v1.05) to be loaded, found by its
// class names at run time; without it nothing here does anything. Rig only, not headset-confirmed.
//
// 1. THE BONES BRIDGE (gy_bones, ON since 2026-11-16, owner): Brutal Doom's monsters stay as they are. A few seconds after a Brutal Doom / XMVE
//    monster dies, its Legion of Bones undead counterpart rises from the corpse, LoB's own way (decorate/vanilla.txt, read):
//    - WHICH: the dead monster's class and its parents are looked up in gy_BonesTable (tools/gen_bones_table.py: what each BD /
//      XMVE class replaces, parsed from their DECORATE), else a vanilla parent. That gives one of the 13 monsters LoB raises
//      in its Double Death skills, and LoB's own rising actor for it (RISE below: SkullZombieSpawn ... ReaperSpawn). Lost
//      souls, pain elementals, the Cyberdemon, the Mastermind (and whatever replaces them) stay dead, as in LoB. LoB's own
//      monsters and undead never come here (they rise or die by LoB's own states).
//    - WHEN: LoB's Respawn Delay (LOB_Respawn, LoB's own menu: Instant / 5 / 10 / 15 / 20 s; its states wait 0 / 170 / 345 /
//      520 / 695 tics) after LoB's death animation (25 tics), counted from the death. With Random Delay on (gy_bones_random,
//      2026-11-18) the corpse's own delay instead, one of those five, rolled at the death and kept for its holds.
//    - WHETHER (gy_bones_chance, owner 2026-11-18 50%, 2026-11-27 15%): rolled once at the death; a loser is never queued and its corpse stays.
// 1b. LEGION OF BONES' OWN RAISERS (2026-11-18): its 13 Double Death monsters (and its Spider Mastermind) rise by their own
//    states, which this pack never edits. The same two rolls at their death: a loser is held on its last corpse frame for
//    good (tics -1) the tic its wait begins, before its A_CheckBlock and Respawn; a winner with Random Delay is put on the wait
//    frame its own delay picks (LobTick, gy_Bones.WaitAt). A winner with Random Delay off is not touched.
//    - WHAT STOPS IT (gy_bones_block): 0 "Something On It (LoB)": LoB's A_SetSolid + A_CheckBlock: when the wait ends, if
//      something solid stands on the corpse (a player, a monster) the whole wait starts again (at least a second); after 4
//      such holds it rises at the nearest free spot beside the corpse, or stays dead if none (2026-11-16). 1 "Nothing". Either way a
//      corpse that came back to life meanwhile (an Arch-vile, RSQ Miniboss's Revive Thralls) is left alone.
//    - THE RISING: LoB's: its UndeadSpawnFire burst on the corpse, Doom's teleport sound (misc/teleport), its <Name>Spawn
//      actor (the undead's death frames backwards, facing its target), which spawns the undead with SXF_TRANSFERPOINTERS: it
//      comes for whoever killed the corpse. The Brutal Doom corpse is removed (it got up). A corpse already removed (gibbed
//      away) rises where it lay, as LoB raises gibbed deaths too.
// 2. GRAVES RISE (RSQ Miniboss): RSQ Miniboss asks gy_RSQService "bones.graves" when a miniboss fight calls in (its Graves
//    Rise row, off): the tombstones in the map, or within a radius of the fight's spawn, raise undead the same way.
//    Miniboss says how many a stone. A riser that does not fit looks for a free spot near it and tries again (RiseNear).
// 3. THE HEARTBEAT (RSQ Miniboss): it asks gy_RSQService "stones.pulse" on each beat of RSQ Glow In The Dark's red
//    heartbeat while a miniboss fight waits to be called in: every stone's candle beats with it (gy_Stone.pulse).
//
// NETPLAY: all of it is play code from synced events (WorldThingDied, WorldTick, the server cvars, Miniboss's play-side call);
// nothing reads a hand or the console player.

class gy_Bones play
{
	// the 13 Legion of Bones raises in its Double Death skills (mapinfo.txt), and its rising actor for each (vanilla.txt Respawn)
	static Name Vanilla(int k)
	{
		static const Name VANILLA[] = { 'ZombieMan', 'ShotgunGuy', 'ChaingunGuy', 'DoomImp', 'Demon', 'Spectre', 'Cacodemon',
			'HellKnight', 'BaronOfHell', 'Revenant', 'Fatso', 'Arachnotron', 'Archvile' };
		return (k >= 0 && k < VANILLA.Size()) ? VANILLA[k] : 'None';
	}
	static int VanillaKind(Name cn)
	{
		for (int i = 0; i < 13; i++) if (cn == Vanilla(i)) return i;
		return -1;
	}
	static Name Rise(int k)
	{
		static const Name RISE[] = { 'SkullZombieSpawn', 'SkullShotgunnerSpawn', 'SkullChaingunnerSpawn', 'SkeletonImpSpawn',
			'SkeletonDemonSpawn', 'GhostSpectreSpawn', 'CacoLichSpawn', 'SlayerKnightSpawn', 'BalrogSpawn', 'PhantomRevenantSpawn',
			'AbhorrentSpawn', 'ArachnoboneSpawn', 'ReaperSpawn' };
		return RISE[clamp(k, 0, RISE.Size() - 1)];
	}
	// LoB's own: its living Double Death copies (they rise by their own states) and every undead (a second death is final)
	static bool IsLob(Name cn)
	{
		static const Name LOBS[] = { 'LOBZombieMan', 'LOBShotgunGuy', 'LOBChaingunGuy', 'LOBDoomImp', 'LOBDemon', 'LOBSpectre',
			'LOBLostSoul', 'LOBHellKnight', 'LOBBaronOfHell', 'LOBCacodemon', 'LOBRevenant', 'LOBMancubus', 'LOBArachnotron',
			'LOBArchvile', 'LOBSpiderMastermind', 'SkullZombie', 'SkullShotgunner', 'SkullChaingunner', 'SkeletonImp',
			'SkeletonDemon', 'GhostSpectre', 'DragonSoul', 'SlayerKnight', 'Balrog', 'CacoLich', 'Painbringer', 'PhantomRevenant',
			'PhantomRevenant2', 'Abhorrent', 'Arachnobone', 'Reaper', 'Conqueror', 'RetroSkeleton' };
		for (int i = 0; i < LOBS.Size(); i++) if (cn == LOBS[i]) return true;
		return false;
	}
	// LoB's Respawn Delay, its states' waits in tics (LOB_Respawn 0..4: 0 / 170 / 345 / 520 / 695), and its death animation
	const DEATH_ANIM = 25;
	static int WaitOf(int v)
	{
		static const int WAIT[] = { 0, 170, 345, 520, 695 };
		return WAIT[clamp(v, 0, 4)];
	}
	static int WaitTics() { return WaitOf(CI('LOB_Respawn', 2)); }
	// a corpse's own wait: its rolled delay (0..4, as LOB_Respawn's values), or -1: Legion of Bones' Respawn Delay
	static int WaitFor(int d) { return d < 0 ? WaitTics() : WaitOf(d); }

	// RISE CHANCE and RANDOM DELAY (owner 2026-11-18: "having each and every monster rise is irritating, it should be not
	// guaranteed"). Both are rolled ONCE, at the death (WorldThingDied), for the bridge's corpses and for Legion of Bones' own
	// raisers alike, and never again for that corpse. Random Delay folds in the Legion of Bones respawn-delay randomizer
	// (som_lobrnd, which set LOB_Respawn to random(0, 4) every tic): here each corpse rolls its own 0..4 instead, and
	// LOB_Respawn is never written (it stays what Legion of Bones' menu says).
	// (owner 2026-11-27: "i need these rising graves to be random, i don't need to know. i just need it to be not all the time"):
	// the default 50 -> 15, no tell; a saved 50 moves to 15 once (gy_BonesReplacer.Migrate)
	static int Chance() { return clamp(CI('gy_bones_chance', 15), 0, 100); }
	static bool RollRise()
	{
		int c = Chance();
		if (c >= 100) return true;
		if (c <= 0) return false;
		return random[RSQGY_Rise](0, 99) < c;
	}
	static int RollDelay() { return CI('gy_bones_random', 0) != 0 ? random[RSQGY_Rise](0, 4) : -1; }

	// LEGION OF BONES' OWN RAISERS (decorate/vanilla.txt, read): the 13 its Double Death skills put in (mapinfo.txt), and its
	// Spider Mastermind, which has the same states though no skill uses it. Found by class name (and parents), so this
	// pack still loads without Legion of Bones.
	static bool LobRaiser(Actor a)
	{
		static const Name RAISERS[] = { 'LOBZombieMan', 'LOBShotgunGuy', 'LOBChaingunGuy', 'LOBDoomImp', 'LOBDemon', 'LOBSpectre',
			'LOBCacodemon', 'LOBHellKnight', 'LOBBaronOfHell', 'LOBRevenant', 'LOBMancubus', 'LOBArachnotron', 'LOBArchvile',
			'LOBSpiderMastermind' };
		if (!a) return false;
		for (class<Object> c = a.GetClass(); c; c = c.GetParentClass())
		{
			Name cn = c.GetClassName();
			if (cn == 'Actor') break;
			for (int i = 0; i < RAISERS.Size(); i++) if (cn == RAISERS[i]) return true;
		}
		return false;
	}

	// THEIR WAIT (vanilla.txt, the same in every raiser's Death and XDeath): after the last corpse frame, 4 zero-tic A_JumpIf
	// on LOB_Respawn (== 3, 2, 1, 0, each jumping 5), then that same corpse frame for 175, 175, 175 and 170 tics, then
	// A_SetSolid (1 tic), then A_CheckBlock (0 tics): something on the corpse sends it to DeadLoop / XDeadLoop (back to the
	// first A_JumpIf: the whole wait again), else to Respawn (UndeadSpawnFire, <Name>Spawn with SXF_TRANSFERPOINTERS, the
	// teleport sound, Stop). DeadLoop and XDeadLoop are "Goto Death+N" / "Goto XDeath+N" onto that first A_JumpIf, so the
	// labels find it in every raiser (LOBChaingunGuy's Death sends its block to XDeadLoop: both chains are looked at).
	// Counted from there: 0..3 the jumps, 4..7 the waits, 8 A_SetSolid, 9 A_CheckBlock. LOB_Respawn v lands on 8 - v.
	const WAIT_FIRST = 4;
	const WAIT_SOLID = 8;
	static State WaitBase(Actor a, int chain)
	{
		if (chain == 0) return a.FindState("DeadLoop");
		return a.FindState("XDeadLoop");
	}
	static State Step(State s, int n)
	{
		for (int i = 0; s != null && i < n; i++) s = s.NextState;
		return s;
	}
	// the chain is Legion of Bones' as read (175 ... 170, then the 1-tic A_SetSolid); anything else is never touched
	static bool WaitShaped(State b)
	{
		State w1 = Step(b, WAIT_FIRST);
		State w4 = Step(b, WAIT_SOLID - 1);
		State so = Step(b, WAIT_SOLID);
		if (w1 == null || w4 == null || so == null) return false;
		return w1.Tics == 175 && w4.Tics == 170 && so.Tics == 1;
	}
	// where a raiser's corpse stands: chain * 10 + index (chain 0 its Death's, 1 its XDeath's), -1 not in either
	static int WaitAt(Actor a)
	{
		if (!a) return -1;
		State cur = a.CurState;
		if (cur == null) return -1;
		for (int c = 0; c < 2; c++)
		{
			State s = WaitBase(a, c);
			if (s == null || !WaitShaped(s)) continue;
			for (int i = 0; s != null && i <= WAIT_SOLID + 1; i++)
			{
				if (s == cur) return c * 10 + i;
				s = s.NextState;
			}
		}
		return -1;
	}
	// A CORPSE THAT LOST THE ROLL: held for good on the corpse frame it lies on (each wait frame and the A_SetSolid frame show
	// its last corpse frame), never reaching A_CheckBlock or Respawn. Not solid (A_SetSolid may have run). It is an ordinary
	// still corpse now (tics -1): an Arch-vile can raise it, as any other.
	static void Hold(Actor a)
	{
		a.tics = -1;
		a.bSolid = false;
	}

	static bool LobLoaded() { Name n = 'SkullZombieSpawn'; class<Actor> c = n; return c != null; }
	static int CI(Name n, int d) { let c = CVar.FindCVar(n); return c ? c.GetInt() : d; }
	static bool BridgeOn() { return CI('gy_bones', 0) != 0 && LobLoaded(); }
	static bool Debug() { return CI('gy_bones_debug', 0) != 0; }

	// which of the 13 a monster stands in for: -1 none (it stays dead)
	static int KindOf(Actor a)
	{
		if (!a) return -1;
		for (class<Object> c = a.GetClass(); c; c = c.GetParentClass())
		{
			Name cn = c.GetClassName();
			if (cn == 'Actor') break;
			if (IsLob(cn) || gy_BonesTable.Never(cn)) return -1;
			int t = gy_BonesTable.Kind(cn);
			if (t >= 0) return t;
			t = VanillaKind(cn);
			if (t >= 0) return t;
		}
		return -1;
	}
	// the same for a class by name (RSQ Miniboss's thrall types)
	static int KindOfClass(String s)
	{
		class<Actor> c = s;
		if (!c) return -1;
		for (class<Object> k = c; k; k = k.GetParentClass())
		{
			Name cn = k.GetClassName();
			if (cn == 'Actor') break;
			if (IsLob(cn) || gy_BonesTable.Never(cn)) return -1;
			int t = gy_BonesTable.Kind(cn);
			if (t >= 0) return t;
			t = VanillaKind(cn);
			if (t >= 0) return t;
		}
		return -1;
	}

	// RSQ Miniboss's "bones.graves" (gy_RSQService): stringArg the miniboss fight's thrall classes, comma-separated (each raises
	// the undead its kind maps to; none that LoB raises: Skull Zombies); intArg player * 1000 + how many undead A TOMBSTONE
	// (owner 11-10: one, or one for each thrall);
	// doubleArg the radius round the spot (0 = the whole map); objectArg an actor at the fight's spawn. Returns how many.
	static int GravesAsked(String classes, int packed, double radius, Actor spot)
	{
		if (!LobLoaded() || !spot) return 0;
		let h = gy_BonesHandler(EventHandler.Find("gy_BonesHandler"));
		if (!h) return 0;
		Array<String> cl;
		classes.Split(cl, ",");
		Array<int> kinds;
		for (int i = 0; i < cl.Size(); i++)
		{
			int k = KindOfClass(cl[i]);
			if (k >= 0) kinds.Push(k);
		}
		if (kinds.Size() == 0) kinds.Push(0);
		int pn = packed / 1000, perStone = max(1, packed % 1000);
		Actor tgt = (pn >= 0 && pn < MAXPLAYERS && playeringame[pn]) ? players[pn].mo : null;
		return h.RaiseGraves(spot.pos, radius, perStone, kinds, tgt);
	}

	// LoB's rising at a place: the spawn actor first (the "is something on it" test, when asked), then the fire and the sound.
	// Returns the rising actor, null when something stood there (the caller waits again).
	static Actor RiseAt(int kind, Vector3 at, Actor target, double faceAngle, bool test)
	{
		class<Actor> rc = Rise(kind);
		if (!rc) return null;
		let r = Actor.Spawn(rc, at, ALLOW_REPLACE);
		if (!r) return null;
		if (test && !r.TestMobjLocation()) { r.Destroy(); return null; }
		return Risen(r, target, faceAngle);
	}

	// A GRAVE'S RISER (owner 2026-11-10: a woken stone's undead do rise). The 11-07 rig log (SlowMo v3c.log) had 31 risers
	// planned and only 20 risen when the log ended: the rest kept trying the same spot (what blocked it was not logged).
	// So: the planned spot, else the nearest free spot round it, 3 rings of 8, one to three riser widths out (LoB's rising
	// actors are 20 wide in radius, so 40 and 80 map units), each in clear sight of the planned spot (nothing rises through
	// a wall) and within a step of its floor. Null when none fits (the caller tries again a second later, GRAVE_TRIES in all).
	static Actor RiseNear(int kind, Vector3 at, Actor target, double faceAngle)
	{
		class<Actor> rc = Rise(kind);
		if (!rc) return null;
		let r = Actor.Spawn(rc, at, ALLOW_REPLACE);
		if (!r) return null;
		bool ok = r.TestMobjLocation();
		for (int ring = 1; !ok && ring <= 3; ring++)   // three rings (check 11-16 GY5; was two)
		{
			for (int j = 0; !ok && j < 8; j++)
			{
				double ang = faceAngle + j * 45.0 + ring * 22.5;
				double dist = ring * 2 * r.radius;
				r.SetOrigin(at, false);
				FLineTraceData tr;
				if (r.LineTrace(ang, dist + r.radius, 0, TRF_THRUACTORS, r.height * 0.5, data: tr)) continue;   // a wall between
				Vector2 xy = at.xy + (cos(ang), sin(ang)) * dist;
				double fz = level.PointInSector(xy).floorplane.ZAtPoint(xy);
				if (abs(fz - at.z) > r.MaxStepHeight) continue;
				r.SetOrigin((xy, fz), false);
				ok = r.TestMobjLocation();
			}
		}
		if (!ok) { r.Destroy(); return null; }
		return Risen(r, target, faceAngle);
	}

	// the rising actor is in place: its target and facing, then LoB's fire and Doom's teleport sound
	static Actor Risen(Actor r, Actor target, double faceAngle)
	{
		Vector3 at = r.pos;
		r.target = target;
		r.angle = target ? r.AngleTo(target) : faceAngle;
		Name fn = 'UndeadSpawnFire';
		class<Actor> fc = fn;
		if (fc) Actor.Spawn(fc, at, ALLOW_REPLACE);
		r.A_StartSound("misc/teleport", CHAN_AUTO);
		return r;
	}
}

// THE LOAD ORDER (rig 2026-11-06, read from the packs): Legion of Bones and Brutal Doom both define the classes Tracer and
// MonsterTracer; the pack loaded second has its two renamed and every reference goes to the first. LoB before brutal22test6
// would give Brutal Doom's monsters LoB's weaker bullet (MonsterTracer 3-4 damage, not BD's 8), so LoB loads AFTER Brutal Doom
// and XMVE (its skeletons fire BD's tracer instead). Loaded there, LoB's plain-load spawners (SkullZombieSpawner replaces
// ZombieMan, ... SkeletonImpBall replaces DoomImpBall, LOBDeadZombieMan replaces DeadZombieMan) would win over Brutal Doom's
// and XMVE's replacements and every monster would be a skeleton from the start. WITH THE BONES BRIDGE ON, this static handler
// (static: it must see the map's own things spawn) hands each of those spawns back to the replacement the packs loaded before
// LoB made: the last class defined before LoB that replaces the same thing (Actor.GetReplacee, classes in load order), so
// Brutal Doom's and XMVE's monsters stay and only rise as undead when they die. Bridge off: LoB as it ships. LoB loaded
// before Brutal Doom: nothing to hand back (its spawners already lost), the bridge still works.
class gy_BonesReplacer : StaticEventHandler
{
	transient Array<String> fromCls, toCls;

	// SETTINGS GENERATIONS, each once (gy_cfgver; FindCVar, the values the config saves), the way the series does it (RSQ
	// Wheel's CFG_VERSION / wr_cfgver, ShieldSaw's ssq_cfgver, Gun Cards' rsqgc_cfgver): a saved setting outlives a changed
	// default, so a changed default alone never reaches a config that has the old one.
	// 1 (2026-11-27, owner: "i just need it to be not all the time"): Rise Chance (gy_bones_chance) became 15 that day. A saved
	// value of exactly 50, the old default, is moved to 15; any other value was chosen and is kept. After this step 50 can be
	// chosen again on the menu and stays.
	const CFG_VERSION = 1;
	override void OnRegister() { Migrate(); }
	static void Migrate()
	{
		let ver = CVar.FindCVar("gy_cfgver");
		if (!ver || ver.GetInt() >= CFG_VERSION) return;
		int from = ver.GetInt();
		if (from < 1) MoveChance();
		ver.SetInt(CFG_VERSION);
	}
	// gy_bones_chance is a server setting: a saved game keeps its own and loading it puts that one back, so a game saved
	// before generation 1 is moved the same way when it loads (gy_BonesHandler.WorldLoaded)
	static void MoveChance()
	{
		let ch = CVar.FindCVar("gy_bones_chance");
		if (ch && ch.GetInt() == 50) ch.SetInt(15);
	}

	static bool LobReplacer(Name n)
	{
		static const Name R[] = { 'SkullZombieSpawner', 'SkullShotgunnerSpawner', 'SkeletonImpSpawner', 'SkullChaingunnerSpawner',
			'SkeletonDemonSpawner', 'GhostSpectreSpawner', 'DragonSoulSpawner', 'SlayerKnightSpawner', 'BalrogSpawner',
			'CacoLichSpawner', 'PainbringerSpawner', 'PhantomRevenantSpawner', 'AbhorrentSpawner', 'ArachnoboneSpawner',
			'ReaperSpawner', 'ConquerorSpawner', 'RetroSkeletonSpawner', 'LOBDeadZombieMan', 'LOBDeadShotgunGuy',
			'LOBDeadDoomImp', 'SkeletonImpBall' };
		for (int i = 0; i < R.Size(); i++) if (n == R[i]) return true;
		return false;
	}

	// what replaced it before Legion of Bones did: the last class (load order) that replaces it and is not LoB's
	class<Actor> Before(class<Actor> replacee)
	{
		String rn = replacee.GetClassName();
		for (int i = 0; i < fromCls.Size(); i++) if (fromCls[i] == rn) { class<Actor> c = toCls[i]; return c; }
		class<Actor> best = null;
		for (int i = 0; i < AllActorClasses.Size(); i++)
		{
			class<Actor> c = AllActorClasses[i];
			if (!c || c == replacee || LobReplacer(c.GetClassName())) continue;
			if (Actor.GetReplacee(c) == replacee) best = c;
		}
		fromCls.Push(rn);
		toCls.Push(best ? String.Format("%s", best.GetClassName()) : "");
		if (gy_Bones.Debug()) Console.Printf("RSQ Graveyard bones: Legion of Bones' replacement of %s handed back to %s", rn, best ? String.Format("%s", best.GetClassName()) : String.Format("%s itself", rn));
		return best;
	}

	override void CheckReplacement(ReplaceEvent e)
	{
		if (!e.Replacement || !e.Replacee || !LobReplacer(e.Replacement.GetClassName())) return;
		if (gy_Bones.CI('gy_bones', 0) == 0) return;
		let b = Before(e.Replacee);
		e.Replacement = b ? b : e.Replacee;
	}
}

class gy_BonesHandler : EventHandler
{
	// the corpses waiting (in the save)
	Array<Actor> body;
	Array<Actor> killer;
	Array<double> bx, by, bz, ba;
	Array<int> kind, due;
	Array<bool> grave;          // a grave rise for RSQ Miniboss (no corpse; never held)
	Array<int> tries;           // a grave riser's tries (one that never fits is given up after GRAVE_TRIES); a corpse's holds
	const GRAVE_TRIES = 8;      // a second apart: about 7 s from the first try to the last (owner 11-10: a few, then give up;
	                            // check 11-16 GY5: 5 was too few for a stone raising several, its risers' rings overlap)
	const HOLD_MAX = 4;         // a corpse's holds ("Something On It") before it rises beside what stands on it (GY4)
	const HOLD_MIN = 35;        // a hold waits at least this long (GY12: at Instant it spawned and destroyed every tic)
	Array<int> dly;             // a corpse's own Respawn Delay (Random Delay, rolled at the death: 0..4 as LOB_Respawn), -1
	                            // Legion of Bones' setting. Kept as long as body by SyncDly (a save from before 11-18 has none)

	// LEGION OF BONES' OWN RAISERS (2026-11-18): they rise by their own states. Only a corpse that lost the Rise Chance roll
	// (held for good) or one with its own Random Delay is kept here, until it is held, rises, is revived or is let go (in the save)
	Array<Actor> lobBody;
	Array<int> lobDly;          // LOB_LOST: lost the roll; 0..4 its own delay
	Array<int> lobAt;           // its wait index seen last tic (gy_Bones.WaitAt), or where it was just put; -1 not in its wait yet
	Array<int> lobDeathTic;         // the tic it died
	const LOB_LOST = -2;
	const LOB_DYING = 350;      // not in its wait this long after the death (crushed, an unread death state): let go. The longest
	                            // death before the wait is the Spider Mastermind's, 135 tics
	int cfgSeen;                // the settings generation this game was saved under (in the save; 0 in a game saved before 11-27)

	// a game saved before settings generation 1 puts back its own Rise Chance when it loads: its 50 moves to 15, once
	override void WorldLoaded(WorldEvent e)
	{
		if (e.IsSaveGame && cfgSeen < gy_BonesReplacer.CFG_VERSION) gy_BonesReplacer.MoveChance();
		cfgSeen = gy_BonesReplacer.CFG_VERSION;
	}

	override void WorldThingDied(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || a.player || !a.bIsMonster || !gy_Bones.LobLoaded()) return;
		// Legion of Bones' own raisers: Rise Chance and Random Delay apply whether the bridge is on or off
		if (gy_Bones.LobRaiser(a)) { LobDied(a); return; }
		if (!gy_Bones.BridgeOn()) return;
		int k = gy_Bones.KindOf(a);
		bool dbg = gy_Bones.Debug();
		if (k < 0)
		{
			if (dbg) Console.Printf("RSQ Graveyard bones t%d: %s died: not one LoB raises, stays dead", level.maptime, a.GetClassName());
			return;
		}
		// the killer: the corpse's target. WorldThingDied gives no DamageSource (gzdoom 4.14.3 events.cpp
		// DStaticEventHandler::WorldThingDied sets only Thing and Inflictor), and the damage that kills sets the target.
		Actor who = a.target;
		// ONE UNDEAD A CORPSE (check 11-16 GY3): a corpse revived and killed again before its first wait ended was queued
		// twice and gave two undead. Its earlier entry goes; the wait counts from this death.
		for (int i = body.Size() - 1; i >= 0; i--) if (!grave[i] && body[i] == a) Drop(i);
		// RISE CHANCE (owner 2026-11-18): rolled once, now; a loser is never queued, its Brutal Doom corpse stays for good
		if (!gy_Bones.RollRise())
		{
			if (dbg) Console.Printf("RSQ Graveyard bones t%d: %s died at %.0f %.0f: lost the Rise Chance roll (%d%%), stays dead", level.maptime,
				a.GetClassName(), a.pos.x, a.pos.y, gy_Bones.Chance());
			return;
		}
		// RANDOM DELAY: its own Respawn Delay, rolled now and kept for its holds too
		int d = gy_Bones.RollDelay();
		int wait = gy_Bones.DEATH_ANIM + gy_Bones.WaitFor(d);
		Push(a, who, a.pos, a.angle, k, level.maptime + wait, false, d);
		if (dbg) Console.Printf("RSQ Graveyard bones t%d: %s died at %.0f %.0f: rises as %s in %d tics (%s %d)", level.maptime,
			a.GetClassName(), a.pos.x, a.pos.y, gy_Bones.Rise(k), wait, d >= 0 ? "Random Delay" : "LOB_Respawn", d >= 0 ? d : gy_Bones.CI('LOB_Respawn', 2));
	}

	void Push(Actor a, Actor who, Vector3 at, double ang, int k, int when, bool isGrave, int d = -1)
	{
		SyncDly();
		body.Push(a); killer.Push(who); bx.Push(at.x); by.Push(at.y); bz.Push(at.z); ba.Push(ang);
		kind.Push(k); due.Push(when); grave.Push(isGrave); tries.Push(0); dly.Push(d);
	}

	void Drop(int i)
	{
		SyncDly();
		body.Delete(i); killer.Delete(i); bx.Delete(i); by.Delete(i); bz.Delete(i); ba.Delete(i);
		kind.Delete(i); due.Delete(i); grave.Delete(i); tries.Delete(i); dly.Delete(i);
	}

	// dly came on 11-18: a game saved before it loads with corpses waiting and no dly; theirs is Legion of Bones' setting (-1)
	void SyncDly()
	{
		int want = body.Size();
		int have = dly.Size();
		if (have == want) return;
		dly.Resize(want);
		for (int j = have; j < want; j++) dly[j] = -1;
	}

	void ClearQueues()
	{
		body.Clear(); killer.Clear(); bx.Clear(); by.Clear(); bz.Clear(); ba.Clear(); kind.Clear(); due.Clear(); grave.Clear();
		tries.Clear(); dly.Clear();
		lobBody.Clear(); lobDly.Clear(); lobAt.Clear(); lobDeathTic.Clear();
	}

	// ---- LEGION OF BONES' OWN RAISERS (2026-11-18) ---------------------------------------------------------------------
	// Their rise is their own states' (gy_Bones.WaitAt); this pack never edits Legion of Bones. At the death: the Rise
	// Chance roll, then (a winner, Random Delay on) its own delay. A winner with Random Delay off is not kept: Legion of
	// Bones as it ships.
	void LobDied(Actor a)
	{
		for (int i = lobBody.Size() - 1; i >= 0; i--) if (lobBody[i] == a) LobDrop(i);   // killed again: this death's roll only
		bool rise = gy_Bones.RollRise();
		int d = rise ? gy_Bones.RollDelay() : LOB_LOST;
		if (gy_Bones.Debug())
		{
			String what = rise ? (d >= 0 ? String.Format("rises, its own delay %d (%d tics)", d, gy_Bones.WaitOf(d)) : "rises, Legion of Bones' own delay")
				: String.Format("lost the Rise Chance roll (%d%%), held as a corpse when its wait begins", gy_Bones.Chance());
			Console.Printf("RSQ Graveyard bones t%d: Legion of Bones' %s died at %.0f %.0f: %s", level.maptime, a.GetClassName(), a.pos.x, a.pos.y, what);
		}
		if (d == -1) return;
		lobBody.Push(a); lobDly.Push(d); lobAt.Push(-1); lobDeathTic.Push(level.maptime);
	}

	void LobDrop(int i)
	{
		lobBody.Delete(i); lobDly.Delete(i); lobAt.Delete(i); lobDeathTic.Delete(i);
	}

	void LobTick(int now, bool dbg)
	{
		for (int i = lobBody.Size() - 1; i >= 0; i--)
		{
			let a = lobBody[i];
			// gone (it rose: Respawn ends in Stop) or on its feet again (an Arch-vile, RSQ Miniboss's revive): left alone
			if (!a || a.health > 0) { LobDrop(i); continue; }
			if (a.isFrozen()) continue;   // a time freeze: nothing moved since last tic
			int r = gy_Bones.WaitAt(a);
			int at = r < 0 ? -1 : r % 10;
			if (at < gy_Bones.WAIT_FIRST || at > gy_Bones.WAIT_SOLID)
			{
				// not in its wait: still dying; or out of it without rising (crushed), or never reaching it: let go
				if (lobAt[i] >= 0 || now - lobDeathTic[i] > LOB_DYING)
				{
					if (dbg) Console.Printf("RSQ Graveyard bones t%d: Legion of Bones' %s corpse left its wait without rising: let go", now, a.GetClassName());
					LobDrop(i);
				}
				continue;
			}
			// LOST THE ROLL: held where it lies, on its last corpse frame, for good
			if (lobDly[i] == LOB_LOST)
			{
				gy_Bones.Hold(a);
				if (dbg) Console.Printf("RSQ Graveyard bones t%d: Legion of Bones' %s corpse at %.0f %.0f held for good (wait frame %d)", now, a.GetClassName(), a.pos.x, a.pos.y, at);
				LobDrop(i);
				continue;
			}
			// ITS OWN DELAY: each pass through the wait is put on the frame its roll picks (8 - d), the first pass and each one
			// after something stood on it (Legion of Bones' DeadLoop, back through the A_JumpIf). A_SetSolid lasts one tic and
			// one game tic runs between two WorldTicks, so a corpse seen on it last tic and in its wait now has come round again.
			int prev = lobAt[i];
			if (prev < 0 || prev == gy_Bones.WAIT_SOLID || at < prev)
			{
				int put = gy_Bones.WAIT_SOLID - clamp(lobDly[i], 0, 4);
				State st = gy_Bones.Step(gy_Bones.WaitBase(a, r / 10), put);
				if (st != null && st != a.CurState) a.SetState(st);
				// the first pass is not solid in Legion of Bones' own (A_NoBlocking) until its A_SetSolid: one that landed on
				// A_SetSolid (Instant) and was put back on a wait is made so again. A later pass stays solid, as in Legion of Bones.
				if (prev < 0 && put < gy_Bones.WAIT_SOLID) a.bSolid = false;
				lobAt[i] = put;
				if (dbg) Console.Printf("RSQ Graveyard bones t%d: Legion of Bones' %s corpse %s its wait: its own delay %d, %d tics", now, a.GetClassName(),
					prev < 0 ? "begins" : "begins again", lobDly[i], gy_Bones.WaitOf(lobDly[i]));
			}
			else lobAt[i] = at;
		}
	}

	override void WorldTick()
	{
		if (body.Size() == 0 && lobBody.Size() == 0) return;
		if (!gy_Bones.LobLoaded()) { ClearQueues(); return; }
		int now = level.maptime;
		bool dbg = gy_Bones.Debug();
		if (lobBody.Size() > 0) LobTick(now, dbg);
		if (body.Size() == 0) return;
		SyncDly();
		// the Bones Bridge switched off meanwhile: the corpses already waiting stay dead, dropped now rather than at their due
		// tic (check 11-16 GY9: they stayed in the saved arrays until then); graves still rise
		bool bridge = gy_Bones.BridgeOn();
		for (int i = body.Size() - 1; i >= 0; i--)
		{
			if (!bridge && !grave[i]) { Drop(i); continue; }
			if (due[i] > now) continue;
			let a = body[i];
			// it came back to life by itself (an Arch-vile, a Miniboss revive): left alone
			if (a && a.health > 0) { if (dbg) Console.Printf("RSQ Graveyard bones t%d: %s was revived: no rise", now, a.GetClassName()); Drop(i); continue; }
			Vector3 at = a ? a.pos : (bx[i], by[i], bz[i]);
			bool hold = !grave[i] && gy_Bones.CI('gy_bones_block', 0) == 0;
			// HELD TOO OFTEN (check 11-16 GY4 / NEW-GY2: a corpse something stays on retried forever, and its entry grew the
			// saved arrays): after HOLD_MAX holds it rises at the nearest free spot beside the corpse instead (RiseNear);
			// if none fits either, it stays dead.
			bool beside = hold && tries[i] >= HOLD_MAX;
			Actor r;
			if (grave[i] || beside) r = gy_Bones.RiseNear(kind[i], at, killer[i], grave[i] ? ba[i] : (a ? a.angle : ba[i]));
			else r = gy_Bones.RiseAt(kind[i], at, killer[i], a ? a.angle : ba[i], hold);
			if (!r && beside)
			{
				if (dbg) Console.Printf("RSQ Graveyard bones t%d: the %s corpse at %.0f %.0f was held %d times and nothing near it is free: it stays dead", now, a ? String.Format("%s", a.GetClassName()) : "gone", at.x, at.y, tries[i]);
				Drop(i);
				continue;
			}
			if (!r)
			{
				if (hold)
				{
					// LoB: something on the corpse, the whole wait starts again (logged the first time; LoB's Instant tries every tic)
					due[i] = now + max(HOLD_MIN, gy_Bones.WaitFor(dly[i]));   // its own delay again (Random Delay), never re-rolled
					tries[i]++;
					if (dbg && tries[i] == 1) Console.Printf("RSQ Graveyard bones t%d: something on the %s corpse at %.0f %.0f: the wait starts again", now, a ? String.Format("%s", a.GetClassName()) : "gone", at.x, at.y);
				}
				else
				{
					// no free spot at or near the grave's riser: a second later it looks again (what stood there may move on)
					if (++tries[i] >= GRAVE_TRIES) { if (dbg) Console.Printf("RSQ Graveyard bones t%d: a grave riser at %.0f %.0f found no free spot in %d tries: given up", now, at.x, at.y, tries[i]); Drop(i); continue; }
					due[i] = now + 35;
					if (dbg) Console.Printf("RSQ Graveyard bones t%d: a grave riser at %.0f %.0f did not fit, nor any spot near it (try %d of %d): tries again in 35 tics", now, at.x, at.y, tries[i], GRAVE_TRIES);
				}
				continue;
			}
			if (dbg)
			{
				double moved = (r.pos.xy - at.xy).Length();
				String note = "";
				if (grave[i] && moved > 0.5) note = String.Format(", %.0f map units from its planned spot", moved);
				if (tries[i] > 0) note = note .. String.Format(grave[i] ? ", on try %d" : ", after %d hold%s", grave[i] ? tries[i] + 1 : tries[i], tries[i] == 1 ? "" : "s");
				Console.Printf("RSQ Graveyard bones t%d: %s RISES at %.0f %.0f from %s (target %s)%s", now, r.GetClassName(), r.pos.x, r.pos.y,
					grave[i] ? "a tombstone" : (a ? String.Format("%s", a.GetClassName()) : "a corpse gone"), killer[i] ? String.Format("%s", killer[i].GetClassName()) : "none", note);
			}
			if (a && !grave[i])
			{
				// the corpse got up: any other entry for it goes too (GY3), then the corpse
				for (int j = body.Size() - 1; j >= 0; j--) if (j != i && !grave[j] && body[j] == a) { Drop(j); if (j < i) i--; }
				a.Destroy();
			}
			Drop(i);
		}
	}

	// ---- GRAVES RISE (RSQ Miniboss, "bones.graves"): the tombstones in range, nearest the spot first ----------------------
	// perStone: how many undead each tombstone raises (Miniboss's Graves Rise Mode, owner 11-10: one, or one for each thrall);
	// radius 0: the whole map. NO CAP (owner 2026-11-07: every tombstone raises undead; the old cap of 24 is gone). A stone's risers stand in a ring round it and rise one after another
	// (GRAVE_STAGGER tics apart), the stones a few tics apart.
	const GRAVE_STAGGER = 12;
	int RaiseGraves(Vector3 spot, double radius, int perStone, Array<int> kinds, Actor target)
	{
		Array<Actor> st;
		Array<double> sd;
		let it = ThinkerIterator.Create("gy_Stone");
		Actor s;
		while (s = Actor(it.Next()))
		{
			double d = (s.pos.xy - spot.xy).Length();
			if (radius > 0 && d > radius) continue;
			int k = st.Size();
			st.Push(s); sd.Push(d);
			while (k > 0 && sd[k - 1] > d) { st[k] = st[k - 1]; sd[k] = sd[k - 1]; k--; }
			st[k] = s; sd[k] = d;
		}
		int n = st.Size();
		if (n == 0 || kinds.Size() == 0) return 0;
		int now = level.maptime, made = 0;
		for (int i = 0; i < n; i++)
		{
			for (int j = 0; j < perStone; j++)
			{
				// one a stone: the thralls' kinds in turn across the stones; one for each thrall: each stone raises every thrall's kind
				int k = perStone > 1 ? kinds[j % kinds.Size()] : kinds[i % kinds.Size()];
				// the ring grows with how many stand on it (check 11-16 GY5: one 40-unit ring for any number): about a riser's
				// width (48) of circumference each
				double ring = perStone > 1 ? max(40.0, perStone * 48.0 / 6.2832) : 0.0;
				double ang = j * 360.0 / perStone + i * 37;
				Vector3 at = st[i].pos + (cos(ang) * ring, sin(ang) * ring, 0);
				at.z = st[i].pos.z;
				Push(null, target, at, ang, k, now + i * 4 + j * GRAVE_STAGGER, true);
				made++;
			}
		}
		if (gy_Bones.Debug())
			Console.Printf("RSQ Graveyard bones t%d: a miniboss fight wakes %d tombstone%s (%s): %d undead (%d a stone, no cap)", now, n, n == 1 ? "" : "s",
				radius > 0 ? String.Format("within %.0f", radius) : "the whole map", made, perStone);
		return made;
	}
}
