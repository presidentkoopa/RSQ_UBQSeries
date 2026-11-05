// RSQ FnF -- THE FLASHLIGHT (owner 11-03 20:38: "I support the flashlight proposal. Allow for selectable size, color, and
// quality."). docs/FLASHLIGHT_PROPOSAL.md's B+: one real spot light from the lens, a see-through additive cone you can see in
// the air, cut where it meets a wall or a monster (one trace), and a soft hotspot where it lands. Rig only, not
// headset-confirmed.
//
// IN VR:
//   1. TAKE: the OFF hand at the flashlight clip, on your chest on the OFF hand's own side (the flare pocket's mirror; it
//      reaches across, this one does not), grip: the flashlight is in that hand, ON (a click). The main hand keeps its gun.
//   2. That hand's TRIGGER turns it off and on.
//   3. PUT BACK: grip at the clip again. Anything else that takes the off hand (a flare from the pocket, another weapon,
//      death) puts it away; given the hand back by the flare, it comes back as it was (on or off). On a new level it stays
//      in the hand, switched off.
//   With a flare in the off hand the clip does nothing (one thing in the hand at a time).
// HELD in Brutal Doom 22 VR Reloaded's shotgun pump / forend support hand (fbx_s192_L.md3 frame 1; tools/gen_torch.py),
// drawn in BD22 VR's off-hand MODELDEF placement (as the flare is), toned by its Hand Skin Tone (model slot 7).
//
// BUDGET (FLASHLIGHT_PROPOSAL.md 2: a spot light costs like a point light of its whole range): ONE spot light per flashlight,
// no shadow map, its range set by Beam Quality (Quest 448, PCVR 640, High 896). The cone is one model, unlit (additive,
// full bright, drawn AddStencil in the beam's colour); the hotspot one sprite, no light; one LineTrace a tic (every 2nd tic
// on Quest). Dust (PCVR, High) is particles, no actors.
// THE CONE IS A WORLD ACTOR, NEVER AN OVERLAY OF THE HAND (owner 11-05 06:02: "the flashlight hides enemy sprites when over
// them?"): in VR QuestZDoom 17.3 draws the player's HUD models after the opaque scene and before the translucent pass
// (hw_drawinfo.cpp: DrawPlayerSprites ahead of RenderTranslucent when RenderPlayerSpritesInScene) with depth writes on and
// their depth squeezed into the near 0.3 (hw_models.cpp BeginDrawHUDModel), and every sprite is drawn in that translucent
// pass (hw_drawlistadd.cpp AddSprite), so a beam drawn with the hand (11-05 01:15 to 06:02) hid every monster behind it. An
// AddStencil actor is drawn in the translucent pass itself, sorted, with no depth writes. Its lag (owner 11-05 00:43: "The
// flashlight cone lags") is met by moving it a tic ahead each tic: the engine draws it between where it was (Prev, set to
// the lens now) and where it is (one tic on), so it sits on the hand instead of a tic behind.
//
// THE OTHER MODS, BY NAME:
//   RSQ Tactical Rig: the clip hangs on its body ("body.yaw"); while the off hand is in one of its places the grip is the
//     rig's. A holster of the rig's can take and put back the flashlight with the network events "rsqff_fl_take" /
//     "rsqff_fl_back", and ask "torch.phase" (RSQFF_TorchService, below), as its flare holster does with the flare.
//   DarkDoomz (Caligari87): "DarkDoomz Flashlight Stands Down" (on): while ours is on, a DarkDoomZ_Spotlight following you
//     is switched off the way its own key does it: its own item is used once (UseInventory on DarkDoomZ_Flashlight). Its
//     lights and item are never deleted; nothing here breaks without it.
//
// NETPLAY, the series' way: the hands are read on the console player's machine; take, put back and the switch travel as
// network events. The beam follows each player's synced hand on every machine.

class RSQFF_Torch : Weapon
{
	const GLOW = 7312;       // the overlay layer of the glowing lens

