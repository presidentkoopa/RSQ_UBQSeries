#!/usr/bin/env python3
"""gen_glossary.py -- writes Score/zscript/rsscore/glossary_data.zs, the Glossary's entries (glossary.zs).

    python3 Score/tools/gen_glossary.py          (from the repo root; or from anywhere: paths are its own)
    python3 Score/tools/gen_glossary.py --check  also prints every entry, for reading through

SOURCES, so a change is made once, in the place it belongs:
  * tools/glossary_source.md's bonus lists (the "N bonuses" groups: 206 on 2026-11-27): each row's name, family,
    what earns it and its pay (xN). Until 2026-11-27 these lists were read out of Score/README.md; the README is
    written from the code now and has no such lists, so the two regions this script reads were saved as that file
    (from git 927ddbc7f~1) and are edited there. "README" below means that file.
  * combos.zs and combo.zs (reg.OwnCombo): every named combo's name and pay, straight from the code; the source
    file's "All N named combos" list (171 on 2026-11-27) gives each one's steps in words (matched by name).
  * The code's bonus classes: every row name in the source file must be a string the code shows (DisplayName/RowName
    or a table's label), and a row's first pay must be one of its class's own numbers; the script says where not.
  * The OVERRIDES below: the few rows whose source text does not read as a plain sentence, the monster a value is
    shown on when an imp never qualifies, and what each row needs when the words do not say it.

VALUES: never a bare percent. A pay of xN is shown as the points it adds on a familiar monster, worked out the way
the handler does (int(round(base * N)), handler.zs PayRows; base = the monster's spawn health): an imp, 60.

WORDS (owner): no casino words (Pays, Earned, Payout, Jackpot); "Bonus", "Needs". The font has capitals only and
ASCII 32-96, so the text is kept to that.
"""
import os, re, sys, math, glob

HERE = os.path.dirname(os.path.abspath(__file__))
SCORE = os.path.dirname(HERE)
README = os.path.join(HERE, 'glossary_source.md')   # 2026-11-27: was Score/README.md (see SOURCES above)
ZS = os.path.join(SCORE, 'zscript', 'rsscore')
OUT = os.path.join(ZS, 'glossary_data.zs')

FAMS = ['Efficiency', 'Style', 'Daring', 'Melee', 'Counterplay', 'Combos']

MONSTERS = {'imp': 60, 'Baron of Hell': 1000, 'Cyberdemon': 4000, 'Mancubus': 600}


def art(word):
    return 'Kill an' if word[0] in 'AEIOU' else 'Kill a'


def pts(mult, base=60):
    return int(math.floor(base * mult + 0.5))   # C round(), half away from zero (all values here are positive)


