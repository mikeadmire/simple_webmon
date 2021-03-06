# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_webmon/version'

Gem::Specification.new do |spec|
  spec.name          = "simple_webmon"
  spec.version       = SimpleWebmon::VERSION
  spec.authors       = ["Mike Admire"]
  spec.email         = ["mike@mikeadmire.com"]
  spec.description   = %q{Simple website monitoring.}
  spec.summary       = %q{SimpleWebmon is a Ruby gem that makes it easy to setup a basic website monitor.}
  spec.homepage      = "https://github.com/mikeadmire/simple_webmon"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakeweb"
end
