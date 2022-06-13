def pbIsOldSpecialType?(type)
  return isConst?(type,PBTypes,:FIRE) ||
         isConst?(type,PBTypes,:WATER) ||
         isConst?(type,PBTypes,:ICE) ||
         isConst?(type,PBTypes,:GRASS) ||
         isConst?(type,PBTypes,:ELECTRIC) ||
         isConst?(type,PBTypes,:PSYCHIC) ||
         isConst?(type,PBTypes,:DRAGON) ||
         isConst?(type,PBTypes,:DARK)
end



################################################################################
# Make up internal names for things based on their actual names.
################################################################################
module MakeshiftConsts
  @@consts=[]

  def self.get(c,i,modname=nil)
    if !@@consts[c]
      @@consts[c]=[]
    end
    if @@consts[c][i]
      return @@consts[c][i]
    end
    if modname
      v=getConstantName(modname,i) rescue nil
      if v
        @@consts[c][i]=v
        return v
      end
    end
    trname=pbGetMessage(c,i)
    trconst=trname.gsub(/é/,"e")
    trconst=trconst.upcase
    trconst=trconst.gsub(/♀/,"fE")
    trconst=trconst.gsub(/♂/,"mA")
    trconst=trconst.gsub(/[^A-Za-z0-9_]/,"")
    if trconst.length==0
      return nil if trname.length==0
      trconst=sprintf("T_%03d",i)
    elsif !trconst[0,1][/[A-Z]/]
      trconst="T_"+trconst
    end
    while @@consts[c].include?(trconst)
      trconst=sprintf("%s_%03d",trconst,i)
    end
    @@consts[c][i]=trconst
    return trconst
  end
end



def pbGetTypeConst(i)
  ret=MakeshiftConsts.get(MessageTypes::Types,i,PBTypes)
  if !ret
    ret=["NORMAL","FIGHTING","FLYING","POISON","GROUND",
         "ROCK","BUG","GHOST","STEEL","QMARKS",
         "FIRE","WATER","GRASS","ELECTRIC",
         "PSYCHIC","ICE","DRAGON","DARK"][i]
  end
  return ret
end

def pbGetEvolutionConst(i)
  ret=["Unknown",
     "Happiness","HappinessDay","HappinessNight","Level","Trade",
     "TradeItem","Item","AttackGreater","AtkDefEqual","DefenseGreater",
     "Silcoon","Cascoon","Ninjask","Shedinja","Beauty",
     "ItemMale","ItemFemale","DayHoldItem","NightHoldItem","HasMove",
     "HasInParty","LevelMale","LevelFemale","Location","TradeSpecies",
     "Custom1","Custom2","Custom3","Custom4","Custom5","Custom6","Custom7",
     "Custom8"
  ]
  i=0 if i>=ret.length || i<0
  return ret[i]
end

def pbGetAbilityConst(i)
  return MakeshiftConsts.get(MessageTypes::Abilities,i,PBAbilities)
end

def pbGetMoveConst(i)
  return MakeshiftConsts.get(MessageTypes::Moves,i,PBMoves)
end

def pbGetItemConst(i)
  return MakeshiftConsts.get(MessageTypes::Items,i,PBItems)
end

def pbGetSpeciesConst(i)
  return MakeshiftConsts.get(MessageTypes::Species,i,PBSpecies)
end

def pbGetTrainerConst(i)
  name=MakeshiftConsts.get(MessageTypes::TrainerTypes,i,PBTrainers)
end



################################################################################
# Save data to PBS files
################################################################################
def pbSavePokemonData
  dexdata=File.open("Data/dexdata.dat","rb") rescue nil
  messages=Messages.new("Data/messages.dat") rescue nil
  return if !dexdata || !messages
  metrics=load_data("Data/metrics.dat") rescue nil
  atkdata=File.open("Data/attacksRS.dat","rb")
  eggEmerald=File.open("Data/eggEmerald.dat","rb")
  regionaldata=File.open("Data/regionals.dat","rb")
  numRegions=regionaldata.fgetw
  numDexDatas=regionaldata.fgetw
  pokedata=File.open("PBS/pokemon.txt","wb") rescue nil
  pokedata.write(0xEF.chr)
  pokedata.write(0xBB.chr)
  pokedata.write(0xBF.chr)
  for i in 1..(PBSpecies.maxValue rescue PBSpecies.getCount-1 rescue messages.getCount(MessageTypes::Species)-1)
    cname=getConstantName(PBSpecies,i) rescue next
    speciesname=messages.get(MessageTypes::Species,i)
    kind=messages.get(MessageTypes::Kinds,i)
    entry=messages.get(MessageTypes::Entries,i)
    formnames=messages.get(MessageTypes::FormNames,i)
    pbDexDataOffset(dexdata,i,6)
    color=dexdata.fgetb
    habitat=dexdata.fgetb
    type1=dexdata.fgetb
    type2=dexdata.fgetb
    basestats=[]
    for j in 0...6
      basestats.push(dexdata.fgetb)
    end
    rareness=dexdata.fgetb
    pbDexDataOffset(dexdata,i,18)
    gender=dexdata.fgetb
    happiness=dexdata.fgetb
    growthrate=dexdata.fgetb
    stepstohatch=dexdata.fgetw
    effort=[]
    for j in 0...6
      effort.push(dexdata.fgetb)
    end
    ability1=dexdata.fgetb
    ability2=dexdata.fgetb
    compat1=dexdata.fgetb
    compat2=dexdata.fgetb
    height=dexdata.fgetw
    weight=dexdata.fgetw
    pbDexDataOffset(dexdata,i,38)
    baseexp=dexdata.fgetw
    hiddenability1=dexdata.fgetb
    hiddenability2=dexdata.fgetb
    hiddenability3=dexdata.fgetb
    hiddenability4=dexdata.fgetb
    pbDexDataOffset(dexdata,i,48)
    item1=dexdata.fgetw
    item2=dexdata.fgetw
    item3=dexdata.fgetw
    pokedata.write("[#{i}]\r\nName=#{speciesname}\r\n")
    pokedata.write("InternalName=#{cname}\r\n")
    ctype1=getConstantName(PBTypes,type1) rescue pbGetTypeConst(type1) || pbGetTypeConst(0) || "NORMAL"
    pokedata.write("Type1=#{ctype1}\r\n")
    if type1!=type2
      ctype2=getConstantName(PBTypes,type2) rescue pbGetTypeConst(type2) || pbGetTypeConst(0) || "NORMAL"
      pokedata.write("Type2=#{ctype2}\r\n")
    end
    pokedata.write("BaseStats=#{basestats[0]},#{basestats[1]},#{basestats[2]},#{basestats[3]},#{basestats[4]},#{basestats[5]}\r\n")
    pokedata.write("GenderRate=AlwaysMale\r\n") if gender==0
    pokedata.write("GenderRate=FemaleOneEighth\r\n") if gender==31
    pokedata.write("GenderRate=Female25Percent\r\n") if gender==63
    pokedata.write("GenderRate=Female50Percent\r\n") if gender==127
    pokedata.write("GenderRate=Female75Percent\r\n") if gender==191
    pokedata.write("GenderRate=FemaleSevenEighths\r\n") if gender==223
    pokedata.write("GenderRate=AlwaysFemale\r\n") if gender==254
    pokedata.write("GenderRate=Genderless\r\n") if gender==255
    pokedata.write("GrowthRate=" + ["Medium","Erratic","Fluctuating","Parabolic","Fast","Slow"][growthrate]+"\r\n")
    pokedata.write("BaseEXP=#{baseexp}\r\n")
    pokedata.write("EffortPoints=#{effort[0]},#{effort[1]},#{effort[2]},#{effort[3]},#{effort[4]},#{effort[5]}\r\n")
    pokedata.write("Rareness=#{rareness}\r\n")
    pokedata.write("Happiness=#{happiness}\r\n")
    pokedata.write("Abilities=")
    if ability1!=0
      cability1=getConstantName(PBAbilities,ability1) rescue pbGetAbilityConst(ability1)
      pokedata.write("#{cability1}")
      pokedata.write(",") if ability2!=0
    end
    if ability2!=0
      cability2=getConstantName(PBAbilities,ability2) rescue pbGetAbilityConst(ability2)
      pokedata.write("#{cability2}")
    end
    pokedata.write("\r\n")
    if hiddenability1>0 || hiddenability2>0 || hiddenability3>0 || hiddenability4>0
      pokedata.write("HiddenAbility=")
      needcomma=false
      if hiddenability1>0
        cabilityh=getConstantName(PBAbilities,hiddenability1) rescue pbGetAbilityConst(hiddenability1)
        pokedata.write("#{cabilityh}"); needcomma=true
      end
      if hiddenability2>0
        pokedata.write(",") if needcomma
        cabilityh=getConstantName(PBAbilities,hiddenability2) rescue pbGetAbilityConst(hiddenability2)
        pokedata.write("#{cabilityh}"); needcomma=true
      end
      if hiddenability3>0
        pokedata.write(",") if needcomma
        cabilityh=getConstantName(PBAbilities,hiddenability3) rescue pbGetAbilityConst(hiddenability3)
        pokedata.write("#{cabilityh}"); needcomma=true
      end
      if hiddenability4>0
        pokedata.write(",") if needcomma
        cabilityh=getConstantName(PBAbilities,hiddenability4) rescue pbGetAbilityConst(hiddenability4)
        pokedata.write("#{cabilityh}")
      end
      pokedata.write("\r\n")
    end
    pokedata.write("Moves=")
    offset=atkdata.getOffset(i-1)
    length=atkdata.getLength(i-1)>>1
    atkdata.pos=offset
    movelist=[]
    for j in 0...length
      alevel=atkdata.fgetw
      move=atkdata.fgetw
      movelist.push([j,alevel,move])
    end
    movelist.sort!{|a,b| a[1]==b[1] ? a[0]<=>b[0] : a[1]<=>b[1] }
    for j in 0...movelist.length
      alevel=movelist[j][1]
      move=movelist[j][2]
      pokedata.write(",") if j>0
      cmove=getConstantName(PBMoves,move) rescue pbGetMoveConst(move)
      pokedata.write(sprintf("%d,%s",alevel,cmove))
    end
    pokedata.write("\r\n")
    eggEmerald.pos=(i-1)*8
    offset=eggEmerald.fgetdw
    length=eggEmerald.fgetdw
    if length>0
      pokedata.write("EggMoves=")
      eggEmerald.pos=offset
      first=true
      j=0; loop do break unless j<length
        atk=eggEmerald.fgetw
        pokedata.write(",") if !first
        break if atk==0
        if atk>0
          cmove=getConstantName(PBMoves,atk) rescue pbGetMoveConst(atk)
          pokedata.write("#{cmove}")
          first=false
        end
        j+=1
      end
      pokedata.write("\r\n")
    end
    compatarray=["","Monster","Water1","Bug","Flying","Field","Fairy","Grass","Humanlike",
                 "Water3","Mineral","Amorphous","Water2","Ditto","Dragon","Undiscovered"]
    comp1=compatarray[compat1]
    comp2=compatarray[compat2]
    if compat1==compat2
      pokedata.write("Compatibility=#{comp1}\r\n")
    else
      pokedata.write("Compatibility=#{comp1},#{comp2}\r\n")
    end
    pokedata.write("StepsToHatch=#{stepstohatch}\r\n")
    pokedata.write("Height=")
    pokedata.write(sprintf("%.1f",height/10.0)) if height
    pokedata.write("\r\n")
    pokedata.write("Weight=")
    pokedata.write(sprintf("%.1f",weight/10.0)) if weight
    pokedata.write("\r\n")
    pokedata.write("Color="+["Red","Blue","Yellow","Green","Black","Brown","Purple","Gray","White","Pink"][color]+"\r\n")
    pokedata.write("Habitat="+["","Grassland","Forest","WatersEdge","Sea","Cave","Mountain","RoughTerrain","Urban","Rare"][habitat]+"\r\n") if habitat>0
    regionallist=[]
    for region in 0...numRegions
      regionaldata.pos=4+region*numDexDatas*2+(i*2)
      regionallist.push(regionaldata.fgetw)
    end
    numb = regionallist.size-1
    while (numb>=0) # remove every 0 at end of array 
      (regionallist[numb] == 0) ? regionallist.pop : break
      numb-=1
    end
    if !regionallist.empty?
      pokedata.write("RegionalNumbers="+regionallist[0].to_s)
      for numb in 1...regionallist.size
        pokedata.write(","+regionallist[numb].to_s)
      end
      pokedata.write("\r\n")
    end
    pokedata.write("Kind=#{kind}\r\n")
    pokedata.write("Pokedex=#{entry}\r\n")
    if formnames && formnames!=""
      pokedata.write("FormNames=#{formnames}\r\n")
    end
    if item1>0
      citem1=getConstantName(PBItems,item1) rescue pbGetItemConst(item1)
      pokedata.write("WildItemCommon=#{citem1}\r\n")
    end
    if item2>0
      citem2=getConstantName(PBItems,item2) rescue pbGetItemConst(item2)
      pokedata.write("WildItemUncommon=#{citem2}\r\n")
    end
    if item3>0
      citem3=getConstantName(PBItems,item3) rescue pbGetItemConst(item3)
      pokedata.write("WildItemRare=#{citem3}\r\n")
    end
    if metrics
      pokedata.write("BattlerPlayerY=#{metrics[0][i] || 0}\r\n")
      pokedata.write("BattlerEnemyY=#{metrics[1][i] || 0}\r\n")
      pokedata.write("BattlerAltitude=#{metrics[2][i] || 0}\r\n")
    end
    pokedata.write("Evolutions=")
    count=0
    for form in pbGetEvolvedFormData(i)
      evonib=form[0]
      level=form[1]
      poke=form[2]
      next if poke==0 || evonib==PBEvolution::Unknown
      cpoke=getConstantName(PBSpecies,poke) rescue pbGetSpeciesConst(poke)
      evoname=getConstantName(PBEvolution,evonib) rescue pbGetEvolutionConst(evonib)
      next if !cpoke || cpoke==""
      pokedata.write(",") if count>0
      pokedata.write(sprintf("%s,%s,",cpoke,evoname))
      case PBEvolution::EVOPARAM[evonib]
        when 1
          pokedata.write(_ISPRINTF("{1:d}",level))
        when 2
          clevel=getConstantName(PBItems,level) rescue pbGetItemConst(level)
          pokedata.write("#{clevel}")
        when 3
          clevel=getConstantName(PBMoves,level) rescue pbGetMoveConst(level)
          pokedata.write("#{clevel}")
        when 4
          clevel=getConstantName(PBSpecies,level) rescue pbGetSpeciesConst(level)
          pokedata.write("#{clevel}")
        when 5
          clevel=getConstantName(PBTypes,level) rescue pbGetTypeConst(level)
          pokedata.write("#{clevel}")
      end
      count+=1
    end
    pokedata.write("\r\n")
    if i%20==0
      Graphics.update
      pbSetWindowText(_INTL("Processing species {1}...",i))
    end
  end
  dexdata.close
  atkdata.close
  eggEmerald.close
  regionaldata.close
  pokedata.close
  Graphics.update
end

def pbSaveTypes
  return if (PBTypes.maxValue rescue 0)==0
  File.open("PBS/types.txt","wb"){|f|
     f.write(0xEF.chr)
     f.write(0xBB.chr)
     f.write(0xBF.chr)
     for i in 0..(PBTypes.maxValue rescue 25)
       name=PBTypes.getName(i) rescue nil
       next if !name || name==""
       constname=getConstantName(PBTypes,i) rescue pbGetTypeConst(i)
       f.write(sprintf("[%d]\r\n",i))
       f.write(sprintf("Name=%s\r\n",name))
       f.write(sprintf("InternalName=%s\r\n",constname))
       if (PBTypes.isPseudoType?(i) rescue isConst?(i,PBTypes,QMARKS))
         f.write("IsPseudoType=true\r\n")
       end
       if (PBTypes.isSpecialType?(i) rescue pbIsOldSpecialType?(i))
         f.write("IsSpecialType=true\r\n")
       end
       weak=[]
       resist=[]
       immune=[]
       for j in 0..(PBTypes.maxValue rescue 25)
         cname=getConstantName(PBTypes,j) rescue pbGetTypeConst(j)
         next if !cname || cname==""
         eff=PBTypes.getEffectiveness(j,i)
         weak.push(cname) if eff==4
         resist.push(cname) if eff==1
         immune.push(cname) if eff==0
       end
       f.write("Weaknesses="+weak.join(",")+"\r\n") if weak.length>0
       f.write("Resistances="+resist.join(",")+"\r\n") if resist.length>0
       f.write("Immunities="+immune.join(",")+"\r\n") if immune.length>0
       f.write("\r\n")
     end
  }
