# BD22 VR Reloaded bug read, part 1: weapons A (2026-11-27)
Commit read: edfaf63 (from `git rev-parse --short HEAD`; the task prompt said the folder is not a git repository, the command answered anyway). Nothing was run. Nothing was changed.

Paths are relative to the repo root. "Main" is the gun's own class in `src/actors/Weapons`; "copy" is its off-hand version in `src/DECORATE.rsqdual` (the Axe's copy is inside `Axe.dec`).
`DEFAULTWEAPON.dec` (class BrutalWeapon, with NoAmmo, DoKick, TossGrenade) IS in the repo, so those states were read, not guessed. Brutal Doom's ACS, its tokens (FiredPrimary, Reloading, Kicking, NoAutoReload, HasUnloaded*), its puffs and projectiles are NOT in the repo: where a finding leans on one of them it says so.

## Files read
| file | lines | read to the end? |
|---|---|---|
| src/actors/Weapons/Railgun.dec | 1-1044 (two chunks: 1-815, 815-1044) | yes |
| src/actors/Weapons/Shotgun.dec | 1-1035 (1-656, 656-1035) | yes |
| src/actors/Weapons/Rifle.dec | 1-1003 (1-732, 732-1003) | yes |
| src/actors/Weapons/DEFAULTWEAPON.dec | 1-972 | yes |
| src/actors/Weapons/Axe.dec | 1-864 | yes |
| src/actors/Weapons/Plasma.dec | 1-855 | yes |
| src/actors/Weapons/RocketLauncher.dec | 1-816 | yes |
| src/actors/Weapons/AssaultShotgun.dec | 1-807 | yes |
| src/actors/Weapons/Sniper.dec | 1-734 | yes |
| src/actors/Weapons/Saw.dec | 1-711 | yes |

Outside the part, read to confirm or kill a suspicion:
- `src/DECORATE.rsqdual`: the five copies of my guns (RSQ_Off_Rifle 2518-3474, RSQ_Off_Plasma_Gun 3484-4238, RSQ_Off_Shot_Gun 4250-5271, RSQ_Off_AssaultShotgun 5888-6688, RSQ_Off_RailGun 6698-7443) compared with their main by `diff` of the two actor blocks, every differing line looked at. Header 1-60 read. `DECORATE.rsm`, `.rsqbash`, `.rsqmg`, `.rsqmoon` read whole (they are short). `DECORATE.rsqdualmg` not needed (Minigun only).
- Sniper, Rocket_Launcher and Chain_saw have NO off-hand copy (`src/zscript/rsq/dualtable.zs` 8-13).
- `src/zscript/rsq/dual.zs` whole, `dualtable.zs` whole, `flick.zs` whole, `alts.zs` whole, `semiauto.zs` whole, `rlock.zs` whole.
- `src/zscript/rsr/rsr_pump.zs` 116-405 and 560-999; `src/zscript/rsr/vreload.zs` 335-484, 640-1100, 1180-1459; `src/zscript/rsvr/melee.zs` 136-203, 1540-1650, 1850-1910; `axegrab.zs` 30-52; `rsld/handler.zs` 1000-1022, `ld_g2_fx.zs` 505-520, `ld_g5_core.zs` 225-250; CVARINFO lines found by grep.

## Findings, worst first

