class Window_PokemonOption < Window_DrawableCommand
  attr_reader :mustUpdateOptions

  def initialize(options,x,y,width,height)
    @options=options
    @nameBaseColor=Color.new(24*8,15*8,0)
    @nameShadowColor=Color.new(31*8,22*8,10*8)
    @selBaseColor=Color.new(31*8,6*8,3*8)
    @selShadowColor=Color.new(31*8,17*8,16*8)
    @optvalues=[]
    @mustUpdateOptions=false
    for i in 0...@options.length
      @optvalues[i]=0
    end
    super(x,y,width,height)
  end

  def [](i)
    return @optvalues[i]
  end

  def []=(i,value)
    @optvalues[i]=value
    refresh
  end

  def itemCount
    return @options.length+1
  end

  def drawItem(index,count,rect)
    rect=drawCursor(index,rect)
    optionname=(index==@options.length) ? _INTL("Cancel") : @options[index].name
    optionwidth=(rect.width*9/20)
    pbDrawShadowText(self.contents,rect.x,rect.y,optionwidth,rect.height,optionname,
       @nameBaseColor,@nameShadowColor)
    self.contents.draw_text(rect.x,rect.y,optionwidth,rect.height,optionname)
    return if index==@options.length
    if @options[index].is_a?(EnumOption)
      if @options[index].values.length>1
        totalwidth=0
        for value in @options[index].values
          totalwidth+=self.contents.text_size(value).width
        end
        spacing=(optionwidth-totalwidth)/(@options[index].values.length-1)
        spacing=0 if spacing<0
        xpos=optionwidth+rect.x
        ivalue=0
        for value in @options[index].values
          pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
             (ivalue==self[index]) ? @selBaseColor : self.baseColor,
             (ivalue==self[index]) ? @selShadowColor : self.shadowColor
          )
          self.contents.draw_text(xpos,rect.y,optionwidth,rect.height,value)
          xpos+=self.contents.text_size(value).width
          xpos+=spacing
          ivalue+=1
        end
      else
        pbDrawShadowText(self.contents,rect.x+optionwidth,rect.y,optionwidth,rect.height,
           optionname,self.baseColor,self.shadowColor)
      end
    elsif @options[index].is_a?(NumberOption)
      value=_ISPRINTF("{1:d}",@options[index].optstart+self[index])
      xpos=optionwidth+rect.x
      pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
         @selBaseColor,@selShadowColor)
    else
      value=@options[index].values[self[index]]
      xpos=optionwidth+rect.x
      pbDrawShadowText(self.contents,xpos,rect.y,optionwidth,rect.height,value,
         @selBaseColor,@selShadowColor)
      self.contents.draw_text(xpos,rect.y,optionwidth,rect.height,value)
    end
  end

  def update
    dorefresh=false
    oldindex=self.index
    @mustUpdateOptions=false
    super
    dorefresh=self.index!=oldindex
    if self.active && self.index<@options.length
      if Input.repeat?(Input::LEFT) || $go_back_left
        self[self.index]=@options[self.index].prev(self[self.index])
        dorefresh=true
        @mustUpdateOptions=true
        $go_back_left=nil
      elsif Input.repeat?(Input::RIGHT) || $go_back_right
        self[self.index]=@options[self.index].next(self[self.index])
        dorefresh=true
        @mustUpdateOptions=true
        $go_back_right=nil
      end
    end
    refresh if dorefresh
  end
end



module PropertyMixin
  def get
    @getProc ? @getProc.call() : nil
  end

  def set(value)
    @setProc.call(value) if @setProc
  end
end



class EnumOption
  include PropertyMixin
  attr_reader :values
  attr_reader :name

  def initialize(name,options,getProc,setProc)  #name,format,optstart,optend,getProc,setProc          
    @values=options
    @name=name
    @getProc=getProc
    @setProc=setProc
  end

  def next(current)
    index=current+1
    index=@values.length-1 if index>@values.length-1
    return index
  end

  def prev(current)
    index=current-1
    index=0 if index<0
    return index
  end
end



class EnumOption2
  include PropertyMixin
  attr_reader :values
  attr_reader :name

  def initialize(name,options,getProc,setProc)             
    @values=options
    @name=name
    @getProc=getProc
    @setProc=setProc
  end

  def next(current)
    index=current+1
    index=@values.length-1 if index>@values.length-1
    return index
  end

  def prev(current)
    index=current-1
    index=0 if index<0
    return index
  end
