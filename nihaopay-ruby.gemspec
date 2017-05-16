lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nihaopay/version'

Gem::Specification.new do |s|
  s.name          = 'nihaopay-ruby'
  s.version       = Nihaopay::VERSION
  s.authors       = ['JagdeepSingh', 'Johnny Shields']
  s.email         = ['jagdeepsingh.fof@gmail.com', 'johnny.shields@gmail.com']
  s.description   = 'Ruby library for Nihaopay payment gateway API'
  s.summary       = 'Ruby library for Nihaopay payment gateway API'

  s.files         = Dir['{lib,spec}/**/*'] + %w[README.md CHANGELOG.md LICENSE]
  s.test_files    = s.files.grep(%r{^spec/})
  s.require_paths = ['lib']

  s.add_dependency 'json', '>= 1'
  s.add_dependency 'httparty', '>= 0.13'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop', '>= 0.46'
  s.add_development_dependency 'rspec', '>= 3'
  s.add_development_dependency 'tzinfo-data'
end
