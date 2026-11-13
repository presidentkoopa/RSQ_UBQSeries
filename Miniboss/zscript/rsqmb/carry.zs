// ============================================================================
// RSQ_Miniboss -- A NEW BODY KEEPS ITS CHAMPION (2026-11-12, the owner's definition: every monster of the encounter is a
// BOOSTED LEGENDARY CHAMPION, and stays one when RSQ Monsters swaps its body on a tier change).
//
// How Champions makes a champion (Champions 2021-03-09, zscript/champions/handler.txt and baseclass.txt): its handler rolls
// each new monster as it spawns (WorldThingSpawned) and, on a hit, gives it a champion_PersistentInfo (the colour's
// controller class, its index, its mutation, a hybrid's second colour) and creates a controller THINKER that does the work
// (its colour token, its look, its health, its powers, its mutation). Tokens alone re-create only the four powers its
// handler reads by name; the rest live in the controller. Its own WorldThingRevived builds the controllers again from the
// PersistentInfo (a revived champion keeps its colour). So, for a set-piece body RSQ Monsters swaps (RS_Retier.Swap spawns
// the new class where the old one stands, then destroys the old, all in one call):
//   0 the old body's PersistentInfo is taken off it as it is destroyed (WorldThingDestroyed comes before its inventory goes)
//     and held, with the spot it stood on; or straight off the old body when the new one's spawn event comes first;
//   1 BEFORE Champions sees the new body (this handler runs first, SetOrder), that PersistentInfo is moved onto it
//     and Champions' own WorldThingRevived is asked to build its controllers from it, with the spawn's own event. Champions'
//     "dormant until transformed" rule is met for that one call (LegenDoom's Transformed token held for the call: the new
//     body rises a few tics later, below). Same colour, same mutation, same hybrid; Champions' own code, nothing copied.
//   2 It carries champion_NullToken for the rest of that spawn, so Champions' own roll does not make it a SECOND, random
//     champion (rig run mbkeep0: a Dark Green miniboss came back Violet, a Black thrall came back Pink or plain). The token
//     is taken off again by RSQMB_Handler.WorldThingSpawned (after Champions'), or at the latest the next tic here.
//   3 fight.zs Follow dresses it (its tokens, its LegenDoom legendary, boss.zs Rebody), and boss.zs Reborn makes it RISE
//     (RiseOne, as at the arrival), held invulnerable until it has risen, then gives it its share of health back.
// Map monsters swapped by the same missed window are not touched here (only a set piece's own bodies are matched): they
// stay as they were before this (Champions' own roll at its own chance).
// Everything by name: without Champions or LegenDoom this does nothing.
// ============================================================================

class RSQMB_SwapCatch : EventHandler
{
	Array<Actor> nullTemp;    // bodies holding our temporary champion_NullToken

	override void OnRegister() { SetOrder(-1000); }   // before Champions' handler (order 0): it must not roll the new body

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || !a.bISMONSTER || a.player) return;
		let h = RSQMB_Handler.Get();
		if (!h || h.tfMon.Size() == 0) return;
		if (h.CarryOnSpawn(a, e) && RSQMB_Handler.Loaded("champion_NullToken"))
		{
			RSQMB_Handler.Give(a, "champion_NullToken");
			nullTemp.Push(a);
		}
	}

	// the token off again (RSQMB_Handler.WorldThingSpawned calls this right after Champions' handler; the tic is the backstop)
	void TakeNull(Actor only = null)
	{
		let nc = RSQMB_Handler.InvClass("champion_NullToken");
		for (int i = nullTemp.Size() - 1; i >= 0; i--)
		{
			let a = nullTemp[i];
			if (only && a != only) continue;
			if (a && nc) a.TakeInventory(nc, 999);
			nullTemp.Delete(i);
		}
	}
	override void WorldTick() { if (nullTemp.Size()) TakeNull(); }

	override void WorldThingDestroyed(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || !a.bISMONSTER) return;
		let h = RSQMB_Handler.Get();
		if (h && h.tfMon.Size()) h.HoldOnDestroy(a);
	}

	static RSQMB_SwapCatch Get() { return RSQMB_SwapCatch(EventHandler.Find("RSQMB_SwapCatch")); }
}

