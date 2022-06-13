module Binance
  module Api
    module Margin
      class Order
        class << self
          def cancel!(symbol: nil, isIsolated: false, orderId: nil, origClientOrderId: nil,
                      newClientOrderId: nil, recvWindow: nil, api_key: nil, api_secret_key: nil)
            timestamp = Configuration.timestamp
            params = {
              symbol: symbol, isIsolated: isIsolated, orderId: orderId, origClientOrderId: origClientOrderId,
              newClientOrderId: newClientOrderId, recvWindow: recvWindow, timestamp: timestamp,
            }.delete_if { |_, value| value.nil? }
            ensure_required_cancel_keys!(params: params)
            path = "/sapi/v1/margin/order"
            Request.send!(api_key_type: :trading, method: :delete, path: path,
                          params: params, security_type: :margin, tld: Configuration.tld,
                          api_key: api_key, api_secret_key: api_secret_key)
          end

          def create!(symbol: nil, isIsolated: false, side: nil, type: nil, quantity: nil,
                      quoteOrderQty: nil, price: nil, stopPrice: nil, newClientOrderId: nil,
                      icebergQty: nil, newOrderRespType: nil, sideEffectType: nil, timeInForce: nil,
                      recvWindow: nil, api_key: nil, api_secret_key: nil)
            timestamp = Configuration.timestamp
            params = {
              symbol: symbol, isIsolated: isIsolated, side: side, type: type,
              quantity: quantity, quoteOrderQty: quoteOrderQty, price: price,
              stopPrice: stopPrice, newClientOrderId: newClientOrderId, icebergQty: icebergQty,
              newOrderRespType: newOrderRespType, sideEffectType: sideEffectType,
              timeInForce: timeInForce, recvWindow: recvWindow, timestamp: timestamp,
            }.delete_if { |_, value| value.nil? }
            ensure_required_create_keys!(params: params)
            path = "/sapi/v1/margin/order"
            Request.send!(api_key_type: :trading, method: :post, path: path,
                          params: params, security_type: :margin, tld: Configuration.tld,
                          api_key: api_key, api_secret_key: api_secret_key)
          end

          def status!(orderId: nil, originalClientOrderId: nil, recvWindow: nil, symbol: nil,
                      api_key: nil, api_secret_key: nil, isIsolated: false)
            raise Error.new(message: "symbol is required") if symbol.nil?
            raise Error.new(message: "either orderid or originalclientorderid " \
                            "is required") if orderId.nil? && originalClientOrderId.nil?
            timestamp = Configuration.timestamp
            params = {
              orderId: orderId, origClientOrderId: originalClientOrderId, recvWindow: recvWindow,
              symbol: symbol, timestamp: timestamp, isIsolated: isIsolated
            }.delete_if { |key, value| value.nil? }
            Request.send!(api_key_type: :trading, path: "/sapi/v1/margin/order",
                          params: params, security_type: :user_data, tld: Configuration.tld, api_key: api_key,
                          api_secret_key: api_secret_key)
          end

          private

          def additional_required_create_keys(type:)
            case type
            when :limit
              [:price, :timeInForce].freeze
            when :stop_loss, :take_profit
              [:stopPrice].freeze
            when :stop_loss_limit, :take_profit_limit
              [:price, :stopPrice, :timeInForce].freeze
            when :limit_maker
              [:price].freeze
            else
              [].freeze
            end
          end

          def ensure_required_create_keys!(params:)
            keys = required_create_keys.dup.concat(additional_required_create_keys(type: params[:type]))
            missing_keys = keys.select { |key| params[key].nil? }
            raise Error.new(message: "required keys are missing: #{missing_keys.join(", ")}") unless missing_keys.empty?
          end

          def required_create_keys
            [:symbol, :side, :type, :timestamp].freeze
          end

          def ensure_required_cancel_keys!(params:)
            keys = required_cancel_keys.dup
            missing_keys = keys.select { |key| params[key].nil? }
            raise Error.new(message: "required keys are missing: #{missing_keys.join(", ")}") unless missing_keys.empty?
          end

          def required_cancel_keys
            [:symbol, :timestamp].freeze
          end
        end
      end
    end
  end
end
