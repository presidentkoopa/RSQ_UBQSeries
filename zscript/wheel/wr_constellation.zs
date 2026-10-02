// THE STAR CHART.
//
// Your arsenal drawn the way a chart draws a sky: every weapon is a named
// five-pointed star, every slot is a constellation with its own colour and its
// own cloud of coloured dust, and thin lines run from each star to the ones it
// belongs with.
//
// IT DRAWS ITSELF, STARTING FROM WHAT YOU ARE HOLDING. The gun in your hands
// lights first, lines drop from it to its variants, then a line reaches across
// to the next slot and that constellation builds in turn. The reveal is the
// only moment the chart gets to explain itself, and it explains best by
// starting somewhere the player already is.
//
// WHY THIS EXISTS ALONGSIDE THE RING. The ring is an arc, and an arc runs out
// of arc length -- that is why sub-cards, fans, wr_subcards_max and the whole
// crowding apparatus exist at all. A volume does not run out. A fifty-weapon
// arsenal is a bigger sky, not a more crowded one, so the chart needs none of
// that machinery and does not have it.
//
// WHAT IT IS MADE OF.
//
//   stars    BB_SDFSTAR, a payload written for this. A star POLYGON, hollow
//            with a stroke for the named ones and solid for the dust, so the
//            whole chart is one shape at three sizes.
//   labels   BB_TEXT, centred INSIDE its star. That is the entire reason the
//            star had to be a glyph with a middle rather than a point of
//            light: a point of light has nowhere to write.
//   links    the volumetric beams. This is the best use that feature has had
//            here -- the lines between stars ARE lasers, and each one grows
//            from its parent toward its child rather than appearing whole.
//
// THINGS THIS DELIBERATELY DOES NOT HAVE, having tried them: a horizontal
// reference ring on the floor, drop lines from every star down to it, a bloom
// disc behind each star, and a spinning selection reticle. Every one of them
// was borrowed from a different kind of diagram, and together they buried the
// thing they were supposed to clarify. A chart is stars, names and lines.
//
// NOTHING IS FROZEN HERE. Stopping the world while the chart is up is the
// caller's business, not this file's.

class wr_Constellation : EventHandler
{
	// ---- tuning ----------------------------------------------------------

	// How far the nearest and furthest clusters sit. Real separation, not a
	// dome: the spread between these two numbers IS the parallax.
	// FURTHER OUT THAN ARM'S LENGTH. 46 put the nearest constellation about a
	// metre and a third from your face, which reads as a thing shoved at you
	// rather than a sky you are standing under.
	const NEAR_R      = 68.0;
	const FAR_R       = 165.0;

	// Half-width of the arc the clusters occupy, in degrees either side of
	// where you were facing when it opened. Wide enough to surround, short of
	// putting a weapon directly behind you.
	const ARC_HALF    = 115.0;

	// How far above and below eye level clusters may sit.
	const RISE_HI     = 34.0;
	const RISE_LO     = -22.0;

	// A main star, and one of its variants -- QUAD sizes, not drawn sizes.
	//
	// BB_SDFSTAR draws its star at 58% of the quad and leaves the rest
	// transparent for the halo to fall off in, so these are about 1.7x the
	// star you actually see. Fitting the shape to the quad instead is what cut
	// the glow off square and put every star in a faint rectangle.
	const STAR_MAIN   = 11.6;
	const STAR_SUB    = 7.6;

	// Stroke widths, 0-15, where 0 would mean a solid star. The named stars
	// are hollow because their names go inside them.
	const STROKE_MAIN = 3;
	const STROKE_SUB  = 2;

	// Five points, because that is what a star has when someone draws one.
	const POINTS      = 5;

	// ---- the dust --------------------------------------------------------
	//
	// EVERY CONSTELLATION BRINGS ITS OWN, in its own colour, and that is what
	// makes a slot read as a region of sky rather than as three shapes sitting
	// near each other. It arrives WITH its cluster, so the chart thickens as
	// it draws instead of opening onto a finished sky.
	//
	// They are the same star polygon as everything else, small -- some solid,
	// some hollow, mixed by hash. One shape at three sizes is what makes the
	// whole thing look drawn by one hand.
	const DUST_PER    = 30;
	const DUST_SPREAD = 26.0;   // degrees of sky around the cluster centre
	const DUST_MIN    = 0.9;
	const DUST_MAX    = 3.2;
	const DUST_LO     = 0.30;   // dimmest a speck may be
	const DUST_HI     = 0.85;

	// THE REVEAL, in tics. The chart draws itself cluster by cluster: the main
	// star, then its variants, then the link out to the next cluster.
	const T_MAIN      = 4;    // main star pops
	const T_SUB       = 3;    // each variant after it
	const T_LINK      = 5;    // the reach to the next cluster

	// ---- naming ----------------------------------------------------------
	//
	// THE NAME SITS OUTSIDE THE STAR, on a leader line, which is how a chart
	// has always done it. Text inside a five-pointed star is fighting the
	// shape: the interior pentagon is small, so the type has to be tiny, and
	// the arms cut across it. Short names just fit; SUPER SHOTGUN never would.
	//
	// LEADERS POINT AWAY FROM THE CLUSTER'S CENTRE, and that rule is doing
	// real work. On paper a leader can go anywhere, because there is one
	// viewing angle. This chart wraps a hundred and fifteen degrees either
	// side of you with real depth, so a leader aimed by eye at build time lies
	// across three other stars as soon as you turn your head. Pushing every
	// label radially outward from its own constellation's middle is computed
	// in the chart's own space, so it holds from EVERY angle: the labels are
	// always on the outside of the crowd, never through it.
	const LABEL_OUT   = 9.0;    // degrees of sky from star to label
	const LABEL_H     = 2.3;    // text height, in world units, size-independent
	const LABEL_ASPECT = 0.62;  // width per character, as a fraction of height
	const LEAD_THICK  = 0.045;
	const LEAD_ALPHA  = 0.40;

	// The cluster's own title, set large and dim BEHIND its stars. It answers
	// "what am I looking at" before a single weapon name has been read, which
	// is the one thing the ring gives away free with its slot numbers and the
	// chart otherwise does not.
	//
	// In the cluster's colour rather than grey: grey on black does not read,
	// and the colour reinforces the coding that is already doing the work.
	const TITLE_H     = 7.0;
	const TITLE_BACK  = 1.30;   // pushed this much further out than its stars
	const TITLE_ALPHA = 0.22;

	// Selection: how long a star stays lit after the pointer leaves it, so a
	// shaky hand does not strobe the whole sky.
	const HOVER_GRACE = 6;

