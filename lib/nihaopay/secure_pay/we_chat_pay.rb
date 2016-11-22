module Nihaopay
  module SecurePay
    class WeChatPay < Base
      class << self
        def vendor
          :wechatpay
        end
      end
    end
  end
end
