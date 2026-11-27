// ============================================================================
// RSQGO_Data -- the phase 1 cards, as flat arrays. Filled at run time by the GENERATED half of this class
// (zscript/rsqgo/cards.zs, written by Gore/tools/gen_gore.py from BD's own DECORATE), never by hand.
//
// A CARD is one Brutal Doom class we take over: what an actor of that class shows (its TRACKS: BD's actor tic by tic,
// one per random branch, with BD's odds: keyframes of frame, x/y scale, alpha and Bright), what it spawns and when
// (children), what it leaves where it lands (BD's floor spot class, a splash track, a sound) and, for a hit blood,
// every blood-level path. The frames are our baked copies of BD's (graphics/rsqgo, also generated). Held by the
// manager as a transient object: rebuilt after a load.
// ============================================================================

class RSQGO_Data play
{
	enum EKind { K_DROP, K_HIT, K_LIQUID }
	enum ECat { C_HIT, C_FLYING, C_MIST, C_LIQUID }
	// When a child spawn plays (cards.py P_*): a drop's own children, a hit blood's paths, landing, under water.
	// P_LEVEL2 is a hit blood's own path after BD's intensity script starts (it always runs: BD's script acts after
	// it); P_LOW its LowBlood entered again (levels 0-1, the SlaughterCounter jump); P_LOTS/ABSURD/ANIMU the levels.
	enum EPath { P_DROP, P_COMMON, P_LEVEL2, P_LOTS, P_ABSURD, P_ANIMU, P_WATER, P_SAW, P_FLOOR, P_WALL, P_LOW }
	// A hit blood's puff tracks, one set per way BD's blood reaches its LowBlood frames (cards.py R_*).
	enum ERoute { R_LEVEL2, R_LOW, R_LOTS, R_ABSURD, R_ANIMU, R_SLAUGHTER }
	enum EMode { M_MISSILE, M_ITEMEX, M_ITEM }
	// The surfaces a missile bounces off instead of dying (cards.py B_*; BD's BOUNCEONWALLS / DOOMBOUNCE ...)
	enum EBounce { B_WALLS = 1, B_FLOORS = 2, B_CEILINGS = 4, B_AUTOOFF = 8 }
	const NR = 14;              // numbers per child: 7 random ranges (lo, hi)

	bool ok;                    // Brutal Doom is loaded (its Brutal_Blood class exists)
	Class<Inventory> invSaw;            // BD's HasCutingWeapon (the saw branch reads it on the victim's TARGET, the attacker)
	Class<Inventory> invSlaughter;      // BD's SlaughterCounter (30 or more on the victim: low blood)

	// ---- cards
	Array<String> cName;
	Array< Class<Actor> > cCls;
	Array<int> cKind;
	Array<int> cCat;
	Array<double> cSpeed;
	Array<double> cGrav;
	Array<bool> cMissile;
	Array<bool> cNoclip;
	Array<int> cStyle;
	Array<String> cDecal;
	Array<String> cSpot;
	Array<int> cLife;
	Array<String> cLandSound;
	Array<double> cRadius;
	Array<bool> cStopMove;
	Array<bool> cNoInter;       // +NOINTERACTION: moves by its velocity only (no gravity, floor or walls)
	Array<int> cBounce;         // B_* bits
	Array<double> cWallBF;      // WallBounceFactor
	Array<double> cBF;          // BounceFactor
	Array<double> cMass;        // Mass (how fast it sinks under water)
	Array<bool> cPure;          // nothing it does reaches the playsim (no spot, no actor child, no give): cosmetic only
	Array<bool> cDropKids;      // it has P_DROP children (a culled drop still needs its flight to cut them where it lands)
	Array< Class<Actor> > cBDCls;       // BD's class itself (its default Translation colours our frames: emit.zs ClassTrans)
	Array< Class<Actor> > cSpotC;       // cSpot / cLSpot resolved once (Build)
	Array< Class<Actor> > cLSpotC;
	Array<int> cVar0;
	Array<int> cVarN;
	Array<int> cSpl0;
	Array<int> cSplN;
	Array<int> cWSpl0;
	Array<int> cWSplN;
	Array<int> cPuff0;
	Array<int> cPuffN;
	Array<int> cKid0;
	Array<int> cKidN;
	Array<int> cGive0;
	Array<int> cGiveN;
	// hit bloods
	Array<String> cSound;
	Array<int> cSlaughter;      // SlaughterCounter count on the victim that means LowBlood (0: the class has no check)
	Array<bool> cSaw;
	Array<int> cSawSidx;        // the saw check's state index (a low-damage blood that starts past it never checks)
	Array<int> cAcsTic;         // the tic BD_CheckBloodIntensity ACTS (after the blood's own tick of that tic)
	Array<int> cSawTic;         // the tic of the saw check (HitSaw starts there)
	Array<int> cSlTic;          // the tic of the SlaughterCounter check (LowBlood starts there)
	Array<int> cSawFxTic;       // the saw's sound and quake: tics into HitSaw
	Array<String> cSawSound;
	Array<int> cQuake0;
	Array<int> cQuake1;
	Array<int> cQuake2;
	Array<int> cQuake3;
	// liquid checkers
	Array<String> cLSpot;
	Array<double> cLDist;
	Array<int> cLDelay;
	Array<int> cLFlat0;
	Array<int> cLFlatN;
	Array<TextureID> lfTex;

