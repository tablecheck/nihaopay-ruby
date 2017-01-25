module Nihaopay
  class Merchant
    attr_accessor :token

    def initialize(token)
      self.token = token
    end

    def union_pay(amount, currency, options = {})
      options[:token] = token
      Nihaopay::SecurePay::UnionPay.start(amount, currency, options)
    end

    def ali_pay(amount, currency, options = {})
      options[:token] = token
      Nihaopay::SecurePay::AliPay.start(amount, currency, options)
    end

    def wechat_pay(amount, currency, options = {})
      options[:token] = token
      Nihaopay::SecurePay::WeChatPay.start(amount, currency, options)
    end

    def authorize(amount, credit_card, options = {})
      options[:token] = token
      Nihaopay::Transactions::Authorize.start(amount, credit_card, options)
    end

    def capture(transaction_id, amount, currency, options = {})
      options[:token] = token
      Nihaopay::Transactions::Capture.start(transaction_id, amount, currency, options)
    end

    def purchase(amount, credit_card, options = {})
      options[:token] = token
      Nihaopay::Transactions::Purchase.start(amount, credit_card, options)
    end

    def release(transaction_id, options = {})
      options[:token] = token
      Nihaopay::Transactions::Release.start(transaction_id, options)
    end

    def refund(transaction_id, amount, currency, options = {})
      options[:token] = token
      Nihaopay::Transactions::Refund.start(transaction_id, amount, currency, options)
    end
  end
end
