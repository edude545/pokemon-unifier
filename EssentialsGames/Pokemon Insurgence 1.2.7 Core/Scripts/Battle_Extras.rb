################################################################################
#-------------------------------------------------------------------------------
#Author: Alexandre
#Adds some extra functions to battle logic.
#-------------------------------------------------------------------------------
################################################################################
class PokeBattle_OnlineBattle
################################################################################
#-------------------------------------------------------------------------------
#Waits to receive a change in battler after fainting.
#-------------------------------------------------------------------------------
################################################################################
  def waitnewenemy
    loop do
      pbDisplay("Waiting...")
      @scene.pbGraphicsUpdate
      @scene.pbInputUpdate
      message = $network.listen
    #  Kernel.pbMessage(message.to_s)
      case message
        when /<BAT new=(.*)>/
          return $1.to_i
          break
        end
    end
  end
  
  
################################################################################
#-------------------------------------------------------------------------------
#Waits for the server to send a new seed.
#-------------------------------------------------------------------------------
################################################################################      
  
  def receive_seed
    $network.send("<BAT\tseed\tturn=#{@turncount}>")
    loop do
      @scene.pbGraphicsUpdate
      @scene.pbInputUpdate
      message = $network.listen
      case message
        when /<BAT seed=(.*)>/
          seed = $1
          srand($1.to_i)
          break
        end
      end
  end
  
end