end



class NumberOption
  include PropertyMixin
  attr_reader :name
  attr_reader :optstart

  def initialize(name,format,optstart,optend,getProc,setProc)
    @name=name
    @format=format
    @optstart=optstart
    @optend=optend
    @getProc=getProc
    @setProc=setProc
  end

  def next(current)
    index=current+@optstart
    index+=1
    if index>@optend
      index=@optstart
    end
    return index-@optstart
  end

  def prev(current)
    index=current+@optstart
    index-=1
    if index<@optstart
      index=@optend
    end
    return index-@optstart
  end
end

#####################
#
#  Stores game options
#

$SpeechFrames=[
  MessageConfig::TextSkinName, # Default text skin - frlgtextskin
  "rstextskin",
  "rstextskin2",
  "emtextskin",
  "textbox0",
  "textbox1",
  "textbox2",
  "textbox3",
  "textbox4",
  "textbox5",
  "textbox6",
  "textbox7",
  "textbox8",
  "textbox9",
  "textbox10",
  "textbox11",
  "textbox12",
  "textbox13",
  "textbox14",
  "textbox15",
  "textbox16",
  "textbox17",
  "textbox18",
  "textbox19"
]

$TextFrames=[
  "Graphics/Windowskins/"+MessageConfig::ChoiceSkinName, # Default frame - skin1
  "Graphics/Windowskins/skin2",
  "Graphics/Windowskins/skin3",
  "Graphics/Windowskins/skin4",
  "Graphics/Windowskins/skin5",
  "Graphics/Windowskins/skin6",
  "Graphics/Windowskins/skin7",
  "Graphics/Windowskins/skin8",
  "Graphics/Windowskins/skin9",
  "Graphics/Windowskins/skin10",
  "Graphics/Windowskins/skin11",
  "Graphics/Windowskins/skin12",
  "Graphics/Windowskins/skin13",
  "Graphics/Windowskins/skin14",
  "Graphics/Windowskins/skin15",
  "Graphics/Windowskins/skin16",
  "Graphics/Windowskins/skin17",
  "Graphics/Windowskins/skin18",
  "Graphics/Windowskins/skin19",
  "Graphics/Windowskins/skin20",
  "Graphics/Windowskins/skin21",
  "Graphics/Windowskins/skin22",
  "Graphics/Windowskins/skin23",
  "Graphics/Windowskins/skin24",
  "Graphics/Windowskins/skin25",
  "Graphics/Windowskins/skin26",
  "Graphics/Windowskins/skin27",
  "Graphics/Windowskins/skin28"
]

$VersionStyles=[
  [MessageConfig::FontName], # Default font style - Power Green/"Pokemon Emerald"
  ["Power Red and Blue"],
  ["Power Red and Green"],
  ["Power Clear"]
]

def pbSettingToTextSpeed(speed)
  if speed==3
    $is_insane=true
   return -2
  end
  $is_insane=false
  return 3 if speed==0
  return 2 if speed==1
  return 1 if speed==2
  return -2
  return MessageConfig::TextSpeed if MessageConfig::TextSpeed
  return ((Graphics.frame_rate>40) ? -2 : 1)
end



module MessageConfig
  def self.pbDefaultSystemFrame
    if !$PokemonSystem
      return pbResolveBitmap("Graphics/Windowskins/"+MessageConfig::ChoiceSkinName+".png")||""
    else
      if $PokemonSystem.hiContrast && $PokemonSystem.hiContrast != 0
        return pbResolveBitmap("Graphics/Windowskins/skin29")
      end
      return pbResolveBitmap($TextFrames[$PokemonSystem.frame])||""
    end
  end

  def self.pbDefaultSpeechFrame
    if !$PokemonSystem
      return pbResolveBitmap("Graphics/Windowskins/"+MessageConfig::TextSkinName)||""
    else
      if $PokemonSystem.hiContrast && $PokemonSystem.hiContrast != 0
        return pbResolveBitmap("Graphics/Windowskins/textbox20")
      end
      return pbResolveBitmap("Graphics/Windowskins/"+$SpeechFrames[$PokemonSystem.textskin])||""
    end
  end

  def self.pbDefaultSystemFontName
    if !$PokemonSystem
      return MessageConfig.pbTryFonts(MessageConfig::FontName,"Arial Narrow","Arial")
    else
      return MessageConfig.pbTryFonts($VersionStyles[$PokemonSystem.font][0],"Arial Narrow","Arial")
    end
  end

  def self.pbDefaultTextSpeed
    return pbSettingToTextSpeed($PokemonSystem ? $PokemonSystem.textspeed : nil)
  end

  def pbGetSystemTextSpeed
    return $PokemonSystem ? $PokemonSystem.textspeed : ((Graphics.frame_rate>40) ? 2 :  3)
  end
