// ============================================================================
// THROWN THINGS, THE RIG, VR AND GUN BONSAI -- the Quest series' bonuses that are not melee.
// (Distance Grab's thrown objects and barrels, the Tactical Rig's draw, VR-only feats.)
// Each bonus here is named in RS_PhysicalSeed.Names so the registry picks it up.
//
// WHERE THE FACTS COME FROM -- nothing here links against another mod, and nothing here
// reads a hand pose:
//   RSQDG_ThrowService  Distance Grab's throw ledger: who threw an object, how hard it
//                       landed, whether its landing set it off (a barrel, and any barrel
//                       its blast set off), whether it was caught back out of the air;
//                       and whether a hand is carrying something -- found by name
//   RSQTR_RigService    the Tactical Rig's last draw from a holster (a synced network
//                       event, the same on every machine) -- found by name
//   the killing blow    the inflictor the engine hands WorldThingDied: a puff (hitscan,
//                       flagged ISPUFF by the engine) or a missile, and where it went.
//                       In VR the shot leaves the CONTROLLER, so the shot's own line is the
//                       hand's line -- read from the world, not from the pose.
//   RS_PhysicalNotes    below: a token on the pawn that keeps the last 16 tics of the HEAD's
//                       facing (the pawn's angle and pitch, which the headset drives through
//                       the replicated tic command) and the fire buttons (replicated), and
//                       the flags of the player's last blow (ModifyDamage), so a splash is
//                       told from a direct hit.
//
// WHY NO POSE. The hand fields (AttackPos, OffhandPos, WF_TWOHANDSTABILIZED) exist on the
// local machine only; scoring is play scope and must come out the same everywhere. A shot's
// line, the head's facing and the buttons are all in the playsim already. Where stock VR
// already diverges between machines (a VR shot leaves the controller on the shooter's
// machine and the body on everyone else's), scoring follows each machine's own playsim:
// no worse than the engine, and never one machine's private opinion.
//
// BIG MOMENTS (a short RSQ_SlowMo pulse, handler.zs BigMomentPulse): Powder Keg, Air Catch and
// Blind-fire answer BigMoment(ev, paid). Search "BigMoment" to find each one's rule.
// ============================================================================

class RS_PhysicalSeed play
{
	static void Names(out Array<String> into)
	{
		into.Push("RS_Bonus_Thrown");
		into.Push("RS_Bonus_PowderKeg");
		into.Push("RS_Bonus_AirCatch");
		into.Push("RS_Bonus_Skeet");
		into.Push("RS_Bonus_QuickDraw");
		into.Push("RS_Bonus_NoLook");
		into.Push("RS_Bonus_BlindFire");
		into.Push("RS_Bonus_OffHand");
		into.Push("RS_Bonus_FullHands");
		// the suite round (10-27)
		into.Push("RS_Bonus_BodyBlow");
		into.Push("RS_Bonus_HandMeDown");
		into.Push("RS_Bonus_HotSwap");
		into.Push("RS_Bonus_BulletTime");
		into.Push("RS_Bonus_TwoGuns");
	}
}

// The shared base: makes sure the killer carries the notes token (given at the first kill
// the player scores -- the only play hook this file has without a handler of its own; until
// then a missile's fire tic falls back to "now"), and the SlowMo question.
class RS_PhysicalBonus : RS_ScoreBonus
{
	// BigMoment (bonus.zs) is answered by Powder Keg, Air Catch and Blind-fire below.
	override void Commit(RS_ScoreEvent ev) { RS_PhysicalNotes.Ensure(ev.killer); }
}


// ============================================================================
// RS_Physical -- the facts, worked out from the event. Pure reads.
// ============================================================================
class RS_Physical play
{
	enum EShot
	{
		SHOT_NONE,
		SHOT_HITSCAN,   // a puff (or a puffless trace: the pawn itself as inflictor)
		SHOT_MISSILE,   // a projectile the killer fired
	}

	// Ask Distance Grab's ledger about an object (or a hand). -1: no answer / not loaded.
	static int AskGrab(String request, Object about, int arg = 0)
	{
		let it = ServiceIterator.Find("RSQDG_ThrowService");
		Service s;
		while (s = it.Next())
		{
			int v = s.GetInt(request, "", arg, 0, about);
			if (v >= 0) return v;
		}
		return -1;
	}

