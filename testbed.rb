#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

# Flash:    F0h 00h 20h 29h 02h 18h 23h <LED> <Colour> F7h
# Pulse:    F0h 00h 20h 29h 02h 18h 28h <LED> <Colour> F7h
# Set all:  F0h 00h 20h 29h 02h 18h 0Eh <Colour> F7h
# Set row:  F0h 00h 20h 29h 02h 18h 0Dh <Row> <Colour> F7h
# Set col:  F0h 00h 20h 29h 02h 18h 0Ch <Column> <Colour> F7h

# By default, Launchpad MK2 will flash and pulse at 120 BPM. This can be altered by sending Launchpad MK2 F8h (248) messages (MIDI clock), which should be sent at a rate of 24 per beat. To set a tempo of 100 BPM, 2400 MIDI clock messages should be sent each minute, or with a time interval of 25ms.
# Launchpad MK2 supports tempos between 40 and 240 BPM.

# Configuration
SCALE       = 2
TIME_SCALE  = 4.0

# State
QUADRANTS = [
  [{ red: 0x2F, green: 0x00, blue: 0x00 }, { red: 0x00, green: 0x2F, blue: 0x00 }],
  [{ red: 0x00, green: 0x00, blue: 0x2F }, { red: 0x2F, green: 0x2F, blue: 0x00 }],
]
FLIPPED = [[false, false], [false, false]]
PRESSED = (0..7).map { |x| (0..7).map { |y| false } }
NOW     = [Time.now.to_f]

# Helpers
CC      = %i(up down left right session user1 user2 scene1 scene2 scene3 scene4 scene5 scene6 scene7 scene8)
GRID    = (0..7).map { |x| (0..7).map { |y| { grid: [x, y] } } }.flatten
WHITE   = { red: 0x3F, green: 0x3F, blue: 0x3F }

def clamp(val); (val > 0x3F) ? 0x3F : val; end

def base_color(x, y)
  return nil if PRESSED[x][y]
  quad_x  = x / 4
  quad_y  = 1 - (y / 4)
  quad    = QUADRANTS[quad_y][quad_x]
  s_t     = (Math.sin(NOW[0] * TIME_SCALE) * 0.5) + 0.5
  tmp     = { red:    0x00        + quad[:red] + (s_t * 0x3F).round,
              green:  (x * SCALE) + quad[:green],
              blue:   (y * SCALE) + quad[:blue] }
  if FLIPPED[quad_y][quad_x]
    carry       = tmp[:red]
    tmp[:red]   = tmp[:green]
    tmp[:green] = tmp[:blue]
    tmp[:blue]  = carry
  end
  { red:    clamp(tmp[:red]),
    green:  clamp(tmp[:green]),
    blue:   clamp(tmp[:blue]) }
end

def init_board(interaction)
  values = GRID.map do |value|
    tmp = base_color(*value[:grid])
    next unless tmp
    value.merge(tmp)
  end
  interaction.device.changes(values.compact)
end

def set_grid_rgb(interaction, red:, green:, blue: )
  values = GRID.map { |value| value.merge(red: red, green: green, blue: blue) }
  interaction.device.changes(values)
end

def goodbye(interaction)
  (0..63).step(2).each do |i|
    ii = (63 - i) - 1
    set_grid_rgb(interaction, red: ii, green: 0x00, blue: ii)
    sleep 0.01
  end
end

interaction = Launchpad::Interaction.new
interaction.response_to(:grid) do |inter, action|
  x = action[:x]
  y = action[:y]
  PRESSED[x][y] = (action[:state] == :down)
  value         = base_color(x, y) || WHITE
  value[:grid]  = [x, y]
  inter.device.change(value)
end

def flip_quad!(inter, cc, quad_x, quad_y)
  # quad                      = QUADRANTS[quad_y][quad_x]
  # QUADRANTS[quad_y][quad_x] = { red:    0x3F - quad[:red],
  #                               green:  0x3F - quad[:green],
  #                               blue:   0x3F - quad[:blue] }
  FLIPPED[quad_y][quad_x]   = !FLIPPED[quad_y][quad_x]
  if FLIPPED[quad_y][quad_x]
    color = { red: 0x1F, green: 0x1F, blue: 0x1F }
  else
    color = { red: 0x03, green: 0x03, blue: 0x03 }
  end
  inter.device.change(color.merge(cc: cc))
end


# def shift_quad!(inter, quad_x, quad_y)
#   quad                      = QUADRANTS[quad_y][quad_x]
#   QUADRANTS[quad_y][quad_x] = { red:    (quad[:red]   + 0x0D) % 0x3F,
#                                 green:  (quad[:green] + 0x11) % 0x3F,
#                                 blue:   (quad[:blue]  + 0x1F) % 0x3F }
#   init_board(inter)
# end

interaction.response_to(:scene1, :down) do |inter, action|
  flip_quad!(inter, action[:type], 0, 0)
end
interaction.response_to(:scene2, :down) do |inter, action|
  flip_quad!(inter, action[:type], 1, 0)
end
interaction.response_to(:scene3, :down) do |inter, action|
  flip_quad!(inter, action[:type], 0, 1)
end
interaction.response_to(:scene4, :down) do |inter, action|
  flip_quad!(inter, action[:type], 1, 1)
end

interaction.response_to(:mixer, :down) do |_interaction, action|
  interaction.stop
end
interaction.device.change({ red: 0x03, green: 0x00, blue: 0x00, cc: :mixer })
interaction.device.changes(%i(scene1 scene2 scene3 scene4).map { |cc| { red: 0x03, green: 0x03, blue: 0x03, cc: cc } })

init_board(interaction)
input_thread = Thread.new do
  interaction.start
end
animation_thread = Thread.new do
  loop do
    begin
      NOW[0] = Time.now.to_f
      init_board(interaction)
    rescue Exception => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
    sleep 0.01
  end
end

input_thread.join
animation_thread.terminate
goodbye(interaction)
