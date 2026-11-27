// ============================================================================
// RSQ_Miniboss -- THE BOSS KIOSK (design/KIOSK.md, owner 2026-11-16 04:47-04:52). The look: design/mockups/kiosk/
// kiosk_TARGET.png (his pick) and kiosk_lucky_anim.gif (the motion). Art: tools/gen_kiosk.py.
//
//   THE DROP      a Boss won (tierup.zs TierUpOnKill: the miniboss of a called-in fight killed by a player) drops the kiosk
//                 where it died, beside RSQ Score's 1UP crate, IN PLACE OF ITS ONE LEGENDARY WEAPON: BD22 VR Reloaded is
//                 told by name (RSLD_KioskService "kiosk.take"), and that drop is not made. Only when every part is here:
//                 Boss Kiosk on (rsqmb_kiosk), BD22 VR Reloaded's kiosk service ready (it needs LegenDoom 3.0), RSQ Score's
//                 bank (RS_ScoreService). Otherwise nothing changes: the Boss drops its legendary as before.
//   THE OFFERS    three legendary weapons rolled by BD22 VR Reloaded at the Boss's tier (RSLD_KioskService "roll": its
//                 TierRarity, the Boss's own drop's roll), each on its own gun, priced by rarity (rsqmb_kiosk_price_*).
//                 ONLY GUNS YOU ALREADY HAVE (owner 2026-11-22: "the kiosk should not offer any weapon we do not already
//                 have ... the point of it was to allow the player to choose a kind of LD effect for a current weapon,
//                 not get a plasma or bfg way ahead of schedule"): an offer whose gun the buyer does not carry is passed
//                 over (BD22 VR Reloaded's "yours", its third field). From BD22 VR 2.0.5f (owner 2026-11-22 "Yes, count
//                 the family") that field counts the gun's family: the starting Rifle for a Chaingun offer, the Silvergun
//                 for a Pistol one, the Purist / Dual copies (RSLD_Handler.OwnsGun or OwnsFamily); before 2.0.5f only
//                 the gun itself, so with only the starting guns no offer rolled.
//                 Fewer guns than offers: a second, different effect on a gun you have; still too few: fewer offers.
//                 The Big Boss's five Epic offers follow the same rule (EpicRoll). No gun of yours rolls one: no kiosk,
//                 the Boss's own drop as before.
//   NO SIGN       (owner 2026-11-23) the sign over the counter is gone; the whole kiosk shrinks from the floor to fit under a
//                 low ceiling (FitScale).
//   OPENING       the player within Kiosk Range (3 m) who has stood still Kiosk Wait (2 s): the offers, prices and the
//                 card pop in (never mid-fight: you have to stop, and while a Boss fight lands or runs it stays shut). Walk away (0.75 m past the range): it folds away. It
//                 stays until the map ends. Closed, it is the counter.
//   BUYING        point a hand at an offer (or touch it): its card pops in (the gun, rarity, effect, what you hold on that
//                 gun now); pull that hand's trigger: bought if the bank holds the price (RS_ScoreService "gold.spend"),
//                 then made by BD22 VR Reloaded as the real legendary and handed over ("give"). As many as you can afford,
//                 each once. While a hand points at an offer, its trigger is the kiosk's (the gun does not fire).
//   THE STRIP     (owner 2026-11-22) the counter's bottom third, while open: your gun's legendary effect beside the offer's
//                 (the gun, each side's rarity and effect, TIER UP / DOWN, NEW / SWAP EFFECT, and the effects' numbers,
//                 yours -> the offer's, from BD22 VR 2.0.5f's "stats" / "yours.stats"; a behaviour with no number: its
//                 short description), for the offer the card shows, else the first one not sold (StripTick).
//   LUCKY         that hand's ALT FIRE on an offer: one Score life spent (RS_ScoreService "life.spend") raises its rarity
//                 a step (RSLD_KioskService "raise"); once per kiosk, never past Epic (a Boss kiosk: never past Rare, 2026-11-25). The life spent here is not a lost
//                 Boss fight (LossTick knows the kiosk's tic).
//   THE VR UI     the Series' Wheel pattern (wr_Rig aimPos / aimDir, wr_Keybind, InputProcess -> a network event): either
//                 hand's ray, from QuestZDoom's hand poses (AttackPos / OffhandPos), against the offers' boxes in the
//                 kiosk's plane; a hand inside a box counts too. A dotted beam runs from the pointing hand to the offer.
//   HOW IT IS DRAWN  sprites, as the owner's in-engine target was (kiosk_TARGET.png, a sprite render): pre-made panels and
//                 one sprite a letter, laid out in the kiosk's plane, which turns to face the player when it opens. EVERY
//                 WORD AND NUMBER IS THE OWNER'S SOTN LETTERS (owner 2026-11-16 06:30: "what I liked the most"): his word
//                 sheet cut into letters with their two tones (tools/gen_kiosk.py), with the mockup's motion
//                 (kiosk_anim.py): the gold words shimmer through three shades, the card pops and its rows come in one by
//                 one, a Score life flies to the offer on LUCKY, and LUCKY! then the new rarity land, rise and fade. The guns are their own pickup sprites (BD_VoxelPack's voxels where loaded), turning.
//   REPAIR        (design/WEAPON_CONDITION.md, owner 2026-11-16) with RSQ Gun Cards' Weapon Condition on and a gun worn: a
//                 REPAIR button on the counter, left of LUCKY, with its price: every gun he carries back to 100 for
//                 Repair Gold per Point (1) a missing condition point, at least Repair Minimum (10) gold. Point at it and
//                 pull the trigger (RS_ScoreService "gold.spend", then RSQGC_Service "cnd.fix", by name).
//   THE LOG       Kiosk Log (rsqmb_kiosk_log): the drop (offers, prices, the bank, the gold earned since the last Boss win),
//                 opening and closing, every purchase, LUCKY, every repair and every refusal.
// Player-facing words say Boss. Rig only, not headset-confirmed.
// ============================================================================

class RSQMB_KPart : Actor
{
	Default
	{
		+NOINTERACTION
		+NOGRAVITY
		+NOBLOCKMAP
		+DONTSPLASH
		+NOTONAUTOMAP
		+NOTIMEFREEZE
		+BRIGHT
		RenderStyle "Translucent";
		Alpha 1.0;
		Radius 1;
		Height 1;
	}
	States
	{
	Spawn:
		TNT1 A -1;      // RSQMB_Kiosk sets the sprite and frame; a -1 state never resets them
		Stop;
	// every kiosk sprite named once, so the engine loads it (never entered)
	Names:
		KQHD A 0; KQCD A 0; KQPP A 0; KQCT A 0; KQCL A 0; KQGL A 0; KQFL A 0; KQDT A 0; KQLF A 0;
		KQW0 A 0; KQW1 A 0; KQN0 A 0; KQN1 A 0; KQD0 A 0; KQD1 A 0; KQY0 A 0; KQY1 A 0; KQG0 A 0; KQG1 A 0;
		KQB0 A 0; KQB1 A 0; KQP0 A 0; KQP1 A 0; KQO0 A 0; KQO1 A 0; KQC0 A 0; KQC1 A 0; KQR0 A 0; KQR1 A 0;
		KQY2 A 0; KQY3 A 0; KQY4 A 0; KQY5 A 0;
		Stop;
	}
}

// the anchor RSQ VisualRewards' words stand on (SOLD!, LUCKY!, the new rarity), left at an offer for a few seconds
class RSQMB_KWordSpot : Actor
{
	int life;
	Default { Radius 1; Height 8; +NOINTERACTION; +NOBLOCKMAP; +NOGRAVITY; +NOTIMEFREEZE; RenderStyle "None"; }
	override void Tick() { if (--life <= 0) Destroy(); }
	States { Spawn: TNT1 A -1; Stop; }
}

class RSQMB_Kiosk : Actor
{
	// ---- the layout, in the mockup's pixels (kiosk_anim.py: a 540 canvas; the counter's top at y 292, its middle x 271)
	const K = 0.20;           // map units a mockup pixel
	const CT = 34.0;          // the counter's top, map units above the floor (about a metre)
	const SMALLK = 0.27;      // map units a SOTN pixel, small words (1.35 x the mockup's, for reading in the headset)
	const BIGK = 0.50;        // map units a SOTN pixel, the big gold words (KIOSK, prices, LUCKY: the mockup's twice-size)
	const POPT = 2;           // tics a frame of the pop (PRESENTATION_GUIDE.md 2: 0.2 -> 1.35 -> 1.0 over 4 frames)

	enum EGroup { G_BASE, G_OFF0, G_OFF1, G_OFF2, G_OFF3, G_OFF4, G_CARD, G_NOTE, G_BEAM, G_FX, G_WORD, G_STRIP, G_NUM }
	const NOFF = 5;           // the most offers a kiosk holds (a Big Boss's: 5; a Boss's: 3)
	const BOSS_OFFERS = 3;
	const BIG_OFFERS = 5;     // owner 2026-11-16 09:5x: "5 Epic offers (no LUCKY)"
	const B_LUCKY = 8;        // what a hand points at besides an offer (0 .. NOFF-1): the LUCKY button ...
	const B_REPAIR = 9;       // ... and the REPAIR button

	// ---- the offers
	Array<String> offer;      // "slot|rarity|effect" (RSLD_KioskService)
	Array<int> price;
	Array<int> rarity;
	Array<bool> sold;
	Array<String> gunCls;
	bool luckyUsed;
	bool luckyArmed;          // the LUCKY button was pulled: the next trigger on an offer is LUCKY, not a purchase
	int tier;                 // the Boss's tier as BD22 VR counts it (1 = the first)
	bool big;                 // a BIG BOSS's kiosk (bigboss.zs): every offer Epic, no LUCKY (nothing to raise)
	String bossName;

	// ---- the state
	Vector3 home;             // on the floor
	// FITS UNDER THE CEILING (owner 2026-11-23 06:54): the whole kiosk scaled from the floor by this (1: as drawn) so its
	// highest part, the open offer card (TOP map units, with its pop's overshoot), stays CEIL_GAP under the lowest ceiling
	// within FIT_R of its spot (it turns to face you, so the ring, not one line); never under KS_MIN
	double ceilFit;
	const TOP = 80.0;
	const CEIL_GAP = 4.0;
	const FIT_R = 32.0;
	const KS_MIN = 0.35;
	double FitScale()
	{
		double low = ceilingz;
		for (int a = 0; a < 360; a += 45)
		{
			Vector2 at = pos.xy + (cos(a), sin(a)) * FIT_R;
			Sector sc = level.PointInSector(at);
			if (sc) low = min(low, sc.ceilingplane.ZatPoint(at));
		}
		double room = low - floorz - CEIL_GAP;
		return clamp(room / TOP, KS_MIN, 1.0);
	}
	double fy;                // facing: from the kiosk toward the customer
	bool open;
	int openTic, closeTic;
	int stillTics;
	Vector2 stillAt;
	Actor customer;
	int hover[2];             // the offer each hand points at, -1 none
	Vector3 hitA, hitB;       // where each hand's ray meets the offer
	Vector3 HitAt(int h) { return h ? hitB : hitA; }
	void SetHit(int h, Vector3 v) { if (h) hitB = v; else hitA = v; }
	int cardFor, cardTic;     // the offer the card shows, -1 none; the tic it popped
	int sel;                  // the offer last hovered (the card stays on it a moment)
	int selTic;
	String noteSig, cardSig, readSig;
	int stripFor;             // the offer the comparison strip shows, -1 none
	String stripSig;          // what it was built from (the offer, sold, BD22 VR's "yours")
	int stripPoll;            // the next tic it asks BD22 VR's "yours" again for the same offer
	int flashOffer, flashTic, denyOffer, denyTic;
	bool built;

