// RSQ TOP HP BARS -- THE BAR
//
// coldcite's design, kept: one world-space sprite above the thing, his 112x11 art in 5 % steps
// (his half-steps are the see-through "ghost" block), scale 0.3, 10 % of the sprite's height above
// it, the thing's own translucency followed ("Allow Stealth"), your own bar hidden in first person.
//
// WHAT CHANGED, AND WHY
//  - Work per tic: the frame is rebuilt only when health, spawn health, invulnerability or the look
//    changed; the sprite's height only when the thing's sprite frame or scale changed. Settings come from the
//    handler (read once a tic for all bars). Measured: see HANDOFF.md.
//  - Overheal (health above spawn health -- LegenDoom Lite's 300 % legendaries, a resurrection buff):
//    his bar showed it as plain full. Here a thinner strip sits one pixel above the bar, in the same
//    10-block grid: it holds the health ABOVE 100 %, one spawn-health's worth per lap. Laps beyond
//    the strip show as diamond pips at its right end (up to 4). So 150 % = full bar + half strip,
//    300 % = full bar + full strip + 1 pip, and it drains strip first, pips next, bar last.
//  - Placement follows the thing exactly, interpolation included: the bar's previous position is
//    the thing's previous position plus the same height, so a thing moved by another mod (RSQ_Grapple's
//    yank, DistanceGrab's throw, a teleport) drags the bar along in the same rendered frame, without
//    the bar trailing a tic or sliding in from where it was.
//  - The height is the sprite's real top: its top offset times its scale (or its texture height when
//    it stands on the floor and the renderer lifts a sunk sprite), smoothed so frame-to-frame height
//    changes do not make the bar hop. While the thing is turned (roll, or a voxel's pitch: the
//    grapple's tumble) the last standing height is held -- a sprite turning about its middle never
//    reaches above its standing top. A frame drawn as a voxel uses the voxel's own top (voxels.zs).
//  - Champions (by name): its tier icon floats at the champion's Height x 1.1, right where the bar
//    goes; over a champion the bar is lifted to sit just above the icon (handler.zs measures it).
//  - Far Size: the bar grows with distance from the viewer (x1 up to 256 units, to x rsqthp_far at
//    1024), so it stays readable across a room in the headset and is unchanged up close.
//  - Colour-blind / high-contrast sets (art: tools/gen_art.py) add cues that are not colour: the
//    low band is hatched and pulses (alpha 1.0 / 0.6, 0.7 s each way), the mid band has a dark line.
class RSQTHP_Bar : Actor
{
	Actor who;
	RSQTHP_Handler h;
	RSQTHP_Part over, mark;
	int lastHp, lastMax, lastVer;
	bool lastInv, built;
	int lastSpr, lastFrm;
	double lastSY;
	double top, topTarget;
	bool haveTop;
	bool low;               // in the low band of a colour-blind set: pulses
	int markPhase, markBits;
	bool champ;             // carries Champions' icon: lifted above it

	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTONAUTOMAP
		+DONTSPLASH
		+NOTIMEFREEZE
		Radius 1;
		Height 1;
		RenderStyle "Normal";
	}

	States
	{
	Spawn:
		RSYA B -1;
		Stop;
	}

	override void OnDestroy()
	{
		if (over) over.Destroy();
		if (mark) mark.Destroy();
		Super.OnDestroy();
	}

	// No Super.Tick(): the bar has no movement and a -1 tic state; everything is done here.
	override void Tick()
	{
		if (!who || who.health <= 0 || !h) { Destroy(); return; }
		Update();
	}

	void Update()
	{
		if (!h.on) { bInvisible = true; SyncParts(); return; }

		// ---- the frame -------------------------------------------------------------------------
		int hp = who.health;
		int mx = max(1, who.SpawnHealth());
		bool inv = who.bInvulnerable;
		if (!built || hp != lastHp || mx != lastMax || inv != lastInv || h.ver != lastVer)
		{
			built = true; lastHp = hp; lastMax = mx; lastInv = inv; lastVer = h.ver;
			BuildFrame(hp, mx, inv);
		}

		// ---- the height ------------------------------------------------------------------------
		bool turned = who.Roll != 0 || (who.Pitch != 0 && RSQTHP_Voxels.TopOf(who) > 0);
		if (!turned && (!haveTop || who.sprite != lastSpr || who.frame != lastFrm || who.Scale.Y != lastSY))
		{
			lastSpr = who.sprite; lastFrm = who.frame; lastSY = who.Scale.Y;
			topTarget = TopOf(who);
		}
		if (!haveTop) { top = topTarget; haveTop = true; }
		else top += (topTarget - top) * 0.5;
		if (h.champIcons && ((level.maptime + markPhase) % 35) == 0) champ = h.WearsChampIcon(who);
		double up = top * (1.0 + h.offset);
		if (champ && h.champIcons) up = max(up, who.Height * 1.1 + h.champIconH + 1.0);
		up += who.GetBobOffset();
		Vector3 np = (who.Pos.xy, who.Pos.z + up);
		if (np != Pos) SetOrigin(np, false);
		Prev = (who.Prev.xy, who.Prev.z + up);

		// ---- size, light, translucency ----------------------------------------------------------
		double s = h.scale;
		let cam = players[consoleplayer].camera;
		if (cam && h.far > 1.0)
		{
			double d = (cam.Pos.xy - Pos.xy).Length();
			if (d > 256) s *= 1.0 + (h.far - 1.0) * min(1.0, (d - 256) / 768.0);
		}
		Scale = (s, s);
		bBright = h.bright || h.set == 4;
		double a = 1.0;
		int style = STYLE_Normal;
		if (h.stealth) { a = who.Alpha; style = who.GetRenderStyle(); }
		if (low && (level.maptime % 50) >= 25)
		{
			a *= 0.6;
			if (style == STYLE_Normal) style = STYLE_Translucent;
		}
		if (Alpha != a || GetRenderStyle() != style) A_SetRenderStyle(a, style);

		// your own bar, in first person
		bool hide = false;
		if (who.player && who == players[consoleplayer].mo && players[consoleplayer].camera == who && !(who.player.cheats & CF_CHASECAM))
			hide = true;
		bInvisible = hide;

		// ---- the series' markers, every 4th tic ---------------------------------------------------
		if (((level.maptime + markPhase) & 3) == 0)
		{
			int bits = (h.markers && h.HasServices()) ? h.MarkersOf(who) : 0;
			if (bits != markBits)
			{
				markBits = bits;
				if (bits && !mark) mark = RSQTHP_Part(Spawn("RSQTHP_Part", Pos, NO_REPLACE));
				if (!bits && mark) { mark.Destroy(); mark = null; }
				if (mark) { mark.sprite = h.sprMark; mark.frame = bits - 1; }
			}
		}
		SyncParts();
	}

	void BuildFrame(int hp, int mx, bool inv)
	{
		sprite = h.sprMain[h.set];
		double pct = double(hp) / double(mx) * 100.0;
		int f;
		if (inv) f = 0;                       // XX
		else if (pct >= 100) f = 1;           // 99
		else if (pct < 5) f = 21;             // 00
		else f = 1 + (100 - int(pct / 5) * 5) / 5;   // 95 -> 2 ... 5 -> 20, floored to 5 % as his loop did
		frame = f;
		low = !inv && h.set >= 2 && pct < 40;

		// overheal
		if (h.overheal && !inv && hp > mx)
		{
			int extra = hp - mx;
			int laps = (extra + mx - 1) / mx;                 // ceil
			double fill = double(extra - (laps - 1) * mx) / mx; // (0, 1]
			int f20 = clamp(int(ceil(fill * 20 - 0.0001)), 1, 20);
			int pips = min(laps - 1, 4);
			if (!over) over = RSQTHP_Part(Spawn("RSQTHP_Part", Pos, NO_REPLACE));
			if (over) { over.sprite = h.sprOver[h.set * 5 + pips]; over.frame = f20 - 1; }
		}
		else if (over) { over.Destroy(); over = null; }
	}

	void SyncParts()
	{
		if (over) SyncPart(over);
		if (mark) { SyncPart(mark); mark.Scale = Scale * 2 * RSQTHP_A11y.Cue(); }   // icons at twice the bar's scale: readable (x RSQ_Accessibility's Cue Size)
	}

	void SyncPart(RSQTHP_Part p)
	{
		if (p.Pos != Pos) p.SetOrigin(Pos, false);
		p.Prev = Prev;
		p.Scale = Scale;
		p.bBright = bBright;
		p.bInvisible = bInvisible;
		if (p.Alpha != Alpha || p.GetRenderStyle() != GetRenderStyle()) p.A_SetRenderStyle(Alpha, GetRenderStyle());
	}

	// the sprite's real top above its origin, in world units
	static double TopOf(Actor a)
	{
		double vt = RSQTHP_Voxels.TopOf(a);
		if (vt > 0) return vt * a.Scale.Y;
		TextureID tex; bool flip; Vector2 sc;
		[tex, flip, sc] = a.CurState.GetSpriteTexture(0);
		if (!tex.IsValid()) return a.Height;
		Vector2 ofs = TexMan.GetScaledOffset(tex);
		Vector2 siz = TexMan.GetScaledSize(tex);
		double offY = ofs.Y, texH = siz.Y;
		double t = offY;
		// standing on the floor, a sprite sunk into it is drawn lifted by the renderer: its top is
		// then its texture height (coldcite measured the texture height for every case)
		if (a.Pos.Z <= a.FloorZ + 1 && texH > offY) t = texH;
		if (t <= 0) t = texH > 0 ? texH : a.Height;
		return t * a.Scale.Y;
	}
}

