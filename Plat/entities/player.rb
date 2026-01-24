require "gosu"
require_relative "../models/level"

module Platformer
  class Player
    attr_reader :x, :y, :vel_y, :stars_collected

    PLAYER_W = 32
    PLAYER_H = 32
    GRAVITY  = 1
    MOVE_SPEED = 4
    JUMP_SPEED = -16
    DOUBLE_JUMP_DURATION = 10_000

    def initialize(spawn_x_px, spawn_y_px)
      @x = spawn_x_px
      @y = (spawn_y_px / Level::TILE_SIZE).floor * Level::TILE_SIZE
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

      if level.checkpoint_at?(@x + PLAYER_W / 2, @y + PLAYER_H / 2)
        @respawn_x, @respawn_y = @x, @y
        @checkpoint_message_until = Gosu.milliseconds + 1000
      end

      if level.collect_star_at?(@x + PLAYER_W / 2, @y + PLAYER_H / 2)
        @stars_collected += 1
      end

      if level.collect_powerup_at?(@x + PLAYER_W / 2, @y + PLAYER_H / 2)
        @double_jump_expires_at = Gosu.milliseconds + DOUBLE_JUMP_DURATION
        @has_double_jumped = false
      end

      if Gosu.milliseconds - @frame_time > 150
        @frame_index = (@frame_index + 1) % @walk_frames.size
        @frame_time = Gosu.milliseconds
      end
    end

    def draw(camera_x, camera_y, level)
      sprite =
        if !grounded?(level) && @vel_y < 0
          @jump_frame
        elsif Gosu.button_down?(Gosu::KB_LEFT) || Gosu.button_down?(Gosu::KB_RIGHT)
          @walk_frames[@frame_index]
        else
          @idle_frames.first
        end

      scale_x = @facing_left ? -1 : 1
      sprite.draw_rot(
        @x - camera_x + PLAYER_W / 2,
        @y - camera_y + PLAYER_H / 2,
        2, 0, 0.5, 0.5, scale_x, 1
      )

      if Gosu.milliseconds < @checkpoint_message_until
        font = Gosu::Font.new(40)
        font.draw_text("Checkpoint Reached", 140, 200, 10, 1, 1, Gosu::Color::YELLOW)
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
      @x < 0 ||
        @x > level.width * Level::TILE_SIZE ||
        @y > level.height * Level::TILE_SIZE
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

      new_x = @x + dx
      @x = new_x unless collides_rect?(new_x, @y, level)
    end

    def handle_vertical(level)
      @vel_y += GRAVITY unless grounded?(level)

      step = @vel_y < 0 ? -1 : 1

      @vel_y.abs.times do
        new_y = @y + step
        if collides_rect?(@x, new_y, level)
          @vel_y = 0
          break
        else
          @y = new_y
        end
      end
    end

    def grounded?(level)
      collides_rect?(@x, @y + 1, level)
    end

    def collides_rect?(new_x, new_y, level)
      ts = Level::TILE_SIZE
      left   = new_x / ts
      right  = (new_x + PLAYER_W - 1) / ts
      top    = new_y / ts
      bottom = (new_y + PLAYER_H - 1) / ts

      (top..bottom).each do |ty|
        (left..right).each do |tx|
          return true if level.solid_tile?(tx, ty)
        end
      end
      false
    end
  end
end