// RSQ LASER SIGHT.
//
// A laser on every gun, both hands. Two parts, each drawn where it can be drawn best:
//
//   THE BEAM  rides the gun model: a psprite layer called by the gun, so the renderer
//             puts it on that gun's controller every rendered frame, exactly as it puts
//             the gun (beam.zs). It starts at THAT gun's muzzle and runs along THAT gun's
//             barrel -- both measured from its held model (tools/gen_beams.py,
//             docs/MUZZLES.txt) -- brightest at the muzzle and fading to nothing over the
//             fade length. A gun with no measurement gets no beam rather than a wrong one.
//   THE SPOT  a world actor where the trace from the muzzle, along the barrel, lands
//             (35 Hz, interpolated by the renderer), PAINTED ON THE SURFACE: a WALLSPRITE
//             turned to the wall's own normal, a FLATSPRITE on floors and ceilings, a
//             billboard only on an actor. Constant apparent size; a real dynamic light of
//             its colour (switchable). The beam's fade hides the small difference between
//             where the beam ends (per frame) and where the spot is (per tic).
//
// The beam stops where the trace hits: a HUD model is drawn over the world (hw_models.cpp
// squeezes its depth range), so a beam left long would show through the wall. It comes in
// lengths 10 cm .. 6 m in 6% steps and the longest that does not pass the hit is drawn.
//
// THE OPTIONS keep what still applies of UZDXREMA's laser menu: pointer and beam
// separately, pointer glow (bloom / real light / both), any colour by picker -- per hand,
// beam and dot separately, per weapon slot, cycling, target and headshot reactions -- IR,
// visible only through the light amplification goggles, and the fade length.
//
// Visuals only. Nothing here changes damage, aim, or the playsim of any other mod -- it
// cannot break a weapon, only draw on top of it.

class RSQLS_Spot : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		+BRIGHT
		RenderStyle "Add";
		Radius 1; Height 1;
	}
	States { Spawn: RSLS A -1 Bright; Stop; }
}

// The pointer's glow: a wide soft bloom laid over the spot, same placement.
class RSQLS_Glow : RSQLS_Spot
{
	States { Spawn: RSLG A -1 Bright; Stop; }
}

// PHASE 3 pieces. A dot along a thrown weapon's arc; the spread ring (RSLR, a
// thin circle at 0.9 of the sprite's radius); the range readout's glyphs (RSQLS_ReadoutGlyph, below).
class RSQLS_ArcDot : RSQLS_Spot {}
// THE BEAM ALONG THE ARC (owner 2026-11-06, BUGS_1.0 #38): one segment of the beam bent along a thrown weapon's arc, a
// crossed-quad model (MODELDEF RSQLS_ArcSeg, tools/gen_assets.py) laid from one point of the arc to the next
class RSQLS_ArcSeg : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		+BRIGHT
		RenderStyle "Add";
		Radius 1; Height 1;
	}
	States { Spawn: RSLV A -1 Bright; Stop; }
}
// Laser: PC VR (owner 2026-11-06) on the arc: the halo around a segment, a wider segment on the same mesh wearing the
// halo skin (MODELDEF RSQLS_ArcHalo, tools/gen_assets.py): the straight beam's halo rod in cross-section.
class RSQLS_ArcHalo : RSQLS_ArcSeg {}
class RSQLS_Ring : RSQLS_Spot
{
	States { Spawn: RSLR A -1 Bright; Stop; }
}
// THE RANGE READOUT's glyph (owner 11-10: "Redo it as glyphs"): one character, a billboard whose picture is set
// through picnum (graphics/rsqls/RSLNnnn, tools/gen_readout_glyphs.py), drawn AddShaded in the dot's colour. The
// series' way (RSQ Score's wrist digits, the Saber's training-remote panel): QZD 17.3 draws a canvas black or not at
// all in VR, and the old canvas readout (RSLRANGE) was never seen on the rig (P4, 11-10, L5).
class RSQLS_ReadoutGlyph : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP +BRIGHT +NOTIMEFREEZE
		RenderStyle "AddShaded";
		Radius 1; Height 1;
	}
	States { Spawn: TNT1 A -1 Bright; Stop; }
}

class RSQLS_Sight : EventHandler
{
	// ---- BEAM SPARKLE (owner 2026-11-07 05:49, built 11-10; design/PARKED.md): the Quest beam only, a toggle, off ------
	// The stray bright voxels once seen in the outer beam were never tracked down; instead points on the beam's outer
	// shell sparkle gently, almost imperceptibly: now and then one tiny additive particle at a random point along the
	// beam's lit length, a hair off its line, in the beam's colour whitened, fading out in a third of a second. Particles
	// (no actor, no light, no voxel frames: Quest memory). RSQ Accessibility's Photosensitive Mode dims them and halves
	// how often. Local, drawn only; its RNG feeds nothing else.
	const SPARK_EVERY = 5;        // tics between sparks, a hand (x2 in Photosensitive Mode)
	const SPARK_OFF_CM = 0.35;    // off the beam's line
	private int sparkNext[2];
	private void Sparkle(int h, Vector3 at, Vector3 dir, double len, int rgb, double a)
	{
		if (len <= 1 || level.maptime < sparkNext[h]) return;
		bool photo = RSQLS_A11y.Photo();
		sparkNext[h] = level.maptime + random[RSQLSSpark](SPARK_EVERY - 2, SPARK_EVERY + 3) * (photo ? 2 : 1);
		Vector3 d = dir.Length() > 0 ? dir.Unit() : (1, 0, 0);
		Vector3 side = d cross (0, 0, 1);
		if (side.Length() < 0.1) side = d cross (1, 0, 0);
		side = side.Unit();
		Vector3 up = d cross side;
		double t = frandom[RSQLSSpark](0.04, 0.85) * len;
		double ang = frandom[RSQLSSpark](0, 360);
		double off = SPARK_OFF_CM * RSQLS_Hand.Upm() / 100.0;
		int r = (rgb >> 16) & 255, g = (rgb >> 8) & 255, b = rgb & 255;
		r = (r + 255) / 2; g = (g + 255) / 2; b = (b + 255) / 2;
		FSpawnParticleParams pp;
		pp.color1 = Color(255, r, g, b);
		pp.style = STYLE_Add;
		pp.flags = SPF_FULLBRIGHT;
		pp.lifetime = random[RSQLSSpark](8, 12);
		pp.size = frandom[RSQLSSpark](0.8, 1.4);
		pp.sizestep = 0;
		pp.pos = at + d * t + (side * cos(ang) + up * sin(ang)) * off;
		pp.vel = (0, 0, 0);
		pp.accel = (0, 0, 0);
		pp.startalpha = RSQLS_A11y.Dim(clamp(a, 0.1, 1.0) * 0.6);
		pp.fadestep = -1;
		level.SpawnParticle(pp);
	}

	const LEAD_JUMP = 17.0;     // map units in one tic (~0.5 m) that is not a hand

	private Actor spot[2];
	private Actor glow[2];
	private bool  beamShown[2];
	private bool  spotShown[2];

	// Which hands drew a laser last tic (bit 0 main, bit 1 off), for other mods
	// through RSQLS_SightService. Console player only, like the drawing.
	transient int liveMask;
	transient int beamMask;   // the same, beam only
	// The line each hand's beam was drawn on this tic (its muzzle and barrel, from the held model), for RSQ Wheel's
	// card pick (owner 11-05: "use the gun's laser sight to select from the wheel"; RSQ Wheel does not read it yet).
	// Valid while beamMask has the hand.
	transient Vector3 lineAt[2], lineDir[2];
	// A RELOAD OR A SWITCH (owner 11-10: "hide it until ready again"). The beam's kept pose (above) is for the frames
	// between shots (11-09: "PCVR laser sight disappears between shots. not good."), so it holds for a second after
	// any attack press, which covers the fire, recoil and pump frames of every gun; past that an unmeasured frame is a
	// reload or a raise / lower and the beam hides until the gun is back on a measured frame. A pending switch hides
	// the main hand's at once. (Frame labels are not read: Brutal Doom's fire jumps between labels freely.)
	const KEEP_AFTER_FIRE = 35;
	transient int lastFireTic;
	bool Busy(PlayerInfo p, int h)
	{
		if (!p) return false;
		if (p.cmd.buttons & (BT_ATTACK | BT_ALTATTACK)) lastFireTic = level.maptime;
		if (h == 0 && p.PendingWeapon != WP_NOCHANGE) return true;
		return level.maptime - lastFireTic > KEEP_AFTER_FIRE;
	}

	// QUESTZDOOM'S OWN LASER (owner 11-10 23:0x: "Qzd autoloads laser sight. We want ours to always win but not
	// conflict."). QuestZDoom's launcher autoloads M8F's Laser Sight (mmaulwurff/laser-sight: handler m8f_ls_EventHandler,
	// switch m8f_wm_ShowLaserSight). While RSQ Laser Sight is on, M8F's switch is held at 0: its WorldTick returns before
	// tracing (ls_event_handler.zs:43), so no second dot and no 0-damage LineAttack every tic for BD22 VR to turn into
	// rounds (rig P4 L2: a flash and tracer every frame). The player's own M8F setting is kept in rsqls_m8f_was and put
	// back when RSQ Laser Sight is turned off. Found by name: nothing links to M8F's mod; without it, nothing happens.
	// (Replaces the 11-10 Which Laser row.)
	transient int m8fState;       // 0 not looked, 1 loaded, -1 not
	void M8FQuiet(PlayerInfo p, bool oursOn)
	{
		if (m8fState == 0)
		{
			String hn = "m8f_ls_EventHandler";
			class<Object> hc = hn;
			m8fState = hc ? 1 : -1;
		}
		if (m8fState < 0) return;
		let sw = CVar.GetCVar("m8f_wm_ShowLaserSight", p);
		let was = CVar.GetCVar("rsqls_m8f_was", p);
		if (!sw || !was) return;
		if (oursOn)
		{
			if (sw.GetInt() != 0) { was.SetInt(sw.GetInt()); sw.SetInt(0); }
		}
		else if (was.GetInt() >= 0)
		{
			sw.SetInt(was.GetInt());
			was.SetInt(-1);
		}
	}

