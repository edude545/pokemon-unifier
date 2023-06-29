#CONSTANT

GVAR = 163

PLAYEDGAME = 0

GYM1WIN = 1
GYM1ATTEMPT = 2
GYM1PREVIOUS = 3

GYM2WIN = 4
GYM2ATTEMPT = 5
GYM2PREVIOUS = 6

GYM3WIN = 7
GYM3ATTEMPT = 8
GYM3PREVIOUS = 9

GYM4WIN = 10
GYM4ATTEMPT = 11
GYM4PREVIOUS = 12

GYM5WIN = 13
GYM5ATTEMPT = 14
GYM5PREVIOUS = 15

GYM6WIN = 16
GYM6ATTEMPT = 17
GYM6PREVIOUS = 18

GYM7WIN = 19
GYM7ATTEMPT = 20

GYM8WIN = 21
GYM8ATTEMPT = 22

E4WIN = 23
E4ATTEMPT = 24

TIMELESSWIN = 25

E4REMATCHWIN = 26
E4REMATCHATTEMPT = 27

HOLONWIN = 28

ARCEUSWIN = 29

UFFIFOUND = 30
MISSINGNOFOUND = 31
DEXCOMPLETE = 32

class MetricHandler

  #  constnat
=begin
  def self.StoreOne(key)
    if $game_variables[GVAR]==0
      $game_variables[GVAR]=[]
    end
    
  end
  
  def self.PushData
    if $game_variables[GVAR]!=0
      for var in $game_variables[GVAR]
      
      
      end
    
      
    $game_variables[GVAR]=0
  end
=end
  def self.AddOne(key)
    return
    begin
      $network = DeukNetwork.new(1)
      $network.open
      $network.send("<METADD\tkey=#{key}>")
      $network.send("<DSC>")
    rescue
    end
  end
  def self.GetMetric(key)
    $startmetricget = true
    begin
      $network = DeukNetwork.new(1)
      $network.open
      $network.send("<METGET\tkey=#{key}>")
      time1 = Time.now
      loop do
        message = $network.listen
        if message != nil && message != ""
          case message
          when /<METGET val=(.*)>/
            $network.send("<DSC>")
            # raise ($1.to_i + 3).to_s
            if $1.to_i == 0
              return $1.to_i + 1 #+ 3
            else
              return $1.to_i
            end
          end
        end
        if (Time.now - time1).to_i > 2
          break
        end
      end

      $network.send("<DSC>")
      return -1
    rescue
    end
    $startmetricget = nil
  end
  def self.DisplayMetric(key)
    i = GetMetric(key)
    if (i != nil && i != 0)
      Kernel.pbMessage(i.to_s)
    end
  end
end