	// How long a star takes to finish arriving once its turn comes.
	const RISE        = 7.0;

	// Scintillation. Every speck breathes on its own hashed phase and its own
	// hashed rate -- shared ones would read as a single pulse, which is a
	// heartbeat and not a sky. Small: the eye catches motion far below the
	// threshold where it catches brightness.
	const TWINKLE     = 0.16;

	// How hard a star glows. This is SetBillboardGlow's STRENGTH, and it is
	// not decoration -- in BB_SDFSTAR it gates both the halo and the emissive
	// push past 1.0 that lets the bloom pass see the star at all. At zero a
	// star draws as a flat outline, which is what the first version of this
	// file did to every star in the sky.
	const GLOW_MAIN   = 0.85;
	const GLOW_SUB    = 0.55;
	const GLOW_DUST   = 0.25;
	const GLOW_REACH  = 0.55;

	// ---- reaching --------------------------------------------------------
	//
	// YOU CAN STILL PHYSICALLY MOVE WITH THE WORLD FROZEN, so you should be
	// able to put your hand on a star. The ring solves the same problem with a
	// fixed fingertip extension, and that answer does not carry: its cards all
	// sit at one distance, so one frozen offset parks the fingertip just short
	// of all of them. A sky does not have one distance -- these stars are
	// spread from forty-six units to a hundred and twenty, deliberately,
	// because the spread IS the parallax.
	//
	// So the extension is EARNED rather than fixed. This is go-go: inside a
	// dead zone the fingertip is exactly your hand and nothing is changed, and
	// past it the virtual reach grows with the SQUARE of how far you have
	// actually pushed. A small deliberate extension therefore travels a long
	// way out, while ordinary hand movement near your body does not move the
	// fingertip at all -- which is the property that stops this from firing
	// while you are simply holding the controller.
	//
	// Measured from the EYE, along the eye-to-hand line, and both halves of
	// that matter. Live eye rather than the frozen origin, so leaning your
	// whole body toward a constellation reaches it. And the eye-to-hand line
	// rather than the hand's own forward axis, because reaching into a volume
	// is done with the ARM: you put your arm toward the star and push along
	// it, a gesture the body already knows that needs no wrist aiming.
	const GOGO_DEAD   = 3.0;    // units past rest before anything happens
	const GOGO_K      = 0.42;   // how hard the square bites
	const GOGO_MAX    = 1.32;   // ceiling, as a multiple of FAR_R

	// The grab sphere at the fingertip. It GROWS WITH DISTANCE, because a fixed
	// radius that feels right against a near cluster subtends almost nothing
	// against a far one -- the far stars would be technically reachable and
	// practically impossible.
	const TIP_R       = 7.0;
	const TIP_R_FAR   = 13.0;

	// The fingertip is DRAWN, and unlike the ring's this is not optional. On a
	// ring the card is an arm's length in front of your face, so the card
	// lighting up is feedback enough. Out here the fingertip is thirty metres
	// away in a volume; with nothing rendered you would be reaching blind into
	// a sky and guessing. A small solid star, the same glyph as everything
	// else, so it reads as part of the chart rather than as a cursor bolted on.
	const TIP_SIZE    = 2.2;

	// ---- walls -----------------------------------------------------------
	//
	// BBFL_NODEPTH ON EVERYTHING, and it is the whole answer.
	//
	// The problem is real: a layout that renders into geometry is invisible AND
	// still selectable, because nothing in the pointing path knows geometry
	// exists -- AimBillboard, TouchBillboard and stickPick all pass straight
	// through it. You end up pointing a clamped laser at a star behind a door
	// and committing to it blind.
	//
	// The first attempt traced at build and pulled each cluster in to fit the
	// room. It worked, and it was WRONG: a Doom room is often two hundred units
	// across and this chart wants to stand at a hundred and twenty, so the
	// clamp crushed the sky into a closet and took every bit of the depth and
	// spread the layout exists for with it.
	//
	// The mismatch was never that the PLACEMENT disobeyed walls. It was that
	// the DRAWING obeyed them while the pointing did not. A chart is a menu
	// that happens to occupy a volume, not an object in the room -- so it draws
	// over geometry, the two halves agree again, and it stands as far out as it
	// likes. wr_gunhud.zs uses the flag for the on-gun readout for the same
	// reason.
	//
	// The beams are the one exception, and they have no choice: SetBeam has no
	// depth flag. The links between stars and the leaders out to the names will
	// still be cut by a wall. They are the least load-bearing thing here -- the
	// stars, the names and the titles all draw through.

	// Beam slots 0 and 1 belong to RS_GrabViz, which says so in its own header
	// and sets the count to 2 every tic. This handler runs after it in the
	// MAPINFO order, so raising the count here is what makes the rest exist.
	const BEAM_BASE   = 2;
	const BEAM_MAX    = 96;

	// ---- state -----------------------------------------------------------

	private bool     mOpen;
	private int      mTics;          // tics since open, drives the reveal

	// One entry per named star, main and variant alike.
	private Array<int>     mStarIds;
	private Array<int>     mStarHits;    // its invisible, forgiving target
	private Array<int>     mStarLabels;
	private Array<Class<Weapon> > mStarTypes;
	private Array<int>     mStarCluster; // which constellation it belongs to
	private Array<bool>    mStarMain;
	private Array<int>     mStarBornAt;  // tic in the reveal when it appears
	// THREE ARRAYS, NOT ONE. A ZScript dynamic array's base type has to be
	// integral, so Array<Vector3> does not compile -- the ring solves the same
	// problem the same way with mSubX/mSubY/mSubZ.
	private Array<double>  mStarX;
	private Array<double>  mStarY;
	private Array<double>  mStarZ;
	private Array<double>  mStarSize;
	private Array<int>     mStarTint;
	// Where each star's label sits. Stored rather than derived per tic because
	// it is fixed for the chart's life and the leader beam needs it too.
	private Array<double>  mLabX;
	private Array<double>  mLabY;
	private Array<double>  mLabZ;

	// One title per constellation.
	private Array<int>     mTitleIds;
	private Array<int>     mTitleBornAt;

	// One entry per link: two star indices and when the line is drawn.
	private Array<int>     mLinkA;
	private Array<int>     mLinkB;
	private Array<int>     mLinkBornAt;
	private Array<int>     mLinkTint;

	// The dust. Its resting brightness is remembered rather than recomputed,
	// because the only per-tic work a few hundred specks deserve is a shimmer.
	private Array<int>     mDustIds;
	private Array<double>  mDustAlpha;
	private Array<int>     mDustBornAt;

	private int      mHovered;
	private int      mHoverGrace;

