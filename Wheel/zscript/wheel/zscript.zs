
// wr_compat_legendoom.zs -- reading LegenDoom's own rarity for the data
// card. Its own file, one per compat target going forward, so any one mod's
// integration can be diffed, reverted or dropped without touching another's
// or the ring's own code.

// wr_compat_drla.zs -- reading DoomRL Arsenal's assembly tier the same way.

// wr_compat_doomablo.zs -- reading Doomablo's own rarity field.

// wr_compat_pandemonia.zs -- reading base Pandemonia's own durability/
// magazine/sidegrade fields and its player-wide Game Level counter. No
// rarity/tier concept in this one, so unlike the first three compat files
// it never touches the title row.

// wr_compat_pandemonia_anarchy.zs -- reading the Anarchic Sigil, the one
// real player-leveling item in the Anarchy addon. Independent of whichever
// Pandemonia-family weapon is in hand, so read off the OWNER.

// wr_compat_pandemonia_insurrection.zs -- reading the Insurrection addon's
// augment/durability/combo-bar/color-tag fields (formerly named
// wr_compat_pandemonium.zs -- "Pandemonium" was this fork's own misnomer
// for the mod family, corrected once the whole family was surveyed). No
// rarity/tier concept in this one either.

// wr_compat_guncaster.zs -- reading Guncaster's player-side resource pools
// (spell cooldown, charge/hover/glide/stomp/curse). No per-weapon tier
// here at all -- Guncaster is one class with no rarity system -- so this
// reads the WEAPON'S OWNER, not the weapon, and never touches the title row.

// wr_compat_metadoom.zs -- reading MetaDoom's two real per-weapon
// escalation mechanics (plasma rifle heat, Unmaker demon keys). No tier
// ladder in this mod either, so this never touches the title row.

// wr_compat_borderdoom.zs -- reading BorderDoom's cached per-weapon stat
// arrays via array-element field reflection, NOT the mutating ACS
// GetCurrentDamage family. No tier row, purely supplementary.

// wr_compat_combinedarms.zs -- reading Combined Arms' four classes and all
// of their meters. DECORATE + ACS with no ZScript, so no field reflection
// applies at all -- everything is an inventory item Amount instead, read by
// the owned-item walk, and not one of its ACS scripts is ever called.

// wr_compat_doominfinite.zs -- reading DOOM Infinite's procedural weapon
// generator: rolled damage/rate/spread/pellets/crit, exotic ammo, fire
// modes, alt modules, quirks, overheat and the run's own progression. The
// flagship compat target -- real ZScript, and the only mod here whose rolls
// are fully populated on a weapon still lying on the floor.

// wr_compat_finaldoomer.zs -- reading Final Doomer's nine weapon sets. Pure
// DECORATE + ACS like Combined Arms, so the same owned-item walk rather than
// field reflection. No rarity ladder anywhere across all nine sets, so this
// never touches the title row either.

// wr_compat_modelswapper.zs -- reading OUR OWN ModelSwapper mod, not a
// third-party one. Still zero compile-time dependency, same reflection
// natives as everything else here, but ModelSwapper's own code publishes a
// small bridge of plain fields specifically for this, since we control
// both sides.

// wr_compat_lithium.zs -- reading Lithium's seven characters and 48 weapons.
// Real ZScript, so most of it is ordinary field reflection; armour needs a
// two-level walk through that mod's IDOL container and status effects need a
// ThinkerIterator. No rarity ladder, so no title row.
//
// It is also the only compat file here that CALLS another mod's ACS, behind
// its own off-by-default switch and an exact-version gate -- see the fence
// comment at the bottom of that file for why this one is allowed where
// BorderDoom's equivalent is not.

// wr_stats.zs -- the universal stat resolver. Asks one question per stat
// (damage, rate of fire, accuracy, pellets, magazine) of ANY weapon from any
// mod, and takes the best answer available: the mod's own field, the
// tracker's observation, a curse mask, or nothing. What used to be rsRows().

// wr_stattracker.zs -- kills, shots fired, accuracy, headshots (if that mod
// is loaded), and an observed damage/rate-of-fire estimate for weapons that
// don't already expose a real one. Not a compat file -- nothing else
// computes any of this, so it's tracked from scratch, per weapon INSTANCE,
// off this wheel's own EventHandler.

// Wrist rig -- weapon cards in a ring around one hand, taken by pointing at
// one and pulling the trigger, or by reaching into it.
//
// TWO WAYS IN, and they are not rivals. The beam is for a card across the
// ring; the hand is for the one you are already at. When both answer, the hand
// wins -- you had to put it there, so it is the more deliberate act. Reaching
// is switched off with wr_touch 0, which leaves the beam alone.
//
// BBF_FIXED only, still. Camera-facing panels are tested against the wrong
// orientation and TouchBillboard on one reports a hit from anywhere in the
// room, so cards are oriented by hand every tic instead.
//
// THIS NEEDS ENGINE CHANGES, and the note here used to say it did not. It also
// used to say groups were unusable because group scale moved the picture
// without moving the hit box and a group scaled to zero stayed clickable --
// both true, both found by this mod, and both fixed in the fork (see its
// FORK_CHANGES.md section 22). The cards are grouped objects now, and the
// billboard roll axis, the VR input suppression, the borrowed laser and the
// haptics were all added for this.

// Lives outside the EventHandler on purpose.
//
// Everything declared inside an EventHandler inherits play scope, and
// InputProcess is ui -- so a helper it needs cannot live there, whatever
// qualifiers you decorate it with. A plain class is data scope and callable
// from either side. This is the same shape Gearbox uses for the same reason.
class wr_Keybind
{
	static bool isKeyFor(int key, string command)
	{
		Array<int> keys;
		bindings.GetAllKeysForCommand(keys, command);

		uint nKeys = keys.Size();
		for (uint i = 0; i < nKeys; ++i)
		{
			if (keys[i] == key) return true;
		}
		return false;
	}
}

// =====================================================================
// wr_RigService -- the SAME public door as wr_Rig's own block below,
// reachable by a caller that does not know wr_Rig exists.
//
// wr_Rig itself cannot BE this: it is already an EventHandler, and
// ZScript has no multiple inheritance. Without this adapter, another
// mod's only way to reach the rig would be `wr_Rig(EventHandler.Find(
// "wr_Rig"))` -- a CAST, which needs the wr_Rig CLASS NAME at compile
// time, not just at runtime. That line compiles fine here, where this
// file defines wr_Rig, and fails EVERYWHERE ELSE the moment
// RS_WeaponWheel.pk3 is not loaded -- which is exactly the situation
// this mod being split into its own repo was supposed to make normal.
// A soft runtime dependency would have quietly become a hard
// compile-time one.
//
// Service is the engine's own answer (wadsrc/static/zscript/engine/
// service.zs): declaring a subclass is enough -- InitServices() walks
// every loaded class once and auto-instantiates every Service
// descendant, keyed by class name, so a caller reaches this through
// ServiceIterator.Find("wr_RigService").Next() and never writes the
// word wr_Rig at all. That file compiles whether or not this pk3 is
// present. (Not Service.Find -- that overload takes class<Service>, an
// actual type, so a string literal there still needs the class to
// exist at compile time.)
//
// Requests answered:
//   GetInt("IsOpen")            -- 1 if the wheel is open, 0 otherwise
//   GetInt("OpenHand")          -- 0 main / 1 off; meaningless if closed
//   GetDouble("RingClearance")  -- map units; live wr_radius/wr_scale,
//                                  not a guess
//   GetObject("HoveredWeapon", objectArg: PlayerPawn) -- the Weapon the
//                                  wheel is pointed at for that pawn, or
//                                  null
// =====================================================================
class wr_RigService : Service
{
	private wr_Rig Rig() const
	{
		return wr_Rig(EventHandler.Find("wr_Rig"));
	}

	// Neither the scope keyword nor the parameter defaults are restated
	// on an override -- both are inherited from Service's own virtual
	// declaration, and repeating either is a compile error, not a
	// harmless echo of it.
	override int GetInt(String request, string stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let rig = Rig();
		if (!rig) return 0;
		if (request == "IsOpen")   return rig.IsOpen() ? 1 : 0;
		if (request == "OpenHand") return rig.OpenHand();
		// Separate from IsOpen on purpose: the wheel can report open
		// before it has resolved WHERE it is. mAnchor is set once, lazily,
		// the first WorldTick after opening (wr_Rig: "if (!mHaveAnchor)
		// {...}") -- so a caller building on the SAME tic the wheel just
		// opened can read a real IsOpen=1 alongside a still-placeholder
		// (0,0,0) anchor, if the caller's own WorldTick happens to run
		// before the wheel's in that tic's handler order. A card built on
		// that placeholder bakes itself at the wrong point forever, since
		// nothing else triggers a rebuild afterward -- confirmed as the
		// actual cause of "the card never shows up at all".
		if (request == "HasAnchor") return rig.HasAnchor() ? 1 : 0;
		return 0;
	}

	override double GetDouble(String request, string stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let rig = Rig();
		if (!rig) return 0.0;
		if (request == "RingClearance") return rig.RingClearance();

		// The anchor's three components, not a Vector3 -- Service's typed
		// getters do not have one. AnchorX/Y/Z answer 0 together when the
		// wheel is closed (wr_Rig.Anchor() already folds that in), so a
		// caller checking IsOpen first never has to special-case "the
		// anchor is not real yet" a second time here.
		//
		// Stored in a local first -- ZScript will not dereference a field
		// straight off a function call's return value ("Unable to
		// dereference left side of X"), only off an actual variable.
		if (request == "AnchorX" || request == "AnchorY" || request == "AnchorZ")
		{
			Vector3 a = rig.Anchor();
			if (request == "AnchorX") return a.X;
			if (request == "AnchorY") return a.Y;
			return a.Z;
		}
		if (request == "AnchorYaw") return rig.AnchorYaw();
		return 0.0;
	}

	override Object GetObject(String request, string stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let rig = Rig();
		if (!rig) return null;
		if (request == "HoveredWeapon") return rig.HoveredWeapon(PlayerPawn(objectArg));
		return null;
	}
}

class wr_Rig : EventHandler
{
	// Geometry, all in map units.
	const RING_RADIUS   = 26.0;   // how far the panels orbit the wrist
	const RING_RISE     = 10.0;   // how far above it they sit
	const PANEL_W       = 15.0;
	const PANEL_H       = 11.0;
	const SPREAD_DEG    = 26.0;   // angle between adjacent panels
	const MAX_PANELS    = 9;
	// The pointer's volumetric cone lives on its OWN slot. Unslotted it took 0 and fought
	// RS_Lance there; the torch holds 1, the Lance keeps 0 (its fog look), the wheel 2.
	const VOLBEAM_SLOT  = 2;
	const TOUCH_RANGE   = 9.0;    // fingertip radius
	const HOVER_REPEAT  = 6;      // tics before a held hand re-triggers

	bool  mOpen;
	int   mRigHand;               // hand wearing the rig (1 = off)
	int   mPokeHand;              // hand doing the reaching (0 = main)

	Array<int>   mIds;
	Array<int>   mPlates;         // the visible card; mIds are the invisible hit quads
	Array<int>   mLabels;
	Array<int>   mIcons;
	Array<int>   mAmmos;          // the count under the name
	// CLASS<INVENTORY>, NOT CLASS<WEAPON>, since the ring stopped being only
	// weapons. Every Weapon IS an Inventory, so the weapon page pushes the
	// same values it always did and every downstream read still resolves --
	// the widening only costs a cast in the one place that genuinely needs a
	// Weapon back out (see HoveredClass).
	Array<Class<Inventory> > mTypes;

	// PARALLEL TO mTypes. Empty means "ask the class for its tag", which is
	// every weapon and every inventory item. The model page fills it, because
	// a model is not an actor at all and has no class to ask -- it is a row
	// on ModelSwapper's shelf, and its name is the only thing it has.
	Array<string> mCardLabel;
	Array<int>   mCardSlots;      // which slot each card stands for
	// Decided ONCE, in gatherWeapons(), from the weapon count against
	// wr_subcards_max -- not re-read as a live cvar elsewhere, because
	// whether THIS build of the ring collapsed is a fact about the cards
	// already spawned, not a setting that can change out from under them
	// mid-ring. expandSlot()'s dwell trigger reads this, not the cvar.
	bool         mFansEnabled;
	Array<int>   mCardColor;      // resolved once at build -- see cardColorFor()

	// The card's colour when nothing is happening to it. Not a constant, because
	// a dry weapon rests a different colour from a loaded one -- and hovering off
	// a card has to put back THAT colour rather than the one every card shares.
	Array<int>   mBaseColor;

	// Icon dimensions as fractions of the card, worked out once at spawn from the
	// texture's real shape. Two arrays because ZScript's dynamic arrays do not
	// take a Vector2.
	Array<double> mIconW;
	Array<double> mIconH;
	Array<double> mLabelH;        // measured so the name fits its card
	Array<double> mAmmoW;         // bezel width, from what the readout says
	// True when this card's ammo is loaded but under wr_lowammo_frac --
	// computed once at build time from the SAME ammoLoaded() call the
	// readout itself already makes, not a fresh per-tic Weapon lookup.
	// Read every tic by the gauge's own shimmer (layout()), never
	// written there.

	Array<bool> mLowAmmo;

	int mOpenTics;                // drives the grow-in

	Array<int> mAccents;          // the slot-coloured bar along the card's top
	Array<int> mGauges;           // BB_BAR: ammo as a proportion
	Array<int> mFaces;            // one painted canvas texture per card
	Array<int> mShadows;          // one dark quad behind each card
	Array<int> mSlotNums;         // the key you would press, on the card it maps to
	Array<int> mMarks;            // "you already have this", per card
	Array<int> mStackBadges;      // "+N", when this card is hiding others behind it
	Array<int> mSlotCount;        // how many weapons TOTAL share this card's slot
	// Parallel to mStackBadges/mSlotCount: true when a collapsed card's
	// slot has more than one weapon AND every one of them is dry. Read
	// once at badge-creation time to colour the "+N" red instead of its
	// usual neutral -- a player can see, before spending the dwell to
	// expand a fan, whether there is any point.
	Array<bool> mSlotAllDry;
	Actor      mLight;            // one dynamic light, on the hovered card
	int        mLightGrace;       // tics spent pointing at nothing, before the light actually goes out
	Vector3    mLightLastPos;     // where it was, so a graced tic has somewhere to sit
	color      mLightLastHue;
	Array<Actor> mModels;         // a real weapon model per card, when enabled
	Array<double> mModelFit;      // RSQ: per model, the scale that fits it on its card
	Array<double> mModelDrop;     // RSQ: ...and how far below the card's centre its base sits, at that scale

	// ONE GROUP PER CARD, so a card is an object rather than six loose quads.
	//
	// The group carries an origin and a scale, and the ENGINE resolves the
	// animation per frame -- not at script's 35Hz, which is what the hand-rolled
	// grow was doing and why it stepped. Growth eases out with a slight
	// overshoot and collapse eases in; that curve belongs to the engine and is
	// not a parameter, which is fine, because it is a better curve than the one
	// that was here.
	Array<int> mGroups;
	int mFanGroup;

	// Tics left in the collapse. The billboards outlive closeRig by exactly this
	// long so the ring can fold away instead of blinking out; everything else --
	// the weapon, the laser, the sticks, bullet time -- is handed back
	// immediately, because none of that should wait on an animation.
	int mClosingTics;

	// Set for the closes that cannot afford to linger -- death, level end, and
	// re-opening on the other hand. A ring folding away while the next one is
	// already growing would leave two rings on screen and two sets of handles
	// racing each other to be freed.
	bool mHardClose;

	// Whether the fog slab is ours right now. Tracked rather than assumed,
	// because there is no getter and clearing one we never took would wipe a
	// map's own mist.
	bool mFogHeld;
	bool mBeamHeld;
	bool mSweepHeld;

	// Shapes are a slot allocator, not a global slot, so this one is genuinely
	// ours and -1 means we hold none. Still released explicitly: the allocator
	// wraps and overwrites rather than refusing when it runs out, so a leaked
	// slot is a slot somebody else silently loses later.
	int mShapeSlot;
	bool mWaveHeld;

	// Where each card ended up this tic, so the commit burst can be thrown from
	// the card rather than from the hand. Recorded during layout because that is
	// the only place the position exists -- and read during commit, which
	// happens before the ring is torn down.
	// THREE ARRAYS, NOT ONE OF VECTOR3.
	//
	// ZScript's dynamic arrays take integral base types only -- Array<Vector3>
	// is rejected outright, exactly as Array<Vector2> is for the icon sizes
	// twenty lines up. Read cardPos() rather than indexing these directly.
	Array<double> mCardX;
	Array<double> mCardY;
	Array<double> mCardZ;

	// Which card is flipping as the ring folds, and how long is left of it.
	// Two indices, one clock: a ring index and a fan index are both just
	// "0, 1, 2...", so one field could not say WHICH 2 was taken. Only one
	// thing is ever taken per ring-open, so the clock stays shared.
	int mFlipCard;
	int mSubFlipCard;
	int mFlipTics;

	// THE DATA SHEET -- FAKE, ON PURPOSE, FOR NOW.
	//
	// A single larger panel parked beside the ring. Every value on it is a
	// hardcoded string: this exists to be LOOKED AT in a headset, so the
	// border, the row spacing, the colours and the text size can be judged
	// before any of it is wired to a real weapon. Nothing here reads the
	// hovered card yet.
	int          mSheetPlate;

	// THE SHEET'S OWN HIT TARGET. The visible plate is BBFL_NOHIT and must
	// stay that way -- it sits in the middle of the ring and would otherwise
	// steal reaches meant for cards. So the same trick the cards already use:
	// an invisible quad does the hitting, the visible plate stays unhittable.
	int          mSheetHit;

	// WHICH PAGE THE RING IS SHOWING. Point at the sheet and pull to go
	// forward, alt-fire to go back -- one hand owns the whole interaction,
	// which is why neither is a new keybind: both read the fire buttons you
	// have already bound, the same way selecting a card does.
	int          mPage;
	int          mSheetAccent;
	int          mSheetTitle;
	Array<int>   mSheetRows;
	Array<int>   mSheetBars;
	// Which weapon the rows currently describe, so the sheet is rebuilt when
	// the selector moves and NOT every tic. BB_TEXT carries its string at
	// creation and UpdateBillboard cannot change it, so a text change means
	// destroying and recreating the row billboards -- cheap once per hover,
	// wasteful thirty-five times a second.
	Class<Weapon> mSheetShown;
	bool          mSheetValid;
	// Last tic the sheet's rows were restrung, so live countdowns can be
	// refreshed on a cadence instead of only when the weapon changes.
	int           mSheetBuiltTic;
	// The same, for the inspect card, which has no lock timer at all.
	int           mInspectBuiltTic;
	// What the card was last filled AGAINST, so switching the held weapon or
	// flipping between sheet and compare rebuilds it -- see tickInspect.
	Weapon        mInspectMine;
	bool          mInspectCompare;
	int           mSheetUsed;     // pool slots carrying a row this pass

	// The fan that opens out of a multi-weapon slot.
	Array<int>   mSubIds;
	// The fan's hit quads, one per sub-card. Separate from the plate for the
	// reason spawnPanels states: a billboard draws taller than it is authored,
	// so a quad that is both picture and target has dead bands you can see.
	Array<int>   mSubHits;
	Array<int>   mSubIcons;
	Array<int>   mSubAmmos;
	Array<int>   mSubLabels;
	Array<double> mSubIconW;
	Array<double> mSubIconH;
	Array<int>    mSubAccents;
	Array<int>    mSubMarks;
	Array<int>    mSubBase;      // resting colour, so hover-off restores the right one
	Array<double> mSubAmmoW;
	// Fan-card counterpart to mLowAmmo -- computed the same way, at the
	// same build site, from the same ammoLoaded() call. Without this a
	// low-ammo weapon shown only as an expanded fan sub-card never got
	// the low-ammo pulse at all, only its collapsed/flat counterpart did.
	Array<bool>   mSubLowAmmo;
	Array<double> mSubLabelH;
	Array<Class<Weapon> > mSubTypes;
	// A SUBCARD IS A CARD, PART TWO. mSubBase is the DRY-AWARE resting colour
	// (COLOR_DRY when empty) -- correct for the plate, wrong for a light or a
	// spark burst, which should glow the weapon's true hue even when the gun
	// they belong to is empty. mCardColor is main's equivalent raw array;
	// this is that array's sub-card counterpart.
	Array<int>    mSubColor;
	// Reassembled the same way cardPos() reassembles mCardX/mCardY/mCardZ --
	// ZScript dynamic arrays take integral base types only, so Array<Vector3>
	// does not compile here any more than Array<Vector2> does for icon sizes.
	Array<double> mSubX, mSubY, mSubZ;

	// THE CONSTELLATION'S OWN TWO EXTRAS, both empty and untouched unless
	// wr_constellation is on -- see layoutExpansion's constellation block.
	//
	// mSubLines: one BB_SEAM per satellite, drawn hub-to-star. A seam is a
	// glowing slit whose shader deliberately has no progress term of its own
	// ("the easing, the pause and the reverse all belong to the caller",
	// doombase.zs), which is exactly what a line that draws ITSELF outward
	// from the hub needs -- the width is animated by this file, per tic.
	Array<int>    mSubLines;

	// mStars: the decorative background field. Not cards, not selectable,
	// never hit-tested -- they exist to make the expansion read as a piece of
	// sky rather than a scatter plot. Their count is wr_stars.
	Array<int>    mStars;
	Array<double> mStarX, mStarY;   // fixed offsets in the view plane, per star
	Array<int>    mStarHue;

	//==========================================================================
	// INSPECT MODE -- the data card WITHOUT the ring.
	//
	// The sheet has only ever existed inside the wheel, which makes it
	// useless for the thing it is best at: deciding whether the gun on the
	// floor is better than the one in your hand. You cannot open the wheel
	// AT a weapon in the world -- the wheel shows what you already own.
	//
	// So this is the same sheet, summoned by pointing at a weapon instead.
	// The engine already tracks what each hand's laser is resting on, per
	// hand, every frame (LaserTraceTargetMain/Off -- the same fields
	// RS_Headshots reads to tint the beam), so no new trace is cast and no
	// new engine work was needed.
	//
	// DWELL, NOT INSTANT. Sweeping an arm across a room full of pickups
	// would otherwise flash a card at every one. wr_inspect_dwell tics of
	// rest on the same weapon before it appears -- the same reasoning, and
	// the same shape, as the fan's own dwell.
	// THE COMPARISON CARD'S OWN BILLBOARDS.
	//
	// A separate, wider plate rather than the ordinary sheet with extra rows,
	// because a comparison is a different SHAPE of information: two values
	// per line, which one string per row cannot lay out. Text billboards
	// centre their text and offer no alignment control, so real columns mean
	// real separate billboards -- three pools, each centred within its own
	// narrow strip, which reads as aligned columns.
	Array<int> mCmpLabel;    // stat name, left column
	Array<int> mCmpA;        // the weapon being inspected, middle column
	Array<int> mCmpB;        // what that hand is holding, right column
	int mCmpPlate, mCmpAccent, mCmpTitle, mCmpSub, mCmpHeadA, mCmpHeadB;
	int mCmpUsed;

	// ACTOR, NOT WEAPON, and that is the whole point of the pickup path
	// below: some mods never leave a real weapon lying on the floor. Lithium
	// deletes any unowned weapon actor outright and drops a slot-generic
	// stand-in instead, so a Weapon-typed target could never see one.
	Actor mInspectWpn;       // what is currently being inspected, if anything
	Actor mInspectCand;      // what the laser is resting on right now
	int    mInspectTics;     // how long it has rested there
	int    mInspectHand;     // which hand is pointing (0 main, 1 off)

	// Tics since the current expansion opened. The fan itself needs no such
	// counter -- AnimateBillboardGroup hands its whole easing job to the
	// engine -- but the constellation's lines are drawn by THIS file, one
	// ResizeBillboard per tic, so they need to know how far along the opening
	// actually is. Reset by expandSlot, cleared by collapseSlot.
	int mFanTics;
	int mRebuildTics;             // commitModel: rebuild the page this many tics from now
	Array<int>    mSubShadows;
	Array<int>    mSubGauges;
	int mExpanded;                // index into mIds, or -1
	// A collapsed slot's face is always variants[0] -- first by SetSlot
	// registration order, not by anything the player has actually done.
	// Remembered per slot (index 0..9, matching gatherWeapons' own pass
	// numbering) so the face a player actually reaches for keeps showing
	// up first, rather than making them dwell into the fan every time
	// just to reach their own third variant. Session-lifetime, not
	// per-open -- an EventHandler instance survives level transitions,
	// closing and reopening the ring does not reset what was learned.
	Class<Weapon> mLastPicked[10];
	int mDwellTics;               // how long the hover has sat on one card
	int mCollapseGrace;           // consecutive tics on a genuine off-fan
	                               // hit -- see updateHover's own comment

	// TEMPORARY -- paintFace's own wr_debug prints, throttled to the first
	// tic after each ring-open instead of every tic repaintFaces runs (which
	// is every tic the ring is open, one call per card -- unthrottled this
	// flooded the console past readable, which is why the first debug pass
	// asking for these numbers came back as "WHERE").
	bool mDebugPainted;

	bool  mWantAutoOpen;
	Vector3 mAnchor;              // the ring centre, out in front of the hand
	double  mAnchorYaw;
	bool    mHaveAnchor;
	// A ceiling on ringR (below), set once alongside mAnchor from side
	// traces the forward-only wall check can't see -- a wall to the
	// player's LEFT or RIGHT of where the ring opened. -1 means "no cap
	// found"; 0 is a real, reachable cap (a wall close enough that the
	// margin-adjusted distance floors to zero), so it cannot double as
	// the sentinel. ringR only ever shrinks toward this value, never
	// grows past its own count-driven sizing because of it.
	double  mMaxRingR;
	// The ring's ACTUAL current radius, written once per layout() pass --
	// see the note there ("Ring radius grows with the count so the cards
	// never crowd"). RingClearance() reads this instead of wr_radius
	// alone, so a caller parking something beside the ring gets the
	// count-grown extent, not just the tuned base value. 0 until the
	// first layout() runs, which RingClearance() treats as "use the base
	// radius" rather than as a real, collapsed ring.
	double  mLastRingR;
	// mAimYaw/mAimPitch/mHaveAim went with the angular gain that used them.
	int mHovered;                 // billboard id under the poking hand, 0 = none
	int mHoverTics;
	Vector3 mLastPoke;
	bool mHavePoke;
	int  mLockTics;
	// One-shot guard for the idle-close warning haptic (WorldTick).
	// NOT compared against mLockTics by equality -- wr_locktics and
	// wr_warn_tics are both live-tunable sliders, and a countdown that
	// can start AT OR BELOW its own warning threshold would never pass
	// through exact equality with it. This flag instead fires once the
	// first tic mLockTics is inside the window, however it got there,
	// and resets everywhere mLockTics itself resets.
	bool mWarnedThisOpen;
	bool    mTouching;            // hand is physically inside a card
	// HOW FAR IN FRONT OF THE HAND THE REACHING FINGERTIP SITS, frozen with
	// the anchor. See the touch query in WorldTick for why this exists.
	double  mTouchReach;
	bool    mBtOn;                // we are the ones holding bullet time on

	//==========================================================================
	// THE ONLY THING ANOTHER MOD IS INVITED TO ASK.
	//
	// A weapon stat card -- or anything else that wants "what is the
	// player looking at right now" -- reaches the rig through
	// EventHandler.Find("wr_Rig"), the same way every RS_Main handler
	// finds every other one, and gets exactly three answers: is it open,
	// which hand, and what would commit() equip if pressed right now.
	// Every field above this line stays exactly as unowned as it was --
	// this is the one door, not a hole in the wall.
	//==========================================================================
	bool IsOpen() const   { return mOpen; }
	int  OpenHand() const { return mRigHand; }   // 0 = main, 1 = off -- same as mHand elsewhere in RS

	// Where the ring itself actually is. Resolved ONCE at open and held
	// fixed for as long as the wheel stays open -- see the gate at
	// "if (!mHaveAnchor)" below -- so a caller reading this every tic is
	// not fighting a moving target, only a closed-wheel one (mHaveAnchor
	// false, both calls return the zero vector / zero yaw).
	Vector3 Anchor() const     { return mHaveAnchor ? mAnchor : (0, 0, 0); }
	// Whether Anchor()/AnchorYaw() are answering real data or the
	// placeholder. Open and anchored are NOT the same tic: mHaveAnchor is
	// set lazily on the first WorldTick after the wheel opens, so IsOpen
	// can read true for one tic before this does.
	bool    HasAnchor() const { return mHaveAnchor; }
	double  AnchorYaw() const  { return mHaveAnchor ? mAnchorYaw : 0.0; }

	// The class a press would equip right now -- pulled out of commit()
	// rather than duplicated next to it, so this can never answer a
	// question commit() itself would answer differently. A card from an
	// open fan names one specific weapon; the slot's own card names its
	// first, checked second because a fan's parent card stays hittable
	// while the fan is open and the fan is the more specific answer.
	Class<Weapon> HoveredClass() const
	{
		if (!mOpen || mHovered == 0) return null;

		int sub = subIndexOf(mHovered);
		if (sub >= 0 && sub < mSubTypes.Size())
			return mSubTypes[sub];

		int index = cardIndexOf(mHovered);
		if (index < 0 || index >= mTypes.Size()) return null;

		// Null on a non-weapon page, and that is the useful answer rather
		// than a limitation: every weapon-shaped path downstream (the sheet's
		// stat rows, commit's equip) asks this first, so an inventory item or
		// a model simply never reaches code that would not know what to do
		// with it.
		return (class<Weapon>)(mTypes[index]);
	}

	// The actual instance, resolved against the asking player's own
	// inventory -- the ring only ever shows what pmo already carries, so
	// null here means the wheel is closed or nothing is hovered, not
	// "hovering something they don't own".
	Weapon HoveredWeapon(PlayerPawn pmo) const
	{
		let want = HoveredClass();
		if (!want || !pmo) return null;
		return Weapon(pmo.FindInventory(want));
	}

	// How far the ring's own geometry actually reaches from the hand,
	// right now -- not the RING_RADIUS constant above, which nothing at
	// runtime reads any more. A caller parking something beside the ring
	// (a stat card, say) needs the LIVE number: wr_radius and wr_scale
	// are both player-tunable, so a fixed guess is correct for exactly
	// one setting and wrong for every other.
	//
	// Includes half a panel's own width, because the ring's edge is
	// where the PANELS end, not where their centres orbit.
	// "Ensure the data card can dynamically shift further away in the
	// event the wheel populates with more cards." mLastRingR IS that --
	// layout()'s own live radius, grown past the tuned base whenever the
	// count needs it (see the note there: "eight fit at the tuned
	// distance, twelve push out to keep the same gap between them"). The
	// static wr_radius*wr_scale is only the FLOOR that formula starts
	// from, so reading it alone under-clears a ring that has grown.
	// Falls back to that floor before the first layout() has ever run
	// (mLastRingR still 0), which is the correct answer for an
	// as-yet-unbuilt ring anyway.
	double RingClearance() const
	{
		double baseRadius = cv("wr_radius", 5.0) * cv("wr_scale", 1.0);
		double radius = (mLastRingR > 0.0) ? mLastRingR : baseRadius;
		double panelHalfW = cv("wr_panel_w", 4.2) * cv("wr_scale", 1.0) * 0.5;
		return radius + panelHalfW;
	}

	//==========================================================================
	// Open / close
	//==========================================================================

	// PAGES. Weapons is what the ring has always been. Inventory is every
	// bInvBar item you are carrying -- vanilla's own flag, so it works with
	// no mods at all. Models is ModelSwapper's shelf for the gun in your
	// hand, and exists ONLY when that mod is loaded (see pageCount).
	const PAGE_WEAPONS   = 0;
	const PAGE_INVENTORY = 1;    // RSQ: removed; kept as a number so nothing else renumbers
	const PAGE_MODELS    = 2;

	// Two pages, or three when ModelSwapper is loaded. Asked every time
	// rather than latched: a pk3 cannot appear mid-session, but the compat
	// switch behind it can be turned off from the menu at any point, and a
	// page that is off should stop being reachable immediately rather than
	// at the next level load.
	private int pageCount()
	{
		bool ms; string arche, donor; int pick, cnt;
		// THIS RIG'S HAND, not hand 0. Every other consumer of this shim resolves
		// the hand from the rig -- gatherModels and commitModel both do
		// `(mRigHand == 1) ? 1 : 0`, and the sheet's MODEL row resolves it from
		// whichever hand actually holds the weapon. Only this one asked the main
		// hand and then answered for both.
		//
		// Both ways round were wrong. Off hand has a shelf and the main does not:
		// two pages, so the Models page for the gun actually in that hand is
		// unreachable. Main has one and the off hand does not: three pages, the
		// player pages to Models, gatherModels asks hand 1, gets nothing, and the
		// ring comes up completely empty with no explanation and no fallback.
		// Audit finding #38.
		[ms, arche, pick, cnt, donor] = wr_CompatModelSwapper.StateOf((mRigHand == 1) ? 1 : 0);
		// RSQ: the inventory page is gone (WHEEL_WORK_QUEUE.md item 1, the owner: "i will remove
		// the inventory wheel"). Weapons, plus ModelSwapper's shelf when it is loaded.
		return (ms && cnt > 0) ? 2 : 1;   // a shelf to pick from, not just a model worn
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		// Every peer's handler receives every player's netevents. This rig
		// drives consoleplayer's pawn, so anyone else's wheel binds must not
		// reach it -- the constellation and honeycomb already guard the same
		// way.
		if (e.Player != consoleplayer) return;

		bool blockOpen = false;

		// THE MASTER SWITCH, and it is enforced HERE rather than at every toggle
		// site because this is the single door the ring opens through -- all
		// three binds below land on it.
		//
		//   1  this wheel   (default)
		//   2  the engine's own native wheel
		//   0  neither
		//
		// The mirror onto wr_suppress_native_wheel is (mode != 2), NOT (== 1).
		// The engine reads that cvar by name when its wheel button is pressed
		// (hw_vrwheel.cpp, OpenWheel) and absent means "not suppressed", so
		// mirroring on == 1 would hand you the engine's ring the moment you
		// picked "neither".
		//
		// Written every time rather than latched: it is one cvar assignment on
		// a button press, and a latch would need somewhere to live and a reason
		// to trust it after a save load.
		{
			int mode = 1;
			let mc = CVar.GetCVar("wr_wheel_mode", players[consoleplayer]);
			if (mc) mode = mc.GetInt();

			let sup = CVar.GetCVar("wr_suppress_native_wheel", players[consoleplayer]);
			if (sup) sup.SetBool(mode != 2);

			// Gate ONLY the three open binds. The rest of this handler is the
			// ModelSwapper cycle and the ring's own interaction events; the
			// cycle binds have nothing to do with whether the ring opens, and
			// swallowing them here would turn the master switch into something
			// wider than it says it is.
			if (mode != 1) blockOpen = true;
		}

		// A wheel per hand. Whichever hand you summon it on is the hand that
		// wears it, points at it, and receives what you pick -- so the bind you
		// press already says which hand you meant.
		if (e.Name ~== "wr_toggle_off")  { if (blockOpen) return; toggle(preferredToggleHand(1)); return; }
		if (e.Name ~== "wr_toggle_main") { if (blockOpen) return; toggle(preferredToggleHand(0)); return; }
		if (e.Name ~== "wr_toggle")      { if (blockOpen) return; toggle(1); return; }
		// RSQ: ONE BUTTON. Opens the ring in front of the preferred hand (main unless
		// wr_toggle_prefer_hand says otherwise); with wr_either_hand on, both hands pick from it.
		if (e.Name ~== "wr_toggle_any")  { if (blockOpen) return; toggle(preferredToggleHand(0)); return; }
		// RSQ: HOLD, POINT, RELEASE. The +wr_wheel bind sends its press and its release. Held,
		// the ring is up while the button is down and the release picks whatever is under a hand
		// (or just closes it). Tapped, the ring stays up and works as before. Tapped twice, the
		// last pick's hand goes back to the gun it held before (wr_doubletap).
		if (e.Name ~== "wr_press")       { if (blockOpen && !mOpen) return; pressWheel(e.Args[0] != 0); return; }

		// MODELSWAPPER MODEL CYCLE. Applies to whatever weapon is actually
		// in that hand right now, wheel open or not -- there is no reason
		// to require the ring up just to swap a mesh, and every other bind
		// in this handler already works regardless of mOpen.
		if (e.Name ~== "wr_ms_cycle_main") { wr_CompatModelSwapper.Cycle(0, 1); return; }
		if (e.Name ~== "wr_ms_cycle_off")  { wr_CompatModelSwapper.Cycle(1, 1); return; }


		if (e.Name ~== "wr_grab")
		{
			let pmo = players[consoleplayer].mo;
			if (pmo != null && mOpen && mHovered != 0) commit(pmo);
			return;
		}

		if (e.Name ~== "wr_page")
		{
			let pmo = players[consoleplayer].mo;
			if (pmo == null || !mOpen) return;

			// WRAPS. With only two or three pages there is nowhere far to
			// get lost, and a hard stop at either end would leave the
			// forward-only case (no alt-fire bound at all) unable to come
			// back at all.
			// RSQ: with the inventory page gone the pages are WEAPONS and, with ModelSwapper,
			// MODELS -- so paging is a swap between the two, or nothing with one page.
			int n = pageCount();
			if (n < 2) return;
			mPage = (mPage == PAGE_WEAPONS) ? PAGE_MODELS : PAGE_WEAPONS;

			// A fan belongs to the page that opened it.
			collapseSlot();
			rebuildPage(pmo);
			feedback(Sound("wristrig/tick"), 0.30, 45);
			return;
		}

		if (e.Name ~== "wr_expand")
		{
			// Re-checked server-side, same gates InputProcess already
			// applied client-side, INCLUDING mTouching now -- an event in
			// flight can arrive after state that made it valid has
			// already changed (e.g. the hand drifted onto the card
			// between the client send and this running), and the client
			// gate is specifically the "aiming at range" gesture, not the
			// touch-grab one; missing this check let the at-range gesture
			// fire even after the player was already touching the card.
			let pmo = players[consoleplayer].mo;
			if (pmo != null && mOpen && !mTouching && mHovered != 0 && mFansEnabled
				&& !belongsToExpansion(mHovered))
			{
				int cardIndex = cardIndexOf(mHovered);
				// The sheet's hit quad hovers but is no card: cardIndexOf gives
				// -1, expandSlot(-1) would collapse whatever fan is open and
				// return, and the success test below would then read -1 == -1.
				if (cardIndex < 0) return;
				expandSlot(pmo, cardIndex);
				// mExpanded == cardIndex, not a before/after mSubIds.Size()
				// comparison -- expandSlot() unconditionally collapses any
				// existing fan FIRST, so swapping from an open 4-variant
				// fan to a different 2-variant slot shrinks mSubIds even
				// on a genuine success, and the old size check reported
				// that as failure. expandSlot() only ever sets mExpanded
				// to the index it was asked for once it actually built a
				// fan for it (collapseSlot() resets mExpanded to -1 on
				// every early-return path), so this is the real success
				// signal regardless of the old and new fan's relative size.
				if (mExpanded == cardIndex)
				{
					feedback(Sound("wristrig/tick"), 0.30, 45);
					// The dwell timer would otherwise still be counting
					// toward the same expansion this gesture just did --
					// not wrong, just a wasted tic count sitting there
					// for no reason once the fan is already open.
					mDwellTics = 0;
				}
			}
			return;
		}
	}

	// Fire commits, and never reaches the gun.
	//
	// This has to happen here rather than by reading cmd.buttons in WorldTick:
	// by the time the playsim sees the button the shot is already going to
	// happen, and the only place to stop it is before the press becomes a
	// command at all. Returning true consumes the event.
	//
	// Narrow on purpose -- only while the rig is open AND a card is actually
	// under the hand. Any wider and opening the rig would deaden your trigger.
	override bool InputProcess(InputEvent e)
	{
		if (!mOpen || mHovered == 0) return false;
		if (e.Type != InputEvent.Type_KeyDown) return false;

		// +use WHILE HOVERING, NOT TOUCHING -- pop a fan instantly instead
		// of waiting out DWELL_TO_EXPAND. Deliberately the opposite reach
		// of the grab's own +use case three lines down: that one fires
		// only WHEN mTouching (a hand already on the card), this one only
		// when NOT touching (aiming at range) -- so the same key means two
		// different, non-overlapping things depending on how you are
		// pointing, rather than needing a second bind. Gated identically
		// to the dwell path itself (mFansEnabled, not already expanded)
		// so this can never open something the dwell timer couldn't.
		if (!mTouching && wr_Keybind.isKeyFor(e.KeyScan, "+use")
			&& mFansEnabled && !belongsToExpansion(mHovered)
			&& mHovered != mSheetHit)
		{
			EventHandler.SendNetworkEvent("wr_expand");
			return true;
		}

		// EITHER trigger. The rig is worn and worked by one hand, and which hand
		// that is depends on which key opened it -- so insisting on the main
		// trigger made the off-hand rig unusable with the off-hand controller.
		// Trigger takes it from any distance. Use is the grab, for when your hand
		// is already on the card -- same result, but it is the gesture that fits
		// what you just did with your arm.
		bool fire = wr_Keybind.isKeyFor(e.KeyScan, "+attack")
		         || wr_Keybind.isKeyFor(e.KeyScan, "+oh_attack");
		bool alt  = wr_Keybind.isKeyFor(e.KeyScan, "+altattack")
		         || wr_Keybind.isKeyFor(e.KeyScan, "+oh_altatk");   // the fork's button name (d_main.cpp); "+oh_altattack" does not exist

		// THE SHEET PAGES, THE CARDS SELECT. Both read the fire buttons you
		// already have bound rather than taking binds of their own -- binding
		// alt-fire to a wheel action would COST you alt-fire, since a key
		// does one thing, and the wheel is not worth a weapon function.
		//
		// Consumed either way (return true), so neither shoots through the
		// open ring.
		if (mHovered != 0 && mHovered == mSheetHit)
		{
			if (fire) { EventHandler.SendNetworkEvent("wr_page", 1);  return true; }
			if (alt)  { EventHandler.SendNetworkEvent("wr_page", -1); return true; }
			return false;
		}

		if (!fire && !(mTouching && wr_Keybind.isKeyFor(e.KeyScan, "+use"))) return false;

		EventHandler.SendNetworkEvent("wr_grab");
		return true;
	}


	// A fat-fingered wr_toggle_main/wr_toggle_off shouldn't have to mean
	// "summon on this specific hand" for a player who always means the
	// same hand anyway. wr_toggle_prefer_hand (-1 off, 0 main, 1 off-hand)
	// overrides which hand BOTH binds target, unconditionally while a
	// preference is set -- not just on open.
	//
	// UNCONDITIONAL ON PURPOSE, fixing a real bug the first version of
	// this had: substituting only while nothing was open meant a SECOND
	// press of the exact key that opened the ring (redirected to the
	// other hand by the preference) no longer matched mRigHand in
	// toggle()'s own close check -- pressedHand and mRigHand disagreed,
	// so the "same key again" case fell into the cross-hand MOVE branch
	// instead of closing, contradicting the very point of always meaning
	// one hand. Substituting every time instead means both binds always
	// resolve to the SAME target hand while a preference is active, so
	// toggle()'s own `mRigHand == hand` check is always comparing against
	// that same resolved hand and closes correctly on any repress of
	// either key. The cost: moving an open ring to the OTHER hand isn't
	// reachable while a preference is set -- which is the deliberately
	// intended shape of "I always mean one hand", not a regression.
	// RSQ: the hold / tap / double-tap bind. See NetworkProcess "wr_press".
	int    mPressTic;        // when the button went down
	bool   mPressOpened;     // this press opened the ring (so its release may pick)
	int    mTapTic;          // when the last quick tap opened the ring, for the double tap
	Weapon mPrevWeap[2];     // what each hand held before its last pick off the ring
	int    mLastPickHand;

	private void pressWheel(bool down)
	{
		let pmo = players[consoleplayer].mo;
		if (!pmo) return;
		int now = level.maptime;
		if (down)
		{
			mPressTic = now;
			if (mOpen)
			{
				// a second quick press on a ring a quick tap just opened: back to the last gun
				int dbl = int(cv("wr_doubletap", 10.0));
				bool doubled = dbl > 0 && mTapTic > 0 && now - mTapTic <= dbl;
				mPressOpened = false;
				closeRig(doubled);
				if (doubled) swapToPrevious(pmo);
				mTapTic = 0;
				return;
			}
			openRig(preferredToggleHand(0));
			mPressOpened = mOpen;
			return;
		}
		// released
		if (!mPressOpened || !mOpen) { mPressOpened = false; return; }
		mPressOpened = false;
		int held = now - mPressTic;
		if (held >= int(cv("wr_hold_tics", 9.0)))
		{
			// a card under a hand takes it; the sheet, or nothing, just closes
			bool onCard = mHovered != 0 && mHovered != mSheetHit && (mPage != PAGE_WEAPONS || HoveredClass() != null);
			if (onCard) commit(pmo);
			if (mOpen) closeRig();
			mTapTic = 0;
		}
		else mTapTic = mPressTic;   // a quick tap: the ring stays up, and a second tap may follow
	}

	private void swapToPrevious(PlayerPawn pmo)
	{
		int hand = mLastPickHand;
		let w = mPrevWeap[hand];
		if (!w || w.Owner != pmo) return;
		let now = (hand == 1) ? pmo.player.OffhandWeapon : pmo.player.ReadyWeapon;
		if (hand == 1 && offhandBraced(pmo)) { feedback(Sound("wristrig/nope"), 0.35, 60); return; }
		equipInstantly(pmo, w, hand);
		mPrevWeap[hand] = now;
		feedback(Sound("wristrig/lock"), 0.5, 60);
	}

	// RSQ: both hands point at and pick from the one ring (wr_either_hand, on by default).
	// Off, it is REMA's wheel per hand: the hand that opened it is the only one that picks.
	private bool eitherHand() const { return cvBool("wr_either_hand", true); }

	private int preferredToggleHand(int pressedHand) const
	{
		int pref = int(cv("wr_toggle_prefer_hand", -1.0));
		if (pref != 0 && pref != 1) return pressedHand;
		return pref;
	}

	// Pressing the OTHER hand's key while one is open moves the rig across
	// rather than closing it, for the same reason a menu with two tabs does not
	// make you shut it to change tab.
	//
	// PRESSING THE SAME HAND'S KEY AGAIN, VERY SOON AFTER OPENING,
	// RECENTERS INSTEAD OF CLOSING. The anchor freezes once per open (see
	// layout()) and is never revisited, so a ring that opened facing a
	// wall, or just where your hand happened to be a moment ago, had no
	// way back short of closing and reopening it -- losing whatever you
	// were about to do. Clearing mHaveAnchor alone is the whole mechanism:
	// mOpen, the card arrays, gatherWeapons -- nothing else about the
	// ring's state is touched, so this recenters in place rather than
	// tearing anything down.
	//
	// mOpenTics, not a new timestamp -- it already counts up from 0 every
	// tic since THIS open (it drives the grow-in animation). A same-hand
	// press landing in its first few tics reads as "I just opened this
	// and I am still adjusting", not "I have been looking at this and I
	// am done" -- the two intents that would otherwise collide on the
	// exact same key. Deliberately short (default under a third of a
	// second) so it cannot be mistaken for a normal, considered close:
	// outside that window, the same press closes instantly, exactly as
	// it always has.
	// The two alternate layouts have to reach back here when they commit, to
	// hand the session in. Same shape as their own Get().
	static wr_Rig Get()
	{
		return wr_Rig(EventHandler.Find("wr_Rig"));
	}

	private void toggle(int hand)
	{
		// RSQ: with either hand picking, the ring is not "that hand's" ring -- whichever bind
		// is pressed while it is open closes it (or re-centres it, inside the window below).
		if (mOpen && eitherHand()) hand = mRigHand;

		if (mOpen && mRigHand == hand)
		{
			int window = int(cv("wr_recenter_window", 10.0));
			if (window > 0 && mOpenTics <= window)
			{
				mHaveAnchor = false;
				feedback(Sound("wristrig/move"), 0.30, 40);
				return;
			}
			closeRig();
			return;
		}

		// Moving across hands takes the old ring down HARD. Letting it fold while
		// the new one grows would put two rings in the air at once, each holding
		// handles the other is about to clear.
		if (mOpen) { mHardClose = true; closeRig(); mHardClose = false; }

		openRig(hand);
	}

	private void openRig(int hand)
	{
		let pmo = players[consoleplayer].mo;
		if (pmo == null || players[consoleplayer].playerstate != PST_LIVE) return;

		// A ring still folding away from the last open is finished off now, or
		// its handles leak the moment the arrays below are cleared.
		if (mClosingTics > 0) { destroyPanels(); mClosingTics = 0; }


		// Same hand wears the cards and catches them. Reaching across with your
		// gun hand to arm your other one was backwards: it occupies the hand you
		// need, to fill the hand you do not.
		mRigHand    = hand;
		mPokeHand   = hand;
		mHaveAnchor = false;
		mTwoCmp     = false;
		mPage       = PAGE_WEAPONS;

		gatherWeapons(pmo);
		if (mTypes.Size() == 0) return;

		spawnPanels();
		spawnCardModels(pmo);
		buildSheet();
		buildStars();

		mOpen      = true;
		mHovered   = 0;
		mHoverTics = 0;
		mHavePoke  = false;
		mShapeSlot = -1;
		mExpanded  = -1;   // int fields start at 0, and 0 is card 0, not "no fan"
		mOpenTics  = 0;

		// NOT mCardPos.Clear() -- spawnPanels has already sized it, one entry
		// per card, five lines above. Clearing it here emptied it for the ring's
		// whole life, and everything that asks "where is that card" is guarded
		// by its size, so the hovered-card light and the commit sparks both
		// silently did nothing. Reset lives in destroyPanels, next to the arrays
		// it was built alongside.
		mFlipCard  = -1;
		mSubFlipCard = -1;
		mFlipTics  = 0;
		// Same guard idiom as wr_forward: an unset or fat-fingered value
		// resets to the shipped default rather than doing something with 0
		// or negative. Unguarded, 0 (or less) made WorldTick's
		// --mLockTics <= 0 check true on the very first tic, so the ring
		// flashed open and immediately auto-closed on every single summon
		// -- indistinguishable from the mod being completely broken, and a
		// player reasonably expecting "0 = no idle-close timer" got
		// exactly the opposite. The idle-close is a deliberate safety
		// feature (see the comment at its own check site, WorldTick) --
		// giving 0 a real "never expire" meaning would be removing that
		// safety net by config typo, so this floors instead of disabling.
		mLockTics  = int(cv("wr_locktics", 140));
		if (mLockTics <= 0) mLockTics = 140;
		mWarnedThisOpen = false;
		mDebugPainted = false;


		// Claim the sticks. Snap turn and stick movement are decided in the VR
		// input path before any script sees a button, so without this the same
		// thumbstick that is picking a card also spins and walks you.
		wr_VR.SuppressVRInput(true);
		engineLaser(true);

		bulletTime(true);

		// spawnCentre went with the centre cell -- the data sheet stands there
		// now. See the note in layout() where its positioning used to be.
		layout(pmo);

		// Declared once, resolved per frame. The engine's growth curve eases out
		// with a slight overshoot, which is the little bounce a card gets as it
		// settles -- and it is not a parameter, which is fine: it is a better
		// curve than the cubic that used to be here and it runs at the
		// renderer's rate rather than at script's 35Hz.
		int growTics = int(cv("wr_growtics", 6.0));
		if (growTics > 0)
		{
			for (int i = 0; i < mGroups.Size(); ++i)
			{
				wr_BB.AnimateBillboardGroup(mGroups[i], 0.0, 1.0, growTics);
			}
		}

		feedback(Sound("wristrig/open"), 0.40, 55);

		// WHAT ACTUALLY GOT BUILT, in one line.
		//
		// Deliberately narrow. Anything that fails LOUDLY -- a ring that does
		// not appear, a card in the wrong place -- needs no print, and a print
		// per event is how the console became noise the first time.
		//
		// These are the failures you cannot see. A canvas face falls back to a
		// composed one without a word, so "wr_canvas on and it looks identical"
		// reads exactly like "on and working subtly". An icon that resolves to
		// nothing leaves a blank card with no clue whether the weapon has no
		// pickup sprite or the lookup broke. Counting them is the difference
		// between a diagnosis and another round of guessing.
		if (cv("wr_debug", 0.0) > 0.0)
		{
			int faces = 0, icons = 0;
			for (int i = 0; i < mFaces.Size(); ++i)  { if (mFaces[i] != 0) ++faces; }
			for (int i = 0; i < mIcons.Size(); ++i)  { if (mIcons[i] != 0) ++icons; }

			bool wantCanvas = cv("wr_canvas", 0.0) > 0.0;
			// The ring is over the pool, so nothing was painted BY DESIGN --
			// reported separately below, and kept out of the NONE PAINTED
			// alarm, which means the canvas machinery is broken.
			bool overPool  = wantCanvas && mIds.Size() > FACE_POOL;

			Console.Printf(
				"\c[Gold]RSVR HUD\c- %d cards | plate %s | faces %d/%d%s | icons %d | hand %s",
				mIds.Size(),
				(plateKind() == wr_BB.BB_SDFPANEL) ? "sdf" : "sampled",
				faces, (wantCanvas && !overPool) ? mIds.Size() : 0,
				(wantCanvas && !overPool && faces == 0) ? " \c[Red]NONE PAINTED\c-" : "",
				icons,
				(mRigHand == 1) ? "off" : "main");

			// Named separately because it is the one with a known cause and a
			// known fix, rather than a number to interpret.
			if (wantCanvas && !overPool && faces == 0)
			{
				Console.Printf("\c[Gold]RSVR HUD\c- canvas returned nothing: "
					"WRFACEnn undeclared, or animdefs.txt not loaded");
			}
			if (overPool)
			{
				Console.Printf("\c[Gold]RSVR HUD\c- %d cards over the pool of %d, "
					"whole ring composed -- lower wr_subcards_max to keep it under",
					mIds.Size(), FACE_POOL);
			}
		}
	}


	// quiet is for the close that follows a commit, which has already made the
	// louder noise of its own -- two sounds a frame apart read as a stutter.
	private void closeRig(bool quiet = false)
	{

		// Only if there is a ring to fold: PlayerDied and WorldUnloaded call
		// this unconditionally, and a click plus a buzz on every death and
		// every level exit with nothing on screen is noise.
		if (!quiet && (mOpen || mClosingTics > 0)) feedback(Sound("wristrig/close"), 0.18, 35);

		// THE RING FOLDS AWAY RATHER THAN BLINKING OUT.
		//
		// Everything that belongs to the PLAYER is handed back on this tic --
		// the weapon, the laser, the sticks, bullet time. None of that may wait
		// on an animation; a gun you cannot fire for a fifth of a second because
		// a menu is still playing is a menu that got you killed.
		//
		// Only the billboards linger. The group is told to collapse to zero and
		// the handles are destroyed CLOSE_TICS later by the tick, which is what
		// a group scaled to zero is for: it draws nothing, so the last frame is
		// empty whether or not the destroy has landed yet.
		if (!mHardClose && mIds.Size() > 0 && CLOSE_TICS > 0)
		{
			for (int i = 0; i < mGroups.Size(); ++i)
			{
				wr_BB.AnimateBillboardGroup(mGroups[i], 1.0, 0.0, CLOSE_TICS);
			}
			if (mFanGroup != 0)    wr_BB.AnimateBillboardGroup(mFanGroup,    1.0, 0.0, CLOSE_TICS);

			mClosingTics = CLOSE_TICS;

			// The playsim half of the close happens now regardless.
			let pmoNow = players[consoleplayer].mo;
			engineLaser(false);
			wr_VR.SuppressVRInput(false);
			bulletTime(false);
			releaseDecor();

			mOpen     = false;
			mHovered  = 0;
			mTouching = false;
			return;
		}

		clearCardModels();
		destroyPanels();
	}

	//==========================================================================
	// THE DATA SHEET -- A FAKE ONE.
	//
	// Hardcoded rows, built once with the ring and parked to one side of it.
	// The point is to get a panel of the right SIZE, with a border, rows that
	// do not collide and text that can actually be read at arm's length, in
	// front of a headset -- before any of it is pointed at a real weapon.
	//
	// COMPOSED BILLBOARDS, NOT A CANVAS. A canvas paints in 2D pixel
	// coordinates whose Y axis runs the opposite way to everything else here,
	// which is why this file carries fy()/clearFlipped()/dimFlipped() at all.
	// The last panel this project tried was a canvas and drew upside down
	// three separate times. A stack of BB_TEXT billboards has no Y axis to get
	// backwards -- each row is placed in map units like every card is.
	//
	// Every row is its own billboard so it can carry its own colour, which is
	// the whole reason the sheet is worth having over a bigger card.
	//==========================================================================
	// Rebuild the rows when, and only when, the selector lands on a different
	// weapon. Called every tic; returns immediately in the common case.
	private void refreshSheet(PlayerPawn pmo)
	{
		if (mSheetPlate == 0) return;

		// Nothing hovered shows what the hand is already holding -- the same
		// question the centre cell answers, so the sheet is never blank and
		// never stale. Only when that is ALSO empty does it say so.
		Class<Weapon> want = HoveredClass();
		Weapon shown = want ? Weapon(pmo.FindInventory(want)) : null;
		if (shown == null) shown = (mRigHand == 1) ? pmo.player.OffhandWeapon : pmo.player.ReadyWeapon;

		Class<Weapon> nowCls = shown ? shown.GetClass() : null;

		// REBUILT ON A CADENCE, not only when the weapon CHANGES.
		//
		// The per-class gate came from a rationale that is no longer true: it was
		// written when a text change meant destroying and recreating every row
		// billboard, so rebuilding per tic was unthinkable. sheetRow restrings in
		// place with SetBillboardText now, and buildSheetRows' own header says so
		// -- "RESTRUNG, NOT REBUILT ... a hover change costs two calls per row".
		// A stale reason was left guarding a rebuild that had become cheap.
		//
		// The cost of that gate is that every countdown on the sheet is frozen at
		// the value it held when the selector landed: RELOADING, DESPAWN, SPELL
		// CD, OVERHEATED, DODGE, INVULN, and every HEAT/MANA/HP meter. The
		// DESPAWN row's own comment calls it "the row with a deadline on it".
		// Audit findings #25 and #40.
		//
		// Every SHEET_TICK tics rather than every tic: a second's worth of rows is
		// what a countdown printed in whole seconds can actually show, and it
		// keeps the rebuild off the hot path for the other nine tics in ten.
		bool due = (level.maptime - mSheetBuiltTic) >= SHEET_TICK;
		if (mSheetValid && nowCls == mSheetShown && !due) return;
		mSheetBuiltTic = level.maptime;

		mSheetShown = nowCls;
		mSheetValid = true;
		buildSheetRows(shown);
	}

	// THE ROWS, FROM THE WEAPON ITSELF.
	//
	// Engine fields only. Every value here exists on Weapon or Inventory, so
	// this reads a gun from a mod that has never heard of this one -- which is
	// the floor the sheet has to clear before any provider is asked anything.
	//
	// A SHORT SHEET IS THE HONEST ONE. Rows the engine cannot answer are not
	// drawn as "--"; they are absent. Seven rows of dashes claims the data was
	// expected and is missing, when the truth is the engine never had it.
	// THE LITHIUM ROWS, split out of buildSheetRows for register budget --
	// see the call site. Returns whether it claimed the sheet's single
	// gauge, which the caller needs in order to leave the bar alone.
	private bool lithiumRows(Weapon w)
	{
		// LITHIUM -- seven characters, 48 weapons, no rarity ladder. See
		// wr_compat_lithium.zs. Everything here needs a CARRIED weapon:
		// that mod deletes any weapon actor with no owner, so there is
		// nothing on the floor to read.
		bool liName; string liNameRow;
		[liName, liNameRow] = wr_CompatLithium.NameOf(w);
		if (liName)
		{
			bool liWho; int liPc; string liDis;
			[liWho, liPc, liDis] = wr_CompatLithium.CharacterOf(w);
			sheetRow(liWho && liDis.Length()
			           ? String.Format("%s  --  %s", liNameRow, liDis)
			           : liNameRow, SHEET_TEXT);
		}

		// Magazine, as ROUNDS LEFT. Lithium stores shots SPENT and counts
		// up, so this is already inverted for us by the reader.
		bool liMag; int liMagN, liMagMax;
		[liMag, liMagN, liMagMax] = wr_CompatLithium.MagazineOf(w);
		if (liMag)
			sheetRow(String.Format("MAG %d/%d", liMagN, liMagMax),
			         (liMagN == 0) ? color(COLOR_AMMO_DRY) : color(SHEET_TEXT));

		bool liAmmo; string liAmmoWord; int liAmmoN, liAmmoMax;
		[liAmmo, liAmmoWord, liAmmoN, liAmmoMax] = wr_CompatLithium.AmmoOf(w);
		if (liAmmo)
			sheetRow(String.Format("%s %d/%d", liAmmoWord, liAmmoN, liAmmoMax),
			         (liAmmoN == 0) ? color(COLOR_AMMO_DRY) : color(SHEET_MEAS));

		bool liAds; string liAdsWord;
		[liAds, liAdsWord] = wr_CompatLithium.AdsOf(w);
		if (liAds) sheetRow(liAdsWord, SHEET_MEAS);

		// The one row here built for a WHEEL rather than a HUD: this ticks
		// on a gun you are NOT holding, which is exactly what browsing the
		// ring is for.
		bool liAr; int liArSec;
		[liAr, liArSec] = wr_CompatLithium.AutoReloadOf(w);
		if (liAr) sheetRow(String.Format("RELOADING %ds", liArSec), SHEET_DIM);

		bool liStat; string liStatRow;
		[liStat, liStatRow] = wr_CompatLithium.StatusOf(w);
		if (liStat) sheetRow(liStatRow, SHEET_HOT);

		// Mana takes the gauge for the CyberMage. It can never contend with
		// the other three claims on it -- a weapon belongs to one mod, and
		// within Lithium only a CyberMage has mana at all.
		bool liMana; int liManaN, liManaMax;
		[liMana, liManaN, liManaMax] = wr_CompatLithium.ManaOf(w);
		bool liTookBar = false;
		if (liMana && liManaMax > 0 && (liManaN > 0 || wr_CompatLithium.IsManaBattery(w)))
		{
			color mc = (liManaN >= liManaMax) ? color(SHEET_HOT)
			         : (liManaN * 4 < liManaMax) ? color(COLOR_AMMO_DRY) : color(SHEET_MEAS);
			sheetRow(String.Format("MANA %d/%d", liManaN, liManaMax), mc);
			setSheetBar(liManaN * 100 / liManaMax, mc, true);
			liTookBar = true;
		}

		// Cercle is the one spell with a genuine binary ready-state: it
		// fires only at exactly full mana and then spends all of it.
		bool liCer, liCerReady;
		[liCer, liCerReady] = wr_CompatLithium.CercleOf(w);
		if (liCer)
			sheetRow(liCerReady ? "READY" : "NEEDS FULL MANA",
			         liCerReady ? color(SHEET_HOT) : color(SHEET_LOCK));

		bool liCost, liCostReload; int liCostN;
		[liCost, liCostN, liCostReload] = wr_CompatLithium.SpellCostOf(w);
		if (liCost && liCostN > 0)
			sheetRow(String.Format("COST %d%s", liCostN, liCostReload ? " / RELOAD" : ""), SHEET_DIM);
		else if (liCost)
			sheetRow("COST FREE", SHEET_DIM);

		if (wr_CompatLithium.IsManaBattery(w))
			sheetRow("BATTERY  +4 MANA / 0.2s", SHEET_DIM);

		bool liHeat, liHeatLock; int liHeatN, liHeatMax;
		[liHeat, liHeatN, liHeatMax, liHeatLock] = wr_CompatLithium.SmgHeatOf(w);
		if (liHeat && (liHeatN > 0 || liHeatLock))
		{
			color hc = liHeatLock ? color(COLOR_AMMO_DRY)
			         : (liHeatN * 2 >= liHeatMax) ? color(SHEET_HOT) : color(SHEET_MEAS);
			sheetRow(String.Format("HEAT %d/%d%s", liHeatN, liHeatMax,
			         liHeatLock ? "  LOCKED" : ""), hc);
			if (!liTookBar) { setSheetBar(liHeatN * 100 / liHeatMax, hc, true); liTookBar = true; }
		}

		// SPREAD, not accuracy -- this is a multiplier where LOWER IS
		// BETTER, so it never goes near the universal accuracy resolver.
		bool liSpr; double liSprN, liSprWorst;
		[liSpr, liSprN, liSprWorst] = wr_CompatLithium.SmgSpreadOf(w);
		if (liSpr && liSprN > 0.1)
			sheetRow(String.Format("SPREAD %.2fx", liSprN),
			         (liSprN >= 0.6) ? color(COLOR_AMMO_DRY) : color(SHEET_MEAS));

		bool liIon, liIonVent; double liIonC;
		[liIon, liIonC, liIonVent] = wr_CompatLithium.IonChargeOf(w);
		if (liIon)
			sheetRow(String.Format("CHARGE %.2f  %d DMG%s", liIonC, int(liIonC * 300.0),
			         liIonVent ? "  WILL VENT" : ""),
			         liIonVent ? color(COLOR_AMMO_DRY) : color(SHEET_HOT));

		bool liSpin; double liSpinU; int liSpinRate;
		[liSpin, liSpinU, liSpinRate] = wr_CompatLithium.WindUpOf(w);
		if (liSpin)
			sheetRow(String.Format("SPIN %d%%  %d TIC/SHOT", int(liSpinU * 100.0), liSpinRate), SHEET_HOT);

		bool liKh, liKhOn;
		[liKh, liKhOn] = wr_CompatLithium.KhandaOf(w);
		if (liKh && liKhOn) sheetRow("SKILL POWER  50x DAMAGE", SHEET_HOT);

		// The Kampilan's stacks. Excluded from the magazine row on purpose:
		// same field, opposite polarity -- here higher is BETTER.
		bool liCmb; int liCmbN, liCmbMax, liCmbCd;
		[liCmb, liCmbN, liCmbMax, liCmbCd] = wr_CompatLithium.ComboOf(w);
		if (liCmb && liCmbN > 0)
			sheetRow(String.Format("COMBO %d/%d  +%d%% DMG", liCmbN, liCmbMax, liCmbN * 10), SHEET_HOT);

		bool liRems; int liRemsN, liRemsMax;
		[liRems, liRemsN, liRemsMax] = wr_CompatLithium.RemsOf(w);
		if (liRems)
			sheetRow(String.Format("VENTING %d/%d", liRemsN, liRemsMax), SHEET_LOCK);

		// "LAST CHARGE" rather than a live meter, because the field is not
		// cleared after firing and a live label would be a lie.
		bool liShr; int liShrN, liShrPellets;
		[liShr, liShrN, liShrPellets] = wr_CompatLithium.ShrapnelOf(w);
		if (liShr)
			sheetRow(String.Format("LAST CHARGE %d  %d PELLETS", liShrN, liShrPellets), SHEET_DIM);

		bool liFall; int liFallNow, liFallBase;
		[liFall, liFallNow, liFallBase] = wr_CompatLithium.FalloffOf(w);
		if (liFall && liFallNow < liFallBase)
			sheetRow(String.Format("DAMAGE %d  (BASE %d)", liFallNow, liFallBase),
			         (liFallNow * 2 < liFallBase) ? color(COLOR_AMMO_DRY) : color(SHEET_MEAS));

		bool liFist; int liFistN;
		[liFist, liFistN] = wr_CompatLithium.ChargeFistOf(w);
		if (liFist) sheetRow(String.Format("CHARGE %d", liFistN), SHEET_HOT);

		bool liRa; string liRaRow;
		[liRa, liRaRow] = wr_CompatLithium.ReactiveArmorOf(w);
		if (liRa) sheetRow("REACTIVE " .. liRaRow, SHEET_MEAS);

		bool liGren; int liGrenN; string liGrenMode;
		[liGren, liGrenN, liGrenMode] = wr_CompatLithium.GrenadeOf(w);
		if (liGren) sheetRow(String.Format("LOADED %d/8  %s", liGrenN, liGrenMode), SHEET_TEXT);

		bool liTube, liTubeReady;
		[liTube, liTubeReady] = wr_CompatLithium.GrenadeTubeOf(w);
		if (liTube)
			sheetRow(liTubeReady ? "GRENADE READY" : "GRENADE SPENT",
			         liTubeReady ? color(SHEET_HOT) : color(SHEET_LOCK));

		bool liMs; int liMsN, liMsMax;
		[liMs, liMsN, liMsMax] = wr_CompatLithium.MissileSpinOf(w);
		if (liMs) sheetRow(String.Format("SPIN %d/%d", liMsN, liMsMax), SHEET_MEAS);

		// 0 MEANS READY here -- this counter runs the other way from every
		// other one on the card.
		bool liDodge; int liDodgeN, liDodgeMax;
		[liDodge, liDodgeN, liDodgeMax] = wr_CompatLithium.DodgeOf(w);
		if (liDodge)
			sheetRow(liDodgeN <= 0 ? "DODGE READY"
			                       : String.Format("DODGE %.1fs", liDodgeN / 35.0),
			         liDodgeN <= 0 ? color(SHEET_HOT) : color(SHEET_LOCK));

		bool liIf; int liIfN;
		[liIf, liIfN] = wr_CompatLithium.IFramesOf(w);
		if (liIf) sheetRow(String.Format("INVULN %.1fs", liIfN / 35.0), SHEET_HOT);

		bool liSpt, liSptOn;
		[liSpt, liSptOn] = wr_CompatLithium.SprintOf(w);
		if (liSpt && liSptOn) sheetRow("SPRINTING", SHEET_DIM);

		bool liArm; string liArmName; int liArmSave;
		[liArm, liArmName, liArmSave] = wr_CompatLithium.ArmorOf(w);
		if (liArm) sheetRow(String.Format("%s  SAVE %d", liArmName, liArmSave), SHEET_MEAS);

		bool liDf; int liDfPct;
		[liDf, liDfPct] = wr_CompatLithium.DamageFacOf(w);
		if (liDf) sheetRow(String.Format("DAMAGE TAKEN -%d%%", liDfPct), SHEET_MEAS);

		bool liShd; int liShdN;
		[liShd, liShdN] = wr_CompatLithium.ShieldOf(w);
		if (liShd) sheetRow(String.Format("SHIELD %d", liShdN), SHEET_MEAS);

		// Speed is a raw percent whose BASELINE DIFFERS PER CHARACTER (the
		// Dark Lord's is 45), so it is never coloured as a debuff for being
		// under 100 and never compared across characters.
		bool liSpd; int liSpdPct;
		[liSpd, liSpdPct] = wr_CompatLithium.SpeedOf(w);
		if (liSpd) sheetRow(String.Format("SPEED %d%%", liSpdPct), SHEET_DIM);

		// The ACS-sourced rows. Off by default, exact-version gated, and
		// self-latching on a canary failure -- see the fence comment in
		// wr_compat_lithium.zs.
		bool liAttr; string liAttrRow;
		[liAttr, liAttrRow] = wr_CompatLithium.AttributesOf(w);
		if (liAttr) sheetRow(liAttrRow, SHEET_TEXT);

		bool liUpg; int liUpgN, liUpgMax;
		[liUpg, liUpgN, liUpgMax] = wr_CompatLithium.UpgradesOf(w);
		if (liUpg) sheetRow(String.Format("UPGRADES %d/%d", liUpgN, liUpgMax), SHEET_TEXT);

		bool liRm; string liRmWord;
		[liRm, liRmWord] = wr_CompatLithium.RifleModeOf(w);
		if (liRm) sheetRow("FIRE MODE " .. liRmWord, SHEET_TEXT);

		bool liSig, liSigHas;
		[liSig, liSigHas] = wr_CompatLithium.SigilOf(w);
		if (liSig && liSigHas) sheetRow("SIGIL", SHEET_HOT);

		return liTookBar;
	}

	// RSQ: THE SERIES, ASKED BY NAME -- each row only when that mod is loaded and has an answer.
	//   RSQ TacticalRig     where this gun is holstered (RSQTR_RigService "rig.holster")
	//   RSQ Gun Bonsai VR   its Gun Bonsai level, progress and upgrades (WR_Bonsai, wr_q_bonsai.zs)
	private void seriesRows(Weapon w)
	{
		let pmo = players[consoleplayer].mo;
		Service svc;
		let it = ServiceIterator.Find("RSQTR_RigService");
		while (svc = it.Next())
		{
			int r = svc.GetInt("rig.holster", w.GetClassName(), 0, 0, pmo);
			if (r >= 0) { sheetRow("HOLSTER  " .. svc.GetString("rig.regionname", "", r), 0xC8A060); break; }
		}
		if (cv("wr_sheet_bonsai", 1.0) > 0.0) bonsaiRows(pmo, w);
	}

	// RSQ: GUN BONSAI (wr_q_bonsai.zs). "GUN BONSAI LV n  p%", then one row per upgrade, its name as
	// Gun Bonsai shows it and its level as a numeral; one switched off in Gun Bonsai's status menu is
	// dimmed. At most BONSAI_ROWS upgrade rows, so the ammo rows below always keep their place on the
	// nine-row sheet: past that the last row says how many more there are.
	const BONSAI_ROWS = 4;
	private void bonsaiRows(PlayerPawn pmo, Weapon w)
	{
		int lv = WR_Bonsai.Level(pmo, w);
		if (lv < 0) return;
		sheetRow(String.Format("GUN BONSAI LV %d  %d%%", lv, clamp(WR_Bonsai.Progress(pmo, w) / 10, 0, 100)), 0x70D060);
		Array<String> names, classes; Array<int> levels, maxes; Array<bool> on;
		int n = WR_Bonsai.UpgradesFull(pmo, w, names, levels, maxes, classes, on);
		for (int i = 0; i < n; ++i)
		{
			if (i == BONSAI_ROWS - 1 && n > BONSAI_ROWS)
			{
				sheetRow(String.Format("  +%d MORE", n - i), SHEET_DIM);
				break;
			}
			string nm = names[i].MakeUpper();
			if (nm.CodePointCount() > 20) nm = nm.Left(19) .. ".";
			sheetRow("  " .. nm .. "  " .. WR_Bonsai.Numeral(levels[i]), on[i] ? color(0xA8E890) : color(SHEET_DIM));
		}
	}

	private void buildSheetRows(Weapon w)
	{
		// RESTRUNG, NOT REBUILT. SetBillboardText retexts a live BB_TEXT and
		// UpdateBillboard recolours it, so a hover change costs two calls per
		// row instead of destroying and recreating every billboard on the
		// panel. mSheetUsed is how many of the pool are carrying a row this
		// pass; the rest are blanked rather than removed, so the pool is
		// allocated once for the life of the ring and the row slots never move
		// under the reader.
		mSheetUsed = 0;

		string title = w ? ("" .. w.GetTag()) : "EMPTY";
		color  tint  = w ? tierColorOf(w) : color(SHEET_DIM);

		if (mSheetTitle != 0)
		{
			wr_BB.SetBillboardText(mSheetTitle, title);
			wr_BB.UpdateBillboard(mSheetTitle, 0, tint);
		}
		if (mSheetAccent != 0) wr_BB.UpdateBillboard(mSheetAccent, 0, tint);

		if (w == null)
		{
			sheetRow("(empty hand)", SHEET_DIM);
			setSheetBar(0, SHEET_MEAS, false);   // no weapon, no condition/heat gauge
			blankRestOfSheet();
			return;
		}

		// RS DATA, READ STRAIGHT OFF THE WEAPON.
		//
		// Not through RS_Main's own RS_WeaponInfoService, and that is a
		// deliberate refusal rather than an oversight. The builder that
		// service serves (RS_Screens.zs:638-650) prints a cursed stat's real
		// value with only a colour change or a "  [LOCKED]" suffix beside it
		// -- the exact pattern its own sibling records as deleted at
		// :276-281, "which gives the whole thing away". A consumer reading
		// through it inherits the leak and cannot detect it, because the
		// number arrives already formatted.
		//
		// Reflection reads the LockedX flags themselves, so the mask is
		// decided here from the fact rather than inferred from a colour. It
		// is also exact where the service is fragile: the DPS row it serves
		// carries no lock tell at all (:641), so no consumer could mask it
		// even if it tried.
		int tier;
		bool isRS = wr_Field.GetFieldInt(w, "Tier", tier);

		// LegenDoom has no field this fork's reflection natives can read --
		// see wr_compat_legendoom.zs -- so this is checked independently of
		// isRS rather than folded into the same GetFieldInt call.
		bool isLD; int ldRarity;
		[isLD, ldRarity] = wr_CompatLegenDoom.RarityOf(w);

		bool isDRLA; int drlaTier;
		[isDRLA, drlaTier] = wr_CompatDRLA.TierOf(w);

		// Doomablo's generatedRarity IS a plain field, same shape as isRS
		// above -- but a different field name on a different mod's class,
		// so it still needs its own GetFieldInt call rather than reusing
		// "Tier".
		bool isDBL; int dblRarity;
		[isDBL, dblRarity] = wr_CompatDoomablo.RarityOf(w);

		// DOOM Infinite's flavour quirk, the fifth and last mod that gets to
		// name the title row. Not a numeric ladder like the four above -- see
		// wr_compat_doominfinite.zs on why the quirk NAME is the only
		// reachable quality axis -- but it is a real earned property of the
		// weapon and reads exactly like a rarity to a player.
		bool isDI; color diCol; string diWord;
		[isDI, diCol, diWord] = wr_CompatDoomInfinite.FlavorOf(w);

		// HANDLING RIDES THE TOP ROW rather than taking one of its own. Nine
		// row slots is the hard ceiling before content draws off the plate,
		// and a two-handed magazine weapon needs every one of them -- so the
		// one- or two-word handling note goes where there is already space.
		string hands = handlingOf(w);

		if (isRS)
			sheetRow(hands.Length() ? (tierWord(tier) .. "  " .. hands) : tierWord(tier),
			         tierColorOf(w));
		else if (isLD)
			sheetRow(hands.Length() ? (wr_CompatLegenDoom.RarityWord(ldRarity) .. "  " .. hands)
			                        : wr_CompatLegenDoom.RarityWord(ldRarity),
			         tierColorOf(w));
		else if (isDRLA)
			sheetRow(hands.Length() ? (wr_CompatDRLA.TierWord(drlaTier) .. "  " .. hands)
			                        : wr_CompatDRLA.TierWord(drlaTier),
			         tierColorOf(w));
		else if (isDBL)
			sheetRow(hands.Length() ? (wr_CompatDoomablo.RarityWord(dblRarity) .. "  " .. hands)
			                        : wr_CompatDoomablo.RarityWord(dblRarity),
			         tierColorOf(w));
		else if (isDI)
			sheetRow(hands.Length() ? (diWord .. "  " .. hands) : diWord, tierColorOf(w));
		else if (slotOf(w) >= 1 && slotOf(w) <= 9)
			sheetRow(hands.Length() ? String.Format("SLOT %d  %s", slotOf(w), hands)
			                        : String.Format("SLOT %d", slotOf(w)), SHEET_DIM);

		// AMMO. The label is the ammo TYPE, because "this eats the same cells
		// as what I am holding" is a real reason to pick one gun over another
		// and it costs no extra row.
		//
		// NO DENOMINATOR. The obvious one, Ammo2.MaxAmount, is the ammo
		// CLASS's default rather than this weapon's capacity -- ammo classes
		// are routinely given headroom over it, so a full magazine would print
		// as a fraction of something it never reaches. A count with no
		// denominator is true; a fraction against the wrong ceiling is not.
		seriesRows(w);   // RSQ: what the other Radiant Silvergun mods know about this gun

		if (w.Ammo1 == null && w.Ammo2 == null)
		{
			sheetRow("AMMO          --", SHEET_DIM);
		}
		else
		{
			string atag = ammoLabel(w);
			int loaded  = ammoLoaded(w);
			// Ammo1 null, Ammo2 live (a free primary whose alt-fire spends its
			// own pool): ammoLoaded's -1 sentinel was being printed as a count.
			if (loaded < 0 && w.Ammo2 != null) loaded = w.Ammo2.Amount;
			if (loaded < 0) loaded = 0;

			sheetRow(String.Format("%s %d", atag, loaded),
			         loaded == 0 ? color(COLOR_AMMO_DRY) : color(SHEET_HOT));

			// The reserve behind a magazine. Only where there IS a magazine --
			// otherwise the loaded count already IS the reserve and printing
			// it twice reads as twice the ammo.
			if (hasMagazine(w) && w.Ammo1 != null)
				sheetRow(String.Format("RESERVE %d", w.Ammo1.Amount), SHEET_COOL);
		}

		// SHOTS, not rounds -- the one derived number worth the arithmetic.
		// Nobody decides on "186 cells"; they decide on "that is four shots".
		int use = w.default.AmmoUse1;
		int loadedForShots = ammoLoaded(w);   // -1 for a floor weapon (no Ammo1)
		if (use > 1 && loadedForShots >= 0)
		{
			int shots = loadedForShots / use;
			sheetRow(String.Format("SHOTS %d  (%d/ea)", shots, use), SHEET_MEAS);
		}

		// LegenDoom's rolled effects -- independent of ldRarity above, same
		// reasoning as DRLA's mods below: read straight off the held
		// weapon's own owned items, not gated on rarity having been found.
		string ldEffects = wr_CompatLegenDoom.EffectsOf(w);
		if (ldEffects.Length() > 0)
			sheetRow("EFFECT " .. ldEffects, SHEET_TEXT);

		// DRLA's Mod Station upgrades -- independent of drlaTier above, see
		// wr_compat_drla.zs, since a mod's own name is built from the held
		// weapon's class rather than its tier.
		int drlaModMask, drlaModMask2;
		[drlaModMask, drlaModMask2] = wr_CompatDRLA.ModsOf(w);
		if (drlaModMask != 0)
			sheetRow("MOD " .. wr_CompatDRLA.ModsWord(drlaModMask, drlaModMask2), SHEET_TEXT);

		// Pandemonia Insurrection's augments, durability, Superior text,
		// color tag, combo bar and the Sacrosanct Aeonstave's own leveling
		// -- see wr_compat_pandemonia_insurrection.zs. No tier concept in
		// this mod, so none of this touched the title row above; every one
		// of these is purely supplementary, each independently gated the
		// same way DRLA's mod row is.
		bool hasAugs; int curAugs, maxAugs;
		[hasAugs, curAugs, maxAugs] = wr_CompatPandemoniaInsurrection.CountOf(w);
		if (hasAugs && curAugs > 0)
		{
			string breakdown = wr_CompatPandemoniaInsurrection.BreakdownOf(w);
			sheetRow(breakdown.Length() ? String.Format("AUG %d/%d  %s", curAugs, maxAugs, breakdown)
			                            : String.Format("AUG %d/%d", curAugs, maxAugs), SHEET_TEXT);
		}

		bool hasColTag; string colTag;
		[hasColTag, colTag] = wr_CompatPandemoniaInsurrection.ColorTagOf(w);
		if (hasColTag)
			sheetRow("TAG " .. colTag, SHEET_TEXT);

		bool hasDuraI; int duraI, duraMaxI; bool duraBrokenI;
		[hasDuraI, duraI, duraMaxI, duraBrokenI] = wr_CompatPandemoniaInsurrection.DurabilityOf(w);
		if (hasDuraI)
			sheetRow(String.Format("DURA %d/%d", duraI, duraMaxI),
			         duraBrokenI ? color(SHEET_LOCK)
			                     : (duraMaxI > 0 && duraI * 4 < duraMaxI) ? color(COLOR_AMMO_DRY) : color(SHEET_MEAS));

		bool hasSup; string supText;
		[hasSup, supText] = wr_CompatPandemoniaInsurrection.SuperiorOf(w);
		if (hasSup)
			sheetRow("SUPERIOR " .. (supText.Length() > 26 ? (supText.Left(23) .. "...") : supText), SHEET_HOT);

		bool hasCombo; int comboCur, comboMax;
		[hasCombo, comboCur, comboMax] = wr_CompatPandemoniaInsurrection.ComboOf(w);
		if (hasCombo)
			sheetRow(String.Format("COMBO %d/%d", comboCur, comboMax),
			         comboCur >= comboMax ? color(SHEET_HOT) : color(SHEET_MEAS));

		bool hasAeon; int aeonLvl, aeonChg;
		[hasAeon, aeonLvl, aeonChg] = wr_CompatPandemoniaInsurrection.AeonstaveOf(w);
		if (hasAeon)
			sheetRow(String.Format("AEON LVL %d  %d/%d", aeonLvl, aeonChg, wr_CompatPandemoniaInsurrection.AEON_CHARGE_MAX),
			         SHEET_TEXT);

		// Base Pandemonia's own durability/magazine/sidegrade system --
		// see wr_compat_pandemonia.zs. A completely separate field set
		// from Insurrection's above (different class hierarchy), so at
		// most one of the two DURA rows can ever fire for a given weapon
		// -- they share the same label on purpose, since the player is
		// never looking at both mods' weapons in the same hand at once.
		// ONLY IF INSURRECTION DID NOT ALREADY PRINT ONE.
		//
		// The comment above is wrong and was wrong by construction: the two
		// DurabilityOf functions are byte-identical -- same cvar gate, same four
		// reflected field names, no class check anywhere. Reflection is BY NAME,
		// so whichever weapon satisfies one satisfies the other, and every
		// durable Pandemonia weapon printed DURA twice, adjacent and identical.
		// Both copies also burned a slot from a fixed pool that silently drops
		// overflow. Audit finding #36.
		bool hasDuraP; int duraP, duraMaxP; bool duraBrokenP;
		[hasDuraP, duraP, duraMaxP, duraBrokenP] = wr_CompatPandemonia.DurabilityOf(w);
		if (hasDuraP && !hasDuraI)
			sheetRow(String.Format("DURA %d/%d", duraP, duraMaxP),
			         duraBrokenP ? color(SHEET_LOCK)
			                     : (duraMaxP > 0 && duraP * 4 < duraMaxP) ? color(COLOR_AMMO_DRY) : color(SHEET_MEAS));

		bool hasMagP; int magCurP, magMaxP;
		[hasMagP, magCurP, magMaxP] = wr_CompatPandemonia.MagazineOf(w);
		if (hasMagP)
			sheetRow(String.Format("MAG %d/%d", magCurP, magMaxP), SHEET_MEAS);

		bool hasSideP, s1P, s2P; string sideLabelP;
		[hasSideP, s1P, s2P, sideLabelP] = wr_CompatPandemonia.SidegradesOf(w);
		if (hasSideP)
			sheetRow(sideLabelP.Length() ? String.Format("SIDEGRADE %d/2  %s", (s1P ? 1 : 0) + (s2P ? 1 : 0), sideLabelP)
			                             : String.Format("SIDEGRADE %d/2", (s1P ? 1 : 0) + (s2P ? 1 : 0)), SHEET_TEXT);

		// Pandemonia-family player level, and Anarchy's Anarchic Sigil --
		// both PLAYER-side, independent of which family weapon (base,
		// Anarchy, or Insurrection) is actually in hand, so both are
		// called unconditionally the same way Doomablo's LevelOf() is.
		bool hasGameLvl; int gameLvl;
		[hasGameLvl, gameLvl] = wr_CompatPandemonia.GameLevelOf(w);
		if (hasGameLvl)
			sheetRow(String.Format("GAME LEVEL %d", gameLvl), SHEET_TEXT);

		bool hasSigil; int sigilLvl, sigilPts, sigilPtsMax; bool sigilCd;
		[hasSigil, sigilLvl, sigilPts, sigilPtsMax, sigilCd] = wr_CompatPandemoniaAnarchy.SigilOf(w);
		if (hasSigil)
			sheetRow(sigilPtsMax > 0 ? String.Format("SIGIL LVL %d  %d/%d", sigilLvl, sigilPts, sigilPtsMax)
			                        : String.Format("SIGIL LVL %d  MAX", sigilLvl),
			         sigilCd ? color(SHEET_LOCK) : color(SHEET_HOT));

		// Guncaster's player-side resource pools -- see wr_compat_guncaster.zs.
		// No per-weapon tier in this mod at all, so this reads the weapon's
		// OWNER, not the weapon, for every field.
		bool hasCd; double spellCd;
		[hasCd, spellCd] = wr_CompatGuncaster.SpellCooldownOf(w);
		if (hasCd)
			sheetRow(String.Format("SPELL CD %.1fs", spellCd), SHEET_LOCK);

		string gcRes = wr_CompatGuncaster.ResourcesOf(w);
		if (gcRes.Length() > 0)
			sheetRow(gcRes, SHEET_TEXT);

		// MetaDoom's plasma rifle heat and Unmaker demon keys -- see
		// wr_compat_metadoom.zs. Neither is a tier either.
		bool hasHeat; int heat, heatShots;
		[hasHeat, heat, heatShots] = wr_CompatMetaDoom.HeatOf(w);
		if (hasHeat)
			sheetRow(heat >= 5 ? "HEAT 5/5  OVERCHARGE READY"
			                   : String.Format("HEAT %d/5  (%d/10)", heat, heatShots % 10),
			         heat >= 5 ? color(SHEET_HOT) : color(SHEET_MEAS));

		bool hasKeys; int keys;
		[hasKeys, keys] = wr_CompatMetaDoom.KeysOf(w);
		if (hasKeys)
			sheetRow(String.Format("KEYS %d/3", keys), keys > 0 ? color(SHEET_HOT) : color(SHEET_DIM));

		// Doomablo's PLAYER advancement -- see wr_compat_doomablo.zs. A
		// second axis independent of the weapon's own rarity above, so
		// checked and shown regardless of whether this weapon rolled a
		// rarity at all.
		bool hasLvl; int dblLvl; double dblXp, dblXpNext; int dblPoints;
		[hasLvl, dblLvl, dblXp, dblXpNext, dblPoints] = wr_CompatDoomablo.LevelOf(w);
		if (hasLvl)
			sheetRow(String.Format("LVL %d  %.0f/%.0f XP%s", dblLvl, dblXp, dblXpNext,
			                       dblPoints > 0 ? String.Format("  +%d PTS", dblPoints) : ""),
			         dblPoints > 0 ? color(SHEET_HOT) : color(SHEET_MEAS));

		bool hasInferno; int inferno;
		[hasInferno, inferno] = wr_CompatDoomablo.InfernoLevelOf(w);
		if (hasInferno)
			sheetRow(String.Format("INFERNO %d", inferno), SHEET_TEXT);

		// Doomablo's five rolled player stats -- array-element reflection,
		// same as BorderDoom below. Vitality/CritChance/CritDmg/Strength
		// are already effective values (base + item bonuses); RareFind
		// isn't a combat stat but belongs with the others, same array.
		bool hasStats; int dblVit, dblCrc, dblCrd, dblStr, dblRf;
		[hasStats, dblVit, dblCrc, dblCrd, dblStr, dblRf] = wr_CompatDoomablo.StatsOf(w);
		if (hasStats)
		{
			sheetRow(String.Format("VIT %d  STR %d  FIND %d", dblVit, dblStr, dblRf), SHEET_TEXT);
			sheetRow(String.Format("CRIT %d%%  CRITDMG %d%%", dblCrc, dblCrd), SHEET_TEXT);
		}

		// BorderDoom's cached per-weapon stats -- see wr_compat_borderdoom.zs.
		// Read off the ARRAY the mutating GetCurrentDamage family writes
		// into, never the ACS calls themselves. No tier row -- BorderDoom
		// has no rarity system, confirmed, and "LVL" here is a rolled
		// weapon-instance stat, not a colour-worthy rarity tier.
		bool hasBD; int bdDmg, bdAcc, bdRof, bdRcl, bdClip, bdLvl;
		[hasBD, bdDmg, bdAcc, bdRof, bdRcl, bdClip, bdLvl] = wr_CompatBorderDoom.StatsOf(w);
		// Only the LEVEL row survives here. BorderDoom's damage, accuracy,
		// rate of fire and clip size are now resolved by wr_stats.zs along
		// with every other mod's, so printing them again would duplicate
		// rows statRows() already draws. Recoil is dropped outright: it
		// models a crosshair kick, which describes the game aiming for you,
		// and in VR your hand is the aim.
		if (hasBD)
			sheetRow(String.Format("BD LEVEL %d", bdLvl), SHEET_TEXT);

		// DOOM INFINITE -- see wr_compat_doominfinite.zs. The flagship
		// target: its rolled stats already fed the universal rows above
		// (damage, rate of fire, pellets, crit all resolve DECLARED from
		// it), so everything here is the axes those rows cannot carry.
		//
		// THE NAME FIRST. subName is the generator's own loot name, built
		// from the weapon's quirks -- "LEGENDARY DEMONIC SUPER SHOTGUN" --
		// and it is the single line that tells a player what they are
		// looking at before any number does.
		bool diName; string diFullName;
		[diName, diFullName] = wr_CompatDoomInfinite.NameOf(w);
		if (diName) sheetRow(diFullName, tierColorOf(w));

		// SPREAD gets its own row rather than feeding the universal
		// ACCURACY one, and that is deliberate: this mod stores spread in
		// tenths of a degree where LOWER is better, while every accuracy
		// figure elsewhere on this sheet is higher-is-better. Mixing them
		// would light the worse weapon green on the comparison card.
		bool diSpr; double diSpread;
		[diSpr, diSpread] = wr_CompatDoomInfinite.SpreadOf(w);
		if (diSpr) sheetRow(String.Format("SPREAD %.1f DEG", diSpread), SHEET_MEAS);

		// The three axes the generator actually rolls -- exotic ammo, an
		// alternate fire mode, an alt-fire module. All three arrive as
		// finished display strings from the mod itself.
		bool diLoad; string diLoadout;
		[diLoad, diLoadout] = wr_CompatDoomInfinite.LoadoutOf(w);
		if (diLoad) sheetRow(diLoadout, SHEET_TEXT);

		bool diQ; string diQuirks;
		[diQ, diQuirks] = wr_CompatDoomInfinite.QuirksOf(w);
		if (diQ) sheetRow(diQuirks, SHEET_HOT);

		// AMMO COST, only where a shot costs more than one. Exotic ammo
		// types multiply the blueprint cost, and the mod shows only the
		// quirk word for it, never the number.
		bool diCost; int diAmmoCost;
		[diCost, diAmmoCost] = wr_CompatDoomInfinite.AmmoCostOf(w);
		if (diCost) sheetRow(String.Format("AMMO COST %d/SHOT", diAmmoCost), SHEET_MEAS);

		// JAM ODDS. Only ever shown on a weapon that actually carries the
		// JAMMING quirk -- the field exists on every weapon but can only
		// fire on that one, so printing it elsewhere would be a warning
		// about something that cannot happen. The mod shows the word and
		// never the odds.
		bool diJam; int diJamPct;
		[diJam, diJamPct] = wr_CompatDoomInfinite.JamOf(w);
		if (diJam) sheetRow(String.Format("JAM %d%%", diJamPct), COLOR_AMMO_DRY);

		// WHAT THIS WEAPON CAN NEVER BE RE-MODDED INTO -- a real reason to
		// leave it on the floor, and nothing in the game says so.
		bool diLock; string diLocks;
		[diLock, diLocks] = wr_CompatDoomInfinite.LocksOf(w);
		if (diLock) sheetRow("LOCKED " .. diLocks, SHEET_LOCK);

		// THE SUPERCHARGER. While this is above zero the weapon deals
		// TRIPLE damage, and the game communicates that with sparks alone.
		bool diOc; int diOcVal, diOcMax;
		[diOc, diOcVal, diOcMax] = wr_CompatDoomInfinite.OverchargeOf(w);
		if (diOc)
			sheetRow(String.Format("OVERCHARGE %d/%d  x3 DMG", diOcVal, diOcMax), SHEET_HOT);

		// THE ARENA DESPAWN CLOCK, and the row with a deadline on it. A
		// dropped weapon vanishes thirty seconds after its round ends, and
		// the only tell in-game is the sprite slowly going translucent.
		bool diDesp; int diLeft;
		[diDesp, diLeft] = wr_CompatDoomInfinite.DespawnOf(w);
		if (diDesp)
			sheetRow(String.Format("DESPAWN %ds", diLeft),
			         diLeft <= 10 ? color(COLOR_AMMO_DRY) : color(SHEET_DIM));

		// HEAT TAKES THE GAUGE, same as Combined Arms' BlastMaster below --
		// and they can never contend for it, since a weapon belongs to one
		// mod or the other. A full 0-100 model the mod tracks and then shows
		// the player nothing but smoke for.
		bool diHeat; int diHeatVal; double diHeatPct;
		[diHeat, diHeatVal, diHeatPct] = wr_CompatDoomInfinite.HeatOf(w);
		if (diHeat)
		{
			color hc = (diHeatPct >= 0.8) ? color(COLOR_AMMO_DRY)
			         : (diHeatPct >= 0.5) ? color(SHEET_HOT) : color(SHEET_MEAS);
			sheetRow(String.Format("HEAT %d/%d", diHeatVal, wr_CompatDoomInfinite.HEAT_MAX), hc);
			setSheetBar(int(diHeatPct * 100.0), hc, true);
		}

		// THE RUN ITSELF -- player-side, so shown regardless of which
		// weapon is under the selector, the same way Doomablo's level is.
		bool diRun; int diMaps, diLoops;
		[diRun, diMaps, diLoops] = wr_CompatDoomInfinite.RunOf(w);
		if (diRun)
			sheetRow(diLoops > 0 ? String.Format("MAP %d  LOOP %d", diMaps, diLoops)
			                     : String.Format("MAP %d", diMaps), SHEET_TEXT);

		bool diStats; int diDmgPct, diSpdPct, diLuck;
		[diStats, diDmgPct, diSpdPct, diLuck] = wr_CompatDoomInfinite.StatsOf(w);
		if (diStats)
			sheetRow(String.Format("DMG %d%%  SPD %d%%  LUCK %d", diDmgPct, diSpdPct, diLuck),
			         SHEET_TEXT);

		bool diPerk; int diPerks;
		[diPerk, diPerks] = wr_CompatDoomInfinite.PerksOf(w);
		if (diPerk) sheetRow(String.Format("PERKS %d", diPerks), SHEET_TEXT);

		// THE PERKS THEMSELVES, newest first. Deep into a run this list is
		// thirty entries long and the card has room for a few, so the ones
		// worth the space are the ones just taken -- the rest become a
		// "+N MORE" tail rather than silently vanishing.
		bool diPL; string diPerkList;
		[diPL, diPerkList] = wr_CompatDoomInfinite.PerkListOf(w, 3);
		if (diPL) sheetRow(diPerkList, SHEET_DIM);

		// The active item, as its cooldown rather than its name -- the name
		// table is a second `static const` of twenty-five strings and the
		// row reads fine without it, since what decides whether you think
		// about an active right now is whether it is ready.
		bool diAct; string diActName; int diActCount, diActCd, diActCdMax;
		[diAct, diActName, diActCount, diActCd, diActCdMax] = wr_CompatDoomInfinite.ActiveOf(w);
		if (diAct)
			sheetRow(diActCd > 0 ? String.Format("ACTIVE %ds  x%d", diActCd / 35 + 1, diActCount)
			                     : String.Format("ACTIVE READY  x%d", diActCount),
			         diActCd > 0 ? color(SHEET_LOCK) : color(SHEET_HOT));

		// HEALTH AGAINST THE RUN'S OWN CEILING, not vanilla maxhealth. The
		// mod recomputes an effective max every tick and lets health EXCEED
		// it -- that overshoot is its overheal model, so a naive percentage
		// would read over 100 and clip.
		bool diHp; int diHpNow, diHpMax, diHpRegen;
		[diHp, diHpNow, diHpMax, diHpRegen] = wr_CompatDoomInfinite.HealthOf(w);
		if (diHp)
		{
			string over = (diHpNow > diHpMax) ? "  OVERHEAL" : "";
			string reg  = (diHpRegen != 0) ? String.Format("  %+d/s", diHpRegen) : "";
			sheetRow(String.Format("HP %d/%d%s%s", diHpNow, diHpMax, over, reg),
			         (diHpNow * 4 < diHpMax) ? color(COLOR_AMMO_DRY) : color(SHEET_TEXT));
		}

		bool diAp; int diApNow, diApMax, diApRegen;
		[diAp, diApNow, diApMax, diApRegen] = wr_CompatDoomInfinite.ArmorOf(w);
		if (diAp && (diApNow > 0 || diApRegen != 0))
			sheetRow(String.Format("ARMOR %d/%d%s", diApNow, diApMax,
			         diApRegen != 0 ? String.Format("  %+d/s", diApRegen) : ""), SHEET_MEAS);

		bool diBuf; string diBuffs;
		[diBuf, diBuffs] = wr_CompatDoomInfinite.BuffsOf(w);
		if (diBuf) sheetRow(diBuffs, SHEET_HOT);

		// Debuffs print either their remaining seconds (armed) or their
		// build-up meter (still filling) -- see the compat file. The meter
		// is a "you are about to be poisoned" warning the mod never shows.
		bool diDeb; string diDebuffs;
		[diDeb, diDebuffs] = wr_CompatDoomInfinite.DebuffsOf(w);
		if (diDeb) sheetRow(diDebuffs, COLOR_AMMO_DRY);

		// Arena wave progress. Both halves read zero in Classic, where there
		// is no wave, which gates this off without needing to know the mode.
		bool diWav; int diWavKilled, diWavMax;
		[diWav, diWavKilled, diWavMax] = wr_CompatDoomInfinite.WaveOf(w);
		if (diWav) sheetRow(String.Format("WAVE %d/%d", diWavKilled, diWavMax), SHEET_TEXT);

		bool diTal; int diKills, diMapKills, diShots;
		[diTal, diKills, diMapKills, diShots] = wr_CompatDoomInfinite.TallyOf(w);
		if (diTal)
			sheetRow(String.Format("RUN %d KILLS  MAP %d", diKills, diMapKills), SHEET_DIM);

		// Combined Arms -- see wr_compat_combinedarms.zs. Four classes with
		// four different resource systems, so which of these rows answer at
		// all depends on who the player is, not on which weapon is under the
		// selector. No tier concept, so none of it touches the title row.
		//
		// BLASTMASTER HEAT TAKES THE GAUGE when it applies. The sheet has one
		// bar and it belongs to RS Weapon's Condition -- but a BlastMaster is
		// by definition not holding an RS Weapon gun, so the two can never
		// contend for it, and heat is the one reading in this mod that is
		// genuinely a fill rather than a number.
		bool caHeat; int caH, caHMax, caOver;
		[caHeat, caH, caHMax, caOver] = wr_CompatCombinedArms.HeatOf(w);
		if (caHeat)
		{
			if (caOver > 0)
			{
				// Heat itself has been zeroed by the mod at this point, so
				// showing it would read as a cool, healthy gun during the
				// exact twenty seconds the player cannot fire.
				sheetRow(String.Format("OVERHEATED  %ds", caOver / 70 + 1), SHEET_LOCK);
				setSheetBar(100, color(SHEET_LOCK), true);
			}
			else
			{
				string hw = wr_CompatCombinedArms.HeatWord(caH);
				color hc = (caH >= wr_CompatCombinedArms.HEAT_WARN)  ? color(COLOR_AMMO_DRY)
				         : (caH >= wr_CompatCombinedArms.HEAT_TIER3) ? color(SHEET_HOT)
				                                                     : color(SHEET_MEAS);
				sheetRow(hw.Length() ? String.Format("HEAT %d/%d  %s", caH, caHMax, hw)
				                     : String.Format("HEAT %d/%d", caH, caHMax), hc);
				setSheetBar(caHMax > 0 ? (caH * 100 / caHMax) : 0, hc, true);
			}
		}

		bool caRes; string caResRow;
		[caRes, caResRow] = wr_CompatCombinedArms.ResourceRow(w);
		if (caRes) sheetRow(caResRow, SHEET_TEXT);

		bool caCd; string caCdRow;
		[caCd, caCdRow] = wr_CompatCombinedArms.CooldownRow(w);
		if (caCd) sheetRow(caCdRow, SHEET_LOCK);

		bool caUp; string caUpRow;
		[caUp, caUpRow] = wr_CompatCombinedArms.UpgradeRow(w);
		if (caUp) sheetRow(caUpRow, SHEET_TEXT);

		// The one row here the game itself has no other way of telling the
		// player -- see the compat file's own header. Coloured as a warning
		// because that is what it is.
		bool caExp; string caExpRow;
		[caExp, caExpRow] = wr_CompatCombinedArms.ExpiryRow(w);
		if (caExp) sheetRow(caExpRow, COLOR_AMMO_DRY);

		// Live state Combined Arms tracks and never draws anywhere.
		bool caHid; string caHidRow;
		[caHid, caHidRow] = wr_CompatCombinedArms.HiddenRow(w);
		if (caHid) sheetRow(caHidRow, SHEET_HOT);

		// FINAL DOOMER -- nine weapon sets, one active at a time, no rarity
		// ladder anywhere. See wr_compat_finaldoomer.zs for why coverage is
		// uneven: five sets have real live counters, two are identification
		// only.
		bool fdName; string fdNameRow;
		[fdName, fdNameRow] = wr_CompatFinalDoomer.NameOf(w);
		if (fdName) sheetRow(fdNameRow, SHEET_TEXT);

		// Plutonia Heavy Machine Gun spread, INVERTED like DOOM Infinite's
		// statSpread -- lower is more accurate -- so it is its own row, never
		// fed into the universal Accuracy resolver.
		bool fdSpr; int fdSprN, fdSprMax;
		[fdSpr, fdSprN, fdSprMax] = wr_CompatFinalDoomer.InaccuracyOf(w);
		if (fdSpr)
			sheetRow(String.Format("SPREAD %d/%d", fdSprN, fdSprMax),
			         (fdSprN * 2 >= fdSprMax) ? color(COLOR_AMMO_DRY) : color(SHEET_MEAS));

		bool fdBfg; int fdBfgN, fdBfgMax;
		[fdBfg, fdBfgN, fdBfgMax] = wr_CompatFinalDoomer.BfgChargeOf(w);
		if (fdBfg) sheetRow(String.Format("CHARGE %d/%d", fdBfgN, fdBfgMax), SHEET_HOT);

		bool fdFc; int fdFcStage;
		[fdFc, fdFcStage] = wr_CompatFinalDoomer.FistComboOf(w);
		if (fdFc)
			sheetRow(fdFcStage >= 2 ? "COMBO 2/2  UPPERCUT" : String.Format("COMBO %d/2", fdFcStage), SHEET_HOT);

		bool fdBu; int fdBuN, fdBuMax;
		[fdBu, fdBuN, fdBuMax] = wr_CompatFinalDoomer.BurstOf(w);
		if (fdBu) sheetRow(String.Format("BURST %d/%d", fdBuN, fdBuMax), SHEET_TEXT);

		bool fdHal; string fdHalWord;
		[fdHal, fdHalWord] = wr_CompatFinalDoomer.HaldermanOf(w);
		if (fdHal) sheetRow("MODE " .. fdHalWord, SHEET_TEXT);

		bool fdMag; int fdMagL, fdMagR, fdMagMax;
		[fdMag, fdMagL, fdMagR, fdMagMax] = wr_CompatFinalDoomer.MagnumsOf(w);
		if (fdMag) sheetRow(String.Format("L %d/%d  R %d/%d", fdMagL, fdMagMax, fdMagR, fdMagMax), SHEET_TEXT);

		bool fdPump; int fdPumpN, fdPumpMax;
		[fdPump, fdPumpN, fdPumpMax] = wr_CompatFinalDoomer.PumpOf(w);
		if (fdPump) sheetRow(String.Format("PUMP %d/%d", fdPumpN, fdPumpMax), SHEET_TEXT);

		bool fdC4; int fdC4N, fdC4Max;
		[fdC4, fdC4N, fdC4Max] = wr_CompatFinalDoomer.C4Of(w);
		if (fdC4) sheetRow(String.Format("C4 CHARGES %d/%d", fdC4N, fdC4Max), (fdC4N > 0) ? color(SHEET_HOT) : color(SHEET_TEXT));

		bool fdVc; int fdVcStage;
		[fdVc, fdVcStage] = wr_CompatFinalDoomer.VendettaComboOf(w);
		if (fdVc)
			sheetRow(fdVcStage >= 2 ? "COMBO 2/2  HOOK" : String.Format("COMBO %d/2", fdVcStage), SHEET_HOT);

		bool fdSg; int fdSgN, fdSgMax;
		[fdSg, fdSgN, fdSgMax] = wr_CompatFinalDoomer.ShattergunOf(w);
		if (fdSg) sheetRow(String.Format("BURST %d/%d", fdSgN, fdSgMax), SHEET_TEXT);

		bool fdLock; bool fdLocked;
		[fdLock, fdLocked] = wr_CompatFinalDoomer.BfgLockOf(w);
		if (fdLock) sheetRow(fdLocked ? "LOCKED" : "SCANNING", fdLocked ? color(SHEET_HOT) : color(SHEET_MEAS));

		bool fdKat; bool fdKatDrawn; bool fdKatNrg;
		[fdKat, fdKatDrawn, fdKatNrg] = wr_CompatFinalDoomer.KatanaOf(w);
		if (fdKat) sheetRow(fdKatDrawn ? "NRG KATANA  DRAWN" : "NRG KATANA  SHEATHED", SHEET_TEXT);

		bool fdNdl; int fdNdlN, fdNdlMax;
		[fdNdl, fdNdlN, fdNdlMax] = wr_CompatFinalDoomer.NeedlerOf(w);
		if (fdNdl) sheetRow(String.Format("BURST %d/%d", fdNdlN, fdNdlMax), SHEET_TEXT);

		bool fdNano; bool fdNanoOn;
		[fdNano, fdNanoOn] = wr_CompatFinalDoomer.NanoCoreOf(w);
		if (fdNano) sheetRow(fdNanoOn ? "NANOCORE ACTIVE" : "NANOCORE READY", fdNanoOn ? color(SHEET_HOT) : color(SHEET_TEXT));

		bool fdFCh; int fdFChN, fdFChMax;
		[fdFCh, fdFChN, fdFChMax] = wr_CompatFinalDoomer.FistChargeOf(w);
		if (fdFCh) sheetRow(String.Format("CHARGE %d/%d", fdFChN, fdFChMax), SHEET_MEAS);

		bool fdPCh; int fdPChN, fdPChMax;
		[fdPCh, fdPChN, fdPChMax] = wr_CompatFinalDoomer.PistolChargeOf(w);
		if (fdPCh) sheetRow(String.Format("CHARGE %d/%d", fdPChN, fdPChMax), SHEET_MEAS);

		// Whitemare ThermoCoat TAKES THE GAUGE, same as Combined Arms'
		// BlastMaster heat and DOOM Infinite's overload -- all three can
		// never contend for it, a weapon belongs to exactly one mod.
		bool fdHeat; int fdHeatN, fdHeatMax; bool fdHeatOn;
		[fdHeat, fdHeatN, fdHeatMax, fdHeatOn] = wr_CompatFinalDoomer.ThermoCoatOf(w);
		if (fdHeat)
		{
			color hc = fdHeatOn ? color(SHEET_HOT)
			         : (fdHeatN * 2 >= fdHeatMax) ? color(COLOR_AMMO_DRY) : color(SHEET_MEAS);
			sheetRow(String.Format("HEAT %d/%d%s", fdHeatN, fdHeatMax, fdHeatOn ? "  ACTIVE" : ""), hc);
			setSheetBar(fdHeatMax > 0 ? (fdHeatN * 100 / fdHeatMax) : 0, hc, true);
		}

		bool fdWc; int fdWcN, fdWcMax; bool fdWcOver;
		[fdWc, fdWcN, fdWcMax, fdWcOver] = wr_CompatFinalDoomer.WmChaingunOf(w);
		if (fdWc)
			sheetRow(String.Format("SPEED %d/%d%s", fdWcN, fdWcMax, fdWcOver ? "  OVERLOAD" : ""),
			         fdWcOver ? color(COLOR_AMMO_DRY) : color(SHEET_TEXT));

		bool fdWb; int fdWbTics;
		[fdWb, fdWbTics] = wr_CompatFinalDoomer.WmBfgOf(w);
		if (fdWb) sheetRow(String.Format("FIRING %ds", fdWbTics / 35 + 1), SHEET_HOT);

		bool fdWr; int fdWrN, fdWrMax;
		[fdWr, fdWrN, fdWrMax] = wr_CompatFinalDoomer.WmRocketOf(w);
		if (fdWr) sheetRow(String.Format("CHARGE %d/%d", fdWrN, fdWrMax), SHEET_HOT);

		// LITHIUM. Extracted into its own method rather than inlined here:
		// buildSheetRows was already at 229 of 200 registers before Lithium
		// added another forty locals, and ZScript's register budget is per
		// FUNCTION, so the fix is a smaller function rather than fewer rows.
		bool liTookBar = lithiumRows(w);

		// MODELSWAPPER. Only for a weapon actually IN A HAND right now --
		// the bridge only ever tracks the two currently-held weapons, so a
		// browsed-but-not-equipped card has nothing real to show here.
		let sheetPmo = players[consoleplayer].mo;
		let sheetPi = sheetPmo ? sheetPmo.player : null;
		if (sheetPi != null && w != null)
		{
			int msHand = -1;
			if (sheetPi.ReadyWeapon == w)        msHand = 0;
			else if (sheetPi.OffhandWeapon == w) msHand = 1;

			if (msHand >= 0)
			{
				bool msOn; string msArche, msDonor; int msPick, msCount;
				[msOn, msArche, msPick, msCount, msDonor] = wr_CompatModelSwapper.StateOf(msHand);
				if (msOn && msCount > 0)
					sheetRow(String.Format("MODEL %d/%d  %s", msPick + 1, msCount, msDonor), SHEET_MEAS);
				else if (msOn)
					sheetRow("MODEL  " .. msDonor, SHEET_MEAS);   // RSQ: ModelSwapper's service names the model, not a shelf
			}
		}

		// This wheel's own kill/shot/accuracy/headshot tracker -- see
		// wr_stattracker.zs. Everything above this point is a READ of data
		// some other mod already computed; nothing anywhere computes THIS,
		// so it is tracked from scratch off WorldThingDamaged/WorldThingDied/
		// ammo-drain, keyed per weapon INSTANCE, and applies to every weapon
		// on the sheet regardless of which mod (if any) it came from.
		bool hasBasics; int trKills, trShots, trHits;
		[hasBasics, trKills, trShots, trHits] = wr_StatTracker.BasicsOf(w);
		if (hasBasics)
		{
			int acc = trShots > 0 ? (trHits * 100 / trShots) : 0;
			sheetRow(String.Format("KILLS %d  SHOTS %d  ACC %d%%", trKills, trShots, acc), SHEET_TEXT);
		}

		// HEADSHOTS -- only when that mod is actually loaded (Object.FindClass
		// check inside HeadshotsOf()), shown even at zero once it is, the
		// same honesty rule every other conditional row on this sheet
		// follows: present-but-zero is real information, absent is not.
		bool hasHs; int trHs;
		[hasHs, trHs] = wr_StatTracker.HeadshotsOf(w);
		if (hasHs)
		{
			// As a SHARE OF HITS, not of shots. A shot that missed entirely
			// could never have been a headshot, so dividing by shots fired
			// measures aim and accuracy tangled together and reads low for
			// reasons that have nothing to do with where you were aiming.
			// Only shown once there are hits to be a share OF -- until then
			// the bare count is the whole truth.
			// CLAMPED, because the two counters are not bounded the same way and
			// the share of hits could read above 100%.
			//
			// hits is capped at one per detected shot -- it needs a 12-tic window
			// that is closed the moment it fires. headshots has no such window: it
			// counts one per marker inside a 35-tic attribution window with no
			// per-shot cap. So a shotgun blast landing several head pellets is one
			// hit and several headshots, and a headshot arriving 13-35 tics after
			// the shot -- a rocket or a slow bolt in flight -- is a headshot with no
			// hit at all. "HEADSHOTS 5 (500%)" on a headline row is worse than a
			// slightly conservative number. Audit finding #34.
			int hsPct = trHits > 0 ? (trHs * 100 / trHits) : 0;
			if (hsPct > 100) hsPct = 100;
			sheetRow(hasBasics && trHits > 0
			           ? String.Format("HEADSHOTS %d  (%d%%)", trHs, hsPct)
			           : String.Format("HEADSHOTS %d", trHs),
			         trHs > 0 ? color(SHEET_HOT) : color(SHEET_DIM));
		}

		// THE STAT ROWS RUN FOR EVERY WEAPON NOW, not only RS Weapon's.
		// statRows() resolves each stat against whatever can answer it --
		// the mod's own field, the tracker's observation, or nothing -- so a
		// vanilla shotgun gets the same rows as a rolled one, filled from a
		// different place. wr_sheet_stats still switches the whole block off.
		//
		// THE BAR HAS TWO POSSIBLE OWNERS. statRows drives it from Condition
		// (RS Weapon only); the Combined Arms block above drives it from
		// BlastMaster heat. They cannot both apply to one weapon, but the
		// hide-it call has to respect whoever claimed it -- caHeat is that
		// guard, and statRows only ever claims it for a weapon that actually
		// has a Condition.
		bool wantStats = cv("wr_sheet_stats", 1.0) > 0.0;
		if (!caHeat && !diHeat && !fdHeat && !liTookBar) setSheetBar(0, SHEET_MEAS, false);
		if (wantStats) statRows(w);

		blankRestOfSheet();
	}

	// Only the flags that change what your HANDS do -- the part of a pick you
	// feel rather than read. Everything else on Weapon is authoring data.
	private static string handlingOf(Weapon w)
	{
		if (!w) return "";
		string h = "";
		if (w.bMeleeWeapon)    h = "MELEE";
		else if (w.bTwoHanded) h = "2H";
		if (w.bOffhandWeapon)  h = h.Length() ? (h .. "/OFF") : "OFF";
		return h;
	}

	//==========================================================================
	// THE STAT ROWS, FOR EVERY WEAPON RATHER THAN FOR ONE MOD'S.
	//
	// This used to be rsRows(): seven rows that only RS Weapon could fill,
	// while a weapon from any other mod -- or from none -- got almost
	// nothing. Damage, rate of fire, accuracy, magazine and pellets are not
	// RS Weapon's concepts; every weapon in every mod has them, and the only
	// thing that differs is who can tell you the number. wr_stats.zs answers
	// that per stat, so this draws the same rows for a vanilla shotgun and a
	// rolled one and simply fills them from different places.
	//
	// THE CURSE RULES STILL HOLD, and they now live in the resolver rather
	// than here -- a masked stat comes back SRC_MASKED and prints ??? with
	// no number and no bar, and DPS masks with damage because it is derived
	// from it. See wr_stats.zs for the full reasoning; nothing about that
	// promise changed, it just stopped being one mod's special case.
	private void statRows(Weapon w)
	{
		// CONDITION first, and it is the only row here that may carry the
		// gauge: a bar IS the number, so a stat that can be cursed could
		// never have one without leaking what the curse hides. Condition is
		// never cursed.
		int csrc; double cnd;
		[csrc, cnd] = wr_Stats.Condition(w);
		if (csrc == wr_Stats.SRC_DECLARED)
		{
			int pct = int(cnd);
			// BACKFIRE BELOW 20, and nothing else on the sheet says so.
			// RS_Roll.zs:216-232: the 20-29 band is pure upside with
			// backfireChance 0, and the band below it runs 0.20 to 0.35.
			// That edge is the most decision-relevant number on a worn
			// weapon and it has no colour of its own, so it gets a word.
			color ccol = (pct < 20) ? color(SHEET_LOCK)
			           : (pct < 50) ? color(SHEET_HOT) : color(SHEET_MEAS);

			if (pct < 20) sheetRow(String.Format("COND %d%%  BACKFIRE", pct), ccol);
			else          sheetRow(String.Format("CONDITION %d%%", pct), ccol);

			setSheetBar(pct, ccol, true);
		}

		// DPS, masked with damage rather than independently -- see
		// wr_Stats.Dps.
		int dpsSrc, dpsLo, dpsHi;
		[dpsSrc, dpsLo, dpsHi] = wr_Stats.Dps(w);
		if (dpsSrc == wr_Stats.SRC_MASKED)
			sheetRow("DPS  ???", SHEET_LOCK);
		else if (dpsSrc != wr_Stats.SRC_UNKNOWN)
			sheetRow("DPS " .. wr_Stats.Span(dpsLo, dpsHi), SHEET_HOT);

		// DAMAGE as a range -- most weapons roll it, so one figure would be
		// a number the gun cannot actually deal.
		int dSrc, dLo, dHi;
		[dSrc, dLo, dHi] = wr_Stats.Damage(w);
		if (dSrc == wr_Stats.SRC_MASKED)
			sheetRow("DAMAGE  ???", SHEET_LOCK);
		else if (dSrc != wr_Stats.SRC_UNKNOWN)
			sheetRow("DAMAGE " .. wr_Stats.Span(dLo, dHi), SHEET_MEAS);

		// ACCURACY. The declared and observed versions measure genuinely
		// different things -- a gun's spread versus your hit rate with it --
		// so they are worded differently rather than sharing a label that
		// would imply they are the same number from different sources.
		int aSrc; double acc;
		[aSrc, acc] = wr_Stats.Accuracy(w);
		if (aSrc == wr_Stats.SRC_MASKED)
			sheetRow("ACCURACY  ???", SHEET_LOCK);
		else if (aSrc == wr_Stats.SRC_DECLARED)
			sheetRow(String.Format("ACCURACY %d", int(acc)), SHEET_MEAS);
		else if (aSrc == wr_Stats.SRC_OBSERVED)
			sheetRow(String.Format("HIT RATE %d%%", int(acc)), SHEET_MEAS);

		// RATE OF FIRE and PELLETS share a row -- neither can ever be
		// cursed, so neither needs a mask of its own, which is the only
		// thing that would force them onto separate coloured rows.
		int rSrc; double rps;
		[rSrc, rps] = wr_Stats.Rof(w);
		int pSrc, pel;
		[pSrc, pel] = wr_Stats.Pellets(w);

		if (rSrc != wr_Stats.SRC_UNKNOWN)
		{
			string rofTxt = String.Format("ROF %.1f/s", rps);
			// An observed pellet count is a FLOOR -- only the pellets that
			// connected were ever counted -- so it prints with a "+" rather
			// than as a flat claim about the weapon's spread.
			if (pSrc != wr_Stats.SRC_UNKNOWN && pel > 1)
				sheetRow(rofTxt .. String.Format("   PELLETS %d%s", pel,
				         wr_Stats.FloorMark(pSrc)), SHEET_TEXT);
			else
				sheetRow(rofTxt, SHEET_TEXT);
		}

		// MAGAZINE. The loaded count is honest either way -- only CAPACITY
		// can be cursed -- so this is the one row that prints a real number
		// beside a mask rather than replacing the whole value.
		int mSrc, mLoaded, cap;
		[mSrc, mLoaded, cap] = wr_Stats.Magazine(w);
		int magNow = (mLoaded >= 0) ? mLoaded : ammoLoaded(w);   // the mod's own count where it keeps one
		if (mSrc == wr_Stats.SRC_MASKED)
			sheetRow(String.Format("MAG %d / ???", magNow), SHEET_LOCK);
		else if (mSrc != wr_Stats.SRC_UNKNOWN)
			sheetRow(String.Format("MAG %d / %d", magNow, cap), SHEET_TEXT);

		int vSrc; double vel;
		[vSrc, vel] = wr_Stats.Velocity(w);
		if (vSrc == wr_Stats.SRC_MASKED)
			sheetRow("VELOCITY  ???", SHEET_LOCK);
		else if (vSrc != wr_Stats.SRC_UNKNOWN)
			sheetRow(String.Format("VELOCITY %d", int(vel)), SHEET_MEAS);

		int crSrc; double crit;
		[crSrc, crit] = wr_Stats.Crit(w);
		if (crSrc == wr_Stats.SRC_MASKED)
			sheetRow("CRIT  ???", SHEET_LOCK);
		else if (crSrc != wr_Stats.SRC_UNKNOWN)
			sheetRow(String.Format("CRIT %.1f%%", crit), SHEET_MEAS);
	}

	// The tier ladder, in RS_Roll.zs's own declaration order (:12-22). Read as
	// an int because that is what the enum is; a name would need the type.
	private static string tierWord(int t)
	{
		switch (t)
		{
			case 0: return "CURSED";
			case 1: return "TRASH";
			case 2: return "BASIC";
			case 3: return "COMMON";
			case 4: return "UNCOMMON";
			case 5: return "ADVANCED";
			case 6: return "DESIGNER";
			case 7: return "PROTOTYPE";
		}
		return "UNRANKED";
	}

	// The tier's own colour, from RS_Main's single palette, so the sheet never
	// starts a second table that can drift from it.
	//
	// Tier FIRST, ALWAYS -- wr_tier_color does not apply to the sheet. The
	// ring and the sheet answer different questions now: wr_tier_color
	// exists because a ring built mostly from Basic-tier (white, by design)
	// starting gear reads as lifeless, and turning it off trades rarity-at-
	// a-glance for variety on purpose. The owner's own ask, in order: "can
	// we have colored cards all the time and the data card still shows
	// weapon rarity tier thanks to the color of the weapon name" -- the
	// sheet is the ONE place that promise still has to hold even when the
	// ring has stopped making it, so this cannot ask cardColorFor, which
	// would inherit the ring's opt-out. Same fallback (slot palette, then a
	// hashed hue) once tier is off the table, because a weapon with no tier
	// still deserves a real colour and not grey.
	//
	// The int parameter this used to take was never read -- callers already
	// have the tier as an int because reading it is how they know to call
	// this at all, but the COLOUR was always re-derived from the weapon,
	// never from that number. Dropped rather than left dead.
	private static color tierColorOf(Weapon w)
	{
		bool found; color tier;
		[found, tier] = rsTierLookup(w);
		if (found) return tier;

		[found, tier] = wr_CompatLegenDoom.TierOf(w);
		if (found) return tier;

		[found, tier] = wr_CompatDRLA.ColorOf(w);
		if (found) return tier;

		[found, tier] = wr_CompatDoomablo.TierOf(w);
		if (found) return tier;

		int slot = slotOf(w);
		if (slot >= 1 && slot <= 9) return slotColor(slot);

		return hueOf(classNameHash(w), 16);
	}

	private static int slotOf(Weapon w)
	{
		return w ? w.default.SlotNumber : 0;
	}

	// Guarded like every other cvar read here: GetCVar returns null for one
	// the config has never seen and GetFloat on that aborts the VM, which
	// kills layout every tic and reads exactly like the rig not existing.
	private static double sheetScale()
	{
		double s = cv("wr_sheet_scale", 1.0);
		return (s < 0.1) ? 1.0 : s;
	}

	// Empty every pool row this pass did not use. Blanked rather than removed
	// so row N is always the same billboard at the same height -- a row that
	// disappears and takes the rows below it up with it is the thing that
	// makes a sheet unreadable while the selector is moving.
	private void blankRestOfSheet()
	{
		for (int i = mSheetUsed; i < mSheetRows.Size(); ++i)
		{
			if (mSheetRows[i]) wr_BB.SetBillboardText(mSheetRows[i], "");
		}
	}

	// The ammo's own display name, trimmed to fit a row. GetTag falls back to
	// the class name when a mod has not set one, which is still more useful
	// than the word "AMMO".
	private static string ammoLabel(Weapon w)
	{
		Inventory a = hasMagazine(w) ? w.Ammo2 : w.Ammo1;
		if (a == null) a = w.Ammo1;
		// Ammo1/Ammo2 are only assigned in AttachToOwner, so a weapon on the
		// floor -- the only kind the compare card is built for -- has neither.
		// Fall back to the class-declared pool rather than the literal "AMMO".
		class<Inventory> ac = null;
		if (a != null)                 ac = (class<Inventory>)(a.GetClass());
		else if (w.AmmoType1 != null)  ac = w.AmmoType1;
		else if (w.AmmoType2 != null)  ac = w.AmmoType2;
		if (ac == null) return "AMMO";

		string t;
		if (a != null) t = "" .. a.GetTag();
		else           t = "" .. GetDefaultByType(ac).GetTag();
		if (t.Length() == 0) t = "" .. ac.GetClassName();
		t = t.MakeUpper();
		if (t.Length() > 10) t = t.Left(10);
		return t;
	}

	// THE BACKGROUND STARFIELD.
	//
	// Pure decoration, and deliberately so: nothing here is selectable, hit
	// tested, or tied to a weapon. It exists because a constellation drawn
	// against empty air reads as a scatter plot, and the same constellation
	// drawn against a field of other, dimmer, further-away lights reads as a
	// piece of sky -- which is the whole difference the shape was chosen for.
	//
	// Built ONCE per rig, not per expansion. The field is the room the cards
	// are in; rebuilding it every time a slot opened would make the sky itself
	// flicker on and off as you browsed.
	private void buildStars()
	{
		clearStars();

		int want = int(cv("wr_stars", 0.0));
		if (want <= 0) return;

		// Positions and hues are HASHED off the star's index, never rolled --
		// the same reasoning the constellation's own scatter is deterministic.
		// A sky that is different every time you raise your hand is noise; one
		// that is the same sky is a place.
		for (int i = 0; i < want; ++i)
		{
			int h = ((i + 1) * 2654435761) & 0x7FFFFFFF;

			// Spread over a square a good deal wider than the ring itself, so
			// the field runs past the cards rather than stopping neatly behind
			// them and reading as a backdrop panel.
			mStarX.Push(double((h >>  3) & 1023) / 1023.0 - 0.5);
			mStarY.Push(double((h >> 13) & 1023) / 1023.0 - 0.5);

			// HASHED HUE, the same fallback the ring already uses to colour a
			// weapon with no tier to colour by -- so the field has real
			// variety, a few warm and a few cool, rather than reading as one
			// flat layer of grey dust.
			int hue = starHue(h);
			mStarHue.Push(hue);

			mStars.Push(wr_BB.AddBillboardPersistent(
				(0, 0, 0), 0.16, 0.16, 0, 0,
				wr_BB.BBF_FIXED, wr_BB.BB_PANEL, 15,
				hue, wr_BB.BBFL_NOHIT, 0, ""));
		}
	}

	// A star's colour, from its own hash. Kept pale -- these are BEHIND the
	// data and must never compete with it, so every channel is floored high
	// (whites and pastels) rather than allowed to run to a saturated colour
	// that would pull the eye off a card.
	private static int starHue(int h)
	{
		int r = 150 + ((h >>  2) & 105);
		int g = 150 + ((h >> 11) & 105);
		int b = 150 + ((h >> 21) & 105);
		return (r << 16) | (g << 8) | b;
	}

	private void clearStars()
	{
		for (int i = 0; i < mStars.Size(); ++i)
		{
			if (mStars[i]) wr_BB.RemoveBillboard(mStars[i]);
		}
		mStars.Clear();
		mStarX.Clear();
		mStarY.Clear();
		mStarHue.Clear();
	}

	// Every star placed, faded and sized for this tic. Called from the same
	// layout pass the cards use, so the field tracks the hand exactly as they
	// do rather than hanging in world space where the rig used to be.
	private void layoutStars(Vector3 wrist, Vector3 viewRight, double faceYaw,
	                         double tilt, double panelW, double ringR, double grow)
	{
		if (mStars.Size() == 0) return;

		// Pushed back from the cards along the view axis, which is what lets
		// wr_parallax separate them into their own plane when you move your
		// head. Without the offset they would sit in the data's own depth and
		// read as more cards, just smaller.
		Vector3 back = (cos(faceYaw + 180), sin(faceYaw + 180), 0) * (panelW * STAR_BEHIND);

		double field = ringR * 3.2;

		for (int i = 0; i < mStars.Size(); ++i)
		{
			Vector3 pos = wrist + back
			            + viewRight * (mStarX[i] * field)
			            + (0, 0, mStarY[i] * field);

			// Phase-offset per star, so the field twinkles as independent
			// lights rather than pulsing as one sheet -- SHIMMER_PHASE's own
			// argument, applied to a hundred small things instead of nine
			// large ones.
			double tw = 0.55 + 0.45 * sin(level.maptime * STAR_SPEED + i * STAR_PHASE);

			wr_BB.MoveBillboard(mStars[i], pos);
			wr_BB.OrientBillboard(mStars[i], faceYaw, tilt, wr_BB.BBF_FIXED);
			wr_BB.SetBillboardAlpha(mStars[i], tw * grow * cv("wr_stars_alpha", 0.5));
		}
	}

	private void buildSheet()
	{
		clearSheet();
		if (cv("wr_sheet", 1.0) <= 0.0) return;

		// The plate, and a hit-free border. plateKind()/plateShape() are the
		// same solved-rectangle payload the cards use, so the sheet is made of
		// the same material as the thing it sits next to rather than looking
		// like a different mod's window.
		mSheetPlate = wr_BB.AddBillboardPersistent(
			(0, 0, 0), 3.5, 2.5, 0, 0,
			wr_BB.BBF_FIXED, plateKind(), plateShape(),
			SHEET_BG, wr_BB.BBFL_NOHIT, 0, "");
		wr_BB.SetBillboardGradient(mSheetPlate, SHEET_BG2);

		// Created AFTER the plate so it is the nearer of the two by creation
		// order, and alpha 0 rather than absent -- a fully transparent
		// billboard is still hittable, which is the documented trap the cards
		// rely on here on purpose.
		mSheetHit = wr_BB.AddBillboardPersistent(
			(0, 0, 0), 3.5, 2.5, 0, 0,
			wr_BB.BBF_FIXED, wr_BB.BB_PANEL, 0,
			SHEET_BG, 0, 0, "");
		wr_BB.SetBillboardAlpha(mSheetHit, 0);

		// The stripe along the top, same promise the cards' accent makes.
		mSheetAccent = wr_BB.AddBillboardPersistent(
			(0, 0, 0), 3.5, 0.3, 0, 0,
			wr_BB.BBF_FIXED, wr_BB.BB_PANEL, 0,
			SHEET_ACCENT, wr_BB.BBFL_NOHIT, 0, "");

		mSheetTitle = wr_BB.AddBillboardPersistent(
			(0, 0, 0), 3.5, 2.5, 0, 0,
			wr_BB.BBF_FIXED, wr_BB.BB_TEXT, 0,
			SHEET_ACCENT, wr_BB.BBFL_NOHIT, 0, "");

		// THE ROW POOL, allocated once for the life of the ring.
		//
		// SHEET_ROW_POOL, not "as many as this weapon needs": rows are
		// restrung in place as the selector moves, so they have to exist
		// before the first weapon is known, and a fixed pool means row N is
		// the same billboard at the same height for every weapon. Nine,
		// because layoutSheet fits ten elements and the tenth is the bar.
		for (int i = 0; i < SHEET_ROW_POOL; ++i)
		{
			mSheetRows.Push(wr_BB.AddBillboardPersistent(
				(0, 0, 0), 3.5, 2.5, 0, 0,
				wr_BB.BBF_FIXED, wr_BB.BB_TEXT, 0,
				SHEET_TEXT, wr_BB.BBFL_NOHIT, 0, ""));
		}

		// ONE BAR, and it belongs to CONDITION.
		//
		// Not to a stat that can be cursed. RS_Screens.zs:292-297 rules that a
		// cursed stat draws no bar at all, "because a bar IS the number and
		// drawing one would leak exactly what the curse hides" -- so a bar on
		// a maskable row would need a suppression path, and UpdateBillboard
		// cannot delete. Condition is never cursed, so this one is
		// unconditionally safe to update in place every tic.
		mSheetBars.Push(wr_BB.AddBillboardPersistent(
			(0, 0, 0), 3.5, 0.35, 0, 0,
			wr_BB.BBF_FIXED, wr_BB.BB_BAR, 0,
			SHEET_MEAS, wr_BB.BBFL_NOHIT, 0, ""));

		// The title and the rows are filled by buildSheetRows() against the
		// weapon actually under the selector. Nothing is authored here.
		mSheetShown = null;
		mSheetValid = false;
		mSheetUsed  = 0;
	}

	// The condition gauge. Hidden rather than removed when a weapon has no
	// condition to show -- the bar is one billboard for the life of the ring
	// and alpha is the only way to take it off screen without freeing it.
	private void setSheetBar(int pct, color col, bool show)
	{
		if (mSheetBars.Size() == 0 || mSheetBars[0] == 0) return;

		wr_BB.SetBillboardAlpha(mSheetBars[0], show ? 1.0 : 0.0);
		if (show) wr_BB.UpdateBillboard(mSheetBars[0], clamp(pct, 0, 100), col);
	}

	// Writes into the next pool slot rather than creating a billboard. The
	// pool is sized once in buildSheet(); past its end a row is dropped rather
	// than drawn off the plate, which is the failure layoutSheet's ten-slot
	// budget exists to prevent.
	private void sheetRow(string text, color col)
	{
		if (mSheetUsed >= mSheetRows.Size()) return;

		int id = mSheetRows[mSheetUsed];
		++mSheetUsed;
		if (id == 0) return;

		wr_BB.SetBillboardText(id, text);
		wr_BB.UpdateBillboard(id, 0, col);
	}

	private void sheetBar(int pct, color col)
	{
		mSheetBars.Push(wr_BB.AddBillboardPersistent(
			(0, 0, 0), 3.5, 0.35, 0, 0,
			wr_BB.BBF_FIXED, wr_BB.BB_BAR, pct,
			col, wr_BB.BBFL_NOHIT, 0, ""));
	}

	private void clearSheet()
	{
		if (mSheetPlate)  wr_BB.RemoveBillboard(mSheetPlate);
		if (mSheetAccent) wr_BB.RemoveBillboard(mSheetAccent);
		if (mSheetTitle)  wr_BB.RemoveBillboard(mSheetTitle);
		if (mSheetHit)    wr_BB.RemoveBillboard(mSheetHit);
		mSheetPlate = 0; mSheetAccent = 0; mSheetTitle = 0; mSheetHit = 0;

		for (int i = 0; i < mSheetRows.Size(); ++i)
		{
			if (mSheetRows[i]) wr_BB.RemoveBillboard(mSheetRows[i]);
		}
		for (int i = 0; i < mSheetBars.Size(); ++i)
		{
			if (mSheetBars[i]) wr_BB.RemoveBillboard(mSheetBars[i]);
		}
		mSheetRows.Clear();
		mSheetBars.Clear();
	}

	// Parked to one side of the ring, facing you the same way the centre cell
	// does. Placed off mLastRingR rather than off wr_radius, so it steps out
	// with the ring when a big weapon set grows it instead of being buried.
	private void layoutSheet(Vector3 wrist, double viewYaw, Vector3 viewRight,
	                         double tilt, double rise, double ringR,
	                         double panelW, double panelH, double lateral)
	{
		if (mSheetPlate == 0) return;

		double ss = sheetScale();
		double sw = panelW * SHEET_W_CARDS * ss;

		// THE PLATE IS AS TALL AS ITS CONTENT, not as tall as the worst case.
		//
		// SHEET_H_CARDS is 8.6 because a fully-loaded DOOM Infinite weapon can
		// emit close to thirty rows -- but the plate was that size ALWAYS, so a
		// six-row pistol got a thirty-row sheet. That is the panel that swallows
		// the ring: at defaults it renders 30.96 units tall, hung on the hand
		// with no forward standoff, and the cards orbit inside it.
		//
		// shFull stays the authored size and is what every ROW metric is measured
		// against, so a row keeps exactly the absolute height it has today -- this
		// is a shorter plate holding the same-size rows, never the same plate with
		// the text squashed. sh is what actually gets drawn.
		//
		// The fractions are the authored layout read back: rows begin at
		// SHEET_ROWS_TOP from the top and march down at ROW_FRAC * ROW_PITCH
		// each. Thirty rows comes to 0.21 + 30*0.0204*1.3 = 1.006 -- the whole
		// plate, which is what confirms these constants describe the real layout.
		double shFull = panelH * SHEET_H_CARDS * ss;

		int rowsShown = mSheetUsed;
		if (rowsShown > int(mSheetRows.Size())) rowsShown = int(mSheetRows.Size());
		int barsShown = int(mSheetBars.Size());

		double usedFrac = SHEET_ROWS_TOP
			+ (rowsShown + barsShown) * SHEET_ROW_FRAC * SHEET_ROW_PITCH
			+ 0.04;   // a row's worth of daylight under the last line

		// Never taller than authored, and never so short the title has nowhere to
		// sit -- SHEET_ROWS_TOP is where the first row begins, so anything below
		// that would draw the title off its own plate.
		if (usedFrac > 1.0) usedFrac = 1.0;
		if (usedFrac < SHEET_ROWS_TOP + 0.08) usedFrac = SHEET_ROWS_TOP + 0.08;

		double sh = shFull * usedFrac;

		// DEAD CENTRE, where the centre cell used to be. Zero degrees off the
		// view axis no matter how large the ring grows, and out of reach of
		// every fan, which expands outward. layout() floors ringR against the
		// sheet's own half-width so the cards orbit clear of it rather than
		// through it.
		//
		// EXCEPT UNDER THE HONEYCOMB, which is why `lateral` exists. A hex
		// packing is gapless BY DEFINITION -- its centre cell is a real slot
		// holding a real card, not free space the way the middle of a ring is
		// -- so there is no hole at the middle for the sheet to stand in
		// without covering a card. The caller passes the layout's
		// own half-width plus clearance here and the sheet stands beside the
		// comb instead. Zero in ring mode, which is every existing setup.
		Vector3 centre = wrist + viewRight * lateral + (0, 0, rise);

		// Toward the eye, so text sits proud of its plate instead of z-fighting
		// it -- the same lift every card label uses.
		Vector3 lift = (cos(viewYaw + 180), sin(viewYaw + 180), 0) * LABEL_LIFT;
		double  yaw  = viewYaw + 180;

		wr_BB.MoveBillboard(mSheetPlate, centre);
		wr_BB.ResizeBillboard(mSheetPlate, sw, sh);
		wr_BB.OrientBillboard(mSheetPlate, yaw, tilt, wr_BB.BBF_FIXED);

		// Exactly over the plate. Not oversized the way a card's hit quad is
		// -- a card wants forgiving edges, but this one sits in the middle of
		// the ring and any margin it gains is margin the nearest cards lose.
		if (mSheetHit != 0)
		{
			wr_BB.MoveBillboard(mSheetHit, centre);
			wr_BB.ResizeBillboard(mSheetHit, sw, sh);
			wr_BB.OrientBillboard(mSheetHit, yaw, tilt, wr_BB.BBF_FIXED);
		}

		double top = sh * 0.5;

		wr_BB.MoveBillboard(mSheetAccent, centre + lift + (0, 0, top - sh * 0.03));
		wr_BB.ResizeBillboard(mSheetAccent, sw * 0.94, shFull * 0.025);
		wr_BB.OrientBillboard(mSheetAccent, yaw, tilt, wr_BB.BBF_FIXED);

		double titleH = shFull * SHEET_TITLE_FRAC;
		wr_BB.MoveBillboard(mSheetTitle, centre + lift + (0, 0, top - shFull * 0.10));
		wr_BB.ResizeBillboard(mSheetTitle, sw * 0.9, titleH);
		wr_BB.OrientBillboard(mSheetTitle, yaw, tilt, wr_BB.BBF_FIXED);

		// Rows march down from under the title on a fixed pitch. A pitch, not a
		// division of the remaining space: the row height then does not change
		// when a row is added, which is what keeps the sheet readable as the
		// real thing grows past seven rows.
		// Measured against shFull, NOT the shrunk plate -- otherwise shortening
		// the sheet would shrink the text with it, which is the one thing the
		// growth comments on SHEET_H_CARDS were careful never to do.
		double rowH = shFull * SHEET_ROW_FRAC;
		double y    = top - shFull * SHEET_ROWS_TOP;

		for (int i = 0; i < mSheetRows.Size(); ++i)
		{
			wr_BB.MoveBillboard(mSheetRows[i], centre + lift + (0, 0, y));
			wr_BB.ResizeBillboard(mSheetRows[i], sw * 0.86, rowH);
			wr_BB.OrientBillboard(mSheetRows[i], yaw, tilt, wr_BB.BBF_FIXED);
			y -= rowH * SHEET_ROW_PITCH;
		}

		// The gauges sit under the rows, full width, spaced like two more rows.
		for (int i = 0; i < mSheetBars.Size(); ++i)
		{
			wr_BB.MoveBillboard(mSheetBars[i], centre + lift + (0, 0, y));
			wr_BB.ResizeBillboard(mSheetBars[i], sw * 0.86, shFull * 0.028);
			wr_BB.OrientBillboard(mSheetBars[i], yaw, tilt, wr_BB.BBF_FIXED);
			y -= rowH * SHEET_ROW_PITCH;
		}
	}

	// REBUILD IN PLACE, for a page change. Everything openRig does after it
	// has decided which hand it is on -- the ring is already open and stays
	// open, it is only its CONTENTS that change.
	//
	// clearPanels(), NOT destroyPanels(). destroyPanels ends by CLOSING the
	// rig, and this restored none of it, so every page press killed the ring
	// for the rest of the session. mOpen went false, WorldTick early-returns
	// on !mOpen before layout(), and the cards spawned four lines below were
	// therefore never positioned and never removed: mClosingTics stayed 0 so
	// no deferred sweep ever came for them, and the next openRig cleared
	// mIds/mLabels without RemoveBillboard and dropped the handles for good. A
	// full card set plus data sheet, stranded at the map origin, permanently
	// -- and with it the laser dropped, the sticks handed back and bullet time
	// switched off, mid-choice. Both callers were affected, this one and
	// commitModel(), whose own comment says it stays open on purpose.
	//
	// SPLIT INTO TEARDOWN AND CLOSE rather than putting the open state back
	// afterwards. A page change frees exactly the billboards and re-spawns
	// them; it takes nothing from the player and so has nothing to hand back.
	// Restoring afterwards was the other option and it is strictly worse: it
	// means duplicating -- and then keeping in step with -- everything openRig
	// sets, in order to undo four calls this never needed to make.
	//
	// No grow animation here on purpose. openRig eases its groups in from zero
	// because the ring is arriving; a page flip is a ring that is already in
	// the air changing what it holds, and re-growing it from nothing would
	// read as a close and a reopen. A fresh group is settled at 1.0 by
	// default (FBillboardGroup in g_levellocals.h: from/to 1.0, durTics 0), so
	// the new cards simply appear where layout() puts them on the next tic.
	private void rebuildPage(PlayerPawn pmo)
	{
		clearPanels();

		gatherWeapons(pmo);

		spawnPanels();
		spawnCardModels(pmo);
		buildSheet();
		buildStars();

		// Whatever was under the laser belonged to the old page.
		mHovered   = 0;
		mHoverTics = 0;
	}

	// Every billboard and every group, gone. Split out of closeRig because the
	// collapse animation needs a second, later place to call it from -- and
	// because a half-freed ring is the one state nothing else here can handle.
	//
	// THE TEARDOWN HALF. Billboards, groups, card props and the arrays indexed
	// alongside them -- and nothing that belongs to the PLAYER. Safe to call
	// while the rig stays open, which is the entire reason it is split out of
	// destroyPanels: see rebuildPage.
	private void clearPanels()
	{
		clearSheet();
		clearStars();
		clearCompare();

		for (int i = 0; i < mIds.Size(); ++i)
		{
			if (mIds[i]) wr_BB.RemoveBillboard(mIds[i]);
		}
		for (int i = 0; i < mPlates.Size(); ++i)
		{
			if (mPlates[i]) wr_BB.RemoveBillboard(mPlates[i]);
		}
		for (int i = 0; i < mLabels.Size(); ++i)
		{
			if (mLabels[i]) wr_BB.RemoveBillboard(mLabels[i]);
		}
		for (int i = 0; i < mIcons.Size(); ++i)
		{
			if (mIcons[i]) wr_BB.RemoveBillboard(mIcons[i]);
		}
		for (int i = 0; i < mAmmos.Size(); ++i)
		{
			if (mAmmos[i]) wr_BB.RemoveBillboard(mAmmos[i]);
		}
		for (int i = 0; i < mAccents.Size(); ++i)
		{
			if (mAccents[i]) wr_BB.RemoveBillboard(mAccents[i]);
		}
		for (int i = 0; i < mGauges.Size(); ++i)
		{
			if (mGauges[i]) wr_BB.RemoveBillboard(mGauges[i]);
		}
		for (int i = 0; i < mFaces.Size(); ++i)
		{
			if (mFaces[i]) wr_BB.RemoveBillboard(mFaces[i]);
		}
		for (int i = 0; i < mMarks.Size(); ++i)
		{
			if (mMarks[i]) wr_BB.RemoveBillboard(mMarks[i]);
		}
		for (int i = 0; i < mStackBadges.Size(); ++i)
		{
			if (mStackBadges[i]) wr_BB.RemoveBillboard(mStackBadges[i]);
		}
		for (int i = 0; i < mShadows.Size(); ++i)
		{
			if (mShadows[i]) wr_BB.RemoveBillboard(mShadows[i]);
		}
		for (int i = 0; i < mSlotNums.Size(); ++i)
		{
			if (mSlotNums[i]) wr_BB.RemoveBillboard(mSlotNums[i]);
		}

		// Groups LAST, and not optional. A member left pointing at a dead group
		// silently snaps back to full size, so releasing them is the correct way
		// to end a group's life rather than tidy-up nobody would miss.
		for (int i = 0; i < mGroups.Size(); ++i)
		{
			if (mGroups[i]) wr_BB.RemoveBillboardGroup(mGroups[i]);
		}
		mMarks.Clear();
		mStackBadges.Clear();
		mShadows.Clear();
		mSlotNums.Clear();
		mGroups.Clear();

		// THE CARD PROPS, which releaseDecor() used to be the only caller for
		// -- and releaseDecor belongs to the close, not to the teardown, so it
		// is not on this path any more. spawnCardModels() does clear them
		// itself, but only after its weapons-page check, so flipping to the
		// inventory or model page returned before ever reaching that line and
		// left a full set of weapon actors standing in the old ring's
		// positions.
		clearCardModels();

		collapseSlot();

		mIds.Clear();
		mPlates.Clear();
		mLabels.Clear();
		mIcons.Clear();
		mAmmos.Clear();
		mAccents.Clear();
		mGauges.Clear();
		mFaces.Clear();
		mCardX.Clear(); mCardY.Clear(); mCardZ.Clear();
		mMarks.Clear();
		mStackBadges.Clear();
		mShadows.Clear();
		mSlotNums.Clear();
		mBaseColor.Clear();
		mIconW.Clear();
		mIconH.Clear();
		mLabelH.Clear();
		mAmmoW.Clear();
		mLowAmmo.Clear();
		mTypes.Clear();
		mCardLabel.Clear();
		mCardSlots.Clear();
		mCardColor.Clear();
		mSlotCount.Clear();
		mSlotAllDry.Clear();

		// Hover state goes with the teardown rather than with the close: it
		// names a card that no longer exists either way, and a page change has
		// just as little business keeping it as a close does.
		mTouching  = false;
		mHovered   = 0;
		mDwellTics = 0;
	}

	// THE TEARDOWN AND THE CLOSE. Everything the ring took from the player is
	// handed back here and only here -- which is what makes clearPanels() safe
	// to call on its own, and what made calling THIS from rebuildPage a bug.
	private void destroyPanels()
	{
		clearPanels();

		engineLaser(false);
		wr_VR.SuppressVRInput(false);
		bulletTime(false);
		releaseDecor();

		mOpen      = false;
		mOpenTics  = 0;
	}

	// THE RIG NO LONGER TOUCHES THE HELD WEAPON AT ALL.
	//
	// It used to shrink it to half while the ring was up, to get the gun out of
	// the way of the hand being used as a cursor and to mark the mode. Neither
	// is needed: the ring floats a metre out in front, so the gun is not in the
	// way of anything, and the ring itself is a perfectly clear statement that
	// the rig is open.
	//
	// It also carried the worst bug in the mod. psp.scale belongs to the
	// psprite LAYER, and SetPsprite reuses that layer rather than building a
	// new one, so a scale applied by the rig survived the weapon changing
	// underneath it -- and every commit compounded it. Half, quarter, eighth.
	//
	// Gone with it: mSavedScale, mHaveSavedScale, the capture guard, the
	// per-tic re-assert, the restore on all three close paths, and
	// wr_weaponshrink. Nothing in the rig writes to a psprite any more.

	// Nothing else clears the suppression flag, and a stuck one is a player who
	// cannot turn with nothing to blame -- so it is released on every way out of
	// a level, not just the tidy one. That last claim only became TRUE with
	// OnUnregister, below. WorldUnloaded and PlayerDied are both TIDY ways out
	// and between them they were the whole of it, so a savegame load or a quit
	// to title took this handler down with the flag still set and left no path
	// behind that could ever clear it again.
	// Set before ANY handler's WorldLoaded runs, which is the only moment it can
	// matter.
	//
	// BulletTimeX reads bt_adrenaline_unlimited exactly once, in its own
	// WorldLoaded, and caches it. Flipping the cvar when the wheel opens is
	// therefore a no-op -- it was read minutes ago. Adrenaline is a countdown, so
	// without this the world speeds back up underneath you mid-choice.
	//
	// The cost, stated plainly: bullet time you start yourself with its own key
	// becomes unlimited too. There is no way to scope it tighter without holding
	// a reference to the BulletTime class, and that would make BulletTimeX a hard
	// dependency of this wheel -- it would not compile without it.
	override void OnRegister()
	{
		// -1 sentinels. An int field starts at 0, which is card 0 for
		// mExpanded and shape slot 0 for mShapeSlot -- and this handler is
		// rebuilt on every map, so without this the first open of each map
		// treated card 0 as an open fan's parent, and a death or exit before
		// the first open called RemoveShape(0) on somebody else's shape.
		mExpanded  = -1;
		mShapeSlot = -1;

		if (!cvBool("wr_bullettime", true)) return;

		let unl = CVar.FindCVar("bt_adrenaline_unlimited");
		if (unl != null) unl.SetInt(1);
	}

	// THE ONLY TEARDOWN HOOK THAT FIRES ON EVERY PATH.
	//
	// WorldUnloaded is a NORMAL LEVEL EXIT and nothing else (g_level.cpp:827,
	// per-level, on the way to the next map). Load a savegame, start a new
	// game or quit to title and G_InitNew fires the STATIC manager's unload
	// instead (g_level.cpp:579) -- and this is a LEVEL handler, so it is not
	// on that list. It was simply destroyed with mOpen still true and not one
	// line of any close ever ran.
	//
	// What that left set is GLOBAL and the engine never resets it. Both flags
	// are script-owned with no other caller anywhere in the tree --
	// SuppressVRInput is VR_SetScriptInputSuppressed (vmthunks.cpp:5411) and
	// ForceVRLaser is VR_SetScriptLaserForced (vmthunks.cpp:5467) -- so
	// nothing was ever going to hand them back. Three keystrokes to reach:
	// open the rig, Esc, Load Game. The pause menu freezes WorldTick, so the
	// idle-close cannot expire out of it either.
	//
	// OnUnregister runs on all of it, because it hangs off the handler's own
	// destruction rather than off any world event: ClearLevelData reaches
	// localEventManager->Shutdown() (p_setup.cpp:406), which Destroy()s every
	// handler it holds (events.cpp:638) -> DStaticEventHandler::OnDestroy
	// (events.cpp:2397) -> UnregisterHandler -> OnUnregister (events.cpp:348).
	//
	// UNCONDITIONAL, and deliberately not closeRig(). By the time this runs
	// the handler is being destroyed: there is no next tic for a fold-away to
	// be finished on, no reason to play a close sound at a player who has
	// already left, and no state here worth trusting. So the two engine flags
	// are written straight, BEFORE anything else, rather than through
	// engineLaser() -- which is reached only from paths that assume a live rig
	// -- and the input is therefore back in the player's hands even if
	// something below this line were to fail. destroyPanels() then does the
	// rest exactly as a hard close does, and every part of it is already safe
	// on a rig that was never open: each loop tests its handle, every array is
	// Cleared rather than indexed, bulletTime() answers to mBtOn so it flips
	// nothing it did not start, and releaseDecor() hands back only what its
	// own flags say was taken.
	//
	// The one part of that which is not fully in this mod's hands is bullet
	// time, because it is a netevent to another mod rather than a flag we own
	// -- SendNetworkEvent refuses outright once gamestate has left GS_LEVEL
	// (events.cpp:382), so on some exits the toggle simply does not go. That
	// is the same bet the existing level-exit path has always made from
	// WorldUnloaded, and it is the right way round: an undelivered "turn it
	// off" costs a mod whose own state is being torn down anyway, where a
	// stuck suppression flag costs the player their sticks with nothing on
	// screen to blame -- which is why the two engine flags above go first and
	// directly, and do not depend on any of this.
	override void OnUnregister()
	{
		wr_VR.ForceVRLaser(false, -1);
		wr_VR.SetVRLaserRange(0);
		wr_VR.SuppressVRInput(false);

		// mBtOn IS CLEARED BEFORE destroyPanels, AND THAT ORDER IS THE POINT.
		//
		// destroyPanels calls bulletTime(false), which sends the bt_activate
		// netevent. On the exits this override exists for -- load game, new
		// game, quit to title -- gamestate has NOT left GS_LEVEL while the menu
		// is up, so events.cpp:381-383 does not refuse it and the DEM_NETEVENT
		// really is written to the net buffer. Nothing clears that buffer on a
		// level change (the only Net_ClearBuffers is d_main.cpp:1830, the
		// D_DoomLoop restart), and d_net.cpp:3142-3151 dispatches the queued
		// command through `primaryLevel->localEventManager->Console(...)` --
		// resolving primaryLevel at CONSUMPTION time, which by then is the
		// newly loaded level.
		//
		// bt_activate is a TOGGLE with nothing to read back. So the restored
		// save, whose bullet-time state was just rebuilt as off, would receive
		// an unmatched toggle and start in permanent slow motion -- the same
		// stuck-global-state failure this change set fixed in bulletTime()
		// itself, reintroduced one function over.
		//
		// Clearing the record first makes bulletTime's own
		// `if (on == mBtOn) return;` guard fire, so nothing is queued at all.
		// The normal map-change path is unaffected: WorldUnloaded already ran
		// closeRig into a world whose bullet-time state genuinely carried over
		// and genuinely needed cancelling.
		mBtOn = false;

		destroyPanels();
	}

	// HARD, on both, and the mHardClose flag is the whole of it.
	//
	// A soft close sets mClosingTics and defers every RemoveBillboard to a
	// WorldTick -- and neither of these has one coming. Zero tics pass between
	// WorldUnloaded and this handler being destroyed, and nothing sweeps the
	// leftovers: ClearLevelData never touches Billboards, and the only
	// Billboards.Clear() in the tree is the bb_clear debug ccmd (p_tick.cpp:329).
	// So the entire card set survived into the NEXT map, at the previous map's
	// coordinates and at FULL size: the new map restarts maptime against a
	// large startTic, so BillboardGroupScale reads the collapse animation from
	// before its start and returns `from`, which closeRig's fold-away had just
	// set to 1.0.
	//
	// PlayerDied has the same shape and the same fix. WorldTick's own death
	// path (the PST_LIVE check) already closes hard for exactly this reason --
	// "dying is not a moment for an animation" -- so this is the two remaining
	// paths agreeing with it rather than a new rule.
	override void WorldUnloaded(WorldEvent e) { mHardClose = true; closeRig(); mHardClose = false; wr_VR.SuppressVRInput(false); }
	override void PlayerDied(PlayerEvent e)  { mHardClose = true; closeRig(); mHardClose = false; wr_VR.SuppressVRInput(false); }

	// Open on level start while iterating, so testing a change is one launch
	// instead of a launch and a keypress. Off for everyone else.
	//
	// Armed here, fired from WorldTick rather than opened here directly:
	// WorldLoaded can land before the pawn counts as PST_LIVE, and openRig bails
	// on that -- which looks exactly like the rig being broken.
	override void WorldLoaded(WorldEvent e)
	{
		// Cleared BEFORE migrateConfig and read AFTER it, and the order is
		// load-bearing both ways. migrateConfig WRITES wr_autoopen in gen 20,
		// so reading first would auto-open once more on the very load that
		// turned it off. And a cvar write that fails takes the rest of this
		// function with it -- which is why the clear comes first, so a
		// migration that dies leaves the flag at "do nothing" rather than at
		// whatever it happened to hold.
		mWantAutoOpen = false;
		migrateConfig();
		mWantAutoOpen = cvBool("wr_autoopen", false);
	}

	// Geometry generation. Bump this whenever the numbers below change and every
	// existing config picks them up once, automatically.
	const CFG_VERSION = 21;

	private void migrateConfig()
	{
		let stamp = CVar.GetCVar("wr_cfgver", players[consoleplayer]);
		if (stamp == null || stamp.GetInt() >= CFG_VERSION) return;

		// Gen 21: the ring's own Ermac-style art (owner 2026-10-31: "why is my wheel ugly"). Ermac's digits
		// for numbers; the plates follow wr_ring_art, new, so it needs no rewrite.
		let fs = CVar.GetCVar("wr_fontset", players[consoleplayer]);
		if (fs) fs.SetString("Ermac");

		// Gen 20: auto-open OFF. It was on for all of development and the
		// archived value in an existing config outlives any change to the
		// default, so anyone who ever loaded this before now would keep
		// getting a ring in their face at every map start otherwise.
		setCv("wr_autoopen", 0);

		// Gen 19 briefly migrated wr_card_* (the in-world stat card's own
		// size/gap cvars) -- the card and everything that read them are
		// gone now, owner's direct order after it could not be made to
		// render its grid correctly. Left as an empty generation rather
		// than renumbering everything after it.

		// Gen 18: bigger cards. Text readability in a headset is an ABSOLUTE
		// size problem -- a two-line name on a small card is small however the
		// fractions are tuned, because the card itself is the ceiling.
		setCv("wr_panel_w", 4.2);
		setCv("wr_panel_h", 3.0);
		setCv("wr_radius",  5.0);
		setCv("wr_rise",    2.0);
		// wr_span, wr_phase and wr_follow were migrated here until the layout
		// moved from an arc to fixed bearings. Nothing reads them now and the
		// cvars are gone; an archived value left in someone's config is inert.
		setCv("wr_tilt",   12.0);

		// Gen 16: real models default ON. A changed DEFAULT can never reach
		// anyone who has already loaded the mod -- the cvar was written to their
		// config the first time and the saved value wins forever -- so turning
		// it on means rewriting it here once, which is the entire reason this
		// stamp exists.
		setCv("wr_models", 0);
		setCv("wr_touch",   7.0);
		setCv("wr_forward", 34.0);
		setCv("wr_bullettime", 1);
		setCv("wr_roll",    0.0);

		stamp.SetInt(CFG_VERSION);
		Console.Printf("\c[Gold]RSVR HUD\c- geometry updated to gen %d", CFG_VERSION);
	}

	private static void setCv(string name, double value)
	{
		let c = CVar.GetCVar(name, players[consoleplayer]);
		if (c != null) c.SetFloat(value);
	}

	// Reads a user cvar, falling back rather than aborting. GetCVar returns null
	// for anything the config has never seen, and GetFloat on null kills the VM.
	// RSQ: THE LOCAL VALUE. QuestZDoom has no netplay, and on QZD 17.3 a user cvar's per-player
	// copy (CVar.GetCVar with a player) read 0 for a new bool whose local value was 1 (measured:
	// wr_models, "player copy 0 local 1"). FindCVar reads what the menu and console set.
	private static double cv(string name, double fallback)
	{
		let c = CVar.FindCVar(name);
		if (c == null) return fallback;
		return (c.GetRealType() == CVar.CVAR_Bool) ? (c.GetBool() ? 1.0 : 0.0) : c.GetFloat();
	}

	// A bool cvar holds an int, and GetFloat on one returns zero -- which is why
	// wr_autoopen read false no matter what it was set to.
	private static bool cvBool(string name, bool fallback)
	{
		let c = CVar.FindCVar(name);   // RSQ: the local value -- see cv()
		if (c == null) return fallback;
		return (c.GetRealType() == CVar.CVAR_Bool) ? c.GetBool() : (c.GetInt() != 0);
	}


	//==========================================================================
	// What goes on the rig
	//==========================================================================

	// Walked straight off WeaponSlots rather than sorted out of AllActorClasses.
	// Slots 1..9 then 0 is already the order the player thinks in, so there is
	// nothing to sort.
	// ONE CARD PER SLOT, at a FIXED cell.
	//
	// Filling cells left to right in pickup order meant the shotgun moved every
	// time you found something new, so nothing could ever be learned by feel.
	// Binding a slot to a cell fixes that: slot 1 is top left forever, whether
	// or not you own anything in slots 2 through 7.
	//
	// The card's face is the slot's first admissible weapon -- what you would
	// get by taking the slot outright. The rest of that slot lives behind it.
	// Total admissible weapons across every slot -- the number gatherWeapons()
	// needs BEFORE it can decide flat or collapsed. Built by summing
	// slotWeapons() rather than re-filtering inventory a third time: that
	// function is already the one place the admissibility test (owned, not
	// forbidden to this hand) lives, and this and the card-building loop
	// below both defer to it so neither can disagree with the other about
	// how many weapons there are.
	private int countAdmissible(PlayerPawn pmo)
	{
		int total = 0;
		for (int pass = 0; pass < 10; ++pass)
		{
			int slot = (pass == 9) ? 0 : pass + 1;
			Array<Class<Weapon> > variants;
			slotWeapons(pmo, slot, variants);
			total += variants.Size();
		}
		return total;
	}

	// WHAT GOES ON THE RING, for whichever page is showing. The weapon body
	// below is untouched and still the default -- the other two are additions
	// beside it, not a rewrite of it.
	private void gatherWeapons(PlayerPawn pmo)
	{
		if (mPage == PAGE_MODELS)    { gatherModels(pmo);    return; }
		gatherWeaponCards(pmo);
	}


	// MODELSWAPPER'S SHELF FOR THE GUN IN YOUR HAND.
	//
	// The ring shows the RECOMMENDED models -- the ones on that weapon's own
	// archetype shelf, so a shotgun offers shotguns. ModelSwapper's "any"
	// shelf (every model it has, for putting a chainsaw on a rocket launcher)
	// is the deliberate escape hatch and is not what a first look should be
	// crowded with.
	//
	// The card CLASS is the held weapon itself, repeated -- a model is not an
	// actor and has no class of its own. Only the label differs per card,
	// which is the whole reason mCardLabel exists.
	private void gatherModels(PlayerPawn pmo)
	{
		// NO FANS ON THIS PAGE. mFansEnabled is written in exactly one place --
		// gatherWeaponCards -- so a ring opened on the weapons page with a big
		// loadout carried it true straight across a page flip. The dwell trigger
		// is gated on mFansEnabled and not on mPage, so resting on an INVENTORY
		// card unfolded a fan of weapon cards out of it: both non-weapon gatherers
		// push slot 0 for every card, so expandSlot resolved slot 0's weapons.
		// Pressing fire on one of those is then swallowed and dropped, so the
		// trigger is consumed and nothing happens. Audit finding #23 / #28.
		mFansEnabled = false;

		let held = (mRigHand == 1) ? pmo.player.OffhandWeapon : pmo.player.ReadyWeapon;
		if (held == null) return;

		int hand = (mRigHand == 1) ? 1 : 0;

		bool ok; string arche, donor; int pick, count;
		[ok, arche, pick, count, donor] = wr_CompatModelSwapper.StateOf(hand);
		if (!ok || count <= 0) return;

		for (int i = 0; i < count; ++i)
		{
			mTypes.Push(held.GetClass());
			mCardLabel.Push(wr_CompatModelSwapper.NameAt(hand, i));
			mCardSlots.Push(0);

			// The one you are wearing reads differently from the rest, which
			// is the only state a model card has.
			mCardColor.Push(i == pick ? COLOR_HOVER : COLOR_IDLE);
			mSlotCount.Push(1);
			mSlotAllDry.Push(false);
		}
	}

	private void gatherWeaponCards(PlayerPawn pmo)
	{
		mTypes.Clear();
		mCardLabel.Clear();
		mCardSlots.Clear();
		mCardColor.Clear();
		mSlotCount.Clear();
		mSlotAllDry.Clear();

		// FLAT WHILE IT CAN AFFORD TO, COLLAPSED ONCE IT HAS TO.
		//
		// This used to be wr_subcards, a plain on/off switch for the whole
		// game: either every slot always fanned, or every weapon always got
		// its own card. Counting first and comparing to wr_subcards_max makes
		// it a per-loadout decision instead -- nine weapons stays flat and
		// readable, fifty collapses to the same nine learnable bearings it
		// always would have, and nothing has to be reconfigured crossing that
		// line because the ring crosses it by itself.
		mFansEnabled = countAdmissible(pmo) > max(0, cv("wr_subcards_max", 10.0));

		// Every slot Doom has, not the eight a 3x3 happened to hold. Slot 0 is
		// walked last because that is where the engine's own cycling puts it.
		for (int pass = 0; pass < 10; ++pass)
		{
			int slot = (pass == 9) ? 0 : pass + 1;

			Array<Class<Weapon> > variants;
			slotWeapons(pmo, slot, variants);
			if (variants.Size() == 0) continue;

			// COLLAPSED ONLY: move the remembered pick to the front. The test
			// and the swap now live in promoteLastPicked() -- unchanged, but
			// in ONE place, because expandSlot() decides what to leave out of
			// a fan from this same ordering and was reading the unpromoted
			// list. See the note on the helper for what that cost.
			promoteLastPicked(slot, variants);

			// FANS, OR EVERYTHING ON THE RING -- decided once, above, for the
			// whole ring, so two slots can never disagree about which mode
			// the ring is in.
			//
			// Collapsed: one card, this slot's first admissible weapon, and
			// the rest fan out of it on dwell -- the ring stays one card per
			// slot, which is what makes its bearings learnable by feel, slot 4
			// in the same direction whether you own one weapon there or five.
			//
			// Flat: every weapon in the slot gets its own card and the ring
			// grows to fit. It can afford to -- the radius already scales
			// with the count so the chord between neighbours stays above a
			// card width. What it gives up is the fixed bearing: picking up a
			// second plasma rifle moves everything after it round the ring.
			int show = mFansEnabled ? 1 : variants.Size();

			for (int k = 0; k < show; ++k)
			{
				Class<Weapon> type = variants[k];
				let held = Weapon(pmo.FindInventory(type));
				if (held == null) continue;

				mTypes.Push(type);
				mCardSlots.Push(slot);

				// RESOLVED ONCE, HERE, NOT PER FRAME. paintFace repaints
				// every tic in canvas mode -- see the note above
				// repaintFaces -- and cardColorFor's tier branch is a
				// cross-mod Service round trip, which belongs at build
				// time once per weapon, not multiplied by every card
				// every tic.
				mCardColor.Push(cardColorFor(held, slot));

				// PARALLEL TO mTypes, ONE PUSH PER CARD -- not one per slot.
				// A flat ring puts several cards on one slot, and each of
				// them needs its own entry here or every array after this
				// point in the file drifts out of index with mTypes. The
				// value itself only matters on a collapsed card (the stack
				// badge below reads it); on a flat one it is always
				// variants.Size() == 1, since nothing is left behind a card
				// that already has its own.
				mSlotCount.Push(variants.Size());

				// Checked across EVERY variant in the slot, not just this
				// shown one -- the point is telling a player, before they
				// spend the dwell to expand a fan, whether any of what is
				// hidden behind this card is actually worth reaching. A
				// flat card (variants.Size() == 1) never has anything
				// hidden, so it is never marked dry here regardless of its
				// own ammo -- that is what the card's own ammo readout is
				// for.
				bool allDry = variants.Size() > 1;
				if (allDry)
				{
					for (int vi = 0; vi < variants.Size(); ++vi)
					{
						let vHeld = Weapon(pmo.FindInventory(variants[vi]));
						if (vHeld != null && ammoLoaded(vHeld) != 0) { allDry = false; break; }
					}
				}
				mSlotAllDry.Push(allDry);
			}
		}
	}

	// Every weapon of one slot this hand may take, in slot order.
	private void slotWeapons(PlayerPawn pmo, int slot, out Array<Class<Weapon> > into)
	{
		into.Clear();

		let slots = players[consoleplayer].weapons;
		if (slots == null) return;

		int n = slots.SlotSize(slot);
		for (int j = 0; j < n; ++j)
		{
			Class<Weapon> type = slots.GetWeapon(slot, j);
			if (type == null) continue;

			let held = Weapon(pmo.FindInventory(type));
			if (held == null) continue;

			// STOWED IS NOT A CANDIDATE. Weapon.CheckAmmo refuses a
			// bHolsterHidden weapon outright, but this wheel equips by handing
			// the gun to a hand without ever going through CheckAmmo -- so
			// offering a stowed weapon here gives the player one that can never
			// fire, while whatever mount it came off still believes it is
			// seated. The engine's own VR wheel already drops these
			// (IsWheelWeaponUsable, hw_vrwheel.cpp) and this list has to agree
			// with it, or the two wheels disagree about what the player owns.
			//
			// bHolsterHidden ONLY. A stow usually sets bNoAutoSwitchTo as well,
			// but that flag is also a legitimate authored statement about
			// AUTOMATIC switching, and a deliberate pick off the ring is not
			// that -- filtering on it would hide guns nothing has stowed.
			// RSQ: no bHolsterHidden on QZD 17.3 (a REMA weapon flag); nothing is skipped.

			if (!eitherHand() && held.bNoHandSwitch && held.bOffhandWeapon != (mRigHand == 1)) continue;

			into.Push(type);
		}
	}

	// THE CARD'S FACE WEAPON, FIRST IN THE LIST.
	//
	// Split out of gatherWeaponCards because expandSlot() needs the SAME
	// ordering and was reading the raw one. Both call slotWeapons(), and both
	// then treat entry 0 as "the one already on the card" -- gatherWeaponCards
	// to decide what to paint on it, expandSlot to decide what to leave OUT of
	// the fan. A promotion applied in one and not the other means the fan hides
	// the wrong weapon, and it did: one ordinary fan pick sets mLastPicked, so
	// the next open promoted that weapon to the front of the CARD's list while
	// the fan still skipped the RAW slot's first entry. The picked weapon then
	// appeared twice (on the card and in its own fan) and the raw first weapon
	// appeared nowhere at all -- unreachable from the ring entirely, from one
	// perfectly normal selection.
	//
	// COLLAPSED ONLY, exactly as it always was: a flat ring shows every variant
	// anyway (order becomes which bearing each sits at, not which one leads),
	// and both expandSlot call sites are already gated on mFansEnabled, so this
	// check reads the same answer for both callers rather than changing either.
	//
	// in out, not out: this REORDERS what the caller already filled rather than
	// filling it. Precedent for the shape -- an array parameter declared in out
	// and handed a plain local -- is wadsrc statscreen.zs:1036
	// GetSortedPlayers(in out Array<int>), called from statscreen_dm.zs:203.
	private void promoteLastPicked(int slot, in out Array<Class<Weapon> > variants)
	{
		if (!mFansEnabled || variants.Size() < 2) return;
		if (slot < 0 || slot >= 10) return;
		if (mLastPicked[slot] == null || variants[0] == mLastPicked[slot]) return;

		for (int vi = 1; vi < variants.Size(); ++vi)
		{
			if (variants[vi] == mLastPicked[slot])
			{
				Class<Weapon> tmp = variants[0];
				variants[0] = variants[vi];
				variants[vi] = tmp;
				break;
			}
		}
	}

	// Fans a slot's other weapons out of its card.
	//
	// OVERLAYS rather than replaces: the eight slot cards stay where they are,
	// so the thing you opened is still visibly the thing you opened, and moving
	// away is the whole of backing out -- no gesture to learn, nothing to undo.
	//
	// A slot holding one weapon never expands. A submenu with a single entry is
	// a step that exists only to be dismissed.
	private void expandSlot(PlayerPawn pmo, int cardIndex)
	{
		collapseSlot();
		if (cardIndex < 0 || cardIndex >= mCardSlots.Size()) return;

		Array<Class<Weapon> > variants;
		slotWeapons(pmo, mCardSlots[cardIndex], variants);

		// THE SAME ORDER THE CARD WAS BUILT FROM. slotWeapons() answers in raw
		// slot order; the card's face came from the PROMOTED order, and the
		// loop below skips entry 0 on the strength of it already being on the
		// card. Fanning the raw list therefore duplicated the promoted weapon
		// and dropped the raw first one out of the ring altogether.
		promoteLastPicked(mCardSlots[cardIndex], variants);

		if (variants.Size() < 2) return;

		mExpanded = cardIndex;

		// A one-shot flash at the card that just opened, distinct from
		// plain hover-tint -- DWELL_TO_EXPAND is fast enough that a
		// fan popping open otherwise reads as the ring having glitched,
		// not as something the player caused. Non-persistent with its own
		// lifetime, not tracked in any array -- it needs no further
		// script involvement after this call, the engine ages it out on
		// its own (p_tick.cpp: lifetime is SECONDS, checked against
		// spawntic/TICRATE, not tics). Sized a shade past the card itself
		// so it reads as a burst FROM the card rather than another plate
		// sitting on it. faceYaw matches layout()'s own formula
		// (viewYaw + 180) since this fires before that tic's layout() has
		// run and there is nothing else here to read it from.
		if (cvBool("wr_flash", true))
		{
			wr_BB.AddBillboard(cardPos(cardIndex), panelWNow() * 1.15, panelHNow() * 1.15,
				pmo.angle + 180, PANEL_TILT, wr_BB.BBF_FIXED,
				wr_BB.BB_RING, 0, COLOR_STACK,
				wr_BB.BBFL_NOHIT, 0.3);
		}

		// The face weapon is already on the slot card, so the fan is everything
		// after it.
		// The whole fan is ONE group, so it unfolds as a unit out of the card
		// that opened it rather than as four independent things that happen to
		// appear together.
		if (mFanGroup != 0) wr_BB.RemoveBillboardGroup(mFanGroup);
		mFanGroup = wr_BB.AddBillboardGroup((0, 0, 0));

		for (int i = 1; i < variants.Size(); ++i)
		{
			let held = Weapon(pmo.FindInventory(variants[i]));
			if (held == null) continue;

			mSubTypes.Push(variants[i]);

			// A SUBCARD IS A CARD. It was not being treated as one.
			//
			// Everything the ring cards gained -- the solved plate, the dry
			// colour, the slot stripe, the held marker, a fitted name -- the fan
			// kept missing, so opening one dropped you from an instrument back
			// to the flat panels this started as. And a fan is exactly where the
			// extra information matters most: its entries are the SAME GUN in
			// different states, so which one is dry and which one your other
			// hand is holding is the entire question being asked.
			// A CLONE CAN OUTRANK ITS SIBLING. Two _2-family instances of
			// the same class can hold different RS tiers -- that is the
			// entire point of owning more than one -- so this resolves
			// PER INSTANCE rather than reusing the parent card's colour.
			// Dry still overrides tier: which one is empty is the more
			// urgent fact when the question is which to grab.
			// shue COMPUTED UNCONDITIONALLY, not inside the ternary.
			//
			// The line this replaced was `srest = sdry ? COLOR_DRY :
			// int(cardColorFor(...))` -- a ternary short-circuits, so on a
			// dry weapon cardColorFor() never ran at all and there was no
			// raw hue left anywhere to give a light or a spark burst. Main
			// cards keep exactly this pair (mBaseColor the dry-aware resting
			// fill, mCardColor the raw hue underneath it) for the same
			// reason: a dry card's light still glows the weapon's true
			// colour even though its plate reads COLOR_DRY.
			bool sdry = (cv("wr_ammo", 1.0) > 0.0 && ammoLoaded(held) == 0);
			int shue  = int(cardColorFor(held, mCardSlots[cardIndex]));
			int srest = sdry ? COLOR_DRY : shue;
			mSubColor.Push(shue);

			// THE DROP SHADOW, same reason a main card has one: a dark plate
			// against a dark wall has almost no edge, and a fan sits in front
			// of whatever the room happens to be exactly as much as the ring
			// does.
			int sshad = 0;
			if (cv("wr_shadow", 0.5) > 0.0)
			{
				sshad = wr_BB.AddBillboardPersistent(
					(0, 0, 0), 3.5, 2.5, 0, 0,
					wr_BB.BBF_FIXED, plateKind(), plateShape(),
					0x000000, wr_BB.BBFL_NOHIT, 0, "");
				wr_BB.SetBillboardGroup(sshad, mFanGroup);
			}
			mSubShadows.Push(sshad);

			// THE HIT QUAD IS NOT THE PICTURE -- the rule spawnPanels states and the
			// ring obeys, which the fan never got.
			//
			// A billboard draws 1.2x taller than it is authored, so a quad that is
			// both the plate and the target answers across only the middle 83% of
			// what you can see: 8% dead at the top of every fan card and 8% at the
			// bottom, with no horizontal margin at all where a ring card gets a
			// twelfth of its width each side.
			//
			// Worse than merely missing, because InputProcess early-returns on
			// mHovered == 0 WITHOUT consuming the press -- so aiming at a dead band
			// and pulling the trigger fires the gun in your hand instead of taking
			// the weapon. Audit finding #15 / #27.
			//
			// Created BEFORE the plate so it sits behind it in the billboard order,
			// same as the ring's.
			int shit = wr_BB.AddBillboardPersistent(
				(0, 0, 0), 3.5, 2.5, 0, 0,
				wr_BB.BBF_FIXED, plateKind(), plateShape(),
				srest, 0, 0, "");
			wr_BB.SetBillboardAlpha(shit, 0.0);
			wr_BB.SetBillboardGroup(shit, mFanGroup);
			mSubHits.Push(shit);

			int sid = wr_BB.AddBillboardPersistent(
				(0, 0, 0), 3.5, 2.5, 0, 0,
				wr_BB.BBF_FIXED, plateKind(), plateShape(),
				srest, wr_BB.BBFL_NOHIT, 0, "");
			wr_BB.SetBillboardGradient(sid, sdry ? GRAD_DRY : GRAD_IDLE);
			wr_BB.SetBillboardGroup(sid, mFanGroup);
			mSubIds.Push(sid);
			mSubBase.Push(srest);

			// Position written every tic in layoutExpansion(); pre-sized here so
			// the array exists before the first layout pass touches it.
			mSubX.Push(0); mSubY.Push(0); mSubZ.Push(0);

			// The parent slot's colour, so a fan reads as belonging to the card
			// it came out of rather than as loose panels near it.
			int sacc = wr_BB.AddBillboardPersistent(
				(0, 0, 0), 3.5, 0.3, 0, 0,
				wr_BB.BBF_FIXED, wr_BB.BB_PANEL, 0,
				mCardColor[cardIndex], wr_BB.BBFL_NOHIT, 0, "");
			wr_BB.SetBillboardGroup(sacc, mFanGroup);
			mSubAccents.Push(sacc);

			// Which hand already holds this one -- and in a fan of _2 clones
			// that is the difference between "take it" and "swap hands".
			int swhere = heldWhere(variants[i]);
			int smid = 0;
			if (swhere != 0 && cv("wr_marker", 1.0) > 0.0)
			{
				smid = wr_BB.AddBillboardPersistent(
					(0, 0, 0), 0.6, 0.6, 0, 0,
					wr_BB.BBF_FIXED, plateKind(), 15,
					(swhere == 2) ? COLOR_MARK_OTHER : COLOR_MARK_MINE,
					wr_BB.BBFL_NOHIT, 0, "");
				wr_BB.SetBillboardGroup(smid, mFanGroup);
			}
			mSubMarks.Push(smid);

			TextureID icon = iconFor(held);
			double sw = ICON_W_FRAC, sh = ICON_H_FRAC;
			// Braced deliberately: a bracketed multi-assign as an unbraced if body
			// starts a statement with '[', which the parser reads as the start of
			// an array rather than as a destructuring assignment.
			if (icon.IsValid())
			{
				[sw, sh] = fitIcon(icon, ICON_W_FRAC, ICON_H_FRAC);
			}

			mSubIconW.Push(sw);
			mSubIconH.Push(sh);

			int siid = 0;
			if (icon.IsValid())
			{
				siid = wr_BB.AddBillboardPersistent(
					(0, 0, 0), 3.5, 2.5, 0, 0,
					wr_BB.BBF_FIXED, wr_BB.BB_TEXTURE, 0,
					0xFFFFFF, wr_BB.BBFL_NOHIT, 0, TexMan.GetName(icon));
				wr_BB.SetBillboardGroup(siid, mFanGroup);
			}
			mSubIcons.Push(siid);

			// The variants in a slot are the same GUN in different states, so the
			// count under each is often the only thing telling them apart.
			int srounds = ammoLoaded(held);
			int said = 0;
			double saw = AMMO_W_FRAC;
			if (cv("wr_ammo", 1.0) > 0.0 && srounds >= 0)
			{
				// Same payload and same text rule as a ring card. A subcard is a
				// weapon like any other and there is no reason for its readout
				// to be a different thing.
				string stext = ammoText(held, srounds);
				saw = readoutAspect(stext);

				said = wr_BB.AddBillboardPersistent(
					(0, 0, 0), 3.5, 2.5, 0, 0,
					wr_BB.BBF_FIXED, readoutKind(), srounds,
					srounds > 0 ? COLOR_AMMO : COLOR_AMMO_DRY,
					wr_BB.BBFL_NOHIT, 0, stext);
				wr_BB.SetBillboardGroup(said, mFanGroup);
			}
			mSubAmmos.Push(said);
			mSubAmmoW.Push(saw);

			double sLoadFrac = ammoLoadedFrac(held);
			mSubLowAmmo.Push(srounds > 0 && sLoadFrac >= 0.0
				&& sLoadFrac < cv("wr_lowammo_frac", 0.25));

			// The same proportion as a bar. A subcard is never canvas-painted
			// (item 2 of the parity pass, deferred -- wr_canvas is off by
			// default and this is the wr_canvas-off path either way), so
			// there is no canvasFace flag to guard against here the way the
			// main build's gauge does.
			//
			// shue, not srest -- a dry weapon's gauge still reads its true
			// colour, matching cardLight()'s own choice for the same reason:
			// the plate says "empty" already, the gauge saying it a second
			// time in the wrong colour would just be noise.
			int sgau = 0;
			double sfrac = ammoLoadedFrac(held);
			if (cv("wr_ammo", 1.0) > 0.0 && sfrac >= 0.0)
			{
				sgau = wr_BB.AddBillboardPersistent(
					(0, 0, 0), 3.5, 0.35, 0, 0,
					wr_BB.BBF_FIXED, wr_BB.BB_BAR, int(sfrac * 100.0 + 0.5),
					shue, wr_BB.BBFL_NOHIT, 0, "");
				wr_BB.SetBillboardGroup(sgau, mFanGroup);
			}
			mSubGauges.Push(sgau);

			// Measured, like a ring card's. Clones tend to have the LONGEST
			// names in a set -- "Plasma Rifle" becomes "Plasma Rifle Mk II" --
			// so the fan is where an unfitted label overflows first.
			string stag = wrapLabel(held.GetTag(), panelWNow() * LABEL_FIT_FRAC, panelHNow());
			int slid = wr_BB.AddBillboardPersistent(
				(0, 0, 0), 3.5, 2.5, 0, 0,
				wr_BB.BBF_FIXED, wr_BB.BB_TEXT, 0,
				COLOR_LABEL, wr_BB.BBFL_NOHIT, 0, stag);
			wr_BB.SetBillboardGroup(slid, mFanGroup);
			mSubLabels.Push(slid);
			mSubLabelH.Push(fitLabel(stag, panelWNow() * LABEL_FIT_FRAC, panelHNow()));
		}

		// THE CONSTELLATION'S LINES, one per star, hub to satellite.
		//
		// Built here rather than in the layout pass for the same reason every
		// other billboard in this file is: layout runs every tic and must only
		// ever move what already exists. Only under wr_constellation -- a plain
		// fan has nothing to connect, its cards being a list rather than a
		// shape -- so in ring/fan mode this array simply stays empty and the
		// layout block that would draw them never has an id to draw.
		//
		// NOT in mFanGroup. The group applies one eased transform to the whole
		// fan about the hub's origin, which is right for cards that arrive as a
		// unit; a line has to be measured and re-laid between two moving points
		// every tic instead, so it is positioned directly.
		if (cv("wr_constellation", 0.0) > 0.0)
		{
			for (int i = 0; i < mSubIds.Size(); ++i)
			{
				mSubLines.Push(wr_BB.AddBillboardPersistent(
					(0, 0, 0), 0.1, LINE_THICK, 0, 0,
					wr_BB.BBF_FIXED, wr_BB.BB_SEAM, 0,
					mCardColor[cardIndex], wr_BB.BBFL_NOHIT, 0, ""));
			}
		}

		// Unfold. Same declaration-not-a-state-machine deal as the ring.
		mFanTics = 0;
		int fanTics = int(cv("wr_growtics", 6.0));
		if (fanTics > 0 && mSubIds.Size() > 0)
		{
			wr_BB.AnimateBillboardGroup(mFanGroup, 0.0, 1.0, fanTics);
		}
	}

	// How far this star's connecting line has drawn, 0..1.
	//
	// Staggered per index off the same wr_growtics the cards themselves ease
	// over, so the web traces outward one link at a time rather than every
	// line snapping taut at once -- the difference between a diagram appearing
	// and a constellation being drawn in front of you.
	private double lineGrow(int i) const
	{
		double span = max(cv("wr_growtics", 6.0), 1.0);
		int stagger = int(cv("wr_star_stagger", 2.0));
		if (stagger <= 0) return clamp(double(mFanTics) / span, 0.0, 1.0);

		double lead = double(i * stagger);
		return clamp((double(mFanTics) - lead) / span, 0.0, 1.0);
	}

	private void collapseSlot()
	{
		// The constellation's lines, freed the same as everything else the
		// expansion owns. Empty in fan mode, so this costs nothing there.
		for (int i = 0; i < mSubLines.Size(); ++i)
		{
			if (mSubLines[i]) wr_BB.RemoveBillboard(mSubLines[i]);
		}
		mSubLines.Clear();
		mFanTics = 0;

		for (int i = 0; i < mSubIds.Size(); ++i)
		{
			if (mSubIds[i]) wr_BB.RemoveBillboard(mSubIds[i]);
			if (i < mSubHits.Size() && mSubHits[i]) wr_BB.RemoveBillboard(mSubHits[i]);
		}
		for (int i = 0; i < mSubIcons.Size(); ++i)
		{
			if (mSubIcons[i]) wr_BB.RemoveBillboard(mSubIcons[i]);
		}
		for (int i = 0; i < mSubAmmos.Size(); ++i)
		{
			if (mSubAmmos[i]) wr_BB.RemoveBillboard(mSubAmmos[i]);
		}
		for (int i = 0; i < mSubLabels.Size(); ++i)
		{
			if (mSubLabels[i]) wr_BB.RemoveBillboard(mSubLabels[i]);
		}
		for (int i = 0; i < mSubAccents.Size(); ++i)
		{
			if (mSubAccents[i]) wr_BB.RemoveBillboard(mSubAccents[i]);
		}
		for (int i = 0; i < mSubMarks.Size(); ++i)
		{
			if (mSubMarks[i]) wr_BB.RemoveBillboard(mSubMarks[i]);
		}
		for (int i = 0; i < mSubShadows.Size(); ++i)
		{
			if (mSubShadows[i]) wr_BB.RemoveBillboard(mSubShadows[i]);
		}
		for (int i = 0; i < mSubGauges.Size(); ++i)
		{
			if (mSubGauges[i]) wr_BB.RemoveBillboard(mSubGauges[i]);
		}
		// The group goes with its members, or the next fan inherits a live
		// animation from the last one.
		if (mFanGroup != 0) wr_BB.RemoveBillboardGroup(mFanGroup);
		mFanGroup = 0;

		mSubIds.Clear();
		mSubHits.Clear();
		mSubIcons.Clear();
		mSubAmmos.Clear();
		mSubLabels.Clear();
		mSubIconW.Clear();
		mSubIconH.Clear();
		mSubAccents.Clear();
		mSubMarks.Clear();
		mSubBase.Clear();
		mSubColor.Clear();
		mSubX.Clear(); mSubY.Clear(); mSubZ.Clear();
		mSubShadows.Clear();
		mSubGauges.Clear();
		mSubAmmoW.Clear();
		mSubLowAmmo.Clear();
		mSubLabelH.Clear();
		mSubTypes.Clear();
		mExpanded = -1;
		mCollapseGrace = 0;
	}

	// True when this billboard belongs to the open fan or to the card that
	// opened it -- i.e. hovering it should NOT collapse the fan.
	// Which card the stick is pointing at, or 0 if it is near centre.
	//
	// The ring's bearings are laid out in the view plane -- x across, z up --
	// which is exactly the plane a thumbstick lives in, so the mapping is one
	// atan2 and a nearest-bearing search. No cursor to steer and nothing to
	// overshoot: a direction IS a slot.
	private int stickPick(PlayerPawn pmo)
	{
		int n = mIds.Size();
		if (n == 0) return 0;

		// GetRawStickMove(), not cmd.sidemove/forwardmove. Those fields are
		// zeroed at the source by the same SuppressVRInput(true) openRig()
		// calls to stop the stick also walking and turning the player --
		// which meant stick-select was reading a channel this ring had
		// itself just cut off, and returned 0 every tic for as long as the
		// ring was open. GetRawStickMove reads the locomotion stick BEFORE
		// that suppression point, so it still reports real deflection.
		//
		// -1..1, not cmd's old thousands-scale ticcmd units -- the engine
		// already applies its own 0.15 deadzone and a curve before this
		// value ever reaches script, so wr_stickdead only needs to add
		// margin on top of that, not define the deadzone from scratch.
		Vector2 stick = wr_VR.GetRawStickMove();
		double sx = stick.Y;
		double sy = stick.X;

		double dead = cv("wr_stickdead", 0.2);
		if (sx * sx + sy * sy < dead * dead) return 0;

		// layout() adds the wrist roll to every bearing (wr_roll); match
		// against the same rotated bearing or the pick is off by the roll.
		double roll = handRollOf(pmo, mRigHand) * cv("wr_roll", 0.0);

		double want = atan2(sy, sx);

		int best = 0;
		double bestOff = 999;


		for (int i = 0; i < n; ++i)
		{
			double d = want - (bearingForIndex(i, n) + roll);
			while (d >  180) d -= 360;
			while (d < -180) d += 360;
			d = abs(d);

			if (d < bestOff) { bestOff = d; best = mIds[i]; }
		}
		return best;
	}

	// BulletTimeX, if it happens to be loaded.
	//
	// Deliberately fire-and-forget: sending its netevent by name means no class
	// reference, so this compiles and runs identically whether or not the mod is
	// present -- a hard type reference would make BulletTimeX a dependency of
	// the wheel, which is exactly what a hook should not do.
	//
	// bt_activate is a TOGGLE and there is nothing to read back, so this cannot
	// tell "start it" from "stop it" -- it can only flip whatever is currently
	// true. Open the rig during a bullet time you started yourself and the flip
	// CANCELS it: the world runs at full speed for the whole of your choice,
	// which is the exact opposite of the point, and closing flips it back on.
	//
	// ON by default anyway, because the case it is wrong for needs you to have
	// already been in bullet time when you opened the wheel, and the case it is
	// right for is every other time. Scoping it properly means asking
	// BulletTimeX what state it is in, and it publishes no way to ask.
	//
	// THE CVAR GATES THE ON DIRECTION ONLY.
	//
	// It used to guard both, as an unqualified early return at the top of this
	// function. Untick the option while the ring is up and the DISABLE was the
	// call that got refused: the world stayed in slow motion with the wheel
	// gone and nothing left on screen to explain it, and the only way back was
	// finding BulletTimeX's own key. A switch may refuse to turn something on.
	// It must never be able to block the turning off of what it already
	// started. mBtOn is the record of what this mod actually did, and the off
	// path answers to that and to nothing else.
	private void bulletTime(bool on)
	{
		if (on && !cvBool("wr_bullettime", true)) return;
		if (on == mBtOn) return;

		// RSQ: RSQ SlowMo when it is loaded -- its own on/off events, which it holds until told
		// otherwise -- and BulletTimeX's toggle (REMA's route) when it is not.
		//
		// SLOW MOTION THAT WAS ALREADY RUNNING when the ring opened (the player's own SlowMo key, the
		// cigarette, adrenaline) is the player's, not the ring's. wr_slowmo_cancel decides what
		// closing the ring does to it: off (the default) leaves it running; on ends it, as before.
		// Slow motion the ring started itself always ends with the ring.
		let it = ServiceIterator.Find("RSQSM_Service");
		let sm = it.Next();
		if (sm)
		{
			if (on)
			{
				mSlowWasOn = sm.GetInt("active") > 0;
				if (!mSlowWasOn) EventHandler.SendNetworkEvent("rsm_on");
			}
			else if (!mSlowWasOn || cvBool("wr_slowmo_cancel", false))
				EventHandler.SendNetworkEvent("rsm_off");
		}
		else EventHandler.SendNetworkEvent("bt_activate");
		mBtOn = on;
	}
	bool mSlowWasOn;   // RSQ: RSQ SlowMo was already running when the ring opened

	private void tintCard(int id, bool lit)
	{
		if (id == 0) return;

		int card = cardIndexOf(id);
		if (card >= 0 && card < mPlates.Size())
		{
			// Unlit goes back to the card's OWN resting colour, not the shared
			// one -- otherwise hovering a dry weapon and moving off it quietly
			// repaints it as a full one, and the warning is gone for good.
			int rest = (card < mBaseColor.Size()) ? mBaseColor[card] : COLOR_IDLE;
			// plateShape(), never 0: UpdateBillboard writes its data argument
			// straight into the billboard, and for an SDF plate that word IS
			// the corner radius and border width. Passing 0 on the first hover
			// turned the card into a sharp, rimless rectangle for good.
			wr_BB.UpdateBillboard(mPlates[card], plateShape(), lit ? COLOR_HOVER : rest);

			// The gradient's far end moves with the near end, or a lit card gets
			// a gold top fading into the resting card's dark blue bottom.
			wr_BB.SetBillboardGradient(mPlates[card],
				lit ? GRAD_HOVER : (rest == COLOR_DRY ? GRAD_DRY : GRAD_IDLE));
			return;
		}

		int sub = subIndexOf(id);
		if (sub >= 0 && sub < mSubIds.Size())
		{
			// subIndexOf matches the alpha-0 hit quad (mSubHits); the plate
			// the player sees is mSubIds[sub]. Recolouring the hit quad was
			// invisible, so fan cards never lit on hover.
			int plate = mSubIds[sub];
			// Back to the subcard's OWN resting colour, not the shared one --
			// the same fix the ring cards needed, and it matters more here:
			// hovering a dry clone and moving off it would repaint it as a
			// loaded one, in the exact place you are trying to tell clones
			// apart.
			int srest = (sub < mSubBase.Size()) ? mSubBase[sub] : COLOR_SUB;
			wr_BB.UpdateBillboard(plate, plateShape(), lit ? COLOR_HOVER : srest);
			wr_BB.SetBillboardGradient(plate,
				lit ? GRAD_HOVER : (srest == COLOR_DRY ? GRAD_DRY : GRAD_IDLE));
		}
	}

	private int cardIndexOf(int id) const
	{
		for (int i = 0; i < mIds.Size(); ++i)
		{
			if (mIds[i] == id) return i;
		}
		return -1;
	}

	private int subIndexOf(int id) const
	{
		// THE HIT QUAD IS WHAT THE POINTER FINDS, so that is what an id resolves
		// against now. The plate is BBFL_NOHIT and can never be hovered.
		for (int i = 0; i < mSubHits.Size(); ++i)
		{
			if (mSubHits[i] == id) return i;
		}
		return -1;
	}

	// Where a fan hangs: outward from the grid's centre, through the card that
	// opened it, and onward. That keeps it clear of the other seven slots, and
	// it means the fan always grows away from your hand rather than back across
	// the cards you were choosing between.
	// The fan's group origin is its PARENT CARD, so the unfold happens out of
	// the card you opened rather than out of the middle of the fan.
	private void layoutExpansion(double base, double spread, Vector3 cardPos, Vector3 viewRight,
	                             double faceYaw, double tilt, double panelW, double panelH,
	                             double cellW)
	{
		if (mExpanded < 0 || mSubIds.Size() == 0) return;

		if (mFanGroup != 0) wr_BB.SetBillboardGroupOrigin(mFanGroup, cardPos);

		// Three bearings fanned about the slot's own -- outward and to either
		// side. Outward IS the free space, so a fan can never cross a neighbour.
		Vector3 lift = (cos(faceYaw), sin(faceYaw), 0) * LABEL_LIFT;

		// Same fix as the main ring's layout() loop: none of these vary per
		// subcard within a single tic, so hoisting them out of the loop
		// below turns N re-reads (plus wr_glow's own double-read, once for
		// the plate and once for the label) into one.
		double hSubDim        = cv("wr_dim", 0.55);
		double hSubShadowOff  = cv("wr_shadow_offset", 0.35) * cv("wr_scale", 1.0) * 0.55;
		double hSubShadow     = clamp(cv("wr_shadow", 0.5), 0.0, 1.0);
		double hSubGlow       = cv("wr_glow", 1.0);
		double hSubLowAmmo    = cv("wr_lowammo_pulse", 0.35);
		bool   cStellar       = cv("wr_constellation", 0.0) > 0.0;

		// Same idle-close warning fade layout() applies to the main ring
		// -- computed fresh here rather than passed in, since this is a
		// separate function with its own hoisting block already. Without
		// this, a fan's own sub-cards -- the ones a player is actually
		// looking at while it's open -- stayed at full brightness right
		// through the ring's idle-close warning window while the rest of
		// the ring visibly dimmed.
		double subWarnFrac = 1.0;
		int subWarnTics = int(cv("wr_warn_tics", 25.0));
		if (subWarnTics > 0 && mLockTics < subWarnTics)
			subWarnFrac = clamp(double(mLockTics) / subWarnTics, 0.15, 1.0);

		for (int i = 0; i < mSubIds.Size(); ++i)
		{
			// Which ring out, and which of the three bearings on it.
			int ring = i / 3;
			int lane = i % 3;

			// Anything past the first three stacks further out along the same
			// bearing rather than wrapping back into the grid.
			//
			// FAN_FIRST_RING, not 1. The first ring used to sit one cell out,
			// and at that radius three cards cannot be far enough apart in
			// ANGLE without swinging so wide they reach a neighbouring slot --
			// see the separation below. Starting a little further out buys the
			// room to separate them properly, and costs a couple of units of
			// reach.
			double reach = cellW * (FAN_FIRST_RING + ring);

			// THE ANGLE COMES FROM THE CARD'S OWN SIZE, not from the slot count.
			//
			// This is what made a fan draw as a tight overlapping grid. Two
			// cards `sep` apart on a circle of radius `reach` are
			// 2*reach*sin(sep/2) apart, so the angle that actually clears a
			// card falls straight out of its width -- invert that and it is an
			// asin. The old code used fanSpread() alone, which answers a
			// completely different question: how much room is there before the
			// next SLOT. On a nine-slot ring that is 18 degrees, and 18 degrees
			// at one card of reach puts 4.2-unit-wide cards 1.6 units apart.
			// They could not not overlap.
			//
			// fanSpread is still the FLOOR: on a sparse ring there is room to
			// spare, and opening the fan wider than the minimum reads better
			// than pinching it to exactly one card of clearance. It just can no
			// longer push the cards into each other.
			double need = 2.0 * asin(clamp(cellW / (2.0 * reach), 0.0, 1.0));
			double sep  = max(spread, need);

			// lane 0 above the bearing, 1 on it, 2 below -- the same order the
			// single-expression version produced.
			double a = base + (1 - lane) * sep;

			// THE CONSTELLATION, an alternative expansion rather than a
			// replacement -- wr_constellation picks, and the fan above is
			// still the default and still untouched.
			//
			// A fan answers "what else is in this slot" as a tidy list. A
			// constellation answers the same question as a SHAPE: the card
			// you opened is the hub, its siblings are stars scattered around
			// it, and a line is drawn from hub to each one as it arrives. The
			// arrangement is what carries the meaning -- which is why the
			// scatter below is DETERMINISTIC (hashed off the sub-card's own
			// index, never frandom) rather than re-rolled every tic. A
			// constellation that reshuffles while you look at it is a lava
			// lamp; one that is the same shape every time you open that slot
			// is something you can come to recognise.
			if (cStellar)
			{
				// Stars ride the same outward bearing the fan uses -- the
				// slot's own direction is still free space, so this can no
				// more cross a neighbour than a fan can -- but spread over a
				// full even sweep rather than three fixed lanes, with each
				// star pushed in or out by its own hashed jitter.
				int sn = mSubIds.Size();
				double swing = max(sep * 1.15, 18.0);
				double frac  = (sn > 1) ? (double(i) / double(sn - 1) - 0.5) : 0.0;

				// Hash the index into two stable 0..1 values -- one for the
				// angular wobble, one for the reach. Cheap integer mixing
				// rather than a table, and identical every open.
				int h  = (i * 2654435761) & 0x7FFFFFFF;
				double jA = double((h >> 7)  & 255) / 255.0 - 0.5;
				double jR = double((h >> 17) & 255) / 255.0;

				a     = base + frac * swing * 2.0 + jA * swing * 0.35;
				reach = cellW * (FAN_FIRST_RING + 0.35 + jR * 1.15);
			}

			Vector3 pos = cardPos
			            + viewRight * (cos(a) * reach)
			            + (0, 0, sin(a) * reach);

			if (i < mSubX.Size()) { mSubX[i] = pos.X; mSubY[i] = pos.Y; mSubZ[i] = pos.Z; }

			// THE LINE DRAWS ITSELF, HUB TO STAR.
			//
			// A seam laid along the hub-to-star vector: parked at the midpoint,
			// as wide as the gap is long, and ROLLED to that angle -- roll is
			// the quad's own in-plane spin, which is exactly the axis that
			// turns a horizontal slit into a line pointing anywhere in the
			// view plane. Height stays hairline whatever the length.
			//
			// It grows rather than appearing: the width is scaled by this
			// star's own arrival progress, so the line reaches out from the
			// hub and lands on the star at the moment the star itself does.
			// Staggered per index, so they trace outward one at a time instead
			// of all snapping taut together.
			if (cStellar && i < mSubLines.Size() && mSubLines[i] != 0)
			{
				Vector3 span = pos - cardPos;
				double  len  = span.Length();

				// The card's own half-width is subtracted from each end so the
				// line runs BETWEEN the two plates rather than under them --
				// a line that passes beneath the hub reads as one long streak
				// crossing the whole constellation rather than as a link.
				double inset = panelW * 0.5;
				double draw  = max(len - inset * 2.0, 0.0) * lineGrow(i);

				double along = viewRight dot span;
				double up    = span.Z;
				double ang   = atan2(up, along);

				wr_BB.MoveBillboard(mSubLines[i], cardPos + span * 0.5 + lift);
				wr_BB.ResizeBillboard(mSubLines[i], draw, LINE_THICK);
				wr_BB.OrientBillboard(mSubLines[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mSubLines[i], ang);
				wr_BB.SetBillboardAlpha(mSubLines[i], draw > 0.01 ? subWarnFrac : 0.0);
			}

			// A SUBCARD IS A CARD, PART THREE -- the same four live values a
			// main card computes for itself once per tic (spawnPanels'
			// layout loop: lit/pulse/cardAlpha/roll), computed once here
			// instead of never. Everything below threads these four through,
			// same shape as the main loop.
			bool slit = (i < mSubHits.Size() && mSubHits[i] == mHovered);

			double spulse = 1.0;
			if (slit)
			{
				// A REDUCED amplitude, not main's straight wr_pulse. Main's
				// default (~1.20x at peak) is tuned against cellW's own
				// static margin; a fan's spacing (`need`, above) already
				// solves for a card at its BASE size with the same margin a
				// slot enjoys on the ring, and inflating the hovered one by
				// a fifth on top of that is what closes the gap the spacing
				// math just opened. Half the amplitude keeps the breathe
				// readable without eating its own clearance.
				double amp = cv("wr_pulse", 0.10) * 0.5;
				spulse = 1.0 + amp + amp * sin(mHoverTics * PULSE_SPEED);
			}

			double subAlpha = 1.0;
			if (mHovered != 0 && !slit) subAlpha = clamp(hSubDim, 0.05, 1.0);
			subAlpha *= subWarnFrac;

			// The take-confirmation flip is applied in WorldTick, not here
			// -- same reason as the main ring's own version of this note.
			// mSubFlipCard (commit()'s own field, separate from mFlipCard
			// since a main card and a sub-card index space overlap) is
			// still what WorldTick reads to know which subcard's billboard
			// to roll.
			double subRoll = 0.0;

			// THE SHADOW. wr_shadow_offset scaled to about half main's --
			// confirmed necessary, not just cautious: `need` above solves
			// clearance for a card's WIDTH only, with no margin held back
			// for a shadow bleeding sideways at FAN_FIRST_RING, where up to
			// three cards already sit at the minimum separation that keeps
			// them off each other.
			if (i < mSubShadows.Size() && mSubShadows[i] != 0)
			{
				double sso = hSubShadowOff;

				wr_BB.MoveBillboard(mSubShadows[i],
					pos - lift * 0.6 + viewRight * sso - (0, 0, sso));
				wr_BB.ResizeBillboard(mSubShadows[i], panelW * spulse * 1.06,
				                                      panelH * spulse * 1.06);
				wr_BB.OrientBillboard(mSubShadows[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mSubShadows[i], subRoll);
				wr_BB.SetBillboardAlpha(mSubShadows[i], hSubShadow * subAlpha);
			}

			// The hit quad tracks the plate but is sized to what is DRAWN, plus the
			// same forgiving pad a ring card gets. Not scaled by spulse: the pulse
			// is the card breathing, and a target that breathes with it would drift
			// in and out from under a steady pointer.
			if (i < mSubHits.Size() && mSubHits[i] != 0)
			{
				wr_BB.MoveBillboard(mSubHits[i], pos);
				wr_BB.ResizeBillboard(mSubHits[i], panelW * HIT_PAD,
				                                   panelH * CARD_STRETCH * HIT_PAD);
				wr_BB.OrientBillboard(mSubHits[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mSubHits[i], subRoll);
			}

			wr_BB.MoveBillboard(mSubIds[i], pos);
			wr_BB.ResizeBillboard(mSubIds[i], panelW * spulse, panelH * spulse);
			wr_BB.OrientBillboard(mSubIds[i], faceYaw, tilt, wr_BB.BBF_FIXED);
			wr_BB.RollBillboard(mSubIds[i], subRoll);

			// THE PLATE GLOWS. Same call, same defaults as a main card's --
			// on BB_PANEL (wr_sdf off) the engine ignores it, so this needs
			// no branch for that case either.
			double sg = hSubGlow;
			wr_BB.SetBillboardGlow(mSubIds[i], slit ? clamp(GLOW_R * sg, 0.0, 1.0) : 0.0,
			                                   slit ? GLOW_S * sg : 0.0);

			if (i < mSubIcons.Size() && mSubIcons[i] != 0)
			{
				wr_BB.MoveBillboard(mSubIcons[i], pos + lift + (0, 0, panelH * 0.20 * spulse));
				wr_BB.ResizeBillboard(mSubIcons[i], panelW * mSubIconW[i] * spulse,
				                                    panelH * mSubIconH[i] * spulse);
				wr_BB.OrientBillboard(mSubIcons[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mSubIcons[i], subRoll);
			}
			// The parent slot's stripe along the top edge.
			if (i < mSubAccents.Size() && mSubAccents[i] != 0)
			{
				wr_BB.MoveBillboard(mSubAccents[i],
					pos + lift + (0, 0, panelH * (0.5 - ACCENT_H_FRAC * 0.5) * spulse));
				wr_BB.ResizeBillboard(mSubAccents[i], panelW * spulse, panelH * ACCENT_H_FRAC * spulse);
				wr_BB.OrientBillboard(mSubAccents[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mSubAccents[i], subRoll);
			}

			if (i < mSubLabels.Size() && mSubLabels[i] != 0)
			{
				wr_BB.MoveBillboard(mSubLabels[i], pos + lift - (0, 0, panelH * 0.07 * spulse));
				wr_BB.ResizeBillboard(mSubLabels[i], panelW * spulse,
				                                     panelH * mSubLabelH[i] * spulse);
				wr_BB.OrientBillboard(mSubLabels[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mSubLabels[i], subRoll);

				// The same neon the ring gets. A fan is a place you are choosing
				// between near-identical things, so "which one is under the
				// pointer" is worth more here than anywhere else.
				//
				// Default unified to 1.0, matching main's own label AND plate
				// glow (both cv("wr_glow", 1.0)) -- this line previously read
				// 1.6, a mismatch that only mattered if the cvar were ever
				// missing from a config, which it never validly is.
				double slg = hSubGlow;
				wr_BB.SetBillboardGlow(mSubLabels[i], slit ? clamp(GLOW_R * slg, 0.0, 1.0) : 0.0,
				                                      slit ? GLOW_S * slg : 0.0);
			}

			if (i < mSubAmmos.Size() && mSubAmmos[i] != 0)
			{
				wr_BB.MoveBillboard(mSubAmmos[i], pos + lift - (0, 0, panelH * 0.41 * spulse));
				wr_BB.ResizeBillboard(mSubAmmos[i], panelW * mSubAmmoW[i] * spulse,
				                                    panelH * AMMO_H_FRAC * spulse);
				wr_BB.OrientBillboard(mSubAmmos[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mSubAmmos[i], subRoll);
			}

			// The proportion, as a bar -- read before the number is.
			if (i < mSubGauges.Size() && mSubGauges[i] != 0)
			{
				wr_BB.MoveBillboard(mSubGauges[i], pos + lift - (0, 0, panelH * 0.26 * spulse));
				wr_BB.ResizeBillboard(mSubGauges[i], panelW * 0.76 * spulse,
				                                     panelH * GAUGE_H_FRAC * spulse);
				wr_BB.OrientBillboard(mSubGauges[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mSubGauges[i], subRoll);

				// Fan counterpart to the main ring's low-ammo gauge pulse.
				if (i < mSubLowAmmo.Size() && mSubLowAmmo[i] && hSubLowAmmo > 0.0)
				{
					double slf = 0.5 + 0.5 * sin(level.maptime * SHIMMER_SPEED + i * SHIMMER_PHASE);
					double slg = hSubLowAmmo * slf;
					wr_BB.SetBillboardGlow(mSubGauges[i], clamp(GLOW_R * slg, 0.0, 1.0), GLOW_S * slg);
				}
			}

			// The held mark, same corner as a ring card's.
			if (i < mSubMarks.Size() && mSubMarks[i] != 0)
			{
				wr_BB.MoveBillboard(mSubMarks[i],
					pos + lift * 1.5
					    + viewRight * (panelW * 0.40 * spulse)
					    + (0, 0, panelH * 0.34 * spulse));
				wr_BB.ResizeBillboard(mSubMarks[i], panelW * 0.10 * spulse, panelH * 0.13 * spulse);
				wr_BB.OrientBillboard(mSubMarks[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mSubMarks[i], subRoll);
			}

			// FOCUS, LAST -- fading every element by the SAME subAlpha this
			// card just computed, mirroring the order main's own loop fades
			// in (after every element's move/resize, so nothing here can be
			// touched by a call that has not run yet).
			fade(mSubIds[i], subAlpha);
			if (i < mSubShadows.Size()) fade(mSubShadows[i], subAlpha);
			if (i < mSubIcons.Size())   fade(mSubIcons[i], subAlpha);
			if (i < mSubAccents.Size()) fade(mSubAccents[i], subAlpha);
			if (i < mSubLabels.Size())  fade(mSubLabels[i], subAlpha);
			if (i < mSubAmmos.Size())   fade(mSubAmmos[i], subAlpha);
			if (i < mSubGauges.Size())  fade(mSubGauges[i], subAlpha);
			if (i < mSubMarks.Size())   fade(mSubMarks[i], subAlpha);
		}
	}

	private bool belongsToExpansion(int id) const
	{
		if (mExpanded < 0) return false;
		if (mExpanded < mIds.Size() && mIds[mExpanded] == id) return true;

		for (int i = 0; i < mSubHits.Size(); ++i)
		{
			if (mSubHits[i] == id) return true;
		}
		return false;
	}

	// Slot number to grid cell, CLOCKWISE around the ring:
	//
	//   1 2 3
	//   8 . 4
	//   7 6 5
	//
	// Row-major numbering would put slot 4 on the left and slot 5 on the right,
	// which reads as two half-rows rather than one ring. Going round means every
	// slot has a compass bearing, and that bearing is what its variant fan grows
	// along -- so a fan can never cross another slot.
	// A RING OF N, not a 3x3 of eight.
	//
	// Eight slots on a 3x3 was the shape that fit, not the shape that is right:
	// it caps at eight, and its corners sit 1.41x further out than its edges, so
	// the "ring" is really a squashed box. Spacing them evenly round a circle
	// costs nothing, holds any number, and puts every card the same reach away.
	//
	// At eight it lands on the same compass bearings as before -- 135 for the
	// first, 45 degrees apart, clockwise -- so nothing about the feel changes at
	// the count you have been testing.
	private static double bearingForIndex(int i, int count)
	{
		if (count < 1) count = 1;
		return 135.0 - i * (360.0 / count);
	}


	// How far a fan spreads either side of its slot's bearing. Capped at 45, but
	// squeezed as the ring gets crowded so a fan cannot reach into the next
	// slot's territory.
	// The fan's MINIMUM spread, not its actual one. layoutExpansion widens
	// past this whenever the cards would otherwise touch -- which on a busy
	// ring is always, since this narrows exactly when the fan needs more
	// room, not less. Kept because a sparse ring has space to spare and a
	// fan opened wider than the bare minimum reads better than one pinched
	// to a single card of clearance.
	private static double fanSpread(int count)
	{
		if (count < 1) count = 1;
		double half = (360.0 / count) * 0.5;
		return min(45.0, half * 0.9);
	}

	// The centre cell: what this hand is already holding.
	//
	// BBFL_NOHIT throughout -- it is a readout, not a choice. Reaching into the
	// middle is how you say "never mind", and it should not be possible to
	// re-select what you already have by accident.
	// AltHUDIcon first, pickup Icon second.
	//
	// That is what BaseStatusBar.GetInventoryIcon(DI_ALTICONFIRST) does, but the
	// native is ui-scoped and everything here runs in the playsim -- so it reads
	// the two fields off Inventory itself, which are plain TextureIDs and carry
	// no scope restriction at all.
	// Pull the graphic a named state actually draws. GetSpriteTextureID() reads
	// the actor's LIVE sprite, and a weapon sitting in your backpack is not
	// animating -- so for most of them that call returns nothing and the card
	// comes out blank. The state's own sprite/frame pair is fixed at compile
	// time and does not care what the actor is doing.
	private static TextureID spriteOf(Actor a, StateLabel which)
	{
		TextureID none;
		none.SetInvalid();
		if (a == null) return none;

		State st = a.FindState(which);
		if (st == null || !st.ValidateSpriteFrame()) return none;

		TextureID tex;
		bool mirror;
		Vector2 scale;
		[tex, mirror, scale] = st.GetSpriteTexture(0);
		return tex;
	}

	private static TextureID iconFor(Inventory it)
	{
		TextureID none;
		none.SetInvalid();
		if (it == null) return none;

		// The pickup sprite -- the thing you'd see lying on the floor. This is
		// what a weapon is recognisable AS, so it leads.
		TextureID pickup = spriteOf(it, 'Spawn');
		if (pickup.IsValid()) return pickup;

		// Mods that bothered to author a real icon get it honoured next.
		if (it.AltHUDIcon.IsValid()) return it.AltHUDIcon;
		if (it.Icon.IsValid())       return it.Icon;

		// Fist and friends never spawn in the world and have no pickup sprite at
		// all. Their held graphic is the only picture of them that exists.
		TextureID ready = spriteOf(it, 'Ready');
		if (ready.IsValid()) return ready;

		// RSQ: GetSpriteTextureID is REMA's; the current frame's sprite is the same answer.
		if (it.CurState)
		{
			TextureID cur;
			bool flip;
			Vector2 sc;
			[cur, flip, sc] = it.CurState.GetSpriteTexture(0);
			return cur;
		}
		return none;
	}


	// THE SECONDARY PILE, when there is a separate one.
	//
	// Every reading in this mod went through Ammo1, so a weapon whose alt fire
	// draws from its own reserve showed nothing about it -- you could take a
	// grenade launcher with a full primary and no grenades and the ring would
	// have said it was fine.
	//
	// Only when the two are DIFFERENT ACTORS. A weapon that spends the same pool
	// faster on alt fire has Ammo2 pointing at the same Ammo instance as Ammo1,
	// and printing that number twice would be a readout that says nothing and
	// costs a row.
	// A MAGAZINE IS NOT AN ALT FIRE, and the same field carries both.
	//
	// Weapon.Ammo2 means "the second ammo type", and two completely different
	// systems use it. A weapon with a real alt fire keeps a separate pile for
	// it. A weapon with a magazine keeps its LOADED ROUNDS there and refills
	// them from Ammo1, which is then the reserve -- that is exactly what
	// RS_Main does: `needed = Capacity - CountInv(AmmoType2)`, filled from
	// `reserve = AmmoType1`.
	//
	// Reading Ammo2 as alt fire on a magazine weapon gets the numbers right and
	// the meaning backwards, and worse, it means the FIRST number -- the one
	// with all the emphasis -- is your backpack rather than what is in the gun.
	//
	// Told apart by asking whether an alt fire exists at all. No AltFire state
	// means Ammo2 cannot be feeding one, whatever else it is for.
	//
	// Not `private` -- wr_gunhud.zs's own hasMagazine() used to carry a
	// byte-identical inline copy of this exact check, which is how it
	// missed the alt-fire exclusion fix landing here without a matching
	// edit there. Same pk3, same load unit, so calling wr_Rig.hasAltFire
	// from another class in this mod is a same-mod call, not a real
	// external dependency.
	clearscope static bool hasAltFire(Weapon w)
	{
		return w != null && w.FindState('AltFire') != null;
	}

	// Ammo2 as a magazine: a second pile, no alt fire to spend it, and a
	// capacity meaningfully smaller than the reserve it is drawn from.
	private static bool hasMagazine(Weapon w)
	{
		if (w == null || w.Ammo2 == null || w.Ammo2 == w.Ammo1) return false;
		if (hasAltFire(w)) return false;
		return true;
	}

	private static bool hasSecondAmmo(Weapon w)
	{
		return w != null && w.Ammo2 != null && w.Ammo2 != w.Ammo1 && hasAltFire(w);
	}

	// What the bezel reads. "24" normally, "24|3" when alt fire has its own
	// reserve.
	//
	// A separator rather than a second billboard: the readout is already a
	// bordered plate the width of half a card, and hanging another one under it
	// would cost a row the card has not got. The bar is one glyph in the
	// 16-segment alphabet, so it costs nothing to draw.
	//
	// BB_WG13 is the exception and cannot show this -- it takes a NUMBER in
	// `data`, not text, so it can only ever report the primary. Documented
	// rather than worked around; picking the lozenge is picking that trade.
	private static string ammoText(Weapon w, int rounds)
	{
		// Loaded first, reserve second -- the order the gun cares about. A
		// magazine weapon reads "8|112": eight in it, a hundred and twelve
		// behind it.
		int res = ammoReserve(w);
		if (res >= 0) return String.Format("%d|%d", rounds, res);

		int alt = ammoLeft2(w);
		if (alt < 0) return String.Format("%d", rounds);
		return String.Format("%d|%d", rounds, alt);
	}

	private static int ammoLeft2(Weapon w)
	{
		if (!hasSecondAmmo(w)) return -1;
		return w.Ammo2.Amount;
	}

	private static double ammoFrac2(Weapon w)
	{
		if (!hasSecondAmmo(w)) return -1.0;

		int cap = w.Ammo2.MaxAmount;
		if (cap <= 0) return -1.0;
		return clamp(double(w.Ammo2.Amount) / cap, 0.0, 1.0);
	}

	// How many rounds this weapon can fire right now, or -1 for one that does not
	// use ammo at all.
	//
	// Ammo1 is the field, and it is only populated once the weapon has been
	// picked up -- which every weapon on a card has been, since the card only
	// exists because FindInventory returned it.
	// WHAT IS IN THE GUN, not what is in the backpack.
	//
	// On a magazine weapon the loaded rounds live in Ammo2 and Ammo1 is the
	// reserve, so reading Ammo1 as the headline number reported the pile you
	// are NOT currently able to fire. Every card, every ammo bar and every dry
	// warning was answering the wrong question for those weapons -- including
	// the dry test, which called a gun with an empty reserve and a full
	// magazine "dry".
	private static int ammoLoaded(Weapon w)
	{
		if (hasMagazine(w)) return w.Ammo2.Amount;
		return ammoLeftRaw(w);
	}

	private static int ammoLoadedCap(Weapon w)
	{
		if (hasMagazine(w)) return w.Ammo2.MaxAmount;
		return ammoCapRaw(w);
	}

	private static double ammoLoadedFrac(Weapon w)
	{
		int cap = ammoLoadedCap(w);
		if (cap <= 0) return -1.0;
		return clamp(double(ammoLoaded(w)) / cap, 0.0, 1.0);
	}

	// The reserve behind a magazine, or -1 when there is not one.
	private static int ammoReserve(Weapon w)
	{
		if (!hasMagazine(w) || w.Ammo1 == null) return -1;
		return w.Ammo1.Amount;
	}

	private static int ammoLeftRaw(Weapon w)
	{
		if (w == null || w.Ammo1 == null) return -1;
		return w.Ammo1.Amount;
	}

	// The size to draw an icon at so it keeps its shape inside a box, returned as
	// FRACTIONS of the card so it survives wr_scale changing under it.
	//
	// Every icon used to be stretched to the same rectangle, so a rocket launcher
	// and a pistol came out identically proportioned -- which defeats the point
	// of showing a picture at all, on a ring whose whole premise is being
	// readable at a glance.
	//
	// The 1.2 is the billboard vertical stretch: the view matrix stretches world
	// Z and the billboard path never unstretches it, so an authored square
	// renders as a tall rectangle. Undo it here or "keeps its shape" is a lie.
	private static double, double fitIcon(TextureID tex, double boxWFrac, double boxHFrac)
	{
		Vector2 sz = TexMan.GetScaledSize(tex);
		if (sz.X <= 0.0 || sz.Y <= 0.0) return boxWFrac, boxHFrac;

		// Card aspect in the same units the fractions are in.
		double aspect = sz.X / sz.Y;

		// The live card ratio (wr_panel_w / wr_panel_h), not PANEL_W/PANEL_H:
		// those constants are no longer what the card is drawn at, and every
		// icon was squashed by the difference -- more so with tuned panels.
		double cardAspect = panelWNow() / panelHNow();
		if (cardAspect <= 0.0) cardAspect = PANEL_W / PANEL_H;

		double w = boxWFrac;
		double h = (w * cardAspect) / (aspect * CARD_STRETCH);

		if (h > boxHFrac)
		{
			h = boxHFrac;
			w = h * aspect * CARD_STRETCH / cardAspect;
		}
		return w, h;
	}

	// One colour per slot, matching the engine's own vr_laser_color_slotN idea.
	//
	// A slot's bearing is already fixed so the ring can be learned by feel; a
	// fixed colour is the same promise made to the eye. It also means the beam
	// and the card it lands on can agree, which is the difference between a
	// pointer that indicates and one that merely reaches.
	private static color slotColor(int slot)
	{
		switch (slot)
		{
			case 1: return 0x8A8F98;   // fist, chainsaw -- no ammo, so no hue
			case 2: return 0xE8C547;
			case 3: return 0xE07A3E;
			case 4: return 0x4FA3D1;
			case 5: return 0xD1503F;
			case 6: return 0x7B5FD1;
			case 7: return 0x3FBF6F;
			case 8: return 0xD14F9B;
			case 9: return 0x46C6C0;
		}
		return 0x8A8F98;              // slot 0 and anything a mod invented
	}

	// -----------------------------------------------------------------
	// THE REAL COLOUR FOR A CARD, tier first. Owner's ask: "can all the
	// cards for all the sets be colored, even if they're colored by
	// their rarity tier? otherwise if they don't have one can't the
	// slots themselves get fun colors?" -- both halves of that, in order.
	//
	// 1. TIER, if the weapon has one AND wr_tier_color wants it. Asked of
	//    RS_Main's own tier table through RS_TierColorService rather than
	//    by naming RS_Weapon or RS_TierPalette directly -- the same bridge
	//    wr_RigService opened going the other way, and for the identical
	//    reason: a direct class reference needs that class to exist AT
	//    COMPILE TIME, and this mod is meant to stand alone without
	//    RS_Main installed. Service.Find returns null and this falls
	//    through cleanly if RS_Main is not loaded, or is an older build
	//    without the Service.
	//
	//    Off by default reason for wr_tier_color existing at all: RS_Main's
	//    ladder runs Cursed/Trash/BASIC/Common/Uncommon/Advanced/Designer/
	//    Prototype, and Basic -- third of eight, not an edge case, the tier
	//    most drops and every fresh grant actually land on -- is white BY
	//    DESIGN (RS_TierPalette.zs). A ring built mostly from starting gear
	//    is a ring built mostly from white cards, correctly, which is not
	//    the same as being wrong. wr_tier_color 0 skips the tier lookup
	//    entirely so testing (or anyone who would rather have variety than
	//    rarity-at-a-glance) gets the palette below instead.
	//
	// 2. THE CLASSIC SLOT PALETTE, for the nine weapons that actually
	//    have one -- unchanged, this is why Rig Test was already
	//    colourful.
	//
	// 3. A FUN COLOUR, HASHED FROM THE CLASS NAME, for everything left --
	//    a modded weapon with no RS tier and no classic slot, which
	//    previously fell through to the same flat grey as every other
	//    such weapon. Hashed rather than random so the SAME weapon is
	//    always the SAME colour, tic to tic and session to session, the
	//    same promise slotColor already makes for the nine stock guns.
	// -----------------------------------------------------------------
	private static color cardColorFor(Weapon held, int slot)
	{
		if (held && cv("wr_tier_color", 1.0) > 0.0)
		{
			bool found; color tier;
			[found, tier] = rsTierLookup(held);
			if (found) return tier;

			[found, tier] = wr_CompatLegenDoom.TierOf(held);
			if (found) return tier;

			[found, tier] = wr_CompatDRLA.ColorOf(held);
			if (found) return tier;

			[found, tier] = wr_CompatDoomablo.TierOf(held);
			if (found) return tier;
		}

		if (slot >= 1 && slot <= 9) return slotColor(slot);

		return hueOf(classNameHash(held), 16);
	}

	// THE RAW RS_MAIN LOOKUP, pulled out of cardColorFor so the sheet's own
	// tierColorOf() (below slotOf(), near line 943) can ask for it
	// unconditionally. That function used to just forward to cardColorFor,
	// which meant the TIER stat row lost its colour the instant wr_tier_color
	// went off -- the same bug this session already found and fixed for the
	// sheet's title, one call site over.
	private static bool, color rsTierLookup(Weapon held)
	{
		color none;
		if (!held) return false, none;

		// ServiceIterator.Find, NOT Service.Find -- Service's own Find
		// takes class<Service>, an actual TYPE, so a string literal there
		// still makes the compiler resolve RS_TierColorService at compile
		// time and fail to build without RS_Main loaded. ServiceIterator.
		// Find(String) is the real runtime lookup.
		let svc = ServiceIterator.Find("RS_TierColorService").Next();
		if (!svc) return false, none;

		int packed = svc.GetInt("TierColorOf", "", 0, 0, held);
		if (packed < 0) return false, none;

		return true, color(255, (packed >> 16) & 0xFF, (packed >> 8) & 0xFF, packed & 0xFF);
	}

	// A simple mixing hash over the class name's bytes -- this owes
	// nothing to cryptographic quality, only to spreading different
	// names across hueOf's sixteen steps instead of clumping them.
	private static int classNameHash(Weapon w)
	{
		if (!w) return 0;
		// GetClassName() returns a Name, not a String -- concatenation is
		// the conversion ZScript actually offers between the two.
		string nm = "" .. w.GetClassName();
		int h = 0;
		int len = int(nm.Length());   // Length() is unsigned; the raw
		                               // comparison against a signed loop
		                               // counter is what the warning flagged.
		for (int i = 0; i < len; ++i)
			h = (h * 131 + nm.ByteAt(i)) & 0x7FFFFFFF;
		return h;
	}

	// Ammo as a fraction of capacity, or -1 for a weapon that uses none.
	private static double ammoFrac(Weapon w)
	{
		if (w == null || w.Ammo1 == null) return -1.0;
		int cap = w.Ammo1.MaxAmount;
		if (cap <= 0) return -1.0;
		return clamp(double(w.Ammo1.Amount) / cap, 0.0, 1.0);
	}

	// The label height, as a fraction of the card, that keeps the name INSIDE
	// the card.
	//
	// Names are not a fixed length -- "Fist" and "Super Shotgun" were being
	// drawn at the same size in the same box, so one floated in space and the
	// other ran off both edges. MeasureBillboardText knows the real advance of
	// the face it will actually draw in, which is the only way to get this
	// right: counting characters is correct for a monospace atlas and silently
	// wrong for every other, and the roster is reshuffled per game.
	//
	// Returns 0 from the engine when no SDF atlas is loaded. That means
	// "estimate it yourself", not "the string is empty", so it is left alone.
	// BREAK A NAME OVER TWO LINES RATHER THAN SHRINKING IT.
	//
	// A long name used to be scaled down until it fitted one line, so "Rocket
	// Launcher" ended up drawn at half the size of "Fist" on the same ring --
	// the cards that need reading most became the hardest to read.
	//
	// BB_TEXT stacks a string containing '\n' as centred lines by itself, so
	// this only has to choose WHERE. The split goes at the space nearest the
	// middle, which keeps two lines of roughly equal length instead of a long
	// one over a stub.
	//
	// One break only. Three lines in a card this size is smaller than the
	// shrink it was avoiding.
	private static string wrapLabel(string text, double boxW, double panelH)
	{
		double h = panelH * LABEL_HEIGHT_FRAC;
		if (h <= 0.0) return text;

		double w = wr_BB.MeasureBillboardText(text, h, 0);

		// 0 means no SDF atlas is loaded and the measure is unavailable -- that
		// is "estimate it yourself", not "the string is empty", so leave it be.
		if (w <= 0.0 || w <= boxW) return text;

		int best = -1;
		// Length() is unsigned; cast once rather than compare a signed loop
		// counter against it every iteration -- same fix as classNameHash.
		int len = int(text.Length());
		int mid = len / 2;
		for (int i = 0; i < len; ++i)
		{
			if (text.ByteAt(i) != 0x20) continue;          // ' '
			if (best < 0 || abs(i - mid) < abs(best - mid)) best = i;
		}

		// Nothing to break on. A single long word gets the old shrink, which is
		// the correct answer for it.
		if (best <= 0) return text;

		return text.Left(best) .. "\n" .. text.Mid(best + 1);
	}

	private static double fitLabel(string text, double boxW, double panelH)
	{
		double h = panelH * LABEL_HEIGHT_FRAC;
		if (h <= 0.0) return LABEL_HEIGHT_FRAC;

		// MeasureBillboardText reports the WIDEST line of a wrapped string, so
		// this works unchanged on one line or two -- which is the whole reason
		// wrapLabel can hand its result straight here.
		double w = wr_BB.MeasureBillboardText(text, h, 0);
		if (w <= 0.0) return LABEL_HEIGHT_FRAC;

		if (w > boxW) h *= boxW / w;

		// A WRAPPED NAME STILL RETURNS THE PER-LINE HEIGHT.
		//
		// BB_TEXT's height is the height of ONE line -- it stacks the rest
		// itself. Returning the whole block's height made every line that tall,
		// so a two-line name drew at double size and ran off both edges of its
		// card, which is exactly what it did.
		//
		// The block measurement is still needed, but to SHRINK with: if two
		// lines at this size are taller than the name's share of the card, the
		// per-line height comes down until they fit.
		if (text.IndexOf("\n") >= 0)
		{
			Vector2 blk = wr_BB.MeasureBillboardTextBlock(text, h, 0);
			double room = panelH * LABEL_BLOCK_FRAC;

			if (blk.Y > room && blk.Y > 0.0) h *= room / blk.Y;
		}

		return h / panelH;
	}

	// Which plate payload the cards are built from, and the shape numbers that
	// only the solved one reads.
	// The live card size, for the places that need it OUTSIDE layout() -- the
	// label fitter runs at spawn, before layout has computed anything.
	private static double panelWNow() { return cv("wr_panel_w", 4.2) * cv("wr_scale", 1.0); }
	private static double panelHNow() { return cv("wr_panel_h", 3.0) * cv("wr_scale", 1.0); }

	private static int plateKind()
	{
		return (cv("wr_sdf", 1.0) > 0.0) ? wr_BB.BB_SDFPANEL
		                                 : wr_BB.BB_PANEL;
	}

	// Corner radius in byte 0, border width in byte 1, each 0-15 across the
	// half-extent. BB_PANEL ignores it, which is why this can be handed to
	// both without a branch at every call site.
	private static int plateShape()
	{
		int rad = int(clamp(cv("wr_plate_radius", 4.0), 0.0, 15.0));
		int bor = int(clamp(cv("wr_plate_border", 2.0), 0.0, 15.0));
		return rad | (bor << 8);
	}

	// PAINT A CARD'S FACE INTO A CANVAS TEXTURE.
	//
	// The other way to build a card is the way this mod already does it: one
	// billboard per element, each positioned, oriented, rolled and scaled in
	// MAP UNITS every tic, with the layout expressed as fractions of the panel
	// tuned by eye. That works and it stays sharp, because the text payloads are
	// distance fields.
	//
	// This is the other option. Compose the face as an image, in ordinary 2D
	// pixel coordinates where "the bar sits eight pixels under the icon" is
	// eight pixels, and hand the card one texture. Anything drawable becomes a
	// card: a dial instead of a bar, a silhouette with marks over it, pips
	// instead of a number.
	//
	// The trade is real and it is why BOTH exist. A canvas is a RASTER -- held
	// close in VR it shows its pixels, where BB_SEGMENT never will. So the name
	// and the count stay as field billboards on top, and the canvas carries the
	// artwork underneath them.
	//
	// REPAINTED EVERY TIC, and that is not a choice.
	//
	// A canvas is a COMMAND QUEUE, not a picture. hw_entrypoint's update loop
	// does exactly this:
	//
	//     Draw2D(&canvas->Drawer, ...);
	//     canvas->Drawer.Clear();
	//
	// -- it plays the queue into the texture and then empties it. Meanwhile
	// binding the texture to draw a card re-flags it as needing an update. So a
	// canvas that stays on screen is re-rendered every frame from a queue that
	// is empty after the first one, and since these are translucent canvases the
	// engine clears them to transparent when there is nothing to draw.
	//
	// Painting once therefore gave exactly one good frame and then bare plates
	// for the rest of the ring's life, with the odd card catching whatever was
	// left in the framebuffer.
	//
	// Cheap enough: a few dozen queued 2D ops per card at 35Hz, for at most
	// twelve cards, and nothing here touches the playsim.
	// THE CANVAS SAMPLES UPSIDE DOWN.
	//
	// A canvas texture is rendered into an FBO and then read back as an ordinary
	// texture, and the V axis flips somewhere between those two -- so a face
	// painted the obvious way arrives on the card mirrored top to bottom. It is
	// invisible until there is content: an empty canvas looks identical either
	// way up, which is why this survived the first two passes and only showed
	// itself as an upside-down revolver.
	//
	// Everything below authors in NATURAL coordinates -- y=0 is the top of the
	// card as you look at it -- and these three convert. Doing it here rather
	// than pre-flipping every number means the layout still reads as the layout.
	private static int fy(int y) { return FACE_H - y; }

	// Clear takes a top and a bottom, and flipping swaps which is which.
	private void clearFlipped(Canvas c, int l, int t, int r, int b, color col)
	{
		c.Clear(l, fy(b), r, fy(t), col);
	}

	// Dim takes a top-left and a size, so only the origin moves.
	private void dimFlipped(Canvas c, color col, double amt, int x, int y, int w, int h)
	{
		c.Dim(col, amt, x, fy(y + h), w, h);
	}

	// AMMO AS A BAR, not pips any more.
	//
	// Pips had a real fault, not a cosmetic one: PIP_LITERAL_MAX drew one
	// pip per round below twelve and ten pips as tenths above it, so a
	// magazine draining PAST that line changed how many pips were on
	// screen and which ones were lit -- a 30-round mag went from ten
	// tenths-pips straight to twelve literal ones at the exact moment it
	// crossed 12 rounds. Nothing reloaded; the display just reflowed
	// mid-drain, and from across a ring that reads as a refill. Reported
	// exactly that way: "the pips count down, then resize/refill, then
	// count down again". A bar has one state, always -- it shrinks
	// monotonically as you fire and grows only on an actual reload.
	private void barRow(Canvas c, int top, double frac, color tint)
	{
		if (frac < 0.0) return;

		int left  = BAR_INSET;
		int right = FACE_W - BAR_INSET;
		int bot   = top + BAR_H;

		// The trough, always drawn -- an empty bar still says "there is a
		// gauge here", the same reason a token card's trough draws at
		// zero fill instead of vanishing.
		clearFlipped(c, left, top, right, bot, dim(tint, 0.18));

		int fillR = left + int((right - left) * clamp(frac, 0.0, 1.0));
		if (fillR > left)
			clearFlipped(c, left, top, fillR, bot, tint);
	}

	// faceColor used to be a raw slot number, resolved to a colour inside
	// this function -- moved to cardColorFor(), called ONCE per card at
	// build time (gatherWeapons), because this function itself repaints
	// every tic in canvas mode and a per-tic cross-mod Service round trip
	// for every card was not a cost worth paying four times over below.
	private TextureID paintFace(int pool, Weapon held, color faceColor, bool dry, bool dbg = false)
	{
		TextureID none;
		none.SetInvalid();

		string name = String.Format("WRFACE%02d", pool);

		let canvas = TexMan.GetCanvas(name);
		if (canvas == null) return none;   // not declared, or not a canvas

		// Without this the untouched corners come out opaque black instead of
		// letting the plate behind show through.
		// RSQ: SetCanvasTextureTranslucent is REMA's; canvases do not draw in VR on QZD 17.3 anyway.

		int bg = dry ? COLOR_DRY : COLOR_IDLE;

		// The gradient, as bands. A canvas has no gradient primitive, and five
		// steps across a hundred pixels is under the eye's threshold at the size
		// a card is ever seen.
		for (int b = 0; b < FACE_BANDS; ++b)
		{
			int y0 = FACE_H * b / FACE_BANDS;
			int y1 = FACE_H * (b + 1) / FACE_BANDS;

			double k = 1.0 - 0.55 * (double(b) / (FACE_BANDS - 1));
			clearFlipped(canvas, 0, y0, FACE_W, y1, dim(bg, k));
		}

		// The card's colour along the top edge, same promise the accent
		// bar makes on the composed card.
		clearFlipped(canvas, 0, 0, FACE_W, FACE_ACCENT, faceColor);

		// THE GUN RUNS OFF THE EDGES.
		//
		// This is the one thing the billboard path cannot do at all. A billboard
		// has no clip -- a quad draws its whole texture -- so the composed card
		// can only ever SHRINK a sprite until it fits inside a box, which is why
		// every icon there sits politely in the middle looking like a catalogue
		// photo. A canvas crops. Draw the shotgun at 130% and its stock and
		// muzzle leave the card, and it reads as a weapon rather than a picture
		// of one.
		TextureID icon = iconFor(held);

		if (dbg)
		{
			Console.Printf("\c[Cyan]RSVR HUD face[%d]:\c- %s icon.valid=%d idx=%d",
				pool, held ? (held.GetClassName() .. "") : "null",
				int(icon.IsValid()), 0);
		}

		if (icon.IsValid())
		{
			Vector2 sz = TexMan.GetScaledSize(icon);
			double aspect = (sz.X > 0 && sz.Y > 0) ? (sz.X / sz.Y) : 1.6;

			double bleed = clamp(cv("wr_canvas_bleed", 1.30), 0.6, 2.5);
			double iw = FACE_W * bleed;
			double ih = iw / aspect;

			// Bleeding sideways is the good version; bleeding through the top
			// and bottom takes the whole silhouette away, so height is capped
			// and the width follows it back down.
			// Capped to the artwork band, not the whole canvas: the lower third is
			// the readouts and a sprite that reaches it is a sprite behind a label.
			// The sprite may use the whole artwork band. It was capped to the gap
			// between the ammo bars and the readout line, which is a smaller number and
			// left every gun drawn as a thin strip.
			double hcap = ICON_BOX_H * 1.35;
			if (ih > hcap) { ih = hcap; iw = ih * aspect; }

			// DTA_CENTEROFFSET IS THE WHOLE REASON THE SPRITES WERE MISSING.
			//
			// A Doom sprite carries baked-in offsets, and a pickup's put its
			// origin at the item's FEET -- so the draw position is not the
			// top-left of the image, it is a point somewhere below and left of
			// it. Drawing at y=11 with an offset like that puts the entire
			// sprite off the top of a hundred-pixel canvas, silently, with the
			// call succeeding.
			//
			// Overriding to the texture's middle makes the position mean what it
			// looks like it means, and lets the same coordinate work for sprites
			// whose offsets disagree with each other -- which, across a weapon
			// set, they always do.
			double cx = FACE_W * 0.5;
			double cy = ICON_TOP + ICON_BOX_H * 0.5;

			if (dbg) Console.Printf(
				"\c[Cyan]RSVR HUD draw[%d]:\c- sz=(%.1f,%.1f) aspect=%.2f iw=%.1f ih=%.1f "
				"pos=(%.1f,%.1f) canvas=%dx%d",
				pool, sz.X, sz.Y, aspect, iw, ih, cx, fy(int(cy)), FACE_W, FACE_H);

			// A dark twin, offset, underneath. Weapon sprites are lit every
			// which way across a weapon set; a shadow gives all of them the same
			// weight and lifts them off the plate.
			//
			// DTA_AlphaChannel with DTA_FillColor is the pair that gives a
			// silhouette; DTA_FillColor alone stencils the colour but keeps the
			// source's own shading, which is not a shadow.
			// DTA_FLIPY AS WELL AS A FLIPPED POSITION.
			//
			// Two separate corrections and both are needed. Moving the sprite to
			// fy(cy) puts it in the right PLACE on a canvas that samples upside
			// down; flipping the image is what stops the revolver arriving
			// barrel-up once it gets there. Fix only one and it is still wrong,
			// just wrong differently.
			//
			// The shadow is offset DOWNWARD on screen, which is upward here.
			if (cv("wr_canvas_shadow", 1.0) > 0.0)
			{
				canvas.DrawTexture(icon, false, cx + 3, fy(int(cy)) - 3,
					DTA_CenterOffset, true, DTA_FlipY, true,
					DTA_DestWidth, int(iw), DTA_DestHeight, int(ih),
					DTA_FillColor, 0x000000, DTA_AlphaChannel, true,
					DTA_Alpha, 0.5);
			}

			canvas.DrawTexture(icon, false, cx, fy(int(cy)),
				DTA_CenterOffset, true, DTA_FlipY, true,
				DTA_DestWidth, int(iw), DTA_DestHeight, int(ih));
		}

		// A band behind the lower third, where the name and the count are about
		// to be drawn as billboards. Without it a bled sprite runs straight
		// under the text and the text becomes unreadable on exactly the weapons
		// whose artwork works best.
		dimFlipped(canvas, 0x000000, 0.62, 0, READOUT_TOP, FACE_W, FACE_H - READOUT_TOP);

		// AMMO AS A BAR. See the note on barRow() for why pips came out --
		// this reads "how much is left", monotonically, whatever the count.
		if (cv("wr_ammo", 1.0) > 0.0)
		{
			barRow(canvas, BAR_TOP, ammoLoadedFrac(held), faceColor);

			// The second row is the RESERVE on a magazine weapon and the alt
			// fire pile on one with a real alt fire -- never both, since a
			// weapon cannot use Ammo2 for two things at once. Cooler tint
			// either way so it is never mistaken for more of the first row.
			if (hasMagazine(held) && held.Ammo1 != null && held.Ammo1.MaxAmount > 0)
			{
				double rfrac = clamp(double(held.Ammo1.Amount) / held.Ammo1.MaxAmount, 0.0, 1.0);
				barRow(canvas, BAR_TOP + BAR_H + 3, rfrac, COLOR_ALT_BAR);
			}
			else
			{
				barRow(canvas, BAR_TOP + BAR_H + 3, ammoFrac2(held), COLOR_ALT_BAR);
			}
		}

		// SCANLINES, over everything.
		//
		// One dimmed row every three. It is the cheapest possible trick and it
		// does more than any of the above to stop the face reading as a picture
		// pasted on a card and start it reading as a lit display.
		// The phase CRAWLS, one row every few tics. A static scanline pattern is
		// a texture; a drifting one is a signal. The face is already repainted
		// every tic -- it has to be, a canvas is a queue -- so animating this
		// costs one modulo.
		double scan = cv("wr_canvas_scan", 0.22);
		if (scan > 0.0)
		{
			int phase = 0;
			double crawl = cv("wr_scan_crawl", 1.0);
			if (crawl > 0.0) phase = int(level.maptime * crawl * 0.25) % 3;

			for (int y = -3 + phase; y < FACE_H; y += 3)
			{
				if (y < 0) continue;
				dimFlipped(canvas, 0x000000, scan, 0, y, FACE_W, 1);
			}
		}

		// The card's colour as a corner chevron as well as the top stripe,
		// so the ring is eight distinguishable SHAPES and not only eight
		// hues -- which is what survives being in the corner of your eye.
		canvas.DrawThickLine(-4, fy(26), 30, fy(-8), 9, faceColor, 255);

		// A hairline round the outside, so the artwork has an edge even when the
		// plate behind it is switched off.
		canvas.DrawLineFrame(dim(faceColor, 0.45), 0, 0, FACE_W, FACE_H);

		return TexMan.CheckForTexture(name, TexMan.Type_Any);
	}

	// Re-queue every card's artwork. See the note on paintFace for why this
	// cannot be done once at open.
	private void repaintFaces(PlayerPawn pmo)
	{
		if (cv("wr_canvas", 0.0) <= 0.0) return;

		// TEMPORARY -- one tic's worth of paintFace's own debug prints, not
		// one tic's worth PER CARD FOREVER. This runs every tic the ring is
		// open; unthrottled, wr_debug turned this into hundreds of lines a
		// second and nothing was readable.
		bool dumpNow = cv("wr_debug", 0.0) > 0.0 && !mDebugPainted;

		for (int i = 0; i < mFaces.Size() && i < mTypes.Size(); ++i)
		{
			if (mFaces[i] == 0) continue;

			let held = Weapon(pmo.FindInventory(mTypes[i]));
			if (held == null) continue;

			// The card's resolved resting colour already folds wr_ammo in;
			// asking ammoLoaded directly painted a dry face under an idle plate.
			bool dry = (i < mBaseColor.Size()) && mBaseColor[i] == COLOR_DRY;
			paintFace(i, held, mCardColor[i], dry, dumpNow);
		}

		if (dumpNow) mDebugPainted = true;
	}

	// Magazine size. Read by ammoLoadedFrac, which turns a round count into the
	// fraction the bar fills.
	private static int ammoCapRaw(Weapon w)
	{
		if (w == null || w.Ammo1 == null) return -1;
		return w.Ammo1.MaxAmount;
	}

	// Scale a colour's channels without touching its alpha. Canvas.Clear wants
	// a packed ARGB and there is no multiply on a colour in ZScript.
	private static color dim(color c, double k)
	{
		k = clamp(k, 0.0, 1.0);
		int r = int(((c >> 16) & 0xFF) * k);
		int g = int(((c >>  8) & 0xFF) * k);
		int b = int(( c        & 0xFF) * k);
		return color(255, r, g, b);
	}

	private void spawnPanels()
	{
		mIds.Clear();
		mLabels.Clear();
		mIcons.Clear();
		mAmmos.Clear();
		mAccents.Clear();
		mFaces.Clear();
		mGauges.Clear();
		mGroups.Clear();
		mBaseColor.Clear();
		mIconW.Clear();
		mIconH.Clear();
		mLabelH.Clear();
		mAmmoW.Clear();
		mLowAmmo.Clear();

		double panelW = cv("wr_panel_w", 4.2) * cv("wr_scale", 1.0);
		double panelH = cv("wr_panel_h", 3.0) * cv("wr_scale", 1.0);

		// PAINTED FACES ARE ALL OR NOTHING, decided here for the whole ring
		// rather than per card in the loop.
		//
		// The pool is a fixed twelve -- canvas textures have to be declared up
		// front in animdefs and there is no allocate-on-demand -- and this used
		// to let card thirteen quietly fall back to a composed face on its own.
		// That is fine as failure handling and wrong as a picture: painted and
		// composed cards do not look like variants of one card, they look like
		// two different menus, and the ring's whole job is to be read at a
		// glance. It only ever happened on a FLAT ring, which grows a card per
		// weapon instead of per slot, so the sets that tripped it were the
		// crowded ones that could least afford the noise.
		//
		// One uniform ring of composed cards beats twelve good ones and a
		// remainder. Lowering wr_subcards_max is also the way out, since a
		// collapsed ring of slots cannot exceed nine.
		bool canvasRing = cv("wr_canvas", 0.0) > 0.0 && mTypes.Size() <= FACE_POOL;

		for (int i = 0; i < mTypes.Size(); ++i)
		{
			// Position and yaw are set properly by layout() on the same tic;
			// these are placeholders so the handle exists.
			// THE HIT QUAD IS NOT THE PICTURE.
			//
			// Billboards draw 1.2x taller than they are authored -- the view
			// matrix stretches world Z and the billboard path never unstretches
			// it -- so a quad that is both the picture and the target is hittable
			// across only the middle 83% of what you can see. Add the gap the
			// text and icon need to sit inside, and the live band ends up being
			// roughly where the name is, which is exactly the complaint.
			//
			// So: an invisible quad does the hitting, generously sized, and the
			// visible plate is BBFL_NOHIT. Alpha 0 is still hittable -- documented
			// as a trap, used here on purpose.
			int id = wr_BB.AddBillboardPersistent(
				(0, 0, 0), 3.5, 2.5, 0, 0,
				wr_BB.BBF_FIXED, wr_BB.BB_PANEL, 0,
				COLOR_IDLE, 0, 0, "");
			wr_BB.SetBillboardAlpha(id, 0);
			mIds.Push(id);

			// A DRY WEAPON RESTS A DIFFERENT COLOUR.
			//
			// Picking an empty gun looked exactly like picking a loaded one right
			// up until the trigger did nothing, and in a firefight that is the
			// worst possible moment to find out. The colour is the resting state,
			// not a hover state, so it is readable without pointing at anything.
			let heldNow = Weapon(players[consoleplayer].mo.FindInventory(mTypes[i]));
			int rest = (cv("wr_ammo", 1.0) > 0.0 && ammoLoaded(heldNow) == 0)
			         ? COLOR_DRY : COLOR_IDLE;
			mBaseColor.Push(rest);

			// SAMPLED PLATE OR SOLVED ONE, and the caller picks.
			//
			// BB_PANEL stretches one small rounded-rect texture, which is cheap
			// and blurs when a card is held close in VR. BB_SDFPANEL solves the
			// same rectangle per pixel: crisp at any size, and it can take a
			// halo, which a sampled plate structurally cannot -- a glow needs a
			// distance field to read past the shape's edge and a texture has
			// none. That is why the label could glow and the card under it
			// could not.
			//
			// Not free. Two distance tests against one texture sample, times
			// every card, so the switch stays a switch.
			// A SHADOW BEHIND THE CARD.
			//
			// Not decoration -- a legibility fix. The ring floats in front of
			// whatever the room happens to be, and a dark plate against a dark
			// brick wall has almost no edge. One offset black quad behind each
			// card separates it from ANY background, however busy, without
			// having to know anything about the background.
			//
			// Behind everything else on the card and slightly larger, so it
			// reads as the card's own shadow rather than as a border.
			int shad = 0;
			if (cv("wr_shadow", 0.5) > 0.0)
			{
				shad = wr_BB.AddBillboardPersistent(
					(0, 0, 0), 3.5, 2.5, 0, 0,
					wr_BB.BBF_FIXED, plateKind(), plateShape(),
					0x000000, wr_BB.BBFL_NOHIT, 0, "");
			}
			mShadows.Push(shad);

			int plate = wr_BB.AddBillboardPersistent(
				(0, 0, 0), 3.5, 2.5, 0, 0,
				wr_BB.BBF_FIXED, plateKind(), plateShape(),
				rest, wr_BB.BBFL_NOHIT, 0, "");

			// A gradient, not a flat swatch. Two colours cost one extra setter
			// and give the card a top and a bottom -- which is most of what
			// makes a rectangle read as a surface rather than as a hole.
			wr_BB.SetBillboardGradient(plate, rest == COLOR_DRY ? GRAD_DRY : GRAD_IDLE);
			mPlates.Push(plate);

			// The slot's colour, as a bar along the top edge.
			//
			// Bearings are already fixed so the ring can be learned by feel.
			// This is the same promise to the eye: slot 4 is always blue and
			// always at the same angle, so it can be found two ways.
			mAccents.Push(wr_BB.AddBillboardPersistent(
				(0, 0, 0), 3.5, 0.3, 0, 0,
				wr_BB.BBF_FIXED, wr_BB.BB_PANEL, 0,
				mCardColor[i], wr_BB.BBFL_NOHIT, 0, ""));

			// The weapon's name, floated just off the panel face.
			//
			// BBFL_NOHIT is not optional here: the queries return the NEAREST
			// billboard, and the label sits in front of the panel it belongs to.
			// Without it every reach would come back holding a word, and the
			// panel behind it would be permanently unreachable.
			string rawTag = (i < mCardLabel.Size() && mCardLabel[i].Length() > 0)
			                  ? mCardLabel[i]
			                  : (heldNow != null ? ("" .. heldNow.GetTag())
			                                     : ("" .. GetDefaultByType(mTypes[i]).GetTag()));
			string tag = wrapLabel(rawTag, panelW * LABEL_FIT_FRAC, panelH);
			int lid = wr_BB.AddBillboardPersistent(
				(0, 0, 0), 3.5, 2.5, 0, 0,
				wr_BB.BBF_FIXED, wr_BB.BB_TEXT, 0,
				COLOR_LABEL, wr_BB.BBFL_NOHIT, 0, tag);
			mLabels.Push(lid);
			mLabelH.Push(fitLabel(tag, panelW * LABEL_FIT_FRAC, panelH));

			// The weapon's own icon. One engine call resolves it -- DI_ALTICONFIRST
			// prefers AltHudIcon and falls back to the pickup icon by itself, which
			// is the entire resolution chain, already written and native.
			//
			// applyscale is the second return and says whether the icon's own scale
			// should be honoured. It is dropped by nearly everyone -- including
			// Gearbox, which is why its icons are subtly wrong -- so it is kept
			// here and used at layout time.
			// CANVAS FACE, or the composed one.
			//
			// When the canvas carries the artwork, the separate icon and gauge
			// billboards are not created at all -- they are already painted into
			// it, and drawing both would stack two icons on one card.
			//
			// Per RING, not per card -- canvasRing is decided once above, and
			// the note there says why a mixed ring was the worse answer.
			int fid = 0;
			bool canvasFace = false;

			if (canvasRing && heldNow != null)
			{
				TextureID face = paintFace(i, heldNow, mCardColor[i], rest == COLOR_DRY);
				if (face.IsValid())
				{
					fid = wr_BB.AddBillboardPersistent(
						(0, 0, 0), 3.5, 2.5, 0, 0,
						wr_BB.BBF_FIXED, wr_BB.BB_TEXTURE, 0,
						0xFFFFFF, wr_BB.BBFL_NOHIT, 0, TexMan.GetName(face));
					canvasFace = true;
				}
			}
			mFaces.Push(fid);

			int iid = 0;
			double iw = ICON_W_FRAC, ih = ICON_H_FRAC;
			let held = heldNow;
			// iconFor is Inventory-typed on purpose (AltHUDIcon/Icon), but
			// heldNow is the Weapon cast -- null for every inventory-page item,
			// which is why those cards were blank plates with a name.
			let heldItem = players[consoleplayer].mo.FindInventory(mTypes[i]);
			if (heldItem != null && !canvasFace)
			{
				TextureID icon = iconFor(heldItem);

				if (icon.IsValid())
				{
					// Worked out once, here, rather than every tic in layout:
					// the texture cannot change while the rig is up, and this is
					// a texture lookup per card per frame otherwise.
					[iw, ih] = fitIcon(icon, ICON_W_FRAC, ICON_H_FRAC);

					iid = wr_BB.AddBillboardPersistent(
						(0, 0, 0), 3.5, 2.5, 0, 0,
						wr_BB.BBF_FIXED, wr_BB.BB_TEXTURE, 0,
						0xFFFFFF, wr_BB.BBFL_NOHIT, 0, TexMan.GetName(icon));
				}
			}
			mIcons.Push(iid);
			mIconW.Push(iw);
			mIconH.Push(ih);

			// The count, under the name. Blank for a weapon that uses no ammo --
			// a fist with "0" under it would be a lie, and one with "--" is a
			// question nobody asked.
			// BB_SEGMENT, not BB_TEXT.
			//
			// The 16-segment readout is built from arithmetic in the shader, so
			// it needs no font lump, cannot be broken by a missing atlas, and
			// stays sharp at any size -- and it draws its own bordered plate.
			// The point is not legibility, which BB_TEXT already had: it is that
			// a number in a lit bezel reads as an INSTRUMENT, which is what a
			// thing strapped to your arm should look like.
			int aid = 0;
			double aw = AMMO_W_FRAC;
			int rounds = ammoLoaded(held);
			if (cv("wr_ammo", 1.0) > 0.0 && rounds >= 0)
			{
				// WG13 reads its number from `data`; the other two read `text`.
				// Passing both costs nothing and means the payload can be
				// switched at spawn without a branch here.
				string atext = ammoText(heldNow, rounds);
				aw = readoutAspect(atext);

				aid = wr_BB.AddBillboardPersistent(
					(0, 0, 0), 3.5, 2.5, 0, 0,
					wr_BB.BBF_FIXED, readoutKind(), rounds,
					rounds > 0 ? COLOR_AMMO : COLOR_AMMO_DRY,
					wr_BB.BBFL_NOHIT, 0, atext);
			}
			mAmmoW.Push(aw);

			// Loaded but under the low-ammo threshold. ammoLoadedFrac
			// returns -1 for a weapon with no ammo cap at all (a fist, an
			// infinite-ammo weapon) -- explicitly excluded, since "low" is
			// meaningless without a ceiling to be low relative to.
			double loadFrac = ammoLoadedFrac(held);
			mLowAmmo.Push(rounds > 0 && loadFrac >= 0.0 && loadFrac < cv("wr_lowammo_frac", 0.25));

			// THE MARKER, and it does not lock anything.
			//
			// Two states worth telling apart: this weapon is in the hand you are
			// pointing WITH, or it is in your other one. The second is the
			// interesting case -- taking it swaps the hands, or finds a free _2
			// clone -- so it gets the brighter mark. Neither stops the card
			// being selected, because in both cases picking it is a reasonable
			// thing to ask for.
			// "You are already holding this" is a WEAPON fact -- which hand
			// has it. An inventory item is not held in a hand, and a model
			// card's class is the gun you are already carrying, so asking
			// here would mark every card on that page.
			let wcls = (class<Weapon>)(mTypes[i]);
			// Weapons page only. A model card's class IS the gun in hand (the
			// cast succeeds for every shelf row), so asking there marked and
			// glowed every card on the page.
			int where = (wcls && mPage == PAGE_WEAPONS) ? heldWhere(wcls) : 0;
			int mid = 0;
			if (where != 0 && cv("wr_marker", 1.0) > 0.0)
			{
				mid = wr_BB.AddBillboardPersistent(
					(0, 0, 0), 0.6, 0.6, 0, 0,
					wr_BB.BBF_FIXED, plateKind(), 15,
					(where == 2) ? COLOR_MARK_OTHER : COLOR_MARK_MINE,
					wr_BB.BBFL_NOHIT, 0, "");

				// A STANDING GLOW, unlike every other glow on this ring --
				// those all answer "which one is hovered" and go dark the
				// moment you look away. This one is a fact about the card
				// (you are already holding this), not about attention, so
				// it does not compete with the hover halo for the same
				// signal. Set once at creation, not per tic in the main
				// loop -- where does not change within a card's lifetime,
				// and on BB_PANEL (wr_sdf off) the engine ignores glow
				// entirely, so this needs no branch either way. Distinct
				// hue from COLOR_HOVER's gold specifically so a held
				// weapon stays identifiable even buried in a collapsed
				// fan, where the mark itself is small and easy to miss.
				if (mid) wr_BB.SetBillboardGlow(mid, 0.5, 0.6);
			}
			mMarks.Push(mid);

			// THE SLOT NUMBER, in the corner opposite the marker.
			//
			// The ring's bearings are fixed per slot precisely so it can be
			// learned by feel, and this is the same promise written down: the
			// number you would press on the keyboard, on the card it maps to.
			// It also survives the flatten -- with fans off, several cards share
			// a slot and the digit is the only thing that still says so.
			//
			// BB_DIGITS rather than BB_TEXT: it takes the value in `data` and
			// needs no string, which is the entire payload for a single number.
			int nid = 0;
			if (cv("wr_slotnum", 1.0) > 0.0 && mCardSlots[i] > 0)
			{
				nid = wr_BB.AddBillboardPersistent(
					(0, 0, 0), 0.8, 0.8, 0, 0,
					wr_BB.BBF_FIXED, wr_BB.BB_DIGITS, mCardSlots[i],
					COLOR_SLOTNUM, wr_BB.BBFL_NOHIT, 0, "");
			}
			mSlotNums.Push(nid);

			// THE STACK BADGE -- "this card is hiding others."
			//
			// Before wr_subcards_max could pick flat OR collapsed per loadout,
			// a card's shape said everything: collapsed meant every card had
			// a fan behind it and flat meant none did, and either was true of
			// the whole ring at a glance. Now the two coexist card by card --
			// nothing on a collapsed card's FACE otherwise says whether it is
			// a slot of one weapon or five, and dwelling on the wrong
			// assumption either way costs a beat you should not have had to
			// spend finding out.
			//
			// BB_TEXT, not BB_DIGITS, because the count alone reads as a
			// second slot number in the same corner family -- "+3" can only
			// mean one thing. Only mFansEnabled cards carry siblings to hide
			// at all; a flat card's own mSlotCount is always 1 (nothing is
			// left behind a card that already has its own), so the >1 test
			// below is what actually gates this, mFansEnabled is what makes
			// that test possible to fail safely.
			int bid = 0;
			if (mFansEnabled && i < mSlotCount.Size() && mSlotCount[i] > 1)
			{
				// Red instead of the neutral stack colour when every
				// hidden variant is dry -- computed once, in gatherWeapons,
				// across the whole slot rather than just the shown card.
				bool allDry = (i < mSlotAllDry.Size()) && mSlotAllDry[i];
				bid = wr_BB.AddBillboardPersistent(
					(0, 0, 0), 3.5, 2.5, 0, 0,
					wr_BB.BBF_FIXED, wr_BB.BB_TEXT, 0,
					allDry ? color(COLOR_AMMO_DRY) : COLOR_STACK,
					wr_BB.BBFL_NOHIT, 0,
					String.Format("+%d", mSlotCount[i] - 1));
			}
			mStackBadges.Push(bid);

			// The same number as a proportion, which is the reading you actually
			// take at a glance. "148" needs parsing; a bar that is nearly gone
			// does not. BB_BAR's data is a fill PERCENT, 0..100, and it grows
			// from the left edge so only the right end moves.
			int gid = 0;
			double frac = ammoLoadedFrac(held);
			if (cv("wr_ammo", 1.0) > 0.0 && frac >= 0.0 && !canvasFace)
			{
				gid = wr_BB.AddBillboardPersistent(
					(0, 0, 0), 3.5, 0.35, 0, 0,
					wr_BB.BBF_FIXED, wr_BB.BB_BAR, int(frac * 100.0 + 0.5),
					mCardColor[i], wr_BB.BBFL_NOHIT, 0, "");
			}
			mGauges.Push(gid);
			mAmmos.Push(aid);

			// THE CARD IS ONE OBJECT NOW.
			//
			// The header of this file used to say groups were unusable because
			// group scale moved the picture and not the hit box, and a group
			// scaled to zero stayed clickable. Both of those were real, both
			// were found BY this mod, and both are fixed -- FORK_CHANGES.md
			// section 22. The note outlived the bugs by about a fortnight.
			//
			// What it buys: the scale animation is DECLARED once and resolved by
			// the engine per FRAME. The hand-rolled version stepped at script's
			// 35Hz, which is what made it look like a value being animated
			// rather than a thing arriving.
			int grp = wr_BB.AddBillboardGroup((0, 0, 0));
			wr_BB.SetBillboardGroup(id, grp);
			wr_BB.SetBillboardGroup(plate, grp);
			wr_BB.SetBillboardGroup(mAccents[i], grp);
			wr_BB.SetBillboardGroup(lid, grp);
			if (iid != 0) wr_BB.SetBillboardGroup(iid, grp);
			if (gid != 0) wr_BB.SetBillboardGroup(gid, grp);
			if (fid != 0) wr_BB.SetBillboardGroup(fid, grp);
			if (mid != 0) wr_BB.SetBillboardGroup(mid, grp);
			if (shad != 0) wr_BB.SetBillboardGroup(shad, grp);
			if (nid != 0) wr_BB.SetBillboardGroup(nid, grp);
			if (bid != 0) wr_BB.SetBillboardGroup(bid, grp);
			if (aid != 0) wr_BB.SetBillboardGroup(aid, grp);
			mCardX.Push(0); mCardY.Push(0); mCardZ.Push(0);
			mGroups.Push(grp);
		}
	}

	//==========================================================================
	// Following the wrist
	//==========================================================================

	// 0 the instant the rig opens, 1 once it has arrived.
	//
	// Ease-out cubic. A linear grow stops dead at the ring and reads as a jump
	// cut; this decelerates into place, which is what makes it look like the
	// cards have weight rather than like a value being animated.
	private double growFactor() const
	{
		double dur = cv("wr_growtics", 6.0);
		if (dur <= 0.0) return 1.0;

		double t = clamp(mOpenTics / dur, 0.0, 1.0);
		double u = 1.0 - t;
		return 1.0 - u * u * u;
	}

	// Panels are moved by hand every tic rather than attached, because
	// AttachBillboard follows an ACTOR and the thing they need to follow is a
	// tracked hand, which is not one.
	// Geometry is read fresh every tic rather than baked at spawn, so every cvar
	// below is live: change one with the rig open and the next tic has it.
	private void layout(PlayerPawn pmo)
	{
		// THE TRAIL, and it is the whole mechanic rather than a side effect.
		//
		// A card welded to your hand can never be caught BY that hand -- it
		// moves exactly as fast as you do, so there is nothing to reach into.
		// Letting the formation lag means moving your hand pulls it ahead of the
		// cards, and sweeping back through them is the grab.
		//
		// The CENTRE lags, not the cards individually. Lag them separately and
		// they pile into one clump behind your hand and you catch whichever is
		// nearest, which is never twice the same. Lagging the centre keeps the
		// arc rigid, so every card holds its own direction -- pistol always
		// up-left, shotgun always up-right -- and the direction you sweep is the
		// choice you make.
		//
		// It also makes the tic rate stop mattering. Cards that are meant to
		// trail cannot be caught out for trailing.
		// THE GRID IS FROZEN, and that is the mechanic.
		//
		// It used to trail your hand, and the idea was that you could sweep back
		// into a lagging card. In practice that asks you to chase a moving target
		// fast enough to open a gap, which nobody does under fire.
		//
		// Nailing it to where your hand WAS when you opened it inverts that: the
		// targets hold still and your hand is the only thing moving. Eight fixed
		// cells around where you started, so the same weapon is always in the
		// same direction and your arm learns it. The centre is where your hand
		// already is, which is why the centre means "what I am holding" and
		// staying put means "no change".
		if (!mHaveAnchor)
		{
			// THE RING GOES IN FRONT OF THE HAND, not around it.
			//
			// A ring of radius 5 centred on your hand is 15cm away and wrapped
			// around you: it subtends nearly 180 degrees, so reaching a card
			// meant rotating almost ninety or physically walking your arm over
			// there. That is the thing that made it feel like miles, and no
			// amount of cursor gain could fix it -- gain multiplies a rotation
			// that was always going to be enormous.
			//
			// Pushed a metre out along the aim, the whole ring subtends about
			// twenty degrees. A flick of the wrist crosses it.
			double aimY, aimP;
			[aimY, aimP] = handAim(pmo, mRigHand);

			double cp = cos(aimP);
			Vector3 ahead = (cp * cos(aimY), cp * sin(aimY), sin(aimP));

			// DON'T OPEN THE RING INSIDE A WALL. wr_forward is a distance
			// tuned in the open -- point your hand at a wall closer than
			// that (a corner, a low corridor, a locker room) and the ring
			// used to plant its centre past the wall's own face, so half
			// of it rendered on the far side of geometry the player can
			// never see through. Checked ONCE here, at the same moment
			// the anchor itself freezes (mHaveAnchor), not every tic --
			// the facing-lock fix on the token card tonight is the same
			// lesson: a live geometry re-check every tic would fight the
			// player's hand for the ring's position exactly the way live
			// re-facing fought their head.
			double wantForward = cv("wr_forward", 34.0);
			// Same guard idiom as radius/panelW/panelH below: an unset or
			// fat-fingered cvar resets to the shipped default rather than
			// doing something with 0 or a negative number. Unguarded, 0
			// collapsed the ring into the fist -- the exact failure this
			// whole block exists to prevent, just uncovered here -- and a
			// negative value put the anchor behind the player, inside
			// their own body, for the rest of the session.
			if (wantForward < 0.5) wantForward = 34.0;
			Vector3 handP = handPos(pmo, mRigHand);

			double clearForward = wantForward;
			// The SECTOR AT THE TRACE'S OWN START, not the player's. handP
			// can sit well away from pmo.Pos -- 20+ units even outside real
			// VR tracking -- and Trace() uses whatever sector it's handed
			// for the initial floor/ceiling/3D-floor plane tests before any
			// line is crossed. Near a doorway or a 3D-floor edge with a
			// different floor/ceiling height, pmo's own sector could answer
			// a question the trace never actually asked.
			Sector handSector = level.PointInSector((handP.X, handP.Y));
			let tracer = new("LineTracer");
			// ignoreAllActors: true -- this is a WALL check. Left at its
			// default false, the trace's actor mask is 0xFFFFFFFF (match
			// anything) with no SOLID filter underneath, so a monster, a
			// corpse, or a dropped pickup within wr_forward reported a hit
			// exactly like a wall. Because the anchor freezes once per
			// ring-open and is never rechecked, that pull-in used to
			// outlive the actor that caused it -- the ring stayed clamped
			// close for the rest of the session even after the monster
			// walked off, died, or the item was picked up.
			//
			// TRACE_PortalRestrict -- without it the trace silently crosses
			// a sector/line portal (a mirror, a window, a linked hallway)
			// and keeps going in the DESTINATION room's frame, which can be
			// rotated and offset from this one. clearForward below is a
			// plain scalar walked forward from handP in THIS room -- it has
			// no idea the trace ever left it -- so a portal within
			// wr_forward used to report a "wall" that was really on the far
			// side of the portal, and the ring still got planted straight
			// ahead in the near room, unrelated to whatever the trace
			// actually hit. Restricted, the trace simply stops AT the
			// portal instead, which the existing pull-in below already
			// treats correctly -- a portal boundary is exactly the kind of
			// thing the ring should not be planted through.
			if (tracer.Trace(handP, handSector, ahead, wantForward,
				TRACE_NoSky | TRACE_PortalRestrict, Line.ML_BLOCKING | Line.ML_BLOCKEVERYTHING, true))
			{
				// Pulled in short of the hit, not onto it, so the ring's
				// own plates (which have real thickness once drawn) don't
				// immediately re-clip the same wall they were pulled back
				// from. Floored well above zero -- a wall right in the
				// player's face still gets a ring, just a close one,
				// rather than one collapsed into their hand.
				clearForward = max(wantForward * 0.35, tracer.Results.Distance - 6.0);

				// WALL-CLAMP TELL. wr_debug only -- this fires every time
				// the anchor is pulled in, which is ordinary, not an
				// error, so it does not belong on by default the way an
				// actual fault would. Marks exactly where the trace
				// actually hit, so it is obvious at a glance whether a
				// pullback landed on real geometry, on an actor this
				// trace should be ignoring (see ignoreAllActors above --
				// if this marker keeps appearing over a monster, that is
				// the bug, not the marker), or somewhere that makes no
				// sense at all. Non-persistent, self-expiring -- purely a
				// diagnostic, never a permanent fixture.
				if (cv("wr_debug", 0.0) > 0.0)
				{
					wr_BB.AddBillboard(tracer.Results.HitPos, 6.0, 6.0,
						pmo.angle + 180, 0, wr_BB.BBF_FIXED,
						wr_BB.BB_SEAM, 0, color(255, 255, 200, 60),
						wr_BB.BBFL_NOHIT, 2.0);
				}
			}

			mAnchor     = handP + ahead * clearForward;

			// THE REACH, frozen with the anchor and for the same reason: it
			// has to be a fixed extension of the hand, not a distance
			// recomputed against the ring. Recomputed, pushing your hand
			// forward would move the fingertip and the ring's remaining gap
			// by the same amount and you could never close it.
			//
			// Set so the fingertip rests just SHORT of the card plane -- a
			// touch radius and a bit. Standing still with your arm where it
			// was therefore touches nothing; a real push forward of a few
			// centimetres is what carries it in. Derived from clearForward
			// rather than from wr_forward so a ring the wall pulled in close
			// gets a correspondingly short reach instead of a fingertip
			// parked permanently past its own cards.
			double treach = cv("wr_touch", 7.0) * cv("wr_scale", 1.0);
			mTouchReach = clearForward - treach * 1.2;
			if (mTouchReach < 0.0) mTouchReach = 0.0;
			mAnchorYaw  = pmo.angle;
			mHaveAnchor = true;

			// A wall the FORWARD ray can't see: one straight ahead of the
			// hand says nothing about a corner immediately to the player's
			// left or right, and the ring is a wide GRID (see ringR below),
			// not a point -- most of it lives off to the sides of mAnchor,
			// not in front of it. Two more rays, once, from the now-frozen
			// centre, cap how far ringR is later allowed to grow instead of
			// repositioning anything -- a size ceiling can't fight the
			// player's hand the way moving mAnchor live would, since the
			// space around a stationary anchor doesn't change tic to tic.
			// Vertical is NOT checked here -- a low ceiling or a step can
			// still clip the grid. Left/right covers the failure this was
			// actually reported for; treat this as a partial fix, not full
			// geometry awareness.
			Vector3 sideDir = (-sin(mAnchorYaw), cos(mAnchorYaw), 0);
			double sideMax = 60.0;
			// Same card-thickness clearance the forward check already
			// subtracts (Distance - 6.0) -- a ring sized to the raw hit
			// distance, with no margin, can still visually clip the wall
			// the trace just found, the same problem the forward check's
			// own pullback exists to prevent.
			double sideMargin = 6.0;
			// -1, not 0 -- 0.0 is a REAL, reachable cap (something sits
			// close enough that the margin-adjusted distance floors to
			// exactly zero), and the old 0.0 sentinel could not tell that
			// apart from "no wall found at all", silently treating a
			// wall right at the anchor as uncapped.
			mMaxRingR = -1.0;
			Sector anchorSector = level.PointInSector((mAnchor.X, mAnchor.Y));
			let sideTracer = new("LineTracer");
			if (sideTracer.Trace(mAnchor, anchorSector, sideDir, sideMax,
				TRACE_NoSky | TRACE_PortalRestrict, Line.ML_BLOCKING | Line.ML_BLOCKEVERYTHING, true))
			{
				mMaxRingR = max(0.0, sideTracer.Results.Distance - sideMargin);
			}
			let sideTracer2 = new("LineTracer");
			if (sideTracer2.Trace(mAnchor, anchorSector, (0,0,0) - sideDir, sideMax,
				TRACE_NoSky | TRACE_PortalRestrict, Line.ML_BLOCKING | Line.ML_BLOCKEVERYTHING, true))
			{
				double d = max(0.0, sideTracer2.Results.Distance - sideMargin);
				if (mMaxRingR < 0.0 || d < mMaxRingR) mMaxRingR = d;
			}
		}

		// RSQ: THE RING STAYS IN VIEW (wr_follow). REMA leaves it where it opened; turned well away
		// from it (more than wr_follow degrees), it swings round the head to sit ahead again,
		// easing, so turning your body to face a threat does not leave your guns behind you.
		double follow = cv("wr_follow", 0.0);
		if (follow > 0.0 && mHaveAnchor)
		{
			Vector3 eye = (pmo.pos.xy, pmo.player.viewz);
			Vector2 rel = mAnchor.xy - eye.xy;
			double ringYaw = atan2(rel.y, rel.x);
			double off = Actor.deltaangle(ringYaw, pmo.angle);
			if (abs(off) > follow)
			{
				double turn = (off - (off > 0 ? follow : -follow)) * 0.2;
				double c = cos(turn), s2 = sin(turn);
				mAnchor = (eye.x + rel.x * c - rel.y * s2, eye.y + rel.x * s2 + rel.y * c, mAnchor.z);
				mAnchorYaw += turn;
			}
		}

		Vector3 wrist = mAnchor;

		// Every one of these is guarded. GetCVar returns null for a cvar the
		// config has never seen, and calling GetFloat on that aborts the VM --
		// which kills layout() every tic and looks precisely like the rig not
		// existing. A zero radius is the same class of failure without the
		// abort: every panel stacks inside your hand.
		// One dial that grows the whole rig -- distance, card size and reach
		// together. Scaling them independently just breaks the proportions you
		// already tuned, and "make it bigger" is one thought, not four.
		double sc = cv("wr_scale", 1.0);
		if (sc < 0.05) sc = 1.0;

		double radius = cv("wr_radius",   5.0);
		double rise   = cv("wr_rise",     2.0);
		double tilt   = cv("wr_tilt",    12.0);
		double panelW = cv("wr_panel_w",  4.2);
		double panelH = cv("wr_panel_h",  3.0);

		if (radius < 0.5) radius = 5.0;
		if (panelW < 0.5) panelW = 4.2;
		if (panelH < 0.5) panelH = 3.0;

		radius *= sc;
		rise   *= sc;
		panelW *= sc;
		panelH *= sc;

		// The arc lies FLAT around the hand, at rise above it -- a fan you look
		// down at, not a bracelet standing across the forearm. The bracelet is
		// geometrically the more honest reading of "worn on the wrist" and it is
		// unusable: it centres the arc straight up from your hand, which puts
		// half the panels over your head and the rest behind your arm.
		//
		// Wrist ROLL survives from that attempt, as a rotation of the ring within
		// its own plane. Twisting your wrist spins the cards past your hand,
		// which is the one part of arm tracking that helps rather than hinders.
		//
		// It had been dead for a while: it fed the old arc's start angle, and
		// when the layout moved to fixed bearings the arc maths was left behind
		// computing values nothing read. It is added to the BEARING now, which
		// is where it always belonged -- one term, and the whole ring turns.
		//
		// OFF by default, and that is not timidity. A tracked controller reports
		// roll of ninety degrees or more just from how you hold it, so feeding
		// it in raw swings the ring somewhere behind you and looks exactly like
		// the rig failing to open.
		double handRoll = handRollOf(pmo, mRigHand) * cv("wr_roll", 0.0);

		int n = mIds.Size();

		// A GRID, not an arc.
		//
		// An arc cannot hold nine cards without pushing the radius to arm's
		// length: the arc length available is radius * span * pi/180, and nine
		// cards need nine card-widths of it. At any radius you would actually
		// want, they stack on top of each other -- which is what they were doing.
		//
		// A grid has no such ceiling. It packs, it never overlaps, and it scales
		// to a weapon set with fifty entries instead of nine.
		double viewYaw = pmo.angle;
		Vector3 viewRight = (cos(viewYaw - 90), sin(viewYaw - 90), 0);

		double cellW = panelW * 1.25;


		// Ring radius grows with the count so the cards never crowd: eight fit at
		// the tuned distance, twelve push out to keep the same gap between them.
		// The chord between neighbours is 2 * R * sin(180/N), and that wants to
		// stay above one card width.
		int ringCount = n;
		double ringR = radius;
		double minR = (cellW * 0.5) / max(sin(180.0 / max(ringCount, 2)), 0.05);
		if (minR > ringR) ringR = minR;

		// THE SHEET SETS A FLOOR ON THE RING.
		//
		// It stands at the centre now, so a ring tuned smaller than the sheet
		// is wide would orbit its cards straight through the panel. Half the
		// sheet, plus half a card, plus the same gap the sheet already used
		// when it sat beside the ring.
		//
		// This only ever pushes the ring OUT. wr_radius and the count-driven
		// minR above both still win when they are larger, so nothing about a
		// crowded ring changes.
		// Only while the sheet is actually there. Switched off, the ring goes
		// back to being sized by wr_radius and the card count alone.
		if (cv("wr_sheet", 1.0) > 0.0)
		{
			double sheetR = panelW * (SHEET_W_CARDS * sheetScale() * 0.5 + 0.5 + SHEET_GAP_CARDS);

			// HEIGHT AS WELL AS WIDTH, and only width was ever considered.
			//
			// The ring is a circle of cards around a plate standing in the middle
			// of it, so cards sit ABOVE and BELOW the sheet as well as beside it.
			// Flooring the radius on half-width alone clears the three and nine
			// oclock cards and does nothing for twelve and six -- which is exactly
			// the sheet reaching up into the cards and swallowing them.
			//
			// Same content-driven height layoutSheet now draws, computed the same
			// way from the same row count, so the two cannot drift: shrink the
			// sheet and the ring closes in with it, grow it and the ring opens out.
			int sRows = mSheetUsed;
			if (sRows > int(mSheetRows.Size())) sRows = int(mSheetRows.Size());

			double sFrac = SHEET_ROWS_TOP
				+ (sRows + int(mSheetBars.Size())) * SHEET_ROW_FRAC * SHEET_ROW_PITCH
				+ 0.04;
			if (sFrac > 1.0) sFrac = 1.0;
			if (sFrac < SHEET_ROWS_TOP + 0.08) sFrac = SHEET_ROWS_TOP + 0.08;

			// CARD_STRETCH, because a card is drawn taller than it is authored and
			// the clearance has to be measured against what is actually on screen.
			double sheetHalfH = panelH * SHEET_H_CARDS * sheetScale() * sFrac * 0.5 * CARD_STRETCH;
			double sheetRV = sheetHalfH + panelH * (0.5 * CARD_STRETCH + SHEET_GAP_CARDS);
			if (sheetRV > sheetR) sheetR = sheetRV;

			if (sheetR > ringR) ringR = sheetR;
		}

		// The side-trace ceiling from anchor-freeze, above. Applied LAST,
		// after the count-driven growth and the sheet's own floor, so it
		// is a genuine ceiling on the final answer rather than one more
		// input those can grow past. mMaxRingR of 0 means no wall was
		// found in either direction, so nothing is capped.
		//
		// NEVER BELOW minR, though -- that floor exists so neighbouring
		// cards don't overlap, which is worse than the wall-clip this
		// whole mechanism exists to prevent (an unreadable, physically
		// intersecting ring vs. one whose edge sits inside a wall).
		// sheetR is still allowed to lose: a ring smaller than it would
		// like beats one whose cards clip through the wall, and losing
		// against the SHEET specifically doesn't produce overlapping
		// cards, just a ring standing closer to the panel than usual --
		// the original tradeoff this comment already defended, now
		// scoped to the one floor it was actually safe for.
		if (mMaxRingR >= 0.0 && ringR > mMaxRingR) ringR = max(mMaxRingR, minR);

		// Published for RingClearance() -- anything parking beside the
		// ring needs the count-grown extent, not the tuned base value.
		mLastRingR = ringR;

		Vector3 eye = pmo.Pos + (0, 0, pmo.player.viewheight);

		// Beside the ring, off the SOLVED radius rather than the tuned one --
		// ringR above has already grown to whatever the card count needed. The
		// ring has a hole at its middle for the sheet to stand in, so it needs
		// no lateral push of its own; the parameter stays because layoutSheet
		// is shared.
		double sheetLateral = 0.0;

		layoutSheet(wrist, viewYaw, viewRight, tilt, rise, ringR, panelW, panelH, sheetLateral);

		// The field goes down BEFORE the cards, so anything the cards paint
		// this tic lands in front of it rather than behind. Faded in by the
		// same grow the cards use -- a sky that snaps to full brightness while
		// the cards are still travelling arrives before the thing it is the
		// background for. growFactor() called directly rather than reusing the
		// loop's own `grow` local, which is not declared until below this.
		layoutStars(wrist, viewRight, viewYaw + 180, tilt, panelW, ringR, growFactor());

		// THE CENTRE CELL IS GONE. The data sheet stands there instead.
		//
		// It was a card showing what the hand already held, unselectable, so
		// that "open the rig and do nothing" had something to point at. In
		// practice it stated the one thing you could already feel -- what is
		// in your hand -- and nothing else, and the sheet answers that same
		// question far better while also answering it about whatever you are
		// pointing at.
		//
		// The centre is also the only placement that survives the ring
		// growing. Beside the ring the sheet rides ringR, which reaches 20.9
		// units at 25 cards and puts the panel 40 degrees off axis -- a head
		// turn away from the card you are choosing. At the centre it is at
		// zero degrees whatever the ring does, and fans expand OUTWARD so
		// they can never reach it.

		// THE CARDS GROW OUT OF YOUR WRIST.
		//
		// They used to exist all at once, which gave you no idea where they had
		// come from -- eight rectangles simply were, and the first tic of the rig
		// was spent working out what you were looking at. Sliding them out of the
		// centre in six tics says "these belong to that hand" without a word, and
		// it costs one multiply per card.
		//
		// Ease-out cubic: quick away from the wrist, settling into the ring
		// rather than stopping dead at it. Position AND size, because a card that
		// travels at full size reads as sliding rather than unfolding.
		// The SCALE of the grow-in is the group's job now, resolved per frame by
		// the engine with its own eased overshoot. What is left here is the
		// TRAVEL -- cards sliding out of the wrist to their bearings -- and the
		// tumble, neither of which a group carries.
		double grow = growFactor();

		// THE RING BREATHES.
		//
		// A ring that is perfectly still while you stand still reads as a decal
		// stuck to the air. A few millimetres of rise and fall, slow enough that
		// you never catch it moving, is the difference between an image and an
		// object -- the same reason the hovered card pulses rather than just
		// changing colour.
		//
		// Off the level clock, not the open clock, so it does not restart from
		// the same phase every summon.
		double breathe = sin(level.maptime * cv("wr_idle_speed", 1.7))
		               * cv("wr_idle", 0.35) * sc;

		Vector3 origin = wrist + (0, 0, rise + breathe);

		// Hoisted out of the per-card loop below. None of these vary by
		// card within a single tic -- sc/radius/rise/tilt/panelW/panelH
		// above already got this treatment; these did not, so a full ring
		// re-read every one of them, by string, once per card, every tic.
		// wr_glow specifically was read TWICE per card on top of that (once
		// for the plate's halo, once for the label's) at the identical
		// value both times.
		double hDim         = cv("wr_dim", 0.55);
		double hShadowOff   = cv("wr_shadow_offset", 0.35) * sc;
		double hShadow      = clamp(cv("wr_shadow", 0.5), 0.0, 1.0);
		double hModelScale  = cv("wr_model_scale", 0.16);
		double hModelLift   = cv("wr_model_lift", 3.0);
		double hGlow        = cv("wr_glow", 1.0);
		double hShimmer     = cv("wr_shimmer", 0.0);
		double hParallax    = cv("wr_parallax", 0.06);
		double hLowAmmo     = cv("wr_lowammo_pulse", 0.35);

		// The visual half of the idle-close warning -- WorldTick's own
		// haptic tick (fired once, at the same threshold) is the felt
		// half. 1.0 outside the warning window; inside it, a floor of
		// 0.15 rather than fading to nothing, so the ring stays legible
		// enough to read while it is telling you it is about to leave.
		double warnFrac = 1.0;
		int warnTics = int(cv("wr_warn_tics", 25.0));
		if (warnTics > 0 && mLockTics < warnTics)
			warnFrac = clamp(double(mLockTics) / warnTics, 0.15, 1.0);

		for (int i = 0; i < n; ++i)
		{
			// Position is the slot's bearing on the ring, clockwise from north
			// west. Cards you do not own still consume their place, so a slot's
			// direction never changes as you pick things up -- which is the whole
			// reason this can be learned by feel.
			double bearing = bearingForIndex(i, ringCount) + handRoll;

			Vector3 pos;
			double cardGrow = grow;

			pos = wrist
			    + viewRight * (cos(bearing) * ringR)
			    + (0, 0, sin(bearing) * ringR + rise + breathe);

			if (cardGrow < 1.0) pos = origin + (pos - origin) * cardGrow;

			// The hovered card steps toward your eye and lights up. Colour alone
			// is a weak signal on a grid this dense -- depth reads instantly, and
			// it also makes the target physically easier to reach.
			if (mIds[i] == mHovered)
			{
				Vector3 toEye = eye - pos;
				if (toEye.Length() > 0.01) pos += toEye.Unit() * cv("wr_pop", 1.5);
			}

			// EVERY CARD LOOKS AT YOU INDIVIDUALLY.
			//
			// One shared yaw made the ring a flat sheet: every card pointed the
			// same way, so the ones out at the edges were turned slightly away
			// from your eye and the whole thing read as a poster. Solving the
			// yaw per card from ITS position to YOUR eye turns the ring into a
			// shallow bowl wrapped around you, which is what it has always been
			// geometrically and never looked like.
			//
			// Still BBF_FIXED and still solved here rather than by BBF_CAMERA:
			// camera-facing billboards are tested against the wrong orientation
			// by the hit queries, which is the bug this mod was built to avoid.
			// The yaw is the direction the FACE POINTS, and it points AT the eye
			// -- so it is atan2 of the card-to-eye vector, not of its negation.
			//
			// Getting that backwards did not merely turn the cards around. Every
			// label, icon, bar and painted face is offset along `lift`, which is
			// built from this yaw, so flipping it pushed all of them BEHIND the
			// plate where the plate hid them. Seven cards rendered as seven
			// blank rectangles and the debug line still read faces 7/7, because
			// they were painted perfectly and put in the wrong place.
			double faceYaw = viewYaw + 180;
			if (cv("wr_facing", 1.0) > 0.0)
			{
				Vector3 toMe = eye - pos;
				if (toMe.Length() > 0.01) faceYaw = atan2(toMe.Y, toMe.X);
			}

			// THE CARD TUMBLES IN.
			//
			// Rolled off true on the way out of the wrist and settling to level
			// as it arrives. Roll is a real billboard axis now, and because it
			// lives in the SHARED basis the hit quad rolls with the picture --
			// so a card caught mid-tumble is pointable exactly where it looks.
			double roll = (1.0 - cardGrow) * ARRIVE_ROLL * ((i % 2 == 0) ? 1.0 : -1.0);

			// The take-confirmation flip is applied in WorldTick, not here
			// -- this function stops running the instant mOpen goes
			// false, which commit() itself causes synchronously right
			// after arming the flip, so a branch here could never fire.

			if (i < mCardX.Size()) { mCardX[i] = pos.X; mCardY[i] = pos.Y; mCardZ[i] = pos.Z; }




			// The group carries the whole card's origin, so scale happens about
			// the card's own centre rather than about the world origin.
			if (i < mGroups.Size()) wr_BB.SetBillboardGroupOrigin(mGroups[i], pos);

			// Hit quad first, sized past the picture: 1.2 to cover the vertical
			// stretch the renderer adds, and a little more so the edges of the
			// card you can see are edges you can actually point at.
			//
			// No grow factor in the size any more -- the group scales it, and
			// scaling it here as well would square the animation.
			wr_BB.MoveBillboard(mIds[i], pos);
			wr_BB.ResizeBillboard(mIds[i], panelW * HIT_PAD,
			                               panelH * CARD_STRETCH * HIT_PAD);
			wr_BB.OrientBillboard(mIds[i], faceYaw, tilt, wr_BB.BBF_FIXED);
			wr_BB.RollBillboard(mIds[i], roll);

			// The hovered card BREATHES.
			//
			// A colour change is a state you have to notice; a card that is
			// moving is one you cannot miss, and motion survives being in the
			// corner of your eye where colour does not. Sine, not a ramp, so it
			// never stops or snaps -- the old SNES menu pulse.
			//
			// Everything on the card is scaled by the same factor, or the icon
			// and the name slide off a plate that grew underneath them.
			// Everything printed on the card rides a shade in front of its face.
			// The face points along (faceYaw), so stepping that way steps toward
			// the player -- any less and the two z-fight, any more and the text
			// visibly floats free of the card when seen from the side.
			Vector3 lift = (cos(faceYaw), sin(faceYaw), 0) * LABEL_LIFT;

			bool lit = (mIds[i] == mHovered);
			double pulse = 1.0;
			if (lit)
			{
				double amp = cv("wr_pulse", 0.10);
				pulse = 1.0 + amp + amp * sin(mHoverTics * PULSE_SPEED);
			}

			// FOCUS. Cards you are not pointing at step back.
			//
			// Only once something IS hovered -- dimming the whole ring the
			// moment it opens would make it look like it failed to load. Eight
			// cards competing equally for your eye is the problem; seven quiet
			// ones and a lit one is the fix, and it costs one alpha per card.
			//
			// HAS to be below lit and pulse, which is where it went wrong the
			// first time: it was written next to the position bookkeeping at the
			// top of the loop, forty lines before either of them exists.
			double cardAlpha = 1.0;
			if (mHovered != 0 && !lit) cardAlpha = clamp(hDim, 0.05, 1.0);
			cardAlpha *= warnFrac;

			// The shadow sits BEHIND the plate -- pushed away from the viewer
			// rather than toward them -- and offset down and to the side so it
			// reads as cast rather than as an outline. Larger than the card by
			// the same amount it is offset, so it shows on every edge.
			if (i < mShadows.Size() && mShadows[i] != 0)
			{
				double so = hShadowOff;

				wr_BB.MoveBillboard(mShadows[i],
					pos - lift * 0.6 + viewRight * so - (0, 0, so));
				wr_BB.ResizeBillboard(mShadows[i], panelW * pulse * 1.06,
				                                   panelH * pulse * 1.06);
				wr_BB.OrientBillboard(mShadows[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mShadows[i], roll);
				wr_BB.SetBillboardAlpha(mShadows[i], hShadow * cardAlpha);
			}

			// Bottom-left, opposite the held marker, so the two never collide.
			if (i < mSlotNums.Size() && mSlotNums[i] != 0)
			{
				wr_BB.MoveBillboard(mSlotNums[i],
					pos + lift * 1.5
					    - viewRight * (panelW * 0.40 * pulse)
					    + (0, 0, panelH * 0.34 * pulse));
				wr_BB.ResizeBillboard(mSlotNums[i], panelW * 0.11 * pulse,
				                                    panelH * 0.15 * pulse);
				wr_BB.OrientBillboard(mSlotNums[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mSlotNums[i], roll);
			}

			// Bottom-right -- the one corner slot number (bottom-left) and
			// held marker (top-right) leave free. Sized a shade smaller than
			// the slot number: this is confirming something the fan itself
			// will show in a moment, not a fact you need at the same weight
			// as the digit that IS the card's bearing.
			if (i < mStackBadges.Size() && mStackBadges[i] != 0)
			{
				wr_BB.MoveBillboard(mStackBadges[i],
					pos + lift * 1.5
					    + viewRight * (panelW * 0.40 * pulse)
					    - (0, 0, panelH * 0.34 * pulse));
				wr_BB.ResizeBillboard(mStackBadges[i], panelW * 0.24 * pulse,
				                                       panelH * 0.13 * pulse);
				wr_BB.OrientBillboard(mStackBadges[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mStackBadges[i], roll);
			}

			if (i < mSlotNums.Size()) fade(mSlotNums[i], cardAlpha);
			if (i < mPlates.Size())  fade(mPlates[i], cardAlpha);
			if (i < mFaces.Size())   fade(mFaces[i], cardAlpha);
			if (i < mAccents.Size()) fade(mAccents[i], cardAlpha);
			if (i < mIcons.Size())   fade(mIcons[i], cardAlpha);
			if (i < mGauges.Size())  fade(mGauges[i], cardAlpha);
			if (i < mLabels.Size())  fade(mLabels[i], cardAlpha);
			if (i < mAmmos.Size())   fade(mAmmos[i], cardAlpha);
			if (i < mMarks.Size())   fade(mMarks[i], cardAlpha);
			if (i < mStackBadges.Size()) fade(mStackBadges[i], cardAlpha);

			// The model floats a little in FRONT of its plate, so the card backs
			// it rather than intersecting it, and it takes the same pulse and
			// the same fade as everything else on the card.
			if (i < mModels.Size() && mModels[i] != null)
			{
				// fitted to the card at build (mModelFit); wr_model_scale 0.16 is "as fitted"
				double ms = (hModelScale / 0.16) * pulse * (i < mModelFit.Size() ? mModelFit[i] : 1.0);

				// Through a local: SetOrigin wants a modifiable value and an
				// expression is not one.
				Vector3 mp = pos + lift * hModelLift;
				if (i < mModelDrop.Size()) mp.z -= mModelDrop[i] * ms;   // RSQ: centred on the card
				mModels[i].SetOrigin(mp, true);
				mModels[i].Scale = (ms, ms);
				mModels[i].A_SetRenderStyle(cardAlpha, STYLE_Translucent);
				// RSQ: a pickup turns slowly on its card, as pickups do in a showcase
				mModels[i].angle = pmo.angle + 180 + level.maptime * cv("wr_model_spin", 1.5) + i * 40;
				// the picture replaces the flat icon rather than sitting on top of it
				if (i < mIcons.Size()) fade(mIcons[i], 0);
			}

			// The held-weapon mark, pinned to the card's top-right corner.
			if (i < mMarks.Size() && mMarks[i] != 0)
			{
				wr_BB.MoveBillboard(mMarks[i],
					pos + lift * 1.5
					    + viewRight * (panelW * 0.40 * pulse)
					    + (0, 0, panelH * 0.34 * pulse));
				wr_BB.ResizeBillboard(mMarks[i], panelW * 0.10 * pulse,
				                                 panelH * 0.13 * pulse);
				wr_BB.OrientBillboard(mMarks[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mMarks[i], roll);
			}

			if (i < mPlates.Size())
			{
				wr_BB.MoveBillboard(mPlates[i], pos);
				wr_BB.ResizeBillboard(mPlates[i], panelW * pulse, panelH * pulse);
				wr_BB.OrientBillboard(mPlates[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mPlates[i], roll);

				// THE CARD ITSELF GLOWS NOW, not just the name on it.
				//
				// This was impossible until the plate became a distance field:
				// the halo is placed by reading the field OUTSIDE the shape,
				// and a sampled texture has nothing out there to read. On
				// BB_PANEL the call is simply ignored, so the switch needs no
				// branch here.
				double g = hGlow;

				// AMBIENT SHIMMER, off the same halo -- a slow, low breathe on
				// every UNHOVERED card, using the card's own colour (the plate
				// is already tinted to it; this just intensifies the field
				// already there, same as the hover halo does). Off by default
				// (wr_shimmer 0), and even on, it is deliberately far weaker and
				// slower than the hover halo -- this fills in what used to be a
				// hard 0.0 rather than competing with it, so hovering still
				// reads as unmistakably "this one". Plate only, not the label:
				// the label's own halo is reserved for hover so the name stays
				// the clean, unambiguous "which one" signal it always was.
				double shimmerAmt = hShimmer;
				double shimmerFrac = 0.5 + 0.5 * sin(level.maptime * SHIMMER_SPEED + i * SHIMMER_PHASE);
				double sr = shimmerAmt * shimmerFrac;

				wr_BB.SetBillboardGlow(mPlates[i],
					lit ? clamp(GLOW_R * g, 0.0, 1.0) : clamp(GLOW_R * sr, 0.0, 1.0),
					lit ? GLOW_S * g : GLOW_S * sr);
			}

			// The slot bar, pinned to the card's top edge.
			if (i < mAccents.Size())
			{
				wr_BB.MoveBillboard(mAccents[i],
					pos + lift + (0, 0, panelH * (0.5 - ACCENT_H_FRAC * 0.5) * pulse));
				wr_BB.ResizeBillboard(mAccents[i], panelW * pulse,
				                                   panelH * ACCENT_H_FRAC * pulse);
				wr_BB.OrientBillboard(mAccents[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mAccents[i], roll);
			}

			// PARALLAX. The artwork shifts inside its frame as you move.
			//
			// A card is a flat quad and in stereo your eyes know it. But the
			// face already sits a shade IN FRONT of the plate, and anything
			// standing off a surface should slide against it as your head moves
			// -- so nudging the face along the card's own right and up axes by
			// how far off-centre you are gives real depth for one dot product.
			//
			// It is a lenticular trick and it is the cheapest three dimensions
			// in the mod: no extra billboard, no shader, no per-eye anything.
			// Small on purpose -- past a few percent of the card it stops
			// reading as depth and starts reading as the artwork being loose.
			Vector3 par = (0, 0, 0);
			double px = hParallax;
			if (px > 0.0)
			{
				Vector3 toEye = eye - pos;
				if (toEye.Length() > 0.01)
				{
					Vector3 v = toEye.Unit();
					Vector3 cardUp = (0, 0, 1);
					Vector3 cardRight = (cos(faceYaw - 90), sin(faceYaw - 90), 0);

					par = cardRight * (v dot cardRight) * panelW * px
					    + cardUp    * (v dot cardUp)    * panelH * px;
				}
			}

			// The painted face, filling the card and riding a shade in front of
			// the plate. Slightly inset so the SDF plate still shows as a rim
			// around it -- which is what keeps the plate's glow visible.
			if (i < mFaces.Size() && mFaces[i] != 0)
			{
				wr_BB.MoveBillboard(mFaces[i], pos + lift * 0.5 + par);
				wr_BB.ResizeBillboard(mFaces[i], panelW * 0.92 * pulse,
				                                 panelH * 0.92 * pulse);
				wr_BB.OrientBillboard(mFaces[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mFaces[i], roll);
			}

			// Sized to the icon's OWN shape rather than stamped into a fixed
			// rectangle, so a wide pickup stays wide. Centred in its box by
			// keeping the same anchor -- billboards are centre-origin.
			if (i < mIcons.Size() && mIcons[i] != 0)
			{
				wr_BB.MoveBillboard(mIcons[i], pos + lift + par + (0, 0, panelH * 0.17 * pulse));
				wr_BB.ResizeBillboard(mIcons[i], panelW * mIconW[i] * pulse,
				                                 panelH * mIconH[i] * pulse);
				wr_BB.OrientBillboard(mIcons[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mIcons[i], roll);
			}

			if (i < mLabels.Size())
			{
				wr_BB.MoveBillboard(mLabels[i], pos + lift - (0, 0, panelH * 0.07 * pulse));
				// Height measured at spawn against this card's width, so a long
				// name is drawn smaller instead of running off both edges.
				wr_BB.ResizeBillboard(mLabels[i], panelW * pulse,
				                                  panelH * mLabelH[i] * pulse);
				wr_BB.OrientBillboard(mLabels[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mLabels[i], roll);

				// Neon, and only on the one you are pointing at. A halo on every
				// card is a blur; a halo on one is the answer to "which".
				double lg = hGlow;
				wr_BB.SetBillboardGlow(mLabels[i], lit ? clamp(GLOW_R * lg, 0.0, 1.0) : 0.0,
				                                   lit ? GLOW_S * lg : 0.0);
			}

			// The proportion, as a bar. Read before the number is.
			if (i < mGauges.Size() && mGauges[i] != 0)
			{
				wr_BB.MoveBillboard(mGauges[i], pos + lift - (0, 0, panelH * 0.26 * pulse));
				wr_BB.ResizeBillboard(mGauges[i], panelW * 0.76 * pulse,
				                                  panelH * GAUGE_H_FRAC * pulse);
				wr_BB.OrientBillboard(mGauges[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mGauges[i], roll);

				// LOW-AMMO PULSE -- the same shimmer oscillation the plate's
				// ambient shimmer uses (SHIMMER_SPEED/PHASE), but gated on
				// mLowAmmo instead of wr_shimmer, so it works regardless of
				// whether ambient shimmer is even turned on. wr_shimmer
				// answers "does this ring feel alive"; this answers "is
				// this specific weapon about to be empty" -- two different
				// questions that would otherwise share one on/off switch.
				if (i < mLowAmmo.Size() && mLowAmmo[i] && hLowAmmo > 0.0)
				{
					double lf = 0.5 + 0.5 * sin(level.maptime * SHIMMER_SPEED + i * SHIMMER_PHASE);
					double lg = hLowAmmo * lf;
					wr_BB.SetBillboardGlow(mGauges[i], clamp(GLOW_R * lg, 0.0, 1.0), GLOW_S * lg);
				}
			}

			// The count, in its own lit bezel at the bottom of the card.
			if (i < mAmmos.Size() && mAmmos[i] != 0)
			{
				wr_BB.MoveBillboard(mAmmos[i], pos + lift - (0, 0, panelH * 0.41 * pulse));
				wr_BB.ResizeBillboard(mAmmos[i], panelW * mAmmoW[i] * pulse,
				                                 panelH * AMMO_H_FRAC * pulse);
				wr_BB.OrientBillboard(mAmmos[i], faceYaw, tilt, wr_BB.BBF_FIXED);
				wr_BB.RollBillboard(mAmmos[i], roll);

				// THE READOUTS BOOT UP.
				//
				// Progress is a reveal on the segment payload, not a value: the
				// bezel is a hairline slit at 0 that opens vertically, and the
				// characters do not appear at all until 0.55. Driving it with
				// the same curve the cards arrive on means each one powers on as
				// it lands rather than arriving already lit.
				wr_BB.SetBillboardProgress(mAmmos[i], grow);
			}

			// The fan hangs off whichever card opened it, so it is placed here
			// where that card's position has just been worked out.
			if (i == mExpanded)
			{
				layoutExpansion(bearing, fanSpread(ringCount),
				                pos, viewRight, faceYaw, tilt, panelW, panelH, cellW);
			}
		}
	}

	// AttackPos/OffhandPos are only written while OverrideAttackPosDir is set.
	// Without it they hold the actor's ORIGIN -- its feet -- so panels anchored
	// to them sit on the floor at ankle height and read as broken rather than
	// absent. The engine's own wheel hits this and synthesises a hand in front
	// of the camera instead; this does the same, so the rig is usable with no
	// tracked hands at all.
	//==========================================================================
	// PICKUP STAND-INS -- the generic hook, one branch per mod that needs it.
	//
	// Most mods leave a real Weapon actor lying on the floor and inspect mode
	// reads it directly. Some do not: they delete the unowned weapon and drop
	// a slot-generic placeholder that becomes a real gun only at the moment
	// you touch it. Pointing at one of those used to show nothing at all,
	// because the target was Weapon-typed and a placeholder is not a Weapon.
	//
	// The answer can depend on WHO IS ASKING -- Lithium's nine placeholders
	// each give a different weapon per character -- so the player is passed
	// in rather than assumed.
	//
	// FOUND (this is a placeholder we recognise), LABEL (what it would give,
	// or "" for a placeholder that gives THIS character nothing, which is a
	// real answer and not a failed lookup).
	private bool, string pickupStandIn(Actor a, PlayerPawn pmo)
	{
		bool got; string label;
		[got, label] = wr_CompatLithium.PickupOf(a, pmo);
		if (got) return true, label;

		return false, "";
	}

	// THE PICKUP CARD. Deliberately thin, because a placeholder genuinely
	// knows almost nothing -- it has no magazine, no ammo, no rolled stats,
	// and inventing rows to fill the space would be inventing data.
	//
	// What it does know is the one thing worth walking over for: which weapon
	// this becomes for the character you are playing right now.
	private void buildPickupRows(string label)
	{
		mSheetUsed = 0;

		bool nothing = (label.Length() == 0);
		string title = nothing ? "NOTHING HERE" : label;
		color  tint  = nothing ? color(SHEET_DIM) : color(SHEET_TEXT);

		if (mSheetTitle != 0)
		{
			wr_BB.SetBillboardText(mSheetTitle, title);
			wr_BB.UpdateBillboard(mSheetTitle, 0, tint);
		}
		if (mSheetAccent != 0) wr_BB.UpdateBillboard(mSheetAccent, 0, tint);

		// An empty label is not a lookup that failed -- it is the mod saying
		// this character cannot use this pickup at all, which is exactly what
		// you want to know BEFORE walking across a room for it.
		setSheetBar(0, SHEET_MEAS, false);   // a stand-in has no gauge to show

		if (nothing)
		{
			sheetRow("NOT FOR YOUR CHARACTER", COLOR_AMMO_DRY);
			blankRestOfSheet();
			return;
		}

		sheetRow("ON THE FLOOR", SHEET_DIM);
		sheetRow("PICK UP TO SEE ITS STATS", SHEET_DIM);
		blankRestOfSheet();
	}

	//==========================================================================
	// INSPECT MODE'S OWN TICK. Runs whether or not the ring is open, which is
	// the whole point -- see the mInspect* fields for why the sheet needed to
	// escape the wheel at all.
	private void tickInspect()
	{
		// THE RING WINS. Its own sheet is already showing what the selector
		// is on, and two sheets would be two answers to one question.
		if (mOpen || cv("wr_inspect", 1.0) <= 0.0)
		{
			endInspect();
			return;
		}

		if (!playeringame[consoleplayer] || players[consoleplayer].mo == null
		    || players[consoleplayer].playerstate != PST_LIVE)
		{
			endInspect();
			return;
		}

		let pmo = players[consoleplayer].mo;

		// DOOM Infinite opens full-screen ACS menus for its Limbo vendor,
		// mod station and guide, and gates its OWN input on exactly this
		// state. Inspect mode has to as well: it fires on dwell, unasked,
		// and inside a menu the laser is resting on the menu -- an uninvited
		// card over the vendor screen is the one place this could actively
		// get in the way. The RING is left alone deliberately; that takes a
		// keypress, so a player who opens it inside a menu meant to.
		if (wr_CompatDoomInfinite.Suppressed(pmo))
		{
			endInspect();
			return;
		}

		// Both hands are asked, and the MAIN hand wins a tie. Nothing here
		// casts a trace -- the engine refreshes these every render frame for
		// the laser sight, so this is a read of work already done.
		Actor tgt = null;
		int hand = 0;

		// RSQ: REMA's engine keeps what each hand's laser rests on (LaserTraceTargetMain/Off).
		// QZD 17.3 has no such field, so each hand traces for itself.
		tgt = laserTarget(pmo, 0);
		if (tgt != null) hand = 0;
		else
		{
			tgt = laserTarget(pmo, 1);
			if (tgt != null) hand = 1;
		}

		// Anything already in somebody's inventory is not a thing in the
		// world to consider -- that includes the two in your own hands, which
		// a laser can easily rest on. Asked of Inventory rather than Weapon
		// so it covers a pickup stand-in too.
		let tinv = Inventory(tgt);
		if (tinv != null && tinv.Owner != null) tgt = null;

		// TWO KINDS OF TARGET. A real weapon lying there is the ordinary
		// case. The other is a mod's slot-generic PICKUP STAND-IN, which is
		// not a Weapon at all and so was invisible here until now.
		//
		// Nothing else is accepted: the laser rests on monsters, walls and
		// scenery constantly, and a card for those would be noise.
		Weapon foundW = Weapon(tgt);
		bool  isPickup = false;
		string pickLabel = "";
		if (foundW == null && tgt != null)
			[isPickup, pickLabel] = pickupStandIn(tgt, pmo);

		Actor found = (foundW != null) ? Actor(foundW) : (isPickup ? tgt : null);

		if (found == null)
		{
			// GRACE, not an instant cut. A laser resting on a pickup wobbles
			// off it constantly; without this the card strobes.
			if (mInspectTics > 0) --mInspectTics;
			if (mInspectTics <= 0) endInspect();
			return;
		}

		// A different weapon restarts the dwell rather than inheriting the
		// last one's progress.
		if (found != mInspectCand)
		{
			mInspectCand = found;
			mInspectTics = 0;
		}

		mInspectHand = hand;

		int want = int(cv("wr_inspect_dwell", 18.0));
		// Capped just past the dwell. The counter is also the grace that runs
		// down after the laser leaves the target, so an uncapped count froze
		// the card in mid-air for exactly as long as you had been looking.
		if (mInspectTics < want + 3) ++mInspectTics;
		if (mInspectTics < want) return;

		// TWO DIFFERENT CARDS, and which one appears depends on whether
		// there is anything to compare against.
		//
		// With a weapon in that hand, the question is a TRADE -- this versus
		// that -- and a table answers it. With an empty hand there is no
		// trade, only "what is this", which is exactly what the ordinary
		// data sheet already says better than a table with one column
		// filled could.
		Weapon mine = (mInspectHand == 1) ? pmo.player.OffhandWeapon
		                                  : pmo.player.ReadyWeapon;

		// A pickup stand-in has nothing to compare WITH -- it is a promise of
		// a weapon, not a weapon, and none of the resolver's stats exist for
		// it. So the trade card is a weapon-only path by construction.
		bool wantCompare = (foundW != null && mine != null && mine != foundW
		                    && cv("wr_inspect_delta", 1.0) > 0.0);

		// Re-strung when the target changes, AND on a cadence while it does not.
		//
		// Neither fill is cheap enough for every tic, but once-only was worse:
		// inspect mode has no lock timer, so a floor weapon's DESPAWN clock -- the
		// row whose own comment calls it "the row with a deadline on it" -- sat at
		// whatever second it read when the dwell completed, indefinitely. Same
		// cadence the ring's sheet uses. Audit finding #25.
		// THE HELD WEAPON AND THE MODE COUNT AS CHANGES TOO.
		//
		// `mine` and `wantCompare` are recomputed every tic, but only a change of
		// the FLOOR weapon triggered a re-fill -- so switching what you are
		// holding while still pointing at the same pickup left the card reading
		// "vs PISTOL", with the HELD column and every better/worse verdict still
		// about the pistol. The card silently lied about the one question it
		// exists to answer.
		//
		// wantCompare flipping is the worse half: with no rebuild, layoutCompare
		// runs with mCmpPlate == 0 (or layoutInspect with mSheetPlate == 0, since
		// the compare branch called clearSheet), both early-return, and whichever
		// card IS on screen stops being positioned and hangs frozen in mid-air.
		// Audit finding #21 / #24.
		bool inspDue = (level.maptime - mInspectBuiltTic) >= SHEET_TICK;
		if (mInspectWpn != found || mInspectMine != mine
		    || mInspectCompare != wantCompare || inspDue)
		{
			mInspectWpn     = found;
			mInspectMine    = mine;
			mInspectCompare = wantCompare;
			mInspectBuiltTic = level.maptime;

			if (wantCompare)
			{
				clearSheet();
				if (mCmpPlate == 0) buildCompare();
				fillCompare(foundW, mine);
			}
			else
			{
				clearCompare();
				if (mSheetPlate == 0) buildSheet();
				mSheetShown = null;          // force buildSheetRows to redraw
				if (foundW != null) buildSheetRows(foundW);
				else                buildPickupRows(pickLabel);
				blankRestOfSheet();
			}
		}

		if (wantCompare) layoutCompare(pmo);
		else             layoutInspect(pmo);
	}

	//==========================================================================
	// THE COMPARISON CARD.
	//
	// Built once, restrung as the target changes, torn down with inspect
	// mode -- the same lifecycle the sheet's own row pool has, and for the
	// same reason: a billboard created per tic is a billboard leaked per tic.
	private void buildCompare()
	{
		clearCompare();

		double w = panelWNow() * CMP_W_CARDS;
		double h = panelHNow() * CMP_H_CARDS;

		mCmpPlate = wr_BB.AddBillboardPersistent(
			(0, 0, 0), w, h, 0, 0,
			wr_BB.BBF_FIXED, plateKind(), plateShape(),
			SHEET_BG, wr_BB.BBFL_NOHIT, 0, "");
		wr_BB.SetBillboardGradient(mCmpPlate, SHEET_BG2);

		mCmpAccent = wr_BB.AddBillboardPersistent(
			(0, 0, 0), w, 0.3, 0, 0,
			wr_BB.BBF_FIXED, wr_BB.BB_PANEL, 0,
			SHEET_ACCENT, wr_BB.BBFL_NOHIT, 0, "");

		mCmpTitle = mkCmpText(SHEET_ACCENT);
		mCmpSub   = mkCmpText(SHEET_DIM);
		mCmpHeadA = mkCmpText(SHEET_DIM);
		mCmpHeadB = mkCmpText(SHEET_DIM);

		for (int i = 0; i < CMP_ROW_POOL; ++i)
		{
			mCmpLabel.Push(mkCmpText(SHEET_DIM));
			mCmpA.Push(mkCmpText(SHEET_TEXT));
			mCmpB.Push(mkCmpText(SHEET_TEXT));
		}
		mCmpUsed = 0;
	}

	private int mkCmpText(int col)
	{
		return wr_BB.AddBillboardPersistent(
			(0, 0, 0), 3.5, 2.5, 0, 0,
			wr_BB.BBF_FIXED, wr_BB.BB_TEXT, 0,
			col, wr_BB.BBFL_NOHIT, 0, "");
	}

	private void clearCompare()
	{
		for (int i = 0; i < mCmpLabel.Size(); ++i) if (mCmpLabel[i]) wr_BB.RemoveBillboard(mCmpLabel[i]);
		for (int i = 0; i < mCmpA.Size(); ++i)     if (mCmpA[i])     wr_BB.RemoveBillboard(mCmpA[i]);
		for (int i = 0; i < mCmpB.Size(); ++i)     if (mCmpB[i])     wr_BB.RemoveBillboard(mCmpB[i]);
		mCmpLabel.Clear(); mCmpA.Clear(); mCmpB.Clear();

		if (mCmpPlate)  wr_BB.RemoveBillboard(mCmpPlate);
		if (mCmpAccent) wr_BB.RemoveBillboard(mCmpAccent);
		if (mCmpTitle)  wr_BB.RemoveBillboard(mCmpTitle);
		if (mCmpSub)    wr_BB.RemoveBillboard(mCmpSub);
		if (mCmpHeadA)  wr_BB.RemoveBillboard(mCmpHeadA);
		if (mCmpHeadB)  wr_BB.RemoveBillboard(mCmpHeadB);
		mCmpPlate = 0; mCmpAccent = 0; mCmpTitle = 0; mCmpSub = 0;
		mCmpHeadA = 0; mCmpHeadB = 0;
		mCmpUsed = 0;
	}

	// One line: a label and two values. Colour is decided per SIDE rather
	// than per row -- the better of the two is lit, the loser dimmed -- so
	// the verdict reads without parsing either number.
	// better: 1 = the world weapon wins, -1 = the held one, 0 = neither.
	private void cmpRow(string label, string a, string b, int better)
	{
		if (mCmpUsed >= mCmpLabel.Size()) return;
		int i = mCmpUsed;
		++mCmpUsed;

		wr_BB.SetBillboardText(mCmpLabel[i], label);
		wr_BB.UpdateBillboard(mCmpLabel[i], 0, SHEET_DIM);

		wr_BB.SetBillboardText(mCmpA[i], a);
		wr_BB.UpdateBillboard(mCmpA[i], 0,
			(better > 0) ? color(COLOR_DELTA_UP)
			: (better < 0) ? color(COLOR_DELTA_DOWN) : color(SHEET_TEXT));

		wr_BB.SetBillboardText(mCmpB[i], b);
		wr_BB.UpdateBillboard(mCmpB[i], 0,
			(better < 0) ? color(COLOR_DELTA_UP)
			: (better > 0) ? color(COLOR_DELTA_DOWN) : color(SHEET_TEXT));
	}

	private void blankRestOfCompare()
	{
		for (int i = mCmpUsed; i < mCmpLabel.Size(); ++i)
		{
			wr_BB.SetBillboardText(mCmpLabel[i], "");
			wr_BB.SetBillboardText(mCmpA[i], "");
			wr_BB.SetBillboardText(mCmpB[i], "");
		}
	}

	// Fill the card for one pair. found is the weapon in the world, mine the
	// one that hand is currently holding.
	private void fillCompare(Weapon found, Weapon mine)
	{
		mCmpUsed = 0;

		// The three inventory-facing rows below need the player, which the
		// two weapons alone cannot supply -- the one on the floor has no
		// owner at all, which is the whole reason this card exists.
		let pmo = players[consoleplayer].mo;

		wr_BB.SetBillboardText(mCmpTitle, "" .. found.GetTag());
		wr_BB.SetBillboardText(mCmpSub,   "vs " .. mine.GetTag());
		wr_BB.SetBillboardText(mCmpHeadA, "THIS");
		wr_BB.SetBillboardText(mCmpHeadB, "HELD");

		cmpStat(found, mine, "DPS", 0);
		cmpStat(found, mine, "DAMAGE", 1);
		cmpStat(found, mine, "ROF", 2);
		cmpStat(found, mine, "MAG", 3);
		cmpStat(found, mine, "PELLETS", 4);

		// AMMO TYPE, and it is not a number -- it is the question "can I even
		// feed this". A better gun you have no ammo for is not better, and
		// nothing else on this card would say so.
		cmpRow("AMMO", ammoLabel(found), ammoLabel(mine), 0);

		// TIER, only when BOTH sides have one. A rarity word against a blank
		// is not a comparison.
		bool ta, tb; string wa, wb;
		[ta, wa] = tierWordOf(found);
		[tb, wb] = tierWordOf(mine);
		if (ta && tb) cmpRow("TIER", wa, wb, 0);

		// WHAT IT COSTS YOU IN HANDS. A two-handed weapon takes the other
		// hand out of play, so it is not competing on damage alone -- it is
		// competing against whatever that hand was doing.
		cmpRow("HANDS", handsWord(found), handsWord(mine), 0);

		// EVERY MOD-SPECIFIC ROW EITHER WEAPON HAS, from the exact same
		// reader functions the ordinary sheet already trusts.
		//
		// The condensed version of this ("UPGRADES: 3" as a bare count) was
		// wrong, and not for a subtle reason: eleven compat files exist
		// specifically to surface what a weapon actually carries -- augment
		// types, rolled effects, which Mod Station slots are filled, a
		// player's own rolled stats -- and collapsing all of that into one
		// number was throwing the entire point of those files away for the
		// one card where showing it matters most.
		//
		// MERGED BY LABEL, NOT FORCED INTO A SHARED SCHEMA. Two weapons from
		// the SAME mod share a label ("AUG" vs "AUG") and sit in one row
		// side by side. Two weapons from DIFFERENT mods do not pretend to
		// share a concept -- Insurrection's augments and DRLA's mods are not
		// the same axis -- so each gets its own row with the other column
		// left at "--", which shows everything either weapon offers without
		// inventing a comparison that is not real.
		Array<string> la, va, lb, vb;
		modRowsOf(found, la, va);
		modRowsOf(mine,  lb, vb);

		Array<bool> usedB;
		for (int i = 0; i < lb.Size(); ++i) usedB.Push(false);

		for (int i = 0; i < la.Size(); ++i)
		{
			int match = -1;
			for (int j = 0; j < lb.Size(); ++j)
			{
				if (!usedB[j] && lb[j] == la[i]) { match = j; break; }
			}
			if (match >= 0)
			{
				usedB[match] = true;
				cmpRow(la[i], va[i], vb[match], 0);
			}
			else cmpRow(la[i], va[i], "--", 0);
		}
		for (int j = 0; j < lb.Size(); ++j)
		{
			if (!usedB[j]) cmpRow(lb[j], "--", vb[j], 0);
		}

				blankRestOfCompare();
	}

	// Melee / two-handed / off-hand-only, in the same words the ring's own
	// title row uses, so the two surfaces never describe one weapon
	// differently.
	private static string handsWord(Weapon w)
	{
		if (!w) return "--";
		if (w.bMeleeWeapon) return "MELEE";
		if (w.bTwoHanded)   return "TWO";
		if (w.bOffhandWeapon) return "OFF";
		return "ONE";
	}

	// EVERY SUPPLEMENTARY ROW A SINGLE WEAPON COULD PRODUCE, from every
	// compat file in this mod -- the exact same calls buildSheetRows() makes
	// for the sheet, run here for one weapon in isolation so fillCompare()
	// can run it twice and merge the results.
	//
	// Only what is not ALREADY covered by wr_stats.zs is included. BorderDoom's
	// damage/accuracy/rate-of-fire/clip and Pandemonia's magazine are all
	// resolved sources for the universal DAMAGE/ROF/MAG rows already drawn
	// above this block -- repeating them here would be the same number
	// twice under two different labels.
	private static void modRowsOf(Weapon w, out Array<string> labels, out Array<string> values)
	{
		labels.Clear();
		values.Clear();
		if (!w) return;

		// LegenDoom
		string ldE = wr_CompatLegenDoom.EffectsOf(w);
		if (ldE.Length() > 0) { labels.Push("EFFECT"); values.Push(ldE); }

		// RSQ: Gun Bonsai (wr_q_bonsai.zs) -- level and how many upgrades
		int gbLv = cv("wr_sheet_bonsai", 1.0) > 0.0 ? WR_Bonsai.Level(null, w) : -1;
		if (gbLv >= 0)
		{
			Array<String> gbN; Array<int> gbL;
			int gbC = WR_Bonsai.Upgrades(null, w, gbN, gbL);
			labels.Push("BONSAI");
			values.Push(gbC > 0 ? String.Format("LV %d  %d UPG", gbLv, gbC) : String.Format("LV %d", gbLv));
		}

		// DRLA
		int drlaM1, drlaM2;
		[drlaM1, drlaM2] = wr_CompatDRLA.ModsOf(w);
		if (drlaM1 != 0 || drlaM2 != 0)
		{
			labels.Push("MOD");
			values.Push(wr_CompatDRLA.ModsWord(drlaM1, drlaM2));
		}

		// Pandemonia Insurrection
		bool insHas; int insCur, insMax;
		[insHas, insCur, insMax] = wr_CompatPandemoniaInsurrection.CountOf(w);
		if (insHas && insCur > 0)
		{
			string b = wr_CompatPandemoniaInsurrection.BreakdownOf(w);
			labels.Push("AUG");
			values.Push(b.Length() ? String.Format("%d/%d %s", insCur, insMax, b)
			                       : String.Format("%d/%d", insCur, insMax));
		}

		bool insColHas; string insCol;
		[insColHas, insCol] = wr_CompatPandemoniaInsurrection.ColorTagOf(w);
		if (insColHas) { labels.Push("TAG"); values.Push(insCol); }

		bool insDHas; int insDCur, insDMax; bool insDBroken;
		[insDHas, insDCur, insDMax, insDBroken] = wr_CompatPandemoniaInsurrection.DurabilityOf(w);
		if (insDHas)
		{
			labels.Push("DURA");
			values.Push(insDBroken ? "BROKEN" : String.Format("%d/%d", insDCur, insDMax));
		}

		bool insSHas; string insSup;
		[insSHas, insSup] = wr_CompatPandemoniaInsurrection.SuperiorOf(w);
		if (insSHas) { labels.Push("SUPERIOR"); values.Push(insSup); }

		bool insCHas; int insCCur, insCMax;
		[insCHas, insCCur, insCMax] = wr_CompatPandemoniaInsurrection.ComboOf(w);
		if (insCHas) { labels.Push("COMBO"); values.Push(String.Format("%d/%d", insCCur, insCMax)); }

		bool insAHas; int insALvl, insACharge;
		[insAHas, insALvl, insACharge] = wr_CompatPandemoniaInsurrection.AeonstaveOf(w);
		if (insAHas)
		{
			labels.Push("AEON");
			values.Push(String.Format("LVL %d %d/%d", insALvl, insACharge,
			            wr_CompatPandemoniaInsurrection.AEON_CHARGE_MAX));
		}

		// Pandemonia base
		bool pdHas; int pdCur, pdMax; bool pdBroken;
		[pdHas, pdCur, pdMax, pdBroken] = wr_CompatPandemonia.DurabilityOf(w);
		// Guarded against Insurrection's identical reader -- see the note on the
		// sheet's copy. Two DURA labels here meant the merge loop emitted two
		// identical comparison rows. Audit finding #36.
		if (pdHas && !insDHas)
		{
			labels.Push("DURA");
			values.Push(pdBroken ? "BROKEN" : String.Format("%d/%d", pdCur, pdMax));
		}

		bool psHas, ps1, ps2; string psLabel;
		[psHas, ps1, ps2, psLabel] = wr_CompatPandemonia.SidegradesOf(w);
		if (psHas)
		{
			labels.Push("SIDEGRADE");
			values.Push(psLabel.Length() ? psLabel
			            : String.Format("%d/2", (ps1 ? 1 : 0) + (ps2 ? 1 : 0)));
		}

		bool glHas; int glLvl;
		[glHas, glLvl] = wr_CompatPandemonia.GameLevelOf(w);
		if (glHas) { labels.Push("GAME LVL"); values.Push(String.Format("%d", glLvl)); }

		// Pandemonia Anarchy
		bool sigHas; int sigLvl, sigPts, sigMax; bool sigCd;
		[sigHas, sigLvl, sigPts, sigMax, sigCd] = wr_CompatPandemoniaAnarchy.SigilOf(w);
		if (sigHas)
		{
			labels.Push("SIGIL");
			values.Push(String.Format("LVL %d  %d/%d", sigLvl, sigPts, sigMax));
		}

		// Guncaster
		bool gcHas; double gcCd;
		[gcHas, gcCd] = wr_CompatGuncaster.SpellCooldownOf(w);
		if (gcHas) { labels.Push("SPELL CD"); values.Push(String.Format("%.1fs", gcCd)); }

		string gcRes = wr_CompatGuncaster.ResourcesOf(w);
		if (gcRes.Length() > 0) { labels.Push("RESOURCES"); values.Push(gcRes); }

		// MetaDoom
		bool mhHas; int mHeat, mShots;
		[mhHas, mHeat, mShots] = wr_CompatMetaDoom.HeatOf(w);
		if (mhHas) { labels.Push("HEAT"); values.Push(String.Format("%d/5", mHeat)); }

		bool mkHas; int mKeys;
		[mkHas, mKeys] = wr_CompatMetaDoom.KeysOf(w);
		if (mkHas) { labels.Push("KEYS"); values.Push(String.Format("%d/3", mKeys)); }

		// Doomablo (player-side, but attached to the weapon's owner and worth
		// showing here the same way the sheet shows it regardless of rarity)
		bool dlHas; int dLvl; double dXp, dXpNext; int dPts;
		[dlHas, dLvl, dXp, dXpNext, dPts] = wr_CompatDoomablo.LevelOf(w);
		if (dlHas) { labels.Push("LVL"); values.Push(String.Format("%d", dLvl)); }

		bool diHas; int dInferno;
		[diHas, dInferno] = wr_CompatDoomablo.InfernoLevelOf(w);
		if (diHas) { labels.Push("INFERNO"); values.Push(String.Format("%d", dInferno)); }

		bool dsHas; int dVit, dCrc, dCrd, dStr, dRf;
		[dsHas, dVit, dCrc, dCrd, dStr, dRf] = wr_CompatDoomablo.StatsOf(w);
		if (dsHas)
		{
			labels.Push("STATS");
			values.Push(String.Format("VIT%d STR%d CRT%d%%", dVit, dStr, dCrc));
		}

		// BorderDoom -- only LEVEL, since damage/accuracy/rof/clip are
		// already the universal rows' declared source.
		bool bdHas; int bdDmg, bdAcc, bdRof, bdRcl, bdClip, bdLvl;
		[bdHas, bdDmg, bdAcc, bdRof, bdRcl, bdClip, bdLvl] = wr_CompatBorderDoom.StatsOf(w);
		if (bdHas) { labels.Push("BD LVL"); values.Push(String.Format("%d", bdLvl)); }

		// DOOM Infinite -- everything the universal rows cannot carry. The
		// rolled stats themselves (damage, rate of fire, pellets, crit) are
		// already the DECLARED source for those rows, so repeating them here
		// would print the same number twice under two labels.
		bool diQHas; string diQ;
		[diQHas, diQ] = wr_CompatDoomInfinite.QuirksOf(w);
		if (diQHas) { labels.Push("QUIRKS"); values.Push(diQ); }

		bool diLHas; string diL;
		[diLHas, diL] = wr_CompatDoomInfinite.LoadoutOf(w);
		if (diLHas) { labels.Push("LOADOUT"); values.Push(diL); }

		bool diSHas; double diS;
		[diSHas, diS] = wr_CompatDoomInfinite.SpreadOf(w);
		if (diSHas) { labels.Push("SPREAD"); values.Push(String.Format("%.1f", diS)); }

		bool diCHas; int diC;
		[diCHas, diC] = wr_CompatDoomInfinite.AmmoCostOf(w);
		if (diCHas) { labels.Push("AMMO COST"); values.Push(String.Format("%d", diC)); }

		bool diJHas; int diJ;
		[diJHas, diJ] = wr_CompatDoomInfinite.JamOf(w);
		if (diJHas) { labels.Push("JAM"); values.Push(String.Format("%d%%", diJ)); }

		bool diKHas; string diK;
		[diKHas, diK] = wr_CompatDoomInfinite.LocksOf(w);
		if (diKHas) { labels.Push("LOCKED"); values.Push(diK); }

		bool diOHas; int diOv, diOm;
		[diOHas, diOv, diOm] = wr_CompatDoomInfinite.OverchargeOf(w);
		if (diOHas) { labels.Push("OVERCHARGE"); values.Push(String.Format("%d/%d", diOv, diOm)); }

		bool diDHas; int diD;
		[diDHas, diD] = wr_CompatDoomInfinite.DespawnOf(w);
		if (diDHas) { labels.Push("DESPAWN"); values.Push(String.Format("%ds", diD)); }

		bool diHHas; int diHv; double diHp;
		[diHHas, diHv, diHp] = wr_CompatDoomInfinite.HeatOf(w);
		if (diHHas) { labels.Push("HEAT"); values.Push(String.Format("%d/100", diHv)); }

		// Combined Arms
		bool caHHas; int caH, caHMax, caOver;
		[caHHas, caH, caHMax, caOver] = wr_CompatCombinedArms.HeatOf(w);
		if (caHHas)
		{
			labels.Push("HEAT");
			values.Push(caOver > 0 ? "OVERHEAT" : String.Format("%d/%d", caH, caHMax));
		}

		bool caRHas; string caRRow;
		[caRHas, caRRow] = wr_CompatCombinedArms.ResourceRow(w);
		if (caRHas) { labels.Push("RESOURCE"); values.Push(caRRow); }

		bool caCHas; string caCRow;
		[caCHas, caCRow] = wr_CompatCombinedArms.CooldownRow(w);
		if (caCHas) { labels.Push("COOLDOWN"); values.Push(caCRow); }

		bool caUHas; string caURow;
		[caUHas, caURow] = wr_CompatCombinedArms.UpgradeRow(w);
		if (caUHas) { labels.Push("UPGRADE"); values.Push(caURow); }

		bool caEHas; string caERow;
		[caEHas, caERow] = wr_CompatCombinedArms.ExpiryRow(w);
		if (caEHas) { labels.Push("EXPIRES"); values.Push(caERow); }

		bool caHiHas; string caHiRow;
		[caHiHas, caHiRow] = wr_CompatCombinedArms.HiddenRow(w);
		if (caHiHas) { labels.Push("HIDDEN"); values.Push(caHiRow); }

		// Final Doomer
		bool fdNHas; string fdNRow;
		[fdNHas, fdNRow] = wr_CompatFinalDoomer.NameOf(w);
		if (fdNHas) { labels.Push("SET"); values.Push(fdNRow); }

		bool fdSprHas; int fdSprN, fdSprMax;
		[fdSprHas, fdSprN, fdSprMax] = wr_CompatFinalDoomer.InaccuracyOf(w);
		if (fdSprHas) { labels.Push("SPREAD"); values.Push(String.Format("%d/%d", fdSprN, fdSprMax)); }

		bool fdBfgHas; int fdBfgN, fdBfgMax;
		[fdBfgHas, fdBfgN, fdBfgMax] = wr_CompatFinalDoomer.BfgChargeOf(w);
		if (fdBfgHas) { labels.Push("CHARGE"); values.Push(String.Format("%d/%d", fdBfgN, fdBfgMax)); }

		bool fdFcHas; int fdFcStage;
		[fdFcHas, fdFcStage] = wr_CompatFinalDoomer.FistComboOf(w);
		if (fdFcHas) { labels.Push("COMBO"); values.Push(String.Format("%d/2", fdFcStage)); }

		bool fdBuHas; int fdBuN, fdBuMax;
		[fdBuHas, fdBuN, fdBuMax] = wr_CompatFinalDoomer.BurstOf(w);
		if (fdBuHas) { labels.Push("BURST"); values.Push(String.Format("%d/%d", fdBuN, fdBuMax)); }

		bool fdHalHas; string fdHalWord;
		[fdHalHas, fdHalWord] = wr_CompatFinalDoomer.HaldermanOf(w);
		if (fdHalHas) { labels.Push("MODE"); values.Push(fdHalWord); }

		bool fdMagHas; int fdMagL, fdMagR, fdMagMax;
		[fdMagHas, fdMagL, fdMagR, fdMagMax] = wr_CompatFinalDoomer.MagnumsOf(w);
		if (fdMagHas) { labels.Push("CYLINDERS"); values.Push(String.Format("L%d R%d /%d", fdMagL, fdMagR, fdMagMax)); }

		bool fdPumpHas; int fdPumpN, fdPumpMax;
		[fdPumpHas, fdPumpN, fdPumpMax] = wr_CompatFinalDoomer.PumpOf(w);
		if (fdPumpHas) { labels.Push("PUMP"); values.Push(String.Format("%d/%d", fdPumpN, fdPumpMax)); }

		bool fdC4Has; int fdC4N, fdC4Max;
		[fdC4Has, fdC4N, fdC4Max] = wr_CompatFinalDoomer.C4Of(w);
		if (fdC4Has) { labels.Push("C4 CHARGES"); values.Push(String.Format("%d/%d", fdC4N, fdC4Max)); }

		bool fdVcHas; int fdVcStage;
		[fdVcHas, fdVcStage] = wr_CompatFinalDoomer.VendettaComboOf(w);
		if (fdVcHas) { labels.Push("COMBO"); values.Push(String.Format("%d/2", fdVcStage)); }

		bool fdSgHas; int fdSgN, fdSgMax;
		[fdSgHas, fdSgN, fdSgMax] = wr_CompatFinalDoomer.ShattergunOf(w);
		if (fdSgHas) { labels.Push("BURST"); values.Push(String.Format("%d/%d", fdSgN, fdSgMax)); }

		bool fdLockHas; bool fdLocked;
		[fdLockHas, fdLocked] = wr_CompatFinalDoomer.BfgLockOf(w);
		if (fdLockHas) { labels.Push("LOCK"); values.Push(fdLocked ? "LOCKED" : "SCANNING"); }

		bool fdKatHas; bool fdKatDrawn; bool fdKatNrg;
		[fdKatHas, fdKatDrawn, fdKatNrg] = wr_CompatFinalDoomer.KatanaOf(w);
		if (fdKatHas) { labels.Push("KATANA"); values.Push(fdKatDrawn ? "DRAWN" : "SHEATHED"); }

		bool fdNdlHas; int fdNdlN, fdNdlMax;
		[fdNdlHas, fdNdlN, fdNdlMax] = wr_CompatFinalDoomer.NeedlerOf(w);
		if (fdNdlHas) { labels.Push("BURST"); values.Push(String.Format("%d/%d", fdNdlN, fdNdlMax)); }

		bool fdNanoHas; bool fdNanoOn;
		[fdNanoHas, fdNanoOn] = wr_CompatFinalDoomer.NanoCoreOf(w);
		if (fdNanoHas) { labels.Push("NANOCORE"); values.Push(fdNanoOn ? "ACTIVE" : "READY"); }

		bool fdFChHas; int fdFChN, fdFChMax;
		[fdFChHas, fdFChN, fdFChMax] = wr_CompatFinalDoomer.FistChargeOf(w);
		if (fdFChHas) { labels.Push("CHARGE"); values.Push(String.Format("%d/%d", fdFChN, fdFChMax)); }

		bool fdPChHas; int fdPChN, fdPChMax;
		[fdPChHas, fdPChN, fdPChMax] = wr_CompatFinalDoomer.PistolChargeOf(w);
		if (fdPChHas) { labels.Push("CHARGE"); values.Push(String.Format("%d/%d", fdPChN, fdPChMax)); }

		bool fdHeatHas; int fdHeatN, fdHeatMax; bool fdHeatOn;
		[fdHeatHas, fdHeatN, fdHeatMax, fdHeatOn] = wr_CompatFinalDoomer.ThermoCoatOf(w);
		if (fdHeatHas) { labels.Push("HEAT"); values.Push(fdHeatOn ? String.Format("%d/%d ACTIVE", fdHeatN, fdHeatMax) : String.Format("%d/%d", fdHeatN, fdHeatMax)); }

		bool fdWcHas; int fdWcN, fdWcMax; bool fdWcOver;
		[fdWcHas, fdWcN, fdWcMax, fdWcOver] = wr_CompatFinalDoomer.WmChaingunOf(w);
		if (fdWcHas) { labels.Push("SPEED"); values.Push(fdWcOver ? String.Format("%d/%d OVERLOAD", fdWcN, fdWcMax) : String.Format("%d/%d", fdWcN, fdWcMax)); }

		bool fdWbHas; int fdWbTics;
		[fdWbHas, fdWbTics] = wr_CompatFinalDoomer.WmBfgOf(w);
		if (fdWbHas) { labels.Push("FIRING"); values.Push(String.Format("%ds", fdWbTics / 35 + 1)); }

		bool fdWrHas; int fdWrN, fdWrMax;
		[fdWrHas, fdWrN, fdWrMax] = wr_CompatFinalDoomer.WmRocketOf(w);
		if (fdWrHas) { labels.Push("CHARGE"); values.Push(String.Format("%d/%d", fdWrN, fdWrMax)); }
	}

	// One resolved stat, both weapons, side by side.
	//
	// NEVER PICKS A WINNER ACROSS A MASK. A cursed stat still draws its row
	// -- the player should see that the stat exists and is hidden -- but as
	// ??? with neither side lit, because colouring one better would leak the
	// very comparison the curse exists to prevent.
	private void cmpStat(Weapon a, Weapon b, string label, int which)
	{
		int sa, sb;
		double va, vb;
		string ta, tb;

		if (which == 0 || which == 1)
		{
			int alo, ahi, blo, bhi;
			if (which == 0) { [sa, alo, ahi] = wr_Stats.Dps(a);    [sb, blo, bhi] = wr_Stats.Dps(b); }
			else            { [sa, alo, ahi] = wr_Stats.Damage(a); [sb, blo, bhi] = wr_Stats.Damage(b); }
			// A RANGE COMPARES BY ITS MIDPOINT -- two spans have no single
			// difference, and the midpoint is what a player means by "hits
			// harder". Both full spans are still PRINTED; only the verdict
			// is decided on the midpoint.
			va = double(alo + ahi) * 0.5;
			vb = double(blo + bhi) * 0.5;
			ta = wr_Stats.Span(alo, ahi);
			tb = wr_Stats.Span(blo, bhi);
		}
		else if (which == 2)
		{
			[sa, va] = wr_Stats.Rof(a);
			[sb, vb] = wr_Stats.Rof(b);
			ta = String.Format("%.1f/s", va);
			tb = String.Format("%.1f/s", vb);
		}
		else if (which == 3)
		{
			int ai, bi, la, lb;
			[sa, la, ai] = wr_Stats.Magazine(a);
			[sb, lb, bi] = wr_Stats.Magazine(b);
			va = double(ai); vb = double(bi);
			ta = String.Format("%d", ai);
			tb = String.Format("%d", bi);
		}
		else
		{
			int ai, bi;
			[sa, ai] = wr_Stats.Pellets(a);
			[sb, bi] = wr_Stats.Pellets(b);
			va = double(ai); vb = double(bi);
			ta = String.Format("%d%s", ai, wr_Stats.FloorMark(sa));
			tb = String.Format("%d%s", bi, wr_Stats.FloorMark(sb));
		}

		if (sa == wr_Stats.SRC_MASKED || sb == wr_Stats.SRC_MASKED)
		{
			cmpRow(label,
			       sa == wr_Stats.SRC_MASKED ? "???" : ta,
			       sb == wr_Stats.SRC_MASKED ? "???" : tb, 0);
			return;
		}

		// A row neither side can answer says nothing and is skipped. One side
		// answering is still worth drawing, with the other as "--".
		if (sa == wr_Stats.SRC_UNKNOWN && sb == wr_Stats.SRC_UNKNOWN) return;
		if (sa == wr_Stats.SRC_UNKNOWN) { cmpRow(label, "--", tb, 0); return; }
		if (sb == wr_Stats.SRC_UNKNOWN) { cmpRow(label, ta, "--", 0); return; }

		int better = (va > vb + 0.05) ? 1 : (vb > va + 0.05) ? -1 : 0;
		cmpRow(label, ta, tb, better);
	}

	// The tier WORD for whichever mod rolled this weapon, if any did. Reuses
	// the same four readers the ring title row uses rather than starting a
	// second table that could drift out of step with it.
	private static bool, string tierWordOf(Weapon w)
	{
		int tier;
		if (wr_Field.GetFieldInt(w, "Tier", tier)) return true, tierWord(tier);

		bool got; int r;
		[got, r] = wr_CompatLegenDoom.RarityOf(w);
		if (got) return true, wr_CompatLegenDoom.RarityWord(r);

		[got, r] = wr_CompatDRLA.TierOf(w);
		if (got) return true, wr_CompatDRLA.TierWord(r);

		[got, r] = wr_CompatDoomablo.RarityOf(w);
		if (got) return true, wr_CompatDoomablo.RarityWord(r);

		bool diGot; color diCol; string diWord;
		[diGot, diCol, diWord] = wr_CompatDoomInfinite.FlavorOf(w);
		if (diGot) return true, diWord;

		return false, "";
	}

	// Three columns, laid out every tic so the card tracks the hand rather
	// than hanging where the pickup was first seen.
	private void layoutCompare(PlayerPawn pmo, bool atRing = false)
	{
		if (mCmpPlate == 0) return;

		double viewYaw = pmo.angle;
		Vector3 right  = (cos(viewYaw - 90), sin(viewYaw - 90), 0);
		Vector3 centre = handPos(pmo, mInspectHand) + (0, 0, cv("wr_rise", 2.0));
		// RSQ: the two-hand comparison stands where the sheet does, in the middle of the ring
		if (atRing && mHaveAnchor) centre = mAnchor + (0, 0, cv("wr_rise", 2.0));
		Vector3 lift   = (cos(viewYaw + 180), sin(viewYaw + 180), 0) * LABEL_LIFT;
		double  yaw    = viewYaw + 180;
		double  tilt   = PANEL_TILT;

		double w = panelWNow() * CMP_W_CARDS;
		double h = panelHNow() * CMP_H_CARDS;

		wr_BB.MoveBillboard(mCmpPlate, centre);
		wr_BB.ResizeBillboard(mCmpPlate, w, h);
		wr_BB.OrientBillboard(mCmpPlate, yaw, tilt, wr_BB.BBF_FIXED);

		double top = h * 0.5;

		wr_BB.MoveBillboard(mCmpAccent, centre + lift + (0, 0, top - h * 0.03));
		wr_BB.ResizeBillboard(mCmpAccent, w * 0.94, h * 0.02);
		wr_BB.OrientBillboard(mCmpAccent, yaw, tilt, wr_BB.BBF_FIXED);

		double rowH = h * CMP_ROW_FRAC;

		// Title and subtitle span the whole card; the headers and every row
		// below them sit in their own column.
		placeCmp(mCmpTitle, centre + lift + (0, 0, top - h * 0.09), w * 0.9, rowH * 1.2, yaw, tilt);
		placeCmp(mCmpSub,   centre + lift + (0, 0, top - h * 0.17), w * 0.9, rowH * 0.9, yaw, tilt);

		double colL = -w * CMP_COL_LABEL;
		double colA =  w * CMP_COL_A;
		double colB =  w * CMP_COL_B;
		double colW =  w * CMP_COL_W;

		double y = top - h * CMP_ROWS_TOP;
		placeCmp(mCmpHeadA, centre + lift + right * colA + (0, 0, y), colW, rowH * 0.85, yaw, tilt);
		placeCmp(mCmpHeadB, centre + lift + right * colB + (0, 0, y), colW, rowH * 0.85, yaw, tilt);
		y -= rowH * CMP_ROW_PITCH;

		for (int i = 0; i < mCmpLabel.Size(); ++i)
		{
			placeCmp(mCmpLabel[i], centre + lift + right * colL + (0, 0, y), w * 0.30, rowH, yaw, tilt);
			placeCmp(mCmpA[i],     centre + lift + right * colA + (0, 0, y), colW,     rowH, yaw, tilt);
			placeCmp(mCmpB[i],     centre + lift + right * colB + (0, 0, y), colW,     rowH, yaw, tilt);
			y -= rowH * CMP_ROW_PITCH;
		}
	}

	private void placeCmp(int id, Vector3 pos, double w, double h, double yaw, double tilt)
	{
		if (id == 0) return;
		wr_BB.MoveBillboard(id, pos);
		wr_BB.ResizeBillboard(id, w, h);
		wr_BB.OrientBillboard(id, yaw, tilt, wr_BB.BBF_FIXED);
	}

	// Tear the inspect sheet down, but ONLY if inspect is what built it --
	// the ring's own sheet uses the same billboards and must not be freed out
	// from under it.
	private void endInspect()
	{
		mInspectCand = null;
		mInspectTics = 0;
		if (mInspectWpn == null) return;   // Actor now -- weapon or stand-in

		mInspectWpn = null;
		clearCompare();
		if (!mOpen) clearSheet();
	}

	// The inspect sheet rides the pointing hand, at the same tilt and facing
	// the ring's own sheet uses. Positioned every tic so it tracks the hand
	// rather than hanging where the pickup happened to be first seen.
	private void layoutInspect(PlayerPawn pmo)
	{
		if (mSheetPlate == 0) return;

		double viewYaw = pmo.angle;
		Vector3 viewRight = (cos(viewYaw - 90), sin(viewYaw - 90), 0);
		Vector3 wrist = handPos(pmo, mInspectHand);

		double panelW = panelWNow();
		double panelH = panelHNow();

		layoutSheet(wrist, viewYaw, viewRight, PANEL_TILT,
		            cv("wr_rise", 2.0), 0.0, panelW, panelH, 0.0);
	}

	// NOT private: the star chart and the honeycomb point with the same ray
	// the ring does. Duplicating this would be duplicating the definition of
	// where a player's hand is, and the two copies would drift.
	// RSQ: the first actor a hand's ray reaches, within 512 units -- what REMA's engine tracked
	// for every hand as LaserTraceTargetMain/Off.
	private static Actor laserTarget(PlayerPawn pmo, int hand)
	{
		Vector3 org = handPos(pmo, hand), dir = handDir(pmo, hand);
		FLineTraceData t;
		pmo.LineTrace(atan2(dir.y, dir.x), 512, -asin(clamp(dir.z, -1.0, 1.0)), TRF_ABSPOSITION | TRF_ALLACTORS,
			org.z, org.x, org.y, t);
		if (t.HitType != TRACE_HitActor || t.HitActor == pmo) return null;
		return t.HitActor;
	}

	// RSQ: A HAND OFFSET IN TRUE PROPORTIONS. The engine divides a hand's height above or below
	// the eye by level.pixelstretch (hw_openxrdevice.cpp:597, :610; gl_openvr.cpp:1287-1289), so
	// the Z of a hand delta in map units reads 1/1.2 of its real size. A test written in real
	// centimetres or metres a second (the wrist-card pose, the pull and throw speeds) puts the Z
	// back first. Positions on the ring stay in map units: they and the cards share one space.
	static Vector3 trueDelta(Vector3 d) { return (d.x, d.y, d.z * level.pixelstretch); }

	static Vector3 handPos(PlayerPawn pmo, int hand)
	{
		if (pmo.OverrideAttackPosDir)
		{
			return (hand == 1) ? pmo.OffhandPos : pmo.AttackPos;
		}

		double yaw  = pmo.angle;
		double side = (hand == 1) ? -1.0 : 1.0;

		Vector3 head = pmo.Pos + (0, 0, pmo.player.viewheight);
		Vector3 fwd  = (cos(yaw), sin(yaw), 0);
		Vector3 rt   = (cos(yaw - 90), sin(yaw - 90), 0);

		return head + fwd * 22.0 + rt * (side * 11.0) - (0, 0, 8.0);
	}

	// The engine's own convention: a hand's facing is its angle plus ninety
	// degrees, not the angle itself.
	private static double handAngle(PlayerPawn pmo, int hand)
	{
		if (!pmo.OverrideAttackPosDir) return pmo.angle;

		return ((hand == 1) ? pmo.OffhandAngle : pmo.AttackAngle) + 90;
	}

	// The direction a hand points, as a unit vector.
	//
	// The Z SIGN is the trap, and the engine's own wheel gets it wrong: it feeds
	// raw OffhandPitch into an AngleToVector whose Z is -sin(pitch), while the
	// stored convention is up-POSITIVE (hw_vrmodes.cpp negates on the way in).
	// The correct consumer is hw_weapon.cpp, which negates again and so ends up
	// with +sin. Copy that, not the wheel.
	//
	// Without tracking, point where the player looks -- pmo.pitch is down-
	// positive, hence the negation. That is also what makes this testable at a
	// desk, which the old "return 0" never was.
	private static double, double handAim(PlayerPawn pmo, int hand)
	{
		if (pmo.OverrideAttackPosDir)
		{
			return ((hand == 1) ? pmo.OffhandAngle : pmo.AttackAngle) + 90,
			       (hand == 1) ? pmo.OffhandPitch : pmo.AttackPitch;
		}
		return pmo.angle, -pmo.pitch;
	}

	static Vector3 handDir(PlayerPawn pmo, int hand)
	{
		double y, p;

		if (pmo.OverrideAttackPosDir)
		{
			y = ((hand == 1) ? pmo.OffhandAngle : pmo.AttackAngle) + 90;
			p = (hand == 1) ? pmo.OffhandPitch : pmo.AttackPitch;
		}
		else
		{
			y = pmo.angle;
			p = -pmo.pitch;
		}

		double cp = cos(p);
		return (cp * cos(y), cp * sin(y), sin(p));
	}

	private static double handPitchOf(PlayerPawn pmo, int hand)
	{
		if (!pmo.OverrideAttackPosDir) return 0;

		return (hand == 1) ? pmo.OffhandPitch : pmo.AttackPitch;
	}

	private static double handRollOf(PlayerPawn pmo, int hand)
	{
		if (!pmo.OverrideAttackPosDir) return 0;

		// MainHandRoll, not AttackRoll: P_PlayerThink zeroes AttackRoll every
		// tic before WorldTick runs, so wr_roll never turned the main-hand ring.
		return (hand == 1) ? pmo.OffhandRoll : pmo.AttackRoll;   // RSQ: QZD writes AttackRoll per frame (hw_openxrdevice.cpp)
	}

	//==========================================================================
	// Reaching in
	//==========================================================================

	override void WorldTick()
	{

		if (mWantAutoOpen)
		{
			let p = players[consoleplayer];
			if (p.mo != null && p.playerstate == PST_LIVE)
			{
				mWantAutoOpen = false;
				openRig(1);
			}
		}

		// The fold-away outlives the rig being open, so it is ticked down before
		// the early-out rather than after it.
		//
		// TICKED DOWN HERE, but until now never actually APPLIED here. The
		// roll itself was only ever computed and RollBillboard'd inside
		// layout()/layoutExpansion()'s per-card loops -- both gated on
		// mOpen, which commit() has already set false by the time either
		// could run again (closeRig(true), called synchronously right
		// after mFlipCard/mFlipTics are armed, takes the deferred branch
		// and clears mOpen before returning). So the countdown counted
		// down correctly the whole time; the spin it was supposed to
		// drive just never got a single frame to draw. wr_flip has had a
		// working menu slider for a mechanic that could not render.
		//
		// Applied directly here instead of trying to keep layout() alive
		// past mOpen -- that function does a full per-card pass for a
		// ring that is otherwise finished, for the sake of one already-
		// identified card. Same easing curve layout() itself uses.
		if (mFlipTics > 0)
		{
			--mFlipTics;
			double ft = 1.0 - (double(mFlipTics) / CLOSE_TICS);
			double flipRoll = (1.0 - (1.0 - ft) * (1.0 - ft)) * cv("wr_flip", 360.0);
			if (mFlipCard >= 0 && mFlipCard < mIds.Size())
			{
				// mIds are the alpha-0 hit quads. Rolling one of those is
				// invisible; the visible members are the plate and what
				// sits on it. (Sub-cards roll mSubIds, which ARE the plates.)
				int c = mFlipCard;
				if (c < mPlates.Size())               wr_BB.RollBillboard(mPlates[c],  flipRoll);
				if (c < mFaces.Size()   && mFaces[c])   wr_BB.RollBillboard(mFaces[c],   flipRoll);
				if (c < mIcons.Size()   && mIcons[c])   wr_BB.RollBillboard(mIcons[c],   flipRoll);
				if (c < mLabels.Size()  && mLabels[c])  wr_BB.RollBillboard(mLabels[c],  flipRoll);
				if (c < mAccents.Size() && mAccents[c]) wr_BB.RollBillboard(mAccents[c], flipRoll);
				if (c < mAmmos.Size()   && mAmmos[c])   wr_BB.RollBillboard(mAmmos[c],   flipRoll);
				if (c < mGauges.Size()  && mGauges[c])  wr_BB.RollBillboard(mGauges[c],  flipRoll);
			}
			else if (mSubFlipCard >= 0 && mSubFlipCard < mSubIds.Size())
				wr_BB.RollBillboard(mSubIds[mSubFlipCard], flipRoll);
		}
		if (mClosingTics > 0 && --mClosingTics <= 0) destroyPanels();

		tickInspect();

		if (!mOpen) return;

		let pmo = players[consoleplayer].mo;
		if (pmo == null || players[consoleplayer].playerstate != PST_LIVE)
		{
			// Dying is not a moment for an animation. Take it down now.
			mHardClose = true;
			closeRig();
			mHardClose = false;
			return;
		}

		// The lock expires. A rig that stays up until you deal with it is a modal
		// dialog in a firefight; one that quietly folds away if you did not mean
		// to open it costs nothing. Hovering resets it, because a hand on a card
		// is someone who is still deciding.
		//
		// ONE haptic tick, the instant the countdown crosses into its own
		// warning window -- not a warning if a player never feels it
		// start, so this fires once rather than buzzing continuously.
		// layout()'s own warnFrac (below) does the visual half, fading
		// the whole ring over the same window; this is the felt half.
		//
		// mWarnedThisOpen, not exact equality against warnTics -- both
		// wr_locktics and wr_warn_tics are live menu sliders, and if
		// wr_locktics is ever tuned to start AT OR BELOW wr_warn_tics,
		// a countdown that only steps down could never pass through
		// exact equality with it, so the haptic would silently never
		// fire while the visual half (a `<` comparison, not `==`) ran
		// for the ring's entire lifetime. The guard flag instead fires
		// on the first tic mLockTics is inside the window, however it
		// got there -- including immediately, if the ring opens already
		// inside it -- and resets everywhere mLockTics itself resets.
		//
		// Haptic only, no sound -- there is no dedicated cue for this in
		// sndinfo.txt, and this is a tactile nudge on the hand already
		// wearing the rig, not an audible event, the same reasoning
		// feedback() itself uses to gate its own haptic half on wr_haptics
		// separately from wr_sound.
		int warnTics = int(cv("wr_warn_tics", 25.0));
		if (!mWarnedThisOpen && warnTics > 0 && mLockTics <= warnTics)
		{
			mWarnedThisOpen = true;
			double warnGain = cv("wr_haptics", 1.0);
			if (warnGain > 0.0) wr_VR.VRHaptic(mPokeHand, 0.3 * warnGain, 40);
		}

		if (--mLockTics <= 0)
		{
			closeRig();
			return;
		}

		++mOpenTics;
		// The constellation seam clock. It used to tick only inside
		// updateHover's same-card branch, so moving the pointer off the
		// parent card toward a star froze the lines half-drawn.
		if (mExpanded >= 0) ++mFanTics;

		// Before layout, so the artwork is queued for the same frame the cards
		// are placed in.
		if (mRebuildTics > 0 && --mRebuildTics == 0) rebuildPage(pmo);   // see commitModel
		repaintFaces(pmo);

		// Same reason, and the same frame: rows rebuilt here are positioned by
		// layoutSheet below rather than sitting at the origin for a tic.
		refreshSheet(pmo);

		// RE-ASSERT THE FIST, EVERY TIC.
		//
		// This is not belt and braces. A_WeaponReady runs in the weapon's Ready
		// state every single tic and writes the psprite's sprite and frame back
		// to the real gun, so a swap applied once at open survives for exactly
		// one tic and is then gone. It has to happen HERE, after the playsim has
		// ticked the psprite, which is what WorldTick is -- doing it any earlier
		// just gets overwritten again.
		//
		// The design said so from the start and the call was never wired in,
		// which is why the hand has never once been visible.

		layout(pmo);

		// CURSOR GAIN.
		//
		// The cards sit at a real distance in the world, so reaching them meant
		// physically moving your arm that far -- fine once, exhausting to browse
		// with. Multiplying displacement from where the rig opened means a few
		// inches of hand covers the whole ring, while the cards stay at a size
		// and distance that is comfortable to READ.
		//
		// Measured from the anchor rather than from last tic, so it never drifts:
		// bring your hand back where it started and the cursor is back in the
		// centre, exactly.
		// POINTING, not reaching.
		//
		// Touch made you carry your hand to every card, which is why browsing the
		// ring felt like a mile of arm. A ray costs a wrist rotation instead, and
		// it is the only query of the three that is geometrically sound anyway:
		// AimBillboard resolves its basis at the ray origin but tests the
		// intersection point, so its bounds check is live code. TouchBillboard
		// tests the same vector its basis came from, and on a turning card that
		// term is algebraically zero.
		// One to one, both position and aim.
		//
		// There was hand acceleration here and it is gone. It existed because the
		// ring used to be wrapped around the hand, where reaching a card was a
		// genuine arm move -- once the ring sits a metre out in front, the beam
		// leaves along the barrel and a normal wrist movement already crosses it.
		// Amplifying on top of that only breaks the one thing that makes a laser
		// legible: that it goes where the gun is pointing.
		// RSQ: EITHER HAND POINTS. The hand that has the beam keeps it while it is on a card
		// (or touching one); when it is not, the other hand takes over the moment IT is. So
		// two hands never fight over a card, and moving one hand onto the ring is all it takes.
		if (eitherHand())
		{
			int other = (mPokeHand == 1) ? 0 : 1;
			double tr = cv("wr_touch", 7.0) * cv("wr_scale", 1.0);
			if (!handOnRing(pmo, mPokeHand, tr) && handOnRing(pmo, other, tr))
			{
				mPokeHand = other;
				engineLaser(true);
			}
		}

		Vector3 org = handPos(pmo, mPokeHand);

		// Aim is one-to-one. There was an angular gain here and it is gone: it
		// multiplied hand tremor exactly as much as intent, which is what made
		// the beam unusable, and once the ring moved out in front of the hand and
		// reach was amplified it was solving a problem that no longer existed.
		Vector3 dir = handDir(pmo, mPokeHand);

		int rayHit;
		Vector2 uv;
		// Finite range on purpose: unlimited means the ray leaves the room and
		// can find another mod's billboard through a wall.
		[rayHit, uv] = wr_BB.AimBillboard(org, dir, POINTER_RANGE);

		// KEPT SEPARATELY from the selection below, and that separation is the
		// whole fix. What the RAY hit and what is SELECTED are different
		// questions once the stick and the hand can also answer -- see the beam
		// clamp at the end of this function.
		int hit = rayHit;

		// STICK SELECTION, for anyone who would rather not aim.
		//
		// The ring has fixed bearings, so a stick direction maps straight to a
		// slot: push toward the one you want. No precision, no steadiness, works
		// while you are being shot at. It overrides the ray whenever the stick
		// is actually deflected, and gets out of the way when it is not.
		int stickHit = stickPick(pmo);
		if (stickHit != 0) hit = stickHit;

		// TOUCH WINS OVER BEAM.
		//
		// Two ways in, and they are not rivals: the beam is for reaching a card
		// across the ring, the hand is for the one you are already at. When both
		// answer, the hand is the more deliberate act -- you had to put it there
		// -- so it takes precedence over wherever the beam happened to be
		// pointing past it.
		//
		// THE FINGERTIP IS NOT THE CONTROLLER, and until this was written that
		// was the whole bug (audit finding #20): the query ran from the raw hand
		// position against a 7-unit sphere, while the ring hangs at wr_forward
		// -- 34 units, about a metre -- ahead of where that hand was when it
		// opened. Closing 28 units is not a reach, it is a lunge past arm's
		// extension, so mTouching was never true in open space. Every promise
		// this comment makes was dead: reaching never selected, "TOUCH WINS
		// OVER BEAM" never happened, and +use as the grab did nothing at all --
		// on a vanilla-sized loadout the key fell through every branch of
		// InputProcess and leaked out to open the door behind you.
		//
		// So the point that does the touching is carried out in front of the
		// hand, along the hand's own axis, by mTouchReach -- which was frozen
		// with the anchor to sit just short of the cards. The remaining gap is
		// small and REAL: you close it by physically pushing your hand forward,
		// which is what reaching into something is. Holding your arm where it
		// was still touches nothing.
		//
		// It stays a POSITION test rather than becoming a second beam. You do
		// not aim at the card, you have to be at it -- the sphere finds
		// whatever it is inside of, nearest first, and a hand held out beside
		// the ring finds nothing however well it is pointed.
		//
		// wr_touch 0 turns reaching off outright and leaves the beam as the only
		// way in. Skipped rather than called with a zero radius, because "no
		// radius" and "do not ask" are different things and only one of them is
		// free.
		double touchR = cv("wr_touch", 7.0) * cv("wr_scale", 1.0);
		mTouching = false;

		if (touchR > 0.0)
		{
			Vector3 tip = org + dir * mTouchReach;

			int touched;
			Vector2 tuv;
			double tdist;
			[touched, tuv, tdist] = wr_BB.TouchBillboard(tip, touchR);

			mTouching = (touched != 0);
			if (mTouching) hit = touched;
		}

		updateHover(hit);
		tickTwoHand(pmo);   // RSQ: a card under each hand -> the two side by side
		if (!mOpen) return;
		tickPhysical(pmo);  // RSQ: pull a card out of the ring, throw a gun back into it
		if (!mOpen) return;

		// The beam, and the dot where it lands.
		//
		// Without them you are aiming something invisible: the ray leaves your
		// hand at an angle you cannot see, and the first feedback would be a card
		// lighting up somewhere you were not looking.
		//
		// MEASURED AGAINST rayHit, NOT against what won the selection. This used
		// to pass `hit`, and distanceToHit works by walking the ray until it
		// stops finding that exact card -- so handed a card the stick or the
		// hand chose, one that the ray never crossed, the search matched nothing,
		// the interval never closed and it returned POINTER_RANGE. A stick push
		// or a reach therefore fired the laser out to its full 200 units into the
		// room, at the exact moment a card off to one side lit up. The beam is
		// physical: it stops where it actually meets something, and it is allowed
		// to meet nothing while another input does the choosing.
		double reach;
		if (rayHit != 0)
		{
			// Stop the beam at the card it found, so it reads as touching rather
			// than passing through.
			reach = distanceToHit(org, dir, rayHit);
		}
		else
		{
			// AS FAR AS THE RING IS, not as far as the ring is WIDE.
			//
			// wr_radius is the orbit radius, not the distance from the hand, and
			// 5 * 1.6 = 8 was "just past the ring" back when the ring was centred
			// on the wrist at radius 5. The ring now hangs at wr_forward -- 34 units
			// -- so between two cards the dusty beam collapsed to a stub near your
			// hand, a quarter of the way there, while the engine's own thin laser
			// carried on to the wall. Two pointers disagreeing about where you are
			// aiming, on every card-to-card crossing, and no beam reaching the ring
			// at exactly the moment you need to see where the pointer is.
			//
			// Measured from the standoff the ring is actually placed at, plus a
			// little so the miss case reads as slightly past the cards rather than
			// stopping short of them. Audit finding #22.
			reach = (cv("wr_forward", 34.0) + cv("wr_radius", 5.0) * cv("wr_scale", 1.0)) * 1.15;
		}

		// Only the dot is ours now; the beam is the engine laser.
		// Tell the engine laser where to stop. Its own trace cannot see a
		// billboard, so without this the beam goes through the card and lands on
		// the wall behind -- which reads as the laser ignoring the thing it is
		// selecting. Republished every tic; a stale value would clamp the
		// player's laser forever.
		wr_VR.SetVRLaserRange(rayHit != 0 ? reach : 0);

		decor(pmo, org, dir, reach, hit != 0);
		cardLight(pmo);


		// Committing is driven from InputProcess instead, so the fire press can
		// be swallowed before it reaches the weapon. Reading cmd.buttons here
		// would see the press but not be able to stop the shot.
	}

	// How far along the ray the hit card sits.
	//
	// AimBillboard reports which card and where on its face, but not the range,
	// so this walks the same ray until it stops finding that card. Coarse on
	// purpose -- the beam only has to END at the card, not to the millimetre.
	private double distanceToHit(Vector3 org, Vector3 dir, int wanted) const
	{
		double lo = 0.0, hi = POINTER_RANGE;

		for (int i = 0; i < 12; ++i)
		{
			double mid = (lo + hi) * 0.5;
			int probe;
			Vector2 puv;
			[probe, puv] = wr_BB.AimBillboard(org, dir, mid);

			if (probe == wanted) hi = mid;
			else                 lo = mid;
		}
		return hi;
	}

	// A thin quad lying along the ray, plus a dot on the end.
	//
	// A billboard is a quad with a yaw and a tilt, which is exactly enough to
	// lie one down along a direction: width becomes length, height becomes
	// thickness, and the centre goes at the midpoint.
	// The ENGINE's laser, not one made of billboards.
	//
	// It already draws a proper per-hand beam with glow, width, alpha, taper and
	// colour, all cvar-driven and all tuned by whoever set those defaults. The
	// version built here out of fourteen slivers was strictly worse than the one
	// sitting in the renderer.
	//
	// vr_laser_hide_on_wheel only hides it for the ENGINE's wheel -- it tests
	// VRWheel_ShouldSuppressHandInput, which this mod never sets -- so ours is
	// left alone.
	//
	// The previous value is saved rather than assumed off: plenty of people play
	// with a laser sight on permanently, and switching it off for them when the
	// wheel closed would be its own bug.
	private void engineLaser(bool on)
	{
		// An engine override, not a cvar write. The VM refuses writes to archived
		// cvars outside menu code -- correctly -- and this wants the laser for four
		// seconds, not a change to what the player has saved.
		//
		// Named to the rig hand, so the hand still holding a gun is not given a
		// second beam clamped to the ring's distance. Naming the hand is also what
		// gets a cursor onto an EMPTY off hand at all: the engine skips the laser
		// for a hand with no weapon in it unless a script has claimed that hand.
		// RSQ: on the POINTING hand; with either hand picking, the other hand shows a dimmer
		// beam so it is plain that it can point too.
		wr_VR.ForceVRLaser(on, on ? mPokeHand : -1, on && eitherHand());
		if (!on) wr_VR.SetVRLaserRange(0);
	}

	// RSQ: TWO HANDS, TWO CARDS. With either hand picking, the beam belongs to one hand; when the
	// other hand's beam rests on a different gun's card, the sheet gives way to REMA's comparison
	// card -- the picking hand's gun against the other one, line by line, better values marked --
	// for as long as both stay put. wr_twohand_compare 0 turns it off.
	bool          mTwoCmp;
	Class<Weapon> mTwoA, mTwoB;
	int           mTwoBuilt;

	private void tickTwoHand(PlayerPawn pmo)
	{
		Weapon a, b;
		if (eitherHand() && cvBool("wr_twohand_compare", true) && mPage == PAGE_WEAPONS && mHovered != 0)
		{
			int other = (mPokeHand == 1) ? 0 : 1;
			int oid; Vector2 ouv;
			[oid, ouv] = wr_BB.AimBillboard(handPos(pmo, other), handDir(pmo, other), POINTER_RANGE);
			if (oid != 0 && oid != mHovered && oid != mSheetHit)
			{
				Class<Weapon> ca = HoveredClass();
				int keep = mHovered; mHovered = oid;
				Class<Weapon> cb = HoveredClass();
				mHovered = keep;
				if (ca && cb && ca != cb) { a = Weapon(pmo.FindInventory(ca)); b = Weapon(pmo.FindInventory(cb)); }
			}
		}
		if (!a || !b)
		{
			if (mTwoCmp)
			{
				mTwoCmp = false;
				clearCompare();
				if (mSheetPlate == 0) { buildSheet(); mSheetValid = false; }
			}
			return;
		}
		bool due = level.maptime - mTwoBuilt >= SHEET_TICK;
		if (!mTwoCmp || a.GetClass() != mTwoA || b.GetClass() != mTwoB || due)
		{
			if (!mTwoCmp)
			{
				clearSheet();
				feedback(Sound("wristrig/tick"), 0.25, 30);
				if (cvBool("wr_debug", false)) Console.Printf("RSQ Wheel: comparing %s with %s (tic %d)", a.GetClassName(), b.GetClassName(), level.maptime);
			}
			mTwoCmp = true; mTwoA = a.GetClass(); mTwoB = b.GetClass(); mTwoBuilt = level.maptime;
			if (mCmpPlate == 0) buildCompare();
			fillCompare(a, b);
		}
		layoutCompare(pmo, true);
	}

	// RSQ: CARDS ARE THINGS. Two gestures with the ring up, both by hand speed:
	//   PULL A CARD OUT -- with a hand in a weapon card, snap the hand back toward you and the gun
	//     comes with it, into that hand (wr_pull_speed).
	//   THROW A GUN BACK -- snap the hand holding a gun toward the ring, not at a card, and the gun
	//     files itself away: that hand goes back to its empty-hand weapon (slot 1 -- fists, or the
	//     off hand's own fist in a VR set) and the gun's card bursts (wr_throw_speed).
	// Speeds are map units per tic along the hand's travel toward or away from the ring's centre
	// (34 units a metre: 1.5 is about 1.5 m/s). 0 turns either off.
	Vector3 mPrevHand[2];
	bool    mHavePrev[2];
	int     mInCard[2];       // the weapon card a hand was in, kept a few tics after it leaves
	int     mInCardTics[2];
	int     mGestureCool;

	private void tickPhysical(PlayerPawn pmo)
	{
		if (mPage != PAGE_WEAPONS || !mHaveAnchor) return;
		if (mGestureCool > 0) mGestureCool--;
		double touchR = cv("wr_touch", 7.0) * cv("wr_scale", 1.0);
		for (int h = 0; h < 2; h++)
		{
			Vector3 hp = handPos(pmo, h);
			// true proportions (trueDelta): a speed in metres a second means the same whether the
			// snap is level or up and down
			Vector3 v = mHavePrev[h] ? trueDelta(hp - mPrevHand[h]) : (0, 0, 0);
			mPrevHand[h] = hp; mHavePrev[h] = true;

			// which weapon card this hand is in (the touch test, from its fingertip)
			int id; Vector2 uv; double td;
			[id, uv, td] = wr_BB.TouchBillboard(hp + handDir(pmo, h) * mTouchReach, touchR);
			if (id != 0 && id != mSheetHit) { mInCard[h] = id; mInCardTics[h] = 6; }
			else if (mInCardTics[h] > 0 && --mInCardTics[h] == 0) mInCard[h] = 0;

			if (mGestureCool > 0) continue;
			Vector3 toRing = trueDelta(mAnchor - hp);
			double dist = toRing.Length();
			if (dist < 1) continue;
			double toward = v dot (toRing / dist);
			// a hand cannot move 12 units (35 cm) in one tic: that is tracking lost and found, or
			// the view jumping, and it must not read as a pull or a throw
			if (v.Length() > 12.0) continue;
			if (cvBool("wr_debug", false) && (abs(toward) > 0.5 || level.maptime % 10 == 0))
				Console.Printf("RSQ Wheel hand %d: in card %d (touch %d, %.1f), toward ring %.2f u/tic, ring %.0f away, reach %.0f",
					h, mInCard[h], id, td, toward, dist, mTouchReach);

			double pull = cv("wr_pull_speed", 1.5);
			if (pull > 0 && mInCard[h] != 0 && -toward > pull)
			{
				int keep = mHovered;
				mHovered = mInCard[h];
				Class<Weapon> want = HoveredClass();
				if (want)
				{
					mPokeHand = h;
					commit(pmo);
					mGestureCool = 12;
					return;
				}
				mHovered = keep;
			}

			double thr = cv("wr_throw_speed", 2.6);
			// not while reaching for a card: a hand on its way to one points at it, so a throw
			// is a snap toward the ring with the hand's beam on no card at all
			int aimed = 0;
			if (thr > 0 && mInCard[h] == 0 && toward > thr && id == 0)
				[aimed, uv] = wr_BB.AimBillboard(hp, handDir(pmo, h), POINTER_RANGE);
			if (thr > 0 && mInCard[h] == 0 && toward > thr && id == 0 && aimed == 0)
			{
				if (fileAway(pmo, h)) { mGestureCool = 12; return; }
			}
		}
	}

	// The gun in that hand goes back on the ring; the hand takes its empty-hand weapon.
	private bool fileAway(PlayerPawn pmo, int h)
	{
		Weapon held = (h == 1) ? pmo.player.OffhandWeapon : pmo.player.ReadyWeapon;
		if (!held) return false;
		if (h == 1 && offhandBraced(pmo)) return false;   // a braced off hand takes nothing (offhandBraced)
		Weapon bare = null;
		// the off hand's own fist in a VR weapon set (BD22 VR-Reloaded's RSQ_Hands) first
		if (h == 1)
		{
			String fcn = "RSQ_Hands";        // a run-time lookup: null when that set is not loaded
			class<Inventory> fc = fcn;
			if (fc) bare = Weapon(pmo.FindInventory(fc));
		}
		if (!bare)
		{
			Array<Class<Weapon> > ones;
			slotWeapons(pmo, 1, ones);
			for (int i = 0; i < ones.Size() && !bare; i++)
			{
				let w = Weapon(pmo.FindInventory(ones[i]));
				if (!w || w == held) continue;
				if (w.bNoHandSwitch && w.bOffhandWeapon != (h == 1)) continue;
				bare = w;
			}
		}
		if (!bare || bare == held) return false;
		// the burst on the gun's own card, so you see where it went
		for (int i = 0; i < mTypes.Size() && i < mCardColor.Size(); i++)
		{
			if (mTypes[i] && held is mTypes[i])
			{
				sparks(cardPos(i), sparkColor(mCardColor[i]), 0.8);
				break;
			}
		}
		mPrevWeap[h] = held; mLastPickHand = h;   // a double tap brings it back
		equipInstantly(pmo, bare, h);
		feedback(Sound("wristrig/lock"), 0.6, 70);
		return true;
	}

	// RSQ: is this hand's beam on a card, or its fingertip in one?
	private bool handOnRing(PlayerPawn pmo, int hand, double touchR)
	{
		Vector3 o = handPos(pmo, hand), d = handDir(pmo, hand);
		int h; Vector2 uv;
		[h, uv] = wr_BB.AimBillboard(o, d, POINTER_RANGE);
		if (h != 0) return true;
		if (touchR <= 0.0) return false;
		double td;
		[h, uv, td] = wr_BB.TouchBillboard(o + d * mTouchReach, touchR);
		return h != 0;
	}

	// Sound and haptics together, because they are one event.
	//
	// A menu you can only SEE is a menu you have to look at, and in VR looking at
	// your wrist is looking away from the thing shooting you. A tick in the
	// controller and a click in the ear both say "that registered" without
	// costing you the room.
	//
	// The rig has its own sounds rather than borrowing the engine's menu aliases.
	// menu/cursor and menu/choose are the flat beeps of whichever game is loaded
	// and they say "pause menu", which is the one thing this is not. See
	// sndinfo.txt.
	//
	// CHANF_UI keeps them out of the world: no falloff, no occlusion, and not a
	// noise in the level that a monster could be thought to have made.
	//
	// Haptics go to the POKE hand, which is the hand that did the thing. Buzzing
	// the hand wearing the cards when the other one selected would be feedback
	// arriving at the wrong wrist.
	// Takes a Sound, not a string. The conversion from a string LITERAL to a
	// Sound is done by the compiler; handing S_StartSound a runtime string
	// variable is a different question with a worse answer, and every call site
	// here knows its sound at compile time anyway.
	private void feedback(Sound snd, double amp, double ms)
	{
		if (cv("wr_sound", 1.0) > 0.0)
		{
			S_StartSound(snd, CHAN_VOICE, CHANF_UI, cv("wr_volume", 0.65), ATTN_NONE);
		}

		double gain = cv("wr_haptics", 1.0);
		if (amp > 0.0 && gain > 0.0)
		{
			// vr_enable_haptics is still checked engine-side, so someone who has
			// turned haptics off globally is not overridden by a mod cvar.
			wr_VR.VRHaptic(mPokeHand, amp * gain, ms);
		}
	}

	// The slot colour of whatever is under the pointer, or the ring's own idle
	// colour when nothing is.
	private color hoverColor() const
	{
		int card = cardIndexOf(mHovered);
		if (card >= 0 && card < mCardColor.Size()) return mCardColor[card];

		// A fan card is still a card the beam is on. Without this the laser,
		// the dust in it, the sweep and the fog all snapped back to idle blue
		// the instant the pointer crossed from the ring into a fan -- the one
		// place the room's colour is doing the most work, because a fan is
		// where several near-identical weapons are being told apart.
		int sub = subIndexOf(mHovered);
		if (sub >= 0 && sub < mSubColor.Size()) return mSubColor[sub];

		return COLOR_BEAM_IDLE;
	}

	// THE ROOM REACTS.
	//
	// Everything above this line dresses the CARDS. This dresses the space they
	// are in, which is where the remaining difference was: a ring that lights
	// the wall behind it reads as an object in the room, and a ring that does
	// not reads as a picture pasted over one.
	//
	// All three are SINGLE GLOBAL SLOTS with no getters, so this cannot read
	// what a co-loaded mod put there and politely put it back. What makes that
	// survivable is the engine's own contract for them -- "publish it each tic
	// while the light is on" -- so anything else using them is re-publishing
	// every tic too and recovers by itself the moment the rig lets go. It is
	// still someone else's slot, so every one of these is behind its own cvar.
	private void decor(PlayerPawn pmo, Vector3 org, Vector3 dir, double reach, bool onCard)
	{
		color tint = hoverColor();

		// The same arrival curve the cards ride, so the room and the ring agree
		// about when the rig has finished opening.
		double grow = growFactor();

		// THE ROOM'S OWN LIGHT RIPPLES.
		//
		// This one does not create light -- it modulates the glows a map
		// already has, per pixel, with separate phases for wall top, wall
		// bottom, floor and ceiling so a wave can climb a room rather than
		// pulsing it uniformly. Anchored at the ring, so the level appears to
		// react to the rig being open.
		//
		// Worth knowing before turning it on: in a map with NO glowing surfaces
		// it does exactly nothing. Its whole effect is a function of the level
		// you happen to be standing in, which is why it is off by default and
		// not a bug when it seems dead.
		double wave = cv("wr_wave", 0.0);
		if (wave > 0.0)
		{
			wr_FX.SetGlowWaveOrigin(mAnchor);
			wr_FX.SetGlowWave(cv("wr_wave_len", 120.0),
			                  cv("wr_wave_speed", 1.6),
			                  cv("wr_wave_sharp", 1.4), 1);
			wr_FX.SetGlowWaveDepth(wave, wave * 0.8, wave * 0.5, 0.15, 3.0);

			// Offset per channel so the wave CLIMBS instead of flashing the
			// whole room at once -- which is the entire difference between this
			// and a screen-wide brightness pulse.
			wr_FX.SetGlowWavePhase(0.0, 0.35, 0.7, 1.05);
			mWaveHeld = true;
		}
		else if (mWaveHeld)
		{
			wr_FX.SetGlowWave(0.0, 0.0, 0.0, 0);   // wavelength 0 = off
			mWaveHeld = false;
		}

		// THE LASER GETS AIR IN IT.
		//
		// The engine laser is still the pointer -- it does the hit maths and
		// terminates on the card. This is a raymarched cone laid along the same
		// ray, so the beam has dust drifting through it instead of being a line
		// with nothing between it and the wall.
		if (cv("wr_vbeam", 1.0) > 0.0)
		{
			// inner is the hot core, outer where it has faded to nothing;
			// falloff above 1 concentrates the light near the lens, which is
			// what stops a long beam looking like a strip light.
			wr_FX.SetVolumetricBeam(org, dir, tint,
				cv("wr_vbeam_inner", 1.2),
				cv("wr_vbeam_outer", 5.0),
				reach,
				cv("wr_vbeam_density", 0.55) * (onCard ? 1.35 : 1.0),
				2.2,
				cv("wr_vbeam_dust", 0.5), 0.035, 0.4, VOLBEAM_SLOT);
			mBeamHeld = true;
		}
		else if (mBeamHeld)
		{
			// Switched off with the rig still open. Every cvar here is live, so
			// each of these needs its own way back out.
			wr_FX.ClearVolumetricBeam(VOLBEAM_SLOT);
			mBeamHeld = false;
		}

		// A RING OF LIGHT WASHES THE ROOM WHEN IT OPENS.
		//
		// Mode 1 is a cylinder from the origin, tested per pixel against world
		// position on every surface -- so it crosses floor, wall and ceiling as
		// one unbroken line rather than lighting sectors. Nothing per-sector can
		// do that, and it is the reason this reads as the rig emitting rather
		// than as a screen effect.
		//
		// It runs once, on open, and gets out of the way.
		double sweepTics = cv("wr_sweep", 14.0);
		if (sweepTics > 0.0)
		{
			if (mOpenTics <= sweepTics)
			{
				double t = mOpenTics / sweepTics;

				wr_FX.SetSweepOrigin(1, pmo.Pos + (0, 0, pmo.height * 0.5), 1);
				wr_FX.SetSweepBand(0,
					t * cv("wr_sweep_reach", 340.0),   // radius, outward
					18.0 + t * 40.0,                   // thickness, spreading
					0.55,
					tint,
					(1.0 - t) * (1.0 - t) * cv("wr_sweep_bright", 1.4));
				mSweepHeld = true;
			}
			else if (mSweepHeld)
			{
				// Let go the tic after it finishes rather than holding a dead
				// band at zero intensity for as long as the rig is up.
				wr_FX.ClearSweep();
				mSweepHeld = false;
			}
		}
		else if (mSweepHeld)
		{
			wr_FX.ClearSweep();
			mSweepHeld = false;
		}

		// A MARK ON THE FLOOR UNDER YOU.
		//
		// One shape slot, repeated radially. SetShapeRepeat FOLDS THE
		// COORDINATE rather than drawing N copies -- the engine's own note says
		// eight and eight hundred cost the same -- so a full ring of marks is
		// one shape's worth of work. It spins, and its seam splits each mark
		// down the middle as the rig arrives, which is what ties the floor to
		// the cards instead of just decorating under them.
		double floorSize = cv("wr_floor", 0.0);
		if (floorSize > 0.0)
		{
			if (mShapeSlot < 0)
			{
				mShapeSlot = wr_FX.AddShape(
					int(cv("wr_floor_kind", 5.0)),   // 5 = cross
					0,                                // floors only
					pmo.Pos.X, pmo.Pos.Y, pmo.floorz,
					floorSize, 0.0, cv("wr_floor_thick", 0.18),
					tint, cv("wr_floor_bright", 1.2), 0.0);
			}

			if (mShapeSlot >= 0)
			{
				wr_FX.MoveShape(mShapeSlot, pmo.Pos.X, pmo.Pos.Y, pmo.floorz);
				wr_FX.SetShapeRepeat(mShapeSlot, 1,
					cv("wr_floor_count", 8.0),
					cv("wr_floor_space", 46.0),
					cv("wr_floor_spin", 14.0));

				// Splits open as the ring does, then holds. seamRate 0 keeps
				// the caller owning the animation, same as everything else here.
				wr_FX.SetShapeMotion(mShapeSlot, grow * cv("wr_floor_seam", 0.5), 0.0, 0.0);
			}
		}
		else if (mShapeSlot >= 0)
		{
			wr_FX.RemoveShape(mShapeSlot);
			mShapeSlot = -1;
		}

		// MIST THE CARDS SIT IN, off by default.
		//
		// ON THE OVERRIDE SLAB (engine SetFogSlabOverride), not the standing one:
		// it draws over a map's or RS_Fog's fog while the rig is open and gives
		// theirs back untouched when cleared -- the standing slab used to be
		// taken outright and wiped on close. Still off by default.
		double fog = cv("wr_fog", 0.0);
		if (fog > 0.0)
		{
			wr_FX.SetFogSlabOverride(mAnchor.Z + cv("wr_fog_rise", 6.0), fog, 0.6,
			                 cv("wr_fog_scatter", 0.8), tint);
			mFogHeld = true;
		}
		else if (mFogHeld)
		{
			wr_FX.ClearFogSlabOverride();
			mFogHeld = false;
		}
	}

	// Hands back only what was actually TAKEN.
	//
	// The first version cleared all three unconditionally, which is wrong in a
	// specific and rude way: with wr_sweep off, the rig never touches the sweep
	// slot, and clearing it on close would delete a co-loaded mod's sweep that
	// this had nothing to do with. There is no getter to check with, so the
	// flags are the only record of what is ours.
	private void releaseDecor()
	{
		if (mBeamHeld)  { wr_FX.ClearVolumetricBeam(VOLBEAM_SLOT); mBeamHeld = false; }
		if (mSweepHeld) { wr_FX.ClearSweep();          mSweepHeld = false; }
		if (mFogHeld)   { wr_FX.ClearFogSlabOverride();        mFogHeld = false; }

		// RemoveShape, not ClearShapes: ours is one slot out of a shared pool
		// and clearing the pool would take everyone else's with it.
		if (mShapeSlot >= 0) { wr_FX.RemoveShape(mShapeSlot); mShapeSlot = -1; }
		if (mLight != null)  { mLight.Destroy(); mLight = null; }
		mLightGrace = 0;
		clearCardModels();
		if (mWaveHeld)  { wr_FX.SetGlowWave(0.0, 0.0, 0.0, 0); mWaveHeld = false; }
	}

	// Which payload the ammo bezel is drawn with.
	//
	//   0  BB_SEGMENT -- dark bed, glowing segments. An LED.
	//   1  BB_SEGLCD  -- lit plate with the characters punched out dark. An LCD.
	//   2  BB_WG13    -- GITD's lozenge badge, digits knocked out of the plate.
	//
	// Pick by which reads better against the room rather than by which is more
	// correct: LED wins in the dark, LCD wins against a bright wall.
	private static int readoutKind()
	{
		switch (int(cv("wr_readout", 0.0)))
		{
			case 1:  return wr_BB.BB_SEGLCD;
			case 2:  return wr_BB.BB_WG13;
			default: return wr_BB.BB_SEGMENT;
		}
	}

	// WG13 is DIGITS ONLY -- it takes its number in `data`, not as text -- and
	// it wants a lozenge, not a circle. The original's rule is halfH 46 with
	// halfW = halfH * (0.60 + digits * 0.42); this is that ratio, so a
	// three-digit count gets a wider badge than a one-digit one instead of both
	// being stretched into the same box.
	private static double readoutAspect(string text)
	{
		int chars = max(text.Length(), 1);

		if (readoutKind() == wr_BB.BB_WG13)
		{
			// DIGITS ONLY, and now actually counted that way.
			//
			// The comment below has always said the separator is not counted, and
			// nothing ever stripped it. BB_WG13 reads its number out of `data` and
			// never renders `text` at all, but the WIDTH came from the full string
			// -- so ammoText's "8|112" measured six characters and saturated the
			// 0.90 ceiling, giving a magazine weapon a badge nearly edge to edge
			// with one small digit floating in it, next to a card showing the same
			// count at 0.54. Audit finding #29.
			int digits = 0;
			for (int i = 0; i < int(text.Length()); ++i)
			{
				int c = text.ByteAt(i);
				if (c >= 48 && c <= 57) ++digits;
				else break;   // the badge shows the FIRST number only
			}
			if (digits < 1) digits = 1;
			chars = digits;

			// The lozenge's own rule, and it takes DIGITS -- a badge showing a
			// separator is not a case it has, so the separator is not counted.
			//
			// Capped for the same reason the segment branch below is: nothing
			// here bounded it against a long reserve count, and the plate's
			// corners are rounded, so a box sized to the FULL rectangle bleeds
			// past the actual visible edge before it ever reaches 100%. No
			// floor needed -- the formula's own minimum, at a single digit,
			// never comes close to this ceiling.
			return min(AMMO_H_FRAC * CARD_STRETCH * (0.60 + chars * 0.42) * 2.0, 0.90);
		}

		// The segment payload fits its glyphs to the quad, so a longer string
		// in a fixed box just gets thinner letters. Widening with the text keeps
		// "148|12" as legible as "24" instead of squeezing it.
		//
		// Ceiling is 0.90, not the box's own full width: the plate's corners
		// are rounded (wr_plate_radius), so a readout sized to the flat
		// rectangle's edge draws past the plate's actual visible surface --
		// this is what "glyphs extend off the card" turned out to be.
		return clamp(AMMO_W_FRAC * (0.55 + chars * 0.22), AMMO_W_FRAC, 0.90);
	}

	// Which hand, if any, already has this weapon.
	//
	//   0  nobody
	//   1  this hand -- taking it changes nothing
	//   2  the other hand -- taking it swaps, or finds a free clone
	//
	// Informational ONLY. The card stays fully selectable in both cases: the
	// whole point of the swap and the _2 lookup is that picking your other
	// hand's gun is a reasonable thing to ask for, and a marker that greyed it
	// out would be undoing that.
	private int heldWhere(Class<Weapon> type) const
	{
		if (type == null) return 0;

		let mine  = (mRigHand == 1) ? players[consoleplayer].OffhandWeapon
		                            : players[consoleplayer].ReadyWeapon;
		let other = otherHandWeapon();

		if (mine  != null && mine.GetClass()  == type) return 1;
		if (other != null && other.GetClass() == type) return 2;
		return 0;
	}

	// What colour the burst comes out.
	//
	//   0  the slot's colour -- the burst names what you just took
	//   1  white hot
	//   2  rainbow, cycling per particle
	//
	// Rainbow is not the default because the slot colour is doing a JOB: it is
	// the same hue as the card, the accent and the beam, so the burst confirms
	// which one you hit. Rainbow is prettier and says nothing. Both are worth
	// having and only one of them is information.
	// Takes the hue, not an index into one particular array. It used to take a
	// ring index, which a fan card cannot supply: a sub-index of 2 IS a valid
	// ring index of 2, so passing one in would have silently burst in some
	// unrelated ring card's colour rather than failing where it could be seen.
	private color sparkColor(color hue)
	{
		int mode = int(cv("wr_spark_color", 0.0));

		if (mode == 1) return 0xFFF0D8;
		if (mode == 2) return 0;              // per-particle, see sparks()

		return hue;
	}

	// Full-saturation hue by index, for the rainbow mode. Six linear ramps
	// rather than a proper HSV conversion -- the endpoints are the only thing
	// the eye reads at this size and this is a fraction of the arithmetic.
	private static color hueOf(int i, int n)
	{
		double h = 6.0 * (double(i % max(n, 1)) / max(n, 1));
		int seg = int(h);
		int t = int((h - seg) * 255.0);

		switch (seg)
		{
			case 0:  return color(255, 255, t, 0);
			case 1:  return color(255, 255 - t, 255, 0);
			case 2:  return color(255, 0, 255, t);
			case 3:  return color(255, 0, 255 - t, 255);
			case 4:  return color(255, t, 0, 255);
			default: return color(255, 255, 0, 255 - t);
		}
	}

	// A burst off the card you just took, in that slot's colour.
	//
	// Thrown along the card's own outward bearing rather than sprayed evenly, so
	// it reads as the card breaking apart in the direction it was sitting rather
	// than as a firework going off in mid-air. Gravity on, so they fall.
	private void sparks(Vector3 at, color tint, double amount)
	{
		int count = int(clamp(cv("wr_sparks", 18.0) * amount, 0.0, 200.0));
		if (count <= 0) return;

		double spread = cv("wr_sparks_speed", 1.4);

		for (int i = 0; i < count; ++i)
		{
			FSpawnParticleParams p;

			// A zero tint is the rainbow flag from sparkColor -- no colour is a
			// value nothing legitimately wants, so it costs no extra argument.
			p.color1     = (tint == 0) ? hueOf(i, count) : tint;
			p.style      = STYLE_Add;
			p.lifetime   = 18 + (i * 7) % 22;
			p.size       = 1.6 + (i % 5) * 0.5;
			p.sizestep   = -0.06;
			p.pos        = at;

			// No Math.Random here -- the rig runs in the playsim and a
			// client-side visual must not touch the shared RNG, or two machines
			// disagree about the game state over a spark.
			double a = i * 137.508;                 // golden angle, so no clumps
			double r = 0.35 + (i % 7) * 0.14;

			p.vel = (cos(a) * r, sin(a) * r, 0.55 + (i % 4) * 0.22) * spread;
			p.accel = (0, 0, -0.06);

			p.startalpha = 1.0;
			p.fadestep   = -1.0;                     // engine picks from lifetime

			level.SpawnParticle(p);
		}
	}

	// A REAL MODEL AT EACH CARD.
	//
	// MODELDEF binds a model to a CLASS -- `Model Vanilla_BFG9000 { ... }` --
	// so there is no way to hand a generic carrier somebody else's model. That
	// is the same wall the hand model hit. The way through it is not to copy
	// anything: spawn the weapon's OWN class and the engine resolves its model
	// by itself, which means this works for any model-based weapon set rather
	// than a list of ones we knew about.
	//
	// A billboard cannot do this at all. There is no model payload -- a
	// billboard is a quad -- and rendering a model into a card via a camera
	// texture costs a full RenderViewpoint per card per frame, doubled again for
	// stereo. A real actor costs one model draw and, unlike a picture of a gun
	// on a flat card, it has actual stereo depth and catches the card light.
	//
	// DEFANGED ON SPAWN, and every one of these matters:
	//   bSpecial off   -- an Inventory actor in the world is picked up on touch,
	//                     and a display prop that vanishes into your backpack
	//                     when you reach for its card is worse than no prop.
	//   NOBLOCKMAP     -- never enters the blockmap, so nothing can collide with
	//                     it or even test against it.
	//   NOGRAVITY      -- it hangs where layout() puts it.
	//   NOTONAUTOMAP   -- eight guns should not appear on the map.
	//
	// NOT +NOINTERACTION, and that was a bug. It stops the actor THINKING, and a
	// weapon set is entitled to make its pickup appearance a decision rather
	// than a sprite. VanillaVRPlus does exactly that:
	//
	//     Spawn:
	//         TNT1 A 0 A_JumpIf(GetCVAR("evw_pickupmodel")==1, "Spawn.Model")
	//         BFUG A 1
	//
	// A frozen actor never runs that jump, so it sat on a zero-duration TNT1
	// forever and drew nothing at all. Letting it tick is also just the honest
	// general answer: whatever a weapon set does for its own world pickup is
	// what its card should show, and that is a state machine, not a lookup.
	//
	// Degrades honestly: a weapon with no MODELDEF entry shows its pickup
	// SPRITE in the world instead, which still has depth and still beats a flat
	// icon.
	private void spawnCardModels(PlayerPawn pmo)
	{
		// Weapons only. An inventory item has no HUD model worth standing on
		// a card, and a model-page card is a NAME -- spawning the same gun
		// once per shelf row would be a dozen copies of one mesh.
		if (mPage != PAGE_WEAPONS) return;

		clearCardModels();

		if (!cvBool("wr_models", true)) return;

		double sc = cv("wr_model_scale", 0.16);

		for (int i = 0; i < mTypes.Size(); ++i)
		{
			let a = Actor.Spawn(mTypes[i], pmo.Pos, NO_REPLACE);
			if (a == null) { mModels.Push(null); mModelFit.Push(1.0); mModelDrop.Push(0); continue; }

			// bSpecial is the one that matters: an Inventory actor in the world
			// is picked up on touch, and a prop that vanishes into your backpack
			// when you reach for its card is worse than no prop.
			a.bSpecial      = false;
			a.bNoGravity    = true;
			a.bNoTonAutomap = true;
			a.Vel           = (0, 0, 0);

			// NOT a.bNoBlockmap = true. That field is only writable from inside
			// Actor, because changing it has to unlink the actor from the world
			// and link it back -- setting it from outside would leave the
			// blockmap holding a stale entry. A_ChangeLinkFlags is the mechanism
			// that does both halves.
			//
			// Once it is out of the blockmap nothing can collide with it or even
			// test against it, which is why the thru-actors and no-trigger flags
			// that were here as well are gone: they were guarding against
			// contact that can no longer happen.
			a.A_ChangeLinkFlags(1);

			a.Scale = (sc, sc);
			a.SetStateLabel('Spawn');

			// RSQ: INSIDE THE CARD OR NOT AT ALL (the owner: "must live inside that size of card").
			// The pickup's voxel is measured from its own VOXELDEF scale and KVX size
			// (wr_q_vox.zs) and fitted to the card's width and height; a pickup with no voxel to
			// measure (a sprite, or a model whose size script cannot read) keeps the flat icon.
			double fit = 0;
			TextureID t; bool fl; Vector2 ss;
			if (a.CurState) [t, fl, ss] = a.CurState.GetSpriteTexture(0);
			if (t.IsValid())
			{
				Vector2 vs = wr_VoxSize.Size(TexMan.GetName(t));
				if (vs.x > 0 && vs.y > 0)
					fit = min(panelWNow() * 0.70 / vs.x, panelHNow() * 0.55 / vs.y);
			}
			if (cvBool("wr_debug", false))
				Console.Printf("RSQ Wheel card %s: frame %s voxel %s fit %.3f", a.GetClassName(), t.IsValid() ? TexMan.GetName(t) : "-",
					fit > 0 ? "measured" : "none", fit);
			if (fit <= 0) { a.Destroy(); mModels.Push(null); mModelFit.Push(1.0); mModelDrop.Push(0); continue; }

			// a voxel stands on its origin, so it drops by half its height to sit centred
			Vector2 vsz = wr_VoxSize.Size(TexMan.GetName(t));
			mModels.Push(a);
			mModelFit.Push(fit);
			mModelDrop.Push(vsz.y * 0.5);
		}
	}

	private void clearCardModels()
	{
		for (int i = 0; i < mModels.Size(); ++i)
		{
			if (mModels[i] != null) mModels[i].Destroy();
		}
		mModels.Clear();
		mModelFit.Clear();
		mModelDrop.Clear();
	}

	// Guarded so a zero handle is a no-op rather than a call into nothing --
	// half these billboards are optional and the caller should not have to know
	// which ones this time.
	private void fade(int id, double alpha)
	{
		if (id != 0) wr_BB.SetBillboardAlpha(id, alpha);
	}

	// Reassembles a card's position from the three arrays it has to live in.
	// Bounds-checked because every caller is already asking "is there a card
	// there", and returning a zero vector is a visible wrong answer rather than
	// an abort.
	private Vector3 cardPos(int i) const
	{
		if (i < 0 || i >= mCardX.Size()) return (0, 0, 0);
		return (mCardX[i], mCardY[i], mCardZ[i]);
	}

	// cardPos()'s sub-card counterpart.
	private Vector3 subPos(int i) const
	{
		if (i < 0 || i >= mSubX.Size()) return (0, 0, 0);
		return (mSubX[i], mSubY[i], mSubZ[i]);
	}

	// ONE LIGHT, ON THE CARD YOU ARE POINTING AT.
	//
	// Not one per card, and that is the optimisation that matters: dynamic
	// lights cost per light per surface they touch, so eight of them sitting in
	// a ring a metre from your face is eight overlapping volumes lighting the
	// same wall. Only one card is ever the answer to "which", so only one card
	// needs to say so.
	//
	// The colour is the slot's, so the light, the card, the beam and the burst
	// all agree -- and the radius breathes on the same pulse the card does, so
	// the room brightens and settles with it rather than being a lamp that
	// switched on.
	private void cardLight(PlayerPawn pmo)
	{
		bool want = cv("wr_light", 1.0) > 0.0;
		bool resolved = mHovered != 0;

		// WHERE, AND WHAT COLOUR -- resolved up front from EITHER index space,
		// because the light does not care which of the two a card came from.
		// This used to ask the ring only and switch the room light off outright
		// on a fan card, so unfolding a slot and moving one step darkened the
		// room: the exact opposite of what a fan needs, since telling four
		// near-identical weapons apart is what the light is for.
		Vector3 here = mLightLastPos;
		color lightHue = mLightLastHue;

		if (resolved)
		{
			int card = cardIndexOf(mHovered);
			if (card >= 0 && card < mCardX.Size() && card < mCardColor.Size())
			{
				here = cardPos(card);
				lightHue = mCardColor[card];
			}
			else
			{
				int sub = subIndexOf(mHovered);
				if (sub >= 0 && sub < mSubX.Size() && sub < mSubColor.Size())
				{
					here = subPos(sub);
					lightHue = mSubColor[sub];
				}
				else resolved = false;
			}
		}

		// GRACED, NOT INSTANT. The gap between two cards is empty space on
		// purpose -- see wr_touch's own note on generous hit-testing -- and the
		// laser crosses it on every single sweep from one card to its neighbour.
		// Treating that crossing as "nothing hovered" destroyed the light and
		// spawned a fresh one on arrival, which is a visible off-then-on for
		// every card-to-card move: the ring never goes dark on purpose, so a
		// light doing it on its own reads as broken. A few graced tics let the
		// light sit at its last known spot through a gap and glide onward the
		// moment a real card answers, rather than blinking each time. Long
		// enough to bridge a gap, short enough that actually looking away still
		// reads as immediate.
		if (!resolved)
		{
			if (mLight == null) want = false;
			else if (++mLightGrace >= int(cv("wr_light_grace", 3.0))) want = false;
		}
		else
		{
			mLightGrace = 0;
			mLightLastPos = here;
			mLightLastHue = lightHue;
		}

		if (!want)
		{
			if (mLight != null) { mLight.Destroy(); mLight = null; }
			mLightGrace = 0;
			return;
		}

		if (mLight == null)
		{
			// Through a local, not straight from the getter: SetOrigin and Spawn
			// want a modifiable value, and a function's return is not one.
			Vector3 lp = here;
			mLight = Actor(Actor.Spawn("WR_CardLight", lp, NO_REPLACE));
			if (mLight == null) return;
		}

		mLight.SetOrigin(here, true);

		double breathe = 1.0 + 0.12 * sin(mHoverTics * PULSE_SPEED);
		int r1 = int(cv("wr_light_size", 44.0) * breathe);

		// Re-attached under the same id every tic, which is how the colour and
		// radius change at all -- A_AttachLight replaces a light with a matching
		// id rather than stacking a second one on top.
		mLight.A_AttachLight('wrcard', DynamicLight.PointLight,
			lightHue, r1, int(r1 * 0.35),
			DynamicLight.LF_ATTENUATE);
	}


	private void updateHover(int hit)
	{
		// SUBCARDS GET A GRACE PERIOD MAIN CARDS DO NOT NEED.
		//
		// A fan packs several cards into whatever room a busy ring can spare,
		// so landing exactly on one is a much finer aim than picking between
		// nine cards a hand's width apart on the ring proper. "Pointing at
		// nothing" was already free -- the block below never treated hit==0
		// as leaving -- but the ring's OTHER cards are not empty space, and a
		// laser that wobbles a millimetre past the fan's edge used to collapse
		// it on the very first tic, which punished exactly the imprecision a
		// fan is most likely to suffer from.
		//
		// Runs every tic regardless of which branch below fires, because a
		// wobble that settles into a genuine dwell on the wrong card (hit ==
		// mHovered, the early-return branch) has to keep counting too, not
		// just the tic the laser first arrived there.
		if (mExpanded >= 0 && hit != 0 && !belongsToExpansion(hit))
		{
			if (++mCollapseGrace >= int(cv("wr_subcards_grace", 6.0)))
			{
				collapseSlot();
				mCollapseGrace = 0;
			}
		}
		else
		{
			mCollapseGrace = 0;
		}

		// Dwell, not instant. Sweeping across a row on the way somewhere else
		// would otherwise open and shut four fans in a third of a second.
		if (hit == mHovered)
		{
			if (mHovered == 0) return;

			// A HAND STILL ON A CARD IS STILL DECIDING -- reset the fold-away
			// clock every tic it stays there, not only on the tic it arrives.
			//
			// The only other reset lives below the `hit == mHovered` early return,
			// so it fires when the hovered id CHANGES and never again while it
			// stays the same. Holding one card therefore gave exactly wr_locktics
			// -- four seconds -- from the moment you landed on it, then faded and
			// closed mid-decision. A 28-row DOOM Infinite sheet cannot be read in
			// four seconds, so the only way to finish reading one was to jiggle
			// the pointer off the card and back on to restart the clock.
			//
			// Both this file's own comment and CVARINFO describe continuous-hover
			// behaviour ("Hovering a card resets it"). This is the line that makes
			// that true. Audit finding #19.
			mLockTics = int(cv("wr_locktics", 140.0));

			++mHoverTics;
			++mDwellTics;

			// The constellation's own clock -- only ever ticks while an
			// expansion is actually open, which is exactly when its lines
			// need to know how far along they are.

			// Nothing to unfold when every weapon already has its own card --
			// the fan would be a duplicate of cards already on the ring.
			//
			// mFansEnabled, not a live cv() read: whether fans are enabled is
			// a fact about the cards THIS ring was built with, decided once
			// in gatherWeapons(). Re-reading wr_subcards_max here would let a
			// slider drag mid-hover flip a ring that already committed to
			// being flat into trying to expand a card that has nowhere to
			// expand FROM -- every one of its siblings is already its own
			// card on the ring, not folded behind this one.
			if (mDwellTics == DWELL_TO_EXPAND && !belongsToExpansion(hit)
			    && mFansEnabled)
			{
				let pmo = players[consoleplayer].mo;
				if (pmo != null)
				{
					int before = mSubIds.Size();
					expandSlot(pmo, cardIndexOf(hit));
					// Only if a fan actually opened. A one-weapon slot does not
					// expand, and announcing an event that did not happen is
					// worse than silence.
					if (mSubIds.Size() > before) feedback(Sound("wristrig/tick"), 0.30, 45);
				}
			}
			return;
		}

		// Pointing at NOTHING does not close the fan.
		//
		// This is what made the subcards unreachable: between the parent card and
		// its fan there is empty space, so travelling from one to the other put
		// hit at 0 for a few tics -- and treating 0 as "left the fan" collapsed it
		// before you ever arrived. Only landing on some OTHER card counts as
		// leaving, and even that is graced now -- see the top of this function.
		// Getting bored is handled by the lock timer, which is already the
		// thing that closes a rig you have stopped using.
		mDwellTics = 0;

		// Recolour the PLATE, not the thing that was hit -- the hit quad is
		// invisible, so tinting it changes nothing anyone can see. Subcards are
		// their own visible billboard and recolour directly.
		tintCard(mHovered, false);
		tintCard(hit, true);

		// Landing on a card, not leaving one. Firing on the way OUT as well would
		// double every crossing, and sweeping the ring would sound like a zip.
		// RSQ: EACH GUN HAS ITS OWN WEIGHT IN THE HAND. The tick on landing is shaped by the gun
		// under it -- a light short tick on a pistol, a long heavy one on a BFG -- so the ring
		// can be learned by feel. Weight is the slot (1 light .. 9 heavy), the one size measure
		// every weapon set shares. wr_weight_feel 0 gives every card REMA's one tick.
		if (hit != 0)
		{
			double amp = 0.22, ms = 30;
			double wf = cv("wr_weight_feel", 1.0);
			mHovered = hit;
			let hw = HoveredWeapon(players[consoleplayer].mo);
			if (wf > 0 && hw)
			{
				double k = clamp((slotOf(hw) - 1) / 8.0, 0.0, 1.0);
				amp = 0.14 + 0.40 * k * wf;
				ms  = 18 + 50 * k * wf;
			}
			feedback(Sound("wristrig/move"), amp, ms);
		}

		mHovered   = hit;
		mHoverTics = 0;
		if (hit != 0)
		{
			mLockTics = int(cv("wr_locktics", 140));
			if (mLockTics <= 0) mLockTics = 140;
			mWarnedThisOpen = false;
		}
	}

	// Straight into the hand, no lower and no raise.
	//
	// MoveWeaponToHand is the correct engine call and it is NOT usable here: it
	// ends in DropWeapon, which starts the deselect animation, so the gun you
	// asked for arrives half a second after you asked. In a menu you have
	// already spent time in, that reads as the pick not registering.
	//
	// So this does what BringUpWeapon does minus the raise -- sets the hand's
	// weapon and puts its psprite straight into the ready state. The two things
	// MoveWeaponToHand does that actually matter are kept: the hand flag is
	// mirrored onto the sister weapon, or a powered-up Tome variant ends up
	// pointing at the wrong hand; and bNoHandSwitch is honoured rather than
	// quietly overridden.
	// RSQ: returns false when nothing was equipped.
	private bool equipInstantly(PlayerPawn pmo, Weapon weap, int hand)
	{
		let player = pmo.player;
		if (player == null || weap == null) return false;

		bool wantOffhand = (hand == 1);

		// heldWhere() == 1: the card is the gun already in this hand, and the
		// marker on it promises that taking it changes nothing. Re-seating it
		// reset the live psprite to Ready -- cutting a state-driven reload or
		// a burst short -- and cancelled a pending slot-key switch.
		let already = wantOffhand ? player.OffhandWeapon : player.ReadyWeapon;
		if (already == weap) return true;

		if (weap.bNoHandSwitch && weap.bOffhandWeapon != wantOffhand) return false;

		// A braced off hand cannot be armed: see offhandBraced.
		if (wantOffhand && offhandBraced(pmo)) return false;

		// Coming out of the other hand: empty it first, or the same weapon is
		// held twice and the engine's own bookkeeping disagrees with itself.
		if (wantOffhand && player.ReadyWeapon == weap)  player.ReadyWeapon  = null;
		if (!wantOffhand && player.OffhandWeapon == weap) player.OffhandWeapon = null;

		weap.bOffhandWeapon = wantOffhand;
		if (weap.SisterWeapon != null) weap.SisterWeapon.bOffhandWeapon = wantOffhand;

		if (wantOffhand) player.OffhandWeapon = weap;
		else             player.ReadyWeapon   = weap;

		player.PendingWeapon = WP_NOCHANGE;

		int layer = wantOffhand ? PSP_OFFHANDWEAPON : PSP_WEAPON;
		player.SetPsprite(layer, weap.GetReadyState());
		return true;

		// NO SCALE BOOKKEEPING HERE. It is commit()'s job, and it has to happen
		// BEFORE any of this runs -- see the note there. Dropping the flag at
		// this point without putting the scale back is what shrank the weapon by
		// half on every single use.
	}

	// RSQ: THE TWO-HAND BRACE. On a SteamVR build the engine sets WF_TWOHANDSTABILIZED while the
	// off-hand grip is closed near the gun (gl_openvr.cpp:1716-1727). While it is set the off-hand
	// weapon fires nothing (player.zs:393, :426), checks no buttons (p_pspr.cpp:755) and draws
	// nothing (hw_weapon.cpp:832, :917), and SetPsprite puts the flag straight back
	// (p_pspr.cpp:514). A gun handed to a braced off hand would arrive unseen and dead while the
	// ring said the pick had landed. So a pick for that hand goes to the main hand when the gun
	// allows it, and is refused out loud (the dry-pick sound) when it does not. The Quest's
	// OpenXR path never sets the flag, so there this is always false and nothing changes.
	private static bool offhandBraced(PlayerPawn pmo)
	{
		return pmo && pmo.player && (pmo.player.WeaponState & WF_TWOHANDSTABILIZED);
	}

	// Which weapon the OTHER hand is holding, or null.
	private Weapon otherHandWeapon() const
	{
		return (mRigHand == 1) ? players[consoleplayer].ReadyWeapon
		                       : players[consoleplayer].OffhandWeapon;
	}

	// The family root of a cloned weapon: RS_PlasmaRifle_3 -> RS_PlasmaRifle.
	//
	// The convention is a mod one, not an engine one -- a weapon set that wants
	// two of the same gun cannot use the same class twice, so it ships numbered
	// subclasses with their own tags and selection numbers. Stripping the suffix
	// is what lets the rig recognise those as siblings rather than as unrelated
	// weapons that happen to look alike.
	//
	// Not `private` -- the LegenDoom and DRLA compat files need the exact
	// same suffix-stripping rule (a dual-wielded clone's rarity/tier
	// marker is named after the un-suffixed base class) and used to carry
	// byte-identical copies of this function. Unlike those files' own
	// cv() copies, which genuinely differ per file for a real reason,
	// this is pure string logic with zero cvar/mod dependency, so there
	// was no justification for three independent copies of the same
	// convention to drift out of sync.
	clearscope static string familyRoot(string name)
	{
		int n = name.Length();
		if (n < 3) return name;

		// Only a single trailing digit after an underscore. _10 is not a thing
		// anyone ships, and being greedy here would fold BFG_9000 into BFG_900.
		//
		// ByteAt rather than comparing one-character strings: ZScript's string
		// operators are equality only, so '<' on a string is not the ordering
		// test it looks like.
		int last = name.ByteAt(n - 1);
		if (name.ByteAt(n - 2) != 0x5F) return name;   // '_'
		if (last < 0x32 || last > 0x39) return name;   // '2'..'9'

		return name.Left(n - 2);
	}

	// A sibling of this weapon that the player owns and NEITHER hand is holding.
	//
	// This is the good outcome when you pick the gun your other hand already
	// has: a mod that ships _2 through _6 clones did so precisely so you could
	// hold two, and taking the clone gives you what you clearly meant -- one in
	// each hand -- rather than shuffling the single copy back and forth.
	private Weapon freeTwinOf(PlayerPawn pmo, Class<Weapon> want) const
	{
		// Assigned to a string first: GetClassName returns a Name, and relying on
		// an implicit conversion inside an argument list is the kind of thing
		// that reports as an unrelated error two lines away.
		string cn = want.GetClassName();
		string root = familyRoot(cn);

		let inHand  = otherHandWeapon();
		let inMine  = (mRigHand == 1) ? players[consoleplayer].OffhandWeapon
		                              : players[consoleplayer].ReadyWeapon;

		// The root itself first, then _2 upward, so picking a clone can fall back
		// to the original as readily as the other way round.
		for (int i = 0; i <= 8; ++i)
		{
			string candidate = (i == 0) ? root : String.Format("%s_%d", root, i + 1);

			Class<Weapon> cls = (class<Weapon>)(candidate);
			if (cls == null || cls == want) continue;

			let twin = Weapon(pmo.FindInventory(cls));
			if (twin == null) continue;
			if (twin == inHand || twin == inMine) continue;

			// A sibling sitting in a holster or on a hardpoint is not "free":
			// handing it over produces a gun CheckAmmo will not let the player
			// fire. Same rule as slotWeapons(); the reasoning is written out
			// there.
			// RSQ: no bHolsterHidden on QZD 17.3 (a REMA weapon flag); nothing is skipped.

			// No point handing this hand something it is forbidden to hold.
			if (twin.bNoHandSwitch && twin.bOffhandWeapon != (mRigHand == 1)) continue;

			return twin;
		}
		return null;
	}


	// SET THE MODEL, through ModelSwapper's own bridge. Its Cycle() steps by
	// one; picking card N means stepping (N - current), which lands exactly
	// on the card you pointed at rather than walking you toward it.
	private void commitModel(PlayerPawn pmo)
	{
		int index = cardIndexOf(mHovered);
		if (index < 0 || index >= mTypes.Size()) return;

		int hand = (mRigHand == 1) ? 1 : 0;

		bool ok; string arche, donor; int pick, count;
		[ok, arche, pick, count, donor] = wr_CompatModelSwapper.StateOf(hand);
		if (!ok || count <= 0) return;

		// Cycle takes an arbitrary step, not just +/-1 -- ModelSwapper's own
		// CyclePick is (pick + dir) % n -- so one call lands exactly on the
		// card that was pointed at.
		int delta = index - pick;
		if (delta != 0) wr_CompatModelSwapper.Cycle(hand, delta);

		feedback(Sound("wristrig/lock"), 0.45, 60);

		// Stays open on purpose -- picking a look is something you do a few
		// times in a row, comparing, and closing after each one would make
		// that four gestures instead of one.
		// NOT rebuildPage(pmo) here. The cycle went into ModelSwapper's bridge
		// cvar, which ITS WorldTick consumes; this runs from NetworkProcess,
		// which the engine dispatches before P_Ticker, so an immediate rebuild
		// read the previous pick and left the 'worn' highlight on the old
		// model. Two tics, so it lands whichever way the handlers are ordered.
		mRebuildTics = 2;
	}

	// RSQ: the gun goes into the hand that picked it. A gun that only fits one hand
	// (bNoHandSwitch) goes to that hand whichever hand pointed at it.
	private void commit(PlayerPawn pmo)
	{
		if (eitherHand() && mPage == PAGE_WEAPONS)
		{
			int hand = mPokeHand;
			Class<Weapon> want = HoveredClass();
			let w = want ? Weapon(pmo.FindInventory(want)) : null;
			if (w && w.bNoHandSwitch) hand = w.bOffhandWeapon ? 1 : 0;
			// braced off hand: the gun goes to the hand that can hold it (offhandBraced)
			else if (hand == 1 && offhandBraced(pmo)) hand = 0;
			mRigHand = hand;
		}
		commitAs(pmo);
	}

	private void commitAs(PlayerPawn pmo)
	{
		// RSQ: a braced off hand takes nothing (offhandBraced). Said the way a dry pick is said,
		// and nothing is equipped, so the ring never confirms a gun the hand cannot use.
		if (mPage == PAGE_WEAPONS && mRigHand == 1 && offhandBraced(pmo))
		{
			feedback(Sound("wristrig/nope"), 0.35, 60);
			closeRig(true);
			return;
		}
		// RSQ: remember what this hand held, for the double tap
		if (mPage == PAGE_WEAPONS)
		{
			int h = (mRigHand == 1) ? 1 : 0;
			let had = (h == 1) ? pmo.player.OffhandWeapon : pmo.player.ReadyWeapon;
			Class<Weapon> want = HoveredClass();
			if (had && (!want || !(had is want))) { mPrevWeap[h] = had; mLastPickHand = h; }
		}
		if (mPage == PAGE_MODELS)    { commitModel(pmo);     return; }

		// Same resolution HoveredClass() answers for anyone asking from
		// outside -- pulled into one place so the two can never disagree
		// about what a press is about to do.
		Class<Weapon> want = HoveredClass();
		if (want == null) return;

		let weap = Weapon(pmo.FindInventory(want));
		if (weap == null) { closeRig(); return; }

		// PICKING THE GUN YOUR OTHER HAND IS ALREADY HOLDING.
		//
		// It used to be taken literally: the weapon moved across, and the hand it
		// came from was left empty. That is almost never what the ask meant. Two
		// better answers, in order:
		//
		//   1. A FREE TWIN. A weapon set that ships _2 through _6 clones did so
		//      specifically so you could hold two. Take the clone and you end up
		//      with one in each hand, which is the thing you were reaching for.
		//
		//   2. A SWAP. No clone to take, so the hands trade: what you picked
		//      comes here, what was here goes there. Nothing is put down, and
		//      the move is reversible by doing it again -- which is the property
		//      that makes it safe to try mid-fight.
		//
		// Order matters. Swapping first would be a worse outcome reached faster.
		bool swapped = false;
		if (weap == otherHandWeapon())
		{
			let twin = freeTwinOf(pmo, want);
			if (twin != null)
			{
				weap = twin;
			}
			else
			{
				// Read BEFORE the first equip: equipInstantly rewrites both
				// hands' pointers, so afterwards there is nothing left to move.
				let mine = (mRigHand == 1) ? players[consoleplayer].OffhandWeapon
				                           : players[consoleplayer].ReadyWeapon;

				equipInstantly(pmo, weap, mRigHand);

				// Not guaranteed to land: a bNoHandSwitch weapon refuses the
				// other hand, and equipInstantly returns without doing anything.
				// That leaves the other hand empty, which is still a better
				// outcome than refusing the pick the player actually made.
				if (mine != null && mine != weap)
				{
					equipInstantly(pmo, mine, mRigHand == 1 ? 0 : 1);
				}
				swapped = true;
			}
		}

		// The confirm, and it is deliberately the biggest thing the rig does:
		// twice the hover pulse and three times as long. This is the one moment
		// worth being unmistakable, because it is the one that changes the game
		// state, and it fires BEFORE closeRig so it is not lost to the teardown.
		//
		// A DRY PICK SOUNDS WRONG ON PURPOSE. It still equips -- you asked for
		// it and you may well have meant it -- but you find out now, from the
		// wrist, rather than at the trigger with something walking at you. The
		// pulse is shorter and weaker too: the hand agrees with the ear.
		bool dry = (ammoLoaded(weap) == 0);
		if (dry) feedback(Sound("wristrig/nope"), 0.35, 60);
		else     feedback(Sound("wristrig/lock"), 0.75, 90);

		// THE CARD COMES APART.
		//
		// Fired from where the card actually is, which is why it happens here
		// and not after closeRig -- the ring is torn down on the next line and
		// the position goes with it.
		//
		// A dry pick gets a smaller, sadder burst. The rig says the same thing
		// three ways at that moment -- a different sound, a weaker pulse, fewer
		// sparks -- because it is the one outcome you might genuinely not have
		// meant.
		int hitCard = cardIndexOf(mHovered);
		if (hitCard >= 0 && hitCard < mCardX.Size() && hitCard < mCardColor.Size())
		{
			Vector3 burstAt = cardPos(hitCard);
			color burstHue = sparkColor(mCardColor[hitCard]);
			sparks(burstAt, burstHue, dry ? 0.4 : 1.0);

			// One-shot ring at the same spot the sparks just fired from,
			// same reasoning as expandSlot()'s own flash -- non-persistent,
			// self-expiring, needs no further script involvement. The take
			// already has a sound and a haptic pulse; this is the visual
			// third that reads even with haptics or sound off.
			if (cvBool("wr_flash", true))
			{
				wr_BB.AddBillboard(burstAt, panelWNow() * 1.3, panelHNow() * 1.3,
					pmo.angle + 180, PANEL_TILT, wr_BB.BBF_FIXED,
					wr_BB.BB_RING, 0, burstHue,
					wr_BB.BBFL_NOHIT, 0.35);
			}

			// And it flips as it folds away. Roll is a real axis now, and the
			// group collapse keeps the billboards alive long enough to see it.
			mFlipCard = hitCard;
			mFlipTics = CLOSE_TICS;

			// Remembered so a collapsed slot's face is this one next time,
			// not whatever SetSlot happened to register first.
			if (hitCard < mCardSlots.Size())
			{
				int pickedSlot = mCardSlots[hitCard];
				if (pickedSlot >= 0 && pickedSlot < 10) mLastPicked[pickedSlot] = want;
			}
		}
		else
		{
			// A FAN CARD BREAKS APART TOO. Taking one used to be the only quiet
			// pick in the mod -- no burst, no flip -- which read as the take not
			// having registered at the exact moment it had.
			//
			// Safe for the same reason the flip is: closeRig does NOT collapse
			// the fan, it animates mFanGroup to zero over CLOSE_TICS and defers
			// the actual destruction to destroyPanels, so these billboards
			// outlive this call by exactly the window the spin needs.
			int hitSub = subIndexOf(mHovered);
			if (hitSub >= 0 && hitSub < mSubX.Size() && hitSub < mSubColor.Size())
			{
				Vector3 burstAt = subPos(hitSub);
				color burstHue = sparkColor(mSubColor[hitSub]);
				sparks(burstAt, burstHue, dry ? 0.4 : 1.0);

				if (cvBool("wr_flash", true))
				{
					wr_BB.AddBillboard(burstAt, panelWNow() * 1.3, panelHNow() * 1.3,
						pmo.angle + 180, PANEL_TILT, wr_BB.BBF_FIXED,
						wr_BB.BB_RING, 0, burstHue,
						wr_BB.BBFL_NOHIT, 0.35);
				}

				mSubFlipCard = hitSub;
				mFlipTics    = CLOSE_TICS;

				// Same remembering as the main-card branch -- a subcard's
				// slot is its fanned-open parent's slot, mExpanded.
				if (mExpanded >= 0 && mExpanded < mCardSlots.Size())
				{
					int pickedSlot = mCardSlots[mExpanded];
					if (pickedSlot >= 0 && pickedSlot < 10) mLastPicked[pickedSlot] = want;
				}
			}
		}

		// The swap already did its own equipping, above, because it needed to
		// read the outgoing weapon before anything moved.
		if (!swapped) equipInstantly(pmo, weap, mRigHand);
		closeRig(true);
	}

	const PANEL_TILT  = 12.0;
	const COLOR_IDLE  = 0x2E3440;
	const COLOR_HOVER = 0xEF9F27;
	const COLOR_LABEL = 0xD8DEE9;
	const COLOR_SUB         = 0x4A3A20;
	const HIT_PAD           = 1.12;
	const PULSE_SPEED       = 14.0;   // degrees per tic
	const POINTER_RANGE     = 200.0;
	const DWELL_TO_EXPAND   = 7;    // tics on a slot before its fan opens
	const GLOW_RADIUS   = 3.0;
	const GLOW_STRENGTH = 1.4;

	const LABEL_LIFT        = 0.6;

	// ONE line of the name, as a fraction of the card. 0.34 was set when a name
	// was always one line and the card had nothing else on it; against a slot
	// stripe, artwork, ammo bars and a bezel it reads as shouting.
	const LABEL_HEIGHT_FRAC = 0.22;

	// And how much of the card's HEIGHT the whole name may occupy once wrapped.
	//
	// This was 0.34, which is roughly ONE line's worth of block -- so two lines
	// were squeezed to about two thirds size and a wrapped name ended up
	// markedly smaller than an unwrapped one on the card beside it. The point of
	// wrapping was to STOP long names being small.
	//
	// Two lines should be slightly smaller per line than one, because there are
	// two of them; they should not be half. 0.46 leaves them within about ten
	// percent of a single-line name.
	const LABEL_BLOCK_FRAC  = 0.52;

	// A card with nothing left in it. Dark red rather than grey: grey reads as
	// disabled, and this weapon is not disabled -- you can absolutely select it,
	// it just will not fire.
	// What the beam, the sweep and the mist are tinted when the pointer is on
	// nothing. Cool and dim on purpose: every slot colour is warmer or brighter
	// than this, so landing on a card always reads as a step UP.
	const COLOR_BEAM_IDLE = 0x5A6C7A;

	const COLOR_DRY      = 0x3A2226;
	const COLOR_AMMO     = 0x8C97A8;
	const COLOR_AMMO_DRY = 0xC65C5C;

	// The alt-fire reserve. Cool against the slot colour so the second bar is
	// never mistaken for more of the first.
	const COLOR_ALT_BAR  = 0x4FA3D1;

	// The held-weapon mark. The OTHER hand gets the brighter one: that is the
	// case where taking the card actually does something -- a swap, or a free
	// clone -- and the dim one just says "you are already holding this".
	const COLOR_MARK_MINE  = 0x6E7684;
	const COLOR_MARK_OTHER = 0xEFC94C;

	// Dim on purpose: a reference you glance at, never a thing competing with
	// the weapon name for attention.
	const COLOR_SLOTNUM = 0x5F6874;

	// The stack badge -- "+N", on a collapsed card hiding others behind it.
	// Warmer than COLOR_SLOTNUM on purpose: the slot number is always there
	// and asks for nothing, the badge is telling you dwelling here does
	// something, which earns a little more presence than a bare reference.
	const COLOR_STACK = 0xC98A3A;

	// THE STATS PANEL.
	//
	// 320x240 is a compromise: big enough that SmallFont rows are legible at
	// arm's length, small enough that a raster held that close does not show
	// its pixels the way a wider one would.


	// Billboards render 1.2x taller than authored -- world Z is stretched by the
	// view matrix and the billboard path never unstretches it.
	const CARD_STRETCH = 1.2;

	// CANVAS FACES. Pixel coordinates, matching the ANIMDEFS declarations --
	// change one and the other has to move with it.
	const FACE_W      = 140;
	const FACE_H      = 100;
	const FACE_POOL   = 12;    // how many WRFACEnn textures are declared
	const FACE_BANDS  = 5;     // gradient steps
	const FACE_ACCENT = 6;     // slot stripe height
	const ICON_BOX_W  = 96.0;
	// The artwork band. Sits under the bars and above the readout line, and it
	// is the largest single thing on the card because the picture is what you
	// recognise a weapon by -- the name is confirmation, not identification.
	const ICON_BOX_H  = 40.0;
	const ICON_TOP    = 15.0;
	// CANVAS LAYOUT, top to bottom, and it has to dodge the billboards.
	//
	// The name and the segment readout are drawn as separate field billboards
	// IN FRONT of the canvas, at fixed fractions of the card. So the painted
	// artwork does not get the whole face -- it gets everything above them, and
	// anything it puts in the bottom third lands underneath a label.
	//
	// Hence the ammo bars at the TOP, under the accent, rather than in the
	// natural place at the bottom: the bottom is spoken for.
	const BAR_TOP     = 11;
	const BAR_INSET   = 10;
	const BAR_H       = 8;

	// Where the label and segment land in canvas pixels, from their billboard
	// fractions. Kept as constants so the dim band below tracks them instead of
	// being a number tuned by eye.
	// The dim band has to start high enough to sit behind a TWO-LINE name, not
	// just a one-line one -- otherwise the top line of a wrapped name lands on
	// undimmed artwork and loses its contrast exactly where it got bigger.
	const READOUT_TOP = 32;

	// The box an icon is fitted into, as a fraction of the card.
	const ICON_W_FRAC = 0.72;
	const ICON_H_FRAC = 0.46;
	const AMMO_H_FRAC = 0.22;
	const AMMO_W_FRAC = 0.52;
	const GAUGE_H_FRAC = 0.07;
	const ACCENT_H_FRAC = 0.075;

	// How much of the card's width a name may use before it is shrunk to fit.
	const LABEL_FIT_FRAC = 0.90;

	// The far end of each plate's gradient. Darker than the near end in both
	// cases, so the card has a lit top and a shaded bottom.
	const GRAD_IDLE = 0xFF11141B;
	const GRAD_DRY  = 0xFF1E1013;
	const GRAD_HOVER = 0xFF8A5A12;

	// Neon on the hovered name. radius is a fraction of the atlas spread, so 1
	// is the practical maximum -- past the spread there is no field left and the
	// halo clips square at the glyph cell.
	const GLOW_R = 0.75;
	const GLOW_S = 0.9;

	// The idle shimmer's own clock. Slow on purpose -- a lazy multi-second
	// breathe, not the hover pulse's quick one -- and SHIMMER_PHASE offsets
	// it per card so the ring twinkles as a field of independently breathing
	// lights rather than flashing in lockstep. Degrees per tic, same
	// convention as PULSE_SPEED: ZScript's trig takes degrees, not radians.
	const SHIMMER_SPEED = 3.0;
	const SHIMMER_PHASE = 47.0;

	// Tics the ring takes to fold away. The billboards outlive closeRig by this
	// much so it can collapse rather than blink out.
	const CLOSE_TICS = 7;

	// How far a card tumbles on its way in, in degrees of roll.
	const ARRIVE_ROLL = 26.0;

	// THE DATA SHEET, in card widths so it tracks wr_panel_* and wr_scale
	// instead of being a fixed size that stops matching the moment either is
	// touched. Deliberately much larger than a card -- it is one panel you
	// read, not one of nine you glance at.
	// How often a shown sheet is restrung, in tics. Ten is roughly three times
	// a second -- finer than a countdown printed in whole seconds can show, and
	// nine tics in ten still skip the rebuild entirely.
	const SHEET_TICK       = 10;
	const SHEET_W_CARDS    = 2.6;
	// Grown from 3.2 -- the stat tracker (wr_stattracker.zs) added three
	// more possible rows (kills/shots/accuracy, damage/rate of fire,
	// headshots) to what the sheet always had room for. ROW_FRAC and PITCH
	// shrank in the same move, by just enough that an EXISTING row's
	// absolute size on screen is unchanged (sh * ROW_FRAC is the same
	// number as before, sh just got bigger to make room for more of them)
	// -- this is a taller, narrower plate fitting more of the same-size
	// rows, not the same plate with smaller text crammed in.
	// Grown again, 3.9 -> 8.6, for the same reason and by the same technique
	// as the 3.2 -> 3.9 step before it: a fully-loaded DOOM Infinite weapon
	// can emit close to thirty rows (its own dozen supplementary axes, plus
	// the player-side run/health/buff block, plus the universal stat rows on
	// top), and rows past the pool are dropped silently by sheetRow. ROW_FRAC
	// shrinks in exact proportion, so h * ROW_FRAC -- an existing row's real
	// size on screen -- is unchanged. A taller plate holding more of the same
	// size rows, never the same plate with smaller text.
	//
	// It is a big panel now. wr_sheet_scale shrinks the whole thing for
	// anyone who would rather lose rows than height.
	const SHEET_H_CARDS    = 8.6;
	const SHEET_GAP_CARDS  = 0.55;   // daylight between ring and sheet
	const SHEET_TITLE_FRAC = 0.085;  // title height, of sheet height
	const SHEET_ROW_FRAC   = 0.0204; // one row's height
	const SHEET_ROWS_TOP   = 0.21;   // where the first row starts, from the top
	const SHEET_ROW_PITCH  = 1.30;   // row spacing as a multiple of row height

	// THE COMPARISON CARD, in card widths like the sheet so it tracks
	// wr_panel_* and wr_scale rather than being a fixed size that stops
	// matching the moment either is touched.
	//
	// WIDER AND SHORTER than the data sheet on purpose. The sheet is a
	// column of facts about one weapon and grows downward; this is a table
	// with three columns and a fixed number of rows, so it needs width far
	// more than it needs height.
	const CMP_W_CARDS   = 4.2;
	// Grown from 3.0/0.058/1.30 -- pulling every mod's own supplementary
	// rows for BOTH weapons, merged, can run well past what the original
	// ten-row table held. ROW_FRAC shrank in the same move so an EXISTING
	// row's absolute size on screen is unchanged (h * ROW_FRAC is the same
	// number as before, h just grew to make room for more of them) -- this
	// is a taller table fitting more of the same-size rows, not the same
	// table with smaller text crammed in. Same technique the data sheet's
	// own 9-to-12 row growth used.
	const CMP_H_CARDS   = 6.5;
	const CMP_ROW_FRAC  = 0.027;
	const CMP_ROWS_TOP  = 0.26;
	const CMP_ROW_PITCH = 1.15;

	// Column centres, as fractions of the card's own width from its middle.
	// The label column is wide and sits left of centre; the two value
	// columns are narrower, equal, and straddle the right half so the eye
	// can run down either one.
	const CMP_COL_LABEL = 0.30;
	const CMP_COL_A     = 0.10;
	const CMP_COL_B     = 0.34;
	const CMP_COL_W     = 0.26;

	// Sized for the worst real case: DPS, damage, rate of fire, magazine,
	// pellets, ammo, tier and hands (8, always present) plus up to roughly a
	// dozen merged per-mod rows for two heavily-modded weapons from
	// different mods, where nothing merges and every row doubles up. Rows
	// past this pool are silently dropped, same as the sheet's own pool --
	// not an error, just a card that has genuinely run out of plate.
	// 23, NOT 26 -- the number the PLATE holds, not the number the content
	// estimate wanted.
	//
	// Derived rather than guessed: rows start at CMP_ROWS_TOP from the top and
	// step CMP_ROW_FRAC * CMP_ROW_PITCH each, so the last row that still has its
	// bottom edge on the plate is index 22. Rows 24, 25 and 26 were drawn as
	// free-floating text BELOW the card with no background behind them, which is
	// worse than the honest truncation the pool comment promised ("silently
	// dropped ... a card that has genuinely run out of plate").
	//
	// The data sheet's equivalent numbers were kept in step when SHEET_H_CARDS
	// grew; this pool was picked from a content estimate and never was. Audit
	// finding #26.
	const CMP_ROW_POOL  = 23;

	// How many row billboards the sheet allocates, once, up front.
	//
	// layoutSheet steps rows down on a fixed pitch and bars continue the same
	// cursor, so the plate holds thirteen elements before the fourteenth
	// renders off its bottom edge (12 * ROW_FRAC * PITCH + one bar's worth
	// ~= 0.76 of the 0.79 available below the title, leaving a margin
	// rather than sitting exactly on the edge). Twelve rows plus one bar is
	// that budget. A row past it would not error -- it would silently draw
	// into the room, same as before this grew.
	const SHEET_ROW_POOL   = 28;

	const SHEET_BG     = 0x0E1016;
	const SHEET_BG2    = 0x1B2030;
	const SHEET_ACCENT = 0x7F77DD;
	const SHEET_TEXT   = 0xE8EAF0;
	const SHEET_DIM    = 0x8D93A3;

	// THE ONLY TWO COLOURS ON THIS SHEET THAT MEAN BETTER OR WORSE. Every
	// other colour here is a category -- masked, measured, hot, dim. These
	// two are a verdict, and they exist so a delta can be read without
	// parsing the sign in front of the number.
	const COLOR_DELTA_UP   = 0x66DD66;
	const COLOR_DELTA_DOWN = 0xDD5555;
	const SHEET_HOT    = 0xEF9F27;
	const SHEET_COOL   = 0x4FA3D1;
	const SHEET_MEAS   = 0x5DCAA5;
	// A masked row. One colour for every kind of hidden, because a curse is a
	// STATE rather than a category -- RS_Screens.zs:624-626 makes the same
	// point about locked rows outranking their stat family's own hue.
	const SHEET_LOCK   = 0xBE3E4E;

	// Where a fan's innermost ring sits, in cells out from its parent card.
	//
	// Not 1. At one cell, three cards need about sixty degrees between them
	// before they stop overlapping (see layoutExpansion), and a sixty-degree
	// fan on a nine-slot ring comes within a card's width of the neighbouring
	// slot. At 1.6 the same three need about thirty-six, which clears the
	// neighbour by roughly two card widths. Trading a little reach for the
	// angle to separate properly is the whole point of the number.
	const FAN_FIRST_RING = 1.6;

	// How thick a constellation's hub-to-star line draws, in map units.
	// Hairline on purpose and NOT scaled with the cards: a link is meant to
	// be read as a relationship between two things, and a line heavy enough
	// to have visual weight of its own starts competing with the stars it is
	// supposed to be connecting.
	const LINE_THICK = 0.10;

	// The decorative field's own depth and drift. Stars sit FURTHER from the
	// eye than the real cards (STAR_BEHIND, in card widths) so the parallax
	// the ring already applies separates them into a background plane rather
	// than leaving them mixed in among the data. Their shimmer runs slower
	// than the cards' own and is phase-offset per star by STAR_PHASE, the
	// same trick and the same reason SHIMMER_PHASE exists: a field that
	// breathes in lockstep reads as one blinking object, not as a sky.
	const STAR_BEHIND = 2.2;
	const STAR_SPEED  = 1.7;
	const STAR_PHASE  = 61.0;
}

// WR_TestPlayer lived here and now lives in RS_WeaponWheel_dev, because
// AddPlayerClasses is global: registering a debug pawn put "Rig Test" in the
// New Game class list of every game this mod was loaded with.


// Carrier for the hovered card's light.
//
// An actor only because A_AttachLight is an actor method -- there is no way to
// hang a dynamic light on a billboard, which is what this actually wants to be.
// Nothing about it participates in the world: no collision, no gravity, no
// thinking, nothing drawn.
class WR_CardLight : Actor
{
	Default
	{
		+NOINTERACTION;
		+NOBLOCKMAP;
		+NOGRAVITY;
		+NOTONAUTOMAP;
		+DONTSPLASH;
		RenderStyle "None";
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}
}
