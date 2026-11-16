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
| Everything above | Not built |
