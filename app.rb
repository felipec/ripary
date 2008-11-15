require 'rubygems'

require 'model'
require 'events'
require 'scene'

$width = 640
$height = 480
$highlight = 5
$frames_per_day = 8

s = Scene.new($width, $height)
s.play(get_events())
