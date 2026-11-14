// ============================================================================
// RS_BDArt -- the colour ladder's PAINTED ART for Brutal Doom's and XMVE's monsters, drawn without new sprite names
// (2026-11-13; moved here from the MonsterRecolour prototype's driver). rig only, not headset-confirmed.
//
// WHO HOLDS THE COLOUR. A monster's colour is its kit (RS_BDKit: rung above entry -> Tier()). A piece that came out of a
// coloured body (a corpse that is a new actor, a crawler, a last stand, a limb, a gib) holds it in an RS_BDHue, put on
// by RS_BDTierHandler.Carry. The translation is only what the renderer shows: the tier tint (TRNSLATE rs_bdtier_*)
// when there is no painted frame, nothing when the painted frame is drawn. Nothing reads the colour back from the
// translation any more (that was the prototype's "lift the tint for the renderer" trick, now gone).
//
// THE LIMIT. QuestZDoom 17.3 numbers sprite frames in 16 bits (65,535 for the whole load order), and the owner's order
// was 1,240 under it on 2026-11-13 (rig, engine read). Twelve recoloured copies under new sprite names can never fit.
//
// THE TRICK. An actor whose `picnum` is set draws that texture instead of its sprite frame. A PNG in a plain folder of
// a pk3 (rsrecolour/<colour>/<LUMP>.png, one pk3 per colour: pk3/RSQ_BDXMTiers_<Colour>.pk3) is made into a texture
// only when first asked for by its full path, and counts against nothing. picnum has no rotations and no mirroring,
// so after every actor has moved (a Thinker at statnum 120) this asks the engine which lump the actor's frame shows
// from the console player's view (State.GetSpriteTexture: the engine's own rotation and mirror tables) and points
// picnum at that lump's painted copy (X-flip when the engine would mirror it).
//
// FALLBACK. A frame with no painted copy for its colour (a family not painted yet, an art pk3 not loaded, the option
// off) shows the live tier tint, so the art can arrive a family and a colour at a time.
//
// ONLY OUR OWN LOOK IS TOUCHED. The art is drawn only while the actor shows its tier colour (the tint, or no
// translation at all); the tier flash, a Champions tint before the kit takes it off, or a colour from the monster's
// own states are left on screen as they are.
//
// COST. One walk a tic over the tracked actors (kit monsters and coloured pieces). A tracked actor whose frame, colour
// and rotation from the viewer are what they were last tic costs one angle and a few compares; only a change asks the
// engine for the lump (GetSpriteTexture) and the art table (one Map lookup; a full-path texture lookup once per lump
// per colour). SINGLE PLAYER: the art is picked for the console player's view (picnum cannot be set per viewer).
// RSQ Monsters > Painted Colour Art (rsq_mon_art) 0: the live tint only. rsq_mon_art_debug 1: log lines RSART.
// ============================================================================

// On a piece that came out of a coloured body: its colour, as the kit holds a monster's.
class RS_BDHue : Inventory
{
	int col;               // 2..13
	Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE +INVENTORY.UNCLEARABLE }

	override void DetachFromOwner()
	{
		let c = CVar.FindCVar('rsq_mon_art_debug');
		if (c && c.GetBool() && owner && !owner.bDestroyed) Console.Printf("RSART t%d hue %d taken off a living %s", level.maptime, col, owner.GetClassName());
		Super.DetachFromOwner();
	}

	// The colour (2..13) a thing holds, 0 none: its kit's (above its entry colour), its RS_BDHue's.
	static int ColourOf(Actor a)
	{
		if (!a) return 0;
		for (let i = a.Inv; i; i = i.Inv)
		{
			let k = RS_BDKit(i);
			if (k) return k.rung > k.entry ? k.Tier() : 0;
			let h = RS_BDHue(i);
			if (h) return h.col;
		}
		return 0;
	}

	// Whether it has a kit or a hue at all (a body that is known, coloured or not)
	static bool Known(Actor a)
	{
		if (!a) return false;
		for (let i = a.Inv; i; i = i.Inv) if (RS_BDKit(i) || RS_BDHue(i)) return true;
		return false;
	}

	// Give a piece its colour: the hue, the tint (the look with no painted frame), and the art driver's eye.
	static void Put(Actor a, int col)
	{
		if (!a || col < 2 || col > 13) return;
		let h = RS_BDHue(a.FindInventory("RS_BDHue"));
		if (!h)
		{
			a.GiveInventory("RS_BDHue", 1);
			h = RS_BDHue(a.FindInventory("RS_BDHue"));
			if (!h) return;
		}
		h.col = col;
		a.A_SetTranslation(RS_BDKit.TintName(col));
		RS_BDArt.Watch(a, h);
	}
}

