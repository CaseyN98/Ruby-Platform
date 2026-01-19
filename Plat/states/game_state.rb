require "chingu"
require_relative "../models/level"
require_relative "../entities/player"

class GameState < Chingu::GameState
  def initialize(level_path:)
    super()
    @level_path = level_path
  end

  def setup
    load_level(@level_path)
    @font_small = Gosu::Font.new(20)
    @font_big   = Gosu::Font.new(40)
  end

  def load_level(path)
    @level = Platformer::Level.load(path)

    spawn = @level.spawn_tile || [2, @level.height - 3]
    spawn_px = [spawn[0] * Platformer::Level::TILE_SIZE,
                spawn[1] * Platformer::Level::TILE_SIZE]

    @player = Platformer::Player.new(spawn_px[0], spawn_px[1])
    @death_message = nil
    @victory_message = nil
    @level_start_ms = Gosu.milliseconds
    @completion_time = nil

    @camera_x = 0
    @camera_y = 0
  end

  def update
    return if @victory_message
    @level.update
    @player.update(@level)
    clamp_camera_to_player

    if @player.dead?(@level)
      @death_message = "You fell off the world!"
    else
      @death_message = nil
    end

    if @player.victory?(@level)
      @victory_message = "You Win!"
      @completion_time = ((Gosu.milliseconds - @level_start_ms) / 1000.0).round(2)
      @stars_collected = @player.stars_collected
      @total_stars     = @level.total_stars_initial
    end
  end

def draw
  return unless $window   # bail out if window is nil

  @level.draw_background($window.width, $window.height)
  @level.draw(@camera_x, @camera_y, $window.width, $window.height)
  @player.draw(@camera_x, @camera_y, @level)

  # HUD
  @font_small.draw_text("Stars: #{@player.stars_collected}/#{@level.total_stars_initial}",
                        10, 10, 10, 1.0, 1.0, Gosu::Color::YELLOW)
  @font_small.draw_text("Double Jump: #{@player.double_jump_time_remaining}s",
                        10, 30, 10, 1.0, 1.0, Gosu::Color::CYAN)
  elapsed = (Gosu.milliseconds - @level_start_ms)/1000
  @font_small.draw_text("Time: #{elapsed}s",
                        10, 50, 10, 1.0, 1.0, Gosu::Color::WHITE)

  if @death_message
    draw_overlay(@death_message, "Press R to respawn or M for menu", Gosu::Color::WHITE)
  elsif @victory_message
    percent = @total_stars.zero? ? 0 : ((@stars_collected.to_f / @total_stars) * 100).round
    draw_overlay("You Win!",
                 "Time: #{@completion_time}s | Stars: #{@stars_collected}/#{@total_stars} (#{percent}%)\nPress R to restart or M for menu",
                 Gosu::Color::GREEN)
  end
end



  def button_down(id)
    case id
    when Gosu::KB_SPACE
      @player.jump(@level)
    when Gosu::KB_R
      if @death_message
        @player.respawn
        @death_message = nil
      else
        load_level(@level_path)
      end
    when Gosu::KB_M
      pop_game_state # back to menu
    when Gosu::KB_ESCAPE
      close
    else
      super
    end
  end

  private

def clamp_camera_to_player
  return unless $window   # bail out if window is nil

  target_x = @player.x - $window.width / 2
  target_y = @player.y - $window.height / 2

  max_w = @level.width * Platformer::Level::TILE_SIZE - $window.width
  max_h = @level.height * Platformer::Level::TILE_SIZE - $window.height

  @camera_x = [[target_x, 0].max, [max_w, 0].max].min
  @camera_y = [[target_y, 0].max, [max_h, 0].max].min
end


def draw_overlay(title, subtitle, color)
  return unless $window   # skip if window is nil

  Gosu.draw_rect(0, 0, $window.width, $window.height, Gosu::Color.argb(0xAA000000), 9)
  tw = @font_big.text_width(title)
  @font_big.draw_text(title, ($window.width - tw)/2, $window.height/2 - 40, 10, 1.0, 1.0, color)
  @font_small.draw_text(subtitle, 20, $window.height/2 + 20, 10, 1.0, 1.0, Gosu::Color::WHITE)
end



end