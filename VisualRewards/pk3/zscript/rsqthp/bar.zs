// RSQ TOP HP BARS -- THE BAR
//
// coldcite's design, kept: one world-space sprite above the thing, his 112x11 art in 5 % steps
// (his half-steps are the see-through "ghost" block), scale 0.3, 10 % of the sprite's height above
// it, the thing's own translucency followed ("Allow Stealth"), your own bar hidden in first person.
//
// WHAT CHANGED, AND WHY
//  - Work per tic: the frame is rebuilt only when health, spawn health, invulnerability or the look
//    changed; the sprite's height only when the thing's sprite frame or scale changed. Settings come from the
//    handler (read once a tic for all bars).
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
//
// QOL ROUND (owner's picks, 2026-10-31)
//  - HP6 length by toughness: the bar is stretched sideways by LenOf(spawn health): an imp's (60) is coldcite's
//    112 px; x0.15 per doubling, 0.7 to 2.0 (zombieman 0.76, baron 1.61, Spider Mastermind 1.85, Cyberdemon 1.91 --
//    the widest). The strip stretches with it; the icons beside it move out along the view's right by the extra.
//  - HP7 hit flash: the tic after a player's hit lands, the bar is drawn as a white silhouette (stencil). Under
//    RSQ_Accessibility's Photosensitive Mode a flash is at 40 % and at most one per 14 tics (RSQTHP_A11y.Gate/Dim).
//  - HP8 raised: an up arrow right of the bar (in the status slot, or beside frozen / held) for the monster's life.
//  - HP9 fade in: a bar coming into view (made, or shown again by Aimed Only / Nearest 24 / Distance Limit) goes from
//    clear to its alpha over FADE tics.
//  - HP1 (option) damage chunk: the health a player's hit took off stays lit white for CHUNK_HOLD tics (half a second),
//    then drains to the new edge over CHUNK_DRAIN tics. Hits while it is lit add to it.
//  - HP2 (option) ally colour: a friendly monster's bar (allies, Brutal Doom's marines) uses the blue set RSYG.
//  - HP3 / HP4 (options): culled by the handler (Nearest 24), or past Limit Distance from the viewer: hidden.
//  - #16 (2026-11-01): RSQ_Miniboss's miniboss wears a crown above its bar, its thralls a chain link (Markers on),
//    asked through RSQMB_Service every 4th tic with the other series markers.
//
// THE 11-05 ICONS (owner-approved mock-up, 2026-11-05), all under Markers, art in tools/gen_art.py:
//  - whipped: a 5th marker bit (16), left of the bar in the slot nearest it (sprite RSYW: frame = the other four bits).
//  - ally: a heart in the right-hand row whenever the bar is a friendly monster's (Ally Colour on or off), so an ally
//    has a cue that is not colour alone. burning: a flame there while it is in fire (handler.zs THE 11-05 ICONS, Burned below).
//    The right-hand row is laid out from the bar outward: ally, raised, frozen or held, burning (lasting ones nearest).
//  - legendary: a gem above the bar on a LegenDoom legendary that has turned; tier pips: 0-4 gold pips right of a
//    Bossfight miniboss's crown. With a crown the gem sits left of it (one sprite, RSYI, so they never overlap).
class RSQTHP_Bar : Actor
{
	Actor who;
	RSQTHP_Handler h;
	RSQTHP_Part over, mark, stat, boss, dmark;   // dmark: RSQ SlowMo's DOWN mark, a skull (RSYJ)
	int lastHp, lastMax, lastVer;
	bool lastInv, built;
	int lastSpr, lastFrm;
	double lastSY;
	double top, topTarget;
	bool haveTop;
	bool low;               // in the low band of a colour-blind set: pulses
	int markPhase, markBits, bossBits, dmarkBits;
	int statNow, lastFt;    // frozen / held icon (1 frozen, 2 held), and the freezetics seen last tic
	int aimTic;             // Aimed Only: the last tic a hand's gun pointed at this bar's monster
	bool aimMade;           // made only because it was aimed at (full health): goes when the aim has left
	bool champ;             // carries Champions' icon: lifted above it
	int peak;               // the most health seen: a LegenDoom candidate's bar is drawn against it (handler.zs FullOf)
	// QoL round
	const FADE = 6;          // HP9: tics to fade in
	const CHUNK_HOLD = 17;   // HP1: tics the lost chunk stays lit (half a second)
	const CHUNK_DRAIN = 10;  // HP1: tics it then takes to drain
	double lenK;            // HP6: sideways stretch by toughness
	bool raised;            // HP8: an Arch-Vile brought it back
	bool flashPend;         // HP7: a player's hit landed since the last update
	int lastFlash;          // HP7: the tic of the last flash (Photosensitive Mode's gap)
	bool flashNow;          // HP7: drawn as the flash this tic (the probe reads it)
	int shown;              // HP9: tics in view
	bool culled;            // HP3: beyond the nearest 24
	int chunkHp, chunkTic;  // HP1: health before the hit(s), and when the last one landed (0 hp: none)
	RSQTHP_Part chunkP;
	bool lastAlly;          // HP2: drawn in the ally colour
	double chunkX0, chunkW; // HP1: the chunk's left edge and width, in bar pixels
	bool statRaised;        // the status part shows the raised arrow (HP8)
	int statKey;            // what the status part shows: its RSYF frame + 1 (0: nothing)
	int burnUntil;          // the last tic the fire that hit it can land again (Burned); 0 never
	int burnFreeTic;        // the last tic a fire of no known interval hit it (Burned measures the gap); 0 never
	bool burnNow;           // burning: lit on the hit, put out with the markers' 4th-tic read
	double baseAlpha;       // this tic's alpha and style before the hit flash: the parts take these
	int baseStyle;

