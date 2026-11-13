// playerrounds.zs (BD 2.0, owner 2026-10-27 11:21): "Player Ballistics: Hitscan / Bullet".
//
// HITSCAN (0, the default) is BD22 as it ships: nothing here runs.
// BULLET  (1) the player's hitscans fly as real rounds. Ported from the owner's RS_Ballistics,
//         zscript/rsb/enemyfire.zs (presidentkoopa/rs_ballistics), which does this for MONSTERS:
//         WorldHitscanPreFired cancels the hitscan and a round flies along the shot's own aim at
//         sv_rsb_enemy_round_speed (80 map units a tic, its default) instead. Same here, for you.
//
// WHAT IS KEPT EXACTLY (the shotgun stays a shotgun):
//   * PELLETS AND SPREAD. A_FireBullets calls LineAttack once per pellet with that pellet's
//     spread already rolled into its angle and pitch, so every LineAttack is one event and one
//     round. Four pellets are four rounds, each on the line the hitscan pellet would have taken.
//   * WHERE IT POINTS. In VR the engine does not trace along the event's angle: it maps it
//     through the weapon controller (p_map.cpp P_LineAttack, AttackDir). The round takes that
//     same AttackDir (OffhandDir for an off-hand gun), so it flies the hitscan's line.
//   * DAMAGE, DAMAGE TYPE, PUFF, BLOOD, DECALS, KILL CREDIT. A round does NOT deal damage as a
//     missile. When its flight reaches something, it fires the ORIGINAL hitscan -- the event's
//     own damage, damage type and puff class -- from where it is, for the rest of the original
//     range. That last stretch is the engine's own P_LineAttack, so BD22's puff picks the damage
//     type (Shotgun, Minigun, Saw...), BLOODLESSIMPACT, MTHRUSPECIES and the decal all apply as
//     they always did. LAF_TARGETISSOURCE makes the player the damage source: the kill is yours.
//     A_FireBullets has already rolled the damage before the event (FBF_NORANDOM on every BD22
//     gun), so not one random call is added or removed.
//   * WHERE IT STARTS. The drawn muzzle, RSQ_Muzzle.Where (muzzle.zs), with its wall guard; off
//     the table, or with the guard saying no, where the engine would have started the hitscan.
//
// WHAT IS LEFT A HITSCAN, on purpose:
//   * a hitscan shorter than MISSILERANGE (2048): melee, and the SSG's 300-unit point-blank
//     blast (SSG.dec: A_FireBullets(0, 0, 1, 40, "shotpuff", FBF_NORANDOM, 300)) -- the same
//     rule enemyfire.zs uses;
//   * rails (the Ruger's 30-damage "Heavy penetration" rail, the Railgun): they are not hitscan
//     events, and a rail pierces, which a round does not;
//   * anything a non-player fires, and the round's own last-stretch hitscan.
//
// THE ROUND ITSELF never collides as a missile (+NOINTERACTION): each tic it traces its own
// next step with LineTrace -- traced as the SHOOTER, because the drawn muzzle can sit inside the
// player's own box and the engine's hitscan never hits its shooter either (rig, 2026-10-27: a
// pistol held out to the right shot its owner until this) -- and moves there if the step is clear.
// It looks like Dakka's shotgun tracer (owner 2026-10-27 20:09): a DPUF A head and Dakka's dots behind
// it (shotfx.zs). The btracer.obj streak it first used is gone.
//
// ORDER. It must see the shot AFTER RSQ_Recoil and RSQ_FlashHandler (they watch the same event
// and would never see a cancelled one) and after RSQ_Muzzle (whose re-fire from the muzzle,
// LAF_ABSPOSITION, is the event taken here). SetOrder puts this handler last.
//
// NETPLAY. sv_rsq_true_bullets is a server cvar (it decides where shots go). The round is
// playsim: spawned from the event, moved by traces, no random numbers.

class RSQ_PlayerRound : Actor
{
	Default
	{
		+NOINTERACTION;
		+NOBLOCKMAP;
		+NOGRAVITY;
		+DONTSPLASH;
		+NOTELEPORT;
		Radius 1;
		Height 1;
		+FORCEXYBILLBOARD;
		RenderStyle "Add";
		Alpha 0.5;
		Scale 0.5;
	}

	// the hitscan it carries
	double shotAngle, shotPitch;	// world direction (already through AttackDir)
	double rangeLeft;				// of the original AttackDistance
	int dmg;
	Name dmgType;
	class<Actor> puffType;
	int laf;						// the original line-attack flags, minus position/hand bits
	Vector3 dir;
	double flySpeed;
	int life;
	int maxLife;					// 2.0.5: enough tics for the whole range at the slider's speed
	double dotCarry;				// shotfx.zs: where the next Dakka dot falls on the next step

