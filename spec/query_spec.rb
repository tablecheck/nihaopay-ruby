require_relative 'spec_helper'

describe Nihaopay::Query do
  before do
    Nihaopay.test_mode = true
    Nihaopay.token = token
  end
  let(:token) { '6c4dc4828474fa73c5f438a9eb2f' }
  let(:q) { described_class.new }

  describe '#limit' do
    it 'should set @limit' do
      q2 = q.limit(5)
      expect(q2).to eq q
      expect(q2.instance_variable_get(:@limit)).to eq 5
    end
  end

  describe '#before' do
    it 'should set @ending_before' do
      q2 = q.before('2016-07-01T01:00:00Z')
      expect(q2).to eq q
      expect(q2.instance_variable_get(:@ending_before)).to eq '2016-07-01T01:00:00Z'
    end
  end

  describe '#after' do
    it 'should set @starting_after' do
      q2 = q.after('2016-07-01T01:00:00Z')
      expect(q2).to eq q
      expect(q2.instance_variable_get(:@starting_after)).to eq '2016-07-01T01:00:00Z'
    end
  end

  describe '#fetch' do
    before { q.limit(5).before('2016-07-01T01:00:00Z').after('2016-06-01T01:00:00Z') }

    context 'when options not passed' do
      let(:expected_options) do
        { limit: 5,
          starting_after: '2016-06-01T01:00:00Z',
          ending_before: '2016-07-01T01:00:00Z' }
      end
      it { expect(described_class).to receive(:fetch).with(expected_options) }
      after { q.fetch }
    end

    context 'when options passed' do
      let(:expected_options) { { limit: 3 } }
      it { expect(described_class).to receive(:fetch).with(expected_options) }
      after { q.fetch(limit: 3) }
    end
  end

  describe '.fetch' do
    before do
      allow(response).to receive(:parsed_response) { parsed_response }
      allow(HTTParty).to receive(:get) { response }
    end
    let(:response) { Object.new }
    let(:parsed_response) do
      { 'transactions' => [{ 'id' => '20160718111604002633', 'type' => 'charge', 'status' => 'success' },
                           { 'id' => '20160718111604002634', 'type' => 'charge', 'status' => 'failure' }] }
    end
    let(:url) { 'http://api.test.nihaopay.com/v1.1/transactions' }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }

    context 'when options not passed' do
      it { expect(HTTParty).to receive(:get).with(url, headers: headers) }
      after { described_class.fetch }
    end

    context 'when query present' do
      let(:options) { { limit: 5, starting_after: '2016-07-01T01:00:00Z' } }
      it { expect(HTTParty).to receive(:get).with(url, headers: headers, query: options) }
      after { described_class.fetch(options) }
    end

    context 'with invalid options' do
      let(:options) { { foo: :bar } }
      it { expect(HTTParty).to receive(:get).with(url, headers: headers) }
      after { described_class.fetch(options) }
    end

    context 'with blank values' do
      let(:options) { { limit: nil, starting_after: '' } }
      it { expect(HTTParty).to receive(:get).with(url, headers: headers) }
      after { described_class.fetch(options) }
    end

    describe '.build_transactions' do
      context 'when response does not contain :transactions' do
        let(:parsed_response) do
          { 'id' => '20160718111604002633', 'type' => 'charge', 'status' => 'success' }
        end
        it { expect { described_class.fetch }.to raise_error(Nihaopay::TransactionLookUpError) }
      end

      context 'when response contains :transactions' do
        it 'should return collection of transaction objects' do
          txns = described_class.fetch
          expect(txns.size).to eq 2
          expect(txns[0]).to be_a Nihaopay::Transactions::Base
          expect(txns[0].transaction_id).to eq '20160718111604002633'
          expect(txns[0].type).to eq 'charge'
          expect(txns[0].status).to eq 'success'
          expect(txns[1]).to be_a Nihaopay::Transactions::Base
          expect(txns[1].transaction_id).to eq '20160718111604002634'
          expect(txns[1].type).to eq 'charge'
          expect(txns[1].status).to eq 'failure'
        end
      end
    end
  end

  describe '.url' do
    it { expect(described_class.url).to eq 'http://api.test.nihaopay.com/v1.1/transactions' }
  end

  describe '.request_headers' do
    let(:expected_headers) { { 'Authorization' => "Bearer #{token}" } }
    it { expect(described_class.request_headers).to eq expected_headers }
  end

  describe '.query_params' do
    let(:options) { { limit: 5, starting_after: nil, foo: :bar } }
    it { expect(described_class.query_params(options)).to eq(limit: 5) }
  end
end
