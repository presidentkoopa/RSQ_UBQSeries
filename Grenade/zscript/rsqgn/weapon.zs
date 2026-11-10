// RSQ Grenade -- the grenade you hold (slot 9), its ammo and the two pickups.
//
// AMMO THE UAC SURVIVAL PACK'S WAY (JohnnyDoom's pack, DECORATE.grenade J_HandGrenadeAmmo / HandGrenadePack, parsed):
// one grenade a pickup, carry 8, a backpack gives 6 and raises the carry to 16; the pack of three is a child of the
// single, so it fills the same pile. Its pickup sprites are the pack's (JGNDD0 -> QGN1A0, MGRND0 -> QGN3A0), at the
// pack's Scale 0.5, with its pickup messages and its pickup sound (weapons/grnpullpin = DSGRPIN).

class RSQGN_Ammo : Ammo
{
	Default
	{
		Inventory.Amount 1;
		Inventory.MaxAmount 8;
		Ammo.BackpackAmount 6;
		Ammo.BackpackMaxAmount 16;
		Inventory.PickupMessage "You got a Type J Hand Grenade!";
		Inventory.PickupSound "rsqgn/pin";
		Inventory.Icon "QGN1A0";
		+INVENTORY.IGNORESKILL;
		Scale 0.5;
		Tag "Hand Grenades";
	}
	States
	{
	Spawn:
		QGN1 A -1;
		Stop;
	}
}

class RSQGN_Pack : RSQGN_Ammo
{
	Default
	{
		Inventory.Amount 3;
		Inventory.PickupMessage "Picked up a pack of Type J Hand grenades!";
	}
	States
	{
	Spawn:
		QGN3 A -1;
		Stop;
	}
}

// THE GRENADE IN THE HAND. The grenade IS the weapon (RS_Grenade's finding: a slot number belongs to a Weapon); what
// leaves the hand is RSQGN_Thrown. Either hand can hold it (the engine's own switch-hand, or RSQ Tactical Rig).
// Nothing happens on its trigger by itself: the handling (hand.zs) reads the buttons and the hands. The picture is
// the psprite's frame, set each tic by A_RSQGNReady from the handler's state:
//   A ring in, B pin out (ring hidden), C spoon gone (cooking), D cooking + the red flash.
class RSQGN_Grenade : Weapon
{
	Default
	{
		Weapon.SlotNumber 9;
		Weapon.SelectionOrder 3000;
		Weapon.AmmoType "RSQGN_Ammo";
		Weapon.AmmoUse 1;
		Weapon.AmmoGive 0;
		Weapon.Kickback 0;
		+WEAPON.NOALERT;
		+WEAPON.NOAUTOFIRE;
		+WEAPON.NOAUTOAIM;
		+WEAPON.NO_AUTO_SWITCH;		// given at the start without being put in your hand
		+WEAPON.NOAUTOSWITCHTO;		// never chosen for you when another gun runs dry
		+WEAPON.CHEATNOTWEAPON;		// "give all" leaves it out (with Brutal Doom VR loaded it must stay out of reach)
		// NOT NoAutoReverse: in the left controller the engine mirrors the model (hw_vrmodes.cpp GetWeaponTransform),
		// so the grenade sits in a left hand as Brutal Doom VR's placement puts it in a right one, ring to the thumb.
		// AttackDir / OffhandDir carry the same mirror, so the ring the off hand reaches for is where it is drawn.
		+INVENTORY.UNDROPPABLE;
		// TAG AVOIDS THE WORD "GRENADE" (RS_Grenade's note): ModelSwapper token-matches weapon tags and draws Brutal
		// Doom's grenade with its canned throw on anything tagged "grenade".
		Tag "Frag";
	}

	// The ready frame, then the picture for this tic (hand.zs HeldFrame). Set after A_WeaponReady so the state
	// loop cannot put frame A back before it is drawn.
	action void A_RSQGNReady()
	{
		A_WeaponReady(WRF_NOFIRE);
		if (!player || !player.mo) return;
		let psp = player.FindPSprite(player.OffhandWeapon == invoker ? PSP_OFFHANDWEAPON : PSP_WEAPON);
		if (!psp) return;
		int n = player.mo.PlayerNumber();
		int f = RSQGN_Handler.HeldFrame(n);
		psp.Frame = f;
		// THE KINDS (Gun Bonsai VR patch): the held kind's skin, except while the fuse flashes (the frag's red and amber)
		int k = RSQGN_Handler.KindOf(n);
		psp.Sprite = GetSpriteIndex(f <= 2 ? RSQGN_Kind.HeldSprite(k) : 'QGNH');
	}