	static bool, Vector3, Vector3 BeamLine(int h)
	{
		let me = RSQLS_Sight(EventHandler.Find("RSQLS_Sight"));
		h &= 1;
		if (!me || !((me.beamMask >> h) & 1)) return false, (0, 0, 0), (0, 0, 0);
		return true, me.lineAt[h], me.lineDir[h];
	}
	static int BeamHands()
	{
		let me = RSQLS_Sight(EventHandler.Find("RSQLS_Sight"));
		return me ? me.beamMask : 0;
	}
	// ---- THE GUN BONSAI VR PATCH'S LEVELS (GBOVR_TREES.md 4.8), the console player's, once a second ------------------
	// Target Lock and Headshot Reaction are unlocks under the patch: they unlock rsqls_lock (1), rsqls_target_recolor
	// (2) and rsqls_head (1) -- unlearned the feature is off, learned the ROW decides (owner 11-04 "Row can still turn it
	// off"; learning switches the row on once, GBOVR's RowsOnLearn). Without the patch the rows as before.
	// The two nodes exist only when the patch can offer them: they hang from RSQ Tactical Rig's Quick Draw (the patch's
	// RSQ_LaserPerk -> RSQ_RigPerk.ModLoaded needs RSQTR_RigService). With the patch but no Rig they can never be learned,
	// so the rows rule then (0.99a bug 8: Target Lock, on by default, could never turn on).
	transient int gbTic, gbLock, gbHead;
	transient bool gbOn;
	void GbRefresh(PlayerPawn pmo)
	{
		if (gbTic > 0 && level.maptime < gbTic && level.maptime >= gbTic - 35) return;
		gbTic = level.maptime + 35;
		let svc = ServiceIterator.Find("RSQ_MeleeUpgradeService").Next();
		if (svc && !ServiceIterator.Find("RSQTR_RigService").Next()) svc = null;
		gbOn = svc != null;
		gbLock = svc ? max(0, svc.GetInt("plevel", "TargetLock", 0, 0, pmo)) : 0;
		gbHead = svc ? max(0, svc.GetInt("plevel", "HeadshotReaction", 0, 0, pmo)) : 0;
	}
	static clearscope bool Lock(PlayerInfo p)    { let me = RSQLS_Sight(EventHandler.Find("RSQLS_Sight")); return (!me || !me.gbOn || me.gbLock >= 1) && RSQLS_Hand.Flag("rsqls_lock", p, true); }
	static clearscope bool Recolor(PlayerInfo p) { let me = RSQLS_Sight(EventHandler.Find("RSQLS_Sight")); return (!me || !me.gbOn || me.gbLock >= 2) && RSQLS_Hand.Flag("rsqls_target_recolor", p, false); }
	static clearscope bool Head(PlayerInfo p)    { let me = RSQLS_Sight(EventHandler.Find("RSQLS_Sight")); return (!me || !me.gbOn || me.gbHead >= 1) && RSQLS_Hand.Flag("rsqls_head", p, false); }
	// HEADSHOT REACTION 2: the monster each hand's dot sat on the head of, and when. REMA port: local state (the console
	// player's laser) feeding damage -- fine on QuestZDoom, which has no netplay (owner 11-02).
	Actor dotHead[2];
	int headTic[2];
	static int HeadOn(Actor target)
	{
		let me = RSQLS_Sight(EventHandler.Find("RSQLS_Sight"));
		if (!me || !target || !me.gbOn || me.gbHead < 2 || !playeringame[consoleplayer] || !Head(players[consoleplayer])) return 0;   // the Headshot Reaction row too
		for (int h = 0; h < 2; h++) if (me.dotHead[h] == target && level.maptime - me.headTic[h] <= 1) return 1;
		return 0;
	}

	static int LiveHands()
	{
		let me = RSQLS_Sight(EventHandler.Find("RSQLS_Sight"));
		return me ? me.liveMask : 0;
	}

	// The light currently attached to each spot, so it is only re-attached when
	// it changes -- A_AttachLight rebuilds the light.
	private int   lightColor[2];
	private int   lightRadius[2];
	private bool  lightOn[2];

	// ---- phase 3 ------------------------------------------------------------
	const ARC_N = 24;          // dots along a thrown weapon's arc, per hand
	const ARC_TICS = 140;      // the longest flight simulated: four seconds
	const RING_PX = 28.8;      // RSLR's ring radius in pixels (0.9 x 32)
	private Actor arcDot[48];  // ARC_N per hand
	private bool  arcShown[2];
	const SEG_N = 64;          // the most segments of the beam bent along an arc, per hand
	const SEG_LEN = 8.0;       // map units a segment covers at most (shorter arcs: fewer segments)
	private Actor arcSeg[128]; // SEG_N per hand
	private Actor arcHalo[128];// SEG_N per hand: Laser: PC VR's halo around each segment
	const HALO_W = 2.8;        // the arc halo's width, map units (the halo skin is 28 px at 0.1 unit; gen_assets.py)
	private bool  segShown[2];
	private Actor ring[2];
	// THE RANGE READOUT: READ_N characters, READ_LAYERS actors each, spawned once (the first time it shows) and moved.
	const READ_N = 8;
	const READ_LAYERS = 2;     // two on the same spot: AddShaded draws by brightness (RSQ Score's wrist, rig 11-01)
	private Actor readGlyph[16];   // READ_N * READ_LAYERS
	private bool  readShown;
	private transient TextureID readTex[128];   // by ASCII code: RSLNnnn
	private transient bool readTexFound;
	// The simulated path (no dynamic arrays of vectors on 4.12-4.14: three of doubles).
	private transient Array<double> arcX, arcY, arcZ;
	private void ArcClear() { arcX.Clear(); arcY.Clear(); arcZ.Clear(); }
	private void ArcPush(Vector3 v) { arcX.Push(v.x); arcY.Push(v.y); arcZ.Push(v.z); }
	private Vector3 ArcAt(int i) { return (arcX[i], arcY[i], arcZ[i]); }
	// The weapon pack's muzzle point (LaserMuzzleService), cached per weapon class.
	private transient String mzKey[2];
	private transient bool   mzGot[2];
	private transient double mzF[2], mzU[2], mzS[2];
	// What the readout shows: room metres to the hit (0 = nothing), its colour.
	transient double rangeM[2];
	transient double rangeU[2];   // the same, map units along the trace (the Map Units readout; owner 11-10)
	transient int    rangeRgb[2];
	transient double readM;
	transient double readU;
	transient int    readRgb;
	transient String readTxt;     // what it shows ("341 u")

	// Leading (see header).
	private Vector3 lastMuzzle[2], lastHit[2];
	private bool    muzzlePrimed[2], hitPrimed[2];

	// The last measured pose each hand's gun was drawn in, and that gun (DrawHand: the beam holds it between shots).
	private int    heldRow[2];
	private Weapon heldGun[2];

	// Toggle edge detection, for the haptic tick.

	// ---- placement helpers ----------------------------------------------------

	private Actor Ensure(Actor a, Class<Actor> cls)
	{
		if (a) return a;
		a = Actor.Spawn(cls, (0, 0, 0));
		if (a) a.bINVISIBLE = true;
		return a;
	}

	// A piece coming back from hidden TELEPORTS into place rather than streaking
	// in from wherever it was left.
	private static void Put(Actor a, bool wasShown, Vector3 pos)
	{
		if (!wasShown) { a.SetOrigin(pos, false); a.ClearInterpolation(); }
		else a.SetOrigin(pos, true);
		a.bINVISIBLE = false;
	}

	private static void Hide(Actor a) { if (a) a.bINVISIBLE = true; }

	private void HideBeam(int h)
	{
		let p = players[consoleplayer];
		if (p) RSQLS_Beams.Hide(p, h);
		beamShown[h] = false;
	}
	private void HideSpot(int h)
	{
		if (spot[h])
		{
			spot[h].bINVISIBLE = true;
			if (lightOn[h]) { spot[h].A_RemoveLight('RSQLS'); lightOn[h] = false; }
		}
		Hide(glow[h]);
		spotShown[h] = false;
		hitPrimed[h] = false;
	}
	private void HideArc(int h)
	{
		if (!arcShown[h]) return;
		for (int i = 0; i < ARC_N; i++) Hide(arcDot[h * ARC_N + i]);
		arcShown[h] = false;
	}
	private void HideArcBeam(int h)
	{
		if (!segShown[h]) return;
		for (int i = 0; i < SEG_N; i++) { Hide(arcSeg[h * SEG_N + i]); Hide(arcHalo[h * SEG_N + i]); }
		segShown[h] = false;
	}
	private void HideHand(int h) { HideBeam(h); HideSpot(h); HideArc(h); HideArcBeam(h); Hide(ring[h]); rangeM[h] = 0; muzzlePrimed[h] = false; }

