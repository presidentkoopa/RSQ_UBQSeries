// ============================================================================
// RS_CHShared.zs -- Colourful Hell top-level DECORATE.txt: the shared items
// that no family pass picked up.
//
// Source of truth: C:\Users\Command\Desktop\CH\DECORATE.txt (1694 lines, read
// whole, 2026-08-06). That file was never swept: every family pass read
// decorate\*.txt and none read the root DECORATE.txt. 93 actors live there;
// 42 were already imported piecemeal by the zombieman / shotgunner /
// chaingunner lanes and are referenced read-only, never redefined
// (RS_HealthBundle, RS_ArmorBundle, RS_BackPackBundle, RS_DropBaseAmmo and
// its 8 ammo subclasses, RS_DropBaseItem and its 11 item subclasses,
// RS_ColorTierIconCH1-13, RS_ScootDropChecker, RS_implyingclip,
// RS_GrowRaisin, RS_CHBoner, RS_CHAbyssMark -- all in
// zscript/monsters/zombieman/RS_ZombiemanFX.zs and
// zscript/monsters/chaingunner/RS_ChaingunnerFX.zs).
//
// This file holds the 2 genuine leftovers. The other 49 -- CH's dormant
// bonus/ambush event machinery -- are in RS_CHEvents.zs alongside this one.
//
// Conversion rules applied (all from real compile errors on this engine):
//   * ACS gate CallACS("CH_Extras") -> RS_Zom.CV('rs_ch_extradrops', 1),
//     CH's exact value semantics (1 = normal, 2 = rare/translated). Inherited
//     unchanged from RS_DropBaseItem; no new cvar is introduced.
//   * No abstract (it makes actors invisible in this project).
//   * Damage rolls stay rolls -- neither class here has one.
//   * Game "Doom" kept as CH writes it.
//
// TIER: neither class is a tiered monster. No RS_Zom.SetTier, no token.
// CH gives them none.
//
// SOUNDS: CH DECORATE.txt declares ZERO sound properties and ZERO
// A_PlaySound/A_StartSound calls across all 1694 lines (verified by grep for
// SeeSound|DeathSound|PainSound|ActiveSound|AttackSound|MeleeSound|
// BounceSound|HowlSound|A_PlaySound|A_StartSound|SoundName -- no hits).
// Sound denominator for this import is 0/0. No SNDINFO block to report.
// TRNSLATE: CH\TRNSLATE.txt defines only BBEASTEX1-6, CYANCYB01-02,
// YellowRev01 and BRCybGren01-06 -- monster palettes, none referenced by any
// actor in DECORATE.txt. No TRNSLATE block to report.
//
// UNRESOLVED / PROVEN ABSENT IN CH -- see RS_CHEvents.zs header. Nothing in
// this file is unresolved.
// ============================================================================