# ------------------------------------------------------------------------------------------------ overrides
# name -> dict(text=, bonus=, needs=, monster=, family=)
# text: what earns it (replaces README's words); bonus: the Bonus line, with {N} = points for xN on the monster
# (e.g. {0.3}); needs: the mod(s); monster: the monster the value is shown on.
O = {
    # the classics
    'Spree': dict(text='Kill again and again, fast. Each kill gives you 2 to 10 seconds to make the next one.',
                  bonus='+{0.025} on an imp for each kill in the run, up to +{0.25}'),
    'Untouchable': dict(text='Kill without taking damage. It starts after a tenth of the map is down without a scratch, then grows.',
                        bonus='up to +{0.5} on an imp'),
    'Infighter': dict(text='A monster kills another monster. Every player gets it.'),
    'Switcharoo': dict(text='Kill with a different gun from the one you just fired. Two triggers on the same gun count for less.',
                       bonus='+{0.15} on an imp for two guns, +{0.075} for two triggers'),
    'Air': dict(text='Kill while you are off the ground. The higher the jump, the bigger the bonus.',
                bonus='+{0.5} on an imp from 164 units up, up to +{2.0}'),
    'Curveball': dict(text='Kill a monster that cannot see you: round a corner, over a ledge, through a door.'),
    'Darwin': dict(text='A monster kills itself. You did not do it, you set it up. Every player gets it.'),
    'Telefragged': dict(text='Kill a monster by teleporting into it.'),
    'Coach Gun': dict(text='Kill with a Super Shotgun blast.', needs="Brutal Doom's Super Shotgun"),
    'Brawler': dict(text='Kill with your fists or a blade.',
                    bonus='+{0.5} on an imp with fists, a saw or an axe; some weapons less'),
    'Redline': dict(text='Kill while your health is 25 or less. The lower your health, the bigger the bonus.',
                    bonus='+{0.02} on an imp at 25 health, up to +{0.5} at 1'),
    'Swan Song': dict(text='A kill that lands after you have died, like a rocket still in the air. It takes the place of Redline.'),
    'Point-Blank': dict(text='Kill a monster right up close, almost touching it.'),
    # melee
    'Cleaved': dict(text='A melee kill that takes the body apart.', needs='a melee mod'),
    'Fatality': dict(text="Brutal Doom's execution move.", needs='Brutal Doom'),
    'Hurled': dict(text='Kill with a thrown ShieldSaw or saber. Each more kill by the same throw is worth more.',
                   bonus='+{0.3} on an imp, +{0.15} more each, up to +{0.75}', needs='RSQ ShieldSaw or RSQ Saber'),
    'Shield Work': dict(text="Kill with the shield's bash, or its revved grind.",
                        bonus='+{0.3} on an imp for the bash, +{0.2} for the grind', needs='RSQ ShieldSaw'),
    'Riposte': dict(text='Block its attack with your shield or saber, then kill it within 3 seconds.',
                    needs='RSQ ShieldSaw or RSQ Saber'),
    'Perfect Riposte': dict(text='The same as Riposte, after a perfect block. It takes the place of Riposte.',
                            needs='RSQ ShieldSaw or RSQ Saber'),
    'Return to Sender': dict(text='A shot you sent back kills it.',
                             bonus='+{0.4} on an imp; a Hadouken or Swat Back +{0.6}; the Guard +{0.5}',
                             needs='a mod that sends shots back: RSQ Saber, RSQ ShieldSaw or RSQ Melee'),
    'Combo': dict(text='Kill with different melee moves within 4 seconds.',
                  bonus='+{0.1} on an imp for each move past the first, up to +{0.4}', needs='a melee mod'),
    'Poetic Justice': dict(text='A shot you sent back kills the monster that fired it.',
                           needs='a mod that sends shots back: RSQ Saber, RSQ ShieldSaw, RSQ Melee or RSQ Whip'),
    'Boomerang': dict(text='A throw that killed on its way out kills again on its way home.', needs='RSQ ShieldSaw or RSQ Saber'),
    'Ground Down': dict(text='Your thrown disc sticks in a tough monster and grinds it to death.', needs='RSQ ShieldSaw'),
    'Heavy Swing': dict(text="Brutal Doom VR's hard swing: the second or third blow of the swing kills.",
                        bonus='+{0.15} on an imp on the second blow, +{0.3} on the third', needs='Brutal Doom VR'),
    'Choked': dict(text="Kill with the Force grip's choke, or RSQ Melee's Chokehold.", needs='RSQ Saber or RSQ Melee'),
    'Slammed': dict(text='A body flung from your Force grip dies hitting something.', needs='RSQ Saber'),
    'Juggle': dict(text='A melee kill on a monster you put in the air in the last 2 seconds.', needs='a melee mod'),
    'Boot': dict(text="Brutal Doom's kick, head kick or stomp.", needs='Brutal Doom'),
    'Pulled In': dict(text='Your Force pull brings it, then a melee blow finishes it within 2 seconds.', needs='RSQ Saber'),
    'Twin Blades': dict(text='A saber kill with a lit saber in each hand.', needs='RSQ Saber'),
    'Rally': dict(text='Shots you send back kill one after another, each within 3 seconds.',
                  bonus='+{0.2} on an imp for the second, +{0.4} for the third, then +{0.6}',
                  needs='a mod that sends shots back: RSQ Saber, RSQ ShieldSaw, RSQ Melee or RSQ Whip'),
    'Ring Out': dict(text='The level or another monster finishes off a monster you sent there.'),
    'Ground Pound': dict(text="The Force jump's landing, or RSQ Melee's two-fist pound. It takes the place of Slammed.",
                         needs='RSQ Saber or RSQ Melee'),
    'Clean Sweep': dict(text='Your ShieldSaw, thrown at two or more marked monsters, kills the last of them.', needs='RSQ ShieldSaw'),
    'Bank Shot': dict(text='Your disc comes off a wall onto a new target and kills it.', needs='RSQ ShieldSaw'),
    'Shield Wall': dict(text="Kill while your shield blocked another monster's attack in the last second.", needs='RSQ ShieldSaw'),
    'Counter': dict(text='A melee blow kills it in the middle of its attack.', needs='a melee mod'),
    'Knockdown': dict(text='A punch finishes it while it reels.', needs='RSQ Melee'),
    'Flurry': dict(text='A run of glove punches, left and right, each within half a second.',
                   bonus='+{0.15} on an imp on the third, +{0.3} on the fourth, then +{0.45}', needs='RSQ Melee'),
    # shots, throws, the rig, slow motion
    'Thrown': dict(text='Kill with something you threw with Distance Grab. The faster the throw, the bigger the bonus.',
                   bonus='+{0.2} on an imp, up to +{0.5}', needs='RSQ Distance Grab'),
    'Powder Keg': dict(text='The blast of a barrel your throw set off. Each more kill within a second is worth more.',
                       bonus='+{0.3} on an imp, +{0.2} more each, up to +{1.1}', needs='RSQ Distance Grab'),
    'Air Catch': dict(text='Catch a thrown thing back out of the air and throw it again for the kill.',
                      bonus='+{1.0} on an imp, +{0.5} more a catch, up to +{2.0}', needs='RSQ Distance Grab'),
    'Skeet': dict(text='Kill a monster while it is in the air (not one that flies).'),
    'Quick Draw': dict(text='Kill with the gun you just drew from a holster, within 1.2 seconds.', needs='RSQ Tactical Rig'),
    'No-Look': dict(text='Your shot leaves more than 60 degrees away from where your head faces.'),
    'Blind-fire': dict(text="Your eyes could not see it, but your hand's shot could. It takes the place of No-Look."),
    'Off-hand': dict(text="Your off hand's trigger fires the kill."),
    'Full Hands': dict(text='A shot kill while a hand carries something with Distance Grab.', needs='RSQ Distance Grab'),
    'Body Blow': dict(text='A corpse you threw kills it.', needs='RSQ Distance Grab'),
    'Hand-Me-Down': dict(text='Kill by throwing a gun a dead monster dropped.', needs='RSQ Distance Grab'),
    'Hot Swap': dict(text='In the middle of a fight, draw a different gun from a holster and kill with it.', needs='RSQ Tactical Rig'),
    'Stretched Second': dict(text="Kill while RSQ SlowMo has the world slowed. It adds half of what the kill's other bonuses gave (not Efficiency).",
                             bonus="half of the kill's other bonuses; more at very slow speed", needs='RSQ SlowMo'),
    'Two Guns': dict(text='A shot kill from one hand within a second of one from the other.'),
    # the hook and the whip (2026-11-27: today's Grapple and Whip; the rope's rows are gone)
    'Bowling': dict(text='A monster you threw out of the Headlock hits it.', needs='RSQ Melee'),
    'Kick': dict(text='Hook a monster and you fly to it. Your arrival is the kick. The kick kills it.', needs='RSQ Grapple'),
    'Air Spike': dict(text='In the air, swing both hands down to spike the monster you hooked. The explosion where it lands kills it.',
                      needs='RSQ Grapple and RSQ Grenade'),
    'Lashed': dict(text="Kill with the whip's Wide Swing.", needs='RSQ Whip'),
    'Wide Swing': dict(text='Kill two or more with one Wide Swing of the whip. It takes the place of Multi-Kill.',
                       bonus='+{0.3} on an imp for each kill before this one, up to +{0.9}', needs='RSQ Whip'),
    'Ground Crack': dict(text='Crack the whip down at the ground to throw monsters into the air. Kill one before it lands. It takes the place of Juggle and Skeet.',
                         needs='RSQ Whip'),
    'Variety': dict(text='Use three or more of your tools in one fight, with kills within 10 seconds of each other.',
                    bonus='+{0.15} on an imp for each tool past two, up to +{0.6}'),
    # the fists
    'Shoryuken': dict(text='Kill with an uppercut.'),
    'Liver Shot': dict(text='Kill with a punch below the chest.'),
    'Glass Jaw': dict(text='Kill with a punch to the head.'),
    'Textbook': dict(text='Jab, jab, hook, inside one second.'),
    'Triple Threat': dict(text='Jab, hook, uppercut, inside one second. It takes the place of Shoryuken and Textbook.'),
    'Dempsey Roll': dict(text='A run of hooks, left and right in turn.',
                         bonus='+{0.15} on an imp for each hook past two, up to +{0.6}'),
    'Air Combo': dict(text='A punch on a monster your uppercut launched. It takes the place of Juggle and Skeet.'),
    'Bouncer': dict(text='Kill with the Clear Out palm thrust.'),
    'Release': dict(text="Kill by letting out the Guard's stored charge."),
    'Toss': dict(text='A monster thrown out of the Headlock dies when it lands.'),
    'Piledriver': dict(text='Kill with the Headlock Slam.'),
    'Cut Loose': dict(text='Kill with the Headlock Uppercut.'),
    'Butt Stroke': dict(text='Kill with the gun-butt shove itself.'),
    # shared melee
    'Weapon Master': dict(text='A run of kills with one melee mod (fists, saber, ShieldSaw, whip), each within 10 seconds.',
                          bonus='+{0.1} on an imp for each kill past two, up to +{0.5}', needs='a melee mod'),
    'Giant Slayer': dict(text='A melee kill of a monster of 400 health or more. Twice as much from 2,000 health.',
                         monster='Baron of Hell', bonus='+{0.5} on a Baron of Hell; +{1.0@4000} on a Cyberdemon',
                         needs='nothing extra'),
    'Death from Above': dict(text="A melee kill as you fall onto it from a metre above its head.", needs='nothing extra'),
    'Juggler': dict(text='Kill while your thrown saber or disc is still in the air.', needs='RSQ Saber or RSQ ShieldSaw'),
    'Misdirection': dict(text="A shot you sent back kills a monster that did not fire it.",
                         needs='a mod that sends shots back: RSQ Saber, RSQ ShieldSaw, RSQ Melee or RSQ Whip'),
    'Multi-Kill': dict(text='One blow, blast or swing kills more than one. Each kill past the first adds more, by weapon.',
                       bonus='+{0.3} on an imp a kill with a shotgun, +{0.2} a grenade, +{0.15} most guns; up to +{0.75}'),
    # saber, ShieldSaw, whip, hook
    'Lunge': dict(text='A stab driven by your whole body.', needs='RSQ Saber'),
    'Impaled': dict(text='Draw your blade out of an impaled monster.', needs='RSQ Saber'),
    'Back Off': dict(text='Your crossed blades turn the shot that kills. It takes the place of Return to Sender.', needs='RSQ Saber'),
    'Double Throw': dict(text='Throw both sabers, each killing within a second of the other.', needs='RSQ Saber'),
    'Shield Dash': dict(text='The bash at the end of a Shield Dash.', needs='RSQ ShieldSaw'),
    'Bit Off More': dict(text='It grinds to death on your revving shield while clawing at it.', needs='RSQ ShieldSaw'),
    'Homecoming': dict(text='Your disc or saber kills only on its way home.', needs='RSQ ShieldSaw or RSQ Saber'),
    'Eyes in the Back': dict(text='The shield mounted on your shoulder blocks it, then you kill it.', needs='RSQ ShieldSaw'),
    'Hold the Line': dict(text='Shield Wall against two or more monsters in the last 2 seconds. It takes the place of Shield Wall.',
                          bonus='+{0.25} on an imp, +{0.1} more a monster, up to +{0.55}', needs='RSQ ShieldSaw'),
    'Cleaver': dict(text='Your disc cuts it in two with the Cleaver upgrade.', needs='RSQ ShieldSaw'),
    # Distance Grab, the rig, the grenade
    'Heavy Throw': dict(text='Kill with a thrown thing of 100 kg or more.', needs='RSQ Distance Grab'),
    'Throwaway': dict(text='Kill with a gun you threw. More if it was empty.',
                      bonus='+{0.3} on an imp, +{0.5} if it was empty', needs='RSQ Distance Grab'),
    'Iaido': dict(text='Draw the saber from its spot and kill straight away.', needs='RSQ Saber and RSQ Tactical Rig'),
    'Pin Pulled': dict(text='Draw the grenade from your belt buckle and kill within 3 seconds.', needs='RSQ Grenade and RSQ Tactical Rig'),
    'Armory': dict(text='Three different guns, each drawn from a holster and each killing, inside 6 seconds.', needs='RSQ Tactical Rig'),
    'Cooked': dict(text='Kill with a grenade you held in your hand for a second or more.',
                   bonus='+{0.2} on an imp, +{0.1} more each half second, up to +{0.6}'),
    'Airburst': dict(text='Your grenade goes off in the air.'),
    'Tagged': dict(text='A Sticky grenade kills the monster it rides.', needs='RSQ Grenade'),
    'Hold My Beer': dict(text='A grenade that went off in your hand kills it. More if you live.',
                         bonus='+{0.5} on an imp, +{0.8} if you live'),
    'Cluster Bomb': dict(text='Kill with a Cluster bomblet.', needs='RSQ Grenade'),
    'Civil War': dict(text='A monster your Infight or Charm grenade turned makes the kill.', needs='RSQ Grenade'),
    'Blindside': dict(text='Kill while your Flash or Smoke grenade has it blind.', needs='RSQ Grenade'),
    'Barbecue': dict(text="Your Incendiary grenade's fire finishes it.", needs='RSQ Grenade'),
    # the guns
    'Hold Streak': dict(text='Kills while one trigger stays down.',
                        bonus='+{0.15} on an imp for each kill past two, up to +{0.6}'),
    'Double Tap': dict(text='Two pistol hits within a third of a second; the second kills.'),
    'Hand Cannon': dict(text='One revolver round from full health to dead.',
                        bonus="+{0.25} on an imp with Brutal Doom VR's revolver; +{0.3} with the other revolver",
                        needs="Brutal Doom VR's revolver"),
    'Headshot': dict(text='The killing blow is a head shot. More with the sniper rifle or the revolver.',
                     bonus='+{0.25} on an imp; +{0.4} with the sniper rifle or the revolver'),
    'Sights Up': dict(text='A gun kill from far away, aimed down the gun.',
                      bonus='+{0.2} on an imp'),
    'Glass': dict(text='A sniper rifle or railgun kill from very far away, aimed down the gun.', family='Daring',
                  bonus='+{0.4} on an imp; +{0.6} from twice as far'),
    'Direct Hit': dict(text="A rocket's direct hit, not its splash."),
    'Danger Close': dict(text='A nuke kill with you close by, and alive.', needs="Brutal Doom's nuke"),
    'Unmade': dict(text='An Unmaker kill of a monster of 1,000 health or more.', monster='Baron of Hell',
                   needs="Brutal Doom's Unmaker"),
    'Rip and Tear': dict(text='A chainsaw kill of a monster of 400 health or more.', monster='Baron of Hell',
                         bonus='+{0.5} on a Baron of Hell'),
    'Tomahawk': dict(text='Kill with a thrown axe.', needs="Brutal Doom VR's axe"),
    # champions, LegenDoom, Miniboss
    'Immovable Object': dict(text='A melee kill of a Bronze champion.', needs='Champions'),
    'Pop!': dict(text='Kill a Balloon champion with anything but a gun.', needs='Champions'),
    'Pinata': dict(text='Gib a champion.', needs='Champions'),
    'Champion Streak': dict(text='Champion kills, each within 5 seconds.',
                            bonus='+{0.1} on an imp for each, up to +{0.5}', needs='Champions'),
    'Too Close for Comfort': dict(text='Kill an Orange champion in melee or point-blank.', needs='Champions'),
    'Glass Cannon': dict(text='Kill a Black champion in one blow from full health.', needs='Champions'),
    "Fool's Gold": dict(text='Kill a monster a Gold champion gilded.', needs='Champions'),
    'Heartbreaker': dict(text='Kill an Undying champion within 2 seconds of its heart.', needs='Champions'),
    'Champion Fatality': dict(text="Brutal Doom's Fatality on a champion.", needs='Champions and Brutal Doom'),
    'Rainbow': dict(text='Kill champions of 5, 10 and all 14 colours in one map. Each step is given once.',
                    bonus='+{0.5} on an imp at 5 colours, +{1.0} at 10, +{2.0} at all 14', needs='Champions'),
    'One-Tap Legend': dict(text='Kill a legendary from full health in one blow. It takes the place of Legend Denied.', needs='LegenDoom'),
    'Strike While It Rises': dict(text='Kill a legendary within 2 seconds of it rising.', needs='LegenDoom'),
    'Legend Slayer': dict(text='Kill two legendaries within 10 seconds.', needs='LegenDoom'),
    'Chain Gang': dict(text='Kill thralls one after another, each within 12 seconds of the last.',
                       bonus='+{0.4} on an imp for the second, +{0.8} for the third, then +{1.0}', needs='RSQ Miniboss'),
    'Riot Control': dict(text='Kill an enraged monster.', needs='RSQ Miniboss'),
    # second round
    'Run Through': dict(text='Kill with a saber stab.', needs='RSQ Saber'),
    'Unlimited Power': dict(text='Kill with Force Lightning.', needs='RSQ Saber'),
    'Clash Break': dict(text='Your blade-lock shockwave staggers it; kill it within 3 seconds.', needs='RSQ Saber'),
    'Buzzsaw': dict(text='Grind it to death for 1.5 seconds or more. It takes the place of Shield Work.', needs='RSQ ShieldSaw'),
    'Wall Splat': dict(text='Knock it into a wall, and the wall kills it.', needs='a melee mod'),
    'Clubbed': dict(text='Swing a thing you hold into it. More with a corpse.',
                    bonus='+{0.3} on an imp, +{0.1} more a corpse', needs='RSQ Distance Grab'),
    'Trap Shot': dict(text='Shoot your own grenade in the air.'),
    'Teeth': dict(text='Kill with a grenade you pulled the pin of with your teeth.', needs='RSQ Grenade'),
    'Contact': dict(text='An Impact grenade bursts on it.', needs='RSQ Grenade'),
    'Last Grain': dict(text='Kill as the world speeds back up at the end of a slow motion.', needs='RSQ SlowMo'),
    # RSQ Melee second round
    'Swatted': dict(text='A missile your open palm knocked aside kills something. It takes the place of Return to Sender.'),
    'Rope-a-Dope': dict(text='Your Guard soaks its blow and you kill it within 3 seconds. More with your hands or a hand weapon.',
                        bonus='+{0.4} on an imp; +{0.6} with your hands'),
    'Seismic': dict(text='One Ground Pound kills two or more. It takes the place of Multi-Kill.',
                    bonus='+{0.3} on an imp for each kill past the first, up to +{0.9}'),
    'Out of My Way': dict(text='One Clear Out kills two or more.',
                          bonus='+{0.3} on an imp for each kill past the first, up to +{0.9}'),
    'Full Release': dict(text='One Guard release kills two or more.',
                         bonus='+{0.3} on an imp for each kill past the first, up to +{0.9}'),
    'Meat Shield': dict(text='The monster in your Headlock dies of what another monster threw at you. It takes the place of Ring Out.'),
    'Human Shield': dict(text='Kill while your off hand holds a monster as a shield.'),
    'Field Goal': dict(text='The blast of a barrel your uppercut kicked.'),
    'Seeing Stars': dict(text='A Heavy Hands punch freezes it; kill it within a second.'),
    'Meteor': dict(text='A monster your uppercut launched comes down on it.'),
    'Star Punch': dict(text="Kill with the gloves' Star Punch."),
    'Down for the Count': dict(text='Your Rifle Butt knocks it down; kill it within 3 seconds.'),
    'Bare Knuckle': dict(text="A glove kill with RSQ Melee's Slappers Only on."),
    'Red Mist': dict(text="A shotgun kill in your F.E.A.R. slow motion, on a monster you did not shove.",
                     needs='RSQ Melee and RSQ SlowMo'),
    # reading the attack
    'Justice Shot': dict(text='Your gun kills it while it winds up an attack, before the attack leaves it.'),
    'Read It': dict(text='Its shot passes close to you and never hurts you, then you kill it within 3 seconds.'),
    # roster
    'Rarity': dict(text="The rarer the monster's colour, the bigger the bonus.",
                   bonus='+{0.1} on an imp at 1 in 20, up to +{1.0}', needs='RSQ Monsters'),
    'Full Spectrum': dict(text='Kill all 13 colours yourself in one map. Given once.', needs='RSQ Monsters'),
    'Colour Chain': dict(text='Kill the same colour again and again.',
                         bonus='+{0.15} on an imp for each kill past two, up to +{0.75}', needs='RSQ Monsters'),
    'Keep the Change': dict(text='Kill it while it flashes, about to move up a tier. More if it was becoming a boss.',
                            bonus='+{0.3} on an imp; +{0.5} if it was becoming a boss', needs='RSQ Monsters'),
    'Fresh Paint': dict(text='Kill it within 3 seconds of moving up a tier.', needs='RSQ Monsters'),
    'Upset': dict(text='A Common, Green or Blue monster kills a boss tier or an EX. Every player gets it.', needs='RSQ Monsters'),
    'Tier Slayer': dict(text='Kill a boss tier or an EX with a pistol, fists, a kick or the shove.', needs='RSQ Monsters'),
}

