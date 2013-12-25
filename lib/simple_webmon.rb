require "simple_webmon/version"
require 'net/http'
require 'uri'
require 'timeout'

module SimpleWebmon

  class Site
    attr_reader :url, :timeout
    attr_accessor :status

    def initialize(url, timeout = 30)
      @url = url
      @timeout = timeout
    end
  end

  class Monitor

    def get_status(url)
      res = Net::HTTP.get_response(URI.parse(url))
      if res.code == "301"
	res = Net::HTTP.get_response(URI.parse(res.header['location']))
      end
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

    def check_sites(site_list)
      site_list.each do |site|
	site.status = check(site.url, site.timeout)
      end
      site_list
    end

  end
end
