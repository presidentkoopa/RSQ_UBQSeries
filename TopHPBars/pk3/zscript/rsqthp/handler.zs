// RSQ TOP HP BARS -- THE HANDLER
//
// Everything a bar reads once a tic lives here, read ONCE a tic (coldcite's bar looked up four
// cvars and formatted three strings per bar per tic). Bars hold a pointer to this handler.
//
// WHO GETS A BAR, AND WHEN. The same rule as coldcite's: monsters (+ISMONSTER, not NOINTERACTION,
// not NOTELESTOMP -- his LegenDoom fix) and players, and only once their health differs from their
// spawn health. His version gave every monster a ticking CustomInventory to watch for that. Here:
//   - a damage event spawns the bar at once (WorldThingDamaged);
//   - health that changes WITHOUT damage (LegenDoom Lite's legendaries are set to 300 % by ACS, a
//     healer's GiveBody) is caught by a poll that walks 1/16 of the tracked list each tic, so every
//     monster is looked at once every 16 tics, for one native call and one compare.
//
// COLDCITE'S OWN PK3 LOADED TOO. All our names differ (RSQTHP_ classes, rsqthp_ cvars, RSY/RS##
// sprites), so both load without a clash. Two bars over every monster is what would clash, so this
// handler TAKES OVER: when his item class (Z_MyTopHP) exists, it is taken off every monster and player
// the tic after they appear (after every handler's WorldThingSpawned has run, before any thinker),
// and his bar removes itself the tic it finds the item gone (his own clean-up rule). His HUD Options
// entry, when his MENUDEF loads first, opens our menu (MENUDEF.txt). With our bars switched off
// (HP Bars Off) nothing more is taken from him, so his bars show on what appears from then on: ours
// stand down (items already taken stay taken).
//
// SERIES MARKERS. The series' mods are asked by name (ServiceIterator), so nothing links against
// them and an absent mod is no answer. Each answers in its own words (objectArg = the monster):
//   hooked   RSQ_Grapple (RSQGR_Service): "hooked" = tics since it was last on a hook's line (0 while
//            on it) -> on, or let go within HOOK_GRACE tics; or "yanked" 1/2 (on the yank's path,
//            or flying on its own after it)
//   stunned  RSQ_Grapple: "stunned" == 1 (the yank's landing hold, the whip's crack while in pain)
//   locked   UltraBadassShieldSaw (SSQ_ScoreService): "locked" == 1 (a lock-on ring is on it)
//   gripped  UltraBadassQuestSaber (UBQS_SaberService): "gripped" == 1 (a Force grip holds it)
// Any other mod may answer all four as 1/0 from a Service whose class name contains "RSQTHP_Marker".
//
// FROZEN AND HELD (owner's picks 36 and 37, 2026-10-31), right of the bar, one at a time, every tic. Read off the
// monster itself, so no mod is asked and nothing links (bar.zs, StatusOf):
//   frozen   its freezetics is counting: a hit-stop (Saber, ShieldSaw, Whip, DistanceGrab, the rig's thrown gun all
//            set it; Quest teardown surveys/01_MELEE 3.6, 10_TIME 2.4)
//   held     RSQ DistanceGrab's Headlock or human shield (teardown apply/04 1; its near.zs): it re-asserts
//            freezetics every tic (so the count stands still instead of counting down) and borrows the monster's
//            NOGRAVITY and FORCEINFIGHTING for the hold. A hit-stop does neither.
//
// AIMED ONLY (owner's pick 35, an option, off by default): a bar is drawn only over the monster a hand's gun points
// at, either hand -- a hitscan trace from the hand along its aim (teardown surveys/00 1.2 and 3.1: AttackPos /
// OffhandPos, yaw AttackAngle + 90, pitch positive up; outside VR the view) -- and for AIM_LINGER tics after the
// aim leaves it, so a shaky hand does not blink it. A monster aimed at gets its bar even at full health.
//
// QoL ROUND (owner's picks, 2026-10-31). On: HP6 length by toughness, HP7 hit flash, HP8 raised marker, HP9 fade in
// (bar.zs). Options, off until turned on: HP1 damage chunk (rsqthp_chunk), HP2 ally colour (rsqthp_ally), HP3 nearest
// 24 (rsqthp_nearest), HP4 distance limit (rsqthp_limit + rsqthp_limitdist). What a player's hit is: the damage's
// source (a missile's shooter, as WorldThingDamaged hands it) is a player's own body.
class RSQTHP_Handler : EventHandler
{
	// ---- settings, refreshed every tic -------------------------------------------------------
	bool   on, overheal, markers, stealth, bright, aimedOnly;
	bool   chunk, ally, nearest, limit;   // QoL options HP1..HP4
	double limitDist;
	int    scheme;          // effective: own setting, or RSQ_Accessibility's when it is on
	int    set;             // art set 0..4 (A Classic, B Red, C protan+deutan, D tritan, E high contrast)
	double scale, offset, far;
	int    ver;             // bumps when the look changes, so bars rebuild their frame
	transient CVar cOn, cScheme, cScale, cFar, cOffset, cBright, cStealth, cOver, cMark, cCB, cAim;
	transient CVar cChunk, cAlly, cNear, cLimit, cLimitD;
	transient bool cvFound;