	// ---- the parts
	Array<RSQMB_KPart> parts;
	Array<double> pX, pZ, pD, pS, pSY;   // local offsets (right, up, toward the player), base scale (x, y)
	Array<int> pG;                       // group
	Array<int> pSprA, pSprB, pSprC;      // the SOTN shimmer's three shades (gold), pSprB 0 none; pSprC -3: blink with pSprB
	Array<int> pShow;                    // the tic a part first shows (the card's rows come in one by one), 0 at once
	Array<double> pA;                    // base alpha
	double gS[G_NUM];                    // each group's pop scale
	double gCX[G_NUM], gCZ[G_NUM];       // its middle (what it scales about)
	double gAlpha[G_NUM];
	int gPop[G_NUM];                     // the tic its pop began (0 none)
	int gGone[G_NUM];                    // the tic it began to fold away (0 none)
	double gRise[G_NUM];                 // map units it has risen (the words)
	int revealUntil;                     // the last tic a part is waiting to show
	int wordT0;                          // the word on now began (0 none)
	Array<String> wordQ; Array<String> wordC; Array<int> wordAt; Array<double> wordX;   // the words to come
	RSQMB_KPart pip;                     // the Score life flying to an offer (LUCKY)
	Vector3 pipFrom;
	int pipT0, luckyFx;
	RSQMB_KPart gun[NOFF];
	RSQMB_KPart beam[8];
	bool dirty;
	double lastFy;
	int layTic;

	Default
	{
		+NOINTERACTION
		+NOGRAVITY
		+NOBLOCKMAP
		+DONTSPLASH
		+NOTIMEFREEZE
		Radius 24;
		Height 64;
		RenderStyle "None";
	}
	States { Spawn: TNT1 A -1; Stop; }

	static clearscope double CF(Name n, double fb) { let c = CVar.FindCVar(n); return c ? c.GetFloat() : fb; }
	static clearscope int CIK(Name n, int fb) { let c = CVar.FindCVar(n); return c ? c.GetInt() : fb; }
	static clearscope bool LogOn() { return CIK('rsqmb_kiosk_log', 0) != 0 || CIK('rsqmb_debug', 0) != 0; }
	static clearscope bool Photo() { return RSQMB_A11y.Photo(); }

	// (performance, 2026-11-27) RSQMB_Lookup, not the engine's ServiceIterator.Find: the same matches in the same order
	// (lookup.zs), found once. An open kiosk asks Bank / Cards / Legend several times every tic (Note, CardKey, InBox's
	// RepairCost for each hand), about 0.01 ms a raw lookup.
	static Service Svc(String n)
	{
		let it = RSQMB_Lookup.Find(Name(n));
		Service s;
		while (s = it.Next()) if (s.GetClassName() == n) return s;
		return null;
	}
	static Service Legend() { return Svc("RSLD_KioskService"); }
	static Service Bank() { return Svc("RS_ScoreService"); }
	static Service Cards() { return Svc("RSQGC_Service"); }

	// REPAIR (Weapon Condition, RSQ Gun Cards): the condition points missing over every gun he carries, and their price;
	// 0, 0 when Weapon Condition is off, Gun Cards is not loaded or nothing is worn
	static int, int RepairCost(Actor who)
	{
		let c = Cards();
		if (!c || !who || c.GetInt("cnd.on") != 1) return 0, 0;
		int worn = c.GetInt("cnd.worn", "", 0, 0, who);
		if (worn <= 0) return 0, 0;
		int pr = max(max(0, CIK('rsqmb_kiosk_repair_min', 10)), int(ceil(worn * max(0.0, CF('rsqmb_kiosk_repair_per', 1.0)))));
		return worn, pr;
	}

	static int PriceOf(int r)
	{
		switch (r)
		{
		case 0: return max(0, CIK('rsqmb_kiosk_price_common', 150));
		case 1: return max(0, CIK('rsqmb_kiosk_price_uncommon', 250));
		case 2: return max(0, CIK('rsqmb_kiosk_price_rare', 500));
		}
		return max(0, CIK('rsqmb_kiosk_price_epic', 900));
	}
	static String RarName(int r) { static const String N[] = { "COMMON", "UNCOMMON", "RARE", "EPIC" }; return N[clamp(r, 0, 3)]; }
	static String RarCol(int r) { static const String C[] = { "G", "B", "P", "O" }; return C[clamp(r, 0, 3)]; }
	static int RarRGB(int r) { static const int C[] = { 0x5AE65A, 0x5A96FF, 0xC86EFF, 0xFFA028 }; return C[clamp(r, 0, 3)]; }

	// ================================================================ making one
	static RSQMB_Kiosk Drop(Actor boss, int bossTier, Actor killer, bool big = false)
	{
		let lg = Legend();
		if (!lg || lg.GetInt("ready", "", 0, 0, null) != 1 || !Bank() || !boss) return null;
		int t = bossTier + 1;
		Actor buyer = Buyer(killer);
		String all = big ? EpicRoll(lg, t, buyer) : OwnedRoll(lg, t, buyer);
		Array<String> o; all.Split(o, ";");
		if (o.Size() == 0 || all == "") return null;
		// beside the 1UP crate (which is on the death spot): a step to the side of the line from the killer, the side
		// with room; on the spot itself when neither side has
		Vector3 at = boss.pos;
		double ang = killer ? killer.AngleTo(boss) : boss.angle;
		for (int side = 0; side < 3; side++)
		{
			if (side == 2) { at = boss.pos; break; }
			double a = ang + (side == 0 ? 90 : -90);
			FLineTraceData tr;
			boss.LineTrace(a, 120, 0, TRF_THRUACTORS, 24, 0, 0, tr);
			if (tr.HitType == TRACE_HitNone || tr.Distance >= 112) { at = boss.Vec3Angle(72, a, 0); break; }
		}
		let k = RSQMB_Kiosk(Actor.Spawn("RSQMB_Kiosk", at, NO_REPLACE));
		if (!k) return null;
		k.SetZ(k.floorz);
		k.home = k.pos;
		k.ceilFit = k.FitScale();
		if (k.LogOn() && k.ceilFit < 1.0) Console.Printf("RSQMB kiosk: %d map units under the ceiling here: drawn at x%.2f", int(k.ceilingz - k.floorz), k.ceilFit);
		k.tier = t;
		k.big = big;
		k.fy = killer ? k.AngleTo(killer) : 0;
		k.lastFy = k.fy;
		k.cardFor = -1; k.sel = -1; k.stripFor = -1;
		k.hover[0] = -1; k.hover[1] = -1;
		for (int i = 0; i < o.Size() && i < (big ? BIG_OFFERS : BOSS_OFFERS); i++)
		{
			int r = 0;
			Array<String> f; o[i].Split(f, "|");
			if (f.Size() >= 2) r = f[1].ToInt();
			k.offer.Push(o[i]);
			k.rarity.Push(r);
			k.price.Push(PriceOf(r));
			k.sold.Push(false);
			k.gunCls.Push(lg.GetString("class", o[i], 0, 0, null));
		}
		// the drop is the kiosk's now: BD22 VR Reloaded does not make the Boss's own legendary
		lg.GetInt("kiosk.take", "", 0, 0, boss);
		k.Build();
		if (LogOn())
		{
			String l = "";
			for (int i = 0; i < k.offer.Size(); i++)
				l = l .. String.Format("%s[%s %s %s %d G]", i ? " " : "", lg.GetString("gun", k.offer[i], 0, 0, null), RarName(k.rarity[i]),
					lg.GetString("effect", k.offer[i], 0, 0, null), k.price[i]);
			let bk = Bank();
			int bank = (bk && killer) ? bk.GetInt("gold", "", 0, 0, killer) : -1;
			Console.Printf("RSQMB kiosk t%d: dropped at %.0f %.0f for a tier %d Boss (%s); bank %d G; offers %s", level.maptime, k.home.x, k.home.y, t,
				boss.GetClassName(), bank, l);
		}
		return k;
	}

	// THE BUYER the offers are rolled for: the player who killed the Boss, else the first player in the game
	static Actor Buyer(Actor killer)
	{
		if (killer && killer.player) return killer;
		for (int i = 0; i < MAXPLAYERS; i++) if (playeringame[i] && players[i].mo) return players[i].mo;
		return null;
	}
	// an offer's slot and effect ("slot|rarity|effect"); -1, "" for a broken one
	static int OfferSlot(String of)
	{
		Array<String> f; of.Split(f, "|");
		return f.Size() >= 3 ? f[0].ToInt() : -1;
	}
	static String OfferEffect(String of)
	{
		Array<String> f; of.Split(f, "|");
		return f.Size() >= 3 ? f[2] : "";
	}
	// the buyer carries that offer's gun: BD22 VR Reloaded's "yours" ("<rarity>|<effect title>|<owns the gun 0/1>")
	static bool Owned(Service lg, String of, Actor who)
	{
		if (!lg || !who || of == "") return false;
		String y = lg.GetString("yours", of, 0, 0, who);
		Array<String> f; y.Split(f, "|");
		return f.Size() >= 3 && f[2].ToInt() == 1;
	}
	// got already holds this effect on this slot
	static bool HasEffect(Array<String> got, int sl, String eff)
	{
		for (int i = 0; i < got.Size(); i++) if (OfferSlot(got[i]) == sl && OfferEffect(got[i]) ~== eff) return true;
		return false;
	}

	// A BOSS'S THREE OFFERS ON GUNS THE BUYER HAS (owner 2026-11-22). BD22 VR Reloaded rolls them as before ("roll" at the
	// fight's tier, six at a time on six different guns, so a few rolls see every gun); an offer on a gun he does not carry
	// is passed over. Each offer on its own gun where he has enough guns; too few, a second, different effect on a gun he has
	// (as many as it takes); still too few, fewer offers. Up to eight rolls; "" when no gun of his rolled one.
	static String OwnedRoll(Service lg, int t, Actor who)
	{
		Array<String> got, spare;
		Array<int> slots;
		for (int tries = 0; tries < 8 && got.Size() < BOSS_OFFERS; tries++)
		{
			// A BOSS KIOSK STOPS AT PURPLE, ITS ODDS CLIMBING WITH THE COLOUR (owner 2026-11-25; orange is the Big Boss's):
			// BD22 VR Reloaded's "roll.kiosk" (2.0.5w); an older one answers "" to it, so "roll" and its Epic offers passed over
			String all = lg.GetString("roll.kiosk", "", 6, t, null);
			if (all == "") all = lg.GetString("roll", "", 6, t, null);
			Array<String> o; all.Split(o, ";");
			for (int i = 0; i < o.Size() && got.Size() < BOSS_OFFERS; i++)
			{
				String of = o[i];
				Array<String> rf; of.Split(rf, "|");
				if (rf.Size() >= 2 && rf[1].ToInt() >= 3) continue;
				int sl = OfferSlot(of);
				if (sl < 0 || !Owned(lg, of, who)) continue;
				if (slots.Find(sl) == slots.Size()) { slots.Push(sl); got.Push(of); }
				else if (!HasEffect(spare, sl, OfferEffect(of))) spare.Push(of);   // another effect on a gun already offered
			}
		}
		for (int i = 0; i < spare.Size() && got.Size() < BOSS_OFFERS; i++)
			if (!HasEffect(got, OfferSlot(spare[i]), OfferEffect(spare[i]))) got.Push(spare[i]);
		String res = "";
		for (int i = 0; i < got.Size(); i++) res = res .. (i ? ";" : "") .. got[i];
		if (LogOn()) Console.Printf("RSQMB kiosk: %d offer(s) on %d gun(s) the buyer carries: %s", got.Size(), slots.Size(), res != "" ? res : "none (no gun of his rolled one)");
		return res;
	}

