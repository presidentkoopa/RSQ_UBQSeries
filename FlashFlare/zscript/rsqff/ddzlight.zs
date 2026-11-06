// RSQ FlashFlare -- THE DARKDOOMZ LIGHT, from our flashlight (owner 11-06, BUGS_1.0 item 9: "if we can re-write and
// optimize that flashlight and have it come from our model with our tapered cone as an optional visual, then i am happy").
//
// ALTERED SOURCE. This file is NOT the original DarkDoomZ. It is a rewrite, for RSQ FnF, of the flashlight part of
// DarkDoomZ's zscript.zsc (github.com/caligari87/darkdoomz, classes DarkDoomZ_Flashlight and DarkDoomZ_Spotlight):
//   CARRIED: its four flashlight types (Incandescent, Halogen, LED, Red Filter) with their colours, beam and spill angles
//     and radii, number for number; its two qualities (Simple: one spot light averaging beam and spill; Fancy: a beam
//     light plus a spill light at 0.75 of the colour); attenuated spot lights.
//   CHANGED: the lights hang on OUR flashlight model's lens and point along it (torch.zs Beam), never on the player;
//     switched by our flashlight's trigger, not an inventory item; no shadow maps (Quest cost).
//   NOT CARRIED: the damped-spring follow and its mounts (handheld / shoulders / helmet: in VR the hand is the mount, and
//     a spring would make the light trail the hand and our cone), the toggle key, the item given to every player, the
//     click sound (mshahen's, CC BY 3.0: the series uses stock Doom sounds only) and all of DarkDoomZ's darkness.
// Original credits (DarkDoomZ credits.md): Caligari87 (Sterling Parker); code by Kinsie, Gutawer, FishyClockwork,
// phantombeta, Marisa Kirisame, Accensus; testing Fort of Hard Knox, a1337spy, Orange Bomb.
// Class names are RSQFF_ only: DarkDoomZ itself can load alongside.
//
// ---- DarkDoomZ's licence, as its license.md ships it (zlib) ----
// zlib License
//
// (C) 2022 Sterling Parker (aka "Caligari87")
//
// This software is provided 'as-is', without any express or implied
// warranty.  In no event will the authors be held liable for any damages
// arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source distribution.
// ----

// One DarkDoomZ flashlight type: its numbers (DarkDoomZ_Flashlight.DoEffect's switch on ddz_fl_type)
class RSQFF_DdzType play
{
	int r, g, b;
	double beamInner, beamOuter, beamRadius;
	double spillInner, spillOuter, spillRadius;
}

class RSQFF_DdzLight play
{
	// Light Style row: 0 FnF's own beam, 1 DarkDoomZ's
	static bool On() { let c = CVar.FindCVar("rsqff_fl_style"); return c && c.GetInt() == 1; }
	static bool Spill() { let c = CVar.FindCVar("rsqff_fl_ddz_spill"); return !c || c.GetBool(); }

	static RSQFF_DdzType Get()
	{
		let t = new("RSQFF_DdzType");
		let c = CVar.FindCVar("rsqff_fl_ddz_type");
		int k = c ? clamp(c.GetInt(), 0, 3) : 1;
		switch (k)
		{
		case 0: // Incandescent
			t.r = 255; t.g = 214; t.b = 170;
			t.beamInner = 0; t.beamOuter = 25; t.beamRadius = 384;
			t.spillInner = 15; t.spillOuter = 45; t.spillRadius = 128;
			break;
		case 1: // Halogen
			t.r = 255; t.g = 241; t.b = 224;
			t.beamInner = 0; t.beamOuter = 20; t.beamRadius = 512;
			t.spillInner = 10; t.spillOuter = 60; t.spillRadius = 384;
			break;
		case 2: // LED
			t.r = 248; t.g = 255; t.b = 255;
			t.beamInner = 0; t.beamOuter = 15; t.beamRadius = 640;
			t.spillInner = 15; t.spillOuter = 75; t.spillRadius = 256;
			break;
		default: // Red filter
			t.r = 192; t.g = 36; t.b = 34;
			t.beamInner = 0; t.beamOuter = 20; t.beamRadius = 256;
			t.spillInner = 10; t.spillOuter = 60; t.spillRadius = 128;
			break;
		}
		return t;
	}

	// the main light: Fancy (spill on) the beam; Simple the average of beam and spill (DarkDoomZ quality 0)
	static void Main(RSQFF_DdzType t, out Color col, out double inner, out double outer, out int radius)
	{
		col = Color(255, t.r, t.g, t.b);
		if (Spill())
		{
			inner = t.beamInner; outer = t.beamOuter; radius = int(t.beamRadius);
		}
		else
		{
			inner = (t.beamInner + t.spillInner) / 2; outer = (t.beamOuter + t.spillOuter) / 2;
			radius = int((t.beamRadius + t.spillRadius) / 2);
		}
	}

	// the spill light (Fancy only), placed and turned with the main one
	static void PlaceSpill(RSQFF_TorchSpill sp, RSQFF_DdzType t, Vector3 lens, double yaw, double pitch)
	{
		sp.SetOrigin(lens, true);
		sp.angle = yaw;
		sp.pitch = pitch;
		sp.args[DynamicLight.LIGHT_RED] = int(t.r * 0.75);
		sp.args[DynamicLight.LIGHT_GREEN] = int(t.g * 0.75);
		sp.args[DynamicLight.LIGHT_BLUE] = int(t.b * 0.75);
		sp.args[DynamicLight.LIGHT_INTENSITY] = int(t.spillRadius);
		sp.SpotInnerAngle = t.spillInner;
		sp.SpotOuterAngle = t.spillOuter;
	}
}

// DarkDoomZ's spill light (its SelfLight2), from our lens
class RSQFF_TorchSpill : SpotLight
{
	Default
	{
		+DYNAMICLIGHT.NOSHADOWMAP
		+DYNAMICLIGHT.ATTENUATE
	}
}