end



class PokemonSystem
  attr_accessor :textspeed
  attr_accessor :battlescene
  attr_accessor :battlestyle
  attr_accessor :frame
  attr_accessor :textskin
  attr_accessor :font
  attr_accessor :screensize
  attr_accessor :tilemap
  attr_accessor :language
  attr_accessor :volume
  attr_accessor :soundvolume
  attr_accessor :statoverlay
  attr_accessor :alwaysday
  attr_accessor :chooseDifficulty
  attr_accessor :purism
  attr_accessor :turbospeed
  attr_accessor :turbopressed
  attr_accessor :alwaysday2
  attr_accessor :trainerdetection
  attr_accessor :hiContrast
  def language
    return (!@language) ? 0 : @language
  end

  def textskin
    return (!@textskin) ? 0 : @textskin
  end

  def initialize(savefile=0)
    @textspeed   = 2 # Text speed (0=slow, 1=mid, 2=fast)
    @battlescene = 0 # Battle scene (animations) (0=on, 1=off)
    @battlestyle = 0 # Battle style (0=shift, 1=set)
    @frame       = 0 # Default window frame (see also $TextFrames)
    @textskin    = 0 # Speech frame
    @font        = 0 # Font (see also $VersionStyles)
    @screensize  = DEFAULTSCREENZOOM.floor # 0=half size, 1=full size
    @tilemap     = MAPVIEWMODE # Map view (0=original, 1=custom, 2=perspective)
    @language    = 0 # Language (see also LANGUAGES in script PokemonSystem)
    @volume    = 100 # Language (see also LANGUAGES in script PokemonSystem)
     @statoverlay = 1 # Battle style (0=shift, 1=set)
     @chooseDifficulty = 1
     @trainerdetection = 1
     @purism = 0
     @hiContrast = 0
    
     @turbospeed=0
     @alwaysday2=0

 end
end

def statoverlay
  return 0 if pbInSafari?
  return statoverlay
end


