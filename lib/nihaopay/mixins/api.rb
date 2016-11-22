module Nihaopay
  module Api
    def self.included(base)
      base.extend(ClassMethods)
    end

    LIVE_HOST = 'https://api.nihaopay.com'.freeze
    TEST_HOST = 'http://api.test.nihaopay.com'.freeze
    VERSION = 'v1.1'.freeze

    module ClassMethods
      def host
        Nihaopay.test_mode ? TEST_HOST : LIVE_HOST
      end

      def base_url
        "#{host}/#{VERSION}"
      end

      def authorization
        { 'Authorization' => "Bearer #{merchant_token}" }
      end

      def merchant_token
        @token || Nihaopay.token
      end

      def validate_resource!(response)
        return if response.parsed_response['id']
        parsed_response = response.parsed_response.map { |k, v| "#{k}: #{v}" }.join(', ')
        fail Nihaopay::TransactionError, parsed_response
      end

      def validate_collection!(response)
        return if response.parsed_response['transactions']
        parsed_response = response.parsed_response.map { |k, v| "#{k}: #{v}" }.join(', ')
        fail Nihaopay::TransactionError, parsed_response
      end
    end
  end
end
