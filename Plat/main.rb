require "chingu"
require_relative "states/title_state"
require_relative "states/menu_state"

class GameWindow < Chingu::Window
  def initialize
    super(1024, 768, false)
    self.caption = "Seek The Stars!"
  end

  def setup
    # Start with the title fade‑in screen
    push_game_state(TitleState)
  end
end

GameWindow.new.show