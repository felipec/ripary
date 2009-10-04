require 'config'

class FileNode

  def config
    @life = 30
    @mass = 1.0
    @max_speed = 7.0
    case @name
    when /\/Documentation\/.*/
      @color = [255, 255, 0]
    when /\/kernel\/.*/
      @color = [0, 0, 255]
    when /\/lib\/.*/
      @color = [0, 0, 255]
    when /\/arch\/.*/
      @color = [255, 0, 255]
    when /\/drivers\/.*/
      @color = [0, 255, 255]
    when /.*\.[ch]/
      @color = [0, 255, 0]
    else
      @color = [255, 0, 0]
    end
  end

end