	States
	{
	Ready:
		QGNH A 1 A_RSQGNReady;
		Loop;
	Select:
		QGNH A 1 A_Raise(18);
		Loop;
	Deselect:
		QGNH A 1 A_Lower(18);
		Loop;
	// required by the engine, never entered (WRF_NOFIRE): the trigger is read by the handling, not fired
	Fire:
		QGNH A 1;
		Goto Ready;
	Spawn:
		QGN1 A -1;
		Stop;
	// never entered: names QGNH E (Cook Sense 2's amber flash) for MODELDEF; A_RSQGNReady writes the frame
	AmberFrame:
		QGNH E -1;
		Stop;
	// never entered: names the kinds' held sprites for MODELDEF.kinds.txt (A_RSQGNReady sets them)
	KindFrames:
		QGK1 ABC 0; QGK2 ABC 0; QGK3 ABC 0; QGK4 ABC 0; QGK5 ABC 0; QGK6 ABC 0; QGK7 ABC 0; QGK8 ABC 0;
		Stop;
	}
}

// RUMBLE: the series' way (RSQ Tactical Rig's RSQTR_Buzzer): a tiny local A_QuakeEx, whose X intensity QuestZDoom
// sends to the left controller and Y to the right. Only the console player's own rumbles are made.
class RSQGN_Buzzer : Actor
{
	Actor feels;
	bool left;
	double amp;
	int total, tleft;

	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOSECTOR +DONTSPLASH
	}

	static void Start(Actor who, int hand, double strength, int tics)
	{
		if (!who || !who.player || who.player != players[consoleplayer]) return;
		// RSQ_Accessibility's RUMBLE STRENGTH (rsqa_rumble_scale, 0-2; by name, 1 without it), as every other series buzzer
		let rcv = CVar.FindCVar("rsqa_rumble_scale");
		double rs = rcv ? clamp(rcv.GetFloat(), 0.0, 2.0) : 1.0;
		if (rs <= 0) return;
		let q = RSQGN_Buzzer(Actor.Spawn("RSQGN_Buzzer", who.pos));
		if (!q) return;
		let cv = CVar.FindCVar("vr_control_scheme");
		bool lefty = cv && cv.GetInt() >= 10;
		q.feels = who;
		q.left = (hand == 1) != lefty;
		q.amp = clamp(strength, 0.05, 1.0) * rs;   // at Rumble Strength 1, exactly as before
		q.total = clamp(tics, 1, 16);
		q.tleft = q.total;
	}

	// RSQ_Accessibility's RUMBLE BACKUP, by name (as its tools/a11y_template.zs RumbleBackup; this mod carries no copy of
	// that class): as a rumble starts, at Quake Haptics 0, RSQ_Accessibility sends the engine's shot buzz on that
	// controller. This rumble is played as before either way; Rumble Backup off or RSQ_Accessibility absent, nothing.
	static void RumbleBackup(Actor who, bool left)
	{
		if (!who || !who.player) return;
		Name rsqaN = "RSQA_Menu"; class<Object> rsqaC = rsqaN;
		if (!rsqaC) return;
		let cv = CVar.FindCVar('rsqa_rumble_backup');
		if (!cv || !cv.GetInt()) return;
		let it = ServiceIterator.Find("RSQA_Service");
		let s = it.Next();
		if (s) s.GetInt("buzz", "RSQGN", who.PlayerNumber(), left ? 1 : 0);
	}

	override void Tick()
	{
		Super.Tick();
		if (bDestroyed) return;
		if (!feels) { Destroy(); return; }
		SetOrigin(feels.pos, true);
		if (tleft <= 0) return;
		if (tleft == total) RumbleBackup(feels, left);
		double a = amp * tleft / double(total) / 3.2;
		tleft--;
		A_QuakeEx(left ? a : 0.0, left ? 0.0 : a, 0, 2, 0, 8, "", QF_WAVE, 17.5, 17.5, 1);
	}

	States { Spawn: TNT1 A 20; Stop; }
}
