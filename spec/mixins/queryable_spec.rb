require_relative '../spec_helper'

describe Nihaopay::Queryable do
  describe 'ClassMethods' do
    describe '.delegate' do
      before { allow(Nihaopay::Transactions::Base).to receive(:q) { q } }
      let(:q) { Nihaopay::Query.new }

      describe '.limit' do
        it { expect(q).to receive(:limit) }
        after { Nihaopay::Transactions::Base.limit }
      end

      describe '.before' do
        it { expect(q).to receive(:before) }
        after { Nihaopay::Transactions::Base.before }
      end

      describe '.after' do
        it { expect(q).to receive(:after) }
        after { Nihaopay::Transactions::Base.after }
      end
    end

    describe '.find' do
      before do
        allow(response).to receive(:parsed_response) { parsed_response }
        allow(HTTParty).to receive(:get) { response }
      end
      let(:response) { Object.new }
      let(:parsed_response) { nil }

      context 'when response does not contain transaction details' do
        let(:parsed_response) do
          { 'status' => 'success',
            'type' => 'charge',
            'amount' => 1000 }
        end
        it 'should raise an error' do
          expect { Nihaopay::Transactions::Base.find('20160714132438002485') }.to raise_error
        end
      end

      context 'when response contains transaction details' do
        let(:parsed_response) do
          { 'id' => '20160714132438002485',
            'status' => 'success',
            'type' => 'charge',
            'amount' => 1000 }
        end
        it 'should return a transaction object' do
          txn = Nihaopay::Transactions::Base.find('20160714132438002485')
          expect(txn).to be_a Nihaopay::Transactions::Base
          expect(txn.transaction_id).to eq '20160714132438002485'
          expect(txn.status).to eq 'success'
          expect(txn.type).to eq 'charge'
          expect(txn.amount).to eq 1000
        end
      end
    end

    describe '.fetch' do
      before { allow(Nihaopay::Transactions::Base).to receive(:q) { q } }
      let(:q) { Nihaopay::Query.new }

      context 'when :after present in options' do
        let(:options) { { after: '2016-06-01T01:00:00Z', limit: 5 } }
        it { expect(q).to receive(:fetch).with(starting_after: '2016-06-01T01:00:00Z', limit: 5) }
        after { Nihaopay::Transactions::Base.fetch(options) }
      end

      context 'when :before present in options' do
        let(:options) { { before: '2016-06-01T01:00:00Z', limit: 5 } }
        it { expect(q).to receive(:fetch).with(ending_before: '2016-06-01T01:00:00Z', limit: 5) }
        after { Nihaopay::Transactions::Base.fetch(options) }
      end

      context 'when :after and :before not present in options' do
        let(:options) { { limit: 5 } }
        it { expect(q).to receive(:fetch).with(limit: 5) }
        after { Nihaopay::Transactions::Base.fetch(options) }
      end

      context 'when options not passed' do
        it { expect(q).to receive(:fetch).with({}) }
        after { Nihaopay::Transactions::Base.fetch }
      end
    end

    describe '.q' do
      it { expect(Nihaopay::Transactions::Base.send(:q)).to be_a Nihaopay::Query }
    end
  end
end
