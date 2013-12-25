require 'spec_helper'
require 'simple_webmon'

describe SimpleWebmon do
  context 'Monitor' do
    before(:all) do
      FakeWeb.allow_net_connect = false

      FakeWeb.register_uri(:get, "http://good.example.com",
			   body: "Hello World!")

      FakeWeb.register_uri(:get, "http://servererror.example.com",
			   body: "Internal Server Error",
			   status: ["500", "Internal Server Error"])

      FakeWeb.register_uri(:get, "http://notfound.example.com",
			   body: "Page Not Found",
			   status: ["404", "Not Found"])

      FakeWeb.register_uri(:get, "https://redirect.example.com",
			   status: ["301", "Moved Permanently"],
			   location: "http://good.example.com")
    end

    let(:monitor) { SimpleWebmon::Monitor.new }

    describe '.get_response' do
      it "returns valid response when given a URL for a properly responding site" do
	expect(monitor.get_response("http://good.example.com").code).to eq '200'
      end

      it "returns correct status message when given a URL that responds with an Internal Server Error" do
	expect(monitor.get_response("http://servererror.example.com").code).to eq '500'
      end
    end

    describe '.check' do
      it "returns '200' when given a URL that responds correctly" do
	expect(monitor.check(SimpleWebmon::Site.new("http://good.example.com")).status).to eq ['200', 'OK']
      end

      it "returns the correct status message when given a URL that fails" do
	expect(monitor.check(SimpleWebmon::Site.new("http://servererror.example.com")).status).to eq ['500', 'Internal Server Error']
      end

      it "returns and the correct status message when given a URL that fails" do
	expect(monitor.check(SimpleWebmon::Site.new("http://notfound.example.com")).status).to eq ['404', 'Not Found']
      end

      it "returns '200' when given a URL that redirects to a site that responds correctly" do
	expect(monitor.check(SimpleWebmon::Site.new("https://redirect.example.com")).status).to eq ['200', 'OK']
      end

    end

    describe '.check_sites' do
      let(:sites) {
	[
	  SimpleWebmon::Site.new("http://good.example.com"),
	  SimpleWebmon::Site.new("http://servererror.example.com"),
	  SimpleWebmon::Site.new("http://notfound.example.com")
	]
      }

      it "accepts an array of Site objects and returns the same" do
	expect(monitor.check_sites(sites)).to be_an(Array)
      end

      it "returned array has hostname and check response" do
	response = monitor.check_sites(sites)
	expect(response[0].code).to eq '200'
      end

      it "returns correct status messages for each element passed in" do
	response = monitor.check_sites(sites)
	expect(response[0].code).to eq '200'
	expect(response[1].code).to eq '500'
	expect(response[2].code).to eq '404'
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
