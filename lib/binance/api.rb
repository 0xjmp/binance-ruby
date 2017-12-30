require 'active_support/core_ext/string'
require 'httparty'
require 'binance/api/configuration'
require 'binance/api/error'
require "binance/api/version"

module Binance
  class Api
    include HTTParty

    base_uri 'https://api.binance.com'

    class << self
      # Valid limits:[5, 10, 20, 50, 100, 500, 1000]
      
      def candlesticks(end_time: nil, interval: nil, limit: 500, start_time: nil, symbol: nil) 
        raise Error.new(message: 'interval is required.') unless interval
        raise Error.new(message: 'symbol is required.') unless symbol
        params = { endTime: end_time, interval: interval, limit: limit, startTime: start_time, symbol: symbol }
        send_request!(api_key_type: :read_info, path: '/api/v1/klines', params: params)
      end

      def compressed_aggregate_trades(end_time: nil, from_id: nil, limit: 500, start_time: nil, symbol: nil) 
        raise Error.new(message: "symbol is required") unless symbol
        params = { endTime: end_time, fromId: from_id, limit: limit, startTime: start_time, symbol: symbol }
        send_request!(api_key_type: :read_info, path: '/api/v1/aggTrades', params: params)
      end
      
      def depth(symbol: nil, limit: 100)
        raise Error.new(message: "symbol is required") unless symbol
        params = { limit: limit, symbol: symbol }
        send_request!(api_key_type: :read_info, path: '/api/v1/depth', params: params)
      end

      def exchange_info
        send_request!(api_key_type: :read_info, path: '/api/v1/exchangeInfo')
      end

      def historical_trades(symbol: nil, limit: 500, from_id: nil)
        raise Error.new(message: "symbol is required") unless symbol
        params = { fromId: from_id, limit: limit, symbol: symbol }
        send_request!(api_key_type: :read_info, path: '/api/v1/historicalTrades', params: params)
      end

      def ping
        send_request!(path: '/api/v1/ping')
      end

      def ticker(symbol: nil, type: nil)
        ticker_type = type&.to_sym
        error_message = "type must be one of: #{ticker_types.join(', ')}. #{type} was provided."
        raise Error.new(message: error_message) unless ticker_types.include? ticker_type
        params = symbol ? { symbol: symbol } : {}
        send_request!(api_key_type: :read_info, path: "/api/v3/ticker/#{type.to_s.camelcase(:lower)}", params: params)
      end

      def time
        send_request!(path: '/api/v1/time')
      end

      def trades(symbol: nil, limit: 500)
        raise Error.new(message: "symbol is required") unless symbol
        params = { limit: limit, symbol: symbol }
        send_request!(api_key_type: :read_info, path: '/api/v1/trades', params: params)
      end

      private

      def default_headers(api_key_type:, security_type:)
        headers = {}
        headers['X-MBX-APIKEY'] = Configuration.api_key(type: api_key_type) unless security_type == :none
        headers
      end

      def process!(response: '')
        json = JSON.parse(response, symbolize_names: true)
        raise Error.new(json: json) if Error.is_error_response?(json: json)
        json 
      end

      def security_types
        [:none, :trade, :user_data, :user_stream, :market_data].freeze
      end

      def send_request!(api_key_type: :none, headers: {}, method: :get, path: '/', params: {}, security_type: :none)
        raise Error.new(message: "Invalid security type #{security_type}") unless security_types.include?(security_type)
        all_headers = default_headers(api_key_type: api_key_type, security_type: security_type)
        if [:trade, :user_data].include?(security_type)
          params.merge!(
            signature: signed_request_signature(params: params),
            timestamp: timestamp
          )
        end
        # send() is insecure so don't use it.
        case method
        when :get
          response = get(path, headers: all_headers, query: params)
        when :post
          response = post(path, body: params, headers: all_headers)
        when :put
          response = put(path, body: params, headers: all_headers)
        when :delete
          response = delete(path, body: params, headers: all_headers)
        else
          raise Error.new(message: "Invalid http method used: #{method}")
        end
        process!(response: response || '{}')
      end

      def signed_request_signature(params:)
        payload = params.map { |key, value| "#{key}=#{value}" }.join('&')
        Configuration.signed_request_signature(payload: payload)
      end

      def ticker_types
        [:daily, :price, :book_ticker].freeze
      end

      def timestamp
        Time.now.to_i
      end
    end
  end
end