end

def pbSaveAbilities()
  File.open("PBS/abilities.txt","wb"){|f|
     f.write(0xEF.chr)
     f.write(0xBB.chr)
     f.write(0xBF.chr)
     for i in 1..(PBAbilities.maxValue rescue PBAbilities.getCount-1 rescue pbGetMessageCount(MessageTypes::Abilities)-1)
       abilname=getConstantName(PBAbilities,i) rescue pbGetAbilityConst(i)
       next if !abilname || abilname==""
       name=pbGetMessage(MessageTypes::Abilities,i)
       next if !name || name==""
       f.write(sprintf("%d,%s,%s,%s\r\n",i,
          csvquote(abilname),
          csvquote(name),
          csvquote(pbGetMessage(MessageTypes::AbilityDescs,i))
       ))
     end
  }
end

def pbSaveItems
  itemData=readItemList("Data/items.dat") rescue nil
  return if !itemData || itemData.length==0
  File.open("PBS/items.txt","wb"){|f|
     f.write(0xEF.chr)
     f.write(0xBB.chr)
     f.write(0xBF.chr)
     for i in 0...itemData.length
       next if !itemData[i]
       data=itemData[i]
       cname=getConstantName(PBItems,i) rescue sprintf("ITEM%03d",i)
       next if !cname || cname=="" || data[0]==0
       machine=""
       if data[ITEMMACHINE]>0
         machine=getConstantName(PBMoves,data[ITEMMACHINE]) rescue pbGetMoveConst(data[ITEMMACHINE]) rescue ""
       end
       f.write(sprintf("%d,%s,%s,%d,%d,%s,%d,%d,%d,%s\r\n",
          data[ITEMID],csvquote(cname),csvquote(data[ITEMNAME]),
          data[ITEMPOCKET],data[ITEMPRICE],csvquote(data[ITEMDESC]),
          data[ITEMUSE],data[ITEMBATTLEUSE],data[ITEMTYPE],
          csvquote(machine)
       ))
     end
 }
end

def pbSaveMoveData()
  return if !pbRgssExists?("Data/moves.dat")
  File.open("PBS/moves.txt","wb"){|f|
     f.write(0xEF.chr)
     f.write(0xBB.chr)
     f.write(0xBF.chr)
     for i in 1..(PBMoves.maxValue rescue PBMoves.getCount-1 rescue pbGetMessageCount(MessageTypes::Moves)-1)
       moveconst=getConstantName(PBMoves,i) rescue pbGetMoveConst(i) rescue nil
       next if !moveconst || moveconst==""
       movename=pbGetMessage(MessageTypes::Moves,i)
       movedata=PBMoveData.new(i)
       flags=""
       flags+="a" if (movedata.flags&0x00001)!=0
       flags+="b" if (movedata.flags&0x00002)!=0
       flags+="c" if (movedata.flags&0x00004)!=0
       flags+="d" if (movedata.flags&0x00008)!=0
       flags+="e" if (movedata.flags&0x00010)!=0
       flags+="f" if (movedata.flags&0x00020)!=0
       flags+="g" if (movedata.flags&0x00040)!=0
       flags+="h" if (movedata.flags&0x00080)!=0
       flags+="i" if (movedata.flags&0x00100)!=0
       flags+="j" if (movedata.flags&0x00200)!=0
       flags+="k" if (movedata.flags&0x00400)!=0
       flags+="l" if (movedata.flags&0x00800)!=0
       flags+="m" if (movedata.flags&0x01000)!=0
       flags+="n" if (movedata.flags&0x02000)!=0
       flags+="o" if (movedata.flags&0x04000)!=0
       flags+="p" if (movedata.flags&0x08000)!=0
       f.write(sprintf("%d,%s,%s,%03X,%d,%s,%s,%d,%d,%d,%02X,%d,%s,%s\r\n",
          i,csvquote(moveconst),csvquote(movename),
          movedata.function,
          movedata.basedamage,
          csvquote((getConstantName(PBTypes,movedata.type) rescue pbGetTypeConst(movedata.type) rescue "")),
          csvquote(["Physical","Special","Status"][movedata.category]),
          movedata.accuracy,
          movedata.totalpp,
          movedata.addlEffect,
          movedata.target,
          movedata.priority,
          flags,
          csvquote(pbGetMessage(MessageTypes::MoveDescriptions,i))
       ))
     end
 }
end

def pbSaveMachines
  machines=load_data("Data/tm.dat") rescue nil
  return if !machines
  File.open("PBS/tm.txt","wb"){|f|
     for i in 1...machines.length
       Graphics.update if i%50==0
       next if !machines[i]
       movename=getConstantName(PBMoves,i) rescue pbGetMoveConst(i) rescue nil
       next if !movename || movename==""
       f.write("\#-------------------\r\n")
       f.write(sprintf("[%s]\r\n",movename))
       x=[]
       for j in 0...machines[i].length
         speciesname=getConstantName(PBSpecies,machines[i][j]) rescue pbGetSpeciesConst(machines[i][j]) rescue nil
         next if !speciesname || speciesname==""
         x.push(speciesname)
       end
       f.write(x.join(",")+"\r\n")
     end
  }
end

def pbSaveShadowMoves
  moves=load_data("Data/shadowmoves.dat") rescue []
  File.open("PBS/shadowmoves.txt","wb"){|f|
     for i in 0...moves.length
       move=moves[i]
       if move && moves.length>0
         constname=(getConstantName(PBSpecies,i) rescue pbGetSpeciesConst(i) rescue nil)
         next if !constname
         f.write(sprintf("%s=",constname))
         movenames=[]
         for m in move
           movenames.push((getConstantName(PBMoves,m) rescue pbGetMoveConst(m) rescue nil))
         end
         f.write(sprintf("%s\r\n",movenames.compact.join(",")))
       end
     end
  }
end

def pbSaveTrainerTypes()
  data=load_data("Data/trainertypes.dat") rescue nil
  return if !data
  File.open("PBS/trainertypes.txt","wb"){|f|
     f.write(0xEF.chr)
     f.write(0xBB.chr)
     f.write(0xBF.chr)
     f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
     f.write("\r\n")
     for i in 0...data.length
       record=data[i]
       if record
         dataline=sprintf("%d,%s,%s,%d,%s,%s,%s,%s,%s\r\n",
            i,record[1],record[2],
            record[3],
            record[4] ? record[4] : "",
            record[5] ? record[5] : "",
            record[6] ? record[6] : "",
            record[7] ? ["Male","Female","Mixed"][record[7]] : "Mixed",
            record[8]!=record[3] ? record[8] : ""
         )
         f.write(dataline)
       end
     end
  }
end

def pbSaveTrainerBattles()
  data=load_data("Data/trainers.dat") rescue nil
  return if !data
  File.open("PBS/trainers.txt","wb"){|f|
     f.write(0xEF.chr)
     f.write(0xBB.chr)
     f.write(0xBF.chr)
     f.write("\# "+_INTL("See the documentation on the wiki to learn how to edit this file."))
     f.write("\r\n")
     for trainer in data
       trname=getConstantName(PBTrainers,trainer[0]) rescue pbGetTrainerConst(trainer[0]) rescue nil
       next if !trname
       f.write("\#-------------------\r\n")
       f.write(sprintf("%s\r\n",trname))
       trainername=trainer[1] ? trainer[1].gsub(/,/,";") : "???"
       if trainer[4]==0
         f.write(sprintf("%s\r\n",trainername))
       else
         f.write(sprintf("%s,%d\r\n",trainername,trainer[4]))
       end
       f.write(sprintf("%d",trainer[3].length))
       for i in 0...8
         itemname=getConstantName(PBItems,trainer[2][i]) rescue pbGetItemConst(trainer[2][i]) rescue nil
         f.write(sprintf(",%s",itemname)) if trainer[2][i]
       end
       f.write("\r\n")
       for poke in trainer[3]
         maxindex=0
         towrite=[]
         thistemp=getConstantName(PBSpecies,poke[TPSPECIES]) rescue pbGetSpeciesConst(poke[TPSPECIES]) rescue ""
         towrite[TPSPECIES]=thistemp
         towrite[TPLEVEL]=poke[TPLEVEL].to_s
         thistemp=getConstantName(PBItems,poke[TPITEM]) rescue pbGetItemConst(poke[TPITEM]) rescue ""
         towrite[TPITEM]=thistemp
         thistemp=getConstantName(PBMoves,poke[TPMOVE1]) rescue pbGetMoveConst(poke[TPMOVE1]) rescue ""
         towrite[TPMOVE1]=thistemp
         thistemp=getConstantName(PBMoves,poke[TPMOVE2]) rescue pbGetMoveConst(poke[TPMOVE2]) rescue ""
         towrite[TPMOVE2]=thistemp
         thistemp=getConstantName(PBMoves,poke[TPMOVE3]) rescue pbGetMoveConst(poke[TPMOVE3]) rescue ""
         towrite[TPMOVE3]=thistemp
         thistemp=getConstantName(PBMoves,poke[TPMOVE4]) rescue pbGetMoveConst(poke[TPMOVE4]) rescue ""
         towrite[TPMOVE4]=thistemp
         towrite[TPABILITY]=(poke[TPABILITY] ? poke[TPABILITY].to_s : "")
         towrite[TPGENDER]=(poke[TPGENDER] ? ["M","F"][poke[TPGENDER]] : "")
         towrite[TPFORM]=(poke[TPFORM] && poke[TPFORM]!=TPDEFAULTS[TPFORM] ? poke[TPFORM].to_s : "")
         towrite[TPSHINY]=(poke[TPSHINY] ? "shiny" : "")
         towrite[TPNATURE]=(poke[TPNATURE] ? getConstantName(PBNatures,poke[TPNATURE]) : "")
         towrite[TPIV]=(poke[TPIV] && poke[TPIV]!=TPDEFAULTS[TPIV] ? poke[TPIV].to_s : "")
         towrite[TPHAPPINESS]=(poke[TPHAPPINESS] && poke[TPHAPPINESS]!=TPDEFAULTS[TPHAPPINESS] ? poke[TPHAPPINESS].to_s : "")
         towrite[TPNAME]=(poke[TPNAME] ? poke[TPNAME] : "")
         towrite[TPSHADOW]=(poke[TPSHADOW] ? "true" : "")
         towrite[TPBALL]=(poke[TPBALL] && poke[TPBALL]!=TPDEFAULTS[TPBALL] ? poke[TPBALL].to_s : "")
         for i in 0...towrite.length
           towrite[i]="" if !towrite[i]
           maxindex=i if towrite[i] && towrite[i]!=""
         end
         for i in 0..maxindex
           f.write(",") if i>0
           f.write(towrite[i])
         end
         f.write("\r\n")
       end
     end
  }
end

def normalizeConnectionPoint(conn)
  ret=conn.clone
  if conn[1]<0 && conn[4]<0
  elsif conn[1]<0 || conn[4]<0
    ret[4]=-conn[1]
    ret[1]=-conn[4]
  end
  if conn[2]<0 && conn[5]<0
  elsif conn[2]<0 || conn[5]<0
    ret[5]=-conn[2]
    ret[2]=-conn[5]
  end
  return ret
end

def writeConnectionPoint(map1,x1,y1,map2,x2,y2)
  dims1=MapFactoryHelper.getMapDims(map1)
  dims2=MapFactoryHelper.getMapDims(map2)
  if x1==0 && x2==dims2[0]
    return sprintf("%d,West,%d,%d,East,%d\r\n",map1,y1,map2,y2)
  elsif y1==0 && y2==dims2[1]
    return sprintf("%d,North,%d,%d,South,%d\r\n",map1,x1,map2,x2)
  elsif x1==dims1[0] && x2==0
    return sprintf("%d,East,%d,%d,West,%d\r\n",map1,y1,map2,y2)
  elsif y1==dims1[1] && y2==0
    return sprintf("%d,South,%d,%d,North,%d\r\n",map1,x1,map2,x2)
  else
    return sprintf("%d,%d,%d,%d,%d,%d\r\n",map1,x1,y1,map2,x2,y2)
  end
end

def pbSaveConnectionData
  data=load_data("Data/connections.dat") rescue nil
  return if !data
  pbSerializeConnectionData(data,pbLoadRxData("Data/MapInfos"))
end

def pbSerializeConnectionData(conndata,mapinfos)
  File.open("PBS/connections.txt","wb"){|f|
     for conn in conndata
       if mapinfos
         # Skip if map no longer exists
         next if !mapinfos[conn[0]] || !mapinfos[conn[3]]
         f.write(sprintf("# %s (%d) - %s (%d)\r\n",
            mapinfos[conn[0]] ? mapinfos[conn[0]].name : "???",conn[0],
            mapinfos[conn[3]] ? mapinfos[conn[3]].name : "???",conn[3]))
         end
         if conn[1].is_a?(String) || conn[4].is_a?(String)
           f.write(sprintf("%d,%s,%d,%d,%s,%d\r\n",conn[0],conn[1],
              conn[2],conn[3],conn[4],conn[5]))
         else
           ret=normalizeConnectionPoint(conn)
           f.write(writeConnectionPoint(
              ret[0],
              ret[1],
              ret[2],
              ret[3],
              ret[4],
              ret[5]
           ))
         end
       end
  }
  save_data(conndata,"Data/connections.dat")
end

def pbSaveMetadata
  data=load_data("Data/metadata.dat") rescue nil
  return if !data
  pbSerializeMetadata(data,pbLoadRxData("Data/MapInfos"))
end

def pbSerializeMetadata(metadata,mapinfos)
  save_data(metadata,"Data/metadata.dat")
  File.open("PBS/metadata.txt","wb"){|f|
     f.write(0xEF.chr)
     f.write(0xBB.chr)
     f.write(0xBF.chr)
     for i in 0...metadata.length
       next if !metadata[i]
       f.write(sprintf("[%03d]\r\n",i))
       if i==0
         types=PokemonMetadata::GlobalTypes
       else
         if mapinfos && mapinfos[i]
           f.write(sprintf("# %s\r\n",mapinfos[i].name))
         end
         types=PokemonMetadata::NonGlobalTypes
       end
       for key in types.keys
         schema=types[key]
         record=metadata[i][schema[0]]
         next if record==nil
         f.write(sprintf("%s=",key))
         pbWriteCsvRecord(record,f,schema)
         f.write(sprintf("\r\n"))
       end
    end
  }
end

def pbSaveEncounterData()
  encdata=load_data("Data/encounters.dat") rescue nil
  return if !encdata
  mapinfos=pbLoadRxData("Data/MapInfos")  
  File.open("PBS/encounters.txt","wb"){|f|
     sortedkeys=encdata.keys.sort{|a,b| a<=>b}
     for i in sortedkeys
       if encdata[i]
         e=encdata[i]
         mapname=""
         if mapinfos[i]
           map=mapinfos[i].name
           mapname=" # #{map}"
         end
         f.write(sprintf("#########################\r\n"))
         f.write(sprintf("%03d%s\r\n",i,mapname))
         f.write(sprintf("%d,%d,%d\r\n",e[0][EncounterTypes::Land],
             e[0][EncounterTypes::Cave],e[0][EncounterTypes::Water]))
         for j in 0...e[1].length
           enc=e[1][j]
           next if !enc
           f.write(sprintf("%s\r\n",EncounterTypes::Names[j]))
           for k in 0...EncounterTypes::EnctypeChances[j].length
             encentry=(enc[k]) ? enc[k] : [1,5,5]
             species=getConstantName(PBSpecies,encentry[0]) rescue pbGetSpeciesConst(encentry[0])
             if encentry[1]==encentry[2]
               f.write(sprintf("%s,%d\r\n",species,encentry[1]))
             else
               f.write(sprintf("%s,%d,%d\r\n",species,encentry[1],encentry[2]))
             end
           end
         end
       end
     end
  }
end

