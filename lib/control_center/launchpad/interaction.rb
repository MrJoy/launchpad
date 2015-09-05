module ControlCenter
  module Launchpad
    class Interaction < ControlCenter::Interaction
      # def response_to(types = :all, state = :both, opts = nil, &block)
      #   logger.debug "setting response to #{types.inspect} for state #{state.inspect} with #{opts.inspect}"
      #   types = Array(types)
      #   opts ||= {}
      #   no_response_to(types, state) if opts[:exclusive] == true
      #   Array(state == :both ? %i(down up) : state).each do |st|
      #     types.each do |type|
      #       combined_types(type, opts).each do |combined_type|
      #         responses[combined_type][st] << block
      #       end
      #     end
      #   end
      #   nil
      # end

      # def no_response_to(types = nil, state = :both, opts = nil)
      #   logger.debug "removing response to #{types.inspect} for state #{state.inspect}"
      #   types = Array(types)
      #   Array(state == :both ? %i(down up) : state).each do |st|
      #     types.each do |type|
      #       combined_types(type, opts).each do |combined_type|
      #         responses[combined_type][st].clear
      #       end
      #     end
      #   end
      #   nil
      # end

      # def respond_to(type, state, opts = nil)
      #   respond_to_action((opts || {}).merge(type: type, state: state))
      # end

    protected

      # def responses
      #   @responses ||= Hash.new { |hash, key| hash[key] = { down: [], up: [] } }
      # end

      # def grid_range(range)
      #   return nil if range.nil?
      #   Array(range).flatten.map do |pos|
      #     pos.respond_to?(:to_a) ? pos.to_a : pos
      #   end.flatten.uniq
      # end

      # def combined_types(type, opts = nil)
      #   if type.to_sym == :grid && opts
      #     x = grid_range(opts[:x])
      #     y = grid_range(opts[:y])
      #     return [:grid] if x.nil? && y.nil?  # whole grid
      #     x ||= ['-']                         # whole row
      #     y ||= ['-']                         # whole column
      #     x.product(y).map { |xx, yy| :"grid#{xx}#{yy}" }
      #   else
      #     [type.to_sym]
      #   end
      # end

      # def respond_to_action(action)
      #   type    = action[:type].to_sym
      #   state   = action[:state].to_sym
      #   actions = []
      #   if type == :grid
      #     actions += responses[:"grid#{action[:x]}#{action[:y]}"][state]
      #     actions += responses[:"grid#{action[:x]}-"][state]
      #     actions += responses[:"grid-#{action[:y]}"][state]
      #   end
      #   actions += responses[type][state]
      #   actions += responses[:all][state]
      #   actions.compact.each {|block| block.call(self, action)}
      #   nil
      # rescue Exception => e # TODO: StandardException, RuntimeError, or Exception?
      #   logger.error "Error when responding to action #{action.inspect}: #{e.inspect}"
      #   raise e
      # end
    end
  end
end
