// NOCTIS (RS_BlackArchEX, plus/RS_PlusBlackArchEX.zs; design/BIG_BOSS_REMAINING_B.md 25; owner-side call made: acts are
// its Phase 1, its Phase 3, its death's Void). From its own code only.
//   opener    act 1 its own Leaves, act 2 its own Shadowing: both open on its arms-up wind-up; held on the first frame with
//             tics, SILE G 4 (the sound and A_FaceTarget 0-tic lines skipped; not H: the framework holds one frame).
//             Act 3 (the Void) its own Summon: its count user_myeyes set to 8 as the window opens (the value its Missile
//             sends to Summon), held on SILE G 12. A MISS lets the state run: Leaves' four A_RadiusThrust(3000,400) and
//             leaf swarms; Shadowing's 12 RS_BVileEXWAVE3; the Void's Summon raising its revenants and Mr Bones.
//   points    acts 1-2 SILE H1: head (+0.05, 1.13), left hand (+1.55, 1.52), right hand (-1.70, 1.46)
//             act 3 the Void's SILE G1: head (+0.10, 1.11), left hand (+1.60, 1.52), right hand (-1.75, 1.45)
//   summons   acts 1-2 RS_MrBones (its own Pain spawn), EXPOSED! and the GUARD wave. Act 3 the Void's own Summon classes
//             (RS_CommonRevenant x2, RS_RedRevenant, RS_PurpleRevenant, RS_MrBones x4, in that share). Mr Bones its trail's
//             RS_ArchRingHelp raises are not its summons.
//   acts      1 its Phase 1; 2 its Phase 3 (RS_Act.zs hooks on its 900 and 1800 lines in See2 and Missile; marked, Phase 3
//             comes first, so its Phase 2 is not used); 3 its own Death's three RS_BlackArchEXVoid: it goes on as one Void
//             where it stands (body swap, the Black Knight's pattern, bigacts.zs KnightBody), the other two come as its
//             summons. The Void's own kit (BlackHole, KABAM, Shockwave, Shadowing by RS_VoidMode) as written.
class RSQMB_BK_RS_BlackArchEX : RSQMB_BigKit
{
	override String Card() { return "NOCTIS"; }
	override String Kind() { return "BLACK ARCH-VILE"; }
	override void Points(int act, Array<double> sx, Array<double> sy)
	{
		if (act >= 3) Pts(sx, sy, 0.10, 1.11, 1.60, 1.52, -1.75, 1.45);
		else Pts(sx, sy, 0.05, 1.13, 1.55, 1.52, -1.70, 1.46);
	}

	static bool IsVoid(Actor a) { return a && a.GetClassName() == 'RS_BlackArchEXVoid'; }

	override String OpenerFrame(RSQMB_Tele t, int act) { return act >= 3 ? "G" : "H"; }   // design 25: SILE H1; the Void G1
	override String Opener(RSQMB_Tele t, int act)
	{
		let mb = t.b ? t.b.mb : null;
		if (act >= 3 && IsVoid(mb))
		{
			mb.A_SetUserVar('user_myeyes', 8);
			return "Summon";
		}
		return act >= 2 ? "Shadowing" : "Leaves";
	}

	override int Summon(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p, bool guard, int n)
	{
		// the Void's Summon spawns 2 common, 1 red, 1 purple revenant and 4 Mr Bones: taken in that share
		static const String VOIDS[] = { "RS_CommonRevenant", "RS_MrBones", "RS_RedRevenant", "RS_MrBones",
			"RS_PurpleRevenant", "RS_MrBones", "RS_CommonRevenant", "RS_MrBones" };
		bool v = t.act >= 3 && IsVoid(t.b ? t.b.mb : null);
		int got = 0;
		for (int k = 0; k < n; k++)
		{
			String cn = v ? VOIDS[(k + (guard ? 1 : 0)) % VOIDS.Size()] : "RS_MrBones";
			Class<Actor> c = cn;
			if (c && t.SummonAt(h, c, p, (0, 0), 160, 320)) got++;
		}
		return got;
	}

	override void OnAct(RSQMB_Tele t, RSQMB_Handler h, int act)
	{
		let mb = t.b ? t.b.mb : null;
		if (act < 3 || !mb || mb.GetClassName() != 'RS_BlackArchEX') return;
		// its own Death (3 x RS_BlackArchEXVoid): one is the Big Boss's body, two are its summons
		let nb = SwapBody(t, h, "RS_BlackArchEXVoid");
		if (!nb) return;
		String cn = "RS_BlackArchEXVoid";    // a string first: resolved at run time (loads without RSQ Monsters)
		Class<Actor> c = cn;
		let p = t.Victim();
		Vector2 rt = (sin(nb.angle), -cos(nb.angle));
		for (int s = 0; s < 2; s++)
		{
			let v = t.SummonAt(h, c, p, rt * (s == 0 ? 96 : -96), 0, 0);
			if (!v) v = t.SummonAt(h, c, p, (0, 0), 96, 224);
			t.Keep(v);     // beside it, not the GUARD wave
		}
		if (h && h.debug) Console.Printf("RSQMB act t%d: boss %d is its Void, %d summons", level.maptime, t.b.idx, t.SumAlive());
	}

	// the Black Knight's body swap (bigacts.zs KnightBody): the new body where it stands, its health kept
	static play Actor SwapBody(RSQMB_Tele t, RSQMB_Handler h, String cn)
	{
		let b = t.b;
		let old = b ? b.mb : null;
		Class<Actor> c = cn;
		if (!old || !c) return null;
		if (h) h.swapNoRoll = c;           // carry.zs: Champions does not roll the new body
		let nb = Actor.Spawn(c, old.pos, NO_REPLACE);
		if (h) h.swapNoRoll = null;
		if (!nb) return null;
		nb.angle = old.angle;
		nb.target = old.target;
		int hp = old.health, mx = b.maxHP;
		t.ClearWeakPoints(true);
		t.Unpin(old);
		b.Rebody(-1, nb, h);
		nb.health = max(1, hp);
		b.maxHP = mx;
		if (nb.SeeState) nb.SetState(nb.SeeState);
		Actor.Spawn("TeleportFog", old.pos, ALLOW_REPLACE);
		old.ClearCounters();
		old.Destroy();
		t.ActMark();                       // the act's token on the new body
		if (h && h.debug) Console.Printf("RSQMB act t%d: boss %d's life %d is its %s (%d health kept)", level.maptime, b.idx, t.act, c.GetClassName(), hp);
		return nb;
	}
}

// its body in act 3, by class (the Boss bar and banner name it as its card)
class RSQMB_BK_RS_BlackArchEXVoid : RSQMB_BigKit
{
	override String Card() { return "NOCTIS"; }
	override String Kind() { return "BLACK ARCH-VILE"; }
}