def pbSaveTownMap()
  mapdata=load_data("Data/townmap.dat") rescue nil
  return if !mapdata
  File.open("PBS/townmap.txt","wb"){|f|
     f.write(0xEF.chr)
     f.write(0xBB.chr)
     f.write(0xBF.chr)
     for i in 0...mapdata.length
       map=mapdata[i]
       return if !map
       f.write(sprintf("[%d]\r\n",i))
       f.write(sprintf("Name=%s\r\nFilename=%s\r\n",
          csvquote(map[0].is_a?(Array) ? map[0][0] : map[0]),
          csvquote(map[1].is_a?(Array) ? map[1][0] : map[1])))
       for loc in map[2]
         f.write("Point=")
         pbWriteCsvRecord(loc,f,[nil,"uussUUUU"])
         f.write("\r\n")
       end
     end
  }
end

def pbSavePhoneData
  data=load_data("Data/phone.dat") rescue nil
  return if !data
  File.open("PBS/phone.txt","wb"){|f|
     f.write(0xEF.chr)
     f.write(0xBB.chr)
     f.write(0xBF.chr)
     f.write("[<Generics>]\r\n")
     f.write(data.generics.join("\r\n")+"\r\n")
     f.write("[<BattleRequests>]\r\n")
     f.write(data.battleRequests.join("\r\n")+"\r\n")
     f.write("[<GreetingsMorning>]\r\n")
     f.write(data.greetingsMorning.join("\r\n")+"\r\n")
     f.write("[<GreetingsEvening>]\r\n")
     f.write(data.greetingsEvening.join("\r\n")+"\r\n")
     f.write("[<Greetings>]\r\n")
     f.write(data.greetings.join("\r\n")+"\r\n")
     f.write("[<Bodies1>]\r\n")
     f.write(data.bodies1.join("\r\n")+"\r\n")
     f.write("[<Bodies2>]\r\n")
     f.write(data.bodies2.join("\r\n")+"\r\n")
  }
end

def pbSaveTrainerLists()
  trainerlists=load_data("Data/trainerlists.dat") rescue nil
  return if !trainerlists
  File.open("PBS/trainerlists.txt","wb"){|f|
     f.write(0xEF.chr)
     f.write(0xBB.chr)
     f.write(0xBF.chr)
     for tr in trainerlists
       f.write((tr[5] ? "[DefaultTrainerList]" : "[TrainerList]")+"\r\n")
       f.write("Trainers="+tr[3]+"\r\n")
       f.write("Pokemon="+tr[4]+"\r\n")
       if !tr[5]
         f.write("Challenges="+tr[2].join(",")+"\r\n")
       end
       pbSaveBTTrainers(tr[0],"PBS/"+tr[3])
       pbSaveBattlePokemon(tr[1],"PBS/"+tr[4])
     end
  }
end

def pbSaveBTTrainers(bttrainers,filename)
  return if !bttrainers || !filename
  btTrainersRequiredTypes={
     "Type"=>[0,"e",nil],# Specifies a trainer
     "Name"=>[1,"s"],
     "BeginSpeech"=>[2,"s"],
     "EndSpeechWin"=>[3,"s"],
     "EndSpeechLose"=>[4,"s"],
     "PokemonNos"=>[5,"*u"]
  }
  File.open(filename,"wb"){|f|
     f.write(0xEF.chr)
     f.write(0xBB.chr)
     f.write(0xBF.chr)
     for i in 0...bttrainers.length
       next if !bttrainers[i]
       f.write(sprintf("[%03d]\r\n",i))
       for key in btTrainersRequiredTypes.keys
         schema=btTrainersRequiredTypes[key]
         record=bttrainers[i][schema[0]]
         next if record==nil
         f.write(sprintf("%s=",key))
         if key=="Type"
           f.write((getConstantName(PBTrainers,record) rescue pbGetTrainerConst(record)))
         elsif key=="PokemonNos"
           f.write(record.join(",")) # pbWriteCsvRecord somehow won't work here
         else
           pbWriteCsvRecord(record,f,schema)
         end
         f.write(sprintf("\r\n"))
       end
     end
 }
end

def pbSaveBattlePokemon(btpokemon,filename)
  return if !btpokemon || !filename
  species={0=>""}
  moves={0=>""}
  items={0=>""}
  natures={}
  File.open(filename,"wb"){|f|
     for i in 0...btpokemon.length
       Graphics.update if i%500==0
       pkmn=btpokemon[i]
       f.write(pbFastInspect(pkmn,moves,species,items,natures))
       f.write("\r\n")
     end
  }
end

def pbFastInspect(pkmn,moves,species,items,natures)
  c1=species[pkmn.species] ? species[pkmn.species] :
     (species[pkmn.species]=(getConstantName(PBSpecies,pkmn.species) rescue pbGetSpeciesConst(pkmn.species)))
  c2=items[pkmn.item] ? items[pkmn.item] :
     (items[pkmn.item]=(getConstantName(PBItems,pkmn.item) rescue pbGetItemConst(pkmn.item)))
  c3=natures[pkmn.nature] ? natures[pkmn.nature] :
     (natures[pkmn.nature]=getConstantName(PBNatures,pkmn.nature))
  evlist=""
  ev=pkmn.ev
  evs=["HP","ATK","DEF","SPD","SA","SD"]
  for i in 0...ev
    if ((ev&(1<<i))!=0)
      evlist+="," if evlist.length>0
      evlist+=evs[i]
    end
  end
  c4=moves[pkmn.move1] ? moves[pkmn.move1] :
     (moves[pkmn.move1]=(getConstantName(PBMoves,pkmn.move1) rescue pbGetMoveConst(pkmn.move1)))
  c5=moves[pkmn.move2] ? moves[pkmn.move2] :
     (moves[pkmn.move2]=(getConstantName(PBMoves,pkmn.move2) rescue pbGetMoveConst(pkmn.move2)))
  c6=moves[pkmn.move3] ? moves[pkmn.move3] :
     (moves[pkmn.move3]=(getConstantName(PBMoves,pkmn.move3) rescue pbGetMoveConst(pkmn.move3)))
  c7=moves[pkmn.move4] ? moves[pkmn.move4] :
     (moves[pkmn.move4]=(getConstantName(PBMoves,pkmn.move4) rescue pbGetMoveConst(pkmn.move4)))
  return "#{c1};#{c2};#{c3};#{evlist};#{c4},#{c5},#{c6},#{c7}"
end

def pbSaveAllData
  pbSaveTypes; Graphics.update
  pbSaveAbilities; Graphics.update
  pbSaveMoveData; Graphics.update
  pbSaveConnectionData; Graphics.update
  pbSaveMetadata; Graphics.update
  pbSaveItems; Graphics.update
  pbSaveTrainerLists; Graphics.update
  pbSaveMachines; Graphics.update
  pbSaveEncounterData; Graphics.update
  pbSaveTrainerTypes; Graphics.update
  pbSaveTrainerBattles; Graphics.update
  pbSaveTownMap; Graphics.update
  pbSavePhoneData; Graphics.update
  pbSavePokemonData; Graphics.update
  pbSaveShadowMoves; Graphics.update
end



################################################################################
# Lists
################################################################################
def pbListWindow(cmds,width=256)
  list=Window_CommandPokemon.newWithSize(cmds,0,0,width,Graphics.height)
  list.index=0
  list.rowHeight=24
  pbSetSmallFont(list.contents)
  list.refresh
  return list
end

def pbChooseSpecies(default)
  cmdwin=pbListWindow([],200)
  commands=[]
  for i in 1..PBSpecies.maxValue
    cname=getConstantName(PBSpecies,i) rescue nil
    commands.push(_ISPRINTF("{1:03d} {2:s}",i,PBSpecies.getName(i))) if cname
  end
  ret=pbCommands2(cmdwin,commands,-1,default-1,true)
  cmdwin.dispose
  return ret>=0 ? ret+1 : 0
end

def pbChooseSpeciesOrdered(default)
  cmdwin=pbListWindow([],200)
  commands=[]
  for i in 1..PBSpecies.maxValue
    cname=getConstantName(PBSpecies,i) rescue nil
    commands.push([i,PBSpecies.getName(i)]) if cname
  end
  commands.sort! {|a,b| a[1]<=>b[1]}
  realcommands=[]
  for command in commands
    realcommands.push(_ISPRINTF("{1:03d} {2:s}",command[0],command[1]))
  end
  ret=pbCommands2(cmdwin,realcommands,-1,default-1,true)
  cmdwin.dispose
  return ret>=0 ? commands[ret][0] : 0
end

# Displays a sorted list of Pokémon species, and returns the ID of the species
# selected or 0 if the selection was canceled.  defaultItemID, if specified,
# indicates the ID of the species initially shown on the list.
def pbChooseSpeciesList(defaultItemID=0)
  cmdwin=pbListWindow([],200)
  commands=[]
  itemDefault=0
  for c in PBSpecies.constants
    i=PBSpecies.const_get(c)
    if i.is_a?(Integer)
      commands.push([i,PBSpecies.getName(i)])
    end
  end
  commands.sort! {|a,b| a[1]<=>b[1]}
  if defaultItemID>0
    commands.each_with_index {|item,index|
       itemDefault=index if item[0]==defaultItemID
    }
  end
  realcommands=[]
  for command in commands
    realcommands.push(_ISPRINTF("{1:s}",command[1]))
  end
  ret=pbCommands2(cmdwin,realcommands,-1,itemDefault,true) 
  cmdwin.dispose
  return ret>=0 ? commands[ret][0] : 0
end

# Displays a sorted list of moves, and returns the ID of the move selected or
# 0 if the selection was canceled.  defaultMoveID, if specified, indicates the
# ID of the move initially shown on the list.
def pbChooseMoveList(defaultMoveID=0)
  cmdwin=pbListWindow([],200)
  commands=[]
  moveDefault=0
  for i in 1..PBMoves.maxValue
    name=PBMoves.getName(i)
    commands.push([i,name]) if name!=nil && name!=""
  end
  commands.sort! {|a,b| a[1]<=>b[1]}
  if defaultMoveID>0
    commands.each_with_index {|item,index|
       moveDefault=index if item[0]==defaultMoveID
    }
  end
  realcommands=[]
  for command in commands
    realcommands.push(_ISPRINTF("{1:s}",command[1]))
  end
  ret=pbCommands2(cmdwin,realcommands,-1,moveDefault,true) 
  cmdwin.dispose
  return ret>=0 ? commands[ret][0] : 0
end

def pbChooseTypeList(defaultMoveID=0,movetype=false)
  cmdwin=pbListWindow([],200)
  commands=[]
  moveDefault=0
  for i in 0..PBTypes.maxValue
    if !PBTypes.isPseudoType?(i)
      commands.push([i,PBTypes.getName(i)])
    end
  end
  commands.sort! {|a,b| a[1]<=>b[1]}
  if defaultMoveID>0
    commands.each_with_index {|item,index|
       moveDefault=index if item[0]==defaultMoveID
    }
  end
  realcommands=[]
  for command in commands
    realcommands.push(_ISPRINTF("{1:s}",command[1]))
  end
  loop do
    ret=pbCommands2(cmdwin,realcommands,-1,moveDefault,true) 
    retval=ret>=0 ? commands[ret][0] : 0
    cmdwin.dispose
    return retval
  end
end

# Displays a sorted list of items, and returns the ID of the item selected or
# 0 if the selection was canceled.  defaultItemID, if specified, indicates the
# ID of the item initially shown on the list.
def pbChooseItemList(defaultItemID=0)
  cmdwin=pbListWindow([],200)
  commands=[]
  moveDefault=0
  for c in PBItems.constants
    i=PBItems.const_get(c)
    if i.is_a?(Integer)
      commands.push([i,PBItems.getName(i)])
    end
  end
  commands.sort! {|a,b| a[1]<=>b[1]}
  if defaultItemID>0
    commands.each_with_index {|item,index|
       moveDefault=index if item[0]==defaultItemID
    }
  end
  realcommands=[]
  for command in commands
    realcommands.push(_ISPRINTF("{1:s}",command[1]))
  end
  ret=pbCommands2(cmdwin,realcommands,-1,moveDefault,true) 
  cmdwin.dispose
  return ret>=0 ? commands[ret][0] : 0
end

# Displays a sorted list of abilities, and returns the ID of the ability selected
# or 0 if the selection was canceled.  defaultItemID, if specified, indicates the
# ID of the ability initially shown on the list.
def pbChooseAbilityList(defaultAbilityID=0)
  cmdwin=pbListWindow([],200)
  commands=[]
  abilityDefault=0
  for c in PBAbilities.constants
    i=PBAbilities.const_get(c)
    if i.is_a?(Integer)
      commands.push([i,PBAbilities.getName(i)])
    end
  end
  commands.sort! {|a,b| a[1]<=>b[1]}
  if defaultAbilityID>0
    commands.each_with_index {|item,index|
       abilityDefault=index if item[0]==defaultAbilityID
    }
  end
  realcommands=[]
  for command in commands
    realcommands.push(sprintf("#{command[1]}"))
  end
  ret=pbCommands2(cmdwin,realcommands,-1,abilityDefault,true) 
  cmdwin.dispose
  return ret>=0 ? commands[ret][0] : 0
end

def pbCommands2(cmdwindow,commands,cmdIfCancel,defaultindex=-1,noresize=false)
  cmdwindow.z=99999
  cmdwindow.visible=true
  cmdwindow.commands=commands
  if !noresize
    cmdwindow.width=256
  else
    cmdwindow.height=Graphics.height
  end
  cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
  cmdwindow.x=0
  cmdwindow.y=0
  cmdwindow.active=true
  cmdwindow.index=defaultindex if defaultindex>=0
  ret=0
  command=0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    if Input.trigger?(Input::B)
      if cmdIfCancel>0
        command=cmdIfCancel-1
        break
      elsif cmdIfCancel<0
        command=cmdIfCancel
        break
      end
    end
    if Input.trigger?(Input::C) #|| (cmdwindow.doubleclick? rescue false)
      command=cmdwindow.index
      break
    end
  end
  ret=command
  cmdwindow.active=false
  return ret
end

def pbCommands3(cmdwindow,commands,cmdIfCancel,defaultindex=-1,noresize=false)
  cmdwindow.z=99999
  cmdwindow.visible=true
  cmdwindow.commands=commands
  if !noresize
    cmdwindow.width=256
  else
    cmdwindow.height=Graphics.height
  end
  cmdwindow.height=Graphics.height if cmdwindow.height>Graphics.height
  cmdwindow.x=0
  cmdwindow.y=0
  cmdwindow.active=true
  cmdwindow.index=defaultindex if defaultindex>=0
  ret=[]
  command=0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    if Input.trigger?(Input::X)
      command=[5,cmdwindow.index]
      break
    end
    if Input.press?(Input::A)
      if Input.repeat?(Input::UP)
        command=[1,cmdwindow.index]
        break
      elsif Input.repeat?(Input::DOWN)
        command=[2,cmdwindow.index]
        break
      elsif Input.press?(Input::LEFT)
        command=[3,cmdwindow.index]
        break
      elsif Input.press?(Input::RIGHT)
        command=[4,cmdwindow.index]
        break
      end
    end
    if Input.trigger?(Input::B)
      if cmdIfCancel>0
        command=[0,cmdIfCancel-1]
        break
      elsif cmdIfCancel<0
        command=[0,cmdIfCancel]
        break
      end
    end
    if Input.trigger?(Input::C) #|| (cmdwindow.doubleclick? rescue false)
      command=[0,cmdwindow.index]
      break
    end
  end
  ret=command
  cmdwindow.active=false
  return ret
end



################################################################################
# Core lister script
################################################################################
def pbListScreen(title,lister)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  list=pbListWindow([],256)
  list.viewport=viewport
  list.z=2
  title=Window_UnformattedTextPokemon.new(title)
  title.x=256
  title.y=0
  title.width=Graphics.width-256
  title.height=64
  title.viewport=viewport
  title.z=2
  lister.setViewport(viewport)
  selectedmap=-1
  commands=lister.commands
  selindex=lister.startIndex
  if commands.length==0
    value=lister.value(-1)
    lister.dispose
    return value
  end
  list.commands=commands
  list.index=selindex
  loop do
    Graphics.update
    Input.update
    list.update
    if list.index!=selectedmap
      lister.refresh(list.index)
      selectedmap=list.index
    end
    if Input.trigger?(Input::C) || (list.doubleclick? rescue false)
      break
    elsif Input.trigger?(Input::B)
      selectedmap=-1
      break
    end
  end
  value=lister.value(selectedmap)
  lister.dispose
  title.dispose
  list.dispose
  Input.update
  return value
end

