def pbRandomMove
  loop do
    if false
      move=rand(0xA6)+1
    else
      move=rand(PBMoves.maxValue)+1
      next if move>384 || (move == PBMoves::SKETCH) || (move == PBMoves::STRUGGLE)
    end
    return move if PBMoves.getName(move)!=""
  end
end

def addMove(moves,move,base)
  data=moveData(move)
  count=base+1
  if data.function==0 && data.basedamage<=40
    count=base
  end
  if (move == PBMoves::BUBBLE) ||
     (move == PBMoves::BUBBLEBEAM)
    count=0
    return
  end
  if data.basedamage<=30 ||
     (move == PBMoves::GROWL) ||
     (move == PBMoves::TAILWHIP) ||
     (move == PBMoves::LEER)
    count=base
  end
  if data.basedamage>=60 ||
     (move == PBMoves::REFLECT)||
     (move == PBMoves::LIGHTSCREEN) ||
     (move == PBMoves::SAFEGUARD) ||
     (move == PBMoves::SUBSTITUTE) ||
     (move == PBMoves::FAKEOUT)
    count=base+2
  end
  if data.basedamage>=80 && isConst?(data.type,PBTypes,:NORMAL)
    count=base+5
  end
  if data.basedamage>=80 && isConst?(data.type,PBTypes,:NORMAL)
    count=base+3
  end
  if (move == PBMoves::PROTECT) ||
     (move == PBMoves::DETECT) ||
     (move == PBMoves::TOXIC) ||
     (move == PBMoves::AERIALACE) ||
     (move == PBMoves::WILLOWISP) ||
     (move == PBMoves::SPORE) ||
     (move == PBMoves::THUNDERWAVE) ||
     (move == PBMoves::HYPNOSIS) ||
     (move == PBMoves::CONFUSERAY) ||
     (move == PBMoves::ENDURE) ||
     (move == PBMoves::SWORDSDANCE)
    count=base+3
  end
  if !moves.include?(move)
    count.times{moves.push(move)}
  end
end

$tmData          = nil
$legalMoves      = []
$legalMovesLevel = 0
$moveData        = []
$baseStatTotal   = []
$minimumLevel    = []
$babySpecies     = []
$evolutions      = []
$tmMoves         = nil
=begin
def pbGetLegalMoves2(species,maxlevel)
  moves=[]
  return moves if !species || species<=0
  # Generating move list
  movelist=[]
  for k in 0...$cache.pkmn_moves[species].length
    alevel=$cache.pkmn_moves[species][k][0]
    move=$cache.pkmn_moves[species][k][1]
    if alevel<=level
      movelist[movelist.length]=move
    end
  end
  $tmData=load_data("Data/tm.dat") if !$tmData
  if !$tmMoves
    $tmMoves=[]
    itemData=readItemList("Data/items.dat") if !itemData
    for i in 0...itemData.length
      next if !itemData[i]
      atk=itemData[i][8]
      next if !atk || atk==0
      next if !$tmData[atk]
      $tmMoves.push(atk)
    end
  end
  for atk in $tmMoves
    if $tmData[atk].include?(species)
      addMove(moves,atk,0)
    end
  end
  babyspecies=babySpecies(species)
  pbRgssOpen("Data/eggEmerald.dat","rb"){|f|
     f.pos=(babyspecies-1)*8
     offset=f.fgetdw
     length=f.fgetdw
     if length>0
       f.pos=offset
       i=0; loop do break unless i<length
         atk=f.fgetw
         addMove(moves,atk,2)
         i+=1
       end
     end
  }
  movedatas=[]
  for move in moves
    movedatas.push([move,moveData(move)])
  end
  # Delete less powerful moves
  deleteAll=proc{|a,item|
     while a.include?(item)
      a.delete(item)
    end
  }
  for move in moves
    md=moveData(move)
    for move2 in movedatas
      if md.function==0xA5 && move2[1].function==0 && md.type==move2[1].type &&
         md.basedamage>=move2[1].basedamage
        deleteAll.call(moves,move2[0])
      elsif md.function==move2[1].function && md.basedamage==0 &&
         md.accuracy>move2[1].accuracy
        # Supersonic vs. Confuse Ray, etc.
        deleteAll.call(moves,move2[0])
      elsif md.function==0x06 && move2[1].function==0x05
        deleteAll.call(moves,move2[0])
      elsif md.function==move2[1].function && md.basedamage!=0 && 
         md.type==move2[1].type &&
         (md.totalpp==15 || md.totalpp==10 || md.totalpp==move2[1].totalpp) && 
         (md.basedamage>move2[1].basedamage ||
         (md.basedamage==move2[1].basedamage && md.accuracy>move2[1].accuracy))
        # Surf, Flamethrower, Thunderbolt, etc.
        deleteAll.call(moves,move2[0])
      end
    end
  end
  return moves
end

def baseStatTotal(move)
  if !$baseStatTotal[move]
    $baseStatTotal[move]=pbBaseStatTotal(move)
  end
  return $baseStatTotal[move] 
end
=end
def babySpecies(move)
  if !$babySpecies[move]
    $babySpecies[move]=pbGetBabySpecies(move)
  end
  return $babySpecies[move] 
end

def minimumLevel(move)
  if !$minimumLevel[move]
    $minimumLevel[move]=pbGetMinimumLevel(move)
  end
  return $minimumLevel[move] 
end

def evolutions(move)
  if !$evolutions[move]
    $evolutions[move]=pbGetEvolvedFormData(move)
  end
  return $evolutions[move] 
end

def moveData(move)
  if !$moveData[move]
    $moveData[move]=PBMoveData.new(move)
  end
  return $moveData[move]
