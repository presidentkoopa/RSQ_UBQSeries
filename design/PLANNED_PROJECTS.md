# Planned projects (owner 2026-11-10 10:46: these are projects, not parked ideas)

THE BIG FOUR (named 11-09, design/HANDOFF_SESSION_2026-11-09_evening.md): Score (its pruning, names too: the Score Big
Pass), Gun Bonsai VR (its pruning: the GBOVR Big Pass), Monster Assembly (the RSQ Monsters rebuild below), and the
Arcade (design/BIG_FOURTH_ARCADE.md, design/HANDOFF_ARCADE_2026-11-09.md).

## The Arcade (the Big Fourth)
The in-world arcade language: contextual challenges, arcade words and numbers in the world, a conductor, bits as
jackpot, time attack. Design only so far: design/BIG_FOURTH_ARCADE.md, design/HANDOFF_ARCADE_DESIGNER.md.

## Grapple 2.0 (owner 11-10: "planned project")
**Owner 2026-11-12 23:04: "all grapple code has to be thrown out."** Grapple 2.0 is a rebuild from nothing: the current
RSQ Grapple code is not its base. Design comes from the owner; nothing proposed 11-12 23:0x stands.
**Foundation (owner 23:10: "i love this, yes, good foundation"):** the off hand's instant hook. No skill, no rope,
straight line. One press from the off hand, where it points (the hand the whip leaves free). Three results, decided
where it bites: a wall or floor flings you at it; a light monster is flung to you; a heavy one, you are flung to it
(jpalomo's feel, rewritten clean). A bite on a ledge lip with room to stand lands you on top. Fires and flings at full
speed in slow motion (the ledge save). No rope, reel, swing or climb: those are the whip's.
**The two monster results (owner 23:1x):**
- **Too big, so you fly to it: the KICK-CHAIN.** On arrival you execute the jump kick, the game enters slow motion, and
  you "kick off" the enemy: an opposing arc with some height, a moment in the air to grapple the next enemy and kick
  again, building a kick-chain. (The kick's strike is the ski-pole jump kick's payload: knockback, stagger, the yellow
  cross hit.)
- **Light enough, so it comes to you: GET OVER HERE.** The hook shoots out of your hand like Scorpion's spear and the
  monster is yanked to you. No grip, no catch: it arrives in front of you and you shoot, punch, shove, saw, whatever.
  (Any word or sound for it is our own, not Mortal Kombat's voice line.)
- **The pull is automatic by default (owner 23:1x):** on the bite, a light monster comes and a big one pulls you, no
  gesture. Option **Scorpion Pull: On / Off** (Off by default): On, the hook holds on the chain until you yank your
  hand back, and that yank sets it off.
- **The kick-chain, step by step (talked through 23:2x):** hook a big one, fly in (walls checked every tic), arriving IS
  the kick (the jump kick's strike, the yellow cross, KICK!), slow motion starts on contact (asked of RSQ SlowMo; to
  check first: that a slowed world leaves the player's own movement at full speed), then the kick-off: a fixed launch
  up and away, the hang at the top in slow motion; in the air the off hand retargets; the next bite decides: a big one
  = another kick (chain +1, KICK! x2, x3...), a light one = GET OVER HERE in mid-air and finish it as you fall, a wall
  or ledge lip = land or mantle, nothing in reach = you fall. A low ceiling cuts the arc short; a kill still kicks you
  off; a guarded miniboss: bounce, GUARD shakes, no damage.
- **Slow motion in a chain (owner):** each link restarts it a little shorter than the last, so a chain fades out.
  Gun Bonsai VR's Big Pass will let it be extended, maybe a minigame: while airborne some monsters are worth more time.
- **Bounce (owner 23:4x):** away from the monster and up: straight out from its face, whatever way you look.
- **Mid-air aim (owner 23:4x):** the hook snaps to the nearest valid target in a small cone round the off hand's line,
  on by default; an Aim Assist row switches it off.
- **Double jump (owner 2026-11-13 00:0x).** Reference: Castlevania: Symphony of the Night, "Part 7 - Double Jump!"
  (youtube.com/watch?v=MFYLpiPEgmc, 06:40-06:48, watched frame by frame in the built-in browser): in the Long Library
  Alucard dive-kicks a flying Dhuron, the hit pops a damage number, he bounces up off it and dive-kicks it again,
  staying airborne off the enemy. The owner's version: one double jump per kick-off (every kick refreshes it). After a
  kick-off, press jump again for more air and +0.5 s of slow motion, with **DoubleJump!** appearing under the world
  slow-motion bar so you know why it got the boost. Once you double jump, a few enemies within the grapple's reach get
  "+0.25 sec" or "+0.5 sec" over them: hook one to earn that much more slow motion (the start of the airborne minigame).
- **The air spike (owner 00:1x).** Mid-air (after a double jump) you hook a light monster: GET OVER HERE pulls it up
  to you in slow motion; swing both hands down hard together (Ground Pound's gesture, read by Grapple 2.0 itself,
  ANYTHING in your hands, but only at this one moment: an air-pulled light monster in front of you; elsewhere Ground
  Pound stays Melee's, fists only, so it is not triggered by accident) and it is SPIKED straight down. You hang in the
  air until it hits the floor. On impact: RSQ Grenade's #10 Neon Crescent (taken OUT of the barrels' random rotation:
  the spike's own explosion), blood, fire and a shockwave round the impact. The blast counts as a close explosion and
  triggers contextual slow motion on your descent: a new RSQ SlowMo trigger **Grapple-Slam: On / Off** beside its
  Barrel Near You (owner 00:19).
- **Build numbers (owner 2026-11-13 00:2x):** fired by a bound key only (Fire Hook, from the off hand); available from
  the start (no Gun Bonsai VR gate; its Big Pass gates upgrades later); the kick hits like Melee's Ground Pound (30
  damage, knocked back and staggered); range jpalomo's ~23 m; kick-chain slow motion 1.5 s on the first kick, 0.3 s
  shorter each next link (1.5, 1.2, 0.9, 0.6, 0.3); kick-off bounce about 1.5 m up, mindful of ceilings; after a
  double jump up to 5 enemies in reach get a time marker (nearer +0.25 s, farther +0.5 s); RSQ Score rows wait for
  Score's Big Pass (Grapple 2.0 reports its events by name now). Light vs heavy keeps the OG rule (a boss, mass over
  1000, a dormant monster, or a miniboss with Can't Be Yanked is heavy). Comfort versions live in RSQ Accessibility.
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
- The axe's guaranteed critical (a thrown axe that hit, grabbed back: the next throw is an MK Crits critical; built into
  BD22 VR Reloaded 2.0.4r's axe) becomes a Gun Bonsai VR UPGRADE for the axe in this pass (owner 2026-11-12 20:54).
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

## Folded in 2026-11-12 22:2x (owner: "i want the Big Five / 2.0 stuff to be all that I have left")
Everything left is in a big project. Where each leftover went:
- **Monster Assembly:** sprite-name clashes between packs; the tier flash matched exactly to Hackfraud's HF_Monster.zs
  (needs the owner's file from E:\oldshit\outdatedHFmaster); thrall drops checked on other monster types.
- **The Arcade:** words over Champions monsters; fly-in crosshairs (design/refs/crosshair_flyin/); the ski-pole jump
  kick, dash and slide (above); the yellow cross kick hit (design/mockups/kick_hits/); a SOTN look for the whole UI
  (design/mockups/sotn_crit/, owner: "i might consider redesigning the entire UI in this fashion").
- **Gun Bonsai VR's Big Pass:** the axe's guaranteed crit as an upgrade; the boxing gloves (more of their own, or
  folded into fists, or removed: owner 22:2x "Gun Bonsai pass").
- **Big Pass 5 (Options):** the holster swap default; the miniboss extras still in (Arrives By Itself and its
  guardrails, the watch-check call-in, greed and rage, Graves Rise, room glow and heartbeat, tethers/flames/words/Xs,
  music, Roar and Morphed, Tier From "Set"; design/MINIBOSS_CLEANUP_AUDIT.md); GunCards per-gun roll/pitch/yaw (and
  the sliders go once the owner bakes the small card per model).
- **Score's Big Pass:** Rage Quit and Riot Control (they live or die with greed and rage).
- **Grapple 2.0:** the ledge save at full speed in slow motion.
Owner-only (headset or his files): rogue voxels / monsters dropping frames (likely the frame cap, fixed 11-12), the Imp
vanishing before it throws, holsters while DOWN, "sometimes we don't get up" (his log with rsqsm_debug 1), the whip's
direction (parked by him) and the Whip README (his sign-off).

