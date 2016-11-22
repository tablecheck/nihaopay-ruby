module Nihaopay
  module Transactions
    class Authorize < Base
      class << self
        def start(amount, credit_card, options = {})
          @token = options.delete(:token)
          params = request_params(amount, credit_card, options)
          body = request_body(params)
          response = HTTParty.post(request_url, headers: request_headers, body: body)
          build_from_response!(response)
        end

        def request_url
          "#{base_url}/transactions/expresspay"
        end

        def request_params(amount, credit_card, options)
          params = {}
          params.merge! credit_card.to_params_hash
          params.merge! options.slice(*valid_options)
          params[:capture] = capture_param
          params[:amount] = amount
          params[:currency] ||= Nihaopay.currency
          params
        end

        def valid_options
          %i(currency description note reference)
        end

        def capture_param
          false
        end
      end
    end
  end
end
