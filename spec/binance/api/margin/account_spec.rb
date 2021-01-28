require "spec_helper"

RSpec.describe Binance::Api::Margin::Account do
  describe "#transfer!" do
    let(:asset) { }
    let(:amount) { }
    let(:timestamp) { }
    let(:recvWindow) { }
    let(:params) {
      {
        asset: asset, amount: amount, type: type, recvWindow: recvWindow, timestamp: timestamp,
      }.delete_if { |key, value| value.nil? }
    }
    let(:request_body) { params.map { |key, value| "#{key}=#{value}" }.join("&") }
    let(:type) { }

    subject do
      Binance::Api::Margin::Account.transfer!(
        asset: asset, amount: amount, type: type, recvWindow: recvWindow,
      )
    end

    shared_examples "a valid http request" do
      context "when api responds with error" do
        let!(:request_stub) do
          stub_request(:post, "https://api.binance.com/sapi/v1/margin/transfer")
            .with(body: request_body)
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
          stub_request(:post, "https://api.binance.com/sapi/v1/margin/transfer")
            .with(body: request_body)
            .to_return(status: 200, body: json_fixture("margin"))
        end

        it {
          is_expected.to include(:tranId)
        }

        it "should send api request" do
          subject
          expect(request_stub).to have_been_requested
        end
      end
    end

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
      let(:asset) { "BTC" }
      let(:amount) { 500 }
      let(:timestamp) { Binance::Api::Configuration.timestamp }
      let(:recvWindow) { 600 }
      let(:type) { 1 }

      include_examples "a valid http request"
    end
  end
end
