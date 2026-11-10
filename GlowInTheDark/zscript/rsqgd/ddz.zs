// ALTERED for RSQ Glow In The Dark -- this is NOT the original DarkDoomZ. What changed (2026-11-09):
//   - the handler class renamed DarkDoomZ_Handler -> RSQGD_DDZ_Handler (and its option menu class), so nothing clashes;
//   - its FLASHLIGHT REMOVED: the flashlight and spotlight classes, the item given at spawn, its settings, its key,
//     its click sound and its logo (RSQ FnF is the series' one flashlight, and draws DarkDoomZ's beam types itself);
//   - GLOW IN THE DARK AND DARKDOOMZ ARE ONE (owner 2026-11-09 22:01): with GITD off (rsqgd_enabled) the darkness is off
//     too and every sector has its map light back (ChangeLighting below);
//   - the Version line removed (GITD's zscript.txt carries the version; this file is included from rsqgd.zs).
// The darkness itself (the modes, the gains, the fog, the minimum light) is as shipped.
// Original: DarkDoomZ (C) 2018 Sterling Parker (Caligari87), zlib licence (DarkDoomZ/license.md in this pk3).
// Source: darkdoomz.pk3 / https://github.com/caligari87/darkdoomz (commit bcaaab8, 2022 release, ZScript 4.5).

//Courtesy FishyClockwork, with modifications by Caligari87
class RSQGD_DDZ_Handler : EventHandler {
	Array<int> BaseLightLevels;
	int Mode, Preset, PreGain, PostGain, FogDensity, MinLight;
	int OldMode, OldPreset, OldPreGain, OldPostGain, OldFogDensity, OldMinLight;
	double SkyMode, OldSkyMode;
	int BaseAdjustment, FinalAdjustment;
	bool IsSky;
	bool WasOn;       // RSQ: GITD was on at the last pass (a change re-lights every sector)

	override void WorldLoaded(WorldEvent e) {
		if(!ddz_lighting) {
			ThinkerIterator it = ThinkerIterator.Create ("Lighting");
			Lighting effect;
			while (effect = Lighting (it.Next ())) { effect.Destroy (); }
		}

		BaseLightLevels.Clear();
		for(int i = 0; i < Level.Sectors.Size(); i++) {
			BaseLightlevels.Push(Level.Sectors[i].LightLevel);
		}

		ChangeLighting();
	}

	override void UiTick() {
		EventHandler.SendNetworkEvent("UpdateLights");
	}

	override void NetworkProcess(ConsoleEvent e) {
		if(e.Name == "UpdateLights") ChangeLighting();
	}

	void ChangeLighting() {
		// RSQ: GITD off -> DarkDoomZ off: the map's own light, no gains, no fog
		let gc = CVar.FindCVar("rsqgd_enabled");
		bool gitdOn = !gc || gc.GetBool();
		Mode = gitdOn ? ddz_mode : 0;
		Preset = ddz_preset;
		PreGain = gitdOn ? ddz_pregain : 0;
		PostGain = gitdOn ? ddz_postgain : 0;
		SkyMode = ddz_skymode;
		FogDensity = gitdOn ? ddz_fog : 0;
		MinLight = gitdOn ? ddz_minlight : 0;

		bool changed = (
			OldMode != Mode ||
			OldPreset != Preset ||
			OldPreGain != PreGain ||
			OldPostGain != PostGain ||
			OldSkyMode != Skymode ||
			OldFogDensity != FogDensity ||
			OldMinLight != MinLight ||
			WasOn != gitdOn);

		if (changed) {
			BaseAdjustment = 32 * Preset;
			for(int i = 0; i < BaseLightLevels.Size(); i++) {
				int BaseLightLevel = BaseLightLevels[i];
				BaseLightLevel += PreGain;

				IsSky = (level.Sectors[i].GetTexture(0) == skyflatnum ||
						 level.Sectors[i].GetTexture(1) == skyflatnum);

				FinalAdjustment = BaseAdjustment;
				if(IsSky) { FinalAdjustment = int(FinalAdjustment * SkyMode); }

				// Link to graphing calculator depiction of different modes
				// https://www.desmos.com/calculator/v1ni4wftcg
				switch(Mode) {
					case 1: //subtract raw light level (simple fade)
						Level.Sectors[i].Lightlevel = BaseLightLevel - FinalAdjustment;
						break;
					case 2: //linear compression
						Level.Sectors[i].Lightlevel = int(BaseLightLevel * (1.0 - FinalAdjustment / 256.0));
						break;
					case 3: //clamp max brightness level
						Level.Sectors[i].Lightlevel = clamp(BaseLightLevel, 0, 256 - FinalAdjustment);
						break;
					case 4: //apply exponential gamma curve
						Level.Sectors[i].Lightlevel = int((256 - (FinalAdjustment ** (FinalAdjustment / 256))) * (BaseLightLevel / 256.0) ** (1 + (FinalAdjustment / (33 - (FinalAdjustment / 8)))));
						break;
					case 10: //DarkDoom Lite (fixed subtract mode)
						Level.Sectors[i].Lightlevel = BaseLightLevel - 96;
						break;
					case 11: //DarkDoom Classic (fixed subtract mode)
						Level.Sectors[i].Lightlevel = BaseLightLevel - 128;
						break;
					case 12: //DarkDoom Black (fixed subtract mode)
						Level.Sectors[i].Lightlevel = BaseLightLevel - 256;
						break;
					default: //disable
						Level.Sectors[i].Lightlevel = BaseLightLevel; //reset lightlevels
						break;
				}

				Level.Sectors[i].Lightlevel += PostGain;
				Level.Sectors[i].Lightlevel = max(Level.Sectors[i].Lightlevel, MinLight);

				double FinalFogDensity = FogDensity;
				if(IsSky) { FinalFogDensity *= SkyMode; }
				level.Sectors[i].SetFogDensity(int(FinalFogDensity));
			}
		}
		OldMode = Mode;
		OldPreset = Preset;
		OldPreGain = PreGain;
		OldPostGain = PostGain;
		OldSkyMode = SkyMode;
		OldFogDensity = FogDensity;
		OldMinLight = MinLight;
		WasOn = gitdOn;
	}
}

class RSQGD_DDZ_OptionMenu : OptionMenu {
	override void Init(Menu parent, OptionMenuDescriptor desc) {
		super.Init(parent, desc);
		DontDim = true;
		DontBlur = true;
	}
}