# Rows README lists in a way the bullet reader cannot split; written out here, each from the README line named.
EXTRA = [
    # "Champions' colours": 14 colours x0.25, Bronze/Silver x0.5, Gold x0.75 (Daring)
] + [(c + ' Champion', 'Daring', art(c) + ' ' + c + ' champion. This is for its powers; its extra health is in the base already.',
      '+{0.25} on an imp', 'Champions')
     for c in ['Dark Red', 'Red', 'Orange', 'Yellow', 'Dark Green', 'Green', 'Cyan', 'Blue', 'Indigo', 'Violet', 'Pink',
               'Black', 'Grey', 'White']] + [
    ('Bronze Champion', 'Daring', 'Kill a Bronze champion. This is for its powers; its extra health is in the base already.', '+{0.5} on an imp', 'Champions'),
    ('Silver Champion', 'Daring', 'Kill a Silver champion. This is for its powers; its extra health is in the base already.', '+{0.5} on an imp', 'Champions'),
    ('Gold Champion', 'Daring', 'Kill a Gold champion. This is for its powers; its extra health is in the base already.', '+{0.75} on an imp', 'Champions'),
    ('Titan', 'Daring', 'Kill a Titan champion.', '+{0.5} on an imp', 'Champions'),
    ('Undying', 'Daring', 'Kill an Undying champion (its heart killed first).', '+{0.5} on an imp', 'Champions'),
    ('Ghost', 'Daring', 'Kill a Ghost champion.', '+{0.25} on an imp', 'Champions'),
    ('Balloon', 'Daring', 'Kill a Balloon champion.', '+{0.25} on an imp', 'Champions'),
    ('Hybrid', 'Daring', 'Kill a Hybrid champion.', '+{0.25} on an imp', 'Champions'),
    ('Legendary', 'Daring', 'Kill a legendary monster after it rose.', '+{1.5} on an imp', 'LegenDoom'),
    ('Legend Denied', 'Daring', 'Kill a monster before it could rise as a legendary.', '+{0.75} on an imp', 'LegenDoom'),
    ('Legendary Champion', 'Daring', 'Kill a risen legendary with its champion powers on.', '+{0.5} on an imp', 'LegenDoom and Champions'),
    # the ladder's tiers (Daring; one a kill; Common gives none)
] + [(t + ' Tier', 'Daring', art(t) + ' ' + t + ' tier monster. The higher the tier, the bigger the bonus.', '+{%s} on an imp' % m, 'RSQ Monsters')
     for t, m in [('Green', '0.1'), ('Blue', '0.15'), ('Cyan', '0.2'), ('Purple', '0.25'), ('Yellow', '0.25'),
                  ('FireBlu', '0.3'), ('Abyss', '0.3'), ('Brown', '0.35'), ('Gray', '0.35'), ('Red', '0.4')]] + [
    ('Black Boss', 'Daring', 'Kill a Black Boss tier monster.', '+{0.75} on an imp', 'RSQ Monsters'),
    ('White Boss', 'Daring', 'Kill a White Boss tier monster, the top of the ladder.', '+{1.0} on an imp', 'RSQ Monsters'),
    ('EX Boss', 'Daring', 'Kill an EX boss. This comes on top of its tier.', '+{0.5} on an imp', 'RSQ Monsters'),
    # points from other mods
    ('Deflect', 'Melee', "Knock a bolt back into RSQ Saber's training remote.", 'points from RSQ Saber', 'RSQ Saber'),
    ('Remote Down', 'Melee', "Knock RSQ Saber's training remote out of the air.", 'points from RSQ Saber', 'RSQ Saber'),
    ('Rank', 'Daring', "RSQ Miniboss's Rank raises every bonus, up to twice as much at Rank 100. The extra shows on this row.",
     'up to twice the kill at Rank 100', 'RSQ Miniboss'),
    ('Finisher', 'Melee', "RSQ Miniboss's melee finisher on a staggered thrall or a Boss in BREAK!", 'points from RSQ Miniboss', 'RSQ Miniboss'),
    ('Boss', 'Daring', 'Kill the Boss you called in.', '+{3.0@1000} on a Baron of Hell', 'RSQ Miniboss'),
    ('Revenge', 'Daring', "Get back up from RSQ SlowMo's DOWN with a kill.", '+{1.0} on an imp; 100 if no kill comes with it', 'RSQ SlowMo'),
]

