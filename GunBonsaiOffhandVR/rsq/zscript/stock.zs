// STOCK GUN BONSAI UPGRADES: Silvergun / All (the owner, 2026-11-02; GBOVR_TREES.md section 3.13).
//
// Gun Bonsai's own upgrades that do not mesh with the series are pruned from the pool: the ones Kill Rewards
// already covers (Dark Harvest, the three Leeches) and four player upgrades (Intuition: HP Bars does it; Juggler;
// Player Damage; Thorns). The elementals and Rapid Fire on our melee weapons are a separate, per-weapon matter
// (bonsairc.rsq's `disable`) and are not touched here.
//
// HOW. Gun Bonsai keeps one registry of offerable upgrades (TFLV_Upgrade_Registry, held by its event handler) with
// a public Register / Unregister pair; BONSAIRC's `unregister` uses the same calls. Unregister removes a name from
// the pool and remembers it in `unregistered` so a later Register is refused; to put a name back we take it out
// of that list first, then Register. The pool is what GenerateUpgradesForPlayer / ForWeapon draw from, so a
// pruned name is offered nowhere: not on our weapons, not on the player, not on BD22's guns (the owner's call:
// he runs Kill Rewards with BD22 too). An upgrade a save already holds is an instance in a bag, not a registry
// entry: it keeps working and keeps showing. No Gun Bonsai file is changed and no file is shadowed for this.
//
// UNLOCK RSQ FEATURES off (owner 2026-11-22, SyncRsq below) takes the patch's own RSQ nodes out of the same pool.
//
// WHEN. On every map load, and whenever rsq_stock_mode changes (checked once a second, not every tic). The mode is
// a server cvar: one pool per game, every machine agrees.
//
//   rsq_stock_mode  0 Silvergun (the pruned list, default)   1 All (every stock upgrade Gun Bonsai registered)
class RSQ_StockHandler : EventHandler
{
	// the pruned names, Gun Bonsai 0.10.6's class names (GBOVR_TREES.md 3.13, the owner's verdicts 11-02)
	static const String PRUNED[] = {
		"TFLV_Upgrade_DarkHarvest",
		"TFLV_Upgrade_LifeLeech", "TFLV_Upgrade_ArmourLeech", "TFLV_Upgrade_AmmoLeech",
		"TFLV_Upgrade_Intuition", "TFLV_Upgrade_Juggler", "TFLV_Upgrade_PlayerDamage", "TFLV_Upgrade_Thorns"
	};

	int applied;        // the mode last applied, -1 = never
	int nextCheck;
	int rsqApplied;     // Unlock RSQ Features last applied: 0 off, 1 on, -1 never

	override void WorldLoaded(WorldEvent e)
	{
		applied = -1;
		rsqApplied = -1;
		nextCheck = 0;
		Sync(true);
	}

	override void WorldTick()
	{
		if (level.maptime < nextCheck) return;
		nextCheck = level.maptime + TICRATE;
		Sync(false);
	}

	static int Mode()
	{
		let cv = CVar.FindCVar("rsq_stock_mode");
		return (cv && cv.GetInt() == 1) ? 1 : 0;
	}

	void Sync(bool loud)
	{
		let reg = TFLV_Upgrade_Registry.GetRegistry();
		if (!reg) return;   // Gun Bonsai's handler is not up yet; next second
		SyncRsq(reg);
		int mode = Mode();
		if (mode == applied) return;
		int changed = 0;
		for (int i = 0; i < PRUNED.Size(); ++i)
		{
			String n = PRUNED[i];
			if (mode == 0)
			{
				// Silvergun: out of the pool. Unregister is a no-op on a name BONSAIRC already took out.
				if (reg.FindRegistration(n) >= 0) { reg.Unregister(n); ++changed; }
				else if (!reg.IsUnregistered(n)) reg.Unregister(n);   // never registered at all: still bar it
			}
			else
			{
				// All: back in, unless the class is not in this Gun Bonsai (nothing to register then)
				if (reg.FindRegistration(n) >= 0) continue;
				if (!ClassExists(n)) continue;
				int k = reg.unregistered.Find(n);
				if (k < reg.unregistered.Size()) reg.unregistered.Delete(k);
				if (reg.Register(n)) ++changed;
			}
		}
		applied = mode;
		if (loud || changed > 0)
			Console.Printf("\c[Gold]RSQ Gun Bonsai VR:\c- stock upgrades: %s (%d %s)", mode == 0 ? "Silvergun" : "All",
				changed, mode == 0 ? "pruned" : "restored");
	}

	// UNLOCK RSQ FEATURES (owner 2026-11-22; rsqgb_unlock_rsq, core.zs RSQ_MeleeUpgradeService). Off: every node this patch
	// registers (BONSAIRC's register list: every class named RSQ_Upgrade_*) leaves the pool the same way the pruned stock
	// names do, so no RSQ node is offered on any weapon or on the player; Gun Bonsai's own upgrades are untouched. On: each
	// RSQ name out of the pool goes back in. A node a save already learned is in its bag, not the pool: it stays (other mods
	// ignore it while the switch is off: the service answers "loaded" 0). Checked with the stock mode: at every map load and
	// once a second.
	void SyncRsq(TFLV_Upgrade_Registry reg)
	{
		int on = RSQ_MeleeUpgradeService.Unlocks() ? 1 : 0;
		if (on == rsqApplied) return;
		int changed = 0;
		if (on == 0)
		{
			for (uint i = 0; i < AllClasses.Size(); ++i)
			{
				String n = AllClasses[i].GetClassName();
				if (n.Left(12) != "RSQ_Upgrade_") continue;
				if (reg.FindRegistration(n) >= 0) { reg.Unregister(n); ++changed; }
			}
		}
		else
		{
			for (int k = int(reg.unregistered.Size()) - 1; k >= 0; --k)
			{
				String n = reg.unregistered[k];
				if (n.Left(12) != "RSQ_Upgrade_") continue;
				reg.unregistered.Delete(k);
				if (reg.Register(n)) ++changed;
			}
		}
		rsqApplied = on;
		if (changed > 0)
			Console.Printf("\c[Gold]RSQ Gun Bonsai VR:\c- Unlock RSQ Features %s (%d RSQ upgrades %s)", on == 1 ? "on" : "off",
				changed, on == 1 ? "offered again" : "no longer offered");
	}

	static bool ClassExists(String n)
	{
		Class<Object> c = n;
		return c != null;
	}
}