// ---------------------------------------------------------------------------
// CH: DECORATE.txt:663.  A real, declared CH pickup gate -- the twelfth
// DropBaseItem subclass, and the only one no family pass carried over.
// Dropped by two MASTERMINDS bosses:
//   CH MASTERMINDS.txt:3888  Dropitem "CH_Blursphere"  (Blackmind2)
//   CH MASTERMINDS.txt:4983  Dropitem "CH_Blursphere"  (WhiteMind2)
// Both drop lines are currently commented out in
// zscript/monsters/mastermind/RS_Mastermind.zs (:2401, :2720) because the
// class did not exist. It exists now; restoring those two lines is the
// mastermind lane's call, not this one's -- this file does not touch it.
//
// Base class RS_DropBaseItem is CH DECORATE.txt:407, defined read-only in
// zscript/monsters/zombieman/RS_ZombiemanFX.zs:473.
// ---------------------------------------------------------------------------
class RS_CH_BlurSphere : RS_DropBasePowerup   // CH DECORATE.txt:663
{
	Default
	{
		Mass 5;
		Alpha 0.01;
	}
	States
	{
	Rare:
		TNT1 A 0 A_SpawnItemEx("BlurSphere",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("BlurSphere",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}


// ---------------------------------------------------------------------------
// CH: DECORATE.txt:1004.  The ambush director.
//
// An invulnerable, invisible, noclipping 9999-HP marker that A_Warps itself
// onto its TARGET every few tics and, on a timer, rolls once on CH's bonus
// table and drops the winning seed at the target's feet. It is the thing that
// makes the event system *happen to a player* rather than being placed on a
// map. Its outcomes all live in RS_CHEvents.zs.
//
// DORMANT IN CH AND KEPT DORMANT HERE. "CH_BadItch" appears exactly once in
// the whole of CH -- its own definition line. No `replaces`, no ACS call in
// CHACS.acs / CHSett.acs / Announcers.acs / commonFuncs.acs / mathFuncs.acs /
// miscFuncs.acs, no map hook, no other DECORATE reference. Nothing spawns it.
// That dormancy is faithful and is preserved: no replaces, no EventHandler,
// no spawner hook, no cvar gate has been added. The owner designs the trigger.
//
// To fire it by hand: spawn RS_CH_BadItch with SXF_SETTARGET pointing at the
// actor it should follow (it warps to AAPTR_TARGET; with no target the warps
// no-op and it idles harmlessly forever).
//
// Roll order in Stick, exactly as CH wrote it -- each A_Jump is rolled in
// sequence, so the earlier ones dominate:
//   32/256  -> PackCommon (one vanilla-named single monster)
//   12/256  -> Boon or PackCommon
//   12/256  -> one of Pack1,2,6..12, Boon, PackCommon   (the 9 enemy packs)
//    6/256  -> one of Pack3,4,5, Boon, PackMisc10       (the 4 misc events)
//   else    -> loop and roll again next tic
// then CoolDown, a ~1500-tic ladder of escalating re-entry chances.
// ---------------------------------------------------------------------------
class RS_CH_BadItch : Actor   // CH DECORATE.txt:1004
{
	Default
	{
		Health 9999;
		Monster;
		Radius 2;
		Height 2;
		+NOGRAVITY
		+SPAWNFLOAT
		+NOTRIGGER
		+NOTELEPORT
		+NEVERTARGET
		+NOTARGETSWITCH
		+NOINFIGHTING
		-ACTIVATEMCROSS
		-COUNTKILL
		+INVULNERABLE
		+NOCLIP
		+NOTONAUTOMAP
		+LOOKALLAROUND
		+INVISIBLE
		+THRUACTORS
		RenderStyle "Add";
		Speed 6;
		FloatSpeed 6;
		Scale 0.4;
		Alpha 0.95;
		Mass 2;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto See;
	See:
		TNT1 A 1;
		Goto Stick;
	Stick:
		TNT1 A 1 A_Warp(AAPTR_TARGET,random(-3,3),random(-3,3),24,random(0,359),WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 15;
		TNT1 A 1 A_Warp(AAPTR_TARGET,random(-3,3),random(-3,3),24,random(0,359),WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 1 A_Jump(32,"PackCommon");
		TNT1 A 1 A_Jump(12,"Boon","PackCommon");
		TNT1 A 1 A_Jump(12,"Pack1","Pack2","Pack6","Pack7","Pack8","Pack9","Pack10","Pack11","Pack12","Boon","PackCommon");
		TNT1 A 0 A_Jump(6,"Pack3","Pack4","Pack5","Boon","PackMisc10");
		Loop;
	Boon:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusBoon",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	Pack1:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemy1",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	Pack2:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemy2",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	Pack6:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemy3",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	Pack7:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemy4",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	Pack8:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemy5",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	Pack9:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemy6",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	Pack10:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemy7",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	Pack11:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemy8",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	Pack12:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemy9",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	Pack3:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusMisc1",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	Pack4:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusMisc2",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	Pack5:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusMisc3",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	PackMisc10:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusMisc4",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	PackCommon:
		TNT1 A 0 A_SpawnItemEx("RS_Mon_BonusEnemySingle",0,0,0,random(77,120),0,random(-25,25),random(0,360),SXF_NOCHECKPOSITION);
		Goto CoolDown;
	CoolDown:
		TNT1 A 150;
		TNT1 A 1 A_Jump(4,"Stick");
		TNT1 A 150;
		TNT1 A 1 A_Warp(AAPTR_TARGET,random(-3,3),random(-3,3),24,random(0,359),WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 150;
		TNT1 A 1 A_Jump(8,"Stick");
		TNT1 A 150;
		TNT1 A 1 A_Warp(AAPTR_TARGET,random(-3,3),random(-3,3),24,random(0,359),WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 150;
		TNT1 A 1 A_Jump(12,"Stick");
		TNT1 A 150;
		TNT1 A 1 A_Jump(16,"Stick");
		TNT1 A 1 A_Warp(AAPTR_TARGET,random(-3,3),random(-3,3),24,random(0,359),WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 150;
		TNT1 A 1 A_Jump(24,"Stick");
		TNT1 A 150;
		TNT1 A 1 A_Jump(42,"Stick");
		TNT1 A 1 A_Warp(AAPTR_TARGET,random(-3,3),random(-3,3),24,random(0,359),WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 150;
		TNT1 A 1 A_Jump(58,"Stick");
		TNT1 A 150;
		TNT1 A 1 A_Warp(AAPTR_TARGET,random(-3,3),random(-3,3),24,random(0,359),WARPF_ABSOLUTEANGLE|WARPF_NOCHECKPOSITION|WARPF_INTERPOLATE);
		TNT1 A 1 A_Jump(78,"Stick");
		TNT1 A 150;
		Goto Stick;
	}
}

// ============================================================================
// PER-CATEGORY DROP GATES -- an RS addition, 2026-08-06, at the owner's
// request: "dropping weapons or powerups or shit, i want control over".
//
// CH lumps EVERY non-ammo pickup under one switch. RS_DropBaseItem's Scripted
// state reads CH_Extras (rs_ch_extradrops) and dispatches to First / Rare /
// Last, and all twelve item pickups -- weapons, spheres, armour, medikit --
// inherit that one decision. So in CH you cannot turn off dropped BFGs while
// keeping dropped soulspheres.
//
// These three classes split that decision without touching a single DropItem
// line. Each subclasses RS_DropBaseItem and overrides ONLY the Scripted state
// to read its own cvar; Rare / First stay whatever the pickup itself defines,
// and Last (drop nothing) is inherited. Re-parenting a pickup from
// RS_DropBaseItem to one of these is a one-word edit at the class line and
// changes every drop site that names it, across all seventeen families at once.
//
// Value semantics are CH's, deliberately, so the whole set reads alike:
//     1 = normal   2 = rare (the pickup's own reduced-chance branch)
//     anything else (0) = off, via the inherited Last state
// All three default to 1, so out of the box behaviour is IDENTICAL to CH's
// and to what this repo shipped before -- nothing changes until a player
// opts in from the menu.
//
// Ammo, health and backpacks are NOT here: CH already gates those separately
// (rs_ch_ammodrops via RS_DropBaseAmmo, rs_ch_healthdrops, rs_ch_backpackdrops)
// and those gates are honoured untouched. rs_ch_extradrops survives as the
// gate for anything still parented to RS_DropBaseItem -- currently the medikit.
// ============================================================================

class RS_DropBaseWeapon : RS_DropBaseItem   // RS addition -- gates dropped weapons
{
	States
	{
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_weapondrops', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_weapondrops', 1) == 2, "Rare");
		Goto Last;
	}
}

class RS_DropBasePowerup : RS_DropBaseItem   // RS addition -- gates spheres and berserk
{
	States
	{
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_powerupdrops', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_powerupdrops', 1) == 2, "Rare");
		Goto Last;
	}
}

class RS_DropBaseArmor : RS_DropBaseItem   // RS addition -- gates dropped armour
{
	States
	{
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_armordrops', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_armordrops', 1) == 2, "Rare");
		Goto Last;
	}
}

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
// Not a tiered monster: no RS_Zom.SetTier, no token, -COUNTKILL so it cannot
// inflate the map's kill total or block a 100% clear.
// ============================================================================

class RS_CH_VoidOrb : Actor   // RS build -- fills CH's dangling MASTERMINDS.txt:3883/:4979 drop
{
	Default
	{
		Radius 52;
		Height 52;
		Health 6666;
		Speed 0;
		FastSpeed 0;
		Damage 0;                  // bare constant stays bare, as VoidField has it
		Monster;
		+INVULNERABLE
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+NOTARGET
		+NOGRAVITY
		+DONTTHRUST
		-COUNTKILL
		-SOLID
		-CANPUSHWALLS
		-CANUSEWALLS
		-ACTIVATEMCROSS
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
