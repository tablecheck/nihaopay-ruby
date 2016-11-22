module Nihaopay
  class Query
    include ::Nihaopay::Api

    VALID_OPTIONS = %i(limit starting_after ending_before).freeze

    def limit(num)
      @limit = num
      self
    end

    def before(time)
      @ending_before = time
      self
    end

    def after(time)
      @starting_after = time
      self
    end

    def fetch(options = nil)
      options ||= { limit: @limit, starting_after: @starting_after, ending_before: @ending_before }
      self.class.fetch(options)
    end

    class << self
      def fetch(options = {})
        query = query_params(options)
        response = if query.present?
                     HTTParty.get(url, headers: request_headers, query: query)
                   else
                     HTTParty.get(url, headers: request_headers)
                   end
        build_transactions(response)
      rescue Nihaopay::TransactionError => e
        raise Nihaopay::TransactionLookUpError, e.message
      end

      def url
        "#{base_url}/transactions"
      end

      def request_headers
        authorization
      end

      def query_params(options)
        options.slice(*VALID_OPTIONS).reject { |_, v| v.blank? }
      end

      def build_transactions(response)
        validate_collection!(response)
        transactions = response.parsed_response['transactions']
        transactions.map do |transaction|
          Nihaopay::Transactions::Base.build(transaction)
        end
      end
    end
  end
end
