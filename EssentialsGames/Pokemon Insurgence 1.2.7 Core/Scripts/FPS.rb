=begin
#=============================================================================
#
# [ Frame Rate Display ] [ RMXP / RMVX ] [ Scripting Tool ]
#
#=============================================================================
#    Version :  1.00.0
#       Date :  10/9/2011
#-----------------------------------------------------------------------------
# Written By : kellessdee
#    Contact : kellessdee@gmail.com
#-----------------------------------------------------------------------------
# This work is protected by the following license:
#
# Creative Commons - Attribution-NonCommercial-ShareAlike 3.0 Unported
# ( http://creativecommons.org/licenses/by-nc-sa/3.0/ )
#  
# You are free:
#  
# to Share - to copy, distribute and transmit the work
# to Remix - to adapt the work
#   
# Under the following conditions:
#   
# Attribution. You must attribute the work in the manner specified by the
# author or licensor (but not in any way that suggests that they endorse you
# or your use of the work).
#   
# Noncommercial. You may not use this work for commercial purposes.
#   
# Share alike. If you alter, transform, or build upon this work, you may
# distribute the resulting work only under the same or similar license to
# this one.
#   
# - For any reuse or distribution, you must make clear to others the license
#   terms of this work. The best way to do this is with a link to this web
#   page.
#  
# - Any of the above conditions can be waived if you get permission from the
#   copyright holder.
#   
# - Nothing in this license impairs or restricts the author's moral rights.
#  
#----------------------------------------------------------------------------
# DESCRIPTION
#----------------------------------------------------------------------------
# This Script calculates the frame rate based off of the system clock, and is
# calculated each second, thus providing an accurate reading of the game's 
# frame rate. This would be most useful for optimization of code ( find exact 
# dips in Frame rate, slowdowns, etc. ) or for seeing how well the game runs on 
# a Lower-end machine ( perhaps to get a fairly accurate minimum requirements )
#----------------------------------------------------------------------------
# INSTRUCTIONS
#----------------------------------------------------------------------------
# All you need to do is create a global variable as an instance of FPS_Display
# ( creating it in main would probably be best/easiest )
#
#     $fps = FPS_Display.new
#
# It is updated and handled through Graphics.update, so you don't have to do 
# anything else.
#
# The F5 key toggles the Frame Rate Display by default. You can configure the 
# key in the FPS_Display CONFIGURATION section.
#
#=============================================================================

class FPS_Display
  
  #===CONFIGURATION===#
    TOGGLE = Input::F5
  #=END CONFIGURATION=#
  
  attr_accessor :frame_count
  
	def initialize
    
                # Create Sprite to display FPS
		@counter = Sprite.new
    
                # Position Sprite
		@counter.x, @counter.z = 440, 99999999
    
                # Create / Setup Bitmap
		@counter.bitmap = Bitmap.new(200, 24)
                @counter.bitmap.fill_rect(0, 0, 200, 24, Color.new(0, 0, 0))
		@counter.bitmap.font.size = 16
                @counter.bitmap.font.bold = true
		@counter.bitmap.draw_text(100, 0, 100, 24, ' FPS')
    
                # Get Target Frame Rate
		@frame_rate = Graphics.frame_rate
    
                # Set Start time
		@start = nil
		@on = true
                @frame_count = 0
		@fps = @frame_rate
		refresh
    
	end
	
	def refresh
    
                # Clear FPS
		@counter.bitmap.fill_rect(0, 0, 100, 24, Color.new(0,0,0))
    
                # Redraw Current FPS
		@counter.bitmap.draw_text(0, 0, 100, 24, @fps.to_s + " / " + 
                      @frame_rate.to_s, 2)
    
	end
		
	def update
    
                # If F5 is pressed, toggle FPS display
		if Input.trigger?(TOGGLE)
			@on = !@on
			@counter.visible = @on
		end
    
               (@frame_count = 0; return) if !@on
               if @start == nil
                 @start = Time.now
                 @frame_count = 0
               end
               # Get time elapsed in seconds
	       cur_time = Time.now - @start
    
               if cur_time >= 1
               # Get Frames per second
               fps = (@frame_count / cur_time).to_i
    
               # If during check interval and the Frame Rate has changed
               if @fps != fps
                  @fps = fps
                  refresh
                end
                @start = nil
        end
    
	end
	
	def dispose
    
		@counter.dispose; @counter = nil
    
	end
  
end

module Graphics
  
  class << self
    
    alias :new_upd_fps :update unless method_defined?(:new_upd_fps)
    
  end
  
  def self.update
    
    self.new_upd_fps
    
    return if $fps == nil
    
    $fps.frame_count += 1 
    $fps.update
    
  end
  
end
=end