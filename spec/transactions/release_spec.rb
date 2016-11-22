require_relative '../spec_helper'

describe Nihaopay::Transactions::Release do
  before do
    Nihaopay.test_mode = true
    Nihaopay.token = token
  end
  let(:token) { 'merchanttoken1' }
  let(:attrs) do
    { token: token,
      transaction_id: '2222',
      status: 'success',
      released: true,
      release_transaction_id: '1111' }
  end
  let(:release_txn) { described_class.new(attrs) }

  describe '.attr_accessor' do
    subject { release_txn }
    it { is_expected.to respond_to :released= }
    it { is_expected.to respond_to :released }
    it { is_expected.to respond_to :release_transaction_id= }
    it { is_expected.to respond_to :release_transaction_id }
  end

  describe '.start' do
    before do
      allow(response).to receive(:parsed_response) { parsed_response }
      allow(HTTParty).to receive(:post) { response }
    end
    let(:url) { 'http://api.test.nihaopay.com/v1.1/transactions/1111/release' }
    let(:headers) do
      { 'Authorization' => "Bearer #{token}",
        'Content-Type' => 'application/x-www-form-urlencoded' }
    end
    let(:response) { Object.new }
    let(:parsed_response) do
      { 'id' => '2222',
        'status' => 'success',
        'released' => true,
        'transaction_id' => '1111' }
    end

    context 'without options' do
      it { expect(HTTParty).to receive(:post).with(url, headers: headers, body: '') }
      after { described_class.start('1111') }
    end

    context 'with :token in options' do
      let(:options) { { token: 'merchanttoken2' } }
      let(:headers) do
        { 'Authorization' => 'Bearer merchanttoken2',
          'Content-Type' => 'application/x-www-form-urlencoded' }
      end
      it { expect(HTTParty).to receive(:post).with(url, headers: headers, body: '') }
      after do
        described_class.start('1111', options)
        described_class.instance_variable_set(:@token, nil)
      end
    end

    describe '.build_from_response!' do
      it 'should return transaction object' do
        txn = described_class.start('1111')
        expect(txn).to be_a Nihaopay::Transactions::Base
        expect(txn.transaction_id).to eq '2222'
        expect(txn.status).to eq 'success'
        expect(txn.released).to be true
        expect(txn.release_transaction_id).to eq '1111'
      end
    end
  end

  describe '.valid_attributes' do
    let(:expectation) { %i(transaction_id status released release_transaction_id) }
    it { expect(described_class.valid_attributes).to eq expectation }
  end

  describe '.response_keys_map' do
    let(:expectation) { { id: :transaction_id, transaction_id: :release_transaction_id } }
    it { expect(described_class.response_keys_map).to eq expectation }
  end
end
