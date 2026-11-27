// ============================================================================
// THE SIGNATURE COMBOS: the series' named chains, as data (combo.zs RS_ComboSeed.Combos calls Add). One row per
// recognisable move, chosen 2026-11-03 from the 823 chains of Score/ideas/COMBOS_MASTER.md section 4 for variety and
// coverage without confusion (the owner: "Variety, coverage, but not confusion"): every pairing of the series' mods
// has a row, the characterful names are kept, and the "X into Y" filler is left to the generic chain rule, which pays
// every other mix. Names are proposals; the owner renames after 1.0, and a rename never needs code (the sheet's
// "suggested name" column is the source of these strings).
//
// A pattern is "a > b > c", the last step the finishing blow (combo.zs): a step is a tool id, a prefix (saber,
// grenade, gun...) or a group (hands, fists, melee, block, parry, return, throw); it may carry @slow (landed in
// the player's own slow motion), +air / +pb / +head / +<tag>, and the pattern may end "| <filter>" on the victim.
// Pay is a multiplier of the kill's base. A named row must pay more than any broader row it sits under (the
// best-paying match wins), so a class row (gun.shotgun) always beats its plain twin (gun), and a row under Lion Tamer
// (whip > shield.bash 0.5) or Into the Breach (grenade > melee 0.45) was raised past it.
//
// The rows that are combos already and keep their own classes: Pulled In (force.pull > melee), Riposte / Perfect
// Riposte (block / parry > any). A row here under one of them fires only for what it pays past that row (combo.zs).
//
// 2026-11-27: 228 rows here became 159 (with combo.zs's own, 242 named combos became 171). Out: every row with a step
// no mod can make any more. The Grapple's steps (hook, hook.yank, hook.keg, hook.zip: owner, "New rows for new moves";
// the Grapple pulls nothing to you now), the Whip's lasso, bola, wrap, yank, tarzan and flail (it has two moves and no
// rope), and shield.dash and grab.shield, which no mod sends (owner: "Remove, keep Chain Gang"). A whip row left here
// names `whip` or `whip.crack`: the Wide Swing is whip.crack, and the Ground Crack (whip.ground) answers `whip`.
// ============================================================================
class RS_ComboTable play
{
	static void Add(RS_ScoreRegistry reg)
	{
		// ---- the fists (RSQ Melee): punches, the uppercut that launches, the Headlock ----
		reg.OwnCombo("Trap Shooter",       "glove.upper > gun.shotgun",                 0.5);
		reg.OwnCombo("Rising Dragon",      "glove.upper > saber.cut",                   0.5);
		reg.OwnCombo("Spike",              "glove.upper > shield.disc",                 0.5);
		reg.OwnCombo("Air Lash",           "glove.upper > whip.crack",                  0.5);
		reg.OwnCombo("Alley-Oop",          "glove.upper > grab.throw",                  0.5);
		reg.OwnCombo("Air Mail",           "glove.upper > grenade",                     0.5);
		reg.OwnCombo("Fireworks",          "glove.upper > gun.explosive",               0.5);
		reg.OwnCombo("One-Two-Skeet",      "glove > glove.upper > gun.shotgun",         0.9);
		reg.OwnCombo("Cross Cut",          "glove.hook > saber.cut",                    0.4);
		reg.OwnCombo("Fist and Shield",    "glove > shield.bash",                       0.4);
		reg.OwnCombo("Knuckle Crack",      "glove > whip.crack",                        0.4);
		reg.OwnCombo("Jedi Jab",           "glove > force.push",                        0.4);
		reg.OwnCombo("Punch and Pitch",    "glove > shield.disc",                       0.4);
		reg.OwnCombo("Slow Trap Shooter",  "glove.upper@slow > gun.shotgun",            0.55);
		reg.OwnCombo("Feint",              "glove.jab > saber.stab",                    0.45);
		reg.OwnCombo("Skyskewer",          "glove.upper > saber.stab",                  0.55);
		// the gun-butt shove (Melee's, BD22 VR's butt strike, the pistol whip: one tool)
		reg.OwnCombo("Pistol Whip",        "shove > gun.pistol",                        0.5);
		// no "shove > gun.shotgun" row without the slow motion: that is F.E.A.R. Effect's move (the owner, 11-03), and a twin name confuses it
		reg.OwnCombo("Executioner",        "shove > gun+head",                          0.6);
		reg.OwnCombo("Riot Shield",        "shove > shield.bash",                       0.5);
		reg.OwnCombo("Make Room",          "shove > saber.cut",                         0.4);
		reg.OwnCombo("Fire in the Hole",   "shove > grenade",                           0.45);
		reg.OwnCombo("Backlash",           "shove > whip.crack",                        0.4);
		// a missile sent back by hand (Hadouken, Swat Back), the Guard
		reg.OwnCombo("Street Fighter",     "hadouken > glove.upper",                    0.6);
		reg.OwnCombo("Shoto",              "hadouken > saber.cut",                      0.5);
		reg.OwnCombo("Return Fire",        "hadouken > shove > gun.shotgun",            1.0);
		reg.OwnCombo("Neo",                "hadouken@slow > glove",                     0.6);
		reg.OwnCombo("Backhand Spring",    "swat > glove.upper > gun.pistol",           1.0);
		reg.OwnCombo("Parry Punish",       "guard.parry > any",                         0.5);
		reg.OwnCombo("Counter Cut",        "guard.parry > saber",                       0.6);
		reg.OwnCombo("Knuckle Sandwich",   "guard.parry > glove",                       0.55);
		reg.OwnCombo("Dragon Fist",        "guard.parry > glove.upper > glove",         0.9);
		reg.OwnCombo("Pressure Valve",     "guard.release > glove",                     0.5);
		// the Headlock (the off hand holds it: grab.hold), and what comes out of it
		reg.OwnCombo("Hostage",            "grab.hold > gun.pistol",                    0.5);
		reg.OwnCombo("Close Quarters",     "grab.hold > gun.shotgun",                   0.5);
		reg.OwnCombo("Hold This",          "grab.hold > grenade",                       0.6);
		reg.OwnCombo("Execution",          "grab.hold > saber",                         0.5);
		reg.OwnCombo("Suplex",             "grab.hold > headlock.throw",                0.5);
		reg.OwnCombo("Flog",               "grab.hold > whip.crack",                    0.5);
		reg.OwnCombo("Title Belt",         "grab.hold > hands | champ",                 0.6);
		reg.OwnCombo("Bouncer",            "grab.hold > hands > gun.shotgun",           0.9);
		reg.OwnCombo("Choke and Cut",      "grab.hold > headlock.choke > saber.cut",    0.9);
		reg.OwnCombo("Slam and Blam",      "grab.hold > headlock.slam > gun.shotgun",   0.9);
		reg.OwnCombo("Clay Toss",          "headlock.throw > gun.shotgun",              0.5);
		reg.OwnCombo("Ground and Pound",   "headlock.slam > glove",                     0.5);
		reg.OwnCombo("Pin Down",           "headlock.slam > saber.stab",                0.55);
		// the taunt, the two-fist pound, the clear-out
		reg.OwnCombo("Come Get Some",      "taunt > hands",                             0.4);
		reg.OwnCombo("Come Closer",        "taunt > gun.shotgun",                       0.5);
		reg.OwnCombo("Tremor",             "pound > gun.shotgun",                       0.45);
		reg.OwnCombo("Quake",              "pound > shield.bash",                       0.4);
		reg.OwnCombo("Get Back!",          "clearout > grenade",                        0.5);
		reg.OwnCombo("Spread Out",         "clearout > gun.explosive",                  0.45);

		// ---- the saber and the Force (RSQ Saber) ----
		reg.OwnCombo("Laser Sword",        "saber.cut > gun.energy",                    0.5);
		reg.OwnCombo("Blade and Buckshot", "saber.cut > gun.shotgun",                   0.45);
		reg.OwnCombo("Edge and Board",     "saber.cut > shield.bash",                   0.4);
		reg.OwnCombo("Pommel",             "saber.cut > glove",                         0.4);
		reg.OwnCombo("Slash and Blast",    "saber.cut > force.push > gun.shotgun",      0.9);
		reg.OwnCombo("Distraction",        "saber.throw > glove",                       0.5);
		reg.OwnCombo("Covering Fire",      "saber.throw > gun.rifle",                   0.45);
		reg.OwnCombo("Air Traffic",        "saber.throw > shield.disc",                 0.5);
		reg.OwnCombo("Throw and Go",       "saber.throw > saber.cut",                   0.4);
		reg.OwnCombo("Return Flight",      "saber.throw > force.pull > saber.cut",      0.9);
		reg.OwnCombo("Helpless",           "force.grip > saber.cut",                    0.5);
		reg.OwnCombo("Hung Out to Dry",    "force.grip > glove",                        0.5);
		reg.OwnCombo("Special Delivery",   "force.grip > grenade",                      0.5);
		reg.OwnCombo("Pinned",             "force.grip > shield.disc",                  0.5);
		reg.OwnCombo("Strung Up",          "force.grip > whip.crack",                   0.5);
		reg.OwnCombo("Exorcism",           "force.grip > saber.cut | Ghost",            0.6);
		reg.OwnCombo("Jedi Brawler",       "force.grip > glove > saber.cut",            0.9);
		reg.OwnCombo("Superhero Landing",  "force.jump > glove",                        0.5);
		reg.OwnCombo("Leap Strike",        "force.jump > saber.cut",                    0.5);
		reg.OwnCombo("Come Here, Go Up",   "force.pull > glove.upper > gun.shotgun",    0.9);
		reg.OwnCombo("Force Arrest",       "force.pull > grab.hold > glove",            0.9);
		reg.OwnCombo("Jedi Hoplite",       "force.pull > shield.bash > saber.cut",      0.9);
		reg.OwnCombo("Clay Saber",         "force.push > saber.throw",                  0.5);
		reg.OwnCombo("Hot Seat",           "force.push > grab.keg",                     0.5);
		reg.OwnCombo("Scoundrel",          "force.push > saber.throw > gun.pistol",     0.9);
		reg.OwnCombo("Push-Pull",          "force.push > force.pull > saber.cut",       0.9);
		reg.OwnCombo("Time Slash",         "force.push@slow > saber.cut",               0.55);
		reg.OwnCombo("Off the Blade",      "saber.stab > force.push",                   0.5);
		reg.OwnCombo("Stab and Jab",       "saber.stab > glove",                        0.4);
		reg.OwnCombo("Shock and Awe",      "force.lightning > glove",                   0.5);
		reg.OwnCombo("Sith Ambush",        "force.lightning > saber.cut",               0.5);
		reg.OwnCombo("Overcharge",         "force.lightning > gun.energy",              0.5);

		// ---- the ShieldSaw ----
		reg.OwnCombo("Riot Control",       "shield.bash > gun.shotgun",                 0.5);
		reg.OwnCombo("Bash and Slash",     "shield.bash > saber.cut",                   0.5);
		reg.OwnCombo("Bash and Lash",      "shield.bash > whip.crack",                  0.4);
		reg.OwnCombo("Shield and Fist",    "shield.bash > glove",                       0.4);
		reg.OwnCombo("Crack the Shell",    "shield.bash > blade | armoured",            0.55);
		reg.OwnCombo("Bash and Launch",    "shield.bash > glove.upper > gun.shotgun",   0.9);
		reg.OwnCombo("Shield Up",          "shield.block > grenade",                    0.5);
		reg.OwnCombo("This Is Sparta",     "shield.block > shield.bash > saber",        0.9);
		reg.OwnCombo("Riot Squad",         "shield.block > shield.bash > gun.shotgun",  0.9);
		reg.OwnCombo("Shield Uppercut",    "shield.block > shield.bash > glove.upper",  1.0);
		reg.OwnCombo("Slow Sparta",        "shield.block@slow > shield.bash > saber.cut", 1.0);
		reg.OwnCombo("Saw and Saber",      "shield.disc > saber.cut",                   0.5);
		reg.OwnCombo("Crossfire",          "shield.disc > saber.throw",                 0.5);
		reg.OwnCombo("Follow-Through",     "shield.disc > glove",                       0.4);
		reg.OwnCombo("Throw and Follow",   "shield.disc > shield.bash",                 0.4);
		reg.OwnCombo("Cleanup Crack",      "shield.disc > whip.crack",                  0.4);
		reg.OwnCombo("Sawblade Send-Off",  "shield.grind > force.push > shield.disc",   0.9);
		reg.OwnCombo("Hoplite",            "shield.bash > saber.stab",                  0.55);
		reg.OwnCombo("Nailed",             "shield.slam > saber.stab",                  0.55);
		reg.OwnCombo("Up Against the Wall", "shield.slam > glove",                      0.5);

		// ---- the whip (RSQ Whip): whip.crack is its Wide Swing; `whip` is either of its two moves ----
		reg.OwnCombo("Frontier",           "whip.crack > gun.pistol",                   0.5);
		reg.OwnCombo("High Noon",          "whip.crack > rig.draw",                     0.6);
		reg.OwnCombo("Zorro",              "whip.crack > saber",                        0.5);
		reg.OwnCombo("Big Top",            "whip.crack > shield.disc",                  0.55);
		reg.OwnCombo("Crack and Smack",    "whip.crack > glove",                        0.4);
		reg.OwnCombo("Crack of Doom",      "whip.crack > any | legend.dormant",         0.6);
		reg.OwnCombo("Bullet Ballet",      "whip.crack@slow > gun",                     0.9);

		// (the hook's rows were here until 2026-11-27: 21 of them, and 13 more with a hook step elsewhere in this file)

		// ---- Distance Grab: thrown things, a barrel's blast ----
		reg.OwnCombo("Catch This",         "grab.throw > glove",                        0.45);
		reg.OwnCombo("Batter Up",          "grab.throw > gun",                          0.35);
		reg.OwnCombo("Serve and Volley",   "grab.throw > shield.bash",                  0.45);
		reg.OwnCombo("Two Throws",         "grab.throw > shield.disc",                  0.45);
		reg.OwnCombo("Toss and Crack",     "grab.throw > whip.crack",                   0.45);
		reg.OwnCombo("Kitchen Sink",       "grab.throw > grenade > gun",                1.0);
		reg.OwnCombo("Aftershock",         "grab.keg > melee",                          0.5);

		// ---- the grenade (RSQ Grenade, BD22 VR's): the frag and the kinds ----
		reg.OwnCombo("Into the Breach",    "grenade > melee",                           0.45);
		reg.OwnCombo("Mop Up",             "grenade > gun",                             0.3);
		reg.OwnCombo("Shell Shock",        "grenade > glove",                           0.5);
		reg.OwnCombo("Frag and Slash",     "grenade > saber.cut",                       0.5);
		reg.OwnCombo("Demolition",         "grenade > grab.keg > gun",                  1.0);
		reg.OwnCombo("Ice Breaker",        "grenade.freeze > glove",                    0.55);
		reg.OwnCombo("Cold Cut",           "grenade.freeze > saber.cut",                0.55);
		reg.OwnCombo("Cold Shoulder",      "grenade.freeze > shield.bash",              0.55);
		reg.OwnCombo("Ice Pop",            "grenade.freeze > glove.upper > gun.shotgun", 1.0);
		reg.OwnCombo("Dazed and Confused", "grenade.stun > glove",                      0.55);
		reg.OwnCombo("Stun and Gun",       "grenade.stun > gun",                        0.45);
		reg.OwnCombo("Dizzy Finish",       "grenade.stun > glove > fatality",           1.0);
		reg.OwnCombo("Lights Out",         "grenade.flash > melee",                     0.5);
		reg.OwnCombo("Blind Side",         "grenade.flash > saber",                     0.55);
		reg.OwnCombo("Out of the Smoke",   "grenade.smoke > melee",                     0.5);
		reg.OwnCombo("Ninja",              "grenade.smoke > saber.stab",                0.55);
		reg.OwnCombo("Batting Practice",   "grab.swing > gun",                          0.4);
		reg.OwnCombo("Ghost Hold",         "grenade.smoke > grab.hold > blade",         1.0);
		reg.OwnCombo("Pin Cushion",        "grenade.sticky > gun",                      0.45);
		reg.OwnCombo("Return to the Pack", "grenade.sticky > force.push > grenade",     0.9);
		reg.OwnCombo("Hot Lash",           "grenade.fire > whip.crack",                 0.5);
		reg.OwnCombo("Fan the Flames",     "grenade.fire > force.push > gun.fire",      0.9);

		// ---- the guns open it (BD22 VR's classes; plain Doom's guns read as the same classes) ----
		reg.OwnCombo("Rocket Punch",       "gun.explosive > glove",                     0.5);
		reg.OwnCombo("Over-Under",         "gun.explosive > gun.rifle",                 0.4);
		reg.OwnCombo("Mop-Up Saw",         "gun.explosive > blade.saw",                 0.5);
		reg.OwnCombo("Hot Hands",          "gun.fire > glove",                          0.5);
		reg.OwnCombo("Fire Whip",          "gun.fire > whip.crack",                     0.45);
		reg.OwnCombo("Plasma Blade",       "gun.energy > saber.cut",                    0.45);
		reg.OwnCombo("Shoot and Snap",     "gun.pistol > whip.crack",                   0.4);
		reg.OwnCombo("Buckshot Brawl",     "gun.shotgun > glove",                       0.4);
		reg.OwnCombo("Clean Up",           "gun.shotgun > saber.cut",                   0.4);
		reg.OwnCombo("Suppress and Storm", "gun.rifle > shield.bash",                   0.45);
		reg.OwnCombo("Rip and Pump",       "blade.saw > gun.shotgun",                   0.4);
		reg.OwnCombo("Door Kick",          "kick > gun.shotgun+pb",                     0.5);

		// ---- the rig, slow motion's dodge, a shot sent back again ----
		reg.OwnCombo("Showdown",           "rig.draw@slow > gun",                       0.9);
		reg.OwnCombo("Draw and Shove Off", "rig.draw > force.push > gun.pistol",        0.9);
		reg.OwnCombo("Tuco",               "throw.gun > rig.draw",                      0.5);
		reg.OwnCombo("Slip and Shoot",     "lean > gun",                                0.4);
		reg.OwnCombo("Bob and Weave",      "lean > hands",                              0.5);
		reg.OwnCombo("Tennis",             "return > return",                           0.5);
		reg.OwnCombo("Volley",             "return > return > return",                  1.0);
		reg.OwnCombo("Kingslayer",         "any@slow > any | miniboss",                 0.5);
	}
}
