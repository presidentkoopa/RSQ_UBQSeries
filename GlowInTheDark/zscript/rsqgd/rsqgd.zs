// RSQ Glow In The Dark -- every ZScript file, in one include (zscript.txt carries only this line).
#include "zscript/rsqgd/rsmenu.zs"     // Radiant Silvergun Options: the series' shared menu pieces (tools/rsmenu)
#include "zscript/rsqgd/liquids.zs"    // GENERATED from GLDEFS.txt by tools/gen_liquids.py
#include "zscript/rsqgd/liquid.zs"     // liquid kinds, colours, name guesses
#include "zscript/rsqgd/profiles.zs"   // the profile table
#include "zscript/rsqgd/handler.zs"    // the core: map-start pass, look, writer
#include "zscript/rsqgd/react.zs"      // reactions to other mods (by name)
#include "zscript/rsqgd/things.zs"     // doors, switches, exits, items, the few lights
#include "zscript/rsqgd/service.zs"    // RSQGD_Service
#include "zscript/rsqgd/menu.zs"       // menu rows that read the profile table
