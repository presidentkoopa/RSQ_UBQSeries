# Planned projects (owner 2026-11-10 10:46: these are projects, not parked ideas)

THE BIG FOUR (named 11-09, design/HANDOFF_SESSION_2026-11-09_evening.md): Score (its pruning, names too: the Score Big
Pass), Gun Bonsai VR (its pruning: the GBOVR Big Pass), Monster Assembly (the RSQ Monsters rebuild below), and the
Arcade (design/BIG_FOURTH_ARCADE.md, design/HANDOFF_ARCADE_2026-11-09.md).

## The Arcade (the Big Fourth)
The in-world arcade language: contextual challenges, arcade words and numbers in the world, a conductor, bits as
jackpot, time attack. Design only so far: design/BIG_FOURTH_ARCADE.md, design/HANDOFF_ARCADE_DESIGNER.md.

## Grapple 2.0 (owner 11-10: "planned project")
jp's OG hookshot rebuilt in ZScript, the weight rule both ways, air steering. Its open questions (the Revenant; how you
arrive at a big monster; the +user1 clash with BD's Toss Grenade / our Quick Grenade) are part of the project.
See Grapple/ROADMAP.md (the banner at the top).

Held for Grapple 2.0 (owner 11-10 "Hold all for Grapple 2.0"), from the 11-10 code read (Grapple/README_draft.md):
the Whip-Instead-of-Hook snag flings you toward the map origin with the defaults (whip.zs:168-196 never sets ogPoint;
core.zs:454-456); Score's Indiana Jones / Swinging / Dismount never pay with the default OG wall hook (service.zs:326-331,
348 count only PH_LATCH; the fling is PH_HOLD); climbing needs RSQ Distance Grab's grab keys since the Grab Rope keys went
11-10 (the rsqgr_grab netevent is dead); the Rope-mode arrived branch of Pull is unreachable (core.zs:1009-1031); Grab
Reach / Climb Speed Cap / Reel Speed rows do nothing in Rope mode; the dead 'swish' sound; Keep Momentum also changing
Split Pull; stale comments (CVARINFO.txt:1, 4, 22; input.zs:4, 7; whip.zs:1) and credits (CREDITS.txt:7-8); the unused
rsqgr_reset alias; dead fields gripLastOff / gripPending; Gun Bonsai VR's up_hook.zs:81 range fallback 1024 vs 780.

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

### Whip and pistol, Indiana Jones (owner 11-10 12:27, "maybe i'll table it for a gbovr upgrade")
The whip in one hand and a pistol in the other. The catch: the Whip uses the OFF hand to aim the snag (its aim ray) and to
grip the thong (the lasso), so a gun in that hand takes both away. Talking points, not designed: the snag aimed by the
whip hand's own crack direction while a gun is in the other hand; the lasso grip dropped in that mode; one-handed
swing. A possible Gun Bonsai VR upgrade on the whip tree.
Owner 12:30 (the aim): "aim with the whip hand, we still target actors while holding in primary fire. so with whip in
hand we are free aiming the snag cursor, but holding the trigger makes it behave like normal". So: the whip hand's own
ray is the snag cursor while the trigger is up (the off hand free for the pistol); trigger held = marking actors as now.
Owner 11-10 (dead-code pick): build it from the Whip's dead bind-whip code (design/WHIP_DEAD_FEATURES.md section 6),
together with the Rope perks (section 4: Fast Reel, Steady Line, Slingshot as Gun Bonsai VR whip-tree nodes). Queued
after the rig test and the README controls pass.
**Built 2026-11-10 as Whip and Gun** (rig only, not headset-confirmed): Whip/README.md "Whip and Gun", RESULTS.md BINDWHIP.


## Big Pass 5: Options
Named by the owner 2026-11-12 19:2x ("when i go through my options (ADD BIG PASS 5, OPTIONS) I can sort it out then"):
a pass over every option row in the series. Items waiting for it:
- RSQ Tactical Rig, drawing a holstered gun with a gun already in that hand: the gun in hand goes into the Wheel
  (default; keeps the assignment system) or takes that holster (a straight swap, so you always know what is where).
  Built as a toggle; the default is for this pass to settle.

