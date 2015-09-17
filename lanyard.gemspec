# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lanyard/version'

Gem::Specification.new do |spec|
  spec.name          = "lanyard"
  spec.version       = Lanyard::VERSION
  spec.authors       = ["Manfred Endres"]
  spec.email         = ["manfred.endres@tslarusso.de"]

  spec.summary       = %q{Handy little tool to work with the OSX toolchain.}
  spec.homepage      = "http://google.de"
  spec.license       = "MIT"

  spec.required_ruby_version = '~> 2.0'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.platform      = Gem::Platform::CURRENT

  spec.add_runtime_dependency "docopt", "~> 0.5"

  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
