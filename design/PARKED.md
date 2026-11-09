# Parked ideas (owner said "not now"; discuss before building)

- Laser Sight, Quest beam (owner 2026-11-07 05:49): the stray bright voxels seen in the outer beam were never
  tracked down. Instead of removing them, make points along the outer beam sparkle gently, almost
  imperceptibly. Likely route: a few tiny additive sparks at random points on the beam's outer shell, fading in
  and out (VOXELDEF frames cannot be swapped by a cvar, and extra voxel frames cost Quest memory).
  A toggle option for preference (owner 05:49), off by default.

- DOWN's player-facing name (owner 2026-11-07 06:31): "Be Quick or Be Dead", with some of its letters breathing
  in size. Player-facing only (menu and plate); the code keeps the name DOWN. Later.

## Wheel holster web (owner 2026-11-07 06:50-07:22; approved to build; BUILT 11-07, rig only, not headset-confirmed)
- Alt-fire on a Wheel card opens a web on a nearer layer in its own colour: the Doom marine sprite (the IWAD's
  own player sprite) with the six gun holsters placed where the player's ACTIVE Tactical Rig profile puts them
  (2D projection), each with a small number in its middle, consistent everywhere; plus Rotation and Clear.
- Picking a holster puts the gun in it at once. The Wheel does NOT close: alt-fire is an administration mode.
  The Wheel closes as it does today (the Wheel button, or a primary-fire pick with either hand); admin actions
  reset its fold-away timer.
- A holstered gun leaves the next/prev rotation (you reach for it by hand).
- Each hand has its own next/prev list (QZD 17.3 has separate next/prev binds per hand): the web's Rotation node is
  two toggles, Main and Off; a card shows a cycle arrow on its left, right or both sides.
- A hand with an empty list cycles all its guns, as today.
- Card states (owner 07:31): plain card = Wheel only; a living border (a light running round its edge) = in
  next/prev rotation; sitting back on the ring with a fun outline = in a holster. A holstered gun leaves the
  rotation, so a card is only ever one of the three. Every toggle flashes a soft ring and ticks the controller.
- After IDKFA (new game) every gun starts in rotation (owner 07:28). Off-hand alt-fire on a card toggles rotation;
  original art wherever possible (the marine sprite, the pickup models), no fabricated art.
- Per-hand lists DROPPED (owner 07:33): one shared next/prev rotation for both hands.
- Main-hand alt-fire on a card opens the holster web; off-hand alt-fire toggles the card in or out of next/prev.
- Holstering by hand stays the main way; the web is the remote (owner 07:36). "New Guns to Holsters" (holster on
  pickup) is REMOVED. Holsters are assigned or unassigned (never assigned, or cleared in the web). Putting a gun by
  hand into an UNASSIGNED holster assigns that holster to that gun, the same as assigning it in the web (owner 07:41;
  replaces my earlier "first holster becomes its home" wording).
- An assigned holster is that gun's holster whether the gun is in it or in your hand, until the Wheel unassigns
  it or reassigns the gun elsewhere (owner 07:44). So: another gun cannot go into it; the gun's card shows the
  holstered state (and stays out of next/prev) while the gun is in your hand too; the old Holster Lock padlock is
  replaced by assignment. The web's nodes: the six holsters and Clear (rotation is off-hand alt-fire).
- Quick Swap with assignments (owner 07:46): holding an assigned gun at another gun's full holster sends your gun
  to its own holster and that holster's gun to your hand. Each gun only ever enters its own holster (an
  unassigned gun at a full holster: nothing happens).
