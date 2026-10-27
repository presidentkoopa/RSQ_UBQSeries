// THE TORSO (optional, off by default: rsqtr_vest).
//
// A torso worn on the rig's body frame, so the holsters sit on something you can
// see and each stored gun hangs on it. Quake's Grunt (id Software), cut into a torso by
// Vittorio Romeo's original Quake VR mod -- vrtorso.mdl, the same file the owner's RS_VRBody
// and REMA avatar work use: Doom meets Quake. Converted to MD3 by tools/mdl2md3.py (stock
// QuestZDoom reads MD3, not Quake .mdl), with RS_VRBody's recoloured skins and its rule:
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

// TWO TORSOS (rsqtr_vest_style): the Doom marine's (the default, the owner's pick:
// RS_VRBody's marine_torso.iqm, a Doom Eternal Classic Slayer rip, recoloured green /
// blue / red there -- green without armour too) or Quake's Grunt (below).
class RSQTR_Torso : EventHandler
{
	const COLLAR = 18.1;          // model units: the top of the Quake mesh
	const HELMET_DROP = 3.45;     // map units the helmet sits below the eyes: resting on the collar is 6.0 (at 0 it floated 0.62 of its height over it, at 7.8 it sank 0.28 into the shoulders, both measured in the mirror); the owner, 10-27, wants it 3-4 inches above that so it stays near the eyeline: 3.5 in = 0.09 m = 2.55 units up
	const SHOULDERS = 51.689;     // model units: the marine's shoulder line (RS_VRBody's PivotOffset)
	transient Actor body, breath;      // read by the mirror (mirror.zs)
	transient Actor helmet;            // read by the mirror too

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
		bool marine = RSQTR_Rig.Opt("rsqtr_vest_style", p, 0) == 0;
		Vector3 at = neck - (0, 0, (marine ? SHOULDERS : COLLAR) * sz);
		double yaw = rig.BodyYaw(pmo);
		String cls = marine ? "RSQTR_MarinePart" : "RSQTR_TorsoPart";

		if (body && body.GetClassName() != cls) { body.Destroy(); body = null; if (breath) { breath.Destroy(); breath = null; } }
		if (!body) body = Actor.Spawn(cls, at);
		if (!body) return;
		int skin = 0;                                   // 0 own, 1 green, 2 blue
		let armor = BasicArmor(pmo.FindInventory("BasicArmor"));
		if (armor && armor.Amount > 0)
		{
			String t = armor.ArmorType;
			t = t.MakeLower();
			skin = (armor.Amount >= 150 || t.IndexOf("blue") >= 0 || armor.SavePercent >= 0.5) ? 2 : 1;
		}
		// The marine has no bare look: green unless blue (RS_VRBody's rule); its frames are
		// green, blue, red. The Quake torso's: own, green, blue, red.
		// IT FADES AS YOU LOOK DOWN (the owner, 10-27: "can the torsos fade out when I look down,
		// I can't see my holsters or stored weapons"). Solid looking ahead; from 12 degrees down
		// it thins, to a ghost (0.06) by 32 -- the first version (25 -> 50) went unseen in the
		// headset (10-27): a glance at the hip is a shallow head pitch.
		double fade = 1.0;
		if (RSQTR_Rig.CVarOn("rsqtr_vest_fade"))
			fade = clamp(1.0 - (pmo.pitch - 12.0) / 20.0 * 0.47, 0.53, 1.0);   // half the change (the owner, 10-27): solid to 0.53
		Place(body, at, yaw, sz, marine ? (skin == 2 ? 1 : 0) : skin, fade);
		body.A_SetRenderStyle(fade, fade > 0.99 ? STYLE_Normal : STYLE_Translucent);

		int low = int(RSQTR_Rig.Num("rsqtr_vest_low", p, 35));
		// THE HELMET, on your head and turning with the headset (rsqtr_helmet, the owner, 10-27:
		// "can we get that on our torso so we have a helmet, and hide the surface from our view so
		// it still shows up in mirrors"). Its colour follows the torso's armour.
		if (RSQTR_Rig.CVarOn("rsqtr_helmet") && marine)
		{
			if (!helmet) helmet = Actor.Spawn("RSQTR_HelmetPart", RSQTR_Body.Head(pmo));
			if (helmet)
			{
				// IT RESTS ON THE TORSO (the owner, 10-27: "the helmet seems pretty high, does it
				// rest on the torso like a real head?"). At the eyes it floated a neck's height over
				// the collar (measured in the mirror: a gap of 0.62 of the helmet's own height), so it
				// sits DROP lower, scaled with the body; rsqtr_helmet_u fine-tunes it in metres.
				double hs0 = RSQTR_Rig.Num("rsqtr_vest_size", p, 1.0) * k;
				double lift = RSQTR_Rig.Num("rsqtr_helmet_u", p, 0.0) * RSQTR_Body.UPM / RSQTR_Body.PIXELSTRETCH;
				helmet.SetOrigin(RSQTR_Body.Head(pmo) + (0, 0, lift - HELMET_DROP * hs0), true);
				helmet.angle = pmo.angle;
				helmet.pitch = pmo.pitch;
				helmet.roll = pmo.roll;
				double hs = RSQTR_Rig.Num("rsqtr_vest_size", p, 1.0) * k;
				helmet.Scale = (hs, hs);
				helmet.frame = skin == 2 ? 1 : 0;
				helmet.bINVISIBLE = false;
			}
		}
		else if (helmet) helmet.bINVISIBLE = true;

		// Red breathing over it at low health.
		if (pmo.health < low)
		{
			if (!breath) breath = Actor.Spawn(cls, at);
			if (breath)
			{
				double a = (0.25 + 0.35 * (0.5 + 0.5 * sin(level.maptime * 9.0))) * fade;
				Place(breath, at, yaw, sz * 1.003, marine ? 2 : 3, a);
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
		if (helmet) helmet.bINVISIBLE = true;
	}
}

class RSQTR_MarinePart : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		Radius 1; Height 1;
	}
	States { Spawn: RSVM A -1; Stop; }
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

class RSQTR_HelmetPart : Actor
{
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP
		+ONLYVISIBLEINMIRRORS
		Radius 1; Height 1;
	}
	States { Spawn: RSVH A -1; Stop; }
}
