class PokemonSaveScene
  def pbStartScreen
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    totalsec = Graphics.frame_count / 44 #Graphics.frame_rate  #Because Turbo exists
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    mapname=$game_map.name
    textColor=["0070F8,78B8E8","E82010,F8A8B8","0070F8,78B8E8"][$Trainer.gender]
    loctext=_INTL("<ac><c2=06644bd2>{1}</c2></ac>",mapname)
    loctext+=_INTL("Player<r><c3={1}>{2}</c3><br>",textColor,$Trainer.name)
    loctext+=_ISPRINTF("Time<r><c3={1:s}>{2:02d}:{3:02d}</c3><br>",textColor,hour,min)
    loctext+=_INTL("Badges<r><c3={1}>{2}</c3><br>",textColor,$Trainer.numbadges)
    if $Trainer.pokedex
      loctext+=_INTL("Pokédex<r><c3={1}>{2}/{3}</c3><br>",textColor,$Trainer.pokedexOwned,$Trainer.pokedexSeen)
    end
    if $game_variables[542]>1
      loctext+=_INTL("Save File:<r><c3={1}>{2}</c3><br>",textColor,$game_variables[542])
    else
      loctext+=_INTL("Save File:<r><c3={1}>1</c3><br>",textColor)
    end
    @sprites["locwindow"]=Window_AdvancedTextPokemon.new(loctext)
    @sprites["locwindow"].viewport=@viewport
    @sprites["locwindow"].x=0
    @sprites["locwindow"].y=0
    @sprites["locwindow"].width=228 if @sprites["locwindow"].width<228
    @sprites["locwindow"].visible=true
  end
 
  def pbEndScreen
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end
 
 
 
def pbEmergencySave
  oldscene=$scene
  $scene=nil
  Kernel.pbMessage(_INTL("The script is taking too long.  The game will restart."))
  return if !$Trainer
  if $game_variables[542]>1
    savename="Game_"+$game_variables[542].to_s+".rxdata"\
  else
    savename="Game.rxdata"
  end
  if safeExists?(RTP.getSaveFileName("Game.rxdata"))
    File.open(RTP.getSaveFileName("Game.rxdata"),  'rb') {|r|
       File.open(RTP.getSaveFileName("Game.rxdata.bak"), 'wb') {|w|
          while s = r.read(4096)
            w.write s
          end
       }
    }
  end
#if Kernel.pbConfirmMessage(_INTL("Would you like to save the game?"))
  if pbSave
    Kernel.pbMessage(_INTL("\\se[]The game was saved.\\se[save]\\wtnp[30]"))
  else
    Kernel.pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
  end
#end
  $scene=oldscene
end
 
def pbAutoSave(safesave=false)
  if $game_variables[542]>1
      savename="Game_"+$game_variables[542].to_s+"_autosave.rxdata"
  else
      savename="Game_autosave.rxdata"
  end
begin
      File.open(RTP.getSaveFileName(savename),"wb"){|f|
      Marshal.dump($Trainer,f)
      Marshal.dump(Graphics.frame_count,f)
      if $data_system.respond_to?("magic_number")
        $game_system.magic_number = $data_system.magic_number
      else
        $game_system.magic_number = $data_system.version_id
      end
      $game_system.save_count+=1
      Marshal.dump($game_system,f)
      Marshal.dump($PokemonSystem,f)
      Marshal.dump($game_map.map_id,f)
      Marshal.dump($game_switches,f)
      Marshal.dump($game_variables,f)
      Marshal.dump($game_self_switches,f)
      Marshal.dump($game_screen,f)
      Marshal.dump($MapFactory,f)
      Marshal.dump($game_player,f)
      $PokemonGlobal.safesave=safesave
      Marshal.dump($PokemonGlobal,f)
      Marshal.dump($PokemonMap,f)
      Marshal.dump($PokemonBag,f)
      Marshal.dump($PokemonStorage,f)
      Marshal.dump($achievements,f)
    }
    Graphics.frame_reset
   rescue
    return false
  end
  pbStoredLastPlayed($game_variables[542],true)
  return true
end
 
