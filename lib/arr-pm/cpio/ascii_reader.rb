class CPIO::ASCIIReader
  FIELD_SIZES = {
    :magic => 6,
    :ino => 8,
    :mode => 8,
    :uid => 8,
    :gid => 8,
    :nlink => 8,
    :mtime => 8,
    :filesize => 8,
    :devmajor => 8,
    :devminor => 8,
    :rdevmajor => 8,
    :rdevminor => 8,
    :namesize => 8,
    :check => 8
  }
  HEADER_LENGTH = FIELD_SIZES.reduce(0) { |m, (_, v)| m + v }
  HEADER_PACK = FIELD_SIZES.collect { |_, v| "A#{v}" }.join

  FIELD_ORDER = [
    :magic, :ino, :mode, :uid, :gid, :nlink, :mtime, :filesize, :devmajor,
    :devminor, :rdevmajor, :rdevminor, :namesize, :check
  ]

  def initialize(io)
    @io = io
  end

  private

  def io
    @io
  end

  def each(&block)
    while true
      entry = read
      break if entry.nil?
      # The CPIO format has the end-of-stream marker as a file called "TRAILER!!!"
      break if entry.name == "TRAILER!!!"
      block.call(entry, entry.file)
      verify_correct_read(entry) unless entry.directory?
    end
  end

  def verify_correct_read(entry)
    # Read and throw away the whole file if not read at all.
    entry.file.tap do |file|
      if file.nil? ||  file.remaining == 0
        # All OK! :)
      elsif file.remaining == file.length
        file.read(16384) while !file.eof?
      else
        # The file was only partially read? This should be an error by the
        # user.
        consumed = file.length - file.remaining
        raise BadState, "Only #{consumed} bytes were read of the #{file.length} byte file: #{entry.name}"
      end
    end
  end

  def read
    entry = CPIO::Entry.new
    header = io.read(HEADER_LENGTH)
    return nil if header.nil?
    FIELD_ORDER.zip(header.unpack(HEADER_PACK)).each do |field, value|
      entry.send("#{field}=", value.to_i(16))
    end

    entry.validate
    entry.mtime = Time.at(entry.mtime)
    read_name(entry, @io)
    read_file(entry, @io)
    entry
  end

  def read_name(entry, io)
    entry.name = io.read(entry.namesize - 1) # - 1 for null terminator
    nul = io.read(1)
    raise ArgumentError, "Corrupt CPIO or bug? Name null terminator was not null: #{nul.inspect}" if nul != "\0"
    padding_data = io.read(padding_name(entry))
    # Padding should be all null bytes
    if padding_data != ("\0" * padding_data.bytesize)
      raise ArgumentError, "Corrupt CPIO or bug? Name null padding was #{padding_name(entry)} bytes: #{padding_data.inspect}"
    end
  end

  def read_file(entry, io)
    if entry.directory?
      entry.file = nil
      #read_file_padding(entry, io)
      nil
    else
      entry.file = CPIO::BoundedIO.new(io, entry.filesize) do
        read_file_padding(entry, io)
      end
    end
  end

  def read_file_padding(entry, io)
    padding_data = io.read(padding_file(entry))
    if padding_data != ("\0" * padding_data.bytesize)
      raise ArgumentError, "Corrupt CPIO or bug? File null padding was #{padding_file(entry)} bytes: #{padding_data.inspect}"
    end
  end

  def padding_name(entry)
    # name padding is padding up to a multiple of 4 after header+namesize
    -(HEADER_LENGTH + entry.namesize) % 4
  end

  def padding_file(entry)
    (-(HEADER_LENGTH + entry.filesize + 2) % 4)
  end
  public(:each)
end
