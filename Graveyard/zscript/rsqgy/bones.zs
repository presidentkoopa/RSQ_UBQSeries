// RSQ Graveyards (RSQ Edition, presidentkoopa) -- THE BONES (owner 2026-11-06, design/DECISIONS_DEATH_BONES.md 1). GPLv3 like
// the rest of this folder. Everything here waits for Legion of Bones (SpacemanStrife, LOB_v1.05) to be loaded, found by its
// class names at run time; without it nothing here does anything. Rig only, not headset-confirmed.
//
// 1. THE BONES BRIDGE (gy_bones, off): Brutal Doom's monsters stay as they are. A few seconds after a Brutal Doom / XMVE
//    monster dies, its Legion of Bones undead counterpart rises from the corpse, LoB's own way (decorate/vanilla.txt, read):
//    - WHICH: the dead monster's class and its parents are looked up in gy_BonesTable (tools/gen_bones_table.py: what each BD /
//      XMVE class replaces, parsed from their DECORATE), else a vanilla parent. That gives one of the 13 monsters LoB raises
//      in its Double Death skills, and LoB's own rising actor for it (RISE below: SkullZombieSpawn ... ReaperSpawn). Lost
//      souls, pain elementals, the Cyberdemon, the Mastermind (and whatever replaces them) stay dead, as in LoB. LoB's own
//      monsters and undead never come here (they rise or die by LoB's own states).
//    - WHEN: LoB's Respawn Delay (LOB_Respawn, LoB's own menu: Instant / 5 / 10 / 15 / 20 s; its states wait 0 / 170 / 345 /
//      520 / 695 tics) after LoB's death animation (25 tics), counted from the death.
//    - WHAT STOPS IT (gy_bones_block): 0 "Something On It (LoB)": LoB's A_SetSolid + A_CheckBlock: when the wait ends, if
//      something solid stands on the corpse (a player, a monster) the whole wait starts again. 1 "Nothing". Either way a
//      corpse that came back to life meanwhile (an Arch-vile, RSQ Miniboss's Revive Thralls) is left alone.
//    - THE RISING: LoB's: its UndeadSpawnFire burst on the corpse, Doom's teleport sound (misc/teleport), its <Name>Spawn
//      actor (the undead's death frames backwards, facing its target), which spawns the undead with SXF_TRANSFERPOINTERS: it
//      comes for whoever killed the corpse. The Brutal Doom corpse is removed (it got up). A corpse already removed (gibbed
//      away) rises where it lay, as LoB raises gibbed deaths too.
// 2. GRAVES RISE IN A BOSSFIGHT: RSQ Miniboss asks gy_RSQService "bones.graves" when a Bossfight calls in (its row, off): the
//    tombstones in the map, or within a radius of the fight's spawn, raise undead the same way. Miniboss says how many.
// 3. STONES PULSE WITH THE BOSSFIGHT: RSQ Miniboss asks gy_RSQService "stones.pulse" on each beat of RSQ Glow In The Dark's
//    red heartbeat while a Bossfight waits to be called in: every stone's candle beats with it (gy_Stone.pulse).
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
	static int WaitTics()
	{
		static const int WAIT[] = { 0, 170, 345, 520, 695 };
		return WAIT[clamp(CI('LOB_Respawn', 2), 0, 4)];
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
			if (IsLob(cn)) return -1;
			int t = gy_BonesTable.Kind(cn);
			if (t >= 0) return t;
			t = VanillaKind(cn);
			if (t >= 0) return t;
		}
		return -1;
	}

	// RSQ Miniboss's "bones.graves" (gy_RSQService): stringArg the Bossfight's thrall classes, comma-separated (each raises
	// the undead its kind maps to; none that LoB raises: Skull Zombies); intArg player * 1000 + how many undead in all;
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
		int pn = packed / 1000, budget = packed % 1000;
		Actor tgt = (pn >= 0 && pn < MAXPLAYERS && playeringame[pn]) ? players[pn].mo : null;
		return h.RaiseGraves(spot.pos, radius, budget, kinds, tgt);
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
	Array<bool> grave;          // a Bossfight's grave rise (no corpse; never held)
	Array<int> tries;           // a grave riser's tries (one that never fits is given up after GRAVE_TRIES); a corpse's holds
	const GRAVE_TRIES = 10;

	override void WorldThingDied(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || a.player || !a.bIsMonster || !gy_Bones.BridgeOn()) return;
		int k = gy_Bones.KindOf(a);
		bool dbg = gy_Bones.Debug();
		if (k < 0)
		{
			if (dbg) Console.Printf("RSQ Graveyard bones t%d: %s died: not one LoB raises, stays dead", level.maptime, a.GetClassName());
			return;
		}
		Actor who = e.DamageSource ? e.DamageSource : a.target;
		int wait = gy_Bones.DEATH_ANIM + gy_Bones.WaitTics();
		Push(a, who, a.pos, a.angle, k, level.maptime + wait, false);
		if (dbg) Console.Printf("RSQ Graveyard bones t%d: %s died at %.0f %.0f: rises as %s in %d tics (LOB_Respawn %d)", level.maptime,
			a.GetClassName(), a.pos.x, a.pos.y, gy_Bones.Rise(k), wait, gy_Bones.CI('LOB_Respawn', 2));
	}

	void Push(Actor a, Actor who, Vector3 at, double ang, int k, int when, bool isGrave)
	{
		body.Push(a); killer.Push(who); bx.Push(at.x); by.Push(at.y); bz.Push(at.z); ba.Push(ang);
		kind.Push(k); due.Push(when); grave.Push(isGrave); tries.Push(0);
	}

	void Drop(int i)
	{
		body.Delete(i); killer.Delete(i); bx.Delete(i); by.Delete(i); bz.Delete(i); ba.Delete(i);
		kind.Delete(i); due.Delete(i); grave.Delete(i); tries.Delete(i);
	}

	override void WorldTick()
	{
		if (body.Size() == 0) return;
		if (!gy_Bones.LobLoaded()) { body.Clear(); killer.Clear(); bx.Clear(); by.Clear(); bz.Clear(); ba.Clear(); kind.Clear(); due.Clear(); grave.Clear(); tries.Clear(); return; }
		int now = level.maptime;
		bool dbg = gy_Bones.Debug();
		for (int i = body.Size() - 1; i >= 0; i--)
		{
			if (due[i] > now) continue;
			let a = body[i];
			// the Bones Bridge switched off meanwhile: the corpses already waiting stay dead (graves still rise)
			if (!grave[i] && !gy_Bones.BridgeOn()) { Drop(i); continue; }
			// it came back to life by itself (an Arch-vile, a Miniboss revive): left alone
			if (a && a.health > 0) { if (dbg) Console.Printf("RSQ Graveyard bones t%d: %s was revived: no rise", now, a.GetClassName()); Drop(i); continue; }
			Vector3 at = a ? a.pos : (bx[i], by[i], bz[i]);
			bool hold = !grave[i] && gy_Bones.CI('gy_bones_block', 0) == 0;
			let r = gy_Bones.RiseAt(kind[i], at, killer[i], a ? a.angle : ba[i], hold || grave[i]);
			if (!r)
			{
				if (hold)
				{
					// LoB: something on the corpse, the whole wait starts again (logged the first time; LoB's Instant tries every tic)
					due[i] = now + max(1, gy_Bones.WaitTics());
					tries[i]++;
					if (dbg && tries[i] == 1) Console.Printf("RSQ Graveyard bones t%d: something on the %s corpse at %.0f %.0f: the wait starts again", now, a ? String.Format("%s", a.GetClassName()) : "gone", at.x, at.y);
				}
				else
				{
					// a grave's riser that does not fit is tried again a little later (a monster standing there moves on)
					if (++tries[i] >= GRAVE_TRIES) { if (dbg) Console.Printf("RSQ Graveyard bones t%d: a grave riser at %.0f %.0f never fit: given up", now, at.x, at.y); Drop(i); continue; }
					due[i] = now + 35;
					if (dbg) Console.Printf("RSQ Graveyard bones t%d: a grave riser at %.0f %.0f did not fit: tries again", now, at.x, at.y);
				}
				continue;
			}
			if (dbg) Console.Printf("RSQ Graveyard bones t%d: %s RISES at %.0f %.0f from %s (target %s)%s", now, r.GetClassName(), at.x, at.y,
				grave[i] ? "a tombstone" : (a ? String.Format("%s", a.GetClassName()) : "a corpse gone"), killer[i] ? String.Format("%s", killer[i].GetClassName()) : "none",
				(!grave[i] && tries[i] > 0) ? String.Format(", after %d hold%s", tries[i], tries[i] == 1 ? "" : "s") : "");
			if (a && !grave[i]) a.Destroy();   // the corpse got up
			Drop(i);
		}
	}

	// ---- GRAVES RISE (RSQ Miniboss, "bones.graves"): the tombstones in range, nearest the spot first -----------------------
	// budget: how many undead in all (Miniboss's formula); radius 0: the whole map. Each stone in range raises at least one,
	// the budget is spread over them (round robin, nearest first), at most MAX_GRAVE_RISERS in all. A stone's risers stand in a
	// ring round it and rise one after another (GRAVE_STAGGER tics apart), the stones a few tics apart.
	const MAX_GRAVE_RISERS = 24;
	const GRAVE_STAGGER = 12;
	int RaiseGraves(Vector3 spot, double radius, int budget, Array<int> kinds, Actor target)
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
		int total = min(max(budget, n), MAX_GRAVE_RISERS);
		int now = level.maptime, made = 0;
		Array<int> per;
		for (int i = 0; i < n; i++) per.Push(0);
		for (int j = 0; j < total; j++) per[j % n]++;
		for (int i = 0; i < n; i++)
		{
			for (int j = 0; j < per[i]; j++)
			{
				int k = kinds[made % kinds.Size()];
				double ring = per[i] > 1 ? 40.0 : 0.0;
				double ang = j * 360.0 / max(1, per[i]) + i * 37;
				Vector3 at = st[i].pos + (cos(ang) * ring, sin(ang) * ring, 0);
				at.z = st[i].pos.z;
				Push(null, target, at, ang, k, now + i * 4 + j * GRAVE_STAGGER, true);
				made++;
			}
		}
		if (gy_Bones.Debug())
			Console.Printf("RSQ Graveyard bones t%d: a Bossfight wakes %d tombstone%s (%s): %d undead (budget %d, cap %d)", now, n, n == 1 ? "" : "s",
				radius > 0 ? String.Format("within %.0f", radius) : "the whole map", made, budget, MAX_GRAVE_RISERS);
		return made;
	}
}