def pbListScreenBlock(title,lister)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  list=pbListWindow([],256)
  list.viewport=viewport
  list.z=2
  title=Window_UnformattedTextPokemon.new(title)
  title.x=256
  title.y=0
  title.width=Graphics.width-256
  title.height=64
  title.viewport=viewport
  title.z=2
  lister.setViewport(viewport)
  selectedmap=-1
  commands=lister.commands
  selindex=lister.startIndex
  if commands.length==0
    value=lister.value(-1)
    lister.dispose
    return value
  end
  list.commands=commands
  list.index=selindex
  loop do
    Graphics.update
    Input.update
    list.update
    if list.index!=selectedmap
      lister.refresh(list.index)
      selectedmap=list.index
    end
    if Input.trigger?(Input::A)
      yield(Input::A, lister.value(selectedmap))
      list.commands=lister.commands
      if list.index==list.commands.length
        list.index=list.commands.length
      end
      lister.refresh(list.index)
    elsif Input.trigger?(Input::C) || (list.doubleclick? rescue false)
      yield(Input::C, lister.value(selectedmap))
      list.commands=lister.commands
      if list.index==list.commands.length
        list.index=list.commands.length
      end
      lister.refresh(list.index)
    elsif Input.trigger?(Input::B)
      break
    end
  end
  lister.dispose
  title.dispose
  list.dispose
  Input.update
end



################################################################################
# General listers
################################################################################
class GraphicsLister
  def initialize(folder,selection)
    @sprite=IconSprite.new(0,0)
    @sprite.bitmap=nil
    @sprite.z=2
    @folder=folder
    @selection=selection
    @commands=[]
    @index=0
  end

  def setViewport(viewport)
    @sprite.viewport=viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    Dir.chdir(@folder){
       Dir.glob("*.png"){|f| @commands.push(f) }
       Dir.glob("*.PNG"){|f| @commands.push(f) }
       Dir.glob("*.gif"){|f| @commands.push(f) }
       Dir.glob("*.GIF"){|f| @commands.push(f) }
       Dir.glob("*.bmp"){|f| @commands.push(f) }
       Dir.glob("*.BMP"){|f| @commands.push(f) }
       Dir.glob("*.jpg"){|f| @commands.push(f) }
       Dir.glob("*.JPG"){|f| @commands.push(f) }
       Dir.glob("*.jpeg"){|f| @commands.push(f) }
       Dir.glob("*.JPEG"){|f| @commands.push(f) }
    }
    @commands.sort!
    @commands.length.times do |i|
      @index=i if @commands[i]==@selection
    end
    if @commands.length==0
      Kernel.pbMessage(_INTL("There are no files."))
    end
    return @commands
  end

  def value(index)
    return (index<0) ? "" : @commands[index]
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
  end

  def refresh(index)
    return if index<0
    @sprite.setBitmap(@folder+@commands[index])
    ww=@sprite.bitmap.width
    wh=@sprite.bitmap.height
    sx=(Graphics.width-256).to_f()/ww
    sy=(Graphics.height-64).to_f()/wh
    if sx<1.0 || sy<1.0
      if sx>sy
        ww=sy*ww
        wh=(Graphics.height-64).to_f()
      else
        wh=sx*wh
        ww=(Graphics.width-256).to_f()   
      end
    end
    @sprite.zoom_x=ww*1.0/@sprite.bitmap.width
    @sprite.zoom_y=wh*1.0/@sprite.bitmap.height
    @sprite.x=(Graphics.width-((Graphics.width-256)/2))-(ww/2)
    @sprite.y=(Graphics.height-((Graphics.height-64)/2))-(wh/2)
  end
end



class MusicFileLister
  def getPlayingBGM
    $game_system ? $game_system.getPlayingBGM : nil
  end

  def pbPlayBGM(bgm)
    if bgm
      pbBGMPlay(bgm)
    else
      pbBGMStop()
    end
  end

  def initialize(bgm,setting)
    @oldbgm=getPlayingBGM
    @commands=[]
    @bgm=bgm
    @setting=setting
    @index=0
  end

  def startIndex
    return @index
  end

  def setViewport(viewport)
  end

  def commands
    folder=(@bgm) ? "Audio/BGM/" : "Audio/ME/"
    @commands.clear
    Dir.chdir(folder){
       Dir.glob("*.mp3"){|f| @commands.push(f) }
       Dir.glob("*.MP3"){|f| @commands.push(f) }
       Dir.glob("*.mid"){|f| @commands.push(f) }
       Dir.glob("*.MID"){|f| @commands.push(f) }
    }
    @commands.sort!
    @commands.length.times do |i|
      @index=i if @commands[i]==@setting
    end
    if @commands.length==0
      Kernel.pbMessage(_INTL("There are no files."))
    end
    return @commands
  end

  def value(index)
    return (index<0) ? "" : @commands[index]
  end

  def dispose
    pbPlayBGM(@oldbgm)
  end

  def refresh(index)
    return if index<0
    if @bgm
      pbPlayBGM(@commands[index])
    else
      pbPlayBGM("../../Audio/ME/"+@commands[index])
    end
  end
end



class MapLister
  def initialize(selmap,addGlobal=false)
    @sprite=SpriteWrapper.new
    @sprite.bitmap=nil
    @sprite.z=2
    @commands=[]
    @maps=pbMapTree
    @addGlobalOffset=(addGlobal) ? 1 : 0
    @index=0
    for i in 0...@maps.length
      @index=i+@addGlobalOffset if @maps[i][0]==selmap
    end
  end

  def setViewport(viewport)
    @sprite.viewport=viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    if @addGlobalOffset==1
      @commands.push(_INTL("[GLOBAL]"))
    end
    for i in 0...@maps.length
      @commands.push(sprintf("%s%03d %s",("  "*@maps[i][2]),@maps[i][0],@maps[i][1]))
    end
    return @commands
  end

  def value(index)
    if @addGlobalOffset==1
      return 0 if index==0
    end
    return (index<0) ? -1 : @maps[index-@addGlobalOffset][0]
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
  end

  def refresh(index)
    @sprite.bitmap.dispose if @sprite.bitmap
    return if index<0
    return if index==0 && @addGlobalOffset==1
    @sprite.bitmap=createMinimap(@maps[index-@addGlobalOffset][0])
    @sprite.x=(Graphics.width-((Graphics.width-256)/2))-(@sprite.bitmap.width/2)
    @sprite.y=(Graphics.height-((Graphics.height-64)/2))-(@sprite.bitmap.height/2)
  end
end



class ItemLister
  def initialize(selection,includeNew=false)
    @sprite=IconSprite.new(0,0)
    @sprite.bitmap=nil
    @sprite.z=2
    @selection=selection
    @commands=[]
    @ids=[]
    @includeNew=includeNew
    @trainers=nil
    @index=0
  end

  def setViewport(viewport)
    @sprite.viewport=viewport
  end

  def startIndex
    return @index
  end

  def commands   # Sorted alphabetically
    @commands.clear
    @ids.clear
    @itemdata=$ItemData
    cmds=[]
    for i in 1..PBItems.maxValue
      begin
        name=@itemdata[i][ITEMNAME]
      rescue NoMethodError
        next
      end
      if name && name!="" && @itemdata[i][ITEMPOCKET]!=0
        cmds.push([i,name])
      end
    end
    cmds.sort! {|a,b| a[1]<=>b[1]}
    if @includeNew
      @commands.push(_ISPRINTF("[NEW ITEM]"))
      @ids.push(-1)
    end
    for i in cmds
      @commands.push(_ISPRINTF("{1:03d}: {2:s}",i[0],i[1]))
      @ids.push(i[0])
    end
    @index=@selection
    @index=@commands.length-1 if @index>=@commands.length
    @index=0 if @index<0
    return @commands
  end

=begin
  def commands   # Sorted by item index number
    @commands.clear
    @ids.clear
    @itemdata=readItemList("Data/items.dat")
    if @includeNew
      @commands.push(_ISPRINTF("[NEW ITEM]"))
      @ids.push(-1)
    end
    for i in 1..PBItems.maxValue
      # Number: Item name
      name=@itemdata[i][1]
      if name && name!="" && @itemdata[i][2]!=0
        @commands.push(_ISPRINTF("{1:3d}: {2:s}",i,name))
        @ids.push(i)
      end
    end
    @index=@selection
    @index=@commands.length-1 if @index>=@commands.length
    @index=0 if @index<0
    return @commands
  end
=end

  def value(index)
    return nil if (index<0)
    return -1 if index==0 && @includeNew
    realIndex=index
    return @ids[realIndex]
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
  end

  def refresh(index)
    @sprite.bitmap.dispose if @sprite.bitmap
    return if index<0
    begin
      filename=pbItemIconFile(@ids[index])
      @sprite.setBitmap(filename,0)
    rescue
      @sprite.setBitmap(nil)
    end
    ww=@sprite.bitmap.width
    wh=@sprite.bitmap.height
    sx=(Graphics.width-256).to_f()/ww
    sy=(Graphics.height-64).to_f()/wh
    if sx<1.0 || sy<1.0
      if sx>sy
        ww=sy*ww
        wh=(Graphics.height-64).to_f()
      else
        wh=sx*wh
        ww=(Graphics.width-256).to_f()   
      end
    end
    @sprite.zoom_x=ww*1.0/@sprite.bitmap.width
    @sprite.zoom_y=wh*1.0/@sprite.bitmap.height
    @sprite.x=(Graphics.width-((Graphics.width-256)/2))-(ww/2)
    @sprite.y=(Graphics.height-((Graphics.height-64)/2))-(wh/2)
  end
end



class TrainerTypeLister
  def initialize(selection,includeNew)
    @sprite=IconSprite.new(0,0)
    @sprite.bitmap=nil
    @sprite.z=2
    @selection=selection
    @commands=[]
    @ids=[]
    @includeNew=includeNew
    @trainers=nil
    @index=0
  end

  def setViewport(viewport)
    @sprite.viewport=viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    @ids.clear
    @trainers=load_data("Data/trainertypes.dat")
    if @includeNew
      @commands.push(_ISPRINTF("[NEW TRAINER TYPE]"))
      @ids.push(-1)
    end
    @trainers.length.times do |i|
      next if !@trainers[i]
      @commands.push(_ISPRINTF("{1:3d}: {2:s}",i,@trainers[i][2]))
      @ids.push(@trainers[i][0])
    end
    @commands.length.times do |i|
      @index=i if @ids[i]==@selection
    end
    return @commands
  end

  def value(index)
    return nil if (index<0)
    return [-1] if @ids[index]==-1
    return @trainers[@ids[index]]
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
  end

  def refresh(index)
    @sprite.bitmap.dispose if @sprite.bitmap
    return if index<0
    begin
      @sprite.setBitmap(pbTrainerSpriteFile(@ids[index]),0)
    rescue
      @sprite.setBitmap(nil)
    end
    ww=@sprite.bitmap.width
    wh=@sprite.bitmap.height
    sx=(Graphics.width-256).to_f()/ww
    sy=(Graphics.height-64).to_f()/wh
    if sx<1.0 || sy<1.0
      if sx>sy
        ww=sy*ww
        wh=(Graphics.height-64).to_f()
      else
        wh=sx*wh
        ww=(Graphics.width-256).to_f()   
      end
    end
    @sprite.zoom_x=ww*1.0/@sprite.bitmap.width
    @sprite.zoom_y=wh*1.0/@sprite.bitmap.height
    @sprite.x=(Graphics.width-((Graphics.width-256)/2))-(ww/2)
    @sprite.y=(Graphics.height-((Graphics.height-64)/2))-(wh/2)
  end
end



################################################################################
# General properties
################################################################################
class UIntProperty
  def initialize(maxdigits)
    @maxdigits=maxdigits
  end

  def set(settingname,oldsetting)
    params=ChooseNumberParams.new
    params.setMaxDigits(@maxdigits)
    params.setDefaultValue(oldsetting||0)
    return Kernel.pbMessageChooseNumber(
       _INTL("Set the value for {1}.",settingname),params)
  end

  def format(value)
    return value.inspect
  end

  def defaultValue
    return 0
  end
end



class LimitProperty
  def initialize(maxvalue)
    @maxvalue=maxvalue
  end

  def set(settingname,oldsetting)
    oldsetting=1 if !oldsetting
    params=ChooseNumberParams.new
    params.setRange(0,@maxvalue)
    params.setDefaultValue(oldsetting)
    ret=Kernel.pbMessageChooseNumber(
       _INTL("Set the value for {1}.",settingname),params)
    return ret
  end

  def format(value)
    return value.inspect
  end

  def defaultValue
    return 0
  end
end



class NonzeroLimitProperty
  def initialize(maxvalue)
    @maxvalue=maxvalue
  end

  def set(settingname,oldsetting)
    oldsetting=1 if !oldsetting
    params=ChooseNumberParams.new
    params.setRange(1,@maxvalue)
    params.setDefaultValue(oldsetting)
    ret=Kernel.pbMessageChooseNumber(
       _INTL("Set the value for {1}.",settingname),params)
    return ret
  end

  def format(value)
    return value.inspect
  end

  def defaultValue
    return 0
  end
end



class ReadOnlyProperty
  def self.set(settingname,oldsetting)
    Kernel.pbMessage(_INTL("This property cannot be edited."))
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



module UndefinedProperty
  def self.set(settingname,oldsetting)
    Kernel.pbMessage(_INTL("This property can't be edited here at this time."))
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



class EnumProperty
  def initialize(values)
    @values=values
  end

  def set(settingname,oldsetting)
    commands=[]
    for value in @values
      commands.push(value)   
    end
    cmd=Kernel.pbMessage(_INTL("Choose a value for {1}.",settingname),commands,-1)
    return oldsetting if cmd<0
    return cmd
  end

  def defaultValue
    return 0
  end

  def format(value)
    return value ? @values[value] : value.inspect
  end 
end



module BooleanProperty
  def self.set(settingname,oldsetting)
    return Kernel.pbConfirmMessage(_INTL("Enable the setting {1}?",settingname)) ? true : false
  end

  def self.format(value)
    return value.inspect
  end
end



module StringProperty
  def self.set(settingname,oldsetting)
    message=Kernel.pbMessageFreeText(_INTL("Set the value for {1}.",settingname),
       oldsetting ? oldsetting : "",false,256,Graphics.width)
  end

  def self.format(value)
    return value
  end
end



class LimitStringProperty
  def initialize(limit)
    @limit=limit
  end

  def set(settingname,oldsetting)
    message=Kernel.pbMessageFreeText(_INTL("Set the value for {1}.",settingname),
       oldsetting ? oldsetting : "",false,@limit)
  end

  def format(value)
    return value
  end
end



module BGMProperty
  def self.set(settingname,oldsetting)
    chosenmap=pbListScreen(settingname,MusicFileLister.new(true,oldsetting))
    return chosenmap && chosenmap!="" ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module MEProperty
  def self.set(settingname,oldsetting)
    chosenmap=pbListScreen(settingname,MusicFileLister.new(false,oldsetting))
    return chosenmap && chosenmap!="" ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module WindowskinProperty
  def self.set(settingname,oldsetting)
    chosenmap=pbListScreen(settingname,
       GraphicsLister.new("Graphics/Windowskins/",oldsetting))
    return chosenmap && chosenmap!="" ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module TrainerTypeProperty
  def self.set(settingname,oldsetting)
    chosenmap=pbListScreen(settingname,
       TrainerTypeLister.new(oldsetting,false))
    return chosenmap ? chosenmap[0] : oldsetting
  end

  def self.format(value)
    return !value ? value.inspect : PBTrainers.getName(value)
  end
end



module SpeciesProperty
  def self.set(settingname,oldsetting)
    ret=pbChooseSpeciesList(oldsetting ? oldsetting : 1)
    return (ret<=0) ? (oldsetting ? oldsetting : 0) : ret
  end

  def self.format(value)
    return value ? PBSpecies.getName(value) : "-"
  end

  def self.defaultValue
    return 0
  end
end



module TypeProperty
  def self.set(settingname,oldsetting)
    ret=pbChooseTypeList(oldsetting ? oldsetting : 0)
    return (ret<0) ? (oldsetting ? oldsetting : 0) : ret
  end

  def self.format(value)
    return value ? PBTypes.getName(value) : "-"
  end

  def self.defaultValue
    return 0
  end
end



module MoveProperty
  def self.set(settingname,oldsetting)
    ret=pbChooseMoveList(oldsetting ? oldsetting : 1)
    return (ret<=0) ? (oldsetting ? oldsetting : 0) : ret
  end

  def self.format(value)
    return value ? PBMoves.getName(value) : "-"
  end

  def self.defaultValue
    return 0
  end
