#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "surface_master"

# Flash:    F0h 00h 20h 29h 02h 18h 23h <LED> <Colour> F7h
# Pulse:    F0h 00h 20h 29h 02h 18h 28h <LED> <Colour> F7h
# Set all:  F0h 00h 20h 29h 02h 18h 0Eh <Colour> F7h
# Set row:  F0h 00h 20h 29h 02h 18h 0Dh <Row> <Colour> F7h
# Set col:  F0h 00h 20h 29h 02h 18h 0Ch <Column> <Colour> F7h

# Configuration
SCALE       = 2
TIME_SCALE  = 4.0

# State
QUADRANTS = [
  [{ red: 0x2F, green: 0x00, blue: 0x00 }, { red: 0x00, green: 0x2F, blue: 0x00 }],
  [{ red: 0x00, green: 0x00, blue: 0x2F }, { red: 0x2F, green: 0x2F, blue: 0x00 }],
]
FLIPPED = [[false, false], [false, false]]
PRESSED = (0..7).map { |_x| (0..7).map { |_y| false } }
NOW     = [Time.now.to_f]

# Helpers
CC      = %i(up down left right session user1 user2 scene1 scene2 scene3 scene4 scene5 scene6 scene7
             scene8)
GRID    = (0..7).map { |x| (0..7).map { |y| { grid: [x, y] } } }.flatten
WHITE   = { red: 0x3F, green: 0x3F, blue: 0x3F }
BLACK   = { red: 0x00, green: 0x00, blue: 0x00 }

def clamp(val); (val > 0x3F) ? 0x3F : val; end

def quad_for(x, y)
  quad_x  = x / 4
  quad_y  = 1 - (y / 4)
  [QUADRANTS[quad_y][quad_x], FLIPPED[quad_y][quad_x]]
end

def positional_color(x, y)
  { red:   0x00,
    green: (x * SCALE),
    blue:  (y * SCALE) }
end

def temporal_color(_x, _y)
  s_t = (Math.sin(NOW[0] * TIME_SCALE) * 0.5) + 0.5
  { red:   (s_t * 0x3F).round,
    green: 0x00,
    blue:  0x00 }
end

def clamp_color(color)
  { red:   clamp(color[:red]),
    green: clamp(color[:green]),
    blue:  clamp(color[:blue]) }
end

def apply_flip!(flipped, color)
  return unless flipped
  carry         = color[:red]
  color[:red]   = color[:green]
  color[:green] = color[:blue]
  color[:blue]  = carry
end

def add_colors(*colors)
  result = {}
  %i(red green blue).each do |component|
    result[component] = colors.inject(0) { |a, e| a + e[component] }
  end
  result
end

def base_color(x, y)
  return nil if PRESSED[x][y]
  quad, flipped = quad_for(x, y)
  p_color       = positional_color(x, y)
  t_color       = temporal_color(x, y)
  tmp           = add_colors(quad, p_color, t_color)
  apply_flip!(flipped, tmp)

  clamp_color(tmp)
end

def init_board(interaction)
  values = GRID.map do |value|
    tmp = base_color(*value[:grid])
    next unless tmp
    value.merge(tmp)
  end
  interaction.changes(values.compact)
end

def set_grid_rgb(interaction, red:, green:, blue:)
  values = GRID.map { |value| value.merge(red: red, green: green, blue: blue) }
  interaction.changes(values)
end

def goodbye(interaction)
  buttons_off(interaction)
  (0..63).step(2).each do |i|
    ii = (63 - i) - 1
    set_grid_rgb(interaction, red: ii, green: 0x00, blue: ii)
    sleep 0.01
  end
  interaction.close
end

def buttons_off(interaction)
  interaction.changes([BLACK.merge(cc: :mixer),
                       BLACK.merge(cc: :scene1),
                       BLACK.merge(cc: :scene2),
                       BLACK.merge(cc: :scene3),
                       BLACK.merge(cc: :scene4)])
end

SurfaceMaster.init!
interaction = SurfaceMaster::Launchpad::Interaction.new
interaction.response_to(:grid) do |inter, action|
  x = action[:x]
  y = action[:y]
  PRESSED[x][y] = (action[:state] == :down)
  value         = base_color(x, y) || WHITE
  value[:grid]  = [x, y]
  inter.change(value)
end

def flip_quad!(inter, cc, quad_x, quad_y)
  FLIPPED[quad_y][quad_x] = !FLIPPED[quad_y][quad_x]
  if FLIPPED[quad_y][quad_x]
    color = { red: 0x1F, green: 0x1F, blue: 0x1F }
  else
    color = { red: 0x03, green: 0x03, blue: 0x03 }
  end
  inter.change(color.merge(cc: cc))
end

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

interaction.response_to(:mixer, :down) do |_interaction, _action|
  interaction.stop
end
interaction.change(red: 0x03, green: 0x00, blue: 0x00, cc: :mixer)
BTN_COL = { red: 0x03, green: 0x03, blue: 0x03, cc: cc }
interaction.changes(%i(scene1 scene2 scene3 scene4).map { |cc| BTN_COL.merge(cc: cc) })

init_board(interaction)
input_thread = Thread.new do
  interaction.start
end
animation_thread = Thread.new do
  loop do
    begin
      NOW[0] = Time.now.to_f
      init_board(interaction)
    rescue StandardError => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
    sleep 0.01
  end
end

input_thread.join
animation_thread.terminate
goodbye(interaction)
