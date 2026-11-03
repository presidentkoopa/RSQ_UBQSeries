// RSQ HP Bars -- Damage Numbers.
// The numbers are damnums by Xaser Acheron (w/contributions by Major Cooke; MIT licence, see CREDITS.txt),
// github.com/XaserAcheron/damnums v1.0.2, folded in under this mod's names (owner, 2026-11-03). Its look and motion
// are kept as shipped: one actor per digit, damnums' digit-position sprites (renamed QC / QD), its fonts' scale,
// alpha and style, its colours, its toss / float physics, its fade. What changed (for Brutal Doom and VR):
//   - the numbers come from WorldThingDamaged (handler below), not a ticking item on every monster;
//   - no number for Brutal Doom's helpers (head hitboxes, boot smearers), for a hit on a thing already dead, or for
//     the Massacre / KillMe damage types; a number is never larger than the health the target had left;
//   - the font is read from its defaults (no font actor spawned per number);
//   - only damnums' two Doom fonts ship (Classic, its default on Doom, and Small), to keep sprite frames few.

enum RSQTHP_DamNum_Physics
{
	RSQTHP_DAM_PHYSICS_TOSS  = 0,
	RSQTHP_DAM_PHYSICS_FLOAT = 1,
};

const RSQTHP_DamNum_DefaultFontName = "RSQTHP_DamNumFontClassic";
const RSQTHP_DamNum_DefaultFontPrefix = "QC";
const RSQTHP_DamNum_DefaultTranslation = "RSQTHP_DamWhite";
const RSQTHP_DamNum_DefaultDamagetype = "None";
const RSQTHP_DamNum_LanguageTypecolorPrefix = "RSQTHP_DMG_TYPECOLOR_";
const RSQTHP_DamNum_DamnumsTypecolorPrefix = "DAMNUM_TYPECOLOR_";
const RSQTHP_DamNum_PlaceholderTranslation = "RSQTHP_DamDefault";

class RSQTHP_DamNum : Actor
{
	string fontPrefix;
	int digitCount;
	int digitPlace;
	uint8 digitValue;
	name damageType;

	const FADE_AMT = 0.05;
	const DAMAGE_CAP = 9999999;
	const STAT_NUMBER = STAT_USER + 18; // statnum #88 (damnums')

	Default
	{
		RenderStyle 'Add';
		Alpha 1.0;
		Gravity 0.4;
		Scale 0.75;

		-SOLID;
		+NOBLOCKMAP;
		+NOBLOCKMONST;
		+THRUACTORS;
		+BRIGHT;
		+NOINTERACTION;
		+NOTONAUTOMAP;
		+CLIENTSIDEONLY;
	}
	States
	{
	Spawn:
		#### ########## 1 Bright A_DamNumMovement();
		#### # 1 Bright A_DamNumMovement(FADE_AMT);
		Wait;
	}

	// gravity and/or floatiness (damnums')
	action void A_DamNumMovement(double fade = 0)
	{
		if (!self.bNoGravity) self.vel.z -= self.Gravity;
		if (fade) A_FadeOut(fade, 1);
	}

	// the sprite from the digit and its place in the number, so it sits right relative to the viewer (damnums')
	override void PostBeginPlay()
	{
		int dc = (digitCount == 0) ? 1 : digitCount;
		int dp = (digitPlace == 0) ? 1 : digitPlace;
		string fp = (fontPrefix == "") ? RSQTHP_DamNum_DefaultFontPrefix : fontPrefix;
		int spriteindex = GetSpriteIndex(fp .. dc .. dp);
		if (spriteindex != -1)
		{
			// frames A-J are the digits 0-9
			sprite = spriteindex;
			frame = digitValue;
		}
		else
		{
			sprite = GetSpriteIndex('UNKN');
			frame = 0;
		}
	}

	static clearscope string UserString(Name cv, string fb)
	{
		let c = CVar.GetCvar(cv, players[consoleplayer]);
		return c ? c.GetString() : fb;
	}
	static clearscope int UserInt(Name cv, int fb)
	{
		let c = CVar.GetCvar(cv, players[consoleplayer]);
		return c ? c.GetInt() : fb;
	}

	// the colour a damage type asks for in LANGUAGE: ours first, then damnums' own names (a mod written for damnums)
	static string TypeColour(Name damagetype)
	{
		string key = RSQTHP_DamNum_LanguageTypecolorPrefix .. damagetype;
		string v = StringTable.Localize("$" .. key);
		if (v != key) return v;
		key = RSQTHP_DamNum_DamnumsTypecolorPrefix .. damagetype;
		v = StringTable.Localize("$" .. key);
		if (v != key && v.Left(3) == "Dam") return "RSQTHP_" .. v;
		return "";
	}

