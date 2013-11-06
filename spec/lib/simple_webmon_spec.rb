require 'spec_helper'
require 'simple_webmon'

describe SimpleWebmon do
  context 'Monitor' do
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

    describe '.check_sites' do
      let(:sites) {
	[
	  SimpleWebmon::Site.new("http://good.example.com"),
	  SimpleWebmon::Site.new("http://slow.example.com", 1),
	  SimpleWebmon::Site.new("http://servererror.example.com"),
	  SimpleWebmon::Site.new("http://notfound.example.com")
	]
      }

      it "accepts an array of Site objects and returns the same" do
	expect(monitor.check_sites(sites)).to be_an(Array)
      end

      it "returned array has hostname and check response" do
	response = monitor.check_sites(sites)
	expect(response[0].response).to eq 'OK'
      end

      it "passes the timeout parameter along to check" do
	response = monitor.check_sites(sites)
	expect(response[1].response).to eq 'ERROR: Timeout'
      end

      it "returns correct status messages for each element passed in" do
	response = monitor.check_sites(sites)
	expect(response[0].response).to eq 'OK'
	expect(response[1].response).to eq 'ERROR: Timeout'
	expect(response[2].response).to eq 'ERROR: Internal Server Error'
	expect(response[3].response).to eq 'ERROR: Not Found'
      end
    end
  end

  describe 'Site' do
    it "can be created" do
      expect(SimpleWebmon::Site.new("http://good.example.com")).to be_a(SimpleWebmon::Site)
    end

    it "stores a site URL and timeout settings" do
      site = SimpleWebmon::Site.new("http://good.example.com", 10)
      expect(site.url).to eq("http://good.example.com")
      expect(site.timeout).to eq(10)
    end
  end
end
