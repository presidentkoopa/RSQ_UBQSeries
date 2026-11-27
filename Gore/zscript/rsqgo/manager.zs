// ============================================================================
// RSQGO_Manager -- RSQ Gore's one event handler. PHASE 0: IT DOES NOTHING.
//
// What it will hold (design/GORE_SYSTEM_DESIGN.md section 2.2), phase by phase:
//   - the takeover: CheckReplacement maps BD's and XMVE's gore classes by name through a class-keyed cache (the
//     generated exact-name table first, then `is` against colour roots, otherwise the class is left to BD). Never
//     IsFinal. Nothing when rsqgo_on is off or BD is absent.
//   - budgets and rings: live counts per category, spawn budgets per tic from the preset (CVARINFO), one ring per
//     residue kind; a full ring recycles its oldest entry, never by timer and never by RNG.
//   - the floor-spot merge grid (64-unit cells), and the small per-tic schedules (drips, pool growth, screen blood,
//     smear zones, VisualThinker frames). No ThinkerIterator, no BlockThingsIterator.
//   - the cosmetic emitter: particles and parked VisualThinkers, per machine, a handler-held xorshift, never a shared RNG.
//
// THE TWO TIERS (section 2.1). Anything that is an actor is decided identically on every machine: server cvars,
// distance to the NEAREST player (never consoleplayer), random[RSQGO_Play]. Particles, VisualThinkers and decals may
// differ per machine and never spawn an actor.
// ============================================================================

class RSQGO_Manager : EventHandler
{
	// Parking (section 2.4): a thinker in a statnum below STAT_FIRST_THINKING (32) is never ticked, still saved, still
	// moved by lifts. The series' map: 28-30 are taken (Miniboss fx.zs 29, VisualRewards 30); RSQ Gore takes these two.
	const STAT_PARKED_ACTOR = 26;    // landed spots, pools, meat, limbs, casings
	const STAT_PARKED_VT    = 27;    // VisualThinkers drawn by the cosmetic emitter
}
