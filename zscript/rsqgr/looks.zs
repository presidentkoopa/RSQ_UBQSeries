// THE SEAM, looks side -- a STUB owned by core, answering the JP defaults so the
// mod works alone. The monster builder (branch agent-monster) replaces this file
// whole with the JP / CombatFX / Ballistics sets. The contract:
//
//   Sound(what)   a SNDINFO name, "" for silence   fire loop swish hitwall hitflesh retract
//   Sprite(what)  a 4-letter sprite name           open closed link
//   Spark(at, what)  an impact effect, or nothing  wall flesh
//
// The JP set is jpalomo's hook (jp_original/): OCLW/CCLW claw (here RSGH/RSGK),
// tenda0 (RSGR) and his five sounds. JP's hook makes no spark.
class RSQGR_Looks
{
	static String Sound(Name what)
	{
		if (what == 'fire') return "rsqgr/fire";
		if (what == 'loop') return "rsqgr/loop";
		if (what == 'swish') return "rsqgr/swish";
		if (what == 'hitwall') return "rsqgr/hit/terrain";
		if (what == 'hitflesh') return "rsqgr/hit/flesh";
		if (what == 'retract') return "rsqgr/loop";
		return "";
	}

	static Name Sprite(Name what)
	{
		if (what == 'open') return 'RSGH';
		if (what == 'closed') return 'RSGK';
		if (what == 'link') return 'RSGR';
		return 'TNT1';
	}

	static play void Spark(Vector3 at, Name what) {}
}
