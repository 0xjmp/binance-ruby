module Binance
  module Api
    class MarketStream
      class << self
        def connect(api_key: nil, api_secret_key: nil)
          EM.run {
            ws = Faye::WebSocket::Client.new("wss://stream.binance.com:9443/stream?streams=<streamName1>/<streamName2>/<streamName3>")

            ws.on :open do |event|
              p [:open]
              ws.send("Hello, world!")
            end

            ws.on :message do |event|
              p [:message, event.data]
            end

            ws.on :close do |event|
              p [:close, event.code, event.reason]
              ws = nil
            end
          }
        end

        # It's recommended to send a ping about every 30 minutes.
        def keepalive!(listen_key: nil, api_key: nil, api_secret_key: nil)
          raise Error.new(message: "listen_key is required") if listen_key.nil?
          Request.send!(api_key_type: :none, method: :put, path: "/api/v1/userDataStream",
                        params: { listenKey: listen_key }, security_type: :user_stream)
        end

        def start!(api_key: nil, api_secret_key: nil)
          Request.send!(api_key_type: :none, method: :post, path: "/api/v1/userDataStream",
                        security_type: :user_stream, api_key: api_key, api_secret_key: api_secret_key)
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
