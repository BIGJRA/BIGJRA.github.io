###Collects the flags pertaining to the current battle. If you code in additionnal
###functions that return flags, don't forget to add them to this function so they're
### properly processed.
def collectBattleResultFlags
  collectedFlags = []
  tempvar = $battleDataArray.last().afterBattleStateOfPartyResult
  collectedFlags << tempvar if !tempvar.nil?
  collectedFlags << $battleDataArray.last().afterBattleItemsResult
  tempvar = $battleDataArray.last().isThereMVP
  collectedFlags << tempvar if !tempvar.nil?
  tempvar = $battleDataArray.last().getMoveData
  collectedFlags << tempvar if !tempvar.nil?
  tempvar = $battleDataArray.last().getRematchData
  ###those two are different from the other functions because they return arrays 
  ###rather thans strings
  collectedFlags += tempvar
  tempvar = $battleDataArray.last().miscFlags
  collectedFlags += tempvar
  return collectedFlags
end


###This function mostly exists to check that there is any flag to return at all.
###The main use is to use it in the conditionnal branch of an event so that it can
###just ignore the rest of the script entirely if there's no message to print.
def returnAppropriateFlag(flagcollection)
  a = collectBattleResultFlags & flagcollection
  if a.nil? || a.length<1
    return nil
  else
    return a
  end
end

###Those are the arrays that you pass to the above function as parameter so as to
### not overload a single battle with too many messages at once. Feel free to
### customize them or create new ones at will. Just make sure the flag names match
### with both the PBS file and the corresponding function BattleData
$flagCollectionBattleOverall = ["CLOSE_CALL", "CURB_STOMP","6-0"]

$flagCollectionBattleDetails = ["MVP"]

$flagCollectionItems = ["NO_ITEMS", "LESS_ITEMS_THAN_OPPONENT", "MORE_ITEMS_THAN_OPPONENT"]

$flagCollectionRematch = ["SAME_TEAM_SAME_MVP","SAME_TEAM_DIFFERENT_MVP", 
"SAME_TEAM_NEW_MVP","MVP_MEGA", "MVP_EVOLVED",
"MVP_Z_CRYSTAL", "NEW_TEAM_NEW_MVP","NEW_TEAM_SAME_MVP", "NEW_TEAM_DIFFERENT_MVP", "OLD_MVP_DISAPPEARED"]

$flagCollectionMisc = ["IDENTICAL_NICKNAMES", "MONOTYPE", "OUTNUMBERED","OUTNUMBERING"]

$flagCollectionMoveSpam= ["SPAMMED_LISTED_MOVE","SPAMMED_UNSPECIFIED_MOVE"]