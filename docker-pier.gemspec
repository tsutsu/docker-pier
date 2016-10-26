# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docker-pier/version'

Gem::Specification.new do |spec|
  spec.name          = "docker-pier"
  spec.version       = DockerPier::VERSION
  spec.authors       = ["Levi Aul"]
  spec.email         = ["levi@leviaul.com"]

  spec.summary       = %q{An alternative Docker client for dedicated Docker Swarm clusters}
  spec.homepage      = "https://github.com/tsutsu/docker-pier"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.3'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency     "fog-libvirt", "~> 0.3.0"
  spec.add_runtime_dependency     "docker-api", "~> 1.32", ">= 1.32.1"
  spec.add_runtime_dependency     "net-ssh", "~> 3.2"
  spec.add_runtime_dependency     "net-scp", "~> 1.2", ">= 1.2.1"
  spec.add_runtime_dependency     "highline", "~> 1.7", ">= 1.7.8"
  spec.add_runtime_dependency     "pry", "~> 0.10.4"
  spec.add_runtime_dependency     "main", "~> 6.2", ">= 6.2.1"
  spec.add_runtime_dependency     "sequel", "~> 4.39"
  spec.add_runtime_dependency     "amalgalite", "~> 1.5"
  spec.add_runtime_dependency     "color", "~> 1.8"
  spec.add_runtime_dependency     "paint", "~> 1.0", ">= 1.0.1"
end
