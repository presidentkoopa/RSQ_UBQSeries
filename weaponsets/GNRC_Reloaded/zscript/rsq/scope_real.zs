// RS VR scopes, REAL mode: the view down the bore, rendered into the scope's own glass.
//
// The companion to rsq/scope.zs. That file owns the per-gun table and the collimated DOT;
// this one owns the picture through the glass: 3x in REAL mode, 1x under the dot in DOT mode
// (1.99x r6; before that DOT had no picture and the glass was opaque).
//
// HOW IT WORKS
//   An invisible actor (RSQ_ScopeCam) is parked each tic at the lens, pointing down the bore,
//   and TexMan.SetCameraToTexture binds it to a camera texture declared in ANIMDEFS.rsq. The
//   glass surface's skin is then swapped to that texture with A_ChangeModel /
//   CMDL_USESURFACESKIN, which is why the glass has to be its OWN MD3 surface: the RailGun's
//   mesh already carried one, the Ruger's ocular disc was carved into one by the kit
//   (kit/tool/md3_carve_surface.py).
//
// ALWAYS ON WHILE HELD (2.0, owner 2026-10-28: "the real-time scope renders 3x at all times")
//   A camera texture is a SECOND SCENE RENDER of the level (256x256, mono), every frame it is
//   drawn (hw_entrypoint.cpp, "prepare all camera textures that have been used in the last
//   frame"; binding it for a draw calls FCanvasTexture::NeedUpdate). Until 2.0 the skin swap was
//   gated on an eye being within 12 cm behind the eyepiece, to spend that render only while
//   sighting. The owner asked for the picture at all times, so the swap is now on for as long
//   as a scoped gun is the ready weapon in VR, and off (zero cost) the moment it is not.
//   2.0 scope-toggle (owner 01:55, "for performance"): ALT FIRE turns it off and on again
//   (scopeOff below); on whenever the gun is selected. The
//   magnification still follows the eye nearer the bore line (FovFor), so it is 3x from
//   wherever the lens is seen. Cost on the rig: HANDOFF "scope-3x".
//
// ONE EYE, ON PURPOSE
//   RenderViewpoint is called from the camera-texture loop with mainview and toscreen both
//   false, so GetVRMode(mainview && toscreen) hands back the MONO mode and the texture is
//   rendered ONCE, not once per eye. Both eyes therefore see the same flat image with no
//   stereo disparity. That is the right answer for a scope and not a limitation worked around:
//   a real telescopic sight is monocular and its image is at infinity. It also means the cost
//   is one extra render, not two.
//
//   The image is also one frame stale, because camera textures are rendered before the main
//   view. At 72 Hz that is 14 ms of lag on the picture inside the tube while the tube itself
//   is current. Nothing can be done about that from script.
//
// LOCAL PLAYER, SINGLE PLAYER
//   Everything here is driven by where the headset is, which only the local machine knows, and
//   it spawns an actor and writes modelData. Doing that for one player on one machine is fine
//   on its own but is not something to start in a netgame, so -- like the VR hand poses
//   (rsq/hands.zs) -- the whole feature is off when multiplayer is set. The mode cvar is still
//   read per player with CVar.GetCVar so that rule never depends on a local FindCVar.

class RSQ_ScopeReal : EventHandler
{
	// WHICH SURFACE THE GLASS IS: RSQ_ScopeTable.GlassSurface (2.0: moved into the table, so one
	// table holds every per-gun number). Kept here as a forwarder for older callers.
	static int GlassSurface(int i)
	{
		return RSQ_ScopeTable.GlassSurface(i);
	}

	// The camera texture, declared in ANIMDEFS.rsq. Eight characters, because
	// ParseCameraTexture looks the name up with TEXMAN_ShortNameOnly and a longer one would
	// never be found again.
	//
	// ONE constant, and a String. A second one as a Name is "Bad type for constant
	// definiton": a ZScript const takes int, float, double, string or bool and nothing
	// else, so a name literal is refused outright. A_ChangeModel wants a Name and takes
	// this String by the implicit conversion -- which also means the two spellings can
	// never drift apart.
	const TEXNAME = "RSQSCOPE";

