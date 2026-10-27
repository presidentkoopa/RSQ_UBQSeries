// ============================================================================
// RS_ScoreEvent -- everything about one kill, worked out once.
//
// WHY THIS EXISTS. A bonus that re-derives what it needs at the moment it is asked
// ends up doing things like testing line of sight by TELEPORTING THE CORPSE to
// three heights and warping it back, which is what the ACS original had to do.
// Gather the facts once, hand them round, and a bonus becomes a field read.
//
// THE FACTS ARE FROZEN AT THE KILL. A bonus may be asked after the victim has
// begun its death state and after the player has moved, so anything a bonus needs
// is copied in here, not looked up later through a pointer.
//
// PLAY SCOPE. Same rule as the tracker: nothing here may read one machine's view
// of the world.
// ============================================================================

class RS_ScoreEvent play
{
	// ---- who ---------------------------------------------------------------
	Actor victim;
	Actor killer;            // the player pawn, when a player gets the credit
	Actor inflictor;         // the rocket, the puff, the fist
	RS_ScoreTracker tracker;
	int killerNum;           // -1 when no player earned this

	// ---- the kill ----------------------------------------------------------
	int  victimSpawnHealth;  // also the base points, before any override
	int  basePoints;
	Name damageType;
	bool telefragged;

	// ---- the killer's own state, AT THE KILL -------------------------------
	// Redline and Swan Song both read the KILLER's health, not the victim's --
	// The ACS original switched its activator to the shooter before running any
	// multiplier, which is easy to misread and changes what both bonuses mean.
	int  killerHealth;
	bool killerWasDead;
	double airHeight;        // apex this jump reaches, above the floor it left

	// ---- geometry ----------------------------------------------------------
	bool   victimCouldSee;   // did the victim have a clear line to the killer
	double edgeDistance;     // closest approach, box edge to box edge

	// ---- how a monster died to another monster -----------------------------
	bool monsterOnMonster;   // Infighter
	bool selfInflicted;      // Darwin

	// ---- this map's Untouchable thresholds ---------------------------------
	// Both come off the census, so they belong to the map and not the player. The
	// handler fills them in; Untouchable reads them.
	int utKillsNeeded;
	int utHPNeeded;

	// ------------------------------------------------------------------ build

	static RS_ScoreEvent Create(Actor victim, Actor killer, Actor inflictor, Name damageType)
	{
		let ev = new("RS_ScoreEvent");

		ev.victim    = victim;
		ev.killer    = killer;
		ev.inflictor = inflictor;
		ev.damageType = damageType;
		ev.killerNum = -1;

		ev.victimSpawnHealth = victim ? victim.GetSpawnHealth() : 0;
		ev.basePoints        = ev.victimSpawnHealth;

		// The original read this by damage type where the engine supported it and fell
		// back to a box overlap plus a million points of damage where it did not. We
		// have the damage type, so we use it.
		ev.telefragged = (damageType == 'Telefrag');

		if (killer && killer.player)
		{
			ev.killerNum     = killer.PlayerNumber();
			ev.killerHealth  = killer.health;
			ev.killerWasDead = (killer.health < 0);

			let tr = RS_ScoreTracker(killer.FindInventory("RS_ScoreTracker"));
			ev.tracker = tr;

			if (tr)
			{
				ev.airHeight  = tr.airHeight;
			}

			if (victim)
			{
				ev.edgeDistance   = MeasureEdgeGap(victim, killer);
				ev.victimCouldSee = ev.telefragged ? true : HasSight(victim, killer);
			}
		}

		return ev;
	}

	// ---------------------------------------------------------------- geometry

	// Closest approach between two actors' bounding boxes: clamp each actor's box to
	// the other's position, then the distance between those two points.
	// Centre-to-centre would call a Cyberdemon far away while it is standing on your
	// feet.
	static double MeasureEdgeGap(Actor a, Actor b)
	{
		double aX = Clamp(b.pos.x, a.pos.x - a.radius, a.pos.x + a.radius);
		double aY = Clamp(b.pos.y, a.pos.y - a.radius, a.pos.y + a.radius);
		double aZ = Clamp(b.pos.z, a.pos.z,            a.pos.z + a.height);

		double bX = Clamp(aX, b.pos.x - b.radius, b.pos.x + b.radius);
		double bY = Clamp(aY, b.pos.y - b.radius, b.pos.y + b.radius);
		double bZ = Clamp(aZ, b.pos.z,            b.pos.z + b.height);

		vector3 gap = (aX - bX, aY - bY, aZ - bZ);
		return gap.Length();
	}

	// Could the victim see the killer? Tested at the victim's feet, middle and
	// head, because a monster whose eyeline is blocked at one height may be clear
	// at another. Three traces do the same job as warping the corpse about, and they
	// move nothing.
	static bool HasSight(Actor victim, Actor killer)
	{
		if (TraceClear(victim, killer, 0.0))                 { return true; }
		if (TraceClear(victim, killer, victim.height * 0.5)) { return true; }
		if (TraceClear(victim, killer, victim.height))       { return true; }
		return false;
	}

	// TRF_THRUACTORS on purpose: this asks whether the LEVEL blocks the line, the
	// same question CheckSight answers. Another monster standing in the way does
	// not make a kill stylish.
	static bool TraceClear(Actor from, Actor to, double offsetz)
	{
		double dist2d = from.Distance2D(to);
		double dz     = (to.pos.z + to.height * 0.5) - (from.pos.z + offsetz);
		double dist3d = sqrt(dist2d * dist2d + dz * dz);

		if (dist3d <= 0.0) { return true; }

		double ang   = from.AngleTo(to);
		double pitch = -atan2(dz, dist2d);

		FLineTraceData data;
		from.LineTrace(ang, dist3d, pitch, TRF_THRUACTORS, offsetz, 0.0, 0.0, data);

		if (data.HitType == FLineTraceData.TRACE_HitNone) { return true; }

		// Reached as far as the target counts as clear -- a trace that ends exactly
		// on the far actor's own geometry has not been blocked by anything.
		return data.Distance >= dist3d - 1.0;
	}
}
