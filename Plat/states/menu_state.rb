require "chingu"
require_relative "game_state"

class MenuState < Chingu::GameState
  VISIBLE_COUNT = 8
  ITEM_SPACING = 70
  TITLE_Y = 50
  BASE_Y = 160

  def setup
    @font_title = Gosu::Font.new(72)
    @font_item  = Gosu::Font.new(32)
    @font_stats = Gosu::Font.new(20)
    
    @star_img = Gosu::Image.new("assets/star.png") rescue nil
    
    @levels = Dir.glob("levels/*.txt")
    @selected = 0
    @scroll_offset = 0
    @empty = @levels.empty?
  end

  def draw
    return unless $window
    return draw_empty_message if @empty
    
    draw_background_dim
    draw_title
    draw_level_list
  end

  def draw_background_dim
    Gosu.draw_rect(0, 0, $window.width, $window.height, Gosu::Color.argb(0xCC050505), 0)
    Gosu.draw_rect(50, 140, $window.width - 100, $window.height - 180, Gosu::Color.argb(0x33FFFFFF), 1)
  end

  def draw_title
    title = "SEEK THE STARS"
    @font_title.draw_text(title, ($window.width - @font_title.text_width(title)) / 2 + 4, TITLE_Y + 4, 10, 1, 1, Gosu::Color::BLACK)
    @font_title.draw_text(title, ($window.width - @font_title.text_width(title)) / 2, TITLE_Y, 10, 1, 1, Gosu::Color::YELLOW)
    
    subtitle = "Select a Level to Begin"
    subtitle_y = TITLE_Y + 90
    @font_stats.draw_text(subtitle, ($window.width - @font_stats.text_width(subtitle)) / 2, subtitle_y, 10, 1, 1, Gosu::Color::GRAY)
  end

  def draw_level_list
    visible_levels = @levels[@scroll_offset, VISIBLE_COUNT] || []

    visible_levels.each_with_index do |level, i|
      index = @scroll_offset + i
      level_name = File.basename(level, ".txt").capitalize
      stats = SaveData.get(File.basename(level))
      
      best_stars  = stats["stars"] || 0
      total_stars = stats["total_stars"] || "?"
      best_time   = stats["time"] ? "#{stats["time"]}s" : "N/A"

      x = 100
      y = BASE_Y + i * ITEM_SPACING
      w = $window.width - 200
      h = 60

      bg_color = (index == @selected) ? pulsing_selection_color : Gosu::Color.argb(0x44AAAAAA)
      Gosu.draw_rect(x, y, w, h, bg_color, 2)
      
      draw_outline(x, y, w, h, Gosu::Color::YELLOW) if index == @selected

      @font_item.draw_text(level_name, x + 20, y + 12, 10, 1, 1, Gosu::Color::WHITE)

      stats_text = "Best Time: #{best_time}"
      tw = @font_stats.text_width(stats_text)
      @font_stats.draw_text(stats_text, x + w - tw - 20, y + 20, 10, 1, 1, Gosu::Color::CYAN)
      
      draw_stars(x + 220, y + 15, best_stars, total_stars)
    end
  end

  def draw_stars(x, y, count, total)
    return unless @star_img
    total_val = total.to_i rescue 3
    total_val = 3 if total_val == 0
    
    total_val.times do |i|
      color = (i < count.to_i) ? Gosu::Color::WHITE : Gosu::Color.argb(0x44FFFFFF)
      @star_img.draw(x + i * 25, y, 10, 0.4, 0.4, color)
    end
  end

  def pulsing_selection_color
    pulse = (Math.sin(Gosu.milliseconds / 200.0) + 1) / 2.0
    alpha = (0x66 + (pulse * 0x44)).to_i
    Gosu::Color.argb((alpha << 24) | 0xFF4444)
  end

  def draw_outline(x, y, w, h, color)
    thickness = 3
    Gosu.draw_rect(x - thickness, y - thickness, w + thickness*2, thickness, color, 3)
    Gosu.draw_rect(x - thickness, y + h, w + thickness*2, thickness, color, 3)
    Gosu.draw_rect(x - thickness, y, thickness, h, color, 3)
    Gosu.draw_rect(x + w, y, thickness, h, color, 3)
  end

  def draw_empty_message
    msg = "No levels found in levels/"
    @font_item.draw_text(msg, ($window.width - @font_item.text_width(msg)) / 2, $window.height / 2, 10, 1, 1, Gosu::Color::RED)
  end

  def button_down(id)
    return super if @empty

    case id
    when Gosu::KB_DOWN
      @selected = (@selected + 1) % @levels.size
      adjust_scroll
    when Gosu::KB_UP
      @selected = (@selected - 1) % @levels.size
      @selected = @levels.size - 1 if @selected < 0
      adjust_scroll
    when Gosu::KB_RETURN, Gosu::KB_SPACE
      push_game_state(GameState.new(level_path: @levels[@selected]))
    when Gosu::KB_ESCAPE, Gosu::KB_Q
      close
    else
      super
    end
  end

  def adjust_scroll
    if @selected < @scroll_offset
      @scroll_offset = @selected
    elsif @selected >= @scroll_offset + VISIBLE_COUNT
      @scroll_offset = @selected - VISIBLE_COUNT + 1
    end
  end
end