	// ---- sprites, looked up once -------------------------------------------------------------
	transient bool sprFound;
	transient int sprMain[5];
	transient int sprOver[25];       // [set * 5 + pips]
	transient int sprMark;
	transient int sprStat;           // RSYF: A frozen, B held, C raised, D frozen + raised, E held + raised
	transient int sprAlly;           // RSYG: the friendly bar (HP2)
	transient int sprChunk;          // RSYH: the damage chunk (HP1)

	// ---- nearest 24 (HP3) ----------------------------------------------------------------------
	const NEAR_N = 24;
	bool anyCulled;

	// ---- aimed only ----------------------------------------------------------------------------
	const AIM_RANGE = 8192;
	const AIM_LINGER = 18;           // tics a bar stays after the aim leaves its monster (half a second)
	Actor aim[2];                    // what each hand's gun pointed at this tic (null: nothing)

	// ---- tracking ----------------------------------------------------------------------------
	Array<Actor> mons;               // everything that may get a bar, polled 1/16 a tic
	Array<RSQTHP_Bar> monBar;        // its bar, same index (so the poll never searches for it)
	int pollAt;
	Array<RSQTHP_Bar> bars;          // the bars alive (few: only damaged / overhealed things)

	// ---- coldcite's pk3, if loaded -------------------------------------------------------------
	transient bool coldChecked;
	transient class<Inventory> coldItem;
	Array<Actor> coldPending;

	// ---- series services -----------------------------------------------------------------------
	static const String SVC_NAMES[] = { "RSQGR_Service", "SSQ_ScoreService", "UBQS_SaberService", "RSQTHP_Marker" };
	enum ESvc { SV_GRAPPLE, SV_SHIELD, SV_SABER, SV_GENERIC }
	const HOOK_GRACE = 3;
	transient bool svcFound;
	transient Array<Service> svc;
	transient Array<int> svcKind;

	// ---- Champions (by name: nothing links to it) -----------------------------------------------
	// Its icon floats at the champion's Height x 1.1 -- exactly where the bar is -- 96 px tall at
	// 0.75 x champion_IconScale. A bar over a champion is lifted above the icon (bar.zs).
	transient bool champChecked;
	transient class<Inventory> champInfo;
	transient CVar cChIcons, cChScale, cChDormant, cChLD;
	transient bool ldLoaded;
	transient class<Inventory> ldToken, ldTransformed;
	bool champIcons;
	double champIconH;

	// measuring (rsqthp_debug-free: the test harness reads these)
	int spawnedBars;

	static RSQTHP_Handler Get() { return RSQTHP_Handler(EventHandler.Find("RSQTHP_Handler")); }

