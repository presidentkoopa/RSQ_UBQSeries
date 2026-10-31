// YOUR BODY IN A MIRROR (with the torso on: rsqtr_vest).
//
// What the engine draws in a map mirror (Line_Mirror), measured in a frame dump of a mirror room
// with Brutal Doom, BD_VoxelPack and Brutal Doom Quest:
//   - every actor, your own pawn's sprite included: the sprite marine, holding its sprite gun
//   - the torso and the helmet (world actors; the helmet only there: +ONLYVISIBLEINMIRRORS)
//   - NOT what your hands hold. A held gun and the hands are psprites, drawn once after the
//     scene at the controllers (hw_weapon.cpp PreparePlayerSprites3D), never inside a mirror.
//
// So with the torso on, a STAND-IN follows each psprite layer that the load order draws with a
// model: a world actor, +ONLYVISIBLEINMIRRORS (your own view never draws it, a mirror does),
// wearing that layer's model through A_ChangeModel with the layer's own sprite and frame, so it
// shows the gun and the hands as they are this tic, firing frames and all. And the sprite marine
// is hidden in mirrors (+INVISIBLEINMIRRORS on your pawn), so the mirror shows one body, not two.
//
// THE POSE IS THE RENDERER'S, REDONE FOR THE WORLD. A held model is drawn (r_data/models.cpp
// RenderHUDModel) at the controller's pose, shrunk to 0.01 of a metre per model unit, moved
// (0, 5, 30) cm in the controller's frame, scaled and offset by its MODELDEF block, turned 90
// degrees, turned by the block's angle offsets and scaled by vr_weaponScale; the left
// controller's model is mirrored (auto-reverse, unless the weapon is NoAutoReverse). A world
// actor applies the same MODELDEF scale and offset in another order. Stand() solves for the
// actor's place, angles and scale (a negative height mirrors it, for the right controller,
// whose HUD model is mirrored against the world's) so the two match; the block's Scale and
// Offset come from RSQTRLAY (tools/measure_pickups.py --layers), because a running game cannot
// read a MODELDEF.
//
// What it cannot copy (report, 10-27):
//   - per-layer moves made in ui code at draw time (Weapon.ModifyBobLayer3D): Brutal Doom
//     Quest places its gun hand and support hand on each gun that way, and its reload layers;
//     the stand-ins show those layers where the controller is, without that move (exact for
//     the guns whose hands are baked in place, a few centimetres off on the others)
//   - a layer's x/y offsets (the renderer turns them into small turns), the walking bob and the
//     frame-to-frame blend of a model's animation
//   - anything drawn as a flat sprite: only layers with a measured model are stood in for
class RSQTR_LayerTable play
{
	Array<String> lines;
	Map<Name, int> first;

	static RSQTR_LayerTable Load()
	{
		let t = new("RSQTR_LayerTable");
		int l = -1;
		while ((l = Wads.FindLump("RSQTRLAY", l + 1, Wads.AnyNamespace)) >= 0)
		{
			Array<String> ls;
			Map<Name, int> here;
			Wads.ReadLump(l).Split(ls, "\n");
			for (int i = 0; i < ls.Size(); i++)
			{
				String s = ls[i];
				s.StripRight();
				if (s.Length() == 0 || s.Left(2) == "//") continue;
				int sp = s.IndexOf(" ");
				if (sp <= 0) continue;
				Name c = s.Left(sp);
				// a later table (a later file) wins for the classes it lists
				if (!here.CheckKey(c)) { here.Insert(c, 1); t.first.Insert(c, t.lines.Size()); }
				t.lines.Push(s);
			}
		}
		return t;
	}

