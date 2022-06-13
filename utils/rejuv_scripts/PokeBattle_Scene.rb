def pbPokemonString(pkmn)
  if pkmn.is_a?(PokeBattle_Battler) && !pkmn.pokemon
    return ""
  end
  status=""
  if pkmn.hp<=0
    status=" [FNT]"
  else
    case pkmn.status
      when PBStatuses::SLEEP
        status=" [SLP]"
      when PBStatuses::FROZEN
        status=" [FRZ]"
      when PBStatuses::BURN
        status=" [BRN]"
      when PBStatuses::PARALYSIS
        status=" [PAR]"
      when PBStatuses::POISON
        status=" [PSN]"
    end
  end
  return "#{pkmn.name} (Lv. #{pkmn.level})#{status} HP: #{pkmn.hp}/#{pkmn.totalhp}"
end

#>>>>DemICE entered the chat
def pbShowBattleStats(pkmn)
  friend=@battle.battlers[0]
  atksbl="+"  
  atksbl=" " if pkmn.stages[PBStats::ATTACK]<0
  defsbl="+"  
  defsbl=" " if pkmn.stages[PBStats::DEFENSE]<0
  spasbl="+"
  spasbl=" " if pkmn.stages[PBStats::SPATK]<0
  spdsbl="+"
  spdsbl=" " if pkmn.stages[PBStats::SPDEF]<0
  spesbl="+"
  spesbl=" " if pkmn.stages[PBStats::SPEED]<0
  accsbl="+"
  accsbl=" " if pkmn.stages[PBStats::ACCURACY]<0
  evasbl="+"
  evasbl=" " if pkmn.stages[PBStats::EVASION]<0
  c=pkmn.pbCalcCrit()
  if c==0
    crit=4
  elsif c==1
    crit=25
  elsif c==2
    crit=50
  else 
    crit=100
  end  
  if (pkmn.type1 != pkmn.type2)  
    report = [_INTL("Type: {1}/{2}",PBTypes.getName(pkmn.type1),PBTypes.getName(pkmn.type2))]  
  else  
    report = [_INTL("Type: {1}",PBTypes.getName(pkmn.type1))]  
  end
  report.push(_INTL("Level: {1}",pkmn.level))
 # {1} {2} {3} {4}",pkmn.moves[0],pkmn.moves[1],pkmn.moves[2],pkmn.moves[3])"
 #if @battle.revealedMoves[0][pkmn.pokemonIndex].include?(pkmn.moves[0])
  report.push(_INTL("Attack:        {1}   {2}{3}",pkmn.pbCalcAttack(),atksbl,pkmn.stages[PBStats::ATTACK]),
              _INTL("Defense:      {1}   {2}{3}",pkmn.pbCalcDefense(),defsbl,pkmn.stages[PBStats::DEFENSE]),
              _INTL("Sp.Attack:   {1}   {2}{3}",pkmn.pbCalcSpAtk(),spasbl,pkmn.stages[PBStats::SPATK]),
              _INTL("Sp.Defense: {1}   {2}{3}",pkmn.pbCalcSpDef(),spdsbl,pkmn.stages[PBStats::SPDEF]),
              _INTL("Speed:         {1}   {2}{3}",pkmn.pbSpeed(),spesbl,pkmn.stages[PBStats::SPEED]),
              _INTL("Accuracy:   {1}% {2}{3}",pkmn.pbCalcAcc(),accsbl,pkmn.stages[PBStats::ACCURACY]),
              _INTL("Evasion:       {1}% {2}{3}",pkmn.pbCalcEva(),evasbl,pkmn.stages[PBStats::EVASION]),
              _INTL("Crit. Rate:    {1}%    +{2}/3",crit,c))
  if (pkmn == @battle.battlers[1] || pkmn == @battle.battlers[3])
    if @battle.revealedMoves[0][pkmn.pokemonIndex].length!=0
    report.push(_INTL("Revealed Moves:"))
      for i in @battle.revealedMoves[0][pkmn.pokemonIndex]
        if i.id==pkmn.moves[0].id
          report.push(_INTL("{1}:  {2} PP left",pkmn.moves[0].name,pkmn.moves[0].pp))
        end
        if i.id==pkmn.moves[1].id
          report.push(_INTL("{1}:  {2} PP left",pkmn.moves[1].name,pkmn.moves[1].pp))
        end
        if i.id==pkmn.moves[2].id
          report.push(_INTL("{1}:  {2} PP left",pkmn.moves[2].name,pkmn.moves[2].pp))
        end
        if i.id==pkmn.moves[3].id
          report.push(_INTL("{1}:  {2} PP left",pkmn.moves[3].name,pkmn.moves[3].pp))
        end
      end
    end
  end
  dur=@battle.weatherduration
  dur="Permanent" if @battle.weatherduration<0
  turns="turns"
  turns="" if @battle.weatherduration<0
  if @battle.weather==PBWeather::RAINDANCE
    weatherreport=_INTL("Weather: Rain, {1} {2}",dur,turns)
    weatherreport=_INTL("Weather: Torrential Rain, {1} {2}",dur,turns) if @battle.field.effects[PBEffects::HeavyRain]
  elsif @battle.weather==PBWeather::SUNNYDAY
    weatherreport=_INTL("Weather: Sun, {1} {2}",dur,turns)
    weatherreport=_INTL("Weather: Scorching Sun, {1} {2}",dur,turns) if @battle.field.effects[PBEffects::HarshSunlight]
  elsif @battle.weather==PBWeather::SANDSTORM
    weatherreport=_INTL("Weather: Sandstorm, {1} {2}",dur,turns)
  elsif @battle.weather==PBWeather::HAIL
    weatherreport=_INTL("Weather: Hail, {1} {2}",dur,turns)
  elsif @battle.weather==PBWeather::STRONGWINDS
    weatherreport=_INTL("Weather: Strong Winds, {1} {2}",dur,turns)
  elsif @battle.weather==PBWeather::SHADOWSKY
    weatherreport=_INTL("Weather: Shadow Sky, {1} {2}",dur,turns)
  end
  report.push(weatherreport) if @battle.weather!=0
  report.push(_INTL("Slow Start: {1} turns",(5-pkmn.turncount))) if pkmn.hasWorkingAbility(:SLOWSTART) && pkmn.turncount<=5 && (pkmn == @battle.battlers[0] || pkmn == @battle.battlers[2])
  report.push(_INTL("Throat Chop: {1} turns",pkmn.effects[PBEffects::ThroatChop])) if pkmn.effects[PBEffects::ThroatChop]!=0
  report.push(_INTL("Unburdened")) if pkmn.unburdened && (pkmn == @battle.battlers[0] || pkmn == @battle.battlers[2]) && pkmn.hasWorkingAbility(:UNBURDEN)
  report.push(_INTL("Speed Swap")) if pkmn.effects[PBEffects::SpeedSwap]!=0
  report.push(_INTL("Burn Up")) if pkmn.effects[PBEffects::BurnUp]
  report.push(_INTL("Uproar: {1} turns",pkmn.effects[PBEffects::Uproar])) if pkmn.effects[PBEffects::Uproar]!=0
  report.push(_INTL("Truant")) if pkmn.effects[PBEffects::Truant] && (pkmn == @battle.battlers[0] || pkmn == @battle.battlers[2]) && pkmn.hasWorkingAbility(:TRUANT)
  report.push(_INTL("Toxic: {1} turns",pkmn.effects[PBEffects::Toxic])) if pkmn.effects[PBEffects::Toxic]!=0
  report.push(_INTL("Torment")) if pkmn.effects[PBEffects::Torment]
  report.push(_INTL("Miracle Eye")) if pkmn.effects[PBEffects::MiracleEye]
  report.push(_INTL("Minimized")) if pkmn.effects[PBEffects::Minimize]
  report.push(_INTL("Recharging")) if pkmn.effects[PBEffects::HyperBeam]!=0
  report.push(_INTL("Fury Cutter: +{1}",pkmn.effects[PBEffects::FuryCutter])) if pkmn.effects[PBEffects::FuryCutter]!=0
  report.push(_INTL("Echoed Voice: +{1}",pkmn.effects[PBEffects::EchoedVoice])) if pkmn.effects[PBEffects::EchoedVoice]!=0
  report.push(_INTL("Mean Look")) if pkmn.effects[PBEffects::MeanLook]>-1
  report.push(_INTL("Foresight")) if pkmn.effects[PBEffects::Foresight]
  report.push(_INTL("Follow Me")) if pkmn.effects[PBEffects::FollowMe]
  report.push(_INTL("Rage Powder")) if pkmn.effects[PBEffects::RagePowder]
  report.push(_INTL("Flash Fire")) if pkmn.effects[PBEffects::FlashFire]
  report.push(_INTL("Substitute")) if pkmn.effects[PBEffects::Substitute]!=0
  report.push(_INTL("Perish Song: {1} turns",pkmn.effects[PBEffects::PerishSong])) if pkmn.effects[PBEffects::PerishSong]>0
  report.push(_INTL("Leech Seed")) if pkmn.effects[PBEffects::LeechSeed]>-1
  report.push(_INTL("Gastro Acid")) if pkmn.effects[PBEffects::GastroAcid]
  report.push(_INTL("Curse")) if pkmn.effects[PBEffects::Curse]
  report.push(_INTL("Nightmare")) if pkmn.effects[PBEffects::Nightmare]
  report.push(_INTL("Confused")) if pkmn.effects[PBEffects::Confusion]!=0
  report.push(_INTL("Aqua Ring")) if pkmn.effects[PBEffects::AquaRing]
  report.push(_INTL("Ingrain")) if pkmn.effects[PBEffects::Ingrain]
  report.push(_INTL("Power Trick")) if pkmn.effects[PBEffects::PowerTrick]
  report.push(_INTL("Smacked Down")) if pkmn.effects[PBEffects::SmackDown]
  report.push(_INTL("Air Balloon")) if pkmn.hasWorkingItem(:AIRBALLOON)
  report.push(_INTL("Magnet Rise: {1} turns",pkmn.effects[PBEffects::MagnetRise])) if pkmn.effects[PBEffects::MagnetRise]!=0
  report.push(_INTL("Telekinesis: {1} turns",pkmn.effects[PBEffects::Telekinesis])) if pkmn.effects[PBEffects::Telekinesis]!=0
  report.push(_INTL("Heal Block: {1} turns",pkmn.effects[PBEffects::HealBlock])) if pkmn.effects[PBEffects::HealBlock]!=0
  report.push(_INTL("Embargo: {1} turns",pkmn.effects[PBEffects::Embargo])) if pkmn.effects[PBEffects::Embargo]!=0
  report.push(_INTL("Disable: {1} turns",pkmn.effects[PBEffects::Disable])) if pkmn.effects[PBEffects::Disable]!=0
  report.push(_INTL("Encore: {1} turns",pkmn.effects[PBEffects::Encore])) if pkmn.effects[PBEffects::Encore]!=0
  report.push(_INTL("Taunt: {1} turns",pkmn.effects[PBEffects::Taunt])) if pkmn.effects[PBEffects::Taunt]!=0
  report.push(_INTL("Infatuated with {1}",@battle.battlers[pkmn.effects[PBEffects::Attract]].name)) if pkmn.effects[PBEffects::Attract]>=0
  report.push(_INTL("Trick Room: {1} turns",@battle.trickroom)) if @battle.trickroom!=0
  report.push(_INTL("Gravity: {1} turns",@battle.field.effects[PBEffects::Gravity])) if @battle.field.effects[PBEffects::Gravity]>0  
  report.push(_INTL("Tailwind: {1} turns",pkmn.pbOwnSide.effects[PBEffects::Tailwind])) if pkmn.pbOwnSide.effects[PBEffects::Tailwind]>0   
  report.push(_INTL("Reflect: {1} turns",pkmn.pbOwnSide.effects[PBEffects::Reflect])) if pkmn.pbOwnSide.effects[PBEffects::Reflect]>0
  report.push(_INTL("Light Screen: {1} turns",pkmn.pbOwnSide.effects[PBEffects::LightScreen])) if pkmn.pbOwnSide.effects[PBEffects::LightScreen]>0
  report.push(_INTL("Aurora Veil: {1} turns",pkmn.pbOwnSide.effects[PBEffects::AuroraVeil])) if pkmn.pbOwnSide.effects[PBEffects::AuroraVeil]>0
  report.push(_INTL("Safeguard: {1} turns",pkmn.pbOwnSide.effects[PBEffects::Safeguard])) if pkmn.pbOwnSide.effects[PBEffects::Safeguard]>0
  report.push(_INTL("Lucky Chant: {1} turns",pkmn.pbOwnSide.effects[PBEffects::LuckyChant])) if pkmn.pbOwnSide.effects[PBEffects::LuckyChant]>0
  report.push(_INTL("Mist: {1} turns",pkmn.pbOwnSide.effects[PBEffects::Mist])) if pkmn.pbOwnSide.effects[PBEffects::Mist]>0 
  report.push(_INTL("Altered Field: {1} turns",@battle.field.effects[PBEffects::Terrain])) if @battle.field.effects[PBEffects::Terrain]>0
  report.push(_INTL("Messed up Field: {1} turns",@battle.field.effects[PBEffects::Splintered])) if @battle.field.effects[PBEffects::Splintered]>0  
  report.push(_INTL("Electric Terrain: {1} turns",@battle.field.effects[PBEffects::ElectricTerrain])) if @battle.field.effects[PBEffects::ElectricTerrain]>0  
  report.push(_INTL("Grassy Terrain: {1} turns",@battle.field.effects[PBEffects::GrassyTerrain])) if @battle.field.effects[PBEffects::GrassyTerrain]>0
  report.push(_INTL("Misty Terrain: {1} turns",@battle.field.effects[PBEffects::MistyTerrain])) if @battle.field.effects[PBEffects::MistyTerrain]>0
  report.push(_INTL("Psychic Terrain: {1} turns",@battle.field.effects[PBEffects::PsychicTerrain])) if @battle.field.effects[PBEffects::PsychicTerrain]>0
  report.push(_INTL("Rainbow: {1} turns",@battle.field.effects[PBEffects::Rainbow])) if @battle.field.effects[PBEffects::Rainbow]>0
  report.push(_INTL("Magic Room: {1} turns",@battle.field.effects[PBEffects::MagicRoom])) if @battle.field.effects[PBEffects::MagicRoom]>0
  report.push(_INTL("Wonder Room: {1} turns",@battle.field.effects[PBEffects::WonderRoom])) if @battle.field.effects[PBEffects::WonderRoom]>0
  report.push(_INTL("Water Sport: {1} turns",@battle.field.effects[PBEffects::WaterSport])) if @battle.field.effects[PBEffects::WaterSport]>0
  report.push(_INTL("Mud Sport: {1} turns",@battle.field.effects[PBEffects::MudSport])) if @battle.field.effects[PBEffects::MudSport]>0
  report.push(_INTL("Spikes: {1} layers",pkmn.pbOwnSide.effects[PBEffects::Spikes])) if pkmn.pbOwnSide.effects[PBEffects::Spikes]>0
  report.push(_INTL("Toxic Spikes: {1} layers",pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes])) if pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
  report.push(_INTL("Stealth Rock active")) if pkmn.pbOwnSide.effects[PBEffects::StealthRock]
  report.push(_INTL("Sticky Web active")) if pkmn.pbOwnSide.effects[PBEffects::StickyWeb]
  report.push()
  report.push(_INTL("Wonder Room Stat Swap active")) if pkmn.wonderroom==true
  fieldnames = ["No Field", "Electric Terrain", "Grassy Terrain", "Misty Terrain", "Dark Crystal Cavern",
                "Chess Board", "Big Top Arena", "Volcanic Field", "Swamp Field", "Rainbow Field",
                "Corrosive Field", "Corrosive Mist Field", "Desert Field", "Icy Field", "Rocky Field",
                "Forest Field", "Volcanic Top Field", "Factory Field", "Short-circuit Field", "Wasteland",
                "Ashen Beach", "Water Surface", "Underwater", "Cave", "Glitch Field",
                "Crystal Cavern", "Murkwater Surface", "Mountain", "Snowy Mountain", "Blessed Field",
                "Mirror Arena", "Fairy Tale Field", "Dragon's Den", "Flower Garden Field", "Starlight Arena",
                "New World", "Inverse Field", "Psychic Terrain", "Dimensional Field", "Frozen Dimensional Field",
                "Haunted Field", "Corrupted Cave", "Bewitched Woods", "Sky Field", "Colosseum Field", 
                "Infernal Field"]
  report.push(_INTL("Field effect: {1}", fieldnames[$fefieldeffect]))
  party=@battle.pbParty(pkmn.index)
  participants=0
  for i in 0...party.length
    participants+=1 if party[i] && !party[i].isEgg? &&
    party[i].hp>0 && party[i].status==0 && !party[i].nil?
  end
  report.push(_INTL("Remaining Pokemon: {1} ",(participants)))
  Kernel.pbMessage((_INTL"Inspecting {1}:",pkmn.name),report, report.length)