	static int AskRig(String request, Actor who)
	{
		let it = ServiceIterator.Find("RSQTR_RigService");
		Service s;
		while (s = it.Next())
		{
			int v = s.GetInt(request, "", 0, 0, who);
			if (v >= 0) return v;
		}
		return -1;
	}

	// RSQ_SlowMo's clock (RSQSM_Service): "slowmo.active" 1 while the world is slowed, 0 not.
	// -1: not loaded, or a SlowMo that does not answer it.
	static int AskSlowMo(String request)
	{
		let it = ServiceIterator.Find("RSQSM_Service");
		Service s;
		while (s = it.Next())
		{
			int v = s.GetInt(request, "", 0, 0, null);
			if (v >= 0) return v;
		}
		return -1;
	}

	// Which hand fired the killing shot: 1 the main hand's trigger alone, 2 the off hand's alone,
	// 0 both or neither (the buttons at the tic it left; replicated).
	static int ShotHand(RS_ScoreEvent ev, int kind)
	{
		int b = ButtonsAt(ev.killer, ShotAge(ev, kind));
		bool m = (b & BT_ATTACK) != 0, o = (b & BT_OFFHANDATTACK) != 0;
		if (m && !o) return 1;
		if (o && !m) return 2;
		return 0;
	}

	static String AskRigString(String request, Actor who)
	{
		let it = ServiceIterator.Find("RSQTR_RigService");
		Service s;
		while (s = it.Next())
		{
			String v = s.GetString(request, "", 0, 0, who);
			if (v != "") return v;
		}
		return "";
	}

	// The inflictor is an object THIS killer threw with Distance Grab (recently).
	static bool ThrownBy(RS_ScoreEvent ev)
	{
		return ev.inflictor && ev.killerNum >= 0 && AskGrab("throw.by", ev.inflictor) == ev.killerNum;
	}

	// The melee family's damage types (melee.zs reads the same ones; measured there in
	// brutal22test6's actors). A kill by any of these is not a SHOT.
	static bool MeleeType(Name dt)
	{
		return dt == 'Melee' || dt == 'Kick' || dt == 'HeadKick' || dt == 'Stomp'
			|| dt == 'ExtremePunches' || dt == 'Saw' || dt == 'Cut' || dt == 'Saber' || dt == 'Fatality';
	}

	static int ShotKind(RS_ScoreEvent ev)
	{
		let k = ev.killer;
		let inf = ev.inflictor;
		if (!k || !inf || !ev.victim || ev.ringOut) return SHOT_NONE;
		if (MeleeType(ev.damageType)) return SHOT_NONE;
		// A SHOT SENT BACK is not your shot: a monster's fireball the saber or the Force turned is
		// a missile whose target is now you, and a bullet the shield returned is a puff -- the melee
		// family pays it (Return to Sender), and the hand that fired is not yours to judge.
		if (RS_Melee.Returned(ev)) return SHOT_NONE;
		if (inf.bIsPuff) return ThrownBy(ev) ? SHOT_NONE : SHOT_HITSCAN;
		if (inf.bMissile && inf.target == k) return SHOT_MISSILE;
		if (inf == k) return SHOT_HITSCAN;
		return SHOT_NONE;
	}

	// The killer's eye, in play scope: the pawn's position at the player's view height.
	static Vector3 Eye(Actor k)
	{
		return (k.pos.x, k.pos.y, k.player ? k.player.viewz : k.pos.z + k.height * 0.75);
	}

	// How many tics ago the killing missile left: its distance from the eye over its speed.
	// Hitscan is this tic (0).
	static int ShotAge(RS_ScoreEvent ev, int kind)
	{
		if (kind != SHOT_MISSILE) return 0;
		double spd = ev.inflictor.Vel.Length();
		if (spd < 1.0) return 0;
		Vector3 d = ev.inflictor.pos - Eye(ev.killer);
		return int(d.Length() / spd + 0.5);
	}

	// Was the killing blow a splash (a radius attack)? -1: not known (no notes yet).
	static int Splash(RS_ScoreEvent ev)
	{
		let n = RS_PhysicalNotes.Of(ev.killer);
		if (!n || n.lastTic != level.maptime || n.lastVictim != ev.victim) return -1;
		return (n.lastFlags & DMG_EXPLOSION) ? 1 : 0;
	}

