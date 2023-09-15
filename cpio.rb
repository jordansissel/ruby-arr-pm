require "arr-pm/cpio"

CPIO::ASCIIReader.new(STDIN).each do |entry, file|
  puts entry.name
  file.read unless entry.directory?
end
