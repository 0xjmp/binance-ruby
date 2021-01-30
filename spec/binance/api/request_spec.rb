require "spec_helper"

RSpec.describe Binance::Api::Request do
  describe "#send!" do
    before do
      stub_request(method, "https://api.binance.com")
        .to_return(body: {}.to_json)
    end

    subject { Binance::Api::Request.send!(method: method) }

    context "when method is invalid" do
      let(:method) { :random }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when method is :get" do
      let(:method) { :get }

      it { is_expected.to eq({}) }

      context "but json parser error" do
        before do
          allow(JSON).to receive(:parse).and_raise JSON::ParserError
        end

        it { is_expected_block.to raise_error Binance::Api::Error }
      end
    end

    context "when method is :post" do
      let(:method) { :post }

      it { is_expected.to eq({}) }
    end

    context "when method is :put" do
      let(:method) { :put }

      it { is_expected.to eq({}) }
    end

    context "when method is :delete" do
      let(:method) { :delete }

      it { is_expected.to eq({}) }
    end
  end
end
