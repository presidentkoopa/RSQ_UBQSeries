// THE HONEYCOMB.
//
// Every weapon you own, all at once, as a wall of hexagonal cells packed
// edge to edge and coloured by slot.
//
// WHY IT SHOWS EVERYTHING. The ring folds weapons into fans for exactly one
// reason, stated in its own source: an arc runs out of arc length, and nine
// cards need nine card-widths of it at a radius nobody wants. A packed grid
// has no such ceiling -- ring 3 holds 37 cells, ring 4 holds 61 -- so the
// crowding valve that fans exist to be is not needed here, and carrying it
// over would be importing a workaround for a constraint that is absent.
//
// WHAT THAT BUYS, beyond not hiding anything: a slot becomes a CONTIGUOUS
// PATCH OF ONE COLOUR. Four shotguns read as four shotguns at a glance,
// without hovering, without opening anything. The grouping is spatial and
// permanent rather than a thing you have to go and unfold -- which is the one
// job the fan never actually did well.
//
// HOVER BLOOMS THE WHOLE SLOT rather than re-tiling. The image this was drawn
// from had cells sliding apart to admit new ones, and it is a lovely moment,
// but it costs a re-solve of the entire comb mid-motion and it moves the thing
// you were pointing at. Lifting a colour group toward you and dimming the rest
// gives the same beat -- the group announces itself -- while every cell stays
// exactly where your hand already learned it was.
//
// The cells are BB_SDFHEX, which was added to the engine for this: a
// tessellation shares edges, and a shared edge is the one place a sampled
// shape cannot hide. Two neighbours each half a pixel soft do not meet, they
// seam.
//
// IT IS A SPHERE SECTION, NOT A WALL -- a flattened soccerball, which is what
// it was asked to be and also what makes it work. The cells are laid out in
// ANGLE around your eye rather than in distance across a plane, so each one
// subtends the same angle wherever it sits and the comb stays exactly
// tessellated at its edges instead of opening up. Every cell faces you
// (BBF_CAMERA), which on a sphere centred on your eye is the same statement
// twice.

class wr_Honeycomb : EventHandler
{
	// ---- geometry --------------------------------------------------------

	// THE LATTICE UNIT, in billboard half-extents, and getting this wrong is
	// what made the first version of this file unusable.
	//
	// A billboard's size argument is a HALF-extent, so a cell of size sz is
	// 2*sz across the quad. BB_SDFHEX fits its apothem to 0.866 of that half-
	// extent, so flat-to-flat the hexagon is 2 * 0.866 * sz = 1.732*sz wide,
	// and THAT is the distance two horizontal neighbours must sit apart to
	// share an edge. The first version spaced them 1.0*sz -- a little over half
	// of what they needed -- so every cell sat on top of its neighbours.
	const LATTICE     = 1.7320508;

	// A multiplier on that, and 1.0 means exactly touching. Each cell draws its
	// own border inside its own edge, so two touching cells put two border
	// strips side by side and the shared line comes out twice as wide as an
	// outer one -- which is what a comb looks like, and is why this is 1.0
	// rather than a value that opens a gap to fake the same line.
	const PITCH       = 1.0;

	// A pointy-top hex is sqrt(3)/2 as tall between flats as it is wide
	// between vertices, which is what makes the rows interlock instead of
	// stacking. Get this wrong and it is a grid of hexagons rather than a
	// honeycomb.
	const ROW_STEP    = 0.8660254;

	// How far out in front the comb hangs, and how big a cell is there.
	const FORWARD     = 34.0;
	const CELL        = 4.6;

