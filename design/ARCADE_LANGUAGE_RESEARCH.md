# Arcade in-world language: research notes

Research for "Doom Arcade VR" (owner's words). Date: 2026-11-08.
Question: how do Sega (and some others) put words, numbers, timers and ranks INTO the play space?

## How to read this
- Every game detail below was seen in a source I opened. The URL is next to it.
- Lines marked **[inference]** are my ideas for VR Doom, not facts about the games.
- **Big gap, said up front:** text sources rarely describe font, colour, motion or exact screen
  position. For most callouts I could confirm WHAT appears and WHEN, but not HOW it looks.
  Where a look was described (colour, flash, position), I say so. Sega Retro, GameFAQs,
  Hardcore Gaming 101 and several fandom wikis refused the fetch, so Sega's own detail pages
  were not available. Next step before mockups: watch attract-mode / gameplay footage of the
  priority games and note the look frame by frame.

---

## 1. Lock-on ring (threat timer drawn on the enemy)
**What:** a marker drawn on an enemy that shows how soon he will shoot you.
- **Virtua Cop (1994):** the sight sits on the gunman and works like a traffic light. Green while
  he is not ready, then yellow, then red; when he is about to fire it "rapidly flashes red".
  Later stages are almost always orange-to-red. The first two games let you switch it off.
  https://www.sega-16.com/2020/03/virtua-cop-saturn/ ,
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/VirtuaCop
- One writer says the sight first appears as a green "tunnel" with arrows moving round its edge,
  pulling your eye to the next target, and the camera zooms to centre it. Red means he is about to
  shoot, not that you are hit.
  https://kimimithegameeatingshemonster.com/2020/09/08/light-gun-lightning-in-a-bottle/
- Wikipedia says the reticle and zooming camera were inspired by a coffee advert.
  https://en.wikipedia.org/wiki/Virtua_Cop
- **Let's Go Jungle:** each boss weak point gets a ringed target; hit them all in time and the boss
  flinches. https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/LetsGoJungle ,
  https://en.wikipedia.org/wiki/Let%27s_Go_Jungle!:_Lost_on_the_Island_of_Spice
- **After Burner:** the lock warning was on the CABINET, not the screen: flashing lights on the
  monitor frame showed an enemy lock on you. https://en.wikipedia.org/wiki/After_Burner
- **[inference]** A ring on the imp that tightens green to red before its fireball is the single most
  "Virtua Cop" thing we could add, and it lives on the monster, where the VR player already looks.

## 2. Danger flash (this shot WILL hit you)
**What:** only the attacks that will really hurt you are marked.
- **Time Crisis:** in the first two games, bullets that will hit are red with swirls; the rest are
  yellow tracers. Later games mark a hitting attack with a red flash; Time Crisis II shows a red
  reticle on the shooter. https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/TimeCrisis
- Time Crisis II: knives and missiles flash red at the start of the attack; grenades and rolling
  barrels do not, because you can shoot them down.
  https://timecrisispedia.fandom.com/wiki/Time_Crisis_II/Game_Mechanics
- One review: a red octagon appears when a shot is aimed at your head, with a "blip-blip" sound.
  https://www.honestgamers.com/3819/arcade/time-crisis-ii/review.html
- **[inference]** In VR the player can physically dodge. A red flash on the projectiles that will
  actually hit turns dodging into a readable skill.

## 3. Shot-quality word (the game names how good your shot was)
**What:** a short word for the quality of one hit, escalating with streaks.
- **House of the Dead III:** per-shot words "Excellent", "Good", "Faster", and "Twin Shot" (two
  targets with one shell). https://en.wikipedia.org/wiki/The_House_of_the_Dead_III
- **House of the Dead 4:** a critical-shot counter climbs GOOD, GREAT/EXCELLENT, AMAZING, PERFECT.
  Getting hit or a non-weak-point kill resets it. (Wikipedia lists Good, Excellent, Amazing,
  Perfect; TV Tropes lists GOOD, GREAT, AMAZING!, PERFECT!. The sources disagree on tier 2.)
  https://en.wikipedia.org/wiki/The_House_of_the_Dead_4 ,
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/HouseOfTheDead
- **Virtua Cop:** shooting the gun out of a hand is a "Justice Shot" (outside Japan, the first game
  said "Nice Bullseye"). Worth a flat 5,000 points.
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/VirtuaCop ,
  https://kimimithegameeatingshemonster.com/2020/09/08/light-gun-lightning-in-a-bottle/
- **Rambo (2008):** shots are classed "Fast, Crack and Heroic". A reader comment (not the article)
  says a gold flash confirms a Heroic shot.
  https://arcadeheroes.com/2008/05/26/rambo-uk-location-test-video-impressions
- **Borderlands:** a critical hit shows the word "CRITICAL" as floating red text, to the shooter only.
  https://borderlands.fandom.com/wiki/Critical_hit_(Borderlands)
- **[inference]** Headshot streak words (GOOD, GREAT, AMAZING, PERFECT) are cheap, loud and readable
  in a headset, and give the Doom shotgun a reason to aim.

## 4. Number at the hit point (damage / score on the target)
**What:** the number appears on the thing you hit, not in a corner.
- Design notes from Tim Cain (via a wiki summary): numbers go where the player is already looking;
  size shows importance (crits always big); colour plus motion per damage type (fire rises,
  electricity zigzags, acid drips, physical bursts outward). Warning: two numbers side by side can
  read as one ("12" and "4" as "124").
  https://turbo-wiki.pages.dev/tim-cain/ux-design/damage-numbers
- **Bulletstorm:** creative kills ("skillshots") pay points; a review says the screen "light[s] up
  with points". Named examples: Mercy, Full Throttle, Gang Bang, Headshot.
  https://www.pushsquare.com/reviews/ps3/bulletstorm ,
  https://www.gameinformer.com/b/features/archive/2010/04/26/killing-with-style-an-illustration-of-bulletstorm-s-skillshots.aspx ,
  https://en.wikipedia.org/wiki/Bulletstorm
- I did NOT find a source confirming Sega light-gun games pop score numbers on the enemy.
  Treat that as unverified.
- **[inference]** In VR, a number pinned on the corpse must face the player and not stack into
  one long figure; Cain's "separate by colour and motion" rule applies directly.

## 5. Combo / multiplier meter
**What:** a counter that grows with clean play and breaks on a mistake.
- **Virtua Cop:** a bonus multiplier bar rises with each hit on one enemy (up to three), best x9;
  getting hit or shooting a hostage drops it two ranks.
  https://kimimithegameeatingshemonster.com/2020/09/08/light-gun-lightning-in-a-bottle/
  **Virtua Cop 3:** every enemy shot raises the multiplier, up to x16.
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/VirtuaCop
- **Time Crisis II:** a Hit Counter at the TOP of the screen counts consecutive accurate shots; a
  miss or hesitation makes it vanish. No-miss bonus: 500 at the 10th hit, up to 5,000 from the
  100th. https://www.honestgamers.com/3819/arcade/time-crisis-ii/review.html ,
  https://timecrisispedia.fandom.com/wiki/Time_Crisis_II/Game_Mechanics
- **HotD: Overkill:** the meter climbs through named tiers: Extreme Violence, Hardcore Violence,
  Ultra Violence, Psychotic, then Goregasm (each kill then worth 1,000).
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/TheHouseOfTheDeadOverkill
- **NBA Jam:** three baskets in a row = "on fire"; the BALL catches fire and singes the net; the
  announcer says "He's heating up", "He's on fire". https://en.wikipedia.org/wiki/NBA_Jam_(1993_video_game)
- **[inference]** Named tiers beat a bare number. Overkill's tier names show how far flavour can go;
  NBA Jam shows the state can live on an object (the gun) instead of the HUD.

## 6. State shout (the game says what is happening)
**What:** a voice or a big word announces a change of state.
- **Space Harrier:** voice at start: "Welcome to the Fantasy Zone. Get ready!"; after a stage:
  "You're doing great!". https://en.wikipedia.org/wiki/Space_Harrier
- **After Burner:** a famous "fire!" call on missile launch, "boom!" on hits.
  https://www.arcadeattack.co.uk/after-burner-2-mega-drive-review/ ; Climax: "JAGUAR LEADER'S HIT!".
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/AfterBurner
- **House of the Dead 1:** rescuing a scientist shows "Life Up!" in red or blue (per player colour).
  https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2
- **Smash TV:** host lines "Total carnage! I love it!", "Big money! Big prizes! I love it!".
  https://en.wikipedia.org/wiki/Smash_TV
- **Point Blank:** picking a VERY HARD / Insane stage shows a red splash with the word in flaming
  letters. The Galaga stage shows "PERFECT!" with a jingle.
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/PointBlank1994
- **Pinball:** "call-outs" are speech or sound tied to a shot or active mode.
  https://en.wikipedia.org/wiki/Glossary_of_pinball_terms
- **[inference]** Few, short, loud: GET READY, LIFE UP, PERFECT. The player's state, shouted once.

## 7. Arcade timer (time is the pressure)
**What:** a countdown that fails you or refills on progress.
- **Time Crisis (1995):** one minute per area, counting through fights and transitions; certain
  enemies give a few extra seconds. https://en.wikipedia.org/wiki/Time_Crisis_(video_game)
  Original: up to 60 s added; running out costs all lives; rank is by speed. Later games: fixed
  40 s per section; from TC2 the timer stops while "WAIT" is shown.
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/TimeCrisis
  TC2 pays 20 points per 1/60 s saved under the limit.
  https://timecrisispedia.fandom.com/wiki/Time_Crisis_II/Game_Mechanics
- **Point Blank:** every mini-game has a task and a time limit; fail = lose a life.
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/PointBlank1994
- **HotD III Time Attack:** a timer from 45 s replaces lives.
  https://en.wikipedia.org/wiki/The_House_of_the_Dead_III
- **Galaxy Force:** energy meter at the bottom drains as the level goes on; firing and hits drain
  it too. https://en.wikipedia.org/wiki/Galaxy_Force
- **[inference]** A per-room timer that refills on room clear fits Doom arenas well; speed bonus
  per room is the Time Crisis tally.

## 8. Rank / grade
**What:** a letter or word judging your play, per stage and at the end.
- **HotD III:** S to E per chapter; SS final rank. https://en.wikipedia.org/wiki/The_House_of_the_Dead_III
  Later HotD games: chapter grades earn extra lives.
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/HouseOfTheDead
- **HotD: Overkill:** a grade at the end of every level; score becomes cash for guns.
  https://en.wikipedia.org/wiki/The_House_of_the_Dead:_Overkill
- **Rambo:** S to C on accuracy, score, shot types, events; then a percentage "Rambo rating".
  https://arcadeheroes.com/2008/05/26/rambo-uk-location-test-video-impressions
- **Let's Go Jungle:** a co-op compatibility percentage after each stage; S rank leads to a good
  ending. https://en.wikipedia.org/wiki/Let%27s_Go_Jungle!:_Lost_on_the_Island_of_Spice
- **Point Blank 1-2:** the end result advises you (try harder difficulty, practise more);
  3 and DS give a letter grade. https://en.wikipedia.org/wiki/Point_Blank_(video_game_series)
- **Time Crisis:** clearing without continues puts a star next to your initials.
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/TimeCrisis
- **[inference]** A big letter on the exit door or in front of the player at level end.

## 9. Bonus tally (count-up after the action)
**What:** points converted and counted after a stage.
- **HotD III:** spare lives become bonus points. https://en.wikipedia.org/wiki/The_House_of_the_Dead_III
- **Point Blank:** each remaining life = 10,000 at the end; a no-miss stage = +1,000.
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/PointBlank1994
- **Virtua Cop:** Interim (mid-stage) and Mission Reports count civilians shot.
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/VirtuaCop
- **HotD 1:** stage results show each player's score separately; a "stage clear" jingle.
  https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2
- **Pinball:** end-of-ball bonus is paid when the ball drains, multiplied by the bonus multiplier;
  tilt forfeits it. https://en.wikipedia.org/wiki/Glossary_of_pinball_terms ,
  https://www.sternpinball.com/wp-content/uploads/2022/09/Rush-Rulesheet.pdf
- **Smash TV:** in two-player, whoever collected the most cash and prizes gets an extra reward.
  https://en.wikipedia.org/wiki/Smash_TV
- I found no text source describing the count-up animation itself.
- **[inference]** Kills, secrets, time, accuracy counted up one line at a time at the exit.

## 10. Boss card / weak-point brief
- **House of the Dead:** each boss fight opens with a profile showing its weak point, with a
  warning sound (heartbeat in 1-2, beeping in III, scan beeps in 4).
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/HouseOfTheDead
- **Space Harrier:** in the last stage, the past bosses are named at the bottom of the screen.
  https://en.wikipedia.org/wiki/Space_Harrier
- **HotD: Overkill:** grindhouse chapter titles ("Papa's Palace of Pain"), each level a film poster.
  https://tvtropes.org/pmwiki/pmwiki.php/VideoGame/TheHouseOfTheDeadOverkill
- **[inference]** Cyberdemon walks in: name and weak point stamped in the air beside him.

## 11. The level keeps score (pinball playfield language)
**What:** the table itself shows goals with lights; the display only confirms.
- Lit inserts and lit shots tell you where to shoot; starting a mode lights the shots to hit.
  Ball save: a light near the flippers flashes while it is on, only for a short time after plunge.
  Extra ball: a "Shoot Again" light between the flippers. Skill shot: often a flashing lane on the
  plunge. https://www.kineticist.com/news/pinball-for-dummies
- **Stern Rush rulesheet:** lit inserts show the next combo shot (hit within a few seconds to
  double); flashing shots are worth more; jackpot colour shows the multiplier (blue, green, yellow,
  orange, red = 1x-5x, higher ones time out faster); "all lights go out" before a super jackpot
  lights; a 20 s jackpot timer; a year counter on the toy tracks progress to the wizard mode.
  https://www.sternpinball.com/wp-content/uploads/2022/09/Rush-Rulesheet.pdf
- **Twilight Zone:** a real clock on the playfield is the mode timer (Clock Chaos runs it backward
  from 6:00 to 12:00); a lit doorknob signals the wizard mode; a lit Player Piano = jackpot ready.
  https://en.wikipedia.org/wiki/Twilight_Zone_(pinball)
- Terms: jackpot, multiball, lock, skill shot, ball save, extra ball, mode, wizard mode, combo.
  https://en.wikipedia.org/wiki/Glossary_of_pinball_terms
- **[inference]** Doom maps already have lights and switches. Light the monster or door that is the
  next "shot"; colour = its value; a lit object in the room = a timer. The level talks, not the HUD.

## 12. Jackpot / multiball frenzy (a short mode where everything pays more)
- Pinball multiball: several balls at once; jackpots lit only during it; a 6-ball wizard mode
  lasting about 45 s, then a tally (Twilight Zone).
  https://en.wikipedia.org/wiki/Twilight_Zone_(pinball) ,
  https://en.wikipedia.org/wiki/Glossary_of_pinball_terms
- **Rambo:** a full Rage gauge starts Rambo Mode: invincible, unlimited ammo, until the bar drains.
  https://arcadeheroes.com/2008/05/26/rambo-uk-location-test-video-impressions
- **Virtua Cop 3:** ES mode, a foot pedal slows time while a meter drains; kills refill it.
  https://en.wikipedia.org/wiki/Virtua_Cop_3
- **[inference]** "MULTIBALL" for Doom = a wave released on purpose, with a lit JACKPOT monster
  and a clock. Fits the existing SlowMo / Score folders, but that is the owner's call.

## 13. Fonts and look (what I could and could not confirm)
- Arcade type was mostly drawn on an 8x8 grid; some games used thick faces with colourful
  extrusion (Black Heart example). https://www.creativereview.co.uk/a-visual-history-of-arcade-game-typography/
- Space Harrier Master System manual: top score upper left, score upper right, stage lower right;
  high score table in red. https://www.smspower.org/seganotebook/sharrier/manual/sharriem.html
- Line of Fire: a scoreboard at the top of the screen could hide enemies (a complaint).
  https://en.wikipedia.org/wiki/Line_of_Fire_(video_game)
- Not confirmed from any source: the fonts, colours and animation of Sega light-gun callouts.
  Needs footage review. Toshi Omagari's book "Arcade Game Typography" (Thames & Hudson, 2019) is
  the obvious next reference; I did not read it.
- Not covered for lack of a usable source: Thunder Blade, Rail Chase, Star Wars Arcade / Trilogy
  HUDs, Ghost Squad HUD, Brave Fire Fighters, Roboquest.

---

## The 10 strongest patterns for us [inference, ranked]
1. **Lock-on ring on the attacker** (Virtua Cop): green to red before he fires. On the monster.
2. **Danger flash on hits that will land** (Time Crisis): red only on real threats; VR dodging.
3. **Shot-quality word streak** (HotD 4): GOOD, GREAT, AMAZING, PERFECT on headshot chains.
4. **Named combo tiers that break on a mistake** (Overkill, Virtua Cop, TC2 hit counter).
5. **The level lights the next shot** (pinball inserts): lit target, colour = value.
6. **Per-room timer that refills on clear** (Time Crisis), with a time bonus.
7. **Short state shouts, voice plus word** (Space Harrier, HotD "Life Up!", Point Blank PERFECT!).
8. **Letter grade per level, S at the top** (HotD III, Rambo), shown at the exit.
9. **Bonus tally at the exit** (pinball end-of-ball bonus, Point Blank lives to points).
10. **Frenzy mode with a clock and a JACKPOT** (pinball multiball, Rambo Mode).

Also worth a look: the special-move word for a precise non-kill shot (Virtua Cop Justice Shot),
and the boss card with weak point (HotD).
