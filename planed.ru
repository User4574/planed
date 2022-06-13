#!/usr/bin/env ruby

def plane
  (('A'..'Z').to_a.sample(rand(2) + 2) +
   (0..9).to_a.sample(rand(2) + 3)).join +
  (rand(3) == 0 ? " heavy" : "")
end

def heading
  "%03d" % (rand(72) * 5)
end

def level
  rand(32) + 7
end

def altitude
  (rand(6) + 1) * 1000
end

def please
  "please #{%w(climb descend).sample} flight level #{level}"
end

def beacon
  c = %w(B C D F G H J K L M N P Q R S T V W X Z)
  v = %w(A E I O U Y)

  case rand(4)
  when 0
    c.sample + v.sample + c.sample
  when 1
    c.sample + v.sample + c.sample + v.sample + c.sample
  when 2
    c.sample + v.sample + c.sample + c.sample + v.sample
  when 3
    c.sample + c.sample + v.sample
  end
end

def digit?
  d = rand(5)
  d = "" if d.zero?
  d.to_s
end

def route
  c = %w(B C D F G H J K L M N P Q R S T V W X Z)
  v = %w(A E I O U Y)

  case rand(2)
  when 0
    c.sample + v.sample + c.sample + v.sample + c.sample + digit?
  when 1
    c.sample + v.sample + c.sample + c.sample + v.sample + digit?
  end
end

def runway
  "#{rand(36) + 1}#{%w(_ _ L L L C R R R).sample.gsub(/_/, "")}"
end

def clearance
  "cleared to " +
    case rand(6)
    when 0
      "heading #{heading}"
    when 1
      "flight level #{level}"
    when 2
      "#{altitude} feet"
    when 3
      beacon
    when 4
      "land runway #{runway}"
    when 5
      "take off runway #{runway}"
    end
end

def localizer?
  case rand(3)
  when 0
    " until established on the localizer"
  when 1..2
    ""
  end
end

def maintain
  "maintain #{altitude} feet#{localizer?}"
end

def vectors
  case rand(2)
  when 0
    "expect vectors for the #{%w(ILS RNAV).sample} runway #{runway}"
  when 1
    "join the localizer runway #{runway}"
  end
end

def proceed
  "#{%w(proceed fly).sample} direct #{beacon}"
end

def location
  %w(
      ground
      delivery
      departure
      arrival
      tower
      tracks
  ).sample
end

def frequency
  (rand(13) + 118) +
    (rand(200) / 200.0)
end

def contact
  "contact #{location} on #{frequency}"
end

def monitor
  "monitor #{frequency}"
end

def turn
  case rand(3)
  when 0
    "turn left heading #{heading}#{localizer?}"
  when 1
    "turn heading #{heading}#{localizer?}"
  when 2
    "turn right heading #{heading}#{localizer?}"
  end
end

def radar
  "radar contact"
end

def transition?
  ", #{runway} transition"
end

def star
  case rand(3)
  when 0
    "descend via #{route}"
  when 1
    "join the #{route} arrival"
  when 2
    "descend on the #{route} arrival"
  end
end

def sid
  "proceed direct #{beacon}, join the #{route} departure"
end

def sentence
  plane + " " +
    case rand(21)
    when 0
      please
    when 1
      proceed
    when 2
      contact
    when 3
      monitor
    when 4..9 
      clearance
    when 10..12
      turn
    when 13
      radar
    when 14..15
      star
    when 16..17
      sid
    when 18..19
      vectors
    when 20
      maintain
    end
end

require 'faye/websocket'

Faye::WebSocket.load_adapter('thin')

webpage = File.read("planed.html")

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)

    ws.on(:message) do |ev|
      ws.send(sentence)
    end

    ws.rack_response
  else
    [200, { 'Content-Type' => 'text/html' }, [webpage]]
  end
end

run App
