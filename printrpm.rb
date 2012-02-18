$: << "lib"

require "rpm/file"

rpm = RPM::File.new(ARGV[0])

p rpm.lead
p rpm.signature
#rpm.signature.tags.each do |tag|
  #p :signature => [tag.tag, tag.type, tag.value]
#end
p rpm.header

rpm.header.tags.each do |tag|
  next unless tag.tag.to_s =~ /(require|provide)/
  p tag.tag => tag.value
end
#rpm.header.tags[-3..-1].each do |tag|
  #p :header => [tag.tag, tag.type, tag.value]
#end

#payload = rpm.payload
#fd = File.new("/tmp/x.cpio.gz", "w")
#fd.write(rpm.payload.read)
