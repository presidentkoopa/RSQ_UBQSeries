// RS VR scopes: a sight that can be put on any gun that has one in its mesh.
//
// Two modes per gun (MENUDEF.rsq -> rsq_scope2_<gun>, default REAL):
//   DOT   a collimated red dot over the view down the bore at 1x (1.99x r6: see-through).
//   REAL  the view down the bore at 3x, rendered into the scope's own glass surface.
// Both cost one extra scene render, every frame the gun is held with its scope on (2.0: on when
// selected; alt fire toggles it off, at zero cost, and on again; scope_real.zs).
//
// THE DOT IS COLLIMATED, and that is the whole point of it. A reticle painted on the glass
// has full parallax: move your head and the dot slides off what the gun is pointing at, which
// is backwards -- a real reflex sight shows the dot in the same place whatever your eye does.
// So the dot is not painted on the glass. Each rendered frame it is placed at the point D on
// the lens plane where the eye-to-dot ray runs parallel to the bore:
//
//     D = E + A * ((P - E) dot A)          E eye, A bore axis, P a point on the lens plane
//
// The dot therefore slides across the glass as the head moves and the sight picture stays
// true. It is two dot products and a scale, once per frame, in the hook the renderer already
// calls -- ModifyBobLayer3D, which is ui scope and per FRAME, not per tic. That matters: a
// dot placed from a tic-rate sample would visibly lag the head.
//
// Per gun this needs four measured numbers and nothing else (RSQ_ScopeTable), so a scope is a
// component and not a per-weapon special case. The railgun's mesh already carries its glass as
// its own surface ("ScopeGlass", 18 verts); the Ruger's ocular disc is carved out of the scope
// surface by the kit so it has one too.
//
// Everything here is inert until a gun is in the table, and out of VR nothing runs at all.
//
// WHAT THE SCOPE IS MADE OF (2.0 scope-3x; the list for lifting it out as its own mod)
//   zscript/rsq/scope.zs       RSQ_ScopeTable (ALL per-gun data: class, Lens, Axis, Up, Radius,
//                              GlassSurface, Mag, AltToggle, ModeCVar), RSQ_Scope (eye, hand basis, dot),
//                              RSQ_ScopeLayers (reticle psprite id)
//   zscript/rsq/scope_real.zs  RSQ_ScopeReal (EventHandler: camera + glass skin swap, always on
//                              while a scoped gun is held), RSQ_ScopeCam (the camera actor)
//   ANIMDEFS.rsq               cameratexture RSQSCOPE 256 256 fit 240 200
//   CVARINFO.rsq               rsq_scope2_sniper, rsq_scope2_railgun (0 dot 1x, 1 real 3x)
//   MENUDEF.rsq                OptionValue RSQ_ScopeMode + the two "... Scope" options
//   MAPINFO.rsvr               AddEventHandlers "RSQ_ScopeReal"; ZSCRIPT.rsvr includes both files
//   MODELDEF.rsq               the dot quad (RQRT A/B, models/rsq/rsq_dot.md3, RQRTA0/RQRTB0.png)
//   MODELDEF.bd.txt/.rsr       per gun: SurfaceSkin on the glass ("scope_glass.png"), no whole Skin
//   meshes                     RailGun.md3 surface 1, XM21.md3 surface 10 (glass, UV 0..1 disc)
//   each gun's AltFire state   must only swallow the press when AltToggle is on (Sniper.dec,
//                              Railgun.dec: BD22's zoom is kept there as ZoomAltFire, unreachable)
// Borrowed from the rest of the pack (a lifted copy must bring or replace these):
//   RSVR_VRHand.InVR / HandPos / HandDir (rsvr/vrhand.zs): the hand transform scope_real.zs places
//     the camera with;
//   rsq/hands.zs RSQ_GunSide: shows the dot layer (RETICLE) via RSQ_Scope.DotAt; RSQ_Layers.Taken.

class RSQ_ScopeLayers abstract
{
	// 2112, NOT 2102: RSR.WELLMAG is 2102 (rsr/vreload.zs:24) -- the magazine at the well --
	// and RSR_Guns has RailGun at 6 and Sniper at 8, so both scoped guns already use that id
	// for their VR reload. One psprite id holds one caller; sharing it would have killed the
	// reload on exactly the two guns getting scopes. Taken in the pack: 2100-2111, 2120-2123,
	// 2130-2131, 2200-2203, 2210, 2300-2301. Free: 2112-2119, 2124-2129.
	const RETICLE = 2112;		// RSQ_GunSide, main controller: the collimated reticle
}

