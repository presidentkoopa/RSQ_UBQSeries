// wr_q_watch.zs -- RSQ Wheel: the wrist card. Check your watch and the gun in that hand tells you
// about itself.
//
// THE GESTURE IS THE ONE EVERYBODY ALREADY MAKES: the forearm brought up across the chest, the
// wrist in front of the face, the hand pointing across the body. Held there for wr_watch_dwell
// tics (and only while the ring is closed), a card stands over that wrist, facing the eye:
// the gun's name in its tier colour, rounds in it and in reserve, and -- once it has been fired
// -- kills and hit rate from the ring's own tracker, plus its Gun Bonsai level when that mod is
// loaded. Lower the arm and it folds away.
//
// Geometric rather than a roll angle on purpose: which way a controller reports roll for "palm
// up" is the runtime's business, while "wrist in front of the face, hand across the body" is
// the same on every headset. wr_watch 0 turns it off.

class wr_Watch : EventHandler
{
	const ROWS = 4;

	int  mHand;          // the hand showing a card, -1 none
	int  mDwell[2];
	int  mGroup;
	int  mPlate, mAccent, mTitle;
	int  mRow[ROWS];
	Weapon mShown;
	int  mBuiltTic;

	static wr_Watch Get() { return wr_Watch(EventHandler.Find("wr_Watch")); }

	override void OnRegister() { mHand = -1; }

