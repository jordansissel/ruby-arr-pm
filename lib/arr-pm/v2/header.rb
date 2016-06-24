# encoding: utf-8

require "arr-pm/namespace"
require "arr-pm/v2/format"
require "arr-pm/v2/header_header"
require "arr-pm/v2/tag"
require "arr-pm/v2/error"

class ArrPM::V2::Header
  def load(io)
    headerheader = ArrPM::V2::HeaderHeader.new
    headerheader.load(io)
    data = io.read(headerheader.bytesize)
    parse(data, headerheader.entries)
  end

  def parse(data, entry_count)
    entries = []
    entry_count.times do |i|
      tag, type, offset, count = data[i * 16, 16].unpack("NNNN")
      # TODO(sissel): Stopped working here; continue.
    end
  end

end
