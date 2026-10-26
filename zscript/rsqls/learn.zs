// LEARNED FROM THE GUN ITSELF (phase 3).
//
// A laser on every gun in every mod means no per-weapon table: nobody can know
// the spread of a shotgun from a pack this mod has never seen. So the laser
// WATCHES what each weapon actually does, the first time it fires, and draws from
// that. Nothing is guessed; until a weapon has fired, it draws the plain laser.
//
//   SPREAD   every hitscan a player weapon fires passes WorldHitscanPreFired with
//            the angle it was fired at. In VR the engine turns that angle into the
//            controller's frame by its OFFSET from the pawn's own angle
//            (hw_vrmodes.cpp MapWeaponDir: yaw -= actor yaw, pitch -= actor pitch),
//            so that offset IS the spread. The widest seen, per weapon class, per
//            axis, is the ring.
//   ARC      a gravity-bound missile a player fires is caught on spawn and read
//            one tic later (its speed is set after the spawn event): speed, its
//            own gravity factor, and how far above the hand's line it was thrown.
//            That is everything a ballistic path needs.
//
// Kept per weapon CLASS NAME for the session and in savegames. Console player
// only: what is drawn is drawn for that player.
class RSQLS_Learn : EventHandler
{
	Array<String> keys;
	Array<double> sprH, sprV;          // widest spread seen, degrees
	Array<int>    hits;                // hitscans seen
	Array<double> pSpeed, pGrav, pElev, pYaw;
	Array<bool>   pKnown;

	private transient Array<Actor> pend;

	static RSQLS_Learn Get() { return RSQLS_Learn(EventHandler.Find("RSQLS_Learn")); }

	clearscope int Find(String k) const
	{
		for (int i = 0; i < keys.Size(); i++) if (keys[i] == k) return i;
		return -1;
	}

	private int Slot(String k)
	{
		int i = Find(k);
		if (i >= 0) return i;
		keys.Push(k); sprH.Push(0); sprV.Push(0); hits.Push(0);
		pSpeed.Push(0); pGrav.Push(0); pElev.Push(0); pYaw.Push(0); pKnown.Push(false);
		return keys.Size() - 1;
	}

	// The widest spread this weapon has shown, or (0, 0) if it has not fired.
	static clearscope double, double Spread(Weapon w)
	{
		let me = RSQLS_Learn(EventHandler.Find("RSQLS_Learn"));
		if (!me || !w) return 0, 0;
		int i = me.Find(w.GetClassName());
		if (i < 0) return 0, 0;
		return me.sprH[i], me.sprV[i];
	}

	// Its thrown projectile: known, speed (units/tic), gravity factor, elevation
	// above the hand's line (degrees), yaw off it (degrees).
	static clearscope bool, double, double, double, double Arc(Weapon w)
	{
		let me = RSQLS_Learn(EventHandler.Find("RSQLS_Learn"));
		if (!me || !w) return false, 0, 0, 0, 0;
		int i = me.Find(w.GetClassName());
		if (i < 0 || !me.pKnown[i]) return false, 0, 0, 0, 0;
		return true, me.pSpeed[i], me.pGrav[i], me.pElev[i], me.pYaw[i];
	}

	override bool WorldHitscanPreFired(WorldEvent e)
	{
		let pmo = PlayerPawn(e.Thing);
		if (!pmo || !pmo.player || pmo.player != players[consoleplayer]) return false;
		bool off = (e.AttackLineFlags & LAF_ISOFFHAND) != 0;
		Weapon w = off ? pmo.player.OffhandWeapon : pmo.player.ReadyWeapon;
		if (!w) return false;
		double dA = abs(Actor.DeltaAngle(pmo.angle, e.AttackAngle));
		double dP = abs(e.AttackPitch - pmo.pitch);
		if (dA > 30 || dP > 30) return false;   // not a spread: something else aimed it
		int i = Slot(w.GetClassName());
		sprH[i] = max(sprH[i], dA);
		sprV[i] = max(sprV[i], dP);
		hits[i]++;
		return false;   // never stop the shot
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let m = e.Thing;
		if (m && m.bMISSILE && !m.bNOGRAVITY && m.Gravity > 0) pend.Push(m);
	}

	override void WorldTick()
	{
		for (int k = pend.Size() - 1; k >= 0; k--)
		{
			Actor m = pend[k];
			pend.Delete(k);
			if (!m) continue;
			let pmo = PlayerPawn(m.target);
			if (!pmo || !pmo.player || pmo.player != players[consoleplayer]) continue;
			// Which hand threw it: the nearer grip to where it was a tic ago.
			Vector3 was = m.pos - m.vel;
			int h = ((was - pmo.AttackPos).Length() <= (was - pmo.OffhandPos).Length()) ? 0 : 1;
			Weapon w = (h == 0) ? pmo.player.ReadyWeapon : pmo.player.OffhandWeapon;
			if (!w) continue;
			// Its speed is set after the spawn event, and one tic of gravity has
			// been applied since: put that back.
			double g = level.gravity * m.CurSector.gravity * m.Gravity * 0.00125;
			Vector3 v = m.vel;
			if (m.pos.z > m.floorz + 0.5) v.z += g;
			double sp = v.Length();
			if (sp < 1) continue;
			double vPitch = atan2(v.z, v.xy.Length());
			double vYaw = atan2(v.y, v.x);
			int i = Slot(w.GetClassName());
			pSpeed[i] = sp;
			pGrav[i]  = m.Gravity;
			pElev[i]  = vPitch - RSQLS_Hand.Pitch(pmo, h);
			pYaw[i]   = Actor.DeltaAngle(RSQLS_Hand.Yaw(pmo, h), vYaw);
			pKnown[i] = true;
		}
	}
}
