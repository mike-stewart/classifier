# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'classifier/version'

Gem::Specification.new do |spec|
  spec.name          = "classifier"
  spec.version       = Classifier::VERSION
  spec.authors       = ["Lucas Carlson, Mike Stewart"]
  spec.summary       = "A general classifier module to allow Bayesian and other types of classifications."
  spec.homepage      = ""
  spec.license       = "GNU LGPL"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
