module PBDebug
  def PBDebug.logonerr
    begin
      yield
    rescue
      PBDebug.log("**Exception: #{$!.message}")
      PBDebug.log("#{$!.backtrace.inspect}")
#      if $INTERNAL
        pbPrintException($!)
#      end
      PBDebug.flush
    end
  end
  @@log=[]
  
  def PBDebug.flush
    #if $DEBUG && $INTERNAL && @@log.length>0
    if $INTERNAL && @@log.length>0
      File.open("Data/debuglog.txt", "a+b") {|f|
         f.write("#{@@log}")
      }
    end
    @@log.clear 
  end

  def PBDebug.log(msg)
    # DEBUG LOGS AUTOMATIC FOR TESTING ONLY, switch which of the next two are commented to change what is being done
    #if $DEBUG && $INTERNAL
    begin
      if File.exist?("Data/debuglog.txt") && File.size("Data/debuglog.txt") > 10_000_000
        File.delete("Data/debuglog.txt")
      end
      if $INTERNAL
        File.open("Data/debuglog.txt", "a+b") {|f|
          f.write("#{msg}\r\n")
        }
      end
    rescue
      $INTERNAL = false
    end
  end

  def PBDebug.dump(msg)
    if $INTERNAL
      begin
        File.open("Data/dumplog.txt", "a+b") { |f| 
          f.write("#{msg}\r\n") 
        }
      rescue
        $INTERNAL = false
      end
    end
  end
end