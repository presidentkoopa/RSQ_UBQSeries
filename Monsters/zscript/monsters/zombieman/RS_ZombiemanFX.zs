// ============================================================================
// RS_ZombiemanFX.zs -- Colourful Hell Zombieman family: support classes.
// Source of truth: C:\Users\Command\Desktop\CH  (Zombies.txt, DECORATE.txt,
// Gibs.txt, and single actors pulled from Demons/Barons/Imps/Revenants/
// Archviles/Hellknights/Spiders.txt -- each class cites its CH file:line).
//
// Owner's directives for this import (2026-08-05):
//   * Native ZScript. No DECORATE, no ACS. ACS cvar gates -> rs_ch_* cvars
//     (declared in CVARINFO.txt), identical value semantics to CH's.
//   * No announcer HUD messages (owner: drop them).
//   * Vanilla blood/gore accepted: CH's NashGore blood + CHGore gib chain NOT
//     imported. XDeath gib-generator spawn lines are preserved as comments in
//     RS_Zombieman.zs. CH's `replaces Blood` global hijack NOT carried.
//   * No abstract. No state dispatchers. No shared monster base class.
//   * Tier: CH's own token idiom (CHBoner/BoneUp style). RS_ZomTierToken
//     amount == tier. Query: mo.CountInv("RS_ZomTierToken").
//     Set: RS_Zom.SetTier(mo, n). Ladder = CH's icon index:
//     1 Common, 2 Green, 3 Blue, 4 Purple, 5 Yellow(Orange), 6 Red,
//     7 FireBlu, 8 Gray, 9 Abyss, 10 Black, 11 White, 12 Cyan, 13 Brown.
//
// Dangling by design (all no-op safely until their owners exist):
// RS_CommonRevenant (MrBones 3rd raise, guarded), CH_Chaingun (undefined in
// CH itself), sounds skelsit4 / spike/spiked / moloch-nailhit-members
// (silent in CH itself).
// DRLA (DoomRL Arsenal) STRIPPED PER OWNER 2026-08-05: the RL*/RareArmorPool
// cross-mod drops and the RLArsenalThingo probe are removed. Originals kept
// as "// CH:" comments at each drop site.
// ============================================================================

// ---------------------------------------------------------------------------
// Shared helpers. Static functions only -- same idiom as RS_Roll/RS_Catalog.
// ---------------------------------------------------------------------------
class RS_Zom play   // play scope: SetTier touches inventories from PostBeginPlay
{
	// CH's ACS gates were one-line cvar reads (source/CHSett.acs). Same here.
	static int CV(Name cvname, int def)
	{
		let cv = CVar.FindCVar(cvname);
		return cv ? cv.GetInt() : def;
	}

	static void SetTier(Actor mo, int t)
	{
		if (!mo) return;
		t = clamp(t, 0, 99);
		let tok = mo.FindInventory("RS_ZomTierToken");
		if (tok) { tok.Amount = t; if (t <= 0) tok.Destroy(); }
		else if (t > 0) mo.GiveInventory("RS_ZomTierToken", t);
	}

	static int GetTier(Actor mo)
	{
		return mo ? mo.CountInv("RS_ZomTierToken") : 0;
	}
}

// Tier lives here. Amount == tier. CH's own monster-state idiom (CHBoner,
// BoneUp, RocketCounter are the same machinery, defined below).
class RS_ZomTierToken : Inventory
{
	Default
	{
		Inventory.MaxAmount 99;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
	}
}

// ---------------------------------------------------------------------------
// Inventory tokens.  CH: DECORATE.txt:885-898, Zombies.txt:1439,2025,2219.
// ---------------------------------------------------------------------------
class RS_GrowRaisin : Inventory { Default { Inventory.MaxAmount 1; } }   // CH DECORATE.txt:885
class RS_CHBoner    : Inventory { Default { Inventory.MaxAmount 1; } }   // CH DECORATE.txt:890
class RS_CHAbyssMark: Inventory { Default { Inventory.MaxAmount 1; } }   // CH DECORATE.txt:895

