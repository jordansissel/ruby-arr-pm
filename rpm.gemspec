Gem::Specification.new do |spec|
  files = %x{git ls-files}

  spec.name = "rpm"
  spec.version = "0.0.1"
  spec.summary = "rpm"
  spec.description = "rpm"
  spec.license = "none chosen yet"

  # Note: You should set the version explicitly.
  spec.add_dependency "cabin", ">0" # for logging. apache 2 license
  spec.files = files
  spec.require_paths << "lib"
  spec.bindir = "bin"

  spec.authors = ["Jordan Sissel"]
  spec.email = ["jls@semicomplete.com"]
  #spec.homepage = "..."
end

