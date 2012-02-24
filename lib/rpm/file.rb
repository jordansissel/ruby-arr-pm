require File.join(File.dirname(__FILE__), "namespace")
require File.join(File.dirname(__FILE__), "file", "header")
require File.join(File.dirname(__FILE__), "file", "lead")
require File.join(File.dirname(__FILE__), "file", "tag")

# Much of the code here is derived from knowledge gained by reading the rpm
# source code, but mostly it started making more sense after reading this site:
# http://www.rpm.org/max-rpm/s1-rpm-file-format-rpm-file-format.html

class RPM::File
  attr_reader :file

  def initialize(file)
    if file.is_a?(String)
      file = File.new(file, "r")
    end
    @file = file

  end # def initialize

  public
  def lead
    if @lead.nil?
      # Make sure we're at the beginning of the file.
      @file.seek(0, IO::SEEK_SET)
      @lead = ::RPM::File::Lead.new(@file)

      # TODO(sissel): have 'read' return number of bytes read?
      @lead.read
    end
    return @lead
  end # def lead

  public
  def signature
    lead # Make sure we've parsed the lead...

    # If signature_type is not 5 (HEADER_SIGNED_TYPE), no signature.
    if @lead.signature_type != Header::HEADER_SIGNED_TYPE
      @signature = false
      return
    end

    if @signature.nil?
      @signature = ::RPM::File::Header.new(@file)
      @signature.read

      # signature headers are padded up to an 8-byte boundar, details here:
      # http://rpm.org/gitweb?p=rpm.git;a=blob;f=lib/signature.c;h=63e59c00f255a538e48cbc8b0cf3b9bd4a4dbd56;hb=HEAD#l204
      # Throw away the pad.
      @file.read(@signature.length % 8)
    end

    return @signature
  end # def signature

  public
  def header
    signature

    if @header.nil?
      @header = ::RPM::File::Header.new(@file)
      @header.read
    end
    return @header
  end

  # Returns a file descriptor. On first invocation, it seeks to the start of the payload
  public
  def payload
    header
    if @payload.nil?
      @payload = @file.clone
      # The payload starts after the lead, signature, and header. Remember the signature has an
      # 8-byte boundary-rounding.
      @payload.seek(@lead.length + @signature.length + @signature.length % 8 + @header.length, IO::SEEK_SET)
    end

    return @payload
  end # def payload
end # class RPM::File
