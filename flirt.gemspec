# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flirt/version'

Gem::Specification.new do |spec|
  spec.name          = "flirt"
  spec.version       = Flirt::VERSION
  spec.authors       = ["Benjamin Randles-Dunkley"]
  spec.email         = ["ben@chemica.co.uk"]
  spec.summary       = %q{ A brutally simple take on the observer pattern. }
  spec.description   = %q{ Provides a single point for the publication and subscription of events, promoting extreme decoupling. }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
