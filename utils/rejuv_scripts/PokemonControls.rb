module Input
  LeftMouseKey  = 1
  RightMouseKey = 2
  F3    = 23
  F4    = 24
  F5    = 25
  PAGEUP = L
  PAGEDOWN = R
  ITEMKEYS      = [Input::F5,Input::F4,Input::F3]
  ITEMKEYSNAMES = [_INTL("F5"),_INTL("F4"),_INTL("F3")]

  def self.getstate(button)
    self.pressex?(button)
  end
end

module Mouse
  module_function

  # Returns the position of the mouse relative to the game window.
  def getMousePos(catch_anywhere = false)
    return nil unless System.mouse_in_window || catch_anywhere
    return Input.mouse_x, Input.mouse_y
  end
end