class PBMoveData
  attr_reader :function,:basedamage,:type,:accuracy
  attr_reader :totalpp,:addlEffect,:target,:priority
  attr_reader :flags
  attr_reader :contestType,:category

FUNCTION    =0
BASEDAMAGE  =1
TYPE        =2
CATEGORY    =3
ACCURACY    =4
TOTALPP     =5
ADDLEFFECT  =6
TARGET      =7
PRIORITY    =8
FLAGS       =9

  def initialize(moveid)
    if moveid == 0
      @function    = 0
      @basedamage  = 0
      @type        = 0
      @category    = 0
      @accuracy    = 0
      @totalpp     = 0
      @addlEffect  = 0
      @target      = 0
      @priority    = 0
      @flags       = 0
      return
    end
    @function    = $cache.pkmn_move[moveid][PBMoveData::FUNCTION]
    @basedamage  = $cache.pkmn_move[moveid][PBMoveData::BASEDAMAGE]
    @type        = $cache.pkmn_move[moveid][PBMoveData::TYPE]
    @category    = $cache.pkmn_move[moveid][PBMoveData::CATEGORY]
    @accuracy    = $cache.pkmn_move[moveid][PBMoveData::ACCURACY]
    @totalpp     = $cache.pkmn_move[moveid][PBMoveData::TOTALPP]
    @addlEffect  = $cache.pkmn_move[moveid][PBMoveData::ADDLEFFECT]
    @target      = $cache.pkmn_move[moveid][PBMoveData::TARGET]
    @priority    = $cache.pkmn_move[moveid][PBMoveData::PRIORITY]
    @flags       = $cache.pkmn_move[moveid][PBMoveData::FLAGS]
  end

  def isSoundBased?
    return (@flags&0x400)!=0 # Sound Flag ("k") needed checkable for substitute
  end 
end



class PBMove
  attr_reader(:id)       # Gets this move's ID.
  attr_accessor(:pp)     # Gets the number of PP remaining for this move.
  attr_accessor(:ppup)   # Gets the number of PP Ups used for this move.
  attr_accessor(:totalpp)# Gets the total number of PP this move can have.

# Gets this move's type.
  def type
    return $cache.pkmn_move[@id][PBMoveData::TYPE]
  end

# Gets the maximum PP for this move.
  def totalpp
    return @totalpp if defined?(@totalpp)
    tpp=$cache.pkmn_move[@id][PBMoveData::TOTALPP]
    return tpp+(tpp*@ppup/5).floor
  end

  def totalpp=(value)
    @totalpp=value
  end
  
  # Gets basedamage for this move
  def basedamage
    return $cache.pkmn_move[@id][PBMoveData::BASEDAMAGE]
  end
  
# Initializes this object to the specified move ID.
  def initialize(moveid)
    @id=moveid
    @ppup=0
    @pp=totalpp
  end
end