	private static double cv(string n, double f) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : f; }

	// Is this hand in the watch pose?
	private bool watching(PlayerPawn pmo, int h)
	{
		if (!pmo.OverrideAttackPosDir) return false;
		Vector3 eye = (pmo.pos.xy, pmo.player.viewz);
		Vector3 hp = wr_Rig.handPos(pmo, h);
		// true proportions: the engine shortens a hand's height above or below the eye by
		// level.pixelstretch (wr_Rig.trueDelta), and this test is in real centimetres
		Vector3 to = wr_Rig.trueDelta(hp - eye);
		double d = to.Length();
		// within forearm's reach of the face: 15-50 cm (34 units a metre)
		if (d < 5 || d > 17) return false;
		// in front of the eyes, within 35 degrees of where the head points
		Vector3 look = (cos(pmo.angle) * cos(pmo.pitch), sin(pmo.angle) * cos(pmo.pitch), -sin(pmo.pitch));
		if ((to / d) dot look < cos(35)) return false;
		// and the hand pointing across the body, not ahead: more than 55 degrees off the view
		Vector3 hd = wr_Rig.handDir(pmo, h);
		if (hd.xy dot (cos(pmo.angle), sin(pmo.angle)) > cos(55)) return false;
		return true;
	}

	override void WorldTick()
	{
		let pmo = PlayerPawn(players[consoleplayer].mo);
		if (!pmo || players[consoleplayer].playerstate != PST_LIVE) { hide(); return; }
		// RSQ Gun Cards' watch card replaces this one when that mod is loaded and its watch card is on
		let gcw = CVar.FindCVar("rsqgc_watch");
		if (gcw && gcw.GetInt() > 0) { hide(); return; }
		let rig = wr_Rig.Get();
		bool ringUp = rig && rig.IsOpen();
		int dwell = int(cv("wr_watch_dwell", 8));
		for (int h = 0; h < 2; h++)
		{
			if (CVar.FindCVar("wr_watch") && CVar.FindCVar("wr_watch").GetBool() && !ringUp && watching(pmo, h)) mDwell[h]++;
			else mDwell[h] = 0;
		}
		int want = -1;
		if (mHand >= 0 && mDwell[mHand] > 0) want = mHand;            // the hand showing keeps it
		else if (mDwell[0] >= dwell) want = 0;
		else if (mDwell[1] >= dwell) want = 1;
		if (want < 0) { hide(); return; }

		Weapon w = (want == 1) ? pmo.player.OffhandWeapon : pmo.player.ReadyWeapon;
		if (mHand != want || !mGroup) show(pmo, want);
		if (w != mShown || level.maptime - mBuiltTic >= 10) fill(pmo, w);
		place(pmo, want);
	}

	private void show(PlayerPawn pmo, int h)
	{
		hide();
		mHand = h;
		Vector3 at = wr_Rig.handPos(pmo, h);
		mGroup  = wr_BB.AddBillboardGroup(at);
		mPlate  = wr_BB.AddBillboardPersistent(at, 9, 6.4, 0, 0, wr_BB.BBF_CAMERA, wr_BB.BB_PANEL, 0, 0x2E3440, wr_BB.BBFL_NOHIT);
		mAccent = wr_BB.AddBillboardPersistent(at, 8.4, 0.35, 0, 0, wr_BB.BBF_CAMERA, wr_BB.BB_PANEL, 0, 0x8D93A3, wr_BB.BBFL_NOHIT);
		mTitle  = wr_BB.AddBillboardPersistent(at, 8, 1.1, 0, 0, wr_BB.BBF_CAMERA, wr_BB.BB_TEXT, 0, 0xE8EAF0, wr_BB.BBFL_NOHIT, 0, "");
		for (int i = 0; i < ROWS; i++)
			mRow[i] = wr_BB.AddBillboardPersistent(at, 8, 0.75, 0, 0, wr_BB.BBF_CAMERA, wr_BB.BB_TEXT, 0, 0x8D93A3, wr_BB.BBFL_NOHIT, 0, "");
		wr_BB.SetBillboardGroup(mPlate, mGroup); wr_BB.SetBillboardGroup(mAccent, mGroup); wr_BB.SetBillboardGroup(mTitle, mGroup);
		for (int i = 0; i < ROWS; i++) wr_BB.SetBillboardGroup(mRow[i], mGroup);
		wr_BB.AnimateBillboardGroup(mGroup, 0.0, 1.0, 6);
		mShown = null;
		mBuiltTic = -100;
		wr_VR.VRHaptic(h, 0.18, 25);
	}

	private void hide()
	{
		if (!mGroup) { mHand = -1; return; }
		wr_BB.RemoveBillboard(mPlate); wr_BB.RemoveBillboard(mAccent); wr_BB.RemoveBillboard(mTitle);
		for (int i = 0; i < ROWS; i++) wr_BB.RemoveBillboard(mRow[i]);
		wr_BB.RemoveBillboardGroup(mGroup);
		mGroup = 0; mHand = -1; mShown = null;
	}

	private void fill(PlayerPawn pmo, Weapon w)
	{
		mShown = w;
		mBuiltTic = level.maptime;
		Array<string> txt;
		Array<int> tcol;
		if (!w)
		{
			wr_BB.SetBillboardText(mTitle, "EMPTY HAND");
		}
		else
		{
			wr_BB.SetBillboardText(mTitle, w.GetTag());
			// rounds: the magazine if the set has one, else what the ammo pool holds
			int mag = (w.Ammo2 && w.Ammo1 && w.Ammo2 != w.Ammo1) ? w.Ammo2.Amount : -1;
			if (w.Ammo1)
			{
				if (mag >= 0) txt.Push(String.Format("ROUNDS %d  RESERVE %d", mag, w.Ammo1.Amount));
				else txt.Push(String.Format("AMMO %d / %d", w.Ammo1.Amount, w.Ammo1.MaxAmount));
				tcol.Push(w.Ammo1.Amount > 0 ? 0xE8EAF0 : 0xC65C5C);
			}
			bool found; int kills, shots, hits;
			[found, kills, shots, hits] = wr_StatTracker.BasicsOf(w);
			if (found)
			{
				txt.Push(String.Format("KILLS %d  HITS %d%%", kills, shots > 0 ? hits * 100 / shots : 0));
				tcol.Push(0x5DCAA5);
			}
			let it = ServiceIterator.Find("RSQ_MeleeUpgradeService");
			Service svc;
			while (svc = it.Next())
			{
				int lv = svc.GetInt("weapon.level", "", 0, 0, w);
				if (lv < 0) continue;
				txt.Push(String.Format("BONSAI LV %d  %d%%", lv, clamp(svc.GetInt("weapon.xp", "", 0, 0, w) / 10, 0, 100)));
				tcol.Push(0x70D060);
				break;
			}
		}
		for (int i = 0; i < ROWS; i++)
		{
			wr_BB.SetBillboardText(mRow[i], i < txt.Size() ? txt[i] : "");
			if (i < txt.Size()) wr_BB.UpdateBillboard(mRow[i], 0, tcol[i]);
		}
	}

	// Over the wrist, nudged toward the eye so the forearm does not cut it, title on top.
	private void place(PlayerPawn pmo, int h)
	{
		Vector3 eye = (pmo.pos.xy, pmo.player.viewz);
		Vector3 hp = wr_Rig.handPos(pmo, h);
		Vector3 toEye = (eye - hp).Unit();
		double sc0 = cv("wr_watch_scale", 0.6);
		// high enough over the wrist to clear a held gun, and a little toward the eye
		Vector3 c = hp + (0, 0, 8.0 * sc0) + toEye * 3.0;
		wr_BB.SetBillboardGroupOrigin(mGroup, c);
		double sc = sc0;
		wr_BB.MoveBillboard(mPlate, c);
		wr_BB.ResizeBillboard(mPlate, 9 * sc, 6.4 * sc);
		// Lifted off the plate toward the eye as far as the ring lifts its own words (LABEL_LIFT 0.6):
		// at the 0.05 / 0.08 this card had, the plate drew over its words and the card came up blank.
		wr_BB.MoveBillboard(mAccent, c + (0, 0, 2.45 * sc) + toEye * 0.6);
		wr_BB.ResizeBillboard(mAccent, 8.4 * sc, 0.35 * sc);
		wr_BB.MoveBillboard(mTitle, c + (0, 0, 1.6 * sc) + toEye * 0.6);
		wr_BB.ResizeBillboard(mTitle, 8 * sc, 1.1 * sc);
		for (int i = 0; i < ROWS; i++)
		{
			wr_BB.MoveBillboard(mRow[i], c + (0, 0, (0.3 - i * 1.0) * sc) + toEye * 0.6);
			wr_BB.ResizeBillboard(mRow[i], 8 * sc, 0.75 * sc);
		}
	}

	override void WorldUnloaded(WorldEvent e) { mGroup = 0; mHand = -1; mShown = null; }
}
