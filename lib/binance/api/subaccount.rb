module Binance
  module Api
    module Wapi
      module Subaccount
        class << self
          def list!(recvWindow: nil)
            timestamp = Binance::Api::Configuration.timestamp
            params = {
              recvWindow: recvWindow, timestamp: timestamp
            }.delete_if { |key, value| value.nil? }

            path = "/wapi/v3/sub-account/list.html"
            Request.send!(api_key_type: :trading, method: :post, path: path,
                          params: params, security_type: :withdraw)
          end

          def history!(recvWindow: nil)
            timestamp = Binance::Api::Configuration.timestamp
            params = {
              recvWindow: recvWindow, timestamp: timestamp
            }.delete_if { |key, value| value.nil? }

            path = "/wapi/v3/sub-account/history.html"
            Request.send!(api_key_type: :trading, method: :post, path: path,
                          params: params, security_type: :withdraw)
          end

          def assets!(email: nil, recvWindow: nil)
            timestamp = Binance::Api::Configuration.timestamp
            params = {
              email: email, recvWindow: recvWindow, timestamp: timestamp
            }.delete_if { |key, value| value.nil? }

            ensure_required_keys!(params: params, required_keys: %i[email])

            path = "/wapi/v3/sub-account/assets.html"
            Request.send!(api_key_type: :trading, method: :post, path: path,
                          params: params, security_type: :withdraw)
          end

          def transfers!(fromEmail: nil, toEmail: nil, asset: nil, amount: nil, recvWindow: nil)
            timestamp = Binance::Api::Configuration.timestamp
            params = {
              fromEmail: fromEmail, toEmail: toEmail, asset: asset, amount: amount,
              recvWindow: recvWindow, timestamp: timestamp
            }.delete_if { |key, value| value.nil? }

            ensure_required_keys!(params: params, required_keys: %i[fromEmail toEmail asset amount])

            path = "/wapi/v3/sub-account/transfer.html"
            Request.send!(api_key_type: :trading, method: :post, path: path,
                          params: params, security_type: :withdraw)
          end

          private def ensure_required_keys!(params:, required_keys:)
            missing_keys = required_keys.select { |key| params[key].nil? }
            raise Error.new(message: "required keys are missing: #{missing_keys.join(', ')}") unless missing_keys.empty?
          end
        end
      end
    end
  end
end
