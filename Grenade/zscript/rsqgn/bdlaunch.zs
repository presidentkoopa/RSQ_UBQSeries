// =====================================================================================================================
// BRUTAL DOOM'S LAUNCHERS USE OUR BLAST (owner 2026-11-09: "ensure that bds rpg and grenade launcher point to it").
// Brutal Doom's rocket (Rocket2, Rocket2Fast, RocketDM) and launcher grenades (GrenadeMissile, ShortGrenade2) go off
// through separate actors: one deals the damage (RocketExplosion / GrenadeExplosion / UGBLExplosion: A_Explode) and the
// rest only draw (flares, flames, smoke, particles, shockwaves). Here, by class name (nothing links; without Brutal Doom
// nothing matches): when one of those shots goes off, our blast (explosions.zs, the grenade's) plays where it went off
// and the drawing-only actors its explosion spawns there are removed. Brutal Doom's damage, sounds, quake, craters and
// scorch stay as they are. Option: Explosions > Brutal Doom's Launchers (rsqgn_bd_launchers, on).
// Rockets play the approved rocket blast (renders/rocket; flip.zs: floor within 24 units of the floor, else air; a wall
// hit plays the air one), grenades the grenade's.
// =====================================================================================================================
class RSQGN_BDLaunchers : EventHandler
{
	Array<Actor> shots;                  // live Brutal Doom launcher shots
	Array<double> bx, by, bz;            // where one went off: drawing-only actors spawned near it these tics are removed
	Array<int> bUntil;
	int removed;                         // Brutal Doom drawing-only actors removed (the debug log)

	const NEAR = 64.0;                   // its explosion's own actors spawn on it (A_SpawnItemEx at 0,0,13; A_CustomMissile)
	const HOLD = 6;                      // RocketExplosion's own shockwave and bursts come 0-3 tics after

	static bool On() { let c = CVar.FindCVar("rsqgn_bd_launchers"); return !c || c.GetBool(); }

	static bool IsShot(Name n)
	{
		return n == 'Rocket2' || n == 'Rocket2Fast' || n == 'RocketDM' || n == 'GrenadeMissile' || n == 'ShortGrenade2';
	}

	// Brutal Doom's drawing-only explosion actors (brutal22test6: Explosives.dec, FLARES.dec, Fire.dec, Smoke.dec,
	// Particles.dec, FIREWORKS.dec, BFG.dec): never the damage, the craters or the splash
	static bool IsLook(Actor a)
	{
		Name n = a.GetClassName();
		return n == 'ExplosionFlareSpawner' || n == 'MediumExplosionFlames' || n == 'ExplosionSmokeHD'
			|| n == 'HorizontalShockwave' || n == 'BDExplosionparticlesBig' || n == 'BDExplosionparticles2'
			|| n == 'BDExplosionparticles' || n == 'WhiteShockwave' || n == 'WhiteShockwaveBig'
			|| n == 'ExplosionAirBurstEffectSmall' || n == 'ExplosionAirBurstEffect';
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.thing;
		if (!a || !On()) return;
		if (IsShot(a.GetClassName())) { shots.Push(a); return; }
		if (!IsLook(a)) return;
		// one of our tracked shots going off here: our blast, once
		for (int i = shots.Size() - 1; i >= 0; i--)
		{
			let s = shots[i];
			if (!s) { shots.Delete(i); continue; }
			if (s.bMissile && s.InStateSequence(s.CurState, s.SpawnState)) continue;   // still flying (its trail)
			if (s.Distance3D(a) > NEAR) continue;
			Name sn = s.GetClassName();
			if (sn == 'Rocket2' || sn == 'Rocket2Fast' || sn == 'RocketDM')
			{
				let fb = RSQGN_Flip.PlayAt(s.pos, s.pos.z - s.floorz < 24 ? RSQGN_FlipData.ROCKET_FLOOR : RSQGN_FlipData.ROCKET_AIR);
				// the rocket's own boom (the owner's mapwpn005) and the spray's pops, over Brutal Doom's own sound; on the
				// flipbook, which lives as long as the blast (the actor that told us is removed this tic)
				if (fb && RSQGN_Fx.Kinetic(false))
				{
					fb.A_StartSound("rsqgn/k/rocket", CHAN_AUTO, CHANF_OVERLAP, 0.9, ATTN_NORM);
					RSQGN_Pops.Go(s.pos, 3, 2, 3, 0.8);
				}
			}
			else
				RSQGN_Boom.ForGrenade(s, 0);
			let dbg = CVar.FindCVar("rsqgn_debug");
			if (dbg && dbg.GetInt() > 0) Console.Printf("RSQGN BD launcher: %s went off, our blast", s.GetClassName());
			bx.Push(s.pos.x); by.Push(s.pos.y); bz.Push(s.pos.z); bUntil.Push(level.maptime + HOLD);
			shots.Delete(i);
			break;
		}
		for (int j = 0; j < bx.Size(); j++)
		{
			if (bUntil[j] < level.maptime) continue;
			if ((a.pos - (bx[j], by[j], bz[j])).Length() <= NEAR + 16) { removed++; a.Destroy(); return; }
		}
	}

	override void WorldTick()
	{
		for (int j = bx.Size() - 1; j >= 0; j--)
			if (bUntil[j] < level.maptime) { bx.Delete(j); by.Delete(j); bz.Delete(j); bUntil.Delete(j); }
		if (level.maptime % 35 == 0) for (int i = shots.Size() - 1; i >= 0; i--) if (!shots[i]) shots.Delete(i);
	}
}