	// The eye distance FovFor uses when neither eye is behind the glass (the lens seen from in
	// front or edge-on): about where an eye sits at the eyepiece (rig: 8 cm). ALONG_MAX caps it
	// for an eye far off the gun, where the lens is a few pixels wide anyway.
	const ALONG_NOMINAL = 8.0;
	const ALONG_MAX = 40.0;
	// Which way a positive camera roll turns the picture against the up vector's lean to the
	// camera's right. Set from the rig (HANDOFF scope-3x: level picture with the hand rolled 30).
	const ROLL_SIGN = 1.0;

	// 2.0 scope-toggle: alt fire turns the live scope off and on (RSQ_ScopeTable.AltToggle).
	// Off = the glass's own skin and the camera texture drawn nowhere, so the engine renders
	// nothing extra (the cost is zero, rig: HANDOFF scope-toggle). ON whenever a scoped gun is
	// selected; the state is kept for as long as that gun stays the ready weapon.
	bool scopeOff;
	bool altWas;		// alt fire held last tic (our own copy: player.oldbuttons is already this
						// tic's by the time WorldTick runs, so it never shows the press; rig)
	const SND_ON = "ads/in";		// BD22's own aim sounds, the ones its zoom played
	const SND_OFF = "ads/out";

	RSQ_ScopeCam cam;
	int lastIndex;			// the gun the swap is currently applied to, 0 = none
	int lastSurface;
	Weapon lastWeapon;
	bool skinOn;

	// ---------------------------------------------------------------- the hand this tic
	// Identical chain to rsvr/melee.zs Frame(): the gun is a psprite and has no world
	// position, so the only way to land on a point of the drawn model is to redo the
	// transform the renderer used (models.cpp RenderHUDModel).
	private Vector3 fH;
	private Vector3 fF;
	private Vector3 fR;
	private Vector3 fU;
	private double ps;
	private double vu;
	private double ox;
	private double oy;
	private double oz;

	private static double CVarF(Name n, double def)
	{
		let cv = CVar.FindCVar(n);
		return cv ? cv.GetFloat() : def;
	}

	private bool Frame(PlayerPawn mo)
	{
		if (!RSVR_VRHand.InVR(mo))
			return false;
		ps = mo.Level.pixelstretch;
		if (ps <= 0)
			ps = 1.2;
		fH = RSVR_VRHand.HandPos(mo);
		fF = RSVR_VRHand.HandDir(mo, 0, 0, ps);
		fR = -RSVR_VRHand.HandDir(mo, 90, 0, ps);
		fU = RSVR_VRHand.HandDir(mo, 0, 90, ps);
		vu = CVarF('vr_vunits_per_meter', 34);
		if (vu <= 0)
			vu = 34;
		ox = CVarF('vr_3dweaponOffsetX', 0);
		oy = CVarF('vr_3dweaponOffsetY', 0);
		oz = CVarF('vr_3dweaponOffsetZ', 0);
		return true;
	}

