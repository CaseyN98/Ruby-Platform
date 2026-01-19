require "chingu"
require_relative "game_state"

class MenuState < Chingu::GameState
  def setup
    @font = Gosu::Font.new(30)
    @levels = Dir.glob("levels/*.txt")
    @selected = 0
    @empty = @levels.empty?
  end

  def draw
    if @empty
      @font.draw_text("No levels found in levels/", 100, 200, 10, 1.0, 1.0, Gosu::Color::RED)
      return
    end

    title = "Select a Level"
    title_w = @font.text_width(title)
    @font.draw_text(title,
                    ($window.width - title_w)/2,
                    50, 10, 1.0, 1.0, Gosu::Color::YELLOW)

    @levels.each_with_index do |level, i|
      name = "#{i+1}. #{File.basename(level)}"
      w = @font.text_width(name)
      color = (i == @selected) ? Gosu::Color::RED : Gosu::Color::WHITE
      @font.draw_text(name,
                      ($window.width - w)/2,
                      120 + i*40, 10, 1.0, 1.0, color)
    end
  end

  def button_down(id)
    return super if @empty
    case id
    when Gosu::KB_DOWN
      @selected = (@selected + 1) % @levels.size
    when Gosu::KB_UP
      @selected = (@selected - 1) % @levels.size
      @selected = @levels.size - 1 if @selected < 0
    when Gosu::KB_RETURN, Gosu::KB_SPACE
      push_game_state(GameState.new(level_path: @levels[@selected]))
    when Gosu::KB_ESCAPE, Gosu::KB_Q
      close
    else
      super
    end
  end
end

