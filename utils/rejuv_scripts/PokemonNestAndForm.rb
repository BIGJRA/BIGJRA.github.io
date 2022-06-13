def pbFindEncounter(encounter,species)
  return false if !encounter
  for i in 0...encounter.length
    next if !encounter[i]
    for j in 0...encounter[i].length
      return true if encounter[i][j][0]==species
    end
  end
  return false
end



################################################################################
# Shows the "Nest" page of the Pokédex entry screen.
################################################################################
class PokemonNestMapScene
  attr_accessor :currentregion
  
  def pbStartScene(species,regionmap=-1)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    pbRgssOpen("Data/townmap.dat","rb"){|f|
       @mapdata=Marshal.load(f)
    }
    mappos=!$game_map ? nil : pbGetMetadata($game_map.map_id,MetadataMapPosition)
    region=regionmap
    if region<0                                    # Use player's current region
      region=mappos ? mappos[0] : 0                           # Region 0 default
    end
    @currentregion = regionmap
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/pokedexNest"))
    if $game_switches[AdvancedPokedexScene::SWITCH]
       @sprites["dexbar"]=IconSprite.new(0,0,@viewport)
       @sprites["dexbar"].setBitmap(_INTL("Graphics/Pictures/Pokedex/advancedPokedexNestBar"))
      end
    @sprites["map"]=IconSprite.new(0,0,@viewport)
    @sprites["map"].setBitmap("Graphics/Pictures/#{@mapdata[region][1]}")
    @sprites["map"].x+=(Graphics.width-@sprites["map"].bitmap.width)/2
    @sprites["map"].y+=(Graphics.height-@sprites["map"].bitmap.height)/2
    for hidden in REGIONMAPEXTRAS
      if hidden[0]==region && hidden[1]>0 && $game_switches[hidden[1]]
        if !@sprites["map2"]
          @sprites["map2"]=BitmapSprite.new(480,320,@viewport)
          @sprites["map2"].x=@sprites["map"].x; @sprites["map2"].y=@sprites["map"].y
        end
        pbDrawImagePositions(@sprites["map2"].bitmap,[
           ["Graphics/Pictures/#{hidden[4]}",
              hidden[2]*PokemonRegionMapScene::SQUAREWIDTH,
              hidden[3]*PokemonRegionMapScene::SQUAREHEIGHT,0,0,-1,-1]
        ])
      end
    end
    @point=BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH+4,
                             PokemonRegionMapScene::SQUAREHEIGHT+4)
    @point.fill_rect(0,0,
                     PokemonRegionMapScene::SQUAREWIDTH+4,
                     PokemonRegionMapScene::SQUAREHEIGHT+4,Color.new(255,0,0))
    @point2=BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH+4,
                              PokemonRegionMapScene::SQUAREHEIGHT+4)
    @point2.fill_rect(4,0,
                      PokemonRegionMapScene::SQUAREWIDTH,
                      PokemonRegionMapScene::SQUAREHEIGHT+4,Color.new(255,0,0))
    @point3=BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH+4,
                              PokemonRegionMapScene::SQUAREHEIGHT+4)
    @point3.fill_rect(0,4,
                      PokemonRegionMapScene::SQUAREWIDTH+4,
                      PokemonRegionMapScene::SQUAREHEIGHT,Color.new(255,0,0))
    @point4=BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH+4,
                              PokemonRegionMapScene::SQUAREHEIGHT+4)
    @point4.fill_rect(4,4,
                      PokemonRegionMapScene::SQUAREWIDTH,
                      PokemonRegionMapScene::SQUAREHEIGHT,Color.new(255,0,0))
    encdata=load_data("Data/encounters.dat")
    points=[]
    mapwidth=1+PokemonRegionMapScene::RIGHT-PokemonRegionMapScene::LEFT
    for enc in encdata.keys
      enctypes=encdata[enc][1]
      if pbFindEncounter(enctypes,species)
        mappos=pbGetMetadata(enc,MetadataMapPosition)
        if mappos && mappos[0]==region
          showpoint=true
          for loc in @mapdata[region][2]
            showpoint=false if loc[0]==mappos[1] && loc[1]==mappos[2] &&
                               loc[7] && !$game_switches[loc[7]]
          end
          if showpoint
            mapsize=pbGetMetadata(enc,MetadataMapSize)
            if mapsize && mapsize[0] && mapsize[0]>0
              sqwidth=mapsize[0]
              sqheight=(mapsize[1].length*1.0/mapsize[0]).ceil
              for i in 0...sqwidth
                for j in 0...sqheight
                  if mapsize[1][i+j*sqwidth,1].to_i>0
                    points[mappos[1]+i+(mappos[2]+j)*mapwidth]=true
                  end
                end
              end
            else
              points[mappos[1]+mappos[2]*mapwidth]=true
            end
          end
        end
      end
    end
    i=0
    for j in 0...points.length
      if points[j]
        s=SpriteWrapper.new(@viewport)
        s.x=(j%mapwidth)*PokemonRegionMapScene::SQUAREWIDTH-2
        s.x+=(Graphics.width-@sprites["map"].bitmap.width)/2
        s.y=(j/mapwidth)*PokemonRegionMapScene::SQUAREHEIGHT-2
        s.y+=(Graphics.height-@sprites["map"].bitmap.height)/2
        if j>=1 && points[j-1]
          if j>=mapwidth && points[j-mapwidth]
            s.bitmap=@point4
          else
            s.bitmap=@point2
          end
        else
          if j>=mapwidth && points[j-mapwidth]
            s.bitmap=@point3
          else
            s.bitmap=@point
          end
        end
        @sprites["point#{i}"]=s
        i+=1
      end
    end
    @numpoints=i
    @sprites["mapbottom"]=MapBottomSprite.new(@viewport)
    @sprites["mapbottom"].maplocation=pbGetMessage(MessageTypes::RegionNames,region)
    @sprites["mapbottom"].mapdetails=_INTL("{1}'s nest",PBSpecies.getName(species))
    if points.length==0
      @sprites["mapbottom"].nonests=true
    end
    return true
  end

  def pbUpdate
    @numpoints.times {|i|
       @sprites["point#{i}"].opacity=[64,96,128,160,128,96][(Graphics.frame_count/4)%6]
    }
  end

  def pbMapScene(listlimits,species)
    Graphics.transition
    ret=0
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::LEFT)
        ret=4
        break
      elsif Input.trigger?(Input::RIGHT)
        ret=6
        break
      elsif Input.trigger?(Input::UP) && listlimits&1==0 # If not at top of list
        ret=8
        break
      elsif Input.trigger?(Input::DOWN) && listlimits&2==0 # If not at end of list
        ret=2
        break
      elsif Input.trigger?(:PAGEDOWN)
        region = (@currentregion - 1) % NUMREGIONMAPS
        @sprites["background"]=IconSprite.new(0,0,@viewport)
        @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/pokedexNest"))
        if $game_switches[AdvancedPokedexScene::SWITCH]
           @sprites["dexbar"]=IconSprite.new(0,0,@viewport)
           @sprites["dexbar"].setBitmap(_INTL("Graphics/Pictures/Pokedex/advancedPokedexNestBar"))
        end
        @currentregion = region
         
        @sprites["map"]=IconSprite.new(0,0,@viewport)
        @sprites["map"].setBitmap("Graphics/Pictures/#{@mapdata[region][1]}")
        @sprites["map"].x+=(Graphics.width-@sprites["map"].bitmap.width)/2
        @sprites["map"].y+=(Graphics.height-@sprites["map"].bitmap.height)/2
        for hidden in REGIONMAPEXTRAS
          if hidden[0]==region && hidden[1]>0 && $game_switches[hidden[1]]
            if !@sprites["map2"]
              @sprites["map2"]=BitmapSprite.new(480,320,@viewport)
              @sprites["map2"].x=@sprites["map"].x; @sprites["map2"].y=@sprites["map"].y
            end
            pbDrawImagePositions(@sprites["map2"].bitmap,[
               ["Graphics/Pictures/#{hidden[4]}",
                  hidden[2]*PokemonRegionMapScene::SQUAREWIDTH,
                  hidden[3]*PokemonRegionMapScene::SQUAREHEIGHT,0,0,-1,-1]
            ])
          end
        end
        @point=BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH+4,
                                 PokemonRegionMapScene::SQUAREHEIGHT+4)
        @point.fill_rect(0,0,
                         PokemonRegionMapScene::SQUAREWIDTH+4,
                         PokemonRegionMapScene::SQUAREHEIGHT+4,Color.new(255,0,0))
        @point2=BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH+4,
                                  PokemonRegionMapScene::SQUAREHEIGHT+4)
        @point2.fill_rect(4,0,
                          PokemonRegionMapScene::SQUAREWIDTH,
                          PokemonRegionMapScene::SQUAREHEIGHT+4,Color.new(255,0,0))
        @point3=BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH+4,
                                  PokemonRegionMapScene::SQUAREHEIGHT+4)
        @point3.fill_rect(0,4,
                          PokemonRegionMapScene::SQUAREWIDTH+4,
                          PokemonRegionMapScene::SQUAREHEIGHT,Color.new(255,0,0))
        @point4=BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH+4,
                                  PokemonRegionMapScene::SQUAREHEIGHT+4)
        @point4.fill_rect(4,4,
                          PokemonRegionMapScene::SQUAREWIDTH,
                          PokemonRegionMapScene::SQUAREHEIGHT,Color.new(255,0,0))
        encdata=load_data("Data/encounters.dat")
        points=[]
        mapwidth=1+PokemonRegionMapScene::RIGHT-PokemonRegionMapScene::LEFT
        for enc in encdata.keys
          enctypes=encdata[enc][1]
          if pbFindEncounter(enctypes,species)
            mappos=pbGetMetadata(enc,MetadataMapPosition)
            if mappos && mappos[0]==region
              showpoint=true
              for loc in @mapdata[region][2]
                showpoint=false if loc[0]==mappos[1] && loc[1]==mappos[2] &&
                                   loc[7] && !$game_switches[loc[7]]
              end
              if showpoint
                mapsize=pbGetMetadata(enc,MetadataMapSize)
                if mapsize && mapsize[0] && mapsize[0]>0
                  sqwidth=mapsize[0]
                  sqheight=(mapsize[1].length*1.0/mapsize[0]).ceil
                  for i in 0...sqwidth
                    for j in 0...sqheight
                      if mapsize[1][i+j*sqwidth,1].to_i>0
                        points[mappos[1]+i+(mappos[2]+j)*mapwidth]=true
                      end
                    end
                  end
                else
                  points[mappos[1]+mappos[2]*mapwidth]=true
                end
              end
            end
          end
        end
        i=0
        for j in 0...points.length
          if points[j]
            s=SpriteWrapper.new(@viewport)
            s.x=(j%mapwidth)*PokemonRegionMapScene::SQUAREWIDTH-2
            s.x+=(Graphics.width-@sprites["map"].bitmap.width)/2
            s.y=(j/mapwidth)*PokemonRegionMapScene::SQUAREHEIGHT-2
            s.y+=(Graphics.height-@sprites["map"].bitmap.height)/2
            if j>=1 && points[j-1]
              if j>=mapwidth && points[j-mapwidth]
                s.bitmap=@point4
              else
                s.bitmap=@point2
              end
            else
              if j>=mapwidth && points[j-mapwidth]
                s.bitmap=@point3
              else
                s.bitmap=@point
              end
            end
            @sprites["point#{i}"]=s
            i+=1
          end
        end
        @numpoints=i
        @sprites["mapbottom"]=MapBottomSprite.new(@viewport)
        @sprites["mapbottom"].maplocation=pbGetMessage(MessageTypes::RegionNames,region)
        @sprites["mapbottom"].mapdetails=_INTL("{1}'s nest",PBSpecies.getName(species))
        if points.length==0
          @sprites["mapbottom"].nonests=true
        end
        pbFadeInAndShow(@sprites){ pbUpdate }
      elsif Input.trigger?(:PAGEUP)
        region = (@currentregion + 1) % NUMREGIONMAPS
        @sprites["background"]=IconSprite.new(0,0,@viewport)
        @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/pokedexNest"))
        if $game_switches[AdvancedPokedexScene::SWITCH]
           @sprites["dexbar"]=IconSprite.new(0,0,@viewport)
           @sprites["dexbar"].setBitmap(_INTL("Graphics/Pictures/Pokedex/advancedPokedexNestBar"))
        end
        @currentregion = region 
        @sprites["map"]=IconSprite.new(0,0,@viewport)
        @sprites["map"].setBitmap("Graphics/Pictures/#{@mapdata[region][1]}")
        @sprites["map"].x+=(Graphics.width-@sprites["map"].bitmap.width)/2
        @sprites["map"].y+=(Graphics.height-@sprites["map"].bitmap.height)/2
        for hidden in REGIONMAPEXTRAS
          if hidden[0]==region && hidden[1]>0 && $game_switches[hidden[1]]
            if !@sprites["map2"]
              @sprites["map2"]=BitmapSprite.new(480,320,@viewport)
              @sprites["map2"].x=@sprites["map"].x; @sprites["map2"].y=@sprites["map"].y
            end
            pbDrawImagePositions(@sprites["map2"].bitmap,[
               ["Graphics/Pictures/#{hidden[4]}",
                  hidden[2]*PokemonRegionMapScene::SQUAREWIDTH,
                  hidden[3]*PokemonRegionMapScene::SQUAREHEIGHT,0,0,-1,-1]
            ])
          end
        end
        @point=BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH+4,
                                 PokemonRegionMapScene::SQUAREHEIGHT+4)
        @point.fill_rect(0,0,
                         PokemonRegionMapScene::SQUAREWIDTH+4,
                         PokemonRegionMapScene::SQUAREHEIGHT+4,Color.new(255,0,0))
        @point2=BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH+4,
                                  PokemonRegionMapScene::SQUAREHEIGHT+4)
        @point2.fill_rect(4,0,
                          PokemonRegionMapScene::SQUAREWIDTH,
                          PokemonRegionMapScene::SQUAREHEIGHT+4,Color.new(255,0,0))
        @point3=BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH+4,
                                  PokemonRegionMapScene::SQUAREHEIGHT+4)
        @point3.fill_rect(0,4,
                          PokemonRegionMapScene::SQUAREWIDTH+4,
                          PokemonRegionMapScene::SQUAREHEIGHT,Color.new(255,0,0))
        @point4=BitmapWrapper.new(PokemonRegionMapScene::SQUAREWIDTH+4,
                                  PokemonRegionMapScene::SQUAREHEIGHT+4)
        @point4.fill_rect(4,4,
                          PokemonRegionMapScene::SQUAREWIDTH,
                          PokemonRegionMapScene::SQUAREHEIGHT,Color.new(255,0,0))
        encdata=load_data("Data/encounters.dat")
        points=[]
        mapwidth=1+PokemonRegionMapScene::RIGHT-PokemonRegionMapScene::LEFT
        for enc in encdata.keys
          enctypes=encdata[enc][1]
          if pbFindEncounter(enctypes,species)
            mappos=pbGetMetadata(enc,MetadataMapPosition)
            if mappos && mappos[0]==region
              showpoint=true
              for loc in @mapdata[region][2]
                showpoint=false if loc[0]==mappos[1] && loc[1]==mappos[2] &&
                                   loc[7] && !$game_switches[loc[7]]
              end
              if showpoint
                mapsize=pbGetMetadata(enc,MetadataMapSize)
                if mapsize && mapsize[0] && mapsize[0]>0
                  sqwidth=mapsize[0]
                  sqheight=(mapsize[1].length*1.0/mapsize[0]).ceil
                  for i in 0...sqwidth
                    for j in 0...sqheight
                      if mapsize[1][i+j*sqwidth,1].to_i>0
                        points[mappos[1]+i+(mappos[2]+j)*mapwidth]=true
                      end
                    end
                  end
                else
                  points[mappos[1]+mappos[2]*mapwidth]=true
                end
              end
            end
          end
        end
        i=0
        for j in 0...points.length
          if points[j]
            s=SpriteWrapper.new(@viewport)
            s.x=(j%mapwidth)*PokemonRegionMapScene::SQUAREWIDTH-2
            s.x+=(Graphics.width-@sprites["map"].bitmap.width)/2
            s.y=(j/mapwidth)*PokemonRegionMapScene::SQUAREHEIGHT-2
            s.y+=(Graphics.height-@sprites["map"].bitmap.height)/2
            if j>=1 && points[j-1]
              if j>=mapwidth && points[j-mapwidth]
                s.bitmap=@point4
              else
                s.bitmap=@point2
              end
            else
              if j>=mapwidth && points[j-mapwidth]
                s.bitmap=@point3
              else
                s.bitmap=@point
              end
            end
            @sprites["point#{i}"]=s
            i+=1
          end
        end
        @numpoints=i
        @sprites["mapbottom"]=MapBottomSprite.new(@viewport)
        @sprites["mapbottom"].maplocation=pbGetMessage(MessageTypes::RegionNames,region)
        @sprites["mapbottom"].mapdetails=_INTL("{1}'s nest",PBSpecies.getName(species))
        if points.length==0
          @sprites["mapbottom"].nonests=true
        end
        pbFadeInAndShow(@sprites){ pbUpdate }
      elsif Input.trigger?(Input::B)
        ret=1
        pbPlayCancelSE()
        pbFadeOutAndHide(@sprites)
        break
      end
    end
    return ret
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @point.dispose
    @viewport.dispose
  end
