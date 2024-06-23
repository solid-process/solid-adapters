# frozen_string_literal: true

require 'securerandom'

module Payment
  class ChargeCreditCard
    include ::Solid::Output.mixin(config: { addon: { continue: true } })

    attr_reader :payment_gateway

    def initialize(payment_gateway)
      @payment_gateway = ::PaymentGateways::Contract.new(payment_gateway)
    end

    def call(amount:, details: {})
      Given(amount:)
        .and_then(:validate_amount)
        .and_then(:charge_credit_card, details:)
        .and_expose(:payment_charged, %i[payment_id])
    end

    private

    def validate_amount(amount:)
      return Continue() if amount.is_a?(::Numeric) && amount.positive?

      Failure(:invalid_amount, erros: ['amount must be positive'])
    end

    def charge_credit_card(amount:, details:)
      response = payment_gateway.charge_credit_card(amount:, details:)

      Continue(payment_id: ::SecureRandom.uuid) if response.success?
    end
  end
end
