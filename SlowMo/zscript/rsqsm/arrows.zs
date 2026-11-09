// RSQ_SlowMo -- EDGE ARROWS FOR OTHER MODS (2026-11-09, the Bossfight rework's shared contract; design/MINIBOSS_REWORK.md
// "The arrival": "HUD arrows point to them when the landing is not in view (DOWN's edge arrows: SlowMo needs a service for
// another mod to ask for them)"). RSQSM_Service GetInt("arrow.add", key, rgb, size, actor) / GetInt("arrow.clear", key, 0,
// 0, actor) (clock.zs) land here.
// THE LIST is synced play data (the service is called from synced play code on every machine): key, actor, colour, size.
// An entry goes on arrow.clear, when its actor dies or is gone, and with the map (a new map builds a new handler; WorldLoaded
// clears it too). THE VIEW (which arrows are up, their eased direction, their frame clock) is the console player's own,
// worked out every tic the plate's way (plate.zs: the >75 degree rule, the gaze eased a fifth of the way a tic, straight
// behind = at the bottom, pointing down) and kept transient: it never touches the game.
// THE LOOK is DOWN's edge arrows exactly (downhud.zs EdgeArrow: the Turn Marker row rsqsm_down_marker, its baked momentum
// frames, Panel Size), in the caller's colour, no icon slot; size 1.0 = DOWN's, 1.5 the miniboss's (it grows outward).
// Photosensitive Mode: the first frame, held still (as DOWN's). HUD layer, RenderOverlay, every piece its own quad: no clip
// rectangle, no Screen.Dim (VR).
// WITH DOWN: while the console player is DOWN these are NOT drawn: DOWN's own arrows (his targets, his life) have the ring
// to themselves; the list is kept, and they come back when he is up.
class RSQSM_Arrow play
{
	String akey;               // the caller's key
	Actor mon;
	int rgb;
	double size;
	transient bool up;          // the console player's view: more than 75 degrees off, its arrow up
	transient int upTic;        // when it came up (its frame clock)
	transient double dirAng;    // its direction on the screen (degrees, 0 right, 90 up), round the eased gaze
}

class RSQSM_Arrows : EventHandler
{
	const OFF_DEG = 75.0;       // plate.zs TRAIL_DEG: farther than this from the view, the edge arrow
	const MAX_ARROWS = 32;      // a runaway caller cannot fill the HUD (my number)

	Array<RSQSM_Arrow> arrows;  // synced (in the save)

	transient double gYaw, gPitch;   // the console player's eased gaze (plate.zs: a fifth of the way a tic)
	transient bool gSet;
	transient ui RSQSM_DownHud hud;

	static RSQSM_Arrows Get() { return RSQSM_Arrows(EventHandler.Find("RSQSM_Arrows")); }

	// ---- the service (synced play code) -------------------------------------------------------------------------------
	// arrow.add: a new arrow, or the same key on the same actor recoloured / resized in place. 1 done, 0 no living actor
	// or the list full.
	int AddArrow(String k, Actor m, int rgb, double size)
	{
		if (!m || m.health <= 0) return 0;
		rgb &= 0xFFFFFF;
		size = size > 0 ? clamp(size, 0.5, 2.0) : 1.0;
		for (int i = 0; i < arrows.Size(); i++)
		{
			let r = arrows[i];
			if (r && r.mon == m && r.akey ~== k) { r.rgb = rgb; r.size = size; return 1; }
		}
		if (arrows.Size() >= MAX_ARROWS) return 0;
		let nr = RSQSM_Arrow(new("RSQSM_Arrow"));
		nr.akey = k; nr.mon = m; nr.rgb = rgb; nr.size = size;
		arrows.Push(nr);
		return 1;
	}
	// arrow.clear: the arrows with this key on this actor (no actor: every arrow with this key). Always 1.
	int ClearArrows(String k, Actor m)
	{
		for (int i = arrows.Size() - 1; i >= 0; i--)
		{
			let r = arrows[i];
			if (!r || (r.akey ~== k && (!m || r.mon == m))) arrows.Delete(i);
		}
		return 1;
	}

	override void WorldLoaded(WorldEvent e)
	{
		gSet = false;
		if (!e.IsSaveGame) arrows.Clear();
	}
	override void WorldUnloaded(WorldEvent e) { arrows.Clear(); }

	override void WorldTick()
	{
		// the dead and the gone leave (synced data only: the same on every machine)
		for (int i = arrows.Size() - 1; i >= 0; i--)
		{
			let r = arrows[i];
			if (!r || !r.mon || r.mon.health <= 0) arrows.Delete(i);
		}
		// the console player's view (transient: never touches the game)
		int cp = consoleplayer;
		if (!playeringame[cp] || !players[cp].mo) { gSet = false; return; }
		let pmo = players[cp].mo;
		if (!gSet) { gYaw = pmo.angle; gPitch = pmo.pitch; gSet = true; }
		gYaw += Actor.deltaangle(gYaw, pmo.angle) * 0.2;
		gPitch += (pmo.pitch - gPitch) * 0.2;
		if (arrows.Size() == 0) return;
		Vector3 gaze = (cos(pmo.angle) * cos(pmo.pitch), sin(pmo.angle) * cos(pmo.pitch), -sin(pmo.pitch));
		for (int i = 0; i < arrows.Size(); i++)
		{
			let r = arrows[i];
			Vector3 to = pmo.Vec3To(r.mon) + (0, 0, r.mon.height * 0.5 - players[cp].viewheight);
			double dist = to.Length();
			if (dist < 1.0) { r.up = false; continue; }
			Vector3 dir = to / dist;
			double off = acos(clamp(dir dot gaze, -1.0, 1.0));
			bool want = off > OFF_DEG;
			if (want && !r.up) r.upTic = level.maptime;
			r.up = want;
			if (want) r.dirAng = EdgeAng(dir);
		}
	}
	// plate.zs Edge: the way to turn, on the screen, round the EASED gaze; straight behind: at the bottom, pointing down
	double EdgeAng(Vector3 dir)
	{
		double gp = -gPitch;
		Vector3 gr = (sin(gYaw), -cos(gYaw), 0);
		Vector3 gu = (-cos(gYaw) * sin(gp), -sin(gYaw) * sin(gp), cos(gp));
		double xr = dir dot gr, yu = dir dot gu;
		bool behind = abs(Actor.deltaangle(gYaw, atan2(dir.y, dir.x))) > 150.0;
		if (behind || (abs(xr) < 0.001 && abs(yu) < 0.001)) return -90;
		return atan2(yu, xr);
	}

	// ---- the HUD (downhud.zs's gating and art) ------------------------------------------------------------------------
	override void RenderOverlay(RenderEvent e)
	{
		if (arrows.Size() == 0 || gamestate != GS_LEVEL || screenblocks > 11 || automapactive) return;
		int cp = consoleplayer;
		if (!playeringame[cp] || !players[cp].mo) return;
		let d = RSQSM_Down(EventHandler.Find("RSQSM_Down"));
		if (d && d.IsDown(cp)) return;      // DOWN's own arrows have the ring to themselves
		if (!hud) hud = new("RSQSM_DownHud");
		hud.EdgeSetup(cp);
		for (int i = 0; i < arrows.Size(); i++)
		{
			let r = arrows[i];
			if (!r || !r.mon || !r.up) continue;
			hud.EdgeArrow(r.dirAng, RSQSM_DownHud.EdgeFrame(r.upTic), r.rgb, r.size, -1);
		}
	}
}