end
#DemICE left the chat>>>>    

class Window_Pokemon < SpriteWindow_Base
  attr_reader :highlighted

  def highlighted=(value)
    @highlighted=value
    refresh
  end

  def initialize(battler)
    @battler=battler
    @highlighted=false
    @highlightOpacity=255
    @highlightIncr=-2
    super(0,0,480,64)
    self.contents=Bitmap.new(self.width-32,self.height-32)
    self.z=100000
    refresh
  end

  def update
    if @highlighted
      @highlightIncr=-5 if @highlightOpacity>=255
      @highlightIncr=5 if @highlightOpacity<=160
      self.opacity=@highlightOpacity
      self.contents_opacity=@highlightOpacity
      @highlightOpacity+=@highlightIncr
    elsif self.opacity!=255 || self.contents_opacity!=255
      self.opacity=255
      self.contents_opacity=255
    end
    super
  end

  def refresh
    self.contents.clear
    self.contents.font.color = Color.new(0,0,0)
    str=pbPokemonString(@battler)
    self.contents.draw_text(0, 0, self.width-32, 32, str, 0)  
  end
end



class Window_SimpleText < SpriteWindow_Base
  attr_reader :text
  attr_reader :lines

  def text=(value)
    @text=value
    refresh
  end

  def initialize(text,lines)
    @text=text
    @lines=lines
    @lines=1 if @lines<1
    super(0,0,480,32+(@lines*32))
    self.contents=Bitmap.new(self.width-32,self.height-32)
    self.z=100000
    refresh
  end

  def refresh
    self.contents.clear
    self.contents.font.color = Color.new(0,0,0)
    textmsg=@text.clone
    x=y=0
    while ((c = textmsg.slice!(/\S*\s?/m)) != nil)
      break if c==""
      textwidth=self.contents.text_size(c).width
      if c=="\n" 
        # Add 1 to y
        y += 1
        x = 0
        next
      end
      if x>0 && x+textwidth>=self.contents.width
        # Add 1 to y
        y += 1
        x = 0
      end
      # Draw text
      self.contents.draw_text(4 + x, 32 * y, textwidth, 32, c)
      # Add x to drawn text width
      x += textwidth
    end
  end
