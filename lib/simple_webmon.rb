require "simple_webmon/version"
require 'net/http'
require 'uri'
require 'timeout'

module SimpleWebmon

  class Site
    attr_reader :url, :timeout
    attr_accessor :code, :message

    def initialize(url, timeout = 30)
      @url = url
      @timeout = timeout
    end

    def status
      [self.code, self.message]
    end
  end

  class Monitor

    def get_response(url)
      res = Net::HTTP.get_response(URI.parse(url))
      if res.code == "301"
	res = Net::HTTP.get_response(URI.parse(res.header['location']))
      end
      res
    end

    def check(site)
      begin
	Timeout::timeout(site.timeout) do
	  response = get_response(site.url)
	  site.code = response.code
	  site.message = response.message
	end
      rescue Timeout::Error
	site.code = '998'
	site.message = 'Request Timed Out'
      rescue Exception => e
	site.code = '999'
	site.message = e
      end
      site
    end

    def check_sites(site_list)
      site_list.each do |site|
	check(site)
      end
      site_list
    end

  end
end
