// ============================================================================
// RS_Spectre.zs -- Colourful Hell Spectre family, native ZScript.
// Source: C:\Users\Command\Desktop\CH\decorate\spectres.txt (1,722 lines,
// read whole). Every actor cites its CH line. Support: RS_SpectreFX.zs
// (see its header for the parallel-lane note, the PESPEED rebuild, and the
// frames/sounds silent in CH itself: SLGM "\", Shadow/active, Shadow/pain,
// Worm/Death, Worm/Hurt. NOTE: RS_SpectreFX.zs's header still calls SLGM F
// and SLGM "\" "proven missing"; that is now wrong on both counts and this
// lane could not edit that file -- see the next block.)
//
// STOPGAP 2026-08-06 -- SLGM F -> SLGM E, two sites (RS_WhiteSpectre2 See
// and PeekUp, CH spectres.txt:1471 and :1491). Held E for F's beat so the
// slug is not invisible mid-rise; frame counts, tic totals and action-call
// counts are unchanged at both sites. READ THE NEXT PARAGRAPH BEFORE
// TOUCHING THESE TWO LINES AGAIN -- this is a stopgap, not the real fix.
//
// THE ART EXISTS AND WAS NEVER COPIED IN. The lump is
//   E:\New folder\ART SOURCE\SPRITES\spectre\SLGMF0^0
// -- a real 32x31 PNG of the slug, with the extension stripped, sitting
// exactly between E (33x28) and G (22x31) in the rise. It is a MIRRORED
// lump: "SLGM" + "F0" + "^0" defines frame F rot 0 AND frame "^" rot 0,
// and "^" is GZDoom's on-disk escape for the "\" character (frame 27) --
// see the CLAUDE.md note on VILE^1.lmp. So this ONE file supplies BOTH
// frames this family has been carrying as "proven missing in CH itself":
// SLGM F and SLGM "\". It is the only caret-named CH sprite in the whole
// ART SOURCE tree, which is why every previous pass missed it -- the
// folder rips at CH\sprites\trashmon and CHP\sprites\dem&spec both drop
// it, the same extractor failure CLAUDE.md records for the archvile's
// "\" frames.
//
// THE REAL FIX, when the owner clears it -- copy that one file to
//   E:\RS_Main\sprites\rs_spectre\SLGMF0^0.png
// (byte copy; do NOT "correct" the ^ to a backslash), then revert both
// sites to CH verbatim -- "SLGM ABCDEFGHHHVWXY 4 A_Chase" and
// "SLGM ABCDEFG 4" -- and revert the TNT1 placeholder in PeekUp below to
// CH's "SLGM \ 5". That last one still needs care: a quoted frame string
// with an escaped character is a parse error on this engine, so use an
// unquoted single backslash frame or keep the TNT1 timing hold.
//
// RESOLVED 2026-08-06 -- SPG2 -> SRG2 (RS_YellowSpectre Melee, below).
// CH spectres.txt:881 is the only SPG2 reference in the whole CH tree and no
// SPG2* lump exists in CH, in sprites/, or in either IWAD, so it rendered
// nothing. Proof it means SRG2: CH's YellowDemon is the same monster with
// +STEALTH removed (same SRG2 body, same "Demon1" species, same blooddemon/*
// sounds, same CH_Berserk drop, same Var int User_Calm, same yellow
// Translation), and its Melee state carries the twin of this line token for
// token -- Demons.txt:1516 `SRG2 G 1 A_SetUserVar("User_Calm",User_Calm == 1)`
// against spectres.txt:881 `SPG2 G 1 A_SetUserVar("User_Calm",User_Calm == 1)`.
// One character differs. The spectre file is a copy of the demon file and the
// copy mistyped SR as SP. Owner's rule: nothing invisible.
// Tier ladder as before: 1 Common .. 13 Brown (CH icon index); FireBlu
// inherits its tier from the demons lane's RS_FireBluDemon2 (CH icon 7).
// Announcers dropped per owner.
// ============================================================================

// ---------------------------------------------------------------------------
// The spawn dial.  CH: spectres.txt:1 -- Colourset6 replaces Spectre.
// ---------------------------------------------------------------------------
class RS_SpectreColourset : RandomSpawner replaces Spectre
{
	Default
	{
		DropItem "RS_CommonSpectre", 255, 510;
		DropItem "RS_GreenSpectre", 255, 400;
		DropItem "RS_CyanSpectre", 255, 100;
		DropItem "RS_BlueSpectre", 255, 155;
		DropItem "RS_FireBluSpectre", 255, 70;
		DropItem "RS_PurpleSpectre", 255, 100;
		DropItem "RS_BrownSpectre", 255, 100;
		DropItem "RS_GraySpectre", 255, 45;
		DropItem "RS_YellowSpectre", 255, 40;
		DropItem "RS_AbyssSpectre", 255, 40;
		DropItem "RS_RedSpectre", 255, 33;
		DropItem "RS_BlackSpectre", 255, 4;
		DropItem "RS_WhiteSpectre", 255, 1;
	}
}

// ---------------------------------------------------------------------------
// Cvar-gated stubs.  Same gates and semantics as the other families.
// ---------------------------------------------------------------------------
class RS_BrownSpectre : Actor   // CH spectres.txt:18
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_brown', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_brown', 1) == 3, "Fifty");
		Goto Third;
	Fifty:
		TNT1 A 0 A_Jump(128, "Third");
	First:
		TNT1 A 0 A_SpawnItemEx("RS_SpectreColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BrownSpectre2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_CyanSpectre : Actor   // CH spectres.txt:144
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_cyan', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_cyan', 1) == 3, "Fifty");
		Goto Third;
	Fifty:
		TNT1 A 0 A_Jump(128, "Third");
	First:
		TNT1 A 0 A_SpawnItemEx("RS_SpectreColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_CyanSpectre2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_FireBluSpectre : Actor   // CH spectres.txt:303 -- CH: CallACS("CH_FireBLUES")
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_fireblu', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_SpectreColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_FireBluSpectre2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_AbyssSpectre : Actor   // CH spectres.txt:324 -- CH: CallACS("CH_Abyssmal").
// The abyss body IS the demon family's: CH spawns AbyssDemon2 here too.
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_abyss', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_abyss', 1) == 3, "Fifty");
		Goto Third;
	Fifty:
		TNT1 A 0 A_Jump(128, "Third");
		Goto First;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_SpectreColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_GraySpectre : Actor   // CH spectres.txt:347 -- CH: CallACS("CH_Grayscale")
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_gray', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_SpectreColourset",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_GraySpectre2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_BlackSpectre : Actor   // CH spectres.txt:1056 -- CH: CallACS("CH_BlackBossy")
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_blackboss', 1) == 1, "First");
		Goto Third;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_BlackSpectre2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_RedSpectre",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