end



class PokeBattle_DebugScene
  def initialize
    @battle=nil
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
    @pkmnwindows=[nil,nil,nil,nil]
  end

  def pbDisplayMessage(msg,brief=false)
    pbRefresh
    cw = Window_SimpleText.new(msg,4)
    cw.y=256
    i=0
    loop do
      Graphics.update
      Input.update
      cw.update
      if i==80
        cw.dispose
        return
      end
      if Input.trigger?(Input::C)
        cw.dispose
        return
      end
      i+=1
    end
  end

  def pbDisplayPausedMessage(msg)
    cw = Window_SimpleText.new(msg,4)
    cw.y=256
    cw.pause=true
    loop do
      Graphics.update
      Input.update
      cw.update
      if Input.trigger?(Input::C)
        cw.dispose
        return
      end
    end
  end

  def pbDisplayConfirmMessage(msg)
    dw = Window_SimpleText.new(msg,4)
    dw.y=256
    commands=["YES","NO"]
    cw = Window_Command.new(96, commands)
    cw.x=384
    cw.y=160
    cw.index=0
    pbRefresh
    loop do
      Graphics.update
      Input.update
      pbFrameUpdate(cw)
      if Input.trigger?(Input::B)
        cw.dispose
        dw.dispose
        return false
      end
      if Input.trigger?(Input::C)
        cw.dispose
        dw.dispose
        return (cw.index==0)?true:false
      end
    end 
  end

  def pbFrameUpdate(cw=nil)
    cw.update if cw
    for i in 0..3
      @pkmnwindows[i].update if @pkmnwindows[i]
    end 