	// Where the killing blow landed: a hitscan's puff stands at the hit point on the victim
	// (P_LineAttack's bleed position); a missile is where it struck.
	static Vector3 HitPoint(RS_ScoreEvent ev)
	{
		let inf = ev.inflictor;
		if (inf && inf != ev.killer) return inf.pos;
		return ev.victim.pos + (0, 0, ev.victim.height * 0.5);
	}

	// The shot's direction as (yaw, pitch), Doom convention (pitch positive DOWN).
	// Missile: its velocity. Hitscan: from the eye to the hit point. NOT the puff's angle:
	// a puff on a bleeding monster is spawned with no direction at all (p_map.cpp
	// P_LineAttack: the temporary inflictor puff gets nullAngle), so the eye's line stands in
	// for the hand's -- off by at most the hand's reach (about 0.7 m) over the shot's length.
	static Vector2 ShotDir(RS_ScoreEvent ev, int kind)
	{
		if (kind == SHOT_MISSILE)
		{
			Vector3 v = ev.inflictor.Vel;
			return (atan2(v.y, v.x), -atan2(v.z, v.xy.Length()));
		}
		Vector3 d = HitPoint(ev) - Eye(ev.killer);
		return (atan2(d.y, d.x), -atan2(d.z, d.xy.Length()));
	}

	// The head's facing when the shot left (yaw, pitch). The notes' ring, or now.
	static Vector2 HeadAt(Actor k, int age)
	{
		let n = RS_PhysicalNotes.Of(k);
		if (n && age > 0)
		{
			int t = level.maptime - age;
			int s = t % RS_PhysicalNotes.RING;
			if (s < 0) s += RS_PhysicalNotes.RING;
			if (n.ringTic[s] == t) return (n.ringYaw[s], n.ringPitch[s]);
		}
		return (k.angle, k.pitch);
	}

	static int ButtonsAt(Actor k, int age)
	{
		let n = RS_PhysicalNotes.Of(k);
		if (n && age > 0)
		{
			int t = level.maptime - age;
			int s = t % RS_PhysicalNotes.RING;
			if (s < 0) s += RS_PhysicalNotes.RING;
			if (n.ringTic[s] == t) return n.ringButtons[s];
		}
		return k.player ? k.player.cmd.buttons : 0;
	}

	// The angle between two (yaw, pitch) directions, degrees.
	static double Between(Vector2 a, Vector2 b)
	{
		Vector3 u = (cos(a.y) * cos(a.x), cos(a.y) * sin(a.x), -sin(a.y));
		Vector3 v = (cos(b.y) * cos(b.x), cos(b.y) * sin(b.x), -sin(b.y));
		return acos(clamp(u dot v, -1.0, 1.0));
	}

	// Does the level leave a clear line from a to b? (TRF_THRUACTORS: geometry only, the
	// same question event.zs asks for Curveball.)
	static bool Clear(Actor from, Vector3 a, Vector3 b)
	{
		Vector3 d = b - a;
		double len = d.Length();
		if (len < 1.0) return true;
		FLineTraceData data;
		from.LineTrace(atan2(d.y, d.x), len, -atan2(d.z, d.xy.Length()),
			TRF_THRUACTORS | TRF_ABSPOSITION, a.z, a.x, a.y, data);
		if (data.HitType == FLineTraceData.TRACE_HitNone) return true;
		return data.Distance >= len - 1.0;
	}

	// Could the eye see any of the victim (feet, middle, head)?
	static bool EyeSees(Actor k, Actor v)
	{
		Vector3 eye = Eye(k);
		for (int i = 0; i < 3; i++)
		{
			double z = v.pos.z + (i == 0 ? 2.0 : (i == 1 ? v.height * 0.5 : v.height - 2.0));
			if (Clear(k, eye, (v.pos.x, v.pos.y, z))) return true;
		}
		return false;
	}
}


// ============================================================================
// RS_PhysicalNotes -- a token on the pawn. Play scope; saved with the player.
// ============================================================================
class RS_PhysicalNotes : Inventory
{
	const RING = 16;
	double ringYaw[RING];
	double ringPitch[RING];
	int    ringButtons[RING];
	int    ringTic[RING];

	// the player's last blow (ModifyDamage hears every one the pawn deals)
	Actor lastVictim;
	int   lastFlags;
	int   lastTic;

