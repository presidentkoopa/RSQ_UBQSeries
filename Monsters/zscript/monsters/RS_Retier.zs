// ============================================================================
// RS_Retier -- tier changes at runtime for the CH-rebuild monster families.
//
// WHY. Every ColorfulHell colour is its own class, so a tier change SWAPS THE CLASS.
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
// THE NUMBER IS THE STRENGTH (owner 2026-11-11): the ladder is ordered by
// measured strength (mean health rank over the 17 families, Miniboss commit
// 7c50d118, design/rigtest_2026-11-10/evidence/MB_TIER2_strength.py), not by
// Colourful Hell's listing order. Only the numbering changed; every colour
// keeps its classes, health, look and boss status.
//
//   1 Common  2 Green  3 Blue    4 Purple  5 Cyan   6 Brown  7 Yellow
//   8 FireBlu 9 Gray   10 Red    11 Abyss  12 Black (boss, EX roll)  13 White (boss)
//
// (Colourful Hell's own order, the numbers before 11-11: 1 Common 2 Green
// 3 Blue 4 Purple 5 Yellow 6 Red 7 FireBlu 8 Gray 9 Abyss 10 Black 11 White
// 12 Cyan 13 Brown. The icon actors RS_ColorTierIconCH<n> keep CH's names.)
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
			if (tier == 5) return 'RS_CyanCGuy2';
			if (tier == 6) return 'RS_BrownCGuy2';
			if (tier == 7) return 'RS_YellowCGuy';
			if (tier == 8) return 'RS_FireBluCGuy2';
			if (tier == 9) return 'RS_GrayCGuy2';
			if (tier == 10) return 'RS_RedCGuy';
			if (tier == 11) return 'RS_AbyssCGuy2';
			if (tier == 12) return 'RS_BlackCGuy2';
			if (tier == 13) return 'RS_WhiteCguy2';
			return 'None';
		}
		if (fam == 1)
		{
			if (tier == 1) return 'RS_CommonRevenant';
			if (tier == 2) return 'RS_GreenRevenant';
			if (tier == 3) return 'RS_BlueRevenant';
			if (tier == 4) return 'RS_PurpleRevenant';
			if (tier == 5) return 'RS_CyanRevenant2';
			if (tier == 6) return 'RS_BrownRevenant2';
			if (tier == 7) return 'RS_YellowRevenant';
			if (tier == 8) return 'RS_FireBluRevenant2';
			if (tier == 9) return 'RS_GrayRevenant2';
			if (tier == 10) return 'RS_RedRevenant';
			if (tier == 11) return 'RS_AbyssRevenant2';
			if (tier == 12) return 'RS_BlackRevenant3';
			if (tier == 13) return 'RS_WhiteRevenant2';
			return 'None';
		}
		if (fam == 2)
		{
			if (tier == 1) return 'RS_CommonFatso';
			if (tier == 2) return 'RS_GreenFatso';
			if (tier == 3) return 'RS_BlueFatso';
			if (tier == 4) return 'RS_PurpleFatso';
			if (tier == 5) return 'RS_CyanFatso2';
			if (tier == 6) return 'RS_BrownFatso2';
			if (tier == 7) return 'RS_YellowFatso';
			if (tier == 8) return 'RS_FireBluFatso2';
			if (tier == 9) return 'RS_GrayFatso2';
			if (tier == 10) return 'RS_RedFatso';
			if (tier == 11) return 'RS_AbyssFatso2';
			if (tier == 12) return 'RS_BlackFatso2';
			if (tier == 13) return 'RS_WhiteFatso2';
			return 'None';
		}
		if (fam == 3)
		{
			if (tier == 1) return 'RS_CommonArch';
			if (tier == 2) return 'RS_GreenArch';
			if (tier == 3) return 'RS_BlueArch';
			if (tier == 4) return 'RS_PurpleArch';
			if (tier == 5) return 'RS_CyanVile';
			if (tier == 6) return 'RS_BrownVile';
			if (tier == 7) return 'RS_YellowArch';
			if (tier == 8) return 'RS_FireBluArch2';
			if (tier == 9) return 'RS_GrayArch2';
			if (tier == 10) return 'RS_RedArch3';
			if (tier == 11) return 'RS_AbyssVile';
			if (tier == 12) return 'RS_BlackVile';
			if (tier == 13) return 'RS_Whitevile';
			return 'None';
		}
		if (fam == 4)
		{
			if (tier == 1) return 'RS_CommonBaron';
			if (tier == 2) return 'RS_GreenBaron';
			if (tier == 3) return 'RS_BlueBaron';
			if (tier == 4) return 'RS_PurpleBaron';
			if (tier == 5) return 'RS_CyanBaron2';
			if (tier == 6) return 'RS_BrownBaron2';
			if (tier == 7) return 'RS_YellowBaron';
			if (tier == 8) return 'RS_FireBluBaron2';
			if (tier == 9) return 'RS_GrayBaron2';
			if (tier == 10) return 'RS_RedBaron3';
			if (tier == 11) return 'RS_AbyssBaron2';
			if (tier == 12) return 'RS_BlackBaron2';
			if (tier == 13) return 'RS_WhiteBaron2';
			return 'None';
		}
		if (fam == 5)
		{
			if (tier == 1) return 'RS_CommonLSoul';
			if (tier == 2) return 'RS_GreenLSoul';
			if (tier == 3) return 'RS_BlueLSoul';
			if (tier == 4) return 'RS_PurpleLSoul';
			if (tier == 5) return 'RS_CyanLSoul2';
			if (tier == 6) return 'RS_BrownLSoul2';
			if (tier == 7) return 'RS_YellowLSoul';
			if (tier == 8) return 'RS_FireBluLSoul2';
			if (tier == 9) return 'RS_GrayLSoul2';
			if (tier == 10) return 'RS_RedLSoul';
			if (tier == 11) return 'RS_AbyssLSoul2';
			if (tier == 12) return 'RS_BlackLSoul3';
			if (tier == 13) return 'RS_WhiteLSoul2';
			return 'None';
		}
		if (fam == 6)
		{
			if (tier == 1) return 'RS_CommonPE';
			if (tier == 2) return 'RS_GreenPE';
			if (tier == 3) return 'RS_BluePE';
			if (tier == 4) return 'RS_PurplePE';
			if (tier == 5) return 'RS_CyanPE2';
			if (tier == 6) return 'RS_BrownPE2';
			if (tier == 7) return 'RS_YellowPE';
			if (tier == 8) return 'RS_FireBluPE2';
			if (tier == 9) return 'RS_GrayPE2';
			if (tier == 10) return 'RS_RedPE';
			if (tier == 11) return 'RS_AbyssPE2';
			if (tier == 12) return 'RS_BlackPE2';
			if (tier == 13) return 'RS_WhitePE2';
			return 'None';
		}
		if (fam == 7)
		{
			if (tier == 1) return 'RS_CommonCybie';
			if (tier == 2) return 'RS_GreenCybie';
			if (tier == 3) return 'RS_BlueCybie';
			if (tier == 4) return 'RS_PurpleCybie';
			if (tier == 5) return 'RS_CyanCybie2';
			if (tier == 6) return 'RS_BrownCybie2';
			if (tier == 7) return 'RS_YellowCybie';
			if (tier == 8) return 'RS_FireBluCybie2';
			if (tier == 9) return 'RS_GrayCybie2';
			if (tier == 10) return 'RS_RedCybie';
			if (tier == 11) return 'RS_AbyssCybie2';
			if (tier == 12) return 'RS_BlackCybie2';
			if (tier == 13) return 'RS_WhiteCybie2';
			return 'None';
		}
		if (fam == 8)
		{
			if (tier == 1) return 'RS_CommonMind';
			if (tier == 2) return 'RS_GreenMind';
			if (tier == 3) return 'RS_BlueMind';
			if (tier == 4) return 'RS_PurpleMind';
			if (tier == 5) return 'RS_CyanMind2';
			if (tier == 6) return 'RS_BrownMind2';
			if (tier == 7) return 'RS_YellowMind';
			if (tier == 8) return 'RS_FireBluMind2';
			if (tier == 9) return 'RS_GrayMind2';
			if (tier == 10) return 'RS_RedMind';
			if (tier == 11) return 'RS_AbyssMind2';
			if (tier == 12) return 'RS_BlackMind2';
			if (tier == 13) return 'RS_WhiteMind2';
			return 'None';
		}
		if (fam == 9)
		{
			if (tier == 1) return 'RS_CommonDemon';
			if (tier == 2) return 'RS_GreenDemon';
			if (tier == 3) return 'RS_BlueDemon';
			if (tier == 4) return 'RS_PurpleDemon';
			if (tier == 5) return 'RS_CyanDemon2';
			if (tier == 6) return 'RS_BrownDemon2';
			if (tier == 7) return 'RS_YellowDemon';
			if (tier == 8) return 'RS_FireBluDemon2';
			if (tier == 9) return 'RS_GreyDemon2';
			if (tier == 10) return 'RS_RedDemon';
			if (tier == 11) return 'RS_AbyssDemon2';
			if (tier == 12) return 'RS_BlackDemon3';
			if (tier == 13) return 'RS_WhiteDemon2';
			return 'None';
		}
		if (fam == 10)
		{
			if (tier == 1) return 'RS_CommonCaco';
			if (tier == 2) return 'RS_GreenCaco';
			if (tier == 3) return 'RS_BlueCaco';
			if (tier == 4) return 'RS_PurpleCaco';
			if (tier == 5) return 'RS_CyanCaco2';
			if (tier == 6) return 'RS_BrownCaco2';
			if (tier == 7) return 'RS_YellowCaco';
			if (tier == 8) return 'RS_FireBluCaco2';
			if (tier == 9) return 'RS_GrayCaco2';
			if (tier == 10) return 'RS_RedCaco';
			if (tier == 11) return 'RS_AbyssCaco2';
			if (tier == 12) return 'RS_BlackCaco2';
			if (tier == 13) return 'RS_WhiteCaco2';
			return 'None';
		}
		if (fam == 11)
		{
			if (tier == 1) return 'RS_CommonHK';
			if (tier == 2) return 'RS_GreenHK';
			if (tier == 3) return 'RS_BlueHK';
			if (tier == 4) return 'RS_PurpleHK';
			if (tier == 5) return 'RS_CyanHK2';
			if (tier == 6) return 'RS_BrownHK2';
			if (tier == 7) return 'RS_YellowHK';
			if (tier == 8) return 'RS_FireBluHK2';
			if (tier == 9) return 'RS_GrayHK2';
			if (tier == 10) return 'RS_RedHK';
			if (tier == 11) return 'RS_AbyssHK2';
			if (tier == 12) return 'RS_BlackHK2';
			if (tier == 13) return 'RS_WhiteHK3';
			return 'None';
		}
		if (fam == 12)
		{
			if (tier == 1) return 'RS_CommonSP1';
			if (tier == 2) return 'RS_GreenSP1';
			if (tier == 3) return 'RS_BlueSP1';
			if (tier == 4) return 'RS_PurpleSP1';
			if (tier == 5) return 'RS_CyanSP2';
			if (tier == 6) return 'RS_BrownSP2';
			if (tier == 7) return 'RS_YellowSP1';
			if (tier == 8) return 'RS_FireBluSP2';
			if (tier == 9) return 'RS_GraySP2';
			if (tier == 10) return 'RS_RedSP1';
			if (tier == 11) return 'RS_AbyssSP2';
			if (tier == 12) return 'RS_BlackSP2';
			if (tier == 13) return 'RS_WhiteSP11';
			return 'None';
		}
		if (fam == 13)
		{
			if (tier == 1) return 'RS_CommonImp';
			if (tier == 2) return 'RS_GreenImp';
			if (tier == 3) return 'RS_BlueImp';
			if (tier == 4) return 'RS_PurpleImp';
			if (tier == 5) return 'RS_CyanImp2';
			if (tier == 6) return 'RS_BrownImp2';
			if (tier == 7) return 'RS_YellowImp';
			if (tier == 8) return 'RS_FireBluImp2';
			if (tier == 9) return 'RS_GrayImp2';
			if (tier == 10) return 'RS_RedImp';
			if (tier == 11) return 'RS_AbyssImp2';
			if (tier == 12) return 'RS_BlackImp1';
			if (tier == 13) return 'RS_WhiteImp2';
			return 'None';
		}
		if (fam == 14)
		{
			if (tier == 1) return 'RS_CommonSG';
			if (tier == 2) return 'RS_GreenSG';
			if (tier == 3) return 'RS_BlueSG';
			if (tier == 4) return 'RS_PurpleSG';
			if (tier == 5) return 'RS_CyanSG2';
			if (tier == 6) return 'RS_BrownSG2';
			if (tier == 7) return 'RS_YellowSG';
			if (tier == 8) return 'RS_FireBluSG2';
			if (tier == 9) return 'RS_GraySG2';
			if (tier == 10) return 'RS_RedSG';
			if (tier == 11) return 'RS_AbyssSG2';
			if (tier == 12) return 'RS_BlackSG3';
			if (tier == 13) return 'RS_WhiteSG2';
			return 'None';
		}
		if (fam == 15)
		{
			if (tier == 1) return 'RS_CommonSpectre';
			if (tier == 2) return 'RS_GreenSpectre';
			if (tier == 3) return 'RS_BlueSpectre';
			if (tier == 4) return 'RS_PurpleSpectre';
			if (tier == 5) return 'RS_CyanSpectre2';
			if (tier == 6) return 'RS_BrownSpectre2';
			if (tier == 7) return 'RS_YellowSpectre';
			if (tier == 8) return 'RS_FireBluDemon2';
			if (tier == 9) return 'RS_GraySpectre2';
			if (tier == 10) return 'RS_RedSpectre';
			if (tier == 11) return 'RS_AbyssDemon2';
			if (tier == 12) return 'RS_BlackSpectre2';
			if (tier == 13) return 'RS_WhiteSpectre2';
			return 'None';
		}
		if (fam == 16)
		{
			if (tier == 1) return 'RS_CommonZombie';
			if (tier == 2) return 'RS_GreenZombie';
			if (tier == 3) return 'RS_BlueZombie';
			if (tier == 4) return 'RS_PurpleZombie';
			if (tier == 5) return 'RS_CyanZombie2';
			if (tier == 6) return 'RS_BrownZombie2';
			if (tier == 7) return 'RS_YellowZombie';
			if (tier == 8) return 'RS_FireBluZombie2';
			if (tier == 9) return 'RS_GrayZombie2';
			if (tier == 10) return 'RS_RedZombie';
			if (tier == 11) return 'RS_AbyssZombie2';
			if (tier == 12) return 'RS_BlackZombie1';
			if (tier == 13) return 'RS_WhiteZombie1';
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
			if (tier == 5) return 'RS_CyanCGuy';
			if (tier == 6) return 'RS_BrownCGuy';
			if (tier == 7) return 'RS_YellowCGuy';
			if (tier == 8) return 'RS_FireBluCGuy';
			if (tier == 9) return 'RS_GrayCGuy';
			if (tier == 10) return 'RS_RedCGuy';
			if (tier == 11) return 'RS_AbyssCGuy';
			if (tier == 12) return 'RS_BlackCGuy';
			if (tier == 13) return 'RS_WhiteCGuy';
			return 'None';
		}
		if (fam == 1)
		{
			if (tier == 1) return 'RS_CommonRevenant';
			if (tier == 2) return 'RS_GreenRevenant';
			if (tier == 3) return 'RS_BlueRevenant';
			if (tier == 4) return 'RS_PurpleRevenant';
			if (tier == 5) return 'RS_CyanRevenant';
			if (tier == 6) return 'RS_BrownRevenant';
			if (tier == 7) return 'RS_YellowRevenant';
			if (tier == 8) return 'RS_FireBLURevenant';
			if (tier == 9) return 'RS_GrayRevenant';
			if (tier == 10) return 'RS_RedRevenant';
			if (tier == 11) return 'RS_AbyssRevenant';
			if (tier == 12) return 'RS_BlackRevenant';
			if (tier == 13) return 'RS_WhiteRevenant';
			return 'None';
		}
		if (fam == 2)
		{
			if (tier == 1) return 'RS_CommonFatso';
			if (tier == 2) return 'RS_GreenFatso';
			if (tier == 3) return 'RS_BlueFatso';
			if (tier == 4) return 'RS_PurpleFatso';
			if (tier == 5) return 'RS_CyanFatso';
			if (tier == 6) return 'RS_BrownFatso';
			if (tier == 7) return 'RS_YellowFatso';
			if (tier == 8) return 'RS_FireBluFatso';
			if (tier == 9) return 'RS_GrayFatso';
			if (tier == 10) return 'RS_RedFatso';
			if (tier == 11) return 'RS_AbyssFatso';
			if (tier == 12) return 'RS_BlackFatso';
			if (tier == 13) return 'RS_WhiteFatso';
			return 'None';
		}
		if (fam == 3)
		{
			if (tier == 1) return 'RS_CommonArch';
			if (tier == 2) return 'RS_GreenArch';
			if (tier == 3) return 'RS_BlueArch';
			if (tier == 4) return 'RS_PurpleArch';
			if (tier == 5) return 'RS_CyanArch';
			if (tier == 6) return 'RS_BrownArch';
			if (tier == 7) return 'RS_YellowArch';
			if (tier == 8) return 'RS_FireBluArch';
			if (tier == 9) return 'RS_GrayArch';
			if (tier == 10) return 'RS_RedArch';
			if (tier == 11) return 'RS_AbyssArch';
			if (tier == 12) return 'RS_BlackArch';
			if (tier == 13) return 'RS_WhiteArch';
			return 'None';
		}
		if (fam == 4)
		{
			if (tier == 1) return 'RS_CommonBaron';
			if (tier == 2) return 'RS_GreenBaron';
			if (tier == 3) return 'RS_BlueBaron';
			if (tier == 4) return 'RS_PurpleBaron';
			if (tier == 5) return 'RS_CyanBaron';
			if (tier == 6) return 'RS_BrownBaron';
			if (tier == 7) return 'RS_YellowBaron';
			if (tier == 8) return 'RS_FireBluBaron';
			if (tier == 9) return 'RS_GrayBaron';
			if (tier == 10) return 'RS_RedBaron';
			if (tier == 11) return 'RS_AbyssBaron';
			if (tier == 12) return 'RS_BlackBaron';
			if (tier == 13) return 'RS_WhiteBaron';
			return 'None';
		}
		if (fam == 5)
		{
			if (tier == 1) return 'RS_CommonLSoul';
			if (tier == 2) return 'RS_GreenLSoul';
			if (tier == 3) return 'RS_BlueLSoul';
			if (tier == 4) return 'RS_PurpleLSoul';
			if (tier == 5) return 'RS_CyanLSoul';
			if (tier == 6) return 'RS_BrownLSoul';
			if (tier == 7) return 'RS_YellowLSoul';
			if (tier == 8) return 'RS_FireBluLSoul';
			if (tier == 9) return 'RS_GrayLSoul';
			if (tier == 10) return 'RS_RedLSoul';
			if (tier == 11) return 'RS_AbyssLsoul';
			if (tier == 12) return 'RS_BlackLSoul';
			if (tier == 13) return 'RS_WhiteLSoul';
			return 'None';
		}
		if (fam == 6)
		{
			if (tier == 1) return 'RS_CommonPE';
			if (tier == 2) return 'RS_GreenPE';
			if (tier == 3) return 'RS_BluePE';
			if (tier == 4) return 'RS_PurplePE';
			if (tier == 5) return 'RS_CyanPE';
			if (tier == 6) return 'RS_BrownPE';
			if (tier == 7) return 'RS_YellowPE';
			if (tier == 8) return 'RS_FireBluPE';
			if (tier == 9) return 'RS_GrayPE';
			if (tier == 10) return 'RS_RedPE';
			if (tier == 11) return 'RS_AbyssPE';
			if (tier == 12) return 'RS_BlackPE';
			if (tier == 13) return 'RS_WhitePE';
			return 'None';
		}
		if (fam == 7)
		{
			if (tier == 1) return 'RS_CommonCybie';
			if (tier == 2) return 'RS_GreenCybie';
			if (tier == 3) return 'RS_BlueCybie';
			if (tier == 4) return 'RS_PurpleCybie';
			if (tier == 5) return 'RS_CyanCybie';
			if (tier == 6) return 'RS_BrownCybie';
			if (tier == 7) return 'RS_YellowCybie';
			if (tier == 8) return 'RS_FireBluCybie';
			if (tier == 9) return 'RS_GrayCybie';
			if (tier == 10) return 'RS_RedCybie';
			if (tier == 11) return 'RS_AbyssCybie';
			if (tier == 12) return 'RS_BlackCybie';
			if (tier == 13) return 'RS_WhiteCybie';
			return 'None';
		}
		if (fam == 8)
		{
			if (tier == 1) return 'RS_CommonMind';
			if (tier == 2) return 'RS_GreenMind';
			if (tier == 3) return 'RS_BlueMind';
			if (tier == 4) return 'RS_PurpleMind';
			if (tier == 5) return 'RS_CyanMind';
			if (tier == 6) return 'RS_BrownMind';
			if (tier == 7) return 'RS_YellowMind';
			if (tier == 8) return 'RS_FireBluMind';
			if (tier == 9) return 'RS_GrayMind';
			if (tier == 10) return 'RS_RedMind';
			if (tier == 11) return 'RS_AbyssMind';
			if (tier == 12) return 'RS_BlackMind';
			if (tier == 13) return 'RS_WhiteMind';
			return 'None';
		}
		if (fam == 9)
		{
			if (tier == 1) return 'RS_CommonDemon';
			if (tier == 2) return 'RS_GreenDemon';
			if (tier == 3) return 'RS_BlueDemon';
			if (tier == 4) return 'RS_PurpleDemon';
			if (tier == 5) return 'RS_CyanDemon';
			if (tier == 6) return 'RS_BrownDemon';
			if (tier == 7) return 'RS_YellowDemon';
			if (tier == 8) return 'RS_FireBluDemon';
			if (tier == 9) return 'RS_GrayDemon';
			if (tier == 10) return 'RS_RedDemon';
			if (tier == 11) return 'RS_AbyssDemon';
			if (tier == 12) return 'RS_BlackDemon';
			if (tier == 13) return 'RS_WhiteDemon';
			return 'None';
		}
		if (fam == 10)
		{
			if (tier == 1) return 'RS_CommonCaco';
			if (tier == 2) return 'RS_GreenCaco';
			if (tier == 3) return 'RS_BlueCaco';
			if (tier == 4) return 'RS_PurpleCaco';
			if (tier == 5) return 'RS_CyanCaco';
			if (tier == 6) return 'RS_BrownCaco';
			if (tier == 7) return 'RS_YellowCaco';
			if (tier == 8) return 'RS_FireBluCaco';
			if (tier == 9) return 'RS_GrayCaco';
			if (tier == 10) return 'RS_RedCaco';
			if (tier == 11) return 'RS_AbyssCaco';
			if (tier == 12) return 'RS_BlackCaco';
			if (tier == 13) return 'RS_WhiteCaco';
			return 'None';
		}
		if (fam == 11)
		{
			if (tier == 1) return 'RS_CommonHK';
			if (tier == 2) return 'RS_GreenHK';
			if (tier == 3) return 'RS_BlueHK';
			if (tier == 4) return 'RS_PurpleHK';
			if (tier == 5) return 'RS_CyanHK';
			if (tier == 6) return 'RS_BrownHK';
			if (tier == 7) return 'RS_YellowHK';
			if (tier == 8) return 'RS_FireBluHK';
			if (tier == 9) return 'RS_GrayHK';
			if (tier == 10) return 'RS_RedHK';
			if (tier == 11) return 'RS_AbyssHK';
			if (tier == 12) return 'RS_BlackHK';
			if (tier == 13) return 'RS_WhiteHK';
			return 'None';
		}
		if (fam == 12)
		{
			if (tier == 1) return 'RS_CommonSP1';
			if (tier == 2) return 'RS_GreenSP1';
			if (tier == 3) return 'RS_BlueSP1';
			if (tier == 4) return 'RS_PurpleSP1';
			if (tier == 5) return 'RS_CyanSP1';
			if (tier == 6) return 'RS_BrownSP1';
			if (tier == 7) return 'RS_YellowSP1';
			if (tier == 8) return 'RS_FireBluSP1';
			if (tier == 9) return 'RS_GraySP1';
			if (tier == 10) return 'RS_RedSP1';
			if (tier == 11) return 'RS_AbyssSP1';
			if (tier == 12) return 'RS_BlackSP1';
			if (tier == 13) return 'RS_WhiteSP1';
			return 'None';
		}
		if (fam == 13)
		{
			if (tier == 1) return 'RS_CommonImp';
			if (tier == 2) return 'RS_GreenImp';
			if (tier == 3) return 'RS_BlueImp';
			if (tier == 4) return 'RS_PurpleImp';
			if (tier == 5) return 'RS_CyanImp';
			if (tier == 6) return 'RS_BrownImp';
			if (tier == 7) return 'RS_YellowImp';
			if (tier == 8) return 'RS_FireBluImp';
			if (tier == 9) return 'RS_GrayImp';
			if (tier == 10) return 'RS_RedImp';
			if (tier == 11) return 'RS_AbyssImp';
			if (tier == 12) return 'RS_BlackImp';
			if (tier == 13) return 'RS_WhiteImp';
			return 'None';
		}
		if (fam == 14)
		{
			if (tier == 1) return 'RS_CommonSG';
			if (tier == 2) return 'RS_GreenSG';
			if (tier == 3) return 'RS_BlueSG';
			if (tier == 4) return 'RS_PurpleSG';
			if (tier == 5) return 'RS_CyanSG';
			if (tier == 6) return 'RS_BrownSG';
			if (tier == 7) return 'RS_YellowSG';
			if (tier == 8) return 'RS_FireBluSG';
			if (tier == 9) return 'RS_GraySG';
			if (tier == 10) return 'RS_RedSG';
			if (tier == 11) return 'RS_AbyssSG';
			if (tier == 12) return 'RS_BlackSG';
			if (tier == 13) return 'RS_WhiteSG';
			return 'None';
		}
		if (fam == 15)
		{
			if (tier == 1) return 'RS_CommonSpectre';
			if (tier == 2) return 'RS_GreenSpectre';
			if (tier == 3) return 'RS_BlueSpectre';
			if (tier == 4) return 'RS_PurpleSpectre';
			if (tier == 5) return 'RS_CyanSpectre';
			if (tier == 6) return 'RS_BrownSpectre';
			if (tier == 7) return 'RS_YellowSpectre';
			if (tier == 8) return 'RS_FireBluSpectre';
			if (tier == 9) return 'RS_GraySpectre';
			if (tier == 10) return 'RS_RedSpectre';
			if (tier == 11) return 'RS_AbyssSpectre';
			if (tier == 12) return 'RS_BlackSpectre';
			if (tier == 13) return 'RS_WhiteSpectre';
			return 'None';
		}
		if (fam == 16)
		{
			if (tier == 1) return 'RS_CommonZombie';
			if (tier == 2) return 'RS_GreenZombie';
			if (tier == 3) return 'RS_BlueZombie';
			if (tier == 4) return 'RS_PurpleZombie';
			if (tier == 5) return 'RS_CyanZombie';
			if (tier == 6) return 'RS_BrownZombie';
			if (tier == 7) return 'RS_YellowZombie';
			if (tier == 8) return 'RS_FireBluZombie';
			if (tier == 9) return 'RS_GrayZombie';
			if (tier == 10) return 'RS_RedZombie';
			if (tier == 11) return 'RS_AbyssZombie';
			if (tier == 12) return 'RS_BlackZombie';
			if (tier == 13) return 'RS_WhiteZombie';
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

	// [11-11 ladder renumber] EX FORMS. A boss's EX build (RS_BlackImpEX, RS_WhiteSGEX ...) is in neither table: it
	// belongs to the gate it came from (RS_BlackImpEX -> RS_BlackImp; the spider's RS_BlackSPEX -> RS_BlackSP1), so it
	// has that gate's family and tier. Without this a tier change asked of an EX body (RSQ Miniboss: a life lost)
	// found no family and did nothing.
	static bool IsEXName(String n)
	{
		return n.Length() > 2 && n.Mid(n.Length() - 2) == "EX";
	}

	static int FamilyOfAny(String n)
	{
		int f = FamilyOf(n);
		if (f >= 0 || !IsEXName(n)) return f;
		String g = n.Left(n.Length() - 2);
		f = FamilyOf(g);
		if (f < 0) f = FamilyOf(g .. "1");
		return f;
	}

	static int TierOfAny(String n)
	{
		int t = TierOf(n);
		if (t > 0 || !IsEXName(n)) return t;
		String g = n.Left(n.Length() - 2);
		t = TierOf(g);
		if (t <= 0) t = TierOf(g .. "1");
		return t;
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
// STAGGERED BY DEFAULT, for two reasons: it spreads
// a roomful of retiers over many tics instead of spiking one frame, and a
// monster that flashes and THEN changes reads as deliberate where one that
// snaps reads as a bug. Delay is random 5..25 tics, so a room ripples.
//
// THE TELL is HF's tier-change flash (owner 2026-11-09: "flash is important,
// it's how monsters change tier in real time"; it applies to ALL RSQ monsters),
// ported from HF_Monster.zs SetTier/Tick: a random 5..25-tic wait, and every 3
// tics the monster alternates between the flash translation (rs_tier_flashwhite,
// or rs_tier_flashblack when the target tier is White, 13) and its ORIGINAL
// translation, saved at job start and restored (some CH colours carry one).
// Then the swap.
// The flash phase is FULL-BRIGHT (bBRIGHT on; 2026-11-12, owner: "why don't the
// monsters flash like they're supposed to?"). A sprite is lit by its sector, so
// without it the white phase was dim grey in a dark room and all but vanished in
// coloured light (rig run flash1: in a red room the imp seemed to blink out).
// The own-colour phase gives back the monster's own bBRIGHT, saved at job start
// like origTrans, and every way the job ends (the swap, the monster dying or
// vanishing mid-flash, the job destroyed) gives back both. Black (target White)
// stays black: a bright black is still black.
// (Before HF's flash this was a bBRIGHT flicker alone, 45..105 tics.)
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
		// [11-13 BD tiering] a Brutal Doom / XMVE / plain monster on the ladder in place (RS_BDTier.zs): the same flash,
		// then its kit moves; no swap
		if (RS_BDKit.Of(mo)) { RequestKit(mo, tier, instant); return; }
		String mn = mo.GetClassName();
		int fam = RS_TierLadder.FamilyOfAny(mn);
		if (fam < 0) return;              // not one of ours (the ColorfulHell ladder; an EX form by its gate)
		if (TierNowOf(mo) == tier && !JobFor(mo)) return;

		if (instant)
		{
			Swap(mo, tier, true);
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
		nj.origBright = mo.bBRIGHT;
	}

	// [11-13 BD tiering] The in-place tier change. `rung` is the kit's place on the ladder and may pass 13: every
	// rung past White is an EX step (design/BD_XMVE_TIERING.md section 6). Never below the monster's entry colour.
	static void RequestKit(Actor mo, int rung, bool instant = false)
	{
		let k = RS_BDKit.Of(mo);
		if (!k || mo.health <= 0) return;
		rung = max(k.entry, rung);
		let j = JobFor(mo);
		if (instant)
		{
			if (j) { j.RestoreLook(); j.mo = null; j.Destroy(); }
			k.SetRung(rung, true);
			return;
		}
		if (j) { j.targetTier = min(13, rung); j.kitRung = rung; return; }
		if (rung == k.rung) return;
		let nj = RS_RetierJob(new("RS_RetierJob"));
		nj.mo         = mo;
		nj.targetTier = min(13, rung);
		nj.kitRung    = rung;
		nj.timer      = random(5, 25);
		nj.ticker     = 0;
		// its look between flashes: its tier tint (with a painted frame drawn it wears no translation at all; RS_BDArt.zs
		// draws the painted frame again over the tint)
		nj.origTrans  = k.rung > k.entry ? k.tierTrans : mo.Translation;
		nj.origBright = mo.bBRIGHT;
	}

	// RSQ Monsters > "On tier change" (rsq_mon_retier_health, owner 2026-11-09):
	//   0 keep the health fraction already lost
	//   1 full health on an INSTANT tier only, the fraction on a live one (HF's rule, default)
	//   2 always full health
	// Read by Swap.
	static bool FullHealth(bool instant)
	{
		let cv = CVar.FindCVar("rsq_mon_retier_health");
		int mode = cv ? cv.GetInt() : 1;
		return mode >= 2 || (mode == 1 && instant);
	}

	// The tier an actor is on: its ColorfulHell class's place on the ladder (an EX form: its gate's).
	static int TierNowOf(Actor mo)
	{
		if (!mo) return -1;
		String n = mo.GetClassName();
		if (RS_TierLadder.FamilyOfAny(n) >= 0)
			return RS_TierLadder.TierOfAny(n);
		let k = RS_BDKit.Of(mo);          // [11-13 BD tiering] in place: the kit's colour
		if (k) return k.Tier();
		return -1;
	}

	// [11-13 fix 4, design/BD_XMVE_TIERING.md 8.4] LADDER HEALTH. 43 single steps up Colourful Hell's ladder LOSE health
	// (Brown Imp 215 -> Yellow 145). The class defaults stay Colourful Hell's (a natural spawn at world tier 1 keeps its
	// numbers); a body on the ladder by a tier change or a world tier above 1 gets the family's running maximum, +5% a
	// step (RS_BDTierData.Envelope, generated from design/tiering/data/hp_drops.json). 41 are lifted; two keep their
	// own (the Gray Lost Soul hive, the Cyan Zombie), and Black and White keep Colourful Hell's boss health.
	static void LadderHealth(Actor a, int fam, int tier)
	{
		if (!a) return;
		int env = RS_BDTierData.Envelope(fam, tier);
		if (env <= 0 || env <= a.default.health || a.StartHealth == env) return;
		bool fresh = a.health == a.GetSpawnHealth();
		a.StartHealth = env;
		if (fresh) a.health = a.GetSpawnHealth();
	}

	// the world tier (RS_BDTier.zs: rsq_mon_worldtier while no turn-in code exists), 1 with the ladder switched off
	static int WorldTier()
	{
		let on = CVar.FindCVar('rsq_mon_bdtier');
		if (on && !on.GetBool()) return 1;
		let w = CVar.FindCVar('rsq_mon_worldtier');
		return w ? clamp(w.GetInt(), 1, 40) : 1;
	}

	// The swap. Returns the new monster, or null if nothing changed.
	static Actor Swap(Actor mo, int tier, bool instant = false)
	{
		if (!mo) return null;
		String mn = mo.GetClassName();
		int fam = RS_TierLadder.FamilyOfAny(mn);
		if (fam < 0) return null;
		// already on that tier: nothing (an EX body re-asked its own tier keeps its EX build, never swapped to the plain one)
		if (RS_TierLadder.TierOfAny(mn) == tier) return null;
		Name nn = RS_TierLadder.ClassFor(fam, tier);
		if (nn == 'None') return null;
		Class<Actor> nc = nn;
		if (!nc || nc == mo.GetClass()) return null;

		// Carry the WOUND, not the number. Health belongs to the class, so a
		// tier-up must take the new class's health -- that is the point. What
		// survives is the fraction already lost, so a retier is neither a free
		// heal nor an instant kill.
		// [11-13 fix 1, design/BD_XMVE_TIERING.md 8.1] against the body's REAL full health (the skill's MonsterHealth and
		// any StartHealth another mod set), not the class default: on a skill with MonsterHealth 0.5 the old sum read a
		// healthy monster as half dead.
		double frac = 1.0;
		int oldFull = RS_Carry.PeakOf(mo);   // [11-13 fix 2] a LegenDoom legendary's full health is its legendary health
		if (oldFull > 0)
			frac = clamp(double(mo.health) / double(oldFull), 0.05, 1.0);

		Actor a = Actor.Spawn(nc, mo.pos, NO_REPLACE);
		if (!a) return null;
		// [11-13 fix 4] a body that got its colour from a tier change stands on the family's ladder health, so a step
		// up never loses health; and it is marked, so the world tier does not raise it a second time as it spawns
		LadderHealth(a, fam, tier);
		a.GiveInventory("RS_WorldMark", 1);

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

		// [11-13 fix 1] the new body's own full health as the engine spawned it (skill-scaled), not the class default
		// written over it: Black Metal (0.8) bodies came out 25% too tough, Realism (0.5) ones twice as tough.
		int newFull = a.GetSpawnHealth();
		if (newFull > 0)
			a.health = FullHealth(instant) ? newFull : max(1, int(newFull * frac));

		// [11-09 score-fix] RSQ Score's census: the new body takes the old one's place (design/SCORE_EXPANSION.md
		// A2). Score pays a full base only for a monster on its map census and the fraction for anything spawned
		// later, and this IS a new actor -- so every CH colour change paid the fraction. Moved, not added: only a
		// body that was counted passes it on, once. By name, so each mod still loads alone.
		ScoreHandOver(mo, a);

		// [11-13 fix 2, RS_Carry.zs] what the other mods made of the old body goes with it: its Champions champion, its
		// LegenDoom legendary, Universal Entropy's size, RSQ's own marks
		RS_Carry.Take(mo, a, frac);

		// It was already awake and fighting -- do not make it re-notice.
		if (mo.target && a.SeeState)
			a.SetState(a.SeeState);

		// The old body leaves without counting as a kill and without paying
		// out: it did not die, it became something else.
		mo.ClearCounters();
		mo.Destroy();
		return a;
	}

	// [11-09 score-fix] RS_ScoreService "census.take" then "census.add" (RSQ Score awards.zs). Nothing when Score
	// is not loaded.
	static void ScoreHandOver(Actor from, Actor to)
	{
		if (!from || !to) return;
		let sc = ServiceIterator.Find("RS_ScoreService").Next();
		if (sc && sc.GetInt("census.take", "", 0, 0, from) == 1)
			sc.GetInt("census.add", "", 0, 0, to);
	}
}

class RS_RetierJob : Thinker
{
	Actor mo;
	int   targetTier, timer, ticker;
	int   kitRung;             // [11-13 BD tiering] > 0: an in-place change (RS_BDKit), the rung to give; 0: the ColorfulHell swap
	TranslationID origTrans;   // the monster's own colour, restored between flashes
	bool  origBright;          // the monster's own bBRIGHT, restored between flashes and at every exit

	// The monster's own look: its colour and its own brightness.
	void RestoreLook()
	{
		if (!mo) return;
		mo.Translation = origTrans;
		mo.bBRIGHT     = origBright;
	}

	// Every exit path ends here, including a job destroyed from outside (a level
	// change, a save loaded over it): the monster never keeps the flash's full-bright.
	// After the swap mo is the destroyed old body and reads null: nothing to do.
	override void OnDestroy()
	{
		RestoreLook();
		Super.OnDestroy();
	}

	override void Tick()
	{
		if (!mo || mo.health <= 0)
		{
			Destroy();                 // OnDestroy gives a monster that died mid-flash its own look back
			return;
		}
		if (level.isFrozen()) return;

		// HF_Monster.Tick, verbatim in shape: every 3 tics the target tier's
		// flash colour, FULL-BRIGHT so it reads white in any light, then the
		// monster's own colour at its own brightness.
		ticker++;
		// PHOTOSENSITIVE MODE (RSQ Accessibility rsqa_photosafe, owner 2026-11-12 "Yes, calm it"): no flicker; the monster
		// holds the flash colour, full-bright, for the whole wait, then changes
		RS_LookKeep.Hold(mo);      // [11-13 fix 6] the flash is ours: the tier colour keepers leave it alone
		bool calm = false;
		{ Name an = "RSQA_Menu"; class<Object> ac = an; if (ac) { let pc = CVar.FindCVar('rsqa_photosafe'); calm = pc && pc.GetInt() != 0; } }
		if (calm || (ticker / 3) % 2 == 0)
		{
			mo.A_SetTranslation(targetTier == 13 ? "rs_tier_flashblack" : "rs_tier_flashwhite");   // 13 White (was 11 before the 11-11 renumber)
			mo.bBRIGHT = true;
		}
		else
			RestoreLook();

		if (timer > 0) timer--;
		if (timer <= 0)
		{
			RestoreLook();             // before the swap: if nothing changes, the monster stays as it was
			int was = RS_Retier.TierNowOf(mo);   // RSQ Score read-out (RS_ScoreReadout.zs): the tier it leaves
			if (kitRung > 0)
			{
				// [11-13 BD tiering] the same body: its kit moves, and the job lets go of it first so that
				// OnDestroy does not put the old tint back over the new one
				let k = RS_BDKit.Of(mo);
				let body = mo;
				mo = null;
				if (k) { k.SetRung(kitRung, false); RS_TierStamp.Put(body, was); }
				Destroy();
				return;
			}
			RS_TierStamp.Put(RS_Retier.Swap(mo, targetTier), was);          // RSQ Score read-out: stamp the new body
			Destroy();
		}
	}
}

// ----------------------------------------------------------------------------
//   netevent rs_tierof          print what the aimed monster is
//   netevent rs_retier 7        aimed monster becomes tier 7 (Yellow)
//   netevent rs_retier_up       aimed monster goes up one tier (one step stronger)
//   netevent rs_retier_all 9    every monster in the map becomes tier 9 (Gray)
// RS_RetierHandler must also be in MAPINFO's AddEventHandlers.
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// [11-11 ladder renumber] A SAVE FROM BEFORE THE RENUMBER. Its monsters carry the
// tier token CH's old number gave them (a Yellow imp 5, which now reads Cyan), and a
// running flash or a fresh tier stamp holds old numbers too. Each level gets one
// RS_LadderMark the first time it loads on this version; a level that loads from a
// save (or a hub level re-entered) WITHOUT one is from before, so its numbers are
// moved to the strength ladder once, here, and it gets its mark. A new map needs
// nothing (its monsters set the new numbers as they spawn).
// ----------------------------------------------------------------------------
class RS_LadderMark : Thinker {}

// [11-13] on a ColorfulHell body that came out of a tier change: the world tier is already in its colour
class RS_WorldMark : Inventory
{
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
}

class RS_RetierHandler : EventHandler
{
	// CH's listing order (the numbers before 11-11) -> the strength ladder
	static int OldToNew(int t)
	{
		switch (t)
		{
			case 5:  return 7;    // Yellow
			case 6:  return 10;   // Red
			case 7:  return 8;    // FireBlu
			case 8:  return 9;    // Gray
			case 9:  return 11;   // Abyss
			case 10: return 12;   // Black
			case 11: return 13;   // White
			case 12: return 5;    // Cyan
			case 13: return 6;    // Brown
		}
		return t;                 // 1-4 (Common, Green, Blue, Purple) and anything else stay
	}

	// NO FROZEN STATUES (owner 2026-11-12 14:11: "sometimes when i kill an imp it dies as a frozen purple imp"; rig, run
	// ice0: an RS_CommonImp killed by Ice damage stood as a dark blue statue for good). Ice damage (LegenDoom's Freezing
	// guns and its freezing blast, this pack's cyan monsters hitting other monsters) on a monster with no ice death of
	// its own makes the engine freeze it where it stands, and Doom has no shatter to end that. Every monster of this pack
	// now dies its own death from ice (NOICEDEATH, as Brutal Doom's monsters have). The cyan ones had it already.
	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || !a.bIsMonster) return;
		String cn = a.GetClassName();
		if (!(cn.Left(3) ~== "RS_")) return;
		a.bNOICEDEATH = true;

		// [11-13 world tier for ColorfulHell, design/BD_XMVE_TIERING.md 7.1] A ColorfulHell monster at world tier S
		// stands S - 1 colours above its natural roll, on ladder health. A capped family got its raised class when it
		// was chosen (RS_RosterHandler.CheckReplacement: no second body). A family rolling on its own dial is only
		// known now, so a map-load spawn of one is swapped here, instantly. A body from a tier change carries
		// RS_WorldMark and is left alone.
		int world = RS_Retier.WorldTier();
		if (world <= 1 || a.health <= 0 || a.bFRIENDLY) return;
		int fam = RS_TierLadder.FamilyOfAny(cn);
		if (fam < 0) return;
		int tier = RS_TierLadder.TierOfAny(cn);
		if (!a.FindInventory("RS_WorldMark") && level.maptime <= 1 && RS_RosterHandler.DialUncapped(fam))
		{
			int want = min(RS_TierLadder.MaxTier(), tier + world - 1);
			if (want > tier && RS_Retier.Swap(a, want, true)) return;
		}
		RS_Retier.LadderHealth(a, fam, tier);
	}

	override void WorldLoaded(WorldEvent e)
	{
		let mk = ThinkerIterator.Create("RS_LadderMark");
		if (mk.Next()) return;
		if (e.IsSaveGame || e.IsReopen)
		{
			int n = 0;
			ThinkerIterator it = ThinkerIterator.Create("Actor");
			Actor a;
			while (a = Actor(it.Next()))
			{
				let tok = a.FindInventory("RS_ZomTierToken");
				if (tok && tok.Amount > 0) { int nt = OldToNew(tok.Amount); if (nt != tok.Amount) { tok.Amount = nt; n++; } }
				let st = RS_TierStamp(a.FindInventory("RS_TierStamp"));
				if (st) { st.fromTier = OldToNew(st.fromTier); st.toTier = OldToNew(st.toTier); }
			}
			ThinkerIterator ji = ThinkerIterator.Create("RS_RetierJob", Thinker.STAT_DEFAULT);
			RS_RetierJob j;
			while (j = RS_RetierJob(ji.Next())) j.targetTier = OldToNew(j.targetTier);
			if (n > 0) Console.Printf("RSQ Monsters: a save from before the 11-11 ladder renumber: %d monsters' tiers moved to the strength ladder", n);
		}
		new("RS_LadderMark");
	}

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
			String an = a.GetClassName();
			int f = RS_TierLadder.FamilyOfAny(an);
			Console.Printf("RETIER: %s -- family %s, tier %d", an,
				f >= 0 ? String.Format("%s", RS_TierLadder.DialOf(f)) : "not ours",
				f >= 0 ? RS_TierLadder.TierOfAny(an) : 0);
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
