// RSQ_Accessibility -- RSQA_Menu, the Accessibility page's menu class (MENUDEF: Class "RSQA_Menu").
//
// It adds nothing to OptionMenu: it is kept because every series mod finds this pk3 by looking for this class by
// name (tools/a11y_template.zs, tools/cb_template.zs: no class, every setting reads off). The section pruning it
// used to do (RSQASection rows, shown only when their mod was loaded) went on 2026-11-10: no MENUDEF has used a
// Section row since the links moved to Radiant Silvergun Options (tools/rsmenu).
class RSQA_Menu : OptionMenu
{
}
