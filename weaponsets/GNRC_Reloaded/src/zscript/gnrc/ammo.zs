// GNRC_Reloaded: the rounds in each gun (GNRC's player.txt magazines, same sizes) and the player.
// The reserves are GNRC's (gnrc_actors.gen.zs: PistolAmmo, RifleAmmo, Nato) and Doom's (Shell, RocketAmmo, Cell).

class RSQGW_Mag : Ammo abstract
{
	Default
	{
		Inventory.Amount 0;
		Ammo.BackpackAmount 0;
		+INVENTORY.IGNORESKILL
	}
}
class RSQGW_PistolMag : RSQGW_Mag { Default { Inventory.MaxAmount 11; Ammo.BackpackMaxAmount 11; } }
class RSQGW_RifleMag : RSQGW_Mag { Default { Inventory.MaxAmount 31; Ammo.BackpackMaxAmount 31; } }
class RSQGW_ShotgunMag : RSQGW_Mag { Default { Inventory.MaxAmount 8; Ammo.BackpackMaxAmount 8; } }
class RSQGW_DBSGMag : RSQGW_Mag { Default { Inventory.MaxAmount 2; Ammo.BackpackMaxAmount 2; } }
class RSQGW_MinigunMag : RSQGW_Mag { Default { Inventory.MaxAmount 150; Ammo.BackpackMaxAmount 150; } }
class RSQGW_RocketMag : RSQGW_Mag { Default { Inventory.MaxAmount 5; Ammo.BackpackMaxAmount 5; } }
class RSQGW_PlasmaMag : RSQGW_Mag { Default { Inventory.MaxAmount 60; Ammo.BackpackMaxAmount 60; } }

// GNRC's player (player.txt): the Beretta and the knuckle, 50 rounds of 9 mm, and every magazine loaded (so a gun picked
// up later comes loaded, as GNRC does)
class RSQGW_Player : DoomPlayer
{
	Default
	{
		Player.DisplayName "Marine";
		Player.StartItem "RSQGW_Beretta";
		Player.StartItem "RSQGW_Knuckle";
		Player.StartItem "RSQGW_PistolAmmo", 50;
		Player.StartItem "RSQGW_PistolMag", 10;
		Player.StartItem "RSQGW_ShotgunMag", 8;
		Player.StartItem "RSQGW_DBSGMag", 2;
		Player.StartItem "RSQGW_RifleMag", 30;
		Player.StartItem "RSQGW_MinigunMag", 150;
		Player.StartItem "RSQGW_RocketMag", 5;
		Player.StartItem "RSQGW_PlasmaMag", 60;
	}
}
