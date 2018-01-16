require 'openssl'
require 'base64'

module Binance
  module Api
    class Configuration
      class << self
        attr_writer :api_key, :read_info_api_key, :trading_api_key, :withdrawals_api_key
        attr_writer :secret_key
        
        def api_key(type: nil)
          raise Error.new(message: "invalid security_type type: #{type}.") unless type.nil? || api_key_types.include?(type)
          instance_api_key(type: type) || ENV["BINANCE_#{type.to_s.humanize.upcase}_API_KEY"] ||
          instance_api_key             || ENV["BINANCE_API_KEY"]
        end
        
        def secret_key
          instance_variable_get("@secret_key") || ENV['BINANCE_SECRET_KEY']
        end

        def signed_request_signature(payload:)
          raise Error.new(message: "environment variable 'BINANCE_SECRET_KEY' is required " \
            "for signed requests.") unless secret_key
          digest = OpenSSL::Digest::SHA256.new
          OpenSSL::HMAC.hexdigest(digest, secret_key, payload)
        end

        def timestamp
          Time.now.utc.strftime('%s%3N')
        end

        private

        def api_key_types
          [:none, :read_info, :trading, :withdrawals].freeze
        end

        def instance_api_key(type: nil)
          var = "#{type.to_s.downcase}_api_key".sub(/^\_/, '')
          instance_variable_get('@' + var)
        end
              end
    end
  end
end