// [11-13 dying-body census] On a PLAYER while it plays a Brutal Doom fatality (RS_BDTierHandler.Fatalities): the colour of
// the monster being killed. Its fatality frames (ARF1 and the rest, painted with the monster's family) are drawn from the
// art; a frame with no art shows the player as it is (never the tint), and its own translation is put back after.
class RS_BDFatalHue : RS_BDHue
{
	TranslationID keepTr;

	static void Put(Actor p, int col)
	{
		if (!p || col < 2 || col > 13) return;
		let h = RS_BDFatalHue(p.FindInventory("RS_BDFatalHue"));
		if (!h)
		{
			p.GiveInventory("RS_BDFatalHue", 1);
			h = RS_BDFatalHue(p.FindInventory("RS_BDFatalHue"));
			if (!h) return;
			h.keepTr = p.Translation;
		}
		h.col = col;
		RS_BDArt.Watch(p, h);
	}

	static void TakeOff(Actor p)
	{
		if (!p) return;
		let h = RS_BDFatalHue(p.FindInventory("RS_BDFatalHue"));
		if (!h) return;
		RS_BDArt.Get().Release(p, h.keepTr);
		h.Destroy();
	}
}

class RS_BDArt : Thinker
{
	// the tracked actors, and what the driver did to each
	Array<Actor>     who;
	Array<Inventory> src;           // its kit or hue (the colour)
	Array<int>       drawn;         // 1: picnum points at a painted frame now
	Array<int>       ownX, setX;    // the actor's own bXFLIP; the bXFLIP the driver left on it
	Array<int>       lSprite, lFrame, lRot, lCol, rot16;   // what was decided last time; rot16: -1 unknown for this frame
	Array<TextureID> lArt;
	Array<double>    lAng;          // the angle from the viewer last time (the skip test)

	Array<int>  tintInt;            // the twelve rs_bdtier_* translations as ints, colour 2..13 at [col - 2]
	Map<int, int> artCache;         // srcTex * 16 + colour -> index in artTex, -1 none
	Array<TextureID> artTex;
	TranslationID noTrans;          // left at 0: no translation
	transient CVar cvOn, cvDebug;
	bool anyDrawn, wasOff;
	int nDrawn, nTint, nSkip, nLook;    // this tic (debug)
	double msSum, msMax; int msN;
	double artPixels;

	static const String COLOUR[] = { "", "", "green", "blue", "purple", "cyan", "brown", "yellow", "fireblu", "gray",
		"red", "abyss", "black", "white" };

	static RS_BDArt Get()
	{
		let it = ThinkerIterator.Create("RS_BDArt", 120);
		let d = RS_BDArt(it.Next());
		if (d) return d;
		d = new("RS_BDArt");
		d.ChangeStatNum(120);       // after every actor (STAT_DEFAULT 100), the scripts (103) and bots (104)
		return d;
	}

	// a kit monster or a coloured piece: watched from now on (a monster at its entry colour too: it can change later)
	static void Watch(Actor a, Inventory from)
	{
		if (!a || !from) return;
		let d = Get();
		if (d.who.Find(a) != d.who.Size()) { d.src[d.who.Find(a)] = from; return; }
		d.who.Push(a); d.src.Push(from); d.drawn.Push(0); d.ownX.Push(a.bXFLIP ? 1 : 0); d.setX.Push(-1);
		d.lSprite.Push(-1); d.lFrame.Push(-1); d.lRot.Push(-1); d.lCol.Push(-1); d.rot16.Push(-1);
		TextureID none; none.SetNull(); d.lArt.Push(none); d.lAng.Push(1e9);
	}

	bool On() { if (!cvOn) cvOn = CVar.FindCVar('rsq_mon_art'); return !cvOn || cvOn.GetBool(); }
	bool Debug() { if (!cvDebug) cvDebug = CVar.FindCVar('rsq_mon_art_debug'); return cvDebug && cvDebug.GetBool(); }

	int TintOf(int col)
	{
		if (tintInt.Size() == 0)
			for (int c = 2; c <= 13; c++) tintInt.Push(int(Translation.GetID(RS_BDKit.TintName(c))));
		return (col >= 2 && col <= 13) ? tintInt[col - 2] : 0;
	}

