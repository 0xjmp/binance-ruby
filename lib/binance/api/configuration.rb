require 'openssl'
require 'base64'

module Binance
  module Api
    class Configuration
      class << self
        def api_key(type:)
          raise Error.new(message: "invalid security_type type: #{type}.") unless api_key_types.include?(type)
          ENV["BINANCE_#{type.to_s.humanize.upcase}_API_KEY"] || ENV["BINANCE_API_KEY"]
        end

        def signed_request_signature(payload:)
          key = ENV['BINANCE_SECRET_KEY']
          raise Error.new(message: "environment variable 'BINANCE_SECRET_KEY' is required " \
            "for signed requests.") unless key
          digest = OpenSSL::Digest::SHA256.new
          OpenSSL::HMAC.hexdigest(digest, key, payload)
        end

        def timestamp
          Time.now.utc.strftime('%s%3N')
        end

        private

        def api_key_types
          [:none, :read_info, :trading, :withdrawals].freeze
        end
      end
    end
  end
end
