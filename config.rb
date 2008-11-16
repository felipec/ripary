$width = 640
$height = 480
$highlight = 5
$frames_per_day = 4
$output = "/tmp/codeswarm_rgb.bin"

# you probably don't want to change this
$timeblock = (60 * 60 * 24 / $frames_per_day)

$tags = {}

class FileNode

  def config
    @life = 30
    @mass = 1.0
    @max_speed = 7.0
    @color = [255, 0, 0]
  end

end

class PersonNode

  def config
    @life = 60
    @mass = 10.0
    @max_speed = 2.0
  end

end

class Edge

  def config
    @life = 60
    @len = 25.0
  end

end

class Tag

  def config
    @life = 30
  end

end