	// ---- which hands have a laser right now -----------------------------------
	private bool HandLive(PlayerInfo p, int h)
	{
		if (!RSQLS_Hand.Flag(h == 0 ? "rsqls_main" : "rsqls_off", p, true)) return false;
		Weapon w = (h == 0) ? p.ReadyWeapon : p.OffhandWeapon;
		if (!w) return false;
		// THE ENGINE TAKES THE OFF HAND'S GUN WHEN YOU BRACE, SO THE LASER GOES WITH IT.
		// vr_two_handed_weapons is on by default (hw_vrmodes.cpp:119), and the off-hand grip
		// pressed with the controllers inside 0.50 m latches weaponStabilised on the grip's
		// rising edge (gl_openvr.cpp:1716-1727). The renderer then skips every psprite layer
		// whose CALLER is the off-hand weapon -- sprites at hw_weapon.cpp:832-835, models at
		// :917-920 -- and the beam is exactly such a layer, handed to the gun itself
		// (beam.zs Show). So the beam went out on its own, while the spot, the glow, its
		// light, the spread ring and the range readout -- world actors, no business of
		// hw_weapon's -- kept drawing from a gun the engine had stopped drawing, down the
		// SUPPORT hand's axis rather than any barrel. And liveMask kept bit 1 set, so
		// RSQLS_SightService reported a live off-hand laser to RSQ_DistanceGrab, which stood
		// its grab beam down for a laser that was not there.
		// The hand stands down whole instead: HideHand(1) takes beam, spot, glow, light and
		// ring, and zeroes that hand's range so UpdateReadout drops the readout with them; the
		// service bit is simply never set this tic. NOT by clearing the flag --
		// p_pspr.cpp:512-515 re-asserts it from the C++ global on every psprite state set.
		// Grip release clears it with no distance test (gl_openvr.cpp:1724-1726) and the laser
		// comes straight back. OpenVR/SteamVR only in this tree: weaponStabilised is written
		// at gl_openvr.cpp:1723 and :1726 and nowhere else, so on Quest/OpenXR this test
		// simply never fires.
		if (h == 1 && (p.WeaponState & WF_TWOHANDSTABILIZED) != 0) return false;
		// NOTHING TO AIM: a melee weapon (fist, chainsaw, the QuestSaber), or a
		// hand that is not a gun at all. CHEATNOTWEAPON is the stock marker for
		// the second -- it is what keeps a thing out of `give weapons` -- and
		// every off-hand utility in the family carries it: RS_ShieldSawQ's
		// shield, the QuestSaber's Force hand, RSQ_Hands. Found in the rig:
		// with the shield drawn, a laser came out of the shield.
		// A MEASURED GUN is a gun whatever its flags: Brutal Doom Quest's off-hand dual
		// copies (RSQ_Off_*) carry CHEATNOTWEAPON too, so `give weapons` skips them.
		// Found in the rig 2026-10-27: the off-hand copy drew no laser.
		let bt = RSQLS_Beams.Get();
		bool measured = bt && bt.Find(w) >= 0 && !w.bMELEEWEAPON;
		if ((w.bMELEEWEAPON || w.bCHEATNOTWEAPON) && !measured && !RSQLS_Hand.Flag("rsqls_show_melee", p, false)) return false;
		// OFF WHEN LOWERED (owner 2026-10-31): a gun pointed at the floor past rsqls_lower_deg, or on its way in or out
		// of the hand (a switch, a holster), draws no laser. 0 = always on.
		double lower = RSQLS_Hand.Num("rsqls_lower_deg", p, 55.0);
		if (lower > 0 && p.mo && RSQLS_Hand.Pitch(p.mo, h) < -lower) return false;
		if (lower > 0 && h == 0 && p.PendingWeapon != WP_NOCHANGE) return false;
		if (RSQLS_Hand.Flag("rsqls_ready_only", p, false))
		{
			int ready = (h == 0) ? (WF_WEAPONREADY | WF_WEAPONREADYALT)
			                     : (WF_OFFHANDREADY | WF_OFFHANDREADYALT);
			if (!(p.WeaponState & ready)) return false;
		}
		return true;
	}

	// ---- the colours (UZDXREMA's colour block, on runtime translations) -------
	//
	// Order of precedence, lowest first: the colour mode's base colour; the
	// weapon slot's colour; a colour the WEAPON asks for (any loaded mod's
	// LaserColorService -- absent-safe, found by name at run time); cycling;
	// on a live hostile the target colour; on a lined-up headshot the headshot
	// colour. Returns 0xRRGGBB.
	// COLOUR-BLIND PLAY (RSQ_Accessibility's rsqa_colorblind, cb.zs). The stock pair, red main and
	// green off, is one colour to a deuteranope and a dim one to a protanope; with the setting on
	// the hands' own colours become the series pair for that vision (main azure / cyan / magenta,
	// off amber / red / yellow; one colour mode: the main's). The target recolour stands down: a
	// third hue is one more to tell apart (rendered, a white target dot against the tritan red
	// off hand was 9.9 apart), so the lock shows by shape -- the dot swells and pulses twice as
	// deep. A colour the player picked per slot, a weapon's own, or cycling stay as they are.
	static int CBHand(int c, int h, int colorMode)
	{
		if (!RSQLS_CB.Mode()) return c;
		bool off = (h == 1 && colorMode != 0);
		return RSQLS_CB.Pick(off ? RSQLS_CB.CB_COULD : RSQLS_CB.CB_HAVE, c);
	}

	private int ColorOf(PlayerInfo p, int h, Weapon w, bool isDot, bool hostile, bool head)
	{
		int mode = RSQLS_Hand.Opt("rsqls_color_mode", p, 1);
		int beamCol = RSQLS_Hand.Opt((mode == 0 || h == 0) ? "rsqls_col_main" : "rsqls_col_off", p, 0xFF2010);
		int c = beamCol;
		bool own = false;    // the dot has its own colour (mode 2)
		bool handCol = true; // c is still a hand's own colour (colour-blind play swaps those)
		if (isDot && mode == 2)
		{
			c = RSQLS_Hand.Opt(h == 0 ? "rsqls_col_dot_main" : "rsqls_col_dot_off", p, 0xFF2010);
			own = true;
		}

		if (w && !own && RSQLS_Hand.Flag("rsqls_col_per_slot", p, false))
		{
			int sl = w.SlotNumber;
			if (sl >= 0 && sl <= 9)
			{
				c = RSQLS_Hand.Opt(String.Format("rsqls_col_slot%d", sl), p, c);
				handCol = false;
			}
		}

		if (w)
		{
			let it = ServiceIterator.Find("LaserColorService");
			Service sv;
			while (sv = it.Next())
			{
				int r = sv.GetInt("laser.color", w.GetClassName(), h, isDot ? 1.0 : 0.0, w, 'RSQ_LaserSight');
				if (r >= 0) { c = r & 0xFFFFFF; handCol = false; break; }
			}
		}

		if (RSQLS_Hand.Flag("rsqls_cycle", p, false) && (!isDot || RSQLS_Hand.Flag("rsqls_cycle_dot", p, true)))
		{
			double speed = RSQLS_Hand.Num("rsqls_cycle_speed", p, 60.0);
			// 36 hues (10 degrees apart) so the translation cache holds them all.
			double deg = level.maptime * speed / TICRATE + h * 180.0;
			c = RSQLS_Colors.Hue(floor(deg / 10.0) * 10.0);
			handCol = false;
		}
		if (handCol) c = CBHand(c, h, mode);

		if (hostile && Lock(p) && Recolor(p)
			&& !RSQLS_CB.Mode())
			c = RSQLS_Hand.Opt("rsqls_col_target", p, 0xFFE020);

		if (head && Head(p))
		{
			int hc = RSQLS_Hand.Opt("rsqls_col_head", p, 0xFFFFFF);
			if (RSQLS_Hand.Flag("rsqls_head_pulse", p, true))
			{
				double hz = RSQLS_A11y.Hz(RSQLS_Hand.Num("rsqls_head_pulse_hz", p, 4.0));   // Photosensitive Mode: <= 2.5
				double ph = 0.5 + 0.5 * sin(level.maptime * hz * 360.0 / TICRATE);
				// Quantised to 8 steps, again for the cache.
				c = RSQLS_Colors.Mix(c, hc, floor(ph * 8.0) / 8.0);
			}
			else c = hc;
		}
		return c & 0xFFFFFF;
	}

	override void WorldTick()
	{
		liveMask = 0; beamMask = 0;
		let p = players[consoleplayer];
		if (!p || !p.mo) return;
		let pmo = p.mo;
		GbRefresh(pmo);


		bool wantDot  = RSQLS_Hand.Flag("rsqls_pointer", p, true);
		bool wantBeam = RSQLS_Hand.Flag("rsqls_beam", p, true);
		// IR: invisible to the naked eye. The light amplification goggles
		// (Doom's PowerLightAmp, from the Infrared pickup) show it.
		bool ir = RSQLS_Hand.Flag("rsqls_ir", p, false);
		bool irVisible = ir && pmo.FindInventory("PowerLightAmp", true) != null;

		bool oursOn = RSQLS_Hand.Flag("rsqls_on", p, true);
		M8FQuiet(p, oursOn);
		if (pmo.Health <= 0 || !oursOn
			|| (!wantDot && !wantBeam) || (ir && !irVisible))
		{
			HideHand(0); HideHand(1);
			UpdateReadout(pmo, p);
			return;
		}

		for (int h = 0; h < 2; h++)
		{
			if (!HandLive(p, h)) { HideHand(h); continue; }
			spot[h] = Ensure(spot[h], "RSQLS_Spot");
			glow[h] = Ensure(glow[h], "RSQLS_Glow");
			if (!spot[h] || !glow[h]) continue;
			DrawHand(h, pmo, p, wantBeam, wantDot);
			// What actually drew (review, 10-26): a dot-only laser that hits nothing is no light.
			if (beamShown[h] || spotShown[h]) liveMask |= 1 << h;
			if (beamShown[h]) beamMask |= 1 << h;
		}
		UpdateReadout(pmo, p);
	}

