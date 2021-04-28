module Binance
  module Api
    class Error < StandardError
      attr_reader :code, :msg, :symbol

      class << self
        # https://github.com/binance-exchange/binance-official-api-docs/blob/master/errors.md
        def is_error_response?(response:)
          response.code >= 400
        end

        # https://github.com/binance/binance-spot-api-docs/blob/master/errors.md
        def localized(message)
          code = message.to_s.match(/\d+/).to_s.to_i
          case code
          when 1000 then Unknown
          when 1001 then Disconnected
          when 1002 then Unauthorized
          when 1003 then TooManyRequests
          when 1006 then UnexpectedResponse
          when 1007 then Timeout
          when 1013 then InvalidQuantity
          when 1014 then UnknownOrderComposition
          when 1015 then TooManyOrders
          when 1016 then ServiceShuttingDown
          when 1020 then UnsupportedOperation
          when 1021 then InvalidTimestamp
          when 1022 then InvalidSignature
          when 1100 then IllegalChars
          when 1101 then TooManyParameters
          when 1102 then MandatoryParamEmptyOrMalformed
          when 1103 then UnknownParam
          when 1104 then UnreadParameters
          when 1105 then ParamEmpty
          when 1106 then ParamNotRequired
          when 1111 then BadPrecision
          when 1112 then NoDepth
          when 1114 then TIFNotRequired
          when 1115 then InvalidTIF
          when 1116 then InvalidOrderType
          when 1117 then InvalidSide
          when 1118 then EmptyNewCLOrderId
          when 1119 then EmptyOrgCLOrderId
          when 1120 then BadInterval
          when 1121 then BadSymbol
          when 1125 then InvalidListenKey
          when 1127 then IntervalTooLarge
          when 1128 then OptionalParamsBadCombo
          when 1130 then InvalidParameter
          when 2010 then NewOrderRejected
          when 2011 then CancelOrderRejected
          when 2013 then NoSuchOrder
          when 2014 then BadAPIKeyFormat
          when 2015 then RejectedAPIKey
          when 2016 then NoTradingWindow
          else Binance::Api::Error
          end
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
        message += "@#{symbol} " unless symbol.nil?
        message += "#{msg}" unless msg.nil?
      end

      def message
        inspect
      end

      def to_s
        inspect
      end

      class Unknown < Error; end
      class Disconnected < Error; end
      class Unauthorized < Error; end
      class TooManyRequests < Error; end
      class UnexpectedResponse < Error; end
      class Timeout < Error; end
      class InvalidQuantity < Error; end
      class UnknownOrderComposition < Error; end
      class TooManyOrders < Error; end
      class ServiceShuttingDown < Error; end
      class UnsupportedOperation < Error; end
      class InvalidTimestamp < Error; end
      class InvalidSignature < Error; end
      class IllegalChars < Error; end
      class TooManyParameters < Error; end
      class MandatoryParamEmptyOrMalformed < Error; end
      class UnknownParam < Error; end
      class UnreadParameters < Error; end
      class ParamEmpty < Error; end
      class ParamNotRequired < Error; end
      class BadPrecision < Error; end
      class NoDepth < Error; end
      class TIFNotRequired < Error; end
      class InvalidTIF < Error; end
      class InvalidOrderType < Error; end
      class InvalidSide < Error; end
      class EmptyNewCLOrderId < Error; end
      class EmptyOrgCLOrderId < Error; end
      class BadInterval < Error; end
      class BadSymbol < Error; end
      class InvalidListenKey < Error; end
      class IntervalTooLarge < Error; end
      class OptionalParamsBadCombo < Error; end
      class InvalidParameter < Error; end
      class NewOrderRejected < Error; end
      class CancelOrderRejected < Error; end
      class NoSuchOrder < Error; end
      class BadAPIKeyFormat < Error; end
      class RejectedAPIKey < Error; end
      class NoTradingWindow < Error; end
    end
  end
end