end



module ItemProperty
  def self.set(settingname,oldsetting)
    ret=pbChooseItemList(oldsetting ? oldsetting : 1)
    return (ret<=0) ? (oldsetting ? oldsetting : 0) : ret
  end

  def self.format(value)
    return value ? PBItems.getName(value) : "-"
  end

  def self.defaultValue
    return 0
  end
end



module NatureProperty
  def self.set(settingname,oldsetting)
    commands=[]
    (PBNatures.getCount).times do |i|
      commands.push(PBNatures.getName(i))
    end
    ret=Kernel.pbShowCommands(nil,commands,-1)
    return ret
  end

  def self.format(value)
    return "" if !value
    return (value>=0) ? getConstantName(PBNatures,value) : ""
  end

  def self.defaultValue
    return 0
  end
end



################################################################################
# Core property editor script
################################################################################
def pbPropertyList(title,data,properties,saveprompt=false)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  list=pbListWindow([],Graphics.width*5/10)
  list.viewport=viewport
  list.z=2
  title=Window_UnformattedTextPokemon.new(title)
  title.x=list.width
  title.y=0
  title.width=Graphics.width*5/10
  title.height=64
  title.viewport=viewport
  title.z=2
  desc=Window_UnformattedTextPokemon.new("")
  desc.x=list.width
  desc.y=title.height
  desc.width=Graphics.width*5/10
  desc.height=Graphics.height-title.height
  desc.viewport=viewport
  desc.z=2
  selectedmap=-1
  index=0
  retval=nil
  commands=[]
  for i in 0...properties.length
    propobj=properties[i][1]
    commands.push(sprintf("%s=%s",properties[i][0],propobj.format(data[i])))
  end
  list.commands=commands
  list.index=0
  begin
    loop do
      Graphics.update
      Input.update
      list.update
      desc.update
      if list.index!=selectedmap
        desc.text=properties[list.index][2]
        selectedmap=list.index
      end
      if Input.trigger?(Input::A)
        propobj=properties[selectedmap][1]
        if propobj!=ReadOnlyProperty && !propobj.is_a?(ReadOnlyProperty) &&
           Kernel.pbConfirmMessage(_INTL("Reset the setting {1}?",properties[selectedmap][0]))
          if propobj.respond_to?("defaultValue")
            data[selectedmap]=propobj.defaultValue
          else
            data[selectedmap]=nil
          end
        end
        commands.clear
        for i in 0...properties.length
          propobj=properties[i][1]
          commands.push(sprintf("%s=%s",properties[i][0],propobj.format(data[i])))
        end
        list.commands=commands
      elsif Input.trigger?(Input::C) || (list.doubleclick? rescue false)
        propobj=properties[selectedmap][1]
        oldsetting=data[selectedmap]
        newsetting=propobj.set(properties[selectedmap][0],oldsetting)
        data[selectedmap]=newsetting
        commands.clear
        for i in 0...properties.length
          propobj=properties[i][1]
          commands.push(sprintf("%s=%s",properties[i][0],propobj.format(data[i])))
        end
        list.commands=commands
        break
      elsif Input.trigger?(Input::B)
        selectedmap=-1
        break
      end
    end
    if selectedmap==-1 && saveprompt
      cmd=Kernel.pbMessage(_INTL("Save changes?"),
         [_INTL("Yes"),_INTL("No"),_INTL("Cancel")],3)
      if cmd==2
        selectedmap=list.index
      else
        retval=(cmd==0)
      end
    end
  end while selectedmap!=-1
  title.dispose
  list.dispose
  desc.dispose
  Input.update
  return retval
end



################################################################################
# Encounters editor
################################################################################
def pbEncounterEditorTypes(enc,enccmd)
  commands=[]
  indexes=[]
  haveblank=false
  if enc
    commands.push(_INTL("Density: {1},{2},{3}",
       enc[0][EncounterTypes::Land],
       enc[0][EncounterTypes::Cave],
       enc[0][EncounterTypes::Water]))
    indexes.push(-2)
    for i in 0...EncounterTypes::EnctypeChances.length
      if enc[1][i]
        commands.push(EncounterTypes::Names[i])
        indexes.push(i)
      else
        haveblank=true
      end
    end
  else
    commands.push(_INTL("Density: Not Defined Yet"))
    indexes.push(-2)
    haveblank=true
  end
  if haveblank
    commands.push(_INTL("[New Encounter Type]"))
    indexes.push(-3)
  end
  enccmd.z=99999
  enccmd.visible=true
  enccmd.commands=commands
  enccmd.height=Graphics.height if enccmd.height>Graphics.height
  enccmd.x=0
  enccmd.y=0
  enccmd.active=true
  enccmd.index=0
  ret=0
  command=0
  loop do
    Graphics.update
    Input.update
    enccmd.update
    if Input.trigger?(Input::A) && indexes[enccmd.index]>=0
      if Kernel.pbConfirmMessage(_INTL("Delete the encounter type {1}?",commands[enccmd.index]))
        enc[1][indexes[enccmd.index]]=nil
        commands.delete_at(enccmd.index)
        indexes.delete_at(enccmd.index)
        enccmd.commands=commands
        if enccmd.index>=enccmd.commands.length
          enccmd.index=enccmd.commands.length
        end
      end
    end
    if Input.trigger?(Input::B)
      command=-1
      break
    end
    if Input.trigger?(Input::C) || (enccmd.doubleclick? rescue false)
      command=enccmd.index
      break
    end
  end
  ret=command
  enccmd.active=false
  return ret<0 ? -1 : indexes[ret]
end

def pbNewEncounterType(enc)
  cmdwin=pbListWindow([])
  commands=[]
  indexes=[]
  for i in 0...EncounterTypes::EnctypeChances.length
    dogen=false
    if !enc[1][i]
      if i==0
        dogen=true unless enc[1][EncounterTypes::Cave]
      elsif i==1
        dogen=true unless enc[1][EncounterTypes::Land] || 
                          enc[1][EncounterTypes::LandMorning] || 
                          enc[1][EncounterTypes::LandDay] || 
                          enc[1][EncounterTypes::LandNight] || 
                          enc[1][EncounterTypes::BugContest]
      else
        dogen=true
      end
    end
    if dogen
      commands.push(EncounterTypes::Names[i])
      indexes.push(i)
    end
  end
  ret=pbCommands2(cmdwin,commands,-1)
  ret=(ret<0) ? -1 : indexes[ret]
  if ret>=0
    chances=EncounterTypes::EnctypeChances[ret]
    enc[1][ret]=[]
    for i in 0...chances.length
      enc[1][ret].push([1,5,5])
    end
  end
  cmdwin.dispose
  return ret
end

def pbEditEncounterType(enc,etype)
  commands=[]
  cmdwin=pbListWindow([])
  chances=EncounterTypes::EnctypeChances[etype]
  chancetotal=0
  chances.each {|a| chancetotal+=a}
  enctype=enc[1][etype]
  for i in 0...chances.length
    enctype[i]=[1,5,5] if !enctype[i]
  end
  ret=0
  loop do
    commands.clear
    for i in 0...enctype.length
      ch=chances[i]
      ch=sprintf("%.1f",100.0*chances[i]/chancetotal) if chancetotal!=100
      if enctype[i][1]==enctype[i][2]
        commands.push(_INTL("{1}% {2} (Lv.{3})",
           ch,PBSpecies.getName(enctype[i][0]),
           enctype[i][1]
        ))
      else
        commands.push(_INTL("{1}% {2} (Lv.{3}-Lv.{4})",
           ch,PBSpecies.getName(enctype[i][0]),
           enctype[i][1],
           enctype[i][2]
        ))
      end
    end
    ret=pbCommands2(cmdwin,commands,-1,ret)
    break if ret<0
    species=pbChooseSpecies(enctype[ret][0])
    next if species<=0
    enctype[ret][0]=species if species>0
    minlevel=0
    maxlevel=0
    params=ChooseNumberParams.new
    params.setRange(1,PBExperience::MAXLEVEL)
    params.setDefaultValue(enctype[ret][1])
    minlevel=Kernel.pbMessageChooseNumber(_INTL("Set the minimum level."),params)
    params=ChooseNumberParams.new
    params.setRange(minlevel,PBExperience::MAXLEVEL)
    params.setDefaultValue(minlevel)
    maxlevel=Kernel.pbMessageChooseNumber(_INTL("Set the maximum level."),params)
    enctype[ret][1]=minlevel  
    enctype[ret][2]=maxlevel
  end
  cmdwin.dispose
end

def pbEncounterEditorDensity(enc)
  params=ChooseNumberParams.new
  params.setRange(0,100)
  params.setDefaultValue(enc[0][EncounterTypes::Land])
  enc[0][EncounterTypes::Land]=Kernel.pbMessageChooseNumber(
     _INTL("Set the density of Pokémon on land (default {1}).",
        EncounterTypes::EnctypeDensities[EncounterTypes::Land]),params)
  params=ChooseNumberParams.new
  params.setRange(0,100)
  params.setDefaultValue(enc[0][EncounterTypes::Cave])
  enc[0][EncounterTypes::Cave]=Kernel.pbMessageChooseNumber(
     _INTL("Set the density of Pokémon in caves (default {1}).",
        EncounterTypes::EnctypeDensities[EncounterTypes::Cave]),params)
  params=ChooseNumberParams.new
  params.setRange(0,100)
  params.setDefaultValue(enc[0][EncounterTypes::Water])
  enc[0][EncounterTypes::Water]=Kernel.pbMessageChooseNumber(
      _INTL("Set the density of Pokémon on water (default {1}).",
         EncounterTypes::EnctypeDensities[EncounterTypes::Water]),params)
  for i in 0...EncounterTypes::EnctypeCompileDens.length
    t=EncounterTypes::EnctypeCompileDens[i]
    next if !t || t==0
    enc[0][i]=enc[0][EncounterTypes::Land] if t==1
    enc[0][i]=enc[0][EncounterTypes::Cave] if t==2
    enc[0][i]=enc[0][EncounterTypes::Water] if t==3
  end
end

def pbEncounterEditorMap(encdata,map)
  enccmd=pbListWindow([])
  # This window displays the help text
  enchelp=Window_UnformattedTextPokemon.new("")
  enchelp.z=99999
  enchelp.x=256
  enchelp.y=0
  enchelp.width=224
  enchelp.height=96
  mapinfos=load_data("Data/MapInfos.rxdata")
  mapname=mapinfos[map].name
  lastchoice=0
  loop do
    enc=encdata[map]
    enchelp.text=_INTL("{1}",mapname)
    choice=pbEncounterEditorTypes(enc,enccmd)
    if !enc
      enc=[EncounterTypes::EnctypeDensities.clone,[]]
      encdata[map]=enc
    end
    if choice==-2
      pbEncounterEditorDensity(enc)
    elsif choice==-1
      break
    elsif choice==-3
      ret=pbNewEncounterType(enc)
      if ret>=0
        enchelp.text=_INTL("{1}\r\n{2}",mapname,EncounterTypes::Names[ret])
        pbEditEncounterType(enc,ret)
      end
    else
      enchelp.text=_INTL("{1}\r\n{2}",mapname,EncounterTypes::Names[choice])
      pbEditEncounterType(enc,choice)
    end
  end
  if encdata[map][1].length==0
    encdata[map]=nil
  end
  enccmd.dispose
  enchelp.dispose
  Input.update
end



################################################################################
# Trainer type editor
################################################################################
def pbTrainerTypeEditorNew(trconst)
  data=load_data("Data/trainertypes.dat")
  # Get the first unused ID after all existing t-types for the new t-type to use.
  maxid=-1
  for rec in data
    next if !rec
    maxid=[maxid,rec[0]].max
  end
  trainertype=maxid+1
  trname=Kernel.pbMessageFreeText(_INTL("Please enter the trainer type's name."),
     trconst ? trconst.gsub(/_+/," ") : "",false,256)
  if trname=="" && !trconst
    return -1
  else
    # Create a default name if there is none.
    if !trconst
      trconst=trname.gsub(/[^A-Za-z0-9_]/,"")
      trconst=trconst.sub(/^([a-z])/){ $1.upcase }
      if trconst.length==0
        trconst=sprintf("T_%03d",trainertype)
      elsif !trconst[0,1][/[A-Z]/]
        trconst="T_"+trconst
      end
    end
    trname=trconst if trname==""
    # Create an internal name based on the trainer type's name.
    cname=trname.gsub(/é/,"e")
    cname=cname.gsub(/[^A-Za-z0-9_]/,"")
    cname=cname.upcase
    if hasConst?(PBTrainers,cname)
      suffix=1
      100.times do
        tname=sprintf("%s_%d",cname,suffix)
        if !hasConst?(PBTrainers,tname)
          cname=tname
          break
        end
        suffix+=1
      end
    end
    if hasConst?(PBTrainers,cname)
      Kernel.pbMessage(_INTL("Failed to create the trainer type.  Choose a different name."))
      return -1
    end
    record=[]
    record[0]=trainertype
    record[1]=cname
    record[2]=trname
    record[7]=Kernel.pbMessage(_INTL("Is the Trainer male, female, or mixed gender?"),[
       _INTL("Male"),_INTL("Female"),_INTL("Mixed")],0)
    params=ChooseNumberParams.new
    params.setRange(0,255)
    params.setDefaultValue(30)
    record[3]=Kernel.pbMessageChooseNumber(
       _INTL("Set the money per level won for defeating the Trainer."),params)
    record[8]=record[3]
    PBTrainers.const_set(cname,record[0])
    data[record[0]]=record
    save_data(data,"Data/trainertypes.dat")
    pbConvertTrainerData
    Kernel.pbMessage(_INTL("The Trainer type was created (ID: {1}).",record[0]))
    Kernel.pbMessage(
       _ISPRINTF("Put the Trainer's graphic (trainer{1:03d}.png or trainer{2:s}.png) in Graphics/Characters, or it will be blank.",
       record[0],getConstantName(PBTrainers,record[0])))
    return record[0]
  end
end

def pbTrainerTypeEditorSave(trainertype,ttdata)
  record=[]
  record[0]=trainertype
  for i in 0..ttdata.length
    record.push(ttdata[i])
  end
  setConstantName(PBTrainers,trainertype,ttdata[0])
  data=load_data("Data/trainertypes.dat")
  data[record[0]]=record
  data=save_data(data,"Data/trainertypes.dat")
  pbConvertTrainerData
end

def pbTrainerTypeEditor
  selection=0
  trainerTypes=[
    [_INTL("Internal Name"),ReadOnlyProperty,
        _INTL("Internal name that appears in constructs like PBTrainers::XXX.")],
    [_INTL("Trainer Name"),StringProperty,
        _INTL("Name of the trainer type as displayed by the game.")],
    [_INTL("Money Per Level"),LimitProperty.new(255),
        _INTL("Player earns this amount times the highest level among the trainer's Pokémon.")],
    [_INTL("Battle BGM"),BGMProperty,
        _INTL("BGM played in battles against trainers of this type.")],
    [_INTL("Battle End ME"),MEProperty,
        _INTL("ME played when player wins battles against trainers of this type.")],
    [_INTL("Battle Intro ME"),MEProperty,
        _INTL("ME played before battles against trainers of this type.")],
    [_INTL("Gender"),EnumProperty.new([_INTL("Male"),_INTL("Female"),_INTL("Mixed gender")]),
        _INTL("Gender of this Trainer type.")],
    [_INTL("Skill"),LimitProperty.new(255),
        _INTL("Skill level of this Trainer type.")],
  ]
  pbListScreenBlock(_INTL("Trainer Types"),TrainerTypeLister.new(selection,true)){|button,trtype|
     if trtype
       if button==Input::A
         if trtype[0]>=0
           if Kernel.pbConfirmMessageSerious("Delete this trainer type?")
             data=load_data("Data/trainertypes.dat")
             removeConstantValue(PBTrainers,trtype[0])
             data[trtype[0]]=nil
             save_data(data,"Data/trainertypes.dat")
             pbConvertTrainerData
             Kernel.pbMessage(_INTL("The Trainer type was deleted."))
           end
         end
       elsif button==Input::C
         selection=trtype[0]
         if selection<0
           newid=pbTrainerTypeEditorNew(nil)
           if newid>=0
             selection=newid
           end
         else
           data=[]
           for i in 1..trtype.length
             data.push(trtype[i])
           end
           # trtype[2] contains trainer's name to display as title
           save=pbPropertyList(trtype[2],data,trainerTypes,true)
           if save
             pbTrainerTypeEditorSave(selection,data)
           end
         end
       end
     end
  }
