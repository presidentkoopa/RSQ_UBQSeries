// =====================================================================
// RS_MonsterCommands -- CH/CHP's pack-buff ACS, rebuilt in ZScript.
//
// WHY THIS FILE EXISTS. CH and CHP express several monster mechanics as
// an Inventory token whose entire DECORATE body is one
// ACS_NamedExecuteAlways(...) call. The monster import read those empty
// bodies and dropped the tokens on the reasoning that "porting them
// would import nothing." The body is empty BECAUSE the behaviour lives
// in the ACS script -- so dropping the token dropped the mechanic, and
// because the DECORATE really does look empty the loss was invisible at
// every call site. See docs/rs_19_acs_inventory.txt for the full audit.
//
// This file rebuilds the PACK BUFF family: the four scripts a "brown
// tier" leader throws at its neighbours to make the pack genuinely
// harder. Sources read verbatim from CH/source/CHSett.acs and
// CHP/source/CHSett2.acs (identical bodies -- CHP is a copy of CH).
//
//   CH script          property        value      duration  fast  thrust
//   PESPEED            APROP_SPEED     normal+10   600t     yes   no
//   BrownImpCommand    APROP_SPEED     normal+10   180t     yes   yes
//   BrownVileCommand   APROP_DamageFac 0.65        300t     no    yes
//   BrownMindCommand   APROP_DamageFac 0.50        300t     yes   yes
//
// APROP_DamageFactor scales damage RECEIVED, so the last two are damage
// RESISTANCE auras (0.50 = takes half), not damage buffs.
//
// THREE DELIBERATE DIVERGENCES FROM CH, each fixing a bug in the
// original rather than reproducing it:
//
//  1. CH's re-entrancy guard does not work. Every one of these scripts
//     opens `int Nope;` as a SCRIPT-LOCAL, which is zero-initialised on
//     every invocation, so the `if (Nope == 0)` test always passes. Two
//     overlapping casts therefore both read the ALREADY-BUFFED value as
//     `Normal` and the monster's base speed permanently drifts upward.
//     A Powerup cannot do this: InitEffect runs once on attach, the
//     saved value is captured once, and a re-cast renews the timer
//     instead of re-reading. This is why the rebuild is a Powerup and
//     not a Thinker imitating the script.
//
//  2. CH clears ALWAYSFAST unconditionally when the buff ends, so a
//     monster that was NATIVELY ALWAYSFAST loses the flag permanently
//     the first time it is buffed. We track whether WE set it and only
//     clear it if we did.
//
//  3. CH restores the property to a captured absolute. If the monster's
//     speed legitimately changed during the buff (a tier promotion, say)
//     that change is stomped. We restore by DELTA for speed, so an
//     unrelated change survives.
//
// Boss exemption is CH's, kept exactly: `if (CheckFlag(0,"BOSS"))
// Terminate;`. Bosses refuse these outright.
// =====================================================================

// ---------------------------------------------------------------------
// THE JOSTLE. CH follows every *Command with
//   ThrustThing (random(0,255), random(1,12), 0, 0)
//   ThrustThingZ(0, random(1,12), random(0,1), 0)
// which physically flings the recipient in a random direction -- the
// visible "the pack just got shouted at" tell. Scale is APPROXIMATE
// (Hexen's 1/8 and 1/4 unit conventions) and is flavour, not damage, so
// getting it slightly wrong costs feel rather than balance.
//
// NOTE ON SHAPE: this is duplicated as a method on both base classes
// below rather than living once on a shared helper. That is deliberate.
// A static helper on a plain Object has NO precedent in this tree for
// calling random() -- and this repo's history is a list of constructs
// that looked obviously fine and did not resolve (`static const T
// name[]`, `extend class PlayerPawn`, `Damage (random(a,b))` in a
// Default). Powerup descends from Actor, where random() is certainly in
// scope. Six duplicated lines is a cheaper bet than a novel one, and
// RS_PowerPackGuard cannot share a base with RS_PowerPackHaste anyway:
// it must descend from PowerProtection, which is Powerup's own subclass.

