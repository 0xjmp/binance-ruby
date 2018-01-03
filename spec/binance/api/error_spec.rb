require 'spec_helper'

RSpec.describe Binance::Api::Error do
  let(:error) { Binance::Api::Error.new(code: 400, message: 'Error!') }

  describe '#inspect' do
    subject { error.inspect }

    it { is_expected.not_to be_nil }
  end

  describe 'message' do
    subject { error.message }

    it { is_expected.not_to be_nil }
  end

  describe 'to_s' do
    subject { error.to_s }

    it { is_expected.not_to be_nil }
  end
end
