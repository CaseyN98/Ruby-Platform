require "chingu"
require_relative "menu_state"

class TitleState < Chingu::GameState
  FADE_TIME = 150 
  MAX_SHOOTING_STARS = 6

  def setup
    @font_main = Gosu::Font.new(90)
    @font_sub  = Gosu::Font.new(28)
    
    # Path correction check
    @bg_img = Gosu::Image.new("assets/backgrounds/sky.png") rescue nil
    @logo_img = Gosu::Image.new("assets/player_idle.png") rescue nil
    @star_img = Gosu::Image.new("assets/star.png") rescue nil
    
    @alpha = 0
    @timer = 0
    @shooting_stars = []
    
    # Pre-populate stars across the screen so some are visible immediately
    MAX_SHOOTING_STARS.times do 
      star = spawn_shooting_star
      star[:x] = rand($window.width) # Spread them out initially
      @shooting_stars << star
    end
  end

  def spawn_shooting_star
    {
      x: $window.width + rand(100..600), # Start well off-right
      y: rand(-100..$window.height / 2), # Start in upper half
      speed: rand(12.0..22.0),
      scale: rand(0.4..0.8),             # Increased size
      angle: rand(210..240)              # Angle: Down and Left (Standard Gosu/Math)
    }
  end

  def update
    super
    @timer += 1
    @alpha = [[(@timer.to_f / FADE_TIME) * 255, 255].min, 0].max
    @offset_y = Math.sin(@timer / 25.0) * 12

    @shooting_stars.each do |s|
      # Movement logic (convert angle to radians)
      rad = s[:angle] * Math::PI / 180.0
      s[:x] += Math.cos(rad) * s[:speed]
      s[:y] -= Math.sin(rad) * s[:speed] # Note: - for Up/Down check depending on angle
      
      # Respawn if they leave left or bottom
      if s[:x] < -200 || s[:y] > $window.height + 200
        s.merge!(spawn_shooting_star)
      end
    end
  end

  def draw
    return unless $window

    # 1. Background (Z=0)
    @bg_img.draw(0, 0, 0, $window.width.to_f / @bg_img.width, $window.height.to_f / @bg_img.height) if @bg_img

    # 2. Shooting Stars (Z=1)
    @shooting_stars.each do |s|
      # Draw trail
      4.times do |i|
        # Brighter trails
        trail_alpha = ((@alpha / 255.0) * (200 - (i * 45))).to_i
        color = Gosu::Color.rgba(255, 255, 230, [trail_alpha, 0].max)
        
        # Draw each star in the trail slightly behind the leader
        @star_img.draw(s[:x] + (i * 12), s[:y] - (i * 8), 1, s[:scale], s[:scale], color) if @star_img
      end
    end

    # 3. Cinematic Overlay (Z=2)
    overlay_alpha = (@alpha * 0.6).to_i
    Gosu.draw_rect(0, 0, $window.width, $window.height, Gosu::Color.argb((overlay_alpha << 24) | 0x050510), 2)

    # 4. Floating Logo (Z=3)
    if @logo_img
      logo_scale = 2.5 # Scaled up player icon if used as logo
      lx = ($window.width - @logo_img.width * logo_scale) / 2
      ly = ($window.height / 2) - (@logo_img.height * logo_scale) - 40 + @offset_y
      @logo_img.draw(lx, ly, 3, logo_scale, logo_scale, Gosu::Color.rgba(255, 255, 255, @alpha))
    end

    # 5. Title (Z=4, 5)
    title = "SEEK THE STARS"
    tx = ($window.width - @font_main.text_width(title)) / 2
    ty = ($window.height / 2) + 60 + @offset_y
    @font_main.draw_text(title, tx + 6, ty + 6, 4, 1, 1, Gosu::Color.rgba(0, 0, 0, @alpha))
    @font_main.draw_text(title, tx, ty, 5, 1, 1, Gosu::Color.rgba(255, 215, 0, @alpha))

    # 6. Prompt (Z=6)
    if @timer > FADE_TIME
      p_pulse = ((Math.sin(Gosu.milliseconds / 300.0) + 1) / 2.0 * 255).to_i
      pw = @font_sub.text_width("PRESS ANY KEY TO START")
      @font_sub.draw_text("PRESS ANY KEY TO START", ($window.width - pw) / 2, $window.height - 100, 6, 1, 1, Gosu::Color.rgba(255, 255, 255, p_pulse))
    end
  end

  def button_down(id)
    push_game_state(MenuState)
  end
end