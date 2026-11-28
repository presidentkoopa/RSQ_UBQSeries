// TEST ONLY (2026-11-08): do the ModelSwapper set meshes survive firing and the mod's own reload?
// Overlay handler for the ModelSwapper rig (real QuestZDoom 17.3, OpenXR path). tools/rig/msrig_run.py
// builds the overlay and runs doom2 -> the mod -> the MS set -> this, on MAP01, god.
//
// For each class in msrig_guns (comma list): give + select, wait, hold the right trigger (+attack)
// 45 tics, wait, hold BT_RELOAD 8 tics (written into the usercmd each tic: the rig has no reload
// button), wait for the reload to play out. Every tic the WEAPON layer is read:
//   psp.Sprite      what the renderer will look up (ModelSwapper pins it to its model's anchor sprite)
//   psp.CurState    the mod's own state (its sprite is the 2D gun; if psp.Sprite == that, the MESH IS GONE)
// A line is printed whenever (Sprite, Frame, state sprite) changes, tagged MSRIG, with the phase.
// At the end of each gun: tics with the mesh, tics without, and which phase lost it.
class MSRIG_Test : EventHandler
{
	Array<String> guns;
	int gi;			// index of the gun under test
	int t0;			// tic the gun was given
	int phase;		// 0 select 1 idle 2 fire 3 settle 4 reload 5 settle
	int lastSpr, lastFrm, lastStSpr, lastStFrm;
	State lastState;
	int stateChanges;	// distinct state entries seen in FIRE + RELOAD: proof the mod's animation ran
	int withMesh, without, lostIn;
	String lostPhases;
	bool done;

	static String Cls(Object o) { return o ? String.Format("%s", o.GetClassName()) : "none"; }
	static void Cv(Name n, double v) { let c = CVar.FindCVar(n); if (c) c.SetFloat(v); }
	static String Ph(int p)
	{
		static const String names[] = { "select", "idle", "FIRE", "settle", "RELOAD", "after" };
		return names[clamp(p, 0, 5)];
	}
	void Say(String s) { Console.Printf("MSRIG t%d %s", level.maptime, s); }

	override void WorldTick()
	{
		if (!playeringame[0] || !players[0].mo || done) return;
		let mo = PlayerPawn(players[0].mo);
		let p = mo.player;
		int t = level.maptime;
		if (t == 70)
		{
			let c = CVar.FindCVar('msrig_guns');
			String s = c ? c.GetString() : "";
			guns.Clear();
			s.Split(guns, ",");
			Say(String.Format("%d guns: %s", guns.Size(), s));
			gi = -1; t0 = 0;
		}
		if (t < 70) return;

		// next gun
		if (gi < 0 || t - t0 >= 420)
		{
			if (gi >= 0)
			{
				let w = p.ReadyWeapon;
				Say(String.Format("RESULT %s: mesh %d tics, NO MESH %d tics%s | %d state changes in fire+reload | ammo1 now %d ammo2 %d", guns[gi], withMesh, without,
					without > 0 ? " -- lost in: " .. lostPhases : "", stateChanges, w && w.Ammo1 ? w.Ammo1.Amount : -1, w && w.Ammo2 ? w.Ammo2.Amount : -1));
			}
			gi++;
			if (gi >= guns.Size()) { Say("ALL DONE"); done = true; return; }
			t0 = t; phase = 0; withMesh = 0; without = 0; lostPhases = ""; lastSpr = -9; lastFrm = -9; lastStSpr = -9; lastStFrm = -9; stateChanges = 0; lastState = null;
			String g = guns[gi];
			Class<Inventory> wc = g;
			if (!wc) { Say(String.Format("GUN %s: NO SUCH CLASS", g)); t0 = t - 400; return; }
			mo.GiveInventory(wc, 1);
			let w = Weapon(mo.FindInventory(wc));
			if (w)
			{
				p.PendingWeapon = w;
				// fill both ammo types so firing and reloading are possible
				if (w.Ammo1) w.Ammo1.Amount = w.Ammo1.MaxAmount;
				if (w.Ammo2) w.Ammo2.Amount = w.Ammo2.MaxAmount;
				Say(String.Format("GUN %s given, selecting (ammo1 %s %d, ammo2 %s %d)", g,
					Cls(w.Ammo1), w.Ammo1 ? w.Ammo1.Amount : 0, Cls(w.Ammo2), w.Ammo2 ? w.Ammo2.Amount : 0));
			}
			else
				Say(String.Format("GUN %s: not a weapon in inventory after give", g));
		}
		int dt = t - t0;
		let psp = p.FindPSprite(PSP_WEAPON);
		int ph = dt < 120 ? 0 : dt < 150 ? 1 : dt < 195 ? 2 : dt < 260 ? 3 : dt < 268 ? 4 : 5;
		if (ph != phase) { phase = ph; Say(String.Format("  phase %s (ready=%s)", Ph(ph), Cls(p.ReadyWeapon))); }
		if (ph == 4) p.cmd.buttons |= BT_RELOAD;
		if ((ph == 2 || ph == 4) && (dt % 10) == 5)
		{
			let w = p.ReadyWeapon;
			Say(String.Format("  %s buttons=0x%x attackdown=%d ammo1=%d ammo2=%d state=%s", Ph(ph), p.cmd.buttons, p.attackdown,
				w && w.Ammo1 ? w.Ammo1.Amount : -1, w && w.Ammo2 ? w.Ammo2.Amount : -1, psp && psp.CurState ? String.Format("tics %d", psp.CurState.Tics) : "none"));
		}
		// the buttons
		Cv('qzt_rtrigger', ph == 2 ? 1 : 0);
		if (ph == 4) p.cmd.buttons |= BT_RELOAD;	// the mod's own reload (its Ready has WRF_ALLOWRELOAD)

		if (!psp || !psp.CurState) return;
		int spr = psp.Sprite, frm = psp.Frame, sspr = psp.CurState.sprite, sfrm = psp.CurState.Frame;
		if (psp.CurState != lastState) { lastState = psp.CurState; if (ph == 2 || ph == 4 || ph == 5) stateChanges++; }
		bool mesh = spr != sspr;			// pinned to a model anchor, not the mod's 2D sprite
		if (ph >= 1) { if (mesh) withMesh++; else { without++; if (lostPhases.IndexOf(Ph(ph)) < 0) lostPhases = lostPhases .. Ph(ph) .. " "; } }
		if (spr != lastSpr || frm != lastFrm || sspr != lastStSpr || sfrm != lastStFrm)
		{
			lastStFrm = sfrm;
			// a sprite index has no name in ZScript; the mod's 2D sprite index is printed so the
			// offline reader can see when psp.Sprite collapses onto it
			Say(String.Format("  %s psp.Sprite=%d frame=%d | state sprite=%d.%d tics=%d | %s", Ph(ph), spr, frm, sspr, sfrm, psp.CurState.Tics,
				mesh ? "mesh" : "** 2D SPRITE: mesh gone **"));
			lastSpr = spr; lastFrm = frm; lastStSpr = sspr;
		}
	}
}