class RS_WhiteSpectre : Actor   // CH spectres.txt:1389 -- CH: CallACS("CH_WhiteBossy")
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_whiteboss', 1) == 1, "First");
		TNT1 A 0;
		Goto Third;
	First:
		TNT1 A 0 A_SpawnItemEx("RS_WhiteSpectre2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	Third:
		TNT1 A 0 A_SpawnItemEx("RS_BlackSpectre",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 13 -- BROWN ("Brown hide").  CH: spectres.txt:40.  The pack marshal:
// rallies demonkind, heals the room, war-cries the pack.
// ---------------------------------------------------------------------------
class RS_BrownSpectre2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 13); }
	Default
	{
		Health 300;
		BloodColor "gray";
		PainChance 33;
		Species "Demon1";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "Fire", 1.25;
		PainChance "DIMp", 0;
		Speed 17;
		Radius 30;
		Height 56;
		Damage 2;
		Mass 800;
		RenderStyle "Translucent";
		Alpha 0.15;
		Monster;
		+FLOORCLIP
		+NOFEAR
		+DONTHARMCLASS
		+NOINFIGHTING
		DropItem "RS_CH_Berserk", 50;
		MeleeRange 64;
		SeeSound "BPinky/Sight";
		DeathSound "BPinky/Death";
		ActiveSound "Barks";
		PainSound "BPinky/Pain";
		Obituary "%o was too loud to brown spectre.";
		Tag "Brown hide";
	}
	States
	{
	Spawn:
		BPWA ABCD 4 A_Look;
		Loop;
	See:
		BPWA AABBCCDD 2 A_Chase;
		TNT1 A 0 A_Jump(16,"CheckFriends");
		Loop;
	CheckFriends:
		TNT1 A 0 A_CheckSight("Meh");
		TNT1 A 0 A_CheckProximity("Scatter","Demon",300,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_CheckProximity("Scatter","Spectre",300,1,CPXF_ANCESTOR|CPXF_CHECKSIGHT);
		TNT1 A 0 A_PlaySound("BPinky/Idle");
		BPBI AC 5;
	Meh:
		BPWA AABBCCDD 2 A_Wander;
		Goto See;
	Melee:
		TNT1 A 0 A_PlaySound("BPinky/Bite");
		BPBI AB 6 A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		BPBI C 6 A_CustomMeleeAttack(random(1,10) * 8 + random(1,10),"Bite/bite4","","Melee");
		Goto See;
	Scatter:
		TNT1 A 0 A_RadiusGive("RS_BrownImpCommand",320,RGF_MONSTERS|RGF_EXFILTER,1,"RS_BrownSpectre2","Demon1");
		TNT1 A 0 A_RadiusGive("RS_BrownImpCommand",320,RGF_MONSTERS|RGF_EXFILTER,1,"RS_BrownSpectre2","Spectre");
		TNT1 A 0 A_RadiusGive("RS_SpeedBuffPE",320,RGF_MONSTERS|RGF_EXFILTER,1,"RS_BrownSpectre2","Demon1");
		TNT1 A 0 A_RadiusGive("RS_SpeedBuffPE",320,RGF_MONSTERS|RGF_EXFILTER,1,"RS_BrownSpectre2","Spectre");
		TNT1 A 0 A_PlaySound("BPinky/Sight",0);
		BPBI AC 3 A_SpawnItemEx("RS_MediCacoBrown",random(-164,164),random(-164,164),random(8,64),random(1,9),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		BPBI A 3 A_RadiusGive("Health",1200,RGF_MONSTERS,200,null,"Spectre");
		BPBI C 3 A_RadiusGive("Health",1200,RGF_MONSTERS,200,null,"Demon1");
		BPBI ACAC 3 A_SpawnItemEx("RS_MediCacoBrown",random(-164,164),random(-164,164),random(8,64),random(1,9),0,random(-5,5),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_PlaySound("BPinky/Sight",0);
		BPBI ACAC 6;
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		BPPA A 2 A_Pain;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH13",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		TNT1 A 0 A_NoBlocking;
		TNT1 A 0 A_ScreamAndUnblock;
		BPDE ABCDEF 6;
		BPDE F -1;
		Stop;
	Raise:
		BPDE FEDCBA 6;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 12 -- CYAN ("Ice Worm II").  CH: spectres.txt:166.  The burrower:
// shrinks flat to hide, spikes in every direction, rams as a hiss.
// ---------------------------------------------------------------------------
class RS_CyanSpectre2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 12); }
	Default
	{
		Obituary "%o was stored for cold summer by cyan spectre";
		Health 270;
		PainChance 64;
		Speed 27;
		Radius 30;
		Height 56;
		Mass 400;
		Scale 0.95;
		DamageFactor "Wrangler", 3.0;
		DamageFactor "Melee", 2.0;
		DamageFactor "Fire", 1.5;
		DamageFactor "Ice", 0.15;
		DamageFactor "PLWater", 0.25;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainChance "PLWater", 2;
		PainChance "ice", 2;
		PainChance "Fire", 82;
		PainChance "Melee", 12;
		Damage 3;
		Species "Demon1";
		SeeSound "slimeworm/sight";
		AttackSound "slimeworm/melee";
		PainSound "slimeworm/pain";
		DeathSound "slimeworm/death";
		ActiveSound "slimeworm/active";
		BloodColor "Blue";
		Monster;
		+THRUSPECIES
		+FLOORCLIP
		+NOTARGETSWITCH
		+DONTHARMSPECIES
		+DONTHARMCLASS
		+NOTARGET
		+NOICEDEATH
		+LAXTELEFRAGDMG
		DamageFactor "Falling", 0.0;
		DropItem "RS_CH_Chainsaw", 64;
		Tag "Ice Worm II";
		Translation "0:255=%[0.07,0.35,0.87]:[1.01,2.00,2.00]";
		MeleeRange 64;
	}
	States
	{
	Spawn:
		WORM AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		WORM AABB 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(64,"HideMe");
		WORM CCDD 3 A_Chase;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 A_Jump(64,"HideMe");
		Loop;
	See2:
		WORM AABB 3 A_Chase;
		WORM CCDD 3 A_FastChase;
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WORM G 2 A_SetScale(1.0,0.25);
		WORM G 2 A_SetScale(1.0,0.5);
		WORM G 2 A_SetScale(1.0,1.0);
		TNT1 A 0 { bNOPAIN = false; }   // CH: A_ChangeFlag(NOPAIN,FALSE)
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(0,90));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(89,180));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(181,270));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(271,359));
		WORM E 8 A_FaceTarget;
		WORM E 0 A_JumpIfCloser(72,"Melee");
		WORM E 8 A_JumpIfCloser(700,"Hiss");
	HideMe:
		TNT1 A 0 { bNOPAIN = true; }   // CH: A_ChangeFlag(NOPAIN,TRUE)
		WORM G 2 A_SetScale(1.0,0.5);
		WORM G 2 A_SetScale(1.0,0.25);
		WORM G 2 A_SetScale(1.0,0.1);
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(0,90));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(89,180));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(181,270));
		TNT1 AAA 0 A_SpawnItemEx("RS_SpikeCyanRev",0,0,1,random(12,20),0,random(15,25),random(271,359));
		WORM G 8 A_SetSpeed(77);
		WORM AABBCCDD 2 A_Wander;
		WORM AABBCCDD 1 A_Wander;
		WORM G 5 A_SetSpeed(25);
		Goto See2;
	Melee:
		WORM G 1 A_SetScale(1.0,1.0);
		TNT1 A 0 { bNOPAIN = false; }   // CH: A_ChangeFlag(NOPAIN,FALSE)
		WORM EF 4 A_FaceTarget;
		TNT1 HHHHHHHHHH 0 A_SpawnItemEx("RS_SpikeCyanRev",16,0,24,random(9,33),0,random(3,9),frandom(-9,9));
		TNT1 HHHHHHHHHH 0 A_SpawnItemEx("RS_SpikeCyanRev",16,0,29,random(9,33),0,random(4,12),frandom(-4,4));
		WORM G 4 A_CustomMeleeAttack(random(25,75),"slimeworm/melee","none");
		Goto See;
	Hiss:
		WORM EF 4 A_FaceTarget;
		WORM G 8 A_SkullAttack(40);
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		WORM H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH12",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		WORM H 2 A_Pain;
		WORM H 2 A_Jump(232,"HideMe");
		Goto See;
	Death:
		WORM I 8;
		WORM J 8 A_Scream;
		WORM K 4;
		WORM L 4 A_NoBlocking(false);
		WORM M 4;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Cirno",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,253);
		WORM N 1 A_IceGuyDie;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 7 -- FIREBLU.  CH: spectres.txt:322 -- one line: the fireblu demon