class PokemonOptionScene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

 def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @volume=100 if !@volume
    @sprites["title"]=Window_UnformattedTextPokemon.newWithSize(
       _INTL("Options"),0,0,Graphics.width,64,@viewport)
    @sprites["textbox"]=Kernel.pbCreateMessageWindow
    @sprites["textbox"].letterbyletter=false
    @sprites["textbox"].text=_INTL("Speech frame {1}.",1+$PokemonSystem.textskin)
    screensize1=_INTL("Small")
    screensize2=_INTL("Normal")
    screensize3=_INTL("Large")
    screensize4=_INTL("Huge")

    # These are the different options in the game.  To add an option, define a
    # setter and a getter for that option.  To delete an option, comment it out
    # or delete it.  The game's options may be placed in any order.
    @PokemonOptions=[
       EnumOption.new(_INTL("Text Speed"),[_INTL(" Slow"),_INTL(" Mid"),_INTL(" Fast"),_INTL(" Insane")],
          proc { $PokemonSystem.textspeed },
          proc {|value|  
             $PokemonSystem.textspeed=value 
             MessageConfig.pbSetTextSpeed(pbSettingToTextSpeed(value)) 
          }
       ),
       EnumOption.new(_INTL("Battle Scene"),[_INTL("On"),_INTL("Off")],
          proc { $PokemonSystem.battlescene },
          proc {|value|  $PokemonSystem.battlescene=value }
       ),
       EnumOption.new(_INTL("Battle Style"),[_INTL("Shift"),_INTL("Set")],
          proc { $PokemonSystem.battlestyle },
          proc {|value|  $PokemonSystem.battlestyle=value }
       ),
       NumberOption.new(_INTL("Frame"),_INTL("Type %d"),1,$TextFrames.length,
          proc { $PokemonSystem.frame },
          proc {|value|  
             $PokemonSystem.frame=value
             MessageConfig.pbSetSystemFrame($TextFrames[value]) 
          }
       ),
                   
       NumberOption.new(_INTL("Speech Frame"),_INTL("Type %d"),1,$SpeechFrames.length,
          proc { $PokemonSystem.textskin },
          proc {|value|  $PokemonSystem.textskin=value;
             MessageConfig.pbSetSpeechFrame(
                "Graphics/Windowskins/"+$SpeechFrames[value]) }
       ),
       EnumOption.new(_INTL("Font Style"),[_INTL("Em"),_INTL("R/S"),_INTL("FRLG")],
          proc { $PokemonSystem.font },
          proc {|value|  
             $PokemonSystem.font=value
             MessageConfig.pbSetSystemFontName($VersionStyles[value])
          }
       ),
       EnumOption.new(_INTL("High Contrast (for acuity)"),[_INTL("Off"),_INTL("On")],
          proc { $PokemonSystem.hiContrast },
          proc {|value|  $PokemonSystem.hiContrast=value
         if value && value != 0
            $PokemonSystem.frame=28
          else
       #   $PokemonSystem.frame=0
           MessageConfig.pbSetSystemFrame($TextFrames[0])  if $PokemonSystem.frame==28

         end
          
         }
       ),
# Quote this section out if you don't want to allow players to change the screen
# size.
       EnumOption.new(_INTL("Screen Size"),[screensize1,screensize2,screensize3,screensize4],
          proc { $PokemonSystem.screensize },
          proc {|value|
             oldvalue=$PokemonSystem.screensize
             $PokemonSystem.screensize=value
             $ResizeOffsetX=0
             $ResizeOffsetY=0
             pbSetResizeFactor([0.5,1.0,1.5,2.0][value])
             if value!=oldvalue
               ObjectSpace.each_object(TilemapLoader){|o| next if o.disposed?; o.updateClass }
             end
          }
       ),
       NumberOption.new(_INTL("Music Volume"),_INTL("%d\%"),0,101,
         proc { $PokemonSystem.volume },
         proc {|value|
           $PokemonSystem.volume=value
           if $game_system.playing_bgm != nil
             $game_system.playing_bgm.volume=value
             $game_system.bgm_memorize
              $game_system.bgm_stop
              $game_system.bgm_restore
          end
          
          }
      ),
       NumberOption.new(_INTL("Sound Volume"),_INTL("%d\%"),0,101,
         proc { $PokemonSystem.soundvolume },
         proc {|value|
           $PokemonSystem.soundvolume=value
           if $game_system.playing_bgs != nil
             $game_system.playing_bgs.volume=value
             $game_system.bgs_memorize
              $game_system.bgs_stop
              $game_system.bgs_restore
          end
          
          }
      ),
      EnumOption.new(_INTL("Stat Change Overlay"),[_INTL("Off"),_INTL("On")],
          proc { $PokemonSystem.statoverlay },
          proc {|value|  $PokemonSystem.statoverlay=value }
       ),
       
      EnumOption.new(_INTL("Difficulty"),[_INTL("Easy"),_INTL("Normal"),_INTL("Hard")],
          proc { $PokemonSystem.chooseDifficulty },
          proc {|value| 
 #         if !$game_switches
 #           if $PokemonSystem.chooseDifficulty!=value
 #             Kernel.pbMessage("Difficulty will lock after earning your next Badge.")
 #           end
 #                           
                   $PokemonSystem.chooseDifficulty=value
 #    
 #           else
 #         if $game_switches[398]
 #           if $PokemonSystem.chooseDifficulty>value
 #             $go_back_right=1
 #           Kernel.pbMessage("Difficulty has been locked.")
 #           elsif $PokemonSystem.chooseDifficulty<value
 #             $go_back_left=1
 #           Kernel.pbMessage("Difficulty has been locked.")
 #           end
 #         else
 #         if $PokemonSystem.chooseDifficulty!=value
 #           $PokemonSystem.chooseDifficulty=value
 #         Kernel.pbMessage("Difficulty will lock after earning your next Badge.")
 #         end;end
 #       end
        }
#          Kernel.pbMessage("Difficulty:"+value.to_s) }
       ),
       #EnumOption.new(_INTL("Turbo Speed"),[_INTL("High"),_INTL("Hyper"),_INTL("Ludicrous")],
       #   proc { $PokemonSystem.turbospeed },
       #   proc {|value|  $PokemonSystem.turbospeed=value }
       #),
       EnumOption.new(_INTL("Purity Mode"),[_INTL("Off"),_INTL("On"),_INTL("Info")],

       proc { $PokemonSystem.purism },
          proc {|value|
          if value==2
            Kernel.pbMessage("Purity Mode is an option that toggles whether new Pokemon designs will appear in the game.")
            Kernel.pbMessage("Several new Mega Evolutions and \"Delta Species\" are added to Insurgence.")
            Kernel.pbMessage("Purity Mode replaces any such designs in the story with traditional Pokemon ones.")
            Kernel.pbMessage("They will still be in game, but only if looked for.")
            Kernel.pbMessage("Not recommended, unless you are strongly opposed to fan designs.")
            $go_back_left=1
          else
          $PokemonSystem.purism=value 
        end
        }

       ),
       EnumOption.new(_INTL("Constant Daytime"),[_INTL("Off"),_INTL("On")],
          proc { $PokemonSystem.alwaysday2 },
          proc {|value|  $PokemonSystem.alwaysday2=value }
       ),
       
       EnumOption.new(_INTL("Trainer Detection"),[_INTL("Off"),_INTL("On")],
          proc { $PokemonSystem.trainerdetection },
          proc {|value|  $PokemonSystem.trainerdetection=value }
       )

# ------------------------------------------------------------------------------
    ]
    if $game_switches

      @PokemonOptions.push(
      EnumOption.new(_INTL("Story Mode"),[_INTL("Traditional"),_INTL("Darker"),_INTL("Info")],
          proc { $game_variables[137] },
          proc {|value|
          if !Kernel.getIsInPokecenter
                if $game_variables[137]>value
              $go_back_right=1
            Kernel.pbMessage("You must be in a Pokemon Center to change this option.")
            elsif $game_variables[137]<value
              $go_back_left=1
            Kernel.pbMessage("You must be in a Pokemon Center to change this option.")
            end

            else
          if value==2
            Kernel.pbMessage("There are two alternate story modes due to popular request.")
            Kernel.pbMessage("The \"Lighter\" story has no character death and lightens some plot points.")
            Kernel.pbMessage("The story remains generally the same, but is much less dark and edgy.")
            $go_back_left=1
          else
          $game_variables[137]=value 
          end;end}
       ))
     end
     
    @sprites["option"]=Window_PokemonOption.new(@PokemonOptions,0,
       @sprites["title"].height,Graphics.width,
       Graphics.height-@sprites["title"].height-@sprites["textbox"].height)
    @sprites["option"].viewport=@viewport
    @sprites["option"].visible=true
    # Get the values of each option
    for i in 0...@PokemonOptions.length
      @sprites["option"][i]=(@PokemonOptions[i].get || 0)
    end
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbOptions
    pbActivateWindow(@sprites,"option"){
       loop do
         Graphics.update
         Input.update
         pbUpdate
         if @sprites["option"].mustUpdateOptions
           # Set the values of each option
           for i in 0...@PokemonOptions.length
             @PokemonOptions[i].set(@sprites["option"][i])
           end
           @sprites["textbox"].setSkin(MessageConfig.pbGetSpeechFrame())
           @sprites["textbox"].width=@sprites["textbox"].width  # Necessary evil
           pbSetSystemFont(@sprites["textbox"].contents)
           @sprites["textbox"].text=_INTL("Speech frame {1}.",1+$PokemonSystem.textskin)
         end
         if Input.trigger?(Input::B)
          if $PokemonSystem.screensize==2
            Kernel.pbMessage("Note: \"Large\" screen size may cause minor graphical issues in certain areas.")
            Kernel.pbMessage("Note: If possible, try using \"Small\", \"Normal\", or \"Huge\".")
          end
           break
         end
         if Input.trigger?(Input::C) && @sprites["option"].index==@PokemonOptions.length
           break
         end
       end
    }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Set the values of each option
    for i in 0...@PokemonOptions.length
      @PokemonOptions[i].set(@sprites["option"][i])
    end
    Kernel.pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    pbRefreshSceneMap
    @viewport.dispose
  end
end



class PokemonOption
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbOptions
    @scene.pbEndScene
  end
end