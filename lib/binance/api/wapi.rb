module Binance
  module Api
    module Wapi
      class << self
        def withdraw!(asset: nil, address: nil, addressTag: nil, amount: nil, name: nil, recvWindow: nil)
          timestamp = Binance::Api::Configuration.timestamp
          params = {
            asset: asset, address: address,
            addressTag: addressTag, amount: amount, name: name,
            recvWindow: recvWindow, timestamp: timestamp
          }.delete_if { |key, value| value.nil? }

          ensure_required_keys!(params: params, required_keys: [:asset, :address, :amount, :timestamp])

          path = "/wapi/v3/withdraw.html"
          Request.send!(api_key_type: :trading, method: :post, path: path,
                        params: params, security_type: :withdraw)
        end
      end
    end
  end
end
