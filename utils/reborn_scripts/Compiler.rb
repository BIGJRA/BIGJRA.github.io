class Reset < Exception
end

def pbGetExceptionMessage(e,script="")
  emessage=e.message
  if e.is_a?(Hangup)
    emessage="The script is taking too long.  The game will restart."
  elsif e.is_a?(Errno::ENOENT)
    filename=emessage.sub("No such file or directory - ", "")
    emessage="File #{filename} not found."
  end
  if emessage.length > 500
    emessage = emessage[0,500]
  end
  if emessage && !safeExists?("Game.rgssad") && !safeExists?("Game.rgss2a")
    emessage=emessage.gsub(/uninitialized constant PBItems\:\:(\S+)/){
       "The item '#{$1}' is not valid. Please add the item\nto the list of items in the editor. See the wiki for more information." }
    emessage=emessage.gsub(/undefined method `(\S+?)' for PBItems\:Module/){
       "The item '#{$1}' is not valid. Please add the item\nto the list of items in the editor. See the wiki for more information." }
    emessage=emessage.gsub(/uninitialized constant PBTypes\:\:(\S+)/){
       "The type '#{$1}' is not valid. Please add the type\nto the PBS/types.txt file." }
    emessage=emessage.gsub(/undefined method `(\S+?)' for PBTypes\:Module/){
       "The type '#{$1}' is not valid. Please add the type\nto the PBS/types.txt file." }
    emessage=emessage.gsub(/uninitialized constant PBTrainers\:\:(\S+)$/){
       "The trainer type '#{$1}' is not valid. Please add the trainer\nto the list of trainer types in the Editor. See the wiki for\nmore information." }
    emessage=emessage.gsub(/undefined method `(\S+?)' for PBTrainers\:Module/){
       "The trainer type '#{$1}' is not valid. Please add the trainer\nto the list of trainer types in the Editor. See the wiki for\nmore information." }
    emessage=emessage.gsub(/uninitialized constant PBSpecies\:\:(\S+)$/){
       "The Pokemon species '#{$1}' is not valid. Please\nadd the species to the PBS/pokemon.txt file.\nSee the wiki for more information." }
    emessage=emessage.gsub(/undefined method `(\S+?)' for PBSpecies\:Module/){
       "The Pokemon species '#{$1}' is not valid. Please\nadd the species to the PBS/pokemon.txt file.\nSee the wiki for more information." }
  end
 return emessage
end

def pbPrintException(e)
  emessage=pbGetExceptionMessage(e)
  btrace=""
  if e.backtrace
    maxlength=$INTERNAL ? 25 : 10
    e.backtrace[0,maxlength].each do |i|
      btrace=btrace+"#{i}\n"
    end
  end
  btrace.gsub!(/Section(\d+)/){$RGSS_SCRIPTS[$1.to_i][1]}
  message="[#{GAMETITLE} #{GAMEVERSION}]\nException: #{e.class}\nMessage: #{emessage}\n#{btrace}"
  errorlog="errorlog.txt"
  if (Object.const_defined?(:RTP) rescue false)
    errorlog=RTP.getSaveFileName("errorlog.txt")
  end
  errorlogline=errorlog.sub(Dir.pwd+"\\","")
  errorlogline=errorlogline.sub(Dir.pwd+"/","")
  if errorlogline.length>20
    errorlogline="\n"+errorlogline
  end
  return if File.exist?(errorlog) && File.size(errorlog) > 100_000_000
  File.open(errorlog,"ab"){|f| f.write(message);f.write("\n") }
  if !e.is_a?(Hangup)
    print("#{message}\nThis exception was logged in #{errorlogline}.\nPress Ctrl+C to copy this message to the clipboard.")
  end
end

def pbCriticalCode
  ret=0
  begin
    yield
    ret=1
    rescue Exception
    e=$!
    if e.is_a?(Reset) || e.is_a?(SystemExit)
      raise
    else
      pbPrintException(e)
      if e.is_a?(Hangup)
        ret=2
        raise Reset.new
      end
    end
  end
  return ret
end



####################

module FileLineData
  @file=""
  @linedata=""
  @lineno=0
  @section=nil
  @key=nil
  @value=nil

  def self.file
    @file
  end

  def self.file=(value)
    @file=value
  end

  def self.clear
    @file=""
    @linedata=""
    @lineno=""
    @section=nil
    @key=nil
    @value=nil
  end

  def self.linereport
    if @section
      return _INTL("File {1}, section {2}, key {3}\n{4}\n",@file,@section,@key,@value)
    else
      return _INTL("File {1}, line {2}\n{3}\n",@file,@lineno,@linedata)
    end
  end

  def self.setSection(section,key,value)
    @section=section
    @key=key
    if value && value.length>200
      @value=_INTL("{1}...",value[0,200])
    else
      @value=!value ? "" : value.clone
    end
  end

  def self.setLine(line,lineno)
    @section=nil
    if line && line.length>200
      @linedata=_INTL("{1}...",line[0,200])
    else
      @linedata=line
    end
    @lineno=lineno
  end
end

def findIndex(a)
  index=-1
  count=0
  a.each {|i|
     if yield i
       index=count
       break
     end
     count+=1
  }
  return index
end