	const MAX_LIFE = 350;			// 10 s: 8192 units at 80 a tic is 103 tics

	void Setup(Actor shooter, Vector3 at, double ang, double pit, double dist, int damage, Name dtype,
		class<Actor> puff, int flags, double spd)
	{
		target = shooter;
		Species = shooter.GetSpecies();	// MTHRUSPECIES puffs compare with the CALLER's species: the round fires the last stretch
		shotAngle = ang;
		shotPitch = pit;
		angle = ang;
		pitch = pit;
		double cp = cos(pit);
		dir = (cp * cos(ang), cp * sin(ang), -sin(pit));
		rangeLeft = dist;
		dmg = damage;
		dmgType = dtype;
		puffType = puff;
		laf = flags & ~(LAF_ABSPOSITION | LAF_ABSOFFSET | LAF_ISOFFHAND | LAF_OVERRIDEZ | LAF_TARGETISSOURCE);
		flySpeed = spd;
		maxLife = max(MAX_LIFE, int(dist / max(spd, 1.0)) + 35);
	}

	override void Tick()
	{
		if (isFrozen())
			return;
		if (life++ > maxLife || rangeLeft <= 0)
		{
			Destroy();
			return;
		}
		double step = min(flySpeed, rangeLeft);
		// Traced AS THE SHOOTER, as the engine's own hitscan is (P_LineAttack never hits t1): the
		// muzzle can sit inside the player's own box, and a round must not shoot its owner.
		// TRF_ABSPOSITION without TRF_USEWEAPON: a plain line from here, no VR remapping.
		let src = target;
		FLineTraceData t;
		if (src)
			src.LineTrace(shotAngle, step, shotPitch, TRF_ABSPOSITION, pos.z, pos.x, pos.y, t);
		else
			LineTrace(shotAngle, step, shotPitch, TRF_ABSPOSITION, pos.z, pos.x, pos.y, t);
		if (t.HitType != TRACE_HitNone)
		{
			Arrive(t.Distance);
			return;
		}
		rangeLeft -= step;
		Vector3 was = pos;
		SetOrigin(pos + dir * step, true);
		RSQ_ShotFX.RoundStep(was, pos, flySpeed, dotCarry);	// "True Bullets: On": the Dakka tracer follows the round
	}

	// Something is within this tic's step, `dist` ahead: deliver the hitscan from just short of
	// it, for the rest of the original range. Starting 2 units short keeps the shooter's own box
	// behind the start, and from there the engine does everything a BD22 hitscan does.
	void Arrive(double dist)
	{
		let src = target;
		if (src && puffType)
		{
			double back = max(0.0, dist - 2.0);
			SetOrigin(pos + dir * back, false);
			rangeLeft -= back;
			RSQ_PlayerRounds.SetDelivering(true);
			LineAttack(shotAngle, max(rangeLeft, 4.0), shotPitch, dmg, dmgType, puffType,
				laf | LAF_ABSPOSITION | LAF_TARGETISSOURCE, null, pos.z, pos.x, pos.y);
			RSQ_PlayerRounds.SetDelivering(false);
		}
		Destroy();
	}

	States
	{
	Spawn:
		RSDP A -1 Bright;	// Dakka's tracer dot (DPUF A) as the round's head; shotfx.zs lays the trail
		Stop;
	}
}

class RSQ_PlayerRounds : EventHandler
{
	const ROUND_SPEED = 80.0;	// map units a tic: RS_Ballistics' sv_rsb_enemy_round_speed default (CVARINFO.txt)

	// 2.0.5 (owner 2026-11-09): the "True Bullet Speed" slider, sv_rsq_round_speed (CVARINFO.rsx). ROUND_SPEED is its default (renamed from SPEED 11-09: ZScript names are case-insensitive, so the const SPEED and Speed() clashed: "Attempt to redefine Speed").
	static double Speed()
	{
		let cv = CVar.FindCVar('sv_rsq_round_speed');
		return cv ? clamp(cv.GetFloat(), 10.0, 1000.0) : ROUND_SPEED;
	}

	bool delivering;

	override void OnRegister()
	{
		SetOrder(1000);	// after recoil, the flash and the muzzle (see ORDER above)
	}

	static void SetDelivering(bool on)
	{
		let h = RSQ_PlayerRounds(EventHandler.Find('RSQ_PlayerRounds'));
		if (h)
			h.delivering = on;
	}

	static bool On()
	{
		let cv = CVar.FindCVar('sv_rsq_true_bullets');	// "True Bullets: On / Off" (CVARINFO.rsx)
		return cv && cv.GetBool();
	}

