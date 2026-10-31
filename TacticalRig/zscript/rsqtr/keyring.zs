// THE KEYRING (owner 2026-10-31: "yes, i like this ... there are 3 keycards and 3 skull keys"): a steel ring on the
// front of your belt, beside the grenade spot on your off-hand side, with every key you carry hanging from it as the key
// itself -- its own pickup sprite, the voxel a voxel pack gives it, or a weapon pack's model of it -- small, in a
// little fan, swinging as you move. Look down and you see what you can open. Only you see it (it is this machine's
// own drawing); nothing about the keys changes. rsqtr_keyring.

class RSQTR_Keyring : EventHandler
{
	const RING_F = 0.14;        // metres from the head, body frame (the rig's BodyPoint): in front of the belt
	const RING_L = 0.13;        // to the off-hand side, clear of the grenade spot on the buckle
	const RING_U = -0.70;
	const KEY_H = 0.08;         // a key's height, metres (bigger than life: it is read from 1.5 m away)
	const SPREAD = 0.045;       // between keys, metres (a voxel key is ~3 cm wide)
	const MAXK = 8;

	transient Actor ring;
	transient Actor keyShow[MAXK];
	transient Vector2 swing;    // the fan's sway, map units (follows the body's motion, springs back)

	override void WorldTick()
	{
		let p = players[consoleplayer];
		let pmo = p ? p.mo : null;
		let rig = RSQTR_Rig.Get();
		bool on = pmo && rig && pmo.health > 0 && RSQTR_Rig.Flag("rsqtr_keyring", p, true) && RSQTR_Rig.Flag("rsqtr_on", p, true);
		Array<Inventory> keys;
		if (on)
			for (let it = pmo.Inv; it && keys.Size() < MAXK; it = it.Inv)
				if (it is "Key" && it.Amount > 0) keys.Push(it);
		if (!on || keys.Size() == 0) { Hide(); return; }

		double side = RSQTR_Body.LayoutLeft() ? -1 : 1;     // the off-hand side: left for a right-hander
		Vector3 at = rig.BodyPoint(pmo, RING_F, RING_L * side, RING_U);
		let body = rig.GetBody();
		double yaw = (body && body.primed) ? body.yaw : pmo.angle;

		// the sway: the keys lag the body's motion a little and swing back
		swing = swing * 0.85 - pmo.vel.xy * 0.06;
		if (swing.Length() > 0.8) swing = swing.Unit() * 0.8;

		if (!ring) ring = Actor.Spawn("RSQTR_RingShow", at);
		if (ring)
		{
			ring.SetOrigin(at, true);
			ring.angle = yaw;
			ring.bINVISIBLE = false;
		}
		// the keys: a fan across the ring, each hanging from it, the middle one lowest
		double upm = RSQTR_Body.UPM;
		Vector2 across = (-sin(yaw), cos(yaw));       // the body's left
		int n = keys.Size();
		for (int k = 0; k < MAXK; k++)
		{
			if (k >= n) { if (keyShow[k]) keyShow[k].bINVISIBLE = true; continue; }
			if (!keyShow[k]) keyShow[k] = Actor.Spawn("RSQTR_KeyShow", at);
			let ks = RSQTR_KeyShow(keyShow[k]);
			if (!ks) continue;
			double off = (k - (n - 1) * 0.5) * SPREAD * upm;
			// a key stands on its origin, so it hangs with its top at the ring: its whole height below it
			double drop = (0.02 + KEY_H + 0.008 * abs(k - (n - 1) * 0.5)) * upm / RSQTR_Body.PIXELSTRETCH;
			Vector3 kp = at + (across.x * off + swing.x, across.y * off + swing.y, -drop);
			ks.Show(keys[k].GetClassName(), KEY_H * upm);
			ks.SetOrigin(kp, true);
			ks.angle = yaw + 180;     // facing you
		}
	}

	private void Hide()
	{
		if (ring) ring.bINVISIBLE = true;
		for (int k = 0; k < MAXK; k++) if (keyShow[k]) keyShow[k].bINVISIBLE = true;
	}

	// The drawings are this machine's alone and held by transient pointers: a save carries orphans, cleared on load.
	override void OnRegister()
	{
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next())) if (a is "RSQTR_RingShow" || a is "RSQTR_KeyShow") a.Destroy();
	}
}

class RSQTR_RingShow : Actor
{
	Default { +NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP Radius 1; Height 1; }
	States { Spawn: RTKR A -1; Stop; }
}

// One key on the ring: the key's own pickup look (as RSQTR_Icon wears a gun's): its first visible Spawn frame, and the
// model a pack binds to the key class, if any.
class RSQTR_KeyShow : Actor
{
	String wearing;
	Default
	{
		+NOINTERACTION +NOBLOCKMAP +NOGRAVITY +NOTELEPORT +DONTSPLASH +NOTONAUTOMAP +BRIGHT
		Radius 1; Height 1;
	}
	States { Spawn: TNT1 A -1; Stop; }

	// hUnits: how tall it should stand. A sprite's height in pixels at scale 1 is its height in map units.
	void Show(String cls, double hUnits)
	{
		if (cls != wearing)
		{
			wearing = cls;
			class<Actor> c = cls;
			let d = c ? GetDefaultByType(c) : null;
			State st = d ? d.SpawnState : null;
			int tnt = GetSpriteIndex('TNT1');
			for (int i = 0; i < 16 && st && st.sprite == tnt; i++) st = st.NextState;
			if (st && st.sprite != tnt)
			{
				sprite = st.sprite; frame = st.Frame;
				A_ChangeModel(Name(cls));
				let tex = st.GetSpriteTexture(0);
				double hpx = 16;
				if (tex.IsValid()) { Vector2 sz = TexMan.GetScaledSize(tex); hpx = max(4.0, sz.y); }
				double sc = hUnits / hpx * (d ? 1.0 / max(0.01, d.Scale.Y) : 1.0);
				Scale = (sc, sc) * (d ? d.Scale.Y : 1.0);
			}
			else { sprite = tnt; frame = 0; }
		}
		bINVISIBLE = false;
	}
}