// ---------------------------------------------------------------------
// HASTE -- the +10 ADDITIVE speed line (PESPEED, BrownImpCommand).
//
// Additive, not multiplicative, and that is the whole character of it:
// PowerSpeed multiplies, so it would scale with the recipient. CH adds a
// flat +10, which takes a Zombieman from 8 to 18 (+125%) and a
// Cyberdemon from 16 to 26 (+62%). The buff deliberately does more for
// the weak half of the pack. Do NOT "simplify" this to PowerSpeed.
// ---------------------------------------------------------------------
class RS_PowerPackHaste : Powerup
{
	double savedSpeed;
	bool   weSetFast;
	bool   applied;
	bool   doJostle;

	// CH: ThrustThing(random(0,255), random(1,12), 0, 0)
	//     ThrustThingZ(0, random(1,12), random(0,1), 0)
	// Scale is the Hexen 1/8 and 1/4 unit convention and is APPROXIMATE
	// -- one edit here corrects the feel after first boot.
	void JostleOwner()
	{
		if (!Owner) return;
		// Vel.X/Y math rather than Thrust(): this tree has three working
		// examples of the former (RS_Mancubus.zs:390, RS_human_projectiles
		// .zs:126) and ZERO callers of the latter. Proven beats tidy.
		double ang = random(0, 255) * (360.0 / 256.0);  // BYTE angle
		double f   = random(1, 12) * 0.125;
		Owner.Vel.X += f * cos(ang);
		Owner.Vel.Y += f * sin(ang);
		double zf = random(1, 12) * 0.25;
		Owner.Vel.Z += (random(0, 1) == 0) ? zf : -zf;
	}

	Default
	{
		Powerup.Duration 600;        // positive = TICS. CH: Delay(600).
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.NOSCREENBLINK
		+INVENTORY.UNDROPPABLE
		-INVENTORY.INVBAR
	}

	// CH: `if (CheckFlag(0,"BOSS")) Terminate;` -- refuse the item
	// outright rather than attach an inert one.
	override bool TryPickup(in out Actor toucher)
	{
		if (!toucher || toucher.bBOSS || !toucher.bISMONSTER)
			return false;
		return Super.TryPickup(toucher);
	}

	override void InitEffect()
	{
		Super.InitEffect();
		if (!Owner || Owner.bBOSS)
			return;

		savedSpeed = Owner.Speed;
		Owner.Speed = savedSpeed + 10;

		// Divergence 2: only claim the flag if it was not already set,
		// so EndEffect cannot strip a natively-fast monster's own flag.
		if (!Owner.bALWAYSFAST)
		{
			Owner.bALWAYSFAST = true;
			weSetFast = true;
		}

		applied = true;

		if (doJostle)
			JostleOwner();
	}

	override void EndEffect()
	{
		if (applied && Owner)
		{
			// Divergence 3: restore by delta, so a speed change from
			// something else during the buff is not stomped.
			// 0.0 not 0 -- Speed is a double, and a mixed int/double max()
			// is the kind of thing this engine build rejects.
			Owner.Speed = max(0.0, Owner.Speed - 10.0);
			if (weSetFast)
				Owner.bALWAYSFAST = false;
		}
		applied = false;
		Super.EndEffect();
	}
}

// CH: PESPEED. The Abyss Cacodemon's pack haste -- 600 tics, no jostle.
class RS_PESpeedBuff : RS_PowerPackHaste
{
	Default { Powerup.Duration 600; }
}

// CH: BrownImpCommand. Shorter (180t) but adds the physical shove.
class RS_BrownImpCommand : RS_PowerPackHaste
{
	Default { Powerup.Duration 180; }
	override void InitEffect() { doJostle = true; Super.InitEffect(); }
}

// ---------------------------------------------------------------------
// THE REVENANT LINE -- CH's BrownRevSPEED2, whose own author labelled it
// "//THIS SCRIPT CAN GO BURN IN HELL!!!" and was not wrong.
//
// WHAT IT ACTUALLY DOES, once the machinery is stripped: DOUBLE the
// target's speed for 210 tics, then put it back. That is the whole
// mechanic. Everything else in those 45 lines exists to emulate, in ACS,
// what a Powerup gives you for free:
//   * RevSpeedBuff2 / RevSpeedBuff3 are not items, they are BOOLEANS --
//     token inventory used to record "is the buff running".
//   * the NOSKIN actor flag is ALSO abused as a second such boolean,
//     because the first pair could not be made reliable.
//   * every "SetActorProperty(SPEED, Normal / 2)" branch is the UNDO
//     path: `Normal` is read at script entry, so on an already-doubled
//     monster, halving is what restores it. It reads like a penalty and
//     is actually a restore.
//   * `Nope` is a script-local, zero on every entry, so the guard it
//     looks like it provides does not exist -- same defect as the other
//     four scripts in this file.
// A Powerup renews its timer on re-application and runs EndEffect once,
// which is precisely the behaviour all of that was reaching for.
//
// NO BOSS EXEMPTION, deliberately: unlike PESPEED and the *Command
// scripts, BrownRevSPEED2 has no CheckFlag(0,"BOSS") guard. Matched.
// ---------------------------------------------------------------------
class RS_RevSpeedBuff : Powerup
{
	bool applied;

