# Changes

## v0.4.1

* Add a simple driver for the TouchOSC Bridge.


## v0.4.0

* Jettison threaded input handling.
* More Numark Orbit handling (output is still a problem).


## v0.3.0

* __BREAKING CHANGE__: Change Orbit interface to more closely follow conventions established with Novation Launchpad driver.
* Add preliminary `Interaction` class for Numark Orbit.
    * See `examples/orbit_interaction.rb`.
* Fix exclusive binding in `Interaction` to not nuke coarser bindings entirely.
* Rename `examples/orbit_testbed.rb` to `examples/orbit_device.rb`.
* Rename `examples/monitor.rb` to `examples/system_monitor.rb`.
* Rename `examples/launchpad_testbed.rb` to `examples/launchpad_playground.rb`.


## v0.2.1

* Missed a file rename.
* Remove some broken/not-quite-supported, and no longer particurly useful features from Novation Launchpad support.  (Specifically, column-wise/row-wise/board-wise changing of lights in paletted mode.)
* Fix test suite.
* Break apart a lot of complexity.
* Apply style guide (mostly).


## v0.2.0

* Initial release, based on [launchpad](https://github.com/thomasjachmann/launchpad) gem.
* Almost full support for Novation Launchpad Mark 2 (the one with RGB LEDs), missing flashing/pulsing of lights, etc.
* Partial support for Numark Orbit.
