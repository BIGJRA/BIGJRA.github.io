# Postgame Episode 1: A Whole New World

Bear with me: postgame is less episodically structured than the main game, and there aren't chapter names. So, I came up with my own names, with help from the Patreon Discord.

## The Developer Room

If this is the kind of thing that would interest you, enter the developer's room by talking to Ame's computer in the Grand Hall Basement. You can talk to the developers in here, though note that nothing in here is canon to Reborn.

Anyways, the first thing we're going to do is grab the fourth Catching Charm. Make a beeline to the room in the top right corner to grab the *Catching Charm: Sapphire*!

There is a case to be made that you should save actually talking to all these NPC's and reading the content here until after you've also beaten the postgame, though I will cover the currently available contents here regardless. You can battle the folks here optionally just for fun they'll give us BP for the Nightclub, which we'll get to in a bit. - they don't give any EXP and lock all levels to 100. They also use a ton of illegal movesets and some have custom abilities and typings.

!battle(["Autumn", :AUTUMN, 0], "Rainbow Field")

!battle(["Ikaru", :IKARU, 0])

!battle(["Smeargletail", :SMEARGLE, 0])

!battle(["Jan", :JAN, 0], "Glitch Field")

Jan? Wait, I know that guy from Rejuvenation!

!battle(["Marcello", :MARCELLO, 0])

!battle(["Perry", :PERRY, 0])

!battle(["Vulpes", :VULPES, 0], "Fairy Tale Arena OR Starlight Arena")

You can also talk to Vulpes to unlock an alternate fight with their Animations team.

!battle(["Vulpes", :VULPES, 1], "Fairy Tale Arena OR Starlight Arena")

!battle(["Azzie", :AZZIE, 0])

!battle(["Crim", :CRIM, 0], "Starlight Arena")

!battle(["Cass", :CASS, 3])

You can talk to Cass about Ame to talk to Ame and battle her as well:

!battle(["Amethyst", :AME, 1])

Of course, the one and only:

!battle(["Kyra", :KYRA, 0])

Talking to the graves and papers in the backroom will also allow us to fight more former developers:

!battle(["Lia", :SPIRITF, 0])

!battle(["Azery", :SPIRITM, 0])

!battle(["Kurotsune", :KUROTSUNE, 0])

!battle(["Dan", :SPIRITM, 0])

!battle(["Mike", :SPIRITM, 0])

!battle(["MDE", :SPIRITM, 0])

!battle(["Kanaya", :SPIRITF, 0])

!battle(["Koyo", :SPIRITF, 0])

It's also worth noting at this point that the level cap has silently gone up to Lv. 105!

## The Nightclub

Head over to North Obsidia Ward - we can finally enter the nightclub!

Once you talk to Arclight, you'll be free to move around. If you talk to the machine to the left of the nerd at the top, you can turn the chaotic lights off, if you'd like. Talk to the nerd here to record Pokemon's movesets - by doing this, you can save time (and Heart Scales) from having to visit tutors.

Talk to the various characters around the nightclub, if you'd like.

In the top left corner, there are various battle facilities. Winning them grants you Battle Points (BP) which can be exchanged for items.

!shop("Nightclub BP Rewards (Bottom)", [    ["Lonely Mint", "1 BP"], ["Brave Mint", "1 BP"], ["Adamant Mint", "1 BP"], ["Naughty Mint", "1 BP"], ["Bold Mint", "1 BP"], ["Relaxed Mint", "1 BP"], ["Impish Mint", "1 BP"], ["Lax Mint", "1 BP"], ["Timid Mint", "1 BP"], ["Hasty Mint", "1 BP"], ["Serious Mint", "1 BP"], ["Jolly Mint", "1 BP"], ["Naive Mint", "1 BP"], ["Modest Mint", "1 BP"], ["Mild Mint", "1 BP"], ["Quiet Mint", "1 BP"], ["Rash Mint", "1 BP"], ["Calm Mint", "1 BP"], ["Gentle Mint", "1 BP"], ["Sassy Mint", "1 BP"], ["Careful Mint", "1 BP"]])

!shop("Nightclub BP Rewards (Middle)", [["Choice Band", "24 BP"], ["Choice Specs", "24 BP"], ["Choice Scarf", "27 BP"], ["Focus Sash", "5 BP"], ["EXP All Upgrade", "1 BP"], ["Remote PC", "14 BP"], ["5 Cell Batteries", "5 BP"]])

Note that the Remote PC is only available after buying the EXP All Upgrade, and the batteries only after the PC.

