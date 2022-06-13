#===============================================================================
#
#   Volumetric Psuedo 3D Renderer for RGSS 
#   (Designed for 1, but should work in 2, 3, and mkxp)
#     by sukoshijon
#
#   WARNING - This is inefficient
#     Using too many models at once, or using a model bigger than 48 sprites
#     tall WILL LAG YOUR GAME. Even increasing certain values to high levels will
#     significantly lower your FPS.
#
#
#
#   INSTRUCTIONS -
#    create a new Sprite3D as you would create a normal sprite except use Bitmap3D 
#    instead of Bitmap.
#    you can set the height, width, and spritesheet direction 
#    (SpriteSheetModes::Horizontal or ::Vertical) in the constructor of your 
#    Bitmap3D.
#
#===============================================================================

class Sprite3D
  attr_reader :x
  attr_reader :y
  attr_reader :z
  attr_reader :ox
  attr_reader :oy
  attr_reader :angle
  attr_reader :zoom_x
  attr_reader :zoom_y
  attr_reader :zoom_z
  attr_reader :view_angle
  attr_reader :opacity
  attr_reader :visible
  attr_reader :mirror
  attr_reader :blend_type
  attr_reader :color
  attr_reader :tone
  attr_reader :stack_mode
  attr_reader :view__mode
  attr_reader :vanishing_point
  attr_reader :unlit

  attr_reader :model
  
  def initialize(view=nil)
    # initialize all the variables
    @x = 0
    @y = 0
    @z = 0
    @ox = nil
    @oy = nil
    @angle = 0
    @zoom_x = 1
    @zoom_y = 1
    @zoom_z = 1
    @view_angle = 1
    @opacity = 255
    @viewport = view
    @visible = true
    @mirror = false
    @blend_type = 0
    @color = Color.new(0,0,0,0)
    @tone = Tone.new(0,0,0,0)
    @stack_mode = StackingModes::Up
    @view_mode = ViewModes::Orthographic
    @vanishing_point = 1
    @unlit = true
    @model = nil
    @mdl = []
  end
  
  # set the model
  def model=(mdl)
    
    @model = mdl
    
    @model.layers.times do |i|
      lighting_tone_diff = (@model.layers-i)*255/@model.layers/2
      @mdl[i] = Sprite.new(@viewport)
      @mdl[i].bitmap = @model.mdl[i]
      @mdl[i].x = @x
      @mdl[i].y = @y-i*@zoom_y*@view_angle if stack_mode == StackingModes::Up
      @mdl[i].y = @y+i*@zoom_y*@view_angle if stack_mode == StackingModes::Down
      @mdl[i].z = @z+i if stack_mode == StackingModes::Up
      @mdl[i].z = @z-i if stack_mode == StackingModes::Down
      @mdl[i].zoom_x = @zoom_x * (i.to_f/@model.layers.to_f + @vanishing_point) if @view_mode == ViewModes::Perspective
      @mdl[i].zoom_y = @zoom_y * (i.to_f/@model.layers.to_f + @vanishing_point) if @view_mode == ViewModes::Perspective
      @mdl[i].zoom_x = @zoom_x if @view_mode == ViewModes::Orthographic
      @mdl[i].zoom_y = @zoom_y if @view_mode == ViewModes::Orthographic
      @mdl[i].ox = @model.width/2 if @ox == nil
      @mdl[i].oy = @model.height/2 if @oy == nil
      @mdl[i].angle = @angle
      @mdl[i].opacity = @opacity
      @mdl[i].visible = @visible
      @mdl[i].mirror = @mirror
      @mdl[i].blend_type = @blend_type
      @mdl[i].color = @color
      @mdl[i].tone = @tone
      @mdl[i].color = Color.new(0,0,0,lighting_tone_diff.abs) if !@unlit
    end
    @ox = @mdl[0].ox if @ox == nil
    @oy = @mdl[0].oy if @oy == nil
  end
  
  def set_position(x,y,z)
    @x = x
    @y = y
    @z = z
    @mdl.length.times do |i|
      @mdl[i].x = @x
      @mdl[i].y = @y-i*@zoom_y*@view_angle if stack_mode == StackingModes::Up
      @mdl[i].y = @y+i*@zoom_y*@view_angle if stack_mode == StackingModes::Down
      @mdl[i].z = @z+i if stack_mode == StackingModes::Up
      @mdl[i].z = @z-i if stack_mode == StackingModes::Down
    end
  end

  def x=(x)
    @x = x
    @mdl.length.times do |i|
      @mdl[i].x = @x
    end
  end

  def y=(y)
    @y = y
    @mdl.length.times do |i|
      @mdl[i].y = @y-i*@zoom_y*@view_angle if stack_mode == StackingModes::Up
      @mdl[i].y = @y+i*@zoom_y*@view_angle if stack_mode == StackingModes::Down
    end
  end

  def z=(z)
    @z = z
    @mdl.length.times do |i|
      @mdl[i].z = @z+i if stack_mode == StackingModes::Up
      @mdl[i].z = @z-i if stack_mode == StackingModes::Down
    end
  end

  def ox=(ox)
    @ox=ox
    @mdl.length.times do |i|
      @mdl[i].ox = @ox
    end
  end

  def oy=(oy)
    @oy=oy
    @mdl.length.times do |i|
      @mdl[i].oy = @oy
    end
  end
  
  # angle settings
  def angle=(angle)
    @angle = angle.to_f
    @mdl.length.times do |i|
      @mdl[i].angle = @angle
    end
  end
  
  # opacity settings
  def opacity=(opacity)
    @opacity = opacity
    @mdl.length.times do |i|
      @mdl[i].opacity = opacity
    end
  end
  
  # color and tone
  def color=(color)
    @color = color
    @mdl.length.times do |i|
      @mdl[i].color = color
    end
  end
  
  def tone=(tone)
    @tone = tone
    @mdl.length.times do |i|
      @mdl[i].tone = tone
    end
  end

  def zoom_x=(zoom)
    @zoom_x = zoom
    @mdl.length.times do |i|
      @mdl[i].zoom_x = @zoom_x * (i/@model.layers.to_f + @vanishing_point) if @view_mode == ViewModes::Perspective
      @mdl[i].zoom_x = @zoom_x if @view_mode == ViewModes::Orthographic
    end
  end

  def zoom_y=(zoom)
    @zoom_y = zoom
    @mdl.length.times do |i|
      @mdl[i].zoom_y = @zoom_y * (i/@model.layers.to_f + @vanishing_point) if @view_mode == ViewModes::Perspective
      @mdl[i].zoom_y = @zoom_y if @view_mode == ViewModes::Orthographic
    end
  end

  def zoom_z=(zoom)
    @zoom_z = zoom
    @mdl.length.times do |i|
      @mdl[i].y = @y-(i*@zoom_z*@view_angle) if stack_mode == StackingModes::Up
      @mdl[i].y = @y+(i*@zoom_z*@view_angle) if stack_mode == StackingModes::Down
    end
  end
  
  def mirror=(tf)
    raise "Type Error - Argument 0 is not of type `bool`" if !tf.is_a?(TrueClass) && !tf.is_a?(FalseClass)
    @mirror = tf
    @mdl.length.times do |i|
      @mdl[i].mirror = tf
    end
  end
  
  def dispose
    @mdl.length.times do |i|
      @mdl[i].dispose
    end
    @disposed = true
  end
  
  def disposed?
    return true if @disposed
  end
  
  def flash(color, duration)
    @mdl.length.times do |i|
      @mdl[i].flash(color, duration)
    end
  end
  
  def updateFlash
    @mdl.length.times do |i|
      @mdl[i].update
    end
  end

  def stack_mode=(stm)
    @stack_mode = stm
    @mdl.length.times do |i|
      @mdl[i].y = @y-i*@zoom_z*@view_angle if stack_mode == StackingModes::Up
      @mdl[i].y = @y+i*@zoom_z*@view_angle if stack_mode == StackingModes::Down
    end
  end

  def view_angle=(angle)
    @view_angle = angle
    @mdl.length.times do |i|
      @mdl[i].y = @y-(i*@zoom_z*@view_angle) if stack_mode == StackingModes::Up
      @mdl[i].y = @y+(i*@zoom_z*@view_angle) if stack_mode == StackingModes::Down
    end
  end

  def view_mode=(view_mode)
    @view_mode = view_mode
    @mdl.length.times do |i|
      @mdl[i].zoom_x = @zoom_x * (i/@model.layers.to_f + @vanishing_point) if @view_mode == ViewModes::Perspective
      @mdl[i].zoom_y = @zoom_y * (i/@model.layers.to_f + @vanishing_point) if @view_mode == ViewModes::Perspective
      @mdl[i].zoom_x = @zoom_x if @view_mode == ViewModes::Orthographic
      @mdl[i].zoom_y = @zoom_y if @view_mode == ViewModes::Orthographic
    end
  end
  
  def vanishing_point=(point)
    @vanishing_point = point
    if @view_mode == ViewModes::Perspective
      @mdl.length.times do |i|
        @mdl[i].zoom_x = @zoom_x * (i/@model.layers.to_f + @vanishing_point)
        @mdl[i].zoom_y = @zoom_y * (i/@model.layers.to_f + @vanishing_point)
      end
    end
  end

  def unlit=(tf)
    @unlit = tf
    @mdl.length.times do |i|
      lighting_tone_diff = (@model.layers-i)*255/@model.layers/2
      @mdl[i].color = @color
      @mdl[i].color = Color.new(0,0,0,lighting_tone_diff.abs) if !@unlit
    end
  end
