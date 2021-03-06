# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'taipei_ebus/version'

Gem::Specification.new do |spec|
  spec.name          = "taipei_ebus"
  spec.version       = TaipeiEbus::VERSION
  spec.authors       = ["creativeongreen"]
  spec.email         = ["creativeongreen@gmail.com"]
  spec.summary       = %q{Taipei eBus API}
  spec.description   = %q{A few simple interfaces to interactive with Taipei eBus server.}
  spec.homepage      = "https://github.com/creativeongreen/RubyGem-Taipei_ebus"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "nokogiri"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
