require_relative 'spec_helper'

describe Nihaopay::Merchant do
  let(:token) { '6c4dc4828474fa73c5f438a9eb2' }
  let(:merchant) { described_class.new(token) }

  describe '#attr_accessor' do
    subject { merchant }
    it { is_expected.to respond_to :token= }
    it { is_expected.to respond_to :token }
  end

  describe '#initialize' do
    it { expect(merchant.token).to eq token }
  end

  describe '#union_pay' do
    context 'when options not passed' do
      it { expect(Nihaopay::SecurePay::UnionPay).to receive(:start).with(100, 'JPY', token: token) }
      after { merchant.union_pay(100, 'JPY') }
    end

    context 'when options passed' do
      let(:options) do
        { reference: '3461fcc31aec471780ad1a4dc6111947',
          ipn_url: 'http://website.com/ipn',
          callback_url: 'http://website.com/callback' }
      end
      let(:expected_opts) { options.merge(token: token) }
      it { expect(Nihaopay::SecurePay::UnionPay).to receive(:start).with(100, 'JPY', expected_opts) }
      after { merchant.union_pay(100, 'JPY', options) }
    end
  end

  describe '#ali_pay' do
    context 'when options not passed' do
      it { expect(Nihaopay::SecurePay::AliPay).to receive(:start).with(100, 'JPY', token: token) }
      after { merchant.ali_pay(100, 'JPY') }
    end

    context 'when options passed' do
      let(:options) do
        { reference: '3461fcc31aec471780ad1a4dc6111947',
          ipn_url: 'http://website.com/ipn',
          callback_url: 'http://website.com/callback' }
      end
      let(:expected_opts) { options.merge(token: token) }
      it { expect(Nihaopay::SecurePay::AliPay).to receive(:start).with(100, 'JPY', expected_opts) }
      after { merchant.ali_pay(100, 'JPY', options) }
    end
  end

  describe '#wechat_pay' do
    context 'when options not passed' do
      it { expect(Nihaopay::SecurePay::WeChatPay).to receive(:start).with(100, 'JPY', token: token) }
      after { merchant.wechat_pay(100, 'JPY') }
    end

    context 'when options passed' do
      let(:options) do
        { reference: '3461fcc31aec471780ad1a4dc6111947',
          ipn_url: 'http://website.com/ipn',
          callback_url: 'http://website.com/callback' }
      end
      let(:expected_opts) { options.merge(token: token) }
      it { expect(Nihaopay::SecurePay::WeChatPay).to receive(:start).with(100, 'JPY', expected_opts) }
      after { merchant.wechat_pay(100, 'JPY', options) }
    end
  end

  describe '#authorize' do
    let(:cc_attrs) { { number: '6221558812340000', expiry_year: 17, expiry_month: 11, cvv: '123' } }
    let(:cc) { Nihaopay::CreditCard.new(cc_attrs) }

    context 'when options not passed' do
      it { expect(Nihaopay::Transactions::Authorize).to receive(:start).with(100, cc, token: token) }
      after { merchant.authorize(100, cc) }
    end

    context 'when options passed' do
      let(:options) do
        { currency: 'USD',
          description: 'Lorem Ipsum',
          reference: '3461fcc31aec471780ad1a4dc6111947' }
      end
      let(:expected_opts) { options.merge(token: token) }
      it { expect(Nihaopay::Transactions::Authorize).to receive(:start).with(100, cc, expected_opts) }
      after { merchant.authorize(100, cc, options) }
    end
  end

  describe '#capture' do
    it do
      expect(Nihaopay::Transactions::Capture).to receive(:start).with('20160718111604002633',
                                                                      100, 'JPY', token: token)
    end
    after { merchant.capture('20160718111604002633', 100, 'JPY') }
  end

  describe '#purchase' do
    let(:cc_attrs) { { number: '6221558812340000', expiry_year: 17, expiry_month: 11, cvv: '123' } }
    let(:cc) { Nihaopay::CreditCard.new(cc_attrs) }

    context 'when options not passed' do
      it { expect(Nihaopay::Transactions::Purchase).to receive(:start).with(100, cc, token: token) }
      after { merchant.purchase(100, cc) }
    end

    context 'when options passed' do
      let(:options) do
        { currency: 'USD',
          description: 'Lorem Ipsum',
          reference: '3461fcc31aec471780ad1a4dc6111947' }
      end
      let(:expected_opts) { options.merge(token: token) }
      it { expect(Nihaopay::Transactions::Purchase).to receive(:start).with(100, cc, expected_opts) }
      after { merchant.purchase(100, cc, options) }
    end
  end

  describe '#release' do
    let(:txn_id) { '20160718111604002633' }
    it { expect(Nihaopay::Transactions::Release).to receive(:start).with(txn_id, token: token) }
    after { merchant.release(txn_id) }
  end

  describe '#refund' do
    let(:txn_id) { '20160718111604002633' }

    context 'when options not passed' do
      it { expect(Nihaopay::Transactions::Refund).to receive(:start).with(txn_id, 100, 'JPY', token: token) }
      after { merchant.refund(txn_id, 100, 'JPY') }
    end

    context 'when options passed' do
      let(:options) { { reason: 'Out of stock' } }
      let(:expected_opts) { options.merge(token: token) }
      it { expect(Nihaopay::Transactions::Refund).to receive(:start).with(txn_id, 100, 'JPY', expected_opts) }
      after { merchant.refund(txn_id, 100, 'JPY', options) }
    end
  end
end
