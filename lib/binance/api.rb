require 'active_support/core_ext/string'
require 'awrence'
require 'httparty'
require 'binance/api/account'
require 'binance/api/configuration'
require 'binance/api/data_stream'
require 'binance/api/error'
require 'binance/api/order'
require 'binance/api/request'
require "binance/api/version"

module Binance
  module Api
    class << self
      # Valid limits:[5, 10, 20, 50, 100, 500, 1000]
      def candlesticks(end_time: nil, interval: nil, limit: 500, start_time: nil, symbol: nil) 
        raise Error.new(message: 'interval is required') unless interval
        raise Error.new(message: 'symbol is required') unless symbol
        params = { endTime: end_time, interval: interval, limit: limit, startTime: start_time, symbol: symbol }
        Request.send!(api_key_type: :read_info, path: '/api/v1/klines', params: params)
      end

      def compressed_aggregate_trades(end_time: nil, from_id: nil, limit: 500, start_time: nil, symbol: nil) 
        raise Error.new(message: "symbol is required") unless symbol
        params = { endTime: end_time, fromId: from_id, limit: limit, startTime: start_time, symbol: symbol }
        Request.send!(api_key_type: :read_info, path: '/api/v1/aggTrades', params: params)
      end
      
      def depth(symbol: nil, limit: 100)
        raise Error.new(message: "symbol is required") unless symbol
        params = { limit: limit, symbol: symbol }
        Request.send!(api_key_type: :read_info, path: '/api/v1/depth', params: params)
      end

      def exchange_info
        Request.send!(api_key_type: :read_info, path: '/api/v1/exchangeInfo')
      end

      def historical_trades(symbol: nil, limit: 500, from_id: nil)
        raise Error.new(message: "symbol is required") unless symbol
        params = { fromId: from_id, limit: limit, symbol: symbol }
        Request.send!(api_key_type: :read_info, path: '/api/v1/historicalTrades', params: params, security_type: :market_data)
      end

      def ping
        Request.send!(path: '/api/v1/ping')
      end

      def ticker(symbol: nil, type: nil)
        ticker_type = type&.to_sym
        error_message = "type must be one of: #{ticker_types.join(', ')}. #{type} was provided."
        raise Error.new(message: error_message) unless ticker_types.include? ticker_type
        params = symbol ? { symbol: symbol } : {}
        Request.send!(api_key_type: :read_info, path: "/api/v3/ticker/#{type.to_s.camelcase(:lower)}", params: params)
      end

      def time
        Request.send!(path: '/api/v1/time')
      end

      def trades(symbol: nil, limit: 500)
        raise Error.new(message: "symbol is required") unless symbol
        params = { limit: limit, symbol: symbol }
        Request.send!(api_key_type: :read_info, path: '/api/v1/trades', params: params)
      end

      private

      def ticker_types
        [:daily, :price, :book_ticker].freeze
      end
    end
  end
end
