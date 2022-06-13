class PokemonEncounters

def setup(mapID)
    @density=nil
    @stepcount=0
    @enctypes=[]
    begin
        $cache.encounters=load_data("Data/encounters.dat") if !$cache.encounters || (defined? $encountermultiplier && $encountermultiplier==1)
        if $cache.encounters.is_a?(Hash) && $cache.encounters[mapID]
        ##YUMIL -25
        if !defined? $encountermultiplier
            $encountermultiplier=1
        end
        for i in 0..$cache.encounters[mapID][0].length-1
            $cache.encounters[mapID][0][i]=$cache.encounters[mapID][0][i]*$encountermultiplier*($game_switches[726]? 0 : 1)
        end
        @density=$cache.encounters[mapID][0]
        #p @density
        ##YUMIL -25 -END     
        @enctypes=$cache.encounters[mapID][1]
        else
        @density=nil
        @enctypes=[]
        end
        rescue
        @density=nil
        @enctypes=[]
    end
end

def pbGenerateEncounter(enctype)
    if enctype<0 || enctype>EncounterTypes::EnctypeChances.length
    raise ArgumentError.new(_INTL("Encounter type out of range"))
    end
    return nil if @density==nil
    return nil if @density[enctype]==0 || !@density[enctype]
    return nil if @enctypes[enctype]==nil
    @stepcount+=1
    #return nil if @stepcount<=10 && # Check three steps after battle ends
    encount=@density[enctype]*16
    if $PokemonGlobal.bicycle
    encount=(encount*4/5)
    end
    if $PokemonMap.blackFluteUsed
    encount/=2
    end
    if $PokemonMap.whiteFluteUsed
    encount=(encount*3/2)
    end
    if $Trainer.party.length>0 && !$Trainer.party[0].isEgg?
    if ($Trainer.party[0].item == PBItems::CLEANSETAG)
        encount=(encount*2/3)
    elsif ($Trainer.party[0].item == PBItems::PUREINCENSE)
        encount=(encount*2/3)
    else   # Ignore ability effects if an item effect applies
        if ($Trainer.party[0].ability == PBAbilities::STENCH)
        encount=(encount/2)
        elsif ($Trainer.party[0].ability == PBAbilities::WHITESMOKE)
        encount=(encount/2)
        elsif ($Trainer.party[0].ability == PBAbilities::QUICKFEET)
        encount=(encount/2)
        elsif ($Trainer.party[0].ability == PBAbilities::SNOWCLOAK) &&
            $game_screen.weather_type==3
        encount=(encount/2)
        elsif ($Trainer.party[0].ability == PBAbilities::SANDVEIL) &&
            $game_screen.weather_type==4
        encount=(encount/2)
        elsif ($Trainer.party[0].ability == PBAbilities::SWARM)
        encount=(encount*3/2)
        elsif ($Trainer.party[0].ability == PBAbilities::ILLUMINATE)
        encount=(encount*2)
        elsif ($Trainer.party[0].ability == PBAbilities::ARENATRAP)
        encount=(encount*2)
        elsif ($Trainer.party[0].ability == PBAbilities::NOGUARD)
        encount=(encount*2)
        end
    end
    end
    return nil if rand(250*16)>=encount
    encpoke=pbEncounteredPokemon(enctype)
    if $Trainer.party.length>0 && !$Trainer.party[0].isEgg?
    if encpoke && ($Trainer.party[0].ability == PBAbilities::INTIMIDATE) &&
        encpoke[1]<=$Trainer.party[0].level-5 && rand(2)==0
        encpoke=nil
    end
    if encpoke && ($Trainer.party[0].ability == PBAbilities::KEENEYE) &&
        encpoke[1]<=$Trainer.party[0].level-5 && rand(2)==0
        encpoke=nil
    end
    end
    return encpoke
end
end