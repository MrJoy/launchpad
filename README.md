# Control Center

This gem provides Ruby interfaces for programmatically interacting with various MIDI controllers.

Where appropriate this includes setting LEDs and responding to input events.


## Supported Devices

* Novation Launchpad, Mark 2 (the one with RGB support)
* Numark Orbit
    * At present you need to use the Numark Orbit Editor to send a specific mapping to the device, and setting of LEDs doesn't work.


## Requirements

* Roger B. Dannenberg's (portmidi library)[http://sourceforge.net/projects/portmedia/]
* Jan Krutisch's (portmidi gem)[http://github.com/halfbyte/portmidi]


## Compatibility

The gem is known to be compatible with the following ruby versions:

* MRI 2.2.3


## Usage

To be written.  In the meantime, see the examples directory.


## Future plans

* Support for more control surfaces.
* Improve efficiency wrt memory allocations.
* Support for setting up Numark Orbit button mappings.
* Support for setting LEDs on Numark Orbit.
* Expanded support for Novation Launchpad features (blinking/pulsing, etc)


## License

See LICENSE for details.