#   @exceptwindow.text="Exceptions: #{$PBDebugExceptions}"
#   @exceptwindow.update
  end

  def pbRefresh
    for i in 0..3
      @pkmnwindows[i].refresh if @pkmnwindows[i]
    end 
#   @exceptwindow.refresh
  end

# Called whenever a new round begins.
  def pbBeginCommandPhase
  end

# Called whenever the battle begins
  def pbStartBattle(battle)
    @battle=battle
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
    numwindows=battle.doublebattle ? 4 : 2
    for i in 0...numwindows
      @pkmnwindows[i]=Window_Pokemon.new(@battle.battlers[i])
      @pkmnwindows[i].y=i*64
    end
#   @exceptwindow=Window_SimpleText.new("Exceptions: 0",1)
#   @exceptwindow.x=0
#   @exceptwindow.y=416
  end

  def pbEndBattle(result)
    for i in 0..3
      @pkmnwindows[i].dispose if @pkmnwindows[i]
    end
#   @exceptwindow.dispose
  end

  def pbTrainerSendOut(battle,pkmn)
    pbRefresh
  end

  def pbSendOut(battle,pkmn)
    pbRefresh
  end

  def pbTrainerWithdraw(battle,pkmn)
    pbRefresh
  end

  def pbWithdraw(battle,pkmn)
    pbRefresh
  end

