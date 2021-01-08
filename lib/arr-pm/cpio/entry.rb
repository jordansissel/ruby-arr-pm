class CPIO::Entry
  CPIO::FIELDS.each do |field|
    attr_accessor field
  end

  attr_accessor :name
  attr_accessor :file

  DIRECTORY_FLAG = 0040000

  def validate
    raise "Invalid magic #{magic.inspect}" if magic != 0x070701
    raise "Invalid ino #{ino.inspect}" if ino < 0
    raise "Invalid mode #{mode.inspect}" if mode < 0
    raise "Invalid uid #{uid.inspect}" if uid < 0
    raise "Invalid gid #{gid.inspect}" if gid < 0
    raise "Invalid nlink #{nlink.inspect}" if nlink < 0
    raise "Invalid mtime #{mtime.inspect}" if mtime < 0
    raise "Invalid filesize #{filesize.inspect}" if filesize < 0
    raise "Invalid devmajor #{devmajor.inspect}" if devmajor < 0
    raise "Invalid devminor #{devminor.inspect}" if devminor < 0
    raise "Invalid rdevmajor #{rdevmajor.inspect}" if rdevmajor < 0
    raise "Invalid rdevminor #{rdevminor.inspect}" if rdevminor < 0
    raise "Invalid namesize #{namesize.inspect}" if namesize < 0
    raise "Invalid check #{check.inspect}" if check < 0
  end # def validate

  def read(*args)
    return nil if directory?
    file.read(*args)
  end

  def directory?
    mode & DIRECTORY_FLAG > 0
  end
end