	// 0 plain, 1 liquid, 2 metal: by the texture's name (Doom's own naming), cached per texture.
	private Array<int> surfTex, surfKind;
	private int Surface(TextureID tex)
	{
		if (!tex.IsValid()) return 0;
		int id = int(tex);
		int i = surfTex.Find(id);
		if (i < surfTex.Size()) return surfKind[i];
		String n = TexMan.GetName(tex);
		n = n.MakeUpper();
		int k = 0;
		static const String liquid[] = { "WATER", "NUKAGE", "LAVA", "BLOOD", "SLIME", "FALL" };
		static const String metal[] = { "METAL", "SUPPORT", "DOOR", "STEEL", "SHAWN", "PLAT", "PIPE" };
		for (int j = 0; j < liquid.Size() && k == 0; j++) if (n.IndexOf(liquid[j]) >= 0) k = 1;
		for (int j = 0; j < metal.Size() && k == 0; j++) if (n.IndexOf(metal[j]) >= 0) k = 2;
		surfTex.Push(id); surfKind.Push(k);
		return k;
	}

	private void DrawHand(int h, PlayerPawn pmo, PlayerInfo p, bool wantBeam, bool wantDot)
	{
		Weapon w = (h == 0) ? p.ReadyWeapon : p.OffhandWeapon;
		let bt = RSQLS_Beams.Get();
		int ci = bt ? bt.Find(w) : -1;
		let gp = p.FindPSprite(h == 0 ? PSprite.WEAPON : PSprite.OFFHANDWEAPON);
		// The pose the gun is drawn in right now (-1: none measured -- kept below), and the
		// placement the dot is traced from: that pose's, or the class's first while none shows.
		int row = (ci >= 0) ? bt.PoseRow(ci, gp) : -1;
		// THE BEAM STAYS ON BETWEEN SHOTS (owner 2026-11-09: "PCVR laser sight disappears between shots. not good."). A
		// frame no measurement names -- the fire and recovery frames between two shots, a frame a newer weapon pack added
		// -- used to give -1 here, and -1 took the beam away (below) until the gun came back to a measured frame: it
		// blinked off on every shot. Now the gun keeps the last pose it was measured in while it stays in that hand; the
		// beam layer still follows every turn and kick the gun layer's offset gives it (beam.zs, PSPF_ADDWEAPON).
		if (ci >= 0)
		{
			if (row >= 0) { heldRow[h] = row; heldGun[h] = w; }
			else if (heldGun[h] == w && heldRow[h] >= ci && !Busy(p, h)) row = heldRow[h];
		}
		int pi = (row >= 0) ? bt.Place(row) : ((ci >= 0) ? bt.Place(ci) : -1);

		// ---- the muzzle and the barrel -------------------------------------------
		// A MEASURED GUN: its muzzle and barrel from its held model (tools/gen_beams.py),
		// carried from the controller's HUD frame into the map the way the renderer
		// carries the gun (hand.zs HudPoint). vr_weaponScale stretches the gun about its
		// MODELDEF Offset, so it stretches the muzzle's distance from it too.
		// ANY OTHER GUN: no beam; the spot is traced from the grip along the aim -- the
		// shot's own line (OverrideAttackPosDir) -- or from the point a weapon pack's
		// LaserMuzzleService names.
		Vector3 muzzle, dir;
		Vector3 beamAt, beamDir;   // the beam's own line (the mesh's muzzle and barrel), kept for BeamLine
		if (pi >= 0)
		{
			let wsc = CVar.FindCVar("vr_weaponScale");
			double ws = wsc ? wsc.GetFloat() : 1.0;
			muzzle = RSQLS_Hand.HudPoint(pmo, h, RSQLS_Beams.Offset(pi) + RSQLS_Beams.Muzzle(pi) * ws);
			dir = RSQLS_Hand.HudDir(pmo, h, RSQLS_Beams.Barrel(pi));
			beamAt = muzzle; beamDir = dir;
		}
		else
		{
			muzzle = RSQLS_Hand.Grip(pmo, h);
			if (w)
			{
				bool got; double f, u, sd;
				[got, f, u, sd] = MuzzleFor(h, w);
				if (got) muzzle += RSQLS_Hand.GunOffset(pmo, h, f, u, sd);
			}
			dir = RSQLS_Hand.Dir(pmo, h);
		}
		// THE DOT FOLLOWS THE SHOT (owner 2026-10-31: "lasersight pulled to the left"). Brutal Doom VR 2.0 fires every
		// gun with a bore from its own muzzle table down the drawn barrel, 3.85 deg left and 3.36 deg up of the
		// controller (its fix-accuracy). The dot is traced along that same line, from that same muzzle (bdbore.zs,
		// parsed from its code); the beam is still drawn on the mesh's barrel, which is the same line.
		if (w && RSQLS_Hand.Flag("rsqls_bd_bore", p, true) && RSQLS_BDBore.Active())
		{
			bool bdGot; Vector3 bdAt, bdDir;
			[bdGot, bdAt, bdDir] = RSQLS_BDBore.Line(pmo, h, w);
			if (bdGot) { muzzle = bdAt; dir = bdDir; }
		}
		// STEADY HANDS (RSQ_Accessibility, hand.zs Steadied): the dot's line from the smoothed hand. Off / absent: raw.
		double aimYaw, aimPitch;
		bool steady;
		[steady, muzzle, dir, aimYaw, aimPitch] = RSQLS_Hand.Steadied(pmo, h, muzzle, dir);

		// A THROWN WEAPON (grenades): once it has been seen firing, the line is
		// the ballistic path its projectile will take, and the spot is where it
		// lands (learn.zs). The straight beam would point at the wrong place.
		bool arcOn = false;
		double aSp, aGr, aEl, aYw;
		if (w && RSQLS_Hand.Flag("rsqls_arc", p, true))
			[arcOn, aSp, aGr, aEl, aYw] = RSQLS_Learn.Arc(w);
		// THE BEAM BENDS WITH THE ARC (owner 2026-11-06: "the grenade launcher laser is a straight line and not an arc"):
		// with Arc With Beam on, the beam is drawn along the arc (LayArcBeam), never straight; off, only the dots show
		bool arcBeam = arcOn && wantBeam && RSQLS_Hand.Flag("rsqls_arc_beam", p, true);
		if (arcOn) wantBeam = false;

		// ---- the trace: from the muzzle, along the barrel -------------------------
		// TRF_ABSPOSITION with coordinates computed here and zero offsets:
		// P_LineTrace accumulates offsets onto an uninitialised vector exactly
		// when OverrideAttackPosDir is true, which in VR is always.
		double range = RSQLS_Hand.Num("rsqls_range", p, 2048.0);
		FLineTraceData t;
		bool hit;
		Vector3 end;
		if (arcOn)
		{
			// One tic at a time, exactly as the engine will move it: position
			// plus velocity, then gravity off the velocity. Each tic's segment is
			// a LineTrace, so the arc stops at the first wall, floor or body.
			ArcClear();
			double g = level.gravity * aGr * 0.00125;
			Sector s0 = level.PointInSector(muzzle.xy);
			if (s0) g *= s0.gravity;
			Vector3 v = RSQLS_Hand.Fwd(aimYaw + aYw, aimPitch + aEl) * aSp;   // aimYaw / aimPitch: Yaw / Pitch, or steadied
			Vector3 pos = muzzle;
			hit = false;
			ArcPush(muzzle);
			for (int i = 0; i < ARC_TICS; i++)
			{
				Vector3 np = pos + v;
				v.z -= g;
				Vector3 seg = np - pos;
				double sl = seg.Length();
				if (sl > 0.01 && pmo.LineTrace(VectorAngle(seg.x, seg.y), sl, -atan2(seg.z, seg.xy.Length()),
					TRF_ABSPOSITION, pos.z, pos.x, pos.y, t))
				{
					hit = true;
					ArcPush(t.HitLocation);
					break;
				}
				ArcPush(np);
				pos = np;
			}
			end = ArcAt(arcX.Size() - 1);
		}
		else
		{
			hit = pmo.LineTrace(VectorAngle(dir.x, dir.y), range, -atan2(dir.z, dir.xy.Length()),
				TRF_ABSPOSITION, muzzle.z, muzzle.x, muzzle.y, t);
			end = hit ? t.HitLocation : (muzzle + dir * range);
		}
		bool sky = hit && t.HitType == FLineTraceData.TRACE_HasHitSky;
		double hitCm = -1;      // room centimetres from the muzzle to what the trace hit
		{
			Vector3 rd = end - muzzle;
			double vu = RSQLS_Hand.Upm();
			let vc = CVar.FindCVar("vr_vunits_per_meter");
			if (vc) vu = vc.GetFloat();
			double roomM = (rd.x, rd.y, rd.z * RSQLS_Hand.Ps()).Length() / vu;
			rangeM[h] = (hit && !sky) ? roomM : 0;
			rangeU[h] = (hit && !sky) ? rd.Length() : 0;
			if (hit && !sky && !arcOn) hitCm = roomM * 100.0;
		}

		// ---- lead (the spot only): a tic ahead, if asked for ---------------------
		double lead = clamp(RSQLS_Hand.Num("rsqls_lead", p, 0.0), 0.0, 2.0);
		Vector3 drawMuzzle = muzzle, drawEnd = end;
		if (muzzlePrimed[h])
		{
			Vector3 v = muzzle - lastMuzzle[h];
			if (v.Length() <= LEAD_JUMP) drawMuzzle = muzzle + v * lead;
		}
		lastMuzzle[h] = muzzle; muzzlePrimed[h] = true;
		if (hit && !sky && hitPrimed[h])
		{
			Vector3 v = end - lastHit[h];
			// The far end legitimately moves much faster than the hand; only a
			// jump onto a different surface is refused.
			if (v.Length() <= LEAD_JUMP * 12) drawEnd = end + v * lead;
		}
		if (hit && !sky) { lastHit[h] = end; hitPrimed[h] = true; }
		else hitPrimed[h] = false;
		double len = (drawEnd - drawMuzzle).Length();

		// ---- what it is on ------------------------------------------------------
		Actor onWho = (hit && t.HitType == FLineTraceData.TRACE_HitActor) ? t.HitActor : null;
		bool hostile = onWho && onWho.bISMONSTER && onWho.Health > 0 && !onWho.bFRIENDLY;
		// A LINED-UP HEADSHOT, approximately: the hit lands in the top fifth of
		// the body. What counts as a head is the gameplay mod's business; this
		// only shows it (UZDXREMA's Headshot Reaction, as near as script gets).
		bool head = hostile && t.HitLocation.z >= onWho.Pos.z + onWho.Height * 0.8;
		if (head) { dotHead[h] = onWho; headTic[h] = level.maptime; }

		int beamRgb = ColorOf(p, h, w, false, hostile, head);
		int dotRgb  = ColorOf(p, h, w, true,  hostile, head);
		TranslationID dotTint  = RSQLS_Colors.Tint(dotRgb);
		rangeRgb[h] = dotRgb;
		if (arcOn) LayArc(h, dotTint, p); else HideArc(h);
		// the bent beam: a measured gun in a measured (or kept) pose, as the straight beam; any other gun whenever its arc
		// is known (it has no pose to check); its colour and brightness are the beam's
		if (arcBeam && (row >= 0 || ci < 0))
		{
			Sector bs = Level.PointInSector(muzzle.xy);
			double blit = bs ? clamp(bs.lightlevel / 255.0, 0.0, 1.0) : 0.5;
			double ba = RSQLS_Hand.Num("rsqls_beam_a", p, 0.8) * (1.0 - (1.0 - RSQLS_Hand.Num("rsqls_beam_daylight", p, 0.35)) * blit);
			LayArcBeam(h, beamRgb, clamp(ba, 0.05, 1.0), p);
		}
		else HideArcBeam(h);

		// The room's light at the muzzle, 0..1. Dark rooms show the beam.
		Sector sec = Level.PointInSector(muzzle.xy);
		double lit = sec ? clamp(sec.lightlevel / 255.0, 0.0, 1.0) : 0.5;

		// ---- the beam: on the gun, as far as the hit -------------------------------
		// From the pose its muzzle was measured in: the frame shown, or (between shots, any
		// frame not measured) the last measured one this gun showed in this hand (row, above).
		bool beamOn = false;
		if (wantBeam && row >= 0)
		{
			let wsc = CVar.FindCVar("vr_weaponScale");
			double ws = wsc ? wsc.GetFloat() : 1.0;
			double fadeCm = clamp(RSQLS_Hand.Num("rsqls_beam_len", p, 3.0), 0.5, RSQLS_Muzzles.FADE_MAX / 100.0) * 100.0;
			int k = RSQLS_Beams.Length(hitCm, fadeCm, ws);
			if (k >= 0)
			{
				double litFade = RSQLS_Hand.Num("rsqls_beam_daylight", p, 0.35);
				double a = RSQLS_Hand.Num("rsqls_beam_a", p, 0.8) * (1.0 - (1.0 - litFade) * lit);
				if (hostile && Lock(p)) a *= 1.35;
				// LASER: QUEST / PC VR (owner 2026-11-06; once "Beam Type"): Quest is the plain beam (no halo layer), PC VR the whiter core inside its
				// halo (beam.zs ShowGlow). One server setting, so both hands always match.
				if (RSQLS_Hand.Opt("rsqls_beam_type", p, 0) == 1) bt.ShowGlow(p, h, w, row, gp, k, beamRgb, a, fadeCm);
				else { bt.Show(p, h, w, row, gp, k, bt.Tint(beamRgb, a, fadeCm)); RSQLS_Beams.HideHalo(p, h); }
				if (RSQLS_Hand.Opt("rsqls_beam_type", p, 0) == 0 && RSQLS_Hand.Flag("rsqls_beam_sparkle", p, false))
					Sparkle(h, beamAt, beamDir, (hitCm >= 0 ? min(hitCm, fadeCm) : fadeCm) * RSQLS_Hand.Upm() / 100.0, beamRgb, a);
				beamOn = true;
			}
		}
		if (beamOn) { beamShown[h] = true; lineAt[h] = beamAt; lineDir[h] = beamDir; }
		else HideBeam(h);

		// ---- the spot: painted on what it hit ----------------------------------
		double dist = (end - muzzle).Length();
		double dotRange = RSQLS_Hand.Num("rsqls_dot_range", p, 0.0);
		// DOT ONLY ON ENEMIES (owner 2026-11-06, BUGS_1.0 #38, off by default): the dot shows only on a live hostile monster
		bool enemyOnly = RSQLS_Hand.Flag("rsqls_dot_enemy", p, false);
		if (!wantDot || !hit || sky || (dotRange > 0 && dist > dotRange) || (enemyOnly && !hostile)) { HideSpot(h); Hide(ring[h]); return; }

		let s = spot[h];
		Vector3 at = drawEnd;
		bool wallS = false, flatS = false;
		double sAngle = s.Angle;
		if (t.HitType == FLineTraceData.TRACE_HitWall && t.HitLine)
		{
			// The wall's own normal, turned to face the MUZZLE. Not from
			// FLineTraceData.LineSide: trusting that flag's sense put the spot
			// 0.4 units on the far side of the wall, where the depth test hid it
			// (found in the rig, 2026-10-26). Facing the gun is true by
			// construction, whichever way the line was drawn.
			Vector2 d = t.HitLine.delta;
			Vector2 n = (d.y, -d.x);
			double nl = n.Length();
			if (nl > 0) n /= nl;
			if ((n dot (muzzle.xy - end.xy)) < 0) n = -n;
			wallS = true;
			sAngle = VectorAngle(n.x, n.y);
			at += (n.x, n.y, 0) * 0.4;           // a hair off the wall, never inside it
		}
		else if (t.HitType == FLineTraceData.TRACE_HitFloor)
		{
			flatS = true;
			at.z += 0.3;
		}
		else if (t.HitType == FLineTraceData.TRACE_HitCeiling)
		{
			flatS = true;
			at.z -= 0.3;
		}
		else
		{
			// An actor: ON ITS BODY (pick 29; Quest teardown apply/06 §2.5). The trace hits the side of the actor's
			// collision square (p_trace.cpp:695-697: |dx| > r || |dy| > r), which stands r in front of the sprite
			// head-on and up to r*sqrt2 at a corner: the dot floated off the edge of a monster seen at an angle.
			// The monster is a billboard drawn through its centre, so the dot goes where the ray crosses that
			// plane (its closest approach to the centre), kept within 0.75 of the radius sideways -- the stock
			// sprites' half-widths run 0.75r..1.1r (doom2.wad TROO/POSS/SARG/HEAD/BOSS A frames, measured), so
			// that is on the body in every one -- and inside the body's height. Then it is brought toward the
			// EYE (so it keeps its place on screen; toward the muzzle it slid sideways off the body, rig) until
			// it is 2 units in front of the sprite's plane. The renderer turns a sprite square to the view's yaw
			// (or to the eye, gl_billboard_faces_camera), not to the ray: off the centre line those planes differ
			// by many units (rig, 2026-10-31: 16 units out on an imp at the screen's edge the dot sat behind the
			// sprite), so it clears all of them.
			if (len > 1 && onWho) at = OnBody(onWho, drawMuzzle, drawEnd, (pmo.Pos.xy, p.viewz), pmo.Angle);
			else if (len > 1) at += (drawMuzzle - drawEnd) * (2.0 / len);
		}
		s.bWALLSPRITE = wallS; s.bFLATSPRITE = flatS; s.Angle = sAngle;
		bool shownS = spotShown[h];
		Put(s, shownS, at);
		spotShown[h] = true;

		// CONSTANT APPARENT SIZE: about half a degree across at any range (a real
		// laser sight reads at roughly that), with a floor so it never shrinks to
		// nothing up close.
		double sc = RSQLS_Hand.Num("rsqls_spot_size", p, 1.0) * (0.03 + dist / 2000.0) * RSQLS_A11y.Cue();   // Cue Size (the glow follows)
		if (hostile && Lock(p))
		{
			// TARGET LOCK: it TIGHTENS onto the target and bites at the pulse rate.
			double tighten = clamp(RSQLS_Hand.Num("rsqls_lock_tighten", p, 0.0), 0.0, 0.9);
			double hz = RSQLS_A11y.Hz(RSQLS_Hand.Num("rsqls_lock_rate", p, 2.2));   // Photosensitive Mode: <= 2.5
			double depth = RSQLS_CB.Mode() ? 0.25 : 0.12;   // colour-blind play: the lock reads by its pulse
			sc *= (1.0 - tighten) * (1.25 + depth * sin(level.maptime * hz * 360.0 / TICRATE));
		}
		// WHAT IT LANDED ON (Quest teardown 99 7: the trace already names the texture it hit). On water, slime, lava or
		// blood the dot swims and scatters a little; on metal it glints, the glow wider. By texture name, once each.
		int surf = RSQLS_Hand.Flag("rsqls_surface", p, true) ? Surface(t.HitTexture) : 0;
		double sAlphaK = 1.0;
		if (surf == 1)
		{
			sc *= 1.0 + 0.18 * sin(level.maptime * 9.0 + h * 90.0);
			sAlphaK = 0.75;
		}
		s.Scale = (sc, sc);
		s.Alpha = clamp(RSQLS_Hand.Num("rsqls_spot_a", p, 1.0) * sAlphaK, 0.0, 1.0);
		s.Translation = dotTint;

		// ---- the spread ring: where this gun's shots can land (learn.zs) -------
		LayRing(h, w, p, at, dist, wallS, flatS, sAngle, arcOn, dotTint, shownS);

		// ---- the glow: off, a bloom, a real light, or both ----------------------
		int gmode = RSQLS_Hand.Opt("rsqls_glow", p, 3);
		double gscale = clamp(RSQLS_Hand.Num("rsqls_glow_scale", p, 1.8), 1.1, 4.0) * (surf == 2 ? 1.5 : 1.0);
		double gint = clamp(RSQLS_Hand.Num("rsqls_glow_int", p, 1.0), 0.1, 4.0);
		let g = glow[h];
		if (gmode == 1 || gmode == 3)
		{
			g.bWALLSPRITE = wallS; g.bFLATSPRITE = flatS; g.Angle = sAngle;
			// A hair in front of the spot so the two never fight for depth.
			Vector3 gat = at;
			if (wallS) gat += (cos(sAngle), sin(sAngle), 0) * 0.1;
			else if (flatS) gat.z += (t.HitType == FLineTraceData.TRACE_HitFloor) ? 0.1 : -0.1;
			Put(g, shownS && !g.bINVISIBLE, gat);
			g.Scale = (sc * gscale, sc * gscale);
			g.Alpha = clamp(0.30 * gint * s.Alpha, 0.0, 1.0);
			g.Translation = dotTint;
		}
		else Hide(g);

		if (gmode >= 2)
		{
			// Intensity scales the light's colour (the only brightness a point light has) up to 1; past 1 (owner 11-10) the
			// colour is full and the light reaches further by the rest, so the room brightens with the bloom
			int rad = int(clamp((10.0 + dist / 90.0) * gscale / 1.8 * max(1.0, gint), 6.0, 160.0));
			int lc = RSQLS_Colors.Mix(0, dotRgb, clamp(gint, 0.0, 1.0));
			if (!lightOn[h] || lightColor[h] != lc || abs(lightRadius[h] - rad) > 2)
			{
				s.A_AttachLight('RSQLS', DynamicLight.PointLight, lc, rad, rad,
					DynamicLight.LF_ATTENUATE);
				lightOn[h] = true; lightColor[h] = lc; lightRadius[h] = rad;
			}
		}
		else if (lightOn[h]) { s.A_RemoveLight('RSQLS'); lightOn[h] = false; }
	}

