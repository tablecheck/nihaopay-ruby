require_relative '../spec_helper'

describe Nihaopay::Transactions::Purchase do
  describe '.capture_param' do
    it { expect(described_class.capture_param).to be true }
  end
end
