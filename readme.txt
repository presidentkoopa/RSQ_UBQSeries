Gun Bonsai -- VR / Offhand Patch
================================
For Gun Bonsai 0.10.6. Load AFTER GunBonsai-0.10.6.pk3.


WHAT IT FIXES
-------------
Gun Bonsai was written for an engine where the player holds one weapon. On a
dual-wield VR build the player holds two, and stock GB has no idea. The offhand
earns no XP and gets no upgrades, and its shots are credited to -- and modified
by -- whatever the mainhand happens to be. Offhand shots also push the
MAINHAND's weapon-type counters, so over time the mainhand starts being offered
upgrades for a weapon it isn't.

This patch replaces twelve of Gun Bonsai's source files. Everything else is
stock.

  * Two live weapons. Each hand gets its own WeaponInfo, its own XP, its own
    upgrade tree, and its own on-tick upgrade processing. The offhand's
    RapidFire, Shield timer, Lightning minion and Bandoliers ammo caps now
    actually run instead of being dead or flickering.

  * Credit follows the gun, not the hand. Damage is attributed by tracking what
    actually caused it, recorded when the projectile is created and inherited by
    everything descended from it -- submunitions, fragments, explosions, minions
    and damage-over-time. Switch that hand away from the flamethrower and the
    burn still pays the flamethrower. Drop the flamethrower entirely and it
    still pays. Move it to the other hand and nothing changes, because the
    record points at the gun, never at a hand.

  * Damage-over-time splits proportionally. If two weapons burn the same enemy,
    each is paid for the share it actually contributed -- not all of it to
    whichever one touched the target last.

  * Two HUDs. Mainhand top-right, offhand top-left, as horizontal reflections of
    each other. Either side is skipped when that hand is empty, so a single
    weapon still looks like stock GB.

  * Assorted correctness. Holding only an offhand weapon no longer makes the
    entire HUD vanish. The Show Info key can now reach and spend a level the
    offhand earned. RapidFire no longer dereferences a null psprite, which with
    two hands is a VM abort rather than a glitch. Juggler works on both hands.


SETTINGS
--------
  bonsai_vr_dual_hud        Draw a HUD per hand. Default on.
  bonsai_vr_hud_hand        When dual HUD is off: 0 mainhand, 1 offhand,
                            2 whichever earned XP most recently.
  bonsai_vr_hud_main_x/y    Mainhand HUD anchor. Default 0.99 / 0.02.
  bonsai_vr_hud_main_mirror Default 3 (both axes).
  bonsai_vr_hud_off_x/y     Offhand HUD anchor. Default 0.01 / 0.02.
  bonsai_vr_hud_off_mirror  Default 2 (vertical).
  bonsai_vr_warn_binding    Startup warning when binding mode isn't per-weapon.

Set Gun Bonsai's own "upgrade binding mode" to PER WEAPON. With a weapon in each
hand, per-CLASS binding rebinds a single WeaponInfo back and forth between them,
which thrashes. The patch warns once at startup if you have not.


DIAGNOSTICS
-----------
  netevent bonsai-debug,hands      (aliased to the console command `bonsai-hands`)

Prints one line per hand -- weapon, hand flag, level, XP, upgrade count -- plus
the attribution resolver's counters:

  claimed        a mod told us outright which weapon fired (best case)
  self-claimed   the damage named one of your own weapons as its inflictor, or
                 named it through master/target/tracer -- equally exact, just
                 without the mod having to call anything
  inherited      descended from something already tracked
  scored         resolved by scoring both hands
  thin           of those, how many were near-ties, i.e. effectively guesses
  unattributed   we did not know, and awarded nothing rather than guess wrong

It also prints which weapon is holding the last-kill credit, which is the gun
score-to-XP pays.

A high THIN count means the signals are tying and attribution is unreliable. A
nonzero DROPPED count means the provenance ring is too small for your rate of
fire. Both are meant to be watched during play; that is what they are for.


FOR MOD AUTHORS: CLAIMING YOUR OWN SHOTS
----------------------------------------
If your mod spawns a projectile and already knows which weapon fired it, say so.
That is always better than us working it out afterwards, and it costs two lines
at the spawn site where the hand is already a local variable:

    TFLV_VR_Attribution.Claim(shot, firedByWeapon);

If you convert hitscans into travelling projectiles, pass a type hint as well:

    TFLV_VR_Attribution.Claim(shot, firedByWeapon,
                              TFLV_VR_Attribution.HINT_HITSCAN);

The hint matters as much as the attribution. A converted hitscan reaches Gun
Bonsai as a bMISSILE actor moving at projectile speed, so without the hint every
shotgun and chaingun in the game quietly retrains itself as a projectile weapon
and starts drawing from the wrong upgrade pool. HINT_HITSCAN says what the
attack really was.

The hint feeds Gun Bonsai's inference counters and never touches typeflags, so a
claim can never override a weapon type you set yourself in BONSAIRC.

