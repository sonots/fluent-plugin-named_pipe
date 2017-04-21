require 'fluent/input'

module Fluent
  class NamedPipeInput < Input
    Fluent::Plugin.register_input('named_pipe', self)

    config_param :path, :string
    config_param :tag, :string
    config_param :format, :string

    unless method_defined?(:log)
      define_method(:log) { $log }
    end

    # Define `router` method of v0.12 to support v0.10 or earlier
    unless method_defined?(:router)
      define_method("router") { Fluent::Engine }
    end

    def initialize
      require 'fifo'
      super
    end

    def configure(conf)
      super

      begin
        pipe = Fifo.new(@path, :r, :nowait)
        pipe.close # just to try open
      rescue => e
        raise ConfigError, "#{e.class}: #{e.message}"
      end

      @parser = Plugin.new_parser(@format)
      @parser.configure(conf)
    end

    def start
      super
      @running = true
      @thread = Thread.new(&method(:run))
    end

    def shutdown
      @running = false
      @thread.join
      @pipe.close
    end

    def run
      @pipe = Fifo.new(@path, :r, :wait)

      while @running
        begin
          line = @pipe.readline # blocking
          @parser.parse(line) do |time, record|
            if time and record
              router.emit(@tag, time, record)
            else
              log.warn "Pattern not match: #{line.inspect}"
            end
          end
        rescue => e
          log.error "in_named_pipe: unexpected error", :error_class => e.class, :error => e.to_s
          log.error_backtrace
        end
      end
    end
  end
end
