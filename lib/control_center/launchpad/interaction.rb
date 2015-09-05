module ControlCenter
  module Launchpad
    class Interaction
      include ControlCenter::Logging

      attr_reader :device, :active

      def initialize(opts = nil)
        opts ||= {}

        self.logger = opts[:logger]
        logger.debug "Initializing ControlCenter::Launchpad::Interaction##{object_id} with #{opts.inspect}"

        @device       = opts[:device]
        @use_threads  = opts[:use_threads] || true
        @device     ||= Device.new(opts.merge(input: true,
                                              output: true,
                                              logger: opts[:logger]))
        @latency      = (opts[:latency] || 0.001).to_f.abs
        @active       = false

        @action_threads = ThreadGroup.new
      end

      def close
        logger.debug "Closing ControlCenter::Launchpad::Interaction##{object_id}"
        stop
        @device.close
      end

      def closed?; @device.closed?; end

      def start(opts = nil)
        logger.debug "starting Launchpad::Interaction##{object_id}"

        opts = { detached: false }.merge(opts || {})

        @active = true

        @reader_thread ||= Thread.new do
          begin
            while @active do
              @device.read_pending_actions.each do |action|
                if @use_threads
                  action_thread = Thread.new(action) do |act|
                    respond_to_action(act)
                  end
                  @action_threads.add(action_thread)
                else
                  respond_to_action(action)
                end
              end
              sleep @latency# if @latency > 0.0
            end
          rescue Portmidi::DeviceError => e
            logger.fatal "could not read from device, stopping to read actions"
            raise ControlCenter::CommunicationError.new(e)
          rescue Exception => e
            logger.fatal "error causing action reading to stop: #{e.inspect}"
            raise e
          ensure
            @device.reset
          end
        end
        @reader_thread.join unless opts[:detached]
      end

      def stop
        logger.debug "Stopping ControlCenter::Launchpad::Interaction##{object_id}"
        @active = false
        if @reader_thread
          # run (resume from sleep) and wait for @reader_thread to end
          @reader_thread.run if @reader_thread.alive?
          @reader_thread.join
          @reader_thread = nil
        end
      ensure
        @action_threads.list.each do |thread|
          begin
            thread.kill
            thread.join
          rescue StandardException => e # TODO: RuntimeError, Exception, or this?
            logger.error "Error when killing action thread: #{e.inspect}"
          end
        end
        nil
      end

      def response_to(types = :all, state = :both, opts = nil, &block)
        logger.debug "setting response to #{types.inspect} for state #{state.inspect} with #{opts.inspect}"
        types = Array(types)
        opts ||= {}
        no_response_to(types, state) if opts[:exclusive] == true
        Array(state == :both ? %i(down up) : state).each do |st|
          types.each do |type|
            combined_types(type, opts).each do |combined_type|
              responses[combined_type][st] << block
            end
          end
        end
        nil
      end

      def no_response_to(types = nil, state = :both, opts = nil)
        logger.debug "removing response to #{types.inspect} for state #{state.inspect}"
        types = Array(types)
        Array(state == :both ? %i(down up) : state).each do |st|
          types.each do |type|
            combined_types(type, opts).each do |combined_type|
              responses[combined_type][st].clear
            end
          end
        end
        nil
      end

      def respond_to(type, state, opts = nil)
        respond_to_action((opts || {}).merge(type: type, state: state))
      end

    private

      def responses
        @responses ||= Hash.new { |hash, key| hash[key] = { down: [], up: [] } }
      end

      def grid_range(range)
        return nil if range.nil?
        Array(range).flatten.map do |pos|
          pos.respond_to?(:to_a) ? pos.to_a : pos
        end.flatten.uniq
      end

      def combined_types(type, opts = nil)
        if type.to_sym == :grid && opts
          x = grid_range(opts[:x])
          y = grid_range(opts[:y])
          return [:grid] if x.nil? && y.nil?  # whole grid
          x ||= ['-']                         # whole row
          y ||= ['-']                         # whole column
          x.product(y).map { |xx, yy| :"grid#{xx}#{yy}" }
        else
          [type.to_sym]
        end
      end

      def respond_to_action(action)
        type    = action[:type].to_sym
        state   = action[:state].to_sym
        actions = []
        if type == :grid
          actions += responses[:"grid#{action[:x]}#{action[:y]}"][state]
          actions += responses[:"grid#{action[:x]}-"][state]
          actions += responses[:"grid-#{action[:y]}"][state]
        end
        actions += responses[type][state]
        actions += responses[:all][state]
        actions.compact.each {|block| block.call(self, action)}
        nil
      rescue Exception => e # TODO: StandardException, RuntimeError, or Exception?
        logger.error "Error when responding to action #{action.inspect}: #{e.inspect}"
        raise e
      end
    end
  end
end
