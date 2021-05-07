require "spec_helper"

RSpec.describe Binance::WebSocket do
  let(:interval) { "1h" }
  let(:json_string) { '{ "result": null, "id": 312 }' }
  let(:stream_name) { nil }
  let(:symbols) { %w(ETHBTC) }
  let(:websocket) { Binance::WebSocket.new }

  describe "#candlesticks" do
    let(:stream_name) { "#{symbols.first.downcase}@kline_#{interval}" }

    before do
      stub_request(:any, "wss://stream.binance.com:9443/stream")
        .to_return(status: 200, body: "")
      events = OpenStruct.new(
        open: nil,
        message: nil,
        close: nil,
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

    context "error" do
      let(:json_string) { '{ "error": {"code": 0, "msg": "Unknown property","id": 123} }' }

      subject { websocket.candlesticks!(symbols, interval) }

      it { is_expected_block.to raise_error Binance::WebSocket::Error }
    end

    context "kline" do
      let(:json_string) do
        {
          stream: stream_name,
          data: JSON.parse(File.read("spec/fixtures/kline.json"), symbolize_names: true),
        }.to_json
      end

      it "calls on_receive" do
        inc = 0
        websocket.candlesticks!(symbols, interval) { inc = 1 }
        expect(inc).to eq 1
      end
    end
  end
end