# Called whenever a Pokémon should forget a move.  It should return -1 if the
# selection is canceled, or 0 to 3 to indicate the move to forget.
# The function should not allow HM moves to be forgotten.
  def pbForgetMove(pkmn,move)
    return 0
  end

  def pbBeginAttackPhase
  end

# Use this method to display the list of commands.
#  Return values:
#  0 - Fight
#  1 - Pokémon
#  2 - Bag
#  3 - Run
  def pbCommandMenu(index)
    commands=["FIGHT","POKéMON","BAG","RUN"]
    cw = Window_Command.new(192, commands)
    cw.x=0
    cw.y=256
    cw.index=@lastcmd[index]
    pbRefresh
    loop do
      Graphics.update
      Input.update
      pbFrameUpdate(cw)
      if Input.trigger?(Input::C)
        ret=cw.index
        cw.dispose
        @lastcmd[index]=ret
        return ret
      end
    end 
  end

  def pbPokemonString(pkmn)
    status=""
    if pkmn.hp<=0
      status=" [FNT]"
    else
      case pkmn.status
        when PBStatuses::SLEEP
          status=" [SLP]"
        when PBStatuses::FROZEN
          status=" [FRZ]"
        when PBStatuses::BURN
          status=" [BRN]"
        when PBStatuses::PARALYSIS
          status=" [PAR]"
        when PBStatuses::POISON
          status=" [PSN]"
      end
    end
    return "#{pkmn.name} (Lv. #{pkmn.level})#{status} HP: #{pkmn.hp}/#{pkmn.totalhp}"
  end

  def pbMoveString(move)
    ret="#{move.name}"
    typename=PBTypes.getName(move.type)
    if move.id>0
      ret+=" (#{typename}) PP: #{move.pp}/#{move.totalpp}"
    end
    return ret
  end

# Use this method to display the list of moves for a Pokémon
  def pbFightMenu(index)
    moves=@battle.battlers[index].moves
    commands=[
       pbMoveString(moves[0]),
       pbMoveString(moves[1]),
       pbMoveString(moves[2]),
       pbMoveString(moves[3])
    ]
    cw = Window_Command.new(480, commands)
    cw.x=0
    cw.y=256
    cw.index=@lastmove[index]
    pbRefresh
    loop do
      Graphics.update
      Input.update
      pbFrameUpdate(cw)
      if Input.trigger?(Input::B)
        @lastmove[index]=cw.index
        cw.dispose
        return -1
      end
      if Input.trigger?(Input::C)
        ret=cw.index
        @lastmove[index]=ret
        cw.dispose
        return ret
      end
    end
  end

# Use this method to display the inventory
# The return value is the item chosen, or 0 if the choice was canceled.
  def pbItemMenu(index)
    pbDisplayMessage("Items can't be used here.")
    return -1
  end

  def pbFirstTarget(index)
    for i in 0...4
      if i!=index && !@battle.battlers[i].isFainted?
        return i
      end  
    end
    return -1
  end

  def pbNextTarget(cur,index)
    return -1 if cur>=3
    for i in cur+1..3
      if i!=index && !@battle.battlers[i].isFainted?
        return i
      end  
    end
    return -1
  end

  def pbPrevTarget(cur,index)
    return -1 if cur<=0
    ret=-1
    for i in 0..cur-1
      if i!=index && !@battle.battlers[i].isFainted?
        ret=i
      end  
    end
    return ret
  end

