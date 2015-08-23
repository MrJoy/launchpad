# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "launchpad/version"

Gem::Specification.new do |s|
  s.name        = "mrjoy-launchpad"
  s.version     = Launchpad::VERSION
  s.authors     = ["Jon Frisby", "Thomas Jachmann"]
  s.email       = ["jfrisby@mrjoy.com", "self@thomasjachmann.com"]
  s.homepage    = "https://github.com/MrJoy/launchpad"
  s.summary     = %q{A gem for accessing Novation's LaunchPad programmatically and easily.}
  s.description = %q{This gem provides an interface to access Novation's LaunchPad programmatically. LEDs can be lighted and button presses can be evaluated using launchpad's MIDI input/output.}

  s.required_ruby_version = ">= 2.2.0"

  s.add_dependency "portmidi", ">= 0.0.6"
  s.add_dependency "ffi"
  s.add_development_dependency "rake"
  if RUBY_VERSION < "1.9"
    s.add_development_dependency "minitest"
    # s.add_development_dependency "ruby-debug"
  else
    s.add_development_dependency "minitest-reporters"
    # s.add_development_dependency "debugger"
  end
  s.add_development_dependency "mocha"

  # s.has_rdoc = true

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
