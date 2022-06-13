MOVEHASH = {
:MEGAHORN => {
	:ID => 1,
	:name => "Megahorn",
	:function => 0x000,
	:type => :BUG,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 85,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "Using a tough and impressive horn, the user rams into the target with no letup."
},

:ATTACKORDER => {
	:ID => 2,
	:name => "Attack Order",
	:function => 0x000,
	:type => :BUG,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:highcrit => true,
	:desc => "The user calls out their underlings to pummel the target. Critical hits land more easily."
},

:BUGBUZZ => {
	:ID => 3,
	:name => "Bug Buzz",
	:function => 0x046,
	:type => :BUG,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 10,
	:target => :SingleNonUser,
	:soundmove => true,
	:desc => "The user generates a damaging sound wave by vibration. This may also lower the target's Sp. Def stat."
},

:XSCISSOR => {
	:ID => 4,
	:name => "X-Scissor",
	:function => 0x000,
	:type => :BUG,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user slashes by crossing their scythes or claws as if they were a pair of scissors."
},

:SIGNALBEAM => {
	:ID => 5,
	:name => "Signal Beam",
	:function => 0x013,
	:type => :BUG,
	:category => :special,
	:basedamage => 75,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks with a sinister beam of light. This may also confuse the target."
},

:UTURN => {
	:ID => 6,
	:name => "U-turn",
	:function => 0x0EE,
	:type => :BUG,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "After making their attack, the user rushes back to switch places with a party Pokémon in waiting."
},

:STEAMROLLER => {
	:ID => 7,
	:name => "Steamroller",
	:function => 0x010,
	:type => :BUG,
	:category => :physical,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user crushes the target by rolling over it. This may also make the target flinch."
},

:BUGBITE => {
	:ID => 8,
	:name => "Bug Bite",
	:function => 0x0F4,
	:type => :BUG,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user bites the target. If the target is holding a Berry, the user eats it and gains its effect."
},

:SILVERWIND => {
	:ID => 9,
	:name => "Silver Wind",
	:function => 0x02D,
	:type => :BUG,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 5,
	:effect => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks with powdery scales blown by the wind. This may raise all the user's stats."
},

:STRUGGLEBUG => {
	:ID => 10,
	:name => "Struggle Bug",
	:function => 0x045,
	:type => :BUG,
	:category => :special,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 100,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "While resisting, the user attacks the opposing Pokémon. This lowers the Sp. Atk stat of those hit."
},

:TWINEEDLE => {
	:ID => 11,
	:name => "Twineedle",
	:function => 0x0BE,
	:type => :BUG,
	:category => :physical,
	:basedamage => 25,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 20,
	:target => :SingleNonUser,
	:desc => "The user attacks twice in succession by jabbing with two spikes. This may also poison the target."
},

:FURYCUTTER => {
	:ID => 12,
	:name => "Fury Cutter",
	:function => 0x091,
	:type => :BUG,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 95,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is slashed with scythes or claws. This attack becomes more powerful if it hits in succession."
},

:LEECHLIFE => {
	:ID => 13,
	:name => "Leech Life",
	:function => 0x0DD,
	:type => :BUG,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user drains the target's blood. The user's HP is restored by half the damage taken by the target."
},

:PINMISSILE => {
	:ID => 14,
	:name => "Pin Missile",
	:function => 0x0C0,
	:type => :BUG,
	:category => :physical,
	:basedamage => 25,
	:accuracy => 95,
	:maxpp => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "Sharp spikes are shot at the target in rapid succession. They hit two to five times in a row."
},

:DEFENDORDER => {
	:ID => 15,
	:name => "Defend Order",
	:function => 0x02A,
	:type => :BUG,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user calls out their underlings to shield their body, raising their Defense and Sp. Def stats."
},

:HEALORDER => {
	:ID => 16,
	:name => "Heal Order",
	:function => 0x0D5,
	:type => :BUG,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user calls out their underlings to heal them. The user regains up to half of their max HP."
},

:QUIVERDANCE => {
	:ID => 17,
	:name => "Quiver Dance",
	:function => 0x02B,
	:type => :BUG,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user performs a beautiful, mystic dance. This boosts the user's Sp. Atk, Sp. Def, and Speed stats."
},

:RAGEPOWDER => {
	:ID => 18,
	:name => "Rage Powder",
	:function => 0x117,
	:type => :BUG,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:priority => 3,
	:nonmirror => true,
	:desc => "The user scatters a cloud of irritating powder to draw attention. Opponents aim only at the user."
},

:SPIDERWEB => {
	:ID => 19,
	:name => "Spider Web",
	:function => 0x0EF,
	:type => :BUG,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user ensnares the target with thin, gooey silk so it can't flee from battle."
},

:STRINGSHOT => {
	:ID => 20,
	:name => "String Shot",
	:function => 0x04D,
	:type => :BUG,
	:category => :status,
	:basedamage => 0,
	:accuracy => 95,
	:maxpp => 40,
	:target => :AllOpposing,
	:magiccoat => true,
	:desc => "The opposing Pokémon are bound with silk blown from the user's mouth that harshly lowers the Speed stat."
},

:TAILGLOW => {
	:ID => 21,
	:name => "Tail Glow",
	:function => 0x039,
	:type => :BUG,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user stares at flashing lights to focus their mind, drastically raising their Sp. Atk stat."
},

:FOULPLAY => {
	:ID => 22,
	:name => "Foul Play",
	:function => 0x121,
	:type => :DARK,
	:category => :physical,
	:basedamage => 95,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "Turns the target's power against it. The higher the target's Attack stat, the greater the power."
},

:NIGHTDAZE => {
	:ID => 23,
	:name => "Night Daze",
	:function => 0x047,
	:type => :DARK,
	:category => :special,
	:basedamage => 85,
	:accuracy => 95,
	:maxpp => 10,
	:effect => 40,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user lets loose a pitch-black shock wave at the target. This may lower the target's Accuracy."
},

:CRUNCH => {
	:ID => 24,
	:name => "Crunch",
	:function => 0x043,
	:type => :DARK,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 20,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user crunches up the target with sharp fangs. This may also lower the target's Defense stat."
},

:DARKPULSE => {
	:ID => 25,
	:name => "Dark Pulse",
	:function => 0x00F,
	:type => :DARK,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user releases a horrible aura imbued with dark thoughts. This may also make the target flinch."
},

:SUCKERPUNCH => {
	:ID => 26,
	:name => "Sucker Punch",
	:function => 0x116,
	:type => :DARK,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:priority => 1,
	:contact => true,
	:kingrock => true,
	:desc => "This move enables the user to attack first. It fails if the target is not readying a damaging move."
},

:NIGHTSLASH => {
	:ID => 27,
	:name => "Night Slash",
	:function => 0x000,
	:type => :DARK,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:highcrit => true,
	:desc => "The user slashes the target the instant an opportunity arises. Critical hits land more easily."
},

:BITE => {
	:ID => 28,
	:name => "Bite",
	:function => 0x00F,
	:type => :DARK,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 25,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The target is bitten with viciously sharp fangs. This may also make the target flinch."
},

:FEINTATTACK => {
	:ID => 29,
	:name => "Feint Attack",
	:function => 0x0A5,
	:type => :DARK,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user approaches the target disarmingly, then throws a sucker punch. Never misses."
},

:SNARL => {
	:ID => 30,
	:name => "Snarl",
	:function => 0x045,
	:type => :DARK,
	:category => :special,
	:basedamage => 55,
	:accuracy => 95,
	:maxpp => 15,
	:effect => 100,
	:target => :AllOpposing,
	:kingrock => true,
	:soundmove => true,
	:desc => "The user yells as if ranting about something, lowering the Sp. Atk stat of opposing Pokémon."
},

:ASSURANCE => {
	:ID => 31,
	:name => "Assurance",
	:function => 0x082,
	:type => :DARK,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "If the target has already taken some damage in the same turn, this attack's power is doubled."
},

:PAYBACK => {
	:ID => 32,
	:name => "Payback",
	:function => 0x084,
	:type => :DARK,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user stores power to attack. If the user moves after the target, the move's power will be doubled."
},

:PURSUIT => {
	:ID => 33,
	:name => "Pursuit",
	:function => 0x088,
	:type => :DARK,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The power of this attack is doubled if it is used on a target that is switching out of battle."
},

:THIEF => {
	:ID => 34,
	:name => "Thief",
	:function => 0x0F1,
	:type => :DARK,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 25,
	:target => :SingleNonUser,
	:contact => true,
	:nonmirror => true,
	:desc => "The user attacks and steals the target's item. The item cannot be stolen if the user is holding one already."
},

:KNOCKOFF => {
	:ID => 35,
	:name => "Knock Off",
	:function => 0x0F0,
	:type => :DARK,
	:category => :physical,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user slaps away the target's held item. It deals more damage if the target holds an item."
},

:BEATUP => {
	:ID => 36,
	:name => "Beat Up",
	:function => 0x0C1,
	:type => :DARK,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user's party Pokémon attack. The more party Pokémon, the greater the number of attacks."
},

:FLING => {
	:ID => 37,
	:name => "Fling",
	:function => 0x0F7,
	:type => :DARK,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user flings a held item at the target to attack. This move's power and effects depend on the item."
},

:PUNISHMENT => {
	:ID => 38,
	:name => "Punishment",
	:function => 0x08F,
	:type => :DARK,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The more the target has powered up with stat changes, the greater the move's power."
},

:DARKVOID => {
	:ID => 39,
	:name => "Dark Void",
	:function => 0x003,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 50,
	:maxpp => 10,
	:target => :AllOpposing,
	:magiccoat => true,
	:desc => "Opposing Pokémon are dragged into a world of total darkness that makes them sleep."
},

:EMBARGO => {
	:ID => 40,
	:name => "Embargo",
	:function => 0x0F8,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "Prevents the target from using its item and its Trainer from using items on it for five turns."
},

:FAKETEARS => {
	:ID => 41,
	:name => "Fake Tears",
	:function => 0x04F,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user feigns crying to fluster the target, harshly lowering its Sp. Def stat."
},

:FLATTER => {
	:ID => 42,
	:name => "Flatter",
	:function => 0x040,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "Flattery is used to confuse the target. However, this also raises the target's Sp. Atk stat."
},

:HONECLAWS => {
	:ID => 43,
	:name => "Hone Claws",
	:function => 0x029,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user sharpens their claws to boost their Attack stat and Accuracy."
},

:MEMENTO => {
	:ID => 44,
	:name => "Memento",
	:function => 0x0E2,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:desc => "The user faints. In return, this harshly lowers the target's Attack and Sp. Atk stats."
},

:NASTYPLOT => {
	:ID => 45,
	:name => "Nasty Plot",
	:function => 0x032,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user stimulates their brain, thinking bad thoughts. This sharply raises the user's Sp. Atk stat."
},

:QUASH => {
	:ID => 46,
	:name => "Quash",
	:function => 0x11E,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:desc => "The user suppresses the target and makes its move go last."
},

:SNATCH => {
	:ID => 47,
	:name => "Snatch",
	:function => 0x0B2,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:priority => 4,
	:nonmirror => true,
	:desc => "The user steals the effects of any attempts to use a healing or stat-changing move."
},

:SWITCHEROO => {
	:ID => 48,
	:name => "Switcheroo",
	:function => 0x0F2,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user trades held items with the target faster than the eye can follow."
},

:TAUNT => {
	:ID => 49,
	:name => "Taunt",
	:function => 0x0BA,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The target is taunted into a rage that allows it to use only attack moves for three turns."
},

:TORMENT => {
	:ID => 50,
	:name => "Torment",
	:function => 0x0B7,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user torments and enrages the target, preventing it from using the same move twice in a row."
},

:ROAROFTIME => {
	:ID => 51,
	:name => "Roar of Time",
	:function => 0x0C2,
	:type => :DRAGON,
	:category => :special,
	:basedamage => 150,
	:accuracy => 90,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user blasts the target with power that distorts even time. The user can't move on the next turn."
},

:DRACOMETEOR => {
	:ID => 52,
	:name => "Draco Meteor",
	:function => 0x03F,
	:type => :DRAGON,
	:category => :special,
	:basedamage => 130,
	:accuracy => 90,
	:maxpp => 5,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "Comets are summoned down from the sky. The recoil harshly lowers the user's Sp. Atk stat."
},

:OUTRAGE => {
	:ID => 53,
	:name => "Outrage",
	:function => 0x0D2,
	:type => :DRAGON,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 10,
	:target => :RandomOpposing,
	:contact => true,
	:kingrock => true,
	:desc => "The user rampages and attacks for two to three turns. The user then becomes confused."
},

:DRAGONRUSH => {
	:ID => 54,
	:name => "Dragon Rush",
	:function => 0x010,
	:type => :DRAGON,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 75,
	:maxpp => 10,
	:effect => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user tackles the target, exhibiting overwhelming menace. This may also make the target flinch."
},

:SPACIALREND => {
	:ID => 55,
	:name => "Spacial Rend",
	:function => 0x000,
	:type => :DRAGON,
	:category => :special,
	:basedamage => 100,
	:accuracy => 95,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:highcrit => true,
	:desc => "The user tears the target along with the space around it. Critical hits land more easily."
},

:DRAGONPULSE => {
	:ID => 56,
	:name => "Dragon Pulse",
	:function => 0x000,
	:type => :DRAGON,
	:category => :special,
	:basedamage => 85,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The target is attacked with a shock wave generated by the user's gaping mouth."
},

:DRAGONCLAW => {
	:ID => 57,
	:name => "Dragon Claw",
	:function => 0x000,
	:type => :DRAGON,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user slashes the target with huge sharp claws."
},

:DRAGONTAIL => {
	:ID => 58,
	:name => "Dragon Tail",
	:function => 0x0EC,
	:type => :DRAGON,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:priority => -6,
	:contact => true,
	:nonmirror => true,
	:desc => "The target is knocked away, and a different Pokémon is dragged out. Ends the battle in the wild."
},

:DRAGONBREATH => {
	:ID => 59,
	:name => "Dragon Breath",
	:function => 0x007,
	:type => :DRAGON,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user exhales a mighty gust that inflicts damage. This may also leave the target with paralysis."
},

:DUALCHOP => {
	:ID => 60,
	:name => "Dual Chop",
	:function => 0x0BD,
	:type => :DRAGON,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 90,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks the target by hitting it with brutal strikes. The target is hit twice in a row."
},

:TWISTER => {
	:ID => 61,
	:name => "Twister",
	:function => 0x078,
	:type => :DRAGON,
	:category => :special,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 20,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "The user whips up a vicious tornado to tear at the opposing Pokémon. This may also make them flinch."
},

:DRAGONRAGE => {
	:ID => 62,
	:name => "Dragon Rage",
	:function => 0x06B,
	:type => :DRAGON,
	:category => :special,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "This attack hits the target with a shock wave of pure rage. This attack always inflicts 40 HP damage."
},

:DRAGONDANCE => {
	:ID => 63,
	:name => "Dragon Dance",
	:function => 0x026,
	:type => :DRAGON,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user vigorously performs a mystic, powerful dance that boosts their Attack and Speed stats."
},

:BOLTSTRIKE => {
	:ID => 64,
	:name => "Bolt Strike",
	:function => 0x007,
	:type => :ELECTRIC,
	:category => :physical,
	:basedamage => 130,
	:accuracy => 85,
	:maxpp => 5,
	:effect => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "Surrounded with electricity, the user charges forward. This may also leave the target with paralysis."
},

:THUNDER => {
	:ID => 65,
	:name => "Thunder",
	:function => 0x008,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 110,
	:accuracy => 70,
	:maxpp => 10,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A wicked thunderbolt is dropped on the target. This may also leave the target with paralysis."
},

:VOLTTACKLE => {
	:ID => 66,
	:name => "Volt Tackle",
	:function => 0x0FD,
	:type => :ELECTRIC,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks in an electrified charge. It damages the user quite a lot and may paralyze the target."
},

:ZAPCANNON => {
	:ID => 67,
	:name => "Zap Cannon",
	:function => 0x007,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 120,
	:accuracy => 50,
	:maxpp => 5,
	:effect => 100,
	:target => :SingleNonUser,
	:desc => "The user fires an electric blast like a cannon to inflict damage and cause paralysis."
},

:FUSIONBOLT => {
	:ID => 68,
	:name => "Fusion Bolt",
	:function => 0x079,
	:type => :ELECTRIC,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user throws down a giant lightning bolt. Its power is doubled if Fusion Flare is used before it."
},

:THUNDERBOLT => {
	:ID => 69,
	:name => "Thunderbolt",
	:function => 0x007,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "A strong electric blast crashes down on the target. This may also leave the target with paralysis."
},

:WILDCHARGE => {
	:ID => 70,
	:name => "Wild Charge",
	:function => 0x0FA,
	:type => :ELECTRIC,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user is shrouded in electricity and smashes the target. It also damages the user a little."
},

:DISCHARGE => {
	:ID => 71,
	:name => "Discharge",
	:function => 0x007,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 30,
	:target => :AllNonUsers,
	:kingrock => true,
	:desc => "The user lets loose a flare of electricity, striking everything around. This may also cause paralysis."
},

:THUNDERPUNCH => {
	:ID => 72,
	:name => "Thunder Punch",
	:function => 0x007,
	:type => :ELECTRIC,
	:category => :physical,
	:basedamage => 75,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:punchmove => true,
	:desc => "The target is punched with an electrified fist. This may also leave the target with paralysis."
},

:VOLTSWITCH => {
	:ID => 73,
	:name => "Volt Switch",
	:function => 0x0EE,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "After making their attack, the user rushes back to switch places with a party Pokémon in waiting."
},

:SPARK => {
	:ID => 74,
	:name => "Spark",
	:function => 0x007,
	:type => :ELECTRIC,
	:category => :physical,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user throws an electrically charged tackle at the target. This may paralyze the target."
},

:THUNDERFANG => {
	:ID => 75,
	:name => "Thunder Fang",
	:function => 0x009,
	:type => :ELECTRIC,
	:category => :physical,
	:basedamage => 65,
	:accuracy => 95,
	:maxpp => 15,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user bites with electrified fangs. This may also make the target flinch or leave it with paralysis."
},

:SHOCKWAVE => {
	:ID => 76,
	:name => "Shock Wave",
	:function => 0x0A5,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 60,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user strikes the target with a quick jolt of electricity. This attack never misses."
},

:ELECTROWEB => {
	:ID => 77,
	:name => "Electroweb",
	:function => 0x044,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 55,
	:accuracy => 95,
	:maxpp => 15,
	:effect => 100,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "The user attacks and captures opposing Pokémon using an electric net, lowering their Speed stat."
},

:CHARGEBEAM => {
	:ID => 78,
	:name => "Charge Beam",
	:function => 0x020,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 50,
	:accuracy => 90,
	:maxpp => 10,
	:effect => 70,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks with an electric charge. It may also raise the user's Sp. Atk stat."
},

:THUNDERSHOCK => {
	:ID => 79,
	:name => "Thunder Shock",
	:function => 0x007,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 30,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "A jolt of electricity crashes down on the target. This may also leave the target with paralysis."
},

:ELECTROBALL => {
	:ID => 80,
	:name => "Electro Ball",
	:function => 0x099,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user hurls an electric orb. The faster the user is than the target, the greater the power."
},

:CHARGE => {
	:ID => 81,
	:name => "Charge",
	:function => 0x021,
	:type => :ELECTRIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user boosts an Electric-type move for use on the next turn. It raises the user's Sp. Def stat."
},

:MAGNETRISE => {
	:ID => 82,
	:name => "Magnet Rise",
	:function => 0x119,
	:type => :ELECTRIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:gravityblocked => true,
	:desc => "The user levitates using electrically generated magnetism for five turns."
},

:THUNDERWAVE => {
	:ID => 83,
	:name => "Thunder Wave",
	:function => 0x007,
	:type => :ELECTRIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 90,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user launches a weak jolt of electricity that paralyzes the target."
},

:FOCUSPUNCH => {
	:ID => 84,
	:name => "Focus Punch",
	:function => 0x115,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 150,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:priority => -3,
	:contact => true,
	:nonmirror => true,
	:punchmove => true,
	:desc => "The user focuses their mind before launching a punch. The move fails if the user is hit before using it."
},

:HIJUMPKICK => {
	:ID => 85,
	:name => "High Jump Kick",
	:function => 0x10B,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 130,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:gravityblocked => true,
	:desc => "The target is attacked with a knee kick from a jump. If it misses, the user is hurt instead."
},

:CLOSECOMBAT => {
	:ID => 86,
	:name => "Close Combat",
	:function => 0x03C,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user fights up close, not guarding themselves. It lowers the user's Defense and Sp. Def stats."
},

:FOCUSBLAST => {
	:ID => 87,
	:name => "Focus Blast",
	:function => 0x046,
	:type => :FIGHTING,
	:category => :special,
	:basedamage => 120,
	:accuracy => 70,
	:maxpp => 5,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "The user heightens mental focus to unleash their power. It may lower the target's Sp. Def stat."
},

:SUPERPOWER => {
	:ID => 88,
	:name => "Superpower",
	:function => 0x03B,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user attacks with great power. However, this lowers the user's Attack and Defense stats."
},

:CROSSCHOP => {
	:ID => 89,
	:name => "Cross Chop",
	:function => 0x000,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 80,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:highcrit => true,
	:desc => "The user delivers a double chop with their forearms crossed. Critical hits land more easily."
},

:DYNAMICPUNCH => {
	:ID => 90,
	:name => "Dynamic Punch",
	:function => 0x013,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 50,
	:maxpp => 5,
	:effect => 100,
	:target => :SingleNonUser,
	:contact => true,
	:punchmove => true,
	:desc => "The user punches the target with full, concentrated power. This confuses the target if it hits."
},

:HAMMERARM => {
	:ID => 91,
	:name => "Hammer Arm",
	:function => 0x03E,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:punchmove => true,
	:desc => "The user swings and hits with their strong, heavy fist. It lowers the user's Speed, however."
},

:JUMPKICK => {
	:ID => 92,
	:name => "Jump Kick",
	:function => 0x10B,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 95,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:gravityblocked => true,
	:desc => "The user jumps up high, then strikes with a kick. If the kick misses, the user is hurt instead."
},

:AURASPHERE => {
	:ID => 93,
	:name => "Aura Sphere",
	:function => 0x0A5,
	:type => :FIGHTING,
	:category => :special,
	:basedamage => 80,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user lets loose a blast of aura power from deep within their body. This attack never misses."
},

:SACREDSWORD => {
	:ID => 94,
	:name => "Sacred Sword",
	:function => 0x0A9,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks by slicing with a long horn. The target's stat changes don't affect the damage."
},

:SECRETSWORD => {
	:ID => 95,
	:name => "Secret Sword",
	:function => 0x122,
	:type => :FIGHTING,
	:category => :special,
	:basedamage => 85,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user cuts with a long horn. The odd power contained in the horn deals physical damage."
},

:SKYUPPERCUT => {
	:ID => 96,
	:name => "Sky Uppercut",
	:function => 0x11B,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 85,
	:accuracy => 90,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:punchmove => true,
	:desc => "The user attacks the target with an uppercut thrown skyward with force."
},

:SUBMISSION => {
	:ID => 97,
	:name => "Submission",
	:function => 0x0FA,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 80,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user grabs the target and recklessly dives for the ground. This also damages the user a little."
},

:BRICKBREAK => {
	:ID => 98,
	:name => "Brick Break",
	:function => 0x10A,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 75,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks with a swift chop. It can also break barriers, such as Light Screen and Reflect."
},

:DRAINPUNCH => {
	:ID => 99,
	:name => "Drain Punch",
	:function => 0x0DD,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 75,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:punchmove => true,
	:desc => "An energy-draining punch. The user's HP is restored by half the damage taken by the target."
},

:VITALTHROW => {
	:ID => 100,
	:name => "Vital Throw",
	:function => 0x0A5,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:priority => -1,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks last. In return, this throw move never misses."
},

:CIRCLETHROW => {
	:ID => 101,
	:name => "Circle Throw",
	:function => 0x0EC,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:priority => -6,
	:contact => true,
	:nonmirror => true,
	:desc => "The target is thrown, and a different Pokémon is dragged out. Ends the battle in the wild."
},

:FORCEPALM => {
	:ID => 102,
	:name => "Force Palm",
	:function => 0x007,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is attacked with a shock wave. This may also leave the target with paralysis."
},

:LOWSWEEP => {
	:ID => 103,
	:name => "Low Sweep",
	:function => 0x044,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 100,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user makes a swift attack on the target's legs, which lowers the target's Speed stat."
},

:REVENGE => {
	:ID => 104,
	:name => "Revenge",
	:function => 0x081,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:priority => -4,
	:contact => true,
	:kingrock => true,
	:desc => "This attack move's power is doubled if the user has been hurt by the opponent in the same turn."
},

:ROLLINGKICK => {
	:ID => 105,
	:name => "Rolling Kick",
	:function => 0x00F,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 85,
	:maxpp => 15,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user lashes out with a quick, spinning kick. This may also make the target flinch."
},

:WAKEUPSLAP => {
	:ID => 106,
	:name => "Wake-Up Slap",
	:function => 0x07D,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "This attack inflicts big damage on a sleeping target. This also wakes the target up, however."
},

:KARATECHOP => {
	:ID => 107,
	:name => "Karate Chop",
	:function => 0x000,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 25,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:highcrit => true,
	:desc => "The target is attacked with a sharp chop. Critical hits land more easily."
},

:MACHPUNCH => {
	:ID => 108,
	:name => "Mach Punch",
	:function => 0x000,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:priority => 1,
	:contact => true,
	:kingrock => true,
	:punchmove => true,
	:desc => "The user throws a punch at blinding speed. This move always goes first."
},

:ROCKSMASH => {
	:ID => 109,
	:name => "Rock Smash",
	:function => 0x043,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 50,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user punches the target. This may lower the target's Defense stat. It can shatter rocks in the field."
},

:STORMTHROW => {
	:ID => 110,
	:name => "Storm Throw",
	:function => 0x0A0,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user strikes the target with a fierce blow. This attack always results in a critical hit."
},

:VACUUMWAVE => {
	:ID => 111,
	:name => "Vacuum Wave",
	:function => 0x000,
	:type => :FIGHTING,
	:category => :special,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:priority => 1,
	:kingrock => true,
	:desc => "The user whirls their fists to send a wave of pure vacuum at the target. This move always goes first."
},

:DOUBLEKICK => {
	:ID => 112,
	:name => "Double Kick",
	:function => 0x0BD,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 30,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is quickly kicked twice in succession using both feet."
},

:ARMTHRUST => {
	:ID => 113,
	:name => "Arm Thrust",
	:function => 0x0C0,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 15,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user lets loose a flurry of open-palmed arm thrusts that hit two to five times in a row."
},

:TRIPLEKICK => {
	:ID => 114,
	:name => "Triple Kick",
	:function => 0x0BF,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 10,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "A consecutive three-kick attack that becomes more powerful with each successive hit."
},

:COUNTER => {
	:ID => 115,
	:name => "Counter",
	:function => 0x071,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 20,
	:target => :NoTarget,
	:priority => -5,
	:contact => true,
	:nonmirror => true,
	:desc => "A retaliation move that counters any physical attack, inflicting double the damage taken."
},

:FINALGAMBIT => {
	:ID => 116,
	:name => "Final Gambit",
	:function => 0x0E1,
	:type => :FIGHTING,
	:category => :special,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:nonmirror => true,
	:desc => "The user risks everything to attack. The user faints, but does damage equal to their HP."
},

:LOWKICK => {
	:ID => 117,
	:name => "Low Kick",
	:function => 0x09A,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "A powerful low kick that makes the target fall over. The heavier the target, the greater the power."
},

:REVERSAL => {
	:ID => 118,
	:name => "Reversal",
	:function => 0x098,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "An all-out attack that becomes more powerful the less HP the user has."
},

:SEISMICTOSS => {
	:ID => 119,
	:name => "Seismic Toss",
	:function => 0x06D,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is thrown using the power of gravity. It inflicts damage equal to the user's level."
},

:BULKUP => {
	:ID => 120,
	:name => "Bulk Up",
	:function => 0x024,
	:type => :FIGHTING,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user tenses their muscles to bulk up their body, raising both their Attack and Defense stats."
},

:DETECT => {
	:ID => 121,
	:name => "Detect",
	:function => 0x0AA,
	:type => :FIGHTING,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :User,
	:priority => 4,
	:nonmirror => true,
	:desc => "Enables the user to evade all attacks. Its chance of failing rises if it is used in succession."
},

:QUICKGUARD => {
	:ID => 122,
	:name => "Quick Guard",
	:function => 0x0AB,
	:type => :FIGHTING,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :BothSides,
	:priority => 3,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user protects themselves and their allies from priority moves."
},

:VCREATE => {
	:ID => 123,
	:name => "V-create",
	:function => 0x03D,
	:type => :FIRE,
	:category => :physical,
	:basedamage => 180,
	:accuracy => 95,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "Engulfed in flames, the user rushes at the target. It lowers the user's Defense, Sp. Def, and Speed."
},

:BLASTBURN => {
	:ID => 124,
	:name => "Blast Burn",
	:function => 0x0C2,
	:type => :FIRE,
	:category => :special,
	:basedamage => 150,
	:accuracy => 90,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The target is razed by a fiery explosion. The user can't move on the next turn."
},

:ERUPTION => {
	:ID => 125,
	:name => "Eruption",
	:function => 0x08B,
	:type => :FIRE,
	:category => :special,
	:basedamage => 150,
	:accuracy => 100,
	:maxpp => 5,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "The user attacks the targets with explosive fury. The lower the user's HP, the lower the power."
},

:OVERHEAT => {
	:ID => 126,
	:name => "Overheat",
	:function => 0x03F,
	:type => :FIRE,
	:category => :special,
	:basedamage => 130,
	:accuracy => 90,
	:maxpp => 5,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks the target at full power. The attack's recoil harshly lowers the user's Sp. Atk stat."
},

:BLUEFLARE => {
	:ID => 127,
	:name => "Blue Flare",
	:function => 0x00A,
	:type => :FIRE,
	:category => :special,
	:basedamage => 130,
	:accuracy => 85,
	:maxpp => 5,
	:effect => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user engulfs the target in an intense, yet beautiful, blue flame. This may also burn the target."
},

:FIREBLAST => {
	:ID => 128,
	:name => "Fire Blast",
	:function => 0x00A,
	:type => :FIRE,
	:category => :special,
	:basedamage => 110,
	:accuracy => 85,
	:maxpp => 5,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "The user attacks with an intense blast of all-consuming fire. This may leave the target with a burn."
},

:FLAREBLITZ => {
	:ID => 129,
	:name => "Flare Blitz",
	:function => 0x0FE,
	:type => :FIRE,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:defrost => true,
	:desc => "The user charges forward in a flame cloak. It damages the user quite a lot and may burn the target."
},

:MAGMASTORM => {
	:ID => 130,
	:name => "Magma Storm",
	:function => 0x0CF,
	:type => :FIRE,
	:category => :special,
	:basedamage => 100,
	:accuracy => 75,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The target becomes trapped within a maelstrom of fire that rages for four to five turns."
},

:FUSIONFLARE => {
	:ID => 131,
	:name => "Fusion Flare",
	:function => 0x07A,
	:type => :FIRE,
	:category => :special,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:defrost => true,
	:desc => "The user brings down a giant flame. This move's power is doubled if Fusion Bolt is used before it."
},

:HEATWAVE => {
	:ID => 132,
	:name => "Heat Wave",
	:function => 0x00A,
	:type => :FIRE,
	:category => :special,
	:basedamage => 95,
	:accuracy => 90,
	:maxpp => 10,
	:effect => 10,
	:target => :AllOpposing,
	:desc => "The user exhales hot breath on opposing Pokémon. This may also leave those Pokémon with a burn."
},

:INFERNO => {
	:ID => 133,
	:name => "Inferno",
	:function => 0x00A,
	:type => :FIRE,
	:category => :special,
	:basedamage => 100,
	:accuracy => 50,
	:maxpp => 5,
	:effect => 100,
	:target => :SingleNonUser,
	:desc => "The user attacks by engulfing the target in an intense fire. This leaves the target with a burn."
},

:SACREDFIRE => {
	:ID => 134,
	:name => "Sacred Fire",
	:function => 0x00A,
	:type => :FIRE,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 95,
	:maxpp => 5,
	:effect => 50,
	:target => :SingleNonUser,
	:defrost => true,
	:desc => "The target is razed with a mystical fire of great intensity. This may also leave the target with a burn."
},

:SEARINGSHOT => {
	:ID => 135,
	:name => "Searing Shot",
	:function => 0x00A,
	:type => :FIRE,
	:category => :special,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 5,
	:effect => 30,
	:target => :AllNonUsers,
	:kingrock => true,
	:desc => "The user torches everything around in an inferno of scarlet flames. This may burn those hit."
},

:FLAMETHROWER => {
	:ID => 136,
	:name => "Flamethrower",
	:function => 0x00A,
	:type => :FIRE,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "The target is scorched with an intense blast of fire. This may leave the target with a burn."
},

:BLAZEKICK => {
	:ID => 137,
	:name => "Blaze Kick",
	:function => 0x00A,
	:type => :FIRE,
	:category => :physical,
	:basedamage => 85,
	:accuracy => 90,
	:maxpp => 10,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:highcrit => true,
	:desc => "The user launches a kick that lands critical hits more easily. This may also burn the target."
},

:FIERYDANCE => {
	:ID => 138,
	:name => "Fiery Dance",
	:function => 0x020,
	:type => :FIRE,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 50,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "Cloaked in flames, the user dances and flaps their wings. This may also raise the user's Sp. Atk stat."
},

:LAVAPLUME => {
	:ID => 139,
	:name => "Lava Plume",
	:function => 0x00A,
	:type => :FIRE,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 30,
	:target => :AllNonUsers,
	:kingrock => true,
	:desc => "The user torches everything around in an inferno of scarlet flames. This may leave those hit with a burn."
},

:FIREPUNCH => {
	:ID => 140,
	:name => "Fire Punch",
	:function => 0x00A,
	:type => :FIRE,
	:category => :physical,
	:basedamage => 75,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:punchmove => true,
	:desc => "The target is punched with a fiery fist. This may also leave the target with a burn."
},

:FLAMEBURST => {
	:ID => 141,
	:name => "Flame Burst",
	:function => 0x074,
	:type => :FIRE,
	:category => :special,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks with a bursting flame. The bursting flame damages Pokémon next to the target as well."
},

:FIREFANG => {
	:ID => 142,
	:name => "Fire Fang",
	:function => 0x00B,
	:type => :FIRE,
	:category => :physical,
	:basedamage => 65,
	:accuracy => 95,
	:maxpp => 15,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user bites with flame-cloaked fangs. This may also make the target flinch or leave it with a burn."
},

:FLAMEWHEEL => {
	:ID => 143,
	:name => "Flame Wheel",
	:function => 0x00A,
	:type => :FIRE,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 25,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:defrost => true,
	:desc => "The user charges at the target, cloaked in flames. This may also burn the target."
},

:FIREPLEDGE => {
	:ID => 144,
	:name => "Fire Pledge",
	:function => 0x107,
	:type => :FIRE,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A column of fire erupts. Its power is increased and it can create Fields with other Pledge moves."
},

:FLAMECHARGE => {
	:ID => 145,
	:name => "Flame Charge",
	:function => 0x01F,
	:type => :FIRE,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 100,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "Cloaked in flames, the user attacks. Building up power, the user raises their Speed stat."
},

:EMBER => {
	:ID => 146,
	:name => "Ember",
	:function => 0x00A,
	:type => :FIRE,
	:category => :special,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 25,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "The target is attacked with small flames. This may also leave the target with a burn."
},

:FIRESPIN => {
	:ID => 147,
	:name => "Fire Spin",
	:function => 0x0CF,
	:type => :FIRE,
	:category => :special,
	:basedamage => 35,
	:accuracy => 85,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The target becomes trapped within a fierce vortex of fire that rages for four to five turns."
},

:INCINERATE => {
	:ID => 148,
	:name => "Incinerate",
	:function => 0x0F5,
	:type => :FIRE,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :AllOpposing,
	:desc => "The user attacks with fire. If a Pokémon is holding a Berry or a Type Gem, the item becomes unusable."
},

:HEATCRASH => {
	:ID => 149,
	:name => "Heat Crash",
	:function => 0x09B,
	:type => :FIRE,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user slams, covered in flames. The heavier the user is than the target, the greater the power."
},

:SUNNYDAY => {
	:ID => 150,
	:name => "Sunny Day",
	:function => 0x0FF,
	:type => :FIRE,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :UserSide,
	:nonmirror => true,
	:desc => "Intensified sun empowers Fire-type moves and weakens Water-type moves for five turns."
},

:WILLOWISP => {
	:ID => 151,
	:name => "Will-O-Wisp",
	:function => 0x00A,
	:type => :FIRE,
	:category => :status,
	:basedamage => 0,
	:accuracy => 85,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user shoots a sinister, bluish-white flame at the target to inflict a burn."
},

:SKYATTACK => {
	:ID => 152,
	:name => "Sky Attack",
	:function => 0x0C7,
	:type => :FLYING,
	:category => :physical,
	:basedamage => 140,
	:accuracy => 90,
	:maxpp => 5,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:highcrit => true,
	:desc => "A second-turn attack move where critical hits land more easily. This may also make the target flinch."
},

:BRAVEBIRD => {
	:ID => 153,
	:name => "Brave Bird",
	:function => 0x0FB,
	:type => :FLYING,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user tucks in their wings and charges from low altitude. This damages the user quite a lot."
},

:HURRICANE => {
	:ID => 154,
	:name => "Hurricane",
	:function => 0x015,
	:type => :FLYING,
	:category => :special,
	:basedamage => 110,
	:accuracy => 70,
	:maxpp => 10,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user wraps their opponent in a fierce wind that flies up into the sky. This may also confuse the target."
},

:AEROBLAST => {
	:ID => 155,
	:name => "Aeroblast",
	:function => 0x000,
	:type => :FLYING,
	:category => :special,
	:basedamage => 100,
	:accuracy => 95,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:highcrit => true,
	:desc => "A vortex of air is shot at the target to inflict damage. Critical hits land more easily."
},

:FLY => {
	:ID => 156,
	:name => "Fly",
	:function => 0x0C9,
	:type => :FLYING,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 95,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:gravityblocked => true,
	:desc => "The user soars, then strikes the target on the next turn. It can be used to fly to any familiar location."
},

:BOUNCE => {
	:ID => 157,
	:name => "Bounce",
	:function => 0x0CC,
	:type => :FLYING,
	:category => :physical,
	:basedamage => 85,
	:accuracy => 85,
	:maxpp => 5,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:gravityblocked => true,
	:desc => "The user bounces up high, then drops on the second turn. This may also paralyze the target."
},

:DRILLPECK => {
	:ID => 158,
	:name => "Drill Peck",
	:function => 0x000,
	:type => :FLYING,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "A corkscrewing attack with a sharp beak acting as a drill."
},

:AIRSLASH => {
	:ID => 159,
	:name => "Air Slash",
	:function => 0x00F,
	:type => :FLYING,
	:category => :special,
	:basedamage => 75,
	:accuracy => 95,
	:maxpp => 15,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks with a blade of air that slices even the sky. This may also make the target flinch."
},

:AERIALACE => {
	:ID => 160,
	:name => "Aerial Ace",
	:function => 0x0A5,
	:type => :FLYING,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user confounds the target with speed, then slashes. This attack never misses."
},

:CHATTER => {
	:ID => 161,
	:name => "Chatter",
	:function => 0x013,
	:type => :FLYING,
	:category => :special,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 100,
	:target => :SingleNonUser,
	:nonmirror => true,
	:soundmove => true,
	:desc => "The user attacks the target with sound waves of deafening chatter. This confuses the target."
},

:PLUCK => {
	:ID => 162,
	:name => "Pluck",
	:function => 0x0F4,
	:type => :FLYING,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user pecks the target. If the target is holding a Berry, the user eats it and gains its effect."
},

:SKYDROP => {
	:ID => 163,
	:name => "Sky Drop",
	:function => 0x0CE,
	:type => :FLYING,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:gravityblocked => true,
	:desc => "Takes the target to the skies and drops it on the next turn. The target cannot attack while in the sky."
},

:WINGATTACK => {
	:ID => 164,
	:name => "Wing Attack",
	:function => 0x000,
	:type => :FLYING,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 35,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is struck with large, imposing wings spread wide to inflict damage."
},

:ACROBATICS => {
	:ID => 165,
	:name => "Acrobatics",
	:function => 0x086,
	:type => :FLYING,
	:category => :physical,
	:basedamage => 55,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user nimbly strikes the target. Inflicts massive damage if the user is not holding an item."
},

:AIRCUTTER => {
	:ID => 166,
	:name => "Air Cutter",
	:function => 0x000,
	:type => :FLYING,
	:category => :special,
	:basedamage => 60,
	:accuracy => 95,
	:maxpp => 25,
	:target => :AllOpposing,
	:kingrock => true,
	:highcrit => true,
	:desc => "The user launches razor-like wind to slash the opposing Pokémon. Critical hits land more easily."
},

:GUST => {
	:ID => 167,
	:name => "Gust",
	:function => 0x077,
	:type => :FLYING,
	:category => :special,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 35,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A gust of wind is whipped up by wings and launched at the target to inflict damage."
},

:PECK => {
	:ID => 168,
	:name => "Peck",
	:function => 0x000,
	:type => :FLYING,
	:category => :physical,
	:basedamage => 35,
	:accuracy => 100,
	:maxpp => 35,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is jabbed with a sharply pointed beak or horn."
},

:DEFOG => {
	:ID => 169,
	:name => "Defog",
	:function => 0x049,
	:type => :FLYING,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "A strong wind blows away barriers like Reflect or Light Screen. It also lowers the target's Evasion."
},

:FEATHERDANCE => {
	:ID => 170,
	:name => "Feather Dance",
	:function => 0x04B,
	:type => :FLYING,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user covers the target's body with a mass of down that harshly lowers its Attack stat."
},

:MIRRORMOVE => {
	:ID => 171,
	:name => "Mirror Move",
	:function => 0x0AE,
	:type => :FLYING,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user counters the target by mimicking the target's last move."
},

:ROOST => {
	:ID => 172,
	:name => "Roost",
	:function => 0x0D6,
	:type => :FLYING,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user lands and rests their body. It restores up to half of the user's max HP."
},

:TAILWIND => {
	:ID => 173,
	:name => "Tailwind",
	:function => 0x05B,
	:type => :FLYING,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :BothSides,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user whips up a turbulent whirlwind, boosting the Speed stat of the user and allies for four turns."
},

:SHADOWFORCE => {
	:ID => 174,
	:name => "Shadow Force",
	:function => 0x0CD,
	:type => :GHOST,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:bypassprotect => true,
	:kingrock => true,
	:desc => "The user disappears, then strikes on the next turn. It strikes even if the target protects itself."
},

:SHADOWBALL => {
	:ID => 175,
	:name => "Shadow Ball",
	:function => 0x046,
	:type => :GHOST,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 20,
	:target => :SingleNonUser,
	:desc => "The user hurls a shadowy blob at the target. This may also lower the target's Sp. Def stat."
},

:SHADOWCLAW => {
	:ID => 176,
	:name => "Shadow Claw",
	:function => 0x000,
	:type => :GHOST,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:highcrit => true,
	:desc => "The user slashes with a sharp claw made from shadows. Critical hits land more easily."
},

:OMINOUSWIND => {
	:ID => 177,
	:name => "Ominous Wind",
	:function => 0x02D,
	:type => :GHOST,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 5,
	:effect => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user blasts the target with a gust of repulsive wind. This may also raise all the user's stats at once."
},

:SHADOWPUNCH => {
	:ID => 178,
	:name => "Shadow Punch",
	:function => 0x0A5,
	:type => :GHOST,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:punchmove => true,
	:desc => "The user throws a punch from the shadows. This attack never misses."
},

:HEX => {
	:ID => 179,
	:name => "Hex",
	:function => 0x07F,
	:type => :GHOST,
	:category => :special,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "This relentless attack does massive damage to a target affected by status conditions."
},

:SHADOWSNEAK => {
	:ID => 180,
	:name => "Shadow Sneak",
	:function => 0x000,
	:type => :GHOST,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:priority => 1,
	:contact => true,
	:kingrock => true,
	:desc => "The user extends their shadow and attacks from behind. This move always goes first."
},

:ASTONISH => {
	:ID => 181,
	:name => "Astonish",
	:function => 0x00F,
	:type => :GHOST,
	:category => :physical,
	:basedamage => 30,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user attacks the target while shouting in a startling fashion. This may also make the target flinch."
},

:LICK => {
	:ID => 182,
	:name => "Lick",
	:function => 0x007,
	:type => :GHOST,
	:category => :physical,
	:basedamage => 30,
	:accuracy => 100,
	:maxpp => 30,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The target is licked with a long tongue, causing damage. This may also leave the target with paralysis."
},

:NIGHTSHADE => {
	:ID => 183,
	:name => "Night Shade",
	:function => 0x06D,
	:type => :GHOST,
	:category => :special,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user makes the target see a frightening mirage. It inflicts damage equal to the user's level."
},

:CONFUSERAY => {
	:ID => 184,
	:name => "Confuse Ray",
	:function => 0x013,
	:type => :GHOST,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The target is exposed to a sinister ray that triggers confusion."
},

:CURSE => {
	:ID => 185,
	:name => "Curse",
	:function => 0x10D,
	:type => :GHOST,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :OppositeOpposing,
	:nonmirror => true,
	:desc => "A move that works differently for the Ghost-type than for all other types."
},

:DESTINYBOND => {
	:ID => 186,
	:name => "Destiny Bond",
	:function => 0x0E7,
	:type => :GHOST,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :User,
	:nonmirror => true,
	:desc => "If the user faints after using this move, the Pokémon knocking it out also faints."
},

:GRUDGE => {
	:ID => 187,
	:name => "Grudge",
	:function => 0x0E6,
	:type => :GHOST,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :User,
	:nonmirror => true,
	:desc => "If the user faints, the user's grudge depletes the PP of the opponent's move that knocked it out."
},

:NIGHTMARE => {
	:ID => 188,
	:name => "Nightmare",
	:function => 0x10F,
	:type => :GHOST,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:desc => "A sleeping target sees a nightmare that inflicts some damage every turn."
},

:SPITE => {
	:ID => 189,
	:name => "Spite",
	:function => 0x10E,
	:type => :GHOST,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user unleashes a grudge on the move last used by the target, cutting 4 PP from it."
},

:FRENZYPLANT => {
	:ID => 190,
	:name => "Frenzy Plant",
	:function => 0x0C2,
	:type => :GRASS,
	:category => :special,
	:basedamage => 150,
	:accuracy => 90,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user slams the target with an enormous tree. The user can't move on the next turn."
},

:LEAFSTORM => {
	:ID => 191,
	:name => "Leaf Storm",
	:function => 0x03F,
	:type => :GRASS,
	:category => :special,
	:basedamage => 130,
	:accuracy => 90,
	:maxpp => 5,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user whips up a storm of leaves. The attack's recoil harshly lowers the user's Sp. Atk stat."
},

:PETALDANCE => {
	:ID => 192,
	:name => "Petal Dance",
	:function => 0x0D2,
	:type => :GRASS,
	:category => :special,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 10,
	:target => :RandomOpposing,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks by scattering petals for two to three turns. The user then becomes confused."
},

:POWERWHIP => {
	:ID => 193,
	:name => "Power Whip",
	:function => 0x000,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 85,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user violently whirls vines, tentacles, or the like to harshly lash the target."
},

:SEEDFLARE => {
	:ID => 194,
	:name => "Seed Flare",
	:function => 0x04F,
	:type => :GRASS,
	:category => :special,
	:basedamage => 120,
	:accuracy => 85,
	:maxpp => 5,
	:effect => 40,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user emits a shock wave to attack the target. This may also harshly lower the target's Sp. Def stat."
},

:SOLARBEAM => {
	:ID => 195,
	:name => "Solar Beam",
	:function => 0x0C4,
	:type => :GRASS,
	:category => :special,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "In this two-turn attack, the user gathers light, then blasts a bundled beam on the next turn."
},

:WOODHAMMER => {
	:ID => 196,
	:name => "Wood Hammer",
	:function => 0x0FB,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user slams their rugged body into the target to attack. This also damages the user quite a lot."
},

:LEAFBLADE => {
	:ID => 197,
	:name => "Leaf Blade",
	:function => 0x000,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:highcrit => true,
	:desc => "The user handles a sharp leaf like a sword, cutting their target. Critical hits land more easily."
},

:ENERGYBALL => {
	:ID => 198,
	:name => "Energy Ball",
	:function => 0x046,
	:type => :GRASS,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "The user draws power from nature and fires it at the target. This may also lower the target's Sp. Def stat."
},

:SEEDBOMB => {
	:ID => 199,
	:name => "Seed Bomb",
	:function => 0x000,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user slams a barrage of hard-shelled seeds down on the target from above."
},

:GIGADRAIN => {
	:ID => 200,
	:name => "Giga Drain",
	:function => 0x0DD,
	:type => :GRASS,
	:category => :special,
	:basedamage => 75,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:desc => "A nutrient-draining attack. The user's HP is restored by half the damage taken by the target."
},

:HORNLEECH => {
	:ID => 201,
	:name => "Horn Leech",
	:function => 0x0DD,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 75,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user drains the target's energy with horns. The user's HP is restored by half the damage dealt."
},

:LEAFTORNADO => {
	:ID => 202,
	:name => "Leaf Tornado",
	:function => 0x047,
	:type => :GRASS,
	:category => :special,
	:basedamage => 65,
	:accuracy => 90,
	:maxpp => 10,
	:effect => 30,
	:target => :SingleNonUser,
	:desc => "The user attacks by encircling the target in sharp leaves. This may also lower the target's Accuracy."
},

:MAGICALLEAF => {
	:ID => 203,
	:name => "Magical Leaf",
	:function => 0x0A5,
	:type => :GRASS,
	:category => :special,
	:basedamage => 60,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user scatters curious leaves that chase the target. This attack never misses."
},

:NEEDLEARM => {
	:ID => 204,
	:name => "Needle Arm",
	:function => 0x00F,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user attacks by wildly swinging their thorny arms. This may also make the target flinch."
},

:RAZORLEAF => {
	:ID => 205,
	:name => "Razor Leaf",
	:function => 0x000,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 55,
	:accuracy => 95,
	:maxpp => 25,
	:target => :AllOpposing,
	:kingrock => true,
	:highcrit => true,
	:desc => "Sharp-edged leaves are launched to slash at the opposing Pokémon. Critical hits land more easily."
},

:GRASSPLEDGE => {
	:ID => 206,
	:name => "Grass Pledge",
	:function => 0x106,
	:type => :GRASS,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A column of grass sprouts. Its power is increased and it can create Fields with other Pledge moves."
},

:MEGADRAIN => {
	:ID => 207,
	:name => "Mega Drain",
	:function => 0x0DD,
	:type => :GRASS,
	:category => :special,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:desc => "A nutrient-draining attack. The user's HP is restored by half the damage taken by the target."
},

:VINEWHIP => {
	:ID => 208,
	:name => "Vine Whip",
	:function => 0x000,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 45,
	:accuracy => 100,
	:maxpp => 25,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is struck with slender, whiplike vines to inflict damage."
},

:BULLETSEED => {
	:ID => 209,
	:name => "Bullet Seed",
	:function => 0x0C0,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 25,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user forcefully shoots seeds at the target two to five times in a row."
},

:ABSORB => {
	:ID => 210,
	:name => "Absorb",
	:function => 0x0DD,
	:type => :GRASS,
	:category => :special,
	:basedamage => 20,
	:accuracy => 100,
	:maxpp => 25,
	:target => :SingleNonUser,
	:desc => "A nutrient-draining attack. The user's HP is restored by half the damage taken by the target."
},

:GRASSKNOT => {
	:ID => 211,
	:name => "Grass Knot",
	:function => 0x09A,
	:type => :GRASS,
	:category => :special,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user snares the target and trips it. The heavier the target, the greater the move's power."
},

:AROMATHERAPY => {
	:ID => 212,
	:name => "Aromatherapy",
	:function => 0x019,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :BothSides,
	:snatchable => true,
	:nonmirror => true,
	:soundmove => true,
	:desc => "The user releases a soothing scent that heals all status conditions affecting the user's party."
},

:COTTONGUARD => {
	:ID => 213,
	:name => "Cotton Guard",
	:function => 0x038,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user protects their body, wrapping it in soft cotton. It drastically raises their Defense stat."
},

:COTTONSPORE => {
	:ID => 214,
	:name => "Cotton Spore",
	:function => 0x04D,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 40,
	:target => :AllOpposing,
	:magiccoat => true,
	:desc => "The user releases cotton-like spores that harshly lower the targets' Speed stat."
},

:GRASSWHISTLE => {
	:ID => 215,
	:name => "Grass Whistle",
	:function => 0x003,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 55,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:soundmove => true,
	:desc => "The user plays a pleasant melody that lulls the target into a deep sleep."
},

:INGRAIN => {
	:ID => 216,
	:name => "Ingrain",
	:function => 0x0DB,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user lays roots that restore HP on every turn. Because of being rooted, the user can't switch out."
},

:LEECHSEED => {
	:ID => 217,
	:name => "Leech Seed",
	:function => 0x0DC,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "A seed is planted on the target. It steals some HP from the target every turn."
},

:SLEEPPOWDER => {
	:ID => 218,
	:name => "Sleep Powder",
	:function => 0x003,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 75,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user scatters a big cloud of sleep-inducing dust around the target."
},

:SPORE => {
	:ID => 219,
	:name => "Spore",
	:function => 0x003,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user scatters bursts of spores that induce sleep."
},

:STUNSPORE => {
	:ID => 220,
	:name => "Stun Spore",
	:function => 0x007,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 75,
	:maxpp => 30,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user scatters a cloud of numbing powder that paralyzes the target."
},

:SYNTHESIS => {
	:ID => 221,
	:name => "Synthesis",
	:function => 0x0D8,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user restores their own HP. The amount of HP regained varies with the weather."
},

:WORRYSEED => {
	:ID => 222,
	:name => "Worry Seed",
	:function => 0x064,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "A seed causing worry is planted on the target. It changes the target's Ability to Insomnia."
},

:EARTHQUAKE => {
	:ID => 223,
	:name => "Earthquake",
	:function => 0x076,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 10,
	:target => :AllNonUsers,
	:kingrock => true,
	:desc => "The user sets off an earthquake that strikes every Pokémon around them."
},

:EARTHPOWER => {
	:ID => 224,
	:name => "Earth Power",
	:function => 0x046,
	:type => :GROUND,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user makes the ground under the target erupt. This may also lower the target's Sp. Def stat."
},

:DIG => {
	:ID => 225,
	:name => "Dig",
	:function => 0x0CA,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user burrows, then attacks on the next turn. It can also be used to exit dungeons."
},

:DRILLRUN => {
	:ID => 226,
	:name => "Drill Run",
	:function => 0x000,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 95,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:highcrit => true,
	:desc => "The user crashes into the target while rotating their body like a drill. Critical hits land more easily."
},

:BONECLUB => {
	:ID => 227,
	:name => "Bone Club",
	:function => 0x00F,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 65,
	:accuracy => 85,
	:maxpp => 20,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "The user clubs the target with a bone. This may also make the target flinch."
},

:MUDBOMB => {
	:ID => 228,
	:name => "Mud Bomb",
	:function => 0x047,
	:type => :GROUND,
	:category => :special,
	:basedamage => 65,
	:accuracy => 85,
	:maxpp => 10,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user launches a hard-packed mud ball to attack. This may also lower the target's Accuracy."
},

:BULLDOZE => {
	:ID => 229,
	:name => "Bulldoze",
	:function => 0x044,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 100,
	:target => :AllNonUsers,
	:kingrock => true,
	:desc => "The user strikes everything around by stomping the ground. This lowers the Speed stat of those hit."
},

:MUDSHOT => {
	:ID => 230,
	:name => "Mud Shot",
	:function => 0x044,
	:type => :GROUND,
	:category => :special,
	:basedamage => 55,
	:accuracy => 95,
	:maxpp => 15,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks by hurling a blob of mud at the target. This also lowers the target's Speed stat."
},

:BONEMERANG => {
	:ID => 231,
	:name => "Bonemerang",
	:function => 0x0BD,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user throws the bone they hold. The bone loops around to hit the target twice, coming and going."
},

:SANDTOMB => {
	:ID => 232,
	:name => "Sand Tomb",
	:function => 0x0CF,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 35,
	:accuracy => 85,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user traps the target inside a harshly raging sandstorm for four to five turns."
},

:BONERUSH => {
	:ID => 233,
	:name => "Bone Rush",
	:function => 0x0C0,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 25,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user strikes the target with a hard bone two to five times in a row."
},

:MUDSLAP => {
	:ID => 234,
	:name => "Mud-Slap",
	:function => 0x047,
	:type => :GROUND,
	:category => :special,
	:basedamage => 20,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 100,
	:target => :SingleNonUser,
	:desc => "The user hurls mud in the target's face to inflict damage and lower its Accuracy."
},

:FISSURE => {
	:ID => 235,
	:name => "Fissure",
	:function => 0x070,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 30,
	:maxpp => 5,
	:target => :SingleNonUser,
	:desc => "The user opens up a fissure in the ground and drops the target in. The target faints instantly if hit."
},

:MAGNITUDE => {
	:ID => 236,
	:name => "Magnitude",
	:function => 0x095,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 30,
	:target => :AllNonUsers,
	:kingrock => true,
	:desc => "The user attacks everything around with a ground-shaking quake. Its power varies."
},

:MUDSPORT => {
	:ID => 237,
	:name => "Mud Sport",
	:function => 0x09D,
	:type => :GROUND,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :BothSides,
	:nonmirror => true,
	:desc => "The user kicks up mud on the battlefield. This weakens Electric-type moves for five turns."
},

:SANDATTACK => {
	:ID => 238,
	:name => "Sand Attack",
	:function => 0x047,
	:type => :GROUND,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "Sand is hurled in the target's face, reducing the target's Accuracy."
},

:SPIKES => {
	:ID => 239,
	:name => "Spikes",
	:function => 0x103,
	:type => :GROUND,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :OpposingSide,
	:magiccoat => true,
	:nonmirror => true,
	:desc => "The user lays a trap of spikes at the opposing team's feet. It hurts opponents switching into battle."
},

:FREEZESHOCK => {
	:ID => 240,
	:name => "Freeze Shock",
	:function => 0x0C5,
	:type => :ICE,
	:category => :physical,
	:basedamage => 140,
	:accuracy => 90,
	:maxpp => 5,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks with electrically charged ice on the second turn. This may paralyze the target."
},

:ICEBURN => {
	:ID => 241,
	:name => "Ice Burn",
	:function => 0x0C6,
	:type => :ICE,
	:category => :special,
	:basedamage => 140,
	:accuracy => 90,
	:maxpp => 5,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "On the second turn, an ultracold, freezing wind surrounds the target. This may burn the target."
},

:BLIZZARD => {
	:ID => 242,
	:name => "Blizzard",
	:function => 0x00D,
	:type => :ICE,
	:category => :special,
	:basedamage => 110,
	:accuracy => 70,
	:maxpp => 5,
	:effect => 10,
	:target => :AllOpposing,
	:desc => "A howling blizzard is summoned to strike opposing Pokémon. This may also freeze the targets."
},

:ICEBEAM => {
	:ID => 243,
	:name => "Ice Beam",
	:function => 0x00C,
	:type => :ICE,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "The target is struck with an icy-cold beam of energy. This may also leave the target frozen."
},

:ICICLECRASH => {
	:ID => 244,
	:name => "Icicle Crash",
	:function => 0x00F,
	:type => :ICE,
	:category => :physical,
	:basedamage => 85,
	:accuracy => 90,
	:maxpp => 10,
	:effect => 30,
	:target => :SingleNonUser,
	:desc => "The user attacks by harshly dropping large icicles onto the target. This may make the target flinch."
},

:ICEPUNCH => {
	:ID => 245,
	:name => "Ice Punch",
	:function => 0x00C,
	:type => :ICE,
	:category => :physical,
	:basedamage => 75,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:punchmove => true,
	:desc => "The target is punched with an icy fist. This may also leave the target frozen."
},

:AURORABEAM => {
	:ID => 246,
	:name => "Aurora Beam",
	:function => 0x042,
	:type => :ICE,
	:category => :special,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "The target is hit with a rainbow-colored beam. This may also lower the target's Attack stat."
},

:GLACIATE => {
	:ID => 247,
	:name => "Glaciate",
	:function => 0x044,
	:type => :ICE,
	:category => :special,
	:basedamage => 65,
	:accuracy => 95,
	:maxpp => 10,
	:effect => 100,
	:target => :AllOpposing,
	:desc => "The user attacks by blowing freezing cold air at opposing Pokémon. This lowers their Speed stat."
},

:ICEFANG => {
	:ID => 248,
	:name => "Ice Fang",
	:function => 0x00E,
	:type => :ICE,
	:category => :physical,
	:basedamage => 65,
	:accuracy => 95,
	:maxpp => 15,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user bites with cold-infused fangs. This may also make the target flinch or leave it frozen."
},

:AVALANCHE => {
	:ID => 249,
	:name => "Avalanche",
	:function => 0x081,
	:type => :ICE,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:priority => -4,
	:contact => true,
	:kingrock => true,
	:desc => "The power of this move is doubled if the user has already been hurt by the target in the same turn."
},

:ICYWIND => {
	:ID => 250,
	:name => "Icy Wind",
	:function => 0x044,
	:type => :ICE,
	:category => :special,
	:basedamage => 55,
	:accuracy => 95,
	:maxpp => 15,
	:effect => 100,
	:target => :AllOpposing,
	:desc => "The user attacks with a gust of chilled air. This also lowers the opposing Pokémons' Speed stat."
},

:FROSTBREATH => {
	:ID => 251,
	:name => "Frost Breath",
	:function => 0x0A0,
	:type => :ICE,
	:category => :special,
	:basedamage => 60,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user blows a cold breath on the target. This attack always results in a critical hit."
},

:ICESHARD => {
	:ID => 252,
	:name => "Ice Shard",
	:function => 0x000,
	:type => :ICE,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:priority => 1,
	:kingrock => true,
	:desc => "The user flash-freezes chunks of ice and hurls them at the target. This move always goes first."
},

:POWDERSNOW => {
	:ID => 253,
	:name => "Powder Snow",
	:function => 0x00C,
	:type => :ICE,
	:category => :special,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 25,
	:effect => 10,
	:target => :AllOpposing,
	:desc => "The user attacks with a chilling gust of powdery snow. This may also freeze the opposing Pokémon."
},

:ICEBALL => {
	:ID => 254,
	:name => "Ice Ball",
	:function => 0x0D3,
	:type => :ICE,
	:category => :physical,
	:basedamage => 30,
	:accuracy => 90,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks the target for five turns. The move's power increases each time it hits."
},

:ICICLESPEAR => {
	:ID => 255,
	:name => "Icicle Spear",
	:function => 0x0C0,
	:type => :ICE,
	:category => :physical,
	:basedamage => 25,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user launches sharp icicles at the target two to five times in a row."
},

:SHEERCOLD => {
	:ID => 256,
	:name => "Sheer Cold",
	:function => 0x070,
	:type => :ICE,
	:category => :special,
	:basedamage => 1,
	:accuracy => 30,
	:maxpp => 5,
	:target => :SingleNonUser,
	:desc => "The target faints instantly. It is less likely to hit if used by Pokémon other than Ice-types."
},

:HAIL => {
	:ID => 257,
	:name => "Hail",
	:function => 0x102,
	:type => :ICE,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :UserSide,
	:nonmirror => true,
	:desc => "The user summons a hailstorm lasting five turns. It damages all Pokémon except the Ice-type."
},

:HAZE => {
	:ID => 258,
	:name => "Haze",
	:function => 0x051,
	:type => :ICE,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 30,
	:target => :UserSide,
	:nonmirror => true,
	:desc => "The user creates a haze that eliminates every stat change among all the Pokémon engaged in battle."
},

:MIST => {
	:ID => 259,
	:name => "Mist",
	:function => 0x056,
	:type => :ICE,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 30,
	:target => :BothSides,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user cloaks themselves and allies in mist, preventing stats from being lowered for five turns."
},

:EXPLOSION => {
	:ID => 260,
	:name => "Explosion",
	:function => 0x0E0,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 250,
	:accuracy => 100,
	:maxpp => 5,
	:target => :AllNonUsers,
	:kingrock => true,
	:desc => "The user attacks everything around themselves, causing a tremendous explosion. The user then faints."
},

:SELFDESTRUCT => {
	:ID => 261,
	:name => "Self-Destruct",
	:function => 0x0E0,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 200,
	:accuracy => 100,
	:maxpp => 5,
	:target => :AllNonUsers,
	:kingrock => true,
	:desc => "The user attacks everything around themselves by causing an explosion. The user then faints."
},

:GIGAIMPACT => {
	:ID => 262,
	:name => "Giga Impact",
	:function => 0x0C2,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 150,
	:accuracy => 90,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user charges at the target using every bit of their power. The user can't move on the next turn."
},

:HYPERBEAM => {
	:ID => 263,
	:name => "Hyper Beam",
	:function => 0x0C2,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 150,
	:accuracy => 90,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The target is attacked with a powerful beam. The user can't move on the next turn."
},

:LASTRESORT => {
	:ID => 264,
	:name => "Last Resort",
	:function => 0x125,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 140,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "This move can be used only after the user has used all other moves they know within the battle."
},

:DOUBLEEDGE => {
	:ID => 265,
	:name => "Double-Edge",
	:function => 0x0FB,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "A reckless, life-risking tackle. This also damages the user quite a lot."
},

:HEADCHARGE => {
	:ID => 266,
	:name => "Head Charge",
	:function => 0x0FA,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user charges head-first, using powerful guard hair. This also damages the user a little."
},

:MEGAKICK => {
	:ID => 267,
	:name => "Mega Kick",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 75,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is attacked by a kick launched with muscle-packed power."
},

:THRASH => {
	:ID => 268,
	:name => "Thrash",
	:function => 0x0D2,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 10,
	:target => :RandomOpposing,
	:contact => true,
	:kingrock => true,
	:desc => "The user rampages and attacks for two to three turns. The user then becomes confused."
},

:EGGBOMB => {
	:ID => 269,
	:name => "Egg Bomb",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 75,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A large egg is hurled at the target with maximum force to inflict damage."
},

:JUDGMENT => {
	:ID => 270,
	:name => "Judgment",
	:function => 0x09F,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user releases countless shots of light. This move's type varies depending on the held Plate."
},

:SKULLBASH => {
	:ID => 271,
	:name => "Skull Bash",
	:function => 0x0C8,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 130,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 100,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "Tucking in their head, the user raises their Defense stat and rams the target on the second turn."
},

:HYPERVOICE => {
	:ID => 272,
	:name => "Hyper Voice",
	:function => 0x000,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:target => :AllOpposing,
	:soundmove => true,
	:desc => "The user lets loose a horribly echoing shout with the power to inflict damage."
},

:ROCKCLIMB => {
	:ID => 273,
	:name => "Rock Climb",
	:function => 0x013,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 85,
	:maxpp => 20,
	:effect => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks the target by smashing into it with incredible force. This may also confuse the target. It can also be used to scale rocky walls."
},

:TAKEDOWN => {
	:ID => 274,
	:name => "Take Down",
	:function => 0x0FA,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 85,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "A reckless, full-body charge to slam into the target. This also damages the user a little."
},

:UPROAR => {
	:ID => 275,
	:name => "Uproar",
	:function => 0x0D1,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:target => :RandomOpposing,
	:kingrock => true,
	:soundmove => true,
	:desc => "The user attacks in an uproar for three turns. During that time, no Pokémon can fall asleep."
},

:BODYSLAM => {
	:ID => 276,
	:name => "Body Slam",
	:function => 0x007,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 85,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user drops onto the target with their full body weight. This may also leave the target with paralysis."
},

:TECHNOBLAST => {
	:ID => 277,
	:name => "Techno Blast",
	:function => 0x09F,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user fires a beam of light. The move's type changes depending on the Drive the user holds."
},

:EXTREMESPEED => {
	:ID => 278,
	:name => "Extreme Speed",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:priority => 2,
	:contact => true,
	:kingrock => true,
	:desc => "The user charges the target at blinding speed. This move always goes first."
},

:HYPERFANG => {
	:ID => 279,
	:name => "Hyper Fang",
	:function => 0x00F,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 90,
	:maxpp => 15,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user bites hard on the target with sharp front fangs. This may also make the target flinch."
},

:MEGAPUNCH => {
	:ID => 280,
	:name => "Mega Punch",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 85,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:punchmove => true,
	:desc => "The target is slugged by a punch thrown with muscle-packed power."
},

:RAZORWIND => {
	:ID => 281,
	:name => "Razor Wind",
	:function => 0x0C3,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :AllOpposing,
	:kingrock => true,
	:highcrit => true,
	:desc => "Blades of wind hit opposing Pokémon on the second turn. Critical hits land more easily."
},

:SLAM => {
	:ID => 282,
	:name => "Slam",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 75,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is slammed with a long tail, vines, or the like to inflict damage."
},

:STRENGTH => {
	:ID => 283,
	:name => "Strength",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is slugged with a punch thrown at maximum power. This can also be used to move heavy boulders."
},

:TRIATTACK => {
	:ID => 284,
	:name => "Tri Attack",
	:function => 0x017,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 20,
	:target => :SingleNonUser,
	:desc => "The user strikes with a simultaneous three-beam attack. May also burn, freeze, or paralyze the target."
},

:CRUSHCLAW => {
	:ID => 285,
	:name => "Crush Claw",
	:function => 0x043,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 75,
	:accuracy => 95,
	:maxpp => 10,
	:effect => 50,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user slashes the target with hard and sharp claws. This may also lower the target's Defense."
},

:RELICSONG => {
	:ID => 286,
	:name => "Relic Song",
	:function => 0x003,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 75,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 10,
	:target => :AllOpposing,
	:soundmove => true,
	:desc => "The user appeals to the targets' hearts with an ancient song. This may also induce sleep."
},

:CHIPAWAY => {
	:ID => 287,
	:name => "Chip Away",
	:function => 0x0A9,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user strikes consistently. The target's stat changes don't affect this attack's damage."
},

:DIZZYPUNCH => {
	:ID => 288,
	:name => "Dizzy Punch",
	:function => 0x013,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 20,
	:target => :SingleNonUser,
	:contact => true,
	:punchmove => true,
	:desc => "The target is hit with rhythmically launched punches. This may also leave the target confused."
},

:FACADE => {
	:ID => 289,
	:name => "Facade",
	:function => 0x07E,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "This attack move doubles its power if the user is poisoned, burned, or paralyzed."
},

:HEADBUTT => {
	:ID => 290,
	:name => "Headbutt",
	:function => 0x00F,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user charges head first into the target. The target may flinch. Can be used to shake trees."
},

:RETALIATE => {
	:ID => 291,
	:name => "Retaliate",
	:function => 0x085,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user seeks revenge. If an ally fainted on the previous turn, it deals more damage."
},

:SECRETPOWER => {
	:ID => 292,
	:name => "Secret Power",
	:function => 0x0A4,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 30,
	:target => :SingleNonUser,
	:desc => "The additional effects of this attack depend upon where it is used."
},

:SLASH => {
	:ID => 293,
	:name => "Slash",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:highcrit => true,
	:desc => "The target is attacked with a slash of claws or blades. Critical hits land more easily."
},

:HORNATTACK => {
	:ID => 294,
	:name => "Horn Attack",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 25,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is jabbed with a sharply pointed horn to inflict damage."
},

:STOMP => {
	:ID => 295,
	:name => "Stomp",
	:function => 0x010,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The target is stomped with a big foot. This may also make the target flinch."
},

:COVET => {
	:ID => 296,
	:name => "Covet",
	:function => 0x0F1,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 25,
	:target => :SingleNonUser,
	:contact => true,
	:nonmirror => true,
	:desc => "The user endearingly approaches the target, then steals the target's held item."
},

:ROUND => {
	:ID => 297,
	:name => "Round",
	:function => 0x083,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:soundmove => true,
	:desc => "The user attacks the target with a song. Others can join in the Round to increase the power of the attack."
},

:SMELLINGSALTS => {
	:ID => 298,
	:name => "Smelling Salts",
	:function => 0x07C,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "This move's power is doubled when used on a target with paralysis, but also heals its paralysis."
},

:SWIFT => {
	:ID => 299,
	:name => "Swift",
	:function => 0x0A5,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 60,
	:accuracy => 0,
	:maxpp => 20,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "Star-shaped rays are shot at the opposing Pokémon. This attack never misses."
},

:VICEGRIP => {
	:ID => 300,
	:name => "Vice Grip",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 55,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is gripped and squeezed from both sides to inflict damage."
},

:CUT => {
	:ID => 301,
	:name => "Cut",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 95,
	:maxpp => 30,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is cut with a scythe or claw. This can also be used to cut down thin trees."
},

:STRUGGLE => {
	:ID => 302,
	:name => "Struggle",
	:function => 0x002,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 0,
	:maxpp => 1,
	:target => :SingleNonUser,
	:contact => true,
	:nonmirror => true,
	:kingrock => true,
	:desc => "This attack is used in desperation only if the user has no PP. It also damages the user a little."
},

:TACKLE => {
	:ID => 303,
	:name => "Tackle",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 35,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "A physical attack in which the user charges and slams into the target with their whole body."
},

:WEATHERBALL => {
	:ID => 304,
	:name => "Weather Ball",
	:function => 0x087,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "This attack move varies in power and type depending on the weather."
},

:ECHOEDVOICE => {
	:ID => 305,
	:name => "Echoed Voice",
	:function => 0x092,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:soundmove => true,
	:desc => "The user attacks with an echoing voice. The power increases with every turn it is used successively."
},

:FAKEOUT => {
	:ID => 306,
	:name => "Fake Out",
	:function => 0x012,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 100,
	:target => :SingleNonUser,
	:priority => 3,
	:contact => true,
	:desc => "This attack hits first and makes the target flinch. It only works the first turn the user is in battle."
},

:FALSESWIPE => {
	:ID => 307,
	:name => "False Swipe",
	:function => 0x0E9,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 40,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "A restrained attack that prevents the target from fainting. The target is left with at least 1 HP."
},

:PAYDAY => {
	:ID => 308,
	:name => "Pay Day",
	:function => 0x109,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "Numerous coins are hurled at the target to inflict damage. Money is earned after the battle."
},

:POUND => {
	:ID => 309,
	:name => "Pound",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 35,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is physically pounded with a long tail, a foreleg, or the like."
},

:QUICKATTACK => {
	:ID => 310,
	:name => "Quick Attack",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:priority => 1,
	:contact => true,
	:kingrock => true,
	:desc => "The user lunges at a speed that makes them almost invisible. This move always goes first."
},

:SCRATCH => {
	:ID => 311,
	:name => "Scratch",
	:function => 0x000,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 35,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "Hard, pointed, sharp claws rake the target to inflict damage."
},

:SNORE => {
	:ID => 312,
	:name => "Snore",
	:function => 0x011,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:soundmove => true,
	:desc => "This attack can be used only if the user is asleep. The harsh noise may also make the target flinch."
},

:DOUBLEHIT => {
	:ID => 313,
	:name => "Double Hit",
	:function => 0x0BD,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 35,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user slams the target with a long tail, vines, or a tentacle. The target is hit twice in a row."
},

:FEINT => {
	:ID => 314,
	:name => "Feint",
	:function => 0x0AD,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 30,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:priority => 2,
	:bypassprotect => true,
	:nonmirror => true,
	:desc => "The user even hits a target using moves like Protect or Detect. These moves' effects are lifted."
},

:TAILSLAP => {
	:ID => 315,
	:name => "Tail Slap",
	:function => 0x0C0,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 25,
	:accuracy => 85,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks by striking the target with a hard tail. It hits the target two to five times in a row."
},

:RAGE => {
	:ID => 316,
	:name => "Rage",
	:function => 0x093,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 20,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "As long as this move is in use, the user's Attack stat raises each time the user is hit."
},

:RAPIDSPIN => {
	:ID => 317,
	:name => "Rapid Spin",
	:function => 0x110,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 20,
	:accuracy => 100,
	:maxpp => 40,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "A spin attack that can also eliminate such moves as Bind, Wrap, Leech Seed, and Spikes."
},

:SPIKECANNON => {
	:ID => 318,
	:name => "Spike Cannon",
	:function => 0x0C0,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 20,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "Sharp spikes are shot at the target in rapid succession. They hit two to five times in a row."
},

:COMETPUNCH => {
	:ID => 319,
	:name => "Comet Punch",
	:function => 0x0C0,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 18,
	:accuracy => 85,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:punchmove => true,
	:desc => "The target is hit with a flurry of punches that strike two to five times in a row."
},

:FURYSWIPES => {
	:ID => 320,
	:name => "Fury Swipes",
	:function => 0x0C0,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 18,
	:accuracy => 80,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is raked with sharp claws or scythes quickly two to five times in a row."
},

:BARRAGE => {
	:ID => 321,
	:name => "Barrage",
	:function => 0x0C0,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 15,
	:accuracy => 85,
	:maxpp => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "Round objects are hurled at the target to strike two to five times in a row."
},

:BIND => {
	:ID => 322,
	:name => "Bind",
	:function => 0x0CF,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 15,
	:accuracy => 85,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "Things such as long bodies or tentacles are used to bind and squeeze the target for four to five turns."
},

:DOUBLESLAP => {
	:ID => 323,
	:name => "Double Slap",
	:function => 0x0C0,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 15,
	:accuracy => 85,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is slapped repeatedly, back and forth, two to five times in a row."
},

:FURYATTACK => {
	:ID => 324,
	:name => "Fury Attack",
	:function => 0x0C0,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 15,
	:accuracy => 85,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is jabbed repeatedly with a horn or beak two to five times in a row."
},

:WRAP => {
	:ID => 325,
	:name => "Wrap",
	:function => 0x0CF,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 15,
	:accuracy => 90,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "A long body, vines, or the like are used to wrap and squeeze the target for four to five turns."
},

:CONSTRICT => {
	:ID => 326,
	:name => "Constrict",
	:function => 0x044,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 10,
	:accuracy => 100,
	:maxpp => 35,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user attacks with long tentacles, vines, or the like. This may lower the target's Speed stat."
},

:BIDE => {
	:ID => 327,
	:name => "Bide",
	:function => 0x0D4,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:priority => 1,
	:contact => true,
	:nonmirror => true,
	:kingrock => true,
	:desc => "The user endures attacks for two turns, then strikes back to cause double the damage taken."
},

:CRUSHGRIP => {
	:ID => 328,
	:name => "Crush Grip",
	:function => 0x08C,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is crushed with great force. The more HP the target has left, the greater this move's power."
},

:ENDEAVOR => {
	:ID => 329,
	:name => "Endeavor",
	:function => 0x06E,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "This attack move cuts down the target's HP to equal the user's HP."
},

:FLAIL => {
	:ID => 330,
	:name => "Flail",
	:function => 0x098,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user flails about aimlessly to attack. The less HP the user has, the greater the move's power."
},

:FRUSTRATION => {
	:ID => 331,
	:name => "Frustration",
	:function => 0x08A,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "This full-power attack grows more powerful the less the user likes their Trainer."
},

:GUILLOTINE => {
	:ID => 332,
	:name => "Guillotine",
	:function => 0x070,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 30,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "A vicious, tearing attack with big pincers. The target faints instantly if this attack hits."
},

:HIDDENPOWER => {
	:ID => 333,
	:name => "Hidden Power",
	:function => 0x090,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HORNDRILL => {
	:ID => 334,
	:name => "Horn Drill",
	:function => 0x070,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 30,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user stabs the target with a horn rotating like a drill. The target faints instantly if hit."
},

:NATURALGIFT => {
	:ID => 335,
	:name => "Natural Gift",
	:function => 0x096,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:desc => "The user draws power to attack by using a held Berry. The Berry determines the move's type and power."
},

:PRESENT => {
	:ID => 336,
	:name => "Present",
	:function => 0x094,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 90,
	:maxpp => 15,
	:target => :SingleNonUser,
	:desc => "The user attacks by giving the target a gift with a hidden trap. It restores HP sometimes, however."
},

:RETURN => {
	:ID => 337,
	:name => "Return",
	:function => 0x089,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "This full-power attack grows more powerful the more the user likes their Trainer."
},

:SONICBOOM => {
	:ID => 338,
	:name => "Sonic Boom",
	:function => 0x06A,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 1,
	:accuracy => 90,
	:maxpp => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The target is hit with a destructive shock wave that always inflicts 20 HP damage."
},

:SPITUP => {
	:ID => 339,
	:name => "Spit Up",
	:function => 0x113,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:nonmirror => true,
	:kingrock => true,
	:desc => "The power stored from Stockpile is released. Storing more power increases damage dealt."
},

:SUPERFANG => {
	:ID => 340,
	:name => "Super Fang",
	:function => 0x06C,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user chomps hard on the target with their sharp front fangs. This cuts the target's HP in half."
},

:TRUMPCARD => {
	:ID => 341,
	:name => "Trump Card",
	:function => 0x097,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 1,
	:accuracy => 0,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The fewer PP this move has, the greater its power."
},

:WRINGOUT => {
	:ID => 342,
	:name => "Wring Out",
	:function => 0x08C,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user powerfully wrings the target. The higher the target's HP still is, the greater the power."
},

:ACUPRESSURE => {
	:ID => 343,
	:name => "Acupressure",
	:function => 0x037,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 30,
	:target => :UserOrPartner,
	:nonmirror => true,
	:desc => "The user pressures stress points, sharply boosting one of their own or their allies' stats."
},

:AFTERYOU => {
	:ID => 344,
	:name => "After You",
	:function => 0x11D,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user helps the target and makes it use its move right after the user."
},

:ASSIST => {
	:ID => 345,
	:name => "Assist",
	:function => 0x0B5,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:nonmirror => true,
	:desc => "The user hurriedly and randomly uses a move among those known by ally Pokémon."
},

:ATTRACT => {
	:ID => 346,
	:name => "Attract",
	:function => 0x016,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "If it is the opposite gender of the user, the target becomes infatuated and less likely to attack."
},

:BATONPASS => {
	:ID => 347,
	:name => "Baton Pass",
	:function => 0x0ED,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 40,
	:target => :User,
	:nonmirror => true,
	:desc => "The user switches places with a party Pokémon in waiting and passes along any stat changes."
},

:BELLYDRUM => {
	:ID => 348,
	:name => "Belly Drum",
	:function => 0x03A,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user maximizes their Attack stat in exchange for HP equal to half their max HP."
},

:BESTOW => {
	:ID => 349,
	:name => "Bestow",
	:function => 0x0F3,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user passes their held item to the target if the target isn't holding an item already."
},

:BLOCK => {
	:ID => 350,
	:name => "Block",
	:function => 0x0EF,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user blocks the target's way with arms spread wide to prevent escape."
},

:CAMOUFLAGE => {
	:ID => 351,
	:name => "Camouflage",
	:function => 0x060,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user's type is changed depending on the environment."
},

:CAPTIVATE => {
	:ID => 352,
	:name => "Captivate",
	:function => 0x04E,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :AllOpposing,
	:magiccoat => true,
	:desc => "Opposing Pokémon of the opposite gender are charmed, and their Sp. Atk stat harshly lowered."
},

:CHARM => {
	:ID => 353,
	:name => "Charm",
	:function => 0x04B,
	:type => :FAIRY,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user gazes rather charmingly, making the target less wary. This harshly lowers its Attack stat."
},

:CONVERSION => {
	:ID => 354,
	:name => "Conversion",
	:function => 0x05E,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 30,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user changes their type to become the same as the move at the top of the list of their known moves."
},

:CONVERSION2 => {
	:ID => 355,
	:name => "Conversion 2",
	:function => 0x05F,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 30,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user changes their type to become resistant to the type of the attack the opponent used last."
},

:COPYCAT => {
	:ID => 356,
	:name => "Copycat",
	:function => 0x0AF,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :NoTarget,
	:desc => "The user mimics the move used immediately before them. It fails if no other move has been used yet."
},

:DEFENSECURL => {
	:ID => 357,
	:name => "Defense Curl",
	:function => 0x01E,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 40,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user curls up to conceal weak spots and raise their Defense stat."
},

:DISABLE => {
	:ID => 358,
	:name => "Disable",
	:function => 0x0B9,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "For four turns, this move prevents the target from using the move it last used."
},

:DOUBLETEAM => {
	:ID => 359,
	:name => "Double Team",
	:function => 0x022,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "By moving rapidly, the user makes illusory copies of themselves to raise their Evasion."
},

:ENCORE => {
	:ID => 360,
	:name => "Encore",
	:function => 0x0BC,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user compels the target to keep using the move that was encored for three turns."
},

:ENDURE => {
	:ID => 361,
	:name => "Endure",
	:function => 0x0E8,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:priority => 3,
	:nonmirror => true,
	:desc => "The user endures any attack with at least 1 HP. Its chance of failing rises if it is used in succession."
},

:ENTRAINMENT => {
	:ID => 362,
	:name => "Entrainment",
	:function => 0x066,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "Forces the target to mimic an odd dance. The target's Ability becomes the same as the user's."
},

:FLASH => {
	:ID => 363,
	:name => "Flash",
	:function => 0x047,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user emits bright light, cutting targets' Accuracy. It can be used to illuminate dark caves."
},

:FOCUSENERGY => {
	:ID => 364,
	:name => "Focus Energy",
	:function => 0x023,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 30,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user takes a deep breath and focuses so that critical hits land more easily."
},

:FOLLOWME => {
	:ID => 365,
	:name => "Follow Me",
	:function => 0x117,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:priority => 3,
	:nonmirror => true,
	:desc => "The user draws attention to themselves, making all targets take aim only at the user."
},

:FORESIGHT => {
	:ID => 366,
	:name => "Foresight",
	:function => 0x0A7,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 40,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "Enables Normal- and Fighting-type attacks to hit Ghost-types. Renders raised Evasion useless."
},

:GLARE => {
	:ID => 367,
	:name => "Glare",
	:function => 0x007,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user intimidates the target with the pattern on their belly to cause paralysis."
},

:GROWL => {
	:ID => 368,
	:name => "Growl",
	:function => 0x042,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 40,
	:target => :AllOpposing,
	:magiccoat => true,
	:soundmove => true,
	:desc => "The user growls in an endearing way, making opposing Pokémon less wary. This lowers their Attack stat."
},

:GROWTH => {
	:ID => 369,
	:name => "Growth",
	:function => 0x028,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user's body grows all at once, raising the Attack and Sp. Atk stats."
},

:HARDEN => {
	:ID => 370,
	:name => "Harden",
	:function => 0x01D,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 30,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user stiffens all the muscles in their body to raise their Defense stat."
},

:HEALBELL => {
	:ID => 371,
	:name => "Heal Bell",
	:function => 0x019,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :BothSides,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user makes a soothing bell chime to heal the status conditions of all the party Pokémon."
},

:HELPINGHAND => {
	:ID => 372,
	:name => "Helping Hand",
	:function => 0x09C,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :Partner,
	:priority => 5,
	:nonmirror => true,
	:desc => "The user assists an ally by boosting the power of that ally's attack."
},

:HOWL => {
	:ID => 373,
	:name => "Howl",
	:function => 0x01C,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 40,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user howls loudly to raise their spirit, which boosts their Attack stat."
},

:LEER => {
	:ID => 374,
	:name => "Leer",
	:function => 0x043,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 30,
	:target => :AllOpposing,
	:magiccoat => true,
	:desc => "The user gives opposing Pokémon an intimidating leer that lowers the Defense stat."
},

:LOCKON => {
	:ID => 375,
	:name => "Lock-On",
	:function => 0x0A6,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :SingleNonUser,
	:desc => "The user takes sure aim at the target. This ensures the next attack does not miss the target."
},

:LOVELYKISS => {
	:ID => 376,
	:name => "Lovely Kiss",
	:function => 0x003,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 75,
	:maxpp => 10,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "With a scary face, the user tries to force a kiss on the target. If it succeeds, the target falls asleep."
},

:LUCKYCHANT => {
	:ID => 377,
	:name => "Lucky Chant",
	:function => 0x0A1,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 30,
	:target => :BothSides,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user chants an incantation, preventing opponents from landing critical hits for five turns."
},

:MEFIRST => {
	:ID => 378,
	:name => "Me First",
	:function => 0x0B0,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleOpposing,
	:nonmirror => true,
	:desc => "The user cuts ahead and uses the target's intended move with greater power. It fails if not used first."
},

:MEANLOOK => {
	:ID => 379,
	:name => "Mean Look",
	:function => 0x0EF,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user pins the target with a dark, arresting look. The target becomes unable to flee."
},

:METRONOME => {
	:ID => 380,
	:name => "Metronome",
	:function => 0x0B6,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :NoTarget,
	:nonmirror => true,
	:desc => "The user waggles a finger and stimulates their brain into randomly using nearly any move."
},

:MILKDRINK => {
	:ID => 381,
	:name => "Milk Drink",
	:function => 0x0D5,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user restores up to half of their max HP. May also be used in the field to heal HP."
},

:MIMIC => {
	:ID => 382,
	:name => "Mimic",
	:function => 0x05C,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user copies the target's last move. This move can be used until the Pokémon is switched out."
},

:MINDREADER => {
	:ID => 383,
	:name => "Mind Reader",
	:function => 0x0A6,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :SingleNonUser,
	:desc => "The user senses the target's movements to ensure the next attack hitting the target."
},

:MINIMIZE => {
	:ID => 384,
	:name => "Minimize",
	:function => 0x034,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user compresses their body to make themselves look smaller, sharply raising their Evasion."
},

:MOONLIGHT => {
	:ID => 385,
	:name => "Moonlight",
	:function => 0x0D8,
	:type => :FAIRY,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user restores their own HP. The amount of HP regained varies with the weather."
},

:MORNINGSUN => {
	:ID => 386,
	:name => "Morning Sun",
	:function => 0x0D8,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user restores their own HP. The amount of HP regained varies with the weather."
},

:NATUREPOWER => {
	:ID => 387,
	:name => "Nature Power",
	:function => 0x0B3,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "This attack makes use of nature's power. Its effects vary depending on the user's environment."
},

:ODORSLEUTH => {
	:ID => 388,
	:name => "Odor Sleuth",
	:function => 0x0A7,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 40,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "Enables Normal- and Fighting-type moves to hit Ghost-types. It also negates raised Evasion."
},

:PAINSPLIT => {
	:ID => 389,
	:name => "Pain Split",
	:function => 0x05A,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:desc => "The user adds their HP to the target's HP, then equally shares the combined HP with the target."
},

:PERISHSONG => {
	:ID => 390,
	:name => "Perish Song",
	:function => 0x0E5,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :UserSide,
	:nonmirror => true,
	:soundmove => true,
	:desc => "Any Pokémon that hears this song faints in three turns, unless it switches out of battle."
},

:PROTECT => {
	:ID => 391,
	:name => "Protect",
	:function => 0x0AA,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:priority => 4,
	:nonmirror => true,
	:desc => "Enables the user to evade all attacks. Its chance of failing rises if it is used in succession."
},

:PSYCHUP => {
	:ID => 392,
	:name => "Psych Up",
	:function => 0x055,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user hypnotizes themselves into copying any stat change made by the target."
},

:RECOVER => {
	:ID => 393,
	:name => "Recover",
	:function => 0x0D5,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "Regenerating their own cells, the user restores up to half of their max HP."
},

:RECYCLE => {
	:ID => 394,
	:name => "Recycle",
	:function => 0x0F6,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user recycles a held item that has been used in battle so it can be used again."
},

:REFLECTTYPE => {
	:ID => 395,
	:name => "Reflect Type",
	:function => 0x062,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user reflects the target's type, becoming the same type as the target."
},

:REFRESH => {
	:ID => 396,
	:name => "Refresh",
	:function => 0x018,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user rests to cure themselves of a poisoning, burn, or paralysis."
},

:ROAR => {
	:ID => 397,
	:name => "Roar",
	:function => 0x0EB,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:priority => -6,
	:magiccoat => true,
	:nonmirror => true,
	:soundmove => true,
	:desc => "The target is scared off, and a different Pokémon is dragged out. Ends the battle in the wild."
},

:SAFEGUARD => {
	:ID => 398,
	:name => "Safeguard",
	:function => 0x01A,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 25,
	:target => :BothSides,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user creates a protective field that prevents status conditions for five turns."
},

:SCARYFACE => {
	:ID => 399,
	:name => "Scary Face",
	:function => 0x04D,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user frightens the target with a scary face to harshly lower its Speed stat."
},

:SCREECH => {
	:ID => 400,
	:name => "Screech",
	:function => 0x04C,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 85,
	:maxpp => 40,
	:target => :SingleNonUser,
	:magiccoat => true,
	:soundmove => true,
	:desc => "An earsplitting screech harshly lowers the target's Defense stat."
},

:SHARPEN => {
	:ID => 401,
	:name => "Sharpen",
	:function => 0x01C,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 30,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user makes their edges more jagged, which raises their Attack stat."
},

:SHELLSMASH => {
	:ID => 402,
	:name => "Shell Smash",
	:function => 0x035,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user lowers their Defense and Sp. Def stats to sharply raise their Attack, Sp. Atk, and Speed."
},

:SIMPLEBEAM => {
	:ID => 403,
	:name => "Simple Beam",
	:function => 0x063,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user's mysterious psychic wave changes the target's Ability to Simple."
},

:SING => {
	:ID => 404,
	:name => "Sing",
	:function => 0x003,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 55,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:soundmove => true,
	:desc => "A soothing lullaby is sung in a calming voice that puts the target into a deep slumber."
},

:SKETCH => {
	:ID => 405,
	:name => "Sketch",
	:function => 0x05D,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 1,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user permanently learns the move last used by the target. After using it, Sketch itself disappears."
},

:SLACKOFF => {
	:ID => 406,
	:name => "Slack Off",
	:function => 0x0D5,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user slacks off, restoring up to half of their max HP."
},

:SLEEPTALK => {
	:ID => 407,
	:name => "Sleep Talk",
	:function => 0x0B4,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :NoTarget,
	:nonmirror => true,
	:desc => "While being asleep, the user randomly uses one of the moves they know."
},

:SMOKESCREEN => {
	:ID => 408,
	:name => "Smokescreen",
	:function => 0x047,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user releases an obscuring cloud of smoke or ink. This lowers the target's Accuracy."
},

:SOFTBOILED => {
	:ID => 409,
	:name => "Soft-Boiled",
	:function => 0x0D5,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user restores up to half of their max HP. May also be used in the field to heal HP."
},

:SPLASH => {
	:ID => 410,
	:name => "Splash",
	:function => 0x001,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 40,
	:target => :SingleNonUser,
	:nonmirror => true,
	:gravityblocked => true,
	:desc => "The user just flops and splashes around to no effect at all..."
},

:STOCKPILE => {
	:ID => 411,
	:name => "Stockpile",
	:function => 0x112,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user charges up power, raising both Defense and Sp. Def. stats. The move can be used three times."
},

:SUBSTITUTE => {
	:ID => 412,
	:name => "Substitute",
	:function => 0x10C,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user makes a copy of themselves using some of their HP. The copy serves as the user's decoy."
},

:SUPERSONIC => {
	:ID => 413,
	:name => "Supersonic",
	:function => 0x013,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 55,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:soundmove => true,
	:desc => "The user generates odd sound waves from their body that confuse the target."
},

:SWAGGER => {
	:ID => 414,
	:name => "Swagger",
	:function => 0x041,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 85,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user enrages and confuses the target. However, this also sharply raises the target's Attack stat."
},

:SWALLOW => {
	:ID => 415,
	:name => "Swallow",
	:function => 0x114,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The power stored from Stockpile is absorbed. Storing more power heals more HP."
},

:SWEETKISS => {
	:ID => 416,
	:name => "Sweet Kiss",
	:function => 0x013,
	:type => :FAIRY,
	:category => :status,
	:basedamage => 0,
	:accuracy => 75,
	:maxpp => 10,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user kisses the target with a sweet, angelic cuteness that causes confusion."
},

:SWEETSCENT => {
	:ID => 417,
	:name => "Sweet Scent",
	:function => 0x048,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :AllOpposing,
	:magiccoat => true,
	:desc => "A sweet scent that harshly lowers opposing Pokémons' Evasion."
},

:SWORDSDANCE => {
	:ID => 418,
	:name => "Swords Dance",
	:function => 0x02E,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "A frenetic dance to uplift the fighting spirit. This sharply raises the user's Attack stat."
},

:TAILWHIP => {
	:ID => 419,
	:name => "Tail Whip",
	:function => 0x043,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 30,
	:target => :AllOpposing,
	:magiccoat => true,
	:desc => "The user wags their tail cutely, making opposing Pokémon less wary and lowering their Defense stat."
},

:TEETERDANCE => {
	:ID => 420,
	:name => "Teeter Dance",
	:function => 0x013,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :AllNonUsers,
	:desc => "The user performs a wobbly dance that confuses the Pokémon around them."
},

:TICKLE => {
	:ID => 421,
	:name => "Tickle",
	:function => 0x04A,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user tickles the target into laughing, reducing its Attack and Defense stats."
},

:TRANSFORM => {
	:ID => 422,
	:name => "Transform",
	:function => 0x069,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user transforms into a copy of the target right down to having the same move set."
},

:WHIRLWIND => {
	:ID => 423,
	:name => "Whirlwind",
	:function => 0x0EB,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:priority => -6,
	:magiccoat => true,
	:nonmirror => true,
	:desc => "The target is blown away, and a different Pokémon is dragged out. Ends the battle in the wild."
},

:WISH => {
	:ID => 424,
	:name => "Wish",
	:function => 0x0D7,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "One turn after using this move, the user's or their replacement's HP is restored by half the user's max HP."
},

:WORKUP => {
	:ID => 425,
	:name => "Work Up",
	:function => 0x027,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 30,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user is roused, and their Attack and Sp. Atk stats increase."
},

:YAWN => {
	:ID => 426,
	:name => "Yawn",
	:function => 0x004,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user lets loose a huge yawn that lulls the target into falling asleep on the next turn."
},

:GUNKSHOT => {
	:ID => 427,
	:name => "Gunk Shot",
	:function => 0x005,
	:type => :POISON,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 80,
	:maxpp => 5,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user shoots filthy garbage at the target to attack. This may also poison the target."
},

:SLUDGEWAVE => {
	:ID => 428,
	:name => "Sludge Wave",
	:function => 0x005,
	:type => :POISON,
	:category => :special,
	:basedamage => 95,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 10,
	:target => :AllNonUsers,
	:desc => "The user strikes everything around by swamping the area. This may also poison those hit."
},

:SLUDGEBOMB => {
	:ID => 429,
	:name => "Sludge Bomb",
	:function => 0x005,
	:type => :POISON,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 30,
	:target => :SingleNonUser,
	:desc => "Unsanitary sludge is hurled at the target. This may also poison the target."
},

:POISONJAB => {
	:ID => 430,
	:name => "Poison Jab",
	:function => 0x005,
	:type => :POISON,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is stabbed with a tentacle or arm steeped in poison. This may also poison the target."
},

:CROSSPOISON => {
	:ID => 431,
	:name => "Cross Poison",
	:function => 0x005,
	:type => :POISON,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:highcrit => true,
	:desc => "A slashing attack with a poisonous blade that may also poison the target. Critical hits land more easily."
},

:SLUDGE => {
	:ID => 432,
	:name => "Sludge",
	:function => 0x005,
	:type => :POISON,
	:category => :special,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 30,
	:target => :SingleNonUser,
	:desc => "Unsanitary sludge is hurled at the target. This may also poison the target."
},

:VENOSHOCK => {
	:ID => 433,
	:name => "Venoshock",
	:function => 0x07B,
	:type => :POISON,
	:category => :special,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks with a special poisonous liquid. If the target is poisoned, the power is doubled."
},

:CLEARSMOG => {
	:ID => 434,
	:name => "Clear Smog",
	:function => 0x050,
	:type => :POISON,
	:category => :special,
	:basedamage => 50,
	:accuracy => 0,
	:maxpp => 15,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks by throwing a clump of special mud. All stat changes are returned to normal."
},

:POISONFANG => {
	:ID => 435,
	:name => "Poison Fang",
	:function => 0x006,
	:type => :POISON,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 50,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user bites the target with toxic fangs. This may also leave the target badly poisoned."
},

:POISONTAIL => {
	:ID => 436,
	:name => "Poison Tail",
	:function => 0x005,
	:type => :POISON,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 25,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:highcrit => true,
	:desc => "The user hits the target with a tail. This may also poison the target. Critical hits land more easily."
},

:ACID => {
	:ID => 437,
	:name => "Acid",
	:function => 0x046,
	:type => :POISON,
	:category => :special,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 30,
	:effect => 10,
	:target => :AllOpposing,
	:desc => "The opposing Pokémon are attacked with a spray of harsh acid. This may also lower their Sp. Def stat."
},

:ACIDSPRAY => {
	:ID => 438,
	:name => "Acid Spray",
	:function => 0x04F,
	:type => :POISON,
	:category => :special,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 100,
	:target => :SingleNonUser,
	:desc => "The user spits fluid that works to melt the target. This harshly lowers the target's Sp. Def stat."
},

:SMOG => {
	:ID => 439,
	:name => "Smog",
	:function => 0x005,
	:type => :POISON,
	:category => :special,
	:basedamage => 30,
	:accuracy => 70,
	:maxpp => 20,
	:effect => 40,
	:target => :SingleNonUser,
	:desc => "The target is attacked with a discharge of filthy gases. This may also poison the target."
},

:POISONSTING => {
	:ID => 440,
	:name => "Poison Sting",
	:function => 0x005,
	:type => :POISON,
	:category => :physical,
	:basedamage => 15,
	:accuracy => 100,
	:maxpp => 35,
	:effect => 30,
	:target => :SingleNonUser,
	:desc => "The user stabs the target with a poisonous stinger. This may also poison the target."
},

:ACIDARMOR => {
	:ID => 441,
	:name => "Acid Armor",
	:function => 0x02F,
	:type => :POISON,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user alters their cellular structure to liquefy themselves, sharply raising their Defense stat."
},

:COIL => {
	:ID => 442,
	:name => "Coil",
	:function => 0x025,
	:type => :POISON,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user coils up and concentrates. This raises their Attack and Defense stats as well as their Accuracy."
},

:GASTROACID => {
	:ID => 443,
	:name => "Gastro Acid",
	:function => 0x068,
	:type => :POISON,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "Hurls up stomach acids on the target. The fluid eliminates the effect of the target's Ability."
},

:POISONGAS => {
	:ID => 444,
	:name => "Poison Gas",
	:function => 0x005,
	:type => :POISON,
	:category => :status,
	:basedamage => 0,
	:accuracy => 90,
	:maxpp => 40,
	:target => :AllOpposing,
	:magiccoat => true,
	:desc => "A cloud of poison gas is sprayed in the face of opposing Pokémon, poisoning those hit."
},

:POISONPOWDER => {
	:ID => 445,
	:name => "Poison Powder",
	:function => 0x005,
	:type => :POISON,
	:category => :status,
	:basedamage => 0,
	:accuracy => 75,
	:maxpp => 35,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user scatters a cloud of poisonous dust that poisons the target."
},

:TOXIC => {
	:ID => 446,
	:name => "Toxic",
	:function => 0x006,
	:type => :POISON,
	:category => :status,
	:basedamage => 0,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "A move that leaves the target badly poisoned. Its poison damage worsens every turn."
},

:TOXICSPIKES => {
	:ID => 447,
	:name => "Toxic Spikes",
	:function => 0x104,
	:type => :POISON,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :OpposingSide,
	:magiccoat => true,
	:nonmirror => true,
	:desc => "The user lays a trap of poison spikes. This poisons opposing Pokémon that switch into battle."
},

:PSYCHOBOOST => {
	:ID => 448,
	:name => "Psycho Boost",
	:function => 0x03F,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 140,
	:accuracy => 90,
	:maxpp => 5,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks the target at full power. The attack's recoil harshly lowers the user's Sp. Atk stat."
},

:DREAMEATER => {
	:ID => 449,
	:name => "Dream Eater",
	:function => 0x0DE,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:desc => "The user eats the dreams of a sleeping target. It absorbs half the damage to heal its own HP."
},

:FUTURESIGHT => {
	:ID => 450,
	:name => "Future Sight",
	:function => 0x111,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:bypassprotect => true,
	:nonmirror => true,
	:desc => "Two turns after this move is used, a hunk of psychic energy attacks the target."
},

:PSYSTRIKE => {
	:ID => 451,
	:name => "Psystrike",
	:function => 0x122,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user materializes an odd psychic wave to attack the target. This attack does physical damage."
},

:PSYCHIC => {
	:ID => 452,
	:name => "Psychic",
	:function => 0x046,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "The target is hit by a strong telekinetic force. This may also lower the target's Sp. Def stat."
},

:EXTRASENSORY => {
	:ID => 453,
	:name => "Extrasensory",
	:function => 0x00F,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "The user attacks with an odd, unseeable power. This may also make the target flinch."
},

:PSYSHOCK => {
	:ID => 454,
	:name => "Psyshock",
	:function => 0x122,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user materializes an odd psychic wave to attack the target. This attack does physical damage."
},

:ZENHEADBUTT => {
	:ID => 455,
	:name => "Zen Headbutt",
	:function => 0x00F,
	:type => :PSYCHIC,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 90,
	:maxpp => 15,
	:effect => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user focuses their willpower to their head and attacks. It may make the target flinch."
},

:LUSTERPURGE => {
	:ID => 456,
	:name => "Luster Purge",
	:function => 0x046,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 5,
	:effect => 50,
	:target => :SingleNonUser,
	:desc => "The user lets loose a damaging burst of light. This may also lower the target's Sp. Def stat."
},

:MISTBALL => {
	:ID => 457,
	:name => "Mist Ball",
	:function => 0x045,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 5,
	:effect => 50,
	:target => :SingleNonUser,
	:desc => "A mist-like flurry of down envelops the target. This may also lower the target's Sp. Atk stat."
},

:PSYCHOCUT => {
	:ID => 458,
	:name => "Psycho Cut",
	:function => 0x000,
	:type => :PSYCHIC,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:highcrit => true,
	:desc => "The user tears at the target with blades formed by psychic power. Critical hits land more easily."
},

:SYNCHRONOISE => {
	:ID => 459,
	:name => "Synchronoise",
	:function => 0x123,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 15,
	:target => :AllNonUsers,
	:kingrock => true,
	:desc => "The user inflicts damage on any Pokémon of the same type with an odd shock wave."
},

:PSYBEAM => {
	:ID => 460,
	:name => "Psybeam",
	:function => 0x013,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "The target is attacked with a peculiar ray. This may also leave the target confused."
},

:HEARTSTAMP => {
	:ID => 461,
	:name => "Heart Stamp",
	:function => 0x00F,
	:type => :PSYCHIC,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 25,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user unleashes a vicious blow after fooling the target. This may make the target flinch."
},

:CONFUSION => {
	:ID => 462,
	:name => "Confusion",
	:function => 0x013,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 25,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "The target is hit by a weak telekinetic force. This may also confuse the target."
},

:MIRRORCOAT => {
	:ID => 463,
	:name => "Mirror Coat",
	:function => 0x072,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 20,
	:target => :NoTarget,
	:priority => -5,
	:nonmirror => true,
	:desc => "A retaliation move that counters any special attack, inflicting double the damage taken."
},

:PSYWAVE => {
	:ID => 464,
	:name => "Psywave",
	:function => 0x06F,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The target is attacked with an odd psychic wave. The attack varies in intensity."
},

:STOREDPOWER => {
	:ID => 465,
	:name => "Stored Power",
	:function => 0x08E,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks with stored power. The more the user's stats are raised, the greater the power."
},

:AGILITY => {
	:ID => 466,
	:name => "Agility",
	:function => 0x030,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 30,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user relaxes and lightens their body to move faster. This sharply raises the Speed stat."
},

:ALLYSWITCH => {
	:ID => 467,
	:name => "Ally Switch",
	:function => 0x120,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :User,
	:priority => -1,
	:nonmirror => true,
	:desc => "The user teleports using a strange power and switches places with an ally or a party Pokémon."
},

:AMNESIA => {
	:ID => 468,
	:name => "Amnesia",
	:function => 0x033,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user empties their mind to forget their concerns. This sharply raises the user's Sp. Def stat."
},

:BARRIER => {
	:ID => 469,
	:name => "Barrier",
	:function => 0x02F,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user throws up a sturdy wall that sharply raises their Defense stat."
},

:CALMMIND => {
	:ID => 470,
	:name => "Calm Mind",
	:function => 0x02C,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user quietly focuses their mind and calms their spirit to raise their Sp. Atk and Sp. Def stats."
},

:COSMICPOWER => {
	:ID => 471,
	:name => "Cosmic Power",
	:function => 0x02A,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user absorbs a mystical power from space to raise their Defense and Sp. Def stats."
},

:GRAVITY => {
	:ID => 472,
	:name => "Gravity",
	:function => 0x118,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :UserSide,
	:nonmirror => true,
	:desc => "Gravity is intensified for five turns, making moves involving flying unusable and negating Levitate."
},

:GUARDSPLIT => {
	:ID => 473,
	:name => "Guard Split",
	:function => 0x059,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "Employs psychic power to average the user's Defense and Sp. Def stats with the target's."
},

:GUARDSWAP => {
	:ID => 474,
	:name => "Guard Swap",
	:function => 0x053,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:desc => "The user employs their psychic power to switch changes of Defense and Sp. Def stats with the target."
},

:HEALBLOCK => {
	:ID => 475,
	:name => "Heal Block",
	:function => 0x0BB,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :AllOpposing,
	:magiccoat => true,
	:desc => "The user prevents opponents from using moves, Abilities or held items to recover HP for five turns."
},

:HEALPULSE => {
	:ID => 476,
	:name => "Heal Pulse",
	:function => 0x0DF,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:magiccoat => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user emits a healing pulse that restores the target's HP by up to half of its max HP."
},

:HEALINGWISH => {
	:ID => 477,
	:name => "Healing Wish",
	:function => 0x0E3,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user faints. The Pokémon taking their place will have its HP restored and status conditions cured."
},

:HEARTSWAP => {
	:ID => 478,
	:name => "Heart Swap",
	:function => 0x054,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:desc => "The user employs their psychic power to switch stat changes with the target."
},

:HYPNOSIS => {
	:ID => 479,
	:name => "Hypnosis",
	:function => 0x003,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 60,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user employs hypnotic suggestion to make the target fall into a deep sleep."
},

:IMPRISON => {
	:ID => 480,
	:name => "Imprison",
	:function => 0x0B8,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "If opposing Pokémon know any move also known by the user, they are prevented from using it."
},

:KINESIS => {
	:ID => 481,
	:name => "Kinesis",
	:function => 0x047,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 80,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user distracts the target by bending a spoon. This lowers the target's Accuracy."
},

:LIGHTSCREEN => {
	:ID => 482,
	:name => "Light Screen",
	:function => 0x0A3,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 30,
	:target => :BothSides,
	:snatchable => true,
	:nonmirror => true,
	:desc => "A wondrous wall of light is put up to reduce damage from special attacks for five turns."
},

:LUNARDANCE => {
	:ID => 483,
	:name => "Lunar Dance",
	:function => 0x0E4,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user faints. The Pokémon taking their place will have its status and HP fully restored."
},

:MAGICCOAT => {
	:ID => 484,
	:name => "Magic Coat",
	:function => 0x0B1,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :User,
	:priority => 4,
	:nonmirror => true,
	:desc => "The user creates a barrier that reflects back moves like Leech Seed and most status moves."
},

:MAGICROOM => {
	:ID => 485,
	:name => "Magic Room",
	:function => 0x0F9,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :UserSide,
	:desc => "The user creates a bizarre area in which Pokémons' held items lose their effects for five turns."
},

:MEDITATE => {
	:ID => 486,
	:name => "Meditate",
	:function => 0x01C,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 40,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user meditates to awaken the power deep within their body and raise their Attack stat."
},

:MIRACLEEYE => {
	:ID => 487,
	:name => "Miracle Eye",
	:function => 0x0A8,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 40,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "Enables Psychic-type attacks to hit Dark-types. Renders a target's raised Evasion useless."
},

:POWERSPLIT => {
	:ID => 488,
	:name => "Power Split",
	:function => 0x058,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user employs their psychic power to average Attack and Sp. Atk stats with those of the target."
},

:POWERSWAP => {
	:ID => 489,
	:name => "Power Swap",
	:function => 0x052,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:desc => "The user employs psychic power to switch changes of Attack and Sp. Atk stats with the target."
},

:POWERTRICK => {
	:ID => 490,
	:name => "Power Trick",
	:function => 0x057,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user employs their psychic power to switch their Attack and Defense stat."
},

:PSYCHOSHIFT => {
	:ID => 491,
	:name => "Psycho Shift",
	:function => 0x01B,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:desc => "Using their psychic power of suggestion, the user transfers status conditions to the target."
},

:REFLECT => {
	:ID => 492,
	:name => "Reflect",
	:function => 0x0A2,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :BothSides,
	:snatchable => true,
	:nonmirror => true,
	:desc => "A wondrous wall of light is put up to reduce damage from physical attacks for five turns."
},

:REST => {
	:ID => 493,
	:name => "Rest",
	:function => 0x0D9,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user sleeps for two turns. The user's HP are restored and any status conditions healed."
},

:ROLEPLAY => {
	:ID => 494,
	:name => "Role Play",
	:function => 0x065,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user mimics the target completely, copying the target's natural Ability."
},

:SKILLSWAP => {
	:ID => 495,
	:name => "Skill Swap",
	:function => 0x067,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:desc => "The user employs their psychic power to exchange Abilities with the target."
},

:TELEKINESIS => {
	:ID => 496,
	:name => "Telekinesis",
	:function => 0x11A,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:gravityblocked => true,
	:desc => "The user makes the target float with psychic power. The target is easier to hit for three turns."
},

:TELEPORT => {
	:ID => 497,
	:name => "Teleport",
	:function => 0x0EA,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:nonmirror => true,
	:desc => "Use it to flee from any wild Pokémon. It can also warp to the last Pokémon Center visited."
},

:TRICK => {
	:ID => 498,
	:name => "Trick",
	:function => 0x0F2,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user catches the target off guard and swaps held items."
},

:TRICKROOM => {
	:ID => 499,
	:name => "Trick Room",
	:function => 0x11F,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :UserSide,
	:priority => -7,
	:desc => "The user creates a bizarre area in which slower Pokémon get to move first for five turns."
},

:WONDERROOM => {
	:ID => 500,
	:name => "Wonder Room",
	:function => 0x124,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :UserSide,
	:desc => "The user creates a bizarre area in which Defense and Sp. Def stats are swapped for five turns."
},

:HEADSMASH => {
	:ID => 501,
	:name => "Head Smash",
	:function => 0x0FC,
	:type => :ROCK,
	:category => :physical,
	:basedamage => 150,
	:accuracy => 80,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks with a hazardous, full-power headbutt. This also damages the user terribly."
},

:ROCKWRECKER => {
	:ID => 502,
	:name => "Rock Wrecker",
	:function => 0x0C2,
	:type => :ROCK,
	:category => :physical,
	:basedamage => 150,
	:accuracy => 90,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user launches a huge boulder at the target to attack. The user can't move on the next turn."
},

:STONEEDGE => {
	:ID => 503,
	:name => "Stone Edge",
	:function => 0x000,
	:type => :ROCK,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 80,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:highcrit => true,
	:desc => "The user stabs the target from below with sharpened stones. Critical hits land more easily."
},

:ROCKSLIDE => {
	:ID => 504,
	:name => "Rock Slide",
	:function => 0x00F,
	:type => :ROCK,
	:category => :physical,
	:basedamage => 75,
	:accuracy => 90,
	:maxpp => 10,
	:effect => 30,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "Large boulders are hurled at the targets to inflict damage. The opposing Pokémon may flinch."
},

:POWERGEM => {
	:ID => 505,
	:name => "Power Gem",
	:function => 0x000,
	:type => :ROCK,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks with a ray of light that sparkles as if it were made of gemstones."
},

:ANCIENTPOWER => {
	:ID => 506,
	:name => "Ancient Power",
	:function => 0x02D,
	:type => :ROCK,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 5,
	:effect => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks with a ray of light that sparkles as if it were made of gemstones."
},

:ROCKTHROW => {
	:ID => 507,
	:name => "Rock Throw",
	:function => 0x000,
	:type => :ROCK,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 90,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user picks up and throws a small rock at the target to attack."
},

:ROCKTOMB => {
	:ID => 508,
	:name => "Rock Tomb",
	:function => 0x044,
	:type => :ROCK,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 95,
	:maxpp => 15,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "Boulders are hurled at the target. This also lowers the target's Speed stat."
},

:SMACKDOWN => {
	:ID => 509,
	:name => "Smack Down",
	:function => 0x11C,
	:type => :ROCK,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user throws a stone or a similar projectile to attack. Flying Pokémon fall to the ground when hit."
},

:ROLLOUT => {
	:ID => 510,
	:name => "Rollout",
	:function => 0x0D3,
	:type => :ROCK,
	:category => :physical,
	:basedamage => 30,
	:accuracy => 90,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user continually rolls into the target over five turns. It becomes more powerful with each hit."
},

:ROCKBLAST => {
	:ID => 511,
	:name => "Rock Blast",
	:function => 0x0C0,
	:type => :ROCK,
	:category => :physical,
	:basedamage => 25,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user hurls hard rocks at the target. Two to five rocks are launched in a row."
},

:ROCKPOLISH => {
	:ID => 512,
	:name => "Rock Polish",
	:function => 0x030,
	:type => :ROCK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user polishes their body to reduce drag. This sharply raises the user's Speed stat."
},

:SANDSTORM => {
	:ID => 513,
	:name => "Sandstorm",
	:function => 0x101,
	:type => :ROCK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :UserSide,
	:nonmirror => true,
	:desc => "A five-turn sandstorm is summoned to hurt all combatants except the Rock-, Ground-, and Steel-types."
},

:STEALTHROCK => {
	:ID => 514,
	:name => "Stealth Rock",
	:function => 0x105,
	:type => :ROCK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :OpposingSide,
	:magiccoat => true,
	:nonmirror => true,
	:desc => "The user lays a trap of levitating stones. The trap hurts opponents that switch into battle."
},

:WIDEGUARD => {
	:ID => 515,
	:name => "Wide Guard",
	:function => 0x0AC,
	:type => :ROCK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :BothSides,
	:priority => 3,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user and their allies are protected from wide-ranging attacks for one turn."
},

:DOOMDESIRE => {
	:ID => 516,
	:name => "Doom Desire",
	:function => 0x111,
	:type => :STEEL,
	:category => :special,
	:basedamage => 140,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:bypassprotect => true,
	:nonmirror => true,
	:desc => "Two turns after this move is used, the user blasts the target with a concentrated bundle of light."
},

:IRONTAIL => {
	:ID => 517,
	:name => "Iron Tail",
	:function => 0x043,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 75,
	:maxpp => 15,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The target is slammed with a steel-hard tail. This may also lower the target's Defense stat."
},

:METEORMASH => {
	:ID => 518,
	:name => "Meteor Mash",
	:function => 0x01C,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 90,
	:maxpp => 10,
	:effect => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:punchmove => true,
	:desc => "The target is hit with a hard punch fired like a meteor. This may also raise the user's Attack stat."
},

:FLASHCANNON => {
	:ID => 519,
	:name => "Flash Cannon",
	:function => 0x046,
	:type => :STEEL,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user gathers their light energy and releases it all. This may lower the target's Sp. Def stat."
},

:IRONHEAD => {
	:ID => 520,
	:name => "Iron Head",
	:function => 0x00F,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user slams the target with their steel-hard head. This may also make the target flinch."
},

:STEELWING => {
	:ID => 521,
	:name => "Steel Wing",
	:function => 0x01D,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 90,
	:maxpp => 25,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is hit with wings of steel. This may also raise the user's Defense stat."
},

:MIRRORSHOT => {
	:ID => 522,
	:name => "Mirror Shot",
	:function => 0x047,
	:type => :STEEL,
	:category => :special,
	:basedamage => 65,
	:accuracy => 85,
	:maxpp => 10,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user lets loose a flash of energy from their polished body. This may lower the target's Accuracy."
},

:MAGNETBOMB => {
	:ID => 523,
	:name => "Magnet Bomb",
	:function => 0x0A5,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user launches steel bombs that stick to the target. This attack never misses."
},

:GEARGRIND => {
	:ID => 524,
	:name => "Gear Grind",
	:function => 0x0BD,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 85,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks by throwing steel gears at the target twice."
},

:METALCLAW => {
	:ID => 525,
	:name => "Metal Claw",
	:function => 0x01C,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 95,
	:maxpp => 35,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The target is raked with steel claws. This may also raise the user's Attack stat."
},

:BULLETPUNCH => {
	:ID => 526,
	:name => "Bullet Punch",
	:function => 0x000,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:priority => 1,
	:contact => true,
	:kingrock => true,
	:punchmove => true,
	:desc => "The user strikes the target with tough punches as fast as bullets. This move always goes first."
},

:GYROBALL => {
	:ID => 527,
	:name => "Gyro Ball",
	:function => 0x08D,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user whirls in a high-speed spin. The slower the user is than the target, the greater the power."
},

:HEAVYSLAM => {
	:ID => 528,
	:name => "Heavy Slam",
	:function => 0x09B,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user slams with their heavy body. The heavier the user is than the target, the greater the power."
},

:METALBURST => {
	:ID => 529,
	:name => "Metal Burst",
	:function => 0x073,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 1,
	:accuracy => 100,
	:maxpp => 10,
	:target => :NoTarget,
	:desc => "The user retaliates with greater force against the opponent that last inflicted damage on them."
},

:AUTOTOMIZE => {
	:ID => 530,
	:name => "Autotomize",
	:function => 0x031,
	:type => :STEEL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user sheds part of their body to make themselves lighter and sharply raise their Speed stat."
},

:IRONDEFENSE => {
	:ID => 531,
	:name => "Iron Defense",
	:function => 0x02F,
	:type => :STEEL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user hardens their body's surface like iron, sharply raising their Defense stat."
},

:METALSOUND => {
	:ID => 532,
	:name => "Metal Sound",
	:function => 0x04F,
	:type => :STEEL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 85,
	:maxpp => 40,
	:target => :SingleNonUser,
	:magiccoat => true,
	:soundmove => true,
	:desc => "A horrible sound like scraping metal harshly lowers the target's Sp. Def stat."
},

:SHIFTGEAR => {
	:ID => 533,
	:name => "Shift Gear",
	:function => 0x036,
	:type => :STEEL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user rotates their gears, raising the Attack stat and sharply raising the Speed stat."
},

:HYDROCANNON => {
	:ID => 534,
	:name => "Hydro Cannon",
	:function => 0x0C2,
	:type => :WATER,
	:category => :special,
	:basedamage => 150,
	:accuracy => 90,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The target is hit with a watery blast. The user can't move on the next turn."
},

:WATERSPOUT => {
	:ID => 535,
	:name => "Water Spout",
	:function => 0x08B,
	:type => :WATER,
	:category => :special,
	:basedamage => 150,
	:accuracy => 100,
	:maxpp => 5,
	:target => :AllOpposing,
	:desc => "The user spouts water against opposing Pokémon. The lower the user's HP, the lower the power."
},

:HYDROPUMP => {
	:ID => 536,
	:name => "Hydro Pump",
	:function => 0x000,
	:type => :WATER,
	:category => :special,
	:basedamage => 110,
	:accuracy => 80,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The target is blasted by a huge volume of water launched under great pressure."
},

:MUDDYWATER => {
	:ID => 537,
	:name => "Muddy Water",
	:function => 0x047,
	:type => :WATER,
	:category => :special,
	:basedamage => 90,
	:accuracy => 85,
	:maxpp => 10,
	:effect => 30,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "The user attacks by shooting muddy water at the opposing Pokémon. This may also lower their Accuracy."
},

:SURF => {
	:ID => 538,
	:name => "Surf",
	:function => 0x075,
	:type => :WATER,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 15,
	:target => :AllNonUsers,
	:kingrock => true,
	:desc => "The user swamps their surroundings with a giant wave. It can also be used for crossing water."
},

:AQUATAIL => {
	:ID => 539,
	:name => "Aqua Tail",
	:function => 0x000,
	:type => :WATER,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks by swinging their tail as if it were a vicious wave in a raging storm."
},

:CRABHAMMER => {
	:ID => 540,
	:name => "Crabhammer",
	:function => 0x000,
	:type => :WATER,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:highcrit => true,
	:desc => "The target is hammered with a large pincer. Critical hits land more easily."
},

:DIVE => {
	:ID => 541,
	:name => "Dive",
	:function => 0x0CB,
	:type => :WATER,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "Dives on the first turn, floats up and attacks on the next turn. Can be used to dive deep into water."
},

:SCALD => {
	:ID => 542,
	:name => "Scald",
	:function => 0x00A,
	:type => :WATER,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:defrost => true,
	:desc => "The user shoots boiling hot water at the target. This may also leave the target with a burn."
},

:WATERFALL => {
	:ID => 543,
	:name => "Waterfall",
	:function => 0x00F,
	:type => :WATER,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user charges at the target and may make it flinch. This can also be used to climb a waterfall."
},

:RAZORSHELL => {
	:ID => 544,
	:name => "Razor Shell",
	:function => 0x043,
	:type => :WATER,
	:category => :physical,
	:basedamage => 75,
	:accuracy => 95,
	:maxpp => 10,
	:effect => 50,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "The user cuts the target with sharp shells. This may also lower the target's Defense stat."
},

:BRINE => {
	:ID => 545,
	:name => "Brine",
	:function => 0x080,
	:type => :WATER,
	:category => :special,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "If the target's HP is half or less, this attack will hit with double the power."
},

:BUBBLEBEAM => {
	:ID => 546,
	:name => "Bubble Beam",
	:function => 0x044,
	:type => :WATER,
	:category => :special,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 10,
	:target => :SingleNonUser,
	:desc => "A spray of bubbles is forcefully ejected at the target. This may also lower its Speed stat."
},

:OCTAZOOKA => {
	:ID => 547,
	:name => "Octazooka",
	:function => 0x047,
	:type => :WATER,
	:category => :special,
	:basedamage => 65,
	:accuracy => 85,
	:maxpp => 10,
	:effect => 50,
	:target => :SingleNonUser,
	:desc => "The user attacks by spraying ink at the target's eyes. This may also lower the target's Accuracy."
},

:WATERPULSE => {
	:ID => 548,
	:name => "Water Pulse",
	:function => 0x013,
	:type => :WATER,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks the target with a pulsing blast of water. This may also confuse the target."
},

:WATERPLEDGE => {
	:ID => 549,
	:name => "Water Pledge",
	:function => 0x108,
	:type => :WATER,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A column of water spouts up. Its power is increased and it can create Fields with other Pledge moves."
},

:AQUAJET => {
	:ID => 550,
	:name => "Aqua Jet",
	:function => 0x000,
	:type => :WATER,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:priority => 1,
	:contact => true,
	:kingrock => true,
	:desc => "The user lunges at a speed that makes them almost invisible. This move always goes first."
},

:WATERGUN => {
	:ID => 551,
	:name => "Water Gun",
	:function => 0x000,
	:type => :WATER,
	:category => :special,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 25,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The target is blasted with a forceful shot of water."
},

:CLAMP => {
	:ID => 552,
	:name => "Clamp",
	:function => 0x0CF,
	:type => :WATER,
	:category => :physical,
	:basedamage => 35,
	:accuracy => 85,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The target is clamped and squeezed by the user's very thick and sturdy shell for four to five turns."
},

:WHIRLPOOL => {
	:ID => 553,
	:name => "Whirlpool",
	:function => 0x0D0,
	:type => :WATER,
	:category => :special,
	:basedamage => 35,
	:accuracy => 85,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user traps the target in a violent swirling whirlpool for four to five turns."
},

:BUBBLE => {
	:ID => 554,
	:name => "Bubble",
	:function => 0x044,
	:type => :WATER,
	:category => :special,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 30,
	:effect => 10,
	:target => :AllOpposing,
	:desc => "A spray of countless bubbles is jetted at the opposing Pokémon. This may also lower their Speed stat."
},

:AQUARING => {
	:ID => 555,
	:name => "Aqua Ring",
	:function => 0x0DA,
	:type => :WATER,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :User,
	:snatchable => true,
	:healingmove => true,
	:desc => "The user envelops themselves in a veil made of water. They regain some HP every turn."
},

:RAINDANCE => {
	:ID => 556,
	:name => "Rain Dance",
	:function => 0x100,
	:type => :WATER,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :UserSide,
	:nonmirror => true,
	:desc => "Summons rain for five turns, powering up Water-type moves and weakening Fire-type moves."
},

:SOAK => {
	:ID => 557,
	:name => "Soak",
	:function => 0x061,
	:type => :WATER,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user shoots a torrent of water at the target and changes the target's type to Water."
},

:WATERSPORT => {
	:ID => 558,
	:name => "Water Sport",
	:function => 0x09E,
	:type => :WATER,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :UserSide,
	:nonmirror => true,
	:desc => "The user soaks the battlefield with water. This weakens Fire-type moves for five turns."
},

:WITHDRAW => {
	:ID => 559,
	:name => "Withdraw",
	:function => 0x01D,
	:type => :WATER,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 40,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user withdraws their body into their hard shell, raising their Defense stat."
},

:AROMATICMIST => {
	:ID => 560,
	:name => "Aromatic Mist",
	:function => 0x13A,
	:type => :FAIRY,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :BothSides,
	:nonmirror => true,
	:desc => "The user raises the Sp. Def stat of an ally Pokémon by using a mysterious aroma."
},

:BABYDOLLEYES => {
	:ID => 561,
	:name => "Baby-Doll Eyes",
	:function => 0x042,
	:type => :FAIRY,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:priority => 1,
	:magiccoat => true,
	:desc => "Staring with baby-doll eyes, the user lowers the target's Attack stat. This move always goes first."
},

:BELCH => {
	:ID => 562,
	:name => "Belch",
	:function => 0x13C,
	:type => :POISON,
	:category => :special,
	:basedamage => 120,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:desc => "The user lets out a damaging belch at the target. The user must eat a held Berry to use this move."
},

:BOOMBURST => {
	:ID => 563,
	:name => "Boomburst",
	:function => 0x000,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 140,
	:accuracy => 100,
	:maxpp => 10,
	:target => :AllNonUsers,
	:soundmove => true,
	:desc => "The user attacks everything around with the destructive power of a terrible, explosive sound."
},

:CONFIDE => {
	:ID => 564,
	:name => "Confide",
	:function => 0x045,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:soundmove => true,
	:desc => "The user discloses a secret to the target, which cannot focus anymore. This lowers the target's Sp. Atk."
},

:CRAFTYSHIELD => {
	:ID => 565,
	:name => "Crafty Shield",
	:function => 0x149,
	:type => :FAIRY,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :BothSides,
	:priority => 3,
	:nonmirror => true,
	:desc => "The user protects themselves and their allies from status moves. This does not stop damaging moves."
},

:DAZZLINGGLEAM => {
	:ID => 566,
	:name => "Dazzling Gleam",
	:function => 0x000,
	:type => :FAIRY,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "The user damages opposing Pokémon by emitting a powerful flash."
},

:DISARMINGVOICE => {
	:ID => 567,
	:name => "Disarming Voice",
	:function => 0x0A5,
	:type => :FAIRY,
	:category => :special,
	:basedamage => 40,
	:accuracy => 0,
	:maxpp => 15,
	:target => :AllOpposing,
	:kingrock => true,
	:soundmove => true,
	:desc => "A charming cry does emotional damage to opposing Pokémon. This attack never misses."
},

:DRAININGKISS => {
	:ID => 568,
	:name => "Draining Kiss",
	:function => 0x139,
	:type => :FAIRY,
	:category => :special,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user steals HP with a kiss. The user's HP is restored by over half of the damage dealt."
},

:PLASMAFISTS => {
	:ID => 569,
	:name => "Plasma Fists",
	:function => 0x177,
	:type => :ELECTRIC,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:punchmove => true,
	:desc => "The user attacks with electrically charged fists. For that turn, Normal-type moves become Electric-type."
},

:EERIEIMPULSE => {
	:ID => 570,
	:name => "Eerie Impulse",
	:function => 0x13B,
	:type => :ELECTRIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user's body generates an eerie impulse. It harshly lowers the target's Sp. Atk stat."
},

:ELECTRICTERRAIN => {
	:ID => 571,
	:name => "Electric Terrain",
	:function => 0x134,
	:type => :ELECTRIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :NoTarget,
	:nonmirror => true,
	:desc => "The user electrifies the ground for five turns, turning the battlefield into Electric Terrain."
},

:ELECTRIFY => {
	:ID => 572,
	:name => "Electrify",
	:function => 0x153,
	:type => :ELECTRIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:desc => "If the target is hit before using its own move, the target's move becomes Electric-type."
},

:FAIRYLOCK => {
	:ID => 573,
	:name => "Fairy Lock",
	:function => 0x145,
	:type => :FAIRY,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :UserSide,
	:desc => "By locking down the battlefield, the user keeps all Pokémon from fleeing during the next turn."
},

:FAIRYWIND => {
	:ID => 574,
	:name => "Fairy Wind",
	:function => 0x000,
	:type => :FAIRY,
	:category => :special,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user stirs up a fairy wind and strikes the target with it."
},

:FELLSTINGER => {
	:ID => 575,
	:name => "Fell Stinger",
	:function => 0x147,
	:type => :BUG,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 25,
	:effect => 100,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "When the user knocks out a target with this move, the user's Attack stat rises drastically."
},

:FLOWERSHIELD => {
	:ID => 576,
	:name => "Flower Shield",
	:function => 0x150,
	:type => :FAIRY,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :UserSide,
	:nonmirror => true,
	:desc => "The user raises the Defense stat of all Grass-type Pokémon in battle with a mysterious power."
},

:FLYINGPRESS => {
	:ID => 577,
	:name => "Flying Press",
	:function => 0x137,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 95,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:nonmirror => true,
	:kingrock => true,
	:desc => "The user dives down onto the target from the sky. This move is Fighting- and Flying-type simultaneously."
},

:FORESTSCURSE => {
	:ID => 578,
	:name => "Forest's Curse",
	:function => 0x143,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user puts a forest curse on the target. This changes the target to Grass-type."
},

:FREEZEDRY => {
	:ID => 579,
	:name => "Freeze-Dry",
	:function => 0x00C,
	:type => :ICE,
	:category => :special,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 10,
	:target => :SingleNonUser,
	:nonmirror => true,
	:kingrock => true,
	:desc => "The user rapidly cools the target. It may freeze the target and is supereffective on Water-types."
},

:GEOMANCY => {
	:ID => 580,
	:name => "Geomancy",
	:function => 0x13E,
	:type => :FAIRY,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:nonmirror => true,
	:desc => "Absorbing energy, the user sharply raises their Sp. Atk, Sp. Def and Speed stats on the next turn."
},

:GRASSYTERRAIN => {
	:ID => 581,
	:name => "Grassy Terrain",
	:function => 0x135,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :NoTarget,
	:nonmirror => true,
	:desc => "Letting grass sprout from the ground, the user turns the field into Grassy Terrain for five turns."
},

:INFESTATION => {
	:ID => 582,
	:name => "Infestation",
	:function => 0x0CF,
	:type => :BUG,
	:category => :special,
	:basedamage => 20,
	:accuracy => 100,
	:maxpp => 35,
	:effect => 100,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks and infests the target for four to five turns, preventing the target from escaping."
},

:IONDELUGE => {
	:ID => 583,
	:name => "Ion Deluge",
	:function => 0x148,
	:type => :ELECTRIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 25,
	:target => :NoTarget,
	:priority => 1,
	:nonmirror => true,
	:desc => "The user disperses charged particles, which change Normal-type moves to Electric-type moves."
},

:KINGSSHIELD => {
	:ID => 584,
	:name => "King's Shield",
	:function => 0x133,
	:type => :STEEL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:priority => 4,
	:nonmirror => true,
	:desc => "The user is protected from damage. Direct contact harshly lowers any attacker's Attack stat."
},

:LANDSWRATH => {
	:ID => 585,
	:name => "Land's Wrath",
	:function => 0x000,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "The user gathers the energy of the land and focuses that power on the targets to damage them."
},

:MAGNETICFLUX => {
	:ID => 586,
	:name => "Magnetic Flux",
	:function => 0x146,
	:type => :ELECTRIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :BothSides,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user manipulates magnetic fields to raise Defense and Sp. Def of allies with Plus or Minus Ability."
},

:MATBLOCK => {
	:ID => 587,
	:name => "Mat Block",
	:function => 0x154,
	:type => :FIGHTING,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :BothSides,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user shields themselves and allies from damaging moves with a mat. Does not stop status moves."
},

:MISTYTERRAIN => {
	:ID => 588,
	:name => "Misty Terrain",
	:function => 0x136,
	:type => :FAIRY,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :UserSide,
	:nonmirror => true,
	:desc => "The user summons mist for five turns, turning the battlefield into Misty Terrain."
},

:MOONBLAST => {
	:ID => 589,
	:name => "Moonblast",
	:function => 0x045,
	:type => :FAIRY,
	:category => :special,
	:basedamage => 95,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks borrowing the power of the moon. This may also lower the target's Sp. Atk stat."
},

:MYSTICALFIRE => {
	:ID => 590,
	:name => "Mystical Fire",
	:function => 0x045,
	:type => :FIRE,
	:category => :special,
	:basedamage => 75,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks by breathing a special, hot fire. This also lowers the target's Sp. Atk stat."
},

:NOBLEROAR => {
	:ID => 591,
	:name => "Noble Roar",
	:function => 0x138,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 30,
	:target => :SingleNonUser,
	:magiccoat => true,
	:soundmove => true,
	:desc => "The user roars nobly, intimidating the target. This lowers the target's Attack and Sp. Atk stats."
},

:NUZZLE => {
	:ID => 592,
	:name => "Nuzzle",
	:function => 0x007,
	:type => :ELECTRIC,
	:category => :physical,
	:basedamage => 20,
	:accuracy => 100,
	:maxpp => 20,
	:effect => 100,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks by nuzzling electrified cheeks against the target. This also paralyzes the target."
},

:OBLIVIONWING => {
	:ID => 593,
	:name => "Oblivion Wing",
	:function => 0x139,
	:type => :FLYING,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user absorbs the target's HP. The user's HP is restored by over half of the damage inflicted."
},

:PARABOLICCHARGE => {
	:ID => 594,
	:name => "Parabolic Charge",
	:function => 0x0DD,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 65,
	:accuracy => 100,
	:maxpp => 20,
	:target => :AllNonUsers,
	:kingrock => true,
	:desc => "The user attacks everything around. The user's HP is restored by half the damage dealt."
},

:PARTINGSHOT => {
	:ID => 595,
	:name => "Parting Shot",
	:function => 0x13D,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:soundmove => true,
	:desc => "The user lowers the target's Attack and Sp. Atk stats and switches with a party Pokémon."
},

:PETALBLIZZARD => {
	:ID => 596,
	:name => "Petal Blizzard",
	:function => 0x000,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 15,
	:target => :AllNonUsers,
	:kingrock => true,
	:desc => "The user stirs up a violent petal blizzard and attacks everything around themselves."
},

:PHANTOMFORCE => {
	:ID => 597,
	:name => "Phantom Force",
	:function => 0x0CD,
	:type => :GHOST,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:bypassprotect => true,
	:kingrock => true,
	:desc => "The user vanishes, then strikes on the next turn. It strikes even if the target protects itself."
},

:PLAYNICE => {
	:ID => 598,
	:name => "Play Nice",
	:function => 0x042,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user befriends the target, making it lose the will to fight. It lowers the target's Attack stat."
},

:PLAYROUGH => {
	:ID => 599,
	:name => "Play Rough",
	:function => 0x042,
	:type => :FAIRY,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 90,
	:maxpp => 10,
	:effect => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user plays rough with the target and attacks it. This may also lower the target's Attack stat."
},

:POWDER => {
	:ID => 600,
	:name => "Powder",
	:function => 0x152,
	:type => :BUG,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:priority => 1,
	:magiccoat => true,
	:desc => "The user covers the target in combustible powder. It explodes if the target uses a Fire-type move."
},

:POWERUPPUNCH => {
	:ID => 601,
	:name => "Power-Up Punch",
	:function => 0x01C,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 30,
	:effect => 100,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:punchmove => true,
	:desc => "Striking opponents over and over hardens the user's fists. This raises the user's Attack stat."
},

:ROTOTILLER => {
	:ID => 602,
	:name => "Rototiller",
	:function => 0x151,
	:type => :GROUND,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :UserSide,
	:nonmirror => true,
	:desc => "Tilling the soil, the user raises the Attack and Sp. Atk stats of grounded Grass-type Pokémon."
},

:SPIKYSHIELD => {
	:ID => 603,
	:name => "Spiky Shield",
	:function => 0x140,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:priority => 4,
	:nonmirror => true,
	:desc => "Protecting the user from attacks, this move also damages any attacker who makes direct contact."
},

:STICKYWEB => {
	:ID => 604,
	:name => "Sticky Web",
	:function => 0x141,
	:type => :BUG,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :OpposingSide,
	:magiccoat => true,
	:nonmirror => true,
	:desc => "The user weaves a sticky net, lowering the Speed stat of opposing Pokémon switching into battle."
},

:TOPSYTURVY => {
	:ID => 605,
	:name => "Topsy-Turvy",
	:function => 0x142,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "All stat changes affecting the target turn topsy-turvy and become the opposite of what they were."
},

:TRICKORTREAT => {
	:ID => 606,
	:name => "Trick-or-Treat",
	:function => 0x144,
	:type => :GHOST,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user takes the target trick-or-treating. This changes the target's type to Ghost."
},

:VENOMDRENCH => {
	:ID => 607,
	:name => "Venom Drench",
	:function => 0x13F,
	:type => :POISON,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :AllOpposing,
	:magiccoat => true,
	:desc => "With an odd poisonous liquid, the user lowers the Attack, Sp. Atk, and Speed stats of poisoned opponents."
},

:WATERSHURIKEN => {
	:ID => 608,
	:name => "Water Shuriken",
	:function => 0x0C0,
	:type => :WATER,
	:category => :special,
	:basedamage => 15,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:priority => 1,
	:kingrock => true,
	:desc => "The user attacks with throwing stars two to five times in a row. This move always goes first."
},

:HIDDENPOWERNOR => {
	:ID => 609,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERFIR => {
	:ID => 610,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :FIRE,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERFIG => {
	:ID => 611,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :FIGHTING,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERWAT => {
	:ID => 612,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :WATER,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERFLY => {
	:ID => 613,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :FLYING,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERGRA => {
	:ID => 614,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :GRASS,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERPOI => {
	:ID => 615,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :POISON,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERELE => {
	:ID => 616,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERGRO => {
	:ID => 617,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :GROUND,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERPSY => {
	:ID => 618,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERROC => {
	:ID => 619,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :ROCK,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERICE => {
	:ID => 620,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :ICE,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERBUG => {
	:ID => 621,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :BUG,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERDRA => {
	:ID => 622,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :DRAGON,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERGHO => {
	:ID => 623,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :GHOST,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERDAR => {
	:ID => 624,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :DARK,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERSTE => {
	:ID => 625,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :STEEL,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:HIDDENPOWERFAI => {
	:ID => 626,
	:name => "Hidden Power",
	:function => 0x000,
	:type => :FAIRY,
	:category => :special,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A unique attack that varies in type depending on the Pokémon using it."
},

:ORIGINPULSE => {
	:ID => 627,
	:name => "Origin Pulse",
	:function => 0x000,
	:type => :WATER,
	:category => :special,
	:basedamage => 110,
	:accuracy => 85,
	:maxpp => 10,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "The user attacks opposing Pokémon with countless beams of light that glow a deep and brilliant blue."
},

:PRECIPICEBLADES => {
	:ID => 628,
	:name => "Precipice Blades",
	:function => 0x000,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 85,
	:maxpp => 10,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "The user attacks by manifesting the power of the land in fearsome blades of stone."
},

:DRAGONASCENT => {
	:ID => 629,
	:name => "Dragon Ascent",
	:function => 0x03C,
	:type => :FLYING,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user soars, then drops from the sky at high speed. It lowers the user's Defense and Sp. Def stats."
},

:THOUSANDARROWS => {
	:ID => 630,
	:name => "ThousandArrows",
	:function => 0x11C,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "This move also hits opposing Pokémon in the air. Those Pokémon are knocked down to the ground."
},

:THOUSANDWAVES => {
	:ID => 631,
	:name => "Thousand Waves",
	:function => 0x155,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "The user attacks with a wave that crawls along the ground. Those hit can't flee from battle."
},

:DIAMONDSTORM => {
	:ID => 632,
	:name => "Diamond Storm",
	:function => 0x02F,
	:type => :ROCK,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 95,
	:maxpp => 5,
	:effect => 50,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "The user whips up a storm of diamonds to attack. It may sharply raise the user's Defense stat."
},

:HYPERSPACEHOLE => {
	:ID => 633,
	:name => "Hyperspace Hole",
	:function => 0x157,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 80,
	:accuracy => 0,
	:maxpp => 5,
	:target => :SingleNonUser,
	:bypassprotect => true,
	:kingrock => true,
	:desc => "The user appears right next to the target and strikes. Ignores moves like Protect or Detect."
},

:STEAMERUPTION => {
	:ID => 634,
	:name => "Steam Eruption",
	:function => 0x00A,
	:type => :WATER,
	:category => :special,
	:basedamage => 110,
	:accuracy => 95,
	:maxpp => 5,
	:effect => 30,
	:target => :SingleNonUser,
	:kingrock => true,
	:defrost => true,
	:desc => "Immerses the target in superheated steam. This may also leave the target with a burn."
},

:HYPERSPACEFURY => {
	:ID => 635,
	:name => "HyperspaceFury",
	:function => 0x159,
	:type => :DARK,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:bypassprotect => true,
	:kingrock => true,
	:desc => "The user unleashes a barrage, ignoring moves like Protect and Detect. It lowers the user's Defense."
},

:FUTUREDUMMY => {
	:ID => 636,
	:name => "Future Sight",
	:function => 0x15A,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:bypassprotect => true,
	:nonmirror => true,
	:desc => "Two turns after this move is used, a hunk of psychic energy attacks the target."
},

:DOOMDUMMY => {
	:ID => 637,
	:name => "Doom Desire",
	:function => 0x15A,
	:type => :STEEL,
	:category => :special,
	:basedamage => 140,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:bypassprotect => true,
	:nonmirror => true,
	:desc => "Two turns after this move is used, the user blasts the target with a concentrated bundle of light."
},

:ACCELEROCK => {
	:ID => 638,
	:name => "Accelerock",
	:function => 0x000,
	:type => :ROCK,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:priority => 1,
	:contact => true,
	:kingrock => true,
	:desc => "The user smashes into the target at high speed. This move always goes first."
},

:ANCHORSHOT => {
	:ID => 639,
	:name => "Anchor Shot",
	:function => 0x155,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user entangles the target with their anchor chain. The target becomes unable to flee."
},

:AURORAVEIL => {
	:ID => 640,
	:name => "Aurora Veil",
	:function => 0x15B,
	:type => :ICE,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :BothSides,
	:snatchable => true,
	:desc => "This move reduces damage from physical and special moves for five turns. Can only be used during hail."
},

:BANEFULBUNKER => {
	:ID => 641,
	:name => "Baneful Bunker",
	:function => 0x15C,
	:type => :POISON,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:priority => 4,
	:nonmirror => true,
	:desc => "Protecting the user from attacks, this move also poisons any attacker that makes direct contact."
},

:BEAKBLAST => {
	:ID => 642,
	:name => "Beak Blast",
	:function => 0x15D,
	:type => :FLYING,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:priority => -3,
	:nonmirror => true,
	:desc => "The user first heats up their beak, then attacks. Direct contact while heating up results in a burn."
},

:BRUTALSWING => {
	:ID => 643,
	:name => "Brutal Swing",
	:function => 0x000,
	:type => :DARK,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 20,
	:target => :AllNonUsers,
	:contact => true,
	:kingrock => true,
	:desc => "The user swings their body around violently to inflict damage on everything in their vicinity."
},

:BURNUP => {
	:ID => 644,
	:name => "Burn Up",
	:function => 0x15E,
	:type => :FIRE,
	:category => :special,
	:basedamage => 130,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:defrost => true,
	:desc => "The user burns themselves out for massive damage. The user then will no longer be Fire-type."
},

:CLANGINGSCALES => {
	:ID => 645,
	:name => "Clanging Scales",
	:function => 0x15F,
	:type => :DRAGON,
	:category => :special,
	:basedamage => 110,
	:accuracy => 100,
	:maxpp => 5,
	:target => :AllOpposing,
	:kingrock => true,
	:soundmove => true,
	:desc => "The user rubs the scales on their body, making a huge noise. It then lowers the user's Defense stat."
},

:COREENFORCER => {
	:ID => 646,
	:name => "Core Enforcer",
	:function => 0x160,
	:type => :DRAGON,
	:category => :special,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 10,
	:target => :AllOpposing,
	:kingrock => true,
	:desc => "A damaging move that also eliminates the targets' Abilities if they have already used their moves."
},

:DARKESTLARIAT => {
	:ID => 647,
	:name => "Darkest Lariat",
	:function => 0x0A9,
	:type => :DARK,
	:category => :physical,
	:basedamage => 85,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user swings both arms and strikes. The target's stat changes don't affect this attack's damage."
},

:DRAGONHAMMER => {
	:ID => 648,
	:name => "Dragon Hammer",
	:function => 0x000,
	:type => :DRAGON,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user uses their body like a hammer to attack the target and inflict damage."
},

:FIRELASH => {
	:ID => 649,
	:name => "Fire Lash",
	:function => 0x043,
	:type => :FIRE,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 100,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user strikes the target with a burning lash. This also lowers the target's Defense stat."
},

:FIRSTIMPRESSION => {
	:ID => 650,
	:name => "First Impression",
	:function => 0x161,
	:type => :BUG,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 100,
	:target => :SingleNonUser,
	:priority => 2,
	:contact => true,
	:kingrock => true,
	:desc => "Although this move has great power, it only works the first turn the user is in battle."
},

:FLEURCANNON => {
	:ID => 651,
	:name => "Fleur Cannon",
	:function => 0x03F,
	:type => :FAIRY,
	:category => :special,
	:basedamage => 130,
	:accuracy => 90,
	:maxpp => 5,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user unleashes a strong beam. The attack's recoil harshly lowers the user's Sp. Atk stat."
},

:FLORALHEALING => {
	:ID => 652,
	:name => "Floral Healing",
	:function => 0x162,
	:type => :FAIRY,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user restores the target's HP by up to half of its max HP. Restores more HP on Grassy Terrain."
},

:GEARUP => {
	:ID => 653,
	:name => "Gear Up",
	:function => 0x163,
	:type => :STEEL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :BothSides,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user engages their gears to raise Attack and Sp. Atk stats of allies with Plus or Minus Ability."
},

:HIGHHORSEPOWER => {
	:ID => 654,
	:name => "High Horsepower",
	:function => 0x000,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 95,
	:accuracy => 95,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user fiercely attacks the target using their entire body."
},

:ICEHAMMER => {
	:ID => 655,
	:name => "Ice Hammer",
	:function => 0x03E,
	:type => :ICE,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:punchmove => true,
	:desc => "The user swings and hits with their strong, heavy fist. It lowers the user's Speed, however."
},

:INSTRUCT => {
	:ID => 656,
	:name => "Instruct",
	:function => 0x164,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user instructs the target to use the target's last move again."
},

:LASERFOCUS => {
	:ID => 657,
	:name => "Laser Focus",
	:function => 0x165,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 30,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:desc => "By concentrating intensely, the user's attack on the next turn always results in a critical hit."
},

:LEAFAGE => {
	:ID => 658,
	:name => "Leafage",
	:function => 0x000,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 40,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks by pelting the target with leaves."
},

:LIQUIDATION => {
	:ID => 659,
	:name => "Liquidation",
	:function => 0x043,
	:type => :WATER,
	:category => :physical,
	:basedamage => 85,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 20,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user slams the target with a full-force water blast. It may lower the Defense stat of the target."
},

:LUNGE => {
	:ID => 660,
	:name => "Lunge",
	:function => 0x042,
	:type => :BUG,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 100,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user lunges at the target with full force. This also lowers the target's Attack stat."
},

:MOONGEISTBEAM => {
	:ID => 661,
	:name => "Moongeist Beam",
	:function => 0x166,
	:type => :GHOST,
	:category => :special,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user emits a sinister ray to attack. This move will ignore the target's Ability."
},

:NATURESMADNESS => {
	:ID => 662,
	:name => "Nature Madness",
	:function => 0x06C,
	:type => :FAIRY,
	:category => :special,
	:basedamage => 1,
	:accuracy => 90,
	:maxpp => 10,
	:target => :SingleNonUser,
	:desc => "The user hits the target with the force of nature. It halves the target's HP."
},

:POLLENPUFF => {
	:ID => 663,
	:name => "Pollen Puff",
	:function => 0x167,
	:type => :BUG,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:desc => "The user attacks with a pollen puff that explodes. If the target is an ally, it restores HP instead."
},

:POWERTRIP => {
	:ID => 664,
	:name => "Power Trip",
	:function => 0x08E,
	:type => :DARK,
	:category => :physical,
	:basedamage => 20,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user boasts their strength and strikes. The more the user's stats are raised, the greater the power."
},

:PRISMATICLASER => {
	:ID => 665,
	:name => "Prismatic Laser",
	:function => 0x0C2,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 160,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user shoots powerful lasers using the power of a prism. The user can't move on the next turn."
},

:PSYCHICFANGS => {
	:ID => 666,
	:name => "Psychic Fangs",
	:function => 0x10A,
	:type => :PSYCHIC,
	:category => :physical,
	:basedamage => 85,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user bites the target with psychic capabilities. This can also destroy Light Screen and Reflect."
},

:PSYCHICTERRAIN => {
	:ID => 667,
	:name => "Psychic Terrain",
	:function => 0x168,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :UserSide,
	:nonmirror => true,
	:desc => "Summoning psychic energies, the user turns the battlefield into Psychic Terrain for five turns."
},

:PURIFY => {
	:ID => 668,
	:name => "Purify",
	:function => 0x169,
	:type => :POISON,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user heals the target's status condition. It also restores the user's own HP."
},

:REVELATIONDANCE => {
	:ID => 669,
	:name => "RevelationDance",
	:function => 0x16A,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks the target by dancing very hard. The user's type determines the type of this move."
},

:SHADOWBONE => {
	:ID => 670,
	:name => "Shadow Bone",
	:function => 0x043,
	:type => :GHOST,
	:category => :physical,
	:basedamage => 85,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user beats the target with a bone containing a spirit. This may lower the target's Defense."
},

:SHELLTRAP => {
	:ID => 671,
	:name => "Shell Trap",
	:function => 0x16B,
	:type => :FIRE,
	:category => :special,
	:basedamage => 150,
	:accuracy => 100,
	:maxpp => 5,
	:target => :AllOpposing,
	:priority => -3,
	:nonmirror => true,
	:desc => "The user sets a shell trap. If the user is hit by a physical move, the trap will explode and inflict damage."
},

:SHOREUP => {
	:ID => 672,
	:name => "Shore Up",
	:function => 0x16C,
	:type => :GROUND,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user regains up to half of their max HP. It restores more HP in a sandstorm."
},

:SMARTSTRIKE => {
	:ID => 673,
	:name => "Smart Strike",
	:function => 0x0A5,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user stabs the target with a sharp horn. This attack never misses."
},

:SOLARBLADE => {
	:ID => 674,
	:name => "Solar Blade",
	:function => 0x0C4,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 125,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user fills a blade with light energy on the first turn, then attacks on the next turn."
},

:SPARKLINGARIA => {
	:ID => 675,
	:name => "Sparkling Aria",
	:function => 0x16D,
	:type => :WATER,
	:category => :special,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:target => :AllNonUsers,
	:kingrock => true,
	:soundmove => true,
	:desc => "The user bursts into song, emitting many bubbles. If any target had a burn, the burn will be lifted."
},

:SPECTRALTHIEF => {
	:ID => 676,
	:name => "Spectral Thief",
	:function => 0x16E,
	:type => :GHOST,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user hides in the target's shadow, steals the target's stat boosts, and then attacks."
},

:SPEEDSWAP => {
	:ID => 677,
	:name => "Speed Swap",
	:function => 0x16F,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:desc => "The user exchanges Speed stats with the target."
},

:SPIRITSHACKLE => {
	:ID => 678,
	:name => "Spirit Shackle",
	:function => 0x155,
	:type => :GHOST,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks while stitching the target's shadow to the ground, preventing it from escaping."
},

:SPOTLIGHT => {
	:ID => 679,
	:name => "Spotlight",
	:function => 0x170,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :SingleNonUser,
	:priority => 3,
	:magiccoat => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user shines a spotlight on the target so that only it will be attacked during the turn."
},

:STOMPINGTANTRUM => {
	:ID => 680,
	:name => "Stomp Tantrum",
	:function => 0x171,
	:type => :GROUND,
	:category => :physical,
	:basedamage => 75,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "Driven by frustration, the user attacks. If the user's previous move failed, the power of this move doubles."
},

:STRENGTHSAP => {
	:ID => 681,
	:name => "Strength Sap",
	:function => 0x172,
	:type => :GRASS,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:magiccoat => true,
	:nonmirror => true,
	:healingmove => true,
	:desc => "The user restores HP equal to the target's Attack stat. It also lowers the target's Attack stat."
},

:SUNSTEELSTRIKE => {
	:ID => 682,
	:name => "Sunsteel Strike",
	:function => 0x166,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user slams into the target with the force of a meteor. This move will ignore the target's Ability."
},

:TEARFULLOOK => {
	:ID => 683,
	:name => "Tearful Look",
	:function => 0x138,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "Teary eyes make the target lose the desire to fight. It lowers the target's Attack and Sp. Atk."
},

:THROATCHOP => {
	:ID => 684,
	:name => "Throat Chop",
	:function => 0x173,
	:type => :DARK,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks the target's throat. The target cannot use sound-based moves for two turns."
},

:TOXICTHREAD => {
	:ID => 685,
	:name => "Toxic Thread",
	:function => 0x174,
	:type => :POISON,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user shoots poisonous threads to poison the target and lower the target's Speed stat."
},

:TROPKICK => {
	:ID => 686,
	:name => "Trop Kick",
	:function => 0x042,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 70,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 100,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user lands an intense kick of tropical origins. This also lowers the target's Attack stat."
},

:ZINGZAP => {
	:ID => 687,
	:name => "Zing Zap",
	:function => 0x00F,
	:type => :ELECTRIC,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 30,
	:target => :SingleNonUser,
	:contact => true,
	:desc => "A strong electric blast crashes down, shocking the target. This may also make the target flinch."
},

:MULTIATTACK => {
	:ID => 688,
	:name => "Multi-Attack",
	:function => 0x09F,
	:type => :NORMAL,
	:category => :physical,
	:basedamage => 90,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "Cloaked in high energy, the user slams the target. The held Memory defines the move's type."
},

:MINDBLOWN => {
	:ID => 689,
	:name => "Mind Blown",
	:function => 0x175,
	:type => :FIRE,
	:category => :special,
	:basedamage => 150,
	:accuracy => 100,
	:maxpp => 5,
	:target => :AllNonUsers,
	:kingrock => true,
	:desc => "The user attacks everything around by causing their own head to explode. This also damages the user."
},

:PHOTONGEYSER => {
	:ID => 690,
	:name => "Photon Geyser",
	:function => 0x176,
	:type => :PSYCHIC,
	:category => :special,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "A pillar of light that inflicts damage using the higher one of the user's Attack or Sp. Atk."
},

:WEATHERBALLSUN => {
	:ID => 691,
	:name => "Weather Ball",
	:function => 0x087,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "An attack move that varies in power and type depending on the weather."
},

:WEATHERBALLRAIN => {
	:ID => 692,
	:name => "Weather Ball",
	:function => 0x087,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "An attack move that varies in power and type depending on the weather."
},

:WEATHERBALLHAIL => {
	:ID => 693,
	:name => "Weather Ball",
	:function => 0x087,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "An attack move that varies in power and type depending on the weather."
},

:WEATHERBALLSAND => {
	:ID => 694,
	:name => "Weather Ball",
	:function => 0x087,
	:type => :NORMAL,
	:category => :special,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "An attack move that varies in power and type depending on the weather."
},

:DYNAMAXCANNON => {
	:ID => 695,
	:name => "Dynamax Cannon",
	:function => 0x178,
	:type => :DRAGON,
	:category => :special,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user unleashes a strong beam from its core. This move deals twice the damage if the target is Dynamaxed."
},

:SNIPESHOT => {
	:ID => 696,
	:name => "Snipe Shot",
	:function => 0x179,
	:type => :WATER,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user ignores the effects of opposing Pokémon's moves and Abilities that draw in moves, allowing this move to hit the chosen target."
},

:JAWLOCK => {
	:ID => 697,
	:name => "Jaw Lock",
	:function => 0x000,
	:type => :DARK,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "This move prevents the user and the target from switching out until either of them faints. The effect goes away if either of the Pokémon leaves the field."
},

:STUFFCHEEKS => {
	:ID => 698,
	:name => "Stuff Cheeks",
	:function => 0x17A,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user eats its held Berry, then sharply raises its Defense stat."
},

:NORETREAT => {
	:ID => 699,
	:name => "No Retreat",
	:function => 0x17B,
	:type => :FIGHTING,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :SingleNonUser,
	:snatchable => true,
	:nonmirror => true,
	:desc => "This move raises all the user's stats but prevents the user from switching out or fleeing."
},

:TARSHOT => {
	:ID => 700,
	:name => "Tar Shot",
	:function => 0x17C,
	:type => :ROCK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:magiccoat => true,
	:desc => "The user pours sticky tar over the target, lowering the target's Speed stat. The target becomes weaker to Fire-type moves."
},

:MAGICPOWDER => {
	:ID => 701,
	:name => "Magic Powder",
	:function => 0x17D,
	:type => :PSYCHIC,
	:category => :status,
	:basedamage => 0,
	:accuracy => 100,
	:maxpp => 20,
	:target => :SingleNonUser,
	:magiccoat => true,
	:kingrock => true,
	:desc => "The user scatters a cloud of magic powder that changes the target to Psychic type."
},

:DRAGONDARTS => {
	:ID => 702,
	:name => "Dragon Darts",
	:function => 0x17E,
	:type => :DRAGON,
	:category => :physical,
	:basedamage => 50,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks twice using Dreepy. If there are two targets, this move hits each target once."
},

:TEATIME => {
	:ID => 703,
	:name => "Teatime",
	:function => 0x17F,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :UserSide,
	:nonmirror => true,
	:desc => "The user has teatime with all the Pokémon in the battle. Each Pokémon eats its held Berry."
},

:OCTOLOCK => {
	:ID => 704,
	:name => "Octolock",
	:function => 0x180,
	:type => :FIGHTING,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :SingleNonUser,
	:nonmirror => true,
	:kingrock => true,
	:desc => "The user locks the target in and prevents it from fleeing. This move also lowers the target's Defense and Sp. Def every turn."
},

:BOLTBEAK => {
	:ID => 705,
	:name => "Bolt Beak",
	:function => 0x181,
	:type => :ELECTRIC,
	:category => :physical,
	:basedamage => 85,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user stabs the target with its electrified beak. If the user attacks before the target, the power of this move is doubled."
},

:FISHIOUSREND => {
	:ID => 706,
	:name => "Fishious Rend",
	:function => 0x181,
	:type => :WATER,
	:category => :physical,
	:basedamage => 85,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "   The user rends the target with its hard gills. If the user attacks before the target, the power of this move is doubled."
},

:COURTCHANGE => {
	:ID => 707,
	:name => "Court Change",
	:function => 0x182,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :UserSide,
	:desc => "With its mysterious power, the user swaps the effects on either side of the field."
},

:CLANGOROUSSOUL => {
	:ID => 708,
	:name => "Clangorous Soul",
	:function => 0x183,
	:type => :DRAGON,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 5,
	:target => :User,
	:snatchable => true,
	:nonmirror => true,
	:soundmove => true,
	:desc => "The user raises all its stats by using some of its HP."
},

:BODYPRESS => {
	:ID => 709,
	:name => "Body Press",
	:function => 0x184,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks by slamming its body into the target. The higher the user's Defense, the more damage it can inflict on the target."
},

:DECORATE => {
	:ID => 710,
	:name => "Decorate",
	:function => 0x185,
	:type => :FAIRY,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 15,
	:target => :SingleNonUser,
	:nonmirror => true,
	:desc => "The user sharply raises the target's Attack and Sp. Atk stats by decorating the target."
},

:DRUMBEATING => {
	:ID => 711,
	:name => "Drum Beating",
	:function => 0x044,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user plays its drum, controlling the drum's roots to attack the target. This also lowers the target's Speed stat."
},

:SNAPTRAP => {
	:ID => 712,
	:name => "Snap Trap",
	:function => 0x0CF,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 35,
	:accuracy => 100,
	:maxpp => 15,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user snares the target in a snap trap for four to five turns."
},

:PYROBALL => {
	:ID => 713,
	:name => "Pyro Ball",
	:function => 0x00A,
	:type => :FIRE,
	:category => :physical,
	:basedamage => 120,
	:accuracy => 90,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks by igniting a small stone and launching it as a fiery ball at the target. This may also leave the target with a burn."
},

:BEHEMOTHBLADE => {
	:ID => 714,
	:name => "Behemoth Blade",
	:function => 0x178,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user becomes a gigantic sword and cuts the target. This move deals twice the damage if the target is Dynamaxed."
},

:BEHEMOTHBASH => {
	:ID => 715,
	:name => "Behemoth Bash",
	:function => 0x178,
	:type => :STEEL,
	:category => :physical,
	:basedamage => 100,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user becomes a gigantic shield and cuts the target. This move deals twice the damage if the target is Dynamaxed."
},

:AURAWHEELPLUS => {
	:ID => 716,
	:name => "Aura Wheel",
	:function => 0x186,
	:type => :ELECTRIC,
	:category => :physical,
	:basedamage => 110,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "Morpeko attacks and raises its Speed with the energy stored in its cheeks. This move's type changes depending on the user's form."
},

:BREAKINGSWIPE => {
	:ID => 717,
	:name => "Breaking Swipe",
	:function => 0x042,
	:type => :DRAGON,
	:category => :physical,
	:basedamage => 60,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 100,
	:target => :AllOpposing,
	:contact => true,
	:kingrock => true,
	:desc => "The user swings its tough tail wildly and attacks opposing Pokémon. This also lowers their Attack stats."
},

:BRANCHPOKE => {
	:ID => 718,
	:name => "Branch Poke",
	:function => 0x000,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 40,
	:accuracy => 100,
	:maxpp => 40,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks the target by poking it with a sharply pointed branch."
},

:OVERDRIVE => {
	:ID => 719,
	:name => "Overdrive",
	:function => 0x000,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:target => :AllOpposing,
	:kingrock => true,
	:soundmove => true,
	:desc => "The user attacks opposing Pokémon by twanging a guitar or bass guitar, causing a huge echo and strong vibration."
},

:APPLEACID => {
	:ID => 720,
	:name => "Apple Acid",
	:function => 0x046,
	:type => :GRASS,
	:category => :special,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks the target with an acidic liquid created from tart apples. This also lowers the target's Sp. Def stat."
},

:GRAVAPPLE => {
	:ID => 721,
	:name => "Grav Apple",
	:function => 0x043,
	:type => :GRASS,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 100,
	:maxpp => 10,
	:effect => 100,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks the target with an acidic liquid created from tart apples. This also lowers the target's Defense stat."
},

:SPIRITBREAK => {
	:ID => 722,
	:name => "Spirit Break",
	:function => 0x020,
	:type => :FAIRY,
	:category => :physical,
	:basedamage => 75,
	:accuracy => 100,
	:maxpp => 15,
	:effect => 100,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user attacks the target with so much force that it could break the target's spirit. This also lowers the target's Sp. Atk stat."
},

:STRANGESTEAM => {
	:ID => 723,
	:name => "Strange Steam",
	:function => 0x013,
	:type => :FAIRY,
	:category => :special,
	:basedamage => 90,
	:accuracy => 95,
	:maxpp => 10,
	:effect => 20,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks the target by emitting steam. This may also confuse the target."
},

:LIFEDEW => {
	:ID => 724,
	:name => "Life Dew",
	:function => 0x187,
	:type => :WATER,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :BothSides,
	:snatchable => true,
	:nonmirror => true,
	:desc => "The user scatters mysterious water around and restores the HP of itself and its ally Pokémon in the battle."
},

:OBSTRUCT => {
	:ID => 725,
	:name => "Obstruct",
	:function => 0x188,
	:type => :DARK,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 10,
	:target => :UserSide,
	:priority => 1,
	:nonmirror => true,
	:desc => "This move enables the user to protect itself from all attacks. Its chance of failing rises if it is used in succession. Direct contact harshly lowers the attacker's Defense stat."
},

:FALSESURRENDER => {
	:ID => 726,
	:name => "False Surrender",
	:function => 0x0A6,
	:type => :DARK,
	:category => :physical,
	:basedamage => 80,
	:accuracy => 0,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "The user pretends to bow its head, but then it stabs the target with its disheveled hair. This attack never misses."
},

:METEORASSAULT => {
	:ID => 727,
	:name => "Meteor Assault",
	:function => 0x0C2,
	:type => :FIGHTING,
	:category => :physical,
	:basedamage => 150,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user attacks wildly with its thick leek. The user can't move on the next turn, because the force of this move makes it stagger."
},

:ETERNABEAM => {
	:ID => 728,
	:name => "Eternabeam",
	:function => 0x0C2,
	:type => :DRAGON,
	:category => :special,
	:basedamage => 160,
	:accuracy => 90,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "This is Eternatus's most powerful attack in its original form. The user can't move on the next turn."
},

:STEELBEAM => {
	:ID => 729,
	:name => "Steel Beam",
	:function => 0x000,
	:type => :STEEL,
	:category => :special,
	:basedamage => 140,
	:accuracy => 95,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user fires a beam of steel that it collected from its entire body. This also damages the user."
},

:CELEBRATE => {
	:ID => 730,
	:name => "Celebrate",
	:function => 0x001,
	:type => :NORMAL,
	:category => :status,
	:basedamage => 0,
	:accuracy => 0,
	:maxpp => 40,
	:target => :SingleNonUser,
	:nonmirror => true,
	:gravityblocked => true,
	:desc => "The Pokémon congratulates you on your special day!"
},

:AURAWHEELMINUS => {
	:ID => 731,
	:name => "Aura Wheel",
	:function => 0x186,
	:type => :DARK,
	:category => :physical,
	:basedamage => 110,
	:accuracy => 100,
	:maxpp => 10,
	:target => :SingleNonUser,
	:contact => true,
	:kingrock => true,
	:desc => "Morpeko attacks and raises its Speed with the energy stored in its cheeks. This move's type changes depending on the user's form."
},

:TECHNOBLASTELECTRIC => {
	:ID => 732,
	:name => "Techno Blast",
	:function => 0x09F,
	:type => :ELECTRIC,
	:category => :special,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user fires a beam of light. The move's type changes depending on the Drive the user holds."
},

:TECHNOBLASTFIRE => {
	:ID => 733,
	:name => "Techno Blast",
	:function => 0x09F,
	:type => :FIRE,
	:category => :special,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user fires a beam of light. The move's type changes depending on the Drive the user holds."
},

:TECHNOBLASTICE => {
	:ID => 734,
	:name => "Techno Blast",
	:function => 0x09F,
	:type => :ICE,
	:category => :special,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user fires a beam of light. The move's type changes depending on the Drive the user holds."
},

:TECHNOBLASTWATER => {
	:ID => 735,
	:name => "Techno Blast",
	:function => 0x09F,
	:type => :WATER,
	:category => :special,
	:basedamage => 120,
	:accuracy => 100,
	:maxpp => 5,
	:target => :SingleNonUser,
	:kingrock => true,
	:desc => "The user fires a beam of light. The move's type changes depending on the Drive the user holds."
},

}