	// ---- particle variants (a drop's own, its splashes, a hit blood's puff)
	Array<double> vW;           // the odds of this track among its card's (BD's A_Jump branches)
	Array<int> vStart;          // the tic BD's actor first shows something
	Array<int> vLife;           // tics from vStart to BD's removal
	Array<int> vLoopFrom;       // a looping state: from this tic (relative to vStart) the track repeats every vLoopPer
	Array<int> vLoopPer;
	Array<int> vKf0;            // its keyframes
	Array<int> vKfN;
	Array<int> vGrp;            // a splash: the flight track it belongs to (BD's Death keeps the flight's scale), -1 any
	Array<int> vRoute;          // a puff: its route (R_*)
	Array<bool> vWet;           // a drop's track under water (its Spawn tests waterlevel: Underblood), else on dry land

	// ---- keyframes: one per state BD's actor enters (cards.py variant_of)
	Array<int> fTic;            // from the track's start
	Array<int> fTex;            // index into tTex, -1 hidden (a TNT1 stretch)
	Array<double> fSX;          // BD's xscale (negative: mirrored)
	Array<double> fSY;
	Array<double> fA;           // BD's alpha
	Array<bool> fBright;        // a Bright frame (else lit by its sector, as BD's sprite is)

	// ---- textures: our baked copies of BD's frames (graphics/rsqgo), by index
	Array<TextureID> tTex;

	// ---- children
	Array<int> kPath;
	Array<int> kTic;
	Array<int> kSidx;
	Array<int> kCard;
	Array<String> kCls;
	Array< Class<Actor> > kClsC;
	Array<int> kMode;
	Array<int> kCount;
	Array<int> kInterval;
	Array<int> kFlags;
	Array<bool> kAnimuSkip;
	Array<double> kR;           // NR per child

	// ---- gives (screen blood and the saw's items)
	Array<int> gPath;
	Array<int> gTic;
	Array<String> gCls;
	Array<double> gRadius;
	Array<double> gGate;        // the blood must be this far above its floor (-1: no test)
	Array<int> gFlags;          // 1 players, 2 monsters
	Array<bool> gAnimuSkip;     // level 5 skips it (AbsurdBlood after its AnimuGore jump)
	Array< Class<Inventory> > gClsC;    // gCls resolved once (Build)
	Array<bool> gScreen;        // a BloodSplasher_* players-only give: screen blood (manager QueueScreen)

	// ---- BD class name -> card (the takeover map, one read per spawn)
	Map<Name, int> byName;

