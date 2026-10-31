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
	private transient double cSp[2];
	private transient Actor cM[2];
	private transient Weapon cW[2];
	private transient Vector3 cV[2];
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

	static String WName(Weapon w) { return w ? w.GetClassName() .. "" : "none"; }
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
			// WHICH HAND THREW IT (rig 2026-10-31: the nearer grip picked the wrong hand when both were close, and a
			// launcher's grenade was learned onto the empty off hand): of the hands it left near (within 96), the one
			// it left ALONG -- its velocity nearest that hand's aim, within 30 deg.
			double g = level.gravity * m.CurSector.gravity * m.Gravity * 0.00125;
			Vector3 v = m.vel;
			if (m.pos.z > m.floorz + 2) v.z += g;      // one tic of gravity has been applied since it left: put it back
			double sp = v.Length();
			Vector3 was = m.pos - m.vel;
			bool dbg = RSQLS_Hand.Flag("rsqls_debug", players[consoleplayer], false);
			int h = -1;
			double bestDot = cos(30);
			for (int hh = 0; hh < 2; hh++)
			{
				double dd = (was - RSQLS_Hand.Grip(pmo, hh)).Length();
				if (dd > 96 || sp <= 0) continue;
				double dt = (v / sp) dot RSQLS_Hand.Dir(pmo, hh);
				if (dt > bestDot) { bestDot = dt; h = hh; }
			}
			if (dbg) Console.Printf("[RSQLS] t%d missile %s speed %.1f grav %.2f hand %d", level.maptime, m.GetClassName(), sp, m.Gravity, h);
			if (h < 0 || sp < 6) continue;            // not along a gun; brass and magazines are slow
			Weapon w = (h == 0) ? pmo.player.ReadyWeapon : pmo.player.OffhandWeapon;
			if (!w) continue;
			// THE SHOT, NOT ITS SPARKS: a launcher puts out muzzle particles and a smoke trail with its grenade, all
			// gravity missiles along the gun. Only the fastest thing a hand put out this tic is its shot.
			if (sp <= cSp[h]) continue;
			cSp[h] = sp; cM[h] = m; cV[h] = v; cW[h] = w;
		}
		for (int h = 0; h < 2; h++)
		{
			Actor m = cM[h];
			Weapon w = cW[h];
			double sp = cSp[h];
			cSp[h] = 0; cM[h] = null; cW[h] = null;
			if (!m || !w) continue;
			let pmo = PlayerPawn(m.target);
			if (!pmo) continue;
			int i = Slot(KeyOf(w, AltHeld(pmo.player, h == 1)));
			// A known shot is not unlearned by something much slower (a smoke puff a tic later).
			if (pKnown[i] && sp < pSpeed[i] * 0.5) continue;
			Vector3 v = cV[h];
			pSpeed[i] = sp;
			pGrav[i]  = m.Gravity;
			pElev[i]  = atan2(v.z, v.xy.Length()) - RSQLS_Hand.Pitch(pmo, h);
			pYaw[i]   = Actor.DeltaAngle(RSQLS_Hand.Yaw(pmo, h), atan2(v.y, v.x));
			pKnown[i] = true;
			if (RSQLS_Hand.Flag("rsqls_debug", players[consoleplayer], false))
				Console.Printf("[RSQLS] LEARNED %s: %s speed %.1f grav %.2f elev %.1f yaw %.1f", keys[i], m.GetClassName(), sp, m.Gravity, pElev[i], pYaw[i]);
		}
	}
}
