require 'xml/libxml'

class Event
  attr_reader :date, :author, :filename

  def initialize(date, author, filename)
    @date = date
    @author = author
    @filename = filename
  end
  
end

class EventGroup
  attr_reader :id, :events

  def initialize(id)
    @id = id
    @events = []
  end

  def <<(event)
    @events << event
  end

end

def get_events
  events = []

  doc = XML::Document.file("events.xml")
  doc.find("//event").each do |e|
    events << Event.new(Time.at(e['date'].to_i / 1000),
                        e['author'], e['filename'])
  end

  sorted_events = []
  hashed_events = {}

  events.each do |e|
    id = e.date.to_i / (60 * 60 * 24 / $frames_per_day)
    # puts "%d => %d" % [e.date.to_i, id]
    group = hashed_events[id]
    if not group
      group = EventGroup.new(id)
      hashed_events[id] = group
      sorted_events << group
    end
    group << e
  end

  return sorted_events
end
