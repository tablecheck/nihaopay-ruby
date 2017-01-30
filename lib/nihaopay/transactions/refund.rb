module Nihaopay
  module Transactions
    class Refund < Capture
      attr_accessor :refunded, :refund_transaction_id

      class << self
        def request_url(transaction_id)
          "#{base_url}/transactions/#{transaction_id}/refund"
        end

        def valid_options
          super | %i(reason)
        end

        def valid_attributes
          %i(transaction_id status refunded refund_transaction_id time)
        end

        def response_keys_map
          { id: :transaction_id, transaction_id: :refund_transaction_id }
        end
      end
    end
  end
end
