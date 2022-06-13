class PBMoveData
  attr_reader :function,:basedamage,:type,:accuracy
  attr_reader :totalpp,:addlEffect,:target,:priority
  attr_reader :flags
  attr_reader :contestType,:category

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
    @function    = $pkmn_move[moveid][0]
    @basedamage  = $pkmn_move[moveid][1]
    @type        = $pkmn_move[moveid][2]
    @category    = $pkmn_move[moveid][3]
    @accuracy    = $pkmn_move[moveid][4]
    @totalpp     = $pkmn_move[moveid][5]
    @addlEffect  = $pkmn_move[moveid][6]
    @target      = $pkmn_move[moveid][7]
    @priority    = $pkmn_move[moveid][8]
    @flags       = $pkmn_move[moveid][9]
  end

  def isSoundBased?
    return (@flags&0x400)!=0 # Sound Flag ("k") needed checkable for substitute
  end 
end



class PBMove
  attr_reader(:id)       # Gets this move's ID.
  attr_accessor(:pp)     # Gets the number of PP remaining for this move.
  attr_accessor(:ppup)   # Gets the number of PP Ups used for this move.

# Gets this move's type.
  def type
    movedata=PBMoveData.new(@id)
    return movedata.type
  end

# Gets the maximum PP for this move.
  def totalpp
    movedata=PBMoveData.new(@id)
    tpp=movedata.totalpp
    return tpp+(tpp*@ppup/5).floor
  end

# Gets basedamage for this move
  def basedamage
    movedata=PBMoveData.new(@id)
    return movedata.basedamage
  end
  
# Initializes this object to the specified move ID.
  def initialize(moveid)
    movedata=PBMoveData.new(moveid)
    @pp=movedata.totalpp
    @id=moveid
    @ppup=0
  end
end