end

=begin
[3/10]
0-266 - 0-500
[106]
267-372 - 380-500
[95]
373-467 - 400-555 (nonlegendary)
468-563 - 400-555 (nonlegendary)
564-659 - 400-555 (nonlegendary)
660-755 - 400-555 (nonlegendary)
756-799 - 580-600 [legendary] (compat1==15 or compat2==15, genderbyte=255)
800-849 - 500-
850-881 - 580- 
=end



class BaseStatRestriction
  def initialize(mn,mx)
    @mn=mn;@mx=mx  
  end

  def isValid?(pkmn)
    bst=baseStatTotal(pkmn.species)
    return bst>=@mn && bst<=@mx
  end
end



class NonlegendaryRestriction
  def isValid?(pkmn)
    compat10=$cache.pkmn_dex[pkmn.species][:Abilities][0]
    compat11=$cache.pkmn_dex[pkmn.species][:Abilities][1]
    genderbyte=$cache.pkmn_dex[pkmn.species][:GenderRatio]
    return ((compat10!=15 && compat11!=15) || genderbyte!=255)
  end
end



class InverseRestriction
  def initialize(r)
    @r=r
  end

  def isValid?(pkmn)
    return !@r.isValid?(pkmn)
  end
end



def withRestr(rule,minbs,maxbs,legendary)
  ret=PokemonChallengeRules.new.addPokemonRule(BaseStatRestriction.new(minbs,maxbs))
  if legendary==0
    ret.addPokemonRule(NonlegendaryRestriction.new)  
  elsif legendary==1
    ret.addPokemonRule(InverseRestriction.new(NonlegendaryRestriction.new))
  end
  return ret
end

# The Pokemon list is already roughly arranged by rank from weakest to strongest
def pbArrangeByTier(pokemonlist,rule)
  tiers=[
         withRestr(rule,0,500,0),
         withRestr(rule,380,500,0),
         withRestr(rule,400,555,0),
         withRestr(rule,400,555,0),
         withRestr(rule,400,555,0),
         withRestr(rule,400,555,0),
         withRestr(rule,580,680,1),
         withRestr(rule,500,680,0),
         withRestr(rule,580,680,2)
  ]
  tierPokemon=[]
  for i in 0...tiers.length
    tierPokemon.push([])
  end
  for i in 0...pokemonlist.length
    next if !rule.ruleset.isPokemonValid?(pokemonlist[i])
    validtiers=[]
    for j in 0...tiers.length
      tier=tiers[j]
      if tier.ruleset.isPokemonValid?(pokemonlist[i])
        validtiers.push(j)
      end
    end
    if validtiers.length>0
      vt=validtiers.length*i/pokemonlist.length
      tierPokemon[validtiers[vt]].push(pokemonlist[i])
    end
  end
  # Now for each tier, sort the Pokemon in that tier
  ret=[]
  for i in 0...tiers.length
    tierPokemon[i].sort!{|a,b|
       bstA=baseStatTotal(a.species)
       bstB=baseStatTotal(b.species)
       if bstA==bstB
         a.species<=>b.species
       else
         bstA<=>bstB
       end
    }
    ret.concat(tierPokemon[i])
  end
  return ret
end

def hasMorePowerfulMove(moves,thismove)
  thisdata=moveData(thismove)
  return false if thisdata.basedamage==0
  for move in moves
    next if move==0
    if moveData(move).type==thisdata.type &&
       moveData(move).basedamage>thisdata.basedamage
      return true 
    end
  end
  return false
end

