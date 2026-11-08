// THE HOLSTER TIP: A GHOST HAND (report rec 6, "teach in context"; 11-08, rig only, not headset-confirmed).
//
// The first time you hold a gun with the Rig, a faint ghost of your hand shows how to holster it: once the main hand
// has held a gun (RSQTR_Rig.HoldsGun) for HOLD_TICS, and while rsqtr_tip_holster is false (this machine's, archived:
// no gun has ever been holstered here by hand), a translucent, fullbright copy of Brutal Doom VR's hand moves from where
// your hand is drawn to the target holster's centre and back, once every LOOP_TICS, and that holster's ring is forced
// visible. It pauses (hidden) while the main hand holds no gun, and it is gone for good the first time ANY gun goes
// into a gun holster by hand (either hand; RSQTR_Rig.NetworkProcess calls ByHand around Holster / HolsterOff).
//
// THE TARGET: the main-hand hip (Right hip; Left hip when left-handed, RSQTR_Body.LeftHanded) if it is empty and
// unassigned or assigned to this gun; else the nearest (to the main hand) empty gun holster unassigned or assigned to
// this gun; none: nothing shows. A holster the Rig would not take a gun into at all (claimed by another mod, or the
// ShieldSaw's shoulder) is not a target.
//
// THE HAND: Brutal Doom 22 VR Reloaded's own FBX hand (models/rsq/fbx/fbx_oh_free_R.md3, skin fbx_hand.png; its
// RSQ_Gunside / Melee_Attacks fist is frame 1), swapped onto a carrier by path (A_ChangeModel), as RSQTR_NadeShow takes
// BD's grenade. The Rig ships no hand of its own: without that file loaded only the target ring lights (11-08: the Rig
// stands alone).
// Its pose is the drawn hand's: RSQTR_HeldShow.Stand's solve (mirrorbody.zs: the HUD hand model's MODELDEF Scale -1 1 1
// and Offset 0 -24 -10 at the controller's pose, redone for a world actor), moved by the loop's share of the way from
// the controller to the ring's centre.
//
// LOCAL ONLY: the ghost and the ring are this machine's (as the Rig's rings and icons; a subclass of RSQTR_Marker, so a
// load clears it, ClearLocalMarks); the cvar is set only on the machine of the player who holstered.
class RSQTR_Ghost play
{
	const HOLD_TICS = 70;          // 2 s holding a gun before it first shows
	const LOOP_TICS = 52;          // one out-and-back, ~1.5 s
	const HAND_ALPHA = 0.35;
	const RING_ALPHA = 0.35;
	const HAND_PATH = "models/rsq/fbx";
	const HAND_MD3 = "models/rsq/fbx/fbx_oh_free_R.md3";
	const HAND_PNG = "models/rsq/fbx/fbx_hand.png";

	int holdT;                     // tics the main hand has held a gun, without a break
	bool armed;                    // HOLD_TICS reached: from now it shows whenever a gun is held
	bool showing;
	int phase;
	int tgt;
	int lastTic;
	int meshState;                 // 0 not looked yet, 1 there, 2 missing
	RSQTR_GhostHand hand;

	static bool Done() { let c = CVar.FindCVar("rsqtr_tip_holster"); return !c || c.GetBool(); }
	static bool Dbg(PlayerInfo p) { return RSQTR_Rig.Flag("rsqtr_messages", p, false); }

	// ---- the console player's tic (RSQTR_Rig.WorldTick, after DrawMarkers) ----------------------------------------------
	void Tick(RSQTR_Rig rig, PlayerPawn pmo, PlayerInfo p)
	{
		bool gap = lastTic > 0 && level.maptime - lastTic > 1;
		lastTic = level.maptime;
		if (gap && showing) Halt(p, "the Rig was off");
		if (Done()) { if (showing) Halt(p, "tip done"); return; }
		if (meshState == 0)
		{
			meshState = (Wads.CheckNumForFullName(HAND_MD3) >= 0 && Wads.CheckNumForFullName(HAND_PNG) >= 0) ? 1 : 2;
			if (meshState == 2 && Dbg(p))
				Console.Printf("T_GHOST t%d: no hand mesh (%s not loaded): the holster tip lights the ring only", level.maptime, HAND_MD3);
		}

		bool gun = RSQTR_Rig.HoldsGun(pmo);
		if (!gun) { holdT = 0; if (showing) Halt(p, "gun not held"); return; }
		if (!armed)
		{
			if (++holdT < HOLD_TICS) return;
			armed = true;
		}
		String cls = GunOf(pmo);
		int r = Target(rig, pmo, cls);
		if (r < 0) { if (showing) Halt(p, String.Format("no empty holster for %s", cls)); return; }
		if (!showing)
		{
			showing = true; phase = 0; tgt = r;
			if (Dbg(p)) Console.Printf("T_GHOST t%d start: %s in the main hand, ghost hand to %s (loop %d tics, alpha %.2f)",
				level.maptime, cls, RSQTR_Region.NAMES[r], LOOP_TICS, HAND_ALPHA);
		}
		else if (r != tgt)
		{
			if (Dbg(p)) Console.Printf("T_GHOST t%d target: %s -> %s (%s)", level.maptime, RSQTR_Region.NAMES[tgt], RSQTR_Region.NAMES[r], cls);
			tgt = r;
		}
		Vector3 at = rig.RegionAt(pmo, r);
		ForceRing(rig, pmo, p, r, at);

		// the loop: out to the ring and back, eased (0 at the hand, 1 at the ring's centre)
		double s = 0.5 - 0.5 * cos(phase * 360.0 / LOOP_TICS);
		Vector3 grip = RSQTR_Body.Hand(pmo, 0);
		if (meshState == 1 && !hand) hand = RSQTR_GhostHand(Actor.Spawn("RSQTR_GhostHand", grip));
		if (hand)
		{
			hand.Pose(pmo, (at - grip) * s);
			hand.liveTo = level.maptime + 1;
		}
		if (phase == LOOP_TICS / 2 && Dbg(p))
			Console.Printf("T_GHOST t%d loop: ghost hand at %s (%.3f m from the hand, ring %.3f m away)", level.maptime,
				RSQTR_Region.NAMES[r], RSQTR_Body.RoomMetres(grip + (at - grip) * s, grip), RSQTR_Body.RoomMetres(at, grip));
		phase = (phase + 1) % LOOP_TICS;
	}

