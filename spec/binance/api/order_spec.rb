require 'spec_helper'

RSpec.describe Binance::Api::Order do
  describe '#all!' do
    let(:limit) { 500 }
    let(:order_id) { }
    let(:params) { { limit: limit, orderId: order_id, recvWindow: recv_window, symbol: symbol, timestamp: timestamp } }
    let(:query_string) { params.delete_if { |key, value| value.nil? }.map { |key, value| "#{key}=#{value}" }.join('&') }
    let(:recv_window) { }
    let(:signature) do
      Binance::Api::Configuration.signed_request_signature(payload: query_string)
    end
    let(:symbol) { }
    let(:timestamp) { Binance::Api::Configuration.timestamp }

    subject do
      Binance::Api::Order.all!(limit: limit, order_id: order_id, recv_window: recv_window, symbol: symbol)
    end

    context 'when limit is higher than max' do
      let(:limit) { 501 }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context 'when symbol is nil' do
      let(:symbol) { nil }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context 'when all required params are valid' do
      let(:symbol) { 'BTCLTC' }

      context 'but api responds with error' do
        let!(:request_stub) do
          stub_request(:get, "https://api.binance.com/api/v3/allOrders")
            .with(query: query_string + "&signature=#{signature}")
            .to_return(status: 400, body: { msg: 'error', code: '400' }.to_json)
        end

        it { is_expected_block.to raise_error Binance::Api::Error }

        it 'should send api request' do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end

      context 'and api succeeds' do
        let!(:request_stub) do
          stub_request(:get, "https://api.binance.com/api/v3/allOrders")
            .with(query: query_string + "&signature=#{signature}")
            .to_return(status: 200, body: "[#{json_fixture('order-status')}]")
        end

        it 'has order keys' do
          expect(subject.first).to include(:symbol, :orderId, :clientOrderId, :price, :origQty, :executedQty,
                                           :status, :timeInForce, :type, :side, :stopPrice, :icebergQty, :time,
                                           :isWorking)
        end

        it 'should send api request' do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end
    end
  end

  describe '#all_open!' do
    let(:params) { { recvWindow: recv_window, symbol: symbol, timestamp: timestamp } }
    let(:query_string) { params.delete_if { |k, v| v.nil? }.map { |key, value| "#{key}=#{value}" }.join('&') }
    let(:recv_window) { }
    let(:signature) do
      Binance::Api::Configuration.signed_request_signature(payload: query_string)
    end
    let(:symbol) { }
    let(:timestamp) { Binance::Api::Configuration.timestamp }

    subject { Binance::Api::Order.all_open!(recv_window: recv_window, symbol: symbol) }

    context 'when api responds with error' do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v3/openOrders")
          .with(query: query_string + "&signature=#{signature}")
          .to_return(status: 400, body: { msg: 'error', code: '400' }.to_json)
      end

      it { is_expected_block.to raise_error Binance::Api::Error }

      it 'should send api request' do
        subject rescue Binance::Api::Error
        expect(request_stub).to have_been_requested
      end
    end

    context 'when api succeeds' do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v3/openOrders")
          .with(query: query_string + "&signature=#{signature}")
          .to_return(status: 200, body: "[#{json_fixture('order-status')}]")
      end

      it 'has order keys' do
        expect(subject.first).to include(:symbol, :orderId, :clientOrderId, :price, :origQty, :executedQty,
                                         :status, :timeInForce, :type, :side, :stopPrice, :icebergQty, :time,
                                         :isWorking)
      end

      it 'should send api request' do
        subject rescue Binance::Api::Error
        expect(request_stub).to have_been_requested
      end
    end
  end

  describe '#cancel!' do
    let(:order_id) { }
    let(:original_client_order_id) { }
    let(:new_client_order_id) { }
    let(:params) do
      {
        orderId: order_id, origClientOrderId: original_client_order_id,
        newClientOrderId: new_client_order_id,
        recvWindow: recv_window, symbol: symbol, timestamp: timestamp 
      }.delete_if { |key, value| value.nil? }
    end
    let(:recv_window) { }
    let(:symbol) { }
    let(:timestamp) { Binance::Api::Configuration.timestamp }

    subject { Binance::Api::Order.cancel!(
      order_id: order_id, original_client_order_id: original_client_order_id,
      new_client_order_id: new_client_order_id,
      recv_window: recv_window, symbol: symbol
    )}

    shared_examples 'a valid http request' do
      let(:query_string) { params.map { |key, value| "#{key}=#{value}" }.join('&') }
      let(:signature) do
        Binance::Api::Configuration.signed_request_signature(payload: query_string)
      end
      context 'when api responds with error' do
        let!(:request_stub) do
          stub_request(:delete, "https://api.binance.com/api/v3/order")
            .with(body: query_string + "&signature=#{signature}")
            .to_return(status: 400, body: { msg: 'error', code: '400' }.to_json)
        end

        it { is_expected_block.to raise_error Binance::Api::Error }

        it 'should send api request' do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end

      context 'when api succeeds' do
        let!(:request_stub) do
          stub_request(:delete, "https://api.binance.com/api/v3/order")
            .with(body: query_string + "&signature=#{signature}")
            .to_return(status: 200, body: json_fixture('order-cancel'))
        end

        it { is_expected.to include(:symbol, :origClientOrderId, :orderId, :clientOrderId) }

        it 'should send api request' do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end
    end

    context 'when symbol is nil' do
      let(:symbol) { nil }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context 'when symbol is extant' do
      let(:symbol) { 'BTCLTC' }

      context 'when timestamp is nil' do
        let(:timestamp) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context 'when timestamp is extant' do
        let(:timestamp) { Binance::Api::Configuration.timestamp }

        context 'when order_id & orginal_client_order_id is nil' do
          let(:order_id) { nil }
          let(:original_client_order_id) { nil }

          it { is_expected_block.to raise_error Binance::Api::Error }
        end

        context 'when all required params exist' do
          let(:order_id) { 2 }

          include_examples 'a valid http request'
        end
      end
    end
  end

  describe '#create!' do
    let(:iceberg_quantity) { }
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
      Binance::Api::Order.create!(iceberg_quantity: iceberg_quantity, new_client_order_id: new_client_order_id,
                              new_order_response_type: new_order_response_type, price: price,
                              quantity: quantity, recv_window: recv_window, stop_price: stop_price,
                              symbol: symbol, side: side, type: type, time_in_force: time_in_force,
                              test: test)
    end

    shared_examples 'a valid http request' do
      let(:params) { {
        icebergQty: iceberg_quantity, newClientOrderId: new_client_order_id,
        newOrderRespType: new_order_response_type, price: price,
        quantity: quantity, recvWindow: recv_window, 
        stopPrice: stop_price, symbol: symbol, side: side, type: type,
        timeInForce: time_in_force, timestamp: timestamp
      }.delete_if { |key, value| value.nil? } }
      let(:request_body) { params.map { |key, value| "#{key}=#{value}" }.join('&') }
      let(:signature) do
        Binance::Api::Configuration.signed_request_signature(payload: request_body)
      end

      context 'when api responds with error' do
        let!(:request_stub) do
          stub_request(:post, "https://api.binance.com/api/v3/order#{'/test' if test}")
            .with(body: request_body + "&signature=#{signature}")
            .to_return(status: 400, body: { msg: 'error', code: '400' }.to_json)
        end

        it { is_expected_block.to raise_error Binance::Api::Error }

        it 'should send api request' do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end

      context 'when api succeeds' do
        let!(:request_stub) do
          stub_request(:post, "https://api.binance.com/api/v3/order#{'/test' if test}")
            .with(body: request_body + "&signature=#{signature}")
            .to_return(status: 200, body: json_fixture('order-new'))
        end

        it { is_expected.to include(:symbol, :orderId, :clientOrderId, :transactTime, :price, :origQty,
                                    :executedQty, :status, :timeInForce, :type, :side, :fills) }

        it 'should send api request' do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end
    end

    shared_examples 'a valid order' do 
      context 'when quantity is nil' do
        let(:quantity) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context 'when side is nil' do
        let(:side) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context 'when symbol is nil' do
        let(:symbol) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context 'when timestamp is nil' do
        let(:timestamp) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context 'when type is nil' do
        let(:type) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context 'when all required values are not nil' do
        let(:price) { 100.00 }
        let(:quantity) { 500 }
        let(:side) { 'BUY' }
        let(:symbol) { 'BTCLTC' }
        let(:timestamp) { Binance::Api::Configuration.timestamp }

        context 'and type is limit' do
          let(:type) { :limit }

          context 'but time_in_force is nil' do
            let(:time_in_force) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          context 'but price is nil' do
            let(:price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          context 'and price and time_in_force are not nil' do
            let(:price) { 100.0 }
            let(:time_in_force) { 'GTC' }

            include_examples 'a valid http request'
          end
        end

        context 'and type is market' do
          let(:type) { :market }

          include_examples 'a valid http request'
        end

        context 'and type is stop_loss' do
          let(:stop_price) { 150.0 }
          let(:type) { :stop_loss }

          context 'but stop_price is nil' do
            let(:stop_price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          include_examples 'a valid http request'
        end

        context 'and type is stop_loss_limit' do
          let(:price) { 100.0 }
          let(:stop_price) { 150.0 }
          let(:time_in_force) { 'GTC' }
          let(:type) { :stop_loss_limit }

          context 'but price is nil' do
            let(:price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          context 'but time_in_force is nil' do
            let(:time_in_force) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          context 'but stop_price is nil' do
            let(:stop_price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          include_examples 'a valid http request'
        end

        context 'and type is take_profit' do
          let(:stop_price) { 150.0 }
          let(:type) { :take_profit }

          context 'but stop_price is nil' do
            let(:stop_price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          include_examples 'a valid http request'
        end

        context 'and type is take_profit_limit' do
          let(:price) { 100.0 }
          let(:stop_price) { 150.0 }
          let(:time_in_force) { 'GTC' }
          let(:type) { :take_profit_limit }

          context 'but price is nil' do
            let(:price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          context 'but time_in_force is nil' do
            let(:time_in_force) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          context 'but stop_price is nil' do
            let(:stop_price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          include_examples 'a valid http request'
        end

        context 'and type is limit_maker' do
          let(:price) { 100.0 }
          let(:type) { :limit_maker }

          context 'but price is nil' do
            let(:price) { nil }

            it { is_expected_block.to raise_error Binance::Api::Error }
          end

          include_examples 'a valid http request'
        end
      end
    end

    context 'when test is true' do
      let(:test) { true }

      include_examples 'a valid order'
    end

    context 'when test is false' do
      let(:test) { false }

      include_examples 'a valid order'
    end
  end

  describe '#status!' do
    let(:order_id) { }
    let(:original_client_order_id) { }
    let(:params) do
      {
        orderId: order_id, origClientOrderId: original_client_order_id,
        recvWindow: recv_window, symbol: symbol, timestamp: timestamp 
      }.delete_if { |key, value| value.nil? }
    end
    let(:recv_window) { }
    let(:symbol) { }
    let(:timestamp) { Binance::Api::Configuration.timestamp }

    subject { Binance::Api::Order.status!(order_id: order_id, original_client_order_id: original_client_order_id, recv_window: recv_window, symbol: symbol) }

    shared_examples 'a valid http request' do
      let(:query_string) { params.map { |key, value| "#{key}=#{value}" }.join('&') }
      let(:signature) do
        Binance::Api::Configuration.signed_request_signature(payload: query_string)
      end
      context 'when api responds with error' do
        let!(:request_stub) do
          stub_request(:get, "https://api.binance.com/api/v3/order")
            .with(query: query_string + "&signature=#{signature}")
            .to_return(status: 400, body: { msg: 'error', code: '400' }.to_json)
        end

        it { is_expected_block.to raise_error Binance::Api::Error }

        it 'should send api request' do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end

      context 'when api succeeds' do
        let!(:request_stub) do
          stub_request(:get, "https://api.binance.com/api/v3/order")
            .with(query: query_string + "&signature=#{signature}")
            .to_return(status: 200, body: json_fixture('order-status'))
        end

        it { is_expected.to include(:symbol, :orderId, :clientOrderId, :price, :origQty, :executedQty,
                                    :status, :timeInForce, :type, :side, :stopPrice, :icebergQty, :time,
                                    :isWorking) }

        it 'should send api request' do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end
    end

    context 'when symbol is nil' do
      let(:symbol) { nil }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context 'when symbol is extant' do
      let(:symbol) { 'BTCLTC' }

      context 'when order_id & orginal_client_order_id is nil' do
        let(:order_id) { nil }
        let(:original_client_order_id) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context 'when all required params exist' do
        let(:order_id) { 2 }

        include_examples 'a valid http request'
      end
    end
  end
end
