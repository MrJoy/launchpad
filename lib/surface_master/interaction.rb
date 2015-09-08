module SurfaceMaster
  # Base class for event-based drivers.  Sub-classes should extend the constructor, and implement
  # `respond_to_action`, etc.
  class Interaction
    include Logging

    attr_reader :device, :active

    def initialize(opts = nil)
      opts ||= {}

      self.logger = opts[:logger]
      logger.debug "Initializing #{self.class}##{object_id} with #{opts.inspect}"

      @use_threads  = opts[:use_threads] || true
      @device       = opts[:device]
      @device     ||= @device_class.new(opts.merge(input: true,
                                                   output: true,
                                                   logger: opts[:logger]))
      @latency      = (opts[:latency] || 0.001).to_f.abs
      @active       = false

      @action_threads = ThreadGroup.new
    end

    def change(opts); @device.change(opts); end
    def changes(opts); @device.changes(opts); end

    def close
      logger.debug "Closing #{self.class}##{object_id}"
      stop
      @device.close
    end

    def closed?; @device.closed?; end

    def start(opts = nil)
      logger.debug "Starting #{self.class}##{object_id}"

      opts = { detached: false }.merge(opts || {})

      @active = true

      @reader_thread ||= Thread.new do
        begin
          while @active
            @device.read.each do |action|
              handle_action(action)
            end
            sleep @latency if @latency && @latency > 0.0
          end
        rescue Portmidi::DeviceError => e
          logger.fatal "Could not read from device, stopping reader!"
          raise SurfaceMaster::CommunicationError, e
        rescue Exception => e
          logger.fatal "Unkown error, stopping reader: #{e.inspect}"
          raise e
        ensure
          @device.reset!
        end
      end
      @reader_thread.join unless opts[:detached]
    end

    def stop
      logger.debug "Stopping #{self.class}##{object_id}"
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
      logger.debug "Setting response to #{types.inspect} for state #{state.inspect} with"\
        " #{opts.inspect}"
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
      logger.debug "Removing response to #{types.inspect} for state #{state.inspect}"
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

  protected

    def handle_action(action)
      if @use_threads
        action_thread = Thread.new(action) do |act|
          respond_to_action(act)
        end
        @action_threads.add(action_thread)
      else
        respond_to_action(action)
      end
    end

    def responses
      # TODO: Generalize for arbitrary actions...
      @responses ||= Hash.new { |hash, key| hash[key] = { down: [], up: [] } }
    end

    def respond_to_action(_action); end
  end
end
