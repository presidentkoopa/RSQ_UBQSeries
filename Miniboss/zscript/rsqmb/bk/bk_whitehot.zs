// WHITE HOT SPIDER (RS_WhiteSPEX, plus/RS_PlusWhiteSpiderEX.zs; design/BIG_BOSS_REMAINING_B.md 24). From its own code only.
//   opener    acts 1 and 3 its own Basic (held on its first frame, WSPX C 2 Bright; the lift-off is not run); act 2 its own
//             KRAKATOA (held: its 0-tic line check is skipped and the held frame is Basic's WSPX C 2, the same pose).
//             A MISS lets the state run as written: Basic's lift and RS_BoilBoltL9 fans; KRAKATOA's eyes, CCCF 10 and 20
//             RS_KrakatoaL9 (its health line hooked to the act, so a miss in act 2 runs it, not Basic).
//   points    WSPX C1: eye (0, 0.44), eye (+0.14, 0.44), crown (-0.05, 0.83)
//   summons   EXPOSED!: RS_MiniSpiderL9 (its Spiders' RS_SPWHIL9 spawn them). GUARD wave: RS_WhiteSPEXSplit2 (its split's
//             ninths; their own deaths burst tiny spiders, not the wave)
//   acts      1 its kit above its 5000 line; 2 KRAKATOA by the RS_Act.zs hook (RSQMN_Act.At(self, 2, 5000)); 3 its own
//             Death split: it goes on as one RS_WhiteSPEXSplit where it stands (body swap, the Black Knight's pattern,
//             bigacts.zs KnightBody), the other two thirds come as its summons. Every ninth and tiny spider its bodies
//             spawn in the 5 s after the fight is gone with them (WhiteSweep), as the summons are.
class RSQMB_BK_RS_WhiteSPEX : RSQMB_BigKit
{
	Array<Actor> mine;      // its bodies and every summon of the kit (the sweep looks around them)

	override String Card() { return "WHITE HOT SPIDER"; }
	override String Kind() { return "WHITE ARACHNOTRON"; }
	override void Points(int act, Array<double> sx, Array<double> sy) { Pts(sx, sy, 0, 0.44, 0.14, 0.44, -0.05, 0.83); }
	override String Opener(RSQMB_Tele t, int act) { return act == 2 ? "KRAKATOA" : "Basic"; }

	override int Summon(RSQMB_Tele t, RSQMB_Handler h, PlayerPawn p, bool guard, int n)
	{
		Class<Actor> c = guard ? "RS_WhiteSPEXSplit2" : "RS_MiniSpiderL9";
		if (!c) return 0;
		int got = 0;
		for (int k = 0; k < n; k++)
		{
			let a = t.SummonAt(h, c, p, (0, 0), 160, 320);
			if (a) { mine.Push(a); got++; }
		}
		return got;
	}

	override void OnAct(RSQMB_Tele t, RSQMB_Handler h, int act)
	{
		let mb = t.b ? t.b.mb : null;
		if (!mb) return;
		if (mine.Find(mb) == mine.Size()) mine.Push(mb);
		if (act < 3 || mb.GetClassName() != 'RS_WhiteSPEX') return;
		// its own Death split (3 x RS_WhiteSPEXSplit): one is the Big Boss's body, two are its summons
		let nb = SwapBody(t, h, "RS_WhiteSPEXSplit");
		if (!nb) return;
		mine.Push(nb);
		String cn = "RS_WhiteSPEXSplit";     // a string first: resolved at run time (loads without RSQ Monsters)
		Class<Actor> c = cn;
		let p = t.Victim();
		Vector2 rt = (sin(nb.angle), -cos(nb.angle));
		for (int s = 0; s < 2; s++)
		{
			let a = t.SummonAt(h, c, p, rt * (s == 0 ? 96 : -96), 0, 0);
			if (!a) a = t.SummonAt(h, c, p, (0, 0), 96, 224);
			if (a) { mine.Push(a); t.Keep(a); }   // beside it, not the GUARD wave
		}
		if (h && h.debug) Console.Printf("RSQMB act t%d: boss %d splits: a third is the Big Boss, %d summons", level.maptime, t.b.idx, t.SumAlive());
	}

	override void OnEnd(RSQMB_Tele t, RSQMB_Handler h)
	{
		if (t.b && t.b.mb && mine.Find(t.b.mb) == mine.Size()) mine.Push(t.b.mb);
		RSQMB_BK_WhiteSweep.Start(mine);
		mine.Clear();
	}

	// the Black Knight's body swap (bigacts.zs KnightBody), for its own split: the new body where it stands, its health kept
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

// its bodies after the split, by class (the Boss bar and banner name it as its card)
class RSQMB_BK_RS_WhiteSPEXSplit : RSQMB_BigKit
{
	override String Card() { return "WHITE HOT SPIDER"; }
	override String Kind() { return "WHITE ARACHNOTRON"; }
}

// THE FIGHT OVER: the ninths (RS_WhiteSPEXSplit2) its thirds' own Deaths spawn, and the tiny spiders (RS_MiniSpiderL9)
// its ninths' Deaths burst, come after the fight has ended (its Death frames run ~2 s). For 5 s, any of them newer than the
// sweep within 256 units of where one of its bodies or summons was is removed (no kill counted), so nothing of the fight outlives it.
class RSQMB_BK_WhiteSweep : Thinker
{
	Array<double> nx, ny;   // where its bodies and summons were as the fight ended
	int age;

	static void Start(Array<Actor> from)
	{
		let s = new("RSQMB_BK_WhiteSweep");
		for (int i = 0; i < from.Size(); i++) if (from[i]) { s.nx.Push(from[i].pos.x); s.ny.Push(from[i].pos.y); }
		if (s.nx.Size() == 0) s.Destroy();
	}

	override void Tick()
	{
		if (level.isFrozen()) return;
		age++;
		if (age > 5 * TICRATE) { Destroy(); return; }
		Sweep("RS_WhiteSPEXSplit2");
		Sweep("RS_MiniSpiderL9");
	}

	void Sweep(String cn)
	{
		Class<Actor> c = cn;
		if (!c) return;
		let it = ThinkerIterator.Create(c);
		Actor a;
		Array<Actor> gone;
		while (a = Actor(it.Next()))
		{
			if (a.GetAge() > age + 1) continue;          // older than the fight's end: not of it
			for (int i = 0; i < nx.Size(); i++)
				if (level.Vec2Diff((nx[i], ny[i]), a.pos.xy).Length() < 256) { gone.Push(a); break; }
		}
		for (int i = 0; i < gone.Size(); i++) { gone[i].ClearCounters(); gone[i].Destroy(); }
	}
}
