require 'spec_helper'
require 'simple_webmon'

describe SimpleWebmon do
  before(:all) do
    FakeWeb.allow_net_connect = false

    FakeWeb.register_uri(:get, "http://good.example.com/",
			 body: "Hello World!")

    FakeWeb.register_uri(:get, "http://servererror.example.com/",
			 body: "Internal Server Error",
			 status: ["500", "Internal Server Error"])

    FakeWeb.register_uri(:get, "http://slow.example.com/",
			 response: sleep(10))
  end

  it "returns 'OK' when given a URL for a properly responding site" do
    monitor = SimpleWebmon::Monitor.new
    expect(monitor.get_status("http://good.example.com/")).to eq 'OK'
  end

  it "returns 'DOWN' when given a URL that responds with an Internal Server Error" do
    monitor = SimpleWebmon::Monitor.new
    expect(monitor.get_status("http://servererror.example.com/")).to eq 'Internal Server Error'
  end

  it "returns 'DOWN' when given a URL that doesn't respond in time" do
    monitor = SimpleWebmon::Monitor.new
    expect(monitor.check("http://slow.example.com/", 1)).to eq 'ERROR: Timeout'
  end
end
