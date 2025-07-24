require 'spec_helper'

RSpec.describe Binance::WebSocket do
  let(:interval) { '1h' }
  let(:json_string) { '{ "result": null, "id": 312 }' }
  let(:stream_name) { nil }
  let(:symbols) { %w[ETHBTC] }
  let(:websocket) { Binance::WebSocket.new }

  before do
    stub_request(:any, 'wss://stream.binance.com:9443/stream')
      .to_return(status: 200, body: '')
    events = OpenStruct.new(
      open: nil,
      message: nil,
      close: nil
    )
    allow_any_instance_of(Binance::WebSocket).to receive(:on) do |_ws, kind, &block|
      event = case kind
              when :open
              when :message
                OpenStruct.new(data: json_string)
              when :close
              end
      events.send("#{kind}=", -> { block.call(event) })
    end
    allow_any_instance_of(Binance::WebSocket).to receive(:send) do
      events.open&.call
      events.message&.call
      events.close&.call
    end
  end

  describe '#trades' do
    let(:stream_name) { "#{symbols.first.downcase}@kline" }

    context 'error' do
      let(:json_string) { '{ "error": {"code": 0, "msg": "Unknown property","id": 123} }' }

      subject { websocket.trades!(symbols) }

      it { is_expected_block.to raise_error Binance::WebSocket::Error }
    end

    context 'trade' do
      let(:json_string) do
        {
          stream: stream_name,
          data: JSON.parse(File.read('spec/fixtures/streams/trade.json'), symbolize_names: true)
        }.to_json
      end

      it 'calls on_receive' do
        inc = 0
        websocket.trades!(symbols) { inc = 1 }
        expect(inc).to eq 1
      end
    end
  end

  describe '#candlesticks' do
    let(:stream_name) { "#{symbols.first.downcase}@kline_#{interval}" }

    context 'error' do
      let(:json_string) { '{ "error": {"code": 0, "msg": "Unknown property","id": 123} }' }

      subject { websocket.candlesticks!(symbols, interval) }

      it { is_expected_block.to raise_error Binance::WebSocket::Error }
    end

    context 'kline' do
      let(:json_string) do
        {
          stream: stream_name,
          data: JSON.parse(File.read('spec/fixtures/kline.json'), symbolize_names: true)
        }.to_json
      end

      it 'calls on_receive' do
        inc = 0
        websocket.candlesticks!(symbols, interval) { inc = 1 }
        expect(inc).to eq 1
      end
    end
  end

  describe '#user_data_stream!' do
    let(:stream_name) { 'somerandom' }

    context 'error' do
      let(:json_string) { '{ "error": {"code": 0, "msg": "Unknown property","id": 123} }' }

      subject { websocket.user_data_stream!(stream_name) }

      it { is_expected_block.to raise_error Binance::WebSocket::Error }
    end

    context 'executionReport' do
      let(:json_string) do
        {
          stream: stream_name,
          data: JSON.parse(File.read('spec/fixtures/executionReport.json'), symbolize_names: true)
        }.to_json
      end

      it 'calls on_receive' do
        inc = 0
        websocket.user_data_stream!(stream_name) { inc = 1 }
        expect(inc).to eq 1
      end
    end
  end

  describe '#partial_book_depth!' do
    let(:stream_name) { "#{symbols.first.downcase}@depth" }

    context 'error' do
      let(:json_string) { '{ "error": {"code": 0, "msg": "Unknown property","id": 123} }' }

      subject { websocket.partial_book_depth!(symbols, 5) }

      it { is_expected_block.to raise_error Binance::WebSocket::Error }
    end

    context 'partial_book_depth' do
      let(:json_string) do
        {
          stream: stream_name,
          data: JSON.parse(File.read('spec/fixtures/streams/partial_book_depth.json'), symbolize_names: true)
        }.to_json
      end

      it 'calls on_receive' do
        inc = 0
        websocket.partial_book_depth!(symbols, 5, 100) { inc = 1 }
        expect(inc).to eq 1
      end
    end
  end

  describe '#book_depth!' do
    let(:stream_name) { "#{symbols.first.downcase}@depth" }

    context 'error' do
      let(:json_string) { '{ "error": {"code": 0, "msg": "Unknown property","id": 123} }' }

      subject { websocket.book_depth!(symbols) }

      it { is_expected_block.to raise_error Binance::WebSocket::Error }
    end

    context 'book_depth' do
      let(:json_string) do
        {
          stream: stream_name,
          data: JSON.parse(File.read('spec/fixtures/streams/book_depth.json'), symbolize_names: true)
        }.to_json
      end

      it 'calls on_receive' do
        inc = 0
        websocket.book_depth!(symbols, 100) { inc = 1 }
        expect(inc).to eq 1
      end
    end
  end
end
