module Nihaopay
  module Queryable
    extend ::ActiveSupport::Concern

    module ClassMethods
      delegate :limit, :before, :after, to: :q

      def find(transaction_id)
        url = "#{base_url}/transactions/#{transaction_id}"
        response = HTTParty.get(url, headers: request_headers)
        build_from_response!(response)
      rescue Nihaopay::TransactionError => e
        raise Nihaopay::TransactionLookUpError, e.message
      end

      def fetch(options = {})
        options[:starting_after] = options.delete(:after) if options[:after]
        options[:ending_before] = options.delete(:before) if options[:before]
        q.fetch(options)
      end

      private

      def q
        Nihaopay::Query.new
      end
    end
  end
end
