# Background to show when viewing the NationalDex Certification. Found in Graphics/Pictures/ folder
CertificateBackgroundList = ["diploma"]
CREDITS_OUTLINE       = Color.new(0,0,128, 255)
CREDITS_SHADOW        = Color.new(0,0,0, 100)
CREDITS_FILL          = Color.new(255,255,255, 255)

class Scene_Certificate
  def main
#-------------------------------
# Background Setup
#-------------------------------
    @sprite = IconSprite.new(0,0)
    @backgroundList = CertificateBackgroundList
    @sprite.setBitmap("Graphics/Pictures/"+@backgroundList[0])
#--------
# Setup
#--------
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    Graphics.freeze
    @sprite.dispose
  end
  
#Check if the certificate should be cancelled
  def cancel?
    if Input.trigger?(Input::C)
      $scene = Scene_Map.new
      return true
    end
    return false
  end

  def update
    return if cancel?
  end
end