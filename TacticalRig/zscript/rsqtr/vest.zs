// THE TORSO (optional, off by default: rsqtr_vest).
//
// A torso worn on the rig's body frame, so the holsters sit on something you can
// see and each stored gun hangs on it. The owner's Quake torso from RS_VRBody
// (vrtorso.mdl, converted to MD3 by tools/mdl2md3.py: stock QuestZDoom reads MD3,
// not Quake .mdl), with RS_VRBody's recoloured skins and its rule for them:
//   no armour      the torso's own skin
//   green armour   green
//   blue armour    blue (a blue suit worn, or 150 armour or more)
//   low health     red breathing over it (a second copy, its alpha pulsing)
//
// It follows the rig's body (yaw, height calibration, scale) and is drawn for the
// player wearing it only: a local look, like the rings.
//
// Measured: the mesh spans x -6.3..6.0 (front-back), y -12.9..12.8 (shoulder to
// shoulder, 0.75 m), z -3.8..18.1 (waist to collar), in map units at scale 1.

class RSQTR_Torso : EventHandler
{
	const COLLAR = 18.1;          // model units: the top of the mesh
	private transient Actor body, breath;

	override void WorldTick()
	{
		let p = players[consoleplayer];
		let rig = RSQTR_Rig.Get();
		bool want = p && p.mo && p.mo.health > 0 && rig && RSQTR_Rig.Flag("rsqtr_vest", p, false) && RSQTR_Rig.Flag("rsqtr_on", p, true);
		if (!want) { Hide(); return; }
		let pmo = p.mo;
		double k = RSQTR_Rig.BodyScale(p);
		double drop = RSQTR_Rig.Num("rsqtr_vest_u", p, -0.20);         // metres from the eyes to the collar
		double back = RSQTR_Rig.Num("rsqtr_vest_f", p, -0.04);         // metres forward of the eyes
		double sz = RSQTR_Rig.Num("rsqtr_vest_size", p, 1.0) * k;
		Vector3 neck = rig.BodyPoint(pmo, back, 0, drop);
		Vector3 at = neck - (0, 0, COLLAR * sz);
		double yaw = rig.BodyYaw(pmo);

		if (!body) body = Actor.Spawn("RSQTR_TorsoPart", at);
		if (!body) return;
		int skin = 0;                                   // 0 own, 1 green, 2 blue
		let armor = BasicArmor(pmo.FindInventory("BasicArmor"));
		if (armor && armor.Amount > 0)
		{
			String t = armor.ArmorType;
			t = t.MakeLower();
			skin = (armor.Amount >= 150 || t.IndexOf("blue") >= 0 || armor.SavePercent >= 0.5) ? 2 : 1;
		}
		Place(body, at, yaw, sz, skin, 1.0);

		// Red breathing over it at low health.
		int low = int(RSQTR_Rig.Num("rsqtr_vest_low", p, 35));
		if (pmo.health < low)
		{
			if (!breath) breath = Actor.Spawn("RSQTR_TorsoPart", at);
			if (breath)
			{
				double a = 0.25 + 0.35 * (0.5 + 0.5 * sin(level.maptime * 9.0));
				Place(breath, at, yaw, sz * 1.003, 3, a);
				breath.A_SetRenderStyle(a, STYLE_Translucent);
			}
		}
		else if (breath) breath.bINVISIBLE = true;
	}

	private static void Place(Actor a, Vector3 at, double yaw, double sz, int fr, double alpha)
	{
		a.SetOrigin(at, true);
		a.angle = yaw;
		a.Scale = (sz, sz);
		a.frame = fr;
		a.Alpha = alpha;
		a.bINVISIBLE = false;
	}

	private void Hide()
	{
		if (body) body.bINVISIBLE = true;
		if (breath) breath.bINVISIBLE = true;
	}
}

class RSQTR_TorsoPart : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		Radius 1; Height 1;
	}
	States { Spawn: RSVT A -1; Stop; }
}