	private void Halt(PlayerInfo p, String why)
	{
		showing = false;
		if (hand) hand.bINVISIBLE = true;
		if (Dbg(p)) Console.Printf("T_GHOST t%d stop: %s", level.maptime, why);
	}

	// the class the held gun goes into a holster as (RSQTR_Rig.WouldRefuse's own: Brutal Doom's two-gun weapon as one)
	static String GunOf(PlayerPawn pmo)
	{
		let w = pmo.player.ReadyWeapon;
		if (!w) return "";
		String cls = RSQTR_Rig.HeldAs(pmo, w);
		String single = RSQTR_Rig.SingleOf(pmo, cls);
		if (single != "" && single != cls) { class<Weapon> sc = single; if (sc) cls = single; }
		return cls;
	}

	static bool Fits(RSQTR_Rig rig, PlayerPawn pmo, String cls, int r)
	{
		if (!RSQTR_Rig.IsGunRegion(r) || !rig.RegionLive(pmo, r) || r == RSQTR_Hooks.ShieldHolster(pmo)) return false;
		if (rig.Content(pmo, r) != "") return false;
		String lock = rig.lockCls[pmo.PlayerNumber() * RSQTR_Region.N + r];
		return lock == "" || lock ~== cls;
	}

	static int Target(RSQTR_Rig rig, PlayerPawn pmo, String cls)
	{
		int hip = RSQTR_Body.LeftHanded() ? 0 : 1;
		if (Fits(rig, pmo, cls, hip)) return hip;
		Vector3 hp = RSQTR_Body.Hand(pmo, 0);
		int best = -1;
		double bd = 1e9;
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			if (!Fits(rig, pmo, cls, r)) continue;
			double d = RSQTR_Body.RoomMetres(hp, rig.RegionAt(pmo, r));
			if (d < bd) { bd = d; best = r; }
		}
		return best;
	}

	// the target's ring, shown at least at RING_ALPHA whatever Holster Rings says (DrawMarkers has run this tic: a ring
	// it already shows brighter, a rule's flash, is left as it is)
	private void ForceRing(RSQTR_Rig rig, PlayerPawn pmo, PlayerInfo p, int r, Vector3 at)
	{
		let m = rig.marker[r];
		if (!m) { m = Actor.Spawn("RSQTR_Marker", at); rig.marker[r] = m; }
		if (!m) return;
		if (m.bINVISIBLE)
		{
			bool inside = rig.HoverRegion(0) == r || rig.HoverRegion(1) == r;
			double sz = rig.RegionRadius(p, r) * RSQTR_Body.Upm() * (inside ? 1.15 : 1.0);
			m.frame = RSQTR_Rig.MarkerFrame(inside, RSQTR_Rig.Opt("rsqtr_profile_active", p, 1), false);
			m.Scale = (sz, sz);
			m.Alpha = RING_ALPHA;
			m.SetOrigin(at, true);
			m.bINVISIBLE = false;
		}
		else if (m.Alpha < RING_ALPHA) m.Alpha = RING_ALPHA;
	}

	// ---- a gun put in a holster by hand (RSQTR_Rig.NetworkProcess, every machine; acts on the console player's only) ----
	// What the gun holsters held before the press, so ByHand can see whether a gun went in.
	static String Snap(RSQTR_Rig rig, int n)
	{
		String s = "";
		for (int r = 0; r < RSQTR_Region.N; r++) s = s .. (RSQTR_Rig.IsGunRegion(r) ? rig.lastPut[n * RSQTR_Region.N + r] : "") .. "|";
		return s;
	}

	static void ByHand(RSQTR_Rig rig, PlayerPawn pmo, String before, bool heldGun, int h)
	{
		if (!heldGun || !pmo || pmo.player != players[consoleplayer] || Done()) return;
		Array<String> was;
		before.Split(was, "|");
		int n = pmo.PlayerNumber();
		for (int r = 0; r < RSQTR_Region.N; r++)
		{
			if (!RSQTR_Rig.IsGunRegion(r)) continue;
			String now = rig.lastPut[n * RSQTR_Region.N + r];
			String old = r < was.Size() ? was[r] : "";
			if (now == "" || now ~== old) continue;
			CVar.FindCVar("rsqtr_tip_holster").SetBool(true);
			if (Dbg(pmo.player))
				Console.Printf("T_GHOST t%d stop: holstered by hand (%s hand): %s into %s; rsqtr_tip_holster set, the tip never shows again",
					level.maptime, h ? "off" : "main", now, RSQTR_Region.NAMES[r]);
			return;
		}
	}
}