	// THE DOME. A flattened soccerball, which is a sphere section and not a
	// wall -- the cells sit on a sphere centred on your eye and each one turns
	// to face you, so the comb wraps rather than hanging.
	//
	// This is also what makes the tessellation exact. Laying the lattice out in
	// ANGLE rather than in distance means every cell subtends the same angle
	// from the eye no matter how far round the dome it sits, so the comb is
	// seamless in the only place it has to be -- the view -- while genuinely
	// curving away in the world. A flat wall of cells cannot have both.
	//
	// The radius is a MULTIPLE of the hanging distance rather than equal to it:
	// at 1.0 the curve is a full bowl and the outer cells end up beside your
	// ears. 1.7 is the flattening.
	const DOME_MULT   = 1.7;

	// The hovered cell comes toward you, and its whole slot comes part way.
	// Small numbers: this is a lift, not a leap.
	const POP_HOVER   = 2.2;
	const POP_GROUP   = 0.9;

	// Corner rounding and border width, the two nibbles BB_SDFHEX reads.
	// A hexagon has 120-degree corners, so it needs far less rounding than a
	// card before it stops looking like itself.
	//
	// The border is ONE and not two because neighbours touch: every interior
	// line in the comb is two borders back to back, so it already draws at
	// double width. At 2 the grid was heavier than the cells it divided.
	const HEX_ROUND   = 2;
	const HEX_BORDER  = 1;

	// HOW FAR A CELL'S SHADE MAY WANDER FROM ITS SLOT'S COLOUR.
	//
	// A slot rendered as one flat colour across six cells is a coloured blob --
	// the boundaries between its own cells stop registering and the patch reads
	// as a single misshapen tile. Nudging each cell's value a little, by a hash
	// of its index so it is the same every time, keeps the patch reading as one
	// colour while the cells inside it stay individually visible. Small on
	// purpose: this is grain, not variety.
	const SHADE_VARY  = 0.16;

	// BBFL_NODEPTH ON EVERYTHING, and it is the whole answer to walls.
	//
	// The defect this replaces was real: a layout placed into geometry is
	// invisible AND still selectable, because nothing in the pointing path
	// knows geometry exists -- AimBillboard, TouchBillboard and stickPick all
	// pass straight through it. So you end up pointing a clamped laser at a
	// card behind a door and committing to it blind.
	//
	// The first fix traced at build and pulled the layout in to fit the room.
	// It worked and it was WRONG, because a Doom room is often two hundred
	// units across and this chart wants to stand at a hundred and twenty: the
	// clamp crushed the sky into a closet, and every bit of depth and spread
	// the layout exists for went with it.
	//
	// The mismatch was never that the placement disobeyed walls. It was that
	// the DRAWING obeyed them while the pointing did not. A chart is a menu
	// that happens to occupy a volume, not an object in the room -- so it draws
	// over geometry, the two halves agree again, and it can stand as far out as
	// it likes. Same reason wr_gunhud.zs uses the flag for the on-gun readout.

	// The reveal. Cells arrive ring by ring from the centre outward, which is
	// how a comb grows and also happens to be the order that reads best --
	// the thing you are most likely to want is nearest the middle and appears
	// first.
	const T_RING      = 3;

	// How long a cell takes to finish arriving once its turn comes.
	const RISE        = 6.0;

	// ---- state -----------------------------------------------------------

	private bool     mOpen;
	private int      mTics;

	private Array<int>     mCellIds;
	private Array<int>     mCellHits;
	private Array<int>     mCellLabels;
	private Array<Class<Weapon> > mCellTypes;
	private Array<int>     mCellSlot;
	private Array<int>     mCellTint;
	private Array<int>     mCellBornAt;
	// Three arrays, not one: a ZScript dynamic array's base type must be
	// integral, so Array<Vector3> does not compile. The ring does the same.
	private Array<double>  mCellX;
	private Array<double>  mCellY;
	private Array<double>  mCellZ;

	private int      mHovered;

	// Which hand opened it, and where its ray last landed -- the same two
	// facts the ring keeps, for the same two reasons: point from the hand
	// that raised the layout, and stop the beam on what it found.
	private int      mHand;
	private double   mReach;

	// How far the comb may actually hang, given the room. Solved once at
	// open; a comb that re-solved per tic would breathe in and out as the
	// player leaned.
	private double   mDist;

