class Reset < Exception
  
end
#=============================================================================
# ** Module Graphics
#=============================================================================
module Graphics
  class << self
    #-------------------------------------------------------------------------
    # * Aliases Graphics.update and Graphics.transition
    #-------------------------------------------------------------------------
    unless self.method_defined?(:zeriab_f12_removal_update)
      alias_method(:zeriab_f12_removal_update, :update)
      alias_method(:zeriab_f12_removal_transition, :transition)
    end
    def update(*args)
      begin
        zeriab_f12_removal_update(*args)
      rescue Reset 
        if defined?($game_variables) && $game_variables[1001].to_i>0
          $game_variables[1001]=$game_variables[1001].to_i
          $game_variables[1001]+=1
          pbSaveVariables($game_variables[1001])
        end
        raise
      end
    end
  end
end
 

def pbSaveVariables(toSave)
    File.open("Data/temp.dat", "w") { |f| f.write toSave }
end

def pbResetSaveVariable
   File.open("Data/temp.dat", "w") { |f| f.write "0" }
end