// ---------------------------------------------------------------------------
// Colour tier icons.  CH: DECORATE.txt:709-849.  Verbatim; the ACS colour-
// blind gate becomes rs_ch_colorblind (CH cvar CH_ColorBlind, default 0).
// Sprites TI3R A-M ship in sprites/rs_zombieman/.
// ---------------------------------------------------------------------------
class RS_ColorTierIconCH : Actor
{
	Default
	{
		Radius 1;
		Height 1;
		Speed 1;
		Projectile;
		+NOINTERACTION
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_colorblind', 0) == 1, "Show");
	Death:
		TNT1 A 0;
		Stop;
	Show:
		TI3R A 30 Bright;
		Stop;
	}
}

class RS_ColorTierIconCH2 : RS_ColorTierIconCH { States { Show: TI3R B 30 Bright; Stop; } }
class RS_ColorTierIconCH3 : RS_ColorTierIconCH { States { Show: TI3R C 30 Bright; Stop; } }
class RS_ColorTierIconCH4 : RS_ColorTierIconCH { States { Show: TI3R D 30 Bright; Stop; } }
class RS_ColorTierIconCH5 : RS_ColorTierIconCH { States { Show: TI3R E 30 Bright; Stop; } }
class RS_ColorTierIconCH6 : RS_ColorTierIconCH { States { Show: TI3R F 30 Bright; Stop; } }
class RS_ColorTierIconCH7 : RS_ColorTierIconCH { States { Show: TI3R G 30 Bright; Stop; } }
class RS_ColorTierIconCH8 : RS_ColorTierIconCH { States { Show: TI3R H 30 Bright; Stop; } }
class RS_ColorTierIconCH9 : RS_ColorTierIconCH { States { Show: TI3R I 30 Bright; Stop; } }
class RS_ColorTierIconCH10 : RS_ColorTierIconCH { States { Show: TI3R J 30 Bright; Stop; } }
class RS_ColorTierIconCH11 : RS_ColorTierIconCH { States { Show: TI3R K 30 Bright; Stop; } }
class RS_ColorTierIconCH12 : RS_ColorTierIconCH { States { Show: TI3R L 30 Bright; Stop; } }
class RS_ColorTierIconCH13 : RS_ColorTierIconCH { States { Show: TI3R M 30 Bright; Stop; } }

// ---------------------------------------------------------------------------
// Bonus bundles.  CH: DECORATE.txt:21-89 (Health), 91-159 (Armor),
// 161-254 (BackPack).  ACS gate CH_Health/CH_BackPack -> rs_ch_healthdrops /
// rs_ch_backpackdrops (CH defaults 1).
// ---------------------------------------------------------------------------
class RS_HealthBundle : Actor
{
	Default
	{
		Mass 5;
		Alpha 0.01;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_healthdrops', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_healthdrops', 1) == 2, "Two");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_healthdrops', 1) == 3, "Three");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_healthdrops', 1) == 4, "Four");
		Goto Last;
	First:
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-15,15),random(-21,15),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,172);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-21,21),random(-15,21),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,172);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-21,21),random(-21,21),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,172);
		Stop;
	Two:
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,172);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,172);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		Stop;
	Three:
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-15,15),random(-21,15),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-21,21),random(-15,21),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-21,21),random(-21,21),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		Stop;
	Four:
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-15,15),random(-21,15),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-21,21),random(-15,21),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("HealthBonus",random(-21,21),random(-21,21),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		Stop;
	Last:
		TNT1 A 0;
		Stop;
	}
}

