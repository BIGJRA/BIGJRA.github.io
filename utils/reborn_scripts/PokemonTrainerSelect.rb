#based off the field notes
#is technically designed for theme teams but could be used for similar purposes
def pbShowThemeTeams(partnerPickin,total_trainers_needed=1,randomized=false)
  viewport = Viewport.new(0, 0, Graphics.width,Graphics.height)
  viewport.z = 10
  sprites={}
  sprites["index"] = 0
  
  trainers = []
  trainernames = []
  tsprites = []
  if ($game_switches[1307] && $game_variables[31] != 1 && $game_variables[33] != 1 && (partnerPickin == false || $game_switches[1615] == true)) 
    trainers.push(1)      
    trainernames.push("Julia") 
    tsprites.push("trchar015")
  end
  if ($game_switches[1308] && $game_variables[31] != 2 && $game_variables[33] != 2 && (partnerPickin == false || $game_switches[1616] == true))   
    trainers.push(2)      
    trainernames.push("Florinia")
    tsprites.push("trchar052")
  end
  if ($game_switches[1309] && $game_variables[31] != 3 && $game_variables[33] != 3 && (partnerPickin == false || $game_switches[1617] == true)) 
    trainers.push(3)      
    trainernames.push("Shelly")
    tsprites.push("trchar068")
  end
  if ($game_switches[1310] && $game_variables[31] != 4 && $game_variables[33] != 4 && (partnerPickin == false || $game_switches[1618] == true)) 
    trainers.push(4)      
    trainernames.push("Shade")
    tsprites.push("trchar077")
  end
  if ($game_switches[1311] && $game_variables[31] != 5 && $game_variables[33] != 5 && (partnerPickin == false || $game_switches[1619] == true)) 
    trainers.push(5)      
    trainernames.push("Aya")
    tsprites.push("trchar092")
  end
  if($game_switches[1312] && $game_variables[31] != 6 && $game_variables[33] != 6 && (partnerPickin == false || $game_switches[1620] == true)) 
    trainers.push(6)      
    trainernames.push("Serra")
    tsprites.push("trchar096")
  end
  if ($game_switches[1313] && $game_variables[31] != 7 && $game_variables[33] != 7 && (partnerPickin == false || $game_switches[1621] == true)) 
    trainers.push(7)      
    trainernames.push("Noel")
    tsprites.push("trchar082c")
  end
  if ($game_switches[1314] && $game_variables[31] != 8 && $game_variables[33] != 8 && (partnerPickin == false || $game_switches[1622] == true)) 
    trainers.push(8)      
    trainernames.push("Radodadobadomus")
    randommus = rand(18)+97
    randoname = "trchar105"
    if randommus !=97
      randommus = randommus.chr
      randoname = randoname+randommus
    end
    tsprites.push(randoname)
  end
  if ($game_switches[1315] && $game_variables[31] != 9 && $game_variables[33] != 9 && (partnerPickin == false || $game_switches[1623] == true)) 
    trainers.push(9)      
    trainernames.push("Luna")
    tsprites.push("trchar106")
  end
  if ($game_switches[1316] && $game_variables[31] != 10 && $game_variables[33] != 10 && (partnerPickin == false || $game_switches[1624] == true)) 
    trainers.push(10)      
    trainernames.push("Samson")
    tsprites.push("trchar116")
  end
  if ($game_switches[1317] && $game_variables[31] != 11 && $game_variables[33] != 11 && (partnerPickin == false || $game_switches[1625] == true)) 
    trainers.push(11)      
    trainernames.push("Charlotte")
    tsprites.push("trchar085")
  end
  if ($game_switches[1318] && $game_variables[31] != 12 && $game_variables[33] != 12 && (partnerPickin == false || $game_switches[1626] == true)) 
    trainers.push(12)      
    trainernames.push("Terra")
    tsprites.push("trchar115b")
  end
  if ($game_switches[1319] && $game_variables[31] != 13 && $game_variables[33] != 13 && (partnerPickin == false || $game_switches[1627] == true)) 
    trainers.push(13)      
    trainernames.push("Ciel")
    tsprites.push("trchar118")
  end
  if ($game_switches[1320] && $game_variables[31] != 14 && $game_variables[33] != 14 && (partnerPickin == false || $game_switches[1628] == true)) 
    trainers.push(14)      
    trainernames.push("Adrienn")
    tsprites.push("trchar107")
  end
  if ($game_switches[1321] && $game_variables[31] != 15 && $game_variables[33] != 15 && (partnerPickin == false || $game_switches[1629] == true)) 
    trainers.push(15)      
    trainernames.push("Titania")
    tsprites.push("trchar088")
  end
  if ($game_switches[1322] && $game_variables[31] != 16 && $game_variables[33] != 16 && (partnerPickin == false || $game_switches[1630] == true)) 
    trainers.push(16)      
    trainernames.push("Amaria")
    tsprites.push("trchar069")
  end
  if ($game_switches[1323] && $game_variables[31] != 17 && $game_variables[33] != 17 && (partnerPickin == false || $game_switches[1631] == true)) 
    trainers.push(17)      
    trainernames.push("Hardy")
    tsprites.push("trchar093")
  end
  if ($game_switches[1324] && $game_variables[31] != 18 && $game_variables[33] != 18 && (partnerPickin == false || $game_switches[1632] == true)) 
    trainers.push(18)      
    trainernames.push("Saphira")
    tsprites.push("trchar076")
  end
  if ($game_switches[1325] && $game_variables[31] != 19 && $game_variables[33] != 19 && (partnerPickin == false || $game_switches[1633] == true)) 
    trainers.push(19)      
    trainernames.push("Heather")
    tsprites.push("trchar072")
  end
  if ($game_switches[1326] && $game_variables[31] != 20 && $game_variables[33] != 20 && (partnerPickin == false || $game_switches[1634] == true)) 
    trainers.push(20)      
    trainernames.push("Laura")
    tsprites.push("trchar084")
  end
  if ($game_switches[1327] && $game_variables[31] != 21 && $game_variables[33] != 21 && (partnerPickin == false || $game_switches[1635] == true)) 
    trainers.push(21)      
    trainernames.push("Elias")
    tsprites.push("trchar097d")
  end
  if ($game_switches[1328] && $game_variables[31] != 22 && $game_variables[33] != 22 && (partnerPickin == false || $game_switches[1636] == true)) 
    trainers.push(22)      
    trainernames.push("Anna")
    tsprites.push("trchar081")
  end
  if ($game_switches[1329] && $game_variables[31] != 23 && $game_variables[33] != 23 && (partnerPickin == false || $game_switches[1637] == true)) 
    trainers.push(23)      
    trainernames.push("Arclight")
    tsprites.push("trchar108")
  end
  if ($game_switches[1330] && $game_variables[31] != 24 && $game_variables[33] != 24 && (partnerPickin == false || $game_switches[1638] == true)) 
    trainers.push(24)      
    trainernames.push("Cain")
    tsprites.push("trchar023")
  end
  if ($game_switches[1331] && $game_variables[31] != 25 && $game_variables[33] != 25 && (partnerPickin == false || $game_switches[1639] == true)) 
    trainers.push(25)      
    trainernames.push("Fern")
    tsprites.push("trchar029")
  end
  if ($game_switches[1332] && $game_variables[31] != 26 && $game_variables[33] != 26 && (partnerPickin == false || $game_switches[1640] == true)) 
    trainers.push(26)      
    trainernames.push("Victoria")
    tsprites.push("trchar018")
  end
  if ($game_switches[1333] && $game_variables[31] != 27 && $game_variables[33] != 27 && (partnerPickin == false || $game_switches[1641] == true)) 
    trainers.push(27)      
    trainernames.push("Bennett")
    tsprites.push("trchar095b")
  end
  if ($game_switches[1334] && $game_variables[31] != 28 && $game_variables[33] != 28 && (partnerPickin == false || $game_switches[1642] == true)) 
    trainers.push(28)      
    trainernames.push("Taka")
    if $game_switches[878] == true
      tsprites.push("trchar071")
    else
      tsprites.push("trchar071c")
    end
  end
  if ($game_switches[1335] && $game_variables[31] != 29 && $game_variables[33] != 29 && (partnerPickin == false || $game_switches[1643] == true)) 
    trainers.push(29)      
    trainernames.push("Blake")
    tsprites.push("trchar132")
  end
  if ($game_switches[1336] && $game_variables[31] != 30 && $game_variables[33] != 30 && (partnerPickin == false || $game_switches[1644] == true)) 
    trainers.push(30)      
    trainernames.push("Cal")
    tsprites.push("trchar090b")
  end
  if ($game_switches[1337] && $game_variables[31] != 31 && $game_variables[33] != 31 && (partnerPickin == false || $game_switches[1645] == true)) 
    trainers.push(31)      
    trainernames.push("Eve")
    tsprites.push("trchar149")
  end
  if ($game_switches[1338] && $game_variables[31] != 32 && $game_variables[33] != 32 && (partnerPickin == false || $game_switches[1646] == true)) 
    trainers.push(32)      
    trainernames.push("Lumi")
    tsprites.push("trchar150")
  end
  if ($game_switches[1339] && $game_variables[31] != 33 && $game_variables[33] != 33 && (partnerPickin == false || $game_switches[1647] == true)) 
    trainers.push(33)      
    trainernames.push("Zero")
    tsprites.push("trchar070b")
  end
  if ($game_switches[1340] && $game_variables[31] != 34 && $game_variables[33] != 34 && (partnerPickin == false || $game_switches[2087] == true)) 
    trainers.push(34)      
    trainernames.push("Ace")
    tsprites.push("trchar191e")
  end
  if ($game_switches[2011] && $game_variables[31] != 35 && $game_variables[33] != 35 && (partnerPickin == false || $game_switches[2011] == true)) ##checking the switch twice so i dont mess up syntax bc im a scared little bitchy-boo
    trainers.push(35)      
    trainernames.push("Lin")
    tsprites.push("trchar164")
  end

  
  #check if enough battlers are available for battle
  if trainers.length < total_trainers_needed
    return false
  end
  #working out how big the bitmap needs to be
  extra_length = 96 * (trainers.length / 6.0 ).ceil
  sprites["overlay"]=BitmapSprite.new(Graphics.width, extra_length, viewport)
  overlay = sprites["overlay"].bitmap

  if randomized
    choosen_trainer = rand(trainers.length)
    $game_variables[29] = trainers[choosen_trainer]
    $game_variables[28] = trainernames[choosen_trainer]
    return true
  end
  imagePositions=[]
  lightPositions=[]
  x=96
  y=48
  for i in 0...trainers.length
    lightfile = "Graphics/Characters/light4.png"
    lightPositions.push([lightfile,x,y,0,0])
    imagename = ("Graphics/Characters/" + tsprites[i].to_s)
    if trainers[i]==8
      imagePositions.push([imagename,x-2,y-8,0,0])
    elsif trainers[i]==12
      imagePositions.push([imagename,x-2,y-16,0,0])
    else
      imagePositions.push([imagename,x,y,0,0])
    end
    x+=64
    if (i+1) %6 == 0
      x-=384
      y+=96
    end
  end
  pbDrawImagePositions2(overlay,lightPositions)
  pbDrawImagePositions2(overlay,imagePositions)
  sprites["arrow"] = IconSprite.new(0,0)
  sprites["arrow"].setBitmap("Graphics/Pictures/customArrow.png")
  sprites["arrow"].x=84
  sprites["arrow"].y=48
  sprites["arrow"].z=12
  loop do
    Graphics.update
    Input.update
    if Input.trigger?(Input::LEFT) 
      pbPlayCursorSE()
      sprites["index"]-=1
      sprites["index"]=(trainers.length-1) if sprites["index"]<0
    elsif Input.trigger?(Input::RIGHT)
      pbPlayCursorSE()
      sprites["index"]+=1
      sprites["index"]=0 if sprites["index"] > (trainers.length-1)
    elsif Input.trigger?(Input::UP)
      pbPlayCursorSE()
      sprites["index"]-=6
      if sprites["index"]<0
        col = (sprites["index"])%6
        row = ((trainers.length)/6).floor
        sprites["index"] = ((row*6) + col)
        if sprites["index"] > (trainers.length-1)
          sprites["index"] -= 6
        end
      end
    elsif Input.trigger?(Input::DOWN)
      pbPlayCursorSE()
      sprites["index"]+=6
      sprites["index"]=sprites["index"]%6 if sprites["index"] > trainers.length - 1
    end
    if Input.trigger?(Input::B)
      sprites["arrow"].dispose
      sprites["overlay"].dispose
      $game_variables[29]=0
      return false
    end
    if Input.trigger?(Input::C)
      pbPlayDecisionSE()
      sprites["arrow"].dispose
      sprites["overlay"].dispose
      $game_variables[29] = trainers[sprites["index"]]
      $game_variables[28] = trainernames[sprites["index"]]
      break
    end
    sprites["arrow"].x=(sprites["index"]%6)*64
    sprites["arrow"].y=(sprites["index"]/6).floor*96 
    sprites["arrow"].x+=84
    sprites["arrow"].y+=48 + sprites["overlay"].y
    if sprites["arrow"].y>=Graphics.height
      sprites["overlay"].y-=96
    elsif sprites["arrow"].y<=0
      sprites["overlay"].y+=96
    end
  end
  return true
