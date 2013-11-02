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

    def check_all(server_list)
      responses = {}
      server_list.each do |server|
	responses[server[0]] = check(server[0], server[1])
      end
      responses
    end

  end
end
