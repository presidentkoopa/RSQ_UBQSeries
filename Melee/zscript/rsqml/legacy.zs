// THE TWO OLD HANDLERS, as empty shells, so a game saved before 2026-11-01 loads. A level's handlers are written into
// the save by class name and read back from it (a restored game registers no MAPINFO handler: events.cpp
// InitStaticHandlers returns early on a savegame restore), so a save made with RSQ Gun Bonsai VR's punch reader and
// Slappers Only holds RSQ_GloveHandler and RSQ_SlappersHandler and needs the classes to exist. Their old fields are
// skipped on load (read only in developer mode as "Cannot find field"). Nothing registers them now and they do
// nothing: the punch is RSQML_Gloves and Slappers Only RSQML_Slappers, both static handlers (never saved).
class RSQ_GloveHandler : EventHandler {}
class RSQ_SlappersHandler : EventHandler {}
