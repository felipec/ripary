require 'xml/libxml'

class Event
  attr_reader :date, :author, :filename

  def initialize(date, author, filename)
    @date = date
    @author = author
    @filename = filename
  end
  
end

def get_events
  events = []

  puts "Parsing events"
  doc = XML::Document.file("events.xml")
  doc.find("//event").each do |e|
    events << Event.new(Time.at(e['date'].to_i / 1000),
                        e['author'], e['filename'])
  end

  puts "Organizing events"
  sorted_events = {}

  events.each do |e|
    id = e.date.to_i / (60 * 60 * 24 / $frames_per_day)
    group = sorted_events[id] ||= []
    group << e
  end

  return sorted_events
end
