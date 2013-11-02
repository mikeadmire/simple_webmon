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

    FakeWeb.register_uri(:get, "http://notfound.example.com/",
			 body: "Page Not Found",
			 status: ["404", "Not Found"])

    FakeWeb.register_uri(:get, "http://slow.example.com/",
			 response: sleep(10))
  end

  let(:monitor) { SimpleWebmon::Monitor.new }

  describe '.get_status' do
    it "returns 'OK' when given a URL for a properly responding site" do
      expect(monitor.get_status("http://good.example.com/")).to eq 'OK'
    end

    it "returns correct status message when given a URL that responds with an Internal Server Error" do
      expect(monitor.get_status("http://servererror.example.com/")).to eq 'Internal Server Error'
    end
  end

  describe '.check' do

    it "returns 'ERROR' and timeout message when given a URL that doesn't respond in time" do
      expect(monitor.check("http://slow.example.com/", 1)).to eq 'ERROR: Timeout'
    end

    it "returns 'OK' when given a URL that responds correctly" do
      expect(monitor.check("http://good.example.com/")).to eq 'OK'
    end

    it "returns 'ERROR' and the correct status message when given a URL that fails" do
      expect(monitor.check("http://servererror.example.com/")).to eq 'ERROR: Internal Server Error'
    end

    it "returns 'ERROR' and the correct status message when given a URL that fails" do
      expect(monitor.check("http://notfound.example.com/")).to eq 'ERROR: Not Found'
    end

  end

  describe '.check_all' do
    let(:server_list) {
      [["http://good.example.com"],
       ["http://slow.example.com", 1],
       ["http://servererror.example.com"],
       ["http://notfound.example.com"]]
    }

    it "accepts an array of servers and returns a hash" do
      expect(monitor.check_all(server_list)).to be_an(Hash)
    end

    it "returned array has hostname and check response" do
      responses = monitor.check_all(server_list)
      expect(responses[server_list[0][0]]).to eq 'OK'
    end

    it "passes the timeout parameter along to check" do
      responses = monitor.check_all(server_list)
      expect(responses[server_list[1][0]]).to eq 'ERROR: Timeout'
    end

    it "passes hash with correct status message for each element passed in" do
      responses = monitor.check_all(server_list)
      expect(responses[server_list[0][0]]).to eq 'OK'
      expect(responses[server_list[1][0]]).to eq 'ERROR: Timeout'
      expect(responses[server_list[2][0]]).to eq 'ERROR: Internal Server Error'
      expect(responses[server_list[3][0]]).to eq 'ERROR: Not Found'
    end
  end

end
