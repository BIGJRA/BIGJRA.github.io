#physical/special implies adamant/modest or corresponding speed boost nature if spd is in evs
#maximum of two moves of the same type unless explicitly defined
#:support grabs a specific move from the support array
#ace set is the first element of each array
{
    PBSpecies::ABOMASNOW => {
        :physical => {
            :items => [:CHOICEBAND,:LIFEORB,:ASSAULTVEST,:FOCUSSASH],
            :move1 => [:WOODHAMMER,:SEEDBOMB],
            :move2 => [:ICEPUNCH],
            :movepool => [:EARTHQUAKE,:ICESHARD,:SWORDSDANCE,:BRICKBREAK,:OUTRAGE,:ROCKSLIDE,:IRONTAIL],
            :EV => [:HP,:ATK,:SPD],
            :ability => [1]
        },
        :special => {
            :items => [:CHOICESPECS,:LIFEORB,:ASSAULTVEST,:FOCUSSASH],
            :move1 => [:BLIZZARD,:ICEBEAM],
            :move2 => [:GIGADRAIN,:ENERGYBALL],
            :movepool => [:FOCUSBLAST,:SHADOWBALL,:FROSTBREATH,:HIDDENPOWERROC],
            :EV => [:HP,:SA,:SPD],
            :ability => [0,1]
        },
        :mixed => {
            :items => [:LIFEORB,:ASSAULTVEST,:FOCUSSASH],
            :move1 => [:BLIZZARD,:ICEBEAM,:ICEPUNCH],
            :move2 => [:GIGADRAIN,:ENERGYBALL,:WOODHAMMER,:SEEDBOMB],
            :movepool => [:FOCUSBLAST,:SHADOWBALL,:FROSTBREATH,:EARTHQUAKE,:ICESHARD,:SWORDSDANCE,:BRICKBREAK,:OUTRAGE,:ROCKSLIDE,:IRONTAIL],
            :EV => [:HP,:SA,:ATK,:SPD],
            :ability => [0,1],
            :nature => [:MILD,:LONELY]
        },
        :hail => {
            :items => [:ICYROCK],
            :move1 => [:BLIZZARD],
            :move2 => [:GIGADRAIN],
            :movepool => [:FOCUSBLAST,:SHADOWBALL,:FROSTBREATH,:HIDDENPOWERROC],
            :EV => [:HP,:SA,:SPD],
            :ability => [0]
        },
        :support => [:GRASSWHISTLE,:GROWTH,:PROTECT,:SYNTHESIS,:LEECHSEED,:SWAGGER,:TOXIC,:SUBSTITUTE]
    },
    PBSpecies::ABSOL => {
        :physical => {
            :items => [:CHOICEBAND,:LIFEORB,:ASSAULTVEST,:FOCUSSASH,:CHOICESCARF],
            :move1 => [:KNOCKOFF,:THROATCHOP],
            :move2 => [:SUCKERPUNCH,:PURSUIT]
            :movepool => [:SUPERPOWER,:PLAYROUGH,:STONEEDGE,:MEGAHORN,:SWORDSDANCE,:OUTRAGE,:ROCKSLIDE,:ZENHEADBUTT,:IRONTAIL,:HONECLAWS,:PSYCHOCUT],
            :EV => [:ATK,:SPD,:HP],
            :ability => [1,2]
        },
        :lens => {
            :items => [:WIDELENS],
            :move1 => [:KNOCKOFF,:THROATCHOP],
            :movepool => [:PLAYROUGH,:IRONTAIL,:MEGAHORN,:STONEEDGE,:ZENHEADBUTT],
            :EV => [:ATK,:SPD,:HP],
            :ability => [1,2]
        },
        :crit => {
            :items => [:SCOPELENS],
            :movepool => [:PSYCHOCUT,:STONEEDGE,:SHADOWCLAW,:NIGHTSLASH],
            :EV => [:ATK,:SPD,:HP],
            :ability => [1]
        },
        :rude => {
            :items => [:LEFTOVERS],
            :movepool => [:WILLOWISP,:SWAGGER,:PUNISHMENT,:PSYCHUP],
            :EV => [:ATK,:SPD,:HP],
            :ability => [1,2]
        },
        :dumb => {
            :items => [:FOCUSSASH],
            :movepool => [:PERISHSONG,:DETECT,:MEANLOOK,:TOXIC],
            :EV => [:HP,:DEF,:SD],
            :ability => [0,1,2]
        },
        :support => [:THUNDERWAVE,:WILLOWISP,:PROTECT,:TORMENT,:WISH,:SWAGGER,:TOXIC,:SUBSTITUTE]
    },
    PBSpecies::ACCELGOR => {
        :special => {
            :items => [:CHOICESPECS,:LIFEORB,:ASSAULTVEST,:FOCUSSASH],
            :move1 => [:BUGBUZZ],
            :movepool => [:FOCUSBLAST,:ENERGYBALL,:SLUDGEBOMB,:GIGADRAIN,:WATERSHURIKEN],
            :EV => [:SA,:SPD],
            :ability => [1,2]
        },
        :gambit => {
            :items => [:CHOICESCARF],
            :move1 => [:FINALGAMBIT],
            :move2 => [:BUGBUZZ],
            :movepool => [:FINALGAMBIT,:ENERGYBALL,:SLUDGEBOMB,:GIGADRAIN,:WATERSHURIKEN],
            :EV => [:SA,:SPD],
            :ability => [1,2]
        },
        :support => [:RECOVER,:FINALGAMBIT,:PROTECT,:SPIKES,:GUARDSPLIT,:SWAGGER,:TOXIC,:SUBSTITUTE,:MEFIRST]
    },
    PBSpecies::AEGISLASH => {
        :physical => {
            :items => [:LEFTOVERS],
            :move1 => [:KINGSSHIELD],
            :move2 => [:IRONHEAD,:SHADOWCLAW],
            :movepool => [:SHADOWSNEAK,:SACREDSWORD,:ROCKSLIDE,:HEADSMASH,:BRICKBREAK,:SWORDSDANCE],
            :nature => [:ADAMANT,:CAREFUL,:IMPISH],
            :EV => [:HP,:ATK,:DEF,:SD]
        },
        :special => {
            :items => [:LEFTOVERS],
            :move1 => [:KINGSSHIELD],
            :move2 => [:FLASHCANNON],
            :move3 => [:SHADOWBALL],
            :move4 => [:TOXIC],
            :nature => [:MODEST,:BOLD,:CALM],
            :EV => [:HP,:SA,:DEF,:SD]
        },
        :slow => {
            :items => [:IRONBALL],
            :move1 => [:KINGSSHIELD],
            :move2 => [:GYROBALL],
            :movepool => [:SHADOWSNEAK,:TOXIC,:BLOCK,:SUBSTITUTE,:SWAGGER,:SWORDSDANCE],
            :nature => [:BRAVE,:RELAXED,:SASSY],
            :EV => [:HP,:DEF,:SD]
        },
        :support => [:THUNDERWAVE,:WILLOWISP,:PROTECT,:TORMENT,:WISH,:SWAGGER,:TOXIC,:SUBSTITUTE]
    },
    PBSpecies::AERODACTYL => {
        :physical => {
            :items => [:LIFEORB,:CHOICEBAND,:ASSAULTVEST,:FOCUSSASH,:CHOICESCARF],
            :move1 => [:STONEEDGE,:ROCKSLIDE],
            :movepool => [:AERIALACE,:EARTHQUAKE,:FIREFANG,:AQUATAIL,:CRUNCH,:ICEFANG,:IRONHEAD,:STEELWING,:DRAGONCLAW,:THUNDERFANG,:HONECLAWS,:DOUBLEEDGE,:PURSUIT],
            :EV => [:ATK,:SPD],
            :ability => [1,2],
            :support => [:ROOST,:TAILWIND,:STEALTHROCK]
        },
        :herb => {
            :items => [:POWERHERB],
            :move1 => [:STONEEDGE,:ROCKSLIDE],
            :move2 => [:SKYATTACK],
            :movepool => [:EARTHQUAKE,:FIREFANG,:AQUATAIL,:CRUNCH,:ICEFANG,:IRONHEAD,:STEELWING,:DRAGONCLAW,:THUNDERFANG,:HONECLAWS,:DOUBLEEDGE,:PURSUIT],
            :EV => [:ATK,:SPD],
            :ability => [1,2],
            :support => [:ROOST,:TAILWIND,:STEALTHROCK]
        },
        :support => [:ROOST,:TAILWIND,:TAUNT,:STEALTHROCK,:PROTECT,:TORMENT],
    },
    PBSpecies::AGGRON => {
        :physical => {
            :items => [:CHOICEBAND,:LIFEORB,:ASSAULTVEST],
            :move1 => [:STONEEDGE,:HEADSMASH,:ROCKSLIDE],
            :move2 => [:IRONHEAD,:HEAVYSLAM,:SMARTSTRIKE],
            :movepool => [:SUPERPOWER,:EARTHQUAKE,:AQUATAIL,:BRICKBREAK,:DRAGONCLAW,:FIREPUNCH,:OUTRAGE,:SHADOWCLAW,:THUNDERPUNCH,:HONECLAWS],
            :EV => [:ATK,:SPE,:SD],
            :ability => [1,0],
        },
        :support => [:STEALTHROCK,:THUNDERWAVE,:SWAGGER,:TOXIC,:TAUNT,:PROTECT],
    },
    PBSpecies::ALAKAZAM => {
        :special => {
            :items => [:CHOICESPECS,:CHOICESCARF,:LIFEORB,:ASSAULTVEST,:FOCUSSASH],
            :move1 => [:PSYCHIC,:PSYSHOCK],
            :movepool => [:FOCUSBLAST,:SHADOWBALL,:CHARGEBEAM,:SIGNALBEAM,:ENERGYBALL,:DAZZLINGGLEAM,:CALMMIND],
            :EV => [:SA,:SPE]
        },
        :dumb => {  #physical
            :items => [:CHOICEBAND,:CHOICESCARF,:LIFEORB,:ASSAULTVEST,:FOCUSSASH],
            :move1 => [:ZENHEADBUTT,:PSYCHOCUT],
            :movepool => [:ICEPUNCH,:IRONTAIL,:FIREPUNCH,:THUNDERPUNCH,:DRAINPUNCH,:KNOCKOFF,:MEGAKICK,:SECRETPOWER],
            :EV => [:SA,:SPE]
        },
        :support => [:RECOVER,:REFLECT,:LIGHTSCREEN,:SWAGGER,:ENCORE,:PROTECT,:THUNDERWAVE,:TOXIC,:TAUNT,:TORMENT,]
    },
    PBSpecies::ALOMOMOLA => {
        :bulky => {
            :items => [:ROCKYHELMET,:LEFTOVERS,:REDCARD],
            :move1 => [:WISH],
            :move2 => [:PROTECT],
            :movepool => [:SCALD,:KNOCKOFF,:TOXIC,:AQUARING],
            :EV => [:HP,:DEF,:SPD],
            :ability => [2]
        }
    }
}

PBSpecies::AERODACTYL => {
    :physical => {
        :items => [],
        :move1 => [],
        :movepool => [],
        :EV => [],
        :ability => [1,2],
        :support => 1
    },
}