require "chingu"
require_relative "states/menu_state"

class GameWindow < Chingu::Window
  def initialize
    super(640, 480, false)
    self.caption = "Platformer"
  end

  def setup
    # Start with the menu state
    push_game_state(MenuState)
  end
end

GameWindow.new.show
