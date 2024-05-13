# Episode 1: Reborn, the City of Ruin

Welcome to my 100% walkthrough of Pokémon Reborn.

My aim with this document is to provide a complete route through the game including every single item including hidden ones, available Pokémon, some tips for battle strategies, shop and tutor details, and more. To summarize my approach: if you're the type of person that doesn't really like having tons of tabs open at once while you're trying to 100% complete this game, hopefully my guide may be useful for you.

Since this guide is complete, there are some parts that may spoil events that happen later in the game. I try to be vague about story details, but you may want to consider playing the game once first without referencing this walkthrough if this is a concern.

## All Aboard!

The game will first ask you to choose a player character and gender. It will then ask you if you want to view controls. You can actually rebind controls with F1 and even add controller support if you'd like! Once you've gotten acquainted with your chosen controls, you'll find yourself on the train.

Ame will ask you if you have any special instructions or passwords. From the game's readme:

<div id="quote">
    <p> At the start of the game, you will be prompted for special instructions, or passwords. Below is a list of applicable passwords. Please note that these are features are considered a bonus, and may have some  unexpected interactions at times...
    </p><br><br>
    <p>Implement a hard EXP cap when maxed on badges, similar to Pokémon Rejuvenation: </p><br>
        <ul><li>Password: hardcap</li></ul><br>
    <p>Cause randomized early game Pokémon events to bias towards a specific type:</p>
        <ul>
            <li>Password: mononormal</li>
            <li>Password: monofire</li>
            <li>Password: monowater</li>
            <li>Password: monograss</li>
            <li>Password: monoelectric</li>
            <li>Password: monoice</li>
            <li>Password: monofighting</li>
            <li>Password: monopoison</li>
            <li>Password: monoground</li>
            <li>Password: monoflying</li>
            <li>Password: monobug</li>
            <li>Password: monopsychic</li>
            <li>Password: monorock</li>
            <li>Password: monoghost</li>
            <li>Password: monodragon</li>
            <li>Password: monodark</li>
            <li>Password: monosteel</li>
            <li>Password: monofairy</li>
        </ul><br>
    <p>Prevent Pokémon from being healed after their HP drops to 0:</p>
        <ul><li>Password: nuzlocke</li></ul><br>
    <p>Randomly reshuffles species and moves as rolled at game start:</p>
        <ul><li>Password: randomizer</li></ul><br>
    <p>Pokémon do not need to know HM (TMX) moves in order to use them in the field:</p>
        <ul><li>Password: easyhms</li></ul><br>
    <p>Prohibits the player's use of items in trainer battles:</p>
        <ul><li>Password: noitems</li></ul><br>
    <p>Sets all opposing trainer Pokémon to have 252 EVs and 31 IVs in all stats:</p>
        <ul><li>Password: fullevs</li></ul><br>
    <p>Sets all opposing trainer Pokémon to have 0 EVs and IVs in all stats:</p>
        <ul><li>Password: litemode</li></ul><br>
    <p>Makes all Field	Notes visible immediately</p>
        <ul><li>Password: allfieldapp</li></ul><br>
    <p>Remove some randomness by making all attacks do consistent damage rather than a roll:</p>
        <ul><li>Password: nodamageroll</li></ul><br>
    <p>Multiple passwords, including differing monotypes, may be used in tandem with
    each other, but progress at your own risk~</p><br><br>
    <p>Other hidden passwords may be able to be found in the game.</p>
</div>

If this is your first time playing, don't worry too much about passwords - in fact, you can activate passwords later on into the game if you change your mind or discover a new password.

- If you want to do a challenge run, try one of the *mono\[type\]* passwords. Note that it doesn't enforce any explicit rules for battle; it simply guarantees you suitable Pokémon for random events. I really recommend trying one of these especially for a second playthrough.
- You can do *nuzlocke* or *randomizer* if you'd like, just note that Nuzlocke doesn't enforce a first-mon-per-area rule explicitly. You can even do both at the same time.
- *hardcap* prevents you from leveling past your current cap, and *easyhms* allows you to use HM's without teaching them to your Pokémon. Reborn was originally built with the disobedience system and normal HM mechanics, but these passwords are highly recommended for quality of life.
- *noitems* makes it so you can't use in battle items like Potion and X-Attack. I prefer this for the extra difficulty it provides and how it increases the value of moves like Recover.
- *nodamagerolls* makes it so moves will always roll the same damage. There are some fights in this game you practically must reset for a couple times at least, so minimizing the randomness is in my opinion pretty handy.
- *fullevs* ramps up the difficulty significantly by making every Pokémon both hit hard and have some bulk. Reborn is already a tough game without this password, so tread carefully with this one.
- *allfieldapp* lets you see data about fields from the start. If you're following this guide I'll be picking up all the notes naturally anyways, so unless you really want to know right away how each field works you'll be ok skipping this one.
- *litemode* is a good choice if you are struggling or want to experience the wonderful characters, world, and puzzles without spending too much time on the battles.

Regardless, *this guide will be from the perspective of a player who is using no passwords.*

After you're done inputting passwords, enjoy the rest of your train ride!

## Grand Hall

As soon as you're off the train, you'll have a conversation with Ame and Julia. Note that I won't be summarizing story events much in this walkthrough aside from gameplay implications.