	// fire damage landed (handler.zs WorldThingDamaged): it is burning now, and stays so until this fire's own interval
	// has passed without another hit. Several fires at once: the one that can land latest holds it.
	void Burned(Actor inflictor)
	{
		int now = level.maptime;
		int every = RSQTHP_Handler.FireEvery(inflictor);
		if (every <= 0)
		{
			int gap = burnFreeTic > 0 ? now - burnFreeTic : 0;
			every = (gap > 0 && gap <= RSQTHP_Handler.BURN_MAXGAP) ? gap : 1;
			burnFreeTic = now;
		}
		burnUntil = max(burnUntil, now + every);
		burnNow = true;
	}

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
		if (stat) stat.Destroy();
		if (boss) boss.Destroy();
		if (dmark) dmark.Destroy();
		if (chunkP) chunkP.Destroy();
		Super.OnDestroy();
	}

	// HP6: the bar's stretch for a thing of this spawn health (imp 60 = 1)
	static double LenOf(int mx)
	{
		return clamp(1.0 + 0.15 * log(max(1, mx) / 60.0) / log(2.0), 0.7, 2.0);
	}

	// a player's hit landed (handler.zs): flash once, and the chunk it took off (hpBefore: health before it)
	void PlayerHit(int hpBefore)
	{
		flashPend = true;
		if (chunkHp <= 0 || level.maptime - chunkTic > CHUNK_HOLD) chunkHp = hpBefore;   // a new chunk, or add to the lit one
		chunkTic = level.maptime;
	}

	// No Super.Tick(): the bar has no movement and a -1 tic state; everything is done here.
	override void Tick()
	{
		if (!who || who.health <= 0 || !h) { Destroy(); return; }
		// A bar the aim made over an unhurt monster goes once the aim has left it (or Aimed Only is off): an unhurt
		// monster has no bar otherwise, and turning the option off must not leave full bars standing.
		if (aimMade)
		{
			if (who.health < h.FullOf(who, peak)) aimMade = false;
			else if ((!h.aimedOnly || level.maptime - aimTic > RSQTHP_Handler.AIM_LINGER) && !h.DownMarked(who)) { Destroy(); return; }
		}
		Update();
	}

	void Update()
	{
		if (!h.on) { bInvisible = true; SyncParts(); return; }

		// ---- the frame -------------------------------------------------------------------------
		int hp = who.health;
		// a LegenDoom candidate (not turned yet) reads as a plain monster: drawn against its most health since it was
		// picked, never as an overheal (handler.zs, LEGENDOOM'S CANDIDATES); everything else against its spawn health
		if (hp > peak) peak = hp;
		int mx = h.FullOf(who, peak);
		bool inv = who.bInvulnerable;
		bool al = h.ally && who.bFriendly && !who.player;     // Brutal Doom's marines switch FRIENDLY as they go
		if (!built || hp != lastHp || mx != lastMax || inv != lastInv || h.ver != lastVer || al != lastAlly)
		{
			built = true; lastHp = hp; lastMax = mx; lastInv = inv; lastVer = h.ver; lastAlly = al;
			BuildFrame(hp, mx, inv);
			lenK = LenOf(who.SpawnHealth());     // length by the monster's kind, never by a LegenDoom candidate's boost
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
		double camD = 0;
		if (cam)
		{
			camD = (cam.Pos.xy - Pos.xy).Length();
			if (h.far > 1.0 && camD > 256) s *= 1.0 + (h.far - 1.0) * min(1.0, (camD - 256) / 768.0);
		}
		if (lenK <= 0) lenK = LenOf(who.SpawnHealth());
		Scale = (s * lenK, s);
		bBright = h.bright || h.set == 4;

		// your own bar, in first person
		bool hide = false;
		if (who.player && who == players[consoleplayer].mo && players[consoleplayer].camera == who && !(who.player.cheats & CF_CHASECAM))
			hide = true;
		// Aimed Only: only while a hand's gun points at it, and AIM_LINGER tics after
		// (never a DOWN target's: RSQ SlowMo's DOWN v3 keeps its bar up, hit or not -- RSQSM_Service "down.mark", by name)
		if (h.aimedOnly && level.maptime - aimTic > RSQTHP_Handler.AIM_LINGER && !h.DownMarked(who)) hide = true;
		if (culled) hide = true;                                    // HP3 Nearest 24
		if (h.limit && cam && camD > h.limitDist) hide = true;      // HP4 Distance Limit
		bInvisible = hide;
		shown = hide ? 0 : min(shown + 1, FADE);                    // HP9 fade in

		double a = 1.0;
		int style = STYLE_Normal;
		if (h.stealth) { a = who.Alpha; style = who.GetRenderStyle(); }
		if (low && (level.maptime % 50) >= 25)
		{
			a *= 0.6;
			if (style == STYLE_Normal) style = STYLE_Translucent;
		}
		if (shown < FADE)
		{
			a *= double(shown) / FADE;
			if (style == STYLE_Normal) style = STYLE_Translucent;
		}
		baseAlpha = a; baseStyle = style;
		// HP7: one tic as a white silhouette after a player's hit (Photosensitive Mode: 40 %, 14 tics apart)
		flashNow = false;
		if (flashPend)
		{
			flashPend = false;
			if (!hide && RSQTHP_A11y.Gate(lastFlash, level.maptime))
			{
				lastFlash = level.maptime;
				flashNow = true;
				if (fillcolor != Color(255, 255, 255, 255)) SetShade(Color(255, 255, 255));
				a = RSQTHP_A11y.Dim(a * 0.9);
				style = STYLE_TranslucentStencil;
			}
		}
		if (Alpha != a || GetRenderStyle() != style) A_SetRenderStyle(a, style);

		// ---- frozen / held, every tic (a hit-stop lasts 3 to 6 tics); raised, burning, ally beside it ------
		int st = h.markers ? StatusOf() : 0;
		statNow = st;
		bool rs = raised && h.markers;
		bool bn = burnNow && h.markers;
		bool fr = h.markers && who.bFriendly && !who.player;       // an ally's bar: the heart (not only the blue)
		statRaised = rs;
		// frame = s + 3 * (raised + 2 * (burning + 2 * ally)) - 1 (TEXTURES.rsqthp; A..E as before 11-05)
		int key = st + 3 * ((rs ? 1 : 0) + 2 * ((bn ? 1 : 0) + 2 * (fr ? 1 : 0)));
		if (key != statKey)
		{
			statKey = key;
			if (key && !stat) stat = RSQTHP_Part(Spawn("RSQTHP_Part", Pos, NO_REPLACE));
			if (!key && stat) { stat.Destroy(); stat = null; }
			if (stat) { stat.sprite = h.sprStat; stat.frame = key - 1; }
		}

		// ---- HP1: the chunk a player's hit took off --------------------------------------------------
		int hi = 0;
		double drainK = 1.0;
		if (h.chunk && chunkHp > hp && !inv)
		{
			int age = level.maptime - chunkTic;
			if (age <= CHUNK_HOLD + CHUNK_DRAIN)
			{
				hi = chunkHp;
				if (age > CHUNK_HOLD) drainK = 1.0 - double(age - CHUNK_HOLD) / CHUNK_DRAIN;
			}
		}
		if (!hi) chunkHp = 0;
		double x0 = 1 + 110 * clamp(double(hp) / mx, 0.0, 1.0);
		double x1 = 1 + 110 * clamp(double(hi) / mx, 0.0, 1.0);
		x1 = x0 + (x1 - x0) * drainK;
		if (hi && x1 - x0 >= 0.5)
		{
			if (!chunkP) chunkP = RSQTHP_Part(Spawn("RSQTHP_Part", Pos, NO_REPLACE));
			chunkP.sprite = h.sprChunk; chunkP.frame = 0;
			chunkX0 = x0; chunkW = x1 - x0;
		}
		else if (chunkP) { chunkP.Destroy(); chunkP = null; }

		// ---- the series' markers, every 4th tic ---------------------------------------------------
		if (((level.maptime + markPhase) & 3) == 0)
		{
			int bits = (h.markers && h.HasServices()) ? h.MarkersOf(who) : 0;
			if (bits != markBits)
			{
				markBits = bits;
				if (bits && !mark) mark = RSQTHP_Part(Spawn("RSQTHP_Part", Pos, NO_REPLACE));
				if (!bits && mark) { mark.Destroy(); mark = null; }
				// whipped (16): RSYW, frame = the other four bits; else RSYZ, frame = the mask - 1
				if (mark) { if (bits & 16) { mark.sprite = h.sprWhip; mark.frame = bits & 15; } else { mark.sprite = h.sprMark; mark.frame = bits - 1; } }
			}
			// burning: out once the fire that hit it has had its own interval to land again and hasn't (Burned)
			if (burnNow && level.maptime > burnUntil) burnNow = false;
			// RSQ_Miniboss's miniboss (crown, with its Bossfight tier pips) or thrall (chain link), and LegenDoom's
			// legendary (gem), above the bar (#16, 11-05): BossMarkOf answers the RSYI frame + 1
			int bb = h.markers ? h.BossMarkOf(who) : 0;
			if (bb != bossBits)
			{
				bossBits = bb;
				if (bb && !boss) boss = RSQTHP_Part(Spawn("RSQTHP_Part", Pos, NO_REPLACE));
				if (!bb && boss) { boss.Destroy(); boss = null; }
				if (boss) { boss.sprite = h.sprBoss; boss.frame = bb - 1; }
			}
			// RSQ SlowMo's DOWN mark: the v2 skull is gone (v3, owner 11-07): SlowMo draws the target's own icon over the bar
			int db = 0;
			if (db != dmarkBits)
			{
				dmarkBits = db;
				if (db && !dmark) dmark = RSQTHP_Part(Spawn("RSQTHP_Part", Pos, NO_REPLACE));
				if (!db && dmark) { dmark.Destroy(); dmark = null; }
				if (dmark) { dmark.sprite = h.sprDown; dmark.frame = db - 1; }
			}
		}
		SyncParts();
	}

	// 0 nothing, 1 frozen (freezetics counting: a hit-stop), 2 held (RSQ DistanceGrab's Headlock or human shield:
	// near.zs sets freezetics = 2 every tic before the thinkers run, so the count seen here stands still, and it
	// borrows NOGRAVITY and FORCEINFIGHTING for the hold -- read against the class defaults, so a flyer that has
	// NOGRAVITY of its own still needs the other). Read from the monster alone: nothing links to DistanceGrab.
	int StatusOf()
	{
		int ft = who.freezetics, prev = lastFt;
		lastFt = ft;
		if (ft <= 0) return 0;
		if (ft == prev)
		{
			let def = GetDefaultByType(who.GetClass());
			if ((who.bFORCEINFIGHTING && !def.bFORCEINFIGHTING) || (who.bNOGRAVITY && !def.bNOGRAVITY)) return 2;
			return 1;           // re-asserted by something else: frozen all the same
		}
		if (ft == prev - 1) return 1;   // counting down: a hit-stop
		return statNow;     // its first tic, or topped up: one more tic tells which (no one-tic wrong icon)
	}

	void BuildFrame(int hp, int mx, bool inv)
	{
		sprite = (h.ally && who.bFriendly && !who.player) ? h.sprAlly : h.sprMain[h.set];
		double pct = double(hp) / double(mx) * 100.0;
		int f;
		if (inv) f = 0;                       // XX
		else if (pct >= 100) f = 1;           // 99
		else if (pct < 5) f = 21;             // 00
		else f = 1 + (100 - int(pct / 5) * 5) / 5;   // 95 -> 2 ... 5 -> 20, floored to 5 % as his loop did
		frame = f;
		low = !inv && h.set >= 2 && pct < 40;
		Tint(inv ? -1 : (pct >= 70 ? 0 : (pct >= 40 ? 1 : 2)));

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

	// COLOURS 6 and 7 (the owner, 11-03: "I enjoy the green yellow red for the hp bars but I'd like a lavender, orange, cyan, or
	// something similar"): coldcite's Classic frames through a palette translation per band (TRNSLATE RSQTHP_H<ii>: the frame's
	// greys kept, the fill tinted by its brightness). 6: cyan full, lavender mid, orange low. 7 Random: each bar picks three
	// fresh colours when it is made. The overheal strip and the icons keep their own colours. The colour-blind sets (and
	// RSQ_Accessibility's palette, which overrides this row) are untouched.
	int rndCol[3];
	bool rndMade;
	Name tintNow;
	void Tint(int band)
	{
		Name want = 'None';
		if (band >= 0 && sprite == h.sprMain[0] && (h.scheme == 6 || h.scheme == 7))
		{
			static const int COOL[] = { 13, 9, 4 };
			int c = COOL[band];
			if (h.scheme == 7)
			{
				if (!rndMade)
				{
					rndMade = true;
					for (int i = 0; i < 3; i++) rndCol[i] = random[rsqthpbar](0, 16);
				}
				c = rndCol[band];
			}
			want = String.Format("RSQTHP_H%02d", c);
		}
		if (want != tintNow) { tintNow = want; A_SetTranslation(want); }
	}

	void SyncParts()
	{
		// HP6: the stretched bar's extra half-width, in world units along the view's right (a sprite faces the view's
		// yaw), so the icons beside it move out with its ends and the chunk lands on its pixels
		double sy = Scale.Y;
		Vector2 rt = (0, 0);
		let cam = players[consoleplayer].camera;
		if (cam) rt = (sin(cam.Angle), -cos(cam.Angle));
		double ext = 56 * sy * (lenK - 1);
		if (over) SyncPart(over);
		if (mark) { SyncPart(mark, rt * -ext); mark.Scale = (sy, sy) * 2 * RSQTHP_A11y.Cue(); }   // icons at twice the bar's scale: readable (x RSQ_Accessibility's Cue Size)
		if (stat) { SyncPart(stat, rt * ext); stat.Scale = (sy, sy) * 2 * RSQTHP_A11y.Cue(); }
		if (boss) { SyncPart(boss); boss.Scale = (sy, sy) * 2 * RSQTHP_A11y.Cue(); }
		if (dmark) { SyncPart(dmark); dmark.Scale = (sy, sy) * 2 * RSQTHP_A11y.Cue(); dmark.bBright = true; }
		if (chunkP)
		{
			SyncPart(chunkP, rt * ((chunkX0 - 56) * sy * lenK));
			chunkP.Scale = (chunkW * sy * lenK, sy);
			chunkP.bBright = true;
			double ca = baseAlpha * 0.85;
			if (chunkP.Alpha != ca || chunkP.GetRenderStyle() != STYLE_Translucent) chunkP.A_SetRenderStyle(ca, STYLE_Translucent);
		}
	}

	void SyncPart(RSQTHP_Part p, Vector2 shift = (0, 0))
	{
		Vector3 at = Pos + (shift, 0);
		if (p.Pos != at) p.SetOrigin(at, false);
		p.Prev = Prev + (shift, 0);
		p.Scale = Scale;
		p.bBright = bBright;
		p.bInvisible = bInvisible;
		if (p.Alpha != baseAlpha || p.GetRenderStyle() != baseStyle) p.A_SetRenderStyle(baseAlpha, baseStyle);
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
		RSYA A 0; RSYB A 0; RSYC A 0; RSYD A 0; RSYE A 0; RSYZ A 0; RSYF A 0; RSYG A 0; RSYH A 0; RSYW A 0;
		RS10 A 0; RS11 A 0; RS12 A 0; RS13 A 0; RS14 A 0;
		RS20 A 0; RS21 A 0; RS22 A 0; RS23 A 0; RS24 A 0;
		RS30 A 0; RS31 A 0; RS32 A 0; RS33 A 0; RS34 A 0;
		RS40 A 0; RS41 A 0; RS42 A 0; RS43 A 0; RS44 A 0;
		RS50 A 0; RS51 A 0; RS52 A 0; RS53 A 0; RS54 A 0;
		RSYI A 0; RSYJ A 0;
		Stop;
	}
}
