// ============================================================================
// RS_CHShared.zs -- what is left of Colourful Hell's top-level DECORATE.txt
// here, and two shared helpers.
//
// Source of truth: C:\Users\Command\Desktop\CH\DECORATE.txt (1694 lines, read
// whole, 2026-08-06). Its drop actors (the health / armour / backpack
// bundles, DropBaseAmmo, DropBaseItem and their pickups, CH_BlurSphere) and
// the RS per-kind drop gates built on them are GONE (owner 2026-11-27: "bits
// and rewards only" -- Colourful Hell's monsters drop nothing of its own).
// Its bonus / ambush event machinery (CH_BadItch and the 49 RS_Mon_* classes
// of RS_MonEvents.zs, which nothing ever spawned, in CH or here) is gone too
// (owner 2026-11-27: delete it unless the Void Orb needs it; it does not).
//
// This file holds:
//   * RS_CH_VoidOrb -- the RS build the two hardest masterminds leave behind.
//   * RS_MissileChance -- CH's MissileMore / MissileEvenMore flag flips.
// ============================================================================

// ============================================================================
// RS_CH_VoidOrb -- an RS build, 2026-08-06, at the owner's direction.
//
// CH's black (T10) and white (T11) Spider Masterminds both carry
// `Dropitem "VoidOrb"` (MASTERMINDS.txt:3883 and :4979). NO SUCH CLASS EXISTS
// ANYWHERE IN CH -- a case-insensitive sweep of the whole tree returns only
// those two DropItem lines. So in CH the drop silently does nothing, and the
// import correctly itemised it rather than substituting something.
//
// The owner's reading, which the evidence supports: the name belongs to CH's
// ATTACK vocabulary, not its pickup vocabulary. CH's only shipped "Void" actor
// is VoidField (Cacodemons.txt:1805 -> RS_CacodemonFX.zs:942), the yellow
// cacodemon's lingering damage bubble -- +INVULNERABLE, -SOLID, no COUNTKILL,
// pulsing A_Explode. VoidOrb reads as an unbuilt sibling of that, and CH's
// pickups are uniformly RS_DropBase* subclasses, which this is not.
//
// So this is NOT a loot item. It is the hazard the two hardest masterminds
// leave behind when they die: a lingering void field on the corpse. Built on
// VoidField's own shape so it belongs to the same family visually and
// mechanically -- same sprite, same DamageType, same invulnerable/no-kill
// posture -- but slower-pulsing, wider, and self-terminating, because it is a
// death legacy rather than an attack the monster is steering.
//
// THIS IS AN RS INVENTION, NOT A CH TRANSCRIPTION. It is the third deliberate
// departure in the project (after GrayPE2's healed GreyDemon2 and the hell
// knight's kept lead-shot). No CH source defines this behaviour; do not "fix"
// it against CH, and do not cite a CH line for its body.
//
// Not a tiered monster: no RS_Zom.SetTier, no token, never counted as a kill.
//
// HOOKED UP 2026-11-27 (owner: "Hook up the Void Orb"): RS_BlackMind2 and
// RS_WhiteMind2 drop it (their one drop; mastermind/RS_Mastermind.zs). It is not
// a pickup: nothing happens on touching it but its damage. On the rig it was
// first built as a Monster (shootable, invulnerable, 6666 health), and so RSQ
// VisualRewards hung a monster health bar on it (rig MV_V1's frame), and being
// shootable it stood in the way of the player's shots. Now it is a plain
// hazard: not a monster, not shootable (rig MV_V2: a shot through it reaches
// the Imp behind it),
// out of the blockmap (nothing can hit it or stand on it). As a drop it is
// tossed up and falls to the floor under its master's body (the engine takes
// NOGRAVITY off a dropped thing; rig MV_V3: z 92, 100, 95, then the floor 24
// by 35 tics). Its pulse is as
// built: A_Explode 8 over 96 every 12 tics (5-6 to a player standing in it;
// monsters in it are hurt too), type DIMp, until a 6-in-256 roll a 12-tic
// cycle ends it (about 15 s on average; 122 to 514 tics on the rig).
// ============================================================================

class RS_CH_VoidOrb : Actor   // RS build -- CH's dangling MASTERMINDS.txt:3883/:4979 drop, hooked up 2026-11-27
{
	Default
	{
		Radius 52;
		Height 52;
		Speed 0;
		FastSpeed 0;
		Damage 0;                  // bare constant stays bare, as VoidField has it
		+NOBLOCKMAP                // a hazard, not a target: no shot, missile or monster meets it, no health bar
		+NOGRAVITY
		+DONTTHRUST
		+NOTELEPORT
		+DONTSPLASH
		+NOTONAUTOMAP
		+DONTHARMSPECIES
		+DONTHARMCLASS
		RenderStyle "Add";
		DamageType "DIMp";         // VoidField's type, so existing resistances apply
		Alpha 0.7;
		Scale 1.9;
		SeeSound "spell/spellcast1";
		DeathSound "spell/Impact1";
	}
	States
	{
	Spawn:
		// Slower, heavier breathing than VoidField's 1-tic flicker: this is a
		// field left on a corpse, not a bubble a live monster is driving.
		BBOM B 3 Bright A_SetScale(1.9);
		BBOM B 3 Bright A_SetScale(1.7);
		BBOM B 3 Bright A_Explode(8,96);
		BBOM B 3 Bright A_SetScale(1.5);
		BBOM B 3 Bright A_Jump(6,"Death");   // ~ 6/256 per cycle: outlives a fight, not the map
		Goto Spawn+1;
	Death:
		BBOM B 4 Bright A_SetScale(1.6);
		BBOM B 4 Bright A_SetScale(1.2);
		BBOM B 4 Bright A_SetScale(0.8);
		BBOM B 4 Bright A_SetScale(0.4);
		Stop;
	}
}

// ============================================================================
// RS_MissileChance (2026-11-16, Monster Assembly): Colourful Hell's
// A_ChangeFlag("MissileMore" / "MissileEvenMore") without the flags, which the
// engine deprecated in 4.13 for the MissileChanceMult property. QuestZDoom 17.3
// keeps the old flags only as a view of MissileChanceMult; these four do exactly
// what writing bMISSILEMORE / bMISSILEEVENMORE does there (measured on the rig,
// every start value: 1, 0.5, 0.125, 0.0625, 0.25), so nothing plays differently.
// ============================================================================
class RS_MissileChance play
{
	static void SetMore(Actor a, bool on)
	{
		if (!a) return;
		if (on) a.MissileChanceMult = (a.MissileChanceMult == 0.125) ? 0.0625 : 0.5;
		else    a.MissileChanceMult = (a.MissileChanceMult == 0.0625) ? 0.125 : 1.0;
	}
	static void SetEvenMore(Actor a, bool on)
	{
		if (!a) return;
		if (on) a.MissileChanceMult = (a.MissileChanceMult == 0.5) ? 0.0625 : 0.125;
		else    a.MissileChanceMult = (a.MissileChanceMult == 0.0625) ? 0.5 : 1.0;
	}
}
