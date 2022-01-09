module Binance
  module Api
    class Account
      class << self
        def fees!(recvWindow: nil, api_key: nil, api_secret_key: nil)
          timestamp = Configuration.timestamp
          params = { recvWindow: recvWindow, timestamp: timestamp }
          Request.send!(api_key_type: :read_info, path: "/wapi/v3/assetDetail.html",
                        params: params.delete_if { |key, value| value.nil? },
                        security_type: :user_data, api_key: api_key, api_secret_key: api_secret_key)
        end

        def info!(recvWindow: nil, api_key: nil, api_secret_key: nil)
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

        # @note have not tested this for binance.us yet.
        def withdraw!(coin: nil, withdrawOrderId: nil, network: nil, address: nil, addressTag: nil, amount: nil,
                      transactionFeeFlag: false, name: nil, recvWindow: nil, api_key: nil, api_secret_key: nil)
          raise Error.new(message: "amount is required") if amount.nil?
          raise Error.new(message: "coin is required") if coin.nil?
          raise Error.new(message: "address is required") if address.nil?
          timestamp = Configuration.timestamp
          params = {
            coin: coin, withdrawOrderId: withdrawOrderId, network: network, address: address, timestamp: timestamp,
            addressTag: addressTag, amount: amount, transactionFeeFlag: transactionFeeFlag,
            name: name, recvWindow: recvWindow,
          }
          Request.send!(api_key_type: :withdrawals, path: "/sapi/v1/capital/withdraw/apply",
                        params: params.delete_if { |key, value| value.nil? }, method: :post,
                        security_type: :user_data, api_key: api_key, api_secret_key: api_secret_key)
        end

        # If both startTime and endTime are sent, time between startTime and endTime must be less than 90 days.
        def withdraw_history!(coin: nil, status: nil, offset: nil, limit: nil, startTime: nil, endTime: nil,
                              recvWindow: nil, api_key: nil, api_secret_key: nil)
          timestamp = Configuration.timestamp
          params = {
            coin: coin, status: status, offset: offset, limit: limit, startTime: startTime,
            endTime: endTime, recvWindow: recvWindow, timestamp: timestamp,
          }
          Request.send!(api_key_type: :withdrawals, path: "/sapi/v1/capital/withdraw/history",
                        params: params.delete_if { |key, value| value.nil? }, method: :get,
                        security_type: :user_data, api_key: api_key, api_secret_key: api_secret_key)
        end
      end
    end
  end
end
