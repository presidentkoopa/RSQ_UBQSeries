// RSQ_Accessibility -- the Accessibility menu that shows a series mod's rows only when that
// mod is loaded.
//
// The trick: QZD 17.3's OptionMenuItem has no Visible() hook, but MENUDEF accepts any
// OptionMenuItem subclass by name ("RSQASection" -> OptionMenuItemRSQASection), and an
// OptionMenu subclass sees its descriptor's item list before the first draw. RSQA_Menu.Init
// walks that list once: a Section whose classes are all missing is dropped together with the
// rows under it; a kept Section stays as a header line. The descriptor lives for the session
// and the loaded mods cannot change in a session, so pruning once is enough.

class OptionMenuItemRSQASection : OptionMenuItemStaticText
{
	String mNeeds;   // "Class1|Class2": the section shows when any of these classes exists

	OptionMenuItemRSQASection Init(String label, String needs)
	{
		Super.Init(label, 1);   // header colour, like StaticText "x", 1
		mNeeds = needs;
		return self;
	}

	bool Present()
	{
		Array<String> names;
		mNeeds.Split(names, "|", TOK_SKIPEMPTY);
		for (int i = 0; i < names.Size(); i++)
		{
			Name n = names[i];
			Class<Object> c = n;
			if (c != null) return true;
		}
		return false;
	}
}

class RSQA_Menu : OptionMenu
{
	override void Init(Menu parent, OptionMenuDescriptor desc)
	{
		RSQA_Menu.Prune(desc);
		Super.Init(parent, desc);
	}

	// Drops absent sections (and their rows); puts a spacer above each kept section header.
	static void Prune(OptionMenuDescriptor desc)
	{
		Array<OptionMenuItem> kept;
		bool keep = true;
		int changed = 0;
		for (int i = 0; i < desc.mItems.Size(); i++)
		{
			let it = desc.mItems[i];
			let sec = OptionMenuItemRSQASection(it);
			if (sec)
			{
				changed++;
				keep = sec.Present();
				if (keep)
				{
					if (kept.Size() > 0) kept.Push(new("OptionMenuItemStaticText").Init(" "));
					kept.Push(new("OptionMenuItemStaticText").Init(sec.mLabel, 1));
				}
				continue;
			}
			if (keep) kept.Push(it);
		}
		if (changed == 0) return;   // already pruned this session
		desc.mItems.Move(kept);
		desc.mSelectedItem = -1;
		desc.mScrollPos = 0;
	}
}
