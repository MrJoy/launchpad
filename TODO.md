# TODO

## Tasks

1. Come up with 0-based grid mapping for Numark Orbit.
1. Can we rebuild `portmidi with a different value for `PM_DEFAULT_SYSEX_BUFFER_SIZE`?  Does it help with talking to the Numark Orbit?
1. Does [rtmidi](https://github.com/adamjmurray/ruby-rtmidi) work better for us?
1. Can we use TouchOSC for the remote input via [osc-ruby](https://github.com/aberant/osc-ruby), [osc](https://rubygems.org/gems/osc), or [osc-access](https://github.com/arirusso/osc-access)?
1. Can we encapsulate input/output buffering/rate limiting into a thread-per-device?
1. Can we mix-and-match `Portmidi` and `UniMIDI` to allow using `UniMIDI` for writing to the Numark Orbit, and `Portmidi` for everything else?
1. Report issue with large sysex messages apparently being truncated to [portmidi](https://github.com/halfbyte/portmidi) project.
1. Possibly use [midi-instrument](https://github.com/arirusso/midi-instrument) for a more coherent way of mapping inputs?
1. ~~Report overflow issue / lack of backpressure to `UniMIDI` project.~~


## Resources

### For Audio Input

* https://github.com/nagachika/ruby-coreaudio
* https://github.com/bfoz/audio-ruby
* https://github.com/PRX/audio_monster
* https://github.com/arirusso/diamond

### For Simulation

https://github.com/jwhayman/rSynthesize
https://github.com/evant/oscillo

### For Overall Code Structure

https://github.com/ruby-concurrency/concurrent-ruby
https://github.com/hamstergem/hamster
