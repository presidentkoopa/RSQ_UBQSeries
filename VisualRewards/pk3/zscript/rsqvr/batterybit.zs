// THE BATTERY BIT (owner 2026-11-06, design/DECISIONS_DEATH_BONES.md 3; RSQ FnF's "Bones Drop Battery Bits"): a Kill Rewards bit
// in a battery colour of its own (yellow, sprite KRBB: SoM's orb recoloured, tools/gen_battery_bit.py). RSQ FnF asks for them by
// name when a Legion of Bones monster dies (RSQVR_Service "kr.battery": intArg how many, objectArg the body): they burst out with
// SoM's throw, live, blink out and fly to you like every bit (RSQ_KRBit). Picked up, it refills the toucher's flashlight battery
// through RSQ FnF by name (RSQFF_TorchService "battery.add", 0.15 = 15% of a full battery). FnF decides who drops them and how
// many; nothing here drops one by itself, and without FnF none is ever asked for. Rig only, not headset-confirmed.
class RSQ_KRBatteryBit : Inventory
{
	mixin RSQ_KRBit;
	const REFILL = 0.15;
	Default
	{
		Radius 10; Height 8;
		Inventory.MaxAmount 0;
		Inventory.PickupMessage "";
		+INVENTORY.ALWAYSPICKUP;
	}
	override void Tick() { Super.Tick(); BitTick(); }

	override bool TryPickup(in out Actor toucher)
	{
		let pmo = PlayerPawn(toucher);
		if (!pmo || !pmo.player) return false;
		let it = ServiceIterator.Find("RSQFF_TorchService");
		Service s;
		while (s = it.Next()) if (s.GetClassName() == 'RSQFF_TorchService') { s.GetInt("battery.add", "", pmo.PlayerNumber(), REFILL); break; }
		GoAwayAndDie();
		return true;
	}

	// num bits out of a body (RSQ_KRHandler.Burst's throw: 32 up, 1-6 out and up, a random heading); returns how many
	static int Burst(Actor a, int num)
	{
		if (!a || num <= 0) return 0;
		int made = 0;
		for (int i = 0; i < num; ++i)
		{
			bool ok; Actor bit;
			[ok, bit] = a.A_SpawnItemEx("RSQ_KRBatteryBit", 0, 0, 32, random[RSQKR](1, 6), 0, random[RSQKR](1, 6), random[RSQKR](0, 360));
			if (bit) made++;
		}
		return made;
	}
	States { Spawn: KRBB A 4; KRBB A 4 BRIGHT; Loop; }
}