# Use this method to make the player choose a target 
# for certain moves in double battles.
  def pbChooseTarget(index)
    curwindow=pbFirstTarget(index)
    if curwindow==-1
      raise RuntimeError.new("No targets somehow...")
    end
    numwindows=@battle.doublebattle ? 4 : 2
    for i in 0...numwindows
      @pkmnwindows[i].highlighted=(i==curwindow)
    end
    pbRefresh
    loop do
      Graphics.update
      Input.update
      pbFrameUpdate(nil)
      if Input.trigger?(Input::DOWN)
        newwindow=pbNextTarget(curwindow,index)
        if newwindow>=0
          curwindow=newwindow
          for i in 0...numwindows
            @pkmnwindows[i].highlighted=(i==curwindow)
          end
        end
      end
      if Input.trigger?(Input::UP)
        newwindow=pbPrevTarget(curwindow,index)
        if newwindow>=0
          curwindow=newwindow
          for i in 0...numwindows
            @pkmnwindows[i].highlighted=(i==curwindow)
          end
        end
      end
      if Input.trigger?(Input::B)
        for i in 0...numwindows
          @pkmnwindows[i].highlighted=false
          @pkmnwindows[i].update
        end
        return -1
      end
      if Input.trigger?(Input::C)
        for i in 0...numwindows
          @pkmnwindows[i].highlighted=false
          @pkmnwindows[i].update
        end
        return curwindow
      end
    end
  end

  def pbSwitch(index,lax,cancancel)
    party=@battle.pbParty(index)
    commands=[]
    inactives=[1,1,1,1,1,1]
    partypos=[]
    activecmd=0
    numactive=(@doublebattle)?2:1
    battler=@battle.battlers[0]
    commands[commands.length]=pbPokemonString(party[battler.pokemonIndex])
    activecmd=0 if battler.index==index
    inactives[battler.pokemonIndex]=0
    partypos[partypos.length]=battler.pokemonIndex
    if @battle.doublebattle
      battler=@battle.battlers[2]
      commands[commands.length]=pbPokemonString(party[battler.pokemonIndex])
      activecmd=1 if battler.index==index
      inactives[battler.pokemonIndex]=0
      partypos[partypos.length]=battler.pokemonIndex
    end
    for i in 0..party.length-1
      if inactives[i]==1
        commands[commands.length]=pbPokemonString(party[i]) 
        partypos[partypos.length]=i
      end
    end
    for i in 0..3
      @pkmnwindows[i].visible=false if @pkmnwindows[i]
    end
    cw = Window_Command.new(480, commands)
    cw.x=0
    cw.y=0
    cw.index=activecmd
    pbRefresh
    ret=0
    loop do
      Graphics.update
      Input.update
      pbFrameUpdate(cw)
      if cancancel && Input.trigger?(Input::B)
        ret=-1
        cw.dispose
        break
      end
      if Input.trigger?(Input::C)
        pkmnindex=partypos[cw.index]
        canswitch=lax ? @battle.pbCanSwitchLax?(index,pkmnindex,true) :
           @battle.pbCanSwitch?(index,pkmnindex,true)
        if canswitch
          ret=pkmnindex
          cw.dispose
          break
        end
      end
    end
    for i in 0..3
      @pkmnwindows[i].visible=true if @pkmnwindows[i]
    end
    return ret
  end

# This method is called whenever a Pokémon's HP changes.
# Used to animate the HP bar.
  def pbHPChanged(pkmn,oldhp,anim=false)
    hpchange=pkmn.hp-oldhp
    if hpchange<0
      hpchange=-hpchange
      PBDebug.log("[#{pkmn.pbThis} lost #{hpchange} HP, now has #{pkmn.hp} HP]")
    else
      PBDebug.log("[#{pkmn.pbThis} gained #{hpchange} HP, now has #{pkmn.hp} HP]")
    end
    pbRefresh
  end
# This method is called whenever a Pokémon faints
  def pbFainted(pkmn)
  end

  def pbFakeOutFainted(pkmn)
  end
  
  def pbChooseEnemyCommand(index)
    @battle.pbDefaultChooseEnemyCommand(index)
  end

# Use this method to choose a new Pokémon for the enemy
# The enemy's party is guaranteed to have at least one choosable member.
  def pbChooseNewEnemy(index,party)
    @battle.pbDefaultChooseNewEnemy(index,party)
  end

# This method is called when the player wins a wild Pokémon battle.
# This method can change the battle's music for example.
  def pbWildBattleSuccess
  end

# This method is called when the player wins a Trainer battle.
# This method can change the battle's music for example.
  def pbTrainerBattleSuccess
  end

  def pbEXPBar(battler,thispoke,startexp,endexp,tempexp1,tempexp2)
  end

  def pbLevelUp(battler,thispoke,oldtotalhp,oldattack,
                olddefense,oldspeed,oldspatk,oldspdef)
  end

  def pbShowOpponent(opp)
  end

  def pbHideOpponent
  end

  def pbRecall(battlerindex)
  end

  def pbDamageAnimation(pkmn,effectiveness)
  end

  def pbAnimation(moveid,attacker,opponent,hitnum=0)
    if attacker
      if opponent
        PBDebug.log("[pbAnimation (#{attacker.pbThis}, #{opponent.pbThis}]")
      else
        PBDebug.log("[pbAnimation (#{attacker.pbThis}]")
      end
    else
      PBDebug.log("[pbAnimation]")
    end
  end
end



