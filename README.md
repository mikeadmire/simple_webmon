# SimpleWebmon

SimpleWebmon is a Ruby gem that makes it easy to setup a basic website monitor.

## Installation

Add this line to your application's Gemfile:

    gem 'simple_webmon'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_webmon

## Usage

    require 'simple_webmon'

    monitor = SimpleWebmon::Monitor.new
    monitor.check("http://www.example.com")

The default timeout is 30 seconds. An optional second parameter can be passed
to override this. Value is in seconds.

    monitor.check("http://www.example.com", 60)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
