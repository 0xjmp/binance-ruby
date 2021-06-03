require "spec_helper"

RSpec.describe Binance::Api::Margin::Order do
  describe "#cancel!" do
    let(:is_isolated) { }
    let(:orig_client_order_id) { }
    let(:new_client_order_id) { }
    let(:recv_window) { }
    let(:symbol) { }
    let(:timestamp) { Binance::Api::Configuration.timestamp }

    subject do
      Binance::Api::Margin::Order.cancel!(
        isIsolated: is_isolated, origClientOrderId: orig_client_order_id,
        newClientOrderId: new_client_order_id,
        recvWindow: recv_window,
        symbol: symbol,
      )
    end

    shared_examples "a valid http request" do
      let(:params) {
        {
          symbol: symbol, isIsolated: is_isolated,
          origClientOrderId: orig_client_order_id, newClientOrderId: new_client_order_id,
          recvWindow: recv_window, timestamp: timestamp,
        }.delete_if { |key, value| value.nil? }
      }
      let(:request_body) { params.map { |key, value| "#{key}=#{value}" }.join("&") }

      context "when api responds with error" do
        let!(:request_stub) do
          stub_request(:delete, "https://api.binance.com/sapi/v1/margin/order")
            .with(query: request_body)
            .to_return(status: 400, body: { msg: "error", code: "400" }.to_json)
        end

        it { is_expected_block.to raise_error Binance::Api::Error }

        it "should send api request" do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end

      context "when api succeeds" do
        let!(:request_stub) do
          stub_request(:delete, "https://api.binance.com/sapi/v1/margin/order")
            .with(query: request_body)
            .to_return(status: 200, body: json_fixture("margin-cancel"))
        end

        it {
          is_expected.to include(:symbol, :isIsolated, :orderId, :origClientOrderId, :price, :origQty,
                                 :executedQty, :cummulativeQuoteQty, :status, :timeInForce, :type, :side)
        }

        it "should send api request" do
          subject
          expect(request_stub).to have_been_requested
        end
      end
    end

    context "when symbol is nil" do
      let(:symbol) { nil }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when symbol set" do
      let(:symbol) { "BTC" }

      include_examples "a valid http request"
    end
  end

  describe "#create!" do
    let(:iceberg_quantity) { }
    let(:is_isolated) { }
    let(:new_client_order_id) { }
    let(:new_order_response_type) { }
    let(:price) { }
    let(:quantity) { }
    let(:recv_window) { }
    let(:side) { }
    let(:stop_price) { }
    let(:symbol) { }
    let(:time_in_force) { }
    let(:timestamp) { Configuration.timestamp }
    let(:type) { }

    subject do
      Binance::Api::Margin::Order.create!(
        icebergQty: iceberg_quantity, isIsolated: is_isolated,
        newClientOrderId: new_client_order_id, newOrderRespType: new_order_response_type,
        price: price, quantity: quantity, recvWindow: recv_window, stopPrice: stop_price,
        symbol: symbol, side: side, type: type, timeInForce: time_in_force,
      )
    end

    shared_examples "a valid http request" do
      let(:params) {
        {
          symbol: symbol, side: side, type: type, isIsolated: is_isolated,
          icebergQty: iceberg_quantity, newClientOrderId: new_client_order_id,
          newOrderRespType: new_order_response_type,
          quantity: quantity, price: price, recvWindow: recv_window, stopPrice: stop_price,
          timeInForce: time_in_force, timestamp: timestamp,
        }.delete_if { |key, value| value.nil? }
      }
      let(:request_body) { params.map { |key, value| "#{key}=#{value}" }.join("&") }

      context "when api responds with error" do
        let!(:request_stub) do
          stub_request(:post, "https://api.binance.com/sapi/v1/margin/order")
            .with(query: request_body)
            .to_return(status: 400, body: { msg: "error", code: "400" }.to_json)
        end

        it { is_expected_block.to raise_error Binance::Api::Error }

        it "should send api request" do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end

      context "when api succeeds" do
        let!(:request_stub) do
          stub_request(:post, "https://api.binance.com/sapi/v1/margin/order")
            .with(query: request_body)
            .to_return(status: 200, body: json_fixture("market-order-new"))
        end

        it {
          is_expected.to include(:symbol, :orderId, :clientOrderId, :transactTime, :price, :origQty,
                                 :executedQty, :status, :timeInForce, :type, :side, :fills)
        }

        it "should send api request" do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end
    end

    shared_examples "a valid order" do
      context "when quantity is nil" do
        let(:quantity) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context "when side is nil" do
        let(:side) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context "when symbol is nil" do
        let(:symbol) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context "when timestamp is nil" do
        let(:timestamp) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context "when type is nil" do
        let(:type) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context "when all required values are not nil" do
        let(:price) { 100.00 }
        let(:quantity) { 500 }
        let(:side) { "BUY" }
        let(:symbol) { "BTCLTC" }
        let(:timestamp) { Binance::Api::Configuration.timestamp }

        context "and type is limit" do
          let(:type) { :limit }

          context "but time_in_force is nil" do
            let(:time_in_force) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          context "but price is nil" do
            let(:price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          context "and price and time_in_force are not nil" do
            let(:price) { 100.0 }
            let(:time_in_force) { "GTC" }

            include_examples "a valid http request"
          end
        end

        context "and type is market" do
          let(:type) { :market }

          include_examples "a valid http request"
        end

        context "and type is stop_loss" do
          let(:stop_price) { 150.0 }
          let(:type) { :stop_loss }

          context "but stop_price is nil" do
            let(:stop_price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          include_examples "a valid http request"
        end

        context "and type is stop_loss_limit" do
          let(:price) { 100.0 }
          let(:stop_price) { 150.0 }
          let(:time_in_force) { "GTC" }
          let(:type) { :stop_loss_limit }

          context "but price is nil" do
            let(:price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          context "but time_in_force is nil" do
            let(:time_in_force) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          context "but stop_price is nil" do
            let(:stop_price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          include_examples "a valid http request"
        end

        context "and type is take_profit" do
          let(:stop_price) { 150.0 }
          let(:type) { :take_profit }

          context "but stop_price is nil" do
            let(:stop_price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          include_examples "a valid http request"
        end

        context "and type is take_profit_limit" do
          let(:price) { 100.0 }
          let(:stop_price) { 150.0 }
          let(:time_in_force) { "GTC" }
          let(:type) { :take_profit_limit }

          context "but price is nil" do
            let(:price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          context "but time_in_force is nil" do
            let(:time_in_force) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          context "but stop_price is nil" do
            let(:stop_price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          include_examples "a valid http request"
        end

        context "and type is limit_maker" do
          let(:price) { 100.0 }
          let(:type) { :limit_maker }

          context "but price is nil" do
            let(:price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          include_examples "a valid http request"
        end
      end
    end

    include_examples "a valid order"
  end
end