	// WHICH HAND OPENED IT. The ring has worn this since it was written --
	// the hand that raises the layout is the hand that points at it -- and
	// the chart was pointing with pmo.AttackPos regardless, which is the
	// MAIN hand. Opened on the off hand, the beam came out of one hand and
	// the picking happened along the other.
	private int      mHand;

	// Where the ray last landed, so the engine laser can be told to stop
	// there rather than carrying on through the star to the wall behind.
	private double   mReach;

	// The fingertip: how far the hand sat from the eye when the chart opened
	// (the dead zone is measured from this), and the billboard that shows it.
	private double   mRestReach;
	private int      mTipId;
	private bool     mReaching;

	// Where the chart was anchored when it opened. Everything is placed
	// relative to this, and it does NOT follow the player afterwards -- a sky
	// that turns with your head is a HUD, not a place.
	private Vector3  mOrigin;
	private double   mOriginYaw;

	// ---- palette ---------------------------------------------------------

	// One hue per constellation, walked in order. Deliberately not random:
	// the first slot is always this blue, so the sky is the same sky every
	// time and you can learn where things are.
	private static color clusterTint(int i)
	{
		switch (i % 8)
		{
		case 0: return 0x39B7F0;   // ice blue      -- melee
		case 1: return 0xA98BD8;   // violet        -- sidearms
		case 2: return 0xF07AA8;   // rose          -- shotguns
		case 3: return 0x6FD98A;   // green         -- rapid fire
		case 4: return 0xF0C04A;   // amber         -- heavy
		case 5: return 0x59D8CF;   // teal          -- energy
		case 6: return 0xE8794A;   // ember         -- explosive
		default: return 0xB8C4E0;  // pale steel    -- everything after
		}
	}

	// THE CONVENTIONAL DOOM SLOT MEANINGS, which is an assumption and worth
	// saying so: the palette above already makes exactly the same one in its
	// comments, so the two are at least consistent. A mod that reorders its
	// slots will get a title that is wrong -- which is a smaller failure than
	// having no title at all, and it is one line to change.
	private static string clusterName(int i)
	{
		switch (i % 8)
		{
		case 0: return "MELEE";
		case 1: return "SIDEARMS";
		case 2: return "SHOTGUNS";
		case 3: return "RAPID FIRE";
		case 4: return "HEAVY";
		case 5: return "ENERGY";
		case 6: return "EXPLOSIVE";
		default: return "ORDNANCE";
		}
	}

	// A relative of a cluster's colour, for the dust around it. Kept CLOSE to
	// the original rather than dimmed hard: the dust is what identifies the
	// region, so washing it out to grey defeats the point of having it. The
	// variation is what stops thirty specks reading as one flat wash.
	private static color dustTint(color c, int n)
	{
		double m = 0.62 + hash01(n, 71) * 0.55;
		int r = int(((c >> 16) & 0xFF) * m); if (r > 255) r = 255;
		int g = int(((c >>  8) & 0xFF) * m); if (g > 255) g = 255;
		int b = int(( c        & 0xFF) * m); if (b > 255) b = 255;
		return Color(255, r, g, b);
	}

	// ---- deterministic scatter -------------------------------------------

	// The sky has to be the SAME SKY every time it opens, or there is nothing
	// to learn and no muscle memory to build. So no random(): a cheap hash of
	// the index, which gives a scattered-looking but fixed answer.
	private static double hash01(int n, int salt)
	{
		double x = double(n) * 12.9898 + double(salt) * 78.233;
		double s = sin(x * 57.29577951) * 43758.5453;
		return s - floor(s);
	}

	// ---- helpers ---------------------------------------------------------

	private static double cv(string n, double d)
	{
		let c = CVar.GetCVar(n, players[consoleplayer]);
		return c ? c.GetFloat() : d;
	}

	static wr_Constellation Get()
	{
		return wr_Constellation(EventHandler.Find("wr_Constellation"));
	}

	// STROKE OR FILL IS THE HIERARCHY, not size and not colour -- size is
	// something parallax is busy changing, and colour already means the slot.
	// A hollow star is a place you can go and has a name written in it; a
	// solid one is dust. shape packs the point count in the high byte and the
	// stroke in the low, with a stroke of 0 meaning filled.
	private int makeStar(color tint, bool hittable, int points, int stroke)
	{
		// BBF_CAMERA, not a yaw refreshed every tic from the player's BODY
		// angle. In a headset those are different numbers -- you turn your head
		// without turning your body constantly -- so a body-yawed star field
		// shears the moment you look around it, which is the exact moment the
		// chart is supposed to be holding still.
		int id = level.AddBillboardPersistent(
			(0, 0, 0), 1.0, 1.0, 0, 0,
			LevelLocals.BBF_CAMERA, LevelLocals.BB_SDFSTAR,
			(stroke & 15) | ((points & 15) << 8),
			tint,
			LevelLocals.BBFL_NODEPTH | (hittable ? 0 : LevelLocals.BBFL_NOHIT),
			0, "");
		level.SetBillboardAlpha(id, 0.0);
		return id;
	}

	// ---- opening ---------------------------------------------------------

	void Toggle(int hand = 0)
	{
		if (mOpen) { Close(); return; }
		Open(hand);
	}

	// Answers whether there is anything to point AT. An empty arsenal builds
	// no stars, and the caller must not claim the sticks and the laser for a
	// sky with nothing in it -- there would be no card to press to get out.
	bool IsOpen() const
	{
		return mOpen && mStarIds.Size() > 0;
	}

	void Open(int hand = 0)
	{
		let pmo = players[consoleplayer].mo;
		if (!pmo || !pmo.player) return;

		Close();

		mOrigin    = pmo.Pos + (0, 0, pmo.player.viewheight);
		mOriginYaw = pmo.angle;
		mTics      = 0;
		mHovered   = 0;
		mHand      = hand;
		mReach     = 0.0;
		mReaching  = false;
		mOpen      = true;

		// REST IS WHEREVER YOU HAPPENED TO BE, not a constant. A player with
		// their arm already half out when they open the chart has not thereby
		// spent their reach; the dead zone is measured from the pose that
		// opened it.
		Vector3 eye0 = pmo.Pos + (0, 0, pmo.player.viewheight);
		mRestReach = (wr_Rig.handPos(pmo, hand) - eye0).Length();
		if (mRestReach < 1.0) mRestReach = 1.0;

		mTipId = level.AddBillboardPersistent(
			(0, 0, 0), TIP_SIZE, TIP_SIZE, 0, 0,
			LevelLocals.BBF_CAMERA, LevelLocals.BB_SDFSTAR,
			(0 & 15) | ((POINTS & 15) << 8),
			0xFFFFFF, LevelLocals.BBFL_NODEPTH | LevelLocals.BBFL_NOHIT, 0, "");
		level.SetBillboardAlpha(mTipId, 0.0);
		level.SetBillboardGlow(mTipId, GLOW_REACH, 1.0);

		buildClusters(pmo);

		// Nothing owned, nothing drawn. Fold immediately rather than sitting
		// open and empty; IsOpen() is what tells the caller not to proceed.
		if (mStarIds.Size() == 0) { mOpen = false; return; }
	}

