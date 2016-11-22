lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nihaopay/version'

Gem::Specification.new do |s|
  s.name          = 'nihaopay'
  s.version       = Nihaopay::VERSION
  s.authors       = ['JagdeepSingh']
  s.email         = ['jagdeepsingh.fof@gmail.com']
  s.description   = 'Library to integrate Nihaopay Payment Gateway API'
  s.summary       = 'Library to integrate Nihaopay Payment Gateway API'

  s.files         = Dir['{lib,spec}/**/*'] + %w(README.md CHANGELOG.md LICENSE)
  s.test_files    = s.files.grep(%r{^spec/})
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '>= 3.2'
  s.add_dependency 'httparty', '>= 0.13'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rspec', '>= 3'
  s.add_development_dependency 'tzinfo-data'
end
