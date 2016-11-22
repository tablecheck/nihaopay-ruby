require_relative '../spec_helper'

describe Nihaopay::SecurePay::AliPay do
  before do
    Nihaopay.test_mode = true
    Nihaopay.token = token
  end
  let(:token) { '6c4dc4828474fa73c5f438a9eb2f' }

  describe '.vendor' do
    it { expect(described_class.vendor).to eq :alipay }
  end

  describe '.start' do
    let(:url) { 'http://api.test.nihaopay.com/v1.1/transactions/securepay' }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }

    context 'without options' do
      let(:body) { 'amount=1000&currency=JPY&vendor=alipay&reference=&ipn_url=&callback_url=' }
      let(:response) { OpenStruct.new(code: 200, body: '<html></html>') }
      it { expect(HTTParty).to receive(:post).with(url, headers: headers, body: body) { response } }
      after { described_class.start(1000, 'JPY') }
    end

    context 'with options' do
      let(:options) do
        { reference: '3461fcc31aec471780ad1a4dc6111947',
          ipn_url: 'http://website.com/ipn',
          callback_url: 'http://website.com/callback' }
      end
      let(:body) do
        'amount=1000'\
        '&currency=JPY'\
        '&vendor=alipay'\
        '&reference=3461fcc31aec471780ad1a4dc61119'\
        '&ipn_url=http://website.com/ipn'\
        '&callback_url=http://website.com/callback'
      end
      let(:response) { OpenStruct.new(code: 200, body: '<html></html>') }
      it { expect(HTTParty).to receive(:post).with(url, headers: headers, body: body) { response } }
      after { described_class.start(1000, 'JPY', options) }
    end

    context 'with :token in options' do
      let(:options) do
        { token: '6c4dc4828474fa73c5f438a9eb2g',
          reference: '3461fcc31aec471780ad1a4dc6111947',
          ipn_url: 'http://website.com/ipn',
          callback_url: 'http://website.com/callback' }
      end
      let(:headers) { { 'Authorization' => 'Bearer 6c4dc4828474fa73c5f438a9eb2g' } }
      let(:body) do
        'amount=1000'\
        '&currency=JPY'\
        '&vendor=alipay'\
        '&reference=3461fcc31aec471780ad1a4dc61119'\
        '&ipn_url=http://website.com/ipn'\
        '&callback_url=http://website.com/callback'
      end
      let(:response) { OpenStruct.new(code: 200, body: '<html></html>') }
      it { expect(HTTParty).to receive(:post).with(url, headers: headers, body: body) { response } }
      after do
        described_class.start(1000, 'JPY', options)
        described_class.instance_variable_set(:@token, nil)
      end
    end

    context 'with failure response' do
      let(:body) { 'amount=1000&currency=JPY&vendor=alipay&reference=&ipn_url=&callback_url=' }
      let(:response) { OpenStruct.new(code: 401, body: '<html></html>', parsed_response: { message: 'Unauthorized' }) }
      before { allow(HTTParty).to receive(:post) { response } }
      it { expect { described_class.start(1000, 'JPY') }.to raise_error ::Nihaopay::SecurePayTransactionError }
    end
  end

  describe '.request_url' do
    let(:expected) { 'http://api.test.nihaopay.com/v1.1/transactions/securepay' }
    it { expect(described_class.request_url).to eq expected }
  end

  describe '.request_headers' do
    let(:expected) { { 'Authorization' => "Bearer #{token}" } }
    it { expect(described_class.request_headers).to eq expected }
  end

  describe '.request_params' do
    context 'when refrence more than 30 chars' do
      let(:options) do
        { reference: '3461fcc31aec471780ad1a4dc6111947',
          ipn_url: 'http://website.com/ipn',
          callback_url: 'http://website.com/callback' }
      end
      subject { described_class.request_params(1000, 'JPY', options) }
      it { expect(subject[:reference]).to eq '3461fcc31aec471780ad1a4dc61119' }
    end

    context 'when options not in required format' do
      let(:options) do
        { reference: :a3461fcc,
          ipn_url: 'http://website.com/ipn',
          callback_url: 'http://website.com/callback' }
      end
      subject { described_class.request_params(1000.3, :JPY, options) }
      it { expect(subject[:amount]).to eq 1000 }
      it { expect(subject[:currency]).to eq 'JPY' }
      it { expect(subject[:vendor]).to eq 'alipay' }
      it { expect(subject[:reference]).to eq 'a3461fcc' }
      it { expect(subject[:ipn_url]).to eq 'http://website.com/ipn' }
      it { expect(subject[:callback_url]).to eq 'http://website.com/callback' }
    end
  end
end