	// A point given in the table's own units -- centimetres in the controller frame, F forward,
	// L left, U up -- placed in the world.
	//
	// melee.zs Place() takes MODEL units and does the Scale / Offset / ZOffset / (0,5,30) /
	// vr_weaponScale arithmetic itself. RSQ_ScopeTable's numbers were measured AFTER all of
	// that (rgeo.py walks the same chain), so the only part left to redo here is the tail: the
	// 0.01 scale, the player's own weapon-offset cvars, the squash and the hand basis. Written
	// out against melee.zs Place(), with F = ws*m.x - 30 - Offset.y and so on already folded
	// into the table:
	//     f = 0.01 * (ws*m.x - 30 - oz - Offset.y)  ->  0.01 * (F - oz)
	//     r = 0.01 * (-ws*m.y + ox)                 ->  0.01 * (ox - L)
	//     u = 0.01 * (ws*m.z + oy + ZOffset + 5)    ->  0.01 * (U + oy)
	// so the two agree exactly at the vr_3dweaponOffset defaults, and still track the player's
	// offsets when they are not default. A vr_weaponScale other than the 1.02 the table was
	// measured at is the one thing it cannot follow; that is the table's limit, not this code's.
	private Vector3 Place(Vector3 flu)
	{
		Vector3 w = fF * (0.01 * (flu.x - oz))
			+ fR * (0.01 * (ox - flu.y))
			+ fU * (0.01 * (flu.z + oy));
		w.z /= ps;
		return fH + w * vu;
	}

	// Where an eye is, in the same frame, in centimetres. The eye itself is RSQ_Scope.EyeWorld
	// (scope.zs): the headset's real height and either eye's IPD offset, the way the renderer
	// places it. Here the real hand basis is already in hand.
	private Vector3 EyeFLU(PlayerPawn mo, int side)
	{
		Vector3 d = RSQ_Scope.EyeWorld(mo, side) - mo.AttackPos;
		d.z *= ps;					// undo the squash Place applies
		double k = 100.0 / vu;		// map units -> cm
		return ((d dot fF) * k, -(d dot fR) * k, (d dot fU) * k);
	}

	// How far behind the glass the sighting eye is, cm, for the magnification. The sighting eye is
	// the one nearer the bore line (smaller angle off the axis), the same choice the collimated
	// dot makes (RSQ_Scope.DotAt). Both eyes are tested (each is vr_ipd/2 off the head centre).
	double eyeAlong;
	private double SightAlong(PlayerPawn mo, int i)
	{
		Vector3 P = RSQ_ScopeTable.Lens(i);
		Vector3 A = RSQ_ScopeTable.Axis(i);
		double al = A.Length();
		if (al <= 0)
			return ALONG_NOMINAL;
		A = A / al;
		double best = -1, bestRatio = 1e9;
		for (int side = -1; side <= 1; side += 2)
		{
			Vector3 toLens = P - EyeFLU(mo, side);
			double along = toLens dot A;		// > 0: the glass is in front of the eye
			if (along <= 0)
				continue;
			double ratio = (toLens - A * along).Length() / along;
			if (ratio < bestRatio)
			{
				bestRatio = ratio;
				best = along;
			}
		}
		return best > 0 ? best : ALONG_NOMINAL;
	}

	// THE MAGNIFICATION. A camera texture is rendered mono (RenderViewpoint with mainview
	// false), and VREyeInfo::GetProjection (hw_vrmodes.cpp:343) builds it with
	// fovy = 2*atan(tan(fov/2)/ratio) at aspect ratio, so the fov handed to SetCameraToTexture
	// is the HORIZONTAL field across the texture -- and the glass is UV-mapped 0..1 across its
	// disc, so that is the field across the lens. The lens subtends 2*atan(r/along) at the eye;
	// a mag-times sight shows 1/mag of that angle of the world across it.
	static double FovFor(double r, double along, double mag)
	{
		along = clamp(along, 3.0, ALONG_MAX);
		return 2.0 * atan((r / along) / max(mag, 1.0));
	}