	// THE BIG BOSS'S OFFERS (bigboss.zs; owner 11-16 08:40: "a guarenteed legendary kiosk with all epic or legendary loot"):
	// three legendaries, every one EPIC (LegenDoom's top rarity: every one is a legendary weapon already), on three different
	// guns. BD22 VR Reloaded rolls them as for a Boss ("roll", six at a time on six guns), and each is raised a step at a
	// time to Epic by its own "raise" (an effect LegenDoom rolls at Epic on that gun); a gun with no Epic effect is passed
	// over. Up to eight rolls; "" when no gun has an Epic effect (then no kiosk: the Big Boss drops its legendary).
	// ONLY GUNS THE BUYER HAS (owner 2026-11-22): an offer on a gun he does not carry is passed over before it is raised.
	static String EpicRoll(Service lg, int t, Actor who)
	{
		Array<String> got, spare;
		Array<int> slots;
		for (int tries = 0; tries < 10 && got.Size() < BIG_OFFERS; tries++)
		{
			String all = lg.GetString("roll", "", 6, max(t, 5), null);
			Array<String> o; all.Split(o, ";");
			for (int i = 0; i < o.Size() && got.Size() < BIG_OFFERS; i++)
			{
				String of = o[i];
				if (!Owned(lg, of, who)) continue;
				for (int step = 0; step < 4 && of != ""; step++)
				{
					Array<String> f; of.Split(f, "|");
					if (f.Size() < 3) { of = ""; break; }
					if (f[1].ToInt() >= 3)
					{
						int sl = f[0].ToInt();
						if (slots.Find(sl) == slots.Size()) { slots.Push(sl); got.Push(of); }
						else if (spare.Find(of) == spare.Size()) spare.Push(of);     // a second Epic on a gun already offered
						break;
					}
					of = lg.GetString("raise", of, 0, 0, null);
				}
			}
		}
		// FIVE DIFFERENT GUNS WHERE POSSIBLE (owner 11-16 09:5x): too few guns with an Epic effect, a second Epic effect on one
		// (a different one: owner 2026-11-22, several effects for the same gun, never a gun he does not have)
		for (int i = 0; i < spare.Size() && got.Size() < BIG_OFFERS; i++)
			if (!HasEffect(got, OfferSlot(spare[i]), OfferEffect(spare[i]))) got.Push(spare[i]);
		String res = "";
		for (int i = 0; i < got.Size(); i++) res = res .. (i ? ";" : "") .. got[i];
		if (LogOn()) Console.Printf("RSQMB kiosk: a Big Boss's %d offers, every one Epic, on %d different guns the buyer carries: %s", got.Size(), slots.Size(), res != "" ? res : "none (no gun of his has an Epic effect)");
		return res;
	}

	// ================================================================ the parts
	// every panel and letter is a WALL sprite turned to face the customer (flat in the kiosk's plane, as the mockup's
	// panels are): letters a little in front of their panel never sink behind it, whatever the angle (billboards did, rig
	// kq_in2: each turns to the eye on its own). The guns stay as they are (sprites or BD_VoxelPack's voxels).
	RSQMB_KPart Part(int g, String spr, int fr, double lx, double lz, double ld, double sc, double scy = 0, String sprB = "", int style = STYLE_Translucent, double alpha = 1.0, bool wall = true)
	{
		let p = RSQMB_KPart(Actor.Spawn("RSQMB_KPart", home, NO_REPLACE));
		if (!p) return null;
		p.bWallSprite = wall;
		p.angle = fy;
		int sa = GetSpriteIndex(spr);
		p.sprite = sa;
		p.frame = fr;
		p.A_SetRenderStyle(alpha, style);
		parts.Push(p);
		pX.Push(lx); pZ.Push(lz); pD.Push(ld); pS.Push(sc); pSY.Push(scy > 0 ? scy : sc);
		pG.Push(g); pSprA.Push(sprB != "" ? sa : 0); pSprB.Push(sprB != "" ? GetSpriteIndex(sprB) : 0); pSprC.Push(0);
		pShow.Push(0);
		pA.Push(alpha);
		dirty = true;
		return p;
	}

	void Clear(int g)
	{
		for (int i = parts.Size() - 1; i >= 0; i--)
		{
			if (pG[i] != g) continue;
			if (parts[i]) parts[i].Destroy();
			parts.Delete(i); pX.Delete(i); pZ.Delete(i); pD.Delete(i); pS.Delete(i); pSY.Delete(i); pG.Delete(i);
			pSprA.Delete(i); pSprB.Delete(i); pSprC.Delete(i); pShow.Delete(i); pA.Delete(i);
		}
		if (g >= G_OFF0 && g <= G_OFF4) gun[g - G_OFF0] = null;
	}

	// A LINE OF SOTN LETTERS (the owner's word sheet, tools/gen_kiosk.py), one sprite a letter, neighbours sharing one
	// outline column as the sheet's words do (sotnfont.py sotn_text). Colour c: W N D Y G B P O C R. font 1: the big gold
	// words, with the mockup's shimmer (three shades, kiosk_anim.py SH); shimmer: that shimmer on a small gold line too.
	// align 0 centre, 1 left, 2 right; k map units a SOTN pixel; delay: tics before it shows (the card's rows); blink: it
	// trades colour with white (the armed LUCKY line). Returns its width (map units).
	double Text(int g, String s, String c, int font, double x, double z, double d, double k, int align = 0, int delay = 0, bool shimmer = false, bool blink = false)
	{
		s = s.MakeUpper();
		if (font == 1) { c = "Y"; shimmer = true; }
		double w = TextW(s, 0, k);
		double sx = align == 0 ? x - w * 0.5 : (align == 1 ? x : x - w);
		int n = s.Length();
		for (int i = 0; i < n; i++)
		{
			int ch = s.ByteAt(i);
			int cw = RSQMB_KioskFont.W(ch);
			if (ch == 32 || cw == 0) { sx += 3 * k; continue; }
			int grp, fr;
			if (ch >= 65 && ch <= 90) { grp = 0; fr = ch - 65; }
			else
			{
				String G1 = "0123456789-.!%/:+?()',=&#*";
				int at = G1.IndexOf(String.Format("%c", ch));
				if (at < 0) { sx += (cw - 1) * k; continue; }
				grp = 1; fr = at;
			}
			double cx = sx + cw * k * 0.5;
			double sc = k / RSQMB_KioskFont.TEX;
			let p = Part(g, String.Format("KQ%s%d", c, grp), fr, cx, z, d, sc, 0, shimmer && c == "Y" ? String.Format("KQY%d", grp + 2) : (blink ? String.Format("KQW%d", grp) : ""));
			int last = parts.Size() - 1;
			if (shimmer && c == "Y") pSprC[last] = GetSpriteIndex(String.Format("KQY%d", grp + 4));
			if (blink) pSprC[last] = -3;
			if (delay > 0) { pShow[last] = level.maptime + delay; revealUntil = max(revealUntil, pShow[last]); if (p) p.bInvisible = true; }
			sx += (cw - 1) * k;
		}
		return w;
	}

	// a line's width in map units (Text's own measure: SOTN letters sharing their outline columns)
	static double TextW(String s, int font, double k)
	{
		s = s.MakeUpper();
		int n = s.Length();
		double w = 0;
		for (int i = 0; i < n; i++)
		{
			int ch = s.ByteAt(i);
			int cw = RSQMB_KioskFont.W(ch);
			if (ch == 32 || cw == 0) { w += 3 * k; continue; }
			w += (cw - (i < n - 1 ? 1 : 0)) * k;
		}
		return w;
	}

	// words into lines no wider than w (map units), at most max lines (the last one cut short with ..)
	static void Wrap(String s, double w, double k, int maxl, out Array<String> lines)
	{
		lines.Clear();
		Array<String> words; s.Split(words, " ");
		String ln = "";
		for (int i = 0; i < words.Size(); i++)
		{
			if (words[i] == "") continue;
			String nx = ln == "" ? words[i] : ln .. " " .. words[i];
			if (ln != "" && TextW(nx, 0, k) > w)
			{
				lines.Push(ln);
				ln = words[i];
				if (lines.Size() >= maxl) { ln = ""; break; }
			}
			else ln = nx;
		}
		if (ln != "" && lines.Size() < maxl) lines.Push(ln);
	}

	static double LX(double x) { return (x - 271) * K; }
	static double LZ(double y) { return CT + (292 - y) * K; }
	double Shrink() { return ceilFit > 0 ? ceilFit : 1.0; }   // a kiosk from a save made before FitScale: 1

	// the counter and the sign: always there
	void Build()
	{
		built = true;
		for (int g = 0; g < G_NUM; g++) { gS[g] = 1.0; gAlpha[g] = 1.0; }
		double tk = K / RSQMB_KioskFont.TEX;
		// the counter: its top edge at CT, stretched down to the floor
		Part(G_BASE, "KQCT", 0, 0, CT, 0, tk, CT / (75.0 * RSQMB_KioskFont.TEX));
		// NO SIGN (owner 2026-11-23 06:54: "kiosk needs to respect ceilings, maybe remove the KIOSK window"; his pick: drop
		// the sign, then shrink to fit): the gold-edged panel over the counter with KIOSK and BOSS TIER n - RARITY is gone
		gCX[G_BASE] = 0; gCZ[G_BASE] = CT;
		Note();
		Layout(true);
	}

