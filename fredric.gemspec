lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fredric/version'

Gem::Specification.new do |s|
  s.name        = 'fredric'
  s.version     = Fredric::VERSION
  s.date        = Date.today.to_s
  s.summary     = "FRED API Library and Command Line"
  s.description = "Easy to use API for the Federal Reserve Economic Data service with a command line interface"
  s.authors     = ["Danny Ben Shitrit"]
  s.email       = 'db@dannyben.com'
  s.files       = Dir['README.md', 'lib/**/*.*']
  s.executables = ["fred"]
  s.homepage    = 'https://github.com/DannyBen/fredric'
  s.license     = 'MIT'
  s.required_ruby_version = ">= 2.0.0"

  s.add_runtime_dependency 'docopt', '~> 0.5'
  s.add_runtime_dependency 'awesome_print', '~> 1.7'
  s.add_runtime_dependency 'webcache', '~> 0.3'

  s.add_development_dependency 'runfile', '~> 0.8'
  s.add_development_dependency 'runfile-tasks', '~> 0.4'
  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'rdoc', '~> 5.0'
  s.add_development_dependency 'byebug', '~> 9.0'
  s.add_development_dependency 'simplecov', '~> 0.13'
  s.add_development_dependency 'yard', '~> 0.8'
end