class RS_ArmorBundle : Actor   // CH DECORATE.txt:91
{
	Default
	{
		Mass 5;
		Alpha 0.01;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_healthdrops', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_healthdrops', 1) == 2, "Two");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_healthdrops', 1) == 3, "Three");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_healthdrops', 1) == 4, "Four");
		Goto Last;
	First:
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-15,15),random(-21,15),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,172);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-21,21),random(-15,21),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,172);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-21,21),random(-21,21),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,172);
		Stop;
	Two:
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,172);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,172);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		Stop;
	Three:
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-15,15),random(-21,15),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-21,21),random(-15,21),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-21,21),random(-21,21),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		Stop;
	Four:
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-8,8),random(-8,8),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-12,12),random(-12,12),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-15,15),random(-21,15),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-21,21),random(-15,21),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		TNT1 A 0 A_SpawnItemEx("ArmorBonus",random(-21,21),random(-21,21),6,0,0,0,0,SXF_NOPOINTERS|SXF_NOCHECKPOSITION,random(1,255));
		Stop;
	Last:
		TNT1 A 0;
		Stop;
	}
}

class RS_BackPackBundle : Actor   // CH DECORATE.txt:161
{
	Default
	{
		Mass 5;
		Alpha 0.01;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_backpackdrops', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_backpackdrops', 1) == 2, "Two");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_backpackdrops', 1) == 3, "Three");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_backpackdrops', 1) == 4, "Four");
		Goto Last;
	First:
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,232);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,232);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,232);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,232);
		Stop;
	Two:
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		Stop;
	Three:
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,64);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,102);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,102);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,102);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,102);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,132);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,132);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,162);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,162);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,132);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,132);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,162);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,162);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,132);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,132);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,162);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,162);
		Stop;
	Four:
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,164);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,104);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		TNT1 A 0 A_SpawnItemEx("BackPack",random(-8,8),random(-8,8),6,1,0,0,random(-359,359),SXF_NOPOINTERS|SXF_NOCHECKPOSITION,128);
		Stop;
	Last:
		TNT1 A 0;
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Ammo / item drop gates.  CH: DECORATE.txt:256-707.  ACS CH_AmmoUps ->
// rs_ch_ammodrops, CH_Extras -> rs_ch_extradrops (CH defaults 1).
// Only the members the zombie family drops are imported.
// ---------------------------------------------------------------------------
class RS_DropBaseAmmo : Actor   // CH DECORATE.txt:256
{
	Default
	{
		Mass 5;
		Alpha 0.01;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_ammodrops', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_ammodrops', 1) == 2, "Rare");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_ammodrops', 1) == 3, "Dub");
		Goto Last;
	Last:
		TNT1 A 0;
		Stop;
	}
}