	// Where a ray from m through e (the trace's hit on the actor's collision square) shows on the actor's
	// billboard: the ray's closest approach to the actor's axis, no further than 0.75 radius sideways of it and
	// inside its height, then brought toward the eye until it is 2 units in front of the sprite's plane however
	// the renderer turns it (eye: the viewer; viewYaw: the view's yaw). See DrawHand (apply/06 §2.5).
	static Vector3 OnBody(Actor a, Vector3 m, Vector3 e, Vector3 eye, double viewYaw)
	{
		Vector3 d = e - m;
		double len = d.Length();
		if (len <= 1) return e;
		Vector3 u = d / len;
		double hl2 = u.x * u.x + u.y * u.y;
		double r = max(a.radius, 1.0);
		double s = len;
		if (hl2 > 0.0001)
			s = clamp(((a.pos.x - m.x) * u.x + (a.pos.y - m.y) * u.y) / hl2, len, len + r * 2.0);
		Vector3 p = m + u * s;
		Vector2 lat = p.xy - a.pos.xy;
		double ll = lat.Length();
		double side = r * 0.75;
		if (ll > side) p = (a.pos.xy + lat * (side / ll), p.z);
		p.z = clamp(p.z, a.pos.z, a.pos.z + a.height);
		// In front of every plane the sprite may be drawn in: square to the ray, to the eye, to the view's yaw.
		Vector3 back = eye - p;
		double bl = back.Length();
		if (bl <= 2) return p;
		Vector3 w = back / bl;
		double need = 2.0;
		for (int i = 0; i < 3; i++)
		{
			Vector2 n = (i == 0) ? a.pos.xy - m.xy : ((i == 1) ? a.pos.xy - eye.xy : (cos(viewYaw), sin(viewYaw)));
			double nl = n.Length();
			if (nl < 0.001) continue;
			n /= nl;
			double nw = n.x * w.x + n.y * w.y;
			if (nw > -0.1) continue;
			need = max(need, ((n dot (p.xy - a.pos.xy)) + 2.0) / -nw);
		}
		return p + w * min(need, bl);
	}

