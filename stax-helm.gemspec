# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stax/helm/version'

Gem::Specification.new do |spec|
  spec.name          = 'stax-helm'
  spec.version       = Stax::Helm::VERSION
  spec.authors       = ['Richard Lister']
  spec.email         = ['rlister@gmail.com']

  spec.summary       = %q{Control helm charts with stax.}
  spec.description   = %q{Stax is a flexible set of ruby classes for wrangling your cloudformation stacks.}
  spec.homepage      = 'https://github.com/rlister/stax-helm'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'rake', '>= 12.3.3'

  spec.add_dependency('stax')
end
