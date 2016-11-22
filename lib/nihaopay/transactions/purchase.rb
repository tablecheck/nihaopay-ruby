module Nihaopay
  module Transactions
    class Purchase < Authorize
      class << self
        def capture_param
          true
        end
      end
    end
  end
end
