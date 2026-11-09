// ============================================================================
// RS_Retier -- tier changes at runtime for the CH-rebuild monster families.
//
// WHY. RS_MonsterMaster owns a Tier field and rescales a monster in place, and
// its own header records the problem: "NOTHING HAS EVER ASSIGNED A SPAWN TIER
// ... the ONLY way anyone has ever seen any of it is the debug menu", and
// "Under the CH rebuild each creature is its own class, so the dial picks a
// CLASS, not a ladder position."
//
// Exactly one class ever inherited RS_MonsterMaster (RS_Chaingunner), so the
// two sites that retier -- RS_MonsterCatalog's portal and RS_Elites -- cast to
// RS_MonsterMaster, get null for every rebuilt monster, and skip the retier in
// silence. Nothing errors; nothing happens.
//
// So a retier here SWAPS THE CLASS rather than rescaling a field, because that
// is what a tier already means in the rebuilt design: tier 4 of the zombieman
// family IS RS_PurpleZombie. Health, speed, flags, sprites and attacks arrive
// with it -- they are that class's own.
//
// THE LADDER IS NOT TYPED IN. It was recovered from the tree: every colour
// states its tier in PostBeginPlay (RS_Zom.SetTier(self, N)), the dial lists
// which colours a family has, and the cvar gates plus one inherited tier
// (RS_FireBluSpectre2 : RS_FireBluDemon2) were followed to the class that
// states the number. 17 families, 13 tiers, no gaps.
//
//   1 Common  2 Green  3 Blue   4 Purple  5 Yellow  6 Red     7 FireBlu
//   8 Gray    9 Abyss  10 Black 11 White  12 Cyan   13 Brown
//
// Generated tables are if-chains, not arrays: this tree records that array
// literals do not resolve reliably on this build. FamilyOf/TierOf are LOOPS
// over those tables rather than 340 more comparisons -- written flat, they
// exceeded the VM register limit and would not compile.
// ============================================================================

class RS_TierLadder
{
	static int FamilyCount() { return 17; }
	static int MaxTier()     { return 13; }

	static Name DialOf(int fam)
	{
		if (fam == 0) return 'RS_ChaingunnerColourset';
		if (fam == 1) return 'RS_Colourset1';
		if (fam == 2) return 'RS_Colourset10';
		if (fam == 3) return 'RS_Colourset11';
		if (fam == 4) return 'RS_Colourset13';
		if (fam == 5) return 'RS_Colourset14';
		if (fam == 6) return 'RS_Colourset15';
		if (fam == 7) return 'RS_Colourset16';
		if (fam == 8) return 'RS_Colourset17';
		if (fam == 9) return 'RS_Colourset5';
		if (fam == 10) return 'RS_Colourset7';
		if (fam == 11) return 'RS_Colourset8';
		if (fam == 12) return 'RS_Colourset9';
		if (fam == 13) return 'RS_ImpColourset';
		if (fam == 14) return 'RS_ShotgunnerColourset';
		if (fam == 15) return 'RS_SpectreColourset';
		if (fam == 16) return 'RS_ZombieColourset';
		return 'None';
	}