	void Close()
	{
		for (int i = 0; i < mStarIds.Size(); ++i)
		{
			if (mStarIds[i])    level.RemoveBillboard(mStarIds[i]);
			if (mStarHits[i])   level.RemoveBillboard(mStarHits[i]);
			if (mStarLabels[i]) level.RemoveBillboard(mStarLabels[i]);
		}
		for (int i = 0; i < mDustIds.Size(); ++i)
			if (mDustIds[i]) level.RemoveBillboard(mDustIds[i]);
		for (int i = 0; i < mTitleIds.Size(); ++i)
			if (mTitleIds[i]) level.RemoveBillboard(mTitleIds[i]);
		if (mTipId) { level.RemoveBillboard(mTipId); mTipId = 0; }

		// Put our beam slots away without lowering the count -- that is
		// level-wide and would take RS_GrabViz's two with it.
		for (int i = 0; i < BEAM_MAX; ++i)
			level.SetBeam(BEAM_BASE + i, (0,0,0), (0,0,0), 0, 0, 0x000000, 0);

		mStarIds.Clear();    mStarHits.Clear();   mStarLabels.Clear();
		mStarTypes.Clear();  mStarCluster.Clear();
		mStarMain.Clear();   mStarBornAt.Clear();
		mStarSize.Clear();   mStarTint.Clear();
		mStarX.Clear();      mStarY.Clear();      mStarZ.Clear();
		mLabX.Clear();       mLabY.Clear();       mLabZ.Clear();
		mTitleIds.Clear();   mTitleBornAt.Clear();
		mLinkA.Clear();      mLinkB.Clear();      mLinkBornAt.Clear();
		mLinkTint.Clear();
		mDustIds.Clear();    mDustAlpha.Clear();  mDustBornAt.Clear();

		mOpen    = false;
		mHovered = 0;
	}

	// Azimuth is measured from where you faced on open, elevation from eye
	// level, radius outward. The chart is placed once and stays put.
	private Vector3 pointAt(double az, double el, double rad)
	{
		double yaw = mOriginYaw + az;
		double ch  = cos(el);
		return mOrigin + (cos(yaw) * ch * rad,
		                  sin(yaw) * ch * rad,
		                  sin(el) * rad);
	}

	// ---- the dust --------------------------------------------------------

	// Scattered around one cluster, in that cluster's colour, born when it is.
	// Some solid, some hollow, mixed by hash -- a field where every speck is
	// identical reads as a texture, and a texture is not a sky.
	private void addDust(double az, double el, double rad, color tint,
	                     int salt, int bornAt)
	{
		for (int i = 0; i < DUST_PER; ++i)
		{
			int n = salt * 512 + i;

			double daz = az  + (hash01(n, 31) * 2.0 - 1.0) * DUST_SPREAD;
			double del = el  + (hash01(n, 32) * 2.0 - 1.0) * DUST_SPREAD * 0.7;
			double dr  = rad * (0.70 + hash01(n, 33) * 0.65);
			double sz  = DUST_MIN + hash01(n, 34) * (DUST_MAX - DUST_MIN);

			// Roughly two in five are hollow. Enough that the outline reads as
			// a deliberate second kind rather than as an artefact.
			int stroke = (hash01(n, 35) < 0.4) ? 1 : 0;

			int id = makeStar(dustTint(tint, n), false, POINTS, stroke);
			level.ResizeBillboard(id, sz, sz);
			level.MoveBillboard(id, pointAt(daz, del, dr));
			level.SetBillboardGlow(id, GLOW_REACH, GLOW_DUST);
			level.SetBillboardAlpha(id, 0.0);

			mDustIds.Push(id);
			mDustAlpha.Push(DUST_LO + hash01(n, 36) * (DUST_HI - DUST_LO));
			mDustBornAt.Push(bornAt);
		}
	}

	// ---- filling the sky -------------------------------------------------

	// WHICH SLOT THE THING IN YOUR HANDS BELONGS TO, or 1 if that cannot be
	// answered. Used to decide where the chart starts drawing itself.
	private static int heldSlot(PlayerPawn pmo)
	{
		if (!pmo || !pmo.player) return 1;
		let w = pmo.player.ReadyWeapon;
		if (!w) return 1;

		let wp = pmo.player.weapons;
		if (!wp) return 1;

		for (int slot = 1; slot <= 10; ++slot)
		{
			int n = wp.SlotSize(slot);
			for (int i = 0; i < n; ++i)
				if (wp.GetWeapon(slot, i) == w.GetClass()) return slot;
		}
		return 1;
	}

