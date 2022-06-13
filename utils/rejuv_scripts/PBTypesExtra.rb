class PBTypes
  @@TypeData=nil # internal

  def PBTypes.loadTypeData # internal
    if !@@TypeData
      @@TypeData=load_data("Data/types.dat")
      @@TypeData[0].freeze
      @@TypeData[1].freeze
      @@TypeData[2].freeze
      @@TypeData.freeze
    end
    return @@TypeData
  end

  def PBTypes.isPseudoType?(type)
    return PBTypes.loadTypeData()[0].include?(type)
  end

  def PBTypes.isSpecialType?(type)
    return PBTypes.loadTypeData()[1].include?(type)
  end

  def PBTypes.getEffectiveness(attackType,opponentType)
    return PBTypes.loadTypeData()[2][attackType*(PBTypes.maxValue+1)+opponentType]
  end

  def PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2=nil)
    if opponentType2==nil
      return PBTypes.getEffectiveness(attackType,opponentType1)*2
    else
      mod1=PBTypes.getEffectiveness(attackType,opponentType1)
      mod2=(opponentType1==opponentType2) ? 2 : PBTypes.getEffectiveness(attackType,opponentType2)
      return (mod1*mod2)
    end
  end

  def PBTypes.isNotVeryEffective?(attackType,opponentType1,opponentType2=nil)
    e=PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2)
    return e>0 && e<4
  end

  def PBTypes.isNormalEffective?(attackType,opponentType1,opponentType2=nil)
    e=PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2)
    return e==4
  end

  def PBTypes.isIneffective?(attackType,opponentType1,opponentType2=nil)
    e=PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2)
    return e==0
  end

  def PBTypes.isSuperEffective?(attackType,opponentType1,opponentType2=nil)
    e=PBTypes.getCombinedEffectiveness(attackType,opponentType1,opponentType2)
    return e>4
  end
end