class RSQ_ScopeTable abstract
{
	// Measured at each gun's READY frame through the model chain (rgeo.py), centimetres in
	// the weapon controller's frame: F forward, L left, U up.
	//   lens    the centre of the glass
	//   axis    down the bore, unit (the scope camera's centre line)
	//   radius  the glass, so the dot can be clipped to it instead of floating off the tube
	//   mag     magnification for REAL mode; the DOT never magnifies
	clearscope static int Index(Weapon w)
	{
		if (!w)
			return 0;
		Name n = RSQ_Alias.Exact(w);
		if (n == 'RailGun')	return 1;
		if (n == 'Sniper')	return 2;
		return 0;
	}

	clearscope static Vector3 Lens(int i)
	{
		static const double f[] = { 0, 2.756, 5.843 };
		static const double l[] = { 0, 0.416, 1.237 };
		static const double u[] = { 0, 16.469, 10.244 };
				// r9 port: Lens 1 moved with the gun to the FBX hand (was -1.7100 -0.0900 11.8100)
				// r9 port: Lens 2 moved with the gun to the FBX hand (was -0.3000 0.2500 9.2400)
		return i > 0 && i < f.Size() ? (f[i], l[i], u[i]) : (0, 0, 0);
	}

	clearscope static Vector3 Axis(int i)
	{
		// fix-accuracy (owner 2026-10-28: "the scope and the bullet need to be talking to each other"): the camera now
		// looks down the BORE (RSQ_Muzzle.Bore: the 1.92 bore, which runs along the controller's forward, turned with the
		// gun by the port's R), and the shot is zeroed onto this line at RSQ_Muzzle.ZERO_M. The r9 rows were the glass's
		// own axis turned with the gun (RailGun 0.9940 0.0787 0.0764, 0.9 deg off the bore; Ruger 0.9962 0.0624 0.0616,
		// 0.3 deg off): the picture's centre was not where the barrel points even with the shot on the bore.
		static const double f[] = { 0, 0.99602, 0.99602 };
		static const double l[] = { 0, 0.06710, 0.06710 };
		static const double u[] = { 0, 0.05866, 0.05866 };
				// r9 port: Axis 1 moved with the gun to the FBX hand (was 0.9998 0.0149 0.0152)
				// r9 port: Axis 2 moved with the gun to the FBX hand (was 1.0000 -0.0040 0.0038)
		return i > 0 && i < f.Size() ? (f[i], l[i], u[i]) : (1, 0, 0);
	}

	// The lens picture's UP, unit, same frame: the direction the glass UVs call "up" (before the
	// camera's 180 roll, scope_real.zs). Before the r9 port the guns sat level in the hand and
	// this was (0, 0, 1). The r9 port turned both guns by AngleOffset 3.854 / PitchOffset 3.363 /
	// RollOffset 10.974 and moved Lens and Axis with them, but the picture's roll was not in the
	// table, so the lens showed the world tilted by about 11 degrees (rig frame, HANDOFF scope-3x).
	// Measured (2.0 scope-3x): port_gun.rigid_move(gun, MODELDEF.bd.txt / MODELDEF.rsr numbers) @ (0, 0, 1);
	// the same rotation gives the table's Axis and Lens from their pre-port values to 4 decimals.
	clearscope static Vector3 Up(int i)
	{
		static const double f[] = { 0, -0.0447, -0.0447 };
		static const double l[] = { 0, -0.1938, -0.1938 };
		static const double u[] = { 0, 0.9800, 0.9800 };
		return i > 0 && i < f.Size() ? (f[i], l[i], u[i]) : (0, 0, 1);
	}

	// 2.0 scope-3x: the glass's UV half-extent, which is what the camera picture spans
	// (scope_real.zs FovFor), measured from the mesh: |d xyz / d uv| of the glass surface
	// (least-squares fit over its vertices) x MODELDEF Scale x vr_weaponScale 1.02 / 2.
	//   RailGun.md3 surface 1, frame 3: 3.063 / 2.991 md3 units per UV, Scale 1      -> 1.544
	//   XM21.md3 surface 10:            0.234 / 0.234,                Scale 10.485 -> 1.251
	// Was 1.78 / 1.35 (the disc's outer bound): the picture came out about 2.8x, not 3x (rig).
	clearscope static double Radius(int i)
	{
		static const double v[] = { 0, 1.544, 1.251 };
		return i > 0 && i < v.Size() ? v[i] : 0;
	}

	// The glass's own MD3 surface index, which scope_real.zs skins with the camera texture.
	//   1 RailGun  surface 1 "ScopeGlass", authored that way in RailGun.md3
	//   2 Sniper   surface 10 "ScopeGlass", carved out of surface 3 (leupold_scope) by
	//              kit/tool/md3_carve_surface.py; MODELDEF.rsr must list SurfaceSkin 0 10
	// Every MODELDEF block that draws the gun must give the glass a SurfaceSkin and must NOT have a
	// whole-model Skin (a whole-model Skin beats the swap, models_md3.cpp:359-369).
	clearscope static int GlassSurface(int i)
	{
		static const int v[] = { -1, 1, 10 };
		return i > 0 && i < v.Size() ? v[i] : -1;
	}

