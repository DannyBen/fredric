require 'json'
require 'csv'
require 'apicake'

module Fredric
  # Provides access to all the FRED API endpoints with dynamic methods
  # anc caching.
  class API < APICake::Base
    base_uri 'https://api.stlouisfed.org/fred'

    attr_reader :api_key

    # Initializes the API with an API Key, and optional cache settings.
    def initialize(api_key, opts={})
      @api_key = api_key
      cache.disable unless opts[:use_cache]
      cache.dir = opts[:cache_dir] if opts[:cache_dir]
      cache.life = opts[:cache_life] if opts[:cache_life]
    end

    # Returns a hash that will be merged into all query strings before
    # sending the request to FRED. This method is used by API Cake.
    def default_query
      { api_key: api_key, file_type: :json } 
    end

    # Forwards all arguments to #get! and converts the JSON response to CSV
    # If the response contains one or more arrays, the first array will be
    # the CSV output. Otherwise, the response itself will be used.
    def get_csv(*args)
      payload = get!(*args)

      if payload.response.code != '200'
        raise Fredric::BadResponse, "#{payload.response.code} #{payload.response.msg}"
      end

      response = payload.parsed_response
      
      data = csv_node response

      header = data.first.keys
      result = CSV.generate do |csv|
        csv << header
        data.each { |row| csv << row.values }
      end

      result
    end

    # Send a request, convert it to CSV and save it to a file.
    def save_csv(file, *args)
      File.write file, get_csv(*args)
    end

    private

    # Determins which part of the data is best suited to be displayed 
    # as CSV. 
    # - In case there is an array in the data (like 'observations' or
    #   'seriess'), it will be returned.
    # - Otherwise, we will use the entire response as a single row CSV.
    def csv_node(data)
      arrays = data.keys.select { |key| data[key].is_a? Array }
      arrays.empty? ? [data] : data[arrays.first]
    end
  end
end