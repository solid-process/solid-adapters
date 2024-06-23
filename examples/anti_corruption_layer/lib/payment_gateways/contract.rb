# frozen_string_literal: true

module PaymentGateways
  class Contract < ::Solid::Adapters::Proxy
    def charge_credit_card(params)
      params => { amount: Numeric, details: Hash }

      outcome = object.charge_credit_card(params)

      outcome => Response[true | false]

      outcome
    end
  end
end
