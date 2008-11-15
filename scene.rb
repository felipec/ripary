require 'cairo'

class Scene

  def initialize(width, height)
    @surface = Cairo::ImageSurface.new(Cairo::Format::RGB24, width, height)
    @out_file = File.new("/tmp/cs_out.bin", "w")
    @cr = Cairo::Context.new(@surface)
    @cr2 = Cairo::Context.new(@surface)
    @count = 0

    @file_nodes = {}
    @person_nodes = {}
    @edges = {}
  end

  def play(grouped_events)
    puts "Rendering"
    grouped_events.each_value do |events|
      process(events)
      (1..$frames_per_day).each do |f|
        update
        draw
      end
    end
  end

  def process(events)
    events.each do |e|

      # file_nodes
      name = e.filename
      file = @file_nodes[name]
      if file
        file.freshen
      else
        file = FileNode.new(name)
        @file_nodes[name] = file
      end

      # persons
      name = e.author
      person = @person_nodes[name]
      if person
        person.freshen
      else
        person = PersonNode.new(name)
        @person_nodes[name] = person
      end

      person.add_file(file)

      # edges
      edge = @edges[[file, person]]
      if edge
        edge.freshen
      else
        edge = Edge.new(file, person)
        @edges[[file, person]] = edge
      end
    end

    @living_nodes = []
    @living_people = []
    @living_edges = []

    @file_nodes.each_value do |e|
      @living_nodes << e if e.alive?
    end

    @person_nodes.each_value do |e|
      @living_people << e if e.alive?
    end

    @edges.each_value do |e|
      @living_edges << e if e.alive?
    end
  end

  def update

    @living_edges.each { |e| e.relax(@living_edges) }
=begin
    # this is too slow!
    @living_nodes.each { |e| e.relax(@living_nodes) }
=end
    @living_people.each { |e| e.relax(@living_people) }

    @living_edges.each { |e| e.update }
    @living_nodes.each { |e| e.update }
    @living_people.each { |e| e.update }

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

    @living_nodes.each do |n|
      draw_node(n);
    end
    
    @living_people.each do |n|
      draw_node(n);
    end

    puts "count: #{@count += 1}"
    # @cr.target.write_to_png("frames/%0.5i.png" % [@count += 1])
    @out_file.write(@surface.data)
  end

end