	// THE OFF-HAND MUZZLE (round 4). muzzle.zs moves only the main hand's shots; a dual-wield copy's hitscan
	// (LAF_ISOFFHAND) starts at the off controller. The copies are subclasses of their guns with the same
	// MODELDEF placement (MODELDEF.rsqoff), so RSQ_Muzzle's table holds for them, in the off controller's
	// frame (OffhandPos, OffhandDir: the engine's mirrored left-hand frame, the one the off layers are drawn
	// in). Same wall guard as muzzle.zs.
	static Vector3, bool OffWhere(PlayerPawn mo)
	{
		Vector3 at; bool ok;
		[at, ok] = RSQ_Muzzle.OffWhere(mo);	// fix-accuracy: moved to muzzle.zs (its missiles need it; ZSCRIPT.rsvr compiles before this file)
		return at, ok;
	}

	bool offBusy;

	override bool WorldHitscanPreFired(WorldEvent e)
	{
		if (delivering || offBusy)
			return false;
		let mo = PlayerPawn(e.Thing);
		if (!mo || !mo.player)
			return false;
		bool off = (e.AttackLineFlags & LAF_ISOFFHAND) != 0;
		if (!On())
		{	// Hitscan mode: an off-hand shot is re-fired from the off-hand muzzle, as muzzle.zs does for the main hand
			if (!off || (e.AttackLineFlags & LAF_ABSPOSITION) || (e.AttackLineFlags & LAF_ISMELEEATTACK))
				return false;
			Vector3 oat; bool ook;
			[oat, ook] = OffWhere(mo);
			// fix-accuracy: down the off gun's drawn barrel (RSQ_Muzzle.Bore, the same row in the mirrored off frame),
			// from its muzzle or, guard saying no, its controller
			let ow = mo.player.OffhandWeapon;
			bool obore = RSVR_VRHand.InVR(mo) && RSQ_Muzzle.HasBore(ow);
			if ((!ook || e.AttackDistance < MISSILERANGE) && !obore)
				return false;
			double oda = 0, odp = 0;
			if (obore)
				[oda, odp] = RSQ_Muzzle.AimOffset(ow, RSQ_Muzzle.FromFLU(ow, ook));
			offBusy = true;
			mo.LineAttack(e.AttackAngle + oda, e.AttackDistance, e.AttackPitch + odp, e.Damage, e.DamageType, e.AttackPuffType,
				e.AttackLineFlags | LAF_ABSPOSITION, null, oat.z, oat.x, oat.y);
			offBusy = false;
			return true;
		}
		if (e.AttackDistance < MISSILERANGE || !e.AttackPuffType)
			return false;

		// THE START: muzzle.zs's re-fire hands it to us as absolute coordinates; otherwise the
		// muzzle is worked out here the same way, so the order of the handlers cannot change it.
		Vector3 at;
		bool ok = false;
		if (e.AttackLineFlags & LAF_ABSPOSITION)
			at = (e.AttackOffsetForward, e.AttackOffsetSide, e.AttackZ);
		else
		{
			if (!off)
				[at, ok] = RSQ_Muzzle.Where(mo);
			else
				[at, ok] = OffWhere(mo);
			if (!ok)
			{
				if (mo.OverrideAttackPosDir)
					at = off ? mo.OffhandPos : mo.AttackPos;
				else
				{
					double sz = mo.Height * 0.5 - mo.Floorclip + mo.player.mo.AttackZOffset * mo.player.crouchFactor + e.AttackZ;
					at = mo.pos + (0, 0, sz);
				}
			}
		}

		// THE LINE: the engine's own mapping of the event's angles through the controller
		// fix-accuracy: an off-hand shot that was not re-fired above is turned onto the off gun's drawn barrel here (a main-hand
		// one arrives from muzzle.zs already turned: its angles carry the bore)
		double ang = e.AttackAngle, pit = e.AttackPitch;
		if (off && !(e.AttackLineFlags & LAF_ABSPOSITION) && RSVR_VRHand.InVR(mo) && RSQ_Muzzle.HasBore(mo.player.OffhandWeapon))
		{
			double oda, odp;
			[oda, odp] = RSQ_Muzzle.AimOffset(mo.player.OffhandWeapon, RSQ_Muzzle.FromFLU(mo.player.OffhandWeapon, ok));
			ang += oda;
			pit += odp;
		}
		if (mo.OverrideAttackPosDir)
		{
			Vector3 ap = off ? mo.OffhandDir(mo, ang, pit) : mo.AttackDir(mo, ang, pit);
			ang = ap.x;
			pit = ap.y;
		}

		let r = RSQ_PlayerRound(Actor.Spawn('RSQ_PlayerRound', at, ALLOW_REPLACE));
		if (!r)
			return false;
		r.Setup(mo, at, ang, pit, e.AttackDistance, e.Damage, e.DamageType, e.AttackPuffType,
			e.AttackLineFlags, Speed());
		return true;	// the hitscan is not run now: the round carries it
	}