end

def urmom3
  index = $game_variables[29]
  x=96
  y=48
  x+=(index%6)*64
  y+=(index/6).floor*96
  $game_variables[30] = x
  $game_variables[31] = y
end

def themeTeamArray
  teams =[
    {number: 1,trainer: "Julia",name: "Boss Rush", teamnumber: 10, field: 1, doubles: false},
    {number: 1,trainer: "Julia",name: "Boss Rush 2", teamnumber: 11, field: 1, doubles: false},
    {number: 1,trainer: "Julia",name: "Deal With It", teamnumber: 12, field: 21, doubles: true},
    {number: 1,trainer: "Julia",name: "Julia's Kitchen", teamnumber: 13, field: 26, doubles: false},
    {number: 1,trainer: "Julia",name: "Responsible Workplace Practices", teamnumber: 14, field: 17, doubles: true},
    {number: 1,trainer: "Julia",name: "Kaboom!", teamnumber: 15, field: 24, doubles: false},
    {number: 2,trainer: "Florinia",name: "Boss Rush", teamnumber: 10, field: 15, doubles: false},
    {number: 2,trainer: "Florinia",name: "Boss Rush 2", teamnumber: 11, field: 15, doubles: false},
    {number: 2,trainer: "Florinia",name: "Reconsideration", teamnumber: 12, field: 36, doubles: false},
    {number: 2,trainer: "Florinia",name: "Standard Environment", teamnumber: 13, field: 2, doubles: false},
    {number: 2,trainer: "Florinia",name: "Alpine Rose", teamnumber: 14, field: 27, doubles: true},
    {number: 2,trainer: "Florinia",name: "Wetland Rose", teamnumber: 15, field: 8, doubles: false},
    {number: 2,trainer: "Florinia",name: "Performative Science", teamnumber: 16, field: 6, doubles: false},
    {number: 3,trainer: "Shelly",name: "Boss Rush", teamnumber: 10, field: 15, doubles: false},
    {number: 3,trainer: "Shelly",name: "Boss Rush 2", teamnumber: 11, field: 15, doubles: false},
    {number: 3,trainer: "Shelly",name: "Stage Fright", teamnumber: 12, field: 6, doubles: false},
    {number: 3,trainer: "Shelly",name: "Buggie Paddle", teamnumber: 13, field: 21, doubles: false},
    {number: 3,trainer: "Shelly",name: "Miscommunication", teamnumber: 14, field: 36, doubles: false},
    {number: 3,trainer: "Shelly",name: "Computational Science Isn't So Hard!", teamnumber: 15, field: 24, doubles: false},
    {number: 4,trainer: "Shade",name: "Boss Rush", teamnumber: 10, field: 4, doubles: false},
    {number: 4,trainer: "Shade",name: "Boss Rush 2", teamnumber: 11, field: 4, doubles: false},
    {number: 4,trainer: "Shade",name: "Midnight Meadow", teamnumber: 12, field: 2, doubles: false},
    {number: 4,trainer: "Shade",name: "Hexes and Heroism", teamnumber: 13, field: 34, doubles: false},
    {number: 5,trainer: "Aya",name: "Boss Rush", teamnumber: 10, field: 19, doubles: false},
    {number: 5,trainer: "Aya",name: "Boss Rush 2", teamnumber: 11, field: 8, doubles: false},
    {number: 5,trainer: "Aya",name: "Acridity", teamnumber: 12, field: 26, doubles: false},
    {number: 5,trainer: "Aya",name: "Toxicity", teamnumber: 13, field: 10, doubles: false},
    {number: 6,trainer: "Serra",name: "Boss Rush", teamnumber: 10, field: 13, doubles: false},
    {number: 6,trainer: "Serra",name: "Boss Rush 2", teamnumber: 11, field: 36, doubles: true},
    {number: 6,trainer: "Serra",name: "Noitcelfer", teamnumber: 12, field: 36, doubles: false},
    {number: 6,trainer: "Serra",name: "Digital Imaging", teamnumber: 13, field: 24, doubles: false},
    {number: 7,trainer: "Noel",name: "Boss Rush", teamnumber: 10, field: 29, doubles: false},
    {number: 7,trainer: "Noel",name: "Boss Rush 2", teamnumber: 11, field: 29, doubles: false},
    {number: 7,trainer: "Noel",name: "Abnormal", teamnumber: 12, field: 36, doubles: false},
    {number: 7,trainer: "Noel",name: "Defaulted", teamnumber: 13, field: 24, doubles: false},
    {number: 7,trainer: "Noel",name: "Entrainment", teamnumber: 14, field: 26, doubles: true},
    {number: 7,trainer: "Noel",name: "Illustrated", teamnumber: 15, field: 9, doubles: false},
    {number: 8,trainer: "Radomus",name: "Boss Rush", teamnumber: 10, field: 34, doubles: false},
    {number: 8,trainer: "Radomus",name: "Boss Rush 2", teamnumber: 11, field: 34, doubles: false},
    {number: 8,trainer: "Radomus",name: "Telepathic Timetables", teamnumber: 12, field: 37, doubles: false},
    {number: 8,trainer: "Radomus",name: "Black on Purple", teamnumber: 13, field: 37, doubles: true},
    {number: 8,trainer: "Radomus",name: "Stockfish Malfunction", teamnumber: 14, field: 24, doubles: false},
    {number: 8,trainer: "Radomus",name: "Celestial Enlightenment", teamnumber: 15, field: 20, doubles: false},
    {number: 8,trainer: "Radomus",name: "Agnosticism", teamnumber: 16, field: 29, doubles: false},
    {number: 9,trainer: "Luna",name: "Boss Rush", teamnumber: 10, field: 35, doubles: false},
    {number: 9,trainer: "Luna",name: "Boss Rush 2", teamnumber: 11, field: 35, doubles: false},
    {number: 9,trainer: "Luna",name: "Mermaid in the Deep", teamnumber: 12, field: 21, doubles: false},
    {number: 9,trainer: "Luna",name: "Gothic Lolita", teamnumber: 13, field: 31, doubles: false},
    {number: 10,trainer: "Samson",name: "Boss Rush", teamnumber: 10, field: 6, doubles: false},
    {number: 10,trainer: "Samson",name: "Boss Rush 2", teamnumber: 11, field: 6, doubles: false},
    {number: 10,trainer: "Samson",name: "Endorphins", teamnumber: 12, field: 20, doubles: false},
    {number: 10,trainer: "Samson",name: "Grow Strong", teamnumber: 13, field: 15, doubles: false},
    {number: 11,trainer: "Charlotte",name: "Boss Rush", teamnumber: 10, field: 7, doubles: true},
    {number: 11,trainer: "Charlotte",name: "Boss Rush 2", teamnumber: 11, field: 16, doubles: true},
    {number: 11,trainer: "Charlotte",name: "Fried Circuits", teamnumber: 12, field: 24, doubles: false},
    {number: 11,trainer: "Charlotte",name: "Fire Hazard", teamnumber: 13, field: 2, doubles: false},
    {number: 11,trainer: "Charlotte",name: "Like Mom & Pop", teamnumber: 14, field: 32, doubles: false},
    {number: 12,trainer: "Terra",name: "Boss Rush", teamnumber: 10, field: 12, doubles: true},
    {number: 12,trainer: "Terra",name: "Boss Rush 2", teamnumber: 11, field: 12, doubles: true},
    {number: 12,trainer: "Terra",name: "SEEDZ NUTZ", teamnumber: 12, field: 11, doubles: false},
    {number: 12,trainer: "Terra",name: "cOARSE anD ROUGH", teamnumber: 13, field: 20, doubles: false},
    {number: 12,trainer: "Terra",name: "gettin wet ;)", teamnumber: 14, field: 22, doubles: false},
    {number: 12,trainer: "Terra",name: "THE ENTIRE CIRCUS!!!!11!!!!1!!!", teamnumber: 15, field: 6, doubles: false},
    {number: 13,trainer: "Ciel",name: "Boss Rush", teamnumber: 10, field: 27, doubles: true},
    {number: 13,trainer: "Ciel",name: "Boss Rush 2", teamnumber: 11, field: 27, doubles: true},
    {number: 13,trainer: "Ciel",name: "Above the Rabble", teamnumber: 12, field: 26, doubles: false},
    {number: 13,trainer: "Ciel",name: "New Horizons", teamnumber: 13, field: 35, doubles: false},
    {number: 13,trainer: "Ciel",name: "Beauty in Brutality", teamnumber: 14, field: 32, doubles: true},
    {number: 13,trainer: "Ciel",name: "Suspension of Disbelief", teamnumber: 15, field: 37, doubles: false},
    {number: 13,trainer: "Ciel",name: "Are We Human?", teamnumber: 16, field: 6, doubles: true},
    {number: 14,trainer: "Adrienn",name: "Boss Rush", teamnumber: 10, field: 3, doubles: false},
    {number: 14,trainer: "Adrienn",name: "Boss Rush 2", teamnumber: 11, field: 31, doubles: true},
    {number: 14,trainer: "Adrienn",name: "Chronomancy", teamnumber: 12, field: 37, doubles: false},
    {number: 14,trainer: "Adrienn",name: "Machine Dreams", teamnumber: 13, field: 17, doubles: false},
    {number: 14,trainer: "Adrienn",name: "Happily Ever After", teamnumber: 14, field: 31, doubles: false},
    {number: 14,trainer: "Adrienn",name: "Atop Olympus", teamnumber: 15, field: 27, doubles: true},
    {number: 14,trainer: "Adrienn",name: "Miraculous", teamnumber: 16, field: 29, doubles: false},
    {number: 15,trainer: "Titania",name: "Boss Rush", teamnumber: 10, field: 31, doubles: false},
    {number: 15,trainer: "Titania",name: "Boss Rush 2", teamnumber: 11, field: 31, doubles: false},
    {number: 15,trainer: "Titania",name: "Desert Blindness", teamnumber: 12, field: 12, doubles: false},
    {number: 15,trainer: "Titania",name: "Legless Sea", teamnumber: 13, field: 26, doubles: false},
    {number: 15,trainer: "Titania",name: "Forty Nights of Fire", teamnumber: 14, field: 11, doubles: true},
    {number: 15,trainer: "Titania",name: "Psychic Spindle", teamnumber: 15, field: 37, doubles: false},
    {number: 15,trainer: "Titania",name: "The Witch's Hut", teamnumber: 16, field: 8, doubles: false},
    {number: 16,trainer: "Amaria",name: "Boss Rush", teamnumber: 10, field: 21, doubles: $game_variables[881] && !$game_variables[878] || !$game_variables[881] && $game_variables[878]},
    {number: 16,trainer: "Amaria",name: "Boss Rush 2", teamnumber: 11, field: 22, doubles: $game_variables[881] && !$game_variables[878] || !$game_variables[881] && $game_variables[878]},
    {number: 16,trainer: "Amaria",name: "Contradictory Impulses", teamnumber: 12, field: 24, doubles: false},
    {number: 16,trainer: "Amaria",name: "Shadowy Anguish", teamnumber: 13, field: 8, doubles: false},
    {number: 16,trainer: "Amaria",name: "Inward Contemplation", teamnumber: 14, field: 20, doubles: false},
    {number: 16,trainer: "Amaria",name: "The Tumult", teamnumber: 15, field: 37, doubles: false},
    {number: 17,trainer: "Hardy",name: "Boss Rush", teamnumber: 10, field: 14, doubles: true},
    {number: 17,trainer: "Hardy",name: "Boss Rush 2", teamnumber: 11, field: 14, doubles: true},
    {number: 17,trainer: "Hardy",name: "The Ocean", teamnumber: 12, field: 21, doubles: false},
    {number: 17,trainer: "Hardy",name: "Rocky Mountain Way", teamnumber: 13, field: 27, doubles: true},
    {number: 17,trainer: "Hardy",name: "Lucy in the Sky", teamnumber: 14, field: 25, doubles: false},
    {number: 17,trainer: "Hardy",name: "Bites the Dust", teamnumber: 15, field: 12, doubles: true},
    {number: 18,trainer: "Saphira",name: "Boss Rush", teamnumber: 10, field: 32, doubles: false},
    {number: 18,trainer: "Saphira",name: "Boss Rush 2", teamnumber: 11, field: 32, doubles: false},
    {number: 18,trainer: "Saphira",name: "Naga", teamnumber: 12, field: 37, doubles: false},
    {number: 18,trainer: "Saphira",name: "Hydra", teamnumber: 13, field: 21, doubles: false},
    {number: 18,trainer: "Saphira",name: "Wyrm", teamnumber: 14, field: 31, doubles: false},
    {number: 18,trainer: "Saphira",name: "King", teamnumber: 15, field: 29, doubles: false},
    {number: 19,trainer: "Heather",name: "Polar Peak Princess", teamnumber: 10, field: 28, doubles: false},
    {number: 19,trainer: "Heather",name: "Purple Poison Power", teamnumber: 11, field: 10, doubles: false},
    {number: 19,trainer: "Heather",name: "Dancing Dragon Danger", teamnumber: 12, field: 32, doubles: false},
    {number: 19,trainer: "Heather",name: "In Memoriam", teamnumber: 13, field: 35, doubles: true},
    {number: 20,trainer: "Laura",name: "Wisteria", teamnumber: 10, field: 33, doubles: true},
    {number: 20,trainer: "Laura",name: "Sakura", teamnumber: 11, field: 31, doubles: false},
    {number: 20,trainer: "Laura", name: "Octopetala", teamnumber: 12, field: 34, doubles: false},
    {number: 21,trainer: "Elias",name: "False God", teamnumber: 10, field: 29, doubles: false},
    {number: 21,trainer: "Elias",name: "Natural Consequences", teamnumber: 11, field: 29, doubles: false},
    {number: 21,trainer: "Elias", name: "Dabbling in Distortion", teamnumber:12, field: 36, doubles: false},
    {number: 21,trainer: "Elias", name: "Who's Grandmaster Now?", teamnumber:13, field: 5, doubles: true},
    {number: 22,trainer: "Anna",name: "Seeing Stars", teamnumber: 10, field: 34, doubles: true},
    {number: 22,trainer: "Anna",name: "Millennial Puzzles", teamnumber: 11, field: 5, doubles: false},
    {number: 22,trainer: "Anna",name: "Unforeseen Futurity", teamnumber:12, field: 35, doubles: false},
    {number: 23,trainer: "Arclight",name: "Make Some Noise", teamnumber: 10, field: 6, doubles: true},
    {number: 23,trainer: "Arclight",name: "Sole Sight", teamnumber: 11, field: 4, doubles: false},
    {number: 23,trainer: "Arclight",name: "The Conductor", teamnumber: 12, field: 21, doubles: false},
    {number: 23,trainer: "Arclight",name: "Night Club", teamnumber: 13, field: 18, doubles: false},
    {number: 24,trainer: "Cain",name: "Pretty Boy", teamnumber: 10, field: 9, doubles: false},
    {number: 24,trainer: "Cain",name: "Sing for Me!", teamnumber: 11, field: 6, doubles: false},
    {number: 24,trainer: "Cain",name: "Subverted Expectations", teamnumber: 12, field: 36, doubles: false},
    {number: 25,trainer: "Fern",name: "Contrarian", teamnumber: 10, field: 8, doubles: false},
    {number: 25,trainer: "Fern",name: "Hero's Journey", teamnumber: 11, field: 31, doubles: false},
    {number: 25,trainer: "Fern",name: "Come on and Smile!", teamnumber: 12, field: 15, doubles: false},
    {number: 26,trainer: "Victoria",name: "Fallacy of Justice", teamnumber: 10, field: 31, doubles: false},
    {number: 26,trainer: "Victoria",name: "Black and White", teamnumber: 11, field: 5, doubles: false},
    {number: 26,trainer: "Victoria",name: "A Change of Pace", teamnumber: 12, field: 6, doubles: false},
    {number: 27,trainer: "Bennett",name: "A Game Of Intellect", teamnumber: 10, field: 5, doubles: false},
    {number: 27,trainer: "Bennett",name: "Predisposition to Showmanship", teamnumber: 11, field: 6, doubles: false},
    {number: 27,trainer: "Bennett",name: "Self-Reflection", teamnumber: 12, field: 30, doubles: false},
    {number: 28,trainer: "Taka",name: "Stack o' Taka", teamnumber: 10, field: 18, doubles: true},
    {number: 28,trainer: "Taka",name: "Light My Fire",teamnumber: 11, field: 7, doubles:true},
    {number: 28,trainer: "Taka",name: "The View From Up Here",teamnumber: 12, field: 27, doubles: true},
    {number: 28,trainer: "Taka",name: "Legacy", teamnumber: 13, field: 32, doubles: true},
    {number: 29,trainer: "Blake",name: "Console Defrag", teamnumber: 10, field: 24, doubles: true},
    {number: 29,trainer: "Blake",name: "Nice Stall Bro", teamnumber: 11, field: 36, doubles: false},
    {number: 29,trainer: "Blake",name: "Can't Touch This", teamnumber: 12, field: 30, doubles: false},
    {number: 30,trainer: "Cal",name: "Across Coals", teamnumber: 10, field: 20, doubles: false},
    {number: 30,trainer: "Cal",name: "Boiling Blood", teamnumber: 11, field: 32, doubles: false},
    {number: 30,trainer: "Cal",name: "Burning Pride", teamnumber: 12, field: 9, doubles: false},
    {number: 31,trainer: "Eve",name: "Technical Expertise", teamnumber: 10, field: 17, doubles: false},
    {number: 31,trainer: "Eve",name: "Ultra-Precise Analysis", teamnumber: 11, field: 24, doubles: false},
    {number: 31,trainer: "Eve",name: "Intermediation", teamnumber: 12, field: 5, doubles: false},
    {number: 32,trainer: "Lumi",name: "Teamwork!", teamnumber: 10, field: 36, doubles: false},
    {number: 32,trainer: "Lumi",name: "Ametrine Blues", teamnumber: 11, field: 21, doubles: false},
    {number: 32,trainer: "Lumi",name: "Bedtime Stories", teamnumber: 12, field: 31, doubles: false},
    {number: 33,trainer: "Zero",name: "Zed", teamnumber: 10, field: 1, doubles: false},
    {number: 33,trainer: "Zero",name: "Zero Gravity", teamnumber: 11, field: 35, doubles: false},
    {number: 33,trainer: "Zero",name: "Reminiscence", teamnumber: 12, field: 36, doubles: false},
    {number: 34,trainer: "Ace of All Suits",name: "Myth and Mystery", teamnumber: 10, field: 31, doubles: false},
    {number: 34,trainer: "Ace of All Suits",name: "Eyes of Fire", teamnumber: 11, field: 7, doubles: false},
    {number: 34,trainer: "Ace of All Suits",name: "Half-Tossed Coin", teamnumber: 12, field: 4, doubles: false},
    {number: 34,trainer: "Ace of All Suits",name: "Technological Trickster", teamnumber: 13, field: 24, doubles: false},
    {number: 34,trainer: "Ace of All Suits",name: "Fashion Forward", teamnumber: 14, field: 5, doubles: true},
    {number: 34,trainer: "Ace of All Suits",name: "Family", teamnumber: 15, field: 29, doubles: false},
    {number: 35,trainer: "Lin",name: "puppies!!!", teamnumber: 10, field: 29, doubles: false},
    {number: 35,trainer: "Lin",name: "stop flinching urself", teamnumber: 11, field: 9, doubles: true},
    {number: 35,trainer: "Lin",name: "old habits die hard", teamnumber: 12, field: 35, doubles: false}
  ]
  teams.filter! { |hash| hash[:number] == $game_variables[29] }
  teams.filter! { |hash| hash[:name] != "Boss Rush" } if !$game_switches[2075]
  teams.filter! { |hash| hash[:name] != "Boss Rush 2" } if !$game_switches[1587]
  return teams 
