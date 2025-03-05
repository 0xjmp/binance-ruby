require "spec_helper"

RSpec.describe Binance::Api do
  it "has a version number" do
    expect(Binance::Api::VERSION).not_to be nil
  end

  shared_examples "a valid http request" do
    it "should send api request" do
      subject rescue Binance::Api::Error
      expect(request_stub).to have_been_requested
    end
  end

  describe "#all_coins_info!" do
    let(:params) { { timestamp: timestamp } }
    let(:query_string) { params.delete_if { |key, value| value.nil? }.map { |key, value| "#{key}=#{value}" }.join("&") }
    let(:signature) do
      Binance::Api::Configuration.signed_request_signature(payload: query_string)
    end
    let(:timestamp) { Binance::Api::Configuration.timestamp }

    subject { Binance::Api.all_coins_info! }

    context "when api responds with error" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/sapi/v1/capital/config/getall")
          .with(query: query_string + "&signature=#{signature}")
          .to_return(status: 400, body: { msg: "error", code: "400" }.to_json)
      end

      it { is_expected_block.to raise_error Binance::Api::Error }

      include_examples "a valid http request"
    end

    context "when api succeeds" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/sapi/v1/capital/config/getall")
          .with(query: query_string + "&signature=#{signature}")
          .to_return(status: 200, body: json_fixture("candlesticks"))
      end

      it { is_expected.not_to be_empty }

      include_examples "a valid http request"
    end
  end

  describe "#candlesticks!" do
    let(:end_time) { "" }
    let(:interval) { :daily } # TODO: confirm enums
    let(:limit) { 100 }
    let(:start_time) { "" }
    let(:symbol) { "BTCLTC" }

    subject do
      Binance::Api.candlesticks!(endTime: end_time, interval: interval,
                                 limit: limit, startTime: start_time,
                                 symbol: symbol)
    end

    context "when interval is nil" do
      let(:interval) { nil }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when symbol is nil" do
      let(:symbol) { nil }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when api responds with error" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/klines")
          .with(query: { endTime: end_time, interval: interval, limit: limit, startTime: start_time, symbol: symbol })
          .to_return(status: 400, body: { msg: "error", code: "400" }.to_json)
      end

      it { is_expected_block.to raise_error Binance::Api::Error }

      include_examples "a valid http request"
    end

    context "when api succeeds" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/klines")
          .with(query: { endTime: end_time, interval: interval, limit: limit, startTime: start_time, symbol: symbol })
          .to_return(status: 200, body: json_fixture("candlesticks"))
      end

      it { is_expected.not_to be_empty }

      include_examples "a valid http request"
    end
  end

  describe "#compressed_aggregate_trades!" do
    let(:from_id) { "" }
    let(:end_time) { "" }
    let(:limit) { 100 }
    let(:start_time) { "" }
    let(:symbol) { "BTCLTC" }

    subject {
      Binance::Api.compressed_aggregate_trades!(fromId: from_id, endTime: end_time, limit: limit,
                                                startTime: start_time, symbol: symbol)
    }

    context "when symbol is nil" do
      let(:symbol) { nil }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when api responds with error" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/aggTrades")
          .with(query: { fromId: from_id, endTime: end_time, limit: limit, startTime: start_time, symbol: symbol })
          .to_return(status: 400, body: { msg: "error", code: "400" }.to_json)
      end

      it { is_expected_block.to raise_error Binance::Api::Error }

      include_examples "a valid http request"
    end

    context "when api succeeds" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/aggTrades")
          .with(query: { fromId: from_id, endTime: end_time, limit: limit, startTime: start_time, symbol: symbol })
          .to_return(status: 200, body: json_fixture("compressed_aggregate_trades"))
      end

      it "responds with aggregate trades" do
        expect(subject.first).to include(:a, :p, :q, :f, :l, :T, :m, :M)
      end

      include_examples "a valid http request"
    end
  end

  describe "#depth!" do
    let(:limit) { 100 }
    let(:symbol) { "BTCLTC" }

    subject { Binance::Api.depth!(symbol: symbol, limit: limit) }

    context "when symbol is nil" do
      let(:symbol) { nil }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when api responds with error" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/depth")
          .with(query: { limit: limit, symbol: symbol })
          .to_return(status: 400, body: { msg: "error", code: "400" }.to_json)
      end

      it { is_expected_block.to raise_error Binance::Api::Error }

      include_examples "a valid http request"
    end

    context "when api succeeds" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/depth")
          .with(query: { limit: limit, symbol: symbol })
          .to_return(status: 200, body: json_fixture("depth"))
      end

      it { is_expected.to include(:lastUpdateId, :bids, :asks) }

      include_examples "a valid http request"
    end
  end

  describe "#exchange_info!" do
    subject { Binance::Api.exchange_info! }

    context "when api responds with error" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/exchangeInfo")
          .to_return(status: 400, body: { msg: "error", code: "400" }.to_json)
      end

      it { is_expected_block.to raise_error Binance::Api::Error }

      include_examples "a valid http request"
    end

    context "when api succeeds" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/exchangeInfo")
          .to_return(status: 200, body: json_fixture("exchange_info"))
      end

      it { is_expected.to include(:rateLimits, :symbols) }

      include_examples "a valid http request"
    end
  end

  describe "#historical_trades!" do
    let(:from_id) { "" }
    let(:limit) { 500 }
    let(:symbol) { "BTCLTC" }

    subject { Binance::Api.historical_trades!(fromId: from_id, symbol: symbol, limit: limit) }

    context "when symbol is nil" do
      let(:symbol) { nil }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when api responds with error" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/historicalTrades")
          .with(query: { fromId: from_id, limit: limit, symbol: symbol })
          .to_return(status: 400, body: { msg: "error", code: "400" }.to_json)
      end

      it { is_expected_block.to raise_error Binance::Api::Error }

      include_examples "a valid http request"
    end

    context "when api succeeds" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/historicalTrades")
          .with(query: { fromId: from_id, limit: limit, symbol: symbol })
          .to_return(status: 200, body: json_fixture("trades"))
      end

      it "should include trade keys" do
        expect(subject.first).to include(:id, :price, :qty, :time, :isBuyerMaker,
                                         :isBestMatch)
      end

      include_examples "a valid http request"
    end
  end

  describe "#info!" do
    let(:params) { { recvWindow: recv_window, timestamp: timestamp } }
    let(:query_string) { params.delete_if { |key, value| value.nil? }.map { |key, value| "#{key}=#{value}" }.join("&") }
    let(:recv_window) { nil }
    let(:signature) do
      Binance::Api::Configuration.signed_request_signature(payload: query_string)
    end
    let(:timestamp) { Binance::Api::Configuration.timestamp }

    subject { Binance::Api.info!(recvWindow: recv_window) }

    context "when api fails" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v3/account")
          .with(query: query_string + "&signature=#{signature}")
          .to_return(status: 400, body: { msg: "error", code: "400" }.to_json)
      end

      it { is_expected_block.to raise_error Binance::Api::Error }

      include_examples "a valid http request"
    end

    context "when api succeeds" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v3/account")
          .with(query: query_string + "&signature=#{signature}")
          .to_return(status: 200, body: json_fixture("account"))
      end

      it {
        is_expected.to include(:makerCommission, :takerCommission, :buyerCommission,
                               :sellerCommission, :canTrade, :canWithdraw, :canDeposit,
                               :updateTime, :balances)
      }

      include_examples "a valid http request"
    end
  end

  describe "#ping!" do
    subject { Binance::Api.ping! }

    context "when api responds with error" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/ping")
          .to_return(status: 429, body: { msg: "rate limited", code: "429" }.to_json)
      end

      it { is_expected_block.to raise_error Binance::Api::Error }

      include_examples "a valid http request"
    end

    context "when api succeeds" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/ping")
          .to_return(status: 200, body: {}.to_json)
      end

      include_examples "a valid http request"
    end
  end

  describe "#ticker!" do
    let(:symbol) { nil }
    let(:symbols) { nil }

    subject { Binance::Api.ticker!(symbol: symbol, symbols: symbols, type: type) }

    shared_examples "a valid ticker request" do
      shared_examples "valid api responses" do
        context "when api responds with error" do
          let(:stub_response) { { status: 429, body: { msg: "rate limited", code: "429" }.to_json } }

          it { is_expected_block.to raise_error Binance::Api::Error }

          include_examples "a valid http request"
        end

        context "when api succeeds" do
          let(:stub_response) { { status: 200, body: fixture } }

          include_examples "a valid http request"
        end
      end

      context "when symbol is nil" do
        let(:symbol) { nil }

        include_examples "valid api responses"
      end

      context "when symbol is not nil" do
        let(:symbol) { "BTCLTC" }

        include_examples "valid api responses"
      end

      context "when symbols is not nil" do
        let(:symbols) { ["BTCLTC", "DOTUSDT"] }

        include_examples "valid api responses"
      end
    end

    context "when type is invalid" do
      let(:stub_response) { { status: 200, body: "{}" } }
      let(:type) { :holy_moly }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when type is daily" do
      let!(:request_stub) do
        url = "https://api.binance.com/api/v1/ticker/24hr"
        url += "?symbol=#{symbol}" if symbol
        stub_request(:get, url).to_return(stub_response)
      end
      let(:type) { :daily }

      context "when json response is singular" do
        let(:fixture) { json_fixture("ticker-24hr") }
        let(:stub_response) { { status: 200, body: fixture } }

        include_examples "a valid ticker request"

        it {
          is_expected.to include(:symbol, :priceChange, :priceChangePercent, :weightedAvgPrice,
                                 :prevClosePrice, :lastPrice, :lastQty, :bidPrice, :askPrice,
                                 :openPrice, :highPrice, :lowPrice, :volume, :quoteVolume, :openTime,
                                 :closeTime, :fristId, :lastId, :count)
        }
        # TODO: typo? ☝️
      end

      context "when json response is plural" do
        let(:fixture) { "[#{json_fixture("ticker-24hr")}]" }

        include_examples "a valid ticker request"
      end
    end

    context "when type is price" do
      let!(:request_stub) do
        url = "https://api.binance.com/api/v3/ticker/price"
        url += "?symbol=#{symbol}" if symbol
        url += "?symbols=#{symbols.to_s.delete(" ")}" if symbols
        stub_request(:get, url).to_return(stub_response)
      end
      let(:type) { :price }

      context "when json response is singular" do
        let(:fixture) { json_fixture("ticker-price") }
        let(:stub_response) { { status: 200, body: fixture } }

        include_examples "a valid ticker request"

        it { is_expected.to include(:symbol, :price) }
      end

      context "when json response is plural" do
        let(:fixture) { "[#{json_fixture("ticker-price")}]" }

        include_examples "a valid ticker request"
      end
    end

    context "when type is bookTicker" do
      let!(:request_stub) do
        url = "https://api.binance.com/api/v3/ticker/bookTicker"
        url += "?symbol=#{symbol}" if symbol
        stub_request(:get, url).to_return(stub_response)
      end
      let(:type) { :bookTicker }

      context "when json response is singular" do
        let(:fixture) { json_fixture("ticker-book_ticker") }
        let(:stub_response) { { status: 200, body: fixture } }

        include_examples "a valid ticker request"

        it { is_expected.to include(:symbol, :bidPrice, :bidQty, :askPrice, :askQty) }
      end

      context "when json response is plural" do
        let(:fixture) { "[#{json_fixture("ticker-book_ticker")}]" }
        let(:stub_response) { { status: 200, body: fixture } }

        include_examples "a valid ticker request"
      end
    end
  end

  describe "#time!" do
    subject { Binance::Api.time! }

    context "when api responds with error" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/time")
          .to_return(status: 500, body: { msg: "failure", code: "500" }.to_json)
      end

      it { is_expected_block.to raise_error Binance::Api::Error }

      include_examples "a valid http request"
    end

    context "when api succeeds" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/time")
          .to_return(status: 200, body: { serverTime: 4632823 }.to_json)
      end

      it { is_expected.to include(:serverTime) }

      include_examples "a valid http request"
    end
  end

  describe "#trades!" do
    let(:limit) { 500 }
    let(:symbol) { "BTCLTC" }

    subject { Binance::Api.trades!(symbol: symbol, limit: limit) }

    context "when symbol is nil" do
      let(:symbol) { nil }

      it { is_expected_block.to raise_error Binance::Api::Error }
    end

    context "when api responds with error" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/trades")
          .with(query: { limit: limit, symbol: symbol })
          .to_return(status: 400, body: { msg: "error", code: "400" }.to_json)
      end

      it { is_expected_block.to raise_error Binance::Api::Error }

      include_examples "a valid http request"
    end

    context "when api succeeds" do
      let!(:request_stub) do
        stub_request(:get, "https://api.binance.com/api/v1/trades")
          .with(query: { limit: limit, symbol: symbol })
          .to_return(status: 200, body: json_fixture("trades"))
      end

      it "should include trade keys" do
        expect(subject.first).to include(:id, :price, :qty, :time, :isBuyerMaker,
                                         :isBestMatch)
      end

      include_examples "a valid http request"
    end
  end
end