	// Powder Keg's crowd count: kills by thrown blasts close together
	int kegKills;
	int kegTic;

	// Hot Swap: the last kill, and with what
	int lastKillTic;
	String lastKillWeapon;

	// Two Guns: the last shot kill's hand (RS_Physical.ShotHand) and when
	int lastShotHand;
	int lastShotTic;

	Default
	{
		Inventory.MaxAmount 1;
		Inventory.InterHubAmount 1;
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.QUIET
		+INVENTORY.KEEPDEPLETED
		-COUNTITEM
	}

	States
	{
	Spawn:
		TNT1 A -1;
		stop;
	}

	static RS_PhysicalNotes Of(Actor k)
	{
		return k ? RS_PhysicalNotes(k.FindInventory("RS_PhysicalNotes")) : null;
	}

	static void Ensure(Actor k)
	{
		if (k && k.player && !k.FindInventory("RS_PhysicalNotes")) k.GiveInventory("RS_PhysicalNotes", 1);
	}

	override void DoEffect()
	{
		Super.DoEffect();
		if (!owner || !owner.player) return;
		int s = level.maptime % RING;
		ringYaw[s] = owner.angle;
		ringPitch[s] = owner.pitch;
		ringButtons[s] = owner.player.cmd.buttons;
		ringTic[s] = level.maptime;
	}

	// Active (passive false): the owner dealt this; `source` is then the one HIT
	// (p_interaction.cpp GetModifiedDamage(mod, damage, false, inflictor, target, flags)).
	// Nothing is changed: newdamage is left alone.
	override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
	{
		if (passive) return;
		lastVictim = source;
		lastFlags = flags;
		lastTic = level.maptime;
	}
}


// ================================================================== the bonuses

// Thrown: killed by something you threw with Distance Grab -- the impact itself. Pays on
// how hard it landed: 0.2 for a lob, +0.03 per m/s over 3, up to 0.5 (a hard flick).
class RS_Bonus_Thrown : RS_PhysicalBonus
{
	const MULT = 0.2;
	const PER_MPS = 0.03;
	const FROM_MPS = 3.0;
	const MAXMULT = 0.5;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Thrown"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Physical.ThrownBy(ev)) return 0.0;
		if (RS_Physical.AskGrab("throw.blast", ev.inflictor) == 1) return 0.0;   // Powder Keg's
		int cms = RS_Physical.AskGrab("throw.cms", ev.inflictor);
		double mps = cms > 0 ? cms / 100.0 : 0.0;
		return clamp(MULT + PER_MPS * (mps - FROM_MPS), MULT, MAXMULT);
	}
}

// Powder Keg: killed by the blast of a barrel your throw set off (or one its blast set
// off). Each kill by thrown blasts within a second of the last pays more: a barrel into
// a crowd. 0.3, +0.2 per earlier kill, up to 1.1.
class RS_Bonus_PowderKeg : RS_PhysicalBonus
{
	const MULT = 0.3;
	const PER = 0.2;
	const MAXMULT = 1.1;
	const WINDOW = 35;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Powder Keg"; }

	private bool Keg(RS_ScoreEvent ev)
	{
		return RS_Physical.ThrownBy(ev) && RS_Physical.AskGrab("throw.blast", ev.inflictor) == 1;
	}

	private int Earlier(RS_ScoreEvent ev)
	{
		let n = RS_PhysicalNotes.Of(ev.killer);
		return (n && n.kegKills > 0 && level.maptime - n.kegTic <= WINDOW) ? n.kegKills : 0;
	}

	override double Evaluate(RS_ScoreEvent ev)
	{
		return Keg(ev) ? min(MAXMULT, MULT + PER * Earlier(ev)) : 0.0;
	}

	override void Commit(RS_ScoreEvent ev)
	{
		Super.Commit(ev);
		if (!Keg(ev)) return;
		let n = RS_PhysicalNotes.Of(ev.killer);
		if (!n) return;
		n.kegKills = Earlier(ev) + 1;
		n.kegTic = level.maptime;
	}

	// BigMoment: the third kill of one blast and on.
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid >= MULT + 2 * PER - 0.001; }
}

