require 'rubygems'

require 'model'
require 'events'
require 'scene'

require 'config'

puts "Parsing events"
events = get_events()
puts "Rendering"
s = Scene.new($width, $height)
s.play(events)