	// the words on the counter's front: how to buy, LUCKY, and your gold and lives
	void Note()
	{
		bool any = false;
		for (int i = 0; i < sold.Size(); i++) if (!sold[i]) any = true;
		String l1 = !any ? "SOLD OUT" : (open ? "POINT AT AN OFFER, TRIGGER TO BUY" : "STAND STILL HERE TO SHOP");
		int gold = -1, lives = -1;
		let bk = Bank();
		if (bk && customer) { gold = bk.GetInt("gold", "", 0, 0, customer); lives = bk.GetInt("lives", "", 0, 0, customer); }
		String l2 = big ? "BIG BOSS: EVERY OFFER EPIC" : (luckyUsed ? "LUCKY USED THIS KIOSK" : (luckyArmed ? "LUCKY: NOW TRIGGER AN OFFER" : "1 LIFE = +1 RARITY, ONE PER KIOSK"));
		String l3 = gold >= 0 ? String.Format("GOLD %d G   LIVES %d", gold, max(0, lives)) : "";
		int worn, rprice;
		[worn, rprice] = RepairCost(customer);
		String sig = String.Format("%s|%s|%s|%d|%d|%d|%d|%d|%d|%d", l1, l2, l3, open, luckyArmed, hover[0] == B_LUCKY || hover[1] == B_LUCKY, worn, rprice,
			hover[0] == B_REPAIR || hover[1] == B_REPAIR, gold >= rprice);
		if (sig == noteSig) return;
		noteSig = sig;
		Clear(G_NOTE);
		double tk = K / RSQMB_KioskFont.TEX;
		Text(G_NOTE, l1, any ? "W" : "Y", 0, 0, CT - 5, 0.8, SMALLK * 0.7);
		// THE LUCKY BUTTON (point at it and pull the trigger, then pull it on an offer; or alt fire straight on an offer)
		if (open && any && !luckyUsed && !big)
		{
			bool lit = luckyArmed || hover[0] == B_LUCKY || hover[1] == B_LUCKY;
			Part(G_NOTE, "KQPP", lit ? 4 : 1, 0, LZ(LUCKY_Y), 0.6, tk * 1.6, tk * 2.2);
			Text(G_NOTE, "LUCKY", "Y", 1, 0, LZ(LUCKY_Y), 1.0, BIGK * 0.8);
		}
		// THE REPAIR BUTTON (Weapon Condition): left of LUCKY; its price under the word, red when the bank is short
		if (open && worn > 0)
		{
			bool rl = hover[0] == B_REPAIR || hover[1] == B_REPAIR;
			Part(G_NOTE, "KQPP", rl ? 4 : 0, REPAIR_X, LZ(LUCKY_Y), 0.6, tk * 1.3, tk * 2.2);
			Text(G_NOTE, "REPAIR", "W", 0, REPAIR_X, LZ(LUCKY_Y) + 1.8, 1.0, SMALLK * 1.3);
			Text(G_NOTE, String.Format("%d G", rprice), gold >= rprice ? "Y" : "R", 0, REPAIR_X, LZ(LUCKY_Y) - 2.2, 1.0, SMALLK * 1.15);
		}
		Text(G_NOTE, l2, big ? "O" : (luckyUsed ? "D" : "C"), 0, 0, CT - 17.8, 0.8, SMALLK * 0.6);   // just under LUCKY (the strip is below)
		// your gold and lives: open with offers left, on the button row right of LUCKY (the comparison strip has the
		// counter's bottom); else under the LUCKY line, as before
		if (gold >= 0 && open && any)
		{
			Text(G_NOTE, String.Format("GOLD %d G", gold), "Y", 0, GOLD_X, LZ(LUCKY_Y) + 1.7, 1.0, SMALLK * 0.85, 0, 0, true);
			Text(G_NOTE, String.Format("LIVES %d", max(0, lives)), "Y", 0, GOLD_X, LZ(LUCKY_Y) - 1.9, 1.0, SMALLK * 0.85, 0, 0, true);
		}
		else if (l3 != "") Text(G_NOTE, l3, "Y", 0, 0, CT - 25, 0.8, SMALLK * 0.8, 0, 0, true);
		gCX[G_NOTE] = 0; gCZ[G_NOTE] = CT - 14;
	}

	const LUCKY_Y = 352;      // the LUCKY button's middle on the counter's front, mockup pixels
	const REPAIR_X = -26.0;   // the REPAIR button's middle, map units right of the counter's middle (left of LUCKY)
	const GOLD_X = 25.0;      // your gold and lives while it is open, right of LUCKY (the REPAIR button's mirror)

	static const double XS[] = { 150, 270, 390 };
	// FIVE OFFERS (a Big Boss's kiosk): one row, 92 mockup pixels apart, centred on the counter; each a little smaller
	static const double XS5[] = { 87, 179, 271, 363, 455 };
	double OX(int i) { return offer.Size() > BOSS_OFFERS ? LX(XS5[clamp(i, 0, 4)]) : LX(XS[clamp(i, 0, 2)]); }
	double OHalf() { return (offer.Size() > BOSS_OFFERS ? 44 : 50) * K; }    // an offer's box, half its width
	// a line no wider than the offer's room (five offers: long effect names shrink to fit)
	double OFit(String s, double k) { double w = TextW(s, 0, k), room = OHalf() * 2 - 4 * K; return w > room ? k * room / w : k; }

	// one offer: its glow and light, the gun, the price plate, the rarity and the effect
	void BuildOffer(int i)
	{
		int g = G_OFF0 + i;
		Clear(g);
		let lg = Legend();
		double x = OX(i);
		double tk = K / RSQMB_KioskFont.TEX;
		int r = rarity[i];
		double gk = offer.Size() > BOSS_OFFERS ? 0.38 : 0.45;   // the gun's size (smaller, five abreast)
		if (!sold[i])
		{
			Part(g, "KQCL", r, x, LZ(258), 0.3, tk, 0, "", STYLE_Add, 0.55);
			Part(g, "KQGL", r, x, LZ(222), 0.5, tk, 0, "", STYLE_Add, 0.8);
			// the gun: its own pickup sprite (a voxel with BD_VoxelPack), turning
			class<Actor> gc = gunCls[i];
			let gp = Part(g, "TNT1", 0, x, LZ(222), 2.0, 1.0, 0, "", STYLE_Normal, 1.0, false);
			if (gp && gc)
			{
				let d = GetDefaultByType(gc);
				if (d.SpawnState) { gp.sprite = d.SpawnState.sprite; gp.frame = d.SpawnState.frame; }
				pS[pS.Size() - 1] = d.scale.x * gk;
				pSY[pSY.Size() - 1] = d.scale.y * gk;
				gun[i] = gp;
			}
		}
		Part(g, "KQPP", sold[i] ? 4 : r, x, LZ(252), 3, tk);
		if (sold[i]) Text(g, "SOLD", "R", 0, x, LZ(252), 4, BIGK * 0.8);
		else Text(g, String.Format("%d G", price[i]), "Y", 1, x, LZ(252), 4, BIGK * 0.8);
		Text(g, RarName(r), sold[i] ? "D" : RarCol(r), 0, x, LZ(267), 3, OFit(RarName(r), SMALLK * 0.8));
		String eff = lg ? lg.GetString("effect", offer[i], 0, 0, null) : "";
		Text(g, eff, sold[i] ? "D" : "N", 0, x, LZ(280), 3, OFit(eff, SMALLK * 0.85));
		gCX[g] = x; gCZ[g] = LZ(250);
	}

	// the compare card for offer i (THIS / YOURS)
	void BuildCard(int i, bool reveal = true)
	{
		Clear(G_CARD);
		cardFor = i;
		if (i < 0) return;
		let lg = Legend();
		if (!lg) return;
		double tk = K / RSQMB_KioskFont.TEX;
		int r = rarity[i];
		double cz = LZ(132), d = 8;
		double left = -116 * K, top = cz + 56 * K;   // the card's top left (map units)
		// THE ROWS COME IN ONE BY ONE after the card's pop (kiosk_anim.py: a row every 2 frames), on a fresh card only
		int rv = reveal ? 1 : 0;
		Part(G_CARD, "KQCD", r, 0, cz, d, tk);
		String gun = lg.GetString("gun", offer[i], 0, 0, null);
		Text(G_CARD, gun, "W", 0, left + 8 * K, top - 11 * K, d + 0.5, min(SMALLK * 1.2, 150 * K / max(1.0, TextW(gun, 0, 1.0))), 1);
		Text(G_CARD, RarName(r), RarCol(r), 0, -left - 8 * K, top - 11 * K, d + 0.5, SMALLK * 0.8, 2);
		String eff = lg.GetString("effect", offer[i], 0, 0, null);
		String desc = lg.GetString("desc", offer[i], 0, 0, null);
		Text(G_CARD, eff, "W", 0, left + 8 * K, top - 25 * K, d + 0.5, SMALLK, 1, rv * 8);
		// the description, in up to two lines across the card
		Array<String> dl;
		Wrap(desc, 214 * K, SMALLK * 0.8, 2, dl);
		for (int l = 0; l < dl.Size(); l++) Text(G_CARD, dl[l], "N", 0, left + 8 * K, top - (34 + 8 * l) * K, d + 0.5, SMALLK * 0.8, 1, rv * (10 + 2 * l));
		// THIS / YOURS
		String yours = customer ? lg.GetString("yours", offer[i], 0, 0, customer) : "";
		Array<String> y; yours.Split(y, "|");
		int yr = y.Size() >= 1 ? y[0].ToInt() : -1;
		String ye = y.Size() >= 2 ? y[1] : "";
		bool owns = y.Size() >= 3 && y[2].ToInt() == 1;
		double c1 = left + 140 * K, c2 = left + 196 * K, rz = top - 54 * K;
		Text(G_CARD, "THIS", "W", 0, c1, rz, d + 0.5, SMALLK * 0.8, 0, rv * 14);
		Text(G_CARD, "YOURS", "D", 0, c2, rz, d + 0.5, SMALLK * 0.8, 0, rv * 14);
		Text(G_CARD, "RARITY", "N", 0, left + 8 * K, rz - 9 * K, d + 0.5, SMALLK * 0.8, 1, rv * 18);
		Text(G_CARD, RarName(r), RarCol(r), 0, c1, rz - 9 * K, d + 0.5, SMALLK * 0.7, 0, rv * 18);
		Text(G_CARD, yr >= 0 ? RarName(yr) : "NONE", yr >= 0 ? RarCol(yr) : "D", 0, c2, rz - 9 * K, d + 0.5, SMALLK * 0.7, 0, rv * 18);
		Text(G_CARD, "EFFECT", "N", 0, left + 8 * K, rz - 17 * K, d + 0.5, SMALLK * 0.8, 1, rv * 22);
		Text(G_CARD, eff, "W", 0, c1, rz - 17 * K, d + 0.5, SMALLK * 0.6, 0, rv * 22);
		Text(G_CARD, ye != "" ? ye : "NONE", "D", 0, c2, rz - 17 * K, d + 0.5, SMALLK * 0.6, 0, rv * 22);
		Text(G_CARD, "GUN", "N", 0, left + 8 * K, rz - 25 * K, d + 0.5, SMALLK * 0.8, 1, rv * 26);
		Text(G_CARD, owns ? "HAVE IT" : "NEW", owns ? "D" : "G", 0, c1, rz - 25 * K, d + 0.5, SMALLK * 0.7, 0, rv * 26);
		// the bottom line: the price and how to buy, or why not
		int gold = (Bank() && customer) ? Bank().GetInt("gold", "", 0, 0, customer) : 0;
		int lives = (Bank() && customer) ? Bank().GetInt("lives", "", 0, 0, customer) : 0;
		String bl; String bc;
		if (sold[i]) { bl = "SOLD"; bc = "D"; }
		else if (luckyArmed) { bl = r < 3 ? "LUCKY: TRIGGER, 1 LIFE = +1 RARITY" : "EPIC: LUCKY CANNOT RAISE IT"; bc = r < 3 ? "C" : "D"; }
		else if (gold >= price[i]) { bl = String.Format("%d G   PULL TRIGGER TO BUY", price[i]); bc = "Y"; }
		else { bl = String.Format("%d G   NEED %d G MORE", price[i], price[i] - gold); bc = "R"; }
		Text(G_CARD, bl, bc, 0, left + 8 * K, top - 91 * K, d + 0.5, SMALLK * 0.85, 1, rv * 30, false, luckyArmed && r < 3);
		if (!sold[i] && !luckyUsed && r < 3)
			Text(G_CARD, lives > 0 ? "LUCKY: THE BUTTON BELOW, 1 LIFE" : "LUCKY: NO LIFE TO SPEND", lives > 0 ? "C" : "D", 0,
				left + 8 * K, top - 102 * K, d + 0.5, SMALLK * 0.75, 1, rv * 32);
		gCX[G_CARD] = 0; gCZ[G_CARD] = LZ(190);   // it grows out of the offers' row
		gPop[G_CARD] = level.maptime; gGone[G_CARD] = 0;
		cardTic = level.maptime;
		cardSig = CardKey(i);
	}
	String CardKey(int i)
	{
		int gold = (Bank() && customer) ? Bank().GetInt("gold", "", 0, 0, customer) : 0;
		int lives = (Bank() && customer) ? Bank().GetInt("lives", "", 0, 0, customer) : 0;
		return String.Format("%d|%s|%d|%d|%d|%d|%d|%d", i, i >= 0 ? offer[i] : "", i >= 0 ? sold[i] : 0, gold >= (i >= 0 ? price[i] : 0), lives > 0, luckyUsed, i >= 0 ? rarity[i] : 0, luckyArmed);
	}