end



################################################################################
# Trainer editor
################################################################################
class TrainerBattleLister
  def initialize(selection,includeNew)
    @sprite=IconSprite.new
    @sprite.bitmap=nil
    @sprite.z=2
    @selection=selection
    @commands=[]
    @ids=[]
    @includeNew=includeNew
    @trainers=nil
    @index=0
  end

  def setViewport(viewport)
    @sprite.viewport=viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    @ids.clear
    @trainers=load_data("Data/trainers.dat")
    if @includeNew
      @commands.push(_ISPRINTF("[NEW TRAINER BATTLE]"))
      @ids.push(-1)
    end
    @trainers.length.times do |i|
      next if !@trainers[i]
      # Index: TrainerType TrainerName (version)
      @commands.push(_ISPRINTF("{1:3d}: {2:s} {3:s} ({4:s})",i,
         PBTrainers.getName(@trainers[i][0]),@trainers[i][1],@trainers[i][4])) # Trainer's name must not be localized
      # Trainer type ID
      @ids.push(@trainers[i][0])
    end
    @index=@selection
    @index=@commands.length-1 if @index>=@commands.length
    @index=0 if @index<0
    return @commands
  end

  def value(index)
    return nil if (index<0)
    return [-1,nil] if index==0 && @includeNew
    realIndex=(@includeNew) ? index-1 : index
    return [realIndex,@trainers[realIndex]]
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @sprite.dispose
  end

  def refresh(index)
    @sprite.bitmap.dispose if @sprite.bitmap
    return if index<0
    begin
      @sprite.setBitmap(pbTrainerSpriteFile(@ids[index]),0)
    rescue
      @sprite.setBitmap(nil)
    end
    ww=@sprite.bitmap.width
    wh=@sprite.bitmap.height
    sx=(Graphics.width-256).to_f()/ww
    sy=(Graphics.height-64).to_f()/wh
    if sx<1.0 || sy<1.0
      if sx>sy
        ww=sy*ww
        wh=(Graphics.height-64).to_f()
      else
        wh=sx*wh
        ww=(Graphics.width-256).to_f()   
      end
    end
    @sprite.zoom_x=ww*1.0/@sprite.bitmap.width
    @sprite.zoom_y=wh*1.0/@sprite.bitmap.height
    @sprite.x=(Graphics.width-((Graphics.width-256)/2))-(ww/2)
    @sprite.y=(Graphics.height-((Graphics.height-64)/2))-(wh/2)
  end
end



module TrainerBattleProperty
  def self.set(settingname,oldsetting)
    return oldsetting if !oldsetting
    properties=[
       [_INTL("Trainer Type"),TrainerTypeProperty,
           _INTL("Name of the trainer type for this Trainer.")],
       [_INTL("Trainer Name"),StringProperty,
           _INTL("Name of the Trainer.")],
       [_INTL("Battle ID"),LimitProperty.new(255),
           _INTL("ID used to distinguish Trainers with the same name and trainer type.")],
       [_INTL("Pokémon 1"),TrainerPokemonProperty,
           _INTL("First Pokémon.")],
       [_INTL("Pokémon 2"),TrainerPokemonProperty,
           _INTL("Second Pokémon.")],
       [_INTL("Pokémon 3"),TrainerPokemonProperty,
           _INTL("Third Pokémon.")],
       [_INTL("Pokémon 4"),TrainerPokemonProperty,
           _INTL("Fourth Pokémon.")],
       [_INTL("Pokémon 5"),TrainerPokemonProperty,
           _INTL("Fifth Pokémon.")],
       [_INTL("Pokémon 6"),TrainerPokemonProperty,
           _INTL("Sixth Pokémon.")],
       [_INTL("Item 1"),ItemProperty,
           _INTL("Item used by the trainer during battle.")],
       [_INTL("Item 2"),ItemProperty,
           _INTL("Item used by the trainer during battle.")],
       [_INTL("Item 3"),ItemProperty,
           _INTL("Item used by the trainer during battle.")],
       [_INTL("Item 4"),ItemProperty,
           _INTL("Item used by the trainer during battle.")],
       [_INTL("Item 5"),ItemProperty,
           _INTL("Item used by the trainer during battle.")],
       [_INTL("Item 6"),ItemProperty,
           _INTL("Item used by the trainer during battle.")],
       [_INTL("Item 7"),ItemProperty,
           _INTL("Item used by the trainer during battle.")],
       [_INTL("Item 8"),ItemProperty,
           _INTL("Item used by the trainer during battle.")]
    ]
    if !pbPropertyList(settingname,oldsetting,properties,true)
      oldsetting=nil
    else
      oldsetting=nil if !oldsetting[0] || oldsetting[0]==0
    end
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



def pbTrainerBattleEditor
  selection=0
  trainers=load_data("Data/trainers.dat")
  trainertypes=load_data("Data/trainertypes.dat")
  modified=false
  for trainer in trainers
    trtype=trainer[0]
    if !trainertypes || !trainertypes[trtype]
      trainer[0]=0
      modified=true
    end
  end
  if modified
    save_data(trainers,"Data/trainers.dat")
    pbConvertTrainerData
  end
  pbListScreenBlock(_INTL("Trainer Battles"),TrainerBattleLister.new(selection,true)){|button,trtype|
     if trtype
       index=trtype[0]
       trainerdata=trtype[1]
       if button==Input::A
         if index>=0
           if Kernel.pbConfirmMessageSerious("Delete this trainer battle?")
             data=load_data("Data/trainers.dat")
             data.delete_at(index)
             save_data(data,"Data/trainers.dat")
             pbConvertTrainerData
             Kernel.pbMessage(_INTL("The Trainer battle was deleted."))
           end
         end
       elsif button==Input::C
         selection=index
         if selection<0
           ret=Kernel.pbMessage(_INTL("First, define the type of trainer."),[
              _INTL("Use existing type"),_INTL("Use new type"),_INTL("Cancel")
              ],3)
           trainertype=-1
           trainername=""
           if ret==0
             trainertype=pbListScreen(_INTL("Trainer Type"),TrainerTypeLister.new(0,false))
             next if !trainertype
             trainertype=trainertype[0]
             next if trainertype<0
           elsif ret==1
             trainertype=pbTrainerTypeEditorNew(nil)
             next if trainertype<0
           else
             next 
           end
           trainername=Kernel.pbMessageFreeText(_INTL("Now enter the trainer's name."),"",false,32)
           next  if trainername==""
           trainerparty=pbGetFreeTrainerParty(trainertype,trainername)
           if trainerparty<0
             Kernel.pbMessage(_INTL("There is no room to create a trainer of that type and name."))
             next 
           end
           ###############
           pbNewTrainer(trainertype,trainername,trainerparty)
         else
           data=[
              trainerdata[0],      # Trainer type
              trainerdata[1],      # Trainer name
              trainerdata[4],      # ID
              trainerdata[3][0],   # Pokémon 1
              trainerdata[3][1],   # Pokémon 2
              trainerdata[3][2],   # Pokémon 3
              trainerdata[3][3],   # Pokémon 4
              trainerdata[3][4],   # Pokémon 5
              trainerdata[3][5],   # Pokémon 6
              trainerdata[2][0],   # Item 1
              trainerdata[2][1],   # Item 2
              trainerdata[2][2],   # Item 3
              trainerdata[2][3],   # Item 4
              trainerdata[2][4],   # Item 5
              trainerdata[2][5],   # Item 6
              trainerdata[2][6],   # Item 7
              trainerdata[2][7]    # Item 8
           ]
           save=false
           while true
             data=TrainerBattleProperty.set(trainerdata[1],data)
             if data
               trainerdata=[
                  data[0],
                  data[1],
                  [data[9],data[10],data[11],data[12],data[13],data[14],data[15],data[16]].find_all {|i| i && i!=0 },   # Item list
                  [data[3],data[4],data[5],data[6],data[7],data[8]].find_all {|i| i && i[TPSPECIES]!=0 },   # Pokémon list
                  data[2]
               ]
               if trainerdata[3].length==0
                 Kernel.pbMessage(_INTL("Can't save.  The Pokémon list is empty."))
               elsif !trainerdata[1] || trainerdata[1].length==0
                 Kernel.pbMessage(_INTL("Can't save.  No name was entered."))
               else
                 save=true
                 break
               end
             else
               break
             end
           end
           if save
             data=load_data("Data/trainers.dat")
             data[index]=trainerdata
             save_data(data,"Data/trainers.dat")
             pbConvertTrainerData
           end
         end
       end
     end
  }
end



################################################################################
# Trainer Pokémon editor
################################################################################
module TrainerPokemonProperty
  def self.set(settingname,oldsetting)
    oldsetting=TPDEFAULTS.clone if !oldsetting
    properties=[
       [_INTL("Species"),SpeciesProperty,
           _INTL("Species of the Pokémon.")],
       [_INTL("Level"),NonzeroLimitProperty.new(PBExperience::MAXLEVEL),
           _INTL("Level of the Pokémon.")],
       [_INTL("Held item"),ItemProperty,
           _INTL("Item held by the Pokémon.")],
       [_INTL("Move 1"),MoveProperty2.new(oldsetting),
           _INTL("First move.  Leave all moves blank (use Z key) to give it a wild move set.")],
       [_INTL("Move 2"),MoveProperty2.new(oldsetting),
           _INTL("Second move.  Leave all moves blank (use Z key) to give it a wild move set.")],
       [_INTL("Move 3"),MoveProperty2.new(oldsetting),
           _INTL("Third move.  Leave all moves blank (use Z key) to give it a wild move set.")],
       [_INTL("Move 4"),MoveProperty2.new(oldsetting),
           _INTL("Fourth move.  Leave all moves blank (use Z key) to give it a wild move set.")],
       [_INTL("Ability"),LimitProperty.new(5),
           _INTL("Ability flag. 0=first ability, 1=second ability, 2-5=hidden ability.")],
       [_INTL("Gender"),LimitProperty.new(1),
           _INTL("Gender flag. 0=male, 1=female.")],
       [_INTL("Form"),LimitProperty.new(100),
           _INTL("Form of the Pokémon.")],
       [_INTL("Shiny"),BooleanProperty,
           _INTL("If set to true, the Pokémon is a different-colored Pokémon.")],
       [_INTL("Nature"),NatureProperty,
           _INTL("Nature of the Pokémon.")],
       [_INTL("IVs"),LimitProperty.new(31),
           _INTL("Individual values of each of the Pokémon's stats.")],
       [_INTL("Happiness"),LimitProperty.new(255),
           _INTL("Happiness of the Pokémon.")],
       [_INTL("Nickname"),StringProperty,
           _INTL("Name of the Pokémon.")],
       [_INTL("Shadow"),BooleanProperty,
           _INTL("If set to true, the Pokémon is a Shadow Pokémon.")],
       [_INTL("Ball"),BallProperty.new(oldsetting),
           _INTL("Number of the Poké Ball the Pokémon is kept in.")]
    ]
    pbPropertyList(settingname,oldsetting,properties,false)
    for i in 0...TPDEFAULTS.length
      oldsetting[i]=TPDEFAULTS[i] if !oldsetting[i]
    end
    moves=[]
    for i in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
      moves.push(oldsetting[i]) if oldsetting[i]!=0
    end
    oldsetting[TPMOVE1]=moves[0] ? moves[0] : TPDEFAULTS[TPMOVE1]
    oldsetting[TPMOVE2]=moves[1] ? moves[1] : TPDEFAULTS[TPMOVE2]
    oldsetting[TPMOVE3]=moves[2] ? moves[2] : TPDEFAULTS[TPMOVE3]
    oldsetting[TPMOVE4]=moves[3] ? moves[3] : TPDEFAULTS[TPMOVE4]
    oldsetting=nil if !oldsetting[TPSPECIES] || oldsetting[TPSPECIES]==0
    return oldsetting
  end

  def self.format(value)
    return (!value || !value[TPSPECIES] || value[TPSPECIES]==0) ? "-" : PBSpecies.getName(value[TPSPECIES])
  end
end



class BallProperty
  def initialize(pokemondata)
    @pokemondata=pokemondata
  end

  def set(settingname,oldsetting)
    ret=pbChooseBallList(oldsetting ? oldsetting : -1)
    return (ret<=0) ? (oldsetting ? oldsetting : 0) : ret
  end

  def format(value)
    return value ? PBItems.getName(pbBallTypeToBall(value)) : "-"
  end

  def defaultValue
    return 0
  end
end



def pbChooseBallList(defaultMoveID=-1)
  cmdwin=pbListWindow([],200)
  commands=[]
  moveDefault=0
  for key in $BallTypes.keys
    item=getID(PBItems,$BallTypes[key])
    commands.push([key,item,PBItems.getName(item)]) if item && item>0
  end
  commands.sort! {|a,b| a[2]<=>b[2]}
  if defaultMoveID>=0
    for i in 0...commands.length
      moveDefault=i if defaultMoveID==commands[i][0]
    end
  end
  realcommands=[]
  for i in commands
    realcommands.push(i[2])
  end
  ret=pbCommands2(cmdwin,realcommands,-1,moveDefault,true) 
  cmdwin.dispose
  return ret>=0 ? commands[ret][0] : defaultMoveID
end



class MoveProperty2
  def initialize(pokemondata)
    @pokemondata=pokemondata
  end

  def set(settingname,oldsetting)
    ret=pbChooseMoveListForSpecies(@pokemondata[0],oldsetting ? oldsetting : 1)
    return (ret<=0) ? (oldsetting ? oldsetting : 0) : ret
  end

  def format(value)
    return value ? PBMoves.getName(value) : "-"
  end

  def defaultValue
    return 0
  end
end



def pbGetLegalMoves(species)
  moves=[]
  return moves if !species || species<=0
  pbRgssOpen("Data/attacksRS.dat","rb") {|atkdata|
     offset=atkdata.getOffset(species-1)
     length=atkdata.getLength(species-1)>>1
     atkdata.pos=offset
     for k in 0..length-1
       level=atkdata.fgetw
       move=atkdata.fgetw
       moves.push(move)
     end
  }
  itemData=readItemList("Data/items.dat")
  tmdat=load_data("Data/tm.dat")
  for i in 0...itemData.length
    next if !itemData[i]
    atk=itemData[i][8]
    next if !atk || atk==0
    next if !tmdat[atk]
    if tmdat[atk].any? {|item| item==species }
      moves.push(atk)
    end
  end
  babyspecies=pbGetBabySpecies(species)
  pbRgssOpen("Data/eggEmerald.dat","rb"){|f|
     f.pos=(babyspecies-1)*8
     offset=f.fgetdw
     length=f.fgetdw
     if length>0
       f.pos=offset
       i=0; loop do break unless i<length
         atk=f.fgetw
         moves.push(atk)
         i+=1
       end
     end
  }
  moves|=[]
  return moves
end

def pbChooseMoveListForSpecies(species,defaultMoveID=0)
  cmdwin=pbListWindow([],200)
  commands=[]
  moveDefault=0
  legalMoves=pbGetLegalMoves(species)
  for move in legalMoves
    commands.push([move,PBMoves.getName(move)])
  end
  commands.sort! {|a,b| a[1]<=>b[1]}
  if defaultMoveID>0
    commands.each_with_index {|item,index|
       if moveDefault==0
         moveDefault=index if index[0]==defaultMoveID
       end
    }
  end
  commands2=[]
  for i in 1..PBMoves.maxValue
    if PBMoves.getName(i)!=nil && PBMoves.getName(i)!=""
      commands2.push([i,PBMoves.getName(i)])
    end
  end
  commands2.sort! {|a,b| a[1]<=>b[1]}
  if defaultMoveID>0
    commands2.each_with_index {|item,index|
       if moveDefault==0
         moveDefault=index if index[0]==defaultMoveID
       end
    }
  end
  commands.concat(commands2)
  realcommands=[]
  for command in commands
    realcommands.push(_ISPRINTF("{2:s}",command[0],command[1]))
  end
  ret=pbCommands2(cmdwin,realcommands,-1,moveDefault,true) 
  cmdwin.dispose
  return ret>=0 ? commands[ret][0] : 0
end



