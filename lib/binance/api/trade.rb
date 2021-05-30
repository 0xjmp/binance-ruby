module Binance
  module Api
    class Trade
      class << self
        def get_bnb_burn_status!(recvWindow: nil, api_key: nil, api_secret_key: nil)
          timestamp = Configuration.timestamp
          params = { recvWindow: recvWindow, timestamp: timestamp }
          Request.send!(api_key_type: :read_info, path: "/sapi/v1/bnbBurn",
                        params: params.delete_if { |key, value| value.nil? },
                        security_type: :user_data, tld: Configuration.tld, api_key: api_key,
                        api_secret_key: api_secret_key)
        end

        def toggle_bnb_burn!(spot_bnb_burn: true, interest_bnb_burn: false, recvWindow: nil, api_key: nil,
                             api_secret_key: nil)
          timestamp = Configuration.timestamp
          params = { spotBNBBurn: spot_bnb_burn, interestBNBBurn: interest_bnb_burn,
                     recvWindow: recvWindow, timestamp: timestamp }
          Request.send!(api_key_type: :read_info, path: "/sapi/v1/bnbBurn", method: :post,
                        params: params.delete_if { |key, value| value.nil? },
                        security_type: :user_data, tld: Configuration.tld, api_key: api_key,
                        api_secret_key: api_secret_key)
        end
      end
    end
  end
end
