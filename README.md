FRED API Library and Command Line
==================================================

[![Gem](https://img.shields.io/gem/v/fredric.svg?style=flat-square)](https://rubygems.org/gems/fredric)
[![Travis](https://img.shields.io/travis/DannyBen/fredric.svg?style=flat-square)](https://travis-ci.org/DannyBen/fredric)
[![Code Climate](https://img.shields.io/codeclimate/github/DannyBen/fredric.svg?style=flat-square)](https://codeclimate.com/github/DannyBen/fredric)
[![Gemnasium](https://img.shields.io/gemnasium/DannyBen/fredric.svg?style=flat-square)](https://gemnasium.com/DannyBen/fredric)

---

This gem provides both a Ruby library and a command line interface for the 
[FRED][1] data service.

---


Install
--------------------------------------------------

```
$ gem install fredric
```

Or with bundler:

```ruby
gem 'fredric'
```


Features
--------------------------------------------------

* Easy to use interface.
* Use as a library or through the command line.
* Access any FRED endpoint and option directly.
* Display output as JSON, XML or CSV.
* Save output to a file as JSON, XML or CSV.
* Includes a built in file cache (disabled by default).


Usage
--------------------------------------------------

First, require and initialize with your [FRED API Key][4].

```ruby
require 'fredric'
fredric = Fredric::API.new 'your-api-key'
```

Now, you can access any FRED endpoint with any optional parameter, like
this:

```ruby
result = fredric.get "series/observations", series_id: 'GNPCA'
```

In addition, for convenience, you can use the first part of the endpoint as
a method name, like this:

```ruby
result = fredric.series 'observations', series_id: 'GNPCA'
```

In other words, these calls are the same:

```ruby
fredric.get 'endpoint', param: value
fredric.endpoint, param: value
```

as well as these two:

```ruby
fredric.get 'endpoint/sub', param: value
fredric.endpoint 'sub', param: value
```

By default, you will get a ruby hash in return. If you wish to get the raw
output, you can use the `get!` method:

```ruby
result = fredric.get! "series/ovservations", series_id: 'GNPCA'
# => JSON string
```

You can get the response as CSV by calling `get_csv`:

```ruby
result = fredric.get_csv "series/overvations", series_id: 'GNPCA'
# => CSV string
```

Fredric automatically decides which part of the data to convert to CSV.
When there is an array in the response (for example, in the case of 
`observations`), it will be used as the CSV data. Otherwise, the entire
response will be treated as a single-row CSV.

To save the output directly to a file, use the `save` method:

```ruby
fredric.save "filename.json", "series/overvations", series_id: 'GNPCA'
```

Or, to save CSV, use the `save_csv` method:

```ruby
fredric.save_csv "filename.csv", "series/overvations", series_id: 'GNPCA'
```

Debugging your request and adding "sticky" query parameters that stay with
you for the following requests is also easy:

```ruby
fredric.debug = true
fredric.param limit: 10, sort_order: :asc, file_type: :xml
puts fredric.series 'observations', series_id: 'GNPCA'
# => https://api.stlouisfed.org/fred/series/observations?api_key=...&file_type=xml&limit=10&sort_order=asc&series_id=GNPCA

fredric.param sort_order: nil # remove param
```


Command Line
--------------------------------------------------

The command line utility `fred` acts in a similar way. To set your 
FRED API Key, simply set it in the environment variables 
`FREDRIC_KEY`:

`$ export FREDRIC_KEY=y0urAP1k3y`

These commands are available:

`$ fred get [--csv] PATH [PARAMS...]` - print the output.  
`$ fred pretty PATH [PARAMS...]` - print a pretty JSON.  
`$ fred see PATH [PARAMS...]` - print a colored output.  
`$ fred url PATH [PARAMS...]` - show the constructed URL.  
`$ fred save [--csv] FILE PATH [PARAMS...]` - save the output to a file.  

Run `fred --help` for more information, or view the [full usage help][2].

Examples:

```bash
# Shows details about a data series
$ fred see series series_id:GNPCA

# Shows data as CSV
$ fred get --csv series/observations series_id:GNPCA

# Pass arguments that require spaces
$ fred see series/search "search_text:consumer price index" limit:3

# Saves a file
$ fred save --csv result.csv series/search search_text:cpi limit:3

# Shows the URL that Fredric has constructed, good for debugging
$ fred url series/observations query:interest limit:5
# => https://api.stlouisfed.org/fred/series/observations?api_key=ce1e45e6551de5db555a09b88d23682f&file_type=json&query=interest&limit=5

```


Caching
--------------------------------------------------

We are using the [WebCache][3] gem for automatic HTTP caching.
To take the path of least surprises, caching is disabled by default.

You can enable and customize it by either passing options on 
initialization, or by accessing the `WebCache` object directly at 
a later stage.

```ruby
fredric = Fredric::API.new 'apikey', use_cache: true
fredric = Fredric::API.new 'apikey', use_cache: true, cache_dir: 'tmp'
fredric = Fredric::API.new 'apikey', use_cache: true, cache_life: 120

# or 

fredric = Fredric::API.new 'apikey'
fredric.cache.enable
fredric.cache.dir = 'tmp/cache'   # Change cache folder
fredric.cache.life = 120          # Change cache life to 2 minutes
```

To enable caching for the command line, simply set one or both of 
these environment variables:

```
$ export FREDRIC_CACHE_DIR=cache   # default: 'cache'
$ export FREDRIC_CACHE_LIFE=120    # default: 3600 (1 hour)
$ fredric get indices
# => This call will be cached
```


[1]: https://research.stlouisfed.org/docs/api/fred/
[2]: https://github.com/DannyBen/fredric/blob/master/lib/fredric/docopt.txt
[3]: https://github.com/DannyBen/webcache
[4]: https://research.stlouisfed.org/docs/api/api_key.html