	// Which colours have art for a sprite (bit per colour), from each art pk3's rsrecolour/<colour>/sprites.txt (the
	// sprite names it holds, written by tools/build_monster_art.py), read once. A colour whose list is missing (an art
	// folder put in by hand) counts as having every sprite: its frames are looked up one by one.
	Map<Name, int> artSprites;      // sprite name -> colour bits
	int listedCols;                 // colour bits that have a list
	bool listsRead;
	Map<int, int> sprMask;          // sprite index -> colour bits

	void ReadLists()
	{
		listsRead = true;
		for (int c = 2; c <= 13; c++)
		{
			int l = Wads.CheckNumForFullName(String.Format("rsrecolour/%s/sprites.txt", COLOUR[c]));
			if (l < 0) continue;
			listedCols |= 1 << c;
			Array<String> names;
			Wads.ReadLump(l).Split(names, " ", TOK_SKIPEMPTY);
			for (int i = 0; i < names.Size(); i++)
			{
				String n = names[i];
				if (n.Length() < 4) continue;
				Name nm = n.Left(4).MakeUpper();
				int b; bool ok;
				[b, ok] = artSprites.CheckValue(nm);
				artSprites.Insert(nm, (ok ? b : 0) | (1 << c));
			}
		}
		if (Debug()) Console.Printf("RSART sprite lists: colours %x, %d sprite names", listedCols, artSprites.CountUsed());
	}

	int SpriteMask(Actor a, int spr)
	{
		int m; bool ok;
		[m, ok] = sprMask.CheckValue(spr);
		if (ok) return m;
		if (!listsRead) ReadLists();
		m = ~listedCols & 0x3FFC;                     // colours with no list: every sprite may have art
		TextureID t; bool mi; Vector2 sc;
		[t, mi, sc] = a.CurState.GetSpriteTexture(0, 0, (0, 0), spr, a.frame);
		if (t.IsValid())
		{
			String n = TexMan.GetName(t);
			int b;
			[b, ok] = artSprites.CheckValue(Name(n.Left(4).MakeUpper()));
			if (ok) m |= b;
		}
		else m = 0;                                   // an empty sprite (TNT1): nothing to draw
		sprMask.Insert(spr, m);
		return m;
	}

	// the painted copy of a lump for a colour, by its full path, cached. [11-14] When there is none and the lump names a
	// rotation (BOSBE1), the frame's single-rotation copy (BOSBE0) is used, unmirrored: RSQ Monsters' ColorfulHell port
	// ships 51 sprites under Brutal Doom 22's and XMVE's names with rotations of its own, loads later and so wins those
	// frames; the art is BD22's look, and the owner chose it ("Bd22 look is right", 11-14 01:05). Second result: true
	// when that copy was used.
	TextureID, bool Art(TextureID tex, int col)
	{
		int key = int(tex) * 16 + col;
		int v; bool ok;
		[v, ok] = artCache.CheckValue(key);
		if (!ok)
		{
			String nm = TexMan.GetName(tex);
			String path = String.Format("rsrecolour/%s/%s.png", COLOUR[col], nm);
			TextureID t = TexMan.CheckForTexture(path, TexMan.Type_Any);
			int fb = 0;
			if (!t.IsValid() && nm.Length() >= 6 && nm.Mid(5, 1) != "0")
			{
				path = String.Format("rsrecolour/%s/%s0.png", COLOUR[col], nm.Left(5));
				t = TexMan.CheckForTexture(path, TexMan.Type_Any);
				fb = 1;
			}
			v = -1;
			if (t.IsValid())
			{
				v = (artTex.Size() << 1) | fb; artTex.Push(t);
				int w, h; [w, h] = TexMan.GetSize(t);
				artPixels += double(w) * h;           // debug: what the painted frames in use cost as 32-bit textures
			}
			artCache.Insert(key, v);
			if (Debug()) Console.Printf("RSART art %s -> %s", path, v >= 0 ? "found" : "none");
		}
		if (v >= 0) return artTex[v >> 1], (v & 1) != 0;
		TextureID none; none.SetNull();
		return none, false;
	}

	// the painted frame off: its own X-flip back, and (when it shows our look) the live tint
	void Undraw(int i, int col, bool tint)
	{
		let a = who[i];
		if (drawn[i])
		{
			a.picnum.SetNull();
			if (setX[i] >= 0 && (a.bXFLIP ? 1 : 0) == setX[i]) a.bXFLIP = ownX[i] != 0;
			drawn[i] = 0; setX[i] = -1;
		}
		if (tint && col && int(a.Translation) != TintOf(col)) a.A_SetTranslation(RS_BDKit.TintName(col));
		lArt[i].SetNull();
	}

