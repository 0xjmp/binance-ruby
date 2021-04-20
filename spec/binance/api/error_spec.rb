require "spec_helper"

RSpec.describe Binance::Api::Error do
  let(:symbol) { "ETHBTC" }
  let(:error) { Binance::Api::Error.new(code: 400, message: "Error!", symbol: symbol) }

  describe "#inspect" do
    subject { error.inspect }

    it { is_expected.not_to be_nil }
  end

  describe "message" do
    subject { error.message }

    it { is_expected.not_to be_nil }
  end

  describe "to_s" do
    subject { error.to_s }

    it { is_expected.not_to be_nil }
  end

  describe "symbol" do
    subject { symbol.to_s }

    it { is_expected.not_to be_nil }
  end

  describe "error_class" do
    subject { Binance::Api::Error.localized(message) }

    context "error" do
      let(:message) { "(-) some unknown error" }

      it { is_expected.to eq Binance::Api::Error }
    end

    shared_examples "a valid error" do |a_message, class_name|
      context name do
        let(:message) { a_message }

        it { is_expected.to eq Object.const_get("Binance::Api::Error::#{class_name}") }
      end
    end

    include_examples "a valid error", "(-1000) uh heres another 123", "Unknown"
    include_examples "a valid error", "(-1001) some error message", "Disconnected"
    include_examples "a valid error", "(-1002) some error message", "Unauthorized"
    include_examples "a valid error", "(-1003) some error message", "TooManyRequests"
    include_examples "a valid error", "(-1006) some error message", "UnexpectedResponse"
    include_examples "a valid error", "(-1007) some error message", "Timeout"
    include_examples "a valid error", "(-1014) some error message", "UnknownOrderComposition"
    include_examples "a valid error", "(-1015) some error message", "TooManyOrders"
    include_examples "a valid error", "(-1016) some error message", "ServiceShuttingDown"
    include_examples "a valid error", "(-1020) some error message", "UnsupportedOperation"
    include_examples "a valid error", "(-1021) some error message", "InvalidTimestamp"
    include_examples "a valid error", "(-1022) some error message", "InvalidSignature"
    include_examples "a valid error", "(-1100) some error message", "IllegalChars"
    include_examples "a valid error", "(-1101) some error message", "TooManyParameters"
    include_examples "a valid error", "(-1102) some error message", "MandatoryParamEmptyOrMalformed"
    include_examples "a valid error", "(-1103) some error message", "UnknownParam"
    include_examples "a valid error", "(-1104) some error message", "UnreadParameters"
    include_examples "a valid error", "(-1105) some error message", "ParamEmpty"
    include_examples "a valid error", "(-1106) some error message", "ParamNotRequired"
    include_examples "a valid error", "(-1111) some error message", "BadPrecision"
    include_examples "a valid error", "(-1112) some error message", "NoDepth"
    include_examples "a valid error", "(-1114) some error message", "TIFNotRequired"
    include_examples "a valid error", "(-1115) some error message", "InvalidTIF"
    include_examples "a valid error", "(-1116) some error message", "InvalidOrderType"
    include_examples "a valid error", "(-1117) some error message", "InvalidSide"
    include_examples "a valid error", "(-1118) some error message", "EmptyNewCLOrderId"
    include_examples "a valid error", "(-1119) some error message", "EmptyOrgCLOrderId"
    include_examples "a valid error", "(-1120) some error message", "BadInterval"
    include_examples "a valid error", "(-1121) some error message", "BadSymbol"
    include_examples "a valid error", "(-1125) some error message", "InvalidListenKey"
    include_examples "a valid error", "(-1127) some error message", "IntervalTooLarge"
    include_examples "a valid error", "(-1128) some error message", "OptionalParamsBadCombo"
    include_examples "a valid error", "(-1130) some error message", "InvalidParameter"
    include_examples "a valid error", "(-2010) some error message", "NewOrderRejected"
    include_examples "a valid error", "(-2011) some error message", "CancelOrderRejected"
    include_examples "a valid error", "(-2013) some error message", "NoSuchOrder"
    include_examples "a valid error", "(-2014) some error message", "BadAPIKeyFormat"
    include_examples "a valid error", "(-2015) some error message", "RejectedAPIKey"
    include_examples "a valid error", "(-2016) some error message", "NoTradingWindow"
  end
end
