require "rpm/namespace"

class RPM
  private

  def initialize
    #@requires = []
    #@conflicts = []
    #@provides = []
    #@files = []
    #@scripts = {}
  end

  def requires(name, operator=nil, version=nil)
    @requires << [name, operator, version]
  end # def requires

  def conflicts(name, operator=nil, version=nil)
    @conflicts << [name, operator, version]
  end

  def provides(name)
    @provides << name
  end

  def self.read(path_or_io)
    rpmfile = RPM::File.new(path_or_io)
    signature = rpmfile.signature
    header = rpmfile.header

    header.tags.each do |tag|
      p tag
    end

    # Things we care about in the header:
    # * name, version, release, epoch, summary, description
    # * 
    # * requires, provides, conflicts
    # * scripts
    # * payload format

    #payload = rpmfile.payload
    # Parse the payload, check the rpmfile.header to find tags describing the
    # format of the payload.
    # Initial target should be gzipped cpio.
  end # def self.read

  def files
    return @files
  end

  # Write this RPM to an IO-like object (must respond to 'write')
  def write(io)
    # write the lead
    # write the signature?
    # write the header
    # write the payload
  end

  public(:files, :requires, :conflicts, :provides, :write)
end # class RPM