	void Build()
	{
		BuildTex();
		BuildCards();
		for (int c = 0; c < cName.Size(); c++)
		{
			String cn = "RSQGO_K_" .. cName[c];
			Class<Actor> cl = cn;
			cCls.Push(cl);
			if (cl) byName.Insert(cName[c], c);
		}
		for (int k = 0; k < kCls.Size(); k++)
		{
			Class<Actor> cl = kCls[k];
			kClsC.Push(cl);
		}
		// class names resolved once, not per landing / per give (a String to Class conversion is a name lookup)
		for (int c = 0; c < cName.Size(); c++)
		{
			Class<Actor> bc = cName[c];
			cBDCls.Push(bc);
			Class<Actor> sc = cSpot[c];
			cSpotC.Push(sc);
			Class<Actor> lc = cLSpot[c];
			cLSpotC.Push(lc);
			bool dk = false;
			for (int k = cKid0[c]; k < cKid0[c] + cKidN[c]; k++) if (kPath[k] == P_DROP) { dk = true; break; }
			cDropKids.Push(dk);
		}
		for (int i = 0; i < gCls.Size(); i++)
		{
			Class<Inventory> ic = gCls[i];
			gClsC.Push(ic);
			gScreen.Push(gFlags[i] == 1 && gCls[i].Left(13) ~== "BloodSplasher");
		}
		// pure: decided once, children first (the generated order is not a dependency order, so iterate to rest)
		cPure.Clear();
		for (int c = 0; c < cName.Size(); c++) cPure.Push(PureSelf(c));
		for (int pass = 0; pass < 4; pass++)
		{
			for (int c = 0; c < cName.Size(); c++)
			{
				if (!cPure[c]) continue;
				for (int k = cKid0[c]; k < cKid0[c] + cKidN[c]; k++)
					if (kCard[k] < 0 || !cPure[kCard[k]]) { cPure[c] = false; break; }
			}
		}
		// by a variable, never a constant: ZScript compiles before DECORATE, so a constant BD class name is unknown then
		String n = "Brutal_Blood";
		Class<Actor> bd = n;
		ok = bd != null;
		n = "HasCutingWeapon";     invSaw = n;          // BD's spelling
		n = "SlaughterCounter";    invSlaughter = n;
	}

	private bool PureSelf(int c)
	{
		if (cKind[c] != K_DROP || cSpot[c] != "" || cGiveN[c] > 0) return false;
		return true;
	}

	// ---- the generated half calls these (cards.zs), in card order
	private void AddTex(String tex)
	{
		tTex.Push(TexMan.CheckForTexture(tex, TexMan.Type_Any));
	}

	private void AddCard(int kind, int cat, String bdName, double speed, double grav, bool missile, bool noclip, int style,
		String decal, String spot, int life, String landsound, double radius, bool stopmove, bool nointer = false,
		int bounce = 0, double wallbf = 0.75, double bf = 0.7, double mass = 100)
	{
		cName.Push(bdName); cKind.Push(kind); cCat.Push(cat); cSpeed.Push(speed); cGrav.Push(grav);
		cMissile.Push(missile); cNoclip.Push(noclip); cStyle.Push(style); cDecal.Push(decal); cSpot.Push(spot);
		cLife.Push(life); cLandSound.Push(landsound); cRadius.Push(radius); cStopMove.Push(stopmove);
		cNoInter.Push(nointer); cBounce.Push(bounce); cWallBF.Push(wallbf); cBF.Push(bf); cMass.Push(mass);
		cVar0.Push(vW.Size()); cVarN.Push(0);
		cSpl0.Push(vW.Size()); cSplN.Push(0);
		cWSpl0.Push(vW.Size()); cWSplN.Push(0);
		cPuff0.Push(vW.Size()); cPuffN.Push(0);
		cKid0.Push(kPath.Size()); cKidN.Push(0);
		cGive0.Push(gPath.Size()); cGiveN.Push(0);
		cSound.Push(""); cSlaughter.Push(0); cSaw.Push(false); cSawSidx.Push(-1); cAcsTic.Push(0); cSawSound.Push("");
		cSawTic.Push(0); cSlTic.Push(0); cSawFxTic.Push(0);
		cQuake0.Push(0); cQuake1.Push(0); cQuake2.Push(0); cQuake3.Push(0);
		cLSpot.Push(""); cLDist.Push(0); cLDelay.Push(0); cLFlat0.Push(lfTex.Size()); cLFlatN.Push(0);
	}

	private void AddHit(String snd, int slaughter, bool saw, int sawsidx, int acstic, String sawsound, int q0, int q1, int q2, int q3,
		int sawtic = 0, int sltic = 0, int sawfxtic = 0)
	{
		int c = cName.Size() - 1;
		cSound[c] = snd; cSlaughter[c] = slaughter; cSaw[c] = saw; cSawSidx[c] = sawsidx; cAcsTic[c] = acstic;
		cSawSound[c] = sawsound; cQuake0[c] = q0; cQuake1[c] = q1; cQuake2[c] = q2; cQuake3[c] = q3;
		cSawTic[c] = sawtic; cSlTic[c] = sltic; cSawFxTic[c] = sawfxtic;
	}