	// The class to BECOME. Never the cvar gate: spawning a gate re-rolls the
	// colour dice and can land back on the whole dial.
	static Name ClassFor(int fam, int tier)
	{
		if (fam == 0)
		{
			if (tier == 1) return 'RS_CommonCGuy';
			if (tier == 2) return 'RS_GreenCGuy';
			if (tier == 3) return 'RS_BlueCGuy';
			if (tier == 4) return 'RS_PurpleCGuy';
			if (tier == 5) return 'RS_YellowCGuy';
			if (tier == 6) return 'RS_RedCGuy';
			if (tier == 7) return 'RS_FireBluCGuy2';
			if (tier == 8) return 'RS_GrayCGuy2';
			if (tier == 9) return 'RS_AbyssCGuy2';
			if (tier == 10) return 'RS_BlackCGuy2';
			if (tier == 11) return 'RS_WhiteCguy2';
			if (tier == 12) return 'RS_CyanCGuy2';
			if (tier == 13) return 'RS_BrownCGuy2';
			return 'None';
		}
		if (fam == 1)
		{
			if (tier == 1) return 'RS_CommonRevenant';
			if (tier == 2) return 'RS_GreenRevenant';
			if (tier == 3) return 'RS_BlueRevenant';
			if (tier == 4) return 'RS_PurpleRevenant';
			if (tier == 5) return 'RS_YellowRevenant';
			if (tier == 6) return 'RS_RedRevenant';
			if (tier == 7) return 'RS_FireBluRevenant2';
			if (tier == 8) return 'RS_GrayRevenant2';
			if (tier == 9) return 'RS_AbyssRevenant2';
			if (tier == 10) return 'RS_BlackRevenant3';
			if (tier == 11) return 'RS_WhiteRevenant2';
			if (tier == 12) return 'RS_CyanRevenant2';
			if (tier == 13) return 'RS_BrownRevenant2';
			return 'None';
		}
		if (fam == 2)
		{
			if (tier == 1) return 'RS_CommonFatso';
			if (tier == 2) return 'RS_GreenFatso';
			if (tier == 3) return 'RS_BlueFatso';
			if (tier == 4) return 'RS_PurpleFatso';
			if (tier == 5) return 'RS_YellowFatso';
			if (tier == 6) return 'RS_RedFatso';
			if (tier == 7) return 'RS_FireBluFatso2';
			if (tier == 8) return 'RS_GrayFatso2';
			if (tier == 9) return 'RS_AbyssFatso2';
			if (tier == 10) return 'RS_BlackFatso2';
			if (tier == 11) return 'RS_WhiteFatso2';
			if (tier == 12) return 'RS_CyanFatso2';
			if (tier == 13) return 'RS_BrownFatso2';
			return 'None';
		}
		if (fam == 3)
		{
			if (tier == 1) return 'RS_CommonArch';
			if (tier == 2) return 'RS_GreenArch';
			if (tier == 3) return 'RS_BlueArch';
			if (tier == 4) return 'RS_PurpleArch';
			if (tier == 5) return 'RS_YellowArch';
			if (tier == 6) return 'RS_RedArch3';
			if (tier == 7) return 'RS_FireBluArch2';
			if (tier == 8) return 'RS_GrayArch2';
			if (tier == 9) return 'RS_AbyssVile';
			if (tier == 10) return 'RS_BlackVile';
			if (tier == 11) return 'RS_Whitevile';
			if (tier == 12) return 'RS_CyanVile';
			if (tier == 13) return 'RS_BrownVile';
			return 'None';
		}
		if (fam == 4)
		{
			if (tier == 1) return 'RS_CommonBaron';
			if (tier == 2) return 'RS_GreenBaron';
			if (tier == 3) return 'RS_BlueBaron';
			if (tier == 4) return 'RS_PurpleBaron';
			if (tier == 5) return 'RS_YellowBaron';
			if (tier == 6) return 'RS_RedBaron3';
			if (tier == 7) return 'RS_FireBluBaron2';
			if (tier == 8) return 'RS_GrayBaron2';
			if (tier == 9) return 'RS_AbyssBaron2';
			if (tier == 10) return 'RS_BlackBaron2';
			if (tier == 11) return 'RS_WhiteBaron2';
			if (tier == 12) return 'RS_CyanBaron2';
			if (tier == 13) return 'RS_BrownBaron2';
			return 'None';
		}
		if (fam == 5)
		{
			if (tier == 1) return 'RS_CommonLSoul';
			if (tier == 2) return 'RS_GreenLSoul';
			if (tier == 3) return 'RS_BlueLSoul';
			if (tier == 4) return 'RS_PurpleLSoul';
			if (tier == 5) return 'RS_YellowLSoul';
			if (tier == 6) return 'RS_RedLSoul';
			if (tier == 7) return 'RS_FireBluLSoul2';
			if (tier == 8) return 'RS_GrayLSoul2';
			if (tier == 9) return 'RS_AbyssLSoul2';
			if (tier == 10) return 'RS_BlackLSoul3';
			if (tier == 11) return 'RS_WhiteLSoul2';
			if (tier == 12) return 'RS_CyanLSoul2';
			if (tier == 13) return 'RS_BrownLSoul2';
			return 'None';
		}
		if (fam == 6)
		{
			if (tier == 1) return 'RS_CommonPE';
			if (tier == 2) return 'RS_GreenPE';
			if (tier == 3) return 'RS_BluePE';
			if (tier == 4) return 'RS_PurplePE';
			if (tier == 5) return 'RS_YellowPE';
			if (tier == 6) return 'RS_RedPE';
			if (tier == 7) return 'RS_FireBluPE2';
			if (tier == 8) return 'RS_GrayPE2';
			if (tier == 9) return 'RS_AbyssPE2';
			if (tier == 10) return 'RS_BlackPE2';
			if (tier == 11) return 'RS_WhitePE2';
			if (tier == 12) return 'RS_CyanPE2';
			if (tier == 13) return 'RS_BrownPE2';
			return 'None';
		}
		if (fam == 7)
		{
			if (tier == 1) return 'RS_CommonCybie';
			if (tier == 2) return 'RS_GreenCybie';
			if (tier == 3) return 'RS_BlueCybie';
			if (tier == 4) return 'RS_PurpleCybie';
			if (tier == 5) return 'RS_YellowCybie';
			if (tier == 6) return 'RS_RedCybie';
			if (tier == 7) return 'RS_FireBluCybie2';
			if (tier == 8) return 'RS_GrayCybie2';
			if (tier == 9) return 'RS_AbyssCybie2';
			if (tier == 10) return 'RS_BlackCybie2';
			if (tier == 11) return 'RS_WhiteCybie2';
			if (tier == 12) return 'RS_CyanCybie2';
			if (tier == 13) return 'RS_BrownCybie2';
			return 'None';
		}
		if (fam == 8)
		{
			if (tier == 1) return 'RS_CommonMind';
			if (tier == 2) return 'RS_GreenMind';
			if (tier == 3) return 'RS_BlueMind';
			if (tier == 4) return 'RS_PurpleMind';
			if (tier == 5) return 'RS_YellowMind';
			if (tier == 6) return 'RS_RedMind';
			if (tier == 7) return 'RS_FireBluMind2';
			if (tier == 8) return 'RS_GrayMind2';
			if (tier == 9) return 'RS_AbyssMind2';
			if (tier == 10) return 'RS_BlackMind2';
			if (tier == 11) return 'RS_WhiteMind2';
			if (tier == 12) return 'RS_CyanMind2';
			if (tier == 13) return 'RS_BrownMind2';
			return 'None';
		}
		if (fam == 9)
		{
			if (tier == 1) return 'RS_CommonDemon';
			if (tier == 2) return 'RS_GreenDemon';
			if (tier == 3) return 'RS_BlueDemon';
			if (tier == 4) return 'RS_PurpleDemon';
			if (tier == 5) return 'RS_YellowDemon';
			if (tier == 6) return 'RS_RedDemon';
			if (tier == 7) return 'RS_FireBluDemon2';
			if (tier == 8) return 'RS_GreyDemon2';
			if (tier == 9) return 'RS_AbyssDemon2';
			if (tier == 10) return 'RS_BlackDemon3';
			if (tier == 11) return 'RS_WhiteDemon2';
			if (tier == 12) return 'RS_CyanDemon2';
			if (tier == 13) return 'RS_BrownDemon2';
			return 'None';
		}
		if (fam == 10)
		{
			if (tier == 1) return 'RS_CommonCaco';
			if (tier == 2) return 'RS_GreenCaco';
			if (tier == 3) return 'RS_BlueCaco';
			if (tier == 4) return 'RS_PurpleCaco';
			if (tier == 5) return 'RS_YellowCaco';
			if (tier == 6) return 'RS_RedCaco';
			if (tier == 7) return 'RS_FireBluCaco2';
			if (tier == 8) return 'RS_GrayCaco2';
			if (tier == 9) return 'RS_AbyssCaco2';
			if (tier == 10) return 'RS_BlackCaco2';
			if (tier == 11) return 'RS_WhiteCaco2';
			if (tier == 12) return 'RS_CyanCaco2';
			if (tier == 13) return 'RS_BrownCaco2';
			return 'None';
		}
		if (fam == 11)
		{
			if (tier == 1) return 'RS_CommonHK';
			if (tier == 2) return 'RS_GreenHK';
			if (tier == 3) return 'RS_BlueHK';
			if (tier == 4) return 'RS_PurpleHK';
			if (tier == 5) return 'RS_YellowHK';
			if (tier == 6) return 'RS_RedHK';
			if (tier == 7) return 'RS_FireBluHK2';
			if (tier == 8) return 'RS_GrayHK2';
			if (tier == 9) return 'RS_AbyssHK2';
			if (tier == 10) return 'RS_BlackHK2';
			if (tier == 11) return 'RS_WhiteHK3';
			if (tier == 12) return 'RS_CyanHK2';
			if (tier == 13) return 'RS_BrownHK2';
			return 'None';
		}
		if (fam == 12)
		{
			if (tier == 1) return 'RS_CommonSP1';
			if (tier == 2) return 'RS_GreenSP1';
			if (tier == 3) return 'RS_BlueSP1';
			if (tier == 4) return 'RS_PurpleSP1';
			if (tier == 5) return 'RS_YellowSP1';
			if (tier == 6) return 'RS_RedSP1';
			if (tier == 7) return 'RS_FireBluSP2';
			if (tier == 8) return 'RS_GraySP2';
			if (tier == 9) return 'RS_AbyssSP2';
			if (tier == 10) return 'RS_BlackSP2';
			if (tier == 11) return 'RS_WhiteSP11';
			if (tier == 12) return 'RS_CyanSP2';
			if (tier == 13) return 'RS_BrownSP2';
			return 'None';
		}
		if (fam == 13)
		{
			if (tier == 1) return 'RS_CommonImp';
			if (tier == 2) return 'RS_GreenImp';
			if (tier == 3) return 'RS_BlueImp';
			if (tier == 4) return 'RS_PurpleImp';
			if (tier == 5) return 'RS_YellowImp';
			if (tier == 6) return 'RS_RedImp';
			if (tier == 7) return 'RS_FireBluImp2';
			if (tier == 8) return 'RS_GrayImp2';
			if (tier == 9) return 'RS_AbyssImp2';
			if (tier == 10) return 'RS_BlackImp1';
			if (tier == 11) return 'RS_WhiteImp2';
			if (tier == 12) return 'RS_CyanImp2';
			if (tier == 13) return 'RS_BrownImp2';
			return 'None';
		}
		if (fam == 14)
		{
			if (tier == 1) return 'RS_CommonSG';
			if (tier == 2) return 'RS_GreenSG';
			if (tier == 3) return 'RS_BlueSG';
			if (tier == 4) return 'RS_PurpleSG';
			if (tier == 5) return 'RS_YellowSG';
			if (tier == 6) return 'RS_RedSG';
			if (tier == 7) return 'RS_FireBluSG2';
			if (tier == 8) return 'RS_GraySG2';
			if (tier == 9) return 'RS_AbyssSG2';
			if (tier == 10) return 'RS_BlackSG3';
			if (tier == 11) return 'RS_WhiteSG2';
			if (tier == 12) return 'RS_CyanSG2';
			if (tier == 13) return 'RS_BrownSG2';
			return 'None';
		}
		if (fam == 15)
		{
			if (tier == 1) return 'RS_CommonSpectre';
			if (tier == 2) return 'RS_GreenSpectre';
			if (tier == 3) return 'RS_BlueSpectre';
			if (tier == 4) return 'RS_PurpleSpectre';
			if (tier == 5) return 'RS_YellowSpectre';
			if (tier == 6) return 'RS_RedSpectre';
			if (tier == 7) return 'RS_FireBluDemon2';
			if (tier == 8) return 'RS_GraySpectre2';
			if (tier == 9) return 'RS_AbyssDemon2';
			if (tier == 10) return 'RS_BlackSpectre2';
			if (tier == 11) return 'RS_WhiteSpectre2';
			if (tier == 12) return 'RS_CyanSpectre2';
			if (tier == 13) return 'RS_BrownSpectre2';
			return 'None';
		}
		if (fam == 16)
		{
			if (tier == 1) return 'RS_CommonZombie';
			if (tier == 2) return 'RS_GreenZombie';
			if (tier == 3) return 'RS_BlueZombie';
			if (tier == 4) return 'RS_PurpleZombie';
			if (tier == 5) return 'RS_YellowZombie';
			if (tier == 6) return 'RS_RedZombie';
			if (tier == 7) return 'RS_FireBluZombie2';
			if (tier == 8) return 'RS_GrayZombie2';
			if (tier == 9) return 'RS_AbyssZombie2';
			if (tier == 10) return 'RS_BlackZombie1';
			if (tier == 11) return 'RS_WhiteZombie1';
			if (tier == 12) return 'RS_CyanZombie2';
			if (tier == 13) return 'RS_BrownZombie2';
			return 'None';
		}
		return 'None';
	}