// body with +STEALTH. Tier comes from the demons lane's RS_FireBluDemon2.
// ---------------------------------------------------------------------------
class RS_FireBluSpectre2 : RS_FireBluDemon2 { Default { +STEALTH } }

// ---------------------------------------------------------------------------
// TIER 8 -- GRAY ("Uhm").  CH: spectres.txt:366.  The low crawler:
// flattens out of sight, lobs the bouncing ice orb.
// ---------------------------------------------------------------------------
class RS_GraySpectre2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 8); }
	Default
	{
		BloodColor "Black";
		Species "Demon1";
		Health 450;
		Radius 30;
		Height 56;
		Mass 100;
		Speed 20;
		PainChance 128;
		RenderStyle "Add";
		Alpha 0.25;
		YScale 0.80;
		XScale 1.3;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		DamageFactor "Fire", 1.2;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		DamageFactor "ice", 0.2;
		PainChance "DIMp", 0;
		SeeSound "eatiidle";
		AttackSound "slimeworm/melee";
		PainSound "eatidown";
		DeathSound "slimeworm/death";
		ActiveSound "eati/run";
		Obituary "%o was grayscaled by gray spectre ";
		DropItem "RS_HealthBundle";
		DropItem "RS_HealthBundle";
		DropItem "BackPack", 78;
		Translation "Ice";
		MeleeRange 54;
		MeleeThreshold 252;
		Tag "Uhm";
	}
	States
	{
	Spawn:
		TRIT AB 10 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		TNT1 A 0 A_SetSpeed(20);
		TNT1 A 0 A_SetScale(1.30,0.80);
		TRIT ABBCCDDEE 3 A_Chase;
		TRIT A 0 A_Jump(12,"GetLow");
		Goto See+1;
	GetLow:
		TRIT A 0 A_CheckSight("GetLow2");
		Goto See;
	GetLow2:
		TNT1 A 0 A_SetSpeed(6);
		TNT1 A 0 A_SetScale(1.40,0.40);
		TRIT ABCDE 3 A_Wander;
		TRIT A 0 A_CheckSight("GetLow2");
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT E 5 Bright A_FaceTarget;
		TRIT F 4 Bright A_CustomMissile("RS_IceOrbCH2",48,0,random(-3,3));
		Goto See;
	Melee:
		TRIT E 4 Bright A_FaceTarget;
		TRIT F 2 Bright A_CustomMeleeAttack(random(9,39),"bite/bite4","None");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain.Ice:
		TRIT F 1;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT F 2 A_PlaySound("resistCH",8);
		Goto See;
	Pain:
		TRIT F 3;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH8",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TRIT F 3 A_Pain;
		Goto See+1;
	Death:
		TRIT J 20 A_ScreamAndUnblock;
		MISL BCD 10;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 1 -- COMMON ("Spectre").  CH: spectres.txt:514.  The vanilla spectre
// with the Demon1 species, the boner-egg death, and the grow-on-raise.
// ---------------------------------------------------------------------------
class RS_CommonSpectre : Spectre
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 1); }
	Default
	{
		PainChance 150;
		Species "Demon1";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		MeleeRange 54;
		Monster;
		Tag "Spectre";
	}
	States
	{
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SARG I 8;
		SARG J 8 A_Scream;
		SARG K 4;
		SARG L 4 A_NoBlocking;
		SARG M 4;
		SARG N -1;
		Stop;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Raise:
		SARG N 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SARG MLKJI 5;
		Goto See;
	Grow:
		SARG MLKJI 5;
		SARG A 0 A_SpawnItemEx("RS_GreenSpectre",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 2 -- GREEN.  CH: spectres.txt:567.
// ---------------------------------------------------------------------------
class RS_GreenSpectre : Spectre
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 2); }
	Default
	{
		Health 175;
		PainChance 130;
		Species "Demon1";
		BloodColor "Green";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Speed 12;
		Radius 30;
		Height 56;
		Mass 400;
		Monster;
		+FLOORCLIP
		RenderStyle "Add";
		Alpha 0.20;
		SeeSound "demon/sight";
		AttackSound "demon/melee";
		PainSound "demon/pain";
		DeathSound "demon/death";
		ActiveSound "demon/active";
		Obituary "%o was chewed by something green";
		MeleeRange 54;
		Translation "16:31=114:127","32:46=125:127","47:47=0:0","173:191=115:123";
		Tag "Green Spectre";
	}
	States
	{
	Spawn:
		SARG AB 10 A_Look;
		Loop;
	See:
		SARG AABBCCDD 2 Fast A_Chase;
		Loop;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG EF 7 Fast A_FaceTarget;
		SARG G 7 Fast A_CustomMeleeAttack(random(13,40),"Demon/melee","none");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SARG H 2 Fast;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH2",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG H 2 Fast A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SARG I 8;
		SARG J 8 A_Scream;
		SARG K 4;
		SARG L 4 A_NoBlocking;
		SARG M 4;
		SARG N -1;
		Stop;
	Raise:
		SARG N 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SARG MLKJI 5;
		Goto See;
	Grow:
		SARG MLKJI 5;
		SARG A 0 A_SpawnItemEx("RS_BlueSpectre",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 3 -- BLUE.  CH: spectres.txt:652.  Rushes when it can see you.
// ---------------------------------------------------------------------------
class RS_BlueSpectre : Spectre
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 3); }
	Default
	{
		Health 210;
		PainChance 110;
		Species "Demon1";
		BloodColor "blue";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Speed 14;
		Radius 30;
		Height 56;
		Mass 500;
		Monster;
		+FLOORCLIP
		+VISIBILITYPULSE
		SeeSound "demon/sight";
		AttackSound "demon/melee";
		PainSound "demon/pain";
		DeathSound "demon/death";
		ActiveSound "demon/active";
		Obituary "%o met some blue meat";
		RenderStyle "Add";
		MeleeRange 64;
		Translation "16:31=198:207","32:46=240:247","47:47=0:0","208:223=198:205","160:167=112:124","173:191=197:207";
		Tag "Blue Spectre";
	}
	States
	{
	Spawn:
		SARG AB 10 A_Look;
		Loop;
	See:
		SARG AABBCCDD 2 Fast A_Chase;
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG E 4 Bright A_JumpIfCloser(800,"Rush");
		Goto See;
	Rush:
		SARG F 1 A_FaceTarget;
		SARG F 3 A_SkullAttack(25);
		Goto See;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG EF 7 Fast A_FaceTarget;
		SARG G 7 Fast A_CustomMeleeAttack(random(15,43),"Demon/melee","none");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SARG H 2 Fast;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH3",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG H 2 Fast A_Pain;
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SARG I 8;
		SARG J 8 A_Scream;
		SARG K 4;
		SARG L 4 A_NoBlocking;
		SARG M 4;
		SARG N -1;
		Stop;
	Raise:
		SARG N 5 A_JumpIfInventory("RS_GrowRaisin",1,"Grow");
		SARG MLKJI 5;
		Goto See;
	Grow:
		SARG MLKJI 5;
		SARG A 0 A_SpawnItemEx("RS_PurpleSpectre",0,0,6,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETTARGET);
		TNT1 A 0 A_Die;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 4 -- PURPLE.  CH: spectres.txt:745.  Pain can trigger a rush.
// ---------------------------------------------------------------------------
class RS_PurpleSpectre : Spectre
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 4); }
	Default
	{
		Health 250;
		PainChance 80;
		BloodColor "Purple";
		Species "Demon1";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Speed 16;
		Radius 30;
		Height 56;
		Mass 500;
		Monster;
		+FLOORCLIP
		+NOFEAR
		+STEALTH
		SeeSound "demon/sight";
		Damage 3;
		AttackSound "demon/melee";
		PainSound "demon/pain";
		DeathSound "demon/death";
		ActiveSound "demon/active";
		Obituary "%o got purple rushed";
		RenderStyle "Add";
		DropItem "RS_CH_Berserk", 42;
		MeleeRange 64;
		Translation "16:31=[230,149,247]:[180,24,156]","160:167=175:181","32:47=[168,15,181]:[41,12,13]","173:191=250:254";
		Tag "Purple Spectre";
	}
	States
	{
	Spawn:
		SARG AB 10 A_Look;
		Loop;
	See:
		SARG AABBCCDD 2 Fast A_Chase;
		Loop;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG E 4 Bright A_JumpIfCloser(800,"Rush2");
		Goto See;
	Rush2:
		SARG F 1 A_FaceTarget;
		SARG F 3 A_SkullAttack(25);
		Goto See;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG EF 7 Fast A_FaceTarget;
		SARG G 6 Fast A_CustomMeleeAttack(random(13,46),"Demon/melee","none");
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SARG H 2 Fast;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH4",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SARG H 2 Fast A_Pain;
		SARG H 2 Bright A_Jump(100,"Missile");
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SARG I 8;
		SARG J 8 A_Scream;
		SARG K 4;
		SARG L 4 A_NoBlocking;
		SARG M 4;
		SARG N -1;
		Stop;
	Raise:
		SARG NMLKJI 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 5 -- YELLOW.  CH: spectres.txt:836.  The blood demon hide: pain can
// drop stealth and sprint until its next bite calms it.
// The Melee tail below read SPG2 G in CH; corrected to SRG2 G -- see the
// file header for the YellowDemon twin-line proof.
// ---------------------------------------------------------------------------
class RS_YellowSpectre : Spectre
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 5); }
	int User_Calm;   // CH: Var int User_Calm
	Default
	{
		Health 320;
		BloodColor "Yellow";
		PainChance 60;
		Species "Demon1";
		RenderStyle "Add";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Speed 17;
		Radius 30;
		Height 56;
		Mass 500;
		Monster;
		+FLOORCLIP
		+STEALTH
		+NOFEAR
		SeeSound "blooddemon/sight";
		PainSound "blooddemon/pain";
		DeathSound "blooddemon/death";
		ActiveSound "blooddemon/active";
		Obituary "%o was chomped by orange Spectre";
		DropItem "RS_CH_Berserk", 48;
		MeleeRange 64;
		Translation "168:191=160:167","16:31=208:216","32:40=215:223","41:46=232:235","47:47=190:190";
		Tag "Yellow Spectre";
	}
	States
	{
	Spawn:
		SRG2 AB 10 A_Look;
		Loop;
	See:
		SRG2 A 0 A_PlaySound("blooddemon/walk");
		SRG2 AABB 2 A_Chase;
		SRG2 C 0 A_PlaySound("blooddemon/walk");
		SRG2 CCDD 2 A_Chase;
		SRG2 A 0 A_JumpIf(User_Calm == 1,"Calm");
		Loop;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SRG2 EF 8 A_FaceTarget;
		SRG2 G 8 A_CustomMeleeAttack(random(13,52),"blooddemon/melee","none");
		SRG2 G 1 { User_Calm = (User_Calm == 1) ? 1 : 0; }   // CH: SPG2 G -- CH typo; SRG2 is the real prefix and has this frame. Fixed 2026-08-06 (owner: nothing invisible).   // CH: A_SetUserVar("User_Calm",User_Calm == 1)
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SRG2 H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH5",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SRG2 H 2 A_Pain;
		SRG2 H 1 A_Jump(128,"SpeedBuff");
		Goto See;
	SpeedBuff:
		SRG2 E 1 A_SetSpeed(31);
		SRG2 E 1 { bSTEALTH = false; }   // CH: A_ChangeFlag("STEALTH",FALSE)
		SRG2 E 1 { User_Calm = (User_Calm == 0) ? 1 : 0; }   // CH: A_SetUserVar("User_Calm",User_Calm == 0)
		Goto See;
	Calm:
		SRG2 E 1 A_SetSpeed(17);
		SRG2 E 1 { bSTEALTH = true; }   // CH: A_ChangeFlag("STEALTH",True)
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SRG2 I 8;
		SRG2 I 0 A_FaceTarget;
		SRG2 J 0 A_SpawnItemEx("RS_BloodDemonArm",10,0,32,0,8,0,0,128);
		SRG2 J 8 A_Scream;
		SRG2 K 4;
		SRG2 L 4 A_NoBlocking;
		SRG2 M 4;
		SRG2 N -1;
		Stop;
	Raise:
		SRG2 NMLKJI 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 6 -- RED.  CH: spectres.txt:934.  The heavy blood demon: bleeds
// bolts from its bite, armors up through pain.
// ---------------------------------------------------------------------------
class RS_RedSpectre : Spectre
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 6); }
	Default
	{
		Health 394;
		PainChance 30;
		Species "Demon1";
		DamageFactor "Wrangler", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		Speed 16;
		Radius 30;
		Height 56;
		Mass 5000;
		Monster;
		+FLOORCLIP
		+DONTHARMSPECIES
		+STEALTH
		+NOFEAR
		RenderStyle "Add";
		SeeSound "blooddemon/sight";
		PainSound "blooddemon/pain";
		DeathSound "blooddemon/death";
		ActiveSound "blooddemon/active";
		Obituary "%o got a little blood on em";
		HitObituary "%o was crunched by red Spectre";
		DropItem "RS_CH_Berserk", 52;
		Translation "80:95=171:183","96:111=177:191","192:192=170:170","3:3=190:190","128:143=181:191","160:167=5:8";
		MeleeRange 78;
		Tag "Red Spectre";
	}
	States
	{
	Spawn:
		SRG2 AB 10 A_Look;
		Loop;
	See:
		SRG2 A 0 A_PlaySound("blooddemon/walk");
		SRG2 AABB 2 A_Chase;
		SRG2 C 0 A_PlaySound("blooddemon/walk");
		SRG2 CCDD 2 A_Chase;
		Loop;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SRG2 EF 6 A_FaceTarget;
		SRG2 G 4 A_CustomMeleeAttack(random(10,55),"blooddemon/melee","none");
		SRG2 G 1 A_SpawnItemEx("RS_RedThingsLS",1,3,15,0,0,0,0,SXF_NOCHECKPOSITION);
		SRG2 G 0 A_SpawnItemEx("RS_RedThingsLS",6,3,15,0,0,0,0,SXF_NOCHECKPOSITION);
		SRG2 GGGGGG 0 A_CustomMissile("RS_RedDemonBloodBolt3",random(32,48),0,random(-17,17));
		Goto See;
	Pain.AbyssPE:
		TNT1 A 0 { bNOPAIN = true; }
		TNT1 A 0 A_SetScale(0.8,0.8);
		AYPB AAB 5 Bright;
		AYPB B 5 Bright A_PlaySound("AbyssForm",0);
		AYPB BBACDE 5 Bright;
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),16,0,3,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("RS_SplashAbyss",random(-16,16),random(-16,16),random(4,32),12,0,8,random(-359,359),SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		TNT1 A 0 A_SpawnItemEx("RS_AbyssDemon2",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION|SXF_TRANSFERSPECIAL|SXF_TRANSFERAMBUSHFLAG);
		AYPB FGH 3 Bright;
		AYPB I 5 Bright A_SetScale(1,0.75);
		AYPB H 5 Bright A_SetScale(1,0.5);
		AYPB I 5 Bright A_SetScale(1,0.25);
		AYPB H 5 Bright A_SetScale(1,0.05);
		TNT1 A 0 A_Die;
		Stop;
	Pain:
		SRG2 H 2;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH6",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SRG2 H 2 A_Pain;
		SRG2 H 1 A_Jump(174,"BuffUP");
		Goto See;
	BuffUP:
		SRG2 E 1 A_SetSpeed(25);
		SRG2 EF 6 A_CustomMissile("RS_EffectHK",24,0);
		SRG2 G 5 { bNOPAIN = true; }   // CH: A_ChangeFlag("NOPAIN",TRUE)
		SRG2 E 1 { bSTEALTH = false; }   // CH: A_ChangeFlag("STEALTH",FALSE)
		SRG2 E 1 A_SetTranslucent(1);
		Goto See;
	Tickles:
		TNT1 A 0 A_SpawnItemEx("RS_ThePlanBoner",0,0,6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		Goto Death+1;
	Death:
		TNT1 A 0 A_JumpIfInventory("RS_CHBoner",1,"Tickles");
		SRG2 I 8;
		SRG2 I 0 A_FaceTarget;
		SRG2 J 0 A_SpawnItemEx("RS_BloodDemonArm2",10,0,32,0,8,0,0,128);
		SRG2 J 8 A_Scream;
		SRG2 K 4;
		SRG2 L 4 A_NoBlocking;
		SRG2 M 4;
		SRG2 N -1;
		Stop;
	Raise:
		SRG2 NMLKJI 5;
		Goto See;
	}
}

