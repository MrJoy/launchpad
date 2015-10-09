module SurfaceMaster
  module Orbit
    # Higher-level interface for Numark Orbit wireless MIDI control surface.
    class Interaction < SurfaceMaster::Interaction
      def initialize(opts = nil)
        @device_class = Device
        super(opts)
      end

    protected

      def grid_range(range)
        return [0..3] if range.nil?
        Array(range).flatten.map do |pos|
          pos.respond_to?(:to_a) ? pos.to_a : pos
        end.flatten.uniq
      end

      def combined_types(pos, opts = nil)
        tmp = case pos
              when Array
                case pos[0]
                when :vknob
                  banks = pos[1].nil? ? [0..3] : [pos[1]]
                  knobs = pos[2].nil? ? [0..3] : [pos[2]]

                  expand(knobs).product(expand(banks)).map { |k, b| :"#{type}-#{k}-#{b}" }
                when :vknobs, :banks
                  buttons = pos[1].nil? ? [0..3] : [pos[1]]

                  expand(buttons).map { |b| [:"#{type}-#{b}"] }
                when :shoulder, :accelerometer
                  [:"#{pos[0]}-#{pos[1]}"]
                else
                  banks = expand(opts[:bank] || [0..3])
                  x     = expand(grid_range(opts[:x]))
                  y     = expand(grid_range(opts[:y]))
                  # return [:grid] if x.nil? && y.nil?  # whole grid
                  x.product(y).product(banks).map { |xx, (yy, b)| :"#{type}-#{xx}-#{yy}-#{b}" }
                end
              else
                [pos.to_sym]
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
        if action[:type] == :grid
          actions += mappings_for_grid_action(state, action[:control])
        end
        actions        += combined_types.map { |ct| responses[ct][state] }
        actions        += responses[:all][state]
        actions.flatten.compact
      end

      def mappings_for_grid_action(state, control)
        x         = control[:x]
        y         = control[:y]
        bank      = control[:bank]
        actions   = []
        actions  += responses[:"grid-#{x}-#{y}-#{bank}"][state]
        actions  += responses[:"grid-#{x}--#{bank}"][state]
        actions  += responses[:"grid--#{y}-#{bank}"][state]
        actions  += responses[:"grid-#{x}-#{y}-"][state]
        actions  += responses[:"grid-#{x}--"][state]
        actions  += responses[:"grid--#{y}-"][state]
        actions
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
