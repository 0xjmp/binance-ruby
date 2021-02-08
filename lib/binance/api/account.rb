module Binance
  module Api
    class Account
      class << self
        def fees!(recvWindow: 5000, api_key: nil, api_secret_key: nil)
          timestamp = Configuration.timestamp
          params = { recvWindow: recvWindow, timestamp: timestamp }
          Request.send!(api_key_type: :read_info, path: "/wapi/v3/assetDetail.html",
                        params: params.delete_if { |key, value| value.nil? },
                        security_type: :user_data, api_key: api_key, api_secret_key: api_secret_key)
        end

        def info!(recvWindow: 5000, api_key: nil, api_secret_key: nil)
          timestamp = Configuration.timestamp
          params = { recvWindow: recvWindow, timestamp: timestamp }
          Request.send!(api_key_type: :read_info, path: "/api/v3/account",
                        params: params.delete_if { |key, value| value.nil? },
                        security_type: :user_data, api_key: api_key, api_secret_key: api_secret_key)
        end

        def trades!(fromId: nil, limit: 500, recvWindow: 5000, symbol: nil, api_key: nil, api_secret_key: nil)
          raise Error.new(message: "max limit is 500") unless limit <= 500
          raise Error.new(message: "symbol is required") if symbol.nil?
          timestamp = Configuration.timestamp
          params = { fromId: fromId, limit: limit, recvWindow: recvWindow, symbol: symbol, timestamp: timestamp }
          Request.send!(api_key_type: :read_info, path: "/api/v3/myTrades",
                        params: params.delete_if { |key, value| value.nil? },
                        security_type: :user_data, api_key: api_key, api_secret_key: api_secret_key)
        end
      end
    end
  end
end
