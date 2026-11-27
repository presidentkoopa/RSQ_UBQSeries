// RSQ_MonsterRows.zs -- RSQ Monsters' own menu rows. (Moved out of RSQ_MonsterMenu.zs on 11-16: that file is
// GENERATED from tools/rsmenu/rsmenu_template.zs, so tools/rsmenu/gen_rsmenu.sh would have written these away.)

// ==== MONSTER ASSEMBLY (owner 2026-11-16 09:58: "Build it as proposed", docs/MENU_PROPOSAL.md) ==========================
// RSQMNGroup: an Option row whose one setting stands for several of Colourful Hell's own. Picking a value writes them:
//   rsq_mon_ch_extras  Off 0 / On 1 / Half 2  ->  rs_ch_cyan, rs_ch_brown, rs_ch_abyss (1 off, 2 on, 3 half) and
//                      rs_ch_fireblu, rs_ch_gray (1 off, 2 on; they have no half: Half leaves them on)
//   (the Drops row, rsq_mon_ch_drops, went with Colourful Hell's drops: owner 2026-11-27, "bits and rewards only")
// Only a pick writes them; the raw settings are rows on Test and Debug (the five Extra Colours ones since 11-16), so one
// can be changed afterwards. [11-16 bugfix MO12] The row shows the choice the raw settings MATCH, read from them, and
// "Custom" when they match none (as the series' preset rows do), never just its last pick.
class OptionMenuItemRSQMNGroup : OptionMenuItemOption
{
	OptionMenuItemRSQMNGroup Init(String label, Name command, Name values)
	{
		Super.Init(label, command, values);
		return self;
	}

	static int Raw(Name n) { let c = CVar.FindCVar(n); return c ? c.GetInt() : -99; }

	// does choice v of this row match the raw settings now
	static bool Matches(Name which, int v)
	{
		if (which == 'rsq_mon_ch_extras')
		{
			int three = v == 1 ? 2 : (v == 2 ? 3 : 1);
			// FireBlu and Gray read 1 as off and any other value as on (they have no half)
			bool twoOn = v != 0;
			return Raw('rs_ch_cyan') == three && Raw('rs_ch_brown') == three && Raw('rs_ch_abyss') == three
				&& (Raw('rs_ch_fireblu') != 1) == twoOn && (Raw('rs_ch_gray') != 1) == twoOn;
		}
		return false;
	}

	override int GetSelection()
	{
		int cnt = OptionValues.GetCount(mValues);
		for (int i = 0; i < cnt; i++) if (Matches(mAction, int(OptionValues.GetValue(mValues, i)))) return i;
		return -1;
	}

	override int Draw(OptionMenuDescriptor desc, int y, int indent, bool selected)
	{
		drawLabel(indent, y, selected ? OptionMenuSettings.mFontColorSelection : OptionMenuSettings.mFontColor, isGrayed());
		int sel = GetSelection();
		String text = sel >= 0 ? StringTable.Localize(OptionValues.GetText(mValues, sel)) : "Custom";
		drawValue(indent, y, OptionMenuSettings.mFontColorValue, text, isGrayed());
		return indent;
	}

	override void SetSelection(int Selection)
	{
		Super.SetSelection(Selection);
		// the value picked, read from the row's own list: a server setting changed from the menu reaches the CVar a tic
		// later, so reading it back here would give the old value
		if (Selection >= 0 && Selection < OptionValues.GetCount(mValues)) Apply(mAction, int(OptionValues.GetValue(mValues, Selection)));
	}

	static void Put(Name n, int v) { let c = CVar.FindCVar(n); if (c) c.SetInt(v); }

	static void Apply(Name which, int v)
	{
		if (which == 'rsq_mon_ch_extras')
		{
			int three = v == 1 ? 2 : (v == 2 ? 3 : 1);
			int two = v == 0 ? 1 : 2;
			Put('rs_ch_cyan', three); Put('rs_ch_brown', three); Put('rs_ch_abyss', three);
			Put('rs_ch_fireblu', two); Put('rs_ch_gray', two);
		}
	}
}

// RSQMNDiagRow: a Monster Diagnostics spawn row (netevent rs_diag_spawn <row>, RS_Diagnostics.zs). Its label is the row's
// code and the name of that monster in the family Test and Debug > Family picks, read as it is drawn; a family with no EX
// (or no second EX, no other boss body) shows that row greyed and unselectable.
class OptionMenuItemRSQMNDiagRow : OptionMenuItemCommand
{
	int mRow;

	OptionMenuItemRSQMNDiagRow Init(String label, int row)
	{
		mRow = row;
		Super.Init(label, String.Format("netevent rs_diag_spawn %d", row));
		return self;
	}

	bool Exists()
	{
		Name n = RS_DiagHandler.RowClass(RS_DiagHandler.Family(), mRow);
		class<Actor> c = n;
		return c != null;
	}

	override bool Selectable() { return Exists(); }

	override int Draw(OptionMenuDescriptor desc, int y, int indent, bool selected)
	{
		Name n = RS_DiagHandler.RowClass(RS_DiagHandler.Family(), mRow);
		class<Actor> c = n;
		String tag = c ? GetDefaultByType(c).GetTag() : "(none in this family)";
		mLabel = String.Format("%s  %s", RS_DiagHandler.RowCode(mRow), tag);
		drawLabel(indent, y, selected ? OptionMenuSettings.mFontColorSelection : mColor, c == null);
		return indent;
	}
}