end

class Bitmap3D

  attr_accessor :width
  attr_accessor :height
  attr_reader :layers
  attr_reader :mdl

  def initialize(sheet,width=nil,height=nil,mode=SpriteSheetModes::Horizontal)
    @sheet = Bitmap.new(sheet)

    if width == nil
      @width = @sheet.height if mode == SpriteSheetModes::Horizontal
      @width = @sheet.width if mode == SpriteSheetModes::Vertical
    else
      @width = width
    end

    if height == nil
      @height = @sheet.height if mode == SpriteSheetModes::Horizontal
      @height = @sheet.width if mode == SpriteSheetModes::Vertical
    else
      @height = height
    end

    @layers = @sheet.width / @width if mode == SpriteSheetModes::Horizontal
    @layers = @sheet.height / @height if mode == SpriteSheetModes::Vertical
    @mdl = []

    @layers.times do |i|
      @mdl[i] = Bitmap.new(@width,@height)
      @mdl[i].blt(0,0,@sheet,Rect.new(i*@width,0,@width,@height)) if mode == SpriteSheetModes::Horizontal
      @mdl[i].blt(0,0,@sheet,Rect.new(0,(@layers-i)*@height,@width,@height)) if mode == SpriteSheetModes::Vertical
    end
  end
end

module SpriteSheetModes
  Horizontal = 0
  Vertical = 1
end

module StackingModes
  Up = 0
  Down = 1
end

module ViewModes
  Perspective = 0
  Orthographic = 1
end