class PokeBattle_SceneNonInteractive < PokeBattle_Scene
  def initialize
    super
    self.abortable=true
  end

  def pbCommandMenu(index)
    return 1 if rand(15)==0
    return 0
  end

  def pbFightMenu(index)
    battler=@battle.battlers[index]
    i=0
    begin
     i=rand(4)
    end while battler.moves[i].id==0
    PBDebug.log("i=#{i}, pp=#{battler.moves[i].pp}")
    PBDebug.flush
    return i
  end

  def pbItemMenu(index)
    return -1
  end

  def pbChooseTarget(index)
    targets=[]
    for i in 0...4
      if @battle.battlers[index].pbIsOpposing?(i) &&
         !@battle.battlers[i].isFainted?
        targets.push(i)
      end  
    end
    return -1 if targets.length==0
    return targets[rand(targets.length)]
  end

  def pbSwitch(index,lax,cancancel)
    for i in 0...@battle.pbParty(index).length
      if lax
        return i if @battle.pbCanSwitchLax?(index,i,false)
      else
        return i if @battle.pbCanSwitch?(index,i,false)
      end
    end
    return -1
  end

  def pbChooseEnemyCommand(index)
    @battle.pbDefaultChooseEnemyCommand(index)
  end

# Use this method to choose a new Pokémon for the enemy
# The enemy's party is guaranteed to have at least one choosable member.
  def pbChooseNewEnemy(index,party)
    @battle.pbDefaultChooseNewEnemy(index,party)
  end
end



class PokeBattle_DebugSceneNoLogging
  def initialize
    @battle=nil
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
  end

  def pbDisplayMessage(msg,brief=false)
  end

  def pbDisplayPausedMessage(msg)
  end

  def pbDisplayConfirmMessage(msg)
    return true
  end

  def pbShowCommands(msg,commands,defaultValue)
    return 0
  end

# Called whenever a new round begins.
  def pbBeginCommandPhase
  end

# Called whenever the battle begins
  def pbStartBattle(battle)
    @battle=battle
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
  end

  def pbEndBattle(result)
  end

  def pbTrainerSendOut(battle,pkmn)
  end

  def pbSendOut(battle,pkmn)
  end

  def pbTrainerWithdraw(battle,pkmn)
  end

  def pbWithdraw(battle,pkmn)
  end

# Called whenever a Pokémon should forget a move.  It should return -1 if the
# selection is canceled, or 0 to 3 to indicate the move to forget.
# The function should not allow HM moves to be forgotten.
  def pbForgetMove(pkmn,move)
    return 0
  end

  def pbBeginAttackPhase
  end

  def pbCommandMenu(index)
    return 1 if rand(15)==0
    return 4 if rand(10)==0
    return 0
  end

  def pbFightMenu(index)
    battler=@battle.battlers[index]
    i=0
    begin
      i=rand(4)
    end while battler.moves[i].id==0
    return i
  end

  def pbItemMenu(index)
    return -1
  end

  def pbChooseTarget(index)
    targets=[]
    for i in 0...4
      if @battle.battlers[index].pbIsOpposing?(i) &&
         !@battle.battlers[i].isFainted?
        targets.push(i)
      end  
    end
    return -1 if targets.length==0
    return targets[rand(targets.length)]
  end

  def pbRefresh
  end

  def pbSwitch(index,lax,cancancel)
    for i in 0..@battle.pbParty(index).length-1
      if lax
        return i if @battle.pbCanSwitchLax?(index,i,false)
      else
        return i if @battle.pbCanSwitch?(index,i,false)
      end
    end
    return -1
  end

  def pbHPChanged(pkmn,oldhp,anim=false)
  end
  

  def pbFainted(pkmn)
  end

  def pbFakeOutFainted(pkmn)
  end

  def pbChooseEnemyCommand(index)
    @battle.pbDefaultChooseEnemyCommand(index)
  end

# Use this method to choose a new Pokémon for the enemy
# The enemy's party is guaranteed to have at least one choosable member.
  def pbChooseNewEnemy(index,party)
    @battle.pbDefaultChooseNewEnemy(index,party)
  end

# This method is called when the player wins a wild Pokémon battle.
# This method can change the battle's music for example.
  def pbWildBattleSuccess
  end

# This method is called when the player wins a Trainer battle.
# This method can change the battle's music for example.
  def pbTrainerBattleSuccess
  end

  def pbEXPBar(battler,thispoke,startexp,endexp,tempexp1,tempexp2)
  end

  def pbLevelUp(battler,thispoke,oldtotalhp,oldattack,
                olddefense,oldspeed,oldspatk,oldspdef)
  end

  def pbBlitz(keys)
    return rand(30)
  end

  def pbChatter(attacker,opponent)
  end

  def pbShowOpponent(opp)
  end

  def pbHideOpponent
  end

  def pbRecall(battlerindex)
  end

  def pbDamageAnimation(pkmn,effectiveness)
  end

  def pbBattleArenaJudgment(b1,b2,r1,r2)
  end

  def pbBattleArenaBattlers(b1,b2)
  end

  def pbCommonAnimation(moveid,attacker,opponent,hitnum=0)
  end

  def pbAnimation(moveid,attacker,opponent,hitnum=0)
  end
end


class PokeBattle_DebugSceneNoGraphics
  def initialize
    @battle=nil
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
  end

  def pbDisplayMessage(msg,brief=false)
    PBDebug.log(msg)
    @messageCount+=1
  end

  def pbDisplayPausedMessage(msg)
    PBDebug.log(msg)
    @messageCount+=1
  end

  def pbDisplayConfirmMessage(msg)
    PBDebug.log(msg)
    @messageCount+=1
    return true
  end

  def pbShowCommands(msg,commands,defaultValue)
    PBDebug.log(msg)
    @messageCount+=1
    return 0
  end

