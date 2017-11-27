require 'forwardable'
require 'mkfifo'

class Fifo
  include Forwardable

  READ_TIMEOUT = 1

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
    @pipe = Pipe.open(@file_path, m)
  end

  def readline
    res = IO.select([@pipe], [], [], READ_TIMEOUT)
    return nil if res.nil?
    
    while nil == (idx = @buf.index("\n")) do
      tmp = ''
      begin
        s = @pipe.sysread(0xffff, tmp)
        @buf << s
      rescue EOFError => e
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
