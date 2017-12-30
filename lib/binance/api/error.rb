module Binance
  class Api
    class Error < StandardError
      attr_reader :code, :msg

      class << self
        # https://github.com/binance-exchange/binance-official-api-docs/blob/master/errors.md
        def is_error_response?(json:)
          return false if json.is_a? Array
          code = json[:code]&.to_i
          code && code >= 400
        end
      end

      def initialize(code: nil, json: {}, message: nil)
        @code = code || json[:code]
        @msg = message || json[:msg]
      end

      def inspect
        "Binance::Api error (#{code}): #{msg}"
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