	private void buildClusters(PlayerPawn pmo)
	{
		// IT STARTS FROM WHAT YOU ARE HOLDING, and that is not decoration.
		//
		// The reveal is the only moment the chart gets to explain itself, and
		// it explains best by starting somewhere the player already is: the
		// gun in their hands lights first, its variants shoot off it, and the
		// line then reaches to the next slot. Every constellation after that
		// is read as a distance FROM there, which is the thing a player
		// actually wants to know.
		//
		// Slot order is otherwise preserved, wrapped: holding slot 4 gives
		// 4, 5, 6 ... 10, 1, 2, 3. The arsenal keeps the shape the number keys
		// taught, rotated to put you at the front of it.
		int first = heldSlot(pmo);

		// COUNT FIRST, THEN SPREAD. The arc below divides ARC_HALF by this, and
		// it used to divide by a hardcoded 8 -- so the layout only ever filled
		// the whole arc if you happened to own weapons in eight slots. With
		// three, frac ran 0.06 / 0.19 / 0.31 and the clusters landed at -101,
		// -72 and -43 degrees: the entire chart bunched into the right-hand
		// quarter of the sky, ninety degrees off the way you were facing, with
		// the other three quarters empty.
		int total = 0;
		for (int probe = 0; probe < 10; ++probe)
		{
			int ps = first + probe;
			while (ps > 10) ps -= 10;

			Array<Class<Weapon> > have;
			gatherSlot(pmo, ps, have);
			if (have.Size() > 0) ++total;
		}
		if (total < 1) return;

		int born = 0;
		int prevMain = -1;

		int placed = 0;
		for (int step = 0; step < 10; ++step)
		{
			int slot = first + step;
			while (slot > 10) slot -= 10;

			Array<Class<Weapon> > owned;
			gatherSlot(pmo, slot, owned);
			if (owned.Size() == 0) continue;

			// BY SLOT, NOT BY DRAW ORDER. Both of these used to be keyed to
			// `placed`, which is the position in the reveal -- and the reveal
			// starts from whatever you are holding. So carrying a pistol made
			// the pistols the first cluster placed, and the first cluster
			// placed was always painted and named as slot one: your sidearms
			// came out labelled MELEE, your shotguns SIDEARMS, and the whole
			// legend rotated with your loadout. Slot 4 has to be the same
			// colour and the same name on every open or there is nothing to
			// learn, which is the entire premise of a fixed sky.
			color tint = clusterTint(slot - 1);

			// THE ARC IS CENTRED ON WHAT YOU ARE HOLDING, and this is the
			// second half of "it starts from the weapon in your hands".
			//
			// The reveal begins on your own slot and wraps, so `placed` 0 is
			// always the constellation you are already carrying -- and this used
			// to walk the arc from one end to the other, which put that first
			// cluster at -ARC_HALF: ninety-odd degrees to your RIGHT. You opened
			// the chart, and the one thing it was drawing for you began off the
			// edge of your vision while the space in front of you stayed empty.
			//
			// Fanning outward from zero instead puts your own weapon dead ahead
			// and alternates the rest either side of it, so the arsenal grows
			// around you symmetrically and the arc fills from the middle out.
			int rings = (total + 1) / 2;
			if (rings < 1) rings = 1;
			double step = ARC_HALF / double(rings);

			int away = (placed + 1) / 2;                 // 0,1,1,2,2,3,3...
			double side = (placed % 2 == 1) ? 1.0 : -1.0;  // right, left, right...
			double az = double(away) * step * side;
			// Hashed on the SLOT for the same reason as the colour: a
			// constellation has to be in the same place every time you open
			// the chart, not in a place that depends on what you happened to
			// be carrying when you opened it.
			double el   = RISE_LO + hash01(slot, 11) * (RISE_HI - RISE_LO);
			double rad  = NEAR_R + hash01(slot, 12) * (FAR_R - NEAR_R);

			Vector3 mainPos = pointAt(az, el, rad);

			// The main star's label goes UP AND OUT from the chart's centre --
			// its own variants hang below it, so up is the one direction that
			// is guaranteed clear of its own constellation.
			double mSign = (az < 0.0) ? -1.0 : 1.0;
			Vector3 mainLab = pointAt(az + LABEL_OUT * 0.7 * mSign,
			                          el + LABEL_OUT * 0.75, rad);

			int mainIdx = addStar(owned[0], mainPos, mainLab, STAR_MAIN, tint,
			                      placed, true, born);

			// THE CLUSTER'S TITLE, behind its own stars in depth so parallax
			// separates the two. Large and dim: it is meant to be read before
			// you focus on anything, and to disappear once you have.
			string tname = clusterName(slot - 1);
			int tchars = int(tname.Length());
			if (tchars < 4) tchars = 4;

			int title = level.AddBillboardPersistent(
				(0, 0, 0), 1.0, 1.0, 0, 0,
				LevelLocals.BBF_CAMERA, LevelLocals.BB_TEXT, 0,
				tint, LevelLocals.BBFL_NODEPTH | LevelLocals.BBFL_NOHIT, 0, tname);
			level.SetBillboardAlpha(title, 0.0);
			level.ResizeBillboard(title,
				TITLE_H * LABEL_ASPECT * double(tchars) * 0.5, TITLE_H * 0.5);
			level.MoveBillboard(title, pointAt(az, el - 4.0, rad * TITLE_BACK));
			mTitleIds.Push(title);
			mTitleBornAt.Push(born);

			// The dust arrives with its constellation, not before it.
			addDust(az, el, rad, tint, slot, born);
			born += T_MAIN;

			// The line from the previous constellation to this one. Drawn
			// faint: it says "and then", not "these belong together".
			if (prevMain >= 0)
			{
				mLinkA.Push(prevMain);
				mLinkB.Push(mainIdx);
				mLinkBornAt.Push(born);
				mLinkTint.Push(tint);
				born += T_LINK;
			}

			// Variants hang below and around their main star, close enough to
			// read as one thing.
			for (int v = 1; v < owned.Size(); ++v)
			{
				double vaz = az + (hash01(slot * 32 + v, 21) * 2.0 - 1.0) * 9.0;
				double vel = el - 6.0 - hash01(slot * 32 + v, 22) * 9.0;
				double vr  = rad * (0.92 + hash01(slot * 32 + v, 23) * 0.16);

				// RADIALLY OUTWARD FROM THE CLUSTER'S CENTRE. Take the
				// variant's own offset from its main star, stretch it, and put
				// the label out there -- so the leader always points away from
				// the crowd rather than back through it, from any angle.
				double daz = vaz - az, del = vel - el;
				double dlen = sqrt(daz * daz + del * del);
				if (dlen < 0.001) { daz = 0.0; del = -1.0; dlen = 1.0; }

				Vector3 vLab = pointAt(vaz + (daz / dlen) * LABEL_OUT,
				                       vel + (del / dlen) * LABEL_OUT, vr);

				int vi = addStar(owned[v], pointAt(vaz, vel, vr), vLab,
				                 STAR_SUB, tint, placed, false, born);

				mLinkA.Push(mainIdx);
				mLinkB.Push(vi);
				mLinkBornAt.Push(born);
				mLinkTint.Push(tint);

				born += T_SUB;
			}

			prevMain = mainIdx;
			++placed;
		}
	}

	private void gatherSlot(PlayerPawn pmo, int slot, out Array<Class<Weapon> > outv)
	{
		outv.Clear();
		let wp = pmo.player.weapons;
		if (!wp) return;

		int n = wp.SlotSize(slot);
		for (int i = 0; i < n; ++i)
		{
			Class<Weapon> ty = (Class<Weapon>)(wp.GetWeapon(slot, i));
			if (!ty) continue;
			// Owned, AND not stowed. A bHolsterHidden weapon cannot be fired
			// (Weapon.CheckAmmo refuses it) and this chart equips without
			// consulting CheckAmmo, so a star for one offers the player a gun
			// that bricks the moment they take it. Same rule as
			// wr_Rig.slotWeapons(); the reasoning is written out there.
			let have = Weapon(pmo.FindInventory(ty));
			if (!have || have.bHolsterHidden) continue;
			outv.Push(ty);
		}
	}

