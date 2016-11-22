require_relative '../spec_helper'

describe Nihaopay::SecurePay::WeChatPay do
  before do
    Nihaopay.test_mode = true
    Nihaopay.token = token
  end
  let(:token) { '6c4dc4828474fa' }

  describe '.vendor' do
    it { expect(described_class.vendor).to eq :wechatpay }
  end
end
