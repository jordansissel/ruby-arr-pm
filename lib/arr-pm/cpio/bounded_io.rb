class CPIO::BoundedIO
  attr_reader :length
  attr_reader :remaining

  def initialize(io, length, &eof_callback)
    @io = io
    @length = length
    @remaining = length

    @eof_callback = eof_callback
    @eof = false
  end

  def read(size=nil)
    return nil if eof?
    size = @remaining if size.nil?
    data = @io.read(size)
    @remaining -= data.bytesize
    eof?
    data
  end

  def sysread(size)
    raise EOFError, "end of file reached" if eof?
    read(size)
  end

  def eof?
    return false if @remaining > 0
    return @eof if @eof

    @eof_callback.call
    @eof = true
  end
end