	// The gate class the dial names for that tier. A map spawn can be either
	// this or the class above, so both have to answer FamilyOf/TierOf.
	static Name GateFor(int fam, int tier)
	{
		if (fam == 0)
		{
			if (tier == 1) return 'RS_CommonCGuy';
			if (tier == 2) return 'RS_GreenCGuy';
			if (tier == 3) return 'RS_BlueCGuy';
			if (tier == 4) return 'RS_PurpleCGuy';
			if (tier == 5) return 'RS_YellowCGuy';
			if (tier == 6) return 'RS_RedCGuy';
			if (tier == 7) return 'RS_FireBluCGuy';
			if (tier == 8) return 'RS_GrayCGuy';
			if (tier == 9) return 'RS_AbyssCGuy';
			if (tier == 10) return 'RS_BlackCGuy';
			if (tier == 11) return 'RS_WhiteCGuy';
			if (tier == 12) return 'RS_CyanCGuy';
			if (tier == 13) return 'RS_BrownCGuy';
			return 'None';
		}
		if (fam == 1)
		{
			if (tier == 1) return 'RS_CommonRevenant';
			if (tier == 2) return 'RS_GreenRevenant';
			if (tier == 3) return 'RS_BlueRevenant';
			if (tier == 4) return 'RS_PurpleRevenant';
			if (tier == 5) return 'RS_YellowRevenant';
			if (tier == 6) return 'RS_RedRevenant';
			if (tier == 7) return 'RS_FireBLURevenant';
			if (tier == 8) return 'RS_GrayRevenant';
			if (tier == 9) return 'RS_AbyssRevenant';
			if (tier == 10) return 'RS_BlackRevenant';
			if (tier == 11) return 'RS_WhiteRevenant';
			if (tier == 12) return 'RS_CyanRevenant';
			if (tier == 13) return 'RS_BrownRevenant';
			return 'None';
		}
		if (fam == 2)
		{
			if (tier == 1) return 'RS_CommonFatso';
			if (tier == 2) return 'RS_GreenFatso';
			if (tier == 3) return 'RS_BlueFatso';
			if (tier == 4) return 'RS_PurpleFatso';
			if (tier == 5) return 'RS_YellowFatso';
			if (tier == 6) return 'RS_RedFatso';
			if (tier == 7) return 'RS_FireBluFatso';
			if (tier == 8) return 'RS_GrayFatso';
			if (tier == 9) return 'RS_AbyssFatso';
			if (tier == 10) return 'RS_BlackFatso';
			if (tier == 11) return 'RS_WhiteFatso';
			if (tier == 12) return 'RS_CyanFatso';
			if (tier == 13) return 'RS_BrownFatso';
			return 'None';
		}
		if (fam == 3)
		{
			if (tier == 1) return 'RS_CommonArch';
			if (tier == 2) return 'RS_GreenArch';
			if (tier == 3) return 'RS_BlueArch';
			if (tier == 4) return 'RS_PurpleArch';
			if (tier == 5) return 'RS_YellowArch';
			if (tier == 6) return 'RS_RedArch';
			if (tier == 7) return 'RS_FireBluArch';
			if (tier == 8) return 'RS_GrayArch';
			if (tier == 9) return 'RS_AbyssArch';
			if (tier == 10) return 'RS_BlackArch';
			if (tier == 11) return 'RS_WhiteArch';
			if (tier == 12) return 'RS_CyanArch';
			if (tier == 13) return 'RS_BrownArch';
			return 'None';
		}
		if (fam == 4)
		{
			if (tier == 1) return 'RS_CommonBaron';
			if (tier == 2) return 'RS_GreenBaron';
			if (tier == 3) return 'RS_BlueBaron';
			if (tier == 4) return 'RS_PurpleBaron';
			if (tier == 5) return 'RS_YellowBaron';
			if (tier == 6) return 'RS_RedBaron';
			if (tier == 7) return 'RS_FireBluBaron';
			if (tier == 8) return 'RS_GrayBaron';
			if (tier == 9) return 'RS_AbyssBaron';
			if (tier == 10) return 'RS_BlackBaron';
			if (tier == 11) return 'RS_WhiteBaron';
			if (tier == 12) return 'RS_CyanBaron';
			if (tier == 13) return 'RS_BrownBaron';
			return 'None';
		}
		if (fam == 5)
		{
			if (tier == 1) return 'RS_CommonLSoul';
			if (tier == 2) return 'RS_GreenLSoul';
			if (tier == 3) return 'RS_BlueLSoul';
			if (tier == 4) return 'RS_PurpleLSoul';
			if (tier == 5) return 'RS_YellowLSoul';
			if (tier == 6) return 'RS_RedLSoul';
			if (tier == 7) return 'RS_FireBluLSoul';
			if (tier == 8) return 'RS_GrayLSoul';
			if (tier == 9) return 'RS_AbyssLsoul';
			if (tier == 10) return 'RS_BlackLSoul';
			if (tier == 11) return 'RS_WhiteLSoul';
			if (tier == 12) return 'RS_CyanLSoul';
			if (tier == 13) return 'RS_BrownLSoul';
			return 'None';
		}
		if (fam == 6)
		{
			if (tier == 1) return 'RS_CommonPE';
			if (tier == 2) return 'RS_GreenPE';
			if (tier == 3) return 'RS_BluePE';
			if (tier == 4) return 'RS_PurplePE';
			if (tier == 5) return 'RS_YellowPE';
			if (tier == 6) return 'RS_RedPE';
			if (tier == 7) return 'RS_FireBluPE';
			if (tier == 8) return 'RS_GrayPE';
			if (tier == 9) return 'RS_AbyssPE';
			if (tier == 10) return 'RS_BlackPE';
			if (tier == 11) return 'RS_WhitePE';
			if (tier == 12) return 'RS_CyanPE';
			if (tier == 13) return 'RS_BrownPE';
			return 'None';
		}
		if (fam == 7)
		{
			if (tier == 1) return 'RS_CommonCybie';
			if (tier == 2) return 'RS_GreenCybie';
			if (tier == 3) return 'RS_BlueCybie';
			if (tier == 4) return 'RS_PurpleCybie';
			if (tier == 5) return 'RS_YellowCybie';
			if (tier == 6) return 'RS_RedCybie';
			if (tier == 7) return 'RS_FireBluCybie';
			if (tier == 8) return 'RS_GrayCybie';
			if (tier == 9) return 'RS_AbyssCybie';
			if (tier == 10) return 'RS_BlackCybie';
			if (tier == 11) return 'RS_WhiteCybie';
			if (tier == 12) return 'RS_CyanCybie';
			if (tier == 13) return 'RS_BrownCybie';
			return 'None';
		}
		if (fam == 8)
		{
			if (tier == 1) return 'RS_CommonMind';
			if (tier == 2) return 'RS_GreenMind';
			if (tier == 3) return 'RS_BlueMind';
			if (tier == 4) return 'RS_PurpleMind';
			if (tier == 5) return 'RS_YellowMind';
			if (tier == 6) return 'RS_RedMind';
			if (tier == 7) return 'RS_FireBluMind';
			if (tier == 8) return 'RS_GrayMind';
			if (tier == 9) return 'RS_AbyssMind';
			if (tier == 10) return 'RS_BlackMind';
			if (tier == 11) return 'RS_WhiteMind';
			if (tier == 12) return 'RS_CyanMind';
			if (tier == 13) return 'RS_BrownMind';
			return 'None';
		}
		if (fam == 9)
		{
			if (tier == 1) return 'RS_CommonDemon';
			if (tier == 2) return 'RS_GreenDemon';
			if (tier == 3) return 'RS_BlueDemon';
			if (tier == 4) return 'RS_PurpleDemon';
			if (tier == 5) return 'RS_YellowDemon';
			if (tier == 6) return 'RS_RedDemon';
			if (tier == 7) return 'RS_FireBluDemon';
			if (tier == 8) return 'RS_GrayDemon';
			if (tier == 9) return 'RS_AbyssDemon';
			if (tier == 10) return 'RS_BlackDemon';
			if (tier == 11) return 'RS_WhiteDemon';
			if (tier == 12) return 'RS_CyanDemon';
			if (tier == 13) return 'RS_BrownDemon';
			return 'None';
		}
		if (fam == 10)
		{
			if (tier == 1) return 'RS_CommonCaco';
			if (tier == 2) return 'RS_GreenCaco';
			if (tier == 3) return 'RS_BlueCaco';
			if (tier == 4) return 'RS_PurpleCaco';
			if (tier == 5) return 'RS_YellowCaco';
			if (tier == 6) return 'RS_RedCaco';
			if (tier == 7) return 'RS_FireBluCaco';
			if (tier == 8) return 'RS_GrayCaco';
			if (tier == 9) return 'RS_AbyssCaco';
			if (tier == 10) return 'RS_BlackCaco';
			if (tier == 11) return 'RS_WhiteCaco';
			if (tier == 12) return 'RS_CyanCaco';
			if (tier == 13) return 'RS_BrownCaco';
			return 'None';
		}
		if (fam == 11)
		{
			if (tier == 1) return 'RS_CommonHK';
			if (tier == 2) return 'RS_GreenHK';
			if (tier == 3) return 'RS_BlueHK';
			if (tier == 4) return 'RS_PurpleHK';
			if (tier == 5) return 'RS_YellowHK';
			if (tier == 6) return 'RS_RedHK';
			if (tier == 7) return 'RS_FireBluHK';
			if (tier == 8) return 'RS_GrayHK';
			if (tier == 9) return 'RS_AbyssHK';
			if (tier == 10) return 'RS_BlackHK';
			if (tier == 11) return 'RS_WhiteHK';
			if (tier == 12) return 'RS_CyanHK';
			if (tier == 13) return 'RS_BrownHK';
			return 'None';
		}
		if (fam == 12)
		{
			if (tier == 1) return 'RS_CommonSP1';
			if (tier == 2) return 'RS_GreenSP1';
			if (tier == 3) return 'RS_BlueSP1';
			if (tier == 4) return 'RS_PurpleSP1';
			if (tier == 5) return 'RS_YellowSP1';
			if (tier == 6) return 'RS_RedSP1';
			if (tier == 7) return 'RS_FireBluSP1';
			if (tier == 8) return 'RS_GraySP1';
			if (tier == 9) return 'RS_AbyssSP1';
			if (tier == 10) return 'RS_BlackSP1';
			if (tier == 11) return 'RS_WhiteSP1';
			if (tier == 12) return 'RS_CyanSP1';
			if (tier == 13) return 'RS_BrownSP1';
			return 'None';
		}
		if (fam == 13)
		{
			if (tier == 1) return 'RS_CommonImp';
			if (tier == 2) return 'RS_GreenImp';
			if (tier == 3) return 'RS_BlueImp';
			if (tier == 4) return 'RS_PurpleImp';
			if (tier == 5) return 'RS_YellowImp';
			if (tier == 6) return 'RS_RedImp';
			if (tier == 7) return 'RS_FireBluImp';
			if (tier == 8) return 'RS_GrayImp';
			if (tier == 9) return 'RS_AbyssImp';
			if (tier == 10) return 'RS_BlackImp';
			if (tier == 11) return 'RS_WhiteImp';
			if (tier == 12) return 'RS_CyanImp';
			if (tier == 13) return 'RS_BrownImp';
			return 'None';
		}
		if (fam == 14)
		{
			if (tier == 1) return 'RS_CommonSG';
			if (tier == 2) return 'RS_GreenSG';
			if (tier == 3) return 'RS_BlueSG';
			if (tier == 4) return 'RS_PurpleSG';
			if (tier == 5) return 'RS_YellowSG';
			if (tier == 6) return 'RS_RedSG';
			if (tier == 7) return 'RS_FireBluSG';
			if (tier == 8) return 'RS_GraySG';
			if (tier == 9) return 'RS_AbyssSG';
			if (tier == 10) return 'RS_BlackSG';
			if (tier == 11) return 'RS_WhiteSG';
			if (tier == 12) return 'RS_CyanSG';
			if (tier == 13) return 'RS_BrownSG';
			return 'None';
		}
		if (fam == 15)
		{
			if (tier == 1) return 'RS_CommonSpectre';
			if (tier == 2) return 'RS_GreenSpectre';
			if (tier == 3) return 'RS_BlueSpectre';
			if (tier == 4) return 'RS_PurpleSpectre';
			if (tier == 5) return 'RS_YellowSpectre';
			if (tier == 6) return 'RS_RedSpectre';
			if (tier == 7) return 'RS_FireBluSpectre';
			if (tier == 8) return 'RS_GraySpectre';
			if (tier == 9) return 'RS_AbyssSpectre';
			if (tier == 10) return 'RS_BlackSpectre';
			if (tier == 11) return 'RS_WhiteSpectre';
			if (tier == 12) return 'RS_CyanSpectre';
			if (tier == 13) return 'RS_BrownSpectre';
			return 'None';
		}
		if (fam == 16)
		{
			if (tier == 1) return 'RS_CommonZombie';
			if (tier == 2) return 'RS_GreenZombie';
			if (tier == 3) return 'RS_BlueZombie';
			if (tier == 4) return 'RS_PurpleZombie';
			if (tier == 5) return 'RS_YellowZombie';
			if (tier == 6) return 'RS_RedZombie';
			if (tier == 7) return 'RS_FireBluZombie';
			if (tier == 8) return 'RS_GrayZombie';
			if (tier == 9) return 'RS_AbyssZombie';
			if (tier == 10) return 'RS_BlackZombie';
			if (tier == 11) return 'RS_WhiteZombie';
			if (tier == 12) return 'RS_CyanZombie';
			if (tier == 13) return 'RS_BrownZombie';
			return 'None';
		}
		return 'None';
	}

