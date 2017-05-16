module Nihaopay
  module Transactions
    class Capture < Base
      attr_accessor :captured, :capture_transaction_id

      class << self
        def start(transaction_id, amount, currency, options = {})
          @token = options.delete(:token)
          url = request_url(transaction_id)
          params = request_params(options.merge(amount: amount, currency: currency))
          response = HTTParty.post(url, headers: request_headers, body: request_body(params))
          build_from_response!(response)
        end

        def request_url(transaction_id)
          "#{base_url}/transactions/#{transaction_id}/capture"
        end

        def request_params(options = {})
          params = Nihaopay::HashUtil.slice(options, *valid_options)
          params[:reserved] = { 'sub_mid' => options[:sub_mid].to_s }.to_json if options.key?(:sub_mid)
          params
        end

        def valid_options
          %i[amount currency].freeze
        end

        def valid_attributes
          %i[transaction_id status captured capture_transaction_id time].freeze
        end

        def response_keys_map
          { id: :transaction_id, transaction_id: :capture_transaction_id }
        end
      end
    end
  end
end
