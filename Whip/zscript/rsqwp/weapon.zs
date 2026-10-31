// weapon.zs -- the whip as a WEAPON (owner 2026-10-31: "whip is a weapon"; slot 1 with the melee weapons, either hand).
//
// TRIGGER: hold = the whip is out (it uncoils from the hand; swing it to crack), let go = it rolls up. Once it has
// caught an edge and become a rope: hold = reel in, let go = hang, a quick tap = let go of the rope (as the old bind).
// ALT-FIRE: point the OTHER hand and hold alt-fire to lock a target (the crack flies to it). Once the whip has caught an
// edge, alt-fire reels you in instead, and you mantle over the lip at the top.
// Either hand: the off-hand copy fires on the off-hand trigger (BT_OFFHANDATTACK / BT_OFFHANDALTATTACK).
//
// It drives the same whip and line as the old binds (core.Press / Release, RSQWP_Whip), which still work.
// The hand is Brutal Doom VR's own (MODELDEF: its axe grip around the whip handle); without BD the handle shows alone.

class RSQWP_WhipWeapon : Weapon
{
	Default
	{
		Weapon.SlotNumber 1;
		Weapon.SelectionOrder 3900;
		Weapon.AmmoUse 0;
		Weapon.Kickback 0;
		Weapon.BobStyle "InverseSmooth";
		Inventory.PickupMessage "You got the whip!";
		Tag "Whip";
		+WEAPON.MELEEWEAPON
		+WEAPON.NOALERT
		+WEAPON.NOAUTOFIRE
		+WEAPON.WIMPY_WEAPON
		+INVENTORY.UNDROPPABLE
	}

	int Hand() { return (owner && owner.player && owner.player.OffhandWeapon == self) ? 1 : 0; }

	bool TriggerHeld()
	{
		if (!owner || !owner.player) return false;
		return (owner.player.cmd.buttons & (Hand() ? BT_OFFHANDATTACK : BT_ATTACK)) != 0;
	}
	bool AltHeld()
	{
		if (!owner || !owner.player) return false;
		return (owner.player.cmd.buttons & (Hand() ? BT_OFFHANDALTATTACK : BT_ALTATTACK)) != 0;
	}

	action void A_WhipDown()
	{
		let pmo = PlayerPawn(self);
		let core = RSQWP_Core.Get();
		if (!pmo || !core) return;
		int hand = invoker.Hand();
		Vector3 org = RSQWP_Util.HandPos(pmo, hand);
		Vector3 dir = RSQWP_Util.MapDir(RSQWP_Util.HandYaw(pmo, hand), RSQWP_Util.HandPitch(pmo, hand));
		core.Press(pmo.PlayerNumber(), hand, org, dir);
		let w = RSQWP_Whip.Get();
		if (w) w.byWeapon[pmo.PlayerNumber() * 2 + hand] = true;
	}
	// held: stay; released: let go (the whip rolls up, or the rope hangs / a tap lets go)
	action state A_WhipHold()
	{
		if (RSQWP_Util.Flag("rsqwp_debug", false) && level.maptime % 10 == 0 && player)
		{
			let ps = player.FindPSprite(invoker.Hand() ? PSP_OFFHANDWEAPON : PSP_WEAPON);
			Console.Printf("T_WPWEAP t%d ready %s off %s psp %s", level.maptime, player.ReadyWeapon ? player.ReadyWeapon.GetClassName() : 'none',
				player.OffhandWeapon ? player.OffhandWeapon.GetClassName() : 'none', ps && ps.CurState ? "yes" : "no");
		}
		if (invoker.TriggerHeld()) return ResolveState(null);
		let pmo = PlayerPawn(self);
		let core = RSQWP_Core.Get();
		if (pmo && core)
		{
			int hand = invoker.Hand();
			int pn = pmo.PlayerNumber();
			core.Release(pn, hand);
			let w = RSQWP_Whip.Get();
			if (w) w.WeaponUp(pn * 2 + hand, pmo);
		}
		return ResolveState("Ready");
	}

	// alt-fire: lock (whip out or not), or reel when the whip has caught an edge
	action void A_AltDown()
	{
		let pmo = PlayerPawn(self);
		let core = RSQWP_Core.Get();
		let w = RSQWP_Whip.Get();
		if (!pmo || !core || !w) return;
		int i = pmo.PlayerNumber() * 2 + invoker.Hand();
		if (core.hooks[i]) { core.held[i] = true; core.pressFired[i] = true; core.altReel[i] = true; }
		else { w.lockHeld[i] = true; w.lockLeft[i] = 35; w.byWeapon[i] = true; }
	}
	action state A_AltHold()
	{
		if (invoker.AltHeld()) return ResolveState(null);
		let pmo = PlayerPawn(self);
		let core = RSQWP_Core.Get();
		let w = RSQWP_Whip.Get();
		if (pmo && core && w)
		{
			int i = pmo.PlayerNumber() * 2 + invoker.Hand();
			if (core.altReel[i]) { core.altReel[i] = false; if (!invoker.TriggerHeld()) core.held[i] = false; }
			w.lockHeld[i] = false;
		}
		return ResolveState("Ready");
	}

	States
	{
	Spawn:
		WHPW A -1;
		Stop;
	Select:
		WHPW A 1 A_Raise(12);
		Loop;
	Deselect:
		WHPW A 0
		{
			// put the whip away when the weapon goes
			let pmo = PlayerPawn(self);
			let w = RSQWP_Whip.Get();
			let core = RSQWP_Core.Get();
			if (pmo && w && core)
			{
				int i = pmo.PlayerNumber() * 2 + invoker.Hand();
				core.Release(pmo.PlayerNumber(), invoker.Hand());
				w.WeaponUp(i, pmo);
				w.lockHeld[i] = false;
			}
		}
		WHPW A 1 A_Lower(12);
		Wait;
	Ready:
		WHPW A 1 A_WeaponReady();
		Loop;
	Fire:
		WHPW B 1 A_WhipDown();
	Hold:
		WHPW B 1 A_WhipHold();      // B: the hand alone -- the whip draws its own handle while it is out
		Loop;
	AltFire:
		WHPW A 1 A_AltDown();
	AltHold:
		WHPW A 1 A_AltHold();
		Loop;
	}
}