This conversation does quietly show off a mechanic in Pokémon Reborn: relationship points! Certain dialogue triggers and events will make certain characters like you more or less, interally stored as integer values per character. See [Ame's Devblog post](https://www.rebornevo.com/pr/development/records/about-relationship-points-r83/) for an explanation of them; they won't lock you out of any Pokémon, Items, or the like.

**Relationship Point Choices:**
- Yes (+1 Julia)

(Whenever a dialogue choice is not listed, it has no effect on the points.)

!img("hidden001.png")

Immediately down from your starting position, in a rock you'll find a hidden *Normal Gem* (A). There are tons of hidden items in this game, and we won't get the Itemfinder for another two badges or so.

More hidden items:
- (B): *Poké Ball*
- (C): *Red Shard*

It's worth noting that shards are useful in Reborn for obtaining Ability Capsules and Pokémon as well as learning moves via tutors.

Proceed to the right into Opal Ward. A girl at the bottom of the area will give you a *Potion*. In general, talk to as many people in Reborn as you can - they offer helpful tips for battles, give you useful items, etc.

If the weather is sunny you will see an Ice Cream Cart here.

!shop("Opal Ward Ice Cream Shop", ["Vanilla Ice Cream", "Choc Ice Cream", "Berry Ice Cream", "Blue Moon Ice Cream"])

Every day the Ice Cream Shop appears, there is a 1 in 21 chance that they will be selling the rare Blue Moon Ice Cream. Note that talking to the vendor when they are not selling the ice cream activates a cooldown timer of one day, during which time they will not sell Blue Moon Ice Cream not matter how many times you reset. However, if you save *before* speaking to them, you can reset the game until they are carrying Blue Moon Ice Cream. It is too expensive for us right now by far, but should you ever want to buy it, keep this trick in mind.

Talk to the girl in front of the big building here, and you'll head in. Welcome to the Grand Hall.

Upstairs, you'll be asked which starter Pokémon you'd like to get. You actually get to choose between 21 starters, or you can let fate decide by using the computer at the top of the room. One amazing thing about Reborn is that you can obtain every single Pokémon in the first seven generations within a single save file of Reborn without trading, and that includes the starters. So, regardless of which you pick, you'll be able to get the other 20 eventually. Your choices are:

- The Grass types: **Bulbasaur**, **Chikorita**, **Treecko**, **Turtwig**, **Snivy**, **Chespin**, **Rowlet**
- The Fire types: **Charmander**, **Cyndaquil**, **Torchic**, **Chimchar**, **Tepig**, **Fennekin**, **Litten**
- The Water types: **Squirtle**, **Totodile**, **Mudkip**, **Piplup**, **Oshawott**, **Froakie**, **Popplio**

Another feature that Pokémon Reborn has is that it doesn't lock each Pokémon's 'hidden' ability behind special methods of obtaining: every Pokémon has an equal chance of having its hidden ability as its normal abilities. That means you can get Intimidate Litten, Sheer Force Totodile, Contrary Snivy, etc. as your starter!

It is ultimately up to you what you choose. Many players recommend Torchic due to its Speed Boost ability, but each starter can be useful in its own way.

If you save in front of the starters (quicksave is, by default, 'D'), you can reset (resetting is, by default, F12. You will become very familiar with this button.) until you get one with satisfactory nature, ability, IV's, and even shininess. The shiny rate in this game is roughly 1 in 91 in this game, so you might just end up with a shiny starter on your first try!

Talk to Ame as soon as you're done, and you'll be taken downstairs and fight your first battle! Don't worry quite yet about the "No Field" note.

!battle(["Cain", :Cain, 0])

Thanks to Hustle, Nidoran has a chance to miss. Use your starter's stat lowering move once if you'd like then spam your attacking move and hopefully you can win. Note that winning this one is not required.

**Relationship Point Choices:**
- Defeat Cain in battle (+1 Cain)

Once you are done with that battle, you'll be healed, then thrust into another battle. This is the first of what are generally referred to in this game as "gauntlets". Although not necessarily intended by the game, it is worth noting that if you spam the quicksave key while a character is moving in the mid-gauntlet cutscenes, you can save between gauntlet battles.

!battle(["Victoria", :Victoria, 0])

You'll be Lv. 6 now if you won the last one. Use a similar strategy and hopefully you'll come out on top. Note that again winning this one is not required.

**Relationship Point Choices:**
- Defeat Victoria in battle (+1 Victoria)

After the battle, Ame will give you the *Pokédex*, the *Pokégear*, and the *Running Shoes*! Plus, Victoria will give you 5 *Poké Balls*.

Now, we can explore the Grand Hall. This is the region's hub building - we will be checking back here often.

Talk to the guy in the top left - he will tell us about the password *litemode*. We can't enter new passwords right now, but we will be able to later.

A guy behind the desk will allow us to bring in grinding trainers to the grand hall. Let them in if you'd like, but note that right now they're a bit too tough for us. We can come back a bit before the gym leader to grind against them later.

Talk to a guy next to some display cases if you'd like to buy some candy.

**Grand Hall Common Candy Shop**

!shop("Grand Hall Candy Shop", ["Common Candy"])

As you might guess, Common Candies are the opposite of rare candies - they'll decrease your Pokémon's level. Reborn's disobedience system means that Pokémon above the level cap will not always obey your commands, so these are essential to fix that issue. The current level cap is 20 - until we beat the gym leader, Pokémon won't obey at Lv. 21 and beyond. We shouldn't need any common candies right now though. To his right is another shop:

**Default Shop**

!shop("Default Mart (0 Badges)", ["Potion", "Antidote", "Poké Ball"])

In this guide I will be catching every single Pokémon as soon as it becomes available, so if you're going to do the same you're gonna need a lot of balls. Note that you get a *Premier Ball* with every 10 balls you purchase. Reborn is tight on money, so especially if you're not interested in using healing items during battles, you might be better off not spending your cash on Potions and Antidotes and running back to Pokémon Centers when needed instead.

You can also get a single *Potion* in the PC storage.

On your way out the door, you'll see two people right by the exit. One of them will offer you a Pokémon for $500. But when you do, someone will steal it! If you want to skip this event for now until you have more money you can - we won't actually get to have this Pokémon for... 14 more badges.

That's all we can really do in the Grand Hall for now, so head outside.

## Opal Ward

To the right is a trainer.

!battle(["Jonathan", :TechNerd, 0])

Anyways, there is grass here, which means we can obtain new team members!

**Opal Ward**

!enc(29, ["Headbutt"])

Specifically I recommend training up Bidoof as soon as possible - it gets Headbutt at Level 13, which allows you to catch Pokémon in trees. We will also be able to trade away Bibarel for a different Pokémon pretty soon, so that's something to keep in mind. There is also an in-game trade for Watchog a little bit down the road, so you may want to consider at least catching a Patrat for now.

On the left side of the area, in the left broken statue you'll find a hidden *Green Shard*.

Talk to the trainer here with the Snubbull or Stufful, and they will leave. Back at the bottom of the area, you'll now be able to fight trainers to get onto Opal Bridge. The trainers, going clockwise starting to the left:

!battle(["Paul", :YOUNGSTER, 0])

!battle(["Andreas", :StreetRat, 0])

!battle(["Norman", :GENTLEMAN, 0])

!battle(["Claudette", :BEAUTY, 0])

!battle(["Eric", :COOLTRAINER_Male, 0])

For beating both of the trainers at the bottom of the stairs, you'll get an *Exp. Candy XS*. There are also some hidden items on the bridge:

!img("hidden002.png")

- (A): *Awakening*
- (B): *Blue Shard*
- (C): *Antidote*

In the top right, you'll find three bullies.

!battle(["Randy", :YOUNGSTER, 0])

You'll need two Pokémon to be able to fight the last two, so catch a second if you haven't yet.

!battle(["Jackson", :COOLTRAINER_Male, 0], nil, ["Mack", :StreetRat, 0])

When you win, you'll get **Pachirisu** or **Zigzagoon**, randomly determined. Note that whenever there is a random event like this, you will be able to get the other Pokémon later in the game (here is where the monotype passwords would come into play: the *monoelectric* password would guarantee Pachirisu, for example, while *mononormal* would guarantee Zigzagoon).

If you got Zigzagoon, you can train that up instead of Bidoof if you'd like for Headbutt, which it learns at level 11. Also, it might be worthwhile to save before you get the Pokémon: both of these can have the Pickup ability, which can be incredible in Pokémon Reborn. [Click here for details about Pickup in Reborn.](https://www.rebornevo.com/pr/pickup/)

That's it for Opal Ward for now, so head back towards the train station.

## Lower Peridot Ward

In the Lower Peridot Ward, things have opened up! To the left is a trainer.

**Doxy Lindsey. Field: No Field**
- Cleffa, Lv. 5, Serious Nature, IVs: 10
- Panpour, Lv. 5, Serious Nature, IVs: 10

Next, head right then up as soon as you can.

!img("hidden003.png")

A rock on the left side will contain a hidden *Escape Rope* (A). Talk to the guy here, and give him $150 total. We can't do anything in the house behind him quite yet, so head up from here.

You'll find a gym here. We can't go in yet, but if you go up and around to the right, you'll find a *Gift Box*.

Also, specifically when the weather is thunderstorming, you'll find **Blitzle** here. Since it's Lv. 15 it might be a bit too tough to deal with right now, so you can come back later. Note that this is the first encounter that is only possible with the right weather - if you'd like to avoid having to wait you can use the *weathermod* password at your next opportunity.

To the left, there is a Pokémon Center, and some hidden items outside.

- (B): *Paralyze Heal*
- (C): *Elemental Seed*

Hang on to the latter for now - it will be useful later on. There is another trainer to the left:

**Casanova Andy. Field: No Field**
- Purrloin, Lv. 8, Serious Nature, IVs: 10
    - Scratch
    - Scratch
    - Scratch
    - Growl

A riveting moveset.

In the nearby house, you can take a quiz to find out what types of Pokémon you'd be. It's quite long, but a fun time. You'll also be given a *Type Gem* corresponding to the type you get, as well as learn about the *mono[type]* password.

Anyways, go down and right from here.

**Doxy Hera. Field: No Field**
- Igglybuff, Lv. 5, Serious Nature, IVs: 10
- Ducklett, Lv. 6, Serious Nature, IVs: 10

**Casanova Saad. Field: No Field**
- Pansage, Lv. 7, Serious Nature, IVs: 10

During a clear daytime, you'll find a Teddiursa! It will run off and we'll have to chase it.

Go left from this area and enter the first house that you can. Inside, you'll find a *PokéSnax*! This item is crucial for getting certain Pokémon.

More hidden items around here include:

- (D): *Purple Shard*
- (E): *Exp. Candy XS*
- (F): *Common Candy*

With the PokéSnax in our bag, we can talk to the northernmost dumpster here to catch **Gulpin**. Inside the house, also thanks to the snax, you'll be able to catch **Whismur**.

Return to the guy we gave money to - behind him in a house you will find **Minccino** or **Espurr**, randomly determined. With the snax in your bag, it will join you!

On the left side of the Pokémon Center, you can find a hidden *Poison Gem* in some trash paper (G). In a house below, a guy will give you the *Old Rod*!

Back outside, we can actually fish in the dirty water.

**Lower Peridot Ward / Peridot Ward**

|Old Rod           |%  |
|------------------|---|
|**Grimer**        |100|

You can talk to the group below if you'd like, but you can't do anything here quite yet. To the right, you'll find a building to the left and up of the snax house. Inside, you'll be able to battle a guy.

**Fisherman Morey. Field: No Field**
- Goldeen, Lv. 10, Serious Nature, IVs: 10

If you win, he'll let you into his pool, where you can find a *Sea Incense*.

**Peridot Ward Pool**

|Old Rod           |%  |
|------------------|---|
|**Goldeen**       |70 |
|**Finneon**       |30 |

Head out, and back up past the rod guy's house. You'll find the Name Rater's house here... made obsolete by being able to change a Pokémon's nickname from your party!

!img("hidden004.png")

- (A): *Heart Scale*
- (B): *Purple Shard*

If it is still a clear daytime, here you'll be able to talk to Teddiursa again, who will run off to a random location. I will cover all the locations later on, but keep in mind finding it three times from here will allow you to battle and catch it.

Enter the building here and talk to the old man for a battle.

**Elder Seacrest. Field: No Field**
- Caterpie, Lv. 9, Serious Nature, IVs: 10
- Wurmple, Lv. 9, Serious Nature, IVs: 10
- Weedle, Lv. 9, Serious Nature, IVs: 10

If you win, you'll be able to enter his garden.

**Lower Peridot Ward / Peridot Ward**

|Land (Morning)    |%  |Land (Day)        |%  |Land (Night)      |%  |
|------------------|---|------------------|---|------------------|---|
|**Ledyba**        |30 |**Caterpie**      |30 |Hoothoot          |30 |
|**Cherubi**       |24 |**Wurmple**       |30 |Spinarak          |24 |
|**Wurmple**       |20 |**Sunkern**       |30 |**Wurmple**       |20 |
|**Caterpie**      |20 |**Cherubi**       |10 |**Caterpie**      |20 |
|**Sunkern**       |6  |                  |   |**Sunkern**       |6  |

There is a trade for Sunkern we can do later on, so I recommend catching one.

Next, head to the right. Enter the first building here. You'll find out about an injured Skitty - when we get an Oran Berry we will be back. Head outside and go right.

**Doxy Marigold. Field: No Field**
- Pikipek, Lv. 5, Serious Nature, IVs: 10
- Bounsweet, Lv. 7, Serious Nature, IVs: 10
    - Splash
    - Play Nice
    - Rapid Spin
    - Rapid Spin

Once you beat her, talk to her again for a *Rose Incense*! More hidden items:

- (C): *Antidote*
- (D): *Paralyze Heal*

Up from here, enter the building on the right. Talk to the guy here and give him the Gift Box we found earlier, and you'll obtain a **Delibird**! The building to the right of this one contains an ailing **Kricketot** which you can obtain by talking to the person here.

**Relationship Point Choices:**
- Accept Kricketot (+1 Shelly)
- Reject Kricketot (-1 Shelly)

Kricketune with its Fury Cutter attack and Technician ability can be incredible in the early game, so consider using it.

Back outside, talk to the yellow haired guy for a battle.

**Hotshot Seth. Field: No Field**
- Wimpod, Lv. 10, Serious Nature, IVs: 10

When you beat him you can access the Lower Peridot Alley.

**Lower Peridot Alley**

|Cave              |%  |
|------------------|---|
|**Trubbish**      |60 |
|**Stunky**        |22 |
|**Poochyena**     |18 |

Poochyena evolves early and can have the Moxie ability, so it can be fantastic in the early game.

**Punk Macy. Field: No Field**
- Buneary, Lv. 7, Serious Nature, IVs: 10

There is a *Super Potion* here as well as some hidden items:

!img("hidden005.png")

- (A): *Dark Gem*
- (B): *Potion*

During thunderstorms specifically, you'll be able to get **Tynamo** by talking to the beam.

Head outside and go to the right under the bridge.

**Street Rat Bob. Field: No Field**
- Hoppip, Lv. 5, Serious Nature, IVs: 10
    - Tackle
    - Synthesis
    - Tackle
    - Tackle
- Glameow, Lv. 5, Ability: Keen Eye, Bashful Nature
    - Fake Out
    - Scratch

When the weather is rainy, you'll find **Pansear** or **Panpour**, randomly determined. The second from the right box on the bottom row contains a *Purple Shard*. Head to the right.

**Underground Railnet (Opal Area)**

|Cave              |%  |
|------------------|---|
|**Noibat**        |74 |
|**Woobat**        |20 |
|Stunky            |6  |

Woobat can be pretty solid thanks to its Simple ability, and you can evolve it early with enough friendship.

A rock at the top left contains a hidden *Guard Spec*. Once you're done here, head back to the left and go up past Seacrest's Garden to enter the northern part of Peridot Ward.

## Peridot Ward

!img("hidden006.png")

- (A): *Poké Ball*
- (B): *Oran Berry*
- (C): *Ability Capsule*

The Ability Capsule will become unobtainable after some more story events, so grab it while you can. In Reborn, you get to choose the Pokémon's target ability when you use one, including hidden abilities.

With the Oran Berry, we can now enter the house immediately on the right back in Lower Peridot Ward to get **Skitty**. Back up from here there are some trainers.

**Youngster Sid. Field: No Field**
- Hoothoot, Lv. 8, Serious Nature, IVs: 10

**Street Rat Murphy. Field: No Field**
- Ledyba, Lv. 10, Serious Nature, IVs: 10

**Youngster Tony. Field: No Field**
- Kricketot, Lv. 7, Serious Nature, IVs: 10
- Ekans, Lv. 8, Serious Nature, IVs: 10

Also, another few hidden items:

- (D): *Burn Heal*
- (E): *Red Shard*

The in-game trade I mentioned earlier is in the nearby house, but we probably aren't quite ready for it yet, so head up.

!img("hidden007.png")

- (A): *Blue Shard*
- (B): *Paralyze Heal*

**Street Rat Craig. Field: No Field**
- Noibat, Lv. 8, Serious Nature, IVs: 10

**Youngster Jackie. Field: No Field**
- Zigzagoon, Lv. 10, Serious Nature, IVs: 10

**Youngster Jimmy. Field: No Field**
- Patrat, Lv. 10, Serious Nature, IVs: 10

**Doxy Shawna. Field: No Field**
- Oddish, Lv. 10, Serious Nature, IVs: 10

Talk to the fountain while it is raining to battle **Surskit**!

!img("hidden008.png")

The rock behind the dumpster in the bottom left corner of this plaza contains a *Calcium* (A). I really recommend selling it for a clean $4900 - if you haven't noticed the trainers in this area don't give you much money. Also hidden:

- (B): *Ether*
- (C): *Potion*
- (D): *Red Shard*

Enter the house near the youngsters. Talk to the lady here to begin a quest, then head outside.

Up from here, when the weather is clear or sunny and you have a Rose Incense in your bag, you can talk to **Budew** on the wall to obtain it.

Enter the top left house when you're ready for a battle with the guy who stole our $500 Pokémon! Not just him though, you gotta fight both him and the initial salesman. What a snake!

**Street Rat Arnie & Fisherman Milhouse. Field: No Field**
- Fletchling, Lv. 11, Serious Nature, IVs: 10
- Clauncher, Lv. 11, Serious Nature, IVs: 10

However, they don't actually have our purchased Pokémon, so we'll just have to continue this quest later.

Head down and enter the tall building to your right. Inside, two suspicious people will see you and run off. Back in the Igglybuff lady's house you'll have to defeat them.

**Meteor Grunt Geoff & Meteor Grunt Audrey. Field: No Field**
- Duskull, Lv. 11, Serious Nature, IVs: 10
- Cubone, Lv. 11, Serious Nature, IVs: 10

Once you do, you can get **Igglybuff**! It's worth noting that she will eventually ask for this specific Igglybuff back later in the game; for a reward, you'll need to give it back. So, consider breeding it once we get daycare access if you want to use Wigglytuff.

Anyways, to the right of the tall building you can defeat another blonde haired guy to get access to another alleyway.

**Hotshot Roger. Field: No Field**
- Sandshrew, Lv. 8, Serious Nature, IVs: 10
- Diglett, Lv. 9, Serious Nature, IVs: 10

**North Peridot Alley**

|Cave              |%  |
|------------------|---|
|Trubbish          |45 |
|Poochyena         |34 |
|**Purrloin**      |21 |

**Street Rat Reginald. Field: No Field**
- Scatterbug, Lv. 7, Serious Nature, IVs: 10
- Nidoran F., Lv. 9, Serious Nature, IVs: 10

**Street Rat Erick. Field: No Field**
- Weedle, Lv. 9, Serious Nature, IVs: 10
- Pineco, Lv. 9, Serious Nature, IVs: 10

!img("hidden009.png")

- (A): *Repel*
- (B): *Green Shard*

Our first *Data Chip* is above. You can use it to add a password at any PC!

Outside, enter the small building to the left and pickup the *Potion*. Outside, head straight to the left. We will traverse this loop clockwise. Enter the first building you come upon. At night, you can catch **Grubbin** or **Joltik**, randomly determined. Note that this will use up one of your snax, so you'll need to buy more to do other snax-related events. Inside the next building to the left is another *Common Candy*.

**Street Rat Charlie. Field: No Field**
- Salandit, Lv. 10, Serious Nature, IVs: 10

To the left is a Pokémart. The "Default Shops" in this game operate similarly to main Pokémon game shops in that they update their inventory based on how many badges you have - the Peridot Ward shop will have the same inventory as the Grand Hall shop until we get a badge, then they will both upgrade, for example.

Anyways, a small house up from here contains a *Protein*, which again I recommend selling for more ball money.

**Youngster Marshall. Field: No Field**
- Surskit, Lv. 12, Serious Nature, IVs: 10

In the building up and left from here, you can talk to a guy to get a *Common Candy*. Outside, during clear or sunny days, there is a shop.

**Peridot Ward Snax Shop**

|Item       |Price      |
|-----------|-----------|
|*PokéSnax* |$650       |

If you use up your PokéSnax and need more, this is the place. Head to the right and enter the "Jasper" gate. You can find a *Genius Wing* in a rock but otherwise can't proceed. Back in Peridot, go right.

**Punk Trill. Field: No Field**
- Spinarak, Lv. 9, Serious Nature, IVs: 10
- Cutiefly, Lv. 9, Serious Nature, IVs: 10

!img("hidden010.png")

- (A): *Common Candy*
- (B): *Potion*
- (C): *Clever Wing*
- (D): *Green Shard*
- (E): *Purple Shard*
- (F): *Blue Shard*
- (G): *Common Candy*

When you're ready, talk to the green haired guy for a battle.

**Swag Jockey Fern (Potion). Field: No Field**
- Budew, Lv. 13, @Oran Berry, Ability: Poison Point, IVs: 10
    - Mega Drain
    - Natural Gift
    - Stun Spore
    - Covet
- Sandile, Lv. 13, Ability: Moxie, IVs: 10
    - Power Trip
    - Snatch
    - Rage
    - Sand Tomb
- Rowlet, Lv. 14, Ability: Overgrow, IVs: 15
    - Leafage
    - Peck
    - Ominous Wind
    - Confuse Ray

This one is a bit harder than the first two rival fights! Watch out for his Budew, who likes to heal, and his Sandile who can rip through your team of six thanks to Moxie if you're not careful. His Rowlet also may juggernaut with a couple of Ominous Wind boosts, so be cautious of those as well. The Delibird we got earlier can shine in this battle (and arguably only this battle...)!

Around this time, your Zigzagoon/Bidoof will be able to learn Headbutt, so there are a few Pokémon you can now obtain. First, head to the garden:

**Lower Peridot Ward / Peridot Ward**

|Headbutt          |%  |
|------------------|---|
|**Swablu**        |55 |
|**Burmy**         |45 |

Note that we will eventually want a Mothim for an in-game trade, so ensure you catch a Male Burmy at some point. Next, head back to Opal Ward.

**Opal Ward**

|Headbutt          |%  |
|------------------|---|
|**Pineco**        |40 |
|**Spearow**       |30 |
|**Combee**        |30 |

Now is a good time to finish the Teddiursa quest if you haven't already. Keep in mind this has to be done on a clear day. After talking to it in the bottom part of the Lower Peridot Ward and then again on the left side near the Name Rater's house, you'll need to find it three more times. It can be found in one of the following locations, then will be found in the two after it in the list (cyclically).

1. Nearby the train station, where we started the game.
2. Under the Opal Bridge, nearby Panpour/Pansear.
3. Above Mosswater Industrial in between two buildings.
4. Next to the Upper Peridot Ward Pokémart.
5. Next to the rock containing the Calcium near the fountain.
6. Nearby the dumpster where we got Gulpin.
7. In the bottom left corner of Seacrest's garden.

**Teddiursa** will then battle you.

With that out of the way, time to progress the story. Make sure you have your best team for some battles coming up.

You have to two choices: you can head straight to the Mosswater Industrial above Seacrest's Garden, or take a detour first to the Lower Peridot Ward gym. In either case, talk to the character standing in front of the factory when you're ready.

**Relationship Point Choices:**
- Headed straight to Mosswater Industrial (Fern +1)
- Detoured to Lower Peridot Gym before going to Mosswater (Julia +1)

## Mosswater Industrial

Time for our first dungeon proper! Fern will join us as a partner. Leaving your partner and exiting dungeons tend to have negative effects:

**Relationship Point Choices:**
- Leave Fern and exit the factory (-1 Fern, just once)

However, talking to your partner while they're walking with you tends to have positive effects:

**Relationship Point Choices:**
- Talk to Fern while you are together (+1 Fern, just once)

Partners also fully heal your team after every battle, which can be useful for grinding.

Enter the next room and talk with Ace. We'll be wandering around the factory, defeating Team Meteor Grunts and looking for codes. Start by going left.

**Meteor Grunt Mary & Meteor Grunt Coleman. Field: Factory Field**
- Roggenrola, Lv. 13, Serious Nature, IVs: 10
- Bounsweet, Lv. 13, Serious Nature, IVs: 10

Across the bridge, you'll see one flashing terminal: XX7X. Continue up from here.

**Meteor Grunt Hilda & Meteor Grunt Ricardo. Field: Factory Field**
- Zubat, Lv. 12, Serious Nature, IVs: 10
- Aron, Lv. 12, Serious Nature, IVs: 10

In the top left you'll find another terminal: X1XX. The three terminals nearby give us some lore that will be relevant later. Head right.

**Meteor Grunt Sanchez & Meteor Grunt Devin. Field: Factory Field**
- Tympole, Lv. 12, Serious Nature, IVs: 10
- Geodude-Alola, Lv. 12, Serious Nature, IVs: 10

A terminal to the right shows 3XXX. Down from here are more grunts.

**Meteor Grunt Bruno & Meteor Grunt Ray. Field: Factory Field**
- Lillipup, Lv. 12, Serious Nature, IVs: 10
- Rattata-Alola, Lv. 12, Serious Nature, IVs: 10

Head to the top right corner of the room to fight more grunts.

**Meteor Grunt Simon & Meteor Grunt Tara. Field: Factory Field**
- Grimer-Alola, Lv. 13, Serious Nature, IVs: 10
- Zubat, Lv. 12, Serious Nature, IVs: 10

Read the nearby terminal, which shows XXX9. Read the other two terminals nearby for more lore, then head down to the elevator and type in our now completed password.

**Relationship Point Choices:**
- Push the same elevator button as the floor you are on (-1 Fern)

On the second floor, Rini will start us off with part of the second password: XX6X. Before we proceed, head out the door on the bottom right and follow the path to get an *Exp. Candy S*. Back in the main room, head out to the right and cross the bridge.

**Meteor Grunt Winter & Meteor Grunt Michaela. Field: Factory Field**
- Beldum, Lv. 12, Serious Nature, IVs: 10
- Stunky, Lv. 12, Serious Nature, IVs: 10

Interact with the terminal here to get the hint XXX2, and the other for lore. Head out to the left, and down at the first opportunity.

**Meteor Grunt Demian & Meteor Grunt Antoine. Field: Factory Field**
- Venonat, Lv. 12, Serious Nature, IVs: 10
- Poochyena, Lv. 12, Serious Nature, IVs: 10

In this room, use the terminal to discover the hint X8XX. Back outside, go left.

**Meteor Grunt Janis & Meteor Grunt Grant. Field: Factory Field**
- Minior, Lv. 13, Serious Nature, IVs: 10
- Crabrawler, Lv. 13, Serious Nature, IVs: 10

In here is another terminal: 4XXX, plus one more with some lore. You can also get a hidden *Super Potion* in a box at the bottom. Back outside again, go up at the bridge, pickup *Paralyze Heal*, type in the code and head in.

**Meteor Grunt Rod & Meteor Grunt Ringo. Field: Factory Field**
- Solrock, Lv. 13, Serious Nature, IVs: 10
- Lunatone, Lv. 13, Serious Nature, IVs: 10

Pickup the explosives! Back in the central room, choose which of the two characters to talk to.

**Relationship Point Choices:**
- Talk to Julia after getting the boomies (+1 Julia, -1 Florinia)
- Talk to Florinia after getting the boomies (-1 Julia, +1 Florinia)

Either way, head in to the room at the top when you're ready for a fight.

**Meteor Private Aster & Meteor Private Eclipse. Field: Factory Field**
- Rockruff, Lv. 16, Ability: Steadfast, IVs: 31
    - Thunder Fang
    - Howl
    - Bite
    - Rock Throw
- Rockruff, Lv. 16, Ability: Vital Spirit, IVs: 31
    - Fire Fang
    - Howl
    - Bite
    - Rock Throw

Depending on what Pokémon you have this can be a bit difficult since they like to one-shot Fern's Budew, but your sheer numbers can probably overwhelm them regardless.

Outside the factory, Florinia will ask you a question.

**Relationship Point Choices:**
- Yes (+1 Florinia)

You will then be given the Field Notes App in your Pokégear, and offered to turn on a graphical feature that shows off field effect boosts in battle. I recommend doing this! You will also be given the *Electric Terrain Readout*. You may have noticed we were battling on the Factory Field inside Mosswater. Most of the important trainers in this game we will be fighting on these custom field effects, so the Field Notes will be very helpful.

Before we continue with the story, there are a couple quests we can take care of now.

Go to the factory area where we first met Fern, and talk to the scientist guy on the right side of the factory. He will give us the *Factory Field Readout*, so now we have more details whenever we have battles on the Factory Field that was in Mosswater.

Head down and talk to the purple haired guy above the destroyed train station. A hotshot will steal his painkillers! Follow him inside the North Peridot Alley, where you can fight him.

**Hotshot Stiles. Field: No Field**
- Timburr, Lv. 15, Serious Nature, IVs: 10
- Baltoy, Lv. 15, Serious Nature, IVs: 10
- Skiploom, Lv. 16, Serious Nature, IVs: 10

Return to the guy who will give you 5 *Exp. Candy S*. Nice.

## Grand Hall Trainers 1

Now is a good time to mention the Grand Hall repeatable grinding trainers in the top right corner. Each day of the week, different trainers will be available for grinding. At set points in the game, the trainers will get stronger and their rewards better. For now, each trainer will give you 2 *Exp. Candy S* when you defeat them, useful for bringing your levels up. The game will also heal your party after defeating one to save time! The trainers are as follows:

**Arcade Star Carol (SUN). Field: No Field**
- Totodile, Lv. 10, Serious Nature, IVs: 10
- Sentret, Lv. 10, Serious Nature, IVs: 10
- Chikorita, Lv. 10, Serious Nature, IVs: 10

**Hotshot Fawkes (SUN). Field: No Field**
- Froakie, Lv. 14, Serious Nature, IVs: 10

**Casanova Gibson (SUN). Field: No Field**
- Kabuto, Lv. 14, Serious Nature, IVs: 10

**Youngster Jonah (MON). Field: No Field**
- Squirtle, Lv. 14, Docile Nature, IVs: 15

**Hotshot Jace (TUE). Field: No Field**
- Drifloon, Lv. 12, Serious Nature, IVs: 10

**Psychic Silva (WED). Field: No Field**
- Natu, Lv. 12, Serious Nature, IVs: 10

**Elder JB (THU). Field: No Field**
- Froakie, Lv. 11, Serious Nature, IVs: 10
- Fennekin, Lv. 11, Serious Nature, IVs: 10

**Techie Will (FRI). Field: No Field**
- Treecko, Lv. 10, Serious Nature, IVs: 10
- Charmander, Lv. 10, Serious Nature, IVs: 10

**Elder Anthony (SAT). Field: No Field**
- Rufflet, Lv. 12, Serious Nature, IVs: 10

**Hotshot Emile (SAT). Field: No Field**
- Nidoran M., Lv. 14, Serious Nature, IVs: 10

**Casanova Zach & Lady Beau (SAT). Field: No Field**
- Bulbasaur, Lv. 11, Serious Nature, IVs: 10
- Solosis, Lv. 12, Serious Nature, IVs: 10
- Jigglypuff, Lv. 12, Serious Nature, IVs: 10
- Togepi, Lv. 12, Serious Nature, IVs: 10

Use the trainers as you'd like to prepare for the gym.

By now hopefully you've been able to evolve your Bidoof into **Bibarel** at Lv. 15. If so, head into the house across from Mosswater to do an in-game trade for **Munna**!

## Volt Badge

Enter the Neo-Circuit Power-Plant gym when you're ready. The puzzle is simple: beat a trainer, talk to Voltorb, talk to the metal grate standing in your way.

**Techie Ivan. Field: Factory Field**
- Voltorb, Lv. 11, Serious Nature, IVs: 10
- Voltorb, Lv. 11, Serious Nature, IVs: 10

**Techie Bill. Field: Factory Field**
- Mareep, Lv. 14, Serious Nature, IVs: 10

**Hotshot Lennon. Field: Factory Field**
- Shinx, Lv. 12, Serious Nature, IVs: 10

**Techie Yan. Field: Factory Field**
- Tynamo, Lv. 14, Serious Nature, IVs: 10

Study the Electric Terrain Field Notes and talk to the gym leader when you're ready.

**Cheer Captain Julia (2x Potion). Field: Electric Terrain.**
- Minun, Lv. 12, Ability: Minus, Modest Nature, IVs: 10
    - Nuzzle
    - Charge Beam
    - Encore
    - Quick Attack
- Geodude-Alola, Lv. 12, Ability: Galvanize, Adamant Nature, IVs: 20
    - Self-Destruct
    - Tackle
    - Charge
    - Rollout
- Voltorb, Lv. 12, Ability: Aftermath, Adamant Nature, IVs: 20
    - Explosion
    - Rollout
    - Charge Beam
    - Sonic Boom
- Plusle, Lv. 13, Ability: Lightning Rod, Modest Nature, IVs: 10
    - Nuzzle
    - Charge Beam
    - Encore
    - Quick Attack
- Oricorio-Pom-Pom, Lv. 14, Ability: Dancer, Quirky Nature, IVs: 10
    - Work Up
    - Tailwind
    - Pound
    - Air Cutter
- Electrode, Lv. 15, Ability: Aftermath, Bashful Nature, IVs: 24
    - Charge Beam
    - Sonic Boom
    - Rollout
    - Charge

Pokémon Reborn's first gym leader comes in pretty hot. You'll notice that she mostly uses two strategies across her team: stacking Special Attack with Electric Terrain boosted Charge Beam, and wearing out your Lv. 20 and under Pokémon quickly with Sonic Boom. Her Electrode is very fast, and can employ both of these strategies effectively and then take out a chunk of your HP on the way out with Aftermath. Geodude and Voltorb also like to explode, and since the former's is boosted by STAB, Galvanize, and the field... it's gonna hurt. Oricorio can hit hard and boost the speed of the entire team for a few turns, and also punishes your Grass-type starter.

Her team luckily isn't super bulky, so trying to get something going with your own sweepers might be the key. Kricketune and Mightyena can really shine here, as well as your second stage starter especially with Torrent / Blaze / Overgrow. Elemental Seeds boost speed on this field, which can be key to getting momentum with your sweeper. Reborn doesn't always force you to keep the default field around, however: if you have Zigzagoon, you can use Mud Sport to destroy the field, making things a bit more even for you.

Once you emerge victorious, you'll be given the *Volt Badge* as well as *TM57 Charge Beam*. TM's are infinite-use, so feel free to slap it on anything that can learn it. You also get to go up to Lv. 25 now! Great job completing section 1 of Pokémon Reborn!
