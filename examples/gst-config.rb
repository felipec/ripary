require 'config'

$width = 640
$height = 480
$highlight = 5
$frames_per_day = 2

# you probably don't want to change this
$timeblock = (60 * 60 * 24 / $frames_per_day)

class FileNode

  def config
    @life = 60
    @mass = 1.0
    @max_speed = 7.0
    case @name
    when /\/docs\/.*/
      @color = [255, 255, 0]
    when /\/gst\/.*/
      @color = [0, 0, 255]
    when /\/(libs|plugins)\/.*/ # almost core
      @color = [128, 0, 255]
    when /\/(scripts|tests|tools)\/.*/
      @color = [0, 255, 0]
    when /\/(po|win32)\/.*/ # special needs
      @color = [255, 0, 255]
    else
      @color = [255, 0, 0]
    end
  end

end
