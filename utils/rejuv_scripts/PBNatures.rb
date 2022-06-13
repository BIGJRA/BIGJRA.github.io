module PBNatures
  HARDY   = 0
  LONELY  = 1
  BRAVE   = 2
  ADAMANT = 3
  NAUGHTY = 4
  BOLD    = 5
  DOCILE  = 6
  RELAXED = 7
  IMPISH  = 8
  LAX     = 9
  TIMID   = 10
  HASTY   = 11
  SERIOUS = 12
  JOLLY   = 13
  NAIVE   = 14
  MODEST  = 15
  MILD    = 16
  QUIET   = 17
  BASHFUL = 18
  RASH    = 19
  CALM    = 20
  GENTLE  = 21
  SASSY   = 22
  CAREFUL = 23
  QUIRKY  = 24

  def PBNatures.maxValue; 24; end
  def PBNatures.getCount; 25; end

  def PBNatures.getName(id)
    names=[
       _INTL("Hardy"),
       _INTL("Lonely"),
       _INTL("Brave"),
       _INTL("Adamant"),
       _INTL("Naughty"),
       _INTL("Bold"),
       _INTL("Docile"),
       _INTL("Relaxed"),
       _INTL("Impish"),
       _INTL("Lax"),
       _INTL("Timid"),
       _INTL("Hasty"),
       _INTL("Serious"),
       _INTL("Jolly"),
       _INTL("Naive"),
       _INTL("Modest"),
       _INTL("Mild"),
       _INTL("Quiet"),
       _INTL("Bashful"),
       _INTL("Rash"),
       _INTL("Calm"),
       _INTL("Gentle"),
       _INTL("Sassy"),
       _INTL("Careful"),
       _INTL("Quirky")
    ]
    return names[id]
  end
end