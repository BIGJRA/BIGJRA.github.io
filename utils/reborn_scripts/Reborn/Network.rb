unless System.platform == "Android"
  require 'socket'
end
################################################################################
#-------------------------------------------------------------------------------
#Author: Alexandre
#Main Network procedures
#-------------------------------------------------------------------------------
################################################################################
class Network
  attr_accessor :loggedin
  attr_accessor :socket
  attr_accessor :username
  
################################################################################
#-------------------------------------------------------------------------------
#Let's start the scene and initialise the socket variable.
#-------------------------------------------------------------------------------
################################################################################ 
  def initialize
    @loggedin=false
    @socket = nil
    @username = ""
  end

################################################################################
#-------------------------------------------------------------------------------
#Open's a connection to the server.
#-------------------------------------------------------------------------------
################################################################################  
  def open 
    temphost='45.55.245.165' #'localhost'
  
    tempport=1337 #2000

    @socket=TCPSocket.new(temphost,tempport)
  end

################################################################################
#-------------------------------------------------------------------------------
#Sends a disconnect confirm to the server and closes the socket.
#-------------------------------------------------------------------------------
################################################################################   
  def close
    @loggedin=false
    @socket.send("<DSC>",0) if @socket != nil
    @socket.close if @socket != nil
  end

################################################################################
#-------------------------------------------------------------------------------
#Listen's for any incoming messages from the server.
#-------------------------------------------------------------------------------
################################################################################   
=begin
def listen
  updatelistenarray
  if $listenarray[0] != nil
    ret = $listenarray[0]
    $listenarray.delete_at(0)
    return ret
  end
end


def updatelistenarray
  message=listenserver
  $listenarray=Array.new if $listenarray==nil || !$listenarray.is_a?(Array)
  $listenarray.push(message) if message != ""
  
end
=end

  def listen
    return "" if IO.select([@socket], nil, nil, 0.01) == nil 
    buffer = @socket.recv(0xFFFF)
    buffer = buffer.split("\n", -1)
    if @previous_chunk != nil
      buffer[0] = @previous_chunk + buffer[0]
      @previous_chunk = nil
    end
    last_chunk = buffer.pop
    @previous_chunk = last_chunk if last_chunk != ''
    buffer.each {|message|
    case message
      when /<PNG>/ then next
      else
      return message
    end
    }
  end
################################################################################
#-------------------------------------------------------------------------------
#Sends a message with a newline character.
#-------------------------------------------------------------------------------
################################################################################  
  def send(message)
    @socket.send(message + "\n",0)
  end

end