	private Vector3  mOrigin;
	private double   mOriginYaw;

	// ---- palette ---------------------------------------------------------

	// Shared with the star chart on purpose: a slot is the same colour
	// whichever layout you are looking at, so switching between them does not
	// mean learning the arsenal twice.
	private static color slotTint(int slot)
	{
		switch (slot % 8)
		{
		case 1: return 0x39B7F0;
		case 2: return 0xA98BD8;
		case 3: return 0xF07AA8;
		case 4: return 0x6FD98A;
		case 5: return 0xF0C04A;
		case 6: return 0x59D8CF;
		case 7: return 0xE8794A;
		default: return 0xB8C4E0;
		}
	}

	private static double cv(string n, double d)
	{
		let c = CVar.GetCVar(n, players[consoleplayer]);
		return c ? c.GetFloat() : d;
	}

	static wr_Honeycomb Get()
	{
		return wr_Honeycomb(EventHandler.Find("wr_Honeycomb"));
	}

	// ---- the lattice -----------------------------------------------------

	// Axial hex coordinates to a flat offset, in cell widths. Pointy-top: q
	// runs along the row, r steps down and half a cell across, which is the
	// interlock.
	private static Vector2 axialToPlane(int q, int r)
	{
		return (double(q) + double(r) * 0.5, double(r) * ROW_STEP);
	}

	// The Nth cell of a spiral walked outward from the centre. Ring k has
	// exactly 6k cells, so index 0 is the middle, 1-6 the first ring, 7-18 the
	// second, and so on -- which gives a fill order that is always compact and
	// never leaves a hole.
	private static void spiralAt(int index, out int q, out int r)
	{
		q = 0; r = 0;
		if (index <= 0) return;

		// Which ring, and how far around it.
		int ring = 1;
		int left = index - 1;
		while (left >= 6 * ring) { left -= 6 * ring; ++ring; }

		// Start at the ring's first corner, then walk its six sides.
		q = ring; r = -ring;   // one corner of the ring
		int side = left / ring;
		int step = left % ring;

		// The six axial directions, walked in order.
		int dq[6]; int dr[6];
		dq[0] = -1; dr[0] =  1;
		dq[1] = -1; dr[1] =  0;
		dq[2] =  0; dr[2] = -1;
		dq[3] =  1; dr[3] = -1;
		dq[4] =  1; dr[4] =  0;
		dq[5] =  0; dr[5] =  1;

		for (int s = 0; s < side; ++s)
		{
			q += dq[s] * ring;
			r += dr[s] * ring;
		}
		q += dq[side] * step;
		r += dr[side] * step;
	}

	private static int ringOf(int index)
	{
		if (index <= 0) return 0;
		int ring = 1;
		int left = index - 1;
		while (left >= 6 * ring) { left -= 6 * ring; ++ring; }
		return ring;
	}

	// ---- opening ---------------------------------------------------------

	// Answers whether there is anything to point AT. An empty arsenal builds
	// no cells, and the caller must not claim the sticks and the laser for a
	// comb with nothing in it -- there would be no cell to press to get out.
	bool IsOpen() const
	{
		return mOpen && mCellIds.Size() > 0;
	}

	// WHERE THE BEAM STOPS. Same contract the ring publishes: the hovered
	// cell's distance, so the beam lands on it rather than passing through.
	double LaserReach() const
	{
		return mOpen ? mReach : 0.0;
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
		mOpen      = true;

		mDist = FORWARD * cv("wr_hive_dist", 1.0);

		build(pmo);

		if (mCellIds.Size() == 0) { mOpen = false; return; }
	}