	// ---------------------------------------------------------------- the skin
	// A_ChangeModel is an Actor action function, so it is called on the weapon the way the
	// engine's own script calls A_Explode on a puff. From outside a psprite state and without
	// CMDL_WEAPONTOPLAYER it writes the INVOKER's modelData (p_actionfunctions.cpp), which is
	// the weapon -- and RenderHUDModel reads psp->Caller's modelData, so that is exactly the
	// one the drawn gun uses. Passing no skin name stores a null texture id, which
	// CalcModelOverrides treats as "fall through to the MODELDEF SurfaceSkin": that is the way
	// back to the ordinary glass.
	private void SetSkin(Weapon w, int surface, bool on)
	{
		if (!w || surface < 0)
			return;
		// Every argument but the surface skin is deliberately 'None' / "":
		//   modeldef 'None'  leaves modelData->modelDef null, so FindModelFrame keeps looking
		//                    the gun up by its own class exactly as it does untouched;
		//   model    'None'  leaves the override modelID at -1, which CalcModelOverrides reads
		//                    as "no override" and falls through to the MODELDEF mesh -- NOT as
		//                    hide, which is -2 and only comes from CMDL_HIDEMODEL;
		//   skin     'None'  stores a null texture id, which the same function treats as "fall
		//                    through to the MODELDEF SurfaceSkin". That is the way back.
		w.A_ChangeModel('None', 0, "", 'None', surface, "",
			on ? Name(TEXNAME) : Name("None"), CMDL_USESURFACESKIN);
	}

	private void ClearSkin()
	{
		if (skinOn && lastWeapon)
			SetSkin(lastWeapon, lastSurface, false);
		skinOn = false;
	}

	private void Shutdown()
	{
		ClearSkin();
		if (cam)
			cam.Destroy();
		cam = null;
		lastWeapon = null;
		lastIndex = 0;
		lastSurface = -1;
	}

	// ---------------------------------------------------------------- the tic
	override void WorldLoaded(WorldEvent e)
	{
		// the camera was an actor of the old level and the swap was on the old level's weapon
		cam = null;
		skinOn = false;
		lastWeapon = null;
		lastIndex = 0;
		lastSurface = -1;
		scopeOff = false;
	}