def pbRandomPokemonFromRule(rule,trainer)
  pkmn=nil
  i=0
  iteration=-1
  begin
    iteration+=1
    species=0
    level=rule.ruleset.suggestedLevel
    loop do
      species=0
      loop do
        species=rand(PBSpecies.maxValue)+1
        cname=getConstantName(PBSpecies,species) rescue nil
        break if cname
      end
      r=rand(20)
      bst=baseStatTotal(species)
      next if level<minimumLevel(species)
      if iteration%2==0
        if r<16 && bst<400
          next
        end
        if r<13 && bst<500
          next
        end
      else
        if bst>400
          next
        end 
        if r<10 && babySpecies(species)!=species
          next
        end      
      end
      if r<10 && babySpecies(species)==species
        next
      end
      if r<7 && evolutions(species).length>0
        next
      end
      break
    end
    ev=rand(0x3F)+1
    nature=0
    loop do
      nature=rand(25)
      nd5=(nature/5).floor # stat to increase
      nm5=(nature%5).floor # stat to decrease
      if nd5==nm5 || nature==PBNatures::LAX || nature==PBNatures::GENTLE
        # Neutral nature, Lax, or Gentle
        next if rand(20)<19
      else
        if ((ev>>(1+nd5))&1)==0
          # If stat to increase isn't emphasized
          next if rand(10)<6
        end
        if ((ev>>(1+nm5))&1)!=0
          # If stat to decrease is emphasized
          next if rand(10)<9
        end
      end
      break
    end
    item=0
    if level!=$legalMovesLevel
      $legalMoves=[]
    end
    if !$legalMoves[species]
      $legalMoves[species]=pbGetLegalMoves2(species,level)
    end
    itemlist=[
       :ORANBERRY,:SITRUSBERRY,:ADAMANTORB,:BABIRIBERRY,
       :BLACKSLUDGE,:BRIGHTPOWDER,:CHESTOBERRY,:CHOICEBAND,
       :CHOICESCARF,:CHOICESPECS,:CHOPLEBERRY,:DAMPROCK,
       :DEEPSEATOOTH,:EXPERTBELT,:FLAMEORB,:FOCUSSASH,
       :FOCUSBAND,:HEATROCK,:LEFTOVERS,:LIFEORB,:LIGHTBALL,
       :LIGHTCLAY,:LUMBERRY,:OCCABERRY,:PETAYABERRY,:SALACBERRY,
       :SCOPELENS,:SHEDSHELL,:SHELLBELL,:SHUCABERRY,:LIECHIBERRY,
       :SILKSCARF,:THICKCLUB,:TOXICORB,:WIDELENS,:YACHEBERRY,
       :HABANBERRY,:SOULDEW,:PASSHOBERRY,:QUICKCLAW,:WHITEHERB
    ]
    # Most used: Leftovers, Life Orb, Choice Band, Choice Scarf, Focus Sash
    loop do
      if rand(40)==0
        item=PBItems::LEFTOVERS
        break
      end
      itemsym=itemlist[rand(itemlist.length)]
      item=getID(PBItems,itemsym)
      next if item==0
      if itemsym==:LIGHTBALL
        next if (species != PBSpecies::PIKACHU)
      end
      if itemsym==:SHEDSHELL
        next if (species != PBSpecies::FORRETRESS) ||
                (species != PBSpecies::SKARMORY)
      end
      if itemsym==:SOULDEW
        next if (species != PBSpecies::LATIOS) ||
                (species != PBSpecies::LATIAS)
      end
      if itemsym==:LIECHIBERRY && (ev&0x02)==0
        if rand(2)==0
          next
        else
          ev|=0x02
        end
      end
      if itemsym==:FOCUSSASH
        next if baseStatTotal(species)>450 && rand(10)<8
      end
      if itemsym==:ADAMANTORB
        next if (species != PBSpecies::DIALGA)
      end
      if itemsym==:PASSHOBERRY
        next if (species != PBSpecies::STEELIX)
      end
      if itemsym==:BABIRIBERRY 
        next if (species != PBSpecies::TYRANITAR)
      end
      if itemsym==:HABANBERRY
        next if (species != PBSpecies::GARCHOMP)
      end
      if itemsym==:OCCABERRY
        next if (species != PBSpecies::METAGROSS)
      end
      if itemsym==:CHOPLEBERRY
        next if (species != PBSpecies::UMBREON)
      end
      if itemsym==:YACHEBERRY
        next if (species != PBSpecies::TORTERRA) &&
                (species != PBSpecies::GLISCOR) &&
                (species != PBSpecies::DRAGONAIR)
      end
      if itemsym==:SHUCABERRY
        next if (species != PBSpecies::HEATRAN)
      end
      if itemsym==:SALACBERRY && (ev&0x08)==0
        if rand(2)==0
          next
        else
          ev|=0x08
        end
      end
      if itemsym==:PETAYABERRY && (ev&0x10)==0
        if rand(2)==0
          next
        else
          ev|=0x10
        end
      end
      if itemsym==(:DEEPSEATOOTH)
        next if (species != PBSpecies::CLAMPERL)
      end
      if itemsym==(:THICKCLUB)
        next if (species != PBSpecies::CUBONE) && 
                (species != PBSpecies::MAROWAK)
      end
      break
    end
    if level<10
      item=(PBItems::ORANBERRY || item) if rand(40)==0 || 
            (item == PBItems::SITRUSBERRY)
    end
    if level>20
      item=(PBItems::SITRUSBERRY || item) if rand(40)==0 ||   
            (item == PBItems::ORANBERRY)
    end
    moves=$legalMoves[species]
    sketch=false
    if isConst?(moves[0],PBMoves,:SKETCH)
      sketch=true
      moves[0]=pbRandomMove
      moves[1]=pbRandomMove
      moves[2]=pbRandomMove
      moves[3]=pbRandomMove  
    end
    next if moves.length==0
    if (moves|[]).length<4
      moves=[PBMoves::TACKLE] if moves.length==0
      moves|=[]
    else
      newmoves=[]
      rest=(PBMoves::REST || -1)
      spitup=(PBMoves::SPITUP || -1)
      swallow=(PBMoves::SWALLOW || -1)
      stockpile=(PBMoves::STOCKPILE || -1)
      snore=(PBMoves::SNORE || -1)
      sleeptalk=(PBMoves::SLEEPTALK || -1)
      loop do
        newmoves.clear
        while newmoves.length<4
          m=moves[rand(moves.length)]
          if rand(2)==0 && hasMorePowerfulMove(moves,m)
            next
          end
          if !newmoves.include?(m) && m!=0
            newmoves.push(m)
          end
        end
        if (newmoves.include?(spitup) ||
           newmoves.include?(swallow)) && !newmoves.include?(stockpile)
          next unless sketch
        end
        if (!newmoves.include?(spitup) && !newmoves.include?(swallow)) &&
           newmoves.include?(stockpile)
          next unless sketch
        end
        if newmoves.include?(sleeptalk) && !newmoves.include?(rest)
          next unless (sketch || !moves.include?(rest)) && rand(10)<2
        end
        if newmoves.include?(snore) && !newmoves.include?(rest)
          next unless (sketch || !moves.include?(rest)) && rand(10)<2
        end
        totalbasedamage=0
        hasPhysical=false
        hasSpecial=false
        hasNormal=false
        for move in newmoves
          d=moveData(move)
          totalbasedamage+=d.basedamage
          if d.basedamage>=1
            hasNormal=true if isConst?(d.type,PBTypes,:NORMAL)
            hasPhysical=true if d.category==0
            hasSpecial=true if d.category==1
          end
        end
        if !hasPhysical && (ev&0x02)!=0 
          # No physical attack, but emphasizes Attack
          next if rand(10)<8
        end
        if !hasSpecial && (ev&0x10)!=0
          # No special attack, but emphasizes Special Attack
          next if rand(10)<8
        end
        r=rand(10)
        next if r>6 && totalbasedamage>180
        next if r>8 && totalbasedamage>140
        next if totalbasedamage==0 && rand(20)!=0
        ############
        # Moves accepted
        if hasPhysical && !hasSpecial
          ev&=~0x10 if rand(10)<8 # Deemphasize Special Attack
          ev|=0x02 if rand(10)<8 # Emphasize Attack
        end
        if !hasPhysical && hasSpecial
          ev|=0x10 if rand(10)<8 # Emphasize Special Attack
          ev&=~0x02 if rand(10)<8 # Deemphasize Attack
        end
        if !hasNormal && (item == PBItems::SILKSCARF)
          item=PBItems::LEFTOVERS
        end
        moves=newmoves
        break
      end
    end
    for i in 0...4
      moves[i]=0 if !moves[i]  
    end
    if (item == PBItems::LIGHTCLAY) &&
       !moves.include?((PBMoves::LIGHTSCREEN || -1)) &&
       !moves.include?((PBMoves::REFLECT || -1))
      item=PBItems::LEFTOVERS
    end
    if (item == PBItems::BLACKSLUDGE)
      if !isConst?($cache.pkmn_dex[species][:Type1],PBTypes,:POISON) && !isConst?($cache.pkmn_dex[species][4],PBTypes,:POISON)
        item=PBItems::LEFTOVERS
      end
    end
    if (item == PBItems::HEATROCK) &&
       !moves.include?((PBMoves::SUNNYDAY || -1))
      item=PBItems::LEFTOVERS
    end
    if (item == PBItems::DAMPROCK) &&
       !moves.include?((PBMoves::RAINDANCE || -1))
      item=PBItems::LEFTOVERS
    end
    if moves.include?((PBMoves::REST || -1))
       item=PBItems::LUMBERRY if rand(3)==0
       item=PBItems::CHESTOBERRY if rand(4)==0
    end
    pk=PBPokemon.new(species,item,nature,moves[0],moves[1],moves[2],moves[3],ev)
    pkmn=pk.createPokemon(level,31,trainer)
    i+=1
  end while !rule.ruleset.isPokemonValid?(pkmn)
  return pkmn