	// spawn the digits of one number (damnums' spawnDamageNumbers)
	static int SpawnDamageNumbers(Vector3 position = (0,0,0), int damage = 0, Name damagetype = RSQTHP_DamNum_DefaultDamagetype)
	{
		PlayerInfo curPlayer = players[consoleplayer];
		if (!curPlayer || !curPlayer.mo || damage <= 0) return damage;

		// angle toward the console player just a bit
		Vector3 posDiff = (curPlayer.mo.pos - position);
		double ang = ((atan2(posDiff.y, posDiff.x) + 360.0) % 360.0) + frandom(-20, 20);

		int physics = UserInt('rsqthp_dmg_physics', 0);
		vector3 nvel = (1.0 * cos(ang), 1.0 * sin(ang), frandom(3.0, 4.0));
		bool noGravity = false;
		if (physics == RSQTHP_DAM_PHYSICS_FLOAT) { nvel = (0, 0, 1.0); noGravity = true; }

		// the font, read from its defaults (an unknown name falls back to the default font)
		class<RSQTHP_DamNumFont> fontclass = UserString('rsqthp_dmg_font', RSQTHP_DamNum_DefaultFontName);
		if (!fontclass) fontclass = RSQTHP_DamNum_DefaultFontName;
		let font = GetDefaultByType(fontclass);

		// the user's colour, unless it is "Default" (what the font suggests)
		string userTranslation = UserString('rsqthp_dmg_colour', RSQTHP_DamNum_PlaceholderTranslation);
		string fontTrans = font ? font.fontTrans : RSQTHP_DamNum_DefaultTranslation;
		if (userTranslation != RSQTHP_DamNum_PlaceholderTranslation) fontTrans = userTranslation;

		// damage type colour over that, when on
		if (UserInt('rsqthp_dmg_types', 1) && damagetype != RSQTHP_DamNum_DefaultDamagetype)
		{
			string tc = TypeColour(damagetype);
			if (tc != "") fontTrans = tc;
		}

		int dam = min(damage, DAMAGE_CAP);
		int place = 1;
		int length = log10(dam) + 1;
		while (dam > 0)
		{
			let dn = RSQTHP_DamNum(Spawn("RSQTHP_DamNum", position, ALLOW_REPLACE));
			if (dn && font)
			{
				dn.ChangeStatNum(STAT_NUMBER);
				dn.vel = nvel;
				dn.angle = ang;
				dn.bNoGravity = noGravity;
				dn.A_SetScale(font.scale.x, font.scale.y);
				dn.A_SetRenderStyle(font.alpha, font.GetRenderStyle());
				dn.A_SetTranslation(fontTrans);
				dn.fontPrefix = font.fontPrefix;
				dn.digitCount = length;
				dn.digitPlace = place;
				dn.digitValue = dam % 10;
				dn.damageType = damagetype;
			}
			dam /= 10;
			place++;
		}
		return damage;
	}
}

// Font: an actor so its sprites are registered (its states name them); only its defaults are read.
class RSQTHP_DamNumFont : Actor
{
	string fontPrefix;
	string fontTrans;

	property Prefix: fontPrefix;
	property DefaultTranslation: fontTrans;

	Default
	{
		+NOINTERACTION;
		+INVISIBLE;
		+CLIENTSIDEONLY;

		RSQTHP_DamNumFont.Prefix RSQTHP_DamNum_DefaultFontPrefix;
		RSQTHP_DamNumFont.DefaultTranslation RSQTHP_DamNum_DefaultTranslation;
	}
}

// damnums' Doom Classic font (its Game Default on Doom)
class RSQTHP_DamNumFontClassic : RSQTHP_DamNumFont
{
	Default
	{
		RSQTHP_DamNumFont.Prefix "QC";
		RSQTHP_DamNumFont.DefaultTranslation "RSQTHP_DamRed";
		Scale 0.75;
		Alpha 0.75;
		RenderStyle 'Translucent';
	}
	States
	{
	Spawn:
		QC11 A 0; QC21 A 0; QC22 A 0; QC31 A 0; QC32 A 0; QC33 A 0;
		QC41 A 0; QC42 A 0; QC43 A 0; QC44 A 0;
		QC51 A 0; QC52 A 0; QC53 A 0; QC54 A 0; QC55 A 0;
		QC61 A 0; QC62 A 0; QC63 A 0; QC64 A 0; QC65 A 0; QC66 A 0;
		QC71 A 0; QC72 A 0; QC73 A 0; QC74 A 0; QC75 A 0; QC76 A 0; QC77 A 0;
		Stop;
	}
}

// damnums' Doom Small font (its Game Default (small) on Doom)
class RSQTHP_DamNumFontSmall : RSQTHP_DamNumFont
{
	Default
	{
		RSQTHP_DamNumFont.Prefix "QD";
		RSQTHP_DamNumFont.DefaultTranslation "RSQTHP_DamRed";
		Scale 1.0;
		Alpha 1.0;
		RenderStyle 'Translucent';
	}
	States
	{
	Spawn:
		QD11 A 0; QD21 A 0; QD22 A 0; QD31 A 0; QD32 A 0; QD33 A 0;
		QD41 A 0; QD42 A 0; QD43 A 0; QD44 A 0;
		QD51 A 0; QD52 A 0; QD53 A 0; QD54 A 0; QD55 A 0;
		QD61 A 0; QD62 A 0; QD63 A 0; QD64 A 0; QD65 A 0; QD66 A 0;
		QD71 A 0; QD72 A 0; QD73 A 0; QD74 A 0; QD75 A 0; QD76 A 0; QD77 A 0;
		Stop;
	}
}
