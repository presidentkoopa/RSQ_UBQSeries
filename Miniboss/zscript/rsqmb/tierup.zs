// ============================================================================
// RSQ_Miniboss -- MINIBOSS KILLS TIER UP MONSTERS (owner 2026-11-15 19:41: "every miniboss we kill, tiers up monsters 1,
// and we have that as an on / off. just for now so I have something to play"; 19:22: the words "like our other ones
// saying Boss Defeated! and then Enemy Tier Up!"). rsqmb_tierup, ON.
//
//   THE WIN        a called-in fight's MINIBOSS killed by a player (handler.zs BossDied with a killer: the same win
//                  BfPayoff counts). A thrall's death, a miniboss killed by something that is not a player, or removed
//                  without dying, counts nothing.
//   THE WORDS      "MINIBOSS DEFEATED!" in gold over where it died at once; a beat later (TU_BEAT) "ENEMIES TIER UP!" in
//                  red above it, both RSQ VisualRewards' held words (RSQVR_Service "word.hold", size TU_SIZE),
//                  on a small anchor left where it died (its body may be gone by then: Brutal Doom's deaths remove it).
//                  The anchor goes after TU_LIFE tics and the words fade with it.
//   THE TIER-UP    on that beat RSQ Monsters' world tier (its server cvar rsq_mon_worldtier, "World Tier (test)", set BY
//                  NAME: this pack still loads alone) goes up by 1, at most 13 (White). RSQ Monsters itself makes every
//                  living monster on the map follow, with its tier flash (RS_BDTier.zs WorldTick). Already at 13: no
//                  tier-up and no tier-up word. RSQ Monsters not loaded, or its ladder off (rsq_mon_bdtier): nothing at all.
//   JUST FOR NOW   the world tier is a saved setting today: it carries into the next game until it is reset on RSQ
//                  Monsters' page (World Tier (test)).
// ============================================================================

class RSQMB_WordSpot : Actor
{
	int life;
	Default { Radius 1; Height 16; +NOINTERACTION; +NOBLOCKMAP; +NOGRAVITY; +NOTIMEFREEZE; RenderStyle "None"; }
	override void Tick() { if (--life <= 0) Destroy(); }
	States { Spawn: TNT1 A -1; Stop; }
}

extend class RSQMB_Handler
{
	const TU_BEAT = 35;           // tics from "MINIBOSS DEFEATED!" to the tier-up and its word
	const TU_LIFE = 175;          // tics the anchor (and so its words) stays
	const TU_SIZE = 1.2;          // VisualRewards' word size (1 its monster words; 2, TARGET!'s, ran past a 90-degree view at
	                              // the owner's Word Size 1.5 for these 18 letters: rig run tuA)
	const RGB_DEFEATED = 0xFFC830;
	const RGB_TIERUP = 0xFF3020;

	Array<int> tuAt;              // a tier-up due at that tic (one a miniboss killed)
	Array<RSQMB_WordSpot> tuSpot; // ...and the anchor its word goes on

	// RSQ Monsters' world tier cvar, or null when it is absent or its ladder is switched off (then nothing happens)
	static CVar TuWorld()
	{
		let on = CVar.FindCVar('rsq_mon_bdtier');
		if (on && !on.GetBool()) return null;
		return CVar.FindCVar('rsq_mon_worldtier');
	}

	// BossDied (handler.zs), after the payoff
	void TierUpOnKill(RSQMB_Boss b, Actor killer)
	{
		if (!b || !killer || !killer.player) return;
		if (CI('rsqmb_tierup', 1) == 0) { if (debug) Console.Printf("RSQMB tier-up on kill: off (rsqmb_tierup 0)"); return; }
		let wc = TuWorld();
		if (!wc) { if (debug) Console.Printf("RSQMB tier-up on kill: no RSQ Monsters world tier (not loaded, or its ladder off): nothing"); return; }
		RSQMB_WordSpot spot = null;
		let mb = b.mb;
		if (mb)
		{
			spot = RSQMB_WordSpot(Actor.Spawn("RSQMB_WordSpot", mb.pos, NO_REPLACE));
			if (spot)
			{
				spot.life = TU_LIFE;
				spot.Height = max(mb.Height, mb.default.Height);
				WordHold("MINIBOSS DEFEATED!", RGB_DEFEATED, TU_SIZE, spot);
			}
		}
		tuAt.Push(level.maptime + TU_BEAT);
		tuSpot.Push(spot);
		if (debug) Console.Printf("RSQMB tier-up on kill t%d: miniboss %s killed by a player, world tier %d now, +1 in %d tics",
			level.maptime, mb ? mb.GetClassName() : 'gone', wc.GetInt(), TU_BEAT);
	}

	// WorldTick (handler.zs)
	void TierUpTick()
	{
		for (int i = 0; i < tuAt.Size(); i++)
		{
			if (level.maptime < tuAt[i]) continue;
			let spot = tuSpot[i];
			tuAt.Delete(i); tuSpot.Delete(i); i--;
			TierUpNow(spot);
		}
	}

	// the world tier +1 (at most White, 13); the word on the anchor when there is one
	void TierUpNow(Actor spot)
	{
		let wc = TuWorld();
		if (!wc) return;
		int was = wc.GetInt();
		if (was >= TOP_TIER)
		{
			if (debug) Console.Printf("RSQMB tier-up on kill t%d: world tier %d, already at the top (%d): no tier-up", level.maptime, was, TOP_TIER);
			return;
		}
		int now = max(1, was + 1);
		wc.SetInt(now);   // (a server cvar: the engine applies it a tic later, and RSQ Monsters' followers within 8 more)
		if (spot) WordHold("ENEMIES TIER UP!", RGB_TIERUP, TU_SIZE, spot);
		if (debug) Console.Printf("RSQMB tier-up on kill t%d: world tier %d -> %d (%s)", level.maptime, was, now, TierText(now));
	}

	// leaving the level with a tier-up still due: it is given now (no word)
	void TierUpFlush()
	{
		for (int i = 0; i < tuAt.Size(); i++) TierUpNow(null);
		tuAt.Clear(); tuSpot.Clear();
	}
}
