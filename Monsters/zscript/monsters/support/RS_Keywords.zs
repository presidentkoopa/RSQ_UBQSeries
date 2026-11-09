// =====================================================================
// RS_Keywords -- string-parsing utility for the keyword system.
// ---------------------------------------------------------------------
// See docs/rs_03_keywords_v2.txt for the full schema. Syntax: space-
// delimited "key:value" tokens, e.g. "archetype:pistol trigger:semiauto
// payload:single". Multi-value keys just repeat ("trigger:semiauto
// trigger:burst"). Pure string parsing, no state -- the actual BASE/
// GRANTED storage and query API lives on RS_Weapon (RS_Weapon.zs), this
// is just the tokenizer both layers share.
// =====================================================================

class RS_Keywords
{
	// CASE FOLD. Every comparison in this system goes through here.
	//
	// The trap this closes: ZScript is case-INSENSITIVE for class names
	// and state labels, so everything else in this project can be written
	// in any case and still resolve -- but String `==` is case-SENSITIVE.
	// So the first affix author who writes GrantKeyword("Payload", "Multi")
	// instead of ("payload", "multi") gets a keyword that stores fine,
	// reads back fine, and matches NOTHING. No error, no warning, an affix
	// that simply does nothing. Every call site today happens to be
	// lowercase, which is exactly why it has never been caught.
	static string Norm(string s)
	{
		return s.MakeLower();
	}

	static bool StringHas(string kwString, string key, string value)
	{
		Array<string> tokens;
		Norm(kwString).Split(tokens, " ");
		string needle = Norm(key) .. ":" .. Norm(value);
		for (int i = 0; i < tokens.Size(); i++)
			if (tokens[i] == needle)
				return true;
		return false;
	}

	// Last matching token wins -- callers only use this for genuinely
	// single-value keys, where "last" just means "only."
	static string GetValue(string kwString, string key)
	{
		Array<string> tokens;
		Norm(kwString).Split(tokens, " ");
		string prefix = Norm(key) .. ":";
		string result = "";
		for (int i = 0; i < tokens.Size(); i++)
			if (tokens[i].Left(prefix.Length()) == prefix)
				result = tokens[i].Mid(prefix.Length());
		return result;
	}

	static void GetValues(string kwString, string key, out Array<string> results)
	{
		Array<string> tokens;
		Norm(kwString).Split(tokens, " ");
		string prefix = Norm(key) .. ":";
		for (int i = 0; i < tokens.Size(); i++)
			if (tokens[i].Left(prefix.Length()) == prefix)
				results.Push(tokens[i].Mid(prefix.Length()));
	}

	// The documented key set -- see docs/rs_keyword_index_draft.txt -- plus "curse" and
	// "characteristic" from RS_Weapon.zs's own GetKeywordValue(s) doc
	// comment. Purely a typo net: a key that's missing from this list
	// doesn't stop anything from working, it just means Validate() below
	// will log about it. Add to this list when a real new key ships;
	// don't "fix" a call site to match this list instead.
	// Plain comparison chain, not a static const array -- this engine
	// build doesn't resolve `static const string X[] = {...}` reliably.
	static bool IsKnownKey(string key)
	{
		return key == "archetype" || key == "set" || key == "trigger"
			|| key == "grip" || key == "delivery" || key == "payload"
			|| key == "behavior" || key == "element" || key == "feed"
			|| key == "sockets" || key == "reserve" || key == "promotion"
			|| key == "curse" || key == "characteristic"
			// monster-side keys -- see RS_MonsterKeywordIndex.zs. Shared
			// parser/validator, not forked, same as "set"/"delivery"/
			// "payload"/"element" above being reused by both domains.
			|| key == "species" || key == "role" || key == "mobility"
			|| key == "trait";
	}
}
