require File.join(File.dirname(__FILE__), "namespace")
require File.join(File.dirname(__FILE__), "file", "header")
require File.join(File.dirname(__FILE__), "file", "lead")
require File.join(File.dirname(__FILE__), "file", "tag")

# Much of the code here is derived from knowledge gained by reading the rpm
# source code, but mostly it started making more sense after reading this site:
# http://www.rpm.org/max-rpm/s1-rpm-file-format-rpm-file-format.html

class RPM::File
  attr_reader :file

  FLAG_LESS = (1 << 1)    #     RPMSENSE_LESS = (1 << 1),
  FLAG_GREATER = (1 << 2) #     RPMSENSE_GREATER  = (1 << 2),
  FLAG_EQUAL = (1 << 3)   #     RPMSENSE_EQUAL  = (1 << 3),

  def initialize(file)
    if file.is_a?(String)
      file = File.new(file, "r")
    end
    @file = file
  end # def initialize

  # Return the lead for this rpm
  #
  # This 'lead' structure is almost entirely deprecated in the RPM file format.
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

  # Return the signature header for this rpm
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

  # Return the header for this rpm.
  def header
    signature

    if @header.nil?
      @header = ::RPM::File::Header.new(@file)
      @header.read
    end
    return @header
  end # def header

  # Returns a file descriptor for the payload. On first invocation, it seeks to
  # the start of the payload
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

  # Extract this RPM to a target directory.
  #
  # This should have roughly the same effect as:
  # 
  #   % rpm2cpio blah.rpm | (cd {target}; cpio -i --make-directories)
  def extract(target)
    if !File.directory?(target)
      raise Errno::ENOENT.new(target)
    end

    tags = {}
    header.tags.each do |tag|
      tags[tag.tag] = tag.value
    end 
    
    # Extract to the 'target' path
    #tags[:payloadcompressor] # "xz" or "gzip" or ..?
    #tags[:payloadformat] # "cpio"

    extractor = IO.popen("#{tags[:payloadcompressor]} -d | (cd #{target}; cpio -i --make-directories)", "w")
    buffer = ""
    buffer.force_encoding("BINARY")
    payload_fd = payload
    loop do
      data = payload.read(16384, buffer)
      break if data.nil? # eof
      extractor.write(data)
    end
    extractor.close
  end # def extract

  def tags
    if @tags.nil?
      @tags = {}
      header.tags.each do |tag|
        tags[tag.tag] = tag.value
      end
    end
    @tags
  end # def taghash

  # Get all relations of a given type to this package.
  #
  # Examples:
  #
  #     rpm.relation(:require)
  #     rpm.relation(:conflict)
  #     rpm.relation(:provide)
  #
  # In the return array-of-arrays, the elements are:
  # [ name (string), operator (string), version (string) ]
  #
  # operator will be ">=", ">", "=", "<", or "<="
  #
  # @return Array of [name, operator, version]
  def relation(type)
    name = "#{type}name".to_sym
    flags = "#{type}flags".to_sym
    version = "#{type}version".to_sym
    # There is no data if we are missing all 3 tag types (name/flags/version)
    # FYI: 'tags.keys' is an array, Array#& does set intersection. 
    return [] if (tags.keys & [name, flags, version]).size != 3
    # Find tags <type>name, <type>flags, and <type>version, and return
    # an array of "name operator version"
    return tags[name].zip(tags[flags], tags[version]) \
      .reduce([]) { |memo, (n,o,v)| memo << [n, operator(o), v] }
  end # def relation

  # Get an array of requires defined in this package.
  #
  # @return Array of [ [name, operator, version], ... ]
  def requires
    return relation(:require)
  end # def requires

  # Get an array of conflicts defined in this package.
  #
  # @return Array of [ [name, operator, version], ... ]
  def conflicts
    return relation(:conflicts)
  end # def conflicts

  # Get an array of provides defined in this package.
  #
  # @return Array of [ [name, operator, version], ... ]
  def provides
    return provides(:provides)
  end # def provides

  def operator(flag)
    have = lambda do |mask|
      return (flag & mask) == mask
    end

    return "<=" if have.call(FLAG_LESS | FLAG_EQUAL)
    return ">=" if have.call(FLAG_GREATER | FLAG_EQUAL)
    return "=" if have.call(FLAG_EQUAL)
    return "<" if have.call(FLAG_LESS)
    return ">" if have.call(FLAG_GREATER)
  end # def operator

  public(:extract, :payload, :header, :lead, :signature, :initialize, :requires)
end # class RPM::File
