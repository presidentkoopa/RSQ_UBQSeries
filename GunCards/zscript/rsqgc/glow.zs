// glow.zs -- RSQ Gun Cards: CARD GLOW and NO BACKGROUND (owner 2026-11-06, BUGS_1.0 #19: "do i have an option for 'no
// background'", "could these get any kind of emissive glow or light on a kind of Quest / PCVR setting").
//
// CARD GLOW (rsqgc_glow): 0 Off, as before: the cards are lit by the room like the gun. 1 Quest: the cards are fullbright,
// they keep their colours in the dark (the Bright twins of the card states, tools/gen_bright.py; the cards drawn in the
// world get the actor's +BRIGHT); nothing else is drawn, so it costs nothing. 2 PCVR: the same, plus a small dynamic
// light at each hand whose card shows, in the card's colour, fading with it (needs the renderer's dynamic lights on).
// NO BACKGROUND (Material: No Background, rsqgc_look 3): the panel is left out of every card, only the text shows (as glass).

class RSQGC_Glow play
{
	static clearscope int Mode() { let c = CVar.FindCVar("rsqgc_glow"); return c ? clamp(c.GetInt(), 0, 2) : 0; }
	static clearscope bool NoPanel() { let c = CVar.FindCVar("rsqgc_look"); return c && c.GetInt() == 3; }
	// for the watch cards' signatures: a change rebuilds them with the other states
	static clearscope string Sig() { return String.Format(" gl%d np%d", Mode() > 0, NoPanel()); }

	static State CPiece(int kind, bool mirrored, int slot, int depth)
	{
		return Mode() > 0 ? RSQGC_CardStatesB.Piece(kind, mirrored, slot, depth) : RSQGC_CardStates.Piece(kind, mirrored, slot, depth);
	}
	static State SGlyph(int set, int fam, int pos, int code)
	{
		return Mode() > 0 ? RSQGC_SideStatesB.Glyph(set, fam, pos, code) : RSQGC_SideStates.Glyph(set, fam, pos, code);
	}
	static State SKey(int src, int fam, int type, int after, int dim)
	{
		return Mode() > 0 ? RSQGC_SideStatesB.Key(src, fam, type, after, dim) : RSQGC_SideStates.Key(src, fam, type, after, dim);
	}
	static State SPanel(int fam, int hi)
	{
		return Mode() > 0 ? RSQGC_SideStatesB.Panel(fam, hi) : RSQGC_SideStates.Panel(fam, hi);
	}
}

// PCVR's light: a point light that rides each hand while its card shows
class RSQGC_GlowSpot : Actor
{
	Default { +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOSECTOR +DONTSPLASH +NOTONAUTOMAP RenderStyle "None"; }
	States { Spawn: TNT1 A -1; Stop; }
}

extend class RSQGC_GunCard
{
	const GLOW_RADIUS = 24;      // map units (about 70 cm): a small pool of light round the wrist
	RSQGC_GlowSpot mGlow[2];
	int mGlowCol[2], mGlowRad[2];
	void GlowLights(PlayerPawn pmo)
	{
		bool pc = Mode2() && pmo && pmo.player && pmo.player.playerstate == PST_LIVE;
		for (int hand = 0; hand < 2; hand++)
		{
			int rad = pc ? int(GLOW_RADIUS * clamp(mShow[hand], 0.0, 1.0)) : 0;
			if (rad < 2)
			{
				if (mGlow[hand]) { mGlow[hand].Destroy(); mGlow[hand] = null; }
				continue;
			}
			if (!mGlow[hand]) { mGlow[hand] = RSQGC_GlowSpot(Actor.Spawn("RSQGC_GlowSpot", pmo.pos, NO_REPLACE)); mGlowCol[hand] = -1; }
			let s = mGlow[hand];
			if (!s) continue;
			// at the wrist, a little toward the eye so the light falls on the card's side
			Vector3 hp = handPos(pmo, hand);
			Vector3 eye = (pmo.pos.xy, pmo.player.viewz);
			Vector3 to = eye - hp;
			if (to.Length() > 1) to = to.Unit() * 4;
			s.SetOrigin(hp + to, true);
			int c = mLightCol[hand] & 0xFFFFFF;
			if (c != mGlowCol[hand] || abs(rad - mGlowRad[hand]) > 1)
			{
				s.A_AttachLight('RSQGC', DynamicLight.PointLight, c, rad, rad, DynamicLight.LF_ATTENUATE);
				mGlowCol[hand] = c; mGlowRad[hand] = rad;
				if (ci("rsqgc_debug_log", 0)) Console.Printf("rsqgc: card glow light hand %d colour %06X radius %d at %.0f %.0f %.0f", hand, c, rad, s.pos.x, s.pos.y, s.pos.z);
			}
		}
	}
	static bool Mode2() { return RSQGC_Glow.Mode() == 2; }
}