// ---------------------------------------------------------------------------
// TIER 10 -- BLACK BOSS ("Backstabber").  CH: spectres.txt:1075.  The rogue:
// afterimage chase, sight-counter backstab warp, teleport spot escapes.
// ---------------------------------------------------------------------------
class RS_BlackSpectre2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 10); }
	int user_hm;   // CH: var int user_hm
	Default
	{
		Health 3000;
		Radius 20;
		Height 56;
		Mass 100;
		RenderStyle "Translucent";
		Alpha 0.45;
		Speed 15;
		PainChance 100;
		Monster;
		+FLOORCLIP
		+DONTMORPH
		+QUICKTORETALIATE
		+BOSS
		-NORADIUSDMG
		+NOFEAR
		RadiusDamageFactor 0.5;
		DamageFactor "Melee", 2.5;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		PainSound "Shadow/pain";
		DeathSound "Shadow/death";
		ActiveSound "Shadow/active";
		Obituary "%o got casted out by the rogue";
		HitObituary "%o was assisinated by the rogue";
		MeleeRange 64;
		MeleeThreshold 400;
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Chainsaw";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		DropItem "RS_CH_Cell";
		Tag "Backstabber";
	}
	States
	{
	Spawn:
		SHDW A 0;
		Goto Scripted;
	Scripted:
		SHDW A 0;   // CH: ACS_NamedExecuteAlways("AnnounceBlackSpectre") -- announcers dropped per owner
		Goto Idle;
	Idle:
		SHDW EE 1 A_Look;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		Loop;
	See:
		SHDW E 15;
		SHDW E 0 A_SetTranslucent(0.45);
		SHDW AAA 1 A_Chase;
		SHDW A 0 A_SpawnItemEx("RS_ShadowGhostA",0,0,0,0,0,0,0,128);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SHDW BBB 1 A_Chase;
		SHDW B 0 A_SpawnItemEx("RS_ShadowGhostB",0,0,0,0,0,0,0,128);
		SHDW CCC 1 A_Chase;
		SHDW C 0 A_SpawnItemEx("RS_ShadowGhostC",0,0,0,0,0,0,0,128);
		SHDW DDD 1 A_Chase;
		SHDW D 0 A_SpawnItemEx("RS_ShadowGhostD",0,0,0,0,0,0,0,128);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SHDW AAA 1 A_Chase;
		SHDW A 0 A_SpawnItemEx("RS_ShadowGhostA",0,0,0,0,0,0,0,128);
		SHDW BBB 1 A_Chase;
		SHDW B 0 A_SpawnItemEx("RS_ShadowGhostB",0,0,0,0,0,0,0,128);
		SHDW CCC 1 A_Chase;
		SHDW C 0 A_SpawnItemEx("RS_ShadowGhostC",0,0,0,0,0,0,0,128);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SHDW DDD 1 A_Chase;
		SHDW D 0 A_SpawnItemEx("RS_ShadowGhostD",0,0,0,0,0,0,0,128);
		Goto See2;
	See2:
		SHDW E 5 A_SetTranslucent(0.12);
		SHDW AAABBBCCCDDDAAABBBCCCDDD 1 A_Chase;
		SHDW D 0 A_CheckSight("HMM");
		SHDW D 0 { user_hm = user_hm - 1; }   // CH: A_setuservar("user_hm",user_hm-1)
		SHDW E 5 A_SetTranslucent(0.45);
		Goto See+1;
	HMM:
		TNT1 A 0 A_CheckRange(1000,"See");
		SHDW D 0 A_JumpIf(user_hm >= 10,"GETTO");
		SHDW D 0 { user_hm = user_hm + 2; }   // CH: A_setuservar("user_hm",user_hm+2)
		Goto See+1;
	GETTO:
		SHDW D 30 A_PlaySound("Shadow/pain",7,2,false,ATTN_NONE);
		SHDW D 0 A_Warp(AAPTR_TARGET,-38,0,16,0,WARPF_ABSOLUTEOFFSET|WARPF_INTERPOLATE,"BACKSTABBUU");
		Goto See;
	BACKSTABBUU:
		SHDW E 0 { bTHRUACTORS = false; }   // CH: A_ChangeFlag("THRUACTORS",FALSE)
		SHDW E 0 A_SpawnItemEx("TeleportFog");
		SHDW E 6 Bright A_FaceTarget;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 AAAAAAAAAAA 0 A_SpawnParticle("RED",SPF_FULLBRIGHT|SPF_RELATIVE,random(27,74),random(1,13),frandom(0,360),0,0,0,frandom(0.1,11.0),frandom(-0.15,0.25),frandom(-6.9,6.9),0,0,-0.1,0.98,-1);
		SHDW E 18 Bright A_FaceTarget;
		SHDW F 8 A_CustomMeleeAttack(random(30,70),"Butcher/Melee","none");
		SHDW E 12 Bright A_FaceTarget;
		SHDW F 6 A_CustomMeleeAttack(random(30,70),"Butcher/Melee","none");
		SHDW G 1 { user_hm = user_hm - 5; }   // CH: A_setuservar("user_hm",user_hm-5)
		Goto See;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SHDW E 0 { bTHRUACTORS = false; }
		SHDW E 0 A_SetTranslucent(0.45);
		SHDW EF 4 A_FaceTarget;
		SHDW G 2 A_CustomMeleeAttack(random(25,65),"Shadow/attack","none");
		SHDW G 0 A_Jump(12,"Teleporter");
		Goto See;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SHDW E 0 { bTHRUACTORS = false; }
		SHDW E 0 A_SetTranslucent(0.45);
		SHDW E 0 A_Jump(256,"Missiles","Teleporter");
	Missiles:
		SHDW E 6 A_FaceTarget;
		SHDW F 4 A_FaceTarget;
		SHDW GGG 5 Bright A_CustomMissile("RS_ShadowBall",32,0,random(-3,3));
		SHDW F 4 A_FaceTarget;
		SHDW E 2 A_CheckSight("Teleporter");
		SHDW E 0 A_Jump(82,"BigOne");
		SHDW E 1 A_SpidRefire;
		Goto Missile;
	BigOne:
		SHDW F 8 Bright A_FaceTarget;
		SHDW G 8 Bright A_CustomMissile("RS_ShadowBall2",32,0,random(-3,3));
		Goto Missiles;
	Teleporter:
		SHDW F 2 A_SpawnItemEx("RS_TeleporterSpotSH",0,0,3,0,0,0,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SHDW E 8 A_PlaySound("Shadow/active");
		SHDW E 4 { bTHRUACTORS = true; }   // CH: A_ChangeFlag("THRUACTORS",TRUE)
		SHDW E 4 { user_hm = user_hm + 3; }   // CH: A_setuservar("user_hm",user_hm+3)
		SHDW E 2 A_Teleport("See","RS_TeleporterSpotSH","TeleportFog",TF_KEEPVELOCITY);
		Goto See;
	Pain:
		SHDW H 4 A_SetTranslucent(0.45);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH10",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SHDW H 4 A_Pain;
		SHDW H 2 A_Jump(88,"Teleporter");
		Goto See2;
	Death:
		SHDX A 12;
		SHDX B 12 A_Scream;
		SHDX C 13;
		SHDX D 13 A_Fall;
		SHDX EF 13;
		TNT1 A 0 A_SpawnItemEx("RS_CH_Pantsu",0,0,24,VelX,VelY,VelZ,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION,248);
		SHDX G -1;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// TIER 11 -- WHITE BOSS ("Tentacle monster?").  CH: spectres.txt:1409.
// The burrowing slug: untouchable underground, surfaces to bite, spit
// slime, and summon the chomper.  CH ships neither an SLGMF* nor an
// SLGM"\"* lump, so both frames are invisible in CH itself. SLGM F is
// resolved here (-> E, see the file header, 2026-08-06); SLGM "\" is still
// verbatim, held as TNT1 at its site for the timing.
// ---------------------------------------------------------------------------
class RS_WhiteSpectre2 : Actor
{
	override void PostBeginPlay() { Super.PostBeginPlay(); RS_Zom.SetTier(self, 11); }
	Default
	{
		Health 7500;
		Speed 8;
		Radius 16;
		Height 29;
		PainChance 32;
		Mass 400;
		Monster;
		+FLOORCLIP
		+LOOKALLAROUND
		+MISSILEMORE
		+NOTARGET
		+BOSS
		-NORADIUSDMG
		+DONTMORPH
		+NOFEAR
		BloodColor "blue";
		DamageFactor "Fire", 0.75;
		DamageFactor "Melee", 2;
		DamageFactor "Plasma", 0.75;
		DamageFactor "Heroic", 3.0;
		DamageFactor "DIMp", 0;
		PainChance "DIMp", 0;
		SeeSound "slgmsee";
		DeathSound "slgmdie";
		Obituary "%o was... eaten or something?? By something?";
		PainSound "Cracko/Pain";
		Translation "48:63=80:95","208:223=81:94","1:1=111:111","39:47=99:105","164:167=92:104","64:79=92:100","16:31=80:95","176:191=207:207","0:0=200:200","4:4=250:250";
		MeleeRange 64;
		MeleeThreshold 300;
		DropItem "BackPack";
		DropItem "RS_BackPackBundle";
		DropItem "RS_CH_Berserk";
		DropItem "RS_CH_Chainsaw";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_CellPack";
		DropItem "RS_CH_MegaSphere";
		DropItem "RS_CH_MegaSphere", 128;
		DropItem "RS_CH_MegaSphere", 64;
		DropItem "RS_CH_SoulSphere";
		Tag "Tentacle monster?";
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0;   // CH: ACS_NamedExecuteAlways("AnnounceWhiteSpectre") -- announcers dropped per owner
		Goto Idle;
	Idle:
		SLGM A 0 A_Look;
		TNT1 A 0 A_SetInvulnerable;
		TNT1 A 1 A_Look;
		Goto Idle+1;
	See:
		TNT1 A 0 { bNOTARGET = false; }   // CH: A_ChangeFlag("NOTARGET",0)
		TNT1 A 0 A_JumpIfInventory("RS_RiseCheck",1,"Walk");
		TNT1 A 0 A_GiveInventory("RS_RiseCheck",1);
		TNT1 A 0 A_UnsetInvulnerable;
		SLGM ABCDEFGHHHVWXY 4 A_Chase;   // CH verbatim, RESTORED 2026-08-06: the art was found uncopied at ART SOURCE\SPRITES\spectre\SLGMF0^0 and is now in sprites/rs_spectre/. See header.
		Loop;
	Walk:
		TNT1 A 0 A_SetInvulnerable;
		TNT1 A 0 { bNOTARGET = true; }   // CH: A_ChangeFlag("NOTARGET",1)
		TNT1 AA 2 A_Chase;
		TNT1 A 0 A_Jump(8,"PeekUp");
		Loop;
	FastWalk:
		TNT1 A 0 A_SetInvulnerable;
		TNT1 A 0 { bNOTARGET = true; }
		TNT1 A 0 A_SetSpeed(19);
		TNT1 AA 2 A_Chase;
		TNT1 A 0 A_Jump(8,"PeekUp");
		Loop;
	PeekUp:
		TNT1 A 0 { bNOTARGET = false; }
		TNT1 A 0 A_UnsetInvulnerable;
		TNT1 A 0 A_SetSpeed(8);
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SLGM ABCDEFG 4;   // CH verbatim, RESTORED 2026-08-06: art found and copied in. See header.
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SLGM HZ 5;
		TNT1 A 5;   // CH: SLGM \ 5 -- no lump for frame 27 SHIPS anywhere, so CH
		            // renders nothing here too; the quoted "\\" form was a parse
		            // error on this engine, and this keeps the 5-tic timing.
		            // CORRECTED 2026-08-06: the art is not missing, only
		            // uncopied -- ART SOURCE\SPRITES\spectre\SLGMF0^0 is a
		            // mirrored lump defining frame F rot 0 AND frame ^ rot 0,
		            // and ^ is GZDoom's on-disk escape for \. Copy that one
		            // file into sprites/rs_spectre/ and this hold plus the two
		            // SLGM F stopgaps above all become CH verbatim. See header.
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SLGM ZH 5;
		SLGM VWXY 4;
		Goto Walk;
	Melee:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 { bNOTARGET = false; }
		TNT1 A 0 A_UnsetInvulnerable;
		TNT1 A 0 A_SetSpeed(8);
		SLGM IJKLMN 1;
		SLGM OOO 4 A_CustomMeleeAttack(random(20,50),"slgmbite","slgmbite","Normal",true);
		SLGM NMLKJI 1;
		Goto Walk;
	Missile:
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		TNT1 A 0 { bNOTARGET = false; }
		TNT1 A 0 A_UnsetInvulnerable;
		TNT1 A 0 A_SetSpeed(8);
		SLGM IJKLMN 1;
		SLGM N 0 A_Jump(255,"Atk1","Atk2","Atk3");
	Atk1:
		SLGM N 5 A_FaceTarget;
		SLGM O 0 A_CustomMissile("RS_SpecSlime1",32,0,7);
		SLGM O 0 A_CustomMissile("RS_SpecSlime1",32,0,-7);
		SLGM O 5 Bright A_CustomMissile("RS_SpecSlime1",32,0);
		SLGM NMLKJI 1;
		Goto See;
	Atk2:
		SLGM N 5 A_FaceTarget;
		SLGM O 3 Bright A_CustomMissile("RS_SpecSlime2",32,0,random(-1,1));
		SLGM O 1 Bright A_CustomMissile("RS_SpecSlime2",32,0,random(-12,12));
		SLGM N 1 A_FaceTarget;
		SLGM O 3 Bright A_CustomMissile("RS_SpecSlime2",32,0,random(-12,12));
		SLGM O 1 Bright A_CustomMissile("RS_SpecSlime2",32,0,random(-1,1));
		SLGM N 1 A_FaceTarget;
		SLGM O 3 Bright A_CustomMissile("RS_SpecSlime2",32,0,random(-6,6));
		SLGM O 3 Bright A_CustomMissile("RS_SpecSlime2",32,0,random(-6,6));
		SLGM NMLKJI 1;
		Goto See;
	Atk3:
		SLGM N 12 A_FaceTarget;
		SLGM O 5 Bright A_CustomMissile("RS_SpecSlime3",12,0);
		SLGM NMLKJI 1;
		Goto See;
	Pain:
		SLGM J 5;
		TNT1 A 0 A_SpawnItemEx("RS_ColorTierIconCH11",0,0,32,random(1,4),0,random(0,2),random(0,359),SXF_NOCHECKPOSITION);
		SLGM J 5 A_Pain;
		SLGM I 3 A_Jump(64,"FaceSpawn");
		SLGM NMLKJI 1;
		Goto FastWalk;
	FaceSpawn:
		SLGM J 4;
		SLGM K 6 A_SpawnItemEx("RS_Wakawaka",0,0,0,0,0,4,0,SXF_NOCHECKPOSITION|SXF_SETMASTER);
		SLGM NMLKJI 1;
		Goto FastWalk;
	Death:
		SLGM VWXY 5;
		TNT1 A 5;
		TNT1 AAAA 0 A_Wander;
		SLGM P 5 A_Scream;
		SLGM QRST 5;
		SLGM U 5 A_NoBlocking;
		SLGM U -1;
		Stop;
	}
}
