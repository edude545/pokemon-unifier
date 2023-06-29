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
  def open #181.15.244.75
 #     @socket=TCPSocket.new('108.59.8.131',50000) real one. Currently active one is for testing.
     temphost='5.135.154.100'
     temphost=$game_variables[139] if $game_variables[139]!=0
    tempport=6421
    temppport=$game_variables[140] if $game_variables[140]!=0
     @socket=TCPSocket.new(temphost,tempport)

     end

################################################################################
#-------------------------------------------------------------------------------
#Sends a disconnect confirm to the server and closes the socket.
#-------------------------------------------------------------------------------
################################################################################   
  def close
    @loggedin=false
    @socket.send("<DSC>") if @socket != nil
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
    return "" if !@socket.ready?
    raise("aggg")
    buffer = @socket.recv(0xFFFF)
    buffer = buffer.split("\n", -1)
    if @previous_chunk != nil
      buffer[0] = @previous_chunk + buffer[0]
      @previous_chunk = nil
    end
    last_chunk = buffer.pop
    @previous_chunk = last_chunk if last_chunk != ''
        Kernel.pbMessage("aggg2")

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
  #  if message = "<DSC>"
  #      $network=nil
  #  end
    
    @socket.send(message + "\n")
  end

end
