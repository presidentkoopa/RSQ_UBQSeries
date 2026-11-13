// ============================================================================
// THRALLS DROP NO GUN (owner 2026-11-12 20:4x: "no gun drop, no red bits drop. just champion bundle, armor and ammo.")
//
// A thrall's death drops Champions' bundle, RSQ VisualRewards' armour and ammo bits (its health bits are left out there,
// killrewards.zs) and its own ammo. What it no longer drops is a gun: the weapon pickup its monster class drops (a
// zombie's Chaingun, which Brutal Doom 22 replaces with ChaingunSpawnerReplacer, which spawns a ChaingunSpawner two
// tics later), or any other weapon pickup or Brutal Doom weapon spawner born of its death. Its LegenDoom legendary weapon
// is BD22 VR Reloaded's (RSLD takes a thrall's away, "suppressed (a thrall's)"); anything named LD... or RSLD... is
// left to it. The miniboss's own drops are untouched (its legendary weapon, its bits, its bundle, its gun).
//
// HOW A GUN IS TIED TO A THRALL'S DEATH. Every monster death is kept for WINDOW tics (where, when, and whether it was a
// thrall, the miniboss or another monster). A gun pickup born while a thrall's death is that recent is judged on the
// next tic (A_SpawnItemEx sets its target, the actor that spawned it, after the spawn): first its spawner chain (target,
// the target's target, up to 4) -- a dead monster on the chain owns it, a player on it keeps it; with no chain, the
// nearest recent death within NEAR units owns it, measured from the death spot or from the body where it lies now (the
// miniboss first when it is within BOSS_NEAR). A
// thrall's is destroyed, before Brutal Doom's replacer can spawn its own spawner. Debug lines with rsqmb_debug.
// ============================================================================

class RSQMB_ThrallDrops : EventHandler
{
	const WINDOW = 175;        // tics a death's drops stay its own (Brutal Doom's replacer lands up to ~45 tics after it)
	const NEAR = 128.0;        // units from the death spot
	const BOSS_NEAR = 64.0;    // the miniboss's own drops win near its body

	const K_OTHER = 0;
	const K_THRALL = 1;
	const K_BOSS = 2;

	Array<Actor> dBody;
	Array<double> dX, dY;
	Array<int> dT, dKind;
	int lastThrall;            // maptime + 1 of the last thrall death (0: none yet)
	Array<Inventory> pend;     // gun pickups born near a recent thrall death, judged next tic

	// what the dying monster is to a called-in fight: its miniboss, a thrall (bound or freed: it carries RSQMB_Called for
	// good), or nothing
	static int KindOf(Actor a)
	{
		let b = RSQMB_Service.BossOf(a);
		if (b && b.mb == a) return K_BOSS;
		if (a.FindInventory("RSQMB_Ward")) return K_BOSS;
		if (a.FindInventory("RSQMB_Called")) return K_THRALL;
		return K_OTHER;
	}

	// a weapon pickup: a Weapon, a pickup that replaces one (Brutal Doom's ChaingunSpawnerReplacer replaces Chaingun), or
	// one of Brutal Doom's weapon spawners (BDWeaponSpawner; BasicWeaponPickup, but not BasicWeaponPickup2: its runes and
	// fatality bonuses). LegenDoom's and RSLD's legendary pickups are BD22 VR Reloaded's call.
	static bool IsGun(Inventory it)
	{
		String n = it.GetClassName();
		if (n.Left(2) ~== "LD" || n.Left(4) ~== "RSLD") return false;
		if (it is "Weapon") return true;
		class<Actor> rep = Actor.GetReplacee(it.GetClass());
		class<Weapon> wrep = (class<Weapon>)(rep);
		if (wrep && rep != it.GetClass()) return true;
		for (class<Object> c = it.GetClass(); c && c != 'Inventory'; c = c.GetParentClass())
		{
			Name cn = c.GetClassName();
			if (cn == 'BasicWeaponPickup2') return false;
			if (cn == 'BDWeaponSpawner' || cn == 'BasicWeaponPickup') return true;
		}
		return false;
	}

	void Prune()
	{
		while (dT.Size() && level.maptime - dT[0] > WINDOW)
		{
			dBody.Delete(0); dX.Delete(0); dY.Delete(0); dT.Delete(0); dKind.Delete(0);
		}
	}

	override void WorldThingDied(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || !a.bIsMonster) return;
		Prune();
		int k = KindOf(a);
		// another monster's death matters only while a thrall's is recent (its own drop must not be taken for the thrall's)
		if (k == K_OTHER && (lastThrall <= 0 || level.maptime + 1 - lastThrall > WINDOW)) return;
		dBody.Push(a); dX.Push(a.pos.x); dY.Push(a.pos.y); dT.Push(level.maptime); dKind.Push(k);
		if (k == K_THRALL) lastThrall = level.maptime + 1;
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if (lastThrall <= 0 || level.maptime + 1 - lastThrall > WINDOW) return;
		let it = Inventory(e.Thing);
		if (!it || it.Owner || !IsGun(it)) return;
		pend.Push(it);
	}

	override void WorldTick()
	{
		if (!pend.Size()) return;
		Prune();
		bool dbg = RSQMB_Handler.CI('rsqmb_debug', 0) != 0;
		for (int i = 0; i < pend.Size(); i++)
		{
			let it = pend[i];
			if (!it || it.Owner) continue;
			int j; String how;
			[j, how] = Whose(it);
			if (j < 0)
			{
				if (dbg) Console.Printf("RSQMB thrall drop: %s kept (%s)", it.GetClassName(), how);
				continue;
			}
			bool thr = dKind[j] == K_THRALL;
			if (dbg)
				Console.Printf("RSQMB thrall drop: %s %s (%s; %s %s died %d tics ago, %.0f units from where it died)", it.GetClassName(),
					thr ? "removed, a thrall's gun" : "kept", how, dKind[j] == K_BOSS ? "the miniboss" : (thr ? "thrall" : "another monster"),
					dBody[j] ? dBody[j].GetClassName() : 'gone', level.maptime - dT[j], (it.pos.xy - (dX[j], dY[j])).Length());
			if (thr) it.Destroy();
		}
		pend.Clear();
	}

	// the recent death this pickup belongs to (an index into the arrays), or -1 (and why)
	int, String Whose(Inventory it)
	{
		Actor t = it.target;
		for (int hop = 0; t && hop < 4; hop++)
		{
			int f = dBody.Find(t);
			if (f < dBody.Size()) return f, "its spawner chain";
			if (t.player) return -1, "a player's";
			t = t.target;
		}
		int best = -1, boss = -1;
		double bd = NEAR, bb = BOSS_NEAR;
		for (int i = 0; i < dT.Size(); i++)
		{
			// from the death spot, or from the body where it lies now (a body thrown by the killing blow drops its gun
			// where it lands: rig mbthrall1, a thrall's ChaingunSpawnerReplacer 132 units from where it died)
			double d = (it.pos.xy - (dX[i], dY[i])).Length();
			if (dBody[i]) d = min(d, (it.pos.xy - dBody[i].pos.xy).Length());
			if (dKind[i] == K_BOSS && d <= bb) { bb = d; boss = i; }
			if (d <= bd) { bd = d; best = i; }
		}
		if (boss >= 0) return boss, "near the miniboss's death spot";
		if (best >= 0) return best, "the nearest recent death";
		return -1, "no recent death near it";
	}
}