	Default
	{
		Powerup.Duration 210;        // CH: Delay(210).
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.NOSCREENBLINK
		+INVENTORY.UNDROPPABLE
		-INVENTORY.INVBAR
	}

	override bool TryPickup(in out Actor toucher)
	{
		if (!toucher || !toucher.bISMONSTER)
			return false;
		return Super.TryPickup(toucher);
	}

	override void InitEffect()
	{
		Super.InitEffect();
		if (!Owner)
			return;
		Owner.Speed *= 2.0;
		applied = true;
	}

	override void EndEffect()
	{
		// Halve rather than restore a captured absolute -- CH's own undo
		// path, and it means a speed change from anything else during the
		// buff survives instead of being stomped.
		if (applied && Owner)
			Owner.Speed *= 0.5;
		applied = false;
		Super.EndEffect();
	}
}

// ---------------------------------------------------------------------
// GUARD -- the DamageFactor line (BrownVileCommand, BrownMindCommand).
//
// PowerProtection already models "scale damage received" and this repo
// already leans on it the same way -- RS_WVileResist (DamageFactor 0.5)
// and RS_HKEXProtect (0.6) are both PowerProtection subclasses with the
// factor set in Default. Same shape here, so nothing new is invented.
// ---------------------------------------------------------------------
class RS_PowerPackGuard : PowerProtection
{
	bool weSetFast;
	bool wantFast;
	bool doJostle;
	bool applied;

	// Same six lines as RS_PowerPackHaste.JostleOwner -- see the note
	// above that class for why this is duplicated rather than shared.
	void JostleOwner()
	{
		if (!Owner) return;
		// Vel.X/Y math rather than Thrust(): this tree has three working
		// examples of the former (RS_Mancubus.zs:390, RS_human_projectiles
		// .zs:126) and ZERO callers of the latter. Proven beats tidy.
		double ang = random(0, 255) * (360.0 / 256.0);  // BYTE angle
		double f   = random(1, 12) * 0.125;
		Owner.Vel.X += f * cos(ang);
		Owner.Vel.Y += f * sin(ang);
		double zf = random(1, 12) * 0.25;
		Owner.Vel.Z += (random(0, 1) == 0) ? zf : -zf;
	}

	Default
	{
		Powerup.Duration 300;        // CH: Delay(300).
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.NOSCREENBLINK
		+INVENTORY.UNDROPPABLE
		-INVENTORY.INVBAR
	}

	override bool TryPickup(in out Actor toucher)
	{
		if (!toucher || toucher.bBOSS || !toucher.bISMONSTER)
			return false;
		return Super.TryPickup(toucher);
	}

	override void InitEffect()
	{
		Super.InitEffect();
		if (!Owner || Owner.bBOSS)
			return;

		if (wantFast && !Owner.bALWAYSFAST)
		{
			Owner.bALWAYSFAST = true;
			weSetFast = true;
		}

		applied = true;

		if (doJostle)
			JostleOwner();
	}

	override void EndEffect()
	{
		if (applied && Owner && weSetFast)
			Owner.bALWAYSFAST = false;
		applied = false;
		Super.EndEffect();
	}
}

// CH: BrownVileCommand -- 0.65 damage taken, 300 tics, jostle, NO
// ALWAYSFAST (the only one of the four that does not set it).
class RS_BrownVileCommand : RS_PowerPackGuard
{
	Default { DamageFactor 0.65; Powerup.Duration 300; }
	override void InitEffect() { doJostle = true; wantFast = false; Super.InitEffect(); }
}

