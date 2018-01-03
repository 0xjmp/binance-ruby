module Binance
  module Api
    class Order
      class << self
        def all!(limit: 500, order_id: nil, recv_window: nil, symbol: nil)
          raise Error.new(message: "max limit is 500") unless limit <= 500
          raise Error.new(message: "symbol is required") if symbol.nil?
          timestamp = Configuration.timestamp
          params = { limit: limit, order_id: order_id, recv_window: recv_window, symbol: symbol, timestamp: timestamp }
          Request.send!(api_key_type: :read_info, path: "/api/v3/allOrders",
                        params: params.delete_if { |key, value| value.nil? },
                        security_type: :user_data)
        end

        # Be careful when accessing without a symbol!
        def all_open!(recv_window: nil, symbol: nil)
          timestamp = Configuration.timestamp
          params = { recv_window: recv_window, symbol: symbol, timestamp: timestamp }
          Request.send!(api_key_type: :read_info, path: '/api/v3/openOrders',
                        params: params, security_type: :user_data)
        end

        def cancel!(params: {})
          raise Error.new(message: "symbol is required") if params[:symbol].nil?
          raise Error.new(message: "timestamp is required") if params[:timestamp].nil?
          raise Error.new(message: "either order_id or original_client_order_id " \
            "is required") if params[:order_id].nil? && params[:original_client_order_id].nil?
          Request.send!(api_key_type: :trading, method: :delete, path: "/api/v3/order",
                        params: params.delete_if { |key, value| value.nil? },
                        security_type: :trade)
        end

        def create!(params: {}, test: false)
          ensure_required_create_keys!(params: params)
          flat_params = params.delete_if { |key, value| value.nil? }
          path = "/api/v3/order#{'/test' if test}"
          Request.send!(api_key_type: :trading, method: :post, path: path,
                        params: flat_params, security_type: :trade)
        end

        def status!(params = {})
          raise Error.new(message: "symbol is required") if params[:symbol].nil?
          raise Error.new(message: "timestamp is required") if params[:timestamp].nil?
          raise Error.new(message: "either order_id or original_client_order_id " \
            "is required") if params[:order_id].nil? && params[:original_client_order_id].nil?
          Request.send!(api_key_type: :trading, path: "/api/v3/order",
                        params: params.delete_if { |key, value| value.nil? },
                        security_type: :user_data)
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