	static int FamilyOf(Name cls)
	{
		if (cls == 'None') return -1;
		for (int f = 0; f < FamilyCount(); f++)
			for (int t = 1; t <= MaxTier(); t++)
				if (ClassFor(f, t) == cls || GateFor(f, t) == cls) return f;
		return -1;
	}

	static int TierOf(Name cls)
	{
		if (cls == 'None') return 0;
		for (int f = 0; f < FamilyCount(); f++)
			for (int t = 1; t <= MaxTier(); t++)
				if (ClassFor(f, t) == cls || GateFor(f, t) == cls) return t;
		return 0;
	}
}

// ============================================================================
// RS_Retier -- the public entry point.  PLAY SCOPE, like RS_Zom: it spawns and
// destroys actors and constructs a Thinker, none of which is legal from a data
// context (the first version of this file failed to compile for exactly that).
//
//   RS_Retier.Request(mo, tier)         staggered, with a flash tell
//   RS_Retier.Request(mo, tier, true)   immediate
//
// STAGGERED BY DEFAULT, for the two reasons RS_MonsterMaster gives: it spreads
// a roomful of retiers over many tics instead of spiking one frame, and a
// monster that flashes and THEN changes reads as deliberate where one that
// snaps reads as a bug. Delay is random 45..105 tics, so a room ripples.
//
// THE TELL is HF's tier-change flash (owner 2026-11-09: "flash is important,
// it's how monsters change tier in real time"; it applies to ALL RSQ monsters),
// ported from HF_Monster.zs SetTier/Tick: a random 5..25-tic wait, and every 3
// tics the monster alternates between the flash translation (rs_tier_flashwhite,
// or rs_tier_flashblack when the target tier is White, 11) and its ORIGINAL
// translation, saved at job start and restored (some CH colours carry one).
// Then the swap (CH) or the in-place tier (MeatGrinder). One flash, both sets.
// It replaced a bBRIGHT flicker (45..105 tics).
// ============================================================================
class RS_Retier play
{
	static RS_RetierJob JobFor(Actor mo)
	{
		if (!mo) return null;
		ThinkerIterator it = ThinkerIterator.Create("RS_RetierJob", Thinker.STAT_DEFAULT);
		RS_RetierJob j;
		while (j = RS_RetierJob(it.Next()))
			if (j.mo == mo) return j;
		return null;
	}

