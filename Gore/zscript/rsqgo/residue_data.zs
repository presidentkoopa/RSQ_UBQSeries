// ============================================================================
// RSQGO_ResData -- PHASE 2's cards (the residue: floor spots, pools, footprints, ceiling spots and launchers, drip
// spawners, drips, boot smearers), as flat arrays. Filled at run time by the GENERATED half of this class
// (zscript/rsqgo/residue_cards.zs, written by Gore/tools/residue_gen.py from BD's own DECORATE), never by hand.
// Held by RSQGO_ResidueRings as a transient object: rebuilt after a load. Design: design/GORE_SYSTEM_DESIGN.md 2.2, 2.3.
//
// A card is one Brutal Doom class we take over. Every card has a name, a kind and OUR class (RSQGO_R_<name>, the
// takeover's replacement). The other arrays hold one entry per card; only the fields of the card's kind are read.
// ============================================================================

class RSQGO_ResData play
{
	enum ERKind { RK_FLOOR, RK_CEIL, RK_LAUNCH, RK_DRIPPER, RK_DRIP, RK_SMEAR }
	enum EFloorSub { SUB_SPOT, SUB_POOL, SUB_PRINT }
	// Where a floor card must stand: SNAP = it falls to the floor and stays; VANISH = BD's A_CheckFloor (off the floor
	// at its check tic it is gone; the engine clips anything within 2 units onto the floor first); MISSILE = a gravity
	// missile that explodes on landing (the growing pools): it lives only when spawned exactly on its floor, at rest.
	enum EStand { ST_SNAP, ST_VANISH, ST_MISSILE }
	const NRUN = 12;            // numbers per drip-spawner run: x, y, z, vx, vy, vz as (lo, hi)

	bool ok;                    // Brutal Doom is loaded

	// ---- every card
	Array<String> cName;
	Array<int> cKind;
	Array< Class<Actor> > cCls;         // our class (RSQGO_R_<name>), the takeover's answer
	Array< Class<Actor> > cBD;          // BD's class (spawned by name when a card leaves one)
	Array<int> cColour;                 // 0 red, 1 green, 2 blue, 3 alien (merges never cross colours)
	// ---- floor and ceiling spots
	Array<int> cSub;
	Array<double> cScale;
	Array<double> cAlpha;
	Array<int> cShowT;                  // BD's first visible tic
	Array<int> cStand;
	Array<int> cCheckT;                 // the tic BD tests the floor (A_CheckFloor)
	Array<int> cLMask;                  // liquid bits that change the outcome (residue_gen.py LQ_BITS)
	Array<int> cAcsT;
	Array<int> cLAct;                   // over such a liquid: 0 gone, 1 leaves cLCls instead
	Array<String> cLCls;
	Array<int> cSmearT;                 // the tic BD spawns its boot smearer (-1 none)
	Array<String> cSmear;
	Array<int> cSmearCard;
	Array<bool> cFace;                  // A_FaceTarget (SplatteredSmall)
	Array<bool> cWaterGone;             // BD's A_JumpIf(waterlevel > 1, "Splash"): spawned under water, it is gone
	Array<bool> cMissile;               // BD's class is +MISSILE: a smearer it spawns takes its originator from target
	Array<double> cCoverLo;             // the blood's radius on the floor (smallest frame), map units
	Array<double> cCoverHi;             // ... largest frame
	Array<int> cFr0;
	Array<int> cFrN;
	Array<double> frW;                  // frame odds (labels V0..Vn of our class)
	Array<int> cRamp0;
	Array<int> cRampN;
	Array<int> rpT;                     // the pool's grow ramp: tic, scale
	Array<double> rpS;
	Array<int> cKid0;
	Array<int> cKidN;
	Array<int> kdT;                     // what a ceiling spot leaves: tic, class
	Array<String> kdCls;
	Array<int> kdCard;
	// ---- ceiling launchers
	Array<int> cLife;
	Array<double> cSpeed;
	Array<double> cGrav;
	Array<String> cSpot;
	Array<int> cSpotCard;
	Array<int> cSpotT;
	Array<bool> cBounce;
	// ---- drip spawners
	Array<int> cRun0;
	Array<int> cRunN;
	Array<String> ruCls;
	Array<int> ruCard;
	Array<int> ruMode;                  // 0 A_SpawnItemEx (offsets, velocity), 1 A_SpawnItem (distance, height)
	Array<int> ruT;
	Array<int> ruCount;
	Array<int> ruInterval;
	Array<double> ruR;                  // NRUN per run
	// ---- drips
	Array<double> cKeep;                // the share BD lets live (A_Jump(230, "NoSpawn") keeps 26/256)
	Array<String> cDSpot;               // the floor spot it leaves where it lands ("" none)
	Array<String> cDSound;
	Array<int> cLookFall;
	Array<int> cLookSplash;
	Array<double> cDSX;                 // BD's drip scale (a VisualThinker draws its frames as BD's sprite)
	Array<double> cDSY;
	Array<int> cDStyle;                 // BD's render style (ERenderStyle)
	Array<int> cSplashLife;
	Array<String> cWKid;                // what it spawns when spawned under water (BD's Splash state)
	// ---- smearers
	Array<int> cLookT;
	Array<int> cFirst;
	Array<int> cPeriod;
	Array<int> cCount;
	Array<int> cChase;                  // A_Chase tics from a lock to the first check (See: Red 2, Blue/Green/Alien 1)
	Array<double> cDist;
	Array<String> cItem;
	Array< Class<Inventory> > cItemC;
	Array<int> cAmount;

