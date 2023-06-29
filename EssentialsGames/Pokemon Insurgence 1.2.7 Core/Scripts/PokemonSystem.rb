# Loads data from a file "safely", similar to load_data. If an encrypted archive
# exists, the real file is deleted to ensure that the file is loaded from the
# encrypted archive.
def pbSafeLoad(file)
  if (safeExists?("./Game.rgssad") || safeExists?("./Game.rgss2a")) && safeExists?(file)
    File.delete(file) rescue nil
  end
  return load_data(file)
end

def pbLoadRxData(file) # :nodoc:
  if $RPGVX
    return load_data(file+".rvdata")
  else
    return load_data(file+".rxdata") 
  end
end

def pbChooseLanguage
  commands=[]
  for lang in LANGUAGES
    commands.push(lang[0])
  end
  return Kernel.pbShowCommands(nil,commands)
end

if !Kernel.respond_to?("pbSetResizeFactor")
  def pbSetResizeFactor(dummy); end
  def setScreenBorderName(border); end

  $ResizeFactor=1.0
  $ResizeFactorMul=100
  $ResizeOffsetX=0
  $ResizeOffsetY=0
  $ResizeFactorSet=false

  module Graphics
    def self.snap_to_bitmap; return nil; end
  end
end


#############
#############


def pbSetUpSystem(savefile=0,isisswitch=false)
  begin
    trainer=nil
    framecount=0
    havedata=false
    game_system=nil
    pokemonSystem=nil
    
    trainer0=nil
    framecount0=0
    havedata0=false
    game_system0=nil
    pokemonSystem0=nil  
    
    trainer1=nil
    framecount1=0
    havedata1=false
    game_system1=nil
    pokemonSystem1=nil

    trainer2=nil
    framecount2=0
    havedata2=false
    game_system2=nil
    pokemonSystem2=nil
    pokemonSystem0=PokemonSystem.new(savefile)

    File.open(RTP.getSaveFileName("Game.rxdata")){|f|
       trainer0=Marshal.load(f)
       framecount0=Marshal.load(f)
       game_system0=Marshal.load(f)
       pokemonSystem0=Marshal.load(f)
    } 
    File.open(RTP.getSaveFileName("Game_1.rxdata")){|f|
       trainer1=Marshal.load(f)
       framecount1=Marshal.load(f)
       game_system1=Marshal.load(f)
       pokemonSystem1=Marshal.load(f)
    } 
    File.open(RTP.getSaveFileName("Game_2.rxdata")){|f|
       trainer2=Marshal.load(f)
       framecount2=Marshal.load(f)
       game_system2=Marshal.load(f)
       pokemonSystem2=Marshal.load(f)
    } 
    $arrayOfSaves=Array.new
    $arrayOfSaves[0]=[trainer0,framecount0,game_system0,pokemonSystem0]
    $arrayOfSaves[1]=[trainer1,framecount1,game_system1,pokemonSystem1]
    $arrayOfSaves[2]=[trainer2,framecount2,game_system2,pokemonSystem2]
    
    trainer=$arrayOfSaves[savefile][0]
    framecount=$arrayOfSaves[savefile][1]
    game_system=$arrayOfSaves[savefile][2]
    pokemonSystem=$arrayOfSaves[savefile][3]
  return if isisswitch
    raise "Corrupted file" if !trainer.is_a?(PokeBattle_Trainer)
    raise "Corrupted file" if !framecount.is_a?(Numeric)
    raise "Corrupted file" if !game_system.is_a?(Game_System)
    raise "Corrupted file" if !pokemonSystem.is_a?(PokemonSystem)
    havedata=true
    rescue
    pokemonSystem=PokemonSystem.new(savefile)
    game_system=Game_System.new
  end
  if !$INEDITOR
    $PokemonSystem=pokemonSystem
    $game_system=Game_System
    
    $ResizeOffsetX=[0,0,0,0][pokemonSystem0.screensize]
    $ResizeOffsetY=[0,0,0,0][pokemonSystem0.screensize]
    resizefactor=[0.5,1.0,1.5,2.0][pokemonSystem0.screensize]
    pbSetResizeFactor(resizefactor)
  else
    pbSetResizeFactor(1.0)
  end
  # Load constants
  begin
    consts=pbSafeLoad("Data/Constants.rxdata")
    consts=[] if !consts
    rescue
    consts=[]
  end
  for script in consts
    next if !script
    eval(Zlib::Inflate.inflate(script[2]),nil,script[1])
  end
