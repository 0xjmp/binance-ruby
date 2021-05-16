require "spec_helper"

RSpec.describe Binance::Api::Account do
  describe "#fees!" do
    let(:params) { { recv_window: recv_window, timestamp: timestamp } }
    let(:query_string) { params.delete_if { |key, value| value.nil? }.map { |key, value| "#{key}=#{value}" }.join("&") }
    let(:recv_window) { }
    let(:signature) do
      signature_string = Binance::Api::Configuration.signed_request_signature(payload: query_string)
      CGI.escape(signature_string)
    end
    let(:timestamp) { Binance::Api::Configuration.timestamp }

    subject { Binance::Api::Account.fees!(recvWindow: recv_window) }

    context "when api responds with error" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/wapi/v3/assetDetail.html")
          .with(query: query_string + "&signature=#{signature}")
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
        stub_request(:get, "https://api.binance.com/wapi/v3/assetDetail.html")
          .with(query: query_string + "&signature=#{signature}")
          .to_return(status: 200, body: json_fixture("assetDetail"))
      end

      it { is_expected.to include(:success, :assetDetail) }

      it "should send api request" do
        subject rescue Binance::Api::Error
        expect(request_stub).to have_been_requested
      end
    end
  end

  describe "#info!" do
    let(:params) { { recv_window: recv_window, timestamp: timestamp } }
    let(:query_string) { params.delete_if { |key, value| value.nil? }.map { |key, value| "#{key}=#{value}" }.join("&") }
    let(:recv_window) { }
    let(:signature) do
      signature_string = Binance::Api::Configuration.signed_request_signature(payload: query_string)
      CGI.escape(signature_string)
    end
    let(:timestamp) { Binance::Api::Configuration.timestamp }

    subject { Binance::Api::Account.info!(recvWindow: recv_window) }

    context "when api responds with error" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v3/account")
          .with(query: query_string + "&signature=#{signature}")
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
        stub_request(:get, "https://api.binance.com/api/v3/account")
          .with(query: query_string + "&signature=#{signature}")
          .to_return(status: 200, body: json_fixture("account"))
      end

      it {
        is_expected.to include(:makerCommission, :takerCommission, :buyerCommission, :sellerCommission,
                               :canTrade, :canWithdraw, :canDeposit, :updateTime, :balances)
      }

      it "should send api request" do
        subject rescue Binance::Api::Error
        expect(request_stub).to have_been_requested
      end
    end
  end

  describe "#trades!" do
    let(:from_id) { }
    let(:limit) { 500 }
    let(:params) { { fromId: from_id, limit: limit, recv_window: recv_window, symbol: symbol, timestamp: timestamp } }
    let(:query_string) { params.delete_if { |key, value| value.nil? }.map { |key, value| "#{key}=#{value}" }.join("&") }
    let(:recv_window) { }
    let(:signature) do
      signature_string = Binance::Api::Configuration.signed_request_signature(payload: query_string)
      CGI.escape(signature_string)
    end
    let(:symbol) { }
    let(:timestamp) { Binance::Api::Configuration.timestamp }

    subject { Binance::Api::Account.trades!(fromId: from_id, limit: limit, recvWindow: recv_window, symbol: symbol) }

    context "when limit is higher than max" do
      let(:limit) { 501 }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when symbol is nil" do
      let(:symbol) { nil }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when all required params are valid" do
      let(:symbol) { "BTCLTC" }

      context "but api responds with error" do
        let!(:request_stub) do
          stub_request(:get, "https://api.binance.com/api/v3/myTrades")
            .with(query: query_string + "&signature=#{signature}")
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
          stub_request(:get, "https://api.binance.com/api/v3/myTrades")
            .with(query: query_string + "&signature=#{signature}")
            .to_return(status: 200, body: "[#{json_fixture("trade")}]")
        end

        it "has trade keys" do
          expect(subject.first).to include(:id, :orderId, :price, :qty, :commission, :commissionAsset, :time,
                                           :isBuyer, :isMaker, :isBestMatch)
        end

        it "should send api request" do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end
    end
  end

  describe "#withdraw!" do
    let(:amount) { }
    let(:coin) { }
    let(:address) { }
    let(:params) { { coin: coin, address: address, timestamp: timestamp, amount: amount, transactionFeeFlag: false } }
    let(:query_string) { params.delete_if { |key, value| value.nil? }.map { |key, value| "#{key}=#{value}" }.join("&") }
    let(:signature) do
      signature_string = Binance::Api::Configuration.signed_request_signature(payload: query_string)
      CGI.escape(signature_string)
    end
    let(:timestamp) { Binance::Api::Configuration.timestamp }

    subject { Binance::Api::Account.withdraw!(coin: coin, amount: amount, address: address) }

    context "when amount is missing" do
      let(:coin) { "ETH" }
      let(:address) { "someaddress" }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when coin is missing" do
      let(:amount) { 0.1 }
      let(:address) { "someaddress" }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when address is missing" do
      let(:coin) { "ETH" }
      let(:amount) { 0.1 }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when all required params are valid" do
      let(:coin) { "ETH" }
      let(:address) { "someaddress" }
      let(:amount) { 0.1 }

      context "but api responds with error" do
        let!(:request_stub) do
          stub_request(:post, "https://api.binance.com/sapi/v1/capital/withdraw/apply")
            .with(body: query_string + "&signature=#{signature}")
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
          stub_request(:post, "https://api.binance.com/sapi/v1/capital/withdraw/apply")
            .with(body: query_string + "&signature=#{signature}")
            .to_return(status: 200, body: '{"id":"7213fea8e94b4a5593d507237e5a555b"}')
        end

        it "has trade keys" do
          expect(subject.first).to include(:id)
        end

        it "should send api request" do
          subject rescue Binance::Api::Error
          expect(request_stub).to have_been_requested
        end
      end
    end
  end
end