	Default
	{
		Weapon.SelectionOrder 99999;
		Weapon.AmmoUse 0;
		Weapon.Kickback 0;
		Tag "Flashlight";
		Inventory.Icon "WRITORCH";   // drawn for the series (Wheel/sources/icons/gen_item_icons.py; owner 2026-11-05)
		+WEAPON.OFFHANDWEAPON
		+WEAPON.NOAUTOFIRE +WEAPON.NOALERT +WEAPON.NOAUTOSWITCHTO +WEAPON.CHEATNOTWEAPON +WEAPON.WIMPY_WEAPON
		+WEAPON.NO_AUTO_SWITCH
		+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE
	}

	// QFFT A in the hand, C no hand drawn (Show Hand off); D the glowing lens, an overlay drawn full bright while it is on
	action void A_RSQFFTorchReady()
	{
		A_WeaponReady(WRF_NOFIRE);
		if (!player || !player.mo) return;
		let psp = player.FindPSprite(PSP_OFFHANDWEAPON);
		if (!psp || player.OffhandWeapon != invoker) return;
		let hc = CVar.GetCVar("rsqff_hand", player);
		bool hand = !hc || hc.GetBool();
		psp.Frame = hand ? 0 : 2;
		int n = player.mo.PlayerNumber();
		bool on = RSQFF_Torches.IsOn(n);
		let gl = player.FindPSprite(GLOW);
		if (on && !gl) A_Overlay(GLOW, "Glow");
		else if (!on && gl) player.SetPSprite(GLOW, null);
	}

	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	Select:
		QFFT A 1 A_Raise(24);
		Loop;
	Deselect:
		QFFT A 1 A_Lower(24);
		Loop;
	Ready:
		QFFT A 1 A_RSQFFTorchReady;
		Loop;
	Fire:
		QFFT A 1;
		Goto Ready;
	Glow:
		QFFT D 1 Bright;
		Loop;
	Frames:
		QFFT BC 0;
		Stop;
	}
}

// the beam's one light: a spot light at the lens, turned to the beam each tic
class RSQFF_TorchSpot : SpotLight
{
	Default
	{
		+DYNAMICLIGHT.NOSHADOWMAP
		+DYNAMICLIGHT.ATTENUATE
	}
}

// the visible beam: tools/gen_torch.py's cone (along model +Z), turned by pitch + 90, its frame the length (A-Z, 1/26 steps),
// QFFC the Quest cone, QFFK the two-layer one. AddStencil: drawn in the translucent pass with no depth writes, so it never
// hides a monster behind it (11-05 06:02)
class RSQFF_TorchCone : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP +NOTELEPORT
		RenderStyle "AddStencil";
		Alpha 0.3;
		RenderRadius 1024;
		Radius 1; Height 1;
	}
	States
	{
	Spawn:
		QFFC A -1 Bright;
		Stop;
	Frames:
		QFFC ABCDEFGHIJKLMNOPQRSTUVWXYZ 0 Bright;
		QFFK ABCDEFGHIJKLMNOPQRSTUVWXYZ 0 Bright;
		Stop;
	}
}

// where the beam lands: one soft sprite, no light
class RSQFF_TorchHot : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +DONTSPLASH +NOTONAUTOMAP +NOTELEPORT +FORCEXYBILLBOARD
		RenderStyle "AddStencil";
		Alpha 0.5;
		Radius 1; Height 1;
	}
	States
	{
	Spawn:
		QFFS A -1 Bright;
		Stop;
	}
}

class RSQFF_Torches : EventHandler
{
	// the lens and the beam's axis of torch_h.md3, md3 cm in the hand mesh's space (tools/gen_torch.py prints them)
	const LENS_X = 15.15;
	const LENS_Y = 1.70;
	const LENS_Z = 3.73;
	const AX_X = 0.933;
	const AX_Y = -0.250;
	const AX_Z = 0.259;
	const T_NONE = 0;
	const T_OFF = 1;
	const T_ON = 2;
	const RANDOM_COL = 98;

