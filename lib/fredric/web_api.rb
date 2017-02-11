require 'uri'
require 'open-uri'
require 'webcache'

module Fredric

  # A general purpose HTTP wrapper. This is poor man's HTTParty with
  # dynamic methods.
  class WebAPI
    attr_reader :base_url, :after_request_block, :last_error
    attr_accessor :debug, :format

    def initialize(base_url)
      @base_url = base_url
    end

    # Allow using any method as the first segment of the path
    # object.user 'details' becomes object.get 'user/details'
    def method_missing(method_sym, *arguments, &_block)
      get "/#{method_sym}", *arguments
    end

    # Add one or more parameter to the default query string. Good for 
    # adding keys that are always needed, like API keys.
    def param(params)
      params.each do |key, value|
        default_params[key] = value
        default_params.delete key if value.nil?
      end
    end

    def cache
      @cache ||= WebCache.new
    end

    # Set a block to be executed after the request. This is called only when
    # using `get` and not when using `get!`. Good for JSON decoding, for 
    # example.
    def after_request(&block)
      @after_request_block = block
    end

    # Return the response from the API. 
    def get(path, extra=nil, params={})
      response = get! path, extra, params
      response = after_request_block.call(response) if after_request_block
      response
    end

    # Return the response from the API, without executing the after_request
    # block.
    def get!(path, extra=nil, params={})
      if extra.is_a?(Hash) and params.empty?
        params = extra
        extra = nil
      end

      path = "#{path}/#{extra}" if extra
      url = construct_url path, params

      return url if debug 

      response = cache.get(url)
      @last_error = response.error
      response.content
    end

    # Save the response from the API to a file.
    def save(filename, path, params={})
      response = get! path, nil, params
      return response if debug
      File.write filename, response.to_s
    end

    # Build a URL from all its explicit and implicit pieces.
    def construct_url(path, params={})
      path = "/#{path}" unless path[0] == '/'
      all_params = default_params.merge params
      result = "#{base_url}#{path}"
      result = "#{result}.#{format}" if format && File.extname(result) == ''
      unless all_params.empty?
        all_params = URI.encode_www_form all_params
        result = "#{result}?#{all_params}"
      end
      result
    end

    def default_params
      @default_params ||= {}
    end

  end
end
