module Nihaopay
  module Transactions
    class Cancel < Base
      attr_accessor :cancelled, :cancel_transaction_id

      class << self
        def start(transaction_id, options = {})
          @token = options.delete(:token)
          url = request_url(transaction_id)
          response = HTTParty.post(url, headers: request_headers, body: request_body)
          build_from_response!(response)
        end

        def request_url(transaction_id)
          "#{base_url}/transactions/#{transaction_id}/cancel"
        end

        def valid_attributes
          %i(transaction_id status cancelled cancel_transaction_id)
        end

        def response_keys_map
          { id: :transaction_id, transaction_id: :cancel_transaction_id }
        end
      end
    end
  end
end
