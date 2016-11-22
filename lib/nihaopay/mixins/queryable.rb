module Nihaopay
  module Queryable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
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

      def limit(num)
        q.limit(num)
      end

      def before(time)
        q.before(time)
      end

      def after(time)
        q.after(time)
      end

      private

      def q
        Nihaopay::Query.new
      end
    end
  end
end
