module Binance
  module Api
    class Error < StandardError
      attr_reader :code, :msg, :symbol

      class << self
        # https://github.com/binance-exchange/binance-official-api-docs/blob/master/errors.md
        def is_error_response?(response:)
          response.code >= 400
        end
      end

      def initialize(code: nil, json: {}, message: nil, symbol: nil)
        @code = code || json[:code]
        @msg = message || json[:msg]
        @symbol = message || json[:symbol]
      end

      def inspect
        message = ""
        message += "(#{code}) " unless code.nil?
        message += "#{msg}" unless msg.nil?
      end

      def message
        inspect
      end

      def to_s
        inspect
      end
    end
  end
end
