# Menu pass brief (owner 11-04 18:32, his answers)

Style: BD22 VR Reloaded's menu (rs_brutal22weaponsq src/MENUDEF.rsq is the model): many options, few sub pages, lots
of customisation, nothing confusing or verbose. Short labels. A row's name promises only what it really does.
- Each mod: its own page under Radiant Silvergun Options. Everything on that main page except tuning/debug.
- One "Tuning and Debug" sub page per mod for debug logs, raw distances, timing numbers. No other sub pages unless a
  mod truly needs one (e.g. a long colour list) -- fold existing sub pages back into the main page where sensible.
- Every feature has a switch: core features default ON, optional extras default OFF. Don't change existing defaults
  (owner-decided) except where BUGS_0.99a.md items say so.
- Everything reachable from the menu, no console. Every cvar a player could want has a row (BUGS items: Score caps &
  reward settings, Melee punch numbers + off-hand grip keys, Grapple whip_above/yank radius/height, GBOVR dual HUD /
  single-HUD hand / per-hand positions & mirroring, FnF rsqff_keys_off, DistanceGrab path_tmin/tmax/air_flutter/
  air_maxtics/keys, Whip Controls (its four binds as Control rows) and Debug Log level 5, Score's Bonus Display Time
  reaching 0). Grapple's rope-only rows say so briefly (or grey out when Rope/Swing is off). Gun Cards' "Inspect
  Gesture" label honest without RSQ Gestures. Glow/Lightning Beam etc: labels honest about what they need.
- Every page has a Reset All covering every cvar on it (and on its Tuning page).
- GUN BONSAI VR GATING: when RSQ Gun Bonsai VR is loaded, each mod page whose rows are unlocked by GBOVR upgrades shows
  ONE top line: "GunBonsaiOVR detected. Mod features unlocked via upgrades." Rows locked behind an upgrade the player
  hasn't learned are greyed out (not hidden), with no extra text. Without GBOVR: no line, nothing greyed. Find which
  rows are upgrade-gated by reading each mod's GBOVR checks (the code already decides; the menu just shows it). Use a
  ZScript OptionMenuItem subclass (the series' rsmenu template already has custom items) for greying.
- Radiant Silvergun Options order BY GROUP: Body (Tactical Rig, Gestures, Accessibility), Hands (Saber, ShieldSaw,
  Melee, Whip, Grenade, FnF), Reach (Grapple, Distance Grab, Laser Sight), Game (SlowMo, Score, Miniboss,
  VisualRewards, Gun Cards, Wheel, Glow In The Dark, Gun Bonsai VR). Via the shared rsmenu template's Rank() in every
  copy (keep copies identical).
- Accessibility's "Menus: Simple" must keep working with the new pages (update its lists).
- Proof: frames of every mod's page (and its Tuning page), with and without GBOVR (gating line + a greyed row);
  zero script errors on the three orders; each README's Menu table updated to match the new rows/labels.

## Stowed items always shown, each with its own toggle (owner 11-04 19:0x)
"Always show flare, flashlight, whip, sabers, saw. Toggle show ___ on/off in each mod's options."
- Whenever the player owns it and it isn't in a hand, each item is drawn at its spot on the body: flare (FnF chest pocket
  and the Rig's flare holster), flashlight (its chest clip), whip (Rig whip holster), sabers (saber holsters), ShieldSaw
  (on the rig/back).
- The toggle lives in EACH ITEM'S OWN MOD's options, default On: FnF "Show Flare" and "Show Flashlight", Whip "Show
  Whip", Saber "Show Sabers", ShieldSaw "Show ShieldSaw". Where the Rig already has a "Show ... in Holster" row, the mod's
  row is the one that matters (keep the Rig row only if it still means something distinct, else fold it).
- Works without the Rig where the mod has its own spot (FnF pocket/clip, ShieldSaw back); with the Rig, at the Rig's spot.

## The feeling (owner 11-04 19:33, the test for every page)
"I like to offer a lot of options and customization in a simple on / off way, sliders occasionally. I want players to
feel like 'Wow, I have a lot of choices, this is highly customizable and easy to understand!' and not 'Wow, I have a lot
of choices... this is overwhelming and difficult to decipher.'"
- Prefer On/Off rows. Sliders only where a number really matters to play (sizes, speeds, volumes); raw numbers go to
  Tuning and Debug. Avoid multi-choice lists unless the choices are few and plain-worded.
- Labels: 1-4 plain words, the thing the player feels ("Bits Fly to Me", not "rsqgb_kr_magnet radius"). No jargon, no
  internal names, no parentheses essays.
- Group rows under short section headers (StaticText) so a long page reads as a few small lists.
- Most important rows at the top of each page.

## Structure, in the owner's words (11-04 19:36) -- this overrides anything above
"Radiant Silvergun Options: list all 20. We can't have menus-in-menus-in-menus. Each mod has its own menu, and a 'test
and debug' submenu. Radiant Silvergun Options -> list all 20 (or however many are loaded) -> mod options -> test and debug."
- Radiant Silvergun Options = one flat list of every loaded mod (in group order, blank-line spacers only, NO group
  sub menus). Each row opens that mod's page.
- Each mod page = all its options. The ONLY sub menu on it is "Test and Debug" (that name), at the foot above Reset All.
- So fold every other sub page (VisualRewards' Bars/Numbers/Level-Up/Kill Rewards, Laser colours/targets/keys, Distance
  Grab's eight sub pages, Glow's Types/Things/React/Custom, Gun Cards' Place, etc.) into the mod's one page under short
  section headers, or into Test and Debug if it's tuning/debug. No exceptions for long colour lists: use option rows.
- No description lines at the top of mod pages; no presets.
