require "gosu"

module Platformer
  class Level
    TILE_SIZE = 32
    attr_reader :width, :height, :background, :victory_tile, :total_stars_initial

    def initialize(rows, background)
      @rows = rows.map(&:dup)
      @height = @rows.size
      @width = @rows.first.size
      @background = background
      @victory_tile = find_tile('V')
      @respawn_timers = {}
      @total_stars_initial = @rows.sum { |row| row.count('*') }
      load_sprites
    end

    def self.load(path)
      rows = File.readlines(path, chomp: true).reject { |line| line.strip.empty? }
      bg_line = rows.first&.start_with?("BG:") ? rows.shift : nil
      background = bg_line ? bg_line.split(":")[1].strip : nil
      new(rows, background)
    end

    def solid_tile?(tx, ty)
      return false if tx < 0 || ty < 0 || tx >= @width || ty >= @height
      @wall_sprites.key?(@rows[ty][tx])
    end

    def find_tile(char)
      @rows.each_with_index do |row, y|
        x = row.index(char)
        return [x, y] if x
      end
      nil
    end

    def spawn_tile
      find_tile('S')
    end

    def victory_at?(px, py)
      return false unless @victory_tile
      vx, vy = @victory_tile
      rect_overlap?(px, py, TILE_SIZE, TILE_SIZE,
                    vx * TILE_SIZE, vy * TILE_SIZE, TILE_SIZE, TILE_SIZE)
    end

    def checkpoint_at?(px, py)
      tx = px / TILE_SIZE
      ty = py / TILE_SIZE
      return false if ty < 0 || ty >= @rows.size || tx < 0 || tx >= @rows[ty].size
      @rows[ty][tx] == 'c'
    end

    def collect_powerup_at?(px, py)
      tx = px / TILE_SIZE
      ty = py / TILE_SIZE
      return false if ty < 0 || ty >= @rows.size || tx < 0 || tx >= @rows[ty].size

      if @rows[ty][tx] == 'd'
        @rows[ty][tx] = '.'
        @respawn_timers[[tx, ty]] = Gosu.milliseconds + 5_000
        return true
      end
      false
    end

    def update
      now = Gosu.milliseconds
      @respawn_timers.each do |pos, time|
        if now >= time
          tx, ty = pos
          @rows[ty][tx] = 'd'
          @respawn_timers.delete(pos)
        end
      end
    end

    def collect_star_at?(px, py)
      tx = px / TILE_SIZE
      ty = py / TILE_SIZE
      return false if ty < 0 || ty >= @rows.size || tx < 0 || tx >= @rows[ty].size

      if @rows[ty][tx] == '*'
        @rows[ty][tx] = '.'
        return true
      end
      false
    end

    def total_stars
      @rows.sum { |row| row.count('*') }
    end

    def draw_background(screen_w, screen_h)
      if @background
        @bg_image ||= Gosu::Image.new("assets/backgrounds/#{@background}", tileable: true)
        @bg_image.draw(0, 0, 0,
                       screen_w.to_f / @bg_image.width,
                       screen_h.to_f / @bg_image.height)
      else
        Gosu.draw_rect(0, 0, screen_w, screen_h, Gosu::Color::CYAN)
      end
    end

    def draw(camera_x, camera_y, screen_w, screen_h)
      first_tx = [camera_x / TILE_SIZE, 0].max
      first_ty = [camera_y / TILE_SIZE, 0].max
      last_tx  = [(camera_x + screen_w) / TILE_SIZE + 1, @width].min
      last_ty  = [(camera_y + screen_h) / TILE_SIZE + 1, @height].min

      (first_ty...last_ty).each do |ty|
        (first_tx...last_tx).each do |tx|
          tile = @rows[ty][tx]
          x = tx * TILE_SIZE - camera_x
          y = ty * TILE_SIZE - camera_y

          if @wall_sprites.key?(tile)
            @wall_sprites[tile].draw(x, y, 1)
          elsif @tile_sprites.key?(tile)
            @tile_sprites[tile].draw(x, y, 1)
          end
        end
      end
    end

    private

def load_sprites
  @wall_sprites ||= Dir["assets/walls/*.png"].each_with_object({}) do |path, hash|
    filename = File.basename(path, ".png")   # "wall10"
    index_str = filename.sub("wall", "")     # "", "1", "10"

    # Special case: wall.png → '#'
    if index_str == ""
      key = "#"
    else
      index = index_str.to_i

      key =
        if index <= 9
          index.to_s                      # "1".."9"
        else
          (index - 10 + 'A'.ord).chr      # 10→A, 11→B, 12→C...
        end
    end

    hash[key] = Gosu::Image.new(path)
  end

  @tile_sprites ||= {
    'V' => Gosu::Image.new("assets/victory.png"),
    'c' => Gosu::Image.new("assets/checkpoint.png"),
    'd' => Gosu::Image.new("assets/double_jump.png"),
    '*' => Gosu::Image.new("assets/star.png")
  }
end

    def rect_overlap?(x1, y1, w1, h1, x2, y2, w2, h2)
      !(x1 + w1 <= x2 || x1 >= x2 + w2 ||
        y1 + h1 <= y2 || y1 >= y2 + h2)
    end
  end
end