	// a player's fatality is over: its own look back, and no longer watched
	void Release(Actor a, TranslationID tr)
	{
		int i = who.Find(a);
		if (i == who.Size()) return;
		if (drawn[i])
		{
			a.picnum.SetNull();
			if (setX[i] >= 0 && (a.bXFLIP ? 1 : 0) == setX[i]) a.bXFLIP = ownX[i] != 0;
		}
		a.Translation = tr;
		Forget(i);
	}

	// [11-13 census] whether a class's states (from its spawn, current and death states, a few steps each) draw a sprite
	// that has painted art in a colour whose art pk3 is loaded (only listed sprites count: with no art loaded, never)
	bool ClassHasArt(Actor a)
	{
		if (!listsRead) ReadLists();
		if (!listedCols) return false;
		State starts[3];
		starts[0] = a.SpawnState; starts[1] = a.CurState; starts[2] = a.FindState("Death");
		for (int j = 0; j < 3; j++)
		{
			State s = starts[j];
			for (int n = 0; s && n < 24; n++, s = s.NextState)
			{
				TextureID t; bool mi; Vector2 sc;
				[t, mi, sc] = s.GetSpriteTexture(0, 0, (0, 0), s.sprite, s.Frame);
				if (!t.IsValid()) continue;
				String nm = TexMan.GetName(t);
				int b; bool ok;
				[b, ok] = artSprites.CheckValue(Name(nm.Left(4).MakeUpper()));
				if (ok && (b & listedCols)) return true;
			}
		}
		return false;
	}

	void Forget(int i)
	{
		who.Delete(i); src.Delete(i); drawn.Delete(i); ownX.Delete(i); setX.Delete(i); lSprite.Delete(i); lFrame.Delete(i);
		lRot.Delete(i); lCol.Delete(i); rot16.Delete(i); lArt.Delete(i); lAng.Delete(i);
	}