- Off-hand alt-fire on a holster-assigned card does nothing but a dull tick: unassign it in the web first (owner
  07:47). Assigning a gun in the web to a holster another gun owns takes it over; the other gun loses its
  assignment (as in the approved mockup). The Rig's "Holster Lock" option row is removed (assignment replaces it).
  The marine in the web: whatever PLAYA1 the load order provides (BD's copy of the classic marine).
- BUILDER'S CHOICES, accepted for now pending the owner's headset look (coordinator 2026-11-07): a pick on a holster
  ring or Clear closes the web and the Wheel stays open (main-hand alt-fire on the same card again also closes it); a
  gun whose holster is taken over in the web becomes a plain card (out of next / prev, as Clear leaves one); the marine
  is a front view (his left side on your right), the holsters spread across him at 1.8x the up / down scale to match the
  sprite's breadth; next / prev never eat the key (ShieldSaw's off-hand cycle and the cigarette still read it): the
  engine's own switch runs and the Wheel puts the rotation's pick in its place (a prop in the hand, or nothing in the
  rotation: the engine's switch is left alone).
- Web polish (owner 09:2x, all picked): the marine centred on his BODY (the sprite's own offset), not the picture,
  so the rings sit on his shoulders, chest and hips; a taken ring shows its gun's own pickup sprite (empty rings
  keep the number); assigning flies the gun's sprite from the card down its line into the ring, the ring flashes in
  the profile colour, controller kick; small light pulses run from the card down each line; the hovered ring swells
  and brightens and its line lights solid; the web unfolds out of the card (panel grows from it, lines draw out one
  by one, rings pop in); the panel border carries the same running light as an in-rotation card.
- Rings are picked by POINTING, like the cards: the web sits just behind the cards' plane so the hand's pointer
  reaches it (owner 09:5x). Ring spots come from the active profile FITTED to the marine's body (the profile's
  highest holsters land on his shoulders, the lowest on his hips, scaled between), so the default profiles look
  like the owner's picture: shoulders beside the head, chest, hips (owner 09:5x).
- ShieldSaw on the shoulder (owner 10:31): with RSQ ShieldSaw loaded and its "Take It From" set to Over the (Off)
  Shoulder, the off-shoulder gun holster is the ShieldSaw's: ring 1 for a right-handed player (ring 2 if
  left-handed; the off shoulder follows handedness), shown with the ShieldSaw's own art in the ring. No gun can be
  assigned there, and Clear cannot free it; only changing ShieldSaw's own option moves it.
- Later (owner 10:31): the web could have used RSQ Tactical Rig's own mirror (the real body, the real holster spots
  and the guns' own models) instead of the marine sprite. Not now.
- Build now (owner 10:32): a Wheel option "Web View: Marine / Mirror". Mirror shows RSQ Tactical Rig's own mirror
  (as in Move Holsters by Hand: your front, the real holster spots, the guns' own models) in the web, with the rings
  on the real holster spots; Marine is today's view. Default Marine (new options default to the existing behaviour).

## Barrel lock-on (owner 2026-11-07 10:41-10:50; approved to build; BUILT 11-07, rig only, not headset-confirmed)
- Lock a monster by turning a free palm at it (works with a gun in that hand: turn the wrist sideways). Distance
  Grab's cone/beam, which normally finds items, finds a monster for this. Lock look: Distance Grab's green glow.
- Sticky: locking needs the 12-degree cone; keeping it needs about twice that. Putting the palm on another monster
  takes the lock at once. With the palm on nothing, the lock holds 3 s, then a 0.5 s grace window in which a throw or
  uppercut still goes to that monster (or where it last was).
- With a lock, a thrown barrel (Distance Grab) and an uppercut barrel (RSQ Melee, asking Distance Grab by name)
  always land on the locked monster: the arc is solved to reach it; the swing sets how hard it hits (harder = flatter,
  faster, more impact). Without a lock: the throw's existing aim assist; the uppercut as now.
- Option row "Barrel Lock-On", ON by default (owner's call).
- Lock-on answers (owner 11:1x): one lock per player, set by either free palm, used by either hand. The palm cone
  picks the MONSTER over an item when the other hand holds a barrel or you stand within punching reach of a barrel;
  otherwise items as now. A moving locked monster: the barrel STEERS in flight after it (homing). With a lock it
  always lands (decided earlier); a still release still sets it down. Steering applies to BARRELS only. An uppercut
  barrel that reaches the lock hits and explodes like a thrown one (impact, stagger, blast). Barrel Lock-On on also
  turns on Melee's uppercut barrel kick. An uppercut barrel goes to the lock only if the lock is roughly ahead;
  otherwise it flies where you punched.
- BUILDER'S CHOICES (11-07, pending the owner's look; DistanceGrab/zscript/rsqdg/lockon.zs): "punching reach" is Doom's
  own punch range, MELEERANGE 64 map units from the body to the barrel's side; "roughly ahead" is within 60 degrees of
  the kick's way (the throw's own forward gate); the lock shows no glow in the 0.5 s grace; the softest locked throw is
  the 45-degree lob that just reaches; an arc that would meet a lower ceiling on the way is thrown flatter (faster), and
  in flight the pull's Duck Under Doors caps its climb; a steered barrel that stops against its monster lands its blow
  there (a glancing stop is otherwise no impact). Anything shootable flagged a monster can be locked, e.g. Champions'
  dark-red shootable corpse (rig run).

