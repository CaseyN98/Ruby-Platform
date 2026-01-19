require 'gosu'
require_relative 'game_window'

module Platformer
  class MenuWindow < Gosu::Window
    SCREEN_W = 640
    SCREEN_H = 480

    def initialize
      super(SCREEN_W, SCREEN_H)
      self.caption = "Select Level"
      @font = Gosu::Font.new(30)
      @levels = Dir.glob("levels/*.txt")   # list all .txt files in levels/
      @selected_index = 0
    end

    def update
      # nothing needed here
    end

    def draw
      @font.draw_text("Select a Level:", 200, 50, 1, 1.0, 1.0, Gosu::Color::YELLOW)

      @levels.each_with_index do |level, i|
        color = (i == @selected_index) ? Gosu::Color::RED : Gosu::Color::WHITE
        @font.draw_text("#{i+1}. #{File.basename(level)}", 200, 120 + i*40, 1, 1.0, 1.0, color)
      end
    end

    def button_down(id)
      case id
      when Gosu::KB_DOWN
        @selected_index = (@selected_index + 1) % @levels.size
      when Gosu::KB_UP
        @selected_index = (@selected_index - 1) % @levels.size
      when Gosu::KB_RETURN, Gosu::KB_SPACE
        # Start game with selected level
        GameWindow.new(level_path: @levels[@selected_index]).show
      when Gosu::KB_ESCAPE
        close
      else
        super
      end
    end
  end
end

