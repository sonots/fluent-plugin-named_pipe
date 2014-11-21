module Fluent
  class NamedPipeOutput < Output
    Plugin.register_output('named_pipe', self)

    config_param :path, :string
    config_param :format, :string, :default => 'out_file'

    def initialize
      require 'fifo'
      super
    end

    def configure(conf)
      super

      begin
        @pipe = Fifo.new(@path, :w, :nowait)
      rescue => e
        raise FluentConfig, "#{e.class}: #{e.message}"
      end

      conf['format'] = @format
      @formatter = TextFormatter.create(conf)
    end

    def emit(tag, es, chain)
      es.each do |time, record|
        @pipe.write @formatter.format(tag, time, record)
      end

      chain.next
    rescue => e
      log.warn "out_named_pipe: #{e.class} #{e.message} #{e.backtrace.first}"
    end
  end
end