# Bullets the reader skips because EXTRA (or an O entry it cannot split) covers them
SKIP_BULLET_PREFIX = ("Champions' colours", "Champions' mutations", 'Each Champion row', 'LegenDoom', 'Deflect',
                      'Rank', 'Finisher', 'Boss', 'Revenge', 'Sights Up')

SPLIT_ROWS = ['Sights Up', 'Glass']   # "A / B" bullets, written as two rows

# section -> what its rows need when an override does not say
SECTION_NEEDS = {
    'The fists': 'RSQ Melee',
    'RSQ Melee': 'RSQ Melee',
    'Distance Grab, the rig, the grenade': 'RSQ Grenade or Brutal Doom VR',
    'The guns': 'nothing extra',
    'Champions': 'Champions',
    'RSQ Monsters': 'RSQ Monsters',
    'The second round': 'RSQ Grenade or Brutal Doom VR',
}

# combo step words -> the mod a step needs (README's own step words)
STEP_NEEDS = [
    ('Force', 'RSQ Saber'), ('saber', 'RSQ Saber'), ('ShieldSaw', 'RSQ ShieldSaw'), ('shield', 'RSQ ShieldSaw'),
    ('disc', 'RSQ ShieldSaw'), ('whip', 'RSQ Whip'), ('Wide Swing', 'RSQ Whip'),   # (hook, rope -> RSQ Grapple went 2026-11-27: no combo has a Grapple step, and "hook punch" is RSQ Melee's)
    ('Distance Grab', 'RSQ Distance Grab'), ('thrown gun', 'RSQ Distance Grab'), ('holster', 'RSQ Tactical Rig'),
    ('lean', 'RSQ Tactical Rig'), ('grenade', 'RSQ Grenade or Brutal Doom VR'),
    ('uppercut', 'RSQ Melee'), ('punch', 'RSQ Melee'), ('jab', 'RSQ Melee'), ('Headlock', 'RSQ Melee'),
    ('Guard', 'RSQ Melee'), ('shove', 'RSQ Melee'), ('Hadouken', 'RSQ Melee'), ('Swat', 'RSQ Melee'),
    ('Clear Out', 'RSQ Melee'), ('pound', 'RSQ Melee'), ('taunt', 'RSQ Melee'), ('Chokehold', 'RSQ Melee'),
    ('slow motion', 'RSQ SlowMo'), ('kick', 'Brutal Doom'), ('chainsaw', 'nothing extra'),
    ('the Boss', 'RSQ Miniboss'), ('thrall', 'RSQ Miniboss'), ('champion', 'Champions'), ('legendary', 'LegenDoom'),
    ('shot sent back', 'a mod that sends shots back'),
]