end



class SingleMatch
  attr_reader :opponentRating
  attr_reader :opponentDeviation
  attr_reader :score
  attr_reader :kValue

  def initialize(opponentRating,opponentDev,score,kValue=16)
    @opponentRating=opponentRating
    @opponentDeviation=opponentDev
    @score=score # -1=draw, 0=lose, 1=win
    @kValue=kValue
  end
end



class MatchHistory
  include Enumerable

  def each
    @matches.each{|item| yield item }
  end

  def length
    @matches.length
  end

  def [](i)
    @matches[i]
  end

  def initialize(thisPlayer)
    @matches=[]
    @thisPlayer=thisPlayer
  end

  def addMatch(otherPlayer,result)
    # 1=I won; 0=Other player won; -1: Draw
    @matches.push(SingleMatch.new(
       otherPlayer.rating,otherPlayer.deviation,result))
  end

  def updateAndClear()
    @thisPlayer.update(@matches)
    @matches.clear
  end
end



class PlayerRatingElo
  attr_reader :rating
  K_VALUE = 16

  def initialize
    @rating=1600.0 
    @deviation=0
    @volatility=0
    @estimatedRating=nil
  end

  def winChancePercent
    return @estimatedRating if @estimatedRating
    x=(1+10.0**((@rating-1600.0)/400.0))
    @estimatedRating=(x==0 ? 1.0 : 1.0/x)
    return @estimatedRating
  end

  def update(matches)
    if matches.length == 0
      return
    end
    stake=0
    for i in 0...matches.length
      score=(match.score==-1) ? 0.5 : match.score
      e=(1+10.0**((@rating-match.opponentRating)/400.0))
      stake+=match.kValue*(score-e)
    end
    @rating+=stake
  end
end



