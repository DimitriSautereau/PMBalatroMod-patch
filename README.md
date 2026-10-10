# PMBalatroMod
Please refer to the original https://github.com/CountKiro/PMBalatroMod
this is just a fork due to some aspect i want to fix

# Installing 
Due to mod structure change a bit for convenient in development, you can git clone the mods or download the whole code as to put it into mods folder as PMBalatroMod-patch-master

# Table of Change
- Add sin seal (based on what the description in the code said and my interpretation)
- Add sin texture in 2x (texture come from upscaling the 1x one with lazy and simple algorithm so it look a bit pixelated)
- Fix/Add magical girl
- Change Mod structure
- Fix XiChun display
- Fix Niko code
- Fix Indigo Elder code
- Improve Alan logic
- Improve Garnet logic
- Flowing time nerf *Questionable
- Fix kongsihui

# Table of Change (patch pass)
Every item below is one commit; the reasoning and the source references are in the git log.

Sin seals
- A scored card with no seal can now pick one up when it carries the matching enhancement, 1 in 10: bleed -> Lust, poise -> Pride, tremor -> Sloth, rupture -> Gluttony, burn -> Wrath, sinking -> Gloom. A plain card can pick up Envy at 1 in 60 while an edition is in play on it or on a Keypage. The seal is permanent and works from that card's next scoring.
- Reworked Envy (grants a random edition, or spreads its seal when the card already has one), Lust (flat +1 per scoring, with a Sloth-raised chance to spread) and Gloom (1 chip per 1% of the Encounter Score above 10%).
- Seal descriptions now state the exact numbers and what each point of Sloth adds.

Charge
- Charge is now one shared pool: +1 per scored Page, +1 per hand for each Keypage holding it (Tiph B doubles the gain), and a Keypage spends 5 to score a played card twice, leftovers carrying over.
- Fixed Keypages never feeding the pool. The hidden manager card lives in the dummy joker area, and the base game dispatches hand-level contexts straight over its own card lists, so it only ever received the per-scored-card context - the joker_main branch was dead code.

Shop pool
- Weight is equal inside each rarity again. The 29 jokers that scaled their own weight now start at x1 like their peers and only rise while their condition holds, capped at x8 (PMCMOD.MAX_SHOP_WEIGHT_MULT). Uncapped, a 10-pallid deck put queequeg at x2048 and one joker owned its rarity.
- Every pool a joker declares now resolves: added the 7 missing ObjectTypes (RCorp, Ring, Index, Middle, Pinky, LCorp, Limbus), fixed the Sinner/Puppet/R Corp declarations, the six ObjectType defaults written in a key form that can never resolve, and a card key in TrueVersion that does not exist.
- The 57 summon/transform-only jokers are documented instead of relying on placeholder pool flags that nothing ever set.

Other fixes
- Lei Heng can no longer destroy an Eternal Keypage; a protected neighbour turns that toss into a retrigger.
- All gameplay math.random rolls are seeded, so results stay reproducible from the run seed.
- Manifest now unlocks a still-locked True Version (and adds it to the collection) instead of showing "Locked" and burning the Spectral; 18 of its 21 targets start locked. Seeded and challenge runs still refuse unlocks.
- Two texture pack badge keys that were referenced but never defined, and a stray brace in pt_BR.
- Silent Deck gives +1 hand and +1 discard instead of +2/+2, and Kong Sihui pays $5 instead of $2. The deck change had to be applied to objects/backs/silent.lua: the loader only reads objects/backs/, so objects/decks/ is a dead duplicate of all 11 decks.
- Charge edition weight 3 -> 17, and maxim/rudolph only enter the shop pool while a Keypage holding Charge is on the team.
- Maxim reworked onto the shared Charge pool: scored Face cards add 5 Charge, scored number cards spend 1 Charge to trigger twice, +2 Chips per dollar held, and $1 per 10 Charge at the end of the Scene.
- Rudolph reworked (his calculate was empty, so he did nothing): Charge cards trigger once more, a Charge Keypage gains $1 sell value each time it triggers, he gains Mult equal to the other Keypages' total sell value, and selling anything feeds its sell value into the Charge pool.
- Nikolai: R Corp Keypages give x1.5 Mult each while he is held (compounding - three is x3.375), on top of his catalogue Mult.
- Prescripts reworked: an Index Keypage on the team (aspects excluded) issues one whenever none is active, each lasts 3 Scenes, and resolving grants Grace of the City (fulfilled) or Karmic Consequence (failed) - two run-wide counters - while the old $15 / wipe-money swing moved to Voice of the City, which now only pays it out while it is held.
- Garnet left the Index pool (it keeps Thumb, Middle, Ring, Pinky and Bloodfiends), Grace of the City now scales the shop weight of the Index Keypages (x2 each, capped x8), and Nikolai no longer catalogues aspects.

