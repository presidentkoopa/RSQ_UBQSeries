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
//     Set: RS_Zom.SetTier(mo, n). The RSQ ladder, ordered by STRENGTH (owner
//     2026-11-11; RS_Retier.zs RS_TierLadder):
//     1 Common, 2 Green, 3 Blue, 4 Purple, 5 Cyan, 6 Brown, 7 Yellow(Orange),
//     8 FireBlu, 9 Gray, 10 Red, 11 Abyss, 12 Black (boss), 13 White (boss).
//     (Before 11-11 the token held CH's icon index, its listing order.)
//
// Dangling by design (all no-op safely until their owners exist):
// RS_CommonRevenant (MrBones 3rd raise, guarded), sounds skelsit4 /
// spike/spiked / moloch-nailhit-members (silent in CH itself).
// DROPS REMOVED (owner 2026-11-27: "bits and rewards only"): Colourful Hell's
// monsters drop nothing of its own -- every DropItem list, the health / armour
// / backpack bundles, the ammo and item drop gates (RS_DropBase*, RS_CH_* ammo,
// weapons, powerups, armour, medikit) and the ammo some of them throw out while
// they fire are gone. RSQ VisualRewards' bits and RSQ Miniboss's rewards are
// those mods' own. The one drop left is the Void Orb (chshared/RS_CHShared.zs).
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

	// THE TIER GEM IS SPAWNED ONLY WHEN IT WILL SHOW (owner's pick 2026-11-27, performance decision #1). Every monster's
	// walk, idle, attack and pain loops spawned one (1,440 call sites); with Tier Icons off (rs_ch_colorblind 0, the
	// default) the gem ran its first tic and deleted itself, never drawn: ~150-600 spawns a second in a big fight. The
	// random stream is kept exactly: the three random() arguments are still rolled in the same order, and a skipped gem
	// still makes the one draw its spawn would have made on the engine's spawn stream (p_mobj.cpp ConstructActor: the bob
	// phase, rng() for a class that does not set FloatBobPhase; the gem is not a monster and not FLOATRANDZ). The only
	// difference: no mod's WorldThingSpawned sees an invisible gem (Accessibility's sound cues stop drawing a false
	// "incoming" arrow for one).
	static void TierIcon(Actor mo, class<Actor> gem)
	{
		int xv = random(1, 4);
		int zv = random(0, 2);
		int an = random(0, 359);
		if (!mo) return;
		if (CV('rs_ch_colorblind', 0) != 1) { random[SpawnActor](0, 255); return; }
		mo.A_SpawnItemEx(gem, 0, 0, 32, xv, 0, zv, an, SXF_NOCHECKPOSITION);
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
// Sprites TI3R A-M: the series' style B tier gems (11-10; design/icons, sprites/monsters/TierIcons). They were
// missing until then, so the aid never drew.
// [11-11 ladder renumber] The frames are in LADDER order (A = tier 1 Common .. M = tier 13 White, strength order);
// the actors keep Colourful Hell's names (RS_ColorTierIconCH<n>, n = CH's icon index, spawned by name from every
// colour's states), so each one below shows its own colour's frame: CH5 Yellow -> G (tier 7), CH6 Red -> J (10),
// CH7 FireBlu -> H (8), CH8 Gray -> I (9), CH9 Abyss -> K (11), CH10 Black -> L (12), CH11 White -> M (13),
// CH12 Cyan -> E (5), CH13 Brown -> F (6).
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
		Scale 0.6;      // the 24 px gem at about 14 map units (11-10, my number)
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

class RS_ColorTierIconCH2 : RS_ColorTierIconCH { States { Show: TI3R B 30 Bright; Stop; } }   // Green, tier 2
class RS_ColorTierIconCH3 : RS_ColorTierIconCH { States { Show: TI3R C 30 Bright; Stop; } }   // Blue, tier 3
class RS_ColorTierIconCH4 : RS_ColorTierIconCH { States { Show: TI3R D 30 Bright; Stop; } }   // Purple, tier 4
class RS_ColorTierIconCH5 : RS_ColorTierIconCH { States { Show: TI3R G 30 Bright; Stop; } }   // Yellow, tier 7
class RS_ColorTierIconCH6 : RS_ColorTierIconCH { States { Show: TI3R J 30 Bright; Stop; } }   // Red, tier 10
class RS_ColorTierIconCH7 : RS_ColorTierIconCH { States { Show: TI3R H 30 Bright; Stop; } }   // FireBlu, tier 8
class RS_ColorTierIconCH8 : RS_ColorTierIconCH { States { Show: TI3R I 30 Bright; Stop; } }   // Gray, tier 9
class RS_ColorTierIconCH9 : RS_ColorTierIconCH { States { Show: TI3R K 30 Bright; Stop; } }   // Abyss, tier 11
class RS_ColorTierIconCH10 : RS_ColorTierIconCH { States { Show: TI3R L 30 Bright; Stop; } }   // Black, tier 12
class RS_ColorTierIconCH11 : RS_ColorTierIconCH { States { Show: TI3R M 30 Bright; Stop; } }   // White, tier 13
class RS_ColorTierIconCH12 : RS_ColorTierIconCH { States { Show: TI3R E 30 Bright; Stop; } }   // Cyan, tier 5
class RS_ColorTierIconCH13 : RS_ColorTierIconCH { States { Show: TI3R F 30 Bright; Stop; } }   // Brown, tier 6

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
		A8Y5 A 6 Bright;
		Goto Death;
	Death:
		A8Y5 A 6 Bright A_SetScale(0.8,0.8);
		A8Y5 A 6 Bright A_SetScale(0.6,0.6);
		A8Y5 A 6 Bright A_SetScale(0.4,0.4);
		A8Y5 A 6 Bright A_SetScale(0.2,0.2);
		A8Y5 A 6 Bright A_SetScale(0.05,0.05);
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
		TNT1 AB 0 A_PlaySound("world/barrelx");
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
