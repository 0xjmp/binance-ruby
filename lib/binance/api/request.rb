module Binance
  module Api
    class Request
      include HTTParty
      http_proxy 'http://us-east-static-09.quotaguard.com', 9293, ENV["QUOTAGUARD_USER"], ENV["QUOTAGUARD_PASSWORD"]

      class << self
        def send!(api_key_type: :none, headers: {}, method: :get, path: "/", params: {}, security_type: :none, tld: Configuration.tld, api_key: nil, api_secret_key: nil)
          Configuration.validate_tld!(tld)
          binance_uri = ENV['BINANCE_TEST_NET_ENABLE'] ? "https://testnet.binance.vision" : "https://api.binance.#{tld}"
          self.base_uri binance_uri

          raise Error.new(message: "invalid security type #{security_type}") unless security_types.include?(security_type)
          all_headers = default_headers(api_key_type: api_key_type, security_type: security_type, api_key: api_key)
          params.delete_if { |k, v| v.nil? }
          if %w(trade user_data).include?(security_type&.to_s)
            signature = signed_request_signature(params: params, api_secret_key: api_secret_key)
            params.merge!(signature: signature)
          end
          # send() is insecure so don't use it.
          case method
          when :get
            response = get(path, headers: all_headers, query: params)
          when :post
            response = post(path, query: params, headers: all_headers)
          when :put
            response = put(path, query: params, headers: all_headers)
          when :delete
            response = delete(path, query: params, headers: all_headers)
          else
            raise Error.new(message: "invalid http method used: #{method}")
          end
          process!(response: response || "{}")
        end

        private

        def default_headers(api_key_type:, security_type:, api_key: nil)
          headers = {}
          headers["Content-Type"] = "application/json; charset=utf-8"
          headers["X-MBX-APIKEY"] = (api_key || Configuration.api_key(type: api_key_type)) unless security_type == :none
          headers
        end

        def process!(response:)
          json = begin
              JSON.parse(response.body, symbolize_names: true)
            rescue JSON::ParserError => error
              # binance 500 errors are html format
              raise Error.new(message: error)
            end
          raise Error.localized(json[:code]).new(json: json) if Error.is_error_response?(response: response)
          json
        end

        def security_types
          [:none, :trade, :user_data, :user_stream, :market_data, :margin].freeze
        end

        def signed_request_signature(params:, api_secret_key: nil)
          payload = params.map { |key, value| "#{key}=#{value}" }.join("&")
          Configuration.signed_request_signature(payload: payload, api_secret_key: api_secret_key)
        end
      end
    end
  end
end
