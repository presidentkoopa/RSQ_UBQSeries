// WALL SPLAT, the move (the owner's pick 54; Quest teardown surveys/01_MELEE.md 4.7, "wall bounce"): a monster your
// punch knocks into a wall slams into it, hurts, bounces off and reels. Moved from RSQ Gun Bonsai VR's up_gloves.zs on
// 2026-11-01 with its class names (a save may hold them). The upgrade (offering it, its level, its numbers) stays in
// Gun Bonsai VR as RSQ_Upgrade_WallSplat; without Gun Bonsai VR the Wall Splat row plays it at level 1.

// WHAT A PUNCHED MONSTER CARRIES WHILE IT FLIES (Wall Splat). Armed by the punch; looks at the monster's own
// movement once a tic. MovementBlockingLine is the engine's "a wall refused this tic's velocity move" (it is cleared
// before every XY move and set only when the move is refused: p_mobj.cpp AActor::Tick, P_XYMovement), and a monster
// that is blocked has its velocity zeroed there -- so the speed it hit with is the one remembered from the tic before.
// Walking (A_Chase's own steps) never sets it. The frozen tics of a hit-stop do not count: a frozen monster's Tick
// stops before its inventory's DoEffect.
class RSQ_Splat : Inventory
{
	PlayerPawn by;
	Weapon glove;
	int lv, left;
	Vector2 lastVel;

	const WINDOW = 12;          // tics of flight a punch arms it for
	const MIN_SPEED = 3.0;      // map units a tic into the wall (the teardown's BOUNCE_MIN_SPEED)
	const RESTITUTION = 0.45;   // the teardown's BOUNCE_RESTITUTION

	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }

	static void Arm(Actor mo, PlayerPawn pawn, Weapon glove, int lv)
	{
		if (!mo || mo.health <= 0 || mo.bDontThrust || mo.player) return;
		let s = RSQ_Splat(mo.FindInventory("RSQ_Splat"));
		if (!s) s = RSQ_Splat(mo.GiveInventoryType("RSQ_Splat"));
		if (!s) return;
		s.by = pawn; s.glove = glove; s.lv = lv;
		s.left = WINDOW;
		s.lastVel = mo.vel.xy;
	}

	override void DoEffect()
	{
		Super.DoEffect();
		let mo = owner;
		if (!mo || mo.health <= 0 || left <= 0) { Destroy(); return; }
		left--;
		double sp = lastVel.Length();
		if (mo.MovementBlockingLine && sp >= MIN_SPEED)
		{
			Slam(mo, sp);
			Destroy();
			return;
		}
		lastVel = mo.vel.xy;
	}

	private void Slam(Actor mo, double sp)
	{
		// the upgrade's numbers (Gun Bonsai VR's RSQ_Upgrade_WallSplat.Damage); level 1's without it: 10 at the slowest
		// slam that counts (3 map units a tic), up to twice that at 6 or more
		int dmg = int(RSQML.Num("WallSplat.damage", lv, sp, int(10 * clamp(sp / 3.0, 1.0, 2.0))));
		bool dbg = RSQML.Debug() > 0;
		if (dbg) Console.Printf("RSQML wall splat: %s at %.1f u/tic -> %d", mo.GetClassName(), sp, dmg);
		// THE SLAM IS THE GLOVE'S, but not a punch: paid to the glove through a helper it claims (the way the
		// ShieldSaw's returned bullet is paid; Gun Bonsai VR's "claim"), so Gun Bonsai credits that glove while the
		// glove upgrades -- which read the last punch off the glove itself -- do not count the slam as that punch again.
		Actor inf = by;
		if (glove && glove.owner)
		{
			let hit = Actor.Spawn("RSQ_SplatHit", mo.pos, NO_REPLACE);
			if (hit)
			{
				hit.target = by;
				RSQML.Claim(hit, glove);
				inf = hit;
			}
		}
		mo.SpawnBlood(mo.pos + (0, 0, mo.height * 0.5), VectorAngle(-lastVel.x, -lastVel.y), dmg);
		mo.A_StartSound("rsqml/smash", CHAN_AUTO, 0, 1.0);
		mo.DamageMobj(inf, by, dmg, 'Melee', DMG_THRUSTLESS);
		if (!mo || mo.health <= 0) return;
		mo.vel.xy = -lastVel * RESTITUTION;
		mo.freezetics = max(mo.freezetics, 5);   // the teardown's slam hit-stop
		RSQML.Stagger(mo, int(RSQML.Num("WallSplat.reel", lv, 0, 15)));   // RSQ_Upgrade_WallSplat.Reel; level 1: 15 tics
		if (by) { RSQ_Buzz.Start(by, 0, 0.5, 6); RSQ_Buzz.Start(by, 1, 0.5, 6); }
	}
}

// The slam's inflictor: nothing but a name Gun Bonsai can pay to the glove.
class RSQ_SplatHit : Actor
{
	Default { +NOINTERACTION +NOBLOCKMAP +NOSECTOR +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP RenderStyle "None"; }
	States { Spawn: TNT1 A 2; Stop; }
}