	// ================================================================ THE COMPARISON STRIP (owner 2026-11-22)
	// The counter's bottom third, while it is open: your gun's legendary effect now beside the offer's, and what goes up and
	// down. Only what BD22 VR Reloaded's kiosk service says (by name, nothing links):
	//   the offer      "gun", "effect", "desc", its rarity, and "stats" (2.0.5f): "label|unit|value|up;..." -- the effect's
	//                  numbers as BD22 VR applies them (unit x a multiplier, 1 = the plain gun; % a chance, 0 = the plain
	//                  gun; up 1 when more is better), "" for an effect that is a behaviour with no number
	//   yours          "yours" ("<rarity>|<effect title>|<owns 0/1>", -1 and "" for a plain gun), "yours.stats" and
	//                  "yours.desc" (2.0.5f), for the effect you hold on that offer's gun
	// No number is made up here: a stat one side's effect lacks is the plain gun's (x1, 0%) where that side has numbers
	// or no effect at all; a side whose effect is only a behaviour shows its short description instead. It follows the
	// card (what a hand points at, and a second after); nothing pointed at, the first offer not sold.
	//
	//   YOURS               SUPER SHOTGUN              OFFER
	//   COMMON                TIER UP 1             UNCOMMON
	//   HOARDER'S            SWAP EFFECT             HUNTING
	//   EXTRA AMMO ON        DAMAGE UP                  X3.0
	//   PICKUP (desc)       FIRE RATE DOWN             X0.78
	const STRIP_Z = 7.7;      // its middle, map units above the floor (the counter's bottom third)
	const STRIP_W = 74.0;     // its plate (the sign's: dark, edged in gold), map units
	const STRIP_H = 14.8;
	const STRIP_COL = 22.0;   // each side's column middle, map units from the counter's middle
	const STRIP_ROOM = 24.0;  // a side's room
	const STRIP_MID = 20.0;   // the middle column's room (what changes)
	const STRIP_NROWS = 2;    // the most numbers it shows

	// a line's size, cut down to fit room (map units)
	static double FitK(String s, double k, double room) { double w = TextW(s, 0, k); return w > room ? k * room / w : k; }

	int StripOffer()
	{
		if (cardFor >= 0 && cardFor < offer.Size()) return cardFor;
		for (int i = 0; i < sold.Size(); i++) if (!sold[i]) return i;
		return -1;
	}

	void StripTick()
	{
		int i = open ? StripOffer() : -1;
		if (i < 0)
		{
			if (stripFor >= 0 && gGone[G_STRIP] == 0) gGone[G_STRIP] = level.maptime;
			stripFor = -1;
			stripSig = "";
			return;
		}
		// the same offer: BD22 VR asked again every 10 tics (a purchase or a pickup changes "yours")
		if (i == stripFor && level.maptime < stripPoll && stripSig != "") return;
		stripPoll = level.maptime + 10;
		let lg = Legend();
		if (!lg) return;
		String y = customer ? lg.GetString("yours", offer[i], 0, 0, customer) : "";
		String ys = customer ? lg.GetString("yours.stats", offer[i], 0, 0, customer) : "";
		String yd = customer ? lg.GetString("yours.desc", offer[i], 0, 0, customer) : "";
		String os = lg.GetString("stats", offer[i], 0, 0, null);
		String sig = String.Format("%d|%s|%d|%s|%s|%s", i, offer[i], sold[i], y, ys, os);
		if (sig == stripSig) return;
		bool first = stripFor < 0;
		BuildStrip(i, y, ys, yd, os);
		stripSig = sig;
		gGone[G_STRIP] = 0;
		if (first)
		{
			// it pops in after the offers (each 2 frames after the one before, OpenUp)
			int at = level.maptime - openTic < 2 ? openTic + (offer.Size() + 1) * 2 * POPT : level.maptime;
			gPop[G_STRIP] = at;
			gS[G_STRIP] = 0;
		}
		Layout(true);
		if (LogOn())
			Console.Printf("RSQMB kiosk t%d: strip on offer %d: yours \"%s\" stats \"%s\" vs %s %s stats \"%s\"", level.maptime, i, y, ys,
				RarName(rarity[i]), lg.GetString("effect", offer[i], 0, 0, null), os);
	}

	// one stat of a "label|unit|value|up;..." answer: its index, -1 none
	static int StatAt(Array<String> st, String label)
	{
		for (int i = 0; i < st.Size(); i++)
		{
			Array<String> f; st[i].Split(f, "|");
			if (f.Size() >= 4 && f[0] ~== label) return i;
		}
		return -1;
	}
	static String StatField(String one, int n)
	{
		Array<String> f; one.Split(f, "|");
		return f.Size() > n ? f[n] : "";
	}
	// a number as the strip writes it: x2.0 / x0.78, or 23%
	static String StatText(String unit, double v)
	{
		if (unit == "%") return String.Format("%d%%", int(v + 0.5));
		double t = v * 10;
		return abs(t - floor(t + 0.5)) < 0.05 ? String.Format("x%.1f", v) : String.Format("x%.2f", v);
	}

	void BuildStrip(int i, String yours, String yStats, String yDesc, String oStats)
	{
		Clear(G_STRIP);
		stripFor = i;
		let lg = Legend();
		if (!lg || i < 0 || i >= offer.Size()) return;
		double d = 0.7, dt = 1.1;
		double tex = RSQMB_KioskFont.TEX;
		Part(G_STRIP, "KQHD", 0, 0, STRIP_Z, d, STRIP_W / (148.0 * tex), STRIP_H / (38.0 * tex));
		// yours: "<rarity>|<effect title>|<owns>"; anything else, a plain gun
		Array<String> f; yours.Split(f, "|");
		int yr = f.Size() >= 3 ? f[0].ToInt() : -1;
		String ye = f.Size() >= 3 ? f[1] : "";
		int r = rarity[i];
		String gun = lg.GetString("gun", offer[i], 0, 0, null);
		String eff = lg.GetString("effect", offer[i], 0, 0, null);
		double xl = -STRIP_COL, xr = STRIP_COL;
		double top = STRIP_Z + STRIP_H * 0.5;
		double z1 = top - 1.6, z2 = top - 4.4, z3 = top - 7.2, z4 = top - 9.9, z5 = top - 12.5;
		double edge = STRIP_W * 0.5 - 2.0;
		// row 1: YOURS, the gun, OFFER (SOLD once bought)
		double k1 = SMALLK * 0.85;
		Text(G_STRIP, "YOURS", "N", 0, -edge, z1, dt, k1, 1);
		Text(G_STRIP, sold[i] ? "SOLD" : "OFFER", sold[i] ? "R" : "Y", 0, edge, z1, dt, k1, 2, 0, !sold[i]);
		Text(G_STRIP, gun, "W", 0, 0, z1, dt, FitK(gun, k1, STRIP_W - 2 * (TextW("OFFER", 0, k1) + 5.0)));
		// row 2: the rarity each side, and the tier's change
		double k2 = SMALLK * 1.15;
		String yrn = yr >= 0 ? RarName(yr) : (ye == "" ? "PLAIN" : "-");
		Text(G_STRIP, yrn, yr >= 0 ? RarCol(yr) : "N", 0, xl, z2, dt, FitK(yrn, k2, STRIP_ROOM));
		Text(G_STRIP, RarName(r), RarCol(r), 0, xr, z2, dt, FitK(RarName(r), k2, STRIP_ROOM));
		String tw; String tc;
		if (yr < 0 && ye == "") { tw = "TIER UP"; tc = "G"; }
		else if (yr < 0) { tw = ""; tc = "N"; }
		else if (r > yr) { tw = String.Format("TIER UP %d", r - yr); tc = "G"; }
		else if (r < yr) { tw = String.Format("TIER DOWN %d", yr - r); tc = "R"; }
		else { tw = "SAME TIER"; tc = "N"; }
		double km = SMALLK * 0.9;
		if (tw != "") Text(G_STRIP, tw, tc, 0, 0, z2, dt, FitK(tw, km, STRIP_MID));
		// row 3: the effect each side, and what happens to it
		double k3 = SMALLK * 1.05;
		String yen = ye != "" ? ye : "NONE";
		Text(G_STRIP, yen, ye != "" ? "W" : "N", 0, xl, z3, dt, FitK(yen, k3, STRIP_ROOM));
		Text(G_STRIP, eff, "W", 0, xr, z3, dt, FitK(eff, k3, STRIP_ROOM));
		String ew; String ec;
		if (ye == "") { ew = "NEW EFFECT"; ec = "G"; }
		else if (ye ~== eff) { ew = "SAME EFFECT"; ec = "N"; }
		else { ew = "SWAP EFFECT"; ec = "Y"; }
		Text(G_STRIP, ew, ec, 0, 0, z3, dt, FitK(ew, km, STRIP_MID));
		// rows 4 and 5: THE NUMBERS (BD22 VR 2.0.5f "stats" / "yours.stats"): yours -> the offer's, each stat's name and
		// whether it goes up or down in the middle, green when that is better (more damage, less ammo used), red when worse
		Array<String> ys, os;
		if (yStats != "") yStats.Split(ys, ";");
		if (oStats != "") oStats.Split(os, ";");
		Array<String> labels;
		for (int n = 0; n < os.Size() && labels.Size() < STRIP_NROWS; n++) labels.Push(StatField(os[n], 0));
		for (int n = 0; n < ys.Size() && labels.Size() < STRIP_NROWS; n++) if (StatAt(os, StatField(ys[n], 0)) < 0) labels.Push(StatField(ys[n], 0));
		// a side whose effect is only a behaviour (no number): its short description in its column
		bool yWords = ye != "" && ys.Size() == 0;
		bool oWords = os.Size() == 0;
		double k4 = SMALLK * 0.95, kd = SMALLK * 0.8;
		for (int n = 0; n < labels.Size(); n++)
		{
			int a = StatAt(ys, labels[n]), b = StatAt(os, labels[n]);
			String one = b >= 0 ? os[b] : ys[a];
			String unit = StatField(one, 1);
			bool upGood = StatField(one, 3).ToInt() == 1;
			double plain = unit == "%" ? 0.0 : 1.0;
			double yv = a >= 0 ? StatField(ys[a], 2).ToDouble() : plain;
			double ov = b >= 0 ? StatField(os[b], 2).ToDouble() : plain;
			bool up = ov > yv + 0.001, down = ov < yv - 0.001;
			String c = !up && !down ? "N" : ((up == upGood) ? "G" : "R");
			String mid = labels[n] .. (up ? " UP" : (down ? " DOWN" : " SAME"));
			double zn = n == 0 ? z4 : z5;
			Text(G_STRIP, mid, c, 0, 0, zn, dt, FitK(mid, km, STRIP_MID));
			if (!yWords) { String t = StatText(unit, yv); Text(G_STRIP, t, a >= 0 ? "W" : "N", 0, xl, zn, dt, FitK(t, k4, STRIP_ROOM)); }
			if (!oWords) { String t = StatText(unit, ov); Text(G_STRIP, t, c == "N" ? "W" : c, 0, xr, zn, dt, FitK(t, k4, STRIP_ROOM)); }
		}
		Array<String> dl;
		if (yWords || (labels.Size() == 0 && ye != ""))
		{
			Wrap(yDesc != "" ? yDesc : ye, STRIP_ROOM, kd, 2, dl);
			for (int l = 0; l < dl.Size(); l++) Text(G_STRIP, dl[l], "N", 0, xl, l == 0 ? z4 : z5, dt, FitK(dl[l], kd, STRIP_ROOM));
		}
		else if (labels.Size() == 0) Text(G_STRIP, "PLAIN GUN", "N", 0, xl, z4, dt, kd);
		if (oWords)
		{
			String od = lg.GetString("desc", offer[i], 0, 0, null);
			Wrap(od != "" ? od : eff, STRIP_ROOM, kd, 2, dl);
			for (int l = 0; l < dl.Size(); l++) Text(G_STRIP, dl[l], "W", 0, xr, l == 0 ? z4 : z5, dt, FitK(dl[l], kd, STRIP_ROOM));
		}
		gCX[G_STRIP] = 0; gCZ[G_STRIP] = STRIP_Z;
	}