class PlayerRating
  attr_reader :volatility
  attr_reader :deviation
  attr_reader :rating

  def initialize
    @rating=1500.0
    @deviation=350.0
    @volatility=0.9
    @estimatedRating=nil
  end

  def winChancePercent
    return @estimatedRating if @estimatedRating
    if (@deviation > 100)
      # http://www.smogon.com/forums/showthread.php?t=55764
      otherRating=1500.0
      otherDeviation=350.0
      s=Math.sqrt(100000.0+@deviation*@deviation+otherDeviation*otherDeviation)
      g=10.0**((otherRating-@rating)*0.79/s)
      @estimatedRating=(1.0/(1.0+g))*100.0 # Percent chance that I win against opponent
    else
      # GLIXARE method
      rds = @deviation * @deviation;
      sqr = Math.sqrt(15.905694331435 * (rds + 221781.21786254));
      inner = (1500.0 - @rating) * Math::PI / sqr;
      @estimatedRating=(10000.0 / (1.0 + (10.0**inner)) + 0.5) / 100.0;
    end
    return @estimatedRating
  end

  def update(matches,system=1.2)
    volatility = volatility2
    deviation = deviation2
    rating = rating2;
    if matches.length == 0
      setDeviation2(Math.sqrt(deviation * deviation + volatility * volatility))
      return
    end
    g=[]
    e=[]
    score=[]
    for i in 0...matches.length
      match = matches[i]
      g[i] = getGFactor(match.opponentDeviation)
      e[i] = getEFactor(rating,match.opponentRating, g[i])
      score[i] = match.score
    end
    # Estimated variance
    variance = 0.0
    for i in 0...matches.length
      variance += g[i]*g[i]*e[i]*(1-e[i])
    end
    variance=1.0/variance
    # Improvement sum
    sum = 0.0
    for i in 0...matches.length
      v = score[i]
      if (v != -1)
        sum += g[i]*(v.to_f-e[i])
      end
    end
    volatility = getUpdatedVolatility(volatility,deviation,variance,sum,system)
    # Update deviation
    t = deviation * deviation + volatility * volatility
    deviation = 1.0 / Math.sqrt(1.0 / t + 1.0 / variance)
    # Update rating
    rating = rating + deviation * deviation * sum
    setRating2(rating)
    setDeviation2(deviation)
    setVolatility2(volatility)
  end

  private

  attr_writer :volatility

  def rating2
    return (@rating-1500.0)/173.7178
  end

  def deviation2
    return (@deviation)/173.7178
  end

  def getGFactor(deviation)
    # deviation is not yet in glicko2
    deviation/=173.7178
    return 1.0 / Math.sqrt(1.0 + (3.0*deviation*deviation) / (Math::PI*Math::PI))
  end

  def getEFactor(rating,opponentRating, g)
    # rating is already in glicko2
    # opponentRating is not yet in glicko2
    opponentRating=(opponentRating-1500.0)/173.7178
    return 1.0 / (1.0 + Math.exp(-g * (rating - opponentRating)));
  end

  alias volatility2 volatility

  def setVolatility2(value)
    @volatility=value
  end

  def setRating2(value)
    @estimatedRating=nil
    @rating=(value*173.7178)+1500.0
  end

  def setDeviation2(value)
    @estimatedRating=nil
    @deviation=(value*173.7178)
  end

  def getUpdatedVolatility(volatility, deviation, variance,improvementSum, system)
    improvement = improvementSum * variance
    a = Math.log(volatility * volatility)
    squSystem = system * system
    squDeviation = deviation * deviation
    squVariance = variance + variance
    squDevplusVar = squDeviation + variance
    x0 = a
    100.times { # Up to 100 iterations to avoid potentially infinite loops
       e = Math.exp(x0)
       d = squDevplusVar + e
       squD = d * d
       i = improvement / d
       h1 = -(x0 - a) / squSystem - 0.5 * e * i * i
       h2 = -1.0 / squSystem - 0.5 * e * squDevplusVar / squD
       h2 += 0.5 * squVariance * e * (squDevplusVar - e) / (squD * d)
       x1 = x0
       x0 -= h1 / h2
       if ((x1 - x0).abs < 0.000001)
         break
       end
    }
    return Math.exp(x0 / 2.0)
  end
end




class RuledTeam
  def rating
    @rating.winChancePercent
  end

  def ratingRaw
    [@rating.rating,@rating.deviation,@rating.volatility,@rating.winChancePercent]
  end

  def ratingData
    @rating
  end

  def totalGames
    (@totalGames||0)+self.games
  end

  def updateRating
    @totalGames=0 if !@totalGames
    oldgames=self.games
    @history.updateAndClear()
    newgames=self.games
    @totalGames+=(oldgames-newgames)
  end

  def compare(other)
    @rating.compare(other.ratingData)
  end

  def addMatch(other,score)
    @history.addMatch(other.ratingData,score)
  end

  def games
    @history.length
  end

  attr_accessor :team

  def initialize(party,rule)
    count=rule.ruleset.suggestedNumber
    @team=[]
    retnum=[]
    loop do
      for i in 0...count
        retnum[i]=rand(party.length)
        @team[i]=party[retnum[i]]
        party.delete_at(retnum[i])
      end
      break if rule.ruleset.isValid?(@team)
    end
    @totalGames=0
    @rating=PlayerRating.new
    @history=MatchHistory.new(@rating)
  end

  def [](i)
    @team[i]
  end

  def toStr
    return "["+@rating.to_i.to_s+","+@games.to_i.to_s+"]"
  end

  def length
    return @team.length
  end

  def load(party)
    ret=[]
    for i in 0...team.length
      ret.push(party[team[i]])
    end
    return ret
  end
end



def pbDecideWinnerEffectiveness(move,otype1,otype2,ability,scores)
  data=moveData(move)
  return 0 if data.basedamage==0
  atype=data.type
  typemod=4
  if (ability == PBAbilities::LEVITATE) && 
     isConst?(data.type,PBTypes,:GROUND)
    typemod=4
  else
    mod1=PBTypes.getEffectiveness(atype,otype1)
    mod2=(otype1==otype2) ? 2 : PBTypes.getEffectiveness(atype,otype2)
    if((ability == PBAbilities::WONDERGUARD))
      mod1=2 if mod1!=4
      mod2=2 if mod2!=4
    end
    typemod=mod1*mod2
  end
  return scores[0] if typemod==0
  return scores[1] if typemod==1
  return scores[2] if typemod==2
  return scores[3] if typemod==4
  return scores[4] if typemod==8
  return scores[5] if typemod==16
  return 0
end

def pbDecideWinnerScore(party0,party1,rating)
  score=0
  types1=[]
  types2=[]
  abilities=[]
  for j in 0...party1.length
    types1.push(party1[j].type1)
    types2.push(party1[j].type2)
    abilities.push(party1[j].ability)
  end
  for i in 0...party0.length
    for move in party0[i].moves
      next if move.id==0
      for j in 0...party1.length
        score+=pbDecideWinnerEffectiveness(move.id,
           types1[j],types2[j],abilities[j],[-16,-8,0,4,12,20])
      end
    end
    basestatsum=baseStatTotal(party0[i].species)
    score+=basestatsum/10
    score+=10 if party0[i].item!=0 # Not in Battle Dome ranking
  end
  score+=rating+rand(32)
  return score