	void Close()
	{
		for (int i = 0; i < mCellIds.Size(); ++i)
		{
			if (mCellIds[i])    level.RemoveBillboard(mCellIds[i]);
			if (mCellHits[i])   level.RemoveBillboard(mCellHits[i]);
			if (mCellLabels[i]) level.RemoveBillboard(mCellLabels[i]);
		}
		mCellIds.Clear();   mCellHits.Clear();  mCellLabels.Clear();
		mCellTypes.Clear(); mCellSlot.Clear();  mCellTint.Clear();
		mCellBornAt.Clear();
		mCellX.Clear();     mCellY.Clear();     mCellZ.Clear();

		mOpen = false;
		mHovered = 0;
	}

	// ---- filling the comb ------------------------------------------------

	private void build(PlayerPawn pmo)
	{
		// SLOT ORDER, AND CONTIGUOUS. Walking the spiral once while stepping
		// through the slots in order is what puts a slot's weapons in adjacent
		// cells -- the patch of one colour is a consequence of the fill order,
		// not something arranged afterwards.
		int cell = 0;

		for (int slot = 1; slot <= 10; ++slot)
		{
			Array<Class<Weapon> > owned;
			gatherSlot(pmo, slot, owned);

			for (int i = 0; i < owned.Size(); ++i)
			{
				addCell(owned[i], slot, cell);
				++cell;
			}
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
			// (Weapon.CheckAmmo refuses it) and this comb equips without
			// consulting CheckAmmo, so a cell for one offers the player a gun
			// that bricks the moment they take it. Same rule as
			// wr_Rig.slotWeapons(); the reasoning is written out there.
			let have = Weapon(pmo.FindInventory(ty));
			if (!have || have.bHolsterHidden) continue;
			outv.Push(ty);
		}
	}

	private void addCell(Class<Weapon> ty, int slot, int index)
	{
		int q, r;
		spiralAt(index, q, r);
		Vector2 flat = axialToPlane(q, r);

		double sz  = CELL * cv("wr_hive_scale", 1.0);
		Vector3 pos = domeAt(flat.x * sz * LATTICE * PITCH,
		                     flat.y * sz * LATTICE * PITCH, 0.0);

		color tint = shadeOf(slotTint(slot), index);

		int shape = (HEX_ROUND << 8) | HEX_BORDER;

		// BBF_CAMERA, not BBF_FIXED. On a dome every cell sits at a different
		// angle from the eye, so a shared yaw leaves the outer ones edge-on --
		// they foreshorten into slivers and the comb stops tessellating exactly
		// where it is widest. Facing the viewer puts every cell's normal on its
		// own sightline, which is the same thing as saying the sphere is
		// centred on your eye.
		int id = level.AddBillboardPersistent(
			(0, 0, 0), sz, sz, 0, 0,
			LevelLocals.BBF_CAMERA, LevelLocals.BB_SDFHEX, shape,
			tint, LevelLocals.BBFL_NODEPTH | LevelLocals.BBFL_NOHIT, 0, "");
		level.SetBillboardAlpha(id, 0.0);

		// A GRADIENT PER CELL, dark at the bottom. Flat fills are what make a
		// tiled surface look printed; a vertical falloff gives every cell the
		// same implied light and the comb reads as one lit object rather than
		// as forty stickers.
		level.SetBillboardGradient(id, shadeOf(tint, index + 7717));
		mCellIds.Push(id);

		// The target is its own quad, as it is everywhere else here: the cell
		// is drawn at the pitch that makes it tessellate, and a hit box the
		// same size would have no forgiveness at all where two cells meet.
		int hit = level.AddBillboardPersistent(
			(0, 0, 0), sz * 0.92, sz * 0.92, 0, 0,
			LevelLocals.BBF_CAMERA, LevelLocals.BB_PANEL, 0,
			tint, LevelLocals.BBFL_NODEPTH, 0, "");
		level.SetBillboardAlpha(hit, 0.0);
		level.MoveBillboard(hit, pos);
		mCellHits.Push(hit);

		int lab = level.AddBillboardPersistent(
			(0, 0, 0), sz * 0.8, sz * 0.22, 0, 0,
			LevelLocals.BBF_CAMERA, LevelLocals.BB_TEXT, 0,
			0xFFFFFF, LevelLocals.BBFL_NODEPTH | LevelLocals.BBFL_NOHIT, 0, tagOf(ty));
		level.SetBillboardAlpha(lab, 0.0);
		mCellLabels.Push(lab);

		mCellTypes.Push(ty);
		mCellSlot.Push(slot);
		mCellTint.Push(tint);
		mCellBornAt.Push(ringOf(index) * T_RING);
		mCellX.Push(pos.x); mCellY.Push(pos.y); mCellZ.Push(pos.z);
	}

