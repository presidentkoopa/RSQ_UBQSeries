// RSQVR_Service -- RSQ VisualRewards, for any mod that asks by name (nothing links):
//     let s = RSQTHP_Lookup.Find("RSQVR_Service").Next();   // null without VisualRewards
//
//   GetInt "loaded"      1 (the pk3 is here)
//   GetInt "kr.loaded"   1: Kill Rewards is part of this pk3 (Gun Bonsai VR offers its Kill Rewards path only then)
//   GetInt "kr.on"       1 while Kill Rewards is switched on (rsqgb_kr_enabled), 0 off
//   GetInt "kr.perk"     stringArg = BitScavenger / RichBits / Magnet / LuckyKill, objectArg = a player's pawn: the level Kill
//                        Rewards is using for that player (read from Gun Bonsai VR by name; 0 without it)
//   GetDouble "kr.magnet" objectArg = a player's pawn: metres bits drift to that player from (the Magnet node or the
//                        Bits Fly to Me row, whichever is further; 0 = off)
//   GetInt "helper"      objectArg = an actor: 1 when it is one of Brutal Doom's helpers (head hitbox, boot smearer ...) that
//                        never gets a bar, a number or bits (rsqvr/helpers.zs), 0 not
//   GetInt "kr.battery"  (play) intArg = how many, objectArg = the body: that many battery bits burst out of it (RSQ FnF's "Bones
//                        Drop Battery Bits", rsqvr/batterybit.zs; each refills 15% of the toucher's flashlight battery through
//                        FnF). Returns how many came out. Asked whether or not Kill Rewards is on (FnF's own row decides).
//
// THE BOSSFIGHT REWORK'S REQUESTS (2026-11-09; the shared contract, design/MINIBOSS_REWORK.md "The arrival, the HUD and the
// beams"). All from synced play code; each answer depends only on the request and the server's Arrival Beams row, never
// on a player's own settings (netplay):
//   GetInt "beam"        stringArg "v1" | "v2" | "v3" | "v4", intArg 0xRRGGBB, doubleArg size (1.0 = sized to the monster's
//                        own height; 0 = 1.0), objectArg the monster, ALREADY SPAWNED at its spot. Plays that arrival beam
//                        (rsqvr/beams.zs: V1 the beam opens around it; V2 floor ring, slam, rings, white -> colour -> real;
//                        V3 the column that hides it, indoor or outdoor picked from the ceiling above; V4 six beams spiral
//                        in, a skull pillar) with its own sound, and HIDES the monster until the reveal (it does not freeze
//                        it: the caller keeps it from acting). Returns the tics from the call until the monster is shown
//                        again (> 0: V1 7, V2 12, V3 19, V4 31, at every size), or 0 when it did not play (Arrival Beams
//                        off, no / dead monster, an unknown kind, a beam already on that monster). Game tics: the beam
//                        does not slow with RSQ SlowMo's world (a Bossfight's arrival plays inside its landing slow).
//                        nameArg (optional, a role): accepted and ignored; each beam has its own sound (SNDINFO.txt,
//                        RVQB1-4).
//   GetInt "word"        stringArg the word, intArg 0xRRGGBB, doubleArg seconds (0 = 1 s), objectArg the actor: a one-off word
//                        over it in the Word Font (rsqvr/words.zs): the SOTN entrance, drifts up, holds, fades.
//                        Returns 1 (0: no actor).
//   GetInt "word.hold"   stringArg the word, intArg 0xRRGGBB, doubleArg size (1 normal, 2 large and pulsing, 0.6 small; 0 = 1),
//                        objectArg the actor: kept over it until "word.clear" with the same text or it dies; asked again
//                        with the same text, its colour and size change in place. Returns 1 (0: no actor).
//   GetInt "word.clear"  stringArg the word, objectArg the actor: that held word fades. Returns 1.
//   GetInt "pop"         intArg 0xRRGGBB, doubleArg size (0 = 1), objectArg the actor: a pixel ring and star burst at its
//                        middle in that colour. Returns 1 (0: no actor).
// Photosensitive Mode (RSQ Accessibility rsqa_photosafe) is respected by all of them (no fast flicker, flashes dimmed).
// THE WORLD WORDS (2026-11-17, rsqvr/worldwords.zs: the reward words as signs in the 3D world):
//   GetInt "worldword"   stringArg "<WORD>|<place>" (place: over | floor | muzzle:<0 main, 1 off> | at:<x>,<y>,<z> | ahead;
//                        none: over a monster, ahead of a player), nameArg the colour family ('magenta', 'cyan', 'gold'),
//                        objectArg the anchor (a monster, or the player whose moment it is), intArg the player it is for
//                        when the anchor is not a player (-1: anyone's). A flat sign facing you, the same apparent size at
//                        any distance, the monster words' SOTN entrance and life; drawn on that player's machine when his
//                        Reward Words row is In the World or Both. Returns 1 (0: no word or no anchor); never depends on a
//                        player's own setting. RSQ Score asks it for 1UP; REVENGE!, REVIVE! and LEVEL UP! are this pk3's own.
//                        (2026-11-22) place hand:<h>[,<f>[,<u>]] (on what that hand holds, followed), and keys beside the
//                        place: size:<k> (k x the usual size), id:<name> (a new word with that id replaces the player's word
//                        up with it), label (drawn whatever Reward Words says). RSQ Grenade asks it for its kinds' names on the
//                        grenade in the hand ("IMPACT|hand:1,2.8,1.5|size:0.6|id:rsqgn.kind|label", worldwords.zs).
//   A gun's muzzle is asked of any Service named "...MuzzleService": GetString("muzzle.at", "", hand, 0, pawn) -> "x y z"
//                        (map units) or "" (RSQ LaserSight answers: Brutal Doom VR's muzzle table and its measured meshes).
// THE ARCADE GOLD BANNERS AND THE INVULNERABILITY BAR (2026-11-16, design/BANNERS_AND_HUD.md; rsqvr/banners.zs, invbar.zs):
//   GetInt "banner"      (play) stringArg "<MOMENT>|<kind:value>|...", objectArg the player's pawn (null: every player):
//                        queues that banner on that player's HUD (after any of his still showing). Returns 1 (0: an
//                        unknown moment, or four already waiting). MOMENT: REVIVE (headline REVIVE), LIFEUSED (-1UP),
//                        BOSSWIN (BOSS DEFEATED!), BOSSLOSS (BOSS WINS!, red), LIFEUP (+1UP: the badge floats up into RSQ
//                        Score's lives). Chips, in the order given, two to a row:
//                          health:<n>      +n HEALTH (green)          armor:<n>     +n ARMOR (blue)
//                          invuln:<secs>   nS INVULNERABLE (magenta; it blinks and flies up into the invulnerability bar)
//                          mags:full | mags:<n>   MAGS FULL / +n MAGS (white)
//                          lives:<n>       n Doomguy faces, "n HELD" (n LEFT, greyed, on LIFEUSED)
//                          tierup:<t> | tierdown:<t>   TIER UP / TIER DOWN (gold / red) + the tier's swatch and name; t a
//                                          world tier 1..13 (RSQ Monsters' colours), or a name, either with @RRGGBB
//                          nolegendary     NO LEGENDARY (red)
//                        Only what happened, with the real numbers: the caller leaves out what did not.
//   GetIntUI "banner.lives"   (ui; RSQ Score's hud.zs, every frame) stringArg "<lives> <face height px>", intArg / doubleArg
//                        the newest life face's centre x / y in screen px: tells the banners where the +1UP lands. Returns
//                        how many faces to hold back (a +1UP still on its way).
//   GetIntUI "invbar.bottom"  (ui) the screen pixel row under the invulnerability bar while it shows, -1 when it does not
//                        (RSQ Score's combo rows go below it).
//                        BOSSINCOMING (BOSS INCOMING!, the crowned skull): name:<text> (empty: the Boss's clean name, section
//                        9; @<class>: that class's), tier:<n>, thralls:<n>[@RRGGBB,RRGGBB...] (each thrall's crosshair in its
//                        colour; without colours the Boss bar's mockup ones), clock:<secs> (FIGHT IN, counting down)
//                        BIGBOSSINCOMING / BIGBOSSWIN / BIGBOSSLOSS (RSQ Miniboss's Big Boss, 2026-11-16): the same as BOSSINCOMING
//                        (its siren too) / BOSSWIN / BOSSLOSS with the same chips; the headline BIG BOSS INCOMING! / BIG BOSS
//                        DEFEATED! / BIG BOSS WINS!
//   GetInt "toast"       (play) stringArg "<kind>|<text>", objectArg the player's pawn: one chip, low in the view, ~1.5 s
//                        (PRESENTATION_GUIDE.md section 5). kind health / armor / invuln / ammo / lives / up / down / info.
//                        Returns 1 when shown (0: no text, or no VisualRewards: then print your old way)
//   Test (console, sv_cheats): netevent rsqvr_bntest 0..7 (6 BOSS INCOMING!, 7 three toasts), or netevent "rsqvr_banner:<spec>".
// The damage numbers' own hook stays where it was: RSQTHP_DnService "crit" (damnums/events.zs).
class RSQVR_Service : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "loaded") return 1;
		if (request == "kr.loaded") return RSQ_KRHandler(EventHandler.Find("RSQ_KRHandler")) ? 1 : 0;
		if (request == "kr.on") return RSQ_KRHandler.SVB("rsqgb_kr_enabled", true) ? 1 : 0;
		if (request == "kr.perk") return RSQ_KRHandler.Perk(Actor(objectArg), stringArg);
		if (request == "helper") return RSQVR_Helpers.IsHelper(Actor(objectArg)) ? 1 : 0;
		if (request == "kr.battery") return RSQ_KRBatteryBit.Burst(Actor(objectArg), clamp(intArg, 0, 32));
		if (request == "scene.push" || request == "scene.pop")
		{
			let sc = RSQVR_Scenes.Get();
			if (!sc) return 0;
			return request == "scene.push" ? sc.Push(stringArg, intArg, nameArg, int(doubleArg) - 1) : sc.Pop(stringArg);
		}
		if (request == "banner") { let bn = RSQVR_Banners.Get(); return bn ? bn.Add(stringArg, Actor(objectArg)) : 0; }
		if (request == "toast") { let bn = RSQVR_Banners.Get(); return bn ? bn.Toast(stringArg, Actor(objectArg)) : 0; }
		if (request == "beam") return RSQVR_Beam.StartBeam(stringArg, intArg, doubleArg, Actor(objectArg), nameArg);
		if (request == "word" || request == "word.hold" || request == "word.clear" || request == "pop")
		{
			let h = RSQVR_FxHandler.Get();
			if (!h) return 0;
			if (request == "word") return h.WordOnce(stringArg, intArg, doubleArg, Actor(objectArg));
			if (request == "word.hold") return h.WordHold(stringArg, intArg, doubleArg, Actor(objectArg));
			if (request == "word.clear") return h.ClearWord(stringArg, Actor(objectArg));
			return h.PopAt(intArg, doubleArg, Actor(objectArg));
		}
		if (request == "worldword") { let h = RSQVR_FxHandler.Get(); return h ? h.WorldWord(stringArg, nameArg, intArg, Actor(objectArg)) : 0; }
		return 0;
	}

	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "loaded") return 1;
		let bn = RSQVR_Banners.Get();
		if (request == "banner.lives")
		{
			if (!bn) return 0;
			Array<String> a;
			stringArg.Split(a, " ");
			double fh = a.Size() > 1 ? a[1].ToDouble() : 0;
			return bn.LivesExchange(intArg, doubleArg, fh);
		}
		if (request == "invbar.bottom") return bn ? bn.InvBottom() : -1;
		return 0;
	}

	override double GetDouble(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "kr.magnet") { let a = Actor(objectArg); return (a && a.player) ? RSQ_KRHandler.MagnetM(a) : 0; }
		return 0;
	}
}
