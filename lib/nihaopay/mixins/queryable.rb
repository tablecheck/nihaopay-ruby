module Nihaopay
  module Queryable
    TIME_FORMAT = '%Y-%m-%dT%H:%M:%S%z'.freeze

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
        options[:starting_after] = options.delete(:after).strftime(TIME_FORMAT) if options[:after]
        options[:ending_before] = options.delete(:before).strftime(TIME_FORMAT) if options[:before]
        q.fetch(options)
      end

      def limit(num)
        q.limit(num)
      end

      def before(time)
        q.before(time.strftime(TIME_FORMAT))
      end

      def after(time)
        q.after(time.strftime(TIME_FORMAT))
      end

      private

      def q
        Nihaopay::Query.new
      end
    end
  end
end
