require 'vector'

class Base
  attr_accessor :life, :life_init
  attr_accessor :name

  def initialize
    @life_init = @life
  end

  def decay
    return if not alive?
    @life -= 1
    @life = 0 if @life < 0
  end

  def alive?
    return @life > 0
  end

  def freshen
    @life = @life_init
  end

  def liveness
    return @life.to_f / @life_init
  end

  def update
  end

end

class Node < Base
  attr_accessor :mass, :pos, :speed
  attr_reader :color

  def initialize()
    super()
    @highlight = @life_init * (1 - ($highlight.to_f) / 100)
  end

  def force_adjust(nodes)
    force = Vector.new()
    nodes.each do |b|
      next if self === b
      cur = nil
      dist = ((@pos.x - b.pos.x) ** 2) + ((@pos.y - b.pos.y) ** 2)
      if dist == 0
        # random
        p "huh"
      elsif dist < 10000
        cur = @pos - b.pos
        cur.scale!(1.0 / dist)
      end
      force.add!(cur) if cur
    end
    apply(force)
  end

  def apply(force)
    if (force.length > 0)
      @speed.add!(force.scale(@mass))
    end
  end

  def apply_speed
    if @speed.length > @max_speed
      mag = Vector.new(@speed.x / @max_speed, @speed.y / @max_speed)
      div = mag.length
      @speed.scale!(1 / div)
    end

    @pos.add!(@speed)
    @speed.scale!(0.5)
  end

  def relax(others)
    force_adjust(others)
  end

  def update
    apply_speed
    # todo constrain
  end

end

class FileNode < Node

  def initialize(name)
    @name = name
    config()
    super()
    @pos = Vector.new($width * rand, $height * rand)
    @speed = Vector.new(@mass * rand(2) - 1, @mass * rand(2) - 1)
  end

end

class PersonNode < Node
  
  def initialize(name)
    @name = name
    config()
    super()
    @pos = Vector.new($width * rand, $height * rand)
    @speed = Vector.new(@mass * rand(2) - 1, @mass * rand(2) - 1)
    @color = Cairo::Color::RGB.new(0.75, 1, 0.75).to_hsv
    @color_count = 1
  end

  def add_file(file)
    tmp = Cairo::Color::RGB.new(file.color[0] / 255.0, file.color[1] / 255.0, file.color[2] / 255.0).to_hsv
    @color.hue += ((tmp.hue - @color.hue) / @color_count)
    @color_count += 1
  end

  def relax(others)
    super(others)
    @speed.scale!(1.0 / 12) # huh?
  end

end

class Edge < Base
  attr_accessor :len
  attr_accessor :to, :from

  def initialize(from, to)
    config()
    super()
    @from = from
    @to = to
  end

  def relax(other)
    force = @to.pos - @from.pos
    distance = force.length
    delta = (@len - distance) / (distance * 3)
    delta *= liveness()
    force.scale!(delta)
    @to.apply(force)
    force.negate!
    @from.apply(force)
  end

end

class Tag < Base

  def initialize(name)
    @name = name
    config()
    super()
  end

end
