class Scene_DebugIntro
  def main
    Graphics.transition(0)
damian=[false]
    while !damian[0]
    damian[0]=true
    sscene=PokemonLoadScene.new
    sscreen=PokemonLoad.new(sscene)
    sscreen.pbStartLoadScreen(0,damian)
  end    
  Graphics.freeze
  end
end