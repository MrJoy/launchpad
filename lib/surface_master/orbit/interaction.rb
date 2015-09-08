module SurfaceMaster
  module Orbit
    class Interaction < SurfaceMaster::Interaction
      def initialize(opts = nil)
        @device_class = Device
        super(opts)
      end

    private

      def respond_to_action(action)
        # type    = action[:type].to_sym
        # state   = action[:state].to_sym
        # actions = []
        # if type == :grid
        #   actions += responses[:"grid#{action[:x]}#{action[:y]}"][state]
        #   actions += responses[:"grid#{action[:x]}-"][state]
        #   actions += responses[:"grid-#{action[:y]}"][state]
        # end
        # actions += responses[type][state]
        # actions += responses[:all][state]
        # actions.compact.each {|block| block.call(self, action)}
      rescue Exception => e # TODO: StandardException, RuntimeError, or Exception?
        logger.error "Error when responding to action #{action.inspect}: #{e.inspect}"
        raise e
      end
    end
  end
end
