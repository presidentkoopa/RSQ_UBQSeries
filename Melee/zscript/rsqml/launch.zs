// THE LAUNCH (GBOVR_TREES.md 4.1 A, Power: Uppercut, Launcher, Juggle, Meteor; owner 11-02). What a glove's uppercut
// lifts carries this until it lands (or LIFE tics): who launched it, with which glove, and that glove's Launcher and
// Meteor levels as they were at the launch. With it:
//   JUGGLE    a second punch from the same player while it is still in the air (RSQ Gun Bonsai VR's Juggle asks
//             "launch.age" on RSQML_Service for the harder hit; the gloves re-lift it, gloves.zs Deliver)
//   LAUNCHER  it staggers when it lands (the stagger is RSQ_Upgrade_Launcher.Stagger, "upgrade.num")
//   METEOR    it hurts what it comes down on, and itself, paid to the glove (RSQ_Upgrade_Meteor.Damage)
// Without RSQ Gun Bonsai VR the levels are 0: it only marks the flight (nothing reads it).
class RSQML_Launched : Inventory
{
	PlayerPawn by;
	Weapon glove;
	int pn, at, lnLv, mtLv;
	bool flew;
	Array<Actor> struck;

	const LIFE = 105;   // tics: a launch that never comes down (a flyer, a ledge) is forgotten after this

	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE }

	static void Mark(Actor mo, PlayerPawn pawn, Weapon glove, int lnLv, int mtLv)
	{
		if (!mo || mo.health <= 0 || mo.player || !pawn) return;
		let t = RSQML_Launched(mo.FindInventory("RSQML_Launched"));
		if (!t) t = RSQML_Launched(mo.GiveInventoryType("RSQML_Launched"));
		if (!t) return;
		t.by = pawn; t.glove = glove; t.pn = pawn.PlayerNumber();
		t.at = level.maptime; t.lnLv = lnLv; t.mtLv = mtLv;
		t.flew = false;
		t.struck.Clear();
	}

	static bool Airborne(Actor mo) { return mo && mo.pos.z > mo.floorz + 1.0 && !mo.bOnMobj; }

	// tics since player pn launched it, while it is still off the floor; -1 otherwise
	static int AgeFor(Actor mo, int pn)
	{
		if (!mo) return -1;
		let t = RSQML_Launched(mo.FindInventory("RSQML_Launched"));
		if (!t || t.pn != pn || !Airborne(mo)) return -1;
		return level.maptime - t.at;
	}

	override void DoEffect()
	{
		Super.DoEffect();
		let mo = owner;
		if (!mo || mo.health <= 0 || level.maptime - at > LIFE) { Destroy(); return; }
		bool air = Airborne(mo);
		if (air) flew = true;
		if (mtLv > 0 && flew && mo.vel.z < -1.0)
		{
			Meteor(mo);
			if (!mo || mo.health <= 0) { Destroy(); return; }
		}
		if (flew && !air && level.maptime - at > 2)
		{
			// LANDED
			if (lnLv > 0)
			{
				int st = int(RSQML.Num("Launcher.stagger", lnLv, 0, 20));
				RSQML.Stagger(mo, st);
				if (RSQML.Debug() > 0) Console.Printf("RSQML launcher: %s landed, staggered %d tics", mo.GetClassName(), st);
			}
			Destroy();
		}
	}

	// METEOR: about to land on a body (its feet reach that body's top this tic or the next), or already in it
	private void Meteor(Actor mo)
	{
		double fall = -mo.vel.z;
		let it = BlockThingsIterator.Create(mo, mo.radius + 64);
		while (it.Next())
		{
			let o = it.thing;
			if (!o || o == mo || !RSQML.IsFoe(by, o) || struck.Find(o) < struck.Size()) continue;
			if (mo.Distance2D(o) > mo.radius + o.radius) continue;
			if (mo.pos.z > o.pos.z + o.height + fall + 2.0 || mo.pos.z + mo.height < o.pos.z) continue;
			struck.Push(o);
			int dmg = int(RSQML.Num("Meteor.damage", mtLv, fall, 20 + fall));
			Actor inf = RSQML.Blow(by, glove, mo.pos);
			if (RSQML.Debug() > 0) { String on = o.GetClassName(); Console.Printf("RSQML meteor: %s falls on %s at %.1f -> %d each", mo.GetClassName(), on, fall, dmg); }
			mo.A_StartSound("rsqml/smash", CHAN_AUTO, 0, 1.0);
			RSQML.Touch("meteor", by, o);
			o.DamageMobj(inf, by, dmg, 'Melee', DMG_THRUSTLESS);
			if (mo && mo.health > 0) mo.DamageMobj(inf, by, dmg, 'Melee', DMG_THRUSTLESS);
			if (!mo || mo.health <= 0) return;
		}
	}
}
