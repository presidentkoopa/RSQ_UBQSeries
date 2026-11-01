// RSQ Grenade -- WHAT LEAVES THE HAND. A projectile with the velocity the throw gave it; Doom does the falling, the
// floors and the walls. The flight numbers are RS_Grenade's (the owner's): gravity 0.27 (Doom's gravity is about 2.7x
// a real one, and a throw leaves at what the arm did), floor bounce 0.5, wall bounce 0.25, ground drag 0.82, a lazy
// tumble that settles flat on the floor. Unlike RS_Grenade it also bounces off monsters (the UAC Survival Pack's
// J_ThrownGrenade does, +ALLOWBOUNCEONACTORS), so only the fuse sets it off.
//
// The damage is ITS OWN A_Explode (RS_Grenade's / the pack's numbers: 85 over 200, then 75 over 255), so the kill,
// the obituary and any score go to the player who threw it (target). The look is RSQGN_Blast (blast.zs).
class RSQGN_Thrown : Actor
{
	int fuse;			// tics left (a cooked grenade arrives with less)
	int fuseTotal;
	int flashNext, redUntil;
	bool boomed;
	bool hot;

	Default
	{
		Projectile;
		-NOGRAVITY;
		-BLOODSPLATTER;
		Radius 3;
		Height 3;
		Mass 5;
		Speed 20;
		Damage 0;			// the blast does the damage, not the hit
		Gravity 0.27;
		Scale 0.3;			// the pack's sprite size, for the sprite drawn when models are off
		+MOVEWITHSECTOR;
		+FORCEXYBILLBOARD;
		BounceType "Doom";
		BounceFactor 0.5;
		WallBounceFactor 0.25;
		+BOUNCEONACTORS;
		+ALLOWBOUNCEONACTORS;
		+CANBOUNCEWATER;
		BounceSound "rsqgn/bounce";
		DamageType "Explosive";
		Obituary "%o was popped by %k's grenade";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		if (fuse <= 0) fuse = RSQGN_Handler.FuseTics();
		if (fuseTotal <= 0) fuseTotal = fuse;
		roll = random[RSQGN_Spin](0, 359);
		pitch = random[RSQGN_Spin](0, 359);
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed || boomed || IsFrozen()) return;

		bool grounded = pos.z <= floorz + 0.25 || bOnMobj;		// on the floor, or come to rest on top of a monster
		// AT REST IT IS NO LONGER A MISSILE. Doom's bounce switches itself off once a floor bounce comes back under
		// 3 units a tic (BOUNCE_AutoOff clears every bounce flag), and a missile with no bounce that rolls into a wall
		// or a monster explodes on it -- a grenade going off early because it rolled. So once its bouncing is over it
		// becomes a plain thing that slides and stops; only the fuse sets it off.
		if (bMissile && (!bBOUNCEONWALLS || (grounded && abs(vel.z) < 0.6)))
			bMissile = false;

		if (!grounded)
		{
			roll += 3.5;			// RS_Grenade: about one lazy turn per two seconds, not a neat ratio
			pitch += 3.5 * 0.43;
		}
		else
		{
			// lie down: eased onto its side (pitch 90), the short way round
			roll = Normalize180(roll - Normalize180(roll) * 0.25);
			pitch = Normalize180(pitch - Normalize180(pitch - 90) * 0.25);
			double f = clamp(RSQGN_Handler.SNum("rsqgn_friction", 0.82), 0.1, 1.0);
			vel.x *= f;
			vel.y *= f;
			if (vel.xy.Length() < 0.12) { vel.x = 0; vel.y = 0; }
		}

		if (fuse > 0)
		{
			fuse--;
			if (level.maptime >= flashNext)
			{
				int per = RSQGN_Handler.FlashPeriod(fuse, fuseTotal);
				redUntil = level.maptime + max(1, per / 2);
				flashNext = level.maptime + per;
				A_StartSound("rsqgn/tick", CHAN_5, CHANF_OVERLAP, fuse < TICRATE ? 0.85 : 0.5);
				if (target && target.player && RSQGN_Handler.Debug(target.player))
					Console.Printf("RSQGN flash thrown t%d period %d left %d at (%.0f %.0f %.0f)%s", level.maptime, per, fuse, pos.x, pos.y, pos.z, bMissile ? "" : " resting");
			}
			bool red = level.maptime < redUntil;
			if (red != hot)
			{
				hot = red;
				if (red) SetStateLabel("Hot"); else SetStateLabel("Spawn");
			}
		}
		else Detonate();
	}

	void Detonate()
	{
		if (boomed) return;
		boomed = true;		// latched first: Tick keeps running after the state change
		bMissile = false;
		vel = (0, 0, 0);
		if (target && target.player && RSQGN_Handler.Debug(target.player))
			Console.Printf("RSQGN boom thrown t%d at (%.0f %.0f %.0f)", level.maptime, pos.x, pos.y, pos.z);
		SetStateLabel("Boom");
	}

	States
	{
	Spawn:
		QGNT A -1;
		Stop;
	Hot:
		QGNT B -1 Bright;
		Stop;
	// the engine sends a missile here when it cannot bounce (a damaging floor, its bounce count): it goes off
	Death:
		TNT1 A 0 { boomed = true; }
		Goto Boom;
	Boom:
		TNT1 A 0 A_NoBlocking;
		TNT1 A 0 A_StartSound("rsqgn/explode", CHAN_AUTO);
		TNT1 A 0 A_StartSound("rsqgn/farexpl", CHAN_7);
		TNT1 A 0 A_AlertMonsters;
		TNT1 A 0 A_SpawnItemEx("RSQGN_Blast", 0, 0, 0, 0, 0, 0, 0, SXF_NOCHECKPOSITION);
		TNT1 A 1 A_Explode(85, 200, XF_HURTSOURCE);
		TNT1 A 1 A_Explode(75, 255, XF_HURTSOURCE);
		Stop;
	}
}