// Air Catch: killed by something you caught back out of the air after throwing it, then threw
// again -- before it ever landed. 1.0, +0.5 per extra catch, up to 2.0. Rare by design.
class RS_Bonus_AirCatch : RS_PhysicalBonus
{
	const MULT = 1.0;
	const PER = 0.5;
	const MAXMULT = 2.0;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Air Catch"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Physical.ThrownBy(ev)) return 0.0;
		int j = RS_Physical.AskGrab("throw.juggle", ev.inflictor);
		return j >= 1 ? min(MAXMULT, MULT + PER * (j - 1)) : 0.0;
	}
	// BigMoment: always.
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// Skeet: the VICTIM was in the air -- knocked up, leaping, falling off a ledge. The mirror
// of Air. Not a flyer (a Cacodemon is always up there), not standing on another body.
class RS_Bonus_Skeet : RS_PhysicalBonus
{
	const MULT = 0.25;
	const MINUP = 24.0;     // map units over its floor: 0.85 m (x 1.2 / 34)
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Skeet"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let v = ev.victim;
		if (!ev.killer || !v) return 0.0;
		if (v.bFloat || v.bNoGravity || v.bOnMobj || v.waterlevel >= 2) return 0.0;
		return (v.pos.z - v.floorz >= MINUP) ? MULT : 0.0;
	}
}

// Quick Draw: killed with the weapon you just drew from a Tactical Rig holster, within a
// second of it being ready (the window counts from the draw, and includes the raise).
class RS_Bonus_QuickDraw : RS_PhysicalBonus
{
	const MULT = 0.35;
	const WINDOW = 42;      // tics from the draw: a second, plus the switch -- measured on rig B, BD22Q:
	                        // drawn at t40, the shotgun up at t44 and able to fire at t45
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Quick Draw"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let k = ev.killer;
		if (!k || !k.player || !k.player.ReadyWeapon) return 0.0;
		if (RS_Physical.ThrownBy(ev)) return 0.0;
		int t = RS_Physical.AskRig("rig.drawtic", k);
		if (t < 0 || level.maptime - t > WINDOW) return 0.0;
		return (k.player.ReadyWeapon.GetClassName() == RS_Physical.AskRigString("rig.drawn", k)) ? MULT : 0.0;
	}
}

// No-Look: the killing shot left more than 60 degrees away from where your head was facing.
// In flat Doom the gun is the eye; in VR it is a hand.
class RS_Bonus_NoLook : RS_PhysicalBonus
{
	const MULT = 0.3;
	const ANGLE = 60.0;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "No-Look"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		int kind = RS_Physical.ShotKind(ev);
		if (kind == RS_Physical.SHOT_NONE) return 0.0;
		if (kind == RS_Physical.SHOT_MISSILE && RS_Physical.Splash(ev) != 0) return 0.0;
		int age = RS_Physical.ShotAge(ev, kind);
		Vector2 shot = RS_Physical.ShotDir(ev, kind);
		Vector2 head = RS_Physical.HeadAt(ev.killer, age);
		return RS_Physical.Between(shot, head) > ANGLE ? MULT : 0.0;
	}
}

// Blind-fire: your EYE had no line to the victim -- and the shot, from your hand, did. Round
// a corner, over cover. It cannot exist in flat Doom. A direct hit only (no splash), and the
// hand has to be on your side of the wall, within arm's reach of the eye and in the eye's
// own clear space -- so a gun pushed THROUGH a wall pays nothing:
//   a missile   its line is traced back to the point nearest the eye: that is the hand.
//   hitscan     the engine keeps no line (the inflictor puff has no direction), so the
//               question becomes "could a hand have made this shot": some point round the
//               eye, at arm's reach, that the eye can see and that can see the hit point.
class RS_Bonus_BlindFire : RS_PhysicalBonus
{
	const MULT = 0.4;
	const REACH = 40.0;     // map units: 1.2 m from the eye
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Blind-fire"; }

	override double Evaluate(RS_ScoreEvent ev)
	{
		int kind = RS_Physical.ShotKind(ev);
		if (kind == RS_Physical.SHOT_NONE || ev.inflictor == ev.killer) return 0.0;
		if (kind == RS_Physical.SHOT_MISSILE && RS_Physical.Splash(ev) != 0) return 0.0;
		let k = ev.killer;
		let v = ev.victim;
		if (RS_Physical.EyeSees(k, v)) return 0.0;
		return HandHadLine(ev, kind) ? MULT : 0.0;
	}

