require 'json'
require 'csv'

module Fredric
  # Provides access to all the FRED API endpoints
  class API < WebAPI
    attr_reader :api_key, :opts

    def initialize(api_key, opts={})
      @api_key = api_key

      defaults = {
        use_cache: false,
        cache_dir: nil,
        cache_life: nil,
        base_url: "https://api.stlouisfed.org/fred"
      }

      opts = defaults.merge! opts
      @opts = opts

      cache.disable unless opts[:use_cache]
      cache.dir = opts[:cache_dir] if opts[:cache_dir]
      cache.life = opts[:cache_life] if opts[:cache_life]

      param api_key: api_key if api_key
      param file_type: :json

      after_request do |response| 
        begin
          JSON.parse response, symbolize_names: true
        rescue JSON::ParserError
          response
        end
      end
      
      super opts[:base_url]
    end

    def get_csv(*args)
      response = get *args

      raise Fredric::BadResponse, "API said '#{response}'" if response.is_a? String
      raise Fredric::BadResponse, "Got a #{response.class}, expected a Hash" unless response.is_a? Hash
      
      data = csv_node response

      header = data.first.keys
      result = CSV.generate do |csv|
        csv << header
        data.each { |row| csv << row.values }
      end

      result
    end

    def save_csv(file, *args)
      data = get_csv *args
      File.write file, data
    end

    private

    # Determins which part of the data is best suited to be displayed 
    # as CSV. 
    # - In case there is an array in the data (like 'observations' or
    #   'seriess'), it will be returned
    # - Otherwise, we will use the entire response as a single row CSV
    def csv_node(data)
      arrays = data.keys.select { |key| data[key].is_a? Array }
      arrays.empty? ? [data] : data[arrays.first]
    end
  end
end