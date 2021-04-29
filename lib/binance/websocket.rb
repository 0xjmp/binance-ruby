module Binance
  class WebSocket < Faye::WebSocket::Client
    def initialize(&on_open)
      super "wss://stream.binance.com:9443/stream", nil, ping: 180

      @request_id_inc = 0

      on :open do |event|
        p [:open]
        on_open&.call
      end

      on :message do |event|
        p [:message, event.data]
        p event
        process(event.data)
      end

      on :close do |event|
        p [:close, event.code, event.reason]
        # FIXME: ws = nil
      end
    end

    # stream name: <symbol>@kline_<interval>
    def candlesticks(symbols, interval, &on_receive)
      symbols_fmt = symbols.is_a?(String) ? [symbols] : symbols
      @candlestick_handler = on_receive
      subscribe(symbols_fmt.map { |s| "#{s.downcase}@kline_#{interval}" })
    end

    private

    def process(data)
      json = JSON.parse(event.data, symbolize_names: true)
      if json[:error]
        p ">> Binance error (#{json[:code]}): #{json[:msg]}"
      elsif json[:result]
        p ">> Successfully subscribed to Binance stream: "
      else
        json.each do |payload|
          stream_name = payload[:stream]
          if stream_name.include?("kline")
            @candlesticks_handler&.call(stream_name, payload[:data])
          end
        end
      end
    end

    def request_id
      @request_id_inc += 1
    end

    def subscribe(streams)
      p ">> Subscribing to Binance streams: #{streams.join(", ")}"
      send({
        method: "SUBSCRIBE",
        params: streams,
        id: request_id,
      })
    end

    def unsubscribe(streams)
      p ">> Unsubscribing from Binance streams: #{streams.join(", ")}"
      send({
        method: "UNSUBSCRIBE",
        params: streams,
        id: request_id,
      })
    end
  end
end