def prepline(line)
  line.sub!(/\s*\#.*$/,"")
  line.sub!(/\s+$/,"")
  return line
end

def csvfield!(str)
  ret=""
  str.sub!(/^\s*/,"")
  if str[0,1]=="\""
    str[0,1]=""
    escaped=false
    fieldbytes=0
    str.scan(/./) do |s|
      fieldbytes+=s.length
      break if s=="\"" && !escaped
      if s=="\\" && !escaped
        escaped=true
      else
        ret+=s
        escaped=false
      end
    end
    str[0,fieldbytes]=""
    if !str[/^\s*,/] && !str[/^\s*$/]
      raise _INTL("Invalid quoted field (in: {1})\n{2}",str,FileLineData.linereport)
    end
    str[0,str.length]=$~.post_match
  else
    if str[/,/]
      str[0,str.length]=$~.post_match
      ret=$~.pre_match
    else
      ret=str.clone
      str[0,str.length]=""
    end
    ret.gsub!(/\s+$/,"")
  end
  return ret
end

def csvquote(str)
  return "" if !str || str==""
  if str[/[,\"]/] #|| str[/^\s/] || str[/\s$/] || str[/^#/]
    str=str.gsub(/[\"]/,"\\\"")
    str="\"#{str}\""
  end
  return str
end

def csvBoolean!(str,line=-1)
  field=csvfield!(str)
  if field[/^1|[Tt][Rr][Uu][Ee]|[Yy][Ee][Ss]$/]
    return true
  elsif field[/^0|[Ff][Aa][Ll][Ss][Ee]|[Nn][Oo]$/]
    return false
  else
    raise _INTL("Field {1} is not a Boolean value (true, false, 1, 0)\n{2}",field,FileLineData.linereport)
    return false
  end
end

def csvPosInt!(str,line=-1)
  ret=csvfield!(str)
  if !ret[/^\d+$/]
    raise _INTL("Field {1} is not a positive integer\n{2}",ret,FileLineData.linereport)
  end
  return ret.to_i
end

def csvInt!(str,line=-1)
  ret=csvfield!(str)
  if !ret[/^\-?\d+$/]
    raise _INTL("Field {1} is not an integer\n{2}",ret,FileLineData.linereport)
  end
  return ret.to_i
end

def csvFloat!(str,key,section)
  ret=csvfield!(str)
  return Float(ret) rescue raise _INTL("Field {1} is not a number\n{2}",ret,FileLineData.linereport)
end

def pbGetCsvRecord(rec,lineno,schema)
  record=[]
  repeat=false
  if schema[1][0,1]=="*"
    repeat=true
    start=1
  else
    repeat=false
    start=0
  end
  begin
    for i in start...schema[1].length
      chr=schema[1][i,1]
      case chr
        when "u"
          record.push(csvPosInt!(rec,lineno))
        when "v"
          field=csvPosInt!(rec,lineno)
          raise _INTL("Field '{1}' must be greater than 0\n{2}",field,FileLineData.linereport) if field==0
          record.push(field)
        when "i"
          record.push(csvInt!(rec,lineno))
        when "U", "I"
          field=csvfield!(rec)
          if field==""
            record.push(nil)
          elsif !field[/^\d+$/]
            raise _INTL("Field '{1}' must be 0 or greater\n{2}",field,FileLineData.linereport)
          else
            record.push(field.to_i)
          end
        when "x"
          field=csvfield!(rec)
          if !field[/^[A-Fa-f0-9]+$/]
            raise _INTL("Field '{1}' is not a hexadecimal number\n{2}",field,FileLineData.linereport)
          end
          record.push(field.hex)
        when "s"
          record.push(csvfield!(rec))
        when "S"
          field=csvfield!(rec)
          if field==""
            record.push(nil)
          else
            record.push(field)
          end
        when "n" # Name
          field=csvfield!(rec)
          if !field[/^(?![0-9])\w+$/]
            raise _INTL("Field '{1}' must contain only letters, digits, and\nunderscores and can't begin with a number.\n{2}",field,FileLineData.linereport)
          end
          record.push(field)
        when "N" # Optional name
          field=csvfield!(rec)
          if field==""
            record.push(nil)
          else
            if !field[/^(?![0-9])\w+$/]
              raise _INTL("Field '{1}' must contain only letters, digits, and\nunderscores and can't begin with a number.\n{2}",field,FileLineData.linereport)
            end
            record.push(field)
          end
        when "b"
          record.push(csvBoolean!(rec,lineno))
        when "e"
          record.push(csvEnumField!(rec,schema[2+i-start],"",FileLineData.linereport))
      end
    end
    break if repeat && rec==""
  end while repeat
  return (schema[1].length==1) ? record[0] : record
end

def pbWriteCsvRecord(record,file,schema)
  if !record.is_a?(Array)
    rec=[record]
  else
    rec=record.clone
  end
  for i in 0...schema[1].length
    chr=schema[1][i,1]
    file.write(",") if i>0
    if rec[i].nil?
      # do nothing
    elsif rec[i].is_a?(String)
      file.write(csvquote(rec[i]))
    elsif rec[i]==true
      file.write("true")
    elsif rec[i]==false
      file.write("false")
    elsif rec[i].is_a?(Numeric)
      case chr
        when "e"
          enumer=schema[2+i]
          if enumer.is_a?(Array)
            file.write(enumer[rec[i]])
          elsif enumer.is_a?(Symbol) || enumer.is_a?(String)
            mod=Object.const_get(enumer.to_sym)
            if enumer.to_s=="PBTrainers" && !mod.respond_to?("getCount")
              file.write((getConstantName(mod,rec[i]) rescue pbGetTrainerConst(rec[i])))
            else
              file.write(getConstantName(mod,rec[i]))
            end
          elsif enumer.is_a?(Module)
            file.write(getConstantName(enumer,rec[i]))
          elsif enumer.is_a?(Hash)
            for key in enumer.keys
              if enumer[key]==rec[i]
                file.write(key)
                break
              end
            end
          end
        else
          file.write(rec[i].inspect)
      end
    else
      file.write(rec[i].inspect)
    end
  end
  return record
end

def pbEachCommentedLine(f)
  lineno=1
  f.each_line {|line|
     if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
       line=line[3,line.length-3]
     end
     if !line[/^\#/] && !line[/^\s*$/]
       yield line, lineno
     end
     lineno+=1
  }
end

def pbEachPreppedLine(f)
  lineno=1
  f.each_line {|line|
     if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
       line=line[3,line.length-3]
     end
     line=prepline(line)
     if !line[/^\#/] && !line[/^\s*$/]
       yield line, lineno
     end
     lineno+=1
  }
end

def pbCompilerEachCommentedLine(filename)
  File.open(filename,"rb"){|f|
     FileLineData.file=filename
     lineno=1
     f.each_line {|line|
        if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
          line=line[3,line.length-3]
        end
        if !line[/^\#/] && !line[/^\s*$/]
          FileLineData.setLine(line,lineno)
          yield line, lineno
        end
        lineno+=1
     }
  }
end

def pbCompilerEachPreppedLine(filename)
  File.open(filename,"rb"){|f|
     FileLineData.file=filename
     lineno=1
     f.each_line {|line|
        if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
          line=line[3,line.length-3]
        end
        line=prepline(line)
        if !line[/^\#/] && !line[/^\s*$/]
          FileLineData.setLine(line,lineno)
          yield line, lineno
        end
        lineno+=1
     }
  }
end

def pbCompileShadowMoves
  sections=[]
  if File.exists?("PBS/shadowmoves.txt")
    pbCompilerEachCommentedLine("PBS/shadowmoves.txt"){|line,lineno|
       if line[ /^([^=]+)=(.*)$/ ]
         key=$1
         value=$2
         value=value.split(",")
         species=parseSpecies(key)
         moves=[]
         for i in 0...[4,value.length].min
           moves.push((parseMove(value[i]) rescue nil))
         end
         moves.compact!
         sections[species]=moves if moves.length>0
       end
    }
  end
  save_data(sections,"Data/shadowmoves.dat")
end

def pbCompileBTTrainers(filename)
  sections=[]
  btTrainersRequiredTypes={
     "Type"=>[0,"e",PBTrainers],
     "Name"=>[1,"s"],
     "BeginSpeech"=>[2,"s"],
     "EndSpeechWin"=>[3,"s"],
     "EndSpeechLose"=>[4,"s"],
     "PokemonNos"=>[5,"*u"]
  }
  requiredtypes=btTrainersRequiredTypes
  trainernames=[]
  beginspeech=[]
  endspeechwin=[]
  endspeechlose=[]
  if safeExists?(filename)
    File.open(filename,"rb"){|f|
       FileLineData.file=filename
       pbEachFileSectionEx(f){|section,name|
          rsection=[]
          for key in section.keys
            FileLineData.setSection(name,key,section[key])
            schema=requiredtypes[key]
            next if !schema
            record=pbGetCsvRecord(section[key],0,schema)
            rsection[schema[0]]=record
          end
          trainernames.push(rsection[1])
          beginspeech.push(rsection[2])
          endspeechwin.push(rsection[3])
          endspeechlose.push(rsection[4])
          sections.push(rsection)
       }
    }
  end
  MessageTypes.addMessagesAsHash(MessageTypes::TrainerNames,trainernames)
  MessageTypes.addMessagesAsHash(MessageTypes::BeginSpeech,beginspeech)
  MessageTypes.addMessagesAsHash(MessageTypes::EndSpeechWin,endspeechwin)
  MessageTypes.addMessagesAsHash(MessageTypes::EndSpeechLose,endspeechlose)
  return sections
end

def pbCompileTownMap
  nonglobaltypes={
     "Name"=>[0,"s"],
     "Filename"=>[1,"s"],
     "Point"=>[2,"uussUUUU"]
  }
  currentmap=-1
  rgnnames=[]
  placenames=[]
  placedescs=[]
  sections=[]
  pbCompilerEachCommentedLine("PBS/townmap.txt"){|line,lineno|
     if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
       currentmap=$~[1].to_i
       sections[currentmap]=[]
     else
       if currentmap<0
         raise _INTL("Expected a section at the beginning of the file\n{1}",FileLineData.linereport)
       end
       if !line[/^\s*(\w+)\s*=\s*(.*)$/]
         raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\n{1}",FileLineData.linereport)
       end
       settingname=$~[1]
       schema=nonglobaltypes[settingname]
       if schema
         record=pbGetCsvRecord($~[2],lineno,schema)
         if settingname=="Name"
           rgnnames[currentmap]=record
         elsif settingname=="Point"
           placenames.push(record[2])
           placedescs.push(record[3])
           sections[currentmap][schema[0]]=[] if !sections[currentmap][schema[0]]
           sections[currentmap][schema[0]].push(record)
         else   # Filename
           sections[currentmap][schema[0]]=record
         end
       end
     end
  }
  File.open("Data/townmap.dat","wb"){|f|
     Marshal.dump(sections,f)
  }
  MessageTypes.setMessages(
     MessageTypes::RegionNames,rgnnames
  )
  MessageTypes.setMessagesAsHash(
     MessageTypes::PlaceNames,placenames
  )
  MessageTypes.setMessagesAsHash(
     MessageTypes::PlaceDescriptions,placedescs
  )
end

def pbCompileMetadata
  sections=[]
  currentmap=-1
  pbCompilerEachCommentedLine("PBS/metadata.txt") {|line,lineno|
     if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
       sectionname=$~[1]
       if currentmap==0
         if sections[currentmap][MetadataHome]==nil
           raise _INTL("The entry Home is required in metadata.txt section [{1}]",sectionname)
         end
         if sections[currentmap][MetadataPlayerA]==nil
           raise _INTL("The entry PlayerA is required in metadata.txt section [{1}]",sectionname)
         end
       end
       currentmap=sectionname.to_i
       sections[currentmap]=[]
     else
       if currentmap<0
         raise _INTL("Expected a section at the beginning of the file\n{1}",FileLineData.linereport)
       end
       if !line[/^\s*(\w+)\s*=\s*(.*)$/]
         raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\n{1}",FileLineData.linereport)
       end
       matchData=$~
       schema=nil
       FileLineData.setSection(currentmap,matchData[1],matchData[2])
       if currentmap==0
         schema=PokemonMetadata::GlobalTypes[matchData[1]]
       else
         schema=PokemonMetadata::NonGlobalTypes[matchData[1]]
       end
       if schema
         record=pbGetCsvRecord(matchData[2],lineno,schema)
         sections[currentmap][schema[0]]=record
       end
     end
  }
  File.open("Data/metadata.dat","wb"){|f|
     Marshal.dump(sections,f)
  }
end

def pbCompileItems
  records=[]
  records[0] = []
  constants=""
  itemnames=[]
  itemdescs=[]
  maxValue=0
  pbCompilerEachCommentedLine("PBS/items.txt"){|line,lineno|
     linerecord=pbGetCsvRecord(line,lineno,[0,"vnsuusuuUN"])
     record=[]
     record[ITEMID]        = linerecord[0]
     constant=linerecord[1]
     constants+="#{constant}=#{record[0]}\n"
     record[ITEMNAME]      = linerecord[2]
     itemnames[record[0]]=linerecord[2]
     record[ITEMPOCKET]    = linerecord[3]
     record[ITEMPRICE]     = linerecord[4]
     record[ITEMDESC]      = linerecord[5]
     itemdescs[record[0]]=linerecord[5]
     record[ITEMUSE]       = linerecord[6]
     record[ITEMBATTLEUSE] = linerecord[7]
     record[ITEMTYPE]      = linerecord[8]
     if linerecord[9]!="" && linerecord[9]
       record[ITEMMACHINE] = parseMove(linerecord[9])
     else
       record[ITEMMACHINE] = 0
     end
     maxValue=[maxValue,record[0]].max
     records[record[ITEMID]] = record
  }
  File.open("Data/items.dat","wb"){|file|
    Marshal.dump(records,file)
  }
  $cache.items = records
  MessageTypes.setMessages(MessageTypes::Items,itemnames)
  MessageTypes.setMessages(MessageTypes::ItemDescriptions,itemdescs)
  #writeSerialRecords("Data/items.dat",records)
  code="class PBItems\n#{constants}"
  code+="\ndef PBItems.getName(id)\nreturn pbGetMessage(MessageTypes::Items,id)\nend\n"
  code+="\ndef PBItems.getCount\nreturn #{records.length}\nend\n"
  code+="\ndef PBItems.maxValue\nreturn #{maxValue}\nend\nend"
  eval(code)
  pbAddScript(code,"PBItems")
  Graphics.update
end

def pbCompileConnections
  records=[]
  constants=""
  itemnames=[]
  pbCompilerEachPreppedLine("PBS/connections.txt"){|line,lineno|
     hashenum={
        "N"=>"N","North"=>"N",
        "E"=>"E","East"=>"E",
        "S"=>"S","South"=>"S",
        "W"=>"W","West"=>"W"
     }
     record=[]
     thisline=line.dup
     record.push(csvInt!(thisline,lineno))
     record.push(csvEnumFieldOrInt!(thisline,hashenum,"",sprintf("(line %d)",lineno)))
     record.push(csvInt!(thisline,lineno))
     record.push(csvInt!(thisline,lineno))
     record.push(csvEnumFieldOrInt!(thisline,hashenum,"",sprintf("(line %d)",lineno)))
     record.push(csvInt!(thisline,lineno))
     if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[0])) &&
        !pbRgssExists?(sprintf("Data/Map%03d.rvdata",record[0]))
       print _INTL("Warning: Map {1}, as mentioned in the map\nconnection data, was not found.\n{2}",record[0],FileLineData.linereport)
     end
     if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",record[3])) &&
        !pbRgssExists?(sprintf("Data/Map%03d.rvdata",record[3]))
       print _INTL("Warning: Map {1}, as mentioned in the map\nconnection data, was not found.\n{2}",record[3],FileLineData.linereport)
     end
     case record[1]
       when "N"
         raise _INTL("North side of first map must connect with south side of second map\n{1}",FileLineData.linereport) if record[4]!="S"
       when "S"
         raise _INTL("South side of first map must connect with north side of second map\n{1}",FileLineData.linereport) if record[4]!="N"
       when "E"
         raise _INTL("East side of first map must connect with west side of second map\n{1}",FileLineData.linereport) if record[4]!="W"
       when "W"
         raise _INTL("West side of first map must connect with east side of second map\n{1}",FileLineData.linereport) if record[4]!="E"
     end
     records.push(record)
  }
  save_data(records,"Data/connections.dat")
  Graphics.update
end

def strsplit(str,re)
  ret=[]
  tstr=str
  while re=~tstr
    ret[ret.length]=$~.pre_match
    tstr=$~.post_match
  end
  ret[ret.length]=tstr if ret.length
  return ret
end

def canonicalize(c)
  return c
end

def pbGetConst(mod,item,err)
  isdef=false
  begin
    isdef=mod.const_defined?(item.to_sym)
    rescue
    raise sprintf(err,item)
  end
  raise sprintf(err,item) if !isdef
  return mod.const_get(item.to_sym)
end

def parseItem(item)
  clonitem=item.upcase
  clonitem.sub!(/^\s*/){}
  clonitem.sub!(/\s*$/){}
  return pbGetConst(PBItems,clonitem,
     _INTL("Undefined item constant name: %s\nName must consist only of letters, numbers, and\nunderscores and can't begin with a number.\nMake sure the item is defined in\nPBS/items.txt.\n{1}",
     FileLineData.linereport))
end

def parseSpecies(item)
  clonitem=item.upcase
  clonitem.gsub!(/^[\s\n]*/){}
  clonitem.gsub!(/[\s\n]*$/){}
  clonitem="NIDORANmA" if clonitem=="NIDORANMA"
  clonitem="NIDORANfE" if clonitem=="NIDORANFE"
  return pbGetConst(PBSpecies,clonitem,_INTL("Undefined species constant name: [%s]\nName must consist only of letters, numbers, and\nunderscores and can't begin with a number.\nMake sure the name is defined in\nPBS/pokemon.txt.\n{1}",FileLineData.linereport))
end

def parseMove(item)
  clonitem=item.upcase
  clonitem.sub!(/^\s*/){}
  clonitem.sub!(/\s*$/){}
  return pbGetConst(PBMoves,clonitem,_INTL("Undefined move constant name: %s\nName must consist only of letters, numbers, and\nunderscores and can't begin with a number.\nMake sure the name is defined in\nPBS/moves.txt.\n{1}",FileLineData.linereport))
end

def parseNature(item)
  clonitem=item.upcase
  clonitem.sub!(/^\s*/){}
  clonitem.sub!(/\s*$/){}
  return pbGetConst(PBNatures,clonitem,_INTL("Undefined nature constant name: %s\nName must consist only of letters, numbers, and\nunderscores and can't begin with a number.\nMake sure the name is defined in\nthe script section PBNatures.\n{1}",FileLineData.linereport))
end

def parseTrainer(item)
  clonitem=item.clone
  clonitem.sub!(/^\s*/){}
  clonitem.sub!(/\s*$/){}
  return pbGetConst(PBTrainers,clonitem,_INTL("Undefined Trainer constant name: %s\nName must consist only of letters, numbers, and\nunderscores and can't begin with a number.\nIn addition, the name must be defined\nin trainertypes.txt.\n{1}",FileLineData.linereport))
end

def pbFindScript(a,name)
  a.each{|i|
     next if !i
     return i if i[1]==name
  }
  return nil
end

def pbAddScript(script,sectionname)
  case GAMETITLE
    when "Pokemon Reborn" then subfolder = "Reborn/"
    when "Pokemon Rejuvenation" then subfolder = "Rejuv/"
    when "Pokemon Desolation" then subfolder = "ReDeso/"
  end
  filename = "Scripts/" + subfolder + sectionname + ".rb"
  File.open(filename,"w"){|f| f.write script}
end

def pbCompileEncounters
  lines=[]
  linenos=[]
  FileLineData.file="PBS/encounters.txt"
  File.open("PBS/encounters.txt","rb"){|f|
     lineno=1
     f.each_line {|line|
        if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
          line=line[3,line.length-3]
        end
        line=prepline(line)
        if line.length!=0
          lines[lines.length]=line
          linenos[linenos.length]=lineno
        end
        lineno+=1
     }
  }
  encounters={}
  thisenc=nil
  lastenc=-1
  lastenclen=0
  needdensity=false
  lastmapid=-1
  i=0;
  while i<lines.length
    line=lines[i]
    FileLineData.setLine(line,linenos[i])
    mapid=line[/^\d+$/]
    if mapid
      lastmapid=mapid
      if thisenc && (thisenc[1][EncounterTypes::Land] ||
                     thisenc[1][EncounterTypes::LandMorning] ||
                     thisenc[1][EncounterTypes::LandDay] ||
                     thisenc[1][EncounterTypes::BugContest] ||
                     thisenc[1][EncounterTypes::LandNight]) &&
                     thisenc[1][EncounterTypes::Cave]
        raise _INTL("Can't define both Land and Cave encounters in the same area (map ID {1})",mapid)
      end
      thisenc=[EncounterTypes::EnctypeDensities.clone,[]]
      encounters[mapid.to_i]=thisenc
      needdensity=true
      i+=1
      next
    end
    enc=findIndex(EncounterTypes::Names){|val| val==line}
    if enc>=0
      needdensity=false
      enclines=EncounterTypes::EnctypeChances[enc].length
      encarray=[]
      j=i+1; k=0
      while j<lines.length && k<enclines
        line=lines[j]
        FileLineData.setLine(lines[j],linenos[j])
        splitarr=strsplit(line,/\s*,\s*/)
        if !splitarr || splitarr.length<2
          raise _INTL("In encounters.txt, expected a species entry line,\ngot \"{1}\" instead (probably too few entries in an encounter type).\nPlease check the format of the section numbered {2},\nwhich is just before this line.\n{3}",
             line,lastmapid,FileLineData.linereport)
        end
        splitarr[2]=splitarr[1] if splitarr.length==2
        splitarr[1]=splitarr[1].to_i
        splitarr[2]=splitarr[2].to_i
        maxlevel=PBExperience::MAXLEVEL
        if splitarr[1]<=0 || splitarr[1]>maxlevel
          raise _INTL("Level number is not valid: {1}\n{2}",splitarr[1],FileLineData.linereport)
        end
        if splitarr[2]<=0 || splitarr[2]>maxlevel
          raise _INTL("Level number is not valid: {1}\n{2}",splitarr[2],FileLineData.linereport)
        end
        if splitarr[1]>splitarr[2]
          raise _INTL("Minimum level is greater than maximum level: {1}\n{2}",line,FileLineData.linereport)
        end
        splitarr[0]=parseSpecies(splitarr[0])
        linearr=splitarr
        encarray.push(linearr)
        thisenc[1][enc]=encarray
        j+=1
        k+=1
      end
      if j==lines.length && k<enclines
         raise _INTL("Reached end of file unexpectedly. There were too few entries in the last section, expected {1} entries.\nPlease check the format of the section numbered {2}.\n{3}",
            enclines,lastmapid,FileLineData.linereport)
      end
      i=j
    elsif needdensity
      needdensity=false
      nums=strsplit(line,/,/)
      if nums && nums.length>=3
        for j in 0...EncounterTypes::EnctypeChances.length
          next if !EncounterTypes::EnctypeChances[j] ||
                  EncounterTypes::EnctypeChances[j].length==0
          next if EncounterTypes::EnctypeCompileDens[j]==0
          thisenc[0][j]=nums[EncounterTypes::EnctypeCompileDens[j]-1].to_i
        end
      else
        raise _INTL("Wrong syntax for densities in encounters.txt; got \"{1}\"\n{2}",line,FileLineData.linereport)
      end
      i+=1
    else
      raise _INTL("Undefined encounter type {1}, expected one of the following:\n{2}\n{3}",
         line,EncounterTypes::Names.inspect,FileLineData.linereport)
    end
  end
  save_data(encounters,"Data/encounters.dat")
end

def pbCompileMoves
  records=[]
  movenames=[]
  movedescs=[]
  movedata=[]
  movedata[0] = [0,0,0,0,0,0,0,0,0,0]
  maxValue=0
  pbCompilerEachPreppedLine("PBS/moves.txt"){|line,lineno|
      thisline=line.clone
      record=[]
      flags=0
      record=pbGetCsvRecord(line,lineno,[0,"vnsxueeuuuxiss",
        nil,nil,nil,nil,nil,PBTypes,["Physical","Special","Status"],
        nil,nil,nil,nil,nil,nil,nil])
      #pbCheckWord(record[3],_INTL("Function code"))
      flags|=1 if record[12][/a/]
      flags|=2 if record[12][/b/]
      flags|=4 if record[12][/c/]
      flags|=8 if record[12][/d/]
      flags|=16 if record[12][/e/]
      flags|=32 if record[12][/f/]
      flags|=64 if record[12][/g/]
      flags|=128 if record[12][/h/]
      flags|=256 if record[12][/i/]
      flags|=512 if record[12][/j/]
      flags|=1024 if record[12][/k/]
      flags|=2048 if record[12][/l/]
      flags|=4096 if record[12][/m/]
      flags|=8192 if record[12][/n/]
      flags|=16384 if record[12][/o/]
      flags|=32768 if record[12][/p/]
      if record[6]==2 && record[4]!=0
        raise _INTL("Status moves must have a base damage of 0, use either Physical or Special\n{1}",FileLineData.linereport)
      end
      if record[6]!=2 && record[4]==0
        print _INTL(
          "Warning: Physical and special moves can't have a base damage of 0, changing to a Status move\n{1}",FileLineData.linereport)
        record[6]=2
      end
      maxValue=[maxValue,record[0]].max
      movedata[record[0]]=[                                             #movedata[fuckinpieceofshit][3]
        record[3],  # Function code
        record[4],  # Damage
        record[5],  # Type
        record[6],  # Category
        record[7],  # Accuracy
        record[8],  # Total PP
        record[9],  # Effect chance
        record[10], # Target
        record[11], # Priority
        flags,      # Flags
      ]
      movenames[record[0]]=record[2]  # Name
      movedescs[record[0]]=record[13] # Description
      records.push(record)
  }
  File.open("Data/moves.dat","wb"){|file|
     Marshal.dump(movedata,file)
  }
  MessageTypes.setMessages(MessageTypes::Moves,movenames)
  MessageTypes.setMessages(MessageTypes::MoveDescriptions,movedescs)
  code="class PBMoves\n"
  for rec in records
    code+="#{rec[1]}=#{rec[0]}\n"
  end
  code+="\ndef self.getName(id)\nreturn pbGetMessage(MessageTypes::Moves,id) if id < 10000 \nreturn PokeBattle_ZMoves::ZMOVENAMES[id-10001]\nend"
  code+="\ndef self.getCount\nreturn #{records.length}\nend"
  code+="\ndef self.maxValue\nreturn #{maxValue}\nend\nend"
  eval(code)
  pbAddScript(code,"PBMoves")
end

def pbCompileAbilities
  records=[]
  movenames=[]
  movedescs=[]
  maxValue=0
  pbCompilerEachPreppedLine("PBS/abilities.txt"){|line,lineno|
     record=pbGetCsvRecord(line,lineno,[0,"vnss"])
     movenames[record[0]]=record[2]
     movedescs[record[0]]=record[3]
     maxValue=[maxValue,record[0]].max
     records.push(record)
  }
  MessageTypes.setMessages(MessageTypes::Abilities,movenames)
  MessageTypes.setMessages(MessageTypes::AbilityDescs,movedescs)
  code="class PBAbilities\n"
  for rec in records
    code+="#{rec[1]}=#{rec[0]}\n"
  end
  code+="\ndef self.getName(id)\nreturn pbGetMessage(MessageTypes::Abilities,id)\nend"
  code+="\ndef self.getCount\nreturn #{records.length}\nend\n"
  code+="\ndef self.maxValue\nreturn #{maxValue}\nend\nend"
  eval(code)
  pbAddScript(code,"PBAbilities")
end

def pbExtractTrainers
  trainertypes=nil
  pbRgssOpen("Data/trainertypes.dat","rb"){|f|
     trainertypes=Marshal.load(f)
  }
  return if !trainertypes
  File.open("trainertypes.txt","wb"){|f|
     for i in 0...trainertypes.length
       next if !trainertypes[i]
       record=trainertypes[i]
       begin
         cnst=getConstantName(PBTrainers,record[0])
       rescue
         next
       end
       f.write(sprintf("%d,%s,%s,%d,%s,%s,%s,%s\n",
          record[0],csvquote(cnst),csvquote(record[2]),
          record[3],csvquote(record[4]),csvquote(record[5]),csvquote(record[6]),
          record[7] ? ["Male","Female","Mixed"][record[7]] : "Mixed"
       ))
     end
  }
end

def pbCompileTrainers
  # Trainer types
  records=[]
  trainernames=[]
  count=0
  maxValue=0
  pbCompilerEachPreppedLine("PBS/trainertypes.txt"){|line,lineno|
     record=pbGetCsvRecord(line,lineno,[0,"unsUSSSeU", # ID can be 0
        nil,nil,nil,nil,nil,nil,nil,{
        ""=>2,"Male"=>0,"M"=>0,"0"=>0,"Female"=>1,"F"=>1,"1"=>1,"Mixed"=>2,"X"=>2,"2"=>2
        },nil]
     )
     if record[3] && (record[3]<0 || record[3]>255)
       raise _INTL("Bad money amount (must be from 0 through 255)\n{1}",FileLineData.linereport)
     end
     record[3]=30 if !record[3]
     if record[8] && (record[8]<0 || record[8]>255)
       raise _INTL("Bad skill value (must be from 0 through 255)\n{1}",FileLineData.linereport)
     end
     record[8]=record[3] if !record[8]
     trainernames[record[0]]=record[2]
     if records[record[0]]
       raise _INTL("Two trainer types ({1} and {2}) have the same ID ({3}), which is not allowed.\n{4}",
          records[record[0]][1],record[1],record[0],FileLineData.linereport)
     end
     records[record[0]]=record
     maxValue=[maxValue,record[0]].max
  }
  count=records.compact.length
  MessageTypes.setMessages(MessageTypes::TrainerTypes,trainernames)
  code="class PBTrainers\n"
  for rec in records
    next if !rec
    code+="#{rec[1]}=#{rec[0]}\n"
  end
  code+="\ndef self.getName(id)\nreturn pbGetMessage(MessageTypes::TrainerTypes,id)\nend"
  code+="\ndef self.getCount\nreturn #{count}\nend"
  code+="\ndef self.maxValue\nreturn #{maxValue}\nend\nend"
  eval(code)
  pbAddScript(code,"PBTrainers")
  File.open("Data/trainertypes.dat","wb"){|f|
     Marshal.dump(records,f)
  }
  # Individual trainers
  lines=[]
  linenos=[]
  lineno=1
  File.open("PBS/trainers.txt","rb"){|f|
     FileLineData.file="PBS/trainers.txt"
     f.each_line {|line|
        if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
          line=line[3,line.length-3]
        end
        line=prepline(line)
        if line!=""
          lines.push(line)
          linenos.push(lineno)
        end
        lineno+=1
     }
  }
  trainers=Array.new(maxValue)
  for i in 0..trainers.length
    trainers[i] = []
  end
  trainernames.clear
  i=0; loop do break unless i<lines.length
    FileLineData.setLine(lines[i],linenos[i])
    trainername=parseTrainer(lines[i])
    FileLineData.setLine(lines[i+1],linenos[i+1])
    nameline=strsplit(lines[i+1],/\s*,\s*/)
    name=nameline[0]
    raise _INTL("Trainer name too long\n{1}",FileLineData.linereport) if name.length>=0x10000
    trainernames.push(name)
    partyid=0
    if nameline[1] && nameline[1]!=""
      raise _INTL("Expected a number for the trainer battle ID\n{1}",FileLineData.linereport) if !nameline[1][/^\d+$/]
      partyid=nameline[1].to_i
    end
    FileLineData.setLine(lines[i+2],linenos[i+2])
    items=strsplit(lines[i+2],/\s*,\s*/)
    items[0].gsub!(/^\s+/,"")   # Number of Pokémon
    raise _INTL("Expected a number for the number of Pokémon\n{1}",FileLineData.linereport) if !items[0][/^\d+$/]
    numpoke=items[0].to_i
    realitems=[]
    for j in 1...items.length   # Items held by Trainer
      realitems.push(parseItem(items[j])) if items[j] && items[j]!=""
    end
    pkmn=[]
    for j in 0...numpoke
      FileLineData.setLine(lines[i+j+3],linenos[i+j+3])
      poke=strsplit(lines[i+j+3],/\s*,\s*/)
      begin
        # Species
        poke[TPSPECIES]=parseSpecies(poke[TPSPECIES])
      rescue
        raise _INTL("Expected a species name: {1}\n{2}",poke[0],FileLineData.linereport)
      end
      # Level
      poke[TPLEVEL]=poke[TPLEVEL].to_i
      raise _INTL("Bad level: {1} (must be from 1-{2})\n{3}",poke[TPLEVEL],
        PBExperience::MAXLEVEL,FileLineData.linereport) if poke[TPLEVEL]<=0 || poke[TPLEVEL]>PBExperience::MAXLEVEL
      # Held item
      if !poke[TPITEM] || poke[TPITEM]==""
        poke[TPITEM]=TPDEFAULTS[TPITEM]
      else
        poke[TPITEM]=parseItem(poke[TPITEM])
      end
      # Moves
      moves=[]
      for j in [TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4]
        moves.push(parseMove(poke[j])) if poke[j] && poke[j]!=""
      end
      for j in 0...4
        index=[TPMOVE1,TPMOVE2,TPMOVE3,TPMOVE4][j]
        if moves[j] && moves[j]!=0
          poke[index]=moves[j]
        else
          poke[index]=TPDEFAULTS[index]
        end
      end
      # Ability
      if !poke[TPABILITY] || poke[TPABILITY]==""
        poke[TPABILITY]=TPDEFAULTS[TPABILITY]
      else
        poke[TPABILITY]=poke[TPABILITY].to_i
        raise _INTL("Bad abilityflag: {1} (must be 0 or 1 or 2-5)\n{2}",poke[TPABILITY],FileLineData.linereport) if poke[TPABILITY]<0 || poke[TPABILITY]>5
      end
      # Gender
      if !poke[TPGENDER] || poke[TPGENDER]==""
        poke[TPGENDER]=TPDEFAULTS[TPGENDER]
      else
        if poke[TPGENDER]=="M"
          poke[TPGENDER]=0
        elsif poke[TPGENDER]=="F"
          poke[TPGENDER]=1
        elsif poke[TPGENDER]=="U"
          poke[TPGENDER]=2
        else
          poke[TPGENDER]=poke[TPGENDER].to_i
          raise _INTL("Bad genderflag: {1} (must be M or F or U, or 0 or 1 or 2)\n{2}",poke[TPGENDER],FileLineData.linereport) if poke[TPGENDER]<0 || poke[TPGENDER]>2
        end
      end
      # Form
      if !poke[TPFORM] || poke[TPFORM]==""
        poke[TPFORM]=TPDEFAULTS[TPFORM]
      else
        poke[TPFORM]=poke[TPFORM].to_i
        raise _INTL("Bad form: {1} (must be 0 or greater)\n{2}",poke[TPFORM],FileLineData.linereport) if poke[TPFORM]<0
      end
      # Shiny
      if !poke[TPSHINY] || poke[TPSHINY]==""
        poke[TPSHINY]=TPDEFAULTS[TPSHINY]
      elsif poke[TPSHINY]=="shiny"
        poke[TPSHINY]=true
      else
        poke[TPSHINY]=csvBoolean!(poke[TPSHINY].clone)
      end
      # Nature
      if !poke[TPNATURE] || poke[TPNATURE]==""
        poke[TPNATURE]=TPDEFAULTS[TPNATURE]
      else
        poke[TPNATURE]=parseNature(poke[TPNATURE])
      end
      # IVs
      if !poke[TPIV] || poke[TPIV]==""
        poke[TPIV]=TPDEFAULTS[TPIV]
      else
        poke[TPIV]=poke[TPIV].to_i
        raise _INTL("Bad IV: {1} (must be from 0-31 (32 special case))\n{2}",poke[TPIV],FileLineData.linereport) if poke[TPIV]<0 || poke[TPIV]>32
      end
      # Happiness
      if !poke[TPHAPPINESS] || poke[TPHAPPINESS]==""
        poke[TPHAPPINESS]=TPDEFAULTS[TPHAPPINESS]
      else
        poke[TPHAPPINESS]=poke[TPHAPPINESS].to_i
        raise _INTL("Bad happiness: {1} (must be from 0-255)\n{2}",poke[TPHAPPINESS],FileLineData.linereport) if poke[TPHAPPINESS]<0 || poke[TPHAPPINESS]>255
      end
      # Nickname
      if !poke[TPNAME] || poke[TPNAME]==""
        poke[TPNAME]=TPDEFAULTS[TPNAME]
      else
        poke[TPNAME]=poke[TPNAME].to_s
        raise _INTL("Bad nickname: {1} (must be 1-20 characters)\n{2}",poke[TPNAME],FileLineData.linereport) if (poke[TPNAME].to_s).length>20
      end
      # Shadow
      if !poke[TPSHADOW] || poke[TPSHADOW]==""
        poke[TPSHADOW]=TPDEFAULTS[TPSHADOW]
      else
        poke[TPSHADOW]=csvBoolean!(poke[TPSHADOW].clone)
      end
      # Ball
      if !poke[TPBALL] || poke[TPBALL]==""
        poke[TPBALL]=TPDEFAULTS[TPBALL]
      else
        poke[TPBALL]=poke[TPBALL].to_i
        raise _INTL("Bad form: {1} (must be 0 or greater)\n{2}",poke[TPBALL],FileLineData.linereport) if poke[TPBALL]<0
      end
      for value in [TPHPEV,TPATKEV,TPDEFEV,TPSPEEV,TPSPAEV,TPSPDEV]
        if !poke[value] || poke[value]==""
          poke[value]=TPDEFAULTS[value]
        else
          poke[value]=poke[value].to_i
        end
      end
      pkmn.push(poke)
    end
    i+=3+numpoke
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerNames,trainernames)
    trainers[trainername].push([name,realitems,pkmn,partyid])
  end
  fulltrainerdata = Array.new(maxValue)
  #build hashes for each trainer class
  for i in 0...trainers.length
    namearray=[]
    classhash = {}
    trainerlist = trainers[i]
    for trainer in trainerlist #make a list of the names in each class
      namearray.push(trainer[0])
    end
    namearray.uniq!
    for name in namearray
      namehash = {}
      for trainer in trainerlist
        next if trainer[0] != name
        namehash[trainer[3]] = [trainer[2],trainer[1]] #we don't want this to be an array since some IDs are >1000
      end
      classhash[name] = namehash
    end
    fulltrainerdata[i] = classhash
  end
  save_data(fulltrainerdata,"Data/trainers.dat")
  $cache.trainers = fulltrainerdata
end

def getConstantName(mod,value)
  for c in mod.constants
    return c if mod.const_get(c.to_sym)==value
  end
  raise _INTL("Value {1} not defined by a constant in {2}",value,mod.name)
end

def pbCompileMachines
  lineno=1
  havesection=false
  sectionname=nil
  sections=[]
  if safeExists?("PBS/tm.txt")
    f=File.open("PBS/tm.txt","rb")
    FileLineData.file="PBS/tm.txt"
    f.each_line {|line|
       if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
         line=line[3,line.length-3]
       end
       FileLineData.setLine(line,lineno)
       if !line[/^\#/] && !line[/^\s*$/]
         if line[/^\s*\[\s*(.*)\s*\]\s*$/]
           sectionname=parseMove($~[1])
           sections[sectionname]=[]
           havesection=true
         else
           if sectionname==nil
             raise _INTL("Expected a section at the beginning of the file.  This error may also occur if the file was not saved in UTF-8.\n{1}",FileLineData.linereport)
           end
           specieslist=line.sub(/\s+$/,"").split(",")
           for species in specieslist
             next if !species || species==""
             sec=sections[sectionname]
             sec[sec.length]=parseSpecies(species)
           end
         end
       end
       lineno+=1
       if lineno%500==0
         Graphics.update
       end
       if lineno%50==0
         pbSetWindowText(_INTL("Processing line {1}",lineno))
       end
    }
    f.close
  end
  save_data(sections,"Data/tm.dat")
end

def checkEnumField(ret,enumer)
  if enumer.is_a?(Module)
    begin
      if ret=="" || !enumer.const_defined?(ret)
        raise _INTL("Undefined value {1} in {2}\n{3}",ret,enumer.name,FileLineData.linereport)
      end
      rescue NameError
      raise _INTL("Incorrect value {1} in {2}\n{3}",ret,enumer.name,FileLineData.linereport)
    end
    return enumer.const_get(ret.to_sym)
  elsif enumer.is_a?(Symbol) || enumer.is_a?(String)
    enumer=Object.const_get(enumer.to_sym)
    begin
      if ret=="" || !enumer.const_defined?(ret)
        raise _INTL("Undefined value {1} in {2}\n{3}",ret,enumer.name,FileLineData.linereport)
      end
      rescue NameError
      raise _INTL("Incorrect value {1} in {2}\n{3}",ret,enumer.name,FileLineData.linereport)
    end
    return enumer.const_get(ret.to_sym)
  elsif enumer.is_a?(Array)
    idx=findIndex(enumer){|item| ret==item}
    if idx<0
      raise _INTL("Undefined value {1} (expected one of: {2})\n{3}",ret,enumer.inspect,FileLineData.linereport)
    end
    return idx
  elsif enumer.is_a?(Hash)
    value=enumer[ret]
    if value==nil
      raise _INTL("Undefined value {1} (expected one of: {2})\n{3}",ret,enumer.keys.inspect,FileLineData.linereport)
    end
    return value
  end
  raise _INTL("Enumeration not defined\n{1}",FileLineData.linereport)
end

def csvEnumField!(value,enumer,key,section)
  ret=csvfield!(value)
  return checkEnumField(ret,enumer)
end

def csvEnumFieldOrInt!(value,enumer,key,section)
  ret=csvfield!(value)
  if ret[/\-?\d+/]
    return ret.to_i
  end
  return checkEnumField(ret,enumer)
end

def pbEachFileSectionEx(f)
  lineno=1
  havesection=false
  sectionname=nil
  lastsection={}
  f.each_line {|line|
     if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
       line=line[3,line.length-3]
     end
     if !line[/^\#/] && !line[/^\s*$/]
       if line[/^\s*\[\s*(.*)\s*\]\s*$/]
         if havesection
           yield lastsection,sectionname
         end
         sectionname=$~[1]
         havesection=true
         lastsection={}
       else
        if sectionname==nil
          raise _INTL("Expected a section at the beginning of the file.  This error may also occur if the file was not saved in UTF-8.\n{1}",FileLineData.linereport)
        end
        if !line[/^\s*(\w+)\s*=\s*(.*)$/]
          raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\n{1}",FileLineData.linereport)
        end
        r1=$~[1]
        r2=$~[2]
        lastsection[r1]=r2.gsub(/\s+$/,"")
      end
    end
    lineno+=1
    if lineno%1000==0
      Graphics.update
    end
    if lineno%100==0
      pbSetWindowText(_INTL("Processing line {1}",lineno))
    end
  }
  if havesection
    yield lastsection,sectionname
  end
end

def pbEachFileSection(f)
  pbEachFileSectionEx(f) {|section,name|
     if block_given? && name[/^\d+$/]
       yield section,name.to_i
     end
  }
end

def pbEachSection(f)
  lineno=1
  havesection=false
  sectionname=nil
  lastsection=[]
  f.each_line {|line|
     if lineno==1 && line[0]==0xEF && line[1]==0xBB && line[2]==0xBF
       line=line[3,line.length-3]
     end
     if !line[/^\#/] && !line[/^\s*$/]
       if line[/^\s*\[\s*(.+?)\s*\]\s*$/]
         if havesection
           yield lastsection,sectionname
         end
         sectionname=$~[1]
         lastsection=[]
         havesection=true
       else
         if sectionname==nil
           raise _INTL("Expected a section at the beginning of the file (line {1}). Sections begin with '[name of section]'",lineno)
         end
         lastsection.push(line.gsub(/^\s+/,"").gsub(/\s+$/,""))
       end
     end
     lineno+=1
     if lineno%500==0
       Graphics.update
     end
  }
  if havesection
    yield lastsection,sectionname
  end
end

def pbCompileTrainerLists
  btTrainersRequiredTypes={
     "Trainers"=>[0,"s"],
     "Pokemon"=>[1,"s"],
     "Challenges"=>[2,"*s"]
  }
  if !safeExists?("PBS/trainerlists.txt")
    File.open("PBS/trainerlists.txt","wb"){|f|
       f.write("[DefaultTrainerList]\nTrainers=bttrainers.txt\nPokemon=btpokemon.txt\n")
    }
  end
  database=[]
  sections=[]
  MessageTypes.setMessagesAsHash(MessageTypes::BeginSpeech,[])
  MessageTypes.setMessagesAsHash(MessageTypes::EndSpeechWin,[])
  MessageTypes.setMessagesAsHash(MessageTypes::EndSpeechLose,[])
  File.open("PBS/trainerlists.txt","rb"){|f|
     pbEachFileSectionEx(f){|section,name|
        next if name!="DefaultTrainerList" && name!="TrainerList"
        rsection=[]
        for key in section.keys
          FileLineData.setSection(name,key,section[key])
          schema=btTrainersRequiredTypes[key]
          next if key=="Challenges" && name=="DefaultTrainerList"
          next if !schema
          record=pbGetCsvRecord(section[key],0,schema)
          rsection[schema[0]]=record
        end
        if !rsection[0]
          raise _INTL("No trainer data file given in section {1}\n{2}",name,FileLineData.linereport)
        end
        if !rsection[1]
          raise _INTL("No trainer data file given in section {1}\n{2}",name,FileLineData.linereport)
        end
        rsection[3]=rsection[0]
        rsection[4]=rsection[1]
        rsection[5]=(name=="DefaultTrainerList")
        if safeExists?("PBS/"+rsection[0])
          rsection[0]=pbCompileBTTrainers("PBS/"+rsection[0])
        else
          rsection[0]=[]
        end
        if safeExists?("PBS/"+rsection[1])
          filename="PBS/"+rsection[1]
          rsection[1]=[]
          pbCompilerEachCommentedLine(filename){|line,lineno|
             rsection[1].push(PBPokemon.fromInspected(line))
          }
        else
          rsection[1]=[]
        end
        if !rsection[2]
          rsection[2]=[]
        end
        while rsection[2].include?("")
          rsection[2].delete("")
        end
        rsection[2].compact!
        sections.push(rsection)
     }
  }
  save_data(sections,"Data/trainerlists.dat")
end

def pbCompileTypes
  sections=[]
  typechart=[]
  types=[]
  nameToType={}
  requiredtypes={
     "Name"=>[1,"s"],
     "InternalName"=>[2,"s"],
  }
  optionaltypes={
     "IsPseudoType"=>[3,"b"],
     "IsSpecialType"=>[4,"b"],
     "Weaknesses"=>[5,"*s"],
     "Resistances"=>[6,"*s"],
     "Immunities"=>[7,"*s"]
  }
  currentmap=-1
  foundtypes=[]
  pbCompilerEachCommentedLine("PBS/types.txt") {|line,lineno|
     if line[/^\s*\[\s*(\d+)\s*\]\s*$/]
       sectionname=$~[1]
       if currentmap>=0
         for reqtype in requiredtypes.keys
           if !foundtypes.include?(reqtype)
             raise _INTL("Required value '{1}' not given in section '{2}'\n{3}",reqtype,currentmap,FileLineData.linereport)
           end
         end
         foundtypes.clear
       end
       currentmap=sectionname.to_i
       types[currentmap]=[currentmap,nil,nil,false,false,[],[],[]]
     else
       if currentmap<0
         raise _INTL("Expected a section at the beginning of the file\n{1}",FileLineData.linereport)
       end
       if !line[/^\s*(\w+)\s*=\s*(.*)$/]
         raise _INTL("Bad line syntax (expected syntax like XXX=YYY)\n{1}",FileLineData.linereport)
       end
       matchData=$~
       schema=nil
       FileLineData.setSection(currentmap,matchData[1],matchData[2])
       if requiredtypes.keys.include?(matchData[1])
         schema=requiredtypes[matchData[1]]
         foundtypes.push(matchData[1])
       else
         schema=optionaltypes[matchData[1]]
       end
       if schema
         record=pbGetCsvRecord(matchData[2],lineno,schema)
         types[currentmap][schema[0]]=record
       end
     end
  }
  types.compact!
  maxValue=0
  for type in types; maxValue=[maxValue,type[0]].max; end
  pseudotypes=[]
  specialtypes=[]
  typenames=[]
  typeinames=[]
  typehash={}
  for type in types
    pseudotypes.push(type[0]) if type[3]
    typenames[type[0]]=type[1]
    typeinames[type[0]]=type[2]
    typehash[type[0]]=type
  end
  for type in types
    n=type[1]
    for w in type[5]; if !typeinames.include?(w)
      raise _INTL("'{1}' is not a defined type (PBS/types.txt, {2}, Weaknesses)",w,n)
    end; end
    for w in type[6]; if !typeinames.include?(w)
      raise _INTL("'{1}' is not a defined type (PBS/types.txt, {2}, Resistances)",w,n)
    end; end
    for w in type[7]; if !typeinames.include?(w)
      raise _INTL("'{1}' is not a defined type (PBS/types.txt, {2}, Immunities)",w,n)
    end; end
  end
  for i in 0..maxValue
    pseudotypes.push(i) if !typehash[i]
  end
  pseudotypes.sort!
  for type in types; specialtypes.push(type[0]) if type[4]; end
  specialtypes.sort!
  MessageTypes.setMessages(MessageTypes::Types,typenames)
  code="class PBTypes\n"
  for type in types
    code+="#{type[2]}=#{type[0]}\n"
  end
  code+="def PBTypes.getCount; return #{types.length}; end\n"
  code+="def PBTypes.maxValue; return #{maxValue}; end\n"
  code+="def PBTypes.getName(id)\nreturn pbGetMessage(MessageTypes::Types,id)\nend\n"
  count=maxValue+1
  for i in 0...count
    type=typehash[i]
    j=0; k=i; while j<count
      typechart[k]=2
      atype=typehash[j]
      if type && atype
        typechart[k]=4 if type[5].include?(atype[2]) # weakness
        typechart[k]=1 if type[6].include?(atype[2]) # resistance
        typechart[k]=0 if type[7].include?(atype[2]) # immune
      end
      j+=1
      k+=count
    end
  end
  code+="end\n"
  eval(code)
  save_data([pseudotypes,specialtypes,typechart],"Data/types.dat")
  pbAddScript(code,"PBTypes")
  Graphics.update
end

def pbCompilePokemonData
  sections=[]
  requiredtypes={
     "Name"=>[0,"s"],
     "Kind"=>[0,"s"],
     "InternalName"=>[0,"c"],
     "Pokedex"=>[0,"S"],
     "Moves"=>[0,"*uE",nil,PBMoves],
     "Color"=>[:Color,"e",["Red","Blue","Yellow","Green","Black","Brown","Purple","Gray","White","Pink"]],
     "Type1"=>[:Type1,"e",PBTypes],
     "BaseStats"=>[:BaseStats,"uuuuuu"],
     "Rareness"=>[:CatchRate,"u"],
     "GenderRate"=>[:GenderRatio,"e",{"AlwaysMale"=>0,"FemaleOneEighth"=>31,
        "Female25Percent"=>63,"Female50Percent"=>127,"Female75Percent"=>191,
        "FemaleSevenEighths"=>223,"AlwaysFemale"=>254,"Genderless"=>255}],
     "Happiness"=>[:Happiness,"u"],
     "GrowthRate"=>[:GrowthRate,"e",{"Medium"=>0,"MediumFast"=>0,"Erratic"=>1,
        "Fluctuating"=>2,"Parabolic"=>3,"MediumSlow"=>3,"Fast"=>4,"Slow"=>5}],
     "StepsToHatch"=>[:EggSteps,"w"],
     "EffortPoints"=>[:EVs,"uuuuuu"],
     "Compatibility"=>[:EggGroups,"eg",{"1"=>1,"Monster"=>1,"2"=>2,"Water1"=>2,"Water 1"=>2,
        "3"=>3,"Bug"=>3,"4"=>4,"Flying"=>4,"5"=>5,"Field"=>5,"Ground"=>5,"6"=>6,
        "Fairy"=>6,"7"=>7,"Grass"=>7,"Plant"=>7,"8"=>8,"Human-like"=>8,"Human-Like"=>8,
        "Humanlike"=>8,"Humanoid"=>8,"Humanshape"=>8,"Human"=>8,"9"=>9,"Water3"=>9,
        "Water 3"=>9,"10"=>10,"Mineral"=>10,"11"=>11,"Amorphous"=>11,"Indeterminate"=>11,
        "12"=>12,"Water2"=>12,"Water 2"=>12,"13"=>13,"Ditto"=>13,"14"=>14,"Dragon"=>14,
        "15"=>15,"Undiscovered"=>15,"No eggs"=>15,"NoEggs"=>15,"None"=>15,"NA"=>15},
        {"1"=>1,"Monster"=>1,"2"=>2,"Water1"=>2,"Water 1"=>2,
        "3"=>3,"Bug"=>3,"4"=>4,"Flying"=>4,"5"=>5,"Field"=>5,"Ground"=>5,"6"=>6,
        "Fairy"=>6,"7"=>7,"Grass"=>7,"Plant"=>7,"8"=>8,"Human-like"=>8,"Human-Like"=>8,
        "Humanlike"=>8,"Humanoid"=>8,"Humanshape"=>8,"Human"=>8,"9"=>9,"Water3"=>9,
        "Water 3"=>9,"10"=>10,"Mineral"=>10,"11"=>11,"Amorphous"=>11,"Indeterminate"=>11,
        "12"=>12,"Water2"=>12,"Water 2"=>12,"13"=>13,"Ditto"=>13,"14"=>14,"Dragon"=>14,
        "15"=>15,"Undiscovered"=>15,"No eggs"=>15,"NoEggs"=>15,"None"=>15,"NA"=>15}],
     "Height"=>[:Height,"f"],
     "Weight"=>[:Weight,"f"],
     "BaseEXP"=>[:BaseEXP,"w"],
  }
  optionaltypes={
     "BattlerPlayerY"=>[0,"i"],
     "BattlerEnemyY"=>[0,"i"],
     "BattlerAltitude"=>[0,"i"],
     "EggMoves"=>[0,"*E",PBMoves],
     "FormNames"=>[0,"S"],
     "RegionalNumbers"=>[0,"*w"],
     "Evolutions"=>[0,"*ses",nil,PBEvolution],
     "Habitat"=>[:Habitat,"e",["","Grassland","Forest","WatersEdge","Sea","Cave","Mountain","RoughTerrain","Urban","Rare"]],
     "Type2"=>[:Type2,"e",PBTypes],
     "Abilities"=>[:Abilities,"eg",PBAbilities,PBAbilities],
     "HiddenAbility"=>[:HiddenAbilities,"e",PBAbilities],
     "WildItemCommon"=>[:WildItemCommon,"*E",PBItems],
     "WildItemUncommon"=>[:WildItemUncommon,"*E",PBItems],
     "WildItemRare"=>[:WildItemRare,"*E",PBItems]
  }
  initdata = {}
  initdata[:ID] = 0
  initdata[:Color] = 0
  initdata[:Habitat] = 0
  initdata[:Type1] = 0
  initdata[:Type2] = 0
  initdata[:BaseStats] = []
  initdata[:CatchRate] = 0
  initdata[:GenderRatio] = 0
  initdata[:Happiness] = 0
  initdata[:GrowthRate] = 0
  initdata[:EggSteps] = 0
  initdata[:EVs] = []
  initdata[:Abilities] = []
  initdata[:EggGroups] = []
  initdata[:Height] = 0
  initdata[:Weight] = 0
  initdata[:BaseEXP] = 0
  initdata[:HiddenAbilities] = 0
  initdata[:WildItemCommon] = 0
  initdata[:WildItemUncommon] = 0
  initdata[:WildItemRare] = 0
  currentmap=-1
  dexdatas={}
  eggmoves=[]
  entries=[]
  kinds=[]
  speciesnames=[]
  moves=[]
  evolutions=[]
  regionals=[]
  formnames=[]
  metrics=[[],[],[]]
  constants=""
  maxValue=0
  File.open("PBS/pokemon.txt","rb"){|f|
    FileLineData.file="PBS/pokemon.txt"
    pbEachFileSection(f){|lastsection,currentmap|
      dexdata=initdata.clone
      dexdata[:ID]=currentmap
      abilarray = []
      evarray = []
      basestatarray = []
      egggrouparray = []
      thesemoves=[]
      theseevos=[]
      if !lastsection["Type2"] || lastsection["Type2"]==""
        if !lastsection["Type1"] || lastsection["Type1"]==""
          raise _INTL("No Pokémon type is defined in section {2} (PBS/pokemon.txt)",key,sectionDisplay) if hash==requiredtypes
          next
        end
        lastsection["Type2"]=lastsection["Type1"].clone
      end
      [requiredtypes,optionaltypes].each{|hash|
        for key in hash.keys
          FileLineData.setSection(currentmap,key,lastsection[key])
          maxValue=[maxValue,currentmap].max
          sectionDisplay=currentmap.to_s
          if currentmap==0
            raise _INTL("A Pokemon species can't be numbered 0 (PBS/pokemon.txt)")
          end
          if !lastsection[key] || lastsection[key]==""
            raise _INTL("Required entry {1} is missing or empty in section {2} (PBS/pokemon.txt)",key,sectionDisplay) if hash==requiredtypes
            next
          end
          secvalue=lastsection[key]
          rtschema=hash[key]
          schema=hash[key][1]
          valueindex=0
          loop do
            sublist=-1
            check = false
            for i in 0...schema.length
              next if schema[i,1]=="*"
              sublist+=1
              minus1=(schema[0,1]=="*") ? -1 : 0
              if schema[i,1]=="g" && secvalue==""
                if key=="Compatibility"
                  dexdata[rtschema[0]][sublist]=dexdata[rtschema[0]][sublist-1]
                end
                break
              end
              case schema[i,1]
                when "e", "g"
                  value=csvEnumField!(secvalue,rtschema[2+i+minus1],key,sectionDisplay)
                when "E"
                  value=csvEnumField!(secvalue,rtschema[2+i+minus1],key,sectionDisplay)
                when "i"
                  value=csvInt!(secvalue,key)
                when "u"
                  value=csvPosInt!(secvalue,key)
                when "w"
                  value=csvPosInt!(secvalue,key)
                when "f"
                  value=csvFloat!(secvalue,key,sectionDisplay)
                  value=(value*10).round
                  if value<=0
                    raise _INTL("Value '{1}' can't be less than or close to 0 (section {2}, PBS/pokemon.txt)",key,currentmap)
                  end
                when "c", "s"
                  value=csvfield!(secvalue)
                when "S"
                  value=secvalue
                  secvalue=""
              end
              if key=="BaseStats"
                basestatarray[sublist]=value || 0
              elsif key=="EffortPoints"
                evarray[sublist]=value || 0
              elsif key=="Abilities"
                abilarray[sublist]=value || 0
              elsif key=="Compatibility"
                egggrouparray[sublist]=value || 0
              elsif key=="EggMoves"
                eggmoves[currentmap]=[] if !eggmoves[currentmap]
                eggmoves[currentmap].push(value)
              elsif key=="Moves"
                thesemoves.push(value)
              elsif key=="RegionalNumbers"
                regionals[valueindex]=[] if !regionals[valueindex]
                regionals[valueindex][currentmap]=value
              elsif key=="Evolutions"
                theseevos.push(value)
              elsif key=="InternalName"
                raise _INTL("Invalid internal name: {1} (section {2}, PBS/pokemon.txt)",value,currentmap) if !value[/^(?![0-9])\w*$/]
                constants+="#{value}=#{currentmap}\n"
              elsif key=="Kind"
                raise _INTL("Kind {1} is greater than 20 characters long (section {2}, PBS/pokemon.txt)",value,currentmap) if value.length>20
                kinds[currentmap]=value
              elsif key=="Pokedex"
                entries[currentmap]=value
              elsif key=="BattlerPlayerY"
                #pbCheckSignedWord(value,key)
                metrics[0][currentmap]=value
              elsif key=="BattlerEnemyY"
                #pbCheckSignedWord(value,key)
                metrics[1][currentmap]=value
              elsif key=="BattlerAltitude"
                #pbCheckSignedWord(value,key)
                metrics[2][currentmap]=value
              elsif key=="Name"
                raise _INTL("Species name {1} is greater than 20 characters long (section {2}, PBS/pokemon.txt)",value,currentmap) if value.length>20
                speciesnames[currentmap]=value
              elsif key=="FormNames"
                formnames[currentmap]=value
              else
                dexdata[rtschema[0]]=value
              end
              valueindex+=1
            end
            break if secvalue==""
            break if schema[0,1]!="*"
          end
        end
      }
      movelist=[]
      evolist=[]
      for i in 0...thesemoves.length/2
        movelist.push([thesemoves[i*2],thesemoves[i*2+1],i])
      end
      movelist.sort!{|a,b| a[0]==b[0] ? a[2]<=>b[2] : a[0]<=>b[0]}
      for i in movelist; i.pop; end
      for i in 0...theseevos.length/3
        evolist.push([theseevos[i*3],theseevos[i*3+1],theseevos[i*3+2]])
      end
      moves[currentmap]=movelist
      evolutions[currentmap]=evolist
      dexdata[:BaseStats] = basestatarray
      dexdata[:EVs] = evarray
      dexdata[:Abilities] = abilarray
      dexdata[:EggGroups] = egggrouparray
      dexdatas.update(dexdata[:ID] => dexdata)
    }
  }
  if dexdatas.length==0
    raise _INTL("No Pokémon species are defined in pokemon.txt")
  end
  count=dexdatas.compact.length
  code="module PBSpecies\n#{constants}"
  for i in 0...speciesnames.length
    speciesnames[i]="????????" if !speciesnames[i]
  end
  code+="def PBSpecies.getName(id)\nreturn pbGetMessage(MessageTypes::Species,id)\nend\n"
  code+="def PBSpecies.getCount\nreturn #{count}\nend\n"
  code+="def PBSpecies.maxValue\nreturn #{maxValue}\nend\nend"
  eval(code)
  pbAddScript(code,"PBSpecies")
  for e in 0...evolutions.length
    evolist=evolutions[e]
    next if !evolist
    for i in 0...evolist.length
      FileLineData.setSection(i,"Evolutions","")
      evonib=evolist[i][1]
      evolist[i][0]=csvEnumField!(evolist[i][0],PBSpecies,"Evolutions",i)
      case PBEvolution::EVOPARAM[evonib]
        when 1
          evolist[i][2]=csvPosInt!(evolist[i][2])
        when 2
          evolist[i][2]=csvEnumField!(evolist[i][2],PBItems,"Evolutions",i)
        when 3
          evolist[i][2]=csvEnumField!(evolist[i][2],PBMoves,"Evolutions",i)
        when 4
          evolist[i][2]=csvEnumField!(evolist[i][2],PBSpecies,"Evolutions",i)
        when 5
          evolist[i][2]=csvEnumField!(evolist[i][2],PBTypes,"Evolutions",i)
        else
          evolist[i][2]=0
      end
    end
  end
  File.open("Data/evolutions.dat","wb"){|f|
    Marshal.dump(evolutions,f)
  }
  save_data(metrics,"Data/metrics.dat")
  File.open("Data/regionals.dat","wb"){|f|
    Marshal.dump(regionals,f)
  }
  $cache.pkmn_dex = dexdatas
  File.open("Data/dexdata.dat","wb"){|f|
    Marshal.dump(dexdatas,f)
  }
  File.open("Data/eggEmerald.dat","wb"){|f|
    Marshal.dump(eggmoves,f)
  }
  MessageTypes.setMessages(MessageTypes::Species,speciesnames)
  MessageTypes.setMessages(MessageTypes::Kinds,kinds)
  MessageTypes.setMessages(MessageTypes::Entries,entries)
  MessageTypes.setMessages(MessageTypes::FormNames,formnames)
  File.open("Data/attacksRS.dat","wb"){|f|
    Marshal.dump(moves,f)
  }
end

datafiles=[
   "encounters.dat",
   "trainertypes.dat",
   "connections.dat",
   "Data/items.dat",
   "metadata.dat",
   "townmap.dat",
   "trainers.dat",
   "attacksRS.dat",
   "dexdata.dat",
   "eggEmerald.dat",
   "evolutions.dat",
   "regionals.dat",
   "types.dat",
   "tm.dat",
   "phone.dat",
   "trainerlists.dat",
   "shadowmoves.dat"
]

textfiles=[
   "moves.txt",
   "abilities.txt",
   "encounters.txt",
   "trainers.txt",
   "trainertypes.txt",
   "items.txt",
   "connections.txt",
   "metadata.txt",
   "townmap.txt",
   "pokemon.txt",
   "phone.txt",
   "trainerlists.txt",
   "shadowmoves.txt",
   "tm.txt",
   "types.txt"
]

begin

class MapData
  def initialize
    @mapinfos=$cache.mapinfos
    @system=$cache.RXsystem
    @tilesets=$cache.RXtilesets
    @mapxy=[]
    @mapWidths=[]
    @mapHeights=[]
    @maps=[]
    @registeredSwitches={}
  end

  def registerSwitch(switch)
    if @registeredSwitches[switch]
      return @registeredSwitches[switch]
    end
    for id in 1..5000
      name=@system.switches[id]
      if !name || name=="" || name==switch
        @system.switches[id]=switch
        @registeredSwitches[switch]=id
        return id
      end
    end
    return 1
  end

  def saveTilesets
    filename="Data/tilesets"
    filename+=".rxdata"
    save_data(@tilesets,filename)
    filename="Data/System"
    filename+=".rxdata"
    save_data(@system,filename)
  end

  def switchName(id)
    return @system.switches[id] || ""
  end

  def mapFilename(mapID)
    filename=sprintf("Data/map%03d",mapID)
    filename+=".rxdata"
    return filename
  end

  def getMap(mapID)
    if @maps[mapID]
      return @maps[mapID]
    else
      begin
        @maps[mapID]=load_data(mapFilename(mapID))
        return @maps[mapID]
        rescue
        return nil
      end
    end
  end

  def isPassable?(mapID,x,y)
    map=getMap(mapID)
    return false if !map
    return false if x<0 || x>=map.width || y<0 || y>=map.height
    passages=@tilesets[map.tileset_id].passages
    priorities=@tilesets[map.tileset_id].priorities
    for i in [2, 1, 0]
      tile_id = map.data[x, y, i]
      return false if tile_id == nil
      return false if passages[tile_id] & 0x0f == 0x0f
      return true if priorities[tile_id] == 0
    end
    return true
  end

  def setCounterTile(mapID,x,y)
    map=getMap(mapID)
    return if !map
    passages=@tilesets[map.tileset_id].passages
    for i in [2, 1, 0]
      tile_id = map.data[x, y, i]
      next if tile_id == 0 || tile_id==nil || !passages[tile_id]
      passages[tile_id]|=0x80
      break
    end
  end

  def isCounterTile?(mapID,x,y)
    map=getMap(mapID)
    return false if !map
    passages=@tilesets[map.tileset_id].passages
    for i in [2, 1, 0]
      tile_id = map.data[x, y, i]
      return false if tile_id == nil
      return true if passages[tile_id] && passages[tile_id] & 0x80 == 0x80
    end
    return false
  end

  def saveMap(mapID)
    save_data(getMap(mapID),mapFilename(mapID)) rescue nil
  end

  def getEventFromXY(mapID,x,y)
    return nil if x<0 || y<0
    mapPositions=@mapxy[mapID]
    if mapPositions
      return mapPositions[y*@mapWidths[mapID]+x]
    else
      map=getMap(mapID)
      return nil if !map
      @mapWidths[mapID]=map.width
      @mapHeights[mapID]=map.height
      mapPositions=[]
      width=map.width
      for e in map.events.values
        mapPositions[e.y*width+e.x]=e if e
      end
      @mapxy[mapID]=mapPositions
      return mapPositions[y*width+x]
    end
  end

  def getEventFromID(mapID,id)
    map=getMap(mapID)
    return nil if !map
    return map.events[id]
  end

  def mapinfos
    return @mapinfos
  end
end

def pbCompileAnimations
  begin
    pbanims=load_data("Data/PkmnAnimations.rxdata")
  rescue
    pbanims=PBAnimations.new
  end
  move2anim=[[],[]]
  for i in 0...pbanims.length
    next if !pbanims[i]
    if pbanims[i].name[/^OppMove\:\s*(.*)$/]
      if Kernel.hasConst?(PBMoves,$~[1])
        moveid=PBMoves.const_get($~[1])
        move2anim[1][moveid]=i
      end
    elsif pbanims[i].name[/^Move\:\s*(.*)$/]
      if Kernel.hasConst?(PBMoves,$~[1])
        moveid=PBMoves.const_get($~[1])
        move2anim[0][moveid]=i
      end
    end
  end
  save_data(move2anim,"Data/move2anim.dat")
  save_data(pbanims,"Data/PkmnAnimations.rxdata")
  $cache.animations = pbanims
  animExpander
end

def pbCompileAllData(mustcompile)
  compilerruntime = Time.now
  #CP_Profiler.begin
  FileLineData.clear
  if mustcompile
    if (!$INEDITOR || LANGUAGES.length<2) && pbRgssExists?("Data/messages.dat")
      MessageTypes.loadMessageFile("Data/messages.dat")
    end
    # No dependencies
    yield(_INTL("Compiling type data"))
    #pbCompileTypes
    # No dependencies
    yield(_INTL("Compiling town map data"))
    pbCompileTownMap
    # No dependencies
    yield(_INTL("Compiling map connection data"))
    pbCompileConnections
    # No dependencies
    yield(_INTL("Compiling ability data"))
    pbCompileAbilities
    # Depends on PBTypes
    yield(_INTL("Compiling move data"))
    pbCompileMoves
    # Depends on PBMoves
    yield(_INTL("Compiling item data"))
    pbCompileItems
    # Depends on PBMoves, PBItems, PBTypes, PBAbilities
    yield(_INTL("Compiling Pokemon data"))
    pbCompilePokemonData
    # Depends on PBSpecies, PBMoves
    yield(_INTL("Compiling machine data"))
    pbCompileMachines
    # Depends on PBSpecies, PBItems, PBMoves
    yield(_INTL("Compiling Trainer data"))
    pbCompileTrainers
    # Depends on PBTrainers
    yield(_INTL("Compiling phone data"))
    #pbCompilePhoneData
    # Depends on PBTrainers
    yield(_INTL("Compiling metadata"))
    pbCompileMetadata
    # Depends on PBTrainers
    yield(_INTL("Compiling battle Trainer data"))
    pbCompileTrainerLists
    # Depends on PBSpecies
    yield(_INTL("Compiling encounter data"))
    pbCompileEncounters
    # Depends on PBSpecies, PBMoves
    yield(_INTL("Compiling shadow move data"))
    pbCompileShadowMoves
    yield(_INTL("Compiling messages"))
    # Depends on PBMoves, PBFieldEffects
    yield(_INTL("Compiling field data"))
    pbCompileFields
    yield(_INTL("Compiling field notes"))
    pbCompileFieldNotes if GAMETITLE == "Pokemon Reborn"
  else
    if (!$INEDITOR || LANGUAGES.length<2) && safeExists?("Data/messages.dat")
      MessageTypes.loadMessageFile("Data/messages.dat")
    end
  end
  pbCompileAnimations
  #pbCompileTrainerEvents(mustcompile)
  #CP_Profiler.print
  pbSetTextMessages
  #pbCombineScripts
  MessageTypes.saveMessages
  if !$INEDITOR && LANGUAGES.length>=2
    pbLoadMessages("Data/"+LANGUAGES[$idk[:settings].language][1])
  end
  totalcompilertime = Time.now - compilerruntime
  #print totalcompilertime
end

rescue Exception
e=$!
if "#{e.class}"=="Reset" || e.is_a?(Reset) || e.is_a?(SystemExit)
  raise e
end
pbPrintException(e)
if e.is_a?(Hangup)
  raise Reset.new
end
loop do
  Graphics.update
end
end

def quickCompile
  msgwindow=Kernel.pbCreateMessageWindow;pbCompileAllData(true) {|msg| Kernel.pbMessageDisplay(msgwindow,msg,false) }
end

def pbCompileFields
	fields = []
	for i in 0...43
		rawfield = FIELDEFFECTS[i]
		next if !rawfield
		currentfield = FEData.new
		#Basic data copying
		currentfield.fieldname 			= rawfield[:FIELDNAME] 		  if rawfield[:FIELDNAME]
		currentfield.intromessage 		= rawfield[:INTROMESSAGE] 	  if rawfield[:INTROMESSAGE] 
		currentfield.fieldgraphics 		= rawfield[:FIELDGRAPHICS] 	  if rawfield[:FIELDGRAPHICS] 
		currentfield.secretpoweranim 	= rawfield[:SECRETPOWERANIM]  if rawfield[:SECRETPOWERANIM] 
		currentfield.naturemoves 		= rawfield[:NATUREMOVES] 	  if rawfield[:NATUREMOVES] 
		currentfield.mimicry 			= rawfield[:MIMICRY] 		  if rawfield[:MIMICRY]
		currentfield.statusmoveboost 	= rawfield[:STATUSMOVEBOOST]  if rawfield[:STATUSMOVEBOOST]
		#now for worse shit
		#invert hashes such that move => mod
		movedamageboost 	= pbHashForwardizer(rawfield[:MOVEDAMAGEBOOST]) 	|| {}
		movetypemod 		= pbHashForwardizer(rawfield[:MOVETYPEMOD])  		|| {}
		movetypechange 		= pbHashForwardizer(rawfield[:MOVETYPECHANGE])  	|| {}
		moveaccuracyboost 	= pbHashForwardizer(rawfield[:MOVEACCURACYBOOST]) 	|| {}
		typedamageboost 	= pbHashForwardizer(rawfield[:TYPEDAMAGEBOOST]) 	|| {}
		typetypemod 		= pbHashForwardizer(rawfield[:TYPETYPEMOD])  		|| {}
		typetypechange 		= pbHashForwardizer(rawfield[:TYPETYPECHANGE])  	|| {}
		fieldchange 		= pbHashForwardizer(rawfield[:FIELDCHANGE]) 		|| {}
		typecondition 		= rawfield[:TYPECONDITION] 	 ? rawfield[:TYPECONDITION]   : {}
		changecondition 	= rawfield[:CHANGECONDITION] ? rawfield[:CHANGECONDITION] : {}
    dontchangebackup  = rawfield[:DONTCHANGEBACKUP] ? rawfield[:DONTCHANGEBACKUP] : {}
		changeeffects 		= rawfield[:CHANGEEFFECTS] 	 ? rawfield[:CHANGEEFFECTS]   : {}

		#messages get stored separately and are replaced by an index
		movemessages  = rawfield[:MOVEMESSAGES]  || {}
		typemessages  = rawfield[:TYPEMESSAGES]  || {} 
		changemessage = rawfield[:CHANGEMESSAGE] || {}
		movemessagelist = []
		typemessagelist = []
		changemessagelist = []
		[movemessages,typemessages,changemessage].each_with_index{|hashdata, index|
			messagelist = hashdata.keys
			newhashdata = {}
			hashdata.each {|key, value|
				newhashdata[messagelist.index(key)+1] = value
			}
			invhash = pbHashForwardizer(newhashdata)
			case index
			when 0
				movemessagelist = messagelist
				movemessages = invhash
			when 1
				typemessagelist = messagelist
				typemessages = invhash
			when 2
				changemessagelist = messagelist
				changemessage = invhash
			end
		}

		#now we have all our hashes de-backwarded, and can fuse them all together.
		#first, moves:
		#get all the keys in one place
		keys = (movedamageboost.keys << movetypemod.keys << movetypechange.keys << moveaccuracyboost.keys << fieldchange.keys).flatten 
		#now we take all the old hashes and squish them into one:
		fieldmovedata = {}
		for move in keys
			movedata = {}
			movedata[:mult] = movedamageboost[move] if movedamageboost[move]
			movedata[:typemod] = movetypemod[move] if movetypemod[move]
			movedata[:typechange] = movetypechange[move] if movetypechange[move]
			movedata[:accmod] = moveaccuracyboost[move] if moveaccuracyboost[move]
			movedata[:multtext] = movemessages[move] if movemessages[move]
			movedata[:fieldchange] = fieldchange[move] if fieldchange[move]
			movedata[:changetext] = changemessage[move] if changemessage[move]
			movedata[:changeeffect] = changeeffects[move] if changeeffects[move]
      movedata[:dontchangebackup] = dontchangebackup.include?(move) ? true : false
			fieldmovedata[move] = movedata
		end
		#now, types!
		fieldtypedata = {}
		keys = (typedamageboost.keys << typetypemod.keys << typetypechange.keys).flatten
		for type in keys
			typedata = {}
			typedata[:mult] = typedamageboost[type] if typedamageboost[type]
			typedata[:typemod] = typetypemod[type] if typetypemod[type]
			typedata[:typechange] = typetypechange[type] if typetypechange[type]
			typedata[:multtext] = typemessages[type] if typemessages[type]
			typedata[:condition] = typecondition[type] if typecondition[type]
			fieldtypedata[type] = typedata
		end
		#seeds for good measure.
		seeddata = {}
		seeddata = {
			:seedtype => rawfield[:SEED],
			:effect => rawfield[:SEEDEFFECT],
			:duration => rawfield[:SEEDEFFECTVAL],
			:message => rawfield[:SEEDEFFECTSTR],
			:animation => rawfield[:SEEDANIM],
			:stats => rawfield[:SEEDSTATS]
		}
		currentfield.fieldtypedata = fieldtypedata
		currentfield.fieldmovedata = fieldmovedata
		currentfield.seeddata = seeddata
		currentfield.movemessagelist = movemessagelist
		currentfield.typemessagelist = typemessagelist
		currentfield.changemessagelist = changemessagelist
    currentfield.fieldchangeconditions = changecondition
		#all done!
		fields.push(currentfield)
	end
	save_data(fields,"Data/fields.dat")
	$cache.FEData = fields
end