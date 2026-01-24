# enemy.rb
require "chingu"

TILE_SIZE = 32

class Enemy < Chingu::GameObject
  attr_reader :kind

  def initialize(x:, y:, kind:, **options)
    @kind = kind.to_sym
    super(x: x, y: y, **options)

    self.zorder = 50
    setup_graphics
    setup_behavior
  end

  #
  # Load correct PNG based on enemy type
  #
  def setup_graphics
    case @kind
    when :npc
      @image = Gosu::Image.new("assets/enemys/npc.png")
    when :spike
      @image = Gosu::Image.new("assets/enemys/spike.png")
    when :turret
      @image = Gosu::Image.new("assets/enemys/turret.png")
    else
      @image = Gosu::Image.new("assets/enemys/npc.png")
    end
  end

  #
  # Behavior setup
  #
  def setup_behavior
    case @kind
    when :npc
      @vx = 1.0
      @walk_range = 64
      @origin_x = x
    when :spike
      # static hazard
    when :turret
      @fire_cooldown = 0
      @fire_interval = 90
    end
  end

  def update
    case @kind
    when :npc
      update_npc
    when :turret
      update_turret
    end
  end

  def update_npc
    self.x += @vx
    if (x - @origin_x).abs > @walk_range
      @vx = -@vx
    end
  end

  def update_turret
    @fire_cooldown -= 1 if @fire_cooldown > 0
    if @fire_cooldown <= 0
      fire_bullet
      @fire_cooldown = @fire_interval
    end
  end

  def fire_bullet
    Bullet.create(
      x: x + 16,
      y: y + 8,
      direction: -1
    )
  end

  def draw
    @image.draw(x, y - @image.height, zorder)
  end

  #
  # Simple bounding box for collisions
  #
  def bbox
    [x, y - @image.height, x + @image.width, y]
  end
end


#
# Bullet class
#
class Bullet < Chingu::GameObject
  SPEED = 4

  def initialize(x:, y:, direction:, **options)
    @direction = direction
    super(x: x, y: y, **options)

    self.zorder = 60
    @image = Gosu::Image.new("assets/enemys/bullet.png")
  end

  def update
    self.x += SPEED * @direction
    destroy if off_screen?
  end

  def off_screen?
    x < -32 || x > window.width + 32
  end

  def draw
    @image.draw(x, y, zorder)
  end

  def bbox
    [x, y, x + @image.width, y + @image.height]
  end
end


#
# Factory for spawning enemies from map characters
#
module EnemyFactory
  def self.from_char(char, col, row)
    kind = case char
           when "N" then :npc
           when "S" then :spike
           when "T" then :turret
           else
             return nil
           end

    px = col * TILE_SIZE
    py = (row + 1) * TILE_SIZE

    Enemy.create(x: px, y: py, kind: kind)
  end
end