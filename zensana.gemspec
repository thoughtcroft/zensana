# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zensana/version'

Gem::Specification.new do |spec|
  spec.name          = "zensana"
  spec.version       = Zensana::VERSION
  spec.authors       = ["Warren Bain"]
  spec.email         = ["warren@thoughtcroft.com"]

  spec.summary       = %q{Import Asana tasks into ZenDesk}
  spec.description   = %q{Command line tool for taking Asana export JSON and importing into ZenDesk using API}
  spec.homepage      = ""

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "thor"
end