class RS_CH_Clip : RS_DropBaseAmmo   // CH DECORATE.txt:389
{
	States
	{
	Dub:
		TNT1 AA 0 A_SpawnItemEx("Clip",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	Rare:
		TNT1 A 0 A_SpawnItemEx("Clip",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("Clip",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_Shell : RS_DropBaseAmmo   // CH DECORATE.txt:309
{
	States
	{
	Dub:
		TNT1 AA 0 A_SpawnItemEx("Shell",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	Rare:
		TNT1 A 0 A_SpawnItemEx("Shell",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("Shell",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_Cell : RS_DropBaseAmmo   // CH DECORATE.txt:341
{
	States
	{
	Dub:
		TNT1 AA 0 A_SpawnItemEx("Cell",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	Rare:
		TNT1 A 0 A_SpawnItemEx("Cell",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("Cell",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_RocketBox : RS_DropBaseAmmo   // CH DECORATE.txt:357
{
	States
	{
	Dub:
		TNT1 AA 0 A_SpawnItemEx("RocketBox",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	Rare:
		TNT1 A 0 A_SpawnItemEx("RocketBox",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("RocketBox",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_RocketAmmo : RS_DropBaseAmmo   // CH DECORATE.txt:373
{
	States
	{
	Dub:
		TNT1 AA 0 A_SpawnItemEx("RocketAmmo",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	Rare:
		TNT1 A 0 A_SpawnItemEx("RocketAmmo",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("RocketAmmo",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_DropBaseItem : Actor   // CH DECORATE.txt:407
{
	Default
	{
		Mass 5;
		Alpha 0.01;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		Goto Scripted;
	Scripted:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_extradrops', 1) == 1, "First");
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_extradrops', 1) == 2, "Rare");
		Goto Last;
	Rare:
		TNT1 A 0;
		Stop;
	First:
		TNT1 A 0;
		Stop;
	Last:
		TNT1 A 0;
		Stop;
	}
}

class RS_CH_Berserk : RS_DropBasePowerup   // CH DECORATE.txt:479
{
	States
	{
	Rare:
		TNT1 A 0 A_SpawnItemEx("Berserk",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("Berserk",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_SuperShotgun : RS_DropBaseWeapon   // CH DECORATE.txt:525
{
	States
	{
	Rare:
		TNT1 A 0 A_SpawnItemEx("SuperShotgun",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("SuperShotgun",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_PlasmaRifle : RS_DropBaseWeapon   // CH DECORATE.txt:571
{
	States
	{
	Rare:
		TNT1 A 0 A_SpawnItemEx("PlasmaRifle",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("PlasmaRifle",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_RocketLauncher : RS_DropBaseWeapon   // CH DECORATE.txt:594
{
	States
	{
	Rare:
		TNT1 A 0 A_SpawnItemEx("RocketLauncher",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("RocketLauncher",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_Medikit : RS_DropBaseItem   // CH DECORATE.txt:617
{
	States
	{
	Rare:
		TNT1 A 0 A_SpawnItemEx("Medikit",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("Medikit",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_SoulSphere : RS_DropBasePowerup   // CH DECORATE.txt:640
{
	States
	{
	Rare:
		TNT1 A 0 A_SpawnItemEx("SoulSphere",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("SoulSphere",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_CH_MegaSphere : RS_DropBasePowerup   // CH DECORATE.txt:686
{
	States
	{
	Rare:
		TNT1 A 0 A_SpawnItemEx("MegaSphere",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION,128);
		Stop;
	First:
		TNT1 A 0 A_SpawnItemEx("MegaSphere",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

// CH: DECORATE.txt:851-882.  In CH these probe for DoomRL Arsenal and drop
// the DRLA variant when present.  DRLA STRIPPED PER OWNER 2026-08-05: the
// probe and the RL* branches are gone; only the CH path remains.
class RS_ScootDropChecker : Actor   // CH DECORATE.txt:851
{
	States
	{
	Spawn:
		TNT1 A 0;
		Goto DropOther;
	DropOther:
		TNT1 A 0 A_SpawnItemEx("Chaingun",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

class RS_implyingclip : RS_ScootDropChecker   // CH DECORATE.txt:871
{
	States
	{
	DropOther:
		TNT1 A 0 A_SpawnItemEx("RS_CH_Clip",0,0,0,0,0,0,0,SXF_NOCHECKPOSITION);
		Stop;
	}
}

// ---------------------------------------------------------------------------
// Shared FX the zombie family spawns, pulled from their CH home files.
// ---------------------------------------------------------------------------

// CH: Barons.txt:4407 / 4432 -- dirt kicked up by the thrown rock.
class RS_Drt2 : Actor
{
	Default
	{
		Projectile;
		-NOGRAVITY
		-NOBLOCKMAP
		-NOTELEPORT
		+RANDOMIZE
		Radius 2;
		Damage 0;
		Speed 5;
	}
	States
	{
	Spawn:
		DIRT A 0 A_SetGravity(0.5);
		DIRT A 0 ThrustThingZ(0,15,0,1);
		Goto See;
	See:
		DIRT DEF 5;
		Loop;
	Death:
		DIRT JKL 3;
		Stop;
	}
}

class RS_Drt3 : Actor
{
	Default
	{
		Projectile;
		-NOGRAVITY
		-NOBLOCKMAP
		-NOTELEPORT
		+RANDOMIZE
		Radius 2;
		Damage 0;
		Speed 5;
	}
	States
	{
	Spawn:
		DIRT A 0 A_SetGravity(0.5);
		DIRT A 0 ThrustThingZ(0,15,0,1);
		Goto See;
	See:
		DIRT GHI 5;
		Loop;
	Death:
		DIRT JKL 3;
		Stop;
	}
}

// CH: Demons.txt:2632 -- parent of the gray zombie's rock.
class RS_WDRock3 : Actor
{
	Default
	{
		Radius 9;
		Height 9;
		Speed 36;
		DamageFunction (random(15,65));
		DamageType "Melee";
		Projectile;
		Scale 0.7;
		SeeSound "monster/hamflr";
		DeathSound "Butcher/melee";
	}
	States
	{
	Spawn:
		JUBD ABCD 3 Bright;
		Loop;
	Death:
		JUBD DDDD 0 A_SpawnItemEx("RS_Drt2",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		JUBD DDDD 1 Bright A_SpawnItemEx("RS_Drt3",random(-2,2),random(-2,2),random(-2,2),1,0,1,random(0,360),128);
		Stop;
	}
}

// CH: Imps.txt:637 / 663 -- the abyss droplet FX + its damaging variant.
class RS_SplashAbyss : Actor
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 16;
		FastSpeed 23;
		Projectile;
		+RANDOMIZE
		+THRUACTORS
		-NOGRAVITY
		Scale 0.3;
		Translation "0:255=%[0.02,0.02,0.03]:[0.29,0.49,0.65]";
	}
	States
	{
	Spawn:
		BAL1 AB 12;
		BAL1 A 2 A_Jump(32, "Death");
		Loop;
	Death:
		BAL7 C 1 Bright A_SetScale(0.6);
		BAL7 CDE 4 Bright;
		Stop;
	}
}

class RS_SplashAbyss2 : RS_SplashAbyss
{
	Default
	{
		Height 6;
		Speed 34;
		DamageFunction (random(1,9));
		DamageType "Ice";
		-THRUACTORS
		+MTHRUSPECIES
		+DONTHARMCLASS
	}
}

// CH: Revenants.txt:217 -- abyss projectile marker, gated on CH_AbyssMark.
class RS_AbyssShotIdentifier : Actor
{
	Default
	{
		Radius 6;
		Height 6;
		Speed 1;
		Projectile;
		+RANDOMIZE
		+NOINTERACTION
		RenderStyle "Add";
		Scale 1.0;
		Alpha 0.9;
	}
	States
	{
	Spawn:
		TNT1 A 0;
	Fly:
		TNT1 A 0 A_JumpIf(RS_Zom.CV('rs_ch_abyssmark', 0) == 1, "Show");
		Stop;
	Show:
		A8Y5 S 6 Bright;
		Goto Death;
	Death:
		A8Y5 S 6 Bright A_SetScale(0.8,0.8);
		A8Y5 S 6 Bright A_SetScale(0.6,0.6);
		A8Y5 S 6 Bright A_SetScale(0.4,0.4);
		A8Y5 S 6 Bright A_SetScale(0.2,0.2);
		A8Y5 S 6 Bright A_SetScale(0.05,0.05);
		Stop;
	}
}

// CH: Archviles.txt:2285 -- the flame the FireBlu zombie sheds and dies with.
class RS_FireSGguy2 : Actor
{
	Default
	{
		Radius 12;
		Height 16;
		Speed 17;
		DamageFunction (random(5,15));
		DamageType "Fire";
		Projectile;
		+RANDOMIZE
		+THRUACTORS
		RenderStyle "Add";
		Alpha 0.85;
		SeeSound "imp/attack";
		DeathSound "imp/shotx";
		Translation "161:161=200:200","160:160=177:177","162:162=184:184","163:163=204:204","164:164=186:186","165:165=204:204","166:166=189:189","167:167=207:207";
	}
	States
	{
	Spawn:
		FIRE AB 6 Bright;
		Goto Death;
	Death:
		FIRE CDEEDCDE 5 A_Explode(random(3,9),64);
		FIRE FGH 4 Bright A_Explode(random(5,15),64);
		Stop;
	}
}

// CH: Hellknights.txt:2107 -- red spark burst debris.
class RS_RedThingsHK : Actor
{
	Default
	{
		Radius 5;
		Height 5;
		Mass 5;
		Speed 9;
		Projectile;
		+THRUACTORS
		Scale 0.2;
		RenderStyle "Add";
		Alpha 0.8;
		Translation "208:223=176:191","224:231=176:176";
	}
	States
	{
	Spawn:
		BAL1 AB 12;
		BAL1 A 2 A_Jump(32, "Death");
		Loop;
	Death:
		BAL1 A 1 A_SetTranslucent(0.35);
		Stop;
	}
}

// CH: Hellknights.txt:2231 -- the red zombie's chained death explosion.
class RS_HKRedDeath : Actor
{
	Default
	{
		Radius 10;
		Height 42;
		+DONTGIB
		+NOGRAVITY
		DamageType "Fire";
		DeathSound "world/barrelx";
		Scale 0.7;
	}
	States
	{
	Spawn:
		BAR1 AB 0 A_PlaySound("world/barrelx");
		Goto Death;
	Death:
		MISL B 8 Bright A_Explode(random(5,10),42);
		MISL C 6 Bright A_PlaySound("world/barrelx");
		MISL D 3 Bright A_Burst("RS_RedThingsHK");
		Stop;
	}
}

// CH: Spiders.txt:1886 -- the plasma ball both black bosses spam.
// Bare `Damage 5` is deliberate: engine rolls it (5..40), exactly as CH.
class RS_PlasmaBallSP3 : Actor
{
	Default
	{
		DamageType "Plasma";
		Radius 13;
		Height 8;
		Speed 25;
		Damage 5;
		Projectile;
		+RANDOMIZE
		+MTHRUSPECIES
		RenderStyle "Add";
		Alpha 0.75;
		SeeSound "weapons/plasmaf";
		DeathSound "weapons/plasmax";
	}
	States
	{
	Spawn:
		PLSS AB 6 Bright;
		Loop;
	Death:
		PLSE ABCDE 4 Bright;
		Stop;
	}
}

// CH: MASTERMINDS.txt:3284 -- the trail's own sub-trail.
class RS_TrailSP2 : Actor
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 20;
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.35;
		Scale 0.25;
		Decal "ArachnotronScorch";
	}
	States
	{
	Spawn:
		SPPL AB 2 Bright;
		Goto Death;
	Death:
		APBX ABCDE 4 Bright A_Explode(7,32);
		Stop;
	}
}

// CH: Chaingunners.txt:2418 -- the EX BFG's plasma trail.
class RS_TrailSPCguy : Actor
{
	Default
	{
		Radius 6;
		Height 16;
		Speed 22;
		DamageType "Plasma";
		Projectile;
		+RANDOMIZE
		RenderStyle "Add";
		Alpha 0.65;
		Scale 0.55;
		Decal "ArachnotronScorch";
	}
	States
	{
	Spawn:
		SPPL AB 2 Bright A_SpawnItemEx("RS_TrailSP2",0,0,2);
		Loop;
	Death:
		APBX ABCDE 4 Bright A_Explode(10,32);
		Stop;
	}
}

// CH: Gibs.txt:230 -- the orange zombiewoman's XDeath keepsake.
class RS_CH_Pantsu : Actor
{
	Default
	{
		Radius 3;
		Height 6;
		Speed 1;
		Scale 1;
		Damage 0;
		Projectile;
		+MOVEWITHSECTOR
		+CANNOTPUSH
		-NOGRAVITY
		+NOTONAUTOMAP
		+THRUACTORS
		Gravity 0.03;
	}
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0 ThrustThingZ(0,5,0,1);
		Goto Fall;
	Fall:
		PTSU A 6;
		PTSU A 6 ThrustThing(angle+45,2,1,0);
		PTSU BB 9;
		PTSU C 6;
		PTSU CD 7;
		PTSU D 7 ThrustThing(angle-90,2,1,0);
		PTSU A 5;
		Loop;
	Crash:
		PTSU A 0 A_SetScale(1.2,0.5);
		PTSU A -1;
		Stop;
	Death:
		PTSU A 0 A_SetScale(1.2,0.5);
		PTSU A -1;
		Stop;
	}
}
