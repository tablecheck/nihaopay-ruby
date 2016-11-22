module Nihaopay
  module Transactions
    class Capture < Base
      attr_accessor :captured, :capture_transaction_id

      class << self
        def start(transaction_id, amount, currency, options = {})
          @token = options.delete(:token)
          url = request_url(transaction_id)
          params = request_body(amount: amount, currency: currency)
          response = HTTParty.post(url, headers: request_headers, body: params)
          build_from_response!(response)
        end

        def request_url(transaction_id)
          "#{base_url}/transactions/#{transaction_id}/capture"
        end

        def valid_attributes
          %i(transaction_id status captured capture_transaction_id)
        end

        def response_keys_map
          { id: :transaction_id, transaction_id: :capture_transaction_id }
        end
      end
    end
  end
end
