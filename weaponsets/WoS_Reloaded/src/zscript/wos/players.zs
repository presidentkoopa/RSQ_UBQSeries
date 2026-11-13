// RSQ_WeaponsOfSaturn: the start choices (owner: "start with pistol + shotgun, or start with Pistol + 1911, or start with
// shotgun + mp40 ... make them player classes to select on game start"). Each is WoS's PistolPlayer (PLAYER.txt): the
// Knuckles, its guns, their reserve, and every magazine pre-loaded as WoS does (so a gun picked up later comes loaded).
// Three rockets for the underbarrel when RSQ Grenade is not loaded: RSQ_Start (zscript/rsq/alias.zs, generated).
class RSQWS_StartBase : DoomPlayer abstract
{
	Default
	{
		Player.StartItem "RSQWS_Knuckles";
		Player.StartItem "RSQWS_9mm", 10;
		Player.StartItem "RSQWS_ACP", 7;
		Player.StartItem "RSQWS_MP40Ammo", 32;
		Player.StartItem "RSQWS_LoadedShell", 8;
		Player.StartItem "RSQWS_LoadedShells", 2;
		Player.StartItem "RSQWS_Magazine", 30;
		Player.StartItem "RSQWS_NatoBelt", 120;
		Player.StartItem "RSQWS_RocketRounds", 12;
		Player.StartItem "RSQWS_Cellpak", 60;
		Player.StartItem "RSQWS_BFGCell", 160;
	}
	States
	{
	Spawn:
		PLAY A -1;
		Loop;
	See:
		PLAY ABCD 4;
		Loop;
	}
}

class RSQWS_PistolShotgunPlayer : RSQWS_StartBase
{
	Default
	{
		Player.DisplayName "Pistol + Shotgun";
		Player.StartItem "RSQWS_Beretta";
		Player.StartItem "RSQWS_Riotgun";
		Player.StartItem "Clip", 60;		// WoS PistolPlayer's
		Player.StartItem "Shell", 8;		// the Riot Gun's own pickup amount (Weapon.AmmoGive 8)
	}
}

class RSQWS_Pistol1911Player : RSQWS_StartBase
{
	Default
	{
		Player.DisplayName "Pistol + 1911";
		Player.StartItem "RSQWS_Beretta";
		Player.StartItem "RSQWS_1911";
		Player.StartItem "Clip", 60;
		Player.StartItem "RSQWS_Bullets", 16;	// two magazines of .45
	}
}

class RSQWS_ShotgunMP40Player : RSQWS_StartBase
{
	Default
	{
		Player.DisplayName "Shotgun + MP40";
		Player.StartItem "RSQWS_Riotgun";
		Player.StartItem "RSQWS_MP40";
		Player.StartItem "Shell", 8;
		Player.StartItem "Clip", 60;		// the MP40's reserve is Clip (WoS)
	}
}