CASINO = re.compile(r'\b(pay|pays|paid|paying|payout|earned|earn|jackpot)\b', re.I)


FIRST = {}   # entry name -> the first multiplier its Bonus line shows (for the value check)


def bonus_line(spec, monster='imp', name=None):
    base = MONSTERS[monster]
    m0 = re.search(r'\{([0-9.]+)', spec)
    if name and m0:
        FIRST[name] = float(m0.group(1))
    def sub(m):
        v = m.group(1)
        if '@' in v:
            mult, b = v.split('@')
            return str(pts(float(mult), int(b)))
        return str(pts(float(v), base))
    return re.sub(r'\{([0-9.@]+)\}', sub, spec)


def auto_bonus(pay, monster, name=None):
    """README pay text -> a Bonus line: the first xN as points on the monster, the rest as points too."""
    m0 = re.search(r'×([0-9]+(?:\.[0-9]+)?)', pay)
    if name and m0:
        FIRST[name] = float(m0.group(1))
    pay = re.sub(r',? ?a big moment[^;,.]*', '', pay)
    pay = re.sub(r'\(a big moment[^)]*\)', '', pay)
    first = [True]
    base = MONSTERS[monster]
    art = 'an' if monster[0] in 'aeiou' else 'a'
    def sub(m):
        p = '+%d' % pts(float(m.group(1)), base)
        if first[0]:
            first[0] = False
            return p + ' on %s %s' % (art, monster)
        return p
    s = re.sub(r'×([0-9]+(?:\.[0-9]+)?)', sub, pay)
    s = re.sub(r'\+([0-9]\.[0-9]+)', lambda m: '+%d' % pts(float(m.group(1)), base), s)
    s = s.replace('at most', 'up to').strip(' ,;.')
    return s


