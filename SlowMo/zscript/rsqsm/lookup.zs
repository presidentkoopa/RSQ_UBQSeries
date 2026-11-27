// RSQSM_Lookup -- ServiceIterator.Find, remembered (tools/lookup/lookup_template.zs, one copy per mod under its own prefix,
// written by tools/lookup/gen_lookup.sh). Every mod still loads and plays alone.
//
// WHY (performance, 2026-11-27, measured on the Windows rig with the full load order in a fight): QuestZDoom 17.3's
// ServiceIterator.Find(n) walks the engine's whole service map, lower-casing every service's class name and testing n as a
// part of it (wadsrc/static/zscript/engine/service.zs Next), about 0.01 ms a lookup; the series made 76 lookups a tic,
// 48 of them at eight call sites. The map is filled once at startup and never changes until the engine shuts down
// (src/common/scripting/interface/vmnatives.cpp InitServices / ClearServices), and each service is ONE object for the whole
// session, so the matches for a name are the same objects in the same order every time. They are found once and kept.
//
// USE: RSQSM_Lookup.Find("X") wherever ServiceIterator.Find("X") was. Next() hands out the same matches, in the same order,
// as the engine's iterator would (null after the last), so a call site changes nothing else. Any scope (clearscope).
//
// THE STORE IS A SERVICE because services are the only script objects the engine keeps for a whole session in every scope
// (play, ui and data alike). Its class name contains no service name the series asks for, so no lookup ever finds it.
class RSQSM_LookupStore : Service
{
	private Array<Name> asked;        // the names looked up so far (Name compares ignoring case, as the engine's match does)
	private Array<int> first, count;  // where each name's matches start in hits, and how many there are
	private Array<Service> hits;

	// the matches for n, found by the engine's own iterator the first time n is asked
	clearscope int Matches(Name n)
	{
		int i = asked.Find(n);
		if (i < asked.Size()) return i;
		first.Push(hits.Size());
		int c = 0;
		let it = ServiceIterator.Find(n);
		Service s;
		while (s = it.Next()) { hits.Push(s); c++; }
		count.Push(c);
		asked.Push(n);
		return asked.Size() - 1;
	}
	clearscope Service Hit(int k, int j) const { return j < count[k] ? hits[first[k] + j] : null; }
}

class RSQSM_Lookup
{
	private RSQSM_LookupStore store;
	private int key, pos;
	private ServiceIterator raw;      // no store (cannot happen while this pk3 is loaded): the engine's own iterator

	static clearscope RSQSM_Lookup Find(Name n)
	{
		let l = new("RSQSM_Lookup");
		l.store = RSQSM_LookupStore(Service.Find("RSQSM_LookupStore"));
		if (l.store) l.key = l.store.Matches(n);
		else l.raw = ServiceIterator.Find(n);
		return l;
	}
	clearscope Service Next()
	{
		if (!store) return raw ? raw.Next() : null;
		return store.Hit(key, pos++);
	}
}