	// The MODELDEF Scale (x y z) and Offset (x y z) the engine draws class c's sprite frame with,
	// left in sc and off (this VM passes no vectors by reference).
	Vector3 sc, off;
	bool Find(Name c, SpriteID spr, int frame)
	{
		if (!first.CheckKey(c)) return false;
		String fr = String.Format("%c", 65 + frame);
		for (int i = first.Get(c); i < lines.Size(); i++)
		{
			Array<String> t;
			lines[i].Split(t, " ", TOK_SKIPEMPTY);
			if (t.Size() < 9 || Name(t[0]) != c) break;
			if (Actor.GetSpriteIndex(Name(t[1])) != spr || t[2].IndexOf(fr) < 0) continue;
			sc = (t[3].ToDouble(), t[4].ToDouble(), t[5].ToDouble());
			off = (t[6].ToDouble(), t[7].ToDouble(), t[8].ToDouble());
			return true;
		}
		return false;
	}
}

class RSQTR_MirrorBody : EventHandler
{
	transient Array<RSQTR_HeldShow> shows;    // one per layer id with a model
	private transient Array<RSQTR_LayerMemo> memo;   // per layer id: the frame last looked up, and its block
	private transient RSQTR_LayerTable table;
	private transient int lastWant;            // 0 none yet (a new level or a load), 1 off, 2 on

	override void WorldTick()
	{
		let p = players[consoleplayer];
		let pmo = p ? p.mo : null;
		bool want = pmo && pmo.health > 0 && RSQTR_Rig.Flag("rsqtr_on", p, true) && RSQTR_Rig.Flag("rsqtr_vest", p, false);

		// THE SPRITE MARINE leaves the mirror while the torso stands in for it. Set when that
		// changes, and on the first tic of a level or a load (the pawn and its flag carry over
		// from the last level, and a save holds the flag), so it never sticks either way.
		if (pmo && lastWant != (want ? 2 : 1))
		{
			pmo.bINVISIBLEINMIRRORS = want;
			lastWant = want ? 2 : 1;
		}

		for (int i = 0; i < shows.Size(); i++) if (shows[i]) shows[i].used = false;
		if (want)
		{
			if (!table) table = RSQTR_LayerTable.Load();
			bool steady = (p.WeaponState & WF_TWOHANDSTABILIZED) != 0;
			for (let s = p.psprites; s; s = s.Next)
			{
				if (s.ID >= PSprite.TARGETCENTER) break;
				if (!s.CurState || !s.Caller) continue;
				bool off = s.Caller == p.OffhandWeapon;
				if (steady && off) continue;          // the renderer hides the off hand's layers then
				// the table is searched only when the layer's frame changes
				let m = MemoFor(s.ID);
				Name cls = s.Caller.GetClassName();
				if (m.st != s.CurState || m.cls != cls || m.spr != s.Sprite || m.fr != s.Frame)
				{
					m.st = s.CurState; m.cls = cls; m.spr = s.Sprite; m.fr = s.Frame;
					m.ok = table.Find(cls, s.Sprite, s.Frame);
					if (m.ok) { m.sc = table.sc; m.off = table.off; }
				}
				if (!m.ok) continue;                  // no model: a flat sprite is not stood in for
				let sh = ShowFor(s.ID, pmo);
				if (!sh) continue;
				sh.Stand(pmo, s, off, m.sc, m.off);
				sh.used = true;
			}
		}
		for (int i = 0; i < shows.Size(); i++) if (shows[i] && !shows[i].used) shows[i].bINVISIBLE = true;
	}

	private RSQTR_LayerMemo MemoFor(int id)
	{
		for (int i = 0; i < memo.Size(); i++) if (memo[i].id == id) return memo[i];
		let m = new("RSQTR_LayerMemo");
		m.id = id;
		memo.Push(m);
		return m;
	}

	private RSQTR_HeldShow ShowFor(int id, Actor pmo)
	{
		for (int i = 0; i < shows.Size(); i++) if (shows[i] && shows[i].layer == id) return shows[i];
		let sh = RSQTR_HeldShow(Actor.Spawn("RSQTR_HeldShow", pmo.pos));
		if (!sh) return null;
		sh.layer = id;
		shows.Push(sh);
		return sh;
	}
}

class RSQTR_LayerMemo play
{
	int id;
	State st;
	Name cls;
	SpriteID spr;
	int fr;
	bool ok;
	Vector3 sc, off;
}