def ascii_clean(s):
    s = s.replace('×', 'x').replace('→', 'then').replace('’', "'").replace('·', ',')
    s = s.replace('–', '-').replace('—', '-')
    s = s.replace('"', "'")
    assert all(32 <= ord(c) <= 126 for c in s), s
    return s


def read_readme():
    lines = open(README, encoding='utf-8').read().split('\n')
    start = next(i for i, l in enumerate(lines) if re.match(r'\*\*\d+ bonuses\*\*', l))
    end = next(i for i, l in enumerate(lines) if i > start and 'name="big-moments"' in l)
    rows = []
    section = ''
    default_fam = None
    for l in lines[start:end]:
        m = re.match(r'<summary><b>(.*?)</b>', l)
        if m:
            section = m.group(1)
            default_fam = 'Melee' if section.startswith('The fists') else ('Daring' if section.startswith('Champions') else None)
            continue
        m = re.match(r'\| \*\*(.+?)\*\* \| (\w+) \| (.*) \| (.*) \|$', l)
        if m:
            rows.append(dict(name=m.group(1), family=m.group(2), text=m.group(3), pay=m.group(4), section=section))
            continue
        m = re.match(r'- \*\*(.+?)\*\*(?: \((\w+)\))?:? ?(.*)$', l)
        if m and not l.startswith('- **Champions') :
            name = m.group(1)
            if name.startswith(SKIP_BULLET_PREFIX):
                continue
            body = m.group(3).lstrip(': ')
            sents = re.split(r'(?<=\.) ', body)
            text = ' '.join(s for s in sents if '×' not in s)
            pay = ' '.join(s for s in sents if '×' in s)
            rows.append(dict(name=name, family=m.group(2) or default_fam, text=text, pay=pay, section=section))
    return rows