!shop("Nightclub BP Rewards (Top)", [["8 Exp. Candy XL", "1 BP"], ["50 Exp. Candy XL", "5 BP"], ["Ability Capsule", "1 BP"], ["2 Heart Scales", "2 BP"], ["Rare Candy", "1 BP"], ["3 EV Tuners", "2 BP"], ["2 EV Boosters", "3 BP"], ["PP All", "4 BP"], ["Reborn Ball", "9 BP"], ["10 Glitter Balls", "5 BP"], ["Sacred Ash", "13 BP"]])

To win BP, you can participate in the Nightclub's Battle Pavilion: Battle Tower and Battle Factory-style competitions, Theme Teams, and Mix N' Match. Try out these options and earn some BP if you'd like, or skip ahead to [the next section](#vanhanen-castle-new-world) to continue the postgame story.

## Battle Pavilion Facilities

The Battle Tower and Battle Factory modes work similarly to canon: the former lets you bring a team of three and the latter has you choose randomly from a pool. In these modes you can optionally choose to enable random field effects as well.

Challenges in the Tower and Factory are sets of five battles: losing a set rewards the player with *BP* equal to the number of battles won. If the player wins the set of five, *BP* is awarded as follows: `BP = w // 2 + 5 + 3RF + 3DB`, where `w` is the current win streak, `RF` is Random Fields being enabled and `DB` is doubles being enabled.

For the first four fights of each set in the Tower and all battles in the Factory, specific Pokemon sets as well as Trainer information for these facilities can be found within the `btpokemon.rb` and `bttrainers.rb` files in the game's `Scripts` directory.

The final fight of each Battle Tower set is against an NPC boss. Note the opponents' *default* fields can be overwritten if the random field option is on. Here are the boss battles for singles:

!btsinglesboss()

Here are the boss battles for doubles:

!btdoublesboss()

Theme Teams allows you to fight the game's NPCs with specific themed teams - beating them (except Julia's "Kaboom" team) will award you *4 BP*.

Mix N' Match allows you to do 2v2 fights of these NPC teams: you get to pick a partner and fight two selected opponents. Note that you can only select partners with which you have a certain amount of relationship points with. Every Mix N' Match fight awards *4 BP*, though choosing random partner/enemies will award *8 BP* instead.

*Note that certain trainers will not be available during certain story events for Theme Teams and Mix N' Match*. Regardless, listed in full, the pool of Theme Teams and Mix N' Match trainers is as follows:

!ttbattles()

## Vanhanen Castle New World

On the right side of the room, talk to Cass.

**Relationship Point Choices:**
- Tell Cass you aren't ready to start your first postgame quest repeatedly (-1 Noel, -1 Serra)

She will give us our first of many legendary quests: we're wanted in Vanhanen Castle!

Fly over to Vanhanen Castle and go in. Where we once fought Cain, you'll see a New World Door on the second level. Head in.

!enc(831, nil, nil, "New World (Vanhanen Castle)")

Enter the door in the top right, follow the path, and talk to the orb. Return to the New World hub. This time, follow the door in the top left. Talk to the orb at the end and return. Finally, go to the bottom right and talk to the Shiinotic.

!battle(["Pokemon", :SHIINOTIC, 0], "Chess Board")

Talk to the next orb. The door at the top of the hub will now be open: follow it and defeat another Shiinotic. Grab the next orb.

Back in the hub, enter the top right room once more. The door at the top will now be unlocked, so follow it in.

!battle(["Cresselia", :CRESSELIA, 0], "New World")

Our first Anomaly battle! Note that this another fight on the New World field. The first four Pokemon use this field beneficially to some extent, but Ice and field-boosted Dark moves can generally shut them down. The first Cresselia will always use Lunar Dance, sacrificing itself to give an omniboost to the second Cresselia. Note the Magical Seed, meaning the second Cresselia will always get two omniboosts, but will need to recharge on the first turn it is out. That means you can use Toxic, Psych Up, Haze, Trick Room, etc. for free and whittle it down with the remainder of your team.

Once you win, you'll be immediately thrown into a battle with a wild **Cresselia**, which you can now catch. Don't worry, this fight is much easier than the previous, you just have to catch it. It's worth noting that you can often mash the auto-save key (default 'D') between the Anomaly battle and the legendary fight if you want. You can also grind the Nightclub facilities to get Reborn Balls if catching the legendaries is too much of a pain.

Luna will give us the *Gather Cube* afterwards.

Return to the Nightclub!

While you're here, more NPC's will have returned to the nightclub. In particular, you can show Florinia the Naganadel we got earlier (or other Ultra Beasts we'll find later) to get 5 *Beast Balls*.

**Relationship Point Choices:**
- Show Florinia an Ultra Beast (+1 Florinia)

That's it for the first Postgame Episode!