	clearscope static double Mag(int i)
	{
		static const double v[] = { 0, 3.0, 3.0 };	// 1.99x r6: 3x (owner); see scope_real.zs FovFor
		return i > 0 && i < v.Size() ? v[i] : 1.0;
	}

	// 2.0 scope-toggle: does alt fire toggle this gun's live scope on and off (RSQ_ScopeReal)?
	// The gun's own AltFire state must then only swallow the press (Sniper.dec, Railgun.dec).
	clearscope static bool AltToggle(int i)
	{
		static const bool v[] = { false, true, true };
		return i > 0 && i < v.Size() ? v[i] : false;
	}

	// the cvar that chooses this gun's mode: 0 dot, 1 real
	clearscope static Name ModeCVar(int i)
	{
		static const Name v[] = { 'none', 'rsq_scope2_railgun', 'rsq_scope2_sniper' };
		return i > 0 && i < v.Size() ? v[i] : 'none';
	}
}

class RSQ_Scope abstract
{
	const DOT_LIFT = 0.25;	// cm the dot sits in front of the glass, toward the eye
	// The hand's own axes, built from the Euler angles the renderer wrote this frame.
	// CLEARSCOPE, deliberately: nothing here calls a native: AttackAngle / AttackPitch /
	// AttackRoll are plain readable fields and the rest is trig. So the renderer hook (ui, per
	// frame) and the layer-state chooser (play, per tic) share ONE implementation instead of
	// the play side needing a second copy to decide whether to show the reticle at all. AttackDir() cannot be called from ui (it is a play method on Actor), but the
	// ANGLES are plain fields and ui may read play data -- so the basis is rebuilt here with
	// trig instead. AttackAngle is the world yaw MINUS 90 (p_map.cpp adds the 90 back
	// everywhere it uses it); AttackPitch is positive up.
	// F11: RETURNS the three axes. An `out Vector3` parameter aborts the VM the first time it is
	// called (qzd17.3 vmexec.h:828-830, "REGT_ADDROF not implemented for vectors").
	clearscope static Vector3, Vector3, Vector3 Basis(PlayerPawn mo)
	{
		Vector3 fwd, right, up;
		double yaw = mo.AttackAngle + 90.0;
		// 1.99x r6: NOT negated. On QZD 17.3 AttackPitch is positive UP (the hand pitched 20
		// up logs AttackPitch 20 and AttackDir z +0.342). With the old minus, and r0 below
		// pointing left, the basis matched the engine's at no pose at all. This basis now matches the play side's AttackDir axes to four
		// decimals at three logged poses (yaw/pitch/roll mixed; HANDOFF r6-scope).
		double pit = mo.AttackPitch;
		double rol = mo.AttackRoll;
		double cy = cos(yaw), sy = sin(yaw), cp = cos(pit), sp = sin(pit);
		fwd = (cp * cy, cp * sy, sp);
		// 1.99x r6: this was (-sy, cy, 0), which is LEFT, so right and up both came out
		// negated and every eye landed on the mirror image of the lens: DotAt never had a
		// sight picture and the dot never drew (rig log, HANDOFF r6-scope).
		Vector3 r0 = (sy, -cy, 0);
		// roll the right/up pair about the forward axis
		double cr = cos(rol), sr = sin(rol);
		Vector3 u0 = (r0 cross fwd);	// up at zero roll
		right = r0 * cr - u0 * sr;		// positive AttackRoll tips the right side down
		up = (right cross fwd);
		return fwd, right, up;
	}