end

def pbDecideWinner(party0,party1,rating0,rating1)
  rating0=(rating0*15.0/100).round 
  rating1=(rating1*15.0/100).round
  score0=pbDecideWinnerScore(party0,party1,rating0)
  score1=pbDecideWinnerScore(party1,party0,rating1)
  if score0==score1
    return 5 if rating0==rating1
    return (rating0>rating1) ? 1 : 2
  else
    return (score0>score1) ? 1 : 2
  end
end

def pbRuledBattle(team1,team2,rule)
  decision=0
  if rand(100)!=0
    party1=[]
    party2=[]
    team1.length.times {|i| party1.push(team1[i]) }
    team2.length.times {|i| party2.push(team2[i]) }
    decision=pbDecideWinner(party1,party2,team1.rating,team2.rating)
  else
    scene=PokeBattle_DebugSceneNoLogging.new
    trainer1=PokeBattle_Trainer.new("PLAYER1",1)
    trainer2=PokeBattle_Trainer.new("PLAYER2",1)
    items1=[]
    items2=[]
    level=rule.ruleset.suggestedLevel
    team1.length.times {|i|
       p=team1[i]
       if p.level!=level
         p.level=level
         p.calcStats
       end
       items1.push(p.item)
       trainer1.party.push(p)
    }
    team2.length.times {|i|
       p=team2[i]
       if p.level!=level
         p.level=level
         p.calcStats
       end
       items2.push(p.item)
       trainer2.party.push(p)
    }
    battle=rule.createBattle(scene,trainer1,trainer2)
    battle.debug=true
    battle.controlPlayer=true
    battle.endspeech="..."
    battle.internalbattle=false
    decision=battle.pbStartBattle
    #p [items1,items2]
    team1.length.times {|i|
       p=team1[i]
       p.heal
       p.setItem(items1[i])
    }
    team2.length.times {|i|
       p=team2[i]
       p.heal
       p.setItem(items2[i])
    }
  end
  if decision==1 # Team 1 wins
    team1.addMatch(team2,1)
    team2.addMatch(team1,0)
  elsif decision==2 # Team 2 wins
    team1.addMatch(team2,0)
    team2.addMatch(team1,1)
  else
    team1.addMatch(team2,-1)
    team2.addMatch(team1,-1)
  end
end

def getTypes(species)
  type1=$cache.pkmn_dex[species][:Type1]
  type2=$cache.pkmn_dex[species][:Type2]
  return type1==type2 ? [type1] : [type1,type2]
end

