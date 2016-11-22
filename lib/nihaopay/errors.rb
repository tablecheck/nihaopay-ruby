module Nihaopay
  TransactionError = Class.new(StandardError)
  SecurePayTransactionError = Class.new(TransactionError)
  ExpressPayTransactionError = Class.new(TransactionError)
  TransactionLookUpError = Class.new(TransactionError)
end