	private int addStar(Class<Weapon> ty, Vector3 pos, Vector3 labPos,
	                    double size, color tint,
	                    int cluster, bool isMain, int bornAt)
	{
		int idx = mStarIds.Size();

		int star = makeStar(tint, false, POINTS,
		                    isMain ? STROKE_MAIN : STROKE_SUB);
		level.ResizeBillboard(star, size, size);
		level.MoveBillboard(star, pos);
		mStarIds.Push(star);

		// A FORGIVING TARGET, separate from the star. Main stars get a wider
		// one than variants, which is also what resolves a ray that passes
		// through two of them: the thing you meant is nearly always the
		// bigger one.
		//
		// BB_PANEL with shape 0 -- a plain rectangle. It is never seen (alpha
		// 0), so solving a distance field for it every pixel buys nothing.
		// AGAINST THE DRAWN STAR, not the quad. The quad is now nearly twice
		// the star, so the old multipliers would have made every hit box
		// overlap its neighbours and the wrong star would light.
		double hitR = size * 0.58 * (isMain ? 1.35 : 1.25);
		int hit = level.AddBillboardPersistent(
			(0, 0, 0), 1.0, 1.0, 0, 0,
			LevelLocals.BBF_CAMERA, LevelLocals.BB_PANEL, 0,
			tint, LevelLocals.BBFL_NODEPTH, 0, "");
		level.SetBillboardAlpha(hit, 0.0);
		level.ResizeBillboard(hit, hitR, hitR);
		level.MoveBillboard(hit, pos);
		mStarHits.Push(hit);

		// THE NAME SITS OUTSIDE, ON A LEADER. Inside the glyph it was limited
		// by the star's interior pentagon, which is small -- short names just
		// fit and a long one never would -- and the arms cut across the type.
		//
		// SIZED IN WORLD UNITS, not as a fraction of its star, so a variant's
		// name is exactly as readable as a main star's. Scaling type with the
		// thing it names is how you get a chart whose least important labels
		// are the only ones you can read.
		string nm = tagOf(ty);
		int chars = int(nm.Length());
		if (chars < 3) chars = 3;

		int lab = level.AddBillboardPersistent(
			(0, 0, 0), 1.0, 1.0, 0, 0,
			LevelLocals.BBF_CAMERA, LevelLocals.BB_TEXT, 0,
			0xFFFFFF, LevelLocals.BBFL_NODEPTH | LevelLocals.BBFL_NOHIT, 0, nm);
		level.SetBillboardAlpha(lab, 0.0);
		level.ResizeBillboard(lab,
			LABEL_H * LABEL_ASPECT * double(chars) * 0.5, LABEL_H * 0.5);
		level.MoveBillboard(lab, labPos);
		mStarLabels.Push(lab);
		mLabX.Push(labPos.x); mLabY.Push(labPos.y); mLabZ.Push(labPos.z);

		mStarTypes.Push(ty);
		mStarCluster.Push(cluster);
		mStarMain.Push(isMain);
		mStarBornAt.Push(bornAt);
		mStarX.Push(pos.x); mStarY.Push(pos.y); mStarZ.Push(pos.z);
		mStarSize.Push(size);
		mStarTint.Push(tint);
		return idx;
	}

	private static string tagOf(Class<Weapon> ty)
	{
		if (!ty) return "";
		let d = GetDefaultByType(ty);
		string t = d ? d.GetTag() : "";
		return (t.Length() > 0) ? t : ("" .. ty.GetClassName());
	}

	// ---- per-tic ---------------------------------------------------------

	override void WorldTick()
	{
		if (!mOpen) return;

		let p = players[consoleplayer];
		if (!p || !p.mo) { Close(); return; }

		++mTics;
		updateHover(p.mo);
		layout(p.mo);
		drawLinks();
	}

	// Reassembled on read. Cheap, and it keeps every call site reading as if
	// the position were stored whole.
	private Vector3 starPos(int i) const
	{
		return (mStarX[i], mStarY[i], mStarZ[i]);
	}

	// How far into the reveal a thing is: 0 before it exists, 1 fully arrived.
	private double arrival(int bornAt) const
	{
		double t = double(mTics - bornAt) / RISE;
		return (t <= 0.0) ? 0.0 : (t >= 1.0 ? 1.0 : t);
	}

	// A speck's own shimmer at this instant. Phase AND rate are hashed per
	// speck: sharing either turns hundreds of independent lights into one
	// pulsing object, which is a heartbeat, not a sky.
	//
	// NOT twinkle(). ZScript identifiers are case-insensitive, so a function
	// by that name is the same name as the TWINKLE constant it reads.
	private double shimmer(int i, int salt) const
	{
		double rate  = 1.6 + hash01(i, salt) * 3.4;
		double phase = hash01(i, salt + 1) * 360.0;
		return 1.0 + sin(double(mTics) * rate + phase) * TWINKLE;
	}

	private void layoutDust()
	{
		for (int i = 0; i < mDustIds.Size(); ++i)
		{
			double a = arrival(mDustBornAt[i]);
			level.SetBillboardAlpha(mDustIds[i],
				a * mDustAlpha[i] * shimmer(i, 31));
		}
	}

	// The cluster titles. They arrive with their constellation and then sit
	// still -- and they DIM once something is lit, because at that point you
	// have stopped asking what you are looking at and started reading a name.
	private void layoutTitles()
	{
		for (int i = 0; i < mTitleIds.Size(); ++i)
		{
			double a = arrival(mTitleBornAt[i]);
			double w = (mHovered != 0) ? 0.45 : 1.0;
			level.SetBillboardAlpha(mTitleIds[i], a * TITLE_ALPHA * w);
		}
	}

