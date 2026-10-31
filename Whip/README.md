# RSQ_Whip (Radiant Silvergun Quest series) -- PROJECT WHIP

A bullwhip for **stock QuestZDoom 17.3** VR. ZScript and data only, no engine change. It stands alone:
**RSQ_Grapple is not needed**, and the two load together (their own binds, their own settings).
Reference: Eye of the Temple.

## Install and binds
Load `RSQ_Whip.pk3` after your weapon pack (any order with the other series pk3s). Bind
**Whip (Main)** and **Whip (Off)** (and, to climb, **Grab Whip (Main/Off)**, or use RSQ_DistanceGrab's grips)
under Options → Customize Controls → RSQ Whip. Settings: **Options → Radiant Silvergun Options → RSQ Whip**.

## What it does
- **A real whip.** The thong is simulated (Eye of the Temple's method: links with mass that thin toward the
  tip), so it hangs, trails, loops and cracks from how you move your arm. A lazy swing never cracks; lift and snap
  the forearm, or throw it side-arm, and the loop runs down to the popper and cracks where it arrives.
- **Whip Style.** *Real*: hold the bind and the whip uncoils from that hand; let go and it rolls up. *Assist*: a
  press throws a lash for you at what you point at.
- **Whip Aim.** *Free*: the crack hits what it touches. *Assist* (default): what is nearest the tip. *Lock*: point
  the other hand and hold the whip hand's alt-fire (your gun's alt-fire is not used while a whip is out); a ring of
  sparks marks the lock; crack and the whip flies to it (~15 m). Keep the whip button held on a locked monster to
  leash it: it is pulled to you.
- **What a crack does.** Damage and a stun that breaks off the monster's attack; throws a switch it lands on;
  flicks a loose pickup to you. **A harder crack hurts more**: the damage goes with the tip's speed at the crack,
  from a quarter of *Damage (hardest crack)* at the crack speed to all of it at *Hardest Crack Speed*.
- **The whip weapon (slot 1).** Trigger held marks a target, a crack sends the whip to it and it wraps round a
  monster; a hard pull back yanks it (light ones fly to you, heavy ones swing you to them). **Wrapped, it swings
  with your arm**: held at the rope's length, it follows your arm round and smashes into the monsters it meets
  (damage and a stagger). Keep the trigger held to keep hold of it. **The lasso**: close your off hand on the
  handle or the thong (the off controller there and its grip -- any headset, Quest too -- or SteamVR's two-hand
  grip), whirl it, let go of the grip and it ropes the monster that way. **The mark stays put** (*Keep the Mark
  When You Lift*, on): once something is marked, lifting the whip for the crack does not move the mark to
  something else; only alt-fire moves it on.
- **Options (off by default).** *Crack Fireballs Out of the Air*: a crack whose lash passes through a monster's
  missile explodes it there -- or, with *Cracked Fireballs and Rockets* set to *Knocked away*, sends it off along
  the crack so it blows up away from you. *Hit-Stop*: a crack freezes the monster for a beat (3-6 tics, harder =
  longer). *Yank Grace*: a wrap cannot be yanked for its first 12 tics (~1/3 s), so the crack's own
  follow-through does not yank the monster straight away.
- **Edges.** A lash that catches a beam, a doorway head or a ledge lip wraps round it and becomes a rope: hold to
  reel, release to hang, push the stick to pump, haul down on the whip in the air to pump, climb it hand over hand
  (Grab Whip), tap to let go and fly (your speed carries on landing). Reel up to a ledge lip -- or slap a free hand
  on it with Grab -- and you **mantle** up and over, by physics (no teleport).

## Cost
Desktop (Xeon, software GL): about 0.15 ms a tic with the whip out and still, 0.25 ms while lashing; Quest
unmeasured (expect 2-3x). Debug Log = Cost prints it (`T_WPWMS`).

## Where things are
`zscript/rsqwp/whip.zs` the whip; `core.zs`, `hook.zs`, `climb.zs`, `monster.zs`, `input.zs`, `util.zs`, `a11y.zs`,
`cb.zs` the line it becomes (forked from RSQ_Grapple's core, renamed RSQWP_); `fx.zs` its look and the stubs the
fork asks for. `tools/gen_whip.py` makes the skins and sounds; `tools/whipsim.py` is the chain in Python for
tuning against recorded hand paths; `tools/rigtest/` the rig runner, the hand-driving probe and the WHIPTEST map.
HANDOFF.md has what is measured and what is open.
