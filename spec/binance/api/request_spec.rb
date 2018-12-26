require 'spec_helper'

RSpec.describe Binance::Api::Request do
  describe '#send!' do
    context 'with valid JSON response' do
      before do
        stub_request(method, 'https://api.binance.com')
          .to_return(body: {}.to_json)
      end

      subject { Binance::Api::Request.send!(method: method) }

      context 'when method is invalid' do
        let(:method) { :random }

        it { is_expected_block.to raise_error Binance::Api::Error }
      end

      context 'when method is :get' do
        let(:method) { :get }

        it { is_expected.to eq({}) }
      end

      context 'when method is :post' do
        let(:method) { :post }

        it { is_expected.to eq({}) }
      end

      context 'when method is :put' do
        let(:method) { :put }

        it { is_expected.to eq({}) }
      end

      context 'when method is :delete' do
        let(:method) { :delete }

        it { is_expected.to eq({}) }
      end
    end

    context 'when handling invalid JSON response' do
      let(:method) { :get }
      let(:fivehundred_error) { file_fixture("500_error.html") }

      subject { Binance::Api::Request.send!(method: method) }

      before do
        stub_request(method, 'https://api.binance.com')
          .to_return(body: fivehundred_error)
      end

      it { is_expected_block.to raise_error Binance::Api::Error }
    end
  end
end