	private void FindCVars()
	{
		cvFound = true;
		cOn = CVar.FindCVar('rsqthp_on');
		cScheme = CVar.FindCVar('rsqthp_scheme');
		cScale = CVar.FindCVar('rsqthp_scale');
		cFar = CVar.FindCVar('rsqthp_far');
		cOffset = CVar.FindCVar('rsqthp_offset');
		cBright = CVar.FindCVar('rsqthp_bright');
		cStealth = CVar.FindCVar('rsqthp_stealth');
		cOver = CVar.FindCVar('rsqthp_overheal');
		cMark = CVar.FindCVar('rsqthp_markers');
		cAim = CVar.FindCVar('rsqthp_aimed');
		cChunk = CVar.FindCVar('rsqthp_chunk');
		cAlly = CVar.FindCVar('rsqthp_ally');
		cNear = CVar.FindCVar('rsqthp_nearest');
		cLimit = CVar.FindCVar('rsqthp_limit');
		cLimitD = CVar.FindCVar('rsqthp_limitdist');
		cCB = null; { Name rsqaN = "RSQA_Menu"; class<Object> rsqaC = rsqaN; if (rsqaC) cCB = CVar.FindCVar("rsqa_colorblind"); }     // RSQ_Accessibility; null when it is not loaded
	}

	private void FindSprites()
	{
		sprFound = true;
		static const Name mains[] = { 'RSYA', 'RSYB', 'RSYC', 'RSYD', 'RSYE' };
		for (int s = 0; s < 5; s++)
		{
			sprMain[s] = Actor.GetSpriteIndex(mains[s]);
			for (int p = 0; p < 5; p++)
				sprOver[s * 5 + p] = Actor.GetSpriteIndex(String.Format("RS%d%d", s + 1, p));
		}
		sprMark = Actor.GetSpriteIndex('RSYZ');
		sprStat = Actor.GetSpriteIndex('RSYF');
		sprAlly = Actor.GetSpriteIndex('RSYG');
		sprChunk = Actor.GetSpriteIndex('RSYH');
	}

	private void FindServices()
	{
		svcFound = true;
		svc.Clear();
		svcKind.Clear();
		for (int n = 0; n < SVC_NAMES.Size(); n++)
		{
			let it = ServiceIterator.Find(SVC_NAMES[n]);
			Service s;
			while (s = it.Next())
				if (svc.Find(s) == svc.Size()) { svc.Push(s); svcKind.Push(n); }
		}
	}

	private void CheckChampions()
	{
		champChecked = true;
		String cn = "champion_PersistentInfo";
		champInfo = cn;
		cChIcons = CVar.FindCVar('champion_Icons');
		cChScale = CVar.FindCVar('champion_IconScale');
		cChDormant = CVar.FindCVar('champion_Dormant');
		cChLD = CVar.FindCVar('champion_Legendoom');
		ldLoaded = Wads.FindLump("LEGNDLIB") != -1 || Wads.CheckNumForFullName("acs/LEGNDLIB.o") != -1;
		String t1 = "LDLegendaryMonsterToken", t2 = "LDLegendaryMonsterTransformed";
		ldToken = t1; ldTransformed = t2;
	}

	// Does this thing wear a Champions icon now? A champion has its PersistentInfo. In Champions'
	// dormant LegenDoom mode (champion_Legendoom AND champion_Dormant, LegenDoom loaded: its handler's
	// own test) EVERY champion is dormant -- its controller does nothing, icon included, until
	// LegenDoom transforms it -- not only the legendary ones: a champion LegenDoom never picked
	// carries PersistentInfo and never shows an icon (handler.txt: the plain roll hands its controller
	// the same ld_dormant). Before, those bars were lifted over an icon that was not there.
	bool WearsChampIcon(Actor a)
	{
		if (!champIcons || !a.FindInventory(champInfo)) return false;
		bool dormantMode = cChDormant && cChDormant.GetInt() && cChLD && cChLD.GetInt() && ldLoaded;
		if (dormantMode && !(ldTransformed && a.FindInventory(ldTransformed))) return false;
		return true;
	}

	private void CheckCold()
	{
		coldChecked = true;
		String cn = "Z_MyTopHP";
		coldItem = cn;
	}

	// colour scheme -> art set
	static int SetOf(int scheme)
	{
		static const int sets[] = { 0, 1, 2, 2, 3, 4 };
		return sets[clamp(scheme, 0, 5)];
	}

