lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'date'
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

  s.add_runtime_dependency 'super_docopt', '~> 0.1'
  s.add_runtime_dependency 'awesome_print', '~> 1.7'
  s.add_runtime_dependency 'apicake', '~> 0.1'
end