// A world copy of one psprite layer, seen only in mirrors.
class RSQTR_HeldShow : Actor
{
	int layer;
	bool used;
	Name wearing;

	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		+ONLYVISIBLEINMIRRORS
		Radius 1; Height 1;
	}
	States { Spawn: TNT1 A -1; Stop; }

	// The renderer's controller frame turned into the map: x right, y up, z back (GL axes,
	// hw_openxrdevice.cpp GetHandTransform: yaw, then pitch, then roll).
	static Vector3 Turn(double yaw, double pitch, double roll, Vector3 q)
	{
		double c = cos(roll), s = sin(roll);
		q = (q.x * c - q.y * s, q.x * s + q.y * c, q.z);
		c = cos(pitch); s = sin(pitch);
		q = (q.x, q.y * c - q.z * s, q.y * s + q.z * c);
		c = cos(yaw); s = sin(yaw);
		q = (q.x * c + q.z * s, q.y, -q.x * s + q.z * c);
		return (q.x, -q.z, q.y);                 // GL (x, up, -mapY) to map (x, y, z)
	}

	void Stand(PlayerPawn pmo, PSprite s, bool off, Vector3 sc, Vector3 ofs)
	{
		let p = pmo.player;
		Name cls = s.Caller.GetClassName();
		if (cls != wearing)
		{
			wearing = cls;
			A_ChangeModel(cls);
			SetModelFlag(MDL_USEACTORPITCH | MDL_USEACTORROLL);
		}
		sprite = s.Sprite;
		frame = s.Frame;

		Vector3 at = off ? pmo.OffhandPos : pmo.AttackPos;
		double ya = off ? pmo.OffhandAngle : pmo.AttackAngle;
		double pi = off ? pmo.OffhandPitch : pmo.AttackPitch;
		double ro = -(off ? pmo.OffhandRoll : pmo.AttackRoll);
		// the left controller's model is mirrored (hw_vrmodes.cpp GetWeaponTransform)
		let w = off ? p.OffhandWeapon : p.ReadyWeapon;
		bool rev = (off != RSQTR_Body.LeftHanded()) && (!w || !w.bNoAutoReverse);

		let cu = CVar.FindCVar("vr_vunits_per_meter"), cw = CVar.FindCVar("vr_weaponScale");
		double cm = (cu ? cu.GetFloat() : 34.0) * 0.01;    // map units per HUD model unit
		double k = cm * (cw ? cw.GetFloat() : 1.0);

		Vector3 R = Turn(ya, pi, ro, (1, 0, 0)), U = Turn(ya, pi, ro, (0, 1, 0)), B = Turn(ya, pi, ro, (0, 0, 1));
		double sg = sc.x * sc.y < 0 ? -1 : 1;
		Vector3 F = B * -sg;
		Vector3 L = rev ? R * -sg : R * sg;
		Vector3 Up = rev ? U : -U;
		Scale = (k, rev ? k : -k);
		// angles from the basis (RSQTR_Fit.Basis's convention)
		angle = atan2(F.y, F.x);
		pitch = -asin(clamp(F.z, -1.0, 1.0));
		Vector3 F0, L0, U0;
		[F0, L0, U0] = RSQTR_Fit.Basis(angle, pitch, 0);
		roll = atan2(L dot U0, L dot L0);

		// where the renderer puts the model's offset point, less where the world would
		Vector3 cust = (CVarF("vr_3dweaponOffsetX"), CVarF("vr_3dweaponOffsetY"), CVarF("vr_3dweaponOffsetZ"));
		Vector3 q = (0, 5, 30) + (ofs.x, ofs.z, ofs.y) + (sc.x * -cust.x, sc.z * cust.y, sc.y * cust.z);
		if (rev) q.x = -q.x;
		Vector3 h = Turn(ya, pi, ro, q);
		h.z /= RSQTR_Body.Ps();
		Vector3 hud = at + h * cm;
		Vector3 wrl = (F * ofs.x + U * ofs.z + L * ofs.y) * k;
		SetOrigin(hud - wrl, true);
		Alpha = s.alpha;
		bINVISIBLE = false;
	}

	static double CVarF(String n) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : 0; }
}