## BD22 VR dual wield and assigned holsters (owner 11:04-11:06; BUILT 11-07, rig only, not headset-confirmed)
- Dual-wielding an assigned gun G (the off hand holds G's off-hand copy, which the Rig counts as G):
  A. Holstering the off-hand copy at G's own holster: G goes home, both hands go to fists.
  B. Holstering the off-hand copy at a holster assigned to another gun X (X in it): the off hand goes to its fist,
     G goes home to its own holster, and the main hand takes X out of that holster.
  At an unassigned empty holster: as A (an assigned gun only enters its own holster).
- Dual edge cases (owner 11:3x): an UNASSIGNED gun dual-wielded, off-hand copy into a free unassigned holster: the
  holster becomes the gun's and the gun goes in, both hands to fists (like A). The copy into a holster assigned to X
  while X is not there: like A (the gun goes home, both hands to fists) (as built).

## Rig clutter ("a lot going on", owner 2026-11-08 17:31) — parked, not built
Owner: "im not saying we should change anything, but ... this looks like a LOT going on". My four suggestions (he asked "all of them?"; parked 17:40):
1. Show only what the hand can use: a gun hand sees gun holsters; an empty hand sees spots with something in them; spots of mods not loaded never show.
2. One ring at a time: the nearest ring full, the rest faint until reached toward.
3. Shrink RSQ FnF's pocket/clip diamonds to holster-ring size, or show them only when the off hand is near.
4. "Always show" rings only while moving holsters (setup), else near-hand only.

## Wheel mod support on stock 17.3 (found 2026-11-08) — parked; DISABLED 2026-11-09
Owner 02:56: "disable wheel mod support for now". Done: every reader but LegenDoom answers off (Wheel/zscript/wheel/wr_modsupport.zs), rows hidden.
About half the Wheel's compat files (Lithium, Doom Infinite, Doomablo, Pandemonia + Anarchy/Insurrection, BorderDoom,
Guncaster, Model Swapper) read nothing on stock QZD 17.3: they use REMA's field reflection, stubbed to "no field"
(Wheel/zscript/wheel/wr_q_shim.zs:873-886). LegenDoom, DRLA, Combined Arms, Final Doomer, MetaDoom Demon Keys work.
Owner: "either get it working or we will drop support". Ways: read public items/cvars/events by name, or one small
bridge pk3 per mod. Needs from the owner: which mods to keep, and their pk3s. See design/WHEEL_MODS_PEEK.md.

## Condition bits, Gold bits, weapon wear -> Big Arcade (owner 2026-11-09 02:56)
"Condition and gold go into Big Arcade; same for weapon wear, that is condition."