	// The arc: ARC_N dots spaced evenly by length along the simulated path.
	private void LayArc(int h, TranslationID tint, PlayerInfo p)
	{
		int n = arcX.Size();
		if (n < 2) { HideArc(h); return; }
		double total = 0;
		for (int i = 1; i < n; i++) total += (ArcAt(i) - ArcAt(i - 1)).Length();
		if (total < 1) { HideArc(h); return; }
		double size = RSQLS_Hand.Num("rsqls_arc_size", p, 1.0) * 0.022 * RSQLS_A11y.Cue();   // Cue Size
		double alpha = clamp(RSQLS_Hand.Num("rsqls_arc_a", p, 0.8), 0.0, 1.0);
		int seg = 1;
		double segStart = 0, segLen = (ArcAt(1) - ArcAt(0)).Length();
		for (int k = 0; k < ARC_N; k++)
		{
			int slot = h * ARC_N + k;
			arcDot[slot] = Ensure(arcDot[slot], "RSQLS_ArcDot");
			let d = arcDot[slot];
			if (!d) continue;
			double want = total * (k + 1) / (ARC_N + 1);
			while (seg < n - 1 && segStart + segLen < want)
			{
				segStart += segLen;
				seg++;
				segLen = (ArcAt(seg) - ArcAt(seg - 1)).Length();
			}
			double f = segLen > 0.001 ? clamp((want - segStart) / segLen, 0.0, 1.0) : 0.0;
			Vector3 at = ArcAt(seg - 1) + (ArcAt(seg) - ArcAt(seg - 1)) * f;
			Put(d, arcShown[h], at);
			d.Scale = (size, size);
			d.Alpha = alpha;
			d.Translation = tint;
		}
		arcShown[h] = true;
	}

