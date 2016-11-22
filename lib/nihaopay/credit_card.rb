module Nihaopay
  class CreditCard
    ATTRIBUTES = %i(number expiry_year expiry_month cvv).freeze

    attr_accessor(*ATTRIBUTES)

    def initialize(attributes = {})
      attributes.symbolize_keys!
      assign_attributes(attributes)
    end

    def to_params_hash
      { card_number: number,
        card_exp_year: expiry_year,
        card_exp_month: expiry_month,
        card_cvv: cvv }
    end

    private

    def assign_attributes(attributes)
      ATTRIBUTES.each do |attribute|
        send("#{attribute}=", attributes[attribute])
      end
    end
  end
end