	// ---- synced ----
	int phase[MAXPLAYERS];
	bool resume[MAXPLAYERS];          // put away by something else while on: comes back on
	String prevOff[MAXPLAYERS];
	int pick[MAXPLAYERS];             // the colour picked at the last switch-on (Random)
	bool gripDown[MAXPLAYERS];
	int ddzWait[MAXPLAYERS];
	RSQFF_TorchSpot spot[MAXPLAYERS];
	RSQFF_TorchCone cone[MAXPLAYERS];
	RSQFF_TorchHot hot[MAXPLAYERS];
	Vector3 lastLens[MAXPLAYERS];     // the lens a tic ago (the cone is moved a tic ahead of the hand)
	bool lastLensOk[MAXPLAYERS];
	double hitDist[MAXPLAYERS];       // map units along the beam to what it meets (0: nothing in reach)
	Vector3 hitPos[MAXPLAYERS], hitNorm[MAXPLAYERS];
	int traceAt[MAXPLAYERS];
	int offKeyTic[MAXPLAYERS];        // when a key bound to +oh_attack last went down with the flashlight out (InputProcess)
	int lightsPeak;

	// ---- the console player's hands (local) ----
	private transient bool gripPrev, trigPrev, bodyPrimed;
	private transient int waitUntil, offKeySeen;
	private transient double myBodyYaw;

