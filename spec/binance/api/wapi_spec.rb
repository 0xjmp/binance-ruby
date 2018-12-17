require 'spec_helper'

RSpec.describe Binance::Api::Wapi do
  describe '#withdraw!' do
    let(:asset) { }
    let(:address) { }
    let(:addressTag) { }
    let(:amount) { }
    let(:name) { }
    let(:recv_window) { }
    let(:timestamp) { Configuration.timestamp }
    let(:signature) do
      Binance::Api::Configuration.signed_request_signature(payload: query_string)
    end

    subject do
      Binance::Api::Wapi.withdraw!(asset: asset, address: address, addressTag: addressTag, amount: amount,
                                   name: name, recvWindow: recv_window)
    end

    shared_examples 'a valid http request' do
      let(:params) { {
        asset: asset, address: address,
        addressTag: addressTag, amount: amount, name: name,
        recvWindow: recv_window, timestamp: timestamp
      }.delete_if { |key, value| value.nil? } }
      let(:request_body) { params.map { |key, value| "#{key}=#{value}" }.join('&') }
      let(:signature) do
        Binance::Api::Configuration.signed_request_signature(payload: request_body)
      end

      context 'when api responds with error' do
        let!(:request_stub) do
          stub_request(:post, "https://api.binance.com/wapi/v3/withdraw.html")
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
          stub_request(:post, "https://api.binance.com/wapi/v3/withdraw.html")
            .with(body: request_body + "&signature=#{signature}")
            .to_return(status: 200, body: json_fixture('withdraw'))
        end

        it { is_expected.to include(:msg, :success, :id) }

        it 'should send api request' do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end
    end

    context 'a valid withdraw' do
      context 'when asset is nil' do
        let(:asset) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context 'when address is nil' do
        let(:address) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context 'when amount is nil' do
        let(:amount) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context 'when timestamp is nil' do
        let(:timestamp) { nil }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context 'when all required values are not nil' do
        let(:asset) { 'PAX' }
        let(:address) { '0x8e870d67f660d95d5be530380d0ec0bd388289e1' }
        let(:amount) { 100 }
        let(:timestamp) { Binance::Api::Configuration.timestamp }

        include_examples 'a valid http request'
      end
    end
  end
end
