require "simple_webmon/version"
require 'net/http'
require 'uri'
require 'timeout'

module SimpleWebmon
  class Monitor

    def get_status(url)
      res = Net::HTTP.get_response(URI.parse(url))
      res.message
    end

    def check(url, timeout_time=30)
      status = ""
      begin
	Timeout::timeout(timeout_time) do
	  status = get_status(url)
	end
      rescue
	status = 'Timeout'
      end
      status == 'OK' ? status : "ERROR: #{status}"
    end

  end
end