end



class PokemonNestMap
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(species,region,listlimits)
    @scene.pbStartScene(species,region)
    ret=@scene.pbMapScene(listlimits,species)
    @scene.pbEndScene
    return ret
  end
end



################################################################################
# Shows the "Form" page of the Pokédex entry screen.
################################################################################
class PokedexFormScene
  def pbStartScene(species)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @species=species
    @gender=$Trainer.formlastseen[species][0]
    @form=$Trainer.formlastseen[species][1]
    @available=pbGetAvailable # [name, gender, form]
    @sprites={}
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/pokedexForm"))
     if $game_switches[AdvancedPokedexScene::SWITCH]
       @sprites["dexbar"]=IconSprite.new(0,0,@viewport)
       @sprites["dexbar"].setBitmap(_INTL("Graphics/Pictures/Pokedex/advancedPokedexFormBar"))
     end
    @sprites["info"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["front"]=PokemonSprite.new(@viewport)
    @sprites["back"]=PokemonSprite.new(@viewport)
    @sprites["icon"]=PokemonSpeciesIconSprite.new(@species,@viewport)
    @sprites["icon"].gender=@gender
    @sprites["icon"].form=@form
    @sprites["icon"].x=52
    @sprites["icon"].y=290
    pbUpdate
    return true
  end

  def pbUpdate
    @sprites["info"].bitmap.clear
    pbSetSystemFont(@sprites["info"].bitmap)
    name=""
    for i in @available
      if i[1]==@gender && i[2]==@form
        name=i[0]
        break
      end
    end
    text=[
       [_INTL("{1}",PBSpecies.getName(@species)),
          (Graphics.width+72)/2,Graphics.height-86,2,
          Color.new(88,88,80),Color.new(168,184,184)],
       [_INTL("{1}",name),
          (Graphics.width+72)/2,Graphics.height-54,2,
          Color.new(88,88,80),Color.new(168,184,184)],
    ]
    pbDrawTextPositions(@sprites["info"].bitmap,text)
    frontBitmap=pbCheckPokemonBitmapFiles([@species,false,(@gender==1),false,@form,false])
    if frontBitmap
      frontSprite=AnimatedBitmap.new(frontBitmap)
      @sprites["front"].bitmap=frontSprite.bitmap
    end
    backBitmap=pbCheckPokemonBitmapFiles([@species,true,(@gender==1),false,@form,false])
    if backBitmap
      backSprite=AnimatedBitmap.new(backBitmap)
      @sprites["back"].bitmap=backSprite.bitmap
    end
    metrics=load_data("Data/metrics.dat")
    backMetric=metrics[0][@species]
    pbPositionPokemonSprite(@sprites["front"],74,96)
    pbPositionPokemonSprite(@sprites["back"],310,96)
#    @sprites["icon"].update
  end

  def pbGetAvailable
    available=[] # [name, gender, form]
    genderbyte=$pkmn_dex[@species][7]
    formnames=pbGetMessage(MessageTypes::FormNames,@species)
    if !formnames || formnames==""
      formnames=[""]
    else
      formnames=strsplit(formnames,/,/)
    end
    @gender=0 if genderbyte==0 || genderbyte==255 # Always male or genderless
    @gender=1 if genderbyte==254 # Always female
    if formnames && formnames[0]!=""
      for j in 0...2
        if $Trainer.formseen[@species][j][0] || ALWAYSSHOWALLFORMS # That gender/form has been seen
          if pbResolveBitmap(sprintf("Graphics/Battlers/%sf",getConstantName(PBSpecies,@species))) ||
             pbResolveBitmap(sprintf("Graphics/Battlers/%03df",@species))
            available.push([_INTL("{1} Male",formnames[0]),j,0]) if j==0
            available.push([_INTL("{1} Female",formnames[0]),j,0]) if j==1
          else
            gendertopush=(genderbyte==254) ? 1 : 0
            available.push([formnames[0],gendertopush,0])
            break
          end
        end
      end
    else
      if $Trainer.formseen[@species][0][0] || ALWAYSSHOWALLFORMS # Male/form 0 has been seen
        if genderbyte!=254 && genderbyte!=255 # Not always female & not genderless
          available.push([_INTL("Male"),0,0])
        end
      end
      if $Trainer.formseen[@species][1][0] || ALWAYSSHOWALLFORMS # Female/form 0 has been seen
        if genderbyte!=0 && genderbyte!=255 # Not always male & not genderless
          available.push([_INTL("Female"),1,0])
        end
      end
      if $Trainer.formseen[@species][0][0] || ALWAYSSHOWALLFORMS # Genderless/form 0 has been seen
        if genderbyte==255 # Genderless
          if formnames && formnames.length>1
            available.push([_INTL("One Form"),0,0])
          else
            available.push([_INTL("Genderless"),0,0])
          end
        end
      end
    end
    for i in 1...formnames.length
      for j in 0...2
        if $Trainer.formseen[@species][j][i] || ALWAYSSHOWALLFORMS # That gender/form has been seen
          if pbResolveBitmap(sprintf("Graphics/Battlers/%sf_%d",getConstantName(PBSpecies,@species),i)) ||
             pbResolveBitmap(sprintf("Graphics/Battlers/%03df_%d",@species,i))
            available.push([_INTL("{1} Male",formnames[i]),j,i]) if j==0
            available.push([_INTL("{1} Female",formnames[i]),j,i]) if j==1
          else
            available.push([formnames[i],j,i])
            break
          end
        end
      end
    end
    return available
  end

  def pbGetCommands
    commands=[]
    for i in @available
      commands.push(i[0])
    end
    return commands
  end

  def pbChooseForm
    oldgender=@gender
    oldform=@form
    commands=pbGetCommands
    using(cmdwindow=Window_CommandPokemon.new(commands)) {
       cmdwindow.height=128 if cmdwindow.height>128
       cmdwindow.z=@viewport.z+1
       pbBottomRight(cmdwindow)
       for i in 0...@available.length
         if @available[i][1]==@gender && @available[i][2]==@form
           cmdwindow.index=i
           break
         end
       end
       loop do
         oldindex=cmdwindow.index
         Graphics.update
         Input.update
         cmdwindow.update
         @sprites["icon"].update
         if cmdwindow.index!=oldindex
           @gender=@sprites["icon"].gender=@available[cmdwindow.index][1]
           @form=@sprites["icon"].form=@available[cmdwindow.index][2]
           pbUpdate
         end
         if Input.trigger?(Input::B)
           pbPlayCancelSE()
           @gender=@sprites["icon"].gender=oldgender
           @form=@sprites["icon"].form=oldform
           break
         end
         if Input.trigger?(Input::C)
           pbPlayDecisionSE()
           break
         end
       end
    }
  end

  def pbControls(listlimits)
    Graphics.transition
    ret=0
    loop do
      Graphics.update
      Input.update
      @sprites["icon"].update
      if Input.trigger?(Input::C)
        pbChooseForm
      elsif Input.trigger?(Input::RIGHT)
        if $game_switches[704]
         ret=6
         break
        end
      elsif Input.trigger?(Input::LEFT)
        ret=4
        break
      elsif Input.trigger?(Input::UP) && listlimits&1==0 # If not at top of list
        ret=8
        break
      elsif Input.trigger?(Input::DOWN) && listlimits&2==0 # If not at end of list
        ret=2
        break
      elsif Input.trigger?(Input::B)
        ret=1
        pbPlayCancelSE()
        pbFadeOutAndHide(@sprites)
        break
      end
    end
    $Trainer.formlastseen[@species][0]=@gender
    $Trainer.formlastseen[@species][1]=@form
    return ret
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokedexForm
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(species,listlimits)
    @scene.pbStartScene(species)
    ret=@scene.pbControls(listlimits)
    @scene.pbEndScene
    return ret
  end
end