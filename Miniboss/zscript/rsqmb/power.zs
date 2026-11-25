// ============================================================================
// RSQ_Miniboss -- YOUR DAMAGE KEEPS UP WITH THE COLOUR (owner 2026-11-25: "without developing any sort of BD dependent GBOVR
// trees (that would level up guns to stay competitive), the enemy numbers need to come down ... we may want to scale up damage
// with rank or tier, or successful Revenge / Revive").
//
//   BY THE COLOUR   every player's damage x (1 + rsqmb_power_step x (the World Tier - 1)): +10% a colour above Common, x1.9
//                   at Red (tier 10, the top since RSQ Monsters' WORLD_TOP). With RSQ Monsters' health curve (at most x2.5 at
//                   Red) a monster at the top takes about 1.3 times as long to kill as at Common. The World Tier is RSQ
//                   Monsters' rsq_mon_worldtier, by name: without it, x1.
//   THE COMEBACK    a REVENGE (RSQ SlowMo's DOWN: you killed the monster that downed you, "down.revenge") or a REVIVE (you got
//                   up from DOWN, "down.up") gives that player x rsqmb_comeback_mult (1.5) for rsqmb_comeback_secs (10 s), and
//                   RSQ VisualRewards' toast says so. RSQ SlowMo tells every service named *RSQDownJoin, so nothing links.
//   HOW             RSQMB_Power, a token every player carries (RSQMB_PowerHandler gives it), scales the damage he deals
//                   (Inventory.ModifyDamage, not passive): his guns, fists, blades and thrown things alike, whatever mod made
//                   them, since the engine asks the attacker's inventory for every hit he is the source of.
// Rig only, not headset-confirmed.
// ============================================================================

class RSQMB_Power : Inventory
{
	int comebackUntil;     // level.maptime the comeback lasts until (0 none)

	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.QUIET
		+INVENTORY.PERSISTENTPOWER
	}

	static double ColourMult()
	{
		let c = CVar.FindCVar('rsq_mon_worldtier');
		if (!c) return 1.0;
		int t = clamp(c.GetInt(), 1, 10);
		return 1.0 + clamp(RSQMB_Handler.CF('rsqmb_power_step', 0.10), 0.0, 0.5) * (t - 1);
	}

	double Mult()
	{
		double m = ColourMult();
		if (comebackUntil > level.maptime) m *= clamp(RSQMB_Handler.CF('rsqmb_comeback_mult', 1.5), 1.0, 4.0);
		return m;
	}

	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		if (passive || damage <= 0) return;
		double m = Mult();
		if (m == 1.0) return;
		newdamage = max(1, int(round(damage * m)));
	}

	// a REVENGE or a REVIVE: the comeback for that player, and the toast
	static void Comeback(int pn, String why)
	{
		if (pn < 0 || pn >= MAXPLAYERS || !playeringame[pn] || !players[pn].mo) return;
		let pmo = players[pn].mo;
		let pw = RSQMB_Power(pmo.FindInventory('RSQMB_Power'));
		if (!pw) pw = RSQMB_Power(pmo.GiveInventoryType('RSQMB_Power'));
		if (!pw) return;
		double secs = clamp(RSQMB_Handler.CF('rsqmb_comeback_secs', 10.0), 0.0, 60.0);
		if (secs <= 0) return;
		pw.comebackUntil = level.maptime + int(secs * TICRATE);
		int pct = int(round((clamp(RSQMB_Handler.CF('rsqmb_comeback_mult', 1.5), 1.0, 4.0) - 1.0) * 100));
		let it = ServiceIterator.Find("RSQVR_Service");
		Service s;
		while (s = it.Next())
		{
			if (s.GetClassName() != 'RSQVR_Service') continue;
			s.GetInt("toast", "up|DAMAGE UP", 0, 0, pmo);
			break;
		}
		if (RSQMB_Handler.CI('rsqmb_debug', 0))
			Console.Printf("RSQMB power t%d: player %d %s: damage x%.2f for %.0f s (colour x%.2f)", level.maptime, pn, why, pw.Mult(), secs, ColourMult());
	}
}

// every player carries the token; a new life or a new game gives it again
class RSQMB_PowerHandler : EventHandler
{
	override void WorldTick()
	{
		if (level.maptime % 35 != 1) return;
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			if (!playeringame[i] || !players[i].mo || players[i].mo.health <= 0) continue;
			if (!players[i].mo.FindInventory('RSQMB_Power')) players[i].mo.GiveInventory('RSQMB_Power', 1);
		}
	}
	override void NetworkProcess(ConsoleEvent e)
	{
		// test (console): netevent rsqmb_comeback -- the comeback as a REVIVE would give it
		if (e.Name ~== "rsqmb_comeback" && CVar.FindCVar('sv_cheats') && CVar.FindCVar('sv_cheats').GetBool()) RSQMB_Power.Comeback(e.Player, "test");
	}
}

// RSQ SlowMo's DOWN tells every *RSQDownJoin service (SlowMo down.zs Tell)
class RSQMB_RSQDownJoin : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "down.revenge") { RSQMB_Power.Comeback(intArg, "REVENGE"); return 1; }
		if (request == "down.up") { RSQMB_Power.Comeback(intArg, "REVIVE"); return 1; }
		return 0;
	}
}
