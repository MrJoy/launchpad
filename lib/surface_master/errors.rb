module SurfaceMaster
  # Unclassified error.
  class GenericError < StandardError; end

  # Error raised when the MIDI device specified doesn't exist.
  class NoSuchDeviceError < GenericError; end

  # Error raised when the MIDI device specified is busy.
  class DeviceBusyError < GenericError; end

  # Error raised when an input has been requested, although device has been initialized without
  # input.
  class NoInputAllowedError < GenericError; end

  # Error raised when an output has been requested, although device has been initialized without
  # output.
  class NoOutputAllowedError < GenericError; end

  # Error raised when anything fails while communicating with a device.
  class CommunicationError < GenericError
    attr_accessor :source
    def initialize(e)
      super(e.portmidi_error)
      self.source = e
    end
  end
end