	private bool HandHadLine(RS_ScoreEvent ev, int kind)
	{
		let k = ev.killer;
		let inf = ev.inflictor;
		Vector3 eye = RS_Physical.Eye(k);
		Vector3 hit = RS_Physical.HitPoint(ev);
		if (kind == RS_Physical.SHOT_MISSILE)
		{
			Vector2 dir = RS_Physical.ShotDir(ev, kind);
			Vector3 u = (cos(dir.y) * cos(dir.x), cos(dir.y) * sin(dir.x), -sin(dir.y));
			double t = (eye - hit) dot u;
			Vector3 hand = hit + u * t;
			if ((hand - eye).Length() > REACH) return false;
			return RS_Physical.Clear(k, eye, hand) && RS_Physical.Clear(k, hand, hit);
		}
		// Hitscan: eight directions round the eye (from the line to the victim), two reaches,
		// three heights -- 48 points, two traces each at most, and only ever reached when the
		// eye is already blind to the victim (rare). Nearest first, so a hand just past the
		// corner is found early.
		double toward = atan2(hit.y - eye.y, hit.x - eye.x);
		static const double RR[] = { 24, 36 };
		static const double DZ[] = { 0, 14, -14 };
		for (int r = 0; r < 2; r++)
		for (int z = 0; z < 3; z++)
		for (int a = 0; a < 8; a++)
		{
			double ang = toward + ((a & 1) ? 1 : -1) * 45.0 * ((a + 1) / 2);
			if (a == 7) ang = toward + 180.0;
			Vector3 hand = (eye.x + cos(ang) * RR[r], eye.y + sin(ang) * RR[r], eye.z + DZ[z]);
			if (RS_Physical.Clear(k, eye, hand) && RS_Physical.Clear(k, hand, hit)) return true;
		}
		return false;
	}

	override bool Supersedes(RS_ScoreBonus other) const { return other is "RS_Bonus_NoLook"; }
	// BigMoment: always.
	override bool BigMoment(RS_ScoreEvent ev, double paid) const { return paid > 0; }
}

// Off-hand: the kill was the OFF hand's shot -- its trigger alone was held when it fired
// (BT_OFFHANDATTACK, which QuestZDoom routes to the off-hand weapon; replicated).
class RS_Bonus_OffHand : RS_PhysicalBonus
{
	const MULT = 0.2;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Off-hand"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		int kind = RS_Physical.ShotKind(ev);
		if (kind == RS_Physical.SHOT_NONE) return 0.0;
		int b = RS_Physical.ButtonsAt(ev.killer, RS_Physical.ShotAge(ev, kind));
		return ((b & BT_OFFHANDATTACK) && !(b & BT_ATTACK)) ? MULT : 0.0;
	}
}

// Full Hands: a shot kill while one of your hands is carrying something with Distance Grab
// -- a barrel held up as cover, a gun in one hand.
class RS_Bonus_FullHands : RS_PhysicalBonus
{
	const MULT = 0.25;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Full Hands"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (RS_Physical.ShotKind(ev) == RS_Physical.SHOT_NONE) return 0.0;
		if (RS_Physical.AskGrab("hold.full", ev.killer, 0) == 1) return MULT;
		if (RS_Physical.AskGrab("hold.full", ev.killer, 1) == 1) return MULT;
		return 0.0;
	}
}


// ---------------------------------------------------------------- the suite round (10-27)

// Body Blow: killed by a corpse you threw with Distance Grab (rsqdg_corpses on): the inflictor is a
// dead monster. On top of Thrown.
class RS_Bonus_BodyBlow : RS_PhysicalBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Body Blow"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Physical.ThrownBy(ev)) return 0.0;
		let inf = ev.inflictor;
		return (inf.bIsMonster && inf.health <= 0) ? MULT : 0.0;
	}
}

// Hand-Me-Down: killed by a weapon a monster dropped, thrown with Distance Grab -- a dead zombie's
// rifle across the room. A monster's drop is a weapon that appeared at its body within two seconds
// of its death (RS_ScoreShots.MonsterDrop). On top of Thrown.
class RS_Bonus_HandMeDown : RS_PhysicalBonus
{
	const MULT = 0.3;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Hand-Me-Down"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		if (!RS_Physical.ThrownBy(ev)) return 0.0;
		let inf = ev.inflictor;
		return RS_ScoreShots.MonsterDrop(inf) ? MULT : 0.0;
	}
}