	private void AddLiquid(String spot, double dist, int delay, String flats)
	{
		int c = cName.Size() - 1;
		cLSpot[c] = spot; cLDist[c] = dist; cLDelay[c] = delay;
		Array<String> fl;
		flats.Split(fl, " ", TOK_SKIPEMPTY);
		cLFlat0[c] = lfTex.Size();
		for (int i = 0; i < fl.Size(); i++) lfTex.Push(TexMan.CheckForTexture(fl[i], TexMan.Type_Flat));
		cLFlatN[c] = fl.Size();
	}

	private int PushVar(double w, int start, int life, int loopfrom, int loopper)
	{
		vW.Push(w); vStart.Push(start); vLife.Push(life); vLoopFrom.Push(loopfrom); vLoopPer.Push(loopper);
		vKf0.Push(fTic.Size()); vKfN.Push(0); vGrp.Push(-1); vRoute.Push(0); vWet.Push(false);
		return vW.Size() - 1;
	}

	// Tracks are written grouped per card (all Var, then all Splash, then all WSplash; a hit blood's Puffs), each
	// followed by its keyframes, so every range is contiguous: a range starts where its first entry lands.
	private void AddVar(double w, int start, int life, int loopfrom, int loopper, bool wet = false)
	{
		int c = cName.Size() - 1;
		int v = PushVar(w, start, life, loopfrom, loopper);
		vWet[v] = wet;
		if (cVarN[c] == 0) cVar0[c] = v;
		cVarN[c]++;
	}

	private void AddSplash(double w, int start, int life, int loopfrom, int loopper, int grp = -1)
	{
		int c = cName.Size() - 1;
		int v = PushVar(w, start, life, loopfrom, loopper);
		vGrp[v] = grp;
		if (cSplN[c] == 0) cSpl0[c] = v;
		cSplN[c]++;
	}

	private void AddWSplash(double w, int start, int life, int loopfrom, int loopper, int grp = -1)
	{
		int c = cName.Size() - 1;
		int v = PushVar(w, start, life, loopfrom, loopper);
		vGrp[v] = grp;
		if (cWSplN[c] == 0) cWSpl0[c] = v;
		cWSplN[c]++;
	}

	private void AddPuff(double w, int start, int life, int loopfrom, int loopper, int route = 0)
	{
		int c = cName.Size() - 1;
		int v = PushVar(w, start, life, loopfrom, loopper);
		vRoute[v] = route;
		if (cPuffN[c] == 0) cPuff0[c] = v;
		cPuffN[c]++;
	}

	// a keyframe of the track written last
	private void AddKf(int tic, int tex, double sx, double sy, double a, bool isBright)
	{
		fTic.Push(tic); fTex.Push(tex); fSX.Push(sx); fSY.Push(sy); fA.Push(a); fBright.Push(isBright);
		vKfN[vW.Size() - 1]++;
	}

	private void AddKid(int path, int tic, int sidx, int card, String cls, int mode, int count, int interval, int flags, bool animuskip,
		double r0, double r1, double r2, double r3, double r4, double r5, double r6, double r7, double r8, double r9,
		double r10, double r11, double r12, double r13)
	{
		int c = cName.Size() - 1;
		kPath.Push(path); kTic.Push(tic); kSidx.Push(sidx); kCard.Push(card); kCls.Push(cls); kMode.Push(mode);
		kCount.Push(max(1, count)); kInterval.Push(interval); kFlags.Push(flags); kAnimuSkip.Push(animuskip);
		kR.Push(r0); kR.Push(r1); kR.Push(r2); kR.Push(r3); kR.Push(r4); kR.Push(r5); kR.Push(r6);
		kR.Push(r7); kR.Push(r8); kR.Push(r9); kR.Push(r10); kR.Push(r11); kR.Push(r12); kR.Push(r13);
		cKidN[c]++;
	}

	private void AddGive(int path, int tic, String cls, double radius, double gate, int flags, bool animuskip = false)
	{
		int c = cName.Size() - 1;
		gPath.Push(path); gTic.Push(tic); gCls.Push(cls); gRadius.Push(radius); gGate.Push(gate); gFlags.Push(flags);
		gAnimuSkip.Push(animuskip);
		cGiveN[c]++;
	}
}
