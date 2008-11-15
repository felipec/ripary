class Vector
  attr_reader :x, :y

  def initialize(x = 0, y = 0)
    @x = x
    @y = y
  end

  def set!(v)
    @x = v.x
    @y = v.y
  end

  def length
    return Math.sqrt(@x ** 2 + @y ** 2)
  end

  def length_sqr
    return @x ** 2 + @y ** 2
  end

  def -(v)
    return Vector.new(@x - v.x, @y - v.y)
  end

  def scale(v)
    return Vector.new(@x * v, @y * v)
  end

  def add!(v)
    @x += v.x
    @y += v.y
  end

  def scale!(v)
    @x *= v
    @y *= v
  end

  def negate!
    @x = -@x
    @y = -@y
  end

  def inspect
    return "x=%.2f,y=%.2f" % [x, y]
  end

end