	// ---- drip looks (TEXTURES.residue: BD's untranslated frames): frames lFr0.. lFrN, each a texture and BD's tics
	Array<int> lFr0;
	Array<int> lFrN;
	Array<TextureID> lfTex;
	Array<int> lfTics;
	// ---- BD's liquid floors (SPLASH.acs BD_CheckIfOverLiquid)
	Array<TextureID> lqTex;
	Array<int> lqBit;

	Map<Name, int> byName;              // BD class name -> card (the takeover map, one read per spawn)

	void Build()
	{
		BuildCards();
		for (int c = 0; c < cName.Size(); c++)
		{
			String cn = "RSQGO_R_" .. cName[c];
			Class<Actor> cl = cn;
			cCls.Push(cl);
			Class<Actor> bd = cName[c];
			cBD.Push(bd);
			if (cl && bd) byName.Insert(cName[c], c);
		}
		for (int c = 0; c < cName.Size(); c++)
		{
			cSmearCard[c] = CardOf(cSmear[c]);
			cSpotCard[c] = CardOf(cSpot[c]);
			Class<Inventory> ic = cItem[c];
			cItemC.Push(ic);
		}
		for (int k = 0; k < kdCls.Size(); k++) kdCard.Push(CardOf(kdCls[k]));
		for (int k = 0; k < ruCls.Size(); k++) ruCard.Push(CardOf(ruCls[k]));
		// by a variable, never a constant: ZScript compiles before DECORATE
		String n = "Brutal_Blood";
		Class<Actor> b = n;
		ok = b != null;
	}

	int CardOf(String n)
	{
		if (n == "") return -1;
		int c;
		bool has;
		[c, has] = byName.CheckValue(n);
		return has ? c : -1;
	}

	int LiquidBit(TextureID t)
	{
		for (int i = 0; i < lqTex.Size(); i++) if (lqTex[i] == t) return lqBit[i];
		return 0;
	}

	// ---- the generated half calls these (residue_cards.zs), in card order
	private void AddCard(String n, int kind, int colour)
	{
		cName.Push(n); cKind.Push(kind); cColour.Push(colour);
		cSub.Push(0); cScale.Push(1); cAlpha.Push(1); cShowT.Push(0); cStand.Push(0); cCheckT.Push(0); cLMask.Push(0);
		cAcsT.Push(0); cLAct.Push(0); cLCls.Push(""); cSmearT.Push(-1); cSmear.Push(""); cSmearCard.Push(-1);
		cFace.Push(false); cWaterGone.Push(false); cMissile.Push(false); cCoverLo.Push(0); cCoverHi.Push(0);
		cFr0.Push(frW.Size()); cFrN.Push(0); cRamp0.Push(rpT.Size()); cRampN.Push(0); cKid0.Push(kdT.Size()); cKidN.Push(0);
		cLife.Push(0); cSpeed.Push(0); cGrav.Push(1); cSpot.Push(""); cSpotCard.Push(-1); cSpotT.Push(0); cBounce.Push(false);
		cRun0.Push(ruCls.Size()); cRunN.Push(0);
		cKeep.Push(1); cDSpot.Push(""); cDSound.Push(""); cLookFall.Push(-1); cLookSplash.Push(-1); cDSX.Push(1);
		cDSY.Push(1); cDStyle.Push(STYLE_Normal); cSplashLife.Push(0); cWKid.Push("");
		cLookT.Push(0); cFirst.Push(0); cPeriod.Push(8); cCount.Push(0); cChase.Push(1); cDist.Push(0); cItem.Push(""); cAmount.Push(0);
	}

	private void AddLiquid(String flat, int bit)
	{
		lqTex.Push(TexMan.CheckForTexture(flat, TexMan.Type_Flat));
		lqBit.Push(bit);
	}

	private void AddLook()
	{
		lFr0.Push(lfTex.Size());
		lFrN.Push(0);
	}