	// THE BEAM ALONG THE ARC: the simulated path cut into equal segments (at most SEG_LEN map units, at most SEG_N), each
	// a thin crossed-quad rod (Scale.Y its length, Scale.X its thickness; pitch 90 turns the model's +Z onto the level,
	// then up or down by the segment's own climb).
	// CONTINUOUS (owner 2026-11-06: it drew as a dashed line): every segment reaches half a segment past both of its ends,
	// so each point of the path is covered by exactly two segments (one at the very start and end), at half the
	// brightness each: one even line with no gaps between segments.
	// LASER: QUEST / PC VR, the same look as the straight beam: Quest is the plain segment in the beam colour.
	// PC VR is the core (the colour pushed RSQLS_Beams.GLOW_WHITE toward white, brightness x GLOW_CORE) inside a halo
	// segment (RSQLS_ArcHalo, beam colour, brightness x GLOW_HALO, the halo rod's rings).
	private void LayArcBeam(int h, int rgb, double alpha, PlayerInfo p)
	{
		int n = arcX.Size();
		if (n < 2) { HideArcBeam(h); return; }
		Array<double> cum;
		cum.Push(0);
		for (int i = 1; i < n; i++) cum.Push(cum[i - 1] + (ArcAt(i) - ArcAt(i - 1)).Length());
		double total = cum[n - 1];
		if (total < 1) { HideArcBeam(h); return; }
		int segs = clamp(int(ceil(total / SEG_LEN)), 1, SEG_N);
		double step = total / segs;
		double thick = 0.5 * RSQLS_A11y.Cue();
		bool glow = RSQLS_Hand.Opt("rsqls_beam_type", p, 0) == 1;
		TranslationID coreTint, haloTint;
		double coreA, haloA;
		if (glow)
		{
			double wf = int(RSQLS_Beams.GLOW_WHITE * 16 + 0.5) / 16.0;
			int cr = int(((rgb >> 16) & 255) * (1 - wf) + 255 * wf);
			int cg = int(((rgb >> 8) & 255) * (1 - wf) + 255 * wf);
			int cb = int((rgb & 255) * (1 - wf) + 255 * wf);
			coreTint = RSQLS_Colors.Tint((cr << 16) | (cg << 8) | cb);
			coreA = clamp(alpha * RSQLS_Beams.GLOW_CORE, 0.0, 1.0);
			haloTint = RSQLS_Colors.Tint(rgb);
			haloA = clamp(alpha * RSQLS_Beams.GLOW_HALO, 0.0, 1.0);
		}
		else { coreTint = RSQLS_Colors.Tint(rgb); coreA = alpha; }
		for (int k = 0; k < SEG_N; k++)
		{
			int slot = h * SEG_N + k;
			if (k >= segs) { Hide(arcSeg[slot]); Hide(arcHalo[slot]); continue; }
			Vector3 from = PathAt(cum, max(0.0, step * (k - 0.5)));
			Vector3 to = PathAt(cum, min(total, step * (k + 1.5)));
			Vector3 d = to - from;
			double len = d.Length();
			double ang = VectorAngle(d.x, d.y);
			double pit = 90 - atan2(d.z, d.xy.Length());
			arcSeg[slot] = Ensure(arcSeg[slot], "RSQLS_ArcSeg");
			let a = arcSeg[slot];
			if (a)
			{
				Put(a, segShown[h] && !a.bINVISIBLE, from);
				a.Angle = ang;
				a.Pitch = pit;
				a.Scale = (thick, max(len, 0.01));
				a.Alpha = coreA * 0.5;
				a.Translation = coreTint;
			}
			if (!glow) { Hide(arcHalo[slot]); continue; }
			arcHalo[slot] = Ensure(arcHalo[slot], "RSQLS_ArcHalo");
			let o = arcHalo[slot];
			if (!o) continue;
			Put(o, segShown[h] && !o.bINVISIBLE, from);
			o.Angle = ang;
			o.Pitch = pit;
			o.Scale = (HALO_W * RSQLS_A11y.Cue(), max(len, 0.01));
			o.Alpha = haloA * 0.5;
			o.Translation = haloTint;
		}
		segShown[h] = true;
	}

	// The point `dist` map units along the arc's path (cum: the path's running length at each point).
	private Vector3 PathAt(Array<double> cum, double dist)
	{
		int n = cum.Size();
		for (int i = 1; i < n; i++)
		{
			if (cum[i] >= dist || i == n - 1)
			{
				double sl = cum[i] - cum[i - 1];
				double f = sl > 0.001 ? clamp((dist - cum[i - 1]) / sl, 0.0, 1.0) : 0.0;
				return ArcAt(i - 1) + (ArcAt(i) - ArcAt(i - 1)) * f;
			}
		}
		return ArcAt(0);
	}

	// The ring: the widest spread this gun has shown, drawn at the spot as an
	// ellipse (horizontal and vertical spread separately), facing the surface the
	// way the spot does. Not on an arc, and not before the gun has fired.
	private void LayRing(int h, Weapon w, PlayerInfo p, Vector3 at, double dist,
		bool wallS, bool flatS, double sAngle, bool arcOn, TranslationID tint, bool spotWasShown)
	{
		double sh, sv;
		[sh, sv] = RSQLS_Learn.Spread(w);
		double minDeg = RSQLS_Hand.Num("rsqls_spread_min", p, 0.75);
		if (arcOn || !RSQLS_Hand.Flag("rsqls_spread", p, false) || max(sh, sv) < minDeg)
		{
			Hide(ring[h]);
			return;
		}
		ring[h] = Ensure(ring[h], "RSQLS_Ring");
		let r = ring[h];
		if (!r) return;
		if (sv < minDeg) sv = sh;    // a purely sideways spread still draws a circle's height
		if (sh < minDeg) sh = sv;
		double rh = dist * tan(sh), rv = dist * tan(sv);
		r.bWALLSPRITE = wallS; r.bFLATSPRITE = flatS; r.Angle = sAngle;
		Vector3 rat = at;
		if (wallS) rat += (cos(sAngle), sin(sAngle), 0) * 0.2;
		else if (flatS) rat.z += 0.2;
		Put(r, spotWasShown && !r.bINVISIBLE, rat);
		r.Scale = (rh / RING_PX, rv / RING_PX);
		r.Alpha = clamp(RSQLS_Hand.Num("rsqls_spread_a", p, 0.6), 0.0, 1.0);
		r.Translation = tint;
	}

	// THE PACK'S OWN MUZZLE. A weapon pack (the WeaponDepot cards, say) can tell
	// the laser where each gun's barrel ends by providing a Service:
	//   class MyPackMuzzles : Service {
	//     override String GetString(String request, String stringArg, int intArg, ...)
	//     // request "laser.muzzle", stringArg = weapon class name, intArg = hand
	//     // -> "forward up side" in METRES from the grip, or "" for "don't know"
	//   }
	// Found by name (LaserMuzzleService in the class name), asked once per weapon
	// class and cached, so neither mod links against the other.
	private bool, double, double, double MuzzleFor(int h, Weapon w)
	{
		String k = w.GetClassName();
		if (k == mzKey[h]) return mzGot[h], mzF[h], mzU[h], mzS[h];
		mzKey[h] = k;
		mzGot[h] = false;
		let it = ServiceIterator.Find("LaserMuzzleService");
		Service sv;
		while (sv = it.Next())
		{
			String r = sv.GetString("laser.muzzle", k, h, 0, w);
			if (r == "") continue;
			Array<String> f;
			r.Split(f, " ", TOK_SKIPEMPTY);
			if (f.Size() < 3) continue;
			mzF[h] = f[0].ToDouble(); mzU[h] = f[1].ToDouble(); mzS[h] = f[2].ToDouble();
			mzGot[h] = true;
			break;
		}
		return mzGot[h], mzF[h], mzU[h], mzS[h];
	}

