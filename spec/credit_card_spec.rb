require_relative 'spec_helper'

describe Nihaopay::CreditCard do
  let(:number) { '6221558812340000' }
  let(:attributes) { { number: number, expiry_year: 17, expiry_month: 11, cvv: '123' } }
  let(:cc) { described_class.new(attributes) }

  describe '#attr_accessor' do
    subject { described_class.new }
    it { is_expected.to respond_to :number= }
    it { is_expected.to respond_to :number }
    it { is_expected.to respond_to :expiry_year= }
    it { is_expected.to respond_to :expiry_year }
    it { is_expected.to respond_to :expiry_month= }
    it { is_expected.to respond_to :expiry_month }
    it { is_expected.to respond_to :cvv= }
    it { is_expected.to respond_to :cvv }
  end

  describe '#initialize' do
    context 'when attributes not passed' do
      subject { described_class.new }
      it { is_expected.to be_a Nihaopay::CreditCard }
    end

    context 'when attributes passed as stringified hash' do
      subject { described_class.new(Nihaopay::HashUtil.stringify_keys(attributes)) }
      it { expect(subject.number).to eq number }
      it { expect(subject.expiry_year).to eq 17 }
      it { expect(subject.expiry_month).to eq 11 }
      it { expect(subject.cvv).to eq '123' }
    end

    context 'with invalid attributes' do
      subject { described_class.new(foo: 'bar') }
      it { is_expected.to be_a Nihaopay::CreditCard }
      it { expect(subject.number).to be_nil }
      it { expect(subject.expiry_year).to be_nil }
      it { expect(subject.expiry_month).to be_nil }
      it { expect(subject.cvv).to be_nil }
    end

    context 'with valid attributes' do
      subject { cc }
      it { expect(subject.number).to eq number }
      it { expect(subject.expiry_year).to eq 17 }
      it { expect(subject.expiry_month).to eq 11 }
      it { expect(subject.cvv).to eq '123' }
    end
  end

  describe '#to_params_hash' do
    let(:expected) { { card_number: number, card_exp_year: 17, card_exp_month: 11, card_cvv: '123' } }
    it { expect(cc.to_params_hash).to eq expected }
  end
end
