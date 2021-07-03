class RPM
  class File; end

  def self.read(path)
    instance = allocate
    rpm_file = RPM::File.new(path)
    rpm_file.header.tags.each do |tag|
      instance.define_singleton_method(tag.tag, lambda{ tag.value} )
    end

    instance
  end

end

module ArrPM
  module V2
    class Package; end
  end
end
