
require "rpm/namespace"

class RPM
  def initialize
    #@requires = []
    #@conflicts = []
    #@provides = []
    #@files = []
    #@scripts = {}
  end

  def self.read(path_or_io)
    rpmfile = RPM::File.new(path_or_io)
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
  end
end # class RPM
