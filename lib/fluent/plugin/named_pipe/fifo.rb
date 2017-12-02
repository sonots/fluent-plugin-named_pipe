require 'forwardable'
require 'mkfifo'

module Fluent
  module PluginNamedPipe
    class Fifo
      extend Forwardable

      READ_TIMEOUT = 1

      def initialize(file_path, mode = :r)
        if !File.exist?(file_path)
          File.mkfifo(file_path)
          File.chmod(0666, file_path)
        end

        @file_path = file_path
        @mode = mode
        self.open

        @buf = ''
      end

      def_delegators :@pipe, :read, :write, :close, :flush

      def open
        m = {:r => 'r+', :w => 'w+'}[@mode]
        @pipe = File.open(@file_path, m)
      end

      def readline
        res = IO.select([@pipe], [], [], READ_TIMEOUT)
        return nil if res.nil?

        while nil == (idx = @buf.index("\n")) do
          tmp = ''
          begin
            s = @pipe.sysread(0xffff, tmp)
            @buf << s
          rescue EOFError
            # reopen
            @pipe.close
            @pipe.open
          end
        end

        line = @buf[0, idx + 1]
        @buf = @buf[idx + 1, @buf.length - line.length]
        return line
      end

    end
  end
end
