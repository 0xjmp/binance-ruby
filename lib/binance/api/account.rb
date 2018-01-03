module Binance
  module Api
    class Account
      class << self
        def info!(recv_window: 5000)
          timestamp = Configuration.timestamp
          params = { recvWindow: recv_window, timestamp: timestamp } 
          Request.send!(api_key_type: :read_info, path: "/api/v3/account",
                        params: params.delete_if { |key, value| value.nil? },
                        security_type: :user_data)
        end

        def trades!(from_id: nil, limit: 500, recv_window: 5000, symbol: nil)
          raise Error.new(message: "max limit is 500") unless limit <= 500
          raise Error.new(message: "symbol is required") if symbol.nil?
          timestamp = Configuration.timestamp
          params = { fromId: from_id, limit: limit, recvWindow: recv_window, symbol: symbol, timestamp: timestamp }
          Request.send!(api_key_type: :read_info, path: "/api/v3/myTrades",
                        params: params.delete_if { |key, value| value.nil? },
                        security_type: :user_data)
        end
      end
    end
  end
end
