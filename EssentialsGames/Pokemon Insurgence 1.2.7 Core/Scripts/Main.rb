def pbCallTitle #:nodoc:
#  Kernel.pbMessage("2")
  if $DEBUG
 #   if File::exists?("Game.rgssad") && !File::exists?("Data/
 #   else
      
 #   end
  #  if File::exists?("Data/Scripts.rxdata")
  #    $game_variables[43121][321312] = true
  #    end
    
 
    return Scene_DebugIntro.new
  else
    # First parameter is an array of images in the Titles
    # directory without a file extension, to show before the
    # actual title screen.  Second parameter is the actual
    # title screen filename, also in Titles with no extension.
    return Scene_Intro.new(['intro0','intro1'], 'splash') 
  end
end
def pbCallTitleForest #:nodoc:
    # First parameter is an array of images in the Titles
    # directory without a file extension, to show before the
    # actual title screen.  Second parameter is the actual
    # title screen filename, also in Titles with no extension.
    return Scene_Intro.new(['intro1'], 'splash_forest') 
end
def mainFunction #:nodoc:
  if $DEBUG
    pbCriticalCode { mainFunctionDebug }
  else
    mainFunctionDebug
  end
  return 1
end

def mainFunctionDebug #:nodoc:
  begin
    getCurrentProcess=Win32API.new("kernel32.dll","GetCurrentProcess","","l")
    setPriorityClass=Win32API.new("kernel32.dll","SetPriorityClass",%w(l i),"")
    setPriorityClass.call(getCurrentProcess.call(),32768) # "Above normal" priority class
    $data_animations    = pbLoadRxData("Data/Animations")
    $data_tilesets      = pbLoadRxData("Data/Tilesets")
    $data_common_events = pbLoadRxData("Data/CommonEvents")
    $data_system        = pbLoadRxData("Data/System")
    $game_system        = Game_System.new
    setScreenBorderName("border") # Sets image file for the border
    Graphics.update
    Graphics.freeze
    $scene = pbCallTitle
    while $scene != nil
      $scene.main
    end
    Graphics.transition(20)
    rescue Hangup
    pbEmergencySave
    raise
  end
end

loop do
  retval=mainFunction
  if retval==0 # failed
    loop do
      Graphics.update
    end
  elsif retval==1 # ended successfully
    break
  end
end