	override void Tick()
	{
		bool dbg = Debug();
		double t0 = dbg ? MSTimeF() : 0;
		nDrawn = 0; nTint = 0; nSkip = 0; nLook = 0;
		bool on = On();
		let cam = players[consoleplayer].camera;
		// [11-13 census] no camera for a tic (Brutal Doom's fatality camera going away): nothing changes this tic (it put
		// every painted body back on the tint for that tic before: rig rcF, every dying body at once 35 tics into a fatality)
		if (on && !cam) return;
		if (!on)
		{
			// the option turned off: every painted frame back to the live tint, once
			if (anyDrawn)
				for (int i = who.Size() - 1; i >= 0; i--)
					if (who[i] && drawn[i])
					{
						let fh = RS_BDFatalHue(src[i]);
						Undraw(i, RS_BDHue.ColourOf(who[i]), !fh);
						if (fh) who[i].Translation = fh.keepTr;
					}
			anyDrawn = false;
			wasOff = true;
			return;
		}
		if (wasOff)
		{
			// on again: every tracked actor is looked at afresh (its last decision was the tint)
			wasOff = false;
			for (int i = 0; i < who.Size(); i++) lCol[i] = -1;
		}
		Vector2 vp = cam.pos.xy;
		bool any = false;
		for (int i = who.Size() - 1; i >= 0; i--)
		{
			let a = who[i];
			if (!a || !src[i] || src[i].owner != a) { if (a && drawn[i]) Undraw(i, 0, false); Forget(i); continue; }
			int col;
			let kit = RS_BDKit(src[i]);
			if (kit) col = kit.rung > kit.entry ? kit.Tier() : 0; else col = RS_BDHue(src[i]).col;
			int tr = int(a.Translation);
			// a player in a fatality: the art only (never the tint), whatever translation the player wears
			let fat = RS_BDFatalHue(src[i]);
			// our look: the tier tint, or no translation (the painted frame, or a look put back with none); not the flash,
			// not a Champions tint the kit has not taken off yet, not a colour from the monster's own states
			bool ours = col && (fat || tr == 0 || tr == TintOf(col));
			if (!ours || a.bINVISIBLE || !a.CurState)
			{
				if (drawn[i]) { Undraw(i, col, ours && !fat); if (fat) a.Translation = fat.keepTr; }
				lCol[i] = -1;
				continue;
			}
			int spr = a.sprite, frm = a.frame;
			if (fat && !(SpriteMask(a, spr) & listedCols & (1 << col)))
			{
				if (drawn[i]) { Undraw(i, col, false); a.Translation = fat.keepTr; }
				lCol[i] = -1;
				continue;
			}
			// a sprite with no art in this colour at all (another family, not painted yet): the tint, and nothing more
			if (!(SpriteMask(a, spr) & (1 << col)))
			{
				if (drawn[i] || tr != TintOf(col)) Undraw(i, col, true);
				nTint++;
				lCol[i] = -1;
				continue;
			}
			// what the renderer would draw: the angle from the viewer to the thing, against the thing's yaw
			double ang = VectorAngle(a.pos.x - vp.x, a.pos.y - vp.y) - a.angle;
			// nothing changed since it was last looked at: the same frame, colour and view, and the look it was left with
			bool kept = drawn[i] ? (tr == 0 && a.picnum == lArt[i] && (a.bXFLIP ? 1 : 0) == setX[i]) : (fat ? true : tr == TintOf(col));
			bool same = spr == lSprite[i] && frm == lFrame[i] && col == lCol[i];
			if (kept && same && abs(Actor.deltaangle(ang, lAng[i])) < 0.5)
			{
				nSkip++; if (drawn[i]) { nDrawn++; any = true; } else nTint++;
				continue;
			}
			nLook++;
			TextureID t0x, t1x, tex; bool m0, m1, mir; Vector2 sc;
			if (spr != lSprite[i] || frm != lFrame[i] || rot16[i] < 0)
			{
				// 8 or 16 rotations for this frame (the engine: (ang - yaw + 45/2*9) >> 28 for 8, a further 180/16 back for 16)
				[t0x, m0, sc] = a.CurState.GetSpriteTexture(0, 0, (0, 0), spr, frm);
				[t1x, m1, sc] = a.CurState.GetSpriteTexture(1, 0, (0, 0), spr, frm);
				rot16[i] = (t0x == t1x && m0 == m1) ? 0 : 1;
			}
			double off = rot16[i] ? 202.5 - 11.25 : 202.5;
			int rot = int(floor(((ang + off) % 360 + 360) % 360 / 22.5)) & 15;
			lSprite[i] = spr; lFrame[i] = frm; lCol[i] = col; lAng[i] = ang;
			if (kept && same && rot == lRot[i]) { if (drawn[i]) { nDrawn++; any = true; } else nTint++; continue; }
			lRot[i] = rot;
			[tex, mir, sc] = a.CurState.GetSpriteTexture(rot, 0, (0, 0), spr, frm);
			TextureID art; bool single = false;
			if (tex.IsValid()) [art, single] = Art(tex, col); else art.SetNull();
			if (single) mir = false;
			if (!art.IsValid())
			{
				if (fat) { if (drawn[i]) { Undraw(i, col, false); a.Translation = fat.keepTr; } continue; }
				// no painted frame (or an empty frame): the live tint
				Undraw(i, col, true);
				nTint++;
				if (dbg && (level.maptime % 35) == 0) Console.Printf("RSART t%d %s col %s src %s: no art, tint", level.maptime, a.GetClassName(), COLOUR[col], tex.IsValid() ? TexMan.GetName(tex) : "-");
				continue;
			}
			// its own X-flip: as found the first time, or as its own code set it since
			if (!drawn[i] || setX[i] < 0 || (a.bXFLIP ? 1 : 0) != setX[i]) ownX[i] = a.bXFLIP ? 1 : 0;
			a.Translation = noTrans;
			a.bXFLIP = (ownX[i] != 0) != mir;
			setX[i] = a.bXFLIP ? 1 : 0;
			a.picnum = art;
			lArt[i] = art;
			drawn[i] = 1;
			nDrawn++; any = true;
			if (dbg && (level.maptime % 35) == 0)
				Console.Printf("RSART t%d %s col %s rot %d src %s mir %d", level.maptime, a.GetClassName(), COLOUR[col], rot, TexMan.GetName(tex), mir);
		}
		anyDrawn = any;
		if (!dbg) return;
		double ms = MSTimeF() - t0;
		msSum += ms; msN++; if (ms > msMax) msMax = ms;
		if ((level.maptime % 35) == 0)
		{
			Console.Printf("RSART t%d tracked %d drawn %d tint %d skipped %d looked-up %d | driver %.4f ms/tic avg, %.4f max over %d tics | art textures %d, %.2f MB as RGBA8",
				level.maptime, who.Size(), nDrawn, nTint, nSkip, nLook, msN ? msSum / msN : 0., msMax, msN, artTex.Size(), artPixels * 4 / 1048576.);
			msSum = 0; msN = 0; msMax = 0;
		}
	}
}