	// ================================================================ placing the parts
	// the pop (0.2 -> 1.35 -> 1.0, a frame each POPT tics), and the fold (to 0.4, fading, over 6 frames)
	static double PopAt(int age)
	{
		static const double P[] = { 0.2, 1.35, 1.12, 1.0 };
		if (age < 0) return 0.0;
		int f = age / POPT;
		return f >= 4 ? 1.0 : P[f];
	}

	void Layout(bool force)
	{
		// the groups' scales this tic
		bool anim = force;
		for (int g = 0; g < G_NUM; g++)
		{
			double s = 1.0, a = 1.0;
			if (gGone[g] > 0)
			{
				double t = (level.maptime - gGone[g]) / (6.0 * POPT);
				s = 1.0 - 0.6 * clamp(t, 0.0, 1.0);
				a = 1.0 - clamp(t, 0.0, 1.0);
				anim = true;
			}
			else if (g == G_WORD && wordT0 > 0)
			{
				// THE MOCKUP'S WORD (kiosk_anim.py: LUCKY, then the new rarity): it lands from 1.6 to 1.0 in 4 frames, rises a
				// little each frame, and after 18 frames fades over 4
				int age = level.maptime - wordT0;
				double e = clamp(age / (4.0 * POPT), 0.0, 1.0);
				s = Photo() ? 1.0 : 1.6 - 0.6 * (1 - (1 - e) ** 3);
				a = age < 18 * POPT ? 1.0 : max(0.0, 1.0 - (age - 18 * POPT) / (4.0 * POPT));
				gRise[g] = age * 0.2;
				anim = true;
			}
			else if (g == G_CARD && gPop[g] > 0)
			{
				// THE CARD'S POP (kiosk_anim.py: 0.35 -> 1 with a small overshoot over 7 frames)
				int age = level.maptime - gPop[g];
				double q = clamp(age / (7.0 * POPT), 0.0, 1.0);
				s = Photo() ? 1.0 : 0.35 + 0.65 * (1 - (1 - q) ** 3) + (q < 1 ? 0.08 * sin(q * 180) : 0);
				if (age < 7 * POPT + 2) anim = true;
			}
			else if (gPop[g] > 0)
			{
				int age = level.maptime - gPop[g];
				s = Photo() ? 1.0 : PopAt(age);
				if (age < 4 * POPT + 2) anim = true;
			}
			if (g >= G_OFF0 && g <= G_OFF4 && (hover[0] == g - G_OFF0 || hover[1] == g - G_OFF0)) s *= 1.12;
			if (s != gS[g] || a != gAlpha[g]) anim = true;
			gS[g] = s; gAlpha[g] = a;
		}
		if (level.maptime <= revealUntil + 1) anim = true;
		bool turned = abs(Actor.DeltaAngle(fy, lastFy)) > 0.01;
		lastFy = fy;
		if (!anim && !turned && !dirty) return;
		dirty = false;
		Vector3 F = (cos(fy), sin(fy), 0);
		Vector3 R = (-sin(fy), cos(fy), 0);
		for (int i = 0; i < parts.Size(); i++)
		{
			let p = parts[i];
			if (!p) continue;
			int g = pG[i];
			double s = gS[g];
			double lx = gCX[g] + (pX[i] - gCX[g]) * s;
			double lz = gCZ[g] + (pZ[i] - gCZ[g]) * s + gRise[g];
			p.SetOrigin(home + (R * lx + F * pD[i] + (0, 0, lz)) * Shrink(), true);
			if (p.bWallSprite) p.angle = fy;
			p.scale = (pS[i] * s, pSY[i] * s) * Shrink();
			p.alpha = pA[i] * gAlpha[g];
			p.bInvisible = s <= 0.01 || gAlpha[g] <= 0.01 || level.maptime < pShow[i];
		}
	}

	// ================================================================ every tic
	override void Tick()
	{
		if (!built) return;
		Watch();
		if (open) Interact();
		else { hover[0] = -1; hover[1] = -1; }
		StripTick();
		Animate();
		PipTick();
		WordTick();
		// the folds that have finished
		for (int g = 0; g < G_NUM; g++)
		{
			if (gGone[g] > 0 && level.maptime - gGone[g] > 6 * POPT + 1)
			{
				gGone[g] = 0; gPop[g] = 0;
				Clear(g);
				if (g == G_CARD) cardFor = -1;
				if (g == G_STRIP) { stripFor = -1; stripSig = ""; }
			}
		}
		Layout(false);
		Publish();
	}

	// who is standing at it, and is he still
	void Watch()
	{
		double range = CF('rsqmb_kiosk_range', 3.0) * 32.0;
		int wait = int(CF('rsqmb_kiosk_wait', 2.0) * TICRATE);
		Actor best = null; double bd = 1e9;
		for (int n = 0; n < MAXPLAYERS; n++)
		{
			if (!playeringame[n] || !players[n].mo || players[n].mo.health <= 0) continue;
			double d = (players[n].mo.pos.xy - home.xy).Length();
			if (d < bd) { bd = d; best = players[n].mo; }
		}
		if (best != customer) { customer = best; stillTics = 0; if (customer) stillAt = customer.pos.xy; }
		if (!customer) { if (open) Close("no one near"); return; }
		// NEVER MID-FIGHT (the header's rule; MB14, 2026-11-16): while a Boss fight lands or runs it does not open, and an open
		// kiosk folds away (a hand pointed at an offer would take that trigger from the gun)
		let fh = RSQMB_Handler(EventHandler.Find("RSQMB_Handler"));
		if (fh && fh.BfBusy())
		{
			if (open) Close("a Boss fight is on");
			stillTics = 0;
			stillAt = customer.pos.xy;
			return;
		}
		if (open)
		{
			if (bd > range + 24) Close(String.Format("walked away (%.1f m)", bd / 32.0));
			else
			{
				// it turns to keep facing him as he moves round it
				double want = AngleTo(customer);
				double dd = Actor.DeltaAngle(fy, want);
				if (abs(dd) > 20 || (abs(dd) > 0.5 && level.maptime - openTic < 4)) fy += dd * 0.15;
			}
			Note();
			return;
		}
		if (level.maptime % 35 == 0) Note();
		if (bd > range) { stillTics = 0; stillAt = customer.pos.xy; return; }
		if ((customer.pos.xy - stillAt).Length() > 16 || customer.vel.xy.Length() > 2)
		{
			stillTics = 0;
			stillAt = customer.pos.xy;
			return;
		}
		if (++stillTics >= wait) OpenUp();
	}

	void OpenUp()
	{
		open = true;
		openTic = level.maptime;
		fy = AngleTo(customer);
		noteSig = "";
		stripSig = ""; stripFor = -1;
		Note();
		gPop[G_NOTE] = level.maptime;
		for (int i = 0; i < offer.Size(); i++)
		{
			BuildOffer(i);
			gPop[G_OFF0 + i] = level.maptime + (i + 1) * 2 * POPT;   // each 2 frames after the one before (the chips' rule)
			gGone[G_OFF0 + i] = 0;
			gS[G_OFF0 + i] = 0;
		}
		Layout(true);
		A_StartSound("switches/normbutn", CHAN_AUTO, 0, 0.8);
		if (LogOn()) Console.Printf("RSQMB kiosk t%d: opened (player %d stood still %.1f s within %.1f m)", level.maptime,
			customer.PlayerNumber(), stillTics / double(TICRATE), (customer.pos.xy - home.xy).Length() / 32.0);
	}

	void Close(String why)
	{
		open = false;
		closeTic = level.maptime;
		stillTics = 0;
		if (customer) stillAt = customer.pos.xy;
		for (int i = 0; i < offer.Size(); i++) gGone[G_OFF0 + i] = level.maptime;
		if (cardFor >= 0) gGone[G_CARD] = level.maptime;
		if (stripFor >= 0) gGone[G_STRIP] = level.maptime;
		stripFor = -1; stripSig = "";
		HideBeam();
		hover[0] = -1; hover[1] = -1;
		noteSig = "";
		Note();
		if (LogOn()) Console.Printf("RSQMB kiosk t%d: closed (%s)", level.maptime, why);
	}