// THE OVERHEAL STRIP AND THE MARKER ICONS: no thinking of their own -- the bar puts them where it is
// each tic. Their art's offsets (TEXTURES.rsqthp) lay them out around the bar from the same origin:
// the strip one pixel above it, the icons left of it, so nothing overlaps and draw order never matters.
class RSQTHP_Part : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTONAUTOMAP
		+DONTSPLASH
		+NOTIMEFREEZE
		Radius 1;
		Height 1;
		RenderStyle "Normal";
	}
	States
	{
	Spawn:
		RSYZ A -1;
		Stop;
	}
	override void Tick() {}
}

// Registers every sprite name the bars use (sprite names exist only once a state names them).
class RSQTHP_SpriteNames : Actor
{
	States
	{
		RSYA A 0; RSYB A 0; RSYC A 0; RSYD A 0; RSYE A 0; RSYZ A 0;
		RS10 A 0; RS11 A 0; RS12 A 0; RS13 A 0; RS14 A 0;
		RS20 A 0; RS21 A 0; RS22 A 0; RS23 A 0; RS24 A 0;
		RS30 A 0; RS31 A 0; RS32 A 0; RS33 A 0; RS34 A 0;
		RS40 A 0; RS41 A 0; RS42 A 0; RS43 A 0; RS44 A 0;
		RS50 A 0; RS51 A 0; RS52 A 0; RS53 A 0; RS54 A 0;
		Stop;
	}
}