	void ReadSettings()
	{
		if (!cvFound) FindCVars();
		if (!sprFound) FindSprites();
		bool o = cOn ? cOn.GetBool() : true;
		int sc = cScheme ? clamp(cScheme.GetInt(), 0, 5) : 0;
		int cb = cCB ? cCB.GetInt() : 0;
		if (cb >= 1 && cb <= 4) sc = cb + 1;        // 1 protan 2 deutan 3 tritan 4 high contrast
		bool ov = cOver ? cOver.GetBool() : true;
		bool br = cBright ? cBright.GetBool() : false;
		if (o != on || sc != scheme || ov != overheal || br != bright) ver++;
		on = o; scheme = sc; set = SetOf(sc); overheal = ov; bright = br;
		markers = cMark ? cMark.GetBool() : true;
		aimedOnly = cAim ? cAim.GetBool() : false;
		chunk = cChunk ? cChunk.GetBool() : false;
		bool al = cAlly ? cAlly.GetBool() : false;
		if (al != ally) ver++;
		ally = al;
		nearest = cNear ? cNear.GetBool() : false;
		limit = cLimit ? cLimit.GetBool() : false;
		limitDist = cLimitD ? max(64.0, cLimitD.GetFloat()) : 1536;
		stealth = cStealth ? cStealth.GetBool() : true;
		scale = cScale ? cScale.GetFloat() : 0.3;
		far = cFar ? max(1.0, cFar.GetFloat()) : 2.0;
		offset = cOffset ? cOffset.GetFloat() : 0.1;
		if (!champChecked) CheckChampions();
		champIcons = champInfo && cChIcons && cChIcons.GetInt() > 0;
		champIconH = champIcons ? 96.0 * 0.75 * (cChScale ? cChScale.GetFloat() : 0.2) : 0;
	}

	static bool Eligible(Actor a)
	{
		if (!a) return false;
		// a player's own body only: a voodoo doll is a player-class actor whose player's mo is another
		// actor (it takes damage, and passes it on to the player, but is not the player)
		if (a.player) return a.player.mo == a;
		return a.bIsMonster && !a.bNoInteraction && !a.bNoTeleStomp;
	}

	override void WorldLoaded(WorldEvent e)
	{
		FindCVars();
		FindServices();
		CheckCold();
		CheckChampions();
		ReadSettings();
		// A HUB MAP COME BACK TO: its monsters come back from the hub snapshot, not through
		// WorldThingSpawned, and WorldUnloaded cleared the list when it was left. Walk them once, so
		// the poll sees health that changed without damage (a legendary's overheal) there too.
		// (A saved game keeps the list itself: it is serialised with this handler.)
		if (e.IsReopen) Retrack();
	}