def pbSave(safesave=false)
  if $PokemonSystem.backup == 0
    counter = 0
    trainer    = nil
    mapid      = nil
    framecount = nil
    system     = nil
    if $game_variables[542]>1
      actual_savename="Game_"+$game_variables[542].to_s+".rxdata"
    else
      actual_savename="Game.rxdata"
    end
    if safeExists?(RTP.getSaveFileName(actual_savename))
      File.open(RTP.getSaveFileName(actual_savename),  'rb') {|save|
        trainer    = Marshal.load(save) # Trainer 
        framecount = Marshal.load(save) # Graphics
        system     = Marshal.load(save) # Game System
        Marshal.load(save)              # Pokemon System
        mapid      = Marshal.load(save) # Map ID 
      }
      number = 1
      if trainer.saveNumber
        number += trainer.saveNumber
      end
      if !$PokemonSystem.backupNames
        $PokemonSystem.backupNames = []
        number = 1
      end
      if number > $PokemonSystem.maxBackup 
        for i in 0...(number - $PokemonSystem.maxBackup )
          if $PokemonSystem.backupNames[i]
            if safeExists?(RTP.getSaveFileName($PokemonSystem.backupNames[i]))
              File.delete(RTP.getSaveFileName($PokemonSystem.backupNames[i]))
            end
          end
        end
      end
      totalsec = framecount / 44 #Graphics.frame_rate  #Because Turbo exists
      hour = totalsec / 60 / 60
      min = totalsec / 60 % 60
      map = pbGetMapNameFromId(mapid)
      trainame = trainer.name
      trainame.gsub!(/[^0-9A-Za-z]/, '')
      savename = "Game - #{number} - #{trainame} - #{hour}h #{min}m - #{trainer.numbadges} badges.rxdata"
      if $game_variables[542]>1
        savename = "Game_#{$game_variables[542]} - #{number} - #{trainame} - #{hour}h #{min}m - #{trainer.numbadges} badges.rxdata"
      end      
      $Trainer.lastSave   = savename
      $Trainer.saveNumber = number
      $PokemonSystem.backupNames.push(savename)
       File.open(RTP.getSaveFileName(actual_savename),  'rb') {|oldsave|
        File.open(RTP.getSaveFileName("#{savename}"), 'wb') {|backup|
          while line = oldsave.read(4096)
            backup.write line
          end
        }
      }
    end
  end
  return pbSaveOld(safesave)
end
 
def pbSaveOld(safesave=false)
  $Trainer.metaID=$PokemonGlobal.playerID
  if $game_variables[542]>1
    savename="Game_"+$game_variables[542].to_s+".rxdata"
  else
    savename="Game.rxdata"
  end
  begin  
      File.open(RTP.getSaveFileName(savename),"wb"){|f|
       Marshal.dump($Trainer,f)
       Marshal.dump(Graphics.frame_count,f)
       if $data_system.respond_to?("magic_number")
         $game_system.magic_number = $data_system.magic_number
       else
         $game_system.magic_number = $data_system.version_id
       end
       $game_system.save_count+=1
       Marshal.dump($game_system,f)
       Marshal.dump($PokemonSystem,f)
       Marshal.dump($game_map.map_id,f)
       Marshal.dump($game_switches,f)
       Marshal.dump($game_variables,f)
       Marshal.dump($game_self_switches,f)
       Marshal.dump($game_screen,f)
       Marshal.dump($MapFactory,f)
       Marshal.dump($game_player,f)
       $PokemonGlobal.safesave=safesave
       Marshal.dump($PokemonGlobal,f)
       Marshal.dump($PokemonMap,f)
       Marshal.dump($PokemonBag,f)
       Marshal.dump($PokemonStorage,f)
       Marshal.dump($achievements,f)
     }
     Graphics.frame_reset
    rescue
    return false
  end
  pbStoredLastPlayed($game_variables[542],nil)
  return true
end
 
 
 
class PokemonSave
  def initialize(scene)
    @scene=scene
  end
 
  def pbDisplay(text,brief=false)
    @scene.pbDisplay(text,brief)
  end
 
  def pbDisplayPaused(text)
    @scene.pbDisplayPaused(text)
  end
 
  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end
 
  def pbSaveScreen
    ret=false
    @scene.pbStartScreen
    if Kernel.pbConfirmMessage(_INTL("Would you like to save the game?"))
      if $game_variables[542]>1
        savename="Game_"+$game_variables[542].to_s+".rxdata"
      else
        savename="Game.rxdata"
      end
      if safeExists?(RTP.getSaveFileName(savename))
        confirm=""
          if !Kernel.pbConfirmMessage(
             _INTL("There is already a saved file.  Is it OK to overwrite it?"))
            @scene.pbEndScreen
            return false
        end
      end
      $PokemonTemp.begunNewGame=false
      if pbSave
        Kernel.pbMessage(_INTL("\\se[]{1} saved the game.\\se[save]\\wtnp[30]",$Trainer.name))
        ret=true
      else
        Kernel.pbMessage(_INTL("\\se[]Save failed.\\wtnp[30]"))
        ret=false
      end
    end
    @scene.pbEndScreen
    return ret
  end
end