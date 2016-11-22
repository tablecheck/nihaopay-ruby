module Nihaopay
  DEFAULT_CURRENCY = 'USD'.freeze

  class << self
    attr_accessor :test_mode, :token, :currency

    def configure
      yield self
    end
  end
end

Nihaopay.test_mode = false
Nihaopay.currency = Nihaopay::DEFAULT_CURRENCY
