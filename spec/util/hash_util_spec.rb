require_relative '../spec_helper'

describe Nihaopay::HashUtil do
  subject { described_class }

  describe '::stringify_keys' do
    let(:hash) { { a: 1, 'b' => 2, 3 => 3 } }
    let(:exp) { { 'a' => 1, 'b' => 2, '3' => 3 } }
    it { expect(subject.stringify_keys(hash)).to eq exp }
  end

  describe '::symbolize_keys' do
    let(:hash) { { a: 1, 'b' => 2, 3 => 3 } }
    let(:exp) { { a: 1, b: 2, 3 => 3 } }
    it { expect(subject.symbolize_keys(hash)).to eq exp }
  end

  describe '::slice' do
    let(:hash) { { a: 1, 'b' => 2, 3 => 3 } }
    it { expect(subject.slice(hash, :a, :b, 3)).to eq(a: 1, 3 => 3) }
  end
end
