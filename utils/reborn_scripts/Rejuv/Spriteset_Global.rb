class Spriteset_Global
  @@viewport2 = Viewport.new(0,0,Graphics.width,Graphics.height)
  @@viewport2.z = 200

  def initialize
    @playersprite = Sprite_Character.new(Spriteset_Map.viewport,$game_player)
    @picture_sprites = []
    for i in 1..50
      @picture_sprites.push(Sprite_Picture.new(@@viewport2,$game_screen.pictures[i]))
    end
    @timer_sprite = Sprite_Timer.new
    update
  end

  def dispose
    @playersprite.dispose
    for sprite in @picture_sprites
      sprite.dispose
    end
    @timer_sprite.dispose
    @playersprite = nil
    @picture_sprites.clear
    @timer_sprite = nil
  end

  def update
    @playersprite.update
    for sprite in @picture_sprites
      sprite.update
    end
    @timer_sprite.update
  end
end