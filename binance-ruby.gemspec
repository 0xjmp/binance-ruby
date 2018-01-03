# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "binance/api/version"

Gem::Specification.new do |spec|
  spec.name          = "binance-ruby"
  spec.version       = Binance::Api::VERSION
  spec.authors       = ["Jake Peterson"]
  spec.email         = ["hello@jakenberg.io"]

  spec.summary       = %q{Official Ruby gem for the Binance APIs and Streams.}
  spec.description   = %q{
    - Official Announcements regarding changes, downtime, etc. to the API and Streams will be reported here: https://t.me/binance_api_announcements
    - Streams, endpoints, parameters, payloads, etc. decscribed in the documents in this repository are considered official and supported.
  }
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", '~> 3.0'
  spec.add_development_dependency 'pry', '~> 0.11.0'
  spec.add_development_dependency 'dotenv-rails', '~> 2.2.0'
  spec.add_development_dependency 'codecov', '~> 0.1'

  spec.add_dependency 'httparty', '~> 0.15'
  spec.add_dependency 'activesupport-core-ext', '~> 4.0.0'
end
