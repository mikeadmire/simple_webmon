require "simple_webmon/version"
require 'net/http'
require 'uri'
require 'timeout'

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

    def check(url, timeout_time=30)
      status = ""
      begin
	Timeout::timeout(timeout_time) do
	  status = get(url)
	end
      rescue
	status = 'ERROR: TIMEOUT'
      end
      status
    end

  end
end
