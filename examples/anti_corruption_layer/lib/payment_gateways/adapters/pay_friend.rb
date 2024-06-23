# frozen_string_literal: true

module PaymentGateways
  class Adapters::PayFriend
    attr_reader :client

    def initialize
      @client = ::PayFriend::Client.new
    end

    def charge_credit_card(params)
      params => { amount:, details: }

      response = client.charge(amount:, payment_data: details, payment_method: 'credit_card')

      Response.new(response.status == 'success')
    end
  end
end
