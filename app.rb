require 'rubygems'

require 'model'
require 'events'
require 'scene'

$width = 640
$height = 480
$highlight = 2
$frames_per_day = 8

puts "Parsing events"
events = get_events()
puts "Rendering"
s = Scene.new($width, $height)
s.play(events)
