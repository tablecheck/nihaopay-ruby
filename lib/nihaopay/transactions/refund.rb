module Nihaopay
  module Transactions
    class Refund < Base
      VALID_OPTIONS = %i(reason).freeze

      attr_accessor :refunded, :refund_transaction_id

      class << self
        def start(transaction_id, amount, currency, options = {})
          @token = options.delete(:token)
          url = request_url(transaction_id)
          params = options.slice(*VALID_OPTIONS).merge(amount: amount, currency: currency)
          response = HTTParty.post(url, headers: request_headers, body: request_body(params))
          build_from_response!(response)
        end

        def request_url(transaction_id)
          "#{base_url}/transactions/#{transaction_id}/refund"
        end

        def valid_attributes
          %i(transaction_id status refunded refund_transaction_id)
        end

        def response_keys_map
          { id: :transaction_id, transaction_id: :refund_transaction_id }
        end
      end
    end
  end
end