## B1.1: A Railgun in the off hand still has Brutal Doom's zoom on its secondary button (whole view x5, light amplifier on), and it puts the main-hand gun into its aiming states
- Kind: drifted copy
- Where: src/DECORATE.rsqdual:7122-7160 (copy's `AltFire:`); main: src/actors/Weapons/Railgun.dec:442-448 (`AltFire:` that only swallows the press, `ZoomAltFire:` kept below it); src/zscript/rsq/scope_real.zs:312
- What the code does: on 2026-10-23/28 the main Railgun's `AltFire` was replaced by a one-tic state and BD22's zoom was renamed `ZoomAltFire` (never entered). The copy was not touched: its `AltFire` is still the zoom. It gives "Zoomed" (7127), sets crosshair 41, calls `A_ZoomFactor(5.0)` (7129), plays "ads/in" and "RAIL_ZM", and gives "PowerLightAmp" (7140, 7154). The copy's Ready goes there whenever the off hand's secondary button is down (the `OverlayID() == 1000000 && buttons & 134217728` test).
- Why it is wrong: the main gun's comment says "Nothing gives the Zoomed token from this weapon any more". The copy does. "Zoomed" is one token for the player, so the main-hand gun reads it too: a main RailGun goes to Ready2 / ZoomedRecoil (Railgun.dec:186, 279), a main Shot_Gun to Ready2 (Shotgun.dec:384), a main Rocket_Launcher to Ready2 (RocketLauncher.dec:193). The live scope reads only the MAIN secondary button (scope_real.zs:312), so the off-hand railgun has no scope toggle either.
- Checked: the diff of the two actors (the copy lacks Railgun.dec 419-447 and nothing else there); `rsq_dual_railgun` is off by default (CVARINFO.rsqdual:13) but dual.zs:80-94 turns any Railgun put in the off hand into this copy, Dual Options on or off. Could not see: whether the off hand's secondary button is bound on a stock QuestZDoom layout, and what A_ZoomFactor does to the headset view (Sniper.dec:439 says "on the whole view").
- Sure?: certain the copy runs BD22's zoom; likely that a player meets it. One press of the off-hand secondary button with a Railgun in the off hand settles it.
- Fix A: in the copy, rename `AltFire:` to `ZoomAltFire:` and add above it `AltFire:` / `RAIL A 1 A_WeaponReady(WRF_NOSECONDARY)` / `Goto Ready` (4 lines, 1 file).
- Fix B: the same, and let scope_real.zs toggle the off-hand railgun's scope from BT_OFFHANDALTATTACK (about 10 lines, 2 files).
- Or intended: only if the off-hand railgun is meant to keep BD22's zoom; then the shared "Zoomed" token still needs to be the copy's own.
- Already known?: no

## B1.2: "Pump Spread" set to Enhanced changes only the main-hand shotgun; the off-hand shotgun keeps Brutal Doom's pattern
- Kind: drifted copy
- Where: main src/actors/Weapons/Shotgun.dec:483, 484, 486 (hip shot), 615, 616, 618 (aimed shot); copy src/DECORATE.rsqdual:4729, 4730, 4732, 4861, 4862, 4864; row src/MENUDEF.rsq:131; cvar src/CVARINFO.rsx:17
- What the code does: the main gun's three A_FireBullets take their spread from `GetCVar("rsq_pump_spread") == 1 ? 3.0 : ...`. The copy has the old fixed numbers (5, 1) (2.5, 2.5) (6, 3).
- Why it is wrong: one gun in each hand, one menu row, two different patterns.
- Checked: both actors side by side; the slug line (4959) is the same in both. The DM states differ the same way (4778-4781, 4901-4904) but nothing jumps to them.
- Sure?: certain.
- Fix A: copy the six lines from Shotgun.dec into the copy (6 lines, 1 file; 12 with the DM states).
- Or intended: no.
- Already known?: no

## B1.3: Assault Shotgun: press secondary (slug) on an empty gun, reload, and the next PRIMARY shot is a slug
- Kind: wrong behaviour
- Where: src/actors/Weapons/AssaultShotgun.dec:370-376 (RSA_ASlugGo gives RSA_ASlug / RSA_ASlugOff, then `Goto Fire`), 241-243 (Fire leaves to NoAmmo), 263 (ResumeFireFrame reads the token), 152-175 (Ready: nothing takes it); copy src/DECORATE.rsqdual:6133, 6155, 6267, 6274
- What the code does: the token is given BEFORE Fire checks for ammo. With the magazine out (HasUnloadedASG) or empty, Fire goes to NoAmmo and the token stays. Only RSA_ASlugShot takes it (378-382). The pump Shotgun has four lines in Ready that drop an unused slug (Shotgun.dec:389-392, "a slug asked for and never fired is dropped"); the Assault Shotgun has none, and no script touches the token (grep: only the class lines in src/zscript/rsq/alts.zs:16-17).
- Why it is wrong: the next trigger pull, primary, fires one 150-damage round with the pump's sound instead of buckshot. `rsa_asg_slug` is on by default (CVARINFO.rsr:33), so this is the default game.
- Checked: every use of RSA_ASlug and RSA_ASlugOff in src; MaxAmount is 1 (RSVR_Token), so one shot leaks, not several.
- Sure?: certain.
- Fix A: add the pump's four lines to the Assault Shotgun's Ready, with RSA_ASlug / RSA_ASlugOff, right after AssaultShotgun.dec:154 and in the copy's Ready (DECORATE.rsqdual:6044). They only jump inside themselves, and nothing in this file uses `Ready+N` (8 lines, 2 files).
- Fix B: in RSA_ASlugGo go to NoAmmo before giving the token when HasUnloadedASG is held or the magazine is empty (6 lines, 2 files).
- Or intended: no.
- Already known?: no

## B1.4: Rounds from a magazine you dropped by hand can be left out of the gun, and some lost for good, when that reload is finished by Brutal Doom's own reload
- Kind: wrong behaviour
- Where: every magazine gun of this part: Railgun.dec:26-34 and 44-50, Rifle.dec:26-36 and 47-54, Plasma.dec:26-36 and 47-54, RocketLauncher.dec:28-36 and 46-52, AssaultShotgun.dec:24-32 and 42-48, Sniper.dec:29-37 and 47-53 (rounds go to RSR_Held_<gun> at mag-out and come back only in RSR_Return); the stock branch RSR_Stock: Railgun.dec:633, Rifle.dec:815, Plasma.dec:657, RocketLauncher.dec:597, AssaultShotgun.dec:500, Sniper.dec:610; src/zscript/rsr/vreload.zs:864-886, 1086-1095
- What the code does: with Real reload the magazine's rounds are parked in RSR_Held_<gun> and the gun waits in RSR_Wait, where switching weapons is allowed. The held rounds return only when a magazine is seated by hand. If the next Reload is not the hand reload (RSR_Start.Called returns without RSR_Go: the off hand no longer holds RSQ_Hands because a second gun, an axe or a series item was drawn; Reloading set to stock; not in VR), the gun goes to RSR_Stock and BD22's loop fills from the reserve only. Nothing in that path gives the held rounds back.
- Why it is wrong: (1) with an empty reserve the "held rounds reload even on an empty reserve" line (for example Rifle.dec:795) lets the reload start, BD22's animation plays, and the gun is still empty while up to 30 rounds sit in RSR_Held_Rifle. (2) Later, at the next hand reload, RSR_Unload adds the magazine to the held pile and RSR_Return1 gives them back one by one; A_GiveInventory does nothing at the cap, so everything over a full magazine is taken from the pile and never given (Rifle.dec:50-54).
- Checked: vreload.zs Begin, Abort, End, Resume and the RSR_Tick "IDLE: end it" branch (897-910): none of them touches RSR_Held_*. flick.zs:3-7 confirms the main gun's gesture reload is BD22's own whenever the off hand holds a gun or a series item. RSR_Held_* MaxAmount is 999 (rsr_guns.bd.zs:1015-1032), so the pile itself never clips.
- Sure?: likely. Certain by reading; how often it happens depends on play (drop the magazine, then draw something into the off hand before seating a new one).
- Fix A: in RSR_Start.Called, in the branch that refuses (vreload.zs:870-882), move RSR_Held_<ReadyWeapon class> back into the gun's magazine (Ammo2) up to its cap and the rest into the reserve (about 10 lines, 1 file; the Rifle and Plasma also keep DoubleRifleAmmo / DoublePlasmaAmmo in step).
- Fix B: start every RSR_Stock with the gun's own RSR_Return loop (about 5 lines in each of 18 gun files).
- Or intended: no; the comment at the top of RSR_Unload says "the reserve's cap loses none".
- Already known?: no

## B1.5: With VR throwing off (or out of VR), the off-hand axe that has chopped once starts obeying the main hand's keys: a kick is thrown twice, a Brutal Doom grenade twice, sprint drains stamina twice as fast
- Kind: wrong behaviour
- Where: src/actors/Weapons/Axe.dec:478-481 (copy's Fire ends `Goto Super::Fire`), 329 and 281 and 406 (`Goto Ready` in the main axe's EndSwing, CancelFire, AltEndSwing), 177-198 (main Ready), 453-454 (the comment that says the copy's Ready reads none of the main hand's tokens)
- What the code does: RSQ_Off_BrutalAxe has its own Ready (475-477) that reads no tokens. But its chop runs the main axe's states, and a DECORATE `Goto` inside inherited states is fixed to the class it was written in, so after the swing the off-hand layer lands in BrutalAxe's Ready and stays in its `Goto Ready+6` loop. That loop reads Kicking, Taunting, Salute1/2, TossGrenade, IsRunning and RSVR_AxeHold (184-196). Both hands' layers then answer the same token: DoKick runs twice (two KickAttack), TossGrenade twice (two grenades, two GrenadeAmmo), StartSprint twice (UsedStamina given by both), and the grip sends the off axe into the MAIN axe's AltGrip.
- Why it is wrong: the copy's own comment says its Ready reads none of them "because they are the MAIN hand's".
- Checked: the rule is the one the owner's own comment states in src/DECORATE.rsm:4-5 ("an inherited Goto Explode would still go to ShortGrenade's own"); BrutalWeapon uses `A_Jump(256, "Ready3")` for the same reason (DEFAULTWEAPON.dec:166, 175). The copy only reaches `Super::Fire` when RSVR_OffAxeVRThrow is 0: melee.zs:151 sets it from `InVR && rsg_vr != 0`, and `rsg_vr` is 1 by default (CVARINFO.rsb:12). A kick does heal it (DoKick ends through BrutalWeapon's Ready3, which jumps by name), until the next chop.
- Sure?: certain about where the layer lands; likely about the doubled actions (they follow from two layers reading one token; Brutal Doom's ACS that clears the tokens is not in the repo). Settle: VR throwing off, an axe in each hand, chop once with the off hand, press kick.
- Fix A: in BrutalAxe change the three `Goto Ready` (Axe.dec:281, 329, 406) to a named jump, `"####" "#" 0 A_Jump(256, "Ready")` followed by the old `Goto Ready` (3 lines, 1 file). The main axe behaves as before; the copy returns to its own Ready.
- Fix B: give the copy its own chop states instead of `Goto Super::Fire` (about 30 lines, 1 file).
- Or intended: no.
- Already known?: no

## B1.6: Two of the same gun share Brutal Doom's per-gun tokens, so one hand's state leaks into the other
- Kind: wrong behaviour
- Where and what, one line each:
  - Assault Shotgun: `HasUnloadedASG` is one token. While one gun's magazine is out (BD22's reload gives it at AssaultShotgun.dec:508 and takes it at 514, about 21 tics; BD22's Unload and a hand reload left half done keep it for as long as you like) the OTHER gun's trigger only clicks: Fire, AssaultShotgun.dec:241 and src/DECORATE.rsqdual:6133, `HasUnloadedASG -> NoAmmo`.
  - Plasma: `PlasmaCharging` is one token. Reload either gun while the other hand holds a charge: that Reload goes to Cancel (Plasma.dec:649; copy 4137), which GIVES that gun 10 rounds it never spent (Plasma.dec:595-609) and does not reload it. The off copy's charge is also cancelled by the main hand's "Reloading" token (copy 3969-3975, not hand-aware), and its Cancel then takes that token (Plasma.dec:610), so the main gun's reload press can be eaten.
  - Rifle and Assault Shotgun: `RifleReloadToken` / `ASGReloadToken` are one token each. While one gun is in BD22's bolt part of its reload, a reload asked of the other gun goes to Inspect (a 7-tic fidget) and does not reload (Rifle.dec:803, copy 3318; AssaultShotgun.dec:486).
  - Rifle, Plasma, Railgun, Shotgun: `HasUnloadedRifle`, `HasUnloadedPlasma`, `HasUnloadedRailgun`, `HasUnloadedShotgun` shared: looks only (which picture, whether a casing flies).
  - `Zoomed` shared: see B1.1; the pump Shotgun's BD22 aim on secondary (when `rsa_sg_slug` is off, the default) also puts the other hand's shotgun into Ready2.
- Why it is wrong: 2.0.5u already fixed exactly this for the pump shotgun's chamber token ("It shared BD22's ShotgunWasEmpty", src/DECORATE.rsqdual:4236-4239); the other tokens were left shared.
- Checked: the diffs show only the magazine ammo (and RSQ_ShotgunWasEmptyOff, RSLD_AltDownOff) renamed in the copies. Dual reload is always BD22's stock reload: vreload.zs:1094 (Wanted needs RSQ_Hands in the off hand) and flick.zs:411-455.
- Sure?: certain for the Assault Shotgun block and the Plasma free rounds by reading; likely as play (the windows are short unless a magazine was left out). `rsq_dual_asg` is off by default, `rsq_dual_plasma` and `rsq_dual_rifle` are on.
- Fix A: as 2.0.5u did: give the copies their own HasUnloadedASG, PlasmaCharging and the two reload tokens (renames inside the copies: about 14, 6 and 8 lines; 1 file, plus one class line each and dual.zs SwapMags if they should travel with the gun).
- Fix B: only the two that cost the player: the copy's `HasUnloadedASG` and `PlasmaCharging` (about 20 lines, 1 file).
- Or intended: the looks-only tokens can stay shared.
- Already known?: no

## B1.7: Rocket launcher lock-on: let go with fewer rockets loaded than the salvo needs, and the launcher finishes the salvo by itself after the reload
- Kind: wrong behaviour
- Where: src/actors/Weapons/RocketLauncher.dec:467-473 (after the last rocket: `Goto Reload`, whatever NoAutoReload says), 577-596; src/zscript/rsq/rlock.zs:110-151 (the salvo), 7-9 (the header: "No rocket left: the rest of the salvo is dropped")
- What the code does: rlock.zs fires the next salvo rocket whenever the launcher is ready again (`WF_WEAPONREADY`, line 132). It drops the salvo only when a Fire it started gave no rocket within 6 tics (125-131). After the last loaded rocket the launcher never becomes ready: BD22 sends it straight into Reload. The salvo waits through the whole reload (BD22's, about 2 s, or the hand reload, as long as the hand takes) and then fires the remaining rockets with no button pressed.
- Why it is wrong: the header promises the rest is dropped; a launcher that fires on its own seconds after a hand reload is not what "let go to fire" means. Locks that left sight are kept while the button is up (line 100), so the late rockets can go round a corner.
- Checked: RSR_Wait uses WRF_NOFIRE (RocketLauncher.dec:38), so the ready flag stays clear during the hand reload; Clear() runs only on a weapon change, death, or the option off (rlock.zs:84-92). With no reserve rockets Reload returns to Ready and the "no rocket came out" rule does drop it: that case is right.
- Sure?: likely. Settle: load 1 rocket, lock 1 enemy, let go.
- Fix A: in rlock.zs WorldTick drop the salvo when the launcher has no round (`CountInv("RocketRounds") == 0` and not NoReloading / purist) or when it has not been ready for some tics after a salvo rocket (about 5 lines, 1 file).
- Or intended: if the salvo is meant to carry over a reload, the header line is wrong.
- Already known?: no

## B1.8: Netplay: "Rocket Launcher Lock-On Alt Fire" is a per-player setting read two different ways
- Kind: netplay
- Where: src/CVARINFO.rsr:34 (`user bool rsa_rl_lock`); src/zscript/rsq/alts.zs:33-57 (`CVar.FindCVar`, then the token RSA_Opt_RLLock for EVERY player); src/zscript/rsq/rlock.zs:83 (`CVar.GetCVar('rsa_rl_lock', p)`, per player); src/actors/Weapons/RocketLauncher.dec:684
- What the code does: the launcher's AltFire goes to the lock state when the player holds RSA_Opt_RLLock. alts.zs gives that token from the LOCAL machine's copy of the cvar to all players; each machine does so from its own value. rlock.zs paints and fires from each player's own value.
- Why it is wrong: with two players who set it differently, each machine gives different tokens (play state differs between machines: a desync), and a player can sit in the lock state with no painting, or zoom with painting. alts.zs:3 says "Server options: they change what is fired"; the other four cvars in that list are `server`, this one is not.
- Checked: the five cvar declarations (CVARINFO.rsr:30-34). Single player is not affected.
- Sure?: certain by reading; netplay only.
- Fix A: make it `server bool` in CVARINFO.rsr:34 and read it with FindCVar in rlock.zs:83 (2 lines, 2 files).
- Fix B: keep it per player and give the token per player in alts.zs (`CVar.GetCVar(cv[k], players[n])`) (3 lines, 1 file).
- Or intended: no.
- Already known?: no

## B1.9: An empty pump shotgun makes no dry click when auto-reload is off, which is always the case with a gun in each hand
- Kind: wrong behaviour
- Where: src/actors/Weapons/Shotgun.dec:449 (Fire: ShotgunWasEmpty -> Pump2), 555-557 (Pump2: no shells, `NoAutoReload -> Ready`), 505-507 (Pump1 the same); copy src/DECORATE.rsqdual:4752, 4802; src/zscript/rsq/dual.zs:431-440 (NoAutoReload forced on while both hands hold guns)
- What the code does: after the last shell the chamber token stays set. Each trigger pull goes Fire -> Pump2 -> Ready with no tic and no sound; "Pumping" is given every time. Every other gun goes through BrutalWeapon's NoAmmo (click, then NoAutoReload -> Ready, DEFAULTWEAPON.dec:209-226).
- Why it is wrong: nothing tells the player the gun is empty, in the one mode (dual) where the mod has switched auto-reload off for him.
- Checked: these lines are BD22's own; the mod's part is forcing NoAutoReload. Could not see how BD22's player sprite reacts to "Pumping".
- Sure?: likely (certain by reading; BD22's own option gives the same silence).
- Fix A: in Pump2 only, send that case to NoAmmo: Shotgun.dec:556 and DECORATE.rsqdual:4802, `"Ready"` -> `"NoAmmo"` (2 lines, 2 files). Pump1 is left alone: it is reached right after the last shot, where a click would be wrong.
- Or intended: if silence on empty is wanted.
- Already known?: no

## B1.10: Guns with no off-hand copy, held in the off hand as themselves, keep main-hand rules there: the Ruger is not semi-auto, the chainsaw is not the VR chainsaw
- Kind: wrong behaviour
- Where: src/zscript/rsq/dual.zs:93-94 ("Weapons with no off-hand version ... go into the off hand as themselves"); src/zscript/rsq/semiauto.zs:24-34 (RSQ_SemiLock is taken when the MAIN trigger and FiredPrimary are up); src/actors/Weapons/Sniper.dec:152, 239, 265; src/zscript/rsvr/melee.zs:199 (RSVR_SawVR from the main hand's weapon only) and 762-773 (KindOfOff knows the axe and the clubs, not the saw); src/actors/Weapons/Saw.dec:172; src/zscript/rsq/rlock.zs:82, 93 (ReadyWeapon and BT_ALTATTACK only)
- What the code does: an off-hand Sniper gives itself RSQ_SemiLock when it fires; the lock is removed on the next tic because the main trigger is not down, and Ready sends it back to Fire while the off trigger is held. An off-hand Chain_saw never gets RSVR_SawVR, so its trigger plays BD22's swing and nothing cuts by contact. An off-hand Rocket_Launcher has no lock-on.
- Why it is wrong: the off hand's Ruger is the "fires 100000 times a second" fault again (Sniper.dec:7).
- Checked: the three scripts above. Could not see: whether QuestZDoom's switch-hand (or the Wheel, a holster) really lets these three into the off hand; dual.zs says it does.
- Sure?: unsure. Settle: put the Ruger in the off hand and hold its trigger.
- Fix A: an off-hand lock for the Sniper as roster.zs:25-34 has for the Silvergun (RSQ_SemiLockOff), chosen by OverlayID in Sniper.dec:239 and 265 (about 8 lines, 2 files); for the saw, set a second token from KindOfOff or keep the saw out of the off hand.
- Fix B: keep the three out of the off hand (dual.zs Hands: send them back to the main hand) (about 10 lines, 1 file).
- Or intended: if these guns are never meant to be in the off hand, B is the fix that says so.
- Already known?: no

## B1.11: During a hand reload the kick, grenade, taunt and unload keys do nothing, then act when the reload ends
- Kind: wrong behaviour
- Where: RSR_Wait in each magazine gun: Railgun.dec:35-40, Rifle.dec:37-42, Plasma.dec:37-42, RocketLauncher.dec:37-42, AssaultShotgun.dec:33-38, Sniper.dec:38-43; the pump waits Shotgun.dec:134-143, 187-196, 234-243; compare Shotgun.dec:87-96 (RSP_LoadWait does read Kicking and IsRunning)
- What the code does: the wait states read only the reload's own tokens. BD22's Kicking, TossGrenade, Taunting, Unloading tokens stay in the inventory and the gun's Ready acts on them when the reload is over, which by hand can be many seconds later.
- Why it is wrong: a kick asked for under attack arrives after the fight; the pump's loading wait already handles kick and sprint, the others do not.
- Checked: BD22's own reload animations also ignore these keys, but they last about 2 s. Could not see whether Brutal Doom's ACS times the tokens out.
- Sure?: unsure (depends on the ACS). Settle: start a hand reload, press kick, finish the reload 10 s later.
- Fix A: in each wait state take the tokens that cannot be served (`A_TakeInventory("Kicking",1)` and the others) or jump to DoKick as RSP_LoadWait does (4 to 6 lines a gun).
- Or intended: if a late kick is acceptable.
- Already known?: no

## B1.12: Pump shotgun, empty: the reload button cannot end the hand-loading, and the trigger does nothing
- Kind: wrong behaviour
- Where: src/actors/Weapons/Shotgun.dec:93 ("BD22: reload again finishes"), 106-110 (RSP_LoadEnd), 45-50 (RSP_NoCase), 548-557 (Pump2), 843-851 (ReloadNormally -> RSP_Load); src/zscript/rsr/rsr_pump.zs:660-679
- What the code does: with no shell in the gun, RSP_LoadEnd goes to RSP_NoCase -> Pump2; Pump2 finds no shell and (auto-reload on) goes to ReloadNormally -> RSP_Load -> RSP_LoadGo -> RSP_LoadWait, all in the same tic. The trigger takes the same road (Fire -> Pump2). The gun is back in the loading wait, where TossGrenade, Taunting, Unloading and the execution token are not read. Each pass also gives HasUnloadedShotgun.
- Why it is wrong: the comment on line 93 says reload again finishes; on an empty gun it cannot. Only a shell, a weapon switch, a kick or sprint leaves the state.
- Checked: LoadStart keeps the load going when `mode == LOAD && weap == w` (rsr_pump.zs:668-671), so the loop is seamless. BD22's own empty shotgun also insists on reloading; there the animation ends by itself.
- Sure?: likely.
- Fix A: read the same keys in RSP_LoadWait that Ready reads (TossGrenade, Taunting, Unloading, ExecuteDownedEnemy), and on a `Reloading` press with an empty gun go to Ready instead of RSP_LoadEnd (about 6 lines, 1 file).
- Or intended: if an empty shotgun is meant to stay in loading until a shell goes in.
- Already known?: no

## B1.13: Rifle: every second shot uses the deathmatch puff; chainsaw secondary after a hit does the same (labels defined twice)
- Kind: wrong behaviour
- Where: src/actors/Weapons/Rifle.dec:350 and 370 (`SpriteVariant:` twice), 397 and 429 (`SpriteVariant2:` twice), jumps at 345 and 392; copy src/DECORATE.rsqdual:2872, 2892, 2919, 2951; src/actors/Weapons/Saw.dec:465 and 497 (`AltFireLoop2:` twice), `Goto AltFireLoop2` at 559
- What the code does: a label defined twice in one actor points at the LAST definition. The Rifle's "PSeq3" jump therefore lands in the copy under `DM:` and fires with "HitPuffDM"; the saw's AltContinue goes to the `DMAlt` copy with "SSawPuff3DM".
- Why it is wrong: the DM states are otherwise dead (their jumps are commented out, Rifle.dec:347). Going by the pattern in Axe.dec:744 (`AxePuffsDM : AxePuffs { -MTHRUSPECIES }`), the DM puff does not pass through other marines, so in co-op every second rifle bullet could hit a team-mate.
- Checked: these lines are Brutal Doom's own, not the owner's. HitPuffDM and SSawPuff3DM are not in the repo.
- Sure?: unsure about what a player sees (single player: probably nothing); likely about which state runs. Settle: read HitPuffDM in brutal22test6.pk3.
- Fix A: rename the second `SpriteVariant` / `SpriteVariant2` / `AltFireLoop2` (for example `SpriteVariantDM`) in Rifle.dec, the Rifle's copy and Saw.dec (5 lines, 3 files).
- Or intended: Brutal Doom's own behaviour; leave it if the files are to stay BD22's.
- Already known?: no

## B1.14: LegenDoom mode: the jam and the trigger hold have no hook on the Assault Shotgun, the Railgun and the Ruger
- Kind: wrong behaviour
- Where: hook present at Shotgun.dec:440-444, Rifle.dec:303-307, Plasma.dec:377-381, RocketLauncher.dec:351 and 372-374; absent from AssaultShotgun.dec:234, Railgun.dec:246, Sniper.dec:238 and the two copies (DECORATE.rsqdual:6126, 6948); src/zscript/rsld/ld_g2_fx.zs:505-513, ld_g5_core.zs:229-246
- What the code does: on a gun without the first-line jump to RSLD_Jammed, a jammed pull still plays its shot (sound, flash, recoil, casing) and only the pellets are dropped (the code's own note: "GAP"); a G5 trigger hold does not hold.
- Checked: the earlier list's Q6 says these guns never get a legendary today, so nothing shows yet.
- Sure?: certain the hook is missing; it only matters once they get a slot.
- Fix A: when Q6 is built, add the two-line hook (the Fire line and the RSLD_Jammed state) to the three guns and two copies, and re-check every `Fire+N` in them, as was done for the Sniper at Sniper.dec:251 (about 4 lines a gun).
- Or intended: yes until Q6 is built.
- Already known?: yes in part, Q6, owner said: "Give them a slot. Not built: a job for a coding session."

## B1.15: Small Brutal Doom faults kept in these files (the owner's patch did not make them)
- Kind: wrong behaviour
- Where and what:
  - RocketLauncher.dec:747 `Goto NoAim+17` lands one state early (line 749 instead of the `MISG I 0` on 750; ToggleNoAim+9 at 763 is right): leaving the zoom with one rocket loaded and two or more in reserve shows the two-rocket picture for 5 tics. Only with Lock-On off.
  - RocketLauncher.dec:472-473: after the last rocket the launcher reloads by itself even with NoAutoReload on; with Real reload this means the tube opens on its own.
  - Sniper.dec:696-697: Unload on an empty Ruger goes to NoAmmo (a click, then a reload).
  - AssaultShotgun.dec:700: with TurboReload, Unload loads the gun.
  - Sniper.dec:481 `SINP D 5` (a misspelt sprite) in the zoom states, which nothing enters now.
- Checked: all five are in BD22's own lines; none has a "posefix" or dated note.
- Sure?: certain by reading; low.
- Fix A: `NoAim+17` -> `NoAim+18` (1 line); the others only if wanted.
- Or intended: Brutal Doom's own; leave if the files are to stay close to BD22.
- Already known?: no

## B1.16: Dead code and comments that no longer match (no player effect, but they mislead the next change)
- Kind: dead code
- Where and what:
  - Axe.dec:683-701 `RSVR_AxeHalf` and its comment about the two-handed axe: nothing spawns it (melee.zs:1434 says so).
  - Axe.dec:118-153 `DualWield` / `StrongThrow`: BD22's canned throw, no longer reachable (Ready's jump was removed, no User3 label); if it were reached it would throw without spending an axe from the pool.
  - Shotgun.dec:115-120 RSP_LBack: both branches do the same thing; the comment on 115 ("a spent shell comes out as in Pump2") is no longer true.
  - DEFAULTWEAPON.dec:227-228: the three states and `Goto NoAmmo+4` after `wait` cannot be reached.
  - Sniper.dec:7-11 says +WEAPON.NOAUTOFIRE is what makes the Ruger semi-auto; semiauto.zs:2-7 says that flag cannot do it on QuestZDoom 17.3 and RSQ_SemiLock does.
  - Line 1 of every file in this part says the lines marked "posefix" are the only changes. They are not: the hand-aware `OverlayID()` tests, the RSLD, RSA, RSM, RSP and RSVR lines carry other marks or none.
  - The copies' RSR / RSP hooks, and the changes they lack (the `RSR_Held_*` line in Reload: Railgun.dec:616, Rifle.dec:795, Plasma.dec:651, AssaultShotgun.dec:478; RSP_NoCase and the 2.0.3q line, Shotgun.dec:41-50 against DECORATE.rsqdual:4292-4294, 4350-4366), cannot run: with a gun in the off hand Wanted() is false (vreload.zs:1094), so every hook falls through to BD22's own states. The difference is harmless today and becomes a real one the day the off hand can hand-reload.
  - The Rifle copy has the purist line after the unconditional jump (DECORATE.rsqdual, AltFire at 3122; main Rifle.dec:608-609): unreachable there.
- Sure?: certain.
- Fix A: delete or correct as listed (about 30 lines, 4 files).
- Or intended: the copies' dead hooks are fine as they are.
- Already known?: no (SH11 lists other dead code, not these)

## Things that looked wrong and are not (so the next reader does not chase them)
- The numeric jumps in every Ready, Fire, Reload, Pump1/2/3, Unload, NoAim, RecoilAnimation and SelectAnimation of the ten files were counted state by state (a `Goto` is not a state). All land where meant except RocketLauncher `NoAim+17` (B1.15).
- The `RSR_Held_*` jump added to each Reload (`..., 1, 4)`) and the reserve test after it (`..., 3)`) both land in the padding states; `Goto Reload+6` / `Reload+7` in IsHolding still land on a state that goes the same way.
- The LegenDoom line added as the first state of Fire shifted `Goto Fire+N`: Shotgun.dec:458 (`Fire+5` is now the ShotgunWasEmpty test, was NoReloading), Rifle.dec:326 (now the NoReloading test), RocketLauncher.dec:357 and 370 (`Fire+8` now lands on `MISG I 0`, which is the line Ready's `Ready+10` aims at, so the insert repaired an old off-by-one). Each runs one extra harmless test; no shot, ammo or timing changes. Sniper.dec:251 and 353 were already corrected by hand.
- Pump1+8, Pump1+38, Pump2+9, Pump2+32, Pump3+3, Pump3+20 match BD22's frames, and the tics given to RSP_PumpStart (20, 17, 11) match the frames between them.
- `A_JumpIfInventory("ShotgunWasEmpty", 1, 1)` followed by `Goto` (Shotgun.dec:41, 100) is right: offset 1 skips the Goto.
- A_FireBullets with flags FBF_NORANDOM only takes no ammo; A_RailAttack's third argument (useammo) is 0 in Railgun.dec:278. No shot takes ammo twice or for free, apart from B1.3 (wrong round) and B1.6 (Plasma Cancel).
- No spent shell flies when you pump a shotgun you loaded after firing it dry (RSP_NoCase, Shotgun.dec:45-50). In a real gun one would; the owner asked for none (BUGS_1.0 item 6, quoted in the file).
- An empty pump shotgun goes straight back into reloading (Pump1/Pump2 -> ReloadNormally): BD22's own auto-reload.
- The Sniper's `Deselect` is a zero-tic `A_Lower` with `Wait` (Sniper.dec:235-236): it ends because A_Lower changes the state when the gun is down.
- `"####" A 0 BRIGHT { if (GetCVar(...)) ... }` in Sniper.dec:268 is a legal DECORATE anonymous function.
- Sniper `ResumeFireFrame+15` (353) lands on the A_SpawnItemEx line as its comment says.
- Every token and class named in the ten files that is the mod's own exists in src/zscript or the DECORATE lumps: RSR_Go/Start/MagOut/Tick/Seated/Done/Filled, RSR_Held_ for all six magazine guns, RSP_*, RSA_*, RSM_VR/LoadedOff/FiredOff/KindLoaded/KindLoadedOff, RFGrenadeOff, RSM_KindRound(Off), RSQ_SemiLock, RSQ_ShotgunWasEmptyOff, RSVR_Axe*/OffAxe*/MainAxeNext/SawVR/NotVR/Axes, RSLD_JamMain/Off, RSLD_G5BlockMain/Off, RSLD_AltDown(Off), RSLD_G7NoTurn. The cvars read from DECORATE exist: rsq_pump_spread (CVARINFO.rsx:17), sv_rsq_true_bullets (CVARINFO.rsx:12).
- BrutalAxeOnWall's `RSVR_Axes, 10` (Axe.dec:857) equals the pool's MaxAmount (axegrab.zs:38).
- The magazine caps of the copies' ammo (31, 50, 9, 20, 5) match the mains' and dualtable.zs:23.
- Copy against main, apart from B1.1, B1.2, B1.6 and the dead hooks in B1.16: damage, pellet counts, ammo use, tics, sounds and flags are the same line for line in all five pairs; the only other differences are the magazine names, `SXF_SETTRACER` on the muzzle glow (meant, header of DECORATE.rsqdual), the off-hand tag lines, and the Rifle copy lacking the `RSM_KindLoaded` lines in FireGrenade (the copy fires its launcher through RSM_FireOff, which has them).
- PuristRifle's `Goto Ready3` resolves to the Rifle's own Ready3; fine.

## Not read or not checkable
- Brutal Doom itself (brutal22test6.pk3): its ACS (what sets and clears FiredPrimary, FiredSecondary, Reloading, Kicking, NoAutoReload, StartDualWield; "FistSelect"; "GetCrosshair"), its puffs, projectiles and sounds. Findings B1.5, B1.9, B1.11, B1.13 depend on it and say so.
- The QuestZDoom engine: how the off-hand layer handles A_WeaponReady, A_ReFire and the off-hand buttons, and what A_ZoomFactor does in the headset (B1.1, B1.10).
- In src/zscript only the parts listed under "Files read" were read; rsr_pump.zs, vreload.zs, melee.zs and axegrab.zs were NOT read whole (they belong to other parts).
- `src/DECORATE.rsqdual` was compared by diff for my five guns, not read line by line outside the differing lines; the other copies in it were not looked at.
- Sprites, models and sounds named in the ten files were not checked against the repo's assets (almost all are Brutal Doom's own).
