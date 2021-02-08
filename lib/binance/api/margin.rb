module Binance
  module Api
    module Margin
      class << self
        # Your Margin Wallet balance determines the amount of funds you can borrow,
        # following a fixed rate of 5:1 (5x).
        def borrow!(asset: nil, amount: nil, recvWindow: nil, api_key: nil, api_secret_key: nil)
          timestamp = Configuration.timestamp
          params = {
            asset: asset, amount: amount, recvWindow: recvWindow, timestamp: timestamp,
          }.delete_if { |_, value| value.nil? }
          ensure_required_keys!(params: params)
          path = "/sapi/v1/margin/loan"
          Request.send!(api_key_type: :trading, method: :post, path: path,
                        params: params, security_type: :margin, tld: Configuration.tld,
                        api_key: api_key, api_secret_key: api_secret_key)
        end

        def repay!(asset: nil, isIsolated: nil, amount: nil, recvWindow: nil, api_key: nil, api_secret_key: nil)
          timestamp = Configuration.timestamp
          params = {
            asset: asset, amount: amount, recvWindow: recvWindow, timestamp: timestamp,
          }.delete_if { |_, value| value.nil? }
          ensure_required_keys!(params: params)
          path = "/sapi/v1/margin/repay"
          Request.send!(api_key_type: :trading, method: :post, path: path,
                        params: params, security_type: :margin, tld: Configuration.tld,
                        api_key: api_key, api_secret_key: api_secret_key)
        end

        private

        def ensure_required_keys!(params:)
          keys = required_margin_keys.dup
          missing_keys = keys.select { |key| params[key].nil? }
          raise Error.new(message: "required keys are missing: #{missing_keys.join(", ")}") unless missing_keys.empty?
        end

        def required_margin_keys
          [:asset, :amount, :timestamp].freeze
        end
      end
    end
  end
end