def read_combos():
    """(name, pattern, mult) from the code, in table order; README's step words by name; README's group for needs."""
    code = []
    for f in ['combo.zs', 'combos.zs']:
        for m in re.finditer(r'reg\.OwnCombo\("([^"]+)",\s*"([^"]+)",\s*([0-9.]+)\)', open(os.path.join(ZS, f)).read()):
            code.append((m.group(1), m.group(2), float(m.group(3))))
    lines = open(README, encoding='utf-8').read().split('\n')
    a = next(i for i, l in enumerate(lines) if re.search(r'All \d+ named combos', l))
    words, groups = {}, {}
    group = ''
    for l in lines[a:]:
        if l.startswith('</details>'):
            break
        m = re.match(r'\*\*(.+)\*\*$', l)
        if m:
            group = m.group(1)
            continue
        m = re.match(r'- (.+?): (.+) \(×([0-9.]+)\)$', l)
        if m:
            words[m.group(1)] = (m.group(2), float(m.group(3)))
            groups[m.group(1)] = group
    return code, words, groups


def code_strings():
    s = set()
    for f in glob.glob(os.path.join(ZS, '*.zs')):
        if os.path.basename(f).startswith('glossary'):
            continue
        for l in open(f, encoding='utf-8', errors='replace'):
            # a row's label: a returned string (DisplayName / RowName / a table's switch), or a label in a table line
            if 'return' in l or 'Name' in l or 'Push(' in l or 'Label' in l:
                s.update(re.findall(r'"([^"\n]+)"', l))
    return s


def class_numbers():
    """row label -> the numbers in the class (or table line) that shows it"""
    out = {}
    for f in glob.glob(os.path.join(ZS, '*.zs')):
        if os.path.basename(f).startswith('glossary'):
            continue
        src = open(f, encoding='utf-8', errors='replace').read()
        for m in re.finditer(r'(?:DisplayName|RowName)\(.*?\)\s*const\s*\{[^}]*?"([^"]+)"', src):
            a = src.rfind('\nclass ', 0, m.start())
            b = src.find('\nclass ', m.end())
            body = src[a:b if b > 0 else len(src)]
            body = re.sub(r'//[^\n]*', '', body)
            nums = set(float(x) for x in re.findall(r'(?<![\w.])([0-9]+\.[0-9]+)', body))
            for lab in re.findall(r'"([^"]+)"', m.group(0)):
                out.setdefault(lab, set()).update(nums)
    return out