Mods that do not call this lose nothing; their shots fall through to scoring.

There are two things you get without calling anything at all:

  * If your weapon deals damage from script and passes ITSELF as the inflictor
    -- target.DamageMobj(self, owner, ...) where self is the weapon -- that is
    taken as the claim. This is the case hand-scoring cannot resolve: a weapon
    in inventory has no position of its own to compare against the two hand
    poses, and a weapon whose Fire state does something other than fire gives
    the psprite test nothing to see. Works in either hand, with no code.

  * If you redirect a projectile that is already in flight -- a deflect, a
    reflect, a bounce -- set its master to the weapon that did it. Its damage
    then credits that weapon. (Set its target to the player as usual, or the
    engine will not call the damage yours at all.)

In both cases the hint is chosen for you, and a BONSAIRC `type` line still
outranks it.


KNOWN LIMITS
------------
  * The upgrade toggle/tune menu still addresses one weapon. Gun Bonsai's netevent
    protocol has no way to name a second one; that needs a wider change than a
    patch should make.
  * Both HUDs draw the player XP bar, because that is what the frame art
    contains. Blanking one would mean shipping new textures.
  * Provenance holds live actor pointers, which do not survive a save/load or a
    level change, so it is cleared on both. A shot in flight across a transition
    goes uncredited -- deliberately better than crediting the wrong gun.


COMPATIBILITY
-------------
Uses only upstream GZDoom and QuestZDoom-lineage API. No engine-specific natives.
Requires an engine with player.OffhandWeapon and PSP_OFFHANDWEAPON.

Gun Bonsai is by Rebecca "ToxicFrog" Kelly and is MIT licensed; this patch is a
derivative of it under the same terms. See Gun Bonsai's COPYING.md.


MELEE UPGRADES (rsq/)
---------------------
Upgrade paths for melee weapons, added as new files (nothing more of Gun Bonsai is
shadowed): the boxing gloves, the sabers (UltraBadassQuestSaber), the ShieldSaw
(UltraBadassShieldSaw) and any melee weapon. No elemental damage and nothing that is
rate of fire -- in VR the rewards are for how you move. Options: Options -> RSQ Melee
Upgrades (Slappers Only, Start with boxing gloves; the rest under Advanced).

  Gloves        Haymaker, One-Two, Star Punch, Counterpunch, Body Blow, Knockdown
  Sabers        Momentum, Riposte Edge, Piercing Return, Saber Throw, Chain Choke,
                Dual Harmony, Force Push, Force Pull, Force Choke, Force Jump
  ShieldSaw     Ricochet, Meat Grinder, Hunter's Return, Bulwark, Rebound, Battering Ram
  Any melee     Lunge, Executioner, Adrenaline (pulses RSQ SlowMo through rsm_pulse)

The saber and the ShieldSaw ask this patch for their levels by name
(RSQ_MeleeUpgradeService). No mod links to another; each pk3 still loads and works
alone, and without this patch the saber and the ShieldSaw behave exactly as before.
With it loaded, an unlearned Force power starts at rsq_force_start (60%).

THE GLOVES are SuperPunchOut's: the glove weapons, Ermac's glove mesh and fit, and
SuperPunchOut's punch reader (a punch arms after 15 cm of travel and must average
rsq_punch_min_speed; power is the average speed). Renamed RSQ_Glove / RSQ_GloveOff so
they can sit beside SuperPunchOut itself. A punch does Brutal Doom's own 10 (its
MeleeStrikeNormal) at the slowest that counts, up to 20 at full speed.

SLAPPERS ONLY (rsq_slappers, off by default): your guns are taken at each level start,
gun pickups become nothing, and a gun handed to you later is taken again within a
quarter second. You keep or are given the gloves, the sabers and the ShieldSaw (when
loaded), the Force hand, and Brutal Doom's fists, axe and sword (and any weapon flagged
as melee, such as the chainsaw). Ammo stays. Brutal Doom's hand grenades are a Weapon
too, so they go.

CREDIT FOR SCRIPT DAMAGE. The ShieldSaw's bash and grind name the player as their
inflictor; a mod in that position can bracket the damage:
    svc.GetInt("credit.push", "", hint, 0, weapon); target.DamageMobj(...);
    svc.GetInt("credit.pop", "", 0, 0, weapon);
and anything inside is paid to that weapon (PerPlayerStats claimStack).


CREDITS
-------
Gun Bonsai: Rebecca "ToxicFrog" Kelly, MIT. This patch and the melee upgrades:
presidentkoopa, same terms. Gloves, punch reader and sounds: SuperPunchOut
(presidentkoopa); the glove mesh and its fit are Ermac's (iAmErmac, PunchOutVR /
Virtual Punch Out); punch, star and knockdown sounds from Punch Out Doom
(DerrickDavison) through Virtual Punch Out; the count is the Super Punch-Out!!
announcer, as SuperPunchOut ships it. Punch-Out!! is Nintendo's.
