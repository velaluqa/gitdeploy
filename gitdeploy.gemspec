# -*- coding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gitdeploy/version'

Gem::Specification.new do |spec|
  spec.name          = "gitdeploy"
  spec.version       = Gitdeploy::VERSION
  spec.authors       = ["Franz Kißig"]
  spec.email         = ["fkissig@velalu.qa"]
  spec.summary       = %q{Push to a Gitdeploy setup with this Gitdeploy gem}
  spec.description   = %q{With this Gitdeploy gem, you can easily push your build folder to a Gitdeploy setup.}
  spec.homepage      = "https://git.velalu.qa/velaluqa/gitdeploy"
  spec.license       = "Proprietary"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end