module Binance
  module Api
    module Margin
      class Account
        class << self
          def transfer!(asset: nil, amount: nil, type: nil, recvWindow: nil, api_key: nil, api_secret_key: nil)
            timestamp = Configuration.timestamp
            params = {
              asset: asset, amount: amount, type: type, recvWindow: recvWindow, timestamp: timestamp,
            }.delete_if { |_, value| value.nil? }
            ensure_required_create_keys!(params: params)
            path = "/sapi/v1/margin/transfer"
            Request.send!(api_key_type: :trading, method: :post, path: path,
                          params: params, security_type: :margin, tld: Configuration.tld,
                          api_key: api_key, api_secret_key: api_secret_key)
          end

          private

          def ensure_required_create_keys!(params:)
            keys = required_create_keys.dup
            missing_keys = keys.select { |key| params[key].nil? }
            raise Error.new(message: "required keys are missing: #{missing_keys.join(", ")}") unless missing_keys.empty?
          end

          def required_create_keys
            [:asset, :amount, :type, :timestamp].freeze
          end
        end
      end
    end
  end
end