// The ghost hand itself: a carrier (the wire sphere with the invisible skin, MODELDEF RSQTR_GhostHand) that wears Brutal
// Doom VR's hand by path. Local, never in play.
class RSQTR_GhostHand : RSQTR_Marker
{
	int liveTo;                    // shown through this tic; hidden after it (the Rig off, the tip stopped)
	bool worn;
	Default
	{
		RenderStyle "Translucent";
		Alpha 0.35;
	}
	States { Spawn: RSTM A -1 Bright; Stop; }

	override void Tick()
	{
		Super.Tick();
		if (level.maptime > liveTo) bINVISIBLE = true;
	}

	// Drawn where the main hand's own model is drawn (RSQTR_HeldShow.Stand, mirrorbody.zs, with the BD hand block's Scale
	// -1 1 1 / Offset 0 -24 -10 from RSQTRLAY), then moved by `move` (map units).
	void Pose(PlayerPawn pmo, Vector3 move)
	{
		if (!worn)
		{
			worn = true;
			A_ChangeModel(GetClassName(), 0, RSQTR_Ghost.HAND_PATH, 'fbx_oh_free_R.md3', 0, RSQTR_Ghost.HAND_PATH, 'fbx_hand.png');
			SetModelFlag(MDL_USEACTORPITCH | MDL_USEACTORROLL);
		}
		Vector3 sc = (-1, 1, 1), ofs = (0, -24, -10);
		Vector3 at = pmo.AttackPos;
		double ya = pmo.AttackAngle, pi = pmo.AttackPitch, ro = -pmo.AttackRoll;
		// the left controller's model is mirrored: the main hand is the left one when left-handed
		bool rev = RSQTR_Body.LeftHanded();
		let cu = CVar.FindCVar("vr_vunits_per_meter"), cw = CVar.FindCVar("vr_weaponScale");
		double cm = (cu ? cu.GetFloat() : 34.0) * 0.01;
		double k = cm * (cw ? cw.GetFloat() : 1.0);
		Vector3 R = RSQTR_HeldShow.Turn(ya, pi, ro, (1, 0, 0)), U = RSQTR_HeldShow.Turn(ya, pi, ro, (0, 1, 0)), B = RSQTR_HeldShow.Turn(ya, pi, ro, (0, 0, 1));
		double sg = sc.x * sc.y < 0 ? -1 : 1;
		Vector3 F = B * -sg;
		Vector3 L = rev ? R * -sg : R * sg;
		Scale = (k, rev ? k : -k);
		angle = atan2(F.y, F.x);
		pitch = -asin(clamp(F.z, -1.0, 1.0));
		Vector3 F0, L0, U0;
		[F0, L0, U0] = RSQTR_Fit.Basis(angle, pitch, 0);
		roll = atan2(L dot U0, L dot L0);
		Vector3 cust = (RSQTR_HeldShow.CVarF("vr_3dweaponOffsetX"), RSQTR_HeldShow.CVarF("vr_3dweaponOffsetY"), RSQTR_HeldShow.CVarF("vr_3dweaponOffsetZ"));
		Vector3 q = (0, 5, 30) + (ofs.x, ofs.z, ofs.y) + (sc.x * -cust.x, sc.z * cust.y, sc.y * cust.z);
		if (rev) q.x = -q.x;
		Vector3 h = RSQTR_HeldShow.Turn(ya, pi, ro, q);
		h.z /= RSQTR_Body.Ps();
		Vector3 hud = at + h * cm;
		Vector3 wrl = (F * ofs.x + U * ofs.z + L * ofs.y) * k;
		SetOrigin(hud - wrl + move, true);
		Alpha = RSQTR_Ghost.HAND_ALPHA;
		bINVISIBLE = false;
	}
}
