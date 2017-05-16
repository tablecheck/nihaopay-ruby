require_relative '../spec_helper'

describe Nihaopay::Transactions::Authorize do
  before do
    Nihaopay.test_mode = true
    Nihaopay.token = token
  end
  let(:token) { '6c4dc4828474f' }

  describe '.start' do
    before do
      allow(response).to receive(:parsed_response) { parsed_response }
      allow(HTTParty).to receive(:post) { response }
    end
    let(:cc_attrs) { { number: '6221558812340000', expiry_year: 17, expiry_month: 11, cvv: '123' } }
    let(:cc) { Nihaopay::CreditCard.new(cc_attrs) }
    let(:url) { 'http://api.test.nihaopay.com/v1.1/transactions/expresspay' }
    let(:headers) do
      { 'Authorization' => "Bearer #{token}",
        'Content-Type' => 'application/x-www-form-urlencoded' }
    end
    let(:response) { Object.new }
    let(:parsed_response) do
      { 'id' => '20160714132438002485',
        'status' => 'success',
        'reference' => '3461fcc31aec471780ad1a4dc6111947',
        'currency' => 'JPY',
        'amount' => 1000,
        'captured' => false }
    end

    context 'with client_ip' do
      let(:body) do
        'card_number=6221558812340000'\
        '&card_exp_year=17'\
        '&card_exp_month=11'\
        '&card_cvv=123'\
        '&client_ip=192.168.0.1'\
        '&capture=false'\
        '&amount=1000'\
        '&currency=USD'
      end
      it { expect(HTTParty).to receive(:post).with(url, headers: headers, body: body) }
      after { described_class.start(1000, cc, client_ip: '192.168.0.1') }
    end

    context 'with other options' do
      let(:options) do
        { client_ip: '192.168.0.1',
          currency: 'USD',
          description: 'Lorem ipsum',
          note: 'To self',
          reference: '111111' }
      end
      let(:body) do
        'card_number=6221558812340000'\
        '&card_exp_year=17'\
        '&card_exp_month=11'\
        '&card_cvv=123'\
        '&currency=USD'\
        '&description=Lorem ipsum'\
        '&note=To self'\
        '&reference=111111'\
        '&client_ip=192.168.0.1'\
        '&capture=false'\
        '&amount=1000'
      end
      it { expect(HTTParty).to receive(:post).with(url, headers: headers, body: body) }
      after { described_class.start(1000, cc, options) }
    end

    context 'with invalid options' do
      let(:options) { { client_ip: '192.168.0.1', foo: :bar } }
      let(:body) do
        'card_number=6221558812340000'\
        '&card_exp_year=17'\
        '&card_exp_month=11'\
        '&card_cvv=123'\
        '&client_ip=192.168.0.1'\
        '&capture=false'\
        '&amount=1000'\
        '&currency=USD'
      end
      it { expect(HTTParty).to receive(:post).with(url, headers: headers, body: body) }
      after { described_class.start(1000, cc, options) }
    end

    context 'with :token in options' do
      let(:options) { { client_ip: '192.168.0.1', token: 'ec471780ad1' } }
      let(:headers) do
        { 'Authorization' => 'Bearer ec471780ad1',
          'Content-Type' => 'application/x-www-form-urlencoded' }
      end
      let(:body) do
        'card_number=6221558812340000'\
        '&card_exp_year=17'\
        '&card_exp_month=11'\
        '&card_cvv=123'\
        '&client_ip=192.168.0.1'\
        '&capture=false'\
        '&amount=1000'\
        '&currency=USD'
      end
      it { expect(HTTParty).to receive(:post).with(url, headers: headers, body: body) }
      after do
        described_class.start(1000, cc, options)
        described_class.instance_variable_set(:@token, nil)
      end
    end

    context 'with :sub_mid in options' do
      let(:options) { { client_ip: '192.168.0.1', sub_mid: 'foobar' } }
      let(:body) do
        'card_number=6221558812340000'\
        '&card_exp_year=17'\
        '&card_exp_month=11'\
        '&card_cvv=123'\
        '&client_ip=192.168.0.1'\
        '&capture=false'\
        '&amount=1000'\
        '&reserved={"sub_mid":"foobar"}'\
        '&currency=USD'
      end
      it { expect(HTTParty).to receive(:post).with(url, headers: headers, body: body) }
      after { described_class.start(1000, cc, options) }
    end

    describe '.build_from_response!' do
      it 'should return transaction object' do
        txn = described_class.start(1000, cc, client_ip: '192.168.0.1')
        expect(txn).to be_a Nihaopay::Transactions::Base
        expect(txn.transaction_id).to eq '20160714132438002485'
        expect(txn.status).to eq 'success'
      end
    end
  end
end
