// RSQ VisualRewards -- RSQ SlowMo's DOWN (owner 2026-11-06, design/NEAR_DEATH.md: the mode is DOWN, getting up is REVIVE).
// SlowMo owns the mode and tells every service named "...RSQDownJoin" by name (its down.zs Tell); nothing links, and each
// mod still loads alone. What this mod adds:
//   - THE MEDKIT DROP (Power-Up Drops, SlowMo's row): each kill that counts drops RSQVR_DownMedkit where the monster fell:
//     +25 health when touched. With BD_VoxelPack it is that pack's Berserk pack voxel (PSTRA.kvx) recoloured white with a
//     red cross (TRNSLATE.rsqvrdn), so it reads as a medkit and is never mistaken for a berserk; without BD_VoxelPack
//     (no voxel on PSTR A) it is the stock Medikit sprite (MEDI A, Doom's own white box with a red cross; whatever the
//     load order draws for it).
//   - THE DAMAGE NUMBERS' TIE-INS (owner 11-06: "some life to them, colours to let the player know this is different, or
//     important, or part of a sequence"; damnums/events.zs DownCount, Gain, ReviveBanner):
//       a kill count "1/3", "2/3", "3/3" pops where each counted kill lands, its colour climbing along the sequence;
//       "+25" on the medkit's pickup, flying to the wrist like the other gains, in its own colour;
//       the REVIVE word flying past like the level-up band, in the damage numbers' font (JFO), in its own colour.
//     The kill count and the +25 follow the Damage Numbers row (and Gains on You for the +25); the REVIVE band always shows.
class RSQVR_RSQDownJoin : Service
{
	override int GetInt(String request, String stringArg, int intArg, double doubleArg, Object objectArg, Name nameArg)
	{
		let dc = CVar.FindCVar("rsqsm_debug");     // RSQ SlowMo's debug log
		bool msg = dc && dc.GetBool();
		int n = intArg;
		if (request == "down.kill")
		{
			let body = Actor(objectArg);
			if (!body) return 0;
			Array<String> f;
			stringArg.Split(f, " ", TOK_SKIPEMPTY);
			int k = f.Size() > 0 ? f[0].ToInt() : 0, need = f.Size() > 1 ? f[1].ToInt() : 0;
			bool drops = f.Size() > 2 && f[2].ToInt() != 0;
			if (drops) RSQVR_DownMedkit.Drop(body, msg);
			let h = RSQTHP_DamNumHandler.Get();
			if (h && n == consoleplayer) h.DownCount(body, k, need);
			return 1;
		}
		if (request == "down.revive")
		{
			let h = RSQTHP_DamNumHandler.Get();
			let pmo = PlayerPawn(objectArg);
			if (h && pmo && n == consoleplayer) { h.ReviveBanner(pmo); if (msg) Console.Printf("RSQ VisualRewards: REVIVE band shown"); }
			return 1;
		}
		return 0;
	}
}

// THE DOWN MEDKIT: +25 health (up to your max health, as Doom's medikit), its own pickup line; stock DSITEMUP pickup sound.
class RSQVR_DownMedkit : Health
{
	Default
	{
		Inventory.Amount 25;
		Inventory.MaxAmount 0;
		Inventory.PickupMessage "Medkit (+25 health)";
		Inventory.PickupSound "misc/health_pkup";
		Tag "Medkit";
		Radius 16;
		Height 16;
		+DONTGIB
	}
	States
	{
	Spawn:
		PSTR A -1;
		Stop;
	Plain:
		MEDI A -1;
		Stop;
	}

	static RSQVR_DownMedkit Drop(Actor body, bool msg)
	{
		let m = RSQVR_DownMedkit(Actor.Spawn("RSQVR_DownMedkit", body.pos + (0, 0, 8), NO_REPLACE));
		if (!m) return null;
		m.bDROPPED = true;
		m.Look();
		m.vel = (frandom[rsqvrdn](-1.5, 1.5), frandom[rsqvrdn](-1.5, 1.5), 4.0);
		if (msg) Console.Printf("RSQ VisualRewards: DOWN medkit dropped at %.0f %.0f %.0f (%s)", m.pos.x, m.pos.y, m.pos.z,
			m.InStateSequence(m.CurState, m.FindState("Plain")) ? "the stock Medikit sprite: no BD_VoxelPack voxel" : "BD_VoxelPack's Berserk voxel, white with a red cross");
		return m;
	}

	// BD_VoxelPack's Berserk voxel recoloured, or the stock Medikit sprite without it
	void Look()
	{
		if (RSQTHP_Voxels.HasVoxel(GetSpriteIndex('PSTR'), 0)) A_SetTranslation('RSQVR_DownMedkit');
		else SetStateLabel("Plain");
	}
}
