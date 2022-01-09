require 'active_support/version'

if ActiveSupport::VERSION::MAJOR > 6
    require "active_support/isolated_execution_state" 
end 

require "active_support/core_ext/string"

require "awrence"
require "httparty"
require "faye/websocket"

require "binance/api"
require "binance/api/account"
require "binance/api/configuration"
require "binance/api/error"
require "binance/api/margin"
require "binance/api/margin/account"
require "binance/api/margin/order"
require "binance/api/order"
require "binance/api/request"
require "binance/api/trade"
require "binance/api/user_data_stream"
require "binance/api/version"
require "binance/websocket"