# Called whenever a new round begins.
  def pbBeginCommandPhase
    if @messageCount>0
      PBDebug.log("[message count: #{@messageCount}]")
    end
    @messageCount=0
  end

# Called whenever the battle begins
  def pbStartBattle(battle)
    @battle=battle
    @lastcmd=[0,0,0,0]
    @lastmove=[0,0,0,0]
    @messageCount=0
  end

  def pbEndBattle(result)
  end

  def pbTrainerSendOut(battle,pkmn)
  end

  def pbSendOut(battle,pkmn)
  end

  def pbTrainerWithdraw(battle,pkmn)
  end

  def pbWithdraw(battle,pkmn)
  end

# Called whenever a Pokémon should forget a move.  It should return -1 if the
# selection is canceled, or 0 to 3 to indicate the move to forget.
# The function should not allow HM moves to be forgotten.
  def pbForgetMove(pkmn,move)
    return 0
  end

  def pbBeginAttackPhase
  end

  def pbCommandMenu(index)
    return 1 if rand(15)==0
    return 0
  end

  def pbFightMenu(index)
    battler=@battle.battlers[index]
    i=0
    begin
      i=rand(4)
    end while battler.moves[i].id==0
    return i
  end

  def pbItemMenu(index)
    return -1
  end

  def pbChooseTarget(index)
    targets=[]
    for i in 0...4
      if @battle.battlers[index].pbIsOpposing?(i) &&
         !@battle.battlers[i].isFainted?
        targets.push(i)
      end  
    end
    return -1 if targets.length==0
    return targets[rand(targets.length)]
  end

  def pbRefresh
  end

  def pbSwitch(index,lax,cancancel)
    for i in 0..@battle.pbParty(index).length-1
      if lax
        return i if @battle.pbCanSwitchLax?(index,i,false)
      else
        return i if @battle.pbCanSwitch?(index,i,false)
      end
    end
    return -1
  end

# This method is called whenever a Pokémon's HP changes.
# Used to animate the HP bar.
  def pbHPChanged(pkmn,oldhp,anim=false)
    hpchange=pkmn.hp-oldhp
    if hpchange<0
      hpchange=-hpchange
      PBDebug.log("[#{pkmn.pbThis} lost #{hpchange} HP, now has #{pkmn.hp} HP]")
    else
      PBDebug.log("[#{pkmn.pbThis} gained #{hpchange} HP, now has #{pkmn.hp} HP]")
    end
     pbRefresh
  end

# This method is called whenever a Pokémon faints
  def pbFainted(pkmn)
  end

# This method is called whenever a Pokémon faints
  def pbFakeOutFainted(pkmn)
  end

  def pbChooseEnemyCommand(index)
    @battle.pbDefaultChooseEnemyCommand(index)
  end

# Use this method to choose a new Pokémon for the enemy
# The enemy's party is guaranteed to have at least one choosable member.
  def pbChooseNewEnemy(index,party)
    @battle.pbDefaultChooseNewEnemy(index,party)
  end

# This method is called when the player wins a wild Pokémon battle.
# This method can change the battle's music for example.
  def pbWildBattleSuccess
  end

# This method is called when the player wins a Trainer battle.
# This method can change the battle's music for example.
  def pbTrainerBattleSuccess
  end

  def pbEXPBar(battler,thispoke,startexp,endexp,tempexp1,tempexp2)
  end

  def pbLevelUp(battler,thispoke,oldtotalhp,oldattack,
                olddefense,oldspeed,oldspatk,oldspdef)
  end

  def pbBlitz(keys)
    return rand(30)
  end

  def pbChatter(attacker,opponent)
  end

  def pbShowOpponent(opp)
  end

  def pbHideOpponent
  end

  def pbRecall(battlerindex)
  end

  def pbDamageAnimation(pkmn,effectiveness)
  end

  def pbBattleArenaJudgment(b1,b2,r1,r2)
    PBDebug.log("[Judgment - #{b1.pbThis}:#{r1.inspect}, #{b2.pbThis}:#{r2.inspect}]")
  end

  def pbBattleArenaBattlers(b1,b2)
    PBDebug.log("[#{b1.pbThis} VS #{b2.pbThis}]")
  end

  def pbCommonAnimation(moveid,attacker,opponent,hitnum=0)
    if attacker
      if opponent
        PBDebug.log("[pbCommonAnimation #{moveid} (#{attacker.pbThis}, #{opponent.pbThis}]")
      else
        PBDebug.log("[pbCommonAnimation #{moveid} (#{attacker.pbThis}]")
      end
    else
      PBDebug.log("[pbCommonAnimation #{moveid}]")
    end
  end

  def pbAnimation(moveid,attacker,opponent,hitnum=0)
    if attacker
      if opponent
        PBDebug.log("[pbAnimation (#{attacker.pbThis}, #{opponent.pbThis}]")
      else
        PBDebug.log("[pbAnimation (#{attacker.pbThis}]")
      end
    else
      PBDebug.log("[pbAnimation]")
    end
  end
end