	// THE RUGER'S PIERCING RAIL in Bullet mode (owner 20:05: "a flying round that pierces"). BD22:
	// actors/Weapons/Sniper.dec:266 A_RailAttack(30, 0, 0, "none", "None", RGF_SILENT, 0, "sniperpuff",
	// 0, 0, 500, ...): 30 damage to every shootable thing on the line, 500 units, stopped by walls, damage
	// type the puff's (SniperPuff: SniperDamage; p_map.cpp P_RailAttack). In Hitscan mode the rail itself
	// runs: it draws nothing (colour None) and IS the piercing shot. Here a piercing round carries it.
	override bool WorldRailgunPreFired(WorldEvent e)
	{
		if (delivering || !On())
			return false;
		let mo = PlayerPawn(e.Thing);
		if (!mo || !mo.player || e.Damage <= 0 || !RSQ_ShotFX.IsRuger(mo) || (e.RailParams.flags & RGF_ISOFFHAND))
			return false;
		Vector3 at; bool ok;
		[at, ok] = RSQ_Muzzle.Where(mo);
		if (!ok)
			at = mo.OverrideAttackPosDir ? mo.AttackPos : mo.pos + (0, 0, mo.Height * 0.5 - mo.Floorclip + mo.AttackZOffset * mo.player.crouchFactor);
		double ang = e.AttackAngle, pit = e.AttackPitch;
		if (mo.OverrideAttackPosDir)
		{
			Vector3 ap = mo.AttackDir(mo, e.AttackAngle, e.AttackPitch);
			ang = ap.x;
			pit = ap.y;
		}
		let r = RSQ_PiercingRound(Actor.Spawn('RSQ_PiercingRound', at, ALLOW_REPLACE));
		if (!r)
			return false;
		r.Setup(mo, at, ang, pit, e.AttackDistance, e.Damage, e.DamageType, e.AttackPuffType, 0, Speed());
		return true;
	}
}

// The Ruger's piercing round. It flies with the Ruger's SniperPuff rounds (whose Dakka look already shows the
// bullet), so it draws nothing itself. Every shootable thing its step reaches takes the rail's damage once, as a
// hitscan from 2 units short of it with the rail's puff and damage type, credited to the player; walls stop it.
class RSQ_PiercingRound : RSQ_PlayerRound
{
	Array<Actor> struck;

	Default
	{
		RenderStyle "None";
	}

	override void Tick()
	{
		if (isFrozen())
			return;
		if (life++ > maxLife || rangeLeft <= 0)
		{
			Destroy();
			return;
		}
		double step = min(flySpeed, rangeLeft);
		let src = target;
		Vector3 start = pos;
		Vector3 p = pos;
		double done = 0;
		for (int guard = 0; guard < 32 && done < step; guard++)
		{
			FLineTraceData t;
			Actor tracer = src ? src : Actor(self);
			tracer.LineTrace(shotAngle, step - done, shotPitch, TRF_ABSPOSITION, p.z, p.x, p.y, t);
			if (t.HitType == TRACE_HitNone)
				break;
			if (t.HitType != TRACE_HitActor)
			{	// a wall, floor or ceiling ends it: the puff and decal there, as the rail leaves them, no damage
				Hit(p, t.Distance, 0);
				Destroy();
				return;
			}
			if (struck.Find(t.HitActor) == struck.Size())
			{
				struck.Push(t.HitActor);
				Hit(p, t.Distance, dmg);
			}
			// on through it
			double past = t.Distance + 1.0;
			p += dir * past;
			done += past;
		}
		rangeLeft -= step;
		SetOrigin(start + dir * step, true);
	}

	// the rail's damage on the first thing ahead, from 2 units short of it, reaching only just past it
	void Hit(Vector3 p, double dist, int damage)
	{
		let src = target;
		if (!src || !puffType)
			return;
		double back = max(0.0, dist - 2.0);
		Vector3 from = p + dir * back;
		RSQ_PlayerRounds.SetDelivering(true);
		LineAttack(shotAngle, 6.0, shotPitch, damage, dmgType, puffType,
			LAF_ABSPOSITION | LAF_TARGETISSOURCE, null, from.z, from.x, from.y);
		RSQ_PlayerRounds.SetDelivering(false);
	}
}
