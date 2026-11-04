// RSQG_HandSync -- the hands where the last FRAME put them, carried to where the BODY is now (tools/handsync/
// handsync_template.zs, one copy per mod under its own prefix, written by tools/handsync/gen_handsync.sh; the same
// fix as BD22 VR Reloaded 2.0.3s rsvr/vrhand.zs RSVR_HandSync). Every mod still loads and plays alone.
//
// THE FLAW IT FIXES (owner 2026-11-03 18:50: "strafing left and right causes the melee 'whoosh' sound to play";
// 18:58: "axe in my offhand, start moving forward and I'm hearing this swoosh sound constantly").
// QuestZDoom writes AttackPos / OffhandPos only while it RENDERS a frame (hw_openxrdevice.cpp:593-608): X/Y are the
// pawn's X/Y at that frame minus the controller's offset, Z is the frame's interpolated eye
// (r_viewpoint.CenterEyePos.Z) plus the controller's height. When two tics run with no frame between them -- any
// frame slower than a tic: a heavy load order, a hitch, the desktop test -- the second tic still holds the first
// frame's numbers while the pawn has walked on, so a hand read against the body jumps back by a whole step and
// forward again on the next frame (walking: 4.75 map units a tic each way). And the eye the frame drew from is
// interpolated, so on a stair, a landing or a lift the hand's height against the body wobbles by up to a tic of
// the view's motion. Both measured on the rig 2026-11-03 (BD22 VR's axe whooshed and cut while walking, the saber
// whooshed). Rig only, not headset-confirmed.
//
// THE FIX, two layers:
//  1. EXACT, per frame (RSQ Whip's climb and lash already do this, input.zs / whip.zs): the machine with the hands
//     measures each FRAME the controller against that same frame's pawn (flat) and that frame's eye
//     (RenderEvent.ViewPos, height) -- the controller's own offset, with nothing of the body's motion in it -- and
//     sends it when it changes. The last one before a tic is the one the tic uses. Body() + that offset is the hand.
//  2. Without a fresh one (menus, the first tics, a renderer that never calls RenderOverlay): the play-side estimate.
//     The world ticks (p_tick.cpp:168-173) run the players' input, then WorldTick, then the movers, and an item's
//     DoEffect runs inside its owner's Tick before the owner moves (p_mobj.cpp:4011 before :4344), so at the first
//     look in a tic the pawn still stands where the last frame drew it. If the hand field changed since the last
//     look a frame came in between and the pawn's position now is that frame's body; if not, the old body stands.
//
// Body(): THE BODY A SWING IS MEASURED FROM -- the pawn's X/Y and the VIEW's height. The hands hang off the view,
// and the engine moves the view against the pawn by itself (a step up lifts the pawn 8 units at once and the view
// follows over several tics; landing squats it), so a still hand read against the feet drops 8 units on a stair.
//
// USE: Fix(pmo, raw, ctrl) on a hand position read from the field ctrl (0 AttackPos, 1 OffhandPos) in PLAY code
// (a DoEffect, a WorldTick, a weapon state); anything else (a fallback, a probe's hand) comes back as it went in.
// Never in ui code: in a RenderOverlay the field is the frame's own and already right.
class RSQG_HandSync : StaticEventHandler
{
	const FRESH = 10;								// tics a per-frame offset stands without a newer one (no frames: a hitch)
	const RESEND = 2;								// an unchanged offset is sent again this often, so it stays fresh
	Vector3 off0[MAXPLAYERS], off1[MAXPLAYERS];		// layer 1: the controllers' offsets from the body, per frame
	int offAt[MAXPLAYERS];							// maptime + 1 they last arrived, 0 = never
	Vector3 raw0[MAXPLAYERS], raw1[MAXPLAYERS];		// layer 2: the fields as last seen
	Vector3 bod0[MAXPLAYERS], bod1[MAXPLAYERS];		// the pawn's position when the frame that wrote them was drawn
	double vz0[MAXPLAYERS], vz1[MAXPLAYERS];		// and the view height (viewz) it drew them from
	double vzLast[MAXPLAYERS];						// viewz at the last look
	int seen[MAXPLAYERS];							// maptime + 1 of the last look, 0 = never
	PlayerPawn who[MAXPLAYERS];
	ui int sent0, sent1, sentTic;					// the last offsets this machine sent (packed), and when
	ui bool sentAny;

	static RSQG_HandSync Get() { return RSQG_HandSync(StaticEventHandler.Find("RSQG_HandSync")); }

	override void WorldLoaded(WorldEvent e) { for (int i = 0; i < MAXPLAYERS; i++) { seen[i] = 0; offAt[i] = 0; } }