	static void Request(Actor mo, int tier, bool instant = false)
	{
		if (!mo || mo.health <= 0) return;
		tier = clamp(tier, 1, RS_TierLadder.MaxTier());
		int fam = RS_TierLadder.FamilyOf(mo.GetClassName());
		// Not on the CH ladder but a monster that tiers IN PLACE (the
		// MeatGrinder set, RS_MGMonster). Same ladder numbers, same flash.
		let mg = RS_MGMonster(mo);
		if (fam < 0 && !mg) return;              // not one of ours
		if (TierNowOf(mo) == tier && !JobFor(mo)) return;

		if (instant)
		{
			if (mg) mg.MG_ApplyTierNow(tier, true);
			else    Swap(mo, tier, true);
			return;
		}

		// Already queued? Re-target instead of stacking a second job, so
		// repeated calls cannot double-swap.
		let j = JobFor(mo);
		if (j) { j.targetTier = tier; return; }

		let nj = RS_RetierJob(new("RS_RetierJob"));
		nj.mo         = mo;
		nj.targetTier = tier;
		nj.timer      = random(5, 25);   // HF: load-balancer AND "charging" beat
		nj.ticker     = 0;
		nj.origTrans  = mo.Translation;
	}

	// RSQ Monsters > "On tier change" (rsq_mon_retier_health, owner 2026-11-09):
	//   0 keep the health fraction already lost
	//   1 full health on an INSTANT tier only, the fraction on a live one (HF's rule, default)
	//   2 always full health
	// Read by Swap (CH) and RS_MGMonster.ApplyTier (MeatGrinder).
	static bool FullHealth(bool instant)
	{
		let cv = CVar.FindCVar("rsq_mon_retier_health");
		int mode = cv ? cv.GetInt() : 1;
		return mode >= 2 || (mode == 1 && instant);
	}

