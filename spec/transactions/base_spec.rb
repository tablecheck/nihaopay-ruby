require_relative '../spec_helper'

describe Nihaopay::Transactions::Base do
  before do
    Nihaopay.test_mode = true
    Nihaopay.token = token
  end
  let(:token) { 'merchanttoken1' }
  let(:txn_id) { '20160714132438002485' }
  let(:attrs) do
    { token: token,
      transaction_id: txn_id,
      type: 'charge',
      status: 'success',
      amount: 1000,
      currency: 'JPY',
      time: '2016-06-01T01:00:00Z',
      reference: 'reference',
      note: 'note-to-self' }
  end
  let(:base) { described_class.new(attrs) }

  describe '.attr_accessor' do
    subject { base }
    it { is_expected.to respond_to :token= }
    it { is_expected.to respond_to :token }
    it { is_expected.to respond_to :transaction_id= }
    it { is_expected.to respond_to :transaction_id }
    it { is_expected.to respond_to :type= }
    it { is_expected.to respond_to :type }
    it { is_expected.to respond_to :status= }
    it { is_expected.to respond_to :status }
    it { is_expected.to respond_to :captured= }
    it { is_expected.to respond_to :captured }
    it { is_expected.to respond_to :reference= }
    it { is_expected.to respond_to :reference }
    it { is_expected.to respond_to :currency= }
    it { is_expected.to respond_to :currency }
    it { is_expected.to respond_to :amount= }
    it { is_expected.to respond_to :amount }
    it { is_expected.to respond_to :note= }
    it { is_expected.to respond_to :note }
    it { is_expected.to respond_to :time= }
    it { is_expected.to respond_to :time }
  end

  describe '#initialize' do
    context 'when attributes not passed' do
      subject { described_class.new }
      it { is_expected.to be_a Nihaopay::Transactions::Base }
    end

    context 'when attributes passed' do
      subject { base }
      it { is_expected.to be_a Nihaopay::Transactions::Base }
      it { expect(subject.token).to eq token }
      it { expect(subject.transaction_id).to eq txn_id }
      it { expect(subject.type).to eq 'charge' }
      it { expect(subject.status).to eq 'success' }
      it { expect(subject.currency).to eq 'JPY' }
      it { expect(subject.reference).to eq 'reference' }
      it { expect(subject.amount).to eq 1000 }
      it { expect(subject.note).to eq 'note-to-self' }
      it { expect(subject.time).to eq '2016-06-01T01:00:00Z' }
    end

    context 'with invalid attributes' do
      subject { described_class.new(foo: :bar) }
      it { is_expected.to be_a Nihaopay::Transactions::Base }
    end
  end

  describe '#capture' do
    it { expect(Nihaopay::Transactions::Capture).to receive(:start).with(txn_id, 1000, 'JPY', token: token) }
    after { base.capture }
  end

  describe '#partial_capture' do
    it { expect(Nihaopay::Transactions::Capture).to receive(:start).with(txn_id, 500, 'JPY', token: token) }
    after { base.partial_capture(500) }
  end

  describe '#release' do
    it { expect(Nihaopay::Transactions::Release).to receive(:start).with(txn_id, token: token) }
    after { base.release }
  end

  describe '#cancel' do
    it { expect(Nihaopay::Transactions::Cancel).to receive(:start).with(txn_id, token: token) }
    after { base.cancel }
  end

  describe '#refund' do
    context 'without options' do
      it { expect(Nihaopay::Transactions::Refund).to receive(:start).with(txn_id, 1000, 'JPY', token: token) }
      after { base.refund }
    end

    context 'with options' do
      let(:expected_opts) { { reason: 'out of stock', token: token } }
      it { expect(Nihaopay::Transactions::Refund).to receive(:start).with(txn_id, 1000, 'JPY', expected_opts) }
      after { base.refund(reason: 'out of stock') }
    end
  end

  describe '#partial_refund' do
    context 'without options' do
      it { expect(Nihaopay::Transactions::Refund).to receive(:start).with(txn_id, 500, 'JPY', token: token) }
      after { base.partial_refund(500) }
    end

    context 'with options' do
      let(:expected_opts) { { reason: 'out of stock', token: token } }
      it { expect(Nihaopay::Transactions::Refund).to receive(:start).with(txn_id, 500, 'JPY', expected_opts) }
      after { base.partial_refund(500, reason: 'out of stock') }
    end
  end

  describe '.request_headers' do
    let(:expectation) do
      { 'Authorization' => "Bearer #{token}",
        'Content-Type' => 'application/x-www-form-urlencoded' }
    end
    it { expect(described_class.request_headers).to eq expectation }
  end

  describe '.build' do
    context 'when options not passed' do
      subject { described_class.build }
      it { is_expected.to be_a Nihaopay::Transactions::Base }
      it { expect(subject.token).to eq token }
    end

    context 'with options' do
      let(:options) do
        opts = attrs.merge(id: '123456', token: 'merchanttoken2', captured: true)
        opts.delete(:transaction_id)
        opts
      end
      subject { described_class.build(options) }
      it { is_expected.to be_a Nihaopay::Transactions::Base }
      it { expect(subject.transaction_id).to eq '123456' }
      it { expect(subject.token).to eq 'merchanttoken2' }
      it { expect(subject.captured).to be true }
      it { expect(subject.time).to eq '2016-06-01T01:00:00Z' }
    end

    context 'with options with string keys' do
      let(:options) do
        opts = Nihaopay::HashUtil.stringify_keys(attrs)
        opts['id'] = '123456'
        opts.delete('transaction_id')
        opts
      end
      subject { described_class.build(options) }
      it { is_expected.to be_a Nihaopay::Transactions::Base }
      it { expect(subject.transaction_id).to eq '123456' }
    end

    context 'without token' do
      let(:options) do
        opts = attrs
        opts[:id] = '123456'
        opts.delete(:transaction_id)
        opts.delete(:token)
        opts
      end
      subject { described_class.build(options) }
      it { is_expected.to be_a Nihaopay::Transactions::Base }
      it { expect(subject.token).to eq 'merchanttoken1' }
    end

    context 'when time not returned in response' do
      let(:options) do
        opts = attrs.merge(id: '123456')
        opts.delete(:time)
        opts
      end
      before { allow(Time).to receive_message_chain(:now, :strftime) { '2017-01-17T16:00:00+0900' } }
      subject { described_class.build(options) }
      it { expect(subject.time).to eq '2017-01-17T16:00:00+0900' }
    end
  end

  describe '.valid_attributes' do
    let(:expectation) do
      %i(token transaction_id type status captured currency reference amount note time)
    end
    it { expect(described_class.valid_attributes).to eq expectation }
  end

  describe '.response_keys_map' do
    let(:expectation) { { id: :transaction_id } }
    it { expect(described_class.response_keys_map).to eq expectation }
  end
end
