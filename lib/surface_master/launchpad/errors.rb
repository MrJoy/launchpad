module Launchpad
  # Generic launchpad error.
  class LaunchpadError < SurfaceMaster::GenericError; end

  # Error raised when <tt>x/y</tt> coordinates outside of the grid
  # or none were specified.
  class NoValidGridCoordinatesError < LaunchpadError; end

  # Error raised when wrong brightness was specified.
  class NoValidBrightnessError < LaunchpadError; end
end
