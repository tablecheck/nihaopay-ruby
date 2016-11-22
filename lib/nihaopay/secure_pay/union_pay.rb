module Nihaopay
  module SecurePay
    class UnionPay < Base
      class << self
        def vendor
          :unionpay
        end
      end
    end
  end
end