	private void layout(PlayerPawn pmo)
	{
		layoutDust();
		layoutTitles();

		for (int i = 0; i < mStarIds.Size(); ++i)
		{
			double a = arrival(mStarBornAt[i]);
			bool lit = (mStarHits[i] == mHovered);

			// Overshoot and settle. A star does not fade in, it arrives --
			// briefly larger than its resting size, then eases down.
			double pop = 1.0 + (1.0 - a) * (1.0 - a) * 1.6;
			double sz  = mStarSize[i] * (lit ? 1.22 : 1.0)
			           * (a > 0.0 ? pop : 0.0);

			level.ResizeBillboard(mStarIds[i], sz, sz);
			level.SetBillboardAlpha(mStarIds[i], a * (lit ? 1.0 : 0.9));

			// STRENGTH IS NOT DECORATION. In BB_SDFSTAR it gates both the halo
			// and the emissive push past 1.0 that lets the bloom pass see the
			// star at all -- at zero every star draws as a flat outline.
			double g = mStarMain[i] ? GLOW_MAIN : GLOW_SUB;
			level.SetBillboardGlow(mStarIds[i], GLOW_REACH,
				lit ? (g + 0.55) : g);

			// THE LABEL IS NOT RESIZED WITH ITS STAR. It was set once in world
			// units and stays there: a name that grows when you point at it is
			// a name that was too small to read a moment ago, and the whole
			// reason the text left the glyph was to stop the star dictating
			// how legible its own name is.
			//
			// Names on every star, weighted rather than hidden. A chart whose
			// labels appear only under the pointer is a chart you have to sweep
			// to read, which is the ring's problem, not this one's.
			double lw;
			if (lit) lw = 1.0;
			else if (mStarMain[i]) lw = 0.92;
			else if (mHovered != 0 && sameClusterAsHovered(i)) lw = 0.85;
			else lw = 0.55;

			level.SetBillboardAlpha(mStarLabels[i], a * lw);
		}
	}

	private bool sameClusterAsHovered(int i) const
	{
		for (int k = 0; k < mStarHits.Size(); ++k)
			if (mStarHits[k] == mHovered)
				return mStarCluster[k] == mStarCluster[i];
		return false;
	}

	// The links, as beams. Each one grows from its parent toward its child
	// rather than appearing whole -- the reach IS the animation.
	private void drawLinks()
	{
		// TWO KINDS OF LINE, ONE BUDGET. The links between stars and the
		// leaders out to the labels are both beams, and SetBeamCount is
		// level-wide -- two features each setting their own count would fight
		// every tic and the loser's lines would simply not exist. Links first,
		// leaders after, each section starting where the last ended.
		int nLink = int(mLinkA.Size());
		int nLead = int(mStarIds.Size());

		// Structure outlives annotation: if a genuinely enormous arsenal
		// overruns, the leaders go before the links do.
		if (nLink > BEAM_MAX) nLink = BEAM_MAX;
		if (nLink + nLead > BEAM_MAX) nLead = BEAM_MAX - nLink;
		if (nLead < 0) nLead = 0;

		int leadBase = BEAM_BASE + nLink;
		int want = nLink;

		level.SetBeamCount(leadBase + nLead,
			cv("wr_beam_glow", 0.35), cv("wr_beam_fog", 0.2));

		for (int i = 0; i < want; ++i)
		{
			double a = arrival(mLinkBornAt[i]);
			if (a <= 0.0)
			{
				level.SetBeam(BEAM_BASE + i, (0,0,0), (0,0,0), 0, 0, 0x000000, 0);
				continue;
			}

			Vector3 from = starPos(mLinkA[i]);
			Vector3 to   = starPos(mLinkB[i]);
			Vector3 grow = from + (to - from) * a;

			level.SetBeam(BEAM_BASE + i, from, grow,
				cv("wr_chart_link_thick", 0.12), 0.4,
				mLinkTint[i], a * cv("wr_chart_link_alpha", 0.45));
		}

		drawLeaders(leadBase, nLead);

		for (int i = leadBase + nLead; i < BEAM_BASE + BEAM_MAX; ++i)
			level.SetBeam(i, (0,0,0), (0,0,0), 0, 0, 0x000000, 0);
	}

	// THE LEADERS. A hairline from each star out to its own name.
	//
	// Thinner and fainter than the links on purpose: a link is structure --
	// this weapon belongs with that one -- while a leader is only saying which
	// name goes with which star. Drawn at the same weight they would compete,
	// and the chart would look like a wiring diagram.
	//
	// STOPPING SHORT AT BOTH ENDS. Run edge to edge and the line disappears
	// into the star's glow at one end and collides with the type at the other;
	// leaving a gap is what makes it read as pointing rather than as attached.
	private void drawLeaders(int base, int count)
	{
		for (int i = 0; i < count; ++i)
		{
			double a = arrival(mStarBornAt[i]);
			bool lit = (mStarHits[i] == mHovered);

			if (a <= 0.0)
			{
				level.SetBeam(base + i, (0,0,0), (0,0,0), 0, 0, 0x000000, 0);
				continue;
			}

			Vector3 sp = starPos(i);
			Vector3 lp = (mLabX[i], mLabY[i], mLabZ[i]);

			Vector3 d = lp - sp;
			double len = d.Length();
			if (len < 0.001) continue;
			Vector3 u = d / len;

			// Clear of the drawn star at one end, clear of the type at the
			// other. mStarSize is the QUAD, and the star is 58% of it.
			double gapA = mStarSize[i] * 0.58 * 0.62;
			double gapB = LABEL_H * 0.55;
			if (gapA + gapB >= len) continue;

			Vector3 from = sp + u * gapA;
			Vector3 to   = sp + u * (len - gapB);

			// Grows with its star rather than snapping in, so the name reaches
			// out of the star instead of arriving beside it.
			Vector3 grow = from + (to - from) * a;

			level.SetBeam(base + i, from, grow,
				LEAD_THICK, 0.22, mStarTint[i],
				a * LEAD_ALPHA * (lit ? 2.0 : 1.0));
		}
	}

	// ---- pointing --------------------------------------------------------

	private int indexOfHit(int id) const
	{
		for (int i = 0; i < mStarHits.Size(); ++i)
			if (mStarHits[i] == id) return i;
		return -1;
	}

	// WHERE THE BEAM STOPS. The hovered star's distance, or zero for "do not
	// clamp" -- the same contract the ring publishes, so the beam reads as
	// touching the star rather than passing through it.
	double LaserReach() const
	{
		return mOpen ? mReach : 0.0;
	}

	// WHERE THE FINGERTIP IS THIS INSTANT, and whether it has left the dead
	// zone at all. See GOGO_DEAD for why the curve is shaped the way it is.
	private Vector3 fingerTip(PlayerPawn pmo, out bool reaching)
	{
		Vector3 eye  = pmo.Pos + (0, 0, pmo.player.viewheight);
		Vector3 hand = wr_Rig.handPos(pmo, mHand);

		Vector3 arm = hand - eye;
		double real = arm.Length();
		if (real < 0.001) { reaching = false; return hand; }

		Vector3 u = arm / real;

		double past = real - (mRestReach + GOGO_DEAD);
		if (past <= 0.0)
		{
			// Inside the dead zone the fingertip IS the hand -- no
			// amplification at all, so ordinary movement near your body cannot
			// fling a cursor across the sky.
			reaching = false;
			return hand;
		}

		reaching = true;

		double virt = real + past * past * cv("wr_chart_gogo", GOGO_K);
		double cap  = FAR_R * GOGO_MAX;
		if (virt > cap) virt = cap;

		return eye + u * virt;
	}