	// THE EYE, IN THE WORLD, the way the renderer places it. 1.99x r6: this was the pawn's XY at
	// p.viewz, and that is not where either eye is, which is why neither mode ever worked in a
	// headset (shown on the rig, HANDOFF r6-scope):
	//   HEIGHT  with vr_crouch_use_button on (the QZD default, hw_vrmodes.cpp:122) viewz stays at
	//           the pawn's ViewHeight and the headset's real height is added afterwards, in
	//           OpenXRDeviceEyePose::GetViewShift (hw_openxrdevice.cpp:219):
	//               + (hmdPosition.y + vr_height_adjust) * vu / ps - ViewHeight
	//           The hand is placed from the controller's absolute height (AttackPos.Z,
	//           hw_openxrdevice.cpp:595, weaponoffset = controller - hmd, VrInputDefault.cpp:148),
	//           so with the old eye the gate was off by the player's height minus the pawn's:
	//           16 cm on the rig. QZD hands script the head as Actor.HmdPosition (actor.zs:277,
	//           written each frame at hw_vrmodes.cpp:445).
	//   SIDE    the two eyes are vr_ipd/2 either side of that centre (GetViewShift, eye 0 = left
	//           = -right). 3.2 cm, against a 1.35 cm lens: the centre point can NEVER be behind
	//           the glass while an eye is, so both gates were shut for good.
	// side: -1 left eye, +1 right eye, 0 the centre between them.
	clearscope static Vector3 EyeWorld(PlayerPawn mo, int side)
	{
		let p = mo.player;
		if (!p)
			return mo.pos;
		double ps = mo.Level.pixelstretch;
		if (ps <= 0)
			ps = 1.2;
		double vu = CVarF('vr_vunits_per_meter', 34);
		if (vu <= 0)
			vu = 34;
		Vector3 eye = (mo.pos.x, mo.pos.y, p.viewz);
		let cb = CVar.FindCVar('vr_crouch_use_button');
		if (!cb || cb.GetBool())
			eye.z += (mo.HmdPosition.y + CVarF('vr_height_adjust', 0)) * vu / ps - RSVR_VRHand.StandEyeHeight(mo);	// 2.0.4g: never DOWN's scaled ViewHeight
		if (side != 0)
		{
			double half = CVarF('vr_ipd', 0.064) * 0.5 * vu * side;
			eye += (sin(mo.angle), -cos(mo.angle), 0) * half;	// the view's right
		}
		return eye;
	}

	clearscope static double CVarF(Name n, double def)
	{
		let cv = CVar.FindCVar(n);
		return cv ? cv.GetFloat() : def;
	}

	// Where an eye is, in the hand's own frame, in centimetres.
	clearscope static Vector3 EyeInHandFrame(PlayerPawn mo, int side = 0)
	{
		let p = mo.player;
		if (!p)
			return (0, 0, 0);
		Vector3 eye = EyeWorld(mo, side);
		Vector3 d = eye - mo.AttackPos;
		double ps = mo.Level.pixelstretch;
		if (ps <= 0)
			ps = 1.2;
		d.z *= ps;				// undo the vertical squash the hand transform applies
		double vu = 34.0;
		let cv = CVar.FindCVar('vr_vunits_per_meter');
		if (cv && cv.GetFloat() > 0)
			vu = cv.GetFloat();
		Vector3 f, r, u;
		[f, r, u] = Basis(mo);
		// map units -> cm in the hand frame
		return ((d dot f) * 100.0 / vu, -(d dot r) * 100.0 / vu, (d dot u) * 100.0 / vu);
	}

	// The collimated dot's position on the lens plane, in the hand frame, cm.
	// D = E + A * ((P - E) dot A), then clipped to the glass so it never leaves the tube.
	clearscope static Vector3, bool DotAt(PlayerPawn mo, int i)
	{
		Vector3 P = RSQ_ScopeTable.Lens(i);
		Vector3 A = RSQ_ScopeTable.Axis(i);
		double al = A.Length();
		if (al <= 0)
			return P, false;
		A = A / al;
		// The sighting eye is whichever eye is nearer the bore line; the dot is collimated for
		// that one (the other is behind the tube or looking past it).
		Vector3 E = EyeInHandFrame(mo, -1);
		Vector3 Er = EyeInHandFrame(mo, 1);
		Vector3 tl = P - E, tr = P - Er;
		if ((tr - A * (tr dot A)).Length() < (tl - A * (tl dot A)).Length())
			E = Er;
		Vector3 D = E + A * ((P - E) dot A);
		// off the glass: the eye is not behind the sight, so show nothing rather than a dot
		// stuck to the rim
		Vector3 off = D - P;
		double rr = RSQ_ScopeTable.Radius(i);
		double side = (off - A * (off dot A)).Length();
		if (rr > 0 && side > rr)
			return D, false;
		// behind the glass (looking at the objective end) is not a sight picture either
		if (((P - E) dot A) <= 0)
			return D, false;
		// 1.99x r6: lifted off the glass toward the eye. On the lens plane itself the quad is
		// coplanar with the glass surface and loses the depth test to it: the rig drew the
		// glass and no dot at all with D exactly on the plane.
		return D - A * DOT_LIFT, true;
	}

	// Play-callable: is there a sight picture at all this frame? The layer chooser uses this to
	// pick the Hidden state, instead of flinging the quad off-screen to make it disappear.
	clearscope static bool DotOk(PlayerPawn mo, int i)
	{
		if (!mo || !mo.player || i <= 0)
			return false;
		Vector3 d;
		bool ok;
		[d, ok] = DotAt(mo, i);
		return ok;
	}
}