def pbTrainerInfo(pokemonlist,trfile,rules)
  bttrainers=pbGetBTTrainers(trfile)
  btpokemon=pbGetBTPokemon(trfile)
  trainertypes=$cache.trainertypes
  if bttrainers.length==0
    for i in 0...200
      yield(nil) if block_given? && i%50==0
      trainerid=0
      money=30
      loop do
        trainerid=rand(PBTrainers.maxValue)+1
        trainerid=getID(PBTrainers,:YOUNGSTER) if rand(30)==0
        next if PBTrainers.getName(trainerid)==""
        money=(!trainertypes[trainerid] ||
               !trainertypes[trainerid][3]) ? 30 : trainertypes[trainerid][3]
        next if money>=100
        break
      end
      gender=(!trainertypes[trainerid] ||
              !trainertypes[trainerid][7]) ? 2 : trainertypes[trainerid][7]
      randomName=getRandomNameEx(gender,nil,0,12)
      tr=[trainerid,randomName,_INTL("Here I come!"),
          _INTL("Yes, I won!"),_INTL("Man, I lost!"),[]]
      bttrainers.push(tr)
    end
    bttrainers.sort!{|a,b|
       money1=(!trainertypes[a[0]] ||
               !trainertypes[a[0]][3]) ? 30 : trainertypes[a[0]][3]
       money2=(!trainertypes[b[0]] ||
               !trainertypes[b[0]][3]) ? 30 : trainertypes[b[0]][3]
       money1==money2 ? a[0]<=>b[0] : money1<=>money2
    }
  end
  yield(nil) if block_given?
  suggestedLevel=rules.ruleset.suggestedLevel
  rulesetTeam=rules.ruleset.copy.clearPokemonRules
  pkmntypes=[]
  validities=[]
  t=Time.new
  for pkmn in pokemonlist
    pkmn.level=suggestedLevel if pkmn.level!=suggestedLevel
    pkmntypes.push(getTypes(pkmn.species))
    validities.push(rules.ruleset.isPokemonValid?(pkmn))
  end
  newbttrainers=[]
  for btt in 0...bttrainers.length
    yield(nil) if block_given? && btt%50==0
    trainerdata=bttrainers[btt]
    pokemonnumbers=trainerdata[5] || []
    species=[]
    types=[]
    #p trainerdata[1]
    (PBTypes.maxValue+1).times {|typ| types[typ]=0 }
    for pn in pokemonnumbers
      pkmn=btpokemon[pn]
      species.push(pkmn.species)
      t=getTypes(pkmn.species)
      t.each{|typ|
         types[typ]+=1
      }
    end
    species|=[] # remove duplicates
    count=0
    (PBTypes.maxValue+1).times {|typ| 
       if types[typ]>=5
         types[typ]/=4
         types[typ]=10 if types[typ]>10
       else
         types[typ]=0
       end
       count+=types[typ]
    }
    types[0]=1 if count==0
    if pokemonnumbers.length==0
      (PBTypes.maxValue+1).times {|typ|
         types[typ]=1
      }
    end
    numbers=[]
    if pokemonlist
      numbersPokemon=[]
      # p species
      for index in 0...pokemonlist.length
        pkmn=pokemonlist[index]
        next if !validities[index]
        absDiff=((index*8/pokemonlist.length)-(btt*8/bttrainers.length)).abs
        sameDiff=(absDiff==0)
        if species.include?(pkmn.species)
          weight=[32,12,5,2,1,0,0,0][[absDiff,7].min]
          if rand(40)<weight
            numbers.push(index)
            numbersPokemon.push(pokemonlist[index])
          end
        else
          t=pkmntypes[index]
          t.each{|typ|
             weight=[32,12,5,2,1,0,0,0][[absDiff,7].min]
             weight*=types[typ]
             if rand(40)<weight
               numbers.push(index)
               numbersPokemon.push(pokemonlist[index])
             end
          }
        end
      end
      numbers|=[]
      if (numbers.length<6 || 
         !rulesetTeam.hasValidTeam?(numbersPokemon))
        for index in 0...pokemonlist.length
          pkmn=pokemonlist[index]
          next if !validities[index]
          if species.include?(pkmn.species)
            numbers.push(index)
            numbersPokemon.push(pokemonlist[index])
          else
            t=pkmntypes[index]
            t.each{|typ|
               if types[typ]>0 && !numbers.include?(index)
                 numbers.push(index)
                 numbersPokemon.push(pokemonlist[index])
                 break
               end
            }
          end
          break if numbers.length>=6 && rules.ruleset.hasValidTeam?(numbersPokemon)
        end
        if numbers.length<6 || !rules.ruleset.hasValidTeam?(numbersPokemon)
          while numbers.length<pokemonlist.length &&
             (numbers.length<6 || !rules.ruleset.hasValidTeam?(numbersPokemon))
            index=rand(pokemonlist.length)
            if !numbers.include?(index)
              numbers.push(index)
              numbersPokemon.push(pokemonlist[index])
            end
          end
        end
      end
      numbers.sort!
    end
    newbttrainers.push([trainerdata[0],trainerdata[1],trainerdata[2],
                        trainerdata[3],trainerdata[4],numbers])  
  end
  yield(nil) if block_given?
  pbpokemonlist=[]
  for pkmn in pokemonlist
    pbpokemonlist.push(PBPokemon.fromPokemon(pkmn))
  end
  trlists=(load_data("Data/trainerlists.dat") rescue [])
  hasDefault=false
  trIndex=-1
  for i in 0...trlists.length
    hasDefault=true if trlists[i][5]
  end
  for i in 0...trlists.length
    if trlists[i][2].include?(trfile)
      trIndex=i
      trlists[i][0]=newbttrainers
      trlists[i][1]=pbpokemonlist
      trlists[i][5]=!hasDefault
    end
  end
  yield(nil) if block_given?
  if trIndex<0
    info=[newbttrainers,pbpokemonlist,[trfile],
          trfile+"tr.txt",trfile+"pm.txt",!hasDefault]
    trlists.push(info)
  end
  yield(nil) if block_given?
  save_data(trlists,"Data/trainerlists.dat")
  yield(nil) if block_given?
  pbSaveTrainerLists()
  yield(nil) if block_given?
end



if $FAKERGSS

def Kernel.pbMessageDisplay(mw,txt,lbl)
  puts txt
end

def _INTL(*arg)
  return arg[0]
end

def _ISPRINTF(*arg)
  return arg[0]
end

end



def isBattlePokemonDuplicate(pk,pk2)
  if pk.species==pk2.species
    moves1=[]
    moves2=[]
    4.times{ 
       moves1.push(pk.moves[0].id)
       moves2.push(pk.moves[1].id)
    }
    moves1.sort!
    moves2.sort!
    if moves1[0]==moves2[0] &&
       moves1[1]==moves2[1] &&
       moves1[2]==moves2[2] &&
       moves1[3]==moves2[3]
      # Accept as same if moves are same and there are four moves each
      return true if moves1[3]!=0
    end
    return true if pk.item==pk2.item &&
                   pk.nature==pk2.nature &&
                   pk.ev[0]==pk2.ev[0] &&
                   pk.ev[1]==pk2.ev[1] &&
                   pk.ev[2]==pk2.ev[2] &&
                   pk.ev[3]==pk2.ev[3] &&
                   pk.ev[4]==pk2.ev[4] &&
                   pk.ev[5]==pk2.ev[5]
    return false
  end      
end

def pbRemoveDuplicates(party)
  #p "before: #{party.length}"
  ret=[]
  for pk in party
    found=false
    count=0
    firstIndex=-1
    for i in 0...ret.length
      pk2=ret[i]
      if isBattlePokemonDuplicate(pk,pk2)
        found=true; break
      end
      if pk.species==pk2.species
        firstIndex=i if count==0
        count+=1
      end
    end
    if !found
      if count>=10
       ret.delete_at(firstIndex)
      end
      ret.push(pk)
    end
  end
  return ret
end

def pbReplenishBattlePokemon(party,rule)
  while party.length<20
    pkmn=pbRandomPokemonFromRule(rule,nil)
    found=false
    for pk in party
      if isBattlePokemonDuplicate(pkmn,pk)
        found=true; break
      end
    end
    party.push(pkmn) if !found
  end
end