	// ---- the hands (the Wheel's reading of QuestZDoom's poses: wr_Rig.handPos / handDir) ----------------------------
	static Vector3 HandPos(PlayerPawn pmo, int hand)
	{
		if (pmo.OverrideAttackPosDir) return (hand == 1) ? pmo.OffhandPos : pmo.AttackPos;
		double yaw = pmo.angle, side = (hand == 1) ? -1.0 : 1.0;
		Vector3 head = pmo.pos + (0, 0, pmo.player.viewheight);
		return head + (cos(yaw), sin(yaw), 0) * 22.0 + (cos(yaw - 90), sin(yaw - 90), 0) * (side * 11.0) - (0, 0, 8.0);
	}
	static Vector3 HandDir(PlayerPawn pmo, int hand)
	{
		double y, p;
		if (pmo.OverrideAttackPosDir)
		{
			y = ((hand == 1) ? pmo.OffhandAngle : pmo.AttackAngle) + 90;
			p = (hand == 1) ? pmo.OffhandPitch : pmo.AttackPitch;
		}
		else { y = pmo.angle; p = -pmo.pitch; }
		double cp = cos(p);
		return (cp * cos(y), cp * sin(y), sin(p));
	}

	// an offer's box in the kiosk's plane: from above its gun to under its effect line, 100 mockup pixels wide
	bool InBox(int i, double lx, double lz)
	{
		lx /= Shrink(); lz /= Shrink();   // the boxes are in the drawn layout's units (FitScale)
		if (i == B_LUCKY) return open && !luckyUsed && !big && abs(lx) <= 60 * K && abs(lz - LZ(LUCKY_Y)) <= 30 * K;
		if (i == B_REPAIR) { int w, p; [w, p] = RepairCost(customer); return open && w > 0 && abs(lx - REPAIR_X) <= 50 * K && abs(lz - LZ(LUCKY_Y)) <= 24 * K; }
		if (i < 0 || i >= offer.Size()) return false;
		return abs(lx - OX(i)) <= OHalf() && lz <= LZ(200) && lz >= LZ(290);
	}

	// what a hand can point at, in turn: the offers, then the LUCKY and REPAIR buttons
	int Target(int j) { return j < offer.Size() ? j : (j == offer.Size() ? B_LUCKY : B_REPAIR); }

	void Interact()
	{
		let pmo = PlayerPawn(customer);
		if (!pmo || !pmo.player) return;
		Vector3 F = (cos(fy), sin(fy), 0);
		Vector3 R = (-sin(fy), cos(fy), 0);
		int beamHand = -1;
		for (int h = 0; h < 2; h++)
		{
			int was = hover[h];
			hover[h] = -1;
			Vector3 o = HandPos(pmo, h);
			Vector3 dir = HandDir(pmo, h);
			// touching: the hand in an offer's box
			Vector3 rel = o - home;
			double ld = rel dot F, lx = rel dot R, lz = rel.z;
			for (int j = 0; j < offer.Size() + 2 && abs(ld) < 12; j++) { int i = Target(j); if (InBox(i, lx, lz)) { hover[h] = i; SetHit(h, o); } }
			// pointing: the ray into the kiosk's plane
			double dn = dir dot F;
			if (hover[h] < 0 && dn < -0.05)
			{
				double t = (home - o) dot F / dn;
				if (t > 0 && t < 400)
				{
					Vector3 hit = o + dir * t;
					Vector3 hr = hit - home;
					double hx = hr dot R, hz = hr.z;
					for (int j = 0; j < offer.Size() + 2; j++) { int i = Target(j); if (InBox(i, hx, hz)) { hover[h] = i; SetHit(h, hit); } }
					if (LogOn() && level.maptime % 35 == 0)
						Console.Printf("RSQMB kiosk t%d: %s hand's ray meets the kiosk %.1f right, %.1f up (%.0f out) -> %d", level.maptime, h ? "off" : "main", hx, hz, t, hover[h]);
				}
			}
			if (hover[h] >= 0 && hover[h] != was)
			{
				if (hover[h] < NOFF) { sel = hover[h]; selTic = level.maptime; }
				A_StartSound("misc/chat2", CHAN_AUTO, CHANF_OVERLAP, 0.25, ATTN_NONE, 2.0);
				if (LogOn()) Console.Printf("RSQMB kiosk t%d: %s hand points at offer %d", level.maptime, h ? "off" : "main", hover[h]);
			}
			if (hover[h] >= 0 && beamHand < 0) beamHand = h;
		}
		// the card follows what is pointed at; it stays on the last one a second after the hand moves off
		int h0 = hover[0] < NOFF ? hover[0] : -1, h1 = hover[1] < NOFF ? hover[1] : -1;
		int want = h0 >= 0 ? h0 : (h1 >= 0 ? h1 : (level.maptime - selTic < TICRATE ? sel : -1));
		if (want != cardFor || (want >= 0 && CardKey(want) != cardSig))
		{
			if (want >= 0)
			{
				bool same = want == cardFor;
				BuildCard(want, !same);
				if (same) gPop[G_CARD] = 0;      // only its words changed: no second pop
			}
			else if (cardFor >= 0 && gGone[G_CARD] == 0) gGone[G_CARD] = level.maptime;
		}
		// the pointing beam: eight dots from the hand to the offer
		for (int k = 0; k < 8; k++)
		{
			if (!beam[k])
			{
				beam[k] = RSQMB_KPart(Actor.Spawn("RSQMB_KPart", home, NO_REPLACE));
				if (!beam[k]) continue;
				beam[k].sprite = GetSpriteIndex("KQDT");
				beam[k].frame = 0;
				beam[k].A_SetRenderStyle(0.9, STYLE_Add);
			}
			let b = beam[k];
			b.bInvisible = beamHand < 0;
			if (beamHand < 0) continue;
			Vector3 o = HandPos(pmo, beamHand);
			b.SetOrigin(o + (HitAt(beamHand) - o) * ((k + 1) / 8.0), true);
			b.scale = (0.18, 0.18) * (0.5 + (k + 1) / 16.0);
		}
	}
	void HideBeam() { for (int k = 0; k < 8; k++) if (beam[k]) beam[k].bInvisible = true; }

	void Animate()
	{
		int t = level.maptime;
		bool ph = Photo();
		static const int SH[] = { 0, 1, 2, 1, 2, 1 };
		for (int i = 0; i < parts.Size(); i++)
		{
			let p = parts[i];
			if (!p) continue;
			// THE SOTN SHIMMER (kiosk_anim.py SH: shades 1.0 1.25 0.8 1.15 0.7 1.3, a step every 3 frames, each offer out of
			// step): the gold words trade their three shades; the armed LUCKY line blinks with white. Photosensitive Mode: still
			if (pSprB[i] == 0) continue;
			if (pSprC[i] == -3) { p.sprite = (!ph && (t / 4) % 2) ? pSprB[i] : pSprA[i]; continue; }
			if (ph) { p.sprite = pSprA[i]; continue; }
			int k = SH[(t / 7 + pG[i] * 2) % 6];
			p.sprite = k == 0 ? pSprA[i] : (k == 1 ? pSprB[i] : pSprC[i]);
		}
		Vector3 F = (cos(fy), sin(fy), 0), R = (-sin(fy), cos(fy), 0);
		for (int i = 0; i < NOFF; i++)
		{
			let g = gun[i];
			if (!g) continue;
			g.angle += 1.5;     // a turntable (a voxel turns; a sprite does not care)
			int pi = parts.Find(g);
			if (pi >= parts.Size()) continue;
			int gg = pG[pi];
			double s = gS[gg];
			double lx = gCX[gg] + (pX[pi] - gCX[gg]) * s;
			double lz = gCZ[gg] + (pZ[pi] - gCZ[gg]) * s + sin(t * 9 + i * 75) * 1.0;
			g.SetOrigin(home + (R * lx + F * pD[pi] + (0, 0, lz)) * Shrink(), true);
		}
		// a flash on an offer just bought or raised; a red blink on one refused
		if (flashTic > 0 && t - flashTic > 10) { flashTic = 0; Clear(G_FX); }
	}

	// for the input handler (ui): which offer each hand points at, while open
	void Publish()
	{
		let h = RSQMB_KioskInput(EventHandler.Find("RSQMB_KioskInput"));
		if (!h) return;
		if (open && customer && customer.PlayerNumber() == consoleplayer)
		{
			h.kiosk = self;
			h.hover[0] = hover[0]; h.hover[1] = hover[1];
		}
		else if (h.kiosk == self) { h.kiosk = null; h.hover[0] = -1; h.hover[1] = -1; }
	}

	// ================================================================ buying, LUCKY
	// A WORD OVER AN OFFER in the SOTN letters (SOLD!, LUCKY!, the new rarity: kiosk_anim.py's LUCKY / RARE), one after
	// another, delay tics after the one before (Layout gives them the mockup's landing, rise and fade)
	void Word(int i, String s, String col, int delay = 0)
	{
		int at = level.maptime + delay;
		if (wordAt.Size()) at = max(at, wordAt[wordAt.Size() - 1] + delay);
		wordQ.Push(s); wordC.Push(col); wordAt.Push(at); wordX.Push(OX(i));
	}
	void WordTick()
	{
		int t = level.maptime;
		if (wordT0 > 0 && t - wordT0 > 22 * POPT) { Clear(G_WORD); wordT0 = 0; gRise[G_WORD] = 0; }
		if (!wordQ.Size() || t < wordAt[0]) return;
		Clear(G_WORD);
		Text(G_WORD, wordQ[0], wordC[0], 0, wordX[0], LZ(205), 9, BIGK, 0, 0, wordC[0] == "Y");
		gCX[G_WORD] = wordX[0]; gCZ[G_WORD] = LZ(205);
		wordT0 = t; gRise[G_WORD] = 0;
		wordQ.Delete(0); wordC.Delete(0); wordAt.Delete(0); wordX.Delete(0);
		Layout(true);
	}

	// THE LIFE FLIES TO THE OFFER (kiosk_anim.py: the pip from the wrist, an arc over 6 frames); the offer's jump, its
	// flash and the words when it lands
	void PipTick()
	{
		if (!pip) return;
		int t = level.maptime;
		double q = clamp((t - pipT0) / (6.0 * POPT), 0.0, 1.0);
		double e = 1 - (1 - q) ** 3;
		Vector3 F = (cos(fy), sin(fy), 0), R = (-sin(fy), cos(fy), 0);
		Vector3 to = home + (R * OX(luckyFx) + F * 6 + (0, 0, LZ(222))) * Shrink();
		pip.SetOrigin(pipFrom + (to - pipFrom) * e + (0, 0, 60 * K * sin(q * 180)), true);
		if (q < 1) return;
		pip.Destroy();
		pip = null;
		LuckyLand(luckyFx);
	}
	void LuckyLand(int i)
	{
		BuildOffer(i);
		gPop[G_OFF0 + i] = level.maptime;
		Flash(i);
		Word(i, "LUCKY!", "Y");
		Word(i, RarName(rarity[i]) .. "!", RarCol(rarity[i]), 10 * POPT);
		cardSig = "";
		noteSig = "";
	}