	// THE COMB IS A PIECE OF A SPHERE, centred on where your eye was when it
	// opened, and it stays put. A wall that follows your head is a HUD.
	//
	// right/up arrive as ARC LENGTHS along that sphere rather than as offsets
	// on a plane, which is the whole trick: dividing by the radius turns them
	// into angles, and equal angles are what make cells the same apparent size
	// at the middle of the comb and at its edge. On a plane they would not be,
	// and the tessellation would open up as it went outward.
	private Vector3 domeAt(double right, double up, double push)
	{
		double rad = mDist * cv("wr_hive_dome", DOME_MULT);
		if (rad < 8.0) rad = 8.0;

		// Arc length over radius is radians; everything downstream is degrees.
		double az = (right / rad) * 57.29577951;
		double el = (up    / rad) * 57.29577951;

		// The cell hangs at the comb's distance, not at the dome's -- the dome
		// only sets how hard the sheet curves. Pulling `push` off the distance
		// is what brings a hovered cell toward you along its own sightline
		// rather than sideways.
		double d = mDist - push;

		double yaw = mOriginYaw + az;
		double ch  = cos(el);
		return mOrigin + (cos(yaw) * ch * d, sin(yaw) * ch * d, sin(el) * d);
	}

	// The per-cell value nudge described at SHADE_VARY. Hashed on the cell's
	// own index so a given arsenal always looks the same, which matters more
	// than it sounds: the comb is meant to be learned.
	private static color shadeOf(color base, int index)
	{
		// 1103515245 and not one of the usual 32-bit hash multipliers: ZScript
		// ints are signed, so anything at or above 2^31 is not a literal it can
		// hold. This one is under it and mixes the low bits just as well.
		double h = double((index * 1103515245 + 12345) & 1023) / 1023.0;
		double m = 1.0 + (h * 2.0 - 1.0) * SHADE_VARY;

		int r = int(base.r * m); if (r > 255) r = 255; if (r < 0) r = 0;
		int g = int(base.g * m); if (g > 255) g = 255; if (g < 0) g = 0;
		int b = int(base.b * m); if (b > 255) b = 255; if (b < 0) b = 0;
		return Color(255, r, g, b);
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
	}

	private double arrival(int bornAt) const
	{
		double t = double(mTics - bornAt) / RISE;
		return (t <= 0.0) ? 0.0 : (t >= 1.0 ? 1.0 : t);
	}

	private int hoveredSlot() const
	{
		for (int i = 0; i < mCellHits.Size(); ++i)
			if (mCellHits[i] == mHovered) return mCellSlot[i];
		return 0;
	}

