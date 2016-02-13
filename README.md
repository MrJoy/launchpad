# Control Center

A gem for interacting with various MIDI controllers.

This was originally forked from [launchpad](https://github.com/thomasjachmann/launchpad) but has diverged considerably:

* Abandon support for Novation Launchpad Mk 1.
* Add support for Novation Launchpad Mk 2.
* Add support for TouchOSB Bridge.
* Improve allocation efficiency to reduce pressure on garbage collector.

Over time I will be generalizing this to interact with arbitrary control surfaces.


## Supported Devices

* Novation Launchpad, Mark 2 (the one with RGB support)
* TouchOSC Bridge
    * At the moment only the `Device` interface is implemented, and you can either consume the input raw, or apply a mapping function of your own.


## Requirements

* Roger B. Dannenberg's (portmidi library)[http://sourceforge.net/projects/portmedia/]
* Jan Krutisch's (portmidi gem)[http://github.com/halfbyte/portmidi]


## Compatibility

The gem is known to be compatible with the following ruby versions:

* MRI 2.2.4


## Usage

To be written.  In the meantime, see the `examples` directory.


## Future plans

* Support for more control surfaces.
* Improve efficiency wrt memory allocations.
* Expanded support for Novation Launchpad features (blinking/pulsing, etc)
* Test suite.
* Normalize message structures across devices a bit.


## License

See LICENSE for details.