def needs_from_steps(steps):
    out = []
    for kw, mod in STEP_NEEDS:
        if kw.lower() in steps.lower() and mod != 'nothing extra' and mod not in out:
            out.append(mod)
    if not out:
        return 'nothing extra'
    return out[0] if len(out) == 1 else ', '.join(out[:-1]) + ' and ' + out[-1]


def zs(s):
    return '"' + ascii_clean(s).replace('\\', '\\\\') + '"'


def main():
    check = '--check' in sys.argv
    strings = code_strings()
    warn = []
    entries = []   # (fam, name, short, text, bonus, needs)

    for r in read_readme():
        name = r['name']
        o = O.get(name, {})
        fam = o.get('family', r['family'])
        if fam not in FAMS:
            warn.append('no family: %s (%s)' % (name, r['section']))
            continue
        monster = o.get('monster', 'imp')
        text = o.get('text', r['text'])
        if 'bonus' in o:
            bonus = bonus_line(o['bonus'], monster, name)
        else:
            bonus = auto_bonus(r['pay'], monster, name)
        needs = o.get('needs')
        if not needs:
            needs = next((v for k, v in SECTION_NEEDS.items() if r['section'].startswith(k) or k in r['section']), 'nothing extra')
        if name not in O:
            warn.append('no override (README words used): %s' % name)
        entries.append((fam, name, text, bonus, needs))

    for name in SPLIT_ROWS:
        if any(e[1] == name for e in entries):
            continue
        o = O[name]
        entries.append((o.get('family', 'Daring'), name, o['text'], bonus_line(o['bonus'], o.get('monster', 'imp'), name), o.get('needs', 'nothing extra')))
    for name, fam, text, bonus, needs in EXTRA:
        entries.append((fam, name, text, bonus_line(bonus, 'imp', name), needs))

    # the generic chain (README "Combos"): 2 tools x0.2, 3 x0.45, 4 x0.75, 5 x1.0, 6 or more x1.2 (combo.zs)
    for n, m in [(2, 0.2), (3, 0.45), (4, 0.75), (5, 1.0), (6, 1.2)]:
        more = ' or more' if n == 6 else ''
        entries.append(('Combos', '%d-Tool Combo' % n,
                        'Hit one monster with %s%s different tools, each within 3 seconds of the last, and kill it. A chain inside 2 seconds is worth more.' % (['', '', 'two', 'three', 'four', 'five', 'six'][n], more),
                        '+%d on an imp' % pts(m), 'nothing extra'))

    code, words, groups = read_combos()
    for name, pat, mult in code:
        if name in words:
            steps, rm = words[name]
            if abs(rm - mult) > 1e-6:
                warn.append('combo %s: README x%s, code x%s (code used)' % (name, rm, mult))
            st = steps.replace(' · ', ', ').split(' → ')
            text = ', then '.join(st) + '. The last one makes the kill.'
            needs = needs_from_steps(steps + ' ' + groups.get(name, ''))
        else:
            warn.append('combo %s not in README (pattern used)' % name)
            text = 'Steps: ' + pat.replace('>', 'then') + '.'
            needs = 'nothing extra'
        text = text[0].upper() + text[1:]
        entries.append(('Combos', name, text, '+%d on an imp' % pts(mult), needs))

    # checks: every row a name the code shows, its first value one of its class's numbers; no casino words
    nums = class_numbers()
    for fam, name, text, bonus, needs in entries:
        if fam != 'Combos' and name not in strings and name != 'Boss':   # Boss: handler.zs BOSS_ROW
            warn.append('not a string in the code: %s' % name)
        first = FIRST.get(name)
        if fam != 'Combos' and first is not None and name in nums and nums[name] and first not in nums[name]:
            warn.append('value check: %s shows x%s, its class has %s' % (name, first, sorted(nums[name])))
        for s in (name, text, bonus, needs):
            if CASINO.search(s):
                warn.append('casino word in %s: %s' % (name, s))
            if '%' in s:
                warn.append('percent in %s: %s' % (name, s))

    counts = {f: 0 for f in FAMS}
    out = ['// GENERATED by Score/tools/gen_glossary.py from tools/glossary_source.md, combo.zs and combos.zs: do not edit, re-run it.',
           '// The Glossary\'s entries (glossary.zs): family, name, what earns it, Bonus, Needs.',
           '', 'extend class RSQSC_GlossaryMenu', '{', '\tvoid Build()', '\t{']
    for fam in FAMS:
        out.append('\t\t// ---- %s' % fam)
        # each tab in A-Z order (the combo tab: the generic chain rows first, then the named combos A-Z)
        rows = [e for e in entries if e[0] == fam]
        rows.sort(key=lambda e: (not e[1][0].isdigit(), e[1].lower()))
        for e in rows:
            counts[fam] += 1
            out.append('\t\tAdd(%d, %s, %s, %s, %s);' % (FAMS.index(fam), zs(e[1]), zs(e[2]), zs(e[3]), zs(e[4])))
    out += ['\t}', '}', '']
    open(OUT, 'w', newline='\n').write('\n'.join(out))

    if check:
        for e in entries:
            print('%-11s | %-22s | %s | %s | %s' % e)
    for w in warn:
        print('WARN', w)
    print('wrote %s: %s, %d in all' % (os.path.relpath(OUT, SCORE), ', '.join('%s %d' % (f, counts[f]) for f in FAMS), sum(counts.values())))


main()
