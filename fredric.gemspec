lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fredric/version'

Gem::Specification.new do |s|
  s.name        = 'fredric'
  s.version     = Fredric::VERSION
  s.summary     = 'FRED API Library and Command Line'
  s.description = 'Easy to use API for the Federal Reserve Economic Data service with a command line interface'
  s.authors     = ['Danny Ben Shitrit']
  s.email       = 'db@dannyben.com'
  s.files       = Dir['README.md', 'lib/**/*.*']
  s.executables = ['fred']
  s.homepage    = 'https://github.com/DannyBen/fredric'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.7'

  s.add_runtime_dependency 'apicake', '~> 0.1'
  s.add_runtime_dependency 'lp', '~> 0.2'
  s.add_runtime_dependency 'super_docopt', '~> 0.1'
  s.metadata['rubygems_mfa_required'] = 'true'
end
