// THE SEAM, looks side -- a STUB owned by core, answering the JP defaults so the
// mod works alone. The monster builder (branch agent-monster) replaces this file
// whole with the JP / CombatFX / Ballistics sets. The contract:
//
//   Sound(what)   a SNDINFO name, "" for silence   fire loop swish hitwall hitflesh retract
//   Sprite(what)  a 4-letter sprite name           open closed
//   Spark(at, what)  an impact effect, or nothing  wall flesh
//
// The JP set is jpalomo's hook (jp_original/): OCLW/CCLW claw (here RSGH/RSGK),
// and his five sounds. The rope is a tube model in tenda0's grey (tools/gen_rope.py). JP's hook makes no spark.
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
		return 'TNT1';
	}

	static play void Spark(Vector3 at, Name what) {}
}
