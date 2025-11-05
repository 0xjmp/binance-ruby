module Binance
  module Api
    module Futures
      class Account
        class << self
          def balance!
            params = { timestamp: Configuration.timestamp }
            Request.send!(api_section: :futures, path: "/fapi/v2/balance", api_key_type: :read_info,
                          security_type: :user_data, params: params)
          end
        end
      end
    end
  end
end
