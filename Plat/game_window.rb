require 'gosu'
require_relative 'level'
require_relative 'player'
require_relative 'camera'
require_relative 'menu_window'

module Platformer
  class GameWindow < Gosu::Window
    SCREEN_W = 640
    SCREEN_H = 480

    def initialize(level_path:)
      super(SCREEN_W, SCREEN_H)
      self.caption = "Platformer"
      @level_path = level_path
      load_level(@level_path)
    end

    def load_level(path)
      @level = Level.load(path)

      if @level.spawn_tile
        sx, sy = @level.spawn_tile
        spawn_x = sx * Platformer::Level::TILE_SIZE
        spawn_y = sy * Platformer::Level::TILE_SIZE
      else
        spawn_x = Platformer::Level::TILE_SIZE * 2
        spawn_y = Platformer::Level::TILE_SIZE * (@level.height - 3)
      end

      @player = Player.new(spawn_x, spawn_y)
      @camera = Camera.new(SCREEN_W, SCREEN_H)
      @death_message = nil
      @victory_message = nil
      @level_start_time = Gosu.milliseconds
      @completion_time = nil
      @stars_collected = 0
      @total_stars = @level.total_stars
    end

    def update
      return if @victory_message # allow respawn after death

      @level.update
      @player.update(@level)
      @camera.update(@player.x, @player.y,
                     @level.width * Level::TILE_SIZE,
                     @level.height * Level::TILE_SIZE)

      if @player.dead?(@level)
        @death_message = "You fell off the world!"
      end

      if @player.victory?(@level)
        elapsed = (Gosu.milliseconds - @level_start_time) / 1000.0
        @victory_message = "You Win!"
        @completion_time = elapsed
        @stars_collected = @player.stars_collected
        @total_stars = @level.total_stars
      end
    end



    def draw
      @level.draw_background
      @level.draw(@camera.x, @camera.y, width, height)
      @player.draw(@camera.x, @camera.y, @level)


      # HUD
      font = Gosu::Font.new(20)
      font.draw_text("Stars: #{@player.stars_collected}/#{@level.total_stars}",
                     10, 10, 10, 1.0, 1.0, Gosu::Color::YELLOW)
      font.draw_text("Double Jump: #{@player.double_jump_time_remaining}s",
                     10, 30, 10, 1.0, 1.0, Gosu::Color::CYAN)
      font.draw_text("Time: #{(Gosu.milliseconds - @level_start_time)/1000}s",
                     10, 50, 10, 1.0, 1.0, Gosu::Color::WHITE)

      if @death_message
        overlay(@death_message, Gosu::Color::WHITE,
                "Press R to restart or M for menu")
      elsif @victory_message
        percent = @total_stars.zero? ? 0 :
                    (@stars_collected.to_f / @total_stars * 100).round
        overlay("You Win!", Gosu::Color::GREEN,
                "Time: #{@completion_time}s | Stars: #{@stars_collected}/#{@total_stars} (#{percent}%)\nPress R to restart or M for menu")
      end
    end

    def button_down(id)
      if id == Gosu::KB_SPACE
        @player.jump(@level)
      elsif id == Gosu::KB_R
        if @death_message
          # Respawn at checkpoint instead of reloading level
          @player.respawn
          @death_message = nil
        else
          load_level(@level_path) # reload current level
        end
      elsif id == Gosu::KB_M
        MenuWindow.new.show
        close
      elsif id == Gosu::KB_ESCAPE
        close
      else
        super
      end
    end



    private

    def overlay(message, color, subtext)
      Gosu.draw_rect(0, 0, width, height, Gosu::Color::BLACK, 10)
      font_big = Gosu::Font.new(40)
      font_small = Gosu::Font.new(25)
      font_big.draw_text(message, width/2 - 100, height/2 - 40,
                         20, 1.0, 1.0, color)
      font_small.draw_text(subtext, width/2 - 150, height/2 + 20,
                           20, 1.0, 1.0, Gosu::Color::YELLOW)
    end
  end
end