	private void AddLookFrame(String tex, int tics)
	{
		lfTex.Push(TexMan.CheckForTexture(tex, TexMan.Type_Any));
		lfTics.Push(max(1, tics));
		lFrN[lFrN.Size() - 1]++;
	}

	private void AddFloor(String n, int sub, int colour, double scale, double alpha, int showt, int stand, int checkt,
		int lmask, int acst, int lact, int smeart, String smear, String lcls, bool face, double coverlo, double coverhi,
		bool watergone, bool missile)
	{
		AddCard(n, RK_FLOOR, colour);
		int c = cName.Size() - 1;
		cSub[c] = sub; cScale[c] = scale; cAlpha[c] = alpha; cShowT[c] = showt; cStand[c] = stand; cCheckT[c] = checkt;
		cLMask[c] = lmask; cAcsT[c] = acst; cLAct[c] = lact; cSmearT[c] = smeart; cSmear[c] = smear; cLCls[c] = lcls;
		cFace[c] = face; cCoverLo[c] = coverlo; cCoverHi[c] = coverhi; cWaterGone[c] = watergone;
		cMissile[c] = missile;
	}

	private void AddCeil(String n, int colour, double scale, double alpha, int showt, double coverlo, double coverhi,
		bool watergone)
	{
		AddCard(n, RK_CEIL, colour);
		int c = cName.Size() - 1;
		cScale[c] = scale; cAlpha[c] = alpha; cShowT[c] = showt; cCoverLo[c] = coverlo; cCoverHi[c] = coverhi;
		cWaterGone[c] = watergone;
	}

	private void AddFrame(double w)
	{
		int c = cName.Size() - 1;
		if (cFrN[c] == 0) cFr0[c] = frW.Size();
		frW.Push(w);
		cFrN[c]++;
	}

	private void AddRamp(int t, double s)
	{
		int c = cName.Size() - 1;
		if (cRampN[c] == 0) cRamp0[c] = rpT.Size();
		rpT.Push(t); rpS.Push(s);
		cRampN[c]++;
	}

	private void AddKid(int t, String cls)
	{
		int c = cName.Size() - 1;
		if (cKidN[c] == 0) cKid0[c] = kdT.Size();
		kdT.Push(t); kdCls.Push(cls);
		cKidN[c]++;
	}

	private void AddLauncher(String n, int life, double speed, double grav, String spot, int spott, bool bounce,
		bool watergone)
	{
		AddCard(n, RK_LAUNCH, 0);
		int c = cName.Size() - 1;
		cLife[c] = life; cSpeed[c] = speed; cGrav[c] = grav; cSpot[c] = spot; cSpotT[c] = spott; cBounce[c] = bounce;
		cWaterGone[c] = watergone;
	}

	private void AddDripper(String n, int life)
	{
		AddCard(n, RK_DRIPPER, 0);
		cLife[cName.Size() - 1] = life;
	}

	private void AddRun(String cls, int mode, int t, int count, int interval, double r0, double r1, double r2, double r3,
		double r4, double r5, double r6, double r7, double r8, double r9, double r10, double r11)
	{
		int c = cName.Size() - 1;
		if (cRunN[c] == 0) cRun0[c] = ruCls.Size();
		ruCls.Push(cls); ruMode.Push(mode); ruT.Push(t); ruCount.Push(max(1, count)); ruInterval.Push(interval);
		ruR.Push(r0); ruR.Push(r1); ruR.Push(r2); ruR.Push(r3); ruR.Push(r4); ruR.Push(r5);
		ruR.Push(r6); ruR.Push(r7); ruR.Push(r8); ruR.Push(r9); ruR.Push(r10); ruR.Push(r11);
		cRunN[c]++;
	}

	private void AddDrip(String n, int colour, double keep, double grav, double alpha, String spot, String snd, int lookfall,
		int looksplash, double sx, double sy, int splashlife, String wkid, int style)
	{
		AddCard(n, RK_DRIP, colour);
		int c = cName.Size() - 1;
		cKeep[c] = keep; cGrav[c] = grav; cAlpha[c] = alpha; cDSpot[c] = spot; cDSound[c] = snd; cLookFall[c] = lookfall;
		cLookSplash[c] = looksplash; cDSX[c] = sx; cDSY[c] = sy; cSplashLife[c] = splashlife;
		cWKid[c] = wkid; cDStyle[c] = style;
	}

	private void AddSmear(String n, int lookt, int first, int period, int count, double dist, String item, int amount,
		int chase)
	{
		AddCard(n, RK_SMEAR, 0);
		int c = cName.Size() - 1;
		cLookT[c] = lookt; cFirst[c] = first; cPeriod[c] = max(1, period); cCount[c] = count; cDist[c] = dist;
		cItem[c] = item; cAmount[c] = amount; cChase[c] = max(0, chase);
	}
}
