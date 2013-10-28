require "simple_webmon/version"
require 'net/http'
require 'uri'

module SimpleWebmon
  class Monitor
    def get(url)
      res = Net::HTTP.get_response(URI.parse(url))
      if res.code == "200"
	return 'OK'
      else
	return 'DOWN'
      end
    end
  end
end
