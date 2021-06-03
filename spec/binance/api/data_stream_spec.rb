require "spec_helper"

RSpec.describe Binance::Api::UserDataStream do
  let(:params) { {} }
  let(:request_body) { params.map { |key, value| "#{key}=#{value}" }.join("&") }

  describe "#keepalive!" do
    let(:params) { { listenKey: listen_key } }

    subject { Binance::Api::UserDataStream.keepalive!(listen_key: listen_key) }

    context "when listen_key is nil" do
      let(:listen_key) { nil }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when listen_key exists" do
      let(:listen_key) { "pqia91ma19a5s61cv6a81va65sdf19v8a65a1a5s61cv6a81va65sdf19v8a65a1" }

      context "but api responds with error" do
        let!(:request_stub) do
          stub_request(:put, "https://api.binance.com/api/v1/userDataStream")
            .with(query: request_body)
            .to_return(status: 400, body: { msg: "error", code: "400" }.to_json)
        end

        it { is_expected_block.to raise_error Binance::Api::Error }

        it "should send api request" do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end

      context "and api succeeds" do
        let!(:request_stub) do
          stub_request(:put, "https://api.binance.com/api/v1/userDataStream")
            .with(query: request_body)
            .to_return(status: 200, body: "{}")
        end

        it "should send api request" do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end
    end
  end

  describe "#start!" do
    let(:listen_key) { "pqia91ma19a5s61cv6a81va65sdf19v8a65a1a5s61cv6a81va65sdf19v8a65a1" }

    subject { Binance::Api::UserDataStream.start! }

    context "when listen_key exists" do
      context "but api responds with error" do
        let!(:request_stub) do
          stub_request(:post, "https://api.binance.com/api/v1/userDataStream")
            .to_return(status: 400, body: { msg: "error", code: "400" }.to_json)
        end

        it { is_expected_block.to raise_error Binance::Api::Error }

        it "should send api request" do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end

      context "and api succeeds" do
        let!(:request_stub) do
          stub_request(:post, "https://api.binance.com/api/v1/userDataStream")
            .to_return(status: 200, body: { listenKey: listen_key }.to_json)
        end

        it "responds with listen_key" do
          expect(subject).to eq(listen_key)
        end

        it "should send api request" do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end
    end
  end

  describe "#stop!" do
    let(:params) { { listenKey: listen_key } }

    subject { Binance::Api::UserDataStream.stop!(listen_key: listen_key) }

    context "when listen_key is nil" do
      let(:listen_key) { nil }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when listen_key exists" do
      let(:listen_key) { "pqia91ma19a5s61cv6a81va65sdf19v8a65a1a5s61cv6a81va65sdf19v8a65a1" }

      context "but api responds with error" do
        let!(:request_stub) do
          stub_request(:delete, "https://api.binance.com/api/v1/userDataStream")
            .with(query: request_body)
            .to_return(status: 400, body: { msg: "error", code: "400" }.to_json)
        end

        it { is_expected_block.to raise_error Binance::Api::Error }

        it "should send api request" do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end

      context "and api succeeds" do
        let!(:request_stub) do
          stub_request(:delete, "https://api.binance.com/api/v1/userDataStream")
            .with(query: request_body)
            .to_return(status: 200, body: "{}")
        end

        it "should send api request" do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end
    end
  end
end
