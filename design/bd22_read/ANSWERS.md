# BD22 VR Reloaded bug read: the owner's answers (2026-11-27)

Nothing in his BD22 repo has been changed yet. Each answer here is to be built there.

| Finding | Answer (his words or his pick) | Built? |
|---|---|---|
| B7.1 grenade pin out across a map change sticks the grenade in the hand | "Pin back in on a new map" (Fix A: Reset right after the state is made, grenade.zs:337-338) | no |
| B7.3 / B3.1 Recoil row does nothing (RSQ_Recoil is in no handler list) | "Recoil stays off, remove the row" (MENUDEF.rsq:132-133, changelog line) | no |
| B8.2 one kick press lands two kicks with a gun in each hand | "Leave it as it is" (intended) | n/a |
| B6.1 / B2.2 / B2.1 eight guns cannot reload with the off hand busy (first asked badly; re-asked) | "Yes, same as the Minigun": reload press or gesture refills the gun by itself when the off hand is busy (RSQ_StockFill pattern, Minigun.dec:35-44) | no |
| B3.2 off-screen reload gesture "never works" | THE READ WAS WRONG. His words: "it works for me, i look dead ahead and point gun 90 deress down and it works, with my ini set like that". Dropped; no change | n/a |
| B3.4 bottom HUD row (VR Row) wrong counts for the nine belt / tank guns | "Fix the counts" (bottomhud.zs:94-107 reads RSQ_HudMag / RSQ_HudRes) | no |
| B3.3 off-hand Silvergun shoots from its grip | "Fix it" (muzzle.zs:310 also matches RSQ_Off_BrutalRevolver) | no |
| B6.2 / B6.4 Revolver "one round at a time" fills all six on the first push; cannot be pushed shut | His words: "THE REVOVLERS SPEEDLOAD ALL OF THE TIME. I WANT THAT. NO MORE SINGLE RELOAD ONE AT A TIME SHIT EVER." So: BOTH revolvers (Revolver and the Silvergun / BrutalRevolver) always speedload; the "Revolver Reload: one round at a time" choice, its row, its setting and its per-round code come out | no |
| B6.5 pump shotgun pumps itself when the trigger is still held from the shot | "Always wait for the hand" (only a new press after the shot skips the hand pump; rsr_pump.zs:872) | no |
| B7.2 axe / Dragonslayer cut by themselves after a menu closes or a save loads | "Fix it" (a hand that jumped while the game was paused is not read as a swing; melee.zs:1119-1128, 1189-1194, pose.zs:87-90) | no |
| B8.1 / B2.4 two Shotvolvers share one hammer state | "Fix it" (each hand's Shotvolver gets its own; rsqdual:899, 937, 949; Revolver.dec:238-410) | no |
| B1.3 Assault Shotgun slug stays armed after an empty secondary press | "Fix it" (clear RSA_ASlug / RSA_ASlugOff in Ready, as the pump shotgun does) | no |
| B1.1 / B8.3 off-hand Railgun secondary still zooms and pushes the main gun into aim | "Match the main Railgun" (off-hand secondary does nothing; rsqdual:7122-7160 against Railgun.dec:442-448) | no |
| B1.2 / B8.5 off-hand pump shotgun ignores Pump Spread | "Off hand follows the setting" (rsqdual:4729-4732, 4861-4864 read rsq_pump_spread) | no |
| B8.4 two guns run BD22's sprint loop: double stamina use and footsteps | "Fix it" (only the main-hand gun runs it) | no |