	// The tier an actor is on: CH by class, MeatGrinder by its own Tier.
	static int TierNowOf(Actor mo)
	{
		if (!mo) return -1;
		if (RS_TierLadder.FamilyOf(mo.GetClassName()) >= 0)
			return RS_TierLadder.TierOf(mo.GetClassName());
		let mg = RS_MGMonster(mo);
		return mg ? mg.Tier : -1;
	}

	// The swap. Returns the new monster, or null if nothing changed.
	static Actor Swap(Actor mo, int tier, bool instant = false)
	{
		if (!mo) return null;
		int fam = RS_TierLadder.FamilyOf(mo.GetClassName());
		if (fam < 0) return null;
		Name nn = RS_TierLadder.ClassFor(fam, tier);
		if (nn == 'None') return null;
		Class<Actor> nc = nn;
		if (!nc || nc == mo.GetClass()) return null;

		// Carry the WOUND, not the number. Health belongs to the class, so a
		// tier-up must take the new class's health -- that is the point. What
		// survives is the fraction already lost, so a retier is neither a free
		// heal nor an instant kill.
		let od = GetDefaultByType(mo.GetClass());
		double frac = 1.0;
		if (od && od.Health > 0)
			frac = clamp(double(mo.health) / double(od.Health), 0.05, 1.0);

		Actor a = Actor.Spawn(nc, mo.pos, NO_REPLACE);
		if (!a) return null;

		a.angle   = mo.angle;
		a.pitch   = mo.pitch;
		a.vel     = mo.vel;
		a.target  = mo.target;
		a.master  = mo.master;
		a.tracer  = mo.tracer;
		a.special = mo.special;
		a.args[0] = mo.args[0]; a.args[1] = mo.args[1]; a.args[2] = mo.args[2];
		a.args[3] = mo.args[3]; a.args[4] = mo.args[4];
		a.bAMBUSH   = mo.bAMBUSH;
		a.bFRIENDLY = mo.bFRIENDLY;
		if (mo.tid != 0) a.ChangeTid(mo.tid);

		let nd = GetDefaultByType(nc);
		if (nd && nd.Health > 0)
			a.health = FullHealth(instant) ? nd.Health : max(1, int(nd.Health * frac));

		// It was already awake and fighting -- do not make it re-notice.
		if (mo.target && a.SeeState)
			a.SetState(a.SeeState);

		// The old body leaves without counting as a kill and without paying
		// out: it did not die, it became something else.
		mo.ClearCounters();
		mo.Destroy();
		return a;
	}
}

