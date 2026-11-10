# Planned projects (owner 2026-11-10 10:46: these are projects, not parked ideas)

## Gun Bonsai VR's Big Pass
"With GBOVR, it gates as much as it possibly can." A Vampire Survivors approach: design an enormous number of features
per weapon (the lightsaber's dozen and more), then gate them behind weapon and player levels with branching paths.
This is how the Miniboss rewards get their meaning. Melee's uppercut stays a Gun Bonsai VR unlock on Melee's own hands
for now; the Big Pass decides the rest. Needs the Arcade brain designed first.


Part of it (owner 11-10):
- Close-call slow motion (below, as first noted).
- Condition bits, Gold bits and weapon wear (Big Arcade, owner 11-09 02:56).

### Close-call slow motion (as noted 11-10 08:37)
Contextual slow motion when a monster missile nearly hits you: imp, cacodemon, revenant, baron, hell knight, cyberdemon,
mancubus (also asked: did we miss any? arachnotron plasma, pain elemental's lost soul, archvile's fire are the others
that fire at you). Possibly a Gun Bonsai VR option gated behind Hadouken, with SlowMo's HUD chevrons pointing at the
shot so you can spin round and hadouken it back. Also: use the HUD chevrons more widely. Not built; owner to decide.


### Condition bits, Gold bits, weapon wear (as noted 11-09)
"Condition and gold go into Big Arcade; same for weapon wear, that is condition."


## RSQ Score's Big Pass
Named by the owner 11-10 10:46 as a planned project beside Gun Bonsai VR's. Not yet scoped.

## Wheel support for other mods
Owner 02:56: "disable wheel mod support for now". Done: every reader but LegenDoom answers off (Wheel/zscript/wheel/wr_modsupport.zs), rows hidden.
About half the Wheel's compat files (Lithium, Doom Infinite, Doomablo, Pandemonia + Anarchy/Insurrection, BorderDoom,
Guncaster, Model Swapper) read nothing on stock QZD 17.3: they use REMA's field reflection, stubbed to "no field"
(Wheel/zscript/wheel/wr_q_shim.zs:873-886). LegenDoom, DRLA, Combined Arms, Final Doomer, MetaDoom Demon Keys work.
Owner: "either get it working or we will drop support". Ways: read public items/cvars/events by name, or one small
bridge pk3 per mod. Needs from the owner: which mods to keep, and their pk3s. See design/WHEEL_MODS_PEEK.md.


## RSQ Monsters rebuild (owner 11-10)
Stale comments, cvars and menus out; menus redone from scratch; Monster Diagnostics written up (its numbering is the
key to the expanded coloured roster); Brutal Doom's own monsters tiered onto the colour ladder (health as CH: a Red
zombieman is a Red zombieman); the tier icons back (design/icons, style B). MeatGrinder was removed 11-10.

## Lasers for a non-BD weapon set
RSQ Laser Sight measures each gun's muzzle from its mesh; a new weapon set needs that pass (owner 11-10).

## Netplay
Parked until QuestZDoom has netplay (owner 11-09). The known items are marked TODO in the code.