## Movement: the ski-pole jump kick (owner 2026-11-12 20:07-20:21, design only)
- Home: cigarette slow-mo (it switches close-call slow-mo off so they never stack); each move burns a slice of the smoke.
- Trigger: both hands sweep back hard together (ski poles), guns in hand, no button.
- The leap: full action by default (owner 20:15: "i am advanced vr user don't baby me"): real air, head height plus,
  the view travels the whole arc, momentum carried out of the landing. Softened versions (lower hop, vignette, blink)
  live in Accessibility only.
- COMMITTED (owner 20:21): the boot swings out sideways at the top of the arc every time, whiffs included; you aim
  the leap and own the result. Whatever it hits flies: monsters bowl into monsters, barrels go off on impact (Melee's
  Barrel Launch).
- Ledges do not stop it: overshoot and Grapple 2.0 saves you; the grapple fires at normal speed during slow-mo.
- Also talked about, not chosen: a double-flick stick dash, a head-lunge dash, a slide kick on a quick head dip
  while running.
- Not built. First step when it is: measure on the rig how fast normal play moves the hands (reloads, holsters) so
  the push-off never fires by accident.

## The sprite-frame budget (2026-11-12)
The engine indexes sprite frames with 16 bits: the whole load order must stay under 65,535. It was 71,572 (runs
sfcount3); LaserSight's PC VR halo removed: 64,228, headroom 1,307. Count any new baked asset first (the gdb read in
the rig: rig/work/fullgdb3.sh, /tmp/sprites.bin, numframes at byte 8, the 16-bit start at byte 10). Big users: GunCards
19.5k, brutal22test6 13.1k, Saber 10.7k, LaserSight 7.3k, RSQ Monsters 5.7k, XMVE 5.3k.
- Owner 2026-11-12 19:44: "once i bake the small card on each model we can cut those sliders completely": the small
  card's baked positions (GunCards' Q0..QE families, the 13 depths) go then, freeing most of GunCards' frames.

## RSQ Score's Big Pass
Named by the owner 11-10 10:46 as a planned project beside Gun Bonsai VR's. Not yet scoped.

## Wheel support for other mods
Owner 02:56: "disable wheel mod support for now". Done: every reader but LegenDoom answers off (Wheel/zscript/wheel/wr_modsupport.zs), rows hidden.
About half the Wheel's compat files (Lithium, Doom Infinite, Doomablo, Pandemonia + Anarchy/Insurrection, BorderDoom,
Guncaster, Model Swapper) read nothing on stock QZD 17.3: they use REMA's field reflection, stubbed to "no field"
(Wheel/zscript/wheel/wr_q_shim.zs:873-886). LegenDoom, DRLA, Combined Arms, Final Doomer, MetaDoom Demon Keys work.
Owner: "either get it working or we will drop support". Ways: read public items/cvars/events by name, or one small
bridge pk3 per mod. Needs from the owner: which mods to keep, and their pk3s. See design/WHEEL_MODS_PEEK.md.


## RSQ Monsters rebuild = Monster Assembly (owner 11-10)
Stale comments, cvars and menus out; menus redone from scratch; Monster Diagnostics written up (its numbering is the
key to the expanded coloured roster); Brutal Doom's own monsters tiered onto the colour ladder (health as CH: a Red
zombieman is a Red zombieman); the tier icons back (design/icons, style B). MeatGrinder was removed 11-10.

Bosses live here (owner 11-10). A **Boss** is a real boss: the EX-tier monsters and their fights. None exist yet. A
**Miniboss** is RSQ Miniboss's (the map's, or the one you call in); its event is no longer called "Bossfight" (renamed
11-10). The **boss bar** (owner 11-09 04:49: "another bar next to the Miniboss one that we will use for Boss fights, EX
tier monsters") is built with the bosses: a second bar beside the Miniboss meter, the same size, like the two SlowMo bars.

## Lasers for a non-BD weapon set
RSQ Laser Sight measures each gun's muzzle from its mesh; a new weapon set needs that pass (owner 11-10).

## Netplay
Parked until QuestZDoom has netplay (owner 11-09). The known items are marked TODO in the code.

## RSQ Monsters pass (owner 11-10 14:45: "Monsters needs work i know"; its own project, later)
Known from the 11-10 agents: the menu checker finds 29 structure problems (the orphan RS pages with the undefined
RS_CH_OffOn, no Reset All on the front page, a sub menu not named Test and Debug); the zscript gives 256 compile
warnings (deprecated VelX-style calls in rs_zombieman.zs, rs_shotgunner.zs). The owner scopes the rest. Not started.
