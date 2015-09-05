module ControlCenter
  # This module provides logging facilities. Just include it to be able to log
  # stuff.
  module Logging
    # Returns the logger to be used by the current instance.
    #
    # Creates one if none was set.
    def logger
      @logger ||= Logger.new(nil)
    end

    # Sets the logger to be used by the current instance.
    def logger=(logger); @logger = logger; end
  end
end
