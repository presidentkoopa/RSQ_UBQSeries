# Parked ideas (owner said "not now"; discuss before building)

- Laser Sight, Quest beam (owner 2026-11-07 05:49): the stray bright voxels seen in the outer beam were never
  tracked down. Instead of removing them, make points along the outer beam sparkle gently, almost
  imperceptibly. Likely route: a few tiny additive sparks at random points on the beam's outer shell, fading in
  and out (VOXELDEF frames cannot be swapped by a cvar, and extra voxel frames cost Quest memory).
  A toggle option for preference (owner 05:49), off by default.

- DOWN's player-facing name (owner 2026-11-07 06:31): "Be Quick or Be Dead", with some of its letters breathing
  in size. Player-facing only (menu and plate); the code keeps the name DOWN. Later.

## Wheel holster web (owner 2026-11-07 06:50-07:22; approved to build, not built yet)
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
