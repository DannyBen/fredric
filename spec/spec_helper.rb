require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'bundler'
Bundler.require :default, :development

include Fredric

RSpec.configure do |config|
  config.before :suite do
    puts 'Running spec_helper > before :suite'
    puts 'Flushing cache'
    APICake::Base.new.cache.flush
  end
end
