# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "surface_master/version"

Gem::Specification.new do |s|
  s.name        = "surface_master"
  s.version     = SurfaceMaster::VERSION
  s.authors     = ["Jon Frisby"]
  s.email       = ["jfrisby@mrjoy.com"]
  s.homepage    = "https://github.com/MrJoy/surface_master"
  s.summary     = "A gem for accessing various MIDI control surfaces programmatically."
  s.description = "This gem provides an interface to access Novation's LaunchPad Mark 2, and"\
    " Numark's Orbit programmatically. LEDs can be lit and button presses can be read."
  # TODO: Update docs to give credit to Thomas Jachmann (self@thomasjachmann.com) for his
  # TODO: `launchpad` gem.

  s.required_ruby_version = ">= 2.2.0"

  s.add_dependency "portmidi", ">= 0.0.6"
  s.add_dependency "ffi"

  # s.has_rdoc = true

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
