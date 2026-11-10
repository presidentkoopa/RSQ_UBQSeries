// ============================================================================
// THE SCORE ON THE WRIST (owner's pick 58, an option, off: rs_score_wrist).
//
// The running total, in small gold digits just above the off-hand controller (the watch wrist), laid out across your
// line of sight. NOT A CANVAS: QZD 17.3 draws a canvas texture black in VR (Quest teardown apply/07_WHEEL.md 6.2,
// measured; RSQ_TacticalRig measured it again: its holster ammo count, rig.zs, is billboard digits for that reason).
// So each digit is a billboard actor -- billboards face your eyes on their own -- whose picture is the glyph of Doom's
// own small font, the IWAD's STCFN048-057, shown through the actor's picnum (the renderer's direct texture override,
// hw_sprites.cpp "isPicnumOverride"), so no art and no TEXTURES lump is added. Drawn additive, shaded gold.
//
// Playsim, per player, from that player's own user setting (synced) and hand pose, so a netgame spawns the same
// actors everywhere. Without a VR hand (the engine puts both hands on the pawn out of VR) nothing shows.
// ============================================================================

class RS_ScoreWrist : EventHandler
{
	const DIGITS = 8;
	const DIGIT_M = 0.02;          // a digit's height, metres (x RSQ_Accessibility's Text Size)
	const ABOVE_M = 0.05;          // above the controller
	const GOLD = 0xFFD040;
	// TWO LAYERS a digit: the font is Doom's red ramp, and AddShaded draws by brightness, so one layer came out dim
	// on the rig (frame 2026-11-01); the second, added on the same spot, doubles it.
	const LAYERS = 2;
	Actor dig[MAXPLAYERS * DIGITS * LAYERS];
	transient TextureID glyph[10];
	transient bool glyphsFound;

	transient class<Inventory> remoteOut;    // RSQ Saber's UBQS_RemoteOut, by name (null without the Saber)

	private void FindGlyphs()
	{
		glyphsFound = true;
		String rn = "UBQS_RemoteOut";
		remoteOut = rn;
		for (int i = 0; i < 10; i++) glyph[i] = TexMan.CheckForTexture(String.Format("STCFN%03d", 48 + i), TexMan.Type_Any);
	}

	private void Hide(int pn) { for (int i = 0; i < DIGITS * LAYERS; i++) if (dig[pn * DIGITS * LAYERS + i]) dig[pn * DIGITS * LAYERS + i].bINVISIBLE = true; }

	override void WorldTick()
	{
		if (!glyphsFound) FindGlyphs();
		for (int pn = 0; pn < MAXPLAYERS; pn++)
		{
			if (!playeringame[pn] || !players[pn].mo) { Hide(pn); continue; }
			Show(pn, players[pn].mo);
		}
	}

	private void Show(int pn, PlayerPawn pmo)
	{
		let on = CVar.GetCVar("rs_score_wrist", players[pn]);
		let hid = CVar.GetCVar("rs_score_hide", players[pn]);
		let tr = RS_ScoreTracker(pmo.FindInventory("RS_ScoreTracker"));
		if (!on || !on.GetBool() || (hid && hid.GetBool()) || !tr || pmo.health <= 0) { Hide(pn); return; }
		// RSQ Saber's training remote panel takes this spot while the remote is out (owner 11-10: "Panel replaces Score")
		if (remoteOut && pmo.FindInventory(remoteOut)) { Hide(pn); return; }
		Vector3 hand;
		if (!pmo.OverrideAttackPosDir || !players[pn].PlayInVR || pmo.AttackPos == pmo.OffhandPos) { Hide(pn); return; }
		hand = pmo.OffhandPos;
		let c = CVar.FindCVar("vr_vunits_per_meter");
		double upm = (c && c.GetFloat() >= 1.0 && !multiplayer) ? c.GetFloat() : 34.0;
		double ps = level.pixelstretch > 0.1 ? level.pixelstretch : 1.2;
		String txt = String.Format("%d", clamp(tr.displayScore, 0, 99999999));
		int n = min(txt.Length(), DIGITS);
		double hU = DIGIT_M * upm * RSSC_A11y.Text();
		double sc = hU / 7.0;                                  // the glyphs are 7 px tall
		Vector3 pos = hand + (0, 0, ABOVE_M * upm / ps + hU * 0.5);
		Vector2 v = pos.xy - pmo.pos.xy;
		double vl = v.Length();
		Vector2 right = vl > 0.5 ? (v.y, -v.x) / vl : (sin(pmo.angle), -cos(pmo.angle));
		double a = RSSC_A11y.Dim(1.0);
		for (int i = 0; i < DIGITS * LAYERS; i++)
		{
			int slot = pn * DIGITS * LAYERS + i;
			int col = i / LAYERS;
			if (col >= n) { if (dig[slot]) dig[slot].bINVISIBLE = true; continue; }
			if (!dig[slot]) dig[slot] = Actor.Spawn("RS_WristDigit", pos, NO_REPLACE);
			let q = dig[slot];
			if (!q) continue;
			double off = (col - (n - 1) * 0.5) * 8.5 * sc;
			q.SetOrigin(pos + (right.x * off, right.y * off, 0), true);
			int d = txt.ByteAt(col) - 48;
			q.picnum = glyph[clamp(d, 0, 9)];
			q.Scale = (sc, sc);
			if (q.Alpha != a) q.A_SetRenderStyle(a, STYLE_AddShaded);
			q.SetShade(GOLD);
			q.bINVISIBLE = !q.picnum.IsValid();
		}
	}
}

class RS_WristDigit : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP +BRIGHT +NOTIMEFREEZE
		RenderStyle "AddShaded";
		Radius 1; Height 1;
	}
	States { Spawn: TNT1 A -1 Bright; Stop; }
}
