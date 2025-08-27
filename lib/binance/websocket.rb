module Binance
  class WebSocket < Faye::WebSocket::Client
    class Error < StandardError; end

    def initialize(on_open: nil, on_close: nil)
      wss_uri = ENV['BINANCE_TEST_NET_ENABLE'] ? 'wss://testnet.binance.vision/stream' : 'wss://stream.binance.com:9443/stream'

      super wss_uri, nil, ping: 180

      @request_id_inc = 0
      @user_stream_handlers = {}

      on :open do |event|
        on_open&.call(event)
      end

      on :message do |event|
        process_data(event.data)
      end

      on :close do |event|
        on_close&.call(event)
      end
    end

    # stream name: <symbol>@kline_<interval>
    #
    # {
    #   "e": "kline",     // Event type
    #   "E": 123456789,   // Event time
    #   "s": "BNBBTC",    // Symbol
    #   "k": {
    #     "t": 123400000, // Kline start time
    #     "T": 123460000, // Kline close time
    #     "s": "BNBBTC",  // Symbol
    #     "i": "1m",      // Interval
    #     "f": 100,       // First trade ID
    #     "L": 200,       // Last trade ID
    #     "o": "0.0010",  // Open price
    #     "c": "0.0020",  // Close price
    #     "h": "0.0025",  // High price
    #     "l": "0.0015",  // Low price
    #     "v": "1000",    // Base asset volume
    #     "n": 100,       // Number of trades
    #     "x": false,     // Is this kline closed?
    #     "q": "1.0000",  // Quote asset volume
    #     "V": "500",     // Taker buy base asset volume
    #     "Q": "0.500",   // Taker buy quote asset volume
    #     "B": "123456"   // Ignore
    #   }
    # }
    def candlesticks!(symbols, interval, &on_receive)
      symbols_fmt = symbols.is_a?(String) ? [symbols] : symbols
      @candlesticks_handler = on_receive
      subscribe(symbols_fmt.map { |s| "#{s.downcase}@kline_#{interval}" })
    end

    def user_data_stream!(listen_key, &on_receive)
      @user_stream_handlers[listen_key] = on_receive
      subscribe([listen_key])
    end

    # stream name: <symbol>@trade
    # {
    #   "e": "trade",     // Event type
    #   "E": 123456789,   // Event time
    #   "s": "BNBBTC",    // Symbol
    #   "t": 12345,       // Trade ID
    #   "p": "0.001",     // Price
    #   "q": "100",       // Quantity
    #   "b": 88,          // Buyer order ID
    #   "a": 50,          // Seller order ID
    #   "T": 123456785,   // Trade time
    #   "m": true,        // Is the buyer the market maker?
    #   "M": true         // Ignore
    # }
    def trades!(symbols, &on_receive)
      symbols_fmt = symbols.is_a?(String) ? [symbols] : symbols
      @trades_handler = on_receive
      subscribe(symbols_fmt.map { |s| "#{s.downcase}@trade" })
    end

    # stream name: <symbol>@depth OR <symbol>@depth@500ms OR <symbol>@depth@100ms
    # {
    #   "e": "depthUpdate", // Event type
    #   "E": 1571889248277, // Event time
    #   "T": 1571889248276, // Transaction time
    #   "s": "BTCUSDT",
    #   "U": 390497796,     // First update ID in event
    #   "u": 390497878,     // Final update ID in event
    #   "pu": 390497794,    // Final update Id in last stream(ie `u` in last stream)
    #   "b": [              // Bids to be updated
    #     [
    #       "7403.89",      // Price Level to be updated
    #       "0.002"         // Quantity
    #     ],
    #     [
    #       "7403.90",
    #       "3.906"
    #     ],
    #     [
    #       "7404.00",
    #       "1.428"
    #     ],
    #     [
    #       "7404.85",
    #       "5.239"
    #     ],
    #     [
    #       "7405.43",
    #       "2.562"
    #     ],
    #   ],
    #   "a": [              // Asks to be updated
    #     [
    #       "7405.96",      // Price level to be
    #       "3.340"         // Quantity
    #     ],
    #     [
    #       "7406.63",
    #       "4.525"
    #     ],
    #     [
    #       "7407.08",
    #       "2.475"
    #     ],
    #     [
    #       "7407.15",
    #       "4.800"
    #     ],
    #     [
    #       "7407.20",
    #       "0.175"
    #     ],
    #   ],
    # ]

    def partial_book_depth!(symbols, level, update_speed = nil, &on_receive)
      symbols_fmt = symbols.is_a?(String) ? [symbols] : symbols
      @book_depth_handler = on_receive
      subscribe(symbols_fmt.map { |s| "#{s.downcase}@depth#{level}#{update_speed ? "@#{update_speed}ms" : ''}" })
    end

    # stream name: <symbol>@depth OR <symbol>@depth@500ms OR <symbol>@depth@100ms
    # {
    #   "e": "depthUpdate", // Event type
    #   "E": 123456789,     // Event time
    #   "T": 123456788,     // Transaction time
    #   "s": "BTCUSDT",     // Symbol
    #   "U": 157,           // First update ID in event
    #   "u": 160,           // Final update ID in event
    #   "pu": 149,          // Final update Id in last stream(ie `u` in last stream)
    #   "b": [              // Bids to be updated
    #     [
    #       "0.0024",       // Price level to be updated
    #       "10"            // Quantity
    #     ]
    #   ],
    #   "a": [              // Asks to be updated
    #     [
    #       "0.0026",       // Price level to be updated
    #       "100"          // Quantity
    #     ]
    #   ]
    # }

    def book_depth!(symbols, update_speed = nil, &on_receive)
      symbols_fmt = symbols.is_a?(String) ? [symbols] : symbols
      @book_depth_handler = on_receive
      subscribe(symbols_fmt.map { |s| "#{s.downcase}@depth#{update_speed ? "@#{update_speed}ms" : ''}" })
    end

    def book_depth_unsubscribe!(symbols, update_speed = nil)
      symbols_fmt = symbols.is_a?(String) ? [symbols] : symbols
      unsubscribe(symbols_fmt.map { |s| "#{s.downcase}@depth#{update_speed ? "@#{update_speed}ms" : ''}" })
    end

    private

    def process_data(data)
      json = JSON.parse(data, symbolize_names: true)
      if json[:error]
        raise Error.new("(#{json[:code]}) #{json[:msg]}")
      elsif json.key?(:result)
        #  Binance stream connected successfully
      else
        case json[:data][:e]&.to_sym
        when :kline
          @candlesticks_handler&.call(json[:stream], json[:data])
        when :depthUpdate
          @book_depth_handler&.call(json[:stream], json[:data])
        when :outboundAccountPosition
        when :balanceUpdate
        when :executionReport # order update
          listen_key = json[:stream]
          @user_stream_handlers[listen_key]&.call(listen_key, json[:data])
        when :trade
          @trades_handler&.call(json[:stream], json[:data])
        end
      end
    end

    def request_id
      @request_id_inc += 1
    end

    def subscribe(streams)
      send({
        method: 'SUBSCRIBE',
        params: streams,
        id: request_id
      }.to_json)
    end

    # Terminating socket connection achieves the same result.
    # If you have a use-case for this, please create a GitHub issue.
    #
    def unsubscribe(streams)
      send({
        method: "UNSUBSCRIBE",
        params: streams,
        id: request_id,
      }.to_json)
    end
  end
end
