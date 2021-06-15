module CPIO
  FIELDS = [
    :magic, :ino, :mode, :uid, :gid, :nlink, :mtime, :filesize, :devmajor,
    :devminor, :rdevmajor, :rdevminor, :namesize, :check
  ]
end

require "arr-pm/cpio/bounded_io"
require "arr-pm/cpio/entry"
require "arr-pm/cpio/ascii_reader"
