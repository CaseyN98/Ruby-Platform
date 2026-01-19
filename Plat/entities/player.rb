require "gosu"
require_relative "../models/level"

module Platformer
  class Player
    attr_reader :x, :y, :vel_y, :stars_collected, :double_jump_time_remaining

    PLAYER_W = 32
    PLAYER_H = 32
    GRAVITY   = 1
    MOVE_SPEED = 4
    JUMP_SPEED = -16
    DOUBLE_JUMP_DURATION = 10_000

    def initialize(spawn_x_px, spawn_y_px)
      @x = spawn_x_px
      @y = spawn_y_px
      @respawn_x, @respawn_y = spawn_x_px, spawn_y_px
      @vel_y = 0

      @idle_frames = [Gosu::Image.new("assets/player_idle.png")]
      @walk_frames = [
        Gosu::Image.new("assets/player_walk1.png"),
        Gosu::Image.new("assets/player_walk2.png"),
        Gosu::Image.new("assets/player_walk3.png")
      ]
      @jump_frame = Gosu::Image.new("assets/player_jump.png")

      @frame_index = 0
      @frame_time = 0
      @facing_left = false

      @checkpoint_message_until = 0

      @stars_collected = 0
      @double_jump_expires_at = 0
      @has_double_jumped = false
    end

    def update(level)
      handle_horizontal(level)
      handle_vertical(level)

      # Reset velocity if grounded
      @vel_y = 0 if grounded?(level) && @vel_y > 0

      # Checkpoint
      if level.checkpoint_at?(@x + PLAYER_W/2, @y + PLAYER_H/2)
        @respawn_x, @respawn_y = @x, @y
        @checkpoint_message_until = Gosu.milliseconds + 1000
      end

      # Stars
      if level.collect_star_at?(@x + PLAYER_W/2, @y + PLAYER_H/2)
        @stars_collected += 1
      end

      # Double jump power-up
      if level.collect_powerup_at?(@x + PLAYER_W/2, @y + PLAYER_H/2)
        @double_jump_expires_at = Gosu.milliseconds + DOUBLE_JUMP_DURATION
        @has_double_jumped = false
      end

      # Walk animation
      if Gosu.milliseconds - @frame_time > 150
        @frame_index = (@frame_index + 1) % @walk_frames.size
        @frame_time = Gosu.milliseconds
      end
    end

    def draw(camera_x, camera_y, level)
      current_sprite =
        if !grounded?(level) && @vel_y < 0
          @jump_frame
        elsif Gosu.button_down?(Gosu::KB_LEFT) || Gosu.button_down?(Gosu::KB_RIGHT)
          @walk_frames[@frame_index]
        else
          @idle_frames.first
        end

      scale_x = @facing_left ? -1 : 1
      current_sprite.draw_rot(@x - camera_x + PLAYER_W/2,
                              @y - camera_y + PLAYER_H/2,
                              2, 0, 0.5, 0.5, scale_x, 1)

      if Gosu.milliseconds < @checkpoint_message_until
        font = Gosu::Font.new(40)
        font.draw_text("Checkpoint Reached", 140, 200, 10, 1.0, 1.0, Gosu::Color::YELLOW)
      end
    end

    def jump(level)
      if grounded?(level)
        @vel_y = JUMP_SPEED
        @has_double_jumped = false
      elsif double_jump_active? && !@has_double_jumped
        @vel_y = JUMP_SPEED
        @has_double_jumped = true
      end
    end

    def dead?(level)
      @x < 0 || @x > level.width * Platformer::Level::TILE_SIZE || @y > level.height * Platformer::Level::TILE_SIZE
    end

    def victory?(level)
      level.victory_at?(@x, @y)
    end

    def respawn
      @x, @y = @respawn_x, @respawn_y
      @vel_y = 0
    end

    def double_jump_time_remaining
      remaining = @double_jump_expires_at - Gosu.milliseconds
      remaining > 0 ? (remaining / 1000.0).round : 0
    end

    private

    def double_jump_active?
      Gosu.milliseconds < @double_jump_expires_at
    end

    def handle_horizontal(level)
      dx = 0
      if Gosu.button_down?(Gosu::KB_LEFT)
        dx -= MOVE_SPEED
        @facing_left = true
      end
      if Gosu.button_down?(Gosu::KB_RIGHT)
        dx += MOVE_SPEED
        @facing_left = false
      end

      return if dx == 0
      @x += dx
      while collides_rect?(@x, @y, level)
        @x -= dx <=> 0  # step back one pixel in the direction of movement
      end
    end

    def handle_vertical(level)
      @vel_y += GRAVITY
      @y += @vel_y

      if @vel_y > 0
        while collides_rect?(@x, @y, level)
          @y -= 1
          @vel_y = 0
        end
      elsif @vel_y < 0
        while collides_rect?(@x, @y, level)
          @y += 1
          @vel_y = 0
        end
      end
    end

    def grounded?(level)
      collides_rect?(@x, @y + PLAYER_H + 1, level)
    end

    def collides_rect?(new_x, new_y, level)
      left   = new_x / Platformer::Level::TILE_SIZE
      right  = (new_x + PLAYER_W - 1) / Platformer::Level::TILE_SIZE
      top    = new_y / Platformer::Level::TILE_SIZE
      bottom = (new_y + PLAYER_H - 1) / Platformer::Level::TILE_SIZE

      (top..bottom).each do |ty|
        (left..right).each do |tx|
          return true if level.solid_tile?(tx, ty)
        end
      end
      false
    end
  end
end

