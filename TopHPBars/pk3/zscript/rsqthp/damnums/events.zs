// RSQ HP Bars -- Damage Numbers: when a number is spawned (from damnums' DamNumEventHandler / DamNumTracker by Xaser Acheron).
//
// damnums gave every ISMONSTER actor a ticking item that diffed its health every tic, and spawned the last diff when
// it died. On Brutal Doom that included the head hitboxes (HeadHitbox family: +ISMONSTER -COUNTKILL, 9999 health,
// riding a monster or a dying body); when the body under one stops being shootable (the kill, a corpse landing) the
// hitbox calls A_Die, its 9999 health drops to 0 and damnums showed 9999 (measured on the rig, HANDOFF.md 11-03).
//
// Here: one number per target per tic from WorldThingDamaged, summed over the tic like damnums' tracker, spawned at
// the start of the next tic (damnums' Shotgun Spray: one number per hit, at once). Never for:
//   - a helper: Brutal Doom's HeadHitbox family and boot smearers by name, and any ISMONSTER -COUNTKILL thing with
//     1000+ spawn health that rides a master or can never be targeted (that is how those helpers are built);
//   - a player's own body (Numbers For "All Shootable": your hits on yourself would float in your face in VR);
//   - a hit on a thing that was already dead before it (a corpse, a body being finished);
//   - the Massacre and KillMe damage types (cheats, and Brutal Doom's own clean-up kills);
//   - a Brutal Doom body (ISMONSTER -COUNTKILL) ending itself with no source or inflictor (bleeding out, A_Die).
// A number is never more than the health the target had left: an overkill shows the health it really lost.
class RSQTHP_DamNumHandler : EventHandler
{
	Array<Actor> who;
	Array<int> amt;
	Array<double> px, py, pz;
	Array<int> typ;   // index into types
	Array<Name> types;

	static const String HELPERBASE[] = { "HeadHitbox" };
	static const String HELPERNAME[] = { "BootSmearerRed", "BootSmearerBlue", "BootSmearerGreen", "NewCybersHitBox" };

	bool IsHelper(Actor a)
	{
		if (!a) return true;
		for (int i = 0; i < HELPERBASE.Size(); i++) { class<Actor> bc = HELPERBASE[i]; if (bc && a is bc) return true; }
		Name cn = a.GetClassName();
		for (int i = 0; i < HELPERNAME.Size(); i++) if (cn == HELPERNAME[i]) return true;
		if (a.bIsMonster && !a.bCountKill && a.SpawnHealth() >= 1000 && ((a.master && a.master != a) || a.bNeverTarget)) return true;
		return false;
	}

	bool Eligible(Actor a)
	{
		if (!a || a.player) return false;
		if (!(a.bIsMonster || (rsqthp_dmg_all && a.bShootable))) return false;
		return !IsHelper(a);
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		if (!rsqthp_dmg) return;
		let a = e.Thing;
		if (!Eligible(a)) return;
		if (e.DamageType == 'Massacre' || e.DamageType == 'KillMe') return;
		// a Brutal Doom body (ISMONSTER -COUNTKILL: a dying, crawling or slumped body) ending itself (bleed-out, A_Die:
		// no source, no inflictor) is not a hit; a hit on one by anyone still shows
		if (a.bIsMonster && !a.bCountKill && !e.DamageSource && !e.Inflictor) return;
		// the event comes after the health came off: before = health + damage
		int before = a.health + e.Damage;
		if (before <= 0 || e.Damage <= 0) return;           // already dead before this hit
		int lost = before - max(a.health, 0);               // never more than it had left
		if (lost <= 0) return;
		Vector3 p = a.pos + (0, 0, a.height - 16);
		if (rsqthp_dmg_spray)
		{
			RSQTHP_DamNum.SpawnDamageNumbers(p, lost, e.DamageType);
			return;
		}
		int ti = types.Find(e.DamageType);
		if (ti == types.Size()) types.Push(e.DamageType);
		int i = who.Find(a);
		if (i == who.Size())
		{
			who.Push(a); amt.Push(0); px.Push(0); py.Push(0); pz.Push(0); typ.Push(0);
		}
		amt[i] += lost; px[i] = p.x; py[i] = p.y; pz[i] = p.z; typ[i] = ti;   // the last hit's type, like damnums
	}

	override void WorldTick()
	{
		if (!who.Size()) return;
		for (int i = 0; i < who.Size(); i++)
		{
			let a = who[i];
			// where it is now (damnums spawned at the owner when its item ticked); a removed thing: where it was hit
			Vector3 p = a ? a.pos + (0, 0, a.height - 16) : (px[i], py[i], pz[i]);
			if (rsqthp_dmg) RSQTHP_DamNum.SpawnDamageNumbers(p, amt[i], types[typ[i]]);
		}
		who.Clear(); amt.Clear(); px.Clear(); py.Clear(); pz.Clear(); typ.Clear();
		if (types.Size() > 64) types.Clear();
	}

	override void WorldUnloaded(WorldEvent e)
	{
		who.Clear(); amt.Clear(); px.Clear(); py.Clear(); pz.Clear(); typ.Clear(); types.Clear();
	}
}