	// THE RANGE READOUT: the distance to what the main hand's laser is on (the off hand's when the main has none),
	// by the gun or over the spot, in the dot's colour. Glyphs, not a canvas (see RSQLS_ReadoutGlyph): each character
	// is a billboard laid out across the line from your eye, centred on where the old canvas screen was.
	// Sizes: a digit is READ_DIGIT_U map units tall at scale 1 (the old screen's text: SmallFont x2 on a 2-unit quad),
	// x Readout Size, x RSQ Accessibility's Text Size; At the Dot is sized to one apparent size (READ_DOT_DEG).
	const READ_DIGIT_U = 0.875;
	const READ_DOT_DEG = 1.1;    // At the Dot: a digit's apparent height in degrees at Readout Size 1 (constant with distance)
	const GLYPH_PX = 48.0;     // every glyph's canvas height (tools/gen_readout_glyphs.py)
	const DIGIT_PX = 33.0;     // a digit's ink height in it
	const READ_GAP = 0.30;     // the space before the unit, in digit heights
	const READ_CLEAR_M = 0.03; // By the Gun: the row's near edge this far past the drawn muzzle's line as seen, metres
	// how far right of the row's centre a point looks, as a slope (across over ahead) from the eye
	private static double ReadSeen(Vector2 d, Vector2 fwd, Vector2 right)
	{
		double ahead = max(d.x * fwd.x + d.y * fwd.y, 1.0);
		return (d.x * right.x + d.y * right.y) / ahead;
	}
	private void HideReadout()
	{
		if (!readShown) return;
		for (int i = 0; i < READ_N * READ_LAYERS; i++) if (readGlyph[i]) readGlyph[i].bINVISIBLE = true;
		readShown = false;
	}
	private void UpdateReadout(PlayerPawn pmo, PlayerInfo p)
	{
		int mode = RSQLS_Hand.Opt("rsqls_readout", p, 0);
		int h = (rangeM[0] > 0) ? 0 : 1;
		if (mode <= 0 || rangeM[h] <= 0 || pmo.Health <= 0)
		{
			HideReadout();
			readM = 0; readTxt = "";
			return;
		}
		readM = rangeM[h];
		readU = rangeU[h];
		readRgb = rangeRgb[h];
		int units = RSQLS_Hand.Opt("rsqls_readout_units", p, 0);
		String num, unit;
		if (units == 1) { num = String.Format("%.0f", readM * 3.28084); unit = "ft"; }
		else if (units == 2) { num = String.Format("%.0f", readU); unit = "u"; }   // the trace's own map units (11-10: room metres x 34 read short on steep shots)
		else { num = readM < 10 ? String.Format("%.1f", readM) : String.Format("%.0f", readM); unit = "m"; }
		readTxt = num .. " " .. unit;

		if (!readTexFound)
		{
			readTexFound = true;
			String cs = "0123456789.mftu";
			for (int i = 0; i < int(cs.Length()); i++)
			{
				int c = cs.ByteAt(i);
				readTex[c] = TexMan.CheckForTexture(String.Format("RSLN%03d", c), TexMan.Type_Any);
			}
		}

		// where: as the old screen (By the Gun: 8 cm up the barrel and 9 cm over the grip; At the Dot: 4 units + 0.6 a
		// metre over the dot, x1 to x8 with the distance), with two fixes the rig asked for (11-10, LS_READOUT_*):
		bool atDot = mode == 2 && spot[h] && !spot[h].bINVISIBLE;
		// At the Dot keeps ONE APPARENT SIZE however far the dot is (owner 11-10: "Constant size with distance"): a digit
		// READ_DOT_DEG tall as seen from your eye (Readout Size 1), never smaller than the old size up close. The old
		// x1-x8 factor left it ~0.37 deg past 4 m, a few pixels (rig 11-10, LS_READOUT_*); size 3 (~1.1 deg) read well.
		double sc = 1.0;
		if (atDot)
		{
			double eyeDist = (spot[h].pos - (pmo.pos.x, pmo.pos.y, p.viewz)).Length();
			sc = max(1.0, eyeDist * tan(READ_DOT_DEG) / READ_DIGIT_U);
		}
		sc *= RSQLS_Hand.Num("rsqls_readout_size", p, 1.0) * RSQLS_A11y.Text();   // RSQ_Accessibility's Text Size
		double ps = RSQLS_Hand.Ps();
		double digitU = READ_DIGIT_U * sc;
		double pxU = digitU / DIGIT_PX;             // map units a glyph pixel
		Vector3 eye = (pmo.pos.x, pmo.pos.y, p.viewz);
		Vector3 at;
		if (atDot)
		{
			// pulled a little toward your eye so a wall's face never cuts it, and when the dot is on a ceiling (a steep
			// shot: over the dot was inside the ceiling, never seen) it goes UNDER the dot instead
			Vector3 onDot = spot[h].pos;
			Vector3 te = eye - onDot;
			double tl = te.Length();
			if (tl > 0.01) onDot += te * (min(2.0 + tl * 0.02, tl * 0.5) / tl);
			double lift = 4 + rangeM[h] * 0.6;
			at = onDot + (0, 0, lift + digitU * 0.6 / ps);
			let sec = level.PointInSector(at.xy);
			if (sec && at.z + digitU / ps > sec.ceilingplane.ZatPoint(at.xy))
			{
				at = onDot - (0, 0, lift + digitU * 0.6 / ps);
				double fl = sec.floorplane.ZatPoint(at.xy);
				if (at.z - digitU / ps < fl) at.z = fl + digitU / ps;
			}
		}
		else
			at = RSQLS_Hand.Grip(pmo, h) + RSQLS_Hand.GunOffset(pmo, h, 0.08, 0.09, 0.0) + (0, 0, digitU * 0.6 / ps);
		// across your line of sight, as Score's wrist does
		Vector2 v = at.xy - pmo.pos.xy;
		double vl = v.Length();
		Vector2 right = vl > 0.5 ? (v.y, -v.x) / vl : (sin(pmo.angle), -cos(pmo.angle));

		// the row: each glyph its own width, the space a gap; centred
		int n = 0;
		double wsum = 0;
		int codes[READ_N];
		double wid[READ_N];
		bool gapBefore[READ_N];
		bool gap = false;
		for (int i = 0; i < int(readTxt.Length()) && n < READ_N; i++)
		{
			int c = readTxt.ByteAt(i);
			if (c == 32) { gap = true; continue; }
			if (c < 0 || c >= 128 || !readTex[c].IsValid()) continue;
			Vector2 sz = TexMan.GetScaledSize(readTex[c]);
			codes[n] = c; wid[n] = sz.x * pxU; gapBefore[n] = gap; gap = false;
			wsum += wid[n] + (gapBefore[n] ? READ_GAP * digitU : 0);
			n++;
		}
		bool was = readShown;
		double x = -wsum * 0.5;
		// By the Gun the row starts beside the gun, on the hand's outer side, not across it (rig 11-10: held up, the
		// gun hid the first digit when the row was centred on the old spot): its near edge READ_CLEAR_M past the gun as
		// you see it, the gun's muzzle taken through your eye onto the row's own depth
		if (!atDot)
		{
			Vector2 fwd = vl > 0.5 ? v / vl : (cos(pmo.angle), sin(pmo.angle));
			Vector2 e2 = eye.xy;
			Vector3 grip = RSQLS_Hand.Grip(pmo, h);
			double depth = max((at.x - e2.x) * fwd.x + (at.y - e2.y) * fwd.y, 1.0);
			double outer = ((grip.x - e2.x) * right.x + (grip.y - e2.y) * right.y) >= 0 ? 1.0 : -1.0;
			// the drawn beam's start is the drawn gun's muzzle (beam.zs); the grip is the controller, which BD22 VR's
			// guns are drawn beside (rig 11-10: 5 cm off as seen), so it stands in only with no beam
			Vector2 gunAt = ((beamMask >> h) & 1) ? lineAt[h].xy : grip.xy;
			double edge = outer * ReadSeen(gunAt - e2, fwd, right) * depth;
			edge += READ_CLEAR_M * RSQLS_Hand.Upm();
			x = outer > 0 ? edge : -edge - wsum;
		}
		for (int g = 0; g < READ_N; g++)
		{
			double cx = 0;
			if (g < n)
			{
				if (gapBefore[g]) x += READ_GAP * digitU;
				cx = x + wid[g] * 0.5;
				x += wid[g];
			}
			for (int l = 0; l < READ_LAYERS; l++)
			{
				int k = g * READ_LAYERS + l;
				let q = readGlyph[k];
				if (g >= n) { if (q) q.bINVISIBLE = true; continue; }
				Vector3 pos = at + (right.x * cx, right.y * cx, 0);
				if (!q)
				{
					q = Actor.Spawn("RSQLS_ReadoutGlyph", pos, NO_REPLACE);
					readGlyph[k] = q;
					if (!q) continue;
					q.A_SetRenderStyle(1.0, STYLE_AddShaded);
				}
				Put(q, was && !q.bINVISIBLE, pos);
				q.picnum = readTex[codes[g]];
				q.Scale = (pxU, pxU / ps);           // the font's own shape: undo the world's 1.2 vertical stretch
				q.SetShade(readRgb);
				q.bINVISIBLE = false;
			}
		}
		readShown = n > 0;
	}

	override void WorldUnloaded(WorldEvent e)
	{
		for (int h = 0; h < 2; h++)
		{
			arcShown[h] = false; segShown[h] = false;
			beamShown[h] = false; spotShown[h] = false; lightOn[h] = false;
			muzzlePrimed[h] = false; hitPrimed[h] = false;
		}
	}
}

// WHAT THE LASER IS DOING, FOR ANY MOD THAT ASKS -- found by name, so a mod that
// asks never links against this one and an absent laser is simply no answer.
//   GetInt("laser.active", "", hand)  -> 1 if a laser (beam or dot) drew on that
//                                        hand (0 main, 1 off) last tic, else 0
//   GetInt("laser.beam", "", hand)    -> the same for the beam alone
//   GetDouble("laser.line", "x"|"y"|"z"|"dx"|"dy"|"dz", hand) -> the line that hand's beam was drawn on last tic
//                                        (muzzle in map units, unit barrel direction); 0 when no beam drew there.
//                                        Meant for RSQ Wheel's card pick (owner 11-05); Wheel does not read it yet.
// RSQ_DistanceGrab asks this so its grab beam stands down on a hand the laser
// already lights.
class RSQLS_SightService : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "laser.active")
			return (RSQLS_Sight.LiveHands() >> (intArg & 1)) & 1;
		if (request == "laser.beam")
			return (RSQLS_Sight.BeamHands() >> (intArg & 1)) & 1;
		// "head.on", objectArg = a monster: 1 when a dot of the console player sat on its head this tic or the last AND
		// they have Gun Bonsai VR's Headshot Reaction 2 (its Headshot node counts a gun hit there)
		if (request == "head.on")
			return RSQLS_Sight.HeadOn(Actor(objectArg));
		return -1;
	}

	override double GetDouble(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request != "laser.line") return 0;
		bool got; Vector3 at, dir;
		[got, at, dir] = RSQLS_Sight.BeamLine(intArg);
		if (!got) return 0;
		if (stringArg == "x") return at.x;
		if (stringArg == "y") return at.y;
		if (stringArg == "z") return at.z;
		if (stringArg == "dx") return dir.x;
		if (stringArg == "dy") return dir.y;
		if (stringArg == "dz") return dir.z;
		return 0;
	}

	// THE MENU (ui): GetIntUI("menu.locked", "TargetLock" | "TargetColour" | "Headshot") -> 1 while the Gun Bonsai VR
	// patch rules that row (gbOn: the patch AND RSQ Tactical Rig, which offers the nodes; GbRefresh) and the console player
	// has not learned it: Target Lock 1, Target Lock 2, Headshot Reaction 1 (Lock / Recolor / Head above). Else 0.
	// Not in a game: 1 when the patch and the Rig are loaded (nothing is learned yet), else 0.
	// GetIntUI("menu.gated") -> 1 when this load gates any row (the patch AND the Rig), else 0: the page's GbLine shows
	// only then (owner 11-04: with the patch but no Rig nothing here is gated, so no line).
	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request ~== "menu.gated")
			return (ServiceIterator.Find("RSQ_MeleeUpgradeService").Next() && ServiceIterator.Find("RSQTR_RigService").Next()) ? 1 : 0;
		if (!(request ~== "menu.locked")) return -1;
		if (!ServiceIterator.Find("RSQ_MeleeUpgradeService").Next() || !ServiceIterator.Find("RSQTR_RigService").Next()) return 0;
		let me = RSQLS_Sight(EventHandler.Find("RSQLS_Sight"));
		if (gamestate != GS_LEVEL || !me) return 1;
		if (!me.gbOn) return 0;
		if (stringArg ~== "TargetLock") return me.gbLock < 1 ? 1 : 0;
		if (stringArg ~== "TargetColour") return me.gbLock < 2 ? 1 : 0;
		if (stringArg ~== "Headshot") return me.gbHead < 1 ? 1 : 0;
		return 0;
	}
}