	// The grab sphere grows with how far out the fingertip has gone: a radius
	// that feels right against the near clusters subtends almost nothing
	// against the far ones.
	private double tipRadius(Vector3 tip, Vector3 eye) const
	{
		double d = (tip - eye).Length() / FAR_R;
		if (d < 0.0) d = 0.0; else if (d > 1.0) d = 1.0;
		return TIP_R + (TIP_R_FAR - TIP_R) * d;
	}

	private void updateHover(PlayerPawn pmo)
	{
		// THE RING'S OWN RAY, from the hand that opened this. Not AttackPos,
		// which is the main hand whichever hand you actually used -- so an
		// off-hand chart drew its beam from one hand and picked along the other.
		Vector3 org = wr_Rig.handPos(pmo, mHand);
		Vector3 dir = wr_Rig.handDir(pmo, mHand);

		int hit;
		Vector2 uv;
		[hit, uv] = level.AimBillboard(org, dir, FAR_R * 2.6);

		// REACHING WINS OVER POINTING, the same rule and the same reason the
		// ring gives: both are ways in and they are not rivals, but putting
		// your hand somewhere is the more deliberate act than happening to be
		// pointed past it.
		Vector3 eye = pmo.Pos + (0, 0, pmo.player.viewheight);
		Vector3 tip = fingerTip(pmo, mReaching);

		if (mReaching)
		{
			int touched;
			Vector2 tuv;
			double tdist;
			[touched, tuv, tdist] = level.TouchBillboard(tip, tipRadius(tip, eye));
			if (touched != 0 && indexOfHit(touched) >= 0) hit = touched;
		}

		// The marker. Shown only while actually reaching -- a cursor parked in
		// the sky at rest is one more thing to read on a chart that is already
		// asking you to read it.
		if (mTipId)
		{
			double lit = (hit != 0 && indexOfHit(hit) >= 0) ? 1.0 : 0.55;
			level.MoveBillboard(mTipId, tip);
			level.SetBillboardAlpha(mTipId, mReaching ? lit : 0.0);
			double ts = TIP_SIZE * (lit > 0.9 ? 1.45 : 1.0);
			level.ResizeBillboard(mTipId, ts, ts);
		}

		if (hit != 0 && indexOfHit(hit) >= 0)
		{
			mHovered    = hit;
			mHoverGrace = HOVER_GRACE;

			// Measured to the star itself rather than to its hit box, which is
			// half again as wide -- the beam should land on the thing you can
			// see, not on the forgiveness around it.
			mReach = (starPos(indexOfHit(hit)) - org).Length();
			return;
		}

		// A MISS REACHES PAST THE SKY, not to zero. Zero means "unclamped" to
		// the engine, which would put the beam on the far wall; stopping it just
		// beyond the furthest cluster keeps it inside the chart it belongs to.
		mReach = FAR_R * 1.25;

		// WHY NOTHING IS LIT, said out loud. There are three ways to get here
		// and from inside a headset they are indistinguishable:
		//
		//   the ray found nothing at all      -- aim, range or origin is wrong
		//   it found a billboard that is not ours  -- something is in front of
		//     the chart and ate it, which AimBillboard cannot avoid because it
		//     returns the nearest hittable billboard in the WORLD
		//   it found one of ours and we rejected it -- impossible by the branch
		//     above, so if this ever prints that, the id bookkeeping is broken
		//
		// Every eighth tic so it is readable rather than a wall.
		if (cv("wr_chart_debug", 0.0) > 0.0 && (mTics % 8) == 0)
		{
			Console.Printf(
				"[CHART] miss: ray=%d (%s)  stars=%d  hand=%d  org=(%.0f,%.0f,%.0f) dir=(%.2f,%.2f,%.2f)",
				hit,
				(hit == 0) ? "nothing in range" : "foreign billboard",
				mStarHits.Size(), mHand,
				org.x, org.y, org.z, dir.x, dir.y, dir.z);
		}

		// Held briefly, so a shaky hand crossing empty sky does not strobe
		// the label off and on.
		if (mHoverGrace > 0) --mHoverGrace;
		else                 mHovered = 0;
	}

	// ---- selecting -------------------------------------------------------

	// READ FROM UI SCOPE. wr_Rig's InputProcess is ui and cannot call into the
	// playsim, so it cannot ask Commit() whether it would have taken the press
	// -- it has to know BEFORE it decides to consume the key, or it eats a
	// trigger pull that should have gone to the gun.
	bool Hot() const
	{
		return mOpen && mHovered != 0;
	}

	// Take whatever is lit. Returns true when it consumed the press, so the
	// caller does not also fire the gun in the player's hand.
	bool Commit()
	{
		if (!mOpen || mHovered == 0) return false;

		int i = indexOfHit(mHovered);
		if (i < 0) return false;

		let pmo = players[consoleplayer].mo;
		if (!pmo || !pmo.player) return false;

		let w = Weapon(pmo.FindInventory(mStarTypes[i]));
		if (!w) return false;

		// PendingWeapon, never a raw slot write -- the raise has to run or the
		// gun appears already up, which reads as a glitch.
		// THE HAND THAT OPENED THIS. BringUpWeapon raises a weapon in whichever
		// hand its bOffhandWeapon flag last said, so a bare PendingWeapon put
		// the pick in the weapon's previous hand, not the one wearing the
		// layout. Same seat the holsters use: exact instance, this hand.
		w.bOffhandWeapon = (mHand == 1);
		if (w.SisterWeapon != null) w.SisterWeapon.bOffhandWeapon = w.bOffhandWeapon;
		pmo.MoveWeaponToHand(w, mHand, true);

		// THROUGH THE RIG, NOT Close(). Close() only takes the billboards down.
		// The SESSION -- the claimed sticks, the forced laser, the slowed clock --
		// belongs to wr_Rig and is undone by closeAlt(), so committing straight to
		// Close() picked the weapon and left the player standing still, unable to
		// walk or snap turn, with nothing left on screen to explain why.
		//
		// Quiet, because the commit makes its own noise a frame earlier and two
		// sounds that close together read as a stutter.
		let rig = wr_Rig.Get();
		if (rig) rig.closeAlt(true);
		else     Close();   // no rig to hand it back to; at least take the sky down

		return true;
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Player != consoleplayer) return;

		if (e.Name == "rs-chart-toggle") { Toggle(); return; }
		if (e.Name == "rs-chart-pick")   { Commit(); return; }
	}

	override void WorldUnloaded(WorldEvent e)
	{
		Close();
	}
}
