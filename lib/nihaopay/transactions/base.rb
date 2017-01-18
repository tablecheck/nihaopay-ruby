module Nihaopay
  module Transactions
    class Base
      include ::Nihaopay::Api
      include ::Nihaopay::Queryable

      attr_accessor :token, :transaction_id, :type, :status
      attr_accessor :captured, :reference, :currency, :amount, :note, :time

      def initialize(attributes = {})
        assign_attributes(attributes)
      end

      def capture
        Nihaopay::Transactions::Capture.start(transaction_id, amount, currency, token: token)
      end

      def partial_capture(capture_amount)
        Nihaopay::Transactions::Capture.start(transaction_id, capture_amount, currency, token: token)
      end

      def release
        Nihaopay::Transactions::Release.start(transaction_id, token: token)
      end

      def cancel
        Nihaopay::Transactions::Cancel.start(transaction_id, token: token)
      end

      def refund(options = {})
        options[:token] = token
        Nihaopay::Transactions::Refund.start(transaction_id, amount, currency, options)
      end

      def partial_refund(refund_amount, options = {})
        options[:token] = token
        Nihaopay::Transactions::Refund.start(transaction_id, refund_amount, currency, options)
      end

      class << self
        def request_headers
          authorization.merge('Content-Type' => 'application/x-www-form-urlencoded')
        end

        def request_body(params = {})
          params.map { |k, v| "#{k}=#{v}" }.join('&')
        end

        def build_from_response!(response)
          validate_resource!(response)
          build(response.parsed_response)
        end

        def build(options = {})
          options = Nihaopay::HashUtil.symbolize_keys(options)
          attributes = Nihaopay::HashUtil.slice(options, *valid_attributes)
          attributes[:token] ||= merchant_token
          attributes[:time] = attributes[:time] ? Time.parse(attributes[:time]) : Time.now
          response_keys_map.each { |k, v| attributes[v] = options[k] }
          new(attributes)
        end

        def valid_attributes
          %i(token transaction_id type status captured currency reference amount note time)
        end

        def response_keys_map
          { id: :transaction_id }
        end
      end

      private

      def assign_attributes(attributes)
        self.class.valid_attributes.each { |f| send("#{f}=", attributes[f]) }
      end
    end
  end
end
