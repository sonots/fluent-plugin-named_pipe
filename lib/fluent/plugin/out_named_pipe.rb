require_relative 'named_pipe/fifo'

module Fluent
  class NamedPipeOutput < Output
    Plugin.register_output('named_pipe', self)

    config_param :path, :string
    config_param :format, :string, :default => 'out_file'

    unless method_defined?(:log)
      define_method(:log) { $log }
    end

    def configure(conf)
      super

      begin
        @pipe = PluginNamedPipe::Fifo.new(@path, :w)
      rescue => e
        raise ConfigError, "#{e.class}: #{e.message}"
      end

      @formatter = Plugin.new_formatter(@format)
      @formatter.configure(conf)
    end

    def shutdown
      @pipe.close
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        @pipe.write @formatter.format(tag, time, record)
        @pipe.flush
      end

      chain.next
    rescue => e
      log.error "out_named_pipe: unexpected error", :error_class => e.class, :error => e.to_s
      log.error_backtrace
    end
  end
end

