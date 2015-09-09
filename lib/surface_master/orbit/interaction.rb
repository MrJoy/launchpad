module SurfaceMaster
  module Orbit
    # Higher-level interface for Numark Orbit wireless MIDI control surface.
    class Interaction < SurfaceMaster::Interaction
      def initialize(opts = nil)
        @device_class = Device
        super(opts)
      end

    protected

      def combined_types(type, _opts = nil)
        [type.to_sym]
      end

      def responses_hash
        { down:   [],
          up:     [],
          update: [],
          tilt:   [] }
      end

      def responses
        @responses ||= Hash.new { |hash, key| hash[key] = responses_hash }
      end

      # TODO: Allow catching ranges of pads...
      #
      # TODO: Allow differentiating on bank/vknob/shoulder button...
      def respond_to_action(action)
        mappings_for_action(action).each do |block|
          block.call(self, action)
        end
        nil
      rescue Exception => e # TODO: StandardException, RuntimeError, or Exception?
        logger.error "Error when responding to action #{action.inspect}: #{e.inspect}"
        raise e
      end

      def mappings_for_action(action)
        type    = action[:type].to_sym
        state   = action[:state].to_sym
        actions = []
        actions += responses[type][state]
        actions += responses[:all][state]
        actions.compact
      end

      def expand_states(state)
        case state
        when :both  then %i(down up)
        when :all   then responses_hash.keys
        else Array(state)
        end
      end
    end
  end
end
