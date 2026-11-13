// GNRC_Reloaded: the rounds in each gun (GNRC's player.txt magazines, same sizes) and the player.
// The reserves are GNRC's (gnrc_actors.gen.zs: PistolAmmo, RifleAmmo, Nato) and Doom's (Shell, RocketAmmo, Cell).

// each its own Ammo (no shared abstract parent: "give ammo" spawns every Ammo class)
class RSQGW_PistolMag : Ammo { Default { Inventory.Amount 0; Inventory.MaxAmount 11; Ammo.BackpackAmount 0; Ammo.BackpackMaxAmount 11; +INVENTORY.IGNORESKILL } }
class RSQGW_RifleMag : Ammo { Default { Inventory.Amount 0; Inventory.MaxAmount 31; Ammo.BackpackAmount 0; Ammo.BackpackMaxAmount 31; +INVENTORY.IGNORESKILL } }
class RSQGW_ShotgunMag : Ammo { Default { Inventory.Amount 0; Inventory.MaxAmount 8; Ammo.BackpackAmount 0; Ammo.BackpackMaxAmount 8; +INVENTORY.IGNORESKILL } }
class RSQGW_DBSGMag : Ammo { Default { Inventory.Amount 0; Inventory.MaxAmount 2; Ammo.BackpackAmount 0; Ammo.BackpackMaxAmount 2; +INVENTORY.IGNORESKILL } }
class RSQGW_MinigunMag : Ammo { Default { Inventory.Amount 0; Inventory.MaxAmount 150; Ammo.BackpackAmount 0; Ammo.BackpackMaxAmount 150; +INVENTORY.IGNORESKILL } }
class RSQGW_RocketMag : Ammo { Default { Inventory.Amount 0; Inventory.MaxAmount 5; Ammo.BackpackAmount 0; Ammo.BackpackMaxAmount 5; +INVENTORY.IGNORESKILL } }
class RSQGW_PlasmaMag : Ammo { Default { Inventory.Amount 0; Inventory.MaxAmount 60; Ammo.BackpackAmount 0; Ammo.BackpackMaxAmount 60; +INVENTORY.IGNORESKILL } }

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
