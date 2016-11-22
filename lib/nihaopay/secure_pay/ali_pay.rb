module Nihaopay
  module SecurePay
    class AliPay < Base
      class << self
        def vendor
          :alipay
        end
      end
    end
  end
end