	override void WorldTick()
	{
		// Driven by the headset, writes render state on one machine, and spawns an actor:
		// none of that is a thing to switch on in a netgame. Same gate the hand poses use.
		if (multiplayer)
		{
			Shutdown();
			return;
		}
		if (consoleplayer < 0 || !playeringame[consoleplayer] || !players[consoleplayer].mo)
		{
			Shutdown();
			return;
		}
		let mo = players[consoleplayer].mo;

		let w = mo.player.ReadyWeapon;
		int i = RSQ_ScopeTable.Index(w);
		int surface = GlassSurface(i);

		// out of VR nothing here does anything at all
		if (i <= 0 || surface < 0 || !Frame(mo))
		{
			Shutdown();
			return;
		}

		// 0 = dot, 1 = real. Read per player, never FindCVar, so a netgame cannot disagree
		// about which mode a gun is in. A cvar that does not exist yet reads as dot.
		// 1.99x r6: BOTH modes render the view down the bore; they differ in magnification.
		// 2.0: REAL is the default (CVARINFO.rsq rsq_scope2_*), and either mode is always on.
		//   1 REAL  the scope's own magnification (RSQ_ScopeTable.Mag, 3x).
		//   0 DOT   1x, with the collimated red dot over it (rsq/hands.zs). The glass cannot
		//           simply be made clear for this: behind the ocular is the inside of the tube
		//           and the objective's own cap, never the world. A 1x picture through the
		//           glass IS the see-through lens, at the same one-extra-render cost.
		let cv = CVar.GetCVar(RSQ_ScopeTable.ModeCVar(i), mo.player);
		double mag = (cv && cv.GetInt() == 1) ? RSQ_ScopeTable.Mag(i) : 1.0;

		// the gun changed under us: take the swap off the one that had it
		if (w != lastWeapon || i != lastIndex)
		{
			ClearSkin();
			lastWeapon = w;
			lastIndex = i;
			lastSurface = surface;
			scopeOff = false;		// a scoped gun is always selected with its scope on
		}

		// Alt fire toggles, on the press (the button's rising edge, so holding it does nothing more).
		// Read off the button and not off a state, so it works whatever state the gun is in.
		bool alt = (mo.player.cmd.buttons & BT_ALTATTACK) != 0;
		bool press = alt && !altWas;
		altWas = alt;
		if (RSQ_ScopeTable.AltToggle(i) && press)
		{
			scopeOff = !scopeOff;
			mo.A_StartSound(scopeOff ? SND_OFF : SND_ON, CHAN_AUTO, CHANF_LOCAL);
		}
		if (scopeOff)
		{
			ClearSkin();		// plain glass; RSQSCOPE drawn nowhere -> not rendered
			return;
		}

		// 2.0: no eye gate. The picture is up for as long as the gun is held (see the header).
		eyeAlong = SightAlong(mo, i);

		Vector3 lens = Place(RSQ_ScopeTable.Lens(i));
		// Down the bore, as the difference of two placed points rather than a rotated vector:
		// the squash in Place is not a rotation, so a direction has to be transformed the same
		// way a displacement is or it drifts off axis with pitch.
		Vector3 A = RSQ_ScopeTable.Axis(i);
		double al = A.Length();
		if (al <= 0)
			return;
		Vector3 ahead = Place(RSQ_ScopeTable.Lens(i) + A * (10.0 / al));
		Vector3 d = ahead - lens;
		double dl = d.Length();
		if (dl <= 0)
			return;
		d = d / dl;

		if (!cam)
		{
			cam = RSQ_ScopeCam(Actor.Spawn('RSQ_ScopeCam', lens, NO_REPLACE));
			if (!cam)
				return;
		}
		cam.SetOrigin(lens, true);
		cam.angle = VectorAngle(d.x, d.y);
		cam.pitch = -asin(clamp(d.z, -1, 1));
		// 1.99x r6: 180, not 0. The glass UVs (kit md3_carve_surface.py --project-uv) put the
		// texture's origin in the opposite corner, so a roll-0 picture showed in the lens
		// upside down AND mirrored (rig frames, HANDOFF r6-scope): a 180 degree rotation.
		// 2.0 scope-3x: PLUS the glass's own roll. The picture is glued to the glass, so the
		// camera must roll exactly as the glass does or the world shows tilted in the lens:
		// the gun's roll in the hand (RSQ_ScopeTable.Up, about 11 degrees since the r9 port) and
		// the hand's own roll (AttackRoll, carried by Place). Up is placed like the bore.
		// Measured in RENDER space, not map space: the view matrix scales map z by pixelstretch
		// BEFORE it applies roll (hw_drawinfo.cpp SetViewMatrix), while angle and pitch are
		// converted by the engine (r_utility.cpp:1229). Map space overshot by about 2 degrees
		// at the guns' 11 degree tilt (rig, HANDOFF scope-3x).
		Vector3 up = Place(RSQ_ScopeTable.Lens(i) + RSQ_ScopeTable.Up(i) * 10.0) - lens;
		up.z *= ps;
		Vector3 dr = (d.x, d.y, d.z * ps);
		dr = dr / dr.Length();
		up = up - dr * (up dot dr);
		Vector3 r0 = (sin(cam.angle), -cos(cam.angle), 0);	// the camera's right at roll 0
		Vector3 u0 = r0 cross dr;								// and its up
		double glassRoll = (up.Length() > 0) ? atan2(up dot r0, up dot u0) : 0;
		cam.roll = 180 + ROLL_SIGN * glassRoll;

		double fov = FovFor(RSQ_ScopeTable.Radius(i), eyeAlong, mag);
		TexMan.SetCameraToTexture(cam, TEXNAME, fov);

		if (!skinOn)
		{
			SetSkin(w, surface, true);
			skinOn = true;
		}
	}
}

// The viewpoint the scope renders from. Invisible, inert, and never in anything's way --
// but it keeps its sector links, because the renderer needs a subsector for a viewpoint.
class RSQ_ScopeCam : Actor
{
	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+NOCLIP
		+NOTONAUTOMAP
		+DONTSPLASH
		RenderStyle "None";
		Radius 1;
		Height 1;
	}
	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}
}
