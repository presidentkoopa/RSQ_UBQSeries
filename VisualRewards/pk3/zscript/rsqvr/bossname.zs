// The Boss's name for the player: the rule of design/BANNERS_AND_HUD.md section 9 (a copy of RSQ Miniboss bossbar.zs
// RSQMB_Handler.BossName; nothing links). Rig only, not headset-confirmed.
class RSQVR_BossName
{
	// THE BOSS'S NAME FOR THE PLAYER (owner 2026-11-16 03:06, design/BANNERS_AND_HUD.md section 9): never a code name
	// (DEMON1, PE, CYBIE ...). The vanilla Doom monster the class descends from or replaces (its own class, its ancestors and
	// what each replaces); else what its Species says (Colorful Hell's own codes); else the same words in its class name;
	// else its Tag; else its class name split into words, without RS_ and a colour. Then " WARLORD" (BossName).
	// THE SAME RULE IN TWO PLACES: RSQ Miniboss bossbar.zs (RSQMB_Handler.BossName, the Boss bar) and RSQ VisualRewards
	// bossname.zs (RSQVR_BossName, the BOSS INCOMING! banner): keep them in step.
	static clearscope String VanillaName(String cn)
	{
		cn = cn.MakeLower();
		static const String VC[] = { "doomimp", "spectre", "demon", "cacodemon", "painelemental", "lostsoul", "baronofhell", "hellknight",
			"revenant", "fatso", "arachnotron", "archvile", "cyberdemon", "spidermastermind", "zombieman", "shotgunguy", "chaingunguy" };
		static const String VN[] = { "IMP", "SPECTRE", "DEMON", "CACODEMON", "PAIN ELEMENTAL", "LOST SOUL", "BARON", "HELL KNIGHT",
			"REVENANT", "MANCUBUS", "ARACHNOTRON", "ARCH-VILE", "CYBERDEMON", "SPIDER MASTERMIND", "ZOMBIEMAN", "SHOTGUN GUY", "CHAINGUNNER" };
		for (int i = 0; i < VC.Size(); i++) if (cn == VC[i]) return VN[i];
		return "";
	}
	// a code (a Species, a class name) by the words in it; longest and most particular first
	static clearscope String WordName(String code)
	{
		code = code.MakeLower();
		static const String KW[] = { "mastermind", "mmind", "arachno", "spider", "cyber", "cybie", "painelem", "pain", "lostsoul", "lsoul",
			"soul", "baron", "hellknight", "knight", "revenant", "fatso", "mancubus", "archvile", "vile", "caco", "spectre", "whitesp",
			"chaingun", "cguy", "shotgun", "sguy", "zombie", "imp", "demon" };
		static const String KN[] = { "SPIDER MASTERMIND", "SPIDER MASTERMIND", "ARACHNOTRON", "ARACHNOTRON", "CYBERDEMON", "CYBERDEMON",
			"PAIN ELEMENTAL", "PAIN ELEMENTAL", "LOST SOUL", "LOST SOUL", "LOST SOUL", "BARON", "HELL KNIGHT", "HELL KNIGHT", "REVENANT",
			"MANCUBUS", "MANCUBUS", "ARCH-VILE", "ARCH-VILE", "CACODEMON", "SPECTRE", "SPECTRE", "CHAINGUNNER", "CHAINGUNNER",
			"SHOTGUN GUY", "SHOTGUN GUY", "ZOMBIEMAN", "IMP", "DEMON" };
		if (code == "pe") return "PAIN ELEMENTAL";
		for (int i = 0; i < KW.Size(); i++) if (code.IndexOf(KW[i]) >= 0) return KN[i];
		return "";
	}
	// a class name in words: RS_ and a colour word gone, split at capitals and underscores
	static clearscope String SplitName(String cn)
	{
		if (cn.Left(3) ~== "RS_") cn = cn.Mid(3);
		String res0 = "";
		for (int i = 0; i < int(cn.Length()); i++)
		{
			int c = cn.ByteAt(i);
			if (c == 95) { if (res0.Length() && res0.Mid(res0.Length() - 1) != " ") res0 = res0 .. " "; continue; }
			bool up = c >= 65 && c <= 90;
			if (up && i > 0 && res0.Length() && res0.Mid(res0.Length() - 1) != " ") res0 = res0 .. " ";
			res0.AppendCharacter(c);
		}
		static const String COL[] = { "green", "blue", "purple", "cyan", "brown", "yellow", "fireblu", "gray", "red", "abyss", "black",
			"white", "shipped" };
		Array<String> w;
		res0.Split(w, " ");
		String res = "";
		for (int i = 0; i < w.Size(); i++)
		{
			bool colour = false;
			for (int k = 0; k < COL.Size(); k++) if (w[i] ~== COL[k]) colour = true;
			if (colour || w[i] == "") continue;
			res = res == "" ? w[i] : res .. " " .. w[i];
		}
		return res.MakeUpper();
	}
	static clearscope String CleanName(Actor a)
	{
		if (!a) return "";
		return CleanNameOf(a.GetClass(), a.Species, a.GetTag(""));
	}
	static clearscope String CleanNameOf(class<Actor> cls, Name species, String tag)
	{
		if (!cls) return "";
		for (class<Actor> c = cls; c; c = (class<Actor>)(c.GetParentClass()))
		{
			if (c == 'Actor') break;
			String v = VanillaName(c.GetClassName());
			if (v != "") return v;
			class<Actor> r = Actor.GetReplacee(c);
			if (r && r != c) { v = VanillaName(r.GetClassName()); if (v != "") return v; }
		}
		String v = species != 'None' ? WordName(String.Format("%s", species)) : "";
		if (v == "") v = WordName(cls.GetClassName());
		if (v != "") return v;
		if (tag != "" && !(tag ~== String.Format("%s", cls.GetClassName()))) return tag.MakeUpper();
		return SplitName(cls.GetClassName());
	}
	static clearscope String BossName(Actor a)
	{
		// a Big Boss by its own name, as RSQ Miniboss gives it (its card and Boss bar); by name, so this loads alone
		if (a)
		{
			let it = RSQTHP_Lookup.Find("RSQMB_Service");
			Service sv;
			while (sv = it.Next()) { String bn = sv.GetStringData("bigname", a.GetClassName(), 0, 0, null, 'None'); if (bn != "") return bn; }
		}
		String n = CleanName(a); return (n != "" ? n : "BOSS") .. " WARLORD";
	}
	static clearscope String BossNameOfClass(class<Actor> cls)
	{
		if (!cls) return "BOSS WARLORD";
		let d = GetDefaultByType(cls);
		String n = CleanNameOf(cls, d.Species, d.GetTag(""));
		return (n != "" ? n : "BOSS") .. " WARLORD";
	}
}
