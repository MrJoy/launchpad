# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "control_center/version"

Gem::Specification.new do |s|
  s.name        = "control_center"
  s.version     = ControlCenter::VERSION
  s.authors     = ["Jon Frisby"]
  s.email       = ["jfrisby@mrjoy.com"]
  s.homepage    = "https://github.com/MrJoy/control_center"
  s.summary     = %q{A gem for accessing various MIDI control surfaces programmatically.}
  s.description = %q{This gem provides an interface to access Novation's LaunchPad, and Numark's Orbit programmatically. LEDs can be lit and button presses can be read.}
  # TODO: Update docs to give credit to Thomas Jachmann (self@thomasjachmann.com) for his `launchpad` gem.

  s.required_ruby_version = ">= 2.2.0"

  s.add_dependency "portmidi", ">= 0.0.6"
  s.add_dependency "ffi"

  # s.has_rdoc = true

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
