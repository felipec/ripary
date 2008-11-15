require 'rubygems'
require 'cairo'
require 'xml/libxml'

$width = 640
$height = 480
$highlight = 5
$frames_per_day = 8

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

class Drawable
  attr_accessor :life, :life_init
  attr_accessor :name

  def initialize(life_init, life_decrement)
    @life = @life_init = life_init
    @life_decrement = life_decrement
  end

  def decay
    return if not alive?
    @life += @life_decrement
    @life = 0 if @life < 0
  end

  def alive?
    return @life > 0
  end

  def freshen
    @life = @life_init
  end

end

class Node < Drawable
  attr_accessor :mass, :pos, :speed
  attr_reader :color

  def initialize(life_init, life_decrement)
    super(life_init, life_decrement)
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

  def hi?
    return @life >= @highlight
  end

  def liveness
    return @life.to_f / @life_init
  end

end

class FileNode < Node

  def initialize(name)
    super(200, -2)
    @name = name
    @touches = 1
    @mass = 1.0
    @max_speed = 7.0
    @pos = Vector.new($width * rand, $height * rand)
    @speed = Vector.new(@mass * rand(2) - 1, @mass * rand(2) - 1)
    @max_touches = 0
    case name
    when /\/Documentation\/.*/
      @color = [255, 255, 0]
    when /.*\.[ch]/
      @color = [0, 0, 255]
    when /.*\.sh/
      @color = [0, 255, 0]
    when /.*\.py/
      @color = [0, 255, 0]
    when /.*\.perl/
      @color = [0, 255, 0]
    when /.*\.tcl/
      @color = [255, 0, 255]
    else
      @color = [255, 0, 0]
    end
  end

  def freshen
    super()
    @touches += 1
    if @touches > @max_touches
      @max_touches = @touches
    end
  end

end

class PersonNode < Node
  
  def initialize(name)
    super(255, -1)
    @name = name
    @touches = 1
    @mass = 10.0
    @max_speed = 2.0
    @pos = Vector.new($width * rand, $height * rand)
    @speed = Vector.new(@mass * rand(2) - 1, @mass * rand(2) - 1)
    @color = [0, 0, 0]
    @color_count = 0
  end

  def freshen
    super()
    @touches += 1
    # @mass += 0.1 # todo: is this ok?
  end

  def add_file(file)
    @color_count += 1
    (0..2).each { |i| @color[i] += file.color[i].to_f / @color_count }
  end

end

class Edge < Drawable
  attr_accessor :len
  attr_accessor :to, :from

  def initialize(from, to)
    super(250, -2)
    @from = from
    @to = to
    @len = 25.0
  end

end

def relax_edge(e)
  force = e.to.pos - e.from.pos
  distance = force.length
  delta = (e.len - distance) / (distance * 3)
  delta *= e.life.to_f / e.life_init
  force.scale!(delta)
  e.to.apply(force)
  force.negate!
  e.from.apply(force)
end

def relax_node(node)
  node.force_adjust($living_nodes)
end

def relax_person(node)
  node.force_adjust($living_people)
  node.speed.scale!(1.0 / 12)
end

class Event
  attr_reader :date, :author, :filename

  def initialize(date, author, filename)
    @date = date
    @author = author
    @filename = filename
  end
  
end

def day_h(num)
  return Time.at(num * 60 * 60 * 24)
end

def process(events)
  events.each do |e|
    # p e.date

    # file_nodes
    name = e.filename
    file = $file_nodes[name]
    if file
      file.freshen
    else
      file = FileNode.new(name)
      $file_nodes[name] = file
    end

    # persons
    name = e.author
    person = $person_nodes[name]
    if person
      person.freshen
    else
      person = PersonNode.new(name)
      $person_nodes[name] = person
    end

    person.add_file(file)

    # edges
    edge = $edges[[file, person]]
    if edge
      edge.freshen
    else
      edge = Edge.new(file, person)
      $edges[[file, person]] = edge
    end
  end

  $living_nodes = []
  $living_people = []
  $living_edges = []

  $file_nodes.each_value do |e|
    $living_nodes << e if e.alive?
  end

  $person_nodes.each_value do |e|
    $living_people << e if e.alive?
  end

  $edges.each_value do |e|
    $living_edges << e if e.alive?
  end
end

def update

  $living_edges.each do |e|
    relax_edge(e)
  end

  # this is too slow!
  # puts "ln=#{$living_nodes.length}"
  $living_nodes.each do |e|
    relax_node(e)
  end

  # puts "lp=#{$living_people.length}"
  $living_people.each do |e|
    relax_person(e)
  end

  $living_edges.each do |e|
    e.decay
  end

  $living_nodes.each do |e|
    e.apply_speed
    # todo constrain
    e.decay
  end

  $living_people.each do |e|
    e.apply_speed
    # todo constrain
    e.decay
  end

end

class Scene

  def initialize(width, height)
    @surface = Cairo::ImageSurface.new(Cairo::Format::RGB24, width, height)
    @out_file = File.new("/tmp/cs_out.bin", "w")
    @cr = Cairo::Context.new(@surface)
    @cr2 = Cairo::Context.new(@surface)
    @count = 0
  end

  def draw_node(node)
    x = node.pos.x
    y = node.pos.y
    size = 2
    case node
    when PersonNode
      if node.hi?
        @cr2.set_source_color(:white)
        @cr2.select_font_face("Liberation Mono", Cairo::FONT_SLANT_NORMAL, Cairo::FONT_WEIGHT_BOLD)
        @cr2.set_font_size(14)
      else
        @cr2.set_source_rgba(node.color[0] / 255, node.color[1] / 255, node.color[2] / 255,
                             node.liveness)
        @cr2.select_font_face("Liberation Mono", Cairo::FONT_SLANT_NORMAL, Cairo::FONT_WEIGHT_NORMAL)
        @cr2.set_font_size(10)
      end

      extents = @cr2.text_extents(node.name)
      @cr2.move_to(x - extents.width / 2 + 0.5, y + extents.height / 2 + 0.5)
      @cr2.show_text(node.name)
    when FileNode
      if node.hi?
        @cr.set_source_color(:white)
        @cr.arc(x + 0.5, y + 0.5, size + 2, 0, 2 * Math::PI)
        @cr.set_line_width(0.25)
        @cr.stroke
      else
        @cr.set_source_rgba(node.color[0] / 255, node.color[1] / 255, node.color[2] / 255,
                            node.liveness)
      end
      @cr.arc(x + 0.5, y + 0.5, size, 0, 2 * Math::PI)
      @cr.fill
    end
  end

  def draw
    # fill background with black
    @cr.set_source_color(:black)
    @cr.paint

    $living_nodes.each do |n|
      draw_node(n);
    end
    
    $living_people.each do |n|
      draw_node(n);
    end

    puts "count: #{@count += 1}"
    # @cr.target.write_to_png("frames/%0.5i.png" % [@count += 1])
    @out_file.write(@surface.data)
  end

end

$events = []
$file_nodes = {}
$person_nodes = {}
$edges = {}

puts "Parsing events"
doc = XML::Document.file("events.xml")
doc.find("//event").each do |e|
  $events << Event.new(Time.at(e['date'].to_i / 1000),
                       e['author'], e['filename'])
end

puts "Organizing events"
$sorted_events = {}

$events.each do |e|
  id = e.date.to_i / (60 * 60 * 24 / $frames_per_day)
  group = $sorted_events[id] ||= []
  group << e
end

puts "Rendering"
s = Scene.new($width, $height)
$sorted_events.each_value do |events|
  process(events)
  (1..$frames_per_day).each do |f|
    update
    s.draw
  end
end