end

def chooseThemeTeams(randomized)
  teams = themeTeamArray  
  print "no teams available, please report: ", $game_variables[29], " - ", $game_variables[28] if teams.length==0
  if randomized 
    chosen_team = teams.sample
    $game_variables[62]  = 1
    $game_variables[:Forced_Field_Effect] = chosen_team[:field]
    $game_switches[1394] = chosen_team[:doubles]
    $game_variables[600] = chosen_team[:teamnumber]
    return
  end
  if $game_switches[1400]
    Kernel.pbMessage("What team should #{$game_variables[28]} use?")
  else
    Kernel.pbMessage("Which one of #{$game_variables[28]}'s teams would you like to face?")
  end
  teamnames = teams.map { |hash| hash[:name] }
  chosen_team_number = Kernel.pbMessage("Pick a team to fight.",teamnames)
  chosen_team = teams[chosen_team_number]
  $game_variables[62]  = 1
  $game_variables[:Forced_Field_Effect] = chosen_team[:field]
  $game_switches[1394] = chosen_team[:doubles]
  $game_variables[600] = chosen_team[:teamnumber]
  return true
end


def pbChooseField
  fields=[_INTL("No Field")]
  fields.push(_INTL("Random"))
  for i in 1..37
    fields.push(FIELDEFFECTS[i][:FIELDNAME])
  end
  choose=Kernel.pbMessage(_INTL("What field would you like to battle on?"),fields)   
  choose -= 1 
  if choose == -1 
    choose = 0
  elsif choose == 0
    choose = rand(38)
  end
  return choose
end