class RS_RetierJob : Thinker
{
	Actor mo;
	int   targetTier, timer, ticker;
	TranslationID origTrans;   // the monster's own colour, restored between flashes

	override void Tick()
	{
		if (!mo || mo.health <= 0)
		{
			if (mo) mo.Translation = origTrans;
			Destroy();
			return;
		}
		if (level.isFrozen()) return;

		// HF_Monster.Tick, verbatim in shape: every 3 tics the target tier's
		// flash colour, then the monster's own colour.
		ticker++;
		if ((ticker / 3) % 2 == 0)
			mo.A_SetTranslation(targetTier == 11 ? "rs_tier_flashblack" : "rs_tier_flashwhite");
		else
			mo.Translation = origTrans;

		if (timer > 0) timer--;
		if (timer <= 0)
		{
			mo.Translation = origTrans;
			let mg = RS_MGMonster(mo);
			if (mg) mg.MG_ApplyTierNow(targetTier);   // its new tint comes with it
			else    RS_Retier.Swap(mo, targetTier);
			Destroy();
		}
	}
}

// ----------------------------------------------------------------------------
//   netevent rs_tierof          print what the aimed monster is
//   netevent rs_retier 7        aimed monster becomes tier 7
//   netevent rs_retier_up       aimed monster goes up one tier
//   netevent rs_retier_all 9    every monster in the map becomes tier 9
// RS_RetierHandler must also be in MAPINFO's AddEventHandlers.
// ----------------------------------------------------------------------------
class RS_RetierHandler : EventHandler
{
	static Actor AimedAt(int pnum)
	{
		let p = players[pnum].mo;
		if (!p) return null;
		FLineTraceData d;
		p.LineTrace(p.angle, 4096, p.pitch, TRF_THRUBLOCK, p.height * 0.5, data: d);
		return d.HitActor;
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name ~== "rs_tierof")
		{
			let a = AimedAt(e.Player);
			if (!a) { Console.Printf("RETIER: nothing aimed at"); return; }
			int f = RS_TierLadder.FamilyOf(a.GetClassName());
			let mm = RS_MGMonster(a);
			Console.Printf("RETIER: %s -- family %s, tier %d", a.GetClassName(),
				f >= 0 ? String.Format("%s", RS_TierLadder.DialOf(f))
				       : (mm ? String.Format("MeatGrinder %s", mm.MG_Family) : "not ours"),
				f >= 0 ? RS_TierLadder.TierOf(a.GetClassName()) : (mm ? mm.Tier : 0));
			return;
		}
		if (e.Name ~== "rs_retier" || e.Name ~== "rs_retier_up")
		{
			let a = AimedAt(e.Player);
			if (!a) { Console.Printf("RETIER: nothing aimed at"); return; }
			int t = (e.Name ~== "rs_retier_up")
			      ? RS_Retier.TierNowOf(a) + 1 : e.Args[0];
			Console.Printf("RETIER: %s -> tier %d", a.GetClassName(), t);
			RS_Retier.Request(a, t);
			return;
		}
		if (e.Name ~== "rs_retier_all")
		{
			int n;
			ThinkerIterator it = ThinkerIterator.Create("Actor");
			Actor a;
			while (a = Actor(it.Next()))
				if (a.bISMONSTER && a.health > 0
				    && RS_Retier.TierNowOf(a) >= 0)
				{ RS_Retier.Request(a, e.Args[0]); n++; }
			Console.Printf("RETIER: queued %d monsters for tier %d", n, e.Args[0]);
			return;
		}
	}
}