// Hot Swap: mid-fight, you put one gun away and drew another from a Tactical Rig holster, and the
// drawn gun killed: your last kill was with something else, at most 3 s before the draw, and this
// kill comes at most 3 s after it. (Quick Draw pays a kill inside 42 tics of any draw; this pays the
// swap itself, and they stack.)
class RS_Bonus_HotSwap : RS_PhysicalBonus
{
	const MULT = 0.25;
	const WINDOW = 105;
	override int Family() const { return FAM_DARING; }
	override String DisplayName() const { return "Hot Swap"; }
	override double Evaluate(RS_ScoreEvent ev)
	{
		let k = ev.killer;
		if (!k || !k.player || !k.player.ReadyWeapon || ev.ringOut) return 0.0;
		if (RS_Physical.ThrownBy(ev)) return 0.0;
		let n = RS_PhysicalNotes.Of(k);
		if (!n || n.lastKillTic <= 0) return 0.0;
		int t = RS_Physical.AskRig("rig.drawtic", k);
		if (t < 0 || level.maptime - t > WINDOW) return 0.0;
		String now = k.player.ReadyWeapon.GetClassName();
		if (now != RS_Physical.AskRigString("rig.drawn", k)) return 0.0;
		if (n.lastKillTic > t || t - n.lastKillTic > WINDOW) return 0.0;
		return (n.lastKillWeapon != "" && n.lastKillWeapon != now) ? MULT : 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		Super.Commit(ev);
		let k = ev.killer;
		let n = RS_PhysicalNotes.Of(k);
		if (!n || !k.player) return;
		n.lastKillTic = level.maptime;
		n.lastKillWeapon = "";
		if (k.player.ReadyWeapon) n.lastKillWeapon = k.player.ReadyWeapon.GetClassName();
	}
}

// Bullet Time: SLOW MOTION MULTIPLIES STYLE, IT IS NOT AN EASY MODE (the owner, 10-27). A kill while
// RSQ_SlowMo has the world slowed (held, a reload's moment, an upgrade's pulse -- but not inside the
// pulse this scorer itself asked for) pays rs_score_slowstyle percent (50) of what the kill's style,
// daring and melee bonuses paid. A plain kill in slow motion pays nothing more. (It paid a flat 0.15
// on every kill before.)
class RS_Bonus_BulletTime : RS_PhysicalBonus
{
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Bullet Time"; }
	override double Evaluate(RS_ScoreEvent ev) { return 0.0; }
	override double AfterOthers(RS_ScoreEvent ev, Array<RS_ScoreBonus> all, Array<double> mults, int me)
	{
		if (!ev.killer || ev.ringOut || !RS_Grapple.SlowNow(ev)) return 0.0;
		double sum = 0.0;
		for (int b = 0; b < all.Size(); b++)
			if (b != me && mults[b] > 0.0 && all[b].Family() != FAM_EFFICIENCY) sum += mults[b];
		return sum * clamp(RS_ScoreHandler.CvarInt("rs_score_slowstyle", 50), 0, 200) / 100.0;
	}
}

// Two Guns: a gun in each hand, both killing -- this shot kill came from one hand's trigger and your
// last shot kill, inside a second, from the other's.
class RS_Bonus_TwoGuns : RS_PhysicalBonus
{
	const MULT = 0.25;
	const WINDOW = 35;
	override int Family() const { return FAM_STYLE; }
	override String DisplayName() const { return "Two Guns"; }
	private int Hand(RS_ScoreEvent ev)
	{
		int kind = RS_Physical.ShotKind(ev);
		return kind == RS_Physical.SHOT_NONE ? 0 : RS_Physical.ShotHand(ev, kind);
	}
	override double Evaluate(RS_ScoreEvent ev)
	{
		int h = Hand(ev);
		let n = RS_PhysicalNotes.Of(ev.killer);
		if (h == 0 || !n || n.lastShotHand == 0 || n.lastShotHand == h) return 0.0;
		return (level.maptime - n.lastShotTic <= WINDOW) ? MULT : 0.0;
	}
	override void Commit(RS_ScoreEvent ev)
	{
		Super.Commit(ev);
		int h = Hand(ev);
		let n = RS_PhysicalNotes.Of(ev.killer);
		if (h == 0 || !n) return;
		n.lastShotHand = h;
		n.lastShotTic = level.maptime;
	}
}
