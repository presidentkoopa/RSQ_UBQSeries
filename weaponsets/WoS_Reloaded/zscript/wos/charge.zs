// RSQ_WeaponsOfSaturn: the Nova Ball's and the Hyper Nova's charge, seen, heard and felt (owner 2026-11-16 03:30, fix 6).
// WoS's charges were silent waits (13 and 30 tics with one sound): in the headset you could not tell when the shot would
// go. Now, from the first tic of the charge to the shot:
//   - a glow at the drawn muzzle (RSQ_Muzzle.Where: the same point the shot leaves from), the gun's own round as a sprite
//     and a point light, both growing steadily from a spark to full size as the charge fills;
//   - a buzz (sounds/rsqws/chargehum.wav, made by tools/make_chargehum.py) whose pitch and volume rise with it, played at
//     the muzzle;
//   - the gun hand's controller buzzing harder as it fills, through the set's own rumble (RSQB_GN_Buzzer: the series'
//     tiny local quake, RSQ_Accessibility's Rumble Strength and Rumble Backup by name).
// The glow only ever grows while charging and fades out over a few tics after the shot, so it never flashes; with
// RSQ_Accessibility's Photosensitive Mode (rsqa_photosafe, by name) it is dimmer and fades out slower still.
// Out of VR it hangs where a held gun's muzzle would be, in front of the view.
class RSQWS_ChargeGlow : Actor
{
	PlayerPawn shooter;
	Weapon gun;
	int fullTics, age, fadeLeft;
	bool fading;
	Color col;
	int maxLight;
	double maxScale;

	const FADE = 4;			// tics to fade after the shot
	const FADE_PHOTO = 10;
	const HUM = 13;			// the buzz's sound slot on the glow

	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		+NOGRAVITY
		+DONTSPLASH
		+FORCEXYBILLBOARD
		+BRIGHT
		RenderStyle "Add";
		Alpha 0;
		Scale 0.02;
	}

	static clearscope bool Photo()
	{
		let c = CVar.FindCVar('rsqa_photosafe');
		return c && c.GetInt() != 0;
	}

	// the glow this player's gun is charging now, if any
	static RSQWS_ChargeGlow Of(Actor who, Weapon w)
	{
		if (!who || !w) return null;
		let it = ThinkerIterator.Create('RSQWS_ChargeGlow', STAT_DEFAULT);
		RSQWS_ChargeGlow g;
		while (g = RSQWS_ChargeGlow(it.Next()))
			if (g.shooter == who && g.gun == w && !g.fading)
				return g;
		return null;
	}

	// a charge starts: full after fullTics. kind: 0 the Nova Ball (its blue plasma), 1 the Hyper Nova (the Titan's orange)
	static RSQWS_ChargeGlow Start(Actor who, Weapon w, int fullTics, int kind)
	{
		let mo = PlayerPawn(who);
		if (!mo || !mo.player || !w) return null;
		let old = Of(mo, w);
		if (old) old.Release();
		let g = RSQWS_ChargeGlow(Actor.Spawn(kind == 1 ? 'RSQWS_ChargeGlowTitan' : 'RSQWS_ChargeGlowNova', mo.pos, NO_REPLACE));
		if (!g) return null;
		g.shooter = mo;
		g.gun = w;
		g.fullTics = max(1, fullTics);
		if (kind == 1)
		{
			g.col = Color(255, 255, 153, 64);	// the Titan's rounds' orange (GLDEFS.wos RSQWS_NOVA)
			g.maxLight = 112;
			g.maxScale = 0.35;	// BFS1 is 45 px: about 16 map units (45 cm) at full, under the Hyper Nova itself (0.6)
			g.A_SetTranslation('RSQWS_NovaOrange');
		}
		else
		{
			g.col = Color(255, 128, 128, 255);	// the Nova Rifle's rounds' light (the stock PLASMABALL: 0.5 0.5 1.0)
			g.maxLight = 72;
			g.maxScale = 0.5;	// PLZS is 15 px: about 7.5 map units (22 cm) at full, under the Nova Ball itself (0.8)
		}
		g.Place();
		g.A_StartSound("rsqws/chargehum", HUM, CHANF_LOOPING, 0.25, ATTN_NORM, 0.6);
		return g;
	}

	// the shot went (or the charge was let go): fade out, the buzz stops
	void Release()
	{
		if (fading) return;
		fading = true;
		fadeLeft = Photo() ? FADE_PHOTO : FADE;
		A_StopSound(HUM);
	}
	static void ReleaseOf(Actor who, Weapon w)
	{
		let g = Of(who, w);
		if (g) g.Release();
	}

	// how full the charge is, 0..1
	double Fill() { return clamp(age / double(fullTics), 0.0, 1.0); }

	void Place()
	{
		if (!shooter || !shooter.player) return;
		Vector3 at;
		bool ok = false;
		bool off = gun && shooter.player.OffhandWeapon == gun;
		if (RSVR_VRHand.InVR(shooter))
		{
			if (off) [at, ok] = RSQ_Muzzle.OffWhere(shooter);
			else [at, ok] = RSQ_Muzzle.Where(shooter);
		}
		if (!ok)
		{
			// out of VR (or the muzzle is in a wall): in front of the view, low and to the right, where a held gun's muzzle is
			double a = shooter.angle, p = shooter.pitch;
			Vector3 fw = (cos(a) * cos(p), sin(a) * cos(p), -sin(p));
			Vector3 rt = (sin(a), -cos(a), 0);
			at = (shooter.pos.xy, shooter.player.viewz - 10) + fw * 28 + rt * 6;
		}
		SetOrigin(at, true);
	}

	override void Tick()
	{
		if (!shooter || !shooter.player || !gun || shooter.health <= 0
			|| (shooter.player.ReadyWeapon != gun && shooter.player.OffhandWeapon != gun))
		{
			A_StopSound(HUM);
			Destroy();
			return;
		}
		Place();
		bool photo = Photo();
		double k;
		if (fading)
		{
			fadeLeft--;
			if (fadeLeft <= 0)
			{
				A_RemoveLight('rsqwscharge');
				Destroy();
				return;
			}
			k = Fill() * fadeLeft / double(photo ? FADE_PHOTO : FADE);
		}
		else
		{
			age++;
			k = Fill();
			// the buzz rises: pitch 0.6 -> 1.5, volume 0.25 -> 1
			A_SoundPitch(HUM, 0.6 + 0.9 * k);
			A_SoundVolume(HUM, 0.25 + 0.75 * k);
			// the gun hand feels it: a pulse every 4 tics, stronger as it fills (the set's own rumble path)
			if (age % 4 == 1)
				RSQB_GN_Buzzer.Start(shooter, shooter.player.OffhandWeapon == gun ? 1 : 0, 0.15 + 0.7 * k, 4);
		}
		double dim = photo ? 0.6 : 1.0;
		A_SetScale(0.03 + (maxScale - 0.03) * k);
		Alpha = (0.2 + 0.7 * k) * dim;
		int r = int((8 + (maxLight - 8) * k) * dim);
		if (r > 0)
			A_AttachLight('rsqwscharge', DynamicLight.PointLight, col, r, 0);
		else
			A_RemoveLight('rsqwscharge');
	}
}

class RSQWS_ChargeGlowNova : RSQWS_ChargeGlow
{
	States { Spawn: PLZS A -1 Bright; Stop; }
}
class RSQWS_ChargeGlowTitan : RSQWS_ChargeGlow
{
	States { Spawn: BFS1 A -1 Bright; Stop; }
}
