module Nihaopay
  module SecurePay
    class Base
      include ::Nihaopay::Api

      class << self
        def with_failure(&_)
          response = yield
          if response.code != 200
            message = response.parsed_response.map { |k, v| "#{k}: #{v}" }.join(', ')
            fail SecurePayTransactionError, message
          end
          response
        end

        def start(amount, currency, options = {})
          with_failure do
            @token = options.delete(:token)
            params = request_params(amount, currency, options)
            body = request_body(params)
            HTTParty.post(request_url, headers: request_headers, body: body)
          end
        end

        def request_url
          "#{base_url}/transactions/securepay"
        end

        def request_headers
          authorization
        end

        def request_params(amount, currency, options)
          { amount: amount.to_i,
            currency: currency.to_s,
            vendor: vendor.to_s,
            reference: options[:reference].to_s.slice(0, 30),
            ipn_url: options[:ipn_url].to_s,
            callback_url: options[:callback_url].to_s }
        end

        def request_body(params = {})
          params.map { |k, v| "#{k}=#{v}" }.join('&')
        end
      end
    end
  end
end
