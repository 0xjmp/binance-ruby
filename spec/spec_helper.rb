require 'dotenv/load'
require "bundler/setup"
require 'webmock/rspec'
require 'pry'
require "binance/api"

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each { |file| require file } 

WebMock.disable_net_connect!

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include RSpecHelpers
end