extend class RSQMB_Handler
{
	// the follow records added for the carry (fight.zs RetierBy / Follow), kept the length of tfMon (a save from before has none)
	Array<Actor> tfNext;      // the new body, caught as it spawned (RSQMB_SwapCatch)
	Array<double> tfFrac;     // the share of its health the old body had left
	Array<int> tfCarry;       // 1: its Champions record was carried and Champions built its controllers again
	Array<Inventory> tfInfo;  // its Champions record, held between the old body's end and the new body's spawn event
	Array<int> tfHeldAt;      // the tic the old body ended (Follow waits a few tics for the new body's spawn event)
	void EnsureTf()
	{
		while (tfHeldAt.Size() < tfMon.Size()) tfHeldAt.Push(0);
		while (tfInfo.Size() < tfMon.Size()) tfInfo.Push(null);
		while (tfNext.Size() < tfMon.Size()) tfNext.Push(null);
		while (tfFrac.Size() < tfMon.Size()) tfFrac.Push(1.0);
		while (tfCarry.Size() < tfMon.Size()) tfCarry.Push(0);
	}

	// a followed set-piece body is destroyed (RS_Retier.Swap, after spawning its new body): its Champions record is held
	// for the new body, and the spot it stood on (the new body spawned there)
	void HoldOnDestroy(Actor o)
	{
		int now = level.maptime;
		EnsureTf();
		int k = tfMon.Find(o);
		if (k >= tfMon.Size() || tfUntil[k] < now || !tfBoss[k] || tfBoss[k].done || tfNext[k]) return;
		tfX[k] = o.pos.x; tfY[k] = o.pos.y; tfZ[k] = o.pos.z;
		tfHeldAt[k] = now;
		let ic = InvClass("champion_PersistentInfo");
		let info = ic ? o.FindInventory(ic) : null;
		if (info) { o.RemoveInventory(info); tfInfo[k] = info; }
		if (debug) Console.Printf("RSQMB carry t%d: %s's old body %s ends at %.1f %.1f %.1f, Champions record %s", now,
			tfRole[k] < 0 ? "the miniboss" : String.Format("thrall %d", tfRole[k]), o.GetClassName(), o.pos.x, o.pos.y, o.pos.z, info ? "held" : "none");
	}

	// a monster spawned: is it the new body of a set-piece monster RSQ Monsters is swapping right now (on the exact spot of
	// one being followed: the old one still standing there, or destroyed there with its record held)? Then its Champion is
	// carried over. True when it is one (the caller holds Champions' roll off it).
	const SPOT_XY = 24.0;
	bool CarryOnSpawn(Actor a, WorldEvent e)
	{
		int now = level.maptime;
		EnsureTf();
		for (int k = 0; k < tfMon.Size(); k++)
		{
			if (tfUntil[k] < now || !tfBoss[k] || tfBoss[k].done || tfNext[k]) continue;
			let o = tfMon[k];
			if (o == a)
			{
				// Follow found it a tic before its spawn event: its record is still held, carried now
				if (tfHeldAt[k] <= 0) continue;
				o = null;
			}
			else if (o)
			{
				Vector3 dv = level.Vec3Diff(o.pos, a.pos);
				if (o.health <= 0 || o.GetClass() == a.GetClass() || dv.xy.Length() > SPOT_XY || abs(dv.z) > SPOT_XY) continue;
				// the spawn event before the old body's end: its record straight off it
				let ic = InvClass("champion_PersistentInfo");
				let info = ic ? o.FindInventory(ic) : null;
				if (info) { o.RemoveInventory(info); tfInfo[k] = info; }
			}
			else
			{
				// where it ended, give or take one step: the spawn event comes after the new body's first tic, and RSQ Monsters
				// hands it the old one's speed and its chase (rig mbkeep4: 9 to 14 units on; mbkeep3: 9 units in z on a step).
				// Two solid monsters' centres stand at least two radii apart, so a map monster's new body is never this close.
				Vector3 dv = level.Vec3Diff((tfX[k], tfY[k], tfZ[k]), a.pos);
				bool same = dv.xy.Length() <= SPOT_XY && abs(dv.z) <= SPOT_XY && now - tfHeldAt[k] <= 2;
				if (debug && dv.Length() < 96) Console.Printf("RSQMB carry t%d: %s spawned %.1f across, %.1f up from where %s's old body ended (%s)", now, a.GetClassName(),
					dv.xy.Length(), dv.z, tfRole[k] < 0 ? "the miniboss" : String.Format("thrall %d", tfRole[k]), tfHeldAt[k] > 0 && same ? "its new body" : "not it");
				if (tfHeldAt[k] <= 0 || !same) continue;
			}
			tfNext[k] = a;
			tfHeldAt[k] = 0;
			tfCarry[k] = CarryChampion(tfInfo[k], a, e);
			tfInfo[k] = null;
			if (debug) Console.Printf("RSQMB carry t%d: %s -> %s (%s): %s", now, o ? o.GetClassName() : 'its old body (ended)', a.GetClassName(),
				tfRole[k] < 0 ? "the miniboss" : String.Format("thrall %d", tfRole[k]),
				tfCarry[k] ? "its Champion built again by Champions" : "no Champions record to carry");
			return true;
		}
		return false;
	}

	// the old body's Champions record onto the new one, and Champions' own revive builds its controllers from it
	static int CarryChampion(Inventory info, Actor a, WorldEvent e)
	{
		if (!info || !a) return 0;
		info.AttachToOwner(a);
		String hn = "champion_Handler";
		class<StaticEventHandler> hc = hn;
		let ch = hc ? EventHandler.Find(hc) : null;   // (EventHandler.Find: StaticEventHandler.Find sees only static ones; rig mbkeep2)
		if (!ch) return 0;
		// Champions skips a not-yet-transformed legendary under its Dormant option: it rises in a few tics (boss.zs Reborn)
		let tc = InvClass("LDLegendaryMonsterTransformed");
		bool tmp = tc && !a.FindInventory(tc);
		if (tmp) a.GiveInventory(tc, 1);
		ch.WorldThingRevived(e);
		if (tmp) a.TakeInventory(tc, 999);
		return 1;
	}
}
