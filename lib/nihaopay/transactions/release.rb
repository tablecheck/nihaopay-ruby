module Nihaopay
  module Transactions
    class Release < Cancel
      attr_accessor :released, :release_transaction_id

      class << self
        def request_url(transaction_id)
          "#{base_url}/transactions/#{transaction_id}/release"
        end

        def valid_attributes
          %i(transaction_id status released release_transaction_id time)
        end

        def response_keys_map
          { id: :transaction_id, transaction_id: :release_transaction_id }
        end
      end
    end
  end
end
