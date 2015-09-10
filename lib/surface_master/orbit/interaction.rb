module SurfaceMaster
  module Orbit
    # Higher-level interface for Numark Orbit wireless MIDI control surface.
    class Interaction < SurfaceMaster::Interaction
      def initialize(opts = nil)
        @device_class = Device
        super(opts)
      end

    protected

      def combined_types(type, opts = nil)
        tmp = case type
              when :shoulder
                [:"#{type}-#{opts[:button]}"]
              when :accelerometer
                [:"#{type}-#{opts[:axis]}"]
              when :vknob
                knobs = opts[:vknob].nil? ? (1..4).to_a : [opts[:vknob]]
                banks = opts[:bank].nil? ? (1..4).to_a : [opts[:bank]]

                knobs.product(banks).map { |k, b| :"#{type}-#{k}-#{b}" }
              when :vknobs, :banks
                buttons = opts[:index].nil? ? (1..4).to_a : [opts[:index]]

                buttons.map { |b| [:"#{type}-#{b}"] }
              when :pad
                banks   = opts[:bank].nil? ? (1..4).to_a : [opts[:bank]]
                buttons = opts[:button].nil? ? (1..16).to_a : [opts[:button]]

                buttons.product(banks).map { |p, b| :"#{type}-#{p}-#{b}" }
              else
                [type]
              end
        tmp.flatten.compact
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
        combined_types  = combined_types(action[:type].to_sym, action[:control])
        state           = action[:state].to_sym
        actions         = []
        actions        += combined_types.map { |ct| responses[ct][state] }
        actions        += responses[:all][state]
        actions.flatten.compact
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
