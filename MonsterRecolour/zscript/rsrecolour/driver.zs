// =====================================================================================================================
// RSQ Monster Recolour: the hand-made art for the colour ladder, WITHOUT new sprite names.
//
// THE LIMIT. QuestZDoom 17.3 numbers sprite frames in 16 bits (65,535 for the whole load order), and the owner's order
// was 1,240 under it on 2026-11-13 (rig, engine read). Brutal Doom's and XMVE's monsters draw about 7,600 frames, so
// twelve recoloured copies under new sprite names (about 91,000 frames) can never fit.
//
// THE TRICK. An actor whose `picnum` is set draws that texture instead of its sprite frame (the engine's own path; the
// Build-tile sprites use it). A texture is not a sprite frame: a PNG in a plain folder of the pk3 (rsrecolour/<colour>/
// <LUMP>.png) is only made into a texture when it is first asked for by its full path, and it counts against nothing.
// picnum has no rotations and no mirroring, so this driver does what the renderer would: every tic, after every actor
// has moved, it asks the engine which lump the actor's frame shows from where the viewer stands
// (State.GetSpriteTexture, the engine's own rotation and mirror tables), and points picnum at that lump's recoloured
// copy (mirrored with the X-flip render flag when the engine would mirror it).
//
// THE COLOUR. RSQ Monsters' tier tint IS the mark: an actor wearing one of the twelve rs_bdtier_* translations is that
// colour (RS_BDTier.zs puts it on the monster and carries it to its corpses, crawlers, last stands and gore pieces).
// The hand-made art must not be tinted again, so the translation is taken off for the frame and put back before the
// next tic's game code runs (RSRC_Handler, the first handler, at the top of the tic; RSRC_Driver, statnum 120, after
// every actor): Brutal Doom, RS_BDTier's Carry and the tier flash see the tint; only the renderer sees the art.
// A frame with no recoloured copy keeps the live tint, so the art can be added a family at a time.
// A monster in the tier flash (its translation is a flash colour, not a tier tint) is left alone.
//
// COST. One array walk per tic over the tracked actors (monsters and tinted pieces); per tinted actor one
// GetSpriteTexture and one Map lookup. Lookups of a full path happen once per lump per colour, then they are cached.
// SINGLE PLAYER: the art is picked for the console player's view, in play code (picnum cannot be set per viewer).
// =====================================================================================================================

class RSRC_Handler : EventHandler
{
	RSRC_Driver drv;

	// First of every handler (lowest Order): the tint must be back on before anyone else's WorldTick or
	// NetworkProcess reads it (RS_BDTier's world-tier follow starts tier flashes there, and a flash keeps the
	// translation it finds as the monster's own).
	override void OnRegister() { SetOrder(-2000000000); }

	override void WorldLoaded(WorldEvent e) { drv = RSRC_Driver.Get(); }

	override void NetworkProcess(ConsoleEvent e) { if (drv) drv.Restore(); }

	override void WorldTick()
	{
		if (!drv) drv = RSRC_Driver.Get();
		drv.Restore();
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || a.player) return;
		if (!drv) drv = RSRC_Driver.Get();
		drv.Offer(a);
	}
}

class RSRC_Driver : Thinker
{
	// tracked actors and what the driver changed on each, for the renderer only
	Array<Actor> who;
	Array<TranslationID> tint;   // the tint the actor wore when the driver drew it
	Array<int>   took;           // 1: the driver took the tint off (and set picnum) for this frame
	Array<int>   xflip;          // the actor's own bXFLIP before the driver drew it (-1: not touched)
	Array<Actor> pending;        // spawned this tic: tracked if they turn out to be monsters or tinted
	Array<int>   tintIds;        // the twelve rs_bdtier_* translations, colour 2..13 in order
	Map<int, int> artCache;      // srcTex * 16 + colour -> index in artTex, -1 none
	Array<TextureID> artTex;
	TranslationID noTrans;       // left at 0: no translation
	transient CVar cvOn, cvDebug;
	int drawn, fell;             // this tic: frames drawn from the art, frames left to the tint (debug log)
	double msSum; int msN;       // debug: the driver's own time per tic

	static const String COLOUR[] = { "", "", "green", "blue", "purple", "cyan", "brown", "yellow", "fireblu", "gray",
		"red", "abyss", "black", "white" };

	static RSRC_Driver Get()
	{
		let it = ThinkerIterator.Create("RSRC_Driver", 120);
		let d = RSRC_Driver(it.Next());
		if (d) return d;
		d = new("RSRC_Driver");
		d.ChangeStatNum(120);       // after every actor (STAT_DEFAULT 100), the scripts (103) and bots (104)
		return d;
	}

	bool On() { if (!cvOn) cvOn = CVar.FindCVar('rsrc_on'); return !cvOn || cvOn.GetBool(); }
	bool Debug() { if (!cvDebug) cvDebug = CVar.FindCVar('rsrc_debug'); return cvDebug && cvDebug.GetBool(); }