	void Flash(int i)
	{
		Clear(G_FX);
		flashTic = level.maptime;
		double tk = K / RSQMB_KioskFont.TEX;
		Part(G_FX, "KQFL", 0, OX(i), LZ(222), 6, tk, 0, "", STYLE_Add, Photo() ? 0.3 : 0.9);
		gCX[G_FX] = OX(i); gCZ[G_FX] = LZ(222);
		gPop[G_FX] = level.maptime; gGone[G_FX] = level.maptime + 4;
		Layout(true);
	}

	void Buy(int i, int hand)
	{
		if (open && i == B_REPAIR) { Repair(hand); return; }
		if (open && i == B_LUCKY)
		{
			if (luckyUsed) return;
			luckyArmed = !luckyArmed;
			A_StartSound(luckyArmed ? "misc/p_pkup" : "switches/normbutn", CHAN_AUTO, 0, 0.7);
			noteSig = ""; cardSig = "";
			if (LogOn()) Console.Printf("RSQMB kiosk t%d: the LUCKY button %s with the %s hand", level.maptime, luckyArmed ? "armed" : "disarmed", hand ? "off" : "main");
			return;
		}
		if (luckyArmed && i >= 0 && i < offer.Size()) { Lucky(i, hand); return; }
		if (!open || i < 0 || i >= offer.Size() || !customer) return;
		let bk = Bank(), lg = Legend();
		if (!bk || !lg) return;
		if (sold[i]) { if (LogOn()) Console.Printf("RSQMB kiosk t%d: offer %d already sold", level.maptime, i); return; }
		int bank = bk.GetInt("gold", "", 0, 0, customer);
		if (bank < price[i])
		{
			A_StartSound("misc/keytry", CHAN_AUTO, 0, 0.9);
			Toast(String.Format("NEED %d G MORE", price[i] - bank));
			if (LogOn()) Console.Printf("RSQMB kiosk t%d: refused offer %d (%s %s, %d G): the bank has %d G", level.maptime, i,
				lg.GetString("gun", offer[i], 0, 0, null), RarName(rarity[i]), price[i], bank);
			return;
		}
		int after = bk.GetInt("gold.spend", String.Format("kiosk: %s %s", lg.GetString("gun", offer[i], 0, 0, null), RarName(rarity[i])), price[i], 0, customer);
		if (after < 0) return;
		int got = lg.GetInt("give", offer[i], 0, 0, customer);
		sold[i] = true;
		A_StartSound("misc/p_pkup", CHAN_AUTO, 0, 1.0);
		Flash(i);
		Word(i, "SOLD!", "Y");
		BuildOffer(i);
		gPop[G_OFF0 + i] = level.maptime;
		noteSig = "";
		if (LogOn()) Console.Printf("RSQMB kiosk t%d: BOUGHT offer %d with the %s hand: %s %s %s for %d G (bank %d -> %d); the legendary %s", level.maptime, i,
			hand ? "off" : "main", lg.GetString("gun", offer[i], 0, 0, null), RarName(rarity[i]), lg.GetString("effect", offer[i], 0, 0, null),
			price[i], bank, after, got == 1 ? "taken" : (got == 2 ? "left lying (he already carries one on that gun)" : "not made"));
		if (got == 2) Toast("YOU HAVE ONE: IT WAITS AT YOUR FEET");
	}

	void Lucky(int i, int hand)
	{
		if (!open || i < 0 || i >= offer.Size() || !customer) return;
		let bk = Bank(), lg = Legend();
		if (!bk || !lg) return;
		String why = "";
		if (sold[i]) why = "sold";
		else if (luckyUsed) why = "LUCKY already used at this kiosk";
		else if (rarity[i] >= 3) why = "already Epic";
		else if (!big && rarity[i] >= 2) why = "a Boss kiosk's offers stop at Rare";   // owner 2026-11-25: orange is the Big Boss's
		else if (bk.GetInt("lives", "", 0, 0, customer) <= 0) why = "no Score life to spend";
		String up = why == "" ? lg.GetString("raise", offer[i], 0, 0, null) : "";
		if (why == "" && up == "") why = "nothing to raise to on that gun";
		luckyArmed = false;
		noteSig = "";
		if (why != "")
		{
			A_StartSound("misc/keytry", CHAN_AUTO, 0, 0.9);
			if (why == "no Score life to spend") Toast("LUCKY NEEDS A LIFE");
			if (LogOn()) Console.Printf("RSQMB kiosk t%d: LUCKY refused on offer %d: %s", level.maptime, i, why);
			return;
		}
		// the life spent here is not a lost Boss fight (tierup.zs LossTick)
		let mh = RSQMB_Handler(EventHandler.Find("RSQMB_Handler"));
		if (mh) mh.kioskLifeTic = level.maptime;
		int left = bk.GetInt("life.spend", "kiosk LUCKY", 0, 0, customer);
		if (left < 0) return;
		String was = offer[i];
		int wr = rarity[i];
		offer[i] = up;
		Array<String> f; up.Split(f, "|");
		rarity[i] = f.Size() >= 2 ? f[1].ToInt() : wr + 1;
		price[i] = PriceOf(rarity[i]);
		luckyUsed = true;
		A_StartSound("misc/p_pkup", CHAN_AUTO, 0, 1.0);
		A_StartSound("misc/teleport", CHAN_AUTO, CHANF_OVERLAP, 0.5);
		// the Score life flies from the hand to the offer; it jumps when it lands (PipTick)
		if (pip) pip.Destroy();
		pip = RSQMB_KPart(Actor.Spawn("RSQMB_KPart", home, NO_REPLACE));
		pipFrom = PlayerPawn(customer) ? HandPos(PlayerPawn(customer), hand) : customer.pos + (0, 0, 40);
		if (pip) { pip.sprite = GetSpriteIndex("KQLF"); pip.frame = 0; pip.scale = (0.1, 0.1); pip.SetOrigin(pipFrom, false); }
		pipT0 = level.maptime;
		luckyFx = i;
		if (!pip) LuckyLand(i);
		noteSig = "";
		cardSig = "";
		if (LogOn()) Console.Printf("RSQMB kiosk t%d: LUCKY on offer %d with the %s hand: a Score life spent (%d left); %s %s -> %s %s, price %d G",
			level.maptime, i, hand ? "off" : "main", left, RarName(wr), lg.GetString("effect", was, 0, 0, null), RarName(rarity[i]),
			lg.GetString("effect", offer[i], 0, 0, null), price[i]);
	}

	// REPAIR (Weapon Condition): every gun he carries back to 100, for its price in gold
	void Repair(int hand)
	{
		let bk = Bank(), gc = Cards();
		if (!open || !customer || !bk || !gc) return;
		int worn, pr;
		[worn, pr] = RepairCost(customer);
		if (worn <= 0) return;
		int guns = gc.GetInt("cnd.worn.guns", "", 0, 0, customer);
		int bank = bk.GetInt("gold", "", 0, 0, customer);
		if (bank < pr)
		{
			A_StartSound("misc/keytry", CHAN_AUTO, 0, 0.9);
			Toast(String.Format("NEED %d G MORE", pr - bank));
			if (LogOn()) Console.Printf("RSQMB kiosk t%d: refused REPAIR (%d points on %d gun(s), %d G): the bank has %d G", level.maptime, worn, guns, pr, bank);
			return;
		}
		int after = bk.GetInt("gold.spend", String.Format("kiosk: repair %d points", worn), pr, 0, customer);
		if (after < 0) return;
		int fixed = gc.GetInt("cnd.fix", "kiosk", 0, 0, customer);
		A_StartSound("misc/p_pkup", CHAN_AUTO, 0, 1.0);
		A_StartSound("weapons/sshotl", CHAN_AUTO, CHANF_OVERLAP, 0.7);
		Toast(String.Format("%d GUN%s REPAIRED", guns, guns == 1 ? "" : "S"), "up");
		noteSig = "";
		Note();
		if (LogOn()) Console.Printf("RSQMB kiosk t%d: REPAIRED with the %s hand: %d points on %d gun(s) for %d G (bank %d -> %d); %d points restored",
			level.maptime, hand ? "off" : "main", worn, guns, pr, bank, after, fixed);
	}

	void Toast(String s, String kind = "info")
	{
		let vr = Svc("RSQVR_Service");
		if (!vr || !customer || vr.GetInt("toast", kind .. "|" .. s, 0, 0, customer) <= 0)
			if (customer && customer.player) customer.A_Print(s, 1.5);
	}
}

// THE TRIGGER WHILE A HAND POINTS AT AN OFFER (the Wheel's InputProcess pattern): either hand's trigger buys, its alt fire is
// LUCKY. Taken before the gun sees it, only while that hand points at an offer of an open kiosk.
class RSQMB_KioskInput : EventHandler
{
	RSQMB_Kiosk kiosk;
	int hover[2];

	static ui bool KeyFor(int key, String cmd)
	{
		Array<int> keys;
		bindings.GetAllKeysForCommand(keys, cmd);
		for (int i = 0; i < keys.Size(); i++) if (keys[i] == key) return true;
		return false;
	}

	override bool InputProcess(InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown || !kiosk) return false;
		int act = 0, hand = -1;
		if (KeyFor(e.KeyScan, "+attack")) { act = 1; hand = 0; }
		else if (KeyFor(e.KeyScan, "+oh_attack")) { act = 1; hand = 1; }
		else if (KeyFor(e.KeyScan, "+altattack")) { act = 2; hand = 0; }
		else if (KeyFor(e.KeyScan, "+oh_altatk")) { act = 2; hand = 1; }
		if (RSQMB_Kiosk.LogOn() && hand >= 0)
			Console.Printf("RSQMB kiosk input: key %d (%s) down: %s hand, pointing at offer %d%s", e.KeyScan, act == 1 ? "trigger" : "alt fire",
				hand ? "off" : "main", hover[hand], hover[hand] >= 0 ? ": the kiosk's" : ": the gun's");
		if (hand < 0 || hover[hand] < 0) return false;
		EventHandler.SendNetworkEvent("rsqmb_kiosk", act, hand, hover[hand]);
		return true;
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (!(e.Name ~== "rsqmb_kiosk")) return;
		// the console's door too (rig tests): netevent rsqmb_kiosk <1 buy / 2 LUCKY> <hand> <offer>; an offer of -1 = the one
		// that hand points at
		RSQMB_Kiosk k = kiosk;
		if (!k) { let it = ThinkerIterator.Create("RSQMB_Kiosk"); k = RSQMB_Kiosk(it.Next()); }
		if (!k) return;
		int hand = clamp(e.Args[1], 0, 1);
		int i = e.Args[2];
		if (e.IsManual && !k.open) { Console.Printf("RSQMB kiosk: not open"); return; }
		if (i < 0) i = k.hover[hand];
		// (the door's old numbers: 3 LUCKY, 4 REPAIR, on a kiosk of three offers)
		else if (k.offer.Size() <= RSQMB_Kiosk.BOSS_OFFERS && (i == 3 || i == 4)) i = i == 3 ? RSQMB_Kiosk.B_LUCKY : RSQMB_Kiosk.B_REPAIR;
		if (e.Args[0] == 1) k.Buy(i, hand);
		else if (e.Args[0] == 2) k.Lucky(i, hand);
	}
}
