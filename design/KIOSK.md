# The Boss kiosk and gold (owner, 2026-11-16 04:47-04:52)

His words: "you can build the kiosk now, and when we are within a range of it, this appears after a few moments of
standing still (to make sure it doesn't pop up during a fight). gold will come from... bits? ... a Boss would normally drop
a legendoom weapon, but this time they drop a kiosk which offers several legendary weapons, each having a cost? we will
have to hammer down the economy balancing later, or take a crack at it now."

**The look:** `mockups/kiosk/kiosk_TARGET.png` (his capture of the in-game render, 11-13: "i want that kiosk to look like
this") and `mockups/kiosk/kiosk_lucky_anim.gif` (his pick: the offers, gold SOTN prices, the compare card popping in,
LUCKY). The presentation follows `PRESENTATION_GUIDE.md`.

## Decided

| Question | His answer |
|---|---|
| Where gold comes from | **Both:** a few gold bits from every kill (in place of some health / armour / ammo bits), plus a big gold fountain from Bosses and champions |
| Gold when you die (no life left) | **Kept**, never lost |
| How many weapons at one kiosk | **As many as you can afford**, each offer once |
| The Boss's gold 1UP crate | **Still dropped**, beside the kiosk |

## The first version (numbers to tune in the headset)

- **The Boss drops the kiosk** where it died, in place of its one legendary weapon. Outside a Boss fight nothing changes.
- **It opens** when the player is within ~3 m and has stood still for ~2 s (never mid-fight); it closes when he walks
  away; it stays until he leaves the map.
- **Three offers**, legendary weapons rolled at the Boss's tier the way the Boss's single drop is rolled today (BD22 VR
  Reloaded's `rsld` TierRarity), each with a gold price by rarity. **LUCKY:** spend one Score life to raise one offer's
  rarity by one step.
- **Gold bits:** a recoloured Kill Rewards bit (gold), about 1 in 4 of a monster's bits; Bosses and champions throw a gold
  fountain. They fly to the player like other bits. Gold is banked and shown on the HUD beside the score, kept across maps.
- **Balance aim:** the gold from the kills between two Bosses buys about one Uncommon; saving across a couple of Bosses
  buys a Rare or better. Every gold bit and purchase is logged so the numbers can be tuned.
- **Who owns what:** LegenDoom supplies the weapons and effects; BD22 VR Reloaded rolls and makes the legendary pickups
  (asked by name); RSQ Miniboss drops the kiosk; RSQ VisualRewards' Kill Rewards drops gold bits; RSQ Score banks gold and
  spends lives for LUCKY. Without LegenDoom or BD22 VR Reloaded, no kiosk: the Boss drops as it does today.

## Built / not built (2026-11-16)

| Part | State |
|---|---|
| BD22 VR Reloaded: the legendaries, asked by name | **Built, rig only, not headset-confirmed** (2.0.4y, `src/zscript/rsld/kiosk.zs`, `RSLD_KioskService`): `ready`; `roll` N offers at a Boss's tier on N different guns (TierRarity + PickAt: the Boss's own drop's roll; melee not sold); `raise` one rarity step (the same effect when LegenDoom rolls it there, else one it does); the names (`gun`, `rarity`, `effect`, `desc`, `class`, `yours`: what the player holds on that gun, for the card); `give`: the real `RSLD_LegendaryPickup` made at the player and handed over (left lying when he already has a legendary on that gun); `kiosk.take`: the Boss's legendary drop, and any other drop the converter gives to that death for 105 tics, is not made. Without that call nothing changes |
| Miniboss: the kiosk dropped on a Boss win | **Built, rig only, not headset-confirmed** (`Miniboss/zscript/rsqmb/kiosk.zs`, tierup.zs `DropKiosk`): beside the 1UP crate (72 units to the side of the death spot, the side with room), only with BD22 VR's service ready (LegenDoom), RSQ Score's bank and Boss Kiosk on; else the Boss drops as before. Rig `kq_e2e3`: a real fight won, `RSLD drop: ... suppressed (the miniboss's: a kiosk took its place)`, the kiosk 72 from the death spot and the crate |
| Opening and closing | **Built, rig only, not headset-confirmed**: within Kiosk Range (3 m) standing still Kiosk Wait (2 s; moved under 0.5 m and slower than 2 units a tic) -> it opens (`opened 71 tics after he stopped`); 0.75 m past the range -> it folds (`closed (walked away)`); it stays until the map ends. Closed it shows the counter and the KIOSK sign |
| The look | **Built, rig only, not headset-confirmed**: the TARGET's layout (`tools/gen_kiosk.py`) with **every word and number in the owner's SOTN letters** (owner 2026-11-16 06:30: "what I liked the most"): his word sheet (`mockups/kiosk/sotn_word_sheet.png`) cut into letters as `ext.py` / `sotnfont.py` cut it, each with its two tones (top half, bottom half); B J Q V X Z and the marks, which the sheet lacks, drawn on the same 3 x 5 grid in the same box. The KIOSK sign, BOSS TIER n and the best rarity, the prices, rarities, effect names, the card (gun, rarity, effect, description, THIS / YOURS and its rows, the price line), SOLD, the counter, LUCKY, gold and lives. The mockup's motion: the gold words shimmer through three shades (kiosk_anim.py SH), the card pops (0.35 -> 1 with an overshoot) and its rows come in one by one, the offers pop in 2 frames apart, a Score life flies from the hand to the offer on LUCKY, then LUCKY! and the new rarity land, rise and fade; Photosensitive Mode stills the shimmer and the pops. Wall sprites in the kiosk's plane, turned to the player when it opens. `mockups/kiosk/rig/rig_SOTN_vs_mockup.png`, `rig_KIOSK_sequence_vr_trigger.png` |
| Buying (VR) | **Built, rig only, not headset-confirmed**: the Wheel's pattern: either hand's ray (QuestZDoom's AttackPos / OffhandPos and their angles) against each offer's box in the kiosk's plane, or the hand inside the box; a dotted beam to the offer; that hand's trigger (`+attack` / `+oh_attack`, taken in InputProcess only while it points at an offer) buys it if the bank holds the price, BD22 VR makes and hands over the legendary. Rig `kq_in7` with the faked controllers: `K_KEY down key 447 "+attack"` -> `BOUGHT offer 1 ... the legendary taken`; the off-hand trigger (`+oh_attack`) too (`kq_in2`) |
| LUCKY | **Built, rig only, not headset-confirmed**: the counter's LUCKY button (point and pull the trigger: armed), then the trigger on an offer: one Score life spent (`RS_ScoreService "life.spend"`), the offer one rarity up, its price follows; once per kiosk; refused at Epic, without a life, or after it was used. Alt fire straight on an offer does the same (the rig's faked controllers send no alt fire: not shown). Not counted as a lost Boss fight (LossTick). Rig `kq_in7`: `LUCKY on offer 0 ... a Score life spent (1 left); COMMON RECURSIVE -> UNCOMMON IGNITING, price 250 G`; `kq_e2e3`: a second LUCKY `refused ... already used` |
| Gold bits | **Built, rig only, not headset-confirmed** (VisualRewards `killrewards.zs` `RSQ_KRGoldBit`, sprite KRBG from SoM's orb, `tools/gen_gold_bit.py`): Gold Share (25 %) of a kill's bits turn gold in place of the health / armour / ammo bit; a Boss throws a Boss Gold Fountain (20) more, a champion a Champion Gold Fountain (6) more; they fly to the player and bank in Score. Only with RSQ Score loaded. Menu rows (Kill Rewards: Gold Bits, Gold Share, Gold per Bit, Boss / Champion Gold Fountain; Test and Debug: Gold Log). `rig_GOLD_BITS_fly_in.png` |
| The gold bank | **Built, rig only, not headset-confirmed** (Score `gold.zs`): on the tracker (saved, carried across maps); `gold.add` / `gold.spend` (all or nothing) / `life.spend` / `gold`, `gold.earned`, `gold.map` by name; never lost on death (the bank at death kept in `rs_score_gold_keep` and given back when that map reloads; rig `kq_death1`: `died on MAP01 with 300 banked` -> `MAP01 reloaded after a death: bank 0 -> 300 (kept)`); Gold Log. **Shown on the off-hand watch card, not on Score's line** (owner 2026-11-16 06:30): RSQ Gun Cards asks Score by name for "gold" and writes GOLD n in gold on the off hand's watch card (Weapon card after KILLS, Status card under the keys, item card last; the main hand's card has none). Rig `kq_watch5` (the world cards, rsqgc_world 1): `[GOLD 350]` -> `[GOLD 355]` as a gold bit lands, on the off hand's card only; `rig_WATCH_gold_offhand.png` (the rig's pose shows that card from behind). The hand-drawn watch card's GOLD line (side.zs) is built but not yet seen on the rig. The kiosk's own counter keeps GOLD and LIVES |
| The logs | **Built**: Gold Log (Score: every deposit and spend, each map's gold as it ends), Gold Log (VisualRewards: every kill that threw gold, every gold bit picked up), Kiosk Log (Miniboss: each Boss win's gold since the last one, the drop and its offers, opening, closing, every purchase, LUCKY and refusal). `mockups/kiosk/rig/evidence_2026-11-16.txt` |
| Headset | Nothing here has been seen in the headset |

## My readings (where the doc left it open)

- **Champions' fountain:** "a champion" is a Champion that is also a LegenDoom legendary (a boosted legendary champion, as BD22
  VR's drops and a Boss's thralls count them). On Black Metal Champions makes every monster a Champion (its chance is
  (4 + 10 x skill) x (skill + 1) / 256): rig `kq_econ1` had 150 fountains in 150 kills, which is not "a few gold bits from
  every kill".
- **LUCKY's button:** the owner's rig has no alt-fire button among the faked controller's (grip, A, B, the off trigger), and
  keys are precious in VR (owner 11-10), so LUCKY is a button on the counter worked with the trigger; alt fire on an offer is
  kept as a shortcut. One per kiosk (the mockup's ONE PER KIOSK).
- **Buying is the trigger,** not the mockup's HOLD GRIP (the grip is QuestZDoom's own weapon grab and sends no key the game sees).
- **Which guns are sold:** the eight gun slots (chainsaw to BFG), three different ones a kiosk; melee is not sold.
- **A legendary bought for a gun you already have a legendary on** is made and left at your feet (LegenDoom's one per gun),
  with a toast; the purchase stands.
- **Never lost on death:** dying with no life reloads the map; the bank at death comes back on that same map's reload. A New
  Game started on that same map straight after dying keeps it too (rare; harmless).
- **Gold bits and Rich Bits:** Rich Bits does not raise a gold bit's worth (the prices are tuned against plain gold).

## The first numbers (rig kq_econ3, MAP02, the owner's skill 6, 2026-11-16)

The rig's player killed the map's monsters one at a time beside him (every kill plain: no style, so the Boss meter fills
slowest), called the Boss in when the meter was full and killed it (thralls first). Gold per bit 5:

| | Map kills | Gold banked in the cycle |
|---|---|---|
| Map start -> Boss 1 won | 24 | **255** (145 of it the fight: the Boss's 9 share bits + its 20 fountain, the thralls) |
| Boss 1 -> Boss 2 won | 12 | **275** |

About 1 gold bit in 4 of a kill's bits (rig: 156 of 572), ~0.9 gold bits a plain kill, 70-80 % of them reaching the player
when he moves on at once. So a cycle (the kills between two Bosses and the Boss itself) is about 250-280 gold, and the first
prices are:

| Rarity | Price | Cycles |
|---|---|---|
| Common | 150 | ~0.6 |
| Uncommon | 250 | ~1 (the aim: one Uncommon a Boss) |
| Rare | 500 | ~2 (the aim: a couple of Bosses saved, a Rare) |
| Epic | 900 | ~3.5 |

All are cvars (Miniboss `rsqmb_kiosk_price_*`, VisualRewards `rsqvr_gold_value` / `_share` / `_fountain` / `_champion`), with
menu rows. In real play the meter fills faster (style, chains), so fewer kills a cycle: the Boss's own gold (about half of a
cycle) keeps the floor. One rig fight (`kq_e2e3`) gave much more: the probe killed the Boss's first body outright, and Kill
Rewards burst a Boss fountain for that body too (Tier Up Each Life swaps the body); in a real fight that body does not die.
To tune in the headset.