	int ColourOf(int tr)
	{
		if (tr == 0) return 0;
		if (tintIds.Size() == 0)
			for (int c = 2; c <= 13; c++) tintIds.Push(int(Translation.GetID(Name("rs_bdtier_" .. COLOUR[c]))));
		for (int i = 0; i < tintIds.Size(); i++) if (tintIds[i] == tr) return i + 2;
		return 0;
	}

	void Offer(Actor a) { pending.Push(a); }

	void Track(Actor a)
	{
		if (who.Find(a) != who.Size()) return;
		who.Push(a); tint.Push(noTrans); took.Push(0); xflip.Push(-1);
	}

	// before the actors: give back what the driver took for the renderer
	void Restore()
	{
		for (int i = 0; i < who.Size(); i++)
		{
			let a = who[i];
			if (!a) continue;
			if (took[i]) { a.Translation = tint[i]; took[i] = 0; a.picnum.SetNull(); }
			if (xflip[i] >= 0) { a.bXFLIP = xflip[i] != 0; xflip[i] = -1; }
		}
	}

	// the recoloured copy of a lump for a colour, by its full path in the pk3
	TextureID Art(TextureID src, int col)
	{
		int key = int(src) * 16 + col;
		int v; bool ok;
		[v, ok] = artCache.CheckValue(key);
		if (!ok)
		{
			String path = String.Format("rsrecolour/%s/%s.png", COLOUR[col], TexMan.GetName(src));
			TextureID t = TexMan.CheckForTexture(path, TexMan.Type_Any);
			v = -1;
			if (t.IsValid()) { v = artTex.Size(); artTex.Push(t); }
			artCache.Insert(key, v);
			if (Debug()) Console.Printf("RSRC art %s -> %s", path, v >= 0 ? "found" : "none");
		}
		if (v >= 0) return artTex[v];
		TextureID none; none.SetNull();
		return none;
	}

	override void Tick()
	{
		// newcomers: monsters always (a tint can come later, with a tier change); anything else only if it is tinted
		for (int i = 0; i < pending.Size(); i++)
		{
			let a = pending[i];
			if (a && (a.bISMONSTER || ColourOf(int(a.Translation)))) Track(a);
		}
		pending.Clear();
		drawn = 0; fell = 0;
		if (!On()) return;
		double t0ms = Debug() ? MSTimeF() : 0;
		let cam = players[consoleplayer].camera;
		if (!cam) return;
		Vector2 vp = cam.pos.xy;
		for (int i = who.Size() - 1; i >= 0; i--)
		{
			let a = who[i];
			if (!a) { who.Delete(i); tint.Delete(i); took.Delete(i); xflip.Delete(i); continue; }
			int col = ColourOf(int(a.Translation));
			if (!col || !a.CurState || a.bINVISIBLE) continue;
			// what the renderer would draw: the angle from the viewer to the thing, against the thing's yaw
			// (the engine: (ang - yaw + 45/2*9) >> 28 for 8 rotations, a further 180/16 back for 16)
			double ang = VectorAngle(a.pos.x - vp.x, a.pos.y - vp.y);
			TextureID t0, t1, src; bool m0, m1, mir; Vector2 sc;
			[t0, m0, sc] = a.CurState.GetSpriteTexture(0, 0, (0, 0), a.sprite, a.frame);
			[t1, m1, sc] = a.CurState.GetSpriteTexture(1, 0, (0, 0), a.sprite, a.frame);
			double off = (t0 == t1 && m0 == m1) ? 202.5 : 202.5 - 11.25;
			int rot = int(floor(((ang - a.angle + off) % 360 + 360) % 360 / 22.5)) & 15;
			[src, mir, sc] = a.CurState.GetSpriteTexture(rot, 0, (0, 0), a.sprite, a.frame);
			if (!src.IsValid()) continue;
			TextureID art = Art(src, col);
			if (!art.IsValid())                                      // no hand-made copy: the live tint stays
			{
				fell++;
				if (Debug() && (level.maptime % 35) == 0) Console.Printf("RSRC t%d %s col %s src %s: no art, tint", level.maptime, a.GetClassName(), COLOUR[col], TexMan.GetName(src));
				continue;
			}
			tint[i] = a.Translation; took[i] = 1;
			a.Translation = noTrans;
			xflip[i] = a.bXFLIP ? 1 : 0;
			if (mir) a.bXFLIP = !a.bXFLIP;
			a.picnum = art;
			drawn++;
			if (Debug() && (level.maptime % 35) == 0)
				Console.Printf("RSRC t%d %s col %s rot %d src %s mir %d", level.maptime, a.GetClassName(), COLOUR[col], rot, TexMan.GetName(src), mir);
		}
		if (!Debug()) return;
		msSum += MSTimeF() - t0ms; msN++;
		if ((level.maptime % 35) == 0)
		{
			Console.Printf("RSRC t%d tracked %d drawn %d tint-only %d | driver %.4f ms/tic over %d tics", level.maptime, who.Size(), drawn, fell, msN ? msSum / msN : 0., msN);
			msSum = 0; msN = 0;
		}
	}
}
