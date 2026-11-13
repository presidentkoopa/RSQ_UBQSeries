// RS VR hands for DUAL WIELD (2026-10-16, owner). A gun moved into the off hand takes the off
// hand from RSQ_Hands, and with it every hand RSQ_Hands draws. So while a gun is in the off hand:
//   - each gun (off hand, and main hand) is held by our posed hand, finger on the trigger,
//     squeezing while that hand fires (off: BT_OFFHANDATTACK, main: BT_ATTACK);
//   - the hand is a layer CALLED BY THE GUN, because only the off-hand weapon may draw on the
//     off controller (models.cpp); its model is a block of the gun's own class (MODELDEF.rsqdual,
//     the gun's hook baked into Offset), so no ModifyBobLayer3D is needed;
//   - RSQ_Hands' own layers are cleared (they would sit wrong without it). It puts them back
//     when it returns to the off hand.
// The hands do not follow the guns' recoil kick here. rsq_hands 0 hides them, as everywhere.
class RSQ_DualHands : EventHandler
{
	const OFFGUN = 2300;
	const MAINGUN = 2301;

	override void WorldTick()
	{
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo)
				continue;
			let mo = players[n].mo;
			let p = mo.player;
			let off = p.OffhandWeapon;
			bool dual = off && !(off is 'RSQ_Hands') && p.playerstate == PST_LIVE && RSQ_Hands.Shown(mo);
			let gs = RSQ_Hands(mo.FindInventory('RSQ_Hands'));	// it holds the hand states (DTrg..)
			if (dual)
			{
				Clear(p, RSQ_Layers.GUNHAND);
				Clear(p, RSQ_Layers.SUPPORT);
				Clear(p, RSQ_Layers.FREEHAND);
			}
			Hand(p, OFFGUN, dual ? off : null, gs, (p.cmd.buttons & BT_OFFHANDATTACK) != 0);
			Hand(p, MAINGUN, dual ? p.ReadyWeapon : null, gs, (p.cmd.buttons & BT_ATTACK) != 0);
		}
	}

	static void Clear(PlayerInfo p, int id)
	{
		if (p.FindPSprite(id))
			p.SetPsprite(id, null);
	}

	static void Hand(PlayerInfo p, int id, Weapon w, RSQ_Hands gs, bool firing)
	{
		// 1.4: not only guns -- the fists and the VR grenade keep their hand too (MODELDEF.rsqdual)
		String label = "";
		Name cn = w ? RSQ_Alias.BD(w) : 'None';
		if (gs && cn == 'Melee_Attacks')
			label = "DFist";
		else if (gs && cn == 'HandGrenades')
		{
			let g = p.FindPSprite(id == MAINGUN ? PSP_WEAPON : PSP_OFFHANDWEAPON);
			if (g && g.Sprite == Actor.GetSpriteIndex('RQNP'))
				label = "DNade";
		}
		else
		{
			int i = w && gs ? RSQ_HandTable.Index(w) : 0;
			if (i == 24)	// 2.0.2 dual axes (owner r3 item 37): each axe in its own FBX hand (RQVI, MODELDEF.rsqaxedual)
				label = firing ? "DFbxSqzAxe" : "DFbxTrgAxe";
			else if (i > 0 && (i < 24 || i > 26) && RSQ_HandTable.GunRot(i) == (0, 0, 0))	// not the axe / chainsaw / sword (r12 port: their GunRot is 0 now, FBX hands baked in place; dual wield keeps no hand for them, as before)
			{
				String tf = RSQ_HandTable.Trigger(i);
				label = tf != "" ? (firing ? "DSqz" : "DTrg") .. tf : "DGun" .. RSQ_HandTable.GunOne(i);
				if (i == 4 || i == 7)	// BD 2.0 b1: the FBX hands
					label = (firing ? "DFbxSqz" : "DFbxTrg") .. (i == 4 ? "P" : "F");
				if (i == 1)	// shotguns: AssaultShotgun
					label = firing ? "DFbxSqzAS" : "DFbxTrgAS";
				if (i == 17 && !(RSQ_Alias.BD(w) == 'BrutalRevolver'))	// batch 4: Revolver
					label = firing ? "DFbxSqzRev" : "DFbxTrgRev";
				if (i == 17 && RSQ_Alias.BD(w) == 'BrutalRevolver')	// 2026-10-27: dual Moonlight (both hands; RSQ_Off_BrutalRevolver is a BrutalRevolver)
					label = firing ? "DFbxSqzBru" : "DFbxTrgBru";
				if (i == 21)	// shotguns: Shot_Gun
					label = firing ? "DFbxSqzSG" : "DFbxTrgSG";
				if (i == 8)	// r9 port: GrenadeLauncher
					label = firing ? "DFbxSqzGL" : "DFbxTrgGL";
				if (i == 19)	// r9 port: Rocket_Launcher
					label = firing ? "DFbxSqzRL" : "DFbxTrgRL";
				if (i == 16)	// r9 port: RailGun
					label = firing ? "DFbxSqzRail" : "DFbxTrgRail";
				if (i == 15)	// r9 port: Plasma_Gun
					label = firing ? "DFbxSqzPlas" : "DFbxTrgPlas";
				if (i == 13)	// r9 port: Minigun
					label = firing ? "DFbxSqzMini" : "DFbxTrgMini";
				if (i == 11)	// r10 port: MG42
					label = firing ? "DFbxSqzMG42" : "DFbxTrgMG42";
				if (i == 14)	// r10 port: NukeLauncher
					label = firing ? "DFbxSqzNuke" : "DFbxTrgNuke";
				if (i == 2)	// r10 port: BFG10k
					label = firing ? "DFbxSqzBFGk" : "DFbxTrgBFGk";
				if (i == 3)	// r11 port: BIG_FUCKING_GUN
					label = firing ? "DFbxSqzBFG9" : "DFbxTrgBFG9";
				if (i == 10)	// r11 port: IncendiaryLauncher
					label = firing ? "DFbxSqzInc" : "DFbxTrgInc";
				if (i == 6)	// r11 port: Devastator
					label = firing ? "DFbxSqzDeva" : "DFbxTrgDeva";
				if (i == 20)	// r11 port: SSG
					label = firing ? "DFbxSqzSSG" : "DFbxTrgSSG";
				if (i == 23)	// r12 port: Unmaker
					label = firing ? "DFbxSqzUnm" : "DFbxTrgUnm";
				if (i == 9)	// r12 port: HellishMissileLauncher
					label = firing ? "DFbxSqzHML" : "DFbxTrgHML";
				if (i == 18)	// batch 4: Rifle
					label = firing ? "DFbxSqzRif" : "DFbxTrgRif";
				if (i == 12)	// batch 3: MP40
					label = firing ? "DFbxSqzM" : "DFbxTrgM";
				if (i == 5)	// batch 2: BrutalSMG
					label = firing ? "DFbxSqzS" : "DFbxTrgS";
			}
		}
		if (label == "")
		{
			Clear(p, id);
			return;
		}
		State st = gs.FindStateByString(label);
		if (!st)
		{
			Clear(p, id);
			return;
		}
		let psp = p.FindPSprite(id);
		if (psp && psp.Caller == w && psp.CurState == st)
			return;
		p.SetPsprite(id, st, false, w);
		psp = p.FindPSprite(id);
		if (psp)
		{
			psp.bAddWeapon = false;
			psp.bAddBob = true;
			psp.y = WEAPONTOP;		// as hands.zs SetLayer: y 0 would tilt the model 8 degrees
			psp.oldy = WEAPONTOP;
		}
	}
}
