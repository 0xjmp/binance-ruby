# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "binance/api/version"

Gem::Specification.new do |spec|
  spec.name          = "binance-ruby"
  spec.version       = Binance::Api::VERSION
  spec.authors       = ["Jake Peterson"]
  spec.email         = ["hello@jakenberg.io"]

  spec.summary       = "binance-ruby-#{Binance::Api::VERSION}"
  spec.description   = %q{Ruby wrapper for the Binance API.}
  spec.homepage      = "https://github.com/jakenberg/binance-ruby"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir['lib/**/*.rb']
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'codecov', '~> 0.1'
  spec.add_development_dependency 'dotenv', '~> 2.2'
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'timecop', '~> 0.9'
  spec.add_development_dependency "webmock", '~> 3.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'byebug', '~> 11.1.3'
  spec.add_development_dependency 'simplecov', '~> 0.20.0'

  spec.add_dependency 'awrence', '~> 1.0'
  spec.add_dependency 'httparty', '~> 0.21.0'
  spec.add_dependency 'faye-websocket', '~> 0.11'
  spec.add_dependency 'eventmachine', '~> 1.2'

  spec.add_runtime_dependency 'activesupport', '>= 5.1.0'
end
