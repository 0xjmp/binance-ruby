module Binance
  class WebSocket < Faye::WebSocket::Client
    class Error < StandardError; end

    def initialize(on_open: nil, on_close: nil)
      super "wss://stream.binance.com:9443/stream", nil, ping: 180

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
        when :outboundAccountPosition
        when :balanceUpdate
        when :executionReport # order update
          listen_key = json[:stream]
          @user_stream_handlers[listen_key]&.call(listen_key, json[:data])
        end
      end
    end

    def request_id
      @request_id_inc += 1
    end

    def subscribe(streams)
      send({
        method: "SUBSCRIBE",
        params: streams,
        id: request_id,
      }.to_json)
    end

    # Terminating socket connection achieves the same result.
    # If you have a use-case for this, please create a GitHub issue.
    #
    # def unsubscribe(streams)
    #   send({
    #     method: "UNSUBSCRIBE",
    #     params: streams,
    #     id: request_id,
    #   }.to_json)
    # end
  end
end
