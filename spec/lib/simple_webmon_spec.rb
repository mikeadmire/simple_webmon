require 'spec_helper'
require 'simple_webmon'

describe SimpleWebmon do
  it "returns 'OK' when given a URL for a properly responding site" do
    monitor = SimpleWebmon::Monitor.new
    expect(monitor.get("http://www.example.com")).to eq 'OK'
  end
end