	// a look every tic, here, before anything moves the pawn
	override void WorldTick()
	{
		for (int i = 0; i < MAXPLAYERS; i++)
			if (playeringame[i] && players[i].mo)
				Look(players[i].mo);
	}

	// LAYER 1, the sender: this frame's controllers against this frame's pawn and eye
	override void RenderOverlay(RenderEvent e)
	{
		if (consoleplayer < 0 || consoleplayer >= MAXPLAYERS || !playeringame[consoleplayer]) return;
		let mo = players[consoleplayer].mo;
		if (!mo || !mo.OverrideAttackPosDir || mo.AttackPos == mo.OffhandPos) return;
		int a = Pack(mo.AttackPos - (mo.pos.x, mo.pos.y, e.ViewPos.z));
		int b = Pack(mo.OffhandPos - (mo.pos.x, mo.pos.y, e.ViewPos.z));
		if (a == 0 || b == 0) return;			// out of range: not a hand
		if (sentAny && a == sent0 && b == sent1 && level.maptime - sentTic < RESEND && level.maptime >= sentTic) return;
		sent0 = a; sent1 = b; sentAny = true; sentTic = level.maptime;
		EventHandler.SendNetworkEvent("RSQG_hs", a, b);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "RSQG_hs")) return;	// (the engine may hand the name back in another case)
		int i = e.Player;
		if (i < 0 || i >= MAXPLAYERS || !playeringame[i]) return;
		off0[i] = Unpack(e.Args[0]);
		off1[i] = Unpack(e.Args[1]);
		offAt[i] = level.maptime + 1;
	}

	// quarter units, 10 bits each plus a set bit (0 = none): +-128 every way, past any arm's reach
	static clearscope int Pack(Vector3 v)
	{
		int x = int(round(v.x * 4)), y = int(round(v.y * 4)), z = int(round(v.z * 4));
		if (abs(x) > 511 || abs(y) > 511 || abs(z) > 511) return 0;
		return (x & 0x3FF) | ((y & 0x3FF) << 10) | ((z & 0x3FF) << 20) | (1 << 30);
	}
	static clearscope Vector3 Unpack(int a)
	{
		int x = a & 0x3FF, y = (a >> 10) & 0x3FF, z = (a >> 20) & 0x3FF;
		if (x >= 512) x -= 1024;
		if (y >= 512) y -= 1024;
		if (z >= 512) z -= 1024;
		return (x / 4.0, y / 4.0, z / 4.0);
	}

	void Look(PlayerPawn mo)
	{
		if (!mo || !mo.player)
			return;
		int i = mo.PlayerNumber();
		if (i < 0 || i >= MAXPLAYERS)
			return;
		int now = mo.Level.maptime + 1;
		if (seen[i] == now && who[i] == mo)
			return;
		bool fresh = seen[i] == 0 || who[i] != mo;
		double vzFrame = fresh ? mo.player.viewz : vzLast[i];
		if (fresh || mo.AttackPos != raw0[i]) { bod0[i] = mo.pos; vz0[i] = vzFrame; }
		if (fresh || mo.OffhandPos != raw1[i]) { bod1[i] = mo.pos; vz1[i] = vzFrame; }
		raw0[i] = mo.AttackPos;
		raw1[i] = mo.OffhandPos;
		vzLast[i] = mo.player.viewz;
		seen[i] = now;
		who[i] = mo;
	}

	static Vector3 Fix(Actor a, Vector3 raw, int ctrl)
	{
		let mo = PlayerPawn(a);
		if (!mo || !mo.player || raw != (ctrl == 0 ? mo.AttackPos : mo.OffhandPos))
			return raw;
		let h = Get();
		if (!h)
			return raw;
		h.Look(mo);
		int i = mo.PlayerNumber();
		if (i < 0 || i >= MAXPLAYERS)
			return raw;
		if (h.offAt[i] > 0 && mo.Level.maptime + 1 - h.offAt[i] <= FRESH)
			return Body(mo) + (ctrl == 0 ? h.off0[i] : h.off1[i]);
		Vector3 b = ctrl == 0 ? h.bod0[i] : h.bod1[i];
		double vz = ctrl == 0 ? h.vz0[i] : h.vz1[i];
		return (raw.x + mo.pos.x - b.x, raw.y + mo.pos.y - b.y, raw.z - vz + mo.player.viewz);
	}

	static clearscope Vector3 Body(Actor a)
	{
		if (!a)
			return (0, 0, 0);
		if (!a.player)
			return a.pos;
		return (a.pos.x, a.pos.y, a.player.viewz);
	}
}
