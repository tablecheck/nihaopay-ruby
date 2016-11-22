require_relative '../spec_helper'

class ApiTest
  include Nihaopay::Api
end

describe Nihaopay::Api do
  let(:token) { '6c4dc4828474fa73c5f438a9eb2f' }

  before do
    Nihaopay.test_mode = true
    Nihaopay.token = token
  end

  describe 'ClassMethods' do
    describe '.host' do
      context 'when test mode' do
        it { expect(ApiTest.host).to eq 'http://api.test.nihaopay.com' }
      end

      context 'when not test mode' do
        before { Nihaopay.test_mode = false }
        it { expect(ApiTest.host).to eq 'https://api.nihaopay.com' }
      end
    end

    describe '.base_url' do
      it { expect(ApiTest.base_url).to eq 'http://api.test.nihaopay.com/v1.1' }
    end

    describe '.authorization' do
      let(:expected) { { 'Authorization' => "Bearer #{token}" } }
      it { expect(ApiTest.authorization).to eq expected }
    end

    describe '.merchant_token' do
      context 'when local' do
        let(:token_2) { 'bf3092e441d9f2ea5fbcf93b51a2' }
        before { ApiTest.instance_variable_set(:@token, token_2) }
        it { expect(ApiTest.merchant_token).to eq token_2 }
        after { ApiTest.instance_variable_set(:@token, nil) }
      end

      context 'when global' do
        it { expect(ApiTest.merchant_token).to eq token }
      end
    end

    describe '.validate_resource!' do
      before { allow(response).to receive(:parsed_response) { parsed_response } }
      let(:response) { Object.new }
      let(:parsed_response) { nil }

      context 'when parsed_response not contains :id' do
        let(:parsed_response) { { 'code' => 200 } }
        it { expect { ApiTest.validate_resource!(response) }.to raise_error(Nihaopay::TransactionError) }
      end

      context 'when parsed_response contains :id' do
        let(:parsed_response) { { 'id' => '20160714132438002485', 'code' => 200 } }
        it { expect { ApiTest.validate_resource!(response) }.to_not raise_error(Nihaopay::TransactionError) }
      end
    end

    describe '.validate_collection!' do
      before { allow(response).to receive(:parsed_response) { parsed_response } }
      let(:response) { Object.new }
      let(:parsed_response) { nil }

      context 'when parsed_response not contains :transactions' do
        let(:parsed_response) { { 'code' => 200 } }
        it { expect { ApiTest.validate_collection!(response) }.to raise_error(Nihaopay::TransactionError) }
      end

      context 'when parsed_response contains :transactions' do
        let(:parsed_response) { { 'transactions' => [{ 'id' => '20160714132438002485', 'code' => 200 }] } }
        it { expect { ApiTest.validate_collection!(response) }.to_not raise_error(Nihaopay::TransactionError) }
      end
    end
  end
end
