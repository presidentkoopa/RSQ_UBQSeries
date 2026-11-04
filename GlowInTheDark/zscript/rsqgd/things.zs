// RSQ Glow In The Dark -- things that matter: doors, locked doors in their key's colour, switches, exits (the
// ADDITIVE COLOUR of the wall part that carries them -- a sidedef tier's own colour, no light, nothing per tic but
// a few pulsing lines), keys and pickups (their sprite drawn at full brightness; optionally a small light), and the
// few real lights over the largest pools. Dynamic lights are the one costly thing here: hard-capped (Quest 0 by
// default), spawned once per map or attached once per item, never per tic, no shadows.

class RSQGD_Light : PointLight
{
	Default
	{
		+DYNAMICLIGHT.ATTENUATE
	}
}

extend class RSQGD_Handler
{
	enum EThing { TH_DOOR = 1, TH_LOCKED, TH_SWITCH, TH_EXIT }

	Array<int> lnIdx, lnKind, lnLock;
	Array<Actor> itm;
	Array<int> itmCol, itmPri;
	Array<bool> itmWasBright, itmLit;
	Array<Actor> liqLights;
	String lightCfg;

	static int LockColour(int lock)
	{
		switch (lock)
		{
			case 1: case 4: case 129: case 132: return 0xFF1010;
			case 2: case 5: case 130: case 133: return 0x1838FF;
			case 3: case 6: case 131: case 134: return 0xFFD000;
		}
		return 0xC0A0FF;                     // any key / a lock this table does not know
	}

	static int KindColour(int kind)
	{
		switch (kind)
		{
			case TH_DOOR: return 0x182638;
			case TH_SWITCH: return 0x483000;
			case TH_EXIT: return 0x00C040;
		}
		return 0;
	}

	void SetTier(Side sd, int tier, int col)
	{
		if (!sd) return;
		if (col <= 0) { sd.EnableAdditiveColor(tier, false); return; }
		sd.SetAdditiveColor(tier, col);
		sd.EnableAdditiveColor(tier, true);
	}

	void PaintLine(int k, double gain)
	{
		Line ln = Level.Lines[lnIdx[k]];
		int kind = lnKind[k];
		int col = kind == TH_LOCKED ? LockColour(lnLock[k]) : KindColour(kind);
		double base = (kind == TH_LOCKED) ? 0.45 : 1.0;
		col = (gain <= 0) ? 0 : Scale(col, base * gain * F("rsqgd_things_strength", 1.0));
		if (col == 0 && gain > 0) col = 0x010101;
		if (kind == TH_DOOR || kind == TH_LOCKED)
		{
			// the door's face is the upper part of the wall seen from either room
			SetTier(ln.sidedef[0], Side.top, col);
			SetTier(ln.sidedef[1], Side.top, col);
			if (!ln.sidedef[1]) SetTier(ln.sidedef[0], Side.mid, col);
		}
		else
		{
			// a switch or exit: whichever part of the front wall carries it
			SetTier(ln.sidedef[0], Side.top, col);
			SetTier(ln.sidedef[0], Side.mid, col);
			SetTier(ln.sidedef[0], Side.bottom, col);
		}
	}

	// one pass over the lines (map start, and when a setting moves)
	void ScanThings()
	{
		for (int k = 0; k < lnIdx.Size(); k++) PaintLine(k, 0);
		lnIdx.Clear(); lnKind.Clear(); lnLock.Clear();
		bool on = B("rsqgd_enabled", true) && B("rsqgd_things", true);
		if (on)
		{
			bool doors = B("rsqgd_things_doors", true);
			for (int l = 0; l < Level.Lines.Size(); l++)
			{
				Line ln = Level.Lines[l];
				int sp = ln.special;
				if (!sp) continue;
				int kind = 0, lock = 0;
				if (sp == 13) { kind = TH_LOCKED; lock = ln.args[3]; }
				else if (sp == 202 && ln.args[4]) { kind = TH_LOCKED; lock = ln.args[4]; }
				else if ((sp == 83 || sp == 85) && ln.args[4]) { kind = TH_LOCKED; lock = ln.args[4]; }
				else if (sp == 243 || sp == 244 || sp == 74 || sp == 75) kind = TH_EXIT;
				else if (sp == 10 || sp == 11 || sp == 12 || sp == 14 || sp == 105 || sp == 106 || sp == 202 || sp == 249) kind = doors ? TH_DOOR : 0;
				else if (ln.activation & (SPAC_Use | SPAC_UseThrough | SPAC_Impact | SPAC_Push)) kind = TH_SWITCH;
				if (kind == TH_EXIT && !(ln.activation & (SPAC_Use | SPAC_UseThrough | SPAC_Impact | SPAC_Push))) kind = 0;   // walk-over exits have no wall to light
				if (!kind) continue;
				lnIdx.Push(l); lnKind.Push(kind); lnLock.Push(lock);
			}
		}
		keysMask = -1;
		for (int k = 0; k < lnIdx.Size(); k++) PaintLine(k, 1.0);
		RefreshLights();
	}

	// locked doors and exits breathe; a locked door whose key someone holds glows brighter and quicker
	void ThingsTick()
	{
		int now = Level.maptime;
		if (now % 4 != 2 || lnIdx.Size() == 0) return;
		double t = now / 35.0;
		for (int k = 0; k < lnIdx.Size(); k++)
		{
			int kind = lnKind[k];
			if (kind != TH_LOCKED && kind != TH_EXIT) continue;
			bool have = kind == TH_LOCKED && (keysMask & (1 << (k & 31))) && HaveKey(lnLock[k]);
			double rate = have ? 50 : 18;
			double w = 0.5 + 0.5 * sin(t * rate / 60.0 * 360 + k * 37);
			PaintLine(k, (have ? 1.6 : 0.7) + (have ? 0.8 : 0.5) * w);
		}
	}

	bool HaveKey(int lock)
	{
		for (int p = 0; p < MAXPLAYERS; p++)
			if (playeringame[p] && players[p].mo && players[p].mo.CheckKeys(lock, false, true)) return true;
		return false;
	}

	void CheckKeysHeld()
	{
		keysMask = -1;                       // HaveKey is asked per pulse; this keeps the hook for a cheaper mask
	}

	// ---- keys and pickups ----
	static int ItemKind(Actor a, out int col)
	{
		String n = a.GetClassName();
		n = n.MakeUpper();
		if (a is "Key")
		{
			col = n.IndexOf("RED") >= 0 ? 0xFF2020 : n.IndexOf("BLUE") >= 0 ? 0x3050FF : n.IndexOf("YELLOW") >= 0 ? 0xFFD020 : 0xC0A0FF;
			return 3;
		}
		if (a is "PowerupGiver" || n.IndexOf("SPHERE") >= 0 || n.IndexOf("BERSERK") >= 0 || n == "RADSUIT" || n == "INFRARED"
			|| n == "ALLMAP" || n == "BACKPACK")
		{
			col = n.IndexOf("SOUL") >= 0 ? 0x4070FF : n.IndexOf("MEGA") >= 0 ? 0xFFF0C0 : n.IndexOf("INVUL") >= 0 ? 0x30FF30
				: n.IndexOf("BLUR") >= 0 ? 0xA040FF : n.IndexOf("BERSERK") >= 0 ? 0xFF2020 : 0x80FF80;
			return 2;
		}
		if (a is "Health") { col = 0xFF4040; return 1; }
		if (a is "BasicArmorPickup") { col = n.IndexOf("BLUE") >= 0 ? 0x4060FF : 0x40FF40; return 1; }
		if (a is "Ammo" || a is "Weapon") { col = 0xFFC060; return 0; }
		return -1;
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.thing;
		if (!a || !(a is "Inventory") || Inventory(a).Owner) return;
		int col;
		int pri = ItemKind(a, col);
		if (pri < 0) return;
		itm.Push(a); itmCol.Push(col); itmPri.Push(pri); itmWasBright.Push(a.bBright); itmLit.Push(false);
		if (ready) GlowItem(itm.Size() - 1);
	}

	bool ItemWanted(int k)
	{
		int lvl = I("rsqgd_items", 1);       // 0 off, 1 keys and powerups, 2 + health and armour, 3 + ammo and weapons
		if (!B("rsqgd_enabled", true) || lvl <= 0) return false;
		int pri = itmPri[k];
		return (pri >= 2) || (pri == 1 && lvl >= 2) || (pri == 0 && lvl >= 3);
	}

	void GlowItem(int k)
	{
		let a = itm[k];
		if (!a) return;
		bool want = ItemWanted(k) && !Inventory(a).Owner;
		a.bBright = want ? true : itmWasBright[k];
		if (!want && itmLit[k]) { a.A_RemoveLight('RSQGDItem'); itmLit[k] = false; }
	}

	int LiveLights()
	{
		int n = 0;
		for (int k = 0; k < liqLights.Size(); k++) if (liqLights[k]) n++;
		for (int k = 0; k < itmLit.Size(); k++) if (itmLit[k] && itm[k]) n++;
		return n;
	}

	// once a second: drop picked-up items, then give the capped lights to the most important items left
	void ItemLightsSecond()
	{
		for (int k = itm.Size() - 1; k >= 0; k--)
		{
			let a = itm[k];
			if (a && !Inventory(a).Owner) continue;
			if (a)
			{
				a.bBright = itmWasBright[k];
				if (itmLit[k]) a.A_RemoveLight('RSQGDItem');
			}
			itm.Delete(k); itmCol.Delete(k); itmPri.Delete(k); itmWasBright.Delete(k); itmLit.Delete(k);
		}
		String ls = String.Format("%d %d %d %d %d", I("rsqgd_item_lights", 0), I("rsqgd_liq_lights", 0), I("rsqgd_light_style", 1),
			I("rsqgd_items", 1), B("rsqgd_enabled", true));
		if (ls != lightCfg) { RefreshLights(); }
		int cap = B("rsqgd_enabled", true) ? clamp(I("rsqgd_item_lights", 0), 0, 32) : 0;
		int lit = 0;
		for (int k = 0; k < itm.Size(); k++) if (itmLit[k]) lit++;
		for (int pri = 3; pri >= 0 && lit < cap; pri--)
		{
			for (int k = 0; k < itm.Size() && lit < cap; k++)
			{
				if (itmLit[k] || itmPri[k] != pri || !ItemWanted(k) || !itm[k]) continue;
				bool soft = I("rsqgd_light_style", 1) == 1;
				int col = soft ? Scale(itmCol[k], 0.5) : itmCol[k];
				int rad = soft ? 96 : 48;
				itm[k].A_AttachLight('RSQGDItem', DynamicLight.PointLight, col, rad, 0, DynamicLight.LF_ATTENUATE, (0, 0, 16));
				itmLit[k] = true;
				lit++;
			}
		}
	}

	// the lights and the item glow follow their settings (also re-capped when a cap falls)
	void RefreshLights()
	{
		lightCfg = String.Format("%d %d %d %d %d", I("rsqgd_item_lights", 0), I("rsqgd_liq_lights", 0), I("rsqgd_light_style", 1),
			I("rsqgd_items", 1), B("rsqgd_enabled", true));
		for (int k = 0; k < itm.Size(); k++)
		{
			if (itmLit[k] && itm[k]) itm[k].A_RemoveLight('RSQGDItem');
			itmLit[k] = false;
			GlowItem(k);
		}
		SpawnLiquidLights();
	}

	// a few real lights over the largest pools (capped; Quest preset 0)
	void SpawnLiquidLights()
	{
		for (int k = 0; k < liqLights.Size(); k++) if (liqLights[k]) liqLights[k].Destroy();
		liqLights.Clear();
		int cap = B("rsqgd_enabled", true) && B("rsqgd_liquids", true) ? clamp(I("rsqgd_liq_lights", 0), 0, 16) : 0;
		if (cap <= 0) return;
		Array<int> pick; Array<double> area;
		for (int q = 0; q < liquids.Size(); q++)
		{
			int i = liquids[q];
			int cls = RSQGD_Liquid.ClassOf(liq0[i]);
			if (cls <= 0) continue;
			Sector s = Level.Sectors[i];
			double x0 = 1e9, x1 = -1e9, y0 = 1e9, y1 = -1e9;
			for (int l = 0; l < s.lines.Size(); l++)
			{
				Vector2 a = s.lines[l].v1.p, b = s.lines[l].v2.p;
				x0 = min(x0, min(a.x, b.x)); x1 = max(x1, max(a.x, b.x)); y0 = min(y0, min(a.y, b.y)); y1 = max(y1, max(a.y, b.y));
			}
			double ar = (x1 - x0) * (y1 - y0);
			int at = pick.Size();
			for (int j = 0; j < pick.Size(); j++) if (ar > area[j]) { at = j; break; }
			pick.Insert(at, i); area.Insert(at, ar);
			if (pick.Size() > cap) { pick.Pop(); area.Pop(); }
		}
		bool soft = I("rsqgd_light_style", 1) == 1;
		for (int j = 0; j < pick.Size(); j++)
		{
			int i = pick[j];
			Sector s = Level.Sectors[i];
			Vector2 c = s.centerspot;
			double z = s.floorplane.ZatPoint(c) + 40;
			let li = RSQGD_Light(Actor.Spawn("RSQGD_Light", (c.x, c.y, z)));
			if (!li) continue;
			int col = Scale(RSQGD_Liquid.Colour(RSQGD_Liquid.ClassOf(liq0[i])), soft ? 0.35 : 0.7);
			int rad = int(clamp(sqrt(area[j]) * 0.35, 64.0, 256.0)) * (soft ? 2 : 1);
			li.args[DynamicLight.LIGHT_RED] = (col >> 16) & 255;
			li.args[DynamicLight.LIGHT_GREEN] = (col >> 8) & 255;
			li.args[DynamicLight.LIGHT_BLUE] = col & 255;
			li.args[DynamicLight.LIGHT_INTENSITY] = rad;
			liqLights.Push(li);
		}
	}
}
