module Platformer
  class Camera
    def initialize(screen_w, screen_h)
      @screen_w = screen_w
      @screen_h = screen_h
      @x = 0
      @y = 0
    end

    def update(target_x, target_y, level_px_w, level_px_h)
      desired_x = target_x - @screen_w / 2
      desired_y = target_y - @screen_h / 2
      @x = [[desired_x, 0].max, [level_px_w - @screen_w, 0].max].min
      @y = [[desired_y, 0].max, [level_px_h - @screen_h, 0].max].min
    end

    def x; @x; end
    def y; @y; end
  end
end