// CH: BrownMindCommand -- 0.50 damage taken, 300 tics, jostle AND
// ALWAYSFAST. The hardest of the four: half damage on the whole pack.
class RS_BrownMindCommand : RS_PowerPackGuard
{
	Default { DamageFactor 0.50; Powerup.Duration 300; }
	override void InitEffect() { doJostle = true; wantFast = true; Super.InitEffect(); }
}

// ---------------------------------------------------------------------
// THE PAIN ELEMENTAL LINE -- PERAGE and PEHULK, CHSett2.acs:492 and :551.
// One offensive, one defensive, both 600 tics, both boss-exempt.
//
// MIND THE TWO DIFFERENT DAMAGE PROPERTIES -- they are easy to confuse
// and they point in opposite directions:
//   APROP_DamageMultiplier -> Actor.DamageMultiply -- damage DEALT.
//                             PERAGE sets 1.5: hits 50% HARDER.
//   APROP_DamageFactor     -> Actor.DamageFactor   -- damage RECEIVED.
//                             PEHULK sets 0.25: takes 75% LESS.
// Reading either as "damage" and picking the wrong one silently inverts
// the buff, so both are spelled out here.
// ---------------------------------------------------------------------

// CH: PERAGE. +50% damage dealt and immunity to pain stagger, 600 tics.
// NOPAIN is the interesting half: a raging PE cannot be flinch-locked,
// which is what makes the rage read as rage rather than as a number.
class RS_PERage : Powerup
{
	bool weSetNoPain;
	bool applied;

	Default
	{
		Powerup.Duration 600;        // CH: Delay(600).
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.NOSCREENBLINK
		+INVENTORY.UNDROPPABLE
		-INVENTORY.INVBAR
	}

	override bool TryPickup(in out Actor toucher)
	{
		if (!toucher || toucher.bBOSS || !toucher.bISMONSTER)
			return false;
		return Super.TryPickup(toucher);
	}

	override void InitEffect()
	{
		Super.InitEffect();
		if (!Owner || Owner.bBOSS)
			return;

		Owner.DamageMultiply *= 1.5;

		if (!Owner.bNOPAIN)
		{
			Owner.bNOPAIN = true;
			weSetNoPain = true;
		}
		applied = true;
	}

	override void EndEffect()
	{
		if (applied && Owner)
		{
			Owner.DamageMultiply /= 1.5;
			if (weSetNoPain)
				Owner.bNOPAIN = false;
		}
		applied = false;
		Super.EndEffect();
	}
}

// CH: PEHULK. Quarter damage taken for 600 tics, plus three flags.
// NOTE CH CLEARS NoDropOff rather than setting it -- the hulked PE is
// allowed to walk off ledges it would normally refuse. That asymmetry is
// deliberate and is preserved; it is not a transcription slip.
class RS_PEHulk : PowerProtection
{
	bool setRetaliate, setDontThrust, clearedNoDropOff;
	bool applied;

	Default
	{
		DamageFactor 0.25;           // CH: APROP_DAMAGEFACTOR 0.25.
		Powerup.Duration 600;
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.NOSCREENBLINK
		+INVENTORY.UNDROPPABLE
		-INVENTORY.INVBAR
	}

	override bool TryPickup(in out Actor toucher)
	{
		if (!toucher || toucher.bBOSS || !toucher.bISMONSTER)
			return false;
		return Super.TryPickup(toucher);
	}

	override void InitEffect()
	{
		Super.InitEffect();
		if (!Owner || Owner.bBOSS)
			return;

		if (!Owner.bQUICKTORETALIATE) { Owner.bQUICKTORETALIATE = true;  setRetaliate     = true; }
		if (!Owner.bDONTTHRUST)       { Owner.bDONTTHRUST       = true;  setDontThrust    = true; }
		if (Owner.bNODROPOFF)         { Owner.bNODROPOFF        = false; clearedNoDropOff = true; }
		applied = true;
	}

	override void EndEffect()
	{
		// Only undo what we actually changed -- the same correction made
		// to ALWAYSFAST at the top of this file, for the same reason.
		if (applied && Owner)
		{
			if (setRetaliate)     Owner.bQUICKTORETALIATE = false;
			if (setDontThrust)    Owner.bDONTTHRUST       = false;
			if (clearedNoDropOff) Owner.bNODROPOFF        = true;
		}
		applied = false;
		Super.EndEffect();
	}
}
