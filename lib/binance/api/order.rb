module Binance
  module Api
    class Order
      class << self
        def all!(limit: 500, order_id: nil, recv_window: 5000, symbol: nil)
          raise Error.new(message: "max limit is 500") unless limit <= 500
          raise Error.new(message: "symbol is required") if symbol.nil?
          timestamp = Configuration.timestamp
          params = { limit: limit, orderId: order_id, recvWindow: recv_window, symbol: symbol, timestamp: timestamp }
          Request.send!(api_key_type: :read_info, path: "/api/v3/allOrders",
                        params: params.delete_if { |key, value| value.nil? },
                        security_type: :user_data)
        end

        # Be careful when accessing without a symbol!
        def all_open!(recv_window: 5000, symbol: nil)
          timestamp = Configuration.timestamp
          params = { recvWindow: recv_window, symbol: symbol, timestamp: timestamp }
          Request.send!(api_key_type: :read_info, path: '/api/v3/openOrders',
                        params: params, security_type: :user_data)
        end

        def cancel!(order_id: nil, original_client_order_id: nil, new_client_order_id: nil, recv_window: nil, symbol: nil)
          raise Error.new(message: "symbol is required") if symbol.nil?
          raise Error.new(message: "either order_id or original_client_order_id " \
            "is required") if order_id.nil? && original_client_order_id.nil?
          timestamp = Configuration.timestamp
          params = { orderId: order_id, origClientOrderId: original_client_order_id,
                     newClientOrderId: new_client_order_id, recvWindow: recv_window,
                     symbol: symbol, timestamp: timestamp }.delete_if { |key, value| value.nil? }
          Request.send!(api_key_type: :trading, method: :delete, path: "/api/v3/order",
                        params: params, security_type: :trade)
        end

        def create!(iceberg_quantity: nil, new_client_order_id: nil, new_order_response_type: nil,
                    price: nil, quantity: nil, recv_window: nil, stop_price: nil, symbol: nil,
                    side: nil, type: nil, time_in_force: nil, test: false)
          timestamp = Configuration.timestamp
          ensure_required_create_keys!(params: {
            iceberg_quantity: iceberg_quantity, new_client_order_id: new_client_order_id,
            new_order_response_type: new_order_response_type, price: price,
            quantity: quantity, recv_window: recv_window, stop_price: stop_price,
            symbol: symbol, side: side, type: type, time_in_force: time_in_force,
            timestamp: timestamp
          })
          params = { 
            icebergQty: iceberg_quantity, newClientOrderId: new_client_order_id,
            newOrderRespType: new_order_response_type, price: price, quantity: quantity,
            recvWindow: recv_window, stopPrice: stop_price, symbol: symbol, side: side,
            type: type, timeInForce: time_in_force, timestamp: timestamp
          }.delete_if { |key, value| value.nil? }
          path = "/api/v3/order#{'/test' if test}"
          Request.send!(api_key_type: :trading, method: :post, path: path,
                        params: params, security_type: :trade)
        end

        def status!(order_id: nil, original_client_order_id: nil, recv_window: nil, symbol: nil)
          raise Error.new(message: "symbol is required") if symbol.nil?
          raise Error.new(message: "either order_id or original_client_order_id " \
            "is required") if order_id.nil? && original_client_order_id.nil?
          timestamp = Configuration.timestamp
          params = {
            orderId: order_id, origClientOrderId: original_client_order_id, recvWindow: recv_window,
            symbol: symbol, timestamp: timestamp
          }.delete_if { |key, value| value.nil? }
          Request.send!(api_key_type: :trading, path: "/api/v3/order",
                        params: params, security_type: :user_data)
        end

        private

        def additional_required_create_keys(type:)
          case type
          when :limit
            [:price, :time_in_force].freeze
          when :stop_loss, :take_profit
            [:stop_price].freeze
          when :stop_loss_limit, :take_profit_limit
            [:price, :stop_price, :time_in_force].freeze
          when :limit_maker
            [:price].freeze
          else
            [].freeze
          end
        end

        def ensure_required_create_keys!(params:)
          keys = required_create_keys.dup.concat(additional_required_create_keys(type: params[:type]))
          missing_keys = keys.select { |key| params[key].nil? }
          raise Error.new(message: "required keys are missing: #{missing_keys.join(', ')}") unless missing_keys.empty?
        end

        def required_create_keys
          [:symbol, :side, :type, :quantity, :timestamp].freeze
        end
      end
    end
  end
end
