###This is the thing you should call in your events after you made sure there are 
###flags to react to with ProcessFlags. The character name should be given directly,
###while the flags should be passed by using ReturnAppropriateFlags and giving an array
###of possible flags as parameter of that function

###a good 60% of the code is just getting variables and replacing them in the text
###if necessary.
def characterResponses(character,flags)
  flag=flags[0]
  mvps = $battleDataArray.last().getMVPs
  lvps = $battleDataArray.last().getLVPs
  mvp_1=mvps[0].name if !mvps[0].nil?
  mvp_2=mvps[1].name if !mvps[1].nil?
  mvp_3=mvps[2].name if !mvps[2].nil?
  mvp_4=mvps[3].name if !mvps[3].nil?
  lvp_1=lvps[0].name if !lvps[0].nil?
  lvp_2=lvps[1].name if !lvps[1].nil?
  lvp_3=lvps[2].name if !lvps[2].nil?
  lvp_4=lvps[3].name if !lvps[3].nil?
  old_mvp_1=$battleDataArray.last().oldMVPName if !$battleDataArray.last().oldMVPName.nil?
  type= $battleDataArray.last().monotype if !$battleDataArray.last().monotype.nil?
  nickname= $battleDataArray.last().nickname if !$battleDataArray.last().nickname.nil?
  move = $battleDataArray.last().mostUsedMove if !$battleDataArray.last().mostUsedMove.nil?
  if(defined?($NPCReactions[character.upcase][flag]))
    i=0
    while i<$NPCReactions[character.upcase][flag].length
      message = $NPCReactions[character.upcase][flag][i]
      message.gsub! '#{mvp_1}',mvp_1 if !mvp_1.nil?
      message.gsub! '#{mvp_2}',mvp_2 if !mvp_2.nil?
      message.gsub! '#{mvp_3}',mvp_3 if !mvp_3.nil?
      message.gsub! '#{mvp_4}',mvp_4 if !mvp_4.nil?
      message.gsub! '#{lvp_1}',lvp_1 if !lvp_1.nil?
      message.gsub! '#{lvp_2}',lvp_2 if !lvp_2.nil?
      message.gsub! '#{lvp_3}',lvp_3 if !lvp_3.nil?
      message.gsub! '#{lvp_4}',lvp_4 if !lvp_4.nil?
      message.gsub! '#{old_mvp_1}',old_mvp_1 if !old_mvp_1.nil?
      message.gsub! '#{type}',(PBTypes.getName(type)) if !type.nil?
      message.gsub! '#{nickname}',nickname if !nickname.nil?
      message.gsub! '#{move}',move if !move.nil?
      ###if the message contains a call for a subsequent message, recursively calls
      ###the function with the same paramters after removing the first flag 
      ###it's currently processing
      if(message.include? '#{submessage}')
        if(flags.length>1)
          flags.shift
          characterResponses(character,flags)
        end
      ###if the message contains #CODE, it will excise it from the message and run
      ###the remainder of the message as code.
      ###It will run any code given as long as it's valid Ruby, so don't try anything
      ###too crazy with it.
      elsif message.include? '#CODE'

         ###We check that the code doesn't contain consecutive code message, and if
         ###it does, we run them as a single eval. This allows you to run multiple-lines
         ###code, such as if switches
         thingToRun=""
         while (i<$NPCReactions[character.upcase][flag].length)&& ($NPCReactions[character.upcase][flag][i].include?'#CODE')
           message = $NPCReactions[character.upcase][flag][i]
           message.slice! '#CODE'
           thingToRun+=message+";"
           i+=1
         end
         eval(thingToRun)
      else
         Kernel.pbMessage(message)
      end
      i+=1
    end
  else
  ###Default message in case something goes wrong somewhere for some reason.
  ###If you get this but can't find any reason why it shouldn't work, double check
  ###that you didn't forgot the section separator at the end of your PBS file.
  Kernel.pbMessage("Okay, I have no idea how you got this message, but you're trying to load a reaction that doesn't exist.")
  Kernel.pbMessage("The character was #{character} and the flag was #{flag}")
  end
end