################################################################################
# Metadata editor
################################################################################
module CharacterProperty
  def self.set(settingname,oldsetting)
    chosenmap=pbListScreen(settingname,
       GraphicsLister.new("Graphics/Characters/",oldsetting))
    return chosenmap && chosenmap!="" ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module PlayerProperty
  def self.set(settingname,oldsetting)
    oldsetting=[0,"xxx","xxx","xxx","xxx","xxx","xxx","xxx"] if !oldsetting
    properties=[
       [_INTL("Trainer Type"),TrainerTypeProperty,
           _INTL("Trainer type of this player.")],
       [_INTL("Sprite"),CharacterProperty,
           _INTL("Walking character sprite.")],
       [_INTL("Bike"),CharacterProperty,
           _INTL("Cycling character sprite.")],
       [_INTL("Surfing"),CharacterProperty,
           _INTL("Surfing character sprite.")],
       [_INTL("Running"),CharacterProperty,
           _INTL("Running character sprite.")],
       [_INTL("Diving"),CharacterProperty,
           _INTL("Diving character sprite.")],
       [_INTL("Fishing"),CharacterProperty,
           _INTL("Fishing character sprite.")],
       [_INTL("Surf-Fishing"),CharacterProperty,
           _INTL("Fishing while surfing character sprite.")]
    ]
    pbPropertyList(settingname,oldsetting,properties,false)
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



module MapSizeProperty
  def self.set(settingname,oldsetting)
    oldsetting=[0,""] if !oldsetting
    properties=[
       [_INTL("Width"),NonzeroLimitProperty.new(30),
           _INTL("The width of this map in Region Map squares.")],
       [_INTL("Valid Squares"),StringProperty,
           _INTL("A series of 1s and 0s marking which squares are part of this map (1=part, 0=not part).")],
    ]
    pbPropertyList(settingname,oldsetting,properties,false)
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



module MapCoordsProperty
  def self.set(settingname,oldsetting)
    chosenmap=pbListScreen(settingname,MapLister.new(oldsetting ? oldsetting[0] : 0))
    if chosenmap>=0
      mappoint=chooseMapPoint(chosenmap)
      if mappoint
        return [chosenmap,mappoint[0],mappoint[1]]
      else
        return oldsetting
      end
    else
      return oldsetting
    end
  end

  def self.format(value)
    return value.inspect
  end
end



module MapCoordsFacingProperty
  def self.set(settingname,oldsetting)
    chosenmap=pbListScreen(settingname,MapLister.new(oldsetting ? oldsetting[0] : 0))
    if chosenmap>=0
      mappoint=chooseMapPoint(chosenmap)
      if mappoint
        facing=Kernel.pbMessage(_INTL("Choose the direction to face in."),
           [_INTL("Down"),_INTL("Left"),_INTL("Right"),_INTL("Up")],-1)
        if facing<0
          return oldsetting
        else
          return [chosenmap,mappoint[0],mappoint[1],[2,4,6,8][facing]]
        end
      else
        return oldsetting
      end
    else
      return oldsetting
    end
  end

  def self.format(value)
    return value.inspect
  end
end



module RegionMapCoordsProperty
  def self.set(settingname,oldsetting)
    regions=getMapNameList
    selregion=-1
    if regions.length==0
      Kernel.pbMessage(_INTL("No region maps are defined."))
      return oldsetting
    elsif regions.length==1
      selregion=regions[0][0]
    else
      cmds=[]
      for region in regions
        cmds.push(region[1])
      end
      selcmd=Kernel.pbMessage(_INTL("Choose a region map."),cmds,-1)
      if selcmd>=0
        selregion=regions[selcmd][0]
      else
        return oldsetting
      end
    end
    mappoint=chooseMapPoint(selregion,true)
    if mappoint
      return [selregion,mappoint[0],mappoint[1]]
    else
      return oldsetting
    end
  end

  def self.format(value)
    return value.inspect
  end
end



module WeatherEffectProperty
  def self.set(settingname,oldsetting)
    cmd=Kernel.pbMessage(_INTL("Choose a weather effect."),[
       _INTL("No weather"),
       _INTL("Rain"),
       _INTL("Storm"),
       _INTL("Snow"),
       _INTL("Sandstorm"),
       _INTL("Sunny"),
       _INTL("HeavyRain"),
       _INTL("Blizzard")
    ],1)
    if cmd==0
      return nil
    else
      params=ChooseNumberParams.new
      params.setRange(0,100)
      params.setDefaultValue(oldsetting ? oldsetting[1] : 100)
      number=Kernel.pbMessageChooseNumber(_INTL("Set the probability of the weather."),params)
      return [cmd,number]
    end
  end

  def self.format(value)
    return value.inspect
  end
end



module MapProperty
  def self.set(settingname,oldsetting)
    chosenmap=pbListScreen(settingname,MapLister.new(oldsetting ? oldsetting : 0))
    return chosenmap>0 ? chosenmap : oldsetting
  end

  def self.format(value)
    return value.inspect
  end

  def self.defaultValue
    return 0
  end
end



def pbMetadataScreen(defaultMapId=nil)
  metadata=nil
  mapinfos=pbLoadRxData("Data/MapInfos")
  metadata=load_data("Data/metadata.dat")
  map=defaultMapId ? defaultMapId : 0
  loop do
    map=pbListScreen(_INTL("SET METADATA"),MapLister.new(map,true))
    break if map<0
    mapname=(map==0) ? _INTL("Global Metadata") : mapinfos[map].name
    data=[]
    properties=(map==0) ? MapScreenScene::GLOBALMETADATA :
                          MapScreenScene::LOCALMAPS
    for i in 0...properties.length
      data.push(metadata[map] ? metadata[map][i+1] : nil)
    end
    pbPropertyList(mapname,data,properties)
    for i in 0...properties.length
      if !metadata[map]
        metadata[map]=[]
      end
      metadata[map][i+1]=data[i]
    end
  end
  pbSerializeMetadata(metadata,mapinfos) if metadata
end



################################################################################
# Map drawing
################################################################################
class MapSprite
  def initialize(map,viewport=nil)
    @sprite=Sprite.new(viewport)
    @sprite.bitmap=createMinimap(map)
    @sprite.x=(Graphics.width/2)-(@sprite.bitmap.width/2)
    @sprite.y=(Graphics.height/2)-(@sprite.bitmap.height/2)
  end

  def dispose
    @sprite.bitmap.dispose
    @sprite.dispose
  end

  def z=(value)
    @sprite.z=value
  end

  def getXY
    return nil if !Input.triggerex?(0x01)
    mouse=Mouse::getMousePos(true)
    if mouse[0]<@sprite.x||mouse[0]>=@sprite.x+@sprite.bitmap.width
      return nil
    end
    if mouse[1]<@sprite.y||mouse[1]>=@sprite.y+@sprite.bitmap.height
      return nil
    end
    x=mouse[0]-@sprite.x
    y=mouse[1]-@sprite.y
    return [x/4,y/4]
  end
end



class SelectionSprite < Sprite
  def initialize(viewport=nil)
    @sprite=Sprite.new(viewport)
    @sprite.bitmap=nil  
    @sprite.z=2
    @othersprite=nil
  end

  def disposed?
    return @sprite.disposed?
  end

  def dispose
    @sprite.bitmap.dispose if @sprite.bitmap
    @othersprite=nil
    @sprite.dispose
  end

  def othersprite=(value)
    @othersprite=value
    if @othersprite && !@othersprite.disposed? &&
       @othersprite.bitmap && !@othersprite.bitmap.disposed?
      @sprite.bitmap=pbDoEnsureBitmap(
         @sprite.bitmap,@othersprite.bitmap.width,@othersprite.bitmap.height)
      red=Color.new(255,0,0)
      @sprite.bitmap.clear
      @sprite.bitmap.fill_rect(0,0,@othersprite.bitmap.width,2,red)
      @sprite.bitmap.fill_rect(0,@othersprite.bitmap.height-2,
         @othersprite.bitmap.width,2,red)
      @sprite.bitmap.fill_rect(0,0,2,@othersprite.bitmap.height,red)
      @sprite.bitmap.fill_rect(@othersprite.bitmap.width-2,0,2,
         @othersprite.bitmap.height,red)
    end
  end

  def update
    if @othersprite && !@othersprite.disposed?
      @sprite.visible=@othersprite.visible
      @sprite.x=@othersprite.x
      @sprite.y=@othersprite.y
    else
      @sprite.visible=false
    end
  end
end



class RegionMapSprite
  def initialize(map,viewport=nil)
    @sprite=Sprite.new(viewport)
    @sprite.bitmap=createRegionMap(map)
    @sprite.x=(Graphics.width/2)-(@sprite.bitmap.width/2)
    @sprite.y=(Graphics.height/2)-(@sprite.bitmap.height/2)
  end

  def dispose
    @sprite.bitmap.dispose
    @sprite.dispose
  end

  def z=(value)
    @sprite.z=value
  end

  def getXY
    return nil if !Input.triggerex?(0x01)
    mouse=Mouse::getMousePos(true)
    if mouse[0]<@sprite.x||mouse[0]>=@sprite.x+@sprite.bitmap.width
      return nil
    end
    if mouse[1]<@sprite.y||mouse[1]>=@sprite.y+@sprite.bitmap.height
      return nil
    end
    x=mouse[0]-@sprite.x
    y=mouse[1]-@sprite.y
    return [x/8,y/8]
  end
end



def createRegionMap(map)
  pbRgssOpen("Data/townmap.dat","rb"){|f|
     @mapdata=Marshal.load(f)
  }
  @map=@mapdata[map]
  bitmap=AnimatedBitmap.new("Graphics/Pictures/#{@map[1]}").deanimate
  retbitmap=BitmapWrapper.new(bitmap.width/2,bitmap.height/2)
  retbitmap.stretch_blt(
     Rect.new(0,0,bitmap.width/2,bitmap.height/2),
     bitmap,
     Rect.new(0,0,bitmap.width,bitmap.height)
  )
  bitmap.dispose
  return retbitmap
end

def getMapNameList
  pbRgssOpen("Data/townmap.dat","rb"){|f|
     @mapdata=Marshal.load(f)
  }
  ret=[]
  for i in 0...@mapdata.length
    next if !@mapdata[i]
    ret.push(
       [i,pbGetMessage(MessageTypes::RegionNames,i)]
    )
  end
  return ret
end

def createMinimap2(mapid)
  map=load_data(sprintf("Data/Map%03d.rxdata",mapid)) rescue nil
  return BitmapWrapper.new(32,32) if !map
  bitmap=BitmapWrapper.new(map.width*4,map.height*4)
  black=Color.new(0,0,0)
  bigmap=(map.width>40 && map.height>40)
  tilesets=load_data("Data/Tilesets.rxdata")
  tileset=tilesets[map.tileset_id]
  return bitmap if !tileset
  helper=TileDrawingHelper.fromTileset(tileset)
  for y in 0...map.height
    for x in 0...map.width
      if bigmap
        next if (x>8 && x<=map.width-8 && y>8 && y<=map.height-8)
      end
      for z in 0..2
        id=map.data[x,y,z]
        next if id==0 || !id
        helper.bltSmallTile(bitmap,x*4,y*4,4,4,id)
      end
    end
  end
  bitmap.fill_rect(0,0,bitmap.width,1,black)
  bitmap.fill_rect(0,bitmap.height-1,bitmap.width,1,black)
  bitmap.fill_rect(0,0,1,bitmap.height,black)
  bitmap.fill_rect(bitmap.width-1,0,1,bitmap.height,black)
  return bitmap
end

def createMinimap(mapid)
  map=load_data(sprintf("Data/Map%03d.rxdata",mapid)) rescue nil
  return BitmapWrapper.new(32,32) if !map
  bitmap=BitmapWrapper.new(map.width*4,map.height*4)
  black=Color.new(0,0,0)
  tilesets=load_data("Data/Tilesets.rxdata")
  tileset=tilesets[map.tileset_id]
  return bitmap if !tileset
  helper=TileDrawingHelper.fromTileset(tileset)
  for y in 0...map.height
    for x in 0...map.width
      for z in 0..2
        id=map.data[x,y,z]
        id=0 if !id
        helper.bltSmallTile(bitmap,x*4,y*4,4,4,id)
      end
    end
  end
  bitmap.fill_rect(0,0,bitmap.width,1,black)
  bitmap.fill_rect(0,bitmap.height-1,bitmap.width,1,black)
  bitmap.fill_rect(0,0,1,bitmap.height,black)
  bitmap.fill_rect(bitmap.width-1,0,1,bitmap.height,black)
  return bitmap
end

def chooseMapPoint(map,rgnmap=false)
  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z=99999
  title=Window_UnformattedTextPokemon.new(_INTL("Click a point on the map."))
  title.x=0
  title.y=Graphics.height-64
  title.width=Graphics.width
  title.height=64
  title.viewport=viewport
  title.z=2
  if rgnmap
    sprite=RegionMapSprite.new(map,viewport)
  else
    sprite=MapSprite.new(map,viewport)
  end
  sprite.z=2
  ret=nil
  loop do
    Graphics.update
    Input.update
    xy=sprite.getXY
    if xy
      ret=xy
      break
    end
    if Input.trigger?(Input::B)
      ret=nil
      break
    end
  end
  sprite.dispose
  title.dispose
  return ret
end



