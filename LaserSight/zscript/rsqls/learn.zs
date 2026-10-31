// LEARNED FROM THE GUN ITSELF (phase 3).
//
// A laser on every gun in every mod means no per-weapon table: nobody can know
// the spread of a shotgun from a pack this mod has never seen. So the laser
// WATCHES what each weapon actually does and draws from that. Nothing is guessed;
// until a weapon has fired, it draws the plain laser.
//
//   SPREAD   every hitscan a player weapon fires passes WorldHitscanPreFired with
//            the angle it was fired at. In VR the engine turns that angle into the
//            controller's frame by its OFFSET from the pawn's own angle
//            (hw_vrmodes.cpp MapWeaponDir: yaw -= actor yaw, pitch -= actor pitch),
//            so that offset IS the spread. Kept as a histogram per weapon, per
//            axis; the ring is the angle 95% of shots fall inside, so one odd shot
//            (a melee kick, a weapon passing its own pitch) cannot blow it up.
//   ARC      a gravity-bound missile a player fires is caught on spawn
//            (WorldThingSpawned runs from PostBeginPlay, after the spawner has set
//            its velocity) and read at the next WorldTick, after it has moved once
//            and had one tic of gravity: speed, its own gravity factor, and how far
//            above the hand's line it left. That is everything a ballistic path
//            needs. Only something that leaves ALONG the gun counts: within 30 deg
//            of where the hand points and from near the hand -- Brutal Doom's brass
//            and magazines are gravity projectiles owned by the player too, and
//            they fly sideways.
//
// Per weapon class AND fire mode: a rifle's alt-fire grenade is "Rifle#alt" and
// never turns the rifle's primary into an arc. What is drawn is the primary.
//
// A STATIC handler, so what was learned lasts the whole session across map
// changes (a per-level handler is shut down on every unload). It is not written
// to savegames; after loading a game the guns are re-learned on their next shot.
// Console player only: what is drawn is drawn for that player.
class RSQLS_Learn : StaticEventHandler
{
	const BINS = 60;            // spread histogram: 0.25 degree bins up to 15
	const BIN_W = 0.25;

	Array<String> keys;
	Array<int>    binsH, binsV; // BINS per key
	Array<int>    hits;
	Array<double> pSpeed, pGrav, pElev, pYaw;
	Array<bool>   pKnown;

	private Array<Actor> pend;
	private Array<int>   pendAlt;

	clearscope int Find(String k) const
	{
		for (int i = 0; i < keys.Size(); i++) if (keys[i] == k) return i;
		return -1;
	}

	private int Slot(String k)
	{
		int i = Find(k);
		if (i >= 0) return i;
		keys.Push(k); hits.Push(0);
		for (int b = 0; b < BINS; b++) { binsH.Push(0); binsV.Push(0); }
		pSpeed.Push(0); pGrav.Push(0); pElev.Push(0); pYaw.Push(0); pKnown.Push(false);
		return keys.Size() - 1;
	}

	private static String KeyOf(Weapon w, bool alt) { String k = w.GetClassName(); return alt ? k .. "#alt" : k; }

	private static bool AltHeld(PlayerInfo p, bool off)
	{
		int b = p.cmd.buttons;
		return off ? (b & BT_OFFHANDALTATTACK) != 0 : (b & BT_ALTATTACK) != 0;
	}

	// The angle 95% of this weapon's shots fall inside, per axis; (0, 0) until it
	// has fired three hitscans.
	static clearscope double, double Spread(Weapon w)
	{
		let me = RSQLS_Learn(StaticEventHandler.Find("RSQLS_Learn"));
		if (!me || !w) return 0, 0;
		int i = me.Find(w.GetClassName());
		if (i < 0 || me.hits[i] < 3) return 0, 0;
		return me.Pct(i, false), me.Pct(i, true);
	}

	clearscope double Pct(int i, bool vert) const
	{
		int need = int(ceil(hits[i] * 0.95));
		int acc = 0;
		for (int b = 0; b < BINS; b++)
		{
			acc += vert ? binsV[i * BINS + b] : binsH[i * BINS + b];
			if (acc >= need) return (b + 1) * BIN_W;
		}
		return BINS * BIN_W;
	}

	// Its thrown projectile: known, speed (units/tic), gravity factor, elevation
	// above the hand's line (degrees), yaw off it (degrees).
	static clearscope bool, double, double, double, double Arc(Weapon w)
	{
		let me = RSQLS_Learn(StaticEventHandler.Find("RSQLS_Learn"));
		if (!me || !w) return false, 0, 0, 0, 0;
		int i = me.Find(w.GetClassName());
		if (i < 0 || !me.pKnown[i]) return false, 0, 0, 0, 0;
		// A GUN THAT FIRES HITSCANS IS NOT A LOB (rig 2026-10-31): Brutal Doom's shotguns also throw gravity tracers
		// and particles along the barrel, which read as a grenade's arc and dropped the dot short after the first
		// shot. A hit seen for this weapon means its shot is the straight line.
		if (me.hits[i] > 0) return false, 0, 0, 0, 0;
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
		if (dA >= BINS * BIN_W || dP >= BINS * BIN_W) return false;   // not a spread: something else aimed it
		int i = Slot(KeyOf(w, AltHeld(pmo.player, off)));
		binsH[i * BINS + int(dA / BIN_W)]++;
		binsV[i * BINS + int(dP / BIN_W)]++;
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
			// Which hand threw it: the nearer grip to where it was a tic ago --
			// and it must have been NEAR one (a casing ejects from the gun too,
			// but a thing from across the room is not this gun's shot).
			Vector3 was = m.pos - m.vel;
			double d0 = (was - pmo.AttackPos).Length(), d1 = (was - pmo.OffhandPos).Length();
			int h = (d0 <= d1) ? 0 : 1;
			if (min(d0, d1) > 96) continue;
			Weapon w = (h == 0) ? pmo.player.ReadyWeapon : pmo.player.OffhandWeapon;
			if (!w) continue;
			// One tic of gravity has been applied since it left (the engine
			// applies it above floorz + 2): put that back.
			double g = level.gravity * m.CurSector.gravity * m.Gravity * 0.00125;
			Vector3 v = m.vel;
			if (m.pos.z > m.floorz + 2) v.z += g;
			double sp = v.Length();
			if (sp < 6) continue;   // brass and magazines are slow
			// ALONG THE GUN, or it is not the gun's shot.
			Vector3 aim = RSQLS_Hand.Dir(pmo, h);
			if ((v / sp) dot aim < cos(30)) continue;
			double vPitch = atan2(v.z, v.xy.Length());
			double vYaw = atan2(v.y, v.x);
			int i = Slot(KeyOf(w, AltHeld(pmo.player, h == 1)));
			pSpeed[i] = sp;
			pGrav[i]  = m.Gravity;
			pElev[i]  = vPitch - RSQLS_Hand.Pitch(pmo, h);
			pYaw[i]   = Actor.DeltaAngle(RSQLS_Hand.Yaw(pmo, h), vYaw);
			pKnown[i] = true;
		}
	}
}
