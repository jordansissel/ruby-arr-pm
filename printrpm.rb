$: << "lib"

require "rpm/file"

rpm = RPM::File.new(ARGV[0])

p rpm.lead
rpm.signature.tags.each do |tag|
  #p :tag => [tag.tag, tag.type, tag.count, tag.value]
end

rpm.header.tags.each do |tag|
  next unless tag.tag.to_s =~ /(require|provide|payload)/
  #p tag.tag => tag.value
end

payload = rpm.payload
fd = File.new("/tmp/rpm.payload", "w")
fd.write(rpm.payload.read)
