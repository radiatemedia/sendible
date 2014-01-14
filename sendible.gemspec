$:.push File.expand_path("../lib", __FILE__)

#Maintain the gem version automatically
require 'sendible/version'

Gem::Specification.new do |s|
  s.name        = 'sendible'
  s.version     = Sendible::VERSION
  s.summary     = "Sendible API interaction"
  s.description = "An interface to the Sendible API"
  s.authors     = ["Radiate Media"]
  s.email       = 'engineeringslc@radiatemedia.com'
  s.files       = Dir["{lib}/**/*", "LICENSE", "README.md"]
  s.homepage    = 'https://github.com/radiatemedia/sendible'
  s.license     = 'MIT'

  #dependencies here
  #s.add_dependency 'great_library', '1.2.3'

  #s.add_development_dependency 'test_library', '1.2.3'
end