	private void Retrack()
	{
		let it = ThinkerIterator.Create("Actor");
		Actor a;
		while (a = Actor(it.Next()))
		{
			if (a.player || a.health <= 0 || !Eligible(a)) continue;
			Track(a);
		}
		for (int n = 0; n < MAXPLAYERS; n++) if (playeringame[n]) AddPlayer(n);
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || a.player || !Eligible(a)) return;
		Track(a);
		if (!coldChecked) CheckCold();
		if (coldItem) coldPending.Push(a);
	}

	// RAISED (HP8): a monster brought back gets its bar at once, with the raised marker for the rest of its life. In
	// stock Doom only the Arch-Vile revives a monster (A_VileChase -> RaiseActor -> WorldThingRevived; the rig log shows
	// it, HANDOFF.md); a player's resurrect is not a monster's and gets no marker.
	override void WorldThingRevived(WorldEvent e)
	{
		let a = e.Thing;
		if (!Eligible(a)) return;
		if (!a.player && on) { let b = Ensure(a); if (b) b.raised = true; }
		Track(a);
		if (!coldChecked) CheckCold();
		if (coldItem) coldPending.Push(a);
	}

	override void PlayerEntered(PlayerEvent e) { AddPlayer(e.PlayerNumber); }
	override void PlayerRespawned(PlayerEvent e) { AddPlayer(e.PlayerNumber); }
	private void AddPlayer(int n)
	{
		let p = players[n].mo;
		if (!p) return;
		if (mons.Find(p) == mons.Size()) Track(p);
		if (!coldChecked) CheckCold();
		if (coldItem) coldPending.Push(p);
	}

	private void Track(Actor a)
	{
		mons.Push(a);
		monBar.Push(null);
	}

	override void WorldThingDamaged(WorldEvent e)
	{
		let a = e.Thing;
		if (!a || a.health <= 0 || !Eligible(a)) return;
		let b = Ensure(a);
		// a player's hit: the flash (HP7) and the chunk it took off (HP1)
		Actor src = e.DamageSource;
		if (!src && e.Inflictor) src = e.Inflictor.target;
		if (b && src && src != a && src.player && src.player.mo == src) b.PlayerHit(a.health + max(0, e.Damage));
	}

	override void WorldTick()
	{
		ReadSettings();
		if (!svcFound) FindServices();
		if (!coldChecked) CheckCold();

		// coldcite's items, the tic after they were given (only while ours are on: with ours off, his show)
		if (coldItem && on)
		{
			for (int i = 0; i < coldPending.Size(); i++)
				if (coldPending[i]) coldPending[i].TakeInventory(coldItem, 0x7FFFFFFF);
		}
		coldPending.Clear();

		if (!on) return;

		aim[0] = null; aim[1] = null;
		if (aimedOnly) TraceAims();
		if (nearest) { if ((level.maptime & 3) == 0) CullFar(); }
		else if (anyCulled) { anyCulled = false; for (int i = 0; i < bars.Size(); i++) if (bars[i]) bars[i].culled = false; }

		// the poll: 1/16 of the list a tic
		while (monBar.Size() < mons.Size()) monBar.Push(null);
		int n = mons.Size();
		if (n == 0) return;
		int k = (n + 15) / 16;
		for (int i = 0; i < k && mons.Size() > 0; i++)
		{
			if (pollAt >= mons.Size()) pollAt = 0;
			let a = mons[pollAt];
			if (!a || a.health <= 0)
			{
				mons.Delete(pollAt);   // dead: a revive puts it back (WorldThingRevived)
				monBar.Delete(pollAt);
				continue;
			}
			let b = monBar[pollAt];
			if ((!b || b.who != a) && a.health != a.SpawnHealth()) monBar[pollAt] = Ensure(a);
			pollAt++;
		}
	}

	// NEAREST 24 (HP3): every 4th tic, the bars beyond the 24 nearest the viewer are marked culled (the bar hides
	// itself, and fades in again when it is back among the 24).
	private void CullFar()
	{
		let cam = players[consoleplayer].camera;
		if (!cam) return;
		Array<double> d;
		for (int i = 0; i < bars.Size(); i++)
			d.Push(bars[i] ? (bars[i].Pos - cam.Pos).Length() : 1e12);
		double cut = 1e12;
		if (bars.Size() > NEAR_N)
		{
			Array<double> s;
			s.Copy(d);
			for (int i = 1; i < s.Size(); i++)    // insertion sort: a few dozen bars
			{
				double v = s[i]; int j = i - 1;
				while (j >= 0 && s[j] > v) { s[j + 1] = s[j]; j--; }
				s[j + 1] = v;
			}
			cut = s[NEAR_N - 1];
		}
		int kept = 0;
		for (int i = 0; i < bars.Size(); i++)
		{
			if (!bars[i]) continue;
			bool c = d[i] > cut || (d[i] == cut && kept >= NEAR_N);
			if (!c) kept++;
			bars[i].culled = c;
		}
		anyCulled = true;
	}

	// AIMED ONLY: what each hand's gun points at. A hitscan from the hand along its aim, as a VR shot goes
	// (OverrideAttackPosDir), absolute coordinates; outside VR, the view, main hand only.
	private void TraceAims()
	{
		let p = players[consoleplayer];
		let pmo = p.mo;
		if (!pmo || pmo.health <= 0) return;
		for (int hd = 0; hd < 2; hd++)
		{
			Weapon w = hd == 0 ? p.ReadyWeapon : p.OffhandWeapon;
			if (!w) continue;
			FLineTraceData t;
			bool hit;
			if (pmo.OverrideAttackPosDir)
			{
				Vector3 at = hd == 0 ? pmo.AttackPos : pmo.OffhandPos;
				double yaw = (hd == 0 ? pmo.AttackAngle : pmo.OffhandAngle) + 90;
				double pit = hd == 0 ? pmo.AttackPitch : pmo.OffhandPitch;     // positive up
				hit = pmo.LineTrace(yaw, AIM_RANGE, -pit, TRF_ABSPOSITION, at.z, at.x, at.y, t);
			}
			else
			{
				if (hd == 1) continue;
				hit = pmo.LineTrace(pmo.angle, AIM_RANGE, pmo.pitch, 0, p.viewz - pmo.Pos.z, 0, 0, t);
			}
			if (!hit || t.HitType != FLineTraceData.TRACE_HitActor) continue;
			let a = t.HitActor;
			if (!a || a == pmo || a.health <= 0 || !Eligible(a)) continue;
			aim[hd] = a;
			Ensure(a, true);
		}
	}

	// a bar for this thing, if it has none (aimed: the aim is on it this tic)
	RSQTHP_Bar Ensure(Actor a, bool aimed = false)
	{
		if (!on) return null;
		for (int i = bars.Size() - 1; i >= 0; i--)
		{
			let b = bars[i];
			if (!b) { bars.Delete(i); continue; }
			if (b.who == a) { if (aimed) b.aimTic = level.maptime; return b; }
		}
		let b = RSQTHP_Bar(Actor.Spawn("RSQTHP_Bar", a.Pos, NO_REPLACE));
		if (!b) return null;
		b.who = a;
		b.h = self;
		b.aimTic = aimed ? level.maptime : -AIM_LINGER - 1;
		b.aimMade = aimed && a.health == a.SpawnHealth();
		b.markPhase = spawnedBars & 3;
		b.champ = WearsChampIcon(a);
		b.Update();
		bars.Push(b);
		spawnedBars++;
		return b;
	}

	// what the series' mods say about this monster (bit mask: 1 hooked, 2 stunned, 4 locked, 8 gripped)
	int MarkersOf(Actor a)
	{
		if (!svcFound) FindServices();
		int bits = 0;
		for (int i = 0; i < svc.Size(); i++)
		{
			let s = svc[i];
			if (!s) continue;
			switch (svcKind[i])
			{
			case SV_GRAPPLE:
			{
				int hk = s.GetInt("hooked", "", 0, 0, a);
				int yk = s.GetInt("yanked", "", 0, 0, a);
				if ((hk >= 0 && hk <= HOOK_GRACE) || yk == 1 || yk == 2) bits |= 1;
				if (s.GetInt("stunned", "", 0, 0, a) == 1) bits |= 2;
				break;
			}
			case SV_SHIELD:
				if (s.GetInt("locked", "", 0, 0, a) == 1) bits |= 4;
				break;
			case SV_SABER:
				if (s.GetInt("gripped", "", 0, 0, a) == 1) bits |= 8;
				break;
			default:
				if (s.GetInt("hooked", "", 0, 0, a) == 1) bits |= 1;
				if (s.GetInt("stunned", "", 0, 0, a) == 1) bits |= 2;
				if (s.GetInt("locked", "", 0, 0, a) == 1) bits |= 4;
				if (s.GetInt("gripped", "", 0, 0, a) == 1) bits |= 8;
				break;
			}
		}
		return bits;
	}

	bool HasServices() { if (!svcFound) FindServices(); return svc.Size() > 0; }

	override void WorldUnloaded(WorldEvent e)
	{
		// bars of players travel with them otherwise; a fresh level starts clean
		for (int i = 0; i < bars.Size(); i++) if (bars[i]) bars[i].Destroy();
		bars.Clear();
		mons.Clear();
		monBar.Clear();
		coldPending.Clear();
	}
}