	private void layout(PlayerPawn pmo)
	{
		int hotSlot = hoveredSlot();

		for (int i = 0; i < mCellIds.Size(); ++i)
		{
			double a = arrival(mCellBornAt[i]);
			bool lit   = (mCellHits[i] == mHovered);
			bool inSet = (hotSlot != 0 && mCellSlot[i] == hotSlot);

			// THE BLOOM. The pointed cell comes toward you, its slot-mates
			// come part of the way, and everything else stays put and dims.
			// The group announces itself without a single cell moving
			// sideways, so what your hand learned a moment ago is still true.
			// TOWARD THE EYE, not toward the comb's forward. On a dome those
			// are different directions everywhere except dead centre, and using
			// the second one slides the outer cells across their neighbours
			// instead of lifting them out.
			double push = lit ? POP_HOVER : (inSet ? POP_GROUP : 0.0);
			Vector3 pos = (mCellX[i], mCellY[i], mCellZ[i]);
			if (push > 0.0)
			{
				Vector3 toEye = mOrigin - pos;
				double len = toEye.Length();
				if (len > 0.001) pos = pos + toEye / len * push;
			}

			double sz = CELL * cv("wr_hive_scale", 1.0)
			          * (lit ? 1.06 : (inSet ? 1.02 : 1.0));

			// Cells arrive by growing into their own footprint rather than
			// fading -- a tessellation that fades in looks like a stain, and
			// one that grows looks like it is being built.
			double grow = 0.55 + a * 0.45;

			level.MoveBillboard(mCellIds[i], pos);
			level.ResizeBillboard(mCellIds[i], sz * grow, sz * grow);

			// Dimming the rest is what makes the bloom read. Not so far that
			// the comb stops being visible -- you are still choosing from all
			// of it, and a wall of near-black cells would undo the whole
			// reason this layout shows everything.
			double alpha = a * (lit ? 1.0 : (hotSlot != 0 && !inSet ? 0.42 : 0.88));
			level.SetBillboardAlpha(mCellIds[i], alpha);

			level.SetBillboardGlow(mCellIds[i],
				lit ? 1.0 : (inSet ? 0.45 : 0.0), 0.0);

			level.MoveBillboard(mCellHits[i], pos);

			// Labels on the hovered slot only. Every name at once on a
			// forty-cell wall is a wall of text; the colour already says what
			// each patch is, and the name is what you want once you have
			// picked a patch to look at.
			double lw = lit ? 1.0 : (inSet ? 0.7 : 0.0);
			if (lw > 0.0)
			{
				level.MoveBillboard(mCellLabels[i], pos - (0, 0, sz * 0.02));
			}
			level.SetBillboardAlpha(mCellLabels[i], a * lw);
		}
	}

	// ---- pointing --------------------------------------------------------

	private void updateHover(PlayerPawn pmo)
	{
		// The ring's own ray, from the hand that opened this -- not AttackPos,
		// which is the main hand whichever hand you actually used.
		Vector3 org = wr_Rig.handPos(pmo, mHand);
		Vector3 dir = wr_Rig.handDir(pmo, mHand);

		int hit;
		Vector2 uv;
		[hit, uv] = level.AimBillboard(org, dir, FORWARD * 3.0);

		mHovered = (hit != 0 && indexOfHit(hit) >= 0) ? hit : 0;
	}

	private int indexOfHit(int id) const
	{
		for (int i = 0; i < mCellHits.Size(); ++i)
			if (mCellHits[i] == id) return i;
		return -1;
	}

	// ---- selecting -------------------------------------------------------

	// READ FROM UI SCOPE. wr_Rig's InputProcess is ui and cannot call into the
	// playsim, so it cannot ask Commit() whether it would have taken the press
	// -- it has to know BEFORE it decides to consume the key, or it eats a
	// trigger pull that should have gone to the gun. This is the one bit of
	// state that decision needs, mirrored onto the rig each tic.
	bool Hot() const
	{
		return mOpen && mHovered != 0;
	}

	bool Commit()
	{
		if (!mOpen || mHovered == 0) return false;

		int i = indexOfHit(mHovered);
		if (i < 0) return false;

		let pmo = players[consoleplayer].mo;
		if (!pmo || !pmo.player) return false;

		let w = Weapon(pmo.FindInventory(mCellTypes[i]));
		if (!w) return false;

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
		let rig = wr_Rig.Get();
		if (rig) rig.closeAlt(true);
		else     Close();   // no rig to hand it back to; at least take the comb down

		return true;
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Player != consoleplayer) return;

		if (e.Name == "rs-comb-pick") { Commit(); return; }
	}

	override void WorldUnloaded(WorldEvent e)
	{
		Close();
	}
}
