require 'forwardable'
require 'mkfifo'

class Fifo
  include Forwardable
  
  class Pipe < ::File
    alias :orig_write :write
    def write(*args)
      orig_write(*args)
      flush
    end
  end
  
  def initialize(file_path, mode = :r)
    if !File.exist?(file_path)
      File.mkfifo(file_path)
      File.chmod(0666, file_path)
    end

    @file_path = file_path
    @mode = mode
    self.open

    def_delegators :@pipe, :read, :write, :close
    
    @buf = ''
  end

  def open
    m = {:r => 'r+', :w => 'w+'}[@mode]
    # p "open %s %s" % [@file_path, m]
    @pipe = Pipe.open(@file_path, m)
  end

  def readline
    while nil == (idx = @buf.index("\n")) do
      # while nil == (tmp = self.read(1)) do
      tmp = ''
      while true
        begin
          s = @pipe.sysread(0xffff, tmp)
          p s
        rescue EOFError => e
          # reopen
          @pipe.close
          @pipe.open
        end
      end

      @buf << tmp
    end

    line = @buf[0, idx + 1]
    @buf = @buf[idx + 1, @buf.length - line.length]
    return line
  end

end
