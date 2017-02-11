require 'singleton'
require 'docopt'
require 'json'
require 'awesome_print'

module Fredric

  # Handles the command line interface
  class CommandLine
    include Singleton

    # Gets an array of arguments (e.g. ARGV), executes the command if valid
    # and shows usage patterns / help otherwise.
    def execute(argv=[])
      doc = File.read File.dirname(__FILE__) + '/docopt.txt'
      begin
        args = Docopt::docopt(doc, argv: argv, version: VERSION)
        handle args
      rescue Docopt::Exit, Fredric::MissingAuth => e
        puts e.message
      end
    end

    def fredric
      @fredric ||= fredric!
    end

    private

    attr_reader :path, :params, :file, :csv

    def fredric!
      Fredric::API.new api_key, options
    end

    # Called when the arguments match one of the usage patterns. Will 
    # delegate action to other, more specialized methods.
    def handle(args)
      @path   = args['PATH']
      @params = translate_params args['PARAMS']
      @file   = args['FILE']
      @csv    = args['--csv']

      unless api_key
        raise Fredric::MissingAuth, "Missing Authentication\nPlease set FREDRIC_KEY=y0urAP1k3y"
      end
      
      return get    if args['get']
      return pretty if args['pretty']
      return see    if args['see']
      return url    if args['url']
      return save   if args['save']
    end

    def get
      if csv
        puts fredric.get_csv path, params
      else
        puts fredric.get! path, params
      end
    end

    def save
      if csv
        success = fredric.save_csv file, path, params
      else
        success = fredric.save file, path, params
      end
      puts success ? "Saved #{file}" : "Saving failed"
    end

    def pretty
      response = fredric.get path, params
      puts JSON.pretty_generate response
    end

    def see
      ap fredric.get path, params
    end

    def url
      fredric.debug = true
      puts fredric.get path, params
      fredric.debug = false
    end

    # Convert a params array like [key:value, key:value] to a hash like
    # {key: value, key: value}
    def translate_params(pairs)
      result = {}
      return result if pairs.empty?
      pairs.each do |pair|
        key, value = pair.split ':'
        result[key.to_sym] = value
      end
      result
    end

    def options
      result = {}
      return result unless cache_dir || cache_life
      
      result[:use_cache] = true
      result[:cache_dir] = cache_dir if cache_dir
      result[:cache_life] = cache_life.to_i if cache_life
      result
    end

    def api_key
      ENV['FREDRIC_KEY']
    end

    def cache_dir
      ENV['FREDRIC_CACHE_DIR']
    end

    def cache_life
      ENV['FREDRIC_CACHE_LIFE']
    end

  end
end
