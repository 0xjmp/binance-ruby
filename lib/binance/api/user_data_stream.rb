module Binance
  module Api
    class UserDataStream
      class << self
        # It's recommended to send a ping about every 30 minutes.
        def keepalive!(listen_key: nil, api_key: nil, api_secret_key: nil)
          raise Error.new(message: "listen_key is required") if listen_key.nil?
          Request.send!(api_key_type: :none, method: :put, path: "/api/v1/userDataStream",
                        params: { listenKey: listen_key }, security_type: :user_stream,
                        api_key: api_key, api_secret_key: api_secret_key)
        end

        def start!(api_key: nil, api_secret_key: nil)
          Request.send!(api_key_type: :none, method: :post, path: "/api/v1/userDataStream",
                        security_type: :user_stream, api_key: api_key, api_secret_key: api_secret_key)[:listenKey]
        end

        def stop!(listen_key: nil, api_key: nil, api_secret_key: nil)
          raise Error.new(message: "listen_key is required") if listen_key.nil?
          Request.send!(api_key_type: :none, method: :delete, path: "/api/v1/userDataStream",
                        params: { listenKey: listen_key }, security_type: :user_stream,
                        api_key: api_key, api_secret_key: api_secret_key)
        end
      end
    end
  end
end