################################################################################
# Visual Editor (map connections)
################################################################################
class MapScreenScene
LOCALMAPS=[
   ["Outdoor",BooleanProperty,
        _INTL("If true, this map is an outdoor map and will be tinted according to time of day.")],
   ["ShowArea",BooleanProperty,
       _INTL("If true, the game will display the map's name upon entry.")],
   ["Bicycle",BooleanProperty,
       _INTL("If true, the bicycle can be used on this map.")],
   ["BicycleAlways",BooleanProperty,
       _INTL("If true, the bicycle will be mounted automatically on this map and cannot be dismounted.")],
   ["HealingSpot",MapCoordsProperty,
        _INTL("Map ID of this Pokemon Center's town, and X and Y coordinates of its entrance within that town.")],
   ["Weather",WeatherEffectProperty,
       _INTL("Weather conditions in effect for this map.")],
   ["MapPosition",RegionMapCoordsProperty,
       _INTL("Identifies the point on the regional map for this map.")],
   ["DiveMap",MapProperty,
       _INTL("Specifies the underwater layer of this map.  Use only if this map has deep water.")],
   ["DarkMap",BooleanProperty,
       _INTL("If true, this map is dark and a circle of light appears around the player. Flash can be used to expand the circle.")],
   ["SafariMap",BooleanProperty,
       _INTL("If true, this map is part of the Safari Zone (both indoor and outdoor).  Not to be used in the reception desk.")],
   ["SnapEdges",BooleanProperty,
       _INTL("If true, when the player goes near this map's edge, the game doesn't center the player as usual.")],
   ["Dungeon",BooleanProperty,
       _INTL("If true, this map has a randomly generated layout. See the wiki for more information.")],
   ["BattleBack",StringProperty,
       _INTL("PNG files named 'battlebgXXX', 'enemybaseXXX', 'playerbaseXXX' in Battlebacks folder, where XXX is this property's value.")],
   ["WildBattleBGM",BGMProperty,
       _INTL("Default BGM for wild Pokémon battles on this map.")],
   ["TrainerBattleBGM",BGMProperty,
       _INTL("Default BGM for trainer battles on this map.")],
   ["WildVictoryME",MEProperty,
       _INTL("Default ME played after winning a wild Pokémon battle on this map.")],
   ["TrainerVictoryME",MEProperty,
       _INTL("Default ME played after winning a Trainer battle on this map.")],
   ["MapSize",MapSizeProperty,
       _INTL("The width of the map in Town Map squares, and a string indicating which squares are part of this map.")],
]
GLOBALMETADATA=[
   ["Home",MapCoordsFacingProperty,
       _INTL("Map ID and X and Y coordinates of where the player goes if no Pokémon Center was entered after a loss.")],
   ["WildBattleBGM",BGMProperty,
       _INTL("Default BGM for wild Pokémon battles.")],
   ["TrainerBattleBGM",BGMProperty,
       _INTL("Default BGM for Trainer battles.")],
   ["WildVictoryME",MEProperty,
       _INTL("Default ME played after winning a wild Pokémon battle.")],
   ["TrainerVictoryME",MEProperty,
       _INTL("Default ME played after winning a Trainer battle.")],
   ["SurfBGM",BGMProperty,
       _INTL("BGM played while surfing.")],
   ["BicycleBGM",BGMProperty,
       _INTL("BGM played while on a bicycle.")],
   ["PlayerA",PlayerProperty, _INTL("Specifies player A.")],
   ["PlayerB",PlayerProperty, _INTL("Specifies player B.")],
   ["PlayerC",PlayerProperty, _INTL("Specifies player C.")],
   ["PlayerD",PlayerProperty, _INTL("Specifies player D.")],
   ["PlayerE",PlayerProperty, _INTL("Specifies player E.")],
   ["PlayerF",PlayerProperty, _INTL("Specifies player F.")],
   ["PlayerG",PlayerProperty, _INTL("Specifies player G.")],
    ["PlayerH",PlayerProperty, _INTL("Specifies player H.")],
   ["PlayerI",PlayerProperty, _INTL("Specifies player I.")],
   ["PlayerJ",PlayerProperty, _INTL("Specifies player J.")],
   ["PlayerK",PlayerProperty, _INTL("Specifies player K.")],
   ["PlayerL",PlayerProperty, _INTL("Specifies player L.")],
   ["PlayerM",PlayerProperty, _INTL("Specifies player M.")],
   ["PlayerN",PlayerProperty, _INTL("Specifies player N.")],
   ["PlayerO",PlayerProperty, _INTL("Specifies player O.")],
       ["PlayerP",PlayerProperty, _INTL("Specifies player P.")],
       ["PlayerQ",PlayerProperty, _INTL("Specifies player Q.")],
       ["PlayerR",PlayerProperty, _INTL("Specifies player R.")],
       ["PlayerS",PlayerProperty, _INTL("Specifies player S.")],
       ["PlayerT",PlayerProperty, _INTL("Specifies player T.")],
       ["PlayerU",PlayerProperty, _INTL("Specifies player U.")],
       ["PlayerV",PlayerProperty, _INTL("Specifies player V.")],
       ["PlayerW",PlayerProperty, _INTL("Specifies player W.")],
       ["PlayerX",PlayerProperty, _INTL("Specifies player X.")],
]

  def getMapSprite(id)
    if !@mapsprites[id]
      @mapsprites[id]=Sprite.new(@viewport)
      @mapsprites[id].z=0
      @mapsprites[id].bitmap=nil
    end
    if !@mapsprites[id].bitmap || @mapsprites[id].bitmap.disposed?
      @mapsprites[id].bitmap=createMinimap(id)
    end
    return @mapsprites[id]
  end

  def close
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@mapsprites)
    @viewport.dispose
  end

  def setMapSpritePos(id,x,y)
    sprite=getMapSprite(id)
    sprite.x=x
    sprite.y=y
    sprite.visible=true
  end

  def putNeighbors(id,sprites)
    conns=@mapconns
    mapsprite=getMapSprite(id)
    dispx=mapsprite.x
    dispy=mapsprite.y
    for conn in conns
      if conn[0]==id
        b=sprites.any? {|i| i==conn[3] }
        if !b
          x=(conn[1]-conn[4])*4+dispx
          y=(conn[2]-conn[5])*4+dispy
          setMapSpritePos(conn[3],x,y)
          sprites.push(conn[3])
          putNeighbors(conn[3],sprites)
        end
      elsif conn[3]==id
        b=sprites.any? {|i| i==conn[0] }
        if !b
          x=(conn[4]-conn[1])*4+dispx
          y=(conn[5]-conn[2])*4+dispy
          setMapSpritePos(conn[0],x,y)
          sprites.push(conn[3])
          putNeighbors(conn[0],sprites)
        end
      end
    end
  end

  def hasConnections?(conns,id)
    for conn in conns
      return true if conn[0]==id || conn[3]==id
    end
    return false
  end

  def connectionsSymmetric?(conn1,conn2)
    if conn1[0]==conn2[0]
      # Equality
      return false if conn1[1]!=conn2[1]
      return false if conn1[2]!=conn2[2]
      return false if conn1[3]!=conn2[3]
      return false if conn1[4]!=conn2[4]
      return false if conn1[5]!=conn2[5]
      return true
    elsif conn1[0]==conn2[3]
      # Symmetry
      return false if conn1[1]!=-conn2[1]
      return false if conn1[2]!=-conn2[2]
      return false if conn1[3]!=conn2[0]
      return false if conn1[4]!=-conn2[4]
      return false if conn1[5]!=-conn2[5]
      return true
    end
    return false
  end

  def removeOldConnections(ret,mapid)
    for i in 0...ret.length
      ret[i]=nil if ret[i][0]==mapid || ret[i][3]==mapid
    end
    ret.compact!
  end

# Returns the maps within _keys_ that are directly connected to this map, _map_.
  def getDirectConnections(keys,map)
    thissprite=getMapSprite(map)
    thisdims=MapFactoryHelper.getMapDims(map)
    ret=[]
    for i in keys
      next if i==map
      othersprite=getMapSprite(i)
      otherdims=MapFactoryHelper.getMapDims(i)
      x1=(thissprite.x-othersprite.x)/4
      y1=(thissprite.y-othersprite.y)/4
      if (x1==otherdims[0] || x1==-thisdims[0] || 
          y1==otherdims[1] || y1==-thisdims[1])
        ret.push(i)
      end  
    end
    # If no direct connections, add an indirect connection
    if ret.length==0
      key=(map==keys[0]) ? keys[1] : keys[0]
      ret.push(key)
    end
    return ret
  end

  def generateConnectionData
    ret=[]
    # Create a clone of current map connection
    for conn in @mapconns
      ret.push(conn.clone)
    end
    keys=@mapsprites.keys
    return ret if keys.length<2
    # Remove all connections containing any sprites on the canvas from the array
    for i in keys
      removeOldConnections(ret,i)
    end
    # Rebuild connections
    for i in keys
      refs=getDirectConnections(keys,i)
      for refmap in refs
        othersprite=getMapSprite(i)
        refsprite=getMapSprite(refmap)
        c1=(refsprite.x-othersprite.x)/4
        c2=(refsprite.y-othersprite.y)/4
        conn=[refmap,0,0,i,c1,c2]
        j=0;while j<ret.length && !connectionsSymmetric?(ret[j],conn)
          j+=1
        end
        if j==ret.length
          ret.push(conn)
        end
      end
    end
    return ret
  end

  def serializeConnectionData
    conndata=generateConnectionData()
    pbSerializeConnectionData(conndata,@mapinfos)
    @mapconns=conndata
  end

  def putSprite(id)
    addSprite(id)
    putNeighbors(id,[])
  end

  def addSprite(id)
    mapsprite=getMapSprite(id)
    x=(Graphics.width-mapsprite.bitmap.width)/2
    y=(Graphics.height-mapsprite.bitmap.height)/2
    mapsprite.x=x.to_i&~3
    mapsprite.y=y.to_i&~3
  end

  def saveMapSpritePos
    @mapspritepos.clear
    for i in @mapsprites.keys
      s=@mapsprites[i]
      @mapspritepos[i]=[s.x,s.y] if s && !s.disposed?
    end
  end

  def mapScreen
    @sprites={}
    @mapsprites={}
    @mapspritepos={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @lasthitmap=-1
    @lastclick=-1
    @oldmousex=nil
    @oldmousey=nil
    @dragging=false
    @dragmapid=-1
    @dragOffsetX=0
    @dragOffsetY=0
    @selmapid=-1
    addBackgroundPlane(@sprites,"background","trainercardbg",@viewport)
    @sprites["selsprite"]=SelectionSprite.new(@viewport)
    @sprites["title"]=Window_UnformattedTextPokemon.new(_INTL("F5: Help"))
    @sprites["title"].x=0
    @sprites["title"].y=Graphics.height-64
    @sprites["title"].width=Graphics.width
    @sprites["title"].height=64
    @sprites["title"].viewport=@viewport
    @sprites["title"].z=2
    @mapinfos=load_data("Data/MapInfos.rxdata")
    @encdata=load_data("Data/encounters.dat")
    conns=MapFactoryHelper.getMapConnections
    @mapconns=[]
    for c in conns
      @mapconns.push(c.clone)
    end
    @metadata=load_data("Data/metadata.dat")
    if $game_map
      @currentmap=$game_map.map_id
    else
      system=load_data("Data/System.rxdata")
      @currentmap=system.edit_map_id
    end
    putSprite(@currentmap)
  end

  def setTopSprite(id)
    for i in @mapsprites.keys
      if i==id
        @mapsprites[i].z=1
      else
        @mapsprites[i].z=0
      end
    end
  end

  def getMetadata(mapid,metadataType)
    return @metadata[mapid][metadataType] if @metadata[mapid]
  end

  def setMetadata(mapid,metadataType,data)
    @metadata[mapid]=[] if !@metadata[mapid]
    @metadata[mapid][metadataType]=data
  end

  def serializeMetadata
    pbSerializeMetadata(@metadata,@mapinfos)
  end

  def helpWindow
    helptext=_INTL("A: Add map to canvas\r\n")
    helptext+=_INTL("DEL: Delete map from canvas\r\n")
    helptext+=_INTL("S: Go to another map\r\n")
    helptext+=_INTL("Click to select a map\r\n")
    helptext+=_INTL("Double-click: Edit map's metadata\r\n")
    helptext+=_INTL("E: Edit map's encounters\r\n")
    helptext+=_INTL("Drag map to move it\r\n")
    helptext+=_INTL("Arrow keys/drag canvas: Move around canvas")
    title=Window_UnformattedTextPokemon.new(helptext)
    title.x=0
    title.y=0
    title.width=Graphics.width*8/10
    title.height=Graphics.height
    title.viewport=@viewport
    title.z=2
    loop do
      Graphics.update
      Input.update
      break if Input.trigger?(Input::C)
      break if Input.trigger?(Input::B)
    end
    Input.update
    title.dispose
  end

  def propertyList(map,properties)
    infos=load_data("Data/MapInfos.rxdata")
    mapname=(map==0) ? _INTL("Global Metadata") : infos[map].name
    data=[]
    for i in 0...properties.length
      data.push(getMetadata(map,i+1))
    end
    pbPropertyList(mapname,data,properties)
    for i in 0...properties.length
      setMetadata(map,i+1,data[i])
    end
  end

  def getMapRect(mapid)
    sprite=getMapSprite(mapid)
    if sprite
      return [
         sprite.x,
         sprite.y,
         sprite.x+sprite.bitmap.width,
         sprite.y+sprite.bitmap.height
      ]
    else
      return nil
    end
  end

  def onDoubleClick(mapid)
    if mapid>=0
      propertyList(mapid,LOCALMAPS)
    else
      propertyList(0,GLOBALMETADATA)
    end
  end

  def onClick(mapid,x,y)
    if @lastclick>0 && Graphics.frame_count-@lastclick<15
      onDoubleClick(mapid)
      @lastclick=-1
    else
      @lastclick=Graphics.frame_count
      if mapid>=0
        @dragging=true
        @dragmapid=mapid
        sprite=getMapSprite(mapid)
        @sprites["selsprite"].othersprite=sprite
        @selmapid=mapid
        @dragOffsetX=sprite.x-x
        @dragOffsetY=sprite.y-y
        setTopSprite(mapid)
      else
        @sprites["selsprite"].othersprite=nil
        @dragging=true
        @dragmapid=mapid
        @selmapid=-1
        @dragOffsetX=x
        @dragOffsetY=y
        saveMapSpritePos
      end
    end
  end

  def onRightClick(mapid,x,y)
#   echo("rightclick (#{mapid})\r\n")
  end

  def onMouseUp(mapid)
#   echo("mouseup (#{mapid})\r\n")
    @dragging=false if @dragging
  end

  def onRightMouseUp(mapid)
#   echo("rightmouseup (#{mapid})\r\n")
  end

  def onMouseOver(mapid,x,y)
#   echo("mouseover (#{mapid},#{x},#{y})\r\n")
  end

  def onMouseMove(mapid,x,y)
#   echo("mousemove (#{mapid},#{x},#{y})\r\n")
    if @dragging
      if @dragmapid>=0
        sprite=getMapSprite(@dragmapid)
        x=x+@dragOffsetX
        y=y+@dragOffsetY
        sprite.x=x&~3
        sprite.y=y&~3
        @sprites["title"].text=_ISPRINTF("F5: Help [{1:03d} {2:s}]",mapid,@mapinfos[@dragmapid].name)
      else
        xpos=x-@dragOffsetX
        ypos=y-@dragOffsetY
        for i in @mapspritepos.keys
          sprite=getMapSprite(i)
          sprite.x=(@mapspritepos[i][0]+xpos)&~3
          sprite.y=(@mapspritepos[i][1]+ypos)&~3
        end
        @sprites["title"].text=_INTL("F5: Help")
      end
    else
      if mapid>=0
        @sprites["title"].text=_ISPRINTF("F5: Help [{1:03d} {2:s}]",mapid,@mapinfos[mapid].name)
      else
        @sprites["title"].text=_INTL("F5: Help")
      end
    end
  end

  def hittest(x,y)
    for i in @mapsprites.keys
      sx=@mapsprites[i].x
      sy=@mapsprites[i].y
      sr=sx+@mapsprites[i].bitmap.width
      sb=sy+@mapsprites[i].bitmap.height
      return i if x>=sx && x<sr && y>=sy && y<sb
    end
    return -1
  end

  def chooseMapScreen(title,currentmap)
    return pbListScreen(title,MapLister.new(currentmap))
  end

  def update
    mousepos=Mouse::getMousePos
    if mousepos
      hitmap=hittest(mousepos[0],mousepos[1])
      if Input.triggerex?(0x01)
        onClick(hitmap,mousepos[0],mousepos[1])   
      elsif Input.triggerex?(0x02)
        onRightClick(hitmap,mousepos[0],mousepos[1])
      elsif Input.releaseex?(0x01)
        onMouseUp(hitmap)
      elsif Input.releaseex?(0x02)
        onRightMouseUp(hitmap)
      else
        if @lasthitmap!=hitmap
          onMouseOver(hitmap,mousepos[0],mousepos[1])
          @lasthitmap=hitmap
        end
        if @oldmousex!=mousepos[0]||@oldmousey!=mousepos[1]
          onMouseMove(hitmap,mousepos[0],mousepos[1])
          @oldmousex=mousepos[0]
          @oldmousey=mousepos[1]
        end
      end
    end
    if Input.press?(Input::UP)
      for i in @mapsprites
        next if !i
        i[1].y+=4
      end
    end
    if Input.press?(Input::DOWN)
      for i in @mapsprites
        next if !i
        i[1].y-=4
      end
    end
    if Input.press?(Input::LEFT)
      for i in @mapsprites
        next if !i
        i[1].x+=4
      end
    end
    if Input.press?(Input::RIGHT)
      for i in @mapsprites
        next if !i
        i[1].x-=4
      end
    end
    if Input.triggerex?("A"[0])
      id=chooseMapScreen(_INTL("Add Map"),@currentmap)
      if id>0
        addSprite(id)
        setTopSprite(id)
        @mapconns=generateConnectionData
      end
    elsif Input.triggerex?("S"[0])
      id=chooseMapScreen(_INTL("Go to Map"),@currentmap)
      if id>0
        @mapconns=generateConnectionData
        pbDisposeSpriteHash(@mapsprites)
        @mapsprites.clear
        @sprites["selsprite"].othersprite=nil
        @selmapid=-1
        putSprite(id)
        @currentmap=id
      end
    elsif Input.triggerex?(0x2E) # Delete
      if @mapsprites.keys.length>1 && @selmapid>=0
        @mapsprites[@selmapid].bitmap.dispose
        @mapsprites[@selmapid].dispose
        @mapsprites.delete(@selmapid)
        @sprites["selsprite"].othersprite=nil
        @selmapid=-1
      end
    elsif Input.triggerex?("E"[0])
      pbEncounterEditorMap(@encdata,@selmapid) if @selmapid>=0
    elsif Input.trigger?(Input::F5)
      helpWindow
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbMapScreenLoop
    loop do
      Graphics.update
      Input.update
      update
      if Input.trigger?(Input::B)
        if Kernel.pbConfirmMessage(_INTL("Save changes?"))
          serializeConnectionData
          serializeMetadata
          save_data(@encdata,"Data/encounters.dat")
          pbSaveEncounterData()
          pbClearData
        end
        break if Kernel.pbConfirmMessage(_INTL("Exit from the editor?"))
      end
    end
  end
end



def pbEditorScreen
  pbCriticalCode {
     mapscreen=MapScreenScene.new
     mapscreen.mapScreen
     mapscreen.pbMapScreenLoop
     mapscreen.close
  }
end