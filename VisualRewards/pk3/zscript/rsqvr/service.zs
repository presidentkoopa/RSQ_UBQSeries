// RSQVR_Service -- RSQ VisualRewards, for any mod that asks by name (nothing links):
//     let s = ServiceIterator.Find("RSQVR_Service").Next();   // null without VisualRewards
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
//                        over it in RS Score's font (rsqvr/words.zs): pops, flickers to white, drifts up, holds, fades.
//                        Returns 1 (0: no actor).
//   GetInt "word.hold"   stringArg the word, intArg 0xRRGGBB, doubleArg size (1 normal, 2 large and pulsing, 0.6 small; 0 = 1),
//                        objectArg the actor: kept over it until "word.clear" with the same text or it dies; asked again
//                        with the same text, its colour and size change in place. Returns 1 (0: no actor).
//   GetInt "word.clear"  stringArg the word, objectArg the actor: that held word fades. Returns 1.
//   GetInt "pop"         intArg 0xRRGGBB, doubleArg size (0 = 1), objectArg the actor: a pixel ring and star burst at its
//                        middle in that colour. Returns 1 (0: no actor).
// Photosensitive Mode (RSQ Accessibility rsqa_photosafe) is respected by all of them (no fast flicker, flashes dimmed).
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
		return 0;
	}

	override double GetDouble(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (request == "kr.magnet") { let a = Actor(objectArg); return (a && a.player) ? RSQ_KRHandler.MagnetM(a) : 0; }
		return 0;
	}
}
