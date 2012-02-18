# ARRRRRRRRRR PM

RPM reader/writer library written in Ruby.

It aims to provide [fpm](https://github.com/jordansissel/fpm) with a way to
read and write rpms.

## Why not use librpm?

It's awkward at least for what I want to do.

## API ideas

It should be possible to do a read+modify+write on an RPM.

### Creating an RPM

    rpm = RPM.new

    # requires and conflicts
    rpm.requires("name") <= "version" # Something fun-dsl-likef
    rpm.requires("name", :<=, "version") # Or maybe something like this

    # provides
    rpm.provides("name")

    # Add some files
    rpm.files << path
    rpm.files << path2
    rpm.files << path3

    # Scripts?
    rpm.scripts[:preinstall](path_or_script_string)
    rpm.scripts[:postinstall](path_or_script_string)
    rpm.scripts[:preuninstall](path_or_script_string)
    rpm.scripts[:postuninstall](path_or_script_string)

    rpm.write(output_file_name)

### Reading an RPM

    rpm = RPM.read(file)

    rpm.requires   # Array of RPM::Requires ?
    rpm.provides   # Array of 'Provides' strings?
    rpm.conflicts  # Array of RPM::Conflicts ?
    rpm.files      # Array of RPM::File ?

Maybe something like:

    rpm.files.each do |file|
      # Tags that are defined in rpm header tags
      # fileclass filecolors filecontexts filedependsn filedependsx filedevices
      # filedigests fileflags filegroupname fileinodes filelangs filelinktos
      # filemodes filemtimes filerdevs filesizes fileusername fileverifyflags 
      #
      # frankly, we don't care about most of these. Meaningful ones:
      # username, groupname, size, mtime, mode, linkto

      # file.io could give a nice IO-like thing that let you read the file out
      # of the rpm
    end