def pbGenerateChallenge(rule,tag)
  oldrule=rule
  yield(_INTL("Preparing to generate teams"))
  rule=rule.copy.setNumber(2)
  yield(nil)
  party=load_data(tag+".rxdata") rescue []
  teams=load_data(tag+"teams.rxdata") rescue []
  if teams.length<10
    btpokemon=pbGetBTPokemon(tag)
    if btpokemon && btpokemon.length!=0
      suggestedLevel=rule.ruleset.suggestedLevel
      for pk in btpokemon
        pkmn=pk.createPokemon(suggestedLevel,31,nil)
        party.push(pkmn) if rule.ruleset.isPokemonValid?(pkmn)
      end
    end
  end
  yield(nil)
  party=pbRemoveDuplicates(party)
  yield(nil)
  maxteams=600
  cutoffrating=65
  toolowrating=40
  iterations=11
  iterations.times do |iter|
    save_data(party,tag+".rxdata")
    yield(_INTL("Generating teams ({1} of {2})",iter+1,iterations))
    i=0;while i<teams.length
      yield(nil) if i%10==0
      pbReplenishBattlePokemon(party,rule)
      if teams[i].rating<cutoffrating && teams[i].totalGames>=80
        teams[i]=RuledTeam.new(party,rule)
      elsif teams[i].length<2
        teams[i]=RuledTeam.new(party,rule)
      elsif i>=maxteams
        teams[i]=nil
        teams.compact!
      elsif teams[i].totalGames>=250
        # retire
        for j in 0...teams[i].length
          party.push(teams[i][j])
        end
        teams[i]=RuledTeam.new(party,rule)
      elsif teams[i].rating<toolowrating
        teams[i]=RuledTeam.new(party,rule)
      end
      i+=1
    end
    save_data(teams,tag+"teams.rxdata")
    yield(nil)
    while teams.length<maxteams
      yield(nil) if teams.length%10==0
      pbReplenishBattlePokemon(party,rule)
      teams.push(RuledTeam.new(party,rule))
    end
    save_data(party,tag+".rxdata")
    teams=teams.sort{|a,b| b.rating<=>a.rating }
    yield(_INTL("Simulating battles ({1} of {2})",iter+1,iterations))
    i=0; loop do
      changed=false
      teams.length.times {|j|
         yield(nil)
         other=j;5.times do
           other=rand(teams.length)
           next if other==j
         end
         next if other==j
         changed=true
         pbRuledBattle(teams[j],teams[other],rule)
      }
      # i+=1;break if i>=5
      i+=1
      gameCount=0
      for team in teams
        gameCount+=team.games
      end
      #p [gameCount,teams.length,gameCount/teams.length]
      yield(nil)
      if (gameCount/teams.length)>=12
        #p "Iterations: #{i}"
        for team in teams
          games=team.games
          team.updateRating
          #p [games,team.totalGames,team.ratingRaw] if $INTERNAL
        end
        #p [gameCount,teams.length,gameCount/teams.length]
        break
      end
    end
    teams.sort!{|a,b| b.rating<=>a.rating }
    save_data(teams,tag+"teams.rxdata")
  end
  party=[]
  yield(nil)
  teams.sort{|a,b| a.rating<=>b.rating }
  for team in teams
    if team.rating>cutoffrating
      for i in 0...team.length
        party.push(team[i])
      end
    end
  end
  rule=oldrule
  yield(nil)
  party=pbRemoveDuplicates(party)
  yield(_INTL("Writing results"))
  party=pbArrangeByTier(party,rule)
  yield(nil)
  pbTrainerInfo(party,tag,rule) { yield(nil) }
  yield(nil)
end

def pbWriteCup(id,rules)
  return if !$DEBUG
  return #as if we ever use this. an annoyed perry who doesn't care about this message every time he plays
  bttrainers=[]
  trlists=(load_data("Data/trainerlists.dat") rescue [])
  list=[]
  for i in 0...trlists.length
    tr=trlists[i]
    if tr[5]
      list.push("*"+(tr[3].sub(/\.txt$/,"")))
    else
      list.push((tr[3].sub(/\.txt$/,"")))
    end
  end
  cmd=0
  if trlists.length!=0
    cmd=Kernel.pbMessage(_INTL("Generate Pokemon teams for this challenge?"),
       [_INTL("NO"),_INTL("YES, USE EXISTING"),_INTL("YES, USE NEW")],1)
  else
    cmd=Kernel.pbMessage(_INTL("Generate Pokemon teams for this challenge?"),
       [_INTL("YES"),_INTL("NO")],2)
    if cmd==0
      cmd=2
    elsif cmd==1
      cmd=0
    end 
  end
  return if cmd==0   # No
  if cmd==1   # Yes, use existing
    cmd=Kernel.pbMessage(_INTL("Choose a challenge."),list,-1)
    if cmd>=0
      Kernel.pbMessage(_INTL("This challenge will use the Pokemon list from {1}.",list[cmd]))
      for i in 0...trlists.length
        tr=trlists[i]
        while !tr[5] && tr[2].include?(id)
          tr[2].delete(id)
        end
      end
      if !trlists[cmd][5]
        trlists[cmd][2].push(id)
      end
      save_data(trlists,"Data/trainerlists.dat")
      Graphics.update
      pbSaveTrainerLists()
      Graphics.update
      return
    else
      return
    end
  # Yes, use new
  elsif cmd==2 && !Kernel.pbConfirmMessage(_INTL("This may take a long time. Are you sure?"))
    return
  end
  mw=Kernel.pbCreateMessageWindow
  t=Time.now
  pbGenerateChallenge(rules,id){|message|
     if (Time.now-t)>=5
       Graphics.update; t=Time.now
     end
     if message
       Kernel.pbMessageDisplay(mw,message,false)
       Graphics.update; t=Time.now
     end
  }
  Kernel.pbDisposeMessageWindow(mw)
  Kernel.pbMessage(_INTL("Team generation complete."))
end