#  if LANGUAGES.length>=2
#    if !havedata
#      pokemonSystem.language=pbChooseLanguage
#    end
#    pbLoadMessages("Data/"+LANGUAGES[pokemonSystem.language][1])
#  end
end

def pbScreenCapture
  capturefile=nil
  5000.times {|i|
     filename=RTP.getSaveFileName(sprintf("capture%03d.bmp",i))
     if !safeExists?(filename)
       capturefile=filename
       break
     end
     i+=1
  }
  if capturefile && safeExists?("rubyscreen.dll")
    takescreen=Win32API.new("rubyscreen.dll","TakeScreenshot","%w(p)","i")
    takescreen.call(capturefile)
    if safeExists?(capturefile)
      pbSEPlay("expfull") if FileTest.audio_exist?("Audio/SE/expfull")
    end
  end
end



module Input
  unless defined?(update_KGC_ScreenCapture)
    class << Input
      alias update_KGC_ScreenCapture update
    end
  end

  def self.update
#          Kernel.registerMobile("-IMSystem1-")

    update_KGC_ScreenCapture
 #         Kernel.registerMobile("-IMSystem2-")
    if trigger?(Input::F8)
      pbScreenCapture
    end
    if press?(Input::I) && (!$game_switches || (!$game_switches[393] && !$game_switches[697]))
      if !$PokemonSystem.turbopressed
        if !$PokemonSystem.turbospeed
          $PokemonSystem.turbospeed=0
        end
        $PokemonSystem.turbospeed+=1
        $PokemonSystem.turbospeed=0 if $PokemonSystem.turbospeed>3
        
        if $PokemonSystem.turbospeed!=0
          imgname="turbo_1" if $PokemonSystem.turbospeed==1
          imgname="turbo_2" if $PokemonSystem.turbospeed==2
          imgname="turbo_3" if $PokemonSystem.turbospeed==3
          
          $game_screen.pictures[21].show(imgname, 0,
           15, 15, 100, 100, 255, 0) if $game_screen && $game_screen.pictures
          #          Graphics.frame_rate=100
          #if !$PokemonSystem.turbospeed
          #  $PokemonSystem.turbospeed=0
          #end
          
          if $PokemonSystem.turbospeed==1
              Graphics.frame_rate=100
          elsif $PokemonSystem.turbospeed==2
              Graphics.frame_rate=160
          elsif $PokemonSystem.turbospeed==3
              Graphics.frame_rate=220
          end
        else
          $game_screen.pictures[21].erase if $game_screen && $game_screen.pictures && $game_screen.pictures[20]
          Graphics.frame_rate=40
        end
        $PokemonSystem.turbopressed=true
      end
    else
      $game_screen.pictures[21].erase if $game_screen && $game_screen.pictures && $game_screen.pictures[20]
      $PokemonSystem.turbopressed=false
      if $PokemonSystem.turbospeed!=0
        #imgname="turbo_1" if $PokemonSystem.turbospeed==1
        #imgname="turbo_2" if $PokemonSystem.turbospeed==2
        #imgname="turbo_3" if $PokemonSystem.turbospeed==3
        
        #$game_screen.pictures[21].show(imgname, 0,
        # 15, 15, 100, 100, 255, 0) if $game_screen && $game_screen.pictures
  #          Graphics.frame_rate=100
        #if !$PokemonSystem.turbospeed
        #  $PokemonSystem.turbospeed=0
        #end
        
        if $PokemonSystem.turbospeed==1
            Graphics.frame_rate=100
        elsif $PokemonSystem.turbospeed==2
            Graphics.frame_rate=160
        elsif $PokemonSystem.turbospeed==3
            Graphics.frame_rate=220
        end
      else
        #$game_screen.pictures[21].erase if $game_screen && $game_screen.pictures && $game_screen.pictures[20]
        Graphics.frame_rate=40
      end
    end
    if trigger?(Input::F7)
    end

  end
end

def pbTurbo()
  if Graphics.frame_rate==40
    Graphics.frame_rate=100
  else
    Graphics.frame_rate=40
  end
end


def pbDebugF7
  if $DEBUG
    Console::setup_console
    begin
      debugBitmaps
      rescue
    end
    pbSEPlay("expfull") if FileTest.audio_exist?("Audio/SE/expfull")
  end
end

pbSetUpSystem()