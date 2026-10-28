// ============================================================================
// RSQMB_Service -- for other mods, found by name (nothing links):
//   ServiceIterator.Find("RSQMB_Service").Next().GetInt("miniboss", "", 0, 0, monster)
// objectArg = the monster asked about; requests without one answer for the level. -1: unknown.
//
//   miniboss      1 a living miniboss of this set piece, else 0      (none: how many are alive)
//   thrall        1 a thrall bound to a living miniboss, else 0
//   enraged       1 enraged by the greed rule now, else 0            (none: 1 while any rage runs)
//   lives         lives left, the current one included (miniboss), else 0
//   invulnerable  1 while its lost-life invulnerability lasts
//   shield        damage it takes now, permille (living thralls x inherited toughness; 0 invulnerable)
//   greed         1 while its greed is armed (struck while thralls live; comes due with the window)
//   window        tics left in the slow window (no object needed)
//   living        its living thralls (miniboss or thrall: the set piece it belongs to)
//   legendary     1 if it inherited legendary status
// GetObject("boss", "", 0, 0, thrall) -> the thrall's miniboss; ("boss", "", n) -> the n-th miniboss.
// GetObject("thrall", "", n, 0, miniboss) -> its n-th thrall (dead or alive), null past the end.
// GetString("powers", "", 0, 0, miniboss) -> what it inherited, comma-separated.
// Play, ui and data scope all answer the same.
// ============================================================================

class RSQMB_Service : Service
{
	static clearscope RSQMB_Boss BossOf(Object o)
	{
		let a = Actor(o);
		if (!a) return null;
		let w = RSQMB_Ward(a.FindInventory("RSQMB_Ward"));
		if (w && w.boss) return w.boss;
		let t = RSQMB_Thrall(a.FindInventory("RSQMB_Thrall"));
		if (t && t.boss) return t.boss;
		return null;
	}

	override int GetIntData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQMB_Handler(EventHandler.Find("RSQMB_Handler"));
		if (!h) return -1;
		let a = Actor(objectArg);
		let b = BossOf(a);
		bool isBoss = b && a && b.mb == a && !b.done && a.health > 0;
		bool isThrall = b && a && b.mb != a && !b.done && a.health > 0;
		if (request ~== "miniboss")
		{
			if (a) return isBoss ? 1 : 0;
			int n = 0;
			for (int i = 0; i < h.bosses.Size(); i++) if (h.bosses[i] && !h.bosses[i].done) n++;
			return n;
		}
		if (request ~== "thrall") return isThrall ? 1 : 0;
		if (request ~== "enraged")
		{
			if (a) return (a.FindInventory("RSQMB_Rage") && a.health > 0) ? 1 : 0;
			return h.rageCount > 0 ? 1 : 0;
		}
		if (request ~== "window") return max(0, h.windowEnd - level.maptime);
		if (request ~== "lives") return isBoss ? b.lives : 0;
		if (request ~== "invulnerable") return (isBoss && b.Invulnerable()) ? 1 : 0;
		if (request ~== "shield") return isBoss ? (b.Invulnerable() ? 0 : int(b.TakeFactorData() * 1000)) : 1000;
		if (request ~== "greed") return (isBoss && b.greedArmed) ? 1 : 0;
		if (request ~== "living") return (b && !b.done) ? b.Living() : 0;
		if (request ~== "legendary") return (isBoss && b.legendary) ? 1 : 0;
		return -1;
	}
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetIntData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }
	override int GetIntUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetIntData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }

	override Object GetObjectData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let h = RSQMB_Handler(EventHandler.Find("RSQMB_Handler"));
		if (!h) return null;
		if (request ~== "boss")
		{
			if (objectArg) { let b = BossOf(objectArg); return b ? b.mb : null; }
			return (intArg >= 0 && intArg < h.bosses.Size() && h.bosses[intArg]) ? h.bosses[intArg].mb : null;
		}
		if (request ~== "thrall")
		{
			let b = BossOf(objectArg);
			return (b && intArg >= 0 && intArg < b.thr.Size()) ? b.thr[intArg] : null;
		}
		return null;
	}
	override Object GetObject(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetObjectData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }
	override Object GetObjectUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetObjectData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }

	override String GetStringData(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		if (!(request ~== "powers")) return "";
		let b = BossOf(objectArg);
		if (!b) return "";
		String s = "";
		for (int i = 0; i < b.powers.Size(); i++) s = s .. (i ? "," : "") .. b.powers[i];
		return s;
	}
	override String GetString(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetStringData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }
	override String GetStringUI(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{ return GetStringData(request, stringArg, intArg, doubleArg, objectArg, nameArg); }
}
