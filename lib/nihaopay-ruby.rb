require 'httparty'

require 'nihaopay/util/hash_util'

require 'nihaopay/mixins/api'
require 'nihaopay/mixins/queryable'

require 'nihaopay/configure'
require 'nihaopay/credit_card'
require 'nihaopay/errors'
require 'nihaopay/merchant'
require 'nihaopay/query'
require 'nihaopay/version'

require 'nihaopay/secure_pay/base'
require 'nihaopay/secure_pay/ali_pay'
require 'nihaopay/secure_pay/union_pay'
require 'nihaopay/secure_pay/we_chat_pay'

require 'nihaopay/transactions/base'
require 'nihaopay/transactions/authorize'
require 'nihaopay/transactions/capture'
require 'nihaopay/transactions/cancel'
require 'nihaopay/transactions/purchase'
require 'nihaopay/transactions/refund'
require 'nihaopay/transactions/release'

module Nihaopay
end
