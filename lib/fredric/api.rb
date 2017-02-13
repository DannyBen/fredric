require 'json'
require 'csv'
require 'apicake'

module Fredric
  # Provides access to all the FRED API endpoints
  class API < APICake::Base
    # disable_dynamic_methods
    base_uri 'https://api.stlouisfed.org/fred'

    attr_reader :api_key

    def initialize(api_key, opts={})
      @api_key = api_key
      cache.disable unless opts[:use_cache]
      cache.dir = opts[:cache_dir] if opts[:cache_dir]
      cache.life = opts[:cache_life] if opts[:cache_life]
    end

    def default_query
      { api_key: api_key, file_type: :json } 
    end
  end
end