	static RSQFF_Torches Get() { return RSQFF_Torches(EventHandler.Find("RSQFF_Torches")); }
	static bool FlOn() { let c = CVar.FindCVar("rsqff_fl_on"); return !c || c.GetBool(); }
	static int SInt(String n, int d) { let c = CVar.FindCVar(n); return c ? c.GetInt() : d; }
	static double LNum(String n, double d) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : d; }
	static bool Debug(PlayerInfo p) { let c = CVar.GetCVar("rsqff_debug", p); return c && c.GetBool(); }

	static bool IsOn(int n)
	{
		let h = Get();
		return h && n >= 0 && n < MAXPLAYERS && h.phase[n] == T_ON;
	}

	// ---------------------------------------------------------------- the settings
	// Beam Size: the spot's inner and outer angles (the cone is drawn at the half-way angle)
	static void SizeAngles(out double inner, out double outer)
	{
		int s = clamp(SInt("rsqff_fl_size", 1), 0, 2);
		if (s == 0) { inner = 6; outer = 14; }
		else if (s == 1) { inner = 10; outer = 22; }
		else { inner = 16; outer = 32; }
	}
	// Beam Quality: Quest / PCVR / High -- the light's range, the cone, its brightness, dust, the trace's rate
	static int Quality() { return clamp(SInt("rsqff_fl_quality", 0), 0, 2); }
	static int Range() { int q = Quality(); return q == 0 ? 448 : (q == 1 ? 640 : 896); }

	// the series' palette (VisualRewards tools/gen_dn_art.py PALETTE) and a warm white, the default
	static Color Shade(int c)
	{
		static const int pal[] = {
			0xFFFFFF, 0xB3BDD1, 0xFFEB38, 0xFFBD2E, 0xFF7A14, 0xFF291A, 0xDB0A42, 0xFF80C2, 0xFF2EF2,
			0xC299FF, 0x943DFF, 0x3D66FF, 0x70C2FF, 0x14F2FF, 0x14CCA3, 0x33FF4D, 0xB8FF24 };
		if (c >= 0 && c <= 16) return Color(255, (pal[c] >> 16) & 255, (pal[c] >> 8) & 255, pal[c] & 255);
		return Color(255, 255, 220, 168);   // 20: Warm White
	}

	// ---------------------------------------------------------------- events
	// THE SWITCH AS A KEY TOO (RSQ Tactical Rig cig.zs, the Zippo's trigger): a tap shorter than a tic never reaches the
	// command's button (rig, 11-03: a press 3 tics after a frame stall was missed), so the key going down counts as well.
	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown) return false;
		if (consoleplayer < 0 || consoleplayer >= MAXPLAYERS || phase[consoleplayer] == T_NONE) return false;
		String b = Bindings.GetBinding(e.KeyScan);
		if (b.MakeLower().IndexOf("+oh_attack") >= 0) EventHandler.SendNetworkEvent("rsqff_fl_key");
		return false;
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		int n = e.Player;
		if (n < 0 || n >= MAXPLAYERS || !playeringame[n]) return;
		let pmo = players[n].mo;
		if (!pmo) return;
		if (e.Name == "rsqff_grip") { gripDown[n] = e.Args[0] != 0; return; }
		if (e.Name == "rsqff_fl_key") { offKeyTic[n] = level.maptime; return; }
		if (e.Name == "rsqff_fl_take") { Take(pmo, n); return; }
		if (e.Name == "rsqff_fl_back") { Back(pmo, n); return; }
		if (e.Name == "rsqff_fl_toggle") { SetOn(pmo, n, phase[n] != T_ON); return; }
	}

	private void Take(PlayerPawn pmo, int n)
	{
		let p = pmo.player;
		if (phase[n] != T_NONE || pmo.health <= 0 || !FlOn()) return;
		let fh = RSQFF_Handler.Get();
		if (fh && fh.phase[n] != 0) { if (Debug(p)) Console.Printf("RSQFF torch t%d: the off hand holds a flare", level.maptime); return; }
		let cur = p.OffhandWeapon;
		prevOff[n] = (cur && !(cur is "RSQFF_Torch") && !(cur is "RSQFF_Held")) ? String.Format("%s", cur.GetClassName()) : "";
		let w = Weapon(pmo.FindInventory("RSQFF_Torch"));
		if (!w) { pmo.GiveInventory("RSQFF_Torch", 1); w = Weapon(pmo.FindInventory("RSQFF_Torch")); }
		if (!w) return;
		RSQFF_Handler.RaiseOff(p, w);
		phase[n] = T_OFF;
		pmo.A_StartSound("rsqff/take", CHAN_AUTO, CHANF_LOCAL, 0.5);
		RSQFF_Buzzer.Start(pmo, 1, 0.25, 3);
		if (Debug(p)) Console.Printf("RSQFF torch take t%d: the flashlight in the off hand (had %s)", level.maptime, prevOff[n] == "" ? "nothing" : prevOff[n]);
		SetOn(pmo, n, true);
	}

	private void Back(PlayerPawn pmo, int n)
	{
		if (phase[n] == T_NONE) return;
		phase[n] = T_NONE;
		resume[n] = false;
		LightsOff(n);
		OffBack(pmo, n);
		pmo.A_StartSound("rsqff/take", CHAN_AUTO, CHANF_LOCAL, 0.5);
		if (Debug(pmo.player)) Console.Printf("RSQFF torch back t%d: on the clip again", level.maptime);
	}

	private void SetOn(PlayerPawn pmo, int n, bool on)
	{
		if (phase[n] == T_NONE) return;
		phase[n] = on ? T_ON : T_OFF;
		if (on && SInt("rsqff_fl_color", 20) == RANDOM_COL) pick[n] = random[rsqff_torch](0, 16);
		if (!on) LightsOff(n);
		traceAt[n] = 0;
		pmo.A_StartSound("rsqff/click", CHAN_AUTO, CHANF_LOCAL, 0.6);
		RSQFF_Buzzer.Start(pmo, 1, 0.15, 2);
		if (Debug(pmo.player))
		{
			double i, o; SizeAngles(i, o);
			Console.Printf("RSQFF torch t%d: %s (size %d: %.0f/%.0f deg, quality %d: range %d, colour %d)", level.maptime, on ? "on" : "off",
				SInt("rsqff_fl_size", 1), i, o, Quality(), Range(), SInt("rsqff_fl_color", 20) == RANDOM_COL ? pick[n] : SInt("rsqff_fl_color", 20));
		}
	}

	// the off hand gets back what it had: that weapon, else BD22 VR's empty hands (RSQ_Hands, by name), else nothing
	private void OffBack(PlayerPawn pmo, int n)
	{
		let p = pmo.player;
		if (!(p.OffhandWeapon is "RSQFF_Torch")) { prevOff[n] = ""; return; }
		p.SetPSprite(RSQFF_Torch.GLOW, null);
		Weapon want = null;
		class<Weapon> pc = prevOff[n];
		if (pc) want = Weapon(pmo.FindInventory(pc));
		if (!want)
		{
			String hn = "RSQ_Hands";
			class<Weapon> hc = hn;
			if (hc) want = Weapon(pmo.FindInventory(hc));
		}
		prevOff[n] = "";
		if (want && want.bOffhandWeapon) { p.OffhandWeapon = null; RSQFF_Handler.RaiseOff(p, want); return; }
		p.SetPsprite(PSP_OFFHANDWEAPON, null);
		p.OffhandWeapon = null;
	}

	private void LightsOff(int n)
	{
		if (spot[n]) spot[n].Destroy();
		if (cone[n]) cone[n].Destroy();
		if (hot[n]) hot[n].Destroy();
		spot[n] = null; cone[n] = null; hot[n] = null;
		lastLensOk[n] = false;
		hitDist[n] = 0;
	}

	// ---------------------------------------------------------------- every tic
	override void WorldTick()
	{
		int live = 0;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo) { if (phase[n] != T_NONE) { phase[n] = T_NONE; LightsOff(n); } continue; }
			Keep(players[n].mo, n);
			if (spot[n]) live++;
		}
		lightsPeak = max(lightsPeak, live);
		let me = players[consoleplayer];
		if (me && me.mo && FlOn()) Hands(me.mo);
	}

	private void Keep(PlayerPawn pmo, int n)
	{
		let p = pmo.player;
		bool inHand = p.OffhandWeapon is "RSQFF_Torch";
		if (phase[n] == T_NONE)
		{
			// given the hand back (the flare's put back or thrown, and it had the flashlight before): as it was
			if (inHand && pmo.health > 0 && FlOn())
			{
				phase[n] = T_OFF;
				if (resume[n]) SetOn(pmo, n, true);
				resume[n] = false;
			}
			else if (inHand) OffBack(pmo, n);
			return;
		}
		if (!inHand || pmo.health <= 0 || !FlOn())
		{
			resume[n] = inHand ? false : phase[n] == T_ON;
			phase[n] = T_NONE;
			LightsOff(n);
			if (inHand) OffBack(pmo, n);
			if (Debug(p)) Console.Printf("RSQFF torch t%d: put away (%s)", level.maptime, !inHand ? "the off hand took something else" : "dead or switched off");
			return;
		}
		if (phase[n] == T_ON) Beam(pmo, n);
	}

	// THE BEAM: the light, the cone and the hotspot from the lens along the flashlight's axis
	private void Beam(PlayerPawn pmo, int n)
	{
		Vector3 lens, dir;
		double ps = RSQFF_Geo.Ps(pmo);
		if (RSQFF_Geo.InVR(pmo))
		{
			lens = RSQFF_Geo.HandPoint(pmo, 1, LENS_X, LENS_Y, LENS_Z);
			Vector3 b = RSQFF_Geo.HandPoint(pmo, 1, LENS_X - AX_X * 10, LENS_Y - AX_Y * 10, LENS_Z - AX_Z * 10);
			dir = lens - b;
		}
		else
		{
			lens = pmo.Vec3Angle(10, pmo.angle - 20, pmo.height * 0.6);
			dir = (cos(pmo.angle) * cos(pmo.pitch), sin(pmo.angle) * cos(pmo.pitch), -sin(pmo.pitch));
		}
		double dl = dir.Length();
		dir = dl > 0 ? dir / dl : (cos(pmo.angle), sin(pmo.angle), 0);    // map units
		double yaw = atan2(dir.y, dir.x);
		double mapPitch = -asin(clamp(dir.z, -1, 1));
		Vector3 rd = (dir.x, dir.y, dir.z * ps);
		rd /= rd.Length();                                                   // the real direction (the cone is drawn in it)
		double realPitch = -asin(clamp(rd.z, -1, 1));

		double inner, outer; SizeAngles(inner, outer);
		int q = Quality();
		int range = Range();
		int c = SInt("rsqff_fl_color", 20);
		Color col = Shade(c == RANDOM_COL ? pick[n] : c);

		// the light
		if (!spot[n]) spot[n] = RSQFF_TorchSpot(Actor.Spawn("RSQFF_TorchSpot", lens, NO_REPLACE));
		let s = spot[n];
		if (s)
		{
			s.SetOrigin(lens, true);
			s.angle = yaw;
			s.pitch = mapPitch;
			s.args[DynamicLight.LIGHT_RED] = col.r;
			s.args[DynamicLight.LIGHT_GREEN] = col.g;
			s.args[DynamicLight.LIGHT_BLUE] = col.b;
			s.args[DynamicLight.LIGHT_INTENSITY] = range;
			s.SpotInnerAngle = inner;
			s.SpotOuterAngle = outer;
		}

		// the trace: every tic (PCVR, High) or every 2nd (Quest); what the beam meets first, a wall or a monster
		int every = q == 0 ? 2 : 1;
		if (traceAt[n] <= level.maptime)
		{
			traceAt[n] = level.maptime + every;
			Trace(pmo, n, lens, yaw, mapPitch, range * 2.5);
		}

		// the cone, a tic ahead: Pos = the lens plus its last tic's move, Prev = the lens now, so the engine's interpolation
		// (Prev -> Pos over the tic) draws it where the hand is drawn, not a tic behind (owner 11-05 00:43: "The flashlight
		// cone lags"). A jump (a teleport, a new level) is not carried ahead.
		Vector3 ahead = lens;
		if (lastLensOk[n])
		{
			Vector3 mv = lens - lastLens[n];
			if (mv.Length() < 24) ahead = lens + mv;
		}
		lastLens[n] = lens;
		lastLensOk[n] = true;
		double half = (inner + outer) * 0.5;
		if (!cone[n]) cone[n] = RSQFF_TorchCone(Actor.Spawn("RSQFF_TorchCone", lens, NO_REPLACE));
		let k = cone[n];
		if (k)
		{
			k.SetOrigin(ahead, true);
			k.Prev = lens;
			k.angle = yaw;
			k.pitch = 90 + realPitch;
			double len = range;
			if (hitDist[n] > 0)
			{
				Vector3 h = hitPos[n] - lens;
				len = min(range, (h.x, h.y, h.z * ps).Length());
			}
			int fr = clamp(int(ceil(len / range * 26)) - 1, 0, 25);
			k.sprite = k.GetSpriteIndex(q == 0 ? 'QFFC' : 'QFFK');
			k.frame = fr;
			k.Scale.Y = range / 64.0;                          // the full length (the frame folds it shorter)
			k.Scale.X = k.Scale.Y * tan(half) / tan(20.0);     // across: the same stretch, at the beam's own angle
			k.SetShade(col);
			k.alpha = q == 0 ? 0.30 : (q == 1 ? 0.34 : 0.38);
			// dust: motes drifting in the beam (PCVR one every 3rd tic, High one a tic)
			if (q > 0 && (q == 2 || level.maptime % 3 == 0)) Dust(pmo, lens, rd, len, half, col, ps);
		}

		// the hotspot where it lands: sized by the distance, fainter on a glancing wall; it reaches past the light (to 2.5 x its
		// range, fading from 1 x), so a far wall still shows where the beam lands for no light
		if (hitDist[n] > 0)
		{
			if (!hot[n]) hot[n] = RSQFF_TorchHot(Actor.Spawn("RSQFF_TorchHot", hitPos[n], NO_REPLACE));
			let t = hot[n];
			if (t)
			{
				double d = hitDist[n];
				t.SetOrigin(hitPos[n] - dir * 2, true);
				double r = d * tan(outer) * 0.75;
				t.Scale.X = t.Scale.Y = clamp(r / 32.0, 0.08, 6.0);
				double face = abs(dir dot hitNorm[n]);
				double fade = d <= range ? 1.0 : clamp(1.0 - (d - range) / (1.5 * range), 0.0, 1.0);   // the hotspot reaches past the light
				t.alpha = (0.25 + 0.45 * face) * fade * (d < 24 ? d / 24.0 : 1.0);
				t.SetShade(col);
				t.bInvisible = t.alpha <= 0.01;
			}
		}
		else if (hot[n]) hot[n].bInvisible = true;

		// DarkDoomz's flashlight stands down while ours is on
		if (SInt("rsqff_fl_ddz", 1) > 0 && level.maptime >= ddzWait[n] && level.maptime % 10 == 0) StandDown(pmo, n);
	}

	private void Trace(PlayerPawn pmo, int n, Vector3 lens, double yaw, double pitch, double dist)
	{
		// from the pawn (a trace never hits its own shooter), started at the lens
		Vector3 d = lens - pmo.pos;
		double fwd = d.x * cos(yaw) + d.y * sin(yaw);
		double side = d.x * sin(yaw) - d.y * cos(yaw);
		FLineTraceData t;
		pmo.LineTrace(yaw, dist, pitch, TRF_SOLIDACTORS, d.z, fwd, side, t);
		if (t.HitType == TRACE_HitNone) { hitDist[n] = 0; return; }
		hitDist[n] = t.Distance;
		hitPos[n] = t.HitLocation;
		Vector3 nm = (0, 0, 1);
		if (t.HitType == TRACE_HitWall && t.HitLine)
		{
			Vector2 ld = t.HitLine.delta;
			nm = (ld.y, -ld.x, 0);
			double l = nm.Length();
			nm = l > 0 ? nm / l : (1, 0, 0);
		}
		else if (t.HitType == TRACE_HitCeiling) nm = (0, 0, -1);
		else if (t.HitType == TRACE_HitActor) nm = -(cos(yaw), sin(yaw), 0);
		hitNorm[n] = nm;
	}

	private void Dust(Actor k, Vector3 lens, Vector3 rd, double len, double half, Color col, double ps)
	{
		double t = frandom[rsqff_torch](0.08, 0.85) * len;
		double r = t * tan(half) * frandom[rsqff_torch](0.0, 0.8);
		double a = frandom[rsqff_torch](0, 360);
		// a direction across the beam
		Vector3 u = (abs(rd.z) < 0.9) ? (-rd.y, rd.x, 0) : (1, 0, 0);
		u /= u.Length();
		Vector3 w = (rd.y * u.z - rd.z * u.y, rd.z * u.x - rd.x * u.z, rd.x * u.y - rd.y * u.x);
		Vector3 p = rd * t + (u * cos(a) + w * sin(a)) * r;
		p.z /= ps;     // back to map units
		p += lens - k.pos;   // from the lens (k: the pawn, the particle's spawner)
		int rgb = (col.r << 16) | (col.g << 8) | col.b;
		k.A_SpawnParticle(rgb, SPF_FULLBRIGHT, random[rsqff_torch](24, 40), frandom[rsqff_torch](1.2, 2.4), 0,
			p.x, p.y, p.z, frandom[rsqff_torch](-0.08, 0.08), frandom[rsqff_torch](-0.08, 0.08), frandom[rsqff_torch](-0.04, 0.06),
			0, 0, 0, 0.55, -1);
	}

	private void StandDown(PlayerPawn pmo, int n)
	{
		String snm = "DarkDoomZ_Spotlight";
		class<Actor> sc = snm;
		if (!sc) { ddzWait[n] = level.maptime + 350; return; }     // no DarkDoomz loaded
		let it = ThinkerIterator.Create(sc);
		Actor a;
		bool found = false;
		while (a = Actor(it.Next())) if (a.Distance3D(pmo) < 160) { found = true; break; }
		if (!found) return;
		String inm = "DarkDoomZ_Flashlight";
		class<Inventory> ic = inm;
		let item = ic ? pmo.FindInventory(ic) : null;
		ddzWait[n] = level.maptime + 35;
		if (!item) return;
		pmo.UseInventory(item);
		if (Debug(pmo.player)) Console.Printf("RSQFF torch t%d: DarkDoomz's flashlight was on: switched off with its own item", level.maptime);
	}

	// ---------------------------------------------------------------- the console player's hands
	private void Hands(PlayerPawn pmo)
	{
		let p = pmo.player;
		int n = consoleplayer;
		bool grip = gripDown[n];
		bool gripEdge = grip && !gripPrev;
		gripPrev = grip;
		// the command's button OR the original command's (RSQ Tactical Rig cig.zs: BD22 VR's own off hand can clear it from cmd)
		bool trig = ((p.cmd.buttons | p.original_cmd.buttons) & BT_OFFHANDATTACK) != 0;
		bool trigEdge = trig && !trigPrev;
		trigPrev = trig;
		bool offKey = offKeyTic[n] != offKeySeen && offKeyTic[n] >= level.maptime - 1;
		offKeySeen = offKeyTic[n];
		if (offKey && !trigEdge && trig) offKey = false;      // the command already holds it: the same press
		trigEdge = trigEdge || offKey;
		if (!RSQFF_Geo.InVR(pmo) || pmo.health <= 0) return;
		if (level.maptime < waitUntil) return;
		if (!gripEdge && !trigEdge) return;
		bool dbg = Debug(p);
		Vector3 cp = Clip(pmo, BodyYaw(pmo));
		double d = RSQFF_Geo.Metres(pmo, RSQFF_Geo.Pos(pmo, 1) - cp);
		double reach = clamp(LNum("rsqff_fl_clip_r", 0.12), 0.04, 0.4);
		bool rig = RigHasHand(pmo);
		bool atClip = d <= reach && !rig;
		if (phase[n] == T_NONE)
		{
			if (gripEdge && atClip) { Send("rsqff_fl_take"); Wait(6); }
			else if (gripEdge && dbg) Console.Printf("RSQFF torch grip t%d: off hand %.2f m from the clip (needs %.2f)%s", level.maptime, d, reach, rig ? ", in a Tactical Rig place" : "");
			return;
		}
		if (gripEdge && atClip) { Send("rsqff_fl_back"); Wait(6); return; }
		if (trigEdge) { Send("rsqff_fl_toggle"); Wait(3); }
	}

	private void Send(String nm) { EventHandler.SendNetworkEvent(nm); }
	private void Wait(int tics) { waitUntil = level.maptime + tics; }

	// THE CLIP: on the chest, on the OFF hand's own side (the flare pocket's mirror), hung from the neck and turned by the
	// body's yaw, as the pocket is (RSQFF_Geo.Pocket)
	static Vector3 Clip(PlayerPawn pmo, double bodyYaw)
	{
		double f = LNum("rsqff_fl_clip_f", 0.10);
		double l = LNum("rsqff_fl_clip_l", 0.17);
		double u = LNum("rsqff_fl_clip_u", -0.22);
		double left = RSQFF_Geo.LeftHanded() ? -l : l;      // toward the off hand: the left for a right-handed player
		Vector3 neck = RSQFF_Geo.FromEyes(pmo, -0.10, 0.10);
		double vu = RSQFF_Geo.Vu();
		f += 0.10; u += 0.10;
		Vector2 fw = (cos(bodyYaw), sin(bodyYaw)), lf = (-sin(bodyYaw), cos(bodyYaw));
		Vector2 xy = (fw * f + lf * left) * vu;
		return neck + (xy.x, xy.y, u * vu / RSQFF_Geo.Ps(pmo));
	}

	private bool RigHasHand(PlayerPawn pmo)
	{
		let it = ServiceIterator.Find("RSQTR_RigService");
		Service s;
		while (s = it.Next()) if (s.GetInt("rig.region", "", 1, 0, pmo) >= 0) return true;
		return false;
	}

	// the body's yaw: RSQ Tactical Rig's when it is loaded, else our own (RSQFF_Handler.BodyYaw's way)
	private double BodyYaw(PlayerPawn pmo)
	{
		let it = ServiceIterator.Find("RSQTR_BodyService");
		Service s;
		while (s = it.Next())
		{
			double y = s.GetDouble("body.yaw", "", 0, 0, pmo);
			if (y != 999) return y;
		}
		if (!bodyPrimed) { myBodyYaw = pmo.angle; bodyPrimed = true; }
		if (pmo.pitch < 20) myBodyYaw += Actor.DeltaAngle(myBodyYaw, pmo.angle) * 0.04;
		return myBodyYaw;
	}
	// THE YAW THE CLIP IS DRAWN AT (stowed.zs, Show Flashlight): the body BodyYaw last gave for the console player (no easing
	// step here); another player's: the rig's body when it is loaded, else where he faces
	double ShownYaw(PlayerPawn pmo)
	{
		let it = ServiceIterator.Find("RSQTR_BodyService");
		Service s;
		while (s = it.Next())
		{
			double y = s.GetDouble("body.yaw", "", 0, 0, pmo);
			if (y != 999) return y;
		}
		return (pmo.player == players[consoleplayer] && bodyPrimed) ? myBodyYaw : pmo.angle;
	}
}

// WHAT THE FLASHLIGHT IS DOING, FOR ANY MOD THAT ASKS BY NAME (a holster of RSQ Tactical Rig's). intArg: the player.
//   GetInt("torch.phase", "", player)   0 on the clip, 1 in the off hand and off, 2 in the hand and on (-1: Flashlight off)
// To take it or put it back, send FnF's network events "rsqff_fl_take" / "rsqff_fl_back" (what a grip at the clip does).
class RSQFF_TorchService : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request != "torch.phase") return -1;
		if (intArg < 0 || intArg >= MAXPLAYERS || !playeringame[intArg]) return -1;
		let h = RSQFF_Torches.Get();
		if (!h || !RSQFF_Torches.FlOn()) return -1;
		